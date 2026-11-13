-- Schema for Domain: trade | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:29

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`trade` COMMENT 'Domain for trade execution and settlement operations across all liquid asset classes—equities, fixed income, FX, and OTC derivatives. Owns order management (OMS/EMS via Charles River and Bloomberg AIM), trade blotter, execution details, T+2 settlement';
ALTER SCHEMA `asset_management`.`trade` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `asset_management`.`trade` SET TAGS ('dbx_domain' = 'trade');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`trade`.`order` (
    `order_id` BIGINT COMMENT 'Unique system identifier for the investment order record. Primary key for the order entity.',
    `broker_id` BIGINT COMMENT 'Reference to the external broker or dealer to whom the order was routed for execution. Links to counterparty entity.',
    `custodian_id` BIGINT COMMENT 'Foreign key linking to trade.custodian. Business justification: Orders specify which custodian will hold the securities. The existing custodian_code (BIGINT) appears to be an unlinked FK.',
    `employee_id` BIGINT COMMENT 'Reference to the portfolio manager or investment professional who originated the order. Links to employee or user entity.',
    `esg_policy_id` BIGINT COMMENT 'Foreign key linking to esg.policy. Business justification: Orders must reference governing ESG policy for compliance audit trail. Pension funds track which responsible investment policy applies to each order for breach detection, regulatory reporting',
    `exclusion_list_id` BIGINT COMMENT 'Foreign key linking to esg.exclusion_list. Business justification: Pre-trade compliance workflow: pension fund orders must be validated against ESG exclusion lists before execution.',
    `instrument_id` BIGINT COMMENT 'Reference to the security master record representing the instrument being traded. Links to security entity for ISIN, CUSIP, SEDOL, and pricing details.',
    `natural_resource_asset_id` BIGINT COMMENT 'Foreign key linking to naturalresource.resource_asset. Business justification: Trade order for a natural resource asset requires linking to the asset for trade reporting and regulatory compliance.',
    `opportunity_id` BIGINT COMMENT 'Foreign key linking to deal.opportunity. Business justification: Each trade order must be associated with the deal it executes; the pension fund’s trade execution reports and risk dashboards rely on this link.',
    `order_employee_id` BIGINT COMMENT 'Reference to the portfolio manager or investment professional who originated the order. Links to employee or user entity.',
    `order_trader_employee_id` BIGINT COMMENT 'Reference to the trader assigned to execute the order. May differ from portfolio manager. Links to employee or user entity.',
    `parent_order_id` BIGINT COMMENT 'Reference to the parent order if this is a child order resulting from order splitting or algorithmic slicing. Null for top-level orders.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio for which this order is placed. Links to the portfolio master entity.',
    `security_instrument_id` BIGINT COMMENT 'Reference to the security master record representing the instrument being traded. Links to security entity for ISIN, CUSIP, SEDOL, and pricing details.',
    `trader_employee_id` BIGINT COMMENT 'Reference to the trader assigned to execute the order. May differ from portfolio manager. Links to employee or user entity.',
    `allocation_method` STRING COMMENT 'Method for allocating fills across multiple portfolios when order is placed on behalf of multiple accounts: pro-rata, priority-based, manual, or average price.. Valid values are `pro_rata|priority|manual|average_price`',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time when the order received final approval from compliance or investment committee. Null if approval not required or pending.',
    `asset_class` STRING COMMENT 'High-level classification of the security being traded: public equities, fixed income, foreign exchange, OTC derivatives, commodities, or alternative assets.',
    `average_execution_price` DECIMAL(18,6) COMMENT 'Volume-weighted average price of all fills for this order. Calculated from execution records. Null until first fill occurs.',
    `benchmark_index` STRING COMMENT 'Reference benchmark index used for performance comparison and execution quality measurement (e.g., S&P 500, MSCI World, Bloomberg Barclays Aggregate).',
    `cancellation_reason` STRING COMMENT 'Explanation for why the order was cancelled. Null if order was not cancelled. Captures user-provided reason or system-generated cause.',
    `commission_amount` DECIMAL(18,2) COMMENT 'Total brokerage commission charged for executing the order. Expressed in order currency. Null until execution occurs.',
    `commission_basis_points` DECIMAL(8,2) COMMENT 'Commission rate expressed in basis points of notional value. One basis point equals 0.01%. Used for performance attribution and TCA.',
    `completed_timestamp` TIMESTAMP COMMENT 'Date and time when the order reached a terminal state (filled, cancelled, rejected, or expired). Null for active orders.',
    `compliance_approved_flag` BOOLEAN COMMENT 'Boolean indicator whether the order has passed pre-trade compliance checks (position limits, restricted lists, concentration rules). True if approved, False otherwise.',
    `compliance_override_reason` STRING COMMENT 'Explanation for any compliance rule override or exception granted for this order. Null if no override was required.',
    `created_timestamp` TIMESTAMP COMMENT 'System audit timestamp capturing when this order record was first inserted into the database. Distinct from order_timestamp which is the business event time.',
    `currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the order is denominated. Typically matches the trading currency of the security.. Valid values are `^[A-Z]{3}$`',
    `cusip` STRING COMMENT '9-character alphanumeric identifier for North American securities. Denormalized from security master for operational convenience.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `execution_strategy` STRING COMMENT 'Algorithmic or manual execution approach specified for the order (e.g., VWAP, TWAP, Implementation Shortfall, Direct Market Access, High Touch).',
    `execution_venue` STRING COMMENT 'Name or code of the exchange, trading platform, or OTC venue where the order is to be executed (e.g., NYSE, NASDAQ, LSE, OTC).',
    `expiry_date` DATE COMMENT 'Date on which the order automatically expires if not filled. Applicable for GTD (Good Till Date) orders. Null for Day and GTC orders.',
    `filled_quantity` DECIMAL(18,4) COMMENT 'Cumulative number of units executed to date. Updated as partial fills occur. Equals quantity when order is fully filled.',
    `instructions` STRING COMMENT 'Free-text field capturing special handling instructions, execution preferences, or notes from the portfolio manager to the trader or broker.',
    `isin` STRING COMMENT '12-character alphanumeric code uniquely identifying the security globally. Denormalized from security master for operational convenience.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `limit_price` DECIMAL(18,6) COMMENT 'Maximum price for buy orders or minimum price for sell orders. Null for market orders. Expressed in order currency.',
    `notional_value` DECIMAL(20,2) COMMENT 'Total market value of the order calculated as quantity multiplied by limit price (or market price for market orders). Expressed in order currency.',
    `number` STRING COMMENT 'Externally visible business identifier for the order, typically generated by the Order Management System (OMS). Used for operational tracking and communication with brokers.',
    `order_date` DATE COMMENT 'Business date on which the order was created by the portfolio manager. Distinct from order_timestamp which captures precise creation time.',
    `order_status` STRING COMMENT 'Current lifecycle state of the order in the order management workflow, from draft through execution to final settlement or cancellation. [ENUM-REF-CANDIDATE: draft|pending_approval|approved|submitted|partially_filled|filled|cancelled|rejected|expired — 9',
    `order_type` STRING COMMENT 'Classification of the order execution instruction: market order, limit order, stop order, algorithmic order types (VWAP, TWAP), or basket order. [ENUM-REF-CANDIDATE: market|limit|stop|stop_limit|iceberg|vwap|twap|peg|basket — 9 candidates stripped',
    `quantity` DECIMAL(18,4) COMMENT 'Total number of units (shares, bonds, contracts) requested in the order. For fixed income, may represent par value or face amount.',
    `rejection_reason` STRING COMMENT 'Explanation for why the order was rejected by broker, exchange, or internal compliance. Null if order was not rejected.',
    `remaining_quantity` DECIMAL(18,4) COMMENT 'Outstanding quantity yet to be executed. Calculated as quantity minus filled_quantity. Zero when order is complete.',
    `sedol` STRING COMMENT '7-character alphanumeric identifier for securities traded on the London Stock Exchange and other UK exchanges. Denormalized from security master.. Valid values are `^[0-9B-DF-HJ-NP-TV-Z]{6}[0-9]$`',
    `settlement_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the trade will settle. May differ from order currency if FX conversion is required.. Valid values are `^[A-Z]{3}$`',
    `settlement_date` DATE COMMENT 'Expected date for delivery versus payment (DVP) settlement. Typically T+2 for equities, T+1 for certain markets, or custom for OTC derivatives.',
    `side` STRING COMMENT 'Direction of the order: buy (long), sell, short sell, or cover (close short position).. Valid values are `buy|sell|short_sell|cover`',
    `stop_price` DECIMAL(18,6) COMMENT 'Trigger price for stop and stop-limit orders. Order becomes active when market reaches this level. Null for non-stop orders.',
    `submitted_timestamp` TIMESTAMP COMMENT 'Date and time when the order was submitted to the broker or execution venue. Null if order has not yet been submitted.',
    `ticker_symbol` STRING COMMENT 'Exchange-specific trading symbol for the security. Denormalized from security master for operational display and broker communication.',
    `time_in_force` STRING COMMENT 'Duration for which the order remains active: Day (expires end of trading day), GTC (Good Till Cancelled), IOC (Immediate or Cancel), FOK (Fill or Kill), GTD (Good Till Date), At Open, At Close.',
    `timestamp` TIMESTAMP COMMENT 'Precise date and time when the order was created in the OMS. Primary business event timestamp for order lifecycle tracking.',
    `updated_timestamp` TIMESTAMP COMMENT 'System audit timestamp capturing when this order record was last modified. Updated on every status change, fill, or attribute update.',
    CONSTRAINT pk_order PRIMARY KEY(`order_id`)
) COMMENT 'Core order management record representing an investment order originating from portfolio managers via Charles River IMS or Bloomberg AIM across all liquid asset classes (equities, fixed income, FX, OTC derivatives).';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`order_allocation` (
    `order_allocation_id` BIGINT COMMENT 'Unique identifier for the order allocation record.',
    `allocation_group_id` BIGINT COMMENT 'Grouping identifier for allocations that are part of the same allocation batch or block trade split.',
    `broker_id` BIGINT COMMENT 'Broker or executing counterparty assigned to this allocation.',
    `cash_account_id` BIGINT COMMENT 'Target account or sub-mandate receiving this allocation.',
    `clearing_house_id` BIGINT COMMENT 'Central Counterparty (CCP) or clearing house used for this allocation, applicable for exchange-traded and cleared Over-The-Counter (OTC) derivatives.',
    `custodian_id` BIGINT COMMENT 'Foreign key linking to trade.custodian. Business justification: Order allocations specify which custodian will hold the allocated securities. The existing custodian_code (BIGINT) appears to be an unlinked FK.',
    `employee_id` BIGINT COMMENT 'Internal trader or portfolio manager who authorized or executed the allocation instruction.',
    `order_id` BIGINT COMMENT 'Reference to the parent order being allocated across portfolios or accounts.',
    `portfolio_id` BIGINT COMMENT 'Target portfolio receiving this allocation of the parent order.',
    `standing_settlement_instruction_id` BIGINT COMMENT 'Reference to the Standard Settlement Instructions (SSI) used for Delivery Versus Payment (DVP) settlement of this allocation.',
    `trader_employee_id` BIGINT COMMENT 'Internal trader or portfolio manager who authorized or executed the allocation instruction.',
    `accrued_interest` DECIMAL(18,2) COMMENT 'Accrued interest amount for fixed income allocations, calculated from the last coupon date to the settlement date.',
    `allocated_notional` DECIMAL(20,2) COMMENT 'Notional value of the allocation in the trade currency, calculated as allocated quantity multiplied by execution price.',
    `allocated_quantity` DECIMAL(18,4) COMMENT 'Number of units or shares allocated to this portfolio or account from the parent order.',
    `allocation_instruction_type` STRING COMMENT 'Method by which the allocation was determined: automatic system allocation, manual trader instruction, model-driven, or pro-rata distribution.. Valid values are `automatic|manual|model_driven|pro_rata`',
    `allocation_number` STRING COMMENT 'Business identifier for the allocation, typically generated by the Order Management System (OMS).',
    `allocation_percentage` DECIMAL(5,2) COMMENT 'Percentage of the parent order allocated to this portfolio or account, expressed as a decimal (e.g., 25.50 for 25.5%).',
    `allocation_reason` STRING COMMENT 'Business rationale or comment explaining the allocation decision, particularly for manual or non-standard allocations.',
    `allocation_status` STRING COMMENT 'Current lifecycle status of the allocation in the settlement workflow.. Valid values are `pending|confirmed|rejected|cancelled|settled|partially_settled`',
    `allocation_timestamp` TIMESTAMP COMMENT 'Date and time when the allocation was created or confirmed by the Order Management System (OMS).',
    `allocation_type` STRING COMMENT 'Classification of the allocation method or instruction type per FIX AllocType field.. Valid values are `calculated|preliminary|ready_to_book|warehouse_instruction|request_to_intermediary`',
    `allocation_version` BIGINT COMMENT 'Version number of the allocation record, incremented when amendments or corrections are made post-confirmation.',
    `average_price` DECIMAL(18,6) COMMENT 'Average price at which the allocated quantity was executed, used for settlement and performance attribution.',
    `commission_amount` DECIMAL(18,2) COMMENT 'Brokerage commission charged for this allocation, expressed in the trade currency.',
    `confirmation_timestamp` TIMESTAMP COMMENT 'Date and time when the allocation was confirmed by the broker or counterparty.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this allocation record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the allocated notional and price.. Valid values are `^[A-Z]{3}$`',
    `fx_rate` DECIMAL(12,6) COMMENT 'Foreign Exchange (FX) rate applied when converting trade currency to settlement currency, if applicable.',
    `modified_by` STRING COMMENT 'User identifier or system process that last modified this allocation record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this allocation record was last modified or updated.',
    `net_amount` DECIMAL(20,2) COMMENT 'Net amount payable or receivable after deducting commissions, fees, and taxes from the gross settlement amount.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this allocation requires regulatory reporting under MiFID II, EMIR, or other jurisdictional requirements.',
    `rejection_reason` STRING COMMENT 'Explanation provided when an allocation is rejected by the broker, custodian, or compliance system.',
    `settlement_amount` DECIMAL(20,2) COMMENT 'Total amount due for settlement in the settlement currency, including principal and any adjustments.',
    `settlement_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which settlement will occur, may differ from trade currency due to Foreign Exchange (FX) conversion.. Valid values are `^[A-Z]{3}$`',
    `settlement_date` DATE COMMENT 'Expected settlement date for this allocation, typically Trade Date plus two business days (T+2) for equities.',
    `settlement_method` STRING COMMENT 'Settlement mechanism: Delivery Versus Payment (DVP), Free Of Payment (FOP), Delivery Against Payment (DAP), or Receive Versus Payment (RVP).. Valid values are `DVP|FOP|DAP|RVP`',
    `settlement_status` STRING COMMENT 'Current status of the settlement process for this allocation.. Valid values are `pending|settled|failed|partially_settled`',
    `tax_amount` DECIMAL(18,2) COMMENT 'Total tax amount applicable to this allocation, including transaction taxes, stamp duty, or withholding tax.',
    `trade_date` DATE COMMENT 'Date on which the parent order was executed, used as the reference for settlement date calculation.',
    `created_by` STRING COMMENT 'User identifier or system process that created this allocation record.',
    CONSTRAINT pk_order_allocation PRIMARY KEY(`order_allocation_id`)
) COMMENT 'Broker and account allocation record that splits a parent order across multiple portfolios, accounts, or sub-mandates. Captures the allocation quantity, allocated notional, target portfolio, allocation percentage, allocation status, and the broker or';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`execution` (
    `execution_id` BIGINT COMMENT 'Unique identifier for the trade execution event. Primary key.',
    `broker_id` BIGINT COMMENT 'Reference to the broker or counterparty that executed the trade.',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: OTC executions require counterparty identification for exposure calculation and collateral management.',
    `execution_venue_id` BIGINT COMMENT 'Foreign key linking to trade.execution_venue. Business justification: Trade executions occur at specific execution venues. The existing venue and venue_mic_code are string identifiers but there is no FK to the execution_venue master table.',
    `instrument_id` BIGINT COMMENT 'Reference to the financial instrument that was executed.',
    `natural_resource_asset_id` BIGINT COMMENT 'Foreign key linking to naturalresource.resource_asset. Business justification: Execution records must reference the natural resource asset for accurate trade reporting and settlement reconciliation.',
    `order_id` BIGINT COMMENT 'Reference to the parent order that generated this execution.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio to which this execution is allocated.',
    `strategy_id` BIGINT COMMENT 'Reference to the investment strategy driving this execution.',
    `accrued_interest` DECIMAL(18,2) COMMENT 'Interest accrued on fixed income instruments from last coupon date to execution date.',
    `algorithm` STRING COMMENT 'Name or identifier of the algorithmic trading strategy used for execution.',
    `asset_class` STRING COMMENT 'High-level classification of the asset class for the executed instrument.. Valid values are `equity|fixed_income|fx|derivative|commodity|alternative`',
    `average_price_flag` BOOLEAN COMMENT 'Indicates whether this execution is part of an average price order.',
    `benchmark_price` DECIMAL(18,6) COMMENT 'Reference benchmark price used for execution quality analysis.',
    `bloomberg_ticker` STRING COMMENT 'Bloomberg ticker symbol for the executed instrument.',
    `capacity` STRING COMMENT 'Capacity in which the broker executed the trade.. Valid values are `principal|agent|riskless_principal|cross_as_agent`',
    `clearing_house` STRING COMMENT 'Name or identifier of the central counterparty clearing house.',
    `commission_amount` DECIMAL(18,2) COMMENT 'Broker commission charged for this execution.',
    `commission_currency` STRING COMMENT 'Three-letter ISO currency code for the commission amount.. Valid values are `^[A-Z]{3}$`',
    `confirmation_received_timestamp` TIMESTAMP COMMENT 'Date and time when trade confirmation was received from the broker or venue.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this execution record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code for the execution value and price.. Valid values are `^[A-Z]{3}$`',
    `cusip` STRING COMMENT 'Nine-character alphanumeric code identifying North American securities.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `dvp_indicator` BOOLEAN COMMENT 'Indicates whether the execution will settle on a delivery versus payment basis.',
    `executed_price` DECIMAL(18,6) COMMENT 'Price per unit at which the execution occurred.',
    `executed_quantity` DECIMAL(18,4) COMMENT 'Number of units or shares executed in this fill event.',
    `executing_trader` STRING COMMENT 'Name or identifier of the trader who executed the order.',
    `execution_status` STRING COMMENT 'Current lifecycle status of the execution event.. Valid values are `filled|partial_fill|cancelled|rejected|pending_confirmation|confirmed`',
    `execution_type` STRING COMMENT 'Classification of the execution event type per FIX protocol standards. [ENUM-REF-CANDIDATE: new|partial_fill|fill|cancelled|replaced|pending_cancel|rejected — 7 candidates stripped; promote to reference product]',
    `isin` STRING COMMENT 'Twelve-character alphanumeric code uniquely identifying the security.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `last_market_flag` BOOLEAN COMMENT 'Indicates whether this is the final execution for the parent order.',
    `liquidity_indicator` STRING COMMENT 'Indicates whether the execution added or removed liquidity from the market.. Valid values are `added|removed|routed`',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this execution record was last modified.',
    `net_settlement_amount` DECIMAL(20,2) COMMENT 'Net amount payable or receivable after commissions and fees.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding the execution event.',
    `price_deviation_bps` DECIMAL(10,2) COMMENT 'Deviation of executed price from benchmark price expressed in basis points.',
    `reference` STRING COMMENT 'External execution reference number assigned by the execution venue or broker.',
    `sedol` STRING COMMENT 'Seven-character alphanumeric code identifying securities traded on the London Stock Exchange.. Valid values are `^[0-9A-Z]{7}$`',
    `settlement_cycle` STRING COMMENT 'Number of business days between trade date and settlement date.. Valid values are `T+0|T+1|T+2|T+3`',
    `settlement_date` DATE COMMENT 'Expected date when the trade will settle and ownership transfers.',
    `side` STRING COMMENT 'Indicates whether the execution was a buy or sell transaction.. Valid values are `buy|sell|short_sell`',
    `timestamp` TIMESTAMP COMMENT 'Precise date and time when the trade was executed in the market.',
    `trade_reporting_indicator` STRING COMMENT 'Status of regulatory trade reporting for this execution.. Valid values are `reported|unreported|pending`',
    `value` DECIMAL(20,2) COMMENT 'Total gross value of the execution calculated as executed quantity multiplied by executed price.',
    `venue` STRING COMMENT 'Name or code of the exchange, ECN, or trading venue where the execution occurred.',
    `venue_mic_code` STRING COMMENT 'ISO 10383 four-character Market Identifier Code for the execution venue.. Valid values are `^[A-Z]{4}$`',
    CONSTRAINT pk_execution PRIMARY KEY(`execution_id`)
) COMMENT 'Trade execution record capturing the actual fill details from the market or execution venue. Represents a single execution event against a parent order, including executed price, executed quantity, execution timestamp, execution venue (exchange, ECN';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`blotter` (
    `blotter_id` BIGINT COMMENT 'Unique identifier for the trade blotter record. Primary key for the consolidated intraday trade register.',
    `performance_benchmark_id` BIGINT COMMENT 'Identifier of the performance benchmark against which this trade will be measured. Used for performance attribution analysis.',
    `broker_id` BIGINT COMMENT 'Identifier of the executing broker or dealer who facilitated the trade. Links to counterparty master data.',
    `counterparty_id` BIGINT COMMENT 'Identifier of the trade counterparty. For exchange-traded securities, may be the central counterparty (CCP); for OTC, the bilateral counterparty.',
    `custodian_id` BIGINT COMMENT 'Identifier of the custodian bank holding the securities. Links to Standard Settlement Instructions (SSI).',
    `employee_id` BIGINT COMMENT 'Identifier of the internal portfolio manager or trader who initiated the order. Used for performance attribution and compliance monitoring.',
    `execution_id` BIGINT COMMENT 'Unique business identifier for the executed trade. Externally-known trade reference number assigned by the Order Management System (OMS).',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Co-investment trade attribution: When pension fund executes co-investments alongside GPs, blotter must track originating manager for performance attribution, co-invest utilization',
    `instrument_id` BIGINT COMMENT 'Internal identifier of the security instrument traded. Links to master security reference data.',
    `natural_resource_asset_id` BIGINT COMMENT 'Foreign key linking to naturalresource.resource_asset. Business justification: Blotter entries need the asset reference for settlement processing and regulatory audit trails.',
    `order_id` BIGINT COMMENT 'Reference to the parent order that generated this trade execution. Links trade to originating investment decision.',
    `portfolio_id` BIGINT COMMENT 'Identifier of the investment portfolio to which this trade belongs. Links trade to asset allocation strategy.',
    `strategy_id` BIGINT COMMENT 'Identifier of the investment strategy or mandate under which the trade was executed. Links to Strategic Asset Allocation (SAA) or Tactical Asset Allocation (TAA).',
    `trader_employee_id` BIGINT COMMENT 'Identifier of the internal portfolio manager or trader who initiated the order. Used for performance attribution and compliance monitoring.',
    `accrued_interest` DECIMAL(18,2) COMMENT 'Interest accrued on fixed income securities from last coupon payment to trade date. Paid by buyer to seller.',
    `allocation_status` STRING COMMENT 'Status of trade allocation to underlying portfolios. Block trades may be allocated across multiple portfolios.. Valid values are `pending|allocated|partially_allocated|rejected`',
    `asset_class` STRING COMMENT 'High-level classification of the traded instrument type. Determines settlement and valuation treatment.. Valid values are `public_equity|fixed_income|fx|otc_derivative|private_equity|real_estate`',
    `broker_lei` STRING COMMENT 'ISO 17442 standard 20-character alphanumeric code uniquely identifying the broker legal entity globally.. Valid values are `^[A-Z0-9]{20}$`',
    `capacity` STRING COMMENT 'Capacity in which the broker executed the trade. Principal means broker traded from own inventory; agency means broker acted as agent.. Valid values are `principal|agency|riskless_principal`',
    `commission` DECIMAL(18,2) COMMENT 'Brokerage commission charged for executing the trade. Paid to the executing broker.',
    `compliance_rule_breached` STRING COMMENT 'Identifier of the compliance rule that was breached, if any. Used for exception reporting and audit trail.',
    `compliance_status` STRING COMMENT 'Pre-trade and post-trade compliance check result. Indicates whether trade complies with investment guidelines and regulatory limits.. Valid values are `approved|pending_review|breached|override_approved`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the blotter record was first created in the Investment Book of Record (IBOR). Audit trail for data lineage.',
    `cusip` STRING COMMENT '9-character alphanumeric code identifying North American securities. Used for US and national instruments.. Valid values are `^[0-9]{3}[0-9A-Z]{5}[0-9]$`',
    `custodian_account` STRING COMMENT 'Account number at the custodian bank where securities will be settled. Part of Standard Settlement Instructions (SSI).',
    `execution_type` STRING COMMENT 'Method by which the trade was executed. Indicates the execution channel and strategy used.. Valid values are `electronic|voice|algorithmic|block|crossing`',
    `execution_venue` STRING COMMENT 'Market or trading venue where the trade was executed. Examples: NYSE, NASDAQ, LSE, OTC, internal crossing network.',
    `fees` DECIMAL(18,2) COMMENT 'Additional fees associated with the trade execution. Includes exchange fees, clearing fees, and regulatory fees.',
    `fx_rate` DECIMAL(18,8) COMMENT 'Exchange rate applied for cross-currency trades. Converts price currency to settlement currency.',
    `gross_amount` DECIMAL(18,2) COMMENT 'Total trade value before fees, commissions, and taxes. Calculated as quantity multiplied by price.',
    `instrument_type` STRING COMMENT 'Detailed classification of the security instrument. Examples: common stock, corporate bond, government bond, FX spot, FX forward, interest rate swap, credit default swap.',
    `isin` STRING COMMENT 'ISO 6166 standard 12-character alphanumeric code uniquely identifying the security globally.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `mic_code` STRING COMMENT 'ISO 10383 standard 4-character code identifying the exchange or trading venue.. Valid values are `^[A-Z]{4}$`',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the blotter record was last updated. Tracks amendments, corrections, and status changes.',
    `net_amount` DECIMAL(18,2) COMMENT 'Total settlement amount after all fees, commissions, and taxes. Amount that will be debited or credited to the portfolio cash account.',
    `price` DECIMAL(18,6) COMMENT 'Execution price per unit of the security. For bonds, may be expressed as percentage of par; for equities, price per share.',
    `price_currency` STRING COMMENT 'ISO 4217 three-letter currency code in which the trade price is denominated.. Valid values are `^[A-Z]{3}$`',
    `quantity` DECIMAL(18,4) COMMENT 'Number of units or nominal amount of the security traded. For bonds, represents face value; for equities, represents share count.',
    `sedol` STRING COMMENT '7-character alphanumeric code identifying securities traded on the London Stock Exchange and other UK exchanges.. Valid values are `^[0-9BCDFGHJKLMNPQRSTVWXYZ]{7}$`',
    `settlement_currency` STRING COMMENT 'ISO 4217 three-letter currency code in which the trade will settle. May differ from price currency for cross-currency trades.. Valid values are `^[A-Z]{3}$`',
    `settlement_date` DATE COMMENT 'Date on which the trade will settle and cash and securities will be exchanged. Typically T+2 for equities.',
    `settlement_method` STRING COMMENT 'Settlement instruction type. DVP (Delivery Versus Payment) is standard for most trades; RVP (Receive Versus Payment) for purchases; FOP (Free Of Payment) for transfers.. Valid values are `dvp|rvp|fop`',
    `side` STRING COMMENT 'Direction of the trade from the fund perspective. Buy increases position, sell decreases position.. Valid values are `buy|sell|short_sell`',
    `tax_amount` DECIMAL(18,2) COMMENT 'Transaction taxes levied on the trade. Includes stamp duty, financial transaction tax, and other applicable taxes.',
    `ticker` STRING COMMENT 'Exchange-specific ticker symbol for the traded security. Human-readable market identifier.',
    `trade_confirmation_number` STRING COMMENT 'Confirmation reference number provided by the broker or counterparty. Used for trade matching and reconciliation.',
    `trade_date` DATE COMMENT 'Date on which the trade was executed in the market. T in T+2 settlement convention.',
    `trade_notes` STRING COMMENT 'Free-text notes or comments about the trade. Captures trader rationale, special instructions, or execution commentary.',
    `trade_status` STRING COMMENT 'Current lifecycle state of the trade in the settlement workflow. Tracks progression from execution to final settlement.. Valid values are `new|allocated|confirmed|settled|cancelled|failed`',
    `trade_timestamp` TIMESTAMP COMMENT 'Precise date and time when the trade was executed. Includes timezone for global trading operations.',
    CONSTRAINT pk_blotter PRIMARY KEY(`blotter_id`)
) COMMENT 'Consolidated intraday trade blotter record aggregating all executed trades across asset classes for a given trading day. Serves as the authoritative daily trade register for the investment book of record (IBOR).';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`settlement_instruction` (
    `settlement_instruction_id` BIGINT COMMENT 'Unique identifier for the settlement instruction record.',
    `blotter_id` BIGINT COMMENT 'Reference to the trade that this settlement instruction governs.',
    `execution_id` BIGINT COMMENT 'Reference to the trade that this settlement instruction governs.',
    `standing_settlement_instruction_id` BIGINT COMMENT 'Reference to the counterpartys standard settlement instructions, containing their delivery and payment details.',
    `accrued_interest` DECIMAL(18,2) COMMENT 'Amount of accrued interest to be settled along with the principal for fixed income securities.',
    `affirmation_status` STRING COMMENT 'Status indicating whether the institutional investor has affirmed the trade details with the broker or custodian.. Valid values are `pending|affirmed|rejected|not_required`',
    `affirmation_timestamp` TIMESTAMP COMMENT 'Date and time when the trade was affirmed by the institutional investor.',
    `cancellation_reason` STRING COMMENT 'Explanation for why the settlement instruction was cancelled, if applicable.',
    `ccp_clearing_member` STRING COMMENT 'Name of the clearing member through which the trade is cleared at the CCP.',
    `ccp_name` STRING COMMENT 'Name of the central counterparty clearing house if the trade is centrally cleared (e.g., LCH, CME Clearing).',
    `counterparty_account_number` STRING COMMENT 'The account number at the counterpartys custodian or depository where securities or cash will be delivered or received.',
    `counterparty_custodian_bic` STRING COMMENT 'ISO 9362 Bank Identifier Code (SWIFT code) of the counterpartys custodian institution.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `custodian_account_number` STRING COMMENT 'The account number at the custodian bank where the securities or cash will be delivered or received.',
    `custodian_bic` STRING COMMENT 'ISO 9362 Bank Identifier Code (SWIFT code) of the custodian institution.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `custodian_name` STRING COMMENT 'Name of the custodian bank or financial institution responsible for holding and settling the securities.',
    `depository_code` STRING COMMENT 'Standard code identifying the central securities depository or clearing system.',
    `depository_name` STRING COMMENT 'Name of the central securities depository or clearing system where the securities are held (e.g., DTC, Euroclear, Clearstream).',
    `failure_code` STRING COMMENT 'Standardized code representing the category of settlement failure.',
    `failure_reason` STRING COMMENT 'Description of the reason for settlement failure if the instruction status is failed (e.g., insufficient securities, account mismatch, counterparty rejection).',
    `instruction_generation_timestamp` TIMESTAMP COMMENT 'Date and time when the settlement instruction was generated by the order management or portfolio management system.',
    `instruction_reference` STRING COMMENT 'External reference number or identifier for the settlement instruction, used for reconciliation and communication with counterparties and custodians.',
    `instruction_sent_timestamp` TIMESTAMP COMMENT 'Date and time when the settlement instruction was transmitted to the custodian or depository.',
    `instruction_status` STRING COMMENT 'Current lifecycle status of the settlement instruction in the settlement workflow.. Valid values are `pending|matched|affirmed|settled|failed|cancelled`',
    `instruction_type` STRING COMMENT 'Indicates whether this instruction is for delivery of securities, receipt of securities, payment of cash, or receipt of cash.. Valid values are `delivery|receipt|payment|receive_payment`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when the settlement instruction record was last updated.',
    `matching_status` STRING COMMENT 'Status indicating whether the settlement instruction has been matched with the counterpartys instruction.. Valid values are `unmatched|matched|mismatched|pending_match`',
    `modified_by` STRING COMMENT 'Identifier of the user or system that last modified the settlement instruction record.',
    `net_settlement_amount` DECIMAL(18,2) COMMENT 'Net amount to be settled after accounting for accrued interest, fees, and any other adjustments.',
    `partial_settlement_allowed` BOOLEAN COMMENT 'Indicates whether partial settlement of the instruction is permitted if the full quantity is not available.',
    `place_of_settlement` STRING COMMENT 'Three-letter ISO 3166 country code indicating the jurisdiction where settlement occurs.. Valid values are `^[A-Z]{3}$`',
    `quantity` DECIMAL(18,4) COMMENT 'The number of units or nominal amount of the security to be settled.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this settlement instruction requires regulatory reporting under MiFID II, EMIR, or other jurisdictional requirements.',
    `security_identifier` STRING COMMENT 'Primary identifier for the security being settled, typically ISIN, CUSIP, or SEDOL.',
    `security_identifier_type` STRING COMMENT 'Type of security identifier used (ISIN, CUSIP, SEDOL, or TICKER).. Valid values are `ISIN|CUSIP|SEDOL|TICKER`',
    `settlement_amount` DECIMAL(18,2) COMMENT 'The total monetary amount to be settled, including principal and any accrued interest or fees, denominated in the settlement currency.',
    `settlement_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the settlement payment will be made.. Valid values are `^[A-Z]{3}$`',
    `settlement_date` DATE COMMENT 'The contractual date on which the settlement of the trade is scheduled to occur, typically T+2 for equities or as per asset class convention.',
    `settlement_fees` DECIMAL(18,2) COMMENT 'Total fees charged by custodians, depositories, or clearing systems for processing the settlement.',
    `settlement_method` STRING COMMENT 'Method governing the delivery and payment mechanics. DVP (Delivery Versus Payment) ensures simultaneous exchange of securities and cash; RVP (Receive Versus Payment) for receipt side; FOP (Free of Payment) for securities transfer without payment; DFP. Valid values are `DVP|RVP|FOP|DFP`',
    `settlement_priority` STRING COMMENT 'Priority level assigned to the settlement instruction for processing by custodians and clearing systems.. Valid values are `normal|high|urgent`',
    `settlement_timestamp` TIMESTAMP COMMENT 'Date and time when the settlement was actually completed and confirmed by the depository or custodian.',
    `settlement_type` STRING COMMENT 'Classification of the settlement cycle: regular (T+2), cash (T+0), next day (T+1), or seller option (custom date).. Valid values are `regular|cash|next_day|seller_option`',
    `trade_confirmation_reference` STRING COMMENT 'Reference number from the trade confirmation document linking this settlement instruction to the original trade.',
    `created_by` STRING COMMENT 'Identifier of the user or system that created the settlement instruction record.',
    CONSTRAINT pk_settlement_instruction PRIMARY KEY(`settlement_instruction_id`)
) COMMENT 'Settlement instruction record governing the delivery and payment mechanics for a trade. Captures settlement date (T+2 standard or contractual), settlement method (DVP, FOP, DFP), settlement currency, custodian account, depository (DTC, Euroclear';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`settlement_fail` (
    `settlement_fail_id` BIGINT COMMENT 'Unique identifier for the settlement failure event record.',
    `blotter_id` BIGINT COMMENT 'Reference to the underlying trade that failed to settle.',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: Settlement fails must be tracked by counterparty for CSDR penalty regime compliance and credit risk monitoring.',
    `execution_id` BIGINT COMMENT 'Reference to the underlying trade that failed to settle.',
    `actual_settlement_date` DATE COMMENT 'The date on which the trade ultimately settled successfully, resolving the fail.',
    `assigned_to` STRING COMMENT 'Name or identifier of the operations team member or desk responsible for resolving the settlement failure.',
    `buy_in_execution_date` DATE COMMENT 'Date on which a buy-in transaction was executed in the market to cover the failed settlement.',
    `buy_in_notice_date` DATE COMMENT 'Date on which a formal buy-in notice was issued to the failing party under CSDR mandatory buy-in rules.',
    `buy_in_risk_flag` BOOLEAN COMMENT 'Indicates whether the settlement failure has reached a threshold that triggers buy-in risk under CSDR or contractual terms.',
    `clearing_system` STRING COMMENT 'Name of the central securities depository or clearing system where the settlement failure occurred.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this settlement failure record was first created in the lakehouse.',
    `custodian_bic` STRING COMMENT 'ISO 9362 Bank Identifier Code of the custodian bank handling settlement for this trade.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `dvp_model` STRING COMMENT 'The DVP settlement model applicable to this trade as defined by the Bank for International Settlements.. Valid values are `model_1|model_2|model_3|free_of_payment`',
    `escalation_date` DATE COMMENT 'Date on which the settlement failure was escalated to a higher management or operational tier.',
    `escalation_level` STRING COMMENT 'Current escalation tier within the organization for managing and resolving the settlement failure.. Valid values are `none|operations|management|legal|executive`',
    `expected_settlement_date` DATE COMMENT 'The original contractual settlement date per the trade terms, typically Trade Date plus two (T+2).',
    `fail_amount` DECIMAL(18,2) COMMENT 'Monetary value of the securities that failed to settle, in the trade currency.',
    `fail_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the monetary value of the failed settlement.. Valid values are `^[A-Z]{3}$`',
    `fail_date` DATE COMMENT 'The contractual settlement date on which the trade failed to settle as expected.',
    `fail_detected_timestamp` TIMESTAMP COMMENT 'System timestamp when the settlement failure was first identified and recorded in the operations system.',
    `fail_duration_days` BIGINT COMMENT 'Number of business days the settlement has been outstanding since the original fail date.',
    `fail_party_type` STRING COMMENT 'Classification of the party responsible for or contributing to the settlement failure.. Valid values are `internal|counterparty|custodian|broker|ccp`',
    `fail_quantity` DECIMAL(18,4) COMMENT 'Number of units or shares that failed to settle on the contractual settlement date.',
    `fail_reason_code` STRING COMMENT 'Standardized code indicating the root cause of the settlement failure.. Valid values are `insufficient_securities|cash_shortfall|counterparty_fail|ssi_mismatch|custody_hold|regulatory_block`',
    `fail_reason_description` STRING COMMENT 'Detailed narrative explanation of the circumstances that caused the settlement failure.',
    `fail_reference_number` STRING COMMENT 'External reference number assigned by custodian or clearing system to track the settlement failure.',
    `fail_side` STRING COMMENT 'Indicates whether the failure occurred on the buy side or sell side of the transaction.. Valid values are `buy|sell`',
    `fail_status` STRING COMMENT 'Current lifecycle status of the settlement failure event.. Valid values are `open|partially_resolved|resolved|escalated|buy_in_initiated|closed`',
    `penalty_amount` DECIMAL(18,2) COMMENT 'Monetary penalty assessed under CSDR mandatory cash penalties regime for late settlement.',
    `penalty_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the settlement failure penalty amount.. Valid values are `^[A-Z]{3}$`',
    `regulatory_report_date` DATE COMMENT 'Date on which the settlement failure was reported to the relevant regulatory authority.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this settlement failure must be reported to regulatory authorities under CSDR or other regimes.',
    `resolution_action` STRING COMMENT 'Description of the corrective action taken or planned to resolve the settlement failure.',
    `revised_settlement_date` DATE COMMENT 'Updated target settlement date negotiated or projected after the initial failure.',
    `security_cusip` STRING COMMENT 'CUSIP identifier for North American securities involved in the failed settlement.. Valid values are `^[A-Z0-9]{9}$`',
    `security_isin` STRING COMMENT 'ISO 6166 International Securities Identification Number of the security that failed to settle.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `security_sedol` STRING COMMENT 'SEDOL identifier for securities traded on UK and Irish exchanges involved in the failed settlement.. Valid values are `^[A-Z0-9]{7}$`',
    `ssi_correction_date` DATE COMMENT 'Date on which corrected Standard Settlement Instructions were provided to resolve the mismatch.',
    `ssi_mismatch_flag` BOOLEAN COMMENT 'Indicates whether the failure was caused by a mismatch in Standard Settlement Instructions between counterparties.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp when this settlement failure record was last modified.',
    CONSTRAINT pk_settlement_fail PRIMARY KEY(`settlement_fail_id`)
) COMMENT 'Record of a settlement failure event where a trade did not settle on the contractual settlement date. Captures fail date, fail reason code (insufficient securities, cash shortfall, counterparty fail, SSI mismatch), fail duration in days, buy-in risk flag';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`confirmation` (
    `confirmation_id` BIGINT COMMENT 'Unique identifier for the trade confirmation record.',
    `broker_id` BIGINT COMMENT 'Reference to the broker or intermediary involved in the trade execution and confirmation process.',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: Trade confirmations are exchanged with counterparties. Linking enables confirmation matching, dispute resolution, and regulatory reporting. Essential for T+1 settlement compliance.',
    `execution_id` BIGINT COMMENT 'Reference to the trade execution that this confirmation validates.',
    `instrument_id` BIGINT COMMENT 'Internal reference to the financial instrument being confirmed.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio or fund to which this trade is allocated.',
    `strategy_id` BIGINT COMMENT 'Reference to the investment strategy under which this trade was executed.',
    `accrued_interest` DECIMAL(20,2) COMMENT 'Interest accrued on fixed income securities from the last coupon payment date to the trade date, confirmed by counterparty.',
    `affirmation_timestamp` TIMESTAMP COMMENT 'Date and time when the confirmation was affirmed by both parties, indicating bilateral agreement on trade economics.',
    `asset_class` STRING COMMENT 'High-level classification of the financial instrument being confirmed.. Valid values are `equity|fixed_income|fx|derivative|commodity|money_market`',
    `capacity` STRING COMMENT 'Capacity in which the counterparty acted in the trade: principal, agent, or riskless principal.. Valid values are `principal|agent|riskless_principal`',
    `clearing_house` STRING COMMENT 'Name of the Central Counterparty (CCP) or clearing house responsible for clearing and settlement of the trade.',
    `clearing_house_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier of the clearing house or CCP.. Valid values are `^[A-Z0-9]{20}$`',
    `commission_amount` DECIMAL(20,2) COMMENT 'Commission charged by the broker or intermediary, as confirmed in the trade confirmation.',
    `confirmation_status` STRING COMMENT 'Current lifecycle status of the trade confirmation indicating matching and affirmation state. [ENUM-REF-CANDIDATE: unconfirmed|matched|mismatched|affirmed|pending_affirmation|cancelled|rejected — 7 candidates stripped; promote to reference product]',
    `confirmation_type` STRING COMMENT 'Method by which the confirmation was received or transmitted, such as electronic via SWIFT or FIX, verbal, or written.. Valid values are `electronic|verbal|written|swift|fix`',
    `confirmed_price` DECIMAL(20,8) COMMENT 'Price per unit confirmed by the counterparty, used for matching against executed price.',
    `confirmed_quantity` DECIMAL(20,6) COMMENT 'Quantity of the instrument confirmed by the counterparty, used for matching against executed quantity.',
    `confirmed_settlement_amount` DECIMAL(20,2) COMMENT 'Net settlement amount confirmed by the counterparty, including adjustments for accrued interest, commissions, and fees.',
    `confirmed_trade_value` DECIMAL(20,2) COMMENT 'Total trade value confirmed by the counterparty, calculated as confirmed quantity multiplied by confirmed price.',
    `counterparty_confirmation_number` STRING COMMENT 'Confirmation reference number assigned by the counterparty for cross-referencing and reconciliation purposes.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this confirmation record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the trade value and settlement.. Valid values are `^[A-Z]{3}$`',
    `cusip` STRING COMMENT 'CUSIP identifier for North American securities.. Valid values are `^[A-Z0-9]{9}$`',
    `dvp_indicator` BOOLEAN COMMENT 'Flag indicating whether the trade will settle on a Delivery Versus Payment basis, ensuring simultaneous exchange of securities and cash.',
    `exception_notes` STRING COMMENT 'Free-text notes documenting any exceptions, manual interventions, or special handling required for this confirmation.',
    `fix_message_type` STRING COMMENT 'FIX protocol message type used for electronic confirmation, such as ExecutionReport or AllocationReport.',
    `isin` STRING COMMENT 'ISO 6166 International Securities Identification Number uniquely identifying the security.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `matched_by` STRING COMMENT 'User or system that performed the confirmation matching and affirmation process.',
    `matched_timestamp` TIMESTAMP COMMENT 'Date and time when the confirmation was successfully matched against internal execution records.',
    `matching_status` STRING COMMENT 'Status of the confirmation matching process between internal trade records and counterparty confirmation details.. Valid values are `matched|unmatched|exception|pending`',
    `mismatch_reason` STRING COMMENT 'Description of any discrepancies between internal execution records and counterparty confirmation, such as quantity, price, or settlement date mismatches.',
    `number` STRING COMMENT 'External business identifier for the confirmation, typically assigned by the counterparty or matching system.',
    `sedol` STRING COMMENT 'SEDOL identifier for securities traded on the London Stock Exchange and other UK markets.. Valid values are `^[A-Z0-9]{7}$`',
    `settlement_cycle` STRING COMMENT 'Standard settlement cycle for the trade, indicating the number of business days between trade date and settlement date.. Valid values are `T+0|T+1|T+2|T+3`',
    `settlement_date` DATE COMMENT 'Date on which the trade is scheduled to settle, as confirmed by the counterparty.',
    `source` STRING COMMENT 'System or platform from which the confirmation was received, such as Bloomberg AIM, Charles River IMS, or direct counterparty system.',
    `ssi_reference` STRING COMMENT 'Reference to the Standard Settlement Instructions used for this trade, defining payment and delivery details.',
    `swift_message_type` STRING COMMENT 'SWIFT message type used for electronic confirmation transmission, such as MT515 for client confirmation or MT518 for market-side confirmation.. Valid values are `^MT[0-9]{3}$`',
    `timestamp` TIMESTAMP COMMENT 'Date and time when the confirmation was received or generated, representing the principal business event for this record.',
    `trade_date` DATE COMMENT 'Date on which the trade was executed, as confirmed by the counterparty.',
    `trade_reporting_indicator` BOOLEAN COMMENT 'Flag indicating whether this trade requires regulatory reporting under MiFID II, EMIR, or other trade reporting regimes.',
    `trade_side` STRING COMMENT 'Indicates whether the pension fund is buying or selling the instrument in this trade.. Valid values are `buy|sell`',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this confirmation record was last modified.',
    CONSTRAINT pk_confirmation PRIMARY KEY(`confirmation_id`)
) COMMENT 'Trade confirmation record representing the bilateral agreement between the pension fund and its counterparty confirming trade economics. Captures confirmation type (electronic via SWIFT/FIX, verbal, written), confirmation status (unconfirmed, matched';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`instrument` (
    `instrument_id` BIGINT COMMENT 'Unique identifier for the financial instrument. Primary key.',
    `underlying_instrument_id` BIGINT COMMENT 'Reference to the underlying instrument for derivatives. Links to another instrument record.',
    `active_flag` BOOLEAN COMMENT 'Boolean indicator of whether the instrument record is currently active in the system.',
    `asset_class` STRING COMMENT 'High-level classification of the instrument into major asset categories.. Valid values are `equity|fixed_income|fx|derivative|commodity|real_estate`',
    `bloomberg_ticker` STRING COMMENT 'Bloomberg proprietary ticker symbol used for market data and trade execution via Bloomberg Terminal.',
    `callable_flag` BOOLEAN COMMENT 'Boolean indicator of whether the issuer has the right to redeem the instrument before maturity.',
    `cfi_code` STRING COMMENT '6-character ISO 10962 code classifying the instrument by category, group, and attributes.. Valid values are `^[A-Z]{6}$`',
    `contract_size` DECIMAL(18,4) COMMENT 'Notional size or multiplier for derivative contracts (e.g., number of shares per option contract).',
    `convertible_flag` BOOLEAN COMMENT 'Boolean indicator of whether the instrument can be converted into another security (typically equity).',
    `country_of_issue` STRING COMMENT '3-letter ISO 3166 country code representing the jurisdiction where the instrument was issued.. Valid values are `^[A-Z]{3}$`',
    `coupon_frequency` STRING COMMENT 'Frequency at which coupon payments are made for fixed income instruments.. Valid values are `annual|semi_annual|quarterly|monthly|zero`',
    `coupon_rate` DECIMAL(10,6) COMMENT 'Annual interest rate paid by fixed income instruments, expressed as a decimal (e.g., 0.0325 for 3.25%).',
    `credit_rating` STRING COMMENT 'Current credit rating assigned to the instrument by a recognized rating agency (e.g., AAA, BB+, Caa1).',
    `currency_code` STRING COMMENT '3-letter ISO 4217 currency code representing the denomination currency of the instrument.. Valid values are `^[A-Z]{3}$`',
    `cusip` STRING COMMENT '9-character alphanumeric code identifying North American securities.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `delisting_date` DATE COMMENT 'Date on which the instrument was removed from exchange listing. Null if still listed.',
    `effective_date` DATE COMMENT 'Date from which this instrument record is effective for trading and portfolio management.',
    `esg_rating` STRING COMMENT 'ESG rating or score assigned to the instrument or issuer by a recognized ESG rating provider.',
    `exchange_code` STRING COMMENT 'Code identifying the primary exchange or trading venue where the instrument is listed.',
    `exercise_style` STRING COMMENT 'Style of option exercise: American (any time), European (expiry only), or Bermudan (specific dates).. Valid values are `american|european|bermudan`',
    `face_value` DECIMAL(20,2) COMMENT 'Nominal or par value of the instrument at issuance, typically for fixed income securities.',
    `figi` STRING COMMENT '12-character alphanumeric code providing a universal identifier for financial instruments per Bloomberg Open Symbology.. Valid values are `^[A-Z0-9]{12}$`',
    `green_bond_flag` BOOLEAN COMMENT 'Boolean indicator of whether the instrument is certified as a green bond under recognized standards.',
    `instrument_type` STRING COMMENT 'Detailed classification of the instrument within its asset class (e.g., common stock, corporate bond, interest rate swap, FX forward).',
    `investment_grade_flag` BOOLEAN COMMENT 'Boolean indicator of whether the instrument is rated investment grade (BBB-/Baa3 or higher) by major rating agencies.',
    `isin` STRING COMMENT '12-character alphanumeric code uniquely identifying the security globally per ISO 6166 standard.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `issue_date` DATE COMMENT 'Date on which the instrument was originally issued or created.',
    `issuer_lei` STRING COMMENT '20-character ISO 17442 code uniquely identifying the issuing legal entity.. Valid values are `^[A-Z0-9]{20}$`',
    `issuer_name` STRING COMMENT 'Legal name of the entity that issued the instrument.',
    `listing_date` DATE COMMENT 'Date on which the instrument was first listed on an exchange for public trading.',
    `lot_size` DECIMAL(18,4) COMMENT 'Minimum tradeable quantity or contract size for the instrument.',
    `maturity_date` DATE COMMENT 'Date on which the instrument matures or expires. Null for perpetual instruments.',
    `mic_code` STRING COMMENT '4-character ISO 10383 code identifying the exchange or trading venue.. Valid values are `^[A-Z]{4}$`',
    `instrument_name` STRING COMMENT 'Full legal or common name of the financial instrument as recognized in the market.',
    `option_type` STRING COMMENT 'Type of option contract: call (right to buy) or put (right to sell).. Valid values are `call|put`',
    `puttable_flag` BOOLEAN COMMENT 'Boolean indicator of whether the holder has the right to sell the instrument back to the issuer before maturity.',
    `rating_agency` STRING COMMENT 'Name of the credit rating agency that assigned the credit rating (e.g., S&P, Moodys, Fitch).',
    `reuters_ric` STRING COMMENT 'Reuters proprietary instrument code used for market data and analytics.',
    `sector_classification` STRING COMMENT 'Industry sector classification of the issuer or underlying entity per GICS, ICB, or similar taxonomy.',
    `sedol` STRING COMMENT '7-character alphanumeric code identifying securities traded on the London Stock Exchange and other UK exchanges.. Valid values are `^[0-9BCDFGHJKLMNPQRSTVWXYZ]{7}$`',
    `settlement_cycle` STRING COMMENT 'Standard settlement period for trades in this instrument, expressed as trade date plus number of business days (e.g., T+2).. Valid values are `T+[0-9]`',
    `settlement_method` STRING COMMENT 'Method by which the instrument settles upon maturity or exercise (physical delivery, cash settlement, or net settlement).. Valid values are `physical|cash|net`',
    `short_name` STRING COMMENT 'Abbreviated or display name of the instrument for operational and reporting purposes.',
    `strike_price` DECIMAL(20,6) COMMENT 'Exercise price for options and other derivative instruments.',
    `termination_date` DATE COMMENT 'Date on which this instrument record was terminated or superseded. Null if still active.',
    `tick_size` DECIMAL(18,8) COMMENT 'Minimum price increment for trading the instrument on the exchange.',
    `trading_status` STRING COMMENT 'Current trading status of the instrument indicating whether it is actively tradeable.. Valid values are `active|suspended|delisted|matured|cancelled`',
    CONSTRAINT pk_instrument PRIMARY KEY(`instrument_id`)
) COMMENT 'Master reference record for all tradeable financial instruments across asset classes—equities, fixed income, FX, and OTC derivatives. Serves as the SSOT for instrument identity within the trade domain.';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`broker` (
    `broker_id` BIGINT COMMENT 'Unique identifier for the broker-dealer or execution counterparty record.',
    `finra_member_id` BIGINT COMMENT 'FINRA member identifier for U.S. broker-dealers subject to FINRA oversight.',
    `kyc_record_id` BIGINT COMMENT 'Foreign key linking to compliance.kyc_record. Business justification: AML/KYC regulations require broker due diligence before trading. Pension funds must verify broker KYC status during onboarding and periodic reviews per FCA/SEC requirements.',
    `approval_date` DATE COMMENT 'Date on which the broker was approved by the Investment Committee (IC) or designated authority for inclusion on the approved broker list.',
    `approved_asset_classes` STRING COMMENT 'Comma-separated list of asset classes for which the broker is approved to execute trades (e.g., equities, fixed income, FX, derivatives, commodities).',
    `bic` STRING COMMENT 'ISO 9362 Bank Identifier Code (SWIFT code) used for settlement instructions and payment routing to the broker.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `broker_status` STRING COMMENT 'Current operational status of the broker relationship indicating whether the broker is approved for trade execution.. Valid values are `active|inactive|suspended|pending_approval|terminated`',
    `broker_type` STRING COMMENT 'Classification of the broker-dealer by service model and execution capability.. Valid values are `full_service|execution_only|prime_broker|clearing_broker|introducing_broker|direct_market_access`',
    `clearing_arrangement` STRING COMMENT 'Type of clearing arrangement used by the broker for trade settlement.. Valid values are `self_clearing|third_party_clearing|prime_brokerage`',
    `clearing_house_name` STRING COMMENT 'Name of the central counterparty (CCP) or clearing house used by the broker for trade clearing and settlement.',
    `commission_structure` STRING COMMENT 'Description of the commission and fee structure applicable to trades executed through this broker (e.g., basis points, fixed per trade, tiered).',
    `counterparty_risk_limit` DECIMAL(18,2) COMMENT 'Maximum exposure limit (in base currency) allowed with this broker for counterparty risk management purposes.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the broker record was first created in the system.',
    `credit_rating` STRING COMMENT 'Current credit rating of the broker-dealer from a recognized rating agency (e.g., Moodys, S&P, Fitch) used for counterparty risk assessment.',
    `csa_flag` BOOLEAN COMMENT 'Indicates whether a Credit Support Annex is in place with this broker for collateral management on OTC derivatives.',
    `csa_threshold_amount` DECIMAL(18,2) COMMENT 'Threshold amount (in base currency) below which collateral is not required under the CSA with this broker.',
    `custodian_name` STRING COMMENT 'Name of the custodian bank holding securities on behalf of the pension fund when trading through this broker.',
    `dvp_capability_flag` BOOLEAN COMMENT 'Indicates whether the broker supports Delivery Versus Payment (DVP) settlement to mitigate settlement risk.',
    `esg_rating` STRING COMMENT 'ESG rating or score assigned to the broker-dealer by an external ESG rating provider (e.g., MSCI, Sustainalytics) for responsible investment stewardship.',
    `execution_capabilities` STRING COMMENT 'Description of the brokers execution capabilities including algorithmic trading, direct market access (DMA), high-touch services, and electronic trading platforms.',
    `fca_firm_reference_number` STRING COMMENT 'FCA-issued firm reference number for UK-regulated broker-dealers.',
    `headquarters_address` STRING COMMENT 'Full street address of the broker-dealers headquarters or principal place of business.',
    `headquarters_city` STRING COMMENT 'City where the broker-dealers headquarters is located.',
    `headquarters_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for the country where the broker-dealers headquarters is located.. Valid values are `^[A-Z]{3}$`',
    `isda_agreement_date` DATE COMMENT 'Date on which the ISDA Master Agreement with this broker was executed.',
    `isda_master_agreement_flag` BOOLEAN COMMENT 'Indicates whether an ISDA Master Agreement is in place with this broker for over-the-counter (OTC) derivatives trading.',
    `last_review_date` DATE COMMENT 'Date of the most recent periodic review of the broker-dealer for continued approval and performance assessment.',
    `legal_name` STRING COMMENT 'Full legal name of the broker-dealer or execution counterparty as registered with regulatory authorities.',
    `lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier uniquely identifying the broker-dealer globally for regulatory reporting and counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `minimum_transfer_amount` DECIMAL(18,2) COMMENT 'Minimum collateral transfer amount (in base currency) specified in the CSA with this broker.',
    `modified_by` STRING COMMENT 'User identifier of the person who last modified the broker record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the broker record was last modified in the system.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review of the broker-dealer.',
    `notes` STRING COMMENT 'Free-text field for additional notes, comments, or special instructions related to the broker relationship.',
    `primary_contact_email` STRING COMMENT 'Email address of the primary relationship contact at the broker-dealer.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_contact_name` STRING COMMENT 'Name of the primary relationship contact at the broker-dealer for operational and escalation purposes.',
    `primary_contact_phone` STRING COMMENT 'Phone number of the primary relationship contact at the broker-dealer.',
    `primary_regulator` STRING COMMENT 'Name of the primary regulatory body overseeing the broker-dealer (e.g., SEC, FCA, FINRA, ESMA).',
    `sec_registration_number` STRING COMMENT 'SEC-issued registration number for U.S.-registered broker-dealers.',
    `settlement_cycle` STRING COMMENT 'Standard settlement cycle for trades executed through this broker (e.g., T+2, T+1, T+0) across different asset classes.',
    `short_name` STRING COMMENT 'Abbreviated or trading name of the broker used for operational reference and reporting.',
    `ssi_on_file_flag` BOOLEAN COMMENT 'Indicates whether Standard Settlement Instructions (SSI) are on file and current for this broker.',
    `termination_date` DATE COMMENT 'Date on which the broker relationship was terminated or the broker was removed from the approved list.',
    `created_by` STRING COMMENT 'User identifier of the person who created the broker record.',
    CONSTRAINT pk_broker PRIMARY KEY(`broker_id`)
) COMMENT 'Master record for approved broker-dealers and execution counterparties used for trade execution across all asset classes. Captures broker legal name, LEI, BIC, regulatory registration numbers (FCA, SEC), approved asset classes, execution capabilities';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`broker_commission` (
    `broker_commission_id` BIGINT COMMENT 'Unique identifier for the broker commission record.',
    `broker_id` BIGINT COMMENT 'Identifier of the broker or executing dealer to whom the commission is payable.',
    `employee_id` BIGINT COMMENT 'Identifier of the internal trader or portfolio manager who executed the trade.',
    `execution_id` BIGINT COMMENT 'Reference to the trade execution that generated this commission charge.',
    `instrument_id` BIGINT COMMENT 'Internal identifier of the financial instrument that was traded.',
    `order_id` BIGINT COMMENT 'Reference to the parent order associated with this commission.',
    `payment_cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: Commission payments to brokers settle through specific cash accounts. Finance teams need this link for commission payment processing, cash forecasting, and broker payables',
    `portfolio_id` BIGINT COMMENT 'Identifier of the investment portfolio or fund to which this commission expense is allocated.',
    `strategy_id` BIGINT COMMENT 'Identifier of the investment strategy under which the trade and commission were executed.',
    `trader_employee_id` BIGINT COMMENT 'Identifier of the internal trader or portfolio manager who executed the trade.',
    `accrual_date` DATE COMMENT 'Date on which the commission expense is accrued in the accounting books.',
    `asset_class` STRING COMMENT 'Broad asset class of the instrument traded: equity, fixed income, foreign exchange, derivative, commodity, or alternative.. Valid values are `equity|fixed_income|fx|derivative|commodity|alternative`',
    `capacity` STRING COMMENT 'Capacity in which the broker acted: principal, agency, or riskless principal.. Valid values are `principal|agency|riskless_principal`',
    `commission_amount` DECIMAL(18,4) COMMENT 'Total commission charge payable to the broker in the commission currency.',
    `commission_basis` STRING COMMENT 'Method by which the commission is calculated: per share, percentage of trade value, flat fee per trade, tiered schedule, notional-based, or ticket charge.. Valid values are `per_share|percentage|flat_fee|tiered|notional_based|ticket_charge`',
    `commission_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the commission is denominated.. Valid values are `^[A-Z]{3}$`',
    `commission_rate_bps` DECIMAL(10,4) COMMENT 'Commission rate expressed in basis points of the trade notional value.',
    `commission_rate_per_share` DECIMAL(10,6) COMMENT 'Commission charge per share or unit traded, applicable for per-share commission structures.',
    `commission_reference` STRING COMMENT 'External reference or invoice number assigned by the broker for this commission charge.',
    `commission_sharing_arrangement_flag` BOOLEAN COMMENT 'Indicates whether this commission is part of a commission sharing arrangement with multiple brokers.',
    `commission_type` STRING COMMENT 'Classification of the commission structure: explicit fee, soft dollar arrangement, research payment account, bundled service, execution-only, or full-service.. Valid values are `explicit|soft_dollar|research_payment|bundled|execution_only|full_service`',
    `cost_center_code` STRING COMMENT 'General ledger cost center code to which this commission expense is allocated for accounting purposes.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this commission record was first created in the system.',
    `cusip` STRING COMMENT 'Nine-character alphanumeric code identifying North American securities.. Valid values are `^[A-Z0-9]{9}$`',
    `execution_quality_tier` STRING COMMENT 'Internal rating of the brokers execution quality for this trade, used for best execution monitoring.. Valid values are `tier_1|tier_2|tier_3|unrated`',
    `execution_venue` STRING COMMENT 'Name of the exchange, trading platform, or venue where the trade was executed.',
    `fx_rate` DECIMAL(18,10) COMMENT 'Exchange rate applied when converting commission amount from commission currency to settlement currency.',
    `gl_account_code` STRING COMMENT 'General ledger account code for booking the commission expense.',
    `invoice_date` DATE COMMENT 'Date on which the broker issued the commission invoice.',
    `invoice_number` STRING COMMENT 'Broker-issued invoice number for this commission charge.',
    `isin` STRING COMMENT 'Twelve-character alphanumeric code uniquely identifying the traded security.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this commission record was last modified.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding the commission charge, payment terms, or special arrangements.',
    `payment_date` DATE COMMENT 'Actual date on which the commission was paid to the broker.',
    `payment_due_date` DATE COMMENT 'Date by which the commission payment must be remitted to the broker.',
    `payment_method` STRING COMMENT 'Method used to remit the commission payment: wire transfer, ACH, check, netting arrangement, or offset against receivables.. Valid values are `wire_transfer|ach|check|netting|offset`',
    `payment_reference` STRING COMMENT 'Payment transaction reference or wire confirmation number for the commission remittance.',
    `payment_status` STRING COMMENT 'Current status of the commission payment: pending, scheduled, paid, overdue, disputed, or waived.. Valid values are `pending|scheduled|paid|overdue|disputed|waived`',
    `research_payment_account_flag` BOOLEAN COMMENT 'Indicates whether this commission is allocated to a research payment account under MiFID II unbundling rules.',
    `sedol` STRING COMMENT 'Seven-character alphanumeric code identifying securities traded on the London Stock Exchange and other UK exchanges.. Valid values are `^[A-Z0-9]{7}$`',
    `settlement_amount` DECIMAL(18,4) COMMENT 'Commission amount in settlement currency after foreign exchange conversion, if applicable.',
    `settlement_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the commission payment is settled, if different from commission currency.. Valid values are `^[A-Z]{3}$`',
    `settlement_date` DATE COMMENT 'Date on which the trade settles and commission payment is due.',
    `side` STRING COMMENT 'Direction of the trade: buy or sell.. Valid values are `buy|sell`',
    `soft_dollar_flag` BOOLEAN COMMENT 'Indicates whether this commission includes soft dollar benefits or bundled research services.',
    `trade_date` DATE COMMENT 'Date on which the underlying trade was executed.',
    `trade_notional_value` DECIMAL(18,4) COMMENT 'Gross notional value of the underlying trade used as the basis for commission calculation.',
    `trade_quantity` DECIMAL(18,6) COMMENT 'Number of shares or units traded, used for per-share commission calculations.',
    `venue_mic_code` STRING COMMENT 'Four-character ISO 10383 code identifying the execution venue or exchange.. Valid values are `^[A-Z]{4}$`',
    CONSTRAINT pk_broker_commission PRIMARY KEY(`broker_commission_id`)
) COMMENT 'Record of commission and transaction cost charges payable to a broker for trade execution services. Captures commission amount, commission rate (bps), commission type (explicit, soft dollar, research payment), trade reference, settlement currency, payment';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`standing_settlement_instruction` (
    `standing_settlement_instruction_id` BIGINT COMMENT 'Unique identifier for the standing_settlement_instruction data product (auto-inserted during validation).',
    `counterparty_id` BIGINT COMMENT 'Reference to the counterparty entity for which this SSI applies.',
    `custodian_id` BIGINT COMMENT 'Foreign key linking to trade.custodian. Business justification: Standing settlement instructions specify custodian details for settlement. The existing custodian_code (BIGINT) appears to be an unlinked FK.',
    `instrument_id` BIGINT COMMENT 'Reference to the financial instrument for which this SSI applies.',
    `approval_status` STRING COMMENT 'Internal approval status of this SSI record before activation.. Valid values are `pending|approved|rejected`',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when this SSI was approved.',
    `approved_by` STRING COMMENT 'User or role who approved this SSI for operational use.',
    `asset_class` STRING COMMENT 'Asset class category to which this SSI applies.. Valid values are `equity|fixed_income|fx|derivative|commodity|real_estate`',
    `beneficiary_account_name` STRING COMMENT 'Name on the beneficiary account for settlement proceeds.',
    `beneficiary_account_number` STRING COMMENT 'Account number for the beneficiary receiving settlement proceeds.',
    `clearing_system_code` STRING COMMENT 'Code identifying the clearing system or Central Counterparty (CCP) used.',
    `contact_email` STRING COMMENT 'Email address of the primary contact for settlement queries.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `contact_name` STRING COMMENT 'Name of the primary contact person for settlement queries related to this SSI.',
    `contact_phone` STRING COMMENT 'Phone number of the primary contact for settlement queries.',
    `counterparty_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the counterparty.. Valid values are `^[A-Z0-9]{20}$`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for the settlement jurisdiction.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this SSI record was first created in the system.',
    `custodian_bic` STRING COMMENT 'ISO 9362 Bank Identifier Code for the custodian institution.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `depository_account_number` STRING COMMENT 'Account number at the depository or custodian where securities are held.',
    `depository_bic` STRING COMMENT 'ISO 9362 Bank Identifier Code for the depository institution.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `depository_name` STRING COMMENT 'Name of the depository institution or central securities depository.',
    `effective_date` DATE COMMENT 'Date from which this SSI becomes valid and operational.',
    `emir_reporting_flag` BOOLEAN COMMENT 'Indicates whether this SSI requires EMIR trade reporting for derivatives.',
    `expiry_date` DATE COMMENT 'Date on which this SSI ceases to be valid, nullable for open-ended SSIs.',
    `instrument_type` STRING COMMENT 'Specific type of financial instrument covered by this SSI.',
    `intermediary_account_number` STRING COMMENT 'Account number at the intermediary institution, if applicable.',
    `intermediary_bic` STRING COMMENT 'ISO 9362 Bank Identifier Code for any intermediary institution in the settlement chain.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `last_used_date` DATE COMMENT 'Date when this SSI was last used for a settlement transaction.',
    `market_code` STRING COMMENT 'ISO 10383 Market Identifier Code (MIC) for the trading venue.. Valid values are `^[A-Z]{4}$`',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this SSI record was last modified.',
    `notes` STRING COMMENT 'Additional notes or comments regarding this SSI record.',
    `place_of_settlement` STRING COMMENT 'ISO 10383 MIC code for the place where settlement occurs.. Valid values are `^[A-Z]{4}$`',
    `priority_indicator` STRING COMMENT 'Priority level for settlement processing of trades using this SSI.. Valid values are `high|normal|low`',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether trades settled via this SSI require regulatory reporting.',
    `safekeeping_account` STRING COMMENT 'Account number for safekeeping of securities at the custodian.',
    `settlement_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for settlement transactions.. Valid values are `^[A-Z]{3}$`',
    `settlement_cycle` STRING COMMENT 'Standard settlement cycle for this SSI, expressed as T+N (e.g., T+2).. Valid values are `^T+[0-9]$`',
    `settlement_method` STRING COMMENT 'Method of settlement: Delivery Versus Payment (DVP), Free of Payment (FOP), Receive Versus Payment (RVP), or Payment Free of Delivery (PFOD).. Valid values are `dvp|fop|rvp|pfod`',
    `special_instructions` STRING COMMENT 'Free-text field for any special settlement instructions or conditions.',
    `ssi_reference` STRING COMMENT 'External business reference number or code for this SSI record.',
    `ssi_status` STRING COMMENT 'Current lifecycle status of the SSI record.. Valid values are `active|inactive|pending|suspended|expired`',
    `ssi_version` BIGINT COMMENT 'Version number of this SSI record, incremented with each update.',
    `standing_instruction_type` STRING COMMENT 'Indicates whether this SSI applies to receive, deliver, or both directions.. Valid values are `receive|deliver|both`',
    `tax_status` STRING COMMENT 'Tax treatment status applicable to settlements under this SSI.',
    `usage_count` BIGINT COMMENT 'Number of times this SSI has been used for settlement transactions.',
    CONSTRAINT pk_standing_settlement_instruction PRIMARY KEY(`standing_settlement_instruction_id`)
) COMMENT 'Standard Settlement Instruction master record defining the standing settlement details for a counterparty and instrument combination. Captures SSI version, effective date, expiry date, counterparty LEI, custodian BIC, depository account number, settlement';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`fx_trade` (
    `fx_trade_id` BIGINT COMMENT 'Unique identifier for the foreign exchange trade transaction.',
    `broker_id` BIGINT COMMENT 'Reference to the broker or intermediary who facilitated the FX trade execution.',
    `counterparty_id` BIGINT COMMENT 'Reference to the financial institution or counterparty with whom the FX trade was executed.',
    `csa_id` BIGINT COMMENT 'Foreign key linking to collateral.csa. Business justification: FX derivatives require CSA for collateral posting terms. Essential for pension funds FX hedging program margin management and UMR compliance.',
    `employee_id` BIGINT COMMENT 'Reference to the internal trader or portfolio manager who executed or authorized the FX trade.',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Currency hedging attribution: FX trades executed to hedge capital calls/distributions from external managers require GP linkage for manager-level currency exposure analysis, hedge',
    `isda_master_id` BIGINT COMMENT 'Foreign key linking to collateral.isda_master. Business justification: FX forwards and swaps are governed by ISDA agreements. Pension funds hedge currency exposure extensively; ISDA linkage enables netting and close-out netting calculations.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio for which this FX trade was executed.',
    `settlement_cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: FX trades settle through designated cash accounts. Treasury operations require this link for FX settlement processing, currency funding, and intraday liquidity management.',
    `trader_employee_id` BIGINT COMMENT 'Reference to the internal trader or portfolio manager who executed or authorized the FX trade.',
    `base_amount` DECIMAL(20,4) COMMENT 'The notional amount in the base currency being sold or exchanged.',
    `base_currency` STRING COMMENT 'The currency being sold or exchanged in the FX transaction, expressed as ISO 4217 three-letter code.. Valid values are `^[A-Z]{3}$`',
    `benchmark_rate` DECIMAL(18,8) COMMENT 'Reference benchmark exchange rate used for valuation or performance comparison purposes.',
    `benchmark_source` STRING COMMENT 'Source or provider of the benchmark exchange rate, such as WM/Reuters, ECB, or Bloomberg.',
    `clearing_house` STRING COMMENT 'Name of the central counterparty clearing house used for cleared FX trades, if applicable.',
    `clearing_status` STRING COMMENT 'Indicates whether the FX trade is centrally cleared, bilaterally settled, pending clearing, or failed clearing.. Valid values are `cleared|bilateral|pending_clearing|clearing_failed`',
    `commission_amount` DECIMAL(18,4) COMMENT 'Total commission or brokerage fee charged for executing the FX trade.',
    `commission_currency` STRING COMMENT 'Currency in which the commission or brokerage fee is denominated, expressed as ISO 4217 three-letter code.. Valid values are `^[A-Z]{3}$`',
    `confirmation_timestamp` TIMESTAMP COMMENT 'Date and time when the FX trade was confirmed by the counterparty.',
    `counterparty_lei` STRING COMMENT 'The 20-character ISO 17442 Legal Entity Identifier of the FX trade counterparty.. Valid values are `^[A-Z0-9]{20}$`',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this FX trade record was first created in the database.',
    `exchange_rate` DECIMAL(18,8) COMMENT 'The agreed exchange rate at which the base currency is converted to the quote currency.',
    `execution_method` STRING COMMENT 'Method by which the FX trade was executed: electronic platform, voice broker, request for quote, or algorithmic trading.. Valid values are `electronic|voice|request_for_quote|algorithmic`',
    `execution_venue` STRING COMMENT 'Name or identifier of the trading venue, platform, or system where the FX trade was executed.',
    `forward_points` DECIMAL(12,6) COMMENT 'The adjustment to the spot rate to derive the forward rate, reflecting interest rate differentials between the two currencies.',
    `hedge_designation` STRING COMMENT 'Accounting classification of the FX trade for hedge accounting purposes under IFRS 9 or equivalent standards.. Valid values are `fair_value_hedge|cash_flow_hedge|net_investment_hedge|not_designated`',
    `hedge_effectiveness_test` STRING COMMENT 'Type of hedge effectiveness testing applied to this FX trade if designated as a hedge.. Valid values are `prospective|retrospective|both|not_applicable`',
    `modified_timestamp` TIMESTAMP COMMENT 'System timestamp when this FX trade record was last updated or modified.',
    `ndf_fixing_date` DATE COMMENT 'The date on which the reference exchange rate is determined for settlement of a non-deliverable forward contract.',
    `ndf_fixing_source` STRING COMMENT 'The reference rate source used to determine the fixing rate for NDF settlement, such as central bank or Reuters page.',
    `notional_amount_usd` DECIMAL(20,4) COMMENT 'The total notional value of the FX trade converted to USD for reporting and risk aggregation purposes.',
    `quote_amount` DECIMAL(20,4) COMMENT 'The notional amount in the quote currency being bought or received.',
    `quote_currency` STRING COMMENT 'The currency being bought or received in the FX transaction, expressed as ISO 4217 three-letter code.. Valid values are `^[A-Z]{3}$`',
    `rate_type` STRING COMMENT 'Classification of the exchange rate: market rate at execution, benchmark reference rate, fixed contractual rate, or bilaterally negotiated rate.. Valid values are `market|benchmark|fixed|negotiated`',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this FX trade is subject to regulatory reporting requirements under EMIR, MiFID II, or equivalent jurisdictions.',
    `settlement_date` DATE COMMENT 'The date on which the FX trade is scheduled to settle and currencies are exchanged.',
    `settlement_method` STRING COMMENT 'Method by which the FX trade will be settled: physical delivery of currencies, cash settlement of net difference, or netting with other trades.. Valid values are `physical_delivery|cash_settlement|netting`',
    `settlement_timestamp` TIMESTAMP COMMENT 'Date and time when the FX trade settlement was completed and currencies were exchanged.',
    `side` STRING COMMENT 'Indicates whether the fund is buying or selling the base currency in this FX transaction.. Valid values are `buy|sell`',
    `spread_bps` DECIMAL(8,2) COMMENT 'The bid-ask spread or markup applied to the FX rate, expressed in basis points.',
    `swap_far_leg_date` DATE COMMENT 'Settlement date for the far leg of an FX swap transaction.',
    `swap_near_leg_date` DATE COMMENT 'Settlement date for the near leg of an FX swap transaction.',
    `trade_date` DATE COMMENT 'The business date on which the FX trade was executed.',
    `trade_purpose` STRING COMMENT 'Business purpose for executing the FX trade: hedging currency exposure, funding investments, repatriating proceeds, managing liquidity, or settling obligations.. Valid values are `hedge|investment_funding|repatriation|liquidity_management|settlement`',
    `trade_reference` STRING COMMENT 'External business identifier or reference number assigned to this FX trade by the trading system or counterparty.',
    `trade_status` STRING COMMENT 'Current lifecycle status of the FX trade in the settlement workflow.. Valid values are `pending|confirmed|settled|cancelled|failed`',
    `trade_timestamp` TIMESTAMP COMMENT 'Date and time when the FX trade was executed in the market.',
    `transaction_type` STRING COMMENT 'Type of FX transaction: spot for immediate delivery, forward for future delivery, swap for simultaneous buy and sell, or NDF for non-deliverable forward.. Valid values are `spot|forward|swap|ndf`',
    `uti` STRING COMMENT 'Globally unique identifier for the FX trade as required by regulatory reporting frameworks such as EMIR and Dodd-Frank.',
    `value_date` DATE COMMENT 'The effective date from which the exchanged currencies are available for use.',
    `venue_mic_code` STRING COMMENT 'ISO 10383 four-character Market Identifier Code for the execution venue.. Valid values are `^[A-Z]{4}$`',
    CONSTRAINT pk_fx_trade PRIMARY KEY(`fx_trade_id`)
) COMMENT 'Foreign exchange trade record capturing spot, forward, and swap FX transactions executed to fund investments, repatriate proceeds, or hedge currency exposure.';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`otc_derivative` (
    `otc_derivative_id` BIGINT COMMENT 'Unique identifier for the OTC derivative trade record.',
    `blotter_id` BIGINT COMMENT 'Reference to the parent trade execution record in the trade execution system.',
    `clearing_house_id` BIGINT COMMENT 'Foreign key linking to trade.clearing_house. Business justification: OTC derivatives that are cleared need to link to the clearing_house master reference table. The existing clearing_house_code (BIGINT) appears to be an unlinked FK.',
    `counterparty_id` BIGINT COMMENT 'Identifier of the external counterparty with whom the OTC derivative contract is bilaterally negotiated.',
    `csa_id` BIGINT COMMENT 'Foreign key linking to collateral.csa. Business justification: OTC derivatives require CSA linkage for collateral terms (thresholds, eligible collateral, haircuts). Critical for UMR compliance and daily variation margin calculation.',
    `employee_id` BIGINT COMMENT 'Identifier of the internal trader or portfolio manager who executed the OTC derivative trade.',
    `execution_id` BIGINT COMMENT 'Reference to the parent trade execution record in the trade execution system.',
    `isda_master_id` BIGINT COMMENT 'Foreign key linking to collateral.isda_master. Business justification: OTC derivatives are governed by ISDA master agreements defining netting, close-out, and termination rights.',
    `portfolio_id` BIGINT COMMENT 'Identifier of the investment portfolio to which this OTC derivative position is allocated.',
    `research_yield_curve_id` BIGINT COMMENT 'Foreign key linking to research.research_yield_curve. Business justification: OTC derivative valuation (especially interest rate swaps) requires yield curves for discounting and projection.',
    `trader_employee_id` BIGINT COMMENT 'Identifier of the internal trader or portfolio manager who executed the OTC derivative trade.',
    `booking_entity` STRING COMMENT 'Legal entity within the pension fund organization that books and holds the OTC derivative position.',
    `clearing_status` STRING COMMENT 'Indicates whether the OTC derivative is centrally cleared through a CCP or remains a bilateral contract.. Valid values are `cleared|bilateral|uncleared`',
    `collateral_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for collateral posted or received.. Valid values are `^[A-Z]{3}$`',
    `collateral_posted` DECIMAL(18,2) COMMENT 'Amount of collateral posted by the fund to the counterparty to cover mark-to-market exposure.',
    `collateral_received` DECIMAL(18,2) COMMENT 'Amount of collateral received from the counterparty to cover mark-to-market exposure in favor of the fund.',
    `confirmation_status` STRING COMMENT 'Status of trade confirmation between counterparties, indicating whether terms have been agreed and documented.. Valid values are `pending|confirmed|disputed|cancelled`',
    `confirmation_timestamp` TIMESTAMP COMMENT 'Timestamp when the OTC derivative trade was confirmed by both counterparties.',
    `counterparty_lei` STRING COMMENT '20-character ISO 17442 Legal Entity Identifier for the derivative counterparty, required for regulatory reporting.. Valid values are `^[A-Z0-9]{20}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the OTC derivative trade record was first created in the system.',
    `credit_rating` STRING COMMENT 'Credit rating of the counterparty or underlying reference entity, provided by agencies such as Moodys, S&P, or Fitch.',
    `csa_in_place` BOOLEAN COMMENT 'Boolean flag indicating whether a Credit Support Annex is in place for collateral management with the counterparty.',
    `day_count_convention` STRING COMMENT 'Method used to calculate accrued interest and payment amounts over time periods in the derivative contract.. Valid values are `actual_360|actual_365|30_360|actual_actual`',
    `derivative_subtype` STRING COMMENT 'Granular classification within the derivative type, such as fixed-to-floating swap or single-name CDS.',
    `derivative_type` STRING COMMENT 'Classification of the OTC derivative instrument by its underlying structure and payoff mechanism.. Valid values are `interest_rate_swap|credit_default_swap|total_return_swap|equity_swap|currency_swap|forward_rate_agreement`',
    `effective_date` DATE COMMENT 'Date on which the OTC derivative contract becomes legally binding and cash flows or obligations commence.',
    `fixed_rate` DECIMAL(10,6) COMMENT 'Fixed interest rate or spread expressed as a decimal for fixed-leg payments in interest rate swaps or CDS premiums.',
    `floating_rate_index` STRING COMMENT 'Reference rate index for floating-leg payments, such as SOFR, LIBOR, EURIBOR, or other benchmark rates.',
    `floating_rate_spread` DECIMAL(10,6) COMMENT 'Basis points spread added to or subtracted from the floating rate index, expressed as a decimal.',
    `isda_master_agreement_date` DATE COMMENT 'Date of the ISDA Master Agreement governing the legal terms and conditions of the derivative relationship with the counterparty.',
    `mark_to_market_value` DECIMAL(18,2) COMMENT 'Current fair value of the OTC derivative position based on market prices or valuation models.',
    `maturity_date` DATE COMMENT 'Date on which the OTC derivative contract expires and final settlement occurs.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the OTC derivative trade record was last modified in the system.',
    `mtm_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the mark-to-market valuation.. Valid values are `^[A-Z]{3}$`',
    `notional_amount` DECIMAL(20,2) COMMENT 'Principal amount on which derivative cash flows and payments are calculated, not exchanged at inception.',
    `notional_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the notional amount of the derivative contract.. Valid values are `^[A-Z]{3}$`',
    `payment_frequency` STRING COMMENT 'Frequency at which periodic cash flows or coupon payments are exchanged between counterparties.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Boolean flag indicating whether this OTC derivative trade is subject to regulatory reporting under EMIR, Dodd-Frank, or MiFID II.',
    `settlement_method` STRING COMMENT 'Method by which the derivative contract is settled at maturity or upon a credit event: cash settlement or physical delivery.. Valid values are `cash|physical`',
    `termination_date` DATE COMMENT 'Date on which the OTC derivative contract was terminated early, if applicable.',
    `termination_reason` STRING COMMENT 'Business reason for early termination of the derivative contract, such as credit event, mutual agreement, or portfolio rebalancing.',
    `trade_date` DATE COMMENT 'Date on which the OTC derivative contract was executed and agreed between counterparties.',
    `trade_reference_number` STRING COMMENT 'External business identifier for the OTC derivative trade, used for confirmation and settlement communication.',
    `trade_status` STRING COMMENT 'Current lifecycle status of the OTC derivative trade in the trade management workflow.. Valid values are `pending|confirmed|settled|terminated|cancelled`',
    `trade_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the OTC derivative trade was executed, including time zone.',
    `underlying_asset_class` STRING COMMENT 'Broad asset class category of the underlying reference entity or index for the derivative.. Valid values are `interest_rate|credit|equity|foreign_exchange|commodity`',
    `underlying_identifier` STRING COMMENT 'Unique identifier for the underlying reference asset, index, or entity (e.g., ISIN, Bloomberg ticker, RED code for CDS).',
    `underlying_name` STRING COMMENT 'Human-readable name of the underlying reference entity, index, or asset for the derivative contract.',
    `unique_product_identifier` STRING COMMENT 'Standardized identifier for the OTC derivative product type, used for regulatory reporting and market transparency.',
    `unique_trade_identifier` STRING COMMENT 'Globally unique identifier for the OTC derivative trade, required for regulatory reporting to trade repositories.',
    `valuation_date` DATE COMMENT 'Date as of which the mark-to-market value was calculated.',
    `valuation_source` STRING COMMENT 'Source system or vendor providing the mark-to-market valuation, such as Bloomberg, Markit, or internal model.',
    CONSTRAINT pk_otc_derivative PRIMARY KEY(`otc_derivative_id`)
) COMMENT 'OTC derivative trade record for bilaterally negotiated derivative contracts including interest rate swaps, credit default swaps (CDS), total return swaps, and equity derivatives.';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`ccp_clearing` (
    `ccp_clearing_id` BIGINT COMMENT 'Unique identifier for the CCP clearing record.',
    `cash_account_id` BIGINT COMMENT 'Reference to the account under which the cleared trade is booked.',
    `ccp_membership_id` BIGINT COMMENT 'Foreign key linking to collateral.ccp_membership. Business justification: Cleared trades must link to CCP membership for initial/variation margin requirements.',
    `clearing_house_id` BIGINT COMMENT 'Foreign key linking to trade.clearing_house. Business justification: CCP clearing records should link to the clearing_house master reference table. The existing clearing_house_code (BIGINT) appears to be an unlinked FK.',
    `execution_id` BIGINT COMMENT 'Reference to the underlying trade that was submitted for clearing.',
    `instrument_id` BIGINT COMMENT 'Reference to the financial instrument that was cleared.',
    `netting_agreement_id` BIGINT COMMENT 'Identifier for the netting set to which this cleared position belongs.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio to which this cleared trade belongs.',
    `asset_class` STRING COMMENT 'Asset class of the cleared instrument.. Valid values are `equity|fixed_income|fx|commodity|credit|interest_rate_derivative`',
    `backloading_flag` BOOLEAN COMMENT 'Indicates whether this is a backloaded trade submitted for clearing after execution.',
    `ccp_lei` STRING COMMENT 'Legal Entity Identifier of the CCP clearing house.. Valid values are `^[A-Z0-9]{20}$`',
    `ccp_name` STRING COMMENT 'Name of the central counterparty clearing house that cleared the trade.. Valid values are `LCH|CME Clearing|Eurex Clearing|ICE Clear|JSCC|OCC`',
    `cleared_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the cleared transaction.. Valid values are `^[A-Z]{3}$`',
    `cleared_notional_amount` DECIMAL(18,2) COMMENT 'Notional amount of the derivative contract that was cleared.',
    `cleared_quantity` DECIMAL(18,4) COMMENT 'Quantity of the instrument that was cleared through the CCP.',
    `clearing_acceptance_timestamp` TIMESTAMP COMMENT 'Date and time when the CCP accepted the trade for clearing.',
    `clearing_account_number` STRING COMMENT 'Account number at the CCP under which the trade is cleared.',
    `clearing_fee_amount` DECIMAL(18,2) COMMENT 'Fee charged by the CCP for clearing the transaction.',
    `clearing_fee_currency_code` STRING COMMENT 'Currency in which the clearing fee is denominated.. Valid values are `^[A-Z]{3}$`',
    `clearing_member_lei` STRING COMMENT 'Legal Entity Identifier of the clearing member firm.. Valid values are `^[A-Z0-9]{20}$`',
    `clearing_member_name` STRING COMMENT 'Name of the clearing member firm through which the trade was cleared.',
    `clearing_obligation_flag` BOOLEAN COMMENT 'Indicates whether the trade is subject to mandatory clearing obligation under EMIR.',
    `clearing_reference_number` STRING COMMENT 'Unique reference number assigned by the CCP for this cleared transaction.',
    `clearing_rejection_timestamp` TIMESTAMP COMMENT 'Date and time when the CCP rejected the trade for clearing.',
    `clearing_status` STRING COMMENT 'Current status of the clearing process for this trade.. Valid values are `submitted|accepted|cleared|rejected|pending|failed`',
    `clearing_submission_timestamp` TIMESTAMP COMMENT 'Date and time when the trade was submitted to the CCP for clearing.',
    `collateral_currency_code` STRING COMMENT 'Currency in which the collateral value is denominated.. Valid values are `^[A-Z]{3}$`',
    `collateral_type` STRING COMMENT 'Type of collateral posted to the CCP for margin requirements.. Valid values are `cash|securities|government_bonds|corporate_bonds|equity`',
    `collateral_value` DECIMAL(18,2) COMMENT 'Market value of collateral posted to the CCP.',
    `compression_eligible_flag` BOOLEAN COMMENT 'Indicates whether the cleared position is eligible for portfolio compression.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this CCP clearing record was first created in the system.',
    `default_fund_contribution` DECIMAL(18,2) COMMENT 'Contribution amount to the CCPs default fund for mutualized risk coverage.',
    `haircut_percentage` DECIMAL(5,2) COMMENT 'Haircut percentage applied by the CCP to the collateral value.',
    `initial_margin_amount` DECIMAL(18,2) COMMENT 'Initial margin requirement posted to the CCP to cover potential future exposure.',
    `initial_margin_currency_code` STRING COMMENT 'Currency in which the initial margin is denominated.. Valid values are `^[A-Z]{3}$`',
    `isin` STRING COMMENT 'International Securities Identification Number of the cleared instrument.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `maturity_date` DATE COMMENT 'Maturity date of the cleared derivative contract.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this CCP clearing record was last modified.',
    `product_type` STRING COMMENT 'Specific product type of the cleared derivative or security.',
    `rejection_code` STRING COMMENT 'Standardized code indicating the reason for clearing rejection.',
    `rejection_reason` STRING COMMENT 'Reason provided by the CCP for rejecting the clearing submission.',
    `settlement_date` DATE COMMENT 'Date on which the cleared trade is scheduled to settle.',
    `trade_date` DATE COMMENT 'Date on which the original trade was executed.',
    `usi` STRING COMMENT 'Unique Swap Identifier for cleared swap transactions under US regulations.',
    `uti` STRING COMMENT 'Unique Trade Identifier assigned to the cleared derivative transaction.',
    `variation_margin_amount` DECIMAL(18,2) COMMENT 'Variation margin amount exchanged to reflect daily mark-to-market changes.',
    `variation_margin_currency_code` STRING COMMENT 'Currency in which the variation margin is denominated.. Valid values are `^[A-Z]{3}$`',
    CONSTRAINT pk_ccp_clearing PRIMARY KEY(`ccp_clearing_id`)
) COMMENT 'Central counterparty clearing record for exchange-traded and cleared OTC derivatives submitted to a CCP (e.g., LCH, CME Clearing, Eurex). Captures CCP name, clearing member, cleared trade reference, initial margin requirement, variation margin, clearing';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`execution_venue` (
    `execution_venue_id` BIGINT COMMENT 'Unique identifier for the execution venue record.',
    `approval_expiry_date` DATE COMMENT 'Date when the current venue approval expires and requires renewal or re-certification.',
    `approved_date` DATE COMMENT 'Date when the venue was approved for trading by the firms investment committee or trading governance body.',
    `asset_classes_supported` STRING COMMENT 'Comma-separated list of asset classes tradable on this venue: equities, fixed income, foreign exchange, derivatives, commodities.',
    `average_fill_rate_pct` DECIMAL(5,2) COMMENT 'Historical average percentage of order quantity filled on first execution attempt.',
    `average_latency_ms` DECIMAL(10,2) COMMENT 'Average round-trip latency in milliseconds from order submission to execution acknowledgment.',
    `best_execution_eligible` BOOLEAN COMMENT 'Indicates whether the venue is approved for inclusion in the firms best execution policy and venue selection process.',
    `clearing_house` STRING COMMENT 'Name of the central counterparty or clearing house used for trade clearing and settlement.',
    `connectivity_protocol` STRING COMMENT 'Primary electronic connectivity protocol or API standard used for order routing and execution.',
    `contact_email` STRING COMMENT 'Primary email address for operational inquiries and trade support at the venue.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `contact_phone` STRING COMMENT 'Primary phone number for operational support and trade desk contact at the venue.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the venues primary jurisdiction.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the execution venue record was first created in the system.',
    `execution_quality_score` DECIMAL(5,2) COMMENT 'Composite score representing the venues execution quality based on price improvement, fill rates, and speed metrics.',
    `last_review_date` DATE COMMENT 'Date of the most recent periodic review of venue performance, execution quality, and compliance.',
    `lei` STRING COMMENT 'ISO 17442 legal entity identifier for the venue operator or parent organization.. Valid values are `^[A-Z0-9]{20}$`',
    `maximum_order_size` DECIMAL(18,4) COMMENT 'Maximum order quantity or notional value permitted for single order execution on this venue.',
    `mic_code` STRING COMMENT 'ISO 10383 four-character market identifier code uniquely identifying the venue.. Valid values are `^[A-Z]{4}$`',
    `minimum_order_size` DECIMAL(18,4) COMMENT 'Minimum order quantity or notional value required for execution on this venue.',
    `modified_by` STRING COMMENT 'User identifier or system account that last modified the execution venue record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the execution venue record was last modified or updated.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review of venue performance and best execution metrics.',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, restrictions, or special handling instructions for this venue.',
    `operating_mic` STRING COMMENT 'Operating MIC identifying the entity operating the venue when different from the segment MIC.. Valid values are `^[A-Z]{4}$`',
    `post_trade_reporting_required` BOOLEAN COMMENT 'Indicates whether trades executed on this venue require post-trade reporting to an approved publication arrangement.',
    `pre_trade_transparency_waiver` BOOLEAN COMMENT 'Indicates whether the venue operates under a pre-trade transparency waiver for certain instrument classes.',
    `regulatory_authority` STRING COMMENT 'Name of the primary regulatory body overseeing the execution venue.',
    `settlement_cycle` STRING COMMENT 'Standard settlement cycle for trades executed on this venue, expressed as T+N format.. Valid values are `^T+[0-9]$`',
    `supports_algorithmic_trading` BOOLEAN COMMENT 'Indicates whether the venue supports algorithmic order types and execution strategies.',
    `supports_dark_pool` BOOLEAN COMMENT 'Indicates whether the venue operates a dark pool or non-displayed liquidity mechanism.',
    `tick_size_regime` STRING COMMENT 'Description of the tick size rules and minimum price increment structure applied by the venue.',
    `time_zone` STRING COMMENT 'IANA time zone identifier for the venues trading hours and timestamps.',
    `trading_currency` STRING COMMENT 'Primary ISO 4217 currency code used for pricing and settlement on this venue.. Valid values are `^[A-Z]{3}$`',
    `trading_hours` STRING COMMENT 'Standard trading session hours in local time zone, including pre-market and post-market sessions if applicable.',
    `venue_name` STRING COMMENT 'Full legal or trading name of the execution venue.',
    `venue_status` STRING COMMENT 'Current operational status of the execution venue for trade routing and execution.. Valid values are `active|suspended|inactive|pending_approval|decommissioned`',
    `venue_type` STRING COMMENT 'Classification of the execution venue: regulated market, multilateral trading facility, organized trading facility, systematic internaliser, over-the-counter bilateral, or approved publication arrangement.. Valid values are `regulated_market|mtf|otf|systematic_internaliser|otc_bilateral|apa`',
    `website_url` STRING COMMENT 'Official website URL of the execution venue for reference documentation and market data.',
    `created_by` STRING COMMENT 'User identifier or system account that created the execution venue record.',
    CONSTRAINT pk_execution_venue PRIMARY KEY(`execution_venue_id`)
) COMMENT 'Master reference record for approved execution venues including regulated markets (exchanges), multilateral trading facilities (MTFs), systematic internalisers (SIs), and OTC bilateral venues.';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`amendment` (
    `amendment_id` BIGINT COMMENT 'Unique identifier for the trade amendment record.',
    `amendment_approved_by_user_employee_id` BIGINT COMMENT 'Identifier of the authorized user who approved the amendment for application.',
    `amendment_employee_id` BIGINT COMMENT 'Identifier of the user or trader who initiated the amendment request.',
    `approved_by_user_employee_id` BIGINT COMMENT 'Identifier of the authorized user who approved the amendment for application.',
    `blotter_id` BIGINT COMMENT 'Reference to the original executed trade that is being amended.',
    `employee_id` BIGINT COMMENT 'Identifier of the user or trader who initiated the amendment request.',
    `execution_id` BIGINT COMMENT 'Reference to the original executed trade that is being amended.',
    `supersedes_amendment_id` BIGINT COMMENT 'Reference to a previous amendment that this amendment replaces or supersedes.',
    `amended_commission_amount` DECIMAL(18,2) COMMENT 'The corrected commission amount after amendment is applied.',
    `amended_executed_price` DECIMAL(18,6) COMMENT 'The corrected execution price after amendment is applied.',
    `amended_executed_quantity` DECIMAL(18,4) COMMENT 'The corrected executed quantity after amendment is applied.',
    `amended_field_name` STRING COMMENT 'Name of the specific trade attribute that was modified by this amendment.',
    `amended_net_settlement_amount` DECIMAL(18,2) COMMENT 'The corrected net settlement amount after amendment is applied.',
    `amended_settlement_date` DATE COMMENT 'The corrected settlement date after amendment is applied.',
    `amended_value` DECIMAL(18,2) COMMENT 'The new corrected value of the field after the amendment is applied.',
    `amendment_status` STRING COMMENT 'Current lifecycle status of the amendment request in the approval and application workflow.. Valid values are `pending|approved|rejected|applied|cancelled`',
    `amendment_type` STRING COMMENT 'Classification of the amendment indicating which aspect of the trade is being corrected.. Valid values are `price_correction|quantity_adjustment|settlement_date_change|counterparty_correction|commission_adjustment|venue_correction`',
    `applied_timestamp` TIMESTAMP COMMENT 'Date and time when the amendment was successfully applied to the trade record.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the amendment was approved by an authorized user.',
    `audit_trail_reference` STRING COMMENT 'Reference to the detailed audit log entry capturing the full before-and-after state of the trade.',
    `counterparty_notification_status` STRING COMMENT 'Status indicating whether the counterparty has been notified of the amendment.. Valid values are `not_required|pending|sent|acknowledged|failed`',
    `counterparty_notification_timestamp` TIMESTAMP COMMENT 'Date and time when the counterparty was notified of the trade amendment.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this amendment record was first created in the database.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for monetary amounts in this amendment.. Valid values are `^[A-Z]{3}$`',
    `impact_on_accounting` BOOLEAN COMMENT 'Indicates whether this amendment requires accounting entries to be reversed or adjusted in the ABOR.',
    `impact_on_settlement` BOOLEAN COMMENT 'Indicates whether this amendment affects the settlement instructions and requires settlement system updates.',
    `modified_timestamp` TIMESTAMP COMMENT 'System timestamp when this amendment record was last modified.',
    `notes` STRING COMMENT 'Additional free-text notes or comments related to the amendment for operational context.',
    `original_commission_amount` DECIMAL(18,2) COMMENT 'The original commission amount before amendment, captured for audit trail purposes.',
    `original_executed_price` DECIMAL(18,6) COMMENT 'The original execution price before amendment, captured for audit trail purposes.',
    `original_executed_quantity` DECIMAL(18,4) COMMENT 'The original executed quantity before amendment, captured for audit trail purposes.',
    `original_net_settlement_amount` DECIMAL(18,2) COMMENT 'The original net settlement amount before amendment, captured for audit trail purposes.',
    `original_settlement_date` DATE COMMENT 'The original settlement date before amendment, captured for audit trail purposes.',
    `original_value` DECIMAL(18,2) COMMENT 'The original value of the field before the amendment was applied.',
    `reason_code` STRING COMMENT 'Standardized code indicating the business reason for the amendment.. Valid values are `data_entry_error|broker_error|counterparty_error|system_error|regulatory_correction|client_instruction`',
    `reason_description` STRING COMMENT 'Detailed free-text explanation of why the amendment was necessary.',
    `reference` STRING COMMENT 'External business reference number for this amendment, used for tracking and reconciliation.',
    `regulatory_reporting_required` BOOLEAN COMMENT 'Indicates whether this amendment must be reported to regulatory authorities under MiFID II or EMIR.',
    `regulatory_reporting_status` STRING COMMENT 'Status of regulatory reporting submission for this amendment.. Valid values are `not_required|pending|submitted|acknowledged|failed`',
    `regulatory_reporting_timestamp` TIMESTAMP COMMENT 'Date and time when the amendment was reported to regulatory authorities.',
    `rejection_reason` STRING COMMENT 'Explanation provided when an amendment request is rejected and not applied.',
    `timestamp` TIMESTAMP COMMENT 'Date and time when the amendment was initiated or requested.',
    `version_number` BIGINT COMMENT 'Sequential version number tracking multiple amendments to the same trade.',
    CONSTRAINT pk_amendment PRIMARY KEY(`amendment_id`)
) COMMENT 'Record of a post-trade amendment or correction applied to an executed trade. Captures amendment type (price correction, quantity adjustment, settlement date change, counterparty correction), original trade reference, amended field name, old value, new';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`status_history` (
    `status_history_id` BIGINT COMMENT 'Unique identifier for each status transition record in the trade lifecycle audit trail.',
    `broker_id` BIGINT COMMENT 'Reference to the broker handling the trade at this transition point.',
    `counterparty_id` BIGINT COMMENT 'Reference to the counterparty involved in this trade at the time of status transition.',
    `execution_id` BIGINT COMMENT 'Reference to the trade whose status transition is being recorded.',
    `instrument_id` BIGINT COMMENT 'Reference to the financial instrument being traded.',
    `order_id` BIGINT COMMENT 'Reference to the originating order for this trade status event.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio to which this trade belongs at the time of status change.',
    `triggering_user_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Trade status transitions require audit trails showing which employee triggered each change.',
    `allocation_status` STRING COMMENT 'The allocation status of the trade at the time of this status transition.. Valid values are `pending|allocated|partially_allocated|unallocated`',
    `amendment_flag` BOOLEAN COMMENT 'Indicates whether this status transition was triggered by a trade amendment.',
    `cancellation_flag` BOOLEAN COMMENT 'Indicates whether this status transition represents a trade cancellation event.',
    `clearing_house` STRING COMMENT 'The name of the central counterparty clearing house processing this trade.',
    `clearing_status` STRING COMMENT 'The clearing status of the trade with the central counterparty at this transition point.. Valid values are `pending|cleared|rejected|failed`',
    `confirmation_status` STRING COMMENT 'The confirmation status of the trade at the time of this status event.. Valid values are `pending|confirmed|unconfirmed|disputed`',
    `correction_flag` BOOLEAN COMMENT 'Indicates whether this status transition was triggered by a trade correction.',
    `counterparty_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier of the counterparty at the time of this status event.. Valid values are `^[A-Z0-9]{20}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this status history record was created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the trade value.. Valid values are `^[A-Z]{3}$`',
    `cusip` STRING COMMENT 'Nine-character alphanumeric code identifying North American securities.. Valid values are `^[A-Z0-9]{9}$`',
    `emir_reporting_flag` BOOLEAN COMMENT 'Indicates whether this status transition requires EMIR trade repository reporting.',
    `error_code` STRING COMMENT 'System or business error code if the status transition represents a failure or rejection.',
    `error_message` STRING COMMENT 'Detailed error message explaining the reason for failure or rejection.',
    `execution_venue` STRING COMMENT 'The trading venue or exchange where the trade was executed at this transition point.',
    `isin` STRING COMMENT 'ISO 6166 twelve-character alphanumeric code uniquely identifying the security.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `notes` STRING COMMENT 'Free-text notes or comments associated with this status transition.',
    `price` DECIMAL(18,6) COMMENT 'The price per unit of the instrument at the time of this status event.',
    `quantity` DECIMAL(18,4) COMMENT 'The quantity of the instrument involved in the trade at this status transition.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this status transition requires regulatory reporting.',
    `sedol` STRING COMMENT 'Seven-character alphanumeric code identifying securities traded on the London Stock Exchange.. Valid values are `^[A-Z0-9]{7}$`',
    `sequence_number` BIGINT COMMENT 'Sequential order of this status transition within the trades complete lifecycle.',
    `settlement_date` DATE COMMENT 'The expected or actual settlement date for the trade at the time of this status event.',
    `settlement_status` STRING COMMENT 'The settlement status of the trade at the time of this status transition.. Valid values are `pending|matched|affirmed|settled|failed|partial`',
    `status_from` STRING COMMENT 'The previous status of the trade before this transition occurred. [ENUM-REF-CANDIDATE: new|pending|executed|confirmed|allocated|settled|cancelled|rejected — 8 candidates stripped; promote to reference product]',
    `status_to` STRING COMMENT 'The new status of the trade after this transition occurred. [ENUM-REF-CANDIDATE: new|pending|executed|confirmed|allocated|settled|cancelled|rejected — 8 candidates stripped; promote to reference product]',
    `trade_value` DECIMAL(18,2) COMMENT 'The total monetary value of the trade at this status transition point.',
    `transition_event` STRING COMMENT 'The business event that triggered this status change. [ENUM-REF-CANDIDATE: order_created|execution_received|trade_confirmed|allocation_completed|settlement_completed|trade_cancelled|trade_rejected|amendment_applied|correction_applied — 9 candidates',
    `transition_reason` STRING COMMENT 'Business reason or explanation for the status change.',
    `transition_reason_code` STRING COMMENT 'Standardized code representing the reason for the status transition.',
    `transition_timestamp` TIMESTAMP COMMENT 'The exact date and time when the status transition occurred.',
    `triggering_system` STRING COMMENT 'The source system that initiated or recorded this status transition.',
    `triggering_user` STRING COMMENT 'The user or service account that triggered this status change.',
    `venue_mic_code` STRING COMMENT 'ISO 10383 four-character Market Identifier Code for the execution venue.. Valid values are `^[A-Z]{4}$`',
    `version_number` BIGINT COMMENT 'Sequential version number of the trade at the time of this status transition.',
    `created_by` STRING COMMENT 'The user or system account that created this status history record.',
    CONSTRAINT pk_status_history PRIMARY KEY(`status_history_id`)
) COMMENT 'Immutable trade audit and lifecycle trail capturing every change to a trade from order creation through settlement. Records both (a) status transitions — status_from, status_to, triggering event (execution, confirmation, settlement, cancellation), system';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`transaction_cost` (
    `transaction_cost_id` BIGINT COMMENT 'Unique identifier for the transaction cost record.',
    `broker_id` BIGINT COMMENT 'Reference to the broker or counterparty who charged or facilitated this cost.',
    `execution_id` BIGINT COMMENT 'Reference to the trade execution that incurred these costs.',
    `instrument_id` BIGINT COMMENT 'Reference to the financial instrument traded.',
    `market_data_snapshot_id` BIGINT COMMENT 'Foreign key linking to research.market_data_snapshot. Business justification: Transaction Cost Analysis (TCA) requires linking execution costs to benchmark market data snapshots.',
    `order_id` BIGINT COMMENT 'Reference to the parent order for this transaction cost.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio that incurred this transaction cost.',
    `strategy_id` BIGINT COMMENT 'Reference to the investment strategy associated with this transaction cost.',
    `asset_class` STRING COMMENT 'High-level asset class categorization of the traded instrument.. Valid values are `equity|fixed_income|fx|derivative|commodity|real_estate`',
    `benchmark_price` DECIMAL(18,6) COMMENT 'Reference price used to calculate implicit costs such as market impact and slippage.',
    `benchmark_type` STRING COMMENT 'Type of benchmark price used for transaction cost analysis.. Valid values are `arrival|vwap|twap|close|open|mid`',
    `clearing_fee` DECIMAL(18,4) COMMENT 'Fee charged by the central counterparty or clearing house for trade clearing.',
    `commission_type` STRING COMMENT 'Classification of commission payment structure per MiFID II unbundling requirements.. Valid values are `explicit|soft_dollar|research_payment|bundled|unbundled`',
    `cost_amount` DECIMAL(18,4) COMMENT 'Total cost amount for this transaction cost component in the cost currency.',
    `cost_bps` DECIMAL(10,4) COMMENT 'Transaction cost expressed in basis points relative to trade notional value.',
    `cost_calculation_timestamp` TIMESTAMP COMMENT 'Date and time when the transaction cost was calculated and recorded.',
    `cost_category` STRING COMMENT 'High-level categorization of the transaction cost type.. Valid values are `explicit|implicit|market_impact|timing|opportunity`',
    `cost_center_code` STRING COMMENT 'Internal cost center or business unit code for cost allocation and reporting.',
    `cost_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the transaction cost amount.. Valid values are `^[A-Z]{3}$`',
    `cost_reference` STRING COMMENT 'External reference number or identifier for this transaction cost record.',
    `cost_status` STRING COMMENT 'Current lifecycle status of the transaction cost record.. Valid values are `estimated|confirmed|invoiced|paid|disputed|adjusted`',
    `cost_type` STRING COMMENT 'Specific type of transaction cost incurred during trade execution. [ENUM-REF-CANDIDATE: commission|spread|market_impact|slippage|delay|tax|clearing_fee|exchange_fee|custody_fee|settlement_fee — 10 candidates stripped; promote to reference product]',
    `cusip` STRING COMMENT 'Nine-character alphanumeric code identifying North American securities.. Valid values are `^[0-9]{3}[0-9A-Z]{5}[0-9]$`',
    `exchange_fee` DECIMAL(18,4) COMMENT 'Fee charged by the trading venue or exchange for trade execution.',
    `execution_price` DECIMAL(18,6) COMMENT 'Actual price at which the trade was executed.',
    `execution_venue` STRING COMMENT 'Name of the trading venue or exchange where the trade was executed.',
    `fx_conversion_cost` DECIMAL(18,4) COMMENT 'Cost incurred for currency conversion related to cross-border trade settlement.',
    `invoice_reference` STRING COMMENT 'External invoice or billing reference number from the broker or service provider.',
    `isin` STRING COMMENT 'Twelve-character alphanumeric code uniquely identifying the security.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `market_impact_amount` DECIMAL(18,4) COMMENT 'Estimated cost due to the trades impact on market price during execution.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding this transaction cost record.',
    `opportunity_cost_amount` DECIMAL(18,4) COMMENT 'Cost of unfilled or partially filled orders representing missed investment opportunities.',
    `payment_date` DATE COMMENT 'Actual date on which the transaction cost was paid.',
    `payment_due_date` DATE COMMENT 'Date by which the transaction cost payment is due to the broker or venue.',
    `quantity` DECIMAL(18,6) COMMENT 'Number of units or shares traded in this execution.',
    `research_payment_account_flag` BOOLEAN COMMENT 'Indicates whether this cost was paid through a dedicated Research Payment Account per MiFID II.',
    `sedol` STRING COMMENT 'Seven-character alphanumeric code identifying securities traded in the UK and Ireland.. Valid values are `^[0-9BCDFGHJKLMNPQRSTVWXYZ]{6}[0-9]$`',
    `settlement_date` DATE COMMENT 'Date on which the trade is scheduled to settle and costs are finalized.',
    `settlement_fee` DECIMAL(18,4) COMMENT 'Fee charged by custodian or settlement agent for trade settlement processing.',
    `side` STRING COMMENT 'Direction of the trade indicating whether the position was bought or sold.. Valid values are `buy|sell|short_sell`',
    `slippage_amount` DECIMAL(18,4) COMMENT 'Difference between expected execution price and actual execution price.',
    `soft_dollar_allocation` DECIMAL(18,4) COMMENT 'Portion of commission allocated to soft dollar research payments per MiFID II unbundling.',
    `spread_amount` DECIMAL(18,6) COMMENT 'Cost attributed to the bid-ask spread at time of execution.',
    `tax_amount` DECIMAL(18,4) COMMENT 'Tax levied on the transaction such as stamp duty or financial transaction tax.',
    `timing_cost_amount` DECIMAL(18,4) COMMENT 'Cost attributed to delay between order decision and execution.',
    `trade_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the trade notional value.. Valid values are `^[A-Z]{3}$`',
    `trade_date` DATE COMMENT 'Date on which the trade was executed.',
    `trade_notional_value` DECIMAL(18,4) COMMENT 'Total notional value of the trade used as the basis for cost calculation.',
    `venue_mic_code` STRING COMMENT 'Four-character ISO 10383 Market Identifier Code for the execution venue.. Valid values are `^[A-Z]{4}$`',
    CONSTRAINT pk_transaction_cost PRIMARY KEY(`transaction_cost_id`)
) COMMENT 'Comprehensive transaction cost SSOT capturing ALL explicit and implicit costs for a trade execution — including broker commission (with commission type: explicit, soft dollar, research payment, and soft-dollar research credit allocation per MiFID II';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`algo_order` (
    `algo_order_id` BIGINT COMMENT 'Unique identifier for the algorithmic execution order record.',
    `broker_id` BIGINT COMMENT 'Reference to the broker or execution venue providing the algorithmic execution service.',
    `employee_id` BIGINT COMMENT 'Reference to the trader who initiated or is responsible for monitoring the algorithmic order.',
    `instrument_id` BIGINT COMMENT 'Reference to the financial instrument being traded via this algorithmic order.',
    `parent_order_id` BIGINT COMMENT 'Reference to the parent order that spawned this algorithmic execution strategy.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio for which this algorithmic order is executed.',
    `strategy_id` BIGINT COMMENT 'Reference to the investment strategy driving this algorithmic order.',
    `trader_employee_id` BIGINT COMMENT 'Reference to the trader who initiated or is responsible for monitoring the algorithmic order.',
    `algo_order_status` STRING COMMENT 'Current lifecycle status of the algorithmic order execution. [ENUM-REF-CANDIDATE: New|Pending|Active|Paused|Completed|Cancelled|Rejected|Expired — 8 candidates stripped; promote to reference product]',
    `algo_provider` STRING COMMENT 'Name of the algorithmic trading platform or service provider executing the order.',
    `algo_strategy_type` STRING COMMENT 'Type of algorithmic trading strategy employed to execute the order with minimal market impact.. Valid values are `VWAP|TWAP|POV|Implementation Shortfall|Arrival Price|Dark Aggregator`',
    `algo_version` STRING COMMENT 'Version identifier of the algorithmic strategy used for execution, for audit and performance tracking.',
    `average_execution_price` DECIMAL(18,6) COMMENT 'Volume-weighted average price achieved by the algorithmic strategy across all child executions.',
    `benchmark_price` DECIMAL(18,6) COMMENT 'Reference price used to measure the performance of the algorithmic execution strategy.',
    `benchmark_type` STRING COMMENT 'Type of benchmark used to evaluate the execution performance of the algorithmic order.. Valid values are `Arrival Price|Close Price|Open Price|VWAP|TWAP|Mid Price`',
    `cancellation_reason` STRING COMMENT 'Free-text explanation for why the algorithmic order was cancelled or terminated before completion.',
    `child_order_count` BIGINT COMMENT 'Total number of child orders generated by the algorithmic strategy to execute the parent order.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this algorithmic order record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code for the order pricing and settlement.. Valid values are `^[A-Z]{3}$`',
    `dark_pool_participation_flag` BOOLEAN COMMENT 'Indicates whether the algorithmic strategy is permitted to route orders to dark pools and alternative trading systems.',
    `end_time` TIMESTAMP COMMENT 'Scheduled end time for the algorithmic execution window in HH:MM:SS format.',
    `end_timestamp` TIMESTAMP COMMENT 'Date and time when the algorithmic execution strategy completed or was terminated.',
    `executed_quantity` DECIMAL(18,4) COMMENT 'Cumulative quantity of the instrument that has been executed by the algorithmic strategy to date.',
    `execution_style` STRING COMMENT 'Trading style parameter controlling the aggressiveness of the algorithmic execution strategy.. Valid values are `Passive|Neutral|Aggressive`',
    `implementation_shortfall_bps` DECIMAL(8,2) COMMENT 'Total cost of execution in basis points including market impact, timing cost, and opportunity cost.',
    `limit_price` DECIMAL(18,6) COMMENT 'Maximum price for buy orders or minimum price for sell orders that the algorithmic strategy may execute at.',
    `max_participation_rate` DECIMAL(5,4) COMMENT 'Maximum percentage of market volume that the algorithmic strategy may consume to avoid excessive market impact.',
    `max_slice_quantity` DECIMAL(18,4) COMMENT 'Maximum quantity that may be sent in a single child order slice by the algorithmic strategy.',
    `min_fill_quantity` DECIMAL(18,4) COMMENT 'Minimum quantity that must be filled in each child order execution to avoid excessive fragmentation.',
    `modified_by` STRING COMMENT 'User identifier or system account that last modified this algorithmic order record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this algorithmic order record was last modified in the system.',
    `notes` STRING COMMENT 'Additional free-text notes or comments regarding the algorithmic order execution for operational reference.',
    `notional_value` DECIMAL(20,2) COMMENT 'Total notional value of the algorithmic order calculated as quantity multiplied by average execution price.',
    `order_quantity` DECIMAL(18,4) COMMENT 'Total quantity of the instrument to be executed via the algorithmic strategy.',
    `participation_rate_target` DECIMAL(5,4) COMMENT 'Target participation rate as a percentage of market volume for POV algorithmic strategies.',
    `price_limit_offset_bps` BIGINT COMMENT 'Price tolerance in basis points from the benchmark or limit price that the algorithmic strategy may deviate.',
    `reference` STRING COMMENT 'External business reference number for the algorithmic order, used for tracking and reconciliation.',
    `rejection_reason` STRING COMMENT 'Free-text explanation for why the algorithmic order was rejected by the execution system or broker.',
    `remaining_quantity` DECIMAL(18,4) COMMENT 'Quantity of the instrument still pending execution by the algorithmic strategy.',
    `side` STRING COMMENT 'Direction of the algorithmic order indicating whether it is a buy or sell transaction.. Valid values are `Buy|Sell|Short Sell`',
    `slippage_bps` DECIMAL(8,2) COMMENT 'Measured slippage in basis points between the average execution price and the benchmark price.',
    `start_time` TIMESTAMP COMMENT 'Scheduled start time for the algorithmic execution window in HH:MM:SS format.',
    `start_timestamp` TIMESTAMP COMMENT 'Date and time when the algorithmic execution strategy began processing the order.',
    `submission_timestamp` TIMESTAMP COMMENT 'Date and time when the algorithmic order was submitted to the execution management system.',
    `urgency_level` STRING COMMENT 'Priority level indicating how aggressively the algorithmic strategy should pursue execution.. Valid values are `Low|Medium|High|Critical`',
    `venue_restriction_list` STRING COMMENT 'Comma-separated list of Market Identifier Codes (MIC) for venues that are restricted or preferred for this algorithmic order.',
    `created_by` STRING COMMENT 'User identifier or system account that created this algorithmic order record.',
    CONSTRAINT pk_algo_order PRIMARY KEY(`algo_order_id`)
) COMMENT 'Algorithmic execution order record capturing the parameters and performance of algorithmic trading strategies used to execute large orders with minimal market impact.';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`custody_account` (
    `custody_account_id` BIGINT COMMENT 'Unique identifier for the custody account record.',
    `counterparty_id` BIGINT COMMENT 'Reference to the custodian bank holding the account (State Street, Northern Trust, etc.).',
    `custodian_id` BIGINT COMMENT 'Foreign key linking to trade.custodian. Business justification: Custody accounts are held at custodian banks. The existing custodian_code (BIGINT) appears to be an unlinked FK.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio that owns this custody account.',
    `account_closure_date` DATE COMMENT 'The date when the custody account was closed, if applicable.',
    `account_currency` STRING COMMENT 'The base currency in which the custody account is denominated (ISO 4217 three-letter code).. Valid values are `^[A-Z]{3}$`',
    `account_manager_email` STRING COMMENT 'Email address of the custodian relationship manager for operational communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `account_manager_name` STRING COMMENT 'Name of the relationship manager or account officer at the custodian bank responsible for this account.',
    `account_manager_phone` STRING COMMENT 'Phone number of the custodian relationship manager for urgent operational matters.',
    `account_name` STRING COMMENT 'The legal name or title of the custody account as registered with the custodian.',
    `account_number` STRING COMMENT 'The unique account number assigned by the custodian bank for this custody account.',
    `account_opening_date` DATE COMMENT 'The date when the custody account was opened with the custodian.',
    `account_status` STRING COMMENT 'Current operational status of the custody account.. Valid values are `active|inactive|suspended|closed|pending_opening`',
    `account_type` STRING COMMENT 'Classification of the custody account based on its purpose and structure.. Valid values are `cash|securities|omnibus|segregated|nominee|direct`',
    `annual_custody_fee_bps` DECIMAL(8,4) COMMENT 'The annual custody fee charged by the custodian, expressed in basis points of Assets Under Administration (AUA).',
    `asset_class` STRING COMMENT 'Primary asset class held in this custody account.. Valid values are `equities|fixed_income|alternatives|multi_asset|cash|derivatives`',
    `beneficial_owner_name` STRING COMMENT 'The legal name of the beneficial owner of the assets held in this custody account.',
    `cash_sweep_account_flag` BOOLEAN COMMENT 'Indicates whether uninvested cash in this account is automatically swept to a designated cash management vehicle.',
    `collateral_account_flag` BOOLEAN COMMENT 'Indicates whether this custody account is designated for holding collateral for derivatives or securities financing transactions.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this custody account record was first created in the system.',
    `custodian_bic` STRING COMMENT 'The SWIFT BIC code of the custodian bank holding this account.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `custodian_lei` STRING COMMENT 'The Legal Entity Identifier of the custodian bank.. Valid values are `^[A-Z0-9]{20}$`',
    `custody_fee_schedule_code` STRING COMMENT 'Reference code for the fee schedule applicable to this custody account.',
    `depository_code` STRING COMMENT 'Standard code identifying the central securities depository (e.g., DTC, Euroclear, Clearstream).',
    `depository_name` STRING COMMENT 'Name of the central securities depository or sub-custodian where assets are held.',
    `emir_reporting_flag` BOOLEAN COMMENT 'Indicates whether trades in this account are subject to EMIR reporting requirements.',
    `last_reconciliation_date` DATE COMMENT 'The date of the most recent successful reconciliation of this custody account.',
    `last_statement_date` DATE COMMENT 'The date of the most recent custody account statement received from the custodian.',
    `last_valuation_date` DATE COMMENT 'The most recent date on which the custodian provided a valuation for assets held in this account.',
    `modified_by` STRING COMMENT 'The user or system identifier that last modified this custody account record.',
    `modified_timestamp` TIMESTAMP COMMENT 'The timestamp when this custody account record was last modified.',
    `nominee_name` STRING COMMENT 'The name of the nominee entity under which securities are registered, if applicable.',
    `omnibus_account_flag` BOOLEAN COMMENT 'Indicates whether this is an omnibus account holding assets for multiple underlying beneficial owners.',
    `place_of_settlement` STRING COMMENT 'ISO country code indicating the jurisdiction where settlement occurs for this account.. Valid values are `^[A-Z]{3}$`',
    `reconciliation_frequency` STRING COMMENT 'The frequency at which holdings and cash balances in this custody account are reconciled with internal records.. Valid values are `daily|weekly|monthly|quarterly`',
    `regulatory_classification` STRING COMMENT 'The regulatory classification of the account holder under applicable securities regulations.. Valid values are `institutional|retail|professional|eligible_counterparty`',
    `safekeeping_account_number` STRING COMMENT 'The safekeeping or depository account number where securities are held.',
    `securities_lending_eligible_flag` BOOLEAN COMMENT 'Indicates whether securities held in this account are eligible for securities lending programs.',
    `segregated_account_flag` BOOLEAN COMMENT 'Indicates whether assets in this account are held in a segregated manner separate from the custodians own assets.',
    `service_level_agreement_tier` STRING COMMENT 'The service tier or SLA level applicable to this custody account.. Valid values are `standard|premium|institutional|bespoke`',
    `settlement_method` STRING COMMENT 'Default settlement method for trades settling through this custody account (DVP = Delivery Versus Payment, RVP = Receive Versus Payment, FOP = Free of Payment).. Valid values are `dvp|rvp|fop|dap|free`',
    `sfdr_classification` STRING COMMENT 'SFDR article classification for ESG disclosure purposes, if applicable.. Valid values are `article_6|article_8|article_9|not_applicable`',
    `special_instructions` STRING COMMENT 'Any special handling instructions or operational notes specific to this custody account.',
    `tax_identification_number` STRING COMMENT 'The tax identification number associated with the beneficial owner of this custody account.',
    `tax_jurisdiction` STRING COMMENT 'ISO country code of the primary tax jurisdiction for this custody account.. Valid values are `^[A-Z]{3}$`',
    `tax_status` STRING COMMENT 'The tax treatment classification of the custody account.. Valid values are `taxable|tax_exempt|tax_deferred|qualified`',
    `transaction_fee_per_trade` DECIMAL(12,2) COMMENT 'The per-transaction fee charged by the custodian for trade settlement services.',
    `created_by` STRING COMMENT 'The user or system identifier that created this custody account record.',
    CONSTRAINT pk_custody_account PRIMARY KEY(`custody_account_id`)
) COMMENT 'Master record for custody accounts held at custodian banks (State Street, Northern Trust) used to hold securities and cash on behalf of the pension funds portfolios.';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`instrument_exclusion` (
    `instrument_exclusion_id` BIGINT COMMENT 'Unique identifier for this instrument-exclusion relationship record. Primary key.',
    `exclusion_list_id` BIGINT COMMENT 'Foreign key linking to the exclusion list policy that applies to this instrument',
    `instrument_id` BIGINT COMMENT 'Foreign key linking to the financial instrument subject to this exclusion',
    `divestment_deadline` DATE COMMENT 'Date by which the fund must complete divestment of this specific instrument under this exclusion policy. Critical for compliance monitoring and trade execution planning.',
    `effective_date` DATE COMMENT 'Date from which this specific exclusion applies to this specific instrument. May differ from the exclusion lists general effective date if the instrument was added later.',
    `instrument_exclusion_status` STRING COMMENT 'Current status of this exclusion application: active (exclusion enforced), pending_divestment (in process of selling), divested (fully exited), waived (exception granted).',
    `reason` STRING COMMENT 'Detailed explanation of why this specific instrument triggered this specific exclusion policy. Captures instrument-level nuance beyond the general exclusion list reason.',
    `revenue_threshold_pct` DECIMAL(5,2) COMMENT 'The actual revenue exposure percentage for this instrument that triggered the exclusion threshold. Allows tracking of how far above/below threshold each instrument falls.',
    CONSTRAINT pk_instrument_exclusion PRIMARY KEY(`instrument_exclusion_id`)
) COMMENT 'This association product represents the application of an exclusion policy to a specific financial instrument. It captures the compliance relationship between ESG exclusion lists and tradeable instruments in the pension funds investable universe.';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`netting_set_inclusion` (
    `netting_set_inclusion_id` BIGINT COMMENT 'Unique system-generated identifier for the netting set inclusion record',
    `netting_agreement_id` BIGINT COMMENT 'Foreign key linking to the netting agreement governing the netting arrangement',
    `otc_derivative_id` BIGINT COMMENT 'Foreign key linking to the OTC derivative trade included in the netting set',
    `eligibility_status` STRING COMMENT 'Current eligibility status of the trade for netting under this agreement based on product scope, legal enforceability, and agreement terms',
    `exclusion_date` DATE COMMENT 'Date on which the trade was removed from the netting set, null if currently included',
    `exclusion_reason` STRING COMMENT 'Reason for excluding the trade from the netting set if applicable (e.g., matured, novated, eligibility change)',
    `exposure_contribution` DECIMAL(20,2) COMMENT 'The trades contribution to the netted exposure calculation under this netting agreement, expressed in the agreements base currency',
    `inclusion_date` DATE COMMENT 'Date on which the OTC derivative trade was added to the netting set under this agreement',
    CONSTRAINT pk_netting_set_inclusion PRIMARY KEY(`netting_set_inclusion_id`)
) COMMENT 'This association product represents the inclusion of an OTC derivative trade within a netting agreement for exposure calculation and close-out netting purposes.';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`trade_check` (
    `trade_check_id` BIGINT COMMENT 'Primary key for the check association',
    `order_id` BIGINT COMMENT 'Foreign key linking to the investment order being validated',
    `rule_id` BIGINT COMMENT 'Foreign key linking to the compliance rule applied in this check',
    `override_approved_by` BIGINT COMMENT 'Reference to the compliance officer or authorized user who approved the override exception',
    `override_reason` STRING COMMENT 'Justification text provided when a failed compliance check is overridden to allow order execution',
    `result` STRING COMMENT 'Outcome of the compliance check indicating whether the order passed, failed, or triggered a warning for this rule',
    `timestamp` TIMESTAMP COMMENT 'Date and time when the compliance check was performed against the order',
    CONSTRAINT pk_trade_check PRIMARY KEY(`trade_check_id`)
) COMMENT 'This association product represents the pre-trade compliance check event between an investment order and a compliance rule. It captures the result of validating each order against applicable compliance rules before execution, including the check outcome';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`custodian` (
    `custodian_id` BIGINT COMMENT 'Primary key for custodian',
    `annual_custody_fee_bps` DECIMAL(8,4) COMMENT 'Annual custody fee expressed in basis points charged on assets under custody.',
    `api_integration_status` STRING COMMENT 'Status of API-based integration for real-time position and transaction data feeds.',
    `aum_threshold_usd` DECIMAL(18,2) COMMENT 'Minimum assets under management threshold in USD required by the custodian for service eligibility.',
    `base_currency_code` STRING COMMENT 'ISO 4217 currency code for the custodians primary reporting and fee currency.',
    `bic_code` STRING COMMENT 'SWIFT/BIC code identifying the custodian for international wire transfers and settlement instructions.',
    `contract_effective_date` DATE COMMENT 'Date when the current custody agreement became legally effective.',
    `contract_expiry_date` DATE COMMENT 'Date when the current custody agreement is scheduled to expire or requires renewal.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code indicating the custodians domicile jurisdiction.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the custodian record was first created in the system.',
    `credit_rating` STRING COMMENT 'Current credit rating of the custodian from major rating agencies for counterparty risk assessment.',
    `credit_rating_agency` STRING COMMENT 'Name of the rating agency that issued the current credit rating (e.g., Moodys, S&P, Fitch).',
    `credit_rating_date` DATE COMMENT 'Date when the current credit rating was assigned or last reviewed.',
    `custodian_type` STRING COMMENT 'Classification of custodian by service model and market coverage scope.',
    `insurance_coverage_usd` DECIMAL(18,2) COMMENT 'Total insurance coverage amount in USD protecting client assets held by the custodian.',
    `is_qualified_custodian` BOOLEAN COMMENT 'Indicates whether the custodian meets qualified custodian requirements under SEC Rule 206(4)-2.',
    `is_systemically_important` BOOLEAN COMMENT 'Indicates whether the custodian is designated as a systemically important financial institution (SIFI).',
    `last_due_diligence_date` DATE COMMENT 'Date of the most recent operational due diligence review conducted on the custodian.',
    `legal_entity_identifier` STRING COMMENT '20-character alphanumeric code uniquely identifying the custodian per ISO 17442 standard for global financial transactions.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the custodian record was last modified.',
    `custodian_name` STRING COMMENT 'Legal registered name of the custodian institution providing asset safekeeping and settlement services.',
    `next_due_diligence_date` DATE COMMENT 'Scheduled date for the next operational due diligence review of the custodian.',
    `notes` STRING COMMENT 'Free-text field for additional operational notes or special instructions regarding the custodian.',
    `onboarding_date` DATE COMMENT 'Date when the custodian relationship was formally established and approved for use.',
    `parent_company_name` STRING COMMENT 'Name of the parent company or holding entity if the custodian is a subsidiary.',
    `primary_contact_email` STRING COMMENT 'Email address of the primary contact for operational communications and settlement inquiries.',
    `primary_contact_name` STRING COMMENT 'Name of the primary relationship manager or contact person at the custodian institution.',
    `primary_contact_phone` STRING COMMENT 'Phone number of the primary contact for urgent settlement and custody matters.',
    `registered_address` STRING COMMENT 'Official registered business address of the custodian institution for legal and regulatory correspondence.',
    `regulatory_jurisdiction` STRING COMMENT 'Primary regulatory authority or jurisdiction governing the custodians operations and licensing.',
    `regulatory_license_number` STRING COMMENT 'License or registration number issued by the regulatory authority authorizing custody services.',
    `risk_rating` STRING COMMENT 'Internal counterparty risk rating assigned to the custodian based on due diligence assessment.',
    `service_level_agreement_tier` STRING COMMENT 'Contracted service level tier defining response times, reporting frequency, and support commitments.',
    `settlement_cut_off_time` STRING COMMENT 'Daily deadline time for submitting settlement instructions to the custodian in local timezone.',
    `custodian_status` STRING COMMENT 'Current operational status of the custodian relationship for trade settlement purposes.',
    `supported_asset_classes` STRING COMMENT 'Comma-separated list of asset classes the custodian can hold and settle (equities, fixed income, FX, derivatives).',
    `supported_markets` STRING COMMENT 'Comma-separated list of market codes or regions where the custodian provides settlement services.',
    `supports_corporate_actions` BOOLEAN COMMENT 'Indicates whether the custodian processes corporate actions (dividends, splits, mergers) on behalf of clients.',
    `supports_fx_execution` BOOLEAN COMMENT 'Indicates whether the custodian provides foreign exchange execution services for settlement.',
    `supports_proxy_voting` BOOLEAN COMMENT 'Indicates whether the custodian facilitates proxy voting services for equity holdings.',
    `supports_securities_lending` BOOLEAN COMMENT 'Indicates whether the custodian offers securities lending program services.',
    `swift_connectivity_status` STRING COMMENT 'Status of SWIFT messaging connectivity for automated settlement instruction transmission.',
    `termination_date` DATE COMMENT 'Date when the custodian relationship was terminated or scheduled for termination.',
    `transaction_fee_usd` DECIMAL(12,4) COMMENT 'Standard per-transaction settlement fee in USD charged by the custodian.',
    CONSTRAINT pk_custodian PRIMARY KEY(`custodian_id`)
) COMMENT 'Master reference table for custodian. Referenced by custodian_id.';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`allocation_group` (
    `allocation_group_id` BIGINT COMMENT 'Primary key for allocation_group',
    `approved_by_user_employee_id` BIGINT COMMENT 'Reference to the user who approved this allocation group for operational use.',
    `performance_benchmark_id` BIGINT COMMENT 'Reference to the benchmark index used for performance measurement of this allocation group.',
    `custodian_id` BIGINT COMMENT 'Reference to the primary custodian for assets held within this allocation group.',
    `department_id` BIGINT COMMENT 'Reference to the trading desk responsible for executing orders for this allocation group.',
    `employee_id` BIGINT COMMENT 'Reference to the portfolio manager responsible for investment decisions within this allocation group.',
    `investment_strategy_id` BIGINT COMMENT 'Reference to the investment strategy that governs this allocation groups investment approach.',
    `legal_entity_id` BIGINT COMMENT 'Reference to the legal entity that owns or manages this allocation group.',
    `settlement_instruction_id` BIGINT COMMENT 'Reference to default settlement instructions for trades allocated to this group.',
    `account_count` BIGINT COMMENT 'Number of investment accounts currently assigned to this allocation group.',
    `allocation_method` STRING COMMENT 'Method used to distribute trade fills across accounts within the allocation group.',
    `allows_partial_fills` BOOLEAN COMMENT 'Indicates whether the allocation group accepts partial order fills for distribution.',
    `approved_timestamp` TIMESTAMP COMMENT 'Timestamp when the allocation group was approved for operational use.',
    `asset_class` STRING COMMENT 'Primary asset class that this allocation group is designed to trade or manage.',
    `auto_rebalance_enabled` BOOLEAN COMMENT 'Indicates whether automatic rebalancing is enabled for accounts in this allocation group.',
    `base_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code representing the base currency for the allocation group.',
    `cash_buffer_percent` DECIMAL(5,2) COMMENT 'Percentage of portfolio value to maintain as cash buffer for liquidity management.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the allocation group record was first created in the system.',
    `allocation_group_description` STRING COMMENT 'Detailed description of the allocation group purpose, investment mandate, and allocation rules.',
    `drift_tolerance_percent` DECIMAL(5,2) COMMENT 'Maximum percentage deviation from target weights before triggering rebalancing.',
    `effective_from_date` DATE COMMENT 'Date from which the allocation group becomes active and available for trade allocation.',
    `effective_to_date` DATE COMMENT 'Date until which the allocation group remains active. Null indicates open-ended validity.',
    `external_system_code` STRING COMMENT 'Identifier used by external systems or counterparties to reference this allocation group.',
    `group_code` STRING COMMENT 'Business identifier code used to reference the allocation group in trading systems and order management platforms.',
    `group_type` STRING COMMENT 'Classification of the allocation group by its functional purpose in the investment process.',
    `is_default_group` BOOLEAN COMMENT 'Indicates whether this allocation group is the default for unassigned orders.',
    `is_model_portfolio` BOOLEAN COMMENT 'Indicates whether this allocation group represents a model portfolio for rebalancing purposes.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the allocation group record was last updated.',
    `minimum_allocation_amount` DECIMAL(18,2) COMMENT 'Minimum monetary amount that can be allocated to any single account within the group.',
    `minimum_allocation_quantity` DECIMAL(18,6) COMMENT 'Minimum number of shares or units that can be allocated to any single account within the group.',
    `allocation_group_name` STRING COMMENT 'Human-readable name of the allocation group used for display and reporting purposes.',
    `notes` STRING COMMENT 'Free-form notes and comments about the allocation group for operational reference.',
    `oms_system_code` STRING COMMENT 'Code identifying this allocation group in the Order Management System (Charles River or Bloomberg AIM).',
    `priority_rank` BIGINT COMMENT 'Numeric rank determining allocation priority when multiple groups compete for limited fills.',
    `rebalance_frequency` STRING COMMENT 'Frequency at which the allocation group is reviewed and rebalanced to target weights.',
    `requires_pre_trade_compliance` BOOLEAN COMMENT 'Indicates whether orders for this group must pass pre-trade compliance checks.',
    `rounding_lot_size` DECIMAL(18,6) COMMENT 'Standard lot size used for rounding allocations to tradeable quantities.',
    `rounding_method` STRING COMMENT 'Method used to round fractional shares or units during the allocation process.',
    `allocation_group_status` STRING COMMENT 'Current lifecycle status of the allocation group indicating its operational availability.',
    `tax_lot_method` STRING COMMENT 'Method used for selecting tax lots when allocating sales within the group.',
    `total_aum` DECIMAL(18,2) COMMENT 'Total assets under management across all accounts in this allocation group in base currency.',
    CONSTRAINT pk_allocation_group PRIMARY KEY(`allocation_group_id`)
) COMMENT 'Master reference table for allocation_group. Referenced by allocation_group_id.';

CREATE OR REPLACE TABLE `asset_management`.`trade`.`clearing_house` (
    `clearing_house_id` BIGINT COMMENT 'Primary key for clearing_house',
    `clearing_broker_id` BIGINT COMMENT 'Reference to the clearing broker used for indirect clearing access, if applicable.',
    `asset_class_coverage` STRING COMMENT 'Comma-separated list of asset classes cleared (e.g., equities, fixed_income, derivatives, fx, commodities).',
    `bic_code` STRING COMMENT 'SWIFT/BIC code identifying the clearing house for international financial messaging per ISO 9362.',
    `central_bank_money_settlement` BOOLEAN COMMENT 'Indicates whether settlement occurs in central bank money rather than commercial bank money.',
    `clearing_house_type` STRING COMMENT 'Classification of clearing house: CCP (Central Counterparty), CSD (Central Securities Depository), ICSD (International CSD), hybrid, or other.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this clearing house record was first created in the system.',
    `credit_rating_moodys` STRING COMMENT 'Current credit rating assigned to the clearing house by Moodys Investors Service.',
    `credit_rating_sp` STRING COMMENT 'Current credit rating assigned to the clearing house by Standard & Poors.',
    `default_fund_contribution_required` BOOLEAN COMMENT 'Indicates whether clearing members must contribute to a mutualized default fund.',
    `default_settlement_cycle` STRING COMMENT 'Standard settlement cycle for cleared trades (e.g., T+0, T+1, T+2).',
    `default_waterfall_position` BIGINT COMMENT 'Position of clearing house capital in the default waterfall sequence (1=first loss, higher=later).',
    `domicile_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code where the clearing house is legally domiciled.',
    `emir_tier` STRING COMMENT 'EMIR classification tier for third-country CCPs (Tier 1 or Tier 2) or not applicable for EU-based CCPs.',
    `interoperability_links` STRING COMMENT 'Comma-separated list of other clearing houses with which interoperability agreements exist.',
    `is_active` BOOLEAN COMMENT 'Indicates whether the clearing house is currently active and available for clearing services.',
    `is_systemically_important` BOOLEAN COMMENT 'Indicates whether the clearing house is designated as systemically important by regulators.',
    `legal_entity_identifier` STRING COMMENT '20-character alphanumeric code that uniquely identifies the clearing house as a legal entity per ISO 17442.',
    `margin_methodology` STRING COMMENT 'Primary margin calculation methodology used by the clearing house.',
    `membership_effective_date` DATE COMMENT 'Date when the pension funds clearing membership or access became effective.',
    `membership_status` STRING COMMENT 'Current status of the pension funds membership or relationship with this clearing house.',
    `membership_termination_date` DATE COMMENT 'Date when the pension funds clearing membership or access was terminated, if applicable.',
    `membership_type` STRING COMMENT 'Type of clearing access: direct clearing member, indirect via clearing broker, or sponsored access.',
    `mic_code` STRING COMMENT 'Four-character code identifying the clearing house as a market infrastructure per ISO 10383.',
    `clearing_house_name` STRING COMMENT 'Official registered name of the clearing house organization.',
    `netting_capability` BOOLEAN COMMENT 'Indicates whether the clearing house supports multilateral netting of obligations.',
    `notes` STRING COMMENT 'Free-text field for additional operational notes or comments about the clearing house.',
    `operational_hours_end` STRING COMMENT 'Daily operational end time in HH:MM format (local time zone).',
    `operational_hours_start` STRING COMMENT 'Daily operational start time in HH:MM format (local time zone).',
    `pfmi_compliant` BOOLEAN COMMENT 'Indicates whether the clearing house is compliant with CPMI-IOSCO Principles for Financial Market Infrastructures.',
    `primary_contact_email` STRING COMMENT 'Primary email address for operational inquiries with the clearing house.',
    `primary_contact_phone` STRING COMMENT 'Primary telephone number for operational contact with the clearing house.',
    `primary_regulator` STRING COMMENT 'Name of the primary regulatory authority overseeing the clearing house (e.g., SEC, ESMA, FCA, CFTC).',
    `qccp_status` BOOLEAN COMMENT 'Indicates whether the clearing house qualifies as a QCCP under Basel III capital requirements.',
    `real_time_gross_settlement` BOOLEAN COMMENT 'Indicates whether the clearing house supports real-time gross settlement processing.',
    `recovery_plan_available` BOOLEAN COMMENT 'Indicates whether the clearing house has a published recovery and resolution plan.',
    `registered_address` STRING COMMENT 'Official registered business address of the clearing house.',
    `regulatory_status` STRING COMMENT 'Current regulatory authorization status of the clearing house in its home jurisdiction.',
    `settlement_currency_codes` STRING COMMENT 'Comma-separated ISO 4217 currency codes supported for settlement (e.g., USD,EUR,GBP,JPY).',
    `short_name` STRING COMMENT 'Abbreviated or commonly used trading name of the clearing house (e.g., LCH, CME, DTCC).',
    `skin_in_the_game_amount` DECIMAL(18,2) COMMENT 'Amount of the clearing houses own capital committed to the default waterfall, in base currency.',
    `time_zone` STRING COMMENT 'IANA time zone identifier for the clearing houses primary operational time zone (e.g., Europe/London).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this clearing house record was last modified.',
    `website_url` STRING COMMENT 'Official website URL of the clearing house.',
    CONSTRAINT pk_clearing_house PRIMARY KEY(`clearing_house_id`)
) COMMENT 'Master reference table for clearing_house. Referenced by clearing_house_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`trade`.`order` ADD CONSTRAINT `fk_trade_order_broker_id` FOREIGN KEY (`broker_id`) REFERENCES `asset_management`.`trade`.`broker`(`broker_id`);
ALTER TABLE `asset_management`.`trade`.`order` ADD CONSTRAINT `fk_trade_order_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`trade`.`order` ADD CONSTRAINT `fk_trade_order_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`trade`.`order` ADD CONSTRAINT `fk_trade_order_parent_order_id` FOREIGN KEY (`parent_order_id`) REFERENCES `asset_management`.`trade`.`order`(`order_id`);
ALTER TABLE `asset_management`.`trade`.`order` ADD CONSTRAINT `fk_trade_order_security_instrument_id` FOREIGN KEY (`security_instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`trade`.`order_allocation` ADD CONSTRAINT `fk_trade_order_allocation_allocation_group_id` FOREIGN KEY (`allocation_group_id`) REFERENCES `asset_management`.`trade`.`allocation_group`(`allocation_group_id`);
ALTER TABLE `asset_management`.`trade`.`order_allocation` ADD CONSTRAINT `fk_trade_order_allocation_broker_id` FOREIGN KEY (`broker_id`) REFERENCES `asset_management`.`trade`.`broker`(`broker_id`);
ALTER TABLE `asset_management`.`trade`.`order_allocation` ADD CONSTRAINT `fk_trade_order_allocation_clearing_house_id` FOREIGN KEY (`clearing_house_id`) REFERENCES `asset_management`.`trade`.`clearing_house`(`clearing_house_id`);
ALTER TABLE `asset_management`.`trade`.`order_allocation` ADD CONSTRAINT `fk_trade_order_allocation_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`trade`.`order_allocation` ADD CONSTRAINT `fk_trade_order_allocation_order_id` FOREIGN KEY (`order_id`) REFERENCES `asset_management`.`trade`.`order`(`order_id`);
ALTER TABLE `asset_management`.`trade`.`order_allocation` ADD CONSTRAINT `fk_trade_order_allocation_standing_settlement_instruction_id` FOREIGN KEY (`standing_settlement_instruction_id`) REFERENCES `asset_management`.`trade`.`standing_settlement_instruction`(`standing_settlement_instruction_id`);
ALTER TABLE `asset_management`.`trade`.`execution` ADD CONSTRAINT `fk_trade_execution_broker_id` FOREIGN KEY (`broker_id`) REFERENCES `asset_management`.`trade`.`broker`(`broker_id`);
ALTER TABLE `asset_management`.`trade`.`execution` ADD CONSTRAINT `fk_trade_execution_execution_venue_id` FOREIGN KEY (`execution_venue_id`) REFERENCES `asset_management`.`trade`.`execution_venue`(`execution_venue_id`);
ALTER TABLE `asset_management`.`trade`.`execution` ADD CONSTRAINT `fk_trade_execution_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`trade`.`execution` ADD CONSTRAINT `fk_trade_execution_order_id` FOREIGN KEY (`order_id`) REFERENCES `asset_management`.`trade`.`order`(`order_id`);
ALTER TABLE `asset_management`.`trade`.`blotter` ADD CONSTRAINT `fk_trade_blotter_broker_id` FOREIGN KEY (`broker_id`) REFERENCES `asset_management`.`trade`.`broker`(`broker_id`);
ALTER TABLE `asset_management`.`trade`.`blotter` ADD CONSTRAINT `fk_trade_blotter_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`trade`.`blotter` ADD CONSTRAINT `fk_trade_blotter_execution_id` FOREIGN KEY (`execution_id`) REFERENCES `asset_management`.`trade`.`execution`(`execution_id`);
ALTER TABLE `asset_management`.`trade`.`blotter` ADD CONSTRAINT `fk_trade_blotter_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`trade`.`blotter` ADD CONSTRAINT `fk_trade_blotter_order_id` FOREIGN KEY (`order_id`) REFERENCES `asset_management`.`trade`.`order`(`order_id`);
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ADD CONSTRAINT `fk_trade_settlement_instruction_blotter_id` FOREIGN KEY (`blotter_id`) REFERENCES `asset_management`.`trade`.`blotter`(`blotter_id`);
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ADD CONSTRAINT `fk_trade_settlement_instruction_execution_id` FOREIGN KEY (`execution_id`) REFERENCES `asset_management`.`trade`.`execution`(`execution_id`);
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ADD CONSTRAINT `fk_trade_settlement_instruction_standing_settlement_instruction_id` FOREIGN KEY (`standing_settlement_instruction_id`) REFERENCES `asset_management`.`trade`.`standing_settlement_instruction`(`standing_settlement_instruction_id`);
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ADD CONSTRAINT `fk_trade_settlement_fail_blotter_id` FOREIGN KEY (`blotter_id`) REFERENCES `asset_management`.`trade`.`blotter`(`blotter_id`);
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ADD CONSTRAINT `fk_trade_settlement_fail_execution_id` FOREIGN KEY (`execution_id`) REFERENCES `asset_management`.`trade`.`execution`(`execution_id`);
ALTER TABLE `asset_management`.`trade`.`confirmation` ADD CONSTRAINT `fk_trade_confirmation_broker_id` FOREIGN KEY (`broker_id`) REFERENCES `asset_management`.`trade`.`broker`(`broker_id`);
ALTER TABLE `asset_management`.`trade`.`confirmation` ADD CONSTRAINT `fk_trade_confirmation_execution_id` FOREIGN KEY (`execution_id`) REFERENCES `asset_management`.`trade`.`execution`(`execution_id`);
ALTER TABLE `asset_management`.`trade`.`confirmation` ADD CONSTRAINT `fk_trade_confirmation_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`trade`.`instrument` ADD CONSTRAINT `fk_trade_instrument_underlying_instrument_id` FOREIGN KEY (`underlying_instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`trade`.`broker_commission` ADD CONSTRAINT `fk_trade_broker_commission_broker_id` FOREIGN KEY (`broker_id`) REFERENCES `asset_management`.`trade`.`broker`(`broker_id`);
ALTER TABLE `asset_management`.`trade`.`broker_commission` ADD CONSTRAINT `fk_trade_broker_commission_execution_id` FOREIGN KEY (`execution_id`) REFERENCES `asset_management`.`trade`.`execution`(`execution_id`);
ALTER TABLE `asset_management`.`trade`.`broker_commission` ADD CONSTRAINT `fk_trade_broker_commission_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`trade`.`broker_commission` ADD CONSTRAINT `fk_trade_broker_commission_order_id` FOREIGN KEY (`order_id`) REFERENCES `asset_management`.`trade`.`order`(`order_id`);
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ADD CONSTRAINT `fk_trade_standing_settlement_instruction_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ADD CONSTRAINT `fk_trade_standing_settlement_instruction_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`trade`.`fx_trade` ADD CONSTRAINT `fk_trade_fx_trade_broker_id` FOREIGN KEY (`broker_id`) REFERENCES `asset_management`.`trade`.`broker`(`broker_id`);
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ADD CONSTRAINT `fk_trade_otc_derivative_blotter_id` FOREIGN KEY (`blotter_id`) REFERENCES `asset_management`.`trade`.`blotter`(`blotter_id`);
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ADD CONSTRAINT `fk_trade_otc_derivative_clearing_house_id` FOREIGN KEY (`clearing_house_id`) REFERENCES `asset_management`.`trade`.`clearing_house`(`clearing_house_id`);
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ADD CONSTRAINT `fk_trade_otc_derivative_execution_id` FOREIGN KEY (`execution_id`) REFERENCES `asset_management`.`trade`.`execution`(`execution_id`);
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ADD CONSTRAINT `fk_trade_ccp_clearing_clearing_house_id` FOREIGN KEY (`clearing_house_id`) REFERENCES `asset_management`.`trade`.`clearing_house`(`clearing_house_id`);
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ADD CONSTRAINT `fk_trade_ccp_clearing_execution_id` FOREIGN KEY (`execution_id`) REFERENCES `asset_management`.`trade`.`execution`(`execution_id`);
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ADD CONSTRAINT `fk_trade_ccp_clearing_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`trade`.`amendment` ADD CONSTRAINT `fk_trade_amendment_blotter_id` FOREIGN KEY (`blotter_id`) REFERENCES `asset_management`.`trade`.`blotter`(`blotter_id`);
ALTER TABLE `asset_management`.`trade`.`amendment` ADD CONSTRAINT `fk_trade_amendment_execution_id` FOREIGN KEY (`execution_id`) REFERENCES `asset_management`.`trade`.`execution`(`execution_id`);
ALTER TABLE `asset_management`.`trade`.`amendment` ADD CONSTRAINT `fk_trade_amendment_supersedes_amendment_id` FOREIGN KEY (`supersedes_amendment_id`) REFERENCES `asset_management`.`trade`.`amendment`(`amendment_id`);
ALTER TABLE `asset_management`.`trade`.`status_history` ADD CONSTRAINT `fk_trade_status_history_broker_id` FOREIGN KEY (`broker_id`) REFERENCES `asset_management`.`trade`.`broker`(`broker_id`);
ALTER TABLE `asset_management`.`trade`.`status_history` ADD CONSTRAINT `fk_trade_status_history_execution_id` FOREIGN KEY (`execution_id`) REFERENCES `asset_management`.`trade`.`execution`(`execution_id`);
ALTER TABLE `asset_management`.`trade`.`status_history` ADD CONSTRAINT `fk_trade_status_history_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`trade`.`status_history` ADD CONSTRAINT `fk_trade_status_history_order_id` FOREIGN KEY (`order_id`) REFERENCES `asset_management`.`trade`.`order`(`order_id`);
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ADD CONSTRAINT `fk_trade_transaction_cost_broker_id` FOREIGN KEY (`broker_id`) REFERENCES `asset_management`.`trade`.`broker`(`broker_id`);
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ADD CONSTRAINT `fk_trade_transaction_cost_execution_id` FOREIGN KEY (`execution_id`) REFERENCES `asset_management`.`trade`.`execution`(`execution_id`);
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ADD CONSTRAINT `fk_trade_transaction_cost_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ADD CONSTRAINT `fk_trade_transaction_cost_order_id` FOREIGN KEY (`order_id`) REFERENCES `asset_management`.`trade`.`order`(`order_id`);
ALTER TABLE `asset_management`.`trade`.`algo_order` ADD CONSTRAINT `fk_trade_algo_order_broker_id` FOREIGN KEY (`broker_id`) REFERENCES `asset_management`.`trade`.`broker`(`broker_id`);
ALTER TABLE `asset_management`.`trade`.`algo_order` ADD CONSTRAINT `fk_trade_algo_order_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`trade`.`algo_order` ADD CONSTRAINT `fk_trade_algo_order_parent_order_id` FOREIGN KEY (`parent_order_id`) REFERENCES `asset_management`.`trade`.`order`(`order_id`);
ALTER TABLE `asset_management`.`trade`.`custody_account` ADD CONSTRAINT `fk_trade_custody_account_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`trade`.`instrument_exclusion` ADD CONSTRAINT `fk_trade_instrument_exclusion_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`trade`.`netting_set_inclusion` ADD CONSTRAINT `fk_trade_netting_set_inclusion_otc_derivative_id` FOREIGN KEY (`otc_derivative_id`) REFERENCES `asset_management`.`trade`.`otc_derivative`(`otc_derivative_id`);
ALTER TABLE `asset_management`.`trade`.`trade_check` ADD CONSTRAINT `fk_trade_trade_check_order_id` FOREIGN KEY (`order_id`) REFERENCES `asset_management`.`trade`.`order`(`order_id`);
ALTER TABLE `asset_management`.`trade`.`allocation_group` ADD CONSTRAINT `fk_trade_allocation_group_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`trade`.`allocation_group` ADD CONSTRAINT `fk_trade_allocation_group_settlement_instruction_id` FOREIGN KEY (`settlement_instruction_id`) REFERENCES `asset_management`.`trade`.`settlement_instruction`(`settlement_instruction_id`);
ALTER TABLE `asset_management`.`trade`.`clearing_house` ADD CONSTRAINT `fk_trade_clearing_house_clearing_broker_id` FOREIGN KEY (`clearing_broker_id`) REFERENCES `asset_management`.`trade`.`broker`(`broker_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`trade`.`order` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`trade`.`order` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`order` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`order` SET TAGS ('dbx_subdomain' = 'order_execution');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `order_id` SET TAGS ('dbx_business_glossary_term' = 'Order Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `broker_id` SET TAGS ('dbx_business_glossary_term' = 'Broker Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Manager Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Esg Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `exclusion_list_id` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `natural_resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `order_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Manager Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `order_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `order_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `order_trader_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `order_trader_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `order_trader_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `parent_order_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Order Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `security_instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `trader_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `allocation_method` SET TAGS ('dbx_business_glossary_term' = 'Allocation Method');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `allocation_method` SET TAGS ('dbx_value_regex' = 'pro_rata|priority|manual|average_price');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approved Timestamp');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `average_execution_price` SET TAGS ('dbx_business_glossary_term' = 'Average Execution Price');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `benchmark_index` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `commission_basis_points` SET TAGS ('dbx_business_glossary_term' = 'Commission Basis Points (bps)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `completed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Completed Timestamp');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `compliance_approved_flag` SET TAGS ('dbx_business_glossary_term' = 'Compliance Approved Flag');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `compliance_override_reason` SET TAGS ('dbx_business_glossary_term' = 'Compliance Override Reason');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Order Currency');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `execution_strategy` SET TAGS ('dbx_business_glossary_term' = 'Execution Strategy');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `execution_venue` SET TAGS ('dbx_business_glossary_term' = 'Execution Venue');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Order Expiry Date');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `filled_quantity` SET TAGS ('dbx_business_glossary_term' = 'Filled Quantity');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `instructions` SET TAGS ('dbx_business_glossary_term' = 'Order Instructions');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `limit_price` SET TAGS ('dbx_business_glossary_term' = 'Limit Price');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `notional_value` SET TAGS ('dbx_business_glossary_term' = 'Notional Value');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Order Number');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `order_date` SET TAGS ('dbx_business_glossary_term' = 'Order Date');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `order_status` SET TAGS ('dbx_business_glossary_term' = 'Order Status');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `order_type` SET TAGS ('dbx_business_glossary_term' = 'Order Type');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Order Quantity');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `remaining_quantity` SET TAGS ('dbx_business_glossary_term' = 'Remaining Quantity');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9B-DF-HJ-NP-TV-Z]{6}[0-9]$');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `settlement_currency` SET TAGS ('dbx_business_glossary_term' = 'Settlement Currency');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `settlement_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `side` SET TAGS ('dbx_business_glossary_term' = 'Order Side');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `side` SET TAGS ('dbx_value_regex' = 'buy|sell|short_sell|cover');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `stop_price` SET TAGS ('dbx_business_glossary_term' = 'Stop Price');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `submitted_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Submitted Timestamp');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `ticker_symbol` SET TAGS ('dbx_business_glossary_term' = 'Ticker Symbol');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `time_in_force` SET TAGS ('dbx_business_glossary_term' = 'Time In Force (TIF)');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `timestamp` SET TAGS ('dbx_business_glossary_term' = 'Order Timestamp');
ALTER TABLE `asset_management`.`trade`.`order` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`trade`.`order_allocation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`trade`.`order_allocation` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`order_allocation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`order_allocation` SET TAGS ('dbx_subdomain' = 'order_execution');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `order_allocation_id` SET TAGS ('dbx_business_glossary_term' = 'Order Allocation Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `allocation_group_id` SET TAGS ('dbx_business_glossary_term' = 'Allocation Group Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `broker_id` SET TAGS ('dbx_business_glossary_term' = 'Broker Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Account Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `clearing_house_id` SET TAGS ('dbx_business_glossary_term' = 'Clearing House Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `order_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Order Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `standing_settlement_instruction_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Settlement Instructions (SSI) Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `trader_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `accrued_interest` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `allocated_notional` SET TAGS ('dbx_business_glossary_term' = 'Allocated Notional Amount');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `allocated_quantity` SET TAGS ('dbx_business_glossary_term' = 'Allocated Quantity');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `allocation_instruction_type` SET TAGS ('dbx_business_glossary_term' = 'Allocation Instruction Type');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `allocation_instruction_type` SET TAGS ('dbx_value_regex' = 'automatic|manual|model_driven|pro_rata');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `allocation_number` SET TAGS ('dbx_business_glossary_term' = 'Allocation Number');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `allocation_percentage` SET TAGS ('dbx_business_glossary_term' = 'Allocation Percentage');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `allocation_reason` SET TAGS ('dbx_business_glossary_term' = 'Allocation Reason');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `allocation_status` SET TAGS ('dbx_business_glossary_term' = 'Allocation Status');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `allocation_status` SET TAGS ('dbx_value_regex' = 'pending|confirmed|rejected|cancelled|settled|partially_settled');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `allocation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Allocation Timestamp');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `allocation_type` SET TAGS ('dbx_business_glossary_term' = 'Allocation Type');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `allocation_type` SET TAGS ('dbx_value_regex' = 'calculated|preliminary|ready_to_book|warehouse_instruction|request_to_intermediary');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `allocation_version` SET TAGS ('dbx_business_glossary_term' = 'Allocation Version');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `average_price` SET TAGS ('dbx_business_glossary_term' = 'Average Execution Price');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `confirmation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Timestamp');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Record Modified By');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Settlement Amount');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Settlement Amount');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `settlement_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Settlement Currency Code');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `settlement_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'DVP|FOP|DAP|RVP');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `settlement_status` SET TAGS ('dbx_business_glossary_term' = 'Settlement Status');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `settlement_status` SET TAGS ('dbx_value_regex' = 'pending|settled|failed|partially_settled');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `trade_date` SET TAGS ('dbx_business_glossary_term' = 'Trade Date');
ALTER TABLE `asset_management`.`trade`.`order_allocation` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By');
ALTER TABLE `asset_management`.`trade`.`execution` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`trade`.`execution` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`execution` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`execution` SET TAGS ('dbx_subdomain' = 'order_execution');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `execution_id` SET TAGS ('dbx_business_glossary_term' = 'Execution Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `broker_id` SET TAGS ('dbx_business_glossary_term' = 'Broker Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `execution_venue_id` SET TAGS ('dbx_business_glossary_term' = 'Execution Venue Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `natural_resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `order_id` SET TAGS ('dbx_business_glossary_term' = 'Order Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Strategy Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `accrued_interest` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `algorithm` SET TAGS ('dbx_business_glossary_term' = 'Execution Algorithm');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'equity|fixed_income|fx|derivative|commodity|alternative');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `average_price_flag` SET TAGS ('dbx_business_glossary_term' = 'Average Price Flag');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `benchmark_price` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Price');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `bloomberg_ticker` SET TAGS ('dbx_business_glossary_term' = 'Bloomberg Ticker Symbol');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `capacity` SET TAGS ('dbx_business_glossary_term' = 'Execution Capacity');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `capacity` SET TAGS ('dbx_value_regex' = 'principal|agent|riskless_principal|cross_as_agent');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `clearing_house` SET TAGS ('dbx_business_glossary_term' = 'Clearing House');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `commission_currency` SET TAGS ('dbx_business_glossary_term' = 'Commission Currency Code');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `commission_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `confirmation_received_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Received Timestamp');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `dvp_indicator` SET TAGS ('dbx_business_glossary_term' = 'Delivery Versus Payment (DVP) Indicator');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `executed_price` SET TAGS ('dbx_business_glossary_term' = 'Executed Price');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `executed_quantity` SET TAGS ('dbx_business_glossary_term' = 'Executed Quantity');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `executing_trader` SET TAGS ('dbx_business_glossary_term' = 'Executing Trader');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `executing_trader` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `execution_status` SET TAGS ('dbx_business_glossary_term' = 'Execution Status');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `execution_status` SET TAGS ('dbx_value_regex' = 'filled|partial_fill|cancelled|rejected|pending_confirmation|confirmed');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `execution_type` SET TAGS ('dbx_business_glossary_term' = 'Execution Type');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `last_market_flag` SET TAGS ('dbx_business_glossary_term' = 'Last Market Flag');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `liquidity_indicator` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Indicator');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `liquidity_indicator` SET TAGS ('dbx_value_regex' = 'added|removed|routed');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `net_settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Settlement Amount');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Execution Notes');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `price_deviation_bps` SET TAGS ('dbx_business_glossary_term' = 'Price Deviation in Basis Points (bps)');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `reference` SET TAGS ('dbx_business_glossary_term' = 'Execution Reference Number');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_business_glossary_term' = 'Settlement Cycle');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_value_regex' = 'T+0|T+1|T+2|T+3');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `side` SET TAGS ('dbx_business_glossary_term' = 'Execution Side');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `side` SET TAGS ('dbx_value_regex' = 'buy|sell|short_sell');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `timestamp` SET TAGS ('dbx_business_glossary_term' = 'Execution Timestamp');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `trade_reporting_indicator` SET TAGS ('dbx_business_glossary_term' = 'Trade Reporting Indicator');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `trade_reporting_indicator` SET TAGS ('dbx_value_regex' = 'reported|unreported|pending');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `value` SET TAGS ('dbx_business_glossary_term' = 'Execution Value');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `venue` SET TAGS ('dbx_business_glossary_term' = 'Execution Venue');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `venue_mic_code` SET TAGS ('dbx_business_glossary_term' = 'Market Identifier Code (MIC)');
ALTER TABLE `asset_management`.`trade`.`execution` ALTER COLUMN `venue_mic_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}$');
ALTER TABLE `asset_management`.`trade`.`blotter` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`trade`.`blotter` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`blotter` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`blotter` SET TAGS ('dbx_subdomain' = 'order_execution');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `blotter_id` SET TAGS ('dbx_business_glossary_term' = 'Blotter ID');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `performance_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark ID');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `broker_id` SET TAGS ('dbx_business_glossary_term' = 'Broker ID');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian ID');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader ID');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `execution_id` SET TAGS ('dbx_business_glossary_term' = 'Trade ID');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Security ID');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `natural_resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Natural Resource Asset Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `order_id` SET TAGS ('dbx_business_glossary_term' = 'Order ID');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy ID');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `trader_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader ID');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `accrued_interest` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `allocation_status` SET TAGS ('dbx_business_glossary_term' = 'Allocation Status');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `allocation_status` SET TAGS ('dbx_value_regex' = 'pending|allocated|partially_allocated|rejected');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|fixed_income|fx|otc_derivative|private_equity|real_estate');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `broker_lei` SET TAGS ('dbx_business_glossary_term' = 'Broker Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `broker_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `capacity` SET TAGS ('dbx_business_glossary_term' = 'Trade Capacity');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `capacity` SET TAGS ('dbx_value_regex' = 'principal|agency|riskless_principal');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `commission` SET TAGS ('dbx_business_glossary_term' = 'Commission');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `compliance_rule_breached` SET TAGS ('dbx_business_glossary_term' = 'Compliance Rule Breached');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'approved|pending_review|breached|override_approved');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[0-9A-Z]{5}[0-9]$');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `custodian_account` SET TAGS ('dbx_business_glossary_term' = 'Custodian Account Number');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `custodian_account` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `execution_type` SET TAGS ('dbx_business_glossary_term' = 'Execution Type');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `execution_type` SET TAGS ('dbx_value_regex' = 'electronic|voice|algorithmic|block|crossing');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `execution_venue` SET TAGS ('dbx_business_glossary_term' = 'Execution Venue');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `fees` SET TAGS ('dbx_business_glossary_term' = 'Trade Fees');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Trade Amount');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `instrument_type` SET TAGS ('dbx_business_glossary_term' = 'Instrument Type');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `mic_code` SET TAGS ('dbx_business_glossary_term' = 'Market Identifier Code (MIC)');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `mic_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}$');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Trade Amount');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `price` SET TAGS ('dbx_business_glossary_term' = 'Trade Price');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `price_currency` SET TAGS ('dbx_business_glossary_term' = 'Price Currency');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `price_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Trade Quantity');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9BCDFGHJKLMNPQRSTVWXYZ]{7}$');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `settlement_currency` SET TAGS ('dbx_business_glossary_term' = 'Settlement Currency');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `settlement_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'dvp|rvp|fop');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `side` SET TAGS ('dbx_business_glossary_term' = 'Trade Side');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `side` SET TAGS ('dbx_value_regex' = 'buy|sell|short_sell');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `ticker` SET TAGS ('dbx_business_glossary_term' = 'Ticker Symbol');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `trade_confirmation_number` SET TAGS ('dbx_business_glossary_term' = 'Trade Confirmation Number');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `trade_date` SET TAGS ('dbx_business_glossary_term' = 'Trade Date');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `trade_notes` SET TAGS ('dbx_business_glossary_term' = 'Trade Notes');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `trade_status` SET TAGS ('dbx_business_glossary_term' = 'Trade Status');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `trade_status` SET TAGS ('dbx_value_regex' = 'new|allocated|confirmed|settled|cancelled|failed');
ALTER TABLE `asset_management`.`trade`.`blotter` ALTER COLUMN `trade_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Trade Timestamp');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` SET TAGS ('dbx_subdomain' = 'settlement_clearing');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `settlement_instruction_id` SET TAGS ('dbx_business_glossary_term' = 'Settlement Instruction Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `blotter_id` SET TAGS ('dbx_business_glossary_term' = 'Trade Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `execution_id` SET TAGS ('dbx_business_glossary_term' = 'Trade Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `standing_settlement_instruction_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Standard Settlement Instructions (SSI) Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `accrued_interest` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest Amount');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `affirmation_status` SET TAGS ('dbx_business_glossary_term' = 'Affirmation Status');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `affirmation_status` SET TAGS ('dbx_value_regex' = 'pending|affirmed|rejected|not_required');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `affirmation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Affirmation Timestamp');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `ccp_clearing_member` SET TAGS ('dbx_business_glossary_term' = 'Central Counterparty (CCP) Clearing Member');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `ccp_name` SET TAGS ('dbx_business_glossary_term' = 'Central Counterparty (CCP) Name');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `counterparty_account_number` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Account Number');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `counterparty_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `counterparty_custodian_bic` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Custodian Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `counterparty_custodian_bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `custodian_account_number` SET TAGS ('dbx_business_glossary_term' = 'Custodian Account Number');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `custodian_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `custodian_bic` SET TAGS ('dbx_business_glossary_term' = 'Custodian Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `custodian_bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `custodian_name` SET TAGS ('dbx_business_glossary_term' = 'Custodian Name');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `depository_code` SET TAGS ('dbx_business_glossary_term' = 'Central Securities Depository (CSD) Code');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `depository_name` SET TAGS ('dbx_business_glossary_term' = 'Central Securities Depository (CSD) Name');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `failure_code` SET TAGS ('dbx_business_glossary_term' = 'Settlement Failure Code');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `failure_reason` SET TAGS ('dbx_business_glossary_term' = 'Settlement Failure Reason');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `instruction_generation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Instruction Generation Timestamp');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `instruction_reference` SET TAGS ('dbx_business_glossary_term' = 'Settlement Instruction Reference Number');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `instruction_sent_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Instruction Sent Timestamp');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `instruction_status` SET TAGS ('dbx_business_glossary_term' = 'Settlement Instruction Status');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `instruction_status` SET TAGS ('dbx_value_regex' = 'pending|matched|affirmed|settled|failed|cancelled');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `instruction_type` SET TAGS ('dbx_business_glossary_term' = 'Instruction Type');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `instruction_type` SET TAGS ('dbx_value_regex' = 'delivery|receipt|payment|receive_payment');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `matching_status` SET TAGS ('dbx_business_glossary_term' = 'Matching Status');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `matching_status` SET TAGS ('dbx_value_regex' = 'unmatched|matched|mismatched|pending_match');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Modified By User');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `net_settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Settlement Amount');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `partial_settlement_allowed` SET TAGS ('dbx_business_glossary_term' = 'Partial Settlement Allowed Flag');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `place_of_settlement` SET TAGS ('dbx_business_glossary_term' = 'Place of Settlement (Country Code)');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `place_of_settlement` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Settlement Quantity');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Required Flag');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `security_identifier` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `security_identifier_type` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier Type');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `security_identifier_type` SET TAGS ('dbx_value_regex' = 'ISIN|CUSIP|SEDOL|TICKER');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Settlement Amount');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `settlement_currency` SET TAGS ('dbx_business_glossary_term' = 'Settlement Currency Code');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `settlement_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `settlement_fees` SET TAGS ('dbx_business_glossary_term' = 'Settlement Fees');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method (Delivery Versus Payment / Receive Versus Payment / Free of Payment / Delivery Free of Payment)');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'DVP|RVP|FOP|DFP');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `settlement_priority` SET TAGS ('dbx_business_glossary_term' = 'Settlement Priority');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `settlement_priority` SET TAGS ('dbx_value_regex' = 'normal|high|urgent');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `settlement_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Actual Settlement Timestamp');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `settlement_type` SET TAGS ('dbx_business_glossary_term' = 'Settlement Type');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `settlement_type` SET TAGS ('dbx_value_regex' = 'regular|cash|next_day|seller_option');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `trade_confirmation_reference` SET TAGS ('dbx_business_glossary_term' = 'Trade Confirmation Reference Number');
ALTER TABLE `asset_management`.`trade`.`settlement_instruction` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` SET TAGS ('dbx_subdomain' = 'settlement_clearing');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `settlement_fail_id` SET TAGS ('dbx_business_glossary_term' = 'Settlement Fail Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `blotter_id` SET TAGS ('dbx_business_glossary_term' = 'Trade Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `execution_id` SET TAGS ('dbx_business_glossary_term' = 'Trade Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `actual_settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Settlement Date');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `assigned_to` SET TAGS ('dbx_business_glossary_term' = 'Assigned To');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `buy_in_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Buy-In Execution Date');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `buy_in_notice_date` SET TAGS ('dbx_business_glossary_term' = 'Buy-In Notice Date');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `buy_in_risk_flag` SET TAGS ('dbx_business_glossary_term' = 'Buy-In Risk Flag');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `clearing_system` SET TAGS ('dbx_business_glossary_term' = 'Clearing System');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `custodian_bic` SET TAGS ('dbx_business_glossary_term' = 'Custodian Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `custodian_bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `dvp_model` SET TAGS ('dbx_business_glossary_term' = 'Delivery Versus Payment (DVP) Model');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `dvp_model` SET TAGS ('dbx_value_regex' = 'model_1|model_2|model_3|free_of_payment');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `escalation_date` SET TAGS ('dbx_business_glossary_term' = 'Escalation Date');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `escalation_level` SET TAGS ('dbx_business_glossary_term' = 'Escalation Level');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `escalation_level` SET TAGS ('dbx_value_regex' = 'none|operations|management|legal|executive');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `expected_settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Expected Settlement Date');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `fail_amount` SET TAGS ('dbx_business_glossary_term' = 'Fail Amount');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `fail_currency` SET TAGS ('dbx_business_glossary_term' = 'Fail Currency');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `fail_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `fail_date` SET TAGS ('dbx_business_glossary_term' = 'Fail Date');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `fail_detected_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Fail Detected Timestamp');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `fail_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Fail Duration Days');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `fail_party_type` SET TAGS ('dbx_business_glossary_term' = 'Fail Party Type');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `fail_party_type` SET TAGS ('dbx_value_regex' = 'internal|counterparty|custodian|broker|ccp');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `fail_quantity` SET TAGS ('dbx_business_glossary_term' = 'Fail Quantity');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `fail_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Fail Reason Code');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `fail_reason_code` SET TAGS ('dbx_value_regex' = 'insufficient_securities|cash_shortfall|counterparty_fail|ssi_mismatch|custody_hold|regulatory_block');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `fail_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Fail Reason Description');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `fail_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Fail Reference Number');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `fail_side` SET TAGS ('dbx_business_glossary_term' = 'Fail Side');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `fail_side` SET TAGS ('dbx_value_regex' = 'buy|sell');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `fail_status` SET TAGS ('dbx_business_glossary_term' = 'Fail Status');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `fail_status` SET TAGS ('dbx_value_regex' = 'open|partially_resolved|resolved|escalated|buy_in_initiated|closed');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `penalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Penalty Amount');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `penalty_currency` SET TAGS ('dbx_business_glossary_term' = 'Penalty Currency');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `penalty_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `regulatory_report_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Report Date');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `resolution_action` SET TAGS ('dbx_business_glossary_term' = 'Resolution Action');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `revised_settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Revised Settlement Date');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `security_cusip` SET TAGS ('dbx_business_glossary_term' = 'Security Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `security_cusip` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{9}$');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `security_isin` SET TAGS ('dbx_business_glossary_term' = 'Security International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `security_isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `security_sedol` SET TAGS ('dbx_business_glossary_term' = 'Security Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `security_sedol` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{7}$');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `ssi_correction_date` SET TAGS ('dbx_business_glossary_term' = 'Standard Settlement Instructions (SSI) Correction Date');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `ssi_mismatch_flag` SET TAGS ('dbx_business_glossary_term' = 'Standard Settlement Instructions (SSI) Mismatch Flag');
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`trade`.`confirmation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`trade`.`confirmation` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`confirmation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`confirmation` SET TAGS ('dbx_subdomain' = 'settlement_clearing');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `confirmation_id` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `broker_id` SET TAGS ('dbx_business_glossary_term' = 'Broker Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `execution_id` SET TAGS ('dbx_business_glossary_term' = 'Execution Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Strategy Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `accrued_interest` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `affirmation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Affirmation Timestamp');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'equity|fixed_income|fx|derivative|commodity|money_market');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `capacity` SET TAGS ('dbx_business_glossary_term' = 'Trading Capacity');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `capacity` SET TAGS ('dbx_value_regex' = 'principal|agent|riskless_principal');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `clearing_house` SET TAGS ('dbx_business_glossary_term' = 'Clearing House');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `clearing_house_lei` SET TAGS ('dbx_business_glossary_term' = 'Clearing House Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `clearing_house_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `confirmation_status` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Status');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `confirmation_type` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Type');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `confirmation_type` SET TAGS ('dbx_value_regex' = 'electronic|verbal|written|swift|fix');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `confirmed_price` SET TAGS ('dbx_business_glossary_term' = 'Confirmed Price');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `confirmed_quantity` SET TAGS ('dbx_business_glossary_term' = 'Confirmed Quantity');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `confirmed_settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Confirmed Settlement Amount');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `confirmed_trade_value` SET TAGS ('dbx_business_glossary_term' = 'Confirmed Trade Value');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `counterparty_confirmation_number` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Confirmation Number');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{9}$');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `dvp_indicator` SET TAGS ('dbx_business_glossary_term' = 'Delivery Versus Payment (DVP) Indicator');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `exception_notes` SET TAGS ('dbx_business_glossary_term' = 'Exception Notes');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `fix_message_type` SET TAGS ('dbx_business_glossary_term' = 'Financial Information eXchange (FIX) Message Type');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `matched_by` SET TAGS ('dbx_business_glossary_term' = 'Matched By');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `matched_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Matched Timestamp');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `matching_status` SET TAGS ('dbx_business_glossary_term' = 'Matching Status');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `matching_status` SET TAGS ('dbx_value_regex' = 'matched|unmatched|exception|pending');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `mismatch_reason` SET TAGS ('dbx_business_glossary_term' = 'Mismatch Reason');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Number');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{7}$');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_business_glossary_term' = 'Settlement Cycle');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_value_regex' = 'T+0|T+1|T+2|T+3');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `source` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Source');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `ssi_reference` SET TAGS ('dbx_business_glossary_term' = 'Standard Settlement Instructions (SSI) Reference');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `swift_message_type` SET TAGS ('dbx_business_glossary_term' = 'SWIFT Message Type');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `swift_message_type` SET TAGS ('dbx_value_regex' = '^MT[0-9]{3}$');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `swift_message_type` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `swift_message_type` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `timestamp` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Timestamp');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `trade_date` SET TAGS ('dbx_business_glossary_term' = 'Trade Date');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `trade_reporting_indicator` SET TAGS ('dbx_business_glossary_term' = 'Trade Reporting Indicator');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `trade_side` SET TAGS ('dbx_business_glossary_term' = 'Trade Side');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `trade_side` SET TAGS ('dbx_value_regex' = 'buy|sell');
ALTER TABLE `asset_management`.`trade`.`confirmation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`trade`.`instrument` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`trade`.`instrument` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`instrument` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`instrument` SET TAGS ('dbx_subdomain' = 'counterparty_cost');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `underlying_instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Underlying Instrument Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `active_flag` SET TAGS ('dbx_business_glossary_term' = 'Active Flag');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'equity|fixed_income|fx|derivative|commodity|real_estate');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `bloomberg_ticker` SET TAGS ('dbx_business_glossary_term' = 'Bloomberg Ticker Symbol');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `callable_flag` SET TAGS ('dbx_business_glossary_term' = 'Callable Flag');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `cfi_code` SET TAGS ('dbx_business_glossary_term' = 'Classification of Financial Instruments (CFI) Code');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `cfi_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}$');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `contract_size` SET TAGS ('dbx_business_glossary_term' = 'Contract Size');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `convertible_flag` SET TAGS ('dbx_business_glossary_term' = 'Convertible Flag');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `country_of_issue` SET TAGS ('dbx_business_glossary_term' = 'Country of Issue');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `country_of_issue` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `coupon_frequency` SET TAGS ('dbx_business_glossary_term' = 'Coupon Frequency');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `coupon_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly|zero');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `coupon_rate` SET TAGS ('dbx_business_glossary_term' = 'Coupon Rate');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `delisting_date` SET TAGS ('dbx_business_glossary_term' = 'Delisting Date');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `exchange_code` SET TAGS ('dbx_business_glossary_term' = 'Exchange Code');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `exercise_style` SET TAGS ('dbx_business_glossary_term' = 'Exercise Style');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `exercise_style` SET TAGS ('dbx_value_regex' = 'american|european|bermudan');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `face_value` SET TAGS ('dbx_business_glossary_term' = 'Face Value');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `figi` SET TAGS ('dbx_business_glossary_term' = 'Financial Instrument Global Identifier (FIGI)');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `figi` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{12}$');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `green_bond_flag` SET TAGS ('dbx_business_glossary_term' = 'Green Bond Flag');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `instrument_type` SET TAGS ('dbx_business_glossary_term' = 'Instrument Type');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `investment_grade_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Grade (IG) Flag');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'Issue Date');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Name');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `listing_date` SET TAGS ('dbx_business_glossary_term' = 'Listing Date');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `lot_size` SET TAGS ('dbx_business_glossary_term' = 'Lot Size');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `mic_code` SET TAGS ('dbx_business_glossary_term' = 'Market Identifier Code (MIC)');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `mic_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}$');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `instrument_name` SET TAGS ('dbx_business_glossary_term' = 'Instrument Name');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `option_type` SET TAGS ('dbx_business_glossary_term' = 'Option Type');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `option_type` SET TAGS ('dbx_value_regex' = 'call|put');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `puttable_flag` SET TAGS ('dbx_business_glossary_term' = 'Puttable Flag');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `rating_agency` SET TAGS ('dbx_business_glossary_term' = 'Rating Agency');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `reuters_ric` SET TAGS ('dbx_business_glossary_term' = 'Reuters Instrument Code (RIC)');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9BCDFGHJKLMNPQRSTVWXYZ]{7}$');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_business_glossary_term' = 'Settlement Cycle');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_value_regex' = 'T+[0-9]');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'physical|cash|net');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `short_name` SET TAGS ('dbx_business_glossary_term' = 'Instrument Short Name');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `strike_price` SET TAGS ('dbx_business_glossary_term' = 'Strike Price');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `tick_size` SET TAGS ('dbx_business_glossary_term' = 'Tick Size');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `trading_status` SET TAGS ('dbx_business_glossary_term' = 'Trading Status');
ALTER TABLE `asset_management`.`trade`.`instrument` ALTER COLUMN `trading_status` SET TAGS ('dbx_value_regex' = 'active|suspended|delisted|matured|cancelled');
ALTER TABLE `asset_management`.`trade`.`broker` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`trade`.`broker` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`broker` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`broker` SET TAGS ('dbx_subdomain' = 'counterparty_cost');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `broker_id` SET TAGS ('dbx_business_glossary_term' = 'Broker Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `finra_member_id` SET TAGS ('dbx_business_glossary_term' = 'Financial Industry Regulatory Authority (FINRA) Member ID');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `finra_member_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `finra_member_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `kyc_record_id` SET TAGS ('dbx_business_glossary_term' = 'Kyc Record Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Broker Approval Date');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `approved_asset_classes` SET TAGS ('dbx_business_glossary_term' = 'Approved Asset Classes');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `bic` SET TAGS ('dbx_business_glossary_term' = 'Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `broker_status` SET TAGS ('dbx_business_glossary_term' = 'Broker Status');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `broker_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending_approval|terminated');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `broker_type` SET TAGS ('dbx_business_glossary_term' = 'Broker Type');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `broker_type` SET TAGS ('dbx_value_regex' = 'full_service|execution_only|prime_broker|clearing_broker|introducing_broker|direct_market_access');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `clearing_arrangement` SET TAGS ('dbx_business_glossary_term' = 'Clearing Arrangement');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `clearing_arrangement` SET TAGS ('dbx_value_regex' = 'self_clearing|third_party_clearing|prime_brokerage');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `clearing_house_name` SET TAGS ('dbx_business_glossary_term' = 'Clearing House Name');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `commission_structure` SET TAGS ('dbx_business_glossary_term' = 'Commission Structure');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `counterparty_risk_limit` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Risk Limit');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `csa_flag` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) Flag');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `csa_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) Threshold Amount');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `custodian_name` SET TAGS ('dbx_business_glossary_term' = 'Custodian Name');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `dvp_capability_flag` SET TAGS ('dbx_business_glossary_term' = 'Delivery Versus Payment (DVP) Capability Flag');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `execution_capabilities` SET TAGS ('dbx_business_glossary_term' = 'Execution Capabilities');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `fca_firm_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Financial Conduct Authority (FCA) Firm Reference Number (FRN)');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_business_glossary_term' = 'Headquarters Address');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `headquarters_city` SET TAGS ('dbx_business_glossary_term' = 'Headquarters City');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `headquarters_country_code` SET TAGS ('dbx_business_glossary_term' = 'Headquarters Country Code');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `headquarters_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `isda_agreement_date` SET TAGS ('dbx_business_glossary_term' = 'ISDA Agreement Execution Date');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `isda_master_agreement_flag` SET TAGS ('dbx_business_glossary_term' = 'International Swaps and Derivatives Association (ISDA) Master Agreement Flag');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Broker Legal Name');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `minimum_transfer_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Transfer Amount');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Record Modified By User');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Broker Notes');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Email Address');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Name');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Phone Number');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `primary_regulator` SET TAGS ('dbx_business_glossary_term' = 'Primary Regulatory Authority');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `sec_registration_number` SET TAGS ('dbx_business_glossary_term' = 'Securities and Exchange Commission (SEC) Registration Number');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_business_glossary_term' = 'Settlement Cycle');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `short_name` SET TAGS ('dbx_business_glossary_term' = 'Broker Short Name');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `ssi_on_file_flag` SET TAGS ('dbx_business_glossary_term' = 'Standard Settlement Instructions (SSI) On File Flag');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Broker Termination Date');
ALTER TABLE `asset_management`.`trade`.`broker` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By User');
ALTER TABLE `asset_management`.`trade`.`broker_commission` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`trade`.`broker_commission` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`broker_commission` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`broker_commission` SET TAGS ('dbx_subdomain' = 'counterparty_cost');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `broker_commission_id` SET TAGS ('dbx_business_glossary_term' = 'Broker Commission ID');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `broker_id` SET TAGS ('dbx_business_glossary_term' = 'Broker ID');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader ID');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `execution_id` SET TAGS ('dbx_business_glossary_term' = 'Execution ID');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument ID');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `order_id` SET TAGS ('dbx_business_glossary_term' = 'Order ID');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `payment_cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Strategy ID');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `trader_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader ID');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `accrual_date` SET TAGS ('dbx_business_glossary_term' = 'Accrual Date');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'equity|fixed_income|fx|derivative|commodity|alternative');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `capacity` SET TAGS ('dbx_business_glossary_term' = 'Broker Capacity');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `capacity` SET TAGS ('dbx_value_regex' = 'principal|agency|riskless_principal');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `commission_basis` SET TAGS ('dbx_business_glossary_term' = 'Commission Basis');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `commission_basis` SET TAGS ('dbx_value_regex' = 'per_share|percentage|flat_fee|tiered|notional_based|ticket_charge');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `commission_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Commission Currency Code');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `commission_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `commission_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate (Basis Points)');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `commission_rate_per_share` SET TAGS ('dbx_business_glossary_term' = 'Commission Rate Per Share');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `commission_reference` SET TAGS ('dbx_business_glossary_term' = 'Commission Reference Number');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `commission_sharing_arrangement_flag` SET TAGS ('dbx_business_glossary_term' = 'Commission Sharing Arrangement (CSA) Flag');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `commission_type` SET TAGS ('dbx_business_glossary_term' = 'Commission Type');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `commission_type` SET TAGS ('dbx_value_regex' = 'explicit|soft_dollar|research_payment|bundled|execution_only|full_service');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{9}$');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `execution_quality_tier` SET TAGS ('dbx_business_glossary_term' = 'Execution Quality Tier');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `execution_quality_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3|unrated');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `execution_venue` SET TAGS ('dbx_business_glossary_term' = 'Execution Venue');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `invoice_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Date');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Invoice Number');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Commission Notes');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `payment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Due Date');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|ach|check|netting|offset');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `payment_reference` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'pending|scheduled|paid|overdue|disputed|waived');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `research_payment_account_flag` SET TAGS ('dbx_business_glossary_term' = 'Research Payment Account (RPA) Flag');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{7}$');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Settlement Amount');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `settlement_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Settlement Currency Code');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `settlement_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `side` SET TAGS ('dbx_business_glossary_term' = 'Trade Side');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `side` SET TAGS ('dbx_value_regex' = 'buy|sell');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `soft_dollar_flag` SET TAGS ('dbx_business_glossary_term' = 'Soft Dollar Flag');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `trade_date` SET TAGS ('dbx_business_glossary_term' = 'Trade Date');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `trade_notional_value` SET TAGS ('dbx_business_glossary_term' = 'Trade Notional Value');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `trade_quantity` SET TAGS ('dbx_business_glossary_term' = 'Trade Quantity');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `venue_mic_code` SET TAGS ('dbx_business_glossary_term' = 'Market Identifier Code (MIC)');
ALTER TABLE `asset_management`.`trade`.`broker_commission` ALTER COLUMN `venue_mic_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}$');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` SET TAGS ('dbx_subdomain' = 'settlement_clearing');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `standing_settlement_instruction_id` SET TAGS ('dbx_business_glossary_term' = 'Standing Settlement Instruction Identifier');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument ID');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'equity|fixed_income|fx|derivative|commodity|real_estate');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `beneficiary_account_name` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Account Name');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `beneficiary_account_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `beneficiary_account_number` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Account Number');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `beneficiary_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `clearing_system_code` SET TAGS ('dbx_business_glossary_term' = 'Clearing System Code');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `contact_email` SET TAGS ('dbx_business_glossary_term' = 'Contact Email');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `contact_name` SET TAGS ('dbx_business_glossary_term' = 'Contact Name');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Contact Phone');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `custodian_bic` SET TAGS ('dbx_business_glossary_term' = 'Custodian Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `custodian_bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `depository_account_number` SET TAGS ('dbx_business_glossary_term' = 'Depository Account Number');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `depository_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `depository_bic` SET TAGS ('dbx_business_glossary_term' = 'Depository Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `depository_bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `depository_name` SET TAGS ('dbx_business_glossary_term' = 'Depository Name');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `emir_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'European Market Infrastructure Regulation (EMIR) Reporting Flag');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `instrument_type` SET TAGS ('dbx_business_glossary_term' = 'Instrument Type');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `intermediary_account_number` SET TAGS ('dbx_business_glossary_term' = 'Intermediary Account Number');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `intermediary_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `intermediary_bic` SET TAGS ('dbx_business_glossary_term' = 'Intermediary Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `intermediary_bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `last_used_date` SET TAGS ('dbx_business_glossary_term' = 'Last Used Date');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `market_code` SET TAGS ('dbx_business_glossary_term' = 'Market Code');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `market_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}$');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `place_of_settlement` SET TAGS ('dbx_business_glossary_term' = 'Place of Settlement');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `place_of_settlement` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}$');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `priority_indicator` SET TAGS ('dbx_business_glossary_term' = 'Priority Indicator');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `priority_indicator` SET TAGS ('dbx_value_regex' = 'high|normal|low');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `safekeeping_account` SET TAGS ('dbx_business_glossary_term' = 'Safekeeping Account');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `safekeeping_account` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `settlement_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Settlement Currency Code');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `settlement_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_business_glossary_term' = 'Settlement Cycle');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_value_regex' = '^T+[0-9]$');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'dvp|fop|rvp|pfod');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `special_instructions` SET TAGS ('dbx_business_glossary_term' = 'Special Instructions');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `ssi_reference` SET TAGS ('dbx_business_glossary_term' = 'Standing Settlement Instruction (SSI) Reference');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `ssi_status` SET TAGS ('dbx_business_glossary_term' = 'Standing Settlement Instruction (SSI) Status');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `ssi_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|suspended|expired');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `ssi_version` SET TAGS ('dbx_business_glossary_term' = 'Standing Settlement Instruction (SSI) Version');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `standing_instruction_type` SET TAGS ('dbx_business_glossary_term' = 'Standing Instruction Type');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `standing_instruction_type` SET TAGS ('dbx_value_regex' = 'receive|deliver|both');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `tax_status` SET TAGS ('dbx_business_glossary_term' = 'Tax Status');
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ALTER COLUMN `usage_count` SET TAGS ('dbx_business_glossary_term' = 'Usage Count');
ALTER TABLE `asset_management`.`trade`.`fx_trade` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`trade`.`fx_trade` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`fx_trade` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`fx_trade` SET TAGS ('dbx_subdomain' = 'order_execution');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `fx_trade_id` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Trade Identifier');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `broker_id` SET TAGS ('dbx_business_glossary_term' = 'Broker Identifier');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `csa_id` SET TAGS ('dbx_business_glossary_term' = 'Csa Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader Identifier');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `isda_master_id` SET TAGS ('dbx_business_glossary_term' = 'Isda Master Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `settlement_cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Settlement Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `trader_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader Identifier');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `base_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Amount');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `base_currency` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `base_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `benchmark_rate` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Exchange Rate');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `benchmark_source` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Rate Source');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `clearing_house` SET TAGS ('dbx_business_glossary_term' = 'Central Counterparty (CCP) Clearing House');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `clearing_status` SET TAGS ('dbx_business_glossary_term' = 'Clearing Status');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `clearing_status` SET TAGS ('dbx_value_regex' = 'cleared|bilateral|pending_clearing|clearing_failed');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Commission Amount');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `commission_currency` SET TAGS ('dbx_business_glossary_term' = 'Commission Currency Code');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `commission_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `confirmation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Trade Confirmation Timestamp');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `execution_method` SET TAGS ('dbx_business_glossary_term' = 'Execution Method');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `execution_method` SET TAGS ('dbx_value_regex' = 'electronic|voice|request_for_quote|algorithmic');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `execution_venue` SET TAGS ('dbx_business_glossary_term' = 'Execution Venue');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `forward_points` SET TAGS ('dbx_business_glossary_term' = 'Forward Points');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `hedge_designation` SET TAGS ('dbx_business_glossary_term' = 'Hedge Accounting Designation');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `hedge_designation` SET TAGS ('dbx_value_regex' = 'fair_value_hedge|cash_flow_hedge|net_investment_hedge|not_designated');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `hedge_effectiveness_test` SET TAGS ('dbx_business_glossary_term' = 'Hedge Effectiveness Test Type');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `hedge_effectiveness_test` SET TAGS ('dbx_value_regex' = 'prospective|retrospective|both|not_applicable');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `ndf_fixing_date` SET TAGS ('dbx_business_glossary_term' = 'Non-Deliverable Forward (NDF) Fixing Date');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `ndf_fixing_source` SET TAGS ('dbx_business_glossary_term' = 'Non-Deliverable Forward (NDF) Fixing Source');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `notional_amount_usd` SET TAGS ('dbx_business_glossary_term' = 'Notional Amount in United States Dollars (USD)');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `quote_amount` SET TAGS ('dbx_business_glossary_term' = 'Quote Currency Amount');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `quote_currency` SET TAGS ('dbx_business_glossary_term' = 'Quote Currency Code');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `quote_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `rate_type` SET TAGS ('dbx_business_glossary_term' = 'Exchange Rate Type');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `rate_type` SET TAGS ('dbx_value_regex' = 'market|benchmark|fixed|negotiated');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Required Flag');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'physical_delivery|cash_settlement|netting');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `settlement_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Settlement Completion Timestamp');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `side` SET TAGS ('dbx_business_glossary_term' = 'Trade Side');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `side` SET TAGS ('dbx_value_regex' = 'buy|sell');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Spread in Basis Points (bps)');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `swap_far_leg_date` SET TAGS ('dbx_business_glossary_term' = 'Swap Far Leg Settlement Date');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `swap_near_leg_date` SET TAGS ('dbx_business_glossary_term' = 'Swap Near Leg Settlement Date');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `trade_date` SET TAGS ('dbx_business_glossary_term' = 'Trade Date');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `trade_purpose` SET TAGS ('dbx_business_glossary_term' = 'Trade Purpose');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `trade_purpose` SET TAGS ('dbx_value_regex' = 'hedge|investment_funding|repatriation|liquidity_management|settlement');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `trade_reference` SET TAGS ('dbx_business_glossary_term' = 'Trade Reference Number');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `trade_status` SET TAGS ('dbx_business_glossary_term' = 'Trade Status');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `trade_status` SET TAGS ('dbx_value_regex' = 'pending|confirmed|settled|cancelled|failed');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `trade_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Trade Execution Timestamp');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Transaction Type');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'spot|forward|swap|ndf');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `uti` SET TAGS ('dbx_business_glossary_term' = 'Unique Transaction Identifier (UTI)');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `value_date` SET TAGS ('dbx_business_glossary_term' = 'Value Date');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `venue_mic_code` SET TAGS ('dbx_business_glossary_term' = 'Market Identifier Code (MIC)');
ALTER TABLE `asset_management`.`trade`.`fx_trade` ALTER COLUMN `venue_mic_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}$');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` SET TAGS ('dbx_subdomain' = 'order_execution');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `otc_derivative_id` SET TAGS ('dbx_business_glossary_term' = 'Over-the-Counter (OTC) Derivative Identifier');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `blotter_id` SET TAGS ('dbx_business_glossary_term' = 'Trade Identifier');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `clearing_house_id` SET TAGS ('dbx_business_glossary_term' = 'Clearing House Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `csa_id` SET TAGS ('dbx_business_glossary_term' = 'Csa Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader Identifier');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `execution_id` SET TAGS ('dbx_business_glossary_term' = 'Trade Identifier');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `isda_master_id` SET TAGS ('dbx_business_glossary_term' = 'Isda Master Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `research_yield_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Research Yield Curve Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `trader_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader Identifier');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `booking_entity` SET TAGS ('dbx_business_glossary_term' = 'Booking Entity');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `clearing_status` SET TAGS ('dbx_business_glossary_term' = 'Clearing Status');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `clearing_status` SET TAGS ('dbx_value_regex' = 'cleared|bilateral|uncleared');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `collateral_currency` SET TAGS ('dbx_business_glossary_term' = 'Collateral Currency');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `collateral_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `collateral_posted` SET TAGS ('dbx_business_glossary_term' = 'Collateral Posted');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `collateral_received` SET TAGS ('dbx_business_glossary_term' = 'Collateral Received');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `confirmation_status` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Status');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `confirmation_status` SET TAGS ('dbx_value_regex' = 'pending|confirmed|disputed|cancelled');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `confirmation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Timestamp');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `csa_in_place` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) In Place');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_business_glossary_term' = 'Day Count Convention');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `day_count_convention` SET TAGS ('dbx_value_regex' = 'actual_360|actual_365|30_360|actual_actual');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `derivative_subtype` SET TAGS ('dbx_business_glossary_term' = 'Derivative Subtype');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `derivative_type` SET TAGS ('dbx_business_glossary_term' = 'Derivative Type');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `derivative_type` SET TAGS ('dbx_value_regex' = 'interest_rate_swap|credit_default_swap|total_return_swap|equity_swap|currency_swap|forward_rate_agreement');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `fixed_rate` SET TAGS ('dbx_business_glossary_term' = 'Fixed Rate');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `floating_rate_index` SET TAGS ('dbx_business_glossary_term' = 'Floating Rate Index');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `floating_rate_spread` SET TAGS ('dbx_business_glossary_term' = 'Floating Rate Spread');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `isda_master_agreement_date` SET TAGS ('dbx_business_glossary_term' = 'ISDA Master Agreement Date');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `mark_to_market_value` SET TAGS ('dbx_business_glossary_term' = 'Mark-to-Market (MTM) Value');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `mtm_currency` SET TAGS ('dbx_business_glossary_term' = 'Mark-to-Market (MTM) Currency');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `mtm_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `notional_amount` SET TAGS ('dbx_business_glossary_term' = 'Notional Amount');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `notional_currency` SET TAGS ('dbx_business_glossary_term' = 'Notional Currency');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `notional_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'cash|physical');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `trade_date` SET TAGS ('dbx_business_glossary_term' = 'Trade Date');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `trade_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Trade Reference Number');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `trade_status` SET TAGS ('dbx_business_glossary_term' = 'Trade Status');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `trade_status` SET TAGS ('dbx_value_regex' = 'pending|confirmed|settled|terminated|cancelled');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `trade_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Trade Timestamp');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `underlying_asset_class` SET TAGS ('dbx_business_glossary_term' = 'Underlying Asset Class');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `underlying_asset_class` SET TAGS ('dbx_value_regex' = 'interest_rate|credit|equity|foreign_exchange|commodity');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `underlying_identifier` SET TAGS ('dbx_business_glossary_term' = 'Underlying Identifier');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `underlying_name` SET TAGS ('dbx_business_glossary_term' = 'Underlying Name');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `unique_product_identifier` SET TAGS ('dbx_business_glossary_term' = 'Unique Product Identifier (UPI)');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `unique_trade_identifier` SET TAGS ('dbx_business_glossary_term' = 'Unique Trade Identifier (UTI)');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ALTER COLUMN `valuation_source` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` SET TAGS ('dbx_subdomain' = 'settlement_clearing');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `ccp_clearing_id` SET TAGS ('dbx_business_glossary_term' = 'Central Counterparty (CCP) Clearing ID');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Account ID');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `ccp_membership_id` SET TAGS ('dbx_business_glossary_term' = 'Ccp Membership Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_house_id` SET TAGS ('dbx_business_glossary_term' = 'Clearing House Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `execution_id` SET TAGS ('dbx_business_glossary_term' = 'Trade ID');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument ID');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `netting_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Netting Set ID');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'equity|fixed_income|fx|commodity|credit|interest_rate_derivative');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `backloading_flag` SET TAGS ('dbx_business_glossary_term' = 'Backloading Flag');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `ccp_lei` SET TAGS ('dbx_business_glossary_term' = 'Central Counterparty (CCP) Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `ccp_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `ccp_name` SET TAGS ('dbx_business_glossary_term' = 'Central Counterparty (CCP) Name');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `ccp_name` SET TAGS ('dbx_value_regex' = 'LCH|CME Clearing|Eurex Clearing|ICE Clear|JSCC|OCC');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `cleared_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Cleared Currency Code');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `cleared_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `cleared_notional_amount` SET TAGS ('dbx_business_glossary_term' = 'Cleared Notional Amount');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `cleared_quantity` SET TAGS ('dbx_business_glossary_term' = 'Cleared Quantity');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_acceptance_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Clearing Acceptance Timestamp');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_account_number` SET TAGS ('dbx_business_glossary_term' = 'Clearing Account Number');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Clearing Fee Amount');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_fee_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Clearing Fee Currency Code');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_fee_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_member_lei` SET TAGS ('dbx_business_glossary_term' = 'Clearing Member Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_member_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_member_name` SET TAGS ('dbx_business_glossary_term' = 'Clearing Member Name');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_member_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_member_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_obligation_flag` SET TAGS ('dbx_business_glossary_term' = 'Clearing Obligation Flag');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Clearing Reference Number');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_rejection_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Clearing Rejection Timestamp');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_status` SET TAGS ('dbx_business_glossary_term' = 'Clearing Status');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_status` SET TAGS ('dbx_value_regex' = 'submitted|accepted|cleared|rejected|pending|failed');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `clearing_submission_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Clearing Submission Timestamp');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `collateral_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Collateral Currency Code');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `collateral_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'cash|securities|government_bonds|corporate_bonds|equity');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `collateral_value` SET TAGS ('dbx_business_glossary_term' = 'Collateral Value');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `compression_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Compression Eligible Flag');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `default_fund_contribution` SET TAGS ('dbx_business_glossary_term' = 'Default Fund Contribution');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `haircut_percentage` SET TAGS ('dbx_business_glossary_term' = 'Haircut Percentage');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `initial_margin_amount` SET TAGS ('dbx_business_glossary_term' = 'Initial Margin (IM) Amount');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `initial_margin_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Initial Margin (IM) Currency Code');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `initial_margin_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `product_type` SET TAGS ('dbx_business_glossary_term' = 'Product Type');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `rejection_code` SET TAGS ('dbx_business_glossary_term' = 'Rejection Code');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `trade_date` SET TAGS ('dbx_business_glossary_term' = 'Trade Date');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `usi` SET TAGS ('dbx_business_glossary_term' = 'Unique Swap Identifier (USI)');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `uti` SET TAGS ('dbx_business_glossary_term' = 'Unique Trade Identifier (UTI)');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `variation_margin_amount` SET TAGS ('dbx_business_glossary_term' = 'Variation Margin (VM) Amount');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `variation_margin_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Variation Margin (VM) Currency Code');
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ALTER COLUMN `variation_margin_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`execution_venue` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`trade`.`execution_venue` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`execution_venue` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`execution_venue` SET TAGS ('dbx_subdomain' = 'order_execution');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `execution_venue_id` SET TAGS ('dbx_business_glossary_term' = 'Execution Venue Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `approval_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Expiry Date');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Approved Date');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `asset_classes_supported` SET TAGS ('dbx_business_glossary_term' = 'Asset Classes Supported');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `average_fill_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Average Fill Rate Percentage');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `average_latency_ms` SET TAGS ('dbx_business_glossary_term' = 'Average Latency Milliseconds (ms)');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `best_execution_eligible` SET TAGS ('dbx_business_glossary_term' = 'Best Execution Eligible');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `clearing_house` SET TAGS ('dbx_business_glossary_term' = 'Clearing House');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `connectivity_protocol` SET TAGS ('dbx_business_glossary_term' = 'Connectivity Protocol');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `contact_email` SET TAGS ('dbx_business_glossary_term' = 'Contact Email Address');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Contact Phone Number');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `execution_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Execution Quality Score');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `maximum_order_size` SET TAGS ('dbx_business_glossary_term' = 'Maximum Order Size');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `mic_code` SET TAGS ('dbx_business_glossary_term' = 'Market Identifier Code (MIC)');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `mic_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}$');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `minimum_order_size` SET TAGS ('dbx_business_glossary_term' = 'Minimum Order Size');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Modified By');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `operating_mic` SET TAGS ('dbx_business_glossary_term' = 'Operating Market Identifier Code (MIC)');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `operating_mic` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}$');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `post_trade_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Post-Trade Reporting Required');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `pre_trade_transparency_waiver` SET TAGS ('dbx_business_glossary_term' = 'Pre-Trade Transparency Waiver');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `regulatory_authority` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_business_glossary_term' = 'Settlement Cycle');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_value_regex' = '^T+[0-9]$');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `supports_algorithmic_trading` SET TAGS ('dbx_business_glossary_term' = 'Supports Algorithmic Trading');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `supports_dark_pool` SET TAGS ('dbx_business_glossary_term' = 'Supports Dark Pool');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `tick_size_regime` SET TAGS ('dbx_business_glossary_term' = 'Tick Size Regime');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `time_zone` SET TAGS ('dbx_business_glossary_term' = 'Time Zone');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `trading_currency` SET TAGS ('dbx_business_glossary_term' = 'Trading Currency');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `trading_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `trading_hours` SET TAGS ('dbx_business_glossary_term' = 'Trading Hours');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `venue_name` SET TAGS ('dbx_business_glossary_term' = 'Venue Name');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `venue_status` SET TAGS ('dbx_business_glossary_term' = 'Venue Status');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `venue_status` SET TAGS ('dbx_value_regex' = 'active|suspended|inactive|pending_approval|decommissioned');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `venue_type` SET TAGS ('dbx_business_glossary_term' = 'Venue Type');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `venue_type` SET TAGS ('dbx_value_regex' = 'regulated_market|mtf|otf|systematic_internaliser|otc_bilateral|apa');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `website_url` SET TAGS ('dbx_business_glossary_term' = 'Website Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`trade`.`execution_venue` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`trade`.`amendment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`trade`.`amendment` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`amendment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`amendment` SET TAGS ('dbx_subdomain' = 'order_execution');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `amendment_approved_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `amendment_approved_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `amendment_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Requested By User Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `amendment_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `blotter_id` SET TAGS ('dbx_business_glossary_term' = 'Trade Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Requested By User Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `execution_id` SET TAGS ('dbx_business_glossary_term' = 'Trade Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `supersedes_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Supersedes Amendment Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `amended_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Amended Commission Amount');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `amended_executed_price` SET TAGS ('dbx_business_glossary_term' = 'Amended Executed Price');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `amended_executed_quantity` SET TAGS ('dbx_business_glossary_term' = 'Amended Executed Quantity');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `amended_field_name` SET TAGS ('dbx_business_glossary_term' = 'Amended Field Name');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `amended_net_settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Amended Net Settlement Amount');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `amended_settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Amended Settlement Date');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `amended_value` SET TAGS ('dbx_business_glossary_term' = 'Amended Value');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_business_glossary_term' = 'Amendment Status');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|applied|cancelled');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_business_glossary_term' = 'Amendment Type');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_value_regex' = 'price_correction|quantity_adjustment|settlement_date_change|counterparty_correction|commission_adjustment|venue_correction');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `applied_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Applied Timestamp');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `audit_trail_reference` SET TAGS ('dbx_business_glossary_term' = 'Audit Trail Reference');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `counterparty_notification_status` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Notification Status');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `counterparty_notification_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|sent|acknowledged|failed');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `counterparty_notification_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Notification Timestamp');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `impact_on_accounting` SET TAGS ('dbx_business_glossary_term' = 'Impact on Accounting Flag');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `impact_on_settlement` SET TAGS ('dbx_business_glossary_term' = 'Impact on Settlement Flag');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Amendment Notes');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `original_commission_amount` SET TAGS ('dbx_business_glossary_term' = 'Original Commission Amount');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `original_executed_price` SET TAGS ('dbx_business_glossary_term' = 'Original Executed Price');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `original_executed_quantity` SET TAGS ('dbx_business_glossary_term' = 'Original Executed Quantity');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `original_net_settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Original Net Settlement Amount');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `original_settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Original Settlement Date');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `original_value` SET TAGS ('dbx_business_glossary_term' = 'Original Value');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `reason_code` SET TAGS ('dbx_business_glossary_term' = 'Amendment Reason Code');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `reason_code` SET TAGS ('dbx_value_regex' = 'data_entry_error|broker_error|counterparty_error|system_error|regulatory_correction|client_instruction');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `reason_description` SET TAGS ('dbx_business_glossary_term' = 'Amendment Reason Description');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `reference` SET TAGS ('dbx_business_glossary_term' = 'Amendment Reference Number');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `regulatory_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Required Flag');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `regulatory_reporting_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Status');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `regulatory_reporting_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|acknowledged|failed');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `regulatory_reporting_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Timestamp');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `timestamp` SET TAGS ('dbx_business_glossary_term' = 'Amendment Timestamp');
ALTER TABLE `asset_management`.`trade`.`amendment` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`trade`.`status_history` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`trade`.`status_history` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`status_history` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`status_history` SET TAGS ('dbx_subdomain' = 'order_execution');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `status_history_id` SET TAGS ('dbx_business_glossary_term' = 'Status History Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `broker_id` SET TAGS ('dbx_business_glossary_term' = 'Broker Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `execution_id` SET TAGS ('dbx_business_glossary_term' = 'Trade Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `order_id` SET TAGS ('dbx_business_glossary_term' = 'Order Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `triggering_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Triggering User Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `triggering_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `triggering_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `allocation_status` SET TAGS ('dbx_business_glossary_term' = 'Allocation Status');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `allocation_status` SET TAGS ('dbx_value_regex' = 'pending|allocated|partially_allocated|unallocated');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `amendment_flag` SET TAGS ('dbx_business_glossary_term' = 'Amendment Flag');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `cancellation_flag` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Flag');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `clearing_house` SET TAGS ('dbx_business_glossary_term' = 'Clearing House');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `clearing_status` SET TAGS ('dbx_business_glossary_term' = 'Clearing Status');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `clearing_status` SET TAGS ('dbx_value_regex' = 'pending|cleared|rejected|failed');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `confirmation_status` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Status');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `confirmation_status` SET TAGS ('dbx_value_regex' = 'pending|confirmed|unconfirmed|disputed');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `correction_flag` SET TAGS ('dbx_business_glossary_term' = 'Correction Flag');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{9}$');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `emir_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'European Market Infrastructure Regulation (EMIR) Reporting Flag');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `error_code` SET TAGS ('dbx_business_glossary_term' = 'Error Code');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `error_message` SET TAGS ('dbx_business_glossary_term' = 'Error Message');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `execution_venue` SET TAGS ('dbx_business_glossary_term' = 'Execution Venue');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `price` SET TAGS ('dbx_business_glossary_term' = 'Price');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Quantity');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{7}$');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Sequence Number');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `settlement_status` SET TAGS ('dbx_business_glossary_term' = 'Settlement Status');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `settlement_status` SET TAGS ('dbx_value_regex' = 'pending|matched|affirmed|settled|failed|partial');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `status_from` SET TAGS ('dbx_business_glossary_term' = 'Status From');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `status_to` SET TAGS ('dbx_business_glossary_term' = 'Status To');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `trade_value` SET TAGS ('dbx_business_glossary_term' = 'Trade Value');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `transition_event` SET TAGS ('dbx_business_glossary_term' = 'Transition Event');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `transition_reason` SET TAGS ('dbx_business_glossary_term' = 'Transition Reason');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `transition_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Transition Reason Code');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `transition_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Transition Timestamp');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `triggering_system` SET TAGS ('dbx_business_glossary_term' = 'Triggering System');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `triggering_user` SET TAGS ('dbx_business_glossary_term' = 'Triggering User');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `triggering_user` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `venue_mic_code` SET TAGS ('dbx_business_glossary_term' = 'Market Identifier Code (MIC)');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `venue_mic_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}$');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`trade`.`status_history` ALTER COLUMN `created_by` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` SET TAGS ('dbx_subdomain' = 'counterparty_cost');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `transaction_cost_id` SET TAGS ('dbx_business_glossary_term' = 'Transaction Cost Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `broker_id` SET TAGS ('dbx_business_glossary_term' = 'Broker Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `execution_id` SET TAGS ('dbx_business_glossary_term' = 'Execution Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Financial Instrument Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `market_data_snapshot_id` SET TAGS ('dbx_business_glossary_term' = 'Market Data Snapshot Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `order_id` SET TAGS ('dbx_business_glossary_term' = 'Order Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'equity|fixed_income|fx|derivative|commodity|real_estate');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `benchmark_price` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Price');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `benchmark_type` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Price Type');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `benchmark_type` SET TAGS ('dbx_value_regex' = 'arrival|vwap|twap|close|open|mid');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `clearing_fee` SET TAGS ('dbx_business_glossary_term' = 'Clearing Fee Amount');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `commission_type` SET TAGS ('dbx_business_glossary_term' = 'Commission Type Classification');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `commission_type` SET TAGS ('dbx_value_regex' = 'explicit|soft_dollar|research_payment|bundled|unbundled');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Transaction Cost Amount');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `cost_bps` SET TAGS ('dbx_business_glossary_term' = 'Transaction Cost in Basis Points (bps)');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `cost_calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Cost Calculation Timestamp');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `cost_category` SET TAGS ('dbx_business_glossary_term' = 'Transaction Cost Category');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `cost_category` SET TAGS ('dbx_value_regex' = 'explicit|implicit|market_impact|timing|opportunity');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `cost_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Transaction Cost Currency Code');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `cost_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `cost_reference` SET TAGS ('dbx_business_glossary_term' = 'Transaction Cost Reference Number');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `cost_status` SET TAGS ('dbx_business_glossary_term' = 'Transaction Cost Status');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `cost_status` SET TAGS ('dbx_value_regex' = 'estimated|confirmed|invoiced|paid|disputed|adjusted');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `cost_type` SET TAGS ('dbx_business_glossary_term' = 'Transaction Cost Type');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[0-9A-Z]{5}[0-9]$');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `exchange_fee` SET TAGS ('dbx_business_glossary_term' = 'Exchange Fee Amount');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `execution_price` SET TAGS ('dbx_business_glossary_term' = 'Execution Price');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `execution_venue` SET TAGS ('dbx_business_glossary_term' = 'Execution Venue Name');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `fx_conversion_cost` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Conversion Cost');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `invoice_reference` SET TAGS ('dbx_business_glossary_term' = 'Invoice Reference Number');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `market_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Market Impact Cost Amount');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Transaction Cost Notes');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `opportunity_cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Cost Amount');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Cost Payment Date');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `payment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Cost Payment Due Date');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Trade Quantity');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `research_payment_account_flag` SET TAGS ('dbx_business_glossary_term' = 'Research Payment Account (RPA) Flag');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9BCDFGHJKLMNPQRSTVWXYZ]{6}[0-9]$');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `settlement_fee` SET TAGS ('dbx_business_glossary_term' = 'Settlement Fee Amount');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `side` SET TAGS ('dbx_business_glossary_term' = 'Trade Side');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `side` SET TAGS ('dbx_value_regex' = 'buy|sell|short_sell');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `slippage_amount` SET TAGS ('dbx_business_glossary_term' = 'Slippage Cost Amount');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `soft_dollar_allocation` SET TAGS ('dbx_business_glossary_term' = 'Soft Dollar Research Credit Allocation');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `spread_amount` SET TAGS ('dbx_business_glossary_term' = 'Bid-Ask Spread Amount');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Transaction Tax Amount');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `timing_cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Timing Cost Amount');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `trade_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Trade Currency Code');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `trade_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `trade_date` SET TAGS ('dbx_business_glossary_term' = 'Trade Date');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `trade_notional_value` SET TAGS ('dbx_business_glossary_term' = 'Trade Notional Value');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `venue_mic_code` SET TAGS ('dbx_business_glossary_term' = 'Market Identifier Code (MIC)');
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ALTER COLUMN `venue_mic_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}$');
ALTER TABLE `asset_management`.`trade`.`algo_order` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`trade`.`algo_order` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`algo_order` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`algo_order` SET TAGS ('dbx_subdomain' = 'order_execution');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `algo_order_id` SET TAGS ('dbx_business_glossary_term' = 'Algorithmic Order Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `broker_id` SET TAGS ('dbx_business_glossary_term' = 'Broker Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `parent_order_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Order Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `trader_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `algo_order_status` SET TAGS ('dbx_business_glossary_term' = 'Algorithmic Order Status');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `algo_provider` SET TAGS ('dbx_business_glossary_term' = 'Algorithmic Provider Name');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `algo_strategy_type` SET TAGS ('dbx_business_glossary_term' = 'Algorithmic Strategy Type');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `algo_strategy_type` SET TAGS ('dbx_value_regex' = 'VWAP|TWAP|POV|Implementation Shortfall|Arrival Price|Dark Aggregator');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `algo_version` SET TAGS ('dbx_business_glossary_term' = 'Algorithm Version');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `average_execution_price` SET TAGS ('dbx_business_glossary_term' = 'Average Execution Price');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `benchmark_price` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Price');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `benchmark_type` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Type');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `benchmark_type` SET TAGS ('dbx_value_regex' = 'Arrival Price|Close Price|Open Price|VWAP|TWAP|Mid Price');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `child_order_count` SET TAGS ('dbx_business_glossary_term' = 'Child Order Count');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `dark_pool_participation_flag` SET TAGS ('dbx_business_glossary_term' = 'Dark Pool Participation Flag');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `end_time` SET TAGS ('dbx_business_glossary_term' = 'Execution End Time');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `end_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Execution End Timestamp');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `executed_quantity` SET TAGS ('dbx_business_glossary_term' = 'Executed Quantity');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `execution_style` SET TAGS ('dbx_business_glossary_term' = 'Execution Style');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `execution_style` SET TAGS ('dbx_value_regex' = 'Passive|Neutral|Aggressive');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `implementation_shortfall_bps` SET TAGS ('dbx_business_glossary_term' = 'Implementation Shortfall (Basis Points - bps)');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `limit_price` SET TAGS ('dbx_business_glossary_term' = 'Limit Price');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `max_participation_rate` SET TAGS ('dbx_business_glossary_term' = 'Maximum Participation Rate');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `max_slice_quantity` SET TAGS ('dbx_business_glossary_term' = 'Maximum Slice Quantity');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `min_fill_quantity` SET TAGS ('dbx_business_glossary_term' = 'Minimum Fill Quantity');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Record Modified By User');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Execution Notes');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `notional_value` SET TAGS ('dbx_business_glossary_term' = 'Notional Value');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `order_quantity` SET TAGS ('dbx_business_glossary_term' = 'Order Quantity');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `participation_rate_target` SET TAGS ('dbx_business_glossary_term' = 'Participation Rate Target (Percentage of Volume - POV)');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `price_limit_offset_bps` SET TAGS ('dbx_business_glossary_term' = 'Price Limit Offset (Basis Points - bps)');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `reference` SET TAGS ('dbx_business_glossary_term' = 'Algorithmic Order Reference Number');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `remaining_quantity` SET TAGS ('dbx_business_glossary_term' = 'Remaining Quantity');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `side` SET TAGS ('dbx_business_glossary_term' = 'Order Side');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `side` SET TAGS ('dbx_value_regex' = 'Buy|Sell|Short Sell');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `slippage_bps` SET TAGS ('dbx_business_glossary_term' = 'Slippage (Basis Points - bps)');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `start_time` SET TAGS ('dbx_business_glossary_term' = 'Execution Start Time');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `start_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Execution Start Timestamp');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `submission_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Submission Timestamp');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `urgency_level` SET TAGS ('dbx_business_glossary_term' = 'Execution Urgency Level');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `urgency_level` SET TAGS ('dbx_value_regex' = 'Low|Medium|High|Critical');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `venue_restriction_list` SET TAGS ('dbx_business_glossary_term' = 'Venue Restriction List');
ALTER TABLE `asset_management`.`trade`.`algo_order` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By User');
ALTER TABLE `asset_management`.`trade`.`custody_account` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`trade`.`custody_account` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`custody_account` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`custody_account` SET TAGS ('dbx_subdomain' = 'settlement_clearing');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `custody_account_id` SET TAGS ('dbx_business_glossary_term' = 'Custody Account Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Id (Foreign Key)');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_closure_date` SET TAGS ('dbx_business_glossary_term' = 'Account Closure Date');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_currency` SET TAGS ('dbx_business_glossary_term' = 'Account Base Currency');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_manager_email` SET TAGS ('dbx_business_glossary_term' = 'Account Manager Email Address');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_manager_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_manager_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_manager_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_manager_name` SET TAGS ('dbx_business_glossary_term' = 'Account Manager Name');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_manager_phone` SET TAGS ('dbx_business_glossary_term' = 'Account Manager Phone Number');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_manager_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_manager_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_name` SET TAGS ('dbx_business_glossary_term' = 'Custody Account Name');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_number` SET TAGS ('dbx_business_glossary_term' = 'Custody Account Number');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_opening_date` SET TAGS ('dbx_business_glossary_term' = 'Account Opening Date');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_status` SET TAGS ('dbx_business_glossary_term' = 'Custody Account Status');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|closed|pending_opening');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_type` SET TAGS ('dbx_business_glossary_term' = 'Custody Account Type');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `account_type` SET TAGS ('dbx_value_regex' = 'cash|securities|omnibus|segregated|nominee|direct');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `annual_custody_fee_bps` SET TAGS ('dbx_business_glossary_term' = 'Annual Custody Fee in Basis Points (bps)');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `annual_custody_fee_bps` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'equities|fixed_income|alternatives|multi_asset|cash|derivatives');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `beneficial_owner_name` SET TAGS ('dbx_business_glossary_term' = 'Beneficial Owner Name');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `beneficial_owner_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `cash_sweep_account_flag` SET TAGS ('dbx_business_glossary_term' = 'Cash Sweep Account Flag');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `collateral_account_flag` SET TAGS ('dbx_business_glossary_term' = 'Collateral Account Flag');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `custodian_bic` SET TAGS ('dbx_business_glossary_term' = 'Custodian Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `custodian_bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `custodian_lei` SET TAGS ('dbx_business_glossary_term' = 'Custodian Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `custodian_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `custody_fee_schedule_code` SET TAGS ('dbx_business_glossary_term' = 'Custody Fee Schedule Code');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `custody_fee_schedule_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `depository_code` SET TAGS ('dbx_business_glossary_term' = 'Central Securities Depository Code');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `depository_name` SET TAGS ('dbx_business_glossary_term' = 'Central Securities Depository Name');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `emir_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'European Market Infrastructure Regulation (EMIR) Reporting Flag');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `last_reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Reconciliation Date');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `last_statement_date` SET TAGS ('dbx_business_glossary_term' = 'Last Statement Date');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `last_valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Valuation Date');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Record Modified By User');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `nominee_name` SET TAGS ('dbx_business_glossary_term' = 'Nominee Name');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `omnibus_account_flag` SET TAGS ('dbx_business_glossary_term' = 'Omnibus Account Flag');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `place_of_settlement` SET TAGS ('dbx_business_glossary_term' = 'Place of Settlement');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `place_of_settlement` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `reconciliation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Frequency');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `reconciliation_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `regulatory_classification` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Classification');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `regulatory_classification` SET TAGS ('dbx_value_regex' = 'institutional|retail|professional|eligible_counterparty');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `safekeeping_account_number` SET TAGS ('dbx_business_glossary_term' = 'Safekeeping Account Number');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `safekeeping_account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `safekeeping_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `securities_lending_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Securities Lending Eligible Flag');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `segregated_account_flag` SET TAGS ('dbx_business_glossary_term' = 'Segregated Account Flag');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `service_level_agreement_tier` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Tier');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `service_level_agreement_tier` SET TAGS ('dbx_value_regex' = 'standard|premium|institutional|bespoke');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'dvp|rvp|fop|dap|free');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Classification');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_value_regex' = 'article_6|article_8|article_9|not_applicable');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `special_instructions` SET TAGS ('dbx_business_glossary_term' = 'Special Instructions');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number (TIN)');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `tax_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Tax Jurisdiction');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `tax_jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `tax_status` SET TAGS ('dbx_business_glossary_term' = 'Tax Status');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `tax_status` SET TAGS ('dbx_value_regex' = 'taxable|tax_exempt|tax_deferred|qualified');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `transaction_fee_per_trade` SET TAGS ('dbx_business_glossary_term' = 'Transaction Fee Per Trade');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `transaction_fee_per_trade` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`custody_account` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By User');
ALTER TABLE `asset_management`.`trade`.`instrument_exclusion` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`trade`.`instrument_exclusion` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`instrument_exclusion` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`instrument_exclusion` SET TAGS ('dbx_subdomain' = 'counterparty_cost');
ALTER TABLE `asset_management`.`trade`.`instrument_exclusion` SET TAGS ('dbx_association_edges' = 'esg.exclusion_list,trade.instrument');
ALTER TABLE `asset_management`.`trade`.`instrument_exclusion` ALTER COLUMN `instrument_exclusion_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Exclusion Identifier');
ALTER TABLE `asset_management`.`trade`.`instrument_exclusion` ALTER COLUMN `divestment_deadline` SET TAGS ('dbx_business_glossary_term' = 'Divestment Deadline');
ALTER TABLE `asset_management`.`trade`.`instrument_exclusion` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Effective Date');
ALTER TABLE `asset_management`.`trade`.`instrument_exclusion` ALTER COLUMN `instrument_exclusion_status` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Application Status');
ALTER TABLE `asset_management`.`trade`.`instrument_exclusion` ALTER COLUMN `reason` SET TAGS ('dbx_business_glossary_term' = 'Instrument-Specific Exclusion Reason');
ALTER TABLE `asset_management`.`trade`.`instrument_exclusion` ALTER COLUMN `revenue_threshold_pct` SET TAGS ('dbx_business_glossary_term' = 'Revenue Threshold Percentage');
ALTER TABLE `asset_management`.`trade`.`netting_set_inclusion` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`trade`.`netting_set_inclusion` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`netting_set_inclusion` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`netting_set_inclusion` SET TAGS ('dbx_subdomain' = 'settlement_clearing');
ALTER TABLE `asset_management`.`trade`.`netting_set_inclusion` SET TAGS ('dbx_association_edges' = 'trade.otc_derivative,collateral.netting_agreement');
ALTER TABLE `asset_management`.`trade`.`netting_set_inclusion` ALTER COLUMN `netting_set_inclusion_id` SET TAGS ('dbx_business_glossary_term' = 'Netting Set Inclusion Identifier');
ALTER TABLE `asset_management`.`trade`.`netting_set_inclusion` ALTER COLUMN `eligibility_status` SET TAGS ('dbx_business_glossary_term' = 'Netting Eligibility Status');
ALTER TABLE `asset_management`.`trade`.`netting_set_inclusion` ALTER COLUMN `exclusion_date` SET TAGS ('dbx_business_glossary_term' = 'Netting Set Exclusion Date');
ALTER TABLE `asset_management`.`trade`.`netting_set_inclusion` ALTER COLUMN `exclusion_reason` SET TAGS ('dbx_business_glossary_term' = 'Netting Exclusion Reason');
ALTER TABLE `asset_management`.`trade`.`netting_set_inclusion` ALTER COLUMN `exposure_contribution` SET TAGS ('dbx_business_glossary_term' = 'Exposure Contribution Amount');
ALTER TABLE `asset_management`.`trade`.`netting_set_inclusion` ALTER COLUMN `inclusion_date` SET TAGS ('dbx_business_glossary_term' = 'Netting Set Inclusion Date');
ALTER TABLE `asset_management`.`trade`.`trade_check` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`trade`.`trade_check` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`trade_check` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`trade_check` SET TAGS ('dbx_subdomain' = 'counterparty_cost');
ALTER TABLE `asset_management`.`trade`.`trade_check` SET TAGS ('dbx_association_edges' = 'trade.order,compliance.rule');
ALTER TABLE `asset_management`.`trade`.`trade_check` ALTER COLUMN `override_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Override Approver');
ALTER TABLE `asset_management`.`trade`.`trade_check` ALTER COLUMN `override_reason` SET TAGS ('dbx_business_glossary_term' = 'Override Reason');
ALTER TABLE `asset_management`.`trade`.`trade_check` ALTER COLUMN `result` SET TAGS ('dbx_business_glossary_term' = 'Check Result');
ALTER TABLE `asset_management`.`trade`.`trade_check` ALTER COLUMN `timestamp` SET TAGS ('dbx_business_glossary_term' = 'Check Timestamp');
ALTER TABLE `asset_management`.`trade`.`custodian` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`trade`.`custodian` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`custodian` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`custodian` SET TAGS ('dbx_subdomain' = 'settlement_clearing');
ALTER TABLE `asset_management`.`trade`.`custodian` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Identifier');
ALTER TABLE `asset_management`.`trade`.`custodian` ALTER COLUMN `annual_custody_fee_bps` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`custodian` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`custodian` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`trade`.`custodian` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`custodian` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`trade`.`custodian` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`custodian` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`trade`.`custodian` ALTER COLUMN `registered_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`custodian` ALTER COLUMN `registered_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`trade`.`custodian` ALTER COLUMN `transaction_fee_usd` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`allocation_group` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`trade`.`allocation_group` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`allocation_group` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`allocation_group` SET TAGS ('dbx_subdomain' = 'order_execution');
ALTER TABLE `asset_management`.`trade`.`allocation_group` ALTER COLUMN `allocation_group_id` SET TAGS ('dbx_business_glossary_term' = 'Allocation Group Identifier');
ALTER TABLE `asset_management`.`trade`.`allocation_group` ALTER COLUMN `total_aum` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`clearing_house` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`trade`.`clearing_house` SET TAGS ('dbx_domain' = 'trade');
ALTER TABLE `asset_management`.`trade`.`clearing_house` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`trade`.`clearing_house` SET TAGS ('dbx_subdomain' = 'settlement_clearing');
ALTER TABLE `asset_management`.`trade`.`clearing_house` ALTER COLUMN `clearing_house_id` SET TAGS ('dbx_business_glossary_term' = 'Clearing House Identifier');
ALTER TABLE `asset_management`.`trade`.`clearing_house` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`clearing_house` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`trade`.`clearing_house` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`clearing_house` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`trade`.`clearing_house` ALTER COLUMN `registered_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`trade`.`clearing_house` ALTER COLUMN `registered_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`trade`.`clearing_house` ALTER COLUMN `skin_in_the_game_amount` SET TAGS ('dbx_confidential' = 'true');
