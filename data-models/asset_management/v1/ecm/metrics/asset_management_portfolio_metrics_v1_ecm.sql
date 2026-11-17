-- Metric views for domain: portfolio | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_allocation_decisions`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Formal capital allocation decisions from portfolios to deal opportunities."
  source: "`asset_management`.`portfolio`.`portfolio_allocation`"
  dimensions:
    - name: "Status"
      display_name: "Status"
      expr: portfolio_allocation_status
      comment: "Status"
  measures:
    - name: "Allocations"
      display_name: "Allocations"
      expr: COUNT(1)
      comment: "Allocations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Allocation %"
      display_name: "Avg allocation %"
      expr: ROUND(AVG(CAST(percentage AS DOUBLE)),2)
      comment: "Allocation %"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_asset`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Instrument/asset master semantic layer — market value, ESG/carbon, duration/yield and listing coverage. Supports exposure, ESG (SFDR) and fixed-income risk steering."
  source: "`asset_management`.`portfolio`.`asset`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the instrument."
    - name: "Sector"
      display_name: "Sector"
      expr: sector
      comment: "Sector classification."
    - name: "Credit Rating"
      display_name: "Credit Rating"
      expr: credit_rating
      comment: "Credit rating of the instrument."
    - name: "Country Of Risk"
      display_name: "Country of Risk"
      expr: country_of_risk
      comment: "Country of risk for the instrument."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency of the instrument."
    - name: "Liquidity Classification"
      display_name: "Liquidity Classification"
      expr: liquidity_classification
      comment: "Liquidity classification of the instrument."
    - name: "Valuation Month"
      display_name: "Valuation Month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Valuation date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Market Value"
      display_name: "Market Value"
      expr: SUM(CAST(market_value AS DOUBLE))
      comment: "Aggregate market value of instruments — exposure base."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Book Value"
      display_name: "Book Value"
      expr: SUM(CAST(book_value AS DOUBLE))
      comment: "Aggregate book value of instruments."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg ESG Score"
      display_name: "Avg ESG Score"
      expr: AVG(CAST(esg_score AS DOUBLE))
      comment: "Average ESG score across instruments — portfolio sustainability profile (SFDR)."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Carbon Intensity"
      display_name: "Avg Carbon Intensity"
      expr: AVG(CAST(carbon_intensity AS DOUBLE))
      comment: "Average carbon intensity — climate risk/TCFD indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Yield To Maturity"
      display_name: "Avg YTM %"
      expr: AVG(CAST(yield_to_maturity AS DOUBLE))
      comment: "Average yield-to-maturity — fixed-income income profile."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Duration Years"
      display_name: "Avg Duration (yrs)"
      expr: AVG(CAST(duration_years AS DOUBLE))
      comment: "Average duration — interest-rate sensitivity of the book."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Listed Asset Rate"
      display_name: "Listed Asset %"
      expr: AVG(CASE WHEN is_listed = TRUE THEN 1.0 ELSE 0.0 END)
      comment: "Share of assets that are listed — liquidity/transparency profile."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Hedged Asset Rate"
      display_name: "Hedged Asset %"
      expr: AVG(CASE WHEN is_hedged = TRUE THEN 1.0 ELSE 0.0 END)
      comment: "Share of assets that are hedged — risk-mitigation coverage."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_asset_class_market_value`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Realized market value by asset class and drift from benchmark/target weights."
  source: "`asset_management`.`portfolio`.`asset_class_weight`"
  filter: is_active = TRUE
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class_name
      comment: "Asset class"
    - name: "Liquidity Class"
      display_name: "Liquidity class"
      expr: liquidity_classification
      comment: "Liquidity"
  measures:
    - name: "Market Value"
      display_name: "Market value"
      expr: SUM(CAST(market_value AS DOUBLE))
      comment: "Market value"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Deviation From Target"
      display_name: "Avg deviation from target"
      expr: ROUND(AVG(CAST(deviation_from_target AS DOUBLE)),2)
      comment: "Drift from target"
    - name: "Avg Active Weight %"
      display_name: "Avg active weight %"
      expr: ROUND(AVG(CAST(active_weight_percentage AS DOUBLE)),2)
      comment: "Active weight"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_asset_class_weight`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Asset-allocation weight semantic layer — active weight vs benchmark, deviation from target, and rebalancing pressure. Core SAA/TAA steering."
  source: "`asset_management`.`portfolio`.`asset_class_weight`"
  dimensions:
    - name: "Asset Class Name"
      display_name: "Asset Class"
      expr: asset_class_name
      comment: "Asset class label."
    - name: "Weight Status"
      display_name: "Weight Status"
      expr: weight_status
      comment: "Status of the weight (within/above/below band)."
    - name: "Base Currency"
      display_name: "Base Currency"
      expr: base_currency_code
      comment: "Base currency of the weight calculation."
    - name: "Reporting Period"
      display_name: "Reporting Period"
      expr: reporting_period
      comment: "Reporting period for the weight snapshot."
    - name: "Valuation Month"
      display_name: "Valuation Month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Valuation date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Market Value"
      display_name: "Market Value"
      expr: SUM(CAST(market_value AS DOUBLE))
      comment: "Market value of the asset class slice."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Active Weight"
      display_name: "Avg Active Weight %"
      expr: AVG(CAST(active_weight_percentage AS DOUBLE))
      comment: "Average active weight vs benchmark — degree of active positioning."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Deviation From Target"
      display_name: "Avg Deviation From Target %"
      expr: AVG(CAST(deviation_from_target AS DOUBLE))
      comment: "Average deviation from SAA target weight — drift indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Contribution To Return"
      display_name: "Avg Contribution To Return %"
      expr: AVG(CAST(contribution_to_return AS DOUBLE))
      comment: "Average contribution to return by asset class — attribution signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Rebalancing Required Rate"
      display_name: "Rebalancing Required %"
      expr: AVG(CASE WHEN rebalancing_required_flag = TRUE THEN 1.0 ELSE 0.0 END)
      comment: "Share of asset class slices flagged for rebalancing — operational trigger."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unfunded Commitment"
      display_name: "Unfunded Commitment"
      expr: SUM(CAST(unfunded_commitment_amount AS DOUBLE))
      comment: "Unfunded commitment attributed to the asset class — liquidity planning."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_asset_master_esg`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Asset-level ESG score, carbon intensity, and credit rating distribution across the book."
  source: "`asset_management`.`portfolio`.`asset`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
    - name: "Country of Risk"
      display_name: "Country of risk"
      expr: country_of_risk
      comment: "Country"
    - name: "Credit Rating"
      display_name: "Credit rating"
      expr: credit_rating
      comment: "Rating"
  measures:
    - name: "Assets"
      display_name: "Assets"
      expr: COUNT(1)
      comment: "Assets"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg ESG Score"
      display_name: "Avg esg score"
      expr: ROUND(AVG(CAST(esg_score AS DOUBLE)),2)
      comment: "ESG"
    - name: "Avg Carbon Intensity"
      display_name: "Avg carbon intensity"
      expr: ROUND(AVG(CAST(carbon_intensity AS DOUBLE)),2)
      comment: "Carbon"
    - name: "Avg Duration (yrs)"
      display_name: "Avg duration (yrs)"
      expr: ROUND(AVG(CAST(duration_years AS DOUBLE)),2)
      comment: "Duration"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_benchmark_assignment_te`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Assigned benchmark tracking error limits and assignment governance status."
  source: "`asset_management`.`portfolio`.`benchmark_assignment`"
  dimensions:
    - name: "Assignment Type"
      display_name: "Assignment type"
      expr: assignment_type
      comment: "Type"
    - name: "Status"
      display_name: "Status"
      expr: assignment_status
      comment: "Status"
  measures:
    - name: "Assignments"
      display_name: "Assignments"
      expr: COUNT(1)
      comment: "Assignments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg TE Limit"
      display_name: "Avg te limit"
      expr: ROUND(AVG(CAST(tracking_error_limit AS DOUBLE)),2)
      comment: "TE limit"
    - name: "Avg Assignment Weight"
      display_name: "Avg assignment weight"
      expr: ROUND(AVG(CAST(assignment_weight AS DOUBLE)),2)
      comment: "Weight"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_benchmark_registry`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Primary benchmark assignment coverage and ESG integration across portfolios."
  source: "`asset_management`.`portfolio`.`portfolio_benchmark`"
  filter: assignment_status = 'ACTIVE'
  dimensions:
    - name: "Benchmark Category"
      display_name: "Benchmark category"
      expr: benchmark_category
      comment: "Category"
    - name: "Geography"
      display_name: "Geography"
      expr: geography
      comment: "Geography"
    - name: "Type"
      display_name: "Type"
      expr: benchmark_type
      comment: "Type"
  measures:
    - name: "Assignments"
      display_name: "Assignments"
      expr: COUNT(1)
      comment: "Assignments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Primary %"
      display_name: "Primary %"
      expr: ROUND(100.0 * SUM(CASE WHEN is_primary_benchmark = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Primary share"
    - name: "ESG Integrated %"
      display_name: "Esg integrated %"
      expr: ROUND(100.0 * SUM(CASE WHEN esg_integration_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "ESG integrated"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_capital_commitment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Private-markets capital commitment semantic layer — committed/funded/unfunded capital, dry-powder, and target return/MOIC. Drives pacing and liquidity planning."
  source: "`asset_management`.`portfolio`.`portfolio_capital_commitment`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the commitment."
    - name: "Commitment Status"
      display_name: "Commitment Status"
      expr: commitment_status
      comment: "Lifecycle status of the commitment."
    - name: "Commitment Type"
      display_name: "Commitment Type"
      expr: commitment_type
      comment: "Type of commitment (fund/co-invest/direct)."
    - name: "Geographic Focus"
      display_name: "Geographic Focus"
      expr: geographic_focus
      comment: "Geographic focus of the commitment."
    - name: "Investment Strategy"
      display_name: "Investment Strategy"
      expr: investment_strategy
      comment: "Investment strategy of the commitment."
    - name: "Vintage Year"
      display_name: "Vintage Year"
      expr: vintage_year
      comment: "Vintage year of the commitment — pacing cohort."
    - name: "Commitment Month"
      display_name: "Commitment Month"
      expr: DATE_TRUNC('month', commitment_date)
      comment: "Commitment date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Committed Capital"
      display_name: "Committed Capital"
      expr: SUM(CAST(base_currency_committed_amount AS DOUBLE))
      comment: "Total committed capital in base currency — scale of private-markets program."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Funded Capital"
      display_name: "Funded Capital"
      expr: SUM(CAST(base_currency_funded_amount AS DOUBLE))
      comment: "Capital drawn/funded to date in base currency."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Unfunded Capital"
      display_name: "Unfunded Capital (Dry Powder)"
      expr: SUM(CAST(base_currency_unfunded_amount AS DOUBLE))
      comment: "Undrawn commitment (dry powder) in base currency — future funding obligation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Funded Ratio"
      display_name: "Funded Ratio %"
      expr: SUM(CAST(base_currency_funded_amount AS DOUBLE)) / NULLIF(SUM(CAST(base_currency_committed_amount AS DOUBLE)), 0)
      comment: "Funded as a share of committed — program drawdown progress. Single-aggregate-per-call ratio composed of two SUMs only (allowed: one division of two aggregates)."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target IRR"
      display_name: "Avg Target IRR %"
      expr: AVG(CAST(target_irr_percent AS DOUBLE))
      comment: "Average target IRR across commitments — expected return profile."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target MOIC"
      display_name: "Avg Target MOIC"
      expr: AVG(CAST(target_moic AS DOUBLE))
      comment: "Average target MOIC across commitments — expected multiple."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Management Fee"
      display_name: "Avg Management Fee %"
      expr: AVG(CAST(management_fee_percent AS DOUBLE))
      comment: "Average management fee rate — cost of external management."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Responsible Investment Rate"
      display_name: "Responsible Investment %"
      expr: AVG(CASE WHEN responsible_investment_flag = TRUE THEN 1.0 ELSE 0.0 END)
      comment: "Share of commitments flagged responsible-investment — ESG mandate adherence (SFDR)."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_capital_commitment_esg_classification`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "ESG classification mix of capital commitments for SFDR Article 8/9 reporting."
  source: "`asset_management`.`portfolio`.`portfolio_capital_commitment`"
  dimensions:
    - name: "ESG Classification"
      display_name: "Esg classification"
      expr: esg_classification
      comment: "ESG class"
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
  measures:
    - name: "Committed"
      display_name: "Committed"
      expr: SUM(CAST(committed_amount AS DOUBLE))
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

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_cash_flow`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Portfolio cash-flow semantic layer — inflows/outflows, withholding tax, reconciliation quality. Supports liquidity management and AML/reconciliation controls."
  source: "`asset_management`.`portfolio`.`portfolio_cash_flow`"
  dimensions:
    - name: "Flow Direction"
      display_name: "Flow Direction"
      expr: flow_direction
      comment: "Direction of the cash flow (inflow/outflow)."
    - name: "Flow Type"
      display_name: "Flow Type"
      expr: flow_type
      comment: "Type of cash flow (contribution/distribution/fee/income)."
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class associated with the cash flow."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency of the cash flow."
    - name: "Reconciliation Status"
      display_name: "Reconciliation Status"
      expr: reconciliation_status
      comment: "Reconciliation status of the cash flow."
    - name: "Transaction Month"
      display_name: "Transaction Month"
      expr: DATE_TRUNC('month', transaction_date)
      comment: "Transaction date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Cash Flow Amount"
      display_name: "Cash Flow Amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Aggregate cash-flow amount in base currency — net liquidity movement."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Withholding Tax"
      display_name: "Withholding Tax"
      expr: SUM(CAST(withholding_tax_amount AS DOUBLE))
      comment: "Aggregate withholding tax on cash flows — reclaim and tax-efficiency opportunity."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Withholding Tax Rate"
      display_name: "Avg Withholding Tax Rate %"
      expr: AVG(CAST(withholding_tax_rate_percent AS DOUBLE))
      comment: "Average withholding tax rate applied — tax drag indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Reconciled Cash Flow Rate"
      display_name: "Reconciled Cash Flow %"
      expr: AVG(CASE WHEN reconciliation_status = 'RECONCILED' THEN 1.0 ELSE 0.0 END)
      comment: "Share of cash flows reconciled — operational control quality (AML/ops)."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Reclaim Eligible Rate"
      display_name: "Reclaim Eligible %"
      expr: AVG(CASE WHEN reclaim_eligible_flag = TRUE THEN 1.0 ELSE 0.0 END)
      comment: "Share of flows eligible for tax reclaim — value-recovery opportunity."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Cash Flow Transactions"
      display_name: "Cash Flow Transactions"
      expr: COUNT(DISTINCT portfolio_cash_flow_id)
      comment: "Number of distinct cash-flow transactions — processing volume."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_cash_flow_net`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Net inflow/outflow across portfolio cash flow events by flow type and asset class."
  source: "`asset_management`.`portfolio`.`portfolio_cash_flow`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
    - name: "Flow Type"
      display_name: "Flow type"
      expr: flow_type
      comment: "Type of cash flow"
    - name: "Flow Direction"
      display_name: "Flow direction"
      expr: flow_direction
      comment: "Inflow or outflow"
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Net Flow Amount"
      display_name: "Net flow amount"
      expr: SUM(CASE WHEN flow_direction = 'INFLOW' THEN amount ELSE -amount END)
      comment: "Signed net flow"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Gross Flow"
      display_name: "Gross flow"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Gross cash flow"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_committed_capital`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Total committed capital and funded/unfunded split driving dry powder deployment strategy."
  source: "`asset_management`.`portfolio`.`portfolio_capital_commitment`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
    - name: "Commitment Status"
      display_name: "Commitment status"
      expr: commitment_status
      comment: "Status"
    - name: "Commitment Type"
      display_name: "Commitment type"
      expr: commitment_type
      comment: "Type"
  measures:
    - name: "Committed"
      display_name: "Committed"
      expr: SUM(CAST(base_currency_committed_amount AS DOUBLE))
      comment: "Committed base ccy"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Funded"
      display_name: "Funded"
      expr: SUM(CAST(base_currency_funded_amount AS DOUBLE))
      comment: "Funded base ccy"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Unfunded (Dry Powder)"
      display_name: "Unfunded (dry powder)"
      expr: SUM(CAST(base_currency_unfunded_amount AS DOUBLE))
      comment: "Unfunded commitment"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Funded %"
      display_name: "Funded %"
      expr: ROUND(100.0 * SUM(CAST(base_currency_funded_amount AS DOUBLE)) / NULLIF(SUM(CAST(base_currency_committed_amount AS DOUBLE)),0),2)
      comment: "Share funded"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_composite_membership`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Portfolio inclusion in GIPS composites and discretionary/fee-paying flags."
  source: "`asset_management`.`portfolio`.`portfolio_composite_membership`"
  dimensions:
    - name: "Inclusion Reason"
      display_name: "Inclusion reason"
      expr: inclusion_reason_code
      comment: "Reason"
    - name: "Currency"
      display_name: "Currency"
      expr: base_currency_code
      comment: "Currency"
  measures:
    - name: "Memberships"
      display_name: "Memberships"
      expr: COUNT(1)
      comment: "Memberships"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Discretionary %"
      display_name: "Discretionary %"
      expr: ROUND(100.0 * SUM(CASE WHEN discretionary_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Discretionary"
    - name: "Fee Paying %"
      display_name: "Fee paying %"
      expr: ROUND(100.0 * SUM(CASE WHEN fee_paying_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Fee-paying"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_constraint_breach`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Mandate/compliance breach semantic layer — breach volume, severity, regulatory reportability and remediation. Core SOX/compliance steering metric."
  source: "`asset_management`.`portfolio`.`constraint_breach`"
  dimensions:
    - name: "Breach Type"
      display_name: "Breach Type"
      expr: breach_type
      comment: "Category of the breach event."
    - name: "Severity Level"
      display_name: "Severity Level"
      expr: severity_level
      comment: "Severity classification of the breach."
    - name: "Breach Status"
      display_name: "Breach Status"
      expr: breach_status
      comment: "Lifecycle status of the breach (open/remediated/waived)."
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class in which the breach occurred."
    - name: "Constraint Category"
      display_name: "Constraint Category"
      expr: constraint_category
      comment: "Category of the breached constraint."
    - name: "Breach Month"
      display_name: "Breach Month"
      expr: DATE_TRUNC('month', breach_occurrence_timestamp)
      comment: "Breach occurrence bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Breach Events"
      display_name: "Breach Events"
      expr: COUNT(DISTINCT constraint_breach_id)
      comment: "Number of distinct breach events — headline compliance risk volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Breach Amount"
      display_name: "Breach Amount"
      expr: SUM(CAST(breach_amount AS DOUBLE))
      comment: "Aggregate monetary magnitude of breaches — financial materiality."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Breach Percentage"
      display_name: "Avg Breach %"
      expr: AVG(CAST(breach_percentage AS DOUBLE))
      comment: "Average breach magnitude as a percentage of threshold — severity depth indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Regulatory Reportable Rate"
      display_name: "Regulatory Reportable %"
      expr: AVG(CASE WHEN regulatory_reportable = TRUE THEN 1.0 ELSE 0.0 END)
      comment: "Share of breaches that are regulatory-reportable — regulatory exposure signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "IC Escalation Rate"
      display_name: "IC Escalation %"
      expr: AVG(CASE WHEN escalated_to_ic = TRUE THEN 1.0 ELSE 0.0 END)
      comment: "Share of breaches escalated to the Investment Committee — governance severity."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Remediation Rate"
      display_name: "Remediation %"
      expr: AVG(CASE WHEN remediated_timestamp IS NOT NULL THEN 1.0 ELSE 0.0 END)
      comment: "Share of breaches that have been remediated — remediation effectiveness."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Waiver Granted Rate"
      display_name: "Waiver Granted %"
      expr: AVG(CASE WHEN waiver_granted = TRUE THEN 1.0 ELSE 0.0 END)
      comment: "Share of breaches covered by an approved waiver — governance tolerance signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_constraint_breach_rate`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Volume and severity of investment guideline breaches detected in compliance monitoring."
  source: "`asset_management`.`portfolio`.`constraint_breach`"
  dimensions:
    - name: "Breach Type"
      display_name: "Breach type"
      expr: breach_type
      comment: "Type"
    - name: "Breach Status"
      display_name: "Breach status"
      expr: breach_status
      comment: "Status"
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
    - name: "Constraint Category"
      display_name: "Constraint category"
      expr: constraint_category
      comment: "Category"
  measures:
    - name: "Breach Count"
      display_name: "Breach count"
      expr: COUNT(1)
      comment: "Breaches"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Breach Amount"
      display_name: "Total breach amount"
      expr: SUM(CAST(breach_amount AS DOUBLE))
      comment: "Monetary breach"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Open Breach %"
      display_name: "Open breach %"
      expr: ROUND(100.0 * SUM(CASE WHEN breach_status = 'OPEN' THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Share open"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_constraint_inventory`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Inventory of active investment constraints and their historical breach counts."
  source: "`asset_management`.`portfolio`.`constraint`"
  filter: constraint_status = 'ACTIVE'
  dimensions:
    - name: "Constraint Type"
      display_name: "Constraint type"
      expr: constraint_type
      comment: "Type"
    - name: "Category"
      display_name: "Category"
      expr: constraint_category
      comment: "Category"
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
  measures:
    - name: "Constraints"
      display_name: "Constraints"
      expr: COUNT(1)
      comment: "Constraints"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Breach Count"
      display_name: "Total breach count"
      expr: SUM(CAST(breach_count AS DOUBLE))
      comment: "Breaches"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_currency_exposure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FX exposure and hedging semantic layer — net/gross exposure, hedge effectiveness, MTM, and policy breach monitoring. Core currency risk steering."
  source: "`asset_management`.`portfolio`.`currency_exposure`"
  dimensions:
    - name: "Foreign Currency"
      display_name: "Foreign Currency"
      expr: foreign_currency_code
      comment: "Foreign currency of the exposure."
    - name: "Base Currency"
      display_name: "Base Currency"
      expr: base_currency_code
      comment: "Base currency of the exposure."
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class_code
      comment: "Asset class associated with the exposure."
    - name: "Hedge Instrument Type"
      display_name: "Hedge Instrument Type"
      expr: hedge_instrument_type
      comment: "Instrument used to hedge the exposure."
    - name: "Geographic Region"
      display_name: "Geographic Region"
      expr: geographic_region
      comment: "Geographic region of the exposure."
    - name: "Valuation Month"
      display_name: "Valuation Month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Valuation date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Net Exposure"
      display_name: "Net Exposure"
      expr: SUM(CAST(net_exposure_amount AS DOUBLE))
      comment: "Net currency exposure after hedging — residual FX risk."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Gross Exposure"
      display_name: "Gross Exposure"
      expr: SUM(CAST(gross_exposure_amount AS DOUBLE))
      comment: "Gross currency exposure before hedging."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Hedged Notional"
      display_name: "Hedged Notional"
      expr: SUM(CAST(hedged_notional_amount AS DOUBLE))
      comment: "Notional amount hedged — hedge coverage."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "MTM Gain Loss"
      display_name: "MTM G/L"
      expr: SUM(CAST(mtm_gain_loss_amount AS DOUBLE))
      comment: "Mark-to-market gain/loss on hedges — P&L impact of the hedging program."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Hedge Effectiveness"
      display_name: "Avg Hedge Effectiveness %"
      expr: AVG(CAST(hedge_effectiveness_percent AS DOUBLE))
      comment: "Average hedge effectiveness — quality of the hedging program."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Hedge Cost Bps"
      display_name: "Avg Hedge Cost (bps)"
      expr: AVG(CAST(hedge_cost_bps AS DOUBLE))
      comment: "Average hedge cost in basis points — cost of currency risk management."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Policy Breach Rate"
      display_name: "FX Policy Breach %"
      expr: AVG(CASE WHEN policy_breach_flag = TRUE THEN 1.0 ELSE 0.0 END)
      comment: "Share of exposures breaching FX policy limits — risk control signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Stress Test Impact"
      display_name: "Stress Test Impact"
      expr: SUM(CAST(stress_test_impact_amount AS DOUBLE))
      comment: "Aggregate stress-test loss impact on FX exposure — tail-risk sizing (TCFD/scenario)."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_currency_hedge_effectiveness`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Currency exposure and hedge effectiveness/cost for the global multi-asset book."
  source: "`asset_management`.`portfolio`.`currency_exposure`"
  dimensions:
    - name: "Foreign Currency"
      display_name: "Foreign currency"
      expr: foreign_currency_code
      comment: "Foreign ccy"
    - name: "Region"
      display_name: "Region"
      expr: geographic_region
      comment: "Region"
    - name: "Hedge Instrument"
      display_name: "Hedge instrument"
      expr: hedge_instrument_type
      comment: "Instrument"
  measures:
    - name: "Gross Exposure"
      display_name: "Gross exposure"
      expr: SUM(CAST(gross_exposure_amount AS DOUBLE))
      comment: "Gross FX exposure"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Hedge Ratio %"
      display_name: "Avg hedge ratio %"
      expr: ROUND(AVG(CAST(hedge_ratio_percent AS DOUBLE)),2)
      comment: "Hedge ratio"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Hedge Effectiveness %"
      display_name: "Avg hedge effectiveness %"
      expr: ROUND(AVG(CAST(hedge_effectiveness_percent AS DOUBLE)),2)
      comment: "Effectiveness"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Hedge Cost bps"
      display_name: "Avg hedge cost bps"
      expr: ROUND(AVG(CAST(hedge_cost_bps AS DOUBLE)),2)
      comment: "Hedge cost"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_gav_vs_nav`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Gross asset value versus net asset value, indicating leverage/accrual drag at the fund level."
  source: "`asset_management`.`portfolio`.`portfolio_nav_record`"
  filter: approval_status = 'APPROVED'
  dimensions:
    - name: "Fiscal Year"
      display_name: "Fiscal year"
      expr: fiscal_year
      comment: "Fiscal year"
  measures:
    - name: "GAV to NAV %"
      display_name: "Gav to nav %"
      expr: ROUND(100.0 * SUM(CAST(gav_amount AS DOUBLE)) / NULLIF(SUM(CAST(nav_amount AS DOUBLE)),0),2)
      comment: "GAV divided by NAV"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Cash & Equivalents"
      display_name: "Total cash & equivalents"
      expr: SUM(CAST(cash_and_equivalents AS DOUBLE))
      comment: "Aggregate cash position"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_gips_composite_aum`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Assets under management grouped by GIPS composite for performance presentation standards."
  source: "`asset_management`.`portfolio`.`gips_composite`"
  filter: composite_status = 'ACTIVE'
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
    - name: "Geographic Focus"
      display_name: "Geographic focus"
      expr: geographic_focus
      comment: "Geography"
    - name: "Composite Type"
      display_name: "Composite type"
      expr: composite_type
      comment: "Type"
  measures:
    - name: "Composite AUM"
      display_name: "Composite aum"
      expr: SUM(CAST(composite_aum AS DOUBLE))
      comment: "Composite AUM"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Composite Count"
      display_name: "Composite count"
      expr: COUNT(1)
      comment: "Composites"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_hierarchy_rebalance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Composite/sleeve hierarchy structure and rebalancing cadence governance."
  source: "`asset_management`.`portfolio`.`hierarchy`"
  filter: is_active = TRUE
  dimensions:
    - name: "Hierarchy Type"
      display_name: "Hierarchy type"
      expr: hierarchy_type
      comment: "Type"
    - name: "Allocation Method"
      display_name: "Allocation method"
      expr: allocation_method
      comment: "Method"
    - name: "Rebalancing Frequency"
      display_name: "Rebalancing frequency"
      expr: rebalancing_frequency
      comment: "Frequency"
  measures:
    - name: "Nodes"
      display_name: "Nodes"
      expr: COUNT(1)
      comment: "Hierarchy nodes"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Allocation Weight"
      display_name: "Avg allocation weight"
      expr: ROUND(AVG(CAST(allocation_weight AS DOUBLE)),2)
      comment: "Weight"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_holding`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Position-level holdings semantic layer — market value exposure, unrealized P&L, ESG and restriction coverage. Drives exposure monitoring and risk steering."
  source: "`asset_management`.`portfolio`.`holding`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Primary asset class of the holding."
    - name: "Sub Asset Class"
      display_name: "Sub Asset Class"
      expr: sub_asset_class
      comment: "Sub asset class classification."
    - name: "Base Currency"
      display_name: "Base Currency"
      expr: base_currency_code
      comment: "Reporting base currency."
    - name: "ESG Rating"
      display_name: "ESG Rating"
      expr: esg_rating
      comment: "ESG rating band for the holding (SFDR relevant)."
    - name: "Liquidity Classification"
      display_name: "Liquidity Classification"
      expr: liquidity_classification
      comment: "Liquidity tier of the holding."
    - name: "Holding Status"
      display_name: "Holding Status"
      expr: holding_status
      comment: "Lifecycle status of the holding."
    - name: "Position Month"
      display_name: "Position Month"
      expr: DATE_TRUNC('month', position_date)
      comment: "Position date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Market Value Base"
      display_name: "Market Value (Base)"
      expr: SUM(CAST(market_value_base AS DOUBLE))
      comment: "Total market value in base currency — core exposure measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Cost Base"
      display_name: "Cost (Base)"
      expr: SUM(CAST(cost_base AS DOUBLE))
      comment: "Total cost basis in base currency."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Unrealized Gain Loss Base"
      display_name: "Unrealized G/L (Base)"
      expr: SUM(CAST(unrealized_gain_loss_base AS DOUBLE))
      comment: "Aggregate unrealized gain/loss in base currency — mark-to-market performance signal."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Accrued Income Base"
      display_name: "Accrued Income (Base)"
      expr: SUM(CAST(accrued_income_base AS DOUBLE))
      comment: "Accrued income in base currency — income yield component."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Unfunded Commitment"
      display_name: "Unfunded Commitment"
      expr: SUM(CAST(unfunded_commitment AS DOUBLE))
      comment: "Position-level unfunded commitment — liquidity obligation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Distinct Positions"
      display_name: "Positions"
      expr: COUNT(DISTINCT holding_id)
      comment: "Number of distinct positions — concentration/diversification indicator."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Restricted Holding Rate"
      display_name: "Restricted Holdings %"
      expr: AVG(CASE WHEN restricted_flag = TRUE THEN 1.0 ELSE 0.0 END)
      comment: "Share of holdings under trading restriction — compliance and liquidity constraint signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Excluded Holding Rate"
      display_name: "Excluded Holdings %"
      expr: AVG(CASE WHEN exclusion_flag = TRUE THEN 1.0 ELSE 0.0 END)
      comment: "Share of holdings on the exclusion list — ESG/responsible-investment adherence (SFDR)."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_holding_carbon_intensity`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Weighted-average carbon intensity of holdings for TCFD climate reporting."
  source: "`asset_management`.`portfolio`.`holding_snapshot`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
    - name: "Country of Risk"
      display_name: "Country of risk"
      expr: country_of_risk
      comment: "Country"
    - name: "Credit Rating"
      display_name: "Credit rating"
      expr: credit_rating
      comment: "Credit rating"
  measures:
    - name: "Avg Carbon Intensity"
      display_name: "Avg carbon intensity"
      expr: ROUND(AVG(CAST(carbon_intensity AS DOUBLE)),2)
      comment: "Average carbon intensity"
    - name: "Avg Duration (yrs)"
      display_name: "Avg duration (yrs)"
      expr: ROUND(AVG(CAST(duration_years AS DOUBLE)),2)
      comment: "Average duration"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_holding_exclusion_screening`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Share of holdings flagged under ESG exclusion policy for SFDR disclosure."
  source: "`asset_management`.`portfolio`.`holding`"
  filter: holding_status = 'ACTIVE'
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
    - name: "ESG Rating"
      display_name: "Esg rating"
      expr: esg_rating
      comment: "ESG"
  measures:
    - name: "Holdings"
      display_name: "Holdings"
      expr: COUNT(1)
      comment: "Holdings"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Excluded %"
      display_name: "Excluded %"
      expr: ROUND(100.0 * SUM(CASE WHEN exclusion_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Excluded share"
    - name: "Collateral-Pledged %"
      display_name: "Collateral-pledged %"
      expr: ROUND(100.0 * SUM(CASE WHEN collateral_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Pledged share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_holding_market_value`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Investment book of record market value and unrealized gain by asset class and currency."
  source: "`asset_management`.`portfolio`.`holding`"
  filter: holding_status = 'ACTIVE'
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
    - name: "Currency"
      display_name: "Currency"
      expr: base_currency_code
      comment: "Base currency"
    - name: "ESG Rating"
      display_name: "Esg rating"
      expr: esg_rating
      comment: "ESG rating"
  measures:
    - name: "Total Cost Base"
      display_name: "Total cost base"
      expr: SUM(CAST(cost_base AS DOUBLE))
      comment: "Cost base"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Excluded Holdings"
      display_name: "Excluded holdings"
      expr: SUM(CASE WHEN exclusion_flag = TRUE THEN 1 ELSE 0 END)
      comment: "ESG-excluded holdings"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Holding Count"
      display_name: "Holding count"
      expr: COUNT(1)
      comment: "Number of holdings"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_holding_snapshot_rating_mix`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Credit rating distribution of fixed-income holdings for quality monitoring."
  source: "`asset_management`.`portfolio`.`holding_snapshot`"
  dimensions:
    - name: "Credit Rating"
      display_name: "Credit rating"
      expr: credit_rating
      comment: "Rating"
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
    - name: "Country of Risk"
      display_name: "Country of risk"
      expr: country_of_risk
      comment: "Country"
  measures:
    - name: "Holdings"
      display_name: "Holdings"
      expr: COUNT(1)
      comment: "Holdings"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Coupon Rate"
      display_name: "Avg coupon rate"
      expr: ROUND(AVG(CAST(coupon_rate AS DOUBLE)),2)
      comment: "Coupon"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg ESG Rating Count"
      display_name: "Avg esg rating count"
      expr: COUNT(esg_rating)
      comment: "ESG-rated holdings"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_ic_approval_throughput`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Volume and value of IC decisions and approval mix for governance oversight."
  source: "`asset_management`.`portfolio`.`portfolio_ic_approval`"
  dimensions:
    - name: "Approval Type"
      display_name: "Approval type"
      expr: approval_type
      comment: "Type"
    - name: "Decision Status"
      display_name: "Decision status"
      expr: decision_status
      comment: "Status"
  measures:
    - name: "Decisions"
      display_name: "Decisions"
      expr: COUNT(1)
      comment: "IC decisions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approved %"
      display_name: "Approved %"
      expr: ROUND(100.0 * SUM(CASE WHEN decision_status = 'APPROVED' THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Approval rate"
    - name: "Total Commitment Approved"
      display_name: "Total commitment approved"
      expr: SUM(CAST(capital_commitment_amount AS DOUBLE))
      comment: "Committed capital approved"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_liquidity_bucket`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Liquidity profile semantic layer — tiered liquidity, HQLA eligibility, haircuts and liquidation costs. Supports liquidity risk and stress steering."
  source: "`asset_management`.`portfolio`.`liquidity_bucket`"
  dimensions:
    - name: "Liquidity Tier"
      display_name: "Liquidity Tier"
      expr: liquidity_tier
      comment: "Liquidity tier classification."
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the holdings in the bucket."
    - name: "Instrument Type"
      display_name: "Instrument Type"
      expr: instrument_type
      comment: "Instrument type within the liquidity bucket."
    - name: "HQLA Category"
      display_name: "HQLA Category"
      expr: hqla_category
      comment: "High-quality-liquid-asset category."
    - name: "Stress Scenario Tier"
      display_name: "Stress Scenario Tier"
      expr: stress_scenario_tier
      comment: "Liquidity tier under stress scenario."
    - name: "Classification Month"
      display_name: "Classification Month"
      expr: DATE_TRUNC('month', classification_date)
      comment: "Classification date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Bucket Market Value"
      display_name: "Market Value (Base)"
      expr: SUM(CAST(market_value_base_currency AS DOUBLE))
      comment: "Market value within the liquidity bucket — liquidity-weighted exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Estimated Liquidation Days"
      display_name: "Avg Liquidation Days"
      expr: AVG(CAST(estimated_liquidation_days AS DOUBLE))
      comment: "Average days to liquidate positions — time-to-cash risk."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Haircut Pct"
      display_name: "Avg Haircut %"
      expr: AVG(CAST(haircut_percent AS DOUBLE))
      comment: "Average haircut applied — stress-value discount."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Liquidation Cost Pct"
      display_name: "Avg Liquidation Cost %"
      expr: AVG(CAST(liquidation_cost_percent AS DOUBLE))
      comment: "Average cost to liquidate positions — slippage/transaction drag."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Bid Ask Spread Bps"
      display_name: "Avg Bid-Ask Spread (bps)"
      expr: AVG(CAST(bid_ask_spread_bps AS DOUBLE))
      comment: "Average bid-ask spread in basis points — market-liquidity depth indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "HQLA Eligible Rate"
      display_name: "HQLA Eligible %"
      expr: AVG(CASE WHEN hqla_eligible_flag = TRUE THEN 1.0 ELSE 0.0 END)
      comment: "Share of holdings that are HQLA-eligible — regulatory liquidity buffer quality."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_liquidity_coverage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Distribution of holdings across liquidity tiers and HQLA eligibility for liquidity risk management."
  source: "`asset_management`.`portfolio`.`liquidity_bucket`"
  dimensions:
    - name: "Liquidity Tier"
      display_name: "Liquidity tier"
      expr: liquidity_tier
      comment: "Tier"
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
    - name: "HQLA Category"
      display_name: "Hqla category"
      expr: hqla_category
      comment: "HQLA bucket"
  measures:
    - name: "Avg Bucket Weight %"
      display_name: "Avg bucket weight %"
      expr: ROUND(AVG(CAST(bucket_weight_percent AS DOUBLE)),2)
      comment: "Bucket weight"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "HQLA Eligible %"
      display_name: "Hqla eligible %"
      expr: ROUND(100.0 * SUM(CASE WHEN hqla_eligible_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Share HQLA eligible"
    - name: "Avg Liquidation Days"
      display_name: "Avg liquidation days"
      expr: ROUND(AVG(CAST(estimated_liquidation_days AS DOUBLE)),2)
      comment: "Days to liquidate"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_liquidity_haircut_cost`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Average liquidation haircut and cost by tier, a stress-liquidity planning KPI."
  source: "`asset_management`.`portfolio`.`liquidity_bucket`"
  dimensions:
    - name: "Liquidity Tier"
      display_name: "Liquidity tier"
      expr: liquidity_tier
      comment: "Tier"
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
  measures:
    - name: "Avg Haircut %"
      display_name: "Avg haircut %"
      expr: ROUND(AVG(CAST(haircut_percent AS DOUBLE)),2)
      comment: "Haircut"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Liquidation Cost %"
      display_name: "Avg liquidation cost %"
      expr: ROUND(AVG(CAST(liquidation_cost_percent AS DOUBLE)),2)
      comment: "Liquidation cost"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Bid-Ask Spread bps"
      display_name: "Avg bid-ask spread bps"
      expr: ROUND(AVG(CAST(bid_ask_spread_bps AS DOUBLE)),2)
      comment: "Spread"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_mandate_change_history`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Volume and type of mandate parameter changes with IC approval traceability."
  source: "`asset_management`.`portfolio`.`mandate_history`"
  dimensions:
    - name: "Change Type"
      display_name: "Change type"
      expr: change_type
      comment: "Type"
    - name: "Change Status"
      display_name: "Change status"
      expr: change_status
      comment: "Status"
    - name: "Reason"
      display_name: "Reason"
      expr: change_reason
      comment: "Reason"
  measures:
    - name: "Changes"
      display_name: "Changes"
      expr: COUNT(1)
      comment: "Changes"
      format:
        type: number
        decimal_places:
          type: all
    - name: "IC Approved %"
      display_name: "Ic approved %"
      expr: ROUND(100.0 * SUM(CASE WHEN ic_approval_reference IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "IC-approved"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_mandate_fees`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Mandate concentration limits and hurdle rates across the external/internal mandate book."
  source: "`asset_management`.`portfolio`.`portfolio_mandate`"
  dimensions:
    - name: "Currency"
      display_name: "Currency"
      expr: base_currency
      comment: "Currency"
    - name: "ESG Level"
      display_name: "Esg level"
      expr: esg_integration_level
      comment: "ESG level"
  measures:
    - name: "Mandates"
      display_name: "Mandates"
      expr: COUNT(1)
      comment: "Mandates"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Concentration Limit %"
      display_name: "Avg concentration limit %"
      expr: ROUND(AVG(CAST(concentration_limit_percent AS DOUBLE)),2)
      comment: "Concentration limit"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Hurdle Rate %"
      display_name: "Avg hurdle rate %"
      expr: ROUND(AVG(CAST(hurdle_rate_percent AS DOUBLE)),2)
      comment: "Hurdle rate"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_mgmt_fee_accrual`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Accrued management fees as a cost driver on the fund P&L."
  source: "`asset_management`.`portfolio`.`portfolio_nav_record`"
  dimensions:
    - name: "Fiscal Year"
      display_name: "Fiscal year"
      expr: fiscal_year
      comment: "Fiscal year"
  measures:
    - name: "Total Mgmt Fee Accrual"
      display_name: "Total mgmt fee accrual"
      expr: SUM(CAST(management_fee_accrual AS DOUBLE))
      comment: "Sum of management fee accruals"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Fee Drag bps"
      display_name: "Fee drag bps"
      expr: ROUND(10000.0 * SUM(CAST(management_fee_accrual AS DOUBLE)) / NULLIF(SUM(CAST(nav_amount AS DOUBLE)),0),2)
      comment: "Fee accrual over NAV in bps"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_nav_change_pct`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Period-over-period NAV change percentage as the headline growth driver."
  source: "`asset_management`.`portfolio`.`portfolio_nav_record`"
  dimensions:
    - name: "Fiscal Year"
      display_name: "Fiscal year"
      expr: fiscal_year
      comment: "Fiscal year"
    - name: "Calculation Method"
      display_name: "Calculation method"
      expr: calculation_method
      comment: "NAV calc method"
  measures:
    - name: "Avg NAV Change %"
      display_name: "Avg nav change %"
      expr: ROUND(AVG(CAST(nav_change_percentage AS DOUBLE)),2)
      comment: "Average NAV change percent"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total NAV Change"
      display_name: "Total nav change"
      expr: SUM(CAST(nav_change_amount AS DOUBLE))
      comment: "Sum of NAV change amounts"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_nav_fx_impact`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Foreign-exchange impact on portfolio NAV, isolating currency translation effects."
  source: "`asset_management`.`portfolio`.`portfolio_nav_record`"
  dimensions:
    - name: "Fiscal Year"
      display_name: "Fiscal year"
      expr: fiscal_year
      comment: "Year"
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Total FX Impact"
      display_name: "Total fx impact"
      expr: SUM(CAST(fx_impact AS DOUBLE))
      comment: "FX impact"
      format:
        type: number
        decimal_places:
          type: all
    - name: "FX Impact % of NAV"
      display_name: "Fx impact % of nav"
      expr: ROUND(100.0 * SUM(CAST(fx_impact AS DOUBLE)) / NULLIF(SUM(CAST(nav_amount AS DOUBLE)),0),2)
      comment: "FX over NAV"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_nav_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "NAV / AUM semantic layer over portfolio NAV records — supports IFRS financial statements, NAV growth tracking, and AUM steering. Semi-additive balances (NAV is a point-in-time stock, never summed across time)."
  source: "`asset_management`.`portfolio`.`portfolio_nav_record`"
  dimensions:
    - name: "Reporting Period"
      display_name: "Reporting Period"
      expr: reporting_period
      comment: "Reporting period label for the NAV strike."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Reporting currency of the NAV record."
    - name: "NAV Status"
      display_name: "NAV Status"
      expr: nav_status
      comment: "Lifecycle status of the NAV (e.g. draft/final)."
    - name: "Reconciliation Status"
      display_name: "Reconciliation Status"
      expr: reconciliation_status
      comment: "Whether the NAV has been reconciled to custodian/administrator."
    - name: "Valuation Day"
      display_name: "Valuation Day"
      expr: DATE_TRUNC('day', valuation_date)
      comment: "NAV valuation date bucketed to day."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Valuation Month"
      display_name: "Valuation Month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "NAV valuation date bucketed to month for time-intelligence."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Valuation Year"
      display_name: "Valuation Year"
      expr: DATE_TRUNC('year', valuation_date)
      comment: "NAV valuation date bucketed to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Closing NAV"
      display_name: "Closing NAV"
      expr: SUM(CAST(nav_amount AS DOUBLE))
      comment: "Closing net asset value (semi-additive: take the last value in the period, never summed across dates)."
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
    - name: "Closing NAV PM"
      display_name: "Closing NAV (Prior Month)"
      expr: SUM(CAST(nav_amount AS DOUBLE))
      comment: "Prior-month closing NAV for month-over-month comparison."
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
          offset: -1 month
    - name: "NAV MoM Growth"
      display_name: "NAV MoM Growth %"
      expr: (AGG(`Closing NAV`) - AGG(`Closing NAV PM`)) / NULLIF(AGG(`Closing NAV PM`), 0)
      comment: "Month-over-month NAV growth rate — headline AUM trajectory for the board."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Gross Asset Value"
      display_name: "Gross Asset Value"
      expr: SUM(CAST(gav_amount AS DOUBLE))
      comment: "Gross asset value before liabilities — gross exposure of the book."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Net Contributions"
      display_name: "Contributions"
      expr: SUM(CAST(contributions AS DOUBLE))
      comment: "Capital contributions into portfolios in the period — drives funding of pension liabilities."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Distributions"
      display_name: "Distributions"
      expr: SUM(CAST(distributions AS DOUBLE))
      comment: "Capital distributed out of portfolios in the period."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Unfunded Commitments"
      display_name: "Unfunded Commitments"
      expr: SUM(CAST(unfunded_commitments AS DOUBLE))
      comment: "Outstanding capital commitments not yet called — key liquidity planning metric for private markets."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg NAV Change Pct"
      display_name: "Avg NAV Change %"
      expr: AVG(CAST(nav_change_percentage AS DOUBLE))
      comment: "Average period NAV change percentage across records — performance pulse."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Reconciled NAV Rate"
      display_name: "Reconciled NAV %"
      expr: AVG(CASE WHEN reconciliation_status = 'RECONCILED' THEN 1.0 ELSE 0.0 END)
      comment: "Share of NAV records fully reconciled — operational data-quality control for IFRS reporting."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_net_capital_flows`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Contributions less distributions at portfolio level, a core liquidity and funding driver."
  source: "`asset_management`.`portfolio`.`portfolio_nav_record`"
  dimensions:
    - name: "Fiscal Year"
      display_name: "Fiscal year"
      expr: fiscal_year
      comment: "Fiscal year"
    - name: "Fiscal Quarter"
      display_name: "Fiscal quarter"
      expr: fiscal_quarter
      comment: "Fiscal quarter"
  measures:
    - name: "Net Flows"
      display_name: "Net flows"
      expr: SUM((CAST(contributions AS DOUBLE)) - (CAST(distributions AS DOUBLE)))
      comment: "Contributions minus distributions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Contributions"
      display_name: "Total contributions"
      expr: SUM(CAST(contributions AS DOUBLE))
      comment: "Contributions in"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Distributions"
      display_name: "Total distributions"
      expr: SUM(CAST(distributions AS DOUBLE))
      comment: "Distributions out"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_net_funding_position`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Net contributions less capital calls and distributions by asset class, a deployment-pacing KPI."
  source: "`asset_management`.`portfolio`.`portfolio_cash_flow`"
  filter: approval_status = 'APPROVED'
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
    - name: "Accounting Period"
      display_name: "Accounting period"
      expr: accounting_period
      comment: "Period"
  measures:
    - name: "Net Position"
      display_name: "Net position"
      expr: SUM(CASE WHEN flow_direction = 'INFLOW' THEN amount ELSE -amount END)
      comment: "Net flow"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Inflow"
      display_name: "Inflow"
      expr: SUM(CASE WHEN flow_direction = 'INFLOW' THEN amount ELSE 0 END)
      comment: "Inflows"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Outflow"
      display_name: "Outflow"
      expr: SUM(CASE WHEN flow_direction = 'OUTFLOW' THEN amount ELSE 0 END)
      comment: "Outflows"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_rebalancing_carbon_reduction`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Carbon footprint reduction achieved through rebalancing, a decarbonization progress KPI."
  source: "`asset_management`.`portfolio`.`rebalancing_event`"
  dimensions:
    - name: "Event Status"
      display_name: "Event status"
      expr: event_status
      comment: "Status"
    - name: "ESG Assessed"
      display_name: "Esg assessed"
      expr: esg_impact_assessed
      comment: "ESG assessed"
  measures:
    - name: "Avg Carbon Reduction"
      display_name: "Avg carbon reduction"
      expr: ROUND(AVG(CAST(carbon_footprint_pre AS DOUBLE) - CAST(carbon_footprint_post AS DOUBLE)),2)
      comment: "Carbon reduction"
    - name: "Events"
      display_name: "Events"
      expr: COUNT(1)
      comment: "Events"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_rebalancing_drift`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Average portfolio drift that triggered rebalancing and estimated market/tax impact."
  source: "`asset_management`.`portfolio`.`rebalancing_event`"
  dimensions:
    - name: "Event Status"
      display_name: "Event status"
      expr: event_status
      comment: "Status"
    - name: "Execution Strategy"
      display_name: "Execution strategy"
      expr: execution_strategy
      comment: "Strategy"
    - name: "Threshold Breached"
      display_name: "Threshold breached"
      expr: drift_threshold_breached
      comment: "Drift breach flag"
  measures:
    - name: "Avg Drift %"
      display_name: "Avg drift %"
      expr: ROUND(AVG(CAST(drift_percentage AS DOUBLE)),2)
      comment: "Average drift"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Est Market Impact"
      display_name: "Total est market impact"
      expr: SUM(CAST(estimated_market_impact AS DOUBLE))
      comment: "Market impact cost"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Est Tax Impact"
      display_name: "Total est tax impact"
      expr: SUM(CAST(estimated_tax_impact AS DOUBLE))
      comment: "Tax impact"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg ESG Score Change"
      display_name: "Avg esg score change"
      expr: ROUND(AVG(CAST(esg_score_post AS DOUBLE) - CAST(esg_score_pre AS DOUBLE)),2)
      comment: "ESG score delta"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_rebalancing_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Rebalancing event semantic layer — transaction cost, tax/market impact, VaR and ESG shift pre/post rebalance. Supports execution and ESG steering."
  source: "`asset_management`.`portfolio`.`rebalancing_event`"
  dimensions:
    - name: "Event Status"
      display_name: "Event Status"
      expr: event_status
      comment: "Lifecycle status of the rebalancing event."
    - name: "Trigger Type"
      display_name: "Trigger Type"
      expr: trigger_type
      comment: "What triggered the rebalance (scheduled/drift/mandate)."
    - name: "Execution Strategy"
      display_name: "Execution Strategy"
      expr: execution_strategy
      comment: "Execution strategy applied."
    - name: "Base Currency"
      display_name: "Base Currency"
      expr: base_currency
      comment: "Base currency of the rebalancing event."
    - name: "Event Month"
      display_name: "Event Month"
      expr: DATE_TRUNC('month', event_timestamp)
      comment: "Event timestamp bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Rebalancing Events"
      display_name: "Rebalancing Events"
      expr: COUNT(DISTINCT rebalancing_event_id)
      comment: "Number of distinct rebalancing events executed."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Transaction Cost"
      display_name: "Transaction Cost"
      expr: SUM(CAST(total_transaction_cost AS DOUBLE))
      comment: "Aggregate transaction cost of rebalancing — direct cost of implementation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Transaction Cost Bps"
      display_name: "Avg Transaction Cost (bps)"
      expr: AVG(CAST(transaction_cost_bps AS DOUBLE))
      comment: "Average transaction cost in basis points — execution efficiency."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Estimated Tax Impact"
      display_name: "Estimated Tax Impact"
      expr: SUM(CAST(estimated_tax_impact AS DOUBLE))
      comment: "Aggregate estimated tax impact of rebalancing decisions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Drift Percentage"
      display_name: "Avg Drift %"
      expr: AVG(CAST(drift_percentage AS DOUBLE))
      comment: "Average portfolio drift at rebalance trigger — allocation discipline."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Avg ESG Score Post"
      display_name: "Avg ESG Score (Post)"
      expr: AVG(CAST(esg_score_post AS DOUBLE))
      comment: "Average post-rebalance ESG score — ESG integration outcome."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg ESG Score Pre"
      display_name: "Avg ESG Score (Pre)"
      expr: AVG(CAST(esg_score_pre AS DOUBLE))
      comment: "Average pre-rebalance ESG score — baseline for ESG improvement."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "ESG Improvement Post Rebalance"
      display_name: "ESG Score Improvement"
      expr: AGG(`Avg ESG Score Post`) - AGG(`Avg ESG Score Pre`)
      comment: "Change in ESG score achieved through rebalancing — demonstrable ESG value add."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Drift Threshold Breach Rate"
      display_name: "Drift Threshold Breach %"
      expr: AVG(CASE WHEN drift_threshold_breached = TRUE THEN 1.0 ELSE 0.0 END)
      comment: "Share of events where the drift threshold was breached — discipline/control signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_saa_actual_vs_target`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic asset allocation adherence: actual weight deviation from policy target by asset class."
  source: "`asset_management`.`portfolio`.`saa_target`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class_name
      comment: "Asset class"
    - name: "Liquidity Class"
      display_name: "Liquidity class"
      expr: liquidity_classification
      comment: "Liquidity classification"
  measures:
    - name: "Avg Actual Weight %"
      display_name: "Avg actual weight %"
      expr: ROUND(AVG(CAST(actual_weight_percent AS DOUBLE)),2)
      comment: "Average actual weight"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Expected Return %"
      display_name: "Avg expected return %"
      expr: ROUND(AVG(CAST(expected_return_percent AS DOUBLE)),2)
      comment: "Expected return assumption"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Expected Vol %"
      display_name: "Avg expected vol %"
      expr: ROUND(AVG(CAST(expected_volatility_percent AS DOUBLE)),2)
      comment: "Expected volatility"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_sleeve_allocation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Actual allocation amount and weight across sleeves for mandate-level monitoring."
  source: "`asset_management`.`portfolio`.`sleeve`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class_code
      comment: "Asset class"
    - name: "Currency"
      display_name: "Currency"
      expr: base_currency_code
      comment: "Currency"
    - name: "ESG Flag"
      display_name: "Esg flag"
      expr: esg_integration_flag
      comment: "ESG integration"
  measures:
    - name: "Actual Allocation"
      display_name: "Actual allocation"
      expr: SUM(CAST(actual_allocation_amount AS DOUBLE))
      comment: "Allocation amount"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Allocation Weight %"
      display_name: "Avg allocation weight %"
      expr: ROUND(AVG(CAST(actual_allocation_weight_percent AS DOUBLE)),2)
      comment: "Allocation weight"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "GIPS Compliant %"
      display_name: "Gips compliant %"
      expr: ROUND(100.0 * SUM(CASE WHEN gips_compliant_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "GIPS compliant share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_taa_active_deviation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Tactical over/underweight versus SAA, indicating active positioning and rebalancing need."
  source: "`asset_management`.`portfolio`.`taa_position`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class_name
      comment: "Asset class"
    - name: "Approval Status"
      display_name: "Approval status"
      expr: approval_status
      comment: "Approval status"
    - name: "Rebalance Required"
      display_name: "Rebalance required"
      expr: rebalancing_required_flag
      comment: "Rebalance flag"
  measures:
    - name: "Avg Deviation %"
      display_name: "Avg deviation %"
      expr: ROUND(AVG(CAST(actual_deviation_percent AS DOUBLE)),2)
      comment: "Average deviation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Positions Needing Rebalance"
      display_name: "Positions needing rebalance"
      expr: SUM(CASE WHEN rebalancing_required_flag = TRUE THEN 1 ELSE 0 END)
      comment: "Count flagged"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Risk Budget %"
      display_name: "Avg risk budget %"
      expr: ROUND(AVG(CAST(risk_budget_percent AS DOUBLE)),2)
      comment: "Risk budget"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_taa_rebalancing_threshold`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Positions nearing upper/lower rebalancing thresholds, an early-warning drill-down."
  source: "`asset_management`.`portfolio`.`taa_position`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class_name
      comment: "Asset class"
  measures:
    - name: "Avg Upper Threshold %"
      display_name: "Avg upper threshold %"
      expr: ROUND(AVG(CAST(rebalancing_threshold_upper_percent AS DOUBLE)),2)
      comment: "Upper threshold"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Lower Threshold %"
      display_name: "Avg lower threshold %"
      expr: ROUND(AVG(CAST(rebalancing_threshold_lower_percent AS DOUBLE)),2)
      comment: "Lower threshold"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Actual Weight %"
      display_name: "Avg actual weight %"
      expr: ROUND(AVG(CAST(actual_weight_percent AS DOUBLE)),2)
      comment: "Actual weight"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_tax_lot_unrealized`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Adjusted cost basis and income received by asset class for tax-aware portfolio management."
  source: "`asset_management`.`portfolio`.`tax_lot`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class"
    - name: "Cost Basis Method"
      display_name: "Cost basis method"
      expr: cost_basis_method
      comment: "Method"
    - name: "Holding Period Type"
      display_name: "Holding period type"
      expr: holding_period_type
      comment: "Short/long"
  measures:
    - name: "Adjusted Cost Basis"
      display_name: "Adjusted cost basis"
      expr: SUM(CAST(adjusted_cost_basis AS DOUBLE))
      comment: "Cost basis"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Income Received"
      display_name: "Income received"
      expr: SUM(CAST(income_received AS DOUBLE))
      comment: "Income"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Holding Days"
      display_name: "Avg holding days"
      expr: ROUND(AVG(CAST(holding_period_days AS DOUBLE)),2)
      comment: "Holding period"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`portfolio_total_portfolio_nav`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FALLBACK: original MV failed install, replaced with minimal row-count view"
  source: "`asset_management`.`portfolio`.`portfolio_nav_record`"
  dimensions:
    - name: All Records
      expr: "1"
  measures:
    - name: Row Count
      expr: COUNT(1)
$$;
