-- Schema for Domain: naturalresource | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:27

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`naturalresource` COMMENT 'Domain for natural resources and commodities investment operations including timberland, farmland, mining, energy, and commodity-linked fund investments. Owns resource asset records, production data, commodity price exposures, depletion schedules, and';
ALTER SCHEMA `asset_management`.`naturalresource` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `asset_management`.`naturalresource` SET TAGS ('dbx_domain' = 'naturalresource');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`resource_asset` (
    `resource_asset_id` BIGINT COMMENT 'Unique identifier for the natural resource asset. Primary key for timberland parcels, farmland tracts, mining concessions, energy assets (upstream oil & gas, renewables), and other physical resource holdings.',
    `asset_manager_gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Asset manager assignment is required for performance reporting and regulatory compliance.',
    `audit_finding_id` BIGINT COMMENT 'Foreign key linking to compliance.audit_finding. Business justification: Audit findings related to asset operations.',
    `certification_id` BIGINT COMMENT 'Foreign key linking to compliance.certification. Business justification: Certifications (ISO, etc.) for asset.',
    `country_outlook_id` BIGINT COMMENT 'Foreign key linking to research.country_outlook. Business justification: Country risk assessment for each asset is driven by the country outlook.',
    `gips_compliance_record_id` BIGINT COMMENT 'Foreign key linking to compliance.gips_compliance_record. Business justification: GIPS compliance record for asset performance reporting.',
    `operator_actor_id` BIGINT COMMENT 'Foreign key linking to shared.actor. Business justification: Captures operator entity for regulatory and ESG reporting, required for compliance and reporting.',
    `policy_document_id` BIGINT COMMENT 'Foreign key linking to compliance.policy_document. Business justification: Asset‑specific ESG policy documents.',
    `project_investment_id` BIGINT COMMENT 'Foreign key linking to infrastructure.project_investment. Business justification: The pension fund tracks natural resource assets as part of project investments; linking them enables consolidated reporting of project performance and ESG metrics.',
    `sfdr_disclosure_id` BIGINT COMMENT 'Foreign key linking to compliance.sfdr_disclosure. Business justification: SFDR disclosure for asset sustainability metrics.',
    `acquisition_cost` DECIMAL(18,2) COMMENT 'Total cost paid to acquire the resource asset, including purchase price and direct acquisition expenses, in base currency (USD).',
    `acquisition_date` DATE COMMENT 'Date on which the pension fund acquired ownership or control of the natural resource asset.',
    `annual_production_capacity` DECIMAL(18,2) COMMENT 'Estimated annual production or harvest capacity of the resource asset in the unit specified by production_unit_of_measure.',
    `area_unit_of_measure` STRING COMMENT 'Unit of measure for the total_area field.. Valid values are `acres|hectares|square_kilometers|square_miles`',
    `asset_identifier` STRING COMMENT 'Externally-recognized unique code or registration number for the resource asset (e.g., cadastral parcel ID, mining concession number, lease block identifier, title deed reference).',
    `asset_name` STRING COMMENT 'Human-readable name or designation of the natural resource asset (e.g., Cascade Timberland Tract, Permian Basin Block 7, Iowa Farmland Portfolio A).',
    `asset_status` STRING COMMENT 'Current operational and ownership status of the resource asset within the portfolio.. Valid values are `active|under_development|dormant|divested|held_for_sale|retired`',
    `carbon_footprint` DECIMAL(18,2) COMMENT 'Estimated annual greenhouse gas (GHG) emissions attributable to the resource asset, measured in tonnes of CO2 equivalent.',
    `country_code` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code where the resource asset is physically located.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this resource asset record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary values associated with this asset.. Valid values are `^[A-Z]{3}$`',
    `current_valuation` DECIMAL(18,2) COMMENT 'Most recent fair market value or Net Asset Value (NAV) of the resource asset in base currency (USD).',
    `data_source_system` STRING COMMENT 'Name of the operational system of record from which this resource asset data originated (e.g., eFront, SimCorp Dimension, Internal Asset Register).',
    `depletion_method` STRING COMMENT 'Accounting method used to allocate the cost of the resource asset over its productive life.. Valid values are `units_of_production|straight_line|declining_balance|not_applicable`',
    `discount_rate` DECIMAL(5,2) COMMENT 'Discount rate or Weighted Average Cost of Capital (WACC) used in valuation models for this resource asset, expressed as a percentage.',
    `environmental_certification` STRING COMMENT 'Environmental or sustainability certifications held by the resource asset (e.g., FSC for timberland, ISO 14001, LEED, organic certification for farmland).',
    `esg_rating` STRING COMMENT 'Overall ESG rating or score assigned to the resource asset by internal or external ESG assessment (e.g., MSCI ESG rating, internal sustainability score).',
    `estimated_useful_life_years` BIGINT COMMENT 'Estimated remaining productive life of the resource asset in years, based on current reserve estimates and production rates.',
    `geographic_region` STRING COMMENT 'Primary geographic region or jurisdiction where the resource asset is located (e.g., North America, Latin America, Asia Pacific).',
    `insurance_coverage` DECIMAL(18,2) COMMENT 'Total insurance coverage amount for the resource asset, including property, liability, and operational risk insurance, in base currency (USD).',
    `investment_strategy` STRING COMMENT 'Investment strategy or mandate under which this resource asset was acquired (e.g., Core Natural Resources, Opportunistic Energy, Sustainable Timberland).',
    `last_inspection_date` DATE COMMENT 'Date of the most recent physical inspection, audit, or operational review of the resource asset.',
    `latitude` DECIMAL(10,7) COMMENT 'Geographic latitude coordinate of the resource asset centroid in decimal degrees (WGS84).',
    `longitude` DECIMAL(10,7) COMMENT 'Geographic longitude coordinate of the resource asset centroid in decimal degrees (WGS84).',
    `next_inspection_date` DATE COMMENT 'Scheduled date for the next physical inspection, audit, or operational review of the resource asset.',
    `operator_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the operator of the resource asset.. Valid values are `^[A-Z0-9]{20}$`',
    `operator_name` STRING COMMENT 'Name of the entity responsible for day-to-day operations and management of the resource asset (may be the pension fund or a third-party operator).',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage of economic interest or ownership held by the pension fund in this resource asset (0.00 to 100.00).',
    `ownership_structure` STRING COMMENT 'Legal structure of the pension funds ownership interest in the resource asset.. Valid values are `direct|joint_venture|partnership|leasehold|royalty_interest`',
    `permit_expiry_date` DATE COMMENT 'Expiration date of the primary regulatory permit or concession for the resource asset.',
    `production_unit_of_measure` STRING COMMENT 'Unit of measure for annual_production_capacity (e.g., barrels_per_day, tonnes_per_year, megawatt_hours).',
    `productive_area` DECIMAL(18,2) COMMENT 'Portion of total area that is actively productive or economically harvestable, in the same unit as total_area.',
    `regulatory_permits` STRING COMMENT 'Key regulatory permits, licenses, or concessions held for the operation of the resource asset (e.g., mining permit, drilling license, water rights).',
    `reserve_classification` STRING COMMENT 'Confidence classification of the reserve estimate per industry standards (e.g., PRMS for oil & gas, JORC for mining).. Valid values are `proven|probable|possible|inferred|measured|indicated`',
    `reserve_quantity` DECIMAL(18,2) COMMENT 'Estimated proven or probable reserves of the resource (e.g., barrels of oil, cubic meters of timber, tonnes of ore) in the unit specified by reserve_unit_of_measure.',
    `reserve_unit_of_measure` STRING COMMENT 'Unit of measure for reserve_quantity (e.g., barrels, cubic_meters, tonnes, board_feet).',
    `resource_subtype` STRING COMMENT 'Detailed sub-classification within the resource type (e.g., softwood timberland, row crop farmland, gold mining, offshore oil, solar farm, wind farm).',
    `resource_type` STRING COMMENT 'Primary classification of the natural resource asset by resource category.. Valid values are `timberland|farmland|mining|upstream_oil_gas|renewable_energy|water_rights`',
    `risk_rating` STRING COMMENT 'Overall risk rating assigned to the resource asset based on operational, environmental, regulatory, and market risk factors.. Valid values are `low|medium|high|critical`',
    `state_province` STRING COMMENT 'State, province, or first-level administrative division where the resource asset is located.',
    `total_area` DECIMAL(18,2) COMMENT 'Total physical area or acreage of the resource asset in the unit specified by area_unit_of_measure.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this resource asset record was last modified in the system.',
    `valuation_date` DATE COMMENT 'Date of the most recent independent valuation or appraisal of the resource asset.',
    `valuation_method` STRING COMMENT 'Primary valuation methodology used to determine current_valuation (e.g., Discounted Cash Flow (DCF), comparable sales, income approach).. Valid values are `dcf|comparable_sales|income_approach|cost_approach|market_approach`',
    CONSTRAINT pk_resource_asset PRIMARY KEY(`resource_asset_id`)
) COMMENT 'SSOT for natural resource asset identity within the naturalresource domain. Master record for each physical resource asset held by the pension fund: timberland parcels, farmland tracts, mining concessions, energy assets (upstream oil & gas, renewables)';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`resource_holding` (
    `resource_holding_id` BIGINT COMMENT 'Unique identifier for the natural resource holding record. Primary key for the resource holding entity.',
    `cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: Each resource holding has a dedicated cash account for holding-level cash flows and settlement.',
    `general_partner_actor_id` BIGINT COMMENT 'Foreign key linking to shared.actor. Business justification: Links general partner legal entity for capital call, fee calculation, and compliance monitoring.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the general partner or fund manager responsible for managing this natural resource investment vehicle.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the general partner or fund manager responsible for managing this natural resource investment vehicle.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio to which this resource holding is allocated.',
    `resource_vehicle_id` BIGINT COMMENT 'Reference to the natural resource investment vehicle or fund in which the pension fund holds an economic interest.',
    `carbon_footprint_tonnes` DECIMAL(18,2) COMMENT 'Estimated annual carbon footprint of the natural resource holding, measured in metric tonnes of CO2 equivalent emissions.',
    `commitment_date` DATE COMMENT 'Date on which the pension fund committed capital to this natural resource investment vehicle or asset, typically the Limited Partnership Agreement (LPA) signing date or acquisition agreement date.',
    `committed_capital_amount` DECIMAL(18,2) COMMENT 'Total capital amount committed by the pension fund to this natural resource holding, representing the maximum obligation under the investment agreement.',
    `committed_capital_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the committed capital amount.. Valid values are `^[A-Z]{3}$`',
    `commodity_price_exposure` STRING COMMENT 'Primary commodity or commodities to which this natural resource holding has price exposure, such as timber, corn, gold, crude oil, or natural gas.',
    `cost_basis_amount` DECIMAL(18,2) COMMENT 'Original acquisition cost or book value of the natural resource holding, used for gain/loss calculation and accounting purposes.',
    `cumulative_distributions_amount` DECIMAL(18,2) COMMENT 'Total distributions received by the pension fund from this natural resource holding since inception, including income, return of capital, and realized gains.',
    `custodian_code` BIGINT COMMENT 'Reference to the custodian bank or fund administrator holding legal custody of the investment documents and assets.',
    `depletion_method` STRING COMMENT 'Accounting method used to allocate the cost of natural resource extraction over the assets productive life: units of production, straight-line, declining balance, or not applicable for non-depleting assets.. Valid values are `units_of_production|straight_line|declining_balance|not_applicable`',
    `depletion_rate_percentage` DECIMAL(5,2) COMMENT 'Annual depletion rate applied to the natural resource asset for accounting and valuation purposes, expressed as a percentage.',
    `dpi_multiple` DECIMAL(5,2) COMMENT 'Cash-on-cash return metric calculated as cumulative distributions divided by paid-in capital, indicating realized return multiple.',
    `economic_interest_percentage` DECIMAL(5,2) COMMENT 'Percentage of economic returns (distributions, profits, carried interest) to which the pension fund is entitled, which may differ from legal ownership percentage due to waterfall structures.',
    `esg_rating` STRING COMMENT 'ESG rating assigned to this natural resource holding by internal or external ESG assessment, reflecting environmental stewardship, social responsibility, and governance quality.',
    `expected_harvest_date` DATE COMMENT 'Anticipated date for major harvest or production event for the natural resource asset, such as timber harvest, crop harvest, or mine production commencement.',
    `fund_term_years` BIGINT COMMENT 'Total term of the natural resource fund or investment vehicle in years, including any extension periods, as specified in the Limited Partnership Agreement.',
    `geographic_focus` STRING COMMENT 'Primary geographic region or country where the natural resource assets are located, using three-letter ISO country codes or regional descriptors.',
    `holding_status` STRING COMMENT 'Current lifecycle status of the resource holding: active management, committed but not yet funded, partially funded with remaining capital calls expected, fully funded, in harvesting or production phase, under divestment process, or fully exited.',
    `holding_type` STRING COMMENT 'Classification of the natural resource holding structure: direct ownership of physical assets, limited partner commitment to a fund, co-investment alongside a sponsor, fund of funds allocation, secondary market purchase, or joint venture participation.. Valid values are `direct_asset|lp_commitment|co_investment|fund_of_funds|secondary|joint_venture`',
    `investment_strategy` STRING COMMENT 'Description of the investment strategy employed for this natural resource holding, such as sustainable forestry, organic farmland, precious metals exploration, renewable energy infrastructure, or commodity arbitrage.',
    `irr_percentage` DECIMAL(5,2) COMMENT 'Annualized internal rate of return on the natural resource holding, calculated using cash flows and current NAV.',
    `is_co_investment` BOOLEAN COMMENT 'Boolean flag indicating whether this holding represents a co-investment alongside a general partner or lead investor, typically with reduced or no management fees.',
    `last_capital_call_date` DATE COMMENT 'Date of the most recent capital call or drawdown notice issued by the general partner for this natural resource holding.',
    `legal_entity_identifier` STRING COMMENT '20-character ISO 17442 Legal Entity Identifier for the investment vehicle or holding entity, enabling global entity identification.. Valid values are `^[A-Z0-9]{20}$`',
    `maturity_date` DATE COMMENT 'Expected maturity or termination date of the natural resource investment vehicle or holding, after which final distributions and liquidation occur.',
    `moic_multiple` DECIMAL(5,2) COMMENT 'Gross return multiple calculated as total value divided by total invested capital, synonymous with TVPI for most holdings.',
    `nav_amount` DECIMAL(18,2) COMMENT 'Current net asset value of the pension funds holding in this natural resource investment, representing fair market value of the position.',
    `nav_as_of_date` DATE COMMENT 'Valuation date for the reported NAV amount, typically quarter-end or month-end.',
    `next_valuation_date` DATE COMMENT 'Scheduled date for the next formal valuation of the natural resource holding, typically quarterly or annually.',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage ownership interest held by the pension fund in the natural resource vehicle or asset, expressed as a decimal percentage.',
    `paid_in_capital_amount` DECIMAL(18,2) COMMENT 'Cumulative capital actually drawn down and invested in the natural resource holding to date, also known as PIC.',
    `production_unit` STRING COMMENT 'Unit of measure for production volume, such as board feet, metric tons, bushels, barrels, cubic meters, or troy ounces.',
    `production_volume` DECIMAL(18,2) COMMENT 'Current or projected annual production volume from the natural resource asset, measured in asset-specific units such as board feet for timber, bushels for crops, ounces for precious metals, or barrels for oil.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this resource holding record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this resource holding record was last modified in the system.',
    `resource_asset_class` STRING COMMENT 'Primary natural resource asset class category for this holding: timberland, farmland, mining operations, energy assets, or commodity-linked investments.. Valid values are `timberland|farmland|mining|energy|commodity_linked`',
    `resource_sub_class` STRING COMMENT 'Detailed sub-classification within the resource asset class, such as softwood timberland, row crop farmland, precious metals mining, oil and gas upstream, or commodity futures strategy.',
    `rvpi_multiple` DECIMAL(5,2) COMMENT 'Unrealized value metric calculated as current NAV divided by paid-in capital, indicating remaining value multiple.',
    `sustainability_certification` STRING COMMENT 'Sustainability or environmental certification held by the natural resource asset, such as Forest Stewardship Council (FSC) for timberland, USDA Organic for farmland, or Responsible Mining Initiative certification.',
    `total_value_amount` DECIMAL(18,2) COMMENT 'Sum of current NAV and cumulative distributions, representing the total value generated by the holding to date.',
    `tvpi_multiple` DECIMAL(5,2) COMMENT 'Performance metric calculated as total value divided by paid-in capital, indicating the gross return multiple on invested capital.',
    `unfunded_commitment_amount` DECIMAL(18,2) COMMENT 'Remaining uncalled committed capital available for future capital calls, commonly referred to as dry powder. Calculated as committed capital minus paid-in capital.',
    `valuation_methodology` STRING COMMENT 'Primary valuation approach used for this natural resource holding, such as discounted cash flow (DCF), comparable transactions, net asset value (NAV), or resource-specific models like stumpage value for timber or reserve-based valuation for mining.',
    `vintage_year` BIGINT COMMENT 'Year in which the initial capital commitment was made or the fund was established, used for cohort performance analysis and benchmarking.',
    CONSTRAINT pk_resource_holding PRIMARY KEY(`resource_holding_id`)
) COMMENT 'SSOT for the pension funds economic interest in each natural resource vehicle — both direct asset holdings and LP/fund commitments. Tracks committed capital, invested capital (PIC), remaining unfunded commitment (dry powder), ownership percentage';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`production_record` (
    `production_record_id` BIGINT COMMENT 'Unique identifier for the production record. Primary key for the production record entity.',
    `resource_asset_id` BIGINT COMMENT 'Foreign key reference to the specific natural resource asset (timberland, farmland, mining site, oil/gas field) that generated this production output.',
    `audit_completion_date` DATE COMMENT 'Date when external audit or verification of the production record was completed. Marks transition to final status for NAV purposes.',
    `auditor_name` STRING COMMENT 'Name of the external audit firm or independent verifier that validated the production data. Provides audit trail for compliance and investor reporting.',
    `auditor_verification_flag` BOOLEAN COMMENT 'Indicates whether the production record has been independently verified by external auditors. Required for final NAV calculation and regulatory reporting.',
    `benchmark_commodity_price` DECIMAL(18,4) COMMENT 'Market benchmark price for the commodity during the reporting period (e.g., WTI crude, LME copper, regional timber index). Used for performance attribution and variance analysis.',
    `certification_type` STRING COMMENT 'Type of sustainability or responsible sourcing certification held by the asset (e.g., FSC for timber, organic certification for farmland, Equator Principles for mining). Enhances ESG profile and market access.',
    `commodity_grade` STRING COMMENT 'Quality classification or grade of the produced commodity. Affects pricing and marketability (e.g., timber grade, ore purity, crude oil API gravity, crop quality).',
    `contract_reference_number` STRING COMMENT 'Reference identifier for the production or offtake contract governing this production activity. Links production data to contractual terms and pricing mechanisms.',
    `data_quality_score` DECIMAL(3,2) COMMENT 'Quality score for the production data on a scale of 0.00 to 1.00. Reflects completeness, accuracy, and timeliness. Used to assess confidence in valuation inputs.',
    `data_source` STRING COMMENT 'Origin of the production data. Indicates reliability and audit trail for NAV determination and performance reporting.. Valid values are `field_measurement|operator_report|third_party_audit|satellite_imagery|iot_sensor`',
    `depletion_charge` DECIMAL(18,2) COMMENT 'Accounting charge representing the reduction in resource reserves due to extraction. Calculated using units-of-production method for natural resource assets.',
    `environmental_incident_flag` BOOLEAN COMMENT 'Indicates whether an environmental incident (spill, contamination, habitat damage) occurred during the production period. Critical for ESG reporting and risk management.',
    `ghg_emissions_tonnes_co2e` DECIMAL(18,4) COMMENT 'Total greenhouse gas emissions generated during production, measured in tonnes of CO2 equivalent. Required for ESG integration and TCFD climate risk reporting.',
    `gross_revenue` DECIMAL(18,2) COMMENT 'Total revenue generated from production before deducting operating costs, royalties, and taxes. Calculated as production volume multiplied by realized price.',
    `harvest_method` STRING COMMENT 'Operational method used to extract or harvest the resource. Impacts cost structure, ESG metrics, and depletion rate calculations. [ENUM-REF-CANDIDATE',
    `hedging_instrument_flag` BOOLEAN COMMENT 'Indicates whether commodity price hedging instruments (futures, swaps, collars) were in place for this production. Affects realized price and risk exposure.',
    `net_operating_income` DECIMAL(18,2) COMMENT 'Net income from production after deducting operating costs and royalties. Key metric for asset-level performance evaluation and valuation.',
    `notes` STRING COMMENT 'Free-text field for additional context, operational notes, or explanations of variances. Supports qualitative analysis and exception documentation.',
    `operating_cost` DECIMAL(18,2) COMMENT 'Direct operating expenses incurred to produce the resource output during the reporting period. Includes labor, equipment, materials, and site maintenance.',
    `operator_name` STRING COMMENT 'Name of the entity responsible for day-to-day production operations. May be the fund itself or a contracted third-party operator.',
    `price_realization_percentage` DECIMAL(5,2) COMMENT 'Percentage of benchmark commodity price achieved in actual sales. Measures pricing effectiveness and quality premium/discount relative to market.',
    `pricing_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the realized price. Natural resource commodities often priced in USD but may vary by market and contract.. Valid values are `^[A-Z]{3}$`',
    `production_efficiency_rate` DECIMAL(5,2) COMMENT 'Percentage of planned production achieved during the reporting period. Measures operational performance against targets and identifies underperforming assets.',
    `production_status` STRING COMMENT 'Current validation status of the production record. Tracks progression from preliminary field data through audit and final confirmation for NAV calculation.. Valid values are `preliminary|confirmed|audited|adjusted|final`',
    `production_unit_of_measure` STRING COMMENT 'Unit of measure for production volume. Varies by resource type: cubic meters or MBF for timber, tonnes for minerals, barrels for oil, bushels for crops, MWh for energy.',
    `production_volume` DECIMAL(18,4) COMMENT 'Physical quantity of resource output produced during the reporting period. Measured in resource-specific units (cubic meters, tonnes, barrels, bushels).',
    `realized_price_per_unit` DECIMAL(18,4) COMMENT 'Actual price received per unit of production during the reporting period. Used for revenue recognition and performance attribution analysis.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when the production record was first created in the system. Audit trail for data lineage and regulatory compliance.',
    `record_updated_by` STRING COMMENT 'Identifier of the user or system that last updated the production record. Supports accountability and audit trail requirements.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the production record. Tracks data modification history for audit and reconciliation purposes.',
    `regulatory_compliance_status` STRING COMMENT 'Current compliance status with applicable environmental, safety, and operational regulations. Non-compliance can trigger operational shutdowns and financial penalties.. Valid values are `compliant|non_compliant|under_review|remediation_in_progress`',
    `remaining_reserves_estimate` DECIMAL(18,4) COMMENT 'Estimated quantity of recoverable resource remaining after this production period. Updated based on production data and reserve studies for long-term planning.',
    `reporting_period_end_date` DATE COMMENT 'End date of the production reporting period. Defines the boundary for production measurement and valuation.',
    `reporting_period_start_date` DATE COMMENT 'Start date of the production reporting period. Typically monthly or quarterly for natural resource assets.',
    `reserve_life_years` DECIMAL(8,2) COMMENT 'Estimated number of years of remaining production at current extraction rates. Critical metric for long-duration liability matching and asset allocation decisions.',
    `resource_type` STRING COMMENT 'Classification of the natural resource being produced. Determines the applicable production metrics and valuation methodology.. Valid values are `timber|farmland|mining|oil_gas|renewable_energy|water`',
    `royalty_payment` DECIMAL(18,2) COMMENT 'Royalty or lease payment owed to landowners, governments, or mineral rights holders based on production volume or revenue. Common in mining and oil/gas.',
    `safety_incident_count` BIGINT COMMENT 'Number of recordable safety incidents (injuries, near-misses) during the production period. Key operational risk and ESG metric for natural resource operations.',
    `third_party_operator_flag` BOOLEAN COMMENT 'Indicates whether production operations are managed by a third-party operator under contract rather than directly by the fund. Affects operational control and risk profile.',
    `water_usage_unit` STRING COMMENT 'Unit of measure for water usage volume. Varies by jurisdiction and industry practice.. Valid values are `cubic_meters|gallons|acre_feet|liters`',
    `water_usage_volume` DECIMAL(18,4) COMMENT 'Volume of water consumed during production operations. Critical ESG metric for water-intensive activities like mining, oil/gas extraction, and irrigation.',
    `weather_impact_flag` BOOLEAN COMMENT 'Indicates whether production was materially affected by adverse weather conditions (drought, flood, frost, hurricane). Relevant for farmland and timber assets.',
    CONSTRAINT pk_production_record PRIMARY KEY(`production_record_id`)
) COMMENT 'Operational production data captured at the asset level on a periodic basis (monthly/quarterly). Records physical output volumes for each resource type: timber harvest volumes (m³/MBF), crop yields (bushels/tonnes), mineral extraction tonnage, oil & gas';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`commodity_exposure` (
    `commodity_exposure_id` BIGINT COMMENT 'Unique identifier for the commodity exposure record.',
    `macro_indicator_id` BIGINT COMMENT 'Foreign key linking to research.macro_indicator. Business justification: Commodity exposure uses macro indicators to capture price and supply dynamics.',
    `market_consensus_id` BIGINT COMMENT 'Foreign key linking to research.market_consensus. Business justification: Consensus estimates provide benchmark prices for commodity exposure calculations.',
    `natural_resource_asset_id` BIGINT COMMENT 'Reference to the underlying natural resource asset (timberland, farmland, mining, energy) generating the commodity exposure.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio holding the natural resource assets generating this commodity exposure.',
    `benchmark_commodity_index` STRING COMMENT 'Reference commodity index or benchmark used to measure relative performance and price risk (e.g., Bloomberg Commodity Index, S&P GSCI, BCOM Agriculture).',
    `benchmark_ticker` STRING COMMENT 'Bloomberg or exchange ticker symbol for the benchmark commodity index or futures contract.',
    `comments` STRING COMMENT 'Free-text field for additional notes, qualitative assessments, or special considerations regarding the commodity exposure.',
    `commodity_subtype` STRING COMMENT 'Detailed subtype or grade of the commodity (e.g., WTI crude, Brent crude, hard red winter wheat, softwood lumber).',
    `commodity_type` STRING COMMENT 'Type of commodity to which the fund has price exposure through natural resource holdings. [ENUM-REF-CANDIDATE: lumber|wheat|corn|soy|crude_oil|natural_gas|copper|gold|iron_ore|silver|platinum|coal|uranium|nickel|zinc|aluminum — 16 candidates stripped',
    `correlation_to_portfolio` DECIMAL(6,4) COMMENT 'Statistical correlation coefficient between commodity price movements and overall portfolio returns, used for diversification analysis.',
    `country_code` STRING COMMENT 'Three-letter ISO country code for the jurisdiction of the commodity-producing asset.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the commodity exposure record was first created in the system.',
    `data_source` STRING COMMENT 'Primary source system or vendor providing commodity price and exposure data (e.g., Bloomberg, eFront, internal valuation model).',
    `depletion_rate_annual` DECIMAL(8,4) COMMENT 'Annual depletion rate of commodity reserves as a percentage, used for reserve life and valuation modeling.',
    `esg_carbon_intensity` DECIMAL(12,4) COMMENT 'Carbon intensity of commodity production measured in metric tons CO2 equivalent per unit of commodity produced.',
    `esg_water_usage_intensity` DECIMAL(12,4) COMMENT 'Water consumption intensity for commodity production measured in cubic meters per unit of commodity produced.',
    `exposure_classification` STRING COMMENT 'Classification of how the commodity exposure arises (direct production, reserves, contractual commitments, or fund investments).. Valid values are `direct_production|reserve_based|contract_linked|fund_investment|indirect`',
    `exposure_duration_years` DECIMAL(6,2) COMMENT 'Expected duration of commodity price exposure in years, based on production schedules, reserve life, or contract terms.',
    `exposure_notional_usd` DECIMAL(20,2) COMMENT 'Notional value of commodity price exposure in USD, representing the market value of the underlying commodity production or reserves.',
    `exposure_percentage_of_aum` DECIMAL(8,4) COMMENT 'Commodity exposure expressed as a percentage of total AUM, used for portfolio concentration risk monitoring.',
    `exposure_status` STRING COMMENT 'Current lifecycle status of the commodity exposure for portfolio monitoring and risk management.. Valid values are `active|hedged|closed|under_review|suspended`',
    `fair_value_level` STRING COMMENT 'IFRS 13 fair value hierarchy level for the commodity exposure valuation (Level 1: quoted prices, Level 2: observable inputs, Level 3: unobservable inputs).. Valid values are `level_1|level_2|level_3`',
    `forward_curve_contango_backwardation` STRING COMMENT 'Current shape of the commodity forward price curve, indicating market expectations and storage costs.. Valid values are `contango|backwardation|flat|not_applicable`',
    `fx_rate_to_reporting_currency` DECIMAL(18,8) COMMENT 'Exchange rate used to convert local commodity prices to reporting currency at measurement date.',
    `geographic_region` STRING COMMENT 'Geographic region where the commodity-producing asset is located, used for geopolitical risk assessment.',
    `hedge_ratio_percentage` DECIMAL(6,2) COMMENT 'Percentage of commodity exposure that is hedged through derivatives or forward contracts, used for risk mitigation analysis.',
    `hedging_instrument_type` STRING COMMENT 'Type of derivative instrument used to hedge commodity price risk, if any.. Valid values are `futures|forwards|swaps|options|collars|none`',
    `is_active` BOOLEAN COMMENT 'Boolean flag indicating whether the commodity exposure record is currently active and should be included in portfolio analytics.',
    `last_modified_by` STRING COMMENT 'User identifier of the person or system that last modified the commodity exposure record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the commodity exposure record was last updated.',
    `last_review_date` DATE COMMENT 'Date when the commodity exposure was last reviewed by the investment or risk management team.',
    `measurement_date` DATE COMMENT 'Date on which the commodity exposure and associated metrics were measured and recorded.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next review of the commodity exposure by the investment or risk management team.',
    `price_sensitivity_dv01` DECIMAL(18,2) COMMENT 'Dollar value change in exposure for a 1% move in commodity price, used for risk analytics and stress testing.',
    `price_unit_of_measure` STRING COMMENT 'Unit of measure for commodity pricing (e.g., per barrel, per bushel, per metric ton, per troy ounce, per MMBtu).',
    `production_volume_annual` DECIMAL(20,4) COMMENT 'Expected annual production volume of the commodity from the underlying natural resource asset.',
    `quantity_exposed` DECIMAL(20,4) COMMENT 'Physical quantity of commodity to which the fund is exposed through production, reserves, or contractual commitments.',
    `quantity_unit_of_measure` STRING COMMENT 'Unit of measure for the exposed commodity quantity (e.g., barrels, bushels, metric tons, troy ounces, cubic meters).',
    `regulatory_classification` STRING COMMENT 'Regulatory classification of the commodity exposure for reporting purposes (e.g., strategic reserve, speculative, hedging).',
    `reporting_currency` STRING COMMENT 'Three-letter ISO currency code in which the exposure is reported (typically USD for commodity exposures).. Valid values are `^[A-Z]{3}$`',
    `reserve_classification` STRING COMMENT 'Classification of commodity reserves based on geological certainty and economic viability.. Valid values are `proven|probable|possible|inferred|measured|indicated`',
    `reserve_quantity` DECIMAL(20,4) COMMENT 'Total proven and probable reserves of the commodity in the underlying natural resource asset.',
    `spot_price_per_unit` DECIMAL(18,6) COMMENT 'Current spot market price per unit of the commodity at the measurement date.',
    `valuation_methodology` STRING COMMENT 'Primary valuation methodology used to determine the fair value of the commodity exposure.. Valid values are `dcf|comparable_transactions|net_asset_value|market_multiple|reserve_based`',
    `var_contribution_usd` DECIMAL(18,2) COMMENT 'Contribution of this commodity exposure to the overall portfolio VaR, calculated at 95% confidence level.',
    `created_by` STRING COMMENT 'User identifier of the person or system that created the commodity exposure record.',
    CONSTRAINT pk_commodity_exposure PRIMARY KEY(`commodity_exposure_id`)
) COMMENT 'Tracks the funds commodity price exposure arising from natural resource holdings. Captures commodity type (lumber, wheat, corn, soy, crude oil, natural gas, copper, gold, iron ore), notional exposure in USD, exposure as % of AUM, benchmark commodity';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`depletion_schedule` (
    `depletion_schedule_id` BIGINT COMMENT 'Unique identifier for the depletion schedule record. Primary key for asset-level depletion tracking of wasting natural resource assets.',
    `investment_id` BIGINT COMMENT 'Reference to the parent investment transaction that acquired the natural resource asset.',
    `natural_resource_asset_id` BIGINT COMMENT 'Reference to the underlying natural resource asset (timberland, farmland, mining property, energy reserve) subject to depletion.',
    `reserve_estimate_id` BIGINT COMMENT 'Foreign key linking to naturalresource.reserve_estimate. Business justification: Depletion schedules for wasting assets are calculated based on reserve estimates (units-of-production method).',
    `acquisition_cost` DECIMAL(18,2) COMMENT 'Total capitalized cost of acquiring the natural resource asset, including purchase price and direct acquisition costs.',
    `acquisition_cost_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the acquisition cost amount.. Valid values are `^[A-Z]{3}$`',
    `acquisition_date` DATE COMMENT 'Date when the natural resource asset was acquired and placed into service.',
    `asset_type` STRING COMMENT 'Classification of the natural resource asset subject to depletion.. Valid values are `timberland|farmland|mining|oil_gas|mineral_rights|water_rights`',
    `commodity_price_assumption` DECIMAL(18,4) COMMENT 'Long-term commodity price assumption used in reserve valuation and depletion rate calculations.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this depletion schedule record was first created in the data platform.',
    `cumulative_depletion_to_date` DECIMAL(18,2) COMMENT 'Total depletion expense recognized from acquisition date through current reporting period.',
    `cumulative_impairment_loss` DECIMAL(18,2) COMMENT 'Total impairment losses recognized on the asset to date, reducing the carrying value below depletable base less depletion.',
    `cumulative_production_to_date` DECIMAL(18,4) COMMENT 'Total quantity of reserves extracted or harvested from acquisition date through current reporting period.',
    `current_period_depletion` DECIMAL(18,2) COMMENT 'Depletion expense recognized for the current reporting period based on production volume and depletion rate.',
    `current_period_production` DECIMAL(18,4) COMMENT 'Quantity of reserves extracted or harvested during the current reporting period.',
    `data_source_system` STRING COMMENT 'Name of the upstream operational system from which this depletion schedule data originated.',
    `depletable_base` DECIMAL(18,2) COMMENT 'Total cost basis subject to depletion, typically acquisition cost less estimated residual land value.',
    `depletion_method` STRING COMMENT 'Accounting method used to calculate periodic depletion expense for the wasting asset.. Valid values are `unit_of_production|straight_line|declining_balance|percentage_depletion|cost_depletion`',
    `depletion_rate_per_unit` DECIMAL(18,6) COMMENT 'Cost per unit of production used to calculate depletion expense, computed as depletable base divided by total proven reserves.',
    `depletion_schedule_status` STRING COMMENT 'Current lifecycle status of the depletion schedule reflecting asset operational state.. Valid values are `active|suspended|depleted|impaired|disposed`',
    `discount_rate` DECIMAL(5,4) COMMENT 'Discount rate applied in discounted cash flow (DCF) valuation of future reserve production for impairment testing.',
    `environmental_reclamation_reserve` DECIMAL(18,2) COMMENT 'Accrued liability for future environmental reclamation and site restoration costs associated with resource extraction.',
    `estimated_depletion_completion_date` DATE COMMENT 'Projected date when the asset will be fully depleted based on current production rates and remaining reserves.',
    `external_reserve_engineer` STRING COMMENT 'Name of the independent third-party reserve engineer or consultant who certified the proven reserve estimates.',
    `impairment_indicator_flag` BOOLEAN COMMENT 'Indicates whether impairment indicators have been identified requiring impairment testing under IAS 36 or FASB ASC 360.',
    `impairment_test_date` DATE COMMENT 'Date of the most recent impairment test performed on the natural resource asset.',
    `last_reserve_certification_date` DATE COMMENT 'Date when proven reserves were last certified by an independent reserve engineer.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'System timestamp when this depletion schedule record was most recently modified.',
    `net_book_value` DECIMAL(18,2) COMMENT 'Current carrying value of the natural resource asset, calculated as depletable base less cumulative depletion to date.',
    `notes` STRING COMMENT 'Free-text notes capturing additional context, assumptions, or special considerations for this depletion schedule.',
    `remaining_reserves` DECIMAL(18,4) COMMENT 'Current estimate of remaining recoverable reserves after cumulative depletion, updated periodically based on reserve studies.',
    `reporting_period_end_date` DATE COMMENT 'End date of the reporting period for which current period depletion and production are measured.',
    `reporting_period_start_date` DATE COMMENT 'Start date of the reporting period for which current period depletion and production are measured.',
    `reserve_revision_date` DATE COMMENT 'Date of the most recent reserve study or revision that updated proven reserve estimates.',
    `reserve_revision_reason` STRING COMMENT 'Business reason for the reserve revision, such as new geological data, price changes, or regulatory updates.',
    `reserve_unit_of_measure` STRING COMMENT 'Unit of measure for quantifying proven reserves and production volumes. [ENUM-REF-CANDIDATE: barrels|cubic_meters|tonnes|board_feet|acres|hectares|troy_ounces — 7 candidates stripped; promote to reference product]',
    `residual_land_value` DECIMAL(18,2) COMMENT 'Estimated value of the land after resource extraction is complete, excluded from depletable base.',
    `responsible_investment_officer` STRING COMMENT 'Name of the investment officer responsible for managing this natural resource asset and its depletion schedule.',
    `schedule_name` STRING COMMENT 'Business-friendly name or label for this depletion schedule, typically including asset name and vintage year.',
    `tax_depletion_allowance` DECIMAL(18,2) COMMENT 'Depletion deduction claimed for tax purposes in the current reporting period.',
    `tax_depletion_method` STRING COMMENT 'Depletion method used for tax reporting purposes, which may differ from financial reporting method.. Valid values are `cost_depletion|percentage_depletion|not_applicable`',
    `total_proven_reserves` DECIMAL(18,4) COMMENT 'Total quantity of proven recoverable reserves at acquisition date, used as denominator in unit-of-production depletion.',
    `valuation_model_reference` STRING COMMENT 'Reference identifier for the resource-specific valuation model used for fair value measurement and impairment testing.',
    CONSTRAINT pk_depletion_schedule PRIMARY KEY(`depletion_schedule_id`)
) COMMENT 'Asset-level depletion, amortization, and depreciation schedule for wasting natural resource assets. Captures depletion method (unit-of-production, straight-line, declining balance), total proven reserves at acquisition, cumulative depletion to date';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`reserve_estimate` (
    `reserve_estimate_id` BIGINT COMMENT 'Unique identifier for the reserve estimate record. Primary key for the reserve estimate entity.',
    `previous_estimate_reserve_estimate_id` BIGINT COMMENT 'Foreign key reference to the prior reserve estimate record that this estimate supersedes, enabling historical tracking and variance analysis.',
    `resource_asset_id` BIGINT COMMENT 'Foreign key reference to the underlying natural resource asset (mining property, oil & gas field, timberland tract) for which reserves are estimated.',
    `audit_firm_name` STRING COMMENT 'Name of the independent reserves auditing firm that reviewed or certified the reserve estimate, if applicable (e.g., DeGolyer & MacNaughton, Gaffney Cline, SRK Consulting).',
    `audit_report_date` DATE COMMENT 'Date of the independent audit report or certification, if the reserve estimate was externally audited.',
    `capital_expenditure_estimate` DECIMAL(18,2) COMMENT 'Total estimated capital expenditure required to develop and extract the reserves, including drilling, infrastructure, equipment, and facility costs.',
    `commodity_price_assumption` DECIMAL(18,4) COMMENT 'Long-term commodity price assumption (per unit of measure) used in the economic evaluation of the reserves, typically based on forward curves, analyst consensus, or internal forecasts.',
    `commodity_type` STRING COMMENT 'Type of commodity or natural resource being estimated: crude oil, natural gas, gold, copper, iron ore, coal, timber, agricultural products, etc.',
    `confidence_level_percent` DECIMAL(5,2) COMMENT 'Statistical confidence level or probability percentage associated with the reserve estimate, typically P10, P50, P90 for probabilistic assessments (e.g., 90% confidence for proven reserves).',
    `created_by_user` STRING COMMENT 'User identifier or name of the person who created this reserve estimate record, supporting accountability and audit trail.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this reserve estimate record was first created in the system, supporting audit trail and data lineage requirements.',
    `depletion_method` STRING COMMENT 'Accounting method used to allocate the cost of the natural resource asset over its productive life: unit-of-production (most common for extractive industries), straight-line, declining balance, cost depletion, or percentage depletion.. Valid values are `unit_of_production|straight_line|declining_balance|cost_depletion|percentage_depletion`',
    `discount_rate_percent` DECIMAL(5,2) COMMENT 'Discount rate (typically WACC or hurdle rate) applied in the NPV calculation to reflect the time value of money and risk profile of the reserves.',
    `effective_date` DATE COMMENT 'The date as of which this reserve estimate is effective and valid. Critical for time-series valuation and regulatory reporting, as reserve estimates are point-in-time assessments.',
    `environmental_adjustment_factor` DECIMAL(5,4) COMMENT 'Adjustment factor applied to reserves to account for environmental constraints, protected areas, seasonal restrictions, or ESG considerations that may limit extraction.',
    `estimate_identifier` STRING COMMENT 'Externally-known business identifier or report reference number for this reserve estimate, used in regulatory filings and investment committee materials.',
    `estimate_status` STRING COMMENT 'Current lifecycle status of the reserve estimate: draft (under preparation), preliminary (initial assessment), final (approved for use), superseded (replaced by newer estimate), archived (historical record).. Valid values are `draft|preliminary|final|superseded|archived`',
    `estimated_npv` DECIMAL(18,2) COMMENT 'Net present value of the reserves calculated using discounted cash flow (DCF) analysis, incorporating commodity price forecasts, operating costs, capital expenditures, and discount rate assumptions.',
    `estimation_method` STRING COMMENT 'Technical method used to estimate reserves: deterministic (single-point), probabilistic (Monte Carlo), analogous (comparison), volumetric (geological), decline curve analysis, material balance, or reservoir simulation.',
    `geological_model_version` STRING COMMENT 'Version identifier of the geological or reservoir model used as the basis for the reserve estimate, enabling traceability and change management.',
    `gross_reserves` DECIMAL(20,4) COMMENT 'Total reserves attributable to the asset before deducting royalties, government take, or working interest adjustments. Represents 100% of the resource in place.',
    `independent_audit_flag` BOOLEAN COMMENT 'Boolean flag indicating whether the reserve estimate was independently audited or reviewed by a third-party reserves auditor (true) or prepared internally (false).',
    `modified_by_user` STRING COMMENT 'User identifier or name of the person who last modified this reserve estimate record, supporting accountability and audit trail.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this reserve estimate record was last modified, supporting change tracking and audit trail requirements.',
    `net_reserves` DECIMAL(20,4) COMMENT 'Reserves attributable to the pension funds ownership interest after deducting royalties, government take, and adjusting for working interest or economic interest percentage.',
    `notes` STRING COMMENT 'Free-text notes capturing additional context, assumptions, limitations, or qualifications related to the reserve estimate that are important for investment decision-making.',
    `operating_cost_per_unit` DECIMAL(18,4) COMMENT 'Estimated operating cost per unit of production (e.g., per barrel, per tonne) used in the economic evaluation, including extraction, processing, transportation, and overhead costs.',
    `price_deck_scenario` STRING COMMENT 'Scenario or case used for commodity price assumptions in the reserve valuation: base case, bull case (high prices), bear case (low prices), spot prices, forward curve, or analyst consensus.. Valid values are `base_case|bull_case|bear_case|spot|forward_curve|consensus`',
    `production_start_date` DATE COMMENT 'Actual or projected date when commercial production from the resource asset commenced or is expected to commence, relevant for reserve depletion scheduling.',
    `qualified_person_credentials` STRING COMMENT 'Professional credentials and certifications of the qualified person (e.g., P.Eng., P.Geo., Chartered Engineer, SPE member), demonstrating competence to prepare reserve estimates.',
    `qualified_person_name` STRING COMMENT 'Name of the qualified person (QP), competent person (CP), or professional engineer who prepared or reviewed the reserve estimate, as required by regulatory standards.',
    `recoverable_quantity` DECIMAL(20,4) COMMENT 'Estimated quantity of the commodity that can be economically extracted and recovered from the resource asset, expressed in the unit of measure specified.',
    `recovery_factor_percent` DECIMAL(5,2) COMMENT 'Percentage of the original resource in place that is estimated to be recoverable, reflecting extraction efficiency and technology limitations.',
    `regulatory_approval_status` STRING COMMENT 'Status of regulatory approvals required to extract the reserves: approved (permits granted), pending (under review), conditional (approved with conditions), denied, or not required.. Valid values are `approved|pending|conditional|denied|not_required`',
    `reporting_standard` STRING COMMENT 'The industry standard or regulatory framework under which this reserve estimate was prepared: SPE-PRMS (petroleum), JORC (Australia mining), NI 43-101 (Canada mining), SEC (US public companies), SAMREC (South Africa), PERC (Europe).. Valid values are `SPE-PRMS|JORC|NI43-101|SEC|SAMREC|PERC`',
    `reserve_booking_date` DATE COMMENT 'Date when the reserve estimate was formally booked or recorded in the pension funds asset register and investment accounting systems.',
    `reserve_category` STRING COMMENT 'Classification of reserve confidence level per industry standards: 1P (proven), 2P (proven + probable), 3P (proven + probable + possible) for petroleum; or measured, indicated, inferred for mining.',
    `reserve_life_years` DECIMAL(6,2) COMMENT 'Estimated number of years the reserves will last at current or projected production rates. Calculated as recoverable quantity divided by annual production rate.',
    `revision_reason` STRING COMMENT 'Business reason for revising the reserve estimate: new drilling data, updated geological model, commodity price change, regulatory change, production performance, technology improvement, or annual review.',
    `royalty_burden_percent` DECIMAL(5,2) COMMENT 'Percentage of production or reserves payable as royalty to mineral rights owners, government, or other parties, reducing the net economic interest.',
    `unit_of_measure` STRING COMMENT 'Unit of measure for the recoverable quantity: barrels (bbl) for oil, thousand cubic feet (mcf) for gas, barrels of oil equivalent (boe), tonnes or ounces for minerals, board feet for timber, acres for land.',
    `valuation_date` DATE COMMENT 'Date on which the economic valuation of the reserves was performed, which may differ from the effective date if market conditions or pricing assumptions were applied retrospectively.',
    `working_interest_percent` DECIMAL(5,2) COMMENT 'Percentage ownership interest in the resource asset that entitles the pension fund to a proportionate share of production and reserves, net of royalties and government take.',
    CONSTRAINT pk_reserve_estimate PRIMARY KEY(`reserve_estimate_id`)
) COMMENT 'Proven, probable, and possible (3P) reserve estimates for extractive resource assets (mining, oil & gas). Captures reserve category (1P/2P/3P per SPE-PRMS or JORC standards), commodity type, estimated recoverable quantity, unit of measure, effective date';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`resource_valuation` (
    `resource_valuation_id` BIGINT COMMENT 'Unique identifier for the natural resource asset valuation record.',
    `commodity_price_deck_id` BIGINT COMMENT 'Reference to the commodity price forecast deck used for revenue projections in the valuation model.',
    `country_outlook_id` BIGINT COMMENT 'Foreign key linking to research.country_outlook. Business justification: Country outlook is used to adjust valuation assumptions for geopolitical risk.',
    `depletion_schedule_id` BIGINT COMMENT 'Reference to the depletion or extraction schedule used for reserve-based valuation of mining, oil, gas, or timber assets.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: Scenario‑based valuation of natural resource assets requires linking to the chosen economic scenario.',
    `research_fx_rate_id` BIGINT COMMENT 'Foreign key linking to research.research_fx_rate. Business justification: Currency conversion for valuation uses the chosen FX rate.',
    `research_report_id` BIGINT COMMENT 'Foreign key linking to research.report. Business justification: Valuation results are documented in formal research reports.',
    `research_yield_curve_id` BIGINT COMMENT 'Foreign key linking to research.research_yield_curve. Business justification: Discounting cash flows uses the selected research yield curve.',
    `reserve_estimate_id` BIGINT COMMENT 'Foreign key linking to naturalresource.reserve_estimate. Business justification: Resource valuations for extractive assets (mining, oil & gas) heavily depend on reserve estimates for DCF modeling.',
    `resource_asset_id` BIGINT COMMENT 'Reference to the underlying natural resource asset being valued (timberland, farmland, mining, energy, commodity fund).',
    `sector_outlook_id` BIGINT COMMENT 'Foreign key linking to research.sector_outlook. Business justification: Sector outlook informs risk and return assumptions in valuations.',
    `appraisal_firm_name` STRING COMMENT 'Name of the independent third-party appraisal firm that conducted the valuation, if applicable.',
    `appraisal_report_date` DATE COMMENT 'Date of the independent appraisal report, if third-party valuation was obtained.',
    `approval_date` DATE COMMENT 'Date on which the valuation was formally approved by the Investment Committee or designated authority.',
    `capital_expenditure_assumption` DECIMAL(20,2) COMMENT 'Total capital expenditure forecast used in the DCF model for sustaining and growth capital.',
    `carbon_price_assumption` DECIMAL(10,2) COMMENT 'Assumed carbon price per ton of CO2 equivalent used in valuation model to reflect climate transition risk.',
    `comparable_transaction_date` DATE COMMENT 'Date of the most recent comparable market transaction used as a valuation benchmark.',
    `comparable_transaction_multiple` DECIMAL(8,4) COMMENT 'Valuation multiple derived from comparable transactions (e.g., EV/EBITDA, price per acre, price per barrel of reserves).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this valuation record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the fair value amount.. Valid values are `^[A-Z]{3}$`',
    `data_source_system` STRING COMMENT 'Name of the source system or platform from which valuation inputs were extracted (e.g., eFront, Bloomberg, internal models).',
    `discount_rate` DECIMAL(8,4) COMMENT 'Weighted Average Cost of Capital (WACC) or discount rate applied in DCF valuation, expressed as a decimal (e.g., 0.0850 for 8.50%).',
    `esg_adjustment_factor` DECIMAL(8,6) COMMENT 'Valuation adjustment factor applied to reflect ESG risks or premiums (e.g., carbon pricing, social license risk, governance quality).',
    `fair_value_amount` DECIMAL(20,2) COMMENT 'The determined fair value of the natural resource asset in the reporting currency.',
    `fair_value_hierarchy_level` STRING COMMENT 'IFRS 13 fair value hierarchy classification: Level 1 (quoted prices), Level 2 (observable inputs), Level 3 (unobservable inputs).. Valid values are `Level_1|Level_2|Level_3`',
    `geopolitical_risk_rating` STRING COMMENT 'Qualitative assessment of geopolitical risk associated with the asset location (expropriation, political instability, sanctions).. Valid values are `low|moderate|high|severe`',
    `inflation_rate` DECIMAL(6,4) COMMENT 'Long-term inflation rate assumption applied to operating cost and revenue escalation, expressed as a decimal (e.g., 0.0250 for 2.50%).',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this valuation record was last updated.',
    `liquidity_discount` DECIMAL(6,4) COMMENT 'Discount applied to fair value to reflect illiquidity and lack of marketability of the natural resource asset, expressed as a decimal.',
    `nav_per_unit` DECIMAL(18,6) COMMENT 'Net Asset Value per unit or share for fund-structured natural resource investments.',
    `operating_cost_per_unit` DECIMAL(18,4) COMMENT 'Average operating cost per unit of production used in the valuation model.',
    `prior_valuation_amount` DECIMAL(20,2) COMMENT 'Fair value from the immediately preceding valuation period, used for variance analysis.',
    `production_unit_of_measure` STRING COMMENT 'Unit of measure for production volume (barrels for oil, tons for minerals, cubic meters for gas, board feet for timber, bushels for farmland, MWh for energy, ounces for precious metals).',
    `production_volume_assumption` DECIMAL(18,2) COMMENT 'Expected annual production volume used in valuation model (barrels, tons, cubic meters, board feet, bushels depending on resource type).',
    `regulatory_risk_adjustment` DECIMAL(8,6) COMMENT 'Valuation discount or premium applied to reflect jurisdiction-specific regulatory risk (permitting, taxation, environmental compliance).',
    `reserve_life_years` DECIMAL(6,2) COMMENT 'Estimated remaining economic life of the resource reserve in years, based on current production rates and proven reserves.',
    `sensitivity_analysis_performed` BOOLEAN COMMENT 'Indicates whether sensitivity analysis was conducted on key valuation assumptions (discount rate, commodity prices, production volumes).',
    `terminal_value_assumption` STRING COMMENT 'Description of terminal value methodology and assumptions used in DCF model (perpetuity growth rate, exit multiple, residual value approach).',
    `valuation_analyst_name` STRING COMMENT 'Name of the internal analyst or team responsible for preparing the valuation.',
    `valuation_change_amount` DECIMAL(20,2) COMMENT 'Absolute change in fair value from the prior valuation period.',
    `valuation_change_percentage` DECIMAL(8,4) COMMENT 'Percentage change in fair value from the prior valuation period, expressed as a decimal.',
    `valuation_date` DATE COMMENT 'The as-of date for which this fair value determination was performed.',
    `valuation_frequency` STRING COMMENT 'Scheduled frequency at which this natural resource asset is revalued.. Valid values are `monthly|quarterly|semi_annual|annual|ad_hoc`',
    `valuation_method` STRING COMMENT 'Primary valuation methodology applied: Discounted Cash Flow (DCF), comparable transaction, Net Asset Value (NAV), independent appraisal, market approach, or income approach.. Valid values are `DCF|comparable_transaction|NAV|appraisal|market_approach|income_approach`',
    `valuation_model_version` STRING COMMENT 'Version identifier of the internal valuation model or template used for this valuation.',
    `valuation_notes` STRING COMMENT 'Free-text commentary on valuation methodology, key assumptions, significant changes, or qualitative factors affecting the valuation.',
    `valuation_reviewer_name` STRING COMMENT 'Name of the senior reviewer or approver who validated the valuation.',
    `valuation_status` STRING COMMENT 'Current workflow status of the valuation record in the approval process.. Valid values are `draft|under_review|approved|final|superseded`',
    CONSTRAINT pk_resource_valuation PRIMARY KEY(`resource_valuation_id`)
) COMMENT 'Periodic fair value and NAV determination records for natural resource assets, capturing valuation methodology (DCF, comparable transaction, NAV, appraisal), discount rate (WACC), terminal value assumptions, commodity price deck used, inflation';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`capital_event` (
    `capital_event_id` BIGINT COMMENT 'Unique identifier for the capital event record in the natural resource investment portfolio.',
    `natural_resource_investment_id` BIGINT COMMENT 'Reference to the underlying natural resource investment (timberland, farmland, mining, energy, commodity fund) to which this capital event applies.',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: Capital calls/distributions require direct portfolio linkage for cash management and liquidity planning. Investment operations reconcile capital events against portfolio commitments.',
    `resource_asset_id` BIGINT COMMENT 'Reference to the underlying natural resource investment (timberland, farmland, mining, energy, commodity fund) to which this capital event applies.',
    `resource_fund_commitment_id` BIGINT COMMENT 'Foreign key linking to naturalresource.resource_fund_commitment. Business justification: Capital events (calls, distributions) for fund investments draw down or distribute against specific fund commitments.',
    `resource_holding_id` BIGINT COMMENT 'Foreign key linking to naturalresource.resource_holding. Business justification: Capital events (capital calls, distributions) relate to specific resource holdings representing the funds economic interest.',
    `approval_date` DATE COMMENT 'Date on which the capital event was approved by the Investment Committee (IC) or authorized treasury personnel for execution.',
    `approval_status` STRING COMMENT 'Internal approval status for the capital event funding or distribution acceptance, reflecting Investment Committee (IC) or treasury approval workflow.. Valid values are `pending|approved|rejected|escalated`',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee that approved the capital event for funding or acceptance, per internal governance protocols.',
    `bank_account_reference` STRING COMMENT 'Reference to the pension funds bank account used for funding capital calls or receiving distributions, per Standard Settlement Instructions (SSI).',
    `capital_recycling_flag` BOOLEAN COMMENT 'Indicates whether this event is part of a capital recycling provision, where distributed capital is reinvested without counting against the original commitment.',
    `commitment_amount` DECIMAL(18,2) COMMENT 'Total committed capital amount for the natural resource investment, representing the maximum capital the Limited Partner (LP) has agreed to contribute.',
    `commodity_price_reference` STRING COMMENT 'Reference commodity price index or benchmark used for valuation or distribution calculation (e.g., WTI Crude, Henry Hub Natural Gas, LME Copper).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the capital event record was first created in the Investment Book of Record (IBOR) system.',
    `depletion_adjustment_amount` DECIMAL(18,2) COMMENT 'Accounting adjustment for natural resource depletion associated with this capital event, reflecting the reduction in resource reserves or asset base.',
    `distribution_type` STRING COMMENT 'Classification of distribution: return of capital, income distribution, preferred return, carried interest, recallable distribution, or final liquidating distribution.. Valid values are `return_of_capital|income|preferred_return|carried_interest|recallable|final`',
    `distributions_to_date` DECIMAL(18,2) COMMENT 'Cumulative distributions received by the Limited Partner (LP) from the natural resource investment as of this event, including this distribution if applicable.',
    `due_date` DATE COMMENT 'Date by which the capital call must be funded or the distribution is scheduled to be paid, as specified in the capital event notice.',
    `effective_date` DATE COMMENT 'Date on which the capital event becomes effective for accounting and valuation purposes, typically the trade date or commitment date.',
    `event_amount` DECIMAL(18,2) COMMENT 'Monetary value of the capital event: amount called for capital calls or amount distributed for distributions, in the funds base currency.',
    `event_amount_base_currency` DECIMAL(18,2) COMMENT 'Capital event amount converted to the pension funds base reporting currency using the effective date foreign exchange (FX) rate.',
    `event_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the capital event amount (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `event_reference_number` STRING COMMENT 'External business identifier for the capital event, typically assigned by the General Partner (GP) or fund administrator for tracking and reconciliation.',
    `event_status` STRING COMMENT 'Current lifecycle status of the capital event: notified by GP, confirmed by LP, funded, settled, cancelled, or recalled (for recallable distributions).. Valid values are `notified|confirmed|funded|settled|cancelled|recalled`',
    `event_type` STRING COMMENT 'Classification of the capital flow event: capital call (drawdown), distribution (return of capital or income), recallable distribution, or capital recycling event.',
    `exception_notes` STRING COMMENT 'Free-text notes documenting any exceptions, discrepancies, or special circumstances related to the capital event processing or reconciliation.',
    `fund_administrator_name` STRING COMMENT 'Name of the third-party fund administrator responsible for processing capital calls and distributions on behalf of the General Partner (GP).',
    `fx_rate` DECIMAL(12,6) COMMENT 'Foreign exchange rate applied to convert the event amount from the fund currency to the pension funds base currency, as of the effective date.',
    `gp_entity_name` STRING COMMENT 'Legal name of the General Partner (GP) or fund manager responsible for managing the natural resource investment and issuing capital event notices.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the capital event record, reflecting changes in status, amounts, or reconciliation.',
    `net_distribution_amount` DECIMAL(18,2) COMMENT 'Net distribution amount received by the Limited Partner (LP) after deducting withholding taxes and any other adjustments from the gross distribution.',
    `notice_document_reference` STRING COMMENT 'Reference identifier for the capital call notice or distribution notice document issued by the General Partner (GP), stored in the document management system.',
    `notification_date` DATE COMMENT 'Date on which the General Partner (GP) notified the Limited Partner (LP) of the capital event, typically via capital call notice or distribution notice.',
    `paid_in_capital_to_date` DECIMAL(18,2) COMMENT 'Cumulative capital contributed by the Limited Partner (LP) to the natural resource investment as of this event, including this capital call if applicable.',
    `payment_instruction_reference` STRING COMMENT 'Reference number or identifier for the payment instruction associated with this capital event, used for treasury and cash management reconciliation.',
    `production_linked_flag` BOOLEAN COMMENT 'Indicates whether the distribution is linked to production output from the natural resource asset (e.g., timber harvest, crop yield, mineral extraction).',
    `recall_expiration_date` DATE COMMENT 'Date after which a recallable distribution can no longer be recalled by the General Partner (GP), typically specified in the Limited Partnership Agreement (LPA).',
    `recallable_flag` BOOLEAN COMMENT 'Indicates whether the distribution is subject to recall provisions under the Limited Partnership Agreement (LPA), allowing the General Partner (GP) to reclaim distributed capital.',
    `reconciliation_status` STRING COMMENT 'Status of reconciliation between the capital event notice and actual cash movement, used for operational control and audit trail.. Valid values are `pending|matched|exception|resolved`',
    `resource_asset_type` STRING COMMENT 'Classification of the underlying natural resource asset: timberland, farmland, mining, energy, commodity-linked fund, or specific commodity exposure. [ENUM-REF-CANDIDATE: timberland|farmland|mining|energy|commodity_fund|natural_gas|oil|metals|agriculture',
    `settlement_date` DATE COMMENT 'Actual date on which the capital event was settled: funds transferred for capital call or distribution received by the Limited Partner (LP).',
    `unfunded_commitment` DECIMAL(18,2) COMMENT 'Remaining uncalled committed capital available for future capital calls, calculated as commitment amount minus paid-in capital to date.',
    `valuation_impact_amount` DECIMAL(18,2) COMMENT 'Impact of this capital event on the Net Asset Value (NAV) of the natural resource investment, reflecting changes in fair value or carrying value.',
    `withholding_tax_amount` DECIMAL(18,2) COMMENT 'Amount of withholding tax deducted from the distribution by the General Partner (GP) or fund administrator, typically for cross-border tax compliance.',
    `withholding_tax_jurisdiction` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code for the jurisdiction imposing withholding tax on the distribution (e.g., USA, CAN, GBR).. Valid values are `^[A-Z]{3}$`',
    CONSTRAINT pk_capital_event PRIMARY KEY(`capital_event_id`)
) COMMENT 'Records all capital flow events for natural resource holdings including capital calls (drawdowns), distributions (return of capital, income distributions), recallable distributions, and capital recycling events.';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`operator_agreement` (
    `operator_agreement_id` BIGINT COMMENT 'Unique identifier for the operator agreement record. Primary key for natural resource operating agreements, joint venture agreements, and management contracts.',
    `investment_id` BIGINT COMMENT 'Foreign key reference to the parent investment record in the portfolio. Links operating agreement to the broader investment structure.',
    `natural_resource_asset_id` BIGINT COMMENT 'Foreign key reference to the natural resource asset governed by this operating agreement. Links agreement to underlying timberland, farmland, mining, or energy asset.',
    `agreement_name` STRING COMMENT 'Human-readable name or title of the operating agreement, typically referencing the asset or project being governed.',
    `agreement_number` STRING COMMENT 'Externally-known unique business identifier for the operating agreement or joint venture contract. Used for legal reference and external communication.',
    `agreement_status` STRING COMMENT 'Current lifecycle status of the operating agreement. Tracks progression from negotiation through execution to termination.. Valid values are `draft|pending_approval|active|suspended|terminated|expired`',
    `agreement_type` STRING COMMENT 'Classification of the agreement structure governing the natural resource asset. Defines the legal and operational framework for resource management and revenue sharing.. Valid values are `operating_agreement|joint_venture|farm_out|royalty_agreement|offtake_agreement|management_contract`',
    `amendment_count` BIGINT COMMENT 'Total number of amendments or modifications made to the operating agreement since original execution. Indicates contract stability.',
    `approval_date` DATE COMMENT 'Date when the operating agreement was approved by the Investment Committee (IC) or authorized governance body.',
    `assignment_restriction_flag` BOOLEAN COMMENT 'Indicates whether the agreement restricts assignment or transfer of rights and obligations without prior consent of all parties.',
    `audit_rights_flag` BOOLEAN COMMENT 'Indicates whether the pension fund has contractual rights to audit the operators books and records. Critical for governance and compliance.',
    `capital_call_notice_days` BIGINT COMMENT 'Number of days advance notice required for capital calls or funding requests under the operating agreement. Defines liquidity planning requirements.',
    `change_of_control_clause_flag` BOOLEAN COMMENT 'Indicates whether the agreement contains change of control provisions requiring consent or triggering termination rights upon operator ownership changes.',
    `confidentiality_obligation_flag` BOOLEAN COMMENT 'Indicates whether the agreement contains confidentiality and non-disclosure obligations binding the parties. Protects proprietary information.',
    `cost_allocation_method` STRING COMMENT 'Method for allocating operating costs and capital expenditures among joint venture partners. Defines cost-sharing mechanics.. Valid values are `proportional|fixed|variable|tiered`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this operator agreement record was first created in the system. Supports audit trail and data lineage.',
    `default_cure_period_days` BIGINT COMMENT 'Number of days allowed for the operator to cure a default or breach before termination rights are triggered. Defines grace period for remediation.',
    `dispute_resolution_mechanism` STRING COMMENT 'Agreed method for resolving disputes between parties under the operating agreement. Defines escalation path and binding resolution process.. Valid values are `litigation|arbitration|mediation|expert_determination`',
    `document_repository_path` STRING COMMENT 'File path or URI to the executed agreement document and related legal documentation in the enterprise document management system.',
    `effective_date` DATE COMMENT 'Date when the operating agreement becomes legally binding and operational responsibilities commence.',
    `environmental_compliance_standard` STRING COMMENT 'Environmental, Social, and Governance (ESG) standards and certifications that the operator is contractually required to maintain.',
    `execution_date` DATE COMMENT 'Date when the operating agreement was formally executed and signed by all parties. May differ from effective date.',
    `expiration_date` DATE COMMENT 'Date when the operating agreement terminates or expires. Nullable for open-ended or perpetual agreements subject to termination clauses.',
    `force_majeure_provision_flag` BOOLEAN COMMENT 'Indicates whether the agreement contains force majeure provisions excusing performance during extraordinary events beyond parties control.',
    `governing_law` STRING COMMENT 'Jurisdiction and legal framework governing the interpretation and enforcement of the operating agreement. Critical for dispute resolution.',
    `hurdle_rate` DECIMAL(5,4) COMMENT 'Minimum preferred return threshold that must be achieved before performance fees or carried interest are payable to the operator.',
    `insurance_requirement` STRING COMMENT 'Minimum insurance coverage types and limits that the operator must maintain under the agreement. Protects against operational and liability risks.',
    `last_amendment_date` DATE COMMENT 'Date of the most recent amendment or modification to the operating agreement. Tracks contract evolution over time.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this operator agreement record was most recently modified. Supports change tracking and audit requirements.',
    `management_fee_basis` STRING COMMENT 'Basis for calculating management fees charged by the operator. Defines whether fees are asset-based, revenue-based, or fixed.. Valid values are `nav|gav|revenue|production|fixed`',
    `management_fee_rate` DECIMAL(5,4) COMMENT 'Annual management fee rate charged by the operator as a percentage of asset value or revenue. Used for cost allocation and performance attribution.',
    `non_compete_clause_flag` BOOLEAN COMMENT 'Indicates whether the agreement contains non-compete restrictions limiting the operators ability to engage in competing activities.',
    `notes` STRING COMMENT 'Free-text field for capturing additional context, special provisions, or operational notes related to the operating agreement.',
    `operator_entity_code` BIGINT COMMENT 'Foreign key reference to the legal entity master record for the operator or joint venture partner. Enables counterparty risk and relationship management.',
    `operator_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the operator or joint venture partner. Enables global counterparty identification and regulatory reporting.. Valid values are `^[A-Z0-9]{20}$`',
    `operator_name` STRING COMMENT 'Legal name of the operator or joint venture partner responsible for day-to-day management and operations of the natural resource asset.',
    `operator_ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage ownership or working interest held by the operator or joint venture partner. Used for revenue sharing and cost allocation calculations.',
    `operator_role` STRING COMMENT 'Functional role of the operator within the agreement structure. Defines operational responsibilities and decision-making authority.. Valid values are `lead_operator|co_operator|managing_partner|non_operating_partner|technical_advisor`',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage ownership or working interest held by the pension fund under this operating agreement. Determines revenue and cost allocation.',
    `performance_fee_rate` DECIMAL(5,4) COMMENT 'Performance-based fee or carried interest rate earned by the operator above a hurdle rate. Aligns operator incentives with asset performance.',
    `reporting_frequency` STRING COMMENT 'Frequency at which the operator is required to provide operational and financial reports to joint venture partners.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `revenue_sharing_method` STRING COMMENT 'Method for distributing revenue and production proceeds among joint venture partners. Defines cash flow distribution mechanics.. Valid values are `proportional|waterfall|tiered|fixed`',
    `termination_date` DATE COMMENT 'Actual date when the agreement was terminated prior to expiration. Populated only when early termination occurs.',
    `termination_reason` STRING COMMENT 'Business or legal reason for early termination of the operating agreement. Captures context for contract closure and lessons learned.',
    CONSTRAINT pk_operator_agreement PRIMARY KEY(`operator_agreement_id`)
) COMMENT 'Master record for operating agreements, joint venture agreements, and management contracts governing natural resource assets. Captures operator/JV partner name, LEI, agreement type (operating agreement, JV, farm-out, royalty agreement, offtake agreement)';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`royalty_obligation` (
    `royalty_obligation_id` BIGINT COMMENT 'Unique identifier for the royalty obligation record.',
    `natural_resource_asset_id` BIGINT COMMENT 'Reference to the underlying natural resource asset (timberland, farmland, mining, energy) to which this royalty obligation is attached.',
    `audit_rights` STRING COMMENT 'Description of the royalty holders contractual rights to audit production records, revenue calculations, and payment compliance.',
    `benchmark_price_index` STRING COMMENT 'Market price index or benchmark used to determine the royalty base value (e.g., WTI, Brent, Henry Hub, LME Copper).',
    `commodity_type` STRING COMMENT 'Type of commodity or natural resource produced from the asset and subject to the royalty obligation. [ENUM-REF-CANDIDATE: crude_oil|natural_gas|coal|gold|copper|iron_ore|timber|agricultural_products — 8 candidates stripped; promote to reference product]',
    `created_by_user` STRING COMMENT 'Identifier of the user or system process that created this record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this royalty obligation record was first created in the system.',
    `deductible_cost_types` STRING COMMENT 'Description of the types of costs that are contractually deductible from the royalty base (e.g., transportation, processing, marketing).',
    `deductible_costs_allowed` BOOLEAN COMMENT 'Indicates whether certain operating, transportation, or processing costs may be deducted from gross revenue before calculating the royalty base.',
    `depletion_method` STRING COMMENT 'Accounting method used to allocate the cost of the natural resource asset over its productive life, relevant for royalty valuation and financial reporting.. Valid values are `units_of_production|straight_line|declining_balance|not_applicable`',
    `discount_rate_percent` DECIMAL(10,6) COMMENT 'Discount rate applied in the valuation model to present-value future royalty payment obligations.',
    `dispute_resolution_mechanism` STRING COMMENT 'Contractual mechanism for resolving disputes related to royalty calculations, payments, or compliance.. Valid values are `arbitration|litigation|mediation|expert_determination`',
    `effective_date` DATE COMMENT 'Date on which the royalty obligation becomes legally binding and payment obligations commence.',
    `environmental_compliance_required` BOOLEAN COMMENT 'Indicates whether the royalty agreement includes environmental compliance or ESG performance conditions that may affect payment obligations.',
    `escalation_clause` STRING COMMENT 'Description of any contractual escalation provisions that adjust the royalty rate or minimum payment over time (e.g., CPI-linked, production-tier-based).',
    `esg_performance_conditions` STRING COMMENT 'Description of any ESG performance conditions or sustainability criteria linked to the royalty obligation (e.g., GHG emission targets, water usage limits).',
    `estimated_reserves_quantity` DECIMAL(18,4) COMMENT 'Estimated quantity of recoverable reserves (barrels, cubic meters, tonnes, board feet) subject to this royalty obligation, used for depletion and valuation modeling.',
    `expiration_date` DATE COMMENT 'Date on which the royalty obligation terminates or expires, if applicable. Null for perpetual or life-of-asset obligations.',
    `fair_value_estimate` DECIMAL(18,2) COMMENT 'Estimated fair value of the royalty obligation liability for financial reporting and NAV calculation purposes.',
    `governing_law_jurisdiction` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the legal jurisdiction whose laws govern the royalty agreement.. Valid values are `^[A-Z]{3}$`',
    `government_jurisdiction` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the government jurisdiction imposing the royalty, if applicable.. Valid values are `^[A-Z]{3}$`',
    `indigenous_community_name` STRING COMMENT 'Name of the indigenous community or First Nation entitled to royalty payments under treaty or land rights agreements, if applicable.',
    `minimum_royalty_amount` DECIMAL(18,2) COMMENT 'Contractual minimum royalty payment due per period, regardless of production or revenue levels.',
    `notes` STRING COMMENT 'Additional notes, comments, or contextual information regarding the royalty obligation.',
    `obligation_status` STRING COMMENT 'Current lifecycle status of the royalty obligation.. Valid values are `active|suspended|terminated|in_dispute|under_review`',
    `payment_due_day` BIGINT COMMENT 'Day of the month or period on which royalty payments are due (e.g., 15th day of the month following production period).',
    `payment_frequency` STRING COMMENT 'Frequency at which royalty payments are calculated and remitted to the royalty holder.. Valid values are `monthly|quarterly|semi_annual|annual|upon_production`',
    `price_adjustment_formula` STRING COMMENT 'Contractual formula or methodology for adjusting the royalty base price, including discounts, quality adjustments, or transportation deductions.',
    `reserves_unit_of_measure` STRING COMMENT 'Unit of measure for the estimated reserves quantity (e.g., barrels for oil, cubic meters for gas, tonnes for minerals, board feet for timber).. Valid values are `barrels|cubic_meters|tonnes|board_feet|acres|hectares`',
    `royalty_agreement_number` STRING COMMENT 'External business identifier for the royalty agreement or contract governing this obligation.',
    `royalty_base_type` STRING COMMENT 'The economic basis on which the royalty rate is applied (e.g., gross revenue, net revenue, production volume, net profits, wellhead value).. Valid values are `gross_revenue|net_revenue|production_volume|net_profits|wellhead_value`',
    `royalty_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which royalty payments are denominated.. Valid values are `^[A-Z]{3}$`',
    `royalty_holder_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the royalty holder, if applicable.. Valid values are `^[A-Z0-9]{20}$`',
    `royalty_holder_name` STRING COMMENT 'Legal name of the party entitled to receive royalty payments (government entity, private landowner, indigenous community, or other rights holder).',
    `royalty_rate_percent` DECIMAL(10,6) COMMENT 'Percentage rate applied to the royalty base (production volume, revenue, or net profits) to calculate the royalty payment.',
    `royalty_type` STRING COMMENT 'Classification of the royalty obligation by legal and economic structure.. Valid values are `government_royalty|landowner_royalty|overriding_royalty_interest|net_profits_interest|production_payment|indigenous_royalty`',
    `suspension_reason` STRING COMMENT 'Reason for suspension of the royalty obligation, if applicable (e.g., force majeure, production halt, regulatory moratorium).',
    `termination_date` DATE COMMENT 'Actual date on which the royalty obligation was terminated, if applicable.',
    `termination_reason` STRING COMMENT 'Reason for termination of the royalty obligation (e.g., asset depletion, contract expiration, mutual agreement, default).',
    `treaty_reference_number` STRING COMMENT 'Reference number or identifier for the treaty, land claim agreement, or indigenous rights agreement governing the royalty obligation.',
    `updated_by_user` STRING COMMENT 'Identifier of the user or system process that last updated this record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this royalty obligation record was last modified.',
    `valuation_date` DATE COMMENT 'Date as of which the fair value estimate was determined.',
    `valuation_methodology` STRING COMMENT 'Methodology used to estimate the fair value of the royalty obligation (e.g., DCF, comparable transactions, income approach).. Valid values are `discounted_cash_flow|comparable_transactions|income_approach|market_approach`',
    CONSTRAINT pk_royalty_obligation PRIMARY KEY(`royalty_obligation_id`)
) COMMENT 'Tracks royalty, overriding royalty interest (ORRI), net profits interest (NPI), and government royalty obligations attached to natural resource assets. Captures royalty type, royalty rate (%), royalty holder (government, private landowner, indigenous';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`royalty_payment` (
    `royalty_payment_id` BIGINT COMMENT 'Unique identifier for the royalty payment transaction record.',
    `employee_id` BIGINT COMMENT 'Reference to the user who approved the royalty payment for disbursement.',
    `natural_resource_asset_id` BIGINT COMMENT 'Reference to the natural resource asset (timberland, farmland, mining, energy) generating the royalty.',
    `cash_account_id` BIGINT COMMENT 'Reference to the bank account to which the royalty payment was disbursed.',
    `record_updated_by_user_employee_id` BIGINT COMMENT 'Reference to the user who last updated the royalty payment record.',
    `royalty_obligation_id` BIGINT COMMENT 'Reference to the underlying royalty obligation contract that governs this payment.',
    `base_currency_code` STRING COMMENT 'Three-letter ISO currency code for the funds base reporting currency (typically USD, EUR, or GBP).. Valid values are `^[A-Z]{3}$`',
    `commodity_price` DECIMAL(18,6) COMMENT 'Market or contract price per unit of the commodity applied to calculate gross revenue for the royalty period.',
    `commodity_price_currency` STRING COMMENT 'Three-letter ISO currency code for the commodity price (e.g., USD, AUD).. Valid values are `^[A-Z]{3}$`',
    `cost_center_code` STRING COMMENT 'Cost center or business unit code to which the royalty payment is allocated for management reporting.',
    `deduction_amount` DECIMAL(18,2) COMMENT 'Total deductions applied to the gross royalty amount, including allowable costs, transportation, or processing fees per contract terms.',
    `dispute_flag` BOOLEAN COMMENT 'Indicator of whether the royalty payment is under dispute by the payee or internal review.',
    `dispute_reason` STRING COMMENT 'Description of the reason for dispute if the payment is flagged for review or contested by the payee.',
    `fx_rate_to_base` DECIMAL(18,8) COMMENT 'Exchange rate applied to convert local currency royalty amount to the funds base reporting currency.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which the royalty payment expense was posted.',
    `gl_posting_date` DATE COMMENT 'Date on which the royalty payment was posted to the general ledger for accounting purposes.',
    `gross_revenue_base` DECIMAL(18,2) COMMENT 'Total gross revenue calculated from production volume multiplied by commodity price, before royalty rate application.',
    `local_currency_code` STRING COMMENT 'Three-letter ISO currency code for the local currency in which the royalty is denominated.. Valid values are `^[A-Z]{3}$`',
    `net_payment_amount` DECIMAL(18,2) COMMENT 'Final net royalty payment amount after all deductions, in local currency.',
    `payee_legal_entity_code` BIGINT COMMENT 'Reference to the legal entity receiving the royalty payment (landowner, mineral rights holder, government authority).',
    `payment_approval_date` DATE COMMENT 'Date on which the royalty payment was approved by authorized personnel prior to disbursement.',
    `payment_date` DATE COMMENT 'Date on which the royalty payment was disbursed to the royalty holder.',
    `payment_method` STRING COMMENT 'Method used to disburse the royalty payment to the recipient.. Valid values are `wire_transfer|ach|check|eft|direct_deposit`',
    `payment_notes` STRING COMMENT 'Free-text notes or comments regarding the royalty payment, including any special circumstances or adjustments.',
    `payment_number` STRING COMMENT 'Business identifier for the royalty payment, typically sequential or formatted per contract terms.',
    `payment_period_end_date` DATE COMMENT 'End date of the production or revenue period covered by this royalty payment.',
    `payment_period_start_date` DATE COMMENT 'Start date of the production or revenue period covered by this royalty payment.',
    `payment_reference_number` STRING COMMENT 'External reference or transaction number assigned by the payment system or bank for reconciliation purposes.',
    `payment_status` STRING COMMENT 'Current lifecycle status of the royalty payment transaction.. Valid values are `pending|processed|settled|cancelled|disputed|reversed`',
    `production_unit_of_measure` STRING COMMENT 'Unit of measure for the production volume (barrels for oil, tonnes for minerals, board feet for timber, etc.). [ENUM-REF-CANDIDATE: barrels|tonnes|cubic_meters|board_feet|acres|megawatt_hours|ounces — 7 candidates stripped; promote to reference product]',
    `production_volume` DECIMAL(18,4) COMMENT 'Quantity of resource extracted or produced during the payment period, forming the basis for royalty calculation.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when the royalty payment record was first created in the data platform.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the royalty payment record was last updated in the data platform.',
    `reversal_date` DATE COMMENT 'Date on which the royalty payment was reversed, if applicable.',
    `reversal_flag` BOOLEAN COMMENT 'Indicator of whether this royalty payment has been reversed or cancelled after initial processing.',
    `reversal_reason` STRING COMMENT 'Explanation for why the royalty payment was reversed or cancelled.',
    `royalty_amount_base` DECIMAL(18,2) COMMENT 'Royalty payment amount converted to the funds base reporting currency for consolidated accounting.',
    `royalty_amount_local` DECIMAL(18,2) COMMENT 'Calculated royalty payment amount in the local currency of the natural resource asset or contract.',
    `royalty_rate` DECIMAL(8,6) COMMENT 'Percentage or decimal rate applied to gross revenue to determine the royalty payment amount, as specified in the royalty agreement.',
    `settlement_date` DATE COMMENT 'Date on which the royalty payment was settled and cleared through the banking system.',
    `source_system_code` STRING COMMENT 'Unique identifier of the royalty payment record in the source operational system for traceability.',
    `withholding_tax_amount` DECIMAL(18,2) COMMENT 'Tax amount withheld at source from the royalty payment per local tax regulations.',
    `withholding_tax_rate` DECIMAL(8,6) COMMENT 'Percentage rate of withholding tax applied to the royalty payment per local jurisdiction requirements.',
    CONSTRAINT pk_royalty_payment PRIMARY KEY(`royalty_payment_id`)
) COMMENT 'Transactional record of each royalty payment disbursed against a royalty obligation. Captures payment date, payment period covered, production volume basis, commodity price applied, gross revenue base, royalty rate applied, payment amount (local currency';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`land_parcel` (
    `land_parcel_id` BIGINT COMMENT 'Unique system identifier for the land parcel record.',
    `employee_id` BIGINT COMMENT 'Identifier of the internal asset manager or external manager responsible for active management and value creation on the parcel.',
    `investment_portfolio_id` BIGINT COMMENT 'Identifier of the investment portfolio or fund to which the parcel is allocated.',
    `acquisition_cost` DECIMAL(18,2) COMMENT 'Total cost paid by the fund to acquire the parcel, including purchase price and transaction costs, in base currency.',
    `acquisition_date` DATE COMMENT 'Date on which the fund acquired ownership or rights to the parcel.',
    `annual_property_tax` DECIMAL(18,2) COMMENT 'Annual property tax liability for the parcel in base currency, used for cash flow modeling and net operating income calculation.',
    `biodiversity_score` DECIMAL(5,2) COMMENT 'Quantitative biodiversity assessment score for the parcel, used for ESG integration and responsible investment stewardship.',
    `cadastral_reference` STRING COMMENT 'Government-issued cadastral or parcel identification number used for land registry and taxation purposes.',
    `carbon_sequestration_potential` DECIMAL(18,2) COMMENT 'Estimated annual carbon sequestration capacity of the parcel in metric tons of CO2 equivalent, relevant for ESG reporting and carbon credit valuation.',
    `country_code` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code indicating the jurisdiction where the parcel is located.. Valid values are `^[A-Z]{3}$`',
    `county_municipality` STRING COMMENT 'County, municipality, or secondary administrative subdivision where the parcel is located.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the parcel record was first created in the data platform.',
    `crop_type` STRING COMMENT 'Primary crop or agricultural product cultivated on the parcel, applicable to farmland parcels.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary values associated with the parcel.. Valid values are `^[A-Z]{3}$`',
    `data_source_system` STRING COMMENT 'Name of the operational system of record from which the parcel data was sourced, such as eFront or internal GIS platform.',
    `elevation_meters` DECIMAL(10,2) COMMENT 'Average elevation of the parcel above sea level in meters, relevant for agricultural and forestry productivity modeling.',
    `encumbrance_description` STRING COMMENT 'Detailed description of any legal encumbrances, liens, easements, or restrictive covenants affecting the parcel.',
    `encumbrance_flag` BOOLEAN COMMENT 'Indicates whether the parcel is subject to legal encumbrances such as liens, easements, or restrictive covenants.',
    `environmental_designation` STRING COMMENT 'Environmental protection or conservation designation affecting land use, such as protected area, wetland, or habitat conservation zone.',
    `insurance_coverage_amount` DECIMAL(18,2) COMMENT 'Total insurance coverage amount for the parcel in base currency, covering property damage, liability, and natural disaster risks.',
    `land_use_type` STRING COMMENT 'Primary classification of the parcels current use within the natural resources portfolio.. Valid values are `timberland|farmland|mining_surface|energy_surface|mixed_use|conservation`',
    `last_valuation_amount` DECIMAL(18,2) COMMENT 'Fair market value of the parcel as determined by the most recent independent valuation, in base currency.',
    `last_valuation_date` DATE COMMENT 'Date of the most recent independent valuation or appraisal of the parcel.',
    `latitude` DECIMAL(10,7) COMMENT 'Geographic latitude coordinate of the parcel centroid in decimal degrees.',
    `lease_expiry_date` DATE COMMENT 'Expiration date of the lease or rights agreement, applicable to leasehold and surface rights parcels.',
    `legal_land_description` STRING COMMENT 'Official legal description of the parcel as recorded in title documents, including metes and bounds, lot and block, or government survey system reference.',
    `longitude` DECIMAL(10,7) COMMENT 'Geographic longitude coordinate of the parcel centroid in decimal degrees.',
    `mineral_resource_type` STRING COMMENT 'Type of mineral or energy resource associated with the parcel, applicable to mining and energy surface rights.',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, special conditions, or contextual information about the parcel.',
    `ownership_type` STRING COMMENT 'Legal form of ownership or rights held by the fund over the parcel.. Valid values are `fee_simple|leasehold|surface_rights|mineral_rights|easement|co_ownership`',
    `parcel_name` STRING COMMENT 'Common or business name assigned to the land parcel for internal reference and reporting.',
    `parcel_status` STRING COMMENT 'Current operational and investment status of the land parcel within the portfolio.. Valid values are `active|under_development|conservation|divested|pending_acquisition`',
    `productive_area_hectares` DECIMAL(18,4) COMMENT 'Net productive area of the parcel in hectares, excluding non-productive zones such as wetlands, roads, and buffer zones.',
    `road_access_type` STRING COMMENT 'Type of road access available to the parcel, affecting operational logistics and asset management costs.. Valid values are `paved|gravel|seasonal|none`',
    `soil_classification` STRING COMMENT 'Soil type or classification code based on local or international soil taxonomy, relevant for agricultural and forestry valuation.',
    `state_province` STRING COMMENT 'State, province, or primary administrative subdivision where the parcel is located.',
    `timber_volume_m3` DECIMAL(18,2) COMMENT 'Total standing timber volume on the parcel in cubic meters, applicable to timberland parcels.',
    `title_deed_reference` STRING COMMENT 'Official title deed or land registry reference number for the parcel.',
    `topography_type` STRING COMMENT 'General topographic characteristic of the parcel affecting operational access and productivity.. Valid values are `flat|rolling|hilly|mountainous|mixed`',
    `total_area_hectares` DECIMAL(18,4) COMMENT 'Total land area of the parcel measured in hectares, representing the gross land holding.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp when the parcel record was last modified in the data platform.',
    `valuation_method` STRING COMMENT 'Primary valuation methodology used in the most recent appraisal of the parcel.. Valid values are `comparable_sales|income_approach|cost_approach|discounted_cash_flow|hybrid`',
    `water_access_flag` BOOLEAN COMMENT 'Indicates whether the parcel has direct access to water resources such as rivers, lakes, or irrigation systems.',
    `zoning_designation` STRING COMMENT 'Local government zoning or land use designation that governs permitted activities on the parcel.',
    CONSTRAINT pk_land_parcel PRIMARY KEY(`land_parcel_id`)
) COMMENT 'Geospatial and legal description master record for land parcels underlying timberland, farmland, and surface rights of mining/energy assets. Captures parcel identifier (legal land description, cadastral reference), total area (hectares), land use';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`environmental_permit` (
    `environmental_permit_id` BIGINT COMMENT 'Unique identifier for the environmental permit record.',
    `natural_resource_asset_id` BIGINT COMMENT 'Reference to the natural resource asset (timberland, farmland, mining, energy) to which this permit applies.',
    `amendment_count` BIGINT COMMENT 'Total number of amendments or modifications made to the original permit since issuance.',
    `authorized_activity` STRING COMMENT 'Specific operational activity or extraction process authorized under this permit (e.g., timber harvesting, mineral extraction, water withdrawal).',
    `bond_amount` DECIMAL(18,2) COMMENT 'Financial bond or security amount required to be posted for environmental reclamation or restoration obligations.',
    `bond_currency` STRING COMMENT 'Three-letter ISO currency code for the reclamation bond amount.',
    `bond_status` STRING COMMENT 'Current status of the reclamation bond or financial security.. Valid values are `posted|released|forfeited|under_review`',
    `compliance_monitoring_frequency` STRING COMMENT 'Required frequency of compliance monitoring and reporting to the regulatory authority.. Valid values are `daily|weekly|monthly|quarterly|annual|continuous`',
    `compliance_status` STRING COMMENT 'Current compliance status of the asset operations relative to permit conditions and regulatory requirements.. Valid values are `compliant|non_compliant|conditional|under_investigation`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this permit record was first created in the system.',
    `effective_date` DATE COMMENT 'Date from which the permit becomes legally effective and operational activities may commence.',
    `emissions_limit_quantity` DECIMAL(18,4) COMMENT 'Maximum allowable emissions quantity under the permit (e.g., tons of carbon dioxide equivalent, particulate matter).',
    `emissions_limit_unit` STRING COMMENT 'Unit of measure for emissions limit (e.g., metric tons CO2e, kilograms, parts per million).',
    `esg_impact_category` STRING COMMENT 'Primary ESG impact category addressed by this permit (e.g., biodiversity, water stewardship, air quality, community impact). [ENUM-REF-CANDIDATE',
    `expiry_date` DATE COMMENT 'Date on which the permit expires and must be renewed or ceases to be valid.',
    `extraction_limit_quantity` DECIMAL(18,4) COMMENT 'Maximum quantity of resource extraction or production authorized under the permit (e.g., cubic meters of water, tons of ore, board feet of timber).',
    `extraction_limit_unit` STRING COMMENT 'Unit of measure for the extraction limit quantity (e.g., cubic meters, metric tons, barrels, board feet).',
    `extraction_period` STRING COMMENT 'Time period over which the extraction limit applies (daily, monthly, annual, or total permit lifetime).. Valid values are `daily|monthly|quarterly|annual|permit_lifetime`',
    `ghg_emissions_scope` STRING COMMENT 'GHG Protocol emissions scope category covered by this permit (Scope 1 direct, Scope 2 indirect energy, Scope 3 value chain).. Valid values are `scope_1|scope_2|scope_3|not_applicable`',
    `inspection_frequency` STRING COMMENT 'Frequency at which regulatory inspections are required or expected under the permit terms.. Valid values are `monthly|quarterly|semi_annual|annual|ad_hoc`',
    `issue_date` DATE COMMENT 'Date on which the permit was officially issued by the regulatory authority.',
    `issuing_authority` STRING COMMENT 'Name of the government agency or regulatory body that issued the permit.',
    `jurisdiction` STRING COMMENT 'Geographic or administrative jurisdiction under which the permit is governed (country, state, province, or local authority).',
    `land_area_authorized_hectares` DECIMAL(18,4) COMMENT 'Total land area in hectares authorized for clearing, extraction, or operational activities under the permit.',
    `last_amendment_date` DATE COMMENT 'Date of the most recent amendment or modification to the permit terms.',
    `last_inspection_date` DATE COMMENT 'Date of the most recent regulatory inspection conducted for this permit.',
    `last_violation_date` DATE COMMENT 'Date of the most recent permit violation or non-compliance incident.',
    `next_inspection_date` DATE COMMENT 'Date of the next scheduled regulatory inspection for permit compliance verification.',
    `penalty_amount` DECIMAL(18,2) COMMENT 'Total monetary penalties assessed for permit violations or non-compliance, in local currency.',
    `penalty_currency` STRING COMMENT 'Three-letter ISO currency code for penalty amounts (e.g., USD, EUR).',
    `permit_conditions` STRING COMMENT 'Detailed text of special conditions, restrictions, or operational requirements imposed by the regulatory authority.',
    `permit_description` STRING COMMENT 'Detailed description of the scope, purpose, and conditions covered by the environmental permit.',
    `permit_document_reference` STRING COMMENT 'Reference identifier or file path to the official permit document stored in the document management system.',
    `permit_number` STRING COMMENT 'Official permit number or registration code issued by the regulatory authority.',
    `permit_status` STRING COMMENT 'Current lifecycle status of the environmental permit.. Valid values are `active|pending|expired|suspended|revoked|under_review`',
    `permit_type` STRING COMMENT 'Classification of the permit based on regulatory purpose and scope. [ENUM-REF-CANDIDATE: environmental_assessment|extraction_license|water_use|emissions|land_clearing|operating_permit|reclamation_bond — 7 candidates stripped; promote to reference product]',
    `reclamation_deadline_date` DATE COMMENT 'Date by which environmental reclamation or site restoration must be completed per permit conditions.',
    `reclamation_required_flag` BOOLEAN COMMENT 'Indicates whether environmental reclamation or site restoration is required under the permit terms.',
    `renewal_date` DATE COMMENT 'Date by which the permit renewal application must be submitted to maintain continuous compliance.',
    `reporting_requirement` STRING COMMENT 'Description of mandatory reporting obligations to the regulatory authority (frequency, format, content).',
    `responsible_party_contact` STRING COMMENT 'Contact information (email or phone) for the responsible party managing permit compliance.',
    `responsible_party_name` STRING COMMENT 'Name of the individual or entity legally responsible for permit compliance and reporting.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this permit record was last modified in the system.',
    `violation_count` BIGINT COMMENT 'Total number of permit violations or non-compliance incidents recorded since permit issuance.',
    `water_use_limit_cubic_meters` DECIMAL(18,4) COMMENT 'Maximum volume of water authorized for withdrawal or use under the permit, measured in cubic meters.',
    CONSTRAINT pk_environmental_permit PRIMARY KEY(`environmental_permit_id`)
) COMMENT 'Registry of environmental, operating, and extraction permits required for natural resource asset operations. Captures permit type (environmental assessment, extraction license, water use, emissions, land clearing), issuing regulatory authority, permit';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`carbon_credit` (
    `carbon_credit_id` BIGINT COMMENT 'Unique identifier for the carbon credit record.',
    `natural_resource_asset_id` BIGINT COMMENT 'Reference to the natural resource asset (timberland, farmland, or other) that generated or is associated with this carbon credit.',
    `carbon_project_id` BIGINT COMMENT 'Identifier of the carbon offset project that generated this credit.',
    `acquisition_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the acquisition price.. Valid values are `^[A-Z]{3}$`',
    `acquisition_date` DATE COMMENT 'Date on which the pension fund acquired ownership of this carbon credit.',
    `acquisition_price_per_tonne` DECIMAL(18,4) COMMENT 'Price paid per tonne of CO2e when acquiring this carbon credit.',
    `additionality_demonstrated_flag` BOOLEAN COMMENT 'Indicates whether the carbon project has demonstrated additionality, meaning the reductions would not have occurred without the project.',
    `buffer_pool_contribution_tonnes` DECIMAL(18,4) COMMENT 'Quantity of carbon credits contributed to the registry buffer pool to mitigate permanence risk.',
    `co_benefits_description` STRING COMMENT 'Description of additional environmental or social co-benefits delivered by the carbon project beyond carbon reduction.',
    `counterparty_name` STRING COMMENT 'Name of the counterparty from whom the carbon credit was acquired or to whom it was transferred.',
    `credit_serial_number` STRING COMMENT 'Unique serial number assigned by the registry to this carbon credit unit, serving as the externally-recognized identifier.',
    `credit_status` STRING COMMENT 'Current lifecycle status of the carbon credit in the registry and portfolio.. Valid values are `issued|held|retired|cancelled|transferred`',
    `credit_type` STRING COMMENT 'Classification of the carbon credit by market type and project category.. Valid values are `voluntary|compliance|REDD+|afforestation|reforestation|avoided_deforestation`',
    `current_market_price_per_tonne` DECIMAL(18,4) COMMENT 'Current market price per tonne of CO2e for this carbon credit type and vintage.',
    `custodian_name` STRING COMMENT 'Name of the custodian or registry account manager holding the carbon credit on behalf of the pension fund.',
    `data_source_system` STRING COMMENT 'Name of the source system or registry from which this carbon credit data was ingested.',
    `esg_rating` STRING COMMENT 'ESG rating assigned to the carbon project by an external rating agency. [ENUM-REF-CANDIDATE: AAA|AA|A|BBB|BB|B|CCC|CC|C — 9 candidates stripped; promote to reference product]',
    `expiry_date` DATE COMMENT 'Date on which the carbon credit expires if not retired, applicable to certain compliance markets.',
    `holding_purpose` STRING COMMENT 'Business purpose for holding this carbon credit within the pension fund portfolio.. Valid values are `portfolio_diversification|esg_compliance|offset_liability|trading`',
    `issuance_date` DATE COMMENT 'Date on which the carbon credit was officially issued by the registry.',
    `legal_entity_identifier` STRING COMMENT '20-character ISO 17442 Legal Entity Identifier of the counterparty or project developer.. Valid values are `^[A-Z0-9]{20}$`',
    `market_price_as_of_date` DATE COMMENT 'Date as of which the current market price was determined.',
    `market_price_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the current market price.. Valid values are `^[A-Z]{3}$`',
    `methodology_name` STRING COMMENT 'Name of the specific carbon accounting methodology used to quantify the emission reductions or removals.',
    `methodology_version` STRING COMMENT 'Version number of the carbon accounting methodology applied.',
    `permanence_risk_rating` STRING COMMENT 'Assessment of the risk that the carbon sequestration may be reversed due to natural or human factors.. Valid values are `low|medium|high`',
    `project_location_country` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code where the carbon project is located.. Valid values are `^[A-Z]{3}$`',
    `project_location_region` STRING COMMENT 'Geographic region or state within the country where the carbon project is located.',
    `quantity_tonnes_co2e` DECIMAL(18,4) COMMENT 'Quantity of carbon dioxide equivalent represented by this credit, measured in metric tonnes.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this carbon credit record was first created in the pension fund system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this carbon credit record was last updated in the pension fund system.',
    `registry_account_number` STRING COMMENT 'Account number in the carbon credit registry under which this credit is held.',
    `registry_name` STRING COMMENT 'Name of the carbon credit registry that issued and tracks this credit.. Valid values are `Verra|Gold_Standard|Climate_Action_Reserve|American_Carbon_Registry|Other`',
    `retirement_beneficiary` STRING COMMENT 'Name of the entity or individual on whose behalf the carbon credit was retired.',
    `retirement_date` DATE COMMENT 'Date on which the carbon credit was retired to offset emissions, rendering it no longer tradable.',
    `retirement_reason` STRING COMMENT 'Reason or purpose for retiring the carbon credit, such as offsetting specific emissions or meeting a commitment.',
    `sdg_alignment` STRING COMMENT 'List of United Nations Sustainable Development Goals that the carbon project contributes to.',
    `verification_body` STRING COMMENT 'Name of the independent third-party organization that verified the carbon project.',
    `verification_date` DATE COMMENT 'Date on which the carbon project was verified by the third-party body.',
    `verification_standard` STRING COMMENT 'Name of the verification standard or methodology applied to validate the carbon reduction or sequestration.',
    `vintage_year` BIGINT COMMENT 'Year in which the carbon reduction or sequestration activity occurred, determining the credits vintage classification.',
    CONSTRAINT pk_carbon_credit PRIMARY KEY(`carbon_credit_id`)
) COMMENT 'Tracks carbon credits, carbon offsets, and REDD+ credits generated by or associated with natural resource assets (particularly timberland and farmland). Captures credit type (voluntary, compliance, REDD+, afforestation), registry (Gold Standard, Verra';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`offtake_agreement` (
    `offtake_agreement_id` BIGINT COMMENT 'Unique identifier for the offtake agreement record. Primary key for this master agreement entity.',
    `employee_id` BIGINT COMMENT 'Reference to the internal portfolio manager or asset manager responsible for overseeing this offtake agreement and the underlying natural resource asset.',
    `natural_resource_asset_id` BIGINT COMMENT 'Reference to the underlying natural resource asset (timberland, farmland, mining, energy) from which production output is sold under this agreement.',
    `agreement_name` STRING COMMENT 'Human-readable descriptive name or title of the offtake agreement for internal reference and reporting.',
    `agreement_number` STRING COMMENT 'Externally-known unique business identifier for the offtake agreement, used in legal documents and counterparty communications.',
    `agreement_status` STRING COMMENT 'Current lifecycle status of the offtake agreement indicating its operational state and enforceability. [ENUM-REF-CANDIDATE: draft|negotiation|executed|active|suspended|terminated|expired — 7 candidates stripped; promote to reference product]',
    `amendment_count` BIGINT COMMENT 'Total number of formal amendments or modifications made to the offtake agreement since its original execution.',
    `annual_volume_quantity` DECIMAL(18,4) COMMENT 'Contracted annual volume of commodity to be delivered under this offtake agreement, expressed in the unit of measure specified.',
    `benchmark_index_name` STRING COMMENT 'Name of the commodity price index or benchmark used for floating or indexed pricing mechanisms, such as LME, ICE, or regional spot indices.',
    `ceiling_price_amount` DECIMAL(18,4) COMMENT 'Maximum price per unit capped under the offtake agreement, providing cost certainty for the buyer.',
    `commodity_specification` STRING COMMENT 'Detailed specification of the commodity including grade, quality standards, physical characteristics, and delivery specifications as defined in the agreement.',
    `commodity_type` STRING COMMENT 'Classification of the commodity or natural resource output being sold under this offtake agreement. [ENUM-REF-CANDIDATE: timber|agricultural_products|crude_oil|natural_gas|coal|iron_ore|copper|gold|silver|lithium|rare_earth_minerals|uranium|other — 13',
    `contract_document_reference` STRING COMMENT 'Document management system reference or file path to the executed offtake agreement legal document.',
    `contract_term_years` DECIMAL(5,2) COMMENT 'Total duration of the offtake agreement expressed in years, representing the commitment period for commodity sales.',
    `counterparty_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the offtaker counterparty, enabling global entity identification and regulatory reporting.. Valid values are `^[A-Z0-9]{20}$`',
    `counterparty_name` STRING COMMENT 'Legal name of the buyer or offtaker entity purchasing the commodity production output under this agreement.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this offtake agreement record was first created in the data platform.',
    `credit_support_amount` DECIMAL(18,2) COMMENT 'Monetary value of credit support or collateral required from the counterparty to mitigate payment default risk.',
    `credit_support_required_flag` BOOLEAN COMMENT 'Indicates whether the counterparty is required to provide credit support such as letters of credit, guarantees, or collateral to secure payment obligations.',
    `data_source_system` STRING COMMENT 'Name of the operational system of record from which this offtake agreement data was sourced, such as eFront or contract management platform.',
    `delivery_incoterm` STRING COMMENT 'International Commercial Terms code defining the allocation of costs, risks, and responsibilities between buyer and seller for commodity delivery. [ENUM-REF-CANDIDATE: EXW|FCA|CPT|CIP|DAP|DPU|DDP|FAS|FOB|CFR|CIF — 11 candidates stripped; promote to',
    `delivery_point_location` STRING COMMENT 'Physical location or facility where commodity delivery and title transfer occurs under the terms of this offtake agreement.',
    `dispute_resolution_mechanism` STRING COMMENT 'Contractually agreed method for resolving disputes arising under the offtake agreement.. Valid values are `litigation|arbitration|mediation|expert_determination`',
    `effective_date` DATE COMMENT 'Date on which the offtake agreement becomes legally binding and operative for commodity sales and deliveries.',
    `esg_certification_required_flag` BOOLEAN COMMENT 'Indicates whether the offtake agreement mandates ESG certifications or sustainability standards for the commodity production and delivery.',
    `esg_certification_type` STRING COMMENT 'Type or name of ESG certification or sustainability standard required under the offtake agreement, such as FSC, Fairtrade, or ISO 14001.',
    `expiry_date` DATE COMMENT 'Date on which the offtake agreement terminates or expires, after which no further obligations exist unless renewed.',
    `fixed_price_amount` DECIMAL(18,4) COMMENT 'Fixed price per unit for commodity sales if the pricing mechanism is fixed, representing the locked-in sale price.',
    `floor_price_amount` DECIMAL(18,4) COMMENT 'Minimum price per unit guaranteed under the offtake agreement, providing downside protection for the seller.',
    `force_majeure_clause` STRING COMMENT 'Text or reference to the force majeure provisions defining events that excuse non-performance by either party without liability.',
    `governing_law_jurisdiction` STRING COMMENT 'Legal jurisdiction and governing law specified in the offtake agreement for dispute resolution and contract interpretation.',
    `last_amendment_date` DATE COMMENT 'Date of the most recent amendment or modification to the offtake agreement terms.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'System timestamp when this offtake agreement record was most recently modified or updated.',
    `legal_counsel_name` STRING COMMENT 'Name of the external legal counsel or law firm that advised on or drafted the offtake agreement.',
    `minimum_offtake_percentage` DECIMAL(5,2) COMMENT 'Minimum percentage of contracted annual volume that the buyer is obligated to purchase under take-or-pay or minimum purchase provisions.',
    `payment_terms_days` BIGINT COMMENT 'Number of days from delivery or invoice date within which the counterparty must remit payment for commodity purchases.',
    `price_adjustment_formula` STRING COMMENT 'Mathematical formula or methodology for calculating price adjustments based on benchmark indices, inflation, or other contractual factors.',
    `price_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all pricing and payment terms in this offtake agreement.. Valid values are `^[A-Z]{3}$`',
    `pricing_mechanism` STRING COMMENT 'Type of pricing structure governing commodity sales under this agreement, determining how prices are set or adjusted over time.. Valid values are `fixed|floating|indexed|cost_plus|hybrid`',
    `renewal_option_flag` BOOLEAN COMMENT 'Indicates whether the offtake agreement includes an option for either party to renew or extend the contract term beyond the initial expiry date.',
    `take_or_pay_flag` BOOLEAN COMMENT 'Indicates whether the agreement includes a take-or-pay provision requiring the buyer to pay for minimum volumes regardless of actual offtake.',
    `termination_notice_days` BIGINT COMMENT 'Number of days advance notice required by either party to terminate the offtake agreement under voluntary termination provisions.',
    `total_contract_volume_quantity` DECIMAL(18,4) COMMENT 'Total cumulative volume of commodity committed over the entire term of the offtake agreement.',
    `volume_unit_of_measure` STRING COMMENT 'Standard unit of measure for commodity volumes specified in this offtake agreement. [ENUM-REF-CANDIDATE: tonnes|barrels|cubic_meters|board_feet|bushels|pounds|kilograms|megawatt_hours|troy_ounces — 9 candidates stripped; promote to reference product]',
    CONSTRAINT pk_offtake_agreement PRIMARY KEY(`offtake_agreement_id`)
) COMMENT 'Master record for offtake agreements and commodity sales contracts governing the sale of production output from natural resource assets. Captures counterparty name, LEI, commodity type, contract volume (annual/total), pricing mechanism (fixed, floating';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`commodity_price_deck` (
    `commodity_price_deck_id` BIGINT COMMENT 'Unique identifier for the commodity price deck record.',
    `created_by_user_employee_id` BIGINT COMMENT 'Identifier of the user who created this price deck record.',
    `employee_id` BIGINT COMMENT 'Identifier of the user or committee member who approved this price deck.',
    `last_modified_by_user_employee_id` BIGINT COMMENT 'Identifier of the user who last modified this price deck record.',
    `market_data_feed_id` BIGINT COMMENT 'Foreign key linking to research.market_data_feed. Business justification: Price decks are sourced from market data feeds for real‑time pricing.',
    `natural_resource_asset_id` BIGINT COMMENT 'Reference to the natural resource asset this price deck applies to.',
    `approval_date` DATE COMMENT 'Date when this price deck was approved by the Investment Committee (IC) or authorized body.',
    `benchmark_index` STRING COMMENT 'Market benchmark or index used as reference for this commodity price (e.g., WTI, Brent, LME).',
    `commodity_subtype` STRING COMMENT 'Specific subtype or grade of the commodity (e.g., WTI, Brent, Henry Hub).',
    `commodity_type` STRING COMMENT 'Type of commodity covered by this price deck. [ENUM-REF-CANDIDATE: crude_oil|natural_gas|gold|silver|copper|iron_ore|coal|timber|agricultural — 9 candidates stripped; promote to reference product]',
    `confidence_level` STRING COMMENT 'Confidence level in the accuracy of this price forecast.. Valid values are `high|medium|low`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this price deck record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code for the price denomination.. Valid values are `^[A-Z]{3}$`',
    `deck_name` STRING COMMENT 'Business name or label for this commodity price deck.',
    `deck_status` STRING COMMENT 'Current lifecycle status of the price deck.. Valid values are `draft|approved|active|superseded|archived`',
    `deck_version` STRING COMMENT 'Version identifier for this price deck iteration.',
    `effective_date` DATE COMMENT 'Date from which this price deck becomes effective for valuation and forecasting.',
    `esg_impact_consideration` STRING COMMENT 'Description of ESG factors considered in the price forecast (e.g., carbon pricing, regulatory changes).',
    `expiry_date` DATE COMMENT 'Date after which this price deck is no longer valid.',
    `forecast_quarter` BIGINT COMMENT 'Calendar quarter within the forecast year (1-4), if applicable.',
    `forecast_year` BIGINT COMMENT 'Calendar year for which this price forecast applies.',
    `geographic_region` STRING COMMENT 'Geographic region or market for which this price deck applies.',
    `geopolitical_risk_factor` STRING COMMENT 'Assessment of geopolitical risk impacting commodity price stability.. Valid values are `low|medium|high`',
    `inflation_adjustment_flag` BOOLEAN COMMENT 'Indicates whether the price forecast includes inflation adjustment (real vs nominal prices).',
    `inflation_rate_assumption` DECIMAL(5,4) COMMENT 'Annual inflation rate assumption used in the price forecast, expressed as a decimal.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this price deck record was last modified.',
    `last_review_date` DATE COMMENT 'Date when this price deck was last reviewed or updated.',
    `market_conditions_summary` STRING COMMENT 'Summary of macroeconomic and market conditions underlying the price forecast.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next review or update of this price deck.',
    `notes` STRING COMMENT 'Additional notes or commentary regarding this price deck.',
    `price_ceiling` DECIMAL(18,4) COMMENT 'Maximum price assumption used in upside scenario analysis.',
    `price_floor` DECIMAL(18,4) COMMENT 'Minimum price assumption used in stress testing or downside scenario analysis.',
    `price_horizon` STRING COMMENT 'Time horizon for the price forecast (spot, short-term 1-3 years, medium-term 3-10 years, long-term 10+ years).. Valid values are `spot|short_term|medium_term|long_term`',
    `price_per_unit` DECIMAL(18,4) COMMENT 'Forecasted price per unit of the commodity.',
    `review_frequency` STRING COMMENT 'Frequency at which this price deck is reviewed and updated.. Valid values are `monthly|quarterly|semi_annual|annual|ad_hoc`',
    `scenario_type` STRING COMMENT 'Economic scenario assumption for this price deck (base case, bull case, bear case, stress test).. Valid values are `base|bull|bear|stress|optimistic|pessimistic`',
    `source_provider` STRING COMMENT 'Name of the external provider or internal team that generated the price forecast.',
    `source_report_reference` STRING COMMENT 'Reference identifier or document name of the source report or research publication.',
    `source_type` STRING COMMENT 'Source of the price forecast (internal research, external consultant, market consensus, proprietary model).. Valid values are `internal|external|consensus|proprietary`',
    `supply_demand_balance` STRING COMMENT 'Assumed supply-demand balance for the commodity in the forecast period.. Valid values are `surplus|balanced|deficit`',
    `unit_of_measure` STRING COMMENT 'Unit of measure for the commodity price (barrel, MMBtu, troy ounce, metric ton). [ENUM-REF-CANDIDATE: barrel|mmbtu|troy_ounce|metric_ton|cubic_meter|board_foot|bushel — 7 candidates stripped; promote to reference product]',
    `usage_purpose` STRING COMMENT 'Intended use of this price deck (DCF valuation, budget forecasting, stress testing, portfolio modeling). [ENUM-REF-CANDIDATE: dcf_valuation|budget_forecasting|stress_testing|portfolio_modeling|risk_analysis|performance_attribution|regulatory_reporting —',
    `valuation_methodology` STRING COMMENT 'Methodology used to derive the commodity price forecast (e.g., DCF, futures curve, econometric model).',
    `volatility_assumption` DECIMAL(5,4) COMMENT 'Price volatility assumption used in scenario modeling, expressed as a decimal.',
    CONSTRAINT pk_commodity_price_deck PRIMARY KEY(`commodity_price_deck_id`)
) COMMENT 'Reference price deck for commodities used in DCF valuation, budget forecasting, and stress testing of natural resource assets. Captures commodity type, scenario (base/bull/bear/stress), price per unit by horizon (short/medium/long-term), currency';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`resource_budget` (
    `resource_budget_id` BIGINT COMMENT 'Unique identifier for the natural resource asset budget record.',
    `asset_manager_employee_id` BIGINT COMMENT 'Reference to the asset manager responsible for this natural resource asset and its budget.',
    `employee_id` BIGINT COMMENT 'Identifier of the user or committee member who approved the budget.',
    `investment_portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio to which this natural resource asset and budget belong.',
    `natural_resource_asset_id` BIGINT COMMENT 'Reference to the natural resource asset this budget applies to.',
    `prepared_by_user_employee_id` BIGINT COMMENT 'Identifier of the user who prepared the budget.',
    `reserve_estimate_id` BIGINT COMMENT 'Foreign key linking to naturalresource.reserve_estimate. Business justification: Resource budgets include production volume targets that should align with reserve estimates. The budgets production assumptions are based on a specific reserve estimate.',
    `approval_date` DATE COMMENT 'Date on which the budget was formally approved by the Investment Committee or authorized body.',
    `budget_amount` DECIMAL(18,2) COMMENT 'Total budgeted amount for this category and period in local currency.',
    `budget_category` STRING COMMENT 'Detailed category of expenditure within the budget type such as labor, equipment, materials, utilities, maintenance, or environmental compliance.',
    `budget_notes` STRING COMMENT 'Additional notes, assumptions, or commentary supporting the budget submission.',
    `budget_number` STRING COMMENT 'Externally-known unique identifier for this budget submission or version.',
    `budget_period_end_date` DATE COMMENT 'End date of the period covered by this budget.',
    `budget_period_start_date` DATE COMMENT 'Start date of the period covered by this budget.',
    `budget_status` STRING COMMENT 'Current approval and lifecycle status of the budget. [ENUM-REF-CANDIDATE: draft|submitted|under_review|approved|rejected|revised|active|closed — 8 candidates stripped; promote to reference product]',
    `budget_type` STRING COMMENT 'Classification of budget expenditure: operating expense, capital expense, sustaining capital, growth capital, reclamation, closure, exploration, or development.',
    `budget_year` BIGINT COMMENT 'Fiscal year for which this budget is prepared.',
    `cash_flow_forecast` DECIMAL(18,2) COMMENT 'Forecasted net cash flow from operations for the budget period.',
    `commodity_price_assumption` DECIMAL(18,4) COMMENT 'Assumed commodity price per unit used in budget revenue and cost projections.',
    `commodity_price_currency` STRING COMMENT 'Currency code for the commodity price assumption.. Valid values are `^[A-Z]{3}$`',
    `contingency_reserve` DECIMAL(18,2) COMMENT 'Budgeted contingency reserve for unforeseen costs or operational variability.',
    `cost_center_code` STRING COMMENT 'Cost center code for internal management accounting and budget tracking.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the budget amount.. Valid values are `^[A-Z]{3}$`',
    `depletion_expense` DECIMAL(18,2) COMMENT 'Budgeted depletion expense for natural resource extraction during the period.',
    `depreciation_expense` DECIMAL(18,2) COMMENT 'Budgeted depreciation expense for property, plant, and equipment during the period.',
    `ebitda_forecast` DECIMAL(18,2) COMMENT 'Forecasted EBITDA for the budget period reflecting operating performance before non-cash charges.',
    `energy_consumption_target_mwh` DECIMAL(18,2) COMMENT 'Target energy consumption in megawatt hours for the budget period.',
    `environmental_compliance_cost` DECIMAL(18,2) COMMENT 'Budgeted cost for environmental monitoring, reporting, and compliance activities.',
    `ghg_emissions_target_tonnes` DECIMAL(18,2) COMMENT 'Target greenhouse gas emissions in tonnes of carbon dioxide equivalent for the budget period.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this budget line is mapped for financial reporting.',
    `production_unit_of_measure` STRING COMMENT 'Unit of measure for production volume such as barrels, cubic meters, tonnes, board feet, or bushels.',
    `production_volume_target` DECIMAL(18,4) COMMENT 'Approved target production volume for the budget period.',
    `reclamation_provision` DECIMAL(18,2) COMMENT 'Budgeted provision for asset retirement and land reclamation obligations.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this budget record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this budget record was last updated in the system.',
    `revenue_forecast` DECIMAL(18,2) COMMENT 'Forecasted gross revenue for the budget period based on production and commodity price assumptions.',
    `revision_number` BIGINT COMMENT 'Sequential revision number for tracking budget versions and amendments.',
    `revision_reason` STRING COMMENT 'Explanation for why the budget was revised including changes in commodity prices, production targets, or operational conditions.',
    `safety_incident_target` BIGINT COMMENT 'Target maximum number of recordable safety incidents for the budget period.',
    `submission_date` DATE COMMENT 'Date on which the budget was submitted for review and approval.',
    `variance_threshold_percentage` DECIMAL(5,2) COMMENT 'Acceptable variance threshold percentage for budget versus actual performance before escalation is required.',
    `water_usage_target_cubic_meters` DECIMAL(18,2) COMMENT 'Target water consumption in cubic meters for the budget period.',
    `workforce_headcount_target` BIGINT COMMENT 'Planned workforce headcount for the budget period including direct employees and contractors.',
    CONSTRAINT pk_resource_budget PRIMARY KEY(`resource_budget_id`)
) COMMENT 'Annual operating and capital expenditure budget for each natural resource asset. Captures budget year, budget type (opex, capex, sustaining capex, growth capex, reclamation/closure), budget amount by category, approved production volume targets, commodity';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`reclamation_liability` (
    `reclamation_liability_id` BIGINT COMMENT 'Unique identifier for the asset retirement obligation and site reclamation liability record.',
    `environmental_permit_id` BIGINT COMMENT 'Foreign key linking to naturalresource.environmental_permit. Business justification: Reclamation liabilities (ARO) often arise from environmental permit conditions. The permit specifies reclamation requirements, deadlines, and bond amounts.',
    `natural_resource_asset_id` BIGINT COMMENT 'Reference to the extractive resource asset (mining, oil & gas, timberland) subject to reclamation obligation.',
    `accretion_expense_current_period` DECIMAL(18,2) COMMENT 'Periodic increase in the carrying amount of the ARO liability due to passage of time, recognized as operating expense in the current reporting period.',
    `actual_expenditure_to_date` DECIMAL(18,2) COMMENT 'Cumulative cash outflows incurred for reclamation activities to date, reducing the outstanding liability balance as work is performed.',
    `area_to_reclaim_hectares` DECIMAL(12,2) COMMENT 'Total land area in hectares requiring reclamation work including disturbed surface, tailings ponds, waste rock piles, and access roads.',
    `aro_reference_number` STRING COMMENT 'Business identifier for the asset retirement obligation used in financial reporting and regulatory filings.',
    `bond_expiry_date` DATE COMMENT 'Expiration date of the reclamation bond requiring renewal or replacement to maintain regulatory compliance and permit validity.',
    `bond_provider` STRING COMMENT 'Name of the financial institution or surety company providing the reclamation bond or financial assurance instrument.',
    `carbon_sequestration_potential` DECIMAL(12,2) COMMENT 'Estimated carbon dioxide equivalent that will be sequestered through revegetation and ecosystem restoration as part of reclamation activities, supporting net-zero commitments.',
    `contingent_liability_flag` BOOLEAN COMMENT 'Indicates whether the reclamation obligation is contingent on future events (e.g., permit expiry, production cessation) rather than a present obligation requiring immediate recognition.',
    `cost_center_code` STRING COMMENT 'Internal cost center or business unit code responsible for managing the natural resource asset and associated reclamation liability.',
    `cost_estimation_method` STRING COMMENT 'Methodology used to develop the undiscounted reclamation cost estimate, determining the reliability and audit trail of the liability valuation.. Valid values are `engineering_estimate|comparable_site|regulatory_formula|third_party_appraisal|historical_actual`',
    `cost_estimator_name` STRING COMMENT 'Name of the engineering firm, consultant, or internal team responsible for preparing the reclamation cost estimate and supporting documentation.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this reclamation liability record was first created in the data platform, supporting audit trail and data lineage requirements.',
    `cumulative_accretion_expense` DECIMAL(18,2) COMMENT 'Total accretion expense recognized since initial recognition of the ARO, representing the time-value growth of the liability to date.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this reclamation liability record.. Valid values are `^[A-Z]{3}$`',
    `discount_rate` DECIMAL(8,4) COMMENT 'Credit-adjusted risk-free rate applied to calculate the present value of the asset retirement obligation, expressed as a decimal (e.g., 0.0350 for 3.50%).',
    `esg_impact_category` STRING COMMENT 'Primary ESG dimension addressed by the reclamation obligation, used for responsible investment reporting and TCFD climate risk disclosure.. Valid values are `land_restoration|water_quality|biodiversity|community_health|air_quality|waste_management`',
    `estimate_date` DATE COMMENT 'Date when the current reclamation cost estimate was prepared or last updated, establishing the baseline for financial reporting and regulatory compliance.',
    `estimated_duration_months` BIGINT COMMENT 'Expected time period in months required to complete all reclamation activities from commencement to final regulatory certification.',
    `expected_settlement_date` DATE COMMENT 'Estimated date when the reclamation work is expected to be completed and the liability settled, typically aligned with end of asset productive life.',
    `fair_value_hierarchy_level` STRING COMMENT 'IFRS 13 fair value hierarchy classification for the ARO liability valuation inputs, typically Level 3 due to unobservable inputs and significant estimation uncertainty.. Valid values are `level_1|level_2|level_3`',
    `funding_status` STRING COMMENT 'Assessment of whether adequate financial resources (bonds, trust funds, restricted cash) are in place to cover the estimated reclamation liability.. Valid values are `unfunded|partially_funded|fully_funded|overfunded`',
    `gl_account_code` STRING COMMENT 'Chart of accounts code for the ARO liability account in the general ledger, enabling financial statement mapping and audit trail.',
    `inflation_rate_assumption` DECIMAL(6,4) COMMENT 'Annual inflation rate assumption applied to escalate future reclamation costs from current dollars to expected future nominal dollars, expressed as decimal.',
    `initial_recognition_date` DATE COMMENT 'Date when the asset retirement obligation was first recognized on the balance sheet per accounting standards.',
    `jurisdiction` STRING COMMENT 'Three-letter country code identifying the legal jurisdiction governing the reclamation obligation and environmental compliance requirements.. Valid values are `^[A-Z]{3}$`',
    `last_revision_date` DATE COMMENT 'Date of the most recent update to the reclamation cost estimate or ARO liability valuation assumptions.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Date and time of the most recent modification to this reclamation liability record, enabling change tracking and data quality monitoring.',
    `liability_status` STRING COMMENT 'Current state of the reclamation liability in its lifecycle from initial estimation through final completion and regulatory sign-off.. Valid values are `estimated|approved|funded|in_progress|completed|disputed`',
    `liability_type` STRING COMMENT 'Classification of the reclamation obligation based on the nature of the extractive activity and required remediation work. [ENUM-REF-CANDIDATE',
    `monitoring_period_years` BIGINT COMMENT 'Required post-reclamation monitoring and maintenance period in years before final regulatory sign-off and liability release can be obtained.',
    `present_value_aro` DECIMAL(18,2) COMMENT 'Discounted present value of the estimated reclamation cost recognized as a liability on the balance sheet per accounting standards.',
    `reclamation_bond_amount` DECIMAL(18,2) COMMENT 'Financial assurance or surety bond posted with regulatory authorities to guarantee funding for site reclamation if the operator defaults.',
    `reclamation_plan_reference` STRING COMMENT 'Document identifier or reference number for the approved site reclamation plan filed with environmental regulators detailing closure activities and timeline.',
    `reclamation_scope_description` STRING COMMENT 'Detailed narrative of the required reclamation activities including land recontouring, revegetation, water treatment, structure removal, and monitoring obligations.',
    `regulatory_approval_date` DATE COMMENT 'Date when the reclamation plan and cost estimate were approved by the relevant environmental regulatory authority.',
    `regulatory_authority` STRING COMMENT 'Name of the government agency or environmental regulator with jurisdiction over the reclamation obligation and site closure requirements.',
    `regulatory_deadline_date` DATE COMMENT 'Mandatory completion date imposed by environmental regulators or permit conditions for site reclamation activities.',
    `remaining_liability_balance` DECIMAL(18,2) COMMENT 'Current outstanding ARO liability after adjusting for accretion, revisions, and actual expenditures, representing the present value of future reclamation obligations.',
    `responsible_party_name` STRING COMMENT 'Legal entity or operating partner with primary contractual and regulatory responsibility for executing and funding the reclamation work.',
    `revision_amount` DECIMAL(18,2) COMMENT 'Change in the ARO liability due to revised cost estimates, timing changes, or discount rate adjustments, recorded as adjustment to asset carrying value or expense.',
    `sensitivity_analysis_performed` BOOLEAN COMMENT 'Indicates whether sensitivity analysis on key assumptions (discount rate, cost inflation, timing) has been performed to assess ARO valuation risk and range of outcomes.',
    `trust_fund_balance` DECIMAL(18,2) COMMENT 'Current balance of dedicated reclamation trust fund or restricted cash account set aside to fund future site closure and remediation activities.',
    `undiscounted_cost_estimate` DECIMAL(18,2) COMMENT 'Total estimated cost of reclamation activities in nominal future dollars before applying present value discount, representing the full expected cash outflow.',
    `valuation_notes` STRING COMMENT 'Free-text commentary on significant assumptions, estimation uncertainties, changes from prior period, or other relevant context for the ARO liability valuation.',
    CONSTRAINT pk_reclamation_liability PRIMARY KEY(`reclamation_liability_id`)
) COMMENT 'Asset retirement obligation (ARO) and site reclamation liability records for mining, oil & gas, and other extractive resource assets. Captures estimated reclamation cost (undiscounted), discount rate applied, present value of ARO, accretion expense per';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` (
    `resource_fund_commitment_id` BIGINT COMMENT 'Unique identifier for the natural resource fund commitment record.',
    `fund_id` BIGINT COMMENT 'Reference to the external natural resource fund in which the pension fund is investing as a Limited Partner (LP).',
    `investment_portfolio_id` BIGINT COMMENT 'Reference to the internal investment portfolio that holds this natural resource fund commitment.',
    `resource_vehicle_id` BIGINT COMMENT 'Foreign key linking to naturalresource.resource_vehicle. Business justification: Resource fund commitments are LP commitments to natural resource funds/vehicles. The commitment should link to the specific resource_vehicle being invested in.',
    `biodiversity_commitment_flag` BOOLEAN COMMENT 'Indicates whether the fund has explicit biodiversity protection or enhancement commitments in its investment mandate.',
    `carbon_intensity_target` DECIMAL(10,2) COMMENT 'Target greenhouse gas (GHG) emissions intensity for the fund portfolio, measured in tonnes CO2 equivalent per unit of production or revenue, aligned with climate commitments.',
    `carried_interest_rate` DECIMAL(5,4) COMMENT 'Performance fee rate payable to the General Partner (GP) on profits above the hurdle rate, typically 20% for natural resource funds.',
    `catch_up_provision` STRING COMMENT 'Description of the catch-up mechanism allowing the General Partner (GP) to receive a higher share of profits after the hurdle rate is met, until the target carry split is achieved.',
    `commitment_amount` DECIMAL(18,2) COMMENT 'Total capital amount committed by the pension fund to the natural resource fund, representing the maximum capital that may be called over the funds life.',
    `commitment_currency` STRING COMMENT 'ISO 4217 three-letter currency code in which the commitment amount is denominated.. Valid values are `^[A-Z]{3}$`',
    `commitment_date` DATE COMMENT 'Date on which the pension fund formally committed capital to the natural resource fund, typically the date the Limited Partnership Agreement (LPA) was executed.',
    `commitment_number` STRING COMMENT 'Externally-known unique identifier for this fund commitment, typically assigned by the General Partner (GP) or internal deal tracking system.',
    `commitment_status` STRING COMMENT 'Current lifecycle status of the fund commitment, indicating whether capital is still being called or the commitment has been fulfilled or terminated.. Valid values are `pending|active|fully_called|terminated|defaulted`',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this commitment record was first created in the data platform.',
    `custodian_name` STRING COMMENT 'Name of the third-party custodian or fund administrator holding legal title to the fund interests on behalf of the pension fund.',
    `deal_team_lead` STRING COMMENT 'Name of the internal investment professional responsible for originating, underwriting, and monitoring this fund commitment.',
    `distributions_received` DECIMAL(18,2) COMMENT 'Cumulative cash distributions received by the pension fund from the natural resource fund, including return of capital and realized gains.',
    `dpi` DECIMAL(10,4) COMMENT 'Cash-on-cash return multiple calculated as distributions received divided by paid-in capital, indicating realized value returned.',
    `esg_classification` STRING COMMENT 'Sustainable Finance Disclosure Regulation (SFDR) classification indicating the funds ESG integration level: Article 6 (no sustainability focus), Article 8 (promotes ESG), Article 9 (sustainable objective).. Valid values are `article_6|article_8|article_9|not_classified`',
    `final_closing_date` DATE COMMENT 'Date of the funds final closing after which no additional Limited Partners (LPs) may join and total fund size is fixed.',
    `first_closing_date` DATE COMMENT 'Date of the funds initial closing when the General Partner (GP) began accepting capital commitments.',
    `fund_size_total` DECIMAL(18,2) COMMENT 'Total capital commitments raised by the fund from all Limited Partners (LPs) at final closing, representing the funds aggregate investment capacity.',
    `fund_strategy` STRING COMMENT 'Primary investment strategy of the natural resource fund, indicating the type of resource assets targeted.. Valid values are `timberland|farmland|mining|energy|commodity|diversified_natural_resources`',
    `fund_term_years` BIGINT COMMENT 'Total contractual term of the fund in years, typically 10-15 years for natural resource funds, after which the fund must liquidate or seek extension.',
    `geographic_focus` STRING COMMENT 'Primary geographic regions or countries targeted by the natural resource fund for investment, using ISO 3166 country codes or regional descriptors.',
    `gp_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the General Partner, used for regulatory reporting and counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `gp_name` STRING COMMENT 'Legal name of the General Partner managing the natural resource fund.',
    `hurdle_rate` DECIMAL(5,4) COMMENT 'Minimum annualized return threshold that Limited Partners (LPs) must achieve before the General Partner (GP) earns carried interest, typically 8% for natural resource funds.',
    `investment_committee_approval_date` DATE COMMENT 'Date on which the pension funds Investment Committee (IC) formally approved the commitment to this natural resource fund.',
    `investment_period_end_date` DATE COMMENT 'Date after which the General Partner (GP) may no longer make new investments, typically 3-5 years from first closing.',
    `irr` DECIMAL(10,4) COMMENT 'Annualized time-weighted return on the fund commitment, calculated using cash flows (capital calls and distributions) and current NAV.',
    `key_person_clause` STRING COMMENT 'Description of the key person provisions in the Limited Partnership Agreement (LPA) that suspend the investment period if specified senior investment professionals leave the General Partner (GP).',
    `last_capital_call_date` DATE COMMENT 'Date of the most recent capital call notice issued by the General Partner (GP) for this commitment.',
    `last_distribution_date` DATE COMMENT 'Date of the most recent cash distribution received by the pension fund from the natural resource fund.',
    `lp_ownership_percentage` DECIMAL(5,4) COMMENT 'Pension funds proportional ownership stake in the fund, calculated as commitment amount divided by fund size total.',
    `management_fee_rate` DECIMAL(5,4) COMMENT 'Annual management fee rate charged by the General Partner (GP), typically expressed as a percentage of committed capital during investment period and NAV thereafter.',
    `nav` DECIMAL(18,2) COMMENT 'Current fair value of the pension funds remaining investment in the natural resource fund, representing unrealized value as of the latest valuation date.',
    `nav_date` DATE COMMENT 'As-of date for the reported Net Asset Value (NAV), typically quarterly or annually per the funds reporting schedule.',
    `paid_in_capital` DECIMAL(18,2) COMMENT 'Cumulative amount of capital called and funded by the pension fund to date, representing actual cash invested.',
    `pri_signatory_flag` BOOLEAN COMMENT 'Indicates whether the General Partner (GP) is a signatory to the United Nations Principles for Responsible Investment (PRI).',
    `rvpi` DECIMAL(10,4) COMMENT 'Unrealized value multiple calculated as NAV divided by paid-in capital, indicating remaining unrealized value.',
    `side_letter_flag` BOOLEAN COMMENT 'Indicates whether the pension fund negotiated a side letter with the General Partner (GP) granting special rights, fee discounts, or reporting provisions.',
    `tvpi` DECIMAL(10,4) COMMENT 'Performance multiple calculated as (distributions received plus NAV) divided by paid-in capital, indicating total value creation.',
    `unfunded_commitment` DECIMAL(18,2) COMMENT 'Remaining uncalled capital commitment available for future capital calls, calculated as commitment amount minus paid-in capital.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp when this commitment record was last modified, used for audit trail and data lineage.',
    `vintage_year` BIGINT COMMENT 'Year in which the fund held its initial closing and began making capital calls, used for performance benchmarking and cohort analysis.',
    CONSTRAINT pk_resource_fund_commitment PRIMARY KEY(`resource_fund_commitment_id`)
) COMMENT 'Commitment record for natural resource fund investments where the pension fund participates as an LP in a dedicated natural resource fund (timberland fund, farmland fund, commodity fund, energy fund).';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`resource_cashflow` (
    `resource_cashflow_id` BIGINT COMMENT 'Unique identifier for the natural resource cash flow record.',
    `cash_account_id` BIGINT COMMENT 'Reference to the bank account used for the cash flow transaction.',
    `counterparty_id` BIGINT COMMENT 'Reference to the counterparty legal entity involved in the transaction.',
    `employee_id` BIGINT COMMENT 'Reference to the user who approved this cash flow record.',
    `investment_portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio that owns this natural resource asset.',
    `natural_resource_asset_id` BIGINT COMMENT 'Reference to the natural resource asset generating this cash flow.',
    `offtake_agreement_id` BIGINT COMMENT 'Foreign key linking to naturalresource.offtake_agreement. Business justification: Resource cashflows from commodity sales are governed by offtake agreements. The cashflow has contract_reference_number which is a denormalized reference.',
    `accrual_date` DATE COMMENT 'Date when the cash flow was accrued for accounting purposes.',
    `approval_date` DATE COMMENT 'Date when the cash flow record was approved by authorized personnel.',
    `base_currency_code` STRING COMMENT 'ISO 4217 three-letter code for the base reporting currency.. Valid values are `^[A-Z]{3}$`',
    `capital_expenditure_amount` DECIMAL(18,2) COMMENT 'Capital expenditures for asset development or infrastructure.',
    `cashflow_category` STRING COMMENT 'Detailed business category of the cash flow transaction.. Valid values are `commodity_sales|royalty_payment|operating_expense|capital_expenditure|reclamation_contribution|lease_payment`',
    `cashflow_period_end_date` DATE COMMENT 'End date of the period covered by this cash flow record.',
    `cashflow_period_start_date` DATE COMMENT 'Start date of the period covered by this cash flow record.',
    `cashflow_status` STRING COMMENT 'Current status of the cash flow record in its lifecycle.. Valid values are `forecasted|accrued|settled|reversed|disputed`',
    `cashflow_type` STRING COMMENT 'Classification of the cash flow by activity type per accounting standards.. Valid values are `operating_inflow|operating_outflow|investing_outflow|financing_inflow|financing_outflow|distribution`',
    `commodity_price_per_unit` DECIMAL(18,4) COMMENT 'Realized price per unit of commodity for revenue cash flows.',
    `commodity_type` STRING COMMENT 'Type of commodity associated with this cash flow if applicable. [ENUM-REF-CANDIDATE: timber|agricultural_crop|crude_oil|natural_gas|coal|gold|copper|iron_ore|other_mineral — 9 candidates stripped; promote to reference product]',
    `cost_center_code` STRING COMMENT 'Cost center code for internal management accounting and allocation.',
    `counterparty_legal_entity_code` BIGINT COMMENT 'Reference to the counterparty legal entity involved in the transaction.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this cash flow record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the cash flow amounts.. Valid values are `^[A-Z]{3}$`',
    `depletion_charge_amount` DECIMAL(18,2) COMMENT 'Non-cash depletion charge allocated to this period for resource consumption.',
    `dispute_flag` BOOLEAN COMMENT 'Indicates whether this cash flow is under dispute.',
    `dispute_reason` STRING COMMENT 'Explanation of the dispute if the cash flow is contested.',
    `esg_impact_category` STRING COMMENT 'ESG impact category associated with this cash flow for responsible investment reporting.. Valid values are `carbon_sequestration|biodiversity_conservation|water_management|community_benefit|reclamation|emissions_reduction`',
    `fx_rate_to_base` DECIMAL(18,8) COMMENT 'Exchange rate used to convert local currency to base reporting currency.',
    `gl_account_code` STRING COMMENT 'General ledger account code for financial reporting and accounting.',
    `gross_revenue_amount` DECIMAL(18,2) COMMENT 'Total gross revenue before deductions for the period.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this cash flow record was last updated.',
    `net_cashflow_amount` DECIMAL(18,2) COMMENT 'Net cash flow amount after all inflows and outflows for the period.',
    `net_cashflow_base_amount` DECIMAL(18,2) COMMENT 'Net cash flow amount converted to base reporting currency.',
    `notes` STRING COMMENT 'Additional notes or comments regarding this cash flow record.',
    `operating_expense_amount` DECIMAL(18,2) COMMENT 'Operating expenses incurred for resource extraction or production.',
    `payment_method` STRING COMMENT 'Method used for payment or receipt of funds.. Valid values are `wire_transfer|ach|check|cash|offset`',
    `production_unit_of_measure` STRING COMMENT 'Unit of measure for the production volume. [ENUM-REF-CANDIDATE: cubic_meters|barrels|tonnes|metric_tons|hectares|acres|board_feet|bushels — 8 candidates stripped; promote to reference product]',
    `production_volume` DECIMAL(18,4) COMMENT 'Quantity of commodity produced or sold during the period.',
    `reclamation_contribution_amount` DECIMAL(18,2) COMMENT 'Contributions to reclamation or environmental restoration funds.',
    `reversal_date` DATE COMMENT 'Date when the cash flow was reversed if applicable.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether this cash flow record has been reversed.',
    `reversal_reason` STRING COMMENT 'Explanation for why the cash flow was reversed.',
    `royalty_amount` DECIMAL(18,2) COMMENT 'Royalty payment amount to landowners or government entities.',
    `settlement_date` DATE COMMENT 'Date when the cash flow was settled or payment was received or made.',
    `source_system_record_code` STRING COMMENT 'Unique identifier of this record in the source system for traceability.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Tax payments including severance tax, property tax, or income tax.',
    `transaction_date` DATE COMMENT 'Date when the cash flow transaction occurred or was recognized.',
    CONSTRAINT pk_resource_cashflow PRIMARY KEY(`resource_cashflow_id`)
) COMMENT 'Periodic cash flow records at the asset level capturing all cash inflows and outflows from natural resource operations. Includes revenue from commodity sales, royalty payments, operating expenses, capital expenditures, reclamation fund contributions';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`operational_incident` (
    `operational_incident_id` BIGINT COMMENT 'Unique identifier for the operational incident record affecting natural resource asset operations.',
    `natural_resource_asset_id` BIGINT COMMENT 'Reference to the natural resource asset affected by this operational incident.',
    `corrective_action_plan` STRING COMMENT 'Summary of the corrective action plan implemented to prevent recurrence including process changes, equipment upgrades, and training initiatives.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this operational incident record was first created in the data platform.',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code for the estimated financial impact amount.',
    `downtime_hours` DECIMAL(10,2) COMMENT 'Total number of hours that operations were halted or significantly impaired due to the incident.',
    `environmental_impact_description` STRING COMMENT 'Description of the environmental impacts resulting from the incident including affected ecosystems, contamination extent, and species or habitat damage.',
    `environmental_impact_flag` BOOLEAN COMMENT 'Indicates whether the incident resulted in environmental damage, contamination, or ecological harm requiring assessment and remediation.',
    `esg_impact_category` STRING COMMENT 'Classification of the incidents primary impact area within the ESG framework for responsible investment reporting and stewardship.. Valid values are `environmental|social|governance|health_safety`',
    `estimated_financial_impact` DECIMAL(18,2) COMMENT 'Estimated total financial impact of the incident including lost revenue, remediation costs, penalties, and asset damage in base currency.',
    `fatality_count` BIGINT COMMENT 'Number of fatalities resulting from the operational incident.',
    `force_majeure_flag` BOOLEAN COMMENT 'Indicates whether the incident qualifies as a force majeure event under applicable contracts and legal agreements.',
    `ghg_emissions_impact` DECIMAL(18,4) COMMENT 'Estimated greenhouse gas emissions resulting from the incident measured in tonnes of carbon dioxide equivalent for climate impact assessment.',
    `incident_description` STRING COMMENT 'Comprehensive narrative description of the operational incident including circumstances, contributing factors, immediate impacts, and initial response actions taken.',
    `incident_end_timestamp` TIMESTAMP COMMENT 'Date and time when the operational incident was resolved or contained, allowing resumption of normal operations.',
    `incident_location_description` STRING COMMENT 'Detailed description of the specific location within the natural resource asset where the incident occurred including parcel, facility, or operational area.',
    `incident_notes` STRING COMMENT 'Additional notes, observations, or supplementary information related to the incident not captured in other structured fields.',
    `incident_number` STRING COMMENT 'Externally-known unique reference number assigned to this operational incident for tracking and reporting purposes.',
    `incident_start_timestamp` TIMESTAMP COMMENT 'Date and time when the operational incident began or was first detected at the natural resource asset location.',
    `incident_status` STRING COMMENT 'Current state of the incident in its lifecycle from initial reporting through investigation, containment, resolution, and closure.. Valid values are `reported|under_investigation|active|contained|resolved|closed`',
    `incident_type` STRING COMMENT 'Classification of the operational incident affecting natural resource operations including weather events, equipment failures, regulatory actions, labor disputes, environmental incidents, and natural disasters.',
    `injury_count` BIGINT COMMENT 'Number of personnel injuries resulting from the operational incident.',
    `insurance_claim_flag` BOOLEAN COMMENT 'Indicates whether an insurance claim has been filed for losses or damages resulting from this operational incident.',
    `insurance_claim_number` STRING COMMENT 'Reference number assigned by the insurance carrier for the claim filed in relation to this incident.',
    `insurance_recovery_amount` DECIMAL(18,2) COMMENT 'Amount recovered or expected to be recovered from insurance coverage for losses incurred from the incident.',
    `investigation_completion_date` DATE COMMENT 'Date when the formal investigation into the incident was completed and final report issued.',
    `investigation_status` STRING COMMENT 'Current status of the formal investigation into the incident causes, impacts, and corrective actions.. Valid values are `not_started|in_progress|completed|report_issued`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'System timestamp when this operational incident record was most recently modified or updated.',
    `latitude` DECIMAL(10,7) COMMENT 'Geographic latitude coordinate of the incident location in decimal degrees for spatial analysis and emergency response.',
    `lessons_learned` STRING COMMENT 'Documentation of key lessons learned from the incident for knowledge sharing and continuous improvement of operational risk management practices.',
    `longitude` DECIMAL(10,7) COMMENT 'Geographic longitude coordinate of the incident location in decimal degrees for spatial analysis and emergency response.',
    `production_impact_flag` BOOLEAN COMMENT 'Indicates whether the incident resulted in disruption or reduction of production output from the natural resource asset.',
    `production_loss_unit` STRING COMMENT 'Unit of measure for the production loss volume such as cubic meters, barrels, tonnes, board feet, or megawatt hours depending on resource type.',
    `production_loss_volume` DECIMAL(18,4) COMMENT 'Quantified volume of production lost due to the operational incident measured in the assets standard unit of production.',
    `regulatory_authority_name` STRING COMMENT 'Name of the regulatory authority or government agency notified of the incident.',
    `regulatory_notification_date` DATE COMMENT 'Date when regulatory authorities were formally notified of the operational incident as required by applicable regulations.',
    `regulatory_notification_required_flag` BOOLEAN COMMENT 'Indicates whether the incident requires mandatory notification to regulatory authorities or government agencies.',
    `remediation_cost` DECIMAL(18,2) COMMENT 'Actual or estimated cost of remediation activities including cleanup, repair, restoration, and corrective actions required to address the incident.',
    `reported_by_name` STRING COMMENT 'Name of the individual or entity who first reported the operational incident.',
    `reported_timestamp` TIMESTAMP COMMENT 'Date and time when the incident was formally reported to management or regulatory authorities.',
    `response_team_assigned` STRING COMMENT 'Name or identifier of the incident response team or emergency response unit assigned to manage and resolve the incident.',
    `root_cause_analysis` STRING COMMENT 'Summary of the root cause analysis findings identifying underlying factors that led to the incident and systemic issues requiring remediation.',
    `safety_incident_flag` BOOLEAN COMMENT 'Indicates whether the operational incident involved worker safety issues, injuries, or occupational health hazards.',
    `severity_level` STRING COMMENT 'Assessment of the incidents severity based on operational impact, financial exposure, safety risk, and environmental consequences.. Valid values are `critical|high|medium|low|minimal`',
    `third_party_involvement_flag` BOOLEAN COMMENT 'Indicates whether third-party contractors, vendors, or external parties were involved in or contributed to the incident.',
    `third_party_name` STRING COMMENT 'Name of the third-party entity involved in the incident if applicable.',
    CONSTRAINT pk_operational_incident PRIMARY KEY(`operational_incident_id`)
) COMMENT 'Records operational incidents, disruptions, and force majeure events affecting natural resource asset operations. Captures incident type (weather event, equipment failure, regulatory shutdown, labor dispute, environmental spill, wildfire, flood), incident';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`harvest_plan` (
    `harvest_plan_id` BIGINT COMMENT 'Unique identifier for the harvest plan record.',
    `asset_manager_employee_id` BIGINT COMMENT 'Reference to the internal asset manager or portfolio manager responsible for overseeing this harvest plan.',
    `legal_entity_id` BIGINT COMMENT 'Reference to the third-party contractor or service provider engaged to execute harvest operations.',
    `depletion_schedule_id` BIGINT COMMENT 'Reference to the depletion schedule used for accounting and valuation of the harvested resource.',
    `employee_id` BIGINT COMMENT 'Reference to the internal user or investment committee member who approved the harvest plan.',
    `environmental_permit_id` BIGINT COMMENT 'Reference to the environmental permit authorizing harvest activities under applicable regulatory frameworks.',
    `investment_portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio to which this natural resource asset and harvest plan are allocated.',
    `land_parcel_id` BIGINT COMMENT 'Reference to the specific land parcel where harvest activities will occur.',
    `natural_resource_asset_id` BIGINT COMMENT 'Reference to the timberland or farmland asset subject to this harvest plan.',
    `offtake_agreement_id` BIGINT COMMENT 'Foreign key linking to naturalresource.offtake_agreement. Business justification: Harvest plans for timberland/farmland may be tied to specific offtake agreements that govern the sale of harvested production.',
    `actual_harvest_end_date` DATE COMMENT 'Actual date when harvest operations concluded, used for performance tracking and variance analysis.',
    `actual_harvest_start_date` DATE COMMENT 'Actual date when harvest operations commenced, used for performance tracking and variance analysis.',
    `actual_harvest_volume` DECIMAL(15,2) COMMENT 'Actual total volume or quantity of resource harvested, used for reconciliation against planned volume.',
    `approval_date` DATE COMMENT 'Date on which the harvest plan received formal approval from internal governance and external regulatory bodies.',
    `biodiversity_impact_assessment` STRING COMMENT 'Qualitative assessment of the harvest plans impact on local biodiversity and ecosystem services.. Valid values are `low|moderate|high|critical`',
    `carbon_sequestration_impact` DECIMAL(12,2) COMMENT 'Estimated net change in carbon sequestration resulting from the harvest, expressed in tonnes of CO2 equivalent.',
    `commodity_price_assumption` DECIMAL(12,2) COMMENT 'Assumed market price per unit of harvested commodity used for revenue estimation and valuation purposes.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this harvest plan record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this harvest plan.. Valid values are `^[A-Z]{3}$`',
    `estimated_cost` DECIMAL(18,2) COMMENT 'Projected total cost of harvest operations including labor, equipment, transportation, and regulatory compliance.',
    `estimated_revenue` DECIMAL(18,2) COMMENT 'Projected gross revenue from the planned harvest based on current commodity prices and volume assumptions.',
    `estimated_yield_per_hectare` DECIMAL(10,2) COMMENT 'Projected average yield per hectare based on site productivity, stand age, and historical performance.',
    `harvest_area_hectares` DECIMAL(12,2) COMMENT 'Total land area in hectares designated for harvest activities under this plan.',
    `harvest_method` STRING COMMENT 'Silvicultural or agricultural harvest technique to be employed, reflecting sustainability and regeneration strategy.. Valid values are `clear_cut|selective|shelterwood|seed_tree|sustainable_yield|rotation`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this harvest plan record was last updated, used for audit trail and change tracking.',
    `plan_end_date` DATE COMMENT 'Planned date when harvest activities are scheduled to conclude under this plan.',
    `plan_name` STRING COMMENT 'Descriptive name for the harvest plan identifying the location, resource type, and planning period.',
    `plan_notes` STRING COMMENT 'Free-text field for additional operational notes, special conditions, or contextual information relevant to the harvest plan.',
    `plan_reference_number` STRING COMMENT 'Externally-known business identifier for the harvest plan used in operational communications and regulatory filings.. Valid values are `^HP-[0-9]{4}-[0-9]{6}$`',
    `plan_start_date` DATE COMMENT 'Planned date when harvest activities are scheduled to commence under this plan.',
    `plan_status` STRING COMMENT 'Current lifecycle status of the harvest plan indicating its operational state and approval stage.. Valid values are `draft|approved|active|suspended|completed|cancelled`',
    `plan_type` STRING COMMENT 'Classification of the harvest plan by primary resource type being harvested.. Valid values are `timber|agricultural|mixed`',
    `plan_year` BIGINT COMMENT 'Calendar year for which this harvest plan is scheduled and budgeted.',
    `planned_harvest_volume` DECIMAL(15,2) COMMENT 'Estimated total volume or quantity of resource planned for harvest expressed in the unit of measure specified.',
    `price_deck_scenario` STRING COMMENT 'Commodity price scenario applied in the harvest plan reflecting macroeconomic assumptions and risk sensitivity.. Valid values are `base|conservative|optimistic|stress`',
    `reforestation_deadline_date` DATE COMMENT 'Regulatory or contractual deadline by which reforestation or regeneration activities must be completed.',
    `reforestation_plan_flag` BOOLEAN COMMENT 'Indicates whether a formal reforestation or regeneration plan is required and documented for this harvest area.',
    `regulatory_approval_status` STRING COMMENT 'Status of regulatory approval from relevant environmental and forestry authorities for this harvest plan.. Valid values are `pending|approved|conditional|denied`',
    `risk_rating` STRING COMMENT 'Overall risk rating assigned to the harvest plan considering operational, environmental, regulatory, and market risks.. Valid values are `low|medium|high|critical`',
    `rotation_age_years` BIGINT COMMENT 'Age of the timber stand or crop rotation cycle at the time of planned harvest, relevant for sustainable yield calculations.',
    `species_type` STRING COMMENT 'Primary timber species or agricultural crop type targeted for harvest under this plan.',
    `sustainability_certification` STRING COMMENT 'Third-party sustainability certification standard under which the harvest plan is designed and will be audited.. Valid values are `FSC|SFI|PEFC|RSPO|none`',
    `variance_explanation` STRING COMMENT 'Explanation of significant variances between planned and actual harvest metrics including volume, timing, and cost.',
    `volume_unit_of_measure` STRING COMMENT 'Unit of measure for the planned harvest volume, aligned with industry standards for the resource type.. Valid values are `cubic_meters|board_feet|tonnes|bushels|bales`',
    `weather_dependency_flag` BOOLEAN COMMENT 'Indicates whether harvest timing and execution are significantly dependent on favorable weather conditions.',
    CONSTRAINT pk_harvest_plan PRIMARY KEY(`harvest_plan_id`)
) COMMENT 'Timber and agricultural harvest planning records for timberland and farmland assets. Captures plan year, harvest area (hectares), planned harvest volume by species/crop type, harvest method (clear-cut, selective, sustainable yield), planned harvest dates';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`carbon_project` (
    `carbon_project_id` BIGINT COMMENT 'Primary key for carbon_project',
    `resource_asset_id` BIGINT COMMENT 'Foreign key linking to naturalresource.resource_asset. Business justification: Carbon projects (REDD+, reforestation, etc.) are typically associated with underlying natural resource assets like timberland or farmland.',
    `acquisition_date` DATE COMMENT 'Date when the pension fund acquired its ownership stake in the carbon project.',
    `additionality_type` STRING COMMENT 'Method used to demonstrate that carbon reductions would not occur without project intervention.',
    `article_6_eligible_flag` BOOLEAN COMMENT 'Indicates whether credits qualify for Paris Agreement Article 6 international transfers.',
    `buffer_pool_contribution_percent` DECIMAL(5,2) COMMENT 'Percentage of issued credits contributed to the registry buffer pool for permanence risk.',
    `ccb_certification_flag` BOOLEAN COMMENT 'Indicates whether the project holds Climate Community and Biodiversity Standards certification.',
    `co_benefits_flag` BOOLEAN COMMENT 'Indicates whether the project delivers verified co-benefits beyond carbon reduction.',
    `corsia_eligible_flag` BOOLEAN COMMENT 'Indicates whether credits are eligible for ICAO CORSIA aviation offsetting compliance.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code where the carbon project is physically located.',
    `crediting_period_end_date` DATE COMMENT 'Date when the carbon credit generation crediting period is scheduled to end.',
    `crediting_period_start_date` DATE COMMENT 'Date when the carbon credit generation crediting period officially begins.',
    `crediting_period_years` BIGINT COMMENT 'Total duration of the crediting period measured in years as defined in project documentation.',
    `credits_issued_to_date_tonnes` DECIMAL(18,4) COMMENT 'Cumulative carbon credits issued by the registry to date in tonnes of CO2 equivalent.',
    `credits_retired_to_date_tonnes` DECIMAL(18,4) COMMENT 'Cumulative carbon credits permanently retired from circulation in tonnes of CO2 equivalent.',
    `current_valuation_usd` DECIMAL(18,2) COMMENT 'Current fair market valuation of the pension funds stake in US dollars.',
    `carbon_project_description` STRING COMMENT 'Detailed narrative description of the carbon project activities and objectives.',
    `esg_score` DECIMAL(5,2) COMMENT 'Composite ESG rating score assigned to the carbon project based on internal assessment.',
    `estimated_annual_credits_tonnes` DECIMAL(18,4) COMMENT 'Projected annual carbon credit generation capacity measured in tonnes of CO2 equivalent.',
    `internal_risk_rating` STRING COMMENT 'Internal investment risk classification assigned by the pension fund risk team.',
    `investment_amount_usd` DECIMAL(18,2) COMMENT 'Total capital invested by the pension fund in this carbon project in US dollars.',
    `last_verification_date` DATE COMMENT 'Date of the most recent third-party verification of carbon credit issuance claims.',
    `latitude` DECIMAL(10,7) COMMENT 'Geographic latitude coordinate of the carbon project centroid location.',
    `longitude` DECIMAL(10,7) COMMENT 'Geographic longitude coordinate of the carbon project centroid location.',
    `methodology_code` STRING COMMENT 'Standardized methodology code defining the carbon accounting and quantification approach used.',
    `carbon_project_name` STRING COMMENT 'Official registered name of the carbon project as filed with the carbon registry.',
    `next_verification_date` DATE COMMENT 'Scheduled date for the next third-party verification of carbon credit claims.',
    `notes` STRING COMMENT 'Internal notes and commentary from investment analysts regarding the carbon project.',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage ownership stake held by the pension fund in the carbon project.',
    `permanence_risk_rating` STRING COMMENT 'Assessment of the risk that sequestered carbon may be released back to the atmosphere.',
    `project_area_hectares` DECIMAL(18,4) COMMENT 'Total land area covered by the carbon project measured in hectares.',
    `project_code` STRING COMMENT 'External business identifier code for the carbon project used in registry systems and reporting.',
    `project_developer_name` STRING COMMENT 'Name of the organization responsible for developing and implementing the carbon project.',
    `project_type` STRING COMMENT 'Classification of the carbon project methodology type determining credit generation approach.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this carbon project record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this carbon project record was last modified.',
    `region` STRING COMMENT 'Geographic region or state/province within the country where the project is situated.',
    `registration_date` DATE COMMENT 'Date when the carbon project was officially registered with the carbon credit registry.',
    `registry_name` STRING COMMENT 'Name of the carbon credit registry where the project is registered and credits are issued.',
    `registry_project_code` STRING COMMENT 'Unique project identifier assigned by the carbon registry for tracking and verification purposes.',
    `sdg_alignment_codes` STRING COMMENT 'Comma-separated UN Sustainable Development Goal numbers the project contributes to.',
    `carbon_project_status` STRING COMMENT 'Current lifecycle status of the carbon project from development through active credit generation.',
    `total_estimated_credits_tonnes` DECIMAL(18,4) COMMENT 'Total projected carbon credits over the full crediting period in tonnes of CO2 equivalent.',
    `validation_body_name` STRING COMMENT 'Name of the accredited third-party organization that validated the project design.',
    `validation_date` DATE COMMENT 'Date when the carbon project was validated by an accredited third-party validation body.',
    `valuation_date` DATE COMMENT 'Date of the most recent fair market valuation assessment.',
    `verification_body_name` STRING COMMENT 'Name of the accredited third-party organization that verifies credit issuance claims.',
    CONSTRAINT pk_carbon_project PRIMARY KEY(`carbon_project_id`)
) COMMENT 'Master reference table for carbon_project. Referenced by project_id.';

CREATE OR REPLACE TABLE `asset_management`.`naturalresource`.`resource_vehicle` (
    `resource_vehicle_id` BIGINT COMMENT 'Primary key for resource_vehicle',
    `administrator_name` STRING COMMENT 'Name of the third-party fund administrator responsible for accounting and investor services.',
    `auditor_name` STRING COMMENT 'Name of the external audit firm responsible for auditing the vehicles financial statements.',
    `base_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code representing the functional currency of the resource investment vehicle.',
    `called_capital` DECIMAL(18,2) COMMENT 'Cumulative capital called from investors to date for investments and expenses in base currency.',
    `carbon_intensity_score` DECIMAL(10,4) COMMENT 'Measure of carbon emissions intensity per unit of revenue or production for climate risk assessment.',
    `carried_interest_rate` DECIMAL(5,4) COMMENT 'Performance fee rate payable to the general partner on profits above the hurdle rate expressed as a decimal percentage.',
    `commodity_exposure_type` STRING COMMENT 'Primary commodity types the vehicle has exposure to such as oil, gas, timber, agricultural products, or metals.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the resource vehicle record was first created in the system.',
    `custodian_name` STRING COMMENT 'Name of the custodian bank or institution holding the vehicles assets for safekeeping.',
    `resource_vehicle_description` STRING COMMENT 'Detailed narrative description of the resource vehicles investment mandate, strategy, and objectives.',
    `distributed_capital` DECIMAL(18,2) COMMENT 'Cumulative distributions returned to investors from the resource vehicle in base currency.',
    `domicile_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code where the resource investment vehicle is legally domiciled for tax and regulatory purposes.',
    `esg_rating` STRING COMMENT 'Environmental, Social, and Governance rating assigned by recognized rating agencies or internal assessment.',
    `extension_years_available` BIGINT COMMENT 'Number of additional years the fund term may be extended beyond the original termination date per partnership agreement.',
    `fund_term_years` BIGINT COMMENT 'Contractual duration of the fund in years from inception to scheduled termination excluding extensions.',
    `geographic_focus` STRING COMMENT 'Primary geographic regions or countries where the resource vehicle targets investments for portfolio construction.',
    `gp_commitment_percentage` DECIMAL(5,4) COMMENT 'Percentage of total fund commitments contributed by the general partner demonstrating alignment of interests.',
    `hard_cap_amount` DECIMAL(18,2) COMMENT 'Maximum capital commitment amount the fund will accept as defined in partnership documents in base currency.',
    `hurdle_rate` DECIMAL(5,4) COMMENT 'Minimum preferred return rate that must be achieved before carried interest is payable expressed as a decimal percentage.',
    `inception_date` DATE COMMENT 'Date when the resource investment vehicle was established or first capital was deployed.',
    `investment_period_end_date` DATE COMMENT 'Date when the active investment period ends after which no new investments can be made from uncalled capital.',
    `investment_strategy` STRING COMMENT 'Risk-return strategy classification of the resource vehicle determining expected return profile and risk tolerance.',
    `is_esg_compliant` BOOLEAN COMMENT 'Indicates whether the resource vehicle meets Environmental, Social, and Governance compliance standards.',
    `is_evergreen` BOOLEAN COMMENT 'Indicates whether the vehicle has an evergreen structure with no fixed termination date and continuous reinvestment.',
    `is_open_ended` BOOLEAN COMMENT 'Indicates whether the vehicle is open-ended with ongoing subscriptions and redemptions versus closed-end structure.',
    `legal_name` STRING COMMENT 'Full legal registered name of the resource investment vehicle as per incorporation or registration documents.',
    `legal_structure` STRING COMMENT 'Legal entity structure of the vehicle such as limited partnership, LLC, trust, or corporation for tax and liability purposes.',
    `management_fee_rate` DECIMAL(5,4) COMMENT 'Annual management fee rate charged by the general partner expressed as a decimal percentage of committed or invested capital.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the resource vehicle record was last modified in the system.',
    `resource_vehicle_name` STRING COMMENT 'Human-readable name of the resource investment vehicle as registered or commonly known in the market.',
    `nav_date` DATE COMMENT 'As-of date for the most recent net asset value calculation of the resource vehicle.',
    `net_asset_value` DECIMAL(18,2) COMMENT 'Current net asset value of the resource investment vehicle representing fair value of assets less liabilities.',
    `regulatory_classification` STRING COMMENT 'Regulatory classification of the vehicle under applicable securities laws such as 3(c)(7), AIFMD, or UCITS.',
    `reporting_frequency` STRING COMMENT 'Frequency at which the vehicle provides performance and financial reports to investors.',
    `resource_category` STRING COMMENT 'Primary natural resource category that the investment vehicle focuses on for asset allocation classification.',
    `resource_vehicle_status` STRING COMMENT 'Current lifecycle status of the resource investment vehicle indicating operational state.',
    `sub_category` STRING COMMENT 'Secondary classification within the primary resource category for granular portfolio segmentation and analysis.',
    `target_fund_size` DECIMAL(18,2) COMMENT 'Target total capital commitments the resource vehicle aims to raise during fundraising in base currency.',
    `tax_status` STRING COMMENT 'Tax treatment classification of the vehicle such as pass-through, blocker, or tax-exempt for investor reporting.',
    `termination_date` DATE COMMENT 'Scheduled or actual date when the resource investment vehicle is expected to or did terminate operations.',
    `total_committed_capital` DECIMAL(18,2) COMMENT 'Aggregate capital commitments from all limited partners and general partner to the resource vehicle in base currency.',
    `valuation_frequency` STRING COMMENT 'Frequency at which the underlying assets of the vehicle are formally valued for NAV calculation.',
    `vehicle_code` STRING COMMENT 'Externally-known unique business identifier code for the resource investment vehicle used in reporting and communications.',
    `vehicle_type` STRING COMMENT 'Classification of the resource investment vehicle structure determining legal and operational characteristics.',
    `vintage_year` BIGINT COMMENT 'Year of first capital call or investment deployment used for performance benchmarking and peer comparison.',
    CONSTRAINT pk_resource_vehicle PRIMARY KEY(`resource_vehicle_id`)
) COMMENT 'Master reference table for resource_vehicle. Referenced by resource_vehicle_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ADD CONSTRAINT `fk_naturalresource_resource_holding_resource_vehicle_id` FOREIGN KEY (`resource_vehicle_id`) REFERENCES `asset_management`.`naturalresource`.`resource_vehicle`(`resource_vehicle_id`);
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ADD CONSTRAINT `fk_naturalresource_production_record_resource_asset_id` FOREIGN KEY (`resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ADD CONSTRAINT `fk_naturalresource_commodity_exposure_natural_resource_asset_id` FOREIGN KEY (`natural_resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ADD CONSTRAINT `fk_naturalresource_depletion_schedule_natural_resource_asset_id` FOREIGN KEY (`natural_resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ADD CONSTRAINT `fk_naturalresource_depletion_schedule_reserve_estimate_id` FOREIGN KEY (`reserve_estimate_id`) REFERENCES `asset_management`.`naturalresource`.`reserve_estimate`(`reserve_estimate_id`);
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ADD CONSTRAINT `fk_naturalresource_reserve_estimate_previous_estimate_reserve_estimate_id` FOREIGN KEY (`previous_estimate_reserve_estimate_id`) REFERENCES `asset_management`.`naturalresource`.`reserve_estimate`(`reserve_estimate_id`);
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ADD CONSTRAINT `fk_naturalresource_reserve_estimate_resource_asset_id` FOREIGN KEY (`resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ADD CONSTRAINT `fk_naturalresource_resource_valuation_commodity_price_deck_id` FOREIGN KEY (`commodity_price_deck_id`) REFERENCES `asset_management`.`naturalresource`.`commodity_price_deck`(`commodity_price_deck_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ADD CONSTRAINT `fk_naturalresource_resource_valuation_depletion_schedule_id` FOREIGN KEY (`depletion_schedule_id`) REFERENCES `asset_management`.`naturalresource`.`depletion_schedule`(`depletion_schedule_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ADD CONSTRAINT `fk_naturalresource_resource_valuation_reserve_estimate_id` FOREIGN KEY (`reserve_estimate_id`) REFERENCES `asset_management`.`naturalresource`.`reserve_estimate`(`reserve_estimate_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ADD CONSTRAINT `fk_naturalresource_resource_valuation_resource_asset_id` FOREIGN KEY (`resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ADD CONSTRAINT `fk_naturalresource_capital_event_resource_asset_id` FOREIGN KEY (`resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ADD CONSTRAINT `fk_naturalresource_capital_event_resource_fund_commitment_id` FOREIGN KEY (`resource_fund_commitment_id`) REFERENCES `asset_management`.`naturalresource`.`resource_fund_commitment`(`resource_fund_commitment_id`);
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ADD CONSTRAINT `fk_naturalresource_capital_event_resource_holding_id` FOREIGN KEY (`resource_holding_id`) REFERENCES `asset_management`.`naturalresource`.`resource_holding`(`resource_holding_id`);
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ADD CONSTRAINT `fk_naturalresource_operator_agreement_natural_resource_asset_id` FOREIGN KEY (`natural_resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ADD CONSTRAINT `fk_naturalresource_royalty_obligation_natural_resource_asset_id` FOREIGN KEY (`natural_resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ADD CONSTRAINT `fk_naturalresource_royalty_payment_natural_resource_asset_id` FOREIGN KEY (`natural_resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ADD CONSTRAINT `fk_naturalresource_royalty_payment_royalty_obligation_id` FOREIGN KEY (`royalty_obligation_id`) REFERENCES `asset_management`.`naturalresource`.`royalty_obligation`(`royalty_obligation_id`);
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ADD CONSTRAINT `fk_naturalresource_environmental_permit_natural_resource_asset_id` FOREIGN KEY (`natural_resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ADD CONSTRAINT `fk_naturalresource_carbon_credit_natural_resource_asset_id` FOREIGN KEY (`natural_resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ADD CONSTRAINT `fk_naturalresource_carbon_credit_carbon_project_id` FOREIGN KEY (`carbon_project_id`) REFERENCES `asset_management`.`naturalresource`.`carbon_project`(`carbon_project_id`);
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ADD CONSTRAINT `fk_naturalresource_offtake_agreement_natural_resource_asset_id` FOREIGN KEY (`natural_resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ADD CONSTRAINT `fk_naturalresource_commodity_price_deck_natural_resource_asset_id` FOREIGN KEY (`natural_resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ADD CONSTRAINT `fk_naturalresource_resource_budget_natural_resource_asset_id` FOREIGN KEY (`natural_resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ADD CONSTRAINT `fk_naturalresource_resource_budget_reserve_estimate_id` FOREIGN KEY (`reserve_estimate_id`) REFERENCES `asset_management`.`naturalresource`.`reserve_estimate`(`reserve_estimate_id`);
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ADD CONSTRAINT `fk_naturalresource_reclamation_liability_environmental_permit_id` FOREIGN KEY (`environmental_permit_id`) REFERENCES `asset_management`.`naturalresource`.`environmental_permit`(`environmental_permit_id`);
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ADD CONSTRAINT `fk_naturalresource_reclamation_liability_natural_resource_asset_id` FOREIGN KEY (`natural_resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ADD CONSTRAINT `fk_naturalresource_resource_fund_commitment_resource_vehicle_id` FOREIGN KEY (`resource_vehicle_id`) REFERENCES `asset_management`.`naturalresource`.`resource_vehicle`(`resource_vehicle_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ADD CONSTRAINT `fk_naturalresource_resource_cashflow_natural_resource_asset_id` FOREIGN KEY (`natural_resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ADD CONSTRAINT `fk_naturalresource_resource_cashflow_offtake_agreement_id` FOREIGN KEY (`offtake_agreement_id`) REFERENCES `asset_management`.`naturalresource`.`offtake_agreement`(`offtake_agreement_id`);
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ADD CONSTRAINT `fk_naturalresource_operational_incident_natural_resource_asset_id` FOREIGN KEY (`natural_resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ADD CONSTRAINT `fk_naturalresource_harvest_plan_depletion_schedule_id` FOREIGN KEY (`depletion_schedule_id`) REFERENCES `asset_management`.`naturalresource`.`depletion_schedule`(`depletion_schedule_id`);
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ADD CONSTRAINT `fk_naturalresource_harvest_plan_environmental_permit_id` FOREIGN KEY (`environmental_permit_id`) REFERENCES `asset_management`.`naturalresource`.`environmental_permit`(`environmental_permit_id`);
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ADD CONSTRAINT `fk_naturalresource_harvest_plan_land_parcel_id` FOREIGN KEY (`land_parcel_id`) REFERENCES `asset_management`.`naturalresource`.`land_parcel`(`land_parcel_id`);
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ADD CONSTRAINT `fk_naturalresource_harvest_plan_natural_resource_asset_id` FOREIGN KEY (`natural_resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ADD CONSTRAINT `fk_naturalresource_harvest_plan_offtake_agreement_id` FOREIGN KEY (`offtake_agreement_id`) REFERENCES `asset_management`.`naturalresource`.`offtake_agreement`(`offtake_agreement_id`);
ALTER TABLE `asset_management`.`naturalresource`.`carbon_project` ADD CONSTRAINT `fk_naturalresource_carbon_project_resource_asset_id` FOREIGN KEY (`resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` SET TAGS ('dbx_subdomain' = 'asset_ownership');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Asset Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `asset_manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Manager Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `audit_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `certification_id` SET TAGS ('dbx_business_glossary_term' = 'Certification Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `country_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Country Outlook Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `gips_compliance_record_id` SET TAGS ('dbx_business_glossary_term' = 'Gips Compliance Record Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `operator_actor_id` SET TAGS ('dbx_business_glossary_term' = 'Operator Actor Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `policy_document_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Document Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `project_investment_id` SET TAGS ('dbx_business_glossary_term' = 'Project Investment Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `sfdr_disclosure_id` SET TAGS ('dbx_business_glossary_term' = 'Sfdr Disclosure Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `acquisition_cost` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Cost');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `acquisition_cost` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `acquisition_date` SET TAGS ('dbx_business_glossary_term' = 'Asset Acquisition Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `annual_production_capacity` SET TAGS ('dbx_business_glossary_term' = 'Annual Production Capacity');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `area_unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Area Unit of Measure');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `area_unit_of_measure` SET TAGS ('dbx_value_regex' = 'acres|hectares|square_kilometers|square_miles');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `asset_identifier` SET TAGS ('dbx_business_glossary_term' = 'External Asset Identifier');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `asset_name` SET TAGS ('dbx_business_glossary_term' = 'Resource Asset Name');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `asset_status` SET TAGS ('dbx_business_glossary_term' = 'Asset Lifecycle Status');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `asset_status` SET TAGS ('dbx_value_regex' = 'active|under_development|dormant|divested|held_for_sale|retired');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `carbon_footprint` SET TAGS ('dbx_business_glossary_term' = 'Carbon Footprint');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `current_valuation` SET TAGS ('dbx_business_glossary_term' = 'Current Valuation');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `current_valuation` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `depletion_method` SET TAGS ('dbx_business_glossary_term' = 'Depletion Method');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `depletion_method` SET TAGS ('dbx_value_regex' = 'units_of_production|straight_line|declining_balance|not_applicable');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `discount_rate` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `discount_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `environmental_certification` SET TAGS ('dbx_business_glossary_term' = 'Environmental Certification');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `estimated_useful_life_years` SET TAGS ('dbx_business_glossary_term' = 'Estimated Useful Life (Years)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `insurance_coverage` SET TAGS ('dbx_business_glossary_term' = 'Insurance Coverage');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `insurance_coverage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `last_inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Last Inspection Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'Latitude Coordinate');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'Longitude Coordinate');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `next_inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Next Inspection Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `operator_lei` SET TAGS ('dbx_business_glossary_term' = 'Operator Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `operator_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `operator_name` SET TAGS ('dbx_business_glossary_term' = 'Operator Name');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `operator_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `operator_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `ownership_structure` SET TAGS ('dbx_business_glossary_term' = 'Ownership Structure');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `ownership_structure` SET TAGS ('dbx_value_regex' = 'direct|joint_venture|partnership|leasehold|royalty_interest');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `permit_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Permit Expiry Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `production_unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Production Unit of Measure');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `productive_area` SET TAGS ('dbx_business_glossary_term' = 'Productive Area');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `regulatory_permits` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Permits');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `reserve_classification` SET TAGS ('dbx_business_glossary_term' = 'Reserve Classification');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `reserve_classification` SET TAGS ('dbx_value_regex' = 'proven|probable|possible|inferred|measured|indicated');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `reserve_quantity` SET TAGS ('dbx_business_glossary_term' = 'Reserve Quantity');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `reserve_quantity` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `reserve_unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Reserve Unit of Measure');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `resource_subtype` SET TAGS ('dbx_business_glossary_term' = 'Resource Asset Subtype');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `resource_type` SET TAGS ('dbx_business_glossary_term' = 'Resource Asset Type');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `resource_type` SET TAGS ('dbx_value_regex' = 'timberland|farmland|mining|upstream_oil_gas|renewable_energy|water_rights');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `state_province` SET TAGS ('dbx_business_glossary_term' = 'State or Province');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `total_area` SET TAGS ('dbx_business_glossary_term' = 'Total Area');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'dcf|comparable_sales|income_approach|cost_approach|market_approach');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` SET TAGS ('dbx_subdomain' = 'asset_ownership');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `resource_holding_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Holding Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `general_partner_actor_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner Actor Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `resource_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Vehicle Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `carbon_footprint_tonnes` SET TAGS ('dbx_business_glossary_term' = 'Carbon Footprint (Tonnes CO2 Equivalent)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `commitment_date` SET TAGS ('dbx_business_glossary_term' = 'Commitment Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `committed_capital_amount` SET TAGS ('dbx_business_glossary_term' = 'Committed Capital Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `committed_capital_currency` SET TAGS ('dbx_business_glossary_term' = 'Committed Capital Currency');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `committed_capital_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `commodity_price_exposure` SET TAGS ('dbx_business_glossary_term' = 'Commodity Price Exposure');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `cost_basis_amount` SET TAGS ('dbx_business_glossary_term' = 'Cost Basis Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `cumulative_distributions_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Distributions Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `custodian_code` SET TAGS ('dbx_business_glossary_term' = 'Custodian Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `depletion_method` SET TAGS ('dbx_business_glossary_term' = 'Depletion Method');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `depletion_method` SET TAGS ('dbx_value_regex' = 'units_of_production|straight_line|declining_balance|not_applicable');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `depletion_rate_percentage` SET TAGS ('dbx_business_glossary_term' = 'Depletion Rate Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `dpi_multiple` SET TAGS ('dbx_business_glossary_term' = 'Distributions to Paid-In (DPI) Multiple');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `economic_interest_percentage` SET TAGS ('dbx_business_glossary_term' = 'Economic Interest Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `expected_harvest_date` SET TAGS ('dbx_business_glossary_term' = 'Expected Harvest Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `fund_term_years` SET TAGS ('dbx_business_glossary_term' = 'Fund Term (Years)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Focus');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `holding_status` SET TAGS ('dbx_business_glossary_term' = 'Holding Status');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `holding_type` SET TAGS ('dbx_business_glossary_term' = 'Holding Type');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `holding_type` SET TAGS ('dbx_value_regex' = 'direct_asset|lp_commitment|co_investment|fund_of_funds|secondary|joint_venture');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `irr_percentage` SET TAGS ('dbx_business_glossary_term' = 'Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `is_co_investment` SET TAGS ('dbx_business_glossary_term' = 'Is Co-Investment Flag');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `last_capital_call_date` SET TAGS ('dbx_business_glossary_term' = 'Last Capital Call Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `legal_entity_identifier` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `legal_entity_identifier` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `moic_multiple` SET TAGS ('dbx_business_glossary_term' = 'Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `nav_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `nav_as_of_date` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) As-Of Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `next_valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Next Valuation Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `paid_in_capital_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid-In Capital (PIC) Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `production_unit` SET TAGS ('dbx_business_glossary_term' = 'Production Unit of Measure');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `production_volume` SET TAGS ('dbx_business_glossary_term' = 'Production Volume');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `resource_asset_class` SET TAGS ('dbx_business_glossary_term' = 'Resource Asset Class');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `resource_asset_class` SET TAGS ('dbx_value_regex' = 'timberland|farmland|mining|energy|commodity_linked');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `resource_sub_class` SET TAGS ('dbx_business_glossary_term' = 'Resource Sub-Class');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `rvpi_multiple` SET TAGS ('dbx_business_glossary_term' = 'Residual Value to Paid-In (RVPI) Multiple');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `sustainability_certification` SET TAGS ('dbx_business_glossary_term' = 'Sustainability Certification');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `total_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Value Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `tvpi_multiple` SET TAGS ('dbx_business_glossary_term' = 'Total Value to Paid-In (TVPI) Multiple');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `unfunded_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Unfunded Commitment Amount (Dry Powder)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Valuation Methodology');
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` SET TAGS ('dbx_subdomain' = 'operations_production');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `production_record_id` SET TAGS ('dbx_business_glossary_term' = 'Production Record Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Asset Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `audit_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Audit Completion Date');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `auditor_name` SET TAGS ('dbx_business_glossary_term' = 'Auditor Name');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `auditor_verification_flag` SET TAGS ('dbx_business_glossary_term' = 'Auditor Verification Flag');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `benchmark_commodity_price` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Commodity Price');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `certification_type` SET TAGS ('dbx_business_glossary_term' = 'Sustainability Certification Type');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `commodity_grade` SET TAGS ('dbx_business_glossary_term' = 'Commodity Grade or Quality Classification');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `contract_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Contract Reference Number');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `data_source` SET TAGS ('dbx_value_regex' = 'field_measurement|operator_report|third_party_audit|satellite_imagery|iot_sensor');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `depletion_charge` SET TAGS ('dbx_business_glossary_term' = 'Depletion Charge');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `environmental_incident_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Incident Flag');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `ghg_emissions_tonnes_co2e` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Emissions in Tonnes Carbon Dioxide Equivalent (CO2e)');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `gross_revenue` SET TAGS ('dbx_business_glossary_term' = 'Gross Revenue');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `harvest_method` SET TAGS ('dbx_business_glossary_term' = 'Harvest or Extraction Method');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `hedging_instrument_flag` SET TAGS ('dbx_business_glossary_term' = 'Hedging Instrument Flag');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `net_operating_income` SET TAGS ('dbx_business_glossary_term' = 'Net Operating Income (NOI)');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Production Record Notes');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `operating_cost` SET TAGS ('dbx_business_glossary_term' = 'Operating Cost');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `operator_name` SET TAGS ('dbx_business_glossary_term' = 'Operator Name');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `operator_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `operator_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `price_realization_percentage` SET TAGS ('dbx_business_glossary_term' = 'Price Realization Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `pricing_currency` SET TAGS ('dbx_business_glossary_term' = 'Pricing Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `pricing_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `production_efficiency_rate` SET TAGS ('dbx_business_glossary_term' = 'Production Efficiency Rate (Percentage)');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `production_status` SET TAGS ('dbx_business_glossary_term' = 'Production Status');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `production_status` SET TAGS ('dbx_value_regex' = 'preliminary|confirmed|audited|adjusted|final');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `production_unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Production Unit of Measure (UOM)');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `production_volume` SET TAGS ('dbx_business_glossary_term' = 'Production Volume');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `realized_price_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Realized Price Per Unit');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `record_updated_by` SET TAGS ('dbx_business_glossary_term' = 'Record Updated By User');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `regulatory_compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Status');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `regulatory_compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|under_review|remediation_in_progress');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `remaining_reserves_estimate` SET TAGS ('dbx_business_glossary_term' = 'Remaining Reserves Estimate');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `reserve_life_years` SET TAGS ('dbx_business_glossary_term' = 'Reserve Life in Years');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `resource_type` SET TAGS ('dbx_business_glossary_term' = 'Resource Type');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `resource_type` SET TAGS ('dbx_value_regex' = 'timber|farmland|mining|oil_gas|renewable_energy|water');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `royalty_payment` SET TAGS ('dbx_business_glossary_term' = 'Royalty Payment');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `safety_incident_count` SET TAGS ('dbx_business_glossary_term' = 'Safety Incident Count');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `third_party_operator_flag` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Operator Flag');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `water_usage_unit` SET TAGS ('dbx_business_glossary_term' = 'Water Usage Unit of Measure');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `water_usage_unit` SET TAGS ('dbx_value_regex' = 'cubic_meters|gallons|acre_feet|liters');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `water_usage_volume` SET TAGS ('dbx_business_glossary_term' = 'Water Usage Volume');
ALTER TABLE `asset_management`.`naturalresource`.`production_record` ALTER COLUMN `weather_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Weather Impact Flag');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` SET TAGS ('dbx_subdomain' = 'financial_valuation');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `commodity_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Commodity Exposure Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `macro_indicator_id` SET TAGS ('dbx_business_glossary_term' = 'Macro Indicator Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `market_consensus_id` SET TAGS ('dbx_business_glossary_term' = 'Market Consensus Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `natural_resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `benchmark_commodity_index` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Commodity Index');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `benchmark_ticker` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Ticker Symbol');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `commodity_subtype` SET TAGS ('dbx_business_glossary_term' = 'Commodity Subtype');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `commodity_type` SET TAGS ('dbx_business_glossary_term' = 'Commodity Type');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `correlation_to_portfolio` SET TAGS ('dbx_business_glossary_term' = 'Correlation to Portfolio');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `depletion_rate_annual` SET TAGS ('dbx_business_glossary_term' = 'Depletion Rate Annual');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `esg_carbon_intensity` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Carbon Intensity');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `esg_water_usage_intensity` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Water Usage Intensity');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `exposure_classification` SET TAGS ('dbx_business_glossary_term' = 'Exposure Classification');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `exposure_classification` SET TAGS ('dbx_value_regex' = 'direct_production|reserve_based|contract_linked|fund_investment|indirect');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `exposure_duration_years` SET TAGS ('dbx_business_glossary_term' = 'Exposure Duration in Years');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `exposure_notional_usd` SET TAGS ('dbx_business_glossary_term' = 'Exposure Notional United States Dollar (USD)');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `exposure_percentage_of_aum` SET TAGS ('dbx_business_glossary_term' = 'Exposure Percentage of Assets Under Management (AUM)');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `exposure_status` SET TAGS ('dbx_business_glossary_term' = 'Exposure Status');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `exposure_status` SET TAGS ('dbx_value_regex' = 'active|hedged|closed|under_review|suspended');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `fair_value_level` SET TAGS ('dbx_business_glossary_term' = 'Fair Value Level');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `fair_value_level` SET TAGS ('dbx_value_regex' = 'level_1|level_2|level_3');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `forward_curve_contango_backwardation` SET TAGS ('dbx_business_glossary_term' = 'Forward Curve Contango or Backwardation');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `forward_curve_contango_backwardation` SET TAGS ('dbx_value_regex' = 'contango|backwardation|flat|not_applicable');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `fx_rate_to_reporting_currency` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate to Reporting Currency');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `hedge_ratio_percentage` SET TAGS ('dbx_business_glossary_term' = 'Hedge Ratio Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `hedging_instrument_type` SET TAGS ('dbx_business_glossary_term' = 'Hedging Instrument Type');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `hedging_instrument_type` SET TAGS ('dbx_value_regex' = 'futures|forwards|swaps|options|collars|none');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active Flag');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `measurement_date` SET TAGS ('dbx_business_glossary_term' = 'Measurement Date');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `price_sensitivity_dv01` SET TAGS ('dbx_business_glossary_term' = 'Price Sensitivity Dollar Value of 01 Basis Point (DV01)');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `price_unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Price Unit of Measure');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `production_volume_annual` SET TAGS ('dbx_business_glossary_term' = 'Production Volume Annual');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `quantity_exposed` SET TAGS ('dbx_business_glossary_term' = 'Quantity Exposed');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `quantity_unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Quantity Unit of Measure');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `regulatory_classification` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Classification');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `reporting_currency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Currency');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `reporting_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `reserve_classification` SET TAGS ('dbx_business_glossary_term' = 'Reserve Classification');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `reserve_classification` SET TAGS ('dbx_value_regex' = 'proven|probable|possible|inferred|measured|indicated');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `reserve_quantity` SET TAGS ('dbx_business_glossary_term' = 'Reserve Quantity');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `spot_price_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Spot Price Per Unit');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Valuation Methodology');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_value_regex' = 'dcf|comparable_transactions|net_asset_value|market_multiple|reserve_based');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `var_contribution_usd` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Contribution United States Dollar (USD)');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` SET TAGS ('dbx_subdomain' = 'operations_production');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `depletion_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Depletion Schedule Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `investment_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `natural_resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `reserve_estimate_id` SET TAGS ('dbx_business_glossary_term' = 'Reserve Estimate Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `acquisition_cost` SET TAGS ('dbx_business_glossary_term' = 'Asset Acquisition Cost');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `acquisition_cost` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `acquisition_cost_currency` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Cost Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `acquisition_cost_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `acquisition_date` SET TAGS ('dbx_business_glossary_term' = 'Asset Acquisition Date');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `asset_type` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset Type');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `asset_type` SET TAGS ('dbx_value_regex' = 'timberland|farmland|mining|oil_gas|mineral_rights|water_rights');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `commodity_price_assumption` SET TAGS ('dbx_business_glossary_term' = 'Commodity Price Assumption');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `commodity_price_assumption` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `cumulative_depletion_to_date` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Depletion Expense to Date');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `cumulative_depletion_to_date` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `cumulative_impairment_loss` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Impairment Loss');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `cumulative_impairment_loss` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `cumulative_production_to_date` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Production to Date');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `cumulative_production_to_date` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `current_period_depletion` SET TAGS ('dbx_business_glossary_term' = 'Current Period Depletion Expense');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `current_period_depletion` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `current_period_production` SET TAGS ('dbx_business_glossary_term' = 'Current Period Production Volume');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `current_period_production` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `depletable_base` SET TAGS ('dbx_business_glossary_term' = 'Depletable Cost Base');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `depletable_base` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `depletion_method` SET TAGS ('dbx_business_glossary_term' = 'Depletion Method');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `depletion_method` SET TAGS ('dbx_value_regex' = 'unit_of_production|straight_line|declining_balance|percentage_depletion|cost_depletion');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `depletion_rate_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Depletion Rate per Unit');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `depletion_rate_per_unit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `depletion_schedule_status` SET TAGS ('dbx_business_glossary_term' = 'Depletion Schedule Status');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `depletion_schedule_status` SET TAGS ('dbx_value_regex' = 'active|suspended|depleted|impaired|disposed');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `discount_rate` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `discount_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `environmental_reclamation_reserve` SET TAGS ('dbx_business_glossary_term' = 'Environmental Reclamation Reserve');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `environmental_reclamation_reserve` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `estimated_depletion_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Estimated Depletion Completion Date');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `external_reserve_engineer` SET TAGS ('dbx_business_glossary_term' = 'External Reserve Engineer');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `impairment_indicator_flag` SET TAGS ('dbx_business_glossary_term' = 'Impairment Indicator Flag');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `impairment_test_date` SET TAGS ('dbx_business_glossary_term' = 'Last Impairment Test Date');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `last_reserve_certification_date` SET TAGS ('dbx_business_glossary_term' = 'Last Reserve Certification Date');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `net_book_value` SET TAGS ('dbx_business_glossary_term' = 'Net Book Value (NBV)');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `net_book_value` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Depletion Schedule Notes');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `remaining_reserves` SET TAGS ('dbx_business_glossary_term' = 'Remaining Proven Reserves');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `remaining_reserves` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `reserve_revision_date` SET TAGS ('dbx_business_glossary_term' = 'Reserve Revision Date');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `reserve_revision_reason` SET TAGS ('dbx_business_glossary_term' = 'Reserve Revision Reason');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `reserve_unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Reserve Unit of Measure');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `residual_land_value` SET TAGS ('dbx_business_glossary_term' = 'Residual Land Value');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `residual_land_value` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `responsible_investment_officer` SET TAGS ('dbx_business_glossary_term' = 'Responsible Investment Officer');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `schedule_name` SET TAGS ('dbx_business_glossary_term' = 'Depletion Schedule Name');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `tax_depletion_allowance` SET TAGS ('dbx_business_glossary_term' = 'Tax Depletion Allowance');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `tax_depletion_allowance` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `tax_depletion_method` SET TAGS ('dbx_business_glossary_term' = 'Tax Depletion Method');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `tax_depletion_method` SET TAGS ('dbx_value_regex' = 'cost_depletion|percentage_depletion|not_applicable');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `total_proven_reserves` SET TAGS ('dbx_business_glossary_term' = 'Total Proven Reserves at Acquisition');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `total_proven_reserves` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ALTER COLUMN `valuation_model_reference` SET TAGS ('dbx_business_glossary_term' = 'Valuation Model Reference');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` SET TAGS ('dbx_subdomain' = 'operations_production');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `reserve_estimate_id` SET TAGS ('dbx_business_glossary_term' = 'Reserve Estimate Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `previous_estimate_reserve_estimate_id` SET TAGS ('dbx_business_glossary_term' = 'Previous Reserve Estimate Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Asset Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `audit_firm_name` SET TAGS ('dbx_business_glossary_term' = 'Independent Audit Firm Name');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `audit_report_date` SET TAGS ('dbx_business_glossary_term' = 'Audit Report Date');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `capital_expenditure_estimate` SET TAGS ('dbx_business_glossary_term' = 'Capital Expenditure (CAPEX) Estimate');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `commodity_price_assumption` SET TAGS ('dbx_business_glossary_term' = 'Commodity Price Assumption');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `commodity_type` SET TAGS ('dbx_business_glossary_term' = 'Commodity Type');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `confidence_level_percent` SET TAGS ('dbx_business_glossary_term' = 'Reserve Estimate Confidence Level Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Record Created By User');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `depletion_method` SET TAGS ('dbx_business_glossary_term' = 'Depletion Accounting Method');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `depletion_method` SET TAGS ('dbx_value_regex' = 'unit_of_production|straight_line|declining_balance|cost_depletion|percentage_depletion');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `discount_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Reserve Estimate Effective Date');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `environmental_adjustment_factor` SET TAGS ('dbx_business_glossary_term' = 'Environmental Adjustment Factor');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `estimate_identifier` SET TAGS ('dbx_business_glossary_term' = 'Reserve Estimate Business Identifier');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `estimate_status` SET TAGS ('dbx_business_glossary_term' = 'Reserve Estimate Status');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `estimate_status` SET TAGS ('dbx_value_regex' = 'draft|preliminary|final|superseded|archived');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `estimated_npv` SET TAGS ('dbx_business_glossary_term' = 'Estimated Net Present Value (NPV)');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `estimated_npv` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `estimation_method` SET TAGS ('dbx_business_glossary_term' = 'Reserve Estimation Method');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `geological_model_version` SET TAGS ('dbx_business_glossary_term' = 'Geological Model Version');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `gross_reserves` SET TAGS ('dbx_business_glossary_term' = 'Gross Reserves Quantity');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `independent_audit_flag` SET TAGS ('dbx_business_glossary_term' = 'Independent Audit Flag');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `modified_by_user` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified By User');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `net_reserves` SET TAGS ('dbx_business_glossary_term' = 'Net Reserves Quantity');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Reserve Estimate Notes');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `operating_cost_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Operating Cost Per Unit');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `price_deck_scenario` SET TAGS ('dbx_business_glossary_term' = 'Price Deck Scenario');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `price_deck_scenario` SET TAGS ('dbx_value_regex' = 'base_case|bull_case|bear_case|spot|forward_curve|consensus');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `production_start_date` SET TAGS ('dbx_business_glossary_term' = 'Production Start Date');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `qualified_person_credentials` SET TAGS ('dbx_business_glossary_term' = 'Qualified Person Professional Credentials');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `qualified_person_name` SET TAGS ('dbx_business_glossary_term' = 'Qualified Person Name');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `qualified_person_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `qualified_person_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `recoverable_quantity` SET TAGS ('dbx_business_glossary_term' = 'Estimated Recoverable Quantity');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `recovery_factor_percent` SET TAGS ('dbx_business_glossary_term' = 'Recovery Factor Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Status');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_value_regex' = 'approved|pending|conditional|denied|not_required');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `reporting_standard` SET TAGS ('dbx_business_glossary_term' = 'Reserve Reporting Standard');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `reporting_standard` SET TAGS ('dbx_value_regex' = 'SPE-PRMS|JORC|NI43-101|SEC|SAMREC|PERC');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `reserve_booking_date` SET TAGS ('dbx_business_glossary_term' = 'Reserve Booking Date');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `reserve_category` SET TAGS ('dbx_business_glossary_term' = 'Reserve Category Classification');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `reserve_life_years` SET TAGS ('dbx_business_glossary_term' = 'Reserve Life in Years');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `revision_reason` SET TAGS ('dbx_business_glossary_term' = 'Reserve Estimate Revision Reason');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `royalty_burden_percent` SET TAGS ('dbx_business_glossary_term' = 'Royalty Burden Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure (UOM)');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Reserve Valuation Date');
ALTER TABLE `asset_management`.`naturalresource`.`reserve_estimate` ALTER COLUMN `working_interest_percent` SET TAGS ('dbx_business_glossary_term' = 'Working Interest Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` SET TAGS ('dbx_subdomain' = 'financial_valuation');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `resource_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Valuation Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `commodity_price_deck_id` SET TAGS ('dbx_business_glossary_term' = 'Commodity Price Deck Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `country_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Country Outlook Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `depletion_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Depletion Schedule Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `research_fx_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Research Fx Rate Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `research_report_id` SET TAGS ('dbx_business_glossary_term' = 'Report Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `research_yield_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Research Yield Curve Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `reserve_estimate_id` SET TAGS ('dbx_business_glossary_term' = 'Reserve Estimate Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Asset Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `sector_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Sector Outlook Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `appraisal_firm_name` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Firm Name');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `appraisal_report_date` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Report Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `capital_expenditure_assumption` SET TAGS ('dbx_business_glossary_term' = 'Capital Expenditure (CapEx) Assumption');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `carbon_price_assumption` SET TAGS ('dbx_business_glossary_term' = 'Carbon Price Assumption');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `comparable_transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Comparable Transaction Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `comparable_transaction_multiple` SET TAGS ('dbx_business_glossary_term' = 'Comparable Transaction Multiple');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `discount_rate` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `esg_adjustment_factor` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Adjustment Factor');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `fair_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Fair Value Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `fair_value_hierarchy_level` SET TAGS ('dbx_business_glossary_term' = 'Fair Value Hierarchy Level');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `fair_value_hierarchy_level` SET TAGS ('dbx_value_regex' = 'Level_1|Level_2|Level_3');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `geopolitical_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Geopolitical Risk Rating');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `geopolitical_risk_rating` SET TAGS ('dbx_value_regex' = 'low|moderate|high|severe');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `inflation_rate` SET TAGS ('dbx_business_glossary_term' = 'Inflation Rate');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `liquidity_discount` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Discount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `nav_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Per Unit');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `operating_cost_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Operating Cost Per Unit');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `prior_valuation_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Valuation Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `production_unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Production Unit of Measure');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `production_volume_assumption` SET TAGS ('dbx_business_glossary_term' = 'Production Volume Assumption');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `regulatory_risk_adjustment` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Risk Adjustment');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `reserve_life_years` SET TAGS ('dbx_business_glossary_term' = 'Reserve Life Years');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `sensitivity_analysis_performed` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Analysis Performed Flag');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `terminal_value_assumption` SET TAGS ('dbx_business_glossary_term' = 'Terminal Value Assumption');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `valuation_analyst_name` SET TAGS ('dbx_business_glossary_term' = 'Valuation Analyst Name');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `valuation_analyst_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `valuation_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Valuation Change Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `valuation_change_percentage` SET TAGS ('dbx_business_glossary_term' = 'Valuation Change Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `valuation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Valuation Frequency');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `valuation_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|ad_hoc');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'DCF|comparable_transaction|NAV|appraisal|market_approach|income_approach');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `valuation_model_version` SET TAGS ('dbx_business_glossary_term' = 'Valuation Model Version');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `valuation_notes` SET TAGS ('dbx_business_glossary_term' = 'Valuation Notes');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `valuation_reviewer_name` SET TAGS ('dbx_business_glossary_term' = 'Valuation Reviewer Name');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `valuation_reviewer_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `valuation_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Status');
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ALTER COLUMN `valuation_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|final|superseded');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` SET TAGS ('dbx_subdomain' = 'financial_valuation');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `capital_event_id` SET TAGS ('dbx_business_glossary_term' = 'Capital Event Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `natural_resource_investment_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Investment Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Investment Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `resource_fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Fund Commitment Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `resource_holding_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Holding Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|escalated');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Reference');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `capital_recycling_flag` SET TAGS ('dbx_business_glossary_term' = 'Capital Recycling Flag');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Commitment Amount');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `commodity_price_reference` SET TAGS ('dbx_business_glossary_term' = 'Commodity Price Reference');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `depletion_adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Depletion Adjustment Amount');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `distribution_type` SET TAGS ('dbx_business_glossary_term' = 'Distribution Type');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `distribution_type` SET TAGS ('dbx_value_regex' = 'return_of_capital|income|preferred_return|carried_interest|recallable|final');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `distributions_to_date` SET TAGS ('dbx_business_glossary_term' = 'Distributions to Date');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Due Date');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `event_amount` SET TAGS ('dbx_business_glossary_term' = 'Event Amount');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `event_amount_base_currency` SET TAGS ('dbx_business_glossary_term' = 'Event Amount in Base Currency');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `event_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Event Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `event_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `event_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Event Reference Number');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `event_status` SET TAGS ('dbx_business_glossary_term' = 'Event Status');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `event_status` SET TAGS ('dbx_value_regex' = 'notified|confirmed|funded|settled|cancelled|recalled');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `event_type` SET TAGS ('dbx_business_glossary_term' = 'Capital Event Type');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `exception_notes` SET TAGS ('dbx_business_glossary_term' = 'Exception Notes');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `fund_administrator_name` SET TAGS ('dbx_business_glossary_term' = 'Fund Administrator Name');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `gp_entity_name` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Entity Name');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `net_distribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Distribution Amount');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `notice_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Notice Document Reference');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `notification_date` SET TAGS ('dbx_business_glossary_term' = 'Notification Date');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `paid_in_capital_to_date` SET TAGS ('dbx_business_glossary_term' = 'Paid-In Capital (PIC) to Date');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `payment_instruction_reference` SET TAGS ('dbx_business_glossary_term' = 'Payment Instruction Reference');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `production_linked_flag` SET TAGS ('dbx_business_glossary_term' = 'Production-Linked Distribution Flag');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `recall_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Recall Expiration Date');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `recallable_flag` SET TAGS ('dbx_business_glossary_term' = 'Recallable Distribution Flag');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'pending|matched|exception|resolved');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `resource_asset_type` SET TAGS ('dbx_business_glossary_term' = 'Resource Asset Type');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `unfunded_commitment` SET TAGS ('dbx_business_glossary_term' = 'Unfunded Commitment (Dry Powder)');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `valuation_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Valuation Impact Amount');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Amount');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `withholding_tax_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Jurisdiction');
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ALTER COLUMN `withholding_tax_jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` SET TAGS ('dbx_subdomain' = 'asset_ownership');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `operator_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Operator Agreement Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `investment_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `natural_resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `agreement_name` SET TAGS ('dbx_business_glossary_term' = 'Agreement Name');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `agreement_number` SET TAGS ('dbx_business_glossary_term' = 'Agreement Number');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `agreement_status` SET TAGS ('dbx_business_glossary_term' = 'Agreement Status');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `agreement_status` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|active|suspended|terminated|expired');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Agreement Type');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'operating_agreement|joint_venture|farm_out|royalty_agreement|offtake_agreement|management_contract');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `amendment_count` SET TAGS ('dbx_business_glossary_term' = 'Amendment Count');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `assignment_restriction_flag` SET TAGS ('dbx_business_glossary_term' = 'Assignment Restriction Flag');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `audit_rights_flag` SET TAGS ('dbx_business_glossary_term' = 'Audit Rights Flag');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `capital_call_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Notice Days');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `change_of_control_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Change of Control Clause Flag');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `confidentiality_obligation_flag` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Obligation Flag');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `cost_allocation_method` SET TAGS ('dbx_business_glossary_term' = 'Cost Allocation Method');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `cost_allocation_method` SET TAGS ('dbx_value_regex' = 'proportional|fixed|variable|tiered');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `default_cure_period_days` SET TAGS ('dbx_business_glossary_term' = 'Default Cure Period Days');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Mechanism');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_value_regex' = 'litigation|arbitration|mediation|expert_determination');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `document_repository_path` SET TAGS ('dbx_business_glossary_term' = 'Document Repository Path');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `document_repository_path` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `environmental_compliance_standard` SET TAGS ('dbx_business_glossary_term' = 'Environmental Compliance Standard');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `execution_date` SET TAGS ('dbx_business_glossary_term' = 'Execution Date');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `force_majeure_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Force Majeure Provision Flag');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `governing_law` SET TAGS ('dbx_business_glossary_term' = 'Governing Law');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `hurdle_rate` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `insurance_requirement` SET TAGS ('dbx_business_glossary_term' = 'Insurance Requirement');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `last_amendment_date` SET TAGS ('dbx_business_glossary_term' = 'Last Amendment Date');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `management_fee_basis` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Basis');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `management_fee_basis` SET TAGS ('dbx_value_regex' = 'nav|gav|revenue|production|fixed');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `management_fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Rate');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `non_compete_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Non-Compete Clause Flag');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Agreement Notes');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `operator_entity_code` SET TAGS ('dbx_business_glossary_term' = 'Operator Entity Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `operator_lei` SET TAGS ('dbx_business_glossary_term' = 'Operator Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `operator_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `operator_name` SET TAGS ('dbx_business_glossary_term' = 'Operator Name');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `operator_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `operator_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `operator_ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Operator Ownership Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `operator_role` SET TAGS ('dbx_business_glossary_term' = 'Operator Role');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `operator_role` SET TAGS ('dbx_value_regex' = 'lead_operator|co_operator|managing_partner|non_operating_partner|technical_advisor');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `performance_fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Performance Fee Rate');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `revenue_sharing_method` SET TAGS ('dbx_business_glossary_term' = 'Revenue Sharing Method');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `revenue_sharing_method` SET TAGS ('dbx_value_regex' = 'proportional|waterfall|tiered|fixed');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` SET TAGS ('dbx_subdomain' = 'financial_valuation');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `royalty_obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Royalty Obligation Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `natural_resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `audit_rights` SET TAGS ('dbx_business_glossary_term' = 'Audit Rights');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `benchmark_price_index` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Price Index');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `commodity_type` SET TAGS ('dbx_business_glossary_term' = 'Commodity Type');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `deductible_cost_types` SET TAGS ('dbx_business_glossary_term' = 'Deductible Cost Types');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `deductible_costs_allowed` SET TAGS ('dbx_business_glossary_term' = 'Deductible Costs Allowed');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `depletion_method` SET TAGS ('dbx_business_glossary_term' = 'Depletion Method');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `depletion_method` SET TAGS ('dbx_value_regex' = 'units_of_production|straight_line|declining_balance|not_applicable');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `discount_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate Percentage (%)');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Mechanism');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_value_regex' = 'arbitration|litigation|mediation|expert_determination');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `environmental_compliance_required` SET TAGS ('dbx_business_glossary_term' = 'Environmental Compliance Required');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `escalation_clause` SET TAGS ('dbx_business_glossary_term' = 'Escalation Clause');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `esg_performance_conditions` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Performance Conditions');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `estimated_reserves_quantity` SET TAGS ('dbx_business_glossary_term' = 'Estimated Reserves Quantity');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `fair_value_estimate` SET TAGS ('dbx_business_glossary_term' = 'Fair Value Estimate');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `governing_law_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Governing Law Jurisdiction');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `governing_law_jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `government_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Government Jurisdiction');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `government_jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `indigenous_community_name` SET TAGS ('dbx_business_glossary_term' = 'Indigenous Community Name');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `indigenous_community_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `minimum_royalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Royalty Amount');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `obligation_status` SET TAGS ('dbx_business_glossary_term' = 'Obligation Status');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `obligation_status` SET TAGS ('dbx_value_regex' = 'active|suspended|terminated|in_dispute|under_review');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `payment_due_day` SET TAGS ('dbx_business_glossary_term' = 'Payment Due Day');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|upon_production');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `price_adjustment_formula` SET TAGS ('dbx_business_glossary_term' = 'Price Adjustment Formula');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `reserves_unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Reserves Unit of Measure');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `reserves_unit_of_measure` SET TAGS ('dbx_value_regex' = 'barrels|cubic_meters|tonnes|board_feet|acres|hectares');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `royalty_agreement_number` SET TAGS ('dbx_business_glossary_term' = 'Royalty Agreement Number');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `royalty_base_type` SET TAGS ('dbx_business_glossary_term' = 'Royalty Base Type');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `royalty_base_type` SET TAGS ('dbx_value_regex' = 'gross_revenue|net_revenue|production_volume|net_profits|wellhead_value');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `royalty_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Royalty Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `royalty_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `royalty_holder_lei` SET TAGS ('dbx_business_glossary_term' = 'Royalty Holder Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `royalty_holder_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `royalty_holder_name` SET TAGS ('dbx_business_glossary_term' = 'Royalty Holder Name');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `royalty_holder_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `royalty_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Royalty Rate Percentage (%)');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `royalty_type` SET TAGS ('dbx_business_glossary_term' = 'Royalty Type');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `royalty_type` SET TAGS ('dbx_value_regex' = 'government_royalty|landowner_royalty|overriding_royalty_interest|net_profits_interest|production_payment|indigenous_royalty');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `suspension_reason` SET TAGS ('dbx_business_glossary_term' = 'Suspension Reason');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `treaty_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Treaty Reference Number');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `updated_by_user` SET TAGS ('dbx_business_glossary_term' = 'Updated By User');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Valuation Methodology');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_obligation` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_value_regex' = 'discounted_cash_flow|comparable_transactions|income_approach|market_approach');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` SET TAGS ('dbx_subdomain' = 'financial_valuation');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `royalty_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Royalty Payment Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `natural_resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Payee Bank Account Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `record_updated_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Record Updated By User Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `record_updated_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `record_updated_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `royalty_obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Royalty Obligation Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `commodity_price` SET TAGS ('dbx_business_glossary_term' = 'Commodity Price');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `commodity_price_currency` SET TAGS ('dbx_business_glossary_term' = 'Commodity Price Currency');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `commodity_price_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `deduction_amount` SET TAGS ('dbx_business_glossary_term' = 'Deduction Amount');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Flag');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `fx_rate_to_base` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate to Base Currency');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `gl_posting_date` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Posting Date');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `gross_revenue_base` SET TAGS ('dbx_business_glossary_term' = 'Gross Revenue Base');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `local_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Local Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `local_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `net_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Payment Amount');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `payee_legal_entity_code` SET TAGS ('dbx_business_glossary_term' = 'Payee Legal Entity Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `payment_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Approval Date');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|ach|check|eft|direct_deposit');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `payment_notes` SET TAGS ('dbx_business_glossary_term' = 'Payment Notes');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `payment_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Number');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `payment_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Period End Date');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `payment_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Period Start Date');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'pending|processed|settled|cancelled|disputed|reversed');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `production_unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Production Unit of Measure');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `production_volume` SET TAGS ('dbx_business_glossary_term' = 'Production Volume');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `reversal_date` SET TAGS ('dbx_business_glossary_term' = 'Reversal Date');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Reversal Flag');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `reversal_reason` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `royalty_amount_base` SET TAGS ('dbx_business_glossary_term' = 'Royalty Amount Base Currency');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `royalty_amount_local` SET TAGS ('dbx_business_glossary_term' = 'Royalty Amount Local Currency');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `royalty_rate` SET TAGS ('dbx_business_glossary_term' = 'Royalty Rate');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Amount');
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ALTER COLUMN `withholding_tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Rate');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` SET TAGS ('dbx_subdomain' = 'asset_ownership');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `land_parcel_id` SET TAGS ('dbx_business_glossary_term' = 'Land Parcel Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Manager Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `investment_portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `acquisition_cost` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Cost');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `acquisition_cost` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `acquisition_date` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Date');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `annual_property_tax` SET TAGS ('dbx_business_glossary_term' = 'Annual Property Tax');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `annual_property_tax` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `biodiversity_score` SET TAGS ('dbx_business_glossary_term' = 'Biodiversity Score');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `cadastral_reference` SET TAGS ('dbx_business_glossary_term' = 'Cadastral Reference Number');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `carbon_sequestration_potential` SET TAGS ('dbx_business_glossary_term' = 'Carbon Sequestration Potential');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `county_municipality` SET TAGS ('dbx_business_glossary_term' = 'County or Municipality');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `crop_type` SET TAGS ('dbx_business_glossary_term' = 'Crop Type');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `elevation_meters` SET TAGS ('dbx_business_glossary_term' = 'Elevation in Meters');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `encumbrance_description` SET TAGS ('dbx_business_glossary_term' = 'Encumbrance Description');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `encumbrance_flag` SET TAGS ('dbx_business_glossary_term' = 'Encumbrance Flag');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `environmental_designation` SET TAGS ('dbx_business_glossary_term' = 'Environmental Designation');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `insurance_coverage_amount` SET TAGS ('dbx_business_glossary_term' = 'Insurance Coverage Amount');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `insurance_coverage_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `land_use_type` SET TAGS ('dbx_business_glossary_term' = 'Land Use Type');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `land_use_type` SET TAGS ('dbx_value_regex' = 'timberland|farmland|mining_surface|energy_surface|mixed_use|conservation');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `last_valuation_amount` SET TAGS ('dbx_business_glossary_term' = 'Last Valuation Amount');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `last_valuation_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `last_valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Valuation Date');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'Latitude');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `lease_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Lease Expiry Date');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `legal_land_description` SET TAGS ('dbx_business_glossary_term' = 'Legal Land Description');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'Longitude');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `mineral_resource_type` SET TAGS ('dbx_business_glossary_term' = 'Mineral Resource Type');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `ownership_type` SET TAGS ('dbx_business_glossary_term' = 'Ownership Type');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `ownership_type` SET TAGS ('dbx_value_regex' = 'fee_simple|leasehold|surface_rights|mineral_rights|easement|co_ownership');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `parcel_name` SET TAGS ('dbx_business_glossary_term' = 'Parcel Name');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `parcel_status` SET TAGS ('dbx_business_glossary_term' = 'Parcel Status');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `parcel_status` SET TAGS ('dbx_value_regex' = 'active|under_development|conservation|divested|pending_acquisition');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `productive_area_hectares` SET TAGS ('dbx_business_glossary_term' = 'Productive Area in Hectares');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `road_access_type` SET TAGS ('dbx_business_glossary_term' = 'Road Access Type');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `road_access_type` SET TAGS ('dbx_value_regex' = 'paved|gravel|seasonal|none');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `soil_classification` SET TAGS ('dbx_business_glossary_term' = 'Soil Classification');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `state_province` SET TAGS ('dbx_business_glossary_term' = 'State or Province');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `timber_volume_m3` SET TAGS ('dbx_business_glossary_term' = 'Timber Volume in Cubic Meters');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `title_deed_reference` SET TAGS ('dbx_business_glossary_term' = 'Title Deed Reference');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `topography_type` SET TAGS ('dbx_business_glossary_term' = 'Topography Type');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `topography_type` SET TAGS ('dbx_value_regex' = 'flat|rolling|hilly|mountainous|mixed');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `total_area_hectares` SET TAGS ('dbx_business_glossary_term' = 'Total Area in Hectares');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'comparable_sales|income_approach|cost_approach|discounted_cash_flow|hybrid');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `water_access_flag` SET TAGS ('dbx_business_glossary_term' = 'Water Access Flag');
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ALTER COLUMN `zoning_designation` SET TAGS ('dbx_business_glossary_term' = 'Zoning Designation');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` SET TAGS ('dbx_subdomain' = 'sustainability_compliance');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `environmental_permit_id` SET TAGS ('dbx_business_glossary_term' = 'Environmental Permit Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `natural_resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `amendment_count` SET TAGS ('dbx_business_glossary_term' = 'Amendment Count');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `authorized_activity` SET TAGS ('dbx_business_glossary_term' = 'Authorized Activity');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `bond_amount` SET TAGS ('dbx_business_glossary_term' = 'Reclamation Bond Amount');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `bond_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `bond_currency` SET TAGS ('dbx_business_glossary_term' = 'Bond Currency');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `bond_status` SET TAGS ('dbx_business_glossary_term' = 'Bond Status');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `bond_status` SET TAGS ('dbx_value_regex' = 'posted|released|forfeited|under_review');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `compliance_monitoring_frequency` SET TAGS ('dbx_business_glossary_term' = 'Compliance Monitoring Frequency');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `compliance_monitoring_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annual|continuous');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|conditional|under_investigation');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Permit Effective Date');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `emissions_limit_quantity` SET TAGS ('dbx_business_glossary_term' = 'Emissions Limit Quantity');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `emissions_limit_unit` SET TAGS ('dbx_business_glossary_term' = 'Emissions Limit Unit of Measure');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `esg_impact_category` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Impact Category');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Permit Expiry Date');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `extraction_limit_quantity` SET TAGS ('dbx_business_glossary_term' = 'Extraction Limit Quantity');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `extraction_limit_unit` SET TAGS ('dbx_business_glossary_term' = 'Extraction Limit Unit of Measure');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `extraction_period` SET TAGS ('dbx_business_glossary_term' = 'Extraction Period');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `extraction_period` SET TAGS ('dbx_value_regex' = 'daily|monthly|quarterly|annual|permit_lifetime');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `ghg_emissions_scope` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Emissions Scope');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `ghg_emissions_scope` SET TAGS ('dbx_value_regex' = 'scope_1|scope_2|scope_3|not_applicable');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `inspection_frequency` SET TAGS ('dbx_business_glossary_term' = 'Inspection Frequency');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `inspection_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|ad_hoc');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'Permit Issue Date');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `issuing_authority` SET TAGS ('dbx_business_glossary_term' = 'Issuing Regulatory Authority');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `land_area_authorized_hectares` SET TAGS ('dbx_business_glossary_term' = 'Land Area Authorized (Hectares)');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `last_amendment_date` SET TAGS ('dbx_business_glossary_term' = 'Last Amendment Date');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `last_inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Last Inspection Date');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `last_violation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Violation Date');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `next_inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Inspection Date');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `penalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Penalty Amount');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `penalty_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `penalty_currency` SET TAGS ('dbx_business_glossary_term' = 'Penalty Currency');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `permit_conditions` SET TAGS ('dbx_business_glossary_term' = 'Permit Conditions');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `permit_description` SET TAGS ('dbx_business_glossary_term' = 'Permit Description');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `permit_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Permit Document Reference');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `permit_number` SET TAGS ('dbx_business_glossary_term' = 'Permit Number');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `permit_status` SET TAGS ('dbx_business_glossary_term' = 'Permit Status');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `permit_status` SET TAGS ('dbx_value_regex' = 'active|pending|expired|suspended|revoked|under_review');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `permit_type` SET TAGS ('dbx_business_glossary_term' = 'Permit Type');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `reclamation_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Reclamation Deadline Date');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `reclamation_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Reclamation Required Flag');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `renewal_date` SET TAGS ('dbx_business_glossary_term' = 'Permit Renewal Date');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `reporting_requirement` SET TAGS ('dbx_business_glossary_term' = 'Reporting Requirement');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `responsible_party_contact` SET TAGS ('dbx_business_glossary_term' = 'Responsible Party Contact');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `responsible_party_contact` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `responsible_party_contact` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `responsible_party_name` SET TAGS ('dbx_business_glossary_term' = 'Responsible Party Name');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `violation_count` SET TAGS ('dbx_business_glossary_term' = 'Violation Count');
ALTER TABLE `asset_management`.`naturalresource`.`environmental_permit` ALTER COLUMN `water_use_limit_cubic_meters` SET TAGS ('dbx_business_glossary_term' = 'Water Use Limit (Cubic Meters)');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` SET TAGS ('dbx_subdomain' = 'sustainability_compliance');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `carbon_credit_id` SET TAGS ('dbx_business_glossary_term' = 'Carbon Credit Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `natural_resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `carbon_project_id` SET TAGS ('dbx_business_glossary_term' = 'Carbon Project Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `acquisition_currency` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `acquisition_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `acquisition_date` SET TAGS ('dbx_business_glossary_term' = 'Carbon Credit Acquisition Date');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `acquisition_price_per_tonne` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Price Per Tonne');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `acquisition_price_per_tonne` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `additionality_demonstrated_flag` SET TAGS ('dbx_business_glossary_term' = 'Additionality Demonstrated Flag');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `buffer_pool_contribution_tonnes` SET TAGS ('dbx_business_glossary_term' = 'Buffer Pool Contribution in Tonnes');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `co_benefits_description` SET TAGS ('dbx_business_glossary_term' = 'Co-Benefits Description');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `counterparty_name` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Name');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `counterparty_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `credit_serial_number` SET TAGS ('dbx_business_glossary_term' = 'Carbon Credit Serial Number');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `credit_status` SET TAGS ('dbx_business_glossary_term' = 'Carbon Credit Status');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `credit_status` SET TAGS ('dbx_value_regex' = 'issued|held|retired|cancelled|transferred');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `credit_type` SET TAGS ('dbx_business_glossary_term' = 'Carbon Credit Type');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `credit_type` SET TAGS ('dbx_value_regex' = 'voluntary|compliance|REDD+|afforestation|reforestation|avoided_deforestation');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `current_market_price_per_tonne` SET TAGS ('dbx_business_glossary_term' = 'Current Market Price Per Tonne');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `current_market_price_per_tonne` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `custodian_name` SET TAGS ('dbx_business_glossary_term' = 'Custodian Name');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Carbon Credit Expiry Date');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `holding_purpose` SET TAGS ('dbx_business_glossary_term' = 'Holding Purpose');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `holding_purpose` SET TAGS ('dbx_value_regex' = 'portfolio_diversification|esg_compliance|offset_liability|trading');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `issuance_date` SET TAGS ('dbx_business_glossary_term' = 'Carbon Credit Issuance Date');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `legal_entity_identifier` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `legal_entity_identifier` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `market_price_as_of_date` SET TAGS ('dbx_business_glossary_term' = 'Market Price As-Of Date');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `market_price_currency` SET TAGS ('dbx_business_glossary_term' = 'Market Price Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `market_price_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `methodology_name` SET TAGS ('dbx_business_glossary_term' = 'Carbon Accounting Methodology Name');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `methodology_version` SET TAGS ('dbx_business_glossary_term' = 'Methodology Version');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `permanence_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Permanence Risk Rating');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `permanence_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `project_location_country` SET TAGS ('dbx_business_glossary_term' = 'Project Location Country Code');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `project_location_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `project_location_region` SET TAGS ('dbx_business_glossary_term' = 'Project Location Region');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `quantity_tonnes_co2e` SET TAGS ('dbx_business_glossary_term' = 'Carbon Credit Quantity in Tonnes Carbon Dioxide Equivalent (CO2e)');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `registry_account_number` SET TAGS ('dbx_business_glossary_term' = 'Registry Account Number');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `registry_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `registry_name` SET TAGS ('dbx_business_glossary_term' = 'Carbon Credit Registry Name');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `registry_name` SET TAGS ('dbx_value_regex' = 'Verra|Gold_Standard|Climate_Action_Reserve|American_Carbon_Registry|Other');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `retirement_beneficiary` SET TAGS ('dbx_business_glossary_term' = 'Retirement Beneficiary');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `retirement_date` SET TAGS ('dbx_business_glossary_term' = 'Carbon Credit Retirement Date');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `retirement_reason` SET TAGS ('dbx_business_glossary_term' = 'Retirement Reason');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `sdg_alignment` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Development Goals (SDG) Alignment');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `verification_body` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Verification Body');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Verification Date');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `verification_standard` SET TAGS ('dbx_business_glossary_term' = 'Carbon Credit Verification Standard');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_credit` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Carbon Credit Vintage Year');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` SET TAGS ('dbx_subdomain' = 'operations_production');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `offtake_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Offtake Agreement Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Responsible Portfolio Manager Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `natural_resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `agreement_name` SET TAGS ('dbx_business_glossary_term' = 'Offtake Agreement Name');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `agreement_number` SET TAGS ('dbx_business_glossary_term' = 'Offtake Agreement Number');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `agreement_status` SET TAGS ('dbx_business_glossary_term' = 'Offtake Agreement Status');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `amendment_count` SET TAGS ('dbx_business_glossary_term' = 'Amendment Count');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `annual_volume_quantity` SET TAGS ('dbx_business_glossary_term' = 'Annual Volume Quantity');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `benchmark_index_name` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index Name');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `ceiling_price_amount` SET TAGS ('dbx_business_glossary_term' = 'Ceiling Price Amount');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `ceiling_price_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `commodity_specification` SET TAGS ('dbx_business_glossary_term' = 'Commodity Specification');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `commodity_type` SET TAGS ('dbx_business_glossary_term' = 'Commodity Type');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `contract_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Contract Document Reference');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `contract_term_years` SET TAGS ('dbx_business_glossary_term' = 'Contract Term in Years');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `counterparty_name` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Name');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `counterparty_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `credit_support_amount` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Amount');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `credit_support_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `credit_support_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Required Flag');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `delivery_incoterm` SET TAGS ('dbx_business_glossary_term' = 'Delivery Incoterm');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `delivery_point_location` SET TAGS ('dbx_business_glossary_term' = 'Delivery Point Location');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Mechanism');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_value_regex' = 'litigation|arbitration|mediation|expert_determination');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Effective Date');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `esg_certification_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Certification Required Flag');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `esg_certification_type` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Certification Type');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Expiry Date');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `fixed_price_amount` SET TAGS ('dbx_business_glossary_term' = 'Fixed Price Amount');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `fixed_price_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `floor_price_amount` SET TAGS ('dbx_business_glossary_term' = 'Floor Price Amount');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `floor_price_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `force_majeure_clause` SET TAGS ('dbx_business_glossary_term' = 'Force Majeure Clause');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `governing_law_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Governing Law Jurisdiction');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `last_amendment_date` SET TAGS ('dbx_business_glossary_term' = 'Last Amendment Date');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `legal_counsel_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Counsel Name');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `minimum_offtake_percentage` SET TAGS ('dbx_business_glossary_term' = 'Minimum Offtake Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `payment_terms_days` SET TAGS ('dbx_business_glossary_term' = 'Payment Terms in Days');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `price_adjustment_formula` SET TAGS ('dbx_business_glossary_term' = 'Price Adjustment Formula');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `price_adjustment_formula` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `price_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Price Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `price_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `pricing_mechanism` SET TAGS ('dbx_business_glossary_term' = 'Pricing Mechanism');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `pricing_mechanism` SET TAGS ('dbx_value_regex' = 'fixed|floating|indexed|cost_plus|hybrid');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `renewal_option_flag` SET TAGS ('dbx_business_glossary_term' = 'Renewal Option Flag');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `take_or_pay_flag` SET TAGS ('dbx_business_glossary_term' = 'Take-or-Pay Clause Flag');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `termination_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Termination Notice Period in Days');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `total_contract_volume_quantity` SET TAGS ('dbx_business_glossary_term' = 'Total Contract Volume Quantity');
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ALTER COLUMN `volume_unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Volume Unit of Measure');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` SET TAGS ('dbx_subdomain' = 'financial_valuation');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `commodity_price_deck_id` SET TAGS ('dbx_business_glossary_term' = 'Commodity Price Deck Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `created_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Created By User Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `created_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `created_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `last_modified_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `last_modified_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `last_modified_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `market_data_feed_id` SET TAGS ('dbx_business_glossary_term' = 'Market Data Feed Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `natural_resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `benchmark_index` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `commodity_subtype` SET TAGS ('dbx_business_glossary_term' = 'Commodity Subtype');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `commodity_type` SET TAGS ('dbx_business_glossary_term' = 'Commodity Type');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `confidence_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `deck_name` SET TAGS ('dbx_business_glossary_term' = 'Price Deck Name');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `deck_status` SET TAGS ('dbx_business_glossary_term' = 'Price Deck Status');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `deck_status` SET TAGS ('dbx_value_regex' = 'draft|approved|active|superseded|archived');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `deck_version` SET TAGS ('dbx_business_glossary_term' = 'Price Deck Version');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `esg_impact_consideration` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Impact Consideration');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `forecast_quarter` SET TAGS ('dbx_business_glossary_term' = 'Forecast Quarter');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `forecast_year` SET TAGS ('dbx_business_glossary_term' = 'Forecast Year');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `geopolitical_risk_factor` SET TAGS ('dbx_business_glossary_term' = 'Geopolitical Risk Factor');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `geopolitical_risk_factor` SET TAGS ('dbx_value_regex' = 'low|medium|high');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `inflation_adjustment_flag` SET TAGS ('dbx_business_glossary_term' = 'Inflation Adjustment Flag');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `inflation_rate_assumption` SET TAGS ('dbx_business_glossary_term' = 'Inflation Rate Assumption');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `market_conditions_summary` SET TAGS ('dbx_business_glossary_term' = 'Market Conditions Summary');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `price_ceiling` SET TAGS ('dbx_business_glossary_term' = 'Price Ceiling');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `price_floor` SET TAGS ('dbx_business_glossary_term' = 'Price Floor');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `price_horizon` SET TAGS ('dbx_business_glossary_term' = 'Price Horizon');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `price_horizon` SET TAGS ('dbx_value_regex' = 'spot|short_term|medium_term|long_term');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `price_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Price Per Unit');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|ad_hoc');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `scenario_type` SET TAGS ('dbx_business_glossary_term' = 'Scenario Type');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `scenario_type` SET TAGS ('dbx_value_regex' = 'base|bull|bear|stress|optimistic|pessimistic');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `source_provider` SET TAGS ('dbx_business_glossary_term' = 'Source Provider');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `source_report_reference` SET TAGS ('dbx_business_glossary_term' = 'Source Report Reference');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `source_type` SET TAGS ('dbx_business_glossary_term' = 'Price Source Type');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `source_type` SET TAGS ('dbx_value_regex' = 'internal|external|consensus|proprietary');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `supply_demand_balance` SET TAGS ('dbx_business_glossary_term' = 'Supply Demand Balance');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `supply_demand_balance` SET TAGS ('dbx_value_regex' = 'surplus|balanced|deficit');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure (UOM)');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `usage_purpose` SET TAGS ('dbx_business_glossary_term' = 'Usage Purpose');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Valuation Methodology');
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ALTER COLUMN `volatility_assumption` SET TAGS ('dbx_business_glossary_term' = 'Volatility Assumption');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` SET TAGS ('dbx_subdomain' = 'financial_valuation');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `resource_budget_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Budget Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `asset_manager_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Manager Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `investment_portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `natural_resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `prepared_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Prepared By User Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `prepared_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `prepared_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `reserve_estimate_id` SET TAGS ('dbx_business_glossary_term' = 'Reserve Estimate Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Budget Approval Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `budget_amount` SET TAGS ('dbx_business_glossary_term' = 'Budget Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `budget_category` SET TAGS ('dbx_business_glossary_term' = 'Budget Expenditure Category');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `budget_notes` SET TAGS ('dbx_business_glossary_term' = 'Budget Notes');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `budget_number` SET TAGS ('dbx_business_glossary_term' = 'Budget Reference Number');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `budget_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Budget Period End Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `budget_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Budget Period Start Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `budget_status` SET TAGS ('dbx_business_glossary_term' = 'Budget Approval Status');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `budget_type` SET TAGS ('dbx_business_glossary_term' = 'Budget Type Classification');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `budget_year` SET TAGS ('dbx_business_glossary_term' = 'Budget Fiscal Year');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `cash_flow_forecast` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Forecast');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `commodity_price_assumption` SET TAGS ('dbx_business_glossary_term' = 'Commodity Price Assumption');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `commodity_price_currency` SET TAGS ('dbx_business_glossary_term' = 'Commodity Price Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `commodity_price_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `contingency_reserve` SET TAGS ('dbx_business_glossary_term' = 'Contingency Reserve');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `depletion_expense` SET TAGS ('dbx_business_glossary_term' = 'Depletion Expense');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `depreciation_expense` SET TAGS ('dbx_business_glossary_term' = 'Depreciation Expense');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `ebitda_forecast` SET TAGS ('dbx_business_glossary_term' = 'Earnings Before Interest Taxes Depreciation and Amortization (EBITDA) Forecast');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `energy_consumption_target_mwh` SET TAGS ('dbx_business_glossary_term' = 'Energy Consumption Target in Megawatt Hours (MWh)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `environmental_compliance_cost` SET TAGS ('dbx_business_glossary_term' = 'Environmental Compliance Cost');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `ghg_emissions_target_tonnes` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Emissions Target in Tonnes');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `production_unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Production Unit of Measure (UOM)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `production_volume_target` SET TAGS ('dbx_business_glossary_term' = 'Production Volume Target');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `reclamation_provision` SET TAGS ('dbx_business_glossary_term' = 'Reclamation Provision');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `revenue_forecast` SET TAGS ('dbx_business_glossary_term' = 'Revenue Forecast');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `revision_number` SET TAGS ('dbx_business_glossary_term' = 'Budget Revision Number');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `revision_reason` SET TAGS ('dbx_business_glossary_term' = 'Budget Revision Reason');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `safety_incident_target` SET TAGS ('dbx_business_glossary_term' = 'Safety Incident Target');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Budget Submission Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `variance_threshold_percentage` SET TAGS ('dbx_business_glossary_term' = 'Variance Threshold Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `water_usage_target_cubic_meters` SET TAGS ('dbx_business_glossary_term' = 'Water Usage Target in Cubic Meters');
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ALTER COLUMN `workforce_headcount_target` SET TAGS ('dbx_business_glossary_term' = 'Workforce Headcount Target');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` SET TAGS ('dbx_subdomain' = 'sustainability_compliance');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `reclamation_liability_id` SET TAGS ('dbx_business_glossary_term' = 'Reclamation Liability Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `environmental_permit_id` SET TAGS ('dbx_business_glossary_term' = 'Environmental Permit Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `natural_resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `accretion_expense_current_period` SET TAGS ('dbx_business_glossary_term' = 'Accretion Expense Current Period');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `actual_expenditure_to_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Expenditure To Date');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `area_to_reclaim_hectares` SET TAGS ('dbx_business_glossary_term' = 'Area To Reclaim (Hectares)');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `aro_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Asset Retirement Obligation (ARO) Reference Number');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `bond_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Bond Expiry Date');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `bond_provider` SET TAGS ('dbx_business_glossary_term' = 'Bond Provider');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `carbon_sequestration_potential` SET TAGS ('dbx_business_glossary_term' = 'Carbon Sequestration Potential (Tonnes CO2e)');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `contingent_liability_flag` SET TAGS ('dbx_business_glossary_term' = 'Contingent Liability Flag');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `cost_estimation_method` SET TAGS ('dbx_business_glossary_term' = 'Cost Estimation Method');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `cost_estimation_method` SET TAGS ('dbx_value_regex' = 'engineering_estimate|comparable_site|regulatory_formula|third_party_appraisal|historical_actual');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `cost_estimator_name` SET TAGS ('dbx_business_glossary_term' = 'Cost Estimator Name');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `cumulative_accretion_expense` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Accretion Expense');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `discount_rate` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `esg_impact_category` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Impact Category');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `esg_impact_category` SET TAGS ('dbx_value_regex' = 'land_restoration|water_quality|biodiversity|community_health|air_quality|waste_management');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `estimate_date` SET TAGS ('dbx_business_glossary_term' = 'Estimate Date');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `estimated_duration_months` SET TAGS ('dbx_business_glossary_term' = 'Estimated Duration (Months)');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `expected_settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Expected Settlement Date');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `fair_value_hierarchy_level` SET TAGS ('dbx_business_glossary_term' = 'Fair Value Hierarchy Level');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `fair_value_hierarchy_level` SET TAGS ('dbx_value_regex' = 'level_1|level_2|level_3');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `funding_status` SET TAGS ('dbx_business_glossary_term' = 'Funding Status');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `funding_status` SET TAGS ('dbx_value_regex' = 'unfunded|partially_funded|fully_funded|overfunded');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `inflation_rate_assumption` SET TAGS ('dbx_business_glossary_term' = 'Inflation Rate Assumption');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `initial_recognition_date` SET TAGS ('dbx_business_glossary_term' = 'Initial Recognition Date');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `last_revision_date` SET TAGS ('dbx_business_glossary_term' = 'Last Revision Date');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `liability_status` SET TAGS ('dbx_business_glossary_term' = 'Liability Status');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `liability_status` SET TAGS ('dbx_value_regex' = 'estimated|approved|funded|in_progress|completed|disputed');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `liability_type` SET TAGS ('dbx_business_glossary_term' = 'Reclamation Liability Type');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `monitoring_period_years` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Period (Years)');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `present_value_aro` SET TAGS ('dbx_business_glossary_term' = 'Present Value of Asset Retirement Obligation (ARO)');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `reclamation_bond_amount` SET TAGS ('dbx_business_glossary_term' = 'Reclamation Bond Amount');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `reclamation_plan_reference` SET TAGS ('dbx_business_glossary_term' = 'Reclamation Plan Reference');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `reclamation_scope_description` SET TAGS ('dbx_business_glossary_term' = 'Reclamation Scope Description');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `regulatory_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `regulatory_authority` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `regulatory_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Deadline Date');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `remaining_liability_balance` SET TAGS ('dbx_business_glossary_term' = 'Remaining Liability Balance');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `responsible_party_name` SET TAGS ('dbx_business_glossary_term' = 'Responsible Party Name');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `revision_amount` SET TAGS ('dbx_business_glossary_term' = 'Revision Amount');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `sensitivity_analysis_performed` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Analysis Performed');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `trust_fund_balance` SET TAGS ('dbx_business_glossary_term' = 'Trust Fund Balance');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `undiscounted_cost_estimate` SET TAGS ('dbx_business_glossary_term' = 'Undiscounted Cost Estimate');
ALTER TABLE `asset_management`.`naturalresource`.`reclamation_liability` ALTER COLUMN `valuation_notes` SET TAGS ('dbx_business_glossary_term' = 'Valuation Notes');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` SET TAGS ('dbx_subdomain' = 'asset_ownership');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `resource_fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Fund Commitment Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `investment_portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `resource_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Vehicle Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `biodiversity_commitment_flag` SET TAGS ('dbx_business_glossary_term' = 'Biodiversity Commitment Flag');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `carbon_intensity_target` SET TAGS ('dbx_business_glossary_term' = 'Carbon Intensity Target');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `carried_interest_rate` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Rate');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `catch_up_provision` SET TAGS ('dbx_business_glossary_term' = 'Catch-Up Provision');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Commitment Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Commitment Currency');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `commitment_date` SET TAGS ('dbx_business_glossary_term' = 'Commitment Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `commitment_number` SET TAGS ('dbx_business_glossary_term' = 'Commitment Number');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `commitment_status` SET TAGS ('dbx_business_glossary_term' = 'Commitment Status');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `commitment_status` SET TAGS ('dbx_value_regex' = 'pending|active|fully_called|terminated|defaulted');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `custodian_name` SET TAGS ('dbx_business_glossary_term' = 'Custodian Name');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `deal_team_lead` SET TAGS ('dbx_business_glossary_term' = 'Deal Team Lead');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `distributions_received` SET TAGS ('dbx_business_glossary_term' = 'Distributions Received');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `dpi` SET TAGS ('dbx_business_glossary_term' = 'Distributions to Paid-In (DPI)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `esg_classification` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Classification');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `esg_classification` SET TAGS ('dbx_value_regex' = 'article_6|article_8|article_9|not_classified');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `final_closing_date` SET TAGS ('dbx_business_glossary_term' = 'Final Closing Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `first_closing_date` SET TAGS ('dbx_business_glossary_term' = 'First Closing Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `fund_size_total` SET TAGS ('dbx_business_glossary_term' = 'Fund Size Total');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `fund_strategy` SET TAGS ('dbx_business_glossary_term' = 'Fund Strategy');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `fund_strategy` SET TAGS ('dbx_value_regex' = 'timberland|farmland|mining|energy|commodity|diversified_natural_resources');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `fund_term_years` SET TAGS ('dbx_business_glossary_term' = 'Fund Term Years');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Focus');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `gp_lei` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `gp_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `gp_name` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Name');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `hurdle_rate` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate (Preferred Return)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `investment_committee_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `investment_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Period End Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `irr` SET TAGS ('dbx_business_glossary_term' = 'Internal Rate of Return (IRR)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `key_person_clause` SET TAGS ('dbx_business_glossary_term' = 'Key Person Clause');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `last_capital_call_date` SET TAGS ('dbx_business_glossary_term' = 'Last Capital Call Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `last_distribution_date` SET TAGS ('dbx_business_glossary_term' = 'Last Distribution Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `lp_ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Ownership Percentage');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `management_fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Rate');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `nav` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `nav_date` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `paid_in_capital` SET TAGS ('dbx_business_glossary_term' = 'Paid-In Capital (PIC)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `pri_signatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Principles for Responsible Investment (PRI) Signatory Flag');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `rvpi` SET TAGS ('dbx_business_glossary_term' = 'Residual Value to Paid-In (RVPI)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `side_letter_flag` SET TAGS ('dbx_business_glossary_term' = 'Side Letter Flag');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `tvpi` SET TAGS ('dbx_business_glossary_term' = 'Total Value to Paid-In (TVPI)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `unfunded_commitment` SET TAGS ('dbx_business_glossary_term' = 'Unfunded Commitment (Dry Powder)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` SET TAGS ('dbx_subdomain' = 'financial_valuation');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `resource_cashflow_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Cash Flow ID');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Bank Account ID');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity ID');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User ID');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `investment_portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Portfolio ID');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `natural_resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset ID');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `offtake_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Offtake Agreement Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `accrual_date` SET TAGS ('dbx_business_glossary_term' = 'Accrual Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `capital_expenditure_amount` SET TAGS ('dbx_business_glossary_term' = 'Capital Expenditure (CAPEX) Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `cashflow_category` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Category');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `cashflow_category` SET TAGS ('dbx_value_regex' = 'commodity_sales|royalty_payment|operating_expense|capital_expenditure|reclamation_contribution|lease_payment');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `cashflow_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Period End Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `cashflow_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Period Start Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `cashflow_status` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Status');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `cashflow_status` SET TAGS ('dbx_value_regex' = 'forecasted|accrued|settled|reversed|disputed');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `cashflow_type` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Type');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `cashflow_type` SET TAGS ('dbx_value_regex' = 'operating_inflow|operating_outflow|investing_outflow|financing_inflow|financing_outflow|distribution');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `commodity_price_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Commodity Price Per Unit');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `commodity_type` SET TAGS ('dbx_business_glossary_term' = 'Commodity Type');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `counterparty_legal_entity_code` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity ID');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `depletion_charge_amount` SET TAGS ('dbx_business_glossary_term' = 'Depletion Charge Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Flag');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `esg_impact_category` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Impact Category');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `esg_impact_category` SET TAGS ('dbx_value_regex' = 'carbon_sequestration|biodiversity_conservation|water_management|community_benefit|reclamation|emissions_reduction');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `fx_rate_to_base` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate to Base');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `gross_revenue_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Revenue Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `net_cashflow_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Cash Flow Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `net_cashflow_base_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Cash Flow Base Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Notes');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `operating_expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Operating Expense Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|ach|check|cash|offset');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `production_unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Production Unit of Measure (UOM)');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `production_volume` SET TAGS ('dbx_business_glossary_term' = 'Production Volume');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `reclamation_contribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Reclamation Contribution Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `reversal_date` SET TAGS ('dbx_business_glossary_term' = 'Reversal Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Reversal Flag');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `reversal_reason` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `royalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Royalty Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Date');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` SET TAGS ('dbx_subdomain' = 'operations_production');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `operational_incident_id` SET TAGS ('dbx_business_glossary_term' = 'Operational Incident Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `natural_resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `corrective_action_plan` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action Plan Summary');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `downtime_hours` SET TAGS ('dbx_business_glossary_term' = 'Operational Downtime Hours');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `environmental_impact_description` SET TAGS ('dbx_business_glossary_term' = 'Environmental Impact Description');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `environmental_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Impact Indicator');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `esg_impact_category` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Impact Category');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `esg_impact_category` SET TAGS ('dbx_value_regex' = 'environmental|social|governance|health_safety');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `estimated_financial_impact` SET TAGS ('dbx_business_glossary_term' = 'Estimated Financial Impact Amount');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `estimated_financial_impact` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `fatality_count` SET TAGS ('dbx_business_glossary_term' = 'Fatality Count');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `force_majeure_flag` SET TAGS ('dbx_business_glossary_term' = 'Force Majeure Event Indicator');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `ghg_emissions_impact` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Emissions Impact');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `incident_description` SET TAGS ('dbx_business_glossary_term' = 'Incident Detailed Description');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `incident_end_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Incident End Date and Time');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `incident_location_description` SET TAGS ('dbx_business_glossary_term' = 'Incident Location Description');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `incident_notes` SET TAGS ('dbx_business_glossary_term' = 'Incident Additional Notes');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `incident_number` SET TAGS ('dbx_business_glossary_term' = 'Incident Reference Number');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `incident_start_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Incident Start Date and Time');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `incident_status` SET TAGS ('dbx_business_glossary_term' = 'Incident Lifecycle Status');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `incident_status` SET TAGS ('dbx_value_regex' = 'reported|under_investigation|active|contained|resolved|closed');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `incident_type` SET TAGS ('dbx_business_glossary_term' = 'Incident Type Classification');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `injury_count` SET TAGS ('dbx_business_glossary_term' = 'Injury Count');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `insurance_claim_flag` SET TAGS ('dbx_business_glossary_term' = 'Insurance Claim Filed Indicator');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `insurance_claim_number` SET TAGS ('dbx_business_glossary_term' = 'Insurance Claim Reference Number');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `insurance_claim_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `insurance_recovery_amount` SET TAGS ('dbx_business_glossary_term' = 'Insurance Recovery Amount');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `insurance_recovery_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `investigation_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Investigation Completion Date');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `investigation_status` SET TAGS ('dbx_business_glossary_term' = 'Investigation Status');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `investigation_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed|report_issued');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'Incident Latitude Coordinate');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `lessons_learned` SET TAGS ('dbx_business_glossary_term' = 'Lessons Learned Documentation');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'Incident Longitude Coordinate');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `production_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Production Impact Indicator');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `production_loss_unit` SET TAGS ('dbx_business_glossary_term' = 'Production Loss Unit of Measure');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `production_loss_volume` SET TAGS ('dbx_business_glossary_term' = 'Production Loss Volume');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `regulatory_authority_name` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Name');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `regulatory_notification_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Notification Date');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `regulatory_notification_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Notification Required Indicator');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `remediation_cost` SET TAGS ('dbx_business_glossary_term' = 'Remediation Cost Amount');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `remediation_cost` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `reported_by_name` SET TAGS ('dbx_business_glossary_term' = 'Incident Reporter Name');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `reported_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Incident Reported Date and Time');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `response_team_assigned` SET TAGS ('dbx_business_glossary_term' = 'Incident Response Team Assigned');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `root_cause_analysis` SET TAGS ('dbx_business_glossary_term' = 'Root Cause Analysis Summary');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `safety_incident_flag` SET TAGS ('dbx_business_glossary_term' = 'Safety Incident Indicator');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `severity_level` SET TAGS ('dbx_business_glossary_term' = 'Incident Severity Level');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `severity_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low|minimal');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `third_party_involvement_flag` SET TAGS ('dbx_business_glossary_term' = 'Third Party Involvement Indicator');
ALTER TABLE `asset_management`.`naturalresource`.`operational_incident` ALTER COLUMN `third_party_name` SET TAGS ('dbx_business_glossary_term' = 'Third Party Name');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` SET TAGS ('dbx_subdomain' = 'operations_production');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `harvest_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Harvest Plan Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `asset_manager_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Manager Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `legal_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Contractor Entity Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `depletion_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Depletion Schedule Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `environmental_permit_id` SET TAGS ('dbx_business_glossary_term' = 'Environmental Permit Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `investment_portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `land_parcel_id` SET TAGS ('dbx_business_glossary_term' = 'Land Parcel Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `natural_resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset Identifier (ID)');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `offtake_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Offtake Agreement Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `actual_harvest_end_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Harvest End Date');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `actual_harvest_start_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Harvest Start Date');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `actual_harvest_volume` SET TAGS ('dbx_business_glossary_term' = 'Actual Harvest Volume');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Harvest Plan Approval Date');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `biodiversity_impact_assessment` SET TAGS ('dbx_business_glossary_term' = 'Biodiversity Impact Assessment');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `biodiversity_impact_assessment` SET TAGS ('dbx_value_regex' = 'low|moderate|high|critical');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `carbon_sequestration_impact` SET TAGS ('dbx_business_glossary_term' = 'Carbon Sequestration Impact in Tonnes Carbon Dioxide Equivalent (CO2e)');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `commodity_price_assumption` SET TAGS ('dbx_business_glossary_term' = 'Commodity Price Assumption');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `commodity_price_assumption` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `estimated_cost` SET TAGS ('dbx_business_glossary_term' = 'Estimated Harvest Cost');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `estimated_cost` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `estimated_revenue` SET TAGS ('dbx_business_glossary_term' = 'Estimated Harvest Revenue');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `estimated_revenue` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `estimated_yield_per_hectare` SET TAGS ('dbx_business_glossary_term' = 'Estimated Yield Per Hectare');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `harvest_area_hectares` SET TAGS ('dbx_business_glossary_term' = 'Harvest Area in Hectares');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `harvest_method` SET TAGS ('dbx_business_glossary_term' = 'Harvest Method');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `harvest_method` SET TAGS ('dbx_value_regex' = 'clear_cut|selective|shelterwood|seed_tree|sustainable_yield|rotation');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `plan_end_date` SET TAGS ('dbx_business_glossary_term' = 'Harvest Plan End Date');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `plan_name` SET TAGS ('dbx_business_glossary_term' = 'Harvest Plan Name');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `plan_notes` SET TAGS ('dbx_business_glossary_term' = 'Harvest Plan Notes');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `plan_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Harvest Plan Reference Number');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `plan_reference_number` SET TAGS ('dbx_value_regex' = '^HP-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `plan_start_date` SET TAGS ('dbx_business_glossary_term' = 'Harvest Plan Start Date');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `plan_status` SET TAGS ('dbx_business_glossary_term' = 'Harvest Plan Status');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `plan_status` SET TAGS ('dbx_value_regex' = 'draft|approved|active|suspended|completed|cancelled');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `plan_type` SET TAGS ('dbx_business_glossary_term' = 'Harvest Plan Type');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `plan_type` SET TAGS ('dbx_value_regex' = 'timber|agricultural|mixed');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `plan_year` SET TAGS ('dbx_business_glossary_term' = 'Harvest Plan Year');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `planned_harvest_volume` SET TAGS ('dbx_business_glossary_term' = 'Planned Harvest Volume');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `price_deck_scenario` SET TAGS ('dbx_business_glossary_term' = 'Price Deck Scenario');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `price_deck_scenario` SET TAGS ('dbx_value_regex' = 'base|conservative|optimistic|stress');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `reforestation_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Reforestation Deadline Date');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `reforestation_plan_flag` SET TAGS ('dbx_business_glossary_term' = 'Reforestation Plan Flag');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Status');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|conditional|denied');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Harvest Plan Risk Rating');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `rotation_age_years` SET TAGS ('dbx_business_glossary_term' = 'Rotation Age in Years');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `species_type` SET TAGS ('dbx_business_glossary_term' = 'Species or Crop Type');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `sustainability_certification` SET TAGS ('dbx_business_glossary_term' = 'Sustainability Certification');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `sustainability_certification` SET TAGS ('dbx_value_regex' = 'FSC|SFI|PEFC|RSPO|none');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `variance_explanation` SET TAGS ('dbx_business_glossary_term' = 'Harvest Variance Explanation');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `volume_unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Volume Unit of Measure');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `volume_unit_of_measure` SET TAGS ('dbx_value_regex' = 'cubic_meters|board_feet|tonnes|bushels|bales');
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ALTER COLUMN `weather_dependency_flag` SET TAGS ('dbx_business_glossary_term' = 'Weather Dependency Flag');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_project` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_project` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_project` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_project` SET TAGS ('dbx_subdomain' = 'sustainability_compliance');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_project` ALTER COLUMN `carbon_project_id` SET TAGS ('dbx_business_glossary_term' = 'Carbon Project Identifier');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_project` ALTER COLUMN `resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Asset Id (Foreign Key)');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_project` ALTER COLUMN `current_valuation_usd` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_project` ALTER COLUMN `investment_amount_usd` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`carbon_project` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_vehicle` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`naturalresource`.`resource_vehicle` SET TAGS ('dbx_domain' = 'naturalresource');
ALTER TABLE `asset_management`.`naturalresource`.`resource_vehicle` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`naturalresource`.`resource_vehicle` SET TAGS ('dbx_subdomain' = 'asset_ownership');
ALTER TABLE `asset_management`.`naturalresource`.`resource_vehicle` ALTER COLUMN `resource_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Vehicle Identifier');
ALTER TABLE `asset_management`.`naturalresource`.`resource_vehicle` ALTER COLUMN `carried_interest_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_vehicle` ALTER COLUMN `hurdle_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`naturalresource`.`resource_vehicle` ALTER COLUMN `management_fee_rate` SET TAGS ('dbx_confidential' = 'true');
