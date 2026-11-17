-- Schema for Domain: actuarial | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:24

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`actuarial` COMMENT 'Domain for actuarial liability matching and liability-driven investment (LDI) operations. Owns actuarial liability projections, ALM models, discount rate curves, mortality assumptions, funded status calculations, contribution rate modeling, and duration';
ALTER SCHEMA `asset_management`.`actuarial` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `asset_management`.`actuarial` SET TAGS ('dbx_domain' = 'actuarial');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`liability_projection` (
    `liability_projection_id` BIGINT COMMENT 'Unique identifier for the actuarial liability projection record.',
    `assumption_set_id` BIGINT COMMENT 'Reference to the comprehensive set of actuarial assumptions used in this projection, enabling traceability and scenario comparison.',
    `contributor_pool_id` BIGINT COMMENT 'Reference to the beneficiary contributor pool (one per participating plan) for which this liability projection is calculated.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: Liability projections must be stress-tested under multiple economic scenarios per regulatory requirements (e.g., PRA).',
    `valuation_cycle_id` BIGINT COMMENT 'Foreign key linking to valuation.cycle. Business justification: ALM analysis timing: Liability projections must reference specific valuation cycles to ensure asset-liability matching uses synchronized measurement dates.',
    `abo_amount` DECIMAL(20,2) COMMENT 'The actuarial present value of pension benefits earned to date based on current salary levels, without projection of future salary increases.',
    `actuarial_gain_loss` DECIMAL(20,2) COMMENT 'The change in the PBO resulting from differences between actual experience and actuarial assumptions, or from changes in assumptions themselves.',
    `actuary_firm` STRING COMMENT 'The actuarial consulting firm that prepared the liability projection, if applicable.',
    `actuary_name` STRING COMMENT 'The name of the qualified actuary responsible for preparing and certifying the liability projection.',
    `amortization_period_years` BIGINT COMMENT 'The number of years over which unfunded actuarial liabilities or surpluses are amortized through contribution adjustments.',
    `benefits_paid` DECIMAL(20,2) COMMENT 'The total pension benefits paid to retirees and beneficiaries during the projection period, reducing the liability.',
    `cash_flow_year_1` DECIMAL(20,2) COMMENT 'Projected net benefit cash flow for year 1 of the projection horizon, used for liquidity planning and ALM.',
    `cash_flow_year_10` DECIMAL(20,2) COMMENT 'Projected net benefit cash flow for year 10 of the projection horizon, used for long-term liquidity planning.',
    `cash_flow_year_20` DECIMAL(20,2) COMMENT 'Projected net benefit cash flow for year 20 of the projection horizon, used for extended-term liquidity planning.',
    `cash_flow_year_30` DECIMAL(20,2) COMMENT 'Projected net benefit cash flow for year 30 of the projection horizon, used for ultra-long-term liquidity planning.',
    `cash_flow_year_5` DECIMAL(20,2) COMMENT 'Projected net benefit cash flow for year 5 of the projection horizon, used for medium-term liquidity planning.',
    `certification_date` DATE COMMENT 'The date on which the actuary certified the liability projection as complete and accurate.',
    `comments` STRING COMMENT 'Free-text field for actuarial notes, qualifications, or explanations regarding the projection methodology or results.',
    `contribution_rate_required` DECIMAL(8,5) COMMENT 'The actuarially determined contribution rate required from employers and members to fund the projected benefit obligation over time.',
    `convexity` DECIMAL(10,4) COMMENT 'The measure of the curvature in the relationship between liability values and discount rates, used for advanced ALM risk management.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this liability projection record was first created in the system.',
    `disability_rate` DECIMAL(8,5) COMMENT 'The assumed annual rate at which active members become disabled and eligible for disability benefits.',
    `discount_rate` DECIMAL(8,5) COMMENT 'The rate used to discount future benefit payments to present value, typically based on high-quality corporate bond yields or government bond yields for long-duration liabilities.',
    `funded_ratio` DECIMAL(8,5) COMMENT 'The ratio of plan assets to the projected benefit obligation, expressed as a percentage, a key solvency and health metric for the pension fund.',
    `funded_status_amount` DECIMAL(20,2) COMMENT 'The difference between plan assets and the projected benefit obligation, indicating surplus or deficit position.',
    `inflation_rate` DECIMAL(8,5) COMMENT 'The assumed annual inflation rate used to project cost-of-living adjustments and indexation of pension benefits.',
    `interest_cost` DECIMAL(20,2) COMMENT 'The increase in the projected benefit obligation due to the passage of time, calculated by applying the discount rate to the beginning PBO.',
    `is_active` BOOLEAN COMMENT 'Indicates whether this liability projection is the current active version for the contributor pool and valuation date.',
    `liability_duration_years` DECIMAL(8,2) COMMENT 'The weighted average duration of the liability cash flows, a key metric for Liability-Driven Investment (LDI) and duration matching strategies.',
    `model_version` STRING COMMENT 'The version identifier of the actuarial projection model used to generate this liability projection, supporting model governance and audit trails.',
    `mortality_improvement_scale` STRING COMMENT 'The scale used to project future improvements in mortality rates over time, such as CPM-B or MP-2021.',
    `mortality_table` STRING COMMENT 'The mortality table used to estimate life expectancy and the duration of benefit payments, such as RP-2014 or Pri-2012.',
    `normal_cost_rate` DECIMAL(8,5) COMMENT 'The portion of the contribution rate attributable to benefits earned in the current year, excluding amortization of past service costs.',
    `pbo_amount` DECIMAL(20,2) COMMENT 'The actuarial present value of all future pension benefits earned to date, incorporating projected future salary increases and service credits.',
    `projection_horizon_years` BIGINT COMMENT 'The number of years into the future for which cash flows and liabilities are projected, typically ranging from 30 to 75 years for pension funds.',
    `projection_scenario` STRING COMMENT 'The scenario type under which the liability projection is modeled, supporting Asset-Liability Management (ALM) stress testing and Strategic Asset Allocation (SAA) planning.. Valid values are `base|optimistic|pessimistic|stress|regulatory`',
    `regulatory_filing_date` DATE COMMENT 'The date on which the liability projection was filed with the regulatory authority.',
    `regulatory_filing_status` STRING COMMENT 'The status of the liability projection in the regulatory filing process with the national pension regulator or other pension regulators.. Valid values are `draft|submitted|approved|rejected`',
    `retirement_age_assumption` DECIMAL(5,2) COMMENT 'The average assumed retirement age for active members, used to project the timing of benefit commencement.',
    `salary_growth_rate` DECIMAL(8,5) COMMENT 'The assumed annual rate of salary increase used to project future benefit obligations for active members.',
    `service_cost` DECIMAL(20,2) COMMENT 'The present value of pension benefits earned by active members during the current period, a key component of pension expense.',
    `turnover_rate` DECIMAL(8,5) COMMENT 'The assumed annual rate at which active members leave employment before retirement, affecting the projected benefit obligation.',
    `updated_by` STRING COMMENT 'The user or system identifier that last modified this liability projection record.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this liability projection record was last modified.',
    `valuation_date` DATE COMMENT 'The as-of date for which the actuarial liability projection is calculated, typically aligned with fiscal year-end or interim valuation dates.',
    `created_by` STRING COMMENT 'The user or system identifier that created this liability projection record.',
    CONSTRAINT pk_liability_projection PRIMARY KEY(`liability_projection_id`)
) COMMENT 'Core master record of actuarial liability projections for each contributor pool (one per participating plan). Captures projected benefit obligation (PBO), accumulated benefit obligation (ABO), projected cash flows by year';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`actuarial_valuation` (
    `actuarial_valuation_id` BIGINT COMMENT 'Unique identifier for the actuarial valuation record.',
    `assumption_set_id` BIGINT COMMENT 'Foreign key linking to actuarial.assumption_set. Business justification: Actuarial valuation uses a specific assumption set; FK provides reference and removes duplicate assumption_set_code.',
    `cycle_id` BIGINT COMMENT 'Foreign key linking to valuation.cycle. Business justification: Regulatory consistency: Actuarial valuations must use asset values from specific valuation cycles.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Valuations are prepared for specific regulatory authorities (the national pension regulator for federally regulated plans, state regulators for public plans).',
    `active_member_count` BIGINT COMMENT 'The total number of active contributing members included in the actuarial valuation as of the valuation date.',
    `actuary_designation` STRING COMMENT 'The professional designation of the lead actuary, such as Fellow of the Society of Actuaries (FSA).',
    `actuary_firm_name` STRING COMMENT 'The name of the actuarial consulting firm that performed the valuation.',
    `amortization_period_years` BIGINT COMMENT 'The number of years over which any unfunded liability or deficit is scheduled to be amortized through special payments.',
    `asset_valuation_method` STRING COMMENT 'The method used to value plan assets for funding purposes, indicating whether market value, smoothed value, or fair value was applied.. Valid values are `market_value|smoothed_value|fair_value`',
    `average_active_member_age` DECIMAL(4,1) COMMENT 'The average age of active contributing members as of the valuation date, used for demographic analysis and liability projection.',
    `average_pensioner_age` DECIMAL(4,1) COMMENT 'The average age of retired members receiving pension benefits as of the valuation date.',
    `completion_date` DATE COMMENT 'The date on which the actuarial valuation report was finalized and signed by the actuary.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this actuarial valuation record was first created in the system.',
    `deferred_member_count` BIGINT COMMENT 'The total number of deferred vested members (former employees with preserved benefits) included in the actuarial valuation as of the valuation date.',
    `employer_contribution_rate` DECIMAL(5,4) COMMENT 'The recommended employer contribution rate as a percentage of pensionable payroll, derived from the actuarial valuation to fund ongoing benefit accruals and amortize any deficit.',
    `filing_date` DATE COMMENT 'The date on which the actuarial valuation was filed with the regulatory authority.',
    `going_concern_discount_rate` DECIMAL(5,4) COMMENT 'The discount rate used to calculate the present value of future benefit payments on a going concern basis, typically based on expected long-term investment returns.',
    `going_concern_funded_ratio` DECIMAL(5,4) COMMENT 'The ratio of plan assets to going concern liabilities, expressed as a decimal. A value of 1.0000 indicates 100 percent funded status.',
    `going_concern_liability` DECIMAL(20,2) COMMENT 'The present value of all accrued pension benefits calculated on a going concern basis, assuming the plan continues to operate indefinitely.',
    `going_concern_surplus_deficit` DECIMAL(20,2) COMMENT 'The difference between plan assets and going concern liabilities, indicating the funded status on a going concern basis. Positive values represent surplus; negative values represent deficit.',
    `inflation_assumption` DECIMAL(5,4) COMMENT 'The assumed long-term rate of inflation used in the actuarial valuation for projecting salary increases, benefit indexation, and cost-of-living adjustments.',
    `lead_actuary_name` STRING COMMENT 'The name of the lead actuary who signed and is responsible for the valuation report.',
    `liability_duration_years` DECIMAL(5,2) COMMENT 'The duration of the pension liabilities expressed in years, representing the weighted average time until benefit payments are made. Critical for Asset-Liability Management (ALM) and Liability-Driven Investment (LDI) strategies.',
    `member_contribution_rate` DECIMAL(5,4) COMMENT 'The member contribution rate as a percentage of pensionable payroll, representing the portion of pension funding contributed by plan members.',
    `mortality_improvement_scale` STRING COMMENT 'The mortality improvement scale applied to the base mortality table to reflect expected future improvements in longevity, such as CPM-B or Scale MP-2021.',
    `mortality_table` STRING COMMENT 'The mortality table used in the valuation to estimate life expectancy and the duration of benefit payments, such as RP-2014 or Pri-2012.',
    `next_required_valuation_date` DATE COMMENT 'The regulatory deadline date by which the next actuarial valuation must be performed.',
    `normal_cost_rate` DECIMAL(5,4) COMMENT 'The normal cost expressed as a percentage of pensionable payroll, representing the annual cost of benefits accruing in the current year.',
    `reference_number` STRING COMMENT 'External business reference number assigned to this actuarial valuation for reporting and audit purposes.',
    `report_document_path` STRING COMMENT 'The file path or document management system reference to the full actuarial valuation report.',
    `retired_member_count` BIGINT COMMENT 'The total number of retired members currently receiving pension benefits included in the actuarial valuation as of the valuation date.',
    `retirement_age_assumption` DECIMAL(4,1) COMMENT 'The assumed average or normal retirement age used in the valuation for projecting when active members will commence pension benefits.',
    `salary_increase_assumption` DECIMAL(5,4) COMMENT 'The assumed long-term rate of salary increases used to project future pensionable earnings for active members.',
    `solvency_discount_rate` DECIMAL(5,4) COMMENT 'The discount rate used to calculate the present value of future benefit payments on a solvency basis, typically based on current annuity purchase rates or high-quality corporate bond yields.',
    `solvency_funded_ratio` DECIMAL(5,4) COMMENT 'The ratio of plan assets to solvency liabilities, expressed as a decimal. A value of 1.0000 indicates 100 percent funded status on a solvency basis.',
    `solvency_liability` DECIMAL(20,2) COMMENT 'The present value of all accrued pension benefits calculated on a solvency basis, representing the cost to settle all obligations if the plan were to wind up on the valuation date.',
    `solvency_surplus_deficit` DECIMAL(20,2) COMMENT 'The difference between plan assets and solvency liabilities, indicating the funded status on a solvency basis. Positive values represent surplus; negative values represent deficit.',
    `special_payment_amount` DECIMAL(20,2) COMMENT 'The total amount of special payments required to amortize any going concern or solvency deficit over the regulatory amortization period.',
    `total_member_count` BIGINT COMMENT 'The total number of all plan members (active, deferred, and retired) included in the actuarial valuation as of the valuation date.',
    `total_plan_assets_market_value` DECIMAL(20,2) COMMENT 'The total market value of all pension plan assets as of the valuation date, representing the investment portfolio available to meet future obligations.',
    `total_plan_assets_smoothed_value` DECIMAL(20,2) COMMENT 'The smoothed or actuarial value of plan assets, which may differ from market value due to asset smoothing techniques used to reduce volatility in funding calculations.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this actuarial valuation record was last modified in the system.',
    `valuation_date` DATE COMMENT 'The as-of date for which the actuarial valuation was performed, representing the snapshot date for all assets, liabilities, and assumptions.',
    `valuation_method` STRING COMMENT 'The actuarial cost method used in the valuation, such as Projected Unit Credit, Entry Age Normal, or Aggregate Cost Method.',
    `valuation_status` STRING COMMENT 'Current lifecycle status of the actuarial valuation indicating its approval and filing state.. Valid values are `draft|submitted|under_review|approved|filed|superseded`',
    `valuation_type` STRING COMMENT 'Classification of the actuarial valuation indicating whether it is a full triennial statutory valuation, interim update, special purpose, wind-up, or transfer valuation.. Valid values are `triennial|interim|special|wind-up|transfer`',
    `wind_up_liability` DECIMAL(20,2) COMMENT 'The estimated cost to fully settle all pension obligations through annuity purchases or lump-sum payments if the plan were terminated on the valuation date.',
    CONSTRAINT pk_actuarial_valuation PRIMARY KEY(`actuarial_valuation_id`)
) COMMENT 'Formal actuarial valuation record representing a full triennial or interim valuation of the pension fund AND the authoritative funded-status-at-date snapshot derived from it.';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`alm_model` (
    `alm_model_id` BIGINT COMMENT 'Unique identifier for the ALM model configuration record.',
    `climate_scenario_id` BIGINT COMMENT 'Foreign key linking to esg.climate_scenario. Business justification: Pension fund ALM models must incorporate climate scenarios for TCFD-compliant stress testing and long-term liability projections.',
    `created_by_user_employee_id` BIGINT COMMENT 'Reference to the user or system account that created this ALM model configuration record.',
    `discount_rate_curve_id` BIGINT COMMENT 'Reference to the discount rate curve used for present value calculations of future liability cash flows in this ALM model.',
    `employee_id` BIGINT COMMENT 'Reference to the actuarial team member or investment professional responsible for maintaining and governing this ALM model configuration.',
    `fund_id` BIGINT COMMENT 'Foreign key linking to privateequity.fund. Business justification: ALM model requires reference to private equity fund to incorporate its NAV into asset allocation and liability matching.',
    `performance_benchmark_id` BIGINT COMMENT 'Reference to the actuarial liability benchmark or liability profile used as the target for asset matching in this ALM model.',
    `updated_by_user_employee_id` BIGINT COMMENT 'Reference to the user or system account that last modified this ALM model configuration record.',
    `approval_date` DATE COMMENT 'Date on which the ALM model configuration was formally approved by the Investment Committee or actuarial governance body for production use.',
    `asset_universe_scope` STRING COMMENT 'Description of the asset classes and investment universe included in the ALM model for portfolio construction and optimization, such as public equities, fixed income, real estate, infrastructure, private equity, and natural resources.',
    `back_testing_frequency` STRING COMMENT 'Frequency at which the ALM model predictions are back-tested against actual portfolio and liability outcomes to validate model accuracy and calibration.. Valid values are `monthly|quarterly|semi_annual|annual|ad_hoc`',
    `benefit_payment_pattern` STRING COMMENT 'Expected pattern of future benefit payments over time used in the ALM model: level for constant payments, increasing for growing obligations, decreasing for declining obligations, or custom for complex patterns.. Valid values are `level|increasing|decreasing|custom`',
    `computational_runtime_minutes` BIGINT COMMENT 'Typical runtime in minutes required to execute a full ALM model run including all scenarios and optimizations, used for capacity planning and scheduling.',
    `confidence_interval_level` DECIMAL(5,4) COMMENT 'Statistical confidence level used for reporting ALM model results and risk metrics, typically 0.9500 for 95 percent confidence or 0.9900 for 99 percent confidence.',
    `contribution_rate_assumption` DECIMAL(8,5) COMMENT 'Assumed annual contribution rate as a percentage of payroll or fixed amount used in the ALM model for projecting future cash inflows from plan sponsors and members.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this ALM model configuration record was first created in the system.',
    `currency_hedging_policy` STRING COMMENT 'Foreign exchange hedging strategy applied in the ALM model for managing currency risk on international investments relative to the liability currency.. Valid values are `fully_hedged|partially_hedged|unhedged|dynamic|custom`',
    `duration_matching_strategy` STRING COMMENT 'Strategy employed in the ALM model to align the duration of assets with the duration of liabilities to minimize interest rate risk exposure.. Valid values are `full_match|partial_match|key_rate_duration|cash_flow_match|immunization|none`',
    `effective_from_date` DATE COMMENT 'Date from which this ALM model configuration becomes active and is used for asset allocation decisions and liability matching analysis.',
    `effective_to_date` DATE COMMENT 'Date on which this ALM model configuration ceases to be active, nullable for models that remain in use indefinitely.',
    `esg_integration_approach` STRING COMMENT 'Approach to incorporating ESG factors into the ALM model asset selection and portfolio construction: exclusion screening, best-in-class selection, thematic investing, impact investing, ESG integration, active engagement, or none.',
    `inflation_assumption_rate` DECIMAL(8,5) COMMENT 'Long-term inflation rate assumption used in the ALM model for indexing pension benefits and projecting real returns, expressed as a decimal proportion.',
    `is_active` BOOLEAN COMMENT 'Indicates whether this ALM model configuration is currently active and available for use in asset allocation and liability matching analysis.',
    `last_calibration_date` DATE COMMENT 'Date on which the ALM model parameters and assumptions were last recalibrated or updated based on current market conditions and actuarial experience.',
    `liquidity_constraint_pct` DECIMAL(5,4) COMMENT 'Minimum percentage of portfolio assets that must be maintained in liquid form to meet near-term benefit payment obligations, expressed as a decimal proportion.',
    `model_code` STRING COMMENT 'Short alphanumeric code used as a unique business identifier for the ALM model in reports and system integrations.. Valid values are `^[A-Z0-9_-]{3,20}$`',
    `model_complexity_rating` STRING COMMENT 'Qualitative assessment of the ALM model computational and conceptual complexity, used for governance oversight and resource allocation.. Valid values are `low|medium|high|very_high`',
    `model_documentation_url` STRING COMMENT 'URL or file path to the comprehensive technical documentation describing the ALM model methodology, assumptions, and validation results.',
    `model_name` STRING COMMENT 'Business name assigned to this ALM model configuration for identification and reference by actuarial and investment teams.',
    `model_notes` STRING COMMENT 'Free-text field for additional notes, assumptions, limitations, or special considerations related to this ALM model configuration.',
    `model_status` STRING COMMENT 'Current lifecycle status of the ALM model configuration indicating whether it is in development, under governance review, approved for use, actively deployed, deprecated for future use, or archived.. Valid values are `draft|under_review|approved|active|deprecated|archived`',
    `model_type` STRING COMMENT 'Classification of the ALM modeling approach used: deterministic for single-path projections, stochastic for probabilistic simulations, scenario-based for defined economic scenarios, hybrid for combined approaches, monte_carlo for random sampling, or. Valid values are `deterministic|stochastic|scenario_based|hybrid|monte_carlo|stress_test`',
    `model_version` STRING COMMENT 'Version number of the ALM model configuration following semantic versioning convention to track model evolution and changes.. Valid values are `^[0-9]+.[0-9]+(.[0-9]+)?$`',
    `mortality_assumption_table` STRING COMMENT 'Name or identifier of the mortality table used in the ALM model for projecting longevity risk and future benefit payments, such as RP-2014 or Pri-2012.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal review and validation of the ALM model configuration by the actuarial team and Investment Committee.',
    `optimization_objective` STRING COMMENT 'Primary objective function that the ALM model optimizes, such as maximizing surplus, minimizing contribution volatility, maximizing risk-adjusted return, or minimizing funded status volatility.',
    `projection_horizon_years` BIGINT COMMENT 'Number of years into the future that the ALM model projects asset and liability cash flows, typically aligned with the duration of pension obligations.',
    `rebalancing_frequency` STRING COMMENT 'Frequency at which the ALM model assumes portfolio rebalancing to maintain target asset allocation and duration matching.. Valid values are `monthly|quarterly|semi_annual|annual|dynamic|none`',
    `regulatory_compliance_flag` BOOLEAN COMMENT 'Indicates whether this ALM model configuration meets all applicable regulatory requirements and has been validated for compliance reporting purposes.',
    `risk_tolerance_level` STRING COMMENT 'Risk appetite classification that governs the ALM model asset allocation constraints and volatility tolerance in pursuit of return objectives.. Valid values are `conservative|moderate|balanced|aggressive|custom`',
    `scenario_count` BIGINT COMMENT 'Number of economic scenarios or simulation paths generated by the ALM model for stochastic or scenario-based analysis.',
    `software_platform` STRING COMMENT 'Name and version of the software platform or actuarial system used to implement and execute this ALM model, such as Aladdin, SimCorp, or proprietary in-house systems.',
    `stress_test_scenarios` STRING COMMENT 'Comma-separated list or description of macroeconomic stress test scenarios applied in the ALM model, such as interest rate shocks, equity market crashes, inflation spikes, or credit spread widening.',
    `target_funded_ratio` DECIMAL(8,5) COMMENT 'Target ratio of plan assets to actuarial liabilities that the ALM model aims to achieve or maintain, expressed as a decimal proportion where 1.00 represents 100 percent funded status.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this ALM model configuration record was last modified, used for audit trail and change tracking.',
    `var_calculation_method` STRING COMMENT 'Methodology used within the ALM model to calculate Value at Risk for portfolio risk assessment: historical simulation, parametric variance-covariance, Monte Carlo simulation, Cornish-Fisher expansion, or not applicable if VaR is not calculated.. Valid values are `historical|parametric|monte_carlo|cornish_fisher|not_applicable`',
    `version_effective_timestamp` TIMESTAMP COMMENT 'Timestamp marking when this specific version of the ALM model configuration became effective, supporting temporal versioning and historical analysis.',
    CONSTRAINT pk_alm_model PRIMARY KEY(`alm_model_id`)
) COMMENT 'Master record for each Asset-Liability Management (ALM) model configuration maintained by the actuarial team. Captures model name, model version, model type (deterministic, stochastic, scenario-based), liability benchmark used, asset universe in scope';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`alm_scenario` (
    `alm_scenario_id` BIGINT COMMENT 'Unique identifier for the ALM scenario run. Primary key.',
    `alm_model_id` BIGINT COMMENT 'Reference to the ALM model configuration used for this scenario run.',
    `assumption_set_id` BIGINT COMMENT 'Foreign key linking to actuarial.assumption_set. Business justification: ALM scenarios use specific actuarial assumptions. While individual assumption values are captured on the scenario, linking to assumption_set provides the authoritative source and',
    `created_by_user_employee_id` BIGINT COMMENT 'Identifier of the analyst or system user who initiated this scenario run.',
    `discount_rate_curve_id` BIGINT COMMENT 'Foreign key linking to actuarial.discount_rate_curve. Business justification: ALM scenarios use specific discount rate curves for liability valuation. This links the scenario to the curve used, enabling analysis of scenario results by discount curve',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: ALM scenario analysis requires economic scenario inputs for stress testing funded ratios.',
    `employee_id` BIGINT COMMENT 'Identifier of the user or Investment Committee member who approved this scenario for official use.',
    `risk_stress_scenario_id` BIGINT COMMENT 'Foreign key linking to risk.stress_scenario. Business justification: ALM scenarios should reference standardized risk stress scenarios for integrated stress testing. Ensures actuarial and risk teams apply consistent shocks.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when this scenario was formally approved for reporting or decision-making purposes.',
    `asset_duration_years` DECIMAL(6,2) COMMENT 'Macaulay or modified duration of the asset portfolio under this scenario, measured in years.',
    `base_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts reported in this scenario.. Valid values are `^[A-Z]{3}$`',
    `benefit_indexation_percent` DECIMAL(5,2) COMMENT 'Annual percentage increase applied to pension benefits in payment to reflect cost-of-living adjustments.',
    `comments` STRING COMMENT 'Free-text field for analyst notes, observations, or special considerations related to this scenario run.',
    `completion_timestamp` TIMESTAMP COMMENT 'Date and time when the scenario run finished processing, whether successfully or with errors.',
    `contribution_rate_assumption_percent` DECIMAL(5,2) COMMENT 'Assumed employer and employee contribution rate as percentage of pensionable earnings for this scenario.',
    `convergence_tolerance` DECIMAL(10,8) COMMENT 'Numerical tolerance threshold used to determine convergence of iterative ALM calculations.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this scenario record was first created in the system.',
    `credit_spread_shock_bps` BIGINT COMMENT 'Basis point adjustment applied to credit spreads across fixed income and credit portfolios in this scenario.',
    `cvar_95_amount` DECIMAL(18,2) COMMENT 'Conditional Value at Risk (expected shortfall) at 95% confidence level for this scenario, in base currency.',
    `discount_rate_percent` DECIMAL(6,4) COMMENT 'Discount rate applied to liability cash flows for present value calculation in this scenario.',
    `duration_gap_years` DECIMAL(6,2) COMMENT 'Difference between asset duration and liability duration, indicating interest rate risk mismatch.',
    `equity_return_assumption_percent` DECIMAL(5,2) COMMENT 'Assumed annual equity market return percentage used in this scenario for public equity asset class projections.',
    `execution_timestamp` TIMESTAMP COMMENT 'Date and time when the scenario run was initiated by the ALM system or analyst.',
    `funded_ratio_result_percent` DECIMAL(6,2) COMMENT 'Calculated funded status ratio (assets divided by liabilities) resulting from this scenario run.',
    `fx_shock_percent` DECIMAL(5,2) COMMENT 'Percentage change applied to foreign exchange rates for multi-currency portfolio stress testing.',
    `inflation_shock_percent` DECIMAL(5,2) COMMENT 'Percentage point adjustment applied to baseline inflation assumptions for this scenario.',
    `infrastructure_return_assumption_percent` DECIMAL(5,2) COMMENT 'Assumed annual return percentage for infrastructure asset class in this scenario projection.',
    `interest_rate_shock_bps` BIGINT COMMENT 'Parallel shift applied to the yield curve in basis points (positive for upward shock, negative for downward shock).',
    `is_baseline` BOOLEAN COMMENT 'Flag indicating whether this scenario represents the baseline or central case for comparison purposes.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this scenario record was last updated or modified.',
    `liability_duration_years` DECIMAL(6,2) COMMENT 'Macaulay or modified duration of the pension liability cash flows under this scenario, measured in years.',
    `longevity_shock_years` DECIMAL(4,2) COMMENT 'Number of years added to life expectancy assumptions to stress-test longevity risk impact on pension liabilities.',
    `model_version_used` STRING COMMENT 'Specific version of the ALM model configuration used for this run, captured for auditability and reproducibility',
    `mortality_assumption_adjustment_percent` DECIMAL(5,2) COMMENT 'Percentage adjustment to baseline mortality tables used for liability projections in this scenario.',
    `output_metrics` STRING COMMENT 'JSON or structured text containing key output metrics from this scenario run, such as projected funded ratio, surplus/deficit, VaR, and duration gap under this scenario',
    `private_equity_return_assumption_percent` DECIMAL(5,2) COMMENT 'Assumed annual return percentage for private equity asset class in this scenario projection.',
    `projection_horizon_years` BIGINT COMMENT 'Number of years into the future that this scenario projects asset and liability cash flows.',
    `real_estate_return_assumption_percent` DECIMAL(5,2) COMMENT 'Assumed annual return percentage for real estate asset class in this scenario projection.',
    `regulatory_framework` STRING COMMENT 'Regulatory or accounting framework under which this scenario was executed (IFRS, FASB, Solvency II, Basel III, Local GAAP).. Valid values are `IFRS|FASB|Solvency_II|Basel_III|Local_GAAP`',
    `run_date` DATE COMMENT 'Date on which this ALM model was executed against this economic scenario',
    `salary_growth_assumption_percent` DECIMAL(5,2) COMMENT 'Assumed annual salary escalation rate for active members used in liability projections.',
    `scenario_description` STRING COMMENT 'Detailed narrative description of the scenario assumptions, purpose, and business context for this run.',
    `scenario_name` STRING COMMENT 'Business-friendly name assigned to this scenario run for identification and reporting purposes.',
    `scenario_run_reference` BIGINT COMMENT 'Unique identifier for this ALM scenario run record',
    `scenario_status` STRING COMMENT 'Current execution status of the scenario run within its lifecycle.. Valid values are `pending|running|completed|failed|cancelled|approved`',
    `scenario_type` STRING COMMENT 'Classification of the scenario methodology: base case, stress test, reverse stress, stochastic path, deterministic projection, or regulatory-mandated scenario.. Valid values are `base_case|stress|reverse_stress|stochastic|deterministic|regulatory`',
    `scenario_version` BIGINT COMMENT 'Version number of this scenario run, incremented when scenarios are re-run with updated assumptions.',
    `stochastic_path_count` BIGINT COMMENT 'Number of Monte Carlo simulation paths executed for stochastic scenario types.',
    `surplus_deficit_amount` DECIMAL(18,2) COMMENT 'Net surplus or deficit amount (assets minus liabilities) calculated in this scenario, in base currency.',
    `valuation_date` DATE COMMENT 'As-of date for asset and liability valuations used as the starting point for this scenario projection.',
    `var_95_amount` DECIMAL(18,2) COMMENT 'Value at Risk at 95% confidence level calculated for the portfolio under this scenario, in base currency.',
    `weight` DECIMAL(5,4) COMMENT 'Probability weight assigned to this scenario for this specific ALM model run, used in expected value calculations. May differ from the scenarios default probability_weight based on model-specific assumptions.',
    CONSTRAINT pk_alm_scenario PRIMARY KEY(`alm_scenario_id`)
) COMMENT 'Transactional record of each ALM scenario run executed against an ALM model. Captures scenario name, scenario type (base case, stress, reverse stress, stochastic path), interest rate shock applied, inflation shock, equity return assumption, credit spread';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`discount_rate_curve` (
    `discount_rate_curve_id` BIGINT COMMENT 'Unique identifier for the discount rate curve record. Primary key.',
    `approval_date` DATE COMMENT 'The date on which this discount rate curve was formally approved by the actuarial or investment committee for use in liability valuation.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee that approved this discount rate curve for operational use.',
    `benchmark_index` STRING COMMENT 'The market benchmark index or reference rate used as the foundation for constructing this curve, such as government bond yields or swap rates.',
    `calculation_methodology_document` STRING COMMENT 'Reference to the internal or external document that describes the detailed methodology and assumptions used to construct this discount rate curve.',
    `comments` STRING COMMENT 'Free-text field for additional notes, assumptions, or context regarding the construction or application of this discount rate curve.',
    `convergence_tenor_years` BIGINT COMMENT 'The tenor in years at which the curve converges to the ultimate forward rate in extrapolation methodologies such as Smith-Wilson.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this discount rate curve record was first created in the system.',
    `credit_quality_rating` STRING COMMENT 'The minimum credit quality or rating category of the bonds used to construct the curve, relevant for IAS 19 high-quality corporate bond curves.. Valid values are `aaa|aa|a|bbb|high_quality|investment_grade`',
    `credit_spread_adjustment_bps` DECIMAL(8,2) COMMENT 'The credit spread adjustment in basis points applied to the base curve to reflect credit risk or regulatory requirements.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code indicating the currency denomination of the discount rates in this curve.. Valid values are `^[A-Z]{3}$`',
    `curve_construction_date` DATE COMMENT 'The date on which this discount rate curve was constructed or calibrated using market data.',
    `curve_name` STRING COMMENT 'Business name or label assigned to this discount rate curve for identification and reference purposes.',
    `curve_status` STRING COMMENT 'Current lifecycle status of the discount rate curve indicating whether it is active for use, superseded by a newer curve, in draft, or archived.. Valid values are `active|superseded|draft|archived|under_review|approved`',
    `curve_type` STRING COMMENT 'Classification of the discount rate curve methodology. Indicates the source or construction approach for the curve such as regulator-prescribed, IAS 19 corporate bond yield, risk-free rate, or custom blend.',
    `curve_version` STRING COMMENT 'Version identifier for this discount rate curve, used to track revisions and updates over time.',
    `data_source_reference` STRING COMMENT 'Reference identifier or URL pointing to the specific market data source or dataset used to construct this curve.',
    `effective_date` DATE COMMENT 'The date from which this discount rate curve becomes applicable for liability valuation and actuarial calculations.',
    `expiry_date` DATE COMMENT 'The date on which this discount rate curve ceases to be valid or is superseded by a new curve. Nullable for currently active curves.',
    `extrapolation_method` STRING COMMENT 'The method used to extend the curve beyond the longest explicitly defined tenor for long-duration liability matching.. Valid values are `flat|linear|smith_wilson|ultimate_forward_rate`',
    `interpolation_method` STRING COMMENT 'The mathematical interpolation technique applied to derive rates between explicitly defined tenors on the curve.. Valid values are `linear|cubic_spline|nelson_siegel|log_linear|flat_forward`',
    `jurisdiction` STRING COMMENT 'Three-letter ISO country code representing the legal or regulatory jurisdiction for which this curve is applicable.. Valid values are `^[A-Z]{3}$`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The date and time when this discount rate curve record was last updated or modified.',
    `liquid_point_tenor_years` BIGINT COMMENT 'The maximum tenor in years up to which market data is considered sufficiently liquid and reliable for direct curve construction.',
    `liquidity_premium_bps` DECIMAL(8,2) COMMENT 'The liquidity premium in basis points added to the curve to compensate for illiquidity in the underlying bond market.',
    `matching_adjustment_bps` DECIMAL(8,2) COMMENT 'The matching adjustment in basis points applied when assets and liabilities are closely matched, reducing discount rate volatility under certain regulatory regimes.',
    `maximum_tenor_years` BIGINT COMMENT 'The longest maturity tenor in years for which a discount rate is explicitly defined or extrapolated in this curve.',
    `minimum_tenor_years` BIGINT COMMENT 'The shortest maturity tenor in years for which a discount rate is explicitly defined in this curve.',
    `modified_by` STRING COMMENT 'Identifier of the user or system process that last modified this discount rate curve record.',
    `regulatory_framework` STRING COMMENT 'The regulatory or accounting standard under which this curve is constructed and applied, such as IFRS, IAS 19, actuarial standards of practice, or the national pension regulator guidelines. [ENUM-REF-CANDIDATE: ifrs|ias19|fasb|eiopa|local_gaap — promote to reference product]',
    `source_data_provider` STRING COMMENT 'The external vendor or internal system that supplied the underlying market data used to construct this curve, such as Bloomberg, Refinitiv, or internal treasury.',
    `tenor_increment_years` DECIMAL(5,2) COMMENT 'The standard interval in years between successive tenor points on the curve, such as 0.5 for semi-annual or 1.0 for annual.',
    `term_structure_type` STRING COMMENT 'Indicates the rate convention used in the term structure: spot rates, forward rates, par yields, or zero-coupon rates.. Valid values are `spot_rate|forward_rate|par_yield|zero_coupon`',
    `ultimate_forward_rate` DECIMAL(10,6) COMMENT 'The long-term forward rate assumption used for extrapolation beyond the liquid point of the curve, expressed as a decimal rate.',
    `usage_scope` STRING COMMENT 'Description of the intended use cases for this curve, such as financial reporting, regulatory reporting, internal ALM, or strategic asset allocation. [ENUM-REF-CANDIDATE: financial_reporting|regulatory_reporting|alm|saa|stress_testing|internal_valuation —',
    `valuation_date` DATE COMMENT 'The as-of date for which this discount rate curve is used to value pension liabilities in actuarial reports and financial statements.',
    `volatility_adjustment_bps` DECIMAL(8,2) COMMENT 'The volatility adjustment in basis points applied under certain regulatory frameworks to dampen the impact of short-term market volatility on liability valuations.',
    CONSTRAINT pk_discount_rate_curve PRIMARY KEY(`discount_rate_curve_id`)
) COMMENT 'Master record for each discount rate curve used to value pension liabilities. Captures curve name, curve type (regulator-prescribed, IAS 19 corporate bond yield, risk-free, custom blend), effective date, currency, term structure (spot rates by tenor from 1Y to';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`mortality_table` (
    `mortality_table_id` BIGINT COMMENT 'Unique identifier for the mortality table record. Primary key.',
    `primary_predecessor_table_mortality_table_id` BIGINT COMMENT 'Reference to the previous mortality table that this table supersedes or replaces.',
    `accounting_standard_alignment` STRING COMMENT 'Accounting standard or framework the mortality table is aligned with (e.g., IFRS, ASPE, US GAAP).',
    `adjustment_factor` DECIMAL(10,6) COMMENT 'Scalar adjustment factor applied to base mortality rates to reflect plan-specific or population-specific experience (e.g., 0.95 for 5% mortality reduction).',
    `age_range_maximum` BIGINT COMMENT 'Maximum age (in years) for which mortality rates are defined in the table.',
    `age_range_minimum` BIGINT COMMENT 'Minimum age (in years) for which mortality rates are defined in the table.',
    `base_year` BIGINT COMMENT 'Reference year for which the mortality rates in the table are calibrated or anchored.',
    `blend_percentage` DECIMAL(5,2) COMMENT 'Percentage weighting used when blending multiple mortality tables to create a custom table (expressed as percentage, e.g., 75.00 for 75%).',
    `collar_adjustment_type` STRING COMMENT 'Indicates whether the table includes adjustments for white-collar, blue-collar, or mixed workforce mortality experience.. Valid values are `white_collar|blue_collar|mixed|none`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the mortality table record was first created in the system.',
    `credibility_weighting` DECIMAL(5,4) COMMENT 'Credibility weight assigned to plan-specific experience versus standard table rates (0.0 to 1.0, where 1.0 is full credibility).',
    `data_source_description` STRING COMMENT 'Detailed description of the data sources, experience studies, or research used to develop the mortality table.',
    `disabled_mortality_flag` BOOLEAN COMMENT 'Indicates whether the table is designed for disabled or ill-health populations with higher mortality rates.',
    `documentation_reference` STRING COMMENT 'Reference to external documentation, research papers, or technical reports describing the mortality table in detail.',
    `effective_date` DATE COMMENT 'Date from which the mortality table is effective and applicable for actuarial liability calculations.',
    `expiry_date` DATE COMMENT 'Date on which the mortality table is no longer valid or has been superseded by a newer table.',
    `gender_applicability` STRING COMMENT 'Indicates whether the mortality table applies to male, female, unisex, or combined populations.. Valid values are `male|female|unisex|combined`',
    `generational_projection_flag` BOOLEAN COMMENT 'Indicates whether the table supports generational mortality projections based on year of birth cohorts.',
    `geographic_scope` STRING COMMENT 'Geographic region or jurisdiction for which the mortality table is applicable (e.g., United States, United Kingdom, Netherlands).',
    `healthy_annuitant_flag` BOOLEAN COMMENT 'Indicates whether the table is designed for healthy annuitants (as opposed to disabled or ill-health populations).',
    `improvement_scale_flag` BOOLEAN COMMENT 'Indicates whether the table includes mortality improvement factors for generational projections.',
    `internal_approval_date` DATE COMMENT 'Date on which the mortality table was approved for use by the internal Investment Committee (IC) or actuarial governance body.',
    `last_review_date` DATE COMMENT 'Date of the most recent actuarial review or validation of the mortality table for continued appropriateness.',
    `longevity_risk_adjustment` DECIMAL(10,6) COMMENT 'Additional adjustment factor applied to account for longevity risk or uncertainty in future mortality improvements.',
    `methodology_notes` STRING COMMENT 'Technical notes describing the actuarial methodology, smoothing techniques, or statistical models used to construct the table.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the mortality table record was last modified or updated.',
    `mortality_basis` STRING COMMENT 'Underlying data source or experience study used to construct the mortality table (e.g., pension plan experience, population census data).',
    `next_review_date` DATE COMMENT 'Scheduled date for the next actuarial review or reassessment of the mortality table.',
    `population_segment` STRING COMMENT 'Specific population segment or cohort the mortality table is designed for (e.g., public sector employees, private sector, annuitants, pensioners).',
    `publication_year` BIGINT COMMENT 'Year the mortality table was officially published or released by the source organization.',
    `regulatory_approval_date` DATE COMMENT 'Date on which the mortality table received regulatory approval for statutory use.',
    `regulatory_approval_status` STRING COMMENT 'Current regulatory approval status of the mortality table for use in statutory actuarial valuations.. Valid values are `approved|pending|not_required|withdrawn`',
    `source_organization` STRING COMMENT 'Organization or body that published or developed the mortality table (e.g., Society of Actuaries, custom internal).',
    `table_code` STRING COMMENT 'Short alphanumeric code or identifier for the mortality table used in actuarial systems and calculations.',
    `table_name` STRING COMMENT 'Official name of the mortality table or improvement scale (e.g., RP-2014, Pri-2012, S3PMA).',
    `table_type` STRING COMMENT 'Classification of the mortality table indicating its purpose and application method in liability calculations.. Valid values are `base_mortality|improvement_scale|generational_projection|static_projection|custom_blend`',
    `usage_status` STRING COMMENT 'Current usage status of the mortality table within the organizations actuarial valuation processes.. Valid values are `active|superseded|archived|under_review`',
    `valuation_purpose` STRING COMMENT 'Primary purpose for which the mortality table is used (e.g., going concern valuation, solvency valuation, accounting valuation, funding valuation).',
    `version_number` STRING COMMENT 'Version identifier for the mortality table, used to track revisions and updates over time.',
    CONSTRAINT pk_mortality_table PRIMARY KEY(`mortality_table_id`)
) COMMENT 'Master record for each mortality table or improvement scale used in actuarial liability calculations. Captures table name, table type (base mortality, improvement scale, generational projection), source (RP-2014, Pri-2012, custom blend)';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`assumption_set` (
    `assumption_set_id` BIGINT COMMENT 'Unique surrogate key for each actuarial assumption set.',
    `capital_market_assumption_id` BIGINT COMMENT 'Foreign key linking to research.capital_market_assumption. Business justification: Actuarial assumption sets require capital market assumptions for expected returns on plan assets.',
    `credit_yield_curve_id` BIGINT COMMENT 'Reference to the risk‑free rate curve used for discounting.',
    `discount_rate_curve_id` BIGINT COMMENT 'Reference to the discount rate curve used for present‑value calculations.',
    `mortality_table_id` BIGINT COMMENT 'Reference to the mortality table applied in the liability projection.',
    `asset_liability_duration` DECIMAL(10,2) COMMENT 'Weighted average duration of assets versus liabilities, expressed in years.',
    `assumption_set_status` STRING COMMENT 'Current lifecycle status of the assumption set.. Valid values are `active|inactive|archived|draft`',
    `assumption_set_code` STRING COMMENT 'Business identifier or short code used in reporting and downstream systems.',
    `contribution_rate` DECIMAL(5,4) COMMENT 'Assumed annual contribution rate as a proportion of payroll.',
    `created_by_role` STRING COMMENT 'Role of the user or system that created the record.. Valid values are `actuary|admin|system`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was first created in the system.',
    `currency` STRING COMMENT 'ISO 4217 currency code for monetary assumptions.. Valid values are `USD|CAD|EUR|GBP|JPY|CHF`',
    `assumption_set_description` STRING COMMENT 'Free‑form description of the purpose, scope, and key characteristics of the assumption set.',
    `effective_date` DATE COMMENT 'Date on which the assumptions become effective for liability valuation.',
    `expiration_date` DATE COMMENT 'Optional date when the assumption set ceases to be valid; null for open‑ended sets.',
    `funded_status_percent` DECIMAL(5,2) COMMENT 'Current funded status expressed as a percentage of total liability.',
    `inflation_rate` DECIMAL(5,4) COMMENT 'Annual inflation rate applied to cash‑flow projections (e.g., 0.0250 = 2.5%).',
    `is_default` BOOLEAN COMMENT 'Indicates whether this set is the default for new liability runs.',
    `last_review_date` DATE COMMENT 'Date when the assumption set was last reviewed by actuarial governance.',
    `ldi_strategy` STRING COMMENT 'Strategic approach used to align assets with liabilities.. Valid values are `duration_matching|cash_flow_matching|risk_based|custom`',
    `liability_projection_years` BIGINT COMMENT 'Number of years forward the liability cash‑flow model projects.',
    `assumption_set_name` STRING COMMENT 'Human‑readable name identifying the set of actuarial assumptions.',
    `review_cycle_months` BIGINT COMMENT 'Standard interval in months between mandatory reviews of the assumption set.',
    `updated_by` STRING COMMENT 'User identifier of the person or system that performed the last update.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the record.',
    `version` BIGINT COMMENT 'Integer version number incremented each time the set is revised.',
    `created_by` STRING COMMENT 'User identifier of the person or system that created the assumption set.',
    CONSTRAINT pk_assumption_set PRIMARY KEY(`assumption_set_id`)
) COMMENT 'Master record defining a complete, versioned, effective-dated set of actuarial assumptions used in a liability valuation or ALM run. Captures assumption set name, effective date, discount_rate_curve reference, mortality_table reference, inflation rate';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`funded_status` (
    `funded_status_id` BIGINT COMMENT 'Unique identifier for the funded status record.',
    `assumption_set_id` BIGINT COMMENT 'Foreign key linking to actuarial.assumption_set. Business justification: Funded status calculations use specific actuarial assumptions. Linking to assumption_set replaces the denormalized assumption_version string with a proper FK to the authoritative',
    `fund_id` BIGINT COMMENT 'Identifier of the pension fund to which this measurement applies.',
    `liability_projection_id` BIGINT COMMENT 'Foreign key linking to actuarial.liability_projection. Business justification: Funded status calculations compare assets to liabilities. This links to the specific liability projection used in the funded ratio calculation.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_asset_valuation. Business justification: Funded ratio reporting: Funded status calculations require reconciliation between actuarial asset values and investment portfolio valuations.',
    `asset_market_value` DECIMAL(20,4) COMMENT 'Aggregate market value of all assets held by the fund at the measurement date.',
    `asset_to_liability_ratio` DECIMAL(6,4) COMMENT 'Ratio of asset market value to liability on a solvency basis, expressed as a decimal.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the funded status record was first created in the system.',
    `currency_code` STRING COMMENT 'Three‑letter ISO 4217 code of the reporting currency for monetary amounts.. Valid values are `^[A-Z]{3}$`',
    `discount_rate` DECIMAL(6,4) COMMENT 'Interest rate used to discount future cash‑flows in the actuarial liability calculation.',
    `funded_ratio` DECIMAL(6,4) COMMENT 'Ratio of total asset market value to total actuarial liability (gross), expressed as a decimal.',
    `liability_gross` DECIMAL(20,4) COMMENT 'Total actuarial liability on a going‑concern basis, expressed in the reporting currency.',
    `liability_solvent` DECIMAL(20,4) COMMENT 'Total actuarial liability on a solvency basis, expressed in the reporting currency.',
    `measurement_status` STRING COMMENT 'Current status of the measurement, indicating whether it is preliminary, final, or adjusted.. Valid values are `preliminary|final|adjusted`',
    `measurement_timestamp` TIMESTAMP COMMENT 'Exact date and time when the funded status measurement was taken.',
    `notes` STRING COMMENT 'Free‑form field for any supplemental information or comments about the measurement.',
    `scenario` STRING COMMENT 'Scenario under which the funded status was calculated, such as base case or stress scenario.. Valid values are `base|stress|adverse`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the funded status record.',
    CONSTRAINT pk_funded_status PRIMARY KEY(`funded_status_id`)
) COMMENT 'Transactional record capturing the funded status of the pension fund at a specific measurement date. Captures measurement date, total actuarial liability (going-concern and solvency bases), total market value of assets, funded ratio (assets/liabilities)';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`contribution_rate_model` (
    `contribution_rate_model_id` BIGINT COMMENT 'System-generated unique identifier for the contribution rate model.',
    `assumption_set_id` BIGINT COMMENT 'Foreign key linking to actuarial.assumption_set. Business justification: Contribution rate models depend on actuarial assumptions for calculating required contribution rates. This links the model to its governing assumption set.',
    `contributor_pool_id` BIGINT COMMENT 'Identifier of the contributor pool (e.g., one of the participating plans) to which the model applies.',
    `liability_projection_id` BIGINT COMMENT 'Foreign key linking to actuarial.liability_projection. Business justification: Contribution rates are calculated based on liability projections. This links the contribution model to the specific liability projection driving the rate calculation.',
    `applicable_region` STRING COMMENT 'Three‑letter ISO country code indicating the jurisdiction of the model.',
    `approval_date` DATE COMMENT 'Date when the model received regulatory approval.',
    `comments` STRING COMMENT 'Free‑form notes or remarks about the model.',
    `contribution_rate_model_status` STRING COMMENT 'Current lifecycle status of the model.. Valid values are `active|inactive|retired|draft`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the contribution rate model record was created.',
    `effective_date` DATE COMMENT 'Date on which the contribution rate model becomes effective.',
    `employee_normal_cost_rate` DECIMAL(10,4) COMMENT 'Employee contribution rate expressed as a percentage of payroll.',
    `employer_normal_cost_rate` DECIMAL(10,4) COMMENT 'Employer contribution rate expressed as a percentage of payroll (e.g., 0.0750 = 7.50%).',
    `expiration_date` DATE COMMENT 'Date on which the contribution rate model expires or is superseded; null for open‑ended models.',
    `frequency` STRING COMMENT 'Frequency at which contributions are applied.. Valid values are `monthly|quarterly|annually`',
    `is_default` BOOLEAN COMMENT 'Flag indicating whether this model is the default for its contributor pool.',
    `last_review_date` DATE COMMENT 'Date of the most recent actuarial review of the model.',
    `model_code` STRING COMMENT 'Business code used to reference the model in actuarial and investment systems.',
    `model_name` STRING COMMENT 'Human‑readable name of the contribution rate model.',
    `model_type` STRING COMMENT 'Classification of the model (e.g., statutory, voluntary, special).. Valid values are `statutory|voluntary|special`',
    `rate_basis` STRING COMMENT 'Basis on which the contribution rates are calculated.. Valid values are `payroll|salary|benefit|total_compensation`',
    `regulatory_approval_status` STRING COMMENT 'Status of regulatory approval (e.g., the national pension regulator) for the model.. Valid values are `pending|approved|rejected`',
    `special_contribution_rate` DECIMAL(10,4) COMMENT 'Additional contribution rate applied under special circumstances (e.g., catch‑up contributions).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the model record.',
    `version_number` BIGINT COMMENT 'Incremental version identifier for change management.',
    CONSTRAINT pk_contribution_rate_model PRIMARY KEY(`contribution_rate_model_id`)
) COMMENT 'Master record for each contribution rate model defining the required employer and employee contribution rates for a contributor pool. Captures model name, contributor pool, effective date, normal cost rate (employer), normal cost rate (employee), special';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`special_payment_schedule` (
    `special_payment_schedule_id` BIGINT COMMENT 'Unique surrogate identifier for the special payment schedule record.',
    `liability_projection_id` BIGINT COMMENT 'Foreign key linking to actuarial.liability_projection. Business justification: Special payment schedules address funding deficits identified in liability projections.',
    `amortization_period_years` BIGINT COMMENT 'Number of years over which the deficiency will be amortized.',
    `approval_date` DATE COMMENT 'Date on which the schedule received formal approval.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the schedule record was first created in the system.',
    `currency_code` STRING COMMENT 'Three‑letter ISO 4217 currency identifier for monetary amounts.',
    `deficiency_type` STRING COMMENT 'Classification of the underlying deficiency that the schedule is designed to amortize.. Valid values are `solvency|going_concern`',
    `special_payment_schedule_description` STRING COMMENT 'Free‑form description providing context and rationale for the schedule.',
    `discount_rate` DECIMAL(5,4) COMMENT 'Rate used to discount future payments to present value for reporting.',
    `effective_from` DATE COMMENT 'Date on which the special payment schedule becomes effective.',
    `effective_until` DATE COMMENT 'Date on which the special payment schedule terminates or is superseded; null for open‑ended schedules.',
    `interest_rate` DECIMAL(5,4) COMMENT 'Annual interest rate applied to the deficiency balance for amortization calculations.',
    `is_taxable` BOOLEAN COMMENT 'Indicates whether the amortization payments are subject to tax.',
    `last_review_date` DATE COMMENT 'Date of the most recent internal review of the schedule.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the schedule record.',
    `net_present_value` DECIMAL(20,2) COMMENT 'Present value of all scheduled payments using the discount rate.',
    `next_review_date` DATE COMMENT 'Planned date for the next scheduled review of the schedule.',
    `notes` STRING COMMENT 'Supplementary free‑text notes captured by actuaries or governance.',
    `payment_amount` DECIMAL(20,2) COMMENT 'Calculated monetary amount of each scheduled amortization payment.',
    `payment_frequency` STRING COMMENT 'Regular interval at which amortization payments are scheduled.. Valid values are `annual|semiannual|quarterly|monthly`',
    `regulatory_approval_date` DATE COMMENT 'Date on which regulatory approval was granted.',
    `regulatory_approval_status` STRING COMMENT 'Status of the schedules approval by relevant regulators (e.g., the national pension regulator).. Valid values are `approved|pending|rejected`',
    `schedule_code` STRING COMMENT 'Alphanumeric code used to uniquely reference the special payment schedule in external systems.',
    `schedule_name` STRING COMMENT 'Human‑readable name of the special payment schedule.',
    `special_payment_schedule_status` STRING COMMENT 'Current lifecycle status of the special payment schedule.. Valid values are `active|inactive|closed|pending`',
    `tax_rate` DECIMAL(5,4) COMMENT 'Applicable tax rate applied to each payment when taxable.',
    `total_deficiency_amount` DECIMAL(20,2) COMMENT 'Monetary amount of the solvency or going‑concern deficiency to be amortized.',
    `version_number` BIGINT COMMENT 'Incremental version identifier for change management of the schedule.',
    CONSTRAINT pk_special_payment_schedule PRIMARY KEY(`special_payment_schedule_id`)
) COMMENT 'Master record for each special payment (deficit amortization payment) schedule established to eliminate a solvency or going-concern deficiency. Captures schedule name, deficiency type (solvency, going-concern), total deficiency amount, amortization period';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`ldi_strategy` (
    `ldi_strategy_id` BIGINT COMMENT 'System-generated unique identifier for the LDI strategy record.',
    `assumption_set_id` BIGINT COMMENT 'Reference to the inflation assumption set used for liability growth forecasts.',
    `discount_rate_curve_id` BIGINT COMMENT 'Reference to the discount rate curve used for present‑value calculations.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: LDI strategies must be validated against economic scenarios to ensure hedge effectiveness under different rate/inflation environments.',
    `inflation_assumption_assumption_set_id` BIGINT COMMENT 'Reference to the inflation assumption set used for liability growth forecasts.',
    `mortality_table_id` BIGINT COMMENT 'Reference to the mortality table applied in actuarial projections.',
    `netting_agreement_id` BIGINT COMMENT 'Foreign key linking to collateral.netting_agreement. Business justification: LDI strategies execute derivative hedges governed by netting agreements that determine close-out netting rights and collateral terms.',
    `approval_date` DATE COMMENT 'Date on which the strategy received formal approval.',
    `approved_by` STRING COMMENT 'Name of the investment committee member or senior officer who approved the strategy.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the strategy record was first created in the system.',
    `currency` STRING COMMENT 'Three‑letter ISO 4217 code of the currency used for strategy amounts.',
    `ldi_strategy_description` STRING COMMENT 'Detailed free‑text description of the strategy purpose, methodology and scope.',
    `duration_target_years` DECIMAL(5,2) COMMENT 'Target portfolio duration in years to match liability duration.',
    `effective_end_date` DATE COMMENT 'Date on which the strategy is scheduled to expire or be retired; null for open‑ended.',
    `effective_start_date` DATE COMMENT 'Date on which the strategy becomes effective for portfolio implementation.',
    `funded_ratio_target` DECIMAL(5,2) COMMENT 'Desired funded status (assets / liabilities) expressed as a percentage.',
    `governance_approval_status` STRING COMMENT 'Current approval state of the strategy by the investment committee.. Valid values are `pending|approved|rejected`',
    `hedge_ratio_target` DECIMAL(5,2) COMMENT 'Desired percentage of liability cash‑flows hedged by assets, expressed in percent.',
    `interest_rate_hedge_type` STRING COMMENT 'Method used to hedge interest‑rate exposure.. Valid values are `duration|cash_flow|both`',
    `last_review_date` DATE COMMENT 'Date of the most recent formal review of the strategy.',
    `ldi_strategy_status` STRING COMMENT 'Current lifecycle status of the strategy.. Valid values are `active|inactive|draft|retired`',
    `liability_hedge_method` STRING COMMENT 'Approach used to match liabilities (duration matching, cash‑flow matching, or hybrid).. Valid values are `duration|cash_flow|both`',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the strategy record.',
    `next_review_date` DATE COMMENT 'Planned date for the next scheduled review of the strategy.',
    `risk_tolerance_level` STRING COMMENT 'Qualitative risk appetite assigned to the strategy.. Valid values are `low|medium|high`',
    `strategy_code` STRING COMMENT 'Short alphanumeric code used to reference the strategy in systems and reports.',
    `strategy_name` STRING COMMENT 'Human‑readable name of the LDI strategy as defined by the actuarial team.',
    `strategy_type` STRING COMMENT 'Classification of the strategy based on hedge approach.. Valid values are `full_hedge|partial_hedge|dynamic_derisking`',
    `stress_test_scenario` STRING COMMENT 'Selected macro‑economic stress scenario for strategy robustness testing.. Valid values are `base|adverse|severe|optimistic|inflation_shock|interest_rate_spike`',
    `target_allocation_alternative_pct` DECIMAL(5,2) COMMENT 'Desired allocation to alternatives (private equity, real estate, infrastructure, etc.) as a percentage.',
    `target_allocation_cash_pct` DECIMAL(5,2) COMMENT 'Desired cash or cash‑equivalent allocation as a percentage of total assets.',
    `target_allocation_equity_pct` DECIMAL(5,2) COMMENT 'Desired equity exposure as a percentage of total assets.',
    `target_allocation_fixed_income_pct` DECIMAL(5,2) COMMENT 'Desired fixed‑income exposure as a percentage of total assets.',
    CONSTRAINT pk_ldi_strategy PRIMARY KEY(`ldi_strategy_id`)
) COMMENT 'Master record for each Liability-Driven Investment (LDI) strategy defined by the actuarial and investment teams. Captures strategy name, strategy type (full hedge, partial hedge, dynamic de-risking), liability hedge ratio target, interest rate hedge';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`ldi_hedge_position` (
    `ldi_hedge_position_id` BIGINT COMMENT 'System-generated unique identifier for the LDI hedge position record.',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: LDI hedge positions represent derivative hedges (interest rate swaps, inflation swaps) executed with specific counterparties.',
    `instrument_id` BIGINT COMMENT 'Foreign key linking to trade.instrument. Business justification: LDI hedge positions implement liability hedges using specific financial instruments (interest rate swaps, inflation-linked bonds).',
    `ldi_strategy_id` BIGINT COMMENT 'Foreign key linking to actuarial.ldi_strategy. Business justification: LDI hedge positions implement specific LDI strategies. This links the transactional hedge position to its governing actuarial LDI strategy definition.',
    `manager_gp_profile_id` BIGINT COMMENT 'Identifier of the portfolio manager responsible for the hedge position.',
    `strategy_id` BIGINT COMMENT 'Reference to the investment strategy for which the hedge is held.',
    `st_instrument_transaction_id` BIGINT COMMENT 'External business identifier assigned to the hedge position transaction.',
    `comments` STRING COMMENT 'Free‑form notes or remarks about the hedge position.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the hedge position record was first created in the system.',
    `dv01_unit` STRING COMMENT 'Unit used for DV01 values (basis points).. Valid values are `bps|bp|basis_point`',
    `effective_from` DATE COMMENT 'Start date when the hedge position became effective.',
    `effective_until` DATE COMMENT 'End date when the hedge position expires or is terminated (nullable).',
    `hedge_currency_code` STRING COMMENT 'Three‑letter ISO currency code of the hedge notional.. Valid values are `^[A-Z]{3}$`',
    `hedge_notional_amount` DECIMAL(20,4) COMMENT 'Nominal amount of the hedge expressed in the hedge currency.',
    `hedge_portfolio_dv01` DECIMAL(20,6) COMMENT 'Dollar value of a one‑basis‑point change in the hedge portfolios interest rate exposure.',
    `is_hedge_active` BOOLEAN COMMENT 'Indicates whether the hedge position is currently active.',
    `last_valuation_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent valuation run for the hedge position.',
    `ldi_hedge_position_status` STRING COMMENT 'Current lifecycle status of the hedge position.. Valid values are `active|inactive|closed|pending`',
    `liability_dv01` DECIMAL(20,6) COMMENT 'Dollar value of a one‑basis‑point change in the liability curve.',
    `measurement_timestamp` TIMESTAMP COMMENT 'Date and time when the hedge position measurement was taken.',
    `risk_factor` STRING COMMENT 'Key risk factor driving the hedge (e.g., interest rate).. Valid values are `interest_rate|inflation|credit_spread`',
    `scenario_code` STRING COMMENT 'Identifier of the economic/actuarial scenario applied to the hedge measurement.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the hedge position record.',
    `valuation_method` STRING COMMENT 'Methodology used to value the hedge position.. Valid values are `duration_matching|cash_flow_matching|duration_hedge|interest_rate_swap|futures|options`',
    CONSTRAINT pk_ldi_hedge_position PRIMARY KEY(`ldi_hedge_position_id`)
) COMMENT 'Transactional record capturing the current LDI hedge position for a given strategy and measurement date. Captures strategy reference, measurement date, nominal hedge notional, interest rate DV01 of liabilities, interest rate DV01 of hedge portfolio';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`liability_cash_flow` (
    `liability_cash_flow_id` BIGINT COMMENT 'Unique identifier for the liability cash flow projection record.',
    `assumption_set_id` BIGINT COMMENT 'Foreign key linking to actuarial.assumption_set. Business justification: Liability cash flows use specific actuarial assumptions. Linking to assumption_set replaces the denormalized assumptions_version string with a proper FK to the authoritative',
    `contributor_pool_id` BIGINT COMMENT 'Identifier of the contributor pool (e.g., one of the participating plans).',
    `liability_projection_id` BIGINT COMMENT 'Foreign key linking to actuarial.liability_projection. Business justification: Liability cash flows are disaggregated projections derived from a parent liability projection.',
    `actuary_firm` STRING COMMENT 'Firm of the actuary responsible.',
    `actuary_name` STRING COMMENT 'Name of the actuary responsible for the projection.',
    `audit_trail_reference` BIGINT COMMENT 'Identifier linking to audit trail records for this projection.',
    `cash_flow_amount` DECIMAL(20,4) COMMENT 'Projected liability cash flow amount for the period.',
    `cash_flow_year` BIGINT COMMENT 'Fiscal year of the cash flow (e.g., 2025).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the projection record was created.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code of the cash flow amount.. Valid values are `[A-Z]{3}`',
    `disability_rate_used` DECIMAL(5,4) COMMENT 'Assumed disability incidence rate used.',
    `discount_rate_used` DECIMAL(5,4) COMMENT 'Discount rate applied to present value the cash flow.',
    `funding_status` STRING COMMENT 'Funding status of the liability at projection date.. Valid values are `underfunded|fully_funded|overfunded`',
    `inflation_rate_used` DECIMAL(5,4) COMMENT 'Assumed inflation rate for the projection period.',
    `liability_cash_flow_status` STRING COMMENT 'Current lifecycle status of the cash flow projection.. Valid values are `projected|approved|revised|rejected`',
    `liability_type` STRING COMMENT 'Type of liability component represented by the cash flow.. Valid values are `pbo|abo|service_cost|interest_cost|actuarial_gain_loss`',
    `model_version` STRING COMMENT 'Version of the actuarial model used for the projection.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the record.',
    `mortality_improvement_scale_used` STRING COMMENT 'Identifier of the mortality improvement scale applied.',
    `mortality_table_used` STRING COMMENT 'Identifier of the mortality table applied in the projection.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding the projection.',
    `projection_date` DATE COMMENT 'Date for which the liability cash flow is projected.',
    `projection_horizon_years` BIGINT COMMENT 'Number of years forward the projection covers.',
    `projection_scenario` STRING COMMENT 'Scenario used for the projection (e.g., base, stress).. Valid values are `base|stress_up|stress_down|adverse|optimistic`',
    `regulatory_approval_date` DATE COMMENT 'Date when regulatory approval was granted.',
    `regulatory_approval_status` STRING COMMENT 'Regulatory filing status of the projection.. Valid values are `pending|approved|rejected`',
    `retirement_age_assumption` BIGINT COMMENT 'Assumed retirement age used in the projection.',
    `salary_growth_rate_used` DECIMAL(5,4) COMMENT 'Assumed salary growth rate used in the projection.',
    `segment_type` STRING COMMENT 'Category of members for which the cash flow is projected.. Valid values are `active|deferred|retiree|survivor`',
    `turnover_rate_used` DECIMAL(5,4) COMMENT 'Assumed employee turnover rate for the projection.',
    CONSTRAINT pk_liability_cash_flow PRIMARY KEY(`liability_cash_flow_id`)
) COMMENT 'Transactional record of disaggregated projected liability by contributor pool, segment, and year, derived from the actuarial liability projection. Captures projection date, contributor pool, segment type (active, deferred, retiree, survivor), projection';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`saa_constraint` (
    `saa_constraint_id` BIGINT COMMENT 'Unique system-generated identifier for the SAA constraint record.',
    `assumption_set_id` BIGINT COMMENT 'Foreign key linking to actuarial.assumption_set. Business justification: SAA constraints are actuarially-derived limits on asset allocation. This links the constraint to the assumption set used in deriving the constraint, ensuring consistency with',
    `created_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: SAA constraints govern asset allocation limits; investment policy governance requires documenting constraint creator. created_by is text, need proper FK.',
    `ldi_strategy_id` BIGINT COMMENT 'Foreign key linking to actuarial.ldi_strategy. Business justification: SAA constraint applies to a specific LDI strategy; FK provides reference and removes duplicate ldi_strategy_id if present.',
    `applies_to_asset_class` STRING COMMENT 'Asset class to which the constraint is applied.. Valid values are `equity|fixed_income|real_asset|private_equity|infrastructure|cash`',
    `applies_to_geography` STRING COMMENT 'Geographic scope for which the constraint is relevant.. Valid values are `global|domestic|emerging|developed`',
    `saa_constraint_code` STRING COMMENT 'Unique alphanumeric code used to reference the constraint in systems and reports.',
    `compliance_flag` BOOLEAN COMMENT 'True if the constraint satisfies a specific regulatory requirement.',
    `constraint_category` STRING COMMENT 'High‑level grouping of the constraint purpose.. Valid values are `duration|allocation|risk|liquidity`',
    `constraint_type` STRING COMMENT 'Category of the constraint defining the business rule applied to the strategic asset allocation.. Valid values are `min_duration|max_equity|min_real_asset|max_credit|min_liquidity|max_volatility`',
    `created_timestamp` TIMESTAMP COMMENT 'Date‑time when the constraint record was first created in the system.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Numeric score (0‑100) reflecting the confidence in the underlying data supporting the constraint.',
    `saa_constraint_description` STRING COMMENT 'Detailed free‑text description of the business rationale and application of the constraint.',
    `effective_from` DATE COMMENT 'Date on which the constraint becomes binding.',
    `effective_until` DATE COMMENT 'Date on which the constraint expires or is superseded; null for open‑ended.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether the constraint must be enforced in all allocation models.',
    `last_review_date` DATE COMMENT 'Date of the most recent formal review of the constraint.',
    `last_updated_by` STRING COMMENT 'User identifier of the person who performed the most recent update.',
    `measurement_unit` STRING COMMENT 'Unit of measure for the measurement_value field.. Valid values are `years|percent|bps|ratio`',
    `measurement_value` DECIMAL(20,6) COMMENT 'Numeric value representing the constraint magnitude (e.g., % allocation, years duration).',
    `modified_timestamp` TIMESTAMP COMMENT 'Date‑time of the most recent update to the constraint record.',
    `saa_constraint_name` STRING COMMENT 'Human‑readable name describing the constraint.',
    `notes` STRING COMMENT 'Free‑form field for any supplemental information or comments.',
    `regulatory_reference` STRING COMMENT 'Identifier of the regulatory rule or guideline that drives the constraint (e.g., REG-1234).',
    `review_status` STRING COMMENT 'Outcome of the latest review process for the constraint.. Valid values are `approved|rejected|under_review`',
    `risk_weight` DECIMAL(10,4) COMMENT 'Weighting factor used in risk‑adjusted allocation calculations.',
    `saa_constraint_status` STRING COMMENT 'Current lifecycle status of the constraint.. Valid values are `active|inactive|pending|retired`',
    `scenario_name` STRING COMMENT 'Name of the economic or market scenario under which the constraint is evaluated.. Valid values are `base|stress|optimistic`',
    `threshold_max` DECIMAL(20,6) COMMENT 'Upper bound value for the constraint when a range is defined.',
    `threshold_min` DECIMAL(20,6) COMMENT 'Lower bound value for the constraint when a range is defined.',
    `version_number` BIGINT COMMENT 'Incremental version of the constraint record for change tracking.',
    `created_by` STRING COMMENT 'User identifier of the person who initially created the constraint.',
    CONSTRAINT pk_saa_constraint PRIMARY KEY(`saa_constraint_id`)
) COMMENT 'Master record defining actuarially-derived constraints on the Strategic Asset Allocation (SAA) imposed by liability characteristics. Captures constraint name, constraint type (minimum duration, maximum equity allocation, minimum real asset allocation';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`experience_study` (
    `experience_study_id` BIGINT COMMENT 'System-generated unique identifier for the actuarial experience study.',
    `assumption_set_id` BIGINT COMMENT 'Foreign key linking to actuarial.assumption_set. Business justification: Experience study uses a specific assumption set; FK provides reference and removes duplicate assumption_set_version and mortality_table_used columns.',
    `mortality_table_id` BIGINT COMMENT 'Foreign key linking to actuarial.mortality_table. Business justification: Experience studies compare actual mortality experience against assumed mortality tables. This links the study to the specific mortality table being validated.',
    `actual_mortality_rate` DECIMAL(6,5) COMMENT 'Observed mortality rate derived from experience data.',
    `actual_retirement_rate` DECIMAL(6,5) COMMENT 'Observed retirement (exit) rate from experience data.',
    `actual_salary_increase` DECIMAL(5,4) COMMENT 'Observed average salary increase percentage from experience data.',
    `assumed_mortality_rate` DECIMAL(6,5) COMMENT 'Mortality rate assumed in the actuarial model for comparison.',
    `assumed_retirement_rate` DECIMAL(6,5) COMMENT 'Retirement rate assumed in the actuarial model for comparison.',
    `assumed_salary_increase` DECIMAL(5,4) COMMENT 'Salary increase percentage assumed in the actuarial model.',
    `assumptions_version` STRING COMMENT 'Version identifier for the set of actuarial assumptions applied in the study.',
    `creation_timestamp` TIMESTAMP COMMENT 'Timestamp when the study record was first created in the system.',
    `data_source` STRING COMMENT 'Origin of the raw data used in the experience study (e.g., payroll system, HRIS).',
    `experience_study_description` STRING COMMENT 'Free‑text description of the study purpose, scope, and methodology.',
    `deviation_metric` DECIMAL(8,4) COMMENT 'Numeric measure of deviation between actual and assumed experience (e.g., difference or ratio).',
    `discount_rate` DECIMAL(5,4) COMMENT 'Annual discount rate applied to cash‑flow projections in the study.',
    `end_date` DATE COMMENT 'Date when the experience study period ends.',
    `experience_period_years` BIGINT COMMENT 'Number of years covered by the experience study period.',
    `experience_study_status` STRING COMMENT 'Current lifecycle status of the study.. Valid values are `draft|active|completed|archived`',
    `inflation_rate` DECIMAL(5,4) COMMENT 'Assumed annual inflation rate applied to benefit cash flows.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the study record.',
    `notes` STRING COMMENT 'Additional free‑form comments or observations recorded by the actuary.',
    `regulatory_approval_date` DATE COMMENT 'Date when the regulatory authority approved the study.',
    `regulatory_approval_status` STRING COMMENT 'Status of regulatory review for the study results.. Valid values are `pending|approved|rejected`',
    `salary_growth_rate` DECIMAL(5,4) COMMENT 'Assumed annual growth rate of member salaries used in the study.',
    `start_date` DATE COMMENT 'Date when the experience study period begins.',
    `study_code` STRING COMMENT 'External or business code assigned to the study for reference in documentation.',
    `study_name` STRING COMMENT 'Descriptive name of the experience study used for reporting and analysis.',
    `study_type` STRING COMMENT 'Category of experience being analyzed, such as mortality, termination, retirement, disability, or salary.. Valid values are `mortality|termination|retirement|disability|salary`',
    CONSTRAINT pk_experience_study PRIMARY KEY(`experience_study_id`)
) COMMENT 'Master record for each actuarial experience study conducted to compare actual plan experience against assumed experience. Captures study name, study period (start/end date), experience type (mortality, termination, retirement, disability, salary)';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`gain_loss` (
    `gain_loss_id` BIGINT COMMENT 'Unique surrogate key for each actuarial gain or loss record.',
    `assumption_set_id` BIGINT COMMENT 'Identifier of the assumption set used for the valuation.',
    `liability_projection_id` BIGINT COMMENT 'Reference to the liability projection associated with this gain/loss.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Identifier of the actuarial valuation episode that produced this record.',
    `amount` DECIMAL(20,4) COMMENT 'Monetary value of the gain or loss expressed in the reporting currency.',
    `confidence_level` DECIMAL(5,2) COMMENT 'Statistical confidence (percentage) associated with the measurement.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was first created in the data lake.',
    `currency_code` STRING COMMENT 'Three‑letter ISO 4217 code of the currency in which the amount is expressed.',
    `gain_loss_status` STRING COMMENT 'Current processing status of the gain/loss record.. Valid values are `recorded|adjusted|reversed`',
    `gain_loss_type` STRING COMMENT 'Category of the gain or loss based on its origin.. Valid values are `demographic|economic|asset_return|assumption_change`',
    `is_estimated` BOOLEAN COMMENT 'Indicates whether the amount is an estimate (true) or based on actual experience (false).',
    `loss_description` STRING COMMENT 'Narrative description of the gain or loss event.',
    `measurement_timestamp` TIMESTAMP COMMENT 'Date and time when the gain or loss measurement was recorded.',
    `notes` STRING COMMENT 'Free‑form field for any supplemental information or comments.',
    `regulatory_filing_status` STRING COMMENT 'Status of any required regulatory filing for this gain/loss.. Valid values are `filed|pending|rejected`',
    `scenario` STRING COMMENT 'Economic or demographic scenario applied to the measurement.. Valid values are `base|adverse|severe`',
    `source_document_reference` STRING COMMENT 'External document or file reference (e.g., PDF, spreadsheet) that supports the measurement.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the record.',
    `valuation_period` STRING COMMENT 'Identifier for the valuation period (e.g., FY2024, Q1‑2025).',
    CONSTRAINT pk_gain_loss PRIMARY KEY(`gain_loss_id`)
) COMMENT 'Transactional record capturing actuarial gains and losses arising from differences between actual and assumed experience in each valuation period. Captures measurement date, gain/loss type (demographic, economic, asset return, assumption change)';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`de_risking_trigger` (
    `de_risking_trigger_id` BIGINT COMMENT 'System‑generated unique identifier for the de‑risking trigger record.',
    `applicable_liability_projection_id` BIGINT COMMENT 'Identifier of the liability projection scenario linked to the trigger.',
    `applicable_portfolio_id` BIGINT COMMENT 'Identifier of the investment portfolio to which the trigger applies.',
    `ldi_strategy_id` BIGINT COMMENT 'Foreign key linking to actuarial.ldi_strategy. Business justification: De-risking triggers define thresholds that adjust LDI hedge ratios. This links the trigger to the specific LDI strategy it governs, enabling strategy-specific trigger management.',
    `limit_id` BIGINT COMMENT 'Foreign key linking to risk.limit. Business justification: De-risking triggers (funded ratio thresholds for glide path execution) are specialized limits. Linking to risk.limit enables unified limit monitoring, breach escalation, and remediation tracking',
    `macro_indicator_id` BIGINT COMMENT 'Foreign key linking to research.macro_indicator. Business justification: De-risking triggers are often set based on macro indicators (interest rates, inflation).',
    `comparison_operator` STRING COMMENT 'Logical operator defining how the measured value is compared to the threshold.. Valid values are `greater_than|less_than|equal_to`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the trigger record was first created in the system.',
    `de_risking_trigger_status` STRING COMMENT 'Current operational status of the trigger.. Valid values are `active|inactive|retired|pending`',
    `de_risking_trigger_description` STRING COMMENT 'Free‑form description of the trigger logic and business rationale.',
    `effective_from` DATE COMMENT 'Date on which the trigger becomes effective.',
    `effective_until` DATE COMMENT 'Date on which the trigger expires or is superseded (null if open‑ended).',
    `is_automated` BOOLEAN COMMENT 'Indicates whether the trigger is applied automatically by the LDI engine.',
    `last_review_date` DATE COMMENT 'Date when the trigger was last reviewed for relevance and accuracy.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the trigger record.',
    `next_review_date` DATE COMMENT 'Planned future date for the next trigger review.',
    `notes` STRING COMMENT 'Additional free‑text comments or operational notes about the trigger.',
    `threshold_unit` STRING COMMENT 'Unit of measure for the threshold value.. Valid values are `percent|bps|rate|currency`',
    `threshold_value` DECIMAL(12,6) COMMENT 'Numeric threshold that activates the trigger (e.g., 80.0 for 80% funded ratio).',
    `trigger_code` STRING COMMENT 'Short alphanumeric code used to reference the trigger in external systems and reports.',
    `trigger_name` STRING COMMENT 'Human‑readable name describing the purpose of the trigger.',
    `trigger_priority` BIGINT COMMENT 'Numeric priority determining evaluation order when multiple triggers are active.',
    `trigger_type` STRING COMMENT 'Category of the trigger condition (e.g., funded‑ratio threshold, interest‑rate level, surplus amount, duration mismatch).. Valid values are `funded_ratio|interest_rate|surplus_amount|duration_mismatch`',
    `version_number` BIGINT COMMENT 'Incremental version of the trigger definition for change management.',
    CONSTRAINT pk_de_risking_trigger PRIMARY KEY(`de_risking_trigger_id`)
) COMMENT 'Master record defining funded-status-based de-risking triggers that automatically adjust the LDI hedge ratio or asset allocation glide path. Captures trigger name, trigger type (funded ratio threshold, interest rate level, surplus amount), trigger';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`de_risking_event` (
    `de_risking_event_id` BIGINT COMMENT 'Unique surrogate key for each de‑risking event record.',
    `assumption_set_id` BIGINT COMMENT 'Identifier of the actuarial assumption set applied in the analysis.',
    `created_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: De-risking events trigger significant portfolio changes; regulatory compliance requires documenting which employee recorded the breach event. created_by is text, need proper FK.',
    `de_risking_trigger_id` BIGINT COMMENT 'Foreign key linking to actuarial.de_risking_trigger. Business justification: De-risking events are triggered by specific de-risking triggers. This links the event to the trigger definition that was breached, enabling analysis of which triggers are most',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: De-risking events are triggered when economic conditions breach thresholds. Recording which economic scenario was active at breach time enables post-event analysis and strategy',
    `fund_id` BIGINT COMMENT 'Internal identifier of the fund whose liability profile triggered the event.',
    `liability_projection_id` BIGINT COMMENT 'Reference to the liability projection used for the breach analysis.',
    `action_mandated` STRING COMMENT 'Prescribed portfolio action required to address the breach.. Valid values are `hedge|sell|reallocate|cash|none`',
    `action_status` STRING COMMENT 'Current status of the mandated action.. Valid values are `pending|completed|failed|partial`',
    `action_taken_date` DATE COMMENT 'Date on which the mandated action was executed.',
    `breach_timestamp` TIMESTAMP COMMENT 'Date and time when the de‑risking trigger was breached.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the event record was first created in the system.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code for monetary values.. Valid values are `USD|CAD|EUR|GBP|CHF|JPY`',
    `de_risking_event_status` STRING COMMENT 'Current lifecycle status of the event.. Valid values are `pending|triggered|actioned|closed|cancelled`',
    `event_reference` STRING COMMENT 'Business identifier for the de‑risking event, often a human‑readable code.',
    `funded_ratio_at_breach` DECIMAL(5,4) COMMENT 'Funded ratio (as a decimal) measured at the moment of breach.',
    `hedge_ratio_after` DECIMAL(5,4) COMMENT 'Proportion of portfolio hedged after the de‑risking action.',
    `hedge_ratio_before` DECIMAL(5,4) COMMENT 'Proportion of portfolio hedged before the de‑risking action.',
    `notes` STRING COMMENT 'Free‑form comments or observations related to the event.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether the event must be reported to regulators.',
    `trigger_threshold` DECIMAL(5,4) COMMENT 'The threshold value for the trigger that was breached, expressed as a decimal.',
    `trigger_type` STRING COMMENT 'Classification of the de‑risking trigger that was breached.. Valid values are `funded_ratio|duration|duration_gap|asset_liability_mismatch`',
    `updated_by` STRING COMMENT 'User or process that performed the last update.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the event record.',
    `created_by` STRING COMMENT 'User or process that created the event record.',
    CONSTRAINT pk_de_risking_event PRIMARY KEY(`de_risking_event_id`)
) COMMENT 'Transactional record of each de-risking trigger breach event and the resulting portfolio action taken. Captures trigger reference, breach date, funded ratio at breach, trigger threshold breached, action mandated, action taken date, hedge ratio before';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`indexation_policy` (
    `indexation_policy_id` BIGINT COMMENT 'System-generated unique identifier for the indexation policy record.',
    `assumption_set_id` BIGINT COMMENT 'Foreign key linking to actuarial.assumption_set. Business justification: Indexation policies use actuarial assumptions, particularly inflation assumptions.',
    `contributor_pool_id` BIGINT COMMENT 'Identifier of the contributor pool to which the policy applies.',
    `created_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Indexation policies affect pension payments; governance requires tracking policy creator for accountability. created_by is text, need proper FK.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Indexation policies (COLA adjustments) are governed by jurisdiction-specific pension regulations.',
    `adjustment_type` STRING COMMENT 'Indicates whether the adjustment is a percentage of benefit or a fixed monetary amount.. Valid values are `percentage|fixed_amount`',
    `applicable_region` STRING COMMENT 'Geographic region(s) where the policy is enforced.. Valid values are `CAN|USA|EU|UK|AUS|NZ`',
    `approval_date` DATE COMMENT 'Date on which regulatory approval was granted.',
    `cap_rate` DECIMAL(5,4) COMMENT 'Maximum allowable indexation percentage; null if uncapped.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the policy record was first created in the system.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code for monetary amounts.. Valid values are `^[A-Z]{3}$`',
    `indexation_policy_description` STRING COMMENT 'Detailed narrative describing the purpose and mechanics of the policy.',
    `effective_from` DATE COMMENT 'Date on which the indexation policy becomes binding.',
    `effective_until` DATE COMMENT 'Date on which the policy ends; null for open‑ended policies.',
    `eligibility_criteria` STRING COMMENT 'Business rules defining which members qualify for the policy.',
    `floor_rate` DECIMAL(5,4) COMMENT 'Minimum allowable indexation percentage; null if no floor.',
    `indexation_frequency` STRING COMMENT 'How often the indexation adjustment is applied.. Valid values are `annual|semi_annual|quarterly|monthly`',
    `indexation_lag_months` BIGINT COMMENT 'Number of months between index publication and its application to benefits.',
    `indexation_method` STRING COMMENT 'Underlying index or methodology used for the adjustment.. Valid values are `CPI|RPI|custom`',
    `indexation_policy_status` STRING COMMENT 'Current lifecycle status of the policy.. Valid values are `active|inactive|pending|terminated`',
    `indexation_rate` DECIMAL(5,4) COMMENT 'Base percentage rate applied to benefits (e.g., 0.0250 for 2.5%).',
    `inflation_index_code` STRING COMMENT 'Standard code of the inflation index (e.g., CPI_CA).. Valid values are `^[A-Z]{3}$`',
    `is_default` BOOLEAN COMMENT 'True if this policy is the default for its contributor pool.',
    `last_review_date` DATE COMMENT 'Date when the policy was last reviewed for relevance.',
    `max_adjustment_amount` DECIMAL(18,2) COMMENT 'Absolute ceiling on the monetary adjustment per period; null if not applicable.',
    `min_adjustment_amount` DECIMAL(18,2) COMMENT 'Absolute floor on the monetary adjustment per period; null if not applicable.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the policy record.',
    `notes` STRING COMMENT 'Free‑form comments or operational notes about the policy.',
    `policy_code` STRING COMMENT 'Business code that uniquely identifies the policy across systems.',
    `policy_name` STRING COMMENT 'Human‑readable name of the indexation policy as used in reports and governance.',
    `policy_type` STRING COMMENT 'Classification of the policy (e.g., cost‑of‑living, wage‑growth, custom, fixed).. Valid values are `cost_of_living|wage_growth|custom|fixed`',
    `regulatory_approval_status` STRING COMMENT 'Status of regulatory sign‑off for the policy.. Valid values are `approved|pending|rejected`',
    `review_cycle_months` BIGINT COMMENT 'Planned interval in months between policy reviews.',
    `version_number` STRING COMMENT 'Version identifier for change management (e.g., v1.2).',
    `created_by` STRING COMMENT 'Name of the business user who created the policy record.',
    CONSTRAINT pk_indexation_policy PRIMARY KEY(`indexation_policy_id`)
) COMMENT 'Master record defining the benefit indexation policy for each contributor pool, governing how pension benefits are adjusted for inflation (cost-of-living adjustments).';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`plan_amendment` (
    `plan_amendment_id` BIGINT COMMENT 'Unique surrogate key for each plan amendment record.',
    `contributor_pool_id` BIGINT COMMENT 'Identifier of the contributor pool (e.g., one of the participating plans) affected by the amendment.',
    `created_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Plan amendments affect beneficiary entitlements; governance requires tracking which employee initiated the amendment. created_by is text, need proper FK.',
    `pension_plan_id` BIGINT COMMENT 'Identifier of the pension plan to which this amendment applies.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Plan amendments must be approved by the governing regulatory authority. For multi-employer pension funds, different amendments may fall under different jurisdictional',
    `regulatory_filing_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_filing. Business justification: Plan amendments require regulatory filings for approval before implementation.',
    `amendment_category` STRING COMMENT 'High‑level classification of the amendment purpose.. Valid values are `benefit|contribution|eligibility|indexation|other`',
    `amendment_code` STRING COMMENT 'External reference code assigned to the amendment for tracking and reporting.',
    `amendment_date` DATE COMMENT 'Date the amendment was formally recorded in the system.',
    `amendment_reason` STRING COMMENT 'Business justification or regulatory driver for the amendment.',
    `amendment_status` STRING COMMENT 'Current lifecycle state of the amendment.. Valid values are `draft|pending|approved|active|repealed|expired`',
    `amendment_type` STRING COMMENT 'Classifies the nature of the amendment to the pension plan.. Valid values are `benefit_improvement|benefit_reduction|contribution_change|eligibility_change|indexation_change`',
    `approval_timestamp` TIMESTAMP COMMENT 'Timestamp when the amendment received formal approval.',
    `approved_by` STRING COMMENT 'User identifier of the approver for the amendment.',
    `benefit_change_amount` DECIMAL(18,2) COMMENT 'Monetary value of any increase or decrease to benefit payouts.',
    `contribution_rate_change` DECIMAL(5,4) COMMENT 'Change in the contribution rate expressed in percentage points.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the amendment record was first created.',
    `plan_amendment_description` STRING COMMENT 'Narrative description of the amendment purpose and details.',
    `document_reference` STRING COMMENT 'Reference to the supporting document (e.g., amendment letter, legal filing).',
    `effective_date` DATE COMMENT 'Date on which the amendment becomes binding for plan participants.',
    `eligibility_criteria_change` STRING COMMENT 'Text describing any modifications to eligibility rules.',
    `expiration_date` DATE COMMENT 'Optional date when the amendment ceases to be in effect.',
    `funding_source` STRING COMMENT 'Source of funding for any additional contributions required by the amendment.. Valid values are `employer|employee|government|other`',
    `impact_assessment` STRING COMMENT 'Summary of the financial and actuarial impact of the amendment.',
    `indexation_rate` DECIMAL(5,4) COMMENT 'New indexation rate applied to benefits after the amendment.',
    `is_confidential` BOOLEAN COMMENT 'Indicates whether the amendment contains confidential information.',
    `ldi_impact_flag` BOOLEAN COMMENT 'True if the amendment materially changes LDI strategy assumptions.',
    `modified_by` STRING COMMENT 'User identifier of the person who last modified the amendment record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the amendment record.',
    `notes` STRING COMMENT 'Free‑form field for any supplemental information.',
    `regulatory_approval_date` DATE COMMENT 'Date when regulatory approval was granted.',
    `regulatory_approval_status` STRING COMMENT 'Status of regulatory review for the amendment.. Valid values are `pending|approved|rejected`',
    `stakeholder_impact` STRING COMMENT 'Description of how the amendment affects plan participants and sponsors.',
    `version_number` BIGINT COMMENT 'Sequential version number of the amendment record.',
    `vesting_schedule_change` STRING COMMENT 'Details of any changes to vesting schedules for accrued benefits.',
    `created_by` STRING COMMENT 'User identifier of the person who created the amendment record.',
    CONSTRAINT pk_plan_amendment PRIMARY KEY(`plan_amendment_id`)
) COMMENT 'Master record of each formal pension plan amendment that modifies benefit terms, contribution rates, eligibility criteria, or indexation provisions. Captures amendment date, amendment type (benefit improvement, benefit reduction, contribution change';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`actuarial_report` (
    `actuarial_report_id` BIGINT COMMENT 'Unique system-generated identifier for the actuarial report.',
    `actuarial_valuation_id` BIGINT COMMENT 'Foreign key linking to actuarial.actuarial_valuation. Business justification: Actuarial reports are often produced based on specific actuarial valuations. This links the report to its underlying valuation, enabling traceability from report to source',
    `assumption_set_id` BIGINT COMMENT 'Foreign key linking to actuarial.assumption_set. Business justification: Actuarial report is generated using a specific assumption set; FK provides reference and removes duplicate assumption_set_code.',
    `liability_projection_id` BIGINT COMMENT 'Foreign key linking to actuarial.liability_projection. Business justification: Actuarial reports reference specific liability projections. This links the report to the projection used, enabling verification of reported liability figures against source',
    `mortality_table_id` BIGINT COMMENT 'Foreign key linking to actuarial.mortality_table. Business justification: Actuarial report uses a specific mortality table; FK provides reference and removes duplicate mortality_table_code.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Actuarial reports are submitted to specific regulatory authorities. For pension funds serving several participating plans, tracking the governing authority per report',
    `active_member_count` BIGINT COMMENT 'Number of members actively accruing benefits at valuation date.',
    `actuary_designation` STRING COMMENT 'Professional designation or title of the lead actuary (e.g., ASA, FSA).',
    `actuary_firm_name` STRING COMMENT 'Name of the actuarial consulting firm that prepared the report.',
    `amortization_period_years` BIGINT COMMENT 'Number of years over which special payments are amortized.',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time when the report received final approval.',
    `average_active_member_age` DECIMAL(5,2) COMMENT 'Mean age of active members at valuation date.',
    `average_pensioner_age` DECIMAL(5,2) COMMENT 'Mean age of members already receiving pension benefits.',
    `certification_date` DATE COMMENT 'Date when the actuarys certification or qualification was confirmed.',
    `comments` STRING COMMENT 'Free‑text field for additional notes or commentary from the actuary.',
    `creation_timestamp` TIMESTAMP COMMENT 'Date and time when the report record was first created in the system.',
    `deferred_member_count` BIGINT COMMENT 'Number of members with deferred benefits (e.g., vested but not yet payable).',
    `discount_rate` DECIMAL(5,4) COMMENT 'Rate used to discount future cash flows to present value for liability calculations.',
    `employer_contribution_rate` DECIMAL(5,4) COMMENT 'Rate at which the employer contributes to the plan relative to payroll.',
    `funded_ratio` DECIMAL(5,2) COMMENT 'Ratio of plan assets to liabilities expressed as a percentage.',
    `going_concern_liability` DECIMAL(20,2) COMMENT 'Present value of projected benefit obligations assuming the plan continues operating.',
    `horizon_years` BIGINT COMMENT 'Number of years into the future the actuarial projection extends.',
    `inflation_assumption` DECIMAL(5,4) COMMENT 'Assumed annual inflation rate applied to future benefit cash flows.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Date and time of the most recent modification to the report record.',
    `lead_actuary_name` STRING COMMENT 'Full name of the lead actuary responsible for the report.',
    `liability_duration_years` DECIMAL(5,2) COMMENT 'Weighted average duration of projected liabilities.',
    `member_contribution_rate` DECIMAL(5,4) COMMENT 'Rate at which plan members contribute to the plan relative to salary.',
    `model_version` STRING COMMENT 'Version identifier of the actuarial model used for calculations.',
    `mortality_improvement_scale` STRING COMMENT 'Scale or factor applied to adjust mortality rates over time.',
    `normal_cost_rate` DECIMAL(5,4) COMMENT 'Annual cost of benefits accrued during the year expressed as a rate.',
    `regulatory_filing_date` DATE COMMENT 'Date on which the report was filed with the relevant regulator.',
    `regulatory_filing_status` STRING COMMENT 'Status of any required regulatory filing associated with the report.. Valid values are `not_required|required|filed|pending|rejected`',
    `report_name` STRING COMMENT 'Descriptive name of the actuarial report used for display and search.',
    `report_number` STRING COMMENT 'Business identifier or reference number assigned to the report.',
    `report_status` STRING COMMENT 'Current lifecycle state of the report within the actuarial workflow.. Valid values are `draft|submitted|approved|rejected|published|archived`',
    `report_type` STRING COMMENT 'Category of the report indicating its purpose and methodology.. Valid values are `valuation|experience_study|alm_study|contribution_rate_review|regulatory_filing|ad_hoc_analysis`',
    `reporting_period_end` DATE COMMENT 'End date of the fiscal period covered by the report.',
    `reporting_period_start` DATE COMMENT 'Start date of the fiscal period covered by the report.',
    `retired_member_count` BIGINT COMMENT 'Number of members already retired and receiving benefits.',
    `retirement_age_assumption` BIGINT COMMENT 'Assumed age at which members retire for projection purposes.',
    `salary_increase_assumption` DECIMAL(5,4) COMMENT 'Projected annual growth rate of member salaries used in earnings projections.',
    `scenario` STRING COMMENT 'Assumed economic or demographic scenario used for the projection.. Valid values are `base|stress_up|stress_down`',
    `solvency_liability` DECIMAL(20,2) COMMENT 'Liability amount calculated under solvency accounting standards.',
    `special_payment_amount` DECIMAL(20,2) COMMENT 'Amount of any special or supplemental payments included in the projection.',
    `total_member_count` BIGINT COMMENT 'Aggregate count of all members covered by the plan.',
    `total_plan_assets_market_value` DECIMAL(20,2) COMMENT 'Aggregate market value of all plan assets at valuation date.',
    `total_plan_assets_smoothed_value` DECIMAL(20,2) COMMENT 'Smoothed (e.g., moving average) value of plan assets used for liability calculations.',
    `valuation_date` DATE COMMENT 'Effective date of the valuation underlying the actuarial calculations.',
    `wind_up_liability` DECIMAL(20,2) COMMENT 'Liability amount assuming the plan is terminated and assets are liquidated.',
    CONSTRAINT pk_actuarial_report PRIMARY KEY(`actuarial_report_id`)
) COMMENT 'Master record for each formal actuarial report produced by the internal or external actuarial team. Captures report name, report type (valuation report, experience study, ALM study, contribution rate review, regulatory filing, ad hoc analysis), reporting';

CREATE OR REPLACE TABLE `asset_management`.`actuarial`.`liability_segment` (
    `liability_segment_id` BIGINT COMMENT 'Unique system-generated identifier for the liability segment record.',
    `contributor_pool_id` BIGINT COMMENT 'FK to beneficiary.contributor_pool',
    `liability_projection_id` BIGINT COMMENT 'Foreign key linking to actuarial.liability_projection. Business justification: Liability segments represent portions of total pension liabilities. This links segments to the liability projection they subdivide, enabling reconciliation of segment totals to',
    `contributor_pool` STRING COMMENT 'Identifier of the contributor pool (e.g., one of the participating plans) to which the segment belongs.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the liability segment record was first created in the system.',
    `discount_rate_used` DECIMAL(5,4) COMMENT 'Discount rate applied to project liability cash‑flows for the segment (e.g., 0.0450 = 4.50%).',
    `effective_date` DATE COMMENT 'Date the liability segment became effective for reporting and funding purposes.',
    `expiration_date` DATE COMMENT 'Date the liability segment ceases to be active, if applicable.',
    `funding_gap_amount` DECIMAL(20,2) COMMENT 'Monetary shortfall between assets and liabilities for the segment.',
    `funding_gap_percentage` DECIMAL(5,2) COMMENT 'Funding gap expressed as a percentage of total liability.',
    `funding_status` STRING COMMENT 'Indicates whether the segment is fully funded, under‑funded, or unfunded.. Valid values are `funded|underfunded|unfunded`',
    `is_default_segment` BOOLEAN COMMENT 'Indicates whether this segment is the default for its contributor pool.',
    `last_review_date` DATE COMMENT 'Date of the most recent formal review of the segment assumptions.',
    `liability_amount_gav` DECIMAL(20,2) COMMENT 'Gross asset value associated with the segment for asset‑liability matching.',
    `liability_amount_gav_currency` STRING COMMENT 'ISO currency code for the gross asset value amount.',
    `liability_amount_nav` DECIMAL(20,2) COMMENT 'Net asset value associated with the segment for asset‑liability matching.',
    `liability_amount_nav_currency` STRING COMMENT 'ISO currency code for the net asset value amount.',
    `liability_currency` STRING COMMENT 'Three‑letter ISO currency code of the liability amount (e.g., USD).',
    `liability_duration_years` DECIMAL(5,2) COMMENT 'Weighted average duration of cash‑flow obligations for the segment, expressed in years.',
    `liability_measurement_currency` STRING COMMENT 'Currency in which liability amounts are measured for this segment.',
    `liability_segment_status` STRING COMMENT 'Current lifecycle status of the liability segment.. Valid values are `active|inactive|archived`',
    `measurement_method` STRING COMMENT 'Methodology used to measure the liability (market, actuarial, or hybrid).. Valid values are `market|actuarial|hybrid`',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the liability segment record.',
    `next_review_date` DATE COMMENT 'Planned date for the next review of the segments assumptions.',
    `notes` STRING COMMENT 'Free‑form text for additional comments or explanations about the segment.',
    `regulatory_approval_date` DATE COMMENT 'Date when regulatory approval was granted or recorded.',
    `regulatory_approval_status` STRING COMMENT 'Status of regulatory approval for the segments liability methodology.. Valid values are `approved|pending|rejected`',
    `risk_category` STRING COMMENT 'Risk classification assigned to the segment based on volatility and duration.. Valid values are `low|medium|high`',
    `segment_classification` STRING COMMENT 'Higher‑level classification grouping (e.g., core, ancillary).',
    `segment_code` STRING COMMENT 'Business identifier code assigned to the liability segment for external reference.',
    `segment_country` STRING COMMENT 'Three‑letter ISO country code where the segments liabilities are primarily located.',
    `segment_creation_date` DATE COMMENT 'Date the segment record was initially created (duplicate of effective_date for audit purposes).',
    `segment_currency_exposure` STRING COMMENT 'Comma‑separated list of currencies in which the segment has exposure.',
    `segment_description` STRING COMMENT 'Detailed description of the segments purpose and composition.',
    `segment_last_updated_date` DATE COMMENT 'Date of the most recent update to the segment record (duplicate of modified_timestamp for audit purposes).',
    `segment_liability_subtype` STRING COMMENT 'Specific subtype of liability within the broader type.. Valid values are `pension|health|disability`',
    `segment_liability_type` STRING COMMENT 'Type of pension liability (defined benefit or defined contribution).. Valid values are `defined_benefit|defined_contribution`',
    `segment_name` STRING COMMENT 'Human‑readable name describing the liability segment.',
    `segment_owner` STRING COMMENT 'Internal team or business unit responsible for the segment.',
    `segment_region` STRING COMMENT 'Geographic region code (e.g., NA, EU, APAC) for the segment.',
    `segment_source_system` STRING COMMENT 'Originating system that supplied the segment data (e.g., SimCorp, Aladdin).',
    `segment_status_reason` STRING COMMENT 'Explanation for the current status of the segment (e.g., reason for archiving).',
    `segment_type` STRING COMMENT 'Classification of the segment by member status (e.g., active, deferred, retired, survivor).. Valid values are `active|deferred|retired|survivor`',
    `total_liability_amount` DECIMAL(20,2) COMMENT 'Aggregated liability amount for the segment expressed in the reporting currency.',
    `valuation_date` DATE COMMENT 'Date on which the liability amounts were valued.',
    `version_number` BIGINT COMMENT 'Incremental version identifier for changes to the segment record.',
    `weighted_average_duration_years` DECIMAL(5,2) COMMENT 'Average duration of the segment weighted by liability cash‑flows.',
    CONSTRAINT pk_liability_segment PRIMARY KEY(`liability_segment_id`)
) COMMENT 'Master record defining the segmentation of total pension liabilities for ALM and LDI purposes. Captures segment name, segment type (active members, deferred members, retirees, survivors), contributor pool, total liability amount, duration of segment';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ADD CONSTRAINT `fk_actuarial_liability_projection_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ADD CONSTRAINT `fk_actuarial_actuarial_valuation_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ADD CONSTRAINT `fk_actuarial_alm_model_discount_rate_curve_id` FOREIGN KEY (`discount_rate_curve_id`) REFERENCES `asset_management`.`actuarial`.`discount_rate_curve`(`discount_rate_curve_id`);
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ADD CONSTRAINT `fk_actuarial_alm_scenario_alm_model_id` FOREIGN KEY (`alm_model_id`) REFERENCES `asset_management`.`actuarial`.`alm_model`(`alm_model_id`);
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ADD CONSTRAINT `fk_actuarial_alm_scenario_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ADD CONSTRAINT `fk_actuarial_alm_scenario_discount_rate_curve_id` FOREIGN KEY (`discount_rate_curve_id`) REFERENCES `asset_management`.`actuarial`.`discount_rate_curve`(`discount_rate_curve_id`);
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ADD CONSTRAINT `fk_actuarial_mortality_table_primary_predecessor_table_mortality_table_id` FOREIGN KEY (`primary_predecessor_table_mortality_table_id`) REFERENCES `asset_management`.`actuarial`.`mortality_table`(`mortality_table_id`);
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ADD CONSTRAINT `fk_actuarial_assumption_set_discount_rate_curve_id` FOREIGN KEY (`discount_rate_curve_id`) REFERENCES `asset_management`.`actuarial`.`discount_rate_curve`(`discount_rate_curve_id`);
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ADD CONSTRAINT `fk_actuarial_assumption_set_mortality_table_id` FOREIGN KEY (`mortality_table_id`) REFERENCES `asset_management`.`actuarial`.`mortality_table`(`mortality_table_id`);
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ADD CONSTRAINT `fk_actuarial_funded_status_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ADD CONSTRAINT `fk_actuarial_funded_status_liability_projection_id` FOREIGN KEY (`liability_projection_id`) REFERENCES `asset_management`.`actuarial`.`liability_projection`(`liability_projection_id`);
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ADD CONSTRAINT `fk_actuarial_contribution_rate_model_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ADD CONSTRAINT `fk_actuarial_contribution_rate_model_liability_projection_id` FOREIGN KEY (`liability_projection_id`) REFERENCES `asset_management`.`actuarial`.`liability_projection`(`liability_projection_id`);
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ADD CONSTRAINT `fk_actuarial_special_payment_schedule_liability_projection_id` FOREIGN KEY (`liability_projection_id`) REFERENCES `asset_management`.`actuarial`.`liability_projection`(`liability_projection_id`);
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ADD CONSTRAINT `fk_actuarial_ldi_strategy_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ADD CONSTRAINT `fk_actuarial_ldi_strategy_discount_rate_curve_id` FOREIGN KEY (`discount_rate_curve_id`) REFERENCES `asset_management`.`actuarial`.`discount_rate_curve`(`discount_rate_curve_id`);
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ADD CONSTRAINT `fk_actuarial_ldi_strategy_inflation_assumption_assumption_set_id` FOREIGN KEY (`inflation_assumption_assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ADD CONSTRAINT `fk_actuarial_ldi_strategy_mortality_table_id` FOREIGN KEY (`mortality_table_id`) REFERENCES `asset_management`.`actuarial`.`mortality_table`(`mortality_table_id`);
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ADD CONSTRAINT `fk_actuarial_ldi_hedge_position_ldi_strategy_id` FOREIGN KEY (`ldi_strategy_id`) REFERENCES `asset_management`.`actuarial`.`ldi_strategy`(`ldi_strategy_id`);
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ADD CONSTRAINT `fk_actuarial_liability_cash_flow_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ADD CONSTRAINT `fk_actuarial_liability_cash_flow_liability_projection_id` FOREIGN KEY (`liability_projection_id`) REFERENCES `asset_management`.`actuarial`.`liability_projection`(`liability_projection_id`);
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ADD CONSTRAINT `fk_actuarial_saa_constraint_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ADD CONSTRAINT `fk_actuarial_saa_constraint_ldi_strategy_id` FOREIGN KEY (`ldi_strategy_id`) REFERENCES `asset_management`.`actuarial`.`ldi_strategy`(`ldi_strategy_id`);
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ADD CONSTRAINT `fk_actuarial_experience_study_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ADD CONSTRAINT `fk_actuarial_experience_study_mortality_table_id` FOREIGN KEY (`mortality_table_id`) REFERENCES `asset_management`.`actuarial`.`mortality_table`(`mortality_table_id`);
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ADD CONSTRAINT `fk_actuarial_gain_loss_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ADD CONSTRAINT `fk_actuarial_gain_loss_liability_projection_id` FOREIGN KEY (`liability_projection_id`) REFERENCES `asset_management`.`actuarial`.`liability_projection`(`liability_projection_id`);
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ADD CONSTRAINT `fk_actuarial_de_risking_trigger_applicable_liability_projection_id` FOREIGN KEY (`applicable_liability_projection_id`) REFERENCES `asset_management`.`actuarial`.`liability_projection`(`liability_projection_id`);
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ADD CONSTRAINT `fk_actuarial_de_risking_trigger_ldi_strategy_id` FOREIGN KEY (`ldi_strategy_id`) REFERENCES `asset_management`.`actuarial`.`ldi_strategy`(`ldi_strategy_id`);
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ADD CONSTRAINT `fk_actuarial_de_risking_event_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ADD CONSTRAINT `fk_actuarial_de_risking_event_de_risking_trigger_id` FOREIGN KEY (`de_risking_trigger_id`) REFERENCES `asset_management`.`actuarial`.`de_risking_trigger`(`de_risking_trigger_id`);
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ADD CONSTRAINT `fk_actuarial_de_risking_event_liability_projection_id` FOREIGN KEY (`liability_projection_id`) REFERENCES `asset_management`.`actuarial`.`liability_projection`(`liability_projection_id`);
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ADD CONSTRAINT `fk_actuarial_indexation_policy_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ADD CONSTRAINT `fk_actuarial_actuarial_report_actuarial_valuation_id` FOREIGN KEY (`actuarial_valuation_id`) REFERENCES `asset_management`.`actuarial`.`actuarial_valuation`(`actuarial_valuation_id`);
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ADD CONSTRAINT `fk_actuarial_actuarial_report_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ADD CONSTRAINT `fk_actuarial_actuarial_report_liability_projection_id` FOREIGN KEY (`liability_projection_id`) REFERENCES `asset_management`.`actuarial`.`liability_projection`(`liability_projection_id`);
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ADD CONSTRAINT `fk_actuarial_actuarial_report_mortality_table_id` FOREIGN KEY (`mortality_table_id`) REFERENCES `asset_management`.`actuarial`.`mortality_table`(`mortality_table_id`);
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ADD CONSTRAINT `fk_actuarial_liability_segment_liability_projection_id` FOREIGN KEY (`liability_projection_id`) REFERENCES `asset_management`.`actuarial`.`liability_projection`(`liability_projection_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` SET TAGS ('dbx_subdomain' = 'liability_valuation');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `liability_projection_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Projection Identifier (ID)');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Identifier (ID)');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Identifier (ID)');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `abo_amount` SET TAGS ('dbx_business_glossary_term' = 'Accumulated Benefit Obligation (ABO) Amount');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `actuarial_gain_loss` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Gain or Loss');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `actuary_firm` SET TAGS ('dbx_business_glossary_term' = 'Actuary Firm');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `actuary_name` SET TAGS ('dbx_business_glossary_term' = 'Actuary Name');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `amortization_period_years` SET TAGS ('dbx_business_glossary_term' = 'Amortization Period Years');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `benefits_paid` SET TAGS ('dbx_business_glossary_term' = 'Benefits Paid');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `cash_flow_year_1` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Year 1');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `cash_flow_year_10` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Year 10');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `cash_flow_year_20` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Year 20');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `cash_flow_year_30` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Year 30');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `cash_flow_year_5` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Year 5');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `certification_date` SET TAGS ('dbx_business_glossary_term' = 'Certification Date');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `contribution_rate_required` SET TAGS ('dbx_business_glossary_term' = 'Contribution Rate Required');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `convexity` SET TAGS ('dbx_business_glossary_term' = 'Convexity');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `disability_rate` SET TAGS ('dbx_business_glossary_term' = 'Disability Rate');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `disability_rate` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `disability_rate` SET TAGS ('dbx_pii_health' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `discount_rate` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `funded_ratio` SET TAGS ('dbx_business_glossary_term' = 'Funded Ratio');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `funded_status_amount` SET TAGS ('dbx_business_glossary_term' = 'Funded Status Amount');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `inflation_rate` SET TAGS ('dbx_business_glossary_term' = 'Inflation Rate');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `interest_cost` SET TAGS ('dbx_business_glossary_term' = 'Interest Cost');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `liability_duration_years` SET TAGS ('dbx_business_glossary_term' = 'Liability Duration Years');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `mortality_improvement_scale` SET TAGS ('dbx_business_glossary_term' = 'Mortality Improvement Scale');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `mortality_table` SET TAGS ('dbx_business_glossary_term' = 'Mortality Table');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `normal_cost_rate` SET TAGS ('dbx_business_glossary_term' = 'Normal Cost Rate');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `pbo_amount` SET TAGS ('dbx_business_glossary_term' = 'Projected Benefit Obligation (PBO) Amount');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `projection_horizon_years` SET TAGS ('dbx_business_glossary_term' = 'Projection Horizon Years');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `projection_scenario` SET TAGS ('dbx_business_glossary_term' = 'Projection Scenario');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `projection_scenario` SET TAGS ('dbx_value_regex' = 'base|optimistic|pessimistic|stress|regulatory');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `regulatory_filing_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Date');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `regulatory_filing_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Status');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `regulatory_filing_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|approved|rejected');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `retirement_age_assumption` SET TAGS ('dbx_business_glossary_term' = 'Retirement Age Assumption');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `salary_growth_rate` SET TAGS ('dbx_business_glossary_term' = 'Salary Growth Rate');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `salary_growth_rate` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `salary_growth_rate` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `service_cost` SET TAGS ('dbx_business_glossary_term' = 'Service Cost');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `turnover_rate` SET TAGS ('dbx_business_glossary_term' = 'Turnover Rate');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` SET TAGS ('dbx_subdomain' = 'liability_valuation');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `actuarial_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Valuation Identifier (ID)');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `active_member_count` SET TAGS ('dbx_business_glossary_term' = 'Active Member Count');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `actuary_designation` SET TAGS ('dbx_business_glossary_term' = 'Actuary Professional Designation');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `actuary_firm_name` SET TAGS ('dbx_business_glossary_term' = 'Actuary Firm Name');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `amortization_period_years` SET TAGS ('dbx_business_glossary_term' = 'Amortization Period in Years');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `asset_valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Asset Valuation Method');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `asset_valuation_method` SET TAGS ('dbx_value_regex' = 'market_value|smoothed_value|fair_value');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `average_active_member_age` SET TAGS ('dbx_business_glossary_term' = 'Average Active Member Age');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `average_pensioner_age` SET TAGS ('dbx_business_glossary_term' = 'Average Pensioner Age');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Completion Date');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `deferred_member_count` SET TAGS ('dbx_business_glossary_term' = 'Deferred Member Count');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `employer_contribution_rate` SET TAGS ('dbx_business_glossary_term' = 'Employer Contribution Rate');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `filing_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Date');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `going_concern_discount_rate` SET TAGS ('dbx_business_glossary_term' = 'Going Concern Discount Rate');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `going_concern_funded_ratio` SET TAGS ('dbx_business_glossary_term' = 'Going Concern Funded Ratio');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `going_concern_liability` SET TAGS ('dbx_business_glossary_term' = 'Going Concern Liability');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `going_concern_surplus_deficit` SET TAGS ('dbx_business_glossary_term' = 'Going Concern Surplus or Deficit');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `inflation_assumption` SET TAGS ('dbx_business_glossary_term' = 'Inflation Assumption');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `lead_actuary_name` SET TAGS ('dbx_business_glossary_term' = 'Lead Actuary Name');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `liability_duration_years` SET TAGS ('dbx_business_glossary_term' = 'Liability Duration in Years');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `member_contribution_rate` SET TAGS ('dbx_business_glossary_term' = 'Member Contribution Rate');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `mortality_improvement_scale` SET TAGS ('dbx_business_glossary_term' = 'Mortality Improvement Scale');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `mortality_table` SET TAGS ('dbx_business_glossary_term' = 'Mortality Table');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `next_required_valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Next Required Valuation Date');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `normal_cost_rate` SET TAGS ('dbx_business_glossary_term' = 'Normal Cost Rate');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Valuation Reference Number');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `report_document_path` SET TAGS ('dbx_business_glossary_term' = 'Valuation Report Document Path');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `retired_member_count` SET TAGS ('dbx_business_glossary_term' = 'Retired Member Count');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `retirement_age_assumption` SET TAGS ('dbx_business_glossary_term' = 'Retirement Age Assumption');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `salary_increase_assumption` SET TAGS ('dbx_business_glossary_term' = 'Salary Increase Assumption');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `salary_increase_assumption` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `salary_increase_assumption` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `solvency_discount_rate` SET TAGS ('dbx_business_glossary_term' = 'Solvency Discount Rate');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `solvency_funded_ratio` SET TAGS ('dbx_business_glossary_term' = 'Solvency Funded Ratio');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `solvency_liability` SET TAGS ('dbx_business_glossary_term' = 'Solvency Liability');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `solvency_surplus_deficit` SET TAGS ('dbx_business_glossary_term' = 'Solvency Surplus or Deficit');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `special_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Special Payment Amount');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `total_member_count` SET TAGS ('dbx_business_glossary_term' = 'Total Member Count');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `total_plan_assets_market_value` SET TAGS ('dbx_business_glossary_term' = 'Total Plan Assets Market Value');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `total_plan_assets_smoothed_value` SET TAGS ('dbx_business_glossary_term' = 'Total Plan Assets Smoothed Value');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Valuation Method');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `valuation_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Status');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `valuation_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|under_review|approved|filed|superseded');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `valuation_type` SET TAGS ('dbx_business_glossary_term' = 'Valuation Type');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `valuation_type` SET TAGS ('dbx_value_regex' = 'triennial|interim|special|wind-up|transfer');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ALTER COLUMN `wind_up_liability` SET TAGS ('dbx_business_glossary_term' = 'Wind-Up Liability');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` SET TAGS ('dbx_subdomain' = 'asset_hedging');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `alm_model_id` SET TAGS ('dbx_business_glossary_term' = 'Asset-Liability Management (ALM) Model Identifier');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `climate_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `created_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Created By User Identifier');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `created_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `created_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `discount_rate_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Discount Curve Identifier');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Model Owner Identifier');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `performance_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Benchmark Identifier');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `updated_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Updated By User Identifier');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `updated_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `updated_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `asset_universe_scope` SET TAGS ('dbx_business_glossary_term' = 'Asset Universe Scope');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `back_testing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Back Testing Frequency');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `back_testing_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|ad_hoc');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `benefit_payment_pattern` SET TAGS ('dbx_business_glossary_term' = 'Benefit Payment Pattern');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `benefit_payment_pattern` SET TAGS ('dbx_value_regex' = 'level|increasing|decreasing|custom');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `computational_runtime_minutes` SET TAGS ('dbx_business_glossary_term' = 'Computational Runtime Minutes');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `confidence_interval_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Interval Level');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `contribution_rate_assumption` SET TAGS ('dbx_business_glossary_term' = 'Contribution Rate Assumption');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `currency_hedging_policy` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Currency Hedging Policy');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `currency_hedging_policy` SET TAGS ('dbx_value_regex' = 'fully_hedged|partially_hedged|unhedged|dynamic|custom');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `duration_matching_strategy` SET TAGS ('dbx_business_glossary_term' = 'Duration Matching Strategy');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `duration_matching_strategy` SET TAGS ('dbx_value_regex' = 'full_match|partial_match|key_rate_duration|cash_flow_match|immunization|none');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `effective_to_date` SET TAGS ('dbx_business_glossary_term' = 'Effective To Date');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `esg_integration_approach` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Approach');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `inflation_assumption_rate` SET TAGS ('dbx_business_glossary_term' = 'Inflation Assumption Rate');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active Flag');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `last_calibration_date` SET TAGS ('dbx_business_glossary_term' = 'Last Calibration Date');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `liquidity_constraint_pct` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Constraint Percentage');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `model_code` SET TAGS ('dbx_business_glossary_term' = 'ALM Model Code');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `model_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,20}$');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `model_complexity_rating` SET TAGS ('dbx_business_glossary_term' = 'Model Complexity Rating');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `model_complexity_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|very_high');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `model_documentation_url` SET TAGS ('dbx_business_glossary_term' = 'Model Documentation Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `model_name` SET TAGS ('dbx_business_glossary_term' = 'ALM Model Name');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `model_notes` SET TAGS ('dbx_business_glossary_term' = 'Model Notes');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `model_status` SET TAGS ('dbx_business_glossary_term' = 'ALM Model Status');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `model_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|active|deprecated|archived');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `model_type` SET TAGS ('dbx_business_glossary_term' = 'ALM Model Type');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `model_type` SET TAGS ('dbx_value_regex' = 'deterministic|stochastic|scenario_based|hybrid|monte_carlo|stress_test');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'ALM Model Version');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `model_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+(.[0-9]+)?$');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `mortality_assumption_table` SET TAGS ('dbx_business_glossary_term' = 'Mortality Assumption Table');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `optimization_objective` SET TAGS ('dbx_business_glossary_term' = 'Optimization Objective');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `projection_horizon_years` SET TAGS ('dbx_business_glossary_term' = 'Projection Horizon Years');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Frequency');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|dynamic|none');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `regulatory_compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Flag');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `risk_tolerance_level` SET TAGS ('dbx_business_glossary_term' = 'Risk Tolerance Level');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `risk_tolerance_level` SET TAGS ('dbx_value_regex' = 'conservative|moderate|balanced|aggressive|custom');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `scenario_count` SET TAGS ('dbx_business_glossary_term' = 'Scenario Count');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `software_platform` SET TAGS ('dbx_business_glossary_term' = 'Software Platform');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `stress_test_scenarios` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Scenarios');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `target_funded_ratio` SET TAGS ('dbx_business_glossary_term' = 'Target Funded Ratio');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `var_calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Calculation Method');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `var_calculation_method` SET TAGS ('dbx_value_regex' = 'historical|parametric|monte_carlo|cornish_fisher|not_applicable');
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ALTER COLUMN `version_effective_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Version Effective Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` SET TAGS ('dbx_subdomain' = 'asset_hedging');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `alm_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Asset-Liability Management (ALM) Scenario ID');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `alm_model_id` SET TAGS ('dbx_business_glossary_term' = 'Asset-Liability Management (ALM) Model ID');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `created_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Created By User ID');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `created_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `created_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `discount_rate_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate Curve Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User ID');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `risk_stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Stress Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `asset_duration_years` SET TAGS ('dbx_business_glossary_term' = 'Asset Duration Years');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `benefit_indexation_percent` SET TAGS ('dbx_business_glossary_term' = 'Benefit Indexation Percent');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `completion_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Completion Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `contribution_rate_assumption_percent` SET TAGS ('dbx_business_glossary_term' = 'Contribution Rate Assumption Percent');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `convergence_tolerance` SET TAGS ('dbx_business_glossary_term' = 'Convergence Tolerance');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `credit_spread_shock_bps` SET TAGS ('dbx_business_glossary_term' = 'Credit Spread Shock Basis Points (bps)');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `cvar_95_amount` SET TAGS ('dbx_business_glossary_term' = 'Conditional Value at Risk (CVaR) 95% Amount');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `discount_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate Percent');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `duration_gap_years` SET TAGS ('dbx_business_glossary_term' = 'Duration Gap Years');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `equity_return_assumption_percent` SET TAGS ('dbx_business_glossary_term' = 'Equity Return Assumption Percent');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `execution_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Execution Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `funded_ratio_result_percent` SET TAGS ('dbx_business_glossary_term' = 'Funded Ratio Result Percent');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `fx_shock_percent` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Shock Percent');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `inflation_shock_percent` SET TAGS ('dbx_business_glossary_term' = 'Inflation Shock Percent');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `infrastructure_return_assumption_percent` SET TAGS ('dbx_business_glossary_term' = 'Infrastructure Return Assumption Percent');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `interest_rate_shock_bps` SET TAGS ('dbx_business_glossary_term' = 'Interest Rate Shock Basis Points (bps)');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `is_baseline` SET TAGS ('dbx_business_glossary_term' = 'Is Baseline Scenario');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `liability_duration_years` SET TAGS ('dbx_business_glossary_term' = 'Liability Duration Years');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `longevity_shock_years` SET TAGS ('dbx_business_glossary_term' = 'Longevity Shock Years');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `model_version_used` SET TAGS ('dbx_business_glossary_term' = 'Model Version Used');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `mortality_assumption_adjustment_percent` SET TAGS ('dbx_business_glossary_term' = 'Mortality Assumption Adjustment Percent');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `output_metrics` SET TAGS ('dbx_business_glossary_term' = 'Output Metrics');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `private_equity_return_assumption_percent` SET TAGS ('dbx_business_glossary_term' = 'Private Equity Return Assumption Percent');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `projection_horizon_years` SET TAGS ('dbx_business_glossary_term' = 'Projection Horizon Years');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `real_estate_return_assumption_percent` SET TAGS ('dbx_business_glossary_term' = 'Real Estate Return Assumption Percent');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `regulatory_framework` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Framework');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `regulatory_framework` SET TAGS ('dbx_value_regex' = 'IFRS|FASB|Solvency_II|Basel_III|Local_GAAP');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `run_date` SET TAGS ('dbx_business_glossary_term' = 'Run Date');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `salary_growth_assumption_percent` SET TAGS ('dbx_business_glossary_term' = 'Salary Growth Assumption Percent');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `salary_growth_assumption_percent` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `salary_growth_assumption_percent` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `scenario_description` SET TAGS ('dbx_business_glossary_term' = 'Scenario Description');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `scenario_name` SET TAGS ('dbx_business_glossary_term' = 'Scenario Name');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `scenario_run_reference` SET TAGS ('dbx_business_glossary_term' = 'Scenario Run Identifier');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `scenario_status` SET TAGS ('dbx_business_glossary_term' = 'Scenario Status');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `scenario_status` SET TAGS ('dbx_value_regex' = 'pending|running|completed|failed|cancelled|approved');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `scenario_type` SET TAGS ('dbx_business_glossary_term' = 'Scenario Type');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `scenario_type` SET TAGS ('dbx_value_regex' = 'base_case|stress|reverse_stress|stochastic|deterministic|regulatory');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `scenario_version` SET TAGS ('dbx_business_glossary_term' = 'Scenario Version');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `stochastic_path_count` SET TAGS ('dbx_business_glossary_term' = 'Stochastic Path Count');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `surplus_deficit_amount` SET TAGS ('dbx_business_glossary_term' = 'Surplus Deficit Amount');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `var_95_amount` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) 95% Amount');
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ALTER COLUMN `weight` SET TAGS ('dbx_business_glossary_term' = 'Scenario Weight');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` SET TAGS ('dbx_subdomain' = 'liability_valuation');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `discount_rate_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate Curve Identifier (ID)');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `benchmark_index` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `calculation_methodology_document` SET TAGS ('dbx_business_glossary_term' = 'Calculation Methodology Document');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `convergence_tenor_years` SET TAGS ('dbx_business_glossary_term' = 'Convergence Tenor (Years)');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `credit_quality_rating` SET TAGS ('dbx_business_glossary_term' = 'Credit Quality Rating');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `credit_quality_rating` SET TAGS ('dbx_value_regex' = 'aaa|aa|a|bbb|high_quality|investment_grade');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `credit_spread_adjustment_bps` SET TAGS ('dbx_business_glossary_term' = 'Credit Spread Adjustment (Basis Points)');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `curve_construction_date` SET TAGS ('dbx_business_glossary_term' = 'Curve Construction Date');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `curve_name` SET TAGS ('dbx_business_glossary_term' = 'Curve Name');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `curve_status` SET TAGS ('dbx_business_glossary_term' = 'Curve Status');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `curve_status` SET TAGS ('dbx_value_regex' = 'active|superseded|draft|archived|under_review|approved');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `curve_type` SET TAGS ('dbx_business_glossary_term' = 'Curve Type');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `curve_version` SET TAGS ('dbx_business_glossary_term' = 'Curve Version');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `data_source_reference` SET TAGS ('dbx_business_glossary_term' = 'Data Source Reference');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `extrapolation_method` SET TAGS ('dbx_business_glossary_term' = 'Extrapolation Method');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `extrapolation_method` SET TAGS ('dbx_value_regex' = 'flat|linear|smith_wilson|ultimate_forward_rate');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `interpolation_method` SET TAGS ('dbx_business_glossary_term' = 'Interpolation Method');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `interpolation_method` SET TAGS ('dbx_value_regex' = 'linear|cubic_spline|nelson_siegel|log_linear|flat_forward');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `liquid_point_tenor_years` SET TAGS ('dbx_business_glossary_term' = 'Liquid Point Tenor (Years)');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `liquidity_premium_bps` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Premium (Basis Points)');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `matching_adjustment_bps` SET TAGS ('dbx_business_glossary_term' = 'Matching Adjustment (Basis Points)');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `maximum_tenor_years` SET TAGS ('dbx_business_glossary_term' = 'Maximum Tenor (Years)');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `minimum_tenor_years` SET TAGS ('dbx_business_glossary_term' = 'Minimum Tenor (Years)');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Modified By');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `regulatory_framework` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Framework');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `source_data_provider` SET TAGS ('dbx_business_glossary_term' = 'Source Data Provider');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `tenor_increment_years` SET TAGS ('dbx_business_glossary_term' = 'Tenor Increment (Years)');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `term_structure_type` SET TAGS ('dbx_business_glossary_term' = 'Term Structure Type');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `term_structure_type` SET TAGS ('dbx_value_regex' = 'spot_rate|forward_rate|par_yield|zero_coupon');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `ultimate_forward_rate` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Forward Rate (UFR)');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `usage_scope` SET TAGS ('dbx_business_glossary_term' = 'Usage Scope');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`actuarial`.`discount_rate_curve` ALTER COLUMN `volatility_adjustment_bps` SET TAGS ('dbx_business_glossary_term' = 'Volatility Adjustment (Basis Points)');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` SET TAGS ('dbx_subdomain' = 'liability_valuation');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `mortality_table_id` SET TAGS ('dbx_business_glossary_term' = 'Mortality Table ID');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `primary_predecessor_table_mortality_table_id` SET TAGS ('dbx_business_glossary_term' = 'Predecessor Mortality Table ID');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `accounting_standard_alignment` SET TAGS ('dbx_business_glossary_term' = 'Accounting Standard Alignment');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `adjustment_factor` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Factor');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `age_range_maximum` SET TAGS ('dbx_business_glossary_term' = 'Age Range Maximum');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `age_range_minimum` SET TAGS ('dbx_business_glossary_term' = 'Age Range Minimum');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `base_year` SET TAGS ('dbx_business_glossary_term' = 'Base Year');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `blend_percentage` SET TAGS ('dbx_business_glossary_term' = 'Blend Percentage');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `collar_adjustment_type` SET TAGS ('dbx_business_glossary_term' = 'Collar Adjustment Type');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `collar_adjustment_type` SET TAGS ('dbx_value_regex' = 'white_collar|blue_collar|mixed|none');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `credibility_weighting` SET TAGS ('dbx_business_glossary_term' = 'Credibility Weighting');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `data_source_description` SET TAGS ('dbx_business_glossary_term' = 'Data Source Description');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `disabled_mortality_flag` SET TAGS ('dbx_business_glossary_term' = 'Disabled Mortality Flag');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `documentation_reference` SET TAGS ('dbx_business_glossary_term' = 'Documentation Reference');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `gender_applicability` SET TAGS ('dbx_business_glossary_term' = 'Gender Applicability');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `gender_applicability` SET TAGS ('dbx_value_regex' = 'male|female|unisex|combined');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `gender_applicability` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `gender_applicability` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `generational_projection_flag` SET TAGS ('dbx_business_glossary_term' = 'Generational Projection Flag');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `healthy_annuitant_flag` SET TAGS ('dbx_business_glossary_term' = 'Healthy Annuitant Flag');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `improvement_scale_flag` SET TAGS ('dbx_business_glossary_term' = 'Improvement Scale Flag');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `internal_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Internal Approval Date');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `longevity_risk_adjustment` SET TAGS ('dbx_business_glossary_term' = 'Longevity Risk Adjustment');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `methodology_notes` SET TAGS ('dbx_business_glossary_term' = 'Methodology Notes');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `mortality_basis` SET TAGS ('dbx_business_glossary_term' = 'Mortality Basis');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `population_segment` SET TAGS ('dbx_business_glossary_term' = 'Population Segment');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `publication_year` SET TAGS ('dbx_business_glossary_term' = 'Publication Year');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `regulatory_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Status');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_value_regex' = 'approved|pending|not_required|withdrawn');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `source_organization` SET TAGS ('dbx_business_glossary_term' = 'Source Organization');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `table_code` SET TAGS ('dbx_business_glossary_term' = 'Mortality Table Code');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `table_name` SET TAGS ('dbx_business_glossary_term' = 'Mortality Table Name');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `table_type` SET TAGS ('dbx_business_glossary_term' = 'Mortality Table Type');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `table_type` SET TAGS ('dbx_value_regex' = 'base_mortality|improvement_scale|generational_projection|static_projection|custom_blend');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `usage_status` SET TAGS ('dbx_business_glossary_term' = 'Usage Status');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `usage_status` SET TAGS ('dbx_value_regex' = 'active|superseded|archived|under_review');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `valuation_purpose` SET TAGS ('dbx_business_glossary_term' = 'Valuation Purpose');
ALTER TABLE `asset_management`.`actuarial`.`mortality_table` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` SET TAGS ('dbx_subdomain' = 'liability_valuation');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Identifier');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `capital_market_assumption_id` SET TAGS ('dbx_business_glossary_term' = 'Capital Market Assumption Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `credit_yield_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Risk‑Free Rate Curve Identifier');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `discount_rate_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate Curve Identifier');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `mortality_table_id` SET TAGS ('dbx_business_glossary_term' = 'Mortality Table Identifier');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `asset_liability_duration` SET TAGS ('dbx_business_glossary_term' = 'Asset‑Liability Duration (Years)');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `assumption_set_status` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Status');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `assumption_set_status` SET TAGS ('dbx_value_regex' = 'active|inactive|archived|draft');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `assumption_set_code` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Code');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `contribution_rate` SET TAGS ('dbx_business_glossary_term' = 'Contribution Rate');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `created_by_role` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Created By Role');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `created_by_role` SET TAGS ('dbx_value_regex' = 'actuary|admin|system');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Creation Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Currency');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|JPY|CHF');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `assumption_set_description` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Description');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Effective Date');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Expiration Date');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `funded_status_percent` SET TAGS ('dbx_business_glossary_term' = 'Funded Status Percentage');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `inflation_rate` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Inflation Rate');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `is_default` SET TAGS ('dbx_business_glossary_term' = 'Default Assumption Set Flag');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Last Review Date');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `ldi_strategy` SET TAGS ('dbx_business_glossary_term' = 'Liability‑Driven Investment Strategy');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `ldi_strategy` SET TAGS ('dbx_value_regex' = 'duration_matching|cash_flow_matching|risk_based|custom');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `liability_projection_years` SET TAGS ('dbx_business_glossary_term' = 'Liability Projection Horizon (Years)');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `assumption_set_name` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Name');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `review_cycle_months` SET TAGS ('dbx_business_glossary_term' = 'Assumption Review Cycle (Months)');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Updated By');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Last Update Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Version');
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Created By');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` SET TAGS ('dbx_subdomain' = 'liability_valuation');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `funded_status_id` SET TAGS ('dbx_business_glossary_term' = 'Funded Status ID');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `liability_projection_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Projection Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `asset_market_value` SET TAGS ('dbx_business_glossary_term' = 'Total Market Value of Assets');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `asset_to_liability_ratio` SET TAGS ('dbx_business_glossary_term' = 'Asset to Liability Ratio');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `discount_rate` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate Used for Liability Valuation');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `funded_ratio` SET TAGS ('dbx_business_glossary_term' = 'Funded Ratio (Assets to Liabilities Ratio)');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `liability_gross` SET TAGS ('dbx_business_glossary_term' = 'Total Actuarial Liability – Gross (Going-Concern Basis)');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `liability_solvent` SET TAGS ('dbx_business_glossary_term' = 'Total Actuarial Liability – Solvency (Solvency Basis)');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `measurement_status` SET TAGS ('dbx_business_glossary_term' = 'Measurement Status');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `measurement_status` SET TAGS ('dbx_value_regex' = 'preliminary|final|adjusted');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `measurement_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Measurement Timestamp (Date and Time of Funded Status Measurement)');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes or Comments');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `scenario` SET TAGS ('dbx_business_glossary_term' = 'Measurement Scenario (e.g., Base, Stress, Adverse)');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `scenario` SET TAGS ('dbx_value_regex' = 'base|stress|adverse');
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` SET TAGS ('dbx_subdomain' = 'benefit_funding');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `contribution_rate_model_id` SET TAGS ('dbx_business_glossary_term' = 'Contribution Rate Model ID');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool ID');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `liability_projection_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Projection Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `applicable_region` SET TAGS ('dbx_business_glossary_term' = 'Applicable Region Code');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Model Comments');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `contribution_rate_model_status` SET TAGS ('dbx_business_glossary_term' = 'Model Lifecycle Status');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `contribution_rate_model_status` SET TAGS ('dbx_value_regex' = 'active|inactive|retired|draft');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `employee_normal_cost_rate` SET TAGS ('dbx_business_glossary_term' = 'Employee Normal Cost Rate');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `employer_normal_cost_rate` SET TAGS ('dbx_business_glossary_term' = 'Employer Normal Cost Rate');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `frequency` SET TAGS ('dbx_business_glossary_term' = 'Contribution Frequency');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|annually');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `is_default` SET TAGS ('dbx_business_glossary_term' = 'Default Model Indicator');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `model_code` SET TAGS ('dbx_business_glossary_term' = 'Contribution Rate Model Code');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `model_name` SET TAGS ('dbx_business_glossary_term' = 'Contribution Rate Model Name');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `model_type` SET TAGS ('dbx_business_glossary_term' = 'Model Classification Type');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `model_type` SET TAGS ('dbx_value_regex' = 'statutory|voluntary|special');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `rate_basis` SET TAGS ('dbx_business_glossary_term' = 'Rate Basis');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `rate_basis` SET TAGS ('dbx_value_regex' = 'payroll|salary|benefit|total_compensation');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Status');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `special_contribution_rate` SET TAGS ('dbx_business_glossary_term' = 'Special Contribution Rate');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Model Version Number');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` SET TAGS ('dbx_subdomain' = 'benefit_funding');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `special_payment_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Special Payment Schedule ID');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `liability_projection_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Projection Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `amortization_period_years` SET TAGS ('dbx_business_glossary_term' = 'Amortization Period (Years)');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `deficiency_type` SET TAGS ('dbx_business_glossary_term' = 'Deficiency Type');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `deficiency_type` SET TAGS ('dbx_value_regex' = 'solvency|going_concern');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `special_payment_schedule_description` SET TAGS ('dbx_business_glossary_term' = 'Schedule Description');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `discount_rate` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `interest_rate` SET TAGS ('dbx_business_glossary_term' = 'Interest Rate');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `is_taxable` SET TAGS ('dbx_business_glossary_term' = 'Taxable Flag');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `net_present_value` SET TAGS ('dbx_business_glossary_term' = 'Net Present Value (NPV)');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Payment Amount');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'annual|semiannual|quarterly|monthly');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `regulatory_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Status');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_value_regex' = 'approved|pending|rejected');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `schedule_code` SET TAGS ('dbx_business_glossary_term' = 'Schedule Code');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `schedule_name` SET TAGS ('dbx_business_glossary_term' = 'Schedule Name');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `special_payment_schedule_status` SET TAGS ('dbx_business_glossary_term' = 'Schedule Status');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `special_payment_schedule_status` SET TAGS ('dbx_value_regex' = 'active|inactive|closed|pending');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Tax Rate');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `total_deficiency_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Deficiency Amount');
ALTER TABLE `asset_management`.`actuarial`.`special_payment_schedule` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` SET TAGS ('dbx_subdomain' = 'asset_hedging');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `ldi_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Liability-Driven Investment Strategy ID');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Inflation Assumption ID');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `discount_rate_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate Curve ID');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `inflation_assumption_assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Inflation Assumption ID');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `mortality_table_id` SET TAGS ('dbx_business_glossary_term' = 'Mortality Table ID');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `netting_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Netting Agreement Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Currency');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `ldi_strategy_description` SET TAGS ('dbx_business_glossary_term' = 'LDI Strategy Description');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `duration_target_years` SET TAGS ('dbx_business_glossary_term' = 'Target Duration (Years)');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `funded_ratio_target` SET TAGS ('dbx_business_glossary_term' = 'Target Funded Ratio');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `governance_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Governance Approval Status');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `governance_approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `hedge_ratio_target` SET TAGS ('dbx_business_glossary_term' = 'Target Hedge Ratio');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `interest_rate_hedge_type` SET TAGS ('dbx_business_glossary_term' = 'Interest Rate Hedge Type');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `interest_rate_hedge_type` SET TAGS ('dbx_value_regex' = 'duration|cash_flow|both');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `ldi_strategy_status` SET TAGS ('dbx_business_glossary_term' = 'LDI Strategy Status');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `ldi_strategy_status` SET TAGS ('dbx_value_regex' = 'active|inactive|draft|retired');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `liability_hedge_method` SET TAGS ('dbx_business_glossary_term' = 'Liability Hedge Method');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `liability_hedge_method` SET TAGS ('dbx_value_regex' = 'duration|cash_flow|both');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `risk_tolerance_level` SET TAGS ('dbx_business_glossary_term' = 'Risk Tolerance Level');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `risk_tolerance_level` SET TAGS ('dbx_value_regex' = 'low|medium|high');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `strategy_code` SET TAGS ('dbx_business_glossary_term' = 'LDI Strategy Code');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `strategy_name` SET TAGS ('dbx_business_glossary_term' = 'LDI Strategy Name');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `strategy_type` SET TAGS ('dbx_business_glossary_term' = 'LDI Strategy Type');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `strategy_type` SET TAGS ('dbx_value_regex' = 'full_hedge|partial_hedge|dynamic_derisking');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `stress_test_scenario` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Scenario');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `stress_test_scenario` SET TAGS ('dbx_value_regex' = 'base|adverse|severe|optimistic|inflation_shock|interest_rate_spike');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `target_allocation_alternative_pct` SET TAGS ('dbx_business_glossary_term' = 'Target Alternative Assets Allocation (%)');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `target_allocation_cash_pct` SET TAGS ('dbx_business_glossary_term' = 'Target Cash Allocation (%)');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `target_allocation_equity_pct` SET TAGS ('dbx_business_glossary_term' = 'Target Equity Allocation (%)');
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ALTER COLUMN `target_allocation_fixed_income_pct` SET TAGS ('dbx_business_glossary_term' = 'Target Fixed‑Income Allocation (%)');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` SET TAGS ('dbx_subdomain' = 'asset_hedging');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `ldi_hedge_position_id` SET TAGS ('dbx_business_glossary_term' = 'LDI Hedge Position ID');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `ldi_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Ldi Strategy Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Manager ID');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy ID');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `st_instrument_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Transaction Identifier (TXN_ID)');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `dv01_unit` SET TAGS ('dbx_business_glossary_term' = 'DV01 Unit of Measure');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `dv01_unit` SET TAGS ('dbx_value_regex' = 'bps|bp|basis_point');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `hedge_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Hedge Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `hedge_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `hedge_notional_amount` SET TAGS ('dbx_business_glossary_term' = 'Hedge Notional Amount');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `hedge_portfolio_dv01` SET TAGS ('dbx_business_glossary_term' = 'Hedge Portfolio DV01');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `is_hedge_active` SET TAGS ('dbx_business_glossary_term' = 'Is Hedge Active Flag');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `last_valuation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Valuation Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `ldi_hedge_position_status` SET TAGS ('dbx_business_glossary_term' = 'Hedge Position Status');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `ldi_hedge_position_status` SET TAGS ('dbx_value_regex' = 'active|inactive|closed|pending');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `liability_dv01` SET TAGS ('dbx_business_glossary_term' = 'Liability DV01');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `measurement_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Measurement Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `risk_factor` SET TAGS ('dbx_business_glossary_term' = 'Primary Risk Factor');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `risk_factor` SET TAGS ('dbx_value_regex' = 'interest_rate|inflation|credit_spread');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `scenario_code` SET TAGS ('dbx_business_glossary_term' = 'Projection Scenario Code');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'duration_matching|cash_flow_matching|duration_hedge|interest_rate_swap|futures|options');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` SET TAGS ('dbx_subdomain' = 'liability_valuation');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `liability_cash_flow_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Cash Flow ID');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool ID');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `liability_projection_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Projection Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `actuary_firm` SET TAGS ('dbx_business_glossary_term' = 'Actuary Firm');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `actuary_name` SET TAGS ('dbx_business_glossary_term' = 'Actuary Name');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `audit_trail_reference` SET TAGS ('dbx_business_glossary_term' = 'Audit Trail ID');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `cash_flow_amount` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Amount');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `cash_flow_year` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Year');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '[A-Z]{3}');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `disability_rate_used` SET TAGS ('dbx_business_glossary_term' = 'Disability Rate Used');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `disability_rate_used` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `disability_rate_used` SET TAGS ('dbx_pii_health' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `discount_rate_used` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate Used');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `funding_status` SET TAGS ('dbx_business_glossary_term' = 'Funding Status');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `funding_status` SET TAGS ('dbx_value_regex' = 'underfunded|fully_funded|overfunded');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `inflation_rate_used` SET TAGS ('dbx_business_glossary_term' = 'Inflation Rate Used');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `liability_cash_flow_status` SET TAGS ('dbx_business_glossary_term' = 'Projection Status');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `liability_cash_flow_status` SET TAGS ('dbx_value_regex' = 'projected|approved|revised|rejected');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `liability_type` SET TAGS ('dbx_business_glossary_term' = 'Liability Type');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `liability_type` SET TAGS ('dbx_value_regex' = 'pbo|abo|service_cost|interest_cost|actuarial_gain_loss');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `mortality_improvement_scale_used` SET TAGS ('dbx_business_glossary_term' = 'Mortality Improvement Scale Used');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `mortality_table_used` SET TAGS ('dbx_business_glossary_term' = 'Mortality Table Used');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Projection Notes');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `projection_date` SET TAGS ('dbx_business_glossary_term' = 'Projection Date');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `projection_horizon_years` SET TAGS ('dbx_business_glossary_term' = 'Projection Horizon (Years)');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `projection_scenario` SET TAGS ('dbx_business_glossary_term' = 'Projection Scenario');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `projection_scenario` SET TAGS ('dbx_value_regex' = 'base|stress_up|stress_down|adverse|optimistic');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `regulatory_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Status');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `retirement_age_assumption` SET TAGS ('dbx_business_glossary_term' = 'Retirement Age Assumption');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `salary_growth_rate_used` SET TAGS ('dbx_business_glossary_term' = 'Salary Growth Rate Used');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `salary_growth_rate_used` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `salary_growth_rate_used` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `segment_type` SET TAGS ('dbx_business_glossary_term' = 'Segment Type (Active, Deferred, Retiree, Survivor)');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `segment_type` SET TAGS ('dbx_value_regex' = 'active|deferred|retiree|survivor');
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ALTER COLUMN `turnover_rate_used` SET TAGS ('dbx_business_glossary_term' = 'Turnover Rate Used');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` SET TAGS ('dbx_subdomain' = 'asset_hedging');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `saa_constraint_id` SET TAGS ('dbx_business_glossary_term' = 'Strategic Asset Allocation Constraint ID');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `created_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Created By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `created_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `created_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `ldi_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Ldi Strategy Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `applies_to_asset_class` SET TAGS ('dbx_business_glossary_term' = 'Applicable Asset Class');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `applies_to_asset_class` SET TAGS ('dbx_value_regex' = 'equity|fixed_income|real_asset|private_equity|infrastructure|cash');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `applies_to_geography` SET TAGS ('dbx_business_glossary_term' = 'Applicable Geography');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `applies_to_geography` SET TAGS ('dbx_value_regex' = 'global|domestic|emerging|developed');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `saa_constraint_code` SET TAGS ('dbx_business_glossary_term' = 'Constraint Code');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Flag');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `constraint_category` SET TAGS ('dbx_business_glossary_term' = 'Constraint Category');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `constraint_category` SET TAGS ('dbx_value_regex' = 'duration|allocation|risk|liquidity');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `constraint_type` SET TAGS ('dbx_business_glossary_term' = 'Constraint Type');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `constraint_type` SET TAGS ('dbx_value_regex' = 'min_duration|max_equity|min_real_asset|max_credit|min_liquidity|max_volatility');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `saa_constraint_description` SET TAGS ('dbx_business_glossary_term' = 'Constraint Description');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Flag');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `last_updated_by` SET TAGS ('dbx_business_glossary_term' = 'Last Updated By User');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `measurement_unit` SET TAGS ('dbx_business_glossary_term' = 'Constraint Measurement Unit');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `measurement_unit` SET TAGS ('dbx_value_regex' = 'years|percent|bps|ratio');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `measurement_value` SET TAGS ('dbx_business_glossary_term' = 'Constraint Measurement Value');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modification Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `saa_constraint_name` SET TAGS ('dbx_business_glossary_term' = 'Constraint Name');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `review_status` SET TAGS ('dbx_business_glossary_term' = 'Review Status');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `review_status` SET TAGS ('dbx_value_regex' = 'approved|rejected|under_review');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `risk_weight` SET TAGS ('dbx_business_glossary_term' = 'Risk Weight');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `saa_constraint_status` SET TAGS ('dbx_business_glossary_term' = 'Constraint Status');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `saa_constraint_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|retired');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `scenario_name` SET TAGS ('dbx_business_glossary_term' = 'Scenario Name');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `scenario_name` SET TAGS ('dbx_value_regex' = 'base|stress|optimistic');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `threshold_max` SET TAGS ('dbx_business_glossary_term' = 'Maximum Threshold');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `threshold_min` SET TAGS ('dbx_business_glossary_term' = 'Minimum Threshold');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` SET TAGS ('dbx_subdomain' = 'liability_valuation');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `experience_study_id` SET TAGS ('dbx_business_glossary_term' = 'Experience Study Identifier');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `mortality_table_id` SET TAGS ('dbx_business_glossary_term' = 'Mortality Table Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `actual_mortality_rate` SET TAGS ('dbx_business_glossary_term' = 'Actual Mortality Rate');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `actual_retirement_rate` SET TAGS ('dbx_business_glossary_term' = 'Actual Retirement Rate');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `actual_salary_increase` SET TAGS ('dbx_business_glossary_term' = 'Actual Salary Increase');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `actual_salary_increase` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `actual_salary_increase` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `assumed_mortality_rate` SET TAGS ('dbx_business_glossary_term' = 'Assumed Mortality Rate');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `assumed_retirement_rate` SET TAGS ('dbx_business_glossary_term' = 'Assumed Retirement Rate');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `assumed_salary_increase` SET TAGS ('dbx_business_glossary_term' = 'Assumed Salary Increase');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `assumed_salary_increase` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `assumed_salary_increase` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `assumptions_version` SET TAGS ('dbx_business_glossary_term' = 'Assumptions Version');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `creation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `experience_study_description` SET TAGS ('dbx_business_glossary_term' = 'Study Description');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `deviation_metric` SET TAGS ('dbx_business_glossary_term' = 'Deviation Metric');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `discount_rate` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Study End Date');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `experience_period_years` SET TAGS ('dbx_business_glossary_term' = 'Experience Period (Years)');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `experience_study_status` SET TAGS ('dbx_business_glossary_term' = 'Experience Study Status');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `experience_study_status` SET TAGS ('dbx_value_regex' = 'draft|active|completed|archived');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `inflation_rate` SET TAGS ('dbx_business_glossary_term' = 'Inflation Rate');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Study Notes');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `regulatory_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Status');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `salary_growth_rate` SET TAGS ('dbx_business_glossary_term' = 'Salary Growth Rate');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `salary_growth_rate` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `salary_growth_rate` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Study Start Date');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `study_code` SET TAGS ('dbx_business_glossary_term' = 'Experience Study Code');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `study_name` SET TAGS ('dbx_business_glossary_term' = 'Experience Study Name');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `study_type` SET TAGS ('dbx_business_glossary_term' = 'Experience Study Type');
ALTER TABLE `asset_management`.`actuarial`.`experience_study` ALTER COLUMN `study_type` SET TAGS ('dbx_value_regex' = 'mortality|termination|retirement|disability|salary');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` SET TAGS ('dbx_subdomain' = 'liability_valuation');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `gain_loss_id` SET TAGS ('dbx_business_glossary_term' = 'Gain/Loss Record Identifier');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Identifier');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `liability_projection_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Projection Identifier');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Valuation Identifier');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Gain/Loss Amount');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `gain_loss_status` SET TAGS ('dbx_business_glossary_term' = 'Record Status');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `gain_loss_status` SET TAGS ('dbx_value_regex' = 'recorded|adjusted|reversed');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `gain_loss_type` SET TAGS ('dbx_business_glossary_term' = 'Gain/Loss Type');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `gain_loss_type` SET TAGS ('dbx_value_regex' = 'demographic|economic|asset_return|assumption_change');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `is_estimated` SET TAGS ('dbx_business_glossary_term' = 'Is Estimated Flag');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `loss_description` SET TAGS ('dbx_business_glossary_term' = 'Loss Description');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `measurement_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Measurement Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `regulatory_filing_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Status');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `regulatory_filing_status` SET TAGS ('dbx_value_regex' = 'filed|pending|rejected');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `scenario` SET TAGS ('dbx_business_glossary_term' = 'Scenario');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `scenario` SET TAGS ('dbx_value_regex' = 'base|adverse|severe');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `source_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Source Document Reference');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ALTER COLUMN `valuation_period` SET TAGS ('dbx_business_glossary_term' = 'Valuation Period');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` SET TAGS ('dbx_subdomain' = 'asset_hedging');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `de_risking_trigger_id` SET TAGS ('dbx_business_glossary_term' = 'De‑Risking Trigger ID');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `applicable_liability_projection_id` SET TAGS ('dbx_business_glossary_term' = 'Applicable Liability Projection ID');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `applicable_portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Applicable Portfolio ID');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `ldi_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Ldi Strategy Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `limit_id` SET TAGS ('dbx_business_glossary_term' = 'Limit Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `macro_indicator_id` SET TAGS ('dbx_business_glossary_term' = 'Macro Indicator Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `comparison_operator` SET TAGS ('dbx_business_glossary_term' = 'Trigger Comparison Operator');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `comparison_operator` SET TAGS ('dbx_value_regex' = 'greater_than|less_than|equal_to');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `de_risking_trigger_status` SET TAGS ('dbx_business_glossary_term' = 'De‑Risking Trigger Status');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `de_risking_trigger_status` SET TAGS ('dbx_value_regex' = 'active|inactive|retired|pending');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `de_risking_trigger_description` SET TAGS ('dbx_business_glossary_term' = 'Trigger Description');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Trigger Effective From Date');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Trigger Effective Until Date');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `is_automated` SET TAGS ('dbx_business_glossary_term' = 'Is Automated');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modification Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Trigger Notes');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `threshold_unit` SET TAGS ('dbx_business_glossary_term' = 'Trigger Threshold Unit');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `threshold_unit` SET TAGS ('dbx_value_regex' = 'percent|bps|rate|currency');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `threshold_value` SET TAGS ('dbx_business_glossary_term' = 'Trigger Threshold Value');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `trigger_code` SET TAGS ('dbx_business_glossary_term' = 'De‑Risking Trigger Code');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `trigger_name` SET TAGS ('dbx_business_glossary_term' = 'De‑Risking Trigger Name');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `trigger_priority` SET TAGS ('dbx_business_glossary_term' = 'Trigger Priority');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `trigger_type` SET TAGS ('dbx_business_glossary_term' = 'De‑Risking Trigger Type');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `trigger_type` SET TAGS ('dbx_value_regex' = 'funded_ratio|interest_rate|surplus_amount|duration_mismatch');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Trigger Version Number');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` SET TAGS ('dbx_subdomain' = 'asset_hedging');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `de_risking_event_id` SET TAGS ('dbx_business_glossary_term' = 'De‑Risking Event ID');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Identifier');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `created_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Created By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `created_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `created_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `de_risking_trigger_id` SET TAGS ('dbx_business_glossary_term' = 'De Risking Trigger Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `liability_projection_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Projection Identifier');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `action_mandated` SET TAGS ('dbx_business_glossary_term' = 'Mandated Action');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `action_mandated` SET TAGS ('dbx_value_regex' = 'hedge|sell|reallocate|cash|none');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `action_status` SET TAGS ('dbx_business_glossary_term' = 'Action Status');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `action_status` SET TAGS ('dbx_value_regex' = 'pending|completed|failed|partial');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `action_taken_date` SET TAGS ('dbx_business_glossary_term' = 'Action Taken Date');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `breach_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Breach Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|CHF|JPY');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `de_risking_event_status` SET TAGS ('dbx_business_glossary_term' = 'De‑Risking Event Status');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `de_risking_event_status` SET TAGS ('dbx_value_regex' = 'pending|triggered|actioned|closed|cancelled');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `event_reference` SET TAGS ('dbx_business_glossary_term' = 'De‑Risking Event Reference');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `funded_ratio_at_breach` SET TAGS ('dbx_business_glossary_term' = 'Funded Ratio at Breach');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `hedge_ratio_after` SET TAGS ('dbx_business_glossary_term' = 'Hedge Ratio After Action');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `hedge_ratio_before` SET TAGS ('dbx_business_glossary_term' = 'Hedge Ratio Before Action');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Event Notes');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `trigger_threshold` SET TAGS ('dbx_business_glossary_term' = 'Trigger Threshold');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `trigger_type` SET TAGS ('dbx_business_glossary_term' = 'Trigger Type');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `trigger_type` SET TAGS ('dbx_value_regex' = 'funded_ratio|duration|duration_gap|asset_liability_mismatch');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` SET TAGS ('dbx_subdomain' = 'benefit_funding');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `indexation_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Indexation Policy Identifier');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Identifier');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `created_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Created By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `created_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `created_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `adjustment_type` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Type');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `adjustment_type` SET TAGS ('dbx_value_regex' = 'percentage|fixed_amount');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `applicable_region` SET TAGS ('dbx_business_glossary_term' = 'Applicable Region');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `applicable_region` SET TAGS ('dbx_value_regex' = 'CAN|USA|EU|UK|AUS|NZ');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `cap_rate` SET TAGS ('dbx_business_glossary_term' = 'Indexation Cap Rate');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `indexation_policy_description` SET TAGS ('dbx_business_glossary_term' = 'Policy Description');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Policy Effective From Date');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Policy Effective Until Date');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `eligibility_criteria` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Criteria');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `floor_rate` SET TAGS ('dbx_business_glossary_term' = 'Indexation Floor Rate');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `indexation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Indexation Frequency');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `indexation_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `indexation_lag_months` SET TAGS ('dbx_business_glossary_term' = 'Indexation Lag (Months)');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `indexation_method` SET TAGS ('dbx_business_glossary_term' = 'Indexation Method');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `indexation_method` SET TAGS ('dbx_value_regex' = 'CPI|RPI|custom');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `indexation_policy_status` SET TAGS ('dbx_business_glossary_term' = 'Indexation Policy Status');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `indexation_policy_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|terminated');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `indexation_rate` SET TAGS ('dbx_business_glossary_term' = 'Indexation Rate');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `inflation_index_code` SET TAGS ('dbx_business_glossary_term' = 'Inflation Index Code');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `inflation_index_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `is_default` SET TAGS ('dbx_business_glossary_term' = 'Default Policy Indicator');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `max_adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Adjustment Amount');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `min_adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Adjustment Amount');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Policy Notes');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `policy_code` SET TAGS ('dbx_business_glossary_term' = 'Indexation Policy Code');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `policy_name` SET TAGS ('dbx_business_glossary_term' = 'Indexation Policy Name');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `policy_type` SET TAGS ('dbx_business_glossary_term' = 'Indexation Policy Type');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `policy_type` SET TAGS ('dbx_value_regex' = 'cost_of_living|wage_growth|custom|fixed');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Status');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_value_regex' = 'approved|pending|rejected');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `review_cycle_months` SET TAGS ('dbx_business_glossary_term' = 'Review Cycle (Months)');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Policy Version Number');
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By (User)');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` SET TAGS ('dbx_subdomain' = 'benefit_funding');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `plan_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Plan Amendment ID');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool ID');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `created_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Created By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `created_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `created_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Plan ID');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `regulatory_filing_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `amendment_category` SET TAGS ('dbx_business_glossary_term' = 'Amendment Category');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `amendment_category` SET TAGS ('dbx_value_regex' = 'benefit|contribution|eligibility|indexation|other');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `amendment_code` SET TAGS ('dbx_business_glossary_term' = 'Amendment Code');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `amendment_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Record Date');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `amendment_reason` SET TAGS ('dbx_business_glossary_term' = 'Amendment Reason');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_business_glossary_term' = 'Amendment Lifecycle Status');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_value_regex' = 'draft|pending|approved|active|repealed|expired');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_business_glossary_term' = 'Amendment Type (Benefit Improvement, Contribution Change, etc.)');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_value_regex' = 'benefit_improvement|benefit_reduction|contribution_change|eligibility_change|indexation_change');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Amendment Approval Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `benefit_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Benefit Change Amount (Monetary)');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `contribution_rate_change` SET TAGS ('dbx_business_glossary_term' = 'Contribution Rate Change (Percentage Points)');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `plan_amendment_description` SET TAGS ('dbx_business_glossary_term' = 'Amendment Description');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `document_reference` SET TAGS ('dbx_business_glossary_term' = 'Document Reference Identifier');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `eligibility_criteria_change` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Criteria Change Description');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `funding_source` SET TAGS ('dbx_business_glossary_term' = 'Funding Source');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `funding_source` SET TAGS ('dbx_value_regex' = 'employer|employee|government|other');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `impact_assessment` SET TAGS ('dbx_business_glossary_term' = 'Impact Assessment Summary');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `indexation_rate` SET TAGS ('dbx_business_glossary_term' = 'Indexation Rate (Percentage)');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `is_confidential` SET TAGS ('dbx_business_glossary_term' = 'Confidential Flag');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `ldi_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Liability‑Driven Investment Impact Flag');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Modified By User Identifier');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modification Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `regulatory_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Status');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `stakeholder_impact` SET TAGS ('dbx_business_glossary_term' = 'Stakeholder Impact Description');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `vesting_schedule_change` SET TAGS ('dbx_business_glossary_term' = 'Vesting Schedule Change Description');
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By User Identifier');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` SET TAGS ('dbx_subdomain' = 'liability_valuation');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `actuarial_report_id` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Report ID');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `actuarial_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `liability_projection_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Projection Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `mortality_table_id` SET TAGS ('dbx_business_glossary_term' = 'Mortality Table Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `active_member_count` SET TAGS ('dbx_business_glossary_term' = 'Active Member Count');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `actuary_designation` SET TAGS ('dbx_business_glossary_term' = 'Actuary Designation');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `actuary_firm_name` SET TAGS ('dbx_business_glossary_term' = 'Actuary Firm Name');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `amortization_period_years` SET TAGS ('dbx_business_glossary_term' = 'Amortization Period (Years)');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Report Approved Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `average_active_member_age` SET TAGS ('dbx_business_glossary_term' = 'Average Active Member Age');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `average_pensioner_age` SET TAGS ('dbx_business_glossary_term' = 'Average Pensioner Age');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `certification_date` SET TAGS ('dbx_business_glossary_term' = 'Actuary Certification Date');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Report Comments');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `creation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Report Creation Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `deferred_member_count` SET TAGS ('dbx_business_glossary_term' = 'Deferred Member Count');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `discount_rate` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `employer_contribution_rate` SET TAGS ('dbx_business_glossary_term' = 'Employer Contribution Rate');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `funded_ratio` SET TAGS ('dbx_business_glossary_term' = 'Funded Ratio');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `going_concern_liability` SET TAGS ('dbx_business_glossary_term' = 'Going Concern Liability');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `horizon_years` SET TAGS ('dbx_business_glossary_term' = 'Projection Horizon (Years)');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `inflation_assumption` SET TAGS ('dbx_business_glossary_term' = 'Inflation Assumption');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Report Last Updated Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `lead_actuary_name` SET TAGS ('dbx_business_glossary_term' = 'Lead Actuary Name');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `lead_actuary_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `lead_actuary_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `liability_duration_years` SET TAGS ('dbx_business_glossary_term' = 'Liability Duration (Years)');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `member_contribution_rate` SET TAGS ('dbx_business_glossary_term' = 'Member Contribution Rate');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Model Version');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `mortality_improvement_scale` SET TAGS ('dbx_business_glossary_term' = 'Mortality Improvement Scale');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `normal_cost_rate` SET TAGS ('dbx_business_glossary_term' = 'Normal Cost Rate');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `regulatory_filing_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Date');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `regulatory_filing_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Status');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `regulatory_filing_status` SET TAGS ('dbx_value_regex' = 'not_required|required|filed|pending|rejected');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `report_name` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Report Name');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `report_number` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Report Number');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `report_status` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Report Status');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `report_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|approved|rejected|published|archived');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `report_type` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Report Type');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `report_type` SET TAGS ('dbx_value_regex' = 'valuation|experience_study|alm_study|contribution_rate_review|regulatory_filing|ad_hoc_analysis');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `reporting_period_end` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `reporting_period_start` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `retired_member_count` SET TAGS ('dbx_business_glossary_term' = 'Retired Member Count');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `retirement_age_assumption` SET TAGS ('dbx_business_glossary_term' = 'Retirement Age Assumption');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `salary_increase_assumption` SET TAGS ('dbx_business_glossary_term' = 'Salary Increase Assumption');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `salary_increase_assumption` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `salary_increase_assumption` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `scenario` SET TAGS ('dbx_business_glossary_term' = 'Projection Scenario');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `scenario` SET TAGS ('dbx_value_regex' = 'base|stress_up|stress_down');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `solvency_liability` SET TAGS ('dbx_business_glossary_term' = 'Solvency Liability');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `special_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Special Payment Amount');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `total_member_count` SET TAGS ('dbx_business_glossary_term' = 'Total Member Count');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `total_plan_assets_market_value` SET TAGS ('dbx_business_glossary_term' = 'Total Plan Assets Market Value');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `total_plan_assets_smoothed_value` SET TAGS ('dbx_business_glossary_term' = 'Total Plan Assets Smoothed Value');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ALTER COLUMN `wind_up_liability` SET TAGS ('dbx_business_glossary_term' = 'Wind‑Up Liability');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` SET TAGS ('dbx_domain' = 'actuarial');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` SET TAGS ('dbx_subdomain' = 'liability_valuation');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `liability_segment_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Segment Identifier');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_internal' = 'true');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `liability_projection_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Projection Id (Foreign Key)');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `contributor_pool` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Identifier');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `discount_rate_used` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate Used');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `funding_gap_amount` SET TAGS ('dbx_business_glossary_term' = 'Funding Gap Amount');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `funding_gap_percentage` SET TAGS ('dbx_business_glossary_term' = 'Funding Gap Percentage');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `funding_status` SET TAGS ('dbx_business_glossary_term' = 'Funding Status');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `funding_status` SET TAGS ('dbx_value_regex' = 'funded|underfunded|unfunded');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `is_default_segment` SET TAGS ('dbx_business_glossary_term' = 'Default Segment Flag');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `liability_amount_gav` SET TAGS ('dbx_business_glossary_term' = 'Gross Asset Value (GAV)');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `liability_amount_gav_currency` SET TAGS ('dbx_business_glossary_term' = 'GAV Currency Code');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `liability_amount_nav` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `liability_amount_nav_currency` SET TAGS ('dbx_business_glossary_term' = 'NAV Currency Code');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `liability_currency` SET TAGS ('dbx_business_glossary_term' = 'Liability Currency Code');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `liability_duration_years` SET TAGS ('dbx_business_glossary_term' = 'Liability Duration (Years)');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `liability_measurement_currency` SET TAGS ('dbx_business_glossary_term' = 'Liability Measurement Currency');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `liability_segment_status` SET TAGS ('dbx_business_glossary_term' = 'Segment Status');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `liability_segment_status` SET TAGS ('dbx_value_regex' = 'active|inactive|archived');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `measurement_method` SET TAGS ('dbx_business_glossary_term' = 'Liability Measurement Method');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `measurement_method` SET TAGS ('dbx_value_regex' = 'market|actuarial|hybrid');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modification Timestamp');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Segment Notes');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `regulatory_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Status');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_value_regex' = 'approved|pending|rejected');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `risk_category` SET TAGS ('dbx_business_glossary_term' = 'Risk Category');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `risk_category` SET TAGS ('dbx_value_regex' = 'low|medium|high');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_classification` SET TAGS ('dbx_business_glossary_term' = 'Segment Classification');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_code` SET TAGS ('dbx_business_glossary_term' = 'Liability Segment Code (LSC)');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_country` SET TAGS ('dbx_business_glossary_term' = 'Segment Country Code');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_creation_date` SET TAGS ('dbx_business_glossary_term' = 'Segment Creation Date');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_currency_exposure` SET TAGS ('dbx_business_glossary_term' = 'Currency Exposure');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_description` SET TAGS ('dbx_business_glossary_term' = 'Segment Description');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_last_updated_date` SET TAGS ('dbx_business_glossary_term' = 'Segment Last Updated Date');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_liability_subtype` SET TAGS ('dbx_business_glossary_term' = 'Liability Subtype');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_liability_subtype` SET TAGS ('dbx_value_regex' = 'pension|health|disability');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_liability_type` SET TAGS ('dbx_business_glossary_term' = 'Liability Type');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_liability_type` SET TAGS ('dbx_value_regex' = 'defined_benefit|defined_contribution');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_name` SET TAGS ('dbx_business_glossary_term' = 'Liability Segment Name');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_owner` SET TAGS ('dbx_business_glossary_term' = 'Segment Owner');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_region` SET TAGS ('dbx_business_glossary_term' = 'Segment Region');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_source_system` SET TAGS ('dbx_business_glossary_term' = 'Source System');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_status_reason` SET TAGS ('dbx_business_glossary_term' = 'Segment Status Reason');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_type` SET TAGS ('dbx_business_glossary_term' = 'Liability Segment Type');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `segment_type` SET TAGS ('dbx_value_regex' = 'active|deferred|retired|survivor');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `total_liability_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Liability Amount');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ALTER COLUMN `weighted_average_duration_years` SET TAGS ('dbx_business_glossary_term' = 'Weighted Average Duration (Years)');
