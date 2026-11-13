-- Schema for Domain: portfolio | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:28

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`portfolio` COMMENT 'Authoritative domain for investment portfolio structure and construction across all asset classes—public equities, private equity, real estate, infrastructure, natural resources, and credit.';
ALTER SCHEMA `asset_management`.`portfolio` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `asset_management`.`portfolio` SET TAGS ('dbx_domain' = 'portfolio');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`portfolio` (
    `portfolio_id` BIGINT COMMENT 'Unique identifier for the investment portfolio. Primary key for the portfolio entity in the Investment Book of Record (IBOR).',
    `actuarial_valuation_id` BIGINT COMMENT 'Foreign key linking to actuarial.actuarial_valuation. Business justification: Portfolio reports are compared to actuarial valuations; FK supports generation of regulatory reports.',
    `alm_model_id` BIGINT COMMENT 'Foreign key linking to actuarial.alm_model. Business justification: Portfolio selects an ALM model for asset‑liability matching; ALM model selection is a formal business decision documented in the portfolio policy.',
    `asset_class_outlook_id` BIGINT COMMENT 'Foreign key linking to research.asset_class_outlook. Business justification: Portfolio asset allocation decisions reference asset class outlooks for expected returns.',
    `assumption_set_id` BIGINT COMMENT 'Foreign key linking to actuarial.assumption_set. Business justification: Portfolio uses a specific assumption set for valuation and risk‑analysis; assumption set selection is a named process in the ALM framework.',
    `capital_market_assumption_id` BIGINT COMMENT 'Foreign key linking to research.capital_market_assumption. Business justification: Portfolio valuation uses capital market assumptions for discount rates and risk premiums.',
    `composite_id` BIGINT COMMENT 'Reference to the GIPS composite that this portfolio belongs to for aggregated performance reporting.',
    `country_outlook_id` BIGINT COMMENT 'Foreign key linking to research.country_outlook. Business justification: Portfolio geographic allocation decisions reference country outlooks for risk assessment.',
    `created_by_actor_id` BIGINT COMMENT 'Foreign key linking to shared.actor. Business justification: Audit trail requires linking portfolio creator to the actor who performed the action.',
    `created_by_user_employee_id` BIGINT COMMENT 'User identifier of the person who created this portfolio record in the system.',
    `custodian_id` BIGINT COMMENT 'Reference to the external custodian bank (State Street, Northern Trust) responsible for safekeeping portfolio assets.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: Portfolio strategy documents reference a macroeconomic scenario for scenario analysis.',
    `employee_id` BIGINT COMMENT 'User identifier of the person who last modified this portfolio record.',
    `equity_benchmark_id` BIGINT COMMENT 'Reference to the primary benchmark index used for performance comparison and tracking error measurement.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the internal portfolio manager or investment team responsible for managing this portfolio.',
    `ldi_strategy_id` BIGINT COMMENT 'Foreign key linking to actuarial.ldi_strategy. Business justification: Portfolio may adopt an LDI strategy for hedging; FK links portfolio to the strategy used.',
    `legal_entity_id` BIGINT COMMENT 'Reference to the legal entity that owns or sponsors this portfolio. Used for regulatory reporting and legal documentation.',
    `macro_model_run_id` BIGINT COMMENT 'Foreign key linking to research.macro_model_run. Business justification: Portfolio risk assessment uses macro model run projections to set target returns.',
    `manager_employee_id` BIGINT COMMENT 'Reference to the internal portfolio manager or investment team responsible for managing this portfolio.',
    `modified_by_user_employee_id` BIGINT COMMENT 'User identifier of the person who last modified this portfolio record.',
    `sector_outlook_id` BIGINT COMMENT 'Foreign key linking to research.sector_outlook. Business justification: Portfolio sector allocation decisions reference sector outlooks for investment guidance.',
    `valuation_policy_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_policy. Business justification: Valuation governance requires each portfolio to reference its governing valuation policy.',
    `accounting_basis` STRING COMMENT 'Accounting standard used for portfolio valuation and financial reporting. International Financial Reporting Standards (IFRS), Generally Accepted Accounting Principles (GAAP), local GAAP, or statutory.. Valid values are `ifrs|gaap|local_gaap|statutory`',
    `asset_class_scope` STRING COMMENT 'Primary asset class or multi-asset scope that defines the investment universe for this portfolio. [ENUM-REF-CANDIDATE: multi_asset|public_equity|private_equity|real_estate|infrastructure|natural_resources|credit|fixed_income|cash — 9 candidates stripped',
    `base_currency` STRING COMMENT 'Three-letter ISO 4217 currency code representing the portfolios base reporting currency for valuation and performance measurement.. Valid values are `^[A-Z]{3}$`',
    `closure_date` DATE COMMENT 'Date when the portfolio was closed or terminated. Null for active portfolios.',
    `portfolio_code` STRING COMMENT 'Externally-known unique business identifier for the portfolio, used across systems and reporting. Typically alphanumeric code assigned at inception.. Valid values are `^[A-Z0-9]{4,12}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this portfolio record was first created in the system. Used for audit trail and data lineage.',
    `data_classification` STRING COMMENT 'Data sensitivity classification level for this portfolio record, determining access controls and handling requirements.. Valid values are `restricted|confidential|internal|public`',
    `portfolio_description` STRING COMMENT 'Detailed narrative description of the portfolios investment strategy, objectives, and unique characteristics.',
    `esg_framework` STRING COMMENT 'Primary ESG framework or standard applied to this portfolio. Principles for Responsible Investment (PRI), Task Force on Climate-related Financial Disclosures (TCFD), Sustainable Finance Disclosure Regulation (SFDR), UN Global Compact (UNGC), Sustainable. Valid values are `pri|tcfd|sfdr|ungc|sdg|none`',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether Environmental, Social, and Governance (ESG) factors are systematically integrated into the investment process for this portfolio.',
    `exclusion_list_applied_flag` BOOLEAN COMMENT 'Indicates whether an ESG exclusion list (e.g., tobacco, weapons, fossil fuels) is applied to investment decisions for this portfolio.',
    `gips_compliant_flag` BOOLEAN COMMENT 'Indicates whether the portfolios performance reporting is compliant with Global Investment Performance Standards (GIPS).',
    `inception_date` DATE COMMENT 'Date when the portfolio was established and began accepting investments. Used as the start date for performance measurement.',
    `investment_committee_approval_date` DATE COMMENT 'Date when the Investment Committee formally approved the establishment or material changes to this portfolio.',
    `investment_policy_version` STRING COMMENT 'Version number of the Investment Policy Statement governing this portfolios investment guidelines and constraints.. Valid values are `^[0-9]{1,3}.[0-9]{1,2}$`',
    `last_rebalance_date` DATE COMMENT 'Date of the most recent portfolio rebalancing event.',
    `leverage_limit_percent` DECIMAL(8,4) COMMENT 'Maximum allowable leverage ratio for the portfolio expressed as a percentage. Defines borrowing and derivative exposure constraints.',
    `liquidity_requirement_days` BIGINT COMMENT 'Minimum number of days of liquidity that must be maintained in the portfolio to meet redemption and operational cash needs.',
    `mandate_type` STRING COMMENT 'Investment mandate governing the portfolio strategy. Strategic Asset Allocation (SAA), Tactical Asset Allocation (TAA), Liability-Driven Investment (LDI), or other mandate types.. Valid values are `saa|taa|ldi|absolute_return|liability_matching|total_return`',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this portfolio record was last modified. Used for audit trail and change tracking.',
    `portfolio_name` STRING COMMENT 'Human-readable name of the investment portfolio, used for display and reporting purposes.',
    `next_rebalance_date` DATE COMMENT 'Scheduled date for the next portfolio rebalancing event based on rebalancing frequency.',
    `performance_calculation_method` STRING COMMENT 'Method used to calculate portfolio returns. Time-Weighted Return (TWR), Money-Weighted Return (MWR), Internal Rate of Return (IRR), or simple return.. Valid values are `twr|mwr|irr|simple`',
    `portfolio_status` STRING COMMENT 'Current lifecycle status of the portfolio indicating whether it is actively managed, suspended, closed, or in liquidation.. Valid values are `active|suspended|closed|liquidating|pending_approval`',
    `portfolio_type` STRING COMMENT 'Classification of the portfolio by its investment mandate and purpose within the fund structure.. Valid values are `strategic|tactical|overlay|benchmark|composite|shadow`',
    `rebalancing_frequency` STRING COMMENT 'Scheduled frequency at which the portfolio is rebalanced to maintain target asset allocation weights. [ENUM-REF-CANDIDATE: daily|weekly|monthly|quarterly|semi_annual|annual|event_driven — 7 candidates stripped; promote to reference product]',
    `regulatory_classification` STRING COMMENT 'Regulatory classification of the portfolio under applicable financial regulations. Undertakings for Collective Investment in Transferable Securities (UCITS), Alternative Investment Fund (AIF), pension fund, insurance-linked, sovereign wealth, endowment',
    `reporting_frequency` STRING COMMENT 'Frequency at which formal performance and valuation reports are generated for this portfolio.. Valid values are `daily|weekly|monthly|quarterly|annual`',
    `risk_tolerance_level` STRING COMMENT 'Risk appetite classification for the portfolio, defining acceptable volatility and drawdown thresholds.. Valid values are `conservative|moderate|balanced|growth|aggressive`',
    `target_return_percent` DECIMAL(8,4) COMMENT 'Target annualized return objective for the portfolio expressed as a percentage. Used for performance evaluation and strategic planning.',
    `tax_status` STRING COMMENT 'Tax treatment classification for the portfolio, determining how investment income and gains are taxed.. Valid values are `tax_exempt|taxable|tax_deferred|foreign_tax_credit`',
    `tracking_error_limit_bps` BIGINT COMMENT 'Maximum allowable tracking error versus the benchmark, expressed in basis points. Used for active risk management.',
    `valuation_frequency` STRING COMMENT 'Frequency at which Net Asset Value (NAV) is calculated for the portfolio. Critical for performance measurement and investor reporting.. Valid values are `daily|weekly|monthly|quarterly`',
    `var_limit_percent` DECIMAL(8,4) COMMENT 'Maximum allowable Value at Risk (VaR) for the portfolio expressed as a percentage of Net Asset Value (NAV). Used for risk constraint monitoring.',
    CONSTRAINT pk_portfolio PRIMARY KEY(`portfolio_id`)
) COMMENT 'Master record for each investment portfolio managed by the fund—the authoritative IBOR/ABOR portfolio entity maintained in SimCorp Dimension. Captures portfolio identity, mandate type (SAA/TAA), asset-class scope, base currency, inception date, regulatory';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`hierarchy` (
    `hierarchy_id` BIGINT COMMENT 'Unique identifier for the portfolio hierarchy relationship record.',
    `child_portfolio_id` BIGINT COMMENT 'Identifier of the child portfolio node in the hierarchy structure.',
    `parent_portfolio_id` BIGINT COMMENT 'Identifier of the parent portfolio node in the hierarchy structure.',
    `portfolio_benchmark_id` BIGINT COMMENT 'Identifier of the benchmark assigned to measure performance of this hierarchical relationship or child portfolio within the parent context.',
    `allocation_method` STRING COMMENT 'Methodology used to determine the allocation weight of the child portfolio within the parent structure.. Valid values are `market_value|notional|risk_weighted|equal_weighted|custom`',
    `allocation_weight` DECIMAL(18,8) COMMENT 'Proportional weight or percentage of the child portfolio within the parent portfolio, expressed as a decimal where 1.0 equals 100 percent.',
    `approval_authority` STRING COMMENT 'Name or role of the individual or committee that approved the establishment or modification of this hierarchical relationship.',
    `approval_date` DATE COMMENT 'Date when the hierarchical relationship was formally approved by the designated authority.',
    `consolidation_rule` STRING COMMENT 'Rule governing how the child portfolio positions and performance are consolidated into the parent portfolio for reporting and analytics.. Valid values are `full_consolidation|proportional|look_through|exclusion`',
    `constraint_description` STRING COMMENT 'Detailed textual description of specific constraints or restrictions applied to the parent-child portfolio relationship.',
    `constraint_type` STRING COMMENT 'Classification of constraints applied to the hierarchical relationship governing allocation limits and investment restrictions.. Valid values are `regulatory|policy|mandate|risk|liquidity|none`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this hierarchy relationship record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the allocation weight and consolidation calculations are denominated.. Valid values are `^[A-Z]{3}$`',
    `effective_date` DATE COMMENT 'Date when the hierarchical relationship between parent and child portfolios becomes active and operational.',
    `hierarchy_type` STRING COMMENT 'Classification of the hierarchical relationship type between parent and child portfolios.. Valid values are `composite|sleeve|sub_portfolio|fund_of_funds|mandate|asset_class`',
    `ic_approval_reference` STRING COMMENT 'Reference number or identifier of the Investment Committee decision or memorandum approving this hierarchical structure.',
    `is_active` BOOLEAN COMMENT 'Boolean indicator of whether this hierarchical relationship is currently active and operational.',
    `last_rebalance_date` DATE COMMENT 'Most recent date when the allocation weight between parent and child portfolios was rebalanced.',
    `hierarchy_level` BIGINT COMMENT 'Numeric depth level of the child node within the overall portfolio hierarchy tree structure, with 1 representing the top level.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this hierarchy relationship record was last modified or updated.',
    `next_rebalance_date` DATE COMMENT 'Scheduled date for the next rebalancing review of the allocation weight between parent and child portfolios.',
    `notes` STRING COMMENT 'Free-form text field for additional comments, rationale, or context regarding the hierarchical relationship.',
    `path` STRING COMMENT 'Full hierarchical path from root to current node, typically represented as a delimited string of portfolio identifiers for traversal and querying.',
    `performance_attribution_flag` BOOLEAN COMMENT 'Indicator whether the child portfolio performance should be attributed separately within parent portfolio performance analytics.',
    `rebalancing_frequency` STRING COMMENT 'Scheduled frequency at which the allocation weight between parent and child portfolios is reviewed and rebalanced. [ENUM-REF-CANDIDATE: daily|weekly|monthly|quarterly|annual|event_driven|none — 7 candidates stripped; promote to reference product]',
    `relationship_name` STRING COMMENT 'Business-friendly name describing the nature of the parent-child portfolio relationship.',
    `relationship_status` STRING COMMENT 'Current lifecycle state of the parent-child portfolio hierarchical relationship.. Valid values are `active|inactive|pending|suspended|terminated`',
    `reporting_inclusion_flag` BOOLEAN COMMENT 'Indicator whether the child portfolio should be included in consolidated parent portfolio reporting and performance attribution.',
    `saa_target_weight` DECIMAL(18,8) COMMENT 'Long-term strategic target allocation weight for the child portfolio within the parent portfolio structure, expressed as a decimal.',
    `sort_order` BIGINT COMMENT 'Numeric sequence used to control the display order of child portfolios within the same parent for reporting and user interface presentation.',
    `source_system_code` STRING COMMENT 'Unique identifier of this hierarchy record in the source operational system for traceability and reconciliation.',
    `taa_adjustment` DECIMAL(18,8) COMMENT 'Short-term tactical adjustment to the strategic allocation weight, expressed as a decimal deviation from the SAA target.',
    `termination_date` DATE COMMENT 'Date when the hierarchical relationship between parent and child portfolios ceases to be active, nullable for ongoing relationships.',
    `tolerance_band_lower` DECIMAL(18,8) COMMENT 'Lower boundary of the acceptable allocation weight range before rebalancing is triggered, expressed as a decimal.',
    `tolerance_band_upper` DECIMAL(18,8) COMMENT 'Upper boundary of the acceptable allocation weight range before rebalancing is triggered, expressed as a decimal.',
    CONSTRAINT pk_hierarchy PRIMARY KEY(`hierarchy_id`)
) COMMENT 'Defines the parent-child structure across portfolio nodes, enabling composite/sleeve/sub-portfolio relationships in multi-asset, fund-of-funds, and sleeve-based mandates, plus consolidated reporting.';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`portfolio_mandate` (
    `portfolio_mandate_id` BIGINT COMMENT 'Unique identifier for the investment mandate governing a portfolio or sleeve.',
    `performance_benchmark_id` BIGINT COMMENT 'Reference to the primary benchmark index used to measure mandate performance.',
    `benchmark_index_id` BIGINT COMMENT 'Reference to the primary benchmark index used to measure mandate performance.',
    `custodian_id` BIGINT COMMENT 'Reference to the custodian bank responsible for safekeeping of mandate assets.',
    `employee_id` BIGINT COMMENT 'Reference to the primary portfolio manager responsible for executing the mandate strategy.',
    `exclusion_list_id` BIGINT COMMENT 'Reference to the ESG exclusion list defining prohibited investments such as tobacco, weapons, or fossil fuels.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the primary portfolio manager responsible for executing the mandate strategy.',
    `legal_entity_id` BIGINT COMMENT 'Reference to the legal entity under which the mandate is established and operated.',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: Portfolio mandate belongs to a portfolio; linking provides parent‑child relationship and enables navigation from mandate to portfolio.',
    `approved_timestamp` TIMESTAMP COMMENT 'Timestamp when the mandate was formally approved by the investment committee. Null if pending approval.',
    `base_currency` STRING COMMENT 'Primary reporting currency for the mandate using ISO 4217 three-letter currency code.. Valid values are `^[A-Z]{3}$`',
    `concentration_limit_percent` DECIMAL(8,4) COMMENT 'Maximum percentage of portfolio value that may be invested in a single issuer or security.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the mandate record was first created in the system.',
    `currency_hedging_policy` STRING COMMENT 'Mandate policy for foreign exchange risk management: fully hedged, partially hedged, unhedged, or dynamic based on market conditions.. Valid values are `fully_hedged|partially_hedged|unhedged|dynamic`',
    `derivatives_permitted_flag` BOOLEAN COMMENT 'Indicates whether the mandate permits the use of derivative instruments for hedging or investment purposes.',
    `document_uri` STRING COMMENT 'Reference to the location of the legal mandate document such as investment management agreement or limited partnership agreement.',
    `esg_integration_level` STRING COMMENT 'Degree of ESG factor integration in investment decisions: none, basic screening, fully integrated, thematic ESG, or impact investing.. Valid values are `none|basic|integrated|thematic|impact`',
    `fee_structure` STRING COMMENT 'Description of the fee arrangement for the mandate including management fees, performance fees, and hurdle rates.',
    `geographic_restrictions` STRING COMMENT 'Geographic constraints on investments, specified as permitted or excluded regions and countries using ISO 3166-1 alpha-3 codes.',
    `high_water_mark_flag` BOOLEAN COMMENT 'Indicates whether performance fees are subject to a high water mark provision requiring recovery of prior losses.',
    `hurdle_rate_percent` DECIMAL(8,4) COMMENT 'Minimum return threshold that must be achieved before performance fees are charged. Null if not applicable.',
    `inception_date` DATE COMMENT 'Date when the mandate became effective and investment activity commenced.',
    `investment_committee_code` BIGINT COMMENT 'Reference to the investment committee responsible for governance and approval of mandate investments.',
    `investment_objective` STRING COMMENT 'Primary investment goal of the mandate such as capital preservation, income generation, growth, or total return.',
    `last_review_date` DATE COMMENT 'Date when the mandate was last reviewed by the investment committee or governance body.',
    `leverage_permitted_flag` BOOLEAN COMMENT 'Indicates whether the mandate permits the use of leverage or borrowing to enhance returns.',
    `liquidity_requirement_days` BIGINT COMMENT 'Minimum number of days within which a specified percentage of the portfolio must be liquidatable to meet cash flow needs.',
    `management_fee_bps` BIGINT COMMENT 'Annual management fee charged on assets under management expressed in basis points.',
    `mandate_code` STRING COMMENT 'Externally-known unique business identifier for the mandate, used in operational systems and reporting.. Valid values are `^[A-Z0-9]{6,20}$`',
    `mandate_name` STRING COMMENT 'Human-readable name of the investment mandate for business user identification and reporting.',
    `mandate_status` STRING COMMENT 'Current lifecycle state of the mandate indicating whether it is operational, suspended, terminated, or awaiting approval.. Valid values are `active|suspended|terminated|pending_approval|under_review`',
    `mandate_type` STRING COMMENT 'Classification of the mandate structure: internal discretionary, separately managed account, limited partner mandate, co-investment, fund of funds, or direct investment.. Valid values are `internal|sma|lp_mandate|co_investment|fund_of_funds|direct_investment`',
    `max_leverage_ratio` DECIMAL(8,4) COMMENT 'Maximum permitted leverage ratio expressed as total assets divided by net assets. Null if leverage not permitted.',
    `min_credit_rating` STRING COMMENT 'Minimum acceptable credit rating for fixed income investments using standard rating agency notation.. Valid values are `^(AAA|AA|A|BBB|BB|B|CCC|CC|C|D)[+-]?$`',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the mandate record was last modified in the system.',
    `next_review_date` DATE COMMENT 'Date when the mandate is scheduled for next review by the investment committee or governance body.',
    `performance_fee_percent` DECIMAL(8,4) COMMENT 'Performance-based fee as a percentage of returns above the hurdle rate. Null if not applicable.',
    `permitted_asset_classes` STRING COMMENT 'Comma-separated list of asset classes allowed under the mandate: public equities, private equity, real estate, infrastructure, natural resources, credit, fixed income.',
    `rebalancing_frequency` STRING COMMENT 'Frequency at which the portfolio is rebalanced to maintain target asset allocation. [ENUM-REF-CANDIDATE: daily|weekly|monthly|quarterly|semi_annual|annual|event_driven — 7 candidates stripped; promote to reference product]',
    `regulatory_classification` STRING COMMENT 'Regulatory classification of the mandate for compliance and reporting purposes such as UCITS, AIFMD, or pension fund mandate.',
    `reporting_frequency` STRING COMMENT 'Frequency at which performance reports are generated for the mandate.. Valid values are `daily|weekly|monthly|quarterly|semi_annual|annual`',
    `risk_tolerance` STRING COMMENT 'Acceptable level of investment risk for the mandate ranging from conservative to very aggressive.. Valid values are `conservative|moderate|balanced|aggressive|very_aggressive`',
    `sector_limit_percent` DECIMAL(8,4) COMMENT 'Maximum percentage of portfolio value that may be invested in a single industry sector.',
    `short_selling_permitted_flag` BOOLEAN COMMENT 'Indicates whether the mandate permits short selling of securities.',
    `target_return_percent` DECIMAL(8,4) COMMENT 'Annualized target return objective for the mandate expressed as a percentage.',
    `termination_date` DATE COMMENT 'Date when the mandate was terminated or is scheduled to terminate. Null for active mandates.',
    `tracking_error_limit_bps` BIGINT COMMENT 'Maximum allowable tracking error versus benchmark expressed in basis points. Null if not applicable.',
    `var_limit_percent` DECIMAL(8,4) COMMENT 'Maximum allowable Value at Risk expressed as a percentage of portfolio value. Null if not applicable.',
    CONSTRAINT pk_portfolio_mandate PRIMARY KEY(`portfolio_mandate_id`)
) COMMENT 'Authoritative master record for each investment mandate governing a portfolio or sleeve. Captures mandate type (internal, SMA, LP mandate, co-investment), investment universe constraints, permitted asset classes, geographic restrictions, currency hedging';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`saa_target` (
    `saa_target_id` BIGINT COMMENT 'Unique identifier for the strategic asset allocation target record.',
    `credit_benchmark_index_id` BIGINT COMMENT 'Foreign key linking to credit.benchmark_index. Business justification: SAA targets for credit asset classes require direct reference to credit benchmarks (Bloomberg Aggregate, ICE BofA) for policy weight calibration and performance attribution.',
    `employee_id` BIGINT COMMENT 'Identifier of the user or system process that created this SAA target record.',
    `last_modified_by_user_employee_id` BIGINT COMMENT 'Identifier of the user or system process that last modified this SAA target record.',
    `portfolio_benchmark_id` BIGINT COMMENT 'Reference to the market benchmark index used to evaluate performance of this asset class allocation.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio or fund to which this SAA target applies.',
    `saa_employee_id` BIGINT COMMENT 'Identifier of the user or system process that created this SAA target record.',
    `saa_last_modified_by_user_employee_id` BIGINT COMMENT 'Identifier of the user or system process that last modified this SAA target record.',
    `actual_weight_percent` DECIMAL(8,5) COMMENT 'Current realized weight of this asset class as a percentage of total portfolio, used for drift monitoring and rebalancing decisions.',
    `approval_authority` STRING COMMENT 'Name or identifier of the governance body that approved this SAA target (e.g., Investment Committee, Board of Directors).',
    `approval_date` DATE COMMENT 'Date on which the Investment Committee formally approved this SAA target.',
    `asset_class_code` STRING COMMENT 'Standardized code identifying the asset class (e.g., PUBLIC_EQUITY, PRIVATE_EQUITY, REAL_ESTATE, INFRASTRUCTURE, NATURAL_RESOURCES, CREDIT, FIXED_INCOME).. Valid values are `^[A-Z0-9_]{2,20}$`',
    `asset_class_name` STRING COMMENT 'Human-readable name of the asset class for reporting and display purposes.',
    `correlation_group_code` STRING COMMENT 'Code identifying the correlation group for portfolio optimization and diversification analysis (e.g., EQUITY_GROUP, FIXED_INCOME_GROUP).. Valid values are `^[A-Z0-9_]{2,20}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this SAA target record was first created in the system.',
    `effective_date` DATE COMMENT 'Date from which this SAA target becomes active and applicable for portfolio management and compliance monitoring.',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether ESG factors are formally integrated into investment decisions for this asset class allocation.',
    `exclusion_policy_applied_flag` BOOLEAN COMMENT 'Indicates whether negative screening or exclusion policies apply to investments within this asset class.',
    `expected_return_percent` DECIMAL(8,5) COMMENT 'Long-term expected annualized return assumption for this asset class used in ALM modeling and strategic planning.',
    `expected_volatility_percent` DECIMAL(8,5) COMMENT 'Long-term expected annualized volatility (standard deviation) assumption for this asset class used in risk modeling.',
    `expiry_date` DATE COMMENT 'Date on which this SAA target ceases to be active; nullable for open-ended targets subject to periodic review.',
    `geographic_constraint_code` STRING COMMENT 'Geographic investment scope constraint for this asset class allocation (e.g., GLOBAL, DEVELOPED, EMERGING).. Valid values are `GLOBAL|DEVELOPED|EMERGING|REGIONAL|DOMESTIC`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this SAA target record.',
    `last_review_date` DATE COMMENT 'Date of the most recent Investment Committee or governance review of this SAA target.',
    `liquidity_classification` STRING COMMENT 'Classification of the asset class liquidity profile for cash management and liability matching purposes.. Valid values are `LIQUID|SEMI_LIQUID|ILLIQUID`',
    `maximum_weight_percent` DECIMAL(8,5) COMMENT 'Upper bound constraint for this asset class allocation as defined in the investment policy, triggering rebalancing if breached.',
    `minimum_weight_percent` DECIMAL(8,5) COMMENT 'Lower bound constraint for this asset class allocation as defined in the investment policy, triggering rebalancing if breached.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal review of this SAA target by the Investment Committee.',
    `policy_weight_percent` DECIMAL(8,5) COMMENT 'Long-term strategic policy target weight for this asset class as a percentage of total portfolio (e.g., 25.00000 for 25%).',
    `rationale_notes` STRING COMMENT 'Free-text explanation of the strategic rationale and Investment Committee considerations supporting this asset allocation target.',
    `rebalancing_threshold_percent` DECIMAL(8,5) COMMENT 'Tolerance band around policy weight; drift exceeding this threshold triggers rebalancing review (e.g., +/- 2.00000%).',
    `review_frequency_code` STRING COMMENT 'Scheduled frequency for reviewing and potentially updating this SAA target (e.g., ANNUAL, QUARTERLY).. Valid values are `ANNUAL|SEMI_ANNUAL|QUARTERLY|AD_HOC`',
    `saa_target_status` STRING COMMENT 'Current lifecycle status of this SAA target record (ACTIVE for in-force targets, SUPERSEDED for replaced targets).. Valid values are `ACTIVE|INACTIVE|PENDING|SUPERSEDED`',
    `sub_asset_class_code` STRING COMMENT 'Granular sub-classification within the asset class (e.g., DEVELOPED_EQUITY, EMERGING_EQUITY, CORE_REAL_ESTATE, VALUE_ADD_REAL_ESTATE).. Valid values are `^[A-Z0-9_]{2,30}$`',
    `sub_asset_class_name` STRING COMMENT 'Human-readable name of the sub-asset class for detailed reporting.',
    `tactical_adjustment_allowed_flag` BOOLEAN COMMENT 'Indicates whether tactical asset allocation (TAA) deviations from this strategic target are permitted within governance limits.',
    `tactical_adjustment_limit_percent` DECIMAL(8,5) COMMENT 'Maximum permitted tactical deviation from policy weight as a percentage (e.g., +/- 3.00000%), if tactical adjustments are allowed.',
    `target_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the SAA target is denominated (e.g., USD, GBP).. Valid values are `^[A-Z]{3}$`',
    `version_number` BIGINT COMMENT 'Sequential version number for this SAA target, incremented with each approved revision to maintain audit trail.',
    `weight_drift_percent` DECIMAL(8,5) COMMENT 'Difference between actual weight and policy weight (actual minus policy), indicating allocation drift requiring rebalancing consideration.',
    CONSTRAINT pk_saa_target PRIMARY KEY(`saa_target_id`)
) COMMENT 'Strategic Asset Allocation (SAA) policy record defining long-term policy weights per asset class for a portfolio or fund, together with the realized actual weight for drift monitoring.';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`taa_position` (
    `taa_position_id` BIGINT COMMENT 'Unique identifier for the tactical asset allocation position record.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio to which this tactical asset allocation position belongs.',
    `saa_target_id` BIGINT COMMENT 'Foreign key linking to portfolio.saa_target. Business justification: TAA positions represent tactical deviations from SAA targets. Explicit FK creates direct linkage between tactical positions and their strategic benchmarks, enabling deviation analysis',
    `actual_amount` DECIMAL(20,2) COMMENT 'The actual dollar value of holdings in this asset class as of the position date.',
    `actual_deviation_percent` DECIMAL(10,6) COMMENT 'The actual deviation from the TAA target weight, calculated as actual weight minus TAA target weight.',
    `actual_weight_percent` DECIMAL(10,6) COMMENT 'The actual current weight of this asset class in the portfolio, expressed as a percentage of total portfolio value.',
    `approval_status` STRING COMMENT 'Approval status of the TAA position by the Investment Committee.. Valid values are `pending|approved|rejected`',
    `approved_by` STRING COMMENT 'Name or identifier of the Investment Committee member or authority who approved the TAA position.',
    `asset_class_code` STRING COMMENT 'Standardized code identifying the asset class (e.g., PUBLIC_EQUITY, PRIVATE_EQUITY, REAL_ESTATE, INFRASTRUCTURE, NATURAL_RESOURCES, CREDIT, FIXED_INCOME).. Valid values are `^[A-Z0-9_]{2,20}$`',
    `asset_class_name` STRING COMMENT 'Human-readable name of the asset class for reporting and display purposes.',
    `benchmark_code` STRING COMMENT 'Code identifying the benchmark index used to measure performance for this asset class.. Valid values are `^[A-Z0-9_]{2,30}$`',
    `benchmark_name` STRING COMMENT 'Human-readable name of the benchmark index for this asset class.',
    `comments` STRING COMMENT 'Additional notes or commentary regarding the tactical asset allocation position.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this TAA position record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the position amounts are denominated.. Valid values are `^[A-Z]{3}$`',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether ESG factors are formally integrated into the investment process for this asset class.',
    `expected_return_percent` DECIMAL(10,6) COMMENT 'The expected annualized return for this asset class over the TAA horizon, as estimated by the investment team.',
    `expected_volatility_percent` DECIMAL(10,6) COMMENT 'The expected annualized volatility (standard deviation of returns) for this asset class over the TAA horizon.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'The date and time when this TAA position record was most recently modified.',
    `liquidity_classification` STRING COMMENT 'Classification of the asset class based on its liquidity profile for cash management and rebalancing purposes.. Valid values are `highly_liquid|liquid|semi_liquid|illiquid`',
    `position_date` DATE COMMENT 'The business date as of which this tactical asset allocation position is effective.',
    `rebalancing_required_flag` BOOLEAN COMMENT 'Indicates whether the actual deviation exceeds the rebalancing thresholds and action is required.',
    `rebalancing_threshold_lower_percent` DECIMAL(10,6) COMMENT 'The lower bound deviation threshold that triggers a rebalancing action for this asset class.',
    `rebalancing_threshold_upper_percent` DECIMAL(10,6) COMMENT 'The upper bound deviation threshold that triggers a rebalancing action for this asset class.',
    `risk_budget_percent` DECIMAL(10,6) COMMENT 'The percentage of total portfolio risk budget allocated to this asset class under the TAA framework.',
    `saa_target_amount` DECIMAL(20,2) COMMENT 'The dollar value corresponding to the SAA target weight for this asset class.',
    `saa_target_weight_percent` DECIMAL(10,6) COMMENT 'The long-term strategic asset allocation target weight for this asset class, expressed as a percentage of total portfolio value.',
    `sub_asset_class_code` STRING COMMENT 'Granular sub-classification within the asset class (e.g., DEVELOPED_EQUITY, EMERGING_EQUITY, CORE_REAL_ESTATE, VALUE_ADD_REAL_ESTATE).. Valid values are `^[A-Z0-9_]{2,30}$`',
    `sub_asset_class_name` STRING COMMENT 'Human-readable name of the sub-asset class for detailed reporting.',
    `taa_decision_date` DATE COMMENT 'The date on which the Investment Committee approved the current TAA target weight for this asset class.',
    `taa_deviation_percent` DECIMAL(10,6) COMMENT 'The tactical over or underweight deviation from the SAA target, calculated as TAA target weight minus SAA target weight.',
    `taa_horizon_months` BIGINT COMMENT 'The expected time horizon in months for which the tactical position is intended to be maintained.',
    `taa_position_status` STRING COMMENT 'Current lifecycle status of the tactical asset allocation position.. Valid values are `active|under_review|suspended|closed`',
    `taa_rationale` STRING COMMENT 'Brief description of the macroeconomic or market view justifying the tactical deviation from SAA.',
    `taa_review_date` DATE COMMENT 'The scheduled date for the next Investment Committee review of this tactical position.',
    `taa_target_amount` DECIMAL(20,2) COMMENT 'The dollar value corresponding to the TAA target weight for this asset class.',
    `taa_target_weight_percent` DECIMAL(10,6) COMMENT 'The current tactical asset allocation target weight for this asset class, reflecting short-to-medium term market views and deviations from SAA.',
    CONSTRAINT pk_taa_position PRIMARY KEY(`taa_position_id`)
) COMMENT 'Tactical Asset Allocation (TAA) position record capturing the current tactical over/underweight deviation from SAA targets for each asset class within a portfolio.';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`holding` (
    `holding_id` BIGINT COMMENT 'Unique identifier for the holding position record in the Investment Book of Record (IBOR).',
    `counterparty_id` BIGINT COMMENT 'Reference to the custodian bank or fund administrator holding the security on behalf of the portfolio.',
    `custodian_id` BIGINT COMMENT 'Reference to the custodian bank or fund administrator holding the security on behalf of the portfolio.',
    `fair_value_hierarchy_id` BIGINT COMMENT 'Foreign key linking to valuation.fair_value_hierarchy. Business justification: IFRS 13/ASC 820 fair value disclosure requires Level 1/2/3 classification per holding. Pension funds must report fair value hierarchy in financial statements.',
    `infra_asset_id` BIGINT COMMENT 'Foreign key linking to infrastructure.infra_asset. Business justification: Pension funds hold direct infrastructure assets. Holdings must reference infra_asset for NAV calculation, performance attribution, and regulatory reporting.',
    `listed_security_id` BIGINT COMMENT 'Reference to the security or asset held in this position.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio that owns this holding position.',
    `property_id` BIGINT COMMENT 'Foreign key linking to realestate.property. Business justification: Direct real estate holdings require property linkage for NAV calculation, performance attribution, and regulatory reporting.',
    `sleeve_id` BIGINT COMMENT 'Foreign key linking to portfolio.sleeve. Business justification: Holdings can be allocated to specific sleeves within a portfolio. Pension funds commonly organize holdings by sleeve (equity sleeve, fixed income sleeve, alternatives sleeve).',
    `account_number` STRING COMMENT 'The custodian account number where the security is held.',
    `accrued_income_base` DECIMAL(28,2) COMMENT 'The income earned but not yet received on the holding (e.g., accrued interest, dividends) in base currency.',
    `accrued_income_local` DECIMAL(28,2) COMMENT 'The income earned but not yet received on the holding in local currency.',
    `asset_class` STRING COMMENT 'The primary asset class classification of the holding for strategic asset allocation (SAA) and reporting purposes.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `base_currency_code` STRING COMMENT 'The three-letter ISO 4217 currency code for the portfolios base reporting currency.. Valid values are `^[A-Z]{3}$`',
    `benchmark_weight` DECIMAL(10,6) COMMENT 'The target weight of this security in the portfolios assigned benchmark, expressed as a decimal (e.g., 0.025 for 2.5%).',
    `collateral_flag` BOOLEAN COMMENT 'Indicates whether the holding is pledged as collateral for derivatives, securities lending, or repo transactions.',
    `commitment_amount` DECIMAL(28,2) COMMENT 'For private market investments, the total committed capital to the fund or co-investment, representing dry powder.',
    `cost_base` DECIMAL(28,2) COMMENT 'The total acquisition cost of the holding in base currency, used for gain/loss calculation.',
    `cost_local` DECIMAL(28,2) COMMENT 'The total acquisition cost of the holding in the local trading currency.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this holding record was first created in the IBOR system.',
    `esg_rating` STRING COMMENT 'The ESG rating or score assigned to the holding by an external provider (e.g., MSCI, Sustainalytics) for responsible investment reporting.',
    `exclusion_flag` BOOLEAN COMMENT 'Indicates whether the holding is subject to ESG exclusion criteria or is on a restricted list for responsible investment compliance.',
    `fx_rate` DECIMAL(18,8) COMMENT 'The exchange rate used to convert local currency values to base currency as of the position date.',
    `holding_status` STRING COMMENT 'The current lifecycle status of the holding position in the portfolio.. Valid values are `active|closed|pending_settlement|suspended|restricted`',
    `income_type` STRING COMMENT 'The type of income generated by this holding for performance attribution and tax reporting.. Valid values are `dividend|interest|distribution|capital_gain|other`',
    `investment_type` STRING COMMENT 'The structure of the investment: direct ownership, co-investment alongside a GP, fund commitment (LP), or secondary market purchase.. Valid values are `direct|co_investment|fund_investment|secondary`',
    `last_valuation_date` DATE COMMENT 'The date on which the holding was last valued, particularly relevant for illiquid private market assets.',
    `lending_flag` BOOLEAN COMMENT 'Indicates whether the holding is currently on loan under a securities lending program.',
    `liquidity_classification` STRING COMMENT 'The liquidity profile of the holding for liquidity risk management and cash flow forecasting.. Valid values are `liquid|semi_liquid|illiquid|locked_up`',
    `local_currency_code` STRING COMMENT 'The three-letter ISO 4217 currency code for the securitys trading currency.. Valid values are `^[A-Z]{3}$`',
    `market_value_base` DECIMAL(28,2) COMMENT 'The current market value of the holding in base currency, calculated as quantity multiplied by market price.',
    `market_value_local` DECIMAL(28,2) COMMENT 'The current market value of the holding in the local trading currency.',
    `portfolio_weight` DECIMAL(10,6) COMMENT 'The actual weight of this holding in the portfolio, calculated as market value divided by total portfolio NAV.',
    `position_date` DATE COMMENT 'The business date as of which this holding position is recorded in the IBOR.',
    `quantity` DECIMAL(28,8) COMMENT 'The number of units, shares, or notional amount of the security held in this position.',
    `rebalancing_flag` BOOLEAN COMMENT 'Indicates whether the holding is currently flagged for rebalancing to align with strategic or tactical asset allocation targets.',
    `restricted_flag` BOOLEAN COMMENT 'Indicates whether the holding is subject to trading restrictions (e.g., lock-up period, regulatory restriction, insider trading blackout).',
    `restriction_end_date` DATE COMMENT 'The date on which trading restrictions on the holding are lifted, if applicable.',
    `settlement_date` DATE COMMENT 'The date on which the most recent transaction affecting this holding was settled (T+2 or other convention).',
    `sub_asset_class` STRING COMMENT 'The secondary or granular asset class classification for tactical asset allocation (TAA) and detailed reporting.',
    `tax_lot_method` STRING COMMENT 'The method used to track cost basis for tax reporting and realized gain/loss calculation.. Valid values are `fifo|lifo|average_cost|specific_identification`',
    `trade_date` DATE COMMENT 'The date on which the most recent transaction affecting this holding was executed.',
    `unfunded_commitment` DECIMAL(28,2) COMMENT 'The remaining uncalled committed capital for private market investments, representing future capital call exposure.',
    `unit_cost_base` DECIMAL(28,8) COMMENT 'The average cost per unit of the security in base currency, used for cost basis and performance attribution.',
    `unit_cost_local` DECIMAL(28,8) COMMENT 'The average cost per unit of the security in the local trading currency.',
    `unrealized_gain_loss_base` DECIMAL(28,2) COMMENT 'The difference between market value and cost in base currency, representing unrealized profit or loss on the position.',
    `unrealized_gain_loss_local` DECIMAL(28,2) COMMENT 'The difference between market value and cost in local currency.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this holding record was last modified in the IBOR system.',
    `valuation_level` STRING COMMENT 'The IFRS 13 fair value hierarchy level (Level 1: quoted prices, Level 2: observable inputs, Level 3: unobservable inputs).. Valid values are `level_1|level_2|level_3`',
    `valuation_source` STRING COMMENT 'The source or method used to determine the market value of the holding, critical for illiquid private assets.. Valid values are `market_price|broker_quote|model_valuation|administrator_nav|appraisal`',
    `vintage_year` BIGINT COMMENT 'For private equity and private market funds, the year in which the fund held its initial closing and began investing.',
    CONSTRAINT pk_holding PRIMARY KEY(`holding_id`)
) COMMENT 'IBOR (Investment Book of Record) position record representing the authoritative current holding of a security or asset within a portfolio as of a given date.';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`holding_snapshot` (
    `holding_snapshot_id` BIGINT COMMENT 'Unique identifier for the holding snapshot record. Primary key.',
    `custodian_id` BIGINT COMMENT 'Reference to the custodian bank or institution holding the security on behalf of the portfolio.',
    `infra_asset_id` BIGINT COMMENT 'Foreign key linking to infrastructure.infra_asset. Business justification: Point-in-time infrastructure holding snapshots needed for GIPS-compliant performance reporting, historical NAV reconciliation, and regulatory filings requiring asset-level position',
    `listed_security_id` BIGINT COMMENT 'Reference to the security or investment instrument held in the portfolio.',
    `market_price_snapshot_id` BIGINT COMMENT 'Foreign key linking to valuation.market_price_snapshot. Business justification: Daily mark-to-market process requires linking holding snapshots to market prices.',
    `portfolio_benchmark_id` BIGINT COMMENT 'Reference to the benchmark index against which this holdings performance is measured.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio to which this holding belongs.',
    `account_number` STRING COMMENT 'The custodian account number where the security is held.',
    `accrued_income_base_currency` DECIMAL(28,2) COMMENT 'The accrued interest, dividends, or other income earned but not yet received on the holding, in base currency.',
    `asset_class` STRING COMMENT 'The primary asset class classification of the holding: public equity, private equity, real estate, infrastructure, natural resources, or credit.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `base_currency_code` STRING COMMENT 'The three-letter ISO 4217 currency code representing the portfolios base currency for valuation.. Valid values are `^[A-Z]{3}$`',
    `carbon_intensity` DECIMAL(18,4) COMMENT 'The greenhouse gas emissions intensity of the security or issuer, typically measured in tonnes of CO2 equivalent per million dollars of revenue.',
    `commitment_amount_base_currency` DECIMAL(28,2) COMMENT 'The total capital commitment made to the investment, applicable to private equity, infrastructure, and other capital call structures, in base currency.',
    `country_of_risk` STRING COMMENT 'The three-letter ISO 3166-1 alpha-3 country code representing the primary country exposure or risk of the security.. Valid values are `^[A-Z]{3}$`',
    `coupon_rate` DECIMAL(8,4) COMMENT 'The annual interest rate paid on a fixed income security, expressed as a percentage. Null for non-interest-bearing securities.',
    `credit_rating` STRING COMMENT 'The credit quality rating assigned to the security by a recognized rating agency such as Moodys, S&P, or Fitch.',
    `cusip` STRING COMMENT 'The nine-character alphanumeric code identifying North American securities.. Valid values are `^[0-9A-Z]{9}$`',
    `duration_years` DECIMAL(8,4) COMMENT 'The weighted average time to receive the cash flows from the security, measuring interest rate sensitivity. Applicable to fixed income holdings.',
    `esg_rating` STRING COMMENT 'The ESG rating or score assigned to the security by an external provider such as MSCI, Sustainalytics, or internal assessment.',
    `fair_value_level` STRING COMMENT 'The IFRS 13 fair value hierarchy level: Level 1 for quoted prices in active markets, Level 2 for observable inputs, Level 3 for unobservable inputs.. Valid values are `level_1|level_2|level_3`',
    `fx_rate` DECIMAL(18,8) COMMENT 'The exchange rate used to convert the security currency to the portfolio base currency at the snapshot date.',
    `holding_status` STRING COMMENT 'Current lifecycle status of the holding position.. Valid values are `active|closed|pending_settlement|suspended|matured|called`',
    `investment_strategy` STRING COMMENT 'The investment strategy or mandate under which this holding was acquired, such as growth, value, core, opportunistic, or distressed.',
    `isin` STRING COMMENT 'The 12-character alphanumeric code that uniquely identifies the security internationally.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `issuer_lei` STRING COMMENT 'The 20-character ISO 17442 Legal Entity Identifier of the security issuer.. Valid values are `^[A-Z0-9]{20}$`',
    `issuer_name` STRING COMMENT 'The name of the entity that issued the security.',
    `liquidity_classification` STRING COMMENT 'The liquidity profile of the holding: liquid for publicly traded securities, semi-liquid for restricted or thinly traded assets, illiquid for private investments.. Valid values are `liquid|semi_liquid|illiquid`',
    `market_price` DECIMAL(28,8) COMMENT 'The market price per unit of the security at the snapshot date, in the securitys trading currency.',
    `market_value_base_currency` DECIMAL(28,2) COMMENT 'The total market value of the holding position in the portfolio base currency at the snapshot date.',
    `maturity_date` DATE COMMENT 'The date on which the principal amount of a fixed income security becomes due and payable. Null for equities and perpetual instruments.',
    `quantity` DECIMAL(28,8) COMMENT 'The number of units, shares, or nominal amount of the security held at the snapshot date.',
    `record_created_timestamp` TIMESTAMP COMMENT 'The timestamp when this holding snapshot record was first created in the Investment Book of Record (IBOR) system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this holding snapshot record was last modified in the Investment Book of Record (IBOR) system.',
    `sector_code` STRING COMMENT 'The industry sector classification code of the security, typically following GICS, ICB, or internal taxonomy.',
    `security_currency_code` STRING COMMENT 'The three-letter ISO 4217 currency code in which the security is denominated and traded.. Valid values are `^[A-Z]{3}$`',
    `security_name` STRING COMMENT 'The full legal or common name of the security held in the portfolio.',
    `sedol` STRING COMMENT 'The seven-character identification code assigned to securities trading on the London Stock Exchange and other UK markets.. Valid values are `^[0-9A-Z]{7}$`',
    `snapshot_date` DATE COMMENT 'The business date for which this holding snapshot was captured, typically end-of-day or month-end.',
    `snapshot_timestamp` TIMESTAMP COMMENT 'The precise timestamp when the holding snapshot was captured in the source system.',
    `ticker_symbol` STRING COMMENT 'The abbreviated trading symbol used to uniquely identify publicly traded securities on an exchange.',
    `total_cost_base_currency` DECIMAL(28,2) COMMENT 'The total acquisition cost of the holding position in the portfolio base currency.',
    `unfunded_commitment_base_currency` DECIMAL(28,2) COMMENT 'The remaining uncalled capital commitment available for future capital calls, in base currency. Also known as dry powder.',
    `unit_cost_base_currency` DECIMAL(28,8) COMMENT 'The average cost per unit of the holding expressed in the portfolio base currency.',
    `unrealized_gain_loss_base_currency` DECIMAL(28,2) COMMENT 'The unrealized profit or loss on the holding position, calculated as market value minus total cost in base currency.',
    `valuation_source` STRING COMMENT 'The source or method used to determine the market value of the holding: market price, broker quote, internal model, third-party appraisal, or Net Asset Value (NAV).. Valid values are `market_price|broker_quote|model|appraisal|nav`',
    `vintage_year` BIGINT COMMENT 'The year in which the first capital commitment was made to a private equity, infrastructure, or real estate fund.',
    `weight_percent` DECIMAL(8,4) COMMENT 'The percentage weight of this holding within the total portfolio market value at the snapshot date.',
    `ytm` DECIMAL(8,4) COMMENT 'The total return anticipated on a bond if held until maturity, expressed as an annual percentage rate.',
    CONSTRAINT pk_holding_snapshot PRIMARY KEY(`holding_snapshot_id`)
) COMMENT 'Point-in-time snapshot of portfolio holdings captured at end-of-day or month-end for historical analysis, regulatory reporting, and performance attribution.';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`portfolio_benchmark` (
    `portfolio_benchmark_id` BIGINT COMMENT 'Unique identifier for the portfolio benchmark assignment record.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio to which this benchmark is assigned.',
    `superseded_by_benchmark_portfolio_benchmark_id` BIGINT COMMENT 'Reference to the portfolio benchmark assignment that replaced this one, if superseded; null if still active or not replaced.',
    `assignment_effective_date` DATE COMMENT 'Date from which this benchmark assignment becomes effective for performance measurement and reporting.',
    `assignment_end_date` DATE COMMENT 'Date on which this benchmark assignment ceases to be effective; null for open-ended assignments.',
    `assignment_reason` STRING COMMENT 'Business rationale or justification for assigning this benchmark to the portfolio (e.g., strategic asset allocation change, mandate requirement, regulatory compliance).',
    `assignment_status` STRING COMMENT 'Current lifecycle status of the benchmark assignment to the portfolio.. Valid values are `active|inactive|pending|superseded`',
    `benchmark_category` STRING COMMENT 'High-level asset class category that the benchmark represents. [ENUM-REF-CANDIDATE: equity|fixed_income|real_estate|infrastructure|private_equity|multi_asset|alternative — 7 candidates stripped; promote to reference product]',
    `benchmark_code` STRING COMMENT 'Unique alphanumeric code identifying the benchmark (e.g., MSCI_WORLD, FTSE_ALL_WORLD, CUSTOM_BLEND_01).. Valid values are `^[A-Z0-9_]{3,20}$`',
    `benchmark_description` STRING COMMENT 'Detailed textual description of the benchmark methodology, composition, and investment universe.',
    `benchmark_name` STRING COMMENT 'Full descriptive name of the benchmark (e.g., MSCI World Index, Bloomberg Barclays Global Aggregate Bond Index).',
    `benchmark_type` STRING COMMENT 'Classification of the benchmark: market index (published third-party), custom blend (internally constructed), liability benchmark (actuarial liability proxy), peer group (universe comparison), or absolute return (fixed target).. Valid values are `market_index|custom_blend|liability_benchmark|peer_group|absolute_return`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this portfolio benchmark assignment record was first created in the system.',
    `currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the benchmark is denominated (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `custom_blend_definition` STRING COMMENT 'Detailed specification of component benchmarks and weights for custom blended benchmarks; null for standard market indices.',
    `data_source` STRING COMMENT 'System or vendor from which benchmark return and composition data is sourced (e.g., Bloomberg, MSCI, FactSet, SimCorp, Internal).',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether the benchmark incorporates Environmental, Social, and Governance (ESG) criteria or screens.',
    `geography` STRING COMMENT 'Geographic scope or regional focus of the benchmark. [ENUM-REF-CANDIDATE: global|developed_markets|emerging_markets|north_america|europe|asia_pacific|usa|other — 9 candidates stripped; promote to reference product]',
    `ic_approval_date` DATE COMMENT 'Date on which the Investment Committee approved this benchmark assignment or change.',
    `ic_approval_reference` STRING COMMENT 'Reference number or identifier of the Investment Committee decision or meeting minutes approving this benchmark assignment.',
    `identifier` STRING COMMENT 'External standard identifier for the benchmark such as Bloomberg Ticker, ISIN, or SEDOL where applicable.',
    `inception_date` DATE COMMENT 'Date on which the benchmark was first published or calculated by the provider.',
    `is_primary_benchmark` BOOLEAN COMMENT 'Indicates whether this is the primary benchmark for the portfolio; true if primary, false if secondary or supplemental.',
    `last_modified_by` STRING COMMENT 'User identifier or name of the person who last modified this portfolio benchmark assignment record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this portfolio benchmark assignment record was last updated.',
    `liability_matching_flag` BOOLEAN COMMENT 'Indicates whether this benchmark is designed to match actuarial liability cash flows for Liability-Driven Investment (LDI) purposes.',
    `performance_fee_benchmark_flag` BOOLEAN COMMENT 'Indicates whether this benchmark is used as the hurdle rate for calculating performance-based fees or carried interest.',
    `provider` STRING COMMENT 'Name of the organization that publishes or maintains the benchmark (e.g., MSCI, FTSE Russell, Bloomberg, S&P Dow Jones, Internal).',
    `rebalancing_frequency` STRING COMMENT 'Frequency at which the benchmark composition is rebalanced by the provider or internally. [ENUM-REF-CANDIDATE: daily|monthly|quarterly|semi_annual|annual|event_driven|none — 7 candidates stripped; promote to reference product]',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this benchmark assignment is required for regulatory or statutory reporting purposes.',
    `return_calculation_method` STRING COMMENT 'Methodology used to calculate benchmark returns (e.g., Time-Weighted Return, Money-Weighted Return, Total Return including dividends, Price Return only).. Valid values are `time_weighted|money_weighted|total_return|price_return`',
    `tracking_error_target_bps` BIGINT COMMENT 'Target tracking error in basis points that the portfolio is expected to maintain relative to this benchmark.',
    `version` STRING COMMENT 'Version identifier for the benchmark methodology or composition, used to track changes over time.',
    `volatility_percent` DECIMAL(5,2) COMMENT 'Annualized standard deviation of benchmark returns, expressed as a percentage, representing historical volatility.',
    `weight_percent` DECIMAL(5,2) COMMENT 'Percentage weight of this benchmark in a blended benchmark scenario; 100.00 for single benchmark assignments.',
    `created_by` STRING COMMENT 'User identifier or name of the person who created this portfolio benchmark assignment record.',
    CONSTRAINT pk_portfolio_benchmark PRIMARY KEY(`portfolio_benchmark_id`)
) COMMENT 'Authoritative benchmark registry AND portfolio-benchmark assignment record. Masters each investment benchmark assigned to portfolios—market indices (MSCI World, FTSE All-World, Bloomberg Aggregate), custom blended benchmarks, and liability benchmarks for';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`benchmark_assignment` (
    `benchmark_assignment_id` BIGINT COMMENT 'Unique identifier for the benchmark assignment record. Primary key for this entity.',
    `portfolio_benchmark_id` BIGINT COMMENT 'Reference to the benchmark being assigned to the portfolio.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio to which this benchmark is assigned.',
    `superseded_by_assignment_benchmark_assignment_id` BIGINT COMMENT 'Reference to the benchmark assignment record that replaces this one, used to maintain assignment lineage when benchmarks are changed.',
    `approval_date` DATE COMMENT 'Date on which the benchmark assignment was formally approved by the Investment Committee or authorized governance body.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee that approved this benchmark assignment.',
    `assignment_notes` STRING COMMENT 'Free-text field for additional context, special instructions, or documentation related to this benchmark assignment.',
    `assignment_reason` STRING COMMENT 'Business rationale for assigning this benchmark to the portfolio, such as strategic asset allocation alignment, liability matching, or regulatory requirement.',
    `assignment_source` STRING COMMENT 'Origin or authority that determined this benchmark assignment, indicating who or what process established the relationship.. Valid values are `investment_committee|portfolio_manager|risk_team|compliance|client_mandate|system_default`',
    `assignment_status` STRING COMMENT 'Current lifecycle status of the benchmark assignment indicating whether it is currently in effect.. Valid values are `active|inactive|pending|suspended|terminated`',
    `assignment_type` STRING COMMENT 'Classification of the benchmark assignment role: primary (main performance benchmark), secondary (alternative comparison), risk (risk measurement), liability (ALM matching), composite (blended), or custom (special purpose).. Valid values are `primary|secondary|risk|liability|composite|custom`',
    `assignment_weight` DECIMAL(10,6) COMMENT 'Weighting factor for this benchmark in blended benchmark calculations, expressed as a decimal (e.g., 0.60 for 60%). Sum of weights across all active assignments for a portfolio should equal 1.0.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this benchmark assignment record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which benchmark returns are calculated and reported for this assignment.. Valid values are `^[A-Z]{3}$`',
    `currency_hedging_flag` BOOLEAN COMMENT 'Indicates whether the benchmark returns for this assignment reflect currency hedging adjustments to match portfolio hedging strategy.',
    `custom_benchmark_flag` BOOLEAN COMMENT 'Indicates whether this is a custom-constructed benchmark specific to this portfolio rather than a standard market index.',
    `effective_from_date` DATE COMMENT 'Date from which this benchmark assignment becomes effective for performance measurement and reporting.',
    `effective_to_date` DATE COMMENT 'Date on which this benchmark assignment ceases to be effective. Null indicates an open-ended assignment.',
    `last_review_date` DATE COMMENT 'Date of the most recent review of this benchmark assignment for continued appropriateness and alignment with portfolio objectives.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this benchmark assignment record.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review of this benchmark assignment.',
    `performance_attribution_flag` BOOLEAN COMMENT 'Indicates whether this benchmark assignment should be used for performance attribution analysis and decomposition of active returns.',
    `rebalancing_frequency` STRING COMMENT 'Frequency at which the benchmark composition or weighting is reviewed and potentially adjusted for this assignment.. Valid values are `daily|weekly|monthly|quarterly|annually|ad_hoc`',
    `reporting_flag` BOOLEAN COMMENT 'Indicates whether this benchmark assignment should be included in client and regulatory reporting packages.',
    `tracking_error_limit` DECIMAL(8,4) COMMENT 'Maximum allowable tracking error (standard deviation of return differences) between portfolio and benchmark, expressed in basis points. Used for risk monitoring and compliance.',
    `version_number` BIGINT COMMENT 'Version number of this benchmark assignment record, incremented with each modification to track assignment history.',
    CONSTRAINT pk_benchmark_assignment PRIMARY KEY(`benchmark_assignment_id`)
) COMMENT 'Association record linking a portfolio to its assigned benchmark(s) with effective date ranges, assignment type (primary, secondary, risk benchmark, liability benchmark), and weighting for blended benchmarks.';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`asset_class_weight` (
    `asset_class_weight_id` BIGINT COMMENT 'Unique identifier for the asset class weight record.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio for which this asset class weight is recorded.',
    `active_weight_percentage` DECIMAL(10,6) COMMENT 'The difference between portfolio actual weight and benchmark weight, expressed in percentage points, indicating active positioning versus benchmark.',
    `approval_status` STRING COMMENT 'The approval workflow status of this weight record, indicating whether it has been reviewed and approved by investment operations or portfolio management.. Valid values are `draft|pending_review|approved|rejected`',
    `approved_by` STRING COMMENT 'The name or identifier of the individual who approved this asset class weight record.',
    `approved_timestamp` TIMESTAMP COMMENT 'The date and time when this asset class weight record was approved.',
    `asset_class_code` STRING COMMENT 'Standardized code representing the asset class category (e.g., PE for Private Equity, RE for Real Estate, INFRA for Infrastructure).. Valid values are `^[A-Z]{2,10}$`',
    `asset_class_name` STRING COMMENT 'Full descriptive name of the asset class (e.g., Public Equity, Private Equity, Real Estate, Infrastructure, Natural Resources, Credit, Cash and Equivalents).',
    `base_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code representing the portfolio base currency in which market value and weights are denominated.. Valid values are `^[A-Z]{3}$`',
    `benchmark_weight_percentage` DECIMAL(10,6) COMMENT 'The weight of this asset class in the composite benchmark index used for performance comparison, expressed as a percentage.',
    `calculation_timestamp` TIMESTAMP COMMENT 'The precise date and time when this asset class weight was calculated by the portfolio management system.',
    `comments` STRING COMMENT 'Free-text field for portfolio managers or analysts to record notes, explanations, or context regarding this asset class weight or any deviations from policy.',
    `contribution_to_return` DECIMAL(10,6) COMMENT 'The contribution of this asset class to total portfolio return for the period, calculated as weight multiplied by asset class return, expressed as a percentage.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this asset class weight record was first created in the system.',
    `data_source` STRING COMMENT 'The system or platform from which this asset class weight data was sourced (e.g., SimCorp Dimension, BlackRock Aladdin, State Street).',
    `deviation_from_target` DECIMAL(10,6) COMMENT 'The difference between actual weight and target weight, expressed in percentage points (actual minus target), indicating over or under allocation.',
    `effective_weight_percentage` DECIMAL(10,6) COMMENT 'The effective allocation weight including unfunded commitments, calculated as (market value plus unfunded commitments) divided by (total portfolio value plus total unfunded commitments), expressed as a percentage.',
    `esg_weight_percentage` DECIMAL(10,6) COMMENT 'The percentage of this asset class that is invested in holdings meeting ESG criteria or responsible investment standards.',
    `is_active` BOOLEAN COMMENT 'Boolean flag indicating whether this is the current active weight record for the portfolio and asset class combination (True if current, False if historical).',
    `liquidity_classification` STRING COMMENT 'Classification of the asset class based on liquidity characteristics (liquid for public markets, illiquid for private markets, semi-liquid for hybrid).. Valid values are `liquid|semi_liquid|illiquid`',
    `market_value` DECIMAL(20,2) COMMENT 'The total market value of holdings in this asset class as of the valuation date, in the portfolio base currency.',
    `modified_by` STRING COMMENT 'The user identifier or system process that last modified this asset class weight record.',
    `modified_timestamp` TIMESTAMP COMMENT 'The date and time when this asset class weight record was last modified.',
    `number_of_holdings` BIGINT COMMENT 'The count of distinct investment positions within this asset class as of the valuation date.',
    `prior_period_weight_percentage` DECIMAL(10,6) COMMENT 'The asset class weight percentage from the previous valuation period, used for period-over-period comparison and drift analysis.',
    `rebalancing_required_flag` BOOLEAN COMMENT 'Boolean indicator whether the current weight deviation exceeds policy thresholds and requires rebalancing action (True if rebalancing needed, False otherwise).',
    `rebalancing_threshold_lower` DECIMAL(10,6) COMMENT 'The lower bound threshold percentage below which the asset class weight triggers a rebalancing action per portfolio policy.',
    `rebalancing_threshold_upper` DECIMAL(10,6) COMMENT 'The upper bound threshold percentage above which the asset class weight triggers a rebalancing action per portfolio policy.',
    `reporting_period` STRING COMMENT 'The reporting period to which this weight record belongs, formatted as YYYY-QN for quarterly, YYYY-MNN for monthly, or YYYY-YYYY for annual.. Valid values are `^[0-9]{4}-(Q[1-4]|M(0[1-9]|1[0-2])|[0-9]{4})$`',
    `tactical_weight_percentage` DECIMAL(10,6) COMMENT 'The tactical asset allocation (TAA) target weight for this asset class reflecting short-term market views and adjustments, expressed as a percentage.',
    `target_weight_percentage` DECIMAL(10,6) COMMENT 'The strategic asset allocation (SAA) target weight for this asset class as defined by the investment policy, expressed as a percentage.',
    `unfunded_commitment_amount` DECIMAL(20,2) COMMENT 'The total uncalled committed capital (dry powder) for this asset class, applicable primarily to private markets investments, in base currency.',
    `valuation_date` DATE COMMENT 'The date on which this asset class weight was calculated and recorded.',
    `weight_calculation_method` STRING COMMENT 'The methodology used to calculate the asset class weight (market value, net asset value, fair value, or cost basis).. Valid values are `market_value|nav|fair_value|cost_basis`',
    `weight_change_percentage` DECIMAL(10,6) COMMENT 'The change in asset class weight from prior period to current period, expressed in percentage points, indicating allocation drift.',
    `weight_percentage` DECIMAL(10,6) COMMENT 'The actual allocation weight of this asset class within the portfolio, expressed as a percentage of total portfolio value (e.g., 25.500000 represents 25.5%).',
    `weight_status` STRING COMMENT 'Categorical status indicating whether the asset class weight is within policy range, overweight, underweight, or at target relative to strategic allocation.. Valid values are `within_range|overweight|underweight|at_target`',
    `created_by` STRING COMMENT 'The user identifier or system process that created this asset class weight record.',
    CONSTRAINT pk_asset_class_weight PRIMARY KEY(`asset_class_weight_id`)
) COMMENT 'Current actual asset class weight record for a portfolio as of a valuation date, capturing the realized allocation to each asset class (public equity, private equity, real estate, infrastructure, natural resources, credit, cash) expressed as a percentage';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`rebalancing_event` (
    `rebalancing_event_id` BIGINT COMMENT 'Unique identifier for the portfolio rebalancing event. Primary key.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio being rebalanced.',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether Investment Committee (IC) or senior management approval was required before executing this rebalancing event.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the rebalancing event received formal approval to proceed.',
    `approved_by` STRING COMMENT 'Name or identifier of the Investment Committee member or authorized approver who approved the rebalancing event.',
    `base_currency` STRING COMMENT 'Three-letter ISO 4217 currency code representing the portfolio base currency for NAV and allocation calculations.. Valid values are `^[A-Z]{3}$`',
    `carbon_footprint_post` DECIMAL(18,2) COMMENT 'Total carbon footprint of the portfolio after rebalancing, used to assess climate impact of the rebalancing decision.',
    `carbon_footprint_pre` DECIMAL(18,2) COMMENT 'Total carbon footprint of the portfolio before rebalancing, measured in tonnes of CO2 equivalent per million invested.',
    `cash_requirement` DECIMAL(18,2) COMMENT 'Minimum cash or liquid asset requirement that must be maintained post-rebalancing to meet near-term liability obligations, in base currency.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this rebalancing event record was first created in the system.',
    `drift_percentage` DECIMAL(10,4) COMMENT 'Percentage deviation from target allocation that triggered the rebalancing, measured in basis points or percentage points.',
    `drift_threshold_breached` BOOLEAN COMMENT 'Indicates whether the rebalancing was triggered by a breach of the Strategic Asset Allocation (SAA) or Tactical Asset Allocation (TAA) drift threshold.',
    `esg_impact_assessed` BOOLEAN COMMENT 'Indicates whether the rebalancing event included an assessment of Environmental, Social, and Governance (ESG) impact on the portfolio.',
    `esg_score_post` DECIMAL(5,2) COMMENT 'Aggregate ESG score of the portfolio after the rebalancing event, used to measure ESG improvement or degradation.',
    `esg_score_pre` DECIMAL(5,2) COMMENT 'Aggregate ESG score of the portfolio before the rebalancing event, typically on a 0-100 scale.',
    `estimated_market_impact` DECIMAL(18,2) COMMENT 'Estimated cost of market impact from executing large rebalancing trades, measured in base currency.',
    `estimated_tax_impact` DECIMAL(18,2) COMMENT 'Estimated tax liability or benefit resulting from the rebalancing trades, including capital gains taxes, in base currency.',
    `event_number` STRING COMMENT 'Business identifier for the rebalancing event, formatted as REB-YYYYMMDD-NNNNNN for external reference and audit trails.. Valid values are `^REB-[0-9]{8}-[0-9]{6}$`',
    `event_status` STRING COMMENT 'Current lifecycle status of the rebalancing event in the execution workflow.. Valid values are `proposed|approved|in_progress|completed|cancelled|failed`',
    `event_timestamp` TIMESTAMP COMMENT 'Date and time when the rebalancing event was initiated or triggered.',
    `execution_end_timestamp` TIMESTAMP COMMENT 'Date and time when all trades for the rebalancing event were completed and settled.',
    `execution_start_timestamp` TIMESTAMP COMMENT 'Date and time when trade execution for the rebalancing event commenced.',
    `execution_strategy` STRING COMMENT 'Trading execution strategy employed for the rebalancing trades to minimize market impact and transaction costs.. Valid values are `immediate|VWAP|TWAP|algorithmic|block_trade|dark_pool`',
    `liquidity_constraint_applied` BOOLEAN COMMENT 'Indicates whether liquidity constraints were applied during the rebalancing to ensure sufficient cash for liability payments.',
    `post_rebalancing_nav` DECIMAL(20,2) COMMENT 'Total Net Asset Value of the portfolio immediately after the rebalancing event, in base currency.',
    `post_trade_var` DECIMAL(18,2) COMMENT 'Portfolio Value at Risk (VaR) calculated after the rebalancing event, used to assess risk impact.',
    `pre_rebalancing_nav` DECIMAL(20,2) COMMENT 'Total Net Asset Value of the portfolio immediately before the rebalancing event, in base currency.',
    `pre_trade_var` DECIMAL(18,2) COMMENT 'Portfolio Value at Risk (VaR) calculated before the rebalancing event, used for risk comparison.',
    `rebalancing_frequency` STRING COMMENT 'Scheduled frequency of rebalancing for this portfolio as defined in the investment mandate.. Valid values are `monthly|quarterly|semi_annual|annual|ad_hoc`',
    `rebalancing_notes` STRING COMMENT 'Free-text field for portfolio managers to document additional context, rationale, or special considerations for this rebalancing event.',
    `risk_assessment_performed` BOOLEAN COMMENT 'Indicates whether a pre-trade risk assessment was conducted before executing the rebalancing event.',
    `scheduled_rebalancing_flag` BOOLEAN COMMENT 'Indicates whether this rebalancing event was part of a scheduled periodic rebalancing cycle (e.g., quarterly, annual).',
    `settlement_date` DATE COMMENT 'Date on which all rebalancing trades are expected to settle, typically T+2 for equities.',
    `system_source` STRING COMMENT 'Name of the source system that generated or recorded this rebalancing event (e.g., SimCorp Dimension, BlackRock Aladdin).',
    `target_allocation_type` STRING COMMENT 'Indicates whether the rebalancing targets Strategic Asset Allocation (SAA) or Tactical Asset Allocation (TAA) weights.. Valid values are `SAA|TAA`',
    `tax_optimization_applied` BOOLEAN COMMENT 'Indicates whether tax-loss harvesting or other tax optimization strategies were applied during the rebalancing event.',
    `total_trades_executed` BIGINT COMMENT 'Number of individual trade orders executed as part of this rebalancing event across all asset classes.',
    `total_transaction_cost` DECIMAL(18,2) COMMENT 'Aggregate transaction costs incurred during the rebalancing, including brokerage fees, commissions, and market impact costs, in base currency.',
    `tracking_error_post` DECIMAL(10,4) COMMENT 'Tracking error of the portfolio relative to its benchmark after the rebalancing event, expressed as a percentage.',
    `tracking_error_pre` DECIMAL(10,4) COMMENT 'Tracking error of the portfolio relative to its benchmark before the rebalancing event, expressed as a percentage.',
    `transaction_cost_bps` DECIMAL(8,2) COMMENT 'Total transaction cost expressed as basis points of the portfolio NAV, used for cost efficiency analysis.',
    `trigger_description` STRING COMMENT 'Detailed narrative explaining the specific reason or condition that triggered this rebalancing event.',
    `trigger_type` STRING COMMENT 'Classification of the event that triggered the rebalancing action.. Valid values are `drift_breach|scheduled_periodic|tactical_decision|mandate_change|liquidity_requirement|risk_limit_breach`',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this rebalancing event record was last modified in the system.',
    CONSTRAINT pk_rebalancing_event PRIMARY KEY(`rebalancing_event_id`)
) COMMENT 'Transactional record capturing each portfolio rebalancing event triggered by drift from SAA/TAA targets or scheduled periodic rebalancing. Records trigger type (drift breach, scheduled, tactical decision, mandate change), target weights before and after';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`constraint` (
    `constraint_id` BIGINT COMMENT 'Unique identifier for the investment constraint record.',
    `portfolio_benchmark_id` BIGINT COMMENT 'Reference to the benchmark used for relative constraint calculations.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio to which this constraint applies.',
    `portfolio_mandate_id` BIGINT COMMENT 'Reference to the investment mandate governing this constraint.',
    `approval_date` DATE COMMENT 'Date on which the constraint was formally approved.',
    `approval_status` STRING COMMENT 'Governance approval state of the constraint before it becomes enforceable.. Valid values are `draft|pending_approval|approved|rejected`',
    `approved_by` STRING COMMENT 'Name or identifier of the authority who approved this constraint.',
    `asset_class` STRING COMMENT 'Asset class to which this constraint applies when scope is asset-class-specific. [ENUM-REF-CANDIDATE: public_equity|private_equity|real_estate|infrastructure|natural_resources|credit|fixed_income|cash — promote to reference product]',
    `breach_count` BIGINT COMMENT 'Cumulative number of times this constraint has been breached since inception.',
    `breach_severity` STRING COMMENT 'Classification of the impact level when this constraint is violated.. Valid values are `critical|high|medium|low|informational`',
    `calculation_method` STRING COMMENT 'Technical specification of how the constraint metric is computed from portfolio positions.',
    `constraint_category` STRING COMMENT 'Classification of the constraint source indicating whether it originates from regulation, mandate terms, internal policy, or risk framework.. Valid values are `regulatory|mandate|policy|risk|operational|esg`',
    `constraint_code` STRING COMMENT 'Business identifier code for the constraint rule, used for reference in compliance monitoring systems.',
    `constraint_status` STRING COMMENT 'Current lifecycle state of the constraint rule.. Valid values are `active|inactive|suspended|pending|expired`',
    `constraint_type` STRING COMMENT 'Category of investment constraint defining the nature of the restriction. [ENUM-REF-CANDIDATE: asset_allocation|concentration|liquidity|credit_quality|duration|leverage|exposure|sector|geography|esg — 10 candidates stripped; promote to reference product]',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this constraint record was first created in the system.',
    `credit_rating_minimum` STRING COMMENT 'Minimum acceptable credit rating for fixed income investments subject to this constraint.',
    `effective_date` DATE COMMENT 'Date from which this constraint becomes active and enforceable.',
    `esg_score_minimum` DECIMAL(5,2) COMMENT 'Minimum ESG score required for investments under this constraint.',
    `expiry_date` DATE COMMENT 'Date on which this constraint ceases to be active, nullable for perpetual constraints.',
    `geography_code` STRING COMMENT 'ISO 3166-1 alpha-3 country or region code when constraint is geography-specific.. Valid values are `^[A-Z]{3}$`',
    `last_breach_date` DATE COMMENT 'Most recent date on which this constraint was breached.',
    `mandate_clause_reference` STRING COMMENT 'Reference to the specific clause in the investment mandate document that defines this constraint.',
    `maximum_value` DECIMAL(18,6) COMMENT 'Upper bound of the constraint range when threshold type is range-based.',
    `minimum_value` DECIMAL(18,6) COMMENT 'Lower bound of the constraint range when threshold type is range-based.',
    `modified_by` STRING COMMENT 'User or system identifier that last modified this constraint record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this constraint record was last modified.',
    `monitoring_frequency` STRING COMMENT 'Cadence at which compliance with this constraint is evaluated.. Valid values are `real_time|intraday|daily|weekly|monthly|quarterly`',
    `constraint_name` STRING COMMENT 'Human-readable name describing the constraint rule.',
    `notes` STRING COMMENT 'Free-text field for additional context, exceptions, or special instructions related to this constraint.',
    `notification_recipients` STRING COMMENT 'Comma-separated list of roles or individuals to be notified upon breach.',
    `notification_required` BOOLEAN COMMENT 'Indicates whether stakeholders must be notified when this constraint is breached.',
    `override_allowed` BOOLEAN COMMENT 'Indicates whether this constraint can be temporarily overridden with appropriate authorization.',
    `override_authority_level` STRING COMMENT 'Minimum authority level required to approve an override of this constraint. [ENUM-REF-CANDIDATE: portfolio_manager|chief_investment_officer|investment_committee|board|none — promote to reference product]',
    `regulatory_reference` STRING COMMENT 'Citation of the regulatory rule or guideline that mandates this constraint.',
    `remediation_period_days` BIGINT COMMENT 'Number of business days allowed to remediate a breach before escalation.',
    `rule_description` STRING COMMENT 'Detailed textual description of the constraint rule and its business rationale.',
    `scope` STRING COMMENT 'Level at which the constraint is applied within the portfolio hierarchy. [ENUM-REF-CANDIDATE: portfolio|asset_class|sector|issuer|security|counterparty|geography — 7 candidates stripped; promote to reference product]',
    `sector_code` STRING COMMENT 'Industry sector code when constraint is sector-specific.',
    `threshold_currency` STRING COMMENT 'ISO 4217 three-letter currency code when threshold is expressed in monetary terms.. Valid values are `^[A-Z]{3}$`',
    `threshold_type` STRING COMMENT 'Type of threshold defining whether the constraint sets a floor, ceiling, or bounded range.. Valid values are `minimum|maximum|range|absolute|relative`',
    `threshold_unit` STRING COMMENT 'Unit of measure for the threshold value indicating whether it is expressed as percentage, basis points, currency amount, count, or ratio.. Valid values are `percentage|bps|currency|count|ratio`',
    `threshold_value` DECIMAL(18,6) COMMENT 'Numeric value representing the constraint limit or target.',
    `tolerance_percentage` DECIMAL(5,2) COMMENT 'Allowable deviation from the threshold before a breach is triggered, expressed as percentage.',
    `created_by` STRING COMMENT 'User or system identifier that created this constraint record.',
    CONSTRAINT pk_constraint PRIMARY KEY(`constraint_id`)
) COMMENT 'Business rule record defining investment constraints and guidelines applicable to a portfolio or mandate, as monitored in BlackRock Aladdin compliance engine.';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`constraint_breach` (
    `constraint_breach_id` BIGINT COMMENT 'Unique identifier for the constraint breach record. Primary key.',
    `constraint_id` BIGINT COMMENT 'Reference to the specific constraint rule or guideline that was breached.',
    `constraint_rule_id` BIGINT COMMENT 'Reference to the specific constraint rule or guideline that was breached.',
    `holding_id` BIGINT COMMENT 'Reference to the specific position that triggered the breach, if applicable.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio in which the breach occurred.',
    `portfolio_mandate_id` BIGINT COMMENT 'Reference to the investment mandate or guideline framework under which the breach was detected.',
    `position_holding_id` BIGINT COMMENT 'Reference to the specific position that triggered the breach, if applicable.',
    `acknowledged_by` STRING COMMENT 'Name or identifier of the individual who acknowledged the breach.',
    `acknowledged_timestamp` TIMESTAMP COMMENT 'Date and time when the breach was formally acknowledged by compliance or portfolio management.',
    `actual_value` DECIMAL(18,6) COMMENT 'The actual measured value at the time of breach detection.',
    `asset_class` STRING COMMENT 'The asset class associated with the breach, such as public equities, private equity, real estate, infrastructure, natural resources, or credit.',
    `breach_amount` DECIMAL(18,6) COMMENT 'The magnitude of the breach, calculated as the difference between actual value and threshold value.',
    `breach_detected_timestamp` TIMESTAMP COMMENT 'Date and time when the compliance monitoring system first detected the breach.',
    `breach_notes` STRING COMMENT 'Free-text field for additional context, commentary, or analysis related to the breach.',
    `breach_occurrence_timestamp` TIMESTAMP COMMENT 'Date and time when the breach actually occurred in the portfolio, which may differ from detection time.',
    `breach_percentage` DECIMAL(10,4) COMMENT 'The breach amount expressed as a percentage of the threshold, indicating relative severity.',
    `breach_reference_number` STRING COMMENT 'Externally-known unique reference number assigned to this breach for tracking and reporting purposes.',
    `breach_status` STRING COMMENT 'Current lifecycle status of the breach in the compliance workflow.. Valid values are `detected|acknowledged|under_review|remediated|waived|escalated`',
    `breach_type` STRING COMMENT 'Classification of when the breach was detected in the trade lifecycle.. Valid values are `pre_trade|post_trade|intraday|end_of_day`',
    `constraint_category` STRING COMMENT 'High-level category of the investment constraint that was breached. [ENUM-REF-CANDIDATE: asset_allocation|concentration|liquidity|credit_quality|duration|leverage|esg|sector|geography|currency — 10 candidates stripped; promote to reference product]',
    `constraint_description` STRING COMMENT 'Detailed description of the constraint rule, including its purpose and parameters.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this breach record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for monetary breach amounts, if applicable.. Valid values are `^[A-Z]{3}$`',
    `detected_by_system` STRING COMMENT 'Name of the compliance monitoring system that detected the breach, such as BlackRock Aladdin or Charles River IMS.',
    `detection_method` STRING COMMENT 'Method by which the breach was detected, indicating whether it was automated or manual.. Valid values are `automated|manual|scheduled_batch|real_time`',
    `escalated_to_ic` BOOLEAN COMMENT 'Indicates whether the breach was escalated to the Investment Committee for review and decision.',
    `escalation_timestamp` TIMESTAMP COMMENT 'Date and time when the breach was escalated to higher authority or the Investment Committee.',
    `geography` STRING COMMENT 'Three-letter ISO country code representing the geographic exposure associated with the breach.. Valid values are `^[A-Z]{3}$`',
    `issuer_name` STRING COMMENT 'Name of the issuer or counterparty associated with the breached position.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Date and time when this breach record was last modified.',
    `regulator_report_date` DATE COMMENT 'Date on which the breach was reported to the regulatory authority.',
    `regulatory_reportable` BOOLEAN COMMENT 'Indicates whether this breach must be reported to regulatory authorities such as SEC, or FCA.',
    `remediated_timestamp` TIMESTAMP COMMENT 'Date and time when the breach was successfully remediated and the portfolio returned to compliance.',
    `remediation_action` STRING COMMENT 'Description of the corrective action taken or planned to remediate the breach.',
    `remediation_deadline` DATE COMMENT 'Target date by which the breach must be remediated according to policy or regulatory requirements.',
    `reported_to_regulator` BOOLEAN COMMENT 'Indicates whether the breach has been formally reported to the applicable regulatory body.',
    `sector` STRING COMMENT 'Industry sector classification of the security or investment involved in the breach.',
    `security_identifier` STRING COMMENT 'Unique identifier of the security involved in the breach, such as ISIN, CUSIP, or SEDOL.',
    `security_name` STRING COMMENT 'Human-readable name of the security or investment involved in the breach.',
    `severity_level` STRING COMMENT 'Assessed severity or materiality of the breach for risk management and escalation purposes.. Valid values are `critical|high|medium|low|informational`',
    `threshold_value` DECIMAL(18,6) COMMENT 'The maximum or minimum limit defined by the constraint rule.',
    `unit_of_measure` STRING COMMENT 'The unit in which threshold and actual values are expressed. [ENUM-REF-CANDIDATE: percent|bps|currency|shares|units|days|years|ratio — 8 candidates stripped; promote to reference product]',
    `waiver_approved_by` STRING COMMENT 'Name or identifier of the authority who approved the waiver.',
    `waiver_expiry_date` DATE COMMENT 'Date on which the granted waiver expires and the constraint becomes enforceable again.',
    `waiver_granted` BOOLEAN COMMENT 'Indicates whether a formal waiver or exception was granted for this breach by the Investment Committee or compliance authority.',
    `waiver_reason` STRING COMMENT 'Business justification or rationale for granting a waiver, if applicable.',
    CONSTRAINT pk_constraint_breach PRIMARY KEY(`constraint_breach_id`)
) COMMENT 'Transactional record of each investment guideline or mandate constraint breach detected during pre-trade or post-trade compliance monitoring in BlackRock Aladdin or Charles River IMS.';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`gips_composite` (
    `gips_composite_id` BIGINT COMMENT 'Unique identifier for the GIPS composite record.',
    `asset_class` STRING COMMENT 'Primary asset class or investment category that defines the composite strategy (e.g., public equities, private equity, real estate, infrastructure, credit).',
    `base_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code representing the base currency for composite performance reporting and valuation.. Valid values are `^[A-Z]{3}$`',
    `benchmark_code` STRING COMMENT 'Standard identifier or ticker symbol for the benchmark index (e.g., Bloomberg ticker, ISIN).',
    `benchmark_name` STRING COMMENT 'Name of the primary benchmark index used for performance comparison and attribution analysis.',
    `composite_aum` DECIMAL(20,2) COMMENT 'Total market value of all assets under management within the composite as of the most recent valuation date, expressed in base currency.',
    `composite_code` STRING COMMENT 'Internal unique code or identifier assigned to the composite for system reference and reporting.',
    `composite_creation_method` STRING COMMENT 'Method used to aggregate individual portfolio returns into the composite return (asset-weighted or equal-weighted).. Valid values are `asset_weighted|equal_weighted`',
    `composite_definition` STRING COMMENT 'Formal definition and inclusion criteria that determine which portfolios are eligible for inclusion in the composite.',
    `composite_description` STRING COMMENT 'Detailed description of the composite investment strategy, mandate, and portfolio characteristics.',
    `composite_dispersion_measure` STRING COMMENT 'Statistical measure used to assess the variability of individual portfolio returns within the composite (e.g., standard deviation, range).. Valid values are `standard_deviation|range|interquartile_range`',
    `composite_manager_name` STRING COMMENT 'Name of the investment manager or team responsible for managing portfolios within the composite.',
    `composite_name` STRING COMMENT 'Official name of the GIPS composite used for performance presentation and client reporting.',
    `composite_notes` STRING COMMENT 'Additional notes, disclosures, or commentary regarding the composite structure, performance, or special considerations.',
    `composite_status` STRING COMMENT 'Current lifecycle status of the composite indicating whether it is actively maintained for performance reporting.. Valid values are `active|inactive|closed|pending`',
    `composite_type` STRING COMMENT 'Classification of the composite based on portfolio management discretion and structure.. Valid values are `discretionary|non_discretionary|pooled|segregated`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the composite record was first created in the system.',
    `derivatives_usage_flag` BOOLEAN COMMENT 'Indicates whether portfolios within the composite are permitted to use derivative instruments for hedging or investment purposes.',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether ESG factors are systematically integrated into the investment decision-making process for portfolios within the composite.',
    `esg_strategy_description` STRING COMMENT 'Description of the ESG integration approach, screening criteria, and responsible investment practices applied to the composite.',
    `fee_schedule_description` STRING COMMENT 'Description of the fee structure and schedule applicable to portfolios within the composite, including management fees and performance fees.',
    `geographic_focus` STRING COMMENT 'Primary geographic region or market focus of the composite investment strategy (e.g., global, North America, emerging markets).',
    `gross_of_fees_flag` BOOLEAN COMMENT 'Indicates whether composite performance is presented gross of investment management fees (True) or net of fees (False).',
    `inception_date` DATE COMMENT 'Date when the composite was first created and began tracking performance.',
    `investment_strategy` STRING COMMENT 'Detailed investment strategy or mandate that defines the composite including geographic focus, sector focus, and investment approach.',
    `last_examination_date` DATE COMMENT 'Date of the most recent independent performance examination or verification, if applicable.',
    `last_updated_by` STRING COMMENT 'User identifier or name of the individual who most recently updated the composite record.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the composite record was most recently modified or updated.',
    `leverage_flag` BOOLEAN COMMENT 'Indicates whether portfolios within the composite are permitted to use leverage or borrowing to enhance returns.',
    `minimum_portfolio_size` DECIMAL(18,2) COMMENT 'Minimum asset value threshold required for a portfolio to be included in the composite, expressed in base currency.',
    `net_of_fees_flag` BOOLEAN COMMENT 'Indicates whether composite performance is presented net of investment management fees (True) or gross of fees (False).',
    `number_of_portfolios` BIGINT COMMENT 'Count of individual portfolios currently included in the composite.',
    `performance_examination_flag` BOOLEAN COMMENT 'Indicates whether the composite performance has been independently verified or examined by a third-party auditor in accordance with GIPS standards.',
    `reporting_frequency` STRING COMMENT 'Frequency at which composite performance is calculated and reported to stakeholders.. Valid values are `monthly|quarterly|annual`',
    `return_calculation_method` STRING COMMENT 'Method used to calculate composite returns: Time-Weighted Return (TWR), Money-Weighted Return (MWR), or Internal Rate of Return (IRR).. Valid values are `twr|mwr|irr`',
    `sector_focus` STRING COMMENT 'Primary industry sector or economic sector focus of the composite investment strategy, if applicable.',
    `termination_date` DATE COMMENT 'Date when the composite was closed or terminated, if applicable. Null for active composites.',
    `three_year_ex_post_standard_deviation` DECIMAL(8,4) COMMENT 'Annualized three-year ex-post standard deviation of composite returns, expressed as a percentage, used to measure historical volatility.',
    `valuation_methodology` STRING COMMENT 'Description of the valuation approach and methodology used for portfolio assets within the composite (e.g., fair value, mark-to-market, DCF for private assets).',
    `created_by` STRING COMMENT 'User identifier or name of the individual who created the composite record.',
    CONSTRAINT pk_gips_composite PRIMARY KEY(`gips_composite_id`)
) COMMENT 'GIPS (Global Investment Performance Standards) composite master record grouping portfolios with similar investment mandates for standardized performance presentation.';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` (
    `portfolio_composite_membership_id` BIGINT COMMENT 'Unique identifier for the portfolio composite membership association record.',
    `approved_by_user_employee_id` BIGINT COMMENT 'Identifier of the compliance officer or investment committee member who approved the composite membership assignment.',
    `composite_id` BIGINT COMMENT 'Identifier of the GIPS composite to which the portfolio is assigned.',
    `employee_id` BIGINT COMMENT 'Identifier of the compliance officer or investment committee member who approved the composite membership assignment.',
    `gips_compliance_record_id` BIGINT COMMENT 'Foreign key linking to compliance.gips_compliance_record. Business justification: Portfolio composite membership must reference the GIPS compliance record for the composite to enforce compliance reporting.',
    `gips_composite_id` BIGINT COMMENT 'Foreign key linking to portfolio.gips_composite. Business justification: portfolio_composite_membership tracks which portfolios belong to which GIPS composites.',
    `portfolio_id` BIGINT COMMENT 'Identifier of the individual portfolio included in the composite.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the composite membership assignment was formally approved.',
    `audit_trail_reference` STRING COMMENT 'Reference identifier linking to detailed audit trail records for this composite membership assignment.',
    `base_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the portfolios base currency during the membership period.. Valid values are `^[A-Z]{3}$`',
    `benchmark_assignment_override_flag` BOOLEAN COMMENT 'Indicates whether the portfolio uses a different benchmark than the composites primary benchmark.',
    `carve_out_cash_allocation_method` STRING COMMENT 'Method used to allocate cash to the carve-out portfolio if applicable.. Valid values are `actual|synthetic|proportional`',
    `carve_out_flag` BOOLEAN COMMENT 'Indicates whether the portfolio is a carve-out segment from a larger multi-strategy portfolio.',
    `compliance_notes` STRING COMMENT 'Free-text notes documenting compliance considerations, exceptions, or special circumstances related to the composite membership.',
    `composite_assignment_date` DATE COMMENT 'Date when the portfolio was formally assigned to the composite by the investment committee or compliance team.',
    `composite_definition_compliance_flag` BOOLEAN COMMENT 'Indicates whether the portfolio meets all criteria defined in the composites investment mandate and strategy.',
    `discretionary_flag` BOOLEAN COMMENT 'Indicates whether the portfolio was managed on a discretionary basis during the membership period.',
    `effective_end_date` DATE COMMENT 'Date when the portfolio was removed from the composite, null if currently active.',
    `effective_start_date` DATE COMMENT 'Date when the portfolio was first included in the composite.',
    `exclusion_reason_code` STRING COMMENT 'Standardized code indicating the reason for removing the portfolio from the composite, null if not excluded. [ENUM-REF-CANDIDATE: mandate_change|strategy_drift|closure|transfer|non_discretionary|regulatory|client_request — 7 candidates stripped; promote',
    `exclusion_reason_description` STRING COMMENT 'Detailed narrative explanation of why the portfolio was excluded from the composite.',
    `fee_paying_flag` BOOLEAN COMMENT 'Indicates whether the portfolio pays management fees during the membership period.',
    `inclusion_reason_code` STRING COMMENT 'Standardized code indicating the reason for including the portfolio in the composite.. Valid values are `initial|mandate_match|strategy_alignment|rebalance|discretionary|regulatory`',
    `inclusion_reason_description` STRING COMMENT 'Detailed narrative explanation of why the portfolio was included in the composite.',
    `last_review_date` DATE COMMENT 'Date when the portfolios composite membership was last reviewed for continued compliance with composite criteria.',
    `market_value_at_exclusion` DECIMAL(20,2) COMMENT 'Total market value of the portfolio at the time of exclusion from the composite, in base currency, null if still active.',
    `market_value_at_inclusion` DECIMAL(20,2) COMMENT 'Total market value of the portfolio at the time of inclusion in the composite, in base currency.',
    `membership_status` STRING COMMENT 'Current status of the portfolios membership in the composite.. Valid values are `active|inactive|pending|excluded`',
    `minimum_asset_threshold_met_flag` BOOLEAN COMMENT 'Indicates whether the portfolio meets the minimum asset size requirement for composite inclusion.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review of the portfolios composite membership eligibility.',
    `performance_calculation_method` STRING COMMENT 'Method used to calculate the portfolios performance contribution to the composite.. Valid values are `twr|mwr|irr|modified_dietz`',
    `portfolio_inception_date` DATE COMMENT 'Date when the portfolio was first established, used to determine eligibility for composite inclusion.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Date and time when this composite membership record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Date and time when this composite membership record was last modified.',
    `significant_cash_flow_flag` BOOLEAN COMMENT 'Indicates whether the portfolio experienced significant cash flows during the membership period that may affect composite performance.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which the composite membership data originated.. Valid values are `simcorp|aladdin|factset|manual`',
    `temporary_exclusion_flag` BOOLEAN COMMENT 'Indicates whether the portfolio was temporarily excluded from the composite due to significant cash flows or other transient conditions.',
    `weight_in_composite_percent` DECIMAL(10,6) COMMENT 'Percentage weight of the portfolio within the composite based on market value, used for performance calculation.',
    CONSTRAINT pk_portfolio_composite_membership PRIMARY KEY(`portfolio_composite_membership_id`)
) COMMENT 'Association record tracking the inclusion of individual portfolios within GIPS composites over time, with effective start and end dates, inclusion reason, and exclusion reason (if applicable).';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` (
    `portfolio_capital_commitment_id` BIGINT COMMENT 'Unique identifier for the capital commitment record. Primary key for the portfolio capital commitment entity.',
    `dd_engagement_id` BIGINT COMMENT 'Foreign key linking to diligence.dd_engagement. Business justification: Pension fund capital commitments to PE/infrastructure funds require completed due diligence.',
    `deal_capital_commitment_id` BIGINT COMMENT 'Foreign key linking to deal.deal_capital_commitment. Business justification: Commitment lifecycle reconciliation requires linking portfolio-stage commitments to their deal-stage predecessors. Audit trail from IC approval through funding depends on this.',
    `fund_id` BIGINT COMMENT 'Reference to the pension fund or contributor pool making the capital commitment.',
    `infra_fund_commitment_id` BIGINT COMMENT 'Foreign key linking to infrastructure.infra_fund_commitment. Business justification: Portfolio-level capital commitments to infrastructure funds must link to infra_fund_commitment for unfunded commitment tracking, capital call forecasting, and SAA',
    `opportunity_id` BIGINT COMMENT 'Foreign key linking to deal.opportunity. Business justification: Deal attribution reporting requires tracing portfolio commitments to originating opportunities. Investment performance analysis by deal vintage and sourcing channel depends on this link.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio or investment program receiving the capital commitment.',
    `re_fund_commitment_id` BIGINT COMMENT 'Foreign key linking to realestate.re_fund_commitment. Business justification: Pension funds track commitments to real estate funds alongside PE funds. Links portfolio-level commitment tracking to RE fund details for consolidated unfunded commitment',
    `asset_class` STRING COMMENT 'Primary asset class category for which the capital is committed.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `base_currency_committed_amount` DECIMAL(20,2) COMMENT 'Committed amount converted to the pension fund base reporting currency at commitment date Foreign Exchange (FX) rate.',
    `base_currency_funded_amount` DECIMAL(20,2) COMMENT 'Funded amount converted to the pension fund base reporting currency using historical Foreign Exchange (FX) rates at each funding date.',
    `base_currency_unfunded_amount` DECIMAL(20,2) COMMENT 'Unfunded amount converted to the pension fund base reporting currency at current Foreign Exchange (FX) rate.',
    `carried_interest_percent` DECIMAL(5,2) COMMENT 'Percentage of profits above the hurdle rate that the General Partner (GP) receives as performance-based compensation.',
    `commitment_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the capital commitment is denominated.. Valid values are `^[A-Z]{3}$`',
    `commitment_date` DATE COMMENT 'Date on which the capital commitment was formally made and documented, typically the Limited Partnership Agreement (LPA) signing date or Investment Committee (IC) approval date.',
    `commitment_notes` STRING COMMENT 'Free-text field for additional context, special terms, conditions, or Investment Committee (IC) stipulations related to the commitment.',
    `commitment_period_end_date` DATE COMMENT 'Date after which no new capital calls can be issued, typically defined in the Limited Partnership Agreement (LPA).',
    `commitment_period_start_date` DATE COMMENT 'Date from which capital calls can begin to be issued against this commitment.',
    `commitment_reference_number` STRING COMMENT 'External business identifier for the capital commitment, used in legal documents and Investment Committee (IC) materials.',
    `commitment_status` STRING COMMENT 'Current lifecycle state of the capital commitment from approval through funding completion.. Valid values are `pending|approved|active|fully_funded|cancelled|expired`',
    `commitment_type` STRING COMMENT 'Classification of the capital commitment by investment structure and timing.. Valid values are `initial|follow_on|co_investment|secondary|recapitalization|sidecar`',
    `committed_amount` DECIMAL(20,2) COMMENT 'Total capital amount committed to the portfolio or investment program, representing the maximum obligation.',
    `counterparty_name` STRING COMMENT 'Legal name of the General Partner (GP), fund manager, or investment vehicle receiving the capital commitment.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this capital commitment record was first created in the system.',
    `esg_classification` STRING COMMENT 'Environmental, Social, and Governance (ESG) classification or rating of the investment program per Sustainable Finance Disclosure Regulation (SFDR) or internal ESG framework.',
    `expected_fund_term_years` BIGINT COMMENT 'Expected total duration of the fund or investment program in years, including investment period and harvest period.',
    `extension_options_years` BIGINT COMMENT 'Number of additional years the fund term can be extended beyond the base term, as permitted by the Limited Partnership Agreement (LPA).',
    `funded_amount` DECIMAL(20,2) COMMENT 'Cumulative capital amount that has been called and funded to date through capital calls or drawdowns.',
    `geographic_focus` STRING COMMENT 'Primary geographic region or market focus for the committed capital deployment.',
    `hurdle_rate_percent` DECIMAL(5,2) COMMENT 'Minimum return threshold percentage that must be achieved before General Partner (GP) carried interest is earned, also known as preferred return.',
    `ic_approval_date` DATE COMMENT 'Date on which the Investment Committee (IC) formally approved the capital commitment.',
    `ic_approval_reference` STRING COMMENT 'Reference number or identifier for the Investment Committee (IC) meeting minutes or resolution approving the commitment.',
    `investment_strategy` STRING COMMENT 'Detailed description of the investment strategy, mandate, or thesis for which the capital is committed.',
    `last_modified_by` STRING COMMENT 'User identifier or name of the person who last modified this capital commitment record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this capital commitment record was last updated or modified.',
    `legal_entity_identifier` STRING COMMENT 'ISO 17442 Legal Entity Identifier (LEI) of the investment vehicle or counterparty receiving the commitment.. Valid values are `^[A-Z0-9]{20}$`',
    `lpa_document_reference` STRING COMMENT 'Document management system reference or identifier for the executed Limited Partnership Agreement (LPA).',
    `lpa_execution_date` DATE COMMENT 'Date on which the Limited Partnership Agreement (LPA) or equivalent legal commitment document was executed.',
    `management_fee_percent` DECIMAL(5,2) COMMENT 'Annual management fee percentage charged by the General Partner (GP) on committed or invested capital.',
    `responsible_investment_flag` BOOLEAN COMMENT 'Indicates whether the commitment is designated as a responsible investment under Principles for Responsible Investment (PRI) framework.',
    `saa_target_allocation_percent` DECIMAL(5,2) COMMENT 'Target allocation percentage for this commitment within the overall Strategic Asset Allocation (SAA) framework.',
    `sector_focus` STRING COMMENT 'Primary industry sector or sub-sector focus for the committed capital deployment.',
    `target_irr_percent` DECIMAL(5,2) COMMENT 'Target net Internal Rate of Return (IRR) percentage for the investment program as stated in the Investment Memorandum (IM).',
    `target_moic` DECIMAL(5,2) COMMENT 'Target Multiple on Invested Capital (MOIC) for the investment program, representing expected total value divided by invested capital.',
    `unfunded_amount` DECIMAL(20,2) COMMENT 'Remaining uncalled capital commitment available for future drawdowns, commonly referred to as dry powder in private markets.',
    `vintage_year` BIGINT COMMENT 'Calendar year in which the capital commitment was made, used for cohort analysis and performance benchmarking in private markets.',
    `created_by` STRING COMMENT 'User identifier or name of the person who created this capital commitment record.',
    CONSTRAINT pk_portfolio_capital_commitment PRIMARY KEY(`portfolio_capital_commitment_id`)
) COMMENT 'Record of capital committed to a portfolio or investment program from the pension funds net contributions and asset allocation decisions. Captures committed amount, funded amount, unfunded (dry powder) balance, commitment currency, commitment date';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`portfolio_nav_record` (
    `portfolio_nav_record_id` BIGINT COMMENT 'Unique identifier for the NAV record. Primary key for this entity.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio for which this NAV is calculated.',
    `valuation_nav_record_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_nav_record. Business justification: NAV reconciliation process requires linking portfolio NAV records to valuation-calculated NAVs.',
    `accrued_expenses` DECIMAL(20,4) COMMENT 'The total accrued expenses deducted in the NAV calculation, such as management fees and administrative costs.',
    `accrued_income` DECIMAL(20,4) COMMENT 'The total accrued income included in the NAV calculation, such as interest and dividends earned but not yet received.',
    `administrator_name` STRING COMMENT 'The name of the fund administrator responsible for calculating and reporting the NAV.',
    `approval_status` STRING COMMENT 'The approval status of the NAV record by authorized personnel or investment committee.. Valid values are `pending|approved|rejected|under_review`',
    `approval_timestamp` TIMESTAMP COMMENT 'The date and time when the NAV record was approved.',
    `approved_by` STRING COMMENT 'The name or identifier of the person who approved the NAV record.',
    `calculation_method` STRING COMMENT 'The methodology used to calculate the NAV, such as mark-to-market, fair value, or administrator-reported.. Valid values are `mark_to_market|fair_value|amortized_cost|model_based|administrator_reported`',
    `cash_and_equivalents` DECIMAL(20,4) COMMENT 'The total value of cash and cash equivalents held in the portfolio as of the valuation date.',
    `contributions` DECIMAL(20,4) COMMENT 'The total contributions or capital inflows into the portfolio during the valuation period.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this NAV record was first created in the lakehouse.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the NAV is denominated.. Valid values are `^[A-Z]{3}$`',
    `distributions` DECIMAL(20,4) COMMENT 'The total distributions or capital outflows from the portfolio during the valuation period.',
    `fiscal_quarter` BIGINT COMMENT 'The fiscal quarter within the fiscal year to which this NAV record belongs.',
    `fiscal_year` BIGINT COMMENT 'The fiscal year to which this NAV record belongs.',
    `fx_impact` DECIMAL(20,4) COMMENT 'The impact of foreign exchange rate movements on the NAV during the valuation period.',
    `gav_amount` DECIMAL(20,4) COMMENT 'The total gross asset value before deducting liabilities, representing the sum of all portfolio holdings at market value.',
    `is_active` BOOLEAN COMMENT 'Indicates whether this NAV record is the current active record or has been superseded by a restatement.',
    `management_fee_accrual` DECIMAL(20,4) COMMENT 'The accrued management fees payable to external managers or internal management, deducted from NAV.',
    `modified_timestamp` TIMESTAMP COMMENT 'The date and time when this NAV record was last modified in the lakehouse.',
    `nav_amount` DECIMAL(20,4) COMMENT 'The total net asset value of the portfolio as of the valuation date, representing total assets minus total liabilities.',
    `nav_change_amount` DECIMAL(20,4) COMMENT 'The absolute change in NAV from the prior valuation date to the current valuation date.',
    `nav_change_percentage` DECIMAL(10,6) COMMENT 'The percentage change in NAV from the prior valuation date to the current valuation date.',
    `nav_per_unit` DECIMAL(20,6) COMMENT 'The NAV per unit or share, calculated as total NAV divided by total units outstanding.',
    `nav_status` STRING COMMENT 'The status of the NAV record indicating whether it is preliminary, final, restated, or adjusted.. Valid values are `preliminary|final|restated|adjusted|cancelled`',
    `notes` STRING COMMENT 'Additional notes or comments regarding the NAV calculation, variances, or special circumstances.',
    `payables` DECIMAL(20,4) COMMENT 'The total value of payables, including pending settlements and other amounts owed by the portfolio.',
    `performance_fee_accrual` DECIMAL(20,4) COMMENT 'The accrued performance fees or carried interest payable to external managers, deducted from NAV.',
    `prior_nav_amount` DECIMAL(20,4) COMMENT 'The NAV amount from the previous valuation date, used for period-over-period comparison.',
    `receivables` DECIMAL(20,4) COMMENT 'The total value of receivables, including pending settlements and other amounts due to the portfolio.',
    `reconciliation_status` STRING COMMENT 'The status of the reconciliation process between administrator NAV and internal IBOR NAV.. Valid values are `pending|reconciled|variance_identified|approved|rejected`',
    `reporting_period` STRING COMMENT 'The frequency or period for which this NAV is reported, such as daily, monthly, or quarterly.. Valid values are `daily|weekly|monthly|quarterly|annual`',
    `source_system_code` STRING COMMENT 'The unique identifier of this NAV record in the source system.',
    `total_assets` DECIMAL(20,4) COMMENT 'The total market value of all assets held in the portfolio as of the valuation date.',
    `total_liabilities` DECIMAL(20,4) COMMENT 'The total value of all liabilities and obligations of the portfolio as of the valuation date.',
    `unfunded_commitments` DECIMAL(20,4) COMMENT 'The total value of unfunded capital commitments to private equity, infrastructure, and other illiquid investments.',
    `units_outstanding` DECIMAL(20,6) COMMENT 'The total number of units or shares outstanding as of the valuation date.',
    `valuation_date` DATE COMMENT 'The date as of which the NAV is calculated and reported.',
    `valuation_source` STRING COMMENT 'The source system or party that provided the NAV calculation, such as fund administrator, IBOR, or custodian.. Valid values are `fund_administrator|internal_ibor|custodian|third_party_valuation|composite`',
    `variance_amount` DECIMAL(20,4) COMMENT 'The difference between administrator-reported NAV and internal IBOR NAV, if any.',
    `variance_percentage` DECIMAL(10,6) COMMENT 'The variance expressed as a percentage of the total NAV.',
    CONSTRAINT pk_portfolio_nav_record PRIMARY KEY(`portfolio_nav_record_id`)
) COMMENT 'Net Asset Value (NAV) record for a portfolio as of a specific valuation date, representing the authoritative portfolio-level NAV as calculated by the fund administrator (State Street / Northern Trust) and reconciled against the IBOR.';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` (
    `portfolio_cash_flow_id` BIGINT COMMENT 'Unique identifier for the cash flow record.',
    `cash_account_id` BIGINT COMMENT 'Reference to the bank account used for the cash flow transaction.',
    `counterparty_id` BIGINT COMMENT 'Reference to the counterparty entity involved in the cash flow transaction such as custodian, broker, or fund manager.',
    `distribution_id` BIGINT COMMENT 'Foreign key linking to privateequity.distribution. Business justification: PE distributions create portfolio cash inflows. Linking enables reconciliation between GP distribution notices and portfolio cash records - essential for cash management, NAV',
    `fund_id` BIGINT COMMENT 'Reference to the beneficiary fund pool that contributed or received this cash flow.',
    `infra_asset_id` BIGINT COMMENT 'Foreign key linking to infrastructure.infra_asset. Business justification: Cash flows (distributions, dividends) from direct infrastructure investments require infra_asset reference for cash flow attribution, IRR calculation, and liability matching',
    `investment_id` BIGINT COMMENT 'Reference to the specific investment or position that generated or received this cash flow.',
    `opportunity_id` BIGINT COMMENT 'Foreign key linking to deal.opportunity. Business justification: Deal-level cash flow attribution enables performance measurement by deal vintage and sourcing channel.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio to which this cash flow belongs.',
    `privateequity_capital_call_id` BIGINT COMMENT 'Foreign key linking to privateequity.privateequity_capital_call. Business justification: Capital calls create portfolio cash outflows. Linking enables reconciliation of GP call notices with portfolio cash movements - critical for liquidity forecasting',
    `property_id` BIGINT COMMENT 'Foreign key linking to realestate.property. Business justification: Property-level cash flows (NOI distributions, capex funding, disposition proceeds) must be tracked at portfolio level for liquidity management and performance attribution.',
    `accounting_period` STRING COMMENT 'The accounting period in YYYY-MM format to which this cash flow is attributed for financial reporting.. Valid values are `^d{4}-d{2}$`',
    `accrual_date` DATE COMMENT 'The date on which the cash flow was accrued for accounting purposes, distinct from settlement date.',
    `amount` DECIMAL(20,4) COMMENT 'The monetary amount of the cash flow in the portfolio base currency.',
    `approval_date` DATE COMMENT 'The date on which the cash flow transaction was approved for execution.',
    `approval_status` STRING COMMENT 'The approval workflow status for cash flows requiring authorization before execution.. Valid values are `pending_approval|approved|rejected`',
    `approved_by` STRING COMMENT 'The name or identifier of the user who approved the cash flow transaction.',
    `asset_class` STRING COMMENT 'The asset class category to which this cash flow is attributed for portfolio allocation and reporting purposes. [ENUM-REF-CANDIDATE: public_equity|private_equity|real_estate|infrastructure|natural_resources|credit|cash|multi_asset — 8 candidates stripped',
    `cost_center_code` STRING COMMENT 'The cost center or business unit code for internal allocation and management reporting of fees and expenses.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this cash flow record was first created in the data platform.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the cash flow amount.. Valid values are `^[A-Z]{3}$`',
    `custodian_reference` STRING COMMENT 'The custodian-provided reference or confirmation number for the cash flow transaction.',
    `portfolio_cash_flow_description` STRING COMMENT 'Detailed narrative description of the cash flow transaction including purpose and context.',
    `flow_direction` STRING COMMENT 'Indicates whether the cash flow is an inflow into the portfolio or an outflow from the portfolio.. Valid values are `inflow|outflow`',
    `flow_type` STRING COMMENT 'Classification of the cash flow transaction type indicating the nature of the inflow or outflow. [ENUM-REF-CANDIDATE: contribution|distribution|capital_call|dividend|coupon|fee|fx_settlement|rebalancing|redemption|other — 10 candidates stripped; promote',
    `fx_rate` DECIMAL(18,8) COMMENT 'The exchange rate applied to convert the original currency amount to the portfolio base currency.',
    `gl_account_code` STRING COMMENT 'The general ledger account code to which this cash flow is posted in the accounting system.',
    `is_active` BOOLEAN COMMENT 'Boolean flag indicating whether this cash flow record is currently active or has been logically deleted or superseded.',
    `is_external` BOOLEAN COMMENT 'Boolean flag indicating whether the cash flow is external to the portfolio or an internal reallocation.',
    `is_significant` BOOLEAN COMMENT 'Boolean flag indicating whether the cash flow exceeds the significance threshold for performance calculation adjustments per GIPS standards.',
    `modified_timestamp` TIMESTAMP COMMENT 'The timestamp when this cash flow record was last modified or updated in the data platform.',
    `notes` STRING COMMENT 'Additional free-text notes or comments regarding the cash flow transaction for operational or audit purposes.',
    `original_amount` DECIMAL(20,4) COMMENT 'The cash flow amount in its original transaction currency before any foreign exchange conversion.',
    `original_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the original transaction amount before conversion.. Valid values are `^[A-Z]{3}$`',
    `payment_method` STRING COMMENT 'The payment instrument or mechanism used to execute the cash flow transaction.. Valid values are `wire_transfer|ach|check|internal_transfer|dvp|other`',
    `portfolio_cash_flow_status` STRING COMMENT 'Current lifecycle status of the cash flow transaction indicating its processing state.. Valid values are `pending|confirmed|settled|cancelled|failed|reversed`',
    `reclaim_eligible_flag` BOOLEAN COMMENT 'Boolean flag indicating whether the withholding tax on this cash flow is eligible for reclaim under applicable tax treaties.',
    `reconciliation_date` DATE COMMENT 'The date on which the cash flow was successfully reconciled with external records.',
    `reconciliation_status` STRING COMMENT 'The reconciliation status indicating whether the cash flow has been matched and verified against custodian or bank statements.. Valid values are `unreconciled|reconciled|exception|under_review`',
    `settlement_date` DATE COMMENT 'The date on which the cash flow was settled and funds were transferred.',
    `significance_threshold_percent` DECIMAL(5,2) COMMENT 'The percentage threshold used to determine if this cash flow is significant relative to portfolio NAV for performance calculation purposes.',
    `source_system_code` STRING COMMENT 'The unique identifier for this cash flow record in the source operational system.',
    `tax_treatment` STRING COMMENT 'Classification of the tax treatment applicable to this cash flow for tax reporting and compliance purposes.. Valid values are `taxable|tax_exempt|tax_deferred|withholding_applied|other`',
    `transaction_date` DATE COMMENT 'The date on which the cash flow transaction occurred or was executed.',
    `transaction_reference` STRING COMMENT 'External reference number or identifier for the cash flow transaction from the source system.',
    `value_date` DATE COMMENT 'The effective date for valuation and performance calculation purposes, used in time-weighted return calculations.',
    `withholding_tax_amount` DECIMAL(20,4) COMMENT 'The amount of withholding tax deducted from the cash flow at source, if applicable.',
    `withholding_tax_rate_percent` DECIMAL(5,2) COMMENT 'The withholding tax rate percentage applied to the cash flow transaction.',
    CONSTRAINT pk_portfolio_cash_flow PRIMARY KEY(`portfolio_cash_flow_id`)
) COMMENT 'Portfolio-level cash flow record capturing all inflows and outflows at the portfolio level including net contributions received, capital calls paid, distributions received, dividend and coupon income, management fees paid, FX settlements, and';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`mandate_history` (
    `mandate_history_id` BIGINT COMMENT 'Unique identifier for each mandate history audit record tracking changes to portfolio mandate parameters over time.',
    `mandate_new_benchmark_portfolio_benchmark_id` BIGINT COMMENT 'Reference to the benchmark assignment that became effective with this change, supporting performance measurement and attribution reporting.',
    `mandate_portfolio_benchmark_id` BIGINT COMMENT 'Reference to the benchmark assignment that was in effect before this change, enabling audit trail of benchmark transitions for performance attribution analysis.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio whose mandate parameters were changed in this history record.',
    `portfolio_mandate_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio_mandate. Business justification: mandate_history tracks changes to portfolio mandates over time. It currently has portfolio_id but lacks a direct FK to the specific portfolio_mandate being tracked.',
    `superseded_by_history_mandate_history_id` BIGINT COMMENT 'Reference to the subsequent mandate history record that replaced this change, enabling navigation through the complete audit trail of mandate parameter evolution.',
    `approved_by` STRING COMMENT 'Name or identifier of the Investment Committee (IC) member or approval authority who authorized this mandate parameter change, supporting governance and accountability requirements.',
    `change_effective_date` DATE COMMENT 'Date when the mandate parameter change became effective and binding for portfolio management and reporting purposes.',
    `change_impact_assessment` STRING COMMENT 'Analysis of the expected impact of this mandate change on portfolio construction, risk profile, performance attribution, and operational processes, supporting Investment Committee (IC) decision-making.',
    `change_notes` STRING COMMENT 'Additional commentary, context, and operational details regarding this mandate parameter change, capturing institutional knowledge and supporting future audit reviews.',
    `change_reason` STRING COMMENT 'Business rationale and justification for the mandate parameter change, including strategic drivers, regulatory requirements, or Investment Committee (IC) directives.',
    `change_status` STRING COMMENT 'Current lifecycle status of the mandate change: proposed for review, approved by Investment Committee (IC), implemented in portfolio management systems, superseded by subsequent change, or cancelled before implementation.. Valid values are `proposed|approved|implemented|superseded|cancelled`',
    `change_type` STRING COMMENT 'Classification of the mandate change event: Strategic Asset Allocation (SAA) target revision, benchmark assignment change, investment constraint amendment, currency hedging policy update, mandate scope expansion, or mandate scope restriction.. Valid values are `saa_target_revision|benchmark_change|constraint_amendment|currency_policy_update|scope_expansion|scope_restriction`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this mandate history record was first created in the data platform, supporting data lineage and audit trail requirements.',
    `ic_approval_date` DATE COMMENT 'Date when the Investment Committee (IC) formally approved this mandate parameter change, establishing governance audit trail and authorization for implementation.',
    `ic_approval_reference` STRING COMMENT 'Investment Committee (IC) meeting reference number or Investment Memorandum (IM) identifier documenting the formal approval of this mandate change for governance and audit purposes.',
    `implementation_date` DATE COMMENT 'Date when the mandate parameter change was operationally implemented in portfolio management systems, Investment Book of Record (IBOR), and compliance monitoring platforms.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this mandate history record was last modified in the data platform, tracking updates to change status, approval information, or implementation details.',
    `new_asset_class_scope` STRING COMMENT 'Permitted asset classes and investment universe that became effective with this change, defining eligible public equities, private equity, real estate, infrastructure, natural resources, and credit investments.',
    `new_constraint_type` STRING COMMENT 'Classification of the investment constraint that became effective with this change, such as concentration limit, sector exposure cap, credit quality floor, or liquidity requirement.',
    `new_constraint_value` DECIMAL(18,2) COMMENT 'Specific parameter value or threshold of the investment constraint that became effective with this change, stored as text to accommodate various constraint formats.',
    `new_currency_policy` STRING COMMENT 'Foreign exchange (FX) hedging policy and currency exposure management approach that became effective with this change, including hedging ratios and permitted instruments.',
    `new_esg_framework` STRING COMMENT 'Environmental, Social, and Governance (ESG) integration framework and responsible investment approach that became effective with this change, including Principles for Responsible Investment (PRI) commitments and exclusion policies.',
    `new_rebalancing_frequency` STRING COMMENT 'Portfolio rebalancing schedule and frequency that became effective with this change, defining how often Strategic Asset Allocation (SAA) targets are restored through trading activity.',
    `new_saa_target_weight` DECIMAL(10,6) COMMENT 'Strategic Asset Allocation (SAA) target weight percentage that became effective with this change, expressed as decimal proportion for portfolio construction and rebalancing.',
    `new_tolerance_band_lower` DECIMAL(10,6) COMMENT 'Lower boundary of the Strategic Asset Allocation (SAA) tolerance band that became effective with this change, expressed as decimal proportion below target weight for rebalancing triggers.',
    `new_tolerance_band_upper` DECIMAL(10,6) COMMENT 'Upper boundary of the Strategic Asset Allocation (SAA) tolerance band that became effective with this change, expressed as decimal proportion above target weight for rebalancing triggers.',
    `previous_asset_class_scope` STRING COMMENT 'Permitted asset classes and investment universe that was in effect before this change, defining eligible public equities, private equity, real estate, infrastructure, natural resources, and credit investments.',
    `previous_constraint_type` STRING COMMENT 'Classification of the investment constraint that was in effect before this change, such as concentration limit, sector exposure cap, credit quality floor, or liquidity requirement.',
    `previous_constraint_value` DECIMAL(18,2) COMMENT 'Specific parameter value or threshold of the investment constraint that was in effect before this change, stored as text to accommodate various constraint formats.',
    `previous_currency_policy` STRING COMMENT 'Foreign exchange (FX) hedging policy and currency exposure management approach that was in effect before this change, including hedging ratios and permitted instruments.',
    `previous_esg_framework` STRING COMMENT 'Environmental, Social, and Governance (ESG) integration framework and responsible investment approach that was in effect before this change, including Principles for Responsible Investment (PRI) commitments and exclusion policies.',
    `previous_rebalancing_frequency` STRING COMMENT 'Portfolio rebalancing schedule and frequency that was in effect before this change, defining how often Strategic Asset Allocation (SAA) targets are restored through trading activity.',
    `previous_saa_target_weight` DECIMAL(10,6) COMMENT 'Strategic Asset Allocation (SAA) target weight percentage that was in effect before this change, expressed as decimal proportion for audit and rebalancing analysis.',
    `previous_tolerance_band_lower` DECIMAL(10,6) COMMENT 'Lower boundary of the Strategic Asset Allocation (SAA) tolerance band that was in effect before this change, expressed as decimal proportion below target weight.',
    `previous_tolerance_band_upper` DECIMAL(10,6) COMMENT 'Upper boundary of the Strategic Asset Allocation (SAA) tolerance band that was in effect before this change, expressed as decimal proportion above target weight.',
    `regulatory_reference` STRING COMMENT 'Citation of the specific regulatory requirement, the national pension regulator, guideline, or pension regulation that necessitated this mandate parameter change.',
    `regulatory_trigger_flag` BOOLEAN COMMENT 'Indicator whether this mandate change was triggered by regulatory requirements, such as the national pension regulator, directives, Sustainable Finance Disclosure Regulation (SFDR) compliance, or pension regulation updates.',
    `source_system_code` STRING COMMENT 'Unique identifier of this mandate history record in the source operational system, enabling traceability and reconciliation with upstream systems of record.',
    `stakeholder_notification_date` DATE COMMENT 'Date when beneficiaries, external managers, custodians, and other stakeholders were formally notified of this mandate parameter change, supporting transparency and communication requirements.',
    `superseded_date` DATE COMMENT 'Date when this mandate change was replaced or overridden by a subsequent mandate parameter revision, establishing temporal validity for historical analysis.',
    `version_number` BIGINT COMMENT 'Sequential version number of the mandate parameter set, incrementing with each approved change to support version control and audit trail reconstruction.',
    CONSTRAINT pk_mandate_history PRIMARY KEY(`mandate_history_id`)
) COMMENT 'Audit history record tracking all changes to portfolio mandate parameters over time, including SAA target revisions, benchmark changes, constraint amendments, currency policy updates, and mandate scope expansions or restrictions.';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`sleeve` (
    `sleeve_id` BIGINT COMMENT 'Unique identifier for the portfolio sleeve record.',
    `composite_id` BIGINT COMMENT 'Reference to the performance composite to which this sleeve belongs for Global Investment Performance Standards (GIPS) reporting.',
    `credit_mandate_id` BIGINT COMMENT 'Foreign key linking to credit.credit_mandate. Business justification: Credit sleeves within multi-asset portfolios require dedicated credit mandates specifying duration limits, credit quality minimums, and sector constraints.',
    `employee_id` BIGINT COMMENT 'Reference to the external manager or internal team responsible for managing this sleeve.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external manager or internal team responsible for managing this sleeve.',
    `pe_fund_id` BIGINT COMMENT 'Foreign key linking to privateequity.fund. Business justification: Portfolio sleeves allocate to specific PE funds for sub-portfolio construction. Investment teams track PE fund exposure within sleeves for rebalancing decisions and asset allocation',
    `portfolio_benchmark_id` BIGINT COMMENT 'Reference to the benchmark index used to measure performance of this sleeve.',
    `portfolio_id` BIGINT COMMENT 'Reference to the parent portfolio to which this sleeve belongs.',
    `actual_allocation_amount` DECIMAL(20,2) COMMENT 'Current actual allocation amount in base currency for this sleeve.',
    `actual_allocation_weight_percent` DECIMAL(7,4) COMMENT 'Current actual allocation weight as a percentage of the parent portfolio.',
    `approval_authority` STRING COMMENT 'Name or role of the authority that approved the establishment or modification of this sleeve (e.g., Investment Committee, CIO).',
    `asset_class_code` STRING COMMENT 'Primary asset class code assigned to this sleeve (e.g., public equities, private equity, real estate, infrastructure, natural resources, credit).',
    `base_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code representing the base currency for this sleeve.. Valid values are `^[A-Z]{3}$`',
    `sleeve_code` STRING COMMENT 'Externally-known unique business code for the sleeve, used for reporting and operational reference.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this sleeve record was first created in the system.',
    `sleeve_description` STRING COMMENT 'Detailed textual description of the sleeves purpose, strategy, and investment objectives.',
    `effective_from_date` DATE COMMENT 'Date from which the current sleeve configuration is effective.',
    `effective_to_date` DATE COMMENT 'Date until which the current sleeve configuration is effective; null for open-ended sleeves.',
    `esg_framework` STRING COMMENT 'Name of the Environmental, Social, and Governance (ESG) framework applied to this sleeve (e.g., PRI, TCFD, SFDR).',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether Environmental, Social, and Governance (ESG) criteria are integrated into the investment process for this sleeve.',
    `exclusion_list_applied_flag` BOOLEAN COMMENT 'Indicates whether an investment exclusion list (e.g., tobacco, weapons, fossil fuels) is applied to this sleeve.',
    `gips_compliant_flag` BOOLEAN COMMENT 'Indicates whether this sleeve is managed and reported in compliance with Global Investment Performance Standards (GIPS).',
    `ic_approval_date` DATE COMMENT 'Date when the Investment Committee (IC) approved the establishment or modification of this sleeve.',
    `ic_approval_reference` STRING COMMENT 'Reference number or identifier for the Investment Committee (IC) approval decision related to this sleeve.',
    `inception_date` DATE COMMENT 'Date when the sleeve was established and became operational.',
    `last_rebalance_date` DATE COMMENT 'Date when the sleeve was last rebalanced.',
    `leverage_limit_percent` DECIMAL(7,4) COMMENT 'Maximum allowable leverage for this sleeve, expressed as a percentage of Net Asset Value (NAV).',
    `liquidity_requirement_days` BIGINT COMMENT 'Minimum number of days within which the sleeve must be able to liquidate positions to meet cash requirements.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this sleeve record was last modified.',
    `sleeve_name` STRING COMMENT 'Human-readable name of the sleeve, describing its purpose or strategy.',
    `next_rebalance_date` DATE COMMENT 'Scheduled date for the next rebalancing of this sleeve.',
    `notes` STRING COMMENT 'Additional operational or administrative notes related to the sleeve.',
    `performance_attribution_flag` BOOLEAN COMMENT 'Indicates whether performance attribution analysis is performed at the sleeve level.',
    `performance_calculation_method` STRING COMMENT 'Method used to calculate performance for this sleeve: Time-Weighted Return (TWR), Money-Weighted Return (MWR), Internal Rate of Return (IRR), or Multiple on Invested Capital (MOIC).. Valid values are `twr|mwr|irr|moic`',
    `rebalancing_frequency` STRING COMMENT 'Scheduled frequency at which this sleeve is reviewed and rebalanced.. Valid values are `daily|weekly|monthly|quarterly|semi_annual|annual`',
    `rebalancing_required_flag` BOOLEAN COMMENT 'Indicates whether rebalancing is currently required based on threshold breach or scheduled review.',
    `rebalancing_threshold_lower_percent` DECIMAL(7,4) COMMENT 'Lower threshold percentage that triggers rebalancing action when actual weight falls below this level.',
    `rebalancing_threshold_upper_percent` DECIMAL(7,4) COMMENT 'Upper threshold percentage that triggers rebalancing action when actual weight exceeds this level.',
    `reporting_inclusion_flag` BOOLEAN COMMENT 'Indicates whether this sleeve is included in consolidated portfolio reporting and performance attribution.',
    `risk_budget_percent` DECIMAL(7,4) COMMENT 'Percentage of the total portfolio risk budget allocated to this sleeve.',
    `sleeve_status` STRING COMMENT 'Current lifecycle status of the sleeve.. Valid values are `active|inactive|suspended|pending|closed`',
    `sleeve_type` STRING COMMENT 'Classification of the sleeve by its organizational purpose: asset class sleeve, strategy sleeve, manager sleeve, geographic sleeve, sector sleeve, or thematic sleeve.. Valid values are `asset_class|strategy|manager|geographic|sector|thematic`',
    `source_system_code` STRING COMMENT 'Unique identifier for this sleeve in the source system.',
    `strategy_name` STRING COMMENT 'Name of the investment strategy employed within this sleeve (e.g., value, growth, core-plus, opportunistic).',
    `sub_asset_class_code` STRING COMMENT 'Granular sub-asset class code for further classification within the primary asset class.',
    `taa_adjustment_weight_percent` DECIMAL(7,4) COMMENT 'Tactical Asset Allocation (TAA) adjustment applied to the Strategic Asset Allocation (SAA) target weight, expressed as percentage points.',
    `target_allocation_amount` DECIMAL(20,2) COMMENT 'Target allocation amount in base currency for this sleeve as per Strategic Asset Allocation (SAA).',
    `target_allocation_weight_percent` DECIMAL(7,4) COMMENT 'Target allocation weight as a percentage of the parent portfolio, per Strategic Asset Allocation (SAA).',
    `termination_date` DATE COMMENT 'Date when the sleeve was closed or terminated.',
    `tolerance_band_lower_percent` DECIMAL(7,4) COMMENT 'Lower bound of the tolerance band for allocation weight, expressed as percentage points below target.',
    `tolerance_band_upper_percent` DECIMAL(7,4) COMMENT 'Upper bound of the tolerance band for allocation weight, expressed as percentage points above target.',
    `tracking_error_limit_bps` BIGINT COMMENT 'Maximum allowable tracking error for this sleeve relative to its benchmark, expressed in basis points.',
    `var_limit_percent` DECIMAL(7,4) COMMENT 'Maximum allowable Value at Risk (VaR) for this sleeve, expressed as a percentage of sleeve value.',
    CONSTRAINT pk_sleeve PRIMARY KEY(`sleeve_id`)
) COMMENT 'Master record for a portfolio sleeve — a ring-fenced sub-allocation within a portfolio dedicated to a specific asset class, strategy, or manager mandate. Captures sleeve name, sleeve type (asset class sleeve, manager sleeve, strategy sleeve), target';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`currency_exposure` (
    `currency_exposure_id` BIGINT COMMENT 'Unique identifier for the currency exposure record.',
    `hedge_counterparty_id` BIGINT COMMENT 'Reference to the counterparty providing the hedging instruments for this currency exposure.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio for which currency exposure is measured.',
    `approval_date` DATE COMMENT 'The date on which the currency exposure or hedging strategy was approved.',
    `approval_status` STRING COMMENT 'The approval status of the currency exposure record or hedging strategy by the Investment Committee or risk management team.. Valid values are `pending|approved|rejected`',
    `approved_by` STRING COMMENT 'The name or identifier of the individual or committee that approved the currency exposure or hedging strategy.',
    `asset_class_code` STRING COMMENT 'The asset class contributing to the foreign currency exposure, such as equities, fixed income, real estate, or private equity.',
    `base_currency_code` STRING COMMENT 'The reporting currency of the portfolio, expressed as ISO 4217 three-letter code.. Valid values are `^[A-Z]{3}$`',
    `comments` STRING COMMENT 'Additional notes or commentary regarding the currency exposure, hedging strategy, or policy breaches.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when the currency exposure record was first created in the system.',
    `data_source_record_reference` STRING COMMENT 'The unique identifier of this currency exposure record in the source system.',
    `data_source_system` STRING COMMENT 'The operational system from which the currency exposure data was sourced, such as SimCorp Dimension, Aladdin, or State Street.',
    `dv01_amount` DECIMAL(20,2) COMMENT 'The sensitivity of the currency exposure to a one basis point change in foreign exchange rates, expressed in base currency.',
    `exposure_status` STRING COMMENT 'Current status of the currency exposure record in the portfolio monitoring lifecycle.. Valid values are `active|closed|under_review|breached`',
    `exposure_type` STRING COMMENT 'Classification of the currency exposure: transaction exposure from cash flows, translation exposure from asset valuation, or economic exposure from market conditions.. Valid values are `transaction|translation|economic`',
    `foreign_currency_code` STRING COMMENT 'The foreign currency to which the portfolio has exposure, expressed as ISO 4217 three-letter code.. Valid values are `^[A-Z]{3}$`',
    `fx_forward_rate` DECIMAL(18,6) COMMENT 'The forward exchange rate used for hedging contracts, if applicable.',
    `fx_spot_rate` DECIMAL(18,6) COMMENT 'The spot exchange rate between the foreign currency and base currency as of the valuation date.',
    `geographic_region` STRING COMMENT 'The geographic region or market where the foreign currency exposure originates.',
    `gross_exposure_amount` DECIMAL(20,2) COMMENT 'Total unhedged exposure to the foreign currency before any hedging instruments are applied, expressed in base currency.',
    `hedge_cost_bps` DECIMAL(8,2) COMMENT 'The annualized cost of hedging the foreign currency exposure, expressed in basis points.',
    `hedge_effectiveness_percent` DECIMAL(5,2) COMMENT 'The effectiveness of the hedging strategy in offsetting foreign currency risk, measured as a percentage.',
    `hedge_instrument_type` STRING COMMENT 'The type of derivative or hedging instrument used to manage the foreign currency exposure.. Valid values are `forward|future|swap|option|none`',
    `hedge_maturity_date` DATE COMMENT 'The maturity or expiration date of the hedging instruments covering this currency exposure.',
    `hedge_ratio_percent` DECIMAL(5,2) COMMENT 'The percentage of gross foreign currency exposure that is hedged through FX derivatives or other hedging instruments.',
    `hedged_notional_amount` DECIMAL(20,2) COMMENT 'The notional amount of foreign currency exposure covered by hedging instruments, expressed in base currency.',
    `last_modified_by` STRING COMMENT 'The user or system that last modified the currency exposure record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The timestamp when the currency exposure record was last updated.',
    `mtm_gain_loss_amount` DECIMAL(20,2) COMMENT 'The unrealized gain or loss on the currency exposure due to foreign exchange rate movements since the prior valuation date, expressed in base currency.',
    `net_exposure_amount` DECIMAL(20,2) COMMENT 'The residual unhedged foreign currency exposure after hedging instruments are applied, expressed in base currency.',
    `policy_breach_flag` BOOLEAN COMMENT 'Indicates whether the current currency exposure exceeds the policy limit.',
    `policy_limit_amount` DECIMAL(20,2) COMMENT 'The maximum allowable foreign currency exposure for this currency as defined by the investment policy, expressed in base currency.',
    `realized_gain_loss_amount` DECIMAL(20,2) COMMENT 'The realized gain or loss from settled foreign currency transactions during the reporting period, expressed in base currency.',
    `rebalancing_required_flag` BOOLEAN COMMENT 'Indicates whether rebalancing or additional hedging is required to bring the exposure within policy limits.',
    `reporting_frequency` STRING COMMENT 'The frequency at which currency exposure is measured and reported for this portfolio.. Valid values are `daily|weekly|monthly|quarterly`',
    `stress_test_impact_amount` DECIMAL(20,2) COMMENT 'The estimated impact on portfolio value under the stress test scenario, expressed in base currency.',
    `stress_test_scenario` STRING COMMENT 'The stress test scenario applied to assess the impact of extreme foreign exchange rate movements on this exposure.',
    `valuation_date` DATE COMMENT 'The date on which the currency exposure is measured and reported.',
    `var_contribution_amount` DECIMAL(20,2) COMMENT 'The contribution of this currency exposure to the overall portfolio Value at Risk, expressed in base currency.',
    CONSTRAINT pk_currency_exposure PRIMARY KEY(`currency_exposure_id`)
) COMMENT 'Portfolio-level currency exposure record capturing the unhedged and hedged foreign currency exposures as of a valuation date. Records base currency, foreign currency, gross exposure amount, hedge ratio, hedged notional, net unhedged exposure, and FX';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`liquidity_bucket` (
    `liquidity_bucket_id` BIGINT COMMENT 'Unique identifier for the liquidity bucket classification record.',
    `holding_snapshot_id` BIGINT COMMENT 'Reference to the specific holding snapshot being classified for liquidity.',
    `listed_security_id` BIGINT COMMENT 'Reference to the security being classified for liquidity analysis.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio to which this liquidity classification applies.',
    `asset_class` STRING COMMENT 'The asset class of the holding being classified (public equities, private equity, real estate, infrastructure, natural resources, credit).',
    `average_daily_volume` DECIMAL(18,2) COMMENT 'Average daily trading volume for the security over the measurement period, used to assess liquidity.',
    `base_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the portfolios base currency.. Valid values are `^[A-Z]{3}$`',
    `bid_ask_spread_bps` DECIMAL(10,2) COMMENT 'The bid-ask spread expressed in basis points, indicating transaction cost and liquidity tightness.',
    `bucket_weight_percent` DECIMAL(8,4) COMMENT 'The cumulative weight of all holdings in this liquidity tier as a percentage of total portfolio value.',
    `classification_date` DATE COMMENT 'The date on which this liquidity classification was determined.',
    `classification_methodology` STRING COMMENT 'The methodology or framework used to determine the liquidity classification (internal model, vendor model, regulatory framework).',
    `classification_source` STRING COMMENT 'The source of the liquidity classification determination.. Valid values are `internal_model|vendor_data|manual_override|regulatory_guideline`',
    `classification_status` STRING COMMENT 'Current status of the liquidity classification record in its lifecycle.. Valid values are `active|superseded|pending|expired`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this liquidity classification record was first created in the system.',
    `effective_from_date` DATE COMMENT 'The date from which this liquidity classification becomes effective.',
    `effective_to_date` DATE COMMENT 'The date until which this liquidity classification remains effective, null for current classifications.',
    `estimated_liquidation_days` BIGINT COMMENT 'Estimated number of days required to fully liquidate the position without significant market impact.',
    `gate_provision_flag` BOOLEAN COMMENT 'Indicates whether the investment is subject to gate provisions that can restrict redemptions during stressed market conditions.',
    `haircut_percent` DECIMAL(8,4) COMMENT 'The haircut percentage applied to the market value for liquidity calculations, reflecting potential value loss in rapid liquidation.',
    `hqla_category` STRING COMMENT 'The HQLA category classification (Level 1, Level 2A, Level 2B, or Non-HQLA) under Basel III.. Valid values are `level_1|level_2a|level_2b|non_hqla`',
    `hqla_eligible_flag` BOOLEAN COMMENT 'Indicates whether the holding qualifies as a High-Quality Liquid Asset under Basel III Liquidity Coverage Ratio (LCR) requirements.',
    `instrument_type` STRING COMMENT 'The specific instrument type of the security (equity, bond, derivative, fund unit, real asset).',
    `last_review_date` DATE COMMENT 'The date on which this liquidity classification was last reviewed.',
    `liquidation_cost_percent` DECIMAL(8,4) COMMENT 'Estimated cost of liquidation expressed as a percentage of market value, including transaction costs and market impact.',
    `liquidity_tier` STRING COMMENT 'The liquidity tier classification indicating the time horizon for converting the holding to cash without significant price impact. [ENUM-REF-CANDIDATE: T+0|T+1|T+2|T+5|T+30|T+90|T+180|illiquid|locked — promote to reference product]. Valid values are `T+0|T+1|T+2|T+5|T+30|T+90`',
    `liquidity_tier_code` STRING COMMENT 'Internal code representing the liquidity tier for system processing and reporting.',
    `liquidity_tier_description` STRING COMMENT 'Detailed description of the liquidity tier classification and its business meaning.',
    `lock_up_period_end_date` DATE COMMENT 'The date on which any lock-up or restriction on redemption expires, after which the holding becomes more liquid.',
    `market_depth_indicator` STRING COMMENT 'Qualitative assessment of the market depth and trading volume available for this holding.. Valid values are `deep|moderate|shallow|illiquid`',
    `market_value_base_currency` DECIMAL(20,2) COMMENT 'Current market value of the holding in the portfolios base currency, used for liquidity weighting.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this liquidity classification record was last modified.',
    `next_review_date` DATE COMMENT 'The scheduled date for the next review of this liquidity classification.',
    `notes` STRING COMMENT 'Additional notes or comments regarding the liquidity classification, including special considerations or assumptions.',
    `override_approval_date` DATE COMMENT 'Date on which the liquidity classification override was approved.',
    `override_approved_by` STRING COMMENT 'Name or identifier of the individual who approved the liquidity classification override.',
    `override_flag` BOOLEAN COMMENT 'Indicates whether the liquidity classification was manually overridden from the system-generated classification.',
    `override_reason` STRING COMMENT 'Business justification for any manual override of the liquidity classification.',
    `redemption_notice_days` BIGINT COMMENT 'Number of days advance notice required to redeem or liquidate the holding, applicable to private markets and fund investments.',
    `regulatory_classification` STRING COMMENT 'Liquidity classification as defined by regulatory frameworks such as Basel III or local pension regulations.',
    `review_frequency_days` BIGINT COMMENT 'The frequency in days at which this liquidity classification should be reviewed and updated.',
    `side_pocket_flag` BOOLEAN COMMENT 'Indicates whether the holding is held in a side pocket, making it illiquid until realization.',
    `source_system_code` STRING COMMENT 'The unique identifier for this liquidity classification record in the source system.',
    `stress_scenario_tier` STRING COMMENT 'The liquidity tier classification under stressed market conditions, used for stress testing and scenario analysis.',
    `weight_percent` DECIMAL(8,4) COMMENT 'The weight of this holding as a percentage of total portfolio value, used for liquidity concentration analysis.',
    CONSTRAINT pk_liquidity_bucket PRIMARY KEY(`liquidity_bucket_id`)
) COMMENT 'Portfolio liquidity classification record bucketing holdings into liquidity tiers (T+0, T+1, T+2, T+5, T+30, T+90, T+180, illiquid/locked) based on instrument type, market depth, and redemption terms.';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` (
    `portfolio_ic_approval_id` BIGINT COMMENT 'Unique identifier for the Investment Committee approval record for portfolio-level decisions.',
    `coinvestment_id` BIGINT COMMENT 'Foreign key linking to privateequity.coinvestment. Business justification: Co-investments require separate IC approval with distinct terms. Linking approval to coinvestment record enables governance tracking, fee analysis, and performance attribution for',
    `diligence_ic_submission_id` BIGINT COMMENT 'Foreign key linking to diligence.diligence_ic_submission. Business justification: Portfolio IC approvals for new investments reference the diligence IC submission that cleared the investment.',
    `ic_meeting_id` BIGINT COMMENT 'Reference to the specific Investment Committee meeting where this approval was granted or denied.',
    `pe_fund_id` BIGINT COMMENT 'Foreign key linking to privateequity.fund. Business justification: Investment Committee approvals for PE fund commitments must reference the specific fund.',
    `pe_investment_id` BIGINT COMMENT 'Foreign key linking to privateequity.investment. Business justification: IC approvals for direct PE investments require linking to the specific investment record.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio subject to this Investment Committee approval decision.',
    `approval_reference_number` STRING COMMENT 'Externally-known unique reference number assigned to this Investment Committee approval for tracking and audit purposes.',
    `approval_type` STRING COMMENT 'Category of portfolio-level decision requiring Investment Committee approval. [ENUM-REF-CANDIDATE: saa_change|taa_adjustment|mandate_approval|benchmark_change|rebalancing_authorization|capital_commitment|policy_exception — 7 candidates stripped; promote',
    `approved_by` STRING COMMENT 'Name or identifier of the Investment Committee Chair or authorized signatory who approved the decision.',
    `capital_commitment_amount` DECIMAL(20,2) COMMENT 'Total capital commitment amount requiring Investment Committee approval, if applicable to this decision.',
    `capital_commitment_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the capital commitment amount.. Valid values are `^[A-Z]{3}$`',
    `chair_approval_flag` BOOLEAN COMMENT 'Indicates whether the Investment Committee Chair formally approved the decision.',
    `compliance_review_status` STRING COMMENT 'Status of compliance department review of the proposal prior to Investment Committee consideration.. Valid values are `approved|pending|rejected|not_required`',
    `conditions_of_approval` STRING COMMENT 'Specific conditions, restrictions, or requirements attached to the Investment Committee approval, if any.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this Investment Committee approval record was first created in the system.',
    `decision_date` DATE COMMENT 'Date when the Investment Committee formally rendered its decision on this portfolio matter.',
    `decision_status` STRING COMMENT 'Current status of the Investment Committee decision on this portfolio matter.. Valid values are `approved|rejected|deferred|conditional|withdrawn`',
    `deferral_reason` STRING COMMENT 'Explanation for why the Investment Committee deferred the decision to a future meeting, if applicable.',
    `effective_date` DATE COMMENT 'Date from which the approved portfolio change becomes effective and operational.',
    `esg_framework` STRING COMMENT 'Name of the ESG framework or standard applied in evaluating this portfolio proposal.',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether the proposed portfolio change incorporates Environmental, Social, and Governance integration requirements.',
    `expected_return_impact_percent` DECIMAL(10,4) COMMENT 'Projected impact on portfolio expected return resulting from the proposed change, expressed as a percentage.',
    `expected_risk_impact_percent` DECIMAL(10,4) COMMENT 'Projected impact on portfolio risk level resulting from the proposed change, expressed as a percentage.',
    `expiry_date` DATE COMMENT 'Date when the Investment Committee approval expires and requires renewal or review, if applicable.',
    `im_document_reference` STRING COMMENT 'Reference identifier for the Investment Memorandum document supporting this Investment Committee submission.',
    `legal_review_status` STRING COMMENT 'Status of legal department review of the proposal prior to Investment Committee consideration.. Valid values are `approved|pending|rejected|not_required`',
    `meeting_date` DATE COMMENT 'Date of the Investment Committee meeting where this portfolio decision was reviewed.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this Investment Committee approval record was last modified or updated.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next Investment Committee review of this portfolio matter, if deferred or requiring periodic review.',
    `policy_exception_flag` BOOLEAN COMMENT 'Indicates whether this approval involves an exception to established investment policy guidelines.',
    `policy_exception_rationale` STRING COMMENT 'Detailed justification for requesting an exception to investment policy, if applicable.',
    `proposal_summary` STRING COMMENT 'Executive summary of the portfolio proposal outlining key objectives, rationale, and expected outcomes.',
    `proposal_title` STRING COMMENT 'Concise title or name of the portfolio proposal submitted for Investment Committee approval.',
    `proposed_benchmark_code` STRING COMMENT 'Code or identifier of the proposed new benchmark for the portfolio, if this approval involves a benchmark change.',
    `proposed_mandate_type` STRING COMMENT 'Type of investment mandate being proposed for approval, if this approval involves a new or modified mandate.',
    `proposed_saa_change_description` STRING COMMENT 'Detailed description of proposed changes to Strategic Asset Allocation targets, if applicable to this approval.',
    `proposed_taa_change_description` STRING COMMENT 'Detailed description of proposed Tactical Asset Allocation adjustments, if applicable to this approval.',
    `quorum_met_flag` BOOLEAN COMMENT 'Indicates whether the required quorum of Investment Committee members was present for the decision to be valid.',
    `rebalancing_threshold_lower_percent` DECIMAL(10,4) COMMENT 'Lower tolerance band threshold triggering portfolio rebalancing, if this approval involves rebalancing parameters.',
    `rebalancing_threshold_upper_percent` DECIMAL(10,4) COMMENT 'Upper tolerance band threshold triggering portfolio rebalancing, if this approval involves rebalancing parameters.',
    `rejection_reason` STRING COMMENT 'Detailed explanation for why the Investment Committee rejected the proposal, if applicable.',
    `risk_assessment_summary` STRING COMMENT 'Summary of risk analysis conducted on the proposed portfolio change, including impact on portfolio risk metrics and stress test results.',
    `strategic_rationale` STRING COMMENT 'Strategic justification for the proposed portfolio change, including alignment with long-term investment objectives and liability-driven investment strategy.',
    `submission_date` DATE COMMENT 'Date when the proposal was formally submitted to the Investment Committee for review.',
    `supporting_analysis_reference` STRING COMMENT 'Reference to supporting analytical materials, models, or research reports submitted with the proposal.',
    `tracking_error_impact_bps` DECIMAL(10,2) COMMENT 'Projected change in tracking error relative to benchmark resulting from the proposed portfolio change, measured in basis points.',
    `var_impact_percent` DECIMAL(10,4) COMMENT 'Projected change in portfolio Value at Risk resulting from the proposed change, expressed as a percentage.',
    `votes_abstained` BIGINT COMMENT 'Number of Investment Committee members who abstained from voting on the proposal.',
    `votes_against` BIGINT COMMENT 'Number of Investment Committee members who voted against the proposal.',
    `votes_in_favor` BIGINT COMMENT 'Number of Investment Committee members who voted in favor of the proposal.',
    `voting_outcome_summary` STRING COMMENT 'Summary of Investment Committee voting results including votes in favor, against, and abstentions.',
    CONSTRAINT pk_portfolio_ic_approval PRIMARY KEY(`portfolio_ic_approval_id`)
) COMMENT 'Investment Committee (IC) approval record for portfolio-level decisions including SAA changes, new mandate approvals, rebalancing authorizations, benchmark changes, and capital commitment approvals.';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`portfolio_allocation` (
    `portfolio_allocation_id` BIGINT COMMENT 'Primary key for the allocation association',
    `opportunity_id` BIGINT COMMENT 'Foreign key linking to the investment opportunity being allocated',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to the investment portfolio receiving the allocation',
    `percentage` DECIMAL(8,4) COMMENT 'Percentage of the total opportunity investment amount allocated to this portfolio. Sum of percentages across all portfolios for one opportunity should equal 100%.',
    `portfolio_allocation_date` DATE COMMENT 'Date when the allocation was formally approved and recorded. Used for tracking allocation timing relative to deal close.',
    `portfolio_allocation_status` STRING COMMENT 'Current lifecycle status of the allocation in the approval workflow. Tracks progression from proposal through IC approval to funding.',
    `rationale` STRING COMMENT 'Business justification for why this portfolio was selected to participate in this opportunity. Documents strategic fit, mandate alignment, and capacity considerations.',
    CONSTRAINT pk_portfolio_allocation PRIMARY KEY(`portfolio_allocation_id`)
) COMMENT 'This association product represents the Allocation event between portfolio and opportunity. It captures the formal assignment of capital from a specific investment portfolio to a specific investment opportunity, including the percentage of the deal';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`asset` (
    `asset_id` BIGINT COMMENT 'Primary key for asset',
    `performance_benchmark_id` BIGINT COMMENT 'Reference to the benchmark index used for performance comparison and attribution analysis.',
    `custodian_id` BIGINT COMMENT 'Reference to the custodian bank or institution holding the asset on behalf of the pension fund.',
    `equity_issuer_id` BIGINT COMMENT 'Reference to the entity that issued or originated the asset for counterparty risk management.',
    `acquisition_date` DATE COMMENT 'Date when the pension fund first acquired or invested in this asset.',
    `asset_class` STRING COMMENT 'Primary classification of the asset by broad investment category for portfolio construction and risk management.',
    `asset_sub_type` STRING COMMENT 'Granular classification providing detailed categorization within the asset type for specialized analysis.',
    `asset_type` STRING COMMENT 'Secondary classification within the asset class defining the specific instrument or investment structure type.',
    `bloomberg_ticker` STRING COMMENT 'Bloomberg terminal ticker symbol used for market data retrieval and trading operations.',
    `book_value` DECIMAL(18,4) COMMENT 'Historical cost basis or amortized cost of the asset for accounting and performance measurement purposes.',
    `carbon_intensity` DECIMAL(12,4) COMMENT 'Tonnes of CO2 equivalent emissions per million dollars of revenue for climate risk assessment.',
    `country_of_domicile` STRING COMMENT 'ISO 3166-1 alpha-3 country code where the asset issuer or entity is legally domiciled.',
    `country_of_risk` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the primary country of risk exposure for the asset.',
    `coupon_rate` DECIMAL(8,5) COMMENT 'Annual interest rate paid on fixed income securities expressed as a percentage of face value.',
    `credit_rating` STRING COMMENT 'Credit quality rating assigned by major rating agencies (S&P, Moodys, Fitch) for fixed income assets.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code representing the assets base or denomination currency.',
    `cusip` STRING COMMENT '9-character alphanumeric identifier for North American securities assigned by CUSIP Global Services.',
    `asset_description` STRING COMMENT 'Detailed narrative description of the asset including key terms and investment characteristics.',
    `duration_years` DECIMAL(8,4) COMMENT 'Measure of interest rate sensitivity indicating the percentage price change for a 1% change in yield.',
    `esg_score` DECIMAL(5,2) COMMENT 'Composite ESG rating score reflecting environmental, social, and governance risk factors.',
    `exchange_code` STRING COMMENT 'Market Identifier Code (MIC) of the primary exchange where the asset is traded per ISO 10383.',
    `fair_value_hierarchy` STRING COMMENT 'IFRS 13 fair value hierarchy classification based on observability of valuation inputs.',
    `identifier` STRING COMMENT 'Primary external business identifier used to reference the asset across systems and counterparties.',
    `inception_date` DATE COMMENT 'Date when the asset was first issued or created in the market.',
    `industry_group` STRING COMMENT 'GICS industry group classification providing more granular sector categorization for analysis.',
    `investment_strategy` STRING COMMENT 'Strategic classification indicating the investment approach or mandate under which the asset is held.',
    `is_hedged` BOOLEAN COMMENT 'Indicates whether the asset position has associated currency or interest rate hedging in place.',
    `is_listed` BOOLEAN COMMENT 'Indicates whether the asset is publicly listed and traded on a recognized exchange.',
    `isin` STRING COMMENT '12-character alphanumeric code that uniquely identifies a security per ISO 6166 standard.',
    `liquidity_classification` STRING COMMENT 'Classification of asset liquidity based on expected time to convert to cash without significant price impact.',
    `market_value` DECIMAL(18,4) COMMENT 'Current fair market value of the asset position in the base currency as of the latest valuation date.',
    `maturity_date` DATE COMMENT 'Date when the asset matures or expires, applicable to fixed income and derivative instruments.',
    `asset_name` STRING COMMENT 'Human-readable name or title of the asset as recognized in investment operations and reporting.',
    `notes` STRING COMMENT 'Free-form notes and comments from investment professionals regarding the asset.',
    `notional_value` DECIMAL(18,4) COMMENT 'Face value or notional principal amount for derivatives and fixed income instruments.',
    `ownership_percentage` DECIMAL(8,5) COMMENT 'Percentage of total ownership or equity stake held in the asset, relevant for private investments.',
    `regulatory_classification` STRING COMMENT 'Classification for regulatory reporting purposes such as Solvency II or pension fund regulations.',
    `sector` STRING COMMENT 'Global Industry Classification Standard (GICS) sector or equivalent industry classification for the asset.',
    `sedol` STRING COMMENT '7-character alphanumeric identifier for securities traded on the London Stock Exchange and other exchanges.',
    `asset_status` STRING COMMENT 'Current lifecycle state of the asset indicating its operational status within the portfolio.',
    `tax_lot_method` STRING COMMENT 'Cost basis method used for tax reporting when disposing of asset positions.',
    `unit_price` DECIMAL(18,6) COMMENT 'Current price per unit or share of the asset used for valuation calculations.',
    `units_held` DECIMAL(18,6) COMMENT 'Quantity of units, shares, or contracts held for the asset position.',
    `valuation_date` DATE COMMENT 'Date of the most recent valuation or pricing update for the asset.',
    `valuation_methodology` STRING COMMENT 'Method used to determine the fair value of the asset per accounting and regulatory standards.',
    `yield_to_maturity` DECIMAL(8,5) COMMENT 'Total return anticipated on a bond if held until maturity, expressed as an annual percentage rate.',
    CONSTRAINT pk_asset PRIMARY KEY(`asset_id`)
) COMMENT 'Master reference table for asset. Referenced by asset_id.';

CREATE OR REPLACE TABLE `asset_management`.`portfolio`.`tax_lot` (
    `tax_lot_id` BIGINT COMMENT 'Primary key for tax_lot',
    `cash_account_id` BIGINT COMMENT 'Reference to the investment account associated with this tax lot.',
    `custodian_id` BIGINT COMMENT 'Reference to the custodian bank or institution holding the assets for this tax lot.',
    `execution_id` BIGINT COMMENT 'Reference to the original trade transaction that created this tax lot.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio that holds this tax lot position.',
    `listed_security_id` BIGINT COMMENT 'Reference to the security or instrument held in this tax lot.',
    `accrued_income` DECIMAL(18,4) COMMENT 'Accrued but unpaid income such as interest or dividends associated with this tax lot.',
    `acquisition_date` DATE COMMENT 'Date when the position was originally acquired for tax lot tracking and holding period calculation.',
    `acquisition_price` DECIMAL(18,8) COMMENT 'Price per unit at which the position was originally acquired.',
    `adjusted_cost_basis` DECIMAL(18,4) COMMENT 'Cost basis adjusted for corporate actions, return of capital, wash sales, and other tax adjustments.',
    `amortization_method` STRING COMMENT 'Method used for amortizing bond premium or accreting discount for tax purposes.',
    `asset_class` STRING COMMENT 'Broad asset class category for the tax lot such as equity, fixed income, real estate, private equity, infrastructure, or natural resources.',
    `close_date` DATE COMMENT 'Date when the tax lot was fully closed through sale or other disposition.',
    `close_price` DECIMAL(18,8) COMMENT 'Price per unit at which the tax lot was closed or disposed.',
    `corporate_action_adjusted` BOOLEAN COMMENT 'Flag indicating whether this tax lot has been adjusted for corporate actions such as splits or mergers.',
    `cost_basis` DECIMAL(18,4) COMMENT 'Total original cost basis of the tax lot including acquisition price and transaction costs for tax reporting.',
    `cost_basis_method` STRING COMMENT 'Method used to calculate cost basis for tax purposes such as FIFO, LIFO, HIFO, specific identification, or average cost.',
    `coupon_rate` DECIMAL(8,5) COMMENT 'Annual coupon rate as a percentage for fixed income securities in this tax lot.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this tax lot record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the tax lot monetary values.',
    `holding_period_days` BIGINT COMMENT 'Number of days the position has been held from acquisition date for holding period determination.',
    `holding_period_type` STRING COMMENT 'Tax classification of holding period as short-term (one year or less) or long-term (more than one year).',
    `income_received` DECIMAL(18,4) COMMENT 'Total income received from this tax lot including dividends, interest, and distributions.',
    `local_currency_code` STRING COMMENT 'ISO 4217 currency code of the original transaction currency if different from base currency.',
    `lot_reference_number` STRING COMMENT 'External business reference number uniquely identifying this tax lot for reporting and reconciliation.',
    `lot_type` STRING COMMENT 'Classification of the tax lot position type indicating long, short, or covered positions.',
    `market_value` DECIMAL(18,4) COMMENT 'Current market value of the remaining position in the tax lot based on latest pricing.',
    `maturity_date` DATE COMMENT 'Maturity date for fixed income securities held in this tax lot.',
    `original_units` DECIMAL(18,6) COMMENT 'Original number of units, shares, or par value acquired when the tax lot was opened.',
    `realized_gain_loss` DECIMAL(18,4) COMMENT 'Total realized gain or loss from disposed units in this tax lot.',
    `settlement_date` DATE COMMENT 'Date when the acquisition trade settled and ownership was legally transferred.',
    `source_system` STRING COMMENT 'Name of the operational system from which this tax lot record originated.',
    `tax_lot_status` STRING COMMENT 'Current lifecycle status of the tax lot indicating whether the position is open, closed, or partially disposed.',
    `tax_jurisdiction` STRING COMMENT 'Country or jurisdiction code governing the tax treatment of this lot.',
    `trade_date` DATE COMMENT 'Date when the acquisition trade was executed in the market.',
    `transaction_costs` DECIMAL(18,4) COMMENT 'Total transaction costs including commissions and fees incurred when acquiring this tax lot.',
    `units_disposed` DECIMAL(18,6) COMMENT 'Total number of units that have been sold or disposed from this tax lot.',
    `units_held` DECIMAL(18,6) COMMENT 'Current number of units, shares, or par value remaining in the tax lot after any partial dispositions.',
    `unrealized_gain_loss` DECIMAL(18,4) COMMENT 'Difference between current market value and adjusted cost basis representing unrealized profit or loss.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this tax lot record was last modified.',
    `wash_sale_adjustment` DECIMAL(18,4) COMMENT 'Amount of disallowed loss added to cost basis due to wash sale rules.',
    `wash_sale_indicator` BOOLEAN COMMENT 'Flag indicating whether this tax lot is subject to wash sale rules disallowing loss deduction.',
    `withholding_tax` DECIMAL(18,4) COMMENT 'Total withholding tax deducted from income payments on this tax lot.',
    `yield_at_acquisition` DECIMAL(8,5) COMMENT 'Yield to maturity or yield at the time of acquisition for fixed income tax lots.',
    CONSTRAINT pk_tax_lot PRIMARY KEY(`tax_lot_id`)
) COMMENT 'Master reference table for tax_lot. Referenced by tax_lot_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ADD CONSTRAINT `fk_portfolio_hierarchy_child_portfolio_id` FOREIGN KEY (`child_portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ADD CONSTRAINT `fk_portfolio_hierarchy_parent_portfolio_id` FOREIGN KEY (`parent_portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ADD CONSTRAINT `fk_portfolio_hierarchy_portfolio_benchmark_id` FOREIGN KEY (`portfolio_benchmark_id`) REFERENCES `asset_management`.`portfolio`.`portfolio_benchmark`(`portfolio_benchmark_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ADD CONSTRAINT `fk_portfolio_portfolio_mandate_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ADD CONSTRAINT `fk_portfolio_saa_target_portfolio_benchmark_id` FOREIGN KEY (`portfolio_benchmark_id`) REFERENCES `asset_management`.`portfolio`.`portfolio_benchmark`(`portfolio_benchmark_id`);
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ADD CONSTRAINT `fk_portfolio_saa_target_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ADD CONSTRAINT `fk_portfolio_taa_position_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ADD CONSTRAINT `fk_portfolio_taa_position_saa_target_id` FOREIGN KEY (`saa_target_id`) REFERENCES `asset_management`.`portfolio`.`saa_target`(`saa_target_id`);
ALTER TABLE `asset_management`.`portfolio`.`holding` ADD CONSTRAINT `fk_portfolio_holding_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`holding` ADD CONSTRAINT `fk_portfolio_holding_sleeve_id` FOREIGN KEY (`sleeve_id`) REFERENCES `asset_management`.`portfolio`.`sleeve`(`sleeve_id`);
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ADD CONSTRAINT `fk_portfolio_holding_snapshot_portfolio_benchmark_id` FOREIGN KEY (`portfolio_benchmark_id`) REFERENCES `asset_management`.`portfolio`.`portfolio_benchmark`(`portfolio_benchmark_id`);
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ADD CONSTRAINT `fk_portfolio_holding_snapshot_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ADD CONSTRAINT `fk_portfolio_portfolio_benchmark_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ADD CONSTRAINT `fk_portfolio_portfolio_benchmark_superseded_by_benchmark_portfolio_benchmark_id` FOREIGN KEY (`superseded_by_benchmark_portfolio_benchmark_id`) REFERENCES `asset_management`.`portfolio`.`portfolio_benchmark`(`portfolio_benchmark_id`);
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ADD CONSTRAINT `fk_portfolio_benchmark_assignment_portfolio_benchmark_id` FOREIGN KEY (`portfolio_benchmark_id`) REFERENCES `asset_management`.`portfolio`.`portfolio_benchmark`(`portfolio_benchmark_id`);
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ADD CONSTRAINT `fk_portfolio_benchmark_assignment_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ADD CONSTRAINT `fk_portfolio_benchmark_assignment_superseded_by_assignment_benchmark_assignment_id` FOREIGN KEY (`superseded_by_assignment_benchmark_assignment_id`) REFERENCES `asset_management`.`portfolio`.`benchmark_assignment`(`benchmark_assignment_id`);
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ADD CONSTRAINT `fk_portfolio_asset_class_weight_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ADD CONSTRAINT `fk_portfolio_rebalancing_event_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`constraint` ADD CONSTRAINT `fk_portfolio_constraint_portfolio_benchmark_id` FOREIGN KEY (`portfolio_benchmark_id`) REFERENCES `asset_management`.`portfolio`.`portfolio_benchmark`(`portfolio_benchmark_id`);
ALTER TABLE `asset_management`.`portfolio`.`constraint` ADD CONSTRAINT `fk_portfolio_constraint_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`constraint` ADD CONSTRAINT `fk_portfolio_constraint_portfolio_mandate_id` FOREIGN KEY (`portfolio_mandate_id`) REFERENCES `asset_management`.`portfolio`.`portfolio_mandate`(`portfolio_mandate_id`);
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ADD CONSTRAINT `fk_portfolio_constraint_breach_constraint_id` FOREIGN KEY (`constraint_id`) REFERENCES `asset_management`.`portfolio`.`constraint`(`constraint_id`);
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ADD CONSTRAINT `fk_portfolio_constraint_breach_holding_id` FOREIGN KEY (`holding_id`) REFERENCES `asset_management`.`portfolio`.`holding`(`holding_id`);
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ADD CONSTRAINT `fk_portfolio_constraint_breach_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ADD CONSTRAINT `fk_portfolio_constraint_breach_portfolio_mandate_id` FOREIGN KEY (`portfolio_mandate_id`) REFERENCES `asset_management`.`portfolio`.`portfolio_mandate`(`portfolio_mandate_id`);
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ADD CONSTRAINT `fk_portfolio_constraint_breach_position_holding_id` FOREIGN KEY (`position_holding_id`) REFERENCES `asset_management`.`portfolio`.`holding`(`holding_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ADD CONSTRAINT `fk_portfolio_portfolio_composite_membership_gips_composite_id` FOREIGN KEY (`gips_composite_id`) REFERENCES `asset_management`.`portfolio`.`gips_composite`(`gips_composite_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ADD CONSTRAINT `fk_portfolio_portfolio_composite_membership_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ADD CONSTRAINT `fk_portfolio_portfolio_capital_commitment_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ADD CONSTRAINT `fk_portfolio_portfolio_nav_record_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ADD CONSTRAINT `fk_portfolio_portfolio_cash_flow_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ADD CONSTRAINT `fk_portfolio_mandate_history_mandate_new_benchmark_portfolio_benchmark_id` FOREIGN KEY (`mandate_new_benchmark_portfolio_benchmark_id`) REFERENCES `asset_management`.`portfolio`.`portfolio_benchmark`(`portfolio_benchmark_id`);
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ADD CONSTRAINT `fk_portfolio_mandate_history_mandate_portfolio_benchmark_id` FOREIGN KEY (`mandate_portfolio_benchmark_id`) REFERENCES `asset_management`.`portfolio`.`portfolio_benchmark`(`portfolio_benchmark_id`);
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ADD CONSTRAINT `fk_portfolio_mandate_history_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ADD CONSTRAINT `fk_portfolio_mandate_history_portfolio_mandate_id` FOREIGN KEY (`portfolio_mandate_id`) REFERENCES `asset_management`.`portfolio`.`portfolio_mandate`(`portfolio_mandate_id`);
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ADD CONSTRAINT `fk_portfolio_mandate_history_superseded_by_history_mandate_history_id` FOREIGN KEY (`superseded_by_history_mandate_history_id`) REFERENCES `asset_management`.`portfolio`.`mandate_history`(`mandate_history_id`);
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ADD CONSTRAINT `fk_portfolio_sleeve_portfolio_benchmark_id` FOREIGN KEY (`portfolio_benchmark_id`) REFERENCES `asset_management`.`portfolio`.`portfolio_benchmark`(`portfolio_benchmark_id`);
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ADD CONSTRAINT `fk_portfolio_sleeve_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ADD CONSTRAINT `fk_portfolio_currency_exposure_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ADD CONSTRAINT `fk_portfolio_liquidity_bucket_holding_snapshot_id` FOREIGN KEY (`holding_snapshot_id`) REFERENCES `asset_management`.`portfolio`.`holding_snapshot`(`holding_snapshot_id`);
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ADD CONSTRAINT `fk_portfolio_liquidity_bucket_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ADD CONSTRAINT `fk_portfolio_portfolio_ic_approval_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_allocation` ADD CONSTRAINT `fk_portfolio_portfolio_allocation_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`portfolio`.`tax_lot` ADD CONSTRAINT `fk_portfolio_tax_lot_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`portfolio`.`portfolio` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` SET TAGS ('dbx_subdomain' = 'portfolio_structure');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `actuarial_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `alm_model_id` SET TAGS ('dbx_business_glossary_term' = 'Alm Model Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `asset_class_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Outlook Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `capital_market_assumption_id` SET TAGS ('dbx_business_glossary_term' = 'Capital Market Assumption Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `composite_id` SET TAGS ('dbx_business_glossary_term' = 'Composite Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `country_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Country Outlook Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `created_by_actor_id` SET TAGS ('dbx_business_glossary_term' = 'Created By Actor Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `created_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Created By User Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `created_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `created_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Modified By User Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `equity_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Manager Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `ldi_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Ldi Strategy Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `legal_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `macro_model_run_id` SET TAGS ('dbx_business_glossary_term' = 'Macro Model Run Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `manager_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Manager Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `modified_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Modified By User Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `modified_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `modified_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `sector_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Sector Outlook Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `valuation_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_business_glossary_term' = 'Accounting Basis');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `accounting_basis` SET TAGS ('dbx_value_regex' = 'ifrs|gaap|local_gaap|statutory');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `asset_class_scope` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Scope');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `base_currency` SET TAGS ('dbx_business_glossary_term' = 'Base Currency');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `base_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `closure_date` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Closure Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `portfolio_code` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Code');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `portfolio_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4,12}$');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `data_classification` SET TAGS ('dbx_business_glossary_term' = 'Data Classification Level');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `data_classification` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `portfolio_description` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Description');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `esg_framework` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Framework');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `esg_framework` SET TAGS ('dbx_value_regex' = 'pri|tcfd|sfdr|ungc|sdg|none');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `exclusion_list_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List Applied Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `gips_compliant_flag` SET TAGS ('dbx_business_glossary_term' = 'Global Investment Performance Standards (GIPS) Compliant Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Inception Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `investment_committee_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `investment_policy_version` SET TAGS ('dbx_business_glossary_term' = 'Investment Policy Statement (IPS) Version');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `investment_policy_version` SET TAGS ('dbx_value_regex' = '^[0-9]{1,3}.[0-9]{1,2}$');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `last_rebalance_date` SET TAGS ('dbx_business_glossary_term' = 'Last Rebalance Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `leverage_limit_percent` SET TAGS ('dbx_business_glossary_term' = 'Leverage Limit Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `liquidity_requirement_days` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Requirement in Days');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `mandate_type` SET TAGS ('dbx_business_glossary_term' = 'Mandate Type');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `mandate_type` SET TAGS ('dbx_value_regex' = 'saa|taa|ldi|absolute_return|liability_matching|total_return');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `portfolio_name` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Name');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `next_rebalance_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Rebalance Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `performance_calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Performance Calculation Method');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `performance_calculation_method` SET TAGS ('dbx_value_regex' = 'twr|mwr|irr|simple');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `portfolio_status` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Status');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `portfolio_status` SET TAGS ('dbx_value_regex' = 'active|suspended|closed|liquidating|pending_approval');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `portfolio_type` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Type');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `portfolio_type` SET TAGS ('dbx_value_regex' = 'strategic|tactical|overlay|benchmark|composite|shadow');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Frequency');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `regulatory_classification` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Classification');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annual');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `risk_tolerance_level` SET TAGS ('dbx_business_glossary_term' = 'Risk Tolerance Level');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `risk_tolerance_level` SET TAGS ('dbx_value_regex' = 'conservative|moderate|balanced|growth|aggressive');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `target_return_percent` SET TAGS ('dbx_business_glossary_term' = 'Target Return Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `tax_status` SET TAGS ('dbx_business_glossary_term' = 'Tax Status');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `tax_status` SET TAGS ('dbx_value_regex' = 'tax_exempt|taxable|tax_deferred|foreign_tax_credit');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `tracking_error_limit_bps` SET TAGS ('dbx_business_glossary_term' = 'Tracking Error Limit in Basis Points (bps)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `valuation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Valuation Frequency');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `valuation_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly');
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ALTER COLUMN `var_limit_percent` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Limit Percentage');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` SET TAGS ('dbx_subdomain' = 'portfolio_structure');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `hierarchy_id` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `child_portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Child Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `parent_portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `portfolio_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `allocation_method` SET TAGS ('dbx_business_glossary_term' = 'Allocation Method');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `allocation_method` SET TAGS ('dbx_value_regex' = 'market_value|notional|risk_weighted|equal_weighted|custom');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `allocation_weight` SET TAGS ('dbx_business_glossary_term' = 'Allocation Weight');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `approval_authority` SET TAGS ('dbx_business_glossary_term' = 'Approval Authority');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `consolidation_rule` SET TAGS ('dbx_business_glossary_term' = 'Consolidation Rule');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `consolidation_rule` SET TAGS ('dbx_value_regex' = 'full_consolidation|proportional|look_through|exclusion');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `constraint_description` SET TAGS ('dbx_business_glossary_term' = 'Constraint Description');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `constraint_type` SET TAGS ('dbx_business_glossary_term' = 'Constraint Type');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `constraint_type` SET TAGS ('dbx_value_regex' = 'regulatory|policy|mandate|risk|liquidity|none');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `hierarchy_type` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Type');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `hierarchy_type` SET TAGS ('dbx_value_regex' = 'composite|sleeve|sub_portfolio|fund_of_funds|mandate|asset_class');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `ic_approval_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Reference');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active Flag');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `last_rebalance_date` SET TAGS ('dbx_business_glossary_term' = 'Last Rebalance Date');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `hierarchy_level` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Level');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `next_rebalance_date` SET TAGS ('dbx_business_glossary_term' = 'Next Rebalance Date');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `path` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Path');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `performance_attribution_flag` SET TAGS ('dbx_business_glossary_term' = 'Performance Attribution Flag');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Frequency');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `relationship_name` SET TAGS ('dbx_business_glossary_term' = 'Relationship Name');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `relationship_status` SET TAGS ('dbx_business_glossary_term' = 'Relationship Status');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `relationship_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|suspended|terminated');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `reporting_inclusion_flag` SET TAGS ('dbx_business_glossary_term' = 'Reporting Inclusion Flag');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `saa_target_weight` SET TAGS ('dbx_business_glossary_term' = 'Strategic Asset Allocation (SAA) Target Weight');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `sort_order` SET TAGS ('dbx_business_glossary_term' = 'Sort Order');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `taa_adjustment` SET TAGS ('dbx_business_glossary_term' = 'Tactical Asset Allocation (TAA) Adjustment');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `tolerance_band_lower` SET TAGS ('dbx_business_glossary_term' = 'Tolerance Band Lower Limit');
ALTER TABLE `asset_management`.`portfolio`.`hierarchy` ALTER COLUMN `tolerance_band_upper` SET TAGS ('dbx_business_glossary_term' = 'Tolerance Band Upper Limit');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` SET TAGS ('dbx_subdomain' = 'portfolio_structure');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `portfolio_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Mandate Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `performance_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `benchmark_index_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Manager Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `exclusion_list_id` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Manager Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `legal_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Mandate Approved Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `base_currency` SET TAGS ('dbx_business_glossary_term' = 'Base Currency');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `base_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `concentration_limit_percent` SET TAGS ('dbx_business_glossary_term' = 'Single Issuer Concentration Limit Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `currency_hedging_policy` SET TAGS ('dbx_business_glossary_term' = 'Currency Hedging Policy');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `currency_hedging_policy` SET TAGS ('dbx_value_regex' = 'fully_hedged|partially_hedged|unhedged|dynamic');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `derivatives_permitted_flag` SET TAGS ('dbx_business_glossary_term' = 'Derivatives Permitted Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `document_uri` SET TAGS ('dbx_business_glossary_term' = 'Mandate Document Uniform Resource Identifier (URI)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `document_uri` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `esg_integration_level` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Level');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `esg_integration_level` SET TAGS ('dbx_value_regex' = 'none|basic|integrated|thematic|impact');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `fee_structure` SET TAGS ('dbx_business_glossary_term' = 'Fee Structure');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `fee_structure` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `geographic_restrictions` SET TAGS ('dbx_business_glossary_term' = 'Geographic Investment Restrictions');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `high_water_mark_flag` SET TAGS ('dbx_business_glossary_term' = 'High Water Mark Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Mandate Inception Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `investment_committee_code` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `investment_objective` SET TAGS ('dbx_business_glossary_term' = 'Investment Objective');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `leverage_permitted_flag` SET TAGS ('dbx_business_glossary_term' = 'Leverage Permitted Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `liquidity_requirement_days` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Requirement in Days');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `management_fee_bps` SET TAGS ('dbx_business_glossary_term' = 'Management Fee in Basis Points (bps)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `management_fee_bps` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `mandate_code` SET TAGS ('dbx_business_glossary_term' = 'Mandate Code');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `mandate_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{6,20}$');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `mandate_name` SET TAGS ('dbx_business_glossary_term' = 'Mandate Name');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `mandate_status` SET TAGS ('dbx_business_glossary_term' = 'Mandate Status');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `mandate_status` SET TAGS ('dbx_value_regex' = 'active|suspended|terminated|pending_approval|under_review');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `mandate_type` SET TAGS ('dbx_business_glossary_term' = 'Mandate Type');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `mandate_type` SET TAGS ('dbx_value_regex' = 'internal|sma|lp_mandate|co_investment|fund_of_funds|direct_investment');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `max_leverage_ratio` SET TAGS ('dbx_business_glossary_term' = 'Maximum Leverage Ratio');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `min_credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Minimum Credit Rating');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `min_credit_rating` SET TAGS ('dbx_value_regex' = '^(AAA|AA|A|BBB|BB|B|CCC|CC|C|D)[+-]?$');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Review Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `performance_fee_percent` SET TAGS ('dbx_business_glossary_term' = 'Performance Fee Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `performance_fee_percent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `permitted_asset_classes` SET TAGS ('dbx_business_glossary_term' = 'Permitted Asset Classes');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Frequency');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `regulatory_classification` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Classification');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Performance Reporting Frequency');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `risk_tolerance` SET TAGS ('dbx_business_glossary_term' = 'Risk Tolerance Level');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `risk_tolerance` SET TAGS ('dbx_value_regex' = 'conservative|moderate|balanced|aggressive|very_aggressive');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `sector_limit_percent` SET TAGS ('dbx_business_glossary_term' = 'Sector Concentration Limit Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `short_selling_permitted_flag` SET TAGS ('dbx_business_glossary_term' = 'Short Selling Permitted Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `target_return_percent` SET TAGS ('dbx_business_glossary_term' = 'Target Return Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Mandate Termination Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `tracking_error_limit_bps` SET TAGS ('dbx_business_glossary_term' = 'Tracking Error Limit in Basis Points (bps)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ALTER COLUMN `var_limit_percent` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Limit Percentage');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` SET TAGS ('dbx_subdomain' = 'allocation_strategy');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `saa_target_id` SET TAGS ('dbx_business_glossary_term' = 'Strategic Asset Allocation (SAA) Target ID');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `credit_benchmark_index_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Benchmark Index Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Created By User ID');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `last_modified_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User ID');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `last_modified_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `last_modified_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `portfolio_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark ID');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `saa_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Created By User ID');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `saa_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `saa_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `saa_last_modified_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User ID');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `saa_last_modified_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `saa_last_modified_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `actual_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Actual Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `approval_authority` SET TAGS ('dbx_business_glossary_term' = 'Approval Authority');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `asset_class_code` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Code');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `asset_class_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `asset_class_name` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Name');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `correlation_group_code` SET TAGS ('dbx_business_glossary_term' = 'Correlation Group Code');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `correlation_group_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `exclusion_policy_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Policy Applied Flag');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `expected_return_percent` SET TAGS ('dbx_business_glossary_term' = 'Expected Return Percentage');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `expected_volatility_percent` SET TAGS ('dbx_business_glossary_term' = 'Expected Volatility Percentage');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `geographic_constraint_code` SET TAGS ('dbx_business_glossary_term' = 'Geographic Constraint Code');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `geographic_constraint_code` SET TAGS ('dbx_value_regex' = 'GLOBAL|DEVELOPED|EMERGING|REGIONAL|DOMESTIC');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `liquidity_classification` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Classification');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `liquidity_classification` SET TAGS ('dbx_value_regex' = 'LIQUID|SEMI_LIQUID|ILLIQUID');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `maximum_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Maximum Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `minimum_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Minimum Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `policy_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Policy Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `rationale_notes` SET TAGS ('dbx_business_glossary_term' = 'Rationale Notes');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `rebalancing_threshold_percent` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Threshold Percentage');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `review_frequency_code` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency Code');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `review_frequency_code` SET TAGS ('dbx_value_regex' = 'ANNUAL|SEMI_ANNUAL|QUARTERLY|AD_HOC');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `saa_target_status` SET TAGS ('dbx_business_glossary_term' = 'Strategic Asset Allocation (SAA) Target Status');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `saa_target_status` SET TAGS ('dbx_value_regex' = 'ACTIVE|INACTIVE|PENDING|SUPERSEDED');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `sub_asset_class_code` SET TAGS ('dbx_business_glossary_term' = 'Sub-Asset Class Code');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `sub_asset_class_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,30}$');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `sub_asset_class_name` SET TAGS ('dbx_business_glossary_term' = 'Sub-Asset Class Name');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `tactical_adjustment_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Tactical Adjustment Allowed Flag');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `tactical_adjustment_limit_percent` SET TAGS ('dbx_business_glossary_term' = 'Tactical Adjustment Limit Percentage');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `target_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Target Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `target_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ALTER COLUMN `weight_drift_percent` SET TAGS ('dbx_business_glossary_term' = 'Weight Drift Percentage');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` SET TAGS ('dbx_subdomain' = 'allocation_strategy');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `taa_position_id` SET TAGS ('dbx_business_glossary_term' = 'Tactical Asset Allocation (TAA) Position ID');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `saa_target_id` SET TAGS ('dbx_business_glossary_term' = 'Saa Target Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `actual_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Amount');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `actual_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `actual_deviation_percent` SET TAGS ('dbx_business_glossary_term' = 'Actual Deviation Percent');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `actual_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Actual Weight Percent');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `asset_class_code` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Code');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `asset_class_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `asset_class_name` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Name');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `benchmark_code` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Code');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `benchmark_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,30}$');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `benchmark_name` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Name');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `expected_return_percent` SET TAGS ('dbx_business_glossary_term' = 'Expected Return Percent');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `expected_volatility_percent` SET TAGS ('dbx_business_glossary_term' = 'Expected Volatility Percent');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `liquidity_classification` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Classification');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `liquidity_classification` SET TAGS ('dbx_value_regex' = 'highly_liquid|liquid|semi_liquid|illiquid');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `position_date` SET TAGS ('dbx_business_glossary_term' = 'Position Date');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `rebalancing_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Required Flag');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `rebalancing_threshold_lower_percent` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Threshold Lower Percent');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `rebalancing_threshold_upper_percent` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Threshold Upper Percent');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `risk_budget_percent` SET TAGS ('dbx_business_glossary_term' = 'Risk Budget Percent');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `saa_target_amount` SET TAGS ('dbx_business_glossary_term' = 'Strategic Asset Allocation (SAA) Target Amount');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `saa_target_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `saa_target_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Strategic Asset Allocation (SAA) Target Weight Percent');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `sub_asset_class_code` SET TAGS ('dbx_business_glossary_term' = 'Sub-Asset Class Code');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `sub_asset_class_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,30}$');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `sub_asset_class_name` SET TAGS ('dbx_business_glossary_term' = 'Sub-Asset Class Name');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `taa_decision_date` SET TAGS ('dbx_business_glossary_term' = 'Tactical Asset Allocation (TAA) Decision Date');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `taa_deviation_percent` SET TAGS ('dbx_business_glossary_term' = 'Tactical Asset Allocation (TAA) Deviation Percent');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `taa_horizon_months` SET TAGS ('dbx_business_glossary_term' = 'Tactical Asset Allocation (TAA) Horizon Months');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `taa_position_status` SET TAGS ('dbx_business_glossary_term' = 'Status');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `taa_position_status` SET TAGS ('dbx_value_regex' = 'active|under_review|suspended|closed');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `taa_rationale` SET TAGS ('dbx_business_glossary_term' = 'Tactical Asset Allocation (TAA) Rationale');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `taa_review_date` SET TAGS ('dbx_business_glossary_term' = 'Tactical Asset Allocation (TAA) Review Date');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `taa_target_amount` SET TAGS ('dbx_business_glossary_term' = 'Tactical Asset Allocation (TAA) Target Amount');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `taa_target_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`taa_position` ALTER COLUMN `taa_target_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Tactical Asset Allocation (TAA) Target Weight Percent');
ALTER TABLE `asset_management`.`portfolio`.`holding` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`portfolio`.`holding` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`holding` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`holding` SET TAGS ('dbx_subdomain' = 'position_valuation');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `holding_id` SET TAGS ('dbx_business_glossary_term' = 'Holding Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `fair_value_hierarchy_id` SET TAGS ('dbx_business_glossary_term' = 'Fair Value Hierarchy Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `infra_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Infra Asset Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `sleeve_id` SET TAGS ('dbx_business_glossary_term' = 'Sleeve Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `account_number` SET TAGS ('dbx_business_glossary_term' = 'Custodian Account Number');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `accrued_income_base` SET TAGS ('dbx_business_glossary_term' = 'Accrued Income Base Currency');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `accrued_income_local` SET TAGS ('dbx_business_glossary_term' = 'Accrued Income Local Currency');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `benchmark_weight` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `collateral_flag` SET TAGS ('dbx_business_glossary_term' = 'Collateral Pledge Flag');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Commitment Amount');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `cost_base` SET TAGS ('dbx_business_glossary_term' = 'Cost Base Currency');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `cost_local` SET TAGS ('dbx_business_glossary_term' = 'Cost Local Currency');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `exclusion_flag` SET TAGS ('dbx_business_glossary_term' = 'ESG Exclusion Flag');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `holding_status` SET TAGS ('dbx_business_glossary_term' = 'Holding Status');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `holding_status` SET TAGS ('dbx_value_regex' = 'active|closed|pending_settlement|suspended|restricted');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `income_type` SET TAGS ('dbx_business_glossary_term' = 'Income Type');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `income_type` SET TAGS ('dbx_value_regex' = 'dividend|interest|distribution|capital_gain|other');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `investment_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Type');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `investment_type` SET TAGS ('dbx_value_regex' = 'direct|co_investment|fund_investment|secondary');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `last_valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Valuation Date');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `lending_flag` SET TAGS ('dbx_business_glossary_term' = 'Securities Lending Flag');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `liquidity_classification` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Classification');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `liquidity_classification` SET TAGS ('dbx_value_regex' = 'liquid|semi_liquid|illiquid|locked_up');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `local_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Local Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `local_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `market_value_base` SET TAGS ('dbx_business_glossary_term' = 'Market Value Base Currency');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `market_value_local` SET TAGS ('dbx_business_glossary_term' = 'Market Value Local Currency');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `portfolio_weight` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `position_date` SET TAGS ('dbx_business_glossary_term' = 'Position Date');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Holding Quantity');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `rebalancing_flag` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Flag');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `restricted_flag` SET TAGS ('dbx_business_glossary_term' = 'Restricted Holding Flag');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `restriction_end_date` SET TAGS ('dbx_business_glossary_term' = 'Restriction End Date');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `sub_asset_class` SET TAGS ('dbx_business_glossary_term' = 'Sub-Asset Class');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `tax_lot_method` SET TAGS ('dbx_business_glossary_term' = 'Tax Lot Accounting Method');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `tax_lot_method` SET TAGS ('dbx_value_regex' = 'fifo|lifo|average_cost|specific_identification');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `trade_date` SET TAGS ('dbx_business_glossary_term' = 'Trade Date');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `unfunded_commitment` SET TAGS ('dbx_business_glossary_term' = 'Unfunded Commitment');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `unit_cost_base` SET TAGS ('dbx_business_glossary_term' = 'Unit Cost Base');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `unit_cost_local` SET TAGS ('dbx_business_glossary_term' = 'Unit Cost Local Currency');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `unrealized_gain_loss_base` SET TAGS ('dbx_business_glossary_term' = 'Unrealized Gain or Loss Base Currency');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `unrealized_gain_loss_local` SET TAGS ('dbx_business_glossary_term' = 'Unrealized Gain or Loss Local Currency');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `valuation_level` SET TAGS ('dbx_business_glossary_term' = 'Fair Value Hierarchy Level');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `valuation_level` SET TAGS ('dbx_value_regex' = 'level_1|level_2|level_3');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `valuation_source` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `valuation_source` SET TAGS ('dbx_value_regex' = 'market_price|broker_quote|model_valuation|administrator_nav|appraisal');
ALTER TABLE `asset_management`.`portfolio`.`holding` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` SET TAGS ('dbx_subdomain' = 'position_valuation');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `holding_snapshot_id` SET TAGS ('dbx_business_glossary_term' = 'Holding Snapshot Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `infra_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Infra Asset Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `market_price_snapshot_id` SET TAGS ('dbx_business_glossary_term' = 'Market Price Snapshot Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `portfolio_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `account_number` SET TAGS ('dbx_business_glossary_term' = 'Custodian Account Number');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `accrued_income_base_currency` SET TAGS ('dbx_business_glossary_term' = 'Accrued Income in Base Currency');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `carbon_intensity` SET TAGS ('dbx_business_glossary_term' = 'Carbon Intensity');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `commitment_amount_base_currency` SET TAGS ('dbx_business_glossary_term' = 'Commitment Amount in Base Currency');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_business_glossary_term' = 'Country of Risk');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `coupon_rate` SET TAGS ('dbx_business_glossary_term' = 'Coupon Rate');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{9}$');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `duration_years` SET TAGS ('dbx_business_glossary_term' = 'Duration in Years');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `fair_value_level` SET TAGS ('dbx_business_glossary_term' = 'Fair Value Hierarchy Level');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `fair_value_level` SET TAGS ('dbx_value_regex' = 'level_1|level_2|level_3');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `holding_status` SET TAGS ('dbx_business_glossary_term' = 'Holding Status');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `holding_status` SET TAGS ('dbx_value_regex' = 'active|closed|pending_settlement|suspended|matured|called');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Name');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `liquidity_classification` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Classification');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `liquidity_classification` SET TAGS ('dbx_value_regex' = 'liquid|semi_liquid|illiquid');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `market_price` SET TAGS ('dbx_business_glossary_term' = 'Market Price');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `market_value_base_currency` SET TAGS ('dbx_business_glossary_term' = 'Market Value in Base Currency');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Holding Quantity');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `sector_code` SET TAGS ('dbx_business_glossary_term' = 'Sector Code');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `security_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Security Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `security_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `security_name` SET TAGS ('dbx_business_glossary_term' = 'Security Name');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `snapshot_date` SET TAGS ('dbx_business_glossary_term' = 'Snapshot Date');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `snapshot_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Snapshot Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `ticker_symbol` SET TAGS ('dbx_business_glossary_term' = 'Ticker Symbol');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `total_cost_base_currency` SET TAGS ('dbx_business_glossary_term' = 'Total Cost in Base Currency');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `unfunded_commitment_base_currency` SET TAGS ('dbx_business_glossary_term' = 'Unfunded Commitment in Base Currency');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `unit_cost_base_currency` SET TAGS ('dbx_business_glossary_term' = 'Unit Cost in Base Currency');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `unrealized_gain_loss_base_currency` SET TAGS ('dbx_business_glossary_term' = 'Unrealized Gain or Loss in Base Currency');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `valuation_source` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `valuation_source` SET TAGS ('dbx_value_regex' = 'market_price|broker_quote|model|appraisal|nav');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ALTER COLUMN `ytm` SET TAGS ('dbx_business_glossary_term' = 'Yield to Maturity (YTM)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` SET TAGS ('dbx_subdomain' = 'compliance_benchmarking');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `portfolio_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Benchmark Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `superseded_by_benchmark_portfolio_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Benchmark Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `assignment_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Effective Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `assignment_end_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment End Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `assignment_reason` SET TAGS ('dbx_business_glossary_term' = 'Assignment Reason');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Assignment Status');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|superseded');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `benchmark_category` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Category');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `benchmark_code` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Code');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `benchmark_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{3,20}$');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `benchmark_description` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Description');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `benchmark_name` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Name');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `benchmark_type` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Type');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `benchmark_type` SET TAGS ('dbx_value_regex' = 'market_index|custom_blend|liability_benchmark|peer_group|absolute_return');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Currency');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `custom_blend_definition` SET TAGS ('dbx_business_glossary_term' = 'Custom Blend Definition');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `geography` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Geography');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `ic_approval_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Reference');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `identifier` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Identifier');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Inception Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `is_primary_benchmark` SET TAGS ('dbx_business_glossary_term' = 'Is Primary Benchmark Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `liability_matching_flag` SET TAGS ('dbx_business_glossary_term' = 'Liability Matching Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `performance_fee_benchmark_flag` SET TAGS ('dbx_business_glossary_term' = 'Performance Fee Benchmark Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `provider` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Provider');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Frequency');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `return_calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Return Calculation Method');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `return_calculation_method` SET TAGS ('dbx_value_regex' = 'time_weighted|money_weighted|total_return|price_return');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `tracking_error_target_bps` SET TAGS ('dbx_business_glossary_term' = 'Tracking Error Target Basis Points (bps)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Version');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `volatility_percent` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Volatility Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_benchmark` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` SET TAGS ('dbx_subdomain' = 'compliance_benchmarking');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `benchmark_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Assignment Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `portfolio_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `superseded_by_assignment_benchmark_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Assignment Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `assignment_notes` SET TAGS ('dbx_business_glossary_term' = 'Assignment Notes');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `assignment_reason` SET TAGS ('dbx_business_glossary_term' = 'Assignment Reason');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `assignment_source` SET TAGS ('dbx_business_glossary_term' = 'Assignment Source');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `assignment_source` SET TAGS ('dbx_value_regex' = 'investment_committee|portfolio_manager|risk_team|compliance|client_mandate|system_default');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Assignment Status');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|suspended|terminated');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Assignment Type');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_value_regex' = 'primary|secondary|risk|liability|composite|custom');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `assignment_weight` SET TAGS ('dbx_business_glossary_term' = 'Assignment Weight');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `currency_hedging_flag` SET TAGS ('dbx_business_glossary_term' = 'Currency Hedging Flag');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `custom_benchmark_flag` SET TAGS ('dbx_business_glossary_term' = 'Custom Benchmark Flag');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `effective_to_date` SET TAGS ('dbx_business_glossary_term' = 'Effective To Date');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `performance_attribution_flag` SET TAGS ('dbx_business_glossary_term' = 'Performance Attribution Flag');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Frequency');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annually|ad_hoc');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Reporting Flag');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `tracking_error_limit` SET TAGS ('dbx_business_glossary_term' = 'Tracking Error Limit');
ALTER TABLE `asset_management`.`portfolio`.`benchmark_assignment` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` SET TAGS ('dbx_subdomain' = 'allocation_strategy');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `asset_class_weight_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Weight Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `active_weight_percentage` SET TAGS ('dbx_business_glossary_term' = 'Active Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|pending_review|approved|rejected');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approved Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `asset_class_code` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Code');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `asset_class_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,10}$');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `asset_class_name` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Name');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `benchmark_weight_percentage` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `contribution_to_return` SET TAGS ('dbx_business_glossary_term' = 'Contribution to Return');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `deviation_from_target` SET TAGS ('dbx_business_glossary_term' = 'Deviation from Target');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `effective_weight_percentage` SET TAGS ('dbx_business_glossary_term' = 'Effective Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `esg_weight_percentage` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `liquidity_classification` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Classification');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `liquidity_classification` SET TAGS ('dbx_value_regex' = 'liquid|semi_liquid|illiquid');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `market_value` SET TAGS ('dbx_business_glossary_term' = 'Market Value');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `market_value` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Modified By');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `number_of_holdings` SET TAGS ('dbx_business_glossary_term' = 'Number of Holdings');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `prior_period_weight_percentage` SET TAGS ('dbx_business_glossary_term' = 'Prior Period Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `rebalancing_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Required Flag');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `rebalancing_threshold_lower` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Threshold Lower Bound');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `rebalancing_threshold_upper` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Threshold Upper Bound');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `reporting_period` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `reporting_period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(Q[1-4]|M(0[1-9]|1[0-2])|[0-9]{4})$');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `tactical_weight_percentage` SET TAGS ('dbx_business_glossary_term' = 'Tactical Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `target_weight_percentage` SET TAGS ('dbx_business_glossary_term' = 'Target Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `unfunded_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Unfunded Commitment Amount');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `unfunded_commitment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `weight_calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Weight Calculation Method');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `weight_calculation_method` SET TAGS ('dbx_value_regex' = 'market_value|nav|fair_value|cost_basis');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `weight_change_percentage` SET TAGS ('dbx_business_glossary_term' = 'Weight Change Percentage');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `weight_percentage` SET TAGS ('dbx_business_glossary_term' = 'Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `weight_status` SET TAGS ('dbx_business_glossary_term' = 'Weight Status');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `weight_status` SET TAGS ('dbx_value_regex' = 'within_range|overweight|underweight|at_target');
ALTER TABLE `asset_management`.`portfolio`.`asset_class_weight` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` SET TAGS ('dbx_subdomain' = 'allocation_strategy');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `rebalancing_event_id` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Event Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `approved_by` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `base_currency` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `base_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `carbon_footprint_post` SET TAGS ('dbx_business_glossary_term' = 'Post-Rebalancing Carbon Footprint');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `carbon_footprint_pre` SET TAGS ('dbx_business_glossary_term' = 'Pre-Rebalancing Carbon Footprint');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `cash_requirement` SET TAGS ('dbx_business_glossary_term' = 'Cash Requirement Amount');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `cash_requirement` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `drift_percentage` SET TAGS ('dbx_business_glossary_term' = 'Drift Percentage');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `drift_threshold_breached` SET TAGS ('dbx_business_glossary_term' = 'Drift Threshold Breached Flag');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `esg_impact_assessed` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Impact Assessed Flag');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `esg_score_post` SET TAGS ('dbx_business_glossary_term' = 'Post-Rebalancing Environmental Social and Governance (ESG) Score');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `esg_score_pre` SET TAGS ('dbx_business_glossary_term' = 'Pre-Rebalancing Environmental Social and Governance (ESG) Score');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `estimated_market_impact` SET TAGS ('dbx_business_glossary_term' = 'Estimated Market Impact Cost');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `estimated_market_impact` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `estimated_tax_impact` SET TAGS ('dbx_business_glossary_term' = 'Estimated Tax Impact');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `estimated_tax_impact` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `event_number` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Event Number');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `event_number` SET TAGS ('dbx_value_regex' = '^REB-[0-9]{8}-[0-9]{6}$');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `event_status` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Event Status');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `event_status` SET TAGS ('dbx_value_regex' = 'proposed|approved|in_progress|completed|cancelled|failed');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `event_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Event Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `execution_end_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Execution End Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `execution_start_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Execution Start Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `execution_strategy` SET TAGS ('dbx_business_glossary_term' = 'Execution Strategy');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `execution_strategy` SET TAGS ('dbx_value_regex' = 'immediate|VWAP|TWAP|algorithmic|block_trade|dark_pool');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `liquidity_constraint_applied` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Constraint Applied Flag');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `post_rebalancing_nav` SET TAGS ('dbx_business_glossary_term' = 'Post-Rebalancing Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `post_rebalancing_nav` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `post_trade_var` SET TAGS ('dbx_business_glossary_term' = 'Post-Trade Value at Risk (VaR)');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `post_trade_var` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `pre_rebalancing_nav` SET TAGS ('dbx_business_glossary_term' = 'Pre-Rebalancing Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `pre_rebalancing_nav` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `pre_trade_var` SET TAGS ('dbx_business_glossary_term' = 'Pre-Trade Value at Risk (VaR)');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `pre_trade_var` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Frequency');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|ad_hoc');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `rebalancing_notes` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Notes');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `risk_assessment_performed` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Performed Flag');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `scheduled_rebalancing_flag` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Rebalancing Flag');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `system_source` SET TAGS ('dbx_business_glossary_term' = 'System Source');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `target_allocation_type` SET TAGS ('dbx_business_glossary_term' = 'Target Allocation Type');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `target_allocation_type` SET TAGS ('dbx_value_regex' = 'SAA|TAA');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `tax_optimization_applied` SET TAGS ('dbx_business_glossary_term' = 'Tax Optimization Applied Flag');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `total_trades_executed` SET TAGS ('dbx_business_glossary_term' = 'Total Trades Executed Count');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `total_transaction_cost` SET TAGS ('dbx_business_glossary_term' = 'Total Transaction Cost');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `total_transaction_cost` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `tracking_error_post` SET TAGS ('dbx_business_glossary_term' = 'Post-Rebalancing Tracking Error');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `tracking_error_post` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `tracking_error_pre` SET TAGS ('dbx_business_glossary_term' = 'Pre-Rebalancing Tracking Error');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `tracking_error_pre` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `transaction_cost_bps` SET TAGS ('dbx_business_glossary_term' = 'Transaction Cost in Basis Points (bps)');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `transaction_cost_bps` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `trigger_description` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Trigger Description');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `trigger_type` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Trigger Type');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `trigger_type` SET TAGS ('dbx_value_regex' = 'drift_breach|scheduled_periodic|tactical_decision|mandate_change|liquidity_requirement|risk_limit_breach');
ALTER TABLE `asset_management`.`portfolio`.`rebalancing_event` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`constraint` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`portfolio`.`constraint` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`constraint` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`constraint` SET TAGS ('dbx_subdomain' = 'compliance_benchmarking');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `constraint_id` SET TAGS ('dbx_business_glossary_term' = 'Constraint ID');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `portfolio_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark ID');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `portfolio_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate ID');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|approved|rejected');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `breach_count` SET TAGS ('dbx_business_glossary_term' = 'Breach Count');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `breach_severity` SET TAGS ('dbx_business_glossary_term' = 'Breach Severity');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `breach_severity` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low|informational');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Calculation Method');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `constraint_category` SET TAGS ('dbx_business_glossary_term' = 'Constraint Category');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `constraint_category` SET TAGS ('dbx_value_regex' = 'regulatory|mandate|policy|risk|operational|esg');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `constraint_code` SET TAGS ('dbx_business_glossary_term' = 'Constraint Code');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `constraint_status` SET TAGS ('dbx_business_glossary_term' = 'Constraint Status');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `constraint_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending|expired');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `constraint_type` SET TAGS ('dbx_business_glossary_term' = 'Constraint Type');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `credit_rating_minimum` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating Minimum');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `esg_score_minimum` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Score Minimum');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `geography_code` SET TAGS ('dbx_business_glossary_term' = 'Geography Code');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `geography_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `last_breach_date` SET TAGS ('dbx_business_glossary_term' = 'Last Breach Date');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `mandate_clause_reference` SET TAGS ('dbx_business_glossary_term' = 'Mandate Clause Reference');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `maximum_value` SET TAGS ('dbx_business_glossary_term' = 'Maximum Value');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `minimum_value` SET TAGS ('dbx_business_glossary_term' = 'Minimum Value');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Modified By');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Frequency');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_value_regex' = 'real_time|intraday|daily|weekly|monthly|quarterly');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `constraint_name` SET TAGS ('dbx_business_glossary_term' = 'Constraint Name');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Constraint Notes');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `notification_recipients` SET TAGS ('dbx_business_glossary_term' = 'Notification Recipients');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `notification_required` SET TAGS ('dbx_business_glossary_term' = 'Notification Required');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `override_allowed` SET TAGS ('dbx_business_glossary_term' = 'Override Allowed');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `override_authority_level` SET TAGS ('dbx_business_glossary_term' = 'Override Authority Level');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `remediation_period_days` SET TAGS ('dbx_business_glossary_term' = 'Remediation Period Days');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `rule_description` SET TAGS ('dbx_business_glossary_term' = 'Rule Description');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'Constraint Scope');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `sector_code` SET TAGS ('dbx_business_glossary_term' = 'Sector Code');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `threshold_currency` SET TAGS ('dbx_business_glossary_term' = 'Threshold Currency');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `threshold_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `threshold_type` SET TAGS ('dbx_business_glossary_term' = 'Threshold Type');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `threshold_type` SET TAGS ('dbx_value_regex' = 'minimum|maximum|range|absolute|relative');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `threshold_unit` SET TAGS ('dbx_business_glossary_term' = 'Threshold Unit');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `threshold_unit` SET TAGS ('dbx_value_regex' = 'percentage|bps|currency|count|ratio');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `threshold_value` SET TAGS ('dbx_business_glossary_term' = 'Threshold Value');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `tolerance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Tolerance Percentage');
ALTER TABLE `asset_management`.`portfolio`.`constraint` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` SET TAGS ('dbx_subdomain' = 'compliance_benchmarking');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `constraint_breach_id` SET TAGS ('dbx_business_glossary_term' = 'Constraint Breach Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `constraint_id` SET TAGS ('dbx_business_glossary_term' = 'Constraint Rule Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `constraint_rule_id` SET TAGS ('dbx_business_glossary_term' = 'Constraint Rule Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `holding_id` SET TAGS ('dbx_business_glossary_term' = 'Position Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `portfolio_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `position_holding_id` SET TAGS ('dbx_business_glossary_term' = 'Position Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `acknowledged_by` SET TAGS ('dbx_business_glossary_term' = 'Acknowledged By');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `acknowledged_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Acknowledged Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `actual_value` SET TAGS ('dbx_business_glossary_term' = 'Actual Value');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `breach_amount` SET TAGS ('dbx_business_glossary_term' = 'Breach Amount');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `breach_detected_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Breach Detected Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `breach_notes` SET TAGS ('dbx_business_glossary_term' = 'Breach Notes');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `breach_occurrence_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Breach Occurrence Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `breach_percentage` SET TAGS ('dbx_business_glossary_term' = 'Breach Percentage');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `breach_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Breach Reference Number');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `breach_status` SET TAGS ('dbx_business_glossary_term' = 'Breach Status');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `breach_status` SET TAGS ('dbx_value_regex' = 'detected|acknowledged|under_review|remediated|waived|escalated');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `breach_type` SET TAGS ('dbx_business_glossary_term' = 'Breach Type');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `breach_type` SET TAGS ('dbx_value_regex' = 'pre_trade|post_trade|intraday|end_of_day');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `constraint_category` SET TAGS ('dbx_business_glossary_term' = 'Constraint Category');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `constraint_description` SET TAGS ('dbx_business_glossary_term' = 'Constraint Description');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `detected_by_system` SET TAGS ('dbx_business_glossary_term' = 'Detected By System');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `detection_method` SET TAGS ('dbx_business_glossary_term' = 'Detection Method');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `detection_method` SET TAGS ('dbx_value_regex' = 'automated|manual|scheduled_batch|real_time');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `escalated_to_ic` SET TAGS ('dbx_business_glossary_term' = 'Escalated to Investment Committee (IC)');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `escalation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Escalation Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `geography` SET TAGS ('dbx_business_glossary_term' = 'Geography');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `geography` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Name');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `regulator_report_date` SET TAGS ('dbx_business_glossary_term' = 'Regulator Report Date');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `regulatory_reportable` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reportable');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `remediated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Remediated Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `remediation_action` SET TAGS ('dbx_business_glossary_term' = 'Remediation Action');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `remediation_deadline` SET TAGS ('dbx_business_glossary_term' = 'Remediation Deadline');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `reported_to_regulator` SET TAGS ('dbx_business_glossary_term' = 'Reported to Regulator');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Sector');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `security_identifier` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `security_name` SET TAGS ('dbx_business_glossary_term' = 'Security Name');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `severity_level` SET TAGS ('dbx_business_glossary_term' = 'Severity Level');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `severity_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low|informational');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `threshold_value` SET TAGS ('dbx_business_glossary_term' = 'Threshold Value');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `waiver_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Waiver Approved By');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `waiver_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Waiver Expiry Date');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `waiver_granted` SET TAGS ('dbx_business_glossary_term' = 'Waiver Granted');
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` SET TAGS ('dbx_subdomain' = 'compliance_benchmarking');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `gips_composite_id` SET TAGS ('dbx_business_glossary_term' = 'Global Investment Performance Standards (GIPS) Composite Identifier');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `benchmark_code` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Code');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `benchmark_name` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Name');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `composite_aum` SET TAGS ('dbx_business_glossary_term' = 'Composite Assets Under Management (AUM)');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `composite_code` SET TAGS ('dbx_business_glossary_term' = 'Composite Code');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `composite_creation_method` SET TAGS ('dbx_business_glossary_term' = 'Composite Creation Method');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `composite_creation_method` SET TAGS ('dbx_value_regex' = 'asset_weighted|equal_weighted');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `composite_definition` SET TAGS ('dbx_business_glossary_term' = 'Composite Definition');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `composite_description` SET TAGS ('dbx_business_glossary_term' = 'Composite Description');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `composite_dispersion_measure` SET TAGS ('dbx_business_glossary_term' = 'Composite Dispersion Measure');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `composite_dispersion_measure` SET TAGS ('dbx_value_regex' = 'standard_deviation|range|interquartile_range');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `composite_manager_name` SET TAGS ('dbx_business_glossary_term' = 'Composite Manager Name');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `composite_name` SET TAGS ('dbx_business_glossary_term' = 'Composite Name');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `composite_notes` SET TAGS ('dbx_business_glossary_term' = 'Composite Notes');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `composite_status` SET TAGS ('dbx_business_glossary_term' = 'Composite Status');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `composite_status` SET TAGS ('dbx_value_regex' = 'active|inactive|closed|pending');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `composite_type` SET TAGS ('dbx_business_glossary_term' = 'Composite Type');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `composite_type` SET TAGS ('dbx_value_regex' = 'discretionary|non_discretionary|pooled|segregated');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `derivatives_usage_flag` SET TAGS ('dbx_business_glossary_term' = 'Derivatives Usage Flag');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `esg_strategy_description` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Strategy Description');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `fee_schedule_description` SET TAGS ('dbx_business_glossary_term' = 'Fee Schedule Description');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `fee_schedule_description` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Focus');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `gross_of_fees_flag` SET TAGS ('dbx_business_glossary_term' = 'Gross of Fees Flag');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Composite Inception Date');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `last_examination_date` SET TAGS ('dbx_business_glossary_term' = 'Last Performance Examination Date');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `last_updated_by` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated By User');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `leverage_flag` SET TAGS ('dbx_business_glossary_term' = 'Leverage Flag');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `minimum_portfolio_size` SET TAGS ('dbx_business_glossary_term' = 'Minimum Portfolio Size');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `net_of_fees_flag` SET TAGS ('dbx_business_glossary_term' = 'Net of Fees Flag');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `number_of_portfolios` SET TAGS ('dbx_business_glossary_term' = 'Number of Portfolios');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `performance_examination_flag` SET TAGS ('dbx_business_glossary_term' = 'Performance Examination Flag');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|annual');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `return_calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Return Calculation Method');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `return_calculation_method` SET TAGS ('dbx_value_regex' = 'twr|mwr|irr');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `sector_focus` SET TAGS ('dbx_business_glossary_term' = 'Sector Focus');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Composite Termination Date');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `three_year_ex_post_standard_deviation` SET TAGS ('dbx_business_glossary_term' = 'Three-Year Ex-Post Standard Deviation');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Valuation Methodology');
ALTER TABLE `asset_management`.`portfolio`.`gips_composite` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By User');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` SET TAGS ('dbx_subdomain' = 'compliance_benchmarking');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `portfolio_composite_membership_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Composite Membership Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `composite_id` SET TAGS ('dbx_business_glossary_term' = 'Composite Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `gips_compliance_record_id` SET TAGS ('dbx_business_glossary_term' = 'Gips Compliance Record Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `gips_composite_id` SET TAGS ('dbx_business_glossary_term' = 'Gips Composite Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `audit_trail_reference` SET TAGS ('dbx_business_glossary_term' = 'Audit Trail Reference');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `benchmark_assignment_override_flag` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Assignment Override Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `carve_out_cash_allocation_method` SET TAGS ('dbx_business_glossary_term' = 'Carve-Out Cash Allocation Method');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `carve_out_cash_allocation_method` SET TAGS ('dbx_value_regex' = 'actual|synthetic|proportional');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `carve_out_flag` SET TAGS ('dbx_business_glossary_term' = 'Carve-Out Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `compliance_notes` SET TAGS ('dbx_business_glossary_term' = 'Compliance Notes');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `composite_assignment_date` SET TAGS ('dbx_business_glossary_term' = 'Composite Assignment Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `composite_definition_compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Composite Definition Compliance Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `discretionary_flag` SET TAGS ('dbx_business_glossary_term' = 'Discretionary Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `exclusion_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Reason Code');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `exclusion_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Reason Description');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `fee_paying_flag` SET TAGS ('dbx_business_glossary_term' = 'Fee-Paying Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `inclusion_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Inclusion Reason Code');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `inclusion_reason_code` SET TAGS ('dbx_value_regex' = 'initial|mandate_match|strategy_alignment|rebalance|discretionary|regulatory');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `inclusion_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Inclusion Reason Description');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `market_value_at_exclusion` SET TAGS ('dbx_business_glossary_term' = 'Market Value at Exclusion');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `market_value_at_exclusion` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `market_value_at_inclusion` SET TAGS ('dbx_business_glossary_term' = 'Market Value at Inclusion');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `market_value_at_inclusion` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `membership_status` SET TAGS ('dbx_business_glossary_term' = 'Membership Status');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `membership_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|excluded');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `minimum_asset_threshold_met_flag` SET TAGS ('dbx_business_glossary_term' = 'Minimum Asset Threshold Met Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `performance_calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Performance Calculation Method');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `performance_calculation_method` SET TAGS ('dbx_value_regex' = 'twr|mwr|irr|modified_dietz');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `portfolio_inception_date` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Inception Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `significant_cash_flow_flag` SET TAGS ('dbx_business_glossary_term' = 'Significant Cash Flow Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'simcorp|aladdin|factset|manual');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `temporary_exclusion_flag` SET TAGS ('dbx_business_glossary_term' = 'Temporary Exclusion Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ALTER COLUMN `weight_in_composite_percent` SET TAGS ('dbx_business_glossary_term' = 'Weight in Composite Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` SET TAGS ('dbx_subdomain' = 'allocation_strategy');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `portfolio_capital_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Capital Commitment Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Dd Engagement Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `deal_capital_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Capital Commitment Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `infra_fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Infra Fund Commitment Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `re_fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Re Fund Commitment Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `base_currency_committed_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Committed Amount');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `base_currency_funded_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Funded Amount');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `base_currency_unfunded_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Unfunded Amount');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `carried_interest_percent` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Commitment Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `commitment_date` SET TAGS ('dbx_business_glossary_term' = 'Commitment Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `commitment_notes` SET TAGS ('dbx_business_glossary_term' = 'Commitment Notes');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `commitment_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Commitment Period End Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `commitment_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Commitment Period Start Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `commitment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Commitment Reference Number');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `commitment_status` SET TAGS ('dbx_business_glossary_term' = 'Commitment Status');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `commitment_status` SET TAGS ('dbx_value_regex' = 'pending|approved|active|fully_funded|cancelled|expired');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `commitment_type` SET TAGS ('dbx_business_glossary_term' = 'Commitment Type');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `commitment_type` SET TAGS ('dbx_value_regex' = 'initial|follow_on|co_investment|secondary|recapitalization|sidecar');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `committed_amount` SET TAGS ('dbx_business_glossary_term' = 'Committed Amount');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `counterparty_name` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Name');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `esg_classification` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Classification');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `expected_fund_term_years` SET TAGS ('dbx_business_glossary_term' = 'Expected Fund Term (Years)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `extension_options_years` SET TAGS ('dbx_business_glossary_term' = 'Extension Options (Years)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `funded_amount` SET TAGS ('dbx_business_glossary_term' = 'Funded Amount');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Focus');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate (Preferred Return) Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `ic_approval_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Reference');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified By User');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `legal_entity_identifier` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `legal_entity_identifier` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `lpa_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Document Reference');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `lpa_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Execution Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `management_fee_percent` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `responsible_investment_flag` SET TAGS ('dbx_business_glossary_term' = 'Responsible Investment Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `saa_target_allocation_percent` SET TAGS ('dbx_business_glossary_term' = 'Strategic Asset Allocation (SAA) Target Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `sector_focus` SET TAGS ('dbx_business_glossary_term' = 'Sector Focus');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `target_irr_percent` SET TAGS ('dbx_business_glossary_term' = 'Target Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `target_moic` SET TAGS ('dbx_business_glossary_term' = 'Target Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `unfunded_amount` SET TAGS ('dbx_business_glossary_term' = 'Unfunded Amount (Dry Powder)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By User');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` SET TAGS ('dbx_subdomain' = 'position_valuation');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `portfolio_nav_record_id` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Record Identifier');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `valuation_nav_record_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Nav Record Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `accrued_expenses` SET TAGS ('dbx_business_glossary_term' = 'Accrued Expenses');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `accrued_income` SET TAGS ('dbx_business_glossary_term' = 'Accrued Income');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `administrator_name` SET TAGS ('dbx_business_glossary_term' = 'Administrator Name');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|under_review');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Calculation Method');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `calculation_method` SET TAGS ('dbx_value_regex' = 'mark_to_market|fair_value|amortized_cost|model_based|administrator_reported');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `cash_and_equivalents` SET TAGS ('dbx_business_glossary_term' = 'Cash and Cash Equivalents');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `contributions` SET TAGS ('dbx_business_glossary_term' = 'Contributions');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `distributions` SET TAGS ('dbx_business_glossary_term' = 'Distributions');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `fiscal_quarter` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Quarter');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `fx_impact` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Impact');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `gav_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Asset Value (GAV) Amount');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `management_fee_accrual` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Accrual');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `nav_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Amount');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `nav_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Change Amount');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `nav_change_percentage` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Change Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `nav_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Per Unit');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `nav_status` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Status');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `nav_status` SET TAGS ('dbx_value_regex' = 'preliminary|final|restated|adjusted|cancelled');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `payables` SET TAGS ('dbx_business_glossary_term' = 'Payables');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `performance_fee_accrual` SET TAGS ('dbx_business_glossary_term' = 'Performance Fee Accrual');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `prior_nav_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Net Asset Value (NAV) Amount');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `receivables` SET TAGS ('dbx_business_glossary_term' = 'Receivables');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'pending|reconciled|variance_identified|approved|rejected');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `reporting_period` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `reporting_period` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annual');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `total_assets` SET TAGS ('dbx_business_glossary_term' = 'Total Assets');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `total_liabilities` SET TAGS ('dbx_business_glossary_term' = 'Total Liabilities');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `unfunded_commitments` SET TAGS ('dbx_business_glossary_term' = 'Unfunded Commitments');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `units_outstanding` SET TAGS ('dbx_business_glossary_term' = 'Units Outstanding');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `valuation_source` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `valuation_source` SET TAGS ('dbx_value_regex' = 'fund_administrator|internal_ibor|custodian|third_party_valuation|composite');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Variance Amount');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ALTER COLUMN `variance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Variance Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` SET TAGS ('dbx_subdomain' = 'position_valuation');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `portfolio_cash_flow_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow ID');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Bank Account ID');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `distribution_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund ID');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `infra_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Infra Asset Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `investment_id` SET TAGS ('dbx_business_glossary_term' = 'Investment ID');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `privateequity_capital_call_id` SET TAGS ('dbx_business_glossary_term' = 'Privateequity Capital Call Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `accounting_period` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `accounting_period` SET TAGS ('dbx_value_regex' = '^d{4}-d{2}$');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `accrual_date` SET TAGS ('dbx_business_glossary_term' = 'Accrual Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Amount');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending_approval|approved|rejected');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By User');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `custodian_reference` SET TAGS ('dbx_business_glossary_term' = 'Custodian Reference Number');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `portfolio_cash_flow_description` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Description');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `flow_direction` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Direction');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `flow_direction` SET TAGS ('dbx_value_regex' = 'inflow|outflow');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `flow_type` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Type');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active Record Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `is_external` SET TAGS ('dbx_business_glossary_term' = 'Is External Cash Flow Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `is_significant` SET TAGS ('dbx_business_glossary_term' = 'Is Significant Cash Flow Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Notes');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `original_amount` SET TAGS ('dbx_business_glossary_term' = 'Original Cash Flow Amount');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `original_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Original Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `original_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|ach|check|internal_transfer|dvp|other');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `portfolio_cash_flow_status` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Status');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `portfolio_cash_flow_status` SET TAGS ('dbx_value_regex' = 'pending|confirmed|settled|cancelled|failed|reversed');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `reclaim_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Tax Reclaim Eligible Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'unreconciled|reconciled|exception|under_review');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `significance_threshold_percent` SET TAGS ('dbx_business_glossary_term' = 'Significance Threshold Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System ID');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `tax_treatment` SET TAGS ('dbx_business_glossary_term' = 'Tax Treatment Classification');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `tax_treatment` SET TAGS ('dbx_value_regex' = 'taxable|tax_exempt|tax_deferred|withholding_applied|other');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `tax_treatment` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `tax_treatment` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `transaction_reference` SET TAGS ('dbx_business_glossary_term' = 'Transaction Reference Number');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `value_date` SET TAGS ('dbx_business_glossary_term' = 'Value Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Amount');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ALTER COLUMN `withholding_tax_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Rate Percentage');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` SET TAGS ('dbx_subdomain' = 'portfolio_structure');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `mandate_history_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate History Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `mandate_new_benchmark_portfolio_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'New Benchmark Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `mandate_portfolio_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Previous Benchmark Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `portfolio_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `superseded_by_history_mandate_history_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By History Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `change_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Change Effective Date');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `change_impact_assessment` SET TAGS ('dbx_business_glossary_term' = 'Change Impact Assessment');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `change_notes` SET TAGS ('dbx_business_glossary_term' = 'Change Notes');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `change_reason` SET TAGS ('dbx_business_glossary_term' = 'Change Reason');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `change_status` SET TAGS ('dbx_business_glossary_term' = 'Change Status');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `change_status` SET TAGS ('dbx_value_regex' = 'proposed|approved|implemented|superseded|cancelled');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `change_type` SET TAGS ('dbx_business_glossary_term' = 'Change Type');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `change_type` SET TAGS ('dbx_value_regex' = 'saa_target_revision|benchmark_change|constraint_amendment|currency_policy_update|scope_expansion|scope_restriction');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `ic_approval_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Reference');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `implementation_date` SET TAGS ('dbx_business_glossary_term' = 'Implementation Date');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `new_asset_class_scope` SET TAGS ('dbx_business_glossary_term' = 'New Asset Class Scope');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `new_constraint_type` SET TAGS ('dbx_business_glossary_term' = 'New Constraint Type');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `new_constraint_value` SET TAGS ('dbx_business_glossary_term' = 'New Constraint Value');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `new_currency_policy` SET TAGS ('dbx_business_glossary_term' = 'New Currency Policy');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `new_esg_framework` SET TAGS ('dbx_business_glossary_term' = 'New Environmental Social and Governance (ESG) Framework');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `new_rebalancing_frequency` SET TAGS ('dbx_business_glossary_term' = 'New Rebalancing Frequency');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `new_saa_target_weight` SET TAGS ('dbx_business_glossary_term' = 'New Strategic Asset Allocation (SAA) Target Weight');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `new_tolerance_band_lower` SET TAGS ('dbx_business_glossary_term' = 'New Tolerance Band Lower Limit');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `new_tolerance_band_upper` SET TAGS ('dbx_business_glossary_term' = 'New Tolerance Band Upper Limit');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `previous_asset_class_scope` SET TAGS ('dbx_business_glossary_term' = 'Previous Asset Class Scope');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `previous_constraint_type` SET TAGS ('dbx_business_glossary_term' = 'Previous Constraint Type');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `previous_constraint_value` SET TAGS ('dbx_business_glossary_term' = 'Previous Constraint Value');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `previous_currency_policy` SET TAGS ('dbx_business_glossary_term' = 'Previous Currency Policy');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `previous_esg_framework` SET TAGS ('dbx_business_glossary_term' = 'Previous Environmental Social and Governance (ESG) Framework');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `previous_rebalancing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Previous Rebalancing Frequency');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `previous_saa_target_weight` SET TAGS ('dbx_business_glossary_term' = 'Previous Strategic Asset Allocation (SAA) Target Weight');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `previous_tolerance_band_lower` SET TAGS ('dbx_business_glossary_term' = 'Previous Tolerance Band Lower Limit');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `previous_tolerance_band_upper` SET TAGS ('dbx_business_glossary_term' = 'Previous Tolerance Band Upper Limit');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `regulatory_trigger_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Trigger Flag');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `stakeholder_notification_date` SET TAGS ('dbx_business_glossary_term' = 'Stakeholder Notification Date');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `superseded_date` SET TAGS ('dbx_business_glossary_term' = 'Superseded Date');
ALTER TABLE `asset_management`.`portfolio`.`mandate_history` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` SET TAGS ('dbx_subdomain' = 'portfolio_structure');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `sleeve_id` SET TAGS ('dbx_business_glossary_term' = 'Sleeve Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `composite_id` SET TAGS ('dbx_business_glossary_term' = 'Composite Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `credit_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Mandate Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `pe_fund_id` SET TAGS ('dbx_business_glossary_term' = 'Pe Fund Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `portfolio_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `actual_allocation_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Allocation Amount');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `actual_allocation_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Actual Allocation Weight Percent');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `approval_authority` SET TAGS ('dbx_business_glossary_term' = 'Approval Authority');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `asset_class_code` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Code');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `sleeve_code` SET TAGS ('dbx_business_glossary_term' = 'Sleeve Code');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `sleeve_description` SET TAGS ('dbx_business_glossary_term' = 'Sleeve Description');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `effective_to_date` SET TAGS ('dbx_business_glossary_term' = 'Effective To Date');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `esg_framework` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Framework');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `exclusion_list_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List Applied Flag');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `gips_compliant_flag` SET TAGS ('dbx_business_glossary_term' = 'Global Investment Performance Standards (GIPS) Compliant Flag');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `ic_approval_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Reference');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Inception Date');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `last_rebalance_date` SET TAGS ('dbx_business_glossary_term' = 'Last Rebalance Date');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `leverage_limit_percent` SET TAGS ('dbx_business_glossary_term' = 'Leverage Limit Percent');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `liquidity_requirement_days` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Requirement Days');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `sleeve_name` SET TAGS ('dbx_business_glossary_term' = 'Sleeve Name');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `next_rebalance_date` SET TAGS ('dbx_business_glossary_term' = 'Next Rebalance Date');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Sleeve Notes');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `performance_attribution_flag` SET TAGS ('dbx_business_glossary_term' = 'Performance Attribution Flag');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `performance_calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Performance Calculation Method');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `performance_calculation_method` SET TAGS ('dbx_value_regex' = 'twr|mwr|irr|moic');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Frequency');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `rebalancing_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Required Flag');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `rebalancing_threshold_lower_percent` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Threshold Lower Percent');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `rebalancing_threshold_upper_percent` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Threshold Upper Percent');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `reporting_inclusion_flag` SET TAGS ('dbx_business_glossary_term' = 'Reporting Inclusion Flag');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `risk_budget_percent` SET TAGS ('dbx_business_glossary_term' = 'Risk Budget Percent');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `sleeve_status` SET TAGS ('dbx_business_glossary_term' = 'Sleeve Status');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `sleeve_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending|closed');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `sleeve_type` SET TAGS ('dbx_business_glossary_term' = 'Sleeve Type');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `sleeve_type` SET TAGS ('dbx_value_regex' = 'asset_class|strategy|manager|geographic|sector|thematic');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `strategy_name` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy Name');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `sub_asset_class_code` SET TAGS ('dbx_business_glossary_term' = 'Sub-Asset Class Code');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `taa_adjustment_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Tactical Asset Allocation (TAA) Adjustment Weight Percent');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `target_allocation_amount` SET TAGS ('dbx_business_glossary_term' = 'Target Allocation Amount');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `target_allocation_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Target Allocation Weight Percent');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `tolerance_band_lower_percent` SET TAGS ('dbx_business_glossary_term' = 'Tolerance Band Lower Percent');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `tolerance_band_upper_percent` SET TAGS ('dbx_business_glossary_term' = 'Tolerance Band Upper Percent');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `tracking_error_limit_bps` SET TAGS ('dbx_business_glossary_term' = 'Tracking Error Limit Basis Points (bps)');
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ALTER COLUMN `var_limit_percent` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Limit Percent');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` SET TAGS ('dbx_subdomain' = 'position_valuation');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `currency_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Currency Exposure Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `hedge_counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Hedge Counterparty Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `asset_class_code` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Code');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `data_source_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Data Source Record Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `dv01_amount` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of 01 (DV01) Amount');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `exposure_status` SET TAGS ('dbx_business_glossary_term' = 'Exposure Status');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `exposure_status` SET TAGS ('dbx_value_regex' = 'active|closed|under_review|breached');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `exposure_type` SET TAGS ('dbx_business_glossary_term' = 'Exposure Type');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `exposure_type` SET TAGS ('dbx_value_regex' = 'transaction|translation|economic');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `foreign_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Foreign Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `foreign_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `fx_forward_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Forward Rate');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `fx_spot_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Spot Rate');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `gross_exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Exposure Amount');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `hedge_cost_bps` SET TAGS ('dbx_business_glossary_term' = 'Hedge Cost in Basis Points (bps)');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `hedge_effectiveness_percent` SET TAGS ('dbx_business_glossary_term' = 'Hedge Effectiveness Percentage');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `hedge_instrument_type` SET TAGS ('dbx_business_glossary_term' = 'Hedge Instrument Type');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `hedge_instrument_type` SET TAGS ('dbx_value_regex' = 'forward|future|swap|option|none');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `hedge_maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Hedge Maturity Date');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `hedge_ratio_percent` SET TAGS ('dbx_business_glossary_term' = 'Hedge Ratio Percentage');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `hedged_notional_amount` SET TAGS ('dbx_business_glossary_term' = 'Hedged Notional Amount');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `mtm_gain_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Mark-to-Market (MTM) Gain or Loss Amount');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `net_exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Exposure Amount');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `policy_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Policy Breach Flag');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `policy_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Policy Limit Amount');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `realized_gain_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Realized Gain or Loss Amount');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `rebalancing_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Required Flag');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `stress_test_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Impact Amount');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `stress_test_scenario` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Scenario');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ALTER COLUMN `var_contribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Contribution Amount');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` SET TAGS ('dbx_subdomain' = 'position_valuation');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `liquidity_bucket_id` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Bucket Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `holding_snapshot_id` SET TAGS ('dbx_business_glossary_term' = 'Holding Snapshot Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `average_daily_volume` SET TAGS ('dbx_business_glossary_term' = 'Average Daily Volume (ADV)');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `bid_ask_spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Bid-Ask Spread in Basis Points (bps)');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `bucket_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Bucket Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `classification_date` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Classification Date');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `classification_methodology` SET TAGS ('dbx_business_glossary_term' = 'Classification Methodology');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `classification_source` SET TAGS ('dbx_business_glossary_term' = 'Classification Source');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `classification_source` SET TAGS ('dbx_value_regex' = 'internal_model|vendor_data|manual_override|regulatory_guideline');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `classification_status` SET TAGS ('dbx_business_glossary_term' = 'Classification Status');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `classification_status` SET TAGS ('dbx_value_regex' = 'active|superseded|pending|expired');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `effective_to_date` SET TAGS ('dbx_business_glossary_term' = 'Effective To Date');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `estimated_liquidation_days` SET TAGS ('dbx_business_glossary_term' = 'Estimated Liquidation Days');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `gate_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Gate Provision Flag');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `haircut_percent` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Haircut Percentage');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `hqla_category` SET TAGS ('dbx_business_glossary_term' = 'High-Quality Liquid Assets (HQLA) Category');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `hqla_category` SET TAGS ('dbx_value_regex' = 'level_1|level_2a|level_2b|non_hqla');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `hqla_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'High-Quality Liquid Assets (HQLA) Eligible Flag');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `instrument_type` SET TAGS ('dbx_business_glossary_term' = 'Instrument Type');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `liquidation_cost_percent` SET TAGS ('dbx_business_glossary_term' = 'Liquidation Cost Percentage');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `liquidity_tier` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Tier');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `liquidity_tier` SET TAGS ('dbx_value_regex' = 'T+0|T+1|T+2|T+5|T+30|T+90');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `liquidity_tier_code` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Tier Code');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `liquidity_tier_description` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Tier Description');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `lock_up_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Lock-Up Period End Date');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `market_depth_indicator` SET TAGS ('dbx_business_glossary_term' = 'Market Depth Indicator');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `market_depth_indicator` SET TAGS ('dbx_value_regex' = 'deep|moderate|shallow|illiquid');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `market_value_base_currency` SET TAGS ('dbx_business_glossary_term' = 'Market Value in Base Currency');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Classification Notes');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `override_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Override Approval Date');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `override_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Override Approved By');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `override_flag` SET TAGS ('dbx_business_glossary_term' = 'Override Flag');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `override_reason` SET TAGS ('dbx_business_glossary_term' = 'Override Reason');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `redemption_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Redemption Notice Days');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `regulatory_classification` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Liquidity Classification');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `review_frequency_days` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency in Days');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `side_pocket_flag` SET TAGS ('dbx_business_glossary_term' = 'Side Pocket Flag');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `stress_scenario_tier` SET TAGS ('dbx_business_glossary_term' = 'Stress Scenario Liquidity Tier');
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ALTER COLUMN `weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Weight Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` SET TAGS ('dbx_subdomain' = 'allocation_strategy');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `portfolio_ic_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Investment Committee (IC) Approval Identifier');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `coinvestment_id` SET TAGS ('dbx_business_glossary_term' = 'Coinvestment Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `diligence_ic_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Diligence Ic Submission Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `ic_meeting_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Meeting Identifier');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `pe_fund_id` SET TAGS ('dbx_business_glossary_term' = 'Pe Fund Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `pe_investment_id` SET TAGS ('dbx_business_glossary_term' = 'Pe Investment Id (Foreign Key)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `approval_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Approval Reference Number');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `approval_type` SET TAGS ('dbx_business_glossary_term' = 'Approval Type');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `capital_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Capital Commitment Amount');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `capital_commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Capital Commitment Currency');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `capital_commitment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `chair_approval_flag` SET TAGS ('dbx_business_glossary_term' = 'Chair Approval Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `compliance_review_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Review Status');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `compliance_review_status` SET TAGS ('dbx_value_regex' = 'approved|pending|rejected|not_required');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `conditions_of_approval` SET TAGS ('dbx_business_glossary_term' = 'Conditions of Approval');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `decision_date` SET TAGS ('dbx_business_glossary_term' = 'Decision Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `decision_status` SET TAGS ('dbx_business_glossary_term' = 'Decision Status');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `decision_status` SET TAGS ('dbx_value_regex' = 'approved|rejected|deferred|conditional|withdrawn');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `deferral_reason` SET TAGS ('dbx_business_glossary_term' = 'Deferral Reason');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `esg_framework` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Framework');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `expected_return_impact_percent` SET TAGS ('dbx_business_glossary_term' = 'Expected Return Impact Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `expected_risk_impact_percent` SET TAGS ('dbx_business_glossary_term' = 'Expected Risk Impact Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `im_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Memorandum (IM) Document Reference');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `legal_review_status` SET TAGS ('dbx_business_glossary_term' = 'Legal Review Status');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `legal_review_status` SET TAGS ('dbx_value_regex' = 'approved|pending|rejected|not_required');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Meeting Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `policy_exception_flag` SET TAGS ('dbx_business_glossary_term' = 'Policy Exception Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `policy_exception_rationale` SET TAGS ('dbx_business_glossary_term' = 'Policy Exception Rationale');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `proposal_summary` SET TAGS ('dbx_business_glossary_term' = 'Proposal Summary');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `proposal_title` SET TAGS ('dbx_business_glossary_term' = 'Proposal Title');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `proposed_benchmark_code` SET TAGS ('dbx_business_glossary_term' = 'Proposed Benchmark Code');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `proposed_mandate_type` SET TAGS ('dbx_business_glossary_term' = 'Proposed Mandate Type');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `proposed_saa_change_description` SET TAGS ('dbx_business_glossary_term' = 'Proposed Strategic Asset Allocation (SAA) Change Description');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `proposed_taa_change_description` SET TAGS ('dbx_business_glossary_term' = 'Proposed Tactical Asset Allocation (TAA) Change Description');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `quorum_met_flag` SET TAGS ('dbx_business_glossary_term' = 'Quorum Met Flag');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `rebalancing_threshold_lower_percent` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Threshold Lower Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `rebalancing_threshold_upper_percent` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Threshold Upper Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `risk_assessment_summary` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Summary');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `strategic_rationale` SET TAGS ('dbx_business_glossary_term' = 'Strategic Rationale');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `supporting_analysis_reference` SET TAGS ('dbx_business_glossary_term' = 'Supporting Analysis Reference');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `tracking_error_impact_bps` SET TAGS ('dbx_business_glossary_term' = 'Tracking Error Impact Basis Points (bps)');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `var_impact_percent` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Impact Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `votes_abstained` SET TAGS ('dbx_business_glossary_term' = 'Votes Abstained');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `votes_against` SET TAGS ('dbx_business_glossary_term' = 'Votes Against');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `votes_in_favor` SET TAGS ('dbx_business_glossary_term' = 'Votes in Favor');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ALTER COLUMN `voting_outcome_summary` SET TAGS ('dbx_business_glossary_term' = 'Voting Outcome Summary');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_allocation` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_allocation` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_allocation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_allocation` SET TAGS ('dbx_subdomain' = 'allocation_strategy');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_allocation` SET TAGS ('dbx_association_edges' = 'portfolio.portfolio,deal.opportunity');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_allocation` ALTER COLUMN `percentage` SET TAGS ('dbx_business_glossary_term' = 'Allocation Percentage');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_allocation` ALTER COLUMN `portfolio_allocation_date` SET TAGS ('dbx_business_glossary_term' = 'Allocation Date');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_allocation` ALTER COLUMN `portfolio_allocation_status` SET TAGS ('dbx_business_glossary_term' = 'Allocation Status');
ALTER TABLE `asset_management`.`portfolio`.`portfolio_allocation` ALTER COLUMN `rationale` SET TAGS ('dbx_business_glossary_term' = 'Allocation Rationale');
ALTER TABLE `asset_management`.`portfolio`.`asset` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`portfolio`.`asset` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`asset` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`asset` SET TAGS ('dbx_subdomain' = 'portfolio_structure');
ALTER TABLE `asset_management`.`portfolio`.`asset` ALTER COLUMN `asset_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Identifier');
ALTER TABLE `asset_management`.`portfolio`.`asset` ALTER COLUMN `cusip` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`asset` ALTER COLUMN `isin` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`asset` ALTER COLUMN `sedol` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`portfolio`.`tax_lot` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`portfolio`.`tax_lot` SET TAGS ('dbx_domain' = 'portfolio');
ALTER TABLE `asset_management`.`portfolio`.`tax_lot` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`portfolio`.`tax_lot` SET TAGS ('dbx_subdomain' = 'portfolio_structure');
ALTER TABLE `asset_management`.`portfolio`.`tax_lot` ALTER COLUMN `tax_lot_id` SET TAGS ('dbx_business_glossary_term' = 'Tax Lot Identifier');
