-- Metric views for domain: naturalresource | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`naturalresource_capital_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Capital call and distribution event KPIs for natural resource fund investments covering commitment deployment, distributions and unfunded exposure. Used to monitor capital pacing and liquidity."
  source: "`asset_management`.`naturalresource`.`capital_event`"
  dimensions:
    - name: "Event Type"
      display_name: "Event type"
      expr: event_type
      comment: "Type of capital event (e.g. capital call, distribution)."
    - name: "Event Status"
      display_name: "Event status"
      expr: event_status
      comment: "Processing status of the capital event."
    - name: "Distribution Type"
      display_name: "Distribution type"
      expr: distribution_type
      comment: "Type of distribution where applicable."
    - name: "Approval Status"
      display_name: "Approval status"
      expr: approval_status
      comment: "Approval status of the capital event."
    - name: "Event Currency Code"
      display_name: "Event currency code"
      expr: event_currency_code
      comment: "Currency of the capital event."
    - name: "Resource Asset Type"
      display_name: "Resource asset type"
      expr: resource_asset_type
      comment: "Underlying resource asset type for the event."
    - name: "Effective Month"
      display_name: "Effective month"
      expr: DATE_TRUNC('month', effective_date)
      comment: "Effective date bucketed to month for capital pacing trends."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Event Count"
      display_name: "Event count"
      expr: COUNT(1)
      comment: "Number of capital events."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Event Amount (Base)"
      display_name: "Total event amount (base)"
      expr: SUM(CAST(event_amount_base_currency AS DOUBLE))
      comment: "Aggregate capital event amount in base currency — primary flow metric."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Commitment Amount"
      display_name: "Total commitment amount"
      expr: SUM(CAST(commitment_amount AS DOUBLE))
      comment: "Aggregate commitment amount associated with events."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Paid-In Capital to Date"
      display_name: "Total paid-in capital to date"
      expr: SUM(CAST(paid_in_capital_to_date AS DOUBLE))
      comment: "Aggregate paid-in capital to date — deployment progress indicator."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Distributions to Date"
      display_name: "Total distributions to date"
      expr: SUM(CAST(distributions_to_date AS DOUBLE))
      comment: "Aggregate distributions received to date."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Distribution"
      display_name: "Total net distribution"
      expr: SUM(CAST(net_distribution_amount AS DOUBLE))
      comment: "Aggregate net distribution amount after deductions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unfunded Commitment"
      display_name: "Total unfunded commitment"
      expr: SUM(CAST(unfunded_commitment AS DOUBLE))
      comment: "Aggregate remaining unfunded commitment — future liquidity obligation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Withholding Tax"
      display_name: "Total withholding tax"
      expr: SUM(CAST(withholding_tax_amount AS DOUBLE))
      comment: "Aggregate withholding tax on distributions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`naturalresource_carbon_credit`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Carbon credit inventory and valuation KPIs covering holdings, retirements and mark-to-market gains. Used to steer carbon strategy and support SFDR/TCFD climate disclosures."
  source: "`asset_management`.`naturalresource`.`carbon_credit`"
  dimensions:
    - name: "Credit Type"
      display_name: "Credit type"
      expr: credit_type
      comment: "Type of carbon credit."
    - name: "Credit Status"
      display_name: "Credit status"
      expr: credit_status
      comment: "Lifecycle status of the credit (e.g. active, retired)."
    - name: "Holding Purpose"
      display_name: "Holding purpose"
      expr: holding_purpose
      comment: "Purpose for holding the credit (e.g. compliance, investment)."
    - name: "Methodology Name"
      display_name: "Methodology name"
      expr: methodology_name
      comment: "Carbon methodology under which credit was issued."
    - name: "Project Location Country"
      display_name: "Project location country"
      expr: project_location_country
      comment: "Country of the underlying carbon project."
    - name: "Permanence Risk Rating"
      display_name: "Permanence risk rating"
      expr: permanence_risk_rating
      comment: "Permanence risk rating of the credit."
    - name: "Vintage Year"
      display_name: "Vintage year"
      expr: vintage_year
      comment: "Vintage year of the carbon credit."
    - name: "Acquisition Month"
      display_name: "Acquisition month"
      expr: DATE_TRUNC('month', acquisition_date)
      comment: "Acquisition date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Credit Record Count"
      display_name: "Credit record count"
      expr: COUNT(1)
      comment: "Number of carbon credit records."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Quantity (Tonnes CO2e)"
      display_name: "Total quantity (tonnes co2e)"
      expr: SUM(CAST(quantity_tonnes_co2e AS DOUBLE))
      comment: "Aggregate carbon credit quantity held in tonnes CO2e."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Buffer Pool Contribution"
      display_name: "Total buffer pool contribution"
      expr: SUM(CAST(buffer_pool_contribution_tonnes AS DOUBLE))
      comment: "Aggregate buffer pool contribution in tonnes — reversal insurance indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Average Acquisition Price per Tonne"
      display_name: "Average acquisition price per tonne"
      expr: AVG(CAST(acquisition_price_per_tonne AS DOUBLE))
      comment: "Average acquisition price per tonne CO2e."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 4
    - name: "Average Market Price per Tonne"
      display_name: "Average market price per tonne"
      expr: AVG(CAST(current_market_price_per_tonne AS DOUBLE))
      comment: "Average current market price per tonne CO2e — mark-to-market reference."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 4
    - name: "Average Unit Mark-to-Market Gain"
      display_name: "Average unit mark-to-market gain"
      expr: AVG(CAST(current_market_price_per_tonne AS DOUBLE) - CAST(acquisition_price_per_tonne AS DOUBLE))
      comment: "Average per-tonne gain/loss versus acquisition price — carbon position performance."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 4
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`naturalresource_carbon_project`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Carbon project portfolio KPIs covering investment, valuation, issuance and ESG scoring. Used to evaluate nature-based solution investments and climate-positive capital allocation."
  source: "`asset_management`.`naturalresource`.`carbon_project`"
  dimensions:
    - name: "Project Type"
      display_name: "Project type"
      expr: project_type
      comment: "Type of carbon project (e.g. afforestation, REDD+)."
    - name: "Project Status"
      display_name: "Project carbon_project_status"
      expr: carbon_project_status
      comment: "Status of the carbon project."
    - name: "Country Code"
      display_name: "Country code"
      expr: country_code
      comment: "Country of the project."
    - name: "Region"
      display_name: "Region"
      expr: region
      comment: "Region of the project."
    - name: "Internal Risk Rating"
      display_name: "Internal risk rating"
      expr: internal_risk_rating
      comment: "Internal risk rating of the project."
    - name: "Permanence Risk Rating"
      display_name: "Permanence risk rating"
      expr: permanence_risk_rating
      comment: "Permanence risk rating of the project."
    - name: "Acquisition Year"
      display_name: "Acquisition year"
      expr: DATE_TRUNC('year', acquisition_date)
      comment: "Year the project was acquired."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Project Count"
      display_name: "Project count"
      expr: COUNT(1)
      comment: "Number of carbon projects."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Investment Amount"
      display_name: "Total investment amount"
      expr: SUM(CAST(investment_amount_usd AS DOUBLE))
      comment: "Aggregate capital invested into carbon projects."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Current Valuation"
      display_name: "Total current valuation"
      expr: SUM(CAST(current_valuation_usd AS DOUBLE))
      comment: "Aggregate current valuation of carbon projects."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Credits Issued to Date"
      display_name: "Total credits issued to date"
      expr: SUM(CAST(credits_issued_to_date_tonnes AS DOUBLE))
      comment: "Aggregate credits issued to date — delivery performance indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Credits Retired to Date"
      display_name: "Total credits retired to date"
      expr: SUM(CAST(credits_retired_to_date_tonnes AS DOUBLE))
      comment: "Aggregate credits retired to date."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Estimated Annual Credits"
      display_name: "Total estimated annual credits"
      expr: SUM(CAST(estimated_annual_credits_tonnes AS DOUBLE))
      comment: "Aggregate estimated annual credit generation capacity."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Average ESG Score"
      display_name: "Average esg score"
      expr: AVG(CAST(esg_score AS DOUBLE))
      comment: "Average ESG score across projects — sustainability quality indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Average Ownership Percentage"
      display_name: "Average ownership percentage"
      expr: AVG(CAST(ownership_percentage AS DOUBLE))
      comment: "Average ownership stake in carbon projects."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`naturalresource_commodity_exposure`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Commodity exposure and risk KPIs covering notional exposure, AUM concentration, hedging and VaR. Used by risk teams to monitor commodity price risk across the portfolio."
  source: "`asset_management`.`naturalresource`.`commodity_exposure`"
  dimensions:
    - name: "Commodity Type"
      display_name: "Commodity type"
      expr: commodity_type
      comment: "Commodity type of the exposure."
    - name: "Commodity Subtype"
      display_name: "Commodity subtype"
      expr: commodity_subtype
      comment: "Commodity subtype of the exposure."
    - name: "Exposure Classification"
      display_name: "Exposure classification"
      expr: exposure_classification
      comment: "Classification of the exposure."
    - name: "Exposure Status"
      display_name: "Exposure status"
      expr: exposure_status
      comment: "Status of the exposure."
    - name: "Geographic Region"
      display_name: "Geographic region"
      expr: geographic_region
      comment: "Geographic region of the exposure."
    - name: "Hedging Instrument Type"
      display_name: "Hedging instrument type"
      expr: hedging_instrument_type
      comment: "Type of hedging instrument used."
    - name: "Fair Value Level"
      display_name: "Fair value level"
      expr: fair_value_level
      comment: "Fair value hierarchy level of the exposure."
    - name: "Measurement Month"
      display_name: "Measurement month"
      expr: DATE_TRUNC('month', measurement_date)
      comment: "Measurement date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Exposure Count"
      display_name: "Exposure count"
      expr: COUNT(1)
      comment: "Number of commodity exposure records."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Exposure Notional"
      display_name: "Total exposure notional"
      expr: SUM(CAST(exposure_notional_usd AS DOUBLE))
      comment: "Aggregate notional commodity exposure in USD — core risk size metric."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total VaR Contribution"
      display_name: "Total var contribution"
      expr: SUM(CAST(var_contribution_usd AS DOUBLE))
      comment: "Aggregate value-at-risk contribution — risk concentration metric."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Exposure Pct of AUM"
      display_name: "Average exposure pct of aum"
      expr: AVG(CAST(exposure_percentage_of_aum AS DOUBLE))
      comment: "Average exposure as percentage of AUM — concentration indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Hedge Ratio"
      display_name: "Average hedge ratio"
      expr: AVG(CAST(hedge_ratio_percentage AS DOUBLE))
      comment: "Average hedge ratio — risk mitigation coverage indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Correlation to Portfolio"
      display_name: "Average correlation to portfolio"
      expr: AVG(CAST(correlation_to_portfolio AS DOUBLE))
      comment: "Average correlation of exposure to portfolio — diversification indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Average ESG Carbon Intensity"
      display_name: "Average esg carbon intensity"
      expr: AVG(CAST(esg_carbon_intensity AS DOUBLE))
      comment: "Average ESG carbon intensity of exposures — climate exposure indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Total DV01 Price Sensitivity"
      display_name: "Total dv01 price sensitivity"
      expr: SUM(CAST(price_sensitivity_dv01 AS DOUBLE))
      comment: "Aggregate DV01 price sensitivity — interest/price risk indicator."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`naturalresource_harvest_plan`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Harvest planning KPIs for timber and agricultural assets covering planned vs actual volumes, economics and sustainability. Used by asset managers to monitor operational execution versus plan."
  source: "`asset_management`.`naturalresource`.`harvest_plan`"
  dimensions:
    - name: "Plan Status"
      display_name: "Plan status"
      expr: plan_status
      comment: "Status of the harvest plan."
    - name: "Plan Type"
      display_name: "Plan type"
      expr: plan_type
      comment: "Type of harvest plan."
    - name: "Species Type"
      display_name: "Species type"
      expr: species_type
      comment: "Species being harvested."
    - name: "Harvest Method"
      display_name: "Harvest method"
      expr: harvest_method
      comment: "Harvest method applied."
    - name: "Sustainability Certification"
      display_name: "Sustainability certification"
      expr: sustainability_certification
      comment: "Sustainability certification of the harvest."
    - name: "Regulatory Approval Status"
      display_name: "Regulatory approval status"
      expr: regulatory_approval_status
      comment: "Regulatory approval status of the plan."
    - name: "Plan Year"
      display_name: "Plan year"
      expr: plan_year
      comment: "Plan year for annual comparison."
  measures:
    - name: "Plan Count"
      display_name: "Plan count"
      expr: COUNT(1)
      comment: "Number of harvest plans."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Planned Harvest Volume"
      display_name: "Total planned harvest volume"
      expr: SUM(CAST(planned_harvest_volume AS DOUBLE))
      comment: "Aggregate planned harvest volume — operational target metric."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Actual Harvest Volume"
      display_name: "Total actual harvest volume"
      expr: SUM(CAST(actual_harvest_volume AS DOUBLE))
      comment: "Aggregate actual harvested volume — execution outcome metric."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Estimated Revenue"
      display_name: "Total estimated revenue"
      expr: SUM(CAST(estimated_revenue AS DOUBLE))
      comment: "Aggregate estimated harvest revenue."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Estimated Cost"
      display_name: "Total estimated cost"
      expr: SUM(CAST(estimated_cost AS DOUBLE))
      comment: "Aggregate estimated harvest cost."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Harvest Area"
      display_name: "Total harvest area"
      expr: SUM(CAST(harvest_area_hectares AS DOUBLE))
      comment: "Aggregate harvest area in hectares."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Average Yield per Hectare"
      display_name: "Average yield per hectare"
      expr: AVG(CAST(estimated_yield_per_hectare AS DOUBLE))
      comment: "Average estimated yield per hectare — land productivity indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Carbon Sequestration Impact"
      display_name: "Total carbon sequestration impact"
      expr: SUM(CAST(carbon_sequestration_impact AS DOUBLE))
      comment: "Aggregate carbon sequestration impact of harvest activity — ESG indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`naturalresource_operational_incident`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Operational and HSE incident KPIs covering financial impact, downtime, safety and environmental events. Used by risk and ESG committees to monitor operational risk across resource assets."
  source: "`asset_management`.`naturalresource`.`operational_incident`"
  dimensions:
    - name: "Incident Type"
      display_name: "Incident type"
      expr: incident_type
      comment: "Type of operational incident."
    - name: "Incident Status"
      display_name: "Incident status"
      expr: incident_status
      comment: "Status of the incident."
    - name: "Severity Level"
      display_name: "Severity level"
      expr: severity_level
      comment: "Severity classification of the incident."
    - name: "ESG Impact Category"
      display_name: "Esg impact category"
      expr: esg_impact_category
      comment: "ESG impact category of the incident."
    - name: "Investigation Status"
      display_name: "Investigation status"
      expr: investigation_status
      comment: "Investigation status of the incident."
    - name: "Incident Month"
      display_name: "Incident month"
      expr: DATE_TRUNC('month', incident_start_timestamp)
      comment: "Incident start bucketed to month for trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Incident Count"
      display_name: "Incident count"
      expr: COUNT(1)
      comment: "Number of operational incidents — operational risk volume indicator."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Estimated Financial Impact"
      display_name: "Total estimated financial impact"
      expr: SUM(CAST(estimated_financial_impact AS DOUBLE))
      comment: "Aggregate estimated financial impact of incidents."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Remediation Cost"
      display_name: "Total remediation cost"
      expr: SUM(CAST(remediation_cost AS DOUBLE))
      comment: "Aggregate remediation cost incurred from incidents."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Insurance Recovery"
      display_name: "Total insurance recovery"
      expr: SUM(CAST(insurance_recovery_amount AS DOUBLE))
      comment: "Aggregate insurance recovery against incidents."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Downtime Hours"
      display_name: "Total downtime hours"
      expr: SUM(CAST(downtime_hours AS DOUBLE))
      comment: "Aggregate downtime hours — operational disruption indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Fatalities"
      display_name: "Total fatalities"
      expr: SUM(CAST(fatality_count AS DOUBLE))
      comment: "Aggregate fatality count — critical HSE safety metric."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Injuries"
      display_name: "Total injuries"
      expr: SUM(CAST(injury_count AS DOUBLE))
      comment: "Aggregate injury count across incidents."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total GHG Emissions Impact"
      display_name: "Total ghg emissions impact"
      expr: SUM(CAST(ghg_emissions_impact AS DOUBLE))
      comment: "Aggregate GHG emissions impact from incidents — environmental damage indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Production Loss Volume"
      display_name: "Total production loss volume"
      expr: SUM(CAST(production_loss_volume AS DOUBLE))
      comment: "Aggregate lost production volume due to incidents."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`naturalresource_production_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Operational production and revenue performance KPIs per reporting period. Used to steer asset-level operating efficiency, realized pricing and ESG operating impact."
  source: "`asset_management`.`naturalresource`.`production_record`"
  dimensions:
    - name: "Resource Type"
      display_name: "Resource type"
      expr: resource_type
      comment: "Natural resource type being produced."
    - name: "Commodity Grade"
      display_name: "Commodity grade"
      expr: commodity_grade
      comment: "Quality grade of the produced commodity."
    - name: "Production Status"
      display_name: "Production status"
      expr: production_status
      comment: "Status of production for the period."
    - name: "Regulatory Compliance Status"
      display_name: "Regulatory compliance status"
      expr: regulatory_compliance_status
      comment: "Regulatory compliance status for the production period."
    - name: "Certification Type"
      display_name: "Certification type"
      expr: certification_type
      comment: "Sustainability/quality certification applied to production."
    - name: "Production Period Month"
      display_name: "Production period month"
      expr: DATE_TRUNC('month', reporting_period_end_date)
      comment: "Reporting period end bucketed to month for operational trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Production Record Count"
      display_name: "Production record count"
      expr: COUNT(1)
      comment: "Number of production records in scope."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Production Volume"
      display_name: "Total production volume"
      expr: SUM(CAST(production_volume AS DOUBLE))
      comment: "Aggregate produced volume — primary operational throughput metric."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Gross Revenue"
      display_name: "Total gross revenue"
      expr: SUM(CAST(gross_revenue AS DOUBLE))
      comment: "Aggregate gross revenue from production sales."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Operating Cost"
      display_name: "Total operating cost"
      expr: SUM(CAST(operating_cost AS DOUBLE))
      comment: "Aggregate operating cost of production."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Operating Income"
      display_name: "Total net operating income"
      expr: SUM(CAST(net_operating_income AS DOUBLE))
      comment: "Aggregate net operating income — core operating profitability driver."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Royalty Payment"
      display_name: "Total royalty payment"
      expr: SUM(CAST(royalty_payment AS DOUBLE))
      comment: "Aggregate royalty payments charged against production revenue."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Realized Price"
      display_name: "Average realized price"
      expr: AVG(CAST(realized_price_per_unit AS DOUBLE))
      comment: "Average realized price per unit — pricing performance indicator."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 4
    - name: "Average Price Realization Pct"
      display_name: "Average price realization pct"
      expr: AVG(CAST(price_realization_percentage AS DOUBLE))
      comment: "Average achieved price relative to benchmark — commercial execution quality."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Production Efficiency"
      display_name: "Average production efficiency"
      expr: AVG(CAST(production_efficiency_rate AS DOUBLE))
      comment: "Average production efficiency rate — operational performance indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total GHG Emissions"
      display_name: "Total ghg emissions"
      expr: SUM(CAST(ghg_emissions_tonnes_co2e AS DOUBLE))
      comment: "Aggregate GHG emissions from production — TCFD climate reporting input."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Safety Incidents"
      display_name: "Total safety incidents"
      expr: SUM(CAST(safety_incident_count AS DOUBLE))
      comment: "Aggregate count of safety incidents — operational HSE risk indicator."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Reserve Life"
      display_name: "Average reserve life"
      expr: AVG(CAST(reserve_life_years AS DOUBLE))
      comment: "Average remaining reserve life in years — asset longevity indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`naturalresource_reclamation_liability`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Asset retirement and reclamation liability KPIs covering present value, funding status and accretion. Used for IFRS liability reporting and environmental obligation governance."
  source: "`asset_management`.`naturalresource`.`reclamation_liability`"
  dimensions:
    - name: "Liability Type"
      display_name: "Liability type"
      expr: liability_type
      comment: "Type of reclamation liability."
    - name: "Liability Status"
      display_name: "Liability status"
      expr: liability_status
      comment: "Status of the reclamation liability."
    - name: "Funding Status"
      display_name: "Funding status"
      expr: funding_status
      comment: "Funding status of the obligation (e.g. funded, underfunded)."
    - name: "ESG Impact Category"
      display_name: "Esg impact category"
      expr: esg_impact_category
      comment: "ESG impact category of the liability."
    - name: "Jurisdiction"
      display_name: "Jurisdiction"
      expr: jurisdiction
      comment: "Regulatory jurisdiction of the obligation."
    - name: "Fair Value Hierarchy Level"
      display_name: "Fair value hierarchy level"
      expr: fair_value_hierarchy_level
      comment: "IFRS fair value hierarchy level of the liability measurement."
    - name: "Expected Settlement Year"
      display_name: "Expected settlement year"
      expr: DATE_TRUNC('year', expected_settlement_date)
      comment: "Expected settlement year of the obligation."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Liability Count"
      display_name: "Liability count"
      expr: COUNT(1)
      comment: "Number of reclamation liability records."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Present Value ARO"
      display_name: "Total present value aro"
      expr: SUM(CAST(present_value_aro AS DOUBLE))
      comment: "Aggregate present value of asset retirement obligations — core IFRS liability metric."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Undiscounted Cost Estimate"
      display_name: "Total undiscounted cost estimate"
      expr: SUM(CAST(undiscounted_cost_estimate AS DOUBLE))
      comment: "Aggregate undiscounted estimated reclamation cost."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Remaining Liability Balance"
      display_name: "Total remaining liability balance"
      expr: SUM(CAST(remaining_liability_balance AS DOUBLE))
      comment: "Aggregate remaining liability balance outstanding."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Actual Expenditure to Date"
      display_name: "Total actual expenditure to date"
      expr: SUM(CAST(actual_expenditure_to_date AS DOUBLE))
      comment: "Aggregate reclamation expenditure incurred to date."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Trust Fund Balance"
      display_name: "Total trust fund balance"
      expr: SUM(CAST(trust_fund_balance AS DOUBLE))
      comment: "Aggregate trust fund balance set aside — funding coverage indicator."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Reclamation Bond Amount"
      display_name: "Total reclamation bond amount"
      expr: SUM(CAST(reclamation_bond_amount AS DOUBLE))
      comment: "Aggregate reclamation bond posted against obligations."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Accretion Expense (Current)"
      display_name: "Total accretion expense (current)"
      expr: SUM(CAST(accretion_expense_current_period AS DOUBLE))
      comment: "Aggregate current-period accretion expense on ARO."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`naturalresource_reserve_estimate`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reserve estimate KPIs covering recoverable quantities, NPV and economic assumptions. Used to assess the long-term production value and resource base of natural resource assets."
  source: "`asset_management`.`naturalresource`.`reserve_estimate`"
  dimensions:
    - name: "Commodity Type"
      display_name: "Commodity type"
      expr: commodity_type
      comment: "Commodity associated with the reserve estimate."
    - name: "Reserve Category"
      display_name: "Reserve category"
      expr: reserve_category
      comment: "Reserve certainty category (e.g. proven, probable, possible)."
    - name: "Estimate Status"
      display_name: "Estimate status"
      expr: estimate_status
      comment: "Status of the reserve estimate."
    - name: "Estimation Method"
      display_name: "Estimation method"
      expr: estimation_method
      comment: "Method used to estimate reserves."
    - name: "Reporting Standard"
      display_name: "Reporting standard"
      expr: reporting_standard
      comment: "Reporting standard applied (e.g. SEC, PRMS)."
    - name: "Price Deck Scenario"
      display_name: "Price deck scenario"
      expr: price_deck_scenario
      comment: "Price deck scenario used in the estimate."
    - name: "Effective Year"
      display_name: "Effective year"
      expr: DATE_TRUNC('year', effective_date)
      comment: "Effective year of the reserve estimate."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Estimate Count"
      display_name: "Estimate count"
      expr: COUNT(1)
      comment: "Number of reserve estimate records."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Net Reserves"
      display_name: "Total net reserves"
      expr: SUM(CAST(net_reserves AS DOUBLE))
      comment: "Aggregate net recoverable reserves — core resource base metric."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Recoverable Quantity"
      display_name: "Total recoverable quantity"
      expr: SUM(CAST(recoverable_quantity AS DOUBLE))
      comment: "Aggregate recoverable quantity across estimates."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Estimated NPV"
      display_name: "Total estimated npv"
      expr: SUM(CAST(estimated_npv AS DOUBLE))
      comment: "Aggregate estimated net present value of reserves — valuation driver."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Capital Expenditure Estimate"
      display_name: "Total capital expenditure estimate"
      expr: SUM(CAST(capital_expenditure_estimate AS DOUBLE))
      comment: "Aggregate estimated capital expenditure to develop reserves."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Recovery Factor"
      display_name: "Average recovery factor"
      expr: AVG(CAST(recovery_factor_percent AS DOUBLE))
      comment: "Average recovery factor — extraction efficiency indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Reserve Life"
      display_name: "Average reserve life"
      expr: AVG(CAST(reserve_life_years AS DOUBLE))
      comment: "Average reserve life in years — asset longevity indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Average Confidence Level"
      display_name: "Average confidence level"
      expr: AVG(CAST(confidence_level_percent AS DOUBLE))
      comment: "Average confidence level of the estimate — certainty indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`naturalresource_resource_asset`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Portfolio-level KPIs for directly held natural resource assets covering valuation, acquisition economics, ESG and reserve coverage. Used by the CIO and real-assets team to steer capital allocation across commodity types and regions."
  source: "`asset_management`.`naturalresource`.`resource_asset`"
  dimensions:
    - name: "Resource Type"
      display_name: "Resource type"
      expr: resource_type
      comment: "High-level natural resource class (e.g. timber, oil & gas, mining, agriculture)."
    - name: "Resource Subtype"
      display_name: "Resource subtype"
      expr: resource_subtype
      comment: "Finer sub-classification of the resource asset."
    - name: "Geographic Region"
      display_name: "Geographic region"
      expr: geographic_region
      comment: "Region where the asset is located for geographic concentration analysis."
    - name: "Country Code"
      display_name: "Country code"
      expr: country_code
      comment: "ISO country code of asset location."
    - name: "Asset Status"
      display_name: "Asset status"
      expr: asset_status
      comment: "Lifecycle status of the asset (e.g. operating, development, divested)."
    - name: "ESG Rating"
      display_name: "Esg rating"
      expr: esg_rating
      comment: "Internal ESG rating band of the asset."
    - name: "Risk Rating"
      display_name: "Risk rating"
      expr: risk_rating
      comment: "Internal investment risk rating band."
    - name: "Investment Strategy"
      display_name: "Investment strategy"
      expr: investment_strategy
      comment: "Investment strategy category for the asset."
    - name: "Reserve Classification"
      display_name: "Reserve classification"
      expr: reserve_classification
      comment: "Reserve certainty classification (e.g. proven, probable)."
    - name: "Acquisition Year"
      display_name: "Acquisition year"
      expr: DATE_TRUNC('year', acquisition_date)
      comment: "Year the asset was acquired, for vintage analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Valuation Month"
      display_name: "Valuation month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Month of the latest valuation for time-series tracking."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Asset Count"
      display_name: "Asset count"
      expr: COUNT(1)
      comment: "Number of natural resource asset records."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Current Valuation"
      display_name: "Total current valuation"
      expr: SUM(CAST(current_valuation AS DOUBLE))
      comment: "Aggregate fair value of natural resource assets — core NAV driver for the real-assets sleeve."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Acquisition Cost"
      display_name: "Total acquisition cost"
      expr: SUM(CAST(acquisition_cost AS DOUBLE))
      comment: "Aggregate historical acquisition cost of assets held."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Unrealized Value Gain"
      display_name: "Unrealized value gain"
      expr: SUM(CAST(current_valuation AS DOUBLE) - CAST(acquisition_cost AS DOUBLE))
      comment: "Difference between current valuation and acquisition cost — unrealized appreciation on held assets."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Ownership Percentage"
      display_name: "Average ownership percentage"
      expr: AVG(CAST(ownership_percentage AS DOUBLE))
      comment: "Average equity ownership stake across assets — indicates control/co-investment posture."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Carbon Footprint"
      display_name: "Total carbon footprint"
      expr: SUM(CAST(carbon_footprint AS DOUBLE))
      comment: "Aggregate carbon footprint of held assets — key TCFD/SFDR climate exposure metric."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Reserve Quantity"
      display_name: "Total reserve quantity"
      expr: SUM(CAST(reserve_quantity AS DOUBLE))
      comment: "Aggregate certified reserve quantity underpinning long-term production value."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Insurance Coverage"
      display_name: "Total insurance coverage"
      expr: SUM(CAST(insurance_coverage AS DOUBLE))
      comment: "Aggregate insurance coverage on assets — operational risk mitigation indicator."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Discount Rate"
      display_name: "Average discount rate"
      expr: AVG(CAST(discount_rate AS DOUBLE))
      comment: "Average valuation discount rate applied across assets."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`naturalresource_resource_cashflow`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Cash flow KPIs for natural resource assets covering revenue, operating expenditure, capital expenditure and distributions. Used by treasury and portfolio teams to monitor cash generation and capital intensity."
  source: "`asset_management`.`naturalresource`.`resource_cashflow`"
  dimensions:
    - name: "Cashflow Type"
      display_name: "Cashflow type"
      expr: cashflow_type
      comment: "Type of cash flow (e.g. revenue, capital call, distribution)."
    - name: "Cashflow Category"
      display_name: "Cashflow category"
      expr: cashflow_category
      comment: "Category classification of the cash flow."
    - name: "Cashflow Status"
      display_name: "Cashflow status"
      expr: cashflow_status
      comment: "Processing status of the cash flow."
    - name: "Commodity Type"
      display_name: "Commodity type"
      expr: commodity_type
      comment: "Commodity associated with the cash flow."
    - name: "Currency Code"
      display_name: "Currency code"
      expr: currency_code
      comment: "Transaction currency of the cash flow."
    - name: "Transaction Month"
      display_name: "Transaction month"
      expr: DATE_TRUNC('month', transaction_date)
      comment: "Transaction date bucketed to month for cash trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Cashflow Count"
      display_name: "Cashflow count"
      expr: COUNT(1)
      comment: "Number of cash flow records."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Net Cashflow (Base)"
      display_name: "Total net cashflow (base)"
      expr: SUM(CAST(net_cashflow_base_amount AS DOUBLE))
      comment: "Aggregate net cash flow in base currency — overall cash generation metric."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Gross Revenue"
      display_name: "Total gross revenue"
      expr: SUM(CAST(gross_revenue_amount AS DOUBLE))
      comment: "Aggregate gross revenue cash inflow."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Operating Expense"
      display_name: "Total operating expense"
      expr: SUM(CAST(operating_expense_amount AS DOUBLE))
      comment: "Aggregate operating expenditure cash outflow."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Capital Expenditure"
      display_name: "Total capital expenditure"
      expr: SUM(CAST(capital_expenditure_amount AS DOUBLE))
      comment: "Aggregate capital expenditure — capital intensity indicator for real assets."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Royalty Amount"
      display_name: "Total royalty amount"
      expr: SUM(CAST(royalty_amount AS DOUBLE))
      comment: "Aggregate royalty cash outflow against production."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Tax Amount"
      display_name: "Total tax amount"
      expr: SUM(CAST(tax_amount AS DOUBLE))
      comment: "Aggregate tax cash outflow on resource cash flows."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Reclamation Contribution"
      display_name: "Total reclamation contribution"
      expr: SUM(CAST(reclamation_contribution_amount AS DOUBLE))
      comment: "Aggregate funding contributions to reclamation obligations."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Disputed Cashflow Count"
      display_name: "Disputed cashflow count"
      expr: SUM(CASE WHEN dispute_flag = TRUE THEN 1 ELSE 0 END)
      comment: "Count of disputed cash flows — settlement risk indicator."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`naturalresource_resource_fund_commitment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fund commitment KPIs for natural resource investment vehicles covering commitment, deployment, NAV and return multiples. Used by the investment committee for commitment pacing and manager performance review."
  source: "`asset_management`.`naturalresource`.`resource_fund_commitment`"
  dimensions:
    - name: "Commitment Status"
      display_name: "Commitment status"
      expr: commitment_status
      comment: "Status of the fund commitment."
    - name: "Fund Strategy"
      display_name: "Fund strategy"
      expr: fund_strategy
      comment: "Investment strategy of the fund."
    - name: "ESG Classification"
      display_name: "Esg classification"
      expr: esg_classification
      comment: "SFDR/ESG classification of the fund."
    - name: "Geographic Focus"
      display_name: "Geographic focus"
      expr: geographic_focus
      comment: "Geographic focus of the fund."
    - name: "GP Name"
      display_name: "Gp name"
      expr: gp_name
      comment: "General partner name managing the fund."
    - name: "Vintage Year"
      display_name: "Vintage year"
      expr: vintage_year
      comment: "Vintage year of the commitment for cohort analysis."
    - name: "Commitment Month"
      display_name: "Commitment month"
      expr: DATE_TRUNC('month', commitment_date)
      comment: "Commitment date bucketed to month for pacing trends."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Commitment Count"
      display_name: "Commitment count"
      expr: COUNT(1)
      comment: "Number of fund commitments."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Commitment Amount"
      display_name: "Total commitment amount"
      expr: SUM(CAST(commitment_amount AS DOUBLE))
      comment: "Aggregate committed capital to natural resource funds."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Paid-In Capital"
      display_name: "Total paid-in capital"
      expr: SUM(CAST(paid_in_capital AS DOUBLE))
      comment: "Aggregate capital drawn down into funds."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unfunded Commitment"
      display_name: "Total unfunded commitment"
      expr: SUM(CAST(unfunded_commitment AS DOUBLE))
      comment: "Aggregate undrawn commitment — future liquidity obligation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Distributions Received"
      display_name: "Total distributions received"
      expr: SUM(CAST(distributions_received AS DOUBLE))
      comment: "Aggregate distributions received from funds."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total NAV"
      display_name: "Total nav"
      expr: SUM(CAST(nav AS DOUBLE))
      comment: "Aggregate net asset value of fund commitments."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average IRR"
      display_name: "Average irr"
      expr: AVG(CAST(irr AS DOUBLE))
      comment: "Average fund-level internal rate of return — primary manager performance KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average TVPI"
      display_name: "Average tvpi"
      expr: AVG(CAST(tvpi AS DOUBLE))
      comment: "Average total value to paid-in multiple across funds."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Average DPI"
      display_name: "Average dpi"
      expr: AVG(CAST(dpi AS DOUBLE))
      comment: "Average distributions to paid-in multiple — realized return indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`naturalresource_resource_holding`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fund-style holding performance KPIs for natural resource vehicle commitments covering NAV, capital deployment and return multiples. Used by the investment committee to evaluate fund-level performance."
  source: "`asset_management`.`naturalresource`.`resource_holding`"
  dimensions:
    - name: "Holding Type"
      display_name: "Holding type"
      expr: holding_type
      comment: "Type of holding (e.g. direct, fund, co-investment)."
    - name: "Holding Status"
      display_name: "Holding status"
      expr: holding_status
      comment: "Lifecycle status of the holding."
    - name: "Resource Asset Class"
      display_name: "Resource asset class"
      expr: resource_asset_class
      comment: "Resource asset class of the holding."
    - name: "Resource Sub Class"
      display_name: "Resource sub class"
      expr: resource_sub_class
      comment: "Resource sub-class of the holding."
    - name: "Geographic Focus"
      display_name: "Geographic focus"
      expr: geographic_focus
      comment: "Geographic focus of the holding."
    - name: "Investment Strategy"
      display_name: "Investment strategy"
      expr: investment_strategy
      comment: "Investment strategy of the holding."
    - name: "ESG Rating"
      display_name: "Esg rating"
      expr: esg_rating
      comment: "ESG rating band of the holding."
    - name: "Vintage Year"
      display_name: "Vintage year"
      expr: vintage_year
      comment: "Vintage year of the holding for cohort performance analysis."
  measures:
    - name: "Holding Count"
      display_name: "Holding count"
      expr: COUNT(1)
      comment: "Number of natural resource holdings."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total NAV"
      display_name: "Total nav"
      expr: SUM(CAST(nav_amount AS DOUBLE))
      comment: "Aggregate net asset value of holdings — core valuation metric."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Committed Capital"
      display_name: "Total committed capital"
      expr: SUM(CAST(committed_capital_amount AS DOUBLE))
      comment: "Aggregate committed capital across holdings."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Paid-In Capital"
      display_name: "Total paid-in capital"
      expr: SUM(CAST(paid_in_capital_amount AS DOUBLE))
      comment: "Aggregate capital drawn down into holdings."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Unfunded Commitment"
      display_name: "Total unfunded commitment"
      expr: SUM(CAST(unfunded_commitment_amount AS DOUBLE))
      comment: "Aggregate undrawn commitment — future liquidity obligation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Cumulative Distributions"
      display_name: "Total cumulative distributions"
      expr: SUM(CAST(cumulative_distributions_amount AS DOUBLE))
      comment: "Aggregate cumulative distributions received from holdings."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average IRR"
      display_name: "Average irr"
      expr: AVG(CAST(irr_percentage AS DOUBLE))
      comment: "Average internal rate of return across holdings — primary return KPI."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average TVPI"
      display_name: "Average tvpi"
      expr: AVG(CAST(tvpi_multiple AS DOUBLE))
      comment: "Average total value to paid-in multiple — total value creation indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Average DPI"
      display_name: "Average dpi"
      expr: AVG(CAST(dpi_multiple AS DOUBLE))
      comment: "Average distributions to paid-in multiple — realized return indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Average MOIC"
      display_name: "Average moic"
      expr: AVG(CAST(moic_multiple AS DOUBLE))
      comment: "Average multiple on invested capital."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Carbon Footprint (Tonnes)"
      display_name: "Total carbon footprint (tonnes)"
      expr: SUM(CAST(carbon_footprint_tonnes AS DOUBLE))
      comment: "Aggregate carbon footprint of holdings — climate exposure reporting input."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`naturalresource_resource_valuation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fair-value and valuation-movement KPIs for natural resource assets covering fair value, valuation change and key valuation assumptions. Used for IFRS reporting and valuation governance."
  source: "`asset_management`.`naturalresource`.`resource_valuation`"
  dimensions:
    - name: "Valuation Method"
      display_name: "Valuation method"
      expr: valuation_method
      comment: "Valuation methodology applied (e.g. DCF, comparable transactions)."
    - name: "Valuation Status"
      display_name: "Valuation status"
      expr: valuation_status
      comment: "Status of the valuation record."
    - name: "Fair Value Hierarchy Level"
      display_name: "Fair value hierarchy level"
      expr: fair_value_hierarchy_level
      comment: "IFRS fair value hierarchy level (Level 1/2/3)."
    - name: "Valuation Frequency"
      display_name: "Valuation frequency"
      expr: valuation_frequency
      comment: "Frequency at which the asset is valued."
    - name: "Geopolitical Risk Rating"
      display_name: "Geopolitical risk rating"
      expr: geopolitical_risk_rating
      comment: "Geopolitical risk rating applied in the valuation."
    - name: "Currency Code"
      display_name: "Currency code"
      expr: currency_code
      comment: "Currency of the valuation."
    - name: "Valuation Month"
      display_name: "Valuation month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Valuation date bucketed to month for valuation trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Valuation Count"
      display_name: "Valuation count"
      expr: COUNT(1)
      comment: "Number of valuation records."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Fair Value"
      display_name: "Total fair value"
      expr: SUM(CAST(fair_value_amount AS DOUBLE))
      comment: "Aggregate fair value across valuations — core IFRS NAV input."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Prior Valuation"
      display_name: "Total prior valuation"
      expr: SUM(CAST(prior_valuation_amount AS DOUBLE))
      comment: "Aggregate prior-period valuation for movement comparison."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Valuation Change"
      display_name: "Total valuation change"
      expr: SUM(CAST(valuation_change_amount AS DOUBLE))
      comment: "Aggregate valuation change amount — portfolio revaluation movement."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Valuation Change Pct"
      display_name: "Average valuation change pct"
      expr: AVG(CAST(valuation_change_percentage AS DOUBLE))
      comment: "Average percentage valuation movement — revaluation volatility indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Discount Rate"
      display_name: "Average discount rate"
      expr: AVG(CAST(discount_rate AS DOUBLE))
      comment: "Average discount rate assumption used in valuations."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Liquidity Discount"
      display_name: "Average liquidity discount"
      expr: AVG(CAST(liquidity_discount AS DOUBLE))
      comment: "Average liquidity discount applied — illiquidity haircut indicator."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Reserve Life"
      display_name: "Average reserve life"
      expr: AVG(CAST(reserve_life_years AS DOUBLE))
      comment: "Average assumed reserve life in years underpinning valuations."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Average Carbon Price Assumption"
      display_name: "Average carbon price assumption"
      expr: AVG(CAST(carbon_price_assumption AS DOUBLE))
      comment: "Average carbon price assumption used in valuation scenarios."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`naturalresource_royalty_payment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Royalty payment KPIs covering gross revenue basis, net payments, deductions and withholding tax. Used to monitor royalty outflows and counterparty/tax exposure on resource production."
  source: "`asset_management`.`naturalresource`.`royalty_payment`"
  dimensions:
    - name: "Payment Status"
      display_name: "Payment status"
      expr: payment_status
      comment: "Status of the royalty payment."
    - name: "Payment Method"
      display_name: "Payment method"
      expr: payment_method
      comment: "Method used for the royalty payment."
    - name: "Base Currency Code"
      display_name: "Base currency code"
      expr: base_currency_code
      comment: "Base reporting currency of the payment."
    - name: "Production Unit of Measure"
      display_name: "Production unit of measure"
      expr: production_unit_of_measure
      comment: "Unit of measure for production underlying the royalty."
    - name: "Payment Month"
      display_name: "Payment month"
      expr: DATE_TRUNC('month', payment_date)
      comment: "Payment date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Payment Count"
      display_name: "Payment count"
      expr: COUNT(1)
      comment: "Number of royalty payment records."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Net Payment"
      display_name: "Total net payment"
      expr: SUM(CAST(net_payment_amount AS DOUBLE))
      comment: "Aggregate net royalty payment amount — primary royalty outflow metric."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Royalty Amount (Base)"
      display_name: "Total royalty amount (base)"
      expr: SUM(CAST(royalty_amount_base AS DOUBLE))
      comment: "Aggregate royalty amount in base currency."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Gross Revenue Basis"
      display_name: "Total gross revenue basis"
      expr: SUM(CAST(gross_revenue_base AS DOUBLE))
      comment: "Aggregate gross revenue basis on which royalties are computed."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Deductions"
      display_name: "Total deductions"
      expr: SUM(CAST(deduction_amount AS DOUBLE))
      comment: "Aggregate deductions applied to royalty computation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Withholding Tax"
      display_name: "Total withholding tax"
      expr: SUM(CAST(withholding_tax_amount AS DOUBLE))
      comment: "Aggregate withholding tax on royalty payments — tax leakage indicator."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Royalty Rate"
      display_name: "Average royalty rate"
      expr: AVG(CAST(royalty_rate AS DOUBLE))
      comment: "Average effective royalty rate applied."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Disputed Payment Count"
      display_name: "Disputed payment count"
      expr: SUM(CASE WHEN dispute_flag = TRUE THEN 1 ELSE 0 END)
      comment: "Count of disputed royalty payments — payment risk indicator."
      format:
        type: number
        decimal_places:
          type: all
$$;
