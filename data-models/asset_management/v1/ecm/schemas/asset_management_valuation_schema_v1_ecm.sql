-- Schema for Domain: valuation | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:30

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`valuation` COMMENT 'Domain for asset valuation and NAV determination across liquid and illiquid asset classes. Owns mark-to-market (MTM) pricing, DCF models, WACC calculations, fair value hierarchies (Level 1/2/3), NAV/GAV computations, independent valuation agent';
ALTER SCHEMA `asset_management`.`valuation` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `asset_management`.`valuation` SET TAGS ('dbx_domain' = 'valuation');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`valuation`.`valuation_asset_valuation` (
    `valuation_asset_valuation_id` BIGINT COMMENT 'Unique identifier for the valuation record of an investment asset.',
    `actor_id` BIGINT COMMENT 'Identifier of the valuation agent or firm.',
    `asset_id` BIGINT COMMENT 'System-generated identifier for the underlying investment asset.',
    `credit_rating_id` BIGINT COMMENT 'Foreign key linking to risk.credit_rating. Business justification: Asset valuations require credit ratings for IFRS 9 impairment assessment and fair value hierarchy classification.',
    `employee_id` BIGINT COMMENT 'Identifier of the manager responsible for the portfolio.',
    `fair_value_hierarchy_id` BIGINT COMMENT 'Foreign key linking to valuation.fair_value_hierarchy. Business justification: Valuation records need to reference the fair value hierarchy level for IFRS 13 compliance.',
    `input_id` BIGINT COMMENT 'Foreign key linking to valuation.input. Business justification: Valuation models use quantitative inputs; linking to input table centralizes input data.',
    `issuer_esg_rating_id` BIGINT COMMENT 'Foreign key linking to esg.issuer_esg_rating. Business justification: SFDR/TCFD compliance requires ESG integration in asset valuations. Pension funds must document ESG scores affecting fair value for regulatory reporting and investment committee reviews.',
    `portfolio_id` BIGINT COMMENT 'Identifier of the portfolio containing the asset.',
    `valuation_cycle_id` BIGINT COMMENT 'Identifier of the valuation cycle or reporting period.',
    `valuation_fx_rate_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_fx_rate. Business justification: Valuation may involve foreign currency; linking to FX rate provides conversion context.',
    `valuation_policy_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_policy. Business justification: Each valuation is governed by a policy; linking to policy provides governance context.',
    `valuation_yield_curve_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_yield_curve. Business justification: Valuation calculations use a yield curve; linking provides the curve reference.',
    `asset_category` STRING COMMENT 'Category grouping for the asset (e.g., real estate, natural resources).',
    `asset_class` STRING COMMENT 'Asset class within the broader type (e.g., public equity, private equity).',
    `asset_currency` STRING COMMENT 'ISO 4217 currency code for the asset valuation.. Valid values are `^[A-Z]{3}$`',
    `asset_isin` STRING COMMENT 'International Securities Identification Number for the asset.. Valid values are `^[A-Z]{2}[0-9A-Z]{9}[0-9]$`',
    `asset_name` STRING COMMENT 'Human‑readable name of the investment asset.',
    `asset_sector` STRING COMMENT 'Economic sector of the asset (e.g., technology, energy).',
    `asset_subclass` STRING COMMENT 'More granular subclass of the asset (e.g., growth equity, infrastructure).',
    `asset_type` STRING COMMENT 'Broad classification of the asset (e.g., equity, fixed income, private equity).',
    `book_value` DECIMAL(38,10) COMMENT 'Accounting book value of the asset.',
    `fair_value` DECIMAL(38,10) COMMENT 'Fair value of the asset as determined by the valuation method.',
    `gav` DECIMAL(38,10) COMMENT 'Gross asset value of the portfolio at the valuation date.',
    `market_value` DECIMAL(38,10) COMMENT 'Market price of the asset if available.',
    `nav` DECIMAL(38,10) COMMENT 'Net asset value of the portfolio at the valuation date.',
    `portfolio_type` STRING COMMENT 'Classification of the portfolio (e.g., public, private, fund of funds).. Valid values are `public|private|fund_of_funds|hedge_fund`',
    `valuation_comments` STRING COMMENT 'Free‑text comments or notes about the valuation.',
    `valuation_cycle_cycle_number` BIGINT COMMENT 'Sequential number of the cycle within the year.',
    `valuation_cycle_cycle_year` BIGINT COMMENT 'Calendar year of the valuation cycle.',
    `valuation_cycle_end_date` DATE COMMENT 'End date of the valuation cycle.',
    `valuation_cycle_frequency` STRING COMMENT 'Frequency of the valuation cycle.. Valid values are `daily|weekly|monthly|quarterly|annual`',
    `valuation_cycle_start_date` DATE COMMENT 'Start date of the valuation cycle.',
    `valuation_cycle_status` STRING COMMENT 'Current status of the valuation cycle.. Valid values are `scheduled|running|completed|cancelled`',
    `valuation_date` DATE COMMENT 'Date on which the valuation was performed.',
    `valuation_document_code` BIGINT COMMENT 'Identifier of the supporting valuation document.',
    `valuation_document_date` DATE COMMENT 'Date the valuation document was created.',
    `valuation_document_hash` STRING COMMENT 'Cryptographic hash of the valuation document for integrity.',
    `valuation_document_signed_at` TIMESTAMP COMMENT 'Timestamp when the valuation document was signed.',
    `valuation_document_signed_by` STRING COMMENT 'Name of the person who signed the valuation document.',
    `valuation_document_status` STRING COMMENT 'Current status of the valuation document.. Valid values are `draft|final|archived`',
    `valuation_document_type` STRING COMMENT 'File format of the valuation document.. Valid values are `pdf|docx|xlsx|txt`',
    `valuation_document_url` STRING COMMENT 'URL to the valuation document.',
    `valuation_document_version` STRING COMMENT 'Version identifier of the valuation document.',
    `valuation_engine` STRING COMMENT 'Software or system used to compute the valuation.. Valid values are `internal|external|third_party`',
    `valuation_method` STRING COMMENT 'Methodology used to determine the asset value.. Valid values are `DCF|market_price|appraisal|fair_value_hierarchy`',
    `valuation_reason` STRING COMMENT 'Reason for performing the valuation (e.g., periodic, event‑driven).',
    `valuation_status` STRING COMMENT 'Current status of the valuation record.. Valid values are `active|archived|pending|rejected`',
    `valuation_time` TIMESTAMP COMMENT 'Exact timestamp of the valuation event.',
    CONSTRAINT pk_valuation_asset_valuation PRIMARY KEY(`valuation_asset_valuation_id`)
) COMMENT 'Core master record and authoritative SSOT for the concluded fair value of an individual investment asset at a specific valuation date, across ALL asset classes (public equity, private equity, infrastructure, real estate, natural resources, credit).';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`valuation_nav_record` (
    `valuation_nav_record_id` BIGINT COMMENT 'Unique identifier for the valuation NAV record.',
    `regulatory_filing_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_filing. Business justification: NAV records must be filed with regulators (Form N-PORT, AIFMD Annex IV). Pension funds submit periodic NAV reports to regulatory authorities.',
    `valuation_cycle_id` BIGINT COMMENT 'Identifier for the valuation cycle.',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the record was first created.',
    `currency_code` STRING COMMENT 'ISO 4217 currency code for NAV amounts.. Valid values are `^[A-Z]{3}$`',
    `fund_code` STRING COMMENT 'Unique code identifying the fund or portfolio.. Valid values are `^[A-Z0-9]{1,10}$`',
    `fund_name` STRING COMMENT 'Human-readable name of the fund or portfolio.',
    `nav_per_unit` DECIMAL(38,2) COMMENT 'NAV divided by the number of units outstanding.',
    `net_asset_value` DECIMAL(38,2) COMMENT 'Net asset value after subtracting liabilities.',
    `number_of_units` DECIMAL(38,2) COMMENT 'Total number of units or shares outstanding.',
    `record_audit_created` TIMESTAMP COMMENT 'Audit timestamp of record creation.',
    `record_audit_updated` TIMESTAMP COMMENT 'Audit timestamp of last record update.',
    `remarks` STRING COMMENT 'Additional notes or comments about the valuation.',
    `total_gross_asset_value` DECIMAL(38,2) COMMENT 'Sum of all asset values before liabilities.',
    `total_liabilities` DECIMAL(38,2) COMMENT 'Sum of all liabilities associated with the fund.',
    `updated_at` TIMESTAMP COMMENT 'Timestamp of the most recent update to the record.',
    `valuation_cycle_frequency` STRING COMMENT 'Frequency at which valuations occur.. Valid values are `daily|weekly|monthly|quarterly|annual`',
    `valuation_date` DATE COMMENT 'Date on which the NAV was calculated.',
    `valuation_method` STRING COMMENT 'Method used to compute the NAV (e.g., MTM, DCF).. Valid values are `MTM|DCF|WACC|FV_L1|FV_L2|FV_L3`',
    `valuation_reference` STRING COMMENT 'Reference code used to identify the valuation instance.. Valid values are `^[A-Z0-9]{1,20}$`',
    `valuation_source_code` STRING COMMENT 'Identifier of the source system or process.',
    `valuation_source_description` STRING COMMENT 'Description of the source system or process.',
    `valuation_source_name` STRING COMMENT 'Name of the source system or process.',
    `valuation_status` STRING COMMENT 'Current status of the valuation process.. Valid values are `pending|completed|approved|rejected|error`',
    CONSTRAINT pk_valuation_nav_record PRIMARY KEY(`valuation_nav_record_id`)
) COMMENT 'Authoritative NAV (Net Asset Value) and GAV (Gross Asset Value) record for a fund, portfolio, or investment vehicle at a specific valuation date. Captures total gross asset value, total liabilities, net asset value, NAV per unit/share, number of units';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`cycle` (
    `cycle_id` BIGINT COMMENT 'Unique identifier for the valuation cycle.',
    `obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: Valuation cycles must satisfy regulatory obligations. Pension funds link each cycle to the specific compliance obligation it fulfills for deadline tracking.',
    `regulatory_calendar_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_calendar. Business justification: Valuation cycles must align with regulatory filing deadlines. Pension funds coordinate quarter-end valuations with compliance calendars to meet filing requirements.',
    `approval_by` STRING COMMENT 'User or system that approved the cycle.',
    `approval_comments` STRING COMMENT 'Comments provided during approval.',
    `approval_date` TIMESTAMP COMMENT 'Timestamp when the cycle was approved.',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the cycle record was created.',
    `cycle_status` STRING COMMENT 'Current lifecycle state of the cycle.. Valid values are `open|in-progress|completed|cancelled|archived`',
    `cycle_type` STRING COMMENT 'Frequency of the cycle: monthly, quarterly, annual, or custom.. Valid values are `monthly|quarterly|annual|custom`',
    `cycle_description` STRING COMMENT 'Free‑form description of the cycle.',
    `end_date` DATE COMMENT 'Date the cycle ends.',
    `identifier` STRING COMMENT 'Human‑readable identifier for the cycle, e.g., "FY23 Q1".',
    `is_archived` BOOLEAN COMMENT 'Indicates if the cycle has been archived.',
    `is_finalized` BOOLEAN COMMENT 'Indicates if the cycle has been finalized.',
    `is_locked` BOOLEAN COMMENT 'Indicates if the cycle is locked for editing.',
    `number` BIGINT COMMENT 'Sequential number of the cycle within the portfolio.',
    `number_month` BIGINT COMMENT 'Month component of the cycle number.',
    `number_quarter` BIGINT COMMENT 'Quarter component of the cycle number.',
    `number_year` BIGINT COMMENT 'Year component of the cycle number.',
    `number_year_month` STRING COMMENT 'Year and month concatenated, e.g., "2023-04".',
    `number_year_month_day` DATE COMMENT 'Full date of the cycle number.',
    `number_year_quarter` STRING COMMENT 'Year and quarter concatenated, e.g., "2023-Q2".',
    `number_year_quarter_day` DATE COMMENT 'Date of the cycle within the quarter.',
    `number_year_quarter_month` STRING COMMENT 'Year, quarter, and month, e.g., "2023-Q2-04".',
    `number_year_quarter_month_day` DATE COMMENT 'Full date of the cycle within the quarter and month.',
    `number_year_quarter_month_day_time` TIMESTAMP COMMENT 'Full timestamp of the cycle within the quarter and month.',
    `number_year_quarter_month_day_time_millis` BIGINT COMMENT 'Milliseconds component of the cycle timestamp.',
    `number_year_quarter_month_day_time_nanos` BIGINT COMMENT 'Nanoseconds component of the cycle timestamp.',
    `number_year_quarter_month_day_time_seconds` BIGINT COMMENT 'Seconds component of the cycle timestamp.',
    `start_date` DATE COMMENT 'Date the cycle begins.',
    `updated_at` TIMESTAMP COMMENT 'Timestamp of the last update to the cycle.',
    `updated_by` STRING COMMENT 'User or system that performed the last update.',
    `valuation_reference_date` DATE COMMENT 'Date used for mark‑to‑market valuation.',
    `version` BIGINT COMMENT 'Version number for change tracking.',
    `created_by` STRING COMMENT 'User or system that created the cycle.',
    CONSTRAINT pk_cycle PRIMARY KEY(`cycle_id`)
) COMMENT 'Master record defining a scheduled valuation cycle or reporting period for a portfolio, fund, or asset class. Captures cycle type (monthly, quarterly, annual), cycle start and end dates, valuation reference date, cycle status (open, in-progress';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`dcf_model` (
    `dcf_model_id` BIGINT COMMENT 'Unique identifier for the DCF model record.',
    `climate_scenario_id` BIGINT COMMENT 'Foreign key linking to esg.climate_scenario. Business justification: TCFD requires climate scenario analysis in valuations. DCF models must stress-test cash flows against temperature pathways (1.5°C, 2°C scenarios).',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: DCF valuations must be stress-tested under base/upside/downside economic scenarios per pension fund risk management and regulatory requirements.',
    `fdd_assessment_id` BIGINT COMMENT 'Foreign key linking to diligence.fdd_assessment. Business justification: DCF models incorporate normalized EBITDA, QoE adjustments, and working capital peg from FDD assessment.',
    `macro_model_id` BIGINT COMMENT 'Foreign key linking to research.macro_model. Business justification: DCF models for private assets consume macroeconomic projections (GDP, inflation, discount rates) from research macro models.',
    `model_created_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: DCF models require creator tracking for model governance and audit. model_created_by_user is text; proper FK needed for employee accountability in valuation model management.',
    `model_portfolio_id` BIGINT COMMENT 'Identifier of the portfolio the model is associated with.',
    `stress_scenario_id` BIGINT COMMENT 'Foreign key linking to risk.stress_scenario. Business justification: DCF models for private assets must be stress-tested under regulatory scenarios (climate, market crash).',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Identifier of the asset the model is applied to.',
    `model_asset_code` BIGINT COMMENT 'Identifier of the asset the model is applied to.',
    `model_author` STRING COMMENT 'Name of the person who created the model.',
    `model_code` STRING COMMENT 'Alphanumeric code identifying the DCF model.. Valid values are `^[A-Z0-9]{3,20}$`',
    `model_confidence_level` STRING COMMENT 'Confidence level of the model outputs.. Valid values are `High|Medium|Low`',
    `model_created_by_user` STRING COMMENT 'User who created the model.',
    `model_creation_date` DATE COMMENT 'Date the model was first created.',
    `model_currency` STRING COMMENT 'Currency of the valuation amount. [ENUM-REF-CANDIDATE: USD|EUR|GBP|JPY|CHF|CAD|AUD — promote to reference product]',
    `model_description` STRING COMMENT 'Detailed description of the DCF model.',
    `model_discount_rate` DECIMAL(5,4) COMMENT 'Discount rate applied to future cash flows.',
    `model_effective_from` DATE COMMENT 'Date the model becomes effective.',
    `model_effective_until` DATE COMMENT 'Date the model ceases to be effective.',
    `model_external_reference` STRING COMMENT 'External reference identifier for the model.',
    `model_file_path` STRING COMMENT 'Filesystem path to the model file.',
    `model_hash` STRING COMMENT 'Hash of the model file for integrity.',
    `model_is_active` BOOLEAN COMMENT 'Flag indicating if the model is currently active.',
    `model_is_approved` BOOLEAN COMMENT 'Flag indicating if the model has been approved.',
    `model_is_archived` BOOLEAN COMMENT 'Flag indicating if the model has been archived.',
    `model_is_draft` BOOLEAN COMMENT 'Flag indicating if the model is in draft state.',
    `model_is_validated` BOOLEAN COMMENT 'Flag indicating if the model has been validated.',
    `model_last_updated` DATE COMMENT 'Date the model was last updated.',
    `model_name` STRING COMMENT 'Human-readable name of the DCF model.',
    `model_notes` STRING COMMENT 'Additional notes or comments about the model.',
    `model_projected_free_cash_flow` DECIMAL(18,2) COMMENT 'Projected free cash flow for each year.',
    `model_projection_horizon_years` BIGINT COMMENT 'Number of years the model projects cash flows.',
    `model_risk_category` STRING COMMENT 'Category of risk associated with the model.. Valid values are `Credit|Liquidity|Market|Operational|Legal`',
    `model_risk_rating` STRING COMMENT 'Risk rating assigned to the model.. Valid values are `A|B|C|D|E`',
    `model_source_system` STRING COMMENT 'Originating system of the model data. [ENUM-REF-CANDIDATE: SimCorp|BlackRock|Bloomberg|StateStreet|eFront|DealCloud|MSCI|CharlesRiver|Oracle|SAP|Diligent|Preqin|PitchBook|FactSet — promote to reference product]',
    `model_status` STRING COMMENT 'Current lifecycle status of the DCF model.. Valid values are `Draft|Active|Archived|Deprecated`',
    `model_terminal_growth_rate` DECIMAL(5,4) COMMENT 'Assumed perpetual growth rate after projection horizon.',
    `model_termination_date` DATE COMMENT 'Date the model was terminated.',
    `model_termination_reason` STRING COMMENT 'Reason for terminating the model.',
    `model_type` STRING COMMENT 'Category of the model (e.g., Equity, Debt, Real Estate). [ENUM-REF-CANDIDATE: Equity|Debt|RealEstate|Infrastructure|PrivateEquity|Credit|Portfolio — promote to reference product]',
    `model_updated_by_user` STRING COMMENT 'User who last updated the model.',
    `model_valuation_amount` DECIMAL(18,2) COMMENT 'Valuation amount derived from the DCF model.',
    `model_valuation_date` DATE COMMENT 'Date on which the valuation was performed.',
    `model_valuation_method` STRING COMMENT 'Method used to derive the valuation.. Valid values are `DCF|NAV|MarketPrice|FairValue`',
    `model_valuation_notes` STRING COMMENT 'Additional notes on the valuation.',
    `model_valuation_source` STRING COMMENT 'Source of the valuation data.. Valid values are `Internal|External|ThirdParty`',
    `model_version` STRING COMMENT 'Version identifier of the DCF model.',
    `model_wacc` DECIMAL(5,4) COMMENT 'Weighted average cost of capital used in discounting.',
    CONSTRAINT pk_dcf_model PRIMARY KEY(`dcf_model_id`)
) COMMENT 'Proprietary Discounted Cash Flow (DCF) model record for an investment asset or portfolio company. Stores model version, projection horizon (years), terminal growth rate, WACC (Weighted Average Cost of Capital), discount rate, projected free cash flow';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`wacc_calculation` (
    `wacc_calculation_id` BIGINT COMMENT 'Unique identifier for the WACC calculation record.',
    `fee_calculation_run_id` BIGINT COMMENT 'Unique code for the specific calculation run instance.',
    `capital_market_assumption_id` BIGINT COMMENT 'Foreign key linking to research.capital_market_assumption. Business justification: WACC calculations directly consume capital market assumptions (risk-free rate, equity risk premium, cost of debt).',
    `climate_scenario_id` BIGINT COMMENT 'Foreign key linking to esg.climate_scenario. Business justification: Climate risk premiums affect cost of capital. WACC calculations must incorporate transition risk severity from climate scenarios.',
    `dcf_model_id` BIGINT COMMENT 'Foreign key linking to valuation.dcf_model. Business justification: WACC calculations are used as inputs to DCF models. A DCF model references a specific WACC calculation for its discount rate.',
    `portfolio_id` BIGINT COMMENT 'Identifier of the portfolio containing the asset.',
    `valuation_cycle_id` BIGINT COMMENT 'Identifier of the valuation cycle during which the calculation was performed.',
    `asset_code` BIGINT COMMENT 'Identifier of the asset for which the WACC was calculated.',
    `calculation_currency` STRING COMMENT 'ISO 4217 currency code for the calculation.. Valid values are `^[A-Z]{3}$`',
    `calculation_end_timestamp` TIMESTAMP COMMENT 'Timestamp when the calculation finished processing.',
    `calculation_method` STRING COMMENT 'Methodology used for the WACC calculation.. Valid values are `DCF|CAPM|WACC_MODEL`',
    `calculation_model_version` STRING COMMENT 'Version identifier of the calculation model.',
    `calculation_notes` STRING COMMENT 'Free-text notes or comments about the calculation.',
    `calculation_source` STRING COMMENT 'System or source that performed the calculation.. Valid values are `SimCorp|Aladdin|Custom`',
    `calculation_start_timestamp` TIMESTAMP COMMENT 'Timestamp when the calculation started processing.',
    `calculation_status` STRING COMMENT 'Current lifecycle status of the calculation process.. Valid values are `pending|running|completed|failed`',
    `calculation_timestamp` TIMESTAMP COMMENT 'Timestamp when the calculation was executed.',
    `cost_of_debt_rate` DECIMAL(10,6) COMMENT 'Cost of debt component of the WACC.',
    `cost_of_equity_rate` DECIMAL(10,6) COMMENT 'Cost of equity component of the WACC.',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the record was first created in the system.',
    `debt_weight` DECIMAL(5,4) COMMENT 'Proportion of debt in the capital structure.',
    `equity_weight` DECIMAL(5,4) COMMENT 'Proportion of equity in the capital structure.',
    `record_audit_created` TIMESTAMP COMMENT 'Audit timestamp for record creation.',
    `record_audit_updated` TIMESTAMP COMMENT 'Audit timestamp for record update.',
    `tax_rate` DECIMAL(5,4) COMMENT 'Effective tax rate applied to the calculation.',
    `updated_at` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `valuation_cycle_frequency` STRING COMMENT 'Frequency of the valuation cycle.. Valid values are `daily|weekly|monthly|quarterly|annual`',
    `valuation_source_code` BIGINT COMMENT 'Identifier of the source used for valuation data.',
    `valuation_source_description` STRING COMMENT 'Description of the valuation source.',
    `valuation_source_name` STRING COMMENT 'Name of the valuation source.',
    `wacc_rate` DECIMAL(10,6) COMMENT 'Weighted average cost of capital expressed as a percentage.',
    CONSTRAINT pk_wacc_calculation PRIMARY KEY(`wacc_calculation_id`)
) COMMENT 'Record of a WACC (Weighted Average Cost of Capital) calculation performed for a specific asset, portfolio company, or investment vehicle at a point in time.';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`fair_value_hierarchy` (
    `fair_value_hierarchy_id` BIGINT COMMENT 'Primary key for the fair value hierarchy classification record.',
    `hierarchy_parent_fair_value_hierarchy_id` BIGINT COMMENT 'Reference to a parent hierarchy level for nested structures.',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the record was first created.',
    `fair_value_hierarchy_description` STRING COMMENT 'Detailed description of the hierarchy level and its application.',
    `effective_from` DATE COMMENT 'Date when the hierarchy level becomes effective.',
    `effective_until` DATE COMMENT 'Date when the hierarchy level ceases to be effective.',
    `fair_value_hierarchy_status` STRING COMMENT 'Current operational status of the hierarchy record.. Valid values are `active|inactive|deprecated`',
    `hierarchy_code` STRING COMMENT 'Unique alphanumeric code identifying the hierarchy level.. Valid values are `^[A-Z0-9]{1,10}$`',
    `hierarchy_level` BIGINT COMMENT 'Numeric indicator of the fair value hierarchy level (1, 2, or 3).',
    `hierarchy_name` STRING COMMENT 'Human‑readable name of the hierarchy level.',
    `hierarchy_order` BIGINT COMMENT 'Ordering of hierarchy levels within a list.',
    `hierarchy_path` STRING COMMENT 'Delimited path representing the hierarchy lineage.',
    `hierarchy_type` STRING COMMENT 'Descriptive type of the hierarchy level as defined by IFRS 13.. Valid values are `Level 1|Level 2|Level 3`',
    `is_default` BOOLEAN COMMENT 'Flag indicating if this level is the default selection.',
    `notes` STRING COMMENT 'Additional remarks or context for the hierarchy level.',
    `source_system_code` STRING COMMENT 'Identifier of the record in the source system.',
    `source_system_version` STRING COMMENT 'Version of the source system record.',
    `updated_at` TIMESTAMP COMMENT 'Timestamp of the most recent update to the record.',
    `version` BIGINT COMMENT 'Version number of the hierarchy record for change tracking.',
    CONSTRAINT pk_fair_value_hierarchy PRIMARY KEY(`fair_value_hierarchy_id`)
) COMMENT 'Reference classification record defining the IFRS 13 / ASC 820 fair value hierarchy levels applied to asset valuations. Captures hierarchy level (Level 1 — quoted prices in active markets, Level 2 — observable inputs, Level 3 — unobservable/model-based';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`indep_valuation_engagement` (
    `indep_valuation_engagement_id` BIGINT COMMENT 'Globally unique identifier for the independent valuation engagement record.',
    `actor_id` BIGINT COMMENT 'Identifier of the independent valuation agent.',
    `manager_mandate_id` BIGINT COMMENT 'Foreign key linking to manager.manager_mandate. Business justification: Mandate/LPA terms often require independent third-party valuations for illiquid private assets annually.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Independent valuations are mandated by specific regulators (FCA, SEC). Pension funds track which regulatory authority requires the independent valuation engagement.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_asset_valuation. Business justification: An independent engagement is performed for a specific asset valuation; linking provides traceability.',
    `engagement_agent_address` STRING COMMENT 'Physical address of the agents office.',
    `engagement_agent_contact` STRING COMMENT 'Primary contact person for the agent.',
    `engagement_agent_email` STRING COMMENT 'Primary email address for the agent.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `engagement_agent_legal_entity_address` STRING COMMENT 'Physical address of the legal entity.',
    `engagement_agent_legal_entity_code` BIGINT COMMENT 'Identifier of the agents legal entity.',
    `engagement_agent_legal_entity_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the legal entity.. Valid values are `^[A-Z]{3}$`',
    `engagement_agent_legal_entity_email` STRING COMMENT 'Email address of the legal entity.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `engagement_agent_legal_entity_name` STRING COMMENT 'Legal name of the agents entity.',
    `engagement_agent_legal_entity_phone` STRING COMMENT 'Phone number of the legal entity.. Valid values are `^[+][0-9]{1,3}[0-9]{7,15}$`',
    `engagement_agent_legal_entity_type` STRING COMMENT 'Type of the legal entity.. Valid values are `corporation|partnership|sole_proprietorship`',
    `engagement_agent_phone` STRING COMMENT 'Primary phone number for the agent.. Valid values are `^[+][0-9]{1,3}[0-9]{7,15}$`',
    `engagement_agent_tax_number` STRING COMMENT 'Tax identification number of the legal entity.. Valid values are `^[A-Z0-9]{5,20}$`',
    `engagement_agent_type` STRING COMMENT 'Classification of the agent: independent, firm, or consulting.. Valid values are `independent|firm|consulting`',
    `engagement_description` STRING COMMENT 'Brief description of the engagement purpose and scope.',
    `engagement_end_date` DATE COMMENT 'Date when the engagement terminates or expires.',
    `engagement_fee` DECIMAL(18,2) COMMENT 'Total fee charged for the engagement in the base currency.',
    `engagement_fee_currency` STRING COMMENT 'ISO 4217 currency code for the engagement fee.. Valid values are `^[A-Z]{3}$`',
    `engagement_fee_due_amount` DECIMAL(18,2) COMMENT 'Amount due for the fee on the due date.',
    `engagement_fee_due_currency` STRING COMMENT 'Currency code for the fee due amount.. Valid values are `^[A-Z]{3}$`',
    `engagement_fee_due_date` DATE COMMENT 'Date when the fee is due for payment.',
    `engagement_fee_paid_amount` DECIMAL(18,2) COMMENT 'Amount paid for the fee.',
    `engagement_fee_paid_currency` STRING COMMENT 'Currency code for the paid fee amount.. Valid values are `^[A-Z]{3}$`',
    `engagement_fee_paid_date` DATE COMMENT 'Date when the fee was actually paid.',
    `engagement_fee_rate` DECIMAL(18,6) COMMENT 'Rate applied to the fee calculation, if applicable.',
    `engagement_fee_rate_unit` STRING COMMENT 'Unit of measure for the fee rate.. Valid values are `per_hour|per_day|per_month`',
    `engagement_fee_schedule` STRING COMMENT 'Description of the fee payment schedule.',
    `engagement_fee_type` STRING COMMENT 'Nature of the fee: fixed, hourly, or retainer.. Valid values are `fixed|hourly|retainer`',
    `engagement_name` STRING COMMENT 'Human-readable name of the engagement.',
    `engagement_number` STRING COMMENT 'External reference number assigned to the engagement by the pension fund.. Valid values are `ENG-d{4}-d{4}`',
    `engagement_scope` STRING COMMENT 'High-level description of the assets or portfolio covered by the engagement.',
    `engagement_scope_amount` DECIMAL(18,2) COMMENT 'Monetary value of the scope in the engagements base currency.',
    `engagement_scope_currency` STRING COMMENT 'ISO 4217 currency code for the scope amount.. Valid values are `^[A-Z]{3}$`',
    `engagement_scope_description` STRING COMMENT 'Detailed description of the scope of the engagement.',
    `engagement_scope_type` STRING COMMENT 'Classification of the scope: asset, portfolio, or fund.. Valid values are `asset|portfolio|fund`',
    `engagement_start_date` DATE COMMENT 'Date when the engagement becomes effective.',
    `engagement_status` STRING COMMENT 'Current lifecycle state of the engagement.. Valid values are `active|suspended|terminated|pending`',
    `engagement_status_reason` STRING COMMENT 'Reason for the current engagement status, if applicable.',
    `engagement_type` STRING COMMENT 'Category of the engagement, e.g., valuation, appraisal, or audit.. Valid values are `valuation|appraisal|audit`',
    `record_audit_created` TIMESTAMP COMMENT 'Timestamp when the record was first created.',
    `record_audit_updated` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    CONSTRAINT pk_indep_valuation_engagement PRIMARY KEY(`indep_valuation_engagement_id`)
) COMMENT 'Master record for an engagement with an independent external valuation agent or appraiser (including licensed real estate appraisers) for a specific asset or portfolio.';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`adjustment` (
    `adjustment_id` BIGINT COMMENT 'Unique system-generated identifier for the adjustment record.',
    `audit_finding_id` BIGINT COMMENT 'Foreign key linking to compliance.audit_finding. Business justification: Valuation adjustments often result from audit findings. Pension funds must track which adjustments remediate specific audit observations for regulatory reporting.',
    `cycle_id` BIGINT COMMENT 'Identifier of the valuation cycle associated with the adjustment.',
    `valuation_document_id` BIGINT COMMENT 'Identifier of the supporting document for the adjustment.',
    `rule_breach_id` BIGINT COMMENT 'Foreign key linking to compliance.rule_breach. Business justification: Valuation adjustments may be required to remediate compliance rule breaches. Links corrective valuation actions to the triggering breach for audit trail.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Identifier of the valuation to which this adjustment applies.',
    `adjustment_date` TIMESTAMP COMMENT 'Date and time when the adjustment was applied to the valuation.',
    `adjustment_status` STRING COMMENT 'Current lifecycle state of the adjustment record.. Valid values are `pending|approved|rejected|applied|cancelled`',
    `adjustment_type` STRING COMMENT 'Category of the valuation adjustment applied to the base asset valuation.. Valid values are `liquidity_discount|control_premium|minority_discount|credit_risk_adjustment|fx_translation_adjustment|model_overlay`',
    `amount` DECIMAL(18,4) COMMENT 'Monetary value of the adjustment applied to the valuation.',
    `approved_at` TIMESTAMP COMMENT 'Timestamp when the adjustment was approved by the governance process.',
    `approved_by` BIGINT COMMENT 'Identifier of the user who approved the adjustment.',
    `approved_by_name` STRING COMMENT 'Name of the user who approved the adjustment.',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the adjustment record was first created.',
    `currency` STRING COMMENT 'ISO 4217 currency code for the adjustment amount.',
    `cycle_frequency` STRING COMMENT 'Frequency of the valuation cycle (e.g., monthly, quarterly).',
    `effective_from` DATE COMMENT 'Date from which the adjustment becomes effective.',
    `effective_until` DATE COMMENT 'Date until which the adjustment remains effective.',
    `is_active` BOOLEAN COMMENT 'Flag indicating if the adjustment is currently active.',
    `is_approved` BOOLEAN COMMENT 'Flag indicating if the adjustment has been approved.',
    `is_draft` BOOLEAN COMMENT 'Flag indicating if the adjustment is in draft state.',
    `is_finalized` BOOLEAN COMMENT 'Flag indicating if the adjustment has been finalized.',
    `is_locked` BOOLEAN COMMENT 'Flag indicating if the adjustment record is locked from edits.',
    `reason` STRING COMMENT 'Narrative explanation of why the adjustment was applied.',
    `reference` STRING COMMENT 'Business reference number used to identify the adjustment in external systems.',
    `source_system_code` BIGINT COMMENT 'Identifier of the source system.',
    `source_system_description` STRING COMMENT 'Description of the source system.',
    `source_system_name` STRING COMMENT 'Name of the source system.',
    `source_system_version` STRING COMMENT 'Version of the source system.',
    `updated_at` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the adjustment record.',
    `version` BIGINT COMMENT 'Version number of the adjustment record for change tracking.',
    CONSTRAINT pk_adjustment PRIMARY KEY(`adjustment_id`)
) COMMENT 'Record of a specific valuation adjustment applied to a base asset valuation. Captures adjustment type (liquidity discount, control premium, minority discount, credit risk adjustment, FX translation adjustment, model overlay), adjustment amount, adjustment';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`market_price_snapshot` (
    `market_price_snapshot_id` BIGINT COMMENT 'Unique identifier for the market price snapshot record.',
    `instrument_id` BIGINT COMMENT 'Foreign key linking to trade.instrument. Business justification: Market price snapshots must link to instrument master for price validation, NAV calculation, and best execution analysis.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_asset_valuation. Business justification: Each market price snapshot is for a specific asset; linking to valuation allows correlation of price data.',
    `ask_price` DECIMAL(18,6) COMMENT 'Ask price of the instrument at the snapshot time.',
    `asset_category` STRING COMMENT 'Category of the asset. [ENUM-REF-CANDIDATE: ... — promote to reference product]',
    `asset_class` STRING COMMENT 'Class of the asset (e.g., equity, fixed income). [ENUM-REF-CANDIDATE: equity|fixed_income|real_estate|private_equity|infrastructure|natural_resources|credit|cash — promote to reference product]',
    `asset_currency` STRING COMMENT 'ISO 4217 currency code for the asset.. Valid values are `^[A-Z]{3}$`',
    `asset_sector` STRING COMMENT 'Sector of the asset. [ENUM-REF-CANDIDATE: ... — promote to reference product]',
    `asset_subclass` STRING COMMENT 'Subclass of the asset. [ENUM-REF-CANDIDATE: ... — promote to reference product]',
    `bid_price` DECIMAL(18,6) COMMENT 'Bid price of the instrument at the snapshot time.',
    `closing_price` DECIMAL(18,6) COMMENT 'Closing price of the instrument at the snapshot time.',
    `cusip` STRING COMMENT 'CUSIP identifier for the instrument.. Valid values are `^[A-Z0-9]{9}$`',
    `exchange_code` STRING COMMENT 'Code of the exchange where the instrument trades.',
    `exchange_name` STRING COMMENT 'Name of the exchange where the instrument trades.',
    `high_price` DECIMAL(18,6) COMMENT 'High price of the instrument during the snapshot period.',
    `instrument_type` STRING COMMENT 'Category of the instrument (e.g., equity, bond, derivative). [ENUM-REF-CANDIDATE: equity|bond|derivative|fund|real_estate|private_equity|credit|cash|commodity — promote to reference product]',
    `isin` STRING COMMENT 'International Securities Identification Number for the instrument.. Valid values are `^[A-Z0-9]{12}$`',
    `last_traded_price` DECIMAL(18,6) COMMENT 'Last traded price of the instrument at the snapshot time.',
    `lei` STRING COMMENT 'Legal Entity Identifier for the instrument issuer.. Valid values are `^[A-Z0-9]{20}$`',
    `low_price` DECIMAL(18,6) COMMENT 'Low price of the instrument during the snapshot period.',
    `market` STRING COMMENT 'Market type of the instrument (equity, fixed income, etc.). [ENUM-REF-CANDIDATE: equity|fixed_income|real_estate|private_equity|infrastructure|natural_resources|credit|cash — promote to reference product]',
    `mid_price` DECIMAL(18,6) COMMENT 'Mid price of the instrument at the snapshot time.',
    `open_price` DECIMAL(18,6) COMMENT 'Opening price of the instrument at the snapshot time.',
    `price_source_system` STRING COMMENT 'System that provided the price data. [ENUM-REF-CANDIDATE: Bloomberg|FactSet|Aladdin|State_Street|eFront|DealCloud|MSCI|Charles_River|Oracle|SAP|Diligent|Preqin|PitchBook — promote to reference product]',
    `price_source_system_address` STRING COMMENT 'Contact address for the price source system.',
    `price_source_system_code` STRING COMMENT 'Identifier of the price source system.',
    `price_source_system_contact` STRING COMMENT 'Contact name for the price source system.',
    `price_source_system_country` STRING COMMENT 'ISO 3166 country code of the price source system.. Valid values are `^[A-Z]{3}$`',
    `price_source_system_description` STRING COMMENT 'Description of the price source system.',
    `price_source_system_effective_from` DATE COMMENT 'Date when the price source system became effective.',
    `price_source_system_effective_until` DATE COMMENT 'Date when the price source system ceased to be effective.',
    `price_source_system_email` STRING COMMENT 'Contact email for the price source system.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `price_source_system_license` STRING COMMENT 'License type for the price source system (commercial, subscription, free).. Valid values are `commercial|subscription|free`',
    `price_source_system_license_expiry` DATE COMMENT 'Date when the license for the price source system expires.',
    `price_source_system_notes` STRING COMMENT 'Additional notes about the price source system.',
    `price_source_system_phone` STRING COMMENT 'Contact phone for the price source system.. Valid values are `^[+]?d{1,15}$`',
    `price_source_system_rating` STRING COMMENT 'Rating of the price source system (A|B|C|D|E|F).. Valid values are `A|B|C|D|E|F`',
    `price_source_system_reference` STRING COMMENT 'Reference identifier for the price source system.',
    `price_source_system_status` STRING COMMENT 'Operational status of the price source system (active, inactive, deprecated).. Valid values are `active|inactive|deprecated`',
    `price_source_system_type` STRING COMMENT 'Type of the price source system (DataFeed, API, WebService, Manual).. Valid values are `DataFeed|API|WebService|Manual`',
    `price_source_system_version` STRING COMMENT 'Version of the price source system.',
    `price_source_system_website` STRING COMMENT 'Website URL of the price source system.',
    `price_source_timestamp` TIMESTAMP COMMENT 'Timestamp when the price was captured by the source system.',
    `price_timestamp` TIMESTAMP COMMENT 'Timestamp of the market price snapshot.',
    `sedol` STRING COMMENT 'SEDOL identifier for the instrument.. Valid values are `^[A-Z0-9]{7}$`',
    `trade_count` BIGINT COMMENT 'Number of trades of the instrument during the snapshot period.',
    `volume` BIGINT COMMENT 'Trade volume of the instrument during the snapshot period.',
    CONSTRAINT pk_market_price_snapshot PRIMARY KEY(`market_price_snapshot_id`)
) COMMENT 'Point-in-time market price record for a liquid security or instrument sourced from Bloomberg, FactSet, or exchange feeds. Captures ISIN, CUSIP, SEDOL, instrument type, exchange, bid price, ask price, mid price, last traded price, closing price, price';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`comparable_transaction` (
    `comparable_transaction_id` BIGINT COMMENT 'Unique identifier for the comparable transaction record.',
    `actor_id` BIGINT COMMENT 'Identifier of the valuation agent or firm.',
    `adjustment_id` BIGINT COMMENT 'Identifier of the supporting document.',
    `methodology_id` BIGINT COMMENT 'Foreign key linking to valuation.methodology. Business justification: Comparable transactions use approved valuation methodologies. The transaction_valuation_method string attribute can be normalized by linking to the methodology reference table which',
    `transaction_valuation_agent_legal_entity_id` BIGINT COMMENT 'Legal entity identifier of the valuation agent.',
    `transaction_valuation_cycle_id` BIGINT COMMENT 'Identifier of the valuation cycle or period.',
    `ebitda` DECIMAL(38,2) COMMENT 'Earnings before interest, taxes, depreciation, and amortization of the target.',
    `enterprise_value` DECIMAL(38,2) COMMENT 'Enterprise value of the target company at transaction date.',
    `record_audit_created` TIMESTAMP COMMENT 'Timestamp when the record was first created.',
    `record_audit_updated` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `transaction_amount_gross` DECIMAL(38,2) COMMENT 'Gross monetary value of the transaction before fees and taxes.',
    `transaction_amount_net` DECIMAL(38,2) COMMENT 'Net monetary value after fees, taxes, and discounts.',
    `transaction_currency` STRING COMMENT 'ISO 4217 currency code for transaction amounts.',
    `transaction_date` DATE COMMENT 'Date on which the transaction occurred.',
    `transaction_discount` DECIMAL(38,2) COMMENT 'Discount applied to the transaction price.',
    `transaction_document_code` STRING COMMENT 'Identifier of the supporting document.',
    `transaction_document_date` DATE COMMENT 'Date the supporting document was created.',
    `transaction_document_hash` STRING COMMENT 'Cryptographic hash of the supporting document.',
    `transaction_document_status` STRING COMMENT 'Current status of the supporting document.',
    `transaction_document_type` STRING COMMENT 'File format of the supporting document.. Valid values are `pdf|docx|xlsx|txt|image`',
    `transaction_document_url` STRING COMMENT 'URL to access the supporting document.',
    `transaction_document_version` STRING COMMENT 'Version identifier of the supporting document.',
    `transaction_fee` DECIMAL(38,2) COMMENT 'Transaction fee or commission paid.',
    `transaction_identifier` STRING COMMENT 'Human-readable identifier for the comparable transaction.',
    `transaction_market` STRING COMMENT 'Market segment where the transaction took place.',
    `transaction_market_code` STRING COMMENT 'Standard code identifying the market segment.',
    `transaction_market_type` STRING COMMENT 'Classification of the market: equity, private equity, real estate, infrastructure, or credit.. Valid values are `equity|private equity|real estate|infrastructure|credit`',
    `transaction_source_code` STRING COMMENT 'Identifier within the source system.',
    `transaction_source_system` STRING COMMENT 'System that originated the transaction record.. Valid values are `SimCorp Dimension|BlackRock Aladdin|Bloomberg Terminal|State Street|eFront|DealCloud`',
    `transaction_status` STRING COMMENT 'Current workflow state of the transaction record.. Valid values are `draft|open|closed|cancelled`',
    `transaction_subtype` STRING COMMENT 'Specific subtype within the transaction type, e.g., acquisition, divestiture.',
    `transaction_tax` DECIMAL(38,2) COMMENT 'Tax amount associated with the transaction.',
    `transaction_time` TIMESTAMP COMMENT 'Precise timestamp of the transaction event.',
    `transaction_type` STRING COMMENT 'Category of the transaction such as M&A, secondary sale, IPO, or recapitalization.. Valid values are `M&A|secondary sale|IPO|recapitalization`',
    `transaction_valuation_agent_legal_entity_name` STRING COMMENT 'Legal entity name of the valuation agent.',
    `transaction_valuation_agent_legal_entity_type` STRING COMMENT 'Legal entity type of the valuation agent, e.g., corporation, partnership.',
    `transaction_valuation_agent_type` STRING COMMENT 'Type of valuation agent, e.g., independent, internal.',
    `transaction_valuation_comments` STRING COMMENT 'Additional comments or notes on the valuation.',
    `transaction_valuation_cycle_frequency` STRING COMMENT 'Frequency of the valuation cycle.. Valid values are `monthly|quarterly|annual|semi-annual`',
    `transaction_valuation_engine` STRING COMMENT 'Engine or platform that performed the valuation.. Valid values are `internal|external|third-party`',
    `transaction_valuation_reason` STRING COMMENT 'Reason for the valuation, e.g., due diligence, audit.',
    `transaction_valuation_source_code` STRING COMMENT 'Identifier of the source of valuation data.',
    `transaction_valuation_source_description` STRING COMMENT 'Description of the valuation source.',
    `transaction_valuation_source_name` STRING COMMENT 'Name of the source of valuation data.',
    `transaction_valuation_status` STRING COMMENT 'Current status of the valuation process.. Valid values are `pending|approved|rejected|in review`',
    CONSTRAINT pk_comparable_transaction PRIMARY KEY(`comparable_transaction_id`)
) COMMENT 'Record of a market comparable transaction used as a valuation reference for an illiquid asset. Captures the comparable company or asset name, transaction date, transaction type (M&A, secondary sale, IPO, recapitalization), enterprise value, EBITDA';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`methodology` (
    `methodology_id` BIGINT COMMENT 'Unique identifier for the valuation methodology.',
    `adjustment_id` BIGINT COMMENT 'Identifier of the associated valuation document.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Valuation methodologies must comply with specific regulatory requirements (IFRS 13, GIPS). Links methodology to the governing regulatory authority for compliance tracking.',
    `applicable_asset_category` STRING COMMENT 'Category of the asset. [ENUM-REF-CANDIDATE: ... — promote to reference product]',
    `applicable_asset_class` STRING COMMENT 'Asset class the methodology applies to. [ENUM-REF-CANDIDATE: public_equities|private_equities|real_estate|infrastructure|natural_resources|credit|fixed_income|private_equity|co_investment|real_estate|infrastructure|natural_resources|credit|fixed_income —',
    `applicable_asset_currency` STRING COMMENT 'ISO 4217 currency code for the asset.. Valid values are `^[A-Z]{3}$`',
    `applicable_asset_sector` STRING COMMENT 'Sector of the asset. [ENUM-REF-CANDIDATE: ... — promote to reference product]',
    `applicable_asset_subclass` STRING COMMENT 'Subclass of the asset class. [ENUM-REF-CANDIDATE: ... — promote to reference product]',
    `applicable_asset_type` STRING COMMENT 'Type of the asset. [ENUM-REF-CANDIDATE: ... — promote to reference product]',
    `methodology_code` STRING COMMENT 'External code used to reference the methodology.',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the methodology record was first created.',
    `methodology_description` STRING COMMENT 'Detailed description of the methodology and its use.',
    `document_code` BIGINT COMMENT 'Identifier of the associated valuation document.',
    `document_created_at` TIMESTAMP COMMENT 'Timestamp when the document was created.',
    `document_created_by` STRING COMMENT 'User who created the document.',
    `document_date` DATE COMMENT 'Date the document was created or published.',
    `document_description` STRING COMMENT 'Description of the document contents.',
    `document_hash` STRING COMMENT 'Cryptographic hash of the document for integrity.',
    `document_hash_algorithm` STRING COMMENT 'Algorithm used to generate the document hash.. Valid values are `SHA-256|SHA-512|MD5`',
    `document_notes` STRING COMMENT 'Additional notes about the document.',
    `document_reference` STRING COMMENT 'Reference identifier for the document in external systems.',
    `document_signed_at` TIMESTAMP COMMENT 'Timestamp when the document was signed.',
    `document_signed_by` STRING COMMENT 'Name of the person who signed the document.',
    `document_signed_by_address` STRING COMMENT 'Physical address of the signer.',
    `document_signed_by_department` STRING COMMENT 'Department of the signer.',
    `document_signed_by_email` STRING COMMENT 'Email address of the signer.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `document_signed_by_identifier` STRING COMMENT 'Unique identifier for the signer.',
    `document_signed_by_identifier_type` STRING COMMENT 'Type of identifier (e.g., employee_id, external_id).',
    `document_signed_by_identifier_value` DECIMAL(18,2) COMMENT 'Value of the signers identifier.',
    `document_signed_by_phone` STRING COMMENT 'Phone number of the signer.. Valid values are `^[+]?d{10,15}$`',
    `document_signed_by_role` STRING COMMENT 'Role of the signer (e.g., Analyst, Manager).',
    `document_signed_by_title` STRING COMMENT 'Job title of the signer.',
    `document_source_system` STRING COMMENT 'System that created the document.',
    `document_status` STRING COMMENT 'Lifecycle status of the document.. Valid values are `draft|signed|archived`',
    `document_type` STRING COMMENT 'File format of the document.. Valid values are `pdf|docx|excel`',
    `document_updated_at` TIMESTAMP COMMENT 'Timestamp of the most recent document update.',
    `document_updated_by` STRING COMMENT 'User who last updated the document.',
    `document_url` STRING COMMENT 'URL to access the valuation methodology document.',
    `document_version` STRING COMMENT 'Version number of the document.',
    `effective_from` DATE COMMENT 'Date the methodology becomes effective.',
    `effective_until` DATE COMMENT 'Date the methodology ceases to be effective (nullable).',
    `methodology_status` STRING COMMENT 'Current lifecycle status of the methodology.. Valid values are `active|inactive|deprecated|draft`',
    `methodology_type` STRING COMMENT 'Type of valuation method (DCF, EV/EBITDA, NAV, broker quote, recent transaction, replacement cost, income capitalization). [ENUM-REF-CANDIDATE: DCF|EV/EBITDA|NAV|broker_quote|recent_transaction|replacement_cost|income_capitalization — promote to reference',
    `methodology_name` STRING COMMENT 'Human‑readable name of the valuation methodology.',
    `notes` STRING COMMENT 'Free‑text notes about the methodology.',
    `updated_at` TIMESTAMP COMMENT 'Timestamp of the most recent update to the methodology record.',
    `version` STRING COMMENT 'Version identifier for the methodology definition.',
    CONSTRAINT pk_methodology PRIMARY KEY(`methodology_id`)
) COMMENT 'Reference record defining approved valuation methodologies available for use across asset classes. Captures methodology name (DCF, EV/EBITDA multiple, NAV, broker quote, recent transaction price, replacement cost, income capitalization), applicable asset';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`valuation_policy` (
    `valuation_policy_id` BIGINT COMMENT 'Unique identifier for the valuation policy record.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Valuation policies are governed by regulatory requirements. Pension funds must track which authoritys rules govern each policy for compliance certification.',
    `approval_required` BOOLEAN COMMENT 'Flag indicating if policy approval is required.',
    `approval_required_reason` STRING COMMENT 'Reason for requiring approval.',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the policy record was created.',
    `document_date` DATE COMMENT 'Date of the policy document.',
    `document_description` STRING COMMENT 'Description of the policy document.',
    `document_hash` STRING COMMENT 'Hash of the policy document for integrity.',
    `document_reference` STRING COMMENT 'Reference identifier for the policy document.',
    `document_signed_at` TIMESTAMP COMMENT 'Timestamp when the document was signed.',
    `document_signed_by` STRING COMMENT 'Name of the person who signed the document.',
    `document_source_system` STRING COMMENT 'System where the policy document originates.',
    `document_source_system_code` STRING COMMENT 'Identifier of the source system.',
    `document_source_system_created_at` TIMESTAMP COMMENT 'Timestamp when the source system record was created.',
    `document_source_system_description` STRING COMMENT 'Description of the source system.',
    `document_source_system_name` STRING COMMENT 'Name of the source system.',
    `document_source_system_status` STRING COMMENT 'Current status of the source system.. Valid values are `Active|Inactive|Deprecated`',
    `document_source_system_type` STRING COMMENT 'Type of source system. [ENUM-REF-CANDIDATE: SimCorp|BlackRock|Bloomberg|StateStreet|eFront|DealCloud|MSCI|CharlesRiver|Oracle|SAP|Diligent|Preqin|PitchBook|FactSet — promote to reference product]',
    `document_source_system_updated_at` TIMESTAMP COMMENT 'Timestamp when the source system record was last updated.',
    `document_source_system_version` STRING COMMENT 'Version of the source system.',
    `document_status` STRING COMMENT 'Current status of the policy document.. Valid values are `Draft|Approved|Rejected|Archived`',
    `document_type` STRING COMMENT 'File type of the policy document.. Valid values are `PDF|Word|Excel|Other`',
    `document_url` STRING COMMENT 'URL to the policy document.',
    `document_version` STRING COMMENT 'Version of the policy document.',
    `effective_from` DATE COMMENT 'Date when the policy becomes effective.',
    `effective_until` DATE COMMENT 'Date when the policy expires or is no longer effective.',
    `hierarchy_rules` STRING COMMENT 'Rules for assigning fair value hierarchy levels.',
    `independent_valuation_reason` STRING COMMENT 'Reason for requiring independent valuation.',
    `independent_valuation_required` BOOLEAN COMMENT 'Flag indicating if independent valuation is required.',
    `methodology` STRING COMMENT 'Methodology used for valuation.. Valid values are `DCF|MarketPrice|Level1|Level2|Level3|Other`',
    `methodology_description` STRING COMMENT 'Description of the valuation methodology.',
    `policy_name` STRING COMMENT 'Human-readable name of the valuation policy.',
    `policy_scope` STRING COMMENT 'Scope of the policy (e.g., asset classes, funds).',
    `policy_status` STRING COMMENT 'Current lifecycle status of the policy.. Valid values are `active|draft|deprecated|archived|pending|cancelled`',
    `policy_type` STRING COMMENT 'Category of the valuation policy.. Valid values are `valuation|nav|fair_value|market_price`',
    `record_audit_created` TIMESTAMP COMMENT 'Audit timestamp of record creation.',
    `record_audit_updated` TIMESTAMP COMMENT 'Audit timestamp of record update.',
    `scope_description` STRING COMMENT 'Detailed description of the policy scope.',
    `scope_type` STRING COMMENT 'Type of scope for the policy.. Valid values are `AssetClass|Portfolio|Fund|Asset`',
    `updated_at` TIMESTAMP COMMENT 'Timestamp when the policy record was last updated.',
    `version` STRING COMMENT 'Version identifier of the policy.',
    CONSTRAINT pk_valuation_policy PRIMARY KEY(`valuation_policy_id`)
) COMMENT 'Master record for the firms formal valuation policy governing fair value determination across asset classes. Captures policy version, effective date, expiry date, asset class scope, approved methodologies, hierarchy level assignment rules, independent';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`valuation_review` (
    `valuation_review_id` BIGINT COMMENT 'Unique identifier for the valuation review record.',
    `analyst_assignment_id` BIGINT COMMENT 'Foreign key linking to research.analyst_assignment. Business justification: Valuation reviews should link to the research analyst assignment covering the asset for accountability tracking.',
    `approver_employee_id` BIGINT COMMENT 'Identifier of the party who approved the review.',
    `approver_id` BIGINT COMMENT 'Identifier of the party who approved the review.',
    `cycle_id` BIGINT COMMENT 'Identifier of the review cycle or period.',
    `employee_id` BIGINT COMMENT 'Identifier of the party who performed the review.',
    `origination_source_id` BIGINT COMMENT 'Identifier of the source system or origin of the review.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Identifier of the valuation record being reviewed.',
    `valuation_document_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_document. Business justification: Valuation reviews have document attributes (document_code, document_url, document_type, document_date, document_status) that can be normalized by linking to valuation_document.',
    `valuation_employee_id` BIGINT COMMENT 'Identifier of the party who performed the review.',
    `approval_comments` STRING COMMENT 'Comments provided during the approval.',
    `approval_date` TIMESTAMP COMMENT 'Timestamp when the review was approved.',
    `approval_status` STRING COMMENT 'Status of the approval process (approved, pending, rejected).',
    `approver_name` STRING COMMENT 'Full name of the approver.',
    `comments` STRING COMMENT 'Narrative comments or observations from the review.',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the review record was first created.',
    `cycle_frequency` STRING COMMENT 'Frequency of the review cycle (monthly, quarterly, annual).',
    `impact` STRING COMMENT 'Business impact or action resulting from the review.',
    `method_description` STRING COMMENT 'Detailed description of the review methodology.',
    `outcome` STRING COMMENT 'Final outcome or decision of the review.',
    `reason` STRING COMMENT 'Business justification for initiating the review.',
    `review_date` TIMESTAMP COMMENT 'Timestamp when the review was initiated or conducted.',
    `review_method` STRING COMMENT 'Methodology used for the review (e.g., DCF, market comparison).',
    `review_status` STRING COMMENT 'Current lifecycle status of the review (e.g., draft, open, closed, approved, rejected).',
    `review_type` STRING COMMENT 'Classification of the review (internal, external, audit).',
    `reviewer_name` STRING COMMENT 'Full name of the reviewer.',
    `source_description` STRING COMMENT 'Description of the review source context.',
    `source_name` STRING COMMENT 'Name of the system or entity that generated the review.',
    `status_date` TIMESTAMP COMMENT 'Timestamp of the last status change for the review.',
    `status_notes` STRING COMMENT 'Additional notes related to status changes.',
    `status_reason` STRING COMMENT 'Reason for the current review status.',
    `updated_at` TIMESTAMP COMMENT 'Timestamp of the most recent update to the review record.',
    `valuation_comments` STRING COMMENT 'Narrative comments on the valuation.',
    `valuation_date` TIMESTAMP COMMENT 'Date of the valuation being reviewed.',
    `valuation_document_code` BIGINT COMMENT 'Identifier of the supporting document for the valuation.',
    `valuation_document_date` TIMESTAMP COMMENT 'Date the valuation document was created or finalized.',
    `valuation_document_type` STRING COMMENT 'Format of the valuation document (PDF, DOCX).',
    `valuation_document_url` STRING COMMENT 'Location of the valuation document.',
    `valuation_method` STRING COMMENT 'Method used for the valuation (DCF, market, book).',
    `valuation_status` STRING COMMENT 'Current status of the valuation (approved, pending, rejected).',
    CONSTRAINT pk_valuation_review PRIMARY KEY(`valuation_review_id`)
) COMMENT 'Record of a formal valuation review or challenge event conducted by the Valuation Committee, IC (Investment Committee), or external auditor for a specific asset valuation or NAV record.';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`private_asset_valuation` (
    `private_asset_valuation_id` BIGINT COMMENT 'Unique identifier for the private asset valuation record.',
    `actor_id` BIGINT COMMENT 'Identifier of the valuation agent or firm.',
    `adjustment_id` BIGINT COMMENT 'Identifier of the valuation supporting document.',
    `dd_engagement_id` BIGINT COMMENT 'Foreign key linking to diligence.dd_engagement. Business justification: Private asset valuation memos require reference to original DD engagement for acquisition basis, identified risks, and conditions precedent.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: Private asset valuations (PE, infrastructure, real estate) require scenario analysis for IC presentations and regulatory stress testing.',
    `issuer_esg_rating_id` BIGINT COMMENT 'Foreign key linking to esg.issuer_esg_rating. Business justification: Private equity/infrastructure valuations require ESG score integration per pension fund policies.',
    `model_id` BIGINT COMMENT 'Identifier of the DCF model used.',
    `portfolio_id` BIGINT COMMENT 'Identifier of the portfolio containing the asset.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Unique identifier for the asset being valued.',
    `valuation_cycle_id` BIGINT COMMENT 'Identifier of the valuation cycle.',
    `asset_class` STRING COMMENT 'Secondary classification of the asset (e.g., private equity, real estate).',
    `asset_code` BIGINT COMMENT 'Unique identifier for the asset being valued.',
    `asset_currency` STRING COMMENT 'ISO 4217 currency code for the asset valuation.',
    `asset_isin` STRING COMMENT 'International Securities Identification Number for the asset.. Valid values are `^[A-Z]{2}[0-9A-Z]{9}[0-9]$`',
    `asset_name` STRING COMMENT 'Legal name of the asset.',
    `asset_type` STRING COMMENT 'Primary classification of the asset (e.g., equity, debt).',
    `book_value` DECIMAL(18,4) COMMENT 'Accounting book value of the asset.',
    `cost_of_debt_rate` DECIMAL(5,4) COMMENT 'Cost of debt component in WACC calculation.',
    `cost_of_equity_rate` DECIMAL(5,4) COMMENT 'Cost of equity component in WACC calculation.',
    `debt_weight` DECIMAL(5,4) COMMENT 'Proportion of debt in the capital structure.',
    `equity_weight` DECIMAL(5,4) COMMENT 'Proportion of equity in the capital structure.',
    `fair_value` DECIMAL(18,4) COMMENT 'Estimated fair market value of the asset.',
    `gav` DECIMAL(18,4) COMMENT 'Gross asset value of the portfolio at valuation date.',
    `market_value` DECIMAL(18,4) COMMENT 'Observable market value if available.',
    `nav` DECIMAL(18,4) COMMENT 'Net asset value of the portfolio at valuation date.',
    `tax_rate` DECIMAL(5,4) COMMENT 'Applicable tax rate for the valuation.',
    `valuation_comments` STRING COMMENT 'Additional comments or notes on the valuation.',
    `valuation_cycle_frequency` STRING COMMENT 'Frequency of the valuation cycle.. Valid values are `Monthly|Quarterly|Annual`',
    `valuation_date` DATE COMMENT 'Date on which the valuation was performed.',
    `valuation_document_code` BIGINT COMMENT 'Identifier of the valuation supporting document.',
    `valuation_document_date` DATE COMMENT 'Date the valuation document was created.',
    `valuation_document_hash` STRING COMMENT 'SHA-256 hash of the valuation document.. Valid values are `^[a-fA-F0-9]{64}$`',
    `valuation_document_signed_at` TIMESTAMP COMMENT 'Timestamp when the valuation document was signed.',
    `valuation_document_signed_by` STRING COMMENT 'Name of the person who signed the valuation document.',
    `valuation_document_status` STRING COMMENT 'Current status of the valuation document.. Valid values are `draft|final|archived`',
    `valuation_document_type` STRING COMMENT 'File format of the valuation document.. Valid values are `pdf|docx|xlsx|txt`',
    `valuation_document_url` STRING COMMENT 'URL to access the valuation document.. Valid values are `^(https?|ftp)://[^s/$.?#].[S]*$`',
    `valuation_document_version` STRING COMMENT 'Version identifier of the valuation document.',
    `valuation_engine` STRING COMMENT 'System or tool used to compute the valuation.. Valid values are `SimCorp|Aladdin|Custom`',
    `valuation_method` STRING COMMENT 'Method used to determine the assets value.. Valid values are `DCF|Market|Comparable|Other`',
    `valuation_reason` STRING COMMENT 'Reason for initiating the valuation.',
    `valuation_source_code` BIGINT COMMENT 'Identifier of the source of valuation data.',
    `valuation_source_description` STRING COMMENT 'Description of the valuation source.',
    `valuation_source_name` STRING COMMENT 'Name of the source of valuation data.',
    `valuation_status` STRING COMMENT 'Current status of the valuation process.. Valid values are `Pending|Approved|Rejected|Completed`',
    `valuation_time` TIMESTAMP COMMENT 'Timestamp of the valuation event.',
    `wacc_rate` DECIMAL(5,4) COMMENT 'Weighted average cost of capital used in valuation.',
    CONSTRAINT pk_private_asset_valuation PRIMARY KEY(`private_asset_valuation_id`)
) COMMENT 'Specialized valuation record for illiquid private market assets (private equity, infrastructure, real estate, natural resources) where observable market prices are unavailable.';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`broker_quote` (
    `broker_quote_id` BIGINT COMMENT 'Unique identifier for the broker quote record.',
    `broker_id` BIGINT COMMENT 'Unique identifier for the broker.',
    `data_vendor_id` BIGINT COMMENT 'Foreign key linking to research.data_vendor. Business justification: Broker quotes must track the data vendor source for data quality monitoring, vendor performance assessment, and regulatory audit trails.',
    `instrument_id` BIGINT COMMENT 'Foreign key linking to trade.instrument. Business justification: Broker quotes must reference instrument master for quote aggregation, price discovery, and best execution compliance.',
    `quote_source_id` BIGINT COMMENT 'Identifier of the quote in the source system.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_asset_valuation. Business justification: Broker quotes are Level 2 pricing inputs used in asset valuations. Linking broker_quote to valuation_asset_valuation enables tracking which quotes were used for a specific',
    `ask_price` DECIMAL(18,6) COMMENT 'Ask price quoted by the broker.',
    `ask_size` DECIMAL(18,6) COMMENT 'Ask size quoted by the broker.',
    `bid_ask_spread` DECIMAL(18,6) COMMENT 'Spread between bid and ask prices.',
    `bid_price` DECIMAL(18,6) COMMENT 'Bid price quoted by the broker.',
    `bid_size` DECIMAL(18,6) COMMENT 'Bid size quoted by the broker.',
    `broker_dealer_lei` STRING COMMENT 'LEI of the brokers dealer entity.. Valid values are `^[0-9A-Z]{20}$`',
    `broker_dealer_name` STRING COMMENT 'Name of the brokers dealer entity.',
    `mid_price` DECIMAL(18,6) COMMENT 'Mid price calculated from bid and ask.',
    `quote_source_country` STRING COMMENT 'Country of the quote source.. Valid values are `^[A-Z]{3}$`',
    `quote_source_exchange` STRING COMMENT 'Exchange where the quote originates.. Valid values are `^[A-Z]{3,5}$`',
    `quote_source_market` STRING COMMENT 'Market of the quote source.. Valid values are `^[A-Z]{3,10}$`',
    `quote_source_name` STRING COMMENT 'Name of the source providing the quote.',
    `quote_source_region` STRING COMMENT 'Region of the quote source.',
    `quote_source_system` STRING COMMENT 'System that provided the quote.',
    `quote_source_type` STRING COMMENT 'Type of the quote source (e.g., Reuters, Bloomberg).',
    `quote_status` STRING COMMENT 'Current status of the quote (active, expired, cancelled).',
    `quote_timestamp` TIMESTAMP COMMENT 'Timestamp when the quote was received.',
    `quote_type` STRING COMMENT 'Type of the quote (indicative, firm, best).',
    `quote_valid_from` TIMESTAMP COMMENT 'Start of the quotes validity period.',
    `quote_valid_to` TIMESTAMP COMMENT 'End of the quotes validity period.',
    CONSTRAINT pk_broker_quote PRIMARY KEY(`broker_quote_id`)
) COMMENT 'Record of a broker or dealer price quote obtained for a security or instrument as a Level 2 pricing input. Captures instrument identifier (ISIN/CUSIP/SEDOL), broker/dealer name, LEI, quote date, bid price, ask price, mid price, quote type (indicative';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`valuation_yield_curve` (
    `valuation_yield_curve_id` BIGINT COMMENT 'Unique identifier for the yield curve record.',
    `research_yield_curve_id` BIGINT COMMENT 'FK to research.research_yield_curve.research_yield_curve_id — DCF and fixed-income valuations must draw discount curves from the research market-data SSOT to ensure valuation and risk use identical curve inputs.',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the record was created.',
    `currency` STRING COMMENT 'ISO 4217 currency code for the yield curve.. Valid values are `^[A-Z]{3}$`',
    `curve_code` STRING COMMENT 'Unique code assigned to the yield curve.',
    `curve_description` STRING COMMENT 'Detailed description of the yield curve.',
    `curve_name` STRING COMMENT 'Human-readable name of the yield curve.',
    `curve_notes` STRING COMMENT 'Notes specific to the yield curve.',
    `curve_source_code` STRING COMMENT 'Identifier of the source of the yield curve.',
    `curve_source_description` STRING COMMENT 'Description of the source of the yield curve.',
    `curve_source_name` STRING COMMENT 'Name of the source of the yield curve.',
    `curve_source_type` STRING COMMENT 'Type of the source such as market data or internal model.',
    `curve_source_url` STRING COMMENT 'URL to access the source of the yield curve.',
    `curve_type` STRING COMMENT 'Category of the yield curve such as government or swap.. Valid values are `government|swap|credit_spread|oas`',
    `effective_from` DATE COMMENT 'Date when the yield curve becomes effective.',
    `effective_until` DATE COMMENT 'Date when the yield curve expires.',
    `is_active` BOOLEAN COMMENT 'Indicates if the curve is currently active.',
    `is_default` BOOLEAN COMMENT 'Indicates if this curve is the default for its type.',
    `is_public` BOOLEAN COMMENT 'Indicates if the curve is publicly available.',
    `notes` STRING COMMENT 'Free-text notes about the yield curve.',
    `record_audit_created` TIMESTAMP COMMENT 'Audit timestamp of record creation.',
    `record_audit_updated` TIMESTAMP COMMENT 'Audit timestamp of record update.',
    `reference_date` DATE COMMENT 'Date on which the yield curve is referenced.',
    `remarks` STRING COMMENT 'Additional remarks about the yield curve.',
    `source_system_code` STRING COMMENT 'Identifier of the source system record.',
    `source_system_name` STRING COMMENT 'Human-readable name of the source system.',
    `source_system_type` STRING COMMENT 'Type of the source system such as database or API.',
    `source_system_url` STRING COMMENT 'URL of the source system endpoint.',
    `source_system_version` STRING COMMENT 'Version of the source system used.',
    `tags` STRING COMMENT 'Comma-separated tags for categorization.',
    `updated_at` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `valuation_yield_curve_status` STRING COMMENT 'Current lifecycle status of the yield curve.. Valid values are `active|inactive|archived`',
    `value_10y` DECIMAL(18,6) COMMENT 'Yield value for the 10-year tenor.',
    `value_1y` DECIMAL(18,6) COMMENT 'Yield value for the 1-year tenor.',
    `value_2y` DECIMAL(18,6) COMMENT 'Yield value for the 2-year tenor.',
    `value_30y` DECIMAL(18,6) COMMENT 'Yield value for the 30-year tenor.',
    `value_3m` DECIMAL(18,6) COMMENT 'Yield value for the 3-month tenor.',
    `value_5y` DECIMAL(18,6) COMMENT 'Yield value for the 5-year tenor.',
    `value_6m` DECIMAL(18,6) COMMENT 'Yield value for the 6-month tenor.',
    `version` BIGINT COMMENT 'Version number of the yield curve record.',
    CONSTRAINT pk_valuation_yield_curve PRIMARY KEY(`valuation_yield_curve_id`)
) COMMENT 'Reference record for a yield curve or discount rate curve used in fixed income and DCF valuations. Captures curve name, curve type (government, swap, credit spread, OAS), currency, reference date, tenor points (3M, 6M, 1Y, 2Y, 5Y, 10Y, 30Y), corresponding';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`valuation_fx_rate` (
    `valuation_fx_rate_id` BIGINT COMMENT 'Unique identifier for the FX rate record.',
    `base_currency` STRING COMMENT 'ISO 4217 three-letter code of the base currency.. Valid values are `^[A-Z]{3}$`',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the record was created.',
    `currency_pair` STRING COMMENT 'Concatenated base and quote currency codes (e.g., USD/EUR).',
    `effective_from` DATE COMMENT 'Date from which the FX rate is effective.',
    `effective_until` DATE COMMENT 'Date until which the FX rate is effective.',
    `forward_rate_12m` DECIMAL(20,10) COMMENT 'Forward exchange rate for twelve month maturity.',
    `forward_rate_1m` DECIMAL(20,10) COMMENT 'Forward exchange rate for one month maturity.',
    `forward_rate_3m` DECIMAL(20,10) COMMENT 'Forward exchange rate for three month maturity.',
    `forward_rate_6m` DECIMAL(20,10) COMMENT 'Forward exchange rate for six month maturity.',
    `quote_currency` STRING COMMENT 'ISO 4217 three-letter code of the quote currency.. Valid values are `^[A-Z]{3}$`',
    `rate_date` DATE COMMENT 'Date on which the FX rate is applicable.',
    `rate_source` STRING COMMENT 'Source of the FX rate data.. Valid values are `Bloomberg|Reuters|Fixing|Other`',
    `rate_source_description` STRING COMMENT 'Detailed description of the rate source.',
    `rate_status` STRING COMMENT 'Current status of the FX rate record.. Valid values are `active|inactive|archived`',
    `rate_type` STRING COMMENT 'Type of rate: spot or forward.. Valid values are `spot|forward`',
    `rate_version` BIGINT COMMENT 'Version number of the FX rate record.',
    `record_audit_created` TIMESTAMP COMMENT 'Audit timestamp of record creation.',
    `record_audit_updated` TIMESTAMP COMMENT 'Audit timestamp of last record update.',
    `remarks` STRING COMMENT 'Additional notes or comments about the FX rate.',
    `spot_rate` DECIMAL(20,10) COMMENT 'Current market spot exchange rate between base and quote currencies.',
    `updated_at` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    CONSTRAINT pk_valuation_fx_rate PRIMARY KEY(`valuation_fx_rate_id`)
) COMMENT 'Reference record for foreign exchange (FX) rates used in multi-currency asset valuations and NAV translation. Captures base currency, quote currency, spot rate, forward rate (1M, 3M, 6M, 12M), rate date, rate source (Bloomberg, WM/Reuters fixing), and';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`nav_liability` (
    `nav_liability_id` BIGINT COMMENT 'Unique identifier for the nav liability record.',
    `adjustment_id` BIGINT COMMENT 'Identifier of the document associated with the liability.',
    `counterparty_id` BIGINT COMMENT 'Identifier of the counterparty involved in the liability.',
    `fund_id` BIGINT COMMENT 'Identifier of the fund associated with the liability.',
    `portfolio_id` BIGINT COMMENT 'Identifier of the portfolio associated with the liability.',
    `settlement_cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: NAV liabilities (accrued fees, payables) settle through designated cash accounts. Pension fund controllers need this link for liability settlement tracking and cash flow projection',
    `valuation_cycle_id` BIGINT COMMENT 'Identifier of the valuation cycle during which the liability is recorded.',
    `valuation_nav_record_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_nav_record. Business justification: NAV liabilities are deducted in NAV computation. Linking nav_liability to valuation_nav_record creates the relationship between the liability records and the NAV record they',
    `counterparty_address` STRING COMMENT 'Physical address of the counterparty.',
    `counterparty_contact` STRING COMMENT 'Primary contact person at the counterparty.',
    `counterparty_email` STRING COMMENT 'Email address of the counterparty contact.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `counterparty_phone` STRING COMMENT 'Phone number of the counterparty contact.',
    `counterparty_type` STRING COMMENT 'Classification of the counterparty.. Valid values are `counterparty|vendor|customer|partner|other`',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the record was created.',
    `nav_liability_description` STRING COMMENT 'Free-text description of the liability.',
    `effective_date` DATE COMMENT 'Date when the liability becomes effective.',
    `legal_entity_code` BIGINT COMMENT 'Identifier of the legal entity associated with the liability.',
    `liability_amount` DECIMAL(18,2) COMMENT 'Monetary amount of the liability.',
    `liability_currency` STRING COMMENT 'ISO 4217 currency code for the liability amount.. Valid values are `^[A-Z]{3}$`',
    `liability_date` DATE COMMENT 'Date when the liability was incurred.',
    `liability_document_code` BIGINT COMMENT 'Identifier of the document associated with the liability.',
    `liability_document_date` DATE COMMENT 'Date the liability document was created.',
    `liability_document_type` STRING COMMENT 'File type of the liability document.. Valid values are `pdf|docx|xlsx|other`',
    `liability_document_url` STRING COMMENT 'URL to access the liability document.',
    `liability_document_version` STRING COMMENT 'Version identifier of the liability document.',
    `liability_subtype` STRING COMMENT 'Further classification of the liability.',
    `liability_type` STRING COMMENT 'Classification of the liability type.. Valid values are `management_fee|carried_interest|redemption|borrowing|derivative_liability|tax_provision`',
    `maturity_date` DATE COMMENT 'Date when the liability matures or is due.',
    `nav_liability_status` STRING COMMENT 'Current status of the liability record.. Valid values are `active|settled|pending|cancelled|closed`',
    `notes` STRING COMMENT 'Free-text notes related to the liability.',
    `record_audit_created` TIMESTAMP COMMENT 'Audit timestamp of record creation.',
    `record_audit_updated` TIMESTAMP COMMENT 'Audit timestamp of last record update.',
    `reference_number` STRING COMMENT 'Internal reference number for the liability.',
    `settlement_amount` DECIMAL(18,2) COMMENT 'Monetary amount settled for the liability.',
    `settlement_currency` STRING COMMENT 'ISO 4217 currency code for the settlement amount.. Valid values are `^[A-Z]{3}$`',
    `settlement_date` DATE COMMENT 'Date when the liability was settled.',
    `settlement_method` STRING COMMENT 'Method used to settle the liability.. Valid values are `bank_transfer|cash|check|wire|cheque|other`',
    `settlement_reference` STRING COMMENT 'Reference number for the settlement transaction.',
    `settlement_status` STRING COMMENT 'Current status of the settlement.. Valid values are `settled|pending|failed|reversed`',
    `source_system_code` STRING COMMENT 'Identifier of the source system instance.',
    `source_system_version` STRING COMMENT 'Version of the source system.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Tax amount associated with the liability.',
    `tax_code` STRING COMMENT 'Tax code applicable to the liability.',
    `tax_jurisdiction` STRING COMMENT 'Country code for the tax jurisdiction.. Valid values are `^[A-Z]{2}$`',
    `tax_rate` DECIMAL(5,4) COMMENT 'Tax rate applied to the liability.',
    `tax_type` STRING COMMENT 'Type of tax applied to the liability.. Valid values are `income_tax|capital_gains|value_added_tax|sales_tax|other`',
    `updated_at` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    CONSTRAINT pk_nav_liability PRIMARY KEY(`nav_liability_id`)
) COMMENT 'Record of liabilities deducted in the NAV computation for a fund or investment vehicle. Captures liability type (management fees payable, carried interest accrual, redemptions payable, borrowings, derivatives MTM liability, tax provisions), liability';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`input` (
    `input_id` BIGINT COMMENT 'Unique identifier for the valuation input record.',
    `approval_by` STRING COMMENT 'User or authority that approved the input.',
    `approval_comments` STRING COMMENT 'Comments or rationale for the approval decision.',
    `approval_date` DATE COMMENT 'Date when the input was approved.',
    `input_code` STRING COMMENT 'Alphanumeric code used internally to reference the input.',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the input record was first created.',
    `input_description` STRING COMMENT 'Detailed description of the input and its purpose.',
    `effective_from` DATE COMMENT 'Date from which the input is considered valid.',
    `effective_until` DATE COMMENT 'Date until which the input remains valid (nullable).',
    `input_status` STRING COMMENT 'Current lifecycle status of the input (e.g., active, deprecated).',
    `input_type` STRING COMMENT 'Category of the input, such as Rate, Price, Metric.',
    `is_active` BOOLEAN COMMENT 'Flag indicating if the input is currently active.',
    `is_approved` BOOLEAN COMMENT 'Flag indicating if the input has been approved for use.',
    `is_confidential` BOOLEAN COMMENT 'Flag indicating if the input contains confidential data.',
    `is_default` BOOLEAN COMMENT 'Flag indicating if the input is the default value for its type.',
    `is_derived` BOOLEAN COMMENT 'Flag indicating if the input is derived from other inputs.',
    `is_required` BOOLEAN COMMENT 'Flag indicating if the input is mandatory for valuation models.',
    `input_name` STRING COMMENT 'Human-readable name of the input, e.g., Revenue Growth Rate.',
    `remarks` STRING COMMENT 'Additional remarks or notes about the input.',
    `source` STRING COMMENT 'Origin of the input data (e.g., internal model, market feed).',
    `source_reference` STRING COMMENT 'Reference identifier in the source system (e.g., model ID).',
    `unit` STRING COMMENT 'Unit of measure for the input value (e.g., % , USD).',
    `updated_at` TIMESTAMP COMMENT 'Timestamp of the most recent update to the input record.',
    `updated_by` STRING COMMENT 'User or system that last updated the input record.',
    `value` DECIMAL(18,6) COMMENT 'Numerical value used in valuation calculations.',
    `version` BIGINT COMMENT 'Version number of the input record for change tracking.',
    `created_by` STRING COMMENT 'User or system that created the input record.',
    CONSTRAINT pk_input PRIMARY KEY(`input_id`)
) COMMENT 'Granular record of a specific quantitative input used in an asset valuation model. Captures input name (revenue growth rate, terminal growth rate, cap rate, NOI, LTV, DSCR, occupancy rate, commodity price), input value, input unit, source (internal model';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`sensitivity` (
    `sensitivity_id` BIGINT COMMENT 'Unique identifier for the sensitivity analysis record.',
    `actor_id` BIGINT COMMENT 'Identifier of the valuation agent.',
    `climate_scenario_id` BIGINT COMMENT 'Foreign key linking to esg.climate_scenario. Business justification: TCFD mandates climate sensitivity analysis. Pension funds run valuation sensitivities against multiple temperature pathways to assess portfolio resilience.',
    `created_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Sensitivity analyses are created by employees. created_by_user is text; proper FK needed for audit trail and analyst accountability in risk assessment.',
    `macro_indicator_id` BIGINT COMMENT 'Foreign key linking to research.macro_indicator. Business justification: Sensitivity analyses test valuation impacts against specific macro indicators (interest rates, inflation, GDP growth).',
    `model_id` BIGINT COMMENT 'Identifier of the valuation model used.',
    `valuation_asset_valuation_asset_valuation_id` BIGINT COMMENT 'Identifier of the asset being valued.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Identifier of the asset being valued.',
    `valuation_cycle_id` BIGINT COMMENT 'Identifier of the valuation cycle.',
    `base_case_value` DECIMAL(38,10) COMMENT 'Fair value under base case assumptions.',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the record was created.',
    `created_by_user` STRING COMMENT 'User who created the record.',
    `delta_value` DECIMAL(38,10) COMMENT 'Change in fair value due to sensitivity variable.',
    `sensitivity_description` STRING COMMENT 'Detailed description of the sensitivity analysis.',
    `notes` STRING COMMENT 'Additional notes about the sensitivity analysis.',
    `percent_change` DECIMAL(38,10) COMMENT 'Percentage change in fair value relative to base case.',
    `run_date` DATE COMMENT 'Calendar date when the sensitivity run was initiated.',
    `run_description` STRING COMMENT 'Brief description of the sensitivity run purpose.',
    `run_duration_seconds` BIGINT COMMENT 'Total duration of the run in seconds.',
    `run_engine_version` STRING COMMENT 'Version of the engine that executed the run.',
    `run_environment` STRING COMMENT 'Execution environment for the run (e.g., production, test).',
    `run_error_message` STRING COMMENT 'Error message if the run failed.',
    `run_notes` STRING COMMENT 'Additional notes or comments about the run.',
    `run_number` BIGINT COMMENT 'Sequential number assigned to each sensitivity run.',
    `run_source_system` STRING COMMENT 'System that originated the run request.',
    `run_source_system_description` STRING COMMENT 'Description of the source system that triggered the run.',
    `run_source_system_version` STRING COMMENT 'Version of the source system that initiated the run.',
    `run_status` STRING COMMENT 'Current status of the sensitivity run.. Valid values are `completed|failed|in_progress|cancelled`',
    `run_timestamp` TIMESTAMP COMMENT 'Exact timestamp of sensitivity run start.',
    `sensitivity_status` STRING COMMENT 'Current status of the sensitivity record.. Valid values are `completed|failed|in_progress|cancelled`',
    `updated_at` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `updated_by_user` STRING COMMENT 'User who last updated the record.',
    `valuation_engine` STRING COMMENT 'Engine that performed the valuation.. Valid values are `SimCorp|Aladdin|Bloomberg`',
    `valuation_method` STRING COMMENT 'Method used for valuation.. Valid values are `DCF|Market|NAV|Fair Value`',
    `valuation_source_code` BIGINT COMMENT 'Identifier of the source of valuation data.',
    `valuation_source_name` STRING COMMENT 'Name of the valuation source.',
    `valuation_source_status` STRING COMMENT 'Lifecycle status of the valuation source.. Valid values are `Active|Inactive|Pending`',
    `valuation_source_type` STRING COMMENT 'Type of the valuation source.. Valid values are `Internal|External|ThirdParty`',
    `valuation_source_version` STRING COMMENT 'Version of the valuation source.',
    `variable` STRING COMMENT 'Variable that was altered in the sensitivity analysis.. Valid values are `WACC|terminal_growth_rate|exit_multiple|cap_rate`',
    `variable_value` DECIMAL(38,10) COMMENT 'Value of the variable used in the sensitivity run.',
    CONSTRAINT pk_sensitivity PRIMARY KEY(`sensitivity_id`)
) COMMENT 'Record of a sensitivity analysis run against a valuation model, capturing how the concluded fair value changes under alternative input assumptions. Captures the base case value, sensitivity variable (WACC, terminal growth rate, exit multiple, cap rate)';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`real_estate_appraisal` (
    `real_estate_appraisal_id` BIGINT COMMENT 'Unique identifier for the real estate appraisal record.',
    `property_id` BIGINT COMMENT 'Unique identifier for the property being appraised.',
    `real_adjustment_id` BIGINT COMMENT 'Identifier of the appraisal report document.',
    `real_property_valuation_document_adjustment_id` BIGINT COMMENT 'Identifier of the property valuation document.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Real estate appraisals follow regulatory standards (RICS, USPAP). Pension funds track which regulatory bodys standards govern each appraisal for compliance.',
    `taxonomy_alignment_id` BIGINT COMMENT 'Foreign key linking to esg.taxonomy_alignment. Business justification: EU Taxonomy alignment directly impacts real estate valuations. Green building certifications and energy efficiency ratings affect property values.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_asset_valuation. Business justification: Real estate appraisals are specialized valuations that feed into the core asset valuation record.',
    `appraisal_comments` STRING COMMENT 'Additional comments from the appraiser.',
    `appraisal_currency` STRING COMMENT 'Currency used for the appraisal value.',
    `appraisal_date` DATE COMMENT 'Date the appraisal was completed.',
    `appraisal_document_code` STRING COMMENT 'Identifier of the appraisal report document.',
    `appraisal_document_date` DATE COMMENT 'Date the appraisal document was issued.',
    `appraisal_document_hash` STRING COMMENT 'Cryptographic hash of the appraisal document.',
    `appraisal_document_signed_at` TIMESTAMP COMMENT 'Timestamp when the appraisal document was signed.',
    `appraisal_document_signed_by` STRING COMMENT 'Name of the person who signed the appraisal document.',
    `appraisal_document_status` STRING COMMENT 'Current status of the appraisal document.',
    `appraisal_document_type` STRING COMMENT 'Format of the appraisal document (e.g., PDF).',
    `appraisal_document_url` STRING COMMENT 'URL to access the appraisal document.',
    `appraisal_document_version` STRING COMMENT 'Version number of the appraisal document.',
    `appraisal_method` STRING COMMENT 'Methodology used for the appraisal (e.g., income capitalization).',
    `appraised_value` DECIMAL(19,4) COMMENT 'Monetary value assigned by the appraisal.',
    `appraiser_firm` STRING COMMENT 'Firm or organization of the appraiser.',
    `appraiser_name` STRING COMMENT 'Full name of the licensed appraiser.',
    `property_address` STRING COMMENT 'Street address of the property.',
    `property_area_sqft` DECIMAL(19,4) COMMENT 'Total area of the property in square feet.',
    `property_city` STRING COMMENT 'City where the property is located.',
    `property_country` STRING COMMENT 'Country of the property.',
    `property_ownership_type` STRING COMMENT 'Ownership classification of the property.',
    `property_state` STRING COMMENT 'State or province of the property.',
    `property_status` STRING COMMENT 'Current lifecycle status of the property.',
    `property_type` STRING COMMENT 'Classification of the property (e.g., residential, commercial).',
    `property_valuation_comments` STRING COMMENT 'Additional comments related to the property valuation.',
    `property_valuation_currency` STRING COMMENT 'Currency used for the property valuation value.',
    `property_valuation_date` DATE COMMENT 'Date the property valuation was performed.',
    `property_valuation_document_code` STRING COMMENT 'Identifier of the property valuation document.',
    `property_valuation_document_date` DATE COMMENT 'Date the property valuation document was issued.',
    `property_valuation_document_hash` STRING COMMENT 'Cryptographic hash of the property valuation document.',
    `property_valuation_document_signed_at` TIMESTAMP COMMENT 'Timestamp when the property valuation document was signed.',
    `property_valuation_document_signed_by` STRING COMMENT 'Name of the person who signed the property valuation document.',
    `property_valuation_document_status` STRING COMMENT 'Current status of the property valuation document.',
    `property_valuation_document_type` STRING COMMENT 'Format of the property valuation document.',
    `property_valuation_document_url` STRING COMMENT 'URL to access the property valuation document.',
    `property_valuation_document_version` STRING COMMENT 'Version number of the property valuation document.',
    `property_valuation_method` STRING COMMENT 'Method used for the property valuation.',
    `property_valuation_notes` STRING COMMENT 'Notes related to the property valuation.',
    `property_valuation_status` STRING COMMENT 'Current status of the property valuation.',
    `property_valuation_value` DECIMAL(19,4) COMMENT 'Monetary value assigned during property valuation.',
    `property_year_built` BIGINT COMMENT 'Year the property was constructed.',
    `property_zip_code` STRING COMMENT 'Postal code of the property.',
    CONSTRAINT pk_real_estate_appraisal PRIMARY KEY(`real_estate_appraisal_id`)
) COMMENT 'Specialized appraisal record for direct real estate holdings capturing property-level valuation outputs from licensed appraisers. Captures property identifier, appraiser firm, appraisal date, appraisal methodology (income capitalization, discounted cash';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`infrastructure_valuation` (
    `infrastructure_valuation_id` BIGINT COMMENT 'Unique identifier for the infrastructure valuation record.',
    `actor_id` BIGINT COMMENT 'Identifier of the valuation agent or firm.',
    `adjustment_id` BIGINT COMMENT 'Identifier of the valuation document.',
    `dd_engagement_id` BIGINT COMMENT 'Foreign key linking to diligence.dd_engagement. Business justification: Infrastructure valuations require DD engagement reference for acquisition assumptions, regulatory conditions, concession terms, and ESG factors.',
    `employee_id` BIGINT COMMENT 'Identifier of the portfolio manager.',
    `infra_asset_id` BIGINT COMMENT 'Unique identifier for the underlying infrastructure asset.',
    `issuer_esg_rating_id` BIGINT COMMENT 'Foreign key linking to esg.issuer_esg_rating. Business justification: Infrastructure assets (renewables, utilities) require ESG ratings for valuation adjustments.',
    `portfolio_id` BIGINT COMMENT 'Identifier of the portfolio containing the asset.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_asset_valuation. Business justification: Infrastructure valuations are specialized valuations for infrastructure assets.',
    `valuation_cycle_id` BIGINT COMMENT 'Identifier of the valuation cycle.',
    `asset_category` STRING COMMENT 'Category of the asset (e.g., renewable, non-renewable).',
    `asset_class` STRING COMMENT 'Class of the asset within the investment taxonomy.',
    `asset_currency` STRING COMMENT 'ISO 4217 currency code for the asset valuation.. Valid values are `^[A-Z]{3}$`',
    `asset_isin` STRING COMMENT 'International Securities Identification Number for the asset.. Valid values are `^[A-Z]{2}[0-9A-Z]{9}[0-9]$`',
    `asset_name` STRING COMMENT 'Legal name of the infrastructure asset.',
    `asset_sector` STRING COMMENT 'Sector in which the asset operates (e.g., energy, transport).',
    `asset_subclass` STRING COMMENT 'Subclass of the asset for more granular categorization.',
    `asset_type` STRING COMMENT 'Type of infrastructure asset (e.g., toll road, airport).',
    `book_value` DECIMAL(20,4) COMMENT 'Book value of the asset in the books.',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the record was first created.',
    `fair_value` DECIMAL(20,4) COMMENT 'Fair value of the asset as determined by the valuation model.',
    `gav` DECIMAL(20,4) COMMENT 'Gross asset value of the portfolio including this asset.',
    `infrastructure_valuation_status` STRING COMMENT 'Current lifecycle status of the valuation record.. Valid values are `draft|pending|approved|published|archived`',
    `market_value` DECIMAL(20,4) COMMENT 'Market value of the asset if available.',
    `nav` DECIMAL(20,4) COMMENT 'Net asset value of the portfolio including this asset.',
    `portfolio_type` STRING COMMENT 'Type of portfolio (e.g., infrastructure, private equity).',
    `updated_at` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `valuation_comments` STRING COMMENT 'Additional comments or notes on the valuation.',
    `valuation_cycle_frequency` STRING COMMENT 'Frequency of the valuation cycle.. Valid values are `monthly|quarterly|annual`',
    `valuation_document_code` BIGINT COMMENT 'Identifier of the valuation document.',
    `valuation_document_date` DATE COMMENT 'Date the valuation document was issued.',
    `valuation_document_hash` STRING COMMENT 'Cryptographic hash of the valuation document.',
    `valuation_document_signed_at` TIMESTAMP COMMENT 'Timestamp when the valuation document was signed.',
    `valuation_document_signed_by` STRING COMMENT 'Name of the person who signed the valuation document.',
    `valuation_document_status` STRING COMMENT 'Current status of the valuation document.. Valid values are `draft|approved|archived`',
    `valuation_document_type` STRING COMMENT 'File type of the valuation document.. Valid values are `pdf|docx|xlsx|txt`',
    `valuation_document_url` STRING COMMENT 'URL to the valuation document.. Valid values are `^https?://.*$`',
    `valuation_document_version` STRING COMMENT 'Version identifier of the valuation document.',
    `valuation_engine` STRING COMMENT 'Software or model engine used for valuation.',
    `valuation_method` STRING COMMENT 'Method used for valuation (e.g., DCF, market comparables).',
    `valuation_reason` STRING COMMENT 'Reason for the valuation (e.g., periodic, trigger).',
    `valuation_reference` STRING COMMENT 'External reference code for the valuation.',
    `valuation_source_code` BIGINT COMMENT 'Identifier of the source of valuation data.',
    `valuation_source_name` STRING COMMENT 'Name of the source of valuation data.',
    `valuation_status` STRING COMMENT 'Status of the valuation document.. Valid values are `draft|pending|approved|published|archived`',
    `valuation_timestamp` TIMESTAMP COMMENT 'Date and time when the valuation was performed.',
    CONSTRAINT pk_infrastructure_valuation PRIMARY KEY(`infrastructure_valuation_id`)
) COMMENT 'Specialized valuation record for direct infrastructure assets (toll roads, airports, utilities, pipelines, renewable energy) capturing infrastructure-specific valuation metrics.';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`credit_instrument_valuation` (
    `credit_instrument_valuation_id` BIGINT COMMENT 'Unique identifier for the credit instrument valuation record.',
    `actor_id` BIGINT COMMENT 'Identifier of the valuation agent or firm.',
    `adjustment_id` BIGINT COMMENT 'Identifier of the valuation document.',
    `credit_rating_id` BIGINT COMMENT 'Foreign key linking to risk.credit_rating. Business justification: Credit instrument fair values depend on issuer credit ratings for spread calculations and OAS determination.',
    `instrument_id` BIGINT COMMENT 'Foreign key linking to trade.instrument. Business justification: Credit instrument valuations (bonds, loans) must link to instrument master for position reconciliation, duration/convexity reporting, and regulatory filings.',
    `issuer_esg_rating_id` BIGINT COMMENT 'Foreign key linking to esg.issuer_esg_rating. Business justification: Credit valuations incorporate ESG risk premiums in spread calculations. ESG ratings affect credit spreads and default probability estimates.',
    `portfolio_id` BIGINT COMMENT 'Identifier of the portfolio containing the instrument.',
    `regulatory_reporting_regulatory_filing_id` BIGINT COMMENT 'Identifier for regulatory reporting purposes.',
    `research_yield_curve_id` BIGINT COMMENT 'Foreign key linking to research.research_yield_curve. Business justification: Credit instrument valuations require yield curves for discounting cash flows and calculating spreads.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_asset_valuation. Business justification: Credit instrument valuations are specialized valuations for fixed income instruments.',
    `valuation_cycle_id` BIGINT COMMENT 'Identifier of the valuation cycle.',
    `accrued_interest` DECIMAL(18,4) COMMENT 'Interest accrued since last coupon payment.',
    `book_value` DECIMAL(18,4) COMMENT 'Book value of the instrument.',
    `clean_price` DECIMAL(18,4) COMMENT 'Market price excluding accrued interest.',
    `coupon_rate` DECIMAL(10,6) COMMENT 'Annual coupon rate of the instrument.',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the record was first created.',
    `currency_code` STRING COMMENT 'ISO 4217 currency code for the valuation.',
    `dirty_price` DECIMAL(18,4) COMMENT 'Market price including accrued interest.',
    `face_value` DECIMAL(18,2) COMMENT 'Nominal value of the instrument at maturity.',
    `fair_value` DECIMAL(18,4) COMMENT 'Fair value of the instrument.',
    `gav` DECIMAL(18,4) COMMENT 'Gross asset value of the instrument.',
    `instrument_cusip` STRING COMMENT 'Committee on Uniform Securities Identification Procedures code for the credit instrument.. Valid values are `^[0-9A-Z]{9}$`',
    `instrument_isin` STRING COMMENT 'International Securities Identification Number for the credit instrument.. Valid values are `^[A-Z]{2}[0-9A-Z]{9}[0-9]$`',
    `instrument_type` STRING COMMENT 'Classification of the credit instrument.. Valid values are `IG bond|HY bond|Private credit|Sovereign debt`',
    `market_code` STRING COMMENT 'Identifier of the market where the instrument trades.',
    `market_value` DECIMAL(18,4) COMMENT 'Market value of the instrument.',
    `maturity_date` DATE COMMENT 'Date on which the instrument matures.',
    `nav` DECIMAL(18,4) COMMENT 'Net asset value of the instrument.',
    `oas` DECIMAL(10,6) COMMENT 'Spread over risk‑free rate adjusted for options.',
    `record_audit_created` TIMESTAMP COMMENT 'Audit timestamp of record creation.',
    `record_audit_updated` TIMESTAMP COMMENT 'Audit timestamp of record update.',
    `risk_metric_convexity` DECIMAL(10,4) COMMENT 'Convexity metric of the instrument.',
    `risk_metric_credit_spread` DECIMAL(10,4) COMMENT 'Credit spread metric of the instrument.',
    `risk_metric_duration` DECIMAL(10,4) COMMENT 'Duration metric of the instrument.',
    `updated_at` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `valuation_comments` STRING COMMENT 'Additional comments on the valuation.',
    `valuation_date` DATE COMMENT 'Date on which the valuation was performed.',
    `valuation_document_code` BIGINT COMMENT 'Identifier of the valuation document.',
    `valuation_document_date` DATE COMMENT 'Date of the valuation document.',
    `valuation_document_type` STRING COMMENT 'Type of the valuation document.. Valid values are `PDF|Word|Excel|Image|Other`',
    `valuation_document_url` STRING COMMENT 'URL to the valuation document.',
    `valuation_engine` STRING COMMENT 'Engine or system that performed the valuation.. Valid values are `SimCorp|BlackRock|Bloomberg|Aladdin`',
    `valuation_method` STRING COMMENT 'Method used for the valuation.. Valid values are `MTM|DCF|WACC|Fair Value Hierarchy`',
    `valuation_source_code` BIGINT COMMENT 'Identifier of the source system for the valuation.',
    `valuation_status` STRING COMMENT 'Current status of the valuation.. Valid values are `Pending|Approved|Rejected|In Review|Completed`',
    `valuation_time` TIMESTAMP COMMENT 'Timestamp of the valuation event.',
    `ytm` DECIMAL(10,6) COMMENT 'Yield to maturity of the instrument.',
    CONSTRAINT pk_credit_instrument_valuation PRIMARY KEY(`credit_instrument_valuation_id`)
) COMMENT 'Valuation record for credit and fixed income instruments including IG bonds, HY bonds, private credit, and sovereign debt. Captures instrument identifier (ISIN/CUSIP), face value, clean price, dirty price, accrued interest, YTM (Yield to Maturity), OAS';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`price_exception` (
    `price_exception_id` BIGINT COMMENT 'Globally unique identifier for the price exception record.',
    `actor_id` BIGINT COMMENT 'Identifier of the agent that performed the valuation.',
    `adjustment_id` BIGINT COMMENT 'Identifier of the supporting document for the exception.',
    `exception_cycle_id` BIGINT COMMENT 'Identifier of the valuation cycle in which the exception occurred.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Identifier of the valuation record related to the exception.',
    `instrument_id` BIGINT COMMENT 'Foreign key linking to trade.instrument. Business justification: Price exceptions flag valuation anomalies per instrument. Linking to instrument master enables exception tracking, audit trails, and valuation committee review by security.',
    `limit_breach_id` BIGINT COMMENT 'Foreign key linking to risk.limit_breach. Business justification: Price exceptions directly cause limit breaches when valuations move outside tolerance. Audit trail requires linking the valuation exception to the resulting breach for regulatory compliance.',
    `rule_breach_id` BIGINT COMMENT 'Foreign key linking to compliance.rule_breach. Business justification: Price exceptions may constitute compliance rule breaches. Links pricing anomalies to formal breach records for regulatory reporting and remediation tracking.',
    `exception_created_at` TIMESTAMP COMMENT 'When the exception record was first created.',
    `exception_cycle_frequency` STRING COMMENT 'Frequency of the valuation cycle.',
    `exception_description` STRING COMMENT 'Detailed description of the exception.',
    `exception_document_code` BIGINT COMMENT 'Identifier of the supporting document for the exception.',
    `exception_document_hash` STRING COMMENT 'Hash of the supporting document for integrity.',
    `exception_document_signed_at` TIMESTAMP COMMENT 'Timestamp when the document was signed.',
    `exception_document_signed_by` STRING COMMENT 'Name of the person who signed the document.',
    `exception_document_status` STRING COMMENT 'Status of the supporting document.',
    `exception_document_type` STRING COMMENT 'Type of the supporting document.',
    `exception_document_url` STRING COMMENT 'URL to the supporting document.',
    `exception_reason` STRING COMMENT 'Short textual reason for the exception.',
    `exception_record_audit_created` TIMESTAMP COMMENT 'Audit timestamp of record creation.',
    `exception_record_audit_updated` TIMESTAMP COMMENT 'Audit timestamp of record update.',
    `exception_remarks` STRING COMMENT 'Additional remarks about the exception.',
    `exception_severity` STRING COMMENT 'Severity level of the exception.. Valid values are `low|medium|high|critical`',
    `exception_source` STRING COMMENT 'System or party that generated the exception.',
    `exception_source_code` BIGINT COMMENT 'Identifier of the source record that triggered the exception.',
    `exception_source_system` STRING COMMENT 'Underlying system that produced the exception.',
    `exception_status` STRING COMMENT 'Current status of the exception record.. Valid values are `open|resolved|acknowledged`',
    `exception_threshold_unit` STRING COMMENT 'Unit of the threshold value.. Valid values are `percent|absolute`',
    `exception_threshold_value` DECIMAL(38,10) COMMENT 'Threshold value exceeded by the exception.',
    `exception_timestamp` TIMESTAMP COMMENT 'When the exception was detected.',
    `exception_type` STRING COMMENT 'The type of exception that occurred during the valuation cycle.. Valid values are `stale_price|missing_price|price_move_threshold|source_disagreement|nav`',
    `exception_updated_at` TIMESTAMP COMMENT 'When the exception record was last updated.',
    `exception_valuation_comments` STRING COMMENT 'Additional comments about the valuation exception.',
    `exception_valuation_date` DATE COMMENT 'Date of the valuation that triggered the exception.',
    `exception_valuation_engine` STRING COMMENT 'Engine that performed the valuation.',
    `exception_valuation_method` STRING COMMENT 'Method used for the valuation.',
    `exception_valuation_reason` STRING COMMENT 'Reason for the valuation exception.',
    `exception_valuation_source_code` BIGINT COMMENT 'Identifier of the source of the valuation data.',
    `exception_valuation_source_description` STRING COMMENT 'Description of the valuation source.',
    `exception_valuation_source_name` STRING COMMENT 'Name of the source of the valuation data.',
    `exception_valuation_status` STRING COMMENT 'Status of the valuation related to the exception.',
    `exception_valuation_time` TIMESTAMP COMMENT 'Timestamp of the valuation that triggered the exception.',
    `exception_value` DECIMAL(38,10) COMMENT 'The numeric value that caused the exception.',
    CONSTRAINT pk_price_exception PRIMARY KEY(`price_exception_id`)
) COMMENT 'Operational data-quality exception record raised during a valuation cycle when a price or NAV input fails a validation tolerance — stale price, missing price, price move beyond threshold, source disagreement (Bloomberg vs broker quote), or NAV';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`exclusion_screening` (
    `exclusion_screening_id` BIGINT COMMENT 'Primary key for the exclusion_screening association',
    `employee_id` BIGINT COMMENT 'Identifier of the ESG analyst or compliance officer who performed or approved this screening',
    `exclusion_list_id` BIGINT COMMENT 'Foreign key linking to the exclusion list entry against which the asset is screened',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to the asset valuation record being screened',
    `check_date` DATE COMMENT 'Date on which this exclusion screening was performed against the asset valuation',
    `exclusion_screening_status` STRING COMMENT 'Outcome of the exclusion screening - whether the asset passed, failed, or was flagged for review',
    `override_flag` BOOLEAN COMMENT 'Boolean indicating whether an Investment Committee override was granted for this exclusion check',
    `override_reason` STRING COMMENT 'Detailed justification for why an exclusion override was granted by the Investment Committee',
    CONSTRAINT pk_exclusion_screening PRIMARY KEY(`exclusion_screening_id`)
) COMMENT 'This association product represents the Exclusion Screening event between an asset valuation and an exclusion list entry. It captures the compliance screening process where each investment asset is checked against the funds exclusion policies.';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`compliance_requirement` (
    `compliance_requirement_id` BIGINT COMMENT 'Unique identifier for the methodology-rule compliance requirement record',
    `methodology_id` BIGINT COMMENT 'Foreign key linking to the valuation methodology being assessed for compliance',
    `rule_id` BIGINT COMMENT 'Foreign key linking to the compliance rule that governs the methodology',
    `compliance_requirement_status` STRING COMMENT 'Current compliance status of the methodology against this specific rule',
    `created_at` TIMESTAMP COMMENT 'Timestamp when this compliance requirement record was created',
    `effective_from` DATE COMMENT 'Date from which the methodology became subject to this compliance rule',
    `effective_until` DATE COMMENT 'Date until which the compliance requirement applies; null for ongoing requirements',
    `next_review_date` DATE COMMENT 'Scheduled date for the next compliance review of this methodology-rule pairing',
    `notes` STRING COMMENT 'Free-text notes documenting compliance findings, exceptions, or remediation actions',
    `updated_at` TIMESTAMP COMMENT 'Timestamp of the most recent update to this compliance requirement record',
    `validated_by` BIGINT COMMENT 'User ID of the compliance officer who performed the last validation',
    `validation_date` DATE COMMENT 'Date of the most recent compliance validation or review for this methodology-rule pairing',
    CONSTRAINT pk_compliance_requirement PRIMARY KEY(`compliance_requirement_id`)
) COMMENT 'This association product represents the compliance contract between a valuation methodology and a compliance rule. It captures which regulatory and internal rules each valuation methodology must adhere to, along with the compliance status, effective';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`filing_inclusion` (
    `filing_inclusion_id` BIGINT COMMENT 'Primary key for the filing_inclusion association',
    `regulatory_filing_id` BIGINT COMMENT 'Foreign key linking to the regulatory filing containing this valuation',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to the asset valuation record being included in the filing',
    `filing_date` DATE COMMENT 'The date when this specific valuation was included or processed for the filing',
    `inclusion_status` STRING COMMENT 'Status indicating whether the valuation was included in the filing, excluded, or adjusted for regulatory purposes',
    `reported_value` DECIMAL(38,10) COMMENT 'The actual value reported in the regulatory filing, which may differ from the fair_value due to regulatory adjustments, currency conversions, or timing differences',
    `variance_amount` DECIMAL(38,10) COMMENT 'The difference between the fair_value from the valuation record and the reported_value in the filing, used for reconciliation and audit purposes',
    CONSTRAINT pk_filing_inclusion PRIMARY KEY(`filing_inclusion_id`)
) COMMENT 'This association product represents the inclusion of a specific asset valuation in a regulatory filing. It captures the regulatory disclosure relationship between valuations and filings, tracking which valuations were reported to which regulatory';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`quote_source` (
    `quote_source_id` BIGINT COMMENT 'Primary key for quote_source',
    `vendor_id` BIGINT COMMENT 'Reference to the vendor master record for the data provider organization supplying this quote source.',
    `api_endpoint_url` STRING COMMENT 'Base URL for the API endpoint used to retrieve pricing data from this source. Confidential for security purposes.',
    `approval_date` DATE COMMENT 'Date when this quote source was formally approved for use in production valuation processes.',
    `approved_by` STRING COMMENT 'Name or identifier of the person or committee that approved this quote source for use in valuation processes.',
    `asset_class_coverage` STRING COMMENT 'Comma-separated list of asset classes covered by this source (e.g., equities, fixed_income, derivatives, real_estate, private_equity).',
    `authentication_method` STRING COMMENT 'Method used to authenticate with the quote source API for data retrieval.',
    `business_days_calendar` STRING COMMENT 'Reference to the holiday calendar used by this source to determine business days for pricing availability.',
    `contact_email` STRING COMMENT 'Email address of the primary contact at the quote source provider for operational communications.',
    `contact_name` STRING COMMENT 'Name of the primary contact person at the quote source provider for operational inquiries and escalations.',
    `contact_phone` STRING COMMENT 'Phone number of the primary contact at the quote source provider for urgent escalations.',
    `contract_reference` STRING COMMENT 'Reference number or identifier for the commercial agreement governing data usage from this source. Used for license compliance tracking.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this quote source record was first created in the system.',
    `currency_coverage` STRING COMMENT 'Comma-separated list of ISO 4217 currency codes for which this source provides pricing data (e.g., USD, EUR, GBP, JPY).',
    `cut_off_time` STRING COMMENT 'Daily cut-off time (HH:MM format in source timezone) after which prices are considered next-day values for NAV calculation.',
    `data_feed_format` STRING COMMENT 'Technical format in which pricing data is received from this source. Used for integration and parsing configuration.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Internal quality rating (0-100) based on historical accuracy, timeliness, and completeness of data from this source.',
    `effective_from_date` DATE COMMENT 'Date from which this quote source became active and available for use in valuation processes.',
    `effective_to_date` DATE COMMENT 'Date until which this quote source is valid. Null indicates currently active with no planned termination.',
    `fair_value_hierarchy_level` STRING COMMENT 'IFRS 13 / ASC 820 fair value hierarchy classification indicating the observability of inputs from this source. Level 1 is quoted prices in active markets.',
    `geographic_coverage` STRING COMMENT 'Regions or markets covered by this quote source (e.g., global, North America, EMEA, APAC). Determines applicability for regional asset valuations.',
    `is_independent_source` BOOLEAN COMMENT 'Indicates whether the source is independent from the fund manager for regulatory compliance. Required for Level 3 asset valuations.',
    `is_primary_source` BOOLEAN COMMENT 'Indicates whether this is the primary (preferred) quote source for its covered asset classes. True means primary source.',
    `is_regulatory_approved` BOOLEAN COMMENT 'Indicates whether this quote source has been approved by relevant regulatory bodies for use in official NAV calculations.',
    `last_validation_date` DATE COMMENT 'Date when the quote source was last validated for data quality and compliance with internal standards.',
    `license_expiry_date` DATE COMMENT 'Date when the current data license agreement expires. Triggers renewal workflow notifications.',
    `minimum_quote_size` DECIMAL(18,2) COMMENT 'Minimum notional or quantity threshold for which quotes from this source are considered representative of market prices.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review of this quote source for continued suitability and compliance.',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, special handling instructions, or known limitations of this quote source.',
    `pricing_methodology` STRING COMMENT 'Description of the valuation methodology used by the source (e.g., mark-to-market, mark-to-model, DCF, comparable transactions, NAV-based).',
    `priority_rank` BIGINT COMMENT 'Numeric ranking indicating preference order when multiple sources provide prices for the same instrument. Lower values indicate higher priority.',
    `source_code` STRING COMMENT 'Standardized alphanumeric code uniquely identifying the quote source within the organization. Used for system integrations and reporting.',
    `source_name` STRING COMMENT 'Full legal or commercial name of the quote source provider (e.g., Bloomberg, Reuters, ICE Data Services, Markit).',
    `source_type` STRING COMMENT 'Classification of the quote source by origin type. Determines data governance and validation rules applied to received prices.',
    `staleness_threshold_hours` BIGINT COMMENT 'Maximum number of hours a price from this source can be considered valid before requiring refresh or escalation.',
    `quote_source_status` STRING COMMENT 'Current operational status of the quote source. Only active sources are used in production valuation processes.',
    `supports_bid_ask_spread` BOOLEAN COMMENT 'Indicates whether the source provides both bid and ask prices enabling spread analysis for liquidity assessment.',
    `supports_historical_prices` BOOLEAN COMMENT 'Indicates whether the source provides access to historical pricing data for back-testing and performance attribution.',
    `timezone` STRING COMMENT 'IANA timezone identifier for the quote source (e.g., America/New_York, Europe/London). Used for timestamp normalization.',
    `tolerance_threshold_percent` DECIMAL(5,2) COMMENT 'Maximum acceptable percentage deviation from prior price before triggering price challenge workflow.',
    `update_frequency` STRING COMMENT 'Frequency at which the quote source provides updated pricing data. Critical for determining staleness thresholds in valuation processes.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this quote source record was last modified.',
    CONSTRAINT pk_quote_source PRIMARY KEY(`quote_source_id`)
) COMMENT 'Master reference table for quote_source. Referenced by quote_source_id.';

CREATE OR REPLACE TABLE `asset_management`.`valuation`.`valuation_document` (
    `valuation_document_id` BIGINT COMMENT 'Primary key for valuation_document',
    `actor_id` BIGINT COMMENT 'Reference to the independent valuation agent or firm that prepared or reviewed the valuation.',
    `asset_id` BIGINT COMMENT 'Reference to the asset or investment being valued in this document.',
    `employee_id` BIGINT COMMENT 'Reference to the internal analyst who prepared the valuation document.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio containing the asset being valued.',
    `reviewed_by_analyst_employee_id` BIGINT COMMENT 'Reference to the senior analyst or manager who reviewed and approved the valuation.',
    `superseded_document_id` BIGINT COMMENT 'Reference to the prior valuation document that this document supersedes.',
    `approval_date` DATE COMMENT 'Date when the valuation document received final approval for use in reporting.',
    `asset_class` STRING COMMENT 'Broad classification of the asset type being valued (public equity, private equity, real estate, infrastructure, natural resources, credit).',
    `capitalization_rate_percent` DECIMAL(8,4) COMMENT 'Cap rate used in real estate and infrastructure valuations to convert income to value.',
    `control_premium_percent` DECIMAL(8,4) COMMENT 'Premium applied to reflect controlling interest in the valued entity.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this valuation document record was first created in the system.',
    `discount_rate_percent` DECIMAL(8,4) COMMENT 'Discount rate applied in discounted cash flow (DCF) valuation models, expressed as a percentage.',
    `document_file_path` STRING COMMENT 'Storage location or URI of the valuation document file in the document management system.',
    `document_number` STRING COMMENT 'Externally-known business identifier for the valuation document, used for tracking and audit trail purposes.',
    `document_status` STRING COMMENT 'Current lifecycle status of the valuation document within the approval workflow.',
    `document_title` STRING COMMENT 'Human-readable title or name of the valuation document for identification and reporting purposes.',
    `document_type` STRING COMMENT 'Classification of the valuation document indicating the methodology or purpose (NAV, GAV, mark-to-market, DCF, fair value, independent appraisal).',
    `document_version` STRING COMMENT 'Version number of the valuation document for tracking revisions and amendments.',
    `ebitda_multiple` DECIMAL(10,4) COMMENT 'Enterprise value to EBITDA multiple used in comparable company or transaction analysis.',
    `effective_from_date` DATE COMMENT 'Date from which this valuation document becomes the authoritative valuation for the asset.',
    `effective_until_date` DATE COMMENT 'Date until which this valuation document remains valid before requiring update or supersession.',
    `fair_value_amount` DECIMAL(28,6) COMMENT 'The concluded fair value of the asset as determined by the valuation analysis.',
    `fair_value_hierarchy_level` STRING COMMENT 'IFRS 13 / ASC 820 fair value hierarchy classification indicating the observability of inputs used in valuation (Level 1, 2, or 3).',
    `gross_asset_value` DECIMAL(28,6) COMMENT 'Total gross asset value before deduction of liabilities, fees, and carried interest as determined in the valuation.',
    `illiquidity_discount_percent` DECIMAL(8,4) COMMENT 'Discount applied to reflect lack of marketability for private or illiquid assets.',
    `is_audited` BOOLEAN COMMENT 'Indicates whether the valuation has been reviewed or audited by external auditors.',
    `is_independent_valuation` BOOLEAN COMMENT 'Indicates whether the valuation was performed by an independent third-party valuation agent.',
    `is_material_change` BOOLEAN COMMENT 'Indicates whether this valuation reflects a material change from the prior valuation period.',
    `net_asset_value` DECIMAL(28,6) COMMENT 'Net asset value after deducting liabilities, accrued fees, and other obligations from gross asset value.',
    `next_valuation_due_date` DATE COMMENT 'Scheduled date for the next periodic valuation update of the asset.',
    `preparation_date` DATE COMMENT 'Date when the valuation document was initially prepared.',
    `prior_valuation_amount` DECIMAL(28,6) COMMENT 'Fair value from the immediately preceding valuation for comparison and change analysis.',
    `revenue_multiple` DECIMAL(10,4) COMMENT 'Enterprise value to revenue multiple used in market-based valuation approaches.',
    `review_date` DATE COMMENT 'Date when the valuation document was reviewed by senior personnel.',
    `terminal_growth_rate_percent` DECIMAL(8,4) COMMENT 'Long-term growth rate assumption used in terminal value calculations for DCF models.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this valuation document record was last modified.',
    `valuation_change_amount` DECIMAL(28,6) COMMENT 'Absolute change in fair value from the prior valuation period.',
    `valuation_change_percent` DECIMAL(10,4) COMMENT 'Percentage change in fair value from the prior valuation period.',
    `valuation_confidence_level` STRING COMMENT 'Internal assessment of confidence in the valuation conclusion based on data quality and methodology reliability.',
    `valuation_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the valuation is denominated.',
    `valuation_date` DATE COMMENT 'The effective date as of which the valuation is determined, representing the point-in-time fair value assessment.',
    `valuation_frequency` STRING COMMENT 'Frequency at which the asset is valued (daily for liquid assets, quarterly/annual for illiquid).',
    `valuation_methodology` STRING COMMENT 'Primary valuation methodology applied in the document (market approach, income approach, cost approach, NAV approach, or hybrid).',
    `valuation_notes` STRING COMMENT 'Free-text notes capturing key assumptions, limitations, or qualifications related to the valuation.',
    `wacc_percent` DECIMAL(8,4) COMMENT 'Weighted average cost of capital used in DCF models for enterprise valuation, expressed as a percentage.',
    CONSTRAINT pk_valuation_document PRIMARY KEY(`valuation_document_id`)
) COMMENT 'Master reference table for valuation_document. Referenced by document_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ADD CONSTRAINT `fk_valuation_valuation_asset_valuation_fair_value_hierarchy_id` FOREIGN KEY (`fair_value_hierarchy_id`) REFERENCES `asset_management`.`valuation`.`fair_value_hierarchy`(`fair_value_hierarchy_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ADD CONSTRAINT `fk_valuation_valuation_asset_valuation_input_id` FOREIGN KEY (`input_id`) REFERENCES `asset_management`.`valuation`.`input`(`input_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ADD CONSTRAINT `fk_valuation_valuation_asset_valuation_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ADD CONSTRAINT `fk_valuation_valuation_asset_valuation_valuation_fx_rate_id` FOREIGN KEY (`valuation_fx_rate_id`) REFERENCES `asset_management`.`valuation`.`valuation_fx_rate`(`valuation_fx_rate_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ADD CONSTRAINT `fk_valuation_valuation_asset_valuation_valuation_policy_id` FOREIGN KEY (`valuation_policy_id`) REFERENCES `asset_management`.`valuation`.`valuation_policy`(`valuation_policy_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ADD CONSTRAINT `fk_valuation_valuation_asset_valuation_valuation_yield_curve_id` FOREIGN KEY (`valuation_yield_curve_id`) REFERENCES `asset_management`.`valuation`.`valuation_yield_curve`(`valuation_yield_curve_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ADD CONSTRAINT `fk_valuation_valuation_nav_record_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ADD CONSTRAINT `fk_valuation_dcf_model_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ADD CONSTRAINT `fk_valuation_wacc_calculation_dcf_model_id` FOREIGN KEY (`dcf_model_id`) REFERENCES `asset_management`.`valuation`.`dcf_model`(`dcf_model_id`);
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ADD CONSTRAINT `fk_valuation_wacc_calculation_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ADD CONSTRAINT `fk_valuation_fair_value_hierarchy_hierarchy_parent_fair_value_hierarchy_id` FOREIGN KEY (`hierarchy_parent_fair_value_hierarchy_id`) REFERENCES `asset_management`.`valuation`.`fair_value_hierarchy`(`fair_value_hierarchy_id`);
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ADD CONSTRAINT `fk_valuation_indep_valuation_engagement_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`valuation`.`adjustment` ADD CONSTRAINT `fk_valuation_adjustment_cycle_id` FOREIGN KEY (`cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`valuation`.`adjustment` ADD CONSTRAINT `fk_valuation_adjustment_valuation_document_id` FOREIGN KEY (`valuation_document_id`) REFERENCES `asset_management`.`valuation`.`valuation_document`(`valuation_document_id`);
ALTER TABLE `asset_management`.`valuation`.`adjustment` ADD CONSTRAINT `fk_valuation_adjustment_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ADD CONSTRAINT `fk_valuation_market_price_snapshot_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ADD CONSTRAINT `fk_valuation_comparable_transaction_adjustment_id` FOREIGN KEY (`adjustment_id`) REFERENCES `asset_management`.`valuation`.`adjustment`(`adjustment_id`);
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ADD CONSTRAINT `fk_valuation_comparable_transaction_methodology_id` FOREIGN KEY (`methodology_id`) REFERENCES `asset_management`.`valuation`.`methodology`(`methodology_id`);
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ADD CONSTRAINT `fk_valuation_comparable_transaction_transaction_valuation_cycle_id` FOREIGN KEY (`transaction_valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`valuation`.`methodology` ADD CONSTRAINT `fk_valuation_methodology_adjustment_id` FOREIGN KEY (`adjustment_id`) REFERENCES `asset_management`.`valuation`.`adjustment`(`adjustment_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ADD CONSTRAINT `fk_valuation_valuation_review_cycle_id` FOREIGN KEY (`cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ADD CONSTRAINT `fk_valuation_valuation_review_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ADD CONSTRAINT `fk_valuation_valuation_review_valuation_document_id` FOREIGN KEY (`valuation_document_id`) REFERENCES `asset_management`.`valuation`.`valuation_document`(`valuation_document_id`);
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ADD CONSTRAINT `fk_valuation_private_asset_valuation_adjustment_id` FOREIGN KEY (`adjustment_id`) REFERENCES `asset_management`.`valuation`.`adjustment`(`adjustment_id`);
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ADD CONSTRAINT `fk_valuation_private_asset_valuation_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ADD CONSTRAINT `fk_valuation_private_asset_valuation_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ADD CONSTRAINT `fk_valuation_broker_quote_quote_source_id` FOREIGN KEY (`quote_source_id`) REFERENCES `asset_management`.`valuation`.`quote_source`(`quote_source_id`);
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ADD CONSTRAINT `fk_valuation_broker_quote_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ADD CONSTRAINT `fk_valuation_nav_liability_adjustment_id` FOREIGN KEY (`adjustment_id`) REFERENCES `asset_management`.`valuation`.`adjustment`(`adjustment_id`);
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ADD CONSTRAINT `fk_valuation_nav_liability_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ADD CONSTRAINT `fk_valuation_nav_liability_valuation_nav_record_id` FOREIGN KEY (`valuation_nav_record_id`) REFERENCES `asset_management`.`valuation`.`valuation_nav_record`(`valuation_nav_record_id`);
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ADD CONSTRAINT `fk_valuation_sensitivity_valuation_asset_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ADD CONSTRAINT `fk_valuation_sensitivity_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ADD CONSTRAINT `fk_valuation_sensitivity_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ADD CONSTRAINT `fk_valuation_real_estate_appraisal_real_adjustment_id` FOREIGN KEY (`real_adjustment_id`) REFERENCES `asset_management`.`valuation`.`adjustment`(`adjustment_id`);
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ADD CONSTRAINT `fk_valuation_real_estate_appraisal_real_property_valuation_document_adjustment_id` FOREIGN KEY (`real_property_valuation_document_adjustment_id`) REFERENCES `asset_management`.`valuation`.`adjustment`(`adjustment_id`);
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ADD CONSTRAINT `fk_valuation_real_estate_appraisal_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ADD CONSTRAINT `fk_valuation_infrastructure_valuation_adjustment_id` FOREIGN KEY (`adjustment_id`) REFERENCES `asset_management`.`valuation`.`adjustment`(`adjustment_id`);
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ADD CONSTRAINT `fk_valuation_infrastructure_valuation_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ADD CONSTRAINT `fk_valuation_infrastructure_valuation_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ADD CONSTRAINT `fk_valuation_credit_instrument_valuation_adjustment_id` FOREIGN KEY (`adjustment_id`) REFERENCES `asset_management`.`valuation`.`adjustment`(`adjustment_id`);
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ADD CONSTRAINT `fk_valuation_credit_instrument_valuation_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ADD CONSTRAINT `fk_valuation_credit_instrument_valuation_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`valuation`.`price_exception` ADD CONSTRAINT `fk_valuation_price_exception_adjustment_id` FOREIGN KEY (`adjustment_id`) REFERENCES `asset_management`.`valuation`.`adjustment`(`adjustment_id`);
ALTER TABLE `asset_management`.`valuation`.`price_exception` ADD CONSTRAINT `fk_valuation_price_exception_exception_cycle_id` FOREIGN KEY (`exception_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`valuation`.`price_exception` ADD CONSTRAINT `fk_valuation_price_exception_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`valuation`.`exclusion_screening` ADD CONSTRAINT `fk_valuation_exclusion_screening_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`valuation`.`compliance_requirement` ADD CONSTRAINT `fk_valuation_compliance_requirement_methodology_id` FOREIGN KEY (`methodology_id`) REFERENCES `asset_management`.`valuation`.`methodology`(`methodology_id`);
ALTER TABLE `asset_management`.`valuation`.`filing_inclusion` ADD CONSTRAINT `fk_valuation_filing_inclusion_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` SET TAGS ('dbx_subdomain' = 'fair_value');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation ID (VAL_ASSET_VAL_ID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Agent ID (VAL_AGENT_ID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `asset_id` SET TAGS ('dbx_business_glossary_term' = 'Asset ID (ASSET_ID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `credit_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Manager ID (PORTFOLIO_MANAGER_ID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `fair_value_hierarchy_id` SET TAGS ('dbx_business_glossary_term' = 'Fair Value Hierarchy Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `input_id` SET TAGS ('dbx_business_glossary_term' = 'Input Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `issuer_esg_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer Esg Rating Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID (PORTFOLIO_ID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle ID (VAL_CYCLE_ID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_fx_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Fx Rate Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_yield_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Yield Curve Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `asset_category` SET TAGS ('dbx_business_glossary_term' = 'Asset Category (ASSET_CATEGORY)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class (ASSET_CLASS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `asset_currency` SET TAGS ('dbx_business_glossary_term' = 'Asset Currency (ASSET_CURRENCY)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `asset_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `asset_isin` SET TAGS ('dbx_business_glossary_term' = 'Asset ISIN (ASSET_ISIN)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `asset_isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[0-9A-Z]{9}[0-9]$');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `asset_name` SET TAGS ('dbx_business_glossary_term' = 'Asset Name (ASSET_NAME)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `asset_sector` SET TAGS ('dbx_business_glossary_term' = 'Asset Sector (ASSET_SECTOR)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `asset_subclass` SET TAGS ('dbx_business_glossary_term' = 'Asset Subclass (ASSET_SUBCLASS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `asset_type` SET TAGS ('dbx_business_glossary_term' = 'Asset Type (ASSET_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `book_value` SET TAGS ('dbx_business_glossary_term' = 'Book Value (BOOK_VALUE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `fair_value` SET TAGS ('dbx_business_glossary_term' = 'Fair Value (FAIR_VALUE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `gav` SET TAGS ('dbx_business_glossary_term' = 'Gross Asset Value (GAV)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `market_value` SET TAGS ('dbx_business_glossary_term' = 'Market Value (MARKET_VALUE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `nav` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `portfolio_type` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Type (PORTFOLIO_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `portfolio_type` SET TAGS ('dbx_value_regex' = 'public|private|fund_of_funds|hedge_fund');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_comments` SET TAGS ('dbx_business_glossary_term' = 'Valuation Comments (VAL_COMMENTS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_cycle_cycle_number` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Number (VAL_CYCLE_NUM)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_cycle_cycle_year` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Year (VAL_CYCLE_YEAR)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_cycle_end_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle End Date (VAL_CYCLE_END_DATE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_cycle_frequency` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Frequency (VAL_CYCLE_FREQ)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_cycle_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annual');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_cycle_start_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Start Date (VAL_CYCLE_START_DATE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_cycle_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Status (VAL_CYCLE_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_cycle_status` SET TAGS ('dbx_value_regex' = 'scheduled|running|completed|cancelled');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date (VAL_DATE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_document_code` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document ID (VAL_DOC_ID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_document_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Date (VAL_DOC_DATE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_document_hash` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Hash (VAL_DOC_HASH)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_document_signed_at` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Signed At (VAL_DOC_SIGNED_AT)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_document_signed_by` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Signed By (VAL_DOC_SIGNED_BY)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_document_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Status (VAL_DOC_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_document_status` SET TAGS ('dbx_value_regex' = 'draft|final|archived');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_document_type` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Type (VAL_DOC_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_document_type` SET TAGS ('dbx_value_regex' = 'pdf|docx|xlsx|txt');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_document_url` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document URL (VAL_DOC_URL)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_document_version` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Version (VAL_DOC_VERSION)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_engine` SET TAGS ('dbx_business_glossary_term' = 'Valuation Engine (VAL_ENGINE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_engine` SET TAGS ('dbx_value_regex' = 'internal|external|third_party');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method (VAL_METHOD)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'DCF|market_price|appraisal|fair_value_hierarchy');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_reason` SET TAGS ('dbx_business_glossary_term' = 'Valuation Reason (VAL_REASON)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Status (VAL_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_status` SET TAGS ('dbx_value_regex' = 'active|archived|pending|rejected');
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ALTER COLUMN `valuation_time` SET TAGS ('dbx_business_glossary_term' = 'Valuation Time (VAL_TIME)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` SET TAGS ('dbx_subdomain' = 'fair_value');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `valuation_nav_record_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation NAV Record ID (VAL_NAV_RECORD_ID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `regulatory_filing_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle ID (VAL_CYCLE_ID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Record Created At (CREATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (CURR_CODE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `fund_code` SET TAGS ('dbx_business_glossary_term' = 'Fund Code (FUND_CODE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `fund_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,10}$');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `fund_name` SET TAGS ('dbx_business_glossary_term' = 'Fund Name (FUND_NAME)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `nav_per_unit` SET TAGS ('dbx_business_glossary_term' = 'NAV per Unit (NAV_PER_UNIT)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `net_asset_value` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `number_of_units` SET TAGS ('dbx_business_glossary_term' = 'Number of Units (NUM_UNITS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Created (AUDIT_CREATED)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Updated (AUDIT_UPDATED)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `remarks` SET TAGS ('dbx_business_glossary_term' = 'Remarks (REMARKS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `total_gross_asset_value` SET TAGS ('dbx_business_glossary_term' = 'Total Gross Asset Value (TOTAL_GROSS_AV)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `total_liabilities` SET TAGS ('dbx_business_glossary_term' = 'Total Liabilities (TOTAL_LIABILITIES)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Record Updated At (UPDATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `valuation_cycle_frequency` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Frequency (VAL_CYCLE_FREQ)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `valuation_cycle_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annual');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date (VAL_DATE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method (VAL_METHOD)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'MTM|DCF|WACC|FV_L1|FV_L2|FV_L3');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `valuation_reference` SET TAGS ('dbx_business_glossary_term' = 'Valuation Reference (VAL_REF)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `valuation_reference` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,20}$');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `valuation_source_code` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source ID (VAL_SRC_ID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `valuation_source_description` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source Description (VAL_SRC_DESC)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `valuation_source_name` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source Name (VAL_SRC_NAME)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `valuation_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Status (VAL_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ALTER COLUMN `valuation_status` SET TAGS ('dbx_value_regex' = 'pending|completed|approved|rejected|error');
ALTER TABLE `asset_management`.`valuation`.`cycle` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`valuation`.`cycle` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`cycle` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`cycle` SET TAGS ('dbx_subdomain' = 'governance_oversight');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Cycle ID (CYCLE_ID)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `regulatory_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Calendar Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `approval_by` SET TAGS ('dbx_business_glossary_term' = 'Cycle Approval By (CYCLE_APPROVAL_BY)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `approval_comments` SET TAGS ('dbx_business_glossary_term' = 'Cycle Approval Comments (CYCLE_APPROVAL_COMMENTS)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Cycle Approval Timestamp (CYCLE_APPROVAL_DATE)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Cycle Created Timestamp (CYCLE_CREATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `cycle_status` SET TAGS ('dbx_business_glossary_term' = 'Cycle Status (CYCLE_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `cycle_status` SET TAGS ('dbx_value_regex' = 'open|in-progress|completed|cancelled|archived');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `cycle_type` SET TAGS ('dbx_business_glossary_term' = 'Cycle Type (CYCLE_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `cycle_type` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|annual|custom');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `cycle_description` SET TAGS ('dbx_business_glossary_term' = 'Cycle Description (CYCLE_DESCRIPTION)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Cycle End Date (CYCLE_END_DATE)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `identifier` SET TAGS ('dbx_business_glossary_term' = 'Cycle Identifier (CYCLE_IDENTIFIER)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `is_archived` SET TAGS ('dbx_business_glossary_term' = 'Cycle Archived Flag (CYCLE_IS_ARCHIVED)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `is_finalized` SET TAGS ('dbx_business_glossary_term' = 'Cycle Finalized Flag (CYCLE_IS_FINALIZED)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `is_locked` SET TAGS ('dbx_business_glossary_term' = 'Cycle Locked Flag (CYCLE_IS_LOCKED)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Cycle Number (CYCLE_NUMBER)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `number_month` SET TAGS ('dbx_business_glossary_term' = 'Cycle Number Month (CYCLE_NUMBER_MONTH)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `number_quarter` SET TAGS ('dbx_business_glossary_term' = 'Cycle Number Quarter (CYCLE_NUMBER_QUARTER)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `number_year` SET TAGS ('dbx_business_glossary_term' = 'Cycle Number Year (CYCLE_NUMBER_YEAR)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `number_year_month` SET TAGS ('dbx_business_glossary_term' = 'Cycle Number Year-Month (CYCLE_NUMBER_YEAR_MONTH)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `number_year_month_day` SET TAGS ('dbx_business_glossary_term' = 'Cycle Number Year-Month-Day (CYCLE_NUMBER_YEAR_MONTH_DAY)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `number_year_quarter` SET TAGS ('dbx_business_glossary_term' = 'Cycle Number Year-Quarter (CYCLE_NUMBER_YEAR_QUARTER)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `number_year_quarter_day` SET TAGS ('dbx_business_glossary_term' = 'Cycle Number Year-Quarter-Day (CYCLE_NUMBER_YEAR_QUARTER_DAY)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `number_year_quarter_month` SET TAGS ('dbx_business_glossary_term' = 'Cycle Number Year-Quarter-Month (CYCLE_NUMBER_YEAR_QUARTER_MONTH)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `number_year_quarter_month_day` SET TAGS ('dbx_business_glossary_term' = 'Cycle Number Year-Quarter-Month-Day (CYCLE_NUMBER_YEAR_QUARTER_MONTH_DAY)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `number_year_quarter_month_day_time` SET TAGS ('dbx_business_glossary_term' = 'Cycle Number Year-Quarter-Month-Day-Time (CYCLE_NUMBER_YEAR_QUARTER_MONTH_DAY_TIME)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `number_year_quarter_month_day_time_millis` SET TAGS ('dbx_business_glossary_term' = 'Cycle Number Year-Quarter-Month-Day-Time-Millis (CYCLE_NUMBER_YEAR_QUARTER_MONTH_DAY_TIME_MILLIS)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `number_year_quarter_month_day_time_nanos` SET TAGS ('dbx_business_glossary_term' = 'Cycle Number Year-Quarter-Month-Day-Time-Nanos (CYCLE_NUMBER_YEAR_QUARTER_MONTH_DAY_TIME_NANOS)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `number_year_quarter_month_day_time_seconds` SET TAGS ('dbx_business_glossary_term' = 'Cycle Number Year-Quarter-Month-Day-Time-Seconds (CYCLE_NUMBER_YEAR_QUARTER_MONTH_DAY_TIME_SECONDS)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Cycle Start Date (CYCLE_START_DATE)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Cycle Updated Timestamp (CYCLE_UPDATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Cycle Updated By (CYCLE_UPDATED_BY)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `valuation_reference_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Reference Date (VALUATION_REFERENCE_DATE)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Cycle Version (CYCLE_VERSION)');
ALTER TABLE `asset_management`.`valuation`.`cycle` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Cycle Created By (CYCLE_CREATED_BY)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` SET TAGS ('dbx_subdomain' = 'valuation_methodology');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `dcf_model_id` SET TAGS ('dbx_business_glossary_term' = 'DCF Model ID (DCF_MODEL_ID)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `climate_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `fdd_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Fdd Assessment Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `macro_model_id` SET TAGS ('dbx_business_glossary_term' = 'Macro Model Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_created_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Model Created By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_created_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_created_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Portfolio ID (DCF_MODEL_PORTFOLIO_ID)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Stress Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Asset ID (DCF_MODEL_ASSET_ID)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_asset_code` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Asset ID (DCF_MODEL_ASSET_ID)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_author` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Author (DCF_MODEL_AUTHOR)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_code` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Code (DCF_MODEL_CODE)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,20}$');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_confidence_level` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Confidence Level (DCF_MODEL_CONFIDENCE_LEVEL)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_confidence_level` SET TAGS ('dbx_value_regex' = 'High|Medium|Low');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_created_by_user` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Created By User (DCF_MODEL_CREATED_BY_USER)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_creation_date` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Creation Date (DCF_MODEL_CREATION_DATE)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_currency` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Currency (DCF_MODEL_CURRENCY)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_description` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Description (DCF_MODEL_DESCRIPTION)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_discount_rate` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Discount Rate (DCF_MODEL_DISCOUNT_RATE)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_effective_from` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Effective From (DCF_MODEL_EFFECTIVE_FROM)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_effective_until` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Effective Until (DCF_MODEL_EFFECTIVE_UNTIL)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_external_reference` SET TAGS ('dbx_business_glossary_term' = 'DCF Model External Reference (DCF_MODEL_EXTERNAL_REFERENCE)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_file_path` SET TAGS ('dbx_business_glossary_term' = 'DCF Model File Path (DCF_MODEL_FILE_PATH)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_hash` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Hash (DCF_MODEL_HASH)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_is_active` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Is Active (DCF_MODEL_IS_ACTIVE)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_is_approved` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Is Approved (DCF_MODEL_IS_APPROVED)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_is_archived` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Is Archived (DCF_MODEL_IS_ARCHIVED)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_is_draft` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Is Draft (DCF_MODEL_IS_DRAFT)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_is_validated` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Is Validated (DCF_MODEL_IS_VALIDATED)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_last_updated` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Last Updated Date (DCF_MODEL_LAST_UPDATED)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_name` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Name (DCF_MODEL_NAME)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_notes` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Notes (DCF_MODEL_NOTES)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_projected_free_cash_flow` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Projected Free Cash Flow (DCF_MODEL_PROJECTED_FCFF)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_projection_horizon_years` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Projection Horizon Years (DCF_MODEL_PROJECTION_HORIZON_YEARS)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_risk_category` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Risk Category (DCF_MODEL_RISK_CATEGORY)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_risk_category` SET TAGS ('dbx_value_regex' = 'Credit|Liquidity|Market|Operational|Legal');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Risk Rating (DCF_MODEL_RISK_RATING)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_risk_rating` SET TAGS ('dbx_value_regex' = 'A|B|C|D|E');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_source_system` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Source System (DCF_MODEL_SOURCE_SYSTEM)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_status` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Status (DCF_MODEL_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_status` SET TAGS ('dbx_value_regex' = 'Draft|Active|Archived|Deprecated');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_terminal_growth_rate` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Terminal Growth Rate (DCF_MODEL_TERMINAL_GROWTH_RATE)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_termination_date` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Termination Date (DCF_MODEL_TERMINATION_DATE)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_termination_reason` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Termination Reason (DCF_MODEL_TERMINATION_REASON)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_type` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Type (DCF_MODEL_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_updated_by_user` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Updated By User (DCF_MODEL_UPDATED_BY_USER)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_valuation_amount` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Valuation Amount (DCF_MODEL_VALUATION_AMOUNT)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_valuation_date` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Valuation Date (DCF_MODEL_VALUATION_DATE)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_valuation_method` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Valuation Method (DCF_MODEL_VALUATION_METHOD)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_valuation_method` SET TAGS ('dbx_value_regex' = 'DCF|NAV|MarketPrice|FairValue');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_valuation_notes` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Valuation Notes (DCF_MODEL_VALUATION_NOTES)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_valuation_source` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Valuation Source (DCF_MODEL_VALUATION_SOURCE)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_valuation_source` SET TAGS ('dbx_value_regex' = 'Internal|External|ThirdParty');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'DCF Model Version (DCF_MODEL_VERSION)');
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ALTER COLUMN `model_wacc` SET TAGS ('dbx_business_glossary_term' = 'DCF Model WACC (DCF_MODEL_WACC)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` SET TAGS ('dbx_subdomain' = 'valuation_methodology');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `wacc_calculation_id` SET TAGS ('dbx_business_glossary_term' = 'WACC Calculation ID (WACC_CALC_ID)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `fee_calculation_run_id` SET TAGS ('dbx_business_glossary_term' = 'Calculation Run ID (CALC_RUN_ID)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `capital_market_assumption_id` SET TAGS ('dbx_business_glossary_term' = 'Capital Market Assumption Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `climate_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `dcf_model_id` SET TAGS ('dbx_business_glossary_term' = 'Dcf Model Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID (PORTFOLIO_ID)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle ID (VAL_CYCLE_ID)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `asset_code` SET TAGS ('dbx_business_glossary_term' = 'Asset ID (ASSET_ID)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `calculation_currency` SET TAGS ('dbx_business_glossary_term' = 'Calculation Currency (CALC_CURRENCY)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `calculation_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `calculation_end_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation End Timestamp (CALC_END_TS)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Calculation Method (CALC_METHOD)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `calculation_method` SET TAGS ('dbx_value_regex' = 'DCF|CAPM|WACC_MODEL');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `calculation_model_version` SET TAGS ('dbx_business_glossary_term' = 'Calculation Model Version (CALC_MODEL_VER)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `calculation_notes` SET TAGS ('dbx_business_glossary_term' = 'Calculation Notes (CALC_NOTES)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `calculation_source` SET TAGS ('dbx_business_glossary_term' = 'Calculation Source (CALC_SOURCE)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `calculation_source` SET TAGS ('dbx_value_regex' = 'SimCorp|Aladdin|Custom');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `calculation_start_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation Start Timestamp (CALC_START_TS)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `calculation_status` SET TAGS ('dbx_business_glossary_term' = 'Calculation Status (CALC_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `calculation_status` SET TAGS ('dbx_value_regex' = 'pending|running|completed|failed');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation Timestamp (CALC_TS)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `cost_of_debt_rate` SET TAGS ('dbx_business_glossary_term' = 'Cost of Debt Rate (COD_RATE)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `cost_of_equity_rate` SET TAGS ('dbx_business_glossary_term' = 'Cost of Equity Rate (COE_RATE)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Record Created At (REC_CREATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `debt_weight` SET TAGS ('dbx_business_glossary_term' = 'Debt Weight (DEBT_WGT)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `equity_weight` SET TAGS ('dbx_business_glossary_term' = 'Equity Weight (EQUITY_WGT)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Created (REC_AUDIT_CREATED)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Updated (REC_AUDIT_UPDATED)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Tax Rate (TAX_RATE)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Record Updated At (REC_UPDATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `valuation_cycle_frequency` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Frequency (VAL_CYCLE_FREQ)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `valuation_cycle_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annual');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `valuation_source_code` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source ID (VAL_SRC_ID)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `valuation_source_description` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source Description (VAL_SRC_DESC)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `valuation_source_name` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source Name (VAL_SRC_NAME)');
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ALTER COLUMN `wacc_rate` SET TAGS ('dbx_business_glossary_term' = 'WACC Rate (WACC_RATE)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` SET TAGS ('dbx_subdomain' = 'governance_oversight');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `fair_value_hierarchy_id` SET TAGS ('dbx_business_glossary_term' = 'Fair Value Hierarchy ID (FVHI)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `hierarchy_parent_fair_value_hierarchy_id` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Parent ID (HIER_PARENT_ID)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Created At (CREATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `fair_value_hierarchy_description` SET TAGS ('dbx_business_glossary_term' = 'Description (DESC)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From (EFF_FROM)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until (EFF_UNTIL)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `fair_value_hierarchy_status` SET TAGS ('dbx_business_glossary_term' = 'Status (STAT)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `fair_value_hierarchy_status` SET TAGS ('dbx_value_regex' = 'active|inactive|deprecated');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `hierarchy_code` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Code (HC)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `hierarchy_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,10}$');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `hierarchy_level` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Level (HL)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `hierarchy_name` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Name (HN)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `hierarchy_order` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Order (HIER_ORDER)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `hierarchy_path` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Path (HIER_PATH)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `hierarchy_type` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Type (HT)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `hierarchy_type` SET TAGS ('dbx_value_regex' = 'Level 1|Level 2|Level 3');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `is_default` SET TAGS ('dbx_business_glossary_term' = 'Is Default (IS_DEFAULT)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes (NOTES)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System ID (SRC_SYS_ID)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `source_system_version` SET TAGS ('dbx_business_glossary_term' = 'Source System Version (SRC_SYS_VER)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Updated At (UPDATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`fair_value_hierarchy` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Version (VER)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` SET TAGS ('dbx_subdomain' = 'governance_oversight');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `indep_valuation_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Indep Valuation Engagement ID (IVE_ID)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Agent ID (ENG_AGENT_ID)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Mandate Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_address` SET TAGS ('dbx_business_glossary_term' = 'Engagement Agent Address (ENG_AGENT_ADDR)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_contact` SET TAGS ('dbx_business_glossary_term' = 'Engagement Agent Contact (ENG_AGENT_CONTACT)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_email` SET TAGS ('dbx_business_glossary_term' = 'Engagement Agent Email (ENG_AGENT_EMAIL)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_legal_entity_address` SET TAGS ('dbx_business_glossary_term' = 'Engagement Agent Legal Entity Address (ENG_AGENT_LEGAL_ADDR)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_legal_entity_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_legal_entity_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_legal_entity_code` SET TAGS ('dbx_business_glossary_term' = 'Engagement Agent Legal Entity ID (ENG_AGENT_LEGAL_ID)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_legal_entity_country` SET TAGS ('dbx_business_glossary_term' = 'Engagement Agent Legal Entity Country (ENG_AGENT_LEGAL_COUNTRY)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_legal_entity_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_legal_entity_email` SET TAGS ('dbx_business_glossary_term' = 'Engagement Agent Legal Entity Email (ENG_AGENT_LEGAL_EMAIL)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_legal_entity_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_legal_entity_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_legal_entity_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_legal_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Engagement Agent Legal Entity Name (ENG_AGENT_LEGAL_NAME)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_legal_entity_phone` SET TAGS ('dbx_business_glossary_term' = 'Engagement Agent Legal Entity Phone (ENG_AGENT_LEGAL_PHONE)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_legal_entity_phone` SET TAGS ('dbx_value_regex' = '^[+][0-9]{1,3}[0-9]{7,15}$');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_legal_entity_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_legal_entity_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_legal_entity_type` SET TAGS ('dbx_business_glossary_term' = 'Engagement Agent Legal Entity Type (ENG_AGENT_LEGAL_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_legal_entity_type` SET TAGS ('dbx_value_regex' = 'corporation|partnership|sole_proprietorship');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_phone` SET TAGS ('dbx_business_glossary_term' = 'Engagement Agent Phone (ENG_AGENT_PHONE)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_phone` SET TAGS ('dbx_value_regex' = '^[+][0-9]{1,3}[0-9]{7,15}$');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_tax_number` SET TAGS ('dbx_business_glossary_term' = 'Engagement Agent Legal Entity Tax ID (ENG_AGENT_LEGAL_TAX_ID)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_tax_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{5,20}$');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_tax_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_tax_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_type` SET TAGS ('dbx_business_glossary_term' = 'Engagement Agent Type (ENG_AGENT_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_agent_type` SET TAGS ('dbx_value_regex' = 'independent|firm|consulting');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_description` SET TAGS ('dbx_business_glossary_term' = 'Engagement Description (ENG_DESC)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_end_date` SET TAGS ('dbx_business_glossary_term' = 'Engagement End Date (ENG_END_DATE)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_fee` SET TAGS ('dbx_business_glossary_term' = 'Engagement Fee (ENG_FEE)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_fee_currency` SET TAGS ('dbx_business_glossary_term' = 'Engagement Fee Currency (ENG_FEE_CURR)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_fee_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_fee_due_amount` SET TAGS ('dbx_business_glossary_term' = 'Engagement Fee Due Amount (ENG_FEE_DUE_AMT)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_fee_due_currency` SET TAGS ('dbx_business_glossary_term' = 'Engagement Fee Due Currency (ENG_FEE_DUE_CURR)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_fee_due_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_fee_due_date` SET TAGS ('dbx_business_glossary_term' = 'Engagement Fee Due Date (ENG_FEE_DUE_DATE)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_fee_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Engagement Fee Paid Amount (ENG_FEE_PAID_AMT)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_fee_paid_currency` SET TAGS ('dbx_business_glossary_term' = 'Engagement Fee Paid Currency (ENG_FEE_PAID_CURR)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_fee_paid_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_fee_paid_date` SET TAGS ('dbx_business_glossary_term' = 'Engagement Fee Paid Date (ENG_FEE_PAID_DATE)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Engagement Fee Rate (ENG_FEE_RATE)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_fee_rate_unit` SET TAGS ('dbx_business_glossary_term' = 'Engagement Fee Rate Unit (ENG_FEE_RATE_UNIT)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_fee_rate_unit` SET TAGS ('dbx_value_regex' = 'per_hour|per_day|per_month');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_fee_schedule` SET TAGS ('dbx_business_glossary_term' = 'Engagement Fee Schedule (ENG_FEE_SCHED)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_fee_type` SET TAGS ('dbx_business_glossary_term' = 'Engagement Fee Type (ENG_FEE_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_fee_type` SET TAGS ('dbx_value_regex' = 'fixed|hourly|retainer');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_name` SET TAGS ('dbx_business_glossary_term' = 'Engagement Name (ENG_NAME)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_number` SET TAGS ('dbx_business_glossary_term' = 'Engagement Number (ENG_NUM)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_number` SET TAGS ('dbx_value_regex' = 'ENG-d{4}-d{4}');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_scope` SET TAGS ('dbx_business_glossary_term' = 'Engagement Scope (ENG_SCOPE)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_scope_amount` SET TAGS ('dbx_business_glossary_term' = 'Engagement Scope Amount (ENG_SCOPE_AMT)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_scope_currency` SET TAGS ('dbx_business_glossary_term' = 'Engagement Scope Currency (ENG_SCOPE_CURR)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_scope_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_scope_description` SET TAGS ('dbx_business_glossary_term' = 'Engagement Scope Description (ENG_SCOPE_DESC)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_scope_type` SET TAGS ('dbx_business_glossary_term' = 'Engagement Scope Type (ENG_SCOPE_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_scope_type` SET TAGS ('dbx_value_regex' = 'asset|portfolio|fund');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_start_date` SET TAGS ('dbx_business_glossary_term' = 'Engagement Start Date (ENG_START_DATE)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_status` SET TAGS ('dbx_business_glossary_term' = 'Engagement Status (ENG_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_status` SET TAGS ('dbx_value_regex' = 'active|suspended|terminated|pending');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_status_reason` SET TAGS ('dbx_business_glossary_term' = 'Engagement Status Reason (ENG_STATUS_REASON)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_type` SET TAGS ('dbx_business_glossary_term' = 'Engagement Type (ENG_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `engagement_type` SET TAGS ('dbx_value_regex' = 'valuation|appraisal|audit');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Created (REC_AUDIT_CREATED)');
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Updated (REC_AUDIT_UPDATED)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`valuation`.`adjustment` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`adjustment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`adjustment` SET TAGS ('dbx_subdomain' = 'valuation_methodology');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `adjustment_id` SET TAGS ('dbx_business_glossary_term' = 'Adjustment ID (ADJ_ID)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `audit_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Cycle ID (ADJ_CYCLE_ID)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `valuation_document_id` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Document ID (ADJ_DOC_ID)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `rule_breach_id` SET TAGS ('dbx_business_glossary_term' = 'Rule Breach Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation ID (VAL_ID)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `adjustment_date` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Date (ADJ_DATE)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `adjustment_status` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Status (ADJ_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `adjustment_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|applied|cancelled');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `adjustment_type` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Type (ADJ_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `adjustment_type` SET TAGS ('dbx_value_regex' = 'liquidity_discount|control_premium|minority_discount|credit_risk_adjustment|fx_translation_adjustment|model_overlay');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Amount (ADJ_AMT)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `approved_at` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Approved Timestamp (ADJ_APPROVED_AT)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Approved By (ADJ_APPROVED_BY)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `approved_by_name` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Approved By Name (ADJ_APPROVED_BY_NAME)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Created Timestamp (ADJ_CREATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Currency (ADJ_CURR)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `cycle_frequency` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Cycle Frequency (ADJ_CYCLE_FREQ)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Effective From (ADJ_EFF_FROM)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Effective Until (ADJ_EFF_UNTIL)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Is Active (ADJ_IS_ACTIVE)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `is_approved` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Is Approved (ADJ_IS_APPROVED)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `is_draft` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Is Draft (ADJ_IS_DRAFT)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `is_finalized` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Is Finalized (ADJ_IS_FINALIZED)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `is_locked` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Is Locked (ADJ_IS_LOCKED)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `reason` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Reason (ADJ_REASON)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `reference` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Reference (ADJ_REF)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Source System ID (ADJ_SRC_SYS_ID)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `source_system_description` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Source System Description (ADJ_SRC_SYS_DESC)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `source_system_name` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Source System Name (ADJ_SRC_SYS_NAME)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `source_system_version` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Source System Version (ADJ_SRC_SYS_VER)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Updated Timestamp (ADJ_UPDATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`adjustment` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Version (ADJ_VER)');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` SET TAGS ('dbx_subdomain' = 'market_pricing');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `market_price_snapshot_id` SET TAGS ('dbx_business_glossary_term' = 'Market Price Snapshot ID');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `ask_price` SET TAGS ('dbx_business_glossary_term' = 'Ask Price');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `asset_category` SET TAGS ('dbx_business_glossary_term' = 'Asset Category');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `asset_currency` SET TAGS ('dbx_business_glossary_term' = 'Asset Currency (ISO 4217)');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `asset_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `asset_sector` SET TAGS ('dbx_business_glossary_term' = 'Asset Sector');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `asset_subclass` SET TAGS ('dbx_business_glossary_term' = 'Asset Subclass');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `bid_price` SET TAGS ('dbx_business_glossary_term' = 'Bid Price');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `closing_price` SET TAGS ('dbx_business_glossary_term' = 'Closing Price');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'CUSIP (Committee on Uniform Securities Identification Procedures)');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{9}$');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `exchange_code` SET TAGS ('dbx_business_glossary_term' = 'Exchange Code');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `exchange_name` SET TAGS ('dbx_business_glossary_term' = 'Exchange Name');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `high_price` SET TAGS ('dbx_business_glossary_term' = 'High Price');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `instrument_type` SET TAGS ('dbx_business_glossary_term' = 'Instrument Type');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'ISIN (International Securities Identification Number)');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{12}$');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `last_traded_price` SET TAGS ('dbx_business_glossary_term' = 'Last Traded Price');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'LEI (Legal Entity Identifier)');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `low_price` SET TAGS ('dbx_business_glossary_term' = 'Low Price');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `market` SET TAGS ('dbx_business_glossary_term' = 'Market');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `mid_price` SET TAGS ('dbx_business_glossary_term' = 'Mid Price');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `open_price` SET TAGS ('dbx_business_glossary_term' = 'Opening Price');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system` SET TAGS ('dbx_business_glossary_term' = 'Price Source System');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_address` SET TAGS ('dbx_business_glossary_term' = 'Contact Address');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Price Source System ID');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_contact` SET TAGS ('dbx_business_glossary_term' = 'Contact Name');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_country` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_description` SET TAGS ('dbx_business_glossary_term' = 'Price Source System Description');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_effective_from` SET TAGS ('dbx_business_glossary_term' = 'Price Source System Effective From');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_effective_until` SET TAGS ('dbx_business_glossary_term' = 'Price Source System Effective Until');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_email` SET TAGS ('dbx_business_glossary_term' = 'Contact Email');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_license` SET TAGS ('dbx_business_glossary_term' = 'License Type');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_license` SET TAGS ('dbx_value_regex' = 'commercial|subscription|free');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_license_expiry` SET TAGS ('dbx_business_glossary_term' = 'License Expiry Date');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_phone` SET TAGS ('dbx_business_glossary_term' = 'Contact Phone');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_phone` SET TAGS ('dbx_value_regex' = '^[+]?d{1,15}$');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_rating` SET TAGS ('dbx_business_glossary_term' = 'Rating');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_rating` SET TAGS ('dbx_value_regex' = 'A|B|C|D|E|F');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_reference` SET TAGS ('dbx_business_glossary_term' = 'Price Source System Reference');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_status` SET TAGS ('dbx_business_glossary_term' = 'Price Source System Status');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_status` SET TAGS ('dbx_value_regex' = 'active|inactive|deprecated');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_type` SET TAGS ('dbx_business_glossary_term' = 'Price Source System Type');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_type` SET TAGS ('dbx_value_regex' = 'DataFeed|API|WebService|Manual');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_version` SET TAGS ('dbx_business_glossary_term' = 'Price Source System Version');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_system_website` SET TAGS ('dbx_business_glossary_term' = 'Website URL');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_source_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Price Source Timestamp');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `price_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Price Snapshot Timestamp');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'SEDOL (Stock Exchange Daily Official List)');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{7}$');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `trade_count` SET TAGS ('dbx_business_glossary_term' = 'Trade Count');
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ALTER COLUMN `volume` SET TAGS ('dbx_business_glossary_term' = 'Trade Volume');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` SET TAGS ('dbx_subdomain' = 'market_pricing');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `comparable_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Comparable Transaction ID (CT_ID)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Agent Identifier (VAL_AGENT_ID)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `actor_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `actor_id` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `adjustment_id` SET TAGS ('dbx_business_glossary_term' = 'Transaction Document ID (DOC_ID)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `methodology_id` SET TAGS ('dbx_business_glossary_term' = 'Methodology Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_valuation_agent_legal_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Agent Legal Entity Identifier (VAL_AGENT_LE_ID)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Identifier (VAL_CYCLE_ID)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `ebitda` SET TAGS ('dbx_business_glossary_term' = 'EBITDA (EBITDA)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `enterprise_value` SET TAGS ('dbx_business_glossary_term' = 'Enterprise Value (EV)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Created Timestamp (AUDIT_CREATED)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Updated Timestamp (AUDIT_UPDATED)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_amount_gross` SET TAGS ('dbx_business_glossary_term' = 'Transaction Gross Amount (GROSS_AMT)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_amount_net` SET TAGS ('dbx_business_glossary_term' = 'Transaction Net Amount (NET_AMT)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_currency` SET TAGS ('dbx_business_glossary_term' = 'Transaction Currency (CURR)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Comparable Transaction Date (CT_DATE)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_discount` SET TAGS ('dbx_business_glossary_term' = 'Transaction Discount (DISCOUNT)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_document_code` SET TAGS ('dbx_business_glossary_term' = 'Transaction Document ID (DOC_ID)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_document_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Document Date (DOC_DATE)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_document_hash` SET TAGS ('dbx_business_glossary_term' = 'Transaction Document Hash (DOC_HASH)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_document_status` SET TAGS ('dbx_business_glossary_term' = 'Transaction Document Status (DOC_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_document_type` SET TAGS ('dbx_business_glossary_term' = 'Transaction Document Type (DOC_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_document_type` SET TAGS ('dbx_value_regex' = 'pdf|docx|xlsx|txt|image');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_document_url` SET TAGS ('dbx_business_glossary_term' = 'Transaction Document URL (DOC_URL)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_document_version` SET TAGS ('dbx_business_glossary_term' = 'Transaction Document Version (DOC_VER)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_fee` SET TAGS ('dbx_business_glossary_term' = 'Transaction Fee (FEE)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_identifier` SET TAGS ('dbx_business_glossary_term' = 'Comparable Transaction Identifier (CT_ID)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_market` SET TAGS ('dbx_business_glossary_term' = 'Transaction Market (MARKET)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_market_code` SET TAGS ('dbx_business_glossary_term' = 'Transaction Market Code (MARKET_CODE)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_market_type` SET TAGS ('dbx_business_glossary_term' = 'Transaction Market Type (MARKET_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_market_type` SET TAGS ('dbx_value_regex' = 'equity|private equity|real estate|infrastructure|credit');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_source_code` SET TAGS ('dbx_business_glossary_term' = 'Transaction Source ID (SRC_ID)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_source_system` SET TAGS ('dbx_business_glossary_term' = 'Transaction Source System (SRC_SYS)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_source_system` SET TAGS ('dbx_value_regex' = 'SimCorp Dimension|BlackRock Aladdin|Bloomberg Terminal|State Street|eFront|DealCloud');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_business_glossary_term' = 'Comparable Transaction Status (CT_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_value_regex' = 'draft|open|closed|cancelled');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_subtype` SET TAGS ('dbx_business_glossary_term' = 'Comparable Transaction Subtype (CT_SUBTYPE)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_tax` SET TAGS ('dbx_business_glossary_term' = 'Transaction Tax (TAX)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_time` SET TAGS ('dbx_business_glossary_term' = 'Comparable Transaction Time (CT_TIME)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Comparable Transaction Type (CT_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'M&A|secondary sale|IPO|recapitalization');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_valuation_agent_legal_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Valuation Agent Legal Entity Name (VAL_AGENT_LE_NAME)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_valuation_agent_legal_entity_type` SET TAGS ('dbx_business_glossary_term' = 'Valuation Agent Legal Entity Type (VAL_AGENT_LE_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_valuation_agent_type` SET TAGS ('dbx_business_glossary_term' = 'Valuation Agent Type (VAL_AGENT_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_valuation_comments` SET TAGS ('dbx_business_glossary_term' = 'Valuation Comments (VAL_COMMENTS)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_valuation_cycle_frequency` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Frequency (VAL_CYCLE_FREQ)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_valuation_cycle_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|annual|semi-annual');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_valuation_engine` SET TAGS ('dbx_business_glossary_term' = 'Transaction Valuation Engine (VAL_ENGINE)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_valuation_engine` SET TAGS ('dbx_value_regex' = 'internal|external|third-party');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_valuation_reason` SET TAGS ('dbx_business_glossary_term' = 'Valuation Reason (VAL_REASON)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_valuation_source_code` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source Identifier (VAL_SRC_ID)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_valuation_source_description` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source Description (VAL_SRC_DESC)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_valuation_source_name` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source Name (VAL_SRC_NAME)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_valuation_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Status (VAL_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ALTER COLUMN `transaction_valuation_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|in review');
ALTER TABLE `asset_management`.`valuation`.`methodology` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`valuation`.`methodology` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`methodology` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`methodology` SET TAGS ('dbx_subdomain' = 'valuation_methodology');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `methodology_id` SET TAGS ('dbx_business_glossary_term' = 'Methodology ID');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `adjustment_id` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document ID');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `applicable_asset_category` SET TAGS ('dbx_business_glossary_term' = 'Methodology Applicable Asset Category');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `applicable_asset_class` SET TAGS ('dbx_business_glossary_term' = 'Methodology Applicable Asset Class');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `applicable_asset_currency` SET TAGS ('dbx_business_glossary_term' = 'Methodology Applicable Asset Currency');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `applicable_asset_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `applicable_asset_sector` SET TAGS ('dbx_business_glossary_term' = 'Methodology Applicable Asset Sector');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `applicable_asset_subclass` SET TAGS ('dbx_business_glossary_term' = 'Methodology Applicable Asset Subclass');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `applicable_asset_type` SET TAGS ('dbx_business_glossary_term' = 'Methodology Applicable Asset Type');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `methodology_code` SET TAGS ('dbx_business_glossary_term' = 'Methodology Code');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Methodology Record Creation Timestamp');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `methodology_description` SET TAGS ('dbx_business_glossary_term' = 'Methodology Description');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_code` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document ID');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_created_at` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Creation Timestamp');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_created_by` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Created By');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_date` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Date');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_description` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Description');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_hash` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Hash');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_hash_algorithm` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Hash Algorithm');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_hash_algorithm` SET TAGS ('dbx_value_regex' = 'SHA-256|SHA-512|MD5');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_notes` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Notes');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_reference` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Reference');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_at` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Signer Timestamp');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Signer Name');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_address` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Signer Address');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_department` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Signer Department');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_email` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Signer Email');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_identifier` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Signer Identifier');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_identifier` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_identifier` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_identifier_type` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Signer Identifier Type');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_identifier_value` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Signer Identifier Value');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_identifier_value` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_identifier_value` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_phone` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Signer Phone');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_phone` SET TAGS ('dbx_value_regex' = '^[+]?d{10,15}$');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_role` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Signer Role');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_signed_by_title` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Signer Title');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_source_system` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Source System');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Status');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_status` SET TAGS ('dbx_value_regex' = 'draft|signed|archived');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_type` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Type');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_type` SET TAGS ('dbx_value_regex' = 'pdf|docx|excel');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_updated_at` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Update Timestamp');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_updated_by` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Updated By');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_url` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document URL');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `document_version` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Version');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Methodology Effective From Date');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Methodology Effective Until Date');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `methodology_status` SET TAGS ('dbx_business_glossary_term' = 'Methodology Status');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `methodology_status` SET TAGS ('dbx_value_regex' = 'active|inactive|deprecated|draft');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `methodology_type` SET TAGS ('dbx_business_glossary_term' = 'Methodology Type (Valuation Methodology)');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `methodology_name` SET TAGS ('dbx_business_glossary_term' = 'Methodology Name');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Methodology Notes');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Methodology Record Update Timestamp');
ALTER TABLE `asset_management`.`valuation`.`methodology` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Methodology Version');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` SET TAGS ('dbx_subdomain' = 'governance_oversight');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `valuation_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy ID (VALUATION_POLICY_ID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `approval_required` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag (POLICY_APPROVAL_REQUIRED)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `approval_required_reason` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Reason (POLICY_APPROVAL_REQUIRED_REASON)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Record Created At (CREATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Date (POLICY_DOCUMENT_DATE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_description` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Description (POLICY_DOCUMENT_DESCRIPTION)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_hash` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Hash (POLICY_DOCUMENT_HASH)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_reference` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Reference (POLICY_DOCUMENT_REFERENCE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_signed_at` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Signed At (POLICY_DOCUMENT_SIGNED_AT)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_signed_by` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Signed By (POLICY_DOCUMENT_SIGNED_BY)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_source_system` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Source System (POLICY_DOCUMENT_SOURCE_SYSTEM)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Source System ID (POLICY_DOCUMENT_SOURCE_SYSTEM_ID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_source_system_created_at` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Source System Created At (POLICY_DOCUMENT_SOURCE_SYSTEM_CREATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_source_system_description` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Source System Description (POLICY_DOCUMENT_SOURCE_SYSTEM_DESCRIPTION)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_source_system_name` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Source System Name (POLICY_DOCUMENT_SOURCE_SYSTEM_NAME)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_source_system_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Source System Status (POLICY_DOCUMENT_SOURCE_SYSTEM_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_source_system_status` SET TAGS ('dbx_value_regex' = 'Active|Inactive|Deprecated');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_source_system_type` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Source System Type (POLICY_DOCUMENT_SOURCE_SYSTEM_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_source_system_updated_at` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Source System Updated At (POLICY_DOCUMENT_SOURCE_SYSTEM_UPDATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_source_system_version` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Source System Version (POLICY_DOCUMENT_SOURCE_SYSTEM_VERSION)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Status (POLICY_DOCUMENT_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_status` SET TAGS ('dbx_value_regex' = 'Draft|Approved|Rejected|Archived');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_type` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Type (POLICY_DOCUMENT_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_type` SET TAGS ('dbx_value_regex' = 'PDF|Word|Excel|Other');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_url` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document URL (POLICY_DOCUMENT_URL)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `document_version` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Document Version (POLICY_DOCUMENT_VERSION)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Effective From Date (EFFECTIVE_FROM)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Effective Until Date (EFFECTIVE_UNTIL)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `hierarchy_rules` SET TAGS ('dbx_business_glossary_term' = 'Valuation Hierarchy Level Assignment Rules (POLICY_HIERARCHY_RULES)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `independent_valuation_reason` SET TAGS ('dbx_business_glossary_term' = 'Independent Valuation Reason (POLICY_INDEPENDENT_VALUATION_REASON)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `independent_valuation_required` SET TAGS ('dbx_business_glossary_term' = 'Independent Valuation Required Flag (POLICY_INDEPENDENT_VALUATION_REQUIRED)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `methodology` SET TAGS ('dbx_business_glossary_term' = 'Valuation Methodology (POLICY_METHODOLOGY)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `methodology` SET TAGS ('dbx_value_regex' = 'DCF|MarketPrice|Level1|Level2|Level3|Other');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `methodology_description` SET TAGS ('dbx_business_glossary_term' = 'Valuation Methodology Description (POLICY_METHODOLOGY_DESCRIPTION)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `policy_name` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Name (POLICY_NAME)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `policy_scope` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Scope (POLICY_SCOPE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `policy_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Status (POLICY_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `policy_status` SET TAGS ('dbx_value_regex' = 'active|draft|deprecated|archived|pending|cancelled');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `policy_type` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Type (POLICY_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `policy_type` SET TAGS ('dbx_value_regex' = 'valuation|nav|fair_value|market_price');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Record Audit Created (RECORD_AUDIT_CREATED)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Record Audit Updated (RECORD_AUDIT_UPDATED)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `scope_description` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Scope Description (POLICY_SCOPE_DESCRIPTION)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `scope_type` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Scope Type (POLICY_SCOPE_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `scope_type` SET TAGS ('dbx_value_regex' = 'AssetClass|Portfolio|Fund|Asset');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Record Updated At (UPDATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Version (POLICY_VERSION)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` SET TAGS ('dbx_subdomain' = 'governance_oversight');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `valuation_review_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Review ID (VRID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `analyst_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst Assignment Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Review Approver ID (RAID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `approver_id` SET TAGS ('dbx_business_glossary_term' = 'Review Approver ID (RAID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Review Cycle ID (RCID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewer ID (RID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `origination_source_id` SET TAGS ('dbx_business_glossary_term' = 'Review Source ID (RSID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation ID (VID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `valuation_document_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `valuation_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewer ID (RID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `valuation_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `valuation_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `approval_comments` SET TAGS ('dbx_business_glossary_term' = 'Review Approval Comments (RAC)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Review Approval Date (RAD)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Review Approval Status (RAS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `approver_name` SET TAGS ('dbx_business_glossary_term' = 'Review Approver Name (RAN)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `approver_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `approver_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Review Comments (RC)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp (RCT)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `cycle_frequency` SET TAGS ('dbx_business_glossary_term' = 'Review Cycle Frequency (RCF)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `impact` SET TAGS ('dbx_business_glossary_term' = 'Review Impact (RI)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `method_description` SET TAGS ('dbx_business_glossary_term' = 'Review Method Description (RMD)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `outcome` SET TAGS ('dbx_business_glossary_term' = 'Review Outcome (RO)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `reason` SET TAGS ('dbx_business_glossary_term' = 'Review Reason (RR)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'Review Date (RD)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `review_method` SET TAGS ('dbx_business_glossary_term' = 'Review Method (RM)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `review_status` SET TAGS ('dbx_business_glossary_term' = 'Review Status (RS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `review_type` SET TAGS ('dbx_business_glossary_term' = 'Review Type (RT)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `reviewer_name` SET TAGS ('dbx_business_glossary_term' = 'Reviewer Name (RN)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `reviewer_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `reviewer_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `source_description` SET TAGS ('dbx_business_glossary_term' = 'Review Source Description (RSD)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `source_name` SET TAGS ('dbx_business_glossary_term' = 'Review Source Name (RSN)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `status_date` SET TAGS ('dbx_business_glossary_term' = 'Review Status Date (RSD)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `status_notes` SET TAGS ('dbx_business_glossary_term' = 'Review Status Notes (RSN)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `status_reason` SET TAGS ('dbx_business_glossary_term' = 'Review Status Reason (RSR)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp (RUT)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `valuation_comments` SET TAGS ('dbx_business_glossary_term' = 'Valuation Comments (VC)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date (VD)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `valuation_document_code` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document ID (VDI)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `valuation_document_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Date (VDD)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `valuation_document_type` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Type (VDT)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `valuation_document_url` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document URL (VDU)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method (VM)');
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ALTER COLUMN `valuation_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Status (VS)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` SET TAGS ('dbx_subdomain' = 'fair_value');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `private_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Private Asset Valuation ID (PAV_ID)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Agent ID (VALUATION_AGENT_ID)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `adjustment_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document ID (VALUATION_DOCUMENT_ID)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Dd Engagement Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `issuer_esg_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer Esg Rating Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'DCF Model ID (DCF_MODEL_ID)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID (PORTFOLIO_ID)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Asset ID (ASSET_ID)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle ID (VALUATION_CYCLE_ID)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class (ASSET_CLASS)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `asset_code` SET TAGS ('dbx_business_glossary_term' = 'Asset ID (ASSET_ID)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `asset_currency` SET TAGS ('dbx_business_glossary_term' = 'Asset Currency (ASSET_CURRENCY)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `asset_isin` SET TAGS ('dbx_business_glossary_term' = 'Asset ISIN (ISIN)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `asset_isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[0-9A-Z]{9}[0-9]$');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `asset_name` SET TAGS ('dbx_business_glossary_term' = 'Asset Name (ASSET_NAME)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `asset_type` SET TAGS ('dbx_business_glossary_term' = 'Asset Type (ASSET_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `book_value` SET TAGS ('dbx_business_glossary_term' = 'Book Value (BOOK_VALUE)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `cost_of_debt_rate` SET TAGS ('dbx_business_glossary_term' = 'Cost of Debt Rate (COST_OF_DEBT_RATE)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `cost_of_equity_rate` SET TAGS ('dbx_business_glossary_term' = 'Cost of Equity Rate (COST_OF_EQUITY_RATE)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `debt_weight` SET TAGS ('dbx_business_glossary_term' = 'Debt Weight (DEBT_WEIGHT)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `equity_weight` SET TAGS ('dbx_business_glossary_term' = 'Equity Weight (EQUITY_WEIGHT)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `fair_value` SET TAGS ('dbx_business_glossary_term' = 'Fair Value (FAIR_VALUE)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `gav` SET TAGS ('dbx_business_glossary_term' = 'Gross Asset Value (GAV)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `market_value` SET TAGS ('dbx_business_glossary_term' = 'Market Value (MARKET_VALUE)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `nav` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Tax Rate (TAX_RATE)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_comments` SET TAGS ('dbx_business_glossary_term' = 'Valuation Comments (VALUATION_COMMENTS)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_cycle_frequency` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Frequency (VALUATION_CYCLE_FREQUENCY)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_cycle_frequency` SET TAGS ('dbx_value_regex' = 'Monthly|Quarterly|Annual');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date (VALUATION_DATE)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_document_code` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document ID (VALUATION_DOCUMENT_ID)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_document_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Date (VALUATION_DOCUMENT_DATE)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_document_hash` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Hash (VALUATION_DOCUMENT_HASH)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_document_hash` SET TAGS ('dbx_value_regex' = '^[a-fA-F0-9]{64}$');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_document_signed_at` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Signed At (VALUATION_DOCUMENT_SIGNED_AT)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_document_signed_by` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Signed By (VALUATION_DOCUMENT_SIGNED_BY)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_document_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Status (VALUATION_DOCUMENT_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_document_status` SET TAGS ('dbx_value_regex' = 'draft|final|archived');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_document_type` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Type (VALUATION_DOCUMENT_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_document_type` SET TAGS ('dbx_value_regex' = 'pdf|docx|xlsx|txt');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_document_url` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document URL (VALUATION_DOCUMENT_URL)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_document_url` SET TAGS ('dbx_value_regex' = '^(https?|ftp)://[^s/$.?#].[S]*$');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_document_version` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Version (VALUATION_DOCUMENT_VERSION)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_engine` SET TAGS ('dbx_business_glossary_term' = 'Valuation Engine (VALUATION_ENGINE)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_engine` SET TAGS ('dbx_value_regex' = 'SimCorp|Aladdin|Custom');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method (VALUATION_METHOD)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'DCF|Market|Comparable|Other');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_reason` SET TAGS ('dbx_business_glossary_term' = 'Valuation Reason (VALUATION_REASON)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_source_code` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source ID (VALUATION_SOURCE_ID)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_source_description` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source Description (VALUATION_SOURCE_DESCRIPTION)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_source_name` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source Name (VALUATION_SOURCE_NAME)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Status (VALUATION_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_status` SET TAGS ('dbx_value_regex' = 'Pending|Approved|Rejected|Completed');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `valuation_time` SET TAGS ('dbx_business_glossary_term' = 'Valuation Time (VALUATION_TIME)');
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ALTER COLUMN `wacc_rate` SET TAGS ('dbx_business_glossary_term' = 'WACC Rate (WACC_RATE)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` SET TAGS ('dbx_subdomain' = 'market_pricing');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `broker_quote_id` SET TAGS ('dbx_business_glossary_term' = 'Broker Quote ID (broker_quote_id)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `broker_id` SET TAGS ('dbx_business_glossary_term' = 'Broker ID (broker_id)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `data_vendor_id` SET TAGS ('dbx_business_glossary_term' = 'Data Vendor Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `quote_source_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Source ID (quote_source_id)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `ask_price` SET TAGS ('dbx_business_glossary_term' = 'Ask Price (ask_price)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `ask_size` SET TAGS ('dbx_business_glossary_term' = 'Ask Size (ask_size)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `bid_ask_spread` SET TAGS ('dbx_business_glossary_term' = 'Bid-Ask Spread (bid_ask_spread)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `bid_price` SET TAGS ('dbx_business_glossary_term' = 'Bid Price (bid_price)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `bid_size` SET TAGS ('dbx_business_glossary_term' = 'Bid Size (bid_size)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `broker_dealer_lei` SET TAGS ('dbx_business_glossary_term' = 'Broker Dealer LEI (broker_dealer_lei)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `broker_dealer_lei` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{20}$');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `broker_dealer_name` SET TAGS ('dbx_business_glossary_term' = 'Broker Dealer Name (broker_dealer_name)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `mid_price` SET TAGS ('dbx_business_glossary_term' = 'Mid Price (mid_price)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `quote_source_country` SET TAGS ('dbx_business_glossary_term' = 'Quote Source Country (quote_source_country)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `quote_source_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `quote_source_exchange` SET TAGS ('dbx_business_glossary_term' = 'Quote Source Exchange (quote_source_exchange)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `quote_source_exchange` SET TAGS ('dbx_value_regex' = '^[A-Z]{3,5}$');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `quote_source_market` SET TAGS ('dbx_business_glossary_term' = 'Quote Source Market (quote_source_market)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `quote_source_market` SET TAGS ('dbx_value_regex' = '^[A-Z]{3,10}$');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `quote_source_name` SET TAGS ('dbx_business_glossary_term' = 'Quote Source Name (quote_source_name)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `quote_source_region` SET TAGS ('dbx_business_glossary_term' = 'Quote Source Region (quote_source_region)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `quote_source_system` SET TAGS ('dbx_business_glossary_term' = 'Quote Source System (quote_source_system)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `quote_source_type` SET TAGS ('dbx_business_glossary_term' = 'Quote Source Type (quote_source_type)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `quote_status` SET TAGS ('dbx_business_glossary_term' = 'Quote Status (quote_status)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `quote_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Quote Timestamp (quote_timestamp)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `quote_type` SET TAGS ('dbx_business_glossary_term' = 'Quote Type (quote_type)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `quote_valid_from` SET TAGS ('dbx_business_glossary_term' = 'Quote Valid From (quote_valid_from)');
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ALTER COLUMN `quote_valid_to` SET TAGS ('dbx_business_glossary_term' = 'Quote Valid To (quote_valid_to)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` SET TAGS ('dbx_subdomain' = 'market_pricing');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `valuation_yield_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Yield Curve ID (VALUATION_YIELD_CURVE_ID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Created At (CREATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Currency (CURRENCY)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `curve_code` SET TAGS ('dbx_business_glossary_term' = 'Curve Code (CURVE_CODE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `curve_description` SET TAGS ('dbx_business_glossary_term' = 'Curve Description (CURVE_DESCRIPTION)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `curve_name` SET TAGS ('dbx_business_glossary_term' = 'Curve Name (CURVE_NAME)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `curve_notes` SET TAGS ('dbx_business_glossary_term' = 'Curve Notes (CURVE_NOTES)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `curve_source_code` SET TAGS ('dbx_business_glossary_term' = 'Curve Source ID (CURVE_SOURCE_ID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `curve_source_description` SET TAGS ('dbx_business_glossary_term' = 'Curve Source Description (CURVE_SOURCE_DESCRIPTION)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `curve_source_name` SET TAGS ('dbx_business_glossary_term' = 'Curve Source Name (CURVE_SOURCE_NAME)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `curve_source_type` SET TAGS ('dbx_business_glossary_term' = 'Curve Source Type (CURVE_SOURCE_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `curve_source_url` SET TAGS ('dbx_business_glossary_term' = 'Curve Source URL (CURVE_SOURCE_URL)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `curve_type` SET TAGS ('dbx_business_glossary_term' = 'Curve Type (CURVE_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `curve_type` SET TAGS ('dbx_value_regex' = 'government|swap|credit_spread|oas');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From (EFFECTIVE_FROM)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until (EFFECTIVE_UNTIL)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active (IS_ACTIVE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `is_default` SET TAGS ('dbx_business_glossary_term' = 'Is Default (IS_DEFAULT)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `is_public` SET TAGS ('dbx_business_glossary_term' = 'Is Public (IS_PUBLIC)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes (NOTES)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Created (RECORD_AUDIT_CREATED)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Updated (RECORD_AUDIT_UPDATED)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `reference_date` SET TAGS ('dbx_business_glossary_term' = 'Reference Date (REFERENCE_DATE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `remarks` SET TAGS ('dbx_business_glossary_term' = 'Remarks (REMARKS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System ID (SOURCE_SYSTEM_ID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `source_system_name` SET TAGS ('dbx_business_glossary_term' = 'Source System Name (SOURCE_SYSTEM_NAME)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `source_system_type` SET TAGS ('dbx_business_glossary_term' = 'Source System Type (SOURCE_SYSTEM_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `source_system_url` SET TAGS ('dbx_business_glossary_term' = 'Source System URL (SOURCE_SYSTEM_URL)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `source_system_version` SET TAGS ('dbx_business_glossary_term' = 'Source System Version (SOURCE_SYSTEM_VERSION)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `tags` SET TAGS ('dbx_business_glossary_term' = 'Tags (TAGS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Updated At (UPDATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `valuation_yield_curve_status` SET TAGS ('dbx_business_glossary_term' = 'Status (STATUS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `valuation_yield_curve_status` SET TAGS ('dbx_value_regex' = 'active|inactive|archived');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `value_10y` SET TAGS ('dbx_business_glossary_term' = '10-Year Yield (10Y_YIELD)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `value_1y` SET TAGS ('dbx_business_glossary_term' = '1-Year Yield (1Y_YIELD)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `value_2y` SET TAGS ('dbx_business_glossary_term' = '2-Year Yield (2Y_YIELD)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `value_30y` SET TAGS ('dbx_business_glossary_term' = '30-Year Yield (30Y_YIELD)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `value_3m` SET TAGS ('dbx_business_glossary_term' = '3-Month Yield (3M_YIELD)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `value_5y` SET TAGS ('dbx_business_glossary_term' = '5-Year Yield (5Y_YIELD)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `value_6m` SET TAGS ('dbx_business_glossary_term' = '6-Month Yield (6M_YIELD)');
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Version (VERSION)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` SET TAGS ('dbx_subdomain' = 'market_pricing');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `valuation_fx_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation FX Rate ID (VAL_FX_RATE_ID)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `base_currency` SET TAGS ('dbx_business_glossary_term' = 'Base Currency (BASE_CURR)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `base_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Created At (CREATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `currency_pair` SET TAGS ('dbx_business_glossary_term' = 'Currency Pair (CURRENCY_PAIR)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From (EFFECTIVE_FROM)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until (EFFECTIVE_UNTIL)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `forward_rate_12m` SET TAGS ('dbx_business_glossary_term' = '12-Month Forward Rate (FORWARD_12M)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `forward_rate_1m` SET TAGS ('dbx_business_glossary_term' = '1-Month Forward Rate (FORWARD_1M)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `forward_rate_3m` SET TAGS ('dbx_business_glossary_term' = '3-Month Forward Rate (FORWARD_3M)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `forward_rate_6m` SET TAGS ('dbx_business_glossary_term' = '6-Month Forward Rate (FORWARD_6M)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `quote_currency` SET TAGS ('dbx_business_glossary_term' = 'Quote Currency (QUOTE_CURR)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `quote_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `rate_date` SET TAGS ('dbx_business_glossary_term' = 'Rate Date (RATE_DATE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `rate_source` SET TAGS ('dbx_business_glossary_term' = 'Rate Source (RATE_SOURCE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `rate_source` SET TAGS ('dbx_value_regex' = 'Bloomberg|Reuters|Fixing|Other');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `rate_source_description` SET TAGS ('dbx_business_glossary_term' = 'Rate Source Description (RATE_SOURCE_DESC)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `rate_status` SET TAGS ('dbx_business_glossary_term' = 'Rate Status (RATE_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `rate_status` SET TAGS ('dbx_value_regex' = 'active|inactive|archived');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `rate_type` SET TAGS ('dbx_business_glossary_term' = 'Rate Type (RATE_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `rate_type` SET TAGS ('dbx_value_regex' = 'spot|forward');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `rate_version` SET TAGS ('dbx_business_glossary_term' = 'Rate Version (RATE_VERSION)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Created (RECORD_AUDIT_CREATED)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Updated (RECORD_AUDIT_UPDATED)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `remarks` SET TAGS ('dbx_business_glossary_term' = 'Remarks (REMARKS)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `spot_rate` SET TAGS ('dbx_business_glossary_term' = 'Spot Rate (SPOT_RATE)');
ALTER TABLE `asset_management`.`valuation`.`valuation_fx_rate` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Updated At (UPDATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` SET TAGS ('dbx_subdomain' = 'fair_value');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `nav_liability_id` SET TAGS ('dbx_business_glossary_term' = 'Nav Liability ID (NAV_LIABILITY_ID)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `adjustment_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Document ID (LIABILITY_DOCUMENT_ID)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID (COUNTERPARTY_ID)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund ID (FUND_ID)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID (PORTFOLIO_ID)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `settlement_cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Settlement Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle ID (VALUATION_CYCLE_ID)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `valuation_nav_record_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Nav Record Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `counterparty_address` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Address (COUNTERPARTY_ADDRESS)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `counterparty_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `counterparty_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `counterparty_contact` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Contact (COUNTERPARTY_CONTACT)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `counterparty_contact` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `counterparty_contact` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `counterparty_email` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Email (COUNTERPARTY_EMAIL)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `counterparty_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `counterparty_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `counterparty_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `counterparty_phone` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Phone (COUNTERPARTY_PHONE)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `counterparty_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `counterparty_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `counterparty_type` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Type (COUNTERPARTY_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `counterparty_type` SET TAGS ('dbx_value_regex' = 'counterparty|vendor|customer|partner|other');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Created At (CREATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `nav_liability_description` SET TAGS ('dbx_business_glossary_term' = 'Description (DESCRIPTION)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date (EFFECTIVE_DATE)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `legal_entity_code` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity ID (LEGAL_ENTITY_ID)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `liability_amount` SET TAGS ('dbx_business_glossary_term' = 'Liability Amount (LIABILITY_AMOUNT)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `liability_currency` SET TAGS ('dbx_business_glossary_term' = 'Liability Currency (LIABILITY_CURRENCY)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `liability_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `liability_date` SET TAGS ('dbx_business_glossary_term' = 'Liability Date (LIABILITY_DATE)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `liability_document_code` SET TAGS ('dbx_business_glossary_term' = 'Liability Document ID (LIABILITY_DOCUMENT_ID)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `liability_document_date` SET TAGS ('dbx_business_glossary_term' = 'Liability Document Date (LIABILITY_DOCUMENT_DATE)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `liability_document_type` SET TAGS ('dbx_business_glossary_term' = 'Liability Document Type (LIABILITY_DOCUMENT_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `liability_document_type` SET TAGS ('dbx_value_regex' = 'pdf|docx|xlsx|other');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `liability_document_url` SET TAGS ('dbx_business_glossary_term' = 'Liability Document URL (LIABILITY_DOCUMENT_URL)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `liability_document_version` SET TAGS ('dbx_business_glossary_term' = 'Liability Document Version (LIABILITY_DOCUMENT_VERSION)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `liability_subtype` SET TAGS ('dbx_business_glossary_term' = 'Liability Subtype (LIABILITY_SUBTYPE)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `liability_type` SET TAGS ('dbx_business_glossary_term' = 'Liability Type (LIABILITY_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `liability_type` SET TAGS ('dbx_value_regex' = 'management_fee|carried_interest|redemption|borrowing|derivative_liability|tax_provision');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date (MATURITY_DATE)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `nav_liability_status` SET TAGS ('dbx_business_glossary_term' = 'Liability Status (STATUS)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `nav_liability_status` SET TAGS ('dbx_value_regex' = 'active|settled|pending|cancelled|closed');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes (NOTES)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Created (RECORD_AUDIT_CREATED)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Updated (RECORD_AUDIT_UPDATED)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Reference Number (REFERENCE_NUMBER)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Settlement Amount (SETTLEMENT_AMOUNT)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `settlement_currency` SET TAGS ('dbx_business_glossary_term' = 'Settlement Currency (SETTLEMENT_CURRENCY)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `settlement_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date (SETTLEMENT_DATE)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method (SETTLEMENT_METHOD)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'bank_transfer|cash|check|wire|cheque|other');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `settlement_reference` SET TAGS ('dbx_business_glossary_term' = 'Settlement Reference (SETTLEMENT_REFERENCE)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `settlement_status` SET TAGS ('dbx_business_glossary_term' = 'Settlement Status (SETTLEMENT_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `settlement_status` SET TAGS ('dbx_value_regex' = 'settled|pending|failed|reversed');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System ID (SOURCE_SYSTEM_ID)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `source_system_version` SET TAGS ('dbx_business_glossary_term' = 'Source System Version (SOURCE_SYSTEM_VERSION)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount (TAX_AMOUNT)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `tax_code` SET TAGS ('dbx_business_glossary_term' = 'Tax Code (TAX_CODE)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `tax_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Tax Jurisdiction (TAX_JURISDICTION)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `tax_jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Tax Rate (TAX_RATE)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `tax_type` SET TAGS ('dbx_business_glossary_term' = 'Tax Type (TAX_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `tax_type` SET TAGS ('dbx_value_regex' = 'income_tax|capital_gains|value_added_tax|sales_tax|other');
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Updated At (UPDATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`input` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`valuation`.`input` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`input` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`input` SET TAGS ('dbx_subdomain' = 'valuation_methodology');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `input_id` SET TAGS ('dbx_business_glossary_term' = 'Input ID (INPUT_ID)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `approval_by` SET TAGS ('dbx_business_glossary_term' = 'Input Approval By (INPUT_APPROVAL_BY)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `approval_comments` SET TAGS ('dbx_business_glossary_term' = 'Input Approval Comments (INPUT_APPROVAL_COMMENTS)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Input Approval Date (INPUT_APPROVAL_DATE)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `input_code` SET TAGS ('dbx_business_glossary_term' = 'Input Code (INPUT_CODE)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Input Created At (INPUT_CREATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `input_description` SET TAGS ('dbx_business_glossary_term' = 'Input Description (INPUT_DESCRIPTION)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Input Effective From (INPUT_EFFECTIVE_FROM)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Input Effective Until (INPUT_EFFECTIVE_UNTIL)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `input_status` SET TAGS ('dbx_business_glossary_term' = 'Input Status (INPUT_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `input_type` SET TAGS ('dbx_business_glossary_term' = 'Input Type (INPUT_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Input Is Active (INPUT_IS_ACTIVE)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `is_approved` SET TAGS ('dbx_business_glossary_term' = 'Input Is Approved (INPUT_IS_APPROVED)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `is_confidential` SET TAGS ('dbx_business_glossary_term' = 'Input Is Confidential (INPUT_IS_CONFIDENTIAL)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `is_default` SET TAGS ('dbx_business_glossary_term' = 'Input Is Default (INPUT_IS_DEFAULT)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `is_derived` SET TAGS ('dbx_business_glossary_term' = 'Input Is Derived (INPUT_IS_DERIVED)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `is_required` SET TAGS ('dbx_business_glossary_term' = 'Input Is Required (INPUT_IS_REQUIRED)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `input_name` SET TAGS ('dbx_business_glossary_term' = 'Input Name (INPUT_NAME)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `remarks` SET TAGS ('dbx_business_glossary_term' = 'Input Remarks (INPUT_REMARKS)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `source` SET TAGS ('dbx_business_glossary_term' = 'Input Source (INPUT_SOURCE)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `source_reference` SET TAGS ('dbx_business_glossary_term' = 'Input Source Reference (INPUT_SOURCE_REFERENCE)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `unit` SET TAGS ('dbx_business_glossary_term' = 'Input Unit (INPUT_UNIT)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Input Updated At (INPUT_UPDATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Input Updated By (INPUT_UPDATED_BY)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `value` SET TAGS ('dbx_business_glossary_term' = 'Input Value (INPUT_VALUE)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Input Version (INPUT_VERSION)');
ALTER TABLE `asset_management`.`valuation`.`input` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Input Created By (INPUT_CREATED_BY)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` SET TAGS ('dbx_subdomain' = 'valuation_methodology');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `sensitivity_id` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity ID (SENS_ID)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Agent ID (SENS_AGENT_ID)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `climate_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `created_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Created By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `created_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `created_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `macro_indicator_id` SET TAGS ('dbx_business_glossary_term' = 'Macro Indicator Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `model_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Model ID (SENS_MODEL_ID)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `valuation_asset_valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset ID (SENS_ASSET_ID)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset ID (SENS_ASSET_ID)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle ID (SENS_CYCLE_ID)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `base_case_value` SET TAGS ('dbx_business_glossary_term' = 'Base Case Value (SENS_BASE_VAL)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Created At (SENS_CREATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Created By User (SENS_CREATED_BY)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `delta_value` SET TAGS ('dbx_business_glossary_term' = 'Delta Value (SENS_DELTA_VAL)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `sensitivity_description` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Description (SENS_DESC)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Notes (SENS_NOTES)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `percent_change` SET TAGS ('dbx_business_glossary_term' = 'Percent Change (SENS_PCT_CHANGE)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `run_date` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Run Date (SENS_RUN_DATE)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `run_description` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Run Description (SENS_RUN_DESC)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `run_duration_seconds` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Run Duration Seconds (SENS_RUN_DUR_SEC)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `run_engine_version` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Run Engine Version (SENS_RUN_ENGINE_VER)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `run_environment` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Run Environment (SENS_RUN_ENV)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `run_error_message` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Run Error Message (SENS_RUN_ERR_MSG)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `run_notes` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Run Notes (SENS_RUN_NOTES)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `run_number` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Run Number (SENS_RUN_NUM)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `run_source_system` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Run Source System (SENS_RUN_SRC_SYS)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `run_source_system_description` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Run Source System Description (SENS_RUN_SRC_DESC)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `run_source_system_version` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Run Source System Version (SENS_RUN_SRC_VER)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `run_status` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Run Status (SENS_RUN_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `run_status` SET TAGS ('dbx_value_regex' = 'completed|failed|in_progress|cancelled');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `run_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Run Timestamp (SENS_RUN_TS)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `sensitivity_status` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Status (SENS_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `sensitivity_status` SET TAGS ('dbx_value_regex' = 'completed|failed|in_progress|cancelled');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Updated At (SENS_UPDATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `updated_by_user` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Updated By User (SENS_UPDATED_BY)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `valuation_engine` SET TAGS ('dbx_business_glossary_term' = 'Valuation Engine (SENS_VAL_ENGINE)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `valuation_engine` SET TAGS ('dbx_value_regex' = 'SimCorp|Aladdin|Bloomberg');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method (SENS_VAL_METHOD)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'DCF|Market|NAV|Fair Value');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `valuation_source_code` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source ID (SENS_SRC_ID)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `valuation_source_name` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source Name (SENS_SRC_NAME)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `valuation_source_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source Status (SENS_SRC_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `valuation_source_status` SET TAGS ('dbx_value_regex' = 'Active|Inactive|Pending');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `valuation_source_type` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source Type (SENS_SRC_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `valuation_source_type` SET TAGS ('dbx_value_regex' = 'Internal|External|ThirdParty');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `valuation_source_version` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source Version (SENS_SRC_VER)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `variable` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Variable (SENS_VAR)');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `variable` SET TAGS ('dbx_value_regex' = 'WACC|terminal_growth_rate|exit_multiple|cap_rate');
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ALTER COLUMN `variable_value` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Variable Value (SENS_VAR_VAL)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` SET TAGS ('dbx_subdomain' = 'fair_value');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `real_estate_appraisal_id` SET TAGS ('dbx_business_glossary_term' = 'Real Estate Appraisal ID (REA_ID)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property ID (PROP_ID)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `real_adjustment_id` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Document ID (APP_DOC_ID)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `real_property_valuation_document_adjustment_id` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Document ID (PROP_VAL_DOC_ID)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `taxonomy_alignment_id` SET TAGS ('dbx_business_glossary_term' = 'Taxonomy Alignment Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraisal_comments` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Comments (APP_COMMENTS)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraisal_currency` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Currency (APP_CURR)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraisal_date` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Date (APP_DATE)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraisal_document_code` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Document ID (APP_DOC_ID)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraisal_document_date` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Document Date (APP_DOC_DATE)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraisal_document_hash` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Document Hash (APP_DOC_HASH)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraisal_document_signed_at` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Document Signed At (APP_DOC_SIGNED_AT)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraisal_document_signed_by` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Document Signed By (APP_DOC_SIGNED_BY)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraisal_document_signed_by` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraisal_document_signed_by` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraisal_document_status` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Document Status (APP_DOC_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraisal_document_type` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Document Type (APP_DOC_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraisal_document_url` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Document URL (APP_DOC_URL)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraisal_document_version` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Document Version (APP_DOC_VER)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraisal_method` SET TAGS ('dbx_business_glossary_term' = 'Appraisal Method (APP_METHOD)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraised_value` SET TAGS ('dbx_business_glossary_term' = 'Appraised Value (APP_VAL)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraiser_firm` SET TAGS ('dbx_business_glossary_term' = 'Appraiser Firm (APPRAISER_FIRM)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraiser_name` SET TAGS ('dbx_business_glossary_term' = 'Appraiser Name (APPRAISER_NAME)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraiser_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `appraiser_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_address` SET TAGS ('dbx_business_glossary_term' = 'Property Address (PROP_ADDR)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_area_sqft` SET TAGS ('dbx_business_glossary_term' = 'Property Area (SQFT) (PROP_AREA_SQFT)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_city` SET TAGS ('dbx_business_glossary_term' = 'Property City (PROP_CITY)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_country` SET TAGS ('dbx_business_glossary_term' = 'Property Country (PROP_COUNTRY)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_ownership_type` SET TAGS ('dbx_business_glossary_term' = 'Property Ownership Type (PROP_OWN_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_state` SET TAGS ('dbx_business_glossary_term' = 'Property State (PROP_STATE)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_status` SET TAGS ('dbx_business_glossary_term' = 'Property Status (PROP_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_type` SET TAGS ('dbx_business_glossary_term' = 'Property Type (PROP_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_comments` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Comments (PROP_VAL_COMMENTS)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_currency` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Currency (PROP_VAL_CURR)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Date (PROP_VAL_DATE)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_document_code` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Document ID (PROP_VAL_DOC_ID)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_document_date` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Document Date (PROP_VAL_DOC_DATE)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_document_hash` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Document Hash (PROP_VAL_DOC_HASH)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_document_signed_at` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Document Signed At (PROP_VAL_DOC_SIGNED_AT)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_document_signed_by` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Document Signed By (PROP_VAL_DOC_SIGNED_BY)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_document_signed_by` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_document_signed_by` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_document_status` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Document Status (PROP_VAL_DOC_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_document_type` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Document Type (PROP_VAL_DOC_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_document_url` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Document URL (PROP_VAL_DOC_URL)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_document_version` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Document Version (PROP_VAL_DOC_VER)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Method (PROP_VAL_METHOD)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_notes` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Notes (PROP_VAL_NOTES)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_status` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Status (PROP_VAL_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_valuation_value` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Value (PROP_VAL_VALUE)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_year_built` SET TAGS ('dbx_business_glossary_term' = 'Property Year Built (PROP_YEAR_BUILT)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_zip_code` SET TAGS ('dbx_business_glossary_term' = 'Property ZIP Code (PROP_ZIP)');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_zip_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ALTER COLUMN `property_zip_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` SET TAGS ('dbx_subdomain' = 'fair_value');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `infrastructure_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Infrastructure Valuation ID (Infrastructure Valuation ID)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Agent ID (Valuation Agent ID)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `adjustment_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document ID (Valuation Document ID)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Dd Engagement Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Manager ID (Portfolio Manager ID)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `infra_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Asset ID (Asset ID)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `issuer_esg_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer Esg Rating Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID (Portfolio ID)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle ID (Valuation Cycle ID)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `asset_category` SET TAGS ('dbx_business_glossary_term' = 'Asset Category (Asset Category)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class (Asset Class)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `asset_currency` SET TAGS ('dbx_business_glossary_term' = 'Asset Currency (Asset Currency)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `asset_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `asset_isin` SET TAGS ('dbx_business_glossary_term' = 'Asset ISIN (ISIN)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `asset_isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[0-9A-Z]{9}[0-9]$');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `asset_name` SET TAGS ('dbx_business_glossary_term' = 'Asset Name (Asset Name)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `asset_sector` SET TAGS ('dbx_business_glossary_term' = 'Asset Sector (Asset Sector)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `asset_subclass` SET TAGS ('dbx_business_glossary_term' = 'Asset Subclass (Asset Subclass)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `asset_type` SET TAGS ('dbx_business_glossary_term' = 'Asset Type (Asset Type)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `book_value` SET TAGS ('dbx_business_glossary_term' = 'Book Value (Book Value)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Created At (Created At)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `fair_value` SET TAGS ('dbx_business_glossary_term' = 'Fair Value (Fair Value)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `gav` SET TAGS ('dbx_business_glossary_term' = 'Gross Asset Value (GAV)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `infrastructure_valuation_status` SET TAGS ('dbx_business_glossary_term' = 'Status (Status)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `infrastructure_valuation_status` SET TAGS ('dbx_value_regex' = 'draft|pending|approved|published|archived');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `market_value` SET TAGS ('dbx_business_glossary_term' = 'Market Value (Market Value)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `nav` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `portfolio_type` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Type (Portfolio Type)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Updated At (Updated At)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_comments` SET TAGS ('dbx_business_glossary_term' = 'Valuation Comments (Valuation Comments)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_cycle_frequency` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Frequency (Valuation Cycle Frequency)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_cycle_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|annual');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_document_code` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document ID (Valuation Document ID)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_document_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Date (Valuation Document Date)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_document_hash` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Hash (Valuation Document Hash)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_document_signed_at` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Signed At (Valuation Document Signed At)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_document_signed_by` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Signed By (Valuation Document Signed By)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_document_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Status (Valuation Document Status)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_document_status` SET TAGS ('dbx_value_regex' = 'draft|approved|archived');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_document_type` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Type (Valuation Document Type)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_document_type` SET TAGS ('dbx_value_regex' = 'pdf|docx|xlsx|txt');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_document_url` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document URL (Valuation Document URL)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_document_url` SET TAGS ('dbx_value_regex' = '^https?://.*$');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_document_version` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Version (Valuation Document Version)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_engine` SET TAGS ('dbx_business_glossary_term' = 'Valuation Engine (Valuation Engine)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method (Valuation Method)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_reason` SET TAGS ('dbx_business_glossary_term' = 'Valuation Reason (Valuation Reason)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_reference` SET TAGS ('dbx_business_glossary_term' = 'Valuation Reference (Valuation Reference)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_source_code` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source ID (Valuation Source ID)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_source_name` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source Name (Valuation Source Name)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Status (Valuation Status)');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_status` SET TAGS ('dbx_value_regex' = 'draft|pending|approved|published|archived');
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ALTER COLUMN `valuation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Valuation Timestamp (Valuation Timestamp)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` SET TAGS ('dbx_subdomain' = 'fair_value');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `credit_instrument_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Instrument Valuation ID (ID)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Agent ID (Agent ID)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `adjustment_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document ID (Doc ID)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `credit_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `issuer_esg_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer Esg Rating Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID (Portfolio ID)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `regulatory_reporting_regulatory_filing_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting ID (Reg ID)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `research_yield_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Research Yield Curve Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle ID (Cycle ID)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `accrued_interest` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest (Accrued)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `book_value` SET TAGS ('dbx_business_glossary_term' = 'Book Value (Book Value)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `clean_price` SET TAGS ('dbx_business_glossary_term' = 'Clean Price (Clean)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `coupon_rate` SET TAGS ('dbx_business_glossary_term' = 'Coupon Rate (Coupon)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Record Created At (Created At)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (Currency)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `dirty_price` SET TAGS ('dbx_business_glossary_term' = 'Dirty Price (Dirty)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `face_value` SET TAGS ('dbx_business_glossary_term' = 'Face Value (FV)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `fair_value` SET TAGS ('dbx_business_glossary_term' = 'Fair Value (Fair Value)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `gav` SET TAGS ('dbx_business_glossary_term' = 'Gross Asset Value (GAV)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `instrument_cusip` SET TAGS ('dbx_business_glossary_term' = 'Credit Instrument CUSIP (CUSIP)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `instrument_cusip` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{9}$');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `instrument_isin` SET TAGS ('dbx_business_glossary_term' = 'Credit Instrument ISIN (ISIN)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `instrument_isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[0-9A-Z]{9}[0-9]$');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `instrument_type` SET TAGS ('dbx_business_glossary_term' = 'Credit Instrument Type (Type)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `instrument_type` SET TAGS ('dbx_value_regex' = 'IG bond|HY bond|Private credit|Sovereign debt');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `market_code` SET TAGS ('dbx_business_glossary_term' = 'Market Code (Market)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `market_value` SET TAGS ('dbx_business_glossary_term' = 'Market Value (Market Value)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date (Maturity Date)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `nav` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `oas` SET TAGS ('dbx_business_glossary_term' = 'Option-Adjusted Spread (OAS)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Created (Audit Created)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Updated (Audit Updated)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `risk_metric_convexity` SET TAGS ('dbx_business_glossary_term' = 'Convexity (Convexity)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `risk_metric_credit_spread` SET TAGS ('dbx_business_glossary_term' = 'Credit Spread (Credit Spread)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `risk_metric_duration` SET TAGS ('dbx_business_glossary_term' = 'Duration (Duration)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Record Updated At (Updated At)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `valuation_comments` SET TAGS ('dbx_business_glossary_term' = 'Valuation Comments (Comments)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date (Valuation Date)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `valuation_document_code` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document ID (Doc ID)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `valuation_document_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Date (Doc Date)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `valuation_document_type` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Type (Doc Type)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `valuation_document_type` SET TAGS ('dbx_value_regex' = 'PDF|Word|Excel|Image|Other');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `valuation_document_url` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document URL (Doc URL)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `valuation_engine` SET TAGS ('dbx_business_glossary_term' = 'Valuation Engine (Engine)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `valuation_engine` SET TAGS ('dbx_value_regex' = 'SimCorp|BlackRock|Bloomberg|Aladdin');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method (Method)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'MTM|DCF|WACC|Fair Value Hierarchy');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `valuation_source_code` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source ID (Source ID)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `valuation_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Status (Status)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `valuation_status` SET TAGS ('dbx_value_regex' = 'Pending|Approved|Rejected|In Review|Completed');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `valuation_time` SET TAGS ('dbx_business_glossary_term' = 'Valuation Time (Valuation Time)');
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ALTER COLUMN `ytm` SET TAGS ('dbx_business_glossary_term' = 'Yield to Maturity (YTM)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`valuation`.`price_exception` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`price_exception` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`price_exception` SET TAGS ('dbx_subdomain' = 'market_pricing');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `price_exception_id` SET TAGS ('dbx_business_glossary_term' = 'Price Exception ID (PRICE_EXCEPTION_ID)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Exception Valuation Agent ID (EXC_VALUATION_AGENT_ID)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `adjustment_id` SET TAGS ('dbx_business_glossary_term' = 'Exception Document ID (EXC_DOCUMENT_ID)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Exception Cycle ID (EXC_CYCLE_ID)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Exception Valuation ID (EXC_VALUATION_ID)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `limit_breach_id` SET TAGS ('dbx_business_glossary_term' = 'Limit Breach Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `rule_breach_id` SET TAGS ('dbx_business_glossary_term' = 'Rule Breach Id (Foreign Key)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_created_at` SET TAGS ('dbx_business_glossary_term' = 'Exception Created At (EXC_CREATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_cycle_frequency` SET TAGS ('dbx_business_glossary_term' = 'Exception Cycle Frequency (EXC_CYCLE_FREQUENCY)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_description` SET TAGS ('dbx_business_glossary_term' = 'Exception Description (EXC_DESCRIPTION)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_document_code` SET TAGS ('dbx_business_glossary_term' = 'Exception Document ID (EXC_DOCUMENT_ID)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_document_hash` SET TAGS ('dbx_business_glossary_term' = 'Exception Document Hash (EXC_DOCUMENT_HASH)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_document_signed_at` SET TAGS ('dbx_business_glossary_term' = 'Exception Document Signed At (EXC_DOCUMENT_SIGNED_AT)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_document_signed_by` SET TAGS ('dbx_business_glossary_term' = 'Exception Document Signed By (EXC_DOCUMENT_SIGNED_BY)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_document_status` SET TAGS ('dbx_business_glossary_term' = 'Exception Document Status (EXC_DOCUMENT_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_document_type` SET TAGS ('dbx_business_glossary_term' = 'Exception Document Type (EXC_DOCUMENT_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_document_url` SET TAGS ('dbx_business_glossary_term' = 'Exception Document URL (EXC_DOCUMENT_URL)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_reason` SET TAGS ('dbx_business_glossary_term' = 'Exception Reason (EXC_REASON)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Exception Record Audit Created (EXC_RECORD_AUDIT_CREATED)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Exception Record Audit Updated (EXC_RECORD_AUDIT_UPDATED)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_remarks` SET TAGS ('dbx_business_glossary_term' = 'Exception Remarks (EXC_REMARKS)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_severity` SET TAGS ('dbx_business_glossary_term' = 'Exception Severity (EXC_SEVERITY)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_severity` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_source` SET TAGS ('dbx_business_glossary_term' = 'Exception Source (EXC_SOURCE)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_source_code` SET TAGS ('dbx_business_glossary_term' = 'Exception Source ID (EXC_SOURCE_ID)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_source_system` SET TAGS ('dbx_business_glossary_term' = 'Exception Source System (EXC_SOURCE_SYSTEM)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_status` SET TAGS ('dbx_business_glossary_term' = 'Exception Status (EXC_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_status` SET TAGS ('dbx_value_regex' = 'open|resolved|acknowledged');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_threshold_unit` SET TAGS ('dbx_business_glossary_term' = 'Exception Threshold Unit (EXC_THRESHOLD_UNIT)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_threshold_unit` SET TAGS ('dbx_value_regex' = 'percent|absolute');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_threshold_value` SET TAGS ('dbx_business_glossary_term' = 'Exception Threshold Value (EXC_THRESHOLD_VALUE)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Exception Timestamp (EXC_TIMESTAMP)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_type` SET TAGS ('dbx_business_glossary_term' = 'Exception Type (EXC_TYPE)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_type` SET TAGS ('dbx_value_regex' = 'stale_price|missing_price|price_move_threshold|source_disagreement|nav');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_updated_at` SET TAGS ('dbx_business_glossary_term' = 'Exception Updated At (EXC_UPDATED_AT)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_valuation_comments` SET TAGS ('dbx_business_glossary_term' = 'Exception Valuation Comments (EXC_VALUATION_COMMENTS)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Exception Valuation Date (EXC_VALUATION_DATE)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_valuation_engine` SET TAGS ('dbx_business_glossary_term' = 'Exception Valuation Engine (EXC_VALUATION_ENGINE)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Exception Valuation Method (EXC_VALUATION_METHOD)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_valuation_reason` SET TAGS ('dbx_business_glossary_term' = 'Exception Valuation Reason (EXC_VALUATION_REASON)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_valuation_source_code` SET TAGS ('dbx_business_glossary_term' = 'Exception Valuation Source ID (EXC_VALUATION_SOURCE_ID)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_valuation_source_description` SET TAGS ('dbx_business_glossary_term' = 'Exception Valuation Source Description (EXC_VALUATION_SOURCE_DESCRIPTION)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_valuation_source_name` SET TAGS ('dbx_business_glossary_term' = 'Exception Valuation Source Name (EXC_VALUATION_SOURCE_NAME)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_valuation_status` SET TAGS ('dbx_business_glossary_term' = 'Exception Valuation Status (EXC_VALUATION_STATUS)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_valuation_time` SET TAGS ('dbx_business_glossary_term' = 'Exception Valuation Time (EXC_VALUATION_TIME)');
ALTER TABLE `asset_management`.`valuation`.`price_exception` ALTER COLUMN `exception_value` SET TAGS ('dbx_business_glossary_term' = 'Exception Value (EXC_VALUE)');
ALTER TABLE `asset_management`.`valuation`.`exclusion_screening` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`valuation`.`exclusion_screening` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`exclusion_screening` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`exclusion_screening` SET TAGS ('dbx_subdomain' = 'governance_oversight');
ALTER TABLE `asset_management`.`valuation`.`exclusion_screening` SET TAGS ('dbx_association_edges' = 'valuation.valuation_asset_valuation,esg.exclusion_list');
ALTER TABLE `asset_management`.`valuation`.`exclusion_screening` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Screening Reviewer ID');
ALTER TABLE `asset_management`.`valuation`.`exclusion_screening` ALTER COLUMN `check_date` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Check Date');
ALTER TABLE `asset_management`.`valuation`.`exclusion_screening` ALTER COLUMN `exclusion_screening_status` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Screening Status');
ALTER TABLE `asset_management`.`valuation`.`exclusion_screening` ALTER COLUMN `override_flag` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Override Flag');
ALTER TABLE `asset_management`.`valuation`.`exclusion_screening` ALTER COLUMN `override_reason` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Override Reason');
ALTER TABLE `asset_management`.`valuation`.`compliance_requirement` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`valuation`.`compliance_requirement` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`compliance_requirement` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`compliance_requirement` SET TAGS ('dbx_subdomain' = 'governance_oversight');
ALTER TABLE `asset_management`.`valuation`.`compliance_requirement` SET TAGS ('dbx_association_edges' = 'valuation.methodology,compliance.rule');
ALTER TABLE `asset_management`.`valuation`.`compliance_requirement` ALTER COLUMN `compliance_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Requirement ID');
ALTER TABLE `asset_management`.`valuation`.`compliance_requirement` ALTER COLUMN `compliance_requirement_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status');
ALTER TABLE `asset_management`.`valuation`.`compliance_requirement` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`valuation`.`compliance_requirement` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Compliance Effective From Date');
ALTER TABLE `asset_management`.`valuation`.`compliance_requirement` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Compliance Effective Until Date');
ALTER TABLE `asset_management`.`valuation`.`compliance_requirement` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`valuation`.`compliance_requirement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Compliance Notes');
ALTER TABLE `asset_management`.`valuation`.`compliance_requirement` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`valuation`.`compliance_requirement` ALTER COLUMN `validated_by` SET TAGS ('dbx_business_glossary_term' = 'Validated By User ID');
ALTER TABLE `asset_management`.`valuation`.`compliance_requirement` ALTER COLUMN `validation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Validation Date');
ALTER TABLE `asset_management`.`valuation`.`filing_inclusion` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`valuation`.`filing_inclusion` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`filing_inclusion` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`filing_inclusion` SET TAGS ('dbx_subdomain' = 'governance_oversight');
ALTER TABLE `asset_management`.`valuation`.`filing_inclusion` SET TAGS ('dbx_association_edges' = 'valuation.valuation_asset_valuation,compliance.regulatory_filing');
ALTER TABLE `asset_management`.`valuation`.`filing_inclusion` ALTER COLUMN `filing_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Date');
ALTER TABLE `asset_management`.`valuation`.`filing_inclusion` ALTER COLUMN `inclusion_status` SET TAGS ('dbx_business_glossary_term' = 'Inclusion Status');
ALTER TABLE `asset_management`.`valuation`.`filing_inclusion` ALTER COLUMN `reported_value` SET TAGS ('dbx_business_glossary_term' = 'Reported Value');
ALTER TABLE `asset_management`.`valuation`.`filing_inclusion` ALTER COLUMN `variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Variance Amount');
ALTER TABLE `asset_management`.`valuation`.`quote_source` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`valuation`.`quote_source` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`quote_source` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`quote_source` SET TAGS ('dbx_subdomain' = 'market_pricing');
ALTER TABLE `asset_management`.`valuation`.`quote_source` ALTER COLUMN `quote_source_id` SET TAGS ('dbx_business_glossary_term' = 'Quote Source Identifier');
ALTER TABLE `asset_management`.`valuation`.`quote_source` ALTER COLUMN `api_endpoint_url` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`valuation`.`quote_source` ALTER COLUMN `contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`quote_source` ALTER COLUMN `contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`valuation`.`quote_source` ALTER COLUMN `contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`valuation`.`quote_source` ALTER COLUMN `contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`valuation`.`quote_source` ALTER COLUMN `contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`valuation`.`quote_source` ALTER COLUMN `contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`valuation`.`quote_source` ALTER COLUMN `contract_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`valuation`.`valuation_document` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`valuation`.`valuation_document` SET TAGS ('dbx_domain' = 'valuation');
ALTER TABLE `asset_management`.`valuation`.`valuation_document` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`valuation`.`valuation_document` SET TAGS ('dbx_subdomain' = 'governance_oversight');
ALTER TABLE `asset_management`.`valuation`.`valuation_document` ALTER COLUMN `valuation_document_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Document Identifier');
