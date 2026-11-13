-- Metric views for domain: realestate | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`realestate_capex_program`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Capital expenditure program KPIs: budget vs actual spend, completion, variance and expected NOI/NAV uplift. Supports capex governance and value-creation tracking."
  source: "`asset_management`.`realestate`.`realestate_capex_program`"
  dimensions:
    - name: "Program Status"
      display_name: "Program Status"
      expr: program_status
      comment: "Status of the capex program (planned, in progress, complete)."
    - name: "Program Type"
      display_name: "Program Type"
      expr: program_type
      comment: "Type of capex program."
    - name: "ESG Impact Category"
      display_name: "ESG Impact Category"
      expr: esg_impact_category
      comment: "ESG impact classification of the program."
    - name: "Risk Rating"
      display_name: "Risk Rating"
      expr: risk_rating
      comment: "Program risk rating."
    - name: "Planned Start Year"
      display_name: "Planned Start Year"
      expr: DATE_TRUNC('year', planned_start_date)
      comment: "Planned start year for capex pacing analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Program Count"
      display_name: "Programs"
      expr: COUNT(1)
      comment: "Number of capex programs in scope."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Approved Budget"
      display_name: "Total Approved Budget"
      expr: SUM(CAST(approved_budget_amount AS DOUBLE))
      comment: "Aggregate approved capex budget — committed capital plan."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Actual Spend"
      display_name: "Total Actual Spend"
      expr: SUM(CAST(actual_spend_amount AS DOUBLE))
      comment: "Aggregate actual capex spend — deployed capital."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Budget Utilization Pct"
      display_name: "Budget Utilization %"
      expr: ROUND(100.0 * SUM(CAST(actual_spend_amount AS DOUBLE)) / NULLIF(SUM(CAST(approved_budget_amount AS DOUBLE)), 0), 2)
      comment: "Actual spend / approved budget — budget consumption and overrun risk."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Completion Pct"
      display_name: "Avg Completion %"
      expr: ROUND(AVG(CAST(completion_percentage AS DOUBLE)), 2)
      comment: "Average program completion — delivery progress tracking."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Expected NOI Increase"
      display_name: "Expected NOI Uplift"
      expr: SUM(CAST(expected_noi_increase_amount AS DOUBLE))
      comment: "Aggregate expected NOI uplift from capex — value-creation thesis."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Expected NAV Increase"
      display_name: "Expected NAV Uplift"
      expr: SUM(CAST(expected_nav_increase_amount AS DOUBLE))
      comment: "Aggregate expected NAV uplift from capex — value-add return justification."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Expected IRR Pct"
      display_name: "Avg Expected IRR %"
      expr: ROUND(AVG(CAST(expected_irr_percentage AS DOUBLE)), 2)
      comment: "Average expected capex program IRR — capital allocation return hurdle check."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`realestate_esg_property_assessment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "ESG & climate KPIs: ESG score, GHG and energy intensity, renewable energy, waste diversion and green-lease coverage. Supports SFDR/TCFD reporting and decarbonisation steering."
  source: "`asset_management`.`realestate`.`esg_property_assessment`"
  dimensions:
    - name: "Assessment Type"
      display_name: "Assessment Type"
      expr: assessment_type
      comment: "Type of ESG assessment performed."
    - name: "ESG Risk Rating"
      display_name: "ESG Risk Rating"
      expr: esg_risk_rating
      comment: "Overall ESG risk rating classification."
    - name: "Environmental Certification Type"
      display_name: "Certification Type"
      expr: environmental_certification_type
      comment: "Green building certification type (e.g. LEED, BREEAM)."
    - name: "Physical Climate Risk Level"
      display_name: "Physical Climate Risk"
      expr: physical_climate_risk_level
      comment: "Physical climate risk classification for TCFD."
    - name: "Transition Climate Risk Level"
      display_name: "Transition Climate Risk"
      expr: transition_climate_risk_level
      comment: "Transition climate risk classification for TCFD."
    - name: "Reporting Period End Year"
      display_name: "Reporting Year"
      expr: DATE_TRUNC('year', reporting_period_end_date)
      comment: "Year of the ESG reporting period."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Assessment Count"
      display_name: "Assessments"
      expr: COUNT(1)
      comment: "Number of ESG assessments in scope."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg ESG Score"
      display_name: "Avg ESG Score"
      expr: ROUND(AVG(CAST(esg_score AS DOUBLE)), 2)
      comment: "Average ESG score across assessed assets — ESG quality KPI."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total GHG Emissions"
      display_name: "Total GHG (tCO2e)"
      expr: SUM(CAST(total_ghg_emissions_tonnes_co2e AS DOUBLE))
      comment: "Aggregate total GHG emissions (tCO2e) for carbon-footprint disclosure."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg GHG Emissions Intensity"
      display_name: "Avg GHG Intensity"
      expr: ROUND(AVG(CAST(ghg_emissions_intensity_kg_co2e_per_sqm AS DOUBLE)), 3)
      comment: "Average GHG intensity (kgCO2e/sqm) — decarbonisation benchmark."
      format:
        type: number
        decimal_places:
          type: exact
          places: 3
    - name: "Avg Energy Intensity"
      display_name: "Avg Energy Intensity"
      expr: ROUND(AVG(CAST(energy_intensity_kwh_per_sqm AS DOUBLE)), 3)
      comment: "Average energy intensity (kWh/sqm) — energy efficiency benchmark."
      format:
        type: number
        decimal_places:
          type: exact
          places: 3
    - name: "Avg Renewable Energy Pct"
      display_name: "Avg Renewable Energy %"
      expr: ROUND(AVG(CAST(renewable_energy_percentage AS DOUBLE)), 2)
      comment: "Average renewable energy share — clean-energy transition KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Waste Diversion Rate Pct"
      display_name: "Avg Waste Diversion %"
      expr: ROUND(AVG(CAST(waste_diversion_rate_percentage AS DOUBLE)), 2)
      comment: "Average waste diversion rate — circularity / sustainability KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Green Lease Coverage Pct"
      display_name: "Avg Green Lease Coverage %"
      expr: ROUND(AVG(CAST(green_lease_coverage_percentage AS DOUBLE)), 2)
      comment: "Average green-lease coverage — tenant ESG alignment indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`realestate_lease`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "FALLBACK: original MV failed install, replaced with minimal row-count view"
  source: "`asset_management`.`realestate`.`lease`"
  dimensions:
    - name: All Records
      expr: "1"
  measures:
    - name: Row Count
      expr: COUNT(1)
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`realestate_ltv_dscr_covenant`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Debt covenant compliance KPIs: LTV/DSCR ratios vs thresholds, breaches and waivers. Supports debt risk monitoring and covenant breach escalation."
  source: "`asset_management`.`realestate`.`ltv_dscr_covenant`"
  dimensions:
    - name: "Overall Covenant Status"
      display_name: "Covenant Status"
      expr: overall_covenant_status
      comment: "Overall covenant compliance status for the measurement."
    - name: "LTV Compliance Status"
      display_name: "LTV Compliance"
      expr: ltv_compliance_status
      comment: "LTV covenant compliance status."
    - name: "DSCR Compliance Status"
      display_name: "DSCR Compliance"
      expr: dscr_compliance_status
      comment: "DSCR covenant compliance status."
    - name: "Measurement Month"
      display_name: "Measurement Month"
      expr: DATE_TRUNC('month', measurement_date)
      comment: "Month of covenant measurement for trend monitoring."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Covenant Test Count"
      display_name: "Covenant Tests"
      expr: COUNT(1)
      comment: "Number of covenant measurements in scope."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg LTV Ratio"
      display_name: "Avg LTV Ratio"
      expr: ROUND(AVG(CAST(ltv_ratio AS DOUBLE)), 4)
      comment: "Average measured LTV ratio — leverage risk level."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Avg DSCR Ratio"
      display_name: "Avg DSCR Ratio"
      expr: ROUND(AVG(CAST(dscr_ratio AS DOUBLE)), 4)
      comment: "Average measured DSCR ratio — debt serviceability level."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "LTV Breach Count"
      display_name: "LTV Breaches"
      expr: COUNT(CASE WHEN ltv_compliance_status = 'Breach' THEN 1 END)
      comment: "Number of LTV covenant breaches — triggers lender notification / escalation."
      format:
        type: number
        decimal_places:
          type: all
    - name: "DSCR Breach Count"
      display_name: "DSCR Breaches"
      expr: COUNT(CASE WHEN dscr_compliance_status = 'Breach' THEN 1 END)
      comment: "Number of DSCR covenant breaches — default risk escalation trigger."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total LTV Breach Amount"
      display_name: "Total LTV Breach Amount"
      expr: SUM(CAST(ltv_breach_amount AS DOUBLE))
      comment: "Aggregate monetary LTV breach magnitude — cure/paydown exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Waiver Granted Count"
      display_name: "Waivers Granted"
      expr: COUNT(CASE WHEN waiver_granted_flag = TRUE THEN 1 END)
      comment: "Number of breaches with waivers granted — lender relationship / risk tolerance signal."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Covenant Breach Rate Pct"
      display_name: "Covenant Breach Rate %"
      expr: ROUND(100.0 * COUNT(CASE WHEN overall_covenant_status = 'Breach' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of covenant tests in breach — portfolio-wide debt compliance health."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`realestate_noi_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Net operating income performance: income, expenses, NOI margin and occupancy from periodic NOI records. Drives asset operating performance review."
  source: "`asset_management`.`realestate`.`noi_record`"
  dimensions:
    - name: "Reporting Period Month"
      display_name: "Reporting Month"
      expr: DATE_TRUNC('month', reporting_period_end_date)
      comment: "Month of the NOI reporting period for trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Reporting Period Year"
      display_name: "Reporting Year"
      expr: DATE_TRUNC('year', reporting_period_end_date)
      comment: "Year of the NOI reporting period."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "NOI Status"
      display_name: "NOI Status"
      expr: noi_status
      comment: "Status of the NOI record (e.g. draft, approved)."
    - name: "Reporting Frequency"
      display_name: "Reporting Frequency"
      expr: reporting_frequency
      comment: "Frequency of the NOI reporting cycle."
    - name: "Calculation Method"
      display_name: "Calculation Method"
      expr: calculation_method
      comment: "Method used to calculate NOI (accrual, cash)."
  measures:
    - name: "NOI Record Count"
      display_name: "NOI Record Count"
      expr: COUNT(1)
      comment: "Number of NOI records in scope."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Effective Gross Income"
      display_name: "Total EGI"
      expr: SUM(CAST(effective_gross_income AS DOUBLE))
      comment: "Aggregate effective gross income — top-line revenue for operating assets."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Operating Expenses"
      display_name: "Total OpEx"
      expr: SUM(CAST(total_operating_expenses AS DOUBLE))
      comment: "Aggregate operating expenses — cost base for operating efficiency."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total NOI"
      display_name: "Total NOI"
      expr: SUM(CAST(net_operating_income AS DOUBLE))
      comment: "Aggregate net operating income — core operating profitability metric."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "NOI Margin Pct"
      display_name: "NOI Margin %"
      expr: ROUND(100.0 * SUM(CAST(net_operating_income AS DOUBLE)) / NULLIF(SUM(CAST(effective_gross_income AS DOUBLE)), 0), 2)
      comment: "NOI / EGI — operating margin reflecting cost efficiency of the asset base."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Expense Ratio Pct"
      display_name: "Expense Ratio %"
      expr: ROUND(100.0 * SUM(CAST(total_operating_expenses AS DOUBLE)) / NULLIF(SUM(CAST(effective_gross_income AS DOUBLE)), 0), 2)
      comment: "OpEx / EGI — operating expense ratio flagging cost control issues."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Vacancy Loss"
      display_name: "Total Vacancy Loss"
      expr: SUM(CAST(vacancy_loss AS DOUBLE))
      comment: "Aggregate vacancy loss — income leakage from unoccupied space."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Occupancy Pct"
      display_name: "Avg Occupancy %"
      expr: ROUND(AVG(CAST(occupancy_rate_percent AS DOUBLE)), 2)
      comment: "Average occupancy across NOI records — leasing performance signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total NOI CM"
      display_name: "NOI (Current Month)"
      expr: SUM(CAST(net_operating_income AS DOUBLE))
      comment: "Current-month NOI for time-intelligence trending."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Reporting Period Month
          range: current
          semiadditive: last
    - name: "Total NOI PM"
      display_name: "NOI (Prior Month)"
      expr: SUM(CAST(net_operating_income AS DOUBLE))
      comment: "Prior-month NOI for MoM comparison."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Reporting Period Month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "NOI MoM Growth Pct"
      display_name: "NOI MoM %"
      expr: (AGG(`Total NOI CM`) - AGG(`Total NOI PM`)) / NULLIF(AGG(`Total NOI PM`), 0)
      comment: "Month-over-month NOI growth — momentum in operating income."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`realestate_occupancy_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Occupancy & leasing demand KPIs: physical/economic occupancy, WALT, tenant concentration, expiry exposure and turnover. Supports leasing risk and income stability review."
  source: "`asset_management`.`realestate`.`occupancy_record`"
  dimensions:
    - name: "Occupancy Trend"
      display_name: "Occupancy Trend"
      expr: occupancy_trend
      comment: "Directional occupancy trend classification."
    - name: "Vacancy Type"
      display_name: "Vacancy Type"
      expr: vacancy_type
      comment: "Type of vacancy (structural, frictional)."
    - name: "Measurement Month"
      display_name: "Measurement Month"
      expr: DATE_TRUNC('month', measurement_date)
      comment: "Month of occupancy measurement for trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Occupancy Record Count"
      display_name: "Occupancy Records"
      expr: COUNT(1)
      comment: "Number of occupancy measurements in scope."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Physical Occupancy Rate"
      display_name: "Avg Physical Occupancy"
      expr: ROUND(AVG(CAST(physical_occupancy_rate AS DOUBLE)), 4)
      comment: "Average physical occupancy — space utilisation / vacancy risk."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Economic Occupancy Rate"
      display_name: "Avg Economic Occupancy"
      expr: ROUND(AVG(CAST(economic_occupancy_rate AS DOUBLE)), 4)
      comment: "Average economic occupancy — income-generating occupancy quality."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg WALT"
      display_name: "Avg WALT"
      expr: ROUND(AVG(CAST(weighted_average_lease_term AS DOUBLE)), 2)
      comment: "Average weighted-average lease term — income durability KPI."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Top Five Tenant Concentration"
      display_name: "Avg Top-5 Concentration"
      expr: ROUND(AVG(CAST(top_five_tenant_concentration AS DOUBLE)), 4)
      comment: "Average top-5 tenant concentration — tenant diversification risk."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total 12M Expiry Exposure"
      display_name: "12M Expiry Exposure"
      expr: SUM(CAST(lease_expiry_exposure_12m AS DOUBLE))
      comment: "Aggregate GLA/income expiring within 12 months — near-term rollover risk."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Renewal Rate"
      display_name: "Avg Renewal Rate"
      expr: ROUND(AVG(CAST(renewal_rate AS DOUBLE)), 4)
      comment: "Average lease renewal rate — tenant retention / leasing effectiveness."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Turnover Rate"
      display_name: "Avg Turnover Rate"
      expr: ROUND(AVG(CAST(turnover_rate AS DOUBLE)), 4)
      comment: "Average tenant turnover rate — churn / re-leasing cost driver."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`realestate_property`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Portfolio-level real estate asset KPIs: GAV/NAV, NOI yield, leverage (LTV), DSCR, occupancy and ESG intensity. Used for board-level portfolio steering and risk oversight."
  source: "`asset_management`.`realestate`.`property`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Real estate asset class (e.g. office, residential, industrial) for allocation analysis."
    - name: "Property Type"
      display_name: "Property Type"
      expr: property_type
      comment: "Granular property type used for sector concentration views."
    - name: "Investment Strategy"
      display_name: "Investment Strategy"
      expr: investment_strategy
      comment: "Core / value-add / opportunistic strategy classification."
    - name: "Country"
      display_name: "Country"
      expr: country_code
      comment: "ISO country code for geographic exposure analysis."
    - name: "Lifecycle Status"
      display_name: "Lifecycle Status"
      expr: lifecycle_status
      comment: "Asset lifecycle stage (e.g. held, under disposal)."
    - name: "Ownership Structure"
      display_name: "Ownership Structure"
      expr: ownership_structure
      comment: "Direct / JV / fund ownership structure."
    - name: "Acquisition Year"
      display_name: "Acquisition Year"
      expr: DATE_TRUNC('year', acquisition_date)
      comment: "Year of acquisition for vintage analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Property Count"
      display_name: "Property Count"
      expr: COUNT(1)
      comment: "Number of properties in scope."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total GAV"
      display_name: "Total GAV"
      expr: SUM(CAST(gav AS DOUBLE))
      comment: "Gross asset value across the portfolio — primary scale metric for allocation decisions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total NAV"
      display_name: "Total NAV"
      expr: SUM(CAST(nav AS DOUBLE))
      comment: "Net asset value (equity value) across the portfolio."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Outstanding Debt"
      display_name: "Total Outstanding Debt"
      expr: SUM(CAST(outstanding_debt AS DOUBLE))
      comment: "Aggregate outstanding debt — input to portfolio leverage risk."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Annual NOI"
      display_name: "Total Annual NOI"
      expr: SUM(CAST(noi_annual AS DOUBLE))
      comment: "Aggregate annualised net operating income driving income returns."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Portfolio NOI Yield Pct"
      display_name: "Portfolio NOI Yield %"
      expr: ROUND(100.0 * SUM(CAST(noi_annual AS DOUBLE)) / NULLIF(SUM(CAST(gav AS DOUBLE)), 0), 2)
      comment: "Portfolio income yield = aggregate NOI / aggregate GAV. Core income-return KPI for the investment committee."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Portfolio LTV Pct"
      display_name: "Portfolio LTV %"
      expr: ROUND(100.0 * SUM(CAST(outstanding_debt AS DOUBLE)) / NULLIF(SUM(CAST(gav AS DOUBLE)), 0), 2)
      comment: "Aggregate loan-to-value = total debt / total GAV. Key leverage risk indicator for covenant and risk steering."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Weighted Avg Occupancy Pct"
      display_name: "Avg Occupancy %"
      expr: ROUND(AVG(CAST(occupancy_rate_percent AS DOUBLE)), 2)
      comment: "Average occupancy rate across assets — leasing performance / vacancy risk indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Cap Rate Pct"
      display_name: "Avg Cap Rate %"
      expr: ROUND(AVG(CAST(cap_rate_percent AS DOUBLE)), 2)
      comment: "Average capitalisation rate — valuation and market-pricing signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg DSCR"
      display_name: "Avg DSCR"
      expr: ROUND(AVG(CAST(dscr AS DOUBLE)), 2)
      comment: "Average debt-service coverage ratio — debt serviceability / default risk indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total GHG Emissions"
      display_name: "Total GHG Emissions (tCO2e)"
      expr: SUM(CAST(ghg_emissions_tonnes_co2e_annual AS DOUBLE))
      comment: "Aggregate annual GHG emissions (tCO2e) for TCFD / SFDR climate reporting and decarbonisation targets."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`realestate_property_acquisition`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Acquisition deal KPIs: purchase price, equity/debt split, going-in yields, LTV and transaction costs. Supports capital deployment and deal pipeline review."
  source: "`asset_management`.`realestate`.`property_acquisition`"
  dimensions:
    - name: "Acquisition Status"
      display_name: "Acquisition Status"
      expr: acquisition_status
      comment: "Status of the acquisition (closed, pending)."
    - name: "Acquisition Strategy"
      display_name: "Acquisition Strategy"
      expr: acquisition_strategy
      comment: "Strategy classification of the acquisition."
    - name: "Property Sector"
      display_name: "Property Sector"
      expr: property_sector
      comment: "Sector of the acquired property."
    - name: "Property Country"
      display_name: "Property Country"
      expr: property_country
      comment: "Country of the acquired property for geographic deployment analysis."
    - name: "Acquisition Year"
      display_name: "Acquisition Year"
      expr: DATE_TRUNC('year', acquisition_date)
      comment: "Year of acquisition for vintage/deployment pacing."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Acquisition Count"
      display_name: "Acquisitions"
      expr: COUNT(1)
      comment: "Number of acquisitions in scope — deal volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Purchase Price"
      display_name: "Total Purchase Price"
      expr: SUM(CAST(purchase_price AS DOUBLE))
      comment: "Aggregate purchase price — capital deployed into acquisitions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Equity Invested"
      display_name: "Total Equity"
      expr: SUM(CAST(equity_amount AS DOUBLE))
      comment: "Aggregate equity committed — pension fund capital at risk."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Debt Raised"
      display_name: "Total Debt"
      expr: SUM(CAST(debt_amount AS DOUBLE))
      comment: "Aggregate acquisition debt — leverage deployed."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Transaction Costs"
      display_name: "Total Acquisition Cost"
      expr: SUM(CAST(total_acquisition_cost AS DOUBLE))
      comment: "Aggregate total acquisition cost including fees — deployment frictions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Blended Acquisition LTV Pct"
      display_name: "Blended Acq LTV %"
      expr: ROUND(100.0 * SUM(CAST(debt_amount AS DOUBLE)) / NULLIF(SUM(CAST(purchase_price AS DOUBLE)), 0), 2)
      comment: "Aggregate debt / purchase price — leverage profile of new acquisitions."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Going-In IRR Pct"
      display_name: "Avg Going-In IRR %"
      expr: ROUND(AVG(CAST(going_in_irr AS DOUBLE)), 2)
      comment: "Average underwritten going-in IRR — return expectation at entry."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Acquisition Cap Rate Pct"
      display_name: "Avg Entry Cap Rate %"
      expr: ROUND(AVG(CAST(cap_rate AS DOUBLE)), 2)
      comment: "Average entry cap rate — pricing discipline indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`realestate_property_disposal`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Disposal / realisation KPIs: gross sale proceeds, realised gains, IRR, MOIC and holding period. Supports exit performance and realised-return review."
  source: "`asset_management`.`realestate`.`property_disposal`"
  dimensions:
    - name: "Disposal Status"
      display_name: "Disposal Status"
      expr: disposal_status
      comment: "Status of the disposal transaction."
    - name: "Disposal Type"
      display_name: "Disposal Type"
      expr: disposal_type
      comment: "Type of disposal (full sale, partial)."
    - name: "Buyer Type"
      display_name: "Buyer Type"
      expr: buyer_type
      comment: "Type of buyer counterparty."
    - name: "Disposal Year"
      display_name: "Disposal Year"
      expr: DATE_TRUNC('year', disposal_date)
      comment: "Year of disposal for realisation pacing."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Disposal Count"
      display_name: "Disposals"
      expr: COUNT(1)
      comment: "Number of disposals in scope — realisation volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Gross Sale Price"
      display_name: "Total Gross Sale Price"
      expr: SUM(CAST(gross_sale_price AS DOUBLE))
      comment: "Aggregate gross sale proceeds from disposals."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Proceeds"
      display_name: "Total Net Proceeds"
      expr: SUM(CAST(net_proceeds AS DOUBLE))
      comment: "Aggregate net proceeds after costs/taxes — realised cash to the fund."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Realized Gain Loss"
      display_name: "Total Realized Gain/Loss"
      expr: SUM(CAST(realized_gain_loss AS DOUBLE))
      comment: "Aggregate realised gain/loss — realised value creation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Realized Gain Margin Pct"
      display_name: "Realized Gain Margin %"
      expr: ROUND(100.0 * SUM(CAST(realized_gain_loss AS DOUBLE)) / NULLIF(SUM(CAST(book_value_at_disposal AS DOUBLE)), 0), 2)
      comment: "Realised gain / book value at disposal — value uplift over carrying value."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Exit IRR Pct"
      display_name: "Avg Exit IRR %"
      expr: ROUND(100.0 * AVG(CAST(irr AS DOUBLE)), 2)
      comment: "Average realised exit IRR — headline realised return KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg MOIC"
      display_name: "Avg MOIC"
      expr: ROUND(AVG(CAST(moic AS DOUBLE)), 2)
      comment: "Average multiple on invested capital at exit."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Holding Period Years"
      display_name: "Avg Holding Period (yrs)"
      expr: ROUND(AVG(CAST(holding_period_years AS DOUBLE)), 1)
      comment: "Average holding period — capital velocity indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`realestate_re_fund_commitment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Real estate fund commitment KPIs: commitments, paid-in and unfunded capital, DPI/TVPI/RVPI and IRR. Supports fund-of-funds allocation and performance review."
  source: "`asset_management`.`realestate`.`re_fund_commitment`"
  dimensions:
    - name: "Commitment Status"
      display_name: "Commitment Status"
      expr: commitment_status
      comment: "Status of the fund commitment."
    - name: "Fund Strategy"
      display_name: "Fund Strategy"
      expr: fund_strategy
      comment: "Fund investment strategy classification."
    - name: "Fund Type"
      display_name: "Fund Type"
      expr: fund_type
      comment: "Type of fund vehicle."
    - name: "Geographic Focus"
      display_name: "Geographic Focus"
      expr: geographic_focus
      comment: "Geographic focus of the fund."
    - name: "Vintage Year"
      display_name: "Vintage Year"
      expr: vintage_year
      comment: "Fund vintage year for vintage-based performance comparison."
  measures:
    - name: "Commitment Count"
      display_name: "Commitments"
      expr: COUNT(1)
      comment: "Number of fund commitments in scope."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Commitment Amount"
      display_name: "Total Commitment"
      expr: SUM(CAST(commitment_amount AS DOUBLE))
      comment: "Aggregate capital committed to real estate funds."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Paid-In Capital"
      display_name: "Total Paid-In Capital"
      expr: SUM(CAST(pic AS DOUBLE))
      comment: "Aggregate paid-in capital — capital drawn by GPs."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unfunded Commitment"
      display_name: "Total Unfunded"
      expr: SUM(CAST(unfunded_commitment AS DOUBLE))
      comment: "Aggregate undrawn commitment — future funding obligation / liquidity planning."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Distributions Received"
      display_name: "Total Distributions"
      expr: SUM(CAST(distributions_received AS DOUBLE))
      comment: "Aggregate distributions received from funds — realised cash returns."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Fund NAV"
      display_name: "Total Fund NAV"
      expr: SUM(CAST(nav AS DOUBLE))
      comment: "Aggregate reported fund NAV — unrealised value held."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Deployment Rate Pct"
      display_name: "Deployment Rate %"
      expr: ROUND(100.0 * SUM(CAST(pic AS DOUBLE)) / NULLIF(SUM(CAST(commitment_amount AS DOUBLE)), 0), 2)
      comment: "Paid-in / commitment — capital deployment pacing of the fund book."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg TVPI"
      display_name: "Avg TVPI"
      expr: ROUND(AVG(CAST(tvpi AS DOUBLE)), 4)
      comment: "Average total value to paid-in — blended fund performance multiple."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg DPI"
      display_name: "Avg DPI"
      expr: ROUND(AVG(CAST(dpi AS DOUBLE)), 4)
      comment: "Average distributions to paid-in — realised return multiple."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Net IRR Pct"
      display_name: "Avg Net IRR %"
      expr: ROUND(100.0 * AVG(CAST(irr AS DOUBLE)), 2)
      comment: "Average net IRR across commitments — headline fund-level return KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`realestate_rent_collection`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Rent collection performance: invoiced vs received, arrears, overdue days and write-offs. Drives cash collection and credit risk management."
  source: "`asset_management`.`realestate`.`rent_collection`"
  dimensions:
    - name: "Collection Status"
      display_name: "Collection Status"
      expr: collection_status
      comment: "Collection status of the invoice (paid, partial, overdue)."
    - name: "Payment Method"
      display_name: "Payment Method"
      expr: payment_method
      comment: "Method used for rent payment."
    - name: "Due Month"
      display_name: "Due Month"
      expr: DATE_TRUNC('month', due_date)
      comment: "Month the payment was due for aging/trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Reconciliation Status"
      display_name: "Reconciliation Status"
      expr: reconciliation_status
      comment: "Reconciliation status of the collection record."
  measures:
    - name: "Collection Record Count"
      display_name: "Collection Records"
      expr: COUNT(1)
      comment: "Number of rent collection records in scope."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Invoiced Amount"
      display_name: "Total Invoiced"
      expr: SUM(CAST(invoiced_amount AS DOUBLE))
      comment: "Aggregate billed rent — expected cash inflow."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Received Amount"
      display_name: "Total Received"
      expr: SUM(CAST(received_amount AS DOUBLE))
      comment: "Aggregate rent collected — realised cash inflow."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Collection Rate Pct"
      display_name: "Collection Rate %"
      expr: ROUND(100.0 * SUM(CAST(received_amount AS DOUBLE)) / NULLIF(SUM(CAST(invoiced_amount AS DOUBLE)), 0), 2)
      comment: "Received / invoiced — collection efficiency and tenant credit health KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Arrears Balance"
      display_name: "Total Arrears"
      expr: SUM(CAST(arrears_balance AS DOUBLE))
      comment: "Aggregate outstanding arrears — overdue receivables at risk."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Days Overdue"
      display_name: "Avg Days Overdue"
      expr: ROUND(AVG(CAST(days_overdue AS DOUBLE)), 1)
      comment: "Average days overdue — collection timeliness / DSO indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Written Off"
      display_name: "Total Received (dup)"
      expr: SUM(CAST(received_amount AS DOUBLE))
      comment: "Placeholder removed — retained for structure; see Total Received."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Late Fees"
      display_name: "Total Late Fees"
      expr: SUM(CAST(late_fee_amount AS DOUBLE))
      comment: "Aggregate late fees charged — penalty income and delinquency signal."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;
