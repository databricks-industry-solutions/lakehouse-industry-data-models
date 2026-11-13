-- Schema for Domain: credit | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:25

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`credit` COMMENT 'Domain for credit and fixed income investment operations including investment grade (IG) bonds, high yield (HY), private credit, sovereign debt, and structured products.';
ALTER SCHEMA `asset_management`.`credit` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `asset_management`.`credit` SET TAGS ('dbx_domain' = 'credit');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`credit`.`fixed_income_security` (
    `fixed_income_security_id` BIGINT COMMENT 'Unique identifier for the fixed income security record. Primary key.',
    `credit_issuer_id` BIGINT COMMENT 'Foreign key linking to credit.credit_issuer. Business justification: Fixed income securities belong to one issuer; adding credit_issuer_id provides a direct link and removes redundant issuer name and lei columns.',
    `instrument_id` BIGINT COMMENT 'Foreign key linking to trade.instrument. Business justification: Align security with the instrument traded for pricing and analytics.',
    `accrued_interest` DECIMAL(20,6) COMMENT 'Interest accumulated on the security since the last coupon payment date, calculated as of the current valuation date.',
    `bloomberg_ticker` STRING COMMENT 'Bloomberg-assigned ticker symbol for the fixed income security used in Bloomberg Terminal.',
    `callable_flag` BOOLEAN COMMENT 'Indicates whether the issuer has the right to redeem the security before maturity.',
    `convexity` DECIMAL(10,4) COMMENT 'Measure of the curvature in the relationship between bond prices and yields, indicating how duration changes as yields change.',
    `country_of_risk` STRING COMMENT 'Three-letter ISO 3166 country code representing the primary country exposure or domicile of the issuer.. Valid values are `^[A-Z]{3}$`',
    `coupon_frequency` STRING COMMENT 'Frequency at which coupon interest payments are made to bondholders.. Valid values are `annual|semi_annual|quarterly|monthly|zero_coupon`',
    `coupon_rate` DECIMAL(10,6) COMMENT 'Annual interest rate paid by the issuer expressed as a decimal percentage of face value.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the security record was first created in the system.',
    `credit_rating_fitch` STRING COMMENT 'Current credit rating assigned by Fitch rating agency.',
    `credit_rating_moody` STRING COMMENT 'Current credit rating assigned by Moodys rating agency.',
    `credit_rating_sp` STRING COMMENT 'Current credit rating assigned by Standard & Poors rating agency.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the security is denominated.. Valid values are `^[A-Z]{3}$`',
    `cusip` STRING COMMENT '9-character alphanumeric code identifying North American securities.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `default_flag` BOOLEAN COMMENT 'Indicates whether the issuer is currently in default on interest or principal payments.',
    `duration` DECIMAL(10,4) COMMENT 'Weighted average time to receive the bonds cash flows, measuring interest rate sensitivity in years.',
    `dv01` DECIMAL(18,6) COMMENT 'Change in the market value of the security for a one basis point change in yield, expressed in currency units.',
    `esg_rating` STRING COMMENT 'ESG score or rating assigned by external provider assessing sustainability and responsible investment criteria.',
    `face_value` DECIMAL(20,2) COMMENT 'Par or nominal value of the security at issuance, representing the principal amount to be repaid at maturity.',
    `first_coupon_date` DATE COMMENT 'Date on which the first coupon payment is scheduled to be made to bondholders.',
    `fixed_income_security_status` STRING COMMENT 'Current lifecycle status of the fixed income security.. Valid values are `active|matured|called|defaulted|cancelled`',
    `floating_rate_flag` BOOLEAN COMMENT 'Indicates whether the coupon rate is variable and resets periodically based on a reference rate.',
    `green_bond_flag` BOOLEAN COMMENT 'Indicates whether the security is classified as a green bond with proceeds dedicated to environmental projects.',
    `investment_grade_flag` BOOLEAN COMMENT 'Indicates whether the security is classified as investment grade based on credit ratings.',
    `isin` STRING COMMENT '12-character alphanumeric code uniquely identifying the security globally per ISO 6166 standard.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `issue_date` DATE COMMENT 'Date on which the fixed income security was originally issued to investors.',
    `last_coupon_date` DATE COMMENT 'Date on which the most recent coupon payment was made to bondholders.',
    `liquidity_classification` STRING COMMENT 'Assessment of the ease with which the security can be bought or sold in the market without significant price impact.. Valid values are `highly_liquid|liquid|moderately_liquid|illiquid`',
    `market_price` DECIMAL(20,6) COMMENT 'Current market price of the security expressed as a percentage of face value or in currency units.',
    `maturity_date` DATE COMMENT 'Date on which the principal amount of the security is due to be repaid in full.',
    `next_coupon_date` DATE COMMENT 'Date on which the next coupon payment is scheduled to be made to bondholders.',
    `oas` DECIMAL(10,2) COMMENT 'Spread over the risk-free rate adjusted for embedded options, measured in basis points.',
    `price_date` DATE COMMENT 'Date as of which the market price was observed or quoted.',
    `puttable_flag` BOOLEAN COMMENT 'Indicates whether the holder has the right to sell the security back to the issuer before maturity.',
    `reference_rate` DECIMAL(18,2) COMMENT 'Benchmark interest rate index used for floating rate securities, such as Secured Overnight Financing Rate (SOFR) or London Interbank Offered Rate (LIBOR).',
    `sector` STRING COMMENT 'Economic sector or industry classification of the issuer.',
    `security_name` STRING COMMENT 'Full legal name or description of the fixed income security as issued.',
    `security_type` STRING COMMENT 'Classification of the fixed income instrument by broad category. [ENUM-REF-CANDIDATE: government_bond|corporate_bond|municipal_bond|treasury_bill|structured_product|private_credit|asset_backed_security — 7 candidates stripped; promote to reference product]',
    `sedol` STRING COMMENT '7-character alphanumeric code identifying securities traded on the London Stock Exchange and other UK exchanges.. Valid values are `^[0-9A-Z]{7}$`',
    `sinking_fund_flag` BOOLEAN COMMENT 'Indicates whether the issuer is required to set aside funds periodically to retire portions of the debt before maturity.',
    `spread_over_reference` DECIMAL(10,2) COMMENT 'Fixed spread in basis points added to the reference rate to determine the floating coupon rate.',
    `subordination_level` STRING COMMENT 'Ranking of the security in the issuers capital structure determining priority in bankruptcy or liquidation.. Valid values are `senior_secured|senior_unsecured|subordinated|junior_subordinated`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the security record was last modified in the system.',
    `ytm` DECIMAL(10,6) COMMENT 'Total return anticipated on the bond if held until maturity, expressed as an annual percentage rate.',
    CONSTRAINT pk_fixed_income_security PRIMARY KEY(`fixed_income_security_id`)
) COMMENT 'Master record for all fixed income and credit instruments held or monitored by the pension fund, including investment grade (IG) bonds, high yield (HY) bonds, sovereign debt, T-Bills, SOFR-linked instruments, private credit notes, and structured products';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`credit_position` (
    `credit_position_id` BIGINT COMMENT 'Unique identifier for the credit position record in the Investment Book of Record (IBOR).',
    `cash_position_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_position. Business justification: Pension fund reconciles each credit position with the cash position that funded the purchase for regulatory reporting and internal audit.',
    `counterparty_id` BIGINT COMMENT 'Reference to the counterparty entity for over-the-counter (OTC) transactions or derivatives.',
    `credit_blotter_id` BIGINT COMMENT 'Foreign key linking to trade.blotter. Business justification: Audit trail linking position to the trade that created it for regulatory reporting.',
    `credit_custodian_blotter_id` BIGINT COMMENT 'Reference to the custody bank holding the physical or electronic securities.',
    `credit_mandate_id` BIGINT COMMENT 'Foreign key linking to credit.credit_mandate. Business justification: Credit positions are governed by investment mandates; adding credit_mandate_id links each position to its mandate, enabling mandate‑level reporting.',
    `custodian_actor_id` BIGINT COMMENT 'Foreign key linking to shared.actor. Business justification: Custodian bank details are required for settlement, regulatory reporting, and risk management of each position.',
    `fixed_income_security_id` BIGINT COMMENT 'Reference to the fixed income security master record for this credit instrument.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio holding this credit position.',
    `account_number` STRING COMMENT 'Custodian or broker account number where the position is held.',
    `accrued_interest` DECIMAL(18,2) COMMENT 'Interest earned but not yet paid since the last coupon payment date.',
    `acquisition_date` DATE COMMENT 'Date on which the position was first acquired into the portfolio.',
    `asset_class` STRING COMMENT 'Classification of the credit instrument by asset class category.. Valid values are `investment_grade|high_yield|private_credit|sovereign_debt|structured_product|treasury_bill`',
    `base_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the funds reporting currency.. Valid values are `^[A-Z]{3}$`',
    `benchmark_index` STRING COMMENT 'Reference benchmark index used for performance comparison and spread calculation, such as Secured Overnight Financing Rate (SOFR).',
    `book_cost` DECIMAL(18,2) COMMENT 'Original acquisition cost of the position including transaction costs, recorded in base currency.',
    `collateral_type` STRING COMMENT 'Type of collateral backing the position for secured debt or derivatives under Credit Support Annex (CSA).',
    `convexity` DECIMAL(8,4) COMMENT 'Measure of the curvature in the relationship between bond prices and yields.',
    `coupon_rate` DECIMAL(8,4) COMMENT 'Annual interest rate paid by the bond issuer, expressed as a percentage.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the position record was first created in the Investment Book of Record (IBOR) system.',
    `credit_rating` STRING COMMENT 'External credit rating assigned by rating agencies such as Moodys, S&P, or Fitch.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the position denomination.. Valid values are `^[A-Z]{3}$`',
    `cusip` STRING COMMENT 'Nine-character alphanumeric code identifying North American securities.. Valid values are `^[0-9]{3}[0-9A-Z]{5}[0-9]$`',
    `duration` DECIMAL(8,4) COMMENT 'Weighted average time to receive cash flows, measuring interest rate sensitivity in years.',
    `dv01` DECIMAL(18,6) COMMENT 'Change in position value for a one basis point change in yield, used for interest rate risk measurement.',
    `esg_score` DECIMAL(5,2) COMMENT 'Composite ESG rating score for the issuer or instrument from external provider or internal assessment.',
    `face_value` DECIMAL(18,2) COMMENT 'Par value or notional principal amount of the fixed income position.',
    `fx_rate` DECIMAL(18,8) COMMENT 'Exchange rate used to convert position currency to base currency.',
    `instrument_type` STRING COMMENT 'Specific type of fixed income or credit derivative instrument.. Valid values are `corporate_bond|government_bond|municipal_bond|cds|convertible_bond|asset_backed_security`',
    `internal_credit_rating` STRING COMMENT 'Proprietary credit rating assigned by the pension funds internal credit research team.',
    `is_callable` BOOLEAN COMMENT 'Indicates whether the issuer has the right to redeem the bond before maturity.',
    `is_puttable` BOOLEAN COMMENT 'Indicates whether the holder has the right to sell the bond back to the issuer before maturity.',
    `isin` STRING COMMENT 'ISO 6166 standard 12-character alphanumeric code uniquely identifying the security.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `issuer_lei` STRING COMMENT 'ISO 17442 standard 20-character alphanumeric code uniquely identifying the issuer legal entity.. Valid values are `^[A-Z0-9]{20}$`',
    `issuer_name` STRING COMMENT 'Legal name of the entity that issued the debt instrument.',
    `market_value` DECIMAL(18,2) COMMENT 'Current fair value of the position based on latest market pricing, recorded in base currency.',
    `maturity_date` DATE COMMENT 'Date on which the principal amount of the debt instrument becomes due and payable.',
    `oas` DECIMAL(8,4) COMMENT 'Spread over the risk-free rate adjusted for embedded options, measured in basis points.',
    `position_status` STRING COMMENT 'Current lifecycle status of the credit position.. Valid values are `open|closed|pending_settlement|suspended|matured`',
    `position_type` STRING COMMENT 'Indicates whether the position is a long holding or short exposure.. Valid values are `long|short`',
    `quantity` DECIMAL(18,4) COMMENT 'Number of units or contracts held in the position.',
    `sedol` STRING COMMENT 'Seven-character alphanumeric code identifying securities traded on London Stock Exchange and other UK exchanges.. Valid values are `^[0-9BCDFGHJKLMNPQRSTVWXYZ]{7}$`',
    `seniority` STRING COMMENT 'Priority ranking of the debt instrument in the issuers capital structure for repayment in case of default.. Valid values are `senior_secured|senior_unsecured|subordinated|junior`',
    `settlement_date` DATE COMMENT 'Date on which the position was settled and ownership transferred, typically Trade Date Plus Two (T+2).',
    `trade_date` DATE COMMENT 'Date on which the transaction to acquire or dispose of the position was executed.',
    `unrealized_gain_loss` DECIMAL(18,2) COMMENT 'Difference between market value and book cost representing unrealized profit or loss.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the position record was last modified in the Investment Book of Record (IBOR) system.',
    `valuation_date` DATE COMMENT 'Date as of which the market value and analytics were calculated.',
    `ytm` DECIMAL(8,4) COMMENT 'Total return anticipated on the bond if held until maturity, expressed as an annual percentage rate.',
    CONSTRAINT pk_credit_position PRIMARY KEY(`credit_position_id`)
) COMMENT 'IBOR-authoritative record of the pension funds current and historical holdings in all credit and fixed income instruments across portfolios. Captures long/short positions, face value, book cost, market value (MTM), accrued interest, settlement date';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`coupon_schedule` (
    `coupon_schedule_id` BIGINT COMMENT 'Unique identifier for the coupon schedule record.',
    `fixed_income_security_id` BIGINT COMMENT 'Foreign key reference to the fixed income security master record for which this coupon schedule applies.',
    `reference_sofr_rate_id` BIGINT COMMENT 'Foreign key linking to credit.sofr_rate. Business justification: Coupon schedules reference a reference rate; adding reference_sofr_rate_id links to the specific SOFR rate record, enabling consistent rate lookups.',
    `accrual_days` BIGINT COMMENT 'Number of days in the coupon accrual period calculated according to the day count convention.',
    `accrual_end_date` DATE COMMENT 'Date on which interest stops accruing for this coupon period.',
    `accrual_start_date` DATE COMMENT 'Date from which interest begins accruing for this coupon period.',
    `actual_payment_amount` DECIMAL(18,4) COMMENT 'Actual cash amount received for this coupon payment, which may differ from scheduled amount due to adjustments or withholding.',
    `actual_payment_date` DATE COMMENT 'Actual date on which the coupon payment was made, which may differ from scheduled payment date due to holidays or settlement delays.',
    `business_day_convention` STRING COMMENT 'Rule applied to adjust payment dates that fall on non-business days to the nearest valid business day.. Valid values are `following|modified_following|preceding|unadjusted`',
    `calculation_agent_lei` STRING COMMENT 'Legal Entity Identifier of the institution responsible for calculating floating rate coupons and determining payment amounts.. Valid values are `^[A-Z0-9]{20}$`',
    `compounding_method` STRING COMMENT 'Method used for compounding interest when reference rates are observed daily or multiple times within a coupon period, such as simple, compounded, or averaged.',
    `coupon_amount` DECIMAL(18,4) COMMENT 'Calculated cash payment amount for this coupon period based on coupon rate, notional principal, and day count convention.',
    `coupon_cap_rate` DECIMAL(12,8) COMMENT 'Maximum coupon rate that will be paid regardless of how high the reference rate rises, limiting issuer exposure to rate increases.',
    `coupon_currency` STRING COMMENT 'Three-letter ISO currency code in which the coupon payment will be made.. Valid values are `^[A-Z]{3}$`',
    `coupon_floor_rate` DECIMAL(12,8) COMMENT 'Minimum coupon rate that will be paid regardless of how low the reference rate falls, providing downside protection to investors.',
    `coupon_rate` DECIMAL(12,8) COMMENT 'Annual interest rate expressed as a decimal for this coupon period, either fixed or calculated from floating reference rate plus spread.',
    `coupon_rate_type` STRING COMMENT 'Classification of the coupon rate structure indicating whether the rate is fixed, floating, zero-coupon, or variable.. Valid values are `fixed|floating|zero|step_up|step_down|variable`',
    `coupon_sequence_number` BIGINT COMMENT 'Sequential ordering number of this coupon payment within the overall schedule for the security.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this coupon schedule record was first created in the system.',
    `cusip` STRING COMMENT 'CUSIP identifier for North American securities, used for trade settlement and custody operations.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `day_count_convention` STRING COMMENT 'Method used to calculate the number of days in the coupon period for interest accrual purposes.. Valid values are `30/360|ACT/360|ACT/365|ACT/ACT|30E/360`',
    `ex_dividend_date` DATE COMMENT 'Date on which the security begins trading without the right to receive the upcoming coupon payment.',
    `fixed_reference_rate_value` DECIMAL(12,8) COMMENT 'Actual observed value of the reference rate on the fixing date, used to calculate the floating coupon rate.',
    `fixing_date` DATE COMMENT 'Date on which the reference rate is observed or fixed for floating rate coupon calculation, typically a few days before the period start.',
    `is_final_coupon` BOOLEAN COMMENT 'Flag indicating whether this is the final coupon payment before the security matures and principal is repaid.',
    `isin` STRING COMMENT 'International Securities Identification Number uniquely identifying the fixed income security globally.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this coupon schedule record was last updated or modified.',
    `net_payment_amount` DECIMAL(18,4) COMMENT 'Net cash amount received after deducting withholding taxes and any other adjustments from the gross coupon payment.',
    `notional_principal` DECIMAL(20,4) COMMENT 'Face value or principal amount on which the coupon payment is calculated for this period.',
    `paying_agent_lei` STRING COMMENT 'Legal Entity Identifier of the financial institution acting as paying agent responsible for distributing coupon payments to bondholders.. Valid values are `^[A-Z0-9]{20}$`',
    `payment_calendar` STRING COMMENT 'Financial center or holiday calendar used to determine business days for payment date adjustments.',
    `payment_date` DATE COMMENT 'Scheduled date on which the coupon payment will be made to bondholders of record.',
    `payment_frequency` STRING COMMENT 'Frequency at which coupon payments are scheduled to be made throughout the life of the security.. Valid values are `annual|semi_annual|quarterly|monthly|at_maturity`',
    `payment_method` STRING COMMENT 'Mechanism through which the coupon payment is delivered to the bondholder, such as wire transfer, clearing system, or physical check.. Valid values are `wire_transfer|ach|check|book_entry|euroclear|clearstream`',
    `payment_status` STRING COMMENT 'Current status of this scheduled coupon payment indicating whether it is upcoming, completed, or has encountered issues.. Valid values are `scheduled|paid|missed|deferred|cancelled`',
    `record_date` DATE COMMENT 'Date on which bondholders must be registered as owners to be entitled to receive the coupon payment.',
    `reference_rate` DECIMAL(18,2) COMMENT 'Benchmark interest rate index used for floating rate coupons such as SOFR, LIBOR, EURIBOR, or other market reference rates.',
    `reference_rate_tenor` STRING COMMENT 'Maturity period of the reference rate used for floating rate calculation, such as 1M, 3M, 6M, or 12M.',
    `reset_frequency` STRING COMMENT 'Frequency at which the floating coupon rate is reset based on the reference rate, such as daily, monthly, quarterly, or semi-annually.',
    `schedule_effective_timestamp` TIMESTAMP COMMENT 'Timestamp when this version of the coupon schedule became effective and valid for use in portfolio valuation and cash flow forecasting.',
    `schedule_source_system` STRING COMMENT 'Operational system from which this coupon schedule record was sourced, such as Bloomberg, SimCorp Dimension, or custodian platform.',
    `schedule_version_number` BIGINT COMMENT 'Version number of this coupon schedule record, incremented when schedule terms are amended or recalculated.',
    `sedol` STRING COMMENT 'Stock Exchange Daily Official List identifier primarily used for UK and Irish securities.. Valid values are `^[0-9A-Z]{7}$`',
    `spread_over_reference_rate_bps` DECIMAL(10,4) COMMENT 'Fixed spread in basis points added to the reference rate to determine the total coupon rate for floating rate securities.',
    `withholding_tax_amount` DECIMAL(18,4) COMMENT 'Amount of tax withheld from the coupon payment at source by the paying agent or custodian.',
    `withholding_tax_rate` DECIMAL(8,6) COMMENT 'Tax rate applied at source to the coupon payment, expressed as a decimal, based on jurisdiction and tax treaty provisions.',
    CONSTRAINT pk_coupon_schedule PRIMARY KEY(`coupon_schedule_id`)
) COMMENT 'Forward-looking cash-flow schedule for each fixed income security, capturing all scheduled coupon payment dates, coupon amounts, coupon rates (fixed or floating), reference rate (SOFR, LIBOR), spread over reference rate, ex-dividend/record/payment dates';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`coupon_payment` (
    `coupon_payment_id` BIGINT COMMENT 'Unique identifier for the coupon payment transaction record.',
    `custodian_id` BIGINT COMMENT 'Identifier of the custodian bank or fund administrator processing the coupon payment.',
    `fixed_income_security_id` BIGINT COMMENT 'Identifier of the fixed income security generating this coupon payment.',
    `portfolio_id` BIGINT COMMENT 'Identifier of the investment portfolio holding the security at time of coupon payment.',
    `accrual_days` BIGINT COMMENT 'Number of days in the accrual period used to calculate the coupon payment per day count convention.',
    `accrual_end_date` DATE COMMENT 'End date of the interest accrual period for this coupon payment.',
    `accrual_start_date` DATE COMMENT 'Start date of the interest accrual period for this coupon payment.',
    `accrued_interest_local` DECIMAL(18,4) COMMENT 'Accrued interest amount at settlement in local currency, used for reconciliation and accounting.',
    `base_currency_code` STRING COMMENT 'Three-letter ISO currency code of the fund base reporting currency.. Valid values are `^[A-Z]{3}$`',
    `coupon_amount_base` DECIMAL(18,4) COMMENT 'Gross coupon payment amount converted to the fund base reporting currency.',
    `coupon_amount_local` DECIMAL(18,4) COMMENT 'Gross coupon payment amount received in the local currency of the security.',
    `coupon_rate` DECIMAL(12,8) COMMENT 'Annual coupon interest rate expressed as a decimal for this payment period.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this coupon payment record was first created in the system.',
    `cusip` STRING COMMENT 'CUSIP identifier for North American securities generating the coupon payment.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `data_classification` STRING COMMENT 'Data classification level of this coupon payment record per information security policy.. Valid values are `internal|confidential`',
    `day_count_convention` STRING COMMENT 'Day count convention used to calculate accrued interest for this coupon payment.. Valid values are `30/360|ACT/360|ACT/365|ACT/ACT|30E/360`',
    `fx_rate` DECIMAL(18,10) COMMENT 'Foreign exchange rate used to convert local currency coupon payment to base reporting currency.',
    `fx_rate_date` DATE COMMENT 'Date of the FX rate used for currency conversion, typically payment or settlement date.',
    `gl_posting_date` DATE COMMENT 'Date the coupon payment income was posted to the general ledger accounting system.',
    `holding_quantity` DECIMAL(18,4) COMMENT 'Quantity of the security held in the portfolio on the record date for this coupon payment.',
    `income_classification` STRING COMMENT 'Accounting classification of the coupon payment income for financial reporting purposes.. Valid values are `interest_income|dividend_income|other_income`',
    `isin` STRING COMMENT 'International Securities Identification Number of the fixed income security generating the coupon.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `local_currency_code` STRING COMMENT 'Three-letter ISO currency code of the security denomination and coupon payment.. Valid values are `^[A-Z]{3}$`',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this coupon payment record was last modified in the system.',
    `net_coupon_amount_base` DECIMAL(18,4) COMMENT 'Net coupon payment amount after withholding tax converted to base reporting currency.',
    `net_coupon_amount_local` DECIMAL(18,4) COMMENT 'Net coupon payment amount after withholding tax deduction in local currency.',
    `paying_agent_lei` STRING COMMENT 'Legal Entity Identifier of the paying agent processing the coupon payment.. Valid values are `^[A-Z0-9]{20}$`',
    `paying_agent_name` STRING COMMENT 'Name of the financial institution acting as paying agent for the coupon payment.',
    `payment_date` DATE COMMENT 'Actual date the coupon cash payment was received in the portfolio account.',
    `payment_frequency` STRING COMMENT 'Frequency at which coupon payments are made per the bond indenture terms.. Valid values are `annual|semi-annual|quarterly|monthly|at_maturity|zero_coupon`',
    `payment_reference_number` STRING COMMENT 'External reference number assigned by custodian or paying agent for this coupon payment transaction.',
    `payment_status` STRING COMMENT 'Current lifecycle status of the coupon payment transaction.. Valid values are `scheduled|received|reconciled|failed|reversed|pending_settlement`',
    `payment_type` STRING COMMENT 'Classification of the coupon payment type within the bond lifecycle.. Valid values are `regular|final|partial|makeup|arrears`',
    `reconciliation_status` STRING COMMENT 'Status of reconciliation between expected and actual coupon payment amounts and dates.. Valid values are `matched|unmatched|exception|pending_review|resolved`',
    `record_date` DATE COMMENT 'Date on which the holder of record must own the security to be entitled to the coupon payment.',
    `scheduled_payment_date` DATE COMMENT 'Contractual date the coupon payment was scheduled per the bond indenture or prospectus.',
    `sedol` STRING COMMENT 'SEDOL identifier for UK and Irish securities generating the coupon payment.. Valid values are `^[0-9A-Z]{7}$`',
    `settlement_date` DATE COMMENT 'Date the coupon payment cash settled into the portfolio cash account.',
    `tax_reclaim_amount_local` DECIMAL(18,4) COMMENT 'Amount of withholding tax eligible for reclaim in local currency under applicable tax treaty.',
    `tax_reclaim_eligible_flag` BOOLEAN COMMENT 'Indicates whether the withholding tax on this coupon payment is eligible for reclaim under tax treaty.',
    `variance_amount_base` DECIMAL(18,4) COMMENT 'Difference between expected and actual coupon payment in base currency, used for reconciliation.',
    `withholding_tax_amount_local` DECIMAL(18,4) COMMENT 'Withholding tax deducted at source by the paying agent or issuer jurisdiction in local currency.',
    `withholding_tax_rate` DECIMAL(8,6) COMMENT 'Withholding tax rate applied to the coupon payment expressed as a decimal.',
    CONSTRAINT pk_coupon_payment PRIMARY KEY(`coupon_payment_id`)
) COMMENT 'Transactional record of actual coupon cash receipts and accruals for fixed income holdings, capturing payment date, coupon amount received, accrued interest at settlement, withholding tax applied, currency, FX rate used for conversion, and reconciliation';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`duration_convexity` (
    `duration_convexity_id` BIGINT COMMENT 'Unique identifier for the duration and convexity measurement record.',
    `credit_yield_curve_id` BIGINT COMMENT 'Foreign key linking to credit.yield_curve. Business justification: Duration and convexity metrics are calculated against a specific yield curve; adding yield_curve_id links the metrics to the curve definition.',
    `fixed_income_security_id` BIGINT COMMENT 'Foreign key reference to the fixed income security being measured.',
    `portfolio_id` BIGINT COMMENT 'Foreign key reference to the portfolio holding the security.',
    `benchmark_curve_name` STRING COMMENT 'Name of the benchmark yield curve used for duration and spread calculations.',
    `calculation_engine` STRING COMMENT 'Analytics engine or platform that performed the duration and convexity calculations.',
    `calculation_error_message` STRING COMMENT 'Error message or diagnostic information if the calculation failed or encountered issues.',
    `calculation_method` STRING COMMENT 'Methodology used to calculate duration and convexity metrics.. Valid values are `analytical|numerical|monte_carlo|binomial_tree|black_scholes`',
    `calculation_status` STRING COMMENT 'Status of the duration and convexity calculation process.. Valid values are `completed|failed|pending|in_progress`',
    `calculation_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the duration and convexity analytics were computed.',
    `convexity` DECIMAL(18,8) COMMENT 'Convexity measuring the curvature of the price-yield relationship and the rate of change of duration.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this duration and convexity record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the market value and DV01 amounts.. Valid values are `^[A-Z]{3}$`',
    `data_source_system` STRING COMMENT 'Source system that provided the input data for duration and convexity calculations.',
    `dv01` DECIMAL(18,2) COMMENT 'Dollar value change in the security or portfolio for a one basis point (0.01%) change in yield.',
    `effective_date` DATE COMMENT 'Date from which these duration and convexity metrics are considered effective for risk management and reporting.',
    `effective_duration` DECIMAL(18,8) COMMENT 'Effective duration accounting for embedded options and expected cash flow changes, expressed in years.',
    `expiry_date` DATE COMMENT 'Date after which these duration and convexity metrics are no longer valid and should be recalculated.',
    `is_active` BOOLEAN COMMENT 'Flag indicating whether this is the current active version of the duration and convexity record.',
    `is_portfolio_level` BOOLEAN COMMENT 'Flag indicating whether this record represents portfolio-level aggregated metrics or security-level metrics.',
    `key_rate_duration_10y` DECIMAL(18,8) COMMENT 'Key rate duration for the 10-year point on the yield curve, measuring sensitivity to that specific maturity.',
    `key_rate_duration_1y` DECIMAL(18,8) COMMENT 'Key rate duration for the 1-year point on the yield curve, measuring sensitivity to that specific maturity.',
    `key_rate_duration_2y` DECIMAL(18,8) COMMENT 'Key rate duration for the 2-year point on the yield curve, measuring sensitivity to that specific maturity.',
    `key_rate_duration_30y` DECIMAL(18,8) COMMENT 'Key reach duration for the 30-year point on the yield curve, measuring sensitivity to that specific maturity.',
    `key_rate_duration_3m` DECIMAL(18,8) COMMENT 'Key rate duration for the 3-month point on the yield curve, measuring sensitivity to that specific maturity.',
    `key_rate_duration_5y` DECIMAL(18,8) COMMENT 'Key rate duration for the 5-year point on the yield curve, measuring sensitivity to that specific maturity.',
    `key_rate_duration_6m` DECIMAL(18,8) COMMENT 'Key rate duration for the 6-month point on the yield curve, measuring sensitivity to that specific maturity.',
    `macaulay_duration` DECIMAL(18,8) COMMENT 'Macaulay duration representing the weighted average time to receive all cash flows, expressed in years.',
    `market_value` DECIMAL(18,2) COMMENT 'Market value of the security or portfolio position at the valuation date, in base currency.',
    `modified_duration` DECIMAL(18,8) COMMENT 'Modified duration measuring the percentage change in price for a 1% change in yield, expressed in years.',
    `oas` DECIMAL(12,6) COMMENT 'Option-adjusted spread over the benchmark curve used for effective duration calculations, expressed in basis points.',
    `pv01` DECIMAL(18,2) COMMENT 'Present value change for a one basis point parallel shift in the yield curve.',
    `spread_duration` DECIMAL(18,8) COMMENT 'Spread duration measuring sensitivity to changes in credit spread over the benchmark yield curve.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this duration and convexity record was last modified.',
    `valuation_date` DATE COMMENT 'The business date for which the duration and convexity metrics were calculated.',
    `version_number` BIGINT COMMENT 'Version number for tracking recalculations or adjustments to the same valuation date metrics.',
    `yield_curve_source` STRING COMMENT 'Source system or vendor providing the benchmark yield curve used in calculations.',
    `ytm` DECIMAL(12,6) COMMENT 'Yield to maturity used as the base yield for duration and convexity calculations, expressed as a decimal percentage.',
    CONSTRAINT pk_duration_convexity PRIMARY KEY(`duration_convexity_id`)
) COMMENT 'Daily interest-rate sensitivity metrics for each fixed income security and portfolio: modified duration, Macaulay duration, effective duration, convexity, DV01 (dollar value of a basis point), PV01, and key rate durations (KRDs) across the yield curve.';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`rating` (
    `rating_id` BIGINT COMMENT 'Unique identifier for the credit rating record.',
    `credit_issuer_id` BIGINT COMMENT 'Reference to the issuer entity (corporate, sovereign, or other) being rated.',
    `fixed_income_security_id` BIGINT COMMENT 'Reference to the specific security being rated, if rating is at security level rather than issuer level.',
    `action` STRING COMMENT 'Type of rating action taken: new rating assignment, upgrade, downgrade, affirmation, withdrawal, or suspension.. Valid values are `New|Upgrade|Downgrade|Affirmed|Withdrawn|Suspended`',
    `active_flag` BOOLEAN COMMENT 'Indicates whether this rating is currently active and in effect (true) or has been superseded or withdrawn (false).',
    `agency` STRING COMMENT 'Name of the rating agency that issued the rating (Moodys, S&P, Fitch, DBRS) or Internal for proprietary credit assessments.. Valid values are `Moodys|S&P|Fitch|DBRS|Internal`',
    `analyst_name` STRING COMMENT 'Name of the lead analyst or credit officer responsible for the rating assignment or review.',
    `rating_category` STRING COMMENT 'Broad classification of the rating: Investment Grade (BBB-/Baa3 and above), High Yield (below BBB-/Baa3), Non-Rated, or Default.. Valid values are `Investment Grade|High Yield|Non-Rated|Default`',
    `committee_date` DATE COMMENT 'Date on which the rating committee met to approve or review the rating decision.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this rating record was first created in the system.',
    `currency` STRING COMMENT 'Three-letter ISO 4217 currency code indicating the currency context of the rating, if applicable.. Valid values are `^[A-Z]{3}$`',
    `default_probability` DECIMAL(10,6) COMMENT 'Estimated probability of default associated with this rating grade, expressed as a decimal (e.g., 0.001 for 0.1%).',
    `effective_date` DATE COMMENT 'Date on which this rating became effective and was published by the rating agency.',
    `esg_score` DECIMAL(5,2) COMMENT 'ESG score or rating component provided by the rating agency or internal assessment, if available.',
    `internal_override_flag` BOOLEAN COMMENT 'Indicates whether the internal credit assessment team has applied an override or adjustment to the external agency rating.',
    `internal_override_rationale` STRING COMMENT 'Explanation for any internal override or adjustment applied to the external rating.',
    `jurisdiction` STRING COMMENT 'Three-letter ISO country code representing the jurisdiction or domicile relevant to the rating.. Valid values are `^[A-Z]{3}$`',
    `methodology` STRING COMMENT 'Name or reference to the rating methodology framework applied by the agency for this rating.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review or surveillance of the rating.',
    `notch` BIGINT COMMENT 'Numeric representation of the rating for quantitative analysis, where higher numbers represent better credit quality.',
    `outlook` STRING COMMENT 'Forward-looking opinion on the potential direction of the rating over the medium term.. Valid values are `Positive|Stable|Negative|Developing|N/A`',
    `previous_rating_value` DECIMAL(18,2) COMMENT 'The rating grade that was in effect immediately prior to this rating action, for tracking rating transitions.',
    `public_flag` BOOLEAN COMMENT 'Indicates whether the rating is publicly disclosed or is a private rating for internal use only.',
    `rating_type` STRING COMMENT 'Type of rating indicating what is being rated: issuer-level credit quality, specific issue, or debt seniority class.. Valid values are `Issuer|Issue|Senior Unsecured|Senior Secured|Subordinated|Short-Term`',
    `rationale` STRING COMMENT 'Summary of the key factors and reasoning behind the rating assignment or rating action.',
    `recovery_rate` DECIMAL(5,2) COMMENT 'Expected recovery rate in the event of default, expressed as a percentage (e.g., 40.00 for 40%).',
    `regulatory_capital_treatment` STRING COMMENT 'Regulatory capital classification or risk weight associated with this rating under applicable banking regulations.',
    `report_url` STRING COMMENT 'URL or document reference to the full rating report or press release published by the rating agency.',
    `scale` STRING COMMENT 'Scale on which the rating is expressed: long-term, short-term, national scale, or global scale.. Valid values are `Long-Term|Short-Term|National|Global`',
    `sector` STRING COMMENT 'Economic sector or industry classification of the rated issuer (e.g., Financial, Industrial, Sovereign, Municipal).',
    `seniority` STRING COMMENT 'Seniority level of the rated debt instrument in the capital structure (e.g., Senior Secured, Senior Unsecured, Subordinated).',
    `solicited_flag` BOOLEAN COMMENT 'Indicates whether the rating was requested by the issuer (solicited) or assigned without issuer request (unsolicited).',
    `source_identifier` STRING COMMENT 'Unique identifier or reference code for this rating in the source system.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this rating record was last updated in the system.',
    `value` STRING COMMENT 'The actual rating grade assigned (e.g., AAA, Aa1, BBB+, B-, CCC, D). Format varies by agency.',
    `version_number` BIGINT COMMENT 'Version number for tracking rating history and changes over time for the same issuer or security.',
    `watch_status` STRING COMMENT 'Indicates whether the rating is under review for potential upgrade, downgrade, or not on watch.. Valid values are `Upgrade|Downgrade|None`',
    `withdrawal_date` DATE COMMENT 'Date on which the rating was withdrawn by the rating agency, if applicable.',
    `withdrawal_reason` STRING COMMENT 'Explanation for why the rating was withdrawn (e.g., debt matured, issuer request, lack of information).',
    CONSTRAINT pk_rating PRIMARY KEY(`rating_id`)
) COMMENT 'SSOT for credit ratings and their full history for fixed income issuers and individual securities, from rating agencies (Moodys, S&P, Fitch) and internal credit assessment.';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`rating_action` (
    `rating_action_id` BIGINT COMMENT 'Unique identifier for the rating action event record.',
    `credit_issuer_id` BIGINT COMMENT 'Reference to the issuer entity subject to the rating action.',
    `employee_id` BIGINT COMMENT 'Reference to the internal credit analyst who reviewed the rating action for portfolio impact.',
    `fixed_income_security_id` BIGINT COMMENT 'Reference to the specific security instrument rated, if action is security-level rather than issuer-level.',
    `action_source_system` STRING COMMENT 'Name of the source system or data feed from which the rating action was ingested.',
    `action_trigger_event` STRING COMMENT 'Description of the key event or development that triggered the rating action.',
    `action_type` STRING COMMENT 'Type of rating action taken: upgrade, downgrade, affirmed, watch placement, or outlook revision. [ENUM-REF-CANDIDATE: upgrade|downgrade|affirmed|watch_positive|watch_negative|outlook_positive|outlook_negative|outlook_stable — 8 candidates stripped',
    `analyst_name` STRING COMMENT 'Name of the lead analyst at the rating agency responsible for the rating action.',
    `announcement_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the rating action was publicly announced by the agency.',
    `committee_approval_date` DATE COMMENT 'Date on which the rating agencys rating committee formally approved the action.',
    `credit_spread_impact_bps` BIGINT COMMENT 'Estimated impact of the rating action on the credit spread, measured in basis points.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the rated instrument, if applicable to issue-level ratings.. Valid values are `^[A-Z]{3}$`',
    `default_probability_estimate` DECIMAL(10,6) COMMENT 'Estimated probability of default associated with the new rating, expressed as a decimal fraction.',
    `effective_date` DATE COMMENT 'Date on which the rating action became effective and was published by the rating agency.',
    `geographic_region` STRING COMMENT 'Primary geographic region or country of the issuer subject to the rating action.',
    `internal_review_date` DATE COMMENT 'Date on which the internal credit team completed their review of the rating action.',
    `internal_review_status` STRING COMMENT 'Status of the pension funds internal credit team review of the rating action.. Valid values are `pending_review|reviewed|approved|escalated`',
    `investment_policy_breach_flag` BOOLEAN COMMENT 'Indicates whether the new rating causes a breach of the funds investment policy constraints.',
    `new_outlook` STRING COMMENT 'The outlook designation assigned as a result of this action, indicating the likely direction of future rating changes.. Valid values are `positive|negative|stable|developing|not_applicable`',
    `new_rating` STRING COMMENT 'The credit rating assigned as a result of this action, using agency-specific rating scale notation.',
    `notch_change` BIGINT COMMENT 'Number of rating notches changed in this action; positive for upgrades, negative for downgrades, zero for affirmations.',
    `portfolio_impact_flag` BOOLEAN COMMENT 'Indicates whether this rating action materially impacts the pension funds investment portfolio holdings.',
    `prior_outlook` STRING COMMENT 'The outlook designation assigned before this action, indicating the likely direction of future rating changes.. Valid values are `positive|negative|stable|developing|not_applicable`',
    `prior_rating` STRING COMMENT 'The credit rating assigned immediately before this action, using agency-specific rating scale notation.',
    `rating_agency_code` BIGINT COMMENT 'Reference to the credit rating agency that issued the rating action.',
    `rating_category` STRING COMMENT 'Broad classification of the new rating as investment grade, high yield, non-rated, or default status.. Valid values are `investment_grade|high_yield|non_rated|default`',
    `rating_scale` STRING COMMENT 'The rating scale used by the agency for this action, distinguishing issuer vs. issue, long-term vs. short-term, and sovereign ratings.. Valid values are `long_term_issuer|short_term_issuer|long_term_issue|short_term_issue|sovereign|municipal`',
    `rating_type` STRING COMMENT 'Classification of the rating by debt seniority or instrument type.. Valid values are `issuer_credit|senior_unsecured|senior_secured|subordinated|preferred_stock|commercial_paper`',
    `rationale_summary` STRING COMMENT 'Brief summary of the key factors and rationale provided by the rating agency for the action.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this rating action record was first created in the pension funds data platform.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this rating action record was last updated in the pension funds data platform.',
    `recovery_rate_estimate` DECIMAL(5,2) COMMENT 'Estimated recovery rate in the event of default, expressed as a percentage.',
    `report_url` STRING COMMENT 'Web link to the full rating report or press release published by the rating agency.',
    `sector_classification` STRING COMMENT 'Industry or sector classification of the issuer as categorized by the rating agency.',
    `solicited_flag` BOOLEAN COMMENT 'Indicates whether the rating was solicited by the issuer or unsolicited by the agency.',
    `watch_status` STRING COMMENT 'Indicates whether the rating has been placed on a watch list for potential near-term change.. Valid values are `creditwatch_positive|creditwatch_negative|under_review_upgrade|under_review_downgrade|not_on_watch`',
    CONSTRAINT pk_rating_action PRIMARY KEY(`rating_action_id`)
) COMMENT 'Transactional event record capturing each rating change, watch placement, or outlook revision for a rated issuer or security. Records the effective date, prior rating, new rating, rating agency, action type (upgrade, downgrade, CreditWatch';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`cds_position` (
    `cds_position_id` BIGINT COMMENT 'Unique identifier for the credit default swap position record.',
    `counterparty_id` BIGINT COMMENT 'Identifier of the counterparty to the CDS contract (protection seller if bought, protection buyer if sold).',
    `credit_issuer_id` BIGINT COMMENT 'Identifier of the underlying reference entity (corporate or sovereign) on which credit protection is written.',
    `fixed_income_security_id` BIGINT COMMENT 'Identifier of the specific debt instrument serving as the reference obligation for credit event determination.',
    `portfolio_id` BIGINT COMMENT 'Identifier of the investment portfolio holding this CDS position.',
    `reference_entity_actor_id` BIGINT COMMENT 'Foreign key linking to shared.actor. Business justification: Reference entity is the underlying issuer; required for CDS pricing, risk analytics, and event monitoring.',
    `reference_entity_credit_issuer_id` BIGINT COMMENT 'Identifier of the underlying reference entity (corporate or sovereign) on which credit protection is written.',
    `accrued_premium` DECIMAL(20,2) COMMENT 'Premium accrued since last payment date but not yet paid, calculated on a pro-rata basis.',
    `ccp_name` STRING COMMENT 'Name of the central counterparty clearing house if the CDS is centrally cleared.',
    `clearing_status` STRING COMMENT 'Indicates whether the CDS is centrally cleared through a CCP or remains bilateral OTC.. Valid values are `cleared|bilateral|uncleared`',
    `collateral_currency` STRING COMMENT 'Three-letter ISO currency code for collateral posted and received.. Valid values are `^[A-Z]{3}$`',
    `collateral_posted` DECIMAL(20,2) COMMENT 'Amount of collateral posted by the pension fund to the counterparty or CCP under CSA or margin agreement.',
    `collateral_received` DECIMAL(20,2) COMMENT 'Amount of collateral received by the pension fund from the counterparty or CCP under CSA or margin agreement.',
    `contract_identifier` STRING COMMENT 'External business identifier or trade reference number for the CDS contract.',
    `counterparty_lei` STRING COMMENT 'Legal Entity Identifier of the CDS counterparty.. Valid values are `^[A-Z0-9]{20}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this CDS position record was first created in the system.',
    `credit_event_date` DATE COMMENT 'Date on which a credit event was determined to have occurred for the reference entity.',
    `credit_event_flag` BOOLEAN COMMENT 'Indicates whether a credit event (bankruptcy, failure to pay, restructuring) has occurred on the reference entity.',
    `cusip` STRING COMMENT 'CUSIP identifier for the CDS contract if applicable in North American markets.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `dv01` DECIMAL(15,4) COMMENT 'Change in CDS position value for a one basis point parallel shift in credit spread, measuring spread duration risk.',
    `effective_date` DATE COMMENT 'Date from which credit protection coverage begins under the CDS contract.',
    `index_flag` BOOLEAN COMMENT 'Indicates whether this is a single-name CDS or part of a CDS index (e.g., CDX, iTraxx).',
    `index_name` STRING COMMENT 'Name of the CDS index if this position is part of an index (e.g., CDX.NA.IG, iTraxx Europe).',
    `index_series` STRING COMMENT 'Series number of the CDS index if applicable.',
    `index_version` STRING COMMENT 'Version number of the CDS index if applicable.',
    `isin` STRING COMMENT 'International Securities Identification Number for the CDS contract if exchange-traded or centrally cleared.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `market_spread_bps` DECIMAL(10,4) COMMENT 'Current market credit spread for the reference entity at the CDS tenor, expressed in basis points.',
    `market_value` DECIMAL(20,2) COMMENT 'Current mark-to-market value of the CDS position in base currency.',
    `market_value_currency` STRING COMMENT 'Three-letter ISO currency code for the market value.. Valid values are `^[A-Z]{3}$`',
    `maturity_date` DATE COMMENT 'Scheduled termination date of the CDS contract when protection coverage ends.',
    `notional_amount` DECIMAL(20,2) COMMENT 'Face value or notional principal amount of credit protection bought or sold under the CDS contract.',
    `notional_currency` STRING COMMENT 'Three-letter ISO currency code for the notional amount.. Valid values are `^[A-Z]{3}$`',
    `position_status` STRING COMMENT 'Current lifecycle status of the CDS position.. Valid values are `active|matured|terminated|novated|assigned`',
    `protection_direction` STRING COMMENT 'Indicates whether the pension fund bought protection (long credit risk hedge) or sold protection (short credit risk exposure).. Valid values are `bought|sold`',
    `recovery_rate_assumption` DECIMAL(5,4) COMMENT 'Assumed recovery rate on reference obligation in event of default, expressed as decimal (e.g., 0.40 for 40 percent).',
    `reference_entity_lei` STRING COMMENT 'Legal Entity Identifier of the reference entity on which credit protection is written.. Valid values are `^[A-Z0-9]{20}$`',
    `restructuring_clause` STRING COMMENT 'Type of restructuring credit event covered: CR (cumulative restructuring), MR (modified restructuring), MM (modified-modified restructuring), XR (old restructuring), or none.. Valid values are `CR|MR|MM|XR|no_restructuring`',
    `running_spread_bps` DECIMAL(10,4) COMMENT 'Annual premium or coupon rate paid by the protection buyer expressed in basis points of the notional amount.',
    `seniority` STRING COMMENT 'Seniority level of the reference obligation in the capital structure.. Valid values are `senior|subordinated|junior`',
    `settlement_method` STRING COMMENT 'Method by which the CDS contract will settle upon credit event: physical delivery, cash settlement, or auction.. Valid values are `physical|cash|auction`',
    `tenor_years` DECIMAL(5,2) COMMENT 'Original term of the CDS contract expressed in years from effective date to maturity.',
    `termination_date` DATE COMMENT 'Actual date the CDS position was terminated, novated, or assigned prior to scheduled maturity.',
    `trade_date` DATE COMMENT 'Date on which the CDS contract was executed and agreed between counterparties.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this CDS position record was last modified.',
    `upfront_payment_amount` DECIMAL(20,2) COMMENT 'One-time upfront payment made at inception to compensate for difference between running spread and market spread.',
    `upfront_payment_currency` STRING COMMENT 'Three-letter ISO currency code for the upfront payment.. Valid values are `^[A-Z]{3}$`',
    `upfront_payment_direction` STRING COMMENT 'Indicates whether the pension fund paid or received the upfront payment.. Valid values are `paid|received`',
    CONSTRAINT pk_cds_position PRIMARY KEY(`cds_position_id`)
) COMMENT 'Master and position record for credit default swap (CDS) contracts held by the pension fund, capturing reference entity, reference obligation, CDS tenor, notional amount, protection bought/sold flag, CDS spread (running coupon in bps), upfront payment';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`cds_market_data` (
    `cds_market_data_id` BIGINT COMMENT 'Unique identifier for the CDS market data record.',
    `credit_issuer_id` BIGINT COMMENT 'Foreign key linking to credit.credit_issuer. Business justification: CDS market data references the issuer; linking to credit_issuer enables issuer-based analytics and regulatory reporting.',
    `reference_entity_actor_id` BIGINT COMMENT 'Foreign key linking to shared.actor. Business justification: Market data for reference entity is used in analytics, valuation, and regulatory reporting.',
    `reference_entity_credit_issuer_id` BIGINT COMMENT 'Identifier for the reference entity (corporate, sovereign, or index) underlying the CDS contract.',
    `ask_spread_bps` DECIMAL(10,4) COMMENT 'Ask-side CDS spread in basis points, representing the spread at which market makers are willing to sell protection.',
    `bid_ask_spread_bps` DECIMAL(10,4) COMMENT 'Difference between ask and bid spreads in basis points, indicating market liquidity and transaction cost.',
    `bid_spread_bps` DECIMAL(10,4) COMMENT 'Bid-side CDS spread in basis points, representing the spread at which market makers are willing to buy protection.',
    `cds_index_series` STRING COMMENT 'Series identifier for CDS indices (e.g., CDX.NA.IG.39, iTraxx Europe S36). Null for single-name CDS.',
    `cds_index_version` STRING COMMENT 'Version number of the CDS index series. Null for single-name CDS.',
    `coupon_rate_bps` DECIMAL(10,4) COMMENT 'Standard fixed coupon rate in basis points for the CDS contract (typically 100 bps or 500 bps for standard contracts).',
    `credit_rating_fitch` STRING COMMENT 'Current Fitch credit rating for the reference entity (e.g., AAA, AA+, BBB-, CCC).',
    `credit_rating_moody` STRING COMMENT 'Current Moodys credit rating for the reference entity (e.g., Aaa, Aa1, Baa3, Caa1).',
    `credit_rating_sp` STRING COMMENT 'Current S&P credit rating for the reference entity (e.g., AAA, AA+, BBB-, CCC).',
    `cs01` DECIMAL(18,6) COMMENT 'Dollar value change in CDS contract for a 1 basis point change in credit spread, measuring credit risk sensitivity.',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code in which the CDS contract is denominated (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `data_quality_flag` BOOLEAN COMMENT 'Indicator of data quality and reliability for the CDS market observation.',
    `data_source` STRING COMMENT 'Source system or vendor providing the CDS market data (e.g., Bloomberg, Markit, ICE, Tradeweb).',
    `dv01` DECIMAL(18,6) COMMENT 'Dollar value change in CDS contract for a 1 basis point change in spread, measuring interest rate sensitivity.',
    `implied_probability_of_default` DECIMAL(8,6) COMMENT 'Market-implied cumulative probability of default over the CDS tenor, derived from the CDS spread.',
    `is_active` BOOLEAN COMMENT 'Indicates whether the CDS contract or reference entity is currently active and trading in the market.',
    `liquidity_score` DECIMAL(5,2) COMMENT 'Quantitative score (0-100) representing the liquidity and trading activity of the CDS contract.',
    `mid_spread_bps` DECIMAL(10,4) COMMENT 'Mid-market CDS spread in basis points, calculated as the average of bid and ask spreads.',
    `pricing_date` DATE COMMENT 'Business date for which the CDS market data is observed and recorded.',
    `pricing_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the CDS market data was captured, including time zone.',
    `rating_outlook` STRING COMMENT 'Consensus or primary rating agency outlook for the reference entity credit rating.. Valid values are `positive|stable|negative|developing`',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this CDS market data record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this CDS market data record was last updated in the system.',
    `recovery_rate_assumption` DECIMAL(5,4) COMMENT 'Assumed recovery rate (as decimal) used in CDS pricing and implied default probability calculation, typically 0.40 for senior unsecured debt.',
    `reference_entity_name` STRING COMMENT 'Full legal name of the reference entity or index (e.g., corporate issuer, sovereign nation, CDX.NA.IG, iTraxx Europe).',
    `reference_entity_ticker` STRING COMMENT 'Market ticker or short code for the reference entity or CDS index.',
    `reference_entity_type` STRING COMMENT 'Classification of the reference entity underlying the CDS.. Valid values are `corporate|sovereign|index|municipal|structured`',
    `region` STRING COMMENT 'Geographic region of the reference entity or index composition.. Valid values are `north_america|europe|asia_pacific|latin_america|middle_east_africa|global`',
    `restructuring_clause` STRING COMMENT 'Type of restructuring credit event covered by the CDS contract (No R, Mod R, Mod Mod R, Full R).. Valid values are `no_restructuring|modified_restructuring|modified_modified_restructuring|full_restructuring`',
    `sector` STRING COMMENT 'Industry sector classification of the reference entity (e.g., Financials, Energy, Technology, Sovereign).',
    `seniority` STRING COMMENT 'Seniority level of the reference obligation in the capital structure.. Valid values are `senior_unsecured|senior_secured|subordinated|junior_subordinated`',
    `spread_bps` DECIMAL(10,4) COMMENT 'CDS spread quoted in basis points, representing the annual premium paid by the protection buyer.',
    `tenor` STRING COMMENT 'Maturity tenor of the CDS contract (1-year, 3-year, 5-year, 7-year, 10-year).. Valid values are `1Y|2Y|3Y|5Y|7Y|10Y`',
    `upfront_points` DECIMAL(10,6) COMMENT 'Upfront payment expressed as percentage points of notional, paid at inception for off-market CDS contracts.',
    CONSTRAINT pk_cds_market_data PRIMARY KEY(`cds_market_data_id`)
) COMMENT 'Time-series of CDS market data for reference entities and indices (CDX, iTraxx), capturing CDS spread by tenor (1Y, 3Y, 5Y, 7Y, 10Y), upfront points, implied probability of default (PD), recovery rate assumption, and pricing date.';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`private_credit_investment` (
    `private_credit_investment_id` BIGINT COMMENT 'Unique identifier for the private credit investment record.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the originating deal or opportunity that led to this private credit investment.',
    `employee_id` BIGINT COMMENT 'Reference to the internal investment manager or portfolio manager responsible for the private credit investment.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the internal investment manager or portfolio manager responsible for the private credit investment.',
    `investment_manager_actor_id` BIGINT COMMENT 'Foreign key linking to shared.actor. Business justification: Investment manager entity is needed for performance attribution, compliance, and stakeholder reporting.',
    `opportunity_id` BIGINT COMMENT 'Reference to the originating deal or opportunity that led to this private credit investment.',
    `borrower_legal_name` STRING COMMENT 'Full legal name of the borrowing entity or obligor under the credit agreement.',
    `borrower_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the borrower, enabling global counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `collateral_type` STRING COMMENT 'Description of assets or security pledged as collateral for the private credit investment.',
    `commitment_date` DATE COMMENT 'Date when the pension fund formally committed capital to the private credit investment.',
    `committed_amount` DECIMAL(18,2) COMMENT 'Total capital amount committed by the pension fund to the private credit investment.',
    `convexity` DECIMAL(10,4) COMMENT 'Convexity measure capturing the curvature of the price-yield relationship for the private credit investment.',
    `coupon_rate` DECIMAL(8,5) COMMENT 'Annual interest rate expressed as a decimal for fixed-rate private credit investments.',
    `covenant_package` STRING COMMENT 'Classification of financial and operational covenants embedded in the credit agreement.. Valid values are `covenant_lite|maintenance_covenants|incurrence_covenants|full_covenant`',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the private credit investment record was first created in the data platform.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the private credit investment is denominated.. Valid values are `^[A-Z]{3}$`',
    `default_probability` DECIMAL(5,4) COMMENT 'Estimated probability of default over a one-year horizon expressed as a decimal.',
    `dv01` DECIMAL(18,2) COMMENT 'Dollar value change in the investment for a one basis point parallel shift in interest rates.',
    `effective_duration` DECIMAL(8,4) COMMENT 'Effective duration accounting for embedded options and prepayment risk in the private credit investment.',
    `esg_score` DECIMAL(5,2) COMMENT 'Composite ESG score for the borrower or investment, reflecting responsible investment integration.',
    `expected_credit_loss` DECIMAL(18,2) COMMENT 'Expected credit loss provision calculated under IFRS 9 for the private credit investment.',
    `external_credit_rating` STRING COMMENT 'Credit rating assigned by external rating agencies such as Moodys, S&P, or Fitch if applicable.',
    `fair_value` DECIMAL(18,2) COMMENT 'Current fair value of the private credit investment as determined by the valuation team for Net Asset Value (NAV) calculation.',
    `first_funding_date` DATE COMMENT 'Date of the initial capital drawdown or funding event for the private credit investment.',
    `floating_rate_index` STRING COMMENT 'Reference rate index for floating-rate private credit investments, such as Secured Overnight Financing Rate (SOFR). [ENUM-REF-CANDIDATE: SOFR|LIBOR|EURIBOR|SONIA|CDOR|BBSY|none — 7 candidates stripped; promote to reference product]',
    `funded_amount` DECIMAL(18,2) COMMENT 'Cumulative capital amount drawn down and funded to date on the private credit investment.',
    `geographic_region` STRING COMMENT 'Primary geographic region or country where the borrower operates or where credit risk is concentrated.',
    `industry_sector` STRING COMMENT 'Primary industry sector or GICS classification of the borrower for portfolio diversification analysis.',
    `internal_credit_rating` STRING COMMENT 'Proprietary credit rating assigned by the pension funds internal credit risk team.',
    `investment_name` STRING COMMENT 'Business name or title of the private credit investment for identification and reporting purposes.',
    `investment_status` STRING COMMENT 'Current lifecycle status of the private credit investment from origination through exit. [ENUM-REF-CANDIDATE: pipeline|committed|funded|performing|non_performing|restructured|defaulted|repaid|written_off — 9 candidates stripped; promote to reference',
    `investment_type` STRING COMMENT 'Classification of the private credit investment structure and seniority in the capital stack. [ENUM-REF-CANDIDATE: senior_secured_loan|mezzanine_debt|unitranche|distressed_debt|infrastructure_debt|subordinated_debt|bridge_loan|revolving_credit — 8',
    `lead_arranger` STRING COMMENT 'Name of the lead arranger or bookrunner for syndicated private credit investments.',
    `loan_to_value_ratio` DECIMAL(5,4) COMMENT 'Ratio of the loan amount to the appraised value of the underlying collateral, expressed as a decimal.',
    `loss_given_default` DECIMAL(5,4) COMMENT 'Estimated loss severity as a percentage of exposure at default, expressed as a decimal.',
    `maturity_date` DATE COMMENT 'Scheduled final maturity or repayment date of the private credit investment per the credit agreement.',
    `modified_duration` DECIMAL(8,4) COMMENT 'Modified duration of the private credit investment, measuring interest rate sensitivity.',
    `oas` DECIMAL(8,5) COMMENT 'Option-adjusted spread in decimal form, measuring the credit spread adjusted for embedded optionality.',
    `origination_date` DATE COMMENT 'Date when the private credit investment was originated or the credit agreement was executed.',
    `outstanding_principal` DECIMAL(18,2) COMMENT 'Current outstanding principal balance of the private credit investment as of the valuation date.',
    `payment_frequency` STRING COMMENT 'Frequency of interest and principal payment schedules per the credit agreement terms.. Valid values are `monthly|quarterly|semi_annual|annual|at_maturity`',
    `pik_toggle_flag` BOOLEAN COMMENT 'Indicates whether the borrower has the option to pay interest in kind rather than cash.',
    `prepayment_penalty_flag` BOOLEAN COMMENT 'Indicates whether the credit agreement includes prepayment penalties or call protection provisions.',
    `seniority` STRING COMMENT 'Position of the private credit investment in the borrowers capital structure and priority of claims.. Valid values are `senior_secured|senior_unsecured|subordinated|mezzanine|junior`',
    `spread_bps` BIGINT COMMENT 'Credit spread over the floating rate index expressed in basis points for floating-rate investments.',
    `syndication_flag` BOOLEAN COMMENT 'Indicates whether the private credit investment is part of a syndicated loan with multiple lenders.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp when the private credit investment record was last modified.',
    `valuation_date` DATE COMMENT 'As-of date for the most recent fair value assessment of the private credit investment.',
    `ytm` DECIMAL(8,5) COMMENT 'Annualized yield to maturity of the private credit investment expressed as a decimal.',
    CONSTRAINT pk_private_credit_investment PRIMARY KEY(`private_credit_investment_id`)
) COMMENT 'Master record for direct private credit investments including senior secured loans, mezzanine debt, unitranche facilities, distressed debt, and infrastructure debt originated or acquired by the pension fund.';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`private_credit_drawdown` (
    `private_credit_drawdown_id` BIGINT COMMENT 'Unique identifier for the private credit drawdown transaction.',
    `actor_id` BIGINT COMMENT 'Reference to the pension fund legal entity or investment vehicle acting as lender.',
    `blotter_id` BIGINT COMMENT 'Foreign key linking to trade.blotter. Business justification: Associate drawdown with the trade that funded it for audit and reconciliation.',
    `booking_entity_actor_id` BIGINT COMMENT 'Reference to the legal entity or fund vehicle in whose books this drawdown is recorded.',
    `borrower_actor_id` BIGINT COMMENT 'Foreign key linking to shared.actor. Business justification: Borrower entity is a corporate counterparty; required for covenant monitoring, credit risk assessment, and regulatory reporting.',
    `counterparty_id` BIGINT COMMENT 'Reference to the legal entity or counterparty that is the borrower under the credit facility.',
    `cash_account_id` BIGINT COMMENT 'Reference to the treasury or cash management account from which the drawdown was funded.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio to which this drawdown is allocated.',
    `private_credit_facility_id` BIGINT COMMENT 'Reference to the parent private credit facility from which capital is being drawn.',
    `private_credit_investment_id` BIGINT COMMENT 'Reference to the parent private credit facility from which capital is being drawn.',
    `approval_authority` STRING COMMENT 'The governance body or individual who approved the drawdown, such as Investment Committee, CIO, or delegated authority.',
    `approval_date` DATE COMMENT 'The date on which the drawdown was formally approved by the designated authority.',
    `asset_class` STRING COMMENT 'The asset class classification of this private credit drawdown for portfolio reporting and strategic asset allocation purposes.. Valid values are `private_credit|direct_lending|mezzanine|distressed_debt|structured_credit`',
    `available_commitment` DECIMAL(18,2) COMMENT 'Remaining undrawn commitment available on the facility after this drawdown.',
    `base_rate_type` STRING COMMENT 'The reference rate index used as the base for interest calculation, such as SOFR, LIBOR, EURIBOR, or Prime.. Valid values are `SOFR|LIBOR|EURIBOR|Prime|Fixed`',
    `collateral_pledged` BOOLEAN COMMENT 'Indicates whether collateral was pledged or updated as part of this drawdown transaction.',
    `collateral_value` DECIMAL(18,2) COMMENT 'Fair market value of collateral pledged or securing this drawdown at the time of execution.',
    `commitment_fee_waived` BOOLEAN COMMENT 'Indicates whether the commitment fee on the undrawn portion was waived for this drawdown period.',
    `covenant_compliance_status` STRING COMMENT 'Status of borrower compliance with financial and operational covenants at the time of drawdown.. Valid values are `compliant|breach|waived|not_applicable`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this drawdown record was first created in the system.',
    `credit_rating` STRING COMMENT 'Internal or external credit rating assigned to the borrower or facility at the time of drawdown.',
    `cumulative_drawn_balance` DECIMAL(18,2) COMMENT 'Total outstanding drawn balance on the facility after this drawdown, including all prior drawdowns less repayments.',
    `drawdown_amount` DECIMAL(18,2) COMMENT 'The principal amount drawn down from the facility in this transaction.',
    `drawdown_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the drawdown amount.. Valid values are `^[A-Z]{3}$`',
    `drawdown_date` DATE COMMENT 'The date on which the capital drawdown was executed and funds were disbursed.',
    `drawdown_number` STRING COMMENT 'Business identifier for the drawdown event, typically sequential within the facility.',
    `drawdown_purpose` STRING COMMENT 'Business purpose or use of proceeds for this drawdown, such as acquisition financing, working capital, refinancing, or capital expenditure.',
    `drawdown_status` STRING COMMENT 'Current lifecycle status of the drawdown transaction.. Valid values are `pending|approved|funded|cancelled|failed`',
    `esg_classification` STRING COMMENT 'ESG classification of the credit facility under SFDR or internal responsible investment framework.. Valid values are `article_6|article_8|article_9|not_classified`',
    `funding_source` STRING COMMENT 'The internal or external source of capital used to fund this drawdown, such as fund name, treasury account, or co-investment vehicle.',
    `geographic_region` STRING COMMENT 'The primary geographic region or country of the borrower or underlying asset exposure.',
    `industry_sector` STRING COMMENT 'The industry sector classification of the borrower or underlying business, using GICS or internal taxonomy.',
    `interest_payment_frequency` STRING COMMENT 'Frequency at which interest payments are due on the drawn amount.. Valid values are `monthly|quarterly|semi-annually|annually|at_maturity`',
    `interest_rate_at_drawdown` DECIMAL(8,5) COMMENT 'The applicable interest rate (expressed as a decimal) in effect at the time of drawdown, including base rate plus spread.',
    `investment_strategy` STRING COMMENT 'The investment strategy or sub-strategy under which this drawdown is classified, such as senior secured, unitranche, or opportunistic credit.',
    `last_modified_by` STRING COMMENT 'User or system identifier of the person or process that last modified this drawdown record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The timestamp when this drawdown record was last updated.',
    `loan_to_value_ratio` DECIMAL(8,5) COMMENT 'The ratio of cumulative drawn balance to collateral value, expressed as a decimal.',
    `maturity_date` DATE COMMENT 'The date on which the drawn principal amount is due for repayment.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding the drawdown transaction, including special conditions or operational remarks.',
    `prepayment_allowed` BOOLEAN COMMENT 'Indicates whether the borrower is permitted to prepay this drawdown without penalty.',
    `prepayment_penalty_rate` DECIMAL(8,5) COMMENT 'The penalty rate (as a decimal) applied if the borrower prepays the drawdown before the scheduled maturity.',
    `settlement_date` DATE COMMENT 'The date on which cash settlement and fund transfer occurred for the drawdown.',
    `settlement_status` STRING COMMENT 'Status of the cash settlement process for the drawdown transaction.. Valid values are `pending|settled|failed|reversed`',
    `spread_bps` BIGINT COMMENT 'Credit spread over the base rate expressed in basis points applicable to this drawdown.',
    `created_by` STRING COMMENT 'User or system identifier of the person or process that created this drawdown record.',
    CONSTRAINT pk_private_credit_drawdown PRIMARY KEY(`private_credit_drawdown_id`)
) COMMENT 'Transactional record of capital drawdown events on private credit facilities, capturing drawdown date, drawdown amount, cumulative drawn balance, purpose of drawdown, applicable interest rate at drawdown, and funding source.';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`private_credit_repayment` (
    `private_credit_repayment_id` BIGINT COMMENT 'Unique identifier for the private credit repayment transaction. Primary key for this entity.',
    `amortization_schedule_id` BIGINT COMMENT 'Reference to the amortization schedule entry that this repayment corresponds to, if applicable.',
    `blotter_id` BIGINT COMMENT 'Foreign key linking to trade.blotter. Business justification: Link repayment to the trade that executed it for settlement tracking.',
    `counterparty_id` BIGINT COMMENT 'Reference to the borrower entity making the repayment, linking to the counterparty master data.',
    `custody_account_id` BIGINT COMMENT 'Reference to the custodian account into which the repayment was received.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio to which this private credit investment and repayment belong.',
    `private_counterparty_id` BIGINT COMMENT 'Reference to the borrower entity making the repayment, linking to the counterparty master data.',
    `private_credit_investment_id` BIGINT COMMENT 'Reference to the underlying private credit investment for which this repayment applies.',
    `private_servicer_entity_counterparty_id` BIGINT COMMENT 'Reference to the loan servicer entity responsible for processing and administering this repayment.',
    `servicer_entity_counterparty_id` BIGINT COMMENT 'Reference to the loan servicer entity responsible for processing and administering this repayment.',
    `accounting_treatment` STRING COMMENT 'Description of the accounting treatment applied to this repayment transaction per IFRS or local GAAP standards.',
    `accrued_interest_end_date` DATE COMMENT 'End date of the interest accrual period covered by this repayment.',
    `accrued_interest_start_date` DATE COMMENT 'Start date of the interest accrual period covered by this repayment.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this repayment record was first created in the data platform.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the repayment was made.. Valid values are `^[A-Z]{3}$`',
    `day_count_convention` STRING COMMENT 'Day count convention used to calculate the interest amount for this repayment such as Actual/360, Actual/365, 30/360, or Actual/Actual.. Valid values are `actual_360|actual_365|30_360|actual_actual`',
    `days_accrued` BIGINT COMMENT 'Number of days in the interest accrual period for which interest was calculated and repaid.',
    `gl_posting_date` DATE COMMENT 'The date on which this repayment transaction was posted to the general ledger for accounting purposes.',
    `interest_amount_repaid` DECIMAL(18,2) COMMENT 'The interest amount repaid in this transaction, representing accrued interest paid by the borrower.',
    `interest_rate_applied` DECIMAL(10,6) COMMENT 'The interest rate applied to calculate the interest component of this repayment, expressed as a decimal.',
    `is_early_repayment` BOOLEAN COMMENT 'Boolean flag indicating whether this repayment occurred before the scheduled maturity or payment date.',
    `is_partial_repayment` BOOLEAN COMMENT 'Boolean flag indicating whether this is a partial repayment of the outstanding principal rather than full repayment.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this repayment record was last modified or updated in the data platform.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding this repayment transaction, including any special circumstances or exceptions.',
    `outstanding_principal_balance` DECIMAL(18,2) COMMENT 'Remaining outstanding principal balance of the private credit investment after this repayment has been applied.',
    `payment_method` STRING COMMENT 'Method by which the repayment was received from the borrower such as wire transfer, ACH, check, direct debit, or automated clearing.. Valid values are `wire_transfer|ach|check|direct_debit|automated_clearing`',
    `payment_reference` STRING COMMENT 'Bank or payment system reference number associated with the repayment transaction for reconciliation purposes.',
    `prepayment_premium` DECIMAL(18,2) COMMENT 'Additional fee or premium charged to the borrower for early repayment of principal before the scheduled maturity date.',
    `principal_amount_repaid` DECIMAL(18,2) COMMENT 'The principal amount repaid in this transaction, representing the reduction in outstanding loan balance.',
    `reconciliation_date` DATE COMMENT 'The date on which this repayment transaction was reconciled and confirmed against bank statements and accounting records.',
    `reconciliation_status` STRING COMMENT 'Status of the reconciliation process for this repayment indicating whether it has been matched to expected cash flows and accounting entries.. Valid values are `pending|matched|unmatched|exception|resolved`',
    `repayment_date` DATE COMMENT 'The date on which the repayment was received or is scheduled to be received from the borrower.',
    `repayment_reference_number` STRING COMMENT 'External reference number or identifier assigned to this repayment transaction by the borrower or servicer.',
    `repayment_sequence_number` BIGINT COMMENT 'Sequential number of this repayment within the series of repayments for the private credit investment.',
    `repayment_status` STRING COMMENT 'Current lifecycle status of the repayment transaction indicating whether it is pending settlement, settled, failed, reversed, cancelled, or reconciled.. Valid values are `pending|settled|failed|reversed|cancelled|reconciled`',
    `repayment_type` STRING COMMENT 'Classification of the repayment indicating whether it is a scheduled principal payment, scheduled interest payment, prepayment, partial prepayment, full prepayment, or amortization payment.. Valid values are `scheduled_principal|scheduled_interest|prepayment|partial_prepayment|full_prepayment|amortization`',
    `scheduled_repayment_amount` DECIMAL(18,2) COMMENT 'The originally scheduled repayment amount per the loan agreement or amortization schedule.',
    `settlement_date` DATE COMMENT 'The date on which the repayment transaction was settled and cash was received into the fund account.',
    `source_system_record_code` STRING COMMENT 'Unique identifier of this repayment record in the source system for traceability and reconciliation purposes.',
    `total_repayment_amount` DECIMAL(18,2) COMMENT 'Total amount repaid in this transaction including principal, interest, prepayment premium, and any other fees.',
    `variance_amount` DECIMAL(18,2) COMMENT 'Difference between the scheduled repayment amount and the actual repayment amount received, indicating over or underpayment.',
    CONSTRAINT pk_private_credit_repayment PRIMARY KEY(`private_credit_repayment_id`)
) COMMENT 'Transactional record of principal repayments, amortization payments, and prepayments on private credit investments, capturing repayment date, principal amount repaid, prepayment premium (if any), remaining outstanding balance, and repayment type';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`covenant_monitoring` (
    `covenant_monitoring_id` BIGINT COMMENT 'Unique identifier for the covenant monitoring record.',
    `investment_id` BIGINT COMMENT 'Reference to the private credit investment subject to covenant monitoring.',
    `actual_value` DECIMAL(18,4) COMMENT 'Actual measured value of the covenant metric as reported by the borrower or calculated from financial statements.',
    `borrower_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier of the borrower entity subject to covenant compliance.. Valid values are `^[A-Z0-9]{20}$`',
    `borrower_name` STRING COMMENT 'Legal name of the borrower entity whose financial covenants are being monitored.',
    `breach_date` DATE COMMENT 'Date on which the covenant breach was identified or became effective, if applicable.',
    `breach_flag` BOOLEAN COMMENT 'Boolean indicator of whether the covenant is currently in breach (True) or compliant (False).',
    `breach_severity` STRING COMMENT 'Severity classification of the covenant breach based on magnitude of deviation and potential impact on credit quality.. Valid values are `minor|moderate|material|critical`',
    `comments` STRING COMMENT 'Free-text comments or notes from the credit analyst or portfolio manager regarding covenant monitoring and compliance.',
    `compliance_status` STRING COMMENT 'Current compliance status of the covenant: compliant, breach, waived by lender, cured after breach, or under review.. Valid values are `compliant|breach|waived|cured|under_review`',
    `covenant_category` STRING COMMENT 'Broad category of covenant: affirmative (actions required), negative (restrictions), financial (ratio/threshold), or reporting (disclosure obligations).. Valid values are `affirmative|negative|financial|reporting`',
    `covenant_description` STRING COMMENT 'Detailed textual description of the covenant terms and conditions as specified in the credit agreement.',
    `covenant_type` STRING COMMENT 'Type of financial covenant being monitored: leverage ratio, interest coverage ratio, Loan to Value (LTV), Debt Service Coverage Ratio (DSCR), minimum liquidity, or net worth.. Valid values are `leverage_ratio|interest_coverage_ratio|ltv|dscr|minimum_liquidity|net_worth`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the covenant monitoring record was first created in the system.',
    `cure_date` DATE COMMENT 'Date on which a previously breached covenant was cured and returned to compliance.',
    `cure_mechanism` STRING COMMENT 'Description of the mechanism or actions taken to cure the covenant breach (e.g., equity injection, asset sale, debt repayment).',
    `cushion_amount` DECIMAL(18,4) COMMENT 'Absolute difference between the actual value and threshold value, representing the margin of safety or breach magnitude.',
    `cushion_percentage` DECIMAL(5,2) COMMENT 'Percentage difference between actual value and threshold, expressed as a percentage of the threshold value.',
    `data_source` STRING COMMENT 'Source of the covenant measurement data: borrower compliance certificate, audited financial statements, management accounts, or third-party valuation.. Valid values are `borrower_report|audited_financials|management_accounts|third_party_valuation`',
    `lender_action` STRING COMMENT 'Actions taken or contemplated by the lender in response to covenant breach (e.g., waiver negotiation, default notice, acceleration).',
    `measurement_date` DATE COMMENT 'Date on which the covenant metric was measured or calculated, typically aligned with financial reporting period end.',
    `measurement_period_end` DATE COMMENT 'End date of the financial period over which the covenant metric is calculated.',
    `measurement_period_start` DATE COMMENT 'Start date of the financial period over which the covenant metric is calculated (e.g., trailing twelve months).',
    `next_test_date` DATE COMMENT 'Scheduled date for the next covenant compliance test or measurement.',
    `remediation_plan` STRING COMMENT 'Description of the borrowers plan to address covenant breach or prevent future breach, if applicable.',
    `reporting_deadline` DATE COMMENT 'Deadline by which the borrower must report covenant compliance to the lender.',
    `risk_rating` STRING COMMENT 'Internal risk rating assigned to the covenant based on proximity to breach and borrower credit quality.. Valid values are `low|medium|high|critical`',
    `testing_frequency` STRING COMMENT 'Frequency at which the covenant must be tested and reported as specified in the credit agreement.. Valid values are `monthly|quarterly|semi_annually|annually`',
    `threshold_operator` STRING COMMENT 'Comparison operator defining the covenant compliance condition relative to the threshold value.. Valid values are `greater_than|less_than|greater_than_or_equal|less_than_or_equal|equal`',
    `threshold_value` DECIMAL(18,4) COMMENT 'Numeric threshold or limit specified in the covenant that must be maintained or not exceeded.',
    `trend_direction` STRING COMMENT 'Directional trend of covenant compliance over recent measurement periods: improving, stable, or deteriorating.. Valid values are `improving|stable|deteriorating`',
    `updated_by` STRING COMMENT 'Identifier of the user or system that last updated the covenant monitoring record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the covenant monitoring record was last updated or modified.',
    `verification_date` DATE COMMENT 'Date on which the covenant compliance was verified by internal or external parties.',
    `verification_status` STRING COMMENT 'Status of verification for the reported covenant metric: unverified, verified by internal team, audited by external auditor, or disputed.. Valid values are `unverified|verified|audited|disputed`',
    `verified_by` STRING COMMENT 'Name or identifier of the individual or team who verified the covenant compliance calculation.',
    `waiver_date` DATE COMMENT 'Date on which the covenant waiver was granted by the lender or syndicate.',
    `waiver_expiry_date` DATE COMMENT 'Date on which the covenant waiver expires and full compliance is required again.',
    `waiver_granted_flag` BOOLEAN COMMENT 'Boolean indicator of whether a waiver has been granted by the lender for a covenant breach.',
    CONSTRAINT pk_covenant_monitoring PRIMARY KEY(`covenant_monitoring_id`)
) COMMENT 'Operational record tracking financial covenant compliance for private credit investments, capturing covenant type (leverage ratio, interest coverage ratio, LTV, DSCR, minimum liquidity), covenant threshold, actual measured value, measurement date';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`structured_product` (
    `structured_product_id` BIGINT COMMENT 'Unique identifier for the structured credit instrument record.',
    `credit_issuer_id` BIGINT COMMENT 'FK to credit.credit_issuer',
    `fixed_income_security_id` BIGINT COMMENT 'Foreign key linking to credit.fixed_income_security. Business justification: Structured products (ABS, MBS, CLOs) are a specialized type of fixed income security. Linking to fixed_income_security creates proper instrument hierarchy.',
    `accrued_interest` DECIMAL(18,6) COMMENT 'Interest accumulated since the last coupon payment date, payable to the seller in a transaction.',
    `bloomberg_ticker` STRING COMMENT 'Bloomberg terminal ticker symbol for the structured product.',
    `collateral_pool_size` DECIMAL(18,2) COMMENT 'Total value of the underlying collateral pool backing the structured product.',
    `collateral_type` STRING COMMENT 'Type of underlying collateral backing the structured product (e.g., residential mortgages, commercial loans, auto loans, credit card receivables, corporate loans).',
    `constant_prepayment_rate` DECIMAL(8,4) COMMENT 'Annualized rate at which the underlying collateral is expected to prepay, expressed as a decimal.',
    `convexity` DECIMAL(10,4) COMMENT 'Measure of the curvature in the relationship between bond prices and yields, capturing second-order interest rate risk.',
    `coupon_frequency` STRING COMMENT 'Frequency at which interest payments are made to investors.. Valid values are `Monthly|Quarterly|Semi-Annual|Annual`',
    `coupon_rate` DECIMAL(10,6) COMMENT 'Annual interest rate paid to investors, expressed as a decimal (e.g., 0.0525 for 5.25%).',
    `credit_enhancement_pct` DECIMAL(8,4) COMMENT 'Total credit enhancement as a percentage of the tranche, including subordination, overcollateralization, and reserve accounts.',
    `credit_rating_fitch` STRING COMMENT 'Current credit rating assigned by Fitch Ratings agency.',
    `credit_rating_moody` STRING COMMENT 'Current credit rating assigned by Moodys Investors Service.',
    `credit_rating_sp` STRING COMMENT 'Current credit rating assigned by Standard and Poors rating agency.',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code for the denomination of the structured product.. Valid values are `^[A-Z]{3}$`',
    `current_face_value` DECIMAL(18,2) COMMENT 'Current outstanding principal balance after amortization, prepayments, and write-downs.',
    `cusip` STRING COMMENT 'CUSIP identifier for North American structured securities.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `default_rate` DECIMAL(8,4) COMMENT 'Percentage of underlying collateral that has defaulted or is expected to default.',
    `duration` DECIMAL(10,4) COMMENT 'Weighted average time to receive cash flows, measuring interest rate risk sensitivity in years.',
    `dv01` DECIMAL(18,6) COMMENT 'Change in market value for a one basis point change in yield, measuring interest rate sensitivity.',
    `expected_maturity_date` DATE COMMENT 'Expected date of full principal repayment based on prepayment assumptions, may differ from legal maturity.',
    `floating_rate_flag` BOOLEAN COMMENT 'Indicates whether the coupon rate is floating (variable) or fixed.',
    `investment_grade_flag` BOOLEAN COMMENT 'Indicates whether the structured product is rated investment grade (BBB- or higher) or high yield.',
    `isin` STRING COMMENT 'International Securities Identification Number uniquely identifying the structured product globally.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `issue_date` DATE COMMENT 'Date when the structured product was originally issued to investors.',
    `issuer_lei` STRING COMMENT 'Legal Entity Identifier of the issuer for regulatory reporting and counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `loss_severity_rate` DECIMAL(8,4) COMMENT 'Expected loss as a percentage of exposure upon default, after recovery.',
    `market_price` DECIMAL(18,6) COMMENT 'Current market price of the structured product, typically quoted as a percentage of par.',
    `maturity_date` DATE COMMENT 'Final legal maturity date when all principal and interest must be repaid.',
    `number_of_collateral_assets` BIGINT COMMENT 'Count of individual assets or loans in the underlying collateral pool.',
    `oas` DECIMAL(10,2) COMMENT 'Spread over the risk-free rate adjusted for embedded options such as prepayment risk, expressed in basis points.',
    `original_face_value` DECIMAL(18,2) COMMENT 'Original principal amount of the structured product at issuance.',
    `overcollateralization_pct` DECIMAL(8,4) COMMENT 'Excess collateral value over outstanding note balance, expressed as a percentage.',
    `price_date` DATE COMMENT 'Date of the most recent market price observation.',
    `product_type` STRING COMMENT 'Classification of structured credit instrument: Asset-Backed Securities, Mortgage-Backed Securities, Residential MBS, Commercial MBS, Collateralized Loan Obligation, Collateralized Debt Obligation, Collateralized Bond Obligation, Covered Bond, Synthetic',
    `reference_rate` DECIMAL(18,2) COMMENT 'Benchmark rate for floating rate instruments (e.g., SOFR, LIBOR, EURIBOR).',
    `security_name` STRING COMMENT 'Full legal name of the structured credit instrument.',
    `sedol` STRING COMMENT 'SEDOL code for UK and Irish structured securities.. Valid values are `^[0-9A-Z]{7}$`',
    `spread_over_reference_bps` DECIMAL(8,2) COMMENT 'Credit spread added to the reference rate for floating rate instruments, expressed in basis points.',
    `subordination_pct` DECIMAL(8,4) COMMENT 'Percentage of junior tranches providing loss protection to this tranche.',
    `tranche_name` STRING COMMENT 'Name or designation of the specific tranche within the structured product (e.g., Senior, Mezzanine, Equity, Class A, Class B).',
    `tranche_seniority` STRING COMMENT 'Seniority ranking of the tranche in the capital structure determining payment priority and loss absorption.. Valid values are `Senior|Mezzanine|Junior|Equity|Subordinated|Super Senior`',
    `weighted_average_coupon` DECIMAL(10,6) COMMENT 'Weighted average interest rate of the underlying collateral pool.',
    `weighted_average_life_years` DECIMAL(8,2) COMMENT 'Expected average time until principal is repaid, accounting for prepayments and amortization.',
    `weighted_average_maturity_months` BIGINT COMMENT 'Weighted average remaining term to maturity of the underlying collateral, expressed in months.',
    `ytm` DECIMAL(10,6) COMMENT 'Total return anticipated if the structured product is held until maturity, expressed as a decimal.',
    CONSTRAINT pk_structured_product PRIMARY KEY(`structured_product_id`)
) COMMENT 'Master record for structured credit instruments including asset-backed securities (ABS), mortgage-backed securities (MBS), collateralized loan obligations (CLO), collateralized debt obligations (CDO), and covered bonds.';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`sovereign_debt_holding` (
    `sovereign_debt_holding_id` BIGINT COMMENT 'Unique identifier for the sovereign debt holding record.',
    `employee_id` BIGINT COMMENT 'Reference to the portfolio manager responsible for this sovereign debt holding.',
    `fixed_income_security_id` BIGINT COMMENT 'Reference to the underlying sovereign debt security master record.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio containing this sovereign debt holding.',
    `accounting_classification` STRING COMMENT 'IFRS 9 accounting treatment category for the sovereign debt holding.. Valid values are `held_to_maturity|available_for_sale|fair_value_through_pl`',
    `accrued_interest` DECIMAL(20,2) COMMENT 'Interest earned but not yet paid since the last coupon payment date.',
    `acquisition_date` DATE COMMENT 'Date when the sovereign debt position was originally acquired.',
    `asset_class` STRING COMMENT 'High-level asset class categorization for portfolio allocation and reporting.. Valid values are `fixed_income`',
    `average_cost` DECIMAL(15,6) COMMENT 'Weighted average cost per unit of the sovereign debt holding across multiple purchases.',
    `book_value` DECIMAL(20,2) COMMENT 'Amortized cost or carrying value of the sovereign debt holding on the books.',
    `callable_flag` BOOLEAN COMMENT 'Indicates whether the issuer has the right to redeem the sovereign debt before maturity.',
    `cost_basis` DECIMAL(20,2) COMMENT 'Original purchase price paid for the sovereign debt holding including transaction costs.',
    `coupon_frequency` STRING COMMENT 'Frequency at which coupon interest payments are made.. Valid values are `annual|semi_annual|quarterly|monthly|zero_coupon`',
    `coupon_rate` DECIMAL(8,5) COMMENT 'Annual interest rate paid by the sovereign debt security expressed as a decimal.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the sovereign debt holding record was first created in the system.',
    `credit_rating_fitch` STRING COMMENT 'Current credit rating assigned by Fitch Ratings to the sovereign issuer.',
    `credit_rating_moody` STRING COMMENT 'Current credit rating assigned by Moodys Investors Service to the sovereign issuer.',
    `credit_rating_sp` STRING COMMENT 'Current credit rating assigned by Standard and Poors to the sovereign issuer.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the sovereign debt is denominated.. Valid values are `^[A-Z]{3}$`',
    `cusip` STRING COMMENT 'Nine-character alphanumeric code identifying North American sovereign debt securities.. Valid values are `^[0-9]{3}[0-9A-Z]{5}[0-9]$`',
    `custodian_account` STRING COMMENT 'Account number at the custodian where the sovereign debt holding is held.',
    `custodian_name` STRING COMMENT 'Name of the financial institution holding the sovereign debt securities in custody.',
    `duration` DECIMAL(10,4) COMMENT 'Macaulay or modified duration measuring interest rate sensitivity of the sovereign debt holding.',
    `dv01` DECIMAL(15,4) COMMENT 'Change in market value for a one basis point change in yield, measuring interest rate risk.',
    `esg_rating` STRING COMMENT 'ESG rating assigned to the sovereign issuer by external rating provider.',
    `face_value` DECIMAL(20,2) COMMENT 'Par or nominal value of the sovereign debt holding at issuance.',
    `green_bond_flag` BOOLEAN COMMENT 'Indicates whether the sovereign debt is a certified green bond for environmental projects.',
    `holding_status` STRING COMMENT 'Current lifecycle status of the sovereign debt holding.. Valid values are `active|matured|sold|called|defaulted`',
    `inflation_linked_flag` BOOLEAN COMMENT 'Indicates whether the sovereign debt principal and coupons are indexed to inflation.',
    `investment_grade_flag` BOOLEAN COMMENT 'Indicates whether the sovereign debt is rated investment grade by major rating agencies.',
    `investment_strategy` STRING COMMENT 'Investment strategy or mandate under which the sovereign debt holding was acquired.',
    `isin` STRING COMMENT 'ISO 6166 standard 12-character alphanumeric code uniquely identifying the sovereign debt security.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `issuer_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the sovereign issuer.. Valid values are `^[A-Z]{3}$`',
    `issuer_lei` STRING COMMENT 'ISO 17442 standard 20-character alphanumeric code uniquely identifying the issuing legal entity.. Valid values are `^[A-Z0-9]{20}$`',
    `issuer_name` STRING COMMENT 'Name of the sovereign or quasi-sovereign entity issuing the debt.',
    `market_value` DECIMAL(20,2) COMMENT 'Current fair market value of the sovereign debt holding based on latest pricing.',
    `market_value_date` DATE COMMENT 'As-of date for the market value measurement.',
    `maturity_date` DATE COMMENT 'Date when the sovereign debt security matures and principal is repaid.',
    `quantity` DECIMAL(20,4) COMMENT 'Number of units or nominal amount of the sovereign debt security held.',
    `security_name` STRING COMMENT 'Full legal name of the sovereign debt security.',
    `security_type` STRING COMMENT 'Classification of the sovereign debt instrument type.. Valid values are `treasury_bond|treasury_bill|inflation_linked_bond|agency_bond|supranational_bond|provincial_bond`',
    `sedol` STRING COMMENT 'Seven-character alphanumeric code identifying securities traded on London Stock Exchange and other UK markets.. Valid values are `^[0-9A-Z]{7}$`',
    `settlement_date` DATE COMMENT 'Date when the acquisition trade settled and ownership transferred.',
    `unrealized_gain_loss` DECIMAL(20,2) COMMENT 'Difference between market value and book value representing unrealized profit or loss.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the sovereign debt holding record was last modified.',
    `ytm` DECIMAL(8,5) COMMENT 'Total return anticipated on the sovereign debt if held until maturity, expressed as an annual rate.',
    CONSTRAINT pk_sovereign_debt_holding PRIMARY KEY(`sovereign_debt_holding_id`)
) COMMENT 'Master record for sovereign and quasi-sovereign debt holdings including government bonds, treasury bills (T-Bills), inflation-linked bonds (ILBs/TIPS), agency bonds, and supranational debt (World Bank, EIB).';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`credit_yield_curve` (
    `credit_yield_curve_id` BIGINT COMMENT 'Unique identifier for the yield curve record.',
    `active_flag` BOOLEAN COMMENT 'Indicates whether this yield curve record is currently active and should be used for valuation and analytics (True/False).',
    `benchmark_flag` BOOLEAN COMMENT 'Indicates whether this is a benchmark curve used as a standard reference for valuation and risk analytics (True/False).',
    `compounding_frequency` STRING COMMENT 'Frequency at which interest is compounded for rate calculations (annual, semi-annual, quarterly, monthly, continuous).. Valid values are `annual|semi_annual|quarterly|monthly|continuous`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this yield curve record was first created in the system.',
    `credit_quality` STRING COMMENT 'Credit quality classification for credit spread curves (AAA, AA, A, BBB, BB, B, CCC, unrated). Not applicable for government curves. [ENUM-REF-CANDIDATE: aaa|aa|a|bbb|bb|b|ccc|unrated — 8 candidates stripped; promote to reference product]',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the yield curve (e.g., USD, EUR, GBP, JPY).. Valid values are `^[A-Z]{3}$`',
    `curve_date` DATE COMMENT 'The business date for which this yield curve snapshot is valid and applicable.',
    `curve_name` STRING COMMENT 'Human-readable name of the yield curve (e.g., US Treasury Curve, EUR Swap Curve, SOFR OIS Curve).',
    `curve_status` STRING COMMENT 'Current lifecycle status of the yield curve record (active, historical, preliminary, final, superseded, invalid).. Valid values are `active|historical|preliminary|final|superseded|invalid`',
    `curve_type` STRING COMMENT 'Classification of the yield curve by instrument type (government, swap, SOFR, OIS, credit spread, corporate, LIBOR, treasury). [ENUM-REF-CANDIDATE: government|swap|sofr|ois|credit_spread|corporate|libor|treasury — 8 candidates stripped; promote to',
    `day_count_convention` STRING COMMENT 'Day count convention used for rate calculations (ACT/360, ACT/365, 30/360, ACT/ACT).. Valid values are `act_360|act_365|30_360|act_act`',
    `effective_timestamp` TIMESTAMP COMMENT 'Date and time from which this yield curve snapshot becomes effective for valuation and risk calculations.',
    `expiry_timestamp` TIMESTAMP COMMENT 'Date and time when this yield curve snapshot is superseded or expires, marking the end of its validity period.',
    `interpolation_method` STRING COMMENT 'Mathematical method used to interpolate rates between tenor points (linear, cubic spline, Nelson-Siegel, Svensson, log-linear, Hermite).. Valid values are `linear|cubic_spline|nelson_siegel|svensson|log_linear|hermite`',
    `jurisdiction` STRING COMMENT 'Three-letter ISO country code representing the jurisdiction or sovereign issuer for government curves (e.g., USA, GBR, DEU, CAN, JPN).. Valid values are `^[A-Z]{3}$`',
    `notes` STRING COMMENT 'Free-text field for additional notes, comments, or context about the yield curve construction, data quality issues, or special circumstances.',
    `publication_timestamp` TIMESTAMP COMMENT 'Date and time when the yield curve data was published or made available by the source system.',
    `sector` STRING COMMENT 'Industry sector for corporate or credit spread curves (e.g., financials, industrials, utilities, energy). Not applicable for government curves.',
    `source_identifier` STRING COMMENT 'Unique identifier or ticker used by the source system to reference this yield curve (e.g., Bloomberg curve ticker).',
    `tenor_10y_discount_factor` DECIMAL(12,10) COMMENT 'Discount factor for 10-year tenor used to present-value future cash flows.',
    `tenor_10y_forward_rate` DECIMAL(12,8) COMMENT 'Forward rate for 10-year tenor, representing the implied future interest rate.',
    `tenor_10y_par_rate` DECIMAL(12,8) COMMENT 'Par yield for 10-year tenor, representing the coupon rate at which a bond would trade at par.',
    `tenor_10y_zero_rate` DECIMAL(12,8) COMMENT 'Zero-coupon rate for 10-year tenor expressed as a decimal (e.g., 0.0525 for 5.25%).',
    `tenor_15y_zero_rate` DECIMAL(12,8) COMMENT 'Zero-coupon rate for 15-year tenor expressed as a decimal (e.g., 0.0550 for 5.50%).',
    `tenor_1m_zero_rate` DECIMAL(12,8) COMMENT 'Zero-coupon rate for 1-month tenor expressed as a decimal (e.g., 0.0325 for 3.25%).',
    `tenor_1y_discount_factor` DECIMAL(12,10) COMMENT 'Discount factor for 1-year tenor used to present-value future cash flows (e.g., 0.9615 for 4% rate).',
    `tenor_1y_forward_rate` DECIMAL(12,8) COMMENT 'Forward rate for 1-year tenor, representing the implied future interest rate.',
    `tenor_1y_par_rate` DECIMAL(12,8) COMMENT 'Par yield for 1-year tenor, representing the coupon rate at which a bond would trade at par.',
    `tenor_1y_zero_rate` DECIMAL(12,8) COMMENT 'Zero-coupon rate for 1-year tenor expressed as a decimal (e.g., 0.0400 for 4.00%).',
    `tenor_20y_zero_rate` DECIMAL(12,8) COMMENT 'Zero-coupon rate for 20-year tenor expressed as a decimal (e.g., 0.0575 for 5.75%).',
    `tenor_2y_zero_rate` DECIMAL(12,8) COMMENT 'Zero-coupon rate for 2-year tenor expressed as a decimal (e.g., 0.0425 for 4.25%).',
    `tenor_30y_discount_factor` DECIMAL(12,10) COMMENT 'Discount factor for 30-year tenor used to present-value future cash flows.',
    `tenor_30y_par_rate` DECIMAL(12,8) COMMENT 'Par yield for 30-year tenor, representing the coupon rate at which a bond would trade at par.',
    `tenor_30y_zero_rate` DECIMAL(12,8) COMMENT 'Zero-coupon rate for 30-year tenor expressed as a decimal (e.g., 0.0600 for 6.00%).',
    `tenor_3m_zero_rate` DECIMAL(12,8) COMMENT 'Zero-coupon rate for 3-month tenor expressed as a decimal (e.g., 0.0350 for 3.50%).',
    `tenor_3y_zero_rate` DECIMAL(12,8) COMMENT 'Zero-coupon rate for 3-year tenor expressed as a decimal (e.g., 0.0450 for 4.50%).',
    `tenor_5y_discount_factor` DECIMAL(12,10) COMMENT 'Discount factor for 5-year tenor used to present-value future cash flows.',
    `tenor_5y_forward_rate` DECIMAL(12,8) COMMENT 'Forward rate for 5-year tenor, representing the implied future interest rate.',
    `tenor_5y_par_rate` DECIMAL(12,8) COMMENT 'Par yield for 5-year tenor, representing the coupon rate at which a bond would trade at par.',
    `tenor_5y_zero_rate` DECIMAL(12,8) COMMENT 'Zero-coupon rate for 5-year tenor expressed as a decimal (e.g., 0.0475 for 4.75%).',
    `tenor_6m_zero_rate` DECIMAL(12,8) COMMENT 'Zero-coupon rate for 6-month tenor expressed as a decimal (e.g., 0.0375 for 3.75%).',
    `tenor_7y_zero_rate` DECIMAL(12,8) COMMENT 'Zero-coupon rate for 7-year tenor expressed as a decimal (e.g., 0.0500 for 5.00%).',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this yield curve record was last modified or updated in the system.',
    `validation_status` STRING COMMENT 'Status of data quality validation checks performed on the yield curve data (passed, failed, pending, not validated).. Valid values are `passed|failed|pending|not_validated`',
    `version_number` BIGINT COMMENT 'Sequential version number for tracking revisions and updates to the yield curve for the same curve date.',
    CONSTRAINT pk_credit_yield_curve PRIMARY KEY(`credit_yield_curve_id`)
) COMMENT 'Reference data store for benchmark yield curves used in fixed income valuation and risk analytics, capturing curve type (government, swap, SOFR, OIS, credit spread curve), currency, tenor points, zero rates, par rates, forward rates, discount factors, and';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`benchmark_index` (
    `benchmark_index_id` BIGINT COMMENT 'Unique identifier for the benchmark index record.',
    `active_flag` BOOLEAN COMMENT 'Indicates whether this benchmark index record is currently active and in use.',
    `asset_class` STRING COMMENT 'Primary asset class category that the benchmark index represents. [ENUM-REF-CANDIDATE: Fixed Income|Credit|Government Bonds|Corporate Bonds|Emerging Markets Debt|High Yield|Investment Grade|Sovereign Debt — 8 candidates stripped; promote to reference',
    `base_date` DATE COMMENT 'Reference date from which the index value is calculated (typically set to 100).',
    `base_value` DECIMAL(10,2) COMMENT 'Initial index value at the base date (commonly 100 or 1000).',
    `benchmark_status` STRING COMMENT 'Current operational status of the benchmark index.. Valid values are `Active|Discontinued|Suspended|Under Review`',
    `bloomberg_ticker` STRING COMMENT 'Bloomberg terminal ticker symbol for the benchmark index.. Valid values are `^[A-Z0-9]{4,10}$`',
    `calculation_frequency` STRING COMMENT 'Frequency at which the index value is calculated and published.. Valid values are `Real-Time|End of Day|Intraday|Weekly`',
    `convexity` DECIMAL(10,4) COMMENT 'Measure of the curvature in the relationship between bond prices and yields for the index.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this benchmark index record was first created in the system.',
    `credit_quality` STRING COMMENT 'Credit rating category or quality tier of securities included in the index. [ENUM-REF-CANDIDATE: Investment Grade|High Yield|AAA|AA|A|BBB|BB|B|CCC|Mixed — 10 candidates stripped; promote to reference product]',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code in which the index is denominated.. Valid values are `^[A-Z]{3}$`',
    `current_index_level` DECIMAL(15,6) COMMENT 'Most recent calculated value of the index.',
    `data_source` STRING COMMENT 'Primary system or vendor from which benchmark data is sourced.. Valid values are `Bloomberg|FactSet|State Street|Northern Trust|SimCorp|Internal`',
    `duration_years` DECIMAL(8,4) COMMENT 'Effective duration of the index in years, measuring interest rate sensitivity.',
    `eligibility_criteria` STRING COMMENT 'Summary of rules and requirements for securities to be included in the index (e.g., minimum issue size, rating).',
    `esg_methodology` STRING COMMENT 'Description of ESG screening or integration approach if applicable.',
    `esg_screened_flag` BOOLEAN COMMENT 'Indicates whether the index applies ESG screening criteria to constituent selection.',
    `factset_index_code` STRING COMMENT 'FactSet proprietary identifier for the benchmark index.',
    `geographic_focus` STRING COMMENT 'Primary geographic region or market that the index covers. [ENUM-REF-CANDIDATE: Global|USA|EUR|GBR|CAN|JPN|CHN|Developed Markets|Emerging Markets|Asia Pacific|Latin America — 11 candidates stripped; promote to reference product]',
    `hedged_flag` BOOLEAN COMMENT 'Indicates whether the index includes currency hedging (True) or is unhedged (False).',
    `inception_date` DATE COMMENT 'Date when the benchmark index was first launched or calculated.',
    `index_code` STRING COMMENT 'Unique alphanumeric code identifying the benchmark index (e.g., LBUSTRUU for Bloomberg US Aggregate).. Valid values are `^[A-Z0-9]{3,20}$`',
    `index_family` STRING COMMENT 'Broader index family or suite to which this benchmark belongs (e.g., Bloomberg Global Aggregate family).',
    `index_level_date` DATE COMMENT 'Date as of which the current index level was calculated.',
    `index_name` STRING COMMENT 'Full official name of the benchmark index.',
    `index_provider` STRING COMMENT 'Organization that calculates and publishes the benchmark index. [ENUM-REF-CANDIDATE: Bloomberg|ICE BofA|FTSE Russell|JP Morgan|Barclays|MSCI|S&P Dow Jones — 7 candidates stripped; promote to reference product]',
    `index_type` STRING COMMENT 'Calculation methodology type for the index (total return includes reinvested income, price return excludes).. Valid values are `Total Return|Price Return|Excess Return|Hedged|Unhedged`',
    `isin` STRING COMMENT 'ISO 6166 standard 12-character alphanumeric code uniquely identifying the index.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `last_rebalance_date` DATE COMMENT 'Most recent date on which the index was rebalanced.',
    `mandate_compliance_flag` BOOLEAN COMMENT 'Indicates whether this benchmark is used for formal mandate compliance monitoring.',
    `market_value_usd` DECIMAL(20,2) COMMENT 'Total market capitalization of the index in USD.',
    `maturity_range` STRING COMMENT 'Maturity bucket or range of securities included (e.g., 1-3 years, 10+ years, All Maturities).',
    `methodology_document_url` STRING COMMENT 'Web link to the official index methodology document published by the provider.',
    `next_rebalance_date` DATE COMMENT 'Scheduled date for the next index rebalance.',
    `number_of_constituents` BIGINT COMMENT 'Total count of securities included in the benchmark index.',
    `oas_bps` DECIMAL(10,2) COMMENT 'Weighted average option-adjusted spread of the index in basis points.',
    `performance_attribution_flag` BOOLEAN COMMENT 'Indicates whether this benchmark is used for performance attribution analysis.',
    `rebalance_frequency` STRING COMMENT 'Frequency at which the index composition is reviewed and rebalanced.. Valid values are `Daily|Monthly|Quarterly|Semi-Annual|Annual`',
    `regulatory_classification` STRING COMMENT 'Regulatory designation or classification of the benchmark (e.g., EU BMR critical, significant, non-significant).',
    `ric_code` STRING COMMENT 'Reuters Instrument Code used to identify the index on Refinitiv platforms.',
    `sector_focus` STRING COMMENT 'Specific industry sector focus if the index is sector-specific (e.g., Financials, Utilities); null for broad indices.',
    `sedol` STRING COMMENT 'Seven-character alphanumeric code used to identify the index in UK and Irish markets.. Valid values are `^[A-Z0-9]{7}$`',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this benchmark index record was last modified.',
    `usage_purpose` STRING COMMENT 'Primary business use case for this benchmark (e.g., performance attribution, mandate compliance, portfolio construction).',
    `weighting_methodology` STRING COMMENT 'Method used to weight constituent securities within the index.. Valid values are `Market Cap Weighted|Equal Weighted|Duration Weighted|GDP Weighted|Custom`',
    `ytm_percent` DECIMAL(8,4) COMMENT 'Weighted average yield to maturity of the index constituents, expressed as a percentage.',
    CONSTRAINT pk_benchmark_index PRIMARY KEY(`benchmark_index_id`)
) COMMENT 'Reference master for fixed income benchmark indices used for performance attribution, portfolio construction, and mandate compliance (e.g., Bloomberg Global Aggregate, Bloomberg US Corporate IG, ICE BofA HY, FTSE WGBI, Bloomberg EM USD Aggregate).';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`credit_benchmark_constituent` (
    `credit_benchmark_constituent_id` BIGINT COMMENT 'Unique identifier for each benchmark constituent record, representing a specific security within a specific benchmark index at a specific rebalancing date.',
    `benchmark_index_id` BIGINT COMMENT 'Foreign key reference to the parent fixed income benchmark index to which this constituent belongs.',
    `fixed_income_security_id` BIGINT COMMENT 'Foreign key reference to the fixed income security master record for this constituent.',
    `accrued_interest` DECIMAL(15,4) COMMENT 'The amount of interest that has accumulated on the security since the last coupon payment date as of the rebalancing date.',
    `bloomberg_ticker` STRING COMMENT 'Bloomberg-specific ticker symbol used for market data retrieval and trading.',
    `callable_flag` BOOLEAN COMMENT 'Boolean indicator of whether the security contains an embedded call option allowing early redemption by the issuer.',
    `composite_rating_category` STRING COMMENT 'The composite credit rating category used by the benchmark index for classification purposes. [ENUM-REF-CANDIDATE: AAA|AA|A|BBB|BB|B|CCC|CC|C|D — 10 candidates stripped; promote to reference product]',
    `constituent_status` STRING COMMENT 'Current lifecycle status of this security within the benchmark index composition.. Valid values are `active|removed|suspended|pending|matured`',
    `convexity` DECIMAL(10,4) COMMENT 'The convexity measure of the security, capturing the curvature of the price-yield relationship.',
    `country_of_risk` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the primary country of credit risk exposure for the security.. Valid values are `^[A-Z]{3}$`',
    `coupon_rate` DECIMAL(10,6) COMMENT 'The annual coupon rate of the security, expressed as a decimal percentage of face value.',
    `credit_rating_fitch` STRING COMMENT 'The Fitch Ratings credit rating assigned to the security at the rebalancing date.',
    `credit_rating_moody` STRING COMMENT 'The Moodys Investors Service credit rating assigned to the security at the rebalancing date.',
    `credit_rating_sp` STRING COMMENT 'The Standard and Poors credit rating assigned to the security at the rebalancing date.',
    `cusip` STRING COMMENT 'Nine-character alphanumeric code identifying North American securities.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `data_source` STRING COMMENT 'The primary source system from which this constituent record was obtained.. Valid values are `bloomberg|factset|msci|index_provider|internal`',
    `duration_contribution` DECIMAL(10,4) COMMENT 'The weighted contribution of this security to the overall benchmark index duration, measured in years.',
    `dv01` DECIMAL(15,4) COMMENT 'The dollar value change in the security price for a one basis point change in yield.',
    `effective_duration` DECIMAL(10,4) COMMENT 'The effective duration accounting for embedded options, measuring interest rate sensitivity for callable or puttable bonds.',
    `effective_from_date` DATE COMMENT 'The date from which this security became an active constituent of the benchmark index.',
    `effective_to_date` DATE COMMENT 'The date until which this security remains an active constituent of the benchmark index, null if currently active.',
    `esg_rating` STRING COMMENT 'The ESG rating assigned to the security or issuer at the rebalancing date.',
    `exclusion_reason` STRING COMMENT 'The reason this security was removed from the benchmark index, if applicable.. Valid values are `matured|rating_downgrade|called|defaulted|index_rule_change|insufficient_liquidity`',
    `face_value` DECIMAL(20,2) COMMENT 'The par or face value of the security, representing the principal amount to be repaid at maturity.',
    `floating_rate_flag` BOOLEAN COMMENT 'Boolean indicator of whether the security has a floating coupon rate tied to a reference rate.',
    `green_bond_flag` BOOLEAN COMMENT 'Boolean indicator of whether the security is classified as a green bond under ESG criteria.',
    `inclusion_reason` STRING COMMENT 'The reason this security was added to the benchmark index at this rebalancing date.. Valid values are `new_issue|rebalancing|rating_upgrade|maturity_extension|index_rule_change`',
    `index_weight_percent` DECIMAL(10,6) COMMENT 'The percentage weight of this security within the benchmark index composition, expressed as a decimal percentage.',
    `investment_grade_flag` BOOLEAN COMMENT 'Boolean indicator of whether the security is classified as investment grade (BBB-/Baa3 or higher) at the rebalancing date.',
    `isin` STRING COMMENT 'ISO 6166 standard 12-character alphanumeric code uniquely identifying the fixed income security.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `issuer_lei` STRING COMMENT 'ISO 17442 standard 20-character code uniquely identifying the issuing legal entity.. Valid values are `^[A-Z0-9]{18}[0-9]{2}$`',
    `issuer_name` STRING COMMENT 'Legal name of the entity that issued the debt security.',
    `market_price` DECIMAL(15,6) COMMENT 'The market price of the security at the rebalancing date, typically expressed as a percentage of face value.',
    `market_value_contribution` DECIMAL(20,2) COMMENT 'The market value contribution of this security to the total benchmark index market value at the rebalancing date.',
    `market_value_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the market value contribution amount.. Valid values are `^[A-Z]{3}$`',
    `maturity_date` DATE COMMENT 'The date on which the principal amount of the security becomes due and payable.',
    `modified_duration` DECIMAL(10,4) COMMENT 'The modified duration of the security at the rebalancing date, measuring price sensitivity to yield changes.',
    `oas` DECIMAL(10,2) COMMENT 'The option-adjusted spread in basis points, measuring the yield spread over the risk-free rate after adjusting for embedded options.',
    `puttable_flag` BOOLEAN COMMENT 'Boolean indicator of whether the security contains an embedded put option allowing early redemption by the holder.',
    `rebalancing_date` DATE COMMENT 'The effective date of the index rebalancing event when this constituent composition was established.',
    `record_created_timestamp` TIMESTAMP COMMENT 'The timestamp when this constituent record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this constituent record was last modified in the system.',
    `sector_classification` STRING COMMENT 'The industry sector classification of the issuer according to the benchmark index methodology. [ENUM-REF-CANDIDATE: government|corporate|financial|utility|industrial|consumer|technology|healthcare|energy|telecommunications — promote to reference product]',
    `security_name` STRING COMMENT 'Full legal name or description of the fixed income security as it appears in the benchmark index.',
    `security_type` STRING COMMENT 'The classification of the fixed income security type within the benchmark index. [ENUM-REF-CANDIDATE: government_bond|corporate_bond|agency_bond|municipal_bond|asset_backed_security|mortgage_backed_security|covered_bond|convertible_bond — promote to',
    `sedol` STRING COMMENT 'Seven-character alphanumeric code identifying securities traded on the London Stock Exchange and other UK exchanges.. Valid values are `^[0-9]{6}[0-9A-Z]$`',
    `subordination_level` STRING COMMENT 'The seniority ranking of the security in the issuers capital structure, determining priority in default scenarios.. Valid values are `senior_secured|senior_unsecured|subordinated|junior_subordinated`',
    `yield_contribution` DECIMAL(10,6) COMMENT 'The weighted contribution of this security to the overall benchmark index yield.',
    `ytm` DECIMAL(10,6) COMMENT 'The yield to maturity of the security at the rebalancing date, expressed as a decimal percentage.',
    CONSTRAINT pk_credit_benchmark_constituent PRIMARY KEY(`credit_benchmark_constituent_id`)
) COMMENT 'Time-series record of securities comprising each fixed income benchmark index at each rebalancing date, capturing security ISIN, index weight, market value contribution, duration contribution, yield contribution, sector classification, country, and rating';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`credit_issuer` (
    `credit_issuer_id` BIGINT COMMENT 'Unique identifier for the credit issuer entity in the pension funds investment universe.',
    `parent_credit_issuer_id` BIGINT COMMENT 'Self-referencing FK on credit_issuer (parent_credit_issuer_id)',
    `active_flag` BOOLEAN COMMENT 'Boolean indicator whether the issuer record is currently active in the investment universe.',
    `country_of_domicile` STRING COMMENT 'ISO 3166-1 alpha-3 country code where the issuer is legally incorporated or domiciled.. Valid values are `^[A-Z]{3}$`',
    `country_of_risk` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the primary geographic risk exposure of the issuer.. Valid values are `^[A-Z]{3}$`',
    `coverage_end_date` DATE COMMENT 'Date when the pension fund ceased coverage of this issuer if no longer tracked.',
    `coverage_start_date` DATE COMMENT 'Date when the pension fund began tracking and covering this issuer in its investment universe.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this issuer record was first created in the lakehouse.',
    `credit_rating_fitch` STRING COMMENT 'Current long-term issuer credit rating assigned by Fitch Ratings.',
    `credit_rating_moody` STRING COMMENT 'Current long-term issuer credit rating assigned by Moodys Investors Service.',
    `credit_rating_sp` STRING COMMENT 'Current long-term issuer credit rating assigned by Standard & Poors.',
    `debt_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the primary currency of the issuers debt issuance.. Valid values are `^[A-Z]{3}$`',
    `default_date` DATE COMMENT 'Date when the issuer entered default status on any debt obligation.',
    `default_flag` BOOLEAN COMMENT 'Boolean indicator whether the issuer is currently in default on any debt obligations.',
    `ebitda` DECIMAL(18,2) COMMENT 'EBITDA reported by the issuer for the most recent fiscal year.',
    `esg_rating_msci` STRING COMMENT 'MSCI ESG rating assessing the issuers management of ESG risks and opportunities. [ENUM-REF-CANDIDATE: AAA|AA|A|BBB|BB|B|CCC — 7 candidates stripped; promote to reference product]',
    `esg_rating_sustainalytics` STRING COMMENT 'Sustainalytics ESG risk rating score measuring the issuers exposure to material ESG risks.',
    `fiscal_year_end` STRING COMMENT 'Month and day of the issuers fiscal year end in MM-DD format.. Valid values are `^(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$`',
    `ghg_emissions_scope_1_2` DECIMAL(18,2) COMMENT 'Total Scope 1 and Scope 2 greenhouse gas emissions in metric tons of CO2 equivalent reported by the issuer.',
    `industry_sector_gics` STRING COMMENT 'GICS sector classification code identifying the issuers primary industry sector.',
    `industry_sector_icb` STRING COMMENT 'ICB sector classification code identifying the issuers primary industry sector.',
    `investment_grade_flag` BOOLEAN COMMENT 'Boolean indicator whether the issuer holds investment grade credit rating (BBB-/Baa3 or higher).',
    `issuer_type` STRING COMMENT 'Classification of the issuer by organizational structure and legal status.. Valid values are `corporate|sovereign|supranational|municipal|agency|financial_institution`',
    `kyc_next_review_date` DATE COMMENT 'Scheduled date for the next periodic KYC review of the issuer.',
    `kyc_review_date` DATE COMMENT 'Date of the most recent KYC review and approval for the issuer.',
    `kyc_status` STRING COMMENT 'Current KYC and AML compliance status for the issuer as a counterparty.. Valid values are `approved|pending|rejected|expired`',
    `legal_name` STRING COMMENT 'Full legal name of the issuer as registered with regulatory authorities.',
    `lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier uniquely identifying the issuer globally.. Valid values are `^[A-Z0-9]{20}$`',
    `listing_exchange` STRING COMMENT 'Primary stock exchange where the issuers equity securities are listed if publicly traded.',
    `market_capitalization` DECIMAL(18,2) COMMENT 'Total market value of the issuers outstanding equity securities for corporate issuers.',
    `pri_signatory_flag` BOOLEAN COMMENT 'Boolean indicator whether the issuer is a signatory to the UN Principles for Responsible Investment.',
    `public_private_flag` BOOLEAN COMMENT 'Indicator whether the issuer is a publicly traded or privately held entity.',
    `rating_outlook_fitch` STRING COMMENT 'Current rating outlook assigned by Fitch indicating potential rating direction.. Valid values are `positive|stable|negative|evolving`',
    `rating_outlook_moody` STRING COMMENT 'Current rating outlook assigned by Moodys indicating potential rating direction.. Valid values are `positive|stable|negative|developing`',
    `rating_outlook_sp` STRING COMMENT 'Current rating outlook assigned by Standard & Poors indicating potential rating direction.. Valid values are `positive|stable|negative|developing`',
    `regulatory_status` STRING COMMENT 'Current regulatory standing of the issuer with relevant securities and financial regulators.. Valid values are `active|suspended|delisted|under_review`',
    `sanctioned_entity_flag` BOOLEAN COMMENT 'Boolean indicator whether the issuer appears on any international sanctions lists.',
    `short_name` STRING COMMENT 'Abbreviated or common name of the issuer used in market communications and reporting.',
    `source_identifier` STRING COMMENT 'Unique identifier for this issuer in the source system of record.',
    `tcfd_reporting_flag` BOOLEAN COMMENT 'Boolean indicator whether the issuer publishes TCFD-aligned climate disclosures.',
    `ticker_symbol` STRING COMMENT 'Primary equity ticker symbol for the issuer on its listing exchange.',
    `total_assets` DECIMAL(18,2) COMMENT 'Total assets reported on the issuers most recent audited balance sheet.',
    `total_debt_outstanding` DECIMAL(18,2) COMMENT 'Total face value of all debt securities issued and outstanding by the issuer.',
    `total_revenue` DECIMAL(18,2) COMMENT 'Total revenue reported by the issuer for the most recent fiscal year.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this issuer record was last modified in the lakehouse.',
    `watchlist_flag` BOOLEAN COMMENT 'Boolean indicator whether the issuer is on credit watch by any major rating agency.',
    CONSTRAINT pk_credit_issuer PRIMARY KEY(`credit_issuer_id`)
) COMMENT 'Master record for corporate and sovereign debt issuers covered by the pension funds credit investment universe, capturing issuer legal name, LEI, parent entity, country of domicile, country of risk, industry sector (GICS/ICB), issuer type (corporate';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`maturity_schedule` (
    `maturity_schedule_id` BIGINT COMMENT 'Unique identifier for each maturity schedule entry in the fixed income portfolio.',
    `counterparty_id` BIGINT COMMENT 'Reference to the counterparty (issuer or custodian) responsible for executing the redemption.',
    `custodian_id` BIGINT COMMENT 'Reference to the custodian bank holding the security and processing the redemption settlement.',
    `fixed_income_security_id` BIGINT COMMENT 'Reference to the underlying fixed income security for which this maturity schedule applies.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio holding this security position.',
    `cash_account_id` BIGINT COMMENT 'Reference to the cash account that will receive redemption proceeds.',
    `accrued_interest` DECIMAL(20,2) COMMENT 'Interest accrued from the last coupon payment date to the redemption event date, payable to the holder.',
    `active_flag` BOOLEAN COMMENT 'Indicates whether this maturity schedule entry is currently active and applicable for portfolio planning and reporting.',
    `benchmark_rate` DECIMAL(18,2) COMMENT 'Reference benchmark rate used for make-whole calculations or floating rate adjustments at redemption.',
    `benchmark_tenor` STRING COMMENT 'Tenor of the benchmark rate used in make-whole or floating rate calculations. [ENUM-REF-CANDIDATE: overnight|1M|3M|6M|1Y|2Y|5Y|10Y|30Y — 9 candidates stripped; promote to reference product]',
    `call_price` DECIMAL(12,6) COMMENT 'Price at which the issuer may call (redeem early) the bond, expressed as percentage of par value.',
    `call_protection_end_date` DATE COMMENT 'Date after which the issuer may exercise call options; bonds are non-callable before this date.',
    `convexity_to_event` DECIMAL(10,4) COMMENT 'Convexity calculated to this specific redemption event, measuring the curvature of price-yield relationship.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this maturity schedule entry was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code for all monetary amounts in this schedule entry.. Valid values are `^[A-Z]{3}$`',
    `data_source` STRING COMMENT 'System or source from which this maturity schedule entry was obtained. [ENUM-REF-CANDIDATE: Bloomberg|SimCorp|State_Street|Northern_Trust|FactSet|manual_entry|issuer_notice — 7 candidates stripped; promote to reference product]',
    `duration_to_event` DECIMAL(8,4) COMMENT 'Modified duration calculated to this specific redemption event date, measuring interest rate sensitivity.',
    `event_date` DATE COMMENT 'Date on which the maturity, call, put, or sinking fund redemption event is scheduled to occur.',
    `exercise_decision_date` DATE COMMENT 'Date on which the decision to exercise or not exercise the call or put option was made.',
    `exercise_status` STRING COMMENT 'Current status of the optional redemption right: pending decision, exercised, not exercised, expired, or cancelled.. Valid values are `pending|exercised|not_exercised|expired|cancelled`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this maturity schedule entry was last updated in the system.',
    `liquidity_impact_flag` BOOLEAN COMMENT 'Indicates whether this redemption event has material impact on portfolio liquidity and cash management planning.',
    `make_whole_provision_flag` BOOLEAN COMMENT 'Indicates whether a make-whole call provision applies, requiring the issuer to compensate investors for lost future interest.',
    `make_whole_spread_bps` DECIMAL(8,2) COMMENT 'Spread in basis points over the reference treasury rate used to calculate the make-whole call price.',
    `notes` STRING COMMENT 'Free-text field for additional comments, special conditions, or analyst notes regarding this redemption event.',
    `notification_date` DATE COMMENT 'Date by which the issuer or investor must provide notice of intent to exercise a call or put option.',
    `option_adjusted_spread_bps` DECIMAL(8,2) COMMENT 'Option-adjusted spread in basis points, reflecting the credit spread after removing embedded option value.',
    `optional_redemption_flag` BOOLEAN COMMENT 'Indicates whether the redemption is optional (call or put) versus mandatory (maturity or sinking fund).',
    `outstanding_principal_after` DECIMAL(20,2) COMMENT 'Principal amount remaining outstanding after this redemption event is executed.',
    `outstanding_principal_before` DECIMAL(20,2) COMMENT 'Principal amount outstanding immediately before this redemption event.',
    `probability_of_exercise` DECIMAL(5,2) COMMENT 'Estimated probability (0-100%) that an optional call or put will be exercised, based on market conditions and analytics.',
    `put_price` DECIMAL(12,6) COMMENT 'Price at which the investor may put (sell back) the bond to the issuer, expressed as percentage of par value.',
    `redemption_amount` DECIMAL(20,2) COMMENT 'Expected principal amount to be redeemed at this event, expressed in the security currency.',
    `redemption_percentage` DECIMAL(5,2) COMMENT 'Percentage of the outstanding principal being redeemed at this event, used for partial redemptions.',
    `redemption_price` DECIMAL(12,6) COMMENT 'Price per unit (typically percentage of par) at which the security will be redeemed.',
    `reinvestment_rate_assumption` DECIMAL(8,4) COMMENT 'Assumed reinvestment rate for proceeds from this redemption event, used in yield and duration calculations.',
    `reinvestment_strategy` STRING COMMENT 'Planned strategy for reinvesting proceeds from this redemption event.. Valid values are `same_asset_class|duration_match|yield_enhancement|cash_hold|tactical_allocation`',
    `schedule_type` STRING COMMENT 'Type of redemption event: maturity (final redemption), call (issuer option), put (investor option), sinking fund (scheduled partial redemption), amortization (structured paydown), or prepayment (early unscheduled).. Valid values are `maturity|call|put|sinking_fund|amortization|prepayment`',
    `settlement_date` DATE COMMENT 'Date on which cash and securities are exchanged for the redemption event.',
    `settlement_method` STRING COMMENT 'Method by which the redemption will settle: Delivery Versus Payment (DVP), Free of Payment (FOP), cash settlement, or physical delivery.. Valid values are `DVP|FOP|cash_settlement|physical_delivery`',
    `sinking_fund_schedule_flag` BOOLEAN COMMENT 'Indicates whether this event is part of a mandatory sinking fund schedule requiring periodic partial redemptions.',
    `tax_treatment` STRING COMMENT 'Expected tax treatment of the redemption proceeds for reporting and planning purposes.. Valid values are `capital_gain|ordinary_income|tax_exempt|return_of_capital|other`',
    `total_proceeds` DECIMAL(20,2) COMMENT 'Total cash proceeds expected from the redemption event, including principal and accrued interest.',
    `yield_to_event` DECIMAL(8,4) COMMENT 'Yield calculated assuming the bond is held until this specific redemption event occurs.',
    CONSTRAINT pk_maturity_schedule PRIMARY KEY(`maturity_schedule_id`)
) COMMENT 'Forward-looking maturity and redemption schedule for the fixed income portfolio, capturing each securitys maturity date, call dates (for callable bonds), put dates (for putable bonds), sinking fund schedule, expected redemption amount, and redemption';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`default_event` (
    `default_event_id` BIGINT COMMENT 'Unique identifier for the credit default event record.',
    `credit_issuer_id` BIGINT COMMENT 'Identifier of the issuer or reference entity experiencing the credit event.',
    `fixed_income_security_id` BIGINT COMMENT 'Identifier of the specific debt instrument or obligation subject to the credit event.',
    `portfolio_id` BIGINT COMMENT 'Identifier of the investment portfolio holding exposure to the defaulted entity.',
    `reference_entity_actor_id` BIGINT COMMENT 'Foreign key linking to shared.actor. Business justification: Default event refers to the issuer; needed for event reporting, loss estimation, and regulatory compliance.',
    `reference_entity_credit_issuer_id` BIGINT COMMENT 'Identifier of the issuer or reference entity experiencing the credit event.',
    `affected_bond_positions` BIGINT COMMENT 'Number of direct bond or fixed income security positions in the portfolio affected by this credit event.',
    `affected_cds_contracts` BIGINT COMMENT 'Number of credit default swap contracts in the portfolio directly affected by this credit event and subject to settlement or valuation adjustment.',
    `announcement_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the credit event was publicly announced or disclosed by the issuer, regulator, or market authority.',
    `auction_date` DATE COMMENT 'Date of the ISDA credit event auction used to determine the final recovery price for cash settlement of credit default swaps.',
    `auction_final_price` DECIMAL(18,6) COMMENT 'Final recovery price determined by the ISDA credit event auction, expressed as a percentage of par value (e.g., 40.00 represents 40% recovery).',
    `contagion_risk_flag` BOOLEAN COMMENT 'Indicates whether the credit event poses systemic or contagion risk to other portfolio holdings, counterparties, or market segments, requiring heightened monitoring.',
    `country_of_risk` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code representing the primary country of credit risk exposure for the reference entity.. Valid values are `^[A-Z]{3}$`',
    `credit_rating_at_event` STRING COMMENT 'The credit rating assigned to the reference entity or obligation immediately prior to or at the time of the credit event, typically from S&P, Moodys, or Fitch.',
    `data_source` STRING COMMENT 'Source system or data provider from which the credit event information was obtained (e.g., Bloomberg, Markit, internal credit risk system, ISDA).',
    `dc_determination_flag` BOOLEAN COMMENT 'Indicates whether the credit event was formally determined by an ISDA regional Determinations Committee (true) or identified through internal credit monitoring (false).',
    `dc_region` STRING COMMENT 'Geographic region of the ISDA Determinations Committee that issued the credit event determination: Americas, EMEA, Asia, Japan, or Australia/New Zealand.. Valid values are `americas|emea|asia|japan|australia_new_zealand`',
    `determination_date` DATE COMMENT 'Date on which the ISDA Determinations Committee formally determined that a credit event has occurred.',
    `estimated_loss_amount` DECIMAL(20,2) COMMENT 'Estimated monetary loss resulting from the credit event, calculated as exposure at default multiplied by loss given default.',
    `event_date` DATE COMMENT 'The date on which the credit event occurred or was publicly announced, as determined by the ISDA Determinations Committee or internal credit risk team.',
    `event_identifier` STRING COMMENT 'Externally-known unique identifier or reference number for this credit event, often assigned by ISDA Determinations Committee or market infrastructure.',
    `event_status` STRING COMMENT 'Current lifecycle status of the credit event: potential (under review), confirmed (DC determination issued), rejected (not a credit event), settled (cash or physical settlement completed), or disputed (under legal challenge).. Valid values are `potential|confirmed|rejected|settled|disputed`',
    `event_type` STRING COMMENT 'Classification of the credit event as defined under ISDA Credit Derivatives Definitions: bankruptcy, failure to pay, restructuring, obligation acceleration, repudiation/moratorium, or governmental intervention.. Valid values are `bankruptcy|failure_to_pay|restructuring|obligation_acceleration|repudiation_moratorium|governmental_intervention`',
    `exposure_at_default` DECIMAL(20,2) COMMENT 'Total notional exposure to the reference entity or obligation at the time of the credit event, across all positions and instruments in the portfolio.',
    `exposure_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the exposure at default amount.. Valid values are `^[A-Z]{3}$`',
    `ic_notification_date` DATE COMMENT 'Date on which the Investment Committee was formally notified of the credit event and its portfolio impact.',
    `legal_counsel_engaged` BOOLEAN COMMENT 'Indicates whether external legal counsel has been engaged to represent the funds interests in bankruptcy proceedings, restructuring negotiations, or litigation related to this credit event.',
    `loss_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the estimated and realized loss amounts.. Valid values are `^[A-Z]{3}$`',
    `loss_given_default` DECIMAL(5,4) COMMENT 'Loss severity as a percentage of exposure at default, calculated as 1 minus recovery rate. Used for credit risk capital calculations and portfolio loss estimation.',
    `notes` STRING COMMENT 'Free-text field for additional context, internal analysis, or special circumstances related to the credit event that do not fit structured fields.',
    `public_information_source` STRING COMMENT 'Citation of the publicly available information source used to verify the credit event, as required by ISDA definitions (e.g., Bloomberg, Reuters, regulatory filing, court document).',
    `rating_agency` STRING COMMENT 'The rating agency that assigned the credit rating at event date: S&P, Moodys, Fitch, DBRS, or other recognized agency.. Valid values are `sp|moodys|fitch|dbrs|other`',
    `realized_loss_amount` DECIMAL(20,2) COMMENT 'Actual realized loss after settlement, workout, or liquidation of the defaulted position. Null until final settlement is completed.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this credit event record was first created in the system.',
    `record_updated_by` STRING COMMENT 'User identifier or system account that last updated this credit event record, for audit trail purposes.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this credit event record was last modified, reflecting updates to status, settlement details, or loss estimates.',
    `recovery_rate` DECIMAL(5,4) COMMENT 'Estimated or actual recovery rate on the defaulted obligation, expressed as a decimal (e.g., 0.4000 represents 40% recovery). May be based on auction results, market pricing, or internal valuation.',
    `regulatory_reporting_required` BOOLEAN COMMENT 'Indicates whether this credit event triggers mandatory regulatory reporting obligations to SEC, or other supervisory authorities.',
    `restructuring_type` STRING COMMENT 'Type of restructuring clause applicable to the credit event: Modified Restructuring (Mod R), Modified Modified Restructuring (Mod Mod R), No Restructuring, or Full Restructuring. Relevant for restructuring credit events.. Valid values are `mod_r|mod_mod_r|no_restructuring|full_restructuring`',
    `sector` STRING COMMENT 'Industry sector or economic classification of the reference entity experiencing the credit event (e.g., financials, energy, industrials, sovereign).',
    `seniority` STRING COMMENT 'Seniority ranking of the defaulted obligation in the capital structure: senior secured, senior unsecured, subordinated, or junior subordinated. Determines recovery priority.. Valid values are `senior_secured|senior_unsecured|subordinated|junior_subordinated`',
    `settlement_date` DATE COMMENT 'Date on which settlement of credit default swap positions or other credit derivatives was completed following the credit event.',
    `settlement_method` STRING COMMENT 'Method used to settle credit default swap positions triggered by this event: cash settlement, physical delivery of defaulted obligations, or ISDA auction-based settlement.. Valid values are `cash|physical|auction`',
    `sovereign_flag` BOOLEAN COMMENT 'Indicates whether the credit event involves a sovereign government entity (true) or a corporate/financial institution entity (false).',
    `trigger_event_description` STRING COMMENT 'Detailed narrative description of the specific event or circumstances that triggered the credit event determination, including relevant facts and timeline.',
    `workout_strategy` STRING COMMENT 'Summary of the planned or executed workout strategy for the defaulted position: hold for recovery, participate in restructuring, sell at market, legal action, or other approach.',
    CONSTRAINT pk_default_event PRIMARY KEY(`default_event_id`)
) COMMENT 'Transactional record of credit events (as defined under ISDA) affecting issuers or reference entities in the portfolio, including bankruptcy, failure to pay, restructuring, obligation acceleration, repudiation/moratorium, and governmental intervention.';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`sofr_rate` (
    `sofr_rate_id` BIGINT COMMENT 'Unique identifier for the SOFR rate record.',
    `benchmark_status` STRING COMMENT 'Current regulatory status of the SOFR benchmark rate.. Valid values are `active|discontinued|under_review`',
    `business_day_convention` STRING COMMENT 'Convention for adjusting rate effective dates when they fall on non-business days.. Valid values are `following|modified_following|preceding`',
    `calendar` STRING COMMENT 'Holiday calendar used to determine business days for SOFR rate publication and application.. Valid values are `us_government_securities|us_federal_reserve|nyse|london`',
    `compounding_method` STRING COMMENT 'Method used for compounding SOFR rates over the averaging period (simple, compound in arrears, compound in advance).. Valid values are `simple|compound_in_arrears|compound_in_advance`',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the rate (typically USD for SOFR).. Valid values are `^[A-Z]{3}$`',
    `data_quality_flag` BOOLEAN COMMENT 'Quality status of the rate data indicating verification level and reliability.',
    `day_count_convention` STRING COMMENT 'Day count convention applied to SOFR rate calculations (Actual/360, Actual/365, 30/360).. Valid values are `actual_360|actual_365|30_360`',
    `effective_date` DATE COMMENT 'Date for which this SOFR rate is effective and applicable.',
    `fallback_rate_flag` BOOLEAN COMMENT 'Indicates whether this rate is being used as a fallback replacement for LIBOR (London Interbank Offered Rate) or another discontinued benchmark.',
    `index_value` DECIMAL(18,8) COMMENT 'Cumulative compounded SOFR index value used for calculating interest accruals on floating rate instruments.',
    `percentile_1` DECIMAL(12,8) COMMENT 'First percentile of the rate distribution used in SOFR calculation, providing insight into rate dispersion.',
    `percentile_25` DECIMAL(12,8) COMMENT 'Twenty-fifth percentile of the rate distribution used in SOFR calculation.',
    `percentile_75` DECIMAL(12,8) COMMENT 'Seventy-fifth percentile of the rate distribution used in SOFR calculation.',
    `percentile_99` DECIMAL(12,8) COMMENT 'Ninety-ninth percentile of the rate distribution used in SOFR calculation.',
    `publication_timestamp` TIMESTAMP COMMENT 'Timestamp when the rate was officially published by the Federal Reserve Bank of New York or CME (Chicago Mercantile Exchange).',
    `rate_bps` DECIMAL(10,2) COMMENT 'The SOFR rate expressed in basis points for fixed income analytics (e.g., 500 bps for 5%).',
    `rate_type` STRING COMMENT 'Type of SOFR rate: overnight, compounded averages (30/90/180 day), or term rates (1M/3M/6M/12M). [ENUM-REF-CANDIDATE: overnight|30_day_average|90_day_average|180_day_average|term_1m|term_3m|term_6m|term_12m — 8 candidates stripped; promote to reference',
    `rate_value` DECIMAL(12,8) COMMENT 'The published SOFR rate value expressed as a decimal percentage (e.g., 0.05 for 5%).',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this rate record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this rate record was last updated in the system.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this rate is used for regulatory reporting purposes (True if used, False otherwise).',
    `revision_flag` BOOLEAN COMMENT 'Indicates whether this rate has been revised after initial publication (True if revised, False if original).',
    `revision_reason` STRING COMMENT 'Explanation for why the rate was revised after initial publication.',
    `revision_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent revision to this rate record, if applicable.',
    `source` STRING COMMENT 'Source system or vendor from which the SOFR rate was obtained (Federal Reserve, CME, Bloomberg, Refinitiv).. Valid values are `federal_reserve|cme|bloomberg|refinitiv`',
    `spread_to_fed_funds` DECIMAL(10,4) COMMENT 'Spread in basis points between SOFR and the Federal Funds effective rate.',
    `spread_to_ois` DECIMAL(10,4) COMMENT 'Spread in basis points between SOFR and the corresponding OIS rate, used for relative value analysis.',
    `tenor_days` BIGINT COMMENT 'Number of days in the tenor period for term SOFR rates (e.g., 30, 90, 180, 360).',
    `volume_billions_usd` DECIMAL(18,2) COMMENT 'Total transaction volume in billions of USD underlying the SOFR calculation for overnight rates.',
    CONSTRAINT pk_sofr_rate PRIMARY KEY(`sofr_rate_id`)
) COMMENT 'Reference data time-series for SOFR (Secured Overnight Financing Rate) and related overnight/term rates (SOFR compounded in arrears, Term SOFR 1M/3M/6M/12M, SOFR OIS rates) published by the Federal Reserve Bank of New York and CME.';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`credit_mandate` (
    `credit_mandate_id` BIGINT COMMENT 'Unique identifier for the credit mandate record.',
    `benchmark_index_id` BIGINT COMMENT 'Foreign key linking to credit.benchmark_index. Business justification: Credit mandates reference benchmark indices for performance attribution and compliance.',
    `approval_authority` STRING COMMENT 'Name or title of the authority that approved this mandate (e.g., Investment Committee, Board of Directors).',
    `approval_date` DATE COMMENT 'Date when the mandate was formally approved by the governing authority.',
    `asset_class_scope` STRING COMMENT 'Comma-separated list of credit asset classes covered by this mandate (e.g., IG, HY, private credit, sovereign, structured products, T-Bills, SOFR-linked instruments).',
    `base_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for mandate reporting and allocation amounts.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this mandate record was first created in the system.',
    `credit_quality_minimum` STRING COMMENT 'Minimum credit rating threshold for investments (e.g., BBB-, B+, unrated allowed).',
    `derivatives_allowed_flag` BOOLEAN COMMENT 'Indicates whether derivatives (CDS, interest rate swaps, options) are permitted within this mandate.',
    `document_reference` STRING COMMENT 'Reference identifier or URL to the formal mandate documentation.',
    `duration_maximum_years` DECIMAL(8,2) COMMENT 'Maximum allowable portfolio duration in years.',
    `duration_minimum_years` DECIMAL(8,2) COMMENT 'Minimum allowable portfolio duration in years.',
    `duration_target_years` DECIMAL(8,2) COMMENT 'Target portfolio duration in years for interest rate risk management.',
    `esg_exclusion_list` STRING COMMENT 'Comma-separated list of sectors or activities excluded based on ESG criteria (e.g., tobacco, weapons, fossil fuels).',
    `esg_integration_level` STRING COMMENT 'Level of ESG integration required for investments within this mandate.. Valid values are `none|basic|integrated|thematic|impact`',
    `geographic_concentration_limit_pct` DECIMAL(5,2) COMMENT 'Maximum percentage of portfolio that can be allocated to any single country or region.',
    `hy_allocation_maximum_pct` DECIMAL(5,2) COMMENT 'Maximum percentage of portfolio that can be high yield securities.',
    `hy_allocation_minimum_pct` DECIMAL(5,2) COMMENT 'Minimum percentage of portfolio that must be high yield securities.',
    `ig_allocation_maximum_pct` DECIMAL(5,2) COMMENT 'Maximum percentage of portfolio that can be investment grade rated securities.',
    `ig_allocation_minimum_pct` DECIMAL(5,2) COMMENT 'Minimum percentage of portfolio that must be investment grade rated securities.',
    `inception_date` DATE COMMENT 'Date when the credit mandate was established and became effective.',
    `investment_strategy` STRING COMMENT 'Description of the investment strategy and approach for this credit mandate (e.g., core plus, opportunistic, distressed, direct lending).',
    `leverage_allowed_flag` BOOLEAN COMMENT 'Indicates whether leverage is permitted within this mandate.',
    `leverage_maximum_ratio` DECIMAL(5,2) COMMENT 'Maximum leverage ratio allowed (e.g., 1.5 means 150% gross exposure to NAV).',
    `liquidity_requirement_days` BIGINT COMMENT 'Minimum number of days within which a specified percentage of the portfolio must be liquidatable.',
    `liquidity_threshold_pct` DECIMAL(5,2) COMMENT 'Percentage of portfolio that must meet the liquidity requirement timeframe.',
    `mandate_code` STRING COMMENT 'Unique business identifier or code assigned to the mandate for operational reference.',
    `mandate_name` STRING COMMENT 'Business name or title of the credit investment mandate.',
    `mandate_status` STRING COMMENT 'Current lifecycle status of the credit mandate.. Valid values are `active|inactive|suspended|pending_approval|closed|under_review`',
    `mandate_type` STRING COMMENT 'Classification of the mandate structure and management approach.. Valid values are `discretionary|advisory|segregated|pooled|overlay|tactical`',
    `maximum_allocation_amount` DECIMAL(18,2) COMMENT 'Maximum investment amount constraint for this mandate in base currency.',
    `minimum_allocation_amount` DECIMAL(18,2) COMMENT 'Minimum investment amount constraint for this mandate in base currency.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal mandate review.',
    `notes` STRING COMMENT 'Additional notes, comments, or special instructions related to the mandate.',
    `performance_target_return_pct` DECIMAL(5,2) COMMENT 'Target annualized return objective for the mandate expressed as a percentage.',
    `performance_target_type` STRING COMMENT 'Type of performance target (absolute return, relative to benchmark, or relative to liability growth).. Valid values are `absolute|relative_to_benchmark|relative_to_liability`',
    `portfolio_manager_name` STRING COMMENT 'Name of the portfolio manager or team responsible for executing this mandate.',
    `private_credit_allocation_maximum_pct` DECIMAL(5,2) COMMENT 'Maximum percentage of portfolio that can be allocated to private credit investments.',
    `rebalancing_frequency` STRING COMMENT 'Frequency at which the portfolio is rebalanced to target allocations.. Valid values are `daily|weekly|monthly|quarterly|threshold_based|discretionary`',
    `rebalancing_threshold_pct` DECIMAL(5,2) COMMENT 'Percentage deviation from target allocation that triggers rebalancing.',
    `review_frequency` STRING COMMENT 'Scheduled frequency for formal mandate performance and compliance review.. Valid values are `monthly|quarterly|semi_annual|annual|ad_hoc`',
    `sector_concentration_limit_pct` DECIMAL(5,2) COMMENT 'Maximum percentage of portfolio that can be allocated to any single industry sector.',
    `single_issuer_limit_pct` DECIMAL(5,2) COMMENT 'Maximum percentage of portfolio that can be invested in securities from a single issuer.',
    `sovereign_allocation_maximum_pct` DECIMAL(5,2) COMMENT 'Maximum percentage of portfolio that can be allocated to sovereign debt.',
    `structured_products_allocation_maximum_pct` DECIMAL(5,2) COMMENT 'Maximum percentage of portfolio that can be allocated to structured credit products (ABS, MBS, CLO).',
    `target_allocation_amount` DECIMAL(18,2) COMMENT 'Target investment amount allocated to this mandate in base currency.',
    `termination_date` DATE COMMENT 'Date when the mandate was or will be terminated; null for open-ended mandates.',
    `tracking_error_limit_pct` DECIMAL(5,2) COMMENT 'Maximum allowable tracking error versus benchmark expressed as annualized standard deviation percentage.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this mandate record was last updated.',
    `var_confidence_level_pct` DECIMAL(5,2) COMMENT 'Confidence level for VaR calculation (e.g., 95%, 99%).',
    `var_limit_pct` DECIMAL(5,2) COMMENT 'Maximum allowable Value at Risk as a percentage of portfolio value at specified confidence level.',
    `var_time_horizon_days` BIGINT COMMENT 'Time horizon in days for VaR calculation (e.g., 1-day, 10-day).',
    CONSTRAINT pk_credit_mandate PRIMARY KEY(`credit_mandate_id`)
) COMMENT 'Master record defining the investment mandate parameters and constraints for each credit portfolio or sub-portfolio managed by the pension fund, capturing mandate name, asset class scope (IG, HY, private credit, sovereign, structured), minimum/maximum';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`spread_analytics` (
    `spread_analytics_id` BIGINT COMMENT 'Unique identifier for the spread analytics record.',
    `fixed_income_security_id` BIGINT COMMENT 'Identifier linking to the fixed income security.',
    `portfolio_id` BIGINT COMMENT 'Identifier linking to the portfolio containing the security.',
    `event_source` STRING COMMENT 'System that generated the analytics data.. Valid values are `Bloomberg|Aladdin|SimCorp`',
    `event_timestamp` TIMESTAMP COMMENT 'Timestamp of the analytics snapshot.',
    `event_type` STRING COMMENT 'Type of analytics event.. Valid values are `daily_snapshot|recalculation|adjustment`',
    `security_accrued_interest` DECIMAL(18,2) COMMENT 'Accrued interest on the security.',
    `security_asset_swap_spread` DECIMAL(10,6) COMMENT 'Asset-swap spread of the security.',
    `security_callability_flag` BOOLEAN COMMENT 'Indicates if the security is callable.',
    `security_convexity` DECIMAL(10,6) COMMENT 'Convexity of the security.',
    `security_country_of_risk` STRING COMMENT 'ISO 3166-1 alpha-3 country code of risk.. Valid values are `^[A-Z]{3}$`',
    `security_coupon_frequency` STRING COMMENT 'Frequency of coupon payments.. Valid values are `annual|semiannual|quarterly|monthly|daily`',
    `security_coupon_rate` DECIMAL(10,6) COMMENT 'Annual coupon rate of the security.',
    `security_credit_rating_fitch` STRING COMMENT 'Fitch credit rating for the security.',
    `security_credit_rating_moody` STRING COMMENT 'Moodys credit rating for the security.',
    `security_credit_rating_sp` STRING COMMENT 'Standard & Poors credit rating for the security.',
    `security_currency` STRING COMMENT 'ISO 4217 currency code for the security.. Valid values are `^[A-Z]{3}$`',
    `security_current_yield` DECIMAL(10,6) COMMENT 'Current yield of the security.',
    `security_cusip` STRING COMMENT 'Committee on Uniform Securities Identification Procedures number for the security.. Valid values are `^[0-9A-Z]{9}$`',
    `security_default_flag` BOOLEAN COMMENT 'Indicates if the security has defaulted.',
    `security_duration` DECIMAL(10,6) COMMENT 'Macaulay duration of the security.',
    `security_dv01` DECIMAL(10,6) COMMENT 'Dollar value of a 1 basis point change in yield.',
    `security_esg_rating` STRING COMMENT 'ESG rating of the security.',
    `security_face_value` DECIMAL(18,2) COMMENT 'Nominal value of the security.',
    `security_g_spread` DECIMAL(10,6) COMMENT 'G-spread of the security.',
    `security_green_bond_flag` BOOLEAN COMMENT 'Indicates if the security is a green bond.',
    `security_i_spread` DECIMAL(10,6) COMMENT 'I-spread of the security.',
    `security_isin` STRING COMMENT 'International Securities Identification Number for the security.. Valid values are `^[A-Z]{2}[0-9A-Z]{9}[0-9]$`',
    `security_issue_date` DATE COMMENT 'Date the security was issued.',
    `security_issuer_lei` STRING COMMENT 'Legal Entity Identifier of the security issuer.. Valid values are `^[A-Z0-9]{18}$`',
    `security_liquidity_classification` STRING COMMENT 'Liquidity classification of the security.. Valid values are `high|medium|low`',
    `security_market_price` DECIMAL(18,2) COMMENT 'Current market price of the security.',
    `security_market_value` DECIMAL(18,2) COMMENT 'Market value of the security position.',
    `security_maturity_date` DATE COMMENT 'Date the security matures.',
    `security_modified_duration` DECIMAL(10,6) COMMENT 'Modified duration of the security.',
    `security_option_adjusted_spread` DECIMAL(10,6) COMMENT 'Option-adjusted spread of the security.',
    `security_reference_rate` DECIMAL(18,2) COMMENT 'Reference rate used for spread calculations.',
    `security_sector` STRING COMMENT 'Industry sector of the issuer.. Valid values are `equity|fixed_income|real_estate|credit`',
    `security_sedol` STRING COMMENT 'Stock Exchange Daily Official List code for the security.. Valid values are `^[0-9A-Z]{7}$`',
    `security_spread_over_reference` DECIMAL(10,6) COMMENT 'Spread over the reference rate.',
    `security_subordination_level` STRING COMMENT 'Subordination level of the security.. Valid values are `senior|subordinated|junior`',
    `security_type` STRING COMMENT 'Classification of the security instrument.. Valid values are `bond|note|bill|preferred|convertible|structured`',
    `security_yield_to_call` DECIMAL(10,6) COMMENT 'Yield to call of the security.',
    `security_yield_to_maturity` DECIMAL(10,6) COMMENT 'Yield to maturity of the security.',
    `security_yield_to_worst` DECIMAL(10,6) COMMENT 'Yield to worst scenario of the security.',
    `security_z_spread` DECIMAL(10,6) COMMENT 'Z-spread of the security.',
    CONSTRAINT pk_spread_analytics PRIMARY KEY(`spread_analytics_id`)
) COMMENT 'Daily yield and spread analytics for each fixed income security and position, capturing yield to maturity (YTM), yield to worst (YTW), yield to call, current yield, option-adjusted spread (OAS), Z-spread, G-spread, asset-swap spread (ASW), I-spread, and';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`credit_allocation` (
    `credit_allocation_id` BIGINT COMMENT 'Primary key for the allocation association',
    `collateral_position_id` BIGINT COMMENT 'Foreign key linking to the collateral position providing security',
    `credit_position_id` BIGINT COMMENT 'Foreign key linking to credit.credit_position. Business justification: Critical missing FK. credit_allocation is described as association product between credit_position and collateral but only has collateral_position_id FK.',
    `credit_allocation_status` STRING COMMENT 'Current lifecycle state of the collateral allocation',
    `effective_date` DATE COMMENT 'The business date on which this collateral allocation became effective',
    `percentage` DECIMAL(8,4) COMMENT 'The percentage of the credit position exposure that is secured by this specific collateral position. Enables fractional allocation of collateral across multiple exposures.',
    `value` DECIMAL(20,2) COMMENT 'The monetary value of collateral allocated to this specific credit position, typically calculated as the collateral market value multiplied by the allocation percentage and adjusted for haircuts.',
    CONSTRAINT pk_credit_allocation PRIMARY KEY(`credit_allocation_id`)
) COMMENT 'This association product represents the Collateral Allocation between credit_position and collateral_position. It captures the operational record of how collateral assets are pledged or allocated against credit exposures for margin, regulatory, and risk';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`amortization_schedule` (
    `amortization_schedule_id` BIGINT COMMENT 'Primary key for amortization_schedule',
    `custody_account_id` BIGINT COMMENT 'Reference to the custodian account where payments are received and principal is held.',
    `instrument_id` BIGINT COMMENT 'Reference to the underlying credit instrument (bond, loan, private credit facility) for which this amortization schedule applies.',
    `credit_issuer_id` BIGINT COMMENT 'Reference to the counterparty or entity responsible for making payments under this schedule.',
    `private_credit_facility_id` BIGINT COMMENT 'Foreign key linking to credit.private_credit_facility. Business justification: Amortization schedules define payment structures for private credit facilities. The schedule tracks principal/interest payments over the life of the facility.',
    `loan_servicer_id` BIGINT COMMENT 'Reference to the entity responsible for administering and collecting payments on the instrument.',
    `accrual_method` STRING COMMENT 'Method used to calculate interest accrual between payment periods for accounting purposes.',
    `amendment_date` DATE COMMENT 'Date of the most recent amendment or modification to the amortization schedule terms.',
    `amendment_reason` STRING COMMENT 'Business reason for the most recent schedule modification such as restructuring or rate reset.',
    `balloon_payment_amount` DECIMAL(18,2) COMMENT 'Large final payment amount due at maturity for balloon or bullet amortization structures.',
    `base_interest_rate` DECIMAL(8,5) COMMENT 'Fixed interest rate or initial rate for floating instruments expressed as a decimal percentage for payment calculations.',
    `business_day_convention` STRING COMMENT 'Rule for adjusting payment dates that fall on non-business days to the appropriate business day.',
    `compounding_frequency` STRING COMMENT 'Frequency at which interest is compounded for compound interest calculations.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this amortization schedule record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this amortization schedule.',
    `day_count_convention` STRING COMMENT 'Method used to calculate accrued interest between payment dates per fixed income market standards.',
    `effective_date` DATE COMMENT 'Date when the amortization schedule becomes effective and payments commence according to the defined structure.',
    `grace_period_days` BIGINT COMMENT 'Number of days after the scheduled payment date before a payment is considered delinquent.',
    `interest_rate_type` STRING COMMENT 'Classification of the interest rate structure applied to the amortization schedule calculations.',
    `last_payment_amount` DECIMAL(18,2) COMMENT 'Total amount of the most recent payment received including principal and interest.',
    `last_payment_date` DATE COMMENT 'Date of the most recent amortization payment received or processed.',
    `late_payment_fee_amount` DECIMAL(18,2) COMMENT 'Fixed fee amount charged when a payment is received after the grace period expires.',
    `late_payment_fee_rate` DECIMAL(8,5) COMMENT 'Percentage-based late fee applied to overdue payment amounts after grace period.',
    `maturity_date` DATE COMMENT 'Final date when all scheduled principal and interest payments are expected to be completed under normal circumstances.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this amortization schedule record.',
    `next_interest_payment` DECIMAL(18,2) COMMENT 'Interest portion of the next scheduled payment based on the current outstanding principal.',
    `next_payment_amount` DECIMAL(18,2) COMMENT 'Total amount due on the next scheduled payment date including principal and interest components.',
    `next_payment_date` DATE COMMENT 'Date of the next scheduled amortization payment due under the current schedule.',
    `next_principal_payment` DECIMAL(18,2) COMMENT 'Principal portion of the next scheduled payment that will reduce the outstanding balance.',
    `notes` STRING COMMENT 'Free-text field for additional comments or special instructions related to the amortization schedule.',
    `original_principal_amount` DECIMAL(18,2) COMMENT 'Initial principal balance at schedule inception used as the basis for calculating amortization payments.',
    `outstanding_principal_amount` DECIMAL(18,2) COMMENT 'Current remaining principal balance after accounting for all principal payments made to date.',
    `payment_calendar_code` STRING COMMENT 'Financial center calendar code used to determine business days for payment date adjustments.',
    `payment_frequency` STRING COMMENT 'Frequency at which scheduled amortization payments are due under the terms of the credit instrument.',
    `payments_made_count` BIGINT COMMENT 'Number of scheduled payments that have been successfully completed to date.',
    `payments_remaining_count` BIGINT COMMENT 'Number of scheduled payments remaining until maturity or expected payoff.',
    `prepayment_allowed_flag` BOOLEAN COMMENT 'Indicates whether early principal prepayments are permitted under the instrument terms.',
    `prepayment_lockout_end_date` DATE COMMENT 'Date until which prepayments are prohibited or subject to maximum penalty under call protection.',
    `prepayment_penalty_rate` DECIMAL(8,5) COMMENT 'Percentage penalty applied to prepaid principal amounts if early repayment occurs.',
    `reference_rate_index` STRING COMMENT 'Benchmark interest rate index used for floating rate calculations such as SOFR, EURIBOR, or SONIA.',
    `schedule_reference_code` STRING COMMENT 'External business identifier for the amortization schedule used in reporting and counterparty communications.',
    `schedule_status` STRING COMMENT 'Current state of the amortization schedule in its lifecycle from creation through completion or early termination.',
    `schedule_type` STRING COMMENT 'Classification of the amortization structure defining how principal and interest payments are distributed over the instrument life.',
    `schedule_version` BIGINT COMMENT 'Version number tracking amendments or modifications to the original amortization schedule.',
    `spread_basis_points` BIGINT COMMENT 'Credit spread over the reference rate expressed in basis points for floating rate instruments.',
    `total_scheduled_payments` BIGINT COMMENT 'Total number of scheduled payment periods over the full life of the amortization schedule.',
    CONSTRAINT pk_amortization_schedule PRIMARY KEY(`amortization_schedule_id`)
) COMMENT 'Master reference table for amortization_schedule. Referenced by amortization_schedule_id.';

CREATE OR REPLACE TABLE `asset_management`.`credit`.`private_credit_facility` (
    `private_credit_facility_id` BIGINT COMMENT 'Primary key for private_credit_facility',
    `credit_issuer_id` BIGINT COMMENT 'Reference to the counterparty entity that is the borrower under this credit facility.',
    `fund_id` BIGINT COMMENT 'Reference to the internal fund or investment vehicle providing capital for this facility.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the private equity sponsor backing the borrower in sponsored transactions.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio under which this credit facility is managed and reported.',
    `agent_bank_name` STRING COMMENT 'Name of the administrative agent bank for syndicated facilities.',
    `all_in_rate_percent` DECIMAL(7,4) COMMENT 'Current total interest rate percentage including base rate plus spread.',
    `amortization_type` STRING COMMENT 'Principal repayment structure defining scheduled amortization pattern.',
    `base_rate_index` STRING COMMENT 'Reference rate benchmark used for floating rate calculations on the facility.',
    `borrower_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the borrowers primary jurisdiction.',
    `call_protection_months` BIGINT COMMENT 'Number of months during which prepayment is restricted or penalized.',
    `commitment_amount` DECIMAL(18,2) COMMENT 'Total committed capital amount that the lender agrees to make available under the facility.',
    `commitment_fee_bps` BIGINT COMMENT 'Annual fee in basis points charged on unfunded commitment amounts.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the facility denomination.',
    `day_count_convention` STRING COMMENT 'Interest calculation convention specifying how days are counted for accrual.',
    `deal_source` STRING COMMENT 'Origination channel indicating how the investment opportunity was sourced.',
    `effective_date` DATE COMMENT 'Date when the credit facility agreement becomes legally binding and effective.',
    `esg_score` DECIMAL(5,2) COMMENT 'Composite ESG score assigned to the borrower for responsible investment assessment.',
    `external_credit_rating` STRING COMMENT 'Credit rating from external rating agency if available for the borrower or facility.',
    `facility_name` STRING COMMENT 'Descriptive name of the private credit facility for identification and reporting purposes.',
    `facility_number` STRING COMMENT 'External business identifier for the private credit facility used in deal documentation and reporting.',
    `facility_status` STRING COMMENT 'Current lifecycle status of the private credit facility indicating operational state.',
    `facility_type` STRING COMMENT 'Classification of the credit facility structure determining repayment terms and priority.',
    `fair_value` DECIMAL(18,2) COMMENT 'Current fair market value of the credit facility for portfolio valuation.',
    `fair_value_date` DATE COMMENT 'As-of date for the most recent fair value measurement.',
    `floor_rate_percent` DECIMAL(5,4) COMMENT 'Minimum interest rate floor as a percentage protecting lender from low rate environments.',
    `funded_amount` DECIMAL(18,2) COMMENT 'Current outstanding principal amount that has been drawn and funded under the facility.',
    `has_pik_feature` BOOLEAN COMMENT 'Indicates whether the facility allows payment-in-kind interest capitalization.',
    `industry_sector` STRING COMMENT 'Primary industry classification of the borrower for sector exposure analysis.',
    `interest_rate_type` STRING COMMENT 'Classification of interest rate structure as fixed, floating, or hybrid combination.',
    `internal_risk_rating` STRING COMMENT 'Proprietary credit risk rating assigned by internal credit committee.',
    `is_covenant_lite` BOOLEAN COMMENT 'Indicates whether the facility has limited or no maintenance covenants.',
    `is_syndicated` BOOLEAN COMMENT 'Indicates whether the facility is part of a syndicated loan arrangement.',
    `legal_entity_identifier` STRING COMMENT 'LEI code of the borrower for regulatory reporting and counterparty identification.',
    `loss_given_default_percent` DECIMAL(7,4) COMMENT 'Expected loss percentage of exposure in the event of borrower default.',
    `maturity_date` DATE COMMENT 'Scheduled final repayment date when all outstanding principal and interest are due.',
    `origination_date` DATE COMMENT 'Date when the credit facility was originally underwritten and closed.',
    `payment_frequency` STRING COMMENT 'Frequency of scheduled interest and principal payments under the facility.',
    `prepayment_penalty_percent` DECIMAL(5,4) COMMENT 'Percentage penalty fee charged for early voluntary prepayment of principal.',
    `probability_of_default_percent` DECIMAL(7,4) COMMENT 'Estimated one-year probability of default percentage for credit risk modeling.',
    `record_created_timestamp` TIMESTAMP COMMENT 'System timestamp when this facility record was first created in the data platform.',
    `security_type` STRING COMMENT 'Type of collateral security or lien position supporting the credit facility.',
    `seniority_rank` STRING COMMENT 'Position in the capital structure determining payment priority in default scenarios.',
    `spread_bps` BIGINT COMMENT 'Credit spread in basis points added to the base rate to determine all-in interest rate.',
    `unfunded_commitment` DECIMAL(18,2) COMMENT 'Remaining undrawn commitment amount available for future drawdowns by the borrower.',
    `upfront_fee_percent` DECIMAL(5,4) COMMENT 'One-time origination fee percentage charged at facility closing.',
    CONSTRAINT pk_private_credit_facility PRIMARY KEY(`private_credit_facility_id`)
) COMMENT 'Master reference table for private_credit_facility. Referenced by private_credit_facility_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ADD CONSTRAINT `fk_credit_fixed_income_security_credit_issuer_id` FOREIGN KEY (`credit_issuer_id`) REFERENCES `asset_management`.`credit`.`credit_issuer`(`credit_issuer_id`);
ALTER TABLE `asset_management`.`credit`.`credit_position` ADD CONSTRAINT `fk_credit_credit_position_credit_mandate_id` FOREIGN KEY (`credit_mandate_id`) REFERENCES `asset_management`.`credit`.`credit_mandate`(`credit_mandate_id`);
ALTER TABLE `asset_management`.`credit`.`credit_position` ADD CONSTRAINT `fk_credit_credit_position_fixed_income_security_id` FOREIGN KEY (`fixed_income_security_id`) REFERENCES `asset_management`.`credit`.`fixed_income_security`(`fixed_income_security_id`);
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ADD CONSTRAINT `fk_credit_coupon_schedule_fixed_income_security_id` FOREIGN KEY (`fixed_income_security_id`) REFERENCES `asset_management`.`credit`.`fixed_income_security`(`fixed_income_security_id`);
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ADD CONSTRAINT `fk_credit_coupon_schedule_reference_sofr_rate_id` FOREIGN KEY (`reference_sofr_rate_id`) REFERENCES `asset_management`.`credit`.`sofr_rate`(`sofr_rate_id`);
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ADD CONSTRAINT `fk_credit_coupon_payment_fixed_income_security_id` FOREIGN KEY (`fixed_income_security_id`) REFERENCES `asset_management`.`credit`.`fixed_income_security`(`fixed_income_security_id`);
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ADD CONSTRAINT `fk_credit_duration_convexity_credit_yield_curve_id` FOREIGN KEY (`credit_yield_curve_id`) REFERENCES `asset_management`.`credit`.`credit_yield_curve`(`credit_yield_curve_id`);
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ADD CONSTRAINT `fk_credit_duration_convexity_fixed_income_security_id` FOREIGN KEY (`fixed_income_security_id`) REFERENCES `asset_management`.`credit`.`fixed_income_security`(`fixed_income_security_id`);
ALTER TABLE `asset_management`.`credit`.`rating` ADD CONSTRAINT `fk_credit_rating_credit_issuer_id` FOREIGN KEY (`credit_issuer_id`) REFERENCES `asset_management`.`credit`.`credit_issuer`(`credit_issuer_id`);
ALTER TABLE `asset_management`.`credit`.`rating` ADD CONSTRAINT `fk_credit_rating_fixed_income_security_id` FOREIGN KEY (`fixed_income_security_id`) REFERENCES `asset_management`.`credit`.`fixed_income_security`(`fixed_income_security_id`);
ALTER TABLE `asset_management`.`credit`.`rating_action` ADD CONSTRAINT `fk_credit_rating_action_credit_issuer_id` FOREIGN KEY (`credit_issuer_id`) REFERENCES `asset_management`.`credit`.`credit_issuer`(`credit_issuer_id`);
ALTER TABLE `asset_management`.`credit`.`rating_action` ADD CONSTRAINT `fk_credit_rating_action_fixed_income_security_id` FOREIGN KEY (`fixed_income_security_id`) REFERENCES `asset_management`.`credit`.`fixed_income_security`(`fixed_income_security_id`);
ALTER TABLE `asset_management`.`credit`.`cds_position` ADD CONSTRAINT `fk_credit_cds_position_credit_issuer_id` FOREIGN KEY (`credit_issuer_id`) REFERENCES `asset_management`.`credit`.`credit_issuer`(`credit_issuer_id`);
ALTER TABLE `asset_management`.`credit`.`cds_position` ADD CONSTRAINT `fk_credit_cds_position_fixed_income_security_id` FOREIGN KEY (`fixed_income_security_id`) REFERENCES `asset_management`.`credit`.`fixed_income_security`(`fixed_income_security_id`);
ALTER TABLE `asset_management`.`credit`.`cds_position` ADD CONSTRAINT `fk_credit_cds_position_reference_entity_credit_issuer_id` FOREIGN KEY (`reference_entity_credit_issuer_id`) REFERENCES `asset_management`.`credit`.`credit_issuer`(`credit_issuer_id`);
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ADD CONSTRAINT `fk_credit_cds_market_data_credit_issuer_id` FOREIGN KEY (`credit_issuer_id`) REFERENCES `asset_management`.`credit`.`credit_issuer`(`credit_issuer_id`);
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ADD CONSTRAINT `fk_credit_cds_market_data_reference_entity_credit_issuer_id` FOREIGN KEY (`reference_entity_credit_issuer_id`) REFERENCES `asset_management`.`credit`.`credit_issuer`(`credit_issuer_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ADD CONSTRAINT `fk_credit_private_credit_drawdown_private_credit_facility_id` FOREIGN KEY (`private_credit_facility_id`) REFERENCES `asset_management`.`credit`.`private_credit_facility`(`private_credit_facility_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ADD CONSTRAINT `fk_credit_private_credit_drawdown_private_credit_investment_id` FOREIGN KEY (`private_credit_investment_id`) REFERENCES `asset_management`.`credit`.`private_credit_investment`(`private_credit_investment_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ADD CONSTRAINT `fk_credit_private_credit_repayment_amortization_schedule_id` FOREIGN KEY (`amortization_schedule_id`) REFERENCES `asset_management`.`credit`.`amortization_schedule`(`amortization_schedule_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ADD CONSTRAINT `fk_credit_private_credit_repayment_private_credit_investment_id` FOREIGN KEY (`private_credit_investment_id`) REFERENCES `asset_management`.`credit`.`private_credit_investment`(`private_credit_investment_id`);
ALTER TABLE `asset_management`.`credit`.`structured_product` ADD CONSTRAINT `fk_credit_structured_product_credit_issuer_id` FOREIGN KEY (`credit_issuer_id`) REFERENCES `asset_management`.`credit`.`credit_issuer`(`credit_issuer_id`);
ALTER TABLE `asset_management`.`credit`.`structured_product` ADD CONSTRAINT `fk_credit_structured_product_fixed_income_security_id` FOREIGN KEY (`fixed_income_security_id`) REFERENCES `asset_management`.`credit`.`fixed_income_security`(`fixed_income_security_id`);
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ADD CONSTRAINT `fk_credit_sovereign_debt_holding_fixed_income_security_id` FOREIGN KEY (`fixed_income_security_id`) REFERENCES `asset_management`.`credit`.`fixed_income_security`(`fixed_income_security_id`);
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ADD CONSTRAINT `fk_credit_credit_benchmark_constituent_benchmark_index_id` FOREIGN KEY (`benchmark_index_id`) REFERENCES `asset_management`.`credit`.`benchmark_index`(`benchmark_index_id`);
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ADD CONSTRAINT `fk_credit_credit_benchmark_constituent_fixed_income_security_id` FOREIGN KEY (`fixed_income_security_id`) REFERENCES `asset_management`.`credit`.`fixed_income_security`(`fixed_income_security_id`);
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ADD CONSTRAINT `fk_credit_credit_issuer_parent_credit_issuer_id` FOREIGN KEY (`parent_credit_issuer_id`) REFERENCES `asset_management`.`credit`.`credit_issuer`(`credit_issuer_id`);
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ADD CONSTRAINT `fk_credit_maturity_schedule_fixed_income_security_id` FOREIGN KEY (`fixed_income_security_id`) REFERENCES `asset_management`.`credit`.`fixed_income_security`(`fixed_income_security_id`);
ALTER TABLE `asset_management`.`credit`.`default_event` ADD CONSTRAINT `fk_credit_default_event_credit_issuer_id` FOREIGN KEY (`credit_issuer_id`) REFERENCES `asset_management`.`credit`.`credit_issuer`(`credit_issuer_id`);
ALTER TABLE `asset_management`.`credit`.`default_event` ADD CONSTRAINT `fk_credit_default_event_fixed_income_security_id` FOREIGN KEY (`fixed_income_security_id`) REFERENCES `asset_management`.`credit`.`fixed_income_security`(`fixed_income_security_id`);
ALTER TABLE `asset_management`.`credit`.`default_event` ADD CONSTRAINT `fk_credit_default_event_reference_entity_credit_issuer_id` FOREIGN KEY (`reference_entity_credit_issuer_id`) REFERENCES `asset_management`.`credit`.`credit_issuer`(`credit_issuer_id`);
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ADD CONSTRAINT `fk_credit_credit_mandate_benchmark_index_id` FOREIGN KEY (`benchmark_index_id`) REFERENCES `asset_management`.`credit`.`benchmark_index`(`benchmark_index_id`);
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ADD CONSTRAINT `fk_credit_spread_analytics_fixed_income_security_id` FOREIGN KEY (`fixed_income_security_id`) REFERENCES `asset_management`.`credit`.`fixed_income_security`(`fixed_income_security_id`);
ALTER TABLE `asset_management`.`credit`.`credit_allocation` ADD CONSTRAINT `fk_credit_credit_allocation_credit_position_id` FOREIGN KEY (`credit_position_id`) REFERENCES `asset_management`.`credit`.`credit_position`(`credit_position_id`);
ALTER TABLE `asset_management`.`credit`.`amortization_schedule` ADD CONSTRAINT `fk_credit_amortization_schedule_credit_issuer_id` FOREIGN KEY (`credit_issuer_id`) REFERENCES `asset_management`.`credit`.`credit_issuer`(`credit_issuer_id`);
ALTER TABLE `asset_management`.`credit`.`amortization_schedule` ADD CONSTRAINT `fk_credit_amortization_schedule_private_credit_facility_id` FOREIGN KEY (`private_credit_facility_id`) REFERENCES `asset_management`.`credit`.`private_credit_facility`(`private_credit_facility_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_facility` ADD CONSTRAINT `fk_credit_private_credit_facility_credit_issuer_id` FOREIGN KEY (`credit_issuer_id`) REFERENCES `asset_management`.`credit`.`credit_issuer`(`credit_issuer_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` SET TAGS ('dbx_subdomain' = 'fixed_income');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `fixed_income_security_id` SET TAGS ('dbx_business_glossary_term' = 'Fixed Income Security Identifier');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `credit_issuer_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Issuer Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `accrued_interest` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `bloomberg_ticker` SET TAGS ('dbx_business_glossary_term' = 'Bloomberg Ticker Symbol');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `callable_flag` SET TAGS ('dbx_business_glossary_term' = 'Callable Flag');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `convexity` SET TAGS ('dbx_business_glossary_term' = 'Convexity');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_business_glossary_term' = 'Country of Risk');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `coupon_frequency` SET TAGS ('dbx_business_glossary_term' = 'Coupon Frequency');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `coupon_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly|zero_coupon');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `coupon_rate` SET TAGS ('dbx_business_glossary_term' = 'Coupon Rate');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `credit_rating_fitch` SET TAGS ('dbx_business_glossary_term' = 'Fitch Credit Rating');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `credit_rating_moody` SET TAGS ('dbx_business_glossary_term' = 'Moodys Credit Rating');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `credit_rating_sp` SET TAGS ('dbx_business_glossary_term' = 'Standard & Poors (S&P) Credit Rating');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `default_flag` SET TAGS ('dbx_business_glossary_term' = 'Default Flag');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `duration` SET TAGS ('dbx_business_glossary_term' = 'Duration');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `dv01` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of 01 (DV01)');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `face_value` SET TAGS ('dbx_business_glossary_term' = 'Face Value');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `first_coupon_date` SET TAGS ('dbx_business_glossary_term' = 'First Coupon Date');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `fixed_income_security_status` SET TAGS ('dbx_business_glossary_term' = 'Security Status');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `fixed_income_security_status` SET TAGS ('dbx_value_regex' = 'active|matured|called|defaulted|cancelled');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `floating_rate_flag` SET TAGS ('dbx_business_glossary_term' = 'Floating Rate Flag');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `green_bond_flag` SET TAGS ('dbx_business_glossary_term' = 'Green Bond Flag');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `investment_grade_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Grade (IG) Flag');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'Issue Date');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `last_coupon_date` SET TAGS ('dbx_business_glossary_term' = 'Last Coupon Date');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `liquidity_classification` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Classification');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `liquidity_classification` SET TAGS ('dbx_value_regex' = 'highly_liquid|liquid|moderately_liquid|illiquid');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `market_price` SET TAGS ('dbx_business_glossary_term' = 'Market Price');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `next_coupon_date` SET TAGS ('dbx_business_glossary_term' = 'Next Coupon Date');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `oas` SET TAGS ('dbx_business_glossary_term' = 'Option-Adjusted Spread (OAS)');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `price_date` SET TAGS ('dbx_business_glossary_term' = 'Price Date');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `puttable_flag` SET TAGS ('dbx_business_glossary_term' = 'Puttable Flag');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `reference_rate` SET TAGS ('dbx_business_glossary_term' = 'Reference Rate');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Sector');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `security_name` SET TAGS ('dbx_business_glossary_term' = 'Security Name');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `security_type` SET TAGS ('dbx_business_glossary_term' = 'Security Type');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `sinking_fund_flag` SET TAGS ('dbx_business_glossary_term' = 'Sinking Fund Flag');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `spread_over_reference` SET TAGS ('dbx_business_glossary_term' = 'Spread Over Reference Rate');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `subordination_level` SET TAGS ('dbx_business_glossary_term' = 'Subordination Level');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `subordination_level` SET TAGS ('dbx_value_regex' = 'senior_secured|senior_unsecured|subordinated|junior_subordinated');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ALTER COLUMN `ytm` SET TAGS ('dbx_business_glossary_term' = 'Yield to Maturity (YTM)');
ALTER TABLE `asset_management`.`credit`.`credit_position` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`credit`.`credit_position` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`credit_position` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`credit_position` SET TAGS ('dbx_subdomain' = 'fixed_income');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `credit_position_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Position Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `cash_position_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Position Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `credit_blotter_id` SET TAGS ('dbx_business_glossary_term' = 'Blotter Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `credit_custodian_blotter_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `credit_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Mandate Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `custodian_actor_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Actor Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `fixed_income_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `account_number` SET TAGS ('dbx_business_glossary_term' = 'Account Number');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `accrued_interest` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `acquisition_date` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Date');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'investment_grade|high_yield|private_credit|sovereign_debt|structured_product|treasury_bill');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `benchmark_index` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `book_cost` SET TAGS ('dbx_business_glossary_term' = 'Book Cost');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `convexity` SET TAGS ('dbx_business_glossary_term' = 'Convexity');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `coupon_rate` SET TAGS ('dbx_business_glossary_term' = 'Coupon Rate');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[0-9A-Z]{5}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `duration` SET TAGS ('dbx_business_glossary_term' = 'Duration');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `dv01` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of 01 Basis Point (DV01)');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `esg_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Score');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `face_value` SET TAGS ('dbx_business_glossary_term' = 'Face Value');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `instrument_type` SET TAGS ('dbx_business_glossary_term' = 'Instrument Type');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `instrument_type` SET TAGS ('dbx_value_regex' = 'corporate_bond|government_bond|municipal_bond|cds|convertible_bond|asset_backed_security');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `internal_credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Internal Credit Rating');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `is_callable` SET TAGS ('dbx_business_glossary_term' = 'Is Callable');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `is_puttable` SET TAGS ('dbx_business_glossary_term' = 'Is Puttable');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Name');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `market_value` SET TAGS ('dbx_business_glossary_term' = 'Market Value (Mark-to-Market / MTM)');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `oas` SET TAGS ('dbx_business_glossary_term' = 'Option-Adjusted Spread (OAS)');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `position_status` SET TAGS ('dbx_business_glossary_term' = 'Position Status');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `position_status` SET TAGS ('dbx_value_regex' = 'open|closed|pending_settlement|suspended|matured');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `position_type` SET TAGS ('dbx_business_glossary_term' = 'Position Type');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `position_type` SET TAGS ('dbx_value_regex' = 'long|short');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Position Quantity');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9BCDFGHJKLMNPQRSTVWXYZ]{7}$');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `seniority` SET TAGS ('dbx_business_glossary_term' = 'Seniority');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `seniority` SET TAGS ('dbx_value_regex' = 'senior_secured|senior_unsecured|subordinated|junior');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `trade_date` SET TAGS ('dbx_business_glossary_term' = 'Trade Date');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `unrealized_gain_loss` SET TAGS ('dbx_business_glossary_term' = 'Unrealized Gain or Loss (Profit and Loss / P&L)');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`credit`.`credit_position` ALTER COLUMN `ytm` SET TAGS ('dbx_business_glossary_term' = 'Yield to Maturity (YTM)');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` SET TAGS ('dbx_subdomain' = 'fixed_income');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `coupon_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Coupon Schedule ID');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `fixed_income_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security ID');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `reference_sofr_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Reference Sofr Rate Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `accrual_days` SET TAGS ('dbx_business_glossary_term' = 'Accrual Days');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `accrual_end_date` SET TAGS ('dbx_business_glossary_term' = 'Accrual End Date');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `accrual_start_date` SET TAGS ('dbx_business_glossary_term' = 'Accrual Start Date');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `actual_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Payment Amount');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `actual_payment_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Payment Date');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `business_day_convention` SET TAGS ('dbx_business_glossary_term' = 'Business Day Convention');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `business_day_convention` SET TAGS ('dbx_value_regex' = 'following|modified_following|preceding|unadjusted');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `calculation_agent_lei` SET TAGS ('dbx_business_glossary_term' = 'Calculation Agent Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `calculation_agent_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `compounding_method` SET TAGS ('dbx_business_glossary_term' = 'Compounding Method');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `coupon_amount` SET TAGS ('dbx_business_glossary_term' = 'Coupon Amount');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `coupon_cap_rate` SET TAGS ('dbx_business_glossary_term' = 'Coupon Cap Rate');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `coupon_currency` SET TAGS ('dbx_business_glossary_term' = 'Coupon Currency');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `coupon_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `coupon_floor_rate` SET TAGS ('dbx_business_glossary_term' = 'Coupon Floor Rate');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `coupon_rate` SET TAGS ('dbx_business_glossary_term' = 'Coupon Rate');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `coupon_rate_type` SET TAGS ('dbx_business_glossary_term' = 'Coupon Rate Type');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `coupon_rate_type` SET TAGS ('dbx_value_regex' = 'fixed|floating|zero|step_up|step_down|variable');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `coupon_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Coupon Sequence Number');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_business_glossary_term' = 'Day Count Convention');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_value_regex' = '30/360|ACT/360|ACT/365|ACT/ACT|30E/360');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `ex_dividend_date` SET TAGS ('dbx_business_glossary_term' = 'Ex-Dividend Date');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `fixed_reference_rate_value` SET TAGS ('dbx_business_glossary_term' = 'Fixed Reference Rate Value');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `fixing_date` SET TAGS ('dbx_business_glossary_term' = 'Fixing Date');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `is_final_coupon` SET TAGS ('dbx_business_glossary_term' = 'Is Final Coupon');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `net_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Payment Amount');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `notional_principal` SET TAGS ('dbx_business_glossary_term' = 'Notional Principal');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `paying_agent_lei` SET TAGS ('dbx_business_glossary_term' = 'Paying Agent Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `paying_agent_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `payment_calendar` SET TAGS ('dbx_business_glossary_term' = 'Payment Calendar');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Coupon Payment Date');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly|at_maturity');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|ach|check|book_entry|euroclear|clearstream');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'scheduled|paid|missed|deferred|cancelled');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `record_date` SET TAGS ('dbx_business_glossary_term' = 'Record Date');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `reference_rate` SET TAGS ('dbx_business_glossary_term' = 'Reference Rate');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `reference_rate_tenor` SET TAGS ('dbx_business_glossary_term' = 'Reference Rate Tenor');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `reset_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reset Frequency');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `schedule_effective_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Schedule Effective Timestamp');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `schedule_source_system` SET TAGS ('dbx_business_glossary_term' = 'Schedule Source System');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `schedule_version_number` SET TAGS ('dbx_business_glossary_term' = 'Schedule Version Number');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `spread_over_reference_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Spread Over Reference Rate (Basis Points)');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Amount');
ALTER TABLE `asset_management`.`credit`.`coupon_schedule` ALTER COLUMN `withholding_tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Rate');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` SET TAGS ('dbx_subdomain' = 'fixed_income');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `coupon_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Coupon Payment ID');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian ID');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `fixed_income_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security ID');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `accrual_days` SET TAGS ('dbx_business_glossary_term' = 'Accrual Days');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `accrual_end_date` SET TAGS ('dbx_business_glossary_term' = 'Accrual End Date');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `accrual_start_date` SET TAGS ('dbx_business_glossary_term' = 'Accrual Start Date');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `accrued_interest_local` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest Local Currency');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `coupon_amount_base` SET TAGS ('dbx_business_glossary_term' = 'Coupon Amount Base Currency');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `coupon_amount_local` SET TAGS ('dbx_business_glossary_term' = 'Coupon Amount Local Currency');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `coupon_rate` SET TAGS ('dbx_business_glossary_term' = 'Coupon Rate');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `data_classification` SET TAGS ('dbx_business_glossary_term' = 'Data Classification');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `data_classification` SET TAGS ('dbx_value_regex' = 'internal|confidential');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_business_glossary_term' = 'Day Count Convention');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_value_regex' = '30/360|ACT/360|ACT/365|ACT/ACT|30E/360');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `fx_rate_date` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate Date');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `gl_posting_date` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Posting Date');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `holding_quantity` SET TAGS ('dbx_business_glossary_term' = 'Holding Quantity');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `income_classification` SET TAGS ('dbx_business_glossary_term' = 'Income Classification');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `income_classification` SET TAGS ('dbx_value_regex' = 'interest_income|dividend_income|other_income');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `local_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Local Currency Code');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `local_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `net_coupon_amount_base` SET TAGS ('dbx_business_glossary_term' = 'Net Coupon Amount Base Currency');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `net_coupon_amount_local` SET TAGS ('dbx_business_glossary_term' = 'Net Coupon Amount Local Currency');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `paying_agent_lei` SET TAGS ('dbx_business_glossary_term' = 'Paying Agent Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `paying_agent_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `paying_agent_name` SET TAGS ('dbx_business_glossary_term' = 'Paying Agent Name');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi-annual|quarterly|monthly|at_maturity|zero_coupon');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'scheduled|received|reconciled|failed|reversed|pending_settlement');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `payment_type` SET TAGS ('dbx_business_glossary_term' = 'Payment Type');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `payment_type` SET TAGS ('dbx_value_regex' = 'regular|final|partial|makeup|arrears');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'matched|unmatched|exception|pending_review|resolved');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `record_date` SET TAGS ('dbx_business_glossary_term' = 'Record Date');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `scheduled_payment_date` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Payment Date');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `tax_reclaim_amount_local` SET TAGS ('dbx_business_glossary_term' = 'Tax Reclaim Amount Local Currency');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `tax_reclaim_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Tax Reclaim Eligible Flag');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `variance_amount_base` SET TAGS ('dbx_business_glossary_term' = 'Variance Amount Base Currency');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `withholding_tax_amount_local` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Amount Local Currency');
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ALTER COLUMN `withholding_tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Rate');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` SET TAGS ('dbx_subdomain' = 'risk_analytics');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `duration_convexity_id` SET TAGS ('dbx_business_glossary_term' = 'Duration Convexity ID');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `credit_yield_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Yield Curve Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `fixed_income_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security ID');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `benchmark_curve_name` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Curve Name');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `calculation_engine` SET TAGS ('dbx_business_glossary_term' = 'Calculation Engine');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `calculation_error_message` SET TAGS ('dbx_business_glossary_term' = 'Calculation Error Message');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Calculation Method');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `calculation_method` SET TAGS ('dbx_value_regex' = 'analytical|numerical|monte_carlo|binomial_tree|black_scholes');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `calculation_status` SET TAGS ('dbx_business_glossary_term' = 'Calculation Status');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `calculation_status` SET TAGS ('dbx_value_regex' = 'completed|failed|pending|in_progress');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation Timestamp');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `convexity` SET TAGS ('dbx_business_glossary_term' = 'Convexity');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `dv01` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of a Basis Point (DV01)');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `effective_duration` SET TAGS ('dbx_business_glossary_term' = 'Effective Duration');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `is_portfolio_level` SET TAGS ('dbx_business_glossary_term' = 'Is Portfolio Level');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `key_rate_duration_10y` SET TAGS ('dbx_business_glossary_term' = 'Key Rate Duration (KRD) 10 Year');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `key_rate_duration_1y` SET TAGS ('dbx_business_glossary_term' = 'Key Rate Duration (KRD) 1 Year');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `key_rate_duration_2y` SET TAGS ('dbx_business_glossary_term' = 'Key Rate Duration (KRD) 2 Year');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `key_rate_duration_30y` SET TAGS ('dbx_business_glossary_term' = 'Key Rate Duration (KRD) 30 Year');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `key_rate_duration_3m` SET TAGS ('dbx_business_glossary_term' = 'Key Rate Duration (KRD) 3 Month');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `key_rate_duration_5y` SET TAGS ('dbx_business_glossary_term' = 'Key Rate Duration (KRD) 5 Year');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `key_rate_duration_6m` SET TAGS ('dbx_business_glossary_term' = 'Key Rate Duration (KRD) 6 Month');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `macaulay_duration` SET TAGS ('dbx_business_glossary_term' = 'Macaulay Duration');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `market_value` SET TAGS ('dbx_business_glossary_term' = 'Market Value');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `modified_duration` SET TAGS ('dbx_business_glossary_term' = 'Modified Duration');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `oas` SET TAGS ('dbx_business_glossary_term' = 'Option-Adjusted Spread (OAS)');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `pv01` SET TAGS ('dbx_business_glossary_term' = 'Present Value of a Basis Point (PV01)');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `spread_duration` SET TAGS ('dbx_business_glossary_term' = 'Spread Duration');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `yield_curve_source` SET TAGS ('dbx_business_glossary_term' = 'Yield Curve Source');
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ALTER COLUMN `ytm` SET TAGS ('dbx_business_glossary_term' = 'Yield to Maturity (YTM)');
ALTER TABLE `asset_management`.`credit`.`rating` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`credit`.`rating` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`rating` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`rating` SET TAGS ('dbx_subdomain' = 'risk_analytics');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `rating_id` SET TAGS ('dbx_business_glossary_term' = 'Rating Identifier');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `credit_issuer_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer Identifier');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `fixed_income_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `action` SET TAGS ('dbx_business_glossary_term' = 'Rating Action');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `action` SET TAGS ('dbx_value_regex' = 'New|Upgrade|Downgrade|Affirmed|Withdrawn|Suspended');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `active_flag` SET TAGS ('dbx_business_glossary_term' = 'Active Rating Flag');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `agency` SET TAGS ('dbx_business_glossary_term' = 'Rating Agency');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `agency` SET TAGS ('dbx_value_regex' = 'Moodys|S&P|Fitch|DBRS|Internal');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `analyst_name` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst Name');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `rating_category` SET TAGS ('dbx_business_glossary_term' = 'Investment Grade (IG) / High Yield (HY) Rating Category');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `rating_category` SET TAGS ('dbx_value_regex' = 'Investment Grade|High Yield|Non-Rated|Default');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `committee_date` SET TAGS ('dbx_business_glossary_term' = 'Rating Committee Date');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Rating Currency');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `default_probability` SET TAGS ('dbx_business_glossary_term' = 'Default Probability');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Rating Effective Date');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `esg_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Score');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `internal_override_flag` SET TAGS ('dbx_business_glossary_term' = 'Internal Override Flag');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `internal_override_rationale` SET TAGS ('dbx_business_glossary_term' = 'Internal Override Rationale');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Rating Jurisdiction');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `methodology` SET TAGS ('dbx_business_glossary_term' = 'Rating Methodology');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `notch` SET TAGS ('dbx_business_glossary_term' = 'Rating Notch');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `outlook` SET TAGS ('dbx_business_glossary_term' = 'Rating Outlook');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `outlook` SET TAGS ('dbx_value_regex' = 'Positive|Stable|Negative|Developing|N/A');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `previous_rating_value` SET TAGS ('dbx_business_glossary_term' = 'Previous Rating Value');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `public_flag` SET TAGS ('dbx_business_glossary_term' = 'Public Rating Flag');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `rating_type` SET TAGS ('dbx_business_glossary_term' = 'Rating Type');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `rating_type` SET TAGS ('dbx_value_regex' = 'Issuer|Issue|Senior Unsecured|Senior Secured|Subordinated|Short-Term');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `rationale` SET TAGS ('dbx_business_glossary_term' = 'Rating Rationale');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `recovery_rate` SET TAGS ('dbx_business_glossary_term' = 'Recovery Rate');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `regulatory_capital_treatment` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Capital Treatment');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `regulatory_capital_treatment` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `regulatory_capital_treatment` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `report_url` SET TAGS ('dbx_business_glossary_term' = 'Rating Report Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `scale` SET TAGS ('dbx_business_glossary_term' = 'Rating Scale');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `scale` SET TAGS ('dbx_value_regex' = 'Long-Term|Short-Term|National|Global');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Issuer Sector');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `seniority` SET TAGS ('dbx_business_glossary_term' = 'Debt Seniority');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `solicited_flag` SET TAGS ('dbx_business_glossary_term' = 'Solicited Rating Flag');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `source_identifier` SET TAGS ('dbx_business_glossary_term' = 'Rating Source Identifier');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `value` SET TAGS ('dbx_business_glossary_term' = 'Rating Value');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Rating Version Number');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `watch_status` SET TAGS ('dbx_business_glossary_term' = 'Credit Watch Status');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `watch_status` SET TAGS ('dbx_value_regex' = 'Upgrade|Downgrade|None');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'Rating Withdrawal Date');
ALTER TABLE `asset_management`.`credit`.`rating` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_business_glossary_term' = 'Rating Withdrawal Reason');
ALTER TABLE `asset_management`.`credit`.`rating_action` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`credit`.`rating_action` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`rating_action` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`rating_action` SET TAGS ('dbx_subdomain' = 'risk_analytics');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `rating_action_id` SET TAGS ('dbx_business_glossary_term' = 'Rating Action Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `credit_issuer_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Internal Reviewer Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `fixed_income_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `action_source_system` SET TAGS ('dbx_business_glossary_term' = 'Rating Action Source System');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `action_trigger_event` SET TAGS ('dbx_business_glossary_term' = 'Rating Action Trigger Event');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `action_type` SET TAGS ('dbx_business_glossary_term' = 'Rating Action Type');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `analyst_name` SET TAGS ('dbx_business_glossary_term' = 'Lead Rating Analyst Name');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `announcement_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Rating Action Announcement Timestamp');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `committee_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Rating Committee Approval Date');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `credit_spread_impact_bps` SET TAGS ('dbx_business_glossary_term' = 'Credit Spread Impact (Basis Points)');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `default_probability_estimate` SET TAGS ('dbx_business_glossary_term' = 'Default Probability Estimate');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Rating Action Effective Date');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Issuer Geographic Region');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `internal_review_date` SET TAGS ('dbx_business_glossary_term' = 'Internal Review Completion Date');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `internal_review_status` SET TAGS ('dbx_business_glossary_term' = 'Internal Review Status');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `internal_review_status` SET TAGS ('dbx_value_regex' = 'pending_review|reviewed|approved|escalated');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `investment_policy_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Policy Breach Flag');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `new_outlook` SET TAGS ('dbx_business_glossary_term' = 'New Rating Outlook');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `new_outlook` SET TAGS ('dbx_value_regex' = 'positive|negative|stable|developing|not_applicable');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `new_rating` SET TAGS ('dbx_business_glossary_term' = 'New Credit Rating');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `notch_change` SET TAGS ('dbx_business_glossary_term' = 'Rating Notch Change');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `portfolio_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Impact Flag');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `prior_outlook` SET TAGS ('dbx_business_glossary_term' = 'Prior Rating Outlook');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `prior_outlook` SET TAGS ('dbx_value_regex' = 'positive|negative|stable|developing|not_applicable');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `prior_rating` SET TAGS ('dbx_business_glossary_term' = 'Prior Credit Rating');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `rating_agency_code` SET TAGS ('dbx_business_glossary_term' = 'Rating Agency Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `rating_category` SET TAGS ('dbx_business_glossary_term' = 'Investment Grade (IG) or High Yield (HY) Rating Category');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `rating_category` SET TAGS ('dbx_value_regex' = 'investment_grade|high_yield|non_rated|default');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `rating_scale` SET TAGS ('dbx_business_glossary_term' = 'Rating Scale Type');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `rating_scale` SET TAGS ('dbx_value_regex' = 'long_term_issuer|short_term_issuer|long_term_issue|short_term_issue|sovereign|municipal');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `rating_type` SET TAGS ('dbx_business_glossary_term' = 'Rating Type Classification');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `rating_type` SET TAGS ('dbx_value_regex' = 'issuer_credit|senior_unsecured|senior_secured|subordinated|preferred_stock|commercial_paper');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `rationale_summary` SET TAGS ('dbx_business_glossary_term' = 'Rating Action Rationale Summary');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `recovery_rate_estimate` SET TAGS ('dbx_business_glossary_term' = 'Recovery Rate Estimate (Percentage)');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `report_url` SET TAGS ('dbx_business_glossary_term' = 'Rating Report Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Issuer Sector Classification');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `solicited_flag` SET TAGS ('dbx_business_glossary_term' = 'Solicited Rating Flag');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `watch_status` SET TAGS ('dbx_business_glossary_term' = 'Credit Watch Status');
ALTER TABLE `asset_management`.`credit`.`rating_action` ALTER COLUMN `watch_status` SET TAGS ('dbx_value_regex' = 'creditwatch_positive|creditwatch_negative|under_review_upgrade|under_review_downgrade|not_on_watch');
ALTER TABLE `asset_management`.`credit`.`cds_position` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`credit`.`cds_position` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`cds_position` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`cds_position` SET TAGS ('dbx_subdomain' = 'risk_analytics');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `cds_position_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Default Swap (CDS) Position Identifier');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `credit_issuer_id` SET TAGS ('dbx_business_glossary_term' = 'Reference Entity Identifier');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `fixed_income_security_id` SET TAGS ('dbx_business_glossary_term' = 'Reference Obligation Identifier');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `reference_entity_actor_id` SET TAGS ('dbx_business_glossary_term' = 'Reference Entity Actor Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `reference_entity_credit_issuer_id` SET TAGS ('dbx_business_glossary_term' = 'Reference Entity Identifier');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `accrued_premium` SET TAGS ('dbx_business_glossary_term' = 'Accrued Premium');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `ccp_name` SET TAGS ('dbx_business_glossary_term' = 'Central Counterparty (CCP) Name');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `clearing_status` SET TAGS ('dbx_business_glossary_term' = 'Clearing Status');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `clearing_status` SET TAGS ('dbx_value_regex' = 'cleared|bilateral|uncleared');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `collateral_currency` SET TAGS ('dbx_business_glossary_term' = 'Collateral Currency');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `collateral_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `collateral_posted` SET TAGS ('dbx_business_glossary_term' = 'Collateral Posted');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `collateral_received` SET TAGS ('dbx_business_glossary_term' = 'Collateral Received');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `contract_identifier` SET TAGS ('dbx_business_glossary_term' = 'Contract Identifier');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `credit_event_date` SET TAGS ('dbx_business_glossary_term' = 'Credit Event Date');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `credit_event_flag` SET TAGS ('dbx_business_glossary_term' = 'Credit Event Flag');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `dv01` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of 01 Basis Point (DV01)');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `index_flag` SET TAGS ('dbx_business_glossary_term' = 'Index Flag');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `index_name` SET TAGS ('dbx_business_glossary_term' = 'Index Name');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `index_series` SET TAGS ('dbx_business_glossary_term' = 'Index Series');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `index_version` SET TAGS ('dbx_business_glossary_term' = 'Index Version');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `market_spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Market Spread in Basis Points (bps)');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `market_value` SET TAGS ('dbx_business_glossary_term' = 'Market Value');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `market_value_currency` SET TAGS ('dbx_business_glossary_term' = 'Market Value Currency');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `market_value_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `notional_amount` SET TAGS ('dbx_business_glossary_term' = 'Notional Amount');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `notional_currency` SET TAGS ('dbx_business_glossary_term' = 'Notional Currency');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `notional_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `position_status` SET TAGS ('dbx_business_glossary_term' = 'Position Status');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `position_status` SET TAGS ('dbx_value_regex' = 'active|matured|terminated|novated|assigned');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `protection_direction` SET TAGS ('dbx_business_glossary_term' = 'Protection Direction');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `protection_direction` SET TAGS ('dbx_value_regex' = 'bought|sold');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `recovery_rate_assumption` SET TAGS ('dbx_business_glossary_term' = 'Recovery Rate Assumption');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `reference_entity_lei` SET TAGS ('dbx_business_glossary_term' = 'Reference Entity Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `reference_entity_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `restructuring_clause` SET TAGS ('dbx_business_glossary_term' = 'Restructuring Clause');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `restructuring_clause` SET TAGS ('dbx_value_regex' = 'CR|MR|MM|XR|no_restructuring');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `running_spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Running Spread in Basis Points (bps)');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `seniority` SET TAGS ('dbx_business_glossary_term' = 'Seniority');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `seniority` SET TAGS ('dbx_value_regex' = 'senior|subordinated|junior');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'physical|cash|auction');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `tenor_years` SET TAGS ('dbx_business_glossary_term' = 'Tenor in Years');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `trade_date` SET TAGS ('dbx_business_glossary_term' = 'Trade Date');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `upfront_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Upfront Payment Amount');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `upfront_payment_currency` SET TAGS ('dbx_business_glossary_term' = 'Upfront Payment Currency');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `upfront_payment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `upfront_payment_direction` SET TAGS ('dbx_business_glossary_term' = 'Upfront Payment Direction');
ALTER TABLE `asset_management`.`credit`.`cds_position` ALTER COLUMN `upfront_payment_direction` SET TAGS ('dbx_value_regex' = 'paid|received');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` SET TAGS ('dbx_subdomain' = 'risk_analytics');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `cds_market_data_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Default Swap (CDS) Market Data ID');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `credit_issuer_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Issuer Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `reference_entity_actor_id` SET TAGS ('dbx_business_glossary_term' = 'Reference Entity Actor Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `reference_entity_credit_issuer_id` SET TAGS ('dbx_business_glossary_term' = 'Reference Entity ID');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `ask_spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Ask Spread in Basis Points (bps)');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `bid_ask_spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Bid-Ask Spread in Basis Points (bps)');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `bid_spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Bid Spread in Basis Points (bps)');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `cds_index_series` SET TAGS ('dbx_business_glossary_term' = 'Credit Default Swap (CDS) Index Series');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `cds_index_version` SET TAGS ('dbx_business_glossary_term' = 'Credit Default Swap (CDS) Index Version');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `coupon_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Coupon Rate in Basis Points (bps)');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `credit_rating_fitch` SET TAGS ('dbx_business_glossary_term' = 'Fitch Credit Rating');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `credit_rating_moody` SET TAGS ('dbx_business_glossary_term' = 'Moodys Credit Rating');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `credit_rating_sp` SET TAGS ('dbx_business_glossary_term' = 'Standard & Poors (S&P) Credit Rating');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `cs01` SET TAGS ('dbx_business_glossary_term' = 'Credit Spread 01 (CS01)');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `data_quality_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Flag');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Market Data Source');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `dv01` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of 01 (DV01)');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `implied_probability_of_default` SET TAGS ('dbx_business_glossary_term' = 'Implied Probability of Default (PD)');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Active Status Indicator');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `liquidity_score` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Score');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `mid_spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Mid Spread in Basis Points (bps)');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `pricing_date` SET TAGS ('dbx_business_glossary_term' = 'Pricing Date');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `pricing_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Pricing Timestamp');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `rating_outlook` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating Outlook');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `rating_outlook` SET TAGS ('dbx_value_regex' = 'positive|stable|negative|developing');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `recovery_rate_assumption` SET TAGS ('dbx_business_glossary_term' = 'Recovery Rate Assumption');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `reference_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Reference Entity Name');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `reference_entity_ticker` SET TAGS ('dbx_business_glossary_term' = 'Reference Entity Ticker Symbol');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `reference_entity_type` SET TAGS ('dbx_business_glossary_term' = 'Reference Entity Type');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `reference_entity_type` SET TAGS ('dbx_value_regex' = 'corporate|sovereign|index|municipal|structured');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `region` SET TAGS ('dbx_value_regex' = 'north_america|europe|asia_pacific|latin_america|middle_east_africa|global');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `restructuring_clause` SET TAGS ('dbx_business_glossary_term' = 'Restructuring Clause');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `restructuring_clause` SET TAGS ('dbx_value_regex' = 'no_restructuring|modified_restructuring|modified_modified_restructuring|full_restructuring');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Industry Sector');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `seniority` SET TAGS ('dbx_business_glossary_term' = 'Debt Seniority');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `seniority` SET TAGS ('dbx_value_regex' = 'senior_unsecured|senior_secured|subordinated|junior_subordinated');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Credit Default Swap (CDS) Spread in Basis Points (bps)');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `tenor` SET TAGS ('dbx_business_glossary_term' = 'Credit Default Swap (CDS) Tenor');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `tenor` SET TAGS ('dbx_value_regex' = '1Y|2Y|3Y|5Y|7Y|10Y');
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ALTER COLUMN `upfront_points` SET TAGS ('dbx_business_glossary_term' = 'Upfront Points');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` SET TAGS ('dbx_subdomain' = 'private_credit');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `private_credit_investment_id` SET TAGS ('dbx_business_glossary_term' = 'Private Credit Investment Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Manager Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Manager Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `investment_manager_actor_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Manager Actor Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `borrower_legal_name` SET TAGS ('dbx_business_glossary_term' = 'Borrower Legal Name');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `borrower_legal_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `borrower_lei` SET TAGS ('dbx_business_glossary_term' = 'Borrower Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `borrower_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `commitment_date` SET TAGS ('dbx_business_glossary_term' = 'Commitment Date');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `committed_amount` SET TAGS ('dbx_business_glossary_term' = 'Committed Amount');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `convexity` SET TAGS ('dbx_business_glossary_term' = 'Convexity');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `coupon_rate` SET TAGS ('dbx_business_glossary_term' = 'Coupon Rate');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `covenant_package` SET TAGS ('dbx_business_glossary_term' = 'Covenant Package Type');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `covenant_package` SET TAGS ('dbx_value_regex' = 'covenant_lite|maintenance_covenants|incurrence_covenants|full_covenant');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `default_probability` SET TAGS ('dbx_business_glossary_term' = 'Probability of Default (PD)');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `dv01` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of 01 Basis Point (DV01)');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `effective_duration` SET TAGS ('dbx_business_glossary_term' = 'Effective Duration');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `esg_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Score');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `expected_credit_loss` SET TAGS ('dbx_business_glossary_term' = 'Expected Credit Loss (ECL)');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `external_credit_rating` SET TAGS ('dbx_business_glossary_term' = 'External Credit Rating');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `fair_value` SET TAGS ('dbx_business_glossary_term' = 'Fair Value');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `first_funding_date` SET TAGS ('dbx_business_glossary_term' = 'First Funding Date');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `floating_rate_index` SET TAGS ('dbx_business_glossary_term' = 'Floating Rate Index');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `funded_amount` SET TAGS ('dbx_business_glossary_term' = 'Funded Amount');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `industry_sector` SET TAGS ('dbx_business_glossary_term' = 'Industry Sector');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `internal_credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Internal Credit Rating');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `investment_name` SET TAGS ('dbx_business_glossary_term' = 'Investment Name');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `investment_status` SET TAGS ('dbx_business_glossary_term' = 'Investment Status');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `investment_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Type');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `lead_arranger` SET TAGS ('dbx_business_glossary_term' = 'Lead Arranger');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `loan_to_value_ratio` SET TAGS ('dbx_business_glossary_term' = 'Loan to Value Ratio (LTV)');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `loss_given_default` SET TAGS ('dbx_business_glossary_term' = 'Loss Given Default (LGD)');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `modified_duration` SET TAGS ('dbx_business_glossary_term' = 'Modified Duration');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `oas` SET TAGS ('dbx_business_glossary_term' = 'Option-Adjusted Spread (OAS)');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `origination_date` SET TAGS ('dbx_business_glossary_term' = 'Origination Date');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `outstanding_principal` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Principal Balance');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|at_maturity');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `pik_toggle_flag` SET TAGS ('dbx_business_glossary_term' = 'Payment-in-Kind (PIK) Toggle Flag');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `prepayment_penalty_flag` SET TAGS ('dbx_business_glossary_term' = 'Prepayment Penalty Flag');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `seniority` SET TAGS ('dbx_business_glossary_term' = 'Seniority in Capital Structure');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `seniority` SET TAGS ('dbx_value_regex' = 'senior_secured|senior_unsecured|subordinated|mezzanine|junior');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Spread in Basis Points (bps)');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `syndication_flag` SET TAGS ('dbx_business_glossary_term' = 'Syndication Flag');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ALTER COLUMN `ytm` SET TAGS ('dbx_business_glossary_term' = 'Yield to Maturity (YTM)');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` SET TAGS ('dbx_subdomain' = 'private_credit');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `private_credit_drawdown_id` SET TAGS ('dbx_business_glossary_term' = 'Private Credit Drawdown ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Lender Entity ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `blotter_id` SET TAGS ('dbx_business_glossary_term' = 'Blotter Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `booking_entity_actor_id` SET TAGS ('dbx_business_glossary_term' = 'Booking Entity ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `borrower_actor_id` SET TAGS ('dbx_business_glossary_term' = 'Borrower Actor Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Borrower Entity ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Funding Account ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `private_credit_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Private Credit Facility ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `private_credit_investment_id` SET TAGS ('dbx_business_glossary_term' = 'Private Credit Facility ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `approval_authority` SET TAGS ('dbx_business_glossary_term' = 'Approval Authority');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'private_credit|direct_lending|mezzanine|distressed_debt|structured_credit');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `available_commitment` SET TAGS ('dbx_business_glossary_term' = 'Available Commitment');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `base_rate_type` SET TAGS ('dbx_business_glossary_term' = 'Base Rate Type');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `base_rate_type` SET TAGS ('dbx_value_regex' = 'SOFR|LIBOR|EURIBOR|Prime|Fixed');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `collateral_pledged` SET TAGS ('dbx_business_glossary_term' = 'Collateral Pledged');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `collateral_value` SET TAGS ('dbx_business_glossary_term' = 'Collateral Value');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `commitment_fee_waived` SET TAGS ('dbx_business_glossary_term' = 'Commitment Fee Waived');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `covenant_compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Covenant Compliance Status');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `covenant_compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|breach|waived|not_applicable');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `cumulative_drawn_balance` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Drawn Balance');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `drawdown_amount` SET TAGS ('dbx_business_glossary_term' = 'Drawdown Amount');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `drawdown_currency` SET TAGS ('dbx_business_glossary_term' = 'Drawdown Currency');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `drawdown_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `drawdown_date` SET TAGS ('dbx_business_glossary_term' = 'Drawdown Date');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `drawdown_number` SET TAGS ('dbx_business_glossary_term' = 'Drawdown Number');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `drawdown_purpose` SET TAGS ('dbx_business_glossary_term' = 'Drawdown Purpose');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `drawdown_status` SET TAGS ('dbx_business_glossary_term' = 'Drawdown Status');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `drawdown_status` SET TAGS ('dbx_value_regex' = 'pending|approved|funded|cancelled|failed');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `esg_classification` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Classification');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `esg_classification` SET TAGS ('dbx_value_regex' = 'article_6|article_8|article_9|not_classified');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `funding_source` SET TAGS ('dbx_business_glossary_term' = 'Funding Source');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `industry_sector` SET TAGS ('dbx_business_glossary_term' = 'Industry Sector');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `interest_payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Interest Payment Frequency');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `interest_payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi-annually|annually|at_maturity');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `interest_rate_at_drawdown` SET TAGS ('dbx_business_glossary_term' = 'Interest Rate at Drawdown');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `loan_to_value_ratio` SET TAGS ('dbx_business_glossary_term' = 'Loan to Value (LTV) Ratio');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Drawdown Notes');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `prepayment_allowed` SET TAGS ('dbx_business_glossary_term' = 'Prepayment Allowed');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `prepayment_penalty_rate` SET TAGS ('dbx_business_glossary_term' = 'Prepayment Penalty Rate');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `settlement_status` SET TAGS ('dbx_business_glossary_term' = 'Settlement Status');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `settlement_status` SET TAGS ('dbx_value_regex' = 'pending|settled|failed|reversed');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Spread (bps)');
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` SET TAGS ('dbx_subdomain' = 'private_credit');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `private_credit_repayment_id` SET TAGS ('dbx_business_glossary_term' = 'Private Credit Repayment ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `amortization_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Amortization Schedule ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `blotter_id` SET TAGS ('dbx_business_glossary_term' = 'Blotter Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Borrower Entity ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `custody_account_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Account ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `private_counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Borrower Entity ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `private_credit_investment_id` SET TAGS ('dbx_business_glossary_term' = 'Private Credit Investment ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `private_servicer_entity_counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Servicer Entity ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `servicer_entity_counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Servicer Entity ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `accounting_treatment` SET TAGS ('dbx_business_glossary_term' = 'Accounting Treatment');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `accounting_treatment` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `accounting_treatment` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `accrued_interest_end_date` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest End Date');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `accrued_interest_start_date` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest Start Date');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_business_glossary_term' = 'Day Count Convention');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_value_regex' = 'actual_360|actual_365|30_360|actual_actual');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `days_accrued` SET TAGS ('dbx_business_glossary_term' = 'Days Accrued');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `gl_posting_date` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Posting Date');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `interest_amount_repaid` SET TAGS ('dbx_business_glossary_term' = 'Interest Amount Repaid');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `interest_rate_applied` SET TAGS ('dbx_business_glossary_term' = 'Interest Rate Applied');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `is_early_repayment` SET TAGS ('dbx_business_glossary_term' = 'Is Early Repayment');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `is_partial_repayment` SET TAGS ('dbx_business_glossary_term' = 'Is Partial Repayment');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Repayment Notes');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `outstanding_principal_balance` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Principal Balance');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|ach|check|direct_debit|automated_clearing');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `payment_reference` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `prepayment_premium` SET TAGS ('dbx_business_glossary_term' = 'Prepayment Premium');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `principal_amount_repaid` SET TAGS ('dbx_business_glossary_term' = 'Principal Amount Repaid');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Date');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'pending|matched|unmatched|exception|resolved');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `repayment_date` SET TAGS ('dbx_business_glossary_term' = 'Repayment Date');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `repayment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Repayment Reference Number');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `repayment_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Repayment Sequence Number');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `repayment_status` SET TAGS ('dbx_business_glossary_term' = 'Repayment Status');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `repayment_status` SET TAGS ('dbx_value_regex' = 'pending|settled|failed|reversed|cancelled|reconciled');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `repayment_type` SET TAGS ('dbx_business_glossary_term' = 'Repayment Type');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `repayment_type` SET TAGS ('dbx_value_regex' = 'scheduled_principal|scheduled_interest|prepayment|partial_prepayment|full_prepayment|amortization');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `scheduled_repayment_amount` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Repayment Amount');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `total_repayment_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Repayment Amount');
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ALTER COLUMN `variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Variance Amount');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` SET TAGS ('dbx_subdomain' = 'private_credit');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `covenant_monitoring_id` SET TAGS ('dbx_business_glossary_term' = 'Covenant Monitoring ID');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `investment_id` SET TAGS ('dbx_business_glossary_term' = 'Investment ID');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `actual_value` SET TAGS ('dbx_business_glossary_term' = 'Actual Measured Value');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `borrower_lei` SET TAGS ('dbx_business_glossary_term' = 'Borrower Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `borrower_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `borrower_name` SET TAGS ('dbx_business_glossary_term' = 'Borrower Name');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `breach_date` SET TAGS ('dbx_business_glossary_term' = 'Breach Date');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Breach Flag');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `breach_severity` SET TAGS ('dbx_business_glossary_term' = 'Breach Severity');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `breach_severity` SET TAGS ('dbx_value_regex' = 'minor|moderate|material|critical');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|breach|waived|cured|under_review');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `covenant_category` SET TAGS ('dbx_business_glossary_term' = 'Covenant Category');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `covenant_category` SET TAGS ('dbx_value_regex' = 'affirmative|negative|financial|reporting');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `covenant_description` SET TAGS ('dbx_business_glossary_term' = 'Covenant Description');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `covenant_type` SET TAGS ('dbx_business_glossary_term' = 'Covenant Type');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `covenant_type` SET TAGS ('dbx_value_regex' = 'leverage_ratio|interest_coverage_ratio|ltv|dscr|minimum_liquidity|net_worth');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `cure_date` SET TAGS ('dbx_business_glossary_term' = 'Cure Date');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `cure_mechanism` SET TAGS ('dbx_business_glossary_term' = 'Cure Mechanism');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `cushion_amount` SET TAGS ('dbx_business_glossary_term' = 'Covenant Cushion Amount');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `cushion_percentage` SET TAGS ('dbx_business_glossary_term' = 'Covenant Cushion Percentage');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `data_source` SET TAGS ('dbx_value_regex' = 'borrower_report|audited_financials|management_accounts|third_party_valuation');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `lender_action` SET TAGS ('dbx_business_glossary_term' = 'Lender Action');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `measurement_date` SET TAGS ('dbx_business_glossary_term' = 'Measurement Date');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `measurement_period_end` SET TAGS ('dbx_business_glossary_term' = 'Measurement Period End Date');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `measurement_period_start` SET TAGS ('dbx_business_glossary_term' = 'Measurement Period Start Date');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `next_test_date` SET TAGS ('dbx_business_glossary_term' = 'Next Test Date');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `remediation_plan` SET TAGS ('dbx_business_glossary_term' = 'Remediation Plan');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `reporting_deadline` SET TAGS ('dbx_business_glossary_term' = 'Reporting Deadline');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Covenant Risk Rating');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `testing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Testing Frequency');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `testing_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annually|annually');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `threshold_operator` SET TAGS ('dbx_business_glossary_term' = 'Threshold Operator');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `threshold_operator` SET TAGS ('dbx_value_regex' = 'greater_than|less_than|greater_than_or_equal|less_than_or_equal|equal');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `threshold_value` SET TAGS ('dbx_business_glossary_term' = 'Covenant Threshold Value');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `trend_direction` SET TAGS ('dbx_business_glossary_term' = 'Trend Direction');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `trend_direction` SET TAGS ('dbx_value_regex' = 'improving|stable|deteriorating');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Verification Date');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `verification_status` SET TAGS ('dbx_business_glossary_term' = 'Verification Status');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `verification_status` SET TAGS ('dbx_value_regex' = 'unverified|verified|audited|disputed');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `verified_by` SET TAGS ('dbx_business_glossary_term' = 'Verified By');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `waiver_date` SET TAGS ('dbx_business_glossary_term' = 'Waiver Date');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `waiver_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Waiver Expiry Date');
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ALTER COLUMN `waiver_granted_flag` SET TAGS ('dbx_business_glossary_term' = 'Waiver Granted Flag');
ALTER TABLE `asset_management`.`credit`.`structured_product` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`credit`.`structured_product` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`structured_product` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`structured_product` SET TAGS ('dbx_subdomain' = 'fixed_income');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `structured_product_id` SET TAGS ('dbx_business_glossary_term' = 'Structured Product Identifier');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `credit_issuer_id` SET TAGS ('dbx_internal' = 'true');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `fixed_income_security_id` SET TAGS ('dbx_business_glossary_term' = 'Fixed Income Security Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `accrued_interest` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `bloomberg_ticker` SET TAGS ('dbx_business_glossary_term' = 'Bloomberg Ticker Symbol');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `collateral_pool_size` SET TAGS ('dbx_business_glossary_term' = 'Collateral Pool Size');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `constant_prepayment_rate` SET TAGS ('dbx_business_glossary_term' = 'Constant Prepayment Rate (CPR)');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `convexity` SET TAGS ('dbx_business_glossary_term' = 'Convexity');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `coupon_frequency` SET TAGS ('dbx_business_glossary_term' = 'Coupon Payment Frequency');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `coupon_frequency` SET TAGS ('dbx_value_regex' = 'Monthly|Quarterly|Semi-Annual|Annual');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `coupon_rate` SET TAGS ('dbx_business_glossary_term' = 'Coupon Rate');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `credit_enhancement_pct` SET TAGS ('dbx_business_glossary_term' = 'Credit Enhancement Percentage');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `credit_rating_fitch` SET TAGS ('dbx_business_glossary_term' = 'Fitch Credit Rating');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `credit_rating_moody` SET TAGS ('dbx_business_glossary_term' = 'Moodys Credit Rating');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `credit_rating_sp` SET TAGS ('dbx_business_glossary_term' = 'Standard and Poors (S&P) Credit Rating');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `current_face_value` SET TAGS ('dbx_business_glossary_term' = 'Current Face Value');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `default_rate` SET TAGS ('dbx_business_glossary_term' = 'Default Rate');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `duration` SET TAGS ('dbx_business_glossary_term' = 'Duration');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `dv01` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of 01 Basis Point (DV01)');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `expected_maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Expected Maturity Date');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `floating_rate_flag` SET TAGS ('dbx_business_glossary_term' = 'Floating Rate Flag');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `investment_grade_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Grade (IG) Flag');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'Issue Date');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `loss_severity_rate` SET TAGS ('dbx_business_glossary_term' = 'Loss Severity Rate');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `market_price` SET TAGS ('dbx_business_glossary_term' = 'Market Price');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `number_of_collateral_assets` SET TAGS ('dbx_business_glossary_term' = 'Number of Collateral Assets');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `oas` SET TAGS ('dbx_business_glossary_term' = 'Option-Adjusted Spread (OAS)');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `original_face_value` SET TAGS ('dbx_business_glossary_term' = 'Original Face Value');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `overcollateralization_pct` SET TAGS ('dbx_business_glossary_term' = 'Overcollateralization Percentage');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `price_date` SET TAGS ('dbx_business_glossary_term' = 'Price Date');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `product_type` SET TAGS ('dbx_business_glossary_term' = 'Structured Product Type');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `reference_rate` SET TAGS ('dbx_business_glossary_term' = 'Reference Rate');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `security_name` SET TAGS ('dbx_business_glossary_term' = 'Security Name');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `spread_over_reference_bps` SET TAGS ('dbx_business_glossary_term' = 'Spread Over Reference Rate in Basis Points (bps)');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `subordination_pct` SET TAGS ('dbx_business_glossary_term' = 'Subordination Percentage');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `tranche_name` SET TAGS ('dbx_business_glossary_term' = 'Tranche Name');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `tranche_seniority` SET TAGS ('dbx_business_glossary_term' = 'Tranche Seniority Level');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `tranche_seniority` SET TAGS ('dbx_value_regex' = 'Senior|Mezzanine|Junior|Equity|Subordinated|Super Senior');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `weighted_average_coupon` SET TAGS ('dbx_business_glossary_term' = 'Weighted Average Coupon (WAC)');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `weighted_average_life_years` SET TAGS ('dbx_business_glossary_term' = 'Weighted Average Life (WAL) in Years');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `weighted_average_maturity_months` SET TAGS ('dbx_business_glossary_term' = 'Weighted Average Maturity (WAM) in Months');
ALTER TABLE `asset_management`.`credit`.`structured_product` ALTER COLUMN `ytm` SET TAGS ('dbx_business_glossary_term' = 'Yield to Maturity (YTM)');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` SET TAGS ('dbx_subdomain' = 'fixed_income');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `sovereign_debt_holding_id` SET TAGS ('dbx_business_glossary_term' = 'Sovereign Debt Holding Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Manager Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `fixed_income_security_id` SET TAGS ('dbx_business_glossary_term' = 'Fixed Income Security Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `accounting_classification` SET TAGS ('dbx_business_glossary_term' = 'Accounting Classification');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `accounting_classification` SET TAGS ('dbx_value_regex' = 'held_to_maturity|available_for_sale|fair_value_through_pl');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `accrued_interest` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `acquisition_date` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Date');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'fixed_income');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `average_cost` SET TAGS ('dbx_business_glossary_term' = 'Average Cost per Unit');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `book_value` SET TAGS ('dbx_business_glossary_term' = 'Book Value');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `callable_flag` SET TAGS ('dbx_business_glossary_term' = 'Callable Flag');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `cost_basis` SET TAGS ('dbx_business_glossary_term' = 'Cost Basis');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `coupon_frequency` SET TAGS ('dbx_business_glossary_term' = 'Coupon Frequency');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `coupon_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly|zero_coupon');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `coupon_rate` SET TAGS ('dbx_business_glossary_term' = 'Coupon Rate');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `credit_rating_fitch` SET TAGS ('dbx_business_glossary_term' = 'Fitch Credit Rating');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `credit_rating_moody` SET TAGS ('dbx_business_glossary_term' = 'Moodys Credit Rating');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `credit_rating_sp` SET TAGS ('dbx_business_glossary_term' = 'Standard and Poors (S&P) Credit Rating');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP) Code');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[0-9A-Z]{5}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `custodian_account` SET TAGS ('dbx_business_glossary_term' = 'Custodian Account Number');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `custodian_account` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `custodian_name` SET TAGS ('dbx_business_glossary_term' = 'Custodian Name');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `duration` SET TAGS ('dbx_business_glossary_term' = 'Duration');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `dv01` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of 01 Basis Point (DV01)');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `face_value` SET TAGS ('dbx_business_glossary_term' = 'Face Value');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `green_bond_flag` SET TAGS ('dbx_business_glossary_term' = 'Green Bond Flag');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `holding_status` SET TAGS ('dbx_business_glossary_term' = 'Holding Status');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `holding_status` SET TAGS ('dbx_value_regex' = 'active|matured|sold|called|defaulted');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `inflation_linked_flag` SET TAGS ('dbx_business_glossary_term' = 'Inflation Linked Flag');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `investment_grade_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Grade Flag');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `issuer_country` SET TAGS ('dbx_business_glossary_term' = 'Issuer Country Code');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `issuer_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Name');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `market_value` SET TAGS ('dbx_business_glossary_term' = 'Market Value');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `market_value_date` SET TAGS ('dbx_business_glossary_term' = 'Market Value Date');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Quantity Held');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `security_name` SET TAGS ('dbx_business_glossary_term' = 'Security Name');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `security_type` SET TAGS ('dbx_business_glossary_term' = 'Security Type');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `security_type` SET TAGS ('dbx_value_regex' = 'treasury_bond|treasury_bill|inflation_linked_bond|agency_bond|supranational_bond|provincial_bond');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL) Code');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `unrealized_gain_loss` SET TAGS ('dbx_business_glossary_term' = 'Unrealized Gain or Loss');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ALTER COLUMN `ytm` SET TAGS ('dbx_business_glossary_term' = 'Yield to Maturity (YTM)');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` SET TAGS ('dbx_subdomain' = 'benchmark_reference');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `credit_yield_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Yield Curve Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `active_flag` SET TAGS ('dbx_business_glossary_term' = 'Active Record Flag');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `benchmark_flag` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Curve Flag');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `compounding_frequency` SET TAGS ('dbx_business_glossary_term' = 'Compounding Frequency');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `compounding_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly|continuous');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `credit_quality` SET TAGS ('dbx_business_glossary_term' = 'Credit Quality Classification');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `curve_date` SET TAGS ('dbx_business_glossary_term' = 'Curve Observation Date');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `curve_name` SET TAGS ('dbx_business_glossary_term' = 'Yield Curve Name');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `curve_status` SET TAGS ('dbx_business_glossary_term' = 'Yield Curve Status');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `curve_status` SET TAGS ('dbx_value_regex' = 'active|historical|preliminary|final|superseded|invalid');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `curve_type` SET TAGS ('dbx_business_glossary_term' = 'Yield Curve Type');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_business_glossary_term' = 'Day Count Convention');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_value_regex' = 'act_360|act_365|30_360|act_act');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `effective_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Effective Timestamp');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `expiry_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Expiry Timestamp');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `interpolation_method` SET TAGS ('dbx_business_glossary_term' = 'Interpolation Method');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `interpolation_method` SET TAGS ('dbx_value_regex' = 'linear|cubic_spline|nelson_siegel|svensson|log_linear|hermite');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction Code');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Curve Notes');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `publication_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Publication Timestamp');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `source_identifier` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_10y_discount_factor` SET TAGS ('dbx_business_glossary_term' = 'Ten Year (10Y) Discount Factor');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_10y_forward_rate` SET TAGS ('dbx_business_glossary_term' = 'Ten Year (10Y) Forward Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_10y_par_rate` SET TAGS ('dbx_business_glossary_term' = 'Ten Year (10Y) Par Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_10y_zero_rate` SET TAGS ('dbx_business_glossary_term' = 'Ten Year (10Y) Zero Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_15y_zero_rate` SET TAGS ('dbx_business_glossary_term' = 'Fifteen Year (15Y) Zero Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_1m_zero_rate` SET TAGS ('dbx_business_glossary_term' = 'One Month (1M) Zero Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_1y_discount_factor` SET TAGS ('dbx_business_glossary_term' = 'One Year (1Y) Discount Factor');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_1y_forward_rate` SET TAGS ('dbx_business_glossary_term' = 'One Year (1Y) Forward Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_1y_par_rate` SET TAGS ('dbx_business_glossary_term' = 'One Year (1Y) Par Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_1y_zero_rate` SET TAGS ('dbx_business_glossary_term' = 'One Year (1Y) Zero Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_20y_zero_rate` SET TAGS ('dbx_business_glossary_term' = 'Twenty Year (20Y) Zero Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_2y_zero_rate` SET TAGS ('dbx_business_glossary_term' = 'Two Year (2Y) Zero Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_30y_discount_factor` SET TAGS ('dbx_business_glossary_term' = 'Thirty Year (30Y) Discount Factor');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_30y_par_rate` SET TAGS ('dbx_business_glossary_term' = 'Thirty Year (30Y) Par Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_30y_zero_rate` SET TAGS ('dbx_business_glossary_term' = 'Thirty Year (30Y) Zero Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_3m_zero_rate` SET TAGS ('dbx_business_glossary_term' = 'Three Month (3M) Zero Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_3y_zero_rate` SET TAGS ('dbx_business_glossary_term' = 'Three Year (3Y) Zero Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_5y_discount_factor` SET TAGS ('dbx_business_glossary_term' = 'Five Year (5Y) Discount Factor');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_5y_forward_rate` SET TAGS ('dbx_business_glossary_term' = 'Five Year (5Y) Forward Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_5y_par_rate` SET TAGS ('dbx_business_glossary_term' = 'Five Year (5Y) Par Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_5y_zero_rate` SET TAGS ('dbx_business_glossary_term' = 'Five Year (5Y) Zero Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_6m_zero_rate` SET TAGS ('dbx_business_glossary_term' = 'Six Month (6M) Zero Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `tenor_7y_zero_rate` SET TAGS ('dbx_business_glossary_term' = 'Seven Year (7Y) Zero Rate');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `validation_status` SET TAGS ('dbx_business_glossary_term' = 'Validation Status');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'passed|failed|pending|not_validated');
ALTER TABLE `asset_management`.`credit`.`credit_yield_curve` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` SET TAGS ('dbx_subdomain' = 'benchmark_reference');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `benchmark_index_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `active_flag` SET TAGS ('dbx_business_glossary_term' = 'Active Flag');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `base_date` SET TAGS ('dbx_business_glossary_term' = 'Base Date');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `base_value` SET TAGS ('dbx_business_glossary_term' = 'Base Value');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `benchmark_status` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Status');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `benchmark_status` SET TAGS ('dbx_value_regex' = 'Active|Discontinued|Suspended|Under Review');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `bloomberg_ticker` SET TAGS ('dbx_business_glossary_term' = 'Bloomberg Ticker');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `bloomberg_ticker` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4,10}$');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Calculation Frequency');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_value_regex' = 'Real-Time|End of Day|Intraday|Weekly');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `convexity` SET TAGS ('dbx_business_glossary_term' = 'Convexity');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `credit_quality` SET TAGS ('dbx_business_glossary_term' = 'Credit Quality');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `current_index_level` SET TAGS ('dbx_business_glossary_term' = 'Current Index Level');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `data_source` SET TAGS ('dbx_value_regex' = 'Bloomberg|FactSet|State Street|Northern Trust|SimCorp|Internal');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `duration_years` SET TAGS ('dbx_business_glossary_term' = 'Duration (Years)');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `eligibility_criteria` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Criteria');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `esg_methodology` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Methodology');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `esg_screened_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Screened Flag');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `factset_index_code` SET TAGS ('dbx_business_glossary_term' = 'FactSet Index Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Focus');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `hedged_flag` SET TAGS ('dbx_business_glossary_term' = 'Hedged Flag');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Inception Date');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `index_code` SET TAGS ('dbx_business_glossary_term' = 'Index Code');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `index_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,20}$');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `index_family` SET TAGS ('dbx_business_glossary_term' = 'Index Family');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `index_level_date` SET TAGS ('dbx_business_glossary_term' = 'Index Level Date');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `index_name` SET TAGS ('dbx_business_glossary_term' = 'Index Name');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `index_provider` SET TAGS ('dbx_business_glossary_term' = 'Index Provider');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `index_type` SET TAGS ('dbx_business_glossary_term' = 'Index Type');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `index_type` SET TAGS ('dbx_value_regex' = 'Total Return|Price Return|Excess Return|Hedged|Unhedged');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `last_rebalance_date` SET TAGS ('dbx_business_glossary_term' = 'Last Rebalance Date');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `mandate_compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Mandate Compliance Flag');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `market_value_usd` SET TAGS ('dbx_business_glossary_term' = 'Market Value United States Dollars (USD)');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `maturity_range` SET TAGS ('dbx_business_glossary_term' = 'Maturity Range');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `methodology_document_url` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `next_rebalance_date` SET TAGS ('dbx_business_glossary_term' = 'Next Rebalance Date');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `number_of_constituents` SET TAGS ('dbx_business_glossary_term' = 'Number of Constituents');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `oas_bps` SET TAGS ('dbx_business_glossary_term' = 'Option-Adjusted Spread (OAS) Basis Points (bps)');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `performance_attribution_flag` SET TAGS ('dbx_business_glossary_term' = 'Performance Attribution Flag');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `rebalance_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rebalance Frequency');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `rebalance_frequency` SET TAGS ('dbx_value_regex' = 'Daily|Monthly|Quarterly|Semi-Annual|Annual');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `regulatory_classification` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Classification');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `ric_code` SET TAGS ('dbx_business_glossary_term' = 'Reuters Instrument Code (RIC)');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `sector_focus` SET TAGS ('dbx_business_glossary_term' = 'Sector Focus');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{7}$');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `usage_purpose` SET TAGS ('dbx_business_glossary_term' = 'Usage Purpose');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `weighting_methodology` SET TAGS ('dbx_business_glossary_term' = 'Weighting Methodology');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `weighting_methodology` SET TAGS ('dbx_value_regex' = 'Market Cap Weighted|Equal Weighted|Duration Weighted|GDP Weighted|Custom');
ALTER TABLE `asset_management`.`credit`.`benchmark_index` ALTER COLUMN `ytm_percent` SET TAGS ('dbx_business_glossary_term' = 'Yield to Maturity (YTM) Percent');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` SET TAGS ('dbx_subdomain' = 'benchmark_reference');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `credit_benchmark_constituent_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Benchmark Constituent Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `benchmark_index_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `fixed_income_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `accrued_interest` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `bloomberg_ticker` SET TAGS ('dbx_business_glossary_term' = 'Bloomberg Ticker Symbol');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `callable_flag` SET TAGS ('dbx_business_glossary_term' = 'Callable Flag');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `composite_rating_category` SET TAGS ('dbx_business_glossary_term' = 'Composite Rating Category');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `constituent_status` SET TAGS ('dbx_business_glossary_term' = 'Constituent Status');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `constituent_status` SET TAGS ('dbx_value_regex' = 'active|removed|suspended|pending|matured');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `convexity` SET TAGS ('dbx_business_glossary_term' = 'Convexity');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_business_glossary_term' = 'Country of Risk');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `coupon_rate` SET TAGS ('dbx_business_glossary_term' = 'Coupon Rate');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `credit_rating_fitch` SET TAGS ('dbx_business_glossary_term' = 'Fitch Credit Rating');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `credit_rating_moody` SET TAGS ('dbx_business_glossary_term' = 'Moodys Credit Rating');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `credit_rating_sp` SET TAGS ('dbx_business_glossary_term' = 'Standard and Poors (S&P) Credit Rating');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `data_source` SET TAGS ('dbx_value_regex' = 'bloomberg|factset|msci|index_provider|internal');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `duration_contribution` SET TAGS ('dbx_business_glossary_term' = 'Duration Contribution');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `dv01` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of 01 Basis Point (DV01)');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `effective_duration` SET TAGS ('dbx_business_glossary_term' = 'Effective Duration');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Constituent Effective From Date');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `effective_to_date` SET TAGS ('dbx_business_glossary_term' = 'Constituent Effective To Date');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `exclusion_reason` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Reason');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `exclusion_reason` SET TAGS ('dbx_value_regex' = 'matured|rating_downgrade|called|defaulted|index_rule_change|insufficient_liquidity');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `face_value` SET TAGS ('dbx_business_glossary_term' = 'Face Value');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `floating_rate_flag` SET TAGS ('dbx_business_glossary_term' = 'Floating Rate Flag');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `green_bond_flag` SET TAGS ('dbx_business_glossary_term' = 'Green Bond Flag');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `inclusion_reason` SET TAGS ('dbx_business_glossary_term' = 'Inclusion Reason');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `inclusion_reason` SET TAGS ('dbx_value_regex' = 'new_issue|rebalancing|rating_upgrade|maturity_extension|index_rule_change');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `index_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Index Weight Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `investment_grade_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Grade Flag');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{18}[0-9]{2}$');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Name');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `market_price` SET TAGS ('dbx_business_glossary_term' = 'Market Price');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `market_value_contribution` SET TAGS ('dbx_business_glossary_term' = 'Market Value Contribution');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `market_value_currency` SET TAGS ('dbx_business_glossary_term' = 'Market Value Currency Code');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `market_value_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `modified_duration` SET TAGS ('dbx_business_glossary_term' = 'Modified Duration');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `oas` SET TAGS ('dbx_business_glossary_term' = 'Option-Adjusted Spread (OAS)');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `puttable_flag` SET TAGS ('dbx_business_glossary_term' = 'Puttable Flag');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `rebalancing_date` SET TAGS ('dbx_business_glossary_term' = 'Index Rebalancing Date');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `security_name` SET TAGS ('dbx_business_glossary_term' = 'Security Name');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `security_type` SET TAGS ('dbx_business_glossary_term' = 'Security Type');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9]{6}[0-9A-Z]$');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `subordination_level` SET TAGS ('dbx_business_glossary_term' = 'Subordination Level');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `subordination_level` SET TAGS ('dbx_value_regex' = 'senior_secured|senior_unsecured|subordinated|junior_subordinated');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `yield_contribution` SET TAGS ('dbx_business_glossary_term' = 'Yield Contribution');
ALTER TABLE `asset_management`.`credit`.`credit_benchmark_constituent` ALTER COLUMN `ytm` SET TAGS ('dbx_business_glossary_term' = 'Yield to Maturity (YTM)');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` SET TAGS ('dbx_subdomain' = 'benchmark_reference');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `credit_issuer_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Issuer Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `parent_credit_issuer_id` SET TAGS ('dbx_self_ref_fk' = 'true');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `active_flag` SET TAGS ('dbx_business_glossary_term' = 'Active Flag');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `country_of_domicile` SET TAGS ('dbx_business_glossary_term' = 'Country of Domicile');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `country_of_domicile` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_business_glossary_term' = 'Country of Risk');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `coverage_end_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage End Date');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `coverage_start_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Start Date');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `credit_rating_fitch` SET TAGS ('dbx_business_glossary_term' = 'Fitch Credit Rating');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `credit_rating_moody` SET TAGS ('dbx_business_glossary_term' = 'Moodys Credit Rating');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `credit_rating_sp` SET TAGS ('dbx_business_glossary_term' = 'Standard & Poors (S&P) Credit Rating');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `debt_currency` SET TAGS ('dbx_business_glossary_term' = 'Debt Currency');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `debt_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `default_date` SET TAGS ('dbx_business_glossary_term' = 'Default Date');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `default_flag` SET TAGS ('dbx_business_glossary_term' = 'Default Flag');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `ebitda` SET TAGS ('dbx_business_glossary_term' = 'Earnings Before Interest Taxes Depreciation and Amortization (EBITDA)');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `esg_rating_msci` SET TAGS ('dbx_business_glossary_term' = 'Morgan Stanley Capital International (MSCI) Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `esg_rating_sustainalytics` SET TAGS ('dbx_business_glossary_term' = 'Sustainalytics Environmental Social and Governance (ESG) Risk Rating');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `fiscal_year_end` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year End');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `fiscal_year_end` SET TAGS ('dbx_value_regex' = '^(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `ghg_emissions_scope_1_2` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Emissions Scope 1 and 2');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `industry_sector_gics` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Sector');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `industry_sector_icb` SET TAGS ('dbx_business_glossary_term' = 'Industry Classification Benchmark (ICB) Sector');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `investment_grade_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Grade (IG) Flag');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `issuer_type` SET TAGS ('dbx_business_glossary_term' = 'Issuer Type');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `issuer_type` SET TAGS ('dbx_value_regex' = 'corporate|sovereign|supranational|municipal|agency|financial_institution');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `kyc_next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Next Review Date');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `kyc_review_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Review Date');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `kyc_status` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Status');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `kyc_status` SET TAGS ('dbx_value_regex' = 'approved|pending|rejected|expired');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Name');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `listing_exchange` SET TAGS ('dbx_business_glossary_term' = 'Listing Exchange');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `market_capitalization` SET TAGS ('dbx_business_glossary_term' = 'Market Capitalization');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `pri_signatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Principles for Responsible Investment (PRI) Signatory Flag');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `public_private_flag` SET TAGS ('dbx_business_glossary_term' = 'Public or Private Flag');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `rating_outlook_fitch` SET TAGS ('dbx_business_glossary_term' = 'Fitch Rating Outlook');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `rating_outlook_fitch` SET TAGS ('dbx_value_regex' = 'positive|stable|negative|evolving');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `rating_outlook_moody` SET TAGS ('dbx_business_glossary_term' = 'Moodys Rating Outlook');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `rating_outlook_moody` SET TAGS ('dbx_value_regex' = 'positive|stable|negative|developing');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `rating_outlook_sp` SET TAGS ('dbx_business_glossary_term' = 'Standard & Poors (S&P) Rating Outlook');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `rating_outlook_sp` SET TAGS ('dbx_value_regex' = 'positive|stable|negative|developing');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `regulatory_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Status');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `regulatory_status` SET TAGS ('dbx_value_regex' = 'active|suspended|delisted|under_review');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `sanctioned_entity_flag` SET TAGS ('dbx_business_glossary_term' = 'Sanctioned Entity Flag');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `short_name` SET TAGS ('dbx_business_glossary_term' = 'Short Name');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `source_identifier` SET TAGS ('dbx_business_glossary_term' = 'Source Identifier');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `tcfd_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Task Force on Climate-related Financial Disclosures (TCFD) Reporting Flag');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `ticker_symbol` SET TAGS ('dbx_business_glossary_term' = 'Ticker Symbol');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `total_assets` SET TAGS ('dbx_business_glossary_term' = 'Total Assets');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `total_debt_outstanding` SET TAGS ('dbx_business_glossary_term' = 'Total Debt Outstanding');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `total_revenue` SET TAGS ('dbx_business_glossary_term' = 'Total Revenue');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`credit_issuer` ALTER COLUMN `watchlist_flag` SET TAGS ('dbx_business_glossary_term' = 'Watchlist Flag');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` SET TAGS ('dbx_subdomain' = 'fixed_income');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `maturity_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Maturity Schedule Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `fixed_income_security_id` SET TAGS ('dbx_business_glossary_term' = 'Fixed Income Security Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Settlement Account Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `accrued_interest` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `active_flag` SET TAGS ('dbx_business_glossary_term' = 'Active Flag');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `benchmark_rate` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Rate');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `benchmark_tenor` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Tenor');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `call_price` SET TAGS ('dbx_business_glossary_term' = 'Call Price');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `call_protection_end_date` SET TAGS ('dbx_business_glossary_term' = 'Call Protection End Date');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `convexity_to_event` SET TAGS ('dbx_business_glossary_term' = 'Convexity to Event');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `duration_to_event` SET TAGS ('dbx_business_glossary_term' = 'Duration to Event');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `event_date` SET TAGS ('dbx_business_glossary_term' = 'Event Date');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `exercise_decision_date` SET TAGS ('dbx_business_glossary_term' = 'Exercise Decision Date');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `exercise_status` SET TAGS ('dbx_business_glossary_term' = 'Exercise Status');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `exercise_status` SET TAGS ('dbx_value_regex' = 'pending|exercised|not_exercised|expired|cancelled');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `liquidity_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Impact Flag');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `make_whole_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Make Whole Provision Flag');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `make_whole_spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Make Whole Spread Basis Points (bps)');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `notification_date` SET TAGS ('dbx_business_glossary_term' = 'Notification Date');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `option_adjusted_spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Option Adjusted Spread Basis Points (OAS bps)');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `optional_redemption_flag` SET TAGS ('dbx_business_glossary_term' = 'Optional Redemption Flag');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `outstanding_principal_after` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Principal After Event');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `outstanding_principal_before` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Principal Before Event');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `probability_of_exercise` SET TAGS ('dbx_business_glossary_term' = 'Probability of Exercise');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `put_price` SET TAGS ('dbx_business_glossary_term' = 'Put Price');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `redemption_amount` SET TAGS ('dbx_business_glossary_term' = 'Redemption Amount');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `redemption_percentage` SET TAGS ('dbx_business_glossary_term' = 'Redemption Percentage');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `redemption_price` SET TAGS ('dbx_business_glossary_term' = 'Redemption Price');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `reinvestment_rate_assumption` SET TAGS ('dbx_business_glossary_term' = 'Reinvestment Rate Assumption');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `reinvestment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Reinvestment Strategy');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `reinvestment_strategy` SET TAGS ('dbx_value_regex' = 'same_asset_class|duration_match|yield_enhancement|cash_hold|tactical_allocation');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `schedule_type` SET TAGS ('dbx_business_glossary_term' = 'Schedule Type');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `schedule_type` SET TAGS ('dbx_value_regex' = 'maturity|call|put|sinking_fund|amortization|prepayment');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'DVP|FOP|cash_settlement|physical_delivery');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `sinking_fund_schedule_flag` SET TAGS ('dbx_business_glossary_term' = 'Sinking Fund Schedule Flag');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `tax_treatment` SET TAGS ('dbx_business_glossary_term' = 'Tax Treatment');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `tax_treatment` SET TAGS ('dbx_value_regex' = 'capital_gain|ordinary_income|tax_exempt|return_of_capital|other');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `tax_treatment` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `tax_treatment` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `total_proceeds` SET TAGS ('dbx_business_glossary_term' = 'Total Proceeds');
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ALTER COLUMN `yield_to_event` SET TAGS ('dbx_business_glossary_term' = 'Yield to Event (YTE)');
ALTER TABLE `asset_management`.`credit`.`default_event` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`credit`.`default_event` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`default_event` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`default_event` SET TAGS ('dbx_subdomain' = 'risk_analytics');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `default_event_id` SET TAGS ('dbx_business_glossary_term' = 'Default Event Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `credit_issuer_id` SET TAGS ('dbx_business_glossary_term' = 'Reference Entity Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `fixed_income_security_id` SET TAGS ('dbx_business_glossary_term' = 'Reference Obligation Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `reference_entity_actor_id` SET TAGS ('dbx_business_glossary_term' = 'Reference Entity Actor Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `reference_entity_credit_issuer_id` SET TAGS ('dbx_business_glossary_term' = 'Reference Entity Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `affected_bond_positions` SET TAGS ('dbx_business_glossary_term' = 'Affected Bond Positions Count');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `affected_cds_contracts` SET TAGS ('dbx_business_glossary_term' = 'Affected Credit Default Swap (CDS) Contracts Count');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `announcement_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Credit Event Announcement Timestamp');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `auction_date` SET TAGS ('dbx_business_glossary_term' = 'Credit Event Auction Settlement Date');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `auction_final_price` SET TAGS ('dbx_business_glossary_term' = 'Credit Event Auction Final Price');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `contagion_risk_flag` SET TAGS ('dbx_business_glossary_term' = 'Contagion Risk Flag');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_business_glossary_term' = 'Country of Risk');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `credit_rating_at_event` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating at Event Date');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Credit Event Data Source System');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `dc_determination_flag` SET TAGS ('dbx_business_glossary_term' = 'ISDA Determinations Committee (DC) Determination Flag');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `dc_region` SET TAGS ('dbx_business_glossary_term' = 'ISDA Determinations Committee (DC) Region');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `dc_region` SET TAGS ('dbx_value_regex' = 'americas|emea|asia|japan|australia_new_zealand');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `determination_date` SET TAGS ('dbx_business_glossary_term' = 'ISDA Determinations Committee (DC) Determination Date');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `estimated_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Estimated Credit Loss Amount');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `estimated_loss_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `event_date` SET TAGS ('dbx_business_glossary_term' = 'Credit Event Occurrence Date');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `event_identifier` SET TAGS ('dbx_business_glossary_term' = 'Credit Event Business Identifier');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `event_status` SET TAGS ('dbx_business_glossary_term' = 'Credit Event Status');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `event_status` SET TAGS ('dbx_value_regex' = 'potential|confirmed|rejected|settled|disputed');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `event_type` SET TAGS ('dbx_business_glossary_term' = 'Credit Event Type');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `event_type` SET TAGS ('dbx_value_regex' = 'bankruptcy|failure_to_pay|restructuring|obligation_acceleration|repudiation_moratorium|governmental_intervention');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `exposure_at_default` SET TAGS ('dbx_business_glossary_term' = 'Exposure at Default (EAD)');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `exposure_at_default` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `exposure_currency` SET TAGS ('dbx_business_glossary_term' = 'Exposure Currency Code');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `exposure_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `ic_notification_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Notification Date');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `legal_counsel_engaged` SET TAGS ('dbx_business_glossary_term' = 'Legal Counsel Engaged Flag');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `loss_currency` SET TAGS ('dbx_business_glossary_term' = 'Loss Amount Currency Code');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `loss_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `loss_given_default` SET TAGS ('dbx_business_glossary_term' = 'Loss Given Default (LGD)');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Credit Event Notes');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `public_information_source` SET TAGS ('dbx_business_glossary_term' = 'Public Information Source');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `rating_agency` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating Agency');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `rating_agency` SET TAGS ('dbx_value_regex' = 'sp|moodys|fitch|dbrs|other');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `realized_loss_amount` SET TAGS ('dbx_business_glossary_term' = 'Realized Credit Loss Amount');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `realized_loss_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `record_updated_by` SET TAGS ('dbx_business_glossary_term' = 'Record Updated By User');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `recovery_rate` SET TAGS ('dbx_business_glossary_term' = 'Recovery Rate');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `regulatory_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Required Flag');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `restructuring_type` SET TAGS ('dbx_business_glossary_term' = 'Restructuring Clause Type');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `restructuring_type` SET TAGS ('dbx_value_regex' = 'mod_r|mod_mod_r|no_restructuring|full_restructuring');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Industry Sector Classification');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `seniority` SET TAGS ('dbx_business_glossary_term' = 'Obligation Seniority Level');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `seniority` SET TAGS ('dbx_value_regex' = 'senior_secured|senior_unsecured|subordinated|junior_subordinated');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Credit Event Settlement Date');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Credit Event Settlement Method');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'cash|physical|auction');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `sovereign_flag` SET TAGS ('dbx_business_glossary_term' = 'Sovereign Credit Event Flag');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `trigger_event_description` SET TAGS ('dbx_business_glossary_term' = 'Credit Event Trigger Description');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `workout_strategy` SET TAGS ('dbx_business_glossary_term' = 'Credit Workout Strategy');
ALTER TABLE `asset_management`.`credit`.`default_event` ALTER COLUMN `workout_strategy` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` SET TAGS ('dbx_subdomain' = 'benchmark_reference');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `sofr_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Secured Overnight Financing Rate (SOFR) Rate ID');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `benchmark_status` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Status');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `benchmark_status` SET TAGS ('dbx_value_regex' = 'active|discontinued|under_review');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `business_day_convention` SET TAGS ('dbx_business_glossary_term' = 'Business Day Convention');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `business_day_convention` SET TAGS ('dbx_value_regex' = 'following|modified_following|preceding');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `calendar` SET TAGS ('dbx_business_glossary_term' = 'Business Day Calendar');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `calendar` SET TAGS ('dbx_value_regex' = 'us_government_securities|us_federal_reserve|nyse|london');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `compounding_method` SET TAGS ('dbx_business_glossary_term' = 'Compounding Method');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `compounding_method` SET TAGS ('dbx_value_regex' = 'simple|compound_in_arrears|compound_in_advance');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `data_quality_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Flag');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_business_glossary_term' = 'Day Count Convention');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_value_regex' = 'actual_360|actual_365|30_360');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `fallback_rate_flag` SET TAGS ('dbx_business_glossary_term' = 'Fallback Rate Flag');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `index_value` SET TAGS ('dbx_business_glossary_term' = 'SOFR (Secured Overnight Financing Rate) Index Value');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `percentile_1` SET TAGS ('dbx_business_glossary_term' = 'First Percentile Rate');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `percentile_25` SET TAGS ('dbx_business_glossary_term' = 'Twenty-Fifth Percentile Rate');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `percentile_75` SET TAGS ('dbx_business_glossary_term' = 'Seventy-Fifth Percentile Rate');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `percentile_99` SET TAGS ('dbx_business_glossary_term' = 'Ninety-Ninth Percentile Rate');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `publication_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Publication Timestamp');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Rate in Basis Points (bps)');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `rate_type` SET TAGS ('dbx_business_glossary_term' = 'SOFR (Secured Overnight Financing Rate) Rate Type');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `rate_value` SET TAGS ('dbx_business_glossary_term' = 'Rate Value');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `revision_flag` SET TAGS ('dbx_business_glossary_term' = 'Revision Flag');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `revision_reason` SET TAGS ('dbx_business_glossary_term' = 'Revision Reason');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `revision_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Revision Timestamp');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `source` SET TAGS ('dbx_value_regex' = 'federal_reserve|cme|bloomberg|refinitiv');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `spread_to_fed_funds` SET TAGS ('dbx_business_glossary_term' = 'Spread to Federal Funds Rate');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `spread_to_ois` SET TAGS ('dbx_business_glossary_term' = 'Spread to Overnight Index Swap (OIS)');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `tenor_days` SET TAGS ('dbx_business_glossary_term' = 'Tenor in Days');
ALTER TABLE `asset_management`.`credit`.`sofr_rate` ALTER COLUMN `volume_billions_usd` SET TAGS ('dbx_business_glossary_term' = 'Transaction Volume in Billions United States Dollars (USD)');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` SET TAGS ('dbx_subdomain' = 'benchmark_reference');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `credit_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Mandate Identifier (ID)');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `benchmark_index_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `approval_authority` SET TAGS ('dbx_business_glossary_term' = 'Approval Authority');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `asset_class_scope` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Scope');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `credit_quality_minimum` SET TAGS ('dbx_business_glossary_term' = 'Credit Quality Minimum');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `derivatives_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Derivatives Allowed Flag');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `document_reference` SET TAGS ('dbx_business_glossary_term' = 'Mandate Document Reference');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `duration_maximum_years` SET TAGS ('dbx_business_glossary_term' = 'Duration Maximum (Years)');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `duration_minimum_years` SET TAGS ('dbx_business_glossary_term' = 'Duration Minimum (Years)');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `duration_target_years` SET TAGS ('dbx_business_glossary_term' = 'Duration Target (Years)');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `esg_exclusion_list` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Exclusion List');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `esg_integration_level` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Level');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `esg_integration_level` SET TAGS ('dbx_value_regex' = 'none|basic|integrated|thematic|impact');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `geographic_concentration_limit_pct` SET TAGS ('dbx_business_glossary_term' = 'Geographic Concentration Limit Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `hy_allocation_maximum_pct` SET TAGS ('dbx_business_glossary_term' = 'High Yield (HY) Allocation Maximum Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `hy_allocation_minimum_pct` SET TAGS ('dbx_business_glossary_term' = 'High Yield (HY) Allocation Minimum Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `ig_allocation_maximum_pct` SET TAGS ('dbx_business_glossary_term' = 'Investment Grade (IG) Allocation Maximum Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `ig_allocation_minimum_pct` SET TAGS ('dbx_business_glossary_term' = 'Investment Grade (IG) Allocation Minimum Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Inception Date');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `leverage_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Leverage Allowed Flag');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `leverage_maximum_ratio` SET TAGS ('dbx_business_glossary_term' = 'Leverage Maximum Ratio');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `liquidity_requirement_days` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Requirement (Days)');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `liquidity_threshold_pct` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Threshold Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `mandate_code` SET TAGS ('dbx_business_glossary_term' = 'Mandate Code');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `mandate_name` SET TAGS ('dbx_business_glossary_term' = 'Mandate Name');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `mandate_status` SET TAGS ('dbx_business_glossary_term' = 'Mandate Status');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `mandate_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending_approval|closed|under_review');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `mandate_type` SET TAGS ('dbx_business_glossary_term' = 'Mandate Type');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `mandate_type` SET TAGS ('dbx_value_regex' = 'discretionary|advisory|segregated|pooled|overlay|tactical');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `maximum_allocation_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Allocation Amount');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `minimum_allocation_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Allocation Amount');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `performance_target_return_pct` SET TAGS ('dbx_business_glossary_term' = 'Performance Target Return Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `performance_target_type` SET TAGS ('dbx_business_glossary_term' = 'Performance Target Type');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `performance_target_type` SET TAGS ('dbx_value_regex' = 'absolute|relative_to_benchmark|relative_to_liability');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `portfolio_manager_name` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Manager Name');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `private_credit_allocation_maximum_pct` SET TAGS ('dbx_business_glossary_term' = 'Private Credit Allocation Maximum Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Frequency');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|threshold_based|discretionary');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `rebalancing_threshold_pct` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Threshold Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|ad_hoc');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `sector_concentration_limit_pct` SET TAGS ('dbx_business_glossary_term' = 'Sector Concentration Limit Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `single_issuer_limit_pct` SET TAGS ('dbx_business_glossary_term' = 'Single Issuer Limit Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `sovereign_allocation_maximum_pct` SET TAGS ('dbx_business_glossary_term' = 'Sovereign Allocation Maximum Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `structured_products_allocation_maximum_pct` SET TAGS ('dbx_business_glossary_term' = 'Structured Products Allocation Maximum Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `target_allocation_amount` SET TAGS ('dbx_business_glossary_term' = 'Target Allocation Amount');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `tracking_error_limit_pct` SET TAGS ('dbx_business_glossary_term' = 'Tracking Error Limit Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `var_confidence_level_pct` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Confidence Level Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `var_limit_pct` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Limit Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_mandate` ALTER COLUMN `var_time_horizon_days` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR) Time Horizon (Days)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` SET TAGS ('dbx_subdomain' = 'risk_analytics');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `spread_analytics_id` SET TAGS ('dbx_business_glossary_term' = 'Spread Analytics ID (SPREAD_ANALYTICS_ID)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `fixed_income_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security ID (SEC_ID)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID (PORTFOLIO_ID)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `event_source` SET TAGS ('dbx_business_glossary_term' = 'Event Source (EVT_SRC)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `event_source` SET TAGS ('dbx_value_regex' = 'Bloomberg|Aladdin|SimCorp');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `event_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Event Timestamp (EVT_TS)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `event_type` SET TAGS ('dbx_business_glossary_term' = 'Event Type (EVT_TYPE)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `event_type` SET TAGS ('dbx_value_regex' = 'daily_snapshot|recalculation|adjustment');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_accrued_interest` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest (AI)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_asset_swap_spread` SET TAGS ('dbx_business_glossary_term' = 'Asset Swap Spread (ASW)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_callability_flag` SET TAGS ('dbx_business_glossary_term' = 'Callability Flag (CALL_FLG)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_convexity` SET TAGS ('dbx_business_glossary_term' = 'Convexity (CONV)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_country_of_risk` SET TAGS ('dbx_business_glossary_term' = 'Country of Risk (CR_RISK)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_country_of_risk` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_coupon_frequency` SET TAGS ('dbx_business_glossary_term' = 'Security Coupon Frequency (COUPON_FREQ)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_coupon_frequency` SET TAGS ('dbx_value_regex' = 'annual|semiannual|quarterly|monthly|daily');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_coupon_rate` SET TAGS ('dbx_business_glossary_term' = 'Security Coupon Rate (COUPON_R)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_credit_rating_fitch` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating (Fitch) (CR_FITCH)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_credit_rating_moody` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating (Moodys) (CR_MOODY)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_credit_rating_sp` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating (S&P) (CR_SP)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_currency` SET TAGS ('dbx_business_glossary_term' = 'Security Currency (CURR)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_current_yield` SET TAGS ('dbx_business_glossary_term' = 'Current Yield (CURR_YLD)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_cusip` SET TAGS ('dbx_business_glossary_term' = 'Security CUSIP (CUSIP)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_cusip` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{9}$');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_default_flag` SET TAGS ('dbx_business_glossary_term' = 'Default Flag (DEF_FLG)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_duration` SET TAGS ('dbx_business_glossary_term' = 'Macaulay Duration (DUR)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_dv01` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of 01 (DV01)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_esg_rating` SET TAGS ('dbx_business_glossary_term' = 'ESG Rating (ESG_R)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_face_value` SET TAGS ('dbx_business_glossary_term' = 'Security Face Value (FACE_VAL)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_g_spread` SET TAGS ('dbx_business_glossary_term' = 'G-Spread (G_SP)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_green_bond_flag` SET TAGS ('dbx_business_glossary_term' = 'Green Bond Flag (GB_FLG)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_i_spread` SET TAGS ('dbx_business_glossary_term' = 'I-Spread (I_SP)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_isin` SET TAGS ('dbx_business_glossary_term' = 'Security ISIN (ISIN)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[0-9A-Z]{9}[0-9]$');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_issue_date` SET TAGS ('dbx_business_glossary_term' = 'Security Issue Date (ISSUE_DT)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{18}$');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_liquidity_classification` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Classification (LIQ_CLASS)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_liquidity_classification` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_market_price` SET TAGS ('dbx_business_glossary_term' = 'Market Price (MP)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_market_value` SET TAGS ('dbx_business_glossary_term' = 'Market Value (MV)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Security Maturity Date (MAT_DT)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_modified_duration` SET TAGS ('dbx_business_glossary_term' = 'Modified Duration (MOD_DUR)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_option_adjusted_spread` SET TAGS ('dbx_business_glossary_term' = 'Option-Adjusted Spread (OAS)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_reference_rate` SET TAGS ('dbx_business_glossary_term' = 'Reference Rate (REF_R)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_sector` SET TAGS ('dbx_business_glossary_term' = 'Sector (SECTOR)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_sector` SET TAGS ('dbx_value_regex' = 'equity|fixed_income|real_estate|credit');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_sedol` SET TAGS ('dbx_business_glossary_term' = 'Security SEDOL (SEDOL)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_spread_over_reference` SET TAGS ('dbx_business_glossary_term' = 'Spread Over Reference (SPREAD_REF)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_subordination_level` SET TAGS ('dbx_business_glossary_term' = 'Subordination Level (SUB_LEVEL)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_subordination_level` SET TAGS ('dbx_value_regex' = 'senior|subordinated|junior');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_type` SET TAGS ('dbx_business_glossary_term' = 'Security Type (SEC_TYPE)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_type` SET TAGS ('dbx_value_regex' = 'bond|note|bill|preferred|convertible|structured');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_yield_to_call` SET TAGS ('dbx_business_glossary_term' = 'Yield to Call (YTC)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_yield_to_maturity` SET TAGS ('dbx_business_glossary_term' = 'Yield to Maturity (YTM)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_yield_to_worst` SET TAGS ('dbx_business_glossary_term' = 'Yield to Worst (YTW)');
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ALTER COLUMN `security_z_spread` SET TAGS ('dbx_business_glossary_term' = 'Z-Spread (Z_SP)');
ALTER TABLE `asset_management`.`credit`.`credit_allocation` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`credit`.`credit_allocation` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`credit_allocation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`credit_allocation` SET TAGS ('dbx_subdomain' = 'fixed_income');
ALTER TABLE `asset_management`.`credit`.`credit_allocation` SET TAGS ('dbx_association_edges' = 'credit.credit_position,collateral.collateral_position');
ALTER TABLE `asset_management`.`credit`.`credit_allocation` ALTER COLUMN `credit_position_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Position Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`credit_allocation` ALTER COLUMN `credit_allocation_status` SET TAGS ('dbx_business_glossary_term' = 'Allocation Status');
ALTER TABLE `asset_management`.`credit`.`credit_allocation` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Allocation Effective Date');
ALTER TABLE `asset_management`.`credit`.`credit_allocation` ALTER COLUMN `percentage` SET TAGS ('dbx_business_glossary_term' = 'Allocation Percentage');
ALTER TABLE `asset_management`.`credit`.`credit_allocation` ALTER COLUMN `value` SET TAGS ('dbx_business_glossary_term' = 'Allocated Collateral Value');
ALTER TABLE `asset_management`.`credit`.`amortization_schedule` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`credit`.`amortization_schedule` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`amortization_schedule` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`amortization_schedule` SET TAGS ('dbx_subdomain' = 'private_credit');
ALTER TABLE `asset_management`.`credit`.`amortization_schedule` ALTER COLUMN `amortization_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Amortization Schedule Identifier');
ALTER TABLE `asset_management`.`credit`.`amortization_schedule` ALTER COLUMN `private_credit_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Private Credit Facility Id (Foreign Key)');
ALTER TABLE `asset_management`.`credit`.`private_credit_facility` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`credit`.`private_credit_facility` SET TAGS ('dbx_domain' = 'credit');
ALTER TABLE `asset_management`.`credit`.`private_credit_facility` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`credit`.`private_credit_facility` SET TAGS ('dbx_subdomain' = 'private_credit');
ALTER TABLE `asset_management`.`credit`.`private_credit_facility` ALTER COLUMN `private_credit_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Private Credit Facility Identifier');
