-- Metric views for domain: actuarial | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`actuarial_alm_model_scenarios`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Asset-liability modeling scenario coverage including climate and economic stress."
  source: "`asset_management`.`actuarial`.`alm_scenario`"
  dimensions:
    - name: "Scenario Type"
      display_name: "Scenario type"
      expr: scenario_type
      comment: "Type"
  measures:
    - name: "Scenarios"
      display_name: "Scenarios"
      expr: COUNT(1)
      comment: "Scenarios"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`actuarial_alm_scenario`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Asset-liability management scenario results: funded ratio outcomes, surplus/deficit, VaR/CVaR and duration gaps for stress testing and SAA decision support."
  source: "`asset_management`.`actuarial`.`alm_scenario`"
  dimensions:
    - name: "scenario_type"
      display_name: "Scenario Type"
      expr: scenario_type
      comment: "Type of ALM scenario (e.g. baseline, stress)."
    - name: "scenario_status"
      display_name: "Scenario Status"
      expr: scenario_status
      comment: "Status of the scenario run."
    - name: "regulatory_framework"
      display_name: "Regulatory Framework"
      expr: regulatory_framework
      comment: "Regulatory framework governing the scenario."
    - name: "base_currency_code"
      display_name: "Base Currency"
      expr: base_currency_code
      comment: "Base currency of the scenario."
    - name: "run_year"
      display_name: "Run Year"
      expr: DATE_TRUNC('year', run_date)
      comment: "Scenario run date bucketed to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "scenario_count"
      display_name: "Scenario Count"
      expr: COUNT(1)
      comment: "Number of ALM scenario runs."
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_funded_ratio_result"
      display_name: "Avg Funded Ratio Result"
      expr: AVG(CAST(funded_ratio_result_percent AS DOUBLE))
      comment: "Average resulting funded ratio across scenarios."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "total_surplus_deficit"
      display_name: "Total Surplus/Deficit"
      expr: SUM(CAST(surplus_deficit_amount AS DOUBLE))
      comment: "Aggregate scenario surplus/deficit outcome."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_var_95"
      display_name: "Avg VaR 95%"
      expr: AVG(CAST(var_95_amount AS DOUBLE))
      comment: "Average 95% Value-at-Risk across scenarios; downside risk measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_cvar_95"
      display_name: "Avg CVaR 95%"
      expr: AVG(CAST(cvar_95_amount AS DOUBLE))
      comment: "Average 95% Conditional VaR (expected shortfall) across scenarios."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_duration_gap_years"
      display_name: "Avg Duration Gap (yrs)"
      expr: AVG(CAST(duration_gap_years AS DOUBLE))
      comment: "Average asset-liability duration gap; measures interest-rate mismatch."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "worst_case_surplus_deficit"
      display_name: "Worst-Case Surplus/Deficit"
      expr: MIN(CAST(surplus_deficit_amount AS DOUBLE))
      comment: "Worst (most negative) surplus/deficit outcome across scenarios."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`actuarial_contribution_rate_model`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Modeled required contribution rates to maintain funding targets."
  source: "`asset_management`.`actuarial`.`contribution_rate_model`"
  dimensions:
    - name: "All Records"
      expr: "1"
  measures:
    - name: "Models"
      display_name: "Models"
      expr: COUNT(1)
      comment: "Models"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`actuarial_de_risking_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "De-risking trigger breach events and hedge-ratio responses, used to monitor glidepath execution and governance action on funded-ratio thresholds."
  source: "`asset_management`.`actuarial`.`de_risking_event`"
  dimensions:
    - name: "de_risking_event_status"
      display_name: "Event Status"
      expr: de_risking_event_status
      comment: "Status of the de-risking event."
    - name: "action_status"
      display_name: "Action Status"
      expr: action_status
      comment: "Status of the mandated de-risking action."
    - name: "trigger_type"
      display_name: "Trigger Type"
      expr: trigger_type
      comment: "Type of de-risking trigger that fired."
    - name: "currency_code"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency context of the event."
    - name: "breach_month"
      display_name: "Breach Month"
      expr: DATE_TRUNC('month', breach_timestamp)
      comment: "Breach timestamp bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "event_count"
      display_name: "Event Count"
      expr: COUNT(1)
      comment: "Number of de-risking breach events."
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_funded_ratio_at_breach"
      display_name: "Avg Funded Ratio at Breach"
      expr: AVG(CAST(funded_ratio_at_breach AS DOUBLE))
      comment: "Average funded ratio at the moment of trigger breach."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_hedge_ratio_before"
      display_name: "Avg Hedge Ratio Before"
      expr: AVG(CAST(hedge_ratio_before AS DOUBLE))
      comment: "Average hedge ratio before the de-risking action."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_hedge_ratio_after"
      display_name: "Avg Hedge Ratio After"
      expr: AVG(CAST(hedge_ratio_after AS DOUBLE))
      comment: "Average hedge ratio after the de-risking action."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_hedge_ratio_increase"
      display_name: "Avg Hedge Ratio Increase"
      expr: AGG(`avg_hedge_ratio_after`) - AGG(`avg_hedge_ratio_before`)
      comment: "Average increase in hedge ratio driven by de-risking actions (after minus before)."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_trigger_threshold"
      display_name: "Avg Trigger Threshold"
      expr: AVG(CAST(trigger_threshold AS DOUBLE))
      comment: "Average funded-ratio threshold configured on fired triggers."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`actuarial_de_risking_events`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Triggered de-risking events shifting the plan toward liability-matching assets."
  source: "`asset_management`.`actuarial`.`de_risking_event`"
  dimensions:
    - name: "All Records"
      expr: "1"
  measures:
    - name: "Events"
      display_name: "Events"
      expr: COUNT(1)
      comment: "Events"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`actuarial_experience_study_findings`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Mortality and demographic experience study outcomes informing assumption updates."
  source: "`asset_management`.`actuarial`.`experience_study`"
  dimensions:
    - name: "Study Type"
      display_name: "Study type"
      expr: study_type
      comment: "Type"
  measures:
    - name: "Studies"
      display_name: "Studies"
      expr: COUNT(1)
      comment: "Studies"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`actuarial_funded_status`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Point-in-time funded status measurements: funded ratio, asset/liability balances and asset-to-liability coverage for ongoing monitoring against de-risking triggers."
  source: "`asset_management`.`actuarial`.`funded_status`"
  dimensions:
    - name: "measurement_status"
      display_name: "Measurement Status"
      expr: measurement_status
      comment: "Status of the funded status measurement."
    - name: "scenario"
      display_name: "Scenario"
      expr: scenario
      comment: "Scenario label under which the funded status was computed."
    - name: "currency_code"
      display_name: "Currency"
      expr: currency_code
      comment: "Reporting currency of the measurement."
    - name: "measurement_month"
      display_name: "Measurement Month"
      expr: DATE_TRUNC('month', measurement_timestamp)
      comment: "Measurement timestamp bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "measurement_year"
      display_name: "Measurement Year"
      expr: DATE_TRUNC('year', measurement_timestamp)
      comment: "Measurement timestamp bucketed to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "measurement_count"
      display_name: "Measurement Count"
      expr: COUNT(1)
      comment: "Number of funded-status measurements."
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_funded_ratio"
      display_name: "Avg Funded Ratio"
      expr: AVG(CAST(funded_ratio AS DOUBLE))
      comment: "Average funded ratio across measurements; primary funding health KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_asset_to_liability_ratio"
      display_name: "Avg Asset/Liability Ratio"
      expr: AVG(CAST(asset_to_liability_ratio AS DOUBLE))
      comment: "Average asset-to-liability coverage ratio."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "closing_asset_market_value"
      display_name: "Closing Asset Market Value"
      expr: SUM(CAST(asset_market_value AS DOUBLE))
      comment: "Closing asset market value balance; use semi-additive closing for period-end snapshots."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: measurement_month
          range: current
          semiadditive: last
    - name: "opening_asset_market_value"
      display_name: "Opening Asset Market Value"
      expr: SUM(CAST(asset_market_value AS DOUBLE))
      comment: "Opening asset market value balance at period start."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: measurement_month
          range: current
          semiadditive: first
    - name: "asset_growth_in_period"
      display_name: "Asset Growth in Period"
      expr: COALESCE(AGG(`closing_asset_market_value`),0) - COALESCE(AGG(`opening_asset_market_value`),0)
      comment: "Change in asset market value within the period (closing minus opening)."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_liability_gross"
      display_name: "Total Gross Liability"
      expr: SUM(CAST(liability_gross AS DOUBLE))
      comment: "Total gross (going-concern) liability."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_liability_solvent"
      display_name: "Total Solvency Liability"
      expr: SUM(CAST(liability_solvent AS DOUBLE))
      comment: "Total solvency-basis liability."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`actuarial_gain_loss`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Actuarial gains and losses by type and scenario for experience-variance monitoring and regulatory disclosure of funding volatility."
  source: "`asset_management`.`actuarial`.`gain_loss`"
  dimensions:
    - name: "gain_loss_type"
      display_name: "Gain/Loss Type"
      expr: gain_loss_type
      comment: "Category of gain or loss (e.g. demographic, financial)."
    - name: "gain_loss_status"
      display_name: "Gain/Loss Status"
      expr: gain_loss_status
      comment: "Status of the gain/loss record."
    - name: "scenario"
      display_name: "Scenario"
      expr: scenario
      comment: "Scenario under which the gain/loss was measured."
    - name: "currency_code"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency of the amount."
    - name: "measurement_month"
      display_name: "Measurement Month"
      expr: DATE_TRUNC('month', measurement_timestamp)
      comment: "Measurement timestamp bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "record_count"
      display_name: "Record Count"
      expr: COUNT(1)
      comment: "Number of gain/loss records."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_gain_loss_amount"
      display_name: "Total Gain/Loss"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Net aggregate actuarial gain (positive) or loss (negative)."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_gain_loss_amount"
      display_name: "Avg Gain/Loss"
      expr: AVG(CAST(amount AS DOUBLE))
      comment: "Average gain/loss per record."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_confidence_level"
      display_name: "Avg Confidence Level"
      expr: AVG(CAST(confidence_level AS DOUBLE))
      comment: "Average statistical confidence level attached to gain/loss estimates."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`actuarial_indexation_policy_terms`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Indexation policy caps/floors and CPI linkage across contributor pools."
  source: "`asset_management`.`actuarial`.`indexation_policy`"
  dimensions:
    - name: "All Records"
      expr: "1"
  measures:
    - name: "Policies"
      display_name: "Policies"
      expr: COUNT(1)
      comment: "Policies"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`actuarial_ldi_hedge_coverage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Liability-driven investment hedge positions covering interest-rate and inflation risk."
  source: "`asset_management`.`actuarial`.`ldi_hedge_position`"
  dimensions:
    - name: "All Records"
      expr: "1"
  measures:
    - name: "Positions"
      display_name: "Positions"
      expr: COUNT(1)
      comment: "Positions"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`actuarial_liability_cash_flow`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Projected liability cash flows by year, type and scenario for funding, LDI cash-flow matching and liquidity planning."
  source: "`asset_management`.`actuarial`.`liability_cash_flow`"
  dimensions:
    - name: "liability_type"
      display_name: "Liability Type"
      expr: liability_type
      comment: "Type of liability generating the cash flow."
    - name: "segment_type"
      display_name: "Segment Type"
      expr: segment_type
      comment: "Liability segment classification."
    - name: "projection_scenario"
      display_name: "Projection Scenario"
      expr: projection_scenario
      comment: "Projection scenario label."
    - name: "funding_status"
      display_name: "Funding Status"
      expr: funding_status
      comment: "Funding status of the cash-flow segment."
    - name: "currency_code"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency of the cash flow."
    - name: "cash_flow_year"
      display_name: "Cash Flow Year"
      expr: cash_flow_year
      comment: "Projection year the cash flow belongs to."
  measures:
    - name: "cash_flow_record_count"
      display_name: "Cash Flow Record Count"
      expr: COUNT(1)
      comment: "Number of projected cash-flow records."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_cash_flow_amount"
      display_name: "Total Cash Flow"
      expr: SUM(CAST(cash_flow_amount AS DOUBLE))
      comment: "Total projected liability cash flow; drives funding and liquidity planning."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_cash_flow_amount"
      display_name: "Avg Cash Flow"
      expr: AVG(CAST(cash_flow_amount AS DOUBLE))
      comment: "Average projected cash flow per record."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_discount_rate_used"
      display_name: "Avg Discount Rate Used"
      expr: AVG(CAST(discount_rate_used AS DOUBLE))
      comment: "Average discount rate applied to projected cash flows."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`actuarial_liability_projection`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Projected pension liabilities (PBO/ABO), funded status, cost components and duration used for long-term funding strategy and LDI alignment."
  source: "`asset_management`.`actuarial`.`liability_projection`"
  dimensions:
    - name: "projection_scenario"
      display_name: "Projection Scenario"
      expr: projection_scenario
      comment: "Economic scenario label for the projection."
    - name: "regulatory_filing_status"
      display_name: "Regulatory Filing Status"
      expr: regulatory_filing_status
      comment: "Regulatory filing status of the projection."
    - name: "mortality_table"
      display_name: "Mortality Table"
      expr: mortality_table
      comment: "Mortality table applied in the projection."
    - name: "actuary_firm"
      display_name: "Actuary Firm"
      expr: actuary_firm
      comment: "Actuarial firm producing the projection."
    - name: "valuation_year"
      display_name: "Valuation Year"
      expr: DATE_TRUNC('year', valuation_date)
      comment: "Valuation date bucketed to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "projection_count"
      display_name: "Projection Count"
      expr: COUNT(1)
      comment: "Number of liability projections."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_pbo"
      display_name: "Total PBO"
      expr: SUM(CAST(pbo_amount AS DOUBLE))
      comment: "Total projected benefit obligation; headline liability measure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_abo"
      display_name: "Total ABO"
      expr: SUM(CAST(abo_amount AS DOUBLE))
      comment: "Total accumulated benefit obligation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_funded_status_amount"
      display_name: "Total Funded Status"
      expr: SUM(CAST(funded_status_amount AS DOUBLE))
      comment: "Aggregate funded status surplus/deficit amount."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_funded_ratio"
      display_name: "Avg Funded Ratio"
      expr: AVG(CAST(funded_ratio AS DOUBLE))
      comment: "Average projected funded ratio."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "total_service_cost"
      display_name: "Total Service Cost"
      expr: SUM(CAST(service_cost AS DOUBLE))
      comment: "Total service cost accrual."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_interest_cost"
      display_name: "Total Interest Cost"
      expr: SUM(CAST(interest_cost AS DOUBLE))
      comment: "Total interest cost on liabilities."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_actuarial_gain_loss"
      display_name: "Total Actuarial Gain/Loss"
      expr: SUM(CAST(actuarial_gain_loss AS DOUBLE))
      comment: "Aggregate actuarial gain (positive) or loss (negative)."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_liability_duration_years"
      display_name: "Avg Liability Duration (yrs)"
      expr: AVG(CAST(liability_duration_years AS DOUBLE))
      comment: "Average projected liability duration; LDI hedge targeting input."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "avg_discount_rate"
      display_name: "Avg Discount Rate"
      expr: AVG(CAST(discount_rate AS DOUBLE))
      comment: "Average discount rate applied; key sensitivity driver."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`actuarial_valuation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core actuarial valuation KPIs: funded ratios, surplus/deficit positions, liability magnitudes and demographic ratios used to steer funding policy and regulatory filing decisions."
  source: "`asset_management`.`actuarial`.`actuarial_valuation`"
  dimensions:
    - name: "valuation_type"
      display_name: "Valuation Type"
      expr: valuation_type
      comment: "Type of actuarial valuation (e.g. going-concern, solvency, wind-up)."
    - name: "valuation_status"
      display_name: "Valuation Status"
      expr: valuation_status
      comment: "Workflow status of the valuation."
    - name: "valuation_method"
      display_name: "Valuation Method"
      expr: valuation_method
      comment: "Methodology used for the valuation."
    - name: "asset_valuation_method"
      display_name: "Asset Valuation Method"
      expr: asset_valuation_method
      comment: "Method used to value plan assets (market vs smoothed)."
    - name: "actuary_firm_name"
      display_name: "Actuary Firm"
      expr: actuary_firm_name
      comment: "External actuarial firm certifying the valuation."
    - name: "valuation_year"
      display_name: "Valuation Year"
      expr: DATE_TRUNC('year', valuation_date)
      comment: "Valuation effective date bucketed to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "valuation_quarter"
      display_name: "Valuation Quarter"
      expr: DATE_TRUNC('quarter', valuation_date)
      comment: "Valuation effective date bucketed to quarter."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "valuation_count"
      display_name: "Valuation Count"
      expr: COUNT(1)
      comment: "Number of actuarial valuations."
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_going_concern_funded_ratio"
      display_name: "Avg Going-Concern Funded Ratio"
      expr: AVG(CAST(going_concern_funded_ratio AS DOUBLE))
      comment: "Average going-concern funded ratio across valuations; key solvency health indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_solvency_funded_ratio"
      display_name: "Avg Solvency Funded Ratio"
      expr: AVG(CAST(solvency_funded_ratio AS DOUBLE))
      comment: "Average solvency funded ratio; drives special-payment and de-risking decisions."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "total_going_concern_surplus_deficit"
      display_name: "Total Going-Concern Surplus/Deficit"
      expr: SUM(CAST(going_concern_surplus_deficit AS DOUBLE))
      comment: "Aggregate going-concern surplus (positive) or deficit (negative)."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_solvency_surplus_deficit"
      display_name: "Total Solvency Surplus/Deficit"
      expr: SUM(CAST(solvency_surplus_deficit AS DOUBLE))
      comment: "Aggregate solvency surplus/deficit exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_solvency_liability"
      display_name: "Total Solvency Liability"
      expr: SUM(CAST(solvency_liability AS DOUBLE))
      comment: "Total solvency liability obligation under valuation basis."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_plan_assets_market_value"
      display_name: "Total Plan Assets (Market)"
      expr: SUM(CAST(total_plan_assets_market_value AS DOUBLE))
      comment: "Total market value of plan assets."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_liability_duration_years"
      display_name: "Avg Liability Duration (yrs)"
      expr: AVG(CAST(liability_duration_years AS DOUBLE))
      comment: "Average liability duration in years; drives LDI hedge targeting."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "total_member_count"
      display_name: "Total Members"
      expr: SUM(CAST(total_member_count AS DOUBLE))
      comment: "Total plan membership covered by the valuation."
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_active_member_age"
      display_name: "Avg Active Member Age"
      expr: AVG(CAST(average_active_member_age AS DOUBLE))
      comment: "Average age of active members; demographic maturity signal."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`actuarial_valuation_cadence`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Actuarial valuation volume and liability/asset outcomes for funding governance."
  source: "`asset_management`.`actuarial`.`actuarial_valuation`"
  dimensions:
    - name: "All Records"
      expr: "1"
  measures:
    - name: "Valuations"
      display_name: "Valuations"
      expr: COUNT(1)
      comment: "Valuations"
      format:
        type: number
        decimal_places:
          type: all
$$;
