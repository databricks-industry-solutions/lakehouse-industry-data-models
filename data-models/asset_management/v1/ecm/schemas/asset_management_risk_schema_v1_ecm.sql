-- Schema for Domain: risk | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:29

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`risk` COMMENT 'Domain for enterprise risk management and macroeconomic stress testing including market risk (VaR, CVaR, DV01), liquidity risk, counterparty/credit risk, concentration risk, factor risk decomposition, scenario analysis, and sensitivity modeling.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`risk`.`limit` (
    `limit_id` BIGINT COMMENT 'Unique identifier for the risk limit record.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Risk limit approvals require documented accountability per regulatory frameworks (BCBS 239). Pension funds must track which employee authorized each limit for audit trails and IC governance.',
    `counterparty_id` BIGINT COMMENT 'Identifier of the counterparty to which this limit applies, for counterparty credit risk and exposure limits.',
    `portfolio_id` BIGINT COMMENT 'Identifier of the specific portfolio to which this limit applies, if limit is portfolio-specific rather than enterprise-wide.',
    `rule_id` BIGINT COMMENT 'Foreign key linking to compliance.rule. Business justification: Risk limits with regulatory_requirement_flag=true are established to comply with specific regulatory rules. Links limit to its governing compliance rule.',
    `strategy_id` BIGINT COMMENT 'Identifier of the investment strategy to which this limit applies, if limit is strategy-specific.',
    `approval_date` DATE COMMENT 'Date on which this limit was formally approved by the designated authority.',
    `asset_class` STRING COMMENT 'Asset class to which this limit applies: public equities, private equity, real estate, infrastructure, natural resources, credit, or multi-asset. [ENUM-REF-CANDIDATE',
    `breach_count_ytd` BIGINT COMMENT 'Number of times this limit has been breached in the current calendar year.',
    `breach_tolerance_lower` DECIMAL(20,4) COMMENT 'Lower threshold defining the soft breach tolerance band below the limit value, triggering monitoring alerts before hard breach.',
    `breach_tolerance_upper` DECIMAL(20,4) COMMENT 'Upper threshold defining the soft breach tolerance band above the limit value, triggering monitoring alerts before hard breach.',
    `calculation_methodology` STRING COMMENT 'Methodology used to calculate the risk metric: historical simulation, parametric, Monte Carlo, or other quantitative approach.',
    `limit_code` STRING COMMENT 'Business-assigned unique code identifying the limit for operational reference and reporting.. Valid values are `^[A-Z0-9_-]{4,20}$`',
    `confidence_level` DECIMAL(5,2) COMMENT 'Statistical confidence level used for VaR and CVaR calculations, typically expressed as a percentage (e.g., 95.00, 99.00).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this limit record was first created in the system.',
    `currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the limit value is denominated.. Valid values are `^[A-Z]{3}$`',
    `effective_date` DATE COMMENT 'Date from which the limit becomes active and enforceable.',
    `escalation_level` STRING COMMENT 'Organizational level to which limit breaches must be escalated: portfolio manager, Chief Investment Officer (CIO), Chief Risk Officer (CRO), Investment Committee (IC), or Board.. Valid values are `portfolio_manager|cio|cro|ic|board`',
    `escalation_procedure` STRING COMMENT 'Documented procedure and workflow to be followed when the limit is breached, including notification and approval requirements.',
    `expiry_date` DATE COMMENT 'Date on which the limit expires and is no longer enforced, nullable for perpetual limits.',
    `geographic_region` STRING COMMENT 'Geographic region or country to which this limit applies, for concentration and geographic exposure limits.',
    `last_breach_date` DATE COMMENT 'Date of the most recent breach of this limit.',
    `last_review_date` DATE COMMENT 'Date of the most recent formal review of this limit by risk management or the Investment Committee.',
    `limit_status` STRING COMMENT 'Current lifecycle status of the risk limit indicating whether it is actively enforced, suspended, expired, awaiting approval, or retired.. Valid values are `active|suspended|expired|pending_approval|retired`',
    `limit_type` STRING COMMENT 'Category of risk limit: Value at Risk (VaR), Conditional Value at Risk (CVaR), Dollar Value of 01 (DV01), concentration, leverage, or liquidity.. Valid values are `VaR|CVaR|DV01|concentration|leverage|liquidity`',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this limit record was last modified or updated.',
    `monitoring_frequency` STRING COMMENT 'Frequency at which the limit is monitored and compliance is assessed: real-time, daily, weekly, monthly, or quarterly.. Valid values are `real_time|daily|weekly|monthly|quarterly`',
    `limit_name` STRING COMMENT 'Human-readable name describing the purpose and scope of the risk limit.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal review of this limit.',
    `notes` STRING COMMENT 'Additional notes, comments, or context regarding the limit, its application, or special considerations.',
    `rationale` STRING COMMENT 'Business rationale and justification for establishing this limit at the specified level, including risk appetite considerations.',
    `regulatory_reference` STRING COMMENT 'Citation of the specific regulatory rule, guideline, or framework that mandates this limit, if applicable.',
    `regulatory_requirement_flag` BOOLEAN COMMENT 'Indicates whether this limit is mandated by regulatory requirements (True) or is an internal risk management control (False).',
    `review_frequency` STRING COMMENT 'Frequency at which the limit is formally reviewed and potentially recalibrated by risk management and the Investment Committee.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `risk_system_source` STRING COMMENT 'Source system from which the limit and its monitoring data originate: BlackRock Aladdin, MSCI Barra, SimCorp Dimension, or internal risk platform.. Valid values are `aladdin|msci_barra|simcorp|internal`',
    `sector` STRING COMMENT 'Economic sector or industry to which this limit applies, for sector concentration limits.',
    `time_horizon_days` BIGINT COMMENT 'Time horizon in days over which the risk metric is calculated, commonly 1-day or 10-day for VaR.',
    `unit` STRING COMMENT 'Unit of measure for the limit value: currency amount, percentage, basis points (bps), notional value, or number of shares.. Valid values are `currency|percentage|bps|notional|shares`',
    `utilization_percentage` DECIMAL(5,2) COMMENT 'Current utilization of the limit expressed as a percentage of the limit value, calculated as (current exposure / limit value) * 100.',
    `value` DECIMAL(20,4) COMMENT 'Numeric threshold value defining the maximum allowable exposure or risk metric for this limit.',
    CONSTRAINT pk_limit PRIMARY KEY(`limit_id`)
) COMMENT 'Master registry of enterprise risk limits and thresholds governing investment exposures across all asset classes and portfolios. Captures limit type (VaR, CVaR, DV01, concentration, leverage, liquidity), limit value, breach tolerance bands, escalation';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`factor` (
    `factor_id` BIGINT COMMENT 'Unique identifier for the systematic risk factor in the master catalog.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Risk factor approval is part of model governance framework. Pension funds must track who approved each factor for use in risk models and attribution analysis.',
    `macro_indicator_id` BIGINT COMMENT 'Foreign key linking to research.macro_indicator. Business justification: Risk factors (inflation, GDP growth, rates) are derived from macro indicators tracked by research.',
    `risk_model_id` BIGINT COMMENT 'Identifier of the parent risk model or factor framework to which this factor belongs.',
    `annualized_volatility_pct` DECIMAL(10,4) COMMENT 'Annualized standard deviation of the factor returns, expressed as a percentage, representing the factors historical volatility.',
    `approval_date` DATE COMMENT 'Date on which the factor was approved for production use by the governing authority.',
    `approval_status` STRING COMMENT 'Governance approval status of the factor for use in production risk analytics (approved, pending, rejected, under review).. Valid values are `approved|pending|rejected|under_review`',
    `asset_class` STRING COMMENT 'Primary asset class to which this factor applies (equity, fixed income, real estate, infrastructure, private equity, natural resources, multi-asset). [ENUM-REF-CANDIDATE',
    `benchmark_index_code` STRING COMMENT 'Code of the benchmark index or universe against which this factor is constructed or measured (e.g., MSCI ACWI, Bloomberg Barclays Aggregate).',
    `beta_to_market` DECIMAL(10,4) COMMENT 'Systematic risk measure representing the factors sensitivity to broad market movements, calculated via regression against market index.',
    `calculation_methodology` STRING COMMENT 'Description of the mathematical or statistical methodology used to construct the factor (e.g., cross-sectional regression, principal component analysis, fundamental ratio).',
    `factor_category` STRING COMMENT 'High-level classification of the factor by asset class or risk domain.. Valid values are `equity_style|fixed_income|macro|alternative|currency|commodity`',
    `factor_code` STRING COMMENT 'Standardized alphanumeric code uniquely identifying the factor across risk systems (e.g., VAL_FACTOR, MOM_FACTOR, DUR_FACTOR).. Valid values are `^[A-Z0-9_]{3,20}$`',
    `correlation_to_market` DECIMAL(5,4) COMMENT 'Correlation coefficient between the factor returns and the broad market index returns, ranging from -1 to +1.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the factor record was first created in the master catalog.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Quantitative score representing the quality, completeness, and reliability of the factor data, typically on a 0-100 scale.',
    `data_source` STRING COMMENT 'Primary data source or vendor providing the factor data (e.g., MSCI Barra, BlackRock Aladdin, Bloomberg, internal proprietary model).',
    `factor_description` STRING COMMENT 'Detailed business description of the factor, its economic rationale, and how it captures systematic risk or return drivers.',
    `effective_from_date` DATE COMMENT 'Date from which this factor definition became effective and available for use in risk analytics.',
    `effective_to_date` DATE COMMENT 'Date until which this factor definition is effective; null for currently active factors.',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether this factor incorporates Environmental, Social, and Governance (ESG) criteria in its construction (True) or not (False).',
    `factor_status` STRING COMMENT 'Current lifecycle status of the factor in the catalog (active, deprecated, under review, pending approval).. Valid values are `active|deprecated|under_review|pending_approval`',
    `factor_type` STRING COMMENT 'Classification of the factor by its construction methodology (style, statistical, macroeconomic, fundamental, technical).. Valid values are `style|statistical|macroeconomic|fundamental|technical`',
    `family` STRING COMMENT 'Grouping of related factors into a family (e.g., Equity Style Factors, Term Structure Factors, Volatility Factors).',
    `information_ratio` DECIMAL(10,4) COMMENT 'Ratio of active return to tracking error, measuring the factors risk-adjusted outperformance relative to a benchmark.',
    `is_active` BOOLEAN COMMENT 'Indicates whether the factor is currently active and used in risk decomposition and attribution (True) or deprecated (False).',
    `is_proprietary` BOOLEAN COMMENT 'Indicates whether the factor is a proprietary internal model (True) or sourced from an external vendor (False).',
    `last_rebalance_date` DATE COMMENT 'Most recent date on which the factor exposures or constituents were recalculated or rebalanced.',
    `last_review_date` DATE COMMENT 'Most recent date on which the factor underwent governance review and validation.',
    `loading_interpretation` STRING COMMENT 'Business interpretation guidance for positive and negative factor exposures (e.g., positive loading indicates value tilt, negative indicates growth tilt).',
    `max_drawdown_pct` DECIMAL(10,4) COMMENT 'Largest peak-to-trough decline in the factors cumulative return history, expressed as a percentage.',
    `factor_name` STRING COMMENT 'Human-readable name of the risk factor (e.g., Value, Momentum, Duration, Credit Spread).',
    `next_rebalance_date` DATE COMMENT 'Scheduled date for the next factor rebalance or recalculation.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next governance review and validation of the factor.',
    `rebalance_frequency` STRING COMMENT 'Frequency at which the factor exposures or constituents are recalculated or rebalanced (daily, weekly, monthly, quarterly, annual, ad hoc).. Valid values are `daily|weekly|monthly|quarterly|annual|ad_hoc`',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this factor is required for regulatory risk reporting to SEC, or other governing bodies (True) or not (False).',
    `return_history_end_date` DATE COMMENT 'Most recent date for which historical factor return data is available.',
    `return_history_start_date` DATE COMMENT 'Earliest date for which historical factor return data is available.',
    `review_frequency` STRING COMMENT 'Scheduled frequency for governance review and validation of the factor definition and performance (monthly, quarterly, semi-annual, annual, ad hoc).. Valid values are `monthly|quarterly|semi_annual|annual|ad_hoc`',
    `sharpe_ratio` DECIMAL(10,4) COMMENT 'Risk-adjusted return metric for the factor, calculated as excess return over risk-free rate divided by volatility.',
    `unit` STRING COMMENT 'Unit of measure for the factor exposure or return (e.g., standard deviations, basis points (bps), percentage, ratio).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the factor record was last modified in the master catalog.',
    `usage_in_stress_testing` BOOLEAN COMMENT 'Indicates whether this factor is used in macroeconomic stress testing and scenario analysis (True) or not (False).',
    `usage_in_var_calculation` BOOLEAN COMMENT 'Indicates whether this factor is included in the portfolio Value at Risk (VaR) calculation (True) or excluded (False).',
    `vendor_model_name` STRING COMMENT 'Name of the vendor risk model or factor library from which this factor is sourced (e.g., Barra Global Equity Model, Aladdin Risk Model).',
    `vendor_model_version` STRING COMMENT 'Version identifier of the vendor risk model or factor library.',
    `vintage_year` BIGINT COMMENT 'Year in which the factor model or definition was first introduced or last materially revised.',
    CONSTRAINT pk_factor PRIMARY KEY(`factor_id`)
) COMMENT 'Master catalog of systematic risk factors used in factor-based risk decomposition and attribution across the investment portfolio. Covers equity style factors (value, momentum, quality, size, low-volatility), fixed income factors (duration, spread';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`model` (
    `model_id` BIGINT COMMENT 'Unique identifier for the risk model record.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Model risk management (SR 11-7) requires documented model approval. Pension funds must track which employee approved each risk model for regulatory compliance and governance.',
    `approval_date` DATE COMMENT 'Date when the model was formally approved for production use by the investment committee or model governance body.',
    `asset_class` STRING COMMENT 'Primary asset class scope for which this model is calibrated. [ENUM-REF-CANDIDATE: public_equities|private_equity|real_estate|infrastructure|natural_resources|credit|multi_asset — 7 candidates stripped; promote to reference product]',
    `backtesting_frequency` STRING COMMENT 'Frequency at which model performance is validated against actual outcomes.. Valid values are `daily|weekly|monthly|quarterly|annually|none`',
    `benchmark_index` STRING COMMENT 'Name or identifier of the benchmark index used for relative risk measurement or tracking error calculation.',
    `calculation_frequency` STRING COMMENT 'Frequency at which the model is executed and risk measures are updated.. Valid values are `daily|weekly|monthly|quarterly|on_demand`',
    `model_code` STRING COMMENT 'Externally-known unique code for the risk model used in system integrations and reporting.. Valid values are `^[A-Z0-9_-]{3,20}$`',
    `confidence_level` DECIMAL(5,4) COMMENT 'Statistical confidence level for the risk measure expressed as a decimal (e.g., 0.9500 for 95%, 0.9900 for 99%).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the model record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which risk measures are expressed.. Valid values are `^[A-Z]{3}$`',
    `data_source` STRING COMMENT 'Primary data source or system feeding input data to the model (e.g., Bloomberg, SimCorp Dimension, BlackRock Aladdin).',
    `documentation_url` STRING COMMENT 'URL or file path to the detailed model documentation, methodology paper, or validation report.',
    `effective_from_date` DATE COMMENT 'Date from which the model became active and began producing risk measures for decision-making.',
    `effective_to_date` DATE COMMENT 'Date when the model was retired or superseded; null for currently active models.',
    `factor_model_flag` BOOLEAN COMMENT 'Indicates whether the model uses factor decomposition for risk attribution.',
    `holding_period_days` BIGINT COMMENT 'Time horizon in days over which risk is measured.',
    `last_backtest_date` DATE COMMENT 'Date when the most recent backtesting validation was performed.',
    `last_calibration_date` DATE COMMENT 'Date when the model parameters were last recalibrated using updated historical data.',
    `limitations` STRING COMMENT 'Known limitations, assumptions, or constraints of the model that users should be aware of.',
    `lookback_window_days` BIGINT COMMENT 'Number of historical days used for model calibration and calculation.',
    `methodology_description` STRING COMMENT 'Detailed textual description of the model methodology, assumptions, and calculation approach.',
    `model_status` STRING COMMENT 'Current lifecycle status of the risk model.. Valid values are `active|inactive|under_review|deprecated|pending_approval|retired`',
    `model_type` STRING COMMENT 'Classification of the quantitative risk model methodology.. Valid values are `historical_simulation|monte_carlo|parametric|factor_based|stress_test|scenario_analysis`',
    `model_name` STRING COMMENT 'Human-readable name of the risk model.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal model review and validation by the model governance committee.',
    `notes` STRING COMMENT 'Additional free-text notes or comments about the model for operational or audit purposes.',
    `owner` STRING COMMENT 'Name or identifier of the business unit or individual responsible for the model.',
    `regulatory_approved_flag` BOOLEAN COMMENT 'Indicates whether the model has been approved by regulatory authorities for capital adequacy or reporting purposes.',
    `regulatory_framework` STRING COMMENT 'Name of the regulatory framework or standard the model complies with (e.g., Basel III guidelines, EMIR).',
    `risk_measure` STRING COMMENT 'Primary risk metric calculated by this model (VaR = Value at Risk, CVaR = Conditional Value at Risk, DV01 = Dollar Value of 01).. Valid values are `var|cvar|dv01|duration|beta|tracking_error`',
    `simulation_count` BIGINT COMMENT 'Number of Monte Carlo simulations or scenarios executed per model run; applicable to Monte Carlo and scenario-based models.',
    `stress_test_flag` BOOLEAN COMMENT 'Indicates whether the model is used for macroeconomic stress testing and scenario analysis.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the model record was last modified.',
    `vendor` STRING COMMENT 'Name of the external vendor or system providing the model (e.g., BlackRock Aladdin, MSCI RiskMetrics, Barra, internal proprietary).',
    `version` STRING COMMENT 'Version identifier of the model implementation for change tracking and audit purposes.. Valid values are `^[0-9]+.[0-9]+(.[0-9]+)?$`',
    CONSTRAINT pk_model PRIMARY KEY(`model_id`)
) COMMENT 'Master registry of quantitative risk models deployed across the enterprise for VaR, CVaR, factor risk, and stress testing. Records model name, model type (historical simulation, Monte Carlo, parametric), confidence level, lookback window, asset class';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`stress_scenario` (
    `stress_scenario_id` BIGINT COMMENT 'Unique identifier for the stress scenario. Primary key.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Stress scenario approval is required for regulatory stress testing (ORSA, IORP II). Pension funds must document which employee approved each scenario for audit purposes.',
    `climate_scenario_id` BIGINT COMMENT 'Foreign key linking to esg.climate_scenario. Business justification: TCFD-mandated climate stress testing requires pension funds to apply standardized climate scenarios (RCP/SSP pathways) to financial stress tests.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: Pension fund stress testing requires linking risk stress scenarios to research economic scenarios.',
    `macro_indicator_id` BIGINT COMMENT 'Foreign key linking to the macroeconomic indicator being shocked',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Pension fund stress scenarios are mandated by specific regulators (PRA, EIOPA, local pension authorities). The regulatory_source field indicates this need.',
    `superseded_by_scenario_stress_scenario_id` BIGINT COMMENT 'Reference to the stress scenario that supersedes this one if deprecated. Null if current.',
    `approval_date` DATE COMMENT 'Date when the scenario was formally approved for use in stress testing.',
    `asset_class_scope` STRING COMMENT 'Comma-separated list of asset classes covered by this scenario (e.g., public equities, private equity, real estate, infrastructure, credit, natural resources).',
    `commodity_shock_percent` DECIMAL(10,4) COMMENT 'Percentage change in commodity prices (e.g., oil, natural gas, metals). Positive for price increases, negative for decreases.',
    `counterparty_default_rate_percent` DECIMAL(10,4) COMMENT 'Assumed percentage of counterparties that default under the scenario.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the stress scenario record was first created in the system.',
    `credit_spread_shock_bps` BIGINT COMMENT 'Widening or tightening of credit spreads in basis points (bps). Positive for widening, negative for tightening.',
    `cvar_confidence_level_percent` DECIMAL(5,2) COMMENT 'Confidence level used for CVaR (Expected Shortfall) calculations under this scenario (e.g., 95.00, 99.00). Null if not applicable.',
    `effective_date` DATE COMMENT 'Date from which this shock parameter specification is effective. Allows versioning of shock assumptions over time. Identified in detection phase.',
    `equity_shock_percent` DECIMAL(10,4) COMMENT 'Percentage change applied to equity markets in this scenario (e.g., -40.0000 for 40% decline). Positive for gains, negative for losses.',
    `external_scenario_code` STRING COMMENT 'Identifier used by the external vendor or regulatory body for this scenario. Null for internal scenarios.',
    `fx_shock_percent` DECIMAL(10,4) COMMENT 'Percentage change in foreign exchange rates (e.g., domestic currency depreciation or appreciation). Positive for appreciation, negative for depreciation.',
    `gdp_shock_percent` DECIMAL(10,4) COMMENT 'Percentage change in GDP growth rate under the scenario (e.g., -5.0000 for 5% contraction).',
    `geographic_scope` STRING COMMENT 'Geographic regions or countries affected by the scenario (e.g., Global, North America, Europe, Emerging Markets). Use 3-letter ISO country codes where applicable.',
    `historical_event_date` DATE COMMENT 'Date of the historical event if the scenario is based on a past crisis (e.g., 2008-09-15 for Lehman collapse). Null for hypothetical scenarios.',
    `indicator_weight` DECIMAL(10,6) COMMENT 'Relative weight or importance of this indicators shock in the overall scenario impact calculation. Used for weighted stress metrics. Identified in detection phase.',
    `inflation_shock_percent` DECIMAL(10,4) COMMENT 'Percentage point change in inflation rate (e.g., +3.0000 for 3 percentage point increase in inflation).',
    `interest_rate_shock_bps` BIGINT COMMENT 'Parallel shift in interest rates expressed in basis points (bps). Positive for rate increases, negative for decreases (e.g., +300 for 3% hike).',
    `is_baseline` BOOLEAN COMMENT 'Flag indicating whether this is a baseline (no-stress) scenario used for comparison. True if baseline, False otherwise.',
    `is_regulatory_required` BOOLEAN COMMENT 'Flag indicating whether this scenario is mandated by a regulatory authority. True if required, False if discretionary.',
    `last_review_date` DATE COMMENT 'Date when the scenario was last reviewed for relevance and accuracy.',
    `liquidity_shock_description` STRING COMMENT 'Narrative description of liquidity stress conditions (e.g., bid-ask spreads widen 10x, redemption surge 20%, funding markets freeze).',
    `modified_by` STRING COMMENT 'Identifier of the user or system that last modified the stress scenario record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the stress scenario record was last modified.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next review of the scenario.',
    `probability_assessment` STRING COMMENT 'Qualitative assessment of the likelihood of the scenario occurring: very low, low, medium, high, very high, or not assessed.. Valid values are `very_low|low|medium|high|very_high|not_assessed`',
    `real_estate_shock_percent` DECIMAL(10,4) COMMENT 'Percentage change in real estate valuations. Positive for appreciation, negative for depreciation.',
    `recovery_rate_percent` DECIMAL(10,4) COMMENT 'Assumed recovery rate on defaulted exposures (e.g., 40.0000 for 40% recovery).',
    `regulatory_source` STRING COMMENT 'Name of the regulatory body or framework that mandated this scenario (e.g., EBA, CCAR). Null for internal scenarios.',
    `scenario_category` STRING COMMENT 'Broad category of the stress event: market shock, credit event, liquidity crisis, macroeconomic downturn, geopolitical, operational, climate, pandemic, or cyber.',
    `scenario_code` STRING COMMENT 'Unique business identifier code for the stress scenario (e.g., GFC_2008, COVID_SHOCK, RATE_HIKE_300).. Valid values are `^[A-Z0-9_-]{3,20}$`',
    `scenario_name` STRING COMMENT 'Human-readable name of the stress scenario (e.g., 2008 Global Financial Crisis, COVID-19 Market Shock, Oil Price Collapse).',
    `scenario_narrative` STRING COMMENT 'Detailed narrative describing the scenario storyline, including macroeconomic context, triggering events, and transmission channels.',
    `scenario_status` STRING COMMENT 'Current lifecycle status of the stress scenario: draft (under development), active (approved for use), archived (historical reference), deprecated (no longer used), or under review (pending approval).. Valid values are `draft|active|archived|deprecated|under_review`',
    `scenario_type` STRING COMMENT 'Classification of the stress scenario: historical (actual past event), hypothetical (plausible future event), regulatory (mandated by regulator), custom (bespoke internal), or reverse stress (identifies breaking point).. Valid values are `historical|hypothetical|regulatory|custom|reverse_stress`',
    `severity_level` STRING COMMENT 'Qualitative severity classification of the stress scenario: mild, moderate, severe, or extreme.. Valid values are `mild|moderate|severe|extreme`',
    `shock_direction` STRING COMMENT 'Direction of the shock: increase (positive shock), decrease (negative shock), or unchanged (indicator held constant). Identified in detection phase.',
    `shock_magnitude` DECIMAL(18,6) COMMENT 'The magnitude of the shock applied to this indicator in this scenario, expressed in the indicators native unit (percent, basis points, index points). Identified in detection phase.',
    `shock_magnitude_description` STRING COMMENT 'Narrative description of the magnitude and nature of the stress shock (e.g., equity markets down 40%, credit spreads widen 500 bps, GDP contracts 5%).',
    `time_horizon_months` BIGINT COMMENT 'Duration over which the stress scenario unfolds, expressed in months (e.g., 3, 6, 12, 24).',
    `unemployment_shock_percent` DECIMAL(10,4) COMMENT 'Percentage point change in unemployment rate (e.g., +5.0000 for 5 percentage point increase).',
    `usage_count` BIGINT COMMENT 'Number of times this scenario has been used in stress testing runs. Incremented with each execution.',
    `var_confidence_level_percent` DECIMAL(5,2) COMMENT 'Confidence level used for VaR calculations under this scenario (e.g., 95.00, 99.00). Null if not applicable.',
    `version_number` STRING COMMENT 'Version identifier for the scenario (e.g., 1.0, 2.1). Incremented when scenario parameters are updated.. Valid values are `^[0-9]+.[0-9]+$`',
    `volatility_shock_percent` DECIMAL(10,4) COMMENT 'Percentage change in market volatility (e.g., VIX increase). Positive for volatility spike, negative for compression.',
    `created_by` STRING COMMENT 'Identifier of the user or system that created the stress scenario record.',
    CONSTRAINT pk_stress_scenario PRIMARY KEY(`stress_scenario_id`)
) COMMENT 'Master catalog of macroeconomic and market stress scenarios used for portfolio stress testing and sensitivity analysis. Each scenario defines a named event (e.g., 2008 GFC, COVID-19 shock, rate hike +300bps, oil price collapse), scenario type (historical';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`var_calculation` (
    `var_calculation_id` BIGINT COMMENT 'Unique identifier for each VaR calculation run. Primary key for the var_calculation product.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: VaR calculations require approval sign-off for regulatory capital reporting. Pension funds must track approver for daily risk reporting governance and IC oversight.',
    `calculation_run_id` BIGINT COMMENT 'Business identifier for the calculation batch or run, used for grouping related VaR calculations executed together.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio or position set against which this VaR calculation was performed.',
    `risk_model_id` BIGINT COMMENT 'Reference to the risk model configuration used for this VaR calculation, defining methodology and parameters.',
    `stress_scenario_id` BIGINT COMMENT 'Reference to a specific stress test or market scenario applied during the VaR calculation, if applicable.',
    `valuation_cycle_id` BIGINT COMMENT 'Foreign key linking to valuation.cycle. Business justification: VaR calculations must reference the valuation cycle ensuring risk metrics use consistent, audited asset values.',
    `approval_timestamp` TIMESTAMP COMMENT 'Timestamp when the VaR calculation result was formally approved for reporting and decision-making purposes.',
    `asset_class_scope` STRING COMMENT 'Comma-separated list of asset classes included in this VaR calculation, such as equities, fixed income, FX, commodities, alternatives.',
    `backtesting_exceptions` BIGINT COMMENT 'Number of times actual losses exceeded the VaR estimate during the backtesting period, used to assess model accuracy.',
    `backtesting_period_end` DATE COMMENT 'End date of the backtesting period used to validate the VaR model accuracy against actual portfolio returns.',
    `backtesting_period_start` DATE COMMENT 'Start date of the backtesting period used to validate the VaR model accuracy against actual portfolio returns.',
    `calculation_date` DATE COMMENT 'The business date on which this VaR calculation was performed, representing the as-of date for the risk assessment.',
    `calculation_duration_seconds` DECIMAL(10,2) COMMENT 'Time taken to complete the VaR calculation, measured in seconds, used for performance monitoring.',
    `calculation_engine` STRING COMMENT 'Name of the risk analytics platform or engine that performed the calculation, such as BlackRock Aladdin or MSCI RiskMetrics.',
    `calculation_notes` STRING COMMENT 'Free-text notes or comments regarding special circumstances, assumptions, or observations related to this VaR calculation.',
    `calculation_status` STRING COMMENT 'Current status of the VaR calculation run, indicating whether it completed successfully or encountered issues.. Valid values are `completed|failed|in_progress|pending|cancelled`',
    `calculation_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the VaR calculation was executed, capturing the exact moment of computation.',
    `confidence_level` DECIMAL(5,4) COMMENT 'Statistical confidence level for the VaR calculation expressed as a decimal, typically 0.9500 for 95% or 0.9900 for 99%.',
    `correlation_matrix_version` STRING COMMENT 'Version identifier of the correlation matrix used in parametric VaR calculations, tracking model updates over time.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this VaR calculation record was first created in the system, for audit trail purposes.',
    `cvar_amount` DECIMAL(20,2) COMMENT 'The calculated CVaR or Expected Shortfall, representing the expected loss given that the loss exceeds the VaR threshold.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Quality score from 0 to 100 indicating the completeness and reliability of market data used in the VaR calculation.',
    `decomposition_available` BOOLEAN COMMENT 'Indicates whether detailed risk factor decomposition or contribution analysis is available for this VaR calculation.',
    `diversification_benefit` DECIMAL(20,2) COMMENT 'Reduction in VaR due to portfolio diversification, calculated as the difference between sum of individual VaRs and portfolio VaR.',
    `historical_lookback_days` BIGINT COMMENT 'Number of historical days of market data used in the VaR calculation, typically 250 to 500 trading days.',
    `holding_period_days` BIGINT COMMENT 'The time horizon in days over which the VaR is calculated, representing the period the portfolio is assumed to be held.',
    `incremental_risk_charge` DECIMAL(20,2) COMMENT 'Additional capital charge for default and migration risk in the trading book, complementing VaR measures.',
    `liquidity_horizon_days` BIGINT COMMENT 'Estimated time in days required to liquidate the portfolio positions without significant market impact, used for liquidity-adjusted VaR.',
    `market_data_source` STRING COMMENT 'Primary source of market data used for the VaR calculation, such as Bloomberg, Reuters, or internal pricing systems.',
    `methodology` STRING COMMENT 'The statistical methodology applied for VaR calculation: historical simulation, Monte Carlo simulation, parametric, or hybrid approach.. Valid values are `historical_simulation|monte_carlo|parametric|hybrid`',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this VaR calculation record was last modified, tracking any updates or corrections to the calculation.',
    `portfolio_value` DECIMAL(20,2) COMMENT 'The total market value of the portfolio at the calculation date, serving as the base for VaR percentage calculations.',
    `position_count` BIGINT COMMENT 'Total number of positions or securities included in the portfolio for this VaR calculation.',
    `regulatory_capital_multiplier` DECIMAL(5,2) COMMENT 'Multiplier applied to VaR for regulatory capital calculation purposes, typically ranging from 3.0 to 4.0 based on backtesting results.',
    `risk_factor_count` BIGINT COMMENT 'Number of distinct risk factors or market variables considered in the VaR model, such as equity indices, interest rates, FX rates.',
    `simulation_iterations` BIGINT COMMENT 'Number of simulation paths or iterations used in Monte Carlo VaR calculations, typically 10,000 or more.',
    `stress_var_amount` DECIMAL(20,2) COMMENT 'VaR calculated using a stressed historical period, typically a 12-month period of significant financial stress.',
    `var_amount` DECIMAL(20,2) COMMENT 'The calculated VaR amount representing the maximum expected loss at the specified confidence level over the holding period.',
    `var_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the VaR amount is denominated.. Valid values are `^[A-Z]{3}$`',
    `var_percentage` DECIMAL(7,4) COMMENT 'VaR amount expressed as a percentage of total portfolio value, calculated as VaR amount divided by portfolio value.',
    `volatility_adjustment_factor` DECIMAL(7,4) COMMENT 'Scaling factor applied to historical volatility estimates to account for current market conditions or regime changes.',
    CONSTRAINT pk_var_calculation PRIMARY KEY(`var_calculation_id`)
) COMMENT 'Transactional record of each Value-at-Risk (VaR) and Conditional Value-at-Risk (CVaR) calculation run performed against a portfolio or position set. Captures calculation date, portfolio scope, risk model used, confidence level (95%, 99%), holding period';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`risk_factor_exposure` (
    `risk_factor_exposure_id` BIGINT COMMENT 'Unique identifier for the risk factor exposure record. Primary key for this transactional snapshot of factor exposure at a point in time.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Factor exposure approvals are required for governance. Pension funds must track who approved material factor exposures for risk committee oversight.',
    `instrument_id` BIGINT COMMENT 'Foreign key linking to trade.instrument. Business justification: Factor risk models decompose returns at instrument level. Pension funds use Barra/Axioma models requiring instrument-to-factor mappings for risk attribution, tracking error analysis, and',
    `listed_security_id` BIGINT COMMENT 'Identifier of the individual security for which this factor exposure is calculated. Nullable when exposure is at portfolio level only.',
    `portfolio_id` BIGINT COMMENT 'Identifier of the portfolio for which this factor exposure is calculated. Links to the investment portfolio master.',
    `risk_factor_id` BIGINT COMMENT 'Identifier of the systematic risk factor to which exposure is measured (e.g., market factor, size factor, value factor, momentum, sector, country, currency).',
    `risk_model_id` BIGINT COMMENT 'Identifier of the risk model used to compute this factor exposure (e.g., MSCI Barra Global Equity Model, BlackRock Aladdin Fixed Income Model).',
    `stress_scenario_id` BIGINT COMMENT 'Identifier of the stress test scenario applied to this factor exposure. Nullable for baseline (non-stressed) exposures.',
    `active_exposure` DECIMAL(18,6) COMMENT 'The difference between the portfolios factor exposure and the benchmark factor exposure. Measures active risk positioning.',
    `approval_status` STRING COMMENT 'The approval status of this factor exposure record, particularly relevant when exposures breach limits and require IC or CRO approval.. Valid values are `approved|pending|rejected|override`',
    `approval_timestamp` TIMESTAMP COMMENT 'The date and time when this factor exposure or limit override was approved. Nullable for non-breach exposures.',
    `as_of_date` DATE COMMENT 'The business date for which this factor exposure snapshot is calculated. Represents the valuation date of the underlying positions.',
    `base_currency_code` STRING COMMENT 'The three-letter ISO 4217 base currency code of the portfolio for currency conversion and reporting purposes.. Valid values are `^[A-Z]{3}$`',
    `benchmark_exposure` DECIMAL(18,6) COMMENT 'The factor exposure of the portfolios benchmark index. Used to calculate active exposure and tracking error contribution.',
    `calculation_method` STRING COMMENT 'The statistical method used to compute the factor exposure: regression, covariance matrix, Monte Carlo simulation, or historical analysis.. Valid values are `regression|covariance|monte_carlo|historical`',
    `calculation_timestamp` TIMESTAMP COMMENT 'The precise date and time when this factor exposure was computed by the risk system. Supports audit trail and version control.',
    `comments` STRING COMMENT 'Free-text comments or notes from risk analysts regarding this factor exposure, limit breach rationale, or model adjustments.',
    `confidence_level` DECIMAL(5,2) COMMENT 'The confidence level associated with the factor exposure estimate, expressed as a percentage (e.g., 95.00, 99.00).',
    `contribution_to_risk_percentage` DECIMAL(10,4) COMMENT 'The percentage of total portfolio risk attributable to this factor exposure. Sum across all factors equals 100%.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this risk factor exposure record was first created in the lakehouse. Supports audit trail and data lineage.',
    `cvar_contribution` DECIMAL(18,2) COMMENT 'The contribution of this factor exposure to the portfolios Conditional Value at Risk (CVaR or Expected Shortfall), in base currency.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'A quality score (0-100) indicating the completeness and reliability of the input data used for this exposure calculation.',
    `exposure_currency_code` STRING COMMENT 'The three-letter ISO 4217 currency code in which the exposure value is denominated (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `exposure_direction` STRING COMMENT 'The directional bias of the factor exposure: long (positive exposure), short (negative exposure), or neutral (near-zero exposure).. Valid values are `long|short|neutral`',
    `exposure_percentage` DECIMAL(10,4) COMMENT 'The factor exposure expressed as a percentage of total portfolio risk or NAV. Facilitates relative comparison across factors.',
    `exposure_value` DECIMAL(18,6) COMMENT 'The numerical exposure of the portfolio or security to this risk factor. Typically expressed as a standardized beta or factor loading.',
    `factor_category` STRING COMMENT 'The high-level category of the risk factor: style (value, growth, momentum), industry, country, currency, macro (interest rate, inflation), or custom.. Valid values are `style|industry|country|currency|macro|custom`',
    `factor_return` DECIMAL(12,6) COMMENT 'The return of the risk factor itself over the measurement period. Used to compute factor-driven performance attribution.',
    `factor_type` STRING COMMENT 'Classification of the factor as systematic (common across securities), idiosyncratic (security-specific), or specific (custom defined).. Valid values are `systematic|idiosyncratic|specific`',
    `factor_volatility` DECIMAL(12,6) COMMENT 'The historical or implied volatility of the risk factor. Expressed as annualized standard deviation in percentage terms.',
    `fx_rate` DECIMAL(18,8) COMMENT 'The foreign exchange rate used to convert exposure from exposure currency to base currency as of the calculation date.',
    `is_material_exposure` BOOLEAN COMMENT 'Boolean flag indicating whether this factor exposure exceeds the materiality threshold defined in the risk policy (True) or not (False).',
    `limit_breach_flag` BOOLEAN COMMENT 'Boolean flag indicating whether this factor exposure breaches the defined risk limit (True) or is within limits (False).',
    `limit_utilization_percentage` DECIMAL(10,4) COMMENT 'The percentage of the risk limit consumed by this factor exposure. Values over 100% indicate a breach.',
    `lookback_period_days` BIGINT COMMENT 'The number of historical days used in the factor exposure calculation (e.g., 252 for one-year daily returns).',
    `marginal_contribution_to_risk` DECIMAL(18,6) COMMENT 'The marginal contribution of this factor exposure to total portfolio risk (VaR or volatility). Measures incremental risk impact.',
    `market_value` DECIMAL(18,2) COMMENT 'The market value of the position (security or portfolio) underlying this factor exposure, in base currency.',
    `model_version` STRING COMMENT 'The version identifier of the risk model used for this calculation (e.g., MSCI Barra GEM3, Aladdin v8.2). Supports model change tracking.',
    `notional_value` DECIMAL(18,2) COMMENT 'The notional value of derivative positions contributing to this factor exposure. Relevant for futures, swaps, and options.',
    `stressed_exposure_value` DECIMAL(18,6) COMMENT 'The factor exposure value under the applied stress scenario. Nullable for baseline exposures.',
    `t_statistic` DECIMAL(10,4) COMMENT 'The statistical significance measure of the factor exposure. Values above 2.0 typically indicate statistically significant exposure.',
    `tracking_error_contribution` DECIMAL(12,6) COMMENT 'The contribution of this factor exposure to the portfolios tracking error versus its benchmark, expressed in basis points.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this risk factor exposure record was last modified. Supports change tracking and version control.',
    `var_contribution` DECIMAL(18,2) COMMENT 'The contribution of this factor exposure to the portfolios total Value at Risk (VaR), in base currency.',
    CONSTRAINT pk_risk_factor_exposure PRIMARY KEY(`risk_factor_exposure_id`)
) COMMENT 'Transactional record of a portfolios or securitys exposure to each systematic risk factor at a point in time, as computed by the risk model (MSCI Barra or BlackRock Aladdin).';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`stress_test_result` (
    `stress_test_result_id` BIGINT COMMENT 'Unique identifier for the stress test result record.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Stress test results require approval for IC reporting and regulatory submissions. Pension funds must document which employee signed off on results.',
    `hedge_program_id` BIGINT COMMENT 'Foreign key linking to the hedge program being stress tested',
    `instrument_id` BIGINT COMMENT 'Foreign key linking to the financial instrument being stressed',
    `liability_projection_id` BIGINT COMMENT 'Foreign key linking to actuarial.liability_projection. Business justification: Regulatory stress testing (PRA) requires showing stressed asset values against liability projections to calculate stressed funded ratio.',
    `performance_calculation_run_id` BIGINT COMMENT 'Foreign key linking to performance.performance_calculation_run. Business justification: Stress tests use baseline NAV from performance calculations. Pension funds require traceability from stressed results to the specific performance run that established',
    `portfolio_id` BIGINT COMMENT 'Identifier of the portfolio or position set subjected to the stress test.',
    `stress_scenario_id` BIGINT COMMENT 'Identifier of the stress scenario applied in this test (e.g., market crash, interest rate shock, credit spread widening).',
    `stress_test_run_id` BIGINT COMMENT 'Identifier of the parent stress test execution run that generated this result.',
    `valuation_cycle_id` BIGINT COMMENT 'Foreign key linking to valuation.cycle. Business justification: Stress test results must identify which valuation cycles NAV was the base case. Regulatory stress testing (IORP II, local pension regulations) requires this audit trail for supervisory',
    `approval_date` DATE COMMENT 'Date on which the stress test result was formally approved.',
    `approval_status` STRING COMMENT 'Current approval status of the stress test result for reporting or decision-making purposes.. Valid values are `pending|approved|rejected|under_review`',
    `asset_class` STRING COMMENT 'Primary asset class of the portfolio or position set subjected to the stress test.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `base_cvar` DECIMAL(20,2) COMMENT 'Conditional Value at Risk (expected shortfall) of the portfolio before applying the stress scenario, in the reporting currency.',
    `base_nav` DECIMAL(20,2) COMMENT 'Net Asset Value of the portfolio before applying the stress scenario, in the reporting currency.',
    `base_var` DECIMAL(20,2) COMMENT 'Value at Risk of the portfolio before applying the stress scenario, in the reporting currency.',
    `breach_flag` BOOLEAN COMMENT 'Indicates whether the stress test result breached any defined risk limits or thresholds (True if breach occurred, False otherwise).',
    `breach_severity` STRING COMMENT 'Severity classification of any risk limit breach identified by the stress test result.. Valid values are `none|minor|moderate|major|critical`',
    `calculation_date` DATE COMMENT 'The as-of date for this stress test calculation. Stress tests are run periodically (daily, weekly, monthly) and results are point-in-time.',
    `calculation_methodology` STRING COMMENT 'Methodology used to calculate the stress test results (e.g., historical simulation, Monte Carlo, parametric VaR, hybrid approach).. Valid values are `historical_simulation|monte_carlo|parametric|hybrid`',
    `concentration_risk_score` DECIMAL(10,4) COMMENT 'Quantitative score measuring portfolio concentration risk under the stress scenario (higher values indicate greater concentration).',
    `confidence_level` DECIMAL(5,4) COMMENT 'Statistical confidence level used in the stress test risk calculations (e.g., 0.9500 for 95%, 0.9900 for 99%).',
    `counterparty_exposure_change` DECIMAL(20,2) COMMENT 'Change in aggregate counterparty credit exposure resulting from the stress scenario, in the reporting currency.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this stress test result record was first created in the system.',
    `currency` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this stress test result (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `effectiveness_under_stress` STRING COMMENT 'Assessment of whether the hedging relationship would remain effective under the stress scenario conditions, per IFRS 9 hedge accounting requirements. Determines if hedge accounting treatment could be maintained.',
    `factor_contribution_summary` STRING COMMENT 'Summary of key risk factor contributions to the stressed P&L (e.g., equity factor, interest rate factor, credit spread factor).',
    `geographic_region` STRING COMMENT 'Geographic region or market focus of the portfolio subjected to the stress test (e.g., North America, Europe, Asia-Pacific, Global).',
    `liquidity_impact_days` BIGINT COMMENT 'Estimated number of days required to liquidate the stressed positions under the scenario conditions, reflecting liquidity risk.',
    `market_value_base` DECIMAL(20,2) COMMENT 'The market value of the position in base currency at calculation date, before stress is applied.',
    `model_version` STRING COMMENT 'Version identifier of the risk model or stress testing engine used to generate this result.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this stress test result record was last modified or updated.',
    `notes` STRING COMMENT 'Free-text field for additional commentary, observations, or context regarding the stress test result.',
    `position_quantity` DECIMAL(20,4) COMMENT 'The quantity of the instrument held at calculation date. Required to calculate stressed P&L from per-unit impact.',
    `rebalance_trigger_flag` BOOLEAN COMMENT 'Indicates whether the stress scenario would cause the hedge ratio to breach the permitted band (min/max hedge ratio) and trigger a mandatory rebalancing event for this hedge program.',
    `regulatory_reference` STRING COMMENT 'Reference to the specific regulatory requirement, guideline, or framework that mandated this stress test (if applicable).',
    `regulatory_scenario_flag` BOOLEAN COMMENT 'Indicates whether this stress test was performed to satisfy a regulatory requirement (True) or for internal risk management purposes (False).',
    `result_timestamp` TIMESTAMP COMMENT 'Date and time when the stress test result was calculated and recorded.',
    `risk_system_source` STRING COMMENT 'Source system that performed the stress test calculation (e.g., BlackRock Aladdin, MSCI RiskMetrics, MSCI Barra, SimCorp Dimension, internal proprietary system).. Valid values are `aladdin|riskmetrics|barra|simcorp|internal`',
    `scenario_impact_amount` DECIMAL(18,2) COMMENT 'The calculated mark-to-market or P&L impact of applying this stress scenario to this hedge program, expressed in the funds base currency. Positive values indicate gains, negative values indicate losses under the stress scenario.',
    `sector` STRING COMMENT 'Primary economic sector or industry classification of the portfolio holdings subjected to the stress test.',
    `sensitivity` DECIMAL(18,6) COMMENT 'The sensitivity of this instrument to the scenario shocks. For equities this may be beta, for bonds duration/convexity, for derivatives delta/gamma. Captures how the instrument responds to the scenario factors.',
    `shock_value` DECIMAL(18,6) COMMENT 'The specific shock value applied to this instrument under this scenario. May differ from scenario-level defaults based on instrument characteristics (e.g., sector-specific equity shocks, credit-rating-specific spread shocks).',
    `stressed_cvar` DECIMAL(20,2) COMMENT 'Conditional Value at Risk (expected shortfall) of the portfolio after applying the stress scenario, in the reporting currency.',
    `stressed_market_value` DECIMAL(20,2) COMMENT 'The market value of the position in base currency after applying the scenario stress shocks.',
    `stressed_nav` DECIMAL(20,2) COMMENT 'Net Asset Value of the portfolio after applying the stress scenario, in the reporting currency.',
    `stressed_pnl` DECIMAL(20,2) COMMENT 'The calculated profit and loss impact for this instrument under this scenario, expressed in base currency. Represents the contribution of this position to total portfolio stress loss.',
    `stressed_pnl_absolute` DECIMAL(20,2) COMMENT 'Absolute change in portfolio value resulting from the stress scenario (stressed NAV minus base NAV), in the reporting currency.',
    `stressed_pnl_percentage` DECIMAL(10,4) COMMENT 'Percentage change in portfolio value resulting from the stress scenario, expressed as a decimal (e.g., -0.1250 for -12.50%).',
    `stressed_var` DECIMAL(20,2) COMMENT 'Value at Risk of the portfolio after applying the stress scenario, in the reporting currency.',
    `test_execution_date` DATE COMMENT 'Date on which this stress test was executed. Required for audit trail and regulatory reporting of when stress tests were performed.',
    `test_status` STRING COMMENT 'Lifecycle status of this stress test record, tracking progression from execution through review and approval for regulatory reporting.',
    `time_horizon_days` BIGINT COMMENT 'Time horizon in days over which the stress scenario is applied (e.g., 1-day, 10-day, 30-day).',
    `valuation_date` DATE COMMENT 'As-of date for the portfolio valuation used as the baseline for stress testing.',
    CONSTRAINT pk_stress_test_result PRIMARY KEY(`stress_test_result_id`)
) COMMENT 'Transactional record of the output from a stress test run applying a defined stress scenario to a portfolio or position set. Captures scenario applied, portfolio scope, stressed P&L impact (absolute and % of NAV), stressed VaR, stressed CVaR, asset class';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`limit_breach` (
    `limit_breach_id` BIGINT COMMENT 'Unique identifier for the limit breach event record.',
    `acknowledged_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Breach acknowledgment must be traceable for escalation procedures. Pension funds require documented accountability for who acknowledged each limit breach per risk governance.',
    `counterparty_id` BIGINT COMMENT 'Reference to the counterparty associated with the breach, if applicable for counterparty risk limits.',
    `limit_id` BIGINT COMMENT 'Reference to the risk limit that was breached.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio associated with the breach, if applicable.',
    `rule_id` BIGINT COMMENT 'Foreign key linking to compliance.rule. Business justification: When risk limit breaches have regulatory implications (regulatory_breach_flag=true), compliance must assess which regulatory rule was violated.',
    `strategy_id` BIGINT COMMENT 'Reference to the investment strategy associated with the breach, if applicable.',
    `triggering_order_id` BIGINT COMMENT 'Foreign key linking to trade.order. Business justification: Pre-trade compliance and breach remediation require linking breaches to triggering orders. Risk teams must identify which orders caused limit violations for regulatory reporting (AIFMD, UCITS)',
    `acknowledged_timestamp` TIMESTAMP COMMENT 'Date and time when the breach was formally acknowledged by risk management.',
    `asset_class` STRING COMMENT 'Asset class associated with the breach such as public equities, private equity, real estate, infrastructure, natural resources, or credit.',
    `breach_code` STRING COMMENT 'Unique business identifier code for the breach event, used for tracking and reporting.. Valid values are `^[A-Z0-9]{6,12}$`',
    `breach_duration_minutes` BIGINT COMMENT 'Duration in minutes that the breach persisted before returning to compliance or being remediated.',
    `breach_magnitude` DECIMAL(20,4) COMMENT 'Absolute difference between the breached metric value and the limit threshold.',
    `breach_percentage` DECIMAL(10,4) COMMENT 'Percentage by which the metric exceeded the limit threshold, calculated as magnitude divided by threshold times 100.',
    `breach_severity` STRING COMMENT 'Classification of the breach severity level based on magnitude and risk impact.. Valid values are `warning|soft_breach|hard_breach|critical`',
    `breach_status` STRING COMMENT 'Current lifecycle status of the breach event in the remediation workflow.. Valid values are `open|acknowledged|under_review|remediated|closed|escalated`',
    `breach_timestamp` TIMESTAMP COMMENT 'Date and time when the limit breach was first detected by the risk monitoring system.',
    `breached_metric_value` DECIMAL(20,4) COMMENT 'Actual value of the risk metric at the time of breach detection.',
    `confidence_level` DECIMAL(5,2) COMMENT 'Statistical confidence level used in the risk calculation, typically expressed as a percentage such as 95% or 99%.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the breach record was first created in the system.',
    `currency` STRING COMMENT 'Three-letter ISO currency code for monetary breach values.. Valid values are `^[A-Z]{3}$`',
    `detection_timestamp` TIMESTAMP COMMENT 'Date and time when the breach was identified and logged by the risk system, may differ from breach timestamp if detected retrospectively.',
    `escalation_level` STRING COMMENT 'Level to which the breach was escalated based on severity and escalation procedures.. Valid values are `none|team_lead|risk_manager|cro|investment_committee|board`',
    `escalation_timestamp` TIMESTAMP COMMENT 'Date and time when the breach was escalated to higher authority or governance body.',
    `geographic_region` STRING COMMENT 'Geographic region or market associated with the breach for regional concentration limits.',
    `ic_review_date` DATE COMMENT 'Date when the breach was reviewed by the Investment Committee, if applicable.',
    `ic_review_required_flag` BOOLEAN COMMENT 'Indicates whether the breach requires formal review by the Investment Committee based on severity and governance policy.',
    `intraday_breach_flag` BOOLEAN COMMENT 'Indicates whether the breach occurred during intraday monitoring versus end-of-day monitoring.',
    `limit_threshold_value` DECIMAL(20,4) COMMENT 'The threshold value of the limit that was breached, captured at time of breach for audit trail.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when the breach record was last modified or updated.',
    `notes` STRING COMMENT 'Free-text notes and comments regarding the breach event, remediation, or follow-up actions.',
    `notification_sent_flag` BOOLEAN COMMENT 'Indicates whether automated notification was sent to stakeholders upon breach detection.',
    `notification_timestamp` TIMESTAMP COMMENT 'Date and time when breach notification was sent to stakeholders.',
    `regulatory_breach_flag` BOOLEAN COMMENT 'Indicates whether the breach violates a regulatory requirement and requires regulatory reporting.',
    `regulatory_reference` STRING COMMENT 'Reference to the specific regulatory requirement or rule that was breached, if applicable.',
    `remediated_by` STRING COMMENT 'Name or identifier of the portfolio manager or trader who executed the remediation action.',
    `remediation_action` STRING COMMENT 'Description of the remediation action taken to address the breach and return to compliance.',
    `remediation_timestamp` TIMESTAMP COMMENT 'Date and time when remediation action was completed and the breach was resolved.',
    `risk_metric_type` STRING COMMENT 'Type of risk metric that breached the limit such as Value at Risk (VaR), Conditional Value at Risk (CVaR), Dollar Value of 01 (DV01), concentration, or liquidity.',
    `risk_system_source` STRING COMMENT 'Source risk system that detected and reported the breach such as BlackRock Aladdin, MSCI RiskMetrics, or Barra.',
    `root_cause` STRING COMMENT 'Identified root cause of the breach such as market movement, operational error, model failure, or limit misconfiguration.',
    `sector` STRING COMMENT 'Industry sector or GICS classification associated with the breach for sector concentration limits.',
    `time_horizon_days` BIGINT COMMENT 'Time horizon in days over which the risk metric was calculated, such as 1-day or 10-day VaR.',
    `unit_of_measure` STRING COMMENT 'Unit of measurement for the breached metric, such as basis points, percentage, currency, or other risk metric units.',
    CONSTRAINT pk_limit_breach PRIMARY KEY(`limit_breach_id`)
) COMMENT 'Transactional record of each risk limit breach event detected during daily or intraday risk monitoring. Captures the breached limit, breach date and time, breached metric value vs limit threshold, breach severity (warning, soft breach, hard breach)';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`risk_counterparty_exposure` (
    `risk_counterparty_exposure_id` BIGINT COMMENT 'Unique identifier for each counterparty exposure record in the risk management system.',
    `counterparty_id` BIGINT COMMENT 'Reference to the counterparty entity to which this exposure applies.',
    `csa_id` BIGINT COMMENT 'Foreign key linking to collateral.csa. Business justification: CSA terms (thresholds, minimum transfer amounts) directly impact collateral-adjusted exposure calculations.',
    `netting_agreement_id` BIGINT COMMENT 'Foreign key linking to collateral.netting_agreement. Business justification: Netting agreements directly reduce counterparty exposure through close-out netting. Pension fund risk teams must calculate net exposure using actual netting agreement terms.',
    `otc_derivative_id` BIGINT COMMENT 'Foreign key linking to trade.otc_derivative. Business justification: Counterparty credit exposure calculations must link to underlying OTC derivatives for CVA/DVA computation, EMIR reporting, and ISDA CSA margin calculations.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio holding positions that contribute to this counterparty exposure.',
    `stress_scenario_id` BIGINT COMMENT 'Reference to the stress test scenario under which this exposure was calculated, if applicable.',
    `asset_class` STRING COMMENT 'The asset class of the underlying instruments contributing to the counterparty exposure.. Valid values are `Equity|Fixed Income|FX|Commodity|Credit|Multi-Asset`',
    `breach_flag` BOOLEAN COMMENT 'Indicates whether this exposure breaches any established counterparty credit limit or concentration threshold.',
    `breach_severity` STRING COMMENT 'The severity classification of any limit breach associated with this counterparty exposure.. Valid values are `None|Low|Medium|High|Critical`',
    `calculation_methodology` STRING COMMENT 'The methodology used to calculate the counterparty credit exposure.. Valid values are `Current Exposure|SA-CCR|IMM|CEM|Other`',
    `ccp_name` STRING COMMENT 'The name of the central counterparty clearing house if the exposure is centrally cleared.',
    `clearing_status` STRING COMMENT 'Indicates whether the exposure is centrally cleared through a CCP or remains bilateral.. Valid values are `Cleared|Bilateral|Uncleared`',
    `collateral_agreement_flag` BOOLEAN COMMENT 'Indicates whether a collateral support agreement is in place with the counterparty.',
    `collateral_agreement_type` STRING COMMENT 'The type of collateral support agreement governing margin and collateral exchange with the counterparty.. Valid values are `CSA|SCSA|Bilateral|Unilateral|None`',
    `collateral_held_amount` DECIMAL(20,2) COMMENT 'The market value of collateral held from the counterparty to mitigate credit exposure, in base currency.',
    `collateral_posted_amount` DECIMAL(20,2) COMMENT 'The market value of collateral posted to the counterparty, in base currency.',
    `concentration_limit_utilization` DECIMAL(8,4) COMMENT 'The percentage of the counterparty concentration limit currently utilized by this exposure, expressed as a decimal.',
    `counterparty_credit_rating` STRING COMMENT 'The external credit rating assigned to the counterparty by a recognized rating agency. [ENUM-REF-CANDIDATE: AAA|AA|A|BBB|BB|B|CCC|CC|C|D|NR — 11 candidates stripped; promote to reference product]',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this counterparty exposure record was first created in the system.',
    `credit_valuation_adjustment` DECIMAL(20,2) COMMENT 'The market value adjustment to reflect counterparty credit risk in OTC derivative valuations.',
    `debit_valuation_adjustment` DECIMAL(20,2) COMMENT 'The market value adjustment to reflect own credit risk in OTC derivative valuations.',
    `effective_maturity_years` DECIMAL(8,2) COMMENT 'The effective maturity of the exposure in years, used in regulatory capital calculations.',
    `expected_credit_loss` DECIMAL(20,2) COMMENT 'The probability-weighted estimate of credit losses over the expected life of the exposure, calculated as EAD × PD × LGD.',
    `expected_exposure` DECIMAL(20,2) COMMENT 'The mean of the probability distribution of exposure at a future date, used in credit valuation adjustment calculations.',
    `exposure_at_default` DECIMAL(20,2) COMMENT 'The estimated exposure amount at the time of counterparty default, used in regulatory capital calculations.',
    `exposure_currency` STRING COMMENT 'The base currency in which all exposure amounts are denominated, using ISO 4217 three-letter code.. Valid values are `^[A-Z]{3}$`',
    `exposure_type` STRING COMMENT 'The category of transaction or instrument giving rise to the counterparty credit exposure.. Valid values are `OTC Derivative|Repo|Securities Lending|Unsettled Trade|Margin|Collateral`',
    `gross_exposure_amount` DECIMAL(20,2) COMMENT 'The total gross credit exposure to the counterparty before netting and collateral adjustments, in base currency.',
    `independent_amount` DECIMAL(20,2) COMMENT 'The fixed collateral amount required to be posted regardless of mark-to-market exposure, providing additional credit protection.',
    `instrument_type` STRING COMMENT 'The specific financial instrument type contributing to the exposure. [ENUM-REF-CANDIDATE: Swap|Forward|Option|Future|Repo|Reverse Repo|Securities Loan|Other — 8 candidates stripped; promote to reference product]',
    `internal_credit_rating` STRING COMMENT 'The internal credit rating assigned to the counterparty by the funds credit risk team.',
    `lei` STRING COMMENT 'The 20-character ISO 17442 Legal Entity Identifier of the counterparty.. Valid values are `^[A-Z0-9]{20}$`',
    `loss_given_default` DECIMAL(8,6) COMMENT 'The estimated percentage of exposure that would be lost in the event of counterparty default, expressed as a decimal.',
    `margin_threshold_amount` DECIMAL(20,2) COMMENT 'The exposure threshold below which no collateral is required to be posted under the collateral agreement.',
    `maturity_date` DATE COMMENT 'The weighted average maturity date of the instruments contributing to this counterparty exposure.',
    `minimum_transfer_amount` DECIMAL(20,2) COMMENT 'The minimum collateral amount that must be transferred in any single margin call under the collateral agreement.',
    `modified_timestamp` TIMESTAMP COMMENT 'The date and time when this counterparty exposure record was last updated in the system.',
    `net_exposure_amount` DECIMAL(20,2) COMMENT 'The net credit exposure after netting and collateral adjustments, representing the residual credit risk, in base currency.',
    `netting_agreement_flag` BOOLEAN COMMENT 'Indicates whether a legally enforceable netting agreement is in place with the counterparty.',
    `netting_agreement_type` STRING COMMENT 'The type of master netting agreement governing the exposure relationship with the counterparty.. Valid values are `ISDA Master|GMRA|GMSLA|Bilateral|None`',
    `netting_benefit_amount` DECIMAL(20,2) COMMENT 'The reduction in exposure achieved through legally enforceable netting agreements, in base currency.',
    `notes` STRING COMMENT 'Additional commentary or context regarding this counterparty exposure record.',
    `potential_future_exposure` DECIMAL(20,2) COMMENT 'The estimated maximum exposure that could arise in the future due to market movements, calculated using simulation models.',
    `probability_of_default` DECIMAL(8,6) COMMENT 'The estimated likelihood that the counterparty will default within a one-year horizon, expressed as a decimal.',
    `risk_weight` DECIMAL(8,4) COMMENT 'The regulatory risk weight applied to this exposure for capital adequacy calculations, expressed as a decimal.',
    `risk_weighted_exposure` DECIMAL(20,2) COMMENT 'The exposure amount multiplied by the applicable risk weight, used in regulatory capital calculations.',
    `valuation_date` DATE COMMENT 'The date on which this counterparty exposure was calculated and valued.',
    `wrong_way_risk_flag` BOOLEAN COMMENT 'Indicates whether this exposure exhibits wrong-way risk, where exposure increases when counterparty creditworthiness deteriorates.',
    CONSTRAINT pk_risk_counterparty_exposure PRIMARY KEY(`risk_counterparty_exposure_id`)
) COMMENT 'Transactional record of gross and net credit exposure to each counterparty across all OTC derivatives, repo agreements, securities lending, and unsettled trades.';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`concentration_exposure` (
    `concentration_exposure_id` BIGINT COMMENT 'Unique identifier for the concentration exposure measurement record.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Concentration exposure approvals require documented accountability for prudent person rule compliance. Pension funds track approvers for diversification governance.',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: Counterparty concentration monitoring is critical for pension fund risk management.',
    `credit_rating_id` BIGINT COMMENT 'Foreign key linking to risk.credit_rating. Business justification: Adds a foreign key to the credit_rating master table, removing the redundant credit_rating string column and enabling referential integrity and efficient joins.',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Manager concentration limits require tracking total exposure to each GP across all mandates. Regulatory large exposure reporting and internal risk limits mandate GP-level aggregation.',
    `limit_id` BIGINT COMMENT 'Reference to the applicable concentration risk limit framework or threshold against which this exposure is monitored.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio being measured for concentration risk.',
    `stress_scenario_id` BIGINT COMMENT 'Reference to a macroeconomic stress scenario under which this concentration exposure was calculated, null for base case measurements.',
    `approval_date` DATE COMMENT 'Date on which an exception or remediation plan for a concentration breach was formally approved by risk governance authority.',
    `asset_class` STRING COMMENT 'The asset class category when concentration dimension is asset class: public equities, private equity, real estate, infrastructure, natural resources, credit, or fixed income.',
    `breach_amount` DECIMAL(20,2) COMMENT 'The absolute monetary amount by which the exposure exceeds the limit threshold, null if within limit.',
    `breach_percentage` DECIMAL(7,4) COMMENT 'The percentage points by which the exposure exceeds the limit threshold, null if within limit.',
    `breach_status` STRING COMMENT 'Indicates whether the concentration exposure is within limits, has breached a soft threshold, breached a hard limit, or has been escalated for remediation.. Valid values are `within_limit|soft_breach|hard_breach|escalated`',
    `calculation_methodology` STRING COMMENT 'Description of the methodology used to calculate the concentration exposure, including aggregation rules, netting conventions, and look-through approaches for fund investments.',
    `concentration_dimension` STRING COMMENT 'The dimension along which concentration risk is being measured: single issuer, sector/industry, geography, asset class, currency, or counterparty.. Valid values are `single_issuer|sector|geography|asset_class|currency|counterparty`',
    `confidence_level` DECIMAL(5,4) COMMENT 'The statistical confidence level used for risk metric calculations, typically expressed as a decimal (e.g., 0.95 for 95% confidence).',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp indicating when this concentration exposure record was first created in the risk management system.',
    `cvar_contribution` DECIMAL(20,2) COMMENT 'The contribution of this concentration exposure to the overall portfolio Conditional Value at Risk (CVaR) or Expected Shortfall metric.',
    `data_source` STRING COMMENT 'The source system or platform from which the concentration exposure data was derived, such as BlackRock Aladdin, MSCI RiskMetrics, or SimCorp Dimension.',
    `dimension_value` DECIMAL(18,2) COMMENT 'The specific value within the concentration dimension being measured, such as issuer name, sector code, country code, asset class name, currency code, or counterparty identifier.',
    `escalation_required_flag` BOOLEAN COMMENT 'Boolean indicator of whether the concentration exposure breach requires escalation to senior management or Investment Committee (IC) per governance policy.',
    `exposure_amount` DECIMAL(20,2) COMMENT 'The total monetary exposure to the specified concentration dimension value, expressed in the portfolio base currency.',
    `exposure_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the exposure amount is denominated.. Valid values are `^[A-Z]{3}$`',
    `exposure_percentage` DECIMAL(7,4) COMMENT 'The concentration exposure expressed as a percentage of total portfolio Net Asset Value (NAV) or Assets Under Management (AUM).',
    `geographic_region` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code representing the geographic region of concentration when dimension is geography.. Valid values are `^[A-Z]{3}$`',
    `limit_threshold` DECIMAL(7,4) COMMENT 'The maximum allowable concentration exposure percentage as defined by the risk limit framework for this dimension and value.',
    `look_through_flag` BOOLEAN COMMENT 'Boolean indicator of whether the concentration calculation includes look-through analysis of underlying holdings in fund-of-funds or commingled vehicles.',
    `measurement_date` DATE COMMENT 'Business date on which the concentration exposure was calculated and recorded.',
    `modified_timestamp` TIMESTAMP COMMENT 'System timestamp indicating when this concentration exposure record was last updated or modified.',
    `monitoring_frequency` STRING COMMENT 'The frequency at which this concentration exposure is monitored and reported to risk management and Investment Committee (IC).. Valid values are `daily|weekly|monthly|quarterly`',
    `nav_base` DECIMAL(20,2) COMMENT 'The total portfolio Net Asset Value (NAV) or Assets Under Management (AUM) used as the denominator for calculating exposure percentage.',
    `netting_applied_flag` BOOLEAN COMMENT 'Boolean indicator of whether long and short positions were netted in the concentration exposure calculation, or if gross exposure was used.',
    `notes` STRING COMMENT 'Free-text field for additional context, commentary, or qualitative assessment related to the concentration exposure measurement.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Boolean indicator of whether this concentration exposure must be included in regulatory reporting to SEC, or other governing bodies.',
    `remediation_plan` STRING COMMENT 'Description of the action plan to reduce or mitigate the concentration exposure if a breach has occurred, including target reduction timeline and responsible party.',
    `risk_rating` STRING COMMENT 'Qualitative risk assessment of the concentration exposure based on magnitude, volatility, and correlation characteristics.. Valid values are `low|medium|high|critical`',
    `sector_classification` STRING COMMENT 'The industry sector classification code or name applicable when concentration dimension is sector, using standard taxonomy such as GICS or BICS.',
    `time_horizon_days` BIGINT COMMENT 'The time horizon in days over which the concentration risk metrics are calculated, commonly 1-day or 10-day for VaR.',
    `var_contribution` DECIMAL(20,2) COMMENT 'The contribution of this concentration exposure to the overall portfolio Value at Risk (VaR) metric.',
    CONSTRAINT pk_concentration_exposure PRIMARY KEY(`concentration_exposure_id`)
) COMMENT 'Transactional record of portfolio concentration risk measurements across multiple dimensions: single issuer, sector/industry, geography, asset class, currency, and counterparty.';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`dv01_sensitivity` (
    `dv01_sensitivity_id` BIGINT COMMENT 'Unique identifier for the DV01 sensitivity record.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Interest rate sensitivity approvals are critical for ALM governance. Pension funds must track who approved DV01 calculations for liability matching oversight.',
    `discount_rate_curve_id` BIGINT COMMENT 'Foreign key linking to actuarial.discount_rate_curve. Business justification: LDI hedge ratio calculations require asset DV01 computed using the SAME discount curve as liabilities.',
    `holding_id` BIGINT COMMENT 'Reference to the specific position or holding for which DV01 sensitivity is calculated.',
    `instrument_id` BIGINT COMMENT 'Foreign key linking to trade.instrument. Business justification: DV01/duration calculations are instrument-specific for fixed income. Essential for liability-driven investing (LDI) where pension funds match asset duration to pension liabilities.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio containing the position or aggregate portfolio for which DV01 is measured.',
    `research_yield_curve_id` BIGINT COMMENT 'Foreign key linking to research.research_yield_curve. Business justification: DV01/duration calculations require yield curve inputs. The dv01_sensitivity table references yield_curve_source/date indicating dependency on curve data.',
    `security_instrument_id` BIGINT COMMENT 'Reference to the underlying security or instrument for which interest rate sensitivity is calculated.',
    `stress_scenario_id` BIGINT COMMENT 'Reference to a specific stress scenario under which this DV01 sensitivity was calculated.',
    `aggregation_level` STRING COMMENT 'The level at which DV01 sensitivity is aggregated: individual position, portfolio, strategy, or total fund.. Valid values are `position|portfolio|strategy|total_fund`',
    `approval_timestamp` TIMESTAMP COMMENT 'Timestamp when the DV01 calculation was approved or validated.',
    `asset_class` STRING COMMENT 'The asset class category of the position for which DV01 is calculated.. Valid values are `fixed_income|credit|government_bonds|corporate_bonds|mortgage_backed_securities|asset_backed_securities`',
    `calculation_date` DATE COMMENT 'The date on which the DV01 sensitivity measure was calculated.',
    `calculation_methodology` STRING COMMENT 'The methodology used to calculate DV01, such as analytical approximation or full revaluation.. Valid values are `analytical|full_revaluation|grid_shock|scenario_based`',
    `calculation_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the DV01 sensitivity calculation was performed, supporting intraday risk monitoring.',
    `confidence_level` DECIMAL(5,2) COMMENT 'Statistical confidence level associated with the DV01 calculation, expressed as a percentage.',
    `convexity` DECIMAL(12,4) COMMENT 'Second-order measure of interest rate sensitivity, capturing the curvature of the price-yield relationship.',
    `coupon_rate` DECIMAL(8,4) COMMENT 'The coupon rate of the fixed income instrument, expressed as a percentage.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the DV01 sensitivity record was first created in the system.',
    `currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the DV01 amount is denominated.. Valid values are `^[A-Z]{3}$`',
    `dv01_amount` DECIMAL(18,2) COMMENT 'The dollar change in the value of the position or portfolio for a one basis point parallel shift in the yield curve.',
    `effective_duration` DECIMAL(12,4) COMMENT 'Effective duration accounting for embedded options, measuring interest rate sensitivity for bonds with optionality.',
    `hedge_adjusted_flag` BOOLEAN COMMENT 'Indicates whether the DV01 calculation reflects hedging positions or is gross of hedges.',
    `instrument_type` STRING COMMENT 'The type of financial instrument for which interest rate sensitivity is measured.. Valid values are `bond|swap|future|option|swaption|cap_floor`',
    `key_rate_duration_10y` DECIMAL(12,4) COMMENT 'Sensitivity to a one basis point change in the 10-year point of the yield curve, holding other points constant.',
    `key_rate_duration_1y` DECIMAL(12,4) COMMENT 'Sensitivity to a one basis point change in the 1-year point of the yield curve, holding other points constant.',
    `key_rate_duration_2y` DECIMAL(12,4) COMMENT 'Sensitivity to a one basis point change in the 2-year point of the yield curve, holding other points constant.',
    `key_rate_duration_30y` DECIMAL(12,4) COMMENT 'Sensitivity to a one basis point change in the 30-year point of the yield curve, holding other points constant.',
    `key_rate_duration_3m` DECIMAL(12,4) COMMENT 'Sensitivity to a one basis point change in the 3-month point of the yield curve, holding other points constant.',
    `key_rate_duration_5y` DECIMAL(12,4) COMMENT 'Sensitivity to a one basis point change in the 5-year point of the yield curve, holding other points constant.',
    `key_rate_duration_6m` DECIMAL(12,4) COMMENT 'Sensitivity to a one basis point change in the 6-month point of the yield curve, holding other points constant.',
    `macaulay_duration` DECIMAL(12,4) COMMENT 'Weighted average time to receive cash flows, expressed in years.',
    `market_value` DECIMAL(18,2) COMMENT 'Current market value of the position at the time of DV01 calculation.',
    `maturity_date` DATE COMMENT 'The maturity date of the fixed income instrument.',
    `modified_duration` DECIMAL(12,4) COMMENT 'Modified duration of the position, measuring the percentage change in price for a 1% change in yield.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the DV01 sensitivity record was last modified or recalculated.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding the DV01 calculation, including any assumptions or adjustments.',
    `notional_amount` DECIMAL(18,2) COMMENT 'Notional principal amount of the position, particularly relevant for derivatives and swaps.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this DV01 measure is used for regulatory reporting purposes such as Pension regulator or Basel III.',
    `risk_system_source` STRING COMMENT 'The risk management system that generated the DV01 calculation, such as Aladdin, RiskMetrics, or SimCorp.',
    `shock_size_bps` BIGINT COMMENT 'The size of the interest rate shock applied in the calculation, typically 1 basis point for DV01.',
    `spread_duration` DECIMAL(12,4) COMMENT 'Sensitivity to changes in credit spread, measuring the impact of spread widening or tightening on position value.',
    `yield_curve_date` DATE COMMENT 'The effective date of the yield curve used in the sensitivity calculation.',
    `yield_curve_source` STRING COMMENT 'The source or vendor of the yield curve used in the DV01 calculation, such as Bloomberg or internal curve.',
    `yield_to_maturity` DECIMAL(8,4) COMMENT 'The yield to maturity of the position at the time of calculation, expressed as a percentage.',
    CONSTRAINT pk_dv01_sensitivity PRIMARY KEY(`dv01_sensitivity_id`)
) COMMENT 'Transactional record of DV01 (Dollar Value of a Basis Point) and broader interest rate sensitivity measures for fixed income and rate-sensitive positions. Captures position or portfolio identifier, DV01 amount, duration (modified, effective, key-rate)';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`liquidity_risk_assessment` (
    `liquidity_risk_assessment_id` BIGINT COMMENT 'Unique identifier for the liquidity risk assessment record.',
    `assessed_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Liquidity assessments require documented assessor for audit trails. Pension funds must track which analyst performed each liquidity risk assessment.',
    `liability_cash_flow_id` BIGINT COMMENT 'Foreign key linking to actuarial.liability_cash_flow. Business justification: Pension liquidity assessments must evaluate asset liquidity against projected benefit payments.',
    `limit_id` BIGINT COMMENT 'Reference to the liquidity risk limit framework applied to this assessment.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio being assessed for liquidity risk.',
    `significant_cash_flow_id` BIGINT COMMENT 'Foreign key linking to performance.significant_cash_flow. Business justification: Pension funds must assess liquidity risk considering significant cash flows (beneficiary payments, large redemptions).',
    `stress_scenario_id` BIGINT COMMENT 'Reference to the stress test scenario applied in this liquidity assessment.',
    `valuation_cycle_id` BIGINT COMMENT 'Foreign key linking to valuation.cycle. Business justification: Liquidity assessments use portfolio NAV from specific valuation cycles. Pension funds must demonstrate liquidity coverage against audited valuations for regulatory compliance and benefit',
    `approval_date` DATE COMMENT 'Date on which the liquidity risk assessment was formally approved.',
    `approved_by` STRING COMMENT 'Name or identifier of the authority who approved the liquidity risk assessment.',
    `assessment_code` STRING COMMENT 'Externally-known unique business identifier for this liquidity risk assessment.. Valid values are `^LRA-[0-9]{8}-[A-Z0-9]{6}$`',
    `assessment_date` DATE COMMENT 'Business date on which the liquidity risk assessment was performed.',
    `assessment_status` STRING COMMENT 'Current lifecycle status of the liquidity risk assessment.. Valid values are `draft|in_review|approved|rejected|superseded|archived`',
    `asset_class` STRING COMMENT 'Primary asset class category for which liquidity risk is being assessed.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `bid_ask_spread_bps` DECIMAL(10,2) COMMENT 'Average bid-ask spread across portfolio positions, expressed in basis points.',
    `breach_severity` STRING COMMENT 'Severity classification of any identified liquidity limit breach.. Valid values are `none|low|medium|high|critical`',
    `concentration_risk_flag` BOOLEAN COMMENT 'Indicates whether concentration risk was identified that could impair liquidity.',
    `confidence_level` DECIMAL(5,4) COMMENT 'Statistical confidence level used in the liquidity risk calculation, expressed as a decimal.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this liquidity risk assessment record was first created in the system.',
    `days_to_liquidate` DECIMAL(10,2) COMMENT 'Estimated number of days required to liquidate the portfolio without exceeding market impact thresholds.',
    `escalation_required_flag` BOOLEAN COMMENT 'Indicates whether the assessment results require escalation to senior management or Investment Committee.',
    `funding_liquidity_risk_flag` BOOLEAN COMMENT 'Indicates whether funding liquidity risk was identified in meeting capital calls or obligations.',
    `geographic_region` STRING COMMENT 'Geographic region or market where the assessed assets are primarily located.',
    `illiquid_assets_value` DECIMAL(20,2) COMMENT 'Total value of assets classified as illiquid within the specified time horizon.',
    `limit_breach_flag` BOOLEAN COMMENT 'Indicates whether the liquidity assessment identified a breach of established risk limits.',
    `liquid_assets_value` DECIMAL(20,2) COMMENT 'Total value of assets classified as liquid within the specified time horizon.',
    `liquidation_scenario` STRING COMMENT 'Market condition scenario under which the liquidity assessment is performed.. Valid values are `normal_market|stressed_market|crisis|orderly_exit|forced_liquidation`',
    `liquidity_coverage_ratio` DECIMAL(10,6) COMMENT 'Ratio of high-quality liquid assets to net cash outflows over the stress period.',
    `liquidity_ratio` DECIMAL(10,6) COMMENT 'Ratio of liquid assets to total portfolio NAV, expressed as a decimal.',
    `market_impact_cost_bps` DECIMAL(10,2) COMMENT 'Estimated market impact cost of liquidating positions, expressed in basis points.',
    `measurement_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the liquidity risk measurement was captured.',
    `methodology` STRING COMMENT 'Calculation methodology or model used to perform the liquidity risk assessment.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this liquidity risk assessment record was last modified.',
    `nav_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the portfolio NAV.. Valid values are `^[A-Z]{3}$`',
    `next_review_date` DATE COMMENT 'Scheduled date for the next liquidity risk assessment review.',
    `notes` STRING COMMENT 'Additional commentary, observations, or context related to the liquidity risk assessment.',
    `regulatory_reference` STRING COMMENT 'Reference to the specific regulatory requirement or framework governing this liquidity assessment.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this liquidity assessment must be included in regulatory reporting submissions.',
    `remediation_plan` STRING COMMENT 'Description of the remediation actions planned or taken to address identified liquidity risks.',
    `reviewed_by` STRING COMMENT 'Name or identifier of the senior risk officer who reviewed and validated the assessment.',
    `risk_system_source` STRING COMMENT 'Source risk management system or platform that generated the liquidity assessment.',
    `sector` STRING COMMENT 'Economic sector classification of the assessed portfolio holdings.',
    `time_horizon_days` BIGINT COMMENT 'Number of days over which the liquidity risk is assessed for liquidation without material market impact.',
    `total_portfolio_nav` DECIMAL(20,2) COMMENT 'Total Net Asset Value of the portfolio at the time of assessment.',
    CONSTRAINT pk_liquidity_risk_assessment PRIMARY KEY(`liquidity_risk_assessment_id`)
) COMMENT 'Transactional record of portfolio liquidity risk assessments measuring the ability to liquidate positions within defined time horizons without material market impact.';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`fx_risk_exposure` (
    `fx_risk_exposure_id` BIGINT COMMENT 'Unique identifier for the foreign exchange risk exposure record.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: FX exposure approvals require documented accountability. Pension funds track who approved currency exposures for hedging policy compliance and governance.',
    `fx_position_id` BIGINT COMMENT 'Foreign key linking to treasury.fx_position. Business justification: FX risk exposure measurements must reference the underlying treasury FX position being assessed.',
    `hedge_fx_trade_id` BIGINT COMMENT 'Foreign key linking to trade.fx_trade. Business justification: Currency hedging programs require linking FX exposures to hedge trades. Pension funds with global mandates track hedge effectiveness per IAS 39/IFRS 9 and need exposure-to-hedge trade linkage',
    `limit_id` BIGINT COMMENT 'Reference to the risk limit framework governing this foreign exchange exposure.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio holding the currency exposure.',
    `research_fx_rate_id` BIGINT COMMENT 'Foreign key linking to research.research_fx_rate. Business justification: FX risk exposures use spot rates and volatility from research market data. Pension funds with global portfolios calculate currency exposures using research-maintained FX rates.',
    `stress_scenario_id` BIGINT COMMENT 'Reference to the macroeconomic stress scenario applied to calculate stressed foreign exchange exposure.',
    `approval_date` DATE COMMENT 'Date on which the foreign exchange exposure position was formally approved by the risk committee or investment committee.',
    `asset_class` STRING COMMENT 'The asset class category generating the foreign exchange exposure.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `base_currency` STRING COMMENT 'The reporting currency of the portfolio, typically the functional currency for risk measurement (ISO 4217 three-letter code).. Valid values are `^[A-Z]{3}$`',
    `breach_status` STRING COMMENT 'Indicates whether the foreign exchange exposure is within limits, approaching limits, or in breach of risk thresholds.. Valid values are `within_limit|warning|breach|critical_breach`',
    `calculation_methodology` STRING COMMENT 'Statistical methodology used to calculate Value at Risk and other risk metrics for the foreign exchange exposure.. Valid values are `historical_simulation|monte_carlo|parametric|variance_covariance`',
    `confidence_level` DECIMAL(4,2) COMMENT 'Statistical confidence level used for Value at Risk calculations, typically expressed as a percentage (e.g., 99.00 for 99%).',
    `correlation_to_portfolio` DECIMAL(6,4) COMMENT 'Statistical correlation between the foreign exchange exposure and the overall portfolio returns, ranging from -1.0000 to 1.0000.',
    `counterparty_lei` STRING COMMENT 'Legal Entity Identifier of the counterparty for hedging instruments, if applicable.. Valid values are `^[A-Z0-9]{20}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the foreign exchange risk exposure record was first created in the system.',
    `currency_pair` STRING COMMENT 'The currency pair representing the exchange rate relationship, formatted as base/exposure (e.g., EUR/USD).. Valid values are `^[A-Z]{3}/[A-Z]{3}$`',
    `cvar_1day_99pct` DECIMAL(18,2) COMMENT 'One-day Conditional Value at Risk (expected shortfall) at 99% confidence level for the foreign exchange exposure.',
    `dv01` DECIMAL(18,2) COMMENT 'Sensitivity of the foreign exchange position to a 1 basis point move in the exchange rate, expressed in base currency.',
    `exposure_base_currency_equivalent` DECIMAL(20,2) COMMENT 'Net foreign exchange exposure translated into the base currency using the spot exchange rate at measurement date.',
    `exposure_currency` STRING COMMENT 'The foreign currency to which the portfolio has exposure (ISO 4217 three-letter code).. Valid values are `^[A-Z]{3}$`',
    `exposure_type` STRING COMMENT 'Classification of the foreign exchange exposure: transaction (cash flow), translation (balance sheet), or economic (strategic).. Valid values are `transaction|translation|economic`',
    `geographic_region` STRING COMMENT 'Geographic region or country code (ISO 3166-1 alpha-3) where the underlying assets generating the exposure are located.. Valid values are `^[A-Z]{3}$`',
    `gross_exposure_amount` DECIMAL(20,2) COMMENT 'Total unhedged foreign currency exposure amount in the exposure currency before any hedging instruments are applied.',
    `hedge_effectiveness` DECIMAL(5,4) COMMENT 'Measure of how effectively the hedging instruments offset the foreign exchange exposure, expressed as a ratio (0.0000 to 1.0000).',
    `hedge_instrument_type` STRING COMMENT 'Type of derivative instrument used to hedge the foreign exchange exposure, or none if unhedged.. Valid values are `forward|swap|option|none`',
    `hedge_notional_amount` DECIMAL(20,2) COMMENT 'Notional amount of foreign exchange hedging instruments (forwards, swaps, options) applied to offset the exposure.',
    `hedge_ratio` DECIMAL(5,4) COMMENT 'Proportion of gross exposure that is hedged, calculated as hedge notional divided by gross exposure (0.0000 to 1.0000).',
    `limit_utilization_percentage` DECIMAL(5,2) COMMENT 'Percentage of the assigned foreign exchange risk limit consumed by this exposure.',
    `measurement_date` DATE COMMENT 'Date on which the foreign exchange risk exposure was measured and recorded.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the foreign exchange risk exposure record was last modified or updated.',
    `net_exposure_amount` DECIMAL(20,2) COMMENT 'Net foreign currency exposure after hedging, calculated as gross exposure minus hedge notional.',
    `notes` STRING COMMENT 'Additional commentary, context, or observations regarding the foreign exchange risk exposure.',
    `regulatory_reference` STRING COMMENT 'Reference to the specific regulatory requirement or reporting framework applicable to this exposure.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this foreign exchange exposure must be included in regulatory reporting submissions.',
    `risk_system_source` STRING COMMENT 'Source system that calculated and provided the foreign exchange risk exposure data.. Valid values are `aladdin|riskmetrics|barra|simcorp|internal`',
    `spot_rate` DECIMAL(18,6) COMMENT 'The current market exchange rate between the base currency and exposure currency at measurement date.',
    `stressed_exposure_amount` DECIMAL(20,2) COMMENT 'Foreign exchange exposure amount under the applied stress scenario, expressed in base currency.',
    `time_horizon_days` BIGINT COMMENT 'Number of days over which the foreign exchange risk exposure is measured and risk metrics are calculated.',
    `var_1day_99pct` DECIMAL(18,2) COMMENT 'One-day Value at Risk at 99% confidence level for the foreign exchange exposure, representing potential loss in base currency.',
    `volatility` DECIMAL(8,6) COMMENT 'Historical or implied volatility of the currency pair, expressed as an annualized standard deviation.',
    CONSTRAINT pk_fx_risk_exposure PRIMARY KEY(`fx_risk_exposure_id`)
) COMMENT 'Transactional record of foreign exchange risk exposures across the investment portfolio, capturing unhedged and hedged currency positions by currency pair.';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`attribution` (
    `attribution_id` BIGINT COMMENT 'Unique identifier for the risk attribution record.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Risk attribution approvals are required for performance reporting to beneficiaries. Pension funds must track who approved attribution analysis for IC presentations.',
    `equity_benchmark_id` BIGINT COMMENT 'Reference to the benchmark used for active risk calculation.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio for which risk is being attributed.',
    `risk_model_id` BIGINT COMMENT 'Foreign key linking to risk.model. Business justification: Attribution calculations use a specific risk model for decomposition. The attribution table has risk_model_name and risk_model_version columns that can be normalized by adding a FK to the model',
    `stress_scenario_id` BIGINT COMMENT 'Reference to the stress scenario under which this attribution was calculated, if applicable.',
    `active_risk` DECIMAL(18,6) COMMENT 'Active risk or tracking error relative to benchmark, expressed in percentage terms.',
    `allocation_risk` DECIMAL(18,6) COMMENT 'Portion of active risk attributable to asset allocation decisions across asset classes or sectors, expressed in percentage terms.',
    `approval_date` DATE COMMENT 'Date on which the risk attribution analysis was formally approved.',
    `asset_class_risk` DECIMAL(18,6) COMMENT 'Portion of total risk attributable to asset class allocation decisions, expressed in percentage terms.',
    `attribution_type` STRING COMMENT 'Type of risk attribution analysis performed.. Valid values are `active_risk|total_risk|tracking_error|residual_risk`',
    `beta_to_benchmark` DECIMAL(10,6) COMMENT 'Beta coefficient measuring systematic risk of this component relative to the benchmark.',
    `calculation_methodology` STRING COMMENT 'Methodology used for risk attribution calculation, such as Brinson-Fachler, factor decomposition, or variance decomposition.',
    `calculation_timestamp` TIMESTAMP COMMENT 'Timestamp when the risk attribution calculation was performed.',
    `component_var` DECIMAL(18,6) COMMENT 'Component VaR representing the standalone risk contribution of this attribution component, expressed in percentage terms.',
    `confidence_level` DECIMAL(5,2) COMMENT 'Statistical confidence level used for risk calculations, typically expressed as a percentage such as 95.00 or 99.00.',
    `correlation_to_portfolio` DECIMAL(8,6) COMMENT 'Correlation coefficient between this risk component and total portfolio risk, ranging from -1.000000 to 1.000000.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk attribution record was first created in the system.',
    `currency_risk` DECIMAL(18,6) COMMENT 'Portion of total risk attributable to foreign exchange exposures, expressed in percentage terms.',
    `cvar_contribution` DECIMAL(18,6) COMMENT 'Contribution of this attribution component to portfolio Conditional Value at Risk, expressed in percentage terms.',
    `data_source` STRING COMMENT 'Source system or platform from which attribution data was derived, such as BlackRock Aladdin, MSCI RiskMetrics, or SimCorp Dimension.',
    `decomposition_level` STRING COMMENT 'Granularity level at which risk attribution is decomposed.. Valid values are `portfolio|strategy|asset_class|sector|security`',
    `factor_risk` DECIMAL(18,6) COMMENT 'Portion of total risk attributable to systematic factor exposures, expressed in percentage terms.',
    `geographic_risk` DECIMAL(18,6) COMMENT 'Portion of total risk attributable to geographic or regional exposures, expressed in percentage terms.',
    `interaction_risk` DECIMAL(18,6) COMMENT 'Portion of active risk attributable to the interaction between allocation and selection decisions, expressed in percentage terms.',
    `marginal_var` DECIMAL(18,6) COMMENT 'Marginal contribution to portfolio VaR from a small change in this risk component, expressed in percentage terms.',
    `measurement_date` DATE COMMENT 'Date on which the risk attribution analysis was performed.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk attribution record was last modified.',
    `notes` STRING COMMENT 'Free-text notes or commentary regarding the risk attribution analysis, including any assumptions or caveats.',
    `r_squared` DECIMAL(8,6) COMMENT 'R-squared statistic measuring the proportion of variance explained by the risk model, ranging from 0.000000 to 1.000000.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this attribution record is required for regulatory reporting to SEC, or other governing bodies.',
    `review_status` STRING COMMENT 'Current review and approval status of the risk attribution record.. Valid values are `draft|pending_review|approved|rejected`',
    `risk_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which risk metrics are expressed.. Valid values are `^[A-Z]{3}$`',
    `sector_risk` DECIMAL(18,6) COMMENT 'Portion of total risk attributable to sector allocation and selection, expressed in percentage terms.',
    `selection_risk` DECIMAL(18,6) COMMENT 'Portion of active risk attributable to security selection decisions within asset classes or sectors, expressed in percentage terms.',
    `specific_risk` DECIMAL(18,6) COMMENT 'Portion of total risk attributable to idiosyncratic or security-specific sources, expressed in percentage terms.',
    `style_risk` DECIMAL(18,6) COMMENT 'Portion of total risk attributable to investment style factors such as value, growth, momentum, expressed in percentage terms.',
    `time_horizon_days` BIGINT COMMENT 'Time horizon in days over which risk is measured, commonly 1, 10, or 252 trading days.',
    `total_risk` DECIMAL(18,6) COMMENT 'Total portfolio risk measured as standard deviation of returns, expressed in percentage terms.',
    `var_contribution` DECIMAL(18,6) COMMENT 'Contribution of this attribution component to portfolio Value at Risk, expressed in percentage terms.',
    CONSTRAINT pk_attribution PRIMARY KEY(`attribution_id`)
) COMMENT 'Transactional record of risk attribution decomposing total portfolio risk (active risk / tracking error) into contributing sources: factor risk, specific risk, asset class risk, geographic risk, and currency risk.';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`sensitivity_analysis` (
    `sensitivity_analysis_id` BIGINT COMMENT 'Unique identifier for the sensitivity analysis run record.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Sensitivity analysis sign-off is required for governance. Pension funds must document which employee approved scenario analysis for risk committee reporting.',
    `holding_id` BIGINT COMMENT 'Reference to the specific position being analyzed; null if portfolio-level analysis.',
    `instrument_id` BIGINT COMMENT 'Foreign key linking to trade.instrument. Business justification: Greeks and sensitivity calculations (delta, gamma, vega) are computed per instrument. Essential for derivatives overlay strategies and options hedging programs common in pension fund risk',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio being analyzed for sensitivity to factor shocks.',
    `risk_factor_id` BIGINT COMMENT 'Reference to the single risk factor being shocked in this sensitivity analysis.',
    `stress_scenario_id` BIGINT COMMENT 'Reference to the stress scenario configuration applied in this sensitivity run.',
    `analysis_code` STRING COMMENT 'Business identifier code for the sensitivity analysis run, used for reporting and tracking.. Valid values are `^[A-Z0-9_-]{4,20}$`',
    `analysis_name` STRING COMMENT 'Descriptive name of the sensitivity analysis run for business user identification.',
    `analysis_status` STRING COMMENT 'Current lifecycle status of the sensitivity analysis run.. Valid values are `pending|running|completed|failed|cancelled`',
    `analysis_type` STRING COMMENT 'Classification of the sensitivity analysis methodology applied.. Valid values are `single_factor|multi_factor|scenario|stress_test|what_if`',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the sensitivity analysis was approved.',
    `as_of_date` DATE COMMENT 'Valuation date for which the sensitivity analysis was performed.',
    `asset_class` STRING COMMENT 'Primary asset class of the portfolio or position being analyzed.',
    `base_value` DECIMAL(28,8) COMMENT 'Portfolio or position value before the sensitivity shock is applied.',
    `calculation_methodology` STRING COMMENT 'Methodology used to calculate the sensitivity: full revaluation, delta approximation, Taylor expansion, Monte Carlo, or historical simulation.. Valid values are `full_revaluation|delta_approximation|taylor_expansion|monte_carlo|historical_simulation`',
    `confidence_level` DECIMAL(5,4) COMMENT 'Statistical confidence level used in risk calculations, expressed as a decimal (e.g., 0.9500 for 95%).',
    `convexity_impact` DECIMAL(12,6) COMMENT 'Impact on portfolio convexity resulting from the sensitivity shock.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the sensitivity analysis record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary values in this sensitivity analysis.. Valid values are `^[A-Z]{3}$`',
    `cvar_impact` DECIMAL(28,8) COMMENT 'Change in portfolio Conditional Value at Risk resulting from the sensitivity shock.',
    `duration_impact` DECIMAL(12,6) COMMENT 'Impact on portfolio duration resulting from the sensitivity shock, measured in years.',
    `dv01` DECIMAL(18,6) COMMENT 'Dollar value change for a one basis point move in interest rates, if applicable to this analysis.',
    `escalation_required_flag` BOOLEAN COMMENT 'Indicates whether the sensitivity analysis result requires escalation to senior management or Investment Committee.',
    `execution_timestamp` TIMESTAMP COMMENT 'Date and time when the sensitivity analysis was executed.',
    `geographic_region` STRING COMMENT 'Geographic region of exposure for the portfolio or position being analyzed.',
    `ic_review_required_flag` BOOLEAN COMMENT 'Indicates whether the sensitivity analysis result requires Investment Committee review.',
    `limit_breach_flag` BOOLEAN COMMENT 'Indicates whether the sensitivity analysis result breached any defined risk limits.',
    `limit_utilization_percentage` DECIMAL(12,6) COMMENT 'Percentage of risk limit utilized after the sensitivity shock is applied.',
    `model_version` STRING COMMENT 'Version identifier of the risk model used for the sensitivity analysis.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when the sensitivity analysis record was last modified.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding the sensitivity analysis run, assumptions, or results.',
    `regulatory_reference` STRING COMMENT 'Reference to the specific regulatory requirement or framework that mandates this sensitivity analysis.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this sensitivity analysis is required for regulatory reporting purposes.',
    `risk_factor_category` STRING COMMENT 'High-level classification of the risk factor being analyzed. [ENUM-REF-CANDIDATE: equity|interest_rate|credit_spread|fx|commodity|volatility|inflation|macro — 8 candidates stripped; promote to reference product]',
    `risk_system_source` STRING COMMENT 'Source risk management system that generated this sensitivity analysis (e.g., Aladdin, RiskMetrics, Barra).',
    `sector` STRING COMMENT 'Economic sector classification of the portfolio or position being analyzed.',
    `shock_direction` STRING COMMENT 'Direction of the shock applied: upward, downward, parallel shift, curve twist, or custom.. Valid values are `up|down|parallel|twist|custom`',
    `shock_magnitude` DECIMAL(18,6) COMMENT 'Magnitude of the shock applied to the risk factor, expressed in units consistent with shock type.',
    `shock_type` STRING COMMENT 'Type of shock applied to the risk factor: absolute change, relative change, basis points, or percentage.. Valid values are `absolute|relative|basis_point|percentage`',
    `shocked_value` DECIMAL(28,8) COMMENT 'Portfolio or position value after the sensitivity shock is applied.',
    `time_horizon_days` BIGINT COMMENT 'Time horizon in days over which the sensitivity analysis is measured.',
    `value_change` DECIMAL(28,8) COMMENT 'Absolute change in portfolio or position value resulting from the sensitivity shock.',
    `value_change_percentage` DECIMAL(12,6) COMMENT 'Percentage change in portfolio or position value resulting from the sensitivity shock.',
    `var_impact` DECIMAL(28,8) COMMENT 'Change in portfolio Value at Risk resulting from the sensitivity shock.',
    CONSTRAINT pk_sensitivity_analysis PRIMARY KEY(`sensitivity_analysis_id`)
) COMMENT 'Transactional record of sensitivity analysis runs measuring portfolio or position value changes in response to defined single-factor shocks (e.g., equity market -10%, credit spreads +100bps, oil price -30%, inflation +50bps).';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`risk_review` (
    `risk_review_id` BIGINT COMMENT 'Unique identifier for the risk review record.',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Periodic risk reviews must document which external managers contributed to portfolio risk. IC risk reporting requires identifying GP-specific risk concentrations.',
    `lead_reviewer_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Risk reviews must track the lead reviewer for accountability. Pension funds require documented ownership of periodic risk reviews for governance and audit.',
    `portfolio_id` BIGINT COMMENT 'Identifier of the investment portfolio subject to this risk review.',
    `research_report_id` BIGINT COMMENT 'Foreign key linking to research.report. Business justification: Periodic risk reviews incorporate research reports for market context, sector analysis, and macroeconomic outlook. Risk committee presentations reference research findings.',
    `strategy_id` BIGINT COMMENT 'Identifier of the investment strategy being reviewed for risk assessment.',
    `action_items` STRING COMMENT 'Specific action items assigned to responsible parties with target completion dates.',
    `approval_date` DATE COMMENT 'Date on which the risk review was formally approved by the designated authority.',
    `approved_by` STRING COMMENT 'Name of the senior risk officer or executive who formally approved the risk review findings and recommendations.',
    `asset_class` STRING COMMENT 'Primary asset class focus of the risk review.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `risk_review_code` STRING COMMENT 'Business identifier for the risk review following format RR-YYYY-NNNNNN where YYYY is year and NNNNNN is sequence number.. Valid values are `^RR-[0-9]{4}-[0-9]{6}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk review record was first created in the system.',
    `critical_breach_count` BIGINT COMMENT 'Number of critical-severity risk limit breaches identified during the review period.',
    `cvar_95_amount` DECIMAL(20,2) COMMENT 'Conditional Value at Risk (expected shortfall) at 95 percent confidence level as of the review date.',
    `data_quality_issues` STRING COMMENT 'Description of any data quality issues or gaps encountered during the review that may affect conclusions.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Percentage score representing the completeness and accuracy of data used in the risk review, scale 0 to 100.',
    `document_reference` STRING COMMENT 'File path or document management system reference to the full risk review report and supporting materials.',
    `emerging_risk_count` BIGINT COMMENT 'Number of new or emerging risks identified during this review that require monitoring or action.',
    `frequency` STRING COMMENT 'Scheduled frequency at which this type of risk review is conducted. [ENUM-REF-CANDIDATE: daily|weekly|monthly|quarterly|semi_annual|annual|ad_hoc — 7 candidates stripped; promote to reference product]',
    `ic_decision` STRING COMMENT 'Decision or guidance provided by the Investment Committee in response to this risk review.',
    `ic_review_date` DATE COMMENT 'Date on which the Investment Committee reviewed this risk assessment.',
    `ic_review_required_flag` BOOLEAN COMMENT 'Indicates whether this risk review requires escalation to the Investment Committee for review and decision.',
    `key_findings` STRING COMMENT 'Summary of the most significant findings from the risk review including material risks, trends, and areas of concern.',
    `limit_breach_count` BIGINT COMMENT 'Number of risk limit breaches identified during the review period.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk review record was last modified.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic risk review of this scope.',
    `notes` STRING COMMENT 'Additional notes, context, or commentary related to the risk review.',
    `period_end_date` DATE COMMENT 'End date of the period covered by this risk review.',
    `period_start_date` DATE COMMENT 'Start date of the period covered by this risk review.',
    `previous_risk_rating` STRING COMMENT 'Risk rating from the prior review period for comparison and trend analysis.. Valid values are `low|moderate|elevated|high|critical`',
    `recommendations` STRING COMMENT 'Recommended actions and risk mitigation measures proposed by the review team.',
    `regulatory_reference` STRING COMMENT 'Citation of applicable regulatory requirement or guideline that mandates this review.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether findings from this review must be included in regulatory reporting submissions.',
    `risk_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which risk metrics are denominated.. Valid values are `^[A-Z]{3}$`',
    `risk_rating` STRING COMMENT 'Overall risk rating assigned as a result of this review based on aggregate risk assessment.. Valid values are `low|moderate|elevated|high|critical`',
    `risk_rating_change` STRING COMMENT 'Direction of change in risk rating compared to the previous review period.. Valid values are `upgraded|downgraded|unchanged|new`',
    `risk_review_date` DATE COMMENT 'Date on which the formal risk review was conducted or completed.',
    `risk_review_status` STRING COMMENT 'Current lifecycle status of the risk review process.. Valid values are `draft|in_progress|under_review|approved|published|archived`',
    `risk_review_type` STRING COMMENT 'Category of risk review conducted: portfolio-level, counterparty-specific, concentration analysis, market risk, liquidity risk, or operational risk.. Valid values are `portfolio|counterparty|concentration|market|liquidity|operational`',
    `risk_system_source` STRING COMMENT 'Primary risk analytics system from which risk metrics and data were sourced for this review.. Valid values are `aladdin|msci_riskmetrics|barra|simcorp|internal`',
    `scope` STRING COMMENT 'Detailed description of the scope and boundaries of the risk review including specific portfolios, strategies, or risk factors examined.',
    `stress_test_result` STRING COMMENT 'Summary outcome of the stress test scenario including projected losses or impacts.',
    `stress_test_scenario_applied` STRING COMMENT 'Name or identifier of the macroeconomic stress test scenario applied during this review.',
    `team_members` STRING COMMENT 'Comma-separated list of team members who participated in conducting the risk review.',
    `var_95_amount` DECIMAL(20,2) COMMENT 'Value at Risk calculated at 95 percent confidence level as of the review date.',
    `var_99_amount` DECIMAL(20,2) COMMENT 'Value at Risk calculated at 99 percent confidence level as of the review date.',
    CONSTRAINT pk_risk_review PRIMARY KEY(`risk_review_id`)
) COMMENT 'Master record of formal periodic risk reviews conducted by the Risk Management team covering portfolio-level risk assessment, limit compliance status, emerging risk identification, and risk governance actions.';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`limit_assignment` (
    `limit_assignment_id` BIGINT COMMENT 'Unique identifier for the limit assignment record linking risk limits to portfolios, mandates, asset classes, or investment strategies.',
    `assigned_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Limit assignments need documented assigner for governance. Pension funds track who assigned limits to portfolios/strategies for accountability and audit.',
    `counterparty_id` BIGINT COMMENT 'Reference to the counterparty to which this limit is assigned, if applicable for counterparty credit risk limits.',
    `limit_id` BIGINT COMMENT 'Reference to the risk limit being assigned to an entity.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the investment mandate to which this limit is assigned, if applicable.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio to which this limit is assigned, if applicable.',
    `strategy_id` BIGINT COMMENT 'Reference to the investment strategy to which this limit is assigned, if applicable.',
    `approval_date` DATE COMMENT 'Date on which this limit assignment was formally approved by the designated authority.',
    `approved_by` STRING COMMENT 'Name or identifier of the authority who approved this limit assignment, typically Chief Risk Officer (CRO) or Investment Committee (IC).',
    `asset_class` STRING COMMENT 'The asset class category to which this limit assignment applies such as public equities, private equity, real estate, infrastructure, natural resources, or credit.',
    `assigned_limit_value` DECIMAL(20,4) COMMENT 'The specific limit threshold value assigned to this entity, which may differ from the base limit definition to accommodate entity-specific risk tolerance.',
    `assignment_code` STRING COMMENT 'Business identifier code for the limit assignment used for operational reference and reporting.',
    `assignment_date` DATE COMMENT 'Date on which this limit assignment was created and recorded in the system.',
    `assignment_priority` BIGINT COMMENT 'Priority ranking of this assignment when multiple overlapping limits apply to the same entity, with lower numbers indicating higher priority.',
    `assignment_rationale` STRING COMMENT 'Business justification and reasoning for assigning this specific limit to this entity, including risk considerations and strategic context.',
    `assignment_status` STRING COMMENT 'Current lifecycle status of the limit assignment indicating whether it is currently in force.. Valid values are `active|inactive|pending|suspended|expired|revoked`',
    `assignment_type` STRING COMMENT 'Classification of the assignment indicating the entity type to which the limit is applied.. Valid values are `portfolio|mandate|asset_class|strategy|counterparty|geographic`',
    `auto_remediation_flag` BOOLEAN COMMENT 'Indicates whether automated remediation actions are enabled for breaches of this limit assignment.',
    `breach_count_ytd` BIGINT COMMENT 'Number of times this limit assignment has been breached in the current calendar year.',
    `breach_tolerance_lower` DECIMAL(10,4) COMMENT 'Lower tolerance threshold as a percentage below which a soft breach warning is triggered before a hard limit breach.',
    `breach_tolerance_upper` DECIMAL(10,4) COMMENT 'Upper tolerance threshold as a percentage above which a soft breach warning is triggered before a hard limit breach.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this limit assignment record was first created in the system.',
    `effective_date` DATE COMMENT 'Date from which this limit assignment becomes active and enforceable.',
    `escalation_level` STRING COMMENT 'Organizational level to which limit breaches for this assignment must be escalated.. Valid values are `portfolio_manager|risk_officer|cro|ic|board`',
    `escalation_procedure` STRING COMMENT 'Detailed procedure to be followed when a breach of this limit assignment occurs, including notification and remediation steps.',
    `expiry_date` DATE COMMENT 'Date on which this limit assignment ceases to be active, nullable for open-ended assignments.',
    `geographic_region` STRING COMMENT 'Geographic region or market to which this limit assignment applies for regional concentration limits.',
    `last_breach_date` DATE COMMENT 'Date of the most recent breach of this limit assignment.',
    `last_review_date` DATE COMMENT 'Date of the most recent review of this limit assignment.',
    `limit_currency` STRING COMMENT 'Three-letter ISO currency code for the assigned limit value.',
    `limit_unit` STRING COMMENT 'Unit of measure for the assigned limit such as currency amount, percentage, basis points, or Value at Risk (VaR) units.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this limit assignment record was last modified or updated.',
    `monitoring_frequency` STRING COMMENT 'Frequency at which this limit assignment is monitored for compliance and potential breaches.. Valid values are `real_time|intraday|daily|weekly|monthly|quarterly`',
    `next_review_date` DATE COMMENT 'Scheduled date for the next review of this limit assignment.',
    `notes` STRING COMMENT 'Additional free-text notes, comments, or context regarding this limit assignment for operational reference.',
    `override_flag` BOOLEAN COMMENT 'Indicates whether this assignment overrides other conflicting limit assignments for the same entity.',
    `regulatory_reference` STRING COMMENT 'Citation of the specific regulatory requirement, rule, or guideline that mandates this limit assignment, if applicable.',
    `regulatory_requirement_flag` BOOLEAN COMMENT 'Indicates whether this limit assignment is mandated by regulatory requirements or is an internal risk management control.',
    `remediation_action` STRING COMMENT 'Predefined action to be taken automatically or manually when this limit assignment is breached, such as position reduction or trading halt.',
    `review_frequency` STRING COMMENT 'Scheduled frequency at which this limit assignment is reviewed for continued appropriateness and relevance.. Valid values are `monthly|quarterly|semi_annual|annual|ad_hoc`',
    `risk_system_source` STRING COMMENT 'Name of the risk management system from which this limit assignment originates, such as BlackRock Aladdin or MSCI RiskMetrics.',
    `sector` STRING COMMENT 'Industry sector to which this limit assignment applies for sector concentration limits.',
    `utilization_percentage` DECIMAL(10,4) COMMENT 'Current utilization of the assigned limit expressed as a percentage, calculated as current exposure divided by limit value.',
    CONSTRAINT pk_limit_assignment PRIMARY KEY(`limit_assignment_id`)
) COMMENT 'Association record linking risk limits to specific portfolios, mandates, asset classes, or investment strategies. Captures the risk limit, the entity it applies to (portfolio, fund, asset class, manager mandate), effective start and end dates, assigned';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`factor_return` (
    `factor_return_id` BIGINT COMMENT 'Unique identifier for the factor return record.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Factor return approvals are part of model governance. Pension funds must track who approved factor return data for use in risk calculations and attribution.',
    `factor_id` BIGINT COMMENT 'Reference to the risk factor for which this return is recorded.',
    `risk_model_id` BIGINT COMMENT 'Reference to the risk model under which this factor return was calculated.',
    `approval_status` STRING COMMENT 'The approval status of this factor return record within the risk governance framework.. Valid values are `draft|pending_review|approved|rejected|archived`',
    `approval_timestamp` TIMESTAMP COMMENT 'The timestamp when this factor return was approved for use in risk calculations.',
    `asset_class` STRING COMMENT 'The asset class to which this factor return applies (e.g., public equities, fixed income, real estate, infrastructure).',
    `benchmark_index_code` STRING COMMENT 'The benchmark index code against which this factor return is measured, if applicable.',
    `beta_to_market` DECIMAL(10,6) COMMENT 'The systematic risk measure of the factor relative to the overall market.',
    `calculation_methodology` STRING COMMENT 'Description of the methodology used to calculate this factor return (e.g., regression-based, principal component analysis, fundamental factor model).',
    `calculation_timestamp` TIMESTAMP COMMENT 'The timestamp when this factor return was calculated by the risk system.',
    `confidence_level` DECIMAL(5,2) COMMENT 'The confidence level used in statistical testing of the factor return, expressed as a percentage (e.g., 95.00 for 95%).',
    `correlation_to_market` DECIMAL(5,4) COMMENT 'The correlation coefficient between the factor return and the market return.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this factor return record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the factor return is denominated.. Valid values are `^[A-Z]{3}$`',
    `data_quality_score` DECIMAL(5,2) COMMENT 'A quality score indicating the completeness and reliability of the underlying data used to calculate this factor return, expressed as a percentage.',
    `data_source` STRING COMMENT 'The source system or vendor from which the underlying data for this factor return was obtained (e.g., Bloomberg, MSCI, FactSet).',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether this factor incorporates ESG considerations in its construction or calculation.',
    `factor_category` STRING COMMENT 'High-level category of the risk factor (e.g., style, industry, country, currency, macroeconomic, statistical).. Valid values are `style|industry|country|currency|macro|statistical`',
    `factor_type` STRING COMMENT 'Specific type or sub-classification of the factor within its category (e.g., value, momentum, size, volatility).',
    `geographic_region` STRING COMMENT 'The geographic region or market to which this factor return applies (e.g., North America, Europe, Asia-Pacific, Global).',
    `information_ratio` DECIMAL(10,4) COMMENT 'The ratio of active return to tracking error for the factor relative to its benchmark.',
    `is_material_factor` BOOLEAN COMMENT 'Indicates whether this factor is considered material to portfolio risk based on contribution thresholds.',
    `is_proprietary` BOOLEAN COMMENT 'Indicates whether this factor is a proprietary internal factor (True) or a vendor-provided factor (False).',
    `lookback_period_days` BIGINT COMMENT 'The number of days used in the historical lookback window for calculating this factor return.',
    `modified_timestamp` TIMESTAMP COMMENT 'The timestamp when this factor return record was last modified.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding this factor return observation, including any anomalies or special considerations.',
    `observation_count` BIGINT COMMENT 'The number of data points or observations used in calculating this factor return.',
    `r_squared` DECIMAL(5,4) COMMENT 'The coefficient of determination indicating the proportion of variance in returns explained by the factor model.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this factor return must be included in regulatory risk reporting submissions.',
    `return_date` DATE COMMENT 'The date for which this factor return is recorded.',
    `return_percentage` DECIMAL(10,4) COMMENT 'The realized return of the risk factor expressed as a percentage for reporting purposes.',
    `return_period_type` STRING COMMENT 'The time period granularity for this factor return observation.. Valid values are `daily|weekly|monthly|quarterly|annual`',
    `return_value` DECIMAL(18,8) COMMENT 'The realized return of the risk factor for the specified period, expressed as a decimal (e.g., 0.0125 for 1.25%).',
    `sector_classification` STRING COMMENT 'Industry sector classification if this is an industry factor return (e.g., GICS sector code or name).',
    `sharpe_ratio` DECIMAL(10,4) COMMENT 'The risk-adjusted return metric for the factor, calculated as excess return divided by volatility.',
    `t_statistic` DECIMAL(10,4) COMMENT 'The t-statistic measuring the statistical significance of the factor return.',
    `usage_in_attribution` BOOLEAN COMMENT 'Indicates whether this factor return is used in performance attribution analysis.',
    `usage_in_stress_testing` BOOLEAN COMMENT 'Indicates whether this factor return is used in macroeconomic stress testing and scenario analysis.',
    `usage_in_var_calculation` BOOLEAN COMMENT 'Indicates whether this factor return is used in historical simulation VaR calculations.',
    `vendor_model_name` STRING COMMENT 'The name of the vendor risk model used to generate this factor return (e.g., Barra Global Equity Model, MSCI World Factor Model).',
    `vendor_model_version` STRING COMMENT 'The version identifier of the vendor risk model used for this calculation.',
    `volatility` DECIMAL(10,6) COMMENT 'The annualized volatility of the factor over the measurement period, expressed as a decimal.',
    CONSTRAINT pk_factor_return PRIMARY KEY(`factor_return_id`)
) COMMENT 'Transactional record of realized risk factor returns over defined periods, used for historical simulation VaR, factor model calibration, and performance attribution.';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`credit_rating` (
    `credit_rating_id` BIGINT COMMENT 'Unique identifier for the credit rating record.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Credit rating overrides/approvals need documented accountability. Pension funds track who approved internal rating overrides for credit risk governance.',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: Credit ratings drive margin call thresholds and collateral eligibility decisions. Pension funds must assess counterparty creditworthiness for OTC derivative exposures.',
    `rating_id` BIGINT COMMENT 'FK to credit.rating.rating_id — Risk calculations that bucket by credit quality must use the single rating SSOT in credit to avoid divergent rating snapshots feeding VaR and concentration risk.',
    `approval_date` DATE COMMENT 'Date when the internal rating assessment or override was approved.',
    `asset_class` STRING COMMENT 'Asset class of the rated instrument or issuer: equity, fixed income, credit, structured products, sovereign, municipal, or corporate. [ENUM-REF-CANDIDATE: equity|fixed_income|credit|structured|sovereign|municipal|corporate — 7 candidates stripped; promote',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the credit rating record was first created in the system.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Data quality score for the rating record, indicating completeness and accuracy of the data.',
    `ecl_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the expected credit loss amount.. Valid values are `^[A-Z]{3}$`',
    `expected_credit_loss_amount` DECIMAL(18,2) COMMENT 'Expected credit loss amount calculated based on the rating, exposure, probability of default, and loss given default.',
    `geographic_region` STRING COMMENT 'Geographic region or country of the issuer or instrument domicile.',
    `instrument_cusip` STRING COMMENT 'CUSIP identifier of the instrument being rated, if applicable.. Valid values are `^[A-Z0-9]{9}$`',
    `instrument_isin` STRING COMMENT 'ISIN of the specific instrument being rated, if applicable. Null for issuer-level ratings.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `internal_rating_override` STRING COMMENT 'Internal credit assessment that overrides or supplements the external rating, if applicable.',
    `internal_rating_rationale` STRING COMMENT 'Rationale for internal rating override or adjustment, documenting the basis for deviation from external rating.',
    `is_solicited_rating` BOOLEAN COMMENT 'Indicates whether the rating was solicited by the issuer (true) or unsolicited (false).',
    `issuer_lei` STRING COMMENT 'Legal Entity Identifier of the issuer or counterparty being rated.. Valid values are `^[A-Z0-9]{20}$`',
    `issuer_name` STRING COMMENT 'Legal name of the issuer or counterparty being rated.',
    `last_review_date` DATE COMMENT 'Date when the credit rating was last reviewed by internal risk management.',
    `loss_given_default_pct` DECIMAL(8,5) COMMENT 'Estimated loss given default associated with the credit rating, expressed as a percentage of exposure at default.',
    `maturity_date` DATE COMMENT 'Maturity date of the rated instrument, if applicable.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the credit rating record was last modified in the system.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next review of the credit rating by internal risk management.',
    `notes` STRING COMMENT 'Additional notes or comments regarding the credit rating, rating action, or internal assessment.',
    `outlook` STRING COMMENT 'Rating agency outlook indicating the potential direction of the rating: positive, stable, negative, developing, or not applicable.. Valid values are `positive|stable|negative|developing|not_applicable`',
    `previous_rating_value` DECIMAL(18,2) COMMENT 'The credit rating value prior to the most recent rating action, if applicable.',
    `probability_of_default_pct` DECIMAL(8,5) COMMENT 'Estimated probability of default associated with the credit rating, expressed as a percentage.',
    `rating_action_date` DATE COMMENT 'Date when the rating agency took action (affirmed, upgraded, downgraded, or withdrew the rating).',
    `rating_action_type` STRING COMMENT 'Type of rating action taken: new assignment, affirmation, upgrade, downgrade, withdrawal, or suspension.. Valid values are `new|affirmed|upgraded|downgraded|withdrawn|suspended`',
    `rating_agency` STRING COMMENT 'Name of the rating agency that assigned the credit rating: S&P, Moodys, Fitch, DBRS, or Internal assessment.. Valid values are `SP|Moodys|Fitch|DBRS|Internal`',
    `rating_category` STRING COMMENT 'Broad category of the credit rating: investment grade (IG), high yield (HY), non-rated, or default.. Valid values are `investment_grade|high_yield|non_rated|default`',
    `rating_change_notches` BIGINT COMMENT 'Number of notches the rating changed in the most recent action (positive for upgrades, negative for downgrades).',
    `rating_effective_date` DATE COMMENT 'Date when the credit rating became effective or was assigned.',
    `rating_notch` BIGINT COMMENT 'Numeric notch representation of the rating for quantitative analysis, where higher values indicate better credit quality.',
    `rating_scale` STRING COMMENT 'Rating scale used: long-term, short-term, issuer default rating, or financial strength rating.. Valid values are `long_term|short_term|issuer_default|financial_strength`',
    `rating_source_identifier` STRING COMMENT 'Unique identifier of the rating record in the source system.',
    `rating_source_system` STRING COMMENT 'Source system from which the credit rating data was obtained (e.g., Bloomberg, Aladdin, vendor feed).',
    `rating_type` STRING COMMENT 'Type of credit rating: issuer-level, instrument-level, counterparty, sovereign, municipal, corporate, or structured finance. [ENUM-REF-CANDIDATE: issuer|instrument|counterparty|sovereign|municipal|corporate|structured — 7 candidates stripped; promote to',
    `rating_value` DECIMAL(18,2) COMMENT 'The actual credit rating value assigned by the rating agency (e.g., AAA, Aa1, BBB+, B-, CCC).',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this rating is used for regulatory capital or reporting purposes.',
    `risk_weight_pct` DECIMAL(8,5) COMMENT 'Regulatory risk weight percentage assigned based on the credit rating for capital adequacy calculations.',
    `sector_classification` STRING COMMENT 'Industry sector classification of the issuer (e.g., financials, industrials, utilities, technology).',
    `seniority` STRING COMMENT 'Seniority level of the rated instrument in the capital structure: senior secured, senior unsecured, subordinated, junior, or equity.. Valid values are `senior_secured|senior_unsecured|subordinated|junior|equity`',
    `watch_status` STRING COMMENT 'Indicates if the rating is on credit watch for potential upgrade, downgrade, or under review.. Valid values are `none|positive_watch|negative_watch|developing_watch`',
    CONSTRAINT pk_credit_rating PRIMARY KEY(`credit_rating_id`)
) COMMENT 'Master record of external credit ratings assigned to issuers and instruments held in the portfolio, sourced from rating agencies (S&P, Moodys, Fitch) and internal credit assessment.';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`risk_exception` (
    `risk_exception_id` BIGINT COMMENT 'Unique identifier for the risk exception record.',
    `counterparty_id` BIGINT COMMENT 'Reference to the counterparty entity if the exception relates to counterparty exposure limits.',
    `limit_id` BIGINT COMMENT 'Reference to the risk limit that this exception applies to.',
    `manager_mandate_id` BIGINT COMMENT 'Foreign key linking to manager.manager_mandate. Business justification: Risk exceptions (limit overrides) are often granted for specific mandate allocations.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio for which the exception is granted.',
    `requested_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Exception requests must track the requestor for governance. Pension funds require documented accountability for who initiated each risk exception request.',
    `strategy_id` BIGINT COMMENT 'Reference to the investment strategy associated with this exception.',
    `approval_date` DATE COMMENT 'Date when the exception was formally approved by the designated authority.',
    `approval_level` STRING COMMENT 'Organizational level or authority required to approve this exception based on materiality and risk.. Valid values are `portfolio_manager|cro|cio|ic|board`',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee who approved the exception.',
    `asset_class` STRING COMMENT 'The asset class to which this exception applies. [ENUM-REF-CANDIDATE: public_equities|private_equity|real_estate|infrastructure|natural_resources|credit|fixed_income|cash — 8 candidates stripped; promote to reference product]',
    `breach_count` BIGINT COMMENT 'Number of times the exception threshold itself has been breached during the active period.',
    `business_rationale` STRING COMMENT 'Detailed business justification for requesting the exception, including strategic context and expected benefits.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the exception record was first created in the system.',
    `currency` STRING COMMENT 'Three-letter ISO currency code for monetary thresholds and limits.. Valid values are `^[A-Z]{3}$`',
    `duration_days` BIGINT COMMENT 'Number of calendar days for which the exception is valid.',
    `effective_date` DATE COMMENT 'Date from which the exception becomes active and the portfolio may operate outside standard limits.',
    `escalation_procedure` STRING COMMENT 'Defined procedure for escalating issues if the exception threshold is itself breached or conditions change.',
    `exception_code` STRING COMMENT 'Business identifier code for the exception, typically formatted as three-letter prefix followed by six-digit sequence.. Valid values are `^[A-Z]{3}-[0-9]{6}$`',
    `exception_name` STRING COMMENT 'Short descriptive name of the risk exception for identification and reporting purposes.',
    `exception_status` STRING COMMENT 'Current lifecycle status of the exception request and approval.. Valid values are `pending|approved|active|expired|revoked|rejected`',
    `exception_type` STRING COMMENT 'Classification of the exception by the nature of the risk constraint being waived or exceeded.. Valid values are `limit_breach|policy_override|concentration_waiver|counterparty_excess|liquidity_variance|var_exceedance`',
    `expiry_date` DATE COMMENT 'Date when the exception expires and standard limits are reinstated.',
    `geographic_region` STRING COMMENT 'Geographic region or market to which the exception applies, using three-letter country codes or regional groupings.',
    `ic_review_date` DATE COMMENT 'Date when the Investment Committee reviewed and approved the exception.',
    `ic_review_required_flag` BOOLEAN COMMENT 'Indicates whether Investment Committee review and approval is required for this exception.',
    `last_breach_date` DATE COMMENT 'Most recent date when the exception threshold was breached.',
    `last_review_date` DATE COMMENT 'Date of the most recent formal review of the exception.',
    `mitigation_measures` STRING COMMENT 'Specific risk mitigation actions or controls that will be implemented while the exception is active.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the exception record was last modified.',
    `monitoring_frequency` STRING COMMENT 'Frequency at which the portfolio will be monitored for compliance with the exception terms.. Valid values are `real_time|intraday|daily|weekly|monthly`',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal review of the exception.',
    `notes` STRING COMMENT 'Additional free-text notes or comments regarding the exception.',
    `original_limit_value` DECIMAL(20,4) COMMENT 'The standard limit value that is being temporarily waived or exceeded.',
    `regulatory_reference` STRING COMMENT 'Reference to the specific regulatory requirement or guideline that governs this exception.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this exception must be reported to regulatory authorities.',
    `request_date` DATE COMMENT 'Date when the exception was formally requested.',
    `review_frequency` STRING COMMENT 'Frequency at which the exception will be formally reviewed by risk management or governance bodies.. Valid values are `weekly|monthly|quarterly|ad_hoc`',
    `revocation_date` DATE COMMENT 'Date when the exception was revoked prior to its scheduled expiry.',
    `revocation_reason` STRING COMMENT 'Explanation for why the exception was revoked before its scheduled expiry date.',
    `revoked_by` STRING COMMENT 'Name or identifier of the individual or authority who revoked the exception.',
    `risk_assessment` STRING COMMENT 'Summary of the risk analysis conducted to evaluate the impact of granting the exception.',
    `risk_system_source` STRING COMMENT 'Name of the risk management system or platform from which the exception data originates.',
    `sector` STRING COMMENT 'Industry sector classification to which the exception applies.',
    `threshold_value` DECIMAL(20,4) COMMENT 'The temporary threshold or limit value permitted under this exception.',
    `unit_of_measure` STRING COMMENT 'Unit in which the threshold is expressed, such as currency, percentage, basis points, or count.',
    `utilization_percentage` DECIMAL(10,4) COMMENT 'Current utilization of the exception threshold as a percentage of the permitted limit.',
    `variance_amount` DECIMAL(20,4) COMMENT 'Absolute difference between the exception threshold and the original limit.',
    `variance_percentage` DECIMAL(10,4) COMMENT 'Percentage variance between the exception threshold and the original limit.',
    CONSTRAINT pk_risk_exception PRIMARY KEY(`risk_exception_id`)
) COMMENT 'Transactional record of formally approved exceptions to risk limits or investment policy constraints, where a portfolio is permitted to operate outside standard limits for a defined period.';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`correlation_matrix` (
    `correlation_matrix_id` BIGINT COMMENT 'Unique identifier for the correlation matrix record.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Correlation matrix approvals are critical for model governance. Pension funds must track who approved correlation assumptions for VaR and stress testing.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio for which this correlation matrix is applied.',
    `risk_model_id` BIGINT COMMENT 'Reference to the risk model that uses this correlation matrix for portfolio risk calculations.',
    `superseded_by_matrix_correlation_matrix_id` BIGINT COMMENT 'Reference to the newer correlation matrix that replaces this one when status changes to superseded.',
    `adjustment_applied_flag` BOOLEAN COMMENT 'Indicates whether numerical adjustments were applied to ensure positive definiteness or stability.',
    `adjustment_method` STRING COMMENT 'Method used to adjust the matrix such as eigenvalue flooring, nearest correlation matrix, or Higham algorithm.',
    `approval_date` DATE COMMENT 'Date when the correlation matrix was formally approved for use in risk calculations.',
    `as_of_date` DATE COMMENT 'Business date for which the correlation matrix is calculated and applicable.',
    `asset_class` STRING COMMENT 'Primary asset class scope for the correlation matrix such as public equities, private equity, real estate, infrastructure, natural resources, or credit.',
    `average_correlation` DECIMAL(8,6) COMMENT 'Mean of all pairwise correlation coefficients in the matrix, used for summary risk assessment.',
    `calculation_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the correlation matrix was computed by the risk system.',
    `condition_number` DECIMAL(20,6) COMMENT 'Ratio of largest to smallest eigenvalue indicating numerical stability and multicollinearity of the correlation matrix.',
    `confidence_level` DECIMAL(5,4) COMMENT 'Statistical confidence level for correlation estimates expressed as a decimal.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this correlation matrix record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for returns used in correlation calculation.. Valid values are `^[A-Z]{3}$`',
    `data_source` STRING COMMENT 'Source system or vendor providing the underlying return data for correlation estimation.',
    `decay_factor` DECIMAL(10,6) COMMENT 'Exponential decay factor applied in weighted correlation estimation to give more weight to recent observations.',
    `dimension_count` BIGINT COMMENT 'Number of assets, factors, or entities included in the correlation matrix.',
    `effective_from_date` DATE COMMENT 'Date from which this correlation matrix becomes effective for risk calculations.',
    `effective_to_date` DATE COMMENT 'Date until which this correlation matrix remains effective, nullable for open-ended matrices.',
    `estimation_methodology` STRING COMMENT 'Statistical method used to estimate correlations such as rolling window, exponentially weighted moving average, or shrinkage estimator.',
    `geographic_scope` STRING COMMENT 'Geographic region or market scope covered by the correlation matrix such as global, regional, or country-specific.',
    `ic_approval_required_flag` BOOLEAN COMMENT 'Indicates whether Investment Committee approval is required before using this correlation matrix in risk calculations.',
    `last_review_date` DATE COMMENT 'Date when the correlation matrix was last reviewed by risk management or Investment Committee.',
    `lookback_period_days` BIGINT COMMENT 'Number of historical days used in the correlation estimation calculation.',
    `matrix_code` STRING COMMENT 'Business identifier code for the correlation matrix used in risk calculations and reporting.',
    `matrix_determinant` DECIMAL(20,10) COMMENT 'Determinant of the correlation matrix used to assess matrix invertibility and numerical stability.',
    `matrix_name` STRING COMMENT 'Descriptive name of the correlation matrix for business user identification.',
    `matrix_status` STRING COMMENT 'Current lifecycle status of the correlation matrix in the risk management system.. Valid values are `active|inactive|draft|approved|superseded|archived`',
    `matrix_type` STRING COMMENT 'Type of correlation matrix indicating the dimension being correlated.. Valid values are `asset_class|factor|currency|sector|geographic|counterparty`',
    `maximum_correlation` DECIMAL(8,6) COMMENT 'Highest correlation coefficient in the matrix indicating strongest positive relationship.',
    `minimum_correlation` DECIMAL(8,6) COMMENT 'Lowest correlation coefficient in the matrix indicating strongest negative relationship.',
    `model_version` STRING COMMENT 'Version identifier of the risk model or calculation engine used to produce the correlation matrix.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this correlation matrix record was last modified in the system.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next review of the correlation matrix.',
    `notes` STRING COMMENT 'Free-text notes or comments about the correlation matrix for risk analyst reference.',
    `observation_frequency` STRING COMMENT 'Frequency of return observations used in correlation estimation.. Valid values are `daily|weekly|monthly|quarterly`',
    `positive_definite_flag` BOOLEAN COMMENT 'Indicates whether the correlation matrix is positive definite, a mathematical requirement for valid covariance matrices.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this correlation matrix is used for regulatory risk reporting requirements.',
    `review_frequency` STRING COMMENT 'Scheduled frequency for reviewing and recalculating the correlation matrix.. Valid values are `daily|weekly|monthly|quarterly|annually`',
    `risk_system_source` STRING COMMENT 'Name of the risk management system that generated or stores this correlation matrix such as Aladdin or RiskMetrics.',
    `shrinkage_intensity` DECIMAL(5,4) COMMENT 'Intensity parameter for shrinkage estimator used to stabilize correlation estimates by blending sample and target matrices.',
    `usage_in_stress_testing` BOOLEAN COMMENT 'Indicates whether this correlation matrix is used in macroeconomic stress testing scenarios.',
    `usage_in_var_calculation` BOOLEAN COMMENT 'Indicates whether this correlation matrix is used in portfolio Value at Risk calculations.',
    `vendor_model_name` STRING COMMENT 'Name of the vendor risk model used to generate the correlation matrix such as MSCI Barra or RiskMetrics.',
    CONSTRAINT pk_correlation_matrix PRIMARY KEY(`correlation_matrix_id`)
) COMMENT 'Transactional record of asset class and factor correlation matrices used in portfolio risk calculations. Captures matrix type (asset class, factor, currency), the set of assets or factors included, correlation coefficients, estimation methodology (rolling';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`appetite_statement` (
    `appetite_statement_id` BIGINT COMMENT 'Unique identifier for the risk appetite statement record.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Risk appetite statements require board/IC approval tracking. Pension funds must document which senior employee approved appetite statements for governance.',
    `esg_policy_id` BIGINT COMMENT 'Foreign key linking to esg.policy. Business justification: TCFD governance pillar requires documented alignment between risk appetite and ESG/climate policies.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Pension fund risk appetite statements must align with regulatory requirements from specific authorities. The regulatory_requirement_flag indicates regulatory-driven appetite.',
    `superseded_by_statement_appetite_statement_id` BIGINT COMMENT 'Identifier of the risk appetite statement that supersedes this version, establishing version lineage and audit trail.',
    `approval_date` DATE COMMENT 'Date on which this risk appetite statement was formally approved by the board or designated committee.',
    `asset_class` STRING COMMENT 'Asset class to which this risk appetite statement applies, or all for enterprise-wide statements. [ENUM-REF-CANDIDATE: public_equities|private_equity|real_estate|infrastructure|natural_resources|credit|multi_asset|all — 8 candidates stripped; promote to',
    `calculation_methodology` STRING COMMENT 'Detailed description of the methodology used to calculate the risk metric, including model assumptions, data sources, and computational approach.',
    `climate_scenario_alignment` STRING COMMENT 'Description of alignment with climate-related financial risk scenarios, such as Task Force on Climate-related Financial Disclosures (TCFD) scenarios or net-zero transition pathways.',
    `confidence_level` DECIMAL(5,2) COMMENT 'Statistical confidence level used in risk metric calculation, typically 95.00 or 99.00 percent for Value at Risk (VaR) and Conditional Value at Risk (CVaR) measures.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk appetite statement record was first created in the system, supporting audit trail and data lineage.',
    `effective_date` DATE COMMENT 'Date from which this risk appetite statement becomes binding and enforceable, typically aligned with board approval date.',
    `escalation_level` STRING COMMENT 'Governance level to which breaches of this risk appetite statement must be escalated, reflecting materiality and severity.. Valid values are `portfolio_manager|cro|cio|risk_committee|investment_committee|board`',
    `escalation_procedure` STRING COMMENT 'Documented procedure for escalating risk appetite breaches, including notification protocols and decision-making authority.',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether this risk appetite statement explicitly incorporates Environmental, Social, and Governance (ESG) risk considerations.',
    `expiry_date` DATE COMMENT 'Date on which this risk appetite statement expires or is scheduled for mandatory review, typically annual or aligned with strategic planning cycle.',
    `external_reference_code` STRING COMMENT 'Unique identifier for this risk appetite statement in the external source system, enabling cross-system reconciliation and lineage tracking.',
    `geographic_scope` STRING COMMENT 'Geographic region or market to which this risk appetite statement applies, using ISO 3166-1 alpha-3 country codes or regional groupings.',
    `last_review_date` DATE COMMENT 'Date of the most recent formal review of this risk appetite statement by the board or designated committee.',
    `liability_matching_consideration` STRING COMMENT 'Description of how this risk appetite statement considers the pension funds long-duration liability profile and Asset-Liability Management (ALM) constraints.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk appetite statement record was last modified, supporting audit trail and change tracking.',
    `monitoring_frequency` STRING COMMENT 'Frequency at which risk exposure against this appetite statement is monitored and reported.. Valid values are `real_time|intraday|daily|weekly|monthly|quarterly`',
    `next_review_date` DATE COMMENT 'Date of the next scheduled formal review of this risk appetite statement.',
    `notes` STRING COMMENT 'Free-text field for additional context, clarifications, or operational notes related to this risk appetite statement.',
    `rationale` STRING COMMENT 'Business rationale and strategic context for the defined risk tolerance levels, linking risk appetite to investment objectives and liability obligations.',
    `regulatory_reference` STRING COMMENT 'Citation or reference to the specific regulatory requirement, guideline, or supervisory expectation that this risk appetite statement addresses.',
    `regulatory_requirement_flag` BOOLEAN COMMENT 'Indicates whether this risk appetite statement is driven by or aligned with a specific regulatory requirement or supervisory expectation.',
    `review_frequency` STRING COMMENT 'Scheduled frequency for formal review and reaffirmation of the risk appetite statement by the board or designated committee.. Valid values are `monthly|quarterly|semi_annually|annually|ad_hoc`',
    `risk_category` STRING COMMENT 'Primary risk category that this appetite statement addresses, aligned with enterprise risk taxonomy.. Valid values are `market_risk|credit_risk|liquidity_risk|concentration_risk|operational_risk|esg_risk`',
    `risk_model_name` STRING COMMENT 'Name of the risk model or system used to measure exposure against this appetite statement, such as Aladdin, RiskMetrics, or Barra.',
    `risk_model_version` STRING COMMENT 'Version identifier of the risk model used for measurement, ensuring consistency and auditability of risk calculations.',
    `risk_subcategory` STRING COMMENT 'Detailed subcategory within the primary risk category, such as equity risk, interest rate risk, or counterparty credit risk.',
    `statement_code` STRING COMMENT 'Externally-known unique business identifier for the risk appetite statement, typically used in board materials and regulatory filings.. Valid values are `^RAS-[A-Z0-9]{6,12}$`',
    `statement_name` STRING COMMENT 'Human-readable name or title of the risk appetite statement, typically reflecting the fiscal year or strategic planning period.',
    `statement_status` STRING COMMENT 'Current lifecycle status of the risk appetite statement within the governance approval workflow.. Valid values are `draft|pending_approval|approved|active|superseded|archived`',
    `statement_version` STRING COMMENT 'Version number of the risk appetite statement, incremented with each board-approved revision.. Valid values are `^[0-9]{1,3}.[0-9]{1,3}$`',
    `stress_scenario_alignment` STRING COMMENT 'Description of how this risk appetite statement is calibrated or validated against enterprise stress testing scenarios and macroeconomic sensitivity analysis.',
    `target_threshold` DECIMAL(18,4) COMMENT 'Target or preferred level of risk exposure, typically lower than the tolerance threshold, representing the desired operating range.',
    `time_horizon_days` BIGINT COMMENT 'Time horizon in days over which the risk metric is measured, commonly 1, 10, or 252 days for market risk.',
    `tolerance_currency` STRING COMMENT 'ISO 4217 three-letter currency code when tolerance threshold is expressed in monetary terms.. Valid values are `^[A-Z]{3}$`',
    `tolerance_metric` STRING COMMENT 'The specific risk metric or measure used to quantify risk tolerance, such as Value at Risk (VaR), Conditional Value at Risk (CVaR), or tracking error.',
    `tolerance_threshold` DECIMAL(18,4) COMMENT 'Numeric threshold value representing the maximum acceptable level of risk for the specified metric, expressed in the unit defined by tolerance unit.',
    `tolerance_unit` STRING COMMENT 'Unit of measure for the tolerance threshold value, such as currency, percentage, basis points, or ratio.. Valid values are `currency|percentage|basis_points|ratio|count|index_points`',
    `warning_threshold` DECIMAL(18,4) COMMENT 'Early warning threshold that triggers heightened monitoring and management attention before tolerance threshold is breached.',
    CONSTRAINT pk_appetite_statement PRIMARY KEY(`appetite_statement_id`)
) COMMENT 'Master record of the enterprise Risk Appetite Statement (RAS) defining the board-approved risk tolerance levels across risk categories: market risk, credit risk, liquidity risk, concentration risk, operational risk, and ESG risk.';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`model_validation` (
    `model_validation_id` BIGINT COMMENT 'Unique identifier for the model validation record.',
    `employee_id` BIGINT COMMENT 'Identifier of the user who initiated the validation.',
    `job_run_user_employee_id` BIGINT COMMENT 'Identifier of the user who triggered the job run.',
    `model_employee_id` BIGINT COMMENT 'Identifier of the user who initiated the validation.',
    `model_id` BIGINT COMMENT 'Identifier of the risk model being validated.',
    `model_job_run_user_employee_id` BIGINT COMMENT 'Identifier of the user who triggered the job run.',
    `validation_run_id` BIGINT COMMENT 'Unique alphanumeric code for the validation run.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was first created.',
    `environment` STRING COMMENT 'Execution environment of the validation run.. Valid values are `prod|test|dev`',
    `job_run_cluster_code` STRING COMMENT 'Identifier of the cluster used for the job run.',
    `job_run_cluster_config_hash` STRING COMMENT 'Hash of the cluster configuration for integrity.',
    `job_run_cluster_config_json` STRING COMMENT 'JSON representation of the cluster configuration.',
    `job_run_cluster_config_properties` STRING COMMENT 'Cluster configuration properties as key-value pairs.',
    `job_run_cluster_config_properties_hash` STRING COMMENT 'Hash of the cluster configuration properties.',
    `job_run_cluster_config_properties_json` STRING COMMENT 'JSON of cluster configuration properties.',
    `job_run_cluster_name` STRING COMMENT 'Name of the cluster used for the job run.',
    `job_run_cluster_type` STRING COMMENT 'Type of cluster used for the job run.. Valid values are `spark|databricks|k8s`',
    `job_run_cluster_version` STRING COMMENT 'Version of the cluster used for the job run.',
    `job_run_code` STRING COMMENT 'Identifier of the Databricks job run.',
    `job_run_end_time` TIMESTAMP COMMENT 'Timestamp when the job run finished.',
    `job_run_error` STRING COMMENT 'Error message from the job run if any.',
    `job_run_log_url` STRING COMMENT 'URL to the job run logs.',
    `job_run_parameters_hash` STRING COMMENT 'Hash of the job run parameters for integrity.',
    `job_run_parameters_json` STRING COMMENT 'JSON of parameters passed to the job run.',
    `job_run_start_time` TIMESTAMP COMMENT 'Timestamp when the job run started.',
    `job_run_status` STRING COMMENT 'Current status of the Databricks job run.. Valid values are `running|completed|failed|cancelled`',
    `job_run_user` STRING COMMENT 'Username of the individual who triggered the job run.',
    `model_validation_status` STRING COMMENT 'Current lifecycle status of the validation process.. Valid values are `pending|in_progress|completed|failed|archived`',
    `notes` STRING COMMENT 'Free-text notes or observations from the validation.',
    `platform` STRING COMMENT 'Platform used for validation (e.g., Databricks).',
    `risk_model_version` STRING COMMENT 'Version of the risk model used in the validation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `validation_date` TIMESTAMP COMMENT 'Timestamp when the validation was executed.',
    `validation_duration_seconds` BIGINT COMMENT 'Total duration of the validation in seconds.',
    `validation_end_timestamp` TIMESTAMP COMMENT 'Timestamp when the validation finished.',
    `validation_engine` STRING COMMENT 'Name of the engine or framework used for validation.',
    `validation_engine_version` STRING COMMENT 'Version of the validation engine.',
    `validation_outcome` STRING COMMENT 'Result of the validation process.. Valid values are `pass|fail|warning`',
    `validation_parameters_hash` STRING COMMENT 'Hash of the validation parameters for integrity.',
    `validation_parameters_json` STRING COMMENT 'JSON representation of parameters used in the validation.',
    `validation_start_timestamp` TIMESTAMP COMMENT 'Timestamp when the validation started.',
    `validation_type` STRING COMMENT 'Category of the validation activity.. Valid values are `initial|periodic|backtest|benchmarking`',
    `validation_version` STRING COMMENT 'Version identifier of the validation logic.',
    CONSTRAINT pk_model_validation PRIMARY KEY(`model_validation_id`)
) COMMENT 'Transactional record of risk model validation and backtesting activities required for model risk governance (model risk management guidance / SR 11-7 style). Captures the risk model validated, validation type (initial, periodic, backtest, benchmarking), validation date';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`scenario_requirement` (
    `scenario_requirement_id` BIGINT COMMENT 'Unique identifier for the scenario requirement record. Primary key.',
    `obligation_id` BIGINT COMMENT 'Foreign key linking to the compliance obligation requiring this scenario',
    `stress_scenario_id` BIGINT COMMENT 'Foreign key linking to the stress scenario that must be executed',
    `applicability_status` STRING COMMENT 'Whether this stress scenario is required, recommended, or optional for satisfying this compliance obligation. Derived from detection phase scenario_applicability_status.',
    `compliance_deadline` DATE COMMENT 'The deadline by which this stress scenario must be executed to satisfy this specific compliance obligation. Different obligations may have different deadlines for the same scenario.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this scenario requirement record was created.',
    `last_execution_date` DATE COMMENT 'Date when this stress scenario was last executed specifically for this compliance obligation. Tracks execution history per obligation.',
    `next_required_date` DATE COMMENT 'The next date by which this stress scenario must be executed for this compliance obligation, based on filing frequency and regulatory requirements.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this scenario requirement record was last updated.',
    CONSTRAINT pk_scenario_requirement PRIMARY KEY(`scenario_requirement_id`)
) COMMENT 'This association product represents the contractual requirement linking stress scenarios to compliance obligations. It captures which stress scenarios must be executed to satisfy which regulatory or policy obligations, along with execution tracking and';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`calculation_run` (
    `calculation_run_id` BIGINT COMMENT 'Primary key for calculation_run',
    `approved_by_user_employee_id` BIGINT COMMENT 'Reference to the user who approved the calculation run results for official use or regulatory submission.',
    `calculation_model_id` BIGINT COMMENT 'Reference to the risk calculation model or methodology used for this run.',
    `market_data_snapshot_id` BIGINT COMMENT 'Reference to the market data and position data snapshot used as input for this calculation run.',
    `employee_id` BIGINT COMMENT 'Reference to the user or system account that initiated or triggered the calculation run.',
    `parent_run_id` BIGINT COMMENT 'Reference to the original calculation run if this is a rerun or child run in a hierarchical execution.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio or portfolio group subject to this calculation run.',
    `actual_end_timestamp` TIMESTAMP COMMENT 'Actual date and time when the calculation run execution completed or terminated.',
    `actual_start_timestamp` TIMESTAMP COMMENT 'Actual date and time when the calculation run execution began.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the calculation run results were formally approved.',
    `asset_class_scope` STRING COMMENT 'Asset classes included in the calculation run such as equities, fixed income, alternatives, or all asset classes.',
    `base_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code used as the base currency for all risk calculations and reporting.',
    `calculation_methodology` STRING COMMENT 'Specific methodology applied such as VaR, CVaR, Monte Carlo simulation, historical simulation, or parametric approach.',
    `confidence_level_percent` DECIMAL(5,2) COMMENT 'Statistical confidence level used for Value at Risk and other probabilistic risk measures, typically 95% or 99%.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the calculation run record was first created in the system.',
    `error_count` BIGINT COMMENT 'Number of errors or exceptions encountered during the calculation run execution.',
    `execution_duration_seconds` BIGINT COMMENT 'Total elapsed time in seconds for the calculation run from start to completion.',
    `failure_reason` STRING COMMENT 'Description of the primary reason for calculation run failure if the run did not complete successfully.',
    `is_official_run` BOOLEAN COMMENT 'Indicates whether this is the official production run for the valuation date versus a test or draft run.',
    `is_regulatory_submission` BOOLEAN COMMENT 'Indicates whether this calculation run is intended for regulatory reporting submission.',
    `is_rerun` BOOLEAN COMMENT 'Indicates whether this calculation run is a rerun of a previous execution due to corrections or updates.',
    `lookback_period_days` BIGINT COMMENT 'Historical observation window in days used for calculating risk metrics and volatility estimates.',
    `market_data_version` STRING COMMENT 'Version identifier of the market data set used for pricing and risk factor inputs.',
    `model_version` STRING COMMENT 'Version number of the risk calculation model or algorithm used in this run for audit and reproducibility.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when the calculation run record was last updated.',
    `output_file_path` STRING COMMENT 'File system or storage path where calculation run output files and reports are stored.',
    `position_count` BIGINT COMMENT 'Total number of investment positions included in the calculation run scope.',
    `regulatory_framework` STRING COMMENT 'Regulatory framework or standard governing the calculation methodology such as Basel III, Solvency II, or internal policy.',
    `reporting_period_end_date` DATE COMMENT 'End date of the reporting period covered by this calculation run.',
    `reporting_period_start_date` DATE COMMENT 'Start date of the reporting period covered by this calculation run.',
    `risk_category` STRING COMMENT 'Primary risk category being calculated such as market risk, credit risk, liquidity risk, or operational risk.',
    `run_code` STRING COMMENT 'Business-readable alphanumeric code uniquely identifying the calculation run for external reference and audit trails.',
    `run_description` STRING COMMENT 'Detailed description of the calculation run purpose, scope, and any special parameters or assumptions.',
    `run_name` STRING COMMENT 'Descriptive name assigned to the calculation run for identification in reports and dashboards.',
    `run_notes` STRING COMMENT 'Additional notes or comments recorded by analysts regarding the calculation run or its results.',
    `run_priority` STRING COMMENT 'Execution priority level determining resource allocation and processing order in the calculation queue.',
    `run_status` STRING COMMENT 'Current execution status of the calculation run within its processing lifecycle.',
    `run_type` STRING COMMENT 'Classification of the calculation run purpose such as scheduled production, ad-hoc analysis, regulatory submission, or stress testing.',
    `scenario_set_code` BIGINT COMMENT 'Reference to the set of stress scenarios or macroeconomic scenarios applied in this calculation run.',
    `scheduled_start_timestamp` TIMESTAMP COMMENT 'Planned start date and time for the calculation run execution.',
    `simulation_count` BIGINT COMMENT 'Number of Monte Carlo simulations or scenario iterations executed in this calculation run.',
    `time_horizon_days` BIGINT COMMENT 'Number of days for the risk calculation holding period, commonly 1-day, 10-day, or 252-day horizons.',
    `valuation_date` DATE COMMENT 'As-of date for which risk metrics are calculated, representing the portfolio snapshot date.',
    `warning_count` BIGINT COMMENT 'Number of warnings or data quality issues flagged during the calculation run execution.',
    CONSTRAINT pk_calculation_run PRIMARY KEY(`calculation_run_id`)
) COMMENT 'Master reference table for calculation_run. Referenced by calculation_run_id.';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`stress_test_run` (
    `stress_test_run_id` BIGINT COMMENT 'Primary key for stress_test_run',
    `actor_id` BIGINT COMMENT 'Reference to the risk analyst or portfolio manager who initiated this stress test run.',
    `approved_by_user_actor_id` BIGINT COMMENT 'Reference to the senior risk officer or committee member who approved the stress test run results.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio or portfolio group being stress tested in this run.',
    `stress_scenario_id` BIGINT COMMENT 'Reference to the macroeconomic or market scenario definition used for this stress test run.',
    `approval_status` STRING COMMENT 'Status of the stress test results approval workflow by risk governance.',
    `approval_timestamp` TIMESTAMP COMMENT 'Timestamp when the stress test run results were approved by the designated approver.',
    `base_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which all stress test results are denominated.',
    `breach_threshold_exceeded` BOOLEAN COMMENT 'Indicates whether the stress test results exceeded predefined risk tolerance thresholds.',
    `comments` STRING COMMENT 'Free-text comments or notes from risk analysts regarding the stress test run assumptions or results.',
    `commodity_shock_percent` DECIMAL(8,4) COMMENT 'Percentage shock applied to commodity prices in the stress scenario.',
    `confidence_level_percent` DECIMAL(5,2) COMMENT 'Statistical confidence level used for Value at Risk (VaR) and Conditional VaR calculations, typically 95.00 or 99.00 percent.',
    `counterparty_default_rate` DECIMAL(8,4) COMMENT 'Assumed default rate for counterparty credit risk assessment in the stress scenario.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this stress test run record was first created in the system.',
    `credit_spread_shock_bps` DECIMAL(8,2) COMMENT 'Basis point widening or tightening applied to credit spreads in the stress scenario.',
    `cvar_amount` DECIMAL(20,4) COMMENT 'Expected Shortfall or Conditional VaR representing the average loss beyond the VaR threshold.',
    `dv01_amount` DECIMAL(18,4) COMMENT 'Interest rate sensitivity measure showing portfolio value change for a one basis point shift in rates.',
    `equity_shock_percent` DECIMAL(8,4) COMMENT 'Percentage shock applied to equity positions in the stress scenario.',
    `escalation_required` BOOLEAN COMMENT 'Indicates whether the stress test results require escalation to senior management or risk committee.',
    `fx_shock_percent` DECIMAL(8,4) COMMENT 'Percentage shock applied to foreign exchange rates in the stress scenario.',
    `horizon_days` BIGINT COMMENT 'Number of days over which the stress scenario is applied, typically 1, 10, 30, 90, or 252 trading days.',
    `interest_rate_shock_bps` DECIMAL(8,2) COMMENT 'Basis point shift applied to interest rate curves in the stress scenario.',
    `liquidity_haircut_percent` DECIMAL(8,4) COMMENT 'Percentage haircut applied to illiquid assets to reflect potential liquidation costs under stress.',
    `methodology` STRING COMMENT 'Calculation methodology used: historical simulation, parametric, Monte Carlo, or hybrid approach.',
    `model_version` STRING COMMENT 'Version identifier of the risk model or calculation engine used for this stress test run.',
    `pnl_impact_amount` DECIMAL(20,4) COMMENT 'Estimated profit or loss impact from the stress scenario, calculated as stressed NAV minus base NAV.',
    `pnl_impact_percent` DECIMAL(8,4) COMMENT 'Percentage change in portfolio value resulting from the stress scenario relative to base NAV.',
    `portfolio_nav_base` DECIMAL(20,4) COMMENT 'Net Asset Value of the portfolio at the valuation date before applying stress scenario, in base currency.',
    `real_estate_shock_percent` DECIMAL(8,4) COMMENT 'Percentage shock applied to real estate and infrastructure valuations in the stress scenario.',
    `regulatory_framework` STRING COMMENT 'Applicable regulatory framework for this stress test, such as Basel III, Solvency II, or local pension regulations.',
    `regulatory_submission_required` BOOLEAN COMMENT 'Indicates whether this stress test run is part of a regulatory reporting requirement.',
    `run_code` STRING COMMENT 'Business-readable unique code assigned to each stress test run for external reference and audit trail purposes.',
    `run_end_timestamp` TIMESTAMP COMMENT 'Timestamp when the stress test run execution completed or terminated.',
    `run_name` STRING COMMENT 'Descriptive name for the stress test run, typically indicating the scenario type and date for easy identification.',
    `run_start_timestamp` TIMESTAMP COMMENT 'Timestamp when the stress test run execution began processing.',
    `run_status` STRING COMMENT 'Current lifecycle status of the stress test run execution workflow.',
    `run_type` STRING COMMENT 'Classification of the stress test run by purpose: regulatory (mandated), internal (routine), ad_hoc, sensitivity, reverse, or custom.',
    `simulation_count` BIGINT COMMENT 'Number of Monte Carlo simulations or historical scenarios used in the stress test calculations.',
    `stressed_nav` DECIMAL(20,4) COMMENT 'Projected Net Asset Value of the portfolio after applying the stress scenario, in base currency.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this stress test run record was last modified.',
    `valuation_date` DATE COMMENT 'As-of date for portfolio positions and market data used in the stress test calculations.',
    `var_amount` DECIMAL(20,4) COMMENT 'Value at Risk measure representing the maximum expected loss at the specified confidence level and horizon.',
    CONSTRAINT pk_stress_test_run PRIMARY KEY(`stress_test_run_id`)
) COMMENT 'Master reference table for stress_test_run. Referenced by stress_test_run_id.';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`validation_run` (
    `validation_run_id` BIGINT COMMENT 'Primary key for validation_run',
    `actor_id` BIGINT COMMENT 'Reference to the user who initiated or triggered the validation run.',
    `approved_by_user_actor_id` BIGINT COMMENT 'Reference to the user who approved the validation run results for regulatory or internal use.',
    `performance_benchmark_id` BIGINT COMMENT 'Reference to the benchmark used for comparative validation analysis.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio scope for this validation run.',
    `regulatory_filing_id` BIGINT COMMENT 'Reference to the regulatory report this validation run supports if applicable.',
    `risk_model_id` BIGINT COMMENT 'Reference to the risk model being validated in this run.',
    `actual_end_timestamp` TIMESTAMP COMMENT 'Actual date and time when the validation run execution completed or terminated.',
    `actual_start_timestamp` TIMESTAMP COMMENT 'Actual date and time when the validation run execution commenced.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the validation run results were formally approved.',
    `as_of_date` DATE COMMENT 'Reference date for portfolio positions and market data snapshot used in the validation run.',
    `asset_class_scope` STRING COMMENT 'Asset classes included in the validation scope such as equities, fixed income, alternatives, or multi-asset.',
    `christoffersen_p_value` DECIMAL(10,6) COMMENT 'Statistical p-value from the Christoffersen independence test for exception clustering analysis.',
    `christoffersen_test_result` STRING COMMENT 'Outcome of the Christoffersen conditional coverage test assessing exception clustering.',
    `confidence_level_percent` DECIMAL(5,2) COMMENT 'Statistical confidence level used in the validation calculations, typically 95% or 99% for VaR models.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the validation run record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the base currency used in validation calculations.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Quantitative assessment of input data quality used in the validation run, expressed as a percentage.',
    `error_message` STRING COMMENT 'Descriptive error message captured if the validation run failed or encountered issues during execution.',
    `exception_threshold` BIGINT COMMENT 'Maximum allowable number of exceptions before the model is flagged for review under regulatory guidelines.',
    `execution_duration_seconds` BIGINT COMMENT 'Total elapsed time in seconds for the validation run from start to completion.',
    `kupiec_pof_p_value` DECIMAL(10,6) COMMENT 'Statistical p-value from the Kupiec proportion of failures test for model validation.',
    `kupiec_pof_test_result` STRING COMMENT 'Outcome of the Kupiec unconditional coverage test for backtesting VaR model accuracy.',
    `lookback_period_days` BIGINT COMMENT 'Historical observation window in days used for backtesting and model calibration during validation.',
    `missing_data_percentage` DECIMAL(5,2) COMMENT 'Percentage of required data points that were missing or imputed during the validation run.',
    `model_multiplier` DECIMAL(5,2) COMMENT 'Regulatory capital multiplier applied based on backtesting results, ranging from 3.0 to 4.0 under Basel guidelines.',
    `notes` STRING COMMENT 'Free-text notes or comments added by analysts regarding the validation run context or findings.',
    `observation_end_date` DATE COMMENT 'Ending date of the historical data window used in the validation analysis.',
    `observation_start_date` DATE COMMENT 'Beginning date of the historical data window used in the validation analysis.',
    `overall_validation_result` STRING COMMENT 'Aggregate outcome of all validation tests determining model fitness for continued use.',
    `regulatory_submission_flag` BOOLEAN COMMENT 'Indicates whether this validation run is intended for regulatory reporting submission.',
    `run_code` STRING COMMENT 'Business-readable alphanumeric code uniquely identifying the validation run for external reference and audit trails.',
    `run_name` STRING COMMENT 'Descriptive name assigned to the validation run for identification in reports and dashboards.',
    `run_type` STRING COMMENT 'Classification of the validation run purpose such as scheduled periodic runs, ad-hoc analysis, or regulatory submissions.',
    `scenario_set_code` BIGINT COMMENT 'Reference to the stress scenario set applied during validation if applicable.',
    `scheduled_start_timestamp` TIMESTAMP COMMENT 'Planned date and time when the validation run was scheduled to begin execution.',
    `validation_run_status` STRING COMMENT 'Current lifecycle state of the validation run execution process.',
    `time_horizon_days` BIGINT COMMENT 'Number of days representing the forward-looking time horizon for risk calculations in this validation run.',
    `total_exceptions_count` BIGINT COMMENT 'Number of backtesting exceptions or breaches identified during the validation run.',
    `total_market_value_base` DECIMAL(20,4) COMMENT 'Aggregate market value of positions validated expressed in the base currency.',
    `total_positions_validated` BIGINT COMMENT 'Count of individual portfolio positions included in the validation run scope.',
    `traffic_light_zone` STRING COMMENT 'Basel traffic light classification indicating model performance based on exception count relative to thresholds.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when the validation run record was last modified.',
    `validation_methodology` STRING COMMENT 'The statistical or analytical methodology applied during validation such as historical simulation, Monte Carlo, or parametric approaches.',
    CONSTRAINT pk_validation_run PRIMARY KEY(`validation_run_id`)
) COMMENT 'Master reference table for validation_run. Referenced by validation_run_id.';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`factor_ic_observation` (
    `factor_ic_observation_id` BIGINT COMMENT 'Unique identifier for the factor ic observation record (factor ic observation id).',
    `factor_id` BIGINT COMMENT 'Foreign key reference to the factor identifier associated with this factor IC observation.',
    `holding_period_days` BIGINT COMMENT 'Number of days in the holding period over which the factor information coefficient observation is measured.',
    `information_coefficient` DECIMAL(9,6) COMMENT 'Information coefficient measuring the correlation between the factor signal and subsequent realized returns for this observation.',
    `period_end_date` DATE COMMENT 'End date of the observation period for the factor information coefficient.',
    `sector_name` STRING COMMENT 'The sector name of the factor ic observation.',
    `universe_size` BIGINT COMMENT 'The universe size of the factor ic observation.',
    CONSTRAINT pk_factor_ic_observation PRIMARY KEY(`factor_ic_observation_id`)
) COMMENT 'Information coefficient of a factor signal, computed by the quant research team; one row per factor, period, holding period and sector.';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`factor_signal_prediction` (
    `factor_signal_prediction_id` BIGINT COMMENT 'Primary key identifier for the factor signal prediction record.',
    `factor_id` BIGINT COMMENT 'Reference to risk.factor.factor_id.',
    `listed_security_id` BIGINT COMMENT 'Reference to equity.listed_security.listed_security_id.',
    `portfolio_id` BIGINT COMMENT 'Reference to portfolio.portfolio.portfolio_id.',
    `direction_correct_flag` BOOLEAN COMMENT 'Indicator for direction correct flag on the factor signal prediction.',
    `holding_period_days` BIGINT COMMENT 'The holding period days of the factor signal prediction.',
    `predicted_direction` STRING COMMENT 'The predicted direction of the factor signal prediction.',
    `prediction_date` DATE COMMENT 'Prediction date of the factor signal prediction.',
    `realized_return_percent` DECIMAL(18,8) COMMENT 'The realized return percent of the factor signal prediction.',
    `signal_value` DECIMAL(18,8) COMMENT 'The signal value of the factor signal prediction.',
    CONSTRAINT pk_factor_signal_prediction PRIMARY KEY(`factor_signal_prediction_id`)
) COMMENT 'One directional prediction of a factor signal for one security.';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`strategy_backtest_result` (
    `strategy_backtest_result_id` BIGINT COMMENT 'Surrogate primary key.',
    `factor_id` BIGINT COMMENT 'FK to risk.factor, the signal the strategy trades.',
    `period_end_date` DATE COMMENT 'Period end date.',
    `sample_type` STRING COMMENT 'Sample type: in_sample, out_of_sample.',
    `simulated_drawdown_percent` DECIMAL(18,8) COMMENT 'Simulated drawdown percent, stored as a negative number.',
    `simulated_pnl_amount` DECIMAL(20,2) COMMENT 'Simulated PnL amount.',
    `simulated_return_percent` DECIMAL(18,8) COMMENT 'Simulated return percent.',
    `strategy_name` STRING COMMENT 'Name of the candidate strategy.',
    `vintage_date` DATE COMMENT 'Backtest start or signal activation date.',
    CONSTRAINT pk_strategy_backtest_result PRIMARY KEY(`strategy_backtest_result_id`)
) COMMENT 'Simulated performance of a candidate strategy, one row per strategy, vintage and period.';

CREATE OR REPLACE TABLE `asset_management`.`risk`.`factor_ic_correlation` (
    `factor_ic_correlation_id` BIGINT COMMENT 'Surrogate primary key.',
    `factor_id` BIGINT COMMENT 'FK to risk.factor.',
    `paired_factor_id` BIGINT COMMENT 'FK to risk.factor, the second factor of the pair.',
    `correlation_value` DECIMAL(9,6) COMMENT 'Correlation value between -1 and 1.',
    `lookback_period_days` BIGINT COMMENT 'Lookback period in days.',
    `period_end_date` DATE COMMENT 'Period end date.',
    CONSTRAINT pk_factor_ic_correlation PRIMARY KEY(`factor_ic_correlation_id`)
) COMMENT 'Pairwise correlation of two factors information coefficients, one row per factor pair and period.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`risk`.`strategy_backtest_result` ADD CONSTRAINT `fk_risk_strategy_backtest_result_factor_id` FOREIGN KEY (`factor_id`) REFERENCES `asset_management`.`risk`.`factor`(`factor_id`);
ALTER TABLE `asset_management`.`risk`.`factor_ic_correlation` ADD CONSTRAINT `fk_risk_factor_ic_correlation_factor_id` FOREIGN KEY (`factor_id`) REFERENCES `asset_management`.`risk`.`factor`(`factor_id`);
ALTER TABLE `asset_management`.`risk`.`factor_ic_correlation` ADD CONSTRAINT `fk_risk_factor_ic_correlation_paired_factor_id` FOREIGN KEY (`paired_factor_id`) REFERENCES `asset_management`.`risk`.`factor`(`factor_id`);
ALTER TABLE `asset_management`.`risk`.`factor` ADD CONSTRAINT `fk_risk_factor_risk_model_id` FOREIGN KEY (`risk_model_id`) REFERENCES `asset_management`.`risk`.`model`(`model_id`);
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ADD CONSTRAINT `fk_risk_stress_scenario_superseded_by_scenario_stress_scenario_id` FOREIGN KEY (`superseded_by_scenario_stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`risk`.`var_calculation` ADD CONSTRAINT `fk_risk_var_calculation_calculation_run_id` FOREIGN KEY (`calculation_run_id`) REFERENCES `asset_management`.`risk`.`calculation_run`(`calculation_run_id`);
ALTER TABLE `asset_management`.`risk`.`var_calculation` ADD CONSTRAINT `fk_risk_var_calculation_risk_model_id` FOREIGN KEY (`risk_model_id`) REFERENCES `asset_management`.`risk`.`model`(`model_id`);
ALTER TABLE `asset_management`.`risk`.`var_calculation` ADD CONSTRAINT `fk_risk_var_calculation_stress_scenario_id` FOREIGN KEY (`stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ADD CONSTRAINT `fk_risk_risk_factor_exposure_risk_factor_id` FOREIGN KEY (`risk_factor_id`) REFERENCES `asset_management`.`risk`.`factor`(`factor_id`);
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ADD CONSTRAINT `fk_risk_risk_factor_exposure_risk_model_id` FOREIGN KEY (`risk_model_id`) REFERENCES `asset_management`.`risk`.`model`(`model_id`);
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ADD CONSTRAINT `fk_risk_risk_factor_exposure_stress_scenario_id` FOREIGN KEY (`stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ADD CONSTRAINT `fk_risk_stress_test_result_stress_scenario_id` FOREIGN KEY (`stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ADD CONSTRAINT `fk_risk_stress_test_result_stress_test_run_id` FOREIGN KEY (`stress_test_run_id`) REFERENCES `asset_management`.`risk`.`stress_test_run`(`stress_test_run_id`);
ALTER TABLE `asset_management`.`risk`.`limit_breach` ADD CONSTRAINT `fk_risk_limit_breach_limit_id` FOREIGN KEY (`limit_id`) REFERENCES `asset_management`.`risk`.`limit`(`limit_id`);
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ADD CONSTRAINT `fk_risk_risk_counterparty_exposure_stress_scenario_id` FOREIGN KEY (`stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ADD CONSTRAINT `fk_risk_concentration_exposure_credit_rating_id` FOREIGN KEY (`credit_rating_id`) REFERENCES `asset_management`.`risk`.`credit_rating`(`credit_rating_id`);
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ADD CONSTRAINT `fk_risk_concentration_exposure_limit_id` FOREIGN KEY (`limit_id`) REFERENCES `asset_management`.`risk`.`limit`(`limit_id`);
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ADD CONSTRAINT `fk_risk_concentration_exposure_stress_scenario_id` FOREIGN KEY (`stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ADD CONSTRAINT `fk_risk_dv01_sensitivity_stress_scenario_id` FOREIGN KEY (`stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ADD CONSTRAINT `fk_risk_liquidity_risk_assessment_limit_id` FOREIGN KEY (`limit_id`) REFERENCES `asset_management`.`risk`.`limit`(`limit_id`);
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ADD CONSTRAINT `fk_risk_liquidity_risk_assessment_stress_scenario_id` FOREIGN KEY (`stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ADD CONSTRAINT `fk_risk_fx_risk_exposure_limit_id` FOREIGN KEY (`limit_id`) REFERENCES `asset_management`.`risk`.`limit`(`limit_id`);
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ADD CONSTRAINT `fk_risk_fx_risk_exposure_stress_scenario_id` FOREIGN KEY (`stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`risk`.`attribution` ADD CONSTRAINT `fk_risk_attribution_risk_model_id` FOREIGN KEY (`risk_model_id`) REFERENCES `asset_management`.`risk`.`model`(`model_id`);
ALTER TABLE `asset_management`.`risk`.`attribution` ADD CONSTRAINT `fk_risk_attribution_stress_scenario_id` FOREIGN KEY (`stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ADD CONSTRAINT `fk_risk_sensitivity_analysis_risk_factor_id` FOREIGN KEY (`risk_factor_id`) REFERENCES `asset_management`.`risk`.`factor`(`factor_id`);
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ADD CONSTRAINT `fk_risk_sensitivity_analysis_stress_scenario_id` FOREIGN KEY (`stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ADD CONSTRAINT `fk_risk_limit_assignment_limit_id` FOREIGN KEY (`limit_id`) REFERENCES `asset_management`.`risk`.`limit`(`limit_id`);
ALTER TABLE `asset_management`.`risk`.`factor_return` ADD CONSTRAINT `fk_risk_factor_return_factor_id` FOREIGN KEY (`factor_id`) REFERENCES `asset_management`.`risk`.`factor`(`factor_id`);
ALTER TABLE `asset_management`.`risk`.`factor_return` ADD CONSTRAINT `fk_risk_factor_return_risk_model_id` FOREIGN KEY (`risk_model_id`) REFERENCES `asset_management`.`risk`.`model`(`model_id`);
ALTER TABLE `asset_management`.`risk`.`risk_exception` ADD CONSTRAINT `fk_risk_risk_exception_limit_id` FOREIGN KEY (`limit_id`) REFERENCES `asset_management`.`risk`.`limit`(`limit_id`);
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ADD CONSTRAINT `fk_risk_correlation_matrix_risk_model_id` FOREIGN KEY (`risk_model_id`) REFERENCES `asset_management`.`risk`.`model`(`model_id`);
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ADD CONSTRAINT `fk_risk_correlation_matrix_superseded_by_matrix_correlation_matrix_id` FOREIGN KEY (`superseded_by_matrix_correlation_matrix_id`) REFERENCES `asset_management`.`risk`.`correlation_matrix`(`correlation_matrix_id`);
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ADD CONSTRAINT `fk_risk_appetite_statement_superseded_by_statement_appetite_statement_id` FOREIGN KEY (`superseded_by_statement_appetite_statement_id`) REFERENCES `asset_management`.`risk`.`appetite_statement`(`appetite_statement_id`);
ALTER TABLE `asset_management`.`risk`.`model_validation` ADD CONSTRAINT `fk_risk_model_validation_model_id` FOREIGN KEY (`model_id`) REFERENCES `asset_management`.`risk`.`model`(`model_id`);
ALTER TABLE `asset_management`.`risk`.`model_validation` ADD CONSTRAINT `fk_risk_model_validation_validation_run_id` FOREIGN KEY (`validation_run_id`) REFERENCES `asset_management`.`risk`.`validation_run`(`validation_run_id`);
ALTER TABLE `asset_management`.`risk`.`scenario_requirement` ADD CONSTRAINT `fk_risk_scenario_requirement_stress_scenario_id` FOREIGN KEY (`stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`risk`.`calculation_run` ADD CONSTRAINT `fk_risk_calculation_run_calculation_model_id` FOREIGN KEY (`calculation_model_id`) REFERENCES `asset_management`.`risk`.`model`(`model_id`);
ALTER TABLE `asset_management`.`risk`.`calculation_run` ADD CONSTRAINT `fk_risk_calculation_run_parent_run_id` FOREIGN KEY (`parent_run_id`) REFERENCES `asset_management`.`risk`.`calculation_run`(`calculation_run_id`);
ALTER TABLE `asset_management`.`risk`.`stress_test_run` ADD CONSTRAINT `fk_risk_stress_test_run_stress_scenario_id` FOREIGN KEY (`stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`risk`.`validation_run` ADD CONSTRAINT `fk_risk_validation_run_risk_model_id` FOREIGN KEY (`risk_model_id`) REFERENCES `asset_management`.`risk`.`model`(`model_id`);
ALTER TABLE `asset_management`.`risk`.`factor_ic_observation` ADD CONSTRAINT `fk_risk_factor_ic_observation_factor_id` FOREIGN KEY (`factor_id`) REFERENCES `asset_management`.`risk`.`factor`(`factor_id`);
ALTER TABLE `asset_management`.`risk`.`factor_signal_prediction` ADD CONSTRAINT `fk_risk_factor_signal_prediction_factor_id` FOREIGN KEY (`factor_id`) REFERENCES `asset_management`.`risk`.`factor`(`factor_id`);

-- ========= TAGS =========
ALTER SCHEMA `asset_management`.`risk` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `asset_management`.`risk` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`strategy_backtest_result` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`strategy_backtest_result` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`strategy_backtest_result` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`strategy_backtest_result` SET TAGS ('dbx_subdomain' = 'stress_testing');
ALTER TABLE `asset_management`.`risk`.`factor_ic_correlation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`factor_ic_correlation` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`factor_ic_correlation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`factor_ic_correlation` SET TAGS ('dbx_subdomain' = 'exposure_analytics');
ALTER TABLE `asset_management`.`risk`.`limit` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`risk`.`limit` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`limit` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`limit` SET TAGS ('dbx_subdomain' = 'limit_governance');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `limit_id` SET TAGS ('dbx_business_glossary_term' = 'Limit Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `rule_id` SET TAGS ('dbx_business_glossary_term' = 'Rule Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Strategy Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `breach_count_ytd` SET TAGS ('dbx_business_glossary_term' = 'Breach Count Year-to-Date (YTD)');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `breach_tolerance_lower` SET TAGS ('dbx_business_glossary_term' = 'Breach Tolerance Lower Bound');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `breach_tolerance_upper` SET TAGS ('dbx_business_glossary_term' = 'Breach Tolerance Upper Bound');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Calculation Methodology');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `limit_code` SET TAGS ('dbx_business_glossary_term' = 'Limit Code');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `limit_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{4,20}$');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Limit Currency');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `escalation_level` SET TAGS ('dbx_business_glossary_term' = 'Escalation Level');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `escalation_level` SET TAGS ('dbx_value_regex' = 'portfolio_manager|cio|cro|ic|board');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `escalation_procedure` SET TAGS ('dbx_business_glossary_term' = 'Escalation Procedure');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `last_breach_date` SET TAGS ('dbx_business_glossary_term' = 'Last Breach Date');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `limit_status` SET TAGS ('dbx_business_glossary_term' = 'Limit Status');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `limit_status` SET TAGS ('dbx_value_regex' = 'active|suspended|expired|pending_approval|retired');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `limit_type` SET TAGS ('dbx_business_glossary_term' = 'Limit Type');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `limit_type` SET TAGS ('dbx_value_regex' = 'VaR|CVaR|DV01|concentration|leverage|liquidity');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Frequency');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_value_regex' = 'real_time|daily|weekly|monthly|quarterly');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `limit_name` SET TAGS ('dbx_business_glossary_term' = 'Limit Name');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Limit Notes');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `rationale` SET TAGS ('dbx_business_glossary_term' = 'Limit Rationale');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `regulatory_requirement_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Flag');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `risk_system_source` SET TAGS ('dbx_business_glossary_term' = 'Risk System Source');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `risk_system_source` SET TAGS ('dbx_value_regex' = 'aladdin|msci_barra|simcorp|internal');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Sector');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `time_horizon_days` SET TAGS ('dbx_business_glossary_term' = 'Time Horizon in Days');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `unit` SET TAGS ('dbx_business_glossary_term' = 'Limit Unit of Measure');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `unit` SET TAGS ('dbx_value_regex' = 'currency|percentage|bps|notional|shares');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `utilization_percentage` SET TAGS ('dbx_business_glossary_term' = 'Utilization Percentage');
ALTER TABLE `asset_management`.`risk`.`limit` ALTER COLUMN `value` SET TAGS ('dbx_business_glossary_term' = 'Limit Value');
ALTER TABLE `asset_management`.`risk`.`factor` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`risk`.`factor` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`factor` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`factor` SET TAGS ('dbx_subdomain' = 'exposure_analytics');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `factor_id` SET TAGS ('dbx_business_glossary_term' = 'Factor Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `macro_indicator_id` SET TAGS ('dbx_business_glossary_term' = 'Macro Indicator Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `risk_model_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Model Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `annualized_volatility_pct` SET TAGS ('dbx_business_glossary_term' = 'Annualized Volatility Percentage (Pct)');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'approved|pending|rejected|under_review');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `benchmark_index_code` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index Code');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `beta_to_market` SET TAGS ('dbx_business_glossary_term' = 'Beta to Market');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Calculation Methodology');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `factor_category` SET TAGS ('dbx_business_glossary_term' = 'Factor Category');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `factor_category` SET TAGS ('dbx_value_regex' = 'equity_style|fixed_income|macro|alternative|currency|commodity');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `factor_code` SET TAGS ('dbx_business_glossary_term' = 'Factor Code');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `factor_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{3,20}$');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `correlation_to_market` SET TAGS ('dbx_business_glossary_term' = 'Correlation to Market');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `factor_description` SET TAGS ('dbx_business_glossary_term' = 'Factor Description');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `effective_to_date` SET TAGS ('dbx_business_glossary_term' = 'Effective To Date');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `factor_status` SET TAGS ('dbx_business_glossary_term' = 'Factor Status');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `factor_status` SET TAGS ('dbx_value_regex' = 'active|deprecated|under_review|pending_approval');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `factor_type` SET TAGS ('dbx_business_glossary_term' = 'Factor Type');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `factor_type` SET TAGS ('dbx_value_regex' = 'style|statistical|macroeconomic|fundamental|technical');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `family` SET TAGS ('dbx_business_glossary_term' = 'Factor Family');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `information_ratio` SET TAGS ('dbx_business_glossary_term' = 'Information Ratio (IR)');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active Factor');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `is_proprietary` SET TAGS ('dbx_business_glossary_term' = 'Is Proprietary Factor');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `last_rebalance_date` SET TAGS ('dbx_business_glossary_term' = 'Last Rebalance Date');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `loading_interpretation` SET TAGS ('dbx_business_glossary_term' = 'Factor Loading Interpretation');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `max_drawdown_pct` SET TAGS ('dbx_business_glossary_term' = 'Maximum Drawdown Percentage (Pct)');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `factor_name` SET TAGS ('dbx_business_glossary_term' = 'Factor Name');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `next_rebalance_date` SET TAGS ('dbx_business_glossary_term' = 'Next Rebalance Date');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `rebalance_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rebalance Frequency');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `rebalance_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annual|ad_hoc');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `return_history_end_date` SET TAGS ('dbx_business_glossary_term' = 'Factor Return History End Date');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `return_history_start_date` SET TAGS ('dbx_business_glossary_term' = 'Factor Return History Start Date');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|ad_hoc');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `sharpe_ratio` SET TAGS ('dbx_business_glossary_term' = 'Sharpe Ratio');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `unit` SET TAGS ('dbx_business_glossary_term' = 'Factor Unit of Measure');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `usage_in_stress_testing` SET TAGS ('dbx_business_glossary_term' = 'Usage in Stress Testing');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `usage_in_var_calculation` SET TAGS ('dbx_business_glossary_term' = 'Usage in Value at Risk (VaR) Calculation');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `vendor_model_name` SET TAGS ('dbx_business_glossary_term' = 'Vendor Model Name');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `vendor_model_version` SET TAGS ('dbx_business_glossary_term' = 'Vendor Model Version');
ALTER TABLE `asset_management`.`risk`.`factor` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`risk`.`model` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`risk`.`model` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`model` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`model` SET TAGS ('dbx_subdomain' = 'limit_governance');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Model Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `backtesting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Backtesting Frequency');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `backtesting_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annually|none');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `benchmark_index` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Calculation Frequency');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|on_demand');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `model_code` SET TAGS ('dbx_business_glossary_term' = 'Model Code');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `model_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,20}$');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `documentation_url` SET TAGS ('dbx_business_glossary_term' = 'Model Documentation Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `effective_to_date` SET TAGS ('dbx_business_glossary_term' = 'Effective To Date');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `factor_model_flag` SET TAGS ('dbx_business_glossary_term' = 'Factor Model Flag');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `holding_period_days` SET TAGS ('dbx_business_glossary_term' = 'Holding Period Days');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `last_backtest_date` SET TAGS ('dbx_business_glossary_term' = 'Last Backtest Date');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `last_calibration_date` SET TAGS ('dbx_business_glossary_term' = 'Last Calibration Date');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `limitations` SET TAGS ('dbx_business_glossary_term' = 'Model Limitations');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `lookback_window_days` SET TAGS ('dbx_business_glossary_term' = 'Lookback Window Days');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `methodology_description` SET TAGS ('dbx_business_glossary_term' = 'Methodology Description');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `model_status` SET TAGS ('dbx_business_glossary_term' = 'Model Status');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `model_status` SET TAGS ('dbx_value_regex' = 'active|inactive|under_review|deprecated|pending_approval|retired');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `model_type` SET TAGS ('dbx_business_glossary_term' = 'Model Type');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `model_type` SET TAGS ('dbx_value_regex' = 'historical_simulation|monte_carlo|parametric|factor_based|stress_test|scenario_analysis');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `model_name` SET TAGS ('dbx_business_glossary_term' = 'Model Name');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Model Notes');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `owner` SET TAGS ('dbx_business_glossary_term' = 'Model Owner');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `regulatory_approved_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approved Flag');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `regulatory_framework` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Framework');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `risk_measure` SET TAGS ('dbx_business_glossary_term' = 'Risk Measure');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `risk_measure` SET TAGS ('dbx_value_regex' = 'var|cvar|dv01|duration|beta|tracking_error');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `simulation_count` SET TAGS ('dbx_business_glossary_term' = 'Simulation Count');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `stress_test_flag` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Flag');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `vendor` SET TAGS ('dbx_business_glossary_term' = 'Model Vendor');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `asset_management`.`risk`.`model` ALTER COLUMN `version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+(.[0-9]+)?$');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` SET TAGS ('dbx_subdomain' = 'stress_testing');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Stress Scenario Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `climate_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `superseded_by_scenario_stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Scenario Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `asset_class_scope` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Scope');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `commodity_shock_percent` SET TAGS ('dbx_business_glossary_term' = 'Commodity Shock Percentage');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `counterparty_default_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Default Rate Percentage');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `credit_spread_shock_bps` SET TAGS ('dbx_business_glossary_term' = 'Credit Spread Shock (Basis Points)');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `cvar_confidence_level_percent` SET TAGS ('dbx_business_glossary_term' = 'Conditional Value at Risk (CVaR) Confidence Level Percentage');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `equity_shock_percent` SET TAGS ('dbx_business_glossary_term' = 'Equity Shock Percentage');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `external_scenario_code` SET TAGS ('dbx_business_glossary_term' = 'External Scenario Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `fx_shock_percent` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Shock Percentage');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `gdp_shock_percent` SET TAGS ('dbx_business_glossary_term' = 'Gross Domestic Product (GDP) Shock Percentage');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `historical_event_date` SET TAGS ('dbx_business_glossary_term' = 'Historical Event Date');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `indicator_weight` SET TAGS ('dbx_business_glossary_term' = 'Indicator Weight');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `inflation_shock_percent` SET TAGS ('dbx_business_glossary_term' = 'Inflation Shock Percentage');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `interest_rate_shock_bps` SET TAGS ('dbx_business_glossary_term' = 'Interest Rate Shock (Basis Points)');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `is_baseline` SET TAGS ('dbx_business_glossary_term' = 'Is Baseline Scenario');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `is_regulatory_required` SET TAGS ('dbx_business_glossary_term' = 'Is Regulatory Required');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `liquidity_shock_description` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Shock Description');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Modified By');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `probability_assessment` SET TAGS ('dbx_business_glossary_term' = 'Probability Assessment');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `probability_assessment` SET TAGS ('dbx_value_regex' = 'very_low|low|medium|high|very_high|not_assessed');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `real_estate_shock_percent` SET TAGS ('dbx_business_glossary_term' = 'Real Estate Shock Percentage');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `recovery_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Recovery Rate Percentage');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `regulatory_source` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Source');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `scenario_category` SET TAGS ('dbx_business_glossary_term' = 'Scenario Category');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `scenario_code` SET TAGS ('dbx_business_glossary_term' = 'Scenario Code');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `scenario_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,20}$');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `scenario_name` SET TAGS ('dbx_business_glossary_term' = 'Scenario Name');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `scenario_narrative` SET TAGS ('dbx_business_glossary_term' = 'Scenario Narrative');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `scenario_status` SET TAGS ('dbx_business_glossary_term' = 'Scenario Status');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `scenario_status` SET TAGS ('dbx_value_regex' = 'draft|active|archived|deprecated|under_review');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `scenario_type` SET TAGS ('dbx_business_glossary_term' = 'Scenario Type');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `scenario_type` SET TAGS ('dbx_value_regex' = 'historical|hypothetical|regulatory|custom|reverse_stress');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `severity_level` SET TAGS ('dbx_business_glossary_term' = 'Severity Level');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `severity_level` SET TAGS ('dbx_value_regex' = 'mild|moderate|severe|extreme');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `shock_direction` SET TAGS ('dbx_business_glossary_term' = 'Shock Direction');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `shock_magnitude` SET TAGS ('dbx_business_glossary_term' = 'Shock Magnitude');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `shock_magnitude_description` SET TAGS ('dbx_business_glossary_term' = 'Shock Magnitude Description');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `time_horizon_months` SET TAGS ('dbx_business_glossary_term' = 'Time Horizon (Months)');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `unemployment_shock_percent` SET TAGS ('dbx_business_glossary_term' = 'Unemployment Shock Percentage');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `usage_count` SET TAGS ('dbx_business_glossary_term' = 'Usage Count');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `var_confidence_level_percent` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Confidence Level Percentage');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `volatility_shock_percent` SET TAGS ('dbx_business_glossary_term' = 'Volatility Shock Percentage');
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`risk`.`var_calculation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`var_calculation` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`var_calculation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`var_calculation` SET TAGS ('dbx_subdomain' = 'exposure_analytics');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `var_calculation_id` SET TAGS ('dbx_business_glossary_term' = 'Value-at-Risk (VaR) Calculation Identifier');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `calculation_run_id` SET TAGS ('dbx_business_glossary_term' = 'Calculation Run Identifier');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `risk_model_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Model Identifier');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Scenario Identifier');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `asset_class_scope` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Scope');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `backtesting_exceptions` SET TAGS ('dbx_business_glossary_term' = 'Backtesting Exceptions Count');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `backtesting_period_end` SET TAGS ('dbx_business_glossary_term' = 'Backtesting Period End Date');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `backtesting_period_start` SET TAGS ('dbx_business_glossary_term' = 'Backtesting Period Start Date');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Calculation Date');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `calculation_duration_seconds` SET TAGS ('dbx_business_glossary_term' = 'Calculation Duration in Seconds');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `calculation_engine` SET TAGS ('dbx_business_glossary_term' = 'Calculation Engine');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `calculation_notes` SET TAGS ('dbx_business_glossary_term' = 'Calculation Notes');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `calculation_status` SET TAGS ('dbx_business_glossary_term' = 'Calculation Status');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `calculation_status` SET TAGS ('dbx_value_regex' = 'completed|failed|in_progress|pending|cancelled');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation Timestamp');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `correlation_matrix_version` SET TAGS ('dbx_business_glossary_term' = 'Correlation Matrix Version');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `cvar_amount` SET TAGS ('dbx_business_glossary_term' = 'Conditional Value-at-Risk (CVaR) Amount');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `cvar_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `decomposition_available` SET TAGS ('dbx_business_glossary_term' = 'Decomposition Available Flag');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `diversification_benefit` SET TAGS ('dbx_business_glossary_term' = 'Diversification Benefit Amount');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `historical_lookback_days` SET TAGS ('dbx_business_glossary_term' = 'Historical Lookback Period in Days');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `holding_period_days` SET TAGS ('dbx_business_glossary_term' = 'Holding Period in Days');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `incremental_risk_charge` SET TAGS ('dbx_business_glossary_term' = 'Incremental Risk Charge (IRC)');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `incremental_risk_charge` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `liquidity_horizon_days` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Horizon in Days');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `market_data_source` SET TAGS ('dbx_business_glossary_term' = 'Market Data Source');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `methodology` SET TAGS ('dbx_business_glossary_term' = 'VaR Methodology');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `methodology` SET TAGS ('dbx_value_regex' = 'historical_simulation|monte_carlo|parametric|hybrid');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `portfolio_value` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Value');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `portfolio_value` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `position_count` SET TAGS ('dbx_business_glossary_term' = 'Position Count');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `regulatory_capital_multiplier` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Capital Multiplier');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `risk_factor_count` SET TAGS ('dbx_business_glossary_term' = 'Risk Factor Count');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `simulation_iterations` SET TAGS ('dbx_business_glossary_term' = 'Monte Carlo Simulation Iterations');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `stress_var_amount` SET TAGS ('dbx_business_glossary_term' = 'Stressed Value-at-Risk (SVaR) Amount');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `stress_var_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `var_amount` SET TAGS ('dbx_business_glossary_term' = 'Value-at-Risk (VaR) Amount');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `var_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `var_currency` SET TAGS ('dbx_business_glossary_term' = 'VaR Currency Code');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `var_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `var_percentage` SET TAGS ('dbx_business_glossary_term' = 'VaR as Percentage of Portfolio');
ALTER TABLE `asset_management`.`risk`.`var_calculation` ALTER COLUMN `volatility_adjustment_factor` SET TAGS ('dbx_business_glossary_term' = 'Volatility Adjustment Factor');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` SET TAGS ('dbx_subdomain' = 'exposure_analytics');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `risk_factor_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Factor Exposure ID');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security ID');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `risk_factor_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Factor ID');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `risk_model_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Model ID');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Stress Scenario ID');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `active_exposure` SET TAGS ('dbx_business_glossary_term' = 'Active Exposure');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'approved|pending|rejected|override');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `as_of_date` SET TAGS ('dbx_business_glossary_term' = 'As-Of Date');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `benchmark_exposure` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Exposure');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Calculation Method');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `calculation_method` SET TAGS ('dbx_value_regex' = 'regression|covariance|monte_carlo|historical');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation Timestamp');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `contribution_to_risk_percentage` SET TAGS ('dbx_business_glossary_term' = 'Contribution to Risk Percentage');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `cvar_contribution` SET TAGS ('dbx_business_glossary_term' = 'Conditional Value at Risk (CVaR) Contribution');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `exposure_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Exposure Currency Code');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `exposure_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `exposure_direction` SET TAGS ('dbx_business_glossary_term' = 'Exposure Direction');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `exposure_direction` SET TAGS ('dbx_value_regex' = 'long|short|neutral');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `exposure_percentage` SET TAGS ('dbx_business_glossary_term' = 'Exposure Percentage');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `exposure_value` SET TAGS ('dbx_business_glossary_term' = 'Exposure Value');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `factor_category` SET TAGS ('dbx_business_glossary_term' = 'Factor Category');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `factor_category` SET TAGS ('dbx_value_regex' = 'style|industry|country|currency|macro|custom');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `factor_return` SET TAGS ('dbx_business_glossary_term' = 'Factor Return');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `factor_type` SET TAGS ('dbx_business_glossary_term' = 'Factor Type');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `factor_type` SET TAGS ('dbx_value_regex' = 'systematic|idiosyncratic|specific');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `factor_volatility` SET TAGS ('dbx_business_glossary_term' = 'Factor Volatility');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `is_material_exposure` SET TAGS ('dbx_business_glossary_term' = 'Is Material Exposure Flag');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `limit_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Limit Breach Flag');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `limit_utilization_percentage` SET TAGS ('dbx_business_glossary_term' = 'Limit Utilization Percentage');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `lookback_period_days` SET TAGS ('dbx_business_glossary_term' = 'Lookback Period Days');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `marginal_contribution_to_risk` SET TAGS ('dbx_business_glossary_term' = 'Marginal Contribution to Risk (MCTR)');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `market_value` SET TAGS ('dbx_business_glossary_term' = 'Market Value');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `notional_value` SET TAGS ('dbx_business_glossary_term' = 'Notional Value');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `stressed_exposure_value` SET TAGS ('dbx_business_glossary_term' = 'Stressed Exposure Value');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `t_statistic` SET TAGS ('dbx_business_glossary_term' = 'T-Statistic');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `tracking_error_contribution` SET TAGS ('dbx_business_glossary_term' = 'Tracking Error Contribution');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ALTER COLUMN `var_contribution` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Contribution');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` SET TAGS ('dbx_subdomain' = 'stress_testing');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `stress_test_result_id` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Result ID');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `liability_projection_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Projection Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `performance_calculation_run_id` SET TAGS ('dbx_business_glossary_term' = 'Performance Calculation Run Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Scenario ID');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `stress_test_run_id` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Run ID');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|under_review');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `base_cvar` SET TAGS ('dbx_business_glossary_term' = 'Base Conditional Value at Risk (CVaR)');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `base_nav` SET TAGS ('dbx_business_glossary_term' = 'Base Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `base_var` SET TAGS ('dbx_business_glossary_term' = 'Base Value at Risk (VaR)');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Breach Flag');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `breach_severity` SET TAGS ('dbx_business_glossary_term' = 'Breach Severity');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `breach_severity` SET TAGS ('dbx_value_regex' = 'none|minor|moderate|major|critical');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Calculation Date');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Calculation Methodology');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_value_regex' = 'historical_simulation|monte_carlo|parametric|hybrid');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `concentration_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Concentration Risk Score');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `counterparty_exposure_change` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Exposure Change');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Currency');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `effectiveness_under_stress` SET TAGS ('dbx_business_glossary_term' = 'Hedge Effectiveness Under Stress');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `factor_contribution_summary` SET TAGS ('dbx_business_glossary_term' = 'Factor Contribution Summary');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `liquidity_impact_days` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Impact Days');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `market_value_base` SET TAGS ('dbx_business_glossary_term' = 'Market Value Base Currency');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `position_quantity` SET TAGS ('dbx_business_glossary_term' = 'Position Quantity');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `rebalance_trigger_flag` SET TAGS ('dbx_business_glossary_term' = 'Rebalance Trigger Flag');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `regulatory_scenario_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Scenario Flag');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `result_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Result Timestamp');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `risk_system_source` SET TAGS ('dbx_business_glossary_term' = 'Risk System Source');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `risk_system_source` SET TAGS ('dbx_value_regex' = 'aladdin|riskmetrics|barra|simcorp|internal');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `scenario_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Scenario Impact Amount');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Sector');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `sensitivity` SET TAGS ('dbx_business_glossary_term' = 'Instrument Sensitivity');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `shock_value` SET TAGS ('dbx_business_glossary_term' = 'Scenario Shock Value');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `stressed_cvar` SET TAGS ('dbx_business_glossary_term' = 'Stressed Conditional Value at Risk (CVaR)');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `stressed_market_value` SET TAGS ('dbx_business_glossary_term' = 'Stressed Market Value');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `stressed_nav` SET TAGS ('dbx_business_glossary_term' = 'Stressed Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `stressed_pnl` SET TAGS ('dbx_business_glossary_term' = 'Stressed P&L Contribution');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `stressed_pnl_absolute` SET TAGS ('dbx_business_glossary_term' = 'Stressed Profit and Loss (P&L) Absolute');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `stressed_pnl_percentage` SET TAGS ('dbx_business_glossary_term' = 'Stressed Profit and Loss (P&L) Percentage');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `stressed_var` SET TAGS ('dbx_business_glossary_term' = 'Stressed Value at Risk (VaR)');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `test_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Execution Date');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `test_status` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Status');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `time_horizon_days` SET TAGS ('dbx_business_glossary_term' = 'Time Horizon Days');
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`risk`.`limit_breach` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`limit_breach` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`limit_breach` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`limit_breach` SET TAGS ('dbx_subdomain' = 'limit_governance');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `limit_breach_id` SET TAGS ('dbx_business_glossary_term' = 'Limit Breach Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `acknowledged_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Acknowledged By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `acknowledged_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `acknowledged_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `limit_id` SET TAGS ('dbx_business_glossary_term' = 'Limit Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `rule_id` SET TAGS ('dbx_business_glossary_term' = 'Rule Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Strategy Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `triggering_order_id` SET TAGS ('dbx_business_glossary_term' = 'Triggering Order Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `acknowledged_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Acknowledged Timestamp');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `breach_code` SET TAGS ('dbx_business_glossary_term' = 'Breach Code');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `breach_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{6,12}$');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `breach_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Breach Duration Minutes');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `breach_magnitude` SET TAGS ('dbx_business_glossary_term' = 'Breach Magnitude');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `breach_percentage` SET TAGS ('dbx_business_glossary_term' = 'Breach Percentage');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `breach_severity` SET TAGS ('dbx_business_glossary_term' = 'Breach Severity');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `breach_severity` SET TAGS ('dbx_value_regex' = 'warning|soft_breach|hard_breach|critical');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `breach_status` SET TAGS ('dbx_business_glossary_term' = 'Breach Status');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `breach_status` SET TAGS ('dbx_value_regex' = 'open|acknowledged|under_review|remediated|closed|escalated');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `breach_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Breach Timestamp');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `breached_metric_value` SET TAGS ('dbx_business_glossary_term' = 'Breached Metric Value');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `detection_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Detection Timestamp');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `escalation_level` SET TAGS ('dbx_business_glossary_term' = 'Escalation Level');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `escalation_level` SET TAGS ('dbx_value_regex' = 'none|team_lead|risk_manager|cro|investment_committee|board');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `escalation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Escalation Timestamp');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `ic_review_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Review Date');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `ic_review_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Review Required Flag');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `intraday_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Intraday Breach Flag');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `limit_threshold_value` SET TAGS ('dbx_business_glossary_term' = 'Limit Threshold Value');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `notification_sent_flag` SET TAGS ('dbx_business_glossary_term' = 'Notification Sent Flag');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `notification_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Notification Timestamp');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `regulatory_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Breach Flag');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `remediated_by` SET TAGS ('dbx_business_glossary_term' = 'Remediated By');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `remediation_action` SET TAGS ('dbx_business_glossary_term' = 'Remediation Action');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `remediation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Remediation Timestamp');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `risk_metric_type` SET TAGS ('dbx_business_glossary_term' = 'Risk Metric Type');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `risk_system_source` SET TAGS ('dbx_business_glossary_term' = 'Risk System Source');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `root_cause` SET TAGS ('dbx_business_glossary_term' = 'Root Cause');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Sector');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `time_horizon_days` SET TAGS ('dbx_business_glossary_term' = 'Time Horizon Days');
ALTER TABLE `asset_management`.`risk`.`limit_breach` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` SET TAGS ('dbx_subdomain' = 'exposure_analytics');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `risk_counterparty_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Counterparty Exposure Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `csa_id` SET TAGS ('dbx_business_glossary_term' = 'Csa Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `netting_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Netting Agreement Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `otc_derivative_id` SET TAGS ('dbx_business_glossary_term' = 'Otc Derivative Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Scenario Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'Equity|Fixed Income|FX|Commodity|Credit|Multi-Asset');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Breach Flag');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `breach_severity` SET TAGS ('dbx_business_glossary_term' = 'Breach Severity');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `breach_severity` SET TAGS ('dbx_value_regex' = 'None|Low|Medium|High|Critical');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Calculation Methodology');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_value_regex' = 'Current Exposure|SA-CCR|IMM|CEM|Other');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `ccp_name` SET TAGS ('dbx_business_glossary_term' = 'Central Counterparty (CCP) Name');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `clearing_status` SET TAGS ('dbx_business_glossary_term' = 'Clearing Status');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `clearing_status` SET TAGS ('dbx_value_regex' = 'Cleared|Bilateral|Uncleared');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `collateral_agreement_flag` SET TAGS ('dbx_business_glossary_term' = 'Collateral Agreement Flag');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `collateral_agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Agreement Type');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `collateral_agreement_type` SET TAGS ('dbx_value_regex' = 'CSA|SCSA|Bilateral|Unilateral|None');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `collateral_held_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Held Amount');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `collateral_posted_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Posted Amount');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `concentration_limit_utilization` SET TAGS ('dbx_business_glossary_term' = 'Concentration Limit Utilization');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `counterparty_credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Credit Rating');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `credit_valuation_adjustment` SET TAGS ('dbx_business_glossary_term' = 'Credit Valuation Adjustment (CVA)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `debit_valuation_adjustment` SET TAGS ('dbx_business_glossary_term' = 'Debit Valuation Adjustment (DVA)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `effective_maturity_years` SET TAGS ('dbx_business_glossary_term' = 'Effective Maturity (Years)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `expected_credit_loss` SET TAGS ('dbx_business_glossary_term' = 'Expected Credit Loss (ECL)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `expected_exposure` SET TAGS ('dbx_business_glossary_term' = 'Expected Exposure (EE)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `exposure_at_default` SET TAGS ('dbx_business_glossary_term' = 'Exposure at Default (EAD)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `exposure_currency` SET TAGS ('dbx_business_glossary_term' = 'Exposure Currency');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `exposure_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `exposure_type` SET TAGS ('dbx_business_glossary_term' = 'Exposure Type');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `exposure_type` SET TAGS ('dbx_value_regex' = 'OTC Derivative|Repo|Securities Lending|Unsettled Trade|Margin|Collateral');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `gross_exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Exposure Amount');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `independent_amount` SET TAGS ('dbx_business_glossary_term' = 'Independent Amount (IA)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `instrument_type` SET TAGS ('dbx_business_glossary_term' = 'Instrument Type');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `internal_credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Internal Credit Rating');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `loss_given_default` SET TAGS ('dbx_business_glossary_term' = 'Loss Given Default (LGD)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `margin_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Margin Threshold Amount');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `minimum_transfer_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Transfer Amount (MTA)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `net_exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Exposure Amount');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `netting_agreement_flag` SET TAGS ('dbx_business_glossary_term' = 'Netting Agreement Flag');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `netting_agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Netting Agreement Type');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `netting_agreement_type` SET TAGS ('dbx_value_regex' = 'ISDA Master|GMRA|GMSLA|Bilateral|None');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `netting_benefit_amount` SET TAGS ('dbx_business_glossary_term' = 'Netting Benefit Amount');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `potential_future_exposure` SET TAGS ('dbx_business_glossary_term' = 'Potential Future Exposure (PFE)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `probability_of_default` SET TAGS ('dbx_business_glossary_term' = 'Probability of Default (PD)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `risk_weight` SET TAGS ('dbx_business_glossary_term' = 'Risk Weight');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `risk_weighted_exposure` SET TAGS ('dbx_business_glossary_term' = 'Risk-Weighted Exposure (RWE)');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ALTER COLUMN `wrong_way_risk_flag` SET TAGS ('dbx_business_glossary_term' = 'Wrong-Way Risk Flag');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` SET TAGS ('dbx_subdomain' = 'exposure_analytics');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `concentration_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Concentration Exposure Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `credit_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `limit_id` SET TAGS ('dbx_business_glossary_term' = 'Limit Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Stress Scenario Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `breach_amount` SET TAGS ('dbx_business_glossary_term' = 'Breach Amount');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `breach_percentage` SET TAGS ('dbx_business_glossary_term' = 'Breach Percentage');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `breach_status` SET TAGS ('dbx_business_glossary_term' = 'Breach Status');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `breach_status` SET TAGS ('dbx_value_regex' = 'within_limit|soft_breach|hard_breach|escalated');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Calculation Methodology');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `concentration_dimension` SET TAGS ('dbx_business_glossary_term' = 'Concentration Dimension');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `concentration_dimension` SET TAGS ('dbx_value_regex' = 'single_issuer|sector|geography|asset_class|currency|counterparty');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `cvar_contribution` SET TAGS ('dbx_business_glossary_term' = 'Conditional Value at Risk (CVaR) Contribution');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `dimension_value` SET TAGS ('dbx_business_glossary_term' = 'Dimension Value');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `escalation_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Escalation Required Flag');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Exposure Amount');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `exposure_currency` SET TAGS ('dbx_business_glossary_term' = 'Exposure Currency');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `exposure_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `exposure_percentage` SET TAGS ('dbx_business_glossary_term' = 'Exposure Percentage');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `geographic_region` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `limit_threshold` SET TAGS ('dbx_business_glossary_term' = 'Limit Threshold');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `look_through_flag` SET TAGS ('dbx_business_glossary_term' = 'Look-Through Flag');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `measurement_date` SET TAGS ('dbx_business_glossary_term' = 'Measurement Date');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Frequency');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `nav_base` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Base');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `netting_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Netting Applied Flag');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `remediation_plan` SET TAGS ('dbx_business_glossary_term' = 'Remediation Plan');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `time_horizon_days` SET TAGS ('dbx_business_glossary_term' = 'Time Horizon Days');
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ALTER COLUMN `var_contribution` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Contribution');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` SET TAGS ('dbx_subdomain' = 'stress_testing');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `dv01_sensitivity_id` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of a Basis Point (DV01) Sensitivity ID');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `discount_rate_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate Curve Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `holding_id` SET TAGS ('dbx_business_glossary_term' = 'Position ID');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `research_yield_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Research Yield Curve Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `security_instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Security ID');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Stress Scenario ID');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `aggregation_level` SET TAGS ('dbx_business_glossary_term' = 'Aggregation Level');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `aggregation_level` SET TAGS ('dbx_value_regex' = 'position|portfolio|strategy|total_fund');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'fixed_income|credit|government_bonds|corporate_bonds|mortgage_backed_securities|asset_backed_securities');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Calculation Date');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Calculation Methodology');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_value_regex' = 'analytical|full_revaluation|grid_shock|scenario_based');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation Timestamp');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `convexity` SET TAGS ('dbx_business_glossary_term' = 'Convexity');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `coupon_rate` SET TAGS ('dbx_business_glossary_term' = 'Coupon Rate');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `dv01_amount` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of a Basis Point (DV01) Amount');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `effective_duration` SET TAGS ('dbx_business_glossary_term' = 'Effective Duration');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `hedge_adjusted_flag` SET TAGS ('dbx_business_glossary_term' = 'Hedge Adjusted Flag');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `instrument_type` SET TAGS ('dbx_business_glossary_term' = 'Instrument Type');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `instrument_type` SET TAGS ('dbx_value_regex' = 'bond|swap|future|option|swaption|cap_floor');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `key_rate_duration_10y` SET TAGS ('dbx_business_glossary_term' = 'Key Rate Duration 10 Year');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `key_rate_duration_1y` SET TAGS ('dbx_business_glossary_term' = 'Key Rate Duration 1 Year');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `key_rate_duration_2y` SET TAGS ('dbx_business_glossary_term' = 'Key Rate Duration 2 Year');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `key_rate_duration_30y` SET TAGS ('dbx_business_glossary_term' = 'Key Rate Duration 30 Year');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `key_rate_duration_3m` SET TAGS ('dbx_business_glossary_term' = 'Key Rate Duration 3 Month');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `key_rate_duration_5y` SET TAGS ('dbx_business_glossary_term' = 'Key Rate Duration 5 Year');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `key_rate_duration_6m` SET TAGS ('dbx_business_glossary_term' = 'Key Rate Duration 6 Month');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `macaulay_duration` SET TAGS ('dbx_business_glossary_term' = 'Macaulay Duration');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `market_value` SET TAGS ('dbx_business_glossary_term' = 'Market Value');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `modified_duration` SET TAGS ('dbx_business_glossary_term' = 'Modified Duration');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `notional_amount` SET TAGS ('dbx_business_glossary_term' = 'Notional Amount');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `risk_system_source` SET TAGS ('dbx_business_glossary_term' = 'Risk System Source');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `shock_size_bps` SET TAGS ('dbx_business_glossary_term' = 'Shock Size Basis Points (bps)');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `spread_duration` SET TAGS ('dbx_business_glossary_term' = 'Spread Duration');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `yield_curve_date` SET TAGS ('dbx_business_glossary_term' = 'Yield Curve Date');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `yield_curve_source` SET TAGS ('dbx_business_glossary_term' = 'Yield Curve Source');
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ALTER COLUMN `yield_to_maturity` SET TAGS ('dbx_business_glossary_term' = 'Yield to Maturity (YTM)');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` SET TAGS ('dbx_subdomain' = 'exposure_analytics');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `liquidity_risk_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Risk Assessment Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `assessed_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assessed By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `assessed_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `assessed_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `liability_cash_flow_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Cash Flow Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `limit_id` SET TAGS ('dbx_business_glossary_term' = 'Limit Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `significant_cash_flow_id` SET TAGS ('dbx_business_glossary_term' = 'Significant Cash Flow Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Scenario Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `assessment_code` SET TAGS ('dbx_business_glossary_term' = 'Assessment Code');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `assessment_code` SET TAGS ('dbx_value_regex' = '^LRA-[0-9]{8}-[A-Z0-9]{6}$');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Assessment Date');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'Assessment Status');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'draft|in_review|approved|rejected|superseded|archived');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `bid_ask_spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Bid-Ask Spread Basis Points (bps)');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `breach_severity` SET TAGS ('dbx_business_glossary_term' = 'Breach Severity');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `breach_severity` SET TAGS ('dbx_value_regex' = 'none|low|medium|high|critical');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `concentration_risk_flag` SET TAGS ('dbx_business_glossary_term' = 'Concentration Risk Flag');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `days_to_liquidate` SET TAGS ('dbx_business_glossary_term' = 'Days to Liquidate');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `escalation_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Escalation Required Flag');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `funding_liquidity_risk_flag` SET TAGS ('dbx_business_glossary_term' = 'Funding Liquidity Risk Flag');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `illiquid_assets_value` SET TAGS ('dbx_business_glossary_term' = 'Illiquid Assets Value');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `limit_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Limit Breach Flag');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `liquid_assets_value` SET TAGS ('dbx_business_glossary_term' = 'Liquid Assets Value');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `liquidation_scenario` SET TAGS ('dbx_business_glossary_term' = 'Liquidation Scenario');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `liquidation_scenario` SET TAGS ('dbx_value_regex' = 'normal_market|stressed_market|crisis|orderly_exit|forced_liquidation');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `liquidity_coverage_ratio` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Coverage Ratio (LCR)');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `liquidity_ratio` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Ratio');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `market_impact_cost_bps` SET TAGS ('dbx_business_glossary_term' = 'Market Impact Cost Basis Points (bps)');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `measurement_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Measurement Timestamp');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `methodology` SET TAGS ('dbx_business_glossary_term' = 'Methodology');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `nav_currency` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Currency');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `nav_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `remediation_plan` SET TAGS ('dbx_business_glossary_term' = 'Remediation Plan');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `reviewed_by` SET TAGS ('dbx_business_glossary_term' = 'Reviewed By');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `risk_system_source` SET TAGS ('dbx_business_glossary_term' = 'Risk System Source');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Sector');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `time_horizon_days` SET TAGS ('dbx_business_glossary_term' = 'Time Horizon Days');
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ALTER COLUMN `total_portfolio_nav` SET TAGS ('dbx_business_glossary_term' = 'Total Portfolio Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` SET TAGS ('dbx_subdomain' = 'exposure_analytics');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `fx_risk_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Risk Exposure ID');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `fx_position_id` SET TAGS ('dbx_business_glossary_term' = 'Fx Position Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `hedge_fx_trade_id` SET TAGS ('dbx_business_glossary_term' = 'Hedge Fx Trade Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `limit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Limit ID');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `research_fx_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Research Fx Rate Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Stress Scenario ID');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `base_currency` SET TAGS ('dbx_business_glossary_term' = 'Base Currency');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `base_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `breach_status` SET TAGS ('dbx_business_glossary_term' = 'Breach Status');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `breach_status` SET TAGS ('dbx_value_regex' = 'within_limit|warning|breach|critical_breach');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Calculation Methodology');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_value_regex' = 'historical_simulation|monte_carlo|parametric|variance_covariance');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `correlation_to_portfolio` SET TAGS ('dbx_business_glossary_term' = 'Correlation to Portfolio');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `currency_pair` SET TAGS ('dbx_business_glossary_term' = 'Currency Pair');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `currency_pair` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}/[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `cvar_1day_99pct` SET TAGS ('dbx_business_glossary_term' = 'Conditional Value at Risk (CVaR) 1-Day 99%');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `dv01` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of 01 (DV01)');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `exposure_base_currency_equivalent` SET TAGS ('dbx_business_glossary_term' = 'Exposure Base Currency Equivalent');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `exposure_currency` SET TAGS ('dbx_business_glossary_term' = 'Exposure Currency');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `exposure_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `exposure_type` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Exposure Type');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `exposure_type` SET TAGS ('dbx_value_regex' = 'transaction|translation|economic');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `geographic_region` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `gross_exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Exposure Amount');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `hedge_effectiveness` SET TAGS ('dbx_business_glossary_term' = 'Hedge Effectiveness');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `hedge_instrument_type` SET TAGS ('dbx_business_glossary_term' = 'Hedge Instrument Type');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `hedge_instrument_type` SET TAGS ('dbx_value_regex' = 'forward|swap|option|none');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `hedge_notional_amount` SET TAGS ('dbx_business_glossary_term' = 'Hedge Notional Amount');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `hedge_ratio` SET TAGS ('dbx_business_glossary_term' = 'Hedge Ratio');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `limit_utilization_percentage` SET TAGS ('dbx_business_glossary_term' = 'Limit Utilization Percentage');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `measurement_date` SET TAGS ('dbx_business_glossary_term' = 'Measurement Date');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `net_exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Exposure Amount');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `risk_system_source` SET TAGS ('dbx_business_glossary_term' = 'Risk System Source');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `risk_system_source` SET TAGS ('dbx_value_regex' = 'aladdin|riskmetrics|barra|simcorp|internal');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `spot_rate` SET TAGS ('dbx_business_glossary_term' = 'Spot Exchange Rate');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `stressed_exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Stressed Exposure Amount');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `time_horizon_days` SET TAGS ('dbx_business_glossary_term' = 'Time Horizon Days');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `var_1day_99pct` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) 1-Day 99%');
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ALTER COLUMN `volatility` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Volatility');
ALTER TABLE `asset_management`.`risk`.`attribution` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`attribution` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`attribution` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`attribution` SET TAGS ('dbx_subdomain' = 'exposure_analytics');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `attribution_id` SET TAGS ('dbx_business_glossary_term' = 'Attribution ID');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `equity_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark ID');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `risk_model_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Model Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Stress Scenario ID');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `active_risk` SET TAGS ('dbx_business_glossary_term' = 'Active Risk');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `allocation_risk` SET TAGS ('dbx_business_glossary_term' = 'Allocation Risk');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `asset_class_risk` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Risk');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `attribution_type` SET TAGS ('dbx_business_glossary_term' = 'Attribution Type');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `attribution_type` SET TAGS ('dbx_value_regex' = 'active_risk|total_risk|tracking_error|residual_risk');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `beta_to_benchmark` SET TAGS ('dbx_business_glossary_term' = 'Beta to Benchmark');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Calculation Methodology');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation Timestamp');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `component_var` SET TAGS ('dbx_business_glossary_term' = 'Component Value at Risk (VaR)');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `correlation_to_portfolio` SET TAGS ('dbx_business_glossary_term' = 'Correlation to Portfolio');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `currency_risk` SET TAGS ('dbx_business_glossary_term' = 'Currency Risk');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `cvar_contribution` SET TAGS ('dbx_business_glossary_term' = 'Conditional Value at Risk (CVaR) Contribution');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `decomposition_level` SET TAGS ('dbx_business_glossary_term' = 'Decomposition Level');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `decomposition_level` SET TAGS ('dbx_value_regex' = 'portfolio|strategy|asset_class|sector|security');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `factor_risk` SET TAGS ('dbx_business_glossary_term' = 'Factor Risk');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `geographic_risk` SET TAGS ('dbx_business_glossary_term' = 'Geographic Risk');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `interaction_risk` SET TAGS ('dbx_business_glossary_term' = 'Interaction Risk');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `marginal_var` SET TAGS ('dbx_business_glossary_term' = 'Marginal Value at Risk (VaR)');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `measurement_date` SET TAGS ('dbx_business_glossary_term' = 'Measurement Date');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `r_squared` SET TAGS ('dbx_business_glossary_term' = 'R-Squared');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `review_status` SET TAGS ('dbx_business_glossary_term' = 'Review Status');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `review_status` SET TAGS ('dbx_value_regex' = 'draft|pending_review|approved|rejected');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `risk_currency` SET TAGS ('dbx_business_glossary_term' = 'Risk Currency');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `risk_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `sector_risk` SET TAGS ('dbx_business_glossary_term' = 'Sector Risk');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `selection_risk` SET TAGS ('dbx_business_glossary_term' = 'Selection Risk');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `specific_risk` SET TAGS ('dbx_business_glossary_term' = 'Specific Risk');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `style_risk` SET TAGS ('dbx_business_glossary_term' = 'Style Risk');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `time_horizon_days` SET TAGS ('dbx_business_glossary_term' = 'Time Horizon Days');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `total_risk` SET TAGS ('dbx_business_glossary_term' = 'Total Risk');
ALTER TABLE `asset_management`.`risk`.`attribution` ALTER COLUMN `var_contribution` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Contribution');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` SET TAGS ('dbx_subdomain' = 'stress_testing');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `sensitivity_analysis_id` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Analysis Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `holding_id` SET TAGS ('dbx_business_glossary_term' = 'Position Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `risk_factor_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Factor Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Scenario Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `analysis_code` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Analysis Code');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `analysis_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{4,20}$');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `analysis_name` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Analysis Name');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `analysis_status` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Analysis Status');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `analysis_status` SET TAGS ('dbx_value_regex' = 'pending|running|completed|failed|cancelled');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `analysis_type` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Analysis Type');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `analysis_type` SET TAGS ('dbx_value_regex' = 'single_factor|multi_factor|scenario|stress_test|what_if');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `as_of_date` SET TAGS ('dbx_business_glossary_term' = 'As-Of Date');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `base_value` SET TAGS ('dbx_business_glossary_term' = 'Base Value');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Calculation Methodology');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_value_regex' = 'full_revaluation|delta_approximation|taylor_expansion|monte_carlo|historical_simulation');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `convexity_impact` SET TAGS ('dbx_business_glossary_term' = 'Convexity Impact');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `cvar_impact` SET TAGS ('dbx_business_glossary_term' = 'Conditional Value at Risk (CVaR) Impact');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `duration_impact` SET TAGS ('dbx_business_glossary_term' = 'Duration Impact');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `dv01` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of 01 (DV01)');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `escalation_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Escalation Required Flag');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `execution_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Execution Timestamp');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `ic_review_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Review Required Flag');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `limit_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Limit Breach Flag');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `limit_utilization_percentage` SET TAGS ('dbx_business_glossary_term' = 'Limit Utilization Percentage');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `risk_factor_category` SET TAGS ('dbx_business_glossary_term' = 'Risk Factor Category');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `risk_system_source` SET TAGS ('dbx_business_glossary_term' = 'Risk System Source');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Sector');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `shock_direction` SET TAGS ('dbx_business_glossary_term' = 'Shock Direction');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `shock_direction` SET TAGS ('dbx_value_regex' = 'up|down|parallel|twist|custom');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `shock_magnitude` SET TAGS ('dbx_business_glossary_term' = 'Shock Magnitude');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `shock_type` SET TAGS ('dbx_business_glossary_term' = 'Shock Type');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `shock_type` SET TAGS ('dbx_value_regex' = 'absolute|relative|basis_point|percentage');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `shocked_value` SET TAGS ('dbx_business_glossary_term' = 'Shocked Value');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `time_horizon_days` SET TAGS ('dbx_business_glossary_term' = 'Time Horizon Days');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `value_change` SET TAGS ('dbx_business_glossary_term' = 'Value Change');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `value_change_percentage` SET TAGS ('dbx_business_glossary_term' = 'Value Change Percentage');
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ALTER COLUMN `var_impact` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Impact');
ALTER TABLE `asset_management`.`risk`.`risk_review` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`risk`.`risk_review` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`risk_review` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`risk_review` SET TAGS ('dbx_subdomain' = 'limit_governance');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `risk_review_id` SET TAGS ('dbx_business_glossary_term' = 'Review ID');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `lead_reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Reviewer Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `lead_reviewer_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `lead_reviewer_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `research_report_id` SET TAGS ('dbx_business_glossary_term' = 'Report Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Strategy ID');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `action_items` SET TAGS ('dbx_business_glossary_term' = 'Action Items');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `risk_review_code` SET TAGS ('dbx_business_glossary_term' = 'Review Code');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `risk_review_code` SET TAGS ('dbx_value_regex' = '^RR-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `critical_breach_count` SET TAGS ('dbx_business_glossary_term' = 'Critical Breach Count');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `cvar_95_amount` SET TAGS ('dbx_business_glossary_term' = 'Conditional Value at Risk (CVaR) 95% Amount');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `data_quality_issues` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Issues');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `document_reference` SET TAGS ('dbx_business_glossary_term' = 'Document Reference');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `emerging_risk_count` SET TAGS ('dbx_business_glossary_term' = 'Emerging Risk Count');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `frequency` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `ic_decision` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `ic_review_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Review Date');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `ic_review_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Review Required Flag');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `key_findings` SET TAGS ('dbx_business_glossary_term' = 'Key Findings');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `limit_breach_count` SET TAGS ('dbx_business_glossary_term' = 'Limit Breach Count');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Review Period End Date');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Review Period Start Date');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `previous_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Previous Risk Rating');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `previous_risk_rating` SET TAGS ('dbx_value_regex' = 'low|moderate|elevated|high|critical');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `recommendations` SET TAGS ('dbx_business_glossary_term' = 'Recommendations');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `risk_currency` SET TAGS ('dbx_business_glossary_term' = 'Risk Currency');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `risk_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|moderate|elevated|high|critical');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `risk_rating_change` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating Change');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `risk_rating_change` SET TAGS ('dbx_value_regex' = 'upgraded|downgraded|unchanged|new');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `risk_review_date` SET TAGS ('dbx_business_glossary_term' = 'Review Date');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `risk_review_status` SET TAGS ('dbx_business_glossary_term' = 'Review Status');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `risk_review_status` SET TAGS ('dbx_value_regex' = 'draft|in_progress|under_review|approved|published|archived');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `risk_review_type` SET TAGS ('dbx_business_glossary_term' = 'Review Type');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `risk_review_type` SET TAGS ('dbx_value_regex' = 'portfolio|counterparty|concentration|market|liquidity|operational');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `risk_system_source` SET TAGS ('dbx_business_glossary_term' = 'Risk System Source');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `risk_system_source` SET TAGS ('dbx_value_regex' = 'aladdin|msci_riskmetrics|barra|simcorp|internal');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'Review Scope');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `stress_test_result` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Result');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `stress_test_scenario_applied` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Scenario Applied');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `team_members` SET TAGS ('dbx_business_glossary_term' = 'Review Team Members');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `var_95_amount` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) 95% Amount');
ALTER TABLE `asset_management`.`risk`.`risk_review` ALTER COLUMN `var_99_amount` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) 99% Amount');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` SET TAGS ('dbx_subdomain' = 'limit_governance');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `limit_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Limit Assignment Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `assigned_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `assigned_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `assigned_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `limit_id` SET TAGS ('dbx_business_glossary_term' = 'Limit Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Strategy Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `assigned_limit_value` SET TAGS ('dbx_business_glossary_term' = 'Assigned Limit Value');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `assignment_code` SET TAGS ('dbx_business_glossary_term' = 'Assignment Code');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `assignment_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Date');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `assignment_priority` SET TAGS ('dbx_business_glossary_term' = 'Assignment Priority');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `assignment_rationale` SET TAGS ('dbx_business_glossary_term' = 'Assignment Rationale');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Assignment Status');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|suspended|expired|revoked');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_business_glossary_term' = 'Assignment Type');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_value_regex' = 'portfolio|mandate|asset_class|strategy|counterparty|geographic');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `auto_remediation_flag` SET TAGS ('dbx_business_glossary_term' = 'Automatic Remediation Flag');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `breach_count_ytd` SET TAGS ('dbx_business_glossary_term' = 'Breach Count Year-to-Date (YTD)');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `breach_tolerance_lower` SET TAGS ('dbx_business_glossary_term' = 'Breach Tolerance Lower Bound');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `breach_tolerance_upper` SET TAGS ('dbx_business_glossary_term' = 'Breach Tolerance Upper Bound');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `escalation_level` SET TAGS ('dbx_business_glossary_term' = 'Escalation Level');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `escalation_level` SET TAGS ('dbx_value_regex' = 'portfolio_manager|risk_officer|cro|ic|board');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `escalation_procedure` SET TAGS ('dbx_business_glossary_term' = 'Escalation Procedure');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `last_breach_date` SET TAGS ('dbx_business_glossary_term' = 'Last Breach Date');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `limit_currency` SET TAGS ('dbx_business_glossary_term' = 'Limit Currency');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `limit_unit` SET TAGS ('dbx_business_glossary_term' = 'Limit Unit of Measure');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Frequency');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_value_regex' = 'real_time|intraday|daily|weekly|monthly|quarterly');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `override_flag` SET TAGS ('dbx_business_glossary_term' = 'Override Flag');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `regulatory_requirement_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Flag');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `remediation_action` SET TAGS ('dbx_business_glossary_term' = 'Remediation Action');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|ad_hoc');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `risk_system_source` SET TAGS ('dbx_business_glossary_term' = 'Risk System Source');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Sector');
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ALTER COLUMN `utilization_percentage` SET TAGS ('dbx_business_glossary_term' = 'Utilization Percentage');
ALTER TABLE `asset_management`.`risk`.`factor_return` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`factor_return` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`factor_return` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`factor_return` SET TAGS ('dbx_subdomain' = 'exposure_analytics');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `factor_return_id` SET TAGS ('dbx_business_glossary_term' = 'Factor Return Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `factor_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Factor Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `risk_model_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Model Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|pending_review|approved|rejected|archived');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `benchmark_index_code` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index Code');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `beta_to_market` SET TAGS ('dbx_business_glossary_term' = 'Beta to Market');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Calculation Methodology');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation Timestamp');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `correlation_to_market` SET TAGS ('dbx_business_glossary_term' = 'Correlation to Market');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `factor_category` SET TAGS ('dbx_business_glossary_term' = 'Factor Category');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `factor_category` SET TAGS ('dbx_value_regex' = 'style|industry|country|currency|macro|statistical');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `factor_type` SET TAGS ('dbx_business_glossary_term' = 'Factor Type');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `information_ratio` SET TAGS ('dbx_business_glossary_term' = 'Information Ratio (IR)');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `is_material_factor` SET TAGS ('dbx_business_glossary_term' = 'Is Material Factor');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `is_proprietary` SET TAGS ('dbx_business_glossary_term' = 'Is Proprietary Factor');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `lookback_period_days` SET TAGS ('dbx_business_glossary_term' = 'Lookback Period (Days)');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `observation_count` SET TAGS ('dbx_business_glossary_term' = 'Observation Count');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `r_squared` SET TAGS ('dbx_business_glossary_term' = 'R-Squared (R²)');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `return_date` SET TAGS ('dbx_business_glossary_term' = 'Factor Return Date');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `return_percentage` SET TAGS ('dbx_business_glossary_term' = 'Factor Return Percentage');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `return_period_type` SET TAGS ('dbx_business_glossary_term' = 'Return Period Type');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `return_period_type` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annual');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `return_value` SET TAGS ('dbx_business_glossary_term' = 'Factor Return Value');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `sharpe_ratio` SET TAGS ('dbx_business_glossary_term' = 'Sharpe Ratio');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `t_statistic` SET TAGS ('dbx_business_glossary_term' = 'T-Statistic');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `usage_in_attribution` SET TAGS ('dbx_business_glossary_term' = 'Usage in Performance Attribution');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `usage_in_stress_testing` SET TAGS ('dbx_business_glossary_term' = 'Usage in Stress Testing');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `usage_in_var_calculation` SET TAGS ('dbx_business_glossary_term' = 'Usage in Value at Risk (VaR) Calculation');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `vendor_model_name` SET TAGS ('dbx_business_glossary_term' = 'Vendor Model Name');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `vendor_model_version` SET TAGS ('dbx_business_glossary_term' = 'Vendor Model Version');
ALTER TABLE `asset_management`.`risk`.`factor_return` ALTER COLUMN `volatility` SET TAGS ('dbx_business_glossary_term' = 'Factor Volatility');
ALTER TABLE `asset_management`.`risk`.`credit_rating` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`risk`.`credit_rating` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`credit_rating` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`credit_rating` SET TAGS ('dbx_subdomain' = 'limit_governance');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `credit_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `ecl_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Expected Credit Loss Currency Code');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `ecl_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `expected_credit_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Expected Credit Loss Amount (ECL)');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `instrument_cusip` SET TAGS ('dbx_business_glossary_term' = 'Instrument Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `instrument_cusip` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{9}$');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `instrument_isin` SET TAGS ('dbx_business_glossary_term' = 'Instrument International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `instrument_isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `internal_rating_override` SET TAGS ('dbx_business_glossary_term' = 'Internal Rating Override');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `internal_rating_rationale` SET TAGS ('dbx_business_glossary_term' = 'Internal Rating Rationale');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `is_solicited_rating` SET TAGS ('dbx_business_glossary_term' = 'Is Solicited Rating Flag');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Name');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `loss_given_default_pct` SET TAGS ('dbx_business_glossary_term' = 'Loss Given Default Percentage (LGD)');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Instrument Maturity Date');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `outlook` SET TAGS ('dbx_business_glossary_term' = 'Rating Outlook');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `outlook` SET TAGS ('dbx_value_regex' = 'positive|stable|negative|developing|not_applicable');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `previous_rating_value` SET TAGS ('dbx_business_glossary_term' = 'Previous Rating Value');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `probability_of_default_pct` SET TAGS ('dbx_business_glossary_term' = 'Probability of Default Percentage (PD)');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `rating_action_date` SET TAGS ('dbx_business_glossary_term' = 'Rating Action Date');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `rating_action_type` SET TAGS ('dbx_business_glossary_term' = 'Rating Action Type');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `rating_action_type` SET TAGS ('dbx_value_regex' = 'new|affirmed|upgraded|downgraded|withdrawn|suspended');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `rating_agency` SET TAGS ('dbx_business_glossary_term' = 'Rating Agency');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `rating_agency` SET TAGS ('dbx_value_regex' = 'SP|Moodys|Fitch|DBRS|Internal');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `rating_category` SET TAGS ('dbx_business_glossary_term' = 'Rating Category');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `rating_category` SET TAGS ('dbx_value_regex' = 'investment_grade|high_yield|non_rated|default');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `rating_change_notches` SET TAGS ('dbx_business_glossary_term' = 'Rating Change Notches');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `rating_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Rating Effective Date');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `rating_notch` SET TAGS ('dbx_business_glossary_term' = 'Rating Notch');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `rating_scale` SET TAGS ('dbx_business_glossary_term' = 'Rating Scale');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `rating_scale` SET TAGS ('dbx_value_regex' = 'long_term|short_term|issuer_default|financial_strength');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `rating_source_identifier` SET TAGS ('dbx_business_glossary_term' = 'Rating Source Identifier');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `rating_source_system` SET TAGS ('dbx_business_glossary_term' = 'Rating Source System');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `rating_type` SET TAGS ('dbx_business_glossary_term' = 'Rating Type');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `rating_value` SET TAGS ('dbx_business_glossary_term' = 'Rating Value');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `risk_weight_pct` SET TAGS ('dbx_business_glossary_term' = 'Risk Weight Percentage');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `seniority` SET TAGS ('dbx_business_glossary_term' = 'Debt Seniority');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `seniority` SET TAGS ('dbx_value_regex' = 'senior_secured|senior_unsecured|subordinated|junior|equity');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `watch_status` SET TAGS ('dbx_business_glossary_term' = 'Credit Watch Status');
ALTER TABLE `asset_management`.`risk`.`credit_rating` ALTER COLUMN `watch_status` SET TAGS ('dbx_value_regex' = 'none|positive_watch|negative_watch|developing_watch');
ALTER TABLE `asset_management`.`risk`.`risk_exception` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`risk_exception` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`risk_exception` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`risk_exception` SET TAGS ('dbx_subdomain' = 'limit_governance');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `risk_exception_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Exception Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `limit_id` SET TAGS ('dbx_business_glossary_term' = 'Limit Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `requested_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Requested By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `requested_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `requested_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Strategy Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `approval_level` SET TAGS ('dbx_business_glossary_term' = 'Approval Level');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `approval_level` SET TAGS ('dbx_value_regex' = 'portfolio_manager|cro|cio|ic|board');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `approved_by` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `breach_count` SET TAGS ('dbx_business_glossary_term' = 'Breach Count');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `business_rationale` SET TAGS ('dbx_business_glossary_term' = 'Business Rationale');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `duration_days` SET TAGS ('dbx_business_glossary_term' = 'Duration Days');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `escalation_procedure` SET TAGS ('dbx_business_glossary_term' = 'Escalation Procedure');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `exception_code` SET TAGS ('dbx_business_glossary_term' = 'Exception Code');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `exception_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}-[0-9]{6}$');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `exception_name` SET TAGS ('dbx_business_glossary_term' = 'Exception Name');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `exception_status` SET TAGS ('dbx_business_glossary_term' = 'Exception Status');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `exception_status` SET TAGS ('dbx_value_regex' = 'pending|approved|active|expired|revoked|rejected');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `exception_type` SET TAGS ('dbx_business_glossary_term' = 'Exception Type');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `exception_type` SET TAGS ('dbx_value_regex' = 'limit_breach|policy_override|concentration_waiver|counterparty_excess|liquidity_variance|var_exceedance');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `ic_review_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Review Date');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `ic_review_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Review Required Flag');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `last_breach_date` SET TAGS ('dbx_business_glossary_term' = 'Last Breach Date');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `mitigation_measures` SET TAGS ('dbx_business_glossary_term' = 'Mitigation Measures');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Frequency');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_value_regex' = 'real_time|intraday|daily|weekly|monthly');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `original_limit_value` SET TAGS ('dbx_business_glossary_term' = 'Original Limit Value');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `request_date` SET TAGS ('dbx_business_glossary_term' = 'Request Date');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'weekly|monthly|quarterly|ad_hoc');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `revocation_date` SET TAGS ('dbx_business_glossary_term' = 'Revocation Date');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `revocation_reason` SET TAGS ('dbx_business_glossary_term' = 'Revocation Reason');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `revoked_by` SET TAGS ('dbx_business_glossary_term' = 'Revoked By');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `revoked_by` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `risk_assessment` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `risk_system_source` SET TAGS ('dbx_business_glossary_term' = 'Risk System Source');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Sector');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `threshold_value` SET TAGS ('dbx_business_glossary_term' = 'Exception Threshold Value');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `utilization_percentage` SET TAGS ('dbx_business_glossary_term' = 'Utilization Percentage');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Variance Amount');
ALTER TABLE `asset_management`.`risk`.`risk_exception` ALTER COLUMN `variance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Variance Percentage');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` SET TAGS ('dbx_subdomain' = 'stress_testing');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `correlation_matrix_id` SET TAGS ('dbx_business_glossary_term' = 'Correlation Matrix Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `risk_model_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Model Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `superseded_by_matrix_correlation_matrix_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Matrix Identifier (ID)');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `adjustment_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Applied Flag');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `adjustment_method` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Method');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `as_of_date` SET TAGS ('dbx_business_glossary_term' = 'As Of Date');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `average_correlation` SET TAGS ('dbx_business_glossary_term' = 'Average Correlation');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation Timestamp');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `condition_number` SET TAGS ('dbx_business_glossary_term' = 'Condition Number');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `decay_factor` SET TAGS ('dbx_business_glossary_term' = 'Decay Factor');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `dimension_count` SET TAGS ('dbx_business_glossary_term' = 'Dimension Count');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `effective_to_date` SET TAGS ('dbx_business_glossary_term' = 'Effective To Date');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `estimation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Estimation Methodology');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `ic_approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Required Flag');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `lookback_period_days` SET TAGS ('dbx_business_glossary_term' = 'Lookback Period Days');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `matrix_code` SET TAGS ('dbx_business_glossary_term' = 'Matrix Code');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `matrix_determinant` SET TAGS ('dbx_business_glossary_term' = 'Matrix Determinant');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `matrix_name` SET TAGS ('dbx_business_glossary_term' = 'Matrix Name');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `matrix_status` SET TAGS ('dbx_business_glossary_term' = 'Matrix Status');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `matrix_status` SET TAGS ('dbx_value_regex' = 'active|inactive|draft|approved|superseded|archived');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `matrix_type` SET TAGS ('dbx_business_glossary_term' = 'Matrix Type');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `matrix_type` SET TAGS ('dbx_value_regex' = 'asset_class|factor|currency|sector|geographic|counterparty');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `maximum_correlation` SET TAGS ('dbx_business_glossary_term' = 'Maximum Correlation');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `minimum_correlation` SET TAGS ('dbx_business_glossary_term' = 'Minimum Correlation');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `observation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Observation Frequency');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `observation_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `positive_definite_flag` SET TAGS ('dbx_business_glossary_term' = 'Positive Definite Flag');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annually');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `risk_system_source` SET TAGS ('dbx_business_glossary_term' = 'Risk System Source');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `shrinkage_intensity` SET TAGS ('dbx_business_glossary_term' = 'Shrinkage Intensity');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `usage_in_stress_testing` SET TAGS ('dbx_business_glossary_term' = 'Usage in Stress Testing');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `usage_in_var_calculation` SET TAGS ('dbx_business_glossary_term' = 'Usage in Value at Risk (VaR) Calculation');
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ALTER COLUMN `vendor_model_name` SET TAGS ('dbx_business_glossary_term' = 'Vendor Model Name');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` SET TAGS ('dbx_subdomain' = 'limit_governance');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `appetite_statement_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Appetite Statement (RAS) Identifier');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `superseded_by_statement_appetite_statement_id` SET TAGS ('dbx_business_glossary_term' = 'Superseding Statement Identifier');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Board Approval Date');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Scope');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Risk Calculation Methodology');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `climate_scenario_alignment` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Alignment');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Statistical Confidence Level Percentage');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Statement Effective Date');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `escalation_level` SET TAGS ('dbx_business_glossary_term' = 'Escalation Authority Level');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `escalation_level` SET TAGS ('dbx_value_regex' = 'portfolio_manager|cro|cio|risk_committee|investment_committee|board');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `escalation_procedure` SET TAGS ('dbx_business_glossary_term' = 'Breach Escalation Procedure');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Indicator');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Statement Expiry Date');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `external_reference_code` SET TAGS ('dbx_business_glossary_term' = 'External System Reference Identifier');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `liability_matching_consideration` SET TAGS ('dbx_business_glossary_term' = 'Liability Matching Consideration');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modification Timestamp');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_business_glossary_term' = 'Risk Monitoring Frequency');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_value_regex' = 'real_time|intraday|daily|weekly|monthly|quarterly');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Review Date');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `rationale` SET TAGS ('dbx_business_glossary_term' = 'Risk Appetite Rationale');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference Citation');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `regulatory_requirement_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Indicator');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Statement Review Frequency');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annually|annually|ad_hoc');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `risk_category` SET TAGS ('dbx_business_glossary_term' = 'Risk Category Classification');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `risk_category` SET TAGS ('dbx_value_regex' = 'market_risk|credit_risk|liquidity_risk|concentration_risk|operational_risk|esg_risk');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `risk_model_name` SET TAGS ('dbx_business_glossary_term' = 'Risk Model Name');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `risk_model_version` SET TAGS ('dbx_business_glossary_term' = 'Risk Model Version');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `risk_subcategory` SET TAGS ('dbx_business_glossary_term' = 'Risk Subcategory Classification');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `statement_code` SET TAGS ('dbx_business_glossary_term' = 'Risk Appetite Statement (RAS) Code');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `statement_code` SET TAGS ('dbx_value_regex' = '^RAS-[A-Z0-9]{6,12}$');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `statement_name` SET TAGS ('dbx_business_glossary_term' = 'Risk Appetite Statement Name');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `statement_status` SET TAGS ('dbx_business_glossary_term' = 'Statement Lifecycle Status');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `statement_status` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|approved|active|superseded|archived');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `statement_version` SET TAGS ('dbx_business_glossary_term' = 'Statement Version Number');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `statement_version` SET TAGS ('dbx_value_regex' = '^[0-9]{1,3}.[0-9]{1,3}$');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `stress_scenario_alignment` SET TAGS ('dbx_business_glossary_term' = 'Stress Scenario Alignment');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `target_threshold` SET TAGS ('dbx_business_glossary_term' = 'Risk Target Threshold Value');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `time_horizon_days` SET TAGS ('dbx_business_glossary_term' = 'Risk Measurement Time Horizon in Days');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `tolerance_currency` SET TAGS ('dbx_business_glossary_term' = 'Tolerance Currency Code');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `tolerance_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `tolerance_metric` SET TAGS ('dbx_business_glossary_term' = 'Risk Tolerance Metric');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `tolerance_threshold` SET TAGS ('dbx_business_glossary_term' = 'Risk Tolerance Threshold Value');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `tolerance_unit` SET TAGS ('dbx_business_glossary_term' = 'Tolerance Threshold Unit of Measure');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `tolerance_unit` SET TAGS ('dbx_value_regex' = 'currency|percentage|basis_points|ratio|count|index_points');
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ALTER COLUMN `warning_threshold` SET TAGS ('dbx_business_glossary_term' = 'Risk Warning Threshold Value');
ALTER TABLE `asset_management`.`risk`.`model_validation` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`risk`.`model_validation` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`model_validation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`model_validation` SET TAGS ('dbx_subdomain' = 'limit_governance');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `model_validation_id` SET TAGS ('dbx_business_glossary_term' = 'Model Validation ID (MODEL_VALIDATION_ID)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Performed By User ID (PERFORMED_BY_USER_ID)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Job Run User ID (JOB_RUN_USER_ID)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `model_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Performed By User ID (PERFORMED_BY_USER_ID)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `model_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `model_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Model ID (MODEL_ID)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `model_job_run_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Job Run User ID (JOB_RUN_USER_ID)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `model_job_run_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `model_job_run_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `validation_run_id` SET TAGS ('dbx_business_glossary_term' = 'Validation Run Identifier (VALIDATION_RUN_ID)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp (CREATED_TIMESTAMP)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `environment` SET TAGS ('dbx_business_glossary_term' = 'Validation Environment (ENVIRONMENT)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `environment` SET TAGS ('dbx_value_regex' = 'prod|test|dev');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_cluster_code` SET TAGS ('dbx_business_glossary_term' = 'Job Run Cluster ID (JOB_RUN_CLUSTER_ID)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_cluster_config_hash` SET TAGS ('dbx_business_glossary_term' = 'Job Run Cluster Config Hash (JOB_RUN_CLUSTER_CONFIG_HASH)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_cluster_config_json` SET TAGS ('dbx_business_glossary_term' = 'Job Run Cluster Config JSON (JOB_RUN_CLUSTER_CONFIG_JSON)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_cluster_config_properties` SET TAGS ('dbx_business_glossary_term' = 'Job Run Cluster Config Properties (JOB_RUN_CLUSTER_CONFIG_PROPERTIES)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_cluster_config_properties_hash` SET TAGS ('dbx_business_glossary_term' = 'Job Run Cluster Config Properties Hash (JOB_RUN_CLUSTER_CONFIG_PROPERTIES_HASH)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_cluster_config_properties_json` SET TAGS ('dbx_business_glossary_term' = 'Job Run Cluster Config Properties JSON (JOB_RUN_CLUSTER_CONFIG_PROPERTIES_JSON)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_cluster_name` SET TAGS ('dbx_business_glossary_term' = 'Job Run Cluster Name (JOB_RUN_CLUSTER_NAME)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_cluster_type` SET TAGS ('dbx_business_glossary_term' = 'Job Run Cluster Type (JOB_RUN_CLUSTER_TYPE)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_cluster_type` SET TAGS ('dbx_value_regex' = 'spark|databricks|k8s');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_cluster_version` SET TAGS ('dbx_business_glossary_term' = 'Job Run Cluster Version (JOB_RUN_CLUSTER_VERSION)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_code` SET TAGS ('dbx_business_glossary_term' = 'Job Run ID (JOB_RUN_ID)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_end_time` SET TAGS ('dbx_business_glossary_term' = 'Job Run End Time (JOB_RUN_END_TIME)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_error` SET TAGS ('dbx_business_glossary_term' = 'Job Run Error (JOB_RUN_ERROR)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_log_url` SET TAGS ('dbx_business_glossary_term' = 'Job Run Log URL (JOB_RUN_LOG_URL)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_parameters_hash` SET TAGS ('dbx_business_glossary_term' = 'Job Run Parameters Hash (JOB_RUN_PARAMETERS_HASH)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_parameters_json` SET TAGS ('dbx_business_glossary_term' = 'Job Run Parameters JSON (JOB_RUN_PARAMETERS_JSON)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_start_time` SET TAGS ('dbx_business_glossary_term' = 'Job Run Start Time (JOB_RUN_START_TIME)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_status` SET TAGS ('dbx_business_glossary_term' = 'Job Run Status (JOB_RUN_STATUS)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_status` SET TAGS ('dbx_value_regex' = 'running|completed|failed|cancelled');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `job_run_user` SET TAGS ('dbx_business_glossary_term' = 'Job Run User (JOB_RUN_USER)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `model_validation_status` SET TAGS ('dbx_business_glossary_term' = 'Validation Status (STATUS)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `model_validation_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|failed|archived');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Validation Notes (NOTES)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `platform` SET TAGS ('dbx_business_glossary_term' = 'Validation Platform (PLATFORM)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `risk_model_version` SET TAGS ('dbx_business_glossary_term' = 'Risk Model Version (RISK_MODEL_VERSION)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp (UPDATED_TIMESTAMP)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `validation_date` SET TAGS ('dbx_business_glossary_term' = 'Validation Date (VALIDATION_DATE)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `validation_duration_seconds` SET TAGS ('dbx_business_glossary_term' = 'Validation Duration Seconds (VALIDATION_DURATION_SECONDS)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `validation_end_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Validation End Timestamp (VALIDATION_END_TIMESTAMP)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `validation_engine` SET TAGS ('dbx_business_glossary_term' = 'Validation Engine (VALIDATION_ENGINE)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `validation_engine_version` SET TAGS ('dbx_business_glossary_term' = 'Validation Engine Version (VALIDATION_ENGINE_VERSION)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `validation_outcome` SET TAGS ('dbx_business_glossary_term' = 'Validation Outcome (VALIDATION_OUTCOME)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `validation_outcome` SET TAGS ('dbx_value_regex' = 'pass|fail|warning');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `validation_parameters_hash` SET TAGS ('dbx_business_glossary_term' = 'Validation Parameters Hash (VALIDATION_PARAMETERS_HASH)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `validation_parameters_json` SET TAGS ('dbx_business_glossary_term' = 'Validation Parameters JSON (VALIDATION_PARAMETERS_JSON)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `validation_start_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Validation Start Timestamp (VALIDATION_START_TIMESTAMP)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `validation_type` SET TAGS ('dbx_business_glossary_term' = 'Validation Type (VALIDATION_TYPE)');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `validation_type` SET TAGS ('dbx_value_regex' = 'initial|periodic|backtest|benchmarking');
ALTER TABLE `asset_management`.`risk`.`model_validation` ALTER COLUMN `validation_version` SET TAGS ('dbx_business_glossary_term' = 'Validation Version (VALIDATION_VERSION)');
ALTER TABLE `asset_management`.`risk`.`scenario_requirement` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`risk`.`scenario_requirement` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`scenario_requirement` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`scenario_requirement` SET TAGS ('dbx_subdomain' = 'stress_testing');
ALTER TABLE `asset_management`.`risk`.`scenario_requirement` SET TAGS ('dbx_association_edges' = 'risk.stress_scenario,compliance.obligation');
ALTER TABLE `asset_management`.`risk`.`scenario_requirement` ALTER COLUMN `scenario_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Scenario Requirement ID');
ALTER TABLE `asset_management`.`risk`.`scenario_requirement` ALTER COLUMN `applicability_status` SET TAGS ('dbx_business_glossary_term' = 'Scenario Applicability Status');
ALTER TABLE `asset_management`.`risk`.`scenario_requirement` ALTER COLUMN `compliance_deadline` SET TAGS ('dbx_business_glossary_term' = 'Compliance Deadline');
ALTER TABLE `asset_management`.`risk`.`scenario_requirement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`risk`.`scenario_requirement` ALTER COLUMN `last_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Last Execution Date');
ALTER TABLE `asset_management`.`risk`.`scenario_requirement` ALTER COLUMN `next_required_date` SET TAGS ('dbx_business_glossary_term' = 'Next Required Date');
ALTER TABLE `asset_management`.`risk`.`scenario_requirement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`risk`.`calculation_run` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`risk`.`calculation_run` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`calculation_run` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`calculation_run` SET TAGS ('dbx_subdomain' = 'limit_governance');
ALTER TABLE `asset_management`.`risk`.`calculation_run` ALTER COLUMN `calculation_run_id` SET TAGS ('dbx_business_glossary_term' = 'Calculation Run Identifier');
ALTER TABLE `asset_management`.`risk`.`stress_test_run` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`risk`.`stress_test_run` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`stress_test_run` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`stress_test_run` SET TAGS ('dbx_subdomain' = 'stress_testing');
ALTER TABLE `asset_management`.`risk`.`stress_test_run` ALTER COLUMN `stress_test_run_id` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Run Identifier');
ALTER TABLE `asset_management`.`risk`.`validation_run` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`risk`.`validation_run` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`validation_run` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`validation_run` SET TAGS ('dbx_subdomain' = 'limit_governance');
ALTER TABLE `asset_management`.`risk`.`validation_run` ALTER COLUMN `validation_run_id` SET TAGS ('dbx_business_glossary_term' = 'Validation Run Identifier');
ALTER TABLE `asset_management`.`risk`.`factor_ic_observation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`factor_ic_observation` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`factor_ic_observation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`factor_ic_observation` SET TAGS ('dbx_subdomain' = 'exposure_analytics');
ALTER TABLE `asset_management`.`risk`.`factor_signal_prediction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`risk`.`factor_signal_prediction` SET TAGS ('dbx_domain' = 'risk');
ALTER TABLE `asset_management`.`risk`.`factor_signal_prediction` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`risk`.`factor_signal_prediction` SET TAGS ('dbx_subdomain' = 'stress_testing');
