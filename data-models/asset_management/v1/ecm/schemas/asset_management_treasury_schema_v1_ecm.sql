-- Schema for Domain: treasury | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:30

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`treasury` COMMENT 'Domain for treasury operations, liquidity management, cash management, and FX hedging. Owns cash position records, liquidity forecasts, net contribution inflows, capital call funding workflows, FX forward/swap positions and hedge ratios, currency exposure';
ALTER SCHEMA `asset_management`.`treasury` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `asset_management`.`treasury` SET TAGS ('dbx_domain' = 'treasury');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`treasury`.`cash_position` (
    `cash_position_id` BIGINT COMMENT 'Unique identifier for the cash position record. Primary key for the cash position entity.',
    `cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: Cash position records duplicate account details that are already stored in cash_account; linking to cash_account centralizes account data.',
    `custodian_id` BIGINT COMMENT 'Reference to the custodian bank holding the cash account (State Street or Northern Trust).',
    `fund_id` BIGINT COMMENT 'Reference to the fund entity (one per participating plan) that owns this cash position.',
    `infra_fund_commitment_id` BIGINT COMMENT 'Foreign key linking to infrastructure.infra_fund_commitment. Business justification: Cash position is associated with a fund commitment to monitor fund cash balances.',
    `liquidity_reserve_policy_id` BIGINT COMMENT 'Foreign key linking to treasury.liquidity_reserve_policy. Business justification: Cash positions are measured against liquidity reserve policy requirements. Links position to applicable policy.',
    `settlement_instruction_id` BIGINT COMMENT 'Reference to the standard settlement instructions template used for automated cash movements to and from this account.',
    `sofr_benchmark_id` BIGINT COMMENT 'Foreign key linking to treasury.sofr_benchmark. Business justification: Cash position interest rates are derived from SOFR; linking provides a direct reference to the benchmark.',
    `valuation_cycle_id` BIGINT COMMENT 'Foreign key linking to valuation.cycle. Business justification: Pension fund NAV calculation requires cash position reconciliation within valuation cycles.',
    `accrued_interest` DECIMAL(20,2) COMMENT 'The cumulative interest earned but not yet paid on the cash balance as of the position date.',
    `available_balance` DECIMAL(20,2) COMMENT 'The cash balance available for immediate use, net of pending settlements, holds, and reserved amounts.',
    `bank_identifier_code` STRING COMMENT 'The SWIFT BIC code of the custodian bank branch holding this cash account, used for international wire transfers and settlement instructions.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `capital_call_pending` DECIMAL(20,2) COMMENT 'Total value of capital calls issued by private equity, infrastructure, or real estate fund managers that are pending funding from this cash account.',
    `collateral_posted` DECIMAL(20,2) COMMENT 'Cash amount posted as collateral to counterparties for derivative positions, margin requirements, or securities lending, reducing available cash.',
    `collateral_received` DECIMAL(20,2) COMMENT 'Cash amount received as collateral from counterparties for derivative positions or securities lending, increasing available cash but with restrictions.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this cash position record was first created in the data warehouse.',
    `custody_balance` DECIMAL(20,2) COMMENT 'The cash balance reported by the custodian bank (State Street or Northern Trust), representing the external source of truth for reconciliation.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Automated data quality assessment score for this cash position record, ranging from 0.00 to 100.00, based on completeness, accuracy, and timeliness checks.',
    `distribution_pending` DECIMAL(20,2) COMMENT 'Total value of distributions from private market investments or fund managers that are expected to be received into this cash account.',
    `effective_date` DATE COMMENT 'The date from which this cash position record is effective, supporting historical point-in-time queries and slowly changing dimension tracking.',
    `expiry_date` DATE COMMENT 'The date when this cash position record is superseded by a newer version, supporting historical point-in-time queries and slowly changing dimension tracking. Null for current records.',
    `fx_hedge_ratio` DECIMAL(5,4) COMMENT 'The proportion of this currency exposure that is hedged through FX forwards or swaps, expressed as a decimal (e.g., 0.8500 for 85 percent hedged).',
    `interest_rate` DECIMAL(8,5) COMMENT 'The current interest rate applied to the cash balance, expressed as a decimal (e.g., 0.0525 for 5.25 percent), typically linked to SOFR (Secured Overnight Financing Rate) or equivalent benchmark.',
    `is_current` BOOLEAN COMMENT 'Indicates whether this is the current active version of the cash position record, supporting slowly changing dimension queries.',
    `last_reconciliation_date` DATE COMMENT 'The date when the most recent successful reconciliation between ledger and custody balances was completed.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this cash position record was last modified in the source system or data warehouse.',
    `ledger_balance` DECIMAL(20,2) COMMENT 'The accounting book balance as recorded in the internal general ledger, representing the official accounting position before reconciliation adjustments.',
    `legal_entity_identifier` STRING COMMENT 'The 20-character LEI code of the fund entity that legally owns this cash account, required for regulatory reporting.. Valid values are `^[A-Z0-9]{20}$`',
    `liquidity_tier` STRING COMMENT 'Classification of cash liquidity: tier_1 for immediately available cash, tier_2 for same-day available, tier_3 for next-day available, restricted for encumbered or limited-access cash.. Valid values are `tier_1|tier_2|tier_3|restricted`',
    `net_contribution_inflow` DECIMAL(20,2) COMMENT 'The net cash inflow from pension contributions (member and employer contributions minus benefit payments) received during the reporting period.',
    `notes` STRING COMMENT 'Free-text field for treasury operations team to record comments, explanations, or special circumstances related to this cash position.',
    `overdraft_limit` DECIMAL(20,2) COMMENT 'The maximum negative balance permitted by the custodian for this account, representing the intraday credit facility available.',
    `pending_settlements_inflow` DECIMAL(20,2) COMMENT 'Total value of incoming cash settlements not yet reflected in the custody balance, including trade settlements, dividend receipts, and capital distributions.',
    `pending_settlements_outflow` DECIMAL(20,2) COMMENT 'Total value of outgoing cash settlements not yet reflected in the custody balance, including trade purchases, capital calls, and fee payments.',
    `position_date` DATE COMMENT 'The business date for which this cash position is reported, representing the as-of date for all balance figures.',
    `position_status` STRING COMMENT 'Current operational status of the cash position: active for normal operations, inactive for dormant accounts, closed for terminated accounts, frozen for regulatory hold, restricted for limited access.. Valid values are `active|inactive|closed|frozen|restricted`',
    `position_timestamp` TIMESTAMP COMMENT 'The precise timestamp when this cash position snapshot was captured, supporting intraday position tracking.',
    `projected_balance` DECIMAL(20,2) COMMENT 'The forecasted end-of-day cash balance incorporating known future cash flows, capital calls, and scheduled settlements.',
    `reconciliation_difference` DECIMAL(20,2) COMMENT 'The variance between ledger balance and custody balance, representing unreconciled items requiring investigation.',
    `reconciliation_status` STRING COMMENT 'Status of the reconciliation between ledger balance and custody balance: reconciled for matched positions, pending for in-progress reconciliation, break for identified discrepancies, investigating for unresolved differences.. Valid values are `reconciled|pending|break|investigating`',
    `reporting_currency_flag` BOOLEAN COMMENT 'Indicates whether this cash position is denominated in the funds base reporting currency, used for performance and NAV (Net Asset Value) calculation.',
    `reserved_amount` DECIMAL(20,2) COMMENT 'Cash amount reserved or earmarked for specific purposes such as collateral requirements, margin calls, or committed capital calls, not available for general use.',
    `sweep_account_flag` BOOLEAN COMMENT 'Indicates whether this account participates in automated cash sweep programs to optimize interest income on idle cash balances.',
    `zero_balance_account_flag` BOOLEAN COMMENT 'Indicates whether this is a zero balance account that automatically transfers excess cash to or from a master concentration account.',
    CONSTRAINT pk_cash_position PRIMARY KEY(`cash_position_id`)
) COMMENT 'Authoritative IBOR/ABOR cash position record for each currency account held at custodians (State Street / Northern Trust). Captures intraday and end-of-day cash balances, projected cash, ledger cash, and custody cash across all fund entities and currency';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`cash_account` (
    `cash_account_id` BIGINT COMMENT 'Unique identifier for the cash account record. Primary key.',
    `bank_account_ssi_id` BIGINT COMMENT 'Reference to the standard settlement instructions template used for automated payment routing from this account.',
    `counterparty_id` BIGINT COMMENT 'Reference to the custodian bank holding this account (State Street, Northern Trust, etc.).',
    `csa_agreement_csa_id` BIGINT COMMENT 'Reference to the ISDA Credit Support Annex agreement governing collateral held in this account.',
    `csa_id` BIGINT COMMENT 'Reference to the ISDA Credit Support Annex agreement governing collateral held in this account.',
    `custodian_id` BIGINT COMMENT 'Reference to the custodian bank holding this account (State Street, Northern Trust, etc.).',
    `infra_fund_commitment_id` BIGINT COMMENT 'Foreign key linking to infrastructure.infra_fund_commitment. Business justification: Cash account belongs to a specific fund commitment; linking enables tracking of cash account usage per fund.',
    `legal_entity_id` BIGINT COMMENT 'Reference to the legal entity that owns or controls this cash account.',
    `manager_mandate_id` BIGINT COMMENT 'Foreign key linking to manager.manager_mandate. Business justification: Pension funds designate specific cash accounts for external manager mandates to segregate capital call funding, distribution receipts, and fee payments.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio or fund that this cash account supports.',
    `resource_asset_id` BIGINT COMMENT 'Foreign key linking to naturalresource.resource_asset. Business justification: Each resource asset has a dedicated cash account for settlement and reporting of production revenue and royalties.',
    `ssi_template_bank_account_ssi_id` BIGINT COMMENT 'Reference to the standard settlement instructions template used for automated payment routing from this account.',
    `sweep_target_account_id` BIGINT COMMENT 'Reference to the target cash account for automated sweep transactions.',
    `aba_routing_number` STRING COMMENT 'Nine-digit ABA routing transit number for domestic US wire transfers and ACH transactions.. Valid values are `^[0-9]{9}$`',
    `account_closed_date` DATE COMMENT 'Date when the cash account was closed or terminated, if applicable.',
    `account_manager_email` STRING COMMENT 'Email address of the custodian account manager for operational inquiries and support.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `account_manager_name` STRING COMMENT 'Name of the custodian relationship manager or account officer responsible for this account.',
    `account_manager_phone` STRING COMMENT 'Phone number of the custodian account manager for urgent operational matters.',
    `account_name` STRING COMMENT 'The descriptive name or title of the cash account as registered with the custodian.',
    `account_number` STRING COMMENT 'The unique account number assigned by the custodian bank for this cash or settlement account.',
    `account_opened_date` DATE COMMENT 'Date when the cash account was originally opened with the custodian.',
    `account_ownership` STRING COMMENT 'Ownership structure of the account: internal treasury, external custodian-held, pooled with other funds, or segregated for specific mandate.. Valid values are `internal|external|pooled|segregated`',
    `account_purpose` STRING COMMENT 'Detailed business purpose or use case for this cash account (e.g., trade settlement, capital call funding, dividend collection, FX hedging collateral).',
    `account_status` STRING COMMENT 'Current operational status of the cash account in its lifecycle.. Valid values are `active|inactive|suspended|closed|pending_activation|restricted`',
    `account_type` STRING COMMENT 'Classification of the cash account by its primary business purpose (settlement, operational liquidity, reserve, collateral, margin, sweep).. Valid values are `settlement|operational|reserve|collateral|margin|sweep`',
    `balance_reporting_frequency` STRING COMMENT 'Frequency at which the custodian provides balance updates for this account.. Valid values are `real_time|daily|weekly|monthly`',
    `benchmark_rate` DECIMAL(18,2) COMMENT 'Reference benchmark rate for floating interest calculation (SOFR, LIBOR, EURIBOR, SONIA, TONAR, ESTR, Fed Funds, or none for fixed/zero).',
    `bic_swift_code` STRING COMMENT 'BIC/SWIFT code identifying the custodian bank and branch for international wire transfers and settlement instructions.. Valid values are `^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `collateral_account_flag` BOOLEAN COMMENT 'Indicates whether this account is designated for holding collateral for derivatives, securities lending, or margin requirements.',
    `correspondent_bank_account_number` STRING COMMENT 'Account number held at the correspondent bank for settlement routing.',
    `correspondent_bank_bic` STRING COMMENT 'BIC/SWIFT code of the correspondent bank for routing international payments.. Valid values are `^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `correspondent_bank_name` STRING COMMENT 'Name of the correspondent or intermediary bank used for settlement routing, if applicable.',
    `cost_center_code` STRING COMMENT 'Internal cost center or business unit code responsible for this account in the corporate chart of accounts.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this cash account record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the account denomination (USD, EUR, GBP, JPY, etc.).. Valid values are `^[A-Z]{3}$`',
    `iban` STRING COMMENT 'International Bank Account Number for cross-border settlement and identification, primarily used in European and international transactions.',
    `interest_bearing_flag` BOOLEAN COMMENT 'Indicates whether this cash account earns interest on positive balances.',
    `interest_calculation_method` STRING COMMENT 'Day count convention used for interest accrual calculation (Actual/360, Actual/365, 30/360, Actual/Actual).. Valid values are `actual_360|actual_365|30_360|actual_actual`',
    `interest_rate_bps` DECIMAL(10,4) COMMENT 'Current interest rate applied to the account, expressed in basis points (1 bps = 0.01%).',
    `interest_rate_type` STRING COMMENT 'Type of interest rate applied to the account: fixed, floating (e.g., SOFR-linked), tiered based on balance, or zero.. Valid values are `fixed|floating|tiered|zero`',
    `internal_gl_account_code` STRING COMMENT 'Internal general ledger account code in Oracle Financials or corporate accounting system mapped to this cash account.',
    `last_activity_date` DATE COMMENT 'Date of the most recent transaction or balance change in this account.',
    `last_reconciliation_date` DATE COMMENT 'Date of the most recent successful reconciliation of this account.',
    `lei` STRING COMMENT '20-character ISO 17442 Legal Entity Identifier for the account holder, used for regulatory reporting and counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `minimum_balance_requirement` DECIMAL(18,2) COMMENT 'Minimum balance that must be maintained in the account to avoid fees or restrictions, in the account currency.',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, special instructions, or account-specific details.',
    `overdraft_allowed_flag` BOOLEAN COMMENT 'Indicates whether the account is permitted to have a negative balance (overdraft facility).',
    `overdraft_limit_amount` DECIMAL(18,2) COMMENT 'Maximum negative balance permitted on this account, in the account currency.',
    `reconciliation_frequency` STRING COMMENT 'Frequency at which this account is reconciled between internal records and custodian statements.. Valid values are `daily|weekly|monthly|quarterly`',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether transactions in this account are subject to regulatory reporting requirements (EMIR, MiFID II, etc.).',
    `sweep_arrangement_flag` BOOLEAN COMMENT 'Indicates whether this account participates in an automated cash sweep arrangement to optimize liquidity.',
    `sweep_threshold_amount` DECIMAL(18,2) COMMENT 'Balance threshold above which excess cash is automatically swept to the target account.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this cash account record was last modified.',
    CONSTRAINT pk_cash_account PRIMARY KEY(`cash_account_id`)
) COMMENT 'Master record for each cash and settlement account maintained at custodian banks (State Street, Northern Trust) and internal treasury accounts. Captures account number, BIC/SWIFT, IBAN, correspondent bank details, currency, account type (settlement';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`liquidity_forecast` (
    `liquidity_forecast_id` BIGINT COMMENT 'Unique identifier for the liquidity forecast record.',
    `approved_by_user_employee_id` BIGINT COMMENT 'Identifier of the treasury manager or authorized approver who approved the liquidity forecast for publication.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: Pension fund liquidity stress testing requires modeling cash flows under multiple economic scenarios (baseline, adverse, severely adverse).',
    `employee_id` BIGINT COMMENT 'Identifier of the treasury analyst or system user who prepared the liquidity forecast.',
    `liability_cash_flow_id` BIGINT COMMENT 'Foreign key linking to actuarial.liability_cash_flow. Business justification: Granular liquidity forecasting requires detailed liability cash flow projections by period.',
    `liability_projection_id` BIGINT COMMENT 'Foreign key linking to actuarial.liability_projection. Business justification: Pension liquidity forecasting requires projected benefit payment outflows from actuarial liability projections.',
    `liquidity_reserve_policy_id` BIGINT COMMENT 'Foreign key linking to treasury.liquidity_reserve_policy. Business justification: Liquidity forecasts are governed by liquidity reserve policies. Links forecast to applicable policy.',
    `liquidity_risk_assessment_id` BIGINT COMMENT 'Foreign key linking to risk.liquidity_risk_assessment. Business justification: Liquidity forecasts inform and are validated against liquidity risk assessments.',
    `superseded_by_forecast_liquidity_forecast_id` BIGINT COMMENT 'Reference to the subsequent liquidity forecast that supersedes this forecast, enabling version tracking and audit trail.',
    `valuation_cycle_id` BIGINT COMMENT 'Foreign key linking to valuation.cycle. Business justification: Liquidity forecasts must align with valuation cycles for pension fund cash planning. Forecasted cash needs are validated against NAV dates to ensure sufficient liquidity for benefit payments',
    `approval_timestamp` TIMESTAMP COMMENT 'The date and time when the liquidity forecast was approved by the authorized approver.',
    `capital_call_funding_amount` DECIMAL(20,2) COMMENT 'Projected capital call drawdowns from private equity, infrastructure, real estate, and other illiquid commitments requiring cash funding during the forecast period.',
    `closing_cash_position_amount` DECIMAL(20,2) COMMENT 'The projected ending cash and cash equivalents balance at the end of the forecast period, calculated as opening position plus net inflows minus net outflows.',
    `collateral_movement_net_amount` DECIMAL(20,2) COMMENT 'Net cash impact from collateral posting and return requirements for derivatives, securities lending, and repo transactions.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when the liquidity forecast record was first created in the system.',
    `currency_code` STRING COMMENT 'The three-letter ISO 4217 currency code in which the forecast amounts are denominated (e.g., USD, GBP, EUR).. Valid values are `^[A-Z]{3}$`',
    `distribution_inflow_amount` DECIMAL(20,2) COMMENT 'Projected cash distributions from private market investments, including dividends, interest, and capital returns during the forecast period.',
    `fee_expense_amount` DECIMAL(20,2) COMMENT 'Projected cash outflows for investment management fees, custody fees, advisory fees, and carried interest payments during the forecast period.',
    `forecast_confidence_level` STRING COMMENT 'The assessed confidence level in the accuracy of the forecast, based on data quality, market volatility, and assumption reliability.. Valid values are `high|medium|low`',
    `forecast_date` DATE COMMENT 'The as-of date for which this liquidity forecast is prepared, representing the base date from which forward projections are calculated.',
    `forecast_horizon_end_date` DATE COMMENT 'The end date of the forecast projection period.',
    `forecast_horizon_start_date` DATE COMMENT 'The start date of the forecast projection period.',
    `forecast_methodology` STRING COMMENT 'Description of the methodology and assumptions used to prepare the liquidity forecast, including statistical models, historical trends, and expert judgment.',
    `forecast_reference_number` STRING COMMENT 'Business identifier for the liquidity forecast, used for external reference and reporting.. Valid values are `^LF-[0-9]{8}-[A-Z0-9]{6}$`',
    `forecast_scenario` STRING COMMENT 'The scenario assumption under which the liquidity forecast is prepared, enabling stress testing and sensitivity analysis.. Valid values are `base|optimistic|pessimistic|stress|recovery|custom`',
    `forecast_status` STRING COMMENT 'Current lifecycle status of the liquidity forecast in the approval and publication workflow.. Valid values are `draft|submitted|approved|published|superseded|archived`',
    `forecast_type` STRING COMMENT 'Classification of the forecast by time horizon and purpose: short-term (T+1 to T+30), medium-term (T+30 to T+90), long-term (T+90 to T+365), strategic, tactical, or operational.. Valid values are `short_term|medium_term|long_term|strategic|tactical|operational`',
    `fx_hedge_settlement_amount` DECIMAL(20,2) COMMENT 'Projected cash flows from foreign exchange forward and swap settlements used for currency hedging during the forecast period.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The date and time when the liquidity forecast record was last updated or modified.',
    `liquidity_surplus_deficit_amount` DECIMAL(20,2) COMMENT 'The projected surplus (positive) or deficit (negative) relative to the minimum liquidity threshold, indicating whether additional funding or investment actions are required.',
    `minimum_liquidity_threshold_amount` DECIMAL(20,2) COMMENT 'The minimum cash balance required to meet operational needs, regulatory requirements, and risk management policies.',
    `net_contribution_inflow_amount` DECIMAL(20,2) COMMENT 'Projected net contributions from beneficiary pools (one per participating plan) during the forecast period, net of benefit payments and withdrawals.',
    `notes` STRING COMMENT 'Free-text notes and commentary providing additional context, assumptions, risks, or qualifications related to the liquidity forecast.',
    `opening_cash_position_amount` DECIMAL(20,2) COMMENT 'The starting cash and cash equivalents balance at the beginning of the forecast period, aggregated across all custody accounts and treasury instruments.',
    `operational_expense_amount` DECIMAL(20,2) COMMENT 'Projected cash outflows for operational expenses including payroll, technology, facilities, and administrative costs.',
    `other_inflow_amount` DECIMAL(20,2) COMMENT 'Projected cash inflows from other sources not categorized above, including tax refunds, legal settlements, and miscellaneous receipts.',
    `other_outflow_amount` DECIMAL(20,2) COMMENT 'Projected cash outflows for other purposes not categorized above, including tax payments, legal settlements, and miscellaneous disbursements.',
    `published_timestamp` TIMESTAMP COMMENT 'The date and time when the liquidity forecast was published and made available to stakeholders.',
    `short_term_investment_maturity_amount` DECIMAL(20,2) COMMENT 'Projected cash inflows from maturing short-term liquidity instruments such as Treasury Bills (T-Bills), commercial paper, and SOFR-linked instruments.',
    `short_term_investment_purchase_amount` DECIMAL(20,2) COMMENT 'Projected cash outflows for purchasing short-term liquidity instruments to manage excess cash.',
    `trade_settlement_net_amount` DECIMAL(20,2) COMMENT 'Net cash impact from expected trade settlements across public equities, fixed income, and derivatives, calculated as settlement inflows minus outflows.',
    CONSTRAINT pk_liquidity_forecast PRIMARY KEY(`liquidity_forecast_id`)
) COMMENT 'Forward-looking liquidity projection records covering short-term (T+1 to T+30), medium-term (T+30 to T+90), and long-term (T+90 to T+365) horizons. Aggregates expected net contribution inflows from beneficiary pools (several participating plans';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`net_contribution_inflow` (
    `net_contribution_inflow_id` BIGINT COMMENT 'Unique identifier for the net contribution inflow record.',
    `cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: Net contribution inflows are deposited into cash accounts; linking tracks the destination account.',
    `contributor_pool_id` BIGINT COMMENT 'Reference to the beneficiary pool from which the contribution originated (one per participating plan).',
    `participating_employer_id` BIGINT COMMENT 'Reference to the participating employer that remitted the contribution on behalf of members.',
    `allocation_date` DATE COMMENT 'The date on which the contribution was allocated to investment portfolios or asset classes.',
    `allocation_status` STRING COMMENT 'Indicates whether the net contribution has been allocated to investment strategies per the Strategic Asset Allocation (SAA).. Valid values are `unallocated|partially_allocated|fully_allocated`',
    `base_currency_amount` DECIMAL(18,2) COMMENT 'Net contribution amount converted to the fund base currency using the applicable FX rate.',
    `contribution_date` DATE COMMENT 'The date on which the net contribution was received or credited to the fund.',
    `contribution_period_end` DATE COMMENT 'End date of the payroll or contribution period covered by this inflow.',
    `contribution_period_start` DATE COMMENT 'Start date of the payroll or contribution period covered by this inflow.',
    `contribution_reference_number` STRING COMMENT 'External reference number assigned to this contribution inflow by the custody platform or remittance system.',
    `contribution_status` STRING COMMENT 'Current lifecycle status of the contribution inflow in the treasury workflow.. Valid values are `pending|cleared|allocated|reversed|reconciled|disputed`',
    `contribution_type` STRING COMMENT 'Classification of the contribution inflow by source or purpose.. Valid values are `regular|special|buyback|transfer_in|employer_match|voluntary`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this contribution inflow record was first created in the treasury system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the contribution was received.. Valid values are `^[A-Z]{3}$`',
    `custody_account_number` STRING COMMENT 'Account number at the custody platform where the contribution was received.',
    `deduction_amount` DECIMAL(18,2) COMMENT 'Total amount deducted from the gross contribution for fees, taxes, or other adjustments.',
    `fx_rate` DECIMAL(18,6) COMMENT 'Exchange rate applied if the contribution was received in a foreign currency and converted to the fund base currency.',
    `gross_contribution_amount` DECIMAL(18,2) COMMENT 'Total contribution amount received before any deductions or adjustments.',
    `liquidity_reserve_amount` DECIMAL(18,2) COMMENT 'Amount of the net contribution held in short-term liquidity instruments for cash management purposes.',
    `liquidity_reserve_flag` BOOLEAN COMMENT 'Indicates whether a portion of this contribution was held in liquidity reserves (T-Bills, SOFR-linked instruments) rather than immediately allocated.',
    `member_count` BIGINT COMMENT 'Number of individual members whose contributions are aggregated in this inflow record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this contribution inflow record was last modified.',
    `net_contribution_amount` DECIMAL(18,2) COMMENT 'Net investable capital after all deductions, representing the amount available for allocation to investment strategies.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding the contribution inflow, exceptions, or special handling instructions.',
    `reconciliation_date` DATE COMMENT 'The date on which the contribution was successfully reconciled with custody records.',
    `reconciliation_status` STRING COMMENT 'Status of the reconciliation between the contribution record and custody platform settlement records.. Valid values are `pending|matched|unmatched|exception`',
    `remittance_method` STRING COMMENT 'The payment method or channel through which the contribution was received.. Valid values are `wire|ach|check|direct_debit|electronic_transfer`',
    `remitting_institution_bic` STRING COMMENT 'BIC or SWIFT code of the remitting financial institution.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `remitting_institution_name` STRING COMMENT 'Name of the financial institution or employer that remitted the contribution.',
    `settlement_date` DATE COMMENT 'The date on which the contribution cash settled in the custody account.',
    `value_date` DATE COMMENT 'The effective date from which the contribution begins accruing investment returns.',
    CONSTRAINT pk_net_contribution_inflow PRIMARY KEY(`net_contribution_inflow_id`)
) COMMENT 'Records of net pension contributions received from each beneficiary pool (one per participating plan) representing the primary source of investable capital.';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`capital_call_funding` (
    `capital_call_funding_id` BIGINT COMMENT 'Unique identifier for the capital call funding record.',
    `adjustment_id` BIGINT COMMENT 'Reference to the payment confirmation document received from the General Partner (GP) or custodian bank.',
    `bank_account_ssi_id` BIGINT COMMENT 'Reference to the General Partner (GP) bank account receiving the capital call funding.',
    `confirmation_document_id` BIGINT COMMENT 'Reference to the payment confirmation document received from the General Partner (GP) or custodian bank.',
    `dd_engagement_id` BIGINT COMMENT 'Foreign key linking to diligence.dd_engagement. Business justification: Capital call funding requires verification that the underlying investment passed DD and IC approval. Treasury operations must confirm diligence clearance before releasing funds.',
    `employee_id` BIGINT COMMENT 'Reference to the treasury or investment committee user who approved the capital call funding.',
    `fund_investment_id` BIGINT COMMENT 'Reference to the private market fund investment that issued this capital call.',
    `fx_forward_id` BIGINT COMMENT 'Foreign key linking to treasury.fx_forward. Business justification: Capital call funding with FX hedge applied should link to the specific FX forward used for hedging.',
    `fx_hedge_instrument_id` BIGINT COMMENT 'Reference to the foreign exchange forward or swap instrument used to hedge this capital call funding.',
    `gp_bank_account_id` BIGINT COMMENT 'Reference to the General Partner (GP) bank account receiving the capital call funding.',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Capital call funding requires direct GP identification for payment routing, call verification, and GP communication.',
    `infra_fund_commitment_id` BIGINT COMMENT 'Foreign key linking to infrastructure.infra_fund_commitment. Business justification: Capital call funding is linked to the fund commitment to track capital call execution.',
    `source_cash_account_id` BIGINT COMMENT 'Reference to the internal cash account from which the capital call funding was sourced.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_asset_valuation. Business justification: Capital call funding links to asset valuations for tracking cost basis versus fair value.',
    `approval_workflow_reference` BIGINT COMMENT 'Reference to the internal approval workflow instance for this capital call funding.',
    `base_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the pension fund base currency.. Valid values are `^[A-Z]{3}$`',
    `call_amount_requested` DECIMAL(18,2) COMMENT 'Total capital amount requested by the General Partner (GP) in the fund currency.',
    `call_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the capital call amount.. Valid values are `^[A-Z]{3}$`',
    `call_due_date` DATE COMMENT 'Date by which the capital call funding must be received by the General Partner (GP) per the Limited Partnership Agreement (LPA).',
    `call_notice_date` DATE COMMENT 'Date the capital call notice was issued by the General Partner (GP).',
    `call_notice_number` STRING COMMENT 'External reference number assigned by the General Partner (GP) to the capital call notice.',
    `call_purpose_description` STRING COMMENT 'Business purpose or investment use case for the capital call as stated by the General Partner (GP).',
    `call_type` STRING COMMENT 'Classification of the capital call purpose per Limited Partnership Agreement (LPA) terms.. Valid values are `investment|management_fee|organizational_expense|other`',
    `commitment_percentage_called` DECIMAL(5,2) COMMENT 'Percentage of the total Limited Partner (LP) commitment being called in this drawdown.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the capital call funding record was first created in the system.',
    `custodian_reference_number` STRING COMMENT 'Reference number assigned by the custody platform for tracking the capital call funding settlement.',
    `default_interest_rate` DECIMAL(5,2) COMMENT 'Annual interest rate applied to late capital call payments per Limited Partnership Agreement (LPA) terms.',
    `funding_amount_base_currency` DECIMAL(18,2) COMMENT 'Capital call funding amount converted to the pension fund base currency for accounting.',
    `funding_approval_date` DATE COMMENT 'Date the capital call funding was approved by internal treasury or investment committee.',
    `funding_execution_date` DATE COMMENT 'Date the capital call funding payment was executed and sent to the General Partner (GP).',
    `funding_priority` STRING COMMENT 'Internal priority level assigned to this capital call funding based on strategic importance and liquidity constraints.. Valid values are `high|medium|low`',
    `funding_settlement_date` DATE COMMENT 'Date the capital call funding payment settled in the General Partner (GP) account per confirmation.',
    `funding_status` STRING COMMENT 'Current workflow status of the capital call funding process.. Valid values are `pending|approved|funded|partially_funded|rejected|cancelled`',
    `fx_hedge_applied_flag` BOOLEAN COMMENT 'Indicates whether a foreign exchange hedge instrument was used to mitigate currency risk for this funding.',
    `fx_rate` DECIMAL(12,6) COMMENT 'Foreign exchange rate applied to convert call currency to base currency at funding execution.',
    `gp_account_number` STRING COMMENT 'Bank account number of the General Partner (GP) receiving the capital call funding.',
    `gp_bank_name` STRING COMMENT 'Name of the bank holding the General Partner (GP) account for this capital call.',
    `gp_swift_bic_code` STRING COMMENT 'SWIFT Bank Identifier Code (BIC) for the General Partner (GP) receiving bank.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `late_payment_penalty_amount` DECIMAL(18,2) COMMENT 'Penalty amount incurred if the capital call funding is not received by the due date per Limited Partnership Agreement (LPA).',
    `liquidity_source` STRING COMMENT 'Source of liquidity used to fund the capital call within the pension fund treasury operations.. Valid values are `cash_on_hand|liquidated_securities|short_term_borrowing|net_contributions`',
    `notes` STRING COMMENT 'Additional operational notes or comments related to the capital call funding workflow.',
    `payment_method` STRING COMMENT 'Payment instrument used to transfer the capital call funding to the General Partner (GP).. Valid values are `wire_transfer|ach|swift|sepa|internal_transfer`',
    `payment_reference_number` STRING COMMENT 'Unique reference number assigned by the treasury system or bank for the payment transaction.',
    `reconciliation_date` DATE COMMENT 'Date the capital call funding was reconciled with General Partner (GP) records and custody platform.',
    `reconciliation_status` STRING COMMENT 'Status of the reconciliation between internal funding records and General Partner (GP) confirmation.. Valid values are `pending|reconciled|discrepancy|under_review`',
    `rejection_reason` STRING COMMENT 'Explanation provided if the capital call funding was rejected or cancelled by internal treasury.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the capital call funding record was last modified.',
    CONSTRAINT pk_capital_call_funding PRIMARY KEY(`capital_call_funding_id`)
) COMMENT 'Operational records tracking the funding workflow for private market capital calls (drawdowns) issued by GPs across private equity, infrastructure, real estate, and natural resources funds.';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`fx_position` (
    `fx_position_id` BIGINT COMMENT 'Unique identifier for the foreign exchange position record.',
    `hedge_program_id` BIGINT COMMENT 'Foreign key linking to treasury.hedge_program. Business justification: FX positions are managed under hedge programs. Links position to governing hedge program.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio holding this FX position.',
    `base_currency` STRING COMMENT 'Three-letter ISO 4217 code for the base currency of the position (e.g., USD for US Dollar).. Valid values are `^[A-Z]{3}$`',
    `collateral_posted_base` DECIMAL(20,2) COMMENT 'Total collateral posted to counterparties under Credit Support Annex (CSA) agreements for FX derivative positions in this currency pair.',
    `collateral_received_base` DECIMAL(20,2) COMMENT 'Total collateral received from counterparties under CSA agreements for FX derivative positions in this currency pair.',
    `comments` STRING COMMENT 'Free-text field for treasury analysts to record notes, exceptions, or special circumstances related to this FX position.',
    `counterparty_concentration_pct` DECIMAL(5,4) COMMENT 'Percentage of total hedge notional concentrated with the largest single counterparty for this currency pair, used for counterparty risk monitoring.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this FX position record was first created in the system.',
    `currency_pair` STRING COMMENT 'Standard currency pair notation combining base and quote currencies (e.g., EUR/USD).. Valid values are `^[A-Z]{3}/[A-Z]{3}$`',
    `data_source_system` STRING COMMENT 'Source system from which the FX position data was extracted (e.g., SimCorp Dimension, BlackRock Aladdin, custody platform).. Valid values are `simcorp|aladdin|state_street|northern_trust|bloomberg|manual`',
    `dv01_base` DECIMAL(20,2) COMMENT 'Sensitivity of the FX position value to a 1 basis point move in the exchange rate, expressed in base currency.',
    `forward_hedge_notional_base` DECIMAL(20,2) COMMENT 'Aggregate notional amount of FX forward contracts used to hedge exposure, expressed in base currency.',
    `hedge_designation` STRING COMMENT 'Accounting hedge designation classification under IFRS 9 for the FX hedging relationship.. Valid values are `cash_flow_hedge|fair_value_hedge|net_investment_hedge|economic_hedge|not_designated`',
    `hedge_effectiveness_ratio` DECIMAL(5,4) COMMENT 'Measure of hedge effectiveness per IFRS 9, calculated as the ratio of hedge instrument value change to hedged item value change.',
    `hedge_ratio_actual` DECIMAL(5,4) COMMENT 'Current hedge ratio expressed as a decimal, calculated as total hedge notional divided by spot exposure (e.g., 0.9500 represents 95% hedged).',
    `hedge_ratio_target` DECIMAL(5,4) COMMENT 'Strategic target hedge ratio as defined by treasury policy for this currency pair, expressed as a decimal.',
    `hedge_ratio_variance` DECIMAL(5,4) COMMENT 'Difference between actual and target hedge ratios, indicating over-hedging (positive) or under-hedging (negative).',
    `last_rebalance_date` DATE COMMENT 'Most recent date when the FX hedge position was rebalanced to align with target hedge ratio.',
    `mtm_value_base` DECIMAL(20,2) COMMENT 'Current mark-to-market valuation of all FX hedging instruments for this currency pair, expressed in base currency.',
    `net_open_exposure_base` DECIMAL(20,2) COMMENT 'Net unhedged FX exposure after accounting for all hedging instruments, calculated as spot exposure minus total hedge notional.',
    `next_scheduled_rebalance_date` DATE COMMENT 'Planned date for the next periodic hedge rebalancing review per treasury calendar.',
    `option_hedge_notional_base` DECIMAL(20,2) COMMENT 'Aggregate notional amount of FX option contracts used to hedge exposure, expressed in base currency.',
    `position_date` DATE COMMENT 'Business date for which this FX position snapshot is recorded.',
    `position_owner` STRING COMMENT 'Name or identifier of the treasury desk or portfolio manager responsible for managing this FX position.',
    `position_status` STRING COMMENT 'Current operational status of the FX position record in the treasury management system.. Valid values are `active|closed|suspended|under_review`',
    `quote_currency` STRING COMMENT 'Three-letter ISO 4217 code for the quote currency in the currency pair (e.g., USD for US Dollar).. Valid values are `^[A-Z]{3}$`',
    `rebalance_required_flag` BOOLEAN COMMENT 'Indicator whether the position requires rebalancing to bring actual hedge ratio back within target tolerance bands.',
    `rebalance_threshold_breach_date` DATE COMMENT 'Date when the hedge ratio variance first exceeded the policy-defined tolerance threshold, triggering rebalance requirement.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicator whether this FX position is subject to regulatory reporting requirements under EMIR, MiFID II, or other jurisdictional mandates.',
    `spot_exposure_base` DECIMAL(20,2) COMMENT 'Total unhedged foreign exchange exposure in base currency terms arising from underlying asset holdings.',
    `spot_rate` DECIMAL(12,6) COMMENT 'Current market spot exchange rate for the currency pair as of position date.',
    `swap_hedge_notional_base` DECIMAL(20,2) COMMENT 'Aggregate notional amount of FX swap contracts used to hedge exposure, expressed in base currency.',
    `total_hedge_notional_base` DECIMAL(20,2) COMMENT 'Sum of all FX hedging instrument notionals (forwards, swaps, options) in base currency.',
    `unrealized_pnl_base` DECIMAL(20,2) COMMENT 'Unrealized gain or loss on FX hedging instruments since inception, expressed in base currency.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this FX position record was last modified.',
    `var_1day_95pct_base` DECIMAL(20,2) COMMENT 'One-day Value at Risk at 95% confidence level for the net open FX exposure, expressed in base currency.',
    `weighted_avg_forward_rate` DECIMAL(12,6) COMMENT 'Notional-weighted average forward rate across all outstanding FX forward hedge contracts for this currency pair.',
    CONSTRAINT pk_fx_position PRIMARY KEY(`fx_position_id`)
) COMMENT 'Master record of the funds aggregate foreign exchange exposure by currency pair, capturing spot exposure, forward hedge notional, net open exposure, hedge ratio, and target hedge ratio per currency.';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`fx_forward` (
    `fx_forward_id` BIGINT COMMENT 'Unique identifier for the FX forward contract record.',
    `cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: FX forward contracts are settled against a cash account; linking provides direct access to settlement details.',
    `csa_agreement_csa_id` BIGINT COMMENT 'Reference to the Credit Support Annex that governs collateral posting requirements for this forward contract.',
    `csa_id` BIGINT COMMENT 'Reference to the Credit Support Annex that governs collateral posting requirements for this forward contract.',
    `employee_id` BIGINT COMMENT 'Employee identifier of the treasury trader who executed the forward contract.',
    `fx_position_id` BIGINT COMMENT 'Foreign key linking to treasury.fx_position. Business justification: FX forward contracts contribute to aggregate FX position. Links forward to its position record for exposure tracking.',
    `hedge_program_id` BIGINT COMMENT 'Foreign key linking to treasury.hedge_program. Business justification: FX forwards are executed as part of hedge programs. Links forward to governing hedge program for program-level reporting.',
    `isda_master_agreement_isda_master_id` BIGINT COMMENT 'Reference to the ISDA Master Agreement governing the legal terms of this derivative transaction.',
    `isda_master_id` BIGINT COMMENT 'Reference to the ISDA Master Agreement governing the legal terms of this derivative transaction.',
    `netting_agreement_id` BIGINT COMMENT 'Identifier for the group of transactions with the same counterparty that are subject to close-out netting under the ISDA agreement.',
    `netting_set_netting_agreement_id` BIGINT COMMENT 'Identifier for the group of transactions with the same counterparty that are subject to close-out netting under the ISDA agreement.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio or asset class that generated the currency exposure being hedged.',
    `treasury_fx_rate_id` BIGINT COMMENT 'Foreign key linking to treasury.treasury_fx_rate. Business justification: FX forward contracts reference the applicable treasury FX rate for pricing; linking ensures rate consistency.',
    `approval_authority` STRING COMMENT 'Name or role of the individual or committee that approved the execution of this forward contract.',
    `approval_date` DATE COMMENT 'Date on which the forward contract was approved by the designated authority.',
    `booking_timestamp` TIMESTAMP COMMENT 'Date and time when the forward contract was recorded in the treasury management system.',
    `buy_amount` DECIMAL(20,2) COMMENT 'Notional amount of the currency being purchased, denominated in the buy currency.',
    `buy_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the currency being purchased in the forward contract.. Valid values are `^[A-Z]{3}$`',
    `central_counterparty_name` STRING COMMENT 'Name of the central clearing house if the contract is centrally cleared.',
    `clearing_status` STRING COMMENT 'Indicates whether the forward contract is centrally cleared through a CCP or remains bilateral.. Valid values are `cleared|bilateral|exempt`',
    `collateral_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the currency in which collateral is posted.. Valid values are `^[A-Z]{3}$`',
    `collateral_posted_amount` DECIMAL(20,2) COMMENT 'Amount of collateral posted by the pension fund to the counterparty to secure the forward contract, denominated in the collateral currency.',
    `contract_status` STRING COMMENT 'Current lifecycle status of the FX forward contract.. Valid values are `pending|confirmed|settled|cancelled|expired|amended`',
    `counterparty_lei` STRING COMMENT '20-character ISO 17442 Legal Entity Identifier for the financial institution counterparty to the FX forward contract.. Valid values are `^[A-Z0-9]{20}$`',
    `counterparty_name` STRING COMMENT 'Legal name of the financial institution or bank acting as counterparty to the forward contract.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this record was first created in the data platform.',
    `custodian_name` STRING COMMENT 'Name of the custody bank or settlement agent facilitating the currency exchange.',
    `forward_points` DECIMAL(18,8) COMMENT 'Difference between the forward rate and the spot rate at inception, representing the interest rate differential between the two currencies.',
    `forward_rate` DECIMAL(18,8) COMMENT 'Agreed exchange rate at which the currency pair will be exchanged on the value date, expressed as units of sell currency per unit of buy currency.',
    `hedge_designation` STRING COMMENT 'Accounting hedge classification under IFRS 9 or equivalent standard, indicating the type of hedge relationship.. Valid values are `cash_flow_hedge|fair_value_hedge|net_investment_hedge|economic_hedge|undesignated`',
    `hedge_effectiveness_test_method` STRING COMMENT 'Methodology used to assess whether the hedge relationship qualifies for hedge accounting treatment.',
    `hedge_ratio` DECIMAL(5,4) COMMENT 'Proportion of the underlying currency exposure that this forward contract is intended to hedge, expressed as a decimal.',
    `mark_to_market_value` DECIMAL(20,2) COMMENT 'Current fair value of the forward contract based on prevailing market rates, denominated in the base currency.',
    `maturity_date` DATE COMMENT 'Final date of the forward contract when the obligation must be fulfilled or the contract expires.',
    `mtm_valuation_date` DATE COMMENT 'Date as of which the mark-to-market value was last calculated.',
    `realized_gain_loss` DECIMAL(20,2) COMMENT 'Actual profit or loss realized upon settlement or early termination of the forward contract.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this forward contract is subject to regulatory reporting requirements under EMIR, Dodd-Frank, or equivalent.',
    `sell_amount` DECIMAL(20,2) COMMENT 'Notional amount of the currency being sold, denominated in the sell currency.',
    `sell_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the currency being sold in the forward contract.. Valid values are `^[A-Z]{3}$`',
    `settlement_account_buy` STRING COMMENT 'Bank account or custody account identifier where the purchased currency will be received upon settlement.',
    `settlement_account_sell` STRING COMMENT 'Bank account or custody account identifier from which the sold currency will be debited upon settlement.',
    `settlement_method` STRING COMMENT 'Mechanism by which the forward contract will be settled at maturity.. Valid values are `physical_delivery|cash_settlement|net_settlement`',
    `spot_rate_at_inception` DECIMAL(18,8) COMMENT 'Market spot exchange rate for the currency pair at the time the forward contract was executed.',
    `termination_date` DATE COMMENT 'Date on which the forward contract was terminated early, if applicable.',
    `termination_reason` STRING COMMENT 'Business reason for early termination of the forward contract, such as change in hedge strategy or underlying exposure elimination.',
    `trade_confirmation_date` DATE COMMENT 'Date on which the trade confirmation was received and validated by both parties.',
    `trade_date` DATE COMMENT 'Date on which the FX forward contract was executed and agreed upon by both parties.',
    `trade_reference_number` STRING COMMENT 'External business identifier for the FX forward trade, typically assigned by the trading platform or counterparty.',
    `trading_desk` STRING COMMENT 'Internal treasury or trading desk responsible for executing and managing this FX forward contract.',
    `underlying_exposure_type` STRING COMMENT 'Nature of the currency exposure being hedged, such as foreign equity investment, private equity commitment, real estate acquisition, or infrastructure asset.',
    `unique_transaction_identifier` STRING COMMENT 'Globally unique identifier for the transaction as required by regulatory reporting frameworks.',
    `unrealized_gain_loss` DECIMAL(20,2) COMMENT 'Cumulative unrealized profit or loss on the forward contract since inception, based on current market rates.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp when this record was last modified in the data platform.',
    `value_date` DATE COMMENT 'Settlement date when the currency exchange will occur and funds will be transferred.',
    CONSTRAINT pk_fx_forward PRIMARY KEY(`fx_forward_id`)
) COMMENT 'Transactional record for each FX forward contract executed to hedge currency exposure arising from non-base-currency investments. Captures trade date, value date, maturity date, buy currency, sell currency, notional amount, forward rate, spot rate at inception';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`fx_swap` (
    `fx_swap_id` BIGINT COMMENT 'Unique identifier for the FX swap transaction record.',
    `counterparty_id` BIGINT COMMENT 'Reference to the financial institution or entity serving as the counterparty to this FX swap transaction.',
    `custody_account_id` BIGINT COMMENT 'Reference to the custody account at State Street or Northern Trust through which the FX swap cash flows will be settled.',
    `employee_id` BIGINT COMMENT 'Reference to the individual trader or portfolio manager who executed this FX swap transaction.',
    `fx_position_id` BIGINT COMMENT 'Foreign key linking to treasury.fx_position. Business justification: FX swap contracts contribute to aggregate FX position. Links swap to its position record for exposure tracking.',
    `hedge_program_id` BIGINT COMMENT 'Foreign key linking to treasury.hedge_program. Business justification: FX swaps are used to roll hedges as part of hedge programs. Links swap to governing hedge program.',
    `isda_agreement_isda_master_id` BIGINT COMMENT 'Reference to the master ISDA agreement governing this FX swap transaction, establishing legal terms and credit support arrangements.',
    `isda_master_id` BIGINT COMMENT 'Reference to the master ISDA agreement governing this FX swap transaction, establishing legal terms and credit support arrangements.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio or fund to which this FX swap is allocated for performance attribution and risk reporting.',
    `treasury_fx_rate_id` BIGINT COMMENT 'Foreign key linking to treasury.treasury_fx_rate. Business justification: FX swap rates should reference treasury_fx_rate for rate source traceability and audit.',
    `accrued_interest_amount` DECIMAL(20,4) COMMENT 'The interest differential that has accrued on the swap position since trade date, reflecting the time value component of the swap points.',
    `base_currency_code` STRING COMMENT 'The base currency in the FX swap pair, representing the currency being bought or sold in the near leg.. Valid values are `^[A-Z]{3}$`',
    `ccp_name` STRING COMMENT 'Name of the central clearing house if the swap is centrally cleared (e.g., LCH, CME), null for bilateral trades.',
    `clearing_status` STRING COMMENT 'Indicates whether the FX swap is cleared through a Central Counterparty (CCP) or remains bilateral, per EMIR clearing obligations.. Valid values are `bilateral|centrally_cleared|exempt`',
    `confirmation_status` STRING COMMENT 'Status of trade confirmation with the counterparty, tracking whether economic terms have been mutually agreed and documented.. Valid values are `pending|confirmed|disputed|amended`',
    `confirmation_timestamp` TIMESTAMP COMMENT 'Timestamp when the FX swap trade confirmation was received and matched with the counterparty.',
    `counterparty_lei` STRING COMMENT 'The 20-character ISO 17442 Legal Entity Identifier of the counterparty, required for regulatory reporting under EMIR and MiFID II.. Valid values are `^[A-Z0-9]{20}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this FX swap record was first created in the system.',
    `csa_applicable_flag` BOOLEAN COMMENT 'Indicates whether a Credit Support Annex is in place for this swap, governing collateral posting requirements.',
    `currency_pair` STRING COMMENT 'The two currencies involved in the swap expressed as base currency / quote currency (e.g., USD/JPY, EUR/USD), following ISO 4217 three-letter codes.. Valid values are `^[A-Z]{3}/[A-Z]{3}$`',
    `execution_venue` STRING COMMENT 'The platform or venue through which the FX swap was executed (e.g., Bloomberg FXGO, direct counterparty negotiation, electronic trading platform).',
    `far_leg_base_amount` DECIMAL(20,4) COMMENT 'Notional amount of the base currency exchanged in the far leg of the swap.',
    `far_leg_date` DATE COMMENT 'Settlement date for the second leg of the FX swap, typically the later of the two exchange dates, reversing the near leg transaction.',
    `far_leg_direction` STRING COMMENT 'Direction of the base currency transaction in the far leg: opposite of near leg direction to complete the swap structure.. Valid values are `buy|sell`',
    `far_leg_exchange_rate` DECIMAL(18,8) COMMENT 'The agreed FX rate applied to the far leg transaction, expressed as quote currency per unit of base currency.',
    `far_leg_quote_amount` DECIMAL(20,4) COMMENT 'Notional amount of the quote currency exchanged in the far leg of the swap.',
    `far_leg_settlement_timestamp` TIMESTAMP COMMENT 'Actual timestamp when the far leg cash flows were settled through the custody account.',
    `hedge_designation` STRING COMMENT 'Accounting hedge designation under IFRS 9 or equivalent standard, determining how gains and losses are recognized in financial statements.. Valid values are `cash_flow_hedge|fair_value_hedge|net_investment_hedge|economic_hedge|not_designated`',
    `hedge_ratio` DECIMAL(8,4) COMMENT 'The proportion of the underlying currency exposure that this FX swap is intended to hedge, expressed as a decimal (e.g., 1.0000 for 100% hedge).',
    `hedged_item_reference` STRING COMMENT 'Business reference to the underlying exposure being hedged (e.g., foreign equity position, private equity commitment, infrastructure asset), linking the swap to its economic purpose.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this FX swap record was last updated, supporting audit trail and data lineage requirements.',
    `mark_to_market_value` DECIMAL(20,4) COMMENT 'Current fair value of the FX swap position based on prevailing market rates, used for NAV calculation and risk reporting.',
    `mtm_currency_code` STRING COMMENT 'The currency in which the mark-to-market value is expressed, typically the funds base currency.. Valid values are `^[A-Z]{3}$`',
    `mtm_valuation_date` DATE COMMENT 'The date as of which the mark-to-market value was calculated, typically the most recent business day.',
    `near_leg_base_amount` DECIMAL(20,4) COMMENT 'Notional amount of the base currency exchanged in the near leg of the swap.',
    `near_leg_date` DATE COMMENT 'Settlement date for the first leg of the FX swap, typically the earlier of the two exchange dates.',
    `near_leg_direction` STRING COMMENT 'Direction of the base currency transaction in the near leg: buy indicates purchasing base currency, sell indicates selling base currency.. Valid values are `buy|sell`',
    `near_leg_exchange_rate` DECIMAL(18,8) COMMENT 'The agreed FX rate applied to the near leg transaction, expressed as quote currency per unit of base currency.',
    `near_leg_quote_amount` DECIMAL(20,4) COMMENT 'Notional amount of the quote currency exchanged in the near leg of the swap.',
    `near_leg_settlement_timestamp` TIMESTAMP COMMENT 'Actual timestamp when the near leg cash flows were settled through the custody account.',
    `notes` STRING COMMENT 'Free-text field for operational notes, special instructions, or context regarding the FX swap execution and purpose.',
    `quote_currency_code` STRING COMMENT 'The quote currency in the FX swap pair, representing the counter-currency used to price the base currency.. Valid values are `^[A-Z]{3}$`',
    `reporting_timestamp` TIMESTAMP COMMENT 'Timestamp when this FX swap transaction was reported to the trade repository, meeting EMIR T+1 reporting requirements.',
    `settlement_method` STRING COMMENT 'The method by which the FX swap will be settled: physical delivery involves actual currency exchange, cash settlement involves net payment, netting offsets multiple positions.. Valid values are `physical_delivery|cash_settlement|netting`',
    `settlement_status` STRING COMMENT 'Tracks the settlement progress of both legs of the FX swap through the custody platform.. Valid values are `pending|near_leg_settled|far_leg_settled|fully_settled|failed`',
    `swap_points` DECIMAL(12,8) COMMENT 'The difference between the far leg and near leg exchange rates, representing the interest rate differential between the two currencies over the swap tenor.',
    `swap_reference_number` STRING COMMENT 'External business identifier for the FX swap contract, used for operational reference and reconciliation with counterparties and custody platforms.',
    `swap_status` STRING COMMENT 'Current lifecycle status of the FX swap transaction in the trade execution and settlement workflow.. Valid values are `pending|confirmed|settled|cancelled|failed`',
    `swap_type` STRING COMMENT 'Classification of the FX swap purpose: hedge roll extends existing FX forward hedges, liquidity management addresses short-term currency needs, collateral adjustment manages margin requirements, tactical positioning captures opportunistic currency views.. Valid values are `hedge_roll|liquidity_management|collateral_adjustment|tactical_positioning`',
    `trade_date` DATE COMMENT 'The date on which the FX swap transaction was executed and agreed between counterparties.',
    `trade_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the FX swap was executed, capturing time-of-day for regulatory reporting and audit trail purposes.',
    `trading_desk` STRING COMMENT 'The internal trading desk or business unit responsible for executing and managing this FX swap (e.g., Treasury Desk, Currency Overlay Team).',
    `unique_transaction_identifier` STRING COMMENT 'Globally unique identifier assigned to this FX swap for regulatory trade reporting under EMIR and MiFID II, ensuring consistent cross-border identification.',
    CONSTRAINT pk_fx_swap PRIMARY KEY(`fx_swap_id`)
) COMMENT 'Transactional record for FX swap contracts used to roll FX forward hedges or manage short-term currency liquidity needs. Captures near leg and far leg details (dates, rates, notionals), currency pair, counterparty, ISDA agreement reference, purpose (hedge';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`hedge_program` (
    `hedge_program_id` BIGINT COMMENT 'Unique identifier for the foreign exchange (FX) hedging program. Primary key.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: FX hedge programs require scenario analysis for effectiveness testing and stress testing (hedge_program.stress_test_scenario exists).',
    `employee_id` BIGINT COMMENT 'Identifier of the treasury or investment committee member who approved the establishment or modification of this hedging program.',
    `esg_policy_id` BIGINT COMMENT 'Foreign key linking to esg.policy. Business justification: Pension funds must demonstrate ESG-aligned hedging per SFDR/PRI requirements. Links hedge programs to governing ESG policy for compliance reporting and audit trail.',
    `ldi_strategy_id` BIGINT COMMENT 'Foreign key linking to actuarial.ldi_strategy. Business justification: Treasury hedge programs (FX, interest rate) must align with actuarial LDI strategy defining hedge_ratio_target and duration_target_years.',
    `var_limit_id` BIGINT COMMENT 'Foreign key linking to risk.limit. Business justification: Hedge programs operate within VaR and DV01 risk limits. Business process: Hedge program compliance monitoring requires checking program exposures against approved risk limits for governance and',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the hedging program was formally approved by the investment committee or treasury governance body.',
    `base_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code representing the funds reporting currency (typically USD).. Valid values are `^[A-Z]{3}$`',
    `benchmark_rate` DECIMAL(18,2) COMMENT 'Reference interest rate used for pricing hedging instruments (e.g., SOFR, CORRA, EURIBOR, SONIA).',
    `collateral_posting_threshold_amount` DECIMAL(18,2) COMMENT 'Minimum mark-to-market (MTM) exposure amount that triggers collateral posting under Credit Support Annex (CSA) agreements.',
    `counterparty_concentration_limit_percent` DECIMAL(5,2) COMMENT 'Maximum percentage of total hedge notional that can be allocated to a single counterparty, enforcing diversification.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this hedge program record was first created in the data platform.',
    `effectiveness_test_frequency` STRING COMMENT 'Frequency at which hedge effectiveness testing is performed for accounting and compliance purposes.. Valid values are `daily|weekly|monthly|quarterly`',
    `esg_alignment_flag` BOOLEAN COMMENT 'Indicates whether the hedging program incorporates ESG considerations or aligns with responsible investment principles.',
    `hedge_accounting_treatment` STRING COMMENT 'Accounting classification under IFRS 9 or equivalent standard for hedge effectiveness and financial reporting.. Valid values are `cash_flow_hedge|fair_value_hedge|net_investment_hedge|no_hedge_accounting`',
    `hedge_effectiveness_test_method` STRING COMMENT 'Methodology used to assess whether the hedging relationship qualifies for hedge accounting under IFRS 9.. Valid values are `dollar_offset|regression_analysis|variance_reduction|qualitative`',
    `hedged_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code representing the foreign currency exposure being hedged.. Valid values are `^[A-Z]{3}$`',
    `last_effectiveness_test_date` DATE COMMENT 'Most recent date on which hedge effectiveness testing was performed for accounting compliance.',
    `last_effectiveness_test_result` STRING COMMENT 'Outcome of the most recent hedge effectiveness test, determining continued eligibility for hedge accounting treatment.. Valid values are `highly_effective|effective|ineffective|not_tested`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'System timestamp when this hedge program record was last updated in the data platform.',
    `last_rebalance_date` DATE COMMENT 'Most recent date on which the hedge ratio was rebalanced to align with target parameters.',
    `maximum_hedge_ratio_percent` DECIMAL(5,2) COMMENT 'Upper bound of the permitted hedge ratio band. Triggers rebalancing if actual hedge ratio exceeds this threshold.',
    `maximum_time_to_maturity_days` BIGINT COMMENT 'Maximum tenor in days for hedging instruments under this program, limiting long-dated exposure and roll risk.',
    `minimum_hedge_ratio_percent` DECIMAL(5,2) COMMENT 'Lower bound of the permitted hedge ratio band. Triggers rebalancing if actual hedge ratio falls below this threshold.',
    `minimum_time_to_maturity_days` BIGINT COMMENT 'Minimum tenor in days for hedging instruments under this program, ensuring alignment with liquidity and funding horizons.',
    `next_scheduled_rebalance_date` DATE COMMENT 'Next scheduled date for reviewing and potentially rebalancing the hedge ratio.',
    `notes` STRING COMMENT 'Free-text field for additional context, special instructions, or operational notes related to the hedging program.',
    `permitted_instruments` STRING COMMENT 'Comma-separated list of derivative instruments permitted under this program (e.g., FX forwards, FX swaps, currency options, cross-currency swaps).',
    `program_inception_date` DATE COMMENT 'Date on which the hedging program was first established and became operational.',
    `program_name` STRING COMMENT 'Descriptive name of the hedging program, identifying the currency exposure or asset class being hedged.',
    `program_objective` STRING COMMENT 'Strategic objective of the hedging program, such as reducing currency volatility, protecting NAV, or stabilizing cash flows.',
    `program_reference_code` STRING COMMENT 'Business-facing unique reference code for the hedging program, typically formatted as HP-{CURRENCY}-{YEAR}.. Valid values are `^HP-[A-Z]{3}-[0-9]{4}$`',
    `program_status` STRING COMMENT 'Current lifecycle status of the hedging program.. Valid values are `active|suspended|terminated|pending_approval|under_review`',
    `program_termination_date` DATE COMMENT 'Date on which the hedging program was formally terminated or is scheduled to terminate. Null for active programs.',
    `program_type` STRING COMMENT 'Classification of the hedging program by the type of exposure being managed.. Valid values are `currency_hedge|interest_rate_hedge|commodity_hedge|multi_asset_hedge`',
    `rebalancing_frequency` STRING COMMENT 'Scheduled frequency for reviewing and rebalancing the hedge ratio to maintain alignment with target parameters.. Valid values are `daily|weekly|monthly|quarterly|event_driven`',
    `rebalancing_trigger_threshold_bps` BIGINT COMMENT 'Deviation threshold in basis points from the target hedge ratio that triggers a rebalancing action.',
    `regulatory_reporting_requirement` STRING COMMENT 'Applicable regulatory reporting obligations for this hedging program (e.g., EMIR trade reporting, MiFID II transaction reporting).',
    `risk_limit_var_amount` DECIMAL(18,2) COMMENT 'Maximum Value at Risk (VaR) permitted for the hedging program, expressed in base currency, as a risk management constraint.',
    `roll_strategy` STRING COMMENT 'Strategy for rolling maturing hedge positions into new contracts to maintain continuous hedge coverage.. Valid values are `passive_roll|active_roll|dynamic_roll|laddered`',
    `stress_test_scenario` STRING COMMENT 'Description of the macroeconomic or market stress scenario applied to test the resilience of the hedging program.',
    `target_hedge_ratio_percent` DECIMAL(5,2) COMMENT 'Strategic target hedge ratio expressed as a percentage of the total foreign currency exposure (e.g., 50.00 means 50% of exposure is hedged).',
    `var_confidence_level_percent` DECIMAL(5,2) COMMENT 'Statistical confidence level used for VaR calculation (e.g., 95.00 or 99.00 percent).',
    `var_time_horizon_days` BIGINT COMMENT 'Time horizon in days over which VaR is calculated for risk monitoring (commonly 1 or 10 days).',
    CONSTRAINT pk_hedge_program PRIMARY KEY(`hedge_program_id`)
) COMMENT 'Master record defining the FX hedging program parameters for each currency or asset class exposure. Captures target hedge ratio, permitted hedge ratio band (min/max), hedging instruments allowed (forwards, swaps, options), rebalancing trigger thresholds';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`hedge_effectiveness` (
    `hedge_effectiveness_id` BIGINT COMMENT 'Unique identifier for the hedge effectiveness assessment record.',
    `approved_by_user_employee_id` BIGINT COMMENT 'Reference to the finance or risk committee member who approved the hedge effectiveness assessment.',
    `employee_id` BIGINT COMMENT 'Reference to the treasury or risk management user who prepared the hedge effectiveness assessment.',
    `hedge_program_id` BIGINT COMMENT 'Reference to the overarching hedge program or strategy under which this effectiveness assessment is performed.',
    `hedging_instrument_id` BIGINT COMMENT 'Reference to the derivative or financial instrument used as the hedging instrument in this hedge relationship.',
    `ldi_strategy_id` BIGINT COMMENT 'Foreign key linking to actuarial.ldi_strategy. Business justification: IFRS 9/ASC 815 hedge accounting requires documenting the hedged item. For pension funds, the hedged item is liabilities per LDI strategy.',
    `reviewed_by_user_employee_id` BIGINT COMMENT 'Reference to the senior treasury or finance user who reviewed the hedge effectiveness assessment.',
    `valuation_cycle_id` BIGINT COMMENT 'Foreign key linking to valuation.cycle. Business justification: Hedge effectiveness testing must align with valuation cycles for hedge accounting compliance. Pension funds assess hedge effectiveness at each valuation date per IFRS 9/ASC 815 requirements.',
    `approval_timestamp` TIMESTAMP COMMENT 'The date and time when the hedge effectiveness assessment was formally approved.',
    `assessment_date` DATE COMMENT 'The date on which the hedge effectiveness assessment was performed.',
    `assessment_methodology_description` STRING COMMENT 'Detailed narrative describing the specific methodology, assumptions, and data sources used to perform the hedge effectiveness assessment.',
    `assessment_period_end_date` DATE COMMENT 'The end date of the period covered by this hedge effectiveness assessment.',
    `assessment_period_start_date` DATE COMMENT 'The start date of the period covered by this hedge effectiveness assessment.',
    `assessment_reference_number` STRING COMMENT 'Business identifier for the hedge effectiveness assessment, used for external reporting and audit trails.',
    `assessment_status` STRING COMMENT 'Current lifecycle status of the hedge effectiveness assessment record.. Valid values are `draft|submitted|approved|rejected|superseded`',
    `assessment_type` STRING COMMENT 'Type of hedge effectiveness assessment: prospective (forward-looking), retrospective (historical), or combined.. Valid values are `prospective|retrospective|combined`',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this hedge effectiveness assessment record was first created in the system.',
    `critical_terms_match_flag` BOOLEAN COMMENT 'Indicates whether the critical terms of the hedging instrument and hedged item match, supporting a qualitative assessment of effectiveness.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts in this assessment.. Valid values are `^[A-Z]{3}$`',
    `discontinuation_date` DATE COMMENT 'The date on which hedge accounting was discontinued for this hedge relationship, if applicable.',
    `discontinuation_flag` BOOLEAN COMMENT 'Indicates whether hedge accounting has been discontinued for this hedge relationship.',
    `discontinuation_reason` STRING COMMENT 'Business explanation for why hedge accounting was discontinued, such as failure to meet effectiveness criteria or hedge objective no longer valid.',
    `dollar_offset_ratio` DECIMAL(10,4) COMMENT 'The ratio of cumulative change in fair value of the hedging instrument to cumulative change in fair value of the hedged item, used in dollar-offset method.',
    `effectiveness_ratio` DECIMAL(10,4) COMMENT 'Quantitative ratio measuring the degree of offset between changes in fair value or cash flows of the hedging instrument and the hedged item, typically expressed as a percentage.',
    `external_auditor_reviewed_flag` BOOLEAN COMMENT 'Indicates whether this hedge effectiveness assessment has been reviewed by external auditors as part of financial statement audit.',
    `hedge_accounting_model` STRING COMMENT 'The type of hedge accounting model applied under IFRS 9: fair value hedge, cash flow hedge, or net investment hedge.. Valid values are `fair_value_hedge|cash_flow_hedge|net_investment_hedge`',
    `hedge_ratio` DECIMAL(10,4) COMMENT 'The ratio of the quantity of hedging instrument to the quantity of hedged item, used to determine the hedge relationship structure.',
    `hedge_relationship_designation_date` DATE COMMENT 'The date on which the hedge relationship was formally designated for hedge accounting purposes.',
    `hedged_item_fair_value_change_amount` DECIMAL(18,2) COMMENT 'The change in fair value of the hedged item during the assessment period, used to calculate effectiveness.',
    `hedged_item_reference` BIGINT COMMENT 'Reference to the asset, liability, or forecasted transaction that is being hedged.',
    `hedged_item_type` STRING COMMENT 'Classification of the risk exposure being hedged in this hedge relationship.. Valid values are `fx_exposure|interest_rate_exposure|commodity_exposure|equity_exposure|credit_exposure|other`',
    `hedging_instrument_fair_value_change_amount` DECIMAL(18,2) COMMENT 'The change in fair value of the hedging instrument during the assessment period, used to calculate effectiveness.',
    `hedging_instrument_type` STRING COMMENT 'Classification of the hedging instrument used in the hedge relationship.. Valid values are `fx_forward|fx_swap|fx_option|interest_rate_swap|cross_currency_swap|other`',
    `ineffectiveness_amount` DECIMAL(18,2) COMMENT 'The portion of the hedge that is deemed ineffective and must be recognized immediately in profit or loss under IFRS 9.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The date and time when this hedge effectiveness assessment record was last updated.',
    `next_assessment_due_date` DATE COMMENT 'The scheduled date for the next periodic hedge effectiveness assessment, typically quarterly or as required by policy.',
    `notes` STRING COMMENT 'Free-text field for additional commentary, observations, or qualitative factors relevant to the hedge effectiveness assessment.',
    `prospective_effectiveness_result` STRING COMMENT 'Outcome of the prospective hedge effectiveness test indicating whether the hedge is expected to be highly effective.. Valid values are `highly_effective|not_highly_effective|not_assessed`',
    `prospective_test_method` STRING COMMENT 'The quantitative or qualitative method used to assess prospective hedge effectiveness.. Valid values are `regression_analysis|dollar_offset|scenario_analysis|var_reduction|qualitative`',
    `rebalancing_date` DATE COMMENT 'The date on which the hedge relationship was rebalanced to restore effectiveness, if applicable.',
    `rebalancing_required_flag` BOOLEAN COMMENT 'Indicates whether the hedge relationship requires rebalancing to maintain hedge effectiveness under IFRS 9.',
    `regression_r_squared` DECIMAL(10,6) COMMENT 'The coefficient of determination from regression analysis, measuring the proportion of variance in the hedged item explained by the hedging instrument.',
    `regression_slope` DECIMAL(10,6) COMMENT 'The slope coefficient from regression analysis, indicating the sensitivity of the hedged item to changes in the hedging instrument.',
    `retrospective_effectiveness_result` STRING COMMENT 'Outcome of the retrospective hedge effectiveness test indicating whether the hedge was highly effective during the assessment period.. Valid values are `highly_effective|not_highly_effective|not_assessed`',
    `retrospective_test_method` STRING COMMENT 'The quantitative or qualitative method used to assess retrospective hedge effectiveness.. Valid values are `regression_analysis|dollar_offset|cumulative_dollar_offset|variance_reduction|qualitative`',
    CONSTRAINT pk_hedge_effectiveness PRIMARY KEY(`hedge_effectiveness_id`)
) COMMENT 'Periodic assessment records of FX hedge effectiveness under IFRS 9 hedge accounting requirements. Captures assessment date, hedge program reference, hedging instrument, hedged item, prospective effectiveness test method (regression, dollar-offset)';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`short_term_instrument` (
    `short_term_instrument_id` BIGINT COMMENT 'Unique identifier for the short-term liquidity instrument record.',
    `approval_user_employee_id` BIGINT COMMENT 'Identifier of the user who approved the investment in the short-term instrument.',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: Money market instruments (CP, CDs, repos) require counterparty tracking for credit risk limits and concentration monitoring.',
    `employee_id` BIGINT COMMENT 'Identifier of the treasury trader or portfolio manager who executed the purchase of the instrument.',
    `issuer_esg_rating_id` BIGINT COMMENT 'Foreign key linking to esg.issuer_esg_rating. Business justification: Pension funds screen ALL investments for ESG including money market/liquidity instruments.',
    `accrued_interest_amount` DECIMAL(18,2) COMMENT 'Interest earned but not yet paid on the instrument since the last coupon payment or purchase date.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the investment was approved by the authorized approver.',
    `benchmark_rate_type` STRING COMMENT 'Reference rate or benchmark to which the instrument yield is linked, such as SOFR or fixed rate.. Valid values are `sofr|libor|euribor|sonia|fixed`',
    `bloomberg_ticker` STRING COMMENT 'Bloomberg ticker symbol used for market data retrieval and pricing.',
    `collateral_flag` BOOLEAN COMMENT 'Indicates whether the instrument is pledged as collateral for derivatives or other obligations.',
    `coupon_rate_percent` DECIMAL(8,5) COMMENT 'Annual interest rate paid by the instrument, expressed as a percentage of face value.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the short-term instrument record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code in which the instrument is denominated.. Valid values are `^[A-Z]{3}$`',
    `current_market_value_amount` DECIMAL(18,2) COMMENT 'Current mark-to-market valuation of the instrument based on latest pricing.',
    `cusip` STRING COMMENT 'CUSIP identifier for North American securities, used for trade settlement and custody.. Valid values are `^[0-9]{3}[0-9A-Z]{5}[0-9]$`',
    `custodian_account_number` STRING COMMENT 'Account number at the custodian where the instrument is held.',
    `custodian_name` STRING COMMENT 'Name of the custodian bank or institution holding the instrument on behalf of the pension fund.',
    `days_to_maturity` BIGINT COMMENT 'Number of calendar days remaining until the instrument reaches maturity.',
    `discount_rate_percent` DECIMAL(8,5) COMMENT 'Rate at which the instrument was purchased at a discount to face value, applicable to discount instruments like T-Bills.',
    `esg_compliant_flag` BOOLEAN COMMENT 'Indicates whether the instrument meets the pension fund ESG investment criteria and responsible investment standards.',
    `face_value_amount` DECIMAL(18,2) COMMENT 'Par or face value of the instrument that will be repaid at maturity.',
    `instrument_credit_rating` STRING COMMENT 'Specific credit rating assigned to this instrument issuance by rating agencies.',
    `instrument_reference_number` STRING COMMENT 'External business identifier or reference number assigned to the short-term instrument by the treasury system or custodian.',
    `instrument_status` STRING COMMENT 'Current lifecycle status of the short-term instrument position.. Valid values are `active|matured|sold|cancelled|pending_settlement`',
    `instrument_type` STRING COMMENT 'Classification of the short-term liquidity instrument held in the treasury portfolio. [ENUM-REF-CANDIDATE: t_bill|commercial_paper|bankers_acceptance|money_market_fund|sofr_linked|repo|reverse_repo — 7 candidates stripped; promote to reference product]',
    `isin` STRING COMMENT 'International Securities Identification Number uniquely identifying the instrument globally.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `issue_date` DATE COMMENT 'Original date on which the instrument was issued by the issuer.',
    `issuer_credit_rating` STRING COMMENT 'Credit rating assigned to the issuer by major rating agencies, indicating creditworthiness.',
    `issuer_lei` STRING COMMENT 'Legal Entity Identifier of the issuer for regulatory reporting and counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `issuer_name` STRING COMMENT 'Legal name of the entity that issued the short-term instrument.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when the short-term instrument record was last updated.',
    `liquidity_tier` STRING COMMENT 'Classification of the instrument based on its liquidity profile and ease of conversion to cash.. Valid values are `tier_1|tier_2|tier_3`',
    `maturity_date` DATE COMMENT 'Date on which the instrument matures and principal is repaid to the holder.',
    `notes` STRING COMMENT 'Free-text field for additional comments, special instructions, or contextual information about the instrument.',
    `portfolio_allocation_strategy` STRING COMMENT 'Strategic purpose for holding this instrument within the treasury portfolio.. Valid values are `liquidity_reserve|cash_management|collateral_buffer|yield_enhancement`',
    `purchase_date` DATE COMMENT 'Date on which the short-term instrument was acquired by the treasury portfolio.',
    `purchase_price_amount` DECIMAL(18,2) COMMENT 'Total amount paid to acquire the instrument, including any premium or discount.',
    `quantity` DECIMAL(18,4) COMMENT 'Number of units or shares of the instrument held in the portfolio.',
    `sedol` STRING COMMENT 'SEDOL code for securities traded on London Stock Exchange and other UK markets.. Valid values are `^[0-9BCDFGHJKLMNPQRSTVWXYZ]{7}$`',
    `settlement_date` DATE COMMENT 'Date on which the purchase transaction settled and cash was exchanged for the instrument.',
    `spread_over_benchmark_bps` BIGINT COMMENT 'Additional yield spread over the benchmark rate, expressed in basis points.',
    `trade_reference_number` STRING COMMENT 'Unique reference number assigned to the original purchase trade by the order management system.',
    `unrealized_gain_loss_amount` DECIMAL(18,2) COMMENT 'Difference between current market value and purchase price, representing unrealized profit or loss.',
    `valuation_date` DATE COMMENT 'Date on which the current market value and accrued interest were last calculated.',
    `valuation_source` STRING COMMENT 'Source system or vendor providing the market valuation for the instrument, such as Bloomberg or custodian pricing.',
    `yield_to_maturity_percent` DECIMAL(8,5) COMMENT 'Annualized rate of return if the instrument is held to maturity, accounting for purchase price and coupon payments.',
    CONSTRAINT pk_short_term_instrument PRIMARY KEY(`short_term_instrument_id`)
) COMMENT 'Master record for short-term liquidity instruments held in the treasury portfolio including T-Bills, SOFR-linked instruments, commercial paper, bankers acceptances, and money market fund units.';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`st_instrument_transaction` (
    `st_instrument_transaction_id` BIGINT COMMENT 'Unique identifier for the short-term instrument transaction record.',
    `approved_by_user_employee_id` BIGINT COMMENT 'Identifier of the user who approved the transaction for execution, if pre-approval is required.',
    `broker_id` BIGINT COMMENT 'Foreign key linking to trade.broker. Business justification: Money market transactions (T-bills, CP, repo) execute through approved brokers. Treasury teams track broker relationships for best execution analysis and counterparty concentration monitoring.',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: Short-term instrument transactions require counterparty identification for settlement risk management and credit exposure tracking.',
    `employee_id` BIGINT COMMENT 'Identifier of the trader or portfolio manager who executed the transaction.',
    `short_term_instrument_id` BIGINT COMMENT 'Foreign key linking to treasury.short_term_instrument. Business justification: Transactions for short-term instruments should FK to the instrument master. Removes redundant instrument_identifier and instrument_type which can be retrieved via JOIN.',
    `accrued_interest_amount` DECIMAL(18,2) COMMENT 'Interest accrued on the instrument from the last coupon payment date to the trade date, paid by the buyer to the seller.',
    `actual_settlement_date` DATE COMMENT 'Actual date on which the transaction settled, may differ from scheduled settlement date due to operational factors.',
    `booking_timestamp` TIMESTAMP COMMENT 'Date and time when the transaction was booked into the investment book of record.',
    `confirmation_timestamp` TIMESTAMP COMMENT 'Date and time when the transaction was confirmed by the counterparty or custodian.',
    `consideration_amount` DECIMAL(18,2) COMMENT 'Total cash amount paid or received for the transaction, excluding fees and accrued interest.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this transaction record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the transaction is denominated.. Valid values are `^[A-Z]{3}$`',
    `cusip` STRING COMMENT 'Nine-character alphanumeric code identifying the security in North American markets.. Valid values are `^[0-9]{3}[0-9A-Z]{5}[0-9]$`',
    `custodian_account_number` STRING COMMENT 'Account number at the custodian bank where the securities are held and settled.',
    `custodian_name` STRING COMMENT 'Name of the custodian bank holding the securities and processing settlement.',
    `days_to_maturity` BIGINT COMMENT 'Number of calendar days from trade date to maturity date.',
    `discount_rate_percent` DECIMAL(8,4) COMMENT 'Discount rate applied to the face value for discount instruments such as Treasury Bills, expressed as a percentage.',
    `external_transaction_reference` STRING COMMENT 'Transaction identifier assigned by the external counterparty, broker, or custodian system for reconciliation purposes.',
    `face_value_amount` DECIMAL(18,2) COMMENT 'Par or nominal value of the short-term instrument at issuance or maturity.',
    `isin` STRING COMMENT 'Twelve-character alphanumeric code uniquely identifying the security globally.. Valid values are `^[A-Z]{2}[0-9A-Z]{9}[0-9]$`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this transaction record was last updated or modified.',
    `maturity_date` DATE COMMENT 'Date on which the short-term instrument matures and principal is repaid.',
    `net_settlement_amount` DECIMAL(18,2) COMMENT 'Total net cash amount to be settled, including consideration, accrued interest, and fees.',
    `notes` STRING COMMENT 'Free-text notes or comments providing additional context or operational details about the transaction.',
    `portfolio_code` STRING COMMENT 'Internal code identifying the investment portfolio or fund to which this transaction is allocated.',
    `quantity` DECIMAL(18,4) COMMENT 'Number of units or nominal amount of the instrument transacted.',
    `settlement_date` DATE COMMENT 'Date on which the transaction is scheduled to settle and cash and securities are exchanged.',
    `settlement_location` STRING COMMENT 'Name of the central securities depository or settlement system where the transaction settles.',
    `settlement_method` STRING COMMENT 'Method of settlement: Delivery Versus Payment, Free of Payment, or Receive Versus Payment.. Valid values are `dvp|fop|rvp`',
    `strategy_code` STRING COMMENT 'Code identifying the investment strategy or mandate under which this transaction was executed.',
    `trade_date` DATE COMMENT 'Date on which the transaction was executed or agreed upon.',
    `transaction_fee_amount` DECIMAL(18,2) COMMENT 'Fees charged by brokers, custodians, or intermediaries for executing and settling the transaction.',
    `transaction_reference_number` STRING COMMENT 'Externally-known unique reference number assigned to this short-term instrument transaction for operational tracking and reconciliation.',
    `transaction_status` STRING COMMENT 'Current lifecycle status of the transaction in the settlement workflow.. Valid values are `pending|confirmed|settled|cancelled|failed`',
    `transaction_type` STRING COMMENT 'Type of transaction executed on the short-term instrument: purchase, sale, maturity, rollover, redemption, or interest payment.. Valid values are `purchase|sale|maturity|rollover|redemption|interest_payment`',
    `unit_price` DECIMAL(18,6) COMMENT 'Price per unit of the instrument at which the transaction was executed.',
    `yield_to_maturity_percent` DECIMAL(8,4) COMMENT 'Annualized yield to maturity of the instrument at the time of transaction, expressed as a percentage.',
    CONSTRAINT pk_st_instrument_transaction PRIMARY KEY(`st_instrument_transaction_id`)
) COMMENT 'Transactional records for purchases, maturities, sales, and rollovers of short-term liquidity instruments (T-Bills, SOFR-linked, commercial paper). Captures transaction type, trade date, settlement date, instrument reference, face value, consideration';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`cash_transfer` (
    `cash_transfer_id` BIGINT COMMENT 'Unique identifier for the cash transfer transaction.',
    `capital_call_funding_id` BIGINT COMMENT 'Foreign key linking to treasury.capital_call_funding. Business justification: Cash transfers funding capital calls should link to the capital_call_funding workflow record.',
    `counterparty_id` BIGINT COMMENT 'Identifier of the external counterparty involved in the transfer, such as a fund manager, broker, or beneficiary.',
    `destination_account_cash_account_id` BIGINT COMMENT 'Identifier of the cash account to which funds are being transferred.',
    `destination_custodian_id` BIGINT COMMENT 'Identifier of the custodian or banking institution holding the destination account.',
    `distribution_receipt_id` BIGINT COMMENT 'Foreign key linking to treasury.distribution_receipt. Business justification: Cash transfers receiving distributions should link to the distribution_receipt record.',
    `employee_id` BIGINT COMMENT 'Identifier of the treasury user who approved the transfer for execution.',
    `fx_forward_id` BIGINT COMMENT 'Foreign key linking to treasury.fx_forward. Business justification: Cash transfers settling FX forwards should link to the forward contract being settled.',
    `fx_swap_id` BIGINT COMMENT 'Foreign key linking to treasury.fx_swap. Business justification: Cash transfers settling FX swaps should link to the swap contract being settled.',
    `initiated_by_user_employee_id` BIGINT COMMENT 'Identifier of the treasury user who initiated the cash transfer request.',
    `margin_call_id` BIGINT COMMENT 'Foreign key linking to collateral.margin_call. Business justification: Cash transfers are initiated to satisfy margin calls under CSA agreements. Direct linkage enables audit trail from margin call to funding execution, essential for collateral operations',
    `pe_investment_id` BIGINT COMMENT 'Identifier of the investment transaction that triggered this cash transfer, such as a capital call or distribution.',
    `primary_cash_account_id` BIGINT COMMENT 'Identifier of the cash account from which funds are being transferred.',
    `related_fx_hedge_hedge_program_id` BIGINT COMMENT 'Identifier of the FX forward or swap position being settled through this cash transfer.',
    `related_trade_blotter_id` BIGINT COMMENT 'Identifier of the trade execution that requires this cash transfer for settlement purposes.',
    `reversed_transfer_cash_transfer_id` BIGINT COMMENT 'Identifier of the original cash transfer that this transfer reverses.',
    `source_custodian_id` BIGINT COMMENT 'Identifier of the custodian or banking institution holding the source account.',
    `standing_settlement_instruction_id` BIGINT COMMENT 'Foreign key linking to trade.standing_settlement_instruction. Business justification: Cash transfers require SSIs for payment routing instructions. Operations teams use SSIs to ensure correct beneficiary details, correspondent banks, and settlement',
    `treasury_fx_rate_id` BIGINT COMMENT 'Foreign key linking to treasury.treasury_fx_rate. Business justification: Cash transfer FX rates should reference treasury_fx_rate for rate source traceability.',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether the transfer requires explicit approval before execution based on amount thresholds or transfer type.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the transfer was approved by the authorized treasury user.',
    `counterparty_lei` STRING COMMENT '20-character Legal Entity Identifier of the counterparty as per ISO 17442 standard.. Valid values are `^[A-Z0-9]{20}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the cash transfer record was first created in the system.',
    `destination_account_number` STRING COMMENT 'External account number of the destination cash account as maintained by the custodian or banking institution.',
    `destination_currency_code` STRING COMMENT 'Three-letter ISO currency code of the destination account for FX transfers.. Valid values are `^[A-Z]{3}$`',
    `failure_reason` STRING COMMENT 'Detailed explanation of why the transfer failed, including error codes and messages from the payment system.',
    `fee_amount` DECIMAL(18,2) COMMENT 'Total fees charged for executing the cash transfer, including wire fees, custodian fees, and intermediary bank charges.',
    `fx_rate` DECIMAL(18,8) COMMENT 'Exchange rate applied if the transfer involves currency conversion between source and destination accounts.',
    `initiation_timestamp` TIMESTAMP COMMENT 'Date and time when the cash transfer was initiated by treasury operations.',
    `intermediary_bank_bic` STRING COMMENT 'SWIFT Bank Identifier Code of any intermediary bank involved in routing the transfer.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `intermediary_bank_name` STRING COMMENT 'Name of the intermediary bank used for routing the transfer between source and destination institutions.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when the cash transfer record was last updated in the system.',
    `net_transfer_amount` DECIMAL(18,2) COMMENT 'Net monetary amount transferred after deducting all fees and adjustments.',
    `notes` STRING COMMENT 'Additional free-text notes or comments recorded by treasury operations regarding the transfer.',
    `payment_channel` STRING COMMENT 'System or interface through which the transfer was initiated: custody platform, treasury workstation, banking portal, or manual entry.. Valid values are `custody_platform|treasury_workstation|banking_portal|manual`',
    `payment_method` STRING COMMENT 'Payment instrument used to execute the transfer: wire transfer, ACH, SWIFT, SEPA, internal book transfer, or check.. Valid values are `wire|ach|swift|sepa|internal_book|check`',
    `priority_level` STRING COMMENT 'Processing priority assigned to the transfer: standard, urgent, same-day, or next-day settlement.. Valid values are `standard|urgent|same_day|next_day`',
    `purpose_description` STRING COMMENT 'Detailed business purpose or reason for the cash transfer, such as capital call funding for Fund XYZ or distribution receipt from ABC Investment.',
    `remittance_information` STRING COMMENT 'Unstructured payment reference information provided to the beneficiary for reconciliation purposes.',
    `reversal_reason` STRING COMMENT 'Business justification for reversing a previously settled transfer, such as erroneous payment or counterparty request.',
    `settlement_confirmation_number` STRING COMMENT 'Confirmation reference number provided by the custodian or banking institution upon successful settlement.',
    `settlement_date` DATE COMMENT 'Actual date when the cash transfer settled and funds were exchanged between accounts.',
    `source_account_number` STRING COMMENT 'External account number of the source cash account as maintained by the custodian or banking institution.',
    `source_currency_code` STRING COMMENT 'Three-letter ISO currency code of the source account for FX transfers.. Valid values are `^[A-Z]{3}$`',
    `transfer_amount` DECIMAL(18,2) COMMENT 'Gross monetary amount being transferred before any fees or adjustments.',
    `transfer_currency_code` STRING COMMENT 'Three-letter ISO currency code of the transfer amount (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `transfer_reference_number` STRING COMMENT 'Externally-known unique reference number assigned to this cash transfer for tracking and reconciliation purposes.',
    `transfer_status` STRING COMMENT 'Current lifecycle status of the cash transfer: initiated, pending approval, approved, in transit, settled, failed, cancelled, or reversed. [ENUM-REF-CANDIDATE: initiated|pending_approval|approved|in_transit|settled|failed|cancelled|reversed — 8 candidates',
    `transfer_type` STRING COMMENT 'Classification of the cash transfer by business purpose: internal sweep, custodian-to-custodian transfer, capital call wire payment, distribution receipt, FX settlement, collateral movement, fee payment, or contribution receipt.',
    `value_date` DATE COMMENT 'Effective date when the cash transfer is valued and impacts cash positions for accounting and liquidity purposes.',
    CONSTRAINT pk_cash_transfer PRIMARY KEY(`cash_transfer_id`)
) COMMENT 'Operational record for each internal and external cash movement initiated by treasury, including inter-account and overnight/threshold-triggered sweeps, custodian-to-custodian transfers, capital call wire payments, distribution receipts, and FX settlement';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`cash_reconciliation` (
    `cash_reconciliation_id` BIGINT COMMENT 'Unique identifier for the cash reconciliation record.',
    `approved_by_user_employee_id` BIGINT COMMENT 'Reference to the treasury manager or controller who approved the reconciliation and any adjustments.',
    `cash_account_id` BIGINT COMMENT 'Reference to the cash account being reconciled.',
    `cash_position_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_position. Business justification: Cash reconciliation compares IBOR position to custodian. Links reconciliation to the specific cash position being reconciled.',
    `custodian_id` BIGINT COMMENT 'Reference to the custodian institution (State Street or Northern Trust) providing the cash balance report.',
    `employee_id` BIGINT COMMENT 'Reference to the treasury operations user who prepared or reviewed the reconciliation.',
    `reviewed_by_user_employee_id` BIGINT COMMENT 'Reference to the senior treasury user who performed secondary review of the reconciliation.',
    `valuation_cycle_id` BIGINT COMMENT 'Foreign key linking to valuation.cycle. Business justification: Cash reconciliations are mandatory before NAV finalization. Pension fund operations must complete cash reconciliation within each valuation cycle to ensure accurate NAV reporting to trustees.',
    `approval_timestamp` TIMESTAMP COMMENT 'Timestamp when the reconciliation was formally approved by authorized treasury management.',
    `auto_reconciled_flag` BOOLEAN COMMENT 'Indicates whether the reconciliation was automatically matched by system rules without manual intervention.',
    `closing_balance_variance_amount` DECIMAL(20,4) COMMENT 'Difference between IBOR and custodian closing balances (IBOR minus custodian).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the reconciliation record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the cash position being reconciled.. Valid values are `^[A-Z]{3}$`',
    `custodian_closing_balance_amount` DECIMAL(20,4) COMMENT 'Closing cash balance reported by custodian (State Street or Northern Trust) at end of reconciliation date.',
    `custodian_file_received_timestamp` TIMESTAMP COMMENT 'Timestamp when custodian cash position file was received and loaded into reconciliation system.',
    `custodian_opening_balance_amount` DECIMAL(20,4) COMMENT 'Opening cash balance reported by custodian (State Street or Northern Trust) at start of reconciliation date.',
    `custodian_statement_date` DATE COMMENT 'Date of the custodian statement used for reconciliation, may differ from reconciliation date due to reporting lag.',
    `custodian_statement_reference` STRING COMMENT 'Custodian-provided statement or report reference number used as source for custodian balances.',
    `custodian_transaction_count` BIGINT COMMENT 'Number of cash transactions reported by custodian for the reconciliation date.',
    `escalation_required_flag` BOOLEAN COMMENT 'Indicates whether the variance exceeds tolerance and requires escalation to senior treasury or finance management.',
    `fee_difference_amount` DECIMAL(20,4) COMMENT 'Variance attributed to custody fees, transaction fees, or other charges recorded differently.',
    `fx_revaluation_difference_amount` DECIMAL(20,4) COMMENT 'Variance attributed to foreign exchange revaluation methodology differences between IBOR and custodian.',
    `ibor_closing_balance_amount` DECIMAL(20,4) COMMENT 'Closing cash balance from internal IBOR system (SimCorp Dimension) at end of reconciliation date.',
    `ibor_extract_timestamp` TIMESTAMP COMMENT 'Timestamp when IBOR cash position data was extracted from SimCorp Dimension for reconciliation.',
    `ibor_opening_balance_amount` DECIMAL(20,4) COMMENT 'Opening cash balance from internal IBOR system (SimCorp Dimension) at start of reconciliation date.',
    `ibor_transaction_count` BIGINT COMMENT 'Number of cash transactions recorded in IBOR system for the reconciliation date.',
    `interest_accrual_difference_amount` DECIMAL(20,4) COMMENT 'Variance attributed to interest accrual calculation differences between IBOR and custodian.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the reconciliation record was last updated, reflecting status changes or adjustments.',
    `manual_adjustment_required_flag` BOOLEAN COMMENT 'Indicates whether manual journal entries or adjustments are required to resolve the variance.',
    `matched_transaction_amount` DECIMAL(20,4) COMMENT 'Total value of successfully matched transactions between IBOR and custodian.',
    `matched_transaction_count` BIGINT COMMENT 'Number of transactions successfully matched between IBOR and custodian records.',
    `opening_balance_variance_amount` DECIMAL(20,4) COMMENT 'Difference between IBOR and custodian opening balances (IBOR minus custodian).',
    `reconciliation_date` DATE COMMENT 'Business date for which the cash reconciliation is performed, typically the prior business day close.',
    `reconciliation_reference_number` STRING COMMENT 'Business identifier for the reconciliation record, typically system-generated or custodian-provided reference.',
    `reconciliation_run_timestamp` TIMESTAMP COMMENT 'Timestamp when the automated reconciliation matching process was executed.',
    `reconciliation_status` STRING COMMENT 'Current lifecycle status of the reconciliation record in the workflow. [ENUM-REF-CANDIDATE: pending|in_progress|matched|unmatched|partially_matched|approved|rejected|escalated — 8 candidates stripped; promote to reference product]',
    `reconciliation_type` STRING COMMENT 'Classification of the reconciliation by frequency and business purpose.. Valid values are `daily|intraday|month_end|quarter_end|year_end|ad_hoc`',
    `resolution_notes` STRING COMMENT 'Detailed explanation of variance causes, reconciling items identified, and resolution actions taken.',
    `settlement_difference_amount` DECIMAL(20,4) COMMENT 'Variance attributed to settlement timing or DVP processing differences.',
    `timing_difference_amount` DECIMAL(20,4) COMMENT 'Variance attributed to timing differences in transaction recording between IBOR and custodian systems.',
    `tolerance_threshold_amount` DECIMAL(20,4) COMMENT 'Maximum acceptable variance amount before escalation is required, defined by treasury policy.',
    `tolerance_threshold_bps` BIGINT COMMENT 'Maximum acceptable variance in basis points relative to account balance before escalation is required.',
    `unexplained_variance_amount` DECIMAL(20,4) COMMENT 'Remaining variance after all identified reconciling items have been accounted for.',
    `unmatched_custodian_transaction_amount` DECIMAL(20,4) COMMENT 'Total value of custodian transactions with no corresponding IBOR record.',
    `unmatched_custodian_transaction_count` BIGINT COMMENT 'Number of custodian transactions with no corresponding IBOR record.',
    `unmatched_ibor_transaction_amount` DECIMAL(20,4) COMMENT 'Total value of IBOR transactions with no corresponding custodian record.',
    `unmatched_ibor_transaction_count` BIGINT COMMENT 'Number of IBOR transactions with no corresponding custodian record.',
    `within_tolerance_flag` BOOLEAN COMMENT 'Indicates whether the reconciliation variance is within acceptable tolerance thresholds.',
    CONSTRAINT pk_cash_reconciliation PRIMARY KEY(`cash_reconciliation_id`)
) COMMENT 'Daily reconciliation records comparing internal IBOR cash positions (SimCorp Dimension) against custodian-reported cash balances (State Street / Northern Trust) by account and currency.';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`treasury_fx_rate` (
    `treasury_fx_rate_id` BIGINT COMMENT 'Unique identifier for the FX rate record. Primary key for the treasury FX rate reference data table.',
    `superseded_by_rate_treasury_fx_rate_id` BIGINT COMMENT 'Reference to the treasury FX rate record that supersedes this rate, enabling navigation through rate history and audit trail of rate changes.',
    `base_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code representing the base currency in the currency pair (e.g., USD in USD/JPY).. Valid values are `^[A-Z]{3}$`',
    `bid_ask_spread_bps` DECIMAL(10,4) COMMENT 'The difference between ask and bid rates expressed in basis points, representing the transaction cost and market liquidity for the currency pair.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this FX rate record was first created in the treasury system, supporting audit trail and data lineage tracking.',
    `cross_rate_flag` BOOLEAN COMMENT 'Boolean flag indicating whether this rate is a cross rate calculated from two USD pairs rather than a directly quoted market rate (e.g., EUR/JPY derived from EUR/USD and USD/JPY).',
    `currency_pair` STRING COMMENT 'Standard currency pair notation combining base and quote currencies (e.g., USD/JPY, EUR/USD) following market convention for FX trading and hedging.. Valid values are `^[A-Z]{3}/[A-Z]{3}$`',
    `effective_end_timestamp` TIMESTAMP COMMENT 'Timestamp until which this FX rate remains effective, after which it is superseded by a newer rate. Null for currently active rates, supporting temporal validity and rate history.',
    `effective_start_timestamp` TIMESTAMP COMMENT 'Timestamp from which this FX rate becomes effective for valuation and hedge accounting purposes, supporting temporal validity and historical rate reconstruction.',
    `fixing_time` TIMESTAMP COMMENT 'The standard market fixing time for this rate (e.g., 4:00 PM London, 10:00 AM New York), used for benchmark rate determination and hedge accounting compliance.',
    `forward_points_1m` DECIMAL(12,6) COMMENT 'Forward points for one-month tenor, used to calculate the one-month forward FX rate for hedging monthly cash flows, capital calls, and distributions.',
    `forward_points_1w` DECIMAL(12,6) COMMENT 'Forward points for one-week tenor, representing the interest rate differential between the two currencies. Added to spot rate to derive the one-week forward rate for hedging short-term FX exposure.',
    `forward_points_1y` DECIMAL(12,6) COMMENT 'Forward points for one-year tenor, used to calculate the one-year forward FX rate for hedging annual exposures and long-term strategic currency hedges.',
    `forward_points_3m` DECIMAL(12,6) COMMENT 'Forward points for three-month tenor, used to calculate the three-month forward FX rate for hedging quarterly exposures and medium-term currency risk.',
    `forward_points_6m` DECIMAL(12,6) COMMENT 'Forward points for six-month tenor, used to calculate the six-month forward FX rate for hedging semi-annual exposures and medium-term currency positions.',
    `inversion_flag` BOOLEAN COMMENT 'Boolean flag indicating whether this rate has been inverted from the source systems native quotation to match internal portfolio reporting convention (e.g., converting EUR/USD to USD/EUR).',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this FX rate record, supporting change tracking and audit trail for data corrections or restatements.',
    `market_convention` STRING COMMENT 'Indicates whether the rate follows direct quotation (domestic currency per unit of foreign currency) or indirect quotation (foreign currency per unit of domestic currency) convention.. Valid values are `direct|indirect`',
    `notes` STRING COMMENT 'Free-text field for additional context, explanations of unusual rate movements, data quality issues, or special handling instructions for this FX rate observation.',
    `published_timestamp` TIMESTAMP COMMENT 'Timestamp when the rate was officially published or made available by the source provider, used for audit trail and data lineage tracking.',
    `quote_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code representing the quote currency in the currency pair (e.g., JPY in USD/JPY).. Valid values are `^[A-Z]{3}$`',
    `rate_date` DATE COMMENT 'The business date for which this FX rate is effective. Used for valuation, hedge accounting, and settlement calculations.',
    `rate_quality_flag` BOOLEAN COMMENT 'Data quality indicator for the FX rate: verified for confirmed rates, unverified for preliminary rates, estimated for interpolated or calculated rates, or stale for rates exceeding freshness threshold.',
    `rate_reference_code` STRING COMMENT 'Unique business identifier for this FX rate observation, typically combining currency pair, rate date, and source identifier for external reference and reconciliation.',
    `rate_source` STRING COMMENT 'The external data provider or central bank that published this FX rate (e.g., Bloomberg, Reuters, European Central Bank, Bank of Canada, Federal Reserve, or custom internal calculation).. Valid values are `bloomberg|reuters|ecb|boc|fed|custom`',
    `rate_source_identifier` STRING COMMENT 'The unique identifier or ticker symbol used by the source system to reference this FX rate (e.g., Bloomberg ticker USDCAD Curncy), enabling traceability and reconciliation.',
    `rate_status` STRING COMMENT 'Current status of the FX rate record: active for current use, superseded by a later rate, preliminary for initial publication, final for confirmed rate, or restated for corrected historical rate.. Valid values are `active|superseded|preliminary|final|restated`',
    `rate_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the FX rate was observed or published by the source system, including time zone information for intraday rate tracking.',
    `rate_type` STRING COMMENT 'Classification of the FX rate type: spot for immediate delivery, forward for future delivery, swap for simultaneous spot and forward, or cross for non-USD pairs.. Valid values are `spot|forward|swap|cross`',
    `received_timestamp` TIMESTAMP COMMENT 'Timestamp when the rate was received and ingested into the internal treasury system from the external source, used for latency monitoring and data freshness validation.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Boolean flag indicating whether this rate is approved for use in regulatory reporting submissions to SEC, or other governing bodies, ensuring compliance with prescribed rate sources.',
    `spot_ask_rate` DECIMAL(18,8) COMMENT 'The ask (offer) side of the spot FX rate, representing the rate at which the market maker will sell the base currency. Used for bid-ask spread analysis and transaction cost estimation.',
    `spot_bid_rate` DECIMAL(18,8) COMMENT 'The bid side of the spot FX rate, representing the rate at which the market maker will buy the base currency. Used for bid-ask spread analysis and transaction cost estimation.',
    `spot_mid_rate` DECIMAL(18,8) COMMENT 'The mid-point between bid and ask spot rates, calculated as the average of bid and ask. Commonly used for portfolio valuation and performance reporting.',
    `spot_rate` DECIMAL(18,8) COMMENT 'The current market exchange rate for immediate delivery (typically T+2 settlement) of the currency pair, used for valuation and hedge ratio calculations.',
    `triangulation_method` STRING COMMENT 'Description of the calculation method used for cross rates, specifying the intermediate currency pairs and mathematical operations applied to derive the rate.',
    `usage_context` STRING COMMENT 'Description of the intended usage context for this rate (e.g., portfolio valuation, hedge accounting, settlement, performance reporting), supporting appropriate rate selection for different business processes.',
    `volatility_30d` DECIMAL(10,4) COMMENT 'Thirty-day historical volatility of the currency pair expressed as an annualized percentage, used for risk assessment, VaR calculations, and option pricing.',
    CONSTRAINT pk_treasury_fx_rate PRIMARY KEY(`treasury_fx_rate_id`)
) COMMENT 'Reference data table for official FX spot rates and forward points by currency pair and tenor, sourced from Bloomberg. Captures rate date, currency pair, spot rate, bid/ask spread, forward points by tenor (1W, 1M, 3M, 6M, 1Y), rate source, and rate type';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`counterparty_limit` (
    `counterparty_limit_id` BIGINT COMMENT 'Unique identifier for the treasury counterparty credit limit record.',
    `counterparty_id` BIGINT COMMENT 'Reference to the bank or dealer counterparty to which this limit applies.',
    `country_outlook_id` BIGINT COMMENT 'Foreign key linking to research.country_outlook. Business justification: Counterparty credit limits for FX/derivatives counterparties incorporate country risk assessment.',
    `csa_agreement_csa_id` BIGINT COMMENT 'Reference to the ISDA Credit Support Annex agreement governing collateral arrangements with this counterparty.',
    `csa_id` BIGINT COMMENT 'Reference to the ISDA Credit Support Annex agreement governing collateral arrangements with this counterparty.',
    `employee_id` BIGINT COMMENT 'Reference to the treasury officer or risk manager who approved this counterparty limit.',
    `isda_master_agreement_isda_master_id` BIGINT COMMENT 'Reference to the ISDA Master Agreement governing derivative transactions with this counterparty.',
    `isda_master_id` BIGINT COMMENT 'Reference to the ISDA Master Agreement governing derivative transactions with this counterparty.',
    `kyc_record_id` BIGINT COMMENT 'Foreign key linking to compliance.kyc_record. Business justification: AML regulations require pension funds to verify counterparty KYC status before establishing trading limits.',
    `modified_by_user_employee_id` BIGINT COMMENT 'Reference to the user who last modified this counterparty limit record.',
    `risk_limit_id` BIGINT COMMENT 'Foreign key linking to risk.limit. Business justification: Treasury counterparty limits must align with enterprise risk limit framework. Business process: Integrated limit monitoring ensures treasury limits are consistent with board-approved risk appetite',
    `approval_authority_level` STRING COMMENT 'Organizational authority level required to approve this limit: treasury officer, senior treasury manager, CFO, or board.. Valid values are `treasury_officer|senior_treasury_manager|cfo|board`',
    `approval_date` DATE COMMENT 'Date on which the counterparty limit was formally approved by authorized personnel.',
    `available_amount` DECIMAL(20,2) COMMENT 'Remaining available limit capacity, calculated as limit amount minus utilized amount.',
    `bic_swift_code` STRING COMMENT 'ISO 9362 BIC/SWIFT code of the counterparty bank, used for payment routing and settlement instructions.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `breach_action` STRING COMMENT 'Automated action to be taken when the limit is breached: block new trades, alert only, require approval for new trades, or reduce exposure.. Valid values are `block_new_trades|alert_only|require_approval|reduce_exposure`',
    `breach_count` BIGINT COMMENT 'Total number of times this counterparty limit has been breached since inception or last reset.',
    `collateral_required_flag` BOOLEAN COMMENT 'Indicates whether collateral posting is required under a Credit Support Annex (CSA) for transactions under this limit.',
    `concentration_limit_flag` BOOLEAN COMMENT 'Indicates whether this limit is subject to additional concentration risk controls due to the counterpartys systemic importance.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this counterparty limit record was first created in the system.',
    `credit_rating` STRING COMMENT 'Current credit rating of the counterparty from the specified rating agency, used to determine limit sizing.',
    `credit_rating_agency` STRING COMMENT 'The rating agency whose credit assessment is used as the basis for this limit: S&P, Moodys, Fitch, DBRS, or internal rating.. Valid values are `SP|Moodys|Fitch|DBRS|Internal`',
    `effective_date` DATE COMMENT 'Date from which the counterparty limit becomes active and enforceable.',
    `expiry_date` DATE COMMENT 'Date on which the counterparty limit expires and is no longer enforceable; nullable for evergreen limits.',
    `instrument_scope` STRING COMMENT 'The treasury instrument types covered by this limit: FX forwards, FX swaps, FX spot, repo, reverse repo, money market instruments, or all instruments. [ENUM-REF-CANDIDATE: fx_forward|fx_swap|fx_spot|repo|reverse_repo|money_market|all_instruments — 7',
    `internal_risk_classification` STRING COMMENT 'Internal risk classification assigned to the counterparty based on credit quality, systemic importance, and concentration risk.. Valid values are `low|medium|high|critical`',
    `last_breach_date` DATE COMMENT 'Date of the most recent breach of this counterparty limit, if any.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this counterparty limit record.',
    `last_review_date` DATE COMMENT 'Date of the most recent periodic review of this counterparty limit.',
    `lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier of the counterparty, used for regulatory reporting and entity identification.. Valid values are `^[A-Z0-9]{20}$`',
    `limit_amount` DECIMAL(20,2) COMMENT 'Maximum permissible exposure amount to the counterparty, expressed in the limit currency.',
    `limit_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the limit amount is denominated.. Valid values are `^[A-Z]{3}$`',
    `limit_reference_number` STRING COMMENT 'Business identifier for the counterparty limit record, used for external communication and audit trails.',
    `limit_status` STRING COMMENT 'Current lifecycle status of the counterparty limit: active for operational use, suspended temporarily, expired, pending approval, or revoked.. Valid values are `active|suspended|expired|pending_approval|revoked`',
    `limit_type` STRING COMMENT 'Classification of the limit by risk measurement approach: credit exposure, settlement risk, pre-settlement exposure, aggregate exposure, intraday, or overnight.. Valid values are `credit|settlement|pre_settlement|aggregate|intraday|overnight`',
    `minimum_rating_threshold` STRING COMMENT 'Minimum acceptable credit rating for the counterparty; limit is suspended if rating falls below this threshold.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review of this counterparty limit.',
    `notes` STRING COMMENT 'Free-text field for additional context, special conditions, or exceptions related to this counterparty limit.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this counterparty limit is subject to regulatory reporting requirements under EMIR, MiFID II, or local regulations.',
    `review_frequency` STRING COMMENT 'Scheduled frequency for periodic review and reaffirmation of the counterparty limit.. Valid values are `monthly|quarterly|semi_annual|annual|ad_hoc`',
    `threshold_breach_percentage` DECIMAL(5,2) COMMENT 'Utilization percentage threshold at which a breach alert is triggered and new transactions may be blocked.',
    `threshold_warning_percentage` DECIMAL(5,2) COMMENT 'Utilization percentage threshold at which a warning alert is triggered to treasury management.',
    `utilization_percentage` DECIMAL(5,2) COMMENT 'Percentage of the limit currently utilized, expressed as a decimal (e.g., 75.50 for 75.5%).',
    `utilized_amount` DECIMAL(20,2) COMMENT 'Current exposure amount utilized against the limit, calculated from outstanding positions and pending settlements.',
    CONSTRAINT pk_counterparty_limit PRIMARY KEY(`counterparty_limit_id`)
) COMMENT 'Treasury counterparty credit limit records defining the maximum permissible exposure to each bank or dealer counterparty for FX forwards, FX swaps, and short-term instrument transactions.';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` (
    `treasury_counterparty_exposure_id` BIGINT COMMENT 'Unique identifier for the treasury counterparty exposure record.',
    `counterparty_id` BIGINT COMMENT 'Reference to the financial institution or counterparty with whom the pension fund has treasury exposure.',
    `counterparty_limit_id` BIGINT COMMENT 'Foreign key linking to treasury.counterparty_limit. Business justification: Counterparty exposure is measured against counterparty limits. Links exposure record to applicable limit for breach monitoring.',
    `country_outlook_id` BIGINT COMMENT 'Foreign key linking to research.country_outlook. Business justification: Counterparty credit exposure assessment incorporates sovereign/country risk for foreign counterparties.',
    `custodian_id` BIGINT COMMENT 'Reference to the custody platform through which positions with this counterparty are settled and reported.',
    `netting_agreement_id` BIGINT COMMENT 'Foreign key linking to collateral.netting_agreement. Business justification: Net counterparty exposure calculations depend on applicable netting agreements.',
    `base_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which exposure amounts are reported.. Valid values are `^[A-Z]{3}$`',
    `collateral_held_amount` DECIMAL(20,2) COMMENT 'Market value of collateral received from the counterparty under Credit Support Annex (CSA) agreements.',
    `collateral_posted_amount` DECIMAL(20,2) COMMENT 'Market value of collateral posted to the counterparty under Credit Support Annex (CSA) agreements.',
    `counterparty_credit_rating` STRING COMMENT 'Current external credit rating of the counterparty from a recognized rating agency.',
    `counterparty_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the counterparty, enabling global identification and regulatory reporting.. Valid values are `^[A-Z0-9]{20}$`',
    `counterparty_type` STRING COMMENT 'Classification of the counterparty by institutional type.. Valid values are `bank|broker_dealer|central_counterparty|custodian|investment_manager|insurance_company`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this exposure record was first created in the system.',
    `credit_valuation_adjustment_amount` DECIMAL(20,2) COMMENT 'Adjustment to the fair value of derivative positions to account for counterparty credit risk.',
    `csa_agreement_flag` BOOLEAN COMMENT 'Indicates whether a Credit Support Annex is in place with this counterparty for collateral management.',
    `csa_minimum_transfer_amount` DECIMAL(20,2) COMMENT 'Minimum amount of collateral that must be transferred in a single movement under the CSA.',
    `csa_threshold_amount` DECIMAL(20,2) COMMENT 'Exposure threshold amount below which collateral exchange is not required under the CSA.',
    `exposure_date` DATE COMMENT 'Business date for which the counterparty exposure is calculated and reported.',
    `exposure_limit_amount` DECIMAL(20,2) COMMENT 'Maximum approved credit exposure limit for this counterparty as set by the Investment Committee or risk policy.',
    `exposure_status` STRING COMMENT 'Current operational status of the counterparty exposure relationship.. Valid values are `active|suspended|closed|under_review|breach`',
    `fx_forward_count` BIGINT COMMENT 'Number of outstanding FX forward contracts with this counterparty.',
    `fx_swap_count` BIGINT COMMENT 'Number of outstanding FX swap contracts with this counterparty.',
    `gross_mtm_exposure_amount` DECIMAL(20,2) COMMENT 'Total mark-to-market value of all positions with the counterparty before netting and collateral adjustments.',
    `gross_notional_amount` DECIMAL(20,2) COMMENT 'Total notional value of all outstanding positions with the counterparty before netting.',
    `isda_agreement_date` DATE COMMENT 'Effective date of the ISDA Master Agreement with this counterparty.',
    `isda_master_agreement_flag` BOOLEAN COMMENT 'Indicates whether an ISDA Master Agreement is in place with this counterparty.',
    `last_collateral_call_date` DATE COMMENT 'Date of the most recent collateral call or margin call with this counterparty.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this exposure record was last updated.',
    `last_reconciliation_date` DATE COMMENT 'Date when the exposure was last reconciled with counterparty statements.',
    `limit_breach_flag` BOOLEAN COMMENT 'Indicator of whether the current exposure exceeds the approved counterparty limit.',
    `limit_utilization_percentage` DECIMAL(5,2) COMMENT 'Percentage of the approved exposure limit currently utilized by the net credit exposure.',
    `net_credit_exposure_amount` DECIMAL(20,2) COMMENT 'Final net credit exposure after netting and collateral adjustments, representing true counterparty credit risk.',
    `net_mtm_exposure_amount` DECIMAL(20,2) COMMENT 'Net mark-to-market exposure after applying bilateral netting but before collateral adjustments.',
    `netting_benefit_amount` DECIMAL(20,2) COMMENT 'Reduction in exposure achieved through bilateral netting agreements under ISDA Master Agreement.',
    `next_collateral_review_date` DATE COMMENT 'Scheduled date for the next collateral position review with this counterparty.',
    `notes` STRING COMMENT 'Free-text field for additional comments, exceptions, or context regarding the counterparty exposure.',
    `potential_future_exposure_amount` DECIMAL(20,2) COMMENT 'Estimated maximum exposure that could arise in the future due to market movements, calculated using risk models.',
    `rating_agency` STRING COMMENT 'Credit rating agency that issued the counterparty credit rating.. Valid values are `SP|Moodys|Fitch|DBRS`',
    `reconciliation_status` STRING COMMENT 'Status of reconciliation between internal exposure calculation and counterparty confirmation.. Valid values are `reconciled|pending|discrepancy|not_required`',
    `regulatory_capital_charge_amount` DECIMAL(20,2) COMMENT 'Regulatory capital requirement associated with this counterparty exposure under Basel III or local prudential rules.',
    `risk_weight_percentage` DECIMAL(5,2) COMMENT 'Basel III risk weight applied to this counterparty exposure for regulatory capital calculation.',
    `settlement_risk_flag` BOOLEAN COMMENT 'Indicates whether settlement risk exists due to non-delivery-versus-payment settlement arrangements.',
    `short_term_instrument_count` BIGINT COMMENT 'Number of outstanding short-term liquidity instruments with this counterparty.',
    `valuation_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the mark-to-market valuation was performed for this exposure record.',
    `wrong_way_risk_flag` BOOLEAN COMMENT 'Indicates whether wrong-way risk exists where counterparty credit quality is negatively correlated with exposure.',
    CONSTRAINT pk_treasury_counterparty_exposure PRIMARY KEY(`treasury_counterparty_exposure_id`)
) COMMENT 'Daily mark-to-market counterparty exposure records aggregating all outstanding FX forward, FX swap, and short-term instrument positions with each treasury counterparty.';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` (
    `liquidity_reserve_policy_id` BIGINT COMMENT 'Unique identifier for the liquidity reserve policy record.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: Liquidity reserve policies define stress thresholds (stress_scenario_type exists). Regulatory stress testing requires linking reserve requirements to specific economic scenarios.',
    `employee_id` BIGINT COMMENT 'Identifier of the user who approved this liquidity reserve policy.',
    `funded_status_id` BIGINT COMMENT 'Foreign key linking to actuarial.funded_status. Business justification: Liquidity reserve requirements vary based on plan funded status - underfunded plans require larger buffers for potential special contributions.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Pension fund liquidity requirements are mandated by specific regulators (PRA, FCA, local pension authorities).',
    `superseded_by_policy_liquidity_reserve_policy_id` BIGINT COMMENT 'Identifier of the liquidity reserve policy that supersedes this policy; nullable if current.',
    `approval_authority` STRING COMMENT 'Governance body or role with authority to approve this liquidity reserve policy.. Valid values are `treasury_head|cfo|investment_committee|board`',
    `approval_date` DATE COMMENT 'Date on which the liquidity reserve policy was formally approved.',
    `capital_call_reserve_percentage` DECIMAL(5,2) COMMENT 'Percentage of unfunded capital commitments to be held as liquidity reserve for capital call funding.',
    `collateral_buffer_percentage` DECIMAL(5,2) COMMENT 'Percentage buffer for collateral posting requirements under derivative and repo agreements.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the liquidity reserve policy record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which liquidity reserve amounts are denominated.. Valid values are `^[A-Z]{3}$`',
    `distribution_reserve_percentage` DECIMAL(5,2) COMMENT 'Percentage of expected beneficiary distributions to be held as liquidity reserve.',
    `effective_date` DATE COMMENT 'Date from which the liquidity reserve policy becomes binding and operational.',
    `eligible_instrument_types` STRING COMMENT 'Comma-separated list of eligible short-term liquidity instrument types under this policy. [ENUM-REF-CANDIDATE: t_bills|sofr_linked|commercial_paper|repo|money_market_funds|bank_deposits|government_bonds — promote to reference product]',
    `escalation_procedure` STRING COMMENT 'Description of the escalation procedure to be followed when liquidity thresholds are breached.',
    `escalation_threshold_amount` DECIMAL(18,2) COMMENT 'Absolute liquidity shortfall amount that triggers escalation to senior management or Investment Committee (IC).',
    `expiry_date` DATE COMMENT 'Date on which the liquidity reserve policy ceases to be effective; nullable for open-ended policies.',
    `fx_hedge_settlement_reserve_days` BIGINT COMMENT 'Number of days of FX hedge settlement exposure to be covered by liquidity reserves.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the liquidity reserve policy record was last modified.',
    `last_review_date` DATE COMMENT 'Date of the most recent review of the liquidity reserve policy.',
    `liquidity_tier_classification` STRING COMMENT 'Classification of liquidity assets into tiers based on quality and convertibility to cash.. Valid values are `tier_1|tier_2|tier_3`',
    `minimum_cash_buffer_amount` DECIMAL(18,2) COMMENT 'Minimum absolute cash reserve amount required to be maintained under this policy.',
    `minimum_cash_buffer_percentage` DECIMAL(5,2) COMMENT 'Minimum cash reserve expressed as a percentage of Assets Under Management (AUM) or net contributions.',
    `minimum_liquidity_coverage_ratio` DECIMAL(5,2) COMMENT 'Minimum acceptable liquidity coverage ratio below which escalation procedures are triggered.',
    `net_stable_funding_ratio_target` DECIMAL(5,2) COMMENT 'Target ratio of available stable funding to required stable funding over a one-year horizon.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next review of the liquidity reserve policy.',
    `notes` STRING COMMENT 'Additional notes, comments, or context regarding the liquidity reserve policy.',
    `policy_document_uri` STRING COMMENT 'URI or file path to the formal policy document for this liquidity reserve policy.',
    `policy_name` STRING COMMENT 'Descriptive name of the liquidity reserve policy.',
    `policy_reference_number` STRING COMMENT 'Externally-known unique reference number for the liquidity reserve policy.. Valid values are `^LRP-[0-9]{6}$`',
    `policy_status` STRING COMMENT 'Current lifecycle status of the liquidity reserve policy.. Valid values are `draft|pending_approval|active|suspended|superseded|retired`',
    `policy_type` STRING COMMENT 'Classification of the liquidity reserve policy by purpose and scope.. Valid values are `strategic|tactical|stress|regulatory|operational|contingency`',
    `rebalancing_frequency` STRING COMMENT 'Frequency at which liquidity reserve positions are reviewed and rebalanced.. Valid values are `daily|weekly|monthly|quarterly|event_driven`',
    `rebalancing_trigger_threshold_percentage` DECIMAL(5,2) COMMENT 'Percentage deviation from target liquidity levels that triggers rebalancing action.',
    `regulatory_framework` STRING COMMENT 'Name of the regulatory framework or standard to which this policy is aligned.',
    `reporting_frequency` STRING COMMENT 'Frequency at which liquidity reserve compliance is reported to governance bodies.. Valid values are `daily|weekly|monthly|quarterly`',
    `review_frequency` STRING COMMENT 'Frequency at which the liquidity reserve policy is reviewed and updated.. Valid values are `quarterly|semi_annual|annual|ad_hoc`',
    `short_term_instrument_maturity_limit_days` BIGINT COMMENT 'Maximum maturity in days for short-term liquidity instruments eligible under this policy.',
    `stress_liquidity_threshold_amount` DECIMAL(18,2) COMMENT 'Minimum cash reserve required under stress scenario conditions.',
    `stress_scenario_type` STRING COMMENT 'Type of stress scenario for which the stress liquidity threshold is calibrated.. Valid values are `market_downturn|credit_crisis|liquidity_shock|operational_disruption|combined`',
    `target_liquidity_coverage_ratio` DECIMAL(5,2) COMMENT 'Target ratio of high-quality liquid assets to net cash outflows over a 30-day stress period.',
    CONSTRAINT pk_liquidity_reserve_policy PRIMARY KEY(`liquidity_reserve_policy_id`)
) COMMENT 'Master record defining the liquidity reserve policy parameters governing minimum cash buffer requirements, liquidity tier classifications, and stress liquidity thresholds.';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`cash_flow_event` (
    `cash_flow_event_id` BIGINT COMMENT 'Unique identifier for the cash flow event record. Primary key for the cash flow event entity.',
    `blotter_id` BIGINT COMMENT 'Reference to the trade execution record if this event represents settlement of a trade transaction.',
    `capital_call_funding_id` BIGINT COMMENT 'Reference to the capital call notice if this event represents funding of a capital call commitment.',
    `privateequity_capital_call_id` BIGINT COMMENT 'Reference to the capital call notice if this event represents funding of a capital call commitment.',
    `cash_account_id` BIGINT COMMENT 'Reference to the specific cash account that will receive or disburse the cash flow.',
    `counterparty_id` BIGINT COMMENT 'Reference to the external counterparty entity involved in the cash flow event, such as a GP, custodian, or broker.',
    `custodian_id` BIGINT COMMENT 'Reference to the custodian bank or institution through which the cash flow event will settle.',
    `distribution_id` BIGINT COMMENT 'Reference to the distribution record if this event represents a distribution received from an investment.',
    `distribution_receipt_id` BIGINT COMMENT 'Foreign key linking to treasury.distribution_receipt. Business justification: Cash flow events from distributions should link to treasury distribution_receipt for treasury-side tracking.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: Asset-liability management (ALM) requires projecting cash flow events under different economic scenarios.',
    `employee_id` BIGINT COMMENT 'Reference to the user who last modified this cash flow event record.',
    `fx_forward_id` BIGINT COMMENT 'Foreign key linking to treasury.fx_forward. Business justification: Cash flow events from FX forward settlements should link to the specific forward contract.',
    `fx_swap_id` BIGINT COMMENT 'Foreign key linking to treasury.fx_swap. Business justification: Cash flow events from FX swap settlements should link to the specific swap contract.',
    `hedge_program_id` BIGINT COMMENT 'Reference to the FX hedge instrument if this event represents settlement of a currency hedge position.',
    `investment_id` BIGINT COMMENT 'Reference to the specific investment position or holding that generated this cash flow event, if applicable.',
    `liquidity_forecast_id` BIGINT COMMENT 'Reference to the parent liquidity forecast that this cash flow event feeds into.',
    `listed_security_id` BIGINT COMMENT 'Reference to the security instrument generating the cash flow, such as a bond for coupon payments or maturity.',
    `manager_mandate_id` BIGINT COMMENT 'Foreign key linking to manager.manager_mandate. Business justification: Management fee payments and carried interest settlements are mandate-specific cash flows.',
    `margin_call_id` BIGINT COMMENT 'Foreign key linking to collateral.margin_call. Business justification: Margin call settlements are material cash flow events requiring explicit tracking in liquidity forecasting.',
    `net_contribution_inflow_id` BIGINT COMMENT 'Foreign key linking to treasury.net_contribution_inflow. Business justification: Cash flow events from pension contributions should link to net_contribution_inflow records.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio or fund entity to which this cash flow event is allocated.',
    `resource_asset_id` BIGINT COMMENT 'Foreign key linking to naturalresource.resource_asset. Business justification: Cash flow events (royalties, production revenue) are tied to a specific resource asset for reconciliation and reporting.',
    `short_term_instrument_id` BIGINT COMMENT 'Foreign key linking to treasury.short_term_instrument. Business justification: Cash flow events from ST instrument maturities/purchases should link to the specific instrument.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_asset_valuation. Business justification: Cash flow events (dividends, distributions, interest) must link to asset valuations for performance attribution and return calculation.',
    `actual_flag` BOOLEAN COMMENT 'Boolean indicator of whether this cash flow event has actually occurred and settled, versus being a forecast or expectation.',
    `base_currency_amount` DECIMAL(20,2) COMMENT 'The net cash flow amount converted to the funds base reporting currency using the applicable FX rate.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this cash flow event record was first created in the lakehouse.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the cash flow event amounts.. Valid values are `^[A-Z]{3}$`',
    `cusip` STRING COMMENT 'CUSIP identifier for the security generating the cash flow, primarily used for North American securities.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `event_date` DATE COMMENT 'The business date on which the cash flow event is scheduled to occur or did occur.',
    `event_reference_number` STRING COMMENT 'Externally-known unique reference number or code for this cash flow event, used for tracking and reconciliation.',
    `event_status` STRING COMMENT 'Current lifecycle status of the cash flow event indicating whether it is expected, confirmed, or has occurred.. Valid values are `scheduled|confirmed|settled|cancelled|revised`',
    `event_type` STRING COMMENT 'Classification of the cash flow event type indicating the nature of the cash movement. [ENUM-REF-CANDIDATE',
    `ex_date` DATE COMMENT 'Ex-dividend or ex-distribution date after which new holders are not entitled to the cash flow.',
    `fee_amount` DECIMAL(20,2) COMMENT 'Total fees or deductions applied to the gross cash flow amount, in the event currency.',
    `flow_direction` STRING COMMENT 'Indicates whether the cash flow event represents an inflow of cash to the fund or an outflow from the fund.. Valid values are `inflow|outflow`',
    `forecast_confidence_level` STRING COMMENT 'Confidence level in the accuracy and timing of the forecasted cash flow event, based on certainty of occurrence.. Valid values are `high|medium|low`',
    `fx_rate` DECIMAL(18,8) COMMENT 'Exchange rate applied to convert the event currency to the base reporting currency, if applicable.',
    `gross_amount` DECIMAL(20,2) COMMENT 'The gross cash flow amount before any deductions, fees, or adjustments, in the event currency.',
    `isin` STRING COMMENT 'International Securities Identification Number for the security generating the cash flow, if applicable.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'System timestamp when this cash flow event record was last updated or modified.',
    `net_amount` DECIMAL(20,2) COMMENT 'The net cash flow amount after all fees and deductions, representing the actual impact on cash position, in the event currency.',
    `notes` STRING COMMENT 'Free-text notes or comments providing additional context, explanations, or special instructions for the cash flow event.',
    `notification_date` DATE COMMENT 'Date on which the cash flow event was first notified or announced by the counterparty or source system.',
    `payment_frequency` STRING COMMENT 'Expected frequency or recurrence pattern of this type of cash flow event.. Valid values are `monthly|quarterly|semi_annual|annual|irregular|one_time`',
    `payment_type` STRING COMMENT 'Specific classification of the payment or cash flow within the broader event type category. [ENUM-REF-CANDIDATE: coupon|dividend|principal|redemption|interest|return_of_capital|carried_interest|management_fee|performance_fee — 9 candidates stripped',
    `reconciliation_status` STRING COMMENT 'Status of reconciliation between the forecasted cash flow event and the actual settlement from custody systems.. Valid values are `pending|matched|unmatched|exception|resolved`',
    `record_date` DATE COMMENT 'Record date for determining entitlement to the cash flow, particularly relevant for dividends and distributions.',
    `settlement_date` DATE COMMENT 'The actual date on which the cash flow event settled or is expected to settle with the counterparty.',
    `source_system_reference` STRING COMMENT 'Unique identifier or reference number for this cash flow event in the originating source system.',
    `value_date` DATE COMMENT 'The date on which the cash flow becomes available for use or investment, accounting for settlement cycles.',
    `variance_amount` DECIMAL(20,2) COMMENT 'Difference between the forecasted cash flow amount and the actual settled amount, in the event currency.',
    CONSTRAINT pk_cash_flow_event PRIMARY KEY(`cash_flow_event_id`)
) COMMENT 'Granular record of each expected or actual cash flow event feeding into the liquidity forecast, including scheduled capital calls, LP distributions received, coupon and dividend receipts, bond maturities, FX hedge settlements, management fee payments';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`bank_account_ssi` (
    `bank_account_ssi_id` BIGINT COMMENT 'Unique identifier for the bank account standard settlement instruction record.',
    `approved_by_user_employee_id` BIGINT COMMENT 'Reference to the user who approved this SSI record for operational use.',
    `counterparty_id` BIGINT COMMENT 'Reference to the counterparty entity associated with this settlement instruction.',
    `custodian_id` BIGINT COMMENT 'Reference to the custodian bank or financial institution holding the account.',
    `employee_id` BIGINT COMMENT 'Reference to the user who approved this SSI record for operational use.',
    `legal_entity_id` BIGINT COMMENT 'Reference to the internal legal entity that owns or controls this account for regulatory and accounting purposes.',
    `aba_routing_number` STRING COMMENT 'Nine-digit ABA routing number used for domestic US settlement instructions.. Valid values are `^[0-9]{9}$`',
    `account_name` STRING COMMENT 'Full legal name of the account as registered with the custodian or correspondent bank.',
    `account_number` STRING COMMENT 'Unique account number assigned by the custodian or bank for settlement purposes.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when this SSI record was approved for operational use.',
    `asset_class` STRING COMMENT 'Primary asset class for which this SSI is designated, enabling asset-specific routing and settlement workflows. [ENUM-REF-CANDIDATE: equity|fixed_income|fx|derivatives|commodities|cash|multi_asset — 7 candidates stripped; promote to reference product]',
    `beneficiary_address_line1` STRING COMMENT 'First line of the beneficiary or account holder address for settlement documentation.',
    `beneficiary_address_line2` STRING COMMENT 'Second line of the beneficiary or account holder address for settlement documentation.',
    `beneficiary_city` STRING COMMENT 'City of the beneficiary or account holder address.',
    `beneficiary_country_code` STRING COMMENT 'Three-letter ISO country code of the beneficiary or account holder address.. Valid values are `^[A-Z]{3}$`',
    `beneficiary_name` STRING COMMENT 'Name of the ultimate beneficiary or account holder for the settlement instruction.',
    `beneficiary_postal_code` STRING COMMENT 'Postal or ZIP code of the beneficiary or account holder address.',
    `beneficiary_state_province` STRING COMMENT 'State or province of the beneficiary or account holder address.',
    `bic_swift_code` STRING COMMENT 'Bank Identifier Code or SWIFT code identifying the custodian or correspondent bank in the global financial network.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `correspondent_bank_account_number` STRING COMMENT 'Account number held at the correspondent bank for routing settlement instructions.',
    `correspondent_bank_bic` STRING COMMENT 'BIC or SWIFT code of the correspondent or intermediary bank in the settlement chain.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `correspondent_bank_name` STRING COMMENT 'Full legal name of the correspondent or intermediary bank used in the settlement chain, if applicable.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this SSI record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code indicating the currency denomination of the account.. Valid values are `^[A-Z]{3}$`',
    `default_ssi_flag` BOOLEAN COMMENT 'Indicates whether this SSI is the default instruction for the given custodian, currency, and asset class combination.',
    `effective_date` DATE COMMENT 'Date from which this SSI record becomes active and available for use in settlement operations.',
    `expiration_date` DATE COMMENT 'Date on which this SSI record expires and is no longer valid for settlement operations. Null indicates no expiration.',
    `iban` STRING COMMENT 'International Bank Account Number used for cross-border settlement instructions, primarily in European and international markets.. Valid values are `^[A-Z]{2}[0-9]{2}[A-Z0-9]+$`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this SSI record was last updated or modified.',
    `last_verified_date` DATE COMMENT 'Date when this SSI was last verified or confirmed with the custodian or counterparty for accuracy and operational readiness.',
    `lei` STRING COMMENT 'Twenty-character Legal Entity Identifier for the account owner, used for regulatory reporting and counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `market_code` STRING COMMENT 'Market or exchange code where this SSI is applicable for settlement operations.',
    `next_verification_due_date` DATE COMMENT 'Date by which the next verification of this SSI record must be completed.',
    `notes` STRING COMMENT 'Additional free-text notes or comments related to this SSI record for operational reference and audit trail purposes.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether transactions settled through this SSI require special regulatory reporting or disclosure.',
    `safekeeping_account_flag` BOOLEAN COMMENT 'Indicates whether this account is used for safekeeping of securities versus cash settlement only.',
    `settlement_method` STRING COMMENT 'Method of settlement for transactions using this SSI. DVP: Delivery Versus Payment, RVP: Receive Versus Payment, FOP: Free of Payment, DAP: Delivery Against Payment, RAF: Receive and Free.. Valid values are `dvp|rvp|fop|dap|raf`',
    `settlement_priority` STRING COMMENT 'Priority level assigned to settlement instructions using this SSI for operational sequencing.. Valid values are `high|normal|low`',
    `special_instructions` STRING COMMENT 'Free-text field capturing any special handling instructions, operational notes, or settlement requirements specific to this SSI.',
    `ssi_reference_number` STRING COMMENT 'Unique business reference number for this SSI record, used for operational identification and communication.',
    `ssi_status` STRING COMMENT 'Current lifecycle status of the SSI record indicating whether it is available for use in settlement operations.. Valid values are `active|inactive|pending|suspended|expired`',
    `ssi_type` STRING COMMENT 'Classification of the SSI record by its operational purpose.. Valid values are `custody|counterparty|broker|correspondent|internal`',
    `verification_frequency_days` BIGINT COMMENT 'Number of days between required verifications of this SSI record to ensure ongoing accuracy and compliance.',
    CONSTRAINT pk_bank_account_ssi PRIMARY KEY(`bank_account_ssi_id`)
) COMMENT 'Standard Settlement Instructions (SSI) reference records for each custodian bank account and counterparty settlement account used in treasury operations. Captures account name, account number, BIC/SWIFT code, IBAN, correspondent bank details, currency';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` (
    `fx_hedge_rebalance_id` BIGINT COMMENT 'Unique identifier for the FX hedge rebalancing event.',
    `counterparty_id` BIGINT COMMENT 'Reference to the financial institution counterparty with whom the rebalancing trades were executed.',
    `employee_id` BIGINT COMMENT 'Reference to the user who approved the rebalancing execution, if approval was required.',
    `executed_by_user_employee_id` BIGINT COMMENT 'Reference to the treasury user who executed the rebalancing trades in the market.',
    `fx_position_id` BIGINT COMMENT 'Reference to the FX position that triggered this rebalancing event.',
    `fx_risk_exposure_id` BIGINT COMMENT 'Foreign key linking to risk.fx_risk_exposure. Business justification: FX hedge rebalancing decisions are triggered by risk exposure assessments. Business process: Rebalancing workflow requires current FX risk exposure to calculate required hedge',
    `fx_trade_id` BIGINT COMMENT 'Foreign key linking to trade.fx_trade. Business justification: Hedge rebalancing generates FX trades to adjust hedge ratios. Treasury teams must link rebalance events to resulting trades for hedge effectiveness testing and audit trail compliance.',
    `hedge_program_id` BIGINT COMMENT 'Foreign key linking to treasury.hedge_program. Business justification: Hedge rebalancing events are triggered by hedge program parameters. Links rebalance to its governing program.',
    `isda_agreement_isda_master_id` BIGINT COMMENT 'Reference to the ISDA master agreement under which the rebalancing trades were executed.',
    `isda_master_id` BIGINT COMMENT 'Reference to the ISDA master agreement under which the rebalancing trades were executed.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio for which the hedge is being rebalanced.',
    `actual_hedge_ratio_after` DECIMAL(5,4) COMMENT 'Actual hedge ratio achieved after the rebalancing execution, expressed as a decimal proportion.',
    `actual_hedge_ratio_before` DECIMAL(5,4) COMMENT 'Actual hedge ratio calculated immediately before the rebalancing event, expressed as a decimal proportion.',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether the rebalancing required formal approval before execution based on size or policy thresholds.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the rebalancing was formally approved for execution.',
    `base_currency` STRING COMMENT 'Three-letter ISO 4217 code for the base currency of the portfolio being hedged.',
    `collateral_impact_base` DECIMAL(18,2) COMMENT 'Net change in collateral posted or received as a result of the rebalancing, expressed in base currency.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this rebalancing record was first created in the system.',
    `currency_pair` STRING COMMENT 'Standard FX market notation for the currency pair being rebalanced, typically base/quote format.',
    `execution_date` DATE COMMENT 'Date on which the rebalancing trades were executed in the market.',
    `execution_rate` DECIMAL(18,8) COMMENT 'Weighted average exchange rate at which the rebalancing trades were executed.',
    `execution_timestamp` TIMESTAMP COMMENT 'Date and time when the rebalancing trades were executed in the market.',
    `existing_hedge_notional_base` DECIMAL(20,2) COMMENT 'Total notional value of existing hedge instruments in base currency before rebalancing.',
    `exposure_amount_base` DECIMAL(20,2) COMMENT 'Total currency exposure in base currency terms at the time of rebalancing trigger.',
    `forward_points` DECIMAL(12,6) COMMENT 'Forward points applied to the spot rate for forward-dated hedge instruments in the rebalancing.',
    `hedge_designation` STRING COMMENT 'Accounting designation of the hedge relationship for financial reporting purposes.. Valid values are `cash_flow|fair_value|net_investment|economic`',
    `hedge_effectiveness_ratio` DECIMAL(5,4) COMMENT 'Calculated hedge effectiveness ratio after rebalancing for hedge accounting qualification purposes.',
    `hedge_instrument_type` STRING COMMENT 'Primary type of FX derivative instrument used to execute the rebalancing.. Valid values are `forward|swap|option|ndf|combination`',
    `hedge_ratio_variance` DECIMAL(5,4) COMMENT 'Difference between actual hedge ratio and target hedge ratio that triggered the rebalancing event.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this rebalancing record was last updated in the system.',
    `lower_threshold_breach_flag` BOOLEAN COMMENT 'Indicates whether the rebalancing was triggered by the hedge ratio falling below the lower permitted band.',
    `mtm_impact_base` DECIMAL(18,2) COMMENT 'Immediate mark-to-market profit or loss impact from the rebalancing trades, expressed in base currency.',
    `new_hedge_notional_base` DECIMAL(20,2) COMMENT 'Total notional value of hedge instruments after rebalancing execution, expressed in base currency.',
    `notes` STRING COMMENT 'Free-text field for additional context, rationale, or special circumstances related to the rebalancing event.',
    `quote_currency` STRING COMMENT 'Three-letter ISO 4217 code for the quote currency in the FX pair being rebalanced.',
    `rebalance_action_type` STRING COMMENT 'Classification of the hedging action taken to restore the hedge ratio to target.. Valid values are `increase_hedge|decrease_hedge|roll_forward|unwind|restructure`',
    `rebalance_cost_base` DECIMAL(18,2) COMMENT 'Total transaction cost incurred for executing the rebalancing, including spreads and fees, in base currency.',
    `rebalance_notional_amount_base` DECIMAL(20,2) COMMENT 'Notional amount of hedge instruments added or removed during rebalancing, expressed in base currency.',
    `rebalance_reference_number` STRING COMMENT 'Externally-known unique reference number assigned to this rebalancing event for tracking and audit purposes.',
    `rebalance_status` STRING COMMENT 'Current lifecycle status of the rebalancing event in the workflow.. Valid values are `pending|approved|executed|settled|cancelled|failed`',
    `rebalance_trigger_type` STRING COMMENT 'Classification of the event or condition that triggered this rebalancing action.. Valid values are `threshold_breach|scheduled|manual|policy_change|market_event|risk_limit`',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this rebalancing event requires regulatory reporting under applicable derivatives regulations.',
    `settlement_date` DATE COMMENT 'Date on which the rebalancing trades are scheduled to settle and cash flows exchange.',
    `spot_rate_at_trigger` DECIMAL(18,8) COMMENT 'Market spot exchange rate for the currency pair at the time the rebalancing was triggered.',
    `target_hedge_ratio` DECIMAL(5,4) COMMENT 'Policy-defined target hedge ratio that the rebalancing aims to achieve, expressed as a decimal proportion.',
    `trade_confirmation_reference` STRING COMMENT 'External confirmation reference number provided by the counterparty or trading platform for the rebalancing trades.',
    `trigger_timestamp` TIMESTAMP COMMENT 'Date and time when the rebalancing trigger condition was detected and the event was initiated.',
    `upper_threshold_breach_flag` BOOLEAN COMMENT 'Indicates whether the rebalancing was triggered by the hedge ratio exceeding the upper permitted band.',
    CONSTRAINT pk_fx_hedge_rebalance PRIMARY KEY(`fx_hedge_rebalance_id`)
) COMMENT 'Operational records capturing each FX hedge rebalancing event triggered when currency exposures drift outside the permitted hedge ratio band defined in the hedge program.';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`treasury_policy` (
    `treasury_policy_id` BIGINT COMMENT 'Primary key for policy',
    `employee_id` BIGINT COMMENT 'Identifier of the treasury function user responsible for maintaining and executing this mandate policy.',
    `esg_policy_id` BIGINT COMMENT 'Foreign key linking to esg.policy. Business justification: Treasury mandates with esg_integration_flag need linkage to specific ESG policy governing integration requirements.',
    `framework_id` BIGINT COMMENT 'Foreign key linking to esg.framework. Business justification: Treasury policies must align with regulatory ESG frameworks (SFDR, TCFD, PRI). Links treasury mandate to applicable framework for regulatory compliance tracking and disclosure requirements.',
    `policy_document_id` BIGINT COMMENT 'Reference to the formal policy document artifact stored in the document management system, containing the full Investment Committee (IC) approved mandate text.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Treasury mandates implement specific regulatory requirements. Linking to regulatory_authority enables compliance teams to track which regulators rules each treasury policy',
    `superseded_by_mandate_treasury_policy_id` BIGINT COMMENT 'Reference to the subsequent treasury mandate policy that replaces this version, enabling version lineage tracking.',
    `approved_counterparty_list` STRING COMMENT 'Comma-separated list of counterparties approved for Foreign Exchange (FX) forward, swap, and derivative transactions under this mandate, subject to Know Your Customer (KYC) and Anti-Money Laundering (AML) compliance.',
    `approved_custodian_list` STRING COMMENT 'Comma-separated list of custodian institutions approved for treasury cash account management and settlement under this mandate, such as State Street and Northern Trust.',
    `base_currency_code` STRING COMMENT 'Three-letter International Organization for Standardization (ISO) 4217 currency code representing the base reporting currency for all treasury mandate thresholds and limits.. Valid values are `^[A-Z]{3}$`',
    `benchmark_rate` DECIMAL(18,2) COMMENT 'Reference benchmark rate used for pricing short-term treasury instruments and evaluating performance, such as Secured Overnight Financing Rate (SOFR) or Euro Short-Term Rate (ESTR).',
    `collateral_minimum_transfer_amount` DECIMAL(18,2) COMMENT 'Minimum collateral transfer amount required under Credit Support Annex (CSA) agreements to reduce operational friction, denominated in base currency.',
    `collateral_posting_threshold_amount` DECIMAL(18,2) COMMENT 'Minimum mark-to-market (MTM) exposure threshold that triggers collateral posting requirements under Credit Support Annex (CSA) agreements, denominated in base currency.',
    `counterparty_concentration_limit_pct` DECIMAL(5,2) COMMENT 'Maximum percentage of total treasury assets that may be allocated to a single counterparty, expressed in basis points (bps) to manage concentration risk.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this treasury mandate policy record was first created in the system.',
    `dv01_limit_amount` DECIMAL(18,2) COMMENT 'Maximum Dollar Value of Zero One (DV01) interest rate sensitivity permitted for treasury fixed income holdings, denominated in base currency.',
    `effective_date` DATE COMMENT 'Date on which the treasury mandate policy becomes binding and operational for treasury activities.',
    `eligible_collateral_types` STRING COMMENT 'Comma-separated list of collateral asset types acceptable for posting under this mandate, such as cash, government bonds, Investment Grade (IG) corporate bonds, and money market instruments.',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether Environmental, Social, and Governance (ESG) criteria are integrated into counterparty and instrument selection under this mandate.',
    `expiry_date` DATE COMMENT 'Date on which the treasury mandate policy ceases to be effective, nullable for open-ended mandates subject to periodic review.',
    `fx_hedge_ratio_target_pct` DECIMAL(5,2) COMMENT 'Target hedge ratio for Foreign Exchange (FX) exposure management, expressed as a percentage of total foreign currency exposure to be hedged.',
    `fx_hedge_ratio_tolerance_pct` DECIMAL(5,2) COMMENT 'Allowable deviation from the target Foreign Exchange (FX) hedge ratio before rebalancing is required, expressed in percentage points.',
    `ic_approval_date` DATE COMMENT 'Date on which the Investment Committee (IC) formally approved this treasury mandate policy version.',
    `ic_approval_reference` STRING COMMENT 'Investment Committee (IC) meeting reference number or resolution identifier documenting the approval of this mandate policy.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this treasury mandate policy record was last updated, supporting audit trail and version control.',
    `last_review_date` DATE COMMENT 'Date of the most recent Investment Committee (IC) review of this treasury mandate policy.',
    `mandate_name` STRING COMMENT 'Descriptive name of the treasury mandate policy, typically reflecting the strategic purpose or version identifier.',
    `mandate_reference_number` STRING COMMENT 'Externally-known business identifier for the treasury mandate policy, used in Investment Committee (IC) documentation and governance records.. Valid values are `^TM-[0-9]{6}$`',
    `mandate_status` STRING COMMENT 'Current lifecycle status of the treasury mandate policy within the governance approval and operational workflow.. Valid values are `draft|pending_approval|active|suspended|superseded|terminated`',
    `mandate_type` STRING COMMENT 'Classification of the treasury mandate by operational focus area: liquidity management, cash management, Foreign Exchange (FX) hedging, collateral management, or integrated.. Valid values are `liquidity_management|cash_management|fx_hedging|collateral_management|integrated`',
    `maximum_maturity_days` BIGINT COMMENT 'Maximum allowable maturity in days for short-term liquidity instruments under this treasury mandate, ensuring alignment with liquidity requirements.',
    `minimum_credit_rating` STRING COMMENT 'Minimum Investment Grade (IG) credit rating required for counterparties and issuers of short-term instruments, as per rating agency standards.. Valid values are `AAA|AA+|AA|AA-|A+|A|A-`',
    `minimum_liquidity_threshold_amount` DECIMAL(18,2) COMMENT 'Minimum cash position amount that must be maintained across all treasury accounts to meet operational and capital call funding requirements, denominated in base currency.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next Investment Committee (IC) review of this treasury mandate policy.',
    `notes` STRING COMMENT 'Free-text field for additional context, special conditions, or operational guidance related to this treasury mandate policy.',
    `permitted_instrument_types` STRING COMMENT 'Comma-separated list of short-term investment instruments authorized under this mandate, such as Treasury Bills (T-Bills), Secured Overnight Financing Rate (SOFR) linked instruments, commercial paper, and money market funds.',
    `rebalance_frequency` STRING COMMENT 'Scheduled frequency for reviewing and rebalancing Foreign Exchange (FX) hedge positions and liquidity allocations under this mandate.. Valid values are `daily|weekly|monthly|quarterly|event_driven`',
    `regulatory_reporting_required_flag` BOOLEAN COMMENT 'Indicates whether transactions under this mandate require regulatory reporting to the national pension regulator, European Market Infrastructure Regulation (EMIR), or other governing bodies.',
    `review_frequency` STRING COMMENT 'Scheduled frequency for Investment Committee (IC) review and reaffirmation of this treasury mandate policy.. Valid values are `quarterly|semi_annual|annual|biennial`',
    `settlement_cycle` STRING COMMENT 'Standard settlement cycle for treasury transactions, expressed as Trade Date Plus (T+) number of business days.. Valid values are `T+0|T+1|T+2|T+3`',
    `settlement_method` STRING COMMENT 'Standard settlement method for treasury transactions: Delivery Versus Payment (DVP), Free of Payment (FOP), or cash settlement.. Valid values are `DVP|FOP|cash_settlement`',
    `var_limit_1day_95pct_amount` DECIMAL(18,2) COMMENT 'Maximum one-day Value at Risk (VaR) at ninety-five percent confidence level permitted for treasury portfolio, denominated in base currency.',
    `version_number` STRING COMMENT 'Semantic version identifier for the mandate policy, incremented with each Investment Committee (IC) approved revision.. Valid values are `^[0-9]+.[0-9]+$`',
    CONSTRAINT pk_treasury_policy PRIMARY KEY(`treasury_policy_id`)
) COMMENT 'Master record defining the treasury investment mandate and operating parameters approved by the Investment Committee. Captures mandate version, effective date, permitted instrument types, maximum maturity for short-term instruments, counterparty';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`sofr_benchmark` (
    `sofr_benchmark_id` BIGINT COMMENT 'Unique identifier for the SOFR benchmark rate record. Primary key.',
    `superseded_by_sofr_benchmark_id` BIGINT COMMENT 'Reference to the sofr_benchmark_id that supersedes this record if this rate was revised.',
    `administrator_lei` STRING COMMENT '20-character Legal Entity Identifier of the benchmark administrator.. Valid values are `^[A-Z0-9]{20}$`',
    `benchmark_administrator` STRING COMMENT 'Name of the official administrator publishing this rate (Federal Reserve Bank of New York for SOFR).',
    `benchmark_regulation_compliant_flag` BOOLEAN COMMENT 'Indicates whether this rate complies with EU Benchmark Regulation (BMR) and IOSCO Principles for Financial Benchmarks.',
    `business_day_convention` STRING COMMENT 'Convention for adjusting rate dates that fall on non-business days.. Valid values are `following|modified_following|preceding|no_adjustment`',
    `calendar_code` STRING COMMENT 'Three-letter code identifying the business day calendar used (e.g., USD for U.S. Federal Reserve calendar).. Valid values are `^[A-Z]{3}$`',
    `compounding_index` DECIMAL(18,10) COMMENT 'Cumulative compounding index value used for calculating interest on SOFR-linked floating rate instruments.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this rate record was first created in the system.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Automated data quality score (0-100) assessing completeness, timeliness, and consistency of this rate record.',
    `day_count_convention` STRING COMMENT 'The day count convention used for interest accrual calculations with this SOFR rate (typically Actual/360 for SOFR).. Valid values are `actual_360|actual_365|30_360`',
    `index_base_date` DATE COMMENT 'The reference date from which the SOFR compounding index is calculated (typically April 2, 2018).',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this rate record was last updated or modified.',
    `notes` STRING COMMENT 'Free-text field for additional comments, annotations, or context regarding this rate record.',
    `percentile_25th` DECIMAL(12,8) COMMENT 'The 25th percentile rate from the distribution of underlying repo transactions, used for rate dispersion analysis.',
    `percentile_75th` DECIMAL(12,8) COMMENT 'The 75th percentile rate from the distribution of underlying repo transactions, used for rate dispersion analysis.',
    `publication_timestamp` TIMESTAMP COMMENT 'The exact timestamp when the Federal Reserve Bank of New York published this SOFR rate.',
    `rate_date` DATE COMMENT 'The business date for which this SOFR rate is effective and published.',
    `rate_status` STRING COMMENT 'Current lifecycle status of the rate: published (official), preliminary (subject to revision), revised (corrected), final (no further changes), or suspended (not available).. Valid values are `published|preliminary|revised|final|suspended`',
    `rate_type` STRING COMMENT 'Classification of the SOFR rate: overnight spot rate or term/average rate with specific tenor. [ENUM-REF-CANDIDATE: overnight|30day_average|90day_average|180day_average|1month_term|3month_term|6month_term|12month_term — 8 candidates stripped; promote to',
    `rate_value_bps` DECIMAL(12,4) COMMENT 'The SOFR rate expressed in basis points (bps) for precision in spread calculations (e.g., 532.0000 bps for 5.32%).',
    `rate_value_percent` DECIMAL(12,8) COMMENT 'The published SOFR rate expressed as an annualized percentage (e.g., 5.32 for 5.32% per annum).',
    `rate_volatility_bps` DECIMAL(12,4) COMMENT 'Standard deviation or volatility measure of the SOFR rate over the calculation period, expressed in basis points.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this rate is used for regulatory reporting purposes (e.g., EMIR, MiFID II trade reporting).',
    `revision_number` BIGINT COMMENT 'Sequential revision number for this rate date; increments when a rate is corrected or republished (0 for initial publication).',
    `revision_reason` STRING COMMENT 'Explanation for why this rate was revised or republished, if applicable.',
    `source_identifier` STRING COMMENT 'Unique identifier or ticker symbol for this rate in the source system (e.g., SOFRRATE Index in Bloomberg).',
    `transaction_count` BIGINT COMMENT 'Number of individual repo transactions included in the SOFR calculation for this date.',
    `transaction_volume_usd` DECIMAL(18,2) COMMENT 'Total notional volume in USD of overnight Treasury repo transactions used to calculate this SOFR rate.',
    `usage_context` STRING COMMENT 'Description of how this rate is used within the organization (e.g., pricing short-term liquidity instruments, floating rate accrual, treasury portfolio benchmarking).',
    `validation_status` STRING COMMENT 'Status of automated validation checks performed on this rate record.. Valid values are `pending|validated|failed|override`',
    `validation_timestamp` TIMESTAMP COMMENT 'Timestamp when automated validation checks were last performed on this rate record.',
    CONSTRAINT pk_sofr_benchmark PRIMARY KEY(`sofr_benchmark_id`)
) COMMENT 'Reference data for SOFR (Secured Overnight Financing Rate) and related overnight/term benchmark rates used to price SOFR-linked short-term instruments, calculate floating rate accruals, and benchmark treasury portfolio returns.';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`distribution_receipt` (
    `distribution_receipt_id` BIGINT COMMENT 'Unique identifier for the distribution receipt record from private market fund investments.',
    `adjustment_id` BIGINT COMMENT 'Reference to the stored distribution notice or capital account statement document received from the General Partner (GP).',
    `cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: Distribution receipts represent cash inflows into a cash account; linking records the receiving account.',
    `custody_account_id` BIGINT COMMENT 'Reference to the custody cash account (State Street or Northern Trust) into which the distribution was settled.',
    `distribution_notice_document_id` BIGINT COMMENT 'Reference to the stored distribution notice or capital account statement document received from the General Partner (GP).',
    `distribution_notice_id` BIGINT COMMENT 'Foreign key linking to performance.notice. Business justification: Distribution processing workflow: Treasury receives distributions announced via GP notices. Parallel to existing capital_call_funding→notice link.',
    `employee_id` BIGINT COMMENT 'Reference to the treasury operations user who approved the distribution receipt for posting to the Investment Book of Record (IBOR).',
    `fund_investment_id` BIGINT COMMENT 'Reference to the underlying private market fund investment (private equity, infrastructure, real estate, natural resources) that generated this distribution.',
    `gp_bank_account_id` BIGINT COMMENT 'Foreign key linking to treasury.gp_bank_account. Business justification: Distributions are received from GP bank accounts. Links receipt to source GP account.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the General Partner (GP) legal entity that manages the fund and issued the distribution.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio or mandate to which this distribution is allocated for performance attribution and reporting.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_asset_valuation. Business justification: PE distribution receipts need asset valuation context for IRR/TVPI calculations.',
    `accounting_period` STRING COMMENT 'Accounting period (YYYY-QN for quarterly or YYYY-MM for monthly) to which the distribution is allocated for financial reporting and Net Asset Value (NAV) calculation.. Valid values are `^d{4}-Q[1-4]$|^d{4}-d{2}$`',
    `announcement_date` DATE COMMENT 'Date on which the General Partner (GP) announced or notified the Limited Partner (LP) of the distribution via capital account statement or distribution notice.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the distribution receipt was approved for posting, in ISO 8601 format with timezone.',
    `asset_class` STRING COMMENT 'Primary asset class classification of the fund investment generating the distribution: private equity, infrastructure, real estate, natural resources, or credit.. Valid values are `private_equity|infrastructure|real_estate|natural_resources|credit`',
    `base_currency_amount` DECIMAL(18,2) COMMENT 'Net distribution amount converted to base currency (Base Currency) using the FX rate, for portfolio accounting and Net Asset Value (NAV) calculation.',
    `base_currency_code` STRING COMMENT 'Three-letter ISO 4217 code for the pension funds base reporting currency (typically USD).. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the distribution receipt record was first created in the system, in ISO 8601 format with timezone.',
    `custodian_reference_number` STRING COMMENT 'Unique transaction reference number assigned by the custodian (State Street or Northern Trust) for the distribution settlement.',
    `distribution_amount` DECIMAL(18,2) COMMENT 'Gross distribution amount received in the original distribution currency, before any withholding taxes or fees.',
    `distribution_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code of the distribution amount as paid by the General Partner (GP).. Valid values are `^[A-Z]{3}$`',
    `distribution_reference_number` STRING COMMENT 'External reference number or identifier provided by the General Partner (GP) or fund administrator for this distribution.',
    `distribution_status` STRING COMMENT 'Current lifecycle status of the distribution receipt: announced by GP, pending settlement, received in custody account, reconciled to notice, disputed, or reversed.. Valid values are `announced|pending|received|reconciled|disputed|reversed`',
    `distribution_type` STRING COMMENT 'Classification of the distribution: return of capital (return of Paid-In Capital), realized gain (capital appreciation), income (dividends, interest, rent), recallable (subject to clawback), or other.. Valid values are `return_of_capital|realized_gain|income|recallable|other`',
    `dpi_contribution` DECIMAL(18,6) COMMENT 'Contribution of this distribution to the cumulative Distributions to Paid-In (DPI) multiple for the fund investment, calculated as distribution amount divided by Paid-In Capital (PIC).',
    `fund_administrator_name` STRING COMMENT 'Name of the third-party fund administrator responsible for processing and reporting the distribution (e.g., SS&C, Citco, Apex).',
    `fx_rate` DECIMAL(18,6) COMMENT 'Foreign exchange rate applied to convert the distribution amount from distribution currency to base currency (Base Currency), as of settlement date.',
    `gp_lei` STRING COMMENT '20-character ISO 17442 Legal Entity Identifier (LEI) of the General Partner (GP) for regulatory reporting and counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `income_amount` DECIMAL(18,2) COMMENT 'Portion of the distribution classified as income (dividends, interest, rental income, royalties) from underlying portfolio assets, in base currency.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when the distribution receipt record was last modified or updated, in ISO 8601 format with timezone.',
    `nav_impact_amount` DECIMAL(18,2) COMMENT 'Impact of the distribution on the funds Net Asset Value (NAV), calculated as the base currency amount adjusted for any unrealized gain recognition, in base currency.',
    `net_distribution_amount` DECIMAL(18,2) COMMENT 'Net distribution amount received after deduction of withholding taxes and any GP-deducted fees, in distribution currency.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding the distribution receipt, including any special circumstances, disputes, or reconciliation details.',
    `payment_date` DATE COMMENT 'Scheduled or actual date on which the distribution was paid by the General Partner (GP) to the Limited Partner (LP).',
    `posted_timestamp` TIMESTAMP COMMENT 'Date and time when the distribution receipt was posted to the Investment Book of Record (IBOR) in SimCorp Dimension or Aladdin, in ISO 8601 format with timezone.',
    `processing_status` STRING COMMENT 'Internal processing workflow status: draft entry, pending treasury approval, approved for posting, posted to Investment Book of Record (IBOR), or rejected.. Valid values are `draft|pending_approval|approved|posted|rejected`',
    `realized_gain_amount` DECIMAL(18,2) COMMENT 'Portion of the distribution classified as realized capital gain from asset sales or exits, in base currency.',
    `recallable_amount` DECIMAL(18,2) COMMENT 'Amount of the distribution that is subject to potential recall or clawback by the General Partner (GP), in base currency.',
    `recallable_expiry_date` DATE COMMENT 'Date after which the recallable distribution is no longer subject to clawback, as specified in the Limited Partnership Agreement (LPA).',
    `recallable_flag` BOOLEAN COMMENT 'Indicates whether this distribution is subject to clawback or recall provisions under the Limited Partnership Agreement (LPA), typically for GP carry true-up.',
    `reconciliation_date` DATE COMMENT 'Date on which the distribution was reconciled between the GP notice and custodian receipt, or variance was resolved.',
    `reconciliation_status` STRING COMMENT 'Status of reconciliation between the GP distribution notice and the custodian cash receipt: pending, matched, variance identified, or resolved.. Valid values are `pending|matched|variance|resolved`',
    `reconciliation_variance_amount` DECIMAL(18,2) COMMENT 'Difference between the expected distribution amount per GP notice and the actual amount received in custody, in base currency.',
    `record_date` DATE COMMENT 'Date of record for determining Limited Partner (LP) entitlement to the distribution, as specified in the distribution notice.',
    `return_of_capital_amount` DECIMAL(18,2) COMMENT 'Portion of the distribution classified as return of Paid-In Capital (PIC), reducing the outstanding investment cost basis, in base currency.',
    `settlement_date` DATE COMMENT 'Date on which the distribution cash was settled and received into the custody account, as confirmed by the custodian (State Street or Northern Trust).',
    `withholding_tax_amount` DECIMAL(18,2) COMMENT 'Amount of withholding tax deducted at source by the General Partner (GP) or fund jurisdiction, in distribution currency.',
    `withholding_tax_rate_percent` DECIMAL(5,2) COMMENT 'Percentage rate of withholding tax applied to the distribution, as specified by the fund jurisdiction or applicable tax treaty.',
    CONSTRAINT pk_distribution_receipt PRIMARY KEY(`distribution_receipt_id`)
) COMMENT 'Records of cash distributions received from private market fund investments (private equity, infrastructure, real estate, natural resources) including return of capital, realized gain distributions, income distributions, and recallable distributions.';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`sweep_instruction` (
    `sweep_instruction_id` BIGINT COMMENT 'Unique identifier for the cash sweep instruction record.',
    `bank_account_ssi_id` BIGINT COMMENT 'Reference to the standard settlement instructions template used for this sweep.',
    `custodian_id` BIGINT COMMENT 'Reference to the custodian bank executing the sweep instruction.',
    `employee_id` BIGINT COMMENT 'Reference to the user who approved the sweep instruction for execution.',
    `initiated_by_user_employee_id` BIGINT COMMENT 'Reference to the user who created or initiated the sweep instruction.',
    `legal_entity_id` BIGINT COMMENT 'Reference to the legal entity on whose behalf the sweep instruction is executed.',
    `liquidity_reserve_policy_id` BIGINT COMMENT 'Foreign key linking to treasury.liquidity_reserve_policy. Business justification: Sweep instructions may be governed by liquidity reserve policies. Links sweep to applicable policy.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio associated with the sweep instruction.',
    `source_cash_account_id` BIGINT COMMENT 'Reference to the originating cash account from which funds are swept.',
    `ssi_registry_id` BIGINT COMMENT 'Reference to the standard settlement instructions template used for this sweep.',
    `target_cash_account_id` BIGINT COMMENT 'Reference to the destination cash account or liquidity instrument account receiving swept funds.',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether manual approval is required before sweep execution.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the sweep instruction was approved.',
    `benchmark_rate` DECIMAL(18,2) COMMENT 'Reference benchmark rate for the liquidity instrument, such as SOFR, LIBOR replacement, or central bank rate.',
    `cancellation_reason` STRING COMMENT 'Explanation for why the sweep instruction was cancelled before execution.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the sweep instruction record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code for the swept funds.. Valid values are `^[A-Z]{3}$`',
    `custodian_confirmation_number` STRING COMMENT 'Confirmation reference number provided by the custodian bank for the executed sweep.',
    `executed_timestamp` TIMESTAMP COMMENT 'Date and time when the sweep instruction was executed and funds movement initiated.',
    `execution_time` TIMESTAMP COMMENT 'Scheduled time of day for sweep execution in HH:MM format, applicable for time-based automated sweeps.',
    `failure_reason` STRING COMMENT 'Detailed explanation of why the sweep instruction failed to execute, if applicable.',
    `instruction_date` DATE COMMENT 'Business date when the sweep instruction was created or issued.',
    `instruction_reference_number` STRING COMMENT 'Externally visible unique reference number for the sweep instruction used for tracking and reconciliation.',
    `instruction_status` STRING COMMENT 'Current lifecycle status of the sweep instruction in the workflow from creation through settlement. [ENUM-REF-CANDIDATE: pending|approved|executed|settled|failed|cancelled|rejected — 7 candidates stripped; promote to reference product]',
    `instruction_type` STRING COMMENT 'Classification of the sweep instruction mechanism: automated rule-based, manual one-time, scheduled periodic, threshold-triggered, zero-balance sweep, or target-balance sweep.. Valid values are `automated|manual|scheduled|threshold_triggered|zero_balance|target_balance`',
    `instrument_maturity_date` DATE COMMENT 'Maturity date of the short-term liquidity instrument purchased with swept funds.',
    `interest_rate_bps` DECIMAL(8,4) COMMENT 'Interest rate earned on swept funds expressed in basis points.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when the sweep instruction record was last updated.',
    `lei` STRING COMMENT 'Twenty-character ISO Legal Entity Identifier for the entity executing the sweep.. Valid values are `^[A-Z0-9]{20}$`',
    `liquidity_instrument_type` STRING COMMENT 'Type of short-term liquidity instrument into which excess cash is swept. [ENUM-REF-CANDIDATE: money_market_fund|treasury_bill|commercial_paper|repo|overnight_deposit|term_deposit|sofr_linked — 7 candidates stripped; promote to reference product]',
    `liquidity_tier` STRING COMMENT 'Classification of the liquidity reserve tier to which swept funds are allocated per liquidity management policy.. Valid values are `tier_1|tier_2|tier_3|operational|strategic|emergency`',
    `minimum_sweep_amount` DECIMAL(18,2) COMMENT 'Minimum monetary amount required for a sweep to be executed; sweeps below this threshold are not processed.',
    `notes` STRING COMMENT 'Free-text field for additional comments, special instructions, or operational notes regarding the sweep.',
    `payment_method` STRING COMMENT 'Payment mechanism used to execute the cash sweep between accounts.. Valid values are `wire_transfer|ach|internal_book_transfer|rtgs|swift|fedwire`',
    `payment_reference_number` STRING COMMENT 'Unique reference number assigned by the payment system for the sweep transaction.',
    `reconciliation_date` DATE COMMENT 'Date when the sweep instruction was reconciled against custodian records.',
    `reconciliation_status` STRING COMMENT 'Status of reconciliation between internal sweep records and custodian confirmations.. Valid values are `pending|reconciled|discrepancy|under_review`',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this sweep instruction must be included in regulatory reporting submissions.',
    `settled_timestamp` TIMESTAMP COMMENT 'Date and time when the sweep transaction was settled and funds transfer completed.',
    `settlement_date` DATE COMMENT 'Date when the cash movement is settled and funds are transferred between accounts.',
    `sweep_amount` DECIMAL(18,2) COMMENT 'Monetary amount of cash being swept from the source account to the target account or instrument.',
    `sweep_frequency` STRING COMMENT 'Scheduled frequency at which automated sweep instructions are evaluated and executed.. Valid values are `daily|weekly|monthly|intraday|on_demand|continuous`',
    `sweep_priority` BIGINT COMMENT 'Execution priority ranking for this sweep instruction when multiple sweeps compete for available cash.',
    `target_balance_amount` DECIMAL(18,2) COMMENT 'Desired balance to be maintained in the source account after sweep execution; excess above this level is swept.',
    `threshold_amount` DECIMAL(18,2) COMMENT 'Minimum balance threshold that triggers an automated sweep when exceeded in the source account.',
    `value_date` DATE COMMENT 'Effective date when the swept funds are valued and interest calculations apply.',
    CONSTRAINT pk_sweep_instruction PRIMARY KEY(`sweep_instruction_id`)
) COMMENT 'Automated and manual cash sweep instruction records governing the movement of excess cash from operating accounts into short-term liquidity instruments or between custodian accounts.';

CREATE OR REPLACE TABLE `asset_management`.`treasury`.`gp_bank_account` (
    `gp_bank_account_id` BIGINT COMMENT 'Primary key for gp_bank_account',
    `custodian_id` BIGINT COMMENT 'Identifier of the custodian institution responsible for safekeeping assets in this account.',
    `fund_id` BIGINT COMMENT 'Identifier of the investment fund associated with this bank account for capital management.',
    `gp_entity_id` BIGINT COMMENT 'Identifier of the general partner legal entity that owns or controls this bank account.',
    `cash_account_id` BIGINT COMMENT 'Identifier of the target bank account for automatic cash sweep transfers.',
    `account_closing_date` DATE COMMENT 'Date when the bank account was closed. Null if account remains open.',
    `account_name` STRING COMMENT 'The registered name on the bank account as it appears in the financial institution records.',
    `account_number` STRING COMMENT 'The unique account number assigned by the financial institution to identify this bank account.',
    `account_opening_date` DATE COMMENT 'Date when the bank account was officially opened and became operational.',
    `account_status` STRING COMMENT 'Current operational status of the bank account within treasury management workflows.',
    `account_type` STRING COMMENT 'Classification of the bank account by its primary treasury function within fund operations.',
    `aml_risk_rating` STRING COMMENT 'Risk rating assigned to this account for anti-money laundering compliance purposes.',
    `bank_branch_code` STRING COMMENT 'Routing or sort code identifying the specific branch within the banking network.',
    `bank_branch_name` STRING COMMENT 'Name of the specific branch of the financial institution servicing this account.',
    `bank_contact_email` STRING COMMENT 'Email address for the primary bank contact managing this account relationship.',
    `bank_contact_phone` STRING COMMENT 'Phone number for the primary bank contact managing this account relationship.',
    `bank_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code where the bank account is domiciled.',
    `bank_name` STRING COMMENT 'Legal name of the financial institution where the account is held.',
    `bank_relationship_manager` STRING COMMENT 'Name of the relationship manager at the financial institution servicing this account.',
    `cost_center_code` STRING COMMENT 'Cost center code associated with this bank account for expense allocation.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this bank account record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code indicating the denomination of the bank account.',
    `daily_transaction_limit` DECIMAL(18,2) COMMENT 'Maximum aggregate transaction amount permitted per day on this account.',
    `effective_from_date` DATE COMMENT 'Date from which this bank account record is effective for treasury operations.',
    `effective_to_date` DATE COMMENT 'Date until which this bank account record is effective. Null for currently active records.',
    `gl_account_code` STRING COMMENT 'General ledger account code mapped to this bank account for financial reporting.',
    `iban` STRING COMMENT 'International Bank Account Number used for cross-border transactions and account identification.',
    `interest_rate_basis_points` BIGINT COMMENT 'Interest rate applied to account balances expressed in basis points.',
    `is_capital_call_account` BOOLEAN COMMENT 'Indicates whether this account is designated for receiving capital call contributions from LPs.',
    `is_distribution_account` BOOLEAN COMMENT 'Indicates whether this account is designated for making distributions to limited partners.',
    `is_fx_hedging_account` BOOLEAN COMMENT 'Indicates whether this account is used for foreign exchange hedging transactions.',
    `is_sweep_enabled` BOOLEAN COMMENT 'Indicates whether automatic cash sweep functionality is enabled for liquidity optimization.',
    `kyc_verification_date` DATE COMMENT 'Date when the most recent KYC verification was completed for this account.',
    `last_reconciliation_date` DATE COMMENT 'Date of the most recent bank reconciliation performed for this account.',
    `legal_entity_identifier` STRING COMMENT 'LEI of the legal entity that owns this bank account for regulatory reporting.',
    `minimum_balance_requirement` DECIMAL(18,2) COMMENT 'Minimum balance that must be maintained in the account per banking agreement.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this bank account record was last modified.',
    `notes` STRING COMMENT 'Free-text notes and comments related to this bank account for operational reference.',
    `overdraft_limit` DECIMAL(18,2) COMMENT 'Maximum overdraft facility amount available on this account if applicable.',
    `primary_signatory_name` STRING COMMENT 'Name of the primary authorized signatory for transactions on this bank account.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this account is subject to specific regulatory reporting requirements.',
    `secondary_signatory_name` STRING COMMENT 'Name of the secondary authorized signatory for dual-signature requirements.',
    `signature_threshold_amount` DECIMAL(18,2) COMMENT 'Transaction amount threshold above which dual signatures are required for authorization.',
    `single_transaction_limit` DECIMAL(18,2) COMMENT 'Maximum amount permitted for a single transaction on this account.',
    `sweep_threshold_amount` DECIMAL(18,2) COMMENT 'Balance threshold that triggers automatic sweep transfers to the target account.',
    `swift_bic_code` STRING COMMENT 'SWIFT/BIC code identifying the financial institution holding this account for international wire transfers.',
    `tax_jurisdiction_code` STRING COMMENT 'Code identifying the tax jurisdiction applicable to this bank account.',
    CONSTRAINT pk_gp_bank_account PRIMARY KEY(`gp_bank_account_id`)
) COMMENT 'Master reference table for gp_bank_account. Referenced by gp_bank_account_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`treasury`.`cash_position` ADD CONSTRAINT `fk_treasury_cash_position_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_position` ADD CONSTRAINT `fk_treasury_cash_position_liquidity_reserve_policy_id` FOREIGN KEY (`liquidity_reserve_policy_id`) REFERENCES `asset_management`.`treasury`.`liquidity_reserve_policy`(`liquidity_reserve_policy_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_position` ADD CONSTRAINT `fk_treasury_cash_position_sofr_benchmark_id` FOREIGN KEY (`sofr_benchmark_id`) REFERENCES `asset_management`.`treasury`.`sofr_benchmark`(`sofr_benchmark_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_account` ADD CONSTRAINT `fk_treasury_cash_account_bank_account_ssi_id` FOREIGN KEY (`bank_account_ssi_id`) REFERENCES `asset_management`.`treasury`.`bank_account_ssi`(`bank_account_ssi_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_account` ADD CONSTRAINT `fk_treasury_cash_account_ssi_template_bank_account_ssi_id` FOREIGN KEY (`ssi_template_bank_account_ssi_id`) REFERENCES `asset_management`.`treasury`.`bank_account_ssi`(`bank_account_ssi_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_account` ADD CONSTRAINT `fk_treasury_cash_account_sweep_target_account_id` FOREIGN KEY (`sweep_target_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ADD CONSTRAINT `fk_treasury_liquidity_forecast_liquidity_reserve_policy_id` FOREIGN KEY (`liquidity_reserve_policy_id`) REFERENCES `asset_management`.`treasury`.`liquidity_reserve_policy`(`liquidity_reserve_policy_id`);
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ADD CONSTRAINT `fk_treasury_liquidity_forecast_superseded_by_forecast_liquidity_forecast_id` FOREIGN KEY (`superseded_by_forecast_liquidity_forecast_id`) REFERENCES `asset_management`.`treasury`.`liquidity_forecast`(`liquidity_forecast_id`);
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ADD CONSTRAINT `fk_treasury_net_contribution_inflow_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ADD CONSTRAINT `fk_treasury_capital_call_funding_bank_account_ssi_id` FOREIGN KEY (`bank_account_ssi_id`) REFERENCES `asset_management`.`treasury`.`bank_account_ssi`(`bank_account_ssi_id`);
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ADD CONSTRAINT `fk_treasury_capital_call_funding_fx_forward_id` FOREIGN KEY (`fx_forward_id`) REFERENCES `asset_management`.`treasury`.`fx_forward`(`fx_forward_id`);
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ADD CONSTRAINT `fk_treasury_capital_call_funding_gp_bank_account_id` FOREIGN KEY (`gp_bank_account_id`) REFERENCES `asset_management`.`treasury`.`gp_bank_account`(`gp_bank_account_id`);
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ADD CONSTRAINT `fk_treasury_capital_call_funding_source_cash_account_id` FOREIGN KEY (`source_cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_position` ADD CONSTRAINT `fk_treasury_fx_position_hedge_program_id` FOREIGN KEY (`hedge_program_id`) REFERENCES `asset_management`.`treasury`.`hedge_program`(`hedge_program_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ADD CONSTRAINT `fk_treasury_fx_forward_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ADD CONSTRAINT `fk_treasury_fx_forward_fx_position_id` FOREIGN KEY (`fx_position_id`) REFERENCES `asset_management`.`treasury`.`fx_position`(`fx_position_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ADD CONSTRAINT `fk_treasury_fx_forward_hedge_program_id` FOREIGN KEY (`hedge_program_id`) REFERENCES `asset_management`.`treasury`.`hedge_program`(`hedge_program_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ADD CONSTRAINT `fk_treasury_fx_forward_treasury_fx_rate_id` FOREIGN KEY (`treasury_fx_rate_id`) REFERENCES `asset_management`.`treasury`.`treasury_fx_rate`(`treasury_fx_rate_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ADD CONSTRAINT `fk_treasury_fx_swap_fx_position_id` FOREIGN KEY (`fx_position_id`) REFERENCES `asset_management`.`treasury`.`fx_position`(`fx_position_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ADD CONSTRAINT `fk_treasury_fx_swap_hedge_program_id` FOREIGN KEY (`hedge_program_id`) REFERENCES `asset_management`.`treasury`.`hedge_program`(`hedge_program_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ADD CONSTRAINT `fk_treasury_fx_swap_treasury_fx_rate_id` FOREIGN KEY (`treasury_fx_rate_id`) REFERENCES `asset_management`.`treasury`.`treasury_fx_rate`(`treasury_fx_rate_id`);
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ADD CONSTRAINT `fk_treasury_hedge_effectiveness_hedge_program_id` FOREIGN KEY (`hedge_program_id`) REFERENCES `asset_management`.`treasury`.`hedge_program`(`hedge_program_id`);
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ADD CONSTRAINT `fk_treasury_st_instrument_transaction_short_term_instrument_id` FOREIGN KEY (`short_term_instrument_id`) REFERENCES `asset_management`.`treasury`.`short_term_instrument`(`short_term_instrument_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_capital_call_funding_id` FOREIGN KEY (`capital_call_funding_id`) REFERENCES `asset_management`.`treasury`.`capital_call_funding`(`capital_call_funding_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_destination_account_cash_account_id` FOREIGN KEY (`destination_account_cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_distribution_receipt_id` FOREIGN KEY (`distribution_receipt_id`) REFERENCES `asset_management`.`treasury`.`distribution_receipt`(`distribution_receipt_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_fx_forward_id` FOREIGN KEY (`fx_forward_id`) REFERENCES `asset_management`.`treasury`.`fx_forward`(`fx_forward_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_fx_swap_id` FOREIGN KEY (`fx_swap_id`) REFERENCES `asset_management`.`treasury`.`fx_swap`(`fx_swap_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_primary_cash_account_id` FOREIGN KEY (`primary_cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_related_fx_hedge_hedge_program_id` FOREIGN KEY (`related_fx_hedge_hedge_program_id`) REFERENCES `asset_management`.`treasury`.`hedge_program`(`hedge_program_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_reversed_transfer_cash_transfer_id` FOREIGN KEY (`reversed_transfer_cash_transfer_id`) REFERENCES `asset_management`.`treasury`.`cash_transfer`(`cash_transfer_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_treasury_fx_rate_id` FOREIGN KEY (`treasury_fx_rate_id`) REFERENCES `asset_management`.`treasury`.`treasury_fx_rate`(`treasury_fx_rate_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ADD CONSTRAINT `fk_treasury_cash_reconciliation_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ADD CONSTRAINT `fk_treasury_cash_reconciliation_cash_position_id` FOREIGN KEY (`cash_position_id`) REFERENCES `asset_management`.`treasury`.`cash_position`(`cash_position_id`);
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ADD CONSTRAINT `fk_treasury_treasury_fx_rate_superseded_by_rate_treasury_fx_rate_id` FOREIGN KEY (`superseded_by_rate_treasury_fx_rate_id`) REFERENCES `asset_management`.`treasury`.`treasury_fx_rate`(`treasury_fx_rate_id`);
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ADD CONSTRAINT `fk_treasury_treasury_counterparty_exposure_counterparty_limit_id` FOREIGN KEY (`counterparty_limit_id`) REFERENCES `asset_management`.`treasury`.`counterparty_limit`(`counterparty_limit_id`);
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ADD CONSTRAINT `fk_treasury_liquidity_reserve_policy_superseded_by_policy_liquidity_reserve_policy_id` FOREIGN KEY (`superseded_by_policy_liquidity_reserve_policy_id`) REFERENCES `asset_management`.`treasury`.`liquidity_reserve_policy`(`liquidity_reserve_policy_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_capital_call_funding_id` FOREIGN KEY (`capital_call_funding_id`) REFERENCES `asset_management`.`treasury`.`capital_call_funding`(`capital_call_funding_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_distribution_receipt_id` FOREIGN KEY (`distribution_receipt_id`) REFERENCES `asset_management`.`treasury`.`distribution_receipt`(`distribution_receipt_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_fx_forward_id` FOREIGN KEY (`fx_forward_id`) REFERENCES `asset_management`.`treasury`.`fx_forward`(`fx_forward_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_fx_swap_id` FOREIGN KEY (`fx_swap_id`) REFERENCES `asset_management`.`treasury`.`fx_swap`(`fx_swap_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_hedge_program_id` FOREIGN KEY (`hedge_program_id`) REFERENCES `asset_management`.`treasury`.`hedge_program`(`hedge_program_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_liquidity_forecast_id` FOREIGN KEY (`liquidity_forecast_id`) REFERENCES `asset_management`.`treasury`.`liquidity_forecast`(`liquidity_forecast_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_net_contribution_inflow_id` FOREIGN KEY (`net_contribution_inflow_id`) REFERENCES `asset_management`.`treasury`.`net_contribution_inflow`(`net_contribution_inflow_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_short_term_instrument_id` FOREIGN KEY (`short_term_instrument_id`) REFERENCES `asset_management`.`treasury`.`short_term_instrument`(`short_term_instrument_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ADD CONSTRAINT `fk_treasury_fx_hedge_rebalance_fx_position_id` FOREIGN KEY (`fx_position_id`) REFERENCES `asset_management`.`treasury`.`fx_position`(`fx_position_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ADD CONSTRAINT `fk_treasury_fx_hedge_rebalance_hedge_program_id` FOREIGN KEY (`hedge_program_id`) REFERENCES `asset_management`.`treasury`.`hedge_program`(`hedge_program_id`);
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ADD CONSTRAINT `fk_treasury_treasury_policy_superseded_by_mandate_treasury_policy_id` FOREIGN KEY (`superseded_by_mandate_treasury_policy_id`) REFERENCES `asset_management`.`treasury`.`treasury_policy`(`treasury_policy_id`);
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ADD CONSTRAINT `fk_treasury_sofr_benchmark_superseded_by_sofr_benchmark_id` FOREIGN KEY (`superseded_by_sofr_benchmark_id`) REFERENCES `asset_management`.`treasury`.`sofr_benchmark`(`sofr_benchmark_id`);
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ADD CONSTRAINT `fk_treasury_distribution_receipt_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ADD CONSTRAINT `fk_treasury_distribution_receipt_gp_bank_account_id` FOREIGN KEY (`gp_bank_account_id`) REFERENCES `asset_management`.`treasury`.`gp_bank_account`(`gp_bank_account_id`);
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ADD CONSTRAINT `fk_treasury_sweep_instruction_bank_account_ssi_id` FOREIGN KEY (`bank_account_ssi_id`) REFERENCES `asset_management`.`treasury`.`bank_account_ssi`(`bank_account_ssi_id`);
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ADD CONSTRAINT `fk_treasury_sweep_instruction_liquidity_reserve_policy_id` FOREIGN KEY (`liquidity_reserve_policy_id`) REFERENCES `asset_management`.`treasury`.`liquidity_reserve_policy`(`liquidity_reserve_policy_id`);
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ADD CONSTRAINT `fk_treasury_sweep_instruction_source_cash_account_id` FOREIGN KEY (`source_cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ADD CONSTRAINT `fk_treasury_sweep_instruction_target_cash_account_id` FOREIGN KEY (`target_cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` ADD CONSTRAINT `fk_treasury_gp_bank_account_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`treasury`.`cash_position` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`treasury`.`cash_position` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`cash_position` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`cash_position` SET TAGS ('dbx_subdomain' = 'cash_liquidity');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `cash_position_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Position Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Entity Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `infra_fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Infra Fund Commitment Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `liquidity_reserve_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Reserve Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `settlement_instruction_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Settlement Instructions (SSI) Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `sofr_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Sofr Benchmark Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `accrued_interest` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `available_balance` SET TAGS ('dbx_business_glossary_term' = 'Available Balance');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `bank_identifier_code` SET TAGS ('dbx_business_glossary_term' = 'Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `bank_identifier_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `capital_call_pending` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Pending');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `collateral_posted` SET TAGS ('dbx_business_glossary_term' = 'Collateral Posted');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `collateral_received` SET TAGS ('dbx_business_glossary_term' = 'Collateral Received');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `custody_balance` SET TAGS ('dbx_business_glossary_term' = 'Custody Balance');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `distribution_pending` SET TAGS ('dbx_business_glossary_term' = 'Distribution Pending');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `fx_hedge_ratio` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Hedge Ratio');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `interest_rate` SET TAGS ('dbx_business_glossary_term' = 'Interest Rate');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `is_current` SET TAGS ('dbx_business_glossary_term' = 'Is Current Flag');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `last_reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Reconciliation Date');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `ledger_balance` SET TAGS ('dbx_business_glossary_term' = 'Ledger Balance');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `legal_entity_identifier` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `legal_entity_identifier` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `liquidity_tier` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Tier');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `liquidity_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3|restricted');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `net_contribution_inflow` SET TAGS ('dbx_business_glossary_term' = 'Net Contribution Inflow');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Position Notes');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `overdraft_limit` SET TAGS ('dbx_business_glossary_term' = 'Overdraft Limit');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `pending_settlements_inflow` SET TAGS ('dbx_business_glossary_term' = 'Pending Settlements Inflow');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `pending_settlements_outflow` SET TAGS ('dbx_business_glossary_term' = 'Pending Settlements Outflow');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `position_date` SET TAGS ('dbx_business_glossary_term' = 'Position Date');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `position_status` SET TAGS ('dbx_business_glossary_term' = 'Cash Position Status');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `position_status` SET TAGS ('dbx_value_regex' = 'active|inactive|closed|frozen|restricted');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `position_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Position Timestamp');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `projected_balance` SET TAGS ('dbx_business_glossary_term' = 'Projected Balance');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `reconciliation_difference` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Difference');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'reconciled|pending|break|investigating');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `reporting_currency_flag` SET TAGS ('dbx_business_glossary_term' = 'Reporting Currency Flag');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `reserved_amount` SET TAGS ('dbx_business_glossary_term' = 'Reserved Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `sweep_account_flag` SET TAGS ('dbx_business_glossary_term' = 'Sweep Account Flag');
ALTER TABLE `asset_management`.`treasury`.`cash_position` ALTER COLUMN `zero_balance_account_flag` SET TAGS ('dbx_business_glossary_term' = 'Zero Balance Account (ZBA) Flag');
ALTER TABLE `asset_management`.`treasury`.`cash_account` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`treasury`.`cash_account` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`cash_account` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`cash_account` SET TAGS ('dbx_subdomain' = 'cash_liquidity');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Account Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `bank_account_ssi_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Settlement Instructions (SSI) Template Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `bank_account_ssi_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `bank_account_ssi_id` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `csa_agreement_csa_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) Agreement Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `csa_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) Agreement Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `infra_fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Infra Fund Commitment Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `legal_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Mandate Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Asset Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `ssi_template_bank_account_ssi_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Settlement Instructions (SSI) Template Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `sweep_target_account_id` SET TAGS ('dbx_business_glossary_term' = 'Sweep Target Account Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `aba_routing_number` SET TAGS ('dbx_business_glossary_term' = 'American Bankers Association (ABA) Routing Number');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `aba_routing_number` SET TAGS ('dbx_value_regex' = '^[0-9]{9}$');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `aba_routing_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `aba_routing_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_closed_date` SET TAGS ('dbx_business_glossary_term' = 'Account Closed Date');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_manager_email` SET TAGS ('dbx_business_glossary_term' = 'Account Manager Email Address');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_manager_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_manager_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_manager_name` SET TAGS ('dbx_business_glossary_term' = 'Account Manager Name');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_manager_phone` SET TAGS ('dbx_business_glossary_term' = 'Account Manager Phone Number');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_manager_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_name` SET TAGS ('dbx_business_glossary_term' = 'Account Name');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_number` SET TAGS ('dbx_business_glossary_term' = 'Account Number');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_opened_date` SET TAGS ('dbx_business_glossary_term' = 'Account Opened Date');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_ownership` SET TAGS ('dbx_business_glossary_term' = 'Account Ownership');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_ownership` SET TAGS ('dbx_value_regex' = 'internal|external|pooled|segregated');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_purpose` SET TAGS ('dbx_business_glossary_term' = 'Account Purpose');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_status` SET TAGS ('dbx_business_glossary_term' = 'Account Status');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|closed|pending_activation|restricted');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_type` SET TAGS ('dbx_business_glossary_term' = 'Account Type');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `account_type` SET TAGS ('dbx_value_regex' = 'settlement|operational|reserve|collateral|margin|sweep');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `balance_reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Balance Reporting Frequency');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `balance_reporting_frequency` SET TAGS ('dbx_value_regex' = 'real_time|daily|weekly|monthly');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `benchmark_rate` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Rate');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `bic_swift_code` SET TAGS ('dbx_business_glossary_term' = 'Bank Identifier Code (BIC) / Society for Worldwide Interbank Financial Telecommunication (SWIFT) Code');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `bic_swift_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `bic_swift_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `bic_swift_code` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `collateral_account_flag` SET TAGS ('dbx_business_glossary_term' = 'Collateral Account Flag');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `correspondent_bank_account_number` SET TAGS ('dbx_business_glossary_term' = 'Correspondent Bank Account Number');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `correspondent_bank_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `correspondent_bank_bic` SET TAGS ('dbx_business_glossary_term' = 'Correspondent Bank Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `correspondent_bank_bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `correspondent_bank_name` SET TAGS ('dbx_business_glossary_term' = 'Correspondent Bank Name');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `iban` SET TAGS ('dbx_business_glossary_term' = 'International Bank Account Number (IBAN)');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `iban` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `interest_bearing_flag` SET TAGS ('dbx_business_glossary_term' = 'Interest Bearing Flag');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `interest_calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Interest Calculation Method');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `interest_calculation_method` SET TAGS ('dbx_value_regex' = 'actual_360|actual_365|30_360|actual_actual');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `interest_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Interest Rate in Basis Points (bps)');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `interest_rate_type` SET TAGS ('dbx_business_glossary_term' = 'Interest Rate Type');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `interest_rate_type` SET TAGS ('dbx_value_regex' = 'fixed|floating|tiered|zero');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `internal_gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'Internal General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `last_activity_date` SET TAGS ('dbx_business_glossary_term' = 'Last Activity Date');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `last_reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Reconciliation Date');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `minimum_balance_requirement` SET TAGS ('dbx_business_glossary_term' = 'Minimum Balance Requirement');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `overdraft_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Overdraft Allowed Flag');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `overdraft_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Overdraft Limit Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `reconciliation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Frequency');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `reconciliation_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `sweep_arrangement_flag` SET TAGS ('dbx_business_glossary_term' = 'Sweep Arrangement Flag');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `sweep_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Sweep Threshold Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_account` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` SET TAGS ('dbx_subdomain' = 'cash_liquidity');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `liquidity_forecast_id` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Forecast Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Prepared By User Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `liability_cash_flow_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Cash Flow Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `liability_projection_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Projection Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `liquidity_reserve_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Reserve Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `liquidity_risk_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Risk Assessment Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `superseded_by_forecast_liquidity_forecast_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Forecast Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `capital_call_funding_amount` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Funding Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `closing_cash_position_amount` SET TAGS ('dbx_business_glossary_term' = 'Closing Cash Position Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `collateral_movement_net_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Movement Net Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `distribution_inflow_amount` SET TAGS ('dbx_business_glossary_term' = 'Distribution Inflow Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `fee_expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Expense Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `forecast_confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Forecast Confidence Level');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `forecast_confidence_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `forecast_date` SET TAGS ('dbx_business_glossary_term' = 'Forecast Date');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `forecast_horizon_end_date` SET TAGS ('dbx_business_glossary_term' = 'Forecast Horizon End Date');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `forecast_horizon_start_date` SET TAGS ('dbx_business_glossary_term' = 'Forecast Horizon Start Date');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `forecast_methodology` SET TAGS ('dbx_business_glossary_term' = 'Forecast Methodology');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `forecast_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Forecast Reference Number');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `forecast_reference_number` SET TAGS ('dbx_value_regex' = '^LF-[0-9]{8}-[A-Z0-9]{6}$');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `forecast_scenario` SET TAGS ('dbx_business_glossary_term' = 'Forecast Scenario');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `forecast_scenario` SET TAGS ('dbx_value_regex' = 'base|optimistic|pessimistic|stress|recovery|custom');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `forecast_status` SET TAGS ('dbx_business_glossary_term' = 'Forecast Status');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `forecast_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|approved|published|superseded|archived');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `forecast_type` SET TAGS ('dbx_business_glossary_term' = 'Forecast Type');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `forecast_type` SET TAGS ('dbx_value_regex' = 'short_term|medium_term|long_term|strategic|tactical|operational');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `fx_hedge_settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Hedge Settlement Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `liquidity_surplus_deficit_amount` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Surplus or Deficit Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `minimum_liquidity_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Liquidity Threshold Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `net_contribution_inflow_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Contribution Inflow Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Forecast Notes');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `opening_cash_position_amount` SET TAGS ('dbx_business_glossary_term' = 'Opening Cash Position Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `operational_expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Operational Expense Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `other_inflow_amount` SET TAGS ('dbx_business_glossary_term' = 'Other Inflow Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `other_outflow_amount` SET TAGS ('dbx_business_glossary_term' = 'Other Outflow Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `published_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Published Timestamp');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `short_term_investment_maturity_amount` SET TAGS ('dbx_business_glossary_term' = 'Short-Term Investment Maturity Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `short_term_investment_purchase_amount` SET TAGS ('dbx_business_glossary_term' = 'Short-Term Investment Purchase Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ALTER COLUMN `trade_settlement_net_amount` SET TAGS ('dbx_business_glossary_term' = 'Trade Settlement Net Amount');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` SET TAGS ('dbx_subdomain' = 'cash_liquidity');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `net_contribution_inflow_id` SET TAGS ('dbx_business_glossary_term' = 'Net Contribution Inflow Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Pool Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `participating_employer_id` SET TAGS ('dbx_business_glossary_term' = 'Employer Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `allocation_date` SET TAGS ('dbx_business_glossary_term' = 'Allocation Date');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `allocation_status` SET TAGS ('dbx_business_glossary_term' = 'Allocation Status');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `allocation_status` SET TAGS ('dbx_value_regex' = 'unallocated|partially_allocated|fully_allocated');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `base_currency_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Amount');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `contribution_date` SET TAGS ('dbx_business_glossary_term' = 'Contribution Date');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `contribution_period_end` SET TAGS ('dbx_business_glossary_term' = 'Contribution Period End Date');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `contribution_period_start` SET TAGS ('dbx_business_glossary_term' = 'Contribution Period Start Date');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `contribution_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Contribution Reference Number');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `contribution_status` SET TAGS ('dbx_business_glossary_term' = 'Contribution Status');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `contribution_status` SET TAGS ('dbx_value_regex' = 'pending|cleared|allocated|reversed|reconciled|disputed');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `contribution_type` SET TAGS ('dbx_business_glossary_term' = 'Contribution Type');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `contribution_type` SET TAGS ('dbx_value_regex' = 'regular|special|buyback|transfer_in|employer_match|voluntary');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `custody_account_number` SET TAGS ('dbx_business_glossary_term' = 'Custody Account Number');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `custody_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `deduction_amount` SET TAGS ('dbx_business_glossary_term' = 'Deduction Amount');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `gross_contribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Contribution Amount');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `liquidity_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Reserve Amount');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `liquidity_reserve_flag` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Reserve Flag');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `member_count` SET TAGS ('dbx_business_glossary_term' = 'Member Count');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `net_contribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Contribution Amount');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Date');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'pending|matched|unmatched|exception');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `remittance_method` SET TAGS ('dbx_business_glossary_term' = 'Remittance Method');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `remittance_method` SET TAGS ('dbx_value_regex' = 'wire|ach|check|direct_debit|electronic_transfer');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `remitting_institution_bic` SET TAGS ('dbx_business_glossary_term' = 'Remitting Institution Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `remitting_institution_bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `remitting_institution_name` SET TAGS ('dbx_business_glossary_term' = 'Remitting Institution Name');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ALTER COLUMN `value_date` SET TAGS ('dbx_business_glossary_term' = 'Value Date');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` SET TAGS ('dbx_subdomain' = 'cash_liquidity');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `capital_call_funding_id` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Funding ID');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `adjustment_id` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Document ID');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `bank_account_ssi_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Bank Account ID');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `bank_account_ssi_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `bank_account_ssi_id` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `confirmation_document_id` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Document ID');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Dd Engagement Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approver User ID');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `fund_investment_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Investment ID');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `fx_forward_id` SET TAGS ('dbx_business_glossary_term' = 'Fx Forward Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `fx_hedge_instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Hedge Instrument ID');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `gp_bank_account_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Bank Account ID');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `gp_bank_account_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `gp_bank_account_id` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `infra_fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Infra Fund Commitment Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `source_cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Source Cash Account ID');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `approval_workflow_reference` SET TAGS ('dbx_business_glossary_term' = 'Approval Workflow ID');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `call_amount_requested` SET TAGS ('dbx_business_glossary_term' = 'Call Amount Requested');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `call_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Call Currency Code');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `call_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `call_due_date` SET TAGS ('dbx_business_glossary_term' = 'Call Due Date');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `call_notice_date` SET TAGS ('dbx_business_glossary_term' = 'Call Notice Date');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `call_notice_number` SET TAGS ('dbx_business_glossary_term' = 'Call Notice Number');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `call_purpose_description` SET TAGS ('dbx_business_glossary_term' = 'Call Purpose Description');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `call_type` SET TAGS ('dbx_business_glossary_term' = 'Call Type');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `call_type` SET TAGS ('dbx_value_regex' = 'investment|management_fee|organizational_expense|other');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `commitment_percentage_called` SET TAGS ('dbx_business_glossary_term' = 'Commitment Percentage Called');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `custodian_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Custodian Reference Number');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `default_interest_rate` SET TAGS ('dbx_business_glossary_term' = 'Default Interest Rate');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `funding_amount_base_currency` SET TAGS ('dbx_business_glossary_term' = 'Funding Amount Base Currency');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `funding_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Funding Approval Date');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `funding_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Funding Execution Date');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `funding_priority` SET TAGS ('dbx_business_glossary_term' = 'Funding Priority');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `funding_priority` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `funding_settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Funding Settlement Date');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `funding_status` SET TAGS ('dbx_business_glossary_term' = 'Funding Status');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `funding_status` SET TAGS ('dbx_value_regex' = 'pending|approved|funded|partially_funded|rejected|cancelled');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `fx_hedge_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Hedge Applied Flag');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `gp_account_number` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Account Number');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `gp_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `gp_bank_name` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Bank Name');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `gp_swift_bic_code` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) SWIFT Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `gp_swift_bic_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `gp_swift_bic_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `gp_swift_bic_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `late_payment_penalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Late Payment Penalty Amount');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `liquidity_source` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Source');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `liquidity_source` SET TAGS ('dbx_value_regex' = 'cash_on_hand|liquidated_securities|short_term_borrowing|net_contributions');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|ach|swift|sepa|internal_transfer');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Date');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'pending|reconciled|discrepancy|under_review');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason');
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_position` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`treasury`.`fx_position` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`fx_position` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`fx_position` SET TAGS ('dbx_subdomain' = 'currency_hedging');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `fx_position_id` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Position Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `hedge_program_id` SET TAGS ('dbx_business_glossary_term' = 'Hedge Program Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `base_currency` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `base_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `collateral_posted_base` SET TAGS ('dbx_business_glossary_term' = 'Collateral Posted in Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `collateral_received_base` SET TAGS ('dbx_business_glossary_term' = 'Collateral Received in Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Position Comments');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `counterparty_concentration_pct` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Concentration Percentage');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `currency_pair` SET TAGS ('dbx_business_glossary_term' = 'Currency Pair');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `currency_pair` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}/[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `data_source_system` SET TAGS ('dbx_value_regex' = 'simcorp|aladdin|state_street|northern_trust|bloomberg|manual');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `dv01_base` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of 01 (DV01) in Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `forward_hedge_notional_base` SET TAGS ('dbx_business_glossary_term' = 'Forward Hedge Notional in Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `hedge_designation` SET TAGS ('dbx_business_glossary_term' = 'Hedge Designation Type');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `hedge_designation` SET TAGS ('dbx_value_regex' = 'cash_flow_hedge|fair_value_hedge|net_investment_hedge|economic_hedge|not_designated');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `hedge_effectiveness_ratio` SET TAGS ('dbx_business_glossary_term' = 'Hedge Effectiveness Ratio');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `hedge_ratio_actual` SET TAGS ('dbx_business_glossary_term' = 'Actual Hedge Ratio');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `hedge_ratio_target` SET TAGS ('dbx_business_glossary_term' = 'Target Hedge Ratio');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `hedge_ratio_variance` SET TAGS ('dbx_business_glossary_term' = 'Hedge Ratio Variance');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `last_rebalance_date` SET TAGS ('dbx_business_glossary_term' = 'Last Rebalance Date');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `mtm_value_base` SET TAGS ('dbx_business_glossary_term' = 'Mark-to-Market (MTM) Value in Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `net_open_exposure_base` SET TAGS ('dbx_business_glossary_term' = 'Net Open Exposure in Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `next_scheduled_rebalance_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Rebalance Date');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `option_hedge_notional_base` SET TAGS ('dbx_business_glossary_term' = 'Option Hedge Notional in Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `position_date` SET TAGS ('dbx_business_glossary_term' = 'Position Date');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `position_owner` SET TAGS ('dbx_business_glossary_term' = 'Position Owner');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `position_status` SET TAGS ('dbx_business_glossary_term' = 'Position Status');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `position_status` SET TAGS ('dbx_value_regex' = 'active|closed|suspended|under_review');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `quote_currency` SET TAGS ('dbx_business_glossary_term' = 'Quote Currency Code');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `quote_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `rebalance_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Rebalance Required Flag');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `rebalance_threshold_breach_date` SET TAGS ('dbx_business_glossary_term' = 'Rebalance Threshold Breach Date');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `spot_exposure_base` SET TAGS ('dbx_business_glossary_term' = 'Spot Exposure in Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `spot_rate` SET TAGS ('dbx_business_glossary_term' = 'Spot Exchange Rate');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `swap_hedge_notional_base` SET TAGS ('dbx_business_glossary_term' = 'Swap Hedge Notional in Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `total_hedge_notional_base` SET TAGS ('dbx_business_glossary_term' = 'Total Hedge Notional in Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `unrealized_pnl_base` SET TAGS ('dbx_business_glossary_term' = 'Unrealized Profit and Loss (P&L) in Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `var_1day_95pct_base` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) 1-Day 95% Confidence in Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_position` ALTER COLUMN `weighted_avg_forward_rate` SET TAGS ('dbx_business_glossary_term' = 'Weighted Average Forward Rate');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` SET TAGS ('dbx_subdomain' = 'currency_hedging');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `fx_forward_id` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Forward Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `csa_agreement_csa_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) Agreement Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `csa_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) Agreement Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `fx_position_id` SET TAGS ('dbx_business_glossary_term' = 'Fx Position Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `hedge_program_id` SET TAGS ('dbx_business_glossary_term' = 'Hedge Program Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `isda_master_agreement_isda_master_id` SET TAGS ('dbx_business_glossary_term' = 'International Swaps and Derivatives Association (ISDA) Master Agreement Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `isda_master_id` SET TAGS ('dbx_business_glossary_term' = 'International Swaps and Derivatives Association (ISDA) Master Agreement Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `netting_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Netting Set Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `netting_set_netting_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Netting Set Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `treasury_fx_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Treasury Fx Rate Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `approval_authority` SET TAGS ('dbx_business_glossary_term' = 'Approval Authority');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `booking_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Booking Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `buy_amount` SET TAGS ('dbx_business_glossary_term' = 'Buy Amount');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `buy_currency` SET TAGS ('dbx_business_glossary_term' = 'Buy Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `buy_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `central_counterparty_name` SET TAGS ('dbx_business_glossary_term' = 'Central Counterparty (CCP) Name');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `clearing_status` SET TAGS ('dbx_business_glossary_term' = 'Clearing Status');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `clearing_status` SET TAGS ('dbx_value_regex' = 'cleared|bilateral|exempt');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `collateral_currency` SET TAGS ('dbx_business_glossary_term' = 'Collateral Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `collateral_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `collateral_posted_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Posted Amount');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `contract_status` SET TAGS ('dbx_business_glossary_term' = 'Contract Status');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `contract_status` SET TAGS ('dbx_value_regex' = 'pending|confirmed|settled|cancelled|expired|amended');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `counterparty_name` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Name');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `custodian_name` SET TAGS ('dbx_business_glossary_term' = 'Custodian Name');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `forward_points` SET TAGS ('dbx_business_glossary_term' = 'Forward Points');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `forward_rate` SET TAGS ('dbx_business_glossary_term' = 'Forward Rate');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `hedge_designation` SET TAGS ('dbx_business_glossary_term' = 'Hedge Designation');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `hedge_designation` SET TAGS ('dbx_value_regex' = 'cash_flow_hedge|fair_value_hedge|net_investment_hedge|economic_hedge|undesignated');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `hedge_effectiveness_test_method` SET TAGS ('dbx_business_glossary_term' = 'Hedge Effectiveness Test Method');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `hedge_ratio` SET TAGS ('dbx_business_glossary_term' = 'Hedge Ratio');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `mark_to_market_value` SET TAGS ('dbx_business_glossary_term' = 'Mark-to-Market (MTM) Value');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `mtm_valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Mark-to-Market (MTM) Valuation Date');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `realized_gain_loss` SET TAGS ('dbx_business_glossary_term' = 'Realized Gain or Loss');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `sell_amount` SET TAGS ('dbx_business_glossary_term' = 'Sell Amount');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `sell_currency` SET TAGS ('dbx_business_glossary_term' = 'Sell Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `sell_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `settlement_account_buy` SET TAGS ('dbx_business_glossary_term' = 'Settlement Account Buy Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `settlement_account_buy` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `settlement_account_sell` SET TAGS ('dbx_business_glossary_term' = 'Settlement Account Sell Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `settlement_account_sell` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'physical_delivery|cash_settlement|net_settlement');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `spot_rate_at_inception` SET TAGS ('dbx_business_glossary_term' = 'Spot Rate at Inception');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `trade_confirmation_date` SET TAGS ('dbx_business_glossary_term' = 'Trade Confirmation Date');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `trade_date` SET TAGS ('dbx_business_glossary_term' = 'Trade Date');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `trade_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Trade Reference Number');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `trading_desk` SET TAGS ('dbx_business_glossary_term' = 'Trading Desk');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `underlying_exposure_type` SET TAGS ('dbx_business_glossary_term' = 'Underlying Exposure Type');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `unique_transaction_identifier` SET TAGS ('dbx_business_glossary_term' = 'Unique Transaction Identifier (UTI)');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `unrealized_gain_loss` SET TAGS ('dbx_business_glossary_term' = 'Unrealized Gain or Loss');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ALTER COLUMN `value_date` SET TAGS ('dbx_business_glossary_term' = 'Value Date');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` SET TAGS ('dbx_subdomain' = 'currency_hedging');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `fx_swap_id` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Swap Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `custody_account_id` SET TAGS ('dbx_business_glossary_term' = 'Custody Account Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `fx_position_id` SET TAGS ('dbx_business_glossary_term' = 'Fx Position Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `hedge_program_id` SET TAGS ('dbx_business_glossary_term' = 'Hedge Program Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `isda_agreement_isda_master_id` SET TAGS ('dbx_business_glossary_term' = 'International Swaps and Derivatives Association (ISDA) Agreement Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `isda_master_id` SET TAGS ('dbx_business_glossary_term' = 'International Swaps and Derivatives Association (ISDA) Agreement Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `treasury_fx_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Treasury Fx Rate Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `accrued_interest_amount` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest Amount');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `ccp_name` SET TAGS ('dbx_business_glossary_term' = 'Central Counterparty (CCP) Name');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `clearing_status` SET TAGS ('dbx_business_glossary_term' = 'Clearing Status');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `clearing_status` SET TAGS ('dbx_value_regex' = 'bilateral|centrally_cleared|exempt');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `confirmation_status` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Status');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `confirmation_status` SET TAGS ('dbx_value_regex' = 'pending|confirmed|disputed|amended');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `confirmation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `csa_applicable_flag` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) Applicable Flag');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `currency_pair` SET TAGS ('dbx_business_glossary_term' = 'Currency Pair');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `currency_pair` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}/[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `execution_venue` SET TAGS ('dbx_business_glossary_term' = 'Execution Venue');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `far_leg_base_amount` SET TAGS ('dbx_business_glossary_term' = 'Far Leg Base Currency Amount');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `far_leg_date` SET TAGS ('dbx_business_glossary_term' = 'Far Leg Settlement Date');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `far_leg_direction` SET TAGS ('dbx_business_glossary_term' = 'Far Leg Direction');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `far_leg_direction` SET TAGS ('dbx_value_regex' = 'buy|sell');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `far_leg_exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Far Leg Exchange Rate');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `far_leg_quote_amount` SET TAGS ('dbx_business_glossary_term' = 'Far Leg Quote Currency Amount');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `far_leg_settlement_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Far Leg Settlement Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `hedge_designation` SET TAGS ('dbx_business_glossary_term' = 'Hedge Designation');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `hedge_designation` SET TAGS ('dbx_value_regex' = 'cash_flow_hedge|fair_value_hedge|net_investment_hedge|economic_hedge|not_designated');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `hedge_ratio` SET TAGS ('dbx_business_glossary_term' = 'Hedge Ratio');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `hedged_item_reference` SET TAGS ('dbx_business_glossary_term' = 'Hedged Item Reference');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `mark_to_market_value` SET TAGS ('dbx_business_glossary_term' = 'Mark-to-Market (MTM) Value');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `mtm_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Mark-to-Market (MTM) Currency Code');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `mtm_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `mtm_valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Mark-to-Market (MTM) Valuation Date');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `near_leg_base_amount` SET TAGS ('dbx_business_glossary_term' = 'Near Leg Base Currency Amount');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `near_leg_date` SET TAGS ('dbx_business_glossary_term' = 'Near Leg Settlement Date');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `near_leg_direction` SET TAGS ('dbx_business_glossary_term' = 'Near Leg Direction');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `near_leg_direction` SET TAGS ('dbx_value_regex' = 'buy|sell');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `near_leg_exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Near Leg Exchange Rate');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `near_leg_quote_amount` SET TAGS ('dbx_business_glossary_term' = 'Near Leg Quote Currency Amount');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `near_leg_settlement_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Near Leg Settlement Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Transaction Notes');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `quote_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Quote Currency Code');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `quote_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `reporting_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'physical_delivery|cash_settlement|netting');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `settlement_status` SET TAGS ('dbx_business_glossary_term' = 'Settlement Status');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `settlement_status` SET TAGS ('dbx_value_regex' = 'pending|near_leg_settled|far_leg_settled|fully_settled|failed');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `swap_points` SET TAGS ('dbx_business_glossary_term' = 'Swap Points');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `swap_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Swap Reference Number');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `swap_status` SET TAGS ('dbx_business_glossary_term' = 'Swap Status');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `swap_status` SET TAGS ('dbx_value_regex' = 'pending|confirmed|settled|cancelled|failed');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `swap_type` SET TAGS ('dbx_business_glossary_term' = 'Swap Type');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `swap_type` SET TAGS ('dbx_value_regex' = 'hedge_roll|liquidity_management|collateral_adjustment|tactical_positioning');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `trade_date` SET TAGS ('dbx_business_glossary_term' = 'Trade Date');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `trade_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Trade Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `trading_desk` SET TAGS ('dbx_business_glossary_term' = 'Trading Desk');
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ALTER COLUMN `unique_transaction_identifier` SET TAGS ('dbx_business_glossary_term' = 'Unique Transaction Identifier (UTI)');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` SET TAGS ('dbx_subdomain' = 'currency_hedging');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `hedge_program_id` SET TAGS ('dbx_business_glossary_term' = 'Hedge Program ID');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User ID');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Esg Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `ldi_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Ldi Strategy Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `var_limit_id` SET TAGS ('dbx_business_glossary_term' = 'Var Limit Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `benchmark_rate` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Rate');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `collateral_posting_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Posting Threshold Amount');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `counterparty_concentration_limit_percent` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Concentration Limit Percentage');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `effectiveness_test_frequency` SET TAGS ('dbx_business_glossary_term' = 'Hedge Effectiveness Test Frequency');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `effectiveness_test_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `esg_alignment_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Alignment Flag');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `hedge_accounting_treatment` SET TAGS ('dbx_business_glossary_term' = 'Hedge Accounting Treatment');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `hedge_accounting_treatment` SET TAGS ('dbx_value_regex' = 'cash_flow_hedge|fair_value_hedge|net_investment_hedge|no_hedge_accounting');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `hedge_accounting_treatment` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `hedge_accounting_treatment` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `hedge_effectiveness_test_method` SET TAGS ('dbx_business_glossary_term' = 'Hedge Effectiveness Test Method');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `hedge_effectiveness_test_method` SET TAGS ('dbx_value_regex' = 'dollar_offset|regression_analysis|variance_reduction|qualitative');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `hedged_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Hedged Currency Code');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `hedged_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `last_effectiveness_test_date` SET TAGS ('dbx_business_glossary_term' = 'Last Effectiveness Test Date');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `last_effectiveness_test_result` SET TAGS ('dbx_business_glossary_term' = 'Last Effectiveness Test Result');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `last_effectiveness_test_result` SET TAGS ('dbx_value_regex' = 'highly_effective|effective|ineffective|not_tested');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `last_rebalance_date` SET TAGS ('dbx_business_glossary_term' = 'Last Rebalance Date');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `maximum_hedge_ratio_percent` SET TAGS ('dbx_business_glossary_term' = 'Maximum Hedge Ratio Percentage');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `maximum_time_to_maturity_days` SET TAGS ('dbx_business_glossary_term' = 'Maximum Time to Maturity Days');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `minimum_hedge_ratio_percent` SET TAGS ('dbx_business_glossary_term' = 'Minimum Hedge Ratio Percentage');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `minimum_time_to_maturity_days` SET TAGS ('dbx_business_glossary_term' = 'Minimum Time to Maturity Days');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `next_scheduled_rebalance_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Rebalance Date');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Program Notes');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `permitted_instruments` SET TAGS ('dbx_business_glossary_term' = 'Permitted Hedging Instruments');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `program_inception_date` SET TAGS ('dbx_business_glossary_term' = 'Program Inception Date');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `program_name` SET TAGS ('dbx_business_glossary_term' = 'Hedge Program Name');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `program_objective` SET TAGS ('dbx_business_glossary_term' = 'Program Objective');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `program_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Hedge Program Reference Code');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `program_reference_code` SET TAGS ('dbx_value_regex' = '^HP-[A-Z]{3}-[0-9]{4}$');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `program_status` SET TAGS ('dbx_business_glossary_term' = 'Hedge Program Status');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `program_status` SET TAGS ('dbx_value_regex' = 'active|suspended|terminated|pending_approval|under_review');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `program_termination_date` SET TAGS ('dbx_business_glossary_term' = 'Program Termination Date');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `program_type` SET TAGS ('dbx_business_glossary_term' = 'Hedge Program Type');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `program_type` SET TAGS ('dbx_value_regex' = 'currency_hedge|interest_rate_hedge|commodity_hedge|multi_asset_hedge');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Frequency');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|event_driven');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `rebalancing_trigger_threshold_bps` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Trigger Threshold Basis Points (bps)');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `regulatory_reporting_requirement` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Requirement');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `risk_limit_var_amount` SET TAGS ('dbx_business_glossary_term' = 'Risk Limit Value at Risk (VaR) Amount');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `roll_strategy` SET TAGS ('dbx_business_glossary_term' = 'Roll Strategy');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `roll_strategy` SET TAGS ('dbx_value_regex' = 'passive_roll|active_roll|dynamic_roll|laddered');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `stress_test_scenario` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Scenario');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `target_hedge_ratio_percent` SET TAGS ('dbx_business_glossary_term' = 'Target Hedge Ratio Percentage');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `var_confidence_level_percent` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Confidence Level Percentage');
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ALTER COLUMN `var_time_horizon_days` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Time Horizon Days');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` SET TAGS ('dbx_subdomain' = 'currency_hedging');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `hedge_effectiveness_id` SET TAGS ('dbx_business_glossary_term' = 'Hedge Effectiveness Assessment ID');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User ID');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Prepared By User ID');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `hedge_program_id` SET TAGS ('dbx_business_glossary_term' = 'Hedge Program ID');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `hedging_instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Hedging Instrument ID');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `ldi_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Ldi Strategy Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `reviewed_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewed By User ID');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `reviewed_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `reviewed_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Assessment Date');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `assessment_methodology_description` SET TAGS ('dbx_business_glossary_term' = 'Assessment Methodology Description');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `assessment_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Assessment Period End Date');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `assessment_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Assessment Period Start Date');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `assessment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Assessment Reference Number');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'Assessment Status');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|approved|rejected|superseded');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `assessment_type` SET TAGS ('dbx_business_glossary_term' = 'Assessment Type');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `assessment_type` SET TAGS ('dbx_value_regex' = 'prospective|retrospective|combined');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `critical_terms_match_flag` SET TAGS ('dbx_business_glossary_term' = 'Critical Terms Match Flag');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `discontinuation_date` SET TAGS ('dbx_business_glossary_term' = 'Discontinuation Date');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `discontinuation_flag` SET TAGS ('dbx_business_glossary_term' = 'Discontinuation Flag');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `discontinuation_reason` SET TAGS ('dbx_business_glossary_term' = 'Discontinuation Reason');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `dollar_offset_ratio` SET TAGS ('dbx_business_glossary_term' = 'Dollar Offset Ratio');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `effectiveness_ratio` SET TAGS ('dbx_business_glossary_term' = 'Effectiveness Ratio');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `external_auditor_reviewed_flag` SET TAGS ('dbx_business_glossary_term' = 'External Auditor Reviewed Flag');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `hedge_accounting_model` SET TAGS ('dbx_business_glossary_term' = 'Hedge Accounting Model');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `hedge_accounting_model` SET TAGS ('dbx_value_regex' = 'fair_value_hedge|cash_flow_hedge|net_investment_hedge');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `hedge_ratio` SET TAGS ('dbx_business_glossary_term' = 'Hedge Ratio');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `hedge_relationship_designation_date` SET TAGS ('dbx_business_glossary_term' = 'Hedge Relationship Designation Date');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `hedged_item_fair_value_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Hedged Item Fair Value Change Amount');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `hedged_item_reference` SET TAGS ('dbx_business_glossary_term' = 'Hedged Item ID');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `hedged_item_type` SET TAGS ('dbx_business_glossary_term' = 'Hedged Item Type');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `hedged_item_type` SET TAGS ('dbx_value_regex' = 'fx_exposure|interest_rate_exposure|commodity_exposure|equity_exposure|credit_exposure|other');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `hedging_instrument_fair_value_change_amount` SET TAGS ('dbx_business_glossary_term' = 'Hedging Instrument Fair Value Change Amount');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `hedging_instrument_type` SET TAGS ('dbx_business_glossary_term' = 'Hedging Instrument Type');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `hedging_instrument_type` SET TAGS ('dbx_value_regex' = 'fx_forward|fx_swap|fx_option|interest_rate_swap|cross_currency_swap|other');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `ineffectiveness_amount` SET TAGS ('dbx_business_glossary_term' = 'Ineffectiveness Amount');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `next_assessment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Assessment Due Date');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Assessment Notes');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `prospective_effectiveness_result` SET TAGS ('dbx_business_glossary_term' = 'Prospective Effectiveness Result');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `prospective_effectiveness_result` SET TAGS ('dbx_value_regex' = 'highly_effective|not_highly_effective|not_assessed');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `prospective_test_method` SET TAGS ('dbx_business_glossary_term' = 'Prospective Test Method');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `prospective_test_method` SET TAGS ('dbx_value_regex' = 'regression_analysis|dollar_offset|scenario_analysis|var_reduction|qualitative');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `rebalancing_date` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Date');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `rebalancing_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Required Flag');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `regression_r_squared` SET TAGS ('dbx_business_glossary_term' = 'Regression R-Squared');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `regression_slope` SET TAGS ('dbx_business_glossary_term' = 'Regression Slope');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `retrospective_effectiveness_result` SET TAGS ('dbx_business_glossary_term' = 'Retrospective Effectiveness Result');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `retrospective_effectiveness_result` SET TAGS ('dbx_value_regex' = 'highly_effective|not_highly_effective|not_assessed');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `retrospective_test_method` SET TAGS ('dbx_business_glossary_term' = 'Retrospective Test Method');
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ALTER COLUMN `retrospective_test_method` SET TAGS ('dbx_value_regex' = 'regression_analysis|dollar_offset|cumulative_dollar_offset|variance_reduction|qualitative');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` SET TAGS ('dbx_subdomain' = 'investment_counterparty');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `short_term_instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Short-Term Instrument ID');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `approval_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approval User ID');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `approval_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `approval_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader User ID');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `issuer_esg_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer Esg Rating Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `accrued_interest_amount` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest Amount');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `benchmark_rate_type` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Rate Type');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `benchmark_rate_type` SET TAGS ('dbx_value_regex' = 'sofr|libor|euribor|sonia|fixed');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `bloomberg_ticker` SET TAGS ('dbx_business_glossary_term' = 'Bloomberg Ticker');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `collateral_flag` SET TAGS ('dbx_business_glossary_term' = 'Collateral Flag');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `coupon_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Coupon Rate Percent');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `current_market_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Current Market Value Amount');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[0-9A-Z]{5}[0-9]$');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `custodian_account_number` SET TAGS ('dbx_business_glossary_term' = 'Custodian Account Number');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `custodian_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `custodian_name` SET TAGS ('dbx_business_glossary_term' = 'Custodian Name');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `days_to_maturity` SET TAGS ('dbx_business_glossary_term' = 'Days to Maturity');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `discount_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate Percent');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `esg_compliant_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Compliant Flag');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `face_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Face Value Amount');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `instrument_credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Instrument Credit Rating');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `instrument_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Instrument Reference Number');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `instrument_status` SET TAGS ('dbx_business_glossary_term' = 'Instrument Status');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `instrument_status` SET TAGS ('dbx_value_regex' = 'active|matured|sold|cancelled|pending_settlement');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `instrument_type` SET TAGS ('dbx_business_glossary_term' = 'Instrument Type');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'Issue Date');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `issuer_credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Issuer Credit Rating');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Name');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `liquidity_tier` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Tier');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `liquidity_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `portfolio_allocation_strategy` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Allocation Strategy');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `portfolio_allocation_strategy` SET TAGS ('dbx_value_regex' = 'liquidity_reserve|cash_management|collateral_buffer|yield_enhancement');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `purchase_date` SET TAGS ('dbx_business_glossary_term' = 'Purchase Date');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `purchase_price_amount` SET TAGS ('dbx_business_glossary_term' = 'Purchase Price Amount');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Quantity');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9BCDFGHJKLMNPQRSTVWXYZ]{7}$');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `spread_over_benchmark_bps` SET TAGS ('dbx_business_glossary_term' = 'Spread Over Benchmark Basis Points (bps)');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `trade_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Trade Reference Number');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `unrealized_gain_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Unrealized Gain Loss Amount');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `valuation_source` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source');
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ALTER COLUMN `yield_to_maturity_percent` SET TAGS ('dbx_business_glossary_term' = 'Yield to Maturity (YTM) Percent');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` SET TAGS ('dbx_subdomain' = 'investment_counterparty');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `st_instrument_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Short-Term (ST) Instrument Transaction Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `broker_id` SET TAGS ('dbx_business_glossary_term' = 'Broker Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `short_term_instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Short Term Instrument Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `accrued_interest_amount` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest Amount');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `actual_settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Settlement Date');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `booking_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Booking Timestamp');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `confirmation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Timestamp');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `consideration_amount` SET TAGS ('dbx_business_glossary_term' = 'Consideration Amount');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP) Code');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[0-9A-Z]{5}[0-9]$');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `custodian_account_number` SET TAGS ('dbx_business_glossary_term' = 'Custodian Account Number');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `custodian_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `custodian_name` SET TAGS ('dbx_business_glossary_term' = 'Custodian Name');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `days_to_maturity` SET TAGS ('dbx_business_glossary_term' = 'Days to Maturity');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `discount_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate Percentage');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `external_transaction_reference` SET TAGS ('dbx_business_glossary_term' = 'External Transaction Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `face_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Face Value Amount');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[0-9A-Z]{9}[0-9]$');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `net_settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Settlement Amount');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `portfolio_code` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Code');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Quantity');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `settlement_location` SET TAGS ('dbx_business_glossary_term' = 'Settlement Location');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'dvp|fop|rvp');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `strategy_code` SET TAGS ('dbx_business_glossary_term' = 'Strategy Code');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `trade_date` SET TAGS ('dbx_business_glossary_term' = 'Trade Date');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `transaction_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Transaction Fee Amount');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `transaction_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Transaction Reference Number');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_business_glossary_term' = 'Transaction Status');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_value_regex' = 'pending|confirmed|settled|cancelled|failed');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Transaction Type');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'purchase|sale|maturity|rollover|redemption|interest_payment');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `unit_price` SET TAGS ('dbx_business_glossary_term' = 'Unit Price');
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ALTER COLUMN `yield_to_maturity_percent` SET TAGS ('dbx_business_glossary_term' = 'Yield to Maturity (YTM) Percentage');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` SET TAGS ('dbx_subdomain' = 'cash_liquidity');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `cash_transfer_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Transfer ID');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `capital_call_funding_id` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Funding Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `destination_account_cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Destination Account ID');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `destination_custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Destination Custodian ID');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `distribution_receipt_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Receipt Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User ID');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `fx_forward_id` SET TAGS ('dbx_business_glossary_term' = 'Fx Forward Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `fx_swap_id` SET TAGS ('dbx_business_glossary_term' = 'Fx Swap Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `initiated_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Initiated By User ID');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `initiated_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `initiated_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `margin_call_id` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `pe_investment_id` SET TAGS ('dbx_business_glossary_term' = 'Related Investment ID');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `primary_cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Source Account ID');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `related_fx_hedge_hedge_program_id` SET TAGS ('dbx_business_glossary_term' = 'Related Foreign Exchange (FX) Hedge ID');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `related_trade_blotter_id` SET TAGS ('dbx_business_glossary_term' = 'Related Trade ID');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `reversed_transfer_cash_transfer_id` SET TAGS ('dbx_business_glossary_term' = 'Reversed Transfer ID');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `source_custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Source Custodian ID');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `standing_settlement_instruction_id` SET TAGS ('dbx_business_glossary_term' = 'Ssi Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `treasury_fx_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Treasury Fx Rate Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `destination_account_number` SET TAGS ('dbx_business_glossary_term' = 'Destination Account Number');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `destination_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `destination_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Destination Currency Code');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `destination_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `failure_reason` SET TAGS ('dbx_business_glossary_term' = 'Failure Reason');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `initiation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Initiation Timestamp');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `intermediary_bank_bic` SET TAGS ('dbx_business_glossary_term' = 'Intermediary Bank Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `intermediary_bank_bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `intermediary_bank_name` SET TAGS ('dbx_business_glossary_term' = 'Intermediary Bank Name');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `net_transfer_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Transfer Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `payment_channel` SET TAGS ('dbx_business_glossary_term' = 'Payment Channel');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `payment_channel` SET TAGS ('dbx_value_regex' = 'custody_platform|treasury_workstation|banking_portal|manual');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire|ach|swift|sepa|internal_book|check');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Priority Level');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'standard|urgent|same_day|next_day');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `purpose_description` SET TAGS ('dbx_business_glossary_term' = 'Purpose Description');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `remittance_information` SET TAGS ('dbx_business_glossary_term' = 'Remittance Information');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `reversal_reason` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `settlement_confirmation_number` SET TAGS ('dbx_business_glossary_term' = 'Settlement Confirmation Number');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `source_account_number` SET TAGS ('dbx_business_glossary_term' = 'Source Account Number');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `source_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `source_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Source Currency Code');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `source_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `transfer_amount` SET TAGS ('dbx_business_glossary_term' = 'Transfer Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `transfer_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Transfer Currency Code');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `transfer_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `transfer_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Transfer Reference Number');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `transfer_status` SET TAGS ('dbx_business_glossary_term' = 'Transfer Status');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `transfer_type` SET TAGS ('dbx_business_glossary_term' = 'Transfer Type');
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ALTER COLUMN `value_date` SET TAGS ('dbx_business_glossary_term' = 'Value Date');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` SET TAGS ('dbx_subdomain' = 'cash_liquidity');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `cash_reconciliation_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Reconciliation ID');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User ID');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Account ID');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `cash_position_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Position Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian ID');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Prepared By User ID');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `reviewed_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewed By User ID');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `reviewed_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `reviewed_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `auto_reconciled_flag` SET TAGS ('dbx_business_glossary_term' = 'Auto Reconciled Flag');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `closing_balance_variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Closing Balance Variance Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `custodian_closing_balance_amount` SET TAGS ('dbx_business_glossary_term' = 'Custodian Closing Balance Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `custodian_file_received_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Custodian File Received Timestamp');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `custodian_opening_balance_amount` SET TAGS ('dbx_business_glossary_term' = 'Custodian Opening Balance Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `custodian_statement_date` SET TAGS ('dbx_business_glossary_term' = 'Custodian Statement Date');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `custodian_statement_reference` SET TAGS ('dbx_business_glossary_term' = 'Custodian Statement Reference');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `custodian_transaction_count` SET TAGS ('dbx_business_glossary_term' = 'Custodian Transaction Count');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `escalation_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Escalation Required Flag');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `fee_difference_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Difference Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `fx_revaluation_difference_amount` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Revaluation Difference Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `ibor_closing_balance_amount` SET TAGS ('dbx_business_glossary_term' = 'Investment Book of Record (IBOR) Closing Balance Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `ibor_extract_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Investment Book of Record (IBOR) Extract Timestamp');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `ibor_opening_balance_amount` SET TAGS ('dbx_business_glossary_term' = 'Investment Book of Record (IBOR) Opening Balance Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `ibor_transaction_count` SET TAGS ('dbx_business_glossary_term' = 'Investment Book of Record (IBOR) Transaction Count');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `interest_accrual_difference_amount` SET TAGS ('dbx_business_glossary_term' = 'Interest Accrual Difference Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `manual_adjustment_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Manual Adjustment Required Flag');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `matched_transaction_amount` SET TAGS ('dbx_business_glossary_term' = 'Matched Transaction Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `matched_transaction_count` SET TAGS ('dbx_business_glossary_term' = 'Matched Transaction Count');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `opening_balance_variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Opening Balance Variance Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Date');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `reconciliation_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Reference Number');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `reconciliation_run_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Run Timestamp');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `reconciliation_type` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Type');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `reconciliation_type` SET TAGS ('dbx_value_regex' = 'daily|intraday|month_end|quarter_end|year_end|ad_hoc');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `resolution_notes` SET TAGS ('dbx_business_glossary_term' = 'Resolution Notes');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `settlement_difference_amount` SET TAGS ('dbx_business_glossary_term' = 'Settlement Difference Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `timing_difference_amount` SET TAGS ('dbx_business_glossary_term' = 'Timing Difference Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `tolerance_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Tolerance Threshold Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `tolerance_threshold_bps` SET TAGS ('dbx_business_glossary_term' = 'Tolerance Threshold Basis Points (bps)');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `unexplained_variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Unexplained Variance Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `unmatched_custodian_transaction_amount` SET TAGS ('dbx_business_glossary_term' = 'Unmatched Custodian Transaction Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `unmatched_custodian_transaction_count` SET TAGS ('dbx_business_glossary_term' = 'Unmatched Custodian Transaction Count');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `unmatched_ibor_transaction_amount` SET TAGS ('dbx_business_glossary_term' = 'Unmatched Investment Book of Record (IBOR) Transaction Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `unmatched_ibor_transaction_count` SET TAGS ('dbx_business_glossary_term' = 'Unmatched Investment Book of Record (IBOR) Transaction Count');
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ALTER COLUMN `within_tolerance_flag` SET TAGS ('dbx_business_glossary_term' = 'Within Tolerance Flag');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` SET TAGS ('dbx_subdomain' = 'currency_hedging');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `treasury_fx_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Treasury Foreign Exchange (FX) Rate Identifier');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `superseded_by_rate_treasury_fx_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Superseding Rate Identifier');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `bid_ask_spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Bid-Ask Spread in Basis Points (bps)');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `cross_rate_flag` SET TAGS ('dbx_business_glossary_term' = 'Cross Rate Calculation Flag');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `currency_pair` SET TAGS ('dbx_business_glossary_term' = 'Currency Pair');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `currency_pair` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}/[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `effective_end_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Rate Effective End Timestamp');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `effective_start_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Rate Effective Start Timestamp');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `fixing_time` SET TAGS ('dbx_business_glossary_term' = 'Rate Fixing Time');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `forward_points_1m` SET TAGS ('dbx_business_glossary_term' = 'Forward Points One Month (1M) Tenor');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `forward_points_1w` SET TAGS ('dbx_business_glossary_term' = 'Forward Points One Week (1W) Tenor');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `forward_points_1y` SET TAGS ('dbx_business_glossary_term' = 'Forward Points One Year (1Y) Tenor');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `forward_points_3m` SET TAGS ('dbx_business_glossary_term' = 'Forward Points Three Month (3M) Tenor');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `forward_points_6m` SET TAGS ('dbx_business_glossary_term' = 'Forward Points Six Month (6M) Tenor');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `inversion_flag` SET TAGS ('dbx_business_glossary_term' = 'Rate Inversion Flag');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `market_convention` SET TAGS ('dbx_business_glossary_term' = 'Market Quotation Convention');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `market_convention` SET TAGS ('dbx_value_regex' = 'direct|indirect');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Rate Record Notes');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `published_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Rate Publication Timestamp');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `quote_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Quote Currency Code');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `quote_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `rate_date` SET TAGS ('dbx_business_glossary_term' = 'Rate Effective Date');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `rate_quality_flag` SET TAGS ('dbx_business_glossary_term' = 'Rate Data Quality Flag');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `rate_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Rate Reference Code');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `rate_source` SET TAGS ('dbx_business_glossary_term' = 'Rate Source Provider');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `rate_source` SET TAGS ('dbx_value_regex' = 'bloomberg|reuters|ecb|boc|fed|custom');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `rate_source_identifier` SET TAGS ('dbx_business_glossary_term' = 'Rate Source System Identifier');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `rate_status` SET TAGS ('dbx_business_glossary_term' = 'Rate Record Status');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `rate_status` SET TAGS ('dbx_value_regex' = 'active|superseded|preliminary|final|restated');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `rate_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Rate Observation Timestamp');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `rate_type` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate Type');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `rate_type` SET TAGS ('dbx_value_regex' = 'spot|forward|swap|cross');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `received_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Rate Receipt Timestamp');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Approved Flag');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `spot_ask_rate` SET TAGS ('dbx_business_glossary_term' = 'Spot Ask Rate');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `spot_bid_rate` SET TAGS ('dbx_business_glossary_term' = 'Spot Bid Rate');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `spot_mid_rate` SET TAGS ('dbx_business_glossary_term' = 'Spot Mid Rate');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `spot_rate` SET TAGS ('dbx_business_glossary_term' = 'Spot Exchange Rate');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `triangulation_method` SET TAGS ('dbx_business_glossary_term' = 'Cross Rate Triangulation Method');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `usage_context` SET TAGS ('dbx_business_glossary_term' = 'Rate Usage Context');
ALTER TABLE `asset_management`.`treasury`.`treasury_fx_rate` ALTER COLUMN `volatility_30d` SET TAGS ('dbx_business_glossary_term' = 'Thirty Day (30D) Historical Volatility');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` SET TAGS ('dbx_subdomain' = 'investment_counterparty');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `counterparty_limit_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Limit Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `country_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Country Outlook Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `csa_agreement_csa_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) Agreement Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `csa_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) Agreement Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `isda_master_agreement_isda_master_id` SET TAGS ('dbx_business_glossary_term' = 'International Swaps and Derivatives Association (ISDA) Master Agreement Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `isda_master_id` SET TAGS ('dbx_business_glossary_term' = 'International Swaps and Derivatives Association (ISDA) Master Agreement Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `kyc_record_id` SET TAGS ('dbx_business_glossary_term' = 'Kyc Record Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `modified_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Modified By User Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `modified_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `modified_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `risk_limit_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Limit Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `approval_authority_level` SET TAGS ('dbx_business_glossary_term' = 'Approval Authority Level');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `approval_authority_level` SET TAGS ('dbx_value_regex' = 'treasury_officer|senior_treasury_manager|cfo|board');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `available_amount` SET TAGS ('dbx_business_glossary_term' = 'Available Amount');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `bic_swift_code` SET TAGS ('dbx_business_glossary_term' = 'Bank Identifier Code (BIC) / Society for Worldwide Interbank Financial Telecommunication (SWIFT) Code');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `bic_swift_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `bic_swift_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `bic_swift_code` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `breach_action` SET TAGS ('dbx_business_glossary_term' = 'Breach Action');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `breach_action` SET TAGS ('dbx_value_regex' = 'block_new_trades|alert_only|require_approval|reduce_exposure');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `breach_count` SET TAGS ('dbx_business_glossary_term' = 'Breach Count');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `collateral_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Collateral Required Flag');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `concentration_limit_flag` SET TAGS ('dbx_business_glossary_term' = 'Concentration Limit Flag');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `credit_rating_agency` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating Agency');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `credit_rating_agency` SET TAGS ('dbx_value_regex' = 'SP|Moodys|Fitch|DBRS|Internal');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `instrument_scope` SET TAGS ('dbx_business_glossary_term' = 'Instrument Scope');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `internal_risk_classification` SET TAGS ('dbx_business_glossary_term' = 'Internal Risk Classification');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `internal_risk_classification` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `last_breach_date` SET TAGS ('dbx_business_glossary_term' = 'Last Breach Date');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Limit Amount');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `limit_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Limit Currency Code');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `limit_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `limit_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Limit Reference Number');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `limit_status` SET TAGS ('dbx_business_glossary_term' = 'Limit Status');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `limit_status` SET TAGS ('dbx_value_regex' = 'active|suspended|expired|pending_approval|revoked');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `limit_type` SET TAGS ('dbx_business_glossary_term' = 'Limit Type');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `limit_type` SET TAGS ('dbx_value_regex' = 'credit|settlement|pre_settlement|aggregate|intraday|overnight');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `minimum_rating_threshold` SET TAGS ('dbx_business_glossary_term' = 'Minimum Rating Threshold');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|ad_hoc');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `threshold_breach_percentage` SET TAGS ('dbx_business_glossary_term' = 'Threshold Breach Percentage');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `threshold_warning_percentage` SET TAGS ('dbx_business_glossary_term' = 'Threshold Warning Percentage');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `utilization_percentage` SET TAGS ('dbx_business_glossary_term' = 'Utilization Percentage');
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ALTER COLUMN `utilized_amount` SET TAGS ('dbx_business_glossary_term' = 'Utilized Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` SET TAGS ('dbx_subdomain' = 'investment_counterparty');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `treasury_counterparty_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Treasury Counterparty Exposure Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `counterparty_limit_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Limit Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `country_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Country Outlook Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `netting_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Netting Agreement Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `collateral_held_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Held Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `collateral_posted_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Posted Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `counterparty_credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Credit Rating');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `counterparty_type` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Type');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `counterparty_type` SET TAGS ('dbx_value_regex' = 'bank|broker_dealer|central_counterparty|custodian|investment_manager|insurance_company');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `credit_valuation_adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Credit Valuation Adjustment (CVA) Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `csa_agreement_flag` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) Agreement Flag');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `csa_minimum_transfer_amount` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) Minimum Transfer Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `csa_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) Threshold Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `exposure_date` SET TAGS ('dbx_business_glossary_term' = 'Exposure Date');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `exposure_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Exposure Limit Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `exposure_status` SET TAGS ('dbx_business_glossary_term' = 'Exposure Status');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `exposure_status` SET TAGS ('dbx_value_regex' = 'active|suspended|closed|under_review|breach');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `fx_forward_count` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Forward Count');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `fx_swap_count` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Swap Count');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `gross_mtm_exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Mark-to-Market (MTM) Exposure Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `gross_notional_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Notional Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `isda_agreement_date` SET TAGS ('dbx_business_glossary_term' = 'International Swaps and Derivatives Association (ISDA) Agreement Date');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `isda_master_agreement_flag` SET TAGS ('dbx_business_glossary_term' = 'International Swaps and Derivatives Association (ISDA) Master Agreement Flag');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `last_collateral_call_date` SET TAGS ('dbx_business_glossary_term' = 'Last Collateral Call Date');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `last_reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Reconciliation Date');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `limit_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Limit Breach Flag');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `limit_utilization_percentage` SET TAGS ('dbx_business_glossary_term' = 'Limit Utilization Percentage');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `net_credit_exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Credit Exposure Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `net_mtm_exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Mark-to-Market (MTM) Exposure Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `netting_benefit_amount` SET TAGS ('dbx_business_glossary_term' = 'Netting Benefit Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `next_collateral_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Collateral Review Date');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `potential_future_exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Potential Future Exposure (PFE) Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `rating_agency` SET TAGS ('dbx_business_glossary_term' = 'Rating Agency');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `rating_agency` SET TAGS ('dbx_value_regex' = 'SP|Moodys|Fitch|DBRS');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'reconciled|pending|discrepancy|not_required');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `regulatory_capital_charge_amount` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Capital Charge Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `risk_weight_percentage` SET TAGS ('dbx_business_glossary_term' = 'Risk Weight Percentage');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `settlement_risk_flag` SET TAGS ('dbx_business_glossary_term' = 'Settlement Risk Flag');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `short_term_instrument_count` SET TAGS ('dbx_business_glossary_term' = 'Short-Term Instrument Count');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `valuation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Valuation Timestamp');
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ALTER COLUMN `wrong_way_risk_flag` SET TAGS ('dbx_business_glossary_term' = 'Wrong-Way Risk Flag');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` SET TAGS ('dbx_subdomain' = 'cash_liquidity');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `liquidity_reserve_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Reserve Policy Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `funded_status_id` SET TAGS ('dbx_business_glossary_term' = 'Funded Status Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `superseded_by_policy_liquidity_reserve_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Policy Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `approval_authority` SET TAGS ('dbx_business_glossary_term' = 'Approval Authority');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `approval_authority` SET TAGS ('dbx_value_regex' = 'treasury_head|cfo|investment_committee|board');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `capital_call_reserve_percentage` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Reserve Percentage');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `collateral_buffer_percentage` SET TAGS ('dbx_business_glossary_term' = 'Collateral Buffer Percentage');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `distribution_reserve_percentage` SET TAGS ('dbx_business_glossary_term' = 'Distribution Reserve Percentage');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `eligible_instrument_types` SET TAGS ('dbx_business_glossary_term' = 'Eligible Instrument Types');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `escalation_procedure` SET TAGS ('dbx_business_glossary_term' = 'Escalation Procedure');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `escalation_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Escalation Threshold Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `fx_hedge_settlement_reserve_days` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Hedge Settlement Reserve Days');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `liquidity_tier_classification` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Tier Classification');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `liquidity_tier_classification` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `minimum_cash_buffer_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Cash Buffer Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `minimum_cash_buffer_percentage` SET TAGS ('dbx_business_glossary_term' = 'Minimum Cash Buffer Percentage');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `minimum_liquidity_coverage_ratio` SET TAGS ('dbx_business_glossary_term' = 'Minimum Liquidity Coverage Ratio (LCR)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `net_stable_funding_ratio_target` SET TAGS ('dbx_business_glossary_term' = 'Net Stable Funding Ratio (NSFR) Target');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `policy_document_uri` SET TAGS ('dbx_business_glossary_term' = 'Policy Document Uniform Resource Identifier (URI)');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `policy_name` SET TAGS ('dbx_business_glossary_term' = 'Policy Name');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `policy_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Policy Reference Number');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `policy_reference_number` SET TAGS ('dbx_value_regex' = '^LRP-[0-9]{6}$');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `policy_status` SET TAGS ('dbx_business_glossary_term' = 'Policy Status');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `policy_status` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|active|suspended|superseded|retired');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `policy_type` SET TAGS ('dbx_business_glossary_term' = 'Policy Type');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `policy_type` SET TAGS ('dbx_value_regex' = 'strategic|tactical|stress|regulatory|operational|contingency');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Frequency');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|event_driven');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `rebalancing_trigger_threshold_percentage` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Trigger Threshold Percentage');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `regulatory_framework` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Framework');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'quarterly|semi_annual|annual|ad_hoc');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `short_term_instrument_maturity_limit_days` SET TAGS ('dbx_business_glossary_term' = 'Short-Term Instrument Maturity Limit Days');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `stress_liquidity_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Stress Liquidity Threshold Amount');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `stress_scenario_type` SET TAGS ('dbx_business_glossary_term' = 'Stress Scenario Type');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `stress_scenario_type` SET TAGS ('dbx_value_regex' = 'market_downturn|credit_crisis|liquidity_shock|operational_disruption|combined');
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ALTER COLUMN `target_liquidity_coverage_ratio` SET TAGS ('dbx_business_glossary_term' = 'Target Liquidity Coverage Ratio (LCR)');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` SET TAGS ('dbx_subdomain' = 'cash_liquidity');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `cash_flow_event_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Event ID');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `blotter_id` SET TAGS ('dbx_business_glossary_term' = 'Trade ID');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `capital_call_funding_id` SET TAGS ('dbx_business_glossary_term' = 'Capital Call ID');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `privateequity_capital_call_id` SET TAGS ('dbx_business_glossary_term' = 'Capital Call ID');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Account ID');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian ID');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `distribution_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution ID');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `distribution_receipt_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Receipt Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Modified By User ID');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `fx_forward_id` SET TAGS ('dbx_business_glossary_term' = 'Fx Forward Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `fx_swap_id` SET TAGS ('dbx_business_glossary_term' = 'Fx Swap Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `hedge_program_id` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Hedge ID');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `investment_id` SET TAGS ('dbx_business_glossary_term' = 'Investment ID');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `liquidity_forecast_id` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Forecast ID');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security ID');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Mandate Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `margin_call_id` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `net_contribution_inflow_id` SET TAGS ('dbx_business_glossary_term' = 'Net Contribution Inflow Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Asset Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `short_term_instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Short Term Instrument Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `actual_flag` SET TAGS ('dbx_business_glossary_term' = 'Actual Flag');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `base_currency_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `event_date` SET TAGS ('dbx_business_glossary_term' = 'Event Date');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `event_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Event Reference Number');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `event_status` SET TAGS ('dbx_business_glossary_term' = 'Event Status');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `event_status` SET TAGS ('dbx_value_regex' = 'scheduled|confirmed|settled|cancelled|revised');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `event_type` SET TAGS ('dbx_business_glossary_term' = 'Event Type');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `ex_date` SET TAGS ('dbx_business_glossary_term' = 'Ex-Date');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `flow_direction` SET TAGS ('dbx_business_glossary_term' = 'Flow Direction');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `flow_direction` SET TAGS ('dbx_value_regex' = 'inflow|outflow');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `forecast_confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Forecast Confidence Level');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `forecast_confidence_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Amount');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `notification_date` SET TAGS ('dbx_business_glossary_term' = 'Notification Date');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|irregular|one_time');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `payment_type` SET TAGS ('dbx_business_glossary_term' = 'Payment Type');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'pending|matched|unmatched|exception|resolved');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `record_date` SET TAGS ('dbx_business_glossary_term' = 'Record Date');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `source_system_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `value_date` SET TAGS ('dbx_business_glossary_term' = 'Value Date');
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ALTER COLUMN `variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Variance Amount');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` SET TAGS ('dbx_subdomain' = 'investment_counterparty');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `bank_account_ssi_id` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Standard Settlement Instructions (SSI) ID');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `bank_account_ssi_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `bank_account_ssi_id` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User ID');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian ID');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User ID');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `legal_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity ID');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `aba_routing_number` SET TAGS ('dbx_business_glossary_term' = 'American Bankers Association (ABA) Routing Number');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `aba_routing_number` SET TAGS ('dbx_value_regex' = '^[0-9]{9}$');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `aba_routing_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `aba_routing_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `account_name` SET TAGS ('dbx_business_glossary_term' = 'Account Name');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `account_number` SET TAGS ('dbx_business_glossary_term' = 'Account Number');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Address Line 1');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Address Line 2');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_city` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary City');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_country_code` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Country Code');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_name` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Name');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Postal Code');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_state_province` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary State or Province');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_state_province` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `beneficiary_state_province` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `bic_swift_code` SET TAGS ('dbx_business_glossary_term' = 'Bank Identifier Code (BIC) / Society for Worldwide Interbank Financial Telecommunication (SWIFT) Code');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `bic_swift_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `bic_swift_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `bic_swift_code` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `correspondent_bank_account_number` SET TAGS ('dbx_business_glossary_term' = 'Correspondent Bank Account Number');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `correspondent_bank_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `correspondent_bank_bic` SET TAGS ('dbx_business_glossary_term' = 'Correspondent Bank Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `correspondent_bank_bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `correspondent_bank_name` SET TAGS ('dbx_business_glossary_term' = 'Correspondent Bank Name');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `default_ssi_flag` SET TAGS ('dbx_business_glossary_term' = 'Default Standard Settlement Instructions (SSI) Flag');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `iban` SET TAGS ('dbx_business_glossary_term' = 'International Bank Account Number (IBAN)');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `iban` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[0-9]{2}[A-Z0-9]+$');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `iban` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `last_verified_date` SET TAGS ('dbx_business_glossary_term' = 'Last Verified Date');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `market_code` SET TAGS ('dbx_business_glossary_term' = 'Market Code');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `next_verification_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Verification Due Date');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `safekeeping_account_flag` SET TAGS ('dbx_business_glossary_term' = 'Safekeeping Account Flag');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'dvp|rvp|fop|dap|raf');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `settlement_priority` SET TAGS ('dbx_business_glossary_term' = 'Settlement Priority');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `settlement_priority` SET TAGS ('dbx_value_regex' = 'high|normal|low');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `special_instructions` SET TAGS ('dbx_business_glossary_term' = 'Special Instructions');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `ssi_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Standard Settlement Instructions (SSI) Reference Number');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `ssi_status` SET TAGS ('dbx_business_glossary_term' = 'Standard Settlement Instructions (SSI) Status');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `ssi_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|suspended|expired');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `ssi_type` SET TAGS ('dbx_business_glossary_term' = 'Standard Settlement Instructions (SSI) Type');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `ssi_type` SET TAGS ('dbx_value_regex' = 'custody|counterparty|broker|correspondent|internal');
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ALTER COLUMN `verification_frequency_days` SET TAGS ('dbx_business_glossary_term' = 'Verification Frequency Days');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` SET TAGS ('dbx_subdomain' = 'currency_hedging');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `fx_hedge_rebalance_id` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Hedge Rebalance ID');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approver User ID');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `executed_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Executed By User ID');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `executed_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `executed_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `fx_position_id` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Position ID');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `fx_risk_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Fx Risk Exposure Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `fx_trade_id` SET TAGS ('dbx_business_glossary_term' = 'Fx Trade Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `hedge_program_id` SET TAGS ('dbx_business_glossary_term' = 'Hedge Program Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `isda_agreement_isda_master_id` SET TAGS ('dbx_business_glossary_term' = 'International Swaps and Derivatives Association (ISDA) Agreement ID');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `isda_master_id` SET TAGS ('dbx_business_glossary_term' = 'International Swaps and Derivatives Association (ISDA) Agreement ID');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `actual_hedge_ratio_after` SET TAGS ('dbx_business_glossary_term' = 'Actual Hedge Ratio After Rebalancing');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `actual_hedge_ratio_before` SET TAGS ('dbx_business_glossary_term' = 'Actual Hedge Ratio Before Rebalancing');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `base_currency` SET TAGS ('dbx_business_glossary_term' = 'Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `collateral_impact_base` SET TAGS ('dbx_business_glossary_term' = 'Collateral Impact Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `currency_pair` SET TAGS ('dbx_business_glossary_term' = 'Currency Pair');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `execution_date` SET TAGS ('dbx_business_glossary_term' = 'Execution Date');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `execution_rate` SET TAGS ('dbx_business_glossary_term' = 'Execution Rate');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `execution_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Execution Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `existing_hedge_notional_base` SET TAGS ('dbx_business_glossary_term' = 'Existing Hedge Notional Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `exposure_amount_base` SET TAGS ('dbx_business_glossary_term' = 'Exposure Amount Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `forward_points` SET TAGS ('dbx_business_glossary_term' = 'Forward Points');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `hedge_designation` SET TAGS ('dbx_business_glossary_term' = 'Hedge Designation');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `hedge_designation` SET TAGS ('dbx_value_regex' = 'cash_flow|fair_value|net_investment|economic');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `hedge_effectiveness_ratio` SET TAGS ('dbx_business_glossary_term' = 'Hedge Effectiveness Ratio');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `hedge_instrument_type` SET TAGS ('dbx_business_glossary_term' = 'Hedge Instrument Type');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `hedge_instrument_type` SET TAGS ('dbx_value_regex' = 'forward|swap|option|ndf|combination');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `hedge_ratio_variance` SET TAGS ('dbx_business_glossary_term' = 'Hedge Ratio Variance');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `lower_threshold_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Lower Threshold Breach Flag');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `mtm_impact_base` SET TAGS ('dbx_business_glossary_term' = 'Mark-to-Market (MTM) Impact Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `new_hedge_notional_base` SET TAGS ('dbx_business_glossary_term' = 'New Hedge Notional Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `quote_currency` SET TAGS ('dbx_business_glossary_term' = 'Quote Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `rebalance_action_type` SET TAGS ('dbx_business_glossary_term' = 'Rebalance Action Type');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `rebalance_action_type` SET TAGS ('dbx_value_regex' = 'increase_hedge|decrease_hedge|roll_forward|unwind|restructure');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `rebalance_cost_base` SET TAGS ('dbx_business_glossary_term' = 'Rebalance Cost Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `rebalance_notional_amount_base` SET TAGS ('dbx_business_glossary_term' = 'Rebalance Notional Amount Base Currency');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `rebalance_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Rebalance Reference Number');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `rebalance_status` SET TAGS ('dbx_business_glossary_term' = 'Rebalance Status');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `rebalance_status` SET TAGS ('dbx_value_regex' = 'pending|approved|executed|settled|cancelled|failed');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `rebalance_trigger_type` SET TAGS ('dbx_business_glossary_term' = 'Rebalance Trigger Type');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `rebalance_trigger_type` SET TAGS ('dbx_value_regex' = 'threshold_breach|scheduled|manual|policy_change|market_event|risk_limit');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `spot_rate_at_trigger` SET TAGS ('dbx_business_glossary_term' = 'Spot Rate at Trigger');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `target_hedge_ratio` SET TAGS ('dbx_business_glossary_term' = 'Target Hedge Ratio');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `trade_confirmation_reference` SET TAGS ('dbx_business_glossary_term' = 'Trade Confirmation Reference');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `trigger_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Trigger Timestamp');
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ALTER COLUMN `upper_threshold_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Upper Threshold Breach Flag');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` SET TAGS ('dbx_subdomain' = 'investment_counterparty');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `treasury_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Owner User Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Esg Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `framework_id` SET TAGS ('dbx_business_glossary_term' = 'Framework Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `policy_document_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Document Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `superseded_by_mandate_treasury_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Mandate Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `approved_counterparty_list` SET TAGS ('dbx_business_glossary_term' = 'Approved Counterparty List');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `approved_custodian_list` SET TAGS ('dbx_business_glossary_term' = 'Approved Custodian List');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `benchmark_rate` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Rate');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `collateral_minimum_transfer_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Minimum Transfer Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `collateral_posting_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Posting Threshold Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `counterparty_concentration_limit_pct` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Concentration Limit Percentage (Pct)');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `dv01_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of Zero One (DV01) Limit Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `eligible_collateral_types` SET TAGS ('dbx_business_glossary_term' = 'Eligible Collateral Types');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `fx_hedge_ratio_target_pct` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Hedge Ratio Target Percentage (Pct)');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `fx_hedge_ratio_tolerance_pct` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Hedge Ratio Tolerance Percentage (Pct)');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `ic_approval_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Reference');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `mandate_name` SET TAGS ('dbx_business_glossary_term' = 'Mandate Name');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `mandate_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Mandate Reference Number');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `mandate_reference_number` SET TAGS ('dbx_value_regex' = '^TM-[0-9]{6}$');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `mandate_status` SET TAGS ('dbx_business_glossary_term' = 'Mandate Status');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `mandate_status` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|active|suspended|superseded|terminated');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `mandate_type` SET TAGS ('dbx_business_glossary_term' = 'Mandate Type');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `mandate_type` SET TAGS ('dbx_value_regex' = 'liquidity_management|cash_management|fx_hedging|collateral_management|integrated');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `maximum_maturity_days` SET TAGS ('dbx_business_glossary_term' = 'Maximum Maturity Days');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `minimum_credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Minimum Credit Rating');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `minimum_credit_rating` SET TAGS ('dbx_value_regex' = 'AAA|AA+|AA|AA-|A+|A|A-');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `minimum_liquidity_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Liquidity Threshold Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `permitted_instrument_types` SET TAGS ('dbx_business_glossary_term' = 'Permitted Instrument Types');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `rebalance_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rebalance Frequency');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `rebalance_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|event_driven');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `regulatory_reporting_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Required Flag');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'quarterly|semi_annual|annual|biennial');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_business_glossary_term' = 'Settlement Cycle');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_value_regex' = 'T+0|T+1|T+2|T+3');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'DVP|FOP|cash_settlement');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `var_limit_1day_95pct_amount` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Limit One Day Ninety-Five Percent Amount');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` SET TAGS ('dbx_subdomain' = 'investment_counterparty');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `sofr_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Secured Overnight Financing Rate (SOFR) Benchmark Identifier');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `superseded_by_sofr_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Identifier');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `administrator_lei` SET TAGS ('dbx_business_glossary_term' = 'Administrator Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `administrator_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `benchmark_administrator` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Administrator');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `benchmark_regulation_compliant_flag` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Regulation Compliant Flag');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `business_day_convention` SET TAGS ('dbx_business_glossary_term' = 'Business Day Convention');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `business_day_convention` SET TAGS ('dbx_value_regex' = 'following|modified_following|preceding|no_adjustment');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `calendar_code` SET TAGS ('dbx_business_glossary_term' = 'Calendar Code');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `calendar_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `compounding_index` SET TAGS ('dbx_business_glossary_term' = 'SOFR Compounding Index');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_business_glossary_term' = 'Day Count Convention');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_value_regex' = 'actual_360|actual_365|30_360');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `index_base_date` SET TAGS ('dbx_business_glossary_term' = 'Index Base Date');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `percentile_25th` SET TAGS ('dbx_business_glossary_term' = '25th Percentile Rate');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `percentile_75th` SET TAGS ('dbx_business_glossary_term' = '75th Percentile Rate');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `publication_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Publication Timestamp');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `rate_date` SET TAGS ('dbx_business_glossary_term' = 'Rate Effective Date');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `rate_status` SET TAGS ('dbx_business_glossary_term' = 'Rate Status');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `rate_status` SET TAGS ('dbx_value_regex' = 'published|preliminary|revised|final|suspended');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `rate_type` SET TAGS ('dbx_business_glossary_term' = 'Rate Type');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `rate_value_bps` SET TAGS ('dbx_business_glossary_term' = 'Rate Value (Basis Points)');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `rate_value_percent` SET TAGS ('dbx_business_glossary_term' = 'Rate Value (Percent)');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `rate_volatility_bps` SET TAGS ('dbx_business_glossary_term' = 'Rate Volatility (Basis Points)');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `revision_number` SET TAGS ('dbx_business_glossary_term' = 'Revision Number');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `revision_reason` SET TAGS ('dbx_business_glossary_term' = 'Revision Reason');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `source_identifier` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `transaction_count` SET TAGS ('dbx_business_glossary_term' = 'Underlying Transaction Count');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `transaction_volume_usd` SET TAGS ('dbx_business_glossary_term' = 'Underlying Transaction Volume (United States Dollar)');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `usage_context` SET TAGS ('dbx_business_glossary_term' = 'Usage Context');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `validation_status` SET TAGS ('dbx_business_glossary_term' = 'Validation Status');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'pending|validated|failed|override');
ALTER TABLE `asset_management`.`treasury`.`sofr_benchmark` ALTER COLUMN `validation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Validation Timestamp');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` SET TAGS ('dbx_subdomain' = 'cash_liquidity');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `distribution_receipt_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Receipt Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `adjustment_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Notice Document Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `custody_account_id` SET TAGS ('dbx_business_glossary_term' = 'Custody Account Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `distribution_notice_document_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Notice Document Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `distribution_notice_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Notice Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `fund_investment_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Investment Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `gp_bank_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Bank Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Entity Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `accounting_period` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `accounting_period` SET TAGS ('dbx_value_regex' = '^d{4}-Q[1-4]$|^d{4}-d{2}$');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `announcement_date` SET TAGS ('dbx_business_glossary_term' = 'Distribution Announcement Date');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'private_equity|infrastructure|real_estate|natural_resources|credit');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `base_currency_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Amount');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `custodian_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Custodian Reference Number');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `distribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Distribution Amount');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `distribution_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Distribution Currency Code');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `distribution_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `distribution_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Distribution Reference Number');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `distribution_status` SET TAGS ('dbx_business_glossary_term' = 'Distribution Status');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `distribution_status` SET TAGS ('dbx_value_regex' = 'announced|pending|received|reconciled|disputed|reversed');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `distribution_type` SET TAGS ('dbx_business_glossary_term' = 'Distribution Type');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `distribution_type` SET TAGS ('dbx_value_regex' = 'return_of_capital|realized_gain|income|recallable|other');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `dpi_contribution` SET TAGS ('dbx_business_glossary_term' = 'Distributions to Paid-In (DPI) Contribution');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `fund_administrator_name` SET TAGS ('dbx_business_glossary_term' = 'Fund Administrator Name');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `gp_lei` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `gp_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `income_amount` SET TAGS ('dbx_business_glossary_term' = 'Income Amount');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `nav_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Impact Amount');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `net_distribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Distribution Amount');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Distribution Receipt Notes');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Distribution Payment Date');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `posted_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Posted Timestamp');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `processing_status` SET TAGS ('dbx_business_glossary_term' = 'Processing Status');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `processing_status` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|approved|posted|rejected');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `realized_gain_amount` SET TAGS ('dbx_business_glossary_term' = 'Realized Gain Amount');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `recallable_amount` SET TAGS ('dbx_business_glossary_term' = 'Recallable Amount');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `recallable_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Recallable Expiry Date');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `recallable_flag` SET TAGS ('dbx_business_glossary_term' = 'Recallable Distribution Flag');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Date');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'pending|matched|variance|resolved');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `reconciliation_variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Variance Amount');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `record_date` SET TAGS ('dbx_business_glossary_term' = 'Distribution Record Date');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `return_of_capital_amount` SET TAGS ('dbx_business_glossary_term' = 'Return of Capital Amount');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Distribution Settlement Date');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Amount');
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ALTER COLUMN `withholding_tax_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Rate Percent');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` SET TAGS ('dbx_subdomain' = 'cash_liquidity');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `sweep_instruction_id` SET TAGS ('dbx_business_glossary_term' = 'Sweep Instruction Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `bank_account_ssi_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Settlement Instructions (SSI) Template Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `initiated_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Initiated By User Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `initiated_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `initiated_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `legal_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `liquidity_reserve_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Reserve Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `source_cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Source Cash Account Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `ssi_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Settlement Instructions (SSI) Template Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `target_cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Target Cash Account Identifier (ID)');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `benchmark_rate` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Rate');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `custodian_confirmation_number` SET TAGS ('dbx_business_glossary_term' = 'Custodian Confirmation Number');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `executed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Executed Timestamp');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `execution_time` SET TAGS ('dbx_business_glossary_term' = 'Execution Time');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `failure_reason` SET TAGS ('dbx_business_glossary_term' = 'Failure Reason');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `instruction_date` SET TAGS ('dbx_business_glossary_term' = 'Instruction Date');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `instruction_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Instruction Reference Number');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `instruction_status` SET TAGS ('dbx_business_glossary_term' = 'Instruction Status');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `instruction_type` SET TAGS ('dbx_business_glossary_term' = 'Instruction Type');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `instruction_type` SET TAGS ('dbx_value_regex' = 'automated|manual|scheduled|threshold_triggered|zero_balance|target_balance');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `instrument_maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Instrument Maturity Date');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `interest_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Interest Rate Basis Points (bps)');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `liquidity_instrument_type` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Instrument Type');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `liquidity_tier` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Tier');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `liquidity_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3|operational|strategic|emergency');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `minimum_sweep_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Sweep Amount');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|ach|internal_book_transfer|rtgs|swift|fedwire');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Date');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'pending|reconciled|discrepancy|under_review');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `settled_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Settled Timestamp');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `sweep_amount` SET TAGS ('dbx_business_glossary_term' = 'Sweep Amount');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `sweep_frequency` SET TAGS ('dbx_business_glossary_term' = 'Sweep Frequency');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `sweep_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|intraday|on_demand|continuous');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `sweep_priority` SET TAGS ('dbx_business_glossary_term' = 'Sweep Priority');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `target_balance_amount` SET TAGS ('dbx_business_glossary_term' = 'Target Balance Amount');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Threshold Amount');
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ALTER COLUMN `value_date` SET TAGS ('dbx_business_glossary_term' = 'Value Date');
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` SET TAGS ('dbx_domain' = 'treasury');
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` SET TAGS ('dbx_subdomain' = 'investment_counterparty');
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` ALTER COLUMN `gp_bank_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Bank Account Identifier');
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` ALTER COLUMN `account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` ALTER COLUMN `account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` ALTER COLUMN `bank_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` ALTER COLUMN `bank_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` ALTER COLUMN `bank_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` ALTER COLUMN `bank_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` ALTER COLUMN `iban` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` ALTER COLUMN `iban` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` ALTER COLUMN `primary_signatory_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` ALTER COLUMN `primary_signatory_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` ALTER COLUMN `secondary_signatory_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` ALTER COLUMN `secondary_signatory_name` SET TAGS ('dbx_pii_name' = 'true');
