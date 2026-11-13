-- Schema for Domain: research | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:29

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`research` COMMENT 'Domain for macroeconomic research, market data management, and proprietary investment modeling. Owns macroeconomic indicator libraries, economic scenario definitions, market data feeds (Bloomberg Terminal, FactSet), proprietary macro models, sector and';
ALTER SCHEMA `asset_management`.`research` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `asset_management`.`research` SET TAGS ('dbx_domain' = 'research');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`research`.`macro_indicator` (
    `macro_indicator_id` BIGINT COMMENT 'Unique identifier for the macroeconomic indicator. Primary key for the macro indicator master library.',
    `base_year` BIGINT COMMENT 'Reference year for index-based indicators (e.g., CPI base year 2015=100). Null for non-indexed indicators.',
    `benchmark_threshold_high` DECIMAL(18,6) COMMENT 'Upper bound of the normal or target range for this indicator, used for alert generation and scenario analysis. Null if no threshold is defined.',
    `benchmark_threshold_low` DECIMAL(18,6) COMMENT 'Lower bound of the normal or target range for this indicator, used for alert generation and scenario analysis. Null if no threshold is defined.',
    `calculation_methodology` STRING COMMENT 'Brief description of how the indicator is calculated or derived (e.g., year-over-year percentage change, quarter-over-quarter annualized, weighted average, survey-based index).',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for country-specific indicators (e.g., USA, GBR, CAN, DEU). Null for global or regional indicators.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this indicator record was first created in the system. Used for audit trail and data lineage.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for monetary indicators (e.g., USD, EUR, GBP). Null for non-monetary indicators.. Valid values are `^[A-Z]{3}$`',
    `data_quality_rating` STRING COMMENT 'Internal assessment of the indicators data quality based on source reliability, revision frequency, and historical accuracy: high (trusted for critical decisions), medium (acceptable with caveats), or low (use with caution).. Valid values are `high|medium|low`',
    `data_source` STRING COMMENT 'Primary source system or vendor providing the indicator data (e.g., Bloomberg Terminal, FactSet, OECD, IMF, National Statistics Agency, Central Bank).',
    `macro_indicator_description` STRING COMMENT 'Detailed business description of the indicator, including its economic significance, typical interpretation, and key considerations for investment analysis.',
    `esg_relevance` STRING COMMENT 'Indicates whether the indicator has direct relevance to ESG analysis: environmental (e.g., carbon emissions, renewable energy share), social (e.g., inequality measures), governance (e.g., corruption index), or not applicable.. Valid values are `environmental|social|governance|not_applicable`',
    `forecast_availability` BOOLEAN COMMENT 'Indicates whether consensus forecasts or proprietary forecasts are maintained for this indicator. True if forecasts are tracked, false otherwise.',
    `frequency` STRING COMMENT 'Frequency at which the indicator is published or updated: daily, weekly, monthly, quarterly, or annual.. Valid values are `daily|weekly|monthly|quarterly|annual`',
    `geographic_scope` STRING COMMENT 'Geographic coverage level of the indicator: global aggregate, regional bloc, individual country, state/province, or city-level.. Valid values are `global|regional|country|state_province|city`',
    `historical_start_date` DATE COMMENT 'Earliest date for which historical data is available for this indicator. Used to determine time-series depth for backtesting and stress testing.',
    `indicator_category` STRING COMMENT 'High-level classification of the indicator type: growth metrics, inflation measures, employment statistics, monetary policy rates, credit spreads, commodity prices, sentiment indices, or fiscal indicators.',
    `indicator_code` STRING COMMENT 'Standardized short code uniquely identifying the indicator across systems (e.g., GDP_GROWTH, CPI_YOY, SOFR_3M). Used for system integration and Bloomberg/FactSet mapping.. Valid values are `^[A-Z0-9_]{3,20}$`',
    `indicator_name` STRING COMMENT 'Full business name of the macroeconomic indicator (e.g., Gross Domestic Product Growth Rate, Consumer Price Index Year-over-Year).',
    `indicator_subcategory` STRING COMMENT 'Detailed sub-classification within the category (e.g., GDP, Industrial Production, CPI, PPI, Unemployment Rate, Central Bank Rate, Corporate Spread, Oil Price, PMI).',
    `last_review_date` DATE COMMENT 'Date when the indicator definition, source, or methodology was last reviewed by the steward team. Used for data governance and quality assurance.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this indicator record was last modified. Used for audit trail and change tracking.',
    `leading_lagging_coincident` STRING COMMENT 'Economic timing classification: leading (predicts future economic activity), lagging (confirms trends after they occur), or coincident (moves with current economic conditions).. Valid values are `leading|lagging|coincident`',
    `macro_indicator_status` STRING COMMENT 'Current lifecycle status of the indicator in the research library: active (currently tracked), discontinued (no longer published), suspended (temporarily unavailable), or under review (evaluation for inclusion).. Valid values are `active|discontinued|suspended|under_review`',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review of the indicator. Used to ensure ongoing relevance and data quality.',
    `notes` STRING COMMENT 'Free-text field for additional context, caveats, or special instructions related to the indicator (e.g., known data quality issues, methodology changes, usage restrictions).',
    `proprietary_model_flag` BOOLEAN COMMENT 'Indicates whether this indicator is derived from an internal proprietary model rather than sourced from external vendors. True for proprietary indicators, false for external.',
    `publication_lag_days` BIGINT COMMENT 'Typical number of days between the reference period end and the official publication date. Used for forecasting data availability in investment models.',
    `region_code` STRING COMMENT 'Regional bloc or economic area code for regional indicators (e.g., OECD, EU, G7, ASEAN). Null for country-specific or global indicators.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this indicator is required for regulatory reporting or compliance disclosures (e.g. stress testing, TCFD climate scenario analysis). True if required, false otherwise.',
    `related_asset_classes` STRING COMMENT 'Comma-separated list of asset classes most sensitive to this indicator (e.g., public equities, fixed income, real estate, infrastructure, commodities). Used for cross-asset correlation analysis.',
    `revision_policy` STRING COMMENT 'Indicates whether published values are subject to revision: no revision, preliminary then final, or continuous revision. Critical for risk modeling and data quality.. Valid values are `no_revision|preliminary_final|continuous_revision`',
    `seasonal_adjustment` STRING COMMENT 'Indicates whether the indicator data is seasonally adjusted, not seasonally adjusted, or available in both forms. Critical for time-series modeling.. Valid values are `seasonally_adjusted|not_seasonally_adjusted|both_available`',
    `source_identifier` STRING COMMENT 'Native identifier or ticker symbol used by the source system (e.g., Bloomberg ticker, FactSet mnemonic, OECD series code).',
    `steward_team` STRING COMMENT 'Name of the internal research team or function responsible for maintaining and validating this indicator (e.g., Macro Research, Fixed Income Research, ESG Research).',
    `unit_of_measure` STRING COMMENT 'Unit in which the indicator is expressed (e.g., percent, basis points, index level, currency amount, ratio). Critical for interpretation and modeling.',
    `usage_context` STRING COMMENT 'Description of how the indicator is used within the organization (e.g., SAA input, risk stress testing, IC presentation, portfolio construction, macro overlay strategy).',
    `volatility_classification` STRING COMMENT 'Qualitative assessment of the indicators historical volatility: low (stable, slow-moving), moderate (typical cyclical variation), or high (subject to sharp swings).. Valid values are `low|moderate|high`',
    CONSTRAINT pk_macro_indicator PRIMARY KEY(`macro_indicator_id`)
) COMMENT 'Master library of macroeconomic indicators tracked and maintained by the research team, including GDP growth rates, inflation indices (CPI, PPI), unemployment rates, central bank policy rates, yield curves, PMI, credit spreads, and commodity price';

CREATE OR REPLACE TABLE `asset_management`.`research`.`macro_indicator_observation` (
    `macro_indicator_observation_id` BIGINT COMMENT 'Unique identifier for the macroeconomic indicator observation record.',
    `economic_scenario_id` BIGINT COMMENT 'Reference to an economic scenario or stress-test scenario if this observation is part of a modeled forecast rather than historical actuals.',
    `macro_indicator_id` BIGINT COMMENT 'Reference to the macroeconomic indicator being observed (e.g., GDP, CPI, unemployment rate).',
    `consensus_estimate` DECIMAL(28,10) COMMENT 'The median or mean forecast value from external analysts or economists prior to the actual release.',
    `consensus_estimate_count` BIGINT COMMENT 'Number of individual forecasts or analysts contributing to the consensus estimate.',
    `country_code` STRING COMMENT 'Three-letter ISO country code for the geographic region this observation pertains to.. Valid values are `^[A-Z]{3}$`',
    `created_by_user` STRING COMMENT 'Identifier of the user or system process that created this observation record.',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code if the observation is denominated in a specific currency.. Valid values are `^[A-Z]{3}$`',
    `data_quality_flag` BOOLEAN COMMENT 'Quality assessment flag indicating the reliability and completeness of this observation.',
    `data_source` STRING COMMENT 'Name of the external data provider or system from which this observation was sourced (e.g., Bloomberg, FactSet, OECD, IMF, national statistical agency).',
    `data_source_identifier` STRING COMMENT 'Unique identifier or ticker symbol used by the data source to reference this indicator (e.g., Bloomberg ticker, FactSet mnemonic).',
    `ingestion_timestamp` TIMESTAMP COMMENT 'Timestamp when this observation record was ingested into the lakehouse platform.',
    `is_annualized` BOOLEAN COMMENT 'Indicates whether the observation value has been annualized for comparability across different reporting periods.',
    `is_seasonally_adjusted` BOOLEAN COMMENT 'Indicates whether the observation value has been seasonally adjusted to remove cyclical patterns.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this observation record.',
    `observation_date` DATE COMMENT 'The date on which this macroeconomic indicator value was observed or reported.',
    `observation_notes` STRING COMMENT 'Free-text notes or commentary from the data source or internal research team regarding this observation.',
    `observation_status` STRING COMMENT 'Current lifecycle status of this observation record: active for current use, superseded by a revision, deprecated, or deleted.. Valid values are `active|superseded|deprecated|deleted`',
    `observation_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the observation was recorded or published, including time zone.',
    `observation_type` STRING COMMENT 'Classification of the observation: actual reported value, preliminary estimate, revised figure, forecast, or external consensus estimate.. Valid values are `actual|preliminary|revised|forecast|consensus`',
    `observation_value` DECIMAL(28,10) COMMENT 'The numeric value of the macroeconomic indicator at this observation point.',
    `period_over_period_change` DECIMAL(18,6) COMMENT 'Percentage change in the indicator value compared to the immediately preceding reporting period.',
    `prior_period_value` DECIMAL(28,10) COMMENT 'The value of this indicator from the immediately preceding reporting period, used for period-over-period analysis.',
    `publication_date` DATE COMMENT 'Date on which the observation was officially published or released by the data source.',
    `publication_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the observation was officially published or released, including time zone.',
    `region_code` STRING COMMENT 'Code representing a broader geographic region (e.g., EUR for Eurozone, APAC for Asia-Pacific) when applicable.',
    `reporting_frequency` STRING COMMENT 'Frequency at which this indicator is reported: daily, weekly, monthly, quarterly, or annual.. Valid values are `daily|weekly|monthly|quarterly|annual`',
    `reporting_period_end_date` DATE COMMENT 'End date of the period this observation covers (e.g., Q1 2024 ends 2024-03-31).',
    `reporting_period_start_date` DATE COMMENT 'Start date of the period this observation covers (e.g., Q1 2024 starts 2024-01-01).',
    `revision_number` BIGINT COMMENT 'Sequential revision number for this observation; 0 for initial release, incremented for each subsequent revision.',
    `surprise_percentage` DECIMAL(18,6) COMMENT 'Percentage difference between the actual observation value and the consensus estimate.',
    `surprise_value` DECIMAL(28,10) COMMENT 'Difference between the actual observation value and the consensus estimate, indicating market surprise.',
    `unit_of_measure` STRING COMMENT 'Unit in which the observation value is expressed (e.g., percent, basis points, index level, millions USD, billions EUR).',
    `updated_by_user` STRING COMMENT 'Identifier of the user or system process that last updated this observation record.',
    `year_over_year_change` DECIMAL(18,6) COMMENT 'Percentage change in the indicator value compared to the same period in the prior year.',
    CONSTRAINT pk_macro_indicator_observation PRIMARY KEY(`macro_indicator_observation_id`)
) COMMENT 'Transactional time-series records of macroeconomic indicator values, covering both observed/reported actuals and external consensus estimates, keyed to a macro_indicator at a point in time (daily, monthly, quarterly, annual).';

CREATE OR REPLACE TABLE `asset_management`.`research`.`economic_scenario` (
    `economic_scenario_id` BIGINT COMMENT 'Unique identifier for the economic scenario record.',
    `climate_scenario_id` BIGINT COMMENT 'Foreign key linking to esg.climate_scenario. Business justification: TCFD-aligned scenario analysis requires economic scenarios to reference specific climate pathways (IEA NZE, NGFS).',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Regulatory stress testing (Basel III, Solvency II) requires tracking which authority mandated each scenario.',
    `approval_date` DATE COMMENT 'Date on which the scenario was formally approved by the Investment Committee or research governance body.',
    `climate_scenario_alignment` STRING COMMENT 'Reference to the climate scenario framework this economic scenario aligns with, such as TCFD or NGFS pathways.',
    `commodity_price_assumption` DECIMAL(10,2) COMMENT 'Assumed representative commodity price level for the scenario period, typically in USD per unit.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the scenario record was first created in the system.',
    `credit_spread_assumption_bps` BIGINT COMMENT 'Assumed credit spread over risk-free rate expressed in basis points for the scenario period.',
    `economic_scenario_description` STRING COMMENT 'Detailed narrative describing the macroeconomic assumptions, conditions, and rationale underlying the scenario.',
    `documentation_url` STRING COMMENT 'URL or file path to the detailed documentation, methodology paper, or research report supporting the scenario.',
    `effective_date` DATE COMMENT 'Date from which the scenario is effective and available for use in portfolio analysis and stress testing.',
    `equity_return_assumption` DECIMAL(7,4) COMMENT 'Assumed annual equity market return expressed as a decimal for the scenario period.',
    `expiry_date` DATE COMMENT 'Date on which the scenario is no longer valid or recommended for use, typically due to updated assumptions or market conditions.',
    `external_reference_code` STRING COMMENT 'Identifier linking this scenario to an external scenario library or third-party research provider such as MSCI or FactSet.',
    `fx_volatility_assumption` DECIMAL(6,4) COMMENT 'Assumed foreign exchange market volatility expressed as a decimal for the scenario period.',
    `gdp_growth_rate_assumption` DECIMAL(6,4) COMMENT 'Assumed annual GDP growth rate expressed as a decimal for the scenario period.',
    `geopolitical_risk_level` STRING COMMENT 'Qualitative assessment of geopolitical risk embedded in the scenario assumptions.. Valid values are `low|moderate|high|extreme`',
    `ghg_emissions_trajectory` STRING COMMENT 'Narrative description of the assumed greenhouse gas emissions path under this scenario.',
    `inflation_rate_assumption` DECIMAL(6,4) COMMENT 'Assumed annual inflation rate expressed as a decimal for the scenario period.',
    `infrastructure_return_assumption` DECIMAL(7,4) COMMENT 'Assumed annual infrastructure asset class return expressed as a decimal for the scenario period.',
    `interest_rate_assumption` DECIMAL(6,4) COMMENT 'Assumed benchmark interest rate level expressed as a decimal for the scenario period.',
    `is_baseline` BOOLEAN COMMENT 'Boolean flag indicating whether this scenario represents the baseline or central case for planning and forecasting.',
    `is_regulatory_required` BOOLEAN COMMENT 'Boolean flag indicating whether this scenario is mandated by regulatory authorities for stress testing or disclosure purposes.',
    `last_review_date` DATE COMMENT 'Date of the most recent review or validation of the scenario assumptions and parameters.',
    `model_version` STRING COMMENT 'Version identifier of the source model used to ensure traceability and reproducibility.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the scenario record was last modified or updated.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review or recalibration of the scenario.',
    `notes` STRING COMMENT 'Free-text field for additional comments, caveats, or contextual information relevant to the scenario.',
    `private_equity_return_assumption` DECIMAL(7,4) COMMENT 'Assumed annual private equity asset class return expressed as a decimal for the scenario period.',
    `probability_weight` DECIMAL(5,4) COMMENT 'Subjective probability or weighting assigned to the scenario for use in expected value calculations and portfolio construction.',
    `real_estate_return_assumption` DECIMAL(7,4) COMMENT 'Assumed annual real estate asset class return expressed as a decimal for the scenario period.',
    `regulatory_environment` STRING COMMENT 'Description of the assumed regulatory and policy environment under this scenario.',
    `scenario_category` STRING COMMENT 'Thematic classification grouping scenarios by their primary focus area or driver.. Valid values are `macro|market|geopolitical|climate|regulatory|sector_specific`',
    `scenario_code` STRING COMMENT 'Short alphanumeric code uniquely identifying the scenario for system integration and cross-referencing.',
    `scenario_name` STRING COMMENT 'Human-readable name of the macroeconomic scenario used for identification and reporting purposes.',
    `scenario_owner` STRING COMMENT 'Name or identifier of the research team member or group responsible for maintaining the scenario.',
    `scenario_status` STRING COMMENT 'Current lifecycle status of the scenario indicating its availability for use in analysis and reporting.. Valid values are `draft|active|archived|deprecated|under_review|approved`',
    `scenario_type` STRING COMMENT 'Classification of the scenario indicating its purpose and nature within the modeling framework.. Valid values are `baseline|stress|optimistic|pessimistic|historical|custom`',
    `source_model` STRING COMMENT 'Name or identifier of the proprietary or third-party macroeconomic model used to generate the scenario.',
    `time_horizon_years` BIGINT COMMENT 'Number of years into the future that the scenario projects, defining the temporal scope of the analysis.',
    `unemployment_rate_assumption` DECIMAL(5,4) COMMENT 'Assumed unemployment rate expressed as a decimal for the scenario period.',
    `usage_count` BIGINT COMMENT 'Number of times the scenario has been used in portfolio stress tests, ALM analyses, or IC presentations.',
    CONSTRAINT pk_economic_scenario PRIMARY KEY(`economic_scenario_id`)
) COMMENT 'Master record of named macroeconomic scenarios defined and maintained by the research team for use in portfolio stress testing, ALM modeling, and IC presentations.';

CREATE OR REPLACE TABLE `asset_management`.`research`.`scenario_assumption` (
    `scenario_assumption_id` BIGINT COMMENT 'Unique identifier for the scenario assumption record.',
    `economic_scenario_id` BIGINT COMMENT 'Reference to the parent economic scenario to which this assumption belongs.',
    `macro_indicator_id` BIGINT COMMENT 'Reference to the macroeconomic indicator being projected or shocked in this assumption.',
    `approval_date` DATE COMMENT 'Date on which this assumption was formally approved for use in portfolio construction, risk modeling, or IC presentations.',
    `approval_status` STRING COMMENT 'Current approval state of the assumption within the Investment Committee (IC) or research governance process.. Valid values are `draft|under_review|approved|rejected|superseded`',
    `approved_by` STRING COMMENT 'Name or identifier of the Investment Committee member, Chief Economist, or research lead who approved this assumption.',
    `asset_class_scope` STRING COMMENT 'Asset class to which this assumption is relevant, enabling asset-class-specific scenario modeling. [ENUM-REF-CANDIDATE: public_equity|private_equity|real_estate|infrastructure|natural_resources|credit|multi_asset — 7 candidates stripped; promote to',
    `assumption_name` STRING COMMENT 'Human-readable name or label for this specific assumption within the scenario.',
    `assumption_notes` STRING COMMENT 'Additional free-text notes, caveats, or qualifications related to this assumption, capturing nuances not covered by structured fields.',
    `assumption_rationale` STRING COMMENT 'Textual explanation of the economic reasoning, market conditions, or research insights that justify this assumption.',
    `assumption_type` STRING COMMENT 'Classification of the assumption indicating whether it represents a baseline projection, shock event, stress condition, recovery path, optimistic case, or pessimistic case.. Valid values are `baseline|shock|stress|recovery|optimistic|pessimistic`',
    `benchmark_comparison` DECIMAL(20,6) COMMENT 'Benchmark or consensus value for the same indicator and horizon, enabling comparison of the assumption against market consensus or historical averages.',
    `confidence_level` DECIMAL(5,2) COMMENT 'Statistical confidence level associated with the projected value, expressed as a percentage (e.g., 95.00 for 95% confidence).',
    `correlation_group` STRING COMMENT 'Identifier for a group of correlated assumptions, enabling joint scenario modeling where multiple indicators move together.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this assumption record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code if the assumption value is denominated in a specific currency, nullable for non-monetary indicators.. Valid values are `^[A-Z]{3}$`',
    `data_source` STRING COMMENT 'External data provider or internal research team that supplied the underlying data for this assumption, such as Bloomberg, FactSet, MSCI, or internal macro research.',
    `effective_date` DATE COMMENT 'Date from which this assumption becomes applicable within the scenario.',
    `expiry_date` DATE COMMENT 'Date on which this assumption ceases to apply, nullable for open-ended assumptions.',
    `geographic_scope` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code or region code indicating the geographic area to which this assumption applies.. Valid values are `^[A-Z]{3}$`',
    `model_version` STRING COMMENT 'Version identifier of the source model used to derive this assumption, enabling model lineage and reproducibility.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal review of this assumption.',
    `probability_weight` DECIMAL(5,4) COMMENT 'Probability weight assigned to this assumption within the scenario, used for weighted scenario analysis and expected value calculations.',
    `projected_value` DECIMAL(20,6) COMMENT 'The numeric value or level projected for the indicator under this assumption, expressed in the indicators native unit.',
    `projection_horizon` STRING COMMENT 'Time horizon over which this assumption applies: short-term (0-2 years), medium-term (3-5 years), long-term (5+ years), or perpetual.. Valid values are `short_term|medium_term|long_term|perpetual`',
    `review_frequency` STRING COMMENT 'Scheduled frequency at which this assumption is reviewed and potentially updated by the research team.. Valid values are `monthly|quarterly|semi_annual|annual|ad_hoc`',
    `sector_scope` STRING COMMENT 'Economic sector or industry segment to which this assumption is scoped, such as financials, energy, technology, or real estate.',
    `sensitivity_flag` BOOLEAN COMMENT 'Boolean indicator of whether this assumption is subject to sensitivity analysis or stress testing in portfolio construction and risk management.',
    `shock_direction` STRING COMMENT 'Direction of the shock applied: upward (positive), downward (negative), or neutral (no directional bias).. Valid values are `upward|downward|neutral`',
    `shock_magnitude` DECIMAL(20,6) COMMENT 'The size of the shock or deviation applied to the baseline indicator value, expressed as an absolute change or percentage point shift.',
    `source_model` STRING COMMENT 'Name or identifier of the proprietary macroeconomic model, external vendor model, or research framework that generated this assumption.',
    `unit_of_measure` STRING COMMENT 'The unit in which the projected value and shock magnitude are expressed, such as percentage, basis points (bps), currency, index points, or growth rate.',
    `updated_by` STRING COMMENT 'Identifier of the research analyst or system user who last updated this assumption record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this assumption record was last modified.',
    `usage_context` STRING COMMENT 'Description of the analytical or operational context in which this assumption is used, such as Strategic Asset Allocation (SAA), Tactical Asset Allocation (TAA), Value at Risk (VaR) modeling, or Liability-Driven Investment (LDI) analysis.',
    `variance_from_baseline` DECIMAL(20,6) COMMENT 'Calculated difference between the projected value and the baseline scenario value, expressed in the same unit of measure.',
    `created_by` STRING COMMENT 'Identifier of the research analyst or system user who created this assumption record.',
    CONSTRAINT pk_scenario_assumption PRIMARY KEY(`scenario_assumption_id`)
) COMMENT 'Detailed assumption records associated with each economic scenario, specifying the projected values or shocks applied to individual macroeconomic indicators within that scenario.';

CREATE OR REPLACE TABLE `asset_management`.`research`.`market_data_feed` (
    `market_data_feed_id` BIGINT COMMENT 'Unique identifier for the market data feed subscription record.',
    `data_vendor_id` BIGINT COMMENT 'Foreign key linking to research.data_vendor. Business justification: Market data feeds are subscriptions to external vendors; linking to data_vendor provides authoritative vendor data and removes redundant vendor_name and vendor_contract_reference columns.',
    `annual_subscription_cost` DECIMAL(18,2) COMMENT 'Annual cost of the feed subscription in the base currency (typically USD), excluding usage-based fees.',
    `asset_class_coverage` STRING COMMENT 'Comma-separated list of asset classes covered by this feed (e.g., Public Equities, Fixed Income, Private Equity, Real Estate, Infrastructure, Natural Resources, Credit, Derivatives, FX).',
    `backup_feed_available_flag` BOOLEAN COMMENT 'Indicates whether an alternative or backup feed is available for business continuity in case of primary feed failure (True/False).',
    `business_owner_name` STRING COMMENT 'Name of the business owner or department head accountable for the feed subscription and its business value.',
    `consuming_systems` STRING COMMENT 'Comma-separated list of internal systems that consume data from this feed (e.g., SimCorp Dimension, BlackRock Aladdin, MSCI RiskMetrics, Internal Data Lake).',
    `contract_renewal_date` DATE COMMENT 'Date when the vendor contract for this feed is due for renewal or renegotiation.',
    `cost_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the subscription cost (e.g., USD, GBP).. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this market data feed record was first created in the system.',
    `data_classification_level` STRING COMMENT 'Highest data classification level of the content delivered by this feed, per organizational data classification policy.. Valid values are `public|internal|confidential|restricted`',
    `data_content_type` STRING COMMENT 'Description of the data content provided by the feed (e.g., pricing, fundamentals, ESG ratings, macroeconomic indicators, risk analytics, performance attribution, fund manager data).',
    `data_quality_sla_percentage` DECIMAL(5,2) COMMENT 'Contractual data quality service level agreement percentage guaranteed by the vendor (e.g., 99.5% accuracy).',
    `data_retention_period_days` BIGINT COMMENT 'Number of days for which historical data from this feed is retained in the organizations data lake, per data governance policy.',
    `data_steward_name` STRING COMMENT 'Name of the individual or team responsible for managing and governing this feed subscription within the research domain.',
    `delivery_frequency` STRING COMMENT 'Frequency at which the feed data is updated or delivered (e.g., Real-Time, Daily, Weekly, Monthly, On-Demand). [ENUM-REF-CANDIDATE: Real-Time|Intraday|Daily|Weekly|Monthly|On-Demand|Continuous Streaming — 7 candidates stripped; promote to reference',
    `delivery_method` STRING COMMENT 'Technical method by which the feed data is delivered to the organization (e.g., API, FTP, SFTP, Direct Terminal Access, Streaming). [ENUM-REF-CANDIDATE: API|FTP|SFTP|Direct Terminal Access|Managed File Transfer|Web Portal|Streaming|Batch File — 8',
    `feed_code` STRING COMMENT 'Unique alphanumeric code identifying the feed subscription for operational reference and billing reconciliation.',
    `feed_criticality` STRING COMMENT 'Business criticality rating of the feed based on its impact on investment operations, risk management, and regulatory reporting.. Valid values are `Critical|High|Medium|Low`',
    `feed_documentation_url` STRING COMMENT 'URL or file path to the vendor-provided technical documentation, data dictionary, or API specification for this feed.',
    `feed_health_status` STRING COMMENT 'Current operational health status of the feed based on monitoring and data quality checks.. Valid values are `Healthy|Degraded|Failed|Under Maintenance|Not Monitored`',
    `feed_name` STRING COMMENT 'Business name of the market data feed subscription (e.g., Bloomberg Terminal Equity Real-Time, FactSet Fixed Income Analytics).',
    `feed_status` STRING COMMENT 'Current operational status of the market data feed subscription.. Valid values are `Active|Inactive|Suspended|Pending Activation|Under Review|Terminated`',
    `feed_type` STRING COMMENT 'Classification of the feed based on data delivery frequency and purpose (e.g., Real-Time, End-of-Day, Historical, Reference Data, Analytics). [ENUM-REF-CANDIDATE: Real-Time|Delayed|End-of-Day|Intraday|Historical|Reference Data|Analytics|Composite — 8',
    `geographic_coverage` STRING COMMENT 'Geographic regions or markets covered by the feed (e.g., Global, North America, Europe, Asia-Pacific, Emerging Markets).',
    `last_data_refresh_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent successful data refresh or delivery from this feed to internal systems.',
    `last_health_check_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent automated health check or monitoring validation for this feed.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this market data feed record was last updated or modified.',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, special configurations, or historical context related to this feed subscription.',
    `primary_use_case` STRING COMMENT 'Primary business use case or application for this feed (e.g., Portfolio Valuation, Risk Analytics, Performance Attribution, Investment Research, ESG Integration, Compliance Reporting).',
    `regulatory_compliance_scope` STRING COMMENT 'Comma-separated list of regulatory frameworks or reporting requirements that this feed supports (e.g., GIPS, SFDR, TCFD, MiFID II).',
    `subscription_end_date` DATE COMMENT 'Date when the feed subscription is scheduled to end or was terminated (nullable for open-ended subscriptions).',
    `subscription_start_date` DATE COMMENT 'Date when the feed subscription became active and data delivery commenced.',
    `uptime_sla_percentage` DECIMAL(5,2) COMMENT 'Contractual uptime service level agreement percentage guaranteed by the vendor (e.g., 99.9% availability).',
    `usage_based_pricing_flag` BOOLEAN COMMENT 'Indicates whether the feed has usage-based pricing components in addition to the base subscription cost (True/False).',
    `user_license_count` BIGINT COMMENT 'Number of named user licenses or concurrent access licenses included in the subscription.',
    `vendor_support_contact` STRING COMMENT 'Primary vendor support contact email or phone number for technical and operational issues related to this feed.',
    CONSTRAINT pk_market_data_feed PRIMARY KEY(`market_data_feed_id`)
) COMMENT 'Master catalogue of market data feed subscriptions and configurations managed by the research domain, covering Bloomberg Terminal, FactSet, Preqin, PitchBook, and MSCI data services.';

CREATE OR REPLACE TABLE `asset_management`.`research`.`market_data_snapshot` (
    `market_data_snapshot_id` BIGINT COMMENT 'Unique identifier for the market data snapshot record.',
    `data_source_data_vendor_id` BIGINT COMMENT 'Reference to the external market data provider or feed system that supplied this snapshot.',
    `data_vendor_id` BIGINT COMMENT 'Reference to the external market data provider or feed system that supplied this snapshot.',
    `listed_security_id` BIGINT COMMENT 'Reference to the security, index, instrument, or currency pair for which market data is captured.',
    `accrued_interest` DECIMAL(18,6) COMMENT 'The interest accumulated on a bond since the last coupon payment date.',
    `ask_price` DECIMAL(24,8) COMMENT 'The lowest price a seller is willing to accept for the instrument at snapshot time.',
    `beta` DECIMAL(12,6) COMMENT 'The measure of the security volatility relative to the overall market.',
    `bid_price` DECIMAL(24,8) COMMENT 'The highest price a buyer is willing to pay for the instrument at snapshot time.',
    `bloomberg_ticker` STRING COMMENT 'Bloomberg-specific ticker symbol for the instrument.',
    `close_price` DECIMAL(24,8) COMMENT 'The closing price of the instrument at the end of the trading session.',
    `convexity` DECIMAL(12,6) COMMENT 'The measure of the curvature in the relationship between bond prices and yields.',
    `credit_spread` DECIMAL(12,6) COMMENT 'The difference in yield between a corporate bond and a comparable government bond, measured in basis points.',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code in which the price is denominated.. Valid values are `^[A-Z]{3}$`',
    `cusip` STRING COMMENT 'CUSIP identifier for North American securities.. Valid values are `^[0-9]{3}[0-9A-Z]{5}[0-9]$`',
    `data_quality_flag` BOOLEAN COMMENT 'Indicator of the quality and reliability of the market data snapshot.',
    `dividend_yield` DECIMAL(12,6) COMMENT 'The annual dividend per share divided by the price per share, expressed as a percentage.',
    `duration` DECIMAL(12,6) COMMENT 'The weighted average time to receive the bond cash flows, measuring interest rate sensitivity.',
    `dv01` DECIMAL(18,6) COMMENT 'The dollar change in value for a one basis point change in yield.',
    `exchange_code` STRING COMMENT 'The Market Identifier Code for the exchange or trading venue where the price was observed.. Valid values are `^[A-Z]{3,4}$`',
    `fx_rate` DECIMAL(18,8) COMMENT 'The exchange rate for currency pairs at the snapshot timestamp.',
    `high_price` DECIMAL(24,8) COMMENT 'The highest price reached by the instrument during the trading session.',
    `implied_volatility` DECIMAL(12,6) COMMENT 'The market forecast of a likely movement in the security price, derived from option prices.',
    `ingestion_timestamp` TIMESTAMP COMMENT 'The timestamp when this market data snapshot was ingested into the lakehouse platform.',
    `is_end_of_day` BOOLEAN COMMENT 'Flag indicating whether this snapshot represents end-of-day market data.',
    `isin` STRING COMMENT 'International Securities Identification Number uniquely identifying the financial instrument globally.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this market data snapshot record was last modified.',
    `low_price` DECIMAL(24,8) COMMENT 'The lowest price reached by the instrument during the trading session.',
    `market_cap` DECIMAL(24,2) COMMENT 'The total market value of the company outstanding shares.',
    `mid_price` DECIMAL(24,8) COMMENT 'The midpoint between bid and ask prices, calculated as the average of bid and ask.',
    `oas` DECIMAL(12,6) COMMENT 'The spread over the risk-free rate adjusted for embedded options in the security.',
    `open_price` DECIMAL(24,8) COMMENT 'The opening price of the instrument for the trading session.',
    `pe_ratio` DECIMAL(12,4) COMMENT 'The ratio of the market price per share to earnings per share.',
    `previous_close_price` DECIMAL(24,8) COMMENT 'The closing price from the prior trading session, used for change calculations.',
    `price` DECIMAL(24,8) COMMENT 'The market price value for the instrument at the snapshot timestamp.',
    `price_type` STRING COMMENT 'The type of price captured in this snapshot. [ENUM-REF-CANDIDATE: last|bid|ask|mid|open|high|low|close|settlement|nav — 10 candidates stripped; promote to reference product]',
    `quote_condition` STRING COMMENT 'Code indicating special conditions or qualifiers associated with the quoted price.',
    `ric` STRING COMMENT 'Reuters Instrument Code used by Refinitiv for instrument identification.',
    `sedol` STRING COMMENT 'SEDOL code used primarily for securities traded on the London Stock Exchange.. Valid values are `^[0-9A-Z]{7}$`',
    `snapshot_date` DATE COMMENT 'The business date for which this market data snapshot is effective.',
    `snapshot_timestamp` TIMESTAMP COMMENT 'The exact date and time when this market data snapshot was captured from the external feed.',
    `source_system_timestamp` TIMESTAMP COMMENT 'The original timestamp from the source market data feed system before ingestion.',
    `trade_condition` STRING COMMENT 'Code indicating special conditions or qualifiers associated with the trade execution.',
    `turnover` DECIMAL(24,2) COMMENT 'The total monetary value of trades executed for the instrument during the session.',
    `volume` DECIMAL(20,4) COMMENT 'The total quantity of the instrument traded during the session or at snapshot time.',
    `ytm` DECIMAL(12,6) COMMENT 'The total return anticipated on a bond if held until maturity, expressed as an annual percentage rate.',
    CONSTRAINT pk_market_data_snapshot PRIMARY KEY(`market_data_snapshot_id`)
) COMMENT 'Transactional silver-layer store of normalized inbound market data values captured from external feeds at a point in time for a given security, index, instrument, or currency pair.';

CREATE OR REPLACE TABLE `asset_management`.`research`.`macro_model` (
    `macro_model_id` BIGINT COMMENT 'Unique identifier for the proprietary macroeconomic model record.',
    `accuracy_metric` STRING COMMENT 'Statistical measure used to assess model accuracy, such as Mean Absolute Error (MAE), Root Mean Squared Error (RMSE), R-squared, or hit rate.',
    `accuracy_value` DECIMAL(18,6) COMMENT 'Numerical value of the accuracy metric from the most recent validation or backtesting exercise.',
    `approval_date` DATE COMMENT 'Date when the model was formally approved for use by the Investment Committee (IC), risk committee, or regulatory authority.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee that approved the model for operational use.',
    `asset_class_applicability` STRING COMMENT 'Comma-separated list or description of asset classes to which this model applies, such as public equities, private equity, real estate, infrastructure, natural resources, credit, or fixed income.',
    `backtesting_period_end` DATE COMMENT 'End date of the historical period used for backtesting the models predictive accuracy and performance.',
    `backtesting_period_start` DATE COMMENT 'Start date of the historical period used for backtesting the models predictive accuracy and performance.',
    `calibration_date` DATE COMMENT 'Date when the model was last calibrated or recalibrated using historical data or updated parameters.',
    `climate_scenario_compatible` BOOLEAN COMMENT 'Indicates whether the model is compatible with climate scenario analysis frameworks such as Task Force on Climate-related Financial Disclosures (TCFD) or Network for Greening the Financial System (NGFS).',
    `computational_runtime_minutes` DECIMAL(10,2) COMMENT 'Average time in minutes required to execute a full model run, used for capacity planning and scheduling.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the model record was first created in the system.',
    `data_source_description` STRING COMMENT 'Description of primary data sources feeding the model, such as Bloomberg Terminal, FactSet, MSCI, central bank publications, or proprietary internal data.',
    `deprecated_date` DATE COMMENT 'Date when the model was deprecated and removed from active use, if applicable.',
    `deprecation_reason` STRING COMMENT 'Explanation for why the model was deprecated, such as superseded by a new model, poor predictive performance, or changes in investment strategy.',
    `documentation_url` STRING COMMENT 'Hyperlink or file path to the detailed model documentation, methodology papers, or technical specifications.',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether the model incorporates Environmental, Social, and Governance (ESG) factors or climate risk scenarios in its analysis.',
    `frequency` STRING COMMENT 'Frequency at which the model is run or updated, such as daily, weekly, monthly, quarterly, annual, or ad hoc.. Valid values are `daily|weekly|monthly|quarterly|annual|ad_hoc`',
    `geographic_scope` STRING COMMENT 'Geographic regions or countries covered by the model, such as global, North America, Europe, Asia-Pacific, or specific country codes.',
    `integration_system` STRING COMMENT 'Name of the operational system or platform where the model outputs are integrated, such as BlackRock Aladdin, SimCorp Dimension, MSCI RiskMetrics, or FactSet.',
    `key_assumptions` STRING COMMENT 'Summary of critical assumptions underpinning the model, such as interest rate paths, inflation expectations, GDP growth rates, or market volatility assumptions.',
    `methodology_description` STRING COMMENT 'Detailed narrative describing the modeling approach, assumptions, data inputs, calibration techniques, and theoretical foundation of the macroeconomic model.',
    `model_code` STRING COMMENT 'Short alphanumeric code or identifier used internally to reference the model in systems and documentation.',
    `model_complexity_score` BIGINT COMMENT 'Numerical score representing the complexity of the model based on number of variables, computational intensity, and calibration difficulty, typically on a scale of 1 to 10.',
    `model_name` STRING COMMENT 'Business name of the proprietary macroeconomic model used for identification and reference in research reports and Investment Committee (IC) presentations.',
    `model_owner` STRING COMMENT 'Name or identifier of the research team member or department responsible for developing, maintaining, and validating the model.',
    `model_status` STRING COMMENT 'Current lifecycle status of the model indicating whether it is actively used, deprecated, under review, archived, or in development.. Valid values are `active|deprecated|under_review|archived|development`',
    `model_type` STRING COMMENT 'Classification of the macroeconomic model methodology, such as Discounted Cash Flow (DCF), factor model, yield curve model, regression, Monte Carlo simulation, or scenario analysis.. Valid values are `DCF|factor_model|yield_curve_model|regression|monte_carlo|scenario_analysis`',
    `model_version` STRING COMMENT 'Version identifier of the model reflecting updates, recalibrations, or methodology changes over time.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the model record was last modified or updated.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review, recalibration, or validation of the model.',
    `notes` STRING COMMENT 'Additional free-text notes or comments about the model, including usage guidance, known limitations, or special considerations.',
    `output_format` STRING COMMENT 'Description of the models output format, such as forecasted time series, probability distributions, scenario matrices, or risk metrics.',
    `primary_use_case` STRING COMMENT 'Primary business application of the model, such as portfolio construction, risk stress testing, Strategic Asset Allocation (SAA), Tactical Asset Allocation (TAA), or Investment Committee (IC) scenario analysis.',
    `regulatory_approval_required` BOOLEAN COMMENT 'Indicates whether the model requires regulatory approval or oversight from bodies such as SEC, or FCA before use in investment decisions.',
    `risk_classification` STRING COMMENT 'Risk rating assigned to the model based on its complexity, sensitivity to assumptions, and potential impact on investment decisions.. Valid values are `low|medium|high|critical`',
    `stress_testing_enabled` BOOLEAN COMMENT 'Indicates whether the model supports macroeconomic stress testing and scenario analysis for risk management purposes.',
    `time_horizon` STRING COMMENT 'Forecasting or analysis time horizon for the model, such as short-term (less than 1 year), medium-term (1-5 years), long-term (5+ years), or custom.. Valid values are `short_term|medium_term|long_term|custom`',
    `validation_date` DATE COMMENT 'Date when the model was last validated for accuracy, robustness, and alignment with observed market outcomes.',
    `validation_status` STRING COMMENT 'Outcome of the most recent model validation process indicating whether the model passed, failed, is pending validation, or validation is not required.. Valid values are `passed|failed|pending|not_required`',
    CONSTRAINT pk_macro_model PRIMARY KEY(`macro_model_id`)
) COMMENT 'Master record of proprietary macroeconomic models developed and maintained by the research team. Captures model name, model type (DCF, factor model, yield curve model, regression, Monte Carlo), asset class applicability, model version, methodology';

CREATE OR REPLACE TABLE `asset_management`.`research`.`macro_model_run` (
    `macro_model_run_id` BIGINT COMMENT 'Unique identifier for each execution of a proprietary macroeconomic model.',
    `analyst_assignment_id` BIGINT COMMENT 'Reference to the research analyst or team member who initiated or is responsible for this model run.',
    `economic_scenario_id` BIGINT COMMENT 'Reference to the economic scenario definition used as input for this model run.',
    `employee_id` BIGINT COMMENT 'Reference to the research analyst or team member who initiated or is responsible for this model run.',
    `macro_model_id` BIGINT COMMENT 'Reference to the proprietary macroeconomic model that was executed in this run.',
    `base_date` DATE COMMENT 'Reference date from which the model projections begin, typically the valuation date or current portfolio date.',
    `completion_timestamp` TIMESTAMP COMMENT 'Date and time when the model execution finished, whether successfully or with failure.',
    `confidence_level` DECIMAL(5,4) COMMENT 'Statistical confidence level used for risk metrics such as VaR and CVaR, expressed as a decimal proportion.',
    `convergence_achieved` BOOLEAN COMMENT 'Indicator of whether the model reached numerical convergence during execution, critical for result validity.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this model run record was first created in the system.',
    `cvar_estimate` DECIMAL(20,2) COMMENT 'Model output representing the estimated Conditional Value at Risk, measuring expected loss beyond the VaR threshold.',
    `error_message` STRING COMMENT 'Detailed error message captured if the model run failed, used for troubleshooting and audit trail.',
    `execution_duration_seconds` BIGINT COMMENT 'Total time in seconds required to complete the model run, used for performance monitoring and optimization.',
    `fair_value_currency` STRING COMMENT 'Three-letter ISO currency code in which the fair value estimate is denominated.',
    `fair_value_estimate` DECIMAL(20,2) COMMENT 'Model-derived fair value estimate for the asset or portfolio under analysis, expressed in the base currency.',
    `fx_currency_pair` STRING COMMENT 'Currency pair for which the FX rate projection applies, expressed in standard format such as USD/JPY.',
    `ic_presentation_flag` BOOLEAN COMMENT 'Indicator of whether this model run output was used in an Investment Committee presentation or decision memo.',
    `implied_equity_risk_premium` DECIMAL(10,6) COMMENT 'Model-derived equity risk premium, representing the expected excess return of equities over the risk-free rate.',
    `input_parameter_count` BIGINT COMMENT 'Number of input parameters supplied to the model for this run, providing metadata on model complexity.',
    `iteration_count` BIGINT COMMENT 'Number of computational iterations performed before the model reached convergence or termination.',
    `model_version` STRING COMMENT 'Version identifier of the macroeconomic model used in this run, enabling reproducibility and change tracking.',
    `output_metric_count` BIGINT COMMENT 'Number of distinct output metrics generated by the model run, indicating the breadth of results produced.',
    `projected_credit_spread_bps` BIGINT COMMENT 'Model output representing the forecasted credit spread over risk-free rates, expressed in basis points.',
    `projected_fx_rate` DECIMAL(18,6) COMMENT 'Model output representing the forecasted foreign exchange rate for the primary currency pair relevant to this run.',
    `projected_gdp_growth_rate` DECIMAL(10,6) COMMENT 'Model output representing the forecasted GDP growth rate, expressed as a decimal proportion.',
    `projected_inflation_rate` DECIMAL(10,6) COMMENT 'Model output representing the forecasted inflation rate, critical for liability-driven investment and actuarial liability matching.',
    `projected_risk_free_rate` DECIMAL(10,6) COMMENT 'Model output representing the forecasted risk-free interest rate, used in discounted cash flow and WACC calculations.',
    `projected_wacc` DECIMAL(10,6) COMMENT 'Model output representing the forecasted weighted average cost of capital, used for valuation and investment decision-making.',
    `projection_horizon_years` BIGINT COMMENT 'Number of years into the future that this model run projects, reflecting the long-duration liability matching requirements.',
    `run_identifier` STRING COMMENT 'Business-friendly identifier or label for this model run, used for tracking and reporting purposes.',
    `run_purpose` STRING COMMENT 'Business purpose or context for this model execution, such as quarterly review, ad-hoc analysis, or regulatory reporting.',
    `run_status` STRING COMMENT 'Current lifecycle status of the model execution.. Valid values are `pending|running|completed|failed|cancelled|validating`',
    `run_timestamp` TIMESTAMP COMMENT 'Date and time when the model execution was initiated.',
    `run_type` STRING COMMENT 'Classification of the model run purpose, distinguishing between baseline forecasts, stress tests, and sensitivity analyses.. Valid values are `baseline|stress_test|sensitivity|scenario_analysis|forecast|backtest`',
    `stress_test_severity` STRING COMMENT 'Classification of the stress test intensity applied in this model run, used for macroeconomic stress testing.. Valid values are `mild|moderate|severe|extreme`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this model run record was last modified, supporting audit trail and change tracking.',
    `validation_notes` STRING COMMENT 'Free-text notes documenting validation findings, exceptions, or issues identified during quality review.',
    `validation_status` STRING COMMENT 'Status of post-run validation checks, ensuring model outputs meet quality and reasonableness thresholds.. Valid values are `not_validated|passed|failed|pending_review`',
    `var_estimate` DECIMAL(20,2) COMMENT 'Model output representing the estimated Value at Risk, quantifying potential portfolio loss under the scenario.',
    CONSTRAINT pk_macro_model_run PRIMARY KEY(`macro_model_run_id`)
) COMMENT 'Transactional record of each execution of a proprietary macro model, capturing the run date, input scenario reference, model version used, key output values (e.g., projected GDP, implied equity risk premium, fair value estimate, WACC), run status, and';

CREATE OR REPLACE TABLE `asset_management`.`research`.`research_report` (
    `research_report_id` BIGINT COMMENT 'Unique identifier for the research report record.',
    `framework_id` BIGINT COMMENT 'Foreign key linking to esg.framework. Business justification: Research reports analyzing ESG regulatory impacts or framework compliance need to reference the specific framework (SFDR, TCFD, EU Taxonomy).',
    `related_deal_opportunity_id` BIGINT COMMENT 'Foreign key reference to a specific deal or investment opportunity in the pipeline that this report supports or evaluates.',
    `related_opportunity_id` BIGINT COMMENT 'Foreign key reference to a specific deal or investment opportunity in the pipeline that this report supports or evaluates.',
    `superseded_by_report_research_report_id` BIGINT COMMENT 'Reference to a newer report that supersedes or replaces this report, supporting version control and ensuring users access the most current analysis.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the report received final approval from research leadership or compliance, authorizing publication and distribution.',
    `approved_by` STRING COMMENT 'Name or identifier of the senior analyst, research director, or compliance officer who granted final approval for publication.',
    `archive_date` DATE COMMENT 'Date on which the report was archived or moved to historical storage, reflecting retention policies and the end of its active lifecycle.',
    `asset_class` STRING COMMENT 'Primary asset class or investment category that the research report addresses, aligned with the organizations Strategic Asset Allocation (SAA) framework. [ENUM-REF-CANDIDATE',
    `author_name` STRING COMMENT 'Full name of the primary research analyst or team lead responsible for authoring the report.',
    `author_team` STRING COMMENT 'Name of the internal research team or division that produced the report, such as Macro Research, Equity Research, or Private Markets Research.',
    `confidence_level` STRING COMMENT 'Qualitative assessment of the research teams confidence in the reports conclusions and recommendations, based on data quality, model robustness, and market uncertainty.. Valid values are `high|medium|low`',
    `confidentiality_level` STRING COMMENT 'Data classification level assigned to the report, governing access controls, sharing restrictions, and retention policies.. Valid values are `public|internal|confidential|restricted`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the report record was first created in the research management system, supporting audit trail and data lineage requirements.',
    `data_sources` STRING COMMENT 'List of primary and secondary data sources used in the research, including Bloomberg Terminal, FactSet, Preqin, PitchBook, and proprietary internal databases.',
    `distribution_list` STRING COMMENT 'Classification of the intended audience and distribution scope for the report, reflecting confidentiality and information governance policies.. Valid values are `internal_only|ic_members|senior_leadership|portfolio_managers|all_staff`',
    `document_version` STRING COMMENT 'Version identifier for the report document, supporting change tracking and audit trail requirements for regulatory and governance purposes.',
    `esg_integration` STRING COMMENT 'Analysis of Environmental, Social, and Governance factors and their materiality to the investment thesis, aligned with PRI and TCFD frameworks.',
    `esg_rating` STRING COMMENT 'Aggregated ESG rating or score assigned to the subject of the report, sourced from internal assessment or external providers such as MSCI ESG Ratings. [ENUM-REF-CANDIDATE: AAA|AA|A|BBB|BB|B|CCC — 7 candidates stripped; promote to reference product]',
    `executive_summary` STRING COMMENT 'Concise summary of the reports key findings, investment thesis, and actionable recommendations for senior leadership and IC review.',
    `file_format` STRING COMMENT 'Digital file format of the published report, such as PDF for formal publications or PowerPoint for IC presentations.. Valid values are `pdf|docx|pptx|html|xlsx`',
    `file_path` STRING COMMENT 'Storage location or URI of the published report document within the enterprise content management system or data lake.',
    `geographic_focus` STRING COMMENT 'Primary geographic region, country, or market that the research report analyzes, using ISO 3166-1 alpha-3 country codes or regional designations.',
    `ic_decision` STRING COMMENT 'Formal decision rendered by the Investment Committee (IC) following review of the report and associated investment memorandum.. Valid values are `approved|approved_with_conditions|deferred|rejected|not_applicable`',
    `ic_submission_date` DATE COMMENT 'Date on which the report was submitted to the Investment Committee (IC) for review and decision-making.',
    `ic_submission_flag` BOOLEAN COMMENT 'Indicates whether this report was formally submitted to the Investment Committee (IC) as part of an investment decision or approval process.',
    `investment_horizon` STRING COMMENT 'Time horizon for the investment outlook or recommendations presented in the report, reflecting the organizations long-duration liability matching strategy.. Valid values are `short_term|medium_term|long_term|strategic`',
    `investment_recommendation` STRING COMMENT 'Formal investment stance or action recommended by the research team, expressed in terms consistent with internal portfolio construction and Tactical Asset Allocation (TAA) processes.',
    `key_findings` STRING COMMENT 'Detailed narrative of the primary research conclusions, data insights, and analytical results that support the reports investment thesis.',
    `keywords` STRING COMMENT 'Comma-separated list of keywords or tags assigned to the report for search, discovery, and taxonomy purposes within the research library.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time of the most recent update to any field in the report record, supporting change tracking and data governance.',
    `macroeconomic_scenario` STRING COMMENT 'Reference to the proprietary macroeconomic scenario or stress-test framework applied in the analysis, such as base case, recession, or inflationary environment.',
    `methodology` STRING COMMENT 'Description of the analytical methods, models, and frameworks applied, such as Discounted Cash Flow (DCF), Capital Asset Pricing Model (CAPM), or proprietary macroeconomic modeling.',
    `number` STRING COMMENT 'Externally-known unique identifier or reference code assigned to the research publication for cataloging and citation purposes.',
    `page_count` BIGINT COMMENT 'Total number of pages in the published report document, used for cataloging and resource planning purposes.',
    `peer_review_status` STRING COMMENT 'Status of internal peer review or quality assurance process conducted by senior analysts or research leadership prior to publication.. Valid values are `not_required|pending|completed|approved|rejected`',
    `publication_date` DATE COMMENT 'Date on which the research report was formally published and made available to authorized internal stakeholders and Investment Committee (IC) members.',
    `publication_status` STRING COMMENT 'Current lifecycle state of the research report within the internal publication workflow and governance process.. Valid values are `draft|under_review|approved|published|archived|withdrawn`',
    `research_report_type` STRING COMMENT 'Classification of the research publication by its primary analytical focus and intended use within the investment process.. Valid values are `sector|country_regional|thematic|asset_class|macro_outlook|investment_memorandum`',
    `revision_date` DATE COMMENT 'Date of the most recent substantive revision or update to the report content, distinct from minor editorial corrections.',
    `revision_notes` STRING COMMENT 'Summary of changes made in the current version, including updated data, revised assumptions, or new analytical insights.',
    `risk_assessment` STRING COMMENT 'Comprehensive evaluation of investment risks, including market, credit, liquidity, operational, and macroeconomic risks, with quantitative and qualitative analysis.',
    `sector_focus` STRING COMMENT 'Industry sector or thematic area covered by the report, such as technology, healthcare, energy transition, or infrastructure, aligned with GICS or internal taxonomy.',
    `target_return` DECIMAL(10,4) COMMENT 'Expected annualized return or Internal Rate of Return (IRR) projected for the investment opportunity or asset class analyzed in the report, expressed as a decimal.',
    `target_return_currency` STRING COMMENT 'ISO 4217 three-letter currency code in which the target return is denominated, such as USD, EUR, or GBP.. Valid values are `^[A-Z]{3}$`',
    `title` STRING COMMENT 'Full title of the research report as it appears on the publication.',
    `valuation_approach` STRING COMMENT 'Primary valuation methodology employed in the report, appropriate to the asset class and investment type being analyzed.. Valid values are `dcf|comparable_company|precedent_transaction|nav|irr_moic|market_multiples`',
    CONSTRAINT pk_research_report PRIMARY KEY(`research_report_id`)
) COMMENT 'Master record of formal research publications produced by the internal research team across all publication types — sector, country/regional, thematic, asset-class, and macro outlooks plus IC-supporting investment memoranda.';

CREATE OR REPLACE TABLE `asset_management`.`research`.`sector_outlook` (
    `sector_outlook_id` BIGINT COMMENT 'Unique identifier for the sector outlook assessment record.',
    `previous_outlook_sector_outlook_id` BIGINT COMMENT 'Reference to the prior version of this sector outlook that this record supersedes.',
    `approval_date` DATE COMMENT 'Date when the sector outlook was formally approved by the Investment Committee (IC) or research leadership.',
    `approved_by` STRING COMMENT 'Name and title of the senior leader or Investment Committee (IC) member who approved the sector outlook.',
    `archived_date` DATE COMMENT 'Date when the sector outlook was archived and superseded by a newer version.',
    `archived_flag` BOOLEAN COMMENT 'Indicates whether the sector outlook has been archived and is no longer active for investment decision-making.',
    `base_case_scenario` STRING COMMENT 'Description of the base case macroeconomic scenario underpinning the sector outlook.',
    `climate_risk_assessment` STRING COMMENT 'Assessment of climate-related physical and transition risks impacting the sector.. Valid values are `high|medium|low|not_applicable`',
    `comments` STRING COMMENT 'Additional notes, caveats, or context relevant to the sector outlook assessment.',
    `confidentiality_level` STRING COMMENT 'Data classification level governing access and distribution of the sector outlook document.. Valid values are `public|internal|confidential|restricted`',
    `contributing_analysts` STRING COMMENT 'Names of additional research team members who contributed to the sector outlook assessment.',
    `conviction_level` STRING COMMENT 'Degree of confidence the research team has in the investment view and outlook assessment.. Valid values are `high|medium|low`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the sector outlook record was first created in the system.',
    `data_sources` STRING COMMENT 'List of primary data sources and market intelligence platforms used in the outlook analysis (e.g., Bloomberg Terminal, FactSet, MSCI, Preqin).',
    `distribution_list` STRING COMMENT 'Comma-separated list of stakeholder groups and individuals authorized to receive the sector outlook (e.g., IC members, portfolio managers, senior leadership).',
    `document_url` STRING COMMENT 'Link to the full sector outlook report document stored in the enterprise content management system.',
    `downside_scenario` STRING COMMENT 'Description of the downside macroeconomic scenario and its implications for the sector.',
    `effective_from_date` DATE COMMENT 'Date from which the sector outlook assessment becomes effective for portfolio construction and Tactical Asset Allocation (TAA) decisions.',
    `effective_to_date` DATE COMMENT 'Date until which the sector outlook remains valid, after which it is superseded or archived.',
    `esg_considerations` STRING COMMENT 'Environmental, Social, and Governance factors material to the sector outlook and investment decision-making.',
    `executive_summary` STRING COMMENT 'High-level summary of the sector outlook, key drivers, and investment implications for senior leadership and Investment Committee (IC) members.',
    `geographic_focus` STRING COMMENT 'Primary geographic regions or countries covered by the sector outlook (e.g., North America, Europe, Asia-Pacific, Global).',
    `gics_industry_group_code` STRING COMMENT 'Four-digit GICS industry group code for more granular sector classification.. Valid values are `^[0-9]{4}$`',
    `gics_industry_group_name` STRING COMMENT 'Full name of the GICS industry group within the sector.',
    `gics_sector_code` STRING COMMENT 'Two-digit GICS sector code identifying the primary sector covered by this outlook.. Valid values are `^[0-9]{2}$`',
    `gics_sector_name` STRING COMMENT 'Full name of the GICS sector (e.g., Energy, Financials, Information Technology).',
    `investment_view` STRING COMMENT 'Overall investment stance recommended by the research team for this sector relative to Strategic Asset Allocation (SAA).. Valid values are `overweight|neutral|underweight|positive|negative`',
    `key_drivers` STRING COMMENT 'Primary factors and catalysts driving the sector outlook, including supply-demand dynamics, regulatory changes, and technological trends.',
    `key_risks` STRING COMMENT 'Material risks and headwinds that could negatively impact the sector outlook and investment thesis.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the sector outlook record was last updated or revised.',
    `lead_analyst_email` STRING COMMENT 'Business email address of the lead analyst for inquiries and collaboration.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `lead_analyst_name` STRING COMMENT 'Full name of the lead research analyst responsible for authoring and maintaining the sector outlook.',
    `macroeconomic_context` STRING COMMENT 'Description of the macroeconomic environment and key indicators influencing the sector outlook.',
    `outlook_code` STRING COMMENT 'Business identifier code for the sector outlook report, used for external reference and tracking.. Valid values are `^[A-Z0-9]{6,12}$`',
    `outlook_status` STRING COMMENT 'Current lifecycle status of the sector outlook assessment.. Valid values are `draft|under_review|approved|published|archived|superseded`',
    `outlook_title` STRING COMMENT 'Formal title of the sector outlook report as presented to the Investment Committee (IC).',
    `outlook_type` STRING COMMENT 'Classification of the outlook report by frequency and purpose.. Valid values are `quarterly|annual|ad_hoc|thematic|strategic`',
    `portfolio_implications` STRING COMMENT 'Recommended actions and implications for portfolio construction, asset allocation, and position sizing across public and private markets.',
    `publication_date` DATE COMMENT 'Date when the sector outlook was formally published and made available to portfolio managers and the Investment Committee (IC).',
    `review_date` DATE COMMENT 'Scheduled date for the next formal review and update of the sector outlook.',
    `scenario_analysis_flag` BOOLEAN COMMENT 'Indicates whether the sector outlook includes formal macroeconomic scenario analysis and stress testing.',
    `time_horizon` STRING COMMENT 'Investment time horizon for which the sector outlook is relevant (short-term: 0-12 months, medium-term: 1-3 years, long-term: 3+ years).. Valid values are `short_term|medium_term|long_term|tactical|strategic`',
    `upside_scenario` STRING COMMENT 'Description of the upside macroeconomic scenario and its implications for the sector.',
    `valuation_assessment` STRING COMMENT 'Overall valuation assessment of the sector relative to historical averages and fundamental metrics.. Valid values are `expensive|fair|cheap|mixed`',
    `version_number` STRING COMMENT 'Version identifier for the sector outlook document, incremented with each revision.. Valid values are `^[0-9]+.[0-9]+$`',
    CONSTRAINT pk_sector_outlook PRIMARY KEY(`sector_outlook_id`)
) COMMENT 'Master record of formal sector and industry outlook assessments produced by the research team, covering GICS sectors and sub-industries relevant to the funds equity, credit, and private markets portfolios.';

CREATE OR REPLACE TABLE `asset_management`.`research`.`country_outlook` (
    `country_outlook_id` BIGINT COMMENT 'Unique identifier for the country outlook assessment record.',
    `analyst_employee_id` BIGINT COMMENT 'Identifier of the lead research analyst responsible for authoring and maintaining this country outlook assessment.',
    `employee_id` BIGINT COMMENT 'Identifier of the lead research analyst responsible for authoring and maintaining this country outlook assessment.',
    `superseded_by_country_outlook_id` BIGINT COMMENT 'Identifier of the newer country outlook assessment that supersedes this version, enabling historical lineage tracking.',
    `approval_status` STRING COMMENT 'Governance approval status indicating whether this country outlook has been formally approved by the Chief Investment Officer or designated research leadership.. Valid values are `pending|approved|rejected`',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when this country outlook assessment received formal approval for publication and operational use.',
    `approved_by` STRING COMMENT 'Name or identifier of the senior research or investment officer who formally approved this country outlook for publication and use in investment decisions.',
    `assessment_date` DATE COMMENT 'Date on which this country outlook assessment was finalized and published by the research team.',
    `capital_controls_flag` BOOLEAN COMMENT 'Indicator of whether the country maintains significant capital controls restricting cross-border investment flows and repatriation.',
    `climate_risk_category` STRING COMMENT 'Assessment of physical and transition climate risks facing the country based on exposure to climate hazards and carbon transition vulnerability.. Valid values are `low|moderate|high|extreme`',
    `comments` STRING COMMENT 'Additional qualitative commentary, caveats, or context provided by the research team regarding this country outlook assessment.',
    `corruption_perception_index` BIGINT COMMENT 'Transparency International Corruption Perceptions Index score on a 0-100 scale where higher indicates lower perceived corruption.',
    `country_code` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code identifying the sovereign nation or territory subject to this outlook assessment.. Valid values are `^[A-Z]{3}$`',
    `country_name` STRING COMMENT 'Full official name of the country or territory covered by this outlook assessment.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this country outlook assessment record was first created in the research system.',
    `credit_outlook` STRING COMMENT 'Forward-looking credit outlook indicating the expected direction of sovereign credit quality over the assessment horizon.. Valid values are `positive|stable|negative|developing`',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the countrys primary sovereign currency used in FX risk and hedging analysis.. Valid values are `^[A-Z]{3}$`',
    `currency_outlook` STRING COMMENT 'Forward-looking assessment of the expected direction and stability of the sovereign currency relative to major reserve currencies.. Valid values are `strengthening|stable|weakening|volatile`',
    `current_account_balance_gdp_pct` DECIMAL(6,3) COMMENT 'Current account balance as a percentage of GDP, reflecting external trade position and foreign exchange reserve sustainability.',
    `data_source` STRING COMMENT 'Primary external data providers and research platforms used to compile this country outlook including Bloomberg, FactSet, IMF, World Bank, and rating agencies.',
    `ease_of_doing_business_rank` BIGINT COMMENT 'Countrys global ranking in the World Bank Ease of Doing Business index, reflecting regulatory efficiency and business environment quality.',
    `esg_country_score` DECIMAL(5,2) COMMENT 'Composite ESG score for the country reflecting environmental sustainability, social development, and governance quality on a 0-100 scale.',
    `fiscal_balance_gdp_pct` DECIMAL(6,3) COMMENT 'Government fiscal balance (surplus or deficit) expressed as a percentage of GDP, indicating fiscal sustainability and sovereign credit risk.',
    `foreign_reserves_months_import` DECIMAL(5,2) COMMENT 'Foreign exchange reserves expressed as months of import coverage, indicating external liquidity and crisis resilience.',
    `fx_volatility_category` STRING COMMENT 'Classification of expected foreign exchange rate volatility based on historical variance and forward-looking macro factors.. Valid values are `low|moderate|high|extreme`',
    `ic_presentation_date` DATE COMMENT 'Date on which this country outlook was presented to the Investment Committee for review and strategic allocation guidance.',
    `ic_presentation_flag` BOOLEAN COMMENT 'Indicator of whether this country outlook assessment has been formally presented to the Investment Committee for strategic allocation decisions.',
    `investment_climate_rating` STRING COMMENT 'Overall qualitative rating of the countrys investment climate considering market access, capital controls, repatriation rules, and investor protections.. Valid values are `very_favorable|favorable|neutral|challenging|unfavorable`',
    `investment_recommendation` STRING COMMENT 'Research teams strategic asset allocation recommendation for country exposure relative to benchmark weights.. Valid values are `overweight|neutral|underweight|avoid`',
    `key_opportunities` STRING COMMENT 'Summary of primary investment opportunities and positive catalysts identified for the country including structural reforms, demographic trends, and sector strengths.',
    `key_risks` STRING COMMENT 'Summary of primary downside risks identified by the research team including political, economic, regulatory, and market-specific factors.',
    `market_access_category` STRING COMMENT 'Classification of foreign investor access to domestic capital markets including equities, fixed income, real estate, and private markets.. Valid values are `open|restricted|closed|emerging`',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review and update of this country outlook assessment by the research team.',
    `outlook_horizon_years` BIGINT COMMENT 'Forward-looking time horizon in years for which this country outlook assessment and projections are valid.',
    `outlook_status` STRING COMMENT 'Current lifecycle status of the country outlook assessment within the research governance workflow.. Valid values are `draft|under_review|approved|published|archived|superseded`',
    `political_risk_category` STRING COMMENT 'Categorical classification of political risk level based on governance stability, rule of law, corruption, and geopolitical tensions.. Valid values are `low|moderate|elevated|high|severe`',
    `political_risk_score` DECIMAL(5,2) COMMENT 'Quantitative score assessing political stability, governance quality, regulatory predictability, and geopolitical risk on a 0-100 scale where higher indicates lower risk.',
    `projected_gdp_growth_rate` DECIMAL(6,3) COMMENT 'Research teams forecast of real GDP growth rate expressed as a percentage for the outlook horizon, reflecting expected economic expansion or contraction.',
    `projected_inflation_rate` DECIMAL(6,3) COMMENT 'Forecast of consumer price inflation rate expressed as a percentage, used for real return calculations and liability matching.',
    `projected_unemployment_rate` DECIMAL(5,2) COMMENT 'Expected unemployment rate as a percentage of the labor force, indicating labor market health and social stability.',
    `public_debt_gdp_pct` DECIMAL(6,2) COMMENT 'Total government debt outstanding as a percentage of GDP, key metric for sovereign credit analysis and debt sustainability assessment.',
    `region` STRING COMMENT 'Broad geographic region classification for portfolio allocation and macroeconomic analysis purposes. [ENUM-REF-CANDIDATE: North America|Latin America|Europe|Middle East|Africa|Asia Pacific|Oceania — 7 candidates stripped; promote to reference product]',
    `regulatory_environment_score` DECIMAL(5,2) COMMENT 'Assessment score evaluating the quality, transparency, and investor-friendliness of the regulatory and legal framework on a 0-100 scale.',
    `sovereign_credit_rating` STRING COMMENT 'Current sovereign credit rating assigned by major rating agencies reflecting the countrys creditworthiness and default risk.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this country outlook assessment record was most recently modified or updated.',
    `version_number` BIGINT COMMENT 'Sequential version number tracking revisions and updates to this country outlook assessment over time.',
    CONSTRAINT pk_country_outlook PRIMARY KEY(`country_outlook_id`)
) COMMENT 'Master record of country and regional economic outlook assessments maintained by the research team, covering sovereign credit quality, political risk, regulatory environment, currency outlook, growth trajectory, and investment climate ratings.';

CREATE OR REPLACE TABLE `asset_management`.`research`.`thematic_research` (
    `thematic_research_id` BIGINT COMMENT 'Unique identifier for the thematic research report.',
    `employee_id` BIGINT COMMENT 'Identifier of the principal research analyst responsible for authoring and maintaining this thematic research.',
    `framework_id` BIGINT COMMENT 'Foreign key linking to esg.framework. Business justification: Thematic research on ESG topics (energy transition, SFDR implications, taxonomy alignment) must reference the specific regulatory framework being analyzed.',
    `peer_reviewer_employee_id` BIGINT COMMENT 'Identifier of the senior analyst or research director responsible for peer reviewing this thematic research.',
    `superseded_by_research_thematic_research_id` BIGINT COMMENT 'Identifier of the newer thematic research report that supersedes this version, if applicable.',
    `thematic_analyst_assignment_id` BIGINT COMMENT 'Identifier of the principal research analyst responsible for authoring and maintaining this thematic research.',
    `thematic_peer_reviewer_analyst_assignment_id` BIGINT COMMENT 'Identifier of the senior analyst or research director responsible for peer reviewing this thematic research.',
    `access_restriction_level` STRING COMMENT 'Data classification level governing access permissions and distribution of the thematic research report.. Valid values are `public|internal|confidential|restricted`',
    `affected_asset_classes` STRING COMMENT 'Comma-separated list of asset classes materially impacted by this structural theme (e.g., public equities, private equity, infrastructure, real estate).',
    `affected_sectors` STRING COMMENT 'Comma-separated list of industry sectors and sub-sectors most exposed to this thematic trend.',
    `approval_date` DATE COMMENT 'Date when the thematic research report received final approval from research leadership for publication and distribution.',
    `climate_relevance` STRING COMMENT 'Assessment of the themes relevance to climate transition, adaptation, and net-zero investment objectives.. Valid values are `high|medium|low|not_applicable`',
    `confidence_level` STRING COMMENT 'Research teams confidence level in the thematic thesis and projected investment outcomes based on data quality and analytical rigor.. Valid values are `high|medium|low`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the thematic research record was first created in the research management system.',
    `data_sources` STRING COMMENT 'Comma-separated list of primary data sources, market intelligence providers, and research databases used in the thematic analysis (e.g., Bloomberg, FactSet, Preqin, PitchBook).',
    `document_url` STRING COMMENT 'Internal repository URL or file path to the full thematic research document and supporting materials.',
    `esg_alignment_score` DECIMAL(5,2) COMMENT 'Quantitative score (0-100) assessing the alignment of this thematic trend with the funds ESG and responsible investment objectives.',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether ESG factors are materially integrated into the thematic research analysis and investment recommendations.',
    `executive_summary` STRING COMMENT 'High-level summary of the thematic research findings, key insights, and investment implications for IC and portfolio managers.',
    `geographic_scope` STRING COMMENT 'Geographic coverage and regional focus of the thematic research analysis.. Valid values are `global|north_america|europe|asia_pacific|emerging_markets|developed_markets`',
    `ic_presentation_date` DATE COMMENT 'Date when the thematic research was presented to the Investment Committee.',
    `ic_presentation_flag` BOOLEAN COMMENT 'Indicates whether this thematic research has been formally presented to the Investment Committee for strategic portfolio allocation decisions.',
    `investment_horizon_years` BIGINT COMMENT 'Long-term investment horizon in years over which this structural theme is expected to materialize and impact portfolio returns.',
    `investment_implications` STRING COMMENT 'Strategic investment implications and portfolio positioning recommendations derived from the thematic analysis.',
    `key_drivers` STRING COMMENT 'Primary macroeconomic, technological, regulatory, or social drivers underpinning this structural theme.',
    `methodology_description` STRING COMMENT 'Description of the research methodology, analytical frameworks, and modeling techniques employed in the thematic analysis.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal review and potential update of the thematic research report.',
    `peer_review_status` STRING COMMENT 'Status of internal peer review process by senior research analysts and investment leadership.. Valid values are `not_started|in_progress|completed|approved|rejected`',
    `publication_date` DATE COMMENT 'Date when the thematic research report was officially published and made available to investment teams and IC.',
    `related_deal_count` BIGINT COMMENT 'Number of active deal pipeline opportunities and investments directly linked to this thematic research.',
    `related_portfolio_exposure_aum` DECIMAL(20,2) COMMENT 'Total AUM in millions of base currency currently allocated to investments aligned with this thematic trend.',
    `research_identifier` STRING COMMENT 'Externally-known unique code or reference number for the thematic research report used in IC presentations and research libraries.',
    `research_status` STRING COMMENT 'Current lifecycle status of the thematic research report in the research workflow.. Valid values are `draft|under_review|approved|published|archived|superseded`',
    `research_team` STRING COMMENT 'Name of the research team or division that produced this thematic research report.',
    `review_frequency_months` BIGINT COMMENT 'Scheduled frequency in months for periodic review and update of the thematic research to reflect evolving market conditions.',
    `risk_considerations` STRING COMMENT 'Key risks, uncertainties, and potential headwinds that could impact the realization of this thematic investment opportunity.',
    `tags` STRING COMMENT 'Comma-separated metadata tags for categorization, search, and discovery of thematic research within the research library.',
    `target_allocation_percentage` DECIMAL(5,2) COMMENT 'Strategic Asset Allocation (SAA) target percentage of total AUM recommended for investments aligned with this theme.',
    `theme_category` STRING COMMENT 'Primary thematic category classifying the structural trend covered by this research.. Valid values are `energy_transition|digital_infrastructure|demographic_shifts|deglobalization|artificial_intelligence|climate_adaptation`',
    `title` STRING COMMENT 'Full title of the thematic research report describing the structural trend or investment theme.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the thematic research record was last modified or updated.',
    `version_number` STRING COMMENT 'Version identifier for tracking iterations and updates to the thematic research report over time.',
    CONSTRAINT pk_thematic_research PRIMARY KEY(`thematic_research_id`)
) COMMENT 'Master record of long-horizon thematic investment research produced by the research team covering structural trends relevant to the funds long-duration mandate — e.g., energy transition, digital infrastructure, demographic shifts, deglobalization, AI';

CREATE OR REPLACE TABLE `asset_management`.`research`.`coverage_universe` (
    `coverage_universe_id` BIGINT COMMENT 'Unique identifier for the coverage universe record. Primary key for the master record defining the research teams formally covered universe of issuers, sectors, geographies, and asset classes.',
    `employee_id` BIGINT COMMENT 'Identifier of the primary research analyst responsible for coverage of this entity.',
    `issuer_esg_rating_id` BIGINT COMMENT 'Foreign key linking to esg.issuer_esg_rating. Business justification: Research coverage of issuers requires current ESG ratings for integrated fundamental analysis. Analysts need direct access to ESG scores when evaluating investment opportunities.',
    `lead_analyst_employee_id` BIGINT COMMENT 'Identifier of the primary research analyst responsible for coverage of this entity.',
    `asset_class` STRING COMMENT 'Primary asset class category to which this coverage universe entry belongs, spanning all investment types managed by the pension fund.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `aum_usd` DECIMAL(20,2) COMMENT 'Total assets under management for covered fund managers or asset managers, expressed in USD.',
    `benchmark_index` STRING COMMENT 'Primary benchmark index to which the covered entity is compared for performance attribution and relative valuation analysis.',
    `bloomberg_ticker` STRING COMMENT 'Bloomberg ticker symbol for the covered entity, enabling direct lookup in Bloomberg Terminal for market data and analytics.',
    `coverage_initiation_date` DATE COMMENT 'Date when formal research coverage of this entity was initiated by the research team.',
    `coverage_status` STRING COMMENT 'Current status of research coverage for this entity, indicating whether active analysis and monitoring is ongoing.. Valid values are `active|suspended|discontinued|under_review`',
    `coverage_team` STRING COMMENT 'Name of the research team or desk responsible for ongoing analysis and monitoring of this coverage universe entry.',
    `coverage_tier` STRING COMMENT 'Priority tier assigned to the coverage universe entry, reflecting depth of research effort and strategic importance to portfolio construction.. Valid values are `tier_1|tier_2|tier_3|watchlist`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the coverage universe record was first created in the system.',
    `credit_rating` STRING COMMENT 'External credit rating assigned to the covered entity by major rating agencies such as Moodys, S&P, or Fitch.',
    `cusip` STRING COMMENT 'CUSIP identifier for North American securities, used for trade settlement and regulatory reporting.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `data_source` STRING COMMENT 'Primary external data provider or system of record for market data and fundamental information on the covered entity.',
    `entity_name` STRING COMMENT 'Full legal or common name of the issuer, company, sovereign, or entity within the coverage universe.',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether ESG factors are formally integrated into the research coverage and investment analysis for this entity.',
    `fund_strategy` STRING COMMENT 'Investment strategy employed by covered fund managers, such as buyout, venture capital, growth equity, or distressed debt.',
    `geography` STRING COMMENT 'Primary geographic region or country of domicile for the covered entity, using ISO 3166-1 alpha-3 country codes.. Valid values are `^[A-Z]{3}$`',
    `ic_approval_required_flag` BOOLEAN COMMENT 'Indicates whether investments in this coverage universe entry require explicit Investment Committee approval prior to execution.',
    `investable_flag` BOOLEAN COMMENT 'Indicates whether the covered entity is currently approved for investment by the Investment Committee, subject to mandate constraints.',
    `investment_grade_flag` BOOLEAN COMMENT 'Indicates whether the covered entity holds an investment grade credit rating, distinguishing IG from high yield issuers.',
    `investment_style` STRING COMMENT 'Investment approach or style characterizing the covered entity, such as value, growth, core-plus, opportunistic, or distressed.',
    `isin` STRING COMMENT 'ISO 6166 International Securities Identification Number for the covered security or instrument.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `last_review_date` DATE COMMENT 'Date of the most recent comprehensive research review or update for this coverage universe entry.',
    `lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the covered entity, enabling global entity identification and regulatory reporting.. Valid values are `^[A-Z0-9]{20}$`',
    `liquidity_classification` STRING COMMENT 'Assessment of the liquidity profile of the covered entity or asset class, critical for portfolio construction and risk management.. Valid values are `highly_liquid|liquid|illiquid|highly_illiquid`',
    `market_cap_usd` DECIMAL(20,2) COMMENT 'Current market capitalization of the covered entity in USD, applicable to publicly traded issuers.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal research review or coverage update, ensuring ongoing monitoring discipline.',
    `regional_classification` STRING COMMENT 'Market development classification for the geographic region, distinguishing developed, emerging, and frontier markets.. Valid values are `developed|emerging|frontier`',
    `research_notes` STRING COMMENT 'Internal research commentary and qualitative notes on the covered entity, capturing analyst insights and investment thesis.',
    `restricted_flag` BOOLEAN COMMENT 'Indicates whether the covered entity is subject to investment restrictions due to regulatory, ethical, or policy constraints.',
    `restriction_reason` STRING COMMENT 'Explanation of the reason for investment restriction, such as ESG exclusion, regulatory prohibition, or conflict of interest.',
    `sector` STRING COMMENT 'Industry sector classification for the covered entity, aligned with GICS or internal sector taxonomy.',
    `sedol` STRING COMMENT 'SEDOL identifier for securities traded on the London Stock Exchange and other European exchanges.. Valid values are `^[0-9A-Z]{7}$`',
    `sub_asset_class` STRING COMMENT 'Granular sub-category within the primary asset class, such as growth equity, value equity, core real estate, opportunistic infrastructure, or high yield credit.',
    `sub_sector` STRING COMMENT 'Detailed sub-sector or industry group within the primary sector, enabling granular thematic and sector research.',
    `target_irr_percent` DECIMAL(5,2) COMMENT 'Target internal rate of return for private market investments or fund commitments, expressed as a percentage.',
    `universe_code` STRING COMMENT 'Business identifier code for the coverage universe entry, used for external reference and reporting.. Valid values are `^[A-Z0-9_-]{3,20}$`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the coverage universe record, supporting audit trail and data lineage.',
    `vintage_year` BIGINT COMMENT 'Year of fund commitment or initial investment for private market funds and co-investments within the coverage universe.',
    CONSTRAINT pk_coverage_universe PRIMARY KEY(`coverage_universe_id`)
) COMMENT 'Master record defining the research teams formally covered universe of issuers, sectors, geographies, and asset classes across ALL asset classes — including private markets, credit, and real assets — distinct from equity.coverage which is listed-equity';

CREATE OR REPLACE TABLE `asset_management`.`research`.`analyst_assignment` (
    `analyst_assignment_id` BIGINT COMMENT 'Unique identifier for the research analyst assignment record.',
    `analyst_employee_id` BIGINT COMMENT 'Identifier of the research analyst assigned to coverage responsibility.',
    `analyst_supervisor_employee_id` BIGINT COMMENT 'Identifier of the senior analyst or research director supervising this assignment and responsible for quality assurance.',
    `coverage_universe_id` BIGINT COMMENT 'Identifier of the specific entity being covered, such as issuer Legal Entity Identifier (LEI), sector code, or geography code.',
    `employee_id` BIGINT COMMENT 'Identifier of the research analyst assigned to coverage responsibility.',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Research analysts are assigned to cover specific GP managers for ongoing due diligence monitoring.',
    `primary_predecessor_assignment_analyst_assignment_id` BIGINT COMMENT 'Identifier of the previous assignment record if this assignment is a continuation or transition from another analyst.',
    `supervisor_employee_id` BIGINT COMMENT 'Identifier of the senior analyst or research director supervising this assignment and responsible for quality assurance.',
    `approval_date` DATE COMMENT 'Date when the assignment was formally approved by the research director or Investment Committee (IC).',
    `approval_status` STRING COMMENT 'Approval workflow status of the assignment: draft, pending approval, approved by research director, rejected, or revision required.. Valid values are `draft|pending_approval|approved|rejected|revision_required`',
    `approved_by` STRING COMMENT 'Name or identifier of the research director or Investment Committee (IC) member who approved this assignment.',
    `asset_class` STRING COMMENT 'Primary asset class scope of the assignment: public equity, private equity, real estate, infrastructure, natural resources, credit, fixed income, or multi-asset.',
    `assignment_end_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the analyst assignment was terminated or transitioned; null for active assignments.',
    `assignment_identifier` STRING COMMENT 'Business-readable unique identifier for the assignment, used in research systems and Investment Committee (IC) materials.',
    `assignment_notes` STRING COMMENT 'Free-text notes capturing special instructions, context, or historical information relevant to this assignment.',
    `assignment_start_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the analyst assignment was initiated in the research management system.',
    `assignment_status` STRING COMMENT 'Current lifecycle status of the analyst assignment: active coverage, inactive, suspended, pending approval, or in transition.. Valid values are `active|inactive|suspended|pending|transition`',
    `assignment_type` STRING COMMENT 'Role type of the assignment: primary analyst, secondary support, backup coverage, specialist consultant, or thematic research lead.. Valid values are `primary|secondary|backup|specialist|thematic`',
    `benchmark_index` STRING COMMENT 'Primary benchmark index or reference portfolio used for performance comparison and relative valuation in this coverage assignment.',
    `collaboration_team` STRING COMMENT 'Names or identifiers of other analysts, portfolio managers, or teams collaborating on this coverage assignment.',
    `confidentiality_level` STRING COMMENT 'Data classification level for research outputs from this assignment: public, internal, confidential, or restricted.. Valid values are `public|internal|confidential|restricted`',
    `conflict_description` STRING COMMENT 'Description of any identified conflict of interest and mitigation measures in place, maintained for compliance and governance.',
    `conflict_of_interest_flag` BOOLEAN COMMENT 'Flag indicating whether a potential conflict of interest has been identified and documented for this assignment.',
    `coverage_entity_name` STRING COMMENT 'Human-readable name of the entity assigned for coverage, such as issuer legal name, sector name, or country name.',
    `coverage_entity_type` STRING COMMENT 'Type of entity assigned for research coverage: issuer, sector, geography, asset class, external fund manager, or portfolio.. Valid values are `issuer|sector|geography|asset_class|fund_manager|portfolio`',
    `coverage_priority` STRING COMMENT 'Priority tier of the coverage assignment reflecting strategic importance and research intensity: tier 1 core, tier 2 standard, tier 3 monitoring, watchlist, or opportunistic.. Valid values are `tier_1|tier_2|tier_3|watchlist|opportunistic`',
    `coverage_scope` STRING COMMENT 'Detailed description of the coverage scope, including specific mandates, thematic focus areas, or exclusions within the assigned entity.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this assignment record was first created in the research management system.',
    `data_source_systems` STRING COMMENT 'Primary data source systems and platforms used for this assignment, such as Bloomberg Terminal, FactSet, Preqin, or internal Investment Book of Record (IBOR).',
    `due_diligence_responsibility` STRING COMMENT 'Level of due diligence responsibility assigned: full operational and financial due diligence, partial support, none, or advisory role.. Valid values are `full|partial|none|advisory`',
    `effective_date` DATE COMMENT 'Date when the analyst assignment becomes effective and coverage responsibility begins.',
    `esg_integration_flag` BOOLEAN COMMENT 'Flag indicating whether Environmental, Social, and Governance (ESG) analysis is required as part of this coverage assignment.',
    `expiry_date` DATE COMMENT 'Date when the analyst assignment expires or coverage responsibility ends; null for open-ended assignments.',
    `geographic_focus` STRING COMMENT 'Geographic region or country focus of the assignment, using three-letter ISO country codes or regional groupings.',
    `ic_presentation_requirement` BOOLEAN COMMENT 'Flag indicating whether this assignment requires regular presentations to the Investment Committee (IC).',
    `last_review_date` DATE COMMENT 'Date of the most recent formal review of the assignment, including scope validation and performance assessment.',
    `macroeconomic_modeling_flag` BOOLEAN COMMENT 'Flag indicating whether proprietary macroeconomic modeling and scenario analysis is required for this assignment.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal review of the assignment scope, priority, and analyst performance.',
    `peer_group` STRING COMMENT 'Defined peer group or comparable set of entities used for relative analysis and benchmarking within this assignment.',
    `performance_rating` STRING COMMENT 'Most recent performance rating of the analyst on this assignment: exceeds expectations, meets expectations, below expectations, or not yet rated.. Valid values are `exceeds|meets|below|not_rated`',
    `reporting_frequency` STRING COMMENT 'Expected frequency of research reports and updates for this assignment: daily, weekly, monthly, quarterly, annual, or ad hoc.. Valid values are `daily|weekly|monthly|quarterly|annual|ad_hoc`',
    `research_mandate` STRING COMMENT 'Formal research mandate or charter defining the analysts responsibilities, deliverables, and reporting requirements for this assignment.',
    `review_frequency` STRING COMMENT 'Scheduled frequency for formal review and reassessment of the assignment: monthly, quarterly, semi-annual, or annual.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `sector_focus` STRING COMMENT 'Industry sector or sub-sector focus of the assignment, using Global Industry Classification Standard (GICS) or internal taxonomy.',
    `transition_reason` STRING COMMENT 'Reason for assignment transition or termination, such as analyst departure, portfolio restructuring, or strategic reprioritization.',
    `updated_by` STRING COMMENT 'Identifier or name of the user or system that last updated this assignment record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this assignment record was last modified, reflecting changes to scope, status, or analyst details.',
    `valuation_methodology` STRING COMMENT 'Primary valuation methodology or approach required for this assignment, such as Discounted Cash Flow (DCF), comparable company analysis, or Net Asset Value (NAV) modeling.',
    `created_by` STRING COMMENT 'Identifier or name of the user or system that created this assignment record.',
    CONSTRAINT pk_analyst_assignment PRIMARY KEY(`analyst_assignment_id`)
) COMMENT 'Transactional record of research analyst assignments to coverage entities (issuers, sectors, geographies, asset classes) within the research coverage universe.';

CREATE OR REPLACE TABLE `asset_management`.`research`.`ic_research_pack` (
    `ic_research_pack_id` BIGINT COMMENT 'Unique identifier for the Investment Committee research package record.',
    `due_diligence_id` BIGINT COMMENT 'Foreign key linking to esg.due_diligence. Business justification: IC investment decision packs must incorporate formal ESG due diligence findings. Pension fund governance requires IC members to review ESG assessments before approval.',
    `economic_scenario_id` BIGINT COMMENT 'Reference to the macroeconomic scenario or stress test scenario used in the investment analysis.',
    `employee_id` BIGINT COMMENT 'Reference to the primary investment analyst or research professional responsible for preparing this research pack.',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: IC research packs for manager selection/re-up decisions must identify the GP under evaluation. Core to Investment Committee manager approval workflow required by pension fund governance.',
    `ic_employee_id` BIGINT COMMENT 'Reference to the primary investment analyst or research professional responsible for preparing this research pack.',
    `ic_meeting_id` BIGINT COMMENT 'Reference to the Investment Committee meeting for which this research pack was prepared.',
    `ic_peer_reviewer_employee_id` BIGINT COMMENT 'Reference to the senior analyst or investment professional who conducted the peer review.',
    `manager_mandate_id` BIGINT COMMENT 'Foreign key linking to manager.manager_mandate. Business justification: IC packs for mandate renewals/amendments must reference the specific mandate under review. Essential for mandate lifecycle governance and IC decision tracking.',
    `opportunity_id` BIGINT COMMENT 'Reference to the investment opportunity or deal that this research pack supports.',
    `peer_reviewer_employee_id` BIGINT COMMENT 'Reference to the senior analyst or investment professional who conducted the peer review.',
    `asset_class` STRING COMMENT 'Primary asset class category of the investment opportunity covered by this research pack. [ENUM-REF-CANDIDATE: public_equity|private_equity|real_estate|infrastructure|natural_resources|credit|fixed_income|multi_asset — 8 candidates stripped; promote to',
    `commitment_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the recommended commitment amount.. Valid values are `^[A-Z]{3}$`',
    `confidentiality_level` STRING COMMENT 'Data classification level governing access and distribution of this research pack.. Valid values are `public|internal|confidential|restricted`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this research pack record was first created in the system.',
    `decision_date` DATE COMMENT 'Date on which the Investment Committee rendered its formal decision on this research pack.',
    `decision_rationale` STRING COMMENT 'Summary of the Investment Committees reasoning and key considerations underlying the decision.',
    `distribution_list` STRING COMMENT 'Authorized recipients or distribution groups for this research pack (e.g., IC members, senior management, deal team).',
    `document_version` STRING COMMENT 'Version number or identifier of the research pack document for change control and audit purposes.',
    `due_diligence_status` STRING COMMENT 'Overall status of the due diligence process supporting this research pack.. Valid values are `not_started|in_progress|completed|pending_items|waived`',
    `esg_integration_summary` STRING COMMENT 'Summary of how ESG factors have been integrated into the investment analysis and decision-making process.',
    `esg_rating` STRING COMMENT 'ESG rating or score assigned to the investment opportunity based on responsible investment assessment. [ENUM-REF-CANDIDATE: AAA|AA|A|BBB|BB|B|CCC|not_rated — 8 candidates stripped; promote to reference product]',
    `fair_value_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the fair value estimate.. Valid values are `^[A-Z]{3}$`',
    `fair_value_estimate` DECIMAL(18,2) COMMENT 'Estimated fair value or enterprise value of the investment opportunity derived from valuation analysis.',
    `file_path` STRING COMMENT 'Storage location or URI of the research pack document in the enterprise document management system.',
    `geographic_focus` STRING COMMENT 'Primary geographic region or country focus of the investment opportunity (e.g., North America, Europe, Asia-Pacific, Global).',
    `ic_decision` STRING COMMENT 'Final decision outcome rendered by the Investment Committee on the investment proposal contained in this research pack.. Valid values are `approved|rejected|deferred|conditional_approval|withdrawn`',
    `ic_meeting_date` DATE COMMENT 'Scheduled date of the Investment Committee meeting at which this research pack is or was presented.',
    `investment_horizon_years` BIGINT COMMENT 'Expected holding period or investment horizon expressed in years.',
    `investment_strategy` STRING COMMENT 'Specific investment strategy or sub-strategy within the asset class (e.g., growth equity, value-add real estate, core infrastructure).',
    `investment_thesis` STRING COMMENT 'Core investment thesis and value creation hypothesis articulated in the research pack.',
    `key_risks_identified` STRING COMMENT 'Summary of the principal investment risks identified during due diligence and research analysis.',
    `mitigation_strategies` STRING COMMENT 'Proposed strategies and actions to mitigate identified investment risks.',
    `pack_reference_number` STRING COMMENT 'Business identifier or document control number assigned to this research pack for tracking and citation purposes.',
    `pack_title` STRING COMMENT 'Formal title of the research package as presented to the Investment Committee.',
    `pack_type` STRING COMMENT 'Classification of the research pack by its purpose: new investment, follow-on capital, divestment recommendation, portfolio review, strategic asset allocation, or external manager selection.. Valid values are `new_investment|follow_on|divestment|portfolio_review|strategic_allocation|manager_selection`',
    `page_count` BIGINT COMMENT 'Total number of pages in the research pack document.',
    `peer_review_status` STRING COMMENT 'Status of internal peer review or quality assurance review of the research pack prior to Investment Committee submission.. Valid values are `not_required|pending|in_progress|completed|approved|rejected`',
    `recommended_commitment_amount` DECIMAL(18,2) COMMENT 'Proposed capital commitment amount recommended to the Investment Committee in the base currency.',
    `research_team` STRING COMMENT 'Name or identifier of the research team or investment team that prepared the research pack.',
    `revision_date` DATE COMMENT 'Date of the most recent revision or update to the research pack.',
    `revision_notes` STRING COMMENT 'Summary of changes or updates made in the current version of the research pack.',
    `risk_rating` STRING COMMENT 'Overall risk assessment rating assigned to the investment opportunity based on due diligence and analysis.. Valid values are `low|medium|high|very_high`',
    `sector_focus` STRING COMMENT 'Industry sector or sectors targeted by the investment opportunity (e.g., technology, healthcare, energy, financials).',
    `submission_date` DATE COMMENT 'Date on which the research pack was formally submitted to the Investment Committee for review.',
    `submission_status` STRING COMMENT 'Current lifecycle status of the research pack in the Investment Committee approval workflow. [ENUM-REF-CANDIDATE: draft|submitted|under_review|approved|rejected|deferred|withdrawn — 7 candidates stripped; promote to reference product]',
    `target_irr` DECIMAL(5,2) COMMENT 'Target net Internal Rate of Return expressed as a percentage that the investment is expected to achieve.',
    `target_moic` DECIMAL(5,2) COMMENT 'Target Multiple on Invested Capital representing the expected total value multiple relative to invested capital.',
    `updated_by` STRING COMMENT 'User identifier or name of the individual who last updated this research pack record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this research pack record.',
    `valuation_methodology` STRING COMMENT 'Primary valuation approach or methodology employed in the investment analysis (e.g., DCF, comparable transactions, NAV).',
    `created_by` STRING COMMENT 'User identifier or name of the individual who created this research pack record.',
    CONSTRAINT pk_ic_research_pack PRIMARY KEY(`ic_research_pack_id`)
) COMMENT 'Master record of research packages formally prepared and submitted to the Investment Committee (IC) in support of investment decisions. Captures IC meeting reference, investment opportunity reference, pack type (new investment, follow-on, divestment';

CREATE OR REPLACE TABLE `asset_management`.`research`.`market_consensus` (
    `market_consensus_id` BIGINT COMMENT 'Unique identifier for the market consensus record.',
    `listed_security_id` BIGINT COMMENT 'Reference to the security or instrument for which consensus estimates are collected.',
    `macro_indicator_id` BIGINT COMMENT 'Reference to the macroeconomic indicator for which consensus forecasts are collected.',
    `superseded_by_consensus_market_consensus_id` BIGINT COMMENT 'Reference to the newer consensus record that supersedes this estimate.',
    `adjustment_rationale` STRING COMMENT 'Explanation of the rationale for any proprietary adjustment applied to the consensus estimate.',
    `analyst_count` BIGINT COMMENT 'Number of analysts contributing estimates to the consensus calculation.',
    `approval_status` STRING COMMENT 'Current approval status of the consensus estimate within internal governance workflows.. Valid values are `draft|pending_review|approved|rejected|superseded`',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the consensus estimate was approved for use.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual who approved the consensus estimate for use.',
    `asset_class` STRING COMMENT 'Asset class to which the consensus estimate applies. [ENUM-REF-CANDIDATE: public_equity|private_equity|fixed_income|real_estate|infrastructure|natural_resources|credit|macro — 8 candidates stripped; promote to reference product]',
    `benchmark_comparison` DECIMAL(10,4) COMMENT 'Variance of the consensus estimate relative to a relevant benchmark or index, expressed as a percentage.',
    `buy_count` BIGINT COMMENT 'Number of analysts with a buy or strong buy recommendation.',
    `collection_timestamp` TIMESTAMP COMMENT 'Date and time when the consensus estimate was collected from the external data provider.',
    `confidence_level` DECIMAL(5,2) COMMENT 'Statistical confidence level associated with the consensus estimate, expressed as a percentage.',
    `consensus_identifier` STRING COMMENT 'External identifier or ticker symbol used by the data provider to uniquely identify this consensus estimate.',
    `consensus_rating` STRING COMMENT 'Aggregated analyst recommendation rating for the security.. Valid values are `strong_buy|buy|hold|underperform|sell`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the market consensus record was first created in the system.',
    `data_quality_flag` BOOLEAN COMMENT 'Indicator of the quality and reliability of the consensus data.',
    `data_source` STRING COMMENT 'External data provider or aggregator from which the consensus estimate was sourced.. Valid values are `bloomberg|factset|refinitiv|sell_side_aggregator|proprietary`',
    `effective_date` DATE COMMENT 'Date from which the consensus estimate is considered valid and applicable.',
    `estimate_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the consensus estimate is denominated.. Valid values are `^[A-Z]{3}$`',
    `estimate_type` STRING COMMENT 'Type of consensus estimate being captured (e.g., earnings per share, revenue, EBITDA, target price, macroeconomic indicator). [ENUM-REF-CANDIDATE: eps|revenue|ebitda|target_price|gdp|inflation|interest_rate|unemployment|credit_spread|fx_rate — 10',
    `fiscal_quarter` BIGINT COMMENT 'Fiscal quarter to which the consensus estimate applies (1-4).',
    `fiscal_year` BIGINT COMMENT 'Fiscal year to which the consensus estimate applies.',
    `forecast_period` STRING COMMENT 'Time period to which the consensus estimate applies (e.g., Q1 2024, FY 2025, 12M forward).',
    `geographic_scope` STRING COMMENT 'Three-letter ISO country code indicating the geographic region to which the consensus estimate applies.. Valid values are `^[A-Z]{3}$`',
    `high_estimate` DECIMAL(20,6) COMMENT 'Highest analyst estimate for the specified metric and period.',
    `hold_count` BIGINT COMMENT 'Number of analysts with a hold recommendation.',
    `ic_submission_flag` BOOLEAN COMMENT 'Indicates whether this consensus estimate was included in an Investment Committee presentation or submission.',
    `last_revision_date` DATE COMMENT 'Date of the most recent revision to the consensus estimate.',
    `low_estimate` DECIMAL(20,6) COMMENT 'Lowest analyst estimate for the specified metric and period.',
    `mean_estimate` DECIMAL(20,6) COMMENT 'Arithmetic mean of all analyst estimates for the specified metric and period.',
    `median_estimate` DECIMAL(20,6) COMMENT 'Median value of all analyst estimates for the specified metric and period.',
    `notes` STRING COMMENT 'Additional notes or commentary regarding the consensus estimate, data quality, or usage considerations.',
    `proprietary_adjustment` DECIMAL(20,6) COMMENT 'Internal adjustment applied to the external consensus estimate based on proprietary research or modeling.',
    `revision_direction` STRING COMMENT 'Direction of the most recent revision to the consensus estimate relative to the prior period.. Valid values are `up|down|unchanged|new`',
    `revision_magnitude` DECIMAL(10,4) COMMENT 'Magnitude of the most recent revision to the consensus estimate, expressed as a percentage change.',
    `sector_classification` STRING COMMENT 'Industry sector classification of the security or indicator (e.g., GICS, ICB).',
    `sell_count` BIGINT COMMENT 'Number of analysts with a sell or underperform recommendation.',
    `stale_threshold_days` BIGINT COMMENT 'Number of days after which the consensus estimate is considered stale and requires refresh.',
    `standard_deviation` DECIMAL(20,6) COMMENT 'Standard deviation of analyst estimates, indicating dispersion and consensus strength.',
    `unit_of_measure` STRING COMMENT 'Unit in which the estimate is expressed (e.g., millions, billions, percentage, basis points, per share).',
    `updated_by` STRING COMMENT 'Identifier of the user or system process that last updated the market consensus record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when the market consensus record was last modified.',
    `usage_context` STRING COMMENT 'Business context or use case for which the consensus estimate is intended (e.g., portfolio construction, IC presentation, risk stress testing).',
    `created_by` STRING COMMENT 'Identifier of the user or system process that created the market consensus record.',
    CONSTRAINT pk_market_consensus PRIMARY KEY(`market_consensus_id`)
) COMMENT 'Transactional records of external market consensus estimates and forecasts collected from Bloomberg, FactSet, and sell-side aggregators for key macroeconomic indicators and security-level metrics (EPS, revenue, EBITDA, target price).';

CREATE OR REPLACE TABLE `asset_management`.`research`.`research_yield_curve` (
    `research_yield_curve_id` BIGINT COMMENT 'Unique identifier for the yield curve definition tracked by the research team.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: Yield curves are defined for specific economic scenarios; linking to economic_scenario provides scenario context and does not create a bidirectional conflict.',
    `asset_class` STRING COMMENT 'Primary asset class to which this yield curve applies.. Valid values are `fixed_income|credit|derivatives|structured_products`',
    `benchmark_flag` BOOLEAN COMMENT 'Indicates whether this curve is used as a benchmark for valuation and risk modeling across portfolios.',
    `business_owner_name` STRING COMMENT 'Name of the business owner or senior analyst accountable for the use and accuracy of this yield curve.',
    `compounding_frequency` STRING COMMENT 'Frequency at which interest is compounded for yield calculations on the curve.. Valid values are `annual|semi_annual|quarterly|monthly|continuous`',
    `country_code` STRING COMMENT 'Three-letter ISO 3166 country code for the sovereign or primary jurisdiction of the curve.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this yield curve definition record was first created in the research system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the yield curve denomination.. Valid values are `^[A-Z]{3}$`',
    `curve_code` STRING COMMENT 'Standardized code or ticker symbol for the yield curve used in market data systems and research models.',
    `curve_name` STRING COMMENT 'Human-readable name of the yield curve (e.g., US Treasury Curve, UK Gilt Curve, SOFR Swap Curve).',
    `curve_status` STRING COMMENT 'Current lifecycle status of the yield curve definition in the research library.. Valid values are `active|inactive|deprecated|under_review`',
    `curve_type` STRING COMMENT 'Classification of the yield curve by instrument category.. Valid values are `sovereign|swap|credit_spread|corporate|municipal|agency`',
    `data_classification_level` STRING COMMENT 'Confidentiality classification level for the yield curve data.. Valid values are `public|internal|confidential|restricted`',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Quantitative score (0-100) representing the completeness, accuracy, and timeliness of the yield curve data.',
    `data_source_identifier` STRING COMMENT 'Vendor-specific identifier or ticker used to retrieve the yield curve from the data source.',
    `data_steward_name` STRING COMMENT 'Name of the individual or team responsible for maintaining and validating this yield curve definition.',
    `day_count_convention` STRING COMMENT 'Day count convention used for calculating accrued interest and yield on the curve.. Valid values are `ACT_360|ACT_365|30_360|ACT_ACT`',
    `effective_date` DATE COMMENT 'Date from which this yield curve definition became active and available for use in research and modeling.',
    `expiry_date` DATE COMMENT 'Date on which this yield curve definition is no longer active or was superseded by a new definition.',
    `extrapolation_method` STRING COMMENT 'Method used to extrapolate rates beyond the longest observed tenor.. Valid values are `flat|linear|exponential|none`',
    `ic_presentation_flag` BOOLEAN COMMENT 'Indicates whether this yield curve is included in Investment Committee presentation materials.',
    `interpolation_method` STRING COMMENT 'Mathematical method used to interpolate rates between observed tenors on the yield curve.. Valid values are `linear|cubic_spline|nelson_siegel|svensson|hermite`',
    `issuer_type` STRING COMMENT 'Type of issuer for the securities underlying the yield curve.. Valid values are `sovereign|supranational|corporate|financial|municipal|agency`',
    `last_update_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent data refresh for this yield curve.',
    `model_integration_flag` BOOLEAN COMMENT 'Indicates whether this yield curve is integrated into proprietary macroeconomic or valuation models.',
    `notes` STRING COMMENT 'Free-text field for additional context, methodology notes, or special considerations for this yield curve.',
    `primary_data_source` STRING COMMENT 'Primary vendor or system from which the yield curve data is sourced.. Valid values are `bloomberg|factset|refinitiv|ice|markit|internal`',
    `rating_category` STRING COMMENT 'Credit rating bucket for credit spread curves, representing the average rating of underlying securities. [ENUM-REF-CANDIDATE: AAA|AA|A|BBB|BB|B|CCC|unrated — 8 candidates stripped; promote to reference product]',
    `regulatory_compliance_scope` STRING COMMENT 'Regulatory frameworks and standards this yield curve must comply with (e.g., IFRS 13, GIPS, MiFID II).',
    `risk_free_rate_proxy_flag` BOOLEAN COMMENT 'Indicates whether this curve is used as a proxy for the risk-free rate in WACC and DCF calculations.',
    `spread_over_benchmark_bps` DECIMAL(10,2) COMMENT 'Average spread in basis points over the benchmark sovereign curve, applicable for credit spread curves.',
    `tenor_range_max_years` DECIMAL(10,4) COMMENT 'Longest maturity tenor available on the yield curve, expressed in years.',
    `tenor_range_min_years` DECIMAL(10,4) COMMENT 'Shortest maturity tenor available on the yield curve, expressed in years.',
    `update_frequency` STRING COMMENT 'Frequency at which the yield curve data is refreshed from the source.. Valid values are `real_time|intraday|daily|weekly|monthly`',
    `updated_by` STRING COMMENT 'User or system identifier of the individual who last modified this yield curve definition record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this yield curve definition record was last modified.',
    `usage_context` STRING COMMENT 'Description of the primary use cases for this yield curve within the organization (e.g., DCF valuation, risk stress testing, ALM).',
    `validation_status` STRING COMMENT 'Status of the most recent data quality validation check for this yield curve.. Valid values are `validated|pending_review|failed|not_validated`',
    `validation_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent data quality validation check.',
    `created_by` STRING COMMENT 'User or system identifier of the individual who created this yield curve definition record.',
    CONSTRAINT pk_research_yield_curve PRIMARY KEY(`research_yield_curve_id`)
) COMMENT 'Master record of yield curve definitions tracked by the research team across sovereign and credit markets, including government yield curves (US Treasury, UK Gilts, German Bunds), swap curves (SOFR, SONIA), and credit spread curves by rating bucket (IG';

CREATE OR REPLACE TABLE `asset_management`.`research`.`yield_curve_point` (
    `yield_curve_point_id` BIGINT COMMENT 'Unique identifier for the yield curve point observation record.',
    `credit_yield_curve_id` BIGINT COMMENT 'Reference to the parent yield curve definition to which this point belongs.',
    `economic_scenario_id` BIGINT COMMENT 'Reference to the economic scenario under which this yield curve point was generated or applies.',
    `market_data_feed_id` BIGINT COMMENT 'Reference to the market data feed configuration that delivered this observation.',
    `superseded_by_yield_curve_point_id` BIGINT COMMENT 'Reference to the yield curve point record that supersedes this one, if this record has been corrected or revised.',
    `approval_status` STRING COMMENT 'The approval status of this yield curve point for use in production analytics and reporting.. Valid values are `draft|pending|approved|rejected`',
    `approval_timestamp` TIMESTAMP COMMENT 'The timestamp when this yield curve point was approved for production use.',
    `approved_by` STRING COMMENT 'The name or identifier of the person who approved this yield curve point for production use.',
    `benchmark_reference` STRING COMMENT 'The benchmark rate or index this yield curve is based on (e.g., SOFR, LIBOR, Treasury, Swap).',
    `compounding_frequency` STRING COMMENT 'The compounding frequency for the yield calculation (e.g., annual, semi-annual, quarterly, continuous).. Valid values are `annual|semi_annual|quarterly|monthly|continuous`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this yield curve point record was first created in the system.',
    `credit_rating` STRING COMMENT 'The credit rating category for corporate or sovereign curves (e.g., AAA, AA, A, BBB, BB, B).',
    `currency_code` STRING COMMENT 'The three-letter ISO 4217 currency code for the yield curve (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `curve_type` STRING COMMENT 'The type of yield curve this point belongs to: zero-coupon, par, forward, or discount factor curve.. Valid values are `zero|par|forward|discount`',
    `data_quality_flag` BOOLEAN COMMENT 'Indicates the quality status of this data point: verified, unverified, stale, suspect, or corrected.',
    `data_source` STRING COMMENT 'The vendor or system that provided this yield curve point (e.g., Bloomberg, FactSet, internal model).',
    `data_steward_name` STRING COMMENT 'The name of the data steward or team responsible for the quality and governance of this yield curve point.',
    `day_count_convention` STRING COMMENT 'The day count convention used for yield calculation (e.g., ACT/360, ACT/365, 30/360, ACT/ACT).. Valid values are `ACT/360|ACT/365|30/360|ACT/ACT`',
    `discount_factor` DECIMAL(18,12) COMMENT 'The discount factor at this tenor, used for present value calculations in fixed income analytics.',
    `effective_date` DATE COMMENT 'The date from which this yield curve point becomes effective for use in valuation and risk calculations.',
    `expiry_date` DATE COMMENT 'The date after which this yield curve point is no longer valid or should not be used.',
    `forward_rate` DECIMAL(12,8) COMMENT 'The implied forward rate starting at this tenor, derived from the yield curve structure.',
    `geographic_scope` STRING COMMENT 'The three-letter ISO country code representing the geographic market for this yield curve (e.g., USA, GBR, CAN).. Valid values are `^[A-Z]{3}$`',
    `interpolation_method` STRING COMMENT 'The mathematical method used to interpolate this point if not directly observed (e.g., linear, cubic spline, Nelson-Siegel).. Valid values are `linear|cubic_spline|nelson_siegel|hermite`',
    `is_active` BOOLEAN COMMENT 'Indicates whether this yield curve point is currently active and should be used in calculations and analytics.',
    `is_interpolated` BOOLEAN COMMENT 'Indicates whether this yield curve point was interpolated (True) or directly observed (False).',
    `is_regulatory_required` BOOLEAN COMMENT 'Indicates whether this yield curve point is required for regulatory reporting or compliance purposes.',
    `market_segment` STRING COMMENT 'The market segment this yield curve represents: government, corporate, municipal, sovereign, or swap market.. Valid values are `government|corporate|municipal|sovereign|swap`',
    `notes` STRING COMMENT 'Free-text notes providing additional context, methodology details, or special considerations for this yield curve point.',
    `observation_date` DATE COMMENT 'The date on which this yield curve point was observed or published.',
    `observation_timestamp` TIMESTAMP COMMENT 'The precise timestamp when this yield curve point was observed or published by the source.',
    `quote_type` STRING COMMENT 'The type of market quote: mid, bid, ask, close, or open price.. Valid values are `mid|bid|ask|close|open`',
    `regulatory_framework` STRING COMMENT 'The regulatory framework or standard this yield curve point supports (e.g., IFRS 9, Basel III, SEC).',
    `source_identifier` STRING COMMENT 'The unique identifier or ticker symbol from the source system (e.g., Bloomberg ticker, FactSet ID).',
    `spread_bps` DECIMAL(10,2) COMMENT 'The spread over a benchmark rate (e.g., SOFR, Treasury) at this tenor, expressed in basis points.',
    `stress_test_flag` BOOLEAN COMMENT 'Indicates whether this yield curve point is part of a stress testing or scenario analysis exercise.',
    `tenor` STRING COMMENT 'The maturity tenor of this yield curve point (e.g., 3M, 6M, 1Y, 2Y, 5Y, 10Y, 20Y, 30Y). [ENUM-REF-CANDIDATE: 1M|3M|6M|9M|1Y|2Y|3Y|5Y — 8 candidates stripped; promote to reference product]',
    `tenor_days` BIGINT COMMENT 'The tenor expressed in calendar days for precise calculation and interpolation.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this yield curve point record was last modified or updated.',
    `usage_context` STRING COMMENT 'The business context or purpose for which this yield curve point is used (e.g., valuation, risk, stress testing, IC presentation).',
    `validation_notes` STRING COMMENT 'Free-text notes documenting validation issues, corrections, or manual review findings.',
    `validation_status` STRING COMMENT 'The validation status of this yield curve point after quality checks and business rule validation.. Valid values are `passed|failed|pending|manual_review`',
    `version_number` BIGINT COMMENT 'The version number of this yield curve point, incremented when corrections or revisions are published.',
    `yield_bps` DECIMAL(10,2) COMMENT 'The observed yield expressed in basis points for fixed income analytics (e.g., 325 bps for 3.25%).',
    `yield_rate` DECIMAL(12,8) COMMENT 'The observed yield or interest rate at this tenor, expressed as a decimal (e.g., 0.0325 for 3.25%).',
    CONSTRAINT pk_yield_curve_point PRIMARY KEY(`yield_curve_point_id`)
) COMMENT 'Transactional time-series records of yield curve data points at specific tenors and observation dates. Captures yield curve reference, tenor (3M, 6M, 1Y, 2Y, 5Y, 10Y, 20Y, 30Y), observed yield or spread (bps), observation date, and data source.';

CREATE OR REPLACE TABLE `asset_management`.`research`.`research_fx_rate` (
    `research_fx_rate_id` BIGINT COMMENT 'Unique identifier for the foreign exchange rate record.',
    `market_data_feed_id` BIGINT COMMENT 'Foreign key reference to the market data feed configuration that delivered this FX rate observation.',
    `ask_rate` DECIMAL(18,8) COMMENT 'The rate at which the market is willing to sell the base currency, expressed in quote currency units.',
    `base_currency` STRING COMMENT 'Three-letter ISO code for the base currency in the currency pair.. Valid values are `^[A-Z]{3}$`',
    `benchmark_rate_flag` BOOLEAN COMMENT 'Indicates whether this FX rate is designated as the official benchmark rate used for portfolio valuation and Net Asset Value (NAV) calculation.',
    `bid_ask_spread_bps` DECIMAL(10,4) COMMENT 'The difference between the ask rate and bid rate expressed in basis points, indicating market liquidity and transaction cost.',
    `bid_rate` DECIMAL(18,8) COMMENT 'The rate at which the market is willing to buy the base currency, expressed in quote currency units.',
    `central_bank_rate_flag` BOOLEAN COMMENT 'Indicates whether this rate is sourced directly from a central bank official fixing or reference rate.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this FX rate record was first created in the lakehouse silver layer.',
    `cross_rate_calculation_method` STRING COMMENT 'Description of the methodology used to derive cross rates when direct market quotes are unavailable, ensuring transparency in valuation.',
    `currency_pair` STRING COMMENT 'The foreign exchange currency pair in ISO format, representing base currency and quote currency (e.g., USD/JPY, EUR/USD).. Valid values are `^[A-Z]{3}/[A-Z]{3}$`',
    `data_lineage_reference` STRING COMMENT 'Identifier or reference linking this FX rate observation to its upstream source system batch or feed ingestion event for audit trail purposes.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Automated quality score assigned to the FX rate observation based on timeliness, completeness, and consistency checks, expressed as a percentage.',
    `fixing_time` TIMESTAMP COMMENT 'The standardized time of day when the official FX fixing rate is published, in HH:MM format (e.g., 16:00 for WMR 4pm London fix).',
    `forward_points` DECIMAL(12,6) COMMENT 'The adjustment added to or subtracted from the spot rate to calculate the forward rate, reflecting interest rate differentials between currencies.',
    `forward_rate` DECIMAL(18,8) COMMENT 'The agreed-upon exchange rate for a currency transaction that will occur at a future date, used for hedging FX risk.',
    `forward_tenor` STRING COMMENT 'The time period until the forward contract settlement date, expressed in standard market convention (e.g., 1M, 3M, 6M, 1Y).. Valid values are `^(ON|TN|SN|[0-9]{1,3}[DWMY])$`',
    `hedging_eligible_flag` BOOLEAN COMMENT 'Indicates whether this currency pair is approved for use in the funds foreign exchange hedging program.',
    `implied_volatility` DECIMAL(8,4) COMMENT 'The market-implied volatility derived from FX option prices, used for risk modeling and hedging strategy.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this FX rate record was last refreshed or modified in the research data repository.',
    `liquidity_tier` STRING COMMENT 'Classification of the currency pair based on market liquidity and trading volume, used for risk assessment and execution strategy.. Valid values are `tier_1|tier_2|tier_3|emerging|exotic`',
    `mid_rate` DECIMAL(18,8) COMMENT 'The midpoint between the bid and ask rates, commonly used for valuation and performance measurement purposes.',
    `notes` STRING COMMENT 'Free-text field for capturing additional context, exceptions, or manual adjustments related to this FX rate observation.',
    `outlier_flag` BOOLEAN COMMENT 'Indicates whether the FX rate observation was flagged as a statistical outlier requiring manual review before use in valuation.',
    `quote_convention` STRING COMMENT 'The market convention used for quoting the currency pair, indicating whether it follows direct, indirect, or cross-rate methodology.. Valid values are `direct|indirect|cross`',
    `quote_currency` STRING COMMENT 'Three-letter ISO code for the quote currency in the currency pair.. Valid values are `^[A-Z]{3}$`',
    `rate_source` STRING COMMENT 'The originating system or vendor that provided the FX rate data (e.g., Bloomberg Terminal, FactSet, internal treasury system). [ENUM-REF-CANDIDATE: bloomberg|factset|reuters|treasury_system|central_bank|broker|internal_model — 7 candidates stripped',
    `rate_source_identifier` STRING COMMENT 'The specific ticker, code, or reference identifier used by the source system to uniquely identify this FX rate feed.',
    `rate_status` STRING COMMENT 'Current status of the FX rate record indicating data quality and usability for valuation and risk calculations.. Valid values are `active|stale|indicative|verified|rejected`',
    `rate_timestamp` TIMESTAMP COMMENT 'Precise date and time when the FX rate was observed or captured from the market data feed.',
    `rate_type` STRING COMMENT 'Classification of the FX rate indicating whether it is a spot rate, forward rate, swap rate, or cross rate.. Valid values are `spot|forward|swap|cross`',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this FX rate is designated for use in regulatory reporting submissions to SEC, or other governing bodies.',
    `settlement_date` DATE COMMENT 'The date on which the currency exchange transaction is scheduled to settle and funds are exchanged.',
    `spot_rate` DECIMAL(18,8) COMMENT 'The current market exchange rate for immediate delivery, expressed as units of quote currency per one unit of base currency.',
    `trading_session` STRING COMMENT 'The geographic trading session or market center during which the FX rate was observed.. Valid values are `london|new_york|tokyo|sydney|hong_kong|continuous`',
    `usage_context` STRING COMMENT 'The primary business use case for which this FX rate observation is intended, guiding appropriate application across investment processes.. Valid values are `valuation|trading|hedging|reporting|stress_testing|scenario_analysis`',
    `volatility_30d` DECIMAL(8,4) COMMENT 'The annualized historical volatility of the currency pair over the trailing 30-day period, expressed as a percentage.',
    CONSTRAINT pk_research_fx_rate PRIMARY KEY(`research_fx_rate_id`)
) COMMENT 'Transactional records of foreign exchange (FX) spot and forward rates captured from Bloomberg and treasury systems for all currency pairs relevant to the funds global investment portfolio.';

CREATE OR REPLACE TABLE `asset_management`.`research`.`asset_class_outlook` (
    `asset_class_outlook_id` BIGINT COMMENT 'Unique identifier for the asset class outlook assessment record.',
    `asset_employee_id` BIGINT COMMENT 'Reference to the senior research analyst responsible for authoring and owning the outlook assessment.',
    `asset_peer_reviewer_employee_id` BIGINT COMMENT 'Reference to the senior analyst or research director who conducted the peer review of the outlook assessment.',
    `climate_scenario_id` BIGINT COMMENT 'Foreign key linking to esg.climate_scenario. Business justification: Asset class return projections must be scenario-aligned for climate risk integration. Pension funds producing climate-adjusted CMAs need to reference specific climate scenarios (1.5°C',
    `economic_scenario_id` BIGINT COMMENT 'Reference to the base macroeconomic scenario used for outlook projections and stress testing.',
    `employee_id` BIGINT COMMENT 'Reference to the senior research analyst responsible for authoring and owning the outlook assessment.',
    `peer_reviewer_employee_id` BIGINT COMMENT 'Reference to the senior analyst or research director who conducted the peer review of the outlook assessment.',
    `superseded_by_outlook_asset_class_outlook_id` BIGINT COMMENT 'Reference to the subsequent outlook assessment that supersedes this version, enabling version lineage tracking.',
    `allocation_delta_percentage` DECIMAL(8,4) COMMENT 'Recommended change in allocation percentage, calculated as target allocation minus current allocation.',
    `approval_date` DATE COMMENT 'Date when the outlook assessment received final approval from Investment Committee (IC) or designated authority.',
    `asset_class` STRING COMMENT 'Primary asset class covered by this outlook assessment, aligned with Strategic Asset Allocation (SAA) framework.. Valid values are `public_equities|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `climate_scenario_alignment` STRING COMMENT 'Assessment of asset class alignment with climate transition scenarios and net-zero pathways per Task Force on Climate-related Financial Disclosures (TCFD).',
    `confidence_level` STRING COMMENT 'Research team confidence in the outlook projections and investment view, reflecting data quality and forecast uncertainty.. Valid values are `high|medium|low`',
    `confidentiality_level` STRING COMMENT 'Data classification level governing access and distribution of the outlook assessment per information security policy.. Valid values are `public|internal|confidential|restricted`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the outlook assessment record was first created in the system.',
    `current_allocation_percentage` DECIMAL(8,4) COMMENT 'Current portfolio allocation percentage to the asset class at the time of outlook publication.',
    `data_sources` STRING COMMENT 'Primary data sources and market intelligence platforms used for outlook analysis, such as Bloomberg Terminal, FactSet, or Preqin.',
    `document_url` STRING COMMENT 'File path or URL to the full outlook assessment document, typically stored in document management system.',
    `effective_date` DATE COMMENT 'Date from which the outlook assessment becomes effective for portfolio construction and Strategic Asset Allocation (SAA) decisions.',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether Environmental, Social, and Governance (ESG) factors were formally integrated into the outlook assessment.',
    `esg_rating` STRING COMMENT 'Overall Environmental, Social, and Governance (ESG) rating for the asset class, using MSCI ESG rating scale. [ENUM-REF-CANDIDATE: AAA|AA|A|BBB|BB|B|CCC — 7 candidates stripped; promote to reference product]',
    `expected_return_percentage` DECIMAL(8,4) COMMENT 'Projected annualized return for the asset class over the outlook horizon, expressed as a percentage.',
    `expected_volatility_percentage` DECIMAL(8,4) COMMENT 'Projected annualized volatility (standard deviation of returns) for the asset class, expressed as a percentage.',
    `expiry_date` DATE COMMENT 'Date when the outlook assessment expires and is superseded by a subsequent outlook, nullable for open-ended outlooks.',
    `geographic_focus` STRING COMMENT 'Primary geographic regions or countries covered by the outlook assessment, using 3-letter ISO country codes or regional groupings.',
    `ic_decision` STRING COMMENT 'Investment Committee (IC) decision outcome following presentation and review of the outlook assessment.. Valid values are `approved|approved_with_conditions|rejected|deferred`',
    `ic_presentation_date` DATE COMMENT 'Date when the outlook assessment was presented to the Investment Committee (IC) for review and approval.',
    `ic_presentation_flag` BOOLEAN COMMENT 'Indicates whether the outlook assessment was formally presented to the Investment Committee (IC) for approval.',
    `investment_opportunities` STRING COMMENT 'Specific investment themes, strategies, or opportunities identified within the asset class for portfolio construction.',
    `investment_view` STRING COMMENT 'Overall investment stance recommended by the research team relative to Strategic Asset Allocation (SAA) benchmark weights.. Valid values are `overweight|neutral|underweight|avoid`',
    `key_drivers` STRING COMMENT 'Primary macroeconomic, market, and structural factors driving the outlook assessment and investment view.',
    `key_risks` STRING COMMENT 'Principal downside risks and uncertainties that could cause actual outcomes to deviate from the outlook projections.',
    `methodology_description` STRING COMMENT 'Summary of analytical methodology and modeling approach used to develop the outlook assessment and return projections.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal review and update of the outlook assessment.',
    `notes` STRING COMMENT 'Additional commentary, caveats, or contextual information relevant to the outlook assessment.',
    `outlook_horizon_years` BIGINT COMMENT 'Time horizon in years for which the outlook assessment provides forward-looking projections and investment recommendations.',
    `outlook_identifier` STRING COMMENT 'Business-readable identifier for the outlook assessment, typically combining asset class and publication period.',
    `outlook_status` STRING COMMENT 'Current lifecycle status of the outlook assessment within the research and approval workflow.. Valid values are `draft|under_review|approved|published|superseded|archived`',
    `peer_review_status` STRING COMMENT 'Status of internal peer review process for quality assurance and validation of outlook methodology and conclusions.. Valid values are `not_started|in_progress|completed|waived`',
    `publication_date` DATE COMMENT 'Date when the outlook assessment was formally published and made available to Investment Committee (IC) and portfolio managers.',
    `research_team` STRING COMMENT 'Name of the research team or division responsible for producing the outlook assessment.',
    `review_frequency_months` BIGINT COMMENT 'Scheduled frequency in months for updating and refreshing the outlook assessment, typically quarterly or semi-annually.',
    `sector_focus` STRING COMMENT 'Primary economic sectors or industries covered by the outlook assessment, using standard sector classification frameworks.',
    `sharpe_ratio` DECIMAL(8,4) COMMENT 'Risk-adjusted return metric calculated as excess return over risk-free rate divided by volatility.',
    `sub_asset_class` STRING COMMENT 'Granular sub-category within the primary asset class, such as Investment Grade (IG), High Yield (HY), or private credit for credit asset class.',
    `target_allocation_percentage` DECIMAL(8,4) COMMENT 'Recommended allocation percentage for the asset class within the total portfolio, aligned with Tactical Asset Allocation (TAA) framework.',
    `title` STRING COMMENT 'Formal title of the asset class outlook assessment as presented to Investment Committee (IC) and stakeholders.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the outlook assessment record was last modified, supporting audit trail and change tracking.',
    `valuation_assessment` STRING COMMENT 'Overall valuation judgment for the asset class relative to historical norms and fundamental fair value estimates.. Valid values are `expensive|fair_value|cheap|mixed`',
    `valuation_metric` STRING COMMENT 'Primary valuation metric used for assessment, such as Price-to-Earnings (P/E), Yield to Maturity (YTM), or Net Operating Income (NOI) yield.',
    `valuation_metric_value` DECIMAL(12,4) COMMENT 'Current value of the primary valuation metric at the time of outlook publication.',
    `version_number` STRING COMMENT 'Version identifier for the outlook assessment, supporting revision control and change tracking.',
    CONSTRAINT pk_asset_class_outlook PRIMARY KEY(`asset_class_outlook_id`)
) COMMENT 'Master record of formal asset class outlook assessments produced by the research team covering all asset classes in the funds SAA: public equities, private equity, real estate, infrastructure, natural resources, credit (IG, HY, private credit), and';

CREATE OR REPLACE TABLE `asset_management`.`research`.`capital_market_assumption` (
    `capital_market_assumption_id` BIGINT COMMENT 'Unique identifier for the capital market assumption record.',
    `climate_scenario_id` BIGINT COMMENT 'Foreign key linking to esg.climate_scenario. Business justification: Capital market assumptions used for SAA must incorporate climate transition impacts. Net-zero committed pension funds require CMAs calibrated to specific climate scenarios for',
    `superseded_by_assumption_id` BIGINT COMMENT 'Reference to the capital market assumption ID that supersedes this assumption, enabling version control and historical tracking of assumption evolution.',
    `approval_date` DATE COMMENT 'The date on which this capital market assumption was formally approved by the investment committee (IC) or designated authority for use in portfolio construction and modeling.',
    `approval_status` STRING COMMENT 'Current approval status of the capital market assumption within the governance workflow, indicating whether it is draft, pending review, approved for use, rejected, or superseded by a newer version.. Valid values are `draft|pending_review|approved|rejected|superseded`',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee that formally approved this capital market assumption for use in strategic asset allocation (SAA) and investment decision-making.',
    `asset_class` STRING COMMENT 'The asset class to which this capital market assumption applies, such as public equities, private equity, real estate, infrastructure, natural resources, or credit investments.. Valid values are `public_equities|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `assumption_code` STRING COMMENT 'Short code or identifier for the capital market assumption set, used for reference in investment committee (IC) materials and system integration.',
    `assumption_name` STRING COMMENT 'Descriptive name of the capital market assumption set used for strategic asset allocation (SAA) and asset-liability management (ALM) modeling.',
    `assumption_owner` STRING COMMENT 'Name or identifier of the research team member or analyst responsible for maintaining and updating this capital market assumption.',
    `assumption_type` STRING COMMENT 'Type of capital market assumption, such as expected return, volatility, correlation, risk premium, inflation, or interest rate projection.. Valid values are `expected_return|volatility|correlation|risk_premium|inflation|interest_rate`',
    `benchmark_reference` STRING COMMENT 'Reference to the market benchmark or index against which this capital market assumption is compared or calibrated, such as MSCI World, S&P 500, or Bloomberg Barclays Aggregate.',
    `calibration_date` DATE COMMENT 'The date on which the capital market assumption was calibrated or derived using historical data and forward-looking projections.',
    `climate_scenario_alignment` STRING COMMENT 'Reference to the climate scenario framework to which this capital market assumption is aligned, such as Task Force on Climate-related Financial Disclosures (TCFD) scenarios or Paris Agreement pathways.',
    `confidence_level` STRING COMMENT 'Qualitative assessment of the confidence level in the accuracy and reliability of this capital market assumption, based on data quality, model robustness, and market stability.. Valid values are `high|medium|low`',
    `correlation_coefficient` DECIMAL(5,4) COMMENT 'The expected correlation coefficient between this asset class and a reference benchmark or other asset classes, ranging from -1 to +1, used in portfolio diversification analysis.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp indicating when this capital market assumption record was first created in the system, supporting audit trail and data lineage requirements.',
    `currency_code` STRING COMMENT 'The three-letter ISO 4217 currency code in which the capital market assumption returns and values are denominated, such as USD, EUR, GBP, or JPY.. Valid values are `^[A-Z]{3}$`',
    `data_source` STRING COMMENT 'Primary data sources used to develop the capital market assumption, such as Bloomberg Terminal, FactSet, MSCI, or proprietary macroeconomic models.',
    `documentation_url` STRING COMMENT 'Uniform resource locator (URL) or file path to the detailed documentation, research report, or investment memorandum (IM) supporting this capital market assumption.',
    `effective_date` DATE COMMENT 'The date from which this capital market assumption becomes effective and is formally adopted for use in strategic asset allocation (SAA) and asset-liability management (ALM) modeling.',
    `esg_integration_flag` BOOLEAN COMMENT 'Boolean flag indicating whether environmental, social, and governance (ESG) factors were integrated into the development of this capital market assumption.',
    `expected_return_percentage` DECIMAL(10,4) COMMENT 'The long-term expected annualized return for the asset class or market segment, expressed as a percentage, used in strategic asset allocation (SAA) optimization.',
    `expected_volatility_percentage` DECIMAL(10,4) COMMENT 'The expected annualized standard deviation of returns, expressed as a percentage, representing the anticipated risk level for the asset class or market segment.',
    `expiry_date` DATE COMMENT 'The date on which this capital market assumption expires or is scheduled for review and potential revision, ensuring assumptions remain current and relevant.',
    `geographic_scope` STRING COMMENT 'Geographic region or market to which this assumption applies, such as global, developed markets, emerging markets, or specific country codes (ISO 3166-1 alpha-3).',
    `ic_presentation_date` DATE COMMENT 'The date on which this capital market assumption was presented to the investment committee (IC) for review, discussion, and approval.',
    `ic_presentation_flag` BOOLEAN COMMENT 'Boolean flag indicating whether this capital market assumption was presented to the investment committee (IC) for formal review and approval.',
    `inflation_assumption_percentage` DECIMAL(10,4) COMMENT 'The long-term expected inflation rate assumption, expressed as a percentage, used to calculate real returns and for liability-driven investment (LDI) modeling.',
    `last_review_date` DATE COMMENT 'The most recent date on which this capital market assumption was formally reviewed by the research team or investment committee (IC).',
    `methodology_description` STRING COMMENT 'Detailed description of the methodology and analytical approach used to derive the capital market assumption, including models, data sources, and calibration techniques.',
    `model_version` STRING COMMENT 'Version identifier of the proprietary macroeconomic or capital market model used to generate this assumption, enabling traceability and reproducibility.',
    `next_review_date` DATE COMMENT 'The scheduled date for the next formal review of this capital market assumption, ensuring timely updates to reflect changing market conditions.',
    `notes` STRING COMMENT 'Additional notes, comments, or qualitative observations related to this capital market assumption, including key assumptions, limitations, or contextual information.',
    `real_return_percentage` DECIMAL(10,4) COMMENT 'The expected return adjusted for inflation, expressed as a percentage, representing the purchasing power growth of the investment over the time horizon.',
    `review_frequency_months` BIGINT COMMENT 'The frequency in months at which this capital market assumption is scheduled for formal review and potential update by the research team.',
    `risk_free_rate_percentage` DECIMAL(10,4) COMMENT 'The assumed risk-free rate of return, typically based on government bond yields such as Treasury bills (T-Bills) or Secured Overnight Financing Rate (SOFR), expressed as a percentage.',
    `risk_premium_bps` BIGINT COMMENT 'The expected risk premium over the risk-free rate, expressed in basis points (bps), representing the additional return required for bearing investment risk.',
    `sector_scope` STRING COMMENT 'Economic sector or industry classification to which this assumption applies, using standard sector classification frameworks such as GICS or ICB.',
    `sharpe_ratio` DECIMAL(10,4) COMMENT 'The expected risk-adjusted return metric calculated as excess return over the risk-free rate divided by volatility, used to compare investment efficiency across asset classes.',
    `stress_testing_enabled` BOOLEAN COMMENT 'Boolean flag indicating whether this capital market assumption is enabled for use in macroeconomic stress testing and scenario analysis for risk management purposes.',
    `time_horizon_years` BIGINT COMMENT 'The projection time horizon in years for which this capital market assumption is applicable, typically aligned with strategic asset allocation (SAA) planning cycles.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp indicating when this capital market assumption record was last modified, supporting audit trail and change tracking requirements.',
    `usage_context` STRING COMMENT 'Description of the primary use cases and contexts in which this capital market assumption is applied, such as strategic asset allocation (SAA), asset-liability management (ALM), or actuarial liability matching.',
    `version_number` STRING COMMENT 'Version number or identifier for this capital market assumption, enabling tracking of revisions and updates over time.',
    CONSTRAINT pk_capital_market_assumption PRIMARY KEY(`capital_market_assumption_id`)
) COMMENT 'Master record of long-term capital market assumptions (CMAs) formally adopted by the research team for use in SAA optimization, ALM modeling, and actuarial liability matching.';

CREATE OR REPLACE TABLE `asset_management`.`research`.`calendar` (
    `calendar_id` BIGINT COMMENT 'Unique identifier for the research calendar entry.',
    `analyst_assignment_id` BIGINT COMMENT 'Foreign key reference to the analyst or researcher responsible for this calendar event.',
    `employee_id` BIGINT COMMENT 'Foreign key reference to the analyst or researcher responsible for this calendar event.',
    `macro_indicator_id` BIGINT COMMENT 'Foreign key reference to the macroeconomic indicator master record, if applicable.',
    `parent_event_calendar_id` BIGINT COMMENT 'Foreign key reference to the parent calendar entry for recurring events.',
    `research_report_id` BIGINT COMMENT 'Foreign key reference to the research report scheduled for publication on this date.',
    `actual_date` DATE COMMENT 'The date on which the event actually occurred, if different from scheduled.',
    `actual_end_time` TIMESTAMP COMMENT 'Precise timestamp when the event actually concluded.',
    `actual_start_time` TIMESTAMP COMMENT 'Precise timestamp when the event actually began.',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether the event requires formal approval before being finalized.',
    `approval_status` STRING COMMENT 'Current approval state of the calendar event.. Valid values are `pending|approved|rejected`',
    `approval_timestamp` TIMESTAMP COMMENT 'Timestamp when the event was approved.',
    `approved_by` STRING COMMENT 'Name or identifier of the person who approved the event.',
    `asset_class_relevance` STRING COMMENT 'Asset classes to which this event is most relevant, such as public equities, private equity, real estate, infrastructure, credit, or natural resources.',
    `attendee_count` BIGINT COMMENT 'Number of expected or actual attendees for the event.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this calendar entry was first created in the system.',
    `distribution_list` STRING COMMENT 'Comma-separated list of stakeholder groups or individuals who should receive information about this event.',
    `duration_minutes` BIGINT COMMENT 'Expected duration of the event in minutes.',
    `event_category` STRING COMMENT 'High-level grouping of the event for organizational and filtering purposes.. Valid values are `macroeconomic|market_data|research_publication|governance|external_event`',
    `event_description` STRING COMMENT 'Detailed narrative describing the purpose, scope, and content of the calendar event.',
    `event_identifier` STRING COMMENT 'Business-readable unique code or reference number for the calendar event.',
    `event_source` STRING COMMENT 'Origin or provider of the event information.. Valid values are `internal|external|bloomberg|factset|central_bank|regulatory_body`',
    `event_status` STRING COMMENT 'Current lifecycle state of the calendar event.. Valid values are `scheduled|confirmed|postponed|cancelled|completed`',
    `event_title` STRING COMMENT 'Descriptive title of the scheduled research event or publication.',
    `event_type` STRING COMMENT 'Classification of the calendar event indicating the nature of the scheduled activity. [ENUM-REF-CANDIDATE',
    `external_reference_code` STRING COMMENT 'Identifier from external systems such as Bloomberg or FactSet for cross-referencing.',
    `external_url` STRING COMMENT 'Web link to external event details or related documentation.',
    `geographic_scope` STRING COMMENT 'Geographic region or country to which the event is relevant, using 3-letter ISO country codes or regional identifiers.',
    `ic_meeting_date` DATE COMMENT 'Date of the Investment Committee meeting associated with this event.',
    `ic_presentation_flag` BOOLEAN COMMENT 'Indicates whether this event is an Investment Committee presentation.',
    `indicator_name` STRING COMMENT 'Name of the macroeconomic indicator being released, if applicable (e.g., CPI, GDP, unemployment rate).',
    `location` STRING COMMENT 'Physical or virtual location where the event takes place.',
    `notes` STRING COMMENT 'Additional free-text notes or comments about the event.',
    `notification_required_flag` BOOLEAN COMMENT 'Indicates whether stakeholders should be notified about this event.',
    `notification_sent_timestamp` TIMESTAMP COMMENT 'Timestamp when notification was sent to stakeholders.',
    `owner_team` STRING COMMENT 'Name of the research team or department responsible for the event.',
    `priority_level` STRING COMMENT 'Importance ranking of the event for research and investment decision-making.. Valid values are `critical|high|medium|low`',
    `recurrence_end_date` DATE COMMENT 'Date when the recurring event series is scheduled to end.',
    `recurrence_pattern` STRING COMMENT 'Frequency pattern for recurring events.. Valid values are `one_time|daily|weekly|monthly|quarterly|annually`',
    `scheduled_date` DATE COMMENT 'The date on which the event is planned to occur.',
    `scheduled_end_time` TIMESTAMP COMMENT 'Precise timestamp when the event is scheduled to conclude.',
    `scheduled_start_time` TIMESTAMP COMMENT 'Precise timestamp when the event is scheduled to begin.',
    `sector_relevance` STRING COMMENT 'Industry sectors or thematic areas to which the event applies.',
    `tags` STRING COMMENT 'Comma-separated keywords or labels for categorization and search.',
    `time_zone` STRING COMMENT 'Time zone in which the event is scheduled, using IANA time zone database identifiers.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this calendar entry was last modified.',
    `visibility_scope` STRING COMMENT 'Access level determining who can view this calendar entry.. Valid values are `public|internal|restricted|confidential`',
    CONSTRAINT pk_calendar PRIMARY KEY(`calendar_id`)
) COMMENT 'Master record of the research teams planned publication and event calendar, including scheduled macro indicator releases (e.g., CPI release dates, central bank meeting dates, earnings seasons), planned research report publication dates, IC presentation';

CREATE OR REPLACE TABLE `asset_management`.`research`.`data_vendor` (
    `data_vendor_id` BIGINT COMMENT 'Unique identifier for the external data vendor. Primary key.',
    `actor_id` BIGINT COMMENT 'Foreign key linking to shared.actor. Business justification: Data vendors are external legal entities requiring unified counterparty management. Linking to actor enables consolidated vendor risk assessment, contract management, and regulatory reporting',
    `kyc_record_id` BIGINT COMMENT 'Foreign key linking to compliance.kyc_record. Business justification: Pension funds must perform KYC on all counterparties including data vendors per AML regulations. Vendor onboarding requires KYC verification.',
    `annual_cost` DECIMAL(18,2) COMMENT 'Total annual cost of the vendor subscription or service agreement.',
    `asset_class_coverage` STRING COMMENT 'Comma-separated list of asset classes covered by the vendor data.',
    `auto_renewal_flag` BOOLEAN COMMENT 'Indicates whether the vendor contract automatically renews unless explicitly terminated.',
    `backup_vendor_available_flag` BOOLEAN COMMENT 'Indicates whether an alternative backup vendor is available for business continuity.',
    `business_owner_name` STRING COMMENT 'Name of the business owner or sponsor responsible for the vendor relationship.',
    `consuming_systems` STRING COMMENT 'Comma-separated list of internal systems that consume data from this vendor.',
    `contract_end_date` DATE COMMENT 'Date when the vendor contract or subscription is scheduled to expire or terminate.',
    `contract_renewal_date` DATE COMMENT 'Next scheduled date for contract renewal or renegotiation with the vendor.',
    `contract_start_date` DATE COMMENT 'Date when the vendor contract or subscription agreement became effective.',
    `cost_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the annual cost.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the vendor record was first created in the system.',
    `data_classification_level` STRING COMMENT 'Highest data classification level of the data provided by this vendor.. Valid values are `public|internal|confidential|restricted`',
    `data_coverage_scope` STRING COMMENT 'Description of the asset classes, geographies, or data domains covered by the vendor.',
    `data_delivery_method` STRING COMMENT 'Primary method by which the vendor delivers data to the organization.. Valid values are `api|sftp|file_transfer|terminal|direct_feed|web_portal`',
    `data_quality_sla_pct` DECIMAL(5,2) COMMENT 'Contractual data quality service level agreement expressed as a percentage.',
    `data_retention_period_days` BIGINT COMMENT 'Number of days the organization is contractually permitted to retain vendor data.',
    `data_steward_name` STRING COMMENT 'Name of the data steward responsible for managing data quality and governance for this vendor.',
    `delivery_frequency` STRING COMMENT 'Frequency at which the vendor provides data updates or refreshes.. Valid values are `real_time|intraday|daily|weekly|monthly|on_demand`',
    `documentation_url` STRING COMMENT 'URL or file path to the vendor contract, service documentation, or data dictionary.',
    `geographic_coverage` STRING COMMENT 'Geographic regions or countries covered by the vendor data feeds.',
    `last_vendor_review_date` DATE COMMENT 'Date of the most recent vendor performance or compliance review.',
    `lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the vendor, enabling global counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `next_vendor_review_date` DATE COMMENT 'Scheduled date for the next vendor performance or compliance review.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding the vendor relationship, service issues, or special considerations.',
    `notice_period_days` BIGINT COMMENT 'Number of days advance notice required to terminate or modify the vendor contract.',
    `primary_use_case` STRING COMMENT 'Primary business use case or purpose for which the vendor data is consumed.',
    `regulatory_compliance_scope` STRING COMMENT 'Regulatory frameworks or compliance requirements the vendor data supports.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the vendor record was last modified or updated.',
    `uptime_sla_pct` DECIMAL(5,2) COMMENT 'Contractual uptime or availability service level agreement expressed as a percentage.',
    `usage_based_pricing_flag` BOOLEAN COMMENT 'Indicates whether the vendor charges based on usage metrics rather than flat subscription fees.',
    `user_license_count` BIGINT COMMENT 'Number of user licenses or seats included in the vendor subscription agreement.',
    `vendor_code` STRING COMMENT 'Internal short code or abbreviation used to identify the vendor in operational systems.',
    `vendor_contact_email` STRING COMMENT 'Email address of the primary vendor contact for support and communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `vendor_contact_name` STRING COMMENT 'Primary contact person at the vendor organization for support and escalations.',
    `vendor_contact_phone` STRING COMMENT 'Phone number of the primary vendor contact for support and escalations.',
    `vendor_criticality` STRING COMMENT 'Business criticality rating of the vendor based on operational dependency and impact.. Valid values are `critical|high|medium|low`',
    `vendor_name` STRING COMMENT 'Full legal name of the data vendor organization as registered.',
    `vendor_performance_score` DECIMAL(5,2) COMMENT 'Quantitative performance score assigned to the vendor based on service quality metrics.',
    `vendor_status` STRING COMMENT 'Current lifecycle status of the vendor relationship.. Valid values are `active|inactive|suspended|under_review|terminated`',
    `vendor_support_tier` STRING COMMENT 'Level of support service contracted with the vendor.. Valid values are `standard|premium|enterprise|dedicated`',
    `vendor_type` STRING COMMENT 'Primary classification of the data vendor based on the type of data or service provided.. Valid values are `market_data|research|analytics|esg_ratings|index_provider|reference_data`',
    CONSTRAINT pk_data_vendor PRIMARY KEY(`data_vendor_id`)
) COMMENT 'Reference master of external market data and research data vendors contracted by the fund, including Bloomberg, FactSet, Preqin, PitchBook, MSCI, and Refinitiv.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ADD CONSTRAINT `fk_research_macro_indicator_observation_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ADD CONSTRAINT `fk_research_macro_indicator_observation_macro_indicator_id` FOREIGN KEY (`macro_indicator_id`) REFERENCES `asset_management`.`research`.`macro_indicator`(`macro_indicator_id`);
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ADD CONSTRAINT `fk_research_scenario_assumption_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ADD CONSTRAINT `fk_research_scenario_assumption_macro_indicator_id` FOREIGN KEY (`macro_indicator_id`) REFERENCES `asset_management`.`research`.`macro_indicator`(`macro_indicator_id`);
ALTER TABLE `asset_management`.`research`.`market_data_feed` ADD CONSTRAINT `fk_research_market_data_feed_data_vendor_id` FOREIGN KEY (`data_vendor_id`) REFERENCES `asset_management`.`research`.`data_vendor`(`data_vendor_id`);
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ADD CONSTRAINT `fk_research_market_data_snapshot_data_source_data_vendor_id` FOREIGN KEY (`data_source_data_vendor_id`) REFERENCES `asset_management`.`research`.`data_vendor`(`data_vendor_id`);
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ADD CONSTRAINT `fk_research_market_data_snapshot_data_vendor_id` FOREIGN KEY (`data_vendor_id`) REFERENCES `asset_management`.`research`.`data_vendor`(`data_vendor_id`);
ALTER TABLE `asset_management`.`research`.`macro_model_run` ADD CONSTRAINT `fk_research_macro_model_run_analyst_assignment_id` FOREIGN KEY (`analyst_assignment_id`) REFERENCES `asset_management`.`research`.`analyst_assignment`(`analyst_assignment_id`);
ALTER TABLE `asset_management`.`research`.`macro_model_run` ADD CONSTRAINT `fk_research_macro_model_run_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`research`.`macro_model_run` ADD CONSTRAINT `fk_research_macro_model_run_macro_model_id` FOREIGN KEY (`macro_model_id`) REFERENCES `asset_management`.`research`.`macro_model`(`macro_model_id`);
ALTER TABLE `asset_management`.`research`.`research_report` ADD CONSTRAINT `fk_research_research_report_superseded_by_report_research_report_id` FOREIGN KEY (`superseded_by_report_research_report_id`) REFERENCES `asset_management`.`research`.`research_report`(`research_report_id`);
ALTER TABLE `asset_management`.`research`.`sector_outlook` ADD CONSTRAINT `fk_research_sector_outlook_previous_outlook_sector_outlook_id` FOREIGN KEY (`previous_outlook_sector_outlook_id`) REFERENCES `asset_management`.`research`.`sector_outlook`(`sector_outlook_id`);
ALTER TABLE `asset_management`.`research`.`country_outlook` ADD CONSTRAINT `fk_research_country_outlook_superseded_by_country_outlook_id` FOREIGN KEY (`superseded_by_country_outlook_id`) REFERENCES `asset_management`.`research`.`country_outlook`(`country_outlook_id`);
ALTER TABLE `asset_management`.`research`.`thematic_research` ADD CONSTRAINT `fk_research_thematic_research_superseded_by_research_thematic_research_id` FOREIGN KEY (`superseded_by_research_thematic_research_id`) REFERENCES `asset_management`.`research`.`thematic_research`(`thematic_research_id`);
ALTER TABLE `asset_management`.`research`.`thematic_research` ADD CONSTRAINT `fk_research_thematic_research_thematic_analyst_assignment_id` FOREIGN KEY (`thematic_analyst_assignment_id`) REFERENCES `asset_management`.`research`.`analyst_assignment`(`analyst_assignment_id`);
ALTER TABLE `asset_management`.`research`.`thematic_research` ADD CONSTRAINT `fk_research_thematic_research_thematic_peer_reviewer_analyst_assignment_id` FOREIGN KEY (`thematic_peer_reviewer_analyst_assignment_id`) REFERENCES `asset_management`.`research`.`analyst_assignment`(`analyst_assignment_id`);
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ADD CONSTRAINT `fk_research_analyst_assignment_coverage_universe_id` FOREIGN KEY (`coverage_universe_id`) REFERENCES `asset_management`.`research`.`coverage_universe`(`coverage_universe_id`);
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ADD CONSTRAINT `fk_research_analyst_assignment_primary_predecessor_assignment_analyst_assignment_id` FOREIGN KEY (`primary_predecessor_assignment_analyst_assignment_id`) REFERENCES `asset_management`.`research`.`analyst_assignment`(`analyst_assignment_id`);
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ADD CONSTRAINT `fk_research_ic_research_pack_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`research`.`market_consensus` ADD CONSTRAINT `fk_research_market_consensus_macro_indicator_id` FOREIGN KEY (`macro_indicator_id`) REFERENCES `asset_management`.`research`.`macro_indicator`(`macro_indicator_id`);
ALTER TABLE `asset_management`.`research`.`market_consensus` ADD CONSTRAINT `fk_research_market_consensus_superseded_by_consensus_market_consensus_id` FOREIGN KEY (`superseded_by_consensus_market_consensus_id`) REFERENCES `asset_management`.`research`.`market_consensus`(`market_consensus_id`);
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ADD CONSTRAINT `fk_research_research_yield_curve_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ADD CONSTRAINT `fk_research_yield_curve_point_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ADD CONSTRAINT `fk_research_yield_curve_point_market_data_feed_id` FOREIGN KEY (`market_data_feed_id`) REFERENCES `asset_management`.`research`.`market_data_feed`(`market_data_feed_id`);
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ADD CONSTRAINT `fk_research_yield_curve_point_superseded_by_yield_curve_point_id` FOREIGN KEY (`superseded_by_yield_curve_point_id`) REFERENCES `asset_management`.`research`.`yield_curve_point`(`yield_curve_point_id`);
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ADD CONSTRAINT `fk_research_research_fx_rate_market_data_feed_id` FOREIGN KEY (`market_data_feed_id`) REFERENCES `asset_management`.`research`.`market_data_feed`(`market_data_feed_id`);
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ADD CONSTRAINT `fk_research_asset_class_outlook_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ADD CONSTRAINT `fk_research_asset_class_outlook_superseded_by_outlook_asset_class_outlook_id` FOREIGN KEY (`superseded_by_outlook_asset_class_outlook_id`) REFERENCES `asset_management`.`research`.`asset_class_outlook`(`asset_class_outlook_id`);
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ADD CONSTRAINT `fk_research_capital_market_assumption_superseded_by_assumption_id` FOREIGN KEY (`superseded_by_assumption_id`) REFERENCES `asset_management`.`research`.`capital_market_assumption`(`capital_market_assumption_id`);
ALTER TABLE `asset_management`.`research`.`calendar` ADD CONSTRAINT `fk_research_calendar_analyst_assignment_id` FOREIGN KEY (`analyst_assignment_id`) REFERENCES `asset_management`.`research`.`analyst_assignment`(`analyst_assignment_id`);
ALTER TABLE `asset_management`.`research`.`calendar` ADD CONSTRAINT `fk_research_calendar_macro_indicator_id` FOREIGN KEY (`macro_indicator_id`) REFERENCES `asset_management`.`research`.`macro_indicator`(`macro_indicator_id`);
ALTER TABLE `asset_management`.`research`.`calendar` ADD CONSTRAINT `fk_research_calendar_parent_event_calendar_id` FOREIGN KEY (`parent_event_calendar_id`) REFERENCES `asset_management`.`research`.`calendar`(`calendar_id`);
ALTER TABLE `asset_management`.`research`.`calendar` ADD CONSTRAINT `fk_research_calendar_research_report_id` FOREIGN KEY (`research_report_id`) REFERENCES `asset_management`.`research`.`research_report`(`research_report_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`research`.`macro_indicator` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`research`.`macro_indicator` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`macro_indicator` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`macro_indicator` SET TAGS ('dbx_subdomain' = 'macro_modeling');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `macro_indicator_id` SET TAGS ('dbx_business_glossary_term' = 'Macroeconomic Indicator ID');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `base_year` SET TAGS ('dbx_business_glossary_term' = 'Base Year');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `benchmark_threshold_high` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Threshold High');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `benchmark_threshold_low` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Threshold Low');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Calculation Methodology');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `data_quality_rating` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Rating');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `data_quality_rating` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `macro_indicator_description` SET TAGS ('dbx_business_glossary_term' = 'Indicator Description');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `esg_relevance` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Relevance');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `esg_relevance` SET TAGS ('dbx_value_regex' = 'environmental|social|governance|not_applicable');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `forecast_availability` SET TAGS ('dbx_business_glossary_term' = 'Forecast Availability');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `frequency` SET TAGS ('dbx_business_glossary_term' = 'Publication Frequency');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annual');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_value_regex' = 'global|regional|country|state_province|city');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `historical_start_date` SET TAGS ('dbx_business_glossary_term' = 'Historical Start Date');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `indicator_category` SET TAGS ('dbx_business_glossary_term' = 'Indicator Category');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `indicator_code` SET TAGS ('dbx_business_glossary_term' = 'Indicator Code');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `indicator_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{3,20}$');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `indicator_name` SET TAGS ('dbx_business_glossary_term' = 'Indicator Name');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `indicator_subcategory` SET TAGS ('dbx_business_glossary_term' = 'Indicator Subcategory');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `leading_lagging_coincident` SET TAGS ('dbx_business_glossary_term' = 'Leading, Lagging, or Coincident Indicator');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `leading_lagging_coincident` SET TAGS ('dbx_value_regex' = 'leading|lagging|coincident');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `macro_indicator_status` SET TAGS ('dbx_business_glossary_term' = 'Indicator Status');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `macro_indicator_status` SET TAGS ('dbx_value_regex' = 'active|discontinued|suspended|under_review');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `proprietary_model_flag` SET TAGS ('dbx_business_glossary_term' = 'Proprietary Model Flag');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `publication_lag_days` SET TAGS ('dbx_business_glossary_term' = 'Publication Lag Days');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `region_code` SET TAGS ('dbx_business_glossary_term' = 'Region Code');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `related_asset_classes` SET TAGS ('dbx_business_glossary_term' = 'Related Asset Classes');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `revision_policy` SET TAGS ('dbx_business_glossary_term' = 'Revision Policy');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `revision_policy` SET TAGS ('dbx_value_regex' = 'no_revision|preliminary_final|continuous_revision');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `seasonal_adjustment` SET TAGS ('dbx_business_glossary_term' = 'Seasonal Adjustment Status');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `seasonal_adjustment` SET TAGS ('dbx_value_regex' = 'seasonally_adjusted|not_seasonally_adjusted|both_available');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `source_identifier` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `steward_team` SET TAGS ('dbx_business_glossary_term' = 'Steward Team');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `usage_context` SET TAGS ('dbx_business_glossary_term' = 'Usage Context');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `volatility_classification` SET TAGS ('dbx_business_glossary_term' = 'Volatility Classification');
ALTER TABLE `asset_management`.`research`.`macro_indicator` ALTER COLUMN `volatility_classification` SET TAGS ('dbx_value_regex' = 'low|moderate|high');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` SET TAGS ('dbx_subdomain' = 'macro_modeling');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `macro_indicator_observation_id` SET TAGS ('dbx_business_glossary_term' = 'Macro Indicator Observation ID');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Scenario ID');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `macro_indicator_id` SET TAGS ('dbx_business_glossary_term' = 'Macro Indicator ID');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `consensus_estimate` SET TAGS ('dbx_business_glossary_term' = 'Consensus Estimate');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `consensus_estimate_count` SET TAGS ('dbx_business_glossary_term' = 'Consensus Estimate Count');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `data_quality_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Flag');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `data_source_identifier` SET TAGS ('dbx_business_glossary_term' = 'Data Source Identifier');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `ingestion_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Ingestion Timestamp');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `is_annualized` SET TAGS ('dbx_business_glossary_term' = 'Is Annualized');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `is_seasonally_adjusted` SET TAGS ('dbx_business_glossary_term' = 'Is Seasonally Adjusted');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `observation_date` SET TAGS ('dbx_business_glossary_term' = 'Observation Date');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `observation_notes` SET TAGS ('dbx_business_glossary_term' = 'Observation Notes');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `observation_status` SET TAGS ('dbx_business_glossary_term' = 'Observation Status');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `observation_status` SET TAGS ('dbx_value_regex' = 'active|superseded|deprecated|deleted');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `observation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Observation Timestamp');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `observation_type` SET TAGS ('dbx_business_glossary_term' = 'Observation Type');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `observation_type` SET TAGS ('dbx_value_regex' = 'actual|preliminary|revised|forecast|consensus');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `observation_value` SET TAGS ('dbx_business_glossary_term' = 'Observation Value');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `period_over_period_change` SET TAGS ('dbx_business_glossary_term' = 'Period-Over-Period Change');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `prior_period_value` SET TAGS ('dbx_business_glossary_term' = 'Prior Period Value');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `publication_date` SET TAGS ('dbx_business_glossary_term' = 'Publication Date');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `publication_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Publication Timestamp');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `region_code` SET TAGS ('dbx_business_glossary_term' = 'Region Code');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annual');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `revision_number` SET TAGS ('dbx_business_glossary_term' = 'Revision Number');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `surprise_percentage` SET TAGS ('dbx_business_glossary_term' = 'Surprise Percentage');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `surprise_value` SET TAGS ('dbx_business_glossary_term' = 'Surprise Value');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `updated_by_user` SET TAGS ('dbx_business_glossary_term' = 'Updated By User');
ALTER TABLE `asset_management`.`research`.`macro_indicator_observation` ALTER COLUMN `year_over_year_change` SET TAGS ('dbx_business_glossary_term' = 'Year-Over-Year (YoY) Change');
ALTER TABLE `asset_management`.`research`.`economic_scenario` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`research`.`economic_scenario` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`economic_scenario` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`economic_scenario` SET TAGS ('dbx_subdomain' = 'macro_modeling');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `climate_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `climate_scenario_alignment` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Alignment');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `commodity_price_assumption` SET TAGS ('dbx_business_glossary_term' = 'Commodity Price Assumption');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `credit_spread_assumption_bps` SET TAGS ('dbx_business_glossary_term' = 'Credit Spread Assumption (Basis Points)');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `economic_scenario_description` SET TAGS ('dbx_business_glossary_term' = 'Scenario Description');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `documentation_url` SET TAGS ('dbx_business_glossary_term' = 'Documentation Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `equity_return_assumption` SET TAGS ('dbx_business_glossary_term' = 'Equity Return Assumption');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `external_reference_code` SET TAGS ('dbx_business_glossary_term' = 'External Reference Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `fx_volatility_assumption` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Volatility Assumption');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `gdp_growth_rate_assumption` SET TAGS ('dbx_business_glossary_term' = 'Gross Domestic Product (GDP) Growth Rate Assumption');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `geopolitical_risk_level` SET TAGS ('dbx_business_glossary_term' = 'Geopolitical Risk Level');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `geopolitical_risk_level` SET TAGS ('dbx_value_regex' = 'low|moderate|high|extreme');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `ghg_emissions_trajectory` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Emissions Trajectory');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `inflation_rate_assumption` SET TAGS ('dbx_business_glossary_term' = 'Inflation Rate Assumption');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `infrastructure_return_assumption` SET TAGS ('dbx_business_glossary_term' = 'Infrastructure Return Assumption');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `interest_rate_assumption` SET TAGS ('dbx_business_glossary_term' = 'Interest Rate Assumption');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `is_baseline` SET TAGS ('dbx_business_glossary_term' = 'Is Baseline Scenario Flag');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `is_regulatory_required` SET TAGS ('dbx_business_glossary_term' = 'Is Regulatory Required Flag');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Scenario Notes');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `private_equity_return_assumption` SET TAGS ('dbx_business_glossary_term' = 'Private Equity (PE) Return Assumption');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `probability_weight` SET TAGS ('dbx_business_glossary_term' = 'Probability Weight');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `real_estate_return_assumption` SET TAGS ('dbx_business_glossary_term' = 'Real Estate Return Assumption');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `regulatory_environment` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Environment');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `scenario_category` SET TAGS ('dbx_business_glossary_term' = 'Scenario Category');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `scenario_category` SET TAGS ('dbx_value_regex' = 'macro|market|geopolitical|climate|regulatory|sector_specific');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `scenario_code` SET TAGS ('dbx_business_glossary_term' = 'Scenario Code');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `scenario_name` SET TAGS ('dbx_business_glossary_term' = 'Scenario Name');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `scenario_owner` SET TAGS ('dbx_business_glossary_term' = 'Scenario Owner');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `scenario_status` SET TAGS ('dbx_business_glossary_term' = 'Scenario Status');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `scenario_status` SET TAGS ('dbx_value_regex' = 'draft|active|archived|deprecated|under_review|approved');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `scenario_type` SET TAGS ('dbx_business_glossary_term' = 'Scenario Type');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `scenario_type` SET TAGS ('dbx_value_regex' = 'baseline|stress|optimistic|pessimistic|historical|custom');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `source_model` SET TAGS ('dbx_business_glossary_term' = 'Source Model');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `time_horizon_years` SET TAGS ('dbx_business_glossary_term' = 'Time Horizon (Years)');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `unemployment_rate_assumption` SET TAGS ('dbx_business_glossary_term' = 'Unemployment Rate Assumption');
ALTER TABLE `asset_management`.`research`.`economic_scenario` ALTER COLUMN `usage_count` SET TAGS ('dbx_business_glossary_term' = 'Usage Count');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` SET TAGS ('dbx_subdomain' = 'macro_modeling');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `scenario_assumption_id` SET TAGS ('dbx_business_glossary_term' = 'Scenario Assumption Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `macro_indicator_id` SET TAGS ('dbx_business_glossary_term' = 'Macroeconomic Indicator Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|rejected|superseded');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `asset_class_scope` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Scope');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `assumption_name` SET TAGS ('dbx_business_glossary_term' = 'Assumption Name');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `assumption_notes` SET TAGS ('dbx_business_glossary_term' = 'Assumption Notes');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `assumption_rationale` SET TAGS ('dbx_business_glossary_term' = 'Assumption Rationale');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `assumption_type` SET TAGS ('dbx_business_glossary_term' = 'Assumption Type');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `assumption_type` SET TAGS ('dbx_value_regex' = 'baseline|shock|stress|recovery|optimistic|pessimistic');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `benchmark_comparison` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Comparison');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `correlation_group` SET TAGS ('dbx_business_glossary_term' = 'Correlation Group');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `probability_weight` SET TAGS ('dbx_business_glossary_term' = 'Probability Weight');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `projected_value` SET TAGS ('dbx_business_glossary_term' = 'Projected Value');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `projection_horizon` SET TAGS ('dbx_business_glossary_term' = 'Projection Horizon');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `projection_horizon` SET TAGS ('dbx_value_regex' = 'short_term|medium_term|long_term|perpetual');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|ad_hoc');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `sector_scope` SET TAGS ('dbx_business_glossary_term' = 'Sector Scope');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `sensitivity_flag` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Flag');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `shock_direction` SET TAGS ('dbx_business_glossary_term' = 'Shock Direction');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `shock_direction` SET TAGS ('dbx_value_regex' = 'upward|downward|neutral');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `shock_magnitude` SET TAGS ('dbx_business_glossary_term' = 'Shock Magnitude');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `source_model` SET TAGS ('dbx_business_glossary_term' = 'Source Model');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `usage_context` SET TAGS ('dbx_business_glossary_term' = 'Usage Context');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `variance_from_baseline` SET TAGS ('dbx_business_glossary_term' = 'Variance from Baseline');
ALTER TABLE `asset_management`.`research`.`scenario_assumption` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`research`.`market_data_feed` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`research`.`market_data_feed` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`market_data_feed` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`market_data_feed` SET TAGS ('dbx_subdomain' = 'market_data');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `market_data_feed_id` SET TAGS ('dbx_business_glossary_term' = 'Market Data Feed ID');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `data_vendor_id` SET TAGS ('dbx_business_glossary_term' = 'Vendor Id (Foreign Key)');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `annual_subscription_cost` SET TAGS ('dbx_business_glossary_term' = 'Annual Subscription Cost');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `annual_subscription_cost` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `asset_class_coverage` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Coverage');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `backup_feed_available_flag` SET TAGS ('dbx_business_glossary_term' = 'Backup Feed Available Flag');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `business_owner_name` SET TAGS ('dbx_business_glossary_term' = 'Business Owner Name');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `consuming_systems` SET TAGS ('dbx_business_glossary_term' = 'Consuming Systems');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `contract_renewal_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Renewal Date');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `cost_currency` SET TAGS ('dbx_business_glossary_term' = 'Cost Currency');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `cost_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `data_classification_level` SET TAGS ('dbx_business_glossary_term' = 'Data Classification Level');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `data_classification_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `data_content_type` SET TAGS ('dbx_business_glossary_term' = 'Data Content Type');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `data_quality_sla_percentage` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Service Level Agreement (SLA) Percentage');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `data_retention_period_days` SET TAGS ('dbx_business_glossary_term' = 'Data Retention Period Days');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `data_steward_name` SET TAGS ('dbx_business_glossary_term' = 'Data Steward Name');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `delivery_frequency` SET TAGS ('dbx_business_glossary_term' = 'Delivery Frequency');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `delivery_method` SET TAGS ('dbx_business_glossary_term' = 'Delivery Method');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `feed_code` SET TAGS ('dbx_business_glossary_term' = 'Feed Code');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `feed_criticality` SET TAGS ('dbx_business_glossary_term' = 'Feed Criticality');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `feed_criticality` SET TAGS ('dbx_value_regex' = 'Critical|High|Medium|Low');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `feed_documentation_url` SET TAGS ('dbx_business_glossary_term' = 'Feed Documentation Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `feed_health_status` SET TAGS ('dbx_business_glossary_term' = 'Feed Health Status');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `feed_health_status` SET TAGS ('dbx_value_regex' = 'Healthy|Degraded|Failed|Under Maintenance|Not Monitored');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `feed_health_status` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `feed_health_status` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `feed_name` SET TAGS ('dbx_business_glossary_term' = 'Feed Name');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `feed_status` SET TAGS ('dbx_business_glossary_term' = 'Feed Status');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `feed_status` SET TAGS ('dbx_value_regex' = 'Active|Inactive|Suspended|Pending Activation|Under Review|Terminated');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `feed_type` SET TAGS ('dbx_business_glossary_term' = 'Feed Type');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `geographic_coverage` SET TAGS ('dbx_business_glossary_term' = 'Geographic Coverage');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `last_data_refresh_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Data Refresh Timestamp');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `last_health_check_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Health Check Timestamp');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `last_health_check_timestamp` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `last_health_check_timestamp` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `primary_use_case` SET TAGS ('dbx_business_glossary_term' = 'Primary Use Case');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `regulatory_compliance_scope` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Scope');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `subscription_end_date` SET TAGS ('dbx_business_glossary_term' = 'Subscription End Date');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `subscription_start_date` SET TAGS ('dbx_business_glossary_term' = 'Subscription Start Date');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `uptime_sla_percentage` SET TAGS ('dbx_business_glossary_term' = 'Uptime Service Level Agreement (SLA) Percentage');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `usage_based_pricing_flag` SET TAGS ('dbx_business_glossary_term' = 'Usage-Based Pricing Flag');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `user_license_count` SET TAGS ('dbx_business_glossary_term' = 'User License Count');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `vendor_support_contact` SET TAGS ('dbx_business_glossary_term' = 'Vendor Support Contact');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `vendor_support_contact` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`market_data_feed` ALTER COLUMN `vendor_support_contact` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` SET TAGS ('dbx_subdomain' = 'market_data');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `market_data_snapshot_id` SET TAGS ('dbx_business_glossary_term' = 'Market Data Snapshot ID');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `data_source_data_vendor_id` SET TAGS ('dbx_business_glossary_term' = 'Data Source ID');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `data_vendor_id` SET TAGS ('dbx_business_glossary_term' = 'Data Source ID');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security ID');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `accrued_interest` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `ask_price` SET TAGS ('dbx_business_glossary_term' = 'Ask Price');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `beta` SET TAGS ('dbx_business_glossary_term' = 'Beta');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `bid_price` SET TAGS ('dbx_business_glossary_term' = 'Bid Price');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `bloomberg_ticker` SET TAGS ('dbx_business_glossary_term' = 'Bloomberg Ticker Symbol');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `close_price` SET TAGS ('dbx_business_glossary_term' = 'Close Price');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `convexity` SET TAGS ('dbx_business_glossary_term' = 'Convexity');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `credit_spread` SET TAGS ('dbx_business_glossary_term' = 'Credit Spread');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[0-9A-Z]{5}[0-9]$');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `data_quality_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Flag');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `dividend_yield` SET TAGS ('dbx_business_glossary_term' = 'Dividend Yield');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `duration` SET TAGS ('dbx_business_glossary_term' = 'Duration');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `dv01` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of 01 (DV01)');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `exchange_code` SET TAGS ('dbx_business_glossary_term' = 'Exchange Code');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `exchange_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3,4}$');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `high_price` SET TAGS ('dbx_business_glossary_term' = 'High Price');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `implied_volatility` SET TAGS ('dbx_business_glossary_term' = 'Implied Volatility');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `ingestion_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Ingestion Timestamp');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `is_end_of_day` SET TAGS ('dbx_business_glossary_term' = 'Is End of Day');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `low_price` SET TAGS ('dbx_business_glossary_term' = 'Low Price');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `market_cap` SET TAGS ('dbx_business_glossary_term' = 'Market Capitalization');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `mid_price` SET TAGS ('dbx_business_glossary_term' = 'Mid Price');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `oas` SET TAGS ('dbx_business_glossary_term' = 'Option-Adjusted Spread (OAS)');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `open_price` SET TAGS ('dbx_business_glossary_term' = 'Open Price');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `pe_ratio` SET TAGS ('dbx_business_glossary_term' = 'Price-to-Earnings (PE) Ratio');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `previous_close_price` SET TAGS ('dbx_business_glossary_term' = 'Previous Close Price');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `price` SET TAGS ('dbx_business_glossary_term' = 'Price');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `price_type` SET TAGS ('dbx_business_glossary_term' = 'Price Type');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `quote_condition` SET TAGS ('dbx_business_glossary_term' = 'Quote Condition');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `ric` SET TAGS ('dbx_business_glossary_term' = 'Reuters Instrument Code (RIC)');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `snapshot_date` SET TAGS ('dbx_business_glossary_term' = 'Snapshot Date');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `snapshot_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Snapshot Timestamp');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `source_system_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Source System Timestamp');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `trade_condition` SET TAGS ('dbx_business_glossary_term' = 'Trade Condition');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `turnover` SET TAGS ('dbx_business_glossary_term' = 'Turnover');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `volume` SET TAGS ('dbx_business_glossary_term' = 'Trading Volume');
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ALTER COLUMN `ytm` SET TAGS ('dbx_business_glossary_term' = 'Yield to Maturity (YTM)');
ALTER TABLE `asset_management`.`research`.`macro_model` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`research`.`macro_model` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`macro_model` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`macro_model` SET TAGS ('dbx_subdomain' = 'macro_modeling');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `macro_model_id` SET TAGS ('dbx_business_glossary_term' = 'Macroeconomic Model Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `accuracy_metric` SET TAGS ('dbx_business_glossary_term' = 'Accuracy Metric');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `accuracy_value` SET TAGS ('dbx_business_glossary_term' = 'Accuracy Value');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `asset_class_applicability` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Applicability');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `backtesting_period_end` SET TAGS ('dbx_business_glossary_term' = 'Backtesting Period End Date');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `backtesting_period_start` SET TAGS ('dbx_business_glossary_term' = 'Backtesting Period Start Date');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `calibration_date` SET TAGS ('dbx_business_glossary_term' = 'Calibration Date');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `climate_scenario_compatible` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Compatible Flag');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `computational_runtime_minutes` SET TAGS ('dbx_business_glossary_term' = 'Computational Runtime in Minutes');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `data_source_description` SET TAGS ('dbx_business_glossary_term' = 'Data Source Description');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `deprecated_date` SET TAGS ('dbx_business_glossary_term' = 'Deprecated Date');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `deprecation_reason` SET TAGS ('dbx_business_glossary_term' = 'Deprecation Reason');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `documentation_url` SET TAGS ('dbx_business_glossary_term' = 'Documentation Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `frequency` SET TAGS ('dbx_business_glossary_term' = 'Model Frequency');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annual|ad_hoc');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `integration_system` SET TAGS ('dbx_business_glossary_term' = 'Integration System');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `key_assumptions` SET TAGS ('dbx_business_glossary_term' = 'Key Assumptions');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `methodology_description` SET TAGS ('dbx_business_glossary_term' = 'Methodology Description');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `model_code` SET TAGS ('dbx_business_glossary_term' = 'Model Code');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `model_complexity_score` SET TAGS ('dbx_business_glossary_term' = 'Model Complexity Score');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `model_name` SET TAGS ('dbx_business_glossary_term' = 'Model Name');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `model_owner` SET TAGS ('dbx_business_glossary_term' = 'Model Owner');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `model_status` SET TAGS ('dbx_business_glossary_term' = 'Model Status');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `model_status` SET TAGS ('dbx_value_regex' = 'active|deprecated|under_review|archived|development');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `model_type` SET TAGS ('dbx_business_glossary_term' = 'Model Type');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `model_type` SET TAGS ('dbx_value_regex' = 'DCF|factor_model|yield_curve_model|regression|monte_carlo|scenario_analysis');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `output_format` SET TAGS ('dbx_business_glossary_term' = 'Output Format');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `primary_use_case` SET TAGS ('dbx_business_glossary_term' = 'Primary Use Case');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `regulatory_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Required Flag');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `risk_classification` SET TAGS ('dbx_business_glossary_term' = 'Risk Classification');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `risk_classification` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `stress_testing_enabled` SET TAGS ('dbx_business_glossary_term' = 'Stress Testing Enabled Flag');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `time_horizon` SET TAGS ('dbx_business_glossary_term' = 'Time Horizon');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `time_horizon` SET TAGS ('dbx_value_regex' = 'short_term|medium_term|long_term|custom');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `validation_date` SET TAGS ('dbx_business_glossary_term' = 'Validation Date');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `validation_status` SET TAGS ('dbx_business_glossary_term' = 'Validation Status');
ALTER TABLE `asset_management`.`research`.`macro_model` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'passed|failed|pending|not_required');
ALTER TABLE `asset_management`.`research`.`macro_model_run` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`research`.`macro_model_run` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`macro_model_run` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`macro_model_run` SET TAGS ('dbx_subdomain' = 'macro_modeling');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `macro_model_run_id` SET TAGS ('dbx_business_glossary_term' = 'Macro Model Run ID');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `analyst_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst ID');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario ID');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst ID');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `macro_model_id` SET TAGS ('dbx_business_glossary_term' = 'Macro Model ID');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `base_date` SET TAGS ('dbx_business_glossary_term' = 'Base Date');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `completion_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Completion Timestamp');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `convergence_achieved` SET TAGS ('dbx_business_glossary_term' = 'Convergence Achieved');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `cvar_estimate` SET TAGS ('dbx_business_glossary_term' = 'Conditional Value at Risk (CVaR) Estimate');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `error_message` SET TAGS ('dbx_business_glossary_term' = 'Error Message');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `execution_duration_seconds` SET TAGS ('dbx_business_glossary_term' = 'Execution Duration Seconds');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `fair_value_currency` SET TAGS ('dbx_business_glossary_term' = 'Fair Value Currency');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `fair_value_estimate` SET TAGS ('dbx_business_glossary_term' = 'Fair Value Estimate');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `fx_currency_pair` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Currency Pair');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `ic_presentation_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Presentation Flag');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `implied_equity_risk_premium` SET TAGS ('dbx_business_glossary_term' = 'Implied Equity Risk Premium');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `input_parameter_count` SET TAGS ('dbx_business_glossary_term' = 'Input Parameter Count');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `iteration_count` SET TAGS ('dbx_business_glossary_term' = 'Iteration Count');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `output_metric_count` SET TAGS ('dbx_business_glossary_term' = 'Output Metric Count');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `projected_credit_spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Projected Credit Spread Basis Points (bps)');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `projected_fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Projected Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `projected_gdp_growth_rate` SET TAGS ('dbx_business_glossary_term' = 'Projected Gross Domestic Product (GDP) Growth Rate');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `projected_inflation_rate` SET TAGS ('dbx_business_glossary_term' = 'Projected Inflation Rate');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `projected_risk_free_rate` SET TAGS ('dbx_business_glossary_term' = 'Projected Risk-Free Rate');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `projected_wacc` SET TAGS ('dbx_business_glossary_term' = 'Projected Weighted Average Cost of Capital (WACC)');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `projection_horizon_years` SET TAGS ('dbx_business_glossary_term' = 'Projection Horizon Years');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `run_identifier` SET TAGS ('dbx_business_glossary_term' = 'Run Identifier');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `run_purpose` SET TAGS ('dbx_business_glossary_term' = 'Run Purpose');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `run_status` SET TAGS ('dbx_business_glossary_term' = 'Run Status');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `run_status` SET TAGS ('dbx_value_regex' = 'pending|running|completed|failed|cancelled|validating');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `run_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Run Timestamp');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `run_type` SET TAGS ('dbx_business_glossary_term' = 'Run Type');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `run_type` SET TAGS ('dbx_value_regex' = 'baseline|stress_test|sensitivity|scenario_analysis|forecast|backtest');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `stress_test_severity` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Severity');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `stress_test_severity` SET TAGS ('dbx_value_regex' = 'mild|moderate|severe|extreme');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `validation_notes` SET TAGS ('dbx_business_glossary_term' = 'Validation Notes');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `validation_status` SET TAGS ('dbx_business_glossary_term' = 'Validation Status');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'not_validated|passed|failed|pending_review');
ALTER TABLE `asset_management`.`research`.`macro_model_run` ALTER COLUMN `var_estimate` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Estimate');
ALTER TABLE `asset_management`.`research`.`research_report` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`research`.`research_report` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`research_report` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`research_report` SET TAGS ('dbx_subdomain' = 'investment_research');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `research_report_id` SET TAGS ('dbx_business_glossary_term' = 'Report ID');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `framework_id` SET TAGS ('dbx_business_glossary_term' = 'Framework Id (Foreign Key)');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `related_deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Related Deal ID');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `related_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Related Deal ID');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `superseded_by_report_research_report_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Report ID');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `archive_date` SET TAGS ('dbx_business_glossary_term' = 'Archive Date');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `author_name` SET TAGS ('dbx_business_glossary_term' = 'Author Name');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `author_team` SET TAGS ('dbx_business_glossary_term' = 'Author Team');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `confidence_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Level');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `data_sources` SET TAGS ('dbx_business_glossary_term' = 'Data Sources');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `distribution_list` SET TAGS ('dbx_business_glossary_term' = 'Distribution List');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `distribution_list` SET TAGS ('dbx_value_regex' = 'internal_only|ic_members|senior_leadership|portfolio_managers|all_staff');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `document_version` SET TAGS ('dbx_business_glossary_term' = 'Document Version');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `esg_integration` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `executive_summary` SET TAGS ('dbx_business_glossary_term' = 'Executive Summary');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `file_format` SET TAGS ('dbx_business_glossary_term' = 'File Format');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `file_format` SET TAGS ('dbx_value_regex' = 'pdf|docx|pptx|html|xlsx');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `file_path` SET TAGS ('dbx_business_glossary_term' = 'File Path');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Focus');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `ic_decision` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `ic_decision` SET TAGS ('dbx_value_regex' = 'approved|approved_with_conditions|deferred|rejected|not_applicable');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `ic_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Date');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `ic_submission_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Flag');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `investment_horizon` SET TAGS ('dbx_business_glossary_term' = 'Investment Horizon');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `investment_horizon` SET TAGS ('dbx_value_regex' = 'short_term|medium_term|long_term|strategic');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `investment_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Investment Recommendation');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `key_findings` SET TAGS ('dbx_business_glossary_term' = 'Key Findings');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `keywords` SET TAGS ('dbx_business_glossary_term' = 'Keywords');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `macroeconomic_scenario` SET TAGS ('dbx_business_glossary_term' = 'Macroeconomic Scenario');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `methodology` SET TAGS ('dbx_business_glossary_term' = 'Research Methodology');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Report Number');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `page_count` SET TAGS ('dbx_business_glossary_term' = 'Page Count');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `peer_review_status` SET TAGS ('dbx_business_glossary_term' = 'Peer Review Status');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `peer_review_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|completed|approved|rejected');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `publication_date` SET TAGS ('dbx_business_glossary_term' = 'Publication Date');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `publication_status` SET TAGS ('dbx_business_glossary_term' = 'Publication Status');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `publication_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|published|archived|withdrawn');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `research_report_type` SET TAGS ('dbx_business_glossary_term' = 'Report Type');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `research_report_type` SET TAGS ('dbx_value_regex' = 'sector|country_regional|thematic|asset_class|macro_outlook|investment_memorandum');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `revision_date` SET TAGS ('dbx_business_glossary_term' = 'Revision Date');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `revision_notes` SET TAGS ('dbx_business_glossary_term' = 'Revision Notes');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `risk_assessment` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `sector_focus` SET TAGS ('dbx_business_glossary_term' = 'Sector Focus');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `target_return` SET TAGS ('dbx_business_glossary_term' = 'Target Return');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `target_return_currency` SET TAGS ('dbx_business_glossary_term' = 'Target Return Currency');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `target_return_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Report Title');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `valuation_approach` SET TAGS ('dbx_business_glossary_term' = 'Valuation Approach');
ALTER TABLE `asset_management`.`research`.`research_report` ALTER COLUMN `valuation_approach` SET TAGS ('dbx_value_regex' = 'dcf|comparable_company|precedent_transaction|nav|irr_moic|market_multiples');
ALTER TABLE `asset_management`.`research`.`sector_outlook` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`research`.`sector_outlook` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`sector_outlook` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`sector_outlook` SET TAGS ('dbx_subdomain' = 'investment_research');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `sector_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Sector Outlook ID');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `previous_outlook_sector_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Previous Outlook ID');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `archived_date` SET TAGS ('dbx_business_glossary_term' = 'Archived Date');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `archived_flag` SET TAGS ('dbx_business_glossary_term' = 'Archived Flag');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `base_case_scenario` SET TAGS ('dbx_business_glossary_term' = 'Base Case Scenario');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `climate_risk_assessment` SET TAGS ('dbx_business_glossary_term' = 'Climate Risk Assessment');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `climate_risk_assessment` SET TAGS ('dbx_value_regex' = 'high|medium|low|not_applicable');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Level');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `contributing_analysts` SET TAGS ('dbx_business_glossary_term' = 'Contributing Analysts');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `conviction_level` SET TAGS ('dbx_business_glossary_term' = 'Conviction Level');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `conviction_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `data_sources` SET TAGS ('dbx_business_glossary_term' = 'Data Sources');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `distribution_list` SET TAGS ('dbx_business_glossary_term' = 'Distribution List');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `document_url` SET TAGS ('dbx_business_glossary_term' = 'Document Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `downside_scenario` SET TAGS ('dbx_business_glossary_term' = 'Downside Scenario');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `effective_to_date` SET TAGS ('dbx_business_glossary_term' = 'Effective To Date');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `esg_considerations` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Considerations');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `executive_summary` SET TAGS ('dbx_business_glossary_term' = 'Executive Summary');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Focus');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `gics_industry_group_code` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Industry Group Code');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `gics_industry_group_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `gics_industry_group_name` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Industry Group Name');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `gics_sector_code` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Sector Code');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `gics_sector_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2}$');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `gics_sector_name` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Sector Name');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `investment_view` SET TAGS ('dbx_business_glossary_term' = 'Investment View');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `investment_view` SET TAGS ('dbx_value_regex' = 'overweight|neutral|underweight|positive|negative');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `key_drivers` SET TAGS ('dbx_business_glossary_term' = 'Key Drivers');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `key_risks` SET TAGS ('dbx_business_glossary_term' = 'Key Risks');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `lead_analyst_email` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst Email');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `lead_analyst_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `lead_analyst_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `lead_analyst_name` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst Name');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `macroeconomic_context` SET TAGS ('dbx_business_glossary_term' = 'Macroeconomic Context');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `outlook_code` SET TAGS ('dbx_business_glossary_term' = 'Outlook Code');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `outlook_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{6,12}$');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `outlook_status` SET TAGS ('dbx_business_glossary_term' = 'Outlook Status');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `outlook_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|published|archived|superseded');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `outlook_title` SET TAGS ('dbx_business_glossary_term' = 'Outlook Title');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `outlook_type` SET TAGS ('dbx_business_glossary_term' = 'Outlook Type');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `outlook_type` SET TAGS ('dbx_value_regex' = 'quarterly|annual|ad_hoc|thematic|strategic');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `portfolio_implications` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Implications');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `publication_date` SET TAGS ('dbx_business_glossary_term' = 'Publication Date');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'Review Date');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `scenario_analysis_flag` SET TAGS ('dbx_business_glossary_term' = 'Scenario Analysis Flag');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `time_horizon` SET TAGS ('dbx_business_glossary_term' = 'Time Horizon');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `time_horizon` SET TAGS ('dbx_value_regex' = 'short_term|medium_term|long_term|tactical|strategic');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `upside_scenario` SET TAGS ('dbx_business_glossary_term' = 'Upside Scenario');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `valuation_assessment` SET TAGS ('dbx_business_glossary_term' = 'Valuation Assessment');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `valuation_assessment` SET TAGS ('dbx_value_regex' = 'expensive|fair|cheap|mixed');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`research`.`sector_outlook` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');
ALTER TABLE `asset_management`.`research`.`country_outlook` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`research`.`country_outlook` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`country_outlook` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`country_outlook` SET TAGS ('dbx_subdomain' = 'investment_research');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `country_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Country Outlook ID');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst ID');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst ID');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `superseded_by_country_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By ID');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Assessment Date');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `capital_controls_flag` SET TAGS ('dbx_business_glossary_term' = 'Capital Controls Flag');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `climate_risk_category` SET TAGS ('dbx_business_glossary_term' = 'Climate Risk Category');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `climate_risk_category` SET TAGS ('dbx_value_regex' = 'low|moderate|high|extreme');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `corruption_perception_index` SET TAGS ('dbx_business_glossary_term' = 'Corruption Perception Index (CPI)');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `country_name` SET TAGS ('dbx_business_glossary_term' = 'Country Name');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `credit_outlook` SET TAGS ('dbx_business_glossary_term' = 'Credit Outlook');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `credit_outlook` SET TAGS ('dbx_value_regex' = 'positive|stable|negative|developing');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `currency_outlook` SET TAGS ('dbx_business_glossary_term' = 'Currency Outlook');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `currency_outlook` SET TAGS ('dbx_value_regex' = 'strengthening|stable|weakening|volatile');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `current_account_balance_gdp_pct` SET TAGS ('dbx_business_glossary_term' = 'Current Account Balance as Percentage of GDP');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `ease_of_doing_business_rank` SET TAGS ('dbx_business_glossary_term' = 'Ease of Doing Business Rank');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `esg_country_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Country Score');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `fiscal_balance_gdp_pct` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Balance as Percentage of GDP');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `foreign_reserves_months_import` SET TAGS ('dbx_business_glossary_term' = 'Foreign Reserves in Months of Import Cover');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `fx_volatility_category` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Volatility Category');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `fx_volatility_category` SET TAGS ('dbx_value_regex' = 'low|moderate|high|extreme');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `ic_presentation_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Presentation Date');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `ic_presentation_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Presentation Flag');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `investment_climate_rating` SET TAGS ('dbx_business_glossary_term' = 'Investment Climate Rating');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `investment_climate_rating` SET TAGS ('dbx_value_regex' = 'very_favorable|favorable|neutral|challenging|unfavorable');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `investment_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Investment Recommendation');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `investment_recommendation` SET TAGS ('dbx_value_regex' = 'overweight|neutral|underweight|avoid');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `key_opportunities` SET TAGS ('dbx_business_glossary_term' = 'Key Opportunities');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `key_risks` SET TAGS ('dbx_business_glossary_term' = 'Key Risks');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `market_access_category` SET TAGS ('dbx_business_glossary_term' = 'Market Access Category');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `market_access_category` SET TAGS ('dbx_value_regex' = 'open|restricted|closed|emerging');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `outlook_horizon_years` SET TAGS ('dbx_business_glossary_term' = 'Outlook Horizon Years');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `outlook_status` SET TAGS ('dbx_business_glossary_term' = 'Outlook Status');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `outlook_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|published|archived|superseded');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `political_risk_category` SET TAGS ('dbx_business_glossary_term' = 'Political Risk Category');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `political_risk_category` SET TAGS ('dbx_value_regex' = 'low|moderate|elevated|high|severe');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `political_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Political Risk Score');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `projected_gdp_growth_rate` SET TAGS ('dbx_business_glossary_term' = 'Projected Gross Domestic Product (GDP) Growth Rate');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `projected_inflation_rate` SET TAGS ('dbx_business_glossary_term' = 'Projected Inflation Rate');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `projected_unemployment_rate` SET TAGS ('dbx_business_glossary_term' = 'Projected Unemployment Rate');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `public_debt_gdp_pct` SET TAGS ('dbx_business_glossary_term' = 'Public Debt as Percentage of GDP');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `regulatory_environment_score` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Environment Score');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `sovereign_credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Sovereign Credit Rating');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`country_outlook` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`research`.`thematic_research` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`research`.`thematic_research` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`thematic_research` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`thematic_research` SET TAGS ('dbx_subdomain' = 'investment_research');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `thematic_research_id` SET TAGS ('dbx_business_glossary_term' = 'Thematic Research ID');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `framework_id` SET TAGS ('dbx_business_glossary_term' = 'Framework Id (Foreign Key)');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `peer_reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Peer Reviewer ID');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `superseded_by_research_thematic_research_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Research ID');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `thematic_analyst_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `thematic_peer_reviewer_analyst_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Peer Reviewer ID');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `access_restriction_level` SET TAGS ('dbx_business_glossary_term' = 'Access Restriction Level');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `access_restriction_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `affected_asset_classes` SET TAGS ('dbx_business_glossary_term' = 'Affected Asset Classes');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `affected_sectors` SET TAGS ('dbx_business_glossary_term' = 'Affected Sectors');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `climate_relevance` SET TAGS ('dbx_business_glossary_term' = 'Climate Relevance');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `climate_relevance` SET TAGS ('dbx_value_regex' = 'high|medium|low|not_applicable');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `confidence_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `data_sources` SET TAGS ('dbx_business_glossary_term' = 'Data Sources');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `document_url` SET TAGS ('dbx_business_glossary_term' = 'Document Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `document_url` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `esg_alignment_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Alignment Score');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `executive_summary` SET TAGS ('dbx_business_glossary_term' = 'Executive Summary');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_value_regex' = 'global|north_america|europe|asia_pacific|emerging_markets|developed_markets');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `ic_presentation_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Presentation Date');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `ic_presentation_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Presentation Flag');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `investment_horizon_years` SET TAGS ('dbx_business_glossary_term' = 'Investment Horizon Years');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `investment_implications` SET TAGS ('dbx_business_glossary_term' = 'Investment Implications');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `key_drivers` SET TAGS ('dbx_business_glossary_term' = 'Key Drivers');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `methodology_description` SET TAGS ('dbx_business_glossary_term' = 'Methodology Description');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `peer_review_status` SET TAGS ('dbx_business_glossary_term' = 'Peer Review Status');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `peer_review_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed|approved|rejected');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `publication_date` SET TAGS ('dbx_business_glossary_term' = 'Publication Date');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `related_deal_count` SET TAGS ('dbx_business_glossary_term' = 'Related Deal Count');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `related_portfolio_exposure_aum` SET TAGS ('dbx_business_glossary_term' = 'Related Portfolio Exposure Assets Under Management (AUM)');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `related_portfolio_exposure_aum` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `research_identifier` SET TAGS ('dbx_business_glossary_term' = 'Research Identifier');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `research_status` SET TAGS ('dbx_business_glossary_term' = 'Research Status');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `research_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|published|archived|superseded');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `research_team` SET TAGS ('dbx_business_glossary_term' = 'Research Team');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `review_frequency_months` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency Months');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `risk_considerations` SET TAGS ('dbx_business_glossary_term' = 'Risk Considerations');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `tags` SET TAGS ('dbx_business_glossary_term' = 'Research Tags');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `target_allocation_percentage` SET TAGS ('dbx_business_glossary_term' = 'Target Allocation Percentage');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `target_allocation_percentage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `theme_category` SET TAGS ('dbx_business_glossary_term' = 'Theme Category');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `theme_category` SET TAGS ('dbx_value_regex' = 'energy_transition|digital_infrastructure|demographic_shifts|deglobalization|artificial_intelligence|climate_adaptation');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Research Title');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`thematic_research` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`research`.`coverage_universe` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`research`.`coverage_universe` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`coverage_universe` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`coverage_universe` SET TAGS ('dbx_subdomain' = 'investment_research');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `coverage_universe_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Universe Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `issuer_esg_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer Esg Rating Id (Foreign Key)');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `lead_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `aum_usd` SET TAGS ('dbx_business_glossary_term' = 'Assets Under Management (AUM) in United States Dollars (USD)');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `benchmark_index` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `bloomberg_ticker` SET TAGS ('dbx_business_glossary_term' = 'Bloomberg Ticker Symbol');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `coverage_initiation_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Initiation Date');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `coverage_status` SET TAGS ('dbx_business_glossary_term' = 'Coverage Status');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `coverage_status` SET TAGS ('dbx_value_regex' = 'active|suspended|discontinued|under_review');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `coverage_team` SET TAGS ('dbx_business_glossary_term' = 'Coverage Team Name');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `coverage_tier` SET TAGS ('dbx_business_glossary_term' = 'Coverage Tier');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `coverage_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3|watchlist');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP) Number');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `entity_name` SET TAGS ('dbx_business_glossary_term' = 'Entity Name');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `fund_strategy` SET TAGS ('dbx_business_glossary_term' = 'Fund Strategy');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `geography` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `geography` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `ic_approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Required Flag');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `investable_flag` SET TAGS ('dbx_business_glossary_term' = 'Investable Flag');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `investment_grade_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Grade (IG) Flag');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `investment_style` SET TAGS ('dbx_business_glossary_term' = 'Investment Style');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `liquidity_classification` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Classification');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `liquidity_classification` SET TAGS ('dbx_value_regex' = 'highly_liquid|liquid|illiquid|highly_illiquid');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `market_cap_usd` SET TAGS ('dbx_business_glossary_term' = 'Market Capitalization in United States Dollars (USD)');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Review Date');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `regional_classification` SET TAGS ('dbx_business_glossary_term' = 'Regional Market Classification');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `regional_classification` SET TAGS ('dbx_value_regex' = 'developed|emerging|frontier');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `research_notes` SET TAGS ('dbx_business_glossary_term' = 'Research Notes');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `research_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `restricted_flag` SET TAGS ('dbx_business_glossary_term' = 'Restricted Investment Flag');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `restriction_reason` SET TAGS ('dbx_business_glossary_term' = 'Restriction Reason');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL) Code');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `sub_asset_class` SET TAGS ('dbx_business_glossary_term' = 'Sub-Asset Class');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `sub_sector` SET TAGS ('dbx_business_glossary_term' = 'Sub-Sector Classification');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `target_irr_percent` SET TAGS ('dbx_business_glossary_term' = 'Target Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `universe_code` SET TAGS ('dbx_business_glossary_term' = 'Coverage Universe Code');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `universe_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,20}$');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`coverage_universe` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` SET TAGS ('dbx_subdomain' = 'investment_research');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `analyst_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst Assignment Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `analyst_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `analyst_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `analyst_supervisor_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Supervisor Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `analyst_supervisor_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `analyst_supervisor_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `coverage_universe_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Entity Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `primary_predecessor_assignment_analyst_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Predecessor Assignment Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `supervisor_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Supervisor Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|approved|rejected|revision_required');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `assignment_end_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Assignment End Timestamp');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `assignment_identifier` SET TAGS ('dbx_business_glossary_term' = 'Assignment Identifier');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `assignment_notes` SET TAGS ('dbx_business_glossary_term' = 'Assignment Notes');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `assignment_start_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Assignment Start Timestamp');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Assignment Status');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending|transition');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_business_glossary_term' = 'Assignment Type');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_value_regex' = 'primary|secondary|backup|specialist|thematic');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `benchmark_index` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `collaboration_team` SET TAGS ('dbx_business_glossary_term' = 'Collaboration Team');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Level');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `conflict_description` SET TAGS ('dbx_business_glossary_term' = 'Conflict Description');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `conflict_description` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `conflict_of_interest_flag` SET TAGS ('dbx_business_glossary_term' = 'Conflict of Interest Flag');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `coverage_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Coverage Entity Name');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `coverage_entity_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Entity Type');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `coverage_entity_type` SET TAGS ('dbx_value_regex' = 'issuer|sector|geography|asset_class|fund_manager|portfolio');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `coverage_priority` SET TAGS ('dbx_business_glossary_term' = 'Coverage Priority');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `coverage_priority` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3|watchlist|opportunistic');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `coverage_scope` SET TAGS ('dbx_business_glossary_term' = 'Coverage Scope');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `data_source_systems` SET TAGS ('dbx_business_glossary_term' = 'Data Source Systems');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `due_diligence_responsibility` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Responsibility');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `due_diligence_responsibility` SET TAGS ('dbx_value_regex' = 'full|partial|none|advisory');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Focus');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `ic_presentation_requirement` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Presentation Requirement');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `macroeconomic_modeling_flag` SET TAGS ('dbx_business_glossary_term' = 'Macroeconomic Modeling Flag');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `peer_group` SET TAGS ('dbx_business_glossary_term' = 'Peer Group');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `performance_rating` SET TAGS ('dbx_business_glossary_term' = 'Performance Rating');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `performance_rating` SET TAGS ('dbx_value_regex' = 'exceeds|meets|below|not_rated');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annual|ad_hoc');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `research_mandate` SET TAGS ('dbx_business_glossary_term' = 'Research Mandate');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `sector_focus` SET TAGS ('dbx_business_glossary_term' = 'Sector Focus');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `transition_reason` SET TAGS ('dbx_business_glossary_term' = 'Transition Reason');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Valuation Methodology');
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` SET TAGS ('dbx_subdomain' = 'investment_research');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `ic_research_pack_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Research Pack Identifier');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `due_diligence_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence Id (Foreign Key)');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Macroeconomic Scenario Identifier');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst Identifier');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `ic_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst Identifier');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `ic_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `ic_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `ic_meeting_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Meeting Identifier');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `ic_peer_reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Peer Reviewer Identifier');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `ic_peer_reviewer_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `ic_peer_reviewer_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Mandate Id (Foreign Key)');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Opportunity Identifier');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `peer_reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Peer Reviewer Identifier');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Commitment Currency');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Level');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `decision_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision Date');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `decision_rationale` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision Rationale');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `decision_rationale` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `distribution_list` SET TAGS ('dbx_business_glossary_term' = 'Distribution List');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `document_version` SET TAGS ('dbx_business_glossary_term' = 'Document Version');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `due_diligence_status` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Status');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `due_diligence_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed|pending_items|waived');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `esg_integration_summary` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Summary');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `fair_value_currency` SET TAGS ('dbx_business_glossary_term' = 'Fair Value Currency');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `fair_value_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `fair_value_estimate` SET TAGS ('dbx_business_glossary_term' = 'Fair Value Estimate');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `fair_value_estimate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `file_path` SET TAGS ('dbx_business_glossary_term' = 'File Path');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Focus');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `ic_decision` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `ic_decision` SET TAGS ('dbx_value_regex' = 'approved|rejected|deferred|conditional_approval|withdrawn');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `ic_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Meeting Date');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `investment_horizon_years` SET TAGS ('dbx_business_glossary_term' = 'Investment Horizon Years');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `investment_thesis` SET TAGS ('dbx_business_glossary_term' = 'Investment Thesis');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `investment_thesis` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `key_risks_identified` SET TAGS ('dbx_business_glossary_term' = 'Key Risks Identified');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `key_risks_identified` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `mitigation_strategies` SET TAGS ('dbx_business_glossary_term' = 'Risk Mitigation Strategies');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `mitigation_strategies` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `pack_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Research Pack Reference Number');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `pack_title` SET TAGS ('dbx_business_glossary_term' = 'Research Pack Title');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `pack_type` SET TAGS ('dbx_business_glossary_term' = 'Research Pack Type');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `pack_type` SET TAGS ('dbx_value_regex' = 'new_investment|follow_on|divestment|portfolio_review|strategic_allocation|manager_selection');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `page_count` SET TAGS ('dbx_business_glossary_term' = 'Page Count');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `peer_review_status` SET TAGS ('dbx_business_glossary_term' = 'Peer Review Status');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `peer_review_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|in_progress|completed|approved|rejected');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `recommended_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Recommended Commitment Amount');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `recommended_commitment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `research_team` SET TAGS ('dbx_business_glossary_term' = 'Research Team');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `revision_date` SET TAGS ('dbx_business_glossary_term' = 'Revision Date');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `revision_notes` SET TAGS ('dbx_business_glossary_term' = 'Revision Notes');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|very_high');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `sector_focus` SET TAGS ('dbx_business_glossary_term' = 'Sector Focus');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Date');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `submission_status` SET TAGS ('dbx_business_glossary_term' = 'Submission Status');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `target_irr` SET TAGS ('dbx_business_glossary_term' = 'Target Internal Rate of Return (IRR)');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `target_irr` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `target_moic` SET TAGS ('dbx_business_glossary_term' = 'Target Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `target_moic` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By User');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Valuation Methodology');
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `asset_management`.`research`.`market_consensus` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`research`.`market_consensus` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`market_consensus` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`market_consensus` SET TAGS ('dbx_subdomain' = 'market_data');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `market_consensus_id` SET TAGS ('dbx_business_glossary_term' = 'Market Consensus ID');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security ID');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `macro_indicator_id` SET TAGS ('dbx_business_glossary_term' = 'Macroeconomic Indicator ID');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `superseded_by_consensus_market_consensus_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Consensus ID');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `adjustment_rationale` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Rationale');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `adjustment_rationale` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `analyst_count` SET TAGS ('dbx_business_glossary_term' = 'Analyst Count');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|pending_review|approved|rejected|superseded');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `benchmark_comparison` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Comparison');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `buy_count` SET TAGS ('dbx_business_glossary_term' = 'Buy Recommendation Count');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `collection_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Collection Timestamp');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `consensus_identifier` SET TAGS ('dbx_business_glossary_term' = 'Consensus Identifier');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `consensus_rating` SET TAGS ('dbx_business_glossary_term' = 'Consensus Rating');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `consensus_rating` SET TAGS ('dbx_value_regex' = 'strong_buy|buy|hold|underperform|sell');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `data_quality_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Flag');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `data_source` SET TAGS ('dbx_value_regex' = 'bloomberg|factset|refinitiv|sell_side_aggregator|proprietary');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `estimate_currency` SET TAGS ('dbx_business_glossary_term' = 'Estimate Currency');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `estimate_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `estimate_type` SET TAGS ('dbx_business_glossary_term' = 'Estimate Type');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `fiscal_quarter` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Quarter');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year (FY)');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `forecast_period` SET TAGS ('dbx_business_glossary_term' = 'Forecast Period');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `high_estimate` SET TAGS ('dbx_business_glossary_term' = 'High Estimate');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `hold_count` SET TAGS ('dbx_business_glossary_term' = 'Hold Recommendation Count');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `ic_submission_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Flag');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `last_revision_date` SET TAGS ('dbx_business_glossary_term' = 'Last Revision Date');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `low_estimate` SET TAGS ('dbx_business_glossary_term' = 'Low Estimate');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `mean_estimate` SET TAGS ('dbx_business_glossary_term' = 'Mean Estimate');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `median_estimate` SET TAGS ('dbx_business_glossary_term' = 'Median Estimate');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `proprietary_adjustment` SET TAGS ('dbx_business_glossary_term' = 'Proprietary Adjustment');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `proprietary_adjustment` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `revision_direction` SET TAGS ('dbx_business_glossary_term' = 'Revision Direction');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `revision_direction` SET TAGS ('dbx_value_regex' = 'up|down|unchanged|new');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `revision_magnitude` SET TAGS ('dbx_business_glossary_term' = 'Revision Magnitude');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `sell_count` SET TAGS ('dbx_business_glossary_term' = 'Sell Recommendation Count');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `stale_threshold_days` SET TAGS ('dbx_business_glossary_term' = 'Stale Threshold Days');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `standard_deviation` SET TAGS ('dbx_business_glossary_term' = 'Standard Deviation');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `usage_context` SET TAGS ('dbx_business_glossary_term' = 'Usage Context');
ALTER TABLE `asset_management`.`research`.`market_consensus` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` SET TAGS ('dbx_subdomain' = 'market_data');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `research_yield_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Research Yield Curve Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'fixed_income|credit|derivatives|structured_products');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `benchmark_flag` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Flag');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `business_owner_name` SET TAGS ('dbx_business_glossary_term' = 'Business Owner Name');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `compounding_frequency` SET TAGS ('dbx_business_glossary_term' = 'Compounding Frequency');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `compounding_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly|continuous');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `curve_code` SET TAGS ('dbx_business_glossary_term' = 'Yield Curve Code');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `curve_name` SET TAGS ('dbx_business_glossary_term' = 'Yield Curve Name');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `curve_status` SET TAGS ('dbx_business_glossary_term' = 'Yield Curve Status');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `curve_status` SET TAGS ('dbx_value_regex' = 'active|inactive|deprecated|under_review');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `curve_type` SET TAGS ('dbx_business_glossary_term' = 'Yield Curve Type');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `curve_type` SET TAGS ('dbx_value_regex' = 'sovereign|swap|credit_spread|corporate|municipal|agency');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `data_classification_level` SET TAGS ('dbx_business_glossary_term' = 'Data Classification Level');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `data_classification_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `data_source_identifier` SET TAGS ('dbx_business_glossary_term' = 'Data Source Identifier');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `data_steward_name` SET TAGS ('dbx_business_glossary_term' = 'Data Steward Name');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_business_glossary_term' = 'Day Count Convention');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_value_regex' = 'ACT_360|ACT_365|30_360|ACT_ACT');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `extrapolation_method` SET TAGS ('dbx_business_glossary_term' = 'Extrapolation Method');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `extrapolation_method` SET TAGS ('dbx_value_regex' = 'flat|linear|exponential|none');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `ic_presentation_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Presentation Flag');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `interpolation_method` SET TAGS ('dbx_business_glossary_term' = 'Interpolation Method');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `interpolation_method` SET TAGS ('dbx_value_regex' = 'linear|cubic_spline|nelson_siegel|svensson|hermite');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `issuer_type` SET TAGS ('dbx_business_glossary_term' = 'Issuer Type');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `issuer_type` SET TAGS ('dbx_value_regex' = 'sovereign|supranational|corporate|financial|municipal|agency');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `last_update_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Update Timestamp');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `model_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Model Integration Flag');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `primary_data_source` SET TAGS ('dbx_business_glossary_term' = 'Primary Data Source');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `primary_data_source` SET TAGS ('dbx_value_regex' = 'bloomberg|factset|refinitiv|ice|markit|internal');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `rating_category` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating Category');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `regulatory_compliance_scope` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Scope');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `risk_free_rate_proxy_flag` SET TAGS ('dbx_business_glossary_term' = 'Risk-Free Rate Proxy Flag');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `spread_over_benchmark_bps` SET TAGS ('dbx_business_glossary_term' = 'Spread Over Benchmark (Basis Points)');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `tenor_range_max_years` SET TAGS ('dbx_business_glossary_term' = 'Maximum Tenor Range (Years)');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `tenor_range_min_years` SET TAGS ('dbx_business_glossary_term' = 'Minimum Tenor Range (Years)');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `update_frequency` SET TAGS ('dbx_business_glossary_term' = 'Update Frequency');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `update_frequency` SET TAGS ('dbx_value_regex' = 'real_time|intraday|daily|weekly|monthly');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `usage_context` SET TAGS ('dbx_business_glossary_term' = 'Usage Context');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `validation_status` SET TAGS ('dbx_business_glossary_term' = 'Validation Status');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'validated|pending_review|failed|not_validated');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `validation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Validation Timestamp');
ALTER TABLE `asset_management`.`research`.`research_yield_curve` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` SET TAGS ('dbx_subdomain' = 'market_data');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `yield_curve_point_id` SET TAGS ('dbx_business_glossary_term' = 'Yield Curve Point Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `credit_yield_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Yield Curve Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `market_data_feed_id` SET TAGS ('dbx_business_glossary_term' = 'Market Data Feed Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `superseded_by_yield_curve_point_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|pending|approved|rejected');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `benchmark_reference` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Reference');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `compounding_frequency` SET TAGS ('dbx_business_glossary_term' = 'Compounding Frequency');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `compounding_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly|continuous');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `curve_type` SET TAGS ('dbx_business_glossary_term' = 'Curve Type');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `curve_type` SET TAGS ('dbx_value_regex' = 'zero|par|forward|discount');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `data_quality_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Flag');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `data_steward_name` SET TAGS ('dbx_business_glossary_term' = 'Data Steward Name');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_business_glossary_term' = 'Day Count Convention');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_value_regex' = 'ACT/360|ACT/365|30/360|ACT/ACT');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `discount_factor` SET TAGS ('dbx_business_glossary_term' = 'Discount Factor');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `forward_rate` SET TAGS ('dbx_business_glossary_term' = 'Forward Rate');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `interpolation_method` SET TAGS ('dbx_business_glossary_term' = 'Interpolation Method');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `interpolation_method` SET TAGS ('dbx_value_regex' = 'linear|cubic_spline|nelson_siegel|hermite');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active Flag');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `is_interpolated` SET TAGS ('dbx_business_glossary_term' = 'Is Interpolated Flag');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `is_regulatory_required` SET TAGS ('dbx_business_glossary_term' = 'Is Regulatory Required Flag');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `market_segment` SET TAGS ('dbx_business_glossary_term' = 'Market Segment');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `market_segment` SET TAGS ('dbx_value_regex' = 'government|corporate|municipal|sovereign|swap');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `observation_date` SET TAGS ('dbx_business_glossary_term' = 'Observation Date');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `observation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Observation Timestamp');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `quote_type` SET TAGS ('dbx_business_glossary_term' = 'Quote Type');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `quote_type` SET TAGS ('dbx_value_regex' = 'mid|bid|ask|close|open');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `regulatory_framework` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Framework');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `source_identifier` SET TAGS ('dbx_business_glossary_term' = 'Source Identifier');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Spread in Basis Points (bps)');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `stress_test_flag` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Flag');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `tenor` SET TAGS ('dbx_business_glossary_term' = 'Tenor');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `tenor_days` SET TAGS ('dbx_business_glossary_term' = 'Tenor in Days');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `usage_context` SET TAGS ('dbx_business_glossary_term' = 'Usage Context');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `validation_notes` SET TAGS ('dbx_business_glossary_term' = 'Validation Notes');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `validation_status` SET TAGS ('dbx_business_glossary_term' = 'Validation Status');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'passed|failed|pending|manual_review');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `yield_bps` SET TAGS ('dbx_business_glossary_term' = 'Yield in Basis Points (bps)');
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ALTER COLUMN `yield_rate` SET TAGS ('dbx_business_glossary_term' = 'Yield Rate');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` SET TAGS ('dbx_subdomain' = 'market_data');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `research_fx_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Research Foreign Exchange (FX) Rate ID');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `market_data_feed_id` SET TAGS ('dbx_business_glossary_term' = 'Market Data Feed ID');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `ask_rate` SET TAGS ('dbx_business_glossary_term' = 'Ask Exchange Rate');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `base_currency` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `base_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `benchmark_rate_flag` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Rate Flag');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `bid_ask_spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Bid-Ask Spread in Basis Points (bps)');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `bid_rate` SET TAGS ('dbx_business_glossary_term' = 'Bid Exchange Rate');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `central_bank_rate_flag` SET TAGS ('dbx_business_glossary_term' = 'Central Bank Rate Flag');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `cross_rate_calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Cross Rate Calculation Method');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `currency_pair` SET TAGS ('dbx_business_glossary_term' = 'Currency Pair');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `currency_pair` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}/[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `data_lineage_reference` SET TAGS ('dbx_business_glossary_term' = 'Data Lineage Reference');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `fixing_time` SET TAGS ('dbx_business_glossary_term' = 'Official Fixing Time');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `forward_points` SET TAGS ('dbx_business_glossary_term' = 'Forward Points');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `forward_rate` SET TAGS ('dbx_business_glossary_term' = 'Forward Exchange Rate');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `forward_tenor` SET TAGS ('dbx_business_glossary_term' = 'Forward Tenor Period');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `forward_tenor` SET TAGS ('dbx_value_regex' = '^(ON|TN|SN|[0-9]{1,3}[DWMY])$');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `hedging_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Hedging Eligible Flag');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `implied_volatility` SET TAGS ('dbx_business_glossary_term' = 'Implied Volatility');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `liquidity_tier` SET TAGS ('dbx_business_glossary_term' = 'Currency Pair Liquidity Tier');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `liquidity_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3|emerging|exotic');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `mid_rate` SET TAGS ('dbx_business_glossary_term' = 'Mid-Market Exchange Rate');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Rate Observation Notes');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `outlier_flag` SET TAGS ('dbx_business_glossary_term' = 'Outlier Detection Flag');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `quote_convention` SET TAGS ('dbx_business_glossary_term' = 'Quote Convention');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `quote_convention` SET TAGS ('dbx_value_regex' = 'direct|indirect|cross');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `quote_currency` SET TAGS ('dbx_business_glossary_term' = 'Quote Currency Code');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `quote_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `rate_source` SET TAGS ('dbx_business_glossary_term' = 'Rate Data Source');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `rate_source_identifier` SET TAGS ('dbx_business_glossary_term' = 'Rate Source Identifier');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `rate_status` SET TAGS ('dbx_business_glossary_term' = 'Rate Status');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `rate_status` SET TAGS ('dbx_value_regex' = 'active|stale|indicative|verified|rejected');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `rate_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Rate Observation Timestamp');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `rate_type` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate Type');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `rate_type` SET TAGS ('dbx_value_regex' = 'spot|forward|swap|cross');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `spot_rate` SET TAGS ('dbx_business_glossary_term' = 'Spot Exchange Rate');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `trading_session` SET TAGS ('dbx_business_glossary_term' = 'Trading Session');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `trading_session` SET TAGS ('dbx_value_regex' = 'london|new_york|tokyo|sydney|hong_kong|continuous');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `usage_context` SET TAGS ('dbx_business_glossary_term' = 'Rate Usage Context');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `usage_context` SET TAGS ('dbx_value_regex' = 'valuation|trading|hedging|reporting|stress_testing|scenario_analysis');
ALTER TABLE `asset_management`.`research`.`research_fx_rate` ALTER COLUMN `volatility_30d` SET TAGS ('dbx_business_glossary_term' = '30-Day Historical Volatility');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` SET TAGS ('dbx_subdomain' = 'investment_research');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `asset_class_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Outlook Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `asset_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `asset_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `asset_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `asset_peer_reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Peer Reviewer Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `asset_peer_reviewer_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `asset_peer_reviewer_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `climate_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Macroeconomic Scenario Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `peer_reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Peer Reviewer Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `superseded_by_outlook_asset_class_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Outlook Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `allocation_delta_percentage` SET TAGS ('dbx_business_glossary_term' = 'Allocation Delta Percentage');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equities|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `climate_scenario_alignment` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Alignment');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `confidence_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Level');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `current_allocation_percentage` SET TAGS ('dbx_business_glossary_term' = 'Current Allocation Percentage');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `data_sources` SET TAGS ('dbx_business_glossary_term' = 'Data Sources');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `document_url` SET TAGS ('dbx_business_glossary_term' = 'Document Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `expected_return_percentage` SET TAGS ('dbx_business_glossary_term' = 'Expected Return Percentage');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `expected_volatility_percentage` SET TAGS ('dbx_business_glossary_term' = 'Expected Volatility Percentage');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Focus');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `ic_decision` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `ic_decision` SET TAGS ('dbx_value_regex' = 'approved|approved_with_conditions|rejected|deferred');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `ic_presentation_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Presentation Date');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `ic_presentation_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Presentation Flag');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `investment_opportunities` SET TAGS ('dbx_business_glossary_term' = 'Investment Opportunities');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `investment_view` SET TAGS ('dbx_business_glossary_term' = 'Investment View');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `investment_view` SET TAGS ('dbx_value_regex' = 'overweight|neutral|underweight|avoid');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `key_drivers` SET TAGS ('dbx_business_glossary_term' = 'Key Drivers');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `key_risks` SET TAGS ('dbx_business_glossary_term' = 'Key Risks');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `methodology_description` SET TAGS ('dbx_business_glossary_term' = 'Methodology Description');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `outlook_horizon_years` SET TAGS ('dbx_business_glossary_term' = 'Outlook Horizon Years');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `outlook_identifier` SET TAGS ('dbx_business_glossary_term' = 'Outlook Identifier');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `outlook_status` SET TAGS ('dbx_business_glossary_term' = 'Outlook Status');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `outlook_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|published|superseded|archived');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `peer_review_status` SET TAGS ('dbx_business_glossary_term' = 'Peer Review Status');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `peer_review_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed|waived');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `publication_date` SET TAGS ('dbx_business_glossary_term' = 'Publication Date');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `research_team` SET TAGS ('dbx_business_glossary_term' = 'Research Team');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `review_frequency_months` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency Months');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `sector_focus` SET TAGS ('dbx_business_glossary_term' = 'Sector Focus');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `sharpe_ratio` SET TAGS ('dbx_business_glossary_term' = 'Sharpe Ratio');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `sub_asset_class` SET TAGS ('dbx_business_glossary_term' = 'Sub-Asset Class');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `target_allocation_percentage` SET TAGS ('dbx_business_glossary_term' = 'Target Allocation Percentage');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Outlook Title');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `valuation_assessment` SET TAGS ('dbx_business_glossary_term' = 'Valuation Assessment');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `valuation_assessment` SET TAGS ('dbx_value_regex' = 'expensive|fair_value|cheap|mixed');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `valuation_metric` SET TAGS ('dbx_business_glossary_term' = 'Valuation Metric');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `valuation_metric_value` SET TAGS ('dbx_business_glossary_term' = 'Valuation Metric Value');
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` SET TAGS ('dbx_subdomain' = 'macro_modeling');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `capital_market_assumption_id` SET TAGS ('dbx_business_glossary_term' = 'Capital Market Assumption (CMA) ID');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `climate_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `superseded_by_assumption_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Capital Market Assumption (CMA) ID');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|pending_review|approved|rejected|superseded');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equities|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `assumption_code` SET TAGS ('dbx_business_glossary_term' = 'Capital Market Assumption (CMA) Code');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `assumption_name` SET TAGS ('dbx_business_glossary_term' = 'Capital Market Assumption (CMA) Name');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `assumption_owner` SET TAGS ('dbx_business_glossary_term' = 'Assumption Owner');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `assumption_type` SET TAGS ('dbx_business_glossary_term' = 'Capital Market Assumption (CMA) Type');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `assumption_type` SET TAGS ('dbx_value_regex' = 'expected_return|volatility|correlation|risk_premium|inflation|interest_rate');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `benchmark_reference` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Reference');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `calibration_date` SET TAGS ('dbx_business_glossary_term' = 'Calibration Date');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `climate_scenario_alignment` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Alignment');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `confidence_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `correlation_coefficient` SET TAGS ('dbx_business_glossary_term' = 'Correlation Coefficient');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `documentation_url` SET TAGS ('dbx_business_glossary_term' = 'Documentation Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `expected_return_percentage` SET TAGS ('dbx_business_glossary_term' = 'Expected Return Percentage');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `expected_volatility_percentage` SET TAGS ('dbx_business_glossary_term' = 'Expected Volatility Percentage');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `ic_presentation_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Presentation Date');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `ic_presentation_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Presentation Flag');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `inflation_assumption_percentage` SET TAGS ('dbx_business_glossary_term' = 'Inflation Assumption Percentage');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `methodology_description` SET TAGS ('dbx_business_glossary_term' = 'Methodology Description');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `real_return_percentage` SET TAGS ('dbx_business_glossary_term' = 'Real Return Percentage');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `review_frequency_months` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency (Months)');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `risk_free_rate_percentage` SET TAGS ('dbx_business_glossary_term' = 'Risk-Free Rate Percentage');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `risk_premium_bps` SET TAGS ('dbx_business_glossary_term' = 'Risk Premium (Basis Points)');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `sector_scope` SET TAGS ('dbx_business_glossary_term' = 'Sector Scope');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `sharpe_ratio` SET TAGS ('dbx_business_glossary_term' = 'Sharpe Ratio');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `stress_testing_enabled` SET TAGS ('dbx_business_glossary_term' = 'Stress Testing Enabled Flag');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `time_horizon_years` SET TAGS ('dbx_business_glossary_term' = 'Time Horizon (Years)');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `usage_context` SET TAGS ('dbx_business_glossary_term' = 'Usage Context');
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`research`.`calendar` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`research`.`calendar` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`calendar` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`calendar` SET TAGS ('dbx_subdomain' = 'investment_research');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Calendar ID');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `analyst_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Owner Analyst ID');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Owner Analyst ID');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `macro_indicator_id` SET TAGS ('dbx_business_glossary_term' = 'Indicator ID');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `parent_event_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Event ID');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `research_report_id` SET TAGS ('dbx_business_glossary_term' = 'Report ID');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `actual_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Date');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `actual_end_time` SET TAGS ('dbx_business_glossary_term' = 'Actual End Time');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `actual_start_time` SET TAGS ('dbx_business_glossary_term' = 'Actual Start Time');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `asset_class_relevance` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Relevance');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `attendee_count` SET TAGS ('dbx_business_glossary_term' = 'Attendee Count');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `distribution_list` SET TAGS ('dbx_business_glossary_term' = 'Distribution List');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Duration Minutes');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `event_category` SET TAGS ('dbx_business_glossary_term' = 'Event Category');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `event_category` SET TAGS ('dbx_value_regex' = 'macroeconomic|market_data|research_publication|governance|external_event');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `event_description` SET TAGS ('dbx_business_glossary_term' = 'Event Description');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `event_identifier` SET TAGS ('dbx_business_glossary_term' = 'Event Identifier');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `event_source` SET TAGS ('dbx_business_glossary_term' = 'Event Source');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `event_source` SET TAGS ('dbx_value_regex' = 'internal|external|bloomberg|factset|central_bank|regulatory_body');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `event_status` SET TAGS ('dbx_business_glossary_term' = 'Event Status');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `event_status` SET TAGS ('dbx_value_regex' = 'scheduled|confirmed|postponed|cancelled|completed');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `event_title` SET TAGS ('dbx_business_glossary_term' = 'Event Title');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `event_type` SET TAGS ('dbx_business_glossary_term' = 'Event Type');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `external_reference_code` SET TAGS ('dbx_business_glossary_term' = 'External Reference ID');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `external_url` SET TAGS ('dbx_business_glossary_term' = 'External Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `ic_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Meeting Date');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `ic_presentation_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Presentation Flag');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `indicator_name` SET TAGS ('dbx_business_glossary_term' = 'Indicator Name');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `location` SET TAGS ('dbx_business_glossary_term' = 'Location');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `notification_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Notification Required Flag');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `notification_sent_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Notification Sent Timestamp');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `owner_team` SET TAGS ('dbx_business_glossary_term' = 'Owner Team');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Priority Level');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `recurrence_end_date` SET TAGS ('dbx_business_glossary_term' = 'Recurrence End Date');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `recurrence_pattern` SET TAGS ('dbx_business_glossary_term' = 'Recurrence Pattern');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `recurrence_pattern` SET TAGS ('dbx_value_regex' = 'one_time|daily|weekly|monthly|quarterly|annually');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `scheduled_date` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Date');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `scheduled_end_time` SET TAGS ('dbx_business_glossary_term' = 'Scheduled End Time');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `scheduled_start_time` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Start Time');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `sector_relevance` SET TAGS ('dbx_business_glossary_term' = 'Sector Relevance');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `tags` SET TAGS ('dbx_business_glossary_term' = 'Tags');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `time_zone` SET TAGS ('dbx_business_glossary_term' = 'Time Zone');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `visibility_scope` SET TAGS ('dbx_business_glossary_term' = 'Visibility Scope');
ALTER TABLE `asset_management`.`research`.`calendar` ALTER COLUMN `visibility_scope` SET TAGS ('dbx_value_regex' = 'public|internal|restricted|confidential');
ALTER TABLE `asset_management`.`research`.`data_vendor` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`research`.`data_vendor` SET TAGS ('dbx_domain' = 'research');
ALTER TABLE `asset_management`.`research`.`data_vendor` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`research`.`data_vendor` SET TAGS ('dbx_subdomain' = 'market_data');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `data_vendor_id` SET TAGS ('dbx_business_glossary_term' = 'Data Vendor Identifier (ID)');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Actor Id (Foreign Key)');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `kyc_record_id` SET TAGS ('dbx_business_glossary_term' = 'Kyc Record Id (Foreign Key)');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `annual_cost` SET TAGS ('dbx_business_glossary_term' = 'Annual Subscription Cost');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `annual_cost` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `asset_class_coverage` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Coverage');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `auto_renewal_flag` SET TAGS ('dbx_business_glossary_term' = 'Auto Renewal Flag');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `backup_vendor_available_flag` SET TAGS ('dbx_business_glossary_term' = 'Backup Vendor Available Flag');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `business_owner_name` SET TAGS ('dbx_business_glossary_term' = 'Business Owner Name');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `consuming_systems` SET TAGS ('dbx_business_glossary_term' = 'Consuming Systems');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `contract_end_date` SET TAGS ('dbx_business_glossary_term' = 'Contract End Date');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `contract_renewal_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Renewal Date');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `contract_start_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Start Date');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `cost_currency` SET TAGS ('dbx_business_glossary_term' = 'Cost Currency Code');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `cost_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `data_classification_level` SET TAGS ('dbx_business_glossary_term' = 'Data Classification Level');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `data_classification_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `data_coverage_scope` SET TAGS ('dbx_business_glossary_term' = 'Data Coverage Scope');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `data_delivery_method` SET TAGS ('dbx_business_glossary_term' = 'Data Delivery Method');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `data_delivery_method` SET TAGS ('dbx_value_regex' = 'api|sftp|file_transfer|terminal|direct_feed|web_portal');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `data_quality_sla_pct` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Service Level Agreement (SLA) Percentage');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `data_retention_period_days` SET TAGS ('dbx_business_glossary_term' = 'Data Retention Period Days');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `data_steward_name` SET TAGS ('dbx_business_glossary_term' = 'Data Steward Name');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `delivery_frequency` SET TAGS ('dbx_business_glossary_term' = 'Data Delivery Frequency');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `delivery_frequency` SET TAGS ('dbx_value_regex' = 'real_time|intraday|daily|weekly|monthly|on_demand');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `documentation_url` SET TAGS ('dbx_business_glossary_term' = 'Documentation Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `geographic_coverage` SET TAGS ('dbx_business_glossary_term' = 'Geographic Coverage');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `last_vendor_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Vendor Review Date');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `next_vendor_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Vendor Review Date');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Vendor Notes');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `notice_period_days` SET TAGS ('dbx_business_glossary_term' = 'Notice Period Days');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `primary_use_case` SET TAGS ('dbx_business_glossary_term' = 'Primary Use Case');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `regulatory_compliance_scope` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Scope');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `uptime_sla_pct` SET TAGS ('dbx_business_glossary_term' = 'Uptime Service Level Agreement (SLA) Percentage');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `usage_based_pricing_flag` SET TAGS ('dbx_business_glossary_term' = 'Usage Based Pricing Flag');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `user_license_count` SET TAGS ('dbx_business_glossary_term' = 'User License Count');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_code` SET TAGS ('dbx_business_glossary_term' = 'Vendor Code');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Vendor Contact Email Address');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Vendor Contact Name');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_contact_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Vendor Contact Phone Number');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_criticality` SET TAGS ('dbx_business_glossary_term' = 'Vendor Criticality');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_criticality` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_name` SET TAGS ('dbx_business_glossary_term' = 'Vendor Legal Name');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_performance_score` SET TAGS ('dbx_business_glossary_term' = 'Vendor Performance Score');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_status` SET TAGS ('dbx_business_glossary_term' = 'Vendor Status');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|under_review|terminated');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_support_tier` SET TAGS ('dbx_business_glossary_term' = 'Vendor Support Tier');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_support_tier` SET TAGS ('dbx_value_regex' = 'standard|premium|enterprise|dedicated');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_type` SET TAGS ('dbx_business_glossary_term' = 'Vendor Type');
ALTER TABLE `asset_management`.`research`.`data_vendor` ALTER COLUMN `vendor_type` SET TAGS ('dbx_value_regex' = 'market_data|research|analytics|esg_ratings|index_provider|reference_data');
