-- Schema for Domain: equity | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:26

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`equity` COMMENT 'Domain governing public equities investment operations including listed equity positions, equity research coverage, sector analysis, stock selection, and corporate actions.';

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`equity`.`listed_security` (
    `listed_security_id` BIGINT COMMENT 'Unique identifier for the listed equity security. Primary key.',
    `bloomberg_ticker` STRING COMMENT 'Bloomberg-specific ticker identifier including exchange suffix.',
    `coverage_analyst` STRING COMMENT 'Name of the internal equity research analyst assigned to cover this security.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this security master record was first created in the system.',
    `cusip` STRING COMMENT '9-character alphanumeric code identifying North American securities.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `data_source` STRING COMMENT 'Name of the primary external data provider or system of record for this security master data.',
    `delisting_date` DATE COMMENT 'Date on which the security was delisted from the primary exchange, if applicable.',
    `dividend_frequency` STRING COMMENT 'Frequency with which the issuer typically pays dividends to shareholders.. Valid values are `annual|semi_annual|quarterly|monthly|irregular|none`',
    `esg_rating` STRING COMMENT 'Current ESG rating assigned by the funds primary ESG rating provider.',
    `esg_rating_date` DATE COMMENT 'Date as of which the ESG rating is current.',
    `exchange_mic` STRING COMMENT 'ISO 10383 4-character code identifying the primary exchange.. Valid values are `^[A-Z]{4}$`',
    `factset_entity_code` STRING COMMENT 'FactSet permanent identifier for the security entity.',
    `gics_industry` STRING COMMENT 'GICS level 3 industry classification of the issuer.',
    `gics_industry_group` STRING COMMENT 'GICS level 2 industry group classification of the issuer.',
    `gics_sector` STRING COMMENT 'GICS level 1 sector classification of the issuer.',
    `gics_sub_industry` STRING COMMENT 'GICS level 4 sub-industry classification of the issuer.',
    `investment_restriction_flag` BOOLEAN COMMENT 'Indicates whether the security is subject to internal investment restrictions or exclusions.',
    `isin` STRING COMMENT 'ISO 6166 12-character alphanumeric code uniquely identifying the security globally.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `issuer_lei` STRING COMMENT 'ISO 17442 20-character alphanumeric code uniquely identifying the issuing legal entity.. Valid values are `^[A-Z0-9]{20}$`',
    `issuer_name` STRING COMMENT 'Legal name of the corporation or entity that issued the equity security.',
    `listing_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the primary exchange jurisdiction.. Valid values are `^[A-Z]{3}$`',
    `listing_date` DATE COMMENT 'Date on which the security was first listed on the primary exchange.',
    `listing_status` STRING COMMENT 'Current trading and listing status of the security on the primary exchange.. Valid values are `active|suspended|delisted|halted`',
    `lot_size` BIGINT COMMENT 'Minimum trading unit or board lot size required by the exchange for this security.',
    `market_cap_date` DATE COMMENT 'Date as of which the market capitalization is calculated.',
    `market_capitalization` DECIMAL(20,2) COMMENT 'Total market value of outstanding shares, calculated as shares outstanding multiplied by current market price, in trading currency.',
    `msci_constituent_flag` BOOLEAN COMMENT 'Indicates whether the security is a constituent of any MSCI index.',
    `par_value` DECIMAL(18,4) COMMENT 'Nominal or face value per share as stated in the corporate charter, in the issuers reporting currency.',
    `par_value_currency` STRING COMMENT 'ISO 4217 3-letter currency code for the par value denomination.. Valid values are `^[A-Z]{3}$`',
    `price_multiplier` DECIMAL(10,4) COMMENT 'Multiplier applied to quoted price to determine actual contract value, typically 1.0 for equities.',
    `primary_exchange` STRING COMMENT 'Name of the primary stock exchange where the security is listed and primarily traded.',
    `research_rating` STRING COMMENT 'Internal research teams investment recommendation rating for the security.. Valid values are `buy|overweight|hold|underweight|sell`',
    `research_rating_date` DATE COMMENT 'Date on which the current research rating was assigned.',
    `restriction_reason` STRING COMMENT 'Explanation of why the security is restricted, if applicable.',
    `reuters_ric` STRING COMMENT 'Reuters-specific instrument identifier code.',
    `security_name` STRING COMMENT 'Full legal name of the equity security as registered with the issuer and exchange.',
    `security_type` STRING COMMENT 'Classification of the equity instrument type.. Valid values are `common_stock|preferred_stock|adr|gdr|reit|etf`',
    `sedol` STRING COMMENT '7-character alphanumeric code identifying securities traded on the London Stock Exchange and other UK exchanges.. Valid values are `^[0-9A-Z]{7}$`',
    `share_class` STRING COMMENT 'Designation of the share class (e.g., Class A, Class B, Ordinary) indicating voting rights and dividend entitlements.',
    `shares_outstanding` BIGINT COMMENT 'Total number of shares currently issued and outstanding as reported by the issuer.',
    `shares_outstanding_date` DATE COMMENT 'Date as of which the shares outstanding figure is accurate.',
    `ticker_symbol` STRING COMMENT 'Exchange-specific trading symbol used to identify the security on the listing exchange.',
    `trading_currency` STRING COMMENT 'ISO 4217 3-letter currency code in which the security is quoted and traded.. Valid values are `^[A-Z]{3}$`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this security master record was last modified.',
    `voting_rights` STRING COMMENT 'Voting rights associated with this share class.. Valid values are `full|limited|none|variable`',
    CONSTRAINT pk_listed_security PRIMARY KEY(`listed_security_id`)
) COMMENT 'Equity security master data for all exchange-traded equity instruments held or covered by the fund. Serves as the SSOT for equity instrument identity, capturing ISIN, CUSIP, SEDOL, ticker symbol, exchange listing, share class, par value, shares';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`equity_position` (
    `equity_position_id` BIGINT COMMENT 'Unique identifier for the equity position record in the Investment Book of Record (IBOR).',
    `custody_account_id` BIGINT COMMENT 'Foreign key linking to trade.custody_account. Business justification: Position custody mapping – tracks which custody account holds each position for reporting.',
    `instrument_id` BIGINT COMMENT 'Foreign key linking to trade.instrument. Business justification: Position‑to‑instrument mapping – aligns equity positions with the trade‑domain instrument for cross‑domain analytics.',
    `listed_security_id` BIGINT COMMENT 'Reference to the equity security master record for this position.',
    `manager_mandate_id` BIGINT COMMENT 'Foreign key linking to manager.manager_mandate. Business justification: Position-level reporting requires linking each equity position to the manager mandate that owns the portfolio, enabling mandate-level performance attribution.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio holding this equity position.',
    `risk_factor_exposure_id` BIGINT COMMENT 'Foreign key linking to risk.risk_factor_exposure. Business justification: Position‑level risk attribution reports require mapping each equity position to its risk factor exposure record.',
    `trader_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Position entry workflow requires linking the trader who executed the trade to the employee record.',
    `accrued_dividend` DECIMAL(18,2) COMMENT 'Dividend income accrued but not yet received for this position in base currency.',
    `acquisition_date` DATE COMMENT 'Date when the position was originally established in the portfolio.',
    `active_weight_percent` DECIMAL(8,4) COMMENT 'Difference between portfolio weight and benchmark weight; indicates over or underweight position.',
    `average_cost_per_share` DECIMAL(18,4) COMMENT 'Weighted average cost basis per share in the positions local currency.',
    `base_currency_code` STRING COMMENT 'ISO 4217 3-letter currency code for the portfolios base reporting currency.. Valid values are `^[A-Z]{3}$`',
    `benchmark_weight_percent` DECIMAL(8,4) COMMENT 'Weight of this security in the portfolios benchmark index expressed as a percentage.',
    `beta` DECIMAL(8,4) COMMENT 'Measure of the securitys volatility relative to the market benchmark per Capital Asset Pricing Model (CAPM).',
    `book_cost_base_currency` DECIMAL(18,2) COMMENT 'Total original acquisition cost of the position in the portfolios base currency.',
    `country_of_domicile` STRING COMMENT 'ISO 3166-1 alpha-3 country code where the issuing company is legally domiciled.. Valid values are `^[A-Z]{3}$`',
    `country_of_risk` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the primary country exposure for risk reporting.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this position record was first created in the IBOR.',
    `cusip` STRING COMMENT '9-character alphanumeric code identifying North American securities.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `custodian_account_number` STRING COMMENT 'Account number at the custodian bank where the equity position is held.',
    `data_source_system` STRING COMMENT 'Name of the upstream system of record that provided this position data.',
    `dividend_yield_percent` DECIMAL(8,4) COMMENT 'Annualized dividend yield of the security expressed as a percentage of market price.',
    `esg_score` DECIMAL(5,2) COMMENT 'Composite ESG rating score for the security from external ESG data provider.',
    `exchange_code` STRING COMMENT 'ISO 10383 4-character code identifying the primary exchange where the security is listed.. Valid values are `^[A-Z]{4}$`',
    `fx_rate` DECIMAL(18,8) COMMENT 'Exchange rate used to convert local currency to base currency as of position date.',
    `income_classification` STRING COMMENT 'Tax classification of dividend income from this position.. Valid values are `qualified|non_qualified|exempt|foreign`',
    `isin` STRING COMMENT 'ISO 6166 standard 12-character alphanumeric code uniquely identifying the equity security.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `last_trade_date` DATE COMMENT 'Date of the most recent trade that affected this position.',
    `lending_eligible_flag` BOOLEAN COMMENT 'Indicates whether the position is eligible for securities lending programs.',
    `local_currency_code` STRING COMMENT 'ISO 4217 3-letter currency code for the securitys trading currency.. Valid values are `^[A-Z]{3}$`',
    `market_capitalization_tier` STRING COMMENT 'Classification of the equity by market capitalization size.. Valid values are `large_cap|mid_cap|small_cap|micro_cap`',
    `market_price` DECIMAL(18,4) COMMENT 'Current market price per share in the securitys local trading currency as of position date.',
    `market_value_base_currency` DECIMAL(18,2) COMMENT 'Total market value of the position converted to the portfolios base currency.',
    `market_value_local_currency` DECIMAL(18,2) COMMENT 'Total market value of the position in the securitys local trading currency.',
    `portfolio_weight_percent` DECIMAL(8,4) COMMENT 'Weight of this position in the total portfolio expressed as a percentage of Net Asset Value (NAV).',
    `position_date` DATE COMMENT 'The business date for which this equity position snapshot is recorded.',
    `position_status` STRING COMMENT 'Current lifecycle status of the equity position.. Valid values are `active|closed|pending|suspended`',
    `position_type` STRING COMMENT 'Indicates whether the position is a long holding or a short sale.. Valid values are `long|short`',
    `price_to_earnings_ratio` DECIMAL(10,2) COMMENT 'Ratio of market price per share to earnings per share; valuation metric.',
    `quantity` DECIMAL(18,4) COMMENT 'Number of shares or units held in the equity position; negative for short positions.',
    `restricted_flag` BOOLEAN COMMENT 'Indicates whether the position is subject to trading restrictions or lock-up periods.',
    `sector_classification` STRING COMMENT 'Industry sector classification of the equity security per GICS or equivalent taxonomy.',
    `sedol` STRING COMMENT '7-character alphanumeric code identifying securities traded on the London Stock Exchange and other UK exchanges.. Valid values are `^[0-9A-Z]{7}$`',
    `settlement_date` DATE COMMENT 'Most recent settlement date for transactions affecting this position.',
    `tax_lot_method` STRING COMMENT 'Method used for tax lot accounting and cost basis calculation.. Valid values are `FIFO|LIFO|HIFO|specific_identification`',
    `ticker_symbol` STRING COMMENT 'Exchange trading symbol for the equity security.',
    `unrealized_gain_loss_base_currency` DECIMAL(18,2) COMMENT 'Difference between market value and book cost in base currency; represents mark-to-market profit or loss.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp when this position record was last modified.',
    `valuation_source` STRING COMMENT 'Source of the market price used for position valuation.. Valid values are `exchange|vendor|broker|model`',
    `voting_rights_flag` BOOLEAN COMMENT 'Indicates whether the equity position carries shareholder voting rights.',
    CONSTRAINT pk_equity_position PRIMARY KEY(`equity_position_id`)
) COMMENT 'IBOR equity position records representing the funds current and historical holdings in listed equities at the portfolio-security-date level. Captures long/short indicator, quantity held, book cost, average cost basis, unrealized P&L, market value in';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`equity_benchmark` (
    `equity_benchmark_id` BIGINT COMMENT 'Unique identifier for the equity benchmark index record.',
    `creator_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Benchmark creation process requires linking the creator to the employee record.',
    `administrator_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier of the benchmark administrator.. Valid values are `^[A-Z0-9]{20}$`',
    `base_currency` STRING COMMENT 'Original calculation currency of the benchmark before any currency conversion.. Valid values are `^[A-Z]{3}$`',
    `base_date` DATE COMMENT 'Inception date of the benchmark index from which historical performance is calculated.',
    `base_value` DECIMAL(18,4) COMMENT 'Initial index level set at the base date (typically 100 or 1000).',
    `benchmark_code` STRING COMMENT 'Unique alphanumeric code identifying the benchmark index (e.g., SPX, MXWO, RTSI).. Valid values are `^[A-Z0-9]{3,12}$`',
    `benchmark_name` STRING COMMENT 'Full official name of the equity benchmark index.',
    `benchmark_status` STRING COMMENT 'Current operational status of the benchmark index.. Valid values are `Active|Discontinued|Suspended|Under Review`',
    `benchmark_type` STRING COMMENT 'Classification of the benchmark by scope and construction methodology. [ENUM-REF-CANDIDATE: Broad Market|Regional|Country|Sector|Style|Factor|ESG|Custom — 8 candidates stripped; promote to reference product]',
    `bloomberg_ticker` STRING COMMENT 'Bloomberg terminal ticker symbol for the benchmark index.. Valid values are `^[A-Z0-9]{1,10}( [A-Z]{1,6})?$`',
    `calculation_frequency` STRING COMMENT 'Frequency at which the benchmark index level is calculated and published.. Valid values are `Real-Time|End-of-Day|Weekly|Monthly`',
    `capping_methodology` STRING COMMENT 'Description of any maximum weight limits applied to individual constituents or sectors.',
    `country_iso_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for single-country benchmarks.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this benchmark record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the benchmark is denominated.. Valid values are `^[A-Z]{3}$`',
    `data_source` STRING COMMENT 'System or vendor from which benchmark data is sourced (e.g., Bloomberg, MSCI, FactSet).',
    `dividend_treatment` STRING COMMENT 'How dividends are treated in the benchmark calculation methodology.. Valid values are `Excluded|Net Reinvested|Gross Reinvested`',
    `effective_date` DATE COMMENT 'Date from which this benchmark record is effective for use in portfolio management and reporting.',
    `esg_integration` BOOLEAN COMMENT 'Indicates whether the benchmark incorporates ESG screening or tilting criteria.',
    `esg_methodology` STRING COMMENT 'Description of ESG screening, exclusion, or integration approach applied to the benchmark.',
    `factsheet_url` STRING COMMENT 'Web link to the current benchmark factsheet or summary document.',
    `free_float_adjustment` BOOLEAN COMMENT 'Indicates whether constituent weights are adjusted for publicly available shares only.',
    `geographic_scope` STRING COMMENT 'Geographic coverage of the equity markets included in the benchmark.. Valid values are `Global|Developed Markets|Emerging Markets|Frontier Markets|Regional|Single Country`',
    `hedged_currency` STRING COMMENT 'Target currency for currency-hedged versions of the benchmark index.. Valid values are `^[A-Z]{3}$`',
    `index_provider` STRING COMMENT 'Organization that calculates and publishes the benchmark index. [ENUM-REF-CANDIDATE: MSCI|FTSE|S&P|Russell|Bloomberg|Dow Jones|Stoxx|Nasdaq — 8 candidates stripped; promote to reference product]',
    `internal_benchmark_flag` BOOLEAN COMMENT 'Indicates whether this is a custom benchmark constructed internally rather than a third-party published index.',
    `is_hedged` BOOLEAN COMMENT 'Indicates whether the benchmark includes currency hedging to a target currency.',
    `isin` STRING COMMENT 'ISO 6166 standard 12-character alphanumeric code uniquely identifying the benchmark index.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this benchmark record.',
    `market_cap_range` STRING COMMENT 'Market capitalization segment targeted by the benchmark index.. Valid values are `Large Cap|Mid Cap|Small Cap|Micro Cap|All Cap|Multi Cap`',
    `methodology_url` STRING COMMENT 'Web link to the official index methodology document published by the provider.',
    `notes` STRING COMMENT 'Free-text field for additional comments, usage guidance, or special considerations for this benchmark.',
    `number_of_constituents` BIGINT COMMENT 'Total count of equity securities included in the benchmark index.',
    `rebalancing_frequency` STRING COMMENT 'Frequency at which the benchmark index composition and weights are reconstituted. [ENUM-REF-CANDIDATE: Daily|Weekly|Monthly|Quarterly|Semi-Annual|Annual|Event-Driven — 7 candidates stripped; promote to reference product]',
    `reconstitution_month` STRING COMMENT 'Primary month in which annual or semi-annual index reconstitution occurs. [ENUM-REF-CANDIDATE: January|February|March|April|May|June|July|August|September|October|November|December — 12 candidates stripped; promote to reference product]',
    `region` STRING COMMENT 'Primary geographic region covered by the benchmark (e.g., North America, Europe, Asia Pacific).',
    `regulatory_classification` STRING COMMENT 'Regulatory designation under applicable benchmark regulations (e.g., EU BMR critical, significant, non-significant).',
    `return_type` STRING COMMENT 'Calculation method for index returns: price-only, net dividends, or gross dividends.. Valid values are `Price Return|Net Total Return|Gross Total Return`',
    `ric_code` STRING COMMENT 'Refinitiv Reuters Instrument Code identifying the benchmark index.. Valid values are `^.[A-Z0-9]{1,10}$`',
    `sector_focus` STRING COMMENT 'Specific GICS sector or industry group if the benchmark is sector-specific.',
    `style_factor` STRING COMMENT 'Investment style or factor exposure emphasized by the benchmark index. [ENUM-REF-CANDIDATE: Value|Growth|Blend|Quality|Momentum|Low Volatility|Dividend|Multi-Factor — 8 candidates stripped; promote to reference product]',
    `termination_date` DATE COMMENT 'Date on which this benchmark was discontinued or replaced, if applicable.',
    `usage_purpose` STRING COMMENT 'Primary use case for this benchmark within the organization (e.g., performance attribution, portfolio construction, risk management, SAA reference).',
    `version_number` BIGINT COMMENT 'Version number of the benchmark record for change tracking and audit purposes.',
    `weighting_methodology` STRING COMMENT 'Method used to weight constituent securities within the benchmark index. [ENUM-REF-CANDIDATE: Market Cap|Float-Adjusted Market Cap|Equal Weight|Fundamental|Factor|Risk-Based|Custom — 7 candidates stripped; promote to reference product]',
    CONSTRAINT pk_equity_benchmark PRIMARY KEY(`equity_benchmark_id`)
) COMMENT 'Reference master for equity benchmark indices used in portfolio construction, performance attribution, and risk management. Captures benchmark name, index provider (MSCI, FTSE, S&P, Russell), benchmark code, currency, rebalancing frequency, weighting';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`equity_benchmark_constituent` (
    `equity_benchmark_constituent_id` BIGINT COMMENT 'Unique identifier for the equity benchmark constituent record.',
    `equity_benchmark_id` BIGINT COMMENT 'Reference to the parent equity benchmark index to which this constituent belongs.',
    `listed_security_id` BIGINT COMMENT 'Reference to the equity security that is a constituent of the benchmark.',
    `addition_date` DATE COMMENT 'Date on which the security was first added to the benchmark index.',
    `adjusted_market_capitalization` DECIMAL(20,2) COMMENT 'Market capitalization adjusted for free float and other index-specific factors, used as the basis for weight calculation in free-float weighted indices.',
    `average_daily_value_traded` DECIMAL(20,2) COMMENT 'Average monetary value of shares traded daily over a specified lookback period, used for liquidity assessment.',
    `average_daily_volume` BIGINT COMMENT 'Average number of shares traded daily over a specified lookback period, used for liquidity assessment.',
    `capping_factor` DECIMAL(8,6) COMMENT 'Factor applied to limit the maximum weight of any single constituent, used in capped index methodologies.',
    `constituent_status` STRING COMMENT 'Current lifecycle status of the constituent membership within the benchmark index.. Valid values are `active|pending_addition|pending_deletion|deleted|suspended`',
    `constituent_weight` DECIMAL(18,10) COMMENT 'Weight of the security within the benchmark index expressed as a decimal proportion, typically summing to 1.0 across all constituents at a given effective date.',
    `constituent_weight_percent` DECIMAL(8,5) COMMENT 'Weight of the security within the benchmark index expressed as a percentage, typically summing to 100 across all constituents.',
    `corporate_action_adjustment_flag` BOOLEAN COMMENT 'Indicates whether this constituent record reflects an adjustment due to a corporate action such as stock split, dividend, or merger.',
    `country_of_domicile` STRING COMMENT 'Three-letter ISO 3166 country code representing the legal domicile of the issuer.. Valid values are `^[A-Z]{3}$`',
    `country_of_risk` STRING COMMENT 'Three-letter ISO 3166 country code representing the primary country of economic risk exposure for the issuer.. Valid values are `^[A-Z]{3}$`',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the security is denominated and priced.. Valid values are `^[A-Z]{3}$`',
    `cusip` STRING COMMENT 'Committee on Uniform Securities Identification Procedures code identifying North American securities.. Valid values are `^[0-9A-Z]{9}$`',
    `data_source` STRING COMMENT 'System or vendor from which the constituent data was sourced, such as Bloomberg, MSCI, FTSE Russell, or internal calculation.',
    `deletion_date` DATE COMMENT 'Date on which the security was removed from the benchmark index, null if still a constituent.',
    `deletion_reason` STRING COMMENT 'Reason code explaining why the security was removed from the benchmark index. [ENUM-REF-CANDIDATE: merger|acquisition|delisting|bankruptcy|rebalance|size_threshold|liquidity_threshold — 7 candidates stripped; promote to reference product]',
    `effective_date` DATE COMMENT 'Date on which this constituent membership and weight became effective, typically aligned with benchmark rebalancing dates.',
    `expiration_date` DATE COMMENT 'Date on which this constituent membership ended or will end, null if currently active in the benchmark.',
    `free_float_factor` DECIMAL(8,6) COMMENT 'Proportion of shares available for public trading, used to adjust market capitalization for free-float weighting methodologies.',
    `gics_industry_code` STRING COMMENT 'Six-digit GICS industry code providing third-level industry classification.. Valid values are `^[0-9]{6}$`',
    `gics_industry_group_code` STRING COMMENT 'Four-digit GICS industry group code providing second-level industry classification.. Valid values are `^[0-9]{4}$`',
    `gics_sector_code` STRING COMMENT 'Two-digit GICS sector code classifying the security at the highest industry hierarchy level.. Valid values are `^[0-9]{2}$`',
    `gics_sub_industry_code` STRING COMMENT 'Eight-digit GICS sub-industry code providing the most granular industry classification.. Valid values are `^[0-9]{8}$`',
    `index_divisor` DECIMAL(20,10) COMMENT 'Divisor value used in index calculation to maintain index continuity across corporate actions and rebalancing events.',
    `index_provider_code` STRING COMMENT 'Code or identifier of the organization that publishes and maintains the benchmark index.',
    `isin` STRING COMMENT 'International Securities Identification Number uniquely identifying the equity security globally.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `issuer_name` STRING COMMENT 'Legal name of the company or entity that issued the equity security.',
    `liquidity_score` DECIMAL(10,4) COMMENT 'Quantitative measure of the securitys trading liquidity used in index eligibility and weighting decisions.',
    `market_capitalization` DECIMAL(20,2) COMMENT 'Total market capitalization of the security at the effective date, calculated as shares outstanding multiplied by price.',
    `price_at_rebalance` DECIMAL(18,6) COMMENT 'Closing price of the security on the effective date used for weight calculation and rebalancing.',
    `rebalance_frequency` STRING COMMENT 'Frequency at which the benchmark index rebalances constituent weights and membership.. Valid values are `quarterly|semi_annual|annual|monthly|ad_hoc`',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this constituent record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this constituent record was last modified in the system.',
    `security_name` STRING COMMENT 'Full legal name of the equity security as recognized by the benchmark provider.',
    `sedol` STRING COMMENT 'Stock Exchange Daily Official List code identifying the security, primarily used in UK and Irish markets.. Valid values are `^[0-9A-Z]{7}$`',
    `shares_outstanding` BIGINT COMMENT 'Number of shares of the security outstanding at the effective date, used in market capitalization weighting calculations.',
    `ticker_symbol` STRING COMMENT 'Exchange ticker symbol for the security at the time of constituent membership.',
    `weighting_methodology` STRING COMMENT 'Methodology used by the index provider to calculate constituent weights within the benchmark.. Valid values are `market_cap|free_float|equal|fundamental|factor`',
    CONSTRAINT pk_equity_benchmark_constituent PRIMARY KEY(`equity_benchmark_constituent_id`)
) COMMENT 'Point-in-time constituent membership records for equity benchmark indices, capturing the weight of each security within a benchmark at a given rebalancing date.';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`equity_coverage` (
    `equity_coverage_id` BIGINT COMMENT 'Unique identifier for the equity research coverage record.',
    `analyst_employee_id` BIGINT COMMENT 'Reference to the lead equity research analyst assigned to this coverage.',
    `employee_id` BIGINT COMMENT 'Reference to the lead equity research analyst assigned to this coverage.',
    `listed_security_id` BIGINT COMMENT 'Reference to the listed equity security under coverage.',
    `active_flag` BOOLEAN COMMENT 'Indicates whether this coverage record is currently active and valid for operational use.',
    `analyst_name` STRING COMMENT 'Full name of the lead equity research analyst responsible for this coverage.',
    `benchmark_index` STRING COMMENT 'Primary equity benchmark index against which this securitys performance is evaluated.',
    `conviction_level` STRING COMMENT 'Analysts conviction level in the investment thesis and rating for this coverage.. Valid values are `high|medium|low`',
    `country_of_domicile` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code of the issuers legal domicile.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this coverage record was first created in the system.',
    `cusip` STRING COMMENT 'Nine-character alphanumeric code identifying North American securities.. Valid values are `^[0-9]{3}[0-9A-Z]{5}[0-9]$`',
    `data_source` STRING COMMENT 'Primary external data provider or system of record for market data and analytics on this security.',
    `equity_coverage_status` STRING COMMENT 'Current status of research coverage for this security.. Valid values are `active|watch|suspended|dropped|pending`',
    `equity_coverage_type` STRING COMMENT 'Classification of the depth and scope of research coverage provided.. Valid values are `full|limited|sector|thematic|event`',
    `esg_coverage_flag` BOOLEAN COMMENT 'Indicates whether dedicated ESG analysis is included in the research coverage for this security.',
    `esg_rating` STRING COMMENT 'Internal or third-party ESG rating assigned to the covered security.',
    `geographic_region` STRING COMMENT 'Primary geographic region of the issuers operations and listing.',
    `industry_group` STRING COMMENT 'Industry group classification within the sector per GICS or internal taxonomy.',
    `initiation_date` DATE COMMENT 'Date when formal research coverage of this security was initiated.',
    `investment_rating` STRING COMMENT 'Current internal investment recommendation rating for the covered security.. Valid values are `buy|overweight|hold|underweight|sell`',
    `isin` STRING COMMENT 'ISO 6166 twelve-character alphanumeric code uniquely identifying the covered security.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `issuer_name` STRING COMMENT 'Legal name of the corporate entity issuing the covered equity security.',
    `last_review_date` DATE COMMENT 'Date of the most recent formal research review or report publication for this coverage.',
    `market_cap_tier` STRING COMMENT 'Market capitalization tier classification of the covered security.. Valid values are `large|mid|small|micro`',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal research review or report update.',
    `position_held_flag` BOOLEAN COMMENT 'Indicates whether the fund currently holds an active position in this covered security.',
    `primary_exchange` STRING COMMENT 'Primary stock exchange where the security is listed and traded.',
    `rating_effective_date` DATE COMMENT 'Date when the current investment rating became effective.',
    `rationale` STRING COMMENT 'Brief explanation of the strategic rationale for including this security in the research coverage universe.',
    `record_version` BIGINT COMMENT 'Version number of this coverage record for change tracking and audit purposes.',
    `research_priority` STRING COMMENT 'Priority tier assigned to this coverage within the research teams portfolio allocation.. Valid values are `core|standard|opportunistic`',
    `sector_classification` STRING COMMENT 'Primary industry sector classification of the covered security per GICS or internal taxonomy.',
    `security_name` STRING COMMENT 'Full legal name of the equity security under coverage.',
    `sedol` STRING COMMENT 'Seven-character alphanumeric code identifying securities traded on London Stock Exchange and other UK exchanges.. Valid values are `^[0-9BCDFGHJKLMNPQRSTVWXYZ]{7}$`',
    `target_price` DECIMAL(18,4) COMMENT 'Analyst twelve-month forward target price for the covered security in local currency.',
    `target_price_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the target price.. Valid values are `^[A-Z]{3}$`',
    `termination_date` DATE COMMENT 'Date when research coverage of this security was formally terminated or dropped.',
    `termination_reason` STRING COMMENT 'Explanation for why coverage was terminated or dropped if coverage status is dropped or suspended.',
    `ticker_symbol` STRING COMMENT 'Exchange ticker symbol for the covered equity security.',
    `updated_by` STRING COMMENT 'User identifier of the person or system that last updated this coverage record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this coverage record was last modified.',
    CONSTRAINT pk_equity_coverage PRIMARY KEY(`equity_coverage_id`)
) COMMENT 'Internal equity research coverage universe master, defining which listed securities are formally covered by the funds internal equity research team. Captures coverage status (active, watch, dropped), assigned analyst, coverage initiation date, coverage';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`research_note` (
    `research_note_id` BIGINT COMMENT 'Unique identifier for the equity research note record.',
    `compliance_reviewer_employee_id` BIGINT COMMENT 'Reference to the compliance officer who reviewed and approved this research note.',
    `employee_id` BIGINT COMMENT 'Reference to the buy-side analyst who authored this research note.',
    `listed_security_id` BIGINT COMMENT 'Reference to the equity security covered by this research note.',
    `peer_review_analyst_employee_id` BIGINT COMMENT 'Reference to the senior analyst or peer who reviewed this research note for quality assurance.',
    `research_compliance_reviewer_employee_id` BIGINT COMMENT 'Reference to the compliance officer who reviewed and approved this research note.',
    `research_employee_id` BIGINT COMMENT 'Reference to the buy-side analyst who authored this research note.',
    `research_peer_review_analyst_employee_id` BIGINT COMMENT 'Reference to the senior analyst or peer who reviewed this research note for quality assurance.',
    `superseded_by_note_research_note_id` BIGINT COMMENT 'Reference to the newer research note that supersedes this one, if applicable.',
    `archived_date` DATE COMMENT 'Date when the research note was moved to archived status.',
    `archived_flag` BOOLEAN COMMENT 'Indicates whether the research note has been archived and is no longer actively maintained.',
    `compliance_review_date` DATE COMMENT 'Date when the research note was reviewed and approved by compliance for conflicts and regulatory adherence.',
    `conviction_level` STRING COMMENT 'Analysts confidence level in the investment thesis and recommendation.. Valid values are `high|medium|low`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the research note record was first created in the system.',
    `dcf_terminal_growth_rate_percent` DECIMAL(5,2) COMMENT 'Perpetual growth rate assumption used in DCF terminal value calculation, expressed as a percentage.',
    `dcf_wacc_percent` DECIMAL(5,2) COMMENT 'Weighted average cost of capital used in DCF valuation model, expressed as a percentage.',
    `distribution_scope` STRING COMMENT 'Defines the internal audience and access level for this research note.. Valid values are `internal_all|portfolio_managers_only|investment_committee|restricted_list|archived`',
    `document_url` STRING COMMENT 'Internal storage location or URL for the full research note document.',
    `earnings_estimate_current_year` DECIMAL(18,4) COMMENT 'Analysts earnings per share estimate for the current fiscal year.',
    `earnings_estimate_next_year` DECIMAL(18,4) COMMENT 'Analysts earnings per share estimate for the next fiscal year.',
    `esg_assessment_summary` STRING COMMENT 'Narrative summary of ESG considerations and their impact on the investment thesis.',
    `esg_score` DECIMAL(5,2) COMMENT 'Internal or third-party ESG rating for the covered security, used in responsible investment integration.',
    `ev_ebitda_ratio` DECIMAL(8,2) COMMENT 'Enterprise value to EBITDA multiple used or cited in the valuation analysis.',
    `executive_summary` STRING COMMENT 'Brief summary of the investment thesis, key findings, and recommendation for quick reference.',
    `investment_horizon_months` BIGINT COMMENT 'Time horizon in months over which the target price and recommendation apply.',
    `investment_recommendation` STRING COMMENT 'The analysts formal investment recommendation for the covered security. [ENUM-REF-CANDIDATE: strong_buy|buy|hold|reduce|sell|under_review|not_rated — 7 candidates stripped; promote to reference product]',
    `key_catalysts` STRING COMMENT 'Summary of expected near-term events or developments that could drive price movement.',
    `key_risks` STRING COMMENT 'Summary of principal investment risks and downside scenarios identified by the analyst.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the research note record was last updated or revised.',
    `note_type` STRING COMMENT 'Classification of the research note by purpose and content type. [ENUM-REF-CANDIDATE: initiation|update|earnings_review|sector_note|thematic|downgrade|upgrade — 7 candidates stripped; promote to reference product]',
    `pe_ratio_forward` DECIMAL(8,2) COMMENT 'Forward-looking price-to-earnings multiple used or cited in the valuation analysis.',
    `prior_recommendation` STRING COMMENT 'The previous investment recommendation before this research note, if this is an update or change. [ENUM-REF-CANDIDATE: strong_buy|buy|hold|reduce|sell|under_review|not_rated — 7 candidates stripped; promote to reference product]',
    `prior_target_price` DECIMAL(18,4) COMMENT 'The previous target price before this research note, if this is an update or change.',
    `publication_date` DATE COMMENT 'Date when the research note was officially published and distributed internally.',
    `publication_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the research note was published to internal systems.',
    `recommendation_change_reason` STRING COMMENT 'Explanation of why the recommendation or target price was changed from the prior view.',
    `research_status` STRING COMMENT 'Current lifecycle status of the research note in the publication workflow. [ENUM-REF-CANDIDATE: draft|peer_review|compliance_review|approved|published|archived|withdrawn — 7 candidates stripped; promote to reference product]',
    `revenue_estimate_current_year` DECIMAL(18,2) COMMENT 'Analysts revenue estimate for the current fiscal year in the securitys reporting currency.',
    `revenue_estimate_next_year` DECIMAL(18,2) COMMENT 'Analysts revenue estimate for the next fiscal year in the securitys reporting currency.',
    `sector_focus` STRING COMMENT 'Primary industry sector or sub-sector that is the focus of this research note.',
    `target_price` DECIMAL(18,4) COMMENT 'Analysts price target for the security over the stated investment horizon.',
    `target_price_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the target price.. Valid values are `^[A-Z]{3}$`',
    `thematic_tag` STRING COMMENT 'Cross-sector investment theme or macro trend addressed in the research note.',
    `title` STRING COMMENT 'Headline or title of the research note summarizing the key thesis or topic.',
    `valuation_methodology` STRING COMMENT 'Primary valuation approach used to derive the target price and investment thesis.. Valid values are `dcf|comparable_multiples|sum_of_parts|dividend_discount|asset_based|hybrid`',
    `version_number` BIGINT COMMENT 'Sequential version number for tracking revisions and updates to the research note.',
    `withdrawal_reason` STRING COMMENT 'Explanation of why the research note was withdrawn from circulation.',
    `withdrawn_flag` BOOLEAN COMMENT 'Indicates whether the research note has been withdrawn due to errors or material changes.',
    `word_count` BIGINT COMMENT 'Total word count of the research note document for content depth tracking.',
    CONSTRAINT pk_research_note PRIMARY KEY(`research_note_id`)
) COMMENT 'Internal equity research notes and investment theses produced by the funds buy-side analysts for covered securities. Captures note type (initiation, update, earnings review, sector note, thematic), publication date, analyst, investment recommendation';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`price_history` (
    `price_history_id` BIGINT COMMENT 'Unique identifier for each daily price history record.',
    `listed_security_id` BIGINT COMMENT 'Foreign key reference to the equity security master record.',
    `adjusted_close_price` DECIMAL(18,4) COMMENT 'Closing price adjusted for corporate actions including dividends, stock splits, and rights offerings to enable accurate historical return calculations.',
    `ask_price` DECIMAL(18,4) COMMENT 'Lowest ask price at market close, representing the price sellers are willing to accept.',
    `batch_reference` STRING COMMENT 'Identifier of the ETL batch process that loaded this price record, supporting data lineage and troubleshooting.',
    `bid_ask_spread` DECIMAL(18,4) COMMENT 'Difference between ask price and bid price, indicating market liquidity and transaction cost.',
    `bid_price` DECIMAL(18,4) COMMENT 'Highest bid price at market close, representing the price buyers are willing to pay.',
    `close_price` DECIMAL(18,4) COMMENT 'Official closing price of the security at market close on the price date.',
    `corporate_action_flag` BOOLEAN COMMENT 'Indicates whether a corporate action (dividend, split, merger, etc.) occurred on the price date affecting price continuity.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which prices are denominated.. Valid values are `^[A-Z]{3}$`',
    `cusip` STRING COMMENT '9-character alphanumeric code identifying North American securities.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `data_quality_flag` BOOLEAN COMMENT 'Quality assessment indicator for the price record, used for data governance and reconciliation.',
    `dividend_amount` DECIMAL(18,4) COMMENT 'Cash dividend per share paid on the price date, if applicable.',
    `exchange_code` STRING COMMENT 'Market Identifier Code (MIC) of the exchange where the security is traded.',
    `high_price` DECIMAL(18,4) COMMENT 'Highest intraday price reached during the trading session.',
    `is_trading_day` BOOLEAN COMMENT 'Indicates whether the price date was an active trading day for the exchange.',
    `isin` STRING COMMENT 'ISO 6166 standard 12-character alphanumeric code uniquely identifying the equity security.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `low_price` DECIMAL(18,4) COMMENT 'Lowest intraday price reached during the trading session.',
    `market_cap` DECIMAL(20,2) COMMENT 'Total market value of the company calculated as closing price multiplied by shares outstanding at the price date.',
    `open_price` DECIMAL(18,4) COMMENT 'Opening price of the security at market open on the price date.',
    `previous_close_price` DECIMAL(18,4) COMMENT 'Official closing price from the prior trading session for day-over-day comparison.',
    `price_change` DECIMAL(18,4) COMMENT 'Absolute change in price from previous close to current close.',
    `price_change_percent` DECIMAL(10,6) COMMENT 'Percentage change in price from previous close to current close expressed as a decimal.',
    `price_date` DATE COMMENT 'Business date for which the price data is recorded (end-of-day).',
    `price_source` STRING COMMENT 'Data vendor or system from which the price data was sourced (e.g., Bloomberg, FactSet, exchange feed).',
    `price_type` STRING COMMENT 'Classification of the price data quality and source authority.. Valid values are `official|estimated|indicative|restated`',
    `record_created_timestamp` TIMESTAMP COMMENT 'System timestamp when the price history record was first created in the lakehouse.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'System timestamp when the price history record was last modified, supporting audit trail and data lineage.',
    `sedol` STRING COMMENT '7-character alphanumeric code identifying securities traded on the London Stock Exchange and other UK exchanges.. Valid values are `^[0-9A-Z]{7}$`',
    `shares_outstanding` BIGINT COMMENT 'Total number of shares issued and outstanding as of the price date, used for market capitalization and per-share calculations.',
    `split_factor` DECIMAL(10,6) COMMENT 'Stock split or reverse split adjustment factor applied on the price date (e.g., 2.0 for 2-for-1 split, 0.5 for 1-for-2 reverse split).',
    `ticker_symbol` STRING COMMENT 'Exchange-specific ticker symbol for the equity security.',
    `total_return_index` DECIMAL(18,6) COMMENT 'Cumulative total return index level assuming reinvestment of all dividends and distributions, used for performance attribution.',
    `trading_status` STRING COMMENT 'Status of trading activity for the security on the price date.. Valid values are `normal|halted|suspended|delisted|pre_open|post_close`',
    `turnover_value` DECIMAL(20,2) COMMENT 'Total monetary value of shares traded during the session, calculated as volume multiplied by price.',
    `volume` BIGINT COMMENT 'Total number of shares traded during the trading session.',
    `vwap` DECIMAL(18,4) COMMENT 'Volume-weighted average price of all trades executed during the trading session, used for execution quality assessment.',
    CONSTRAINT pk_price_history PRIMARY KEY(`price_history_id`)
) COMMENT 'Daily end-of-day price and volume history for listed equity securities. Captures open, high, low, close, adjusted close (for corporate actions), total return index level, trading volume, VWAP, market capitalization, shares outstanding at date';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`corporate_action` (
    `corporate_action_id` BIGINT COMMENT 'Unique identifier for the corporate action event record.',
    `listed_security_id` BIGINT COMMENT 'Reference to the equity security subject to this corporate action.',
    `action_status` STRING COMMENT 'Current lifecycle status of the corporate action: announced, confirmed, pending execution, executed, cancelled, or expired.. Valid values are `announced|confirmed|pending|executed|cancelled|expired`',
    `action_type` STRING COMMENT 'Classification of the corporate action event: dividend, stock split, reverse split, rights issue, spin-off, merger, acquisition, delisting, name change, ticker change, or bonus issue.',
    `announcement_date` DATE COMMENT 'Date on which the corporate action was publicly announced by the issuer.',
    `country_of_issue` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code representing the country in which the security is issued.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this corporate action record was first created in the system.',
    `cusip` STRING COMMENT 'Nine-character alphanumeric code identifying North American securities.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `data_quality_flag` BOOLEAN COMMENT 'Indicator of the data quality status for this corporate action record: verified, pending review, incomplete, or error.',
    `corporate_action_description` STRING COMMENT 'Detailed narrative description of the corporate action event, including business rationale and shareholder impact.',
    `dividend_amount` DECIMAL(18,4) COMMENT 'Cash dividend amount per share declared by the issuer, expressed in the dividend currency.',
    `dividend_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the dividend is denominated.. Valid values are `^[A-Z]{3}$`',
    `dividend_type` STRING COMMENT 'Classification of dividend: ordinary (regular), special (one-time), interim (mid-year), or final (year-end).. Valid values are `ordinary|special|interim|final`',
    `effective_date` DATE COMMENT 'Date on which the corporate action becomes effective, such as the date a merger closes or a name change takes effect.',
    `ex_date` DATE COMMENT 'Date on or after which a security trades without the right to receive the corporate action benefit; critical for determining entitlement.',
    `exchange_code` STRING COMMENT 'Four-character ISO 10383 Market Identifier Code for the exchange on which the security is listed.. Valid values are `^[A-Z]{4}$`',
    `impact_on_nav_flag` BOOLEAN COMMENT 'Boolean flag indicating whether this corporate action has a material impact on portfolio Net Asset Value calculation.',
    `isin` STRING COMMENT 'ISO 6166 twelve-character alphanumeric code uniquely identifying the security subject to the corporate action.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `issuer_lei` STRING COMMENT 'Twenty-character ISO 17442 Legal Entity Identifier uniquely identifying the issuer of the security.. Valid values are `^[A-Z0-9]{20}$`',
    `issuer_name` STRING COMMENT 'Legal name of the company or entity issuing the corporate action.',
    `mandatory_voluntary_flag` BOOLEAN COMMENT 'Indicates whether the corporate action is mandatory (automatic for all shareholders) or voluntary (requires shareholder election).',
    `new_cusip` STRING COMMENT 'CUSIP assigned to the security after a corporate action that changes the security identifier.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `new_isin` STRING COMMENT 'ISIN assigned to the security after a corporate action that changes the security identifier, such as a merger, spin-off, or name change.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `new_security_name` STRING COMMENT 'New legal name of the security or issuer after a name change, merger, or acquisition.',
    `new_sedol` STRING COMMENT 'SEDOL assigned to the security after a corporate action that changes the security identifier.. Valid values are `^[0-9A-Z]{7}$`',
    `new_ticker` STRING COMMENT 'New exchange trading symbol assigned to the security after a ticker change or corporate restructuring.',
    `notification_sent_flag` BOOLEAN COMMENT 'Boolean flag indicating whether portfolio managers and investment teams have been notified of this corporate action.',
    `payment_date` DATE COMMENT 'Date on which the corporate action benefit (dividend, distribution, or new securities) is paid or delivered to entitled shareholders.',
    `position_adjustment_required_flag` BOOLEAN COMMENT 'Boolean flag indicating whether portfolio position records must be adjusted to reflect this corporate action.',
    `processed_timestamp` TIMESTAMP COMMENT 'Timestamp when the corporate action event was processed and applied to portfolio positions and accounting records.',
    `record_date` DATE COMMENT 'Date on which shareholders must be registered on the company books to be entitled to the corporate action benefit.',
    `rights_ratio_from` DECIMAL(18,6) COMMENT 'Number of existing shares required to receive the rights entitlement; for a 1-for-5 rights issue, this value is 5.',
    `rights_ratio_to` DECIMAL(18,6) COMMENT 'Number of new shares offered per the existing share entitlement; for a 1-for-5 rights issue, this value is 1.',
    `sedol` STRING COMMENT 'Seven-character alphanumeric code identifying securities traded on the London Stock Exchange and other UK exchanges.. Valid values are `^[0-9A-Z]{7}$`',
    `source_reference_code` STRING COMMENT 'Unique identifier or reference number assigned to the corporate action event by the source system or data provider.',
    `split_ratio_from` DECIMAL(18,6) COMMENT 'Numerator of the stock split ratio representing the number of old shares; for a 2-for-1 split, this value is 1.',
    `split_ratio_to` DECIMAL(18,6) COMMENT 'Denominator of the stock split ratio representing the number of new shares; for a 2-for-1 split, this value is 2.',
    `subscription_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the subscription price is denominated.. Valid values are `^[A-Z]{3}$`',
    `subscription_price` DECIMAL(18,4) COMMENT 'Price per share at which entitled shareholders may subscribe to new shares in a rights issue.',
    `tax_treatment_code` STRING COMMENT 'Code representing the tax treatment applicable to the corporate action benefit, such as qualified dividend or return of capital.',
    `ticker` STRING COMMENT 'Exchange trading symbol for the security at the time of the corporate action.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this corporate action record was last modified.',
    `withholding_tax_rate` DECIMAL(5,4) COMMENT 'Default withholding tax rate applied to the corporate action benefit, expressed as a decimal (e.g., 0.15 for 15%).',
    CONSTRAINT pk_corporate_action PRIMARY KEY(`corporate_action_id`)
) COMMENT 'Corporate action event master for all equity securities in the coverage and position universe. Captures corporate action type (dividend, stock split, reverse split, rights issue, spin-off, merger, acquisition, delisting, name change, ticker change, bonus';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`corporate_action_election` (
    `corporate_action_election_id` BIGINT COMMENT 'Unique identifier for the corporate action election record.',
    `corporate_action_id` BIGINT COMMENT 'Reference to the underlying corporate action event to which this election applies.',
    `corporate_employee_id` BIGINT COMMENT 'Reference to the portfolio manager who made or authorized the election decision.',
    `corporate_trader_employee_id` BIGINT COMMENT 'Reference to the trader who submitted the election instruction.',
    `counterparty_id` BIGINT COMMENT 'Reference to the custodian bank processing the corporate action election.',
    `custodian_counterparty_id` BIGINT COMMENT 'Reference to the custodian bank processing the corporate action election.',
    `employee_id` BIGINT COMMENT 'Reference to the user who last modified this election record.',
    `equity_position_id` BIGINT COMMENT 'Reference to the equity position for which this election is made.',
    `holding_id` BIGINT COMMENT 'Foreign key linking to portfolio.holding. Business justification: Corporate action elections (dividends, rights issues, mergers) directly impact portfolio holdings.',
    `listed_security_id` BIGINT COMMENT 'Reference to the equity security subject to the corporate action.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio holding the position subject to this election.',
    `portfolio_manager_employee_id` BIGINT COMMENT 'Reference to the portfolio manager who made or authorized the election decision.',
    `trader_employee_id` BIGINT COMMENT 'Reference to the trader who submitted the election instruction.',
    `accounting_entry_reference` BIGINT COMMENT 'Reference to the accounting entry recording the financial impact of the election.',
    `actual_quantity_processed` DECIMAL(18,4) COMMENT 'Actual number of shares processed after proration or partial acceptance.',
    `agent_contact_email` STRING COMMENT 'Email address of the corporate action agent for election inquiries.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `agent_name` STRING COMMENT 'Name of the corporate action agent or transfer agent managing the event.',
    `cancellation_reason` STRING COMMENT 'Reason for cancellation if the election was withdrawn before execution.',
    `cash_consideration_amount` DECIMAL(18,2) COMMENT 'Total cash amount expected to be received for the elected quantity.',
    `cash_consideration_currency` STRING COMMENT 'Three-letter ISO currency code for cash consideration.. Valid values are `^[A-Z]{3}$`',
    `consideration_type` STRING COMMENT 'Type of consideration to be received in exchange for the elected shares.. Valid values are `cash|stock|mixed|rights`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this election record was first created in the system.',
    `custodian_reference_number` STRING COMMENT 'Unique reference number assigned by the custodian to this election instruction.',
    `elected_quantity` DECIMAL(18,4) COMMENT 'Number of shares or units for which the election is being made.',
    `election_confirmation_timestamp` TIMESTAMP COMMENT 'Date and time when the election was confirmed by the custodian or agent.',
    `election_deadline_date` DATE COMMENT 'Final date by which the election must be submitted to the custodian or agent.',
    `election_option_code` STRING COMMENT 'Code representing the specific option chosen by the fund from available alternatives.',
    `election_option_description` STRING COMMENT 'Detailed description of the elected option including terms and consideration.',
    `election_percentage` DECIMAL(5,2) COMMENT 'Percentage of eligible position being elected for participation.',
    `election_rationale` STRING COMMENT 'Business rationale and investment thesis supporting the election decision.',
    `election_reference_number` STRING COMMENT 'External reference number assigned to this election by the fund or custodian.',
    `election_status` STRING COMMENT 'Current lifecycle status of the election instruction. [ENUM-REF-CANDIDATE: draft|submitted|confirmed|executed|cancelled|expired|rejected — 7 candidates stripped; promote to reference product]',
    `election_submission_timestamp` TIMESTAMP COMMENT 'Date and time when the election instruction was submitted to the custodian or agent.',
    `election_type` STRING COMMENT 'Type of voluntary corporate action election being made.. Valid values are `tender_offer|rights_subscription|merger_election|dividend_reinvestment|stock_split_election|spin_off_election`',
    `eligible_quantity` DECIMAL(18,4) COMMENT 'Total number of shares or units eligible for participation in the corporate action.',
    `execution_date` DATE COMMENT 'Date on which the corporate action election was executed and settled.',
    `ic_approval_date` DATE COMMENT 'Date on which the Investment Committee approved the election decision.',
    `ic_approval_reference` STRING COMMENT 'Reference number or identifier for the IC approval decision.',
    `investment_committee_approval_required` BOOLEAN COMMENT 'Indicates whether IC approval was required for this election decision.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this election record was last updated.',
    `net_cash_proceeds` DECIMAL(18,2) COMMENT 'Net cash amount received after deducting withholding taxes and fees.',
    `notes` STRING COMMENT 'Additional notes or comments regarding the election decision or processing.',
    `payment_date` DATE COMMENT 'Date on which cash or stock consideration is expected to be received.',
    `proration_factor` DECIMAL(8,6) COMMENT 'Factor applied when the corporate action is oversubscribed and elections are prorated.',
    `rejection_reason` STRING COMMENT 'Reason provided by custodian or agent if the election was rejected.',
    `stock_consideration_isin` STRING COMMENT 'ISIN of the security to be received as stock consideration.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `stock_consideration_quantity` DECIMAL(18,4) COMMENT 'Number of shares expected to be received as stock consideration.',
    `tax_treatment_code` STRING COMMENT 'Code indicating the expected tax treatment of the consideration received.',
    `withholding_tax_rate` DECIMAL(5,2) COMMENT 'Applicable withholding tax rate percentage on cash consideration.',
    CONSTRAINT pk_corporate_action_election PRIMARY KEY(`corporate_action_election_id`)
) COMMENT 'Records of the funds elections and responses to voluntary corporate actions (e.g., tender offers, rights subscriptions, merger consideration elections, dividend reinvestment elections).';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`equity_factor_exposure` (
    `equity_factor_exposure_id` BIGINT COMMENT 'Unique identifier for the factor exposure record.',
    `equity_benchmark_id` BIGINT COMMENT 'Reference to the benchmark index used for relative factor exposure analysis. Null if absolute exposure only.',
    `factor_model_id` BIGINT COMMENT 'Reference to the factor model used for exposure calculation.',
    `listed_security_id` BIGINT COMMENT 'Reference to the equity security for which factor exposures are calculated.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio for which factor exposures are calculated. Null if exposure is at security level only.',
    `active_exposure` DECIMAL(18,6) COMMENT 'The difference between portfolio factor exposure and benchmark factor exposure, representing active positioning relative to benchmark.',
    `adjustment_reason` STRING COMMENT 'Explanation for any manual adjustments or overrides applied to the calculated factor exposure. Null if no adjustments made.',
    `approval_timestamp` TIMESTAMP COMMENT 'Timestamp when the factor exposure record was approved for use in risk reporting and portfolio management.',
    `approved_by` STRING COMMENT 'Name or identifier of the risk analyst or portfolio manager who approved the factor exposure calculation or adjustment.',
    `beta_to_market` DECIMAL(18,6) COMMENT 'The beta coefficient representing the sensitivity of the security or portfolio to market movements. Core metric in CAPM (Capital Asset Pricing Model).',
    `calculation_method` STRING COMMENT 'Methodology used to calculate the factor exposure: regression analysis, covariance matrix, portfolio optimization, or performance attribution.. Valid values are `regression|covariance|optimization|attribution`',
    `calculation_timestamp` TIMESTAMP COMMENT 'Timestamp when the factor exposure calculation was performed.',
    `comments` STRING COMMENT 'Free-text comments or notes regarding the factor exposure calculation, data quality issues, or analytical insights.',
    `confidence_level` DECIMAL(5,2) COMMENT 'Confidence level for the factor exposure calculation, typically expressed as a percentage such as 95% or 99%.',
    `contribution_to_risk` DECIMAL(18,6) COMMENT 'The contribution of this factor exposure to the overall portfolio risk, measured in percentage or basis points (bps).',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which factor returns and exposures are denominated.. Valid values are `^[A-Z]{3}$`',
    `data_source` STRING COMMENT 'Source system or vendor providing the factor exposure data, such as MSCI Barra, Bloomberg, FactSet, BlackRock Aladdin, or internal calculation.. Valid values are `MSCI_Barra|Bloomberg|FactSet|Internal|Aladdin`',
    `exposure_date` DATE COMMENT 'The date for which the factor exposure is calculated and reported.',
    `exposure_percentile` DECIMAL(5,2) COMMENT 'Percentile rank of the factor exposure relative to peer universe or historical distribution. Range 0 to 100.',
    `exposure_value` DECIMAL(18,6) COMMENT 'Numeric value representing the magnitude of exposure to the factor. Standardized exposure score, typically z-score normalized.',
    `exposure_weight` DECIMAL(18,6) COMMENT 'Portfolio weight applied to the security when calculating portfolio-level factor exposure. Null for security-level exposures.',
    `factor_category` STRING COMMENT 'Classification of the factor into broad categories: style factors, industry factors, country factors, currency factors, market factors, or macroeconomic factors.. Valid values are `style|industry|country|currency|market|macro`',
    `factor_model_version` STRING COMMENT 'Version identifier of the factor model used, such as Barra GEM4, USE4, EUE3, or CAPM variant.',
    `factor_name` STRING COMMENT 'Name of the risk factor, such as market beta, size, value, momentum, quality, low volatility, growth, leverage, liquidity, earnings yield, or sector-specific factors.',
    `factor_return` DECIMAL(18,6) COMMENT 'The return attributed to this factor over the exposure period, expressed as a percentage or decimal.',
    `factor_volatility` DECIMAL(18,6) COMMENT 'The volatility or standard deviation of the factor return, representing the risk associated with the factor itself.',
    `frequency` STRING COMMENT 'Frequency at which factor exposures are calculated and reported: daily, weekly, monthly, or quarterly.. Valid values are `daily|weekly|monthly|quarterly`',
    `is_active` BOOLEAN COMMENT 'Indicates whether this factor exposure record is currently active and should be used in risk reporting and analytics.',
    `lookback_period_days` BIGINT COMMENT 'Number of days of historical data used in the factor exposure calculation, such as 60, 90, 252, or 504 days.',
    `marginal_contribution_to_risk` DECIMAL(18,6) COMMENT 'Marginal contribution to total portfolio risk from this factor exposure, representing the change in risk if exposure changes by one unit.',
    `outlier_flag` BOOLEAN COMMENT 'Indicates whether the factor exposure value is identified as a statistical outlier requiring review or adjustment.',
    `p_value` DECIMAL(18,6) COMMENT 'Probability value indicating the statistical significance of the factor exposure. Values below 0.05 typically indicate significance at 95% confidence level.',
    `quality_score` DECIMAL(5,2) COMMENT 'Data quality score for the factor exposure calculation, ranging from 0 to 100, based on data completeness, timeliness, and model fit.',
    `r_squared` DECIMAL(18,6) COMMENT 'Coefficient of determination indicating the proportion of variance in security returns explained by the factor model. Range 0 to 1.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this factor exposure record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this factor exposure record was last updated or modified.',
    `t_statistic` DECIMAL(18,6) COMMENT 'Statistical t-statistic measuring the significance of the factor exposure. Values above 2 or below -2 typically indicate statistical significance.',
    CONSTRAINT pk_equity_factor_exposure PRIMARY KEY(`equity_factor_exposure_id`)
) COMMENT 'Equity factor exposure records for securities and portfolios based on Barra and CAPM factor models. Captures factor model version (Barra GEM, USE, EUE), exposure date, factor name (market beta, size, value, momentum, quality, low volatility, growth';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`equity_sector_classification` (
    `equity_sector_classification_id` BIGINT COMMENT 'Unique identifier for the sector classification record.',
    `listed_security_id` BIGINT COMMENT 'Reference to the equity security being classified.',
    `analyst_override_flag` BOOLEAN COMMENT 'Indicates whether internal investment analysts have overridden the standard classification for portfolio management purposes.',
    `benchmark_inclusion_flag` BOOLEAN COMMENT 'Indicates whether this classification is used for benchmark index inclusion and sector allocation decisions.',
    `classification_confidence_score` DECIMAL(5,2) COMMENT 'Confidence level or quality score assigned by the classification provider, typically 0-100 percent.',
    `classification_methodology` STRING COMMENT 'Description of the methodology or criteria used to assign the classification.',
    `classification_notes` STRING COMMENT 'Free-text notes or comments regarding special considerations, edge cases, or analyst observations for this classification.',
    `classification_scheme` STRING COMMENT 'Standard classification taxonomy used for sector categorization.. Valid values are `GICS|ICB|NAICS|SIC|TRBC|BICS`',
    `classification_source` STRING COMMENT 'Data provider or system that supplied the classification data.',
    `classification_status` STRING COMMENT 'Current lifecycle status of this classification assignment.. Valid values are `active|inactive|pending|under_review|deprecated`',
    `classification_version` STRING COMMENT 'Version or edition of the classification scheme applied.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this classification record was first created in the system.',
    `cusip` STRING COMMENT 'Nine-character alphanumeric code identifying North American securities.. Valid values are `^[0-9]{3}[0-9A-Z]{5}[0-9]$`',
    `data_quality_flag` BOOLEAN COMMENT 'Indicator of the data quality and verification status of this classification record.',
    `effective_date` DATE COMMENT 'Date from which this sector classification becomes effective for the security.',
    `expiration_date` DATE COMMENT 'Date on which this sector classification ceases to be effective, null for current classifications.',
    `industry_code` STRING COMMENT 'Third-level industry classification code within the industry group.',
    `industry_group_code` STRING COMMENT 'Second-level industry group classification code within the sector.',
    `industry_group_name` STRING COMMENT 'Human-readable name of the industry group.',
    `industry_name` STRING COMMENT 'Human-readable name of the industry.',
    `isin` STRING COMMENT 'ISO 6166 standard 12-character alphanumeric code uniquely identifying the security.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `last_modified_by` STRING COMMENT 'User or system identifier that last modified this classification record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this classification record was last updated.',
    `last_review_date` DATE COMMENT 'Date when this classification was last reviewed or validated by internal data stewards or analysts.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review of this classification.',
    `override_justification` STRING COMMENT 'Business rationale provided by analysts for classification override decisions.',
    `previous_sector_code` STRING COMMENT 'Prior sector code before reclassification, null for initial classifications.',
    `previous_sub_industry_code` STRING COMMENT 'Prior sub-industry code before reclassification, null for initial classifications.',
    `primary_classification_flag` BOOLEAN COMMENT 'Indicates whether this is the primary sector classification for the security when multiple schemes are used.',
    `reclassification_reason` STRING COMMENT 'Business rationale for any change in sector classification, such as merger, business model shift, or scheme update.',
    `revenue_percentage` DECIMAL(5,2) COMMENT 'Percentage of company revenue derived from this sector or sub-industry, used for multi-sector companies.',
    `sector_code` STRING COMMENT 'Top-level sector classification code within the chosen scheme.',
    `sector_name` STRING COMMENT 'Human-readable name of the top-level sector.',
    `sedol` STRING COMMENT 'Seven-character alphanumeric code identifying securities traded on the London Stock Exchange and other UK exchanges.. Valid values are `^[0-9A-Z]{7}$`',
    `sub_industry_code` STRING COMMENT 'Fourth-level sub-industry classification code providing the most granular categorization.',
    `sub_industry_name` STRING COMMENT 'Human-readable name of the sub-industry.',
    `created_by` STRING COMMENT 'User or system identifier that created this classification record.',
    CONSTRAINT pk_equity_sector_classification PRIMARY KEY(`equity_sector_classification_id`)
) COMMENT 'Equity sector and industry classification master for listed securities using standard classification schemes. Captures classification scheme (GICS, ICB, NAICS, SIC), sector code, industry group code, industry code, sub-industry code, sector name, industry';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`security_sector_mapping` (
    `security_sector_mapping_id` BIGINT COMMENT 'Unique identifier for the security sector mapping record.',
    `listed_security_id` BIGINT COMMENT 'Reference to the equity security being classified.',
    `benchmark_alignment_flag` BOOLEAN COMMENT 'Indicates whether this classification aligns with the sector classification used in the portfolios primary benchmark index.',
    `benchmark_sector_code` STRING COMMENT 'Sector code as defined by the benchmark index provider for comparison and attribution purposes.',
    `carbon_intensity_sector` STRING COMMENT 'Sector grouping used for greenhouse gas emissions and carbon intensity analysis.',
    `classification_confidence_score` DECIMAL(5,2) COMMENT 'Numeric score representing the confidence or quality of the classification assignment, typically expressed as a percentage.',
    `classification_notes` STRING COMMENT 'Free-text field capturing additional context, commentary, or special considerations regarding the sector classification.',
    `classification_scheme` STRING COMMENT 'Industry classification standard used for sector assignment. GICS (Global Industry Classification Standard), ICB (Industry Classification Benchmark), TRBC (Thomson Reuters Business Classification), BICS (Bloomberg Industry Classification System), NAICS. Valid values are `GICS|ICB|TRBC|BICS|NAICS|SIC`',
    `classification_source` STRING COMMENT 'Data provider or system that supplied the sector classification, such as Bloomberg, MSCI, FactSet, or internal research.',
    `classification_source_identifier` STRING COMMENT 'Unique identifier or reference code from the classification source system.',
    `classification_status` STRING COMMENT 'Current lifecycle status of the sector mapping record.. Valid values are `active|inactive|pending|superseded`',
    `classification_version` STRING COMMENT 'Version or edition of the classification scheme applied, as schemes evolve over time.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this sector mapping record was first created in the system.',
    `cusip` STRING COMMENT 'Nine-character alphanumeric code identifying North American securities.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `data_quality_flag` BOOLEAN COMMENT 'Indicator of the data quality status for this classification record.',
    `effective_date` DATE COMMENT 'Date from which this sector classification becomes valid and applicable for the security.',
    `esg_sector_classification` STRING COMMENT 'Sector classification specific to ESG analysis frameworks, which may differ from financial sector classifications.',
    `expiry_date` DATE COMMENT 'Date on which this sector classification ceases to be valid, nullable for current classifications.',
    `industry_code` STRING COMMENT 'Code representing the industry, a further sub-classification within the industry group.',
    `industry_group_code` STRING COMMENT 'Code representing the industry group, a sub-classification within the sector.',
    `industry_group_name` STRING COMMENT 'Human-readable name of the industry group classification.',
    `industry_name` STRING COMMENT 'Human-readable name of the industry classification.',
    `internal_sector_code` STRING COMMENT 'Proprietary internal sector classification code used for portfolio construction and risk management.',
    `internal_sector_name` STRING COMMENT 'Human-readable name of the internal sector classification.',
    `isin` STRING COMMENT 'ISO 6166 twelve-character alphanumeric code uniquely identifying the security.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Date and time when this sector mapping record was most recently modified.',
    `last_verification_date` DATE COMMENT 'Date when the sector classification was last verified or reviewed by internal teams.',
    `manual_override_flag` BOOLEAN COMMENT 'Indicates whether the classification was manually overridden by internal research or portfolio management teams.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review of the sector classification.',
    `override_by_user` STRING COMMENT 'Username or identifier of the analyst or portfolio manager who performed the manual override.',
    `override_reason` STRING COMMENT 'Explanation for manual override of the sector classification, capturing internal research rationale.',
    `override_timestamp` TIMESTAMP COMMENT 'Date and time when the manual override was applied.',
    `primary_classification_flag` BOOLEAN COMMENT 'Indicates whether this is the primary sector classification for the security when multiple schemes or classifications are assigned.',
    `reclassification_reason` STRING COMMENT 'Business rationale or trigger for sector reclassification, such as corporate action, scheme update, or business model change.',
    `regulatory_sector_classification` STRING COMMENT 'Sector classification required for regulatory reporting to SEC, or other governing bodies.',
    `sector_code` STRING COMMENT 'Numeric or alphanumeric code representing the sector within the classification scheme.',
    `sector_name` STRING COMMENT 'Human-readable name of the sector classification.',
    `sedol` STRING COMMENT 'Seven-character alphanumeric code identifying securities traded on the London Stock Exchange and other UK exchanges.. Valid values are `^[0-9BCDFGHJKLMNPQRSTVWXYZ]{7}$`',
    `sub_industry_code` STRING COMMENT 'Code representing the most granular sub-industry classification level.',
    `sub_industry_name` STRING COMMENT 'Human-readable name of the sub-industry classification.',
    CONSTRAINT pk_security_sector_mapping PRIMARY KEY(`security_sector_mapping_id`)
) COMMENT 'Association table mapping listed equity securities to their sector and industry classifications under one or more classification schemes at a point in time. Captures the effective date, expiry date, primary classification flag, and classification source.';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`stock_selection` (
    `stock_selection_id` BIGINT COMMENT 'Unique identifier for the stock selection decision record.',
    `analyst_employee_id` BIGINT COMMENT 'Reference to the equity analyst who authored this stock selection recommendation.',
    `employee_id` BIGINT COMMENT 'Reference to the equity analyst who authored this stock selection recommendation.',
    `listed_security_id` BIGINT COMMENT 'Reference to the equity security being evaluated for selection.',
    `portfolio_id` BIGINT COMMENT 'Reference to the target portfolio for which this stock selection decision applies.',
    `research_note_id` BIGINT COMMENT 'Reference to the underlying equity research note that supports this selection decision.',
    `valuation_model_id` BIGINT COMMENT 'Reference to the valuation model used to derive intrinsic value for this selection.',
    `active_weight_percent` DECIMAL(8,5) COMMENT 'Recommended active weight relative to benchmark, calculated as target weight minus benchmark weight.',
    `benchmark_weight_percent` DECIMAL(8,5) COMMENT 'Weight of the equity security in the relevant benchmark index as a percentage.',
    `beta` DECIMAL(6,4) COMMENT 'Beta coefficient measuring the equity securitys systematic risk relative to the market benchmark.',
    `conviction_level` STRING COMMENT 'Analysts confidence level in the stock selection recommendation based on research quality and market conditions.. Valid values are `high|medium|low`',
    `country_of_risk` STRING COMMENT 'Three-letter ISO country code representing the primary country of economic risk exposure.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this stock selection record was first created in the system.',
    `current_market_price` DECIMAL(18,4) COMMENT 'Market price of the equity security at the time of the selection decision.',
    `cusip` STRING COMMENT 'CUSIP identifier for the equity security, primarily used in North American markets.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `decision_date` DATE COMMENT 'Date on which the stock selection decision was formally made by the equity investment team.',
    `dividend_yield_percent` DECIMAL(6,4) COMMENT 'Current dividend yield of the equity security as a percentage of market price.',
    `effective_date` DATE COMMENT 'Date from which the stock selection decision becomes effective for portfolio construction and trading.',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether ESG factors were formally integrated into the stock selection decision process.',
    `esg_score` DECIMAL(5,2) COMMENT 'ESG rating score for the equity security from the designated ESG data provider.',
    `expected_return_percent` DECIMAL(8,4) COMMENT 'Expected total return percentage over the investment horizon, including capital appreciation and dividends.',
    `expiry_date` DATE COMMENT 'Date on which the stock selection decision expires and requires review or renewal.',
    `ic_approval_date` DATE COMMENT 'Date on which the Investment Committee formally approved this stock selection decision.',
    `ic_approval_required_flag` BOOLEAN COMMENT 'Indicates whether this stock selection decision requires formal Investment Committee approval before implementation.',
    `implementation_date` DATE COMMENT 'Date on which the stock selection decision was fully implemented into the portfolio through trade execution.',
    `implementation_status` STRING COMMENT 'Status of the execution and implementation of the stock selection decision into the portfolio.. Valid values are `pending|in_progress|completed|cancelled`',
    `intrinsic_value` DECIMAL(18,4) COMMENT 'Calculated intrinsic value per share derived from the valuation model, representing fundamental fair value.',
    `investment_horizon_months` BIGINT COMMENT 'Time horizon in months over which the stock selection recommendation applies.',
    `investment_thesis_summary` STRING COMMENT 'Concise summary of the core investment thesis supporting the stock selection decision.',
    `isin` STRING COMMENT 'International Securities Identification Number for the equity security under selection.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `key_catalysts` STRING COMMENT 'Identified catalysts expected to drive price movement toward the target price.',
    `key_risks` STRING COMMENT 'Primary risks that could prevent the investment thesis from materializing.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this stock selection record was last modified.',
    `market_capitalization_tier` STRING COMMENT 'Market capitalization size classification of the equity security.. Valid values are `large_cap|mid_cap|small_cap|micro_cap`',
    `price_to_earnings_ratio` DECIMAL(8,2) COMMENT 'Price-to-earnings ratio of the equity security at the time of selection decision.',
    `recommendation` STRING COMMENT 'Formal investment recommendation for the equity security relative to portfolio construction objectives.. Valid values are `buy|overweight|hold|underweight|sell|avoid`',
    `sector_classification` STRING COMMENT 'Industry sector classification of the equity security per standard taxonomy.',
    `security_name` STRING COMMENT 'Full legal name of the equity security issuer.',
    `sedol` STRING COMMENT 'SEDOL identifier for the equity security, primarily used in UK and European markets.. Valid values are `^[0-9A-Z]{7}$`',
    `selection_decision_code` STRING COMMENT 'Unique business identifier for this stock selection decision, used for external reference and audit trails.. Valid values are `^[A-Z0-9]{6,12}$`',
    `selection_status` STRING COMMENT 'Current lifecycle status of the stock selection decision within the investment approval workflow.. Valid values are `draft|submitted|approved|rejected|implemented|withdrawn`',
    `style_factor` STRING COMMENT 'Primary investment style factor characterizing the equity security.. Valid values are `growth|value|blend|quality|momentum`',
    `target_position_value_base_currency` DECIMAL(18,2) COMMENT 'Recommended absolute position value for the equity security in the portfolios base currency.',
    `target_price` DECIMAL(18,4) COMMENT 'Analyst target price for the equity security over the investment horizon.',
    `target_weight_percent` DECIMAL(8,5) COMMENT 'Recommended portfolio weight for the equity security as a percentage of total portfolio value.',
    `ticker_symbol` STRING COMMENT 'Exchange ticker symbol for the equity security.',
    `upside_downside_percent` DECIMAL(8,4) COMMENT 'Expected percentage return from current market price to target price, representing potential upside or downside.',
    CONSTRAINT pk_stock_selection PRIMARY KEY(`stock_selection_id`)
) COMMENT 'Formal stock selection and portfolio-construction decision records produced by the equity investment team for securities in the coverage universe, bridging research output (research_note theses and valuation_model intrinsic values) to portfolio';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`valuation_model` (
    `valuation_model_id` BIGINT COMMENT 'Unique identifier for the proprietary equity valuation model record maintained by the internal research team.',
    `analyst_employee_id` BIGINT COMMENT 'Reference to the internal research analyst responsible for building and maintaining this valuation model.',
    `employee_id` BIGINT COMMENT 'Reference to the internal research analyst responsible for building and maintaining this valuation model.',
    `listed_security_id` BIGINT COMMENT 'Reference to the equity security being valued in this model.',
    `approval_date` DATE COMMENT 'Date when the valuation model was formally approved for use in investment decision-making.',
    `approved_by` STRING COMMENT 'Name or identifier of the senior analyst or investment committee member who approved the valuation model for use.',
    `capex_percent_of_revenue` DECIMAL(10,4) COMMENT 'Capital expenditure as a percentage of revenue, used to estimate reinvestment needs in DCF models.',
    `comparable_multiple_type` STRING COMMENT 'Type of valuation multiple used: EV/EBITDA, P/E, P/B, EV/Sales, PEG, or other industry-specific metric. [ENUM-REF-CANDIDATE: EV/EBITDA|P/E|P/B|EV/Sales|PEG|EV/EBIT|P/S|Dividend Yield — promote to reference product]',
    `comparable_multiple_value` DECIMAL(18,4) COMMENT 'Valuation multiple derived from comparable companies or transactions, such as EV/EBITDA or P/E ratio.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the valuation model record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code in which the intrinsic value estimate is denominated.. Valid values are `^[A-Z]{3}$`',
    `cusip` STRING COMMENT 'CUSIP identifier for the equity security, primarily used in North American markets.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `data_source` STRING COMMENT 'Primary data source or system from which financial data and market information for the model were obtained.',
    `discount_rate_percent` DECIMAL(10,6) COMMENT 'Weighted Average Cost of Capital or required rate of return used to discount future cash flows in DCF models.',
    `ebitda_margin_percent` DECIMAL(10,4) COMMENT 'EBITDA as a percentage of revenue, representing operational profitability assumption in the model.',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether ESG factors have been explicitly integrated into the valuation model assumptions and risk assessment.',
    `forecast_period_years` BIGINT COMMENT 'Number of years for which explicit cash flow or earnings forecasts are modeled before terminal value.',
    `intrinsic_value_estimate` DECIMAL(18,4) COMMENT 'Calculated fair value per share based on the valuation model methodology and assumptions.',
    `isin` STRING COMMENT 'International Securities Identification Number uniquely identifying the equity security being valued.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `key_assumptions` STRING COMMENT 'Summary of critical assumptions underpinning the valuation model, including macroeconomic, industry, and company-specific factors.',
    `key_risks` STRING COMMENT 'Summary of principal risks that could cause actual outcomes to differ materially from the valuation model estimates.',
    `last_review_date` DATE COMMENT 'Date when the valuation model was last reviewed and updated by the research analyst.',
    `model_confidence_level` STRING COMMENT 'Analyst assessment of confidence in the valuation model output based on data quality, assumption robustness, and market conditions.. Valid values are `High|Medium|Low`',
    `model_documentation_url` STRING COMMENT 'Link to detailed model documentation, investment memorandum, or research report supporting the valuation.',
    `model_notes` STRING COMMENT 'Additional commentary, caveats, or qualitative observations from the analyst regarding the valuation model.',
    `model_status` STRING COMMENT 'Current lifecycle status of the valuation model indicating whether it is actively maintained or archived.. Valid values are `Active|Under Review|Suspended|Archived|Discontinued`',
    `model_type` STRING COMMENT 'Type of valuation methodology applied: Discounted Cash Flow, Dividend Discount Model, Enterprise Value to EBITDA multiple, Price-to-Earnings relative, Sum-of-Parts, Net Asset Value-based, or other.',
    `model_version` STRING COMMENT 'Version identifier for the valuation model, tracking iterations and updates to methodology or assumptions.',
    `net_margin_percent` DECIMAL(10,4) COMMENT 'Net income as a percentage of revenue, representing bottom-line profitability assumption.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review and update of the valuation model.',
    `peer_group_median_multiple` DECIMAL(18,4) COMMENT 'Median valuation multiple of the selected peer group used for relative valuation benchmarking.',
    `recommendation` STRING COMMENT 'Analyst investment recommendation based on the valuation model output and qualitative assessment. [ENUM-REF-CANDIDATE: Strong Buy|Buy|Hold|Reduce|Sell|Under Review|Not Rated — 7 candidates stripped; promote to reference product]',
    `research_team` STRING COMMENT 'Name of the internal research team or sector coverage group responsible for this valuation model.',
    `revenue_cagr_percent` DECIMAL(10,4) COMMENT 'Compound annual growth rate of revenue assumed over the forecast period.',
    `scenario_analysis_flag` BOOLEAN COMMENT 'Indicates whether scenario analysis has been performed to model bull, base, and bear case valuation outcomes.',
    `sedol` STRING COMMENT 'SEDOL identifier for the equity security, primarily used in UK and Irish markets.. Valid values are `^[0-9A-Z]{7}$`',
    `sensitivity_analysis_flag` BOOLEAN COMMENT 'Indicates whether sensitivity analysis has been performed to assess valuation impact of key assumption changes.',
    `target_price` DECIMAL(18,4) COMMENT 'Analyst target price per share for the security, typically representing expected price at a future horizon.',
    `target_price_horizon_months` BIGINT COMMENT 'Time horizon in months over which the target price is expected to be achieved.',
    `terminal_growth_rate_percent` DECIMAL(10,6) COMMENT 'Perpetual growth rate assumption applied in the terminal value calculation for DCF models.',
    `ticker_symbol` STRING COMMENT 'Exchange ticker symbol for the equity security.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the valuation model record was last modified or updated.',
    `upside_downside_percent` DECIMAL(10,4) COMMENT 'Percentage difference between target price and current market price, indicating expected return potential.',
    `valuation_date` DATE COMMENT 'As-of date for which the intrinsic value estimate is calculated.',
    `working_capital_percent_of_revenue` DECIMAL(10,4) COMMENT 'Working capital requirement as a percentage of revenue, used to estimate cash flow adjustments.',
    CONSTRAINT pk_valuation_model PRIMARY KEY(`valuation_model_id`)
) COMMENT 'Proprietary equity valuation model records maintained by the internal research team for covered securities. Captures model type (DCF, DDM, EV/EBITDA, P/E relative, sum-of-parts, NAV-based), model version, valuation date, intrinsic value estimate';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`equity_issuer` (
    `equity_issuer_id` BIGINT COMMENT 'Unique identifier for the corporate issuer entity whose equity securities are held or covered by the fund.',
    `parent_issuer_equity_issuer_id` BIGINT COMMENT 'Reference to the ultimate parent company issuer if this issuer is a subsidiary within a corporate group structure.',
    `accounting_standard` STRING COMMENT 'The primary accounting standard framework used by the issuer for financial statement preparation and reporting.. Valid values are `IFRS|US_GAAP|local_GAAP|other`',
    `auditor_name` STRING COMMENT 'The name of the external audit firm responsible for auditing the issuers financial statements.',
    `carbon_intensity` DECIMAL(12,2) COMMENT 'Greenhouse gas emissions intensity measured as tonnes of CO2 equivalent per million USD revenue, used for climate risk assessment.',
    `ceo_name` STRING COMMENT 'Full name of the current Chief Executive Officer leading the issuers executive management team.',
    `cfo_name` STRING COMMENT 'Full name of the current Chief Financial Officer responsible for the issuers financial management and reporting.',
    `coverage_initiation_date` DATE COMMENT 'The date on which the pension fund initiated research coverage and monitoring of this equity issuer.',
    `coverage_status` STRING COMMENT 'Current status of the pension funds research coverage and monitoring activity for this issuer.. Valid values are `active|inactive|suspended|terminated`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this issuer master data record was first created in the system.',
    `credit_rating_fitch` STRING COMMENT 'The current long-term issuer credit rating assigned by Fitch Ratings agency.',
    `credit_rating_moody` STRING COMMENT 'The current long-term issuer credit rating assigned by Moodys Investors Service rating agency.',
    `credit_rating_sp` STRING COMMENT 'The current long-term issuer credit rating assigned by Standard and Poors rating agency.',
    `data_source` STRING COMMENT 'The source system or data provider from which this issuer master data record was obtained or last updated.',
    `employee_count` BIGINT COMMENT 'Total number of full-time equivalent employees working for the issuer globally as of the most recent reporting period.',
    `fiscal_year_end_day` BIGINT COMMENT 'The day of the month on which the issuers fiscal year ends for financial reporting purposes.',
    `fiscal_year_end_month` BIGINT COMMENT 'The month number (1-12) in which the issuers fiscal year ends for financial reporting purposes.',
    `gics_industry_code` STRING COMMENT 'Six-digit GICS industry code providing detailed classification of the issuers specific industry segment.. Valid values are `^[0-9]{6}$`',
    `gics_industry_group_code` STRING COMMENT 'Four-digit GICS industry group code providing more granular classification of the issuers business activities.. Valid values are `^[0-9]{4}$`',
    `gics_sector_code` STRING COMMENT 'Two-digit GICS sector code classifying the issuers primary business activity at the highest industry classification level.. Valid values are `^[0-9]{2}$`',
    `gics_sub_industry_code` STRING COMMENT 'Eight-digit GICS sub-industry code providing the most granular classification of the issuers business activities.. Valid values are `^[0-9]{8}$`',
    `headquarters_address` STRING COMMENT 'Full street address of the issuers principal executive offices and headquarters location.',
    `headquarters_city` STRING COMMENT 'The city where the issuers principal executive offices and headquarters are located.',
    `headquarters_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the location of the issuers principal executive offices.. Valid values are `^[A-Z]{3}$`',
    `incorporation_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the jurisdiction where the issuer is legally incorporated.. Valid values are `^[A-Z]{3}$`',
    `incorporation_date` DATE COMMENT 'The date on which the issuer was legally incorporated or established in its jurisdiction.',
    `investment_grade_flag` BOOLEAN COMMENT 'Boolean indicator of whether the issuer holds investment grade credit ratings (BBB-/Baa3 or higher) from major rating agencies.',
    `investor_relations_email` STRING COMMENT 'Primary email contact for investor relations inquiries and shareholder communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `investor_relations_phone` STRING COMMENT 'Primary telephone contact number for investor relations department and shareholder inquiries.',
    `issuer_status` STRING COMMENT 'Current operational and market status of the issuer reflecting its lifecycle state. [ENUM-REF-CANDIDATE: active|inactive|merged|acquired|delisted|bankrupt|liquidated — 7 candidates stripped; promote to reference product]',
    `issuer_type` STRING COMMENT 'Classification of the issuer entity type indicating its legal and organizational structure. [ENUM-REF-CANDIDATE: public_corporation|private_corporation|government_entity|supranational|reit|trust|partnership — 7 candidates stripped; promote to reference',
    `legal_name` STRING COMMENT 'The official registered legal name of the corporate issuer as recorded in incorporation documents.',
    `lei` STRING COMMENT 'The 20-character ISO 17442 Legal Entity Identifier uniquely identifying the issuer in global financial markets.. Valid values are `^[A-Z0-9]{20}$`',
    `market_capitalization_tier` STRING COMMENT 'Classification of the issuer based on total market capitalization size for portfolio construction and benchmark alignment.. Valid values are `mega_cap|large_cap|mid_cap|small_cap|micro_cap|nano_cap`',
    `msci_esg_rating` STRING COMMENT 'The MSCI ESG rating assessing the issuers management of financially relevant environmental, social, and governance risks. [ENUM-REF-CANDIDATE: AAA|AA|A|BBB|BB|B|CCC — 7 candidates stripped; promote to reference product]',
    `net_zero_commitment_flag` BOOLEAN COMMENT 'Boolean indicator of whether the issuer has made a public commitment to achieve net zero greenhouse gas emissions by a target date.',
    `net_zero_target_year` BIGINT COMMENT 'The calendar year by which the issuer has committed to achieve net zero greenhouse gas emissions, if applicable.',
    `primary_exchange_code` STRING COMMENT 'Market Identifier Code (MIC) of the primary stock exchange where the issuers equity securities are listed and traded.',
    `primary_listing_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the issuers primary listed equity securities are denominated and traded.. Valid values are `^[A-Z]{3}$`',
    `primary_listing_ticker` STRING COMMENT 'The ticker symbol under which the issuers equity securities trade on the primary exchange.',
    `record_version` BIGINT COMMENT 'Version number tracking the number of updates made to this issuer master data record for change management and audit purposes.',
    `short_name` STRING COMMENT 'Commonly used abbreviated or trading name of the issuer for operational and reporting purposes.',
    `sustainalytics_esg_risk_score` DECIMAL(5,2) COMMENT 'Sustainalytics ESG Risk Score measuring the magnitude of unmanaged ESG risks facing the issuer (0-100 scale, higher is riskier).',
    `ultimate_parent_lei` STRING COMMENT 'The Legal Entity Identifier of the ultimate parent entity at the top of the corporate ownership hierarchy.. Valid values are `^[A-Z0-9]{20}$`',
    `updated_by` STRING COMMENT 'The user identifier or system process that performed the most recent update to this issuer master data record.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this issuer master data record was most recently updated or modified.',
    `website_url` STRING COMMENT 'The primary corporate website URL for the issuer providing investor relations and company information.',
    CONSTRAINT pk_equity_issuer PRIMARY KEY(`equity_issuer_id`)
) COMMENT 'Corporate issuer master data for companies whose equity securities are held or covered by the fund. Captures legal entity name, LEI, headquarters country, incorporation jurisdiction, primary stock exchange, primary listing currency, parent company';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`issuer_financials` (
    `issuer_financials_id` BIGINT COMMENT 'Unique identifier for the issuer financial record.',
    `listed_security_id` BIGINT COMMENT 'Reference to the equity security for which financial data is reported.',
    `capital_expenditures` DECIMAL(20,2) COMMENT 'Cash spent on property, plant, equipment, and intangible assets during the period, in reporting currency.',
    `cash_and_equivalents` DECIMAL(20,2) COMMENT 'Cash and highly liquid short-term investments as of period end, in reporting currency.',
    `cost_of_revenue` DECIMAL(20,2) COMMENT 'Direct costs attributable to revenue generation, in reporting currency.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this financial record was first created in the system.',
    `cusip` STRING COMMENT 'CUSIP identifier for North American securities.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `data_provider` STRING COMMENT 'Name of the financial data vendor or source providing this financial information.',
    `data_quality_flag` BOOLEAN COMMENT 'Indicator of data quality and verification status.',
    `data_source_type` STRING COMMENT 'Classification of the financial data source: reported actuals, analyst consensus estimates, restated figures, or preliminary results.. Valid values are `reported|consensus|restated|preliminary`',
    `depreciation_amortization` DECIMAL(20,2) COMMENT 'Total depreciation and amortization expense for the period, in reporting currency.',
    `dividends_paid` DECIMAL(20,2) COMMENT 'Total cash dividends paid to shareholders during the period, in reporting currency.',
    `ebit` DECIMAL(20,2) COMMENT 'Operating income or earnings before interest and taxes, in reporting currency.',
    `ebitda` DECIMAL(20,2) COMMENT 'Earnings before interest, taxes, depreciation, and amortization, in reporting currency.',
    `eps_basic` DECIMAL(10,4) COMMENT 'Basic earnings per share calculated as net income divided by weighted average shares outstanding.',
    `eps_diluted` DECIMAL(10,4) COMMENT 'Diluted earnings per share accounting for potential dilution from convertible securities and options.',
    `filing_date` DATE COMMENT 'Date when the financial statements were filed with regulatory authorities.',
    `financing_cash_flow` DECIMAL(20,2) COMMENT 'Net cash provided by or used in financing activities for the period, in reporting currency.',
    `fiscal_period_type` STRING COMMENT 'Type of reporting period for the financial data.. Valid values are `annual|semi-annual|quarterly|interim`',
    `fiscal_quarter` BIGINT COMMENT 'Fiscal quarter within the year, if applicable (1-4).',
    `fiscal_year` BIGINT COMMENT 'Fiscal year for which the financial data is reported.',
    `free_cash_flow` DECIMAL(20,2) COMMENT 'Operating cash flow minus capital expenditures, in reporting currency.',
    `gross_profit` DECIMAL(20,2) COMMENT 'Revenue minus cost of revenue, in reporting currency.',
    `income_tax_expense` DECIMAL(20,2) COMMENT 'Total income tax expense for the period, in reporting currency.',
    `interest_expense` DECIMAL(20,2) COMMENT 'Total interest expense on debt and other obligations, in reporting currency.',
    `interest_income` DECIMAL(20,2) COMMENT 'Interest income earned on cash, investments, and receivables, in reporting currency.',
    `investing_cash_flow` DECIMAL(20,2) COMMENT 'Net cash used in investing activities for the period, in reporting currency.',
    `isin` STRING COMMENT 'ISO 6166 International Securities Identification Number for the equity security.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `issuer_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the issuer.. Valid values are `^[A-Z0-9]{20}$`',
    `issuer_name` STRING COMMENT 'Legal name of the issuing company or entity.',
    `net_income` DECIMAL(20,2) COMMENT 'Net income attributable to common shareholders after all expenses and taxes, in reporting currency.',
    `operating_cash_flow` DECIMAL(20,2) COMMENT 'Net cash provided by operating activities for the period, in reporting currency.',
    `operating_expenses` DECIMAL(20,2) COMMENT 'Total operating expenses including selling, general, and administrative expenses, in reporting currency.',
    `other_income_expense` DECIMAL(20,2) COMMENT 'Non-operating income and expenses not classified elsewhere, in reporting currency.',
    `period_end_date` DATE COMMENT 'End date of the fiscal reporting period.',
    `pretax_income` DECIMAL(20,2) COMMENT 'Income before income tax expense, in reporting currency.',
    `reporting_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which financial figures are reported.. Valid values are `^[A-Z]{3}$`',
    `reporting_date` DATE COMMENT 'Date when the financial results were officially reported or filed.',
    `revenue` DECIMAL(20,2) COMMENT 'Total revenue or net sales for the reporting period, in reporting currency.',
    `sedol` STRING COMMENT 'SEDOL identifier for securities traded on London Stock Exchange and other exchanges.. Valid values are `^[0-9BCDFGHJKLMNPQRSTVWXYZ]{7}$`',
    `shares_outstanding_basic` DECIMAL(18,2) COMMENT 'Weighted average number of basic shares outstanding during the period.',
    `shares_outstanding_diluted` DECIMAL(18,2) COMMENT 'Weighted average number of diluted shares outstanding including potential dilutive securities.',
    `ticker_symbol` STRING COMMENT 'Exchange ticker symbol for the equity security.',
    `total_assets` DECIMAL(20,2) COMMENT 'Total assets on the balance sheet as of period end, in reporting currency.',
    `total_debt` DECIMAL(20,2) COMMENT 'Total short-term and long-term debt outstanding as of period end, in reporting currency.',
    `total_equity` DECIMAL(20,2) COMMENT 'Total shareholders equity as of period end, in reporting currency.',
    `total_liabilities` DECIMAL(20,2) COMMENT 'Total liabilities on the balance sheet as of period end, in reporting currency.',
    CONSTRAINT pk_issuer_financials PRIMARY KEY(`issuer_financials_id`)
) COMMENT 'Standardized fundamental financial data for equity issuers, capturing reported and consensus financial metrics used in equity analysis. Includes period type (annual, semi-annual, quarterly), reporting date, revenue, EBITDA, EBIT, net income, EPS (basic';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`dividend_record` (
    `dividend_record_id` BIGINT COMMENT 'Unique identifier for the dividend income record.',
    `corporate_action_id` BIGINT COMMENT 'External reference identifier for the corporate action event from the data provider or custodian.',
    `equity_position_id` BIGINT COMMENT 'Reference to the specific equity position record associated with this dividend.',
    `listed_security_id` BIGINT COMMENT 'Reference to the equity security that declared the dividend.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio holding the equity position that generated this dividend.',
    `accrual_date` DATE COMMENT 'Date on which the dividend income was accrued in the fund accounting records, typically the ex-dividend date.',
    `base_currency_code` STRING COMMENT 'ISO 4217 three-letter code for the fund reporting base currency.. Valid values are `^[A-Z]{3}$`',
    `country_of_domicile` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the legal jurisdiction where the issuer is incorporated.. Valid values are `^[A-Z]{3}$`',
    `country_of_risk` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the primary country where the issuer operates and generates revenue.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this dividend record was first created in the system.',
    `cusip` STRING COMMENT 'Nine-character alphanumeric code identifying North American securities.. Valid values are `^[0-9]{3}[0-9A-Z]{5}[0-9]$`',
    `custodian_account_number` STRING COMMENT 'Account number at the custodian bank where the dividend cash was received.',
    `custodian_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier of the custodian bank that received and processed the dividend payment.. Valid values are `^[A-Z0-9]{20}$`',
    `data_source` STRING COMMENT 'System or vendor that provided the dividend corporate action data, such as Bloomberg, custodian feed, or internal research.',
    `declaration_date` DATE COMMENT 'Date on which the issuer board of directors announced the dividend payment.',
    `dividend_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the dividend is declared and paid.. Valid values are `^[A-Z]{3}$`',
    `dividend_frequency` STRING COMMENT 'Typical frequency at which the issuer pays dividends: annual, semi-annual, quarterly, monthly, or irregular.. Valid values are `annual|semi_annual|quarterly|monthly|irregular`',
    `dividend_rate_per_share` DECIMAL(18,6) COMMENT 'Declared dividend amount per share in the dividend currency.',
    `dividend_status` STRING COMMENT 'Current lifecycle status of the dividend: declared by issuer, accrued in accounting, paid and received, cancelled by issuer, or pending settlement.. Valid values are `declared|accrued|paid|cancelled|pending`',
    `dividend_type` STRING COMMENT 'Classification of the dividend payment: ordinary recurring dividend, special one-time dividend, interim mid-year payment, final year-end payment, liquidating distribution, or return of capital.. Valid values are `ordinary|special|interim|final|liquidating|return_of_capital`',
    `ex_dividend_date` DATE COMMENT 'First trading date on which the security trades without the dividend entitlement; positions held before this date are entitled to the dividend.',
    `fx_rate` DECIMAL(18,8) COMMENT 'Exchange rate used to convert dividend amounts from dividend currency to base currency, expressed as base currency per unit of dividend currency.',
    `fx_rate_date` DATE COMMENT 'Date on which the FX rate was observed or fixed for currency conversion.',
    `gross_dividend_amount_base` DECIMAL(18,2) COMMENT 'Total gross dividend income converted to the fund base currency before withholding taxes.',
    `gross_dividend_amount_local` DECIMAL(18,2) COMMENT 'Total gross dividend income in the dividend currency before any withholding taxes or fees.',
    `isin` STRING COMMENT 'ISO 6166 standard 12-character alphanumeric code uniquely identifying the equity security.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `net_dividend_amount_base` DECIMAL(18,2) COMMENT 'Net dividend income received after withholding tax, converted to the fund base currency.',
    `net_dividend_amount_local` DECIMAL(18,2) COMMENT 'Net dividend income received after withholding tax deduction, in the dividend currency.',
    `notes` STRING COMMENT 'Free-text field for additional commentary, exceptions, or special handling instructions related to this dividend record.',
    `payment_date` DATE COMMENT 'Date on which the dividend cash is distributed to entitled shareholders.',
    `quantity_held` DECIMAL(18,4) COMMENT 'Number of shares held in the portfolio on the record date that are entitled to receive the dividend.',
    `record_date` DATE COMMENT 'Date on which shareholders must be registered on the issuer books to receive the dividend payment.',
    `record_version` BIGINT COMMENT 'Version number incremented with each update to support change tracking and audit history.',
    `reinvestment_flag` BOOLEAN COMMENT 'Indicates whether the dividend was reinvested into additional shares of the security rather than received as cash.',
    `sector_classification` STRING COMMENT 'Industry sector classification of the equity issuer using GICS, ICB, or internal taxonomy.',
    `security_name` STRING COMMENT 'Full legal name of the equity security issuer.',
    `sedol` STRING COMMENT 'Seven-character alphanumeric code identifying securities traded on the London Stock Exchange and other UK exchanges.. Valid values are `^[0-9A-Z]{7}$`',
    `settlement_date` DATE COMMENT 'Date on which the dividend cash was actually received and settled in the fund custody account.',
    `tax_reclaim_amount_local` DECIMAL(18,2) COMMENT 'Estimated or actual amount of withholding tax eligible for reclaim in the dividend currency.',
    `tax_reclaim_eligible_flag` BOOLEAN COMMENT 'Indicates whether the fund is eligible to reclaim a portion of the withheld tax under applicable tax treaties.',
    `tax_reclaim_status` STRING COMMENT 'Current status of the tax reclaim process: not applicable, pending initiation, submitted to tax authority, approved for payment, cash received, or rejected.. Valid values are `not_applicable|pending|submitted|approved|received|rejected`',
    `ticker_symbol` STRING COMMENT 'Exchange trading symbol for the equity security.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this dividend record was last modified.',
    `withholding_tax_amount_base` DECIMAL(18,2) COMMENT 'Withholding tax amount converted to the fund base currency.',
    `withholding_tax_amount_local` DECIMAL(18,2) COMMENT 'Absolute amount of tax withheld at source in the dividend currency.',
    `withholding_tax_rate_percent` DECIMAL(5,2) COMMENT 'Percentage rate of tax withheld at source by the issuer jurisdiction on the gross dividend.',
    CONSTRAINT pk_dividend_record PRIMARY KEY(`dividend_record_id`)
) COMMENT 'Dividend income records for equity positions held by the fund, capturing declared dividends, accrued income, and received cash flows at the security-portfolio level.';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`proxy_voting_record` (
    `proxy_voting_record_id` BIGINT COMMENT 'Unique identifier for the proxy voting record.',
    `employee_id` BIGINT COMMENT 'Reference to the responsible investment or ESG analyst who reviewed the resolution.',
    `listed_security_id` BIGINT COMMENT 'Reference to the equity security for which the proxy vote was cast.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio holding the equity position at the time of the vote.',
    `responsible_investment_analyst_employee_id` BIGINT COMMENT 'Reference to the responsible investment or ESG analyst who reviewed the resolution.',
    `ballot_reference` STRING COMMENT 'Unique identifier for the ballot or resolution within the meeting.',
    `cusip` STRING COMMENT 'CUSIP identifier for the equity security.. Valid values are `^[0-9]{3}[0-9A-Z]{5}[0-9]$`',
    `custodian_account_number` STRING COMMENT 'Account number at the custodian bank for the portfolio holding the shares.',
    `custodian_name` STRING COMMENT 'Name of the custodian bank holding the shares and facilitating the proxy voting process.',
    `disclosure_required_flag` BOOLEAN COMMENT 'Indicates whether the vote must be disclosed publicly or to beneficiaries under regulatory or policy requirements.',
    `esg_relevance_flag` BOOLEAN COMMENT 'Indicates whether the resolution has material Environmental, Social, or Governance (ESG) implications.',
    `esg_theme` STRING COMMENT 'Primary ESG theme associated with the resolution (e.g., Climate Change, Board Diversity, Executive Pay, Human Rights).',
    `fund_vote_decision` STRING COMMENT 'Actual voting decision made by the pension fund: For, Against, Abstain, Withhold, Do Not Vote, or Take No Action.. Valid values are `For|Against|Abstain|Withhold|Do Not Vote|Take No Action`',
    `isin` STRING COMMENT 'International Securities Identification Number for the equity security.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `issuer_lei` STRING COMMENT 'Legal Entity Identifier of the issuer company.. Valid values are `^[A-Z0-9]{20}$`',
    `issuer_name` STRING COMMENT 'Legal name of the company issuing the equity security.',
    `management_recommendation` STRING COMMENT 'Voting recommendation provided by the company management: For, Against, Abstain, or No Recommendation.. Valid values are `For|Against|Abstain|No Recommendation`',
    `meeting_country_code` STRING COMMENT 'Three-letter ISO country code for the jurisdiction where the meeting was held.. Valid values are `^[A-Z]{3}$`',
    `meeting_date` DATE COMMENT 'Date on which the shareholder meeting was held.',
    `meeting_location` STRING COMMENT 'Physical or virtual location where the shareholder meeting was held.',
    `meeting_outcome` STRING COMMENT 'Final outcome of the resolution vote: Passed, Failed, Withdrawn, Postponed, or Pending.. Valid values are `Passed|Failed|Withdrawn|Postponed|Pending`',
    `meeting_type` STRING COMMENT 'Type of shareholder meeting: Annual General Meeting (AGM), Extraordinary General Meeting (EGM), Special, Class, Adjourned, or Written Consent.. Valid values are `AGM|EGM|Special|Class|Adjourned|Written Consent`',
    `policy_alignment_flag` BOOLEAN COMMENT 'Indicates whether the funds vote aligned with its internal proxy voting policy guidelines.',
    `proxy_advisor_name` STRING COMMENT 'Name of the proxy advisory firm providing the voting recommendation.',
    `proxy_advisor_recommendation` STRING COMMENT 'Voting recommendation provided by the external proxy advisory firm (e.g., ISS, Glass Lewis): For, Against, Abstain, or No Recommendation.. Valid values are `For|Against|Abstain|No Recommendation`',
    `proxy_service_provider` STRING COMMENT 'Name of the third-party proxy voting service provider or platform used to manage and submit votes.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Date and time when this proxy voting record was first created in the system.',
    `record_date` DATE COMMENT 'Date on which shareholders must be registered to be eligible to vote at the meeting.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Date and time when this proxy voting record was last updated.',
    `resolution_category` STRING COMMENT 'Classification of the resolution type: Director Election, Executive Compensation, Audit, Capital Structure, Merger and Acquisition, Shareholder Proposal, Governance, Environmental Social and Governance (ESG), or Other.',
    `resolution_description` STRING COMMENT 'Full text or summary description of the resolution being voted upon.',
    `resolution_number` STRING COMMENT 'Sequential number or code assigned to the resolution on the meeting agenda.',
    `resolution_sub_category` STRING COMMENT 'Detailed sub-classification of the resolution within the primary category.',
    `sedol` STRING COMMENT 'SEDOL identifier for the equity security.. Valid values are `^[0-9A-Z]{7}$`',
    `shares_entitled` DECIMAL(18,4) COMMENT 'Total number of shares held by the fund that were entitled to vote on the record date.',
    `shares_voted` DECIMAL(18,4) COMMENT 'Number of shares voted by the fund on this resolution.',
    `ticker_symbol` STRING COMMENT 'Exchange ticker symbol for the equity security.',
    `vote_approved_by` STRING COMMENT 'Name or identifier of the individual or committee who approved the voting decision.',
    `vote_approved_timestamp` TIMESTAMP COMMENT 'Date and time when the voting decision was formally approved.',
    `vote_confirmation_number` STRING COMMENT 'Confirmation or reference number provided by the proxy service provider upon successful vote submission.',
    `vote_rationale` STRING COMMENT 'Explanation or justification for the funds voting decision, particularly when deviating from policy or advisor recommendations.',
    `vote_review_status` STRING COMMENT 'Status of internal review and approval process for the vote: Pending, Reviewed, Approved, or Escalated.. Valid values are `Pending|Reviewed|Approved|Escalated`',
    `vote_submission_method` STRING COMMENT 'Method by which the vote was submitted: Electronic, Paper, Proxy Card, Custodian, or Third-Party Platform.. Valid values are `Electronic|Paper|Proxy Card|Custodian|Third-Party Platform`',
    `vote_submission_timestamp` TIMESTAMP COMMENT 'Date and time when the vote was submitted to the proxy service provider or custodian.',
    `votes_abstain_percent` DECIMAL(8,4) COMMENT 'Percentage of total votes abstained from the resolution across all shareholders.',
    `votes_against_percent` DECIMAL(8,4) COMMENT 'Percentage of total votes cast against the resolution across all shareholders.',
    `votes_for_percent` DECIMAL(8,4) COMMENT 'Percentage of total votes cast in favor of the resolution across all shareholders.',
    `voting_power_percent` DECIMAL(8,4) COMMENT 'Percentage of total outstanding shares represented by the funds vote.',
    CONSTRAINT pk_proxy_voting_record PRIMARY KEY(`proxy_voting_record_id`)
) COMMENT 'Records of the funds proxy voting decisions and outcomes for shareholder meetings of equity holdings. Captures meeting type (AGM, EGM), meeting date, resolution number, resolution description, resolution category (director election, executive';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`engagement_log` (
    `engagement_log_id` BIGINT COMMENT 'Unique identifier for the engagement log record.',
    `employee_id` BIGINT COMMENT 'Reference to the internal analyst or stewardship team member who led the engagement.',
    `engagement_controversy_id` BIGINT COMMENT 'Reference to a related ESG controversy record that triggered or informed the engagement.',
    `engagement_related_controversy_id` BIGINT COMMENT 'Reference to a related ESG controversy record that triggered or informed the engagement.',
    `lead_analyst_employee_id` BIGINT COMMENT 'Reference to the internal analyst or stewardship team member who led the engagement.',
    `listed_security_id` BIGINT COMMENT 'Reference to the equity security that is the subject of this engagement.',
    `related_proxy_vote_proxy_voting_record_id` BIGINT COMMENT 'Reference to a related proxy vote record if the engagement is connected to a voting decision.',
    `related_proxy_voting_record_id` BIGINT COMMENT 'Reference to a related proxy vote record if the engagement is connected to a voting decision.',
    `active_flag` BOOLEAN COMMENT 'Indicates whether the engagement log record is currently active or has been archived.',
    `collaborative_partner_names` STRING COMMENT 'Names of other institutional investors or organizations that participated in collaborative engagement.',
    `confidentiality_level` STRING COMMENT 'Confidentiality classification of the engagement record and associated documentation.. Valid values are `public|internal|confidential|restricted`',
    `country_of_domicile` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the issuers country of legal domicile.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the engagement log record was first created in the system.',
    `data_source` STRING COMMENT 'Source system or application from which the engagement log record originated.',
    `document_reference_url` STRING COMMENT 'URL or file path to supporting documentation or correspondence related to the engagement.',
    `engagement_date` DATE COMMENT 'Date on which the engagement activity occurred.',
    `engagement_duration_minutes` BIGINT COMMENT 'Duration of the engagement activity measured in minutes.',
    `engagement_mode` STRING COMMENT 'Mode of engagement indicating whether conducted directly or through collaborative channels.. Valid values are `direct|collaborative|proxy_advisor|industry_coalition`',
    `engagement_notes` STRING COMMENT 'Detailed internal notes and observations from the engagement activity.',
    `engagement_objective` STRING COMMENT 'Stated objective or goal the fund seeks to achieve through this engagement.',
    `engagement_status` STRING COMMENT 'Current status of the engagement in its lifecycle.. Valid values are `initiated|ongoing|resolved|escalated|closed`',
    `engagement_type` STRING COMMENT 'Type or format of the engagement activity conducted with the issuer.. Valid values are `letter|meeting|call|collaborative_engagement|shareholder_resolution|public_statement`',
    `escalation_date` DATE COMMENT 'Date on which escalation action was taken or is planned.',
    `escalation_level` STRING COMMENT 'Level of escalation applied or planned if engagement objectives are not met.. Valid values are `none|board_letter|shareholder_proposal|vote_against|divestment_consideration`',
    `esg_pillar` STRING COMMENT 'Primary ESG pillar that the engagement topic falls under.. Valid values are `environmental|social|governance`',
    `follow_up_date` DATE COMMENT 'Scheduled date for follow-up engagement or review of issuer progress.',
    `follow_up_required_flag` BOOLEAN COMMENT 'Indicates whether follow-up engagement or monitoring is required.',
    `issuer_contact_email` STRING COMMENT 'Email address of the issuer contact person for follow-up communication.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `issuer_contact_name` STRING COMMENT 'Name of the primary contact person at the issuer organization engaged with.',
    `issuer_contact_title` STRING COMMENT 'Job title or role of the issuer contact person engaged with.',
    `issuer_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the issuer being engaged.. Valid values are `^[A-Z0-9]{20}$`',
    `issuer_name` STRING COMMENT 'Legal name of the company or entity being engaged with.',
    `lead_analyst_name` STRING COMMENT 'Full name of the lead analyst or stewardship professional responsible for the engagement.',
    `market_cap_tier` STRING COMMENT 'Market capitalization tier of the issuer at the time of engagement.. Valid values are `large_cap|mid_cap|small_cap|micro_cap`',
    `meeting_format` STRING COMMENT 'Format or medium through which the engagement was conducted.. Valid values are `in_person|video_conference|phone|written_correspondence`',
    `meeting_location` STRING COMMENT 'Physical or virtual location where the engagement meeting took place.',
    `milestone_achieved` STRING COMMENT 'Description of any specific milestone or commitment achieved through the engagement.',
    `milestone_date` DATE COMMENT 'Date on which the engagement milestone was achieved or committed to by the issuer.',
    `outcome` STRING COMMENT 'Outcome or result achieved from the engagement activity.. Valid values are `positive_change|commitment_received|no_change|partial_progress|under_review`',
    `outcome_description` STRING COMMENT 'Detailed narrative description of the engagement outcome and any commitments received from the issuer.',
    `position_held_flag` BOOLEAN COMMENT 'Indicates whether the fund held an equity position in the issuer at the time of engagement.',
    `public_disclosure_flag` BOOLEAN COMMENT 'Indicates whether this engagement activity is publicly disclosed in stewardship reporting.',
    `record_version` BIGINT COMMENT 'Version number of the engagement log record for audit and change tracking purposes.',
    `sector_classification` STRING COMMENT 'Industry sector classification of the issuer being engaged.',
    `topic_category` STRING COMMENT 'Primary thematic category of the engagement topic addressed. [ENUM-REF-CANDIDATE: governance|climate|environmental|social|strategy|risk_management|executive_compensation — 7 candidates stripped; promote to reference product]',
    `topic_detail` STRING COMMENT 'Detailed description of the specific topic or issue discussed during the engagement.',
    `updated_by` STRING COMMENT 'User identifier or name of the person who last updated the engagement log record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the engagement log record was last updated.',
    CONSTRAINT pk_engagement_log PRIMARY KEY(`engagement_log_id`)
) COMMENT 'Records of the funds direct engagement activities with equity issuers as part of active ownership and ESG stewardship. Captures engagement date, engagement type (letter, meeting, call, collaborative engagement), topic category (governance, climate';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`short_interest` (
    `short_interest_id` BIGINT COMMENT 'Unique identifier for the short interest record.',
    `listed_security_id` BIGINT COMMENT 'Reference to the equity security that is shorted or lent.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio holding the short position or lending the security.',
    `activity_type` STRING COMMENT 'Type of short interest activity: short position held by the fund, securities lending activity, or both.. Valid values are `short_position|securities_lending|both`',
    `base_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the funds base reporting currency.. Valid values are `^[A-Z]{3}$`',
    `borrowing_cost_accrued` DECIMAL(18,2) COMMENT 'Accrued borrowing cost incurred to date on short positions, in base currency.',
    `borrowing_cost_rate_bps` DECIMAL(8,2) COMMENT 'Annual cost rate paid to borrow securities for short positions, expressed in basis points.',
    `collateral_type` STRING COMMENT 'Type of collateral received for securities lending: cash, government bonds, corporate bonds, equities, or mixed.. Valid values are `cash|government_bonds|corporate_bonds|equities|mixed`',
    `collateral_value_received` DECIMAL(18,2) COMMENT 'Market value of collateral received from the borrower for lent securities, in base currency.',
    `compliance_breach_reason` STRING COMMENT 'Description of the compliance breach if the compliance flag is false.',
    `compliance_flag` BOOLEAN COMMENT 'Indicates whether the short or lending position complies with internal investment policy and regulatory limits.',
    `counterparty_lei` STRING COMMENT 'Legal Entity Identifier of the counterparty for the short position or securities lending transaction.. Valid values are `^[A-Z0-9]{20}$`',
    `counterparty_name` STRING COMMENT 'Legal name of the counterparty broker or lending agent.',
    `cusip` STRING COMMENT 'CUSIP identifier for North American securities.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `custodian_account_number` STRING COMMENT 'Account number at the custodian bank where the short or lending position is held.',
    `custodian_lei` STRING COMMENT 'Legal Entity Identifier of the custodian bank holding the position.. Valid values are `^[A-Z0-9]{20}$`',
    `exchange_code` STRING COMMENT 'Market Identifier Code (MIC) of the primary exchange where the security is traded.',
    `fx_rate` DECIMAL(18,8) COMMENT 'Exchange rate used to convert local currency values to base currency.',
    `isin` STRING COMMENT 'International Securities Identification Number uniquely identifying the equity security.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `lending_fee_accrued` DECIMAL(18,2) COMMENT 'Accrued lending fee income earned to date on lent securities, in base currency.',
    `lending_fee_rate_bps` DECIMAL(8,2) COMMENT 'Annual fee rate earned on securities lending, expressed in basis points.',
    `lent_market_value_base` DECIMAL(18,2) COMMENT 'Market value of lent securities in the funds base reporting currency.',
    `lent_market_value_local` DECIMAL(18,2) COMMENT 'Market value of lent securities in local trading currency.',
    `lent_quantity` DECIMAL(18,4) COMMENT 'Number of shares lent out under securities lending arrangements.',
    `loan_maturity_date` DATE COMMENT 'Scheduled maturity or recall date for the securities lending arrangement; null for open-ended loans.',
    `loan_start_date` DATE COMMENT 'Date on which the securities lending arrangement commenced.',
    `local_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the local trading currency of the security.. Valid values are `^[A-Z]{3}$`',
    `position_date` DATE COMMENT 'Business date for which the short interest or lending position is reported.',
    `recall_date` DATE COMMENT 'Date on which lent securities were recalled by the lender.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this short interest record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this short interest record was last updated.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this position must be reported to regulatory authorities under short interest disclosure rules.',
    `return_date` DATE COMMENT 'Date on which borrowed or lent securities were returned.',
    `sedol` STRING COMMENT 'SEDOL identifier for securities traded on London Stock Exchange and other exchanges.. Valid values are `^[0-9A-Z]{7}$`',
    `settlement_date` DATE COMMENT 'Date on which the short sale or securities lending transaction settled.',
    `settlement_status` STRING COMMENT 'Current settlement status of the short or lending transaction.. Valid values are `settled|pending|failed|recalled|returned`',
    `short_cost_basis` DECIMAL(18,2) COMMENT 'Original proceeds received when the short position was established, in base currency.',
    `short_position_market_value_base` DECIMAL(18,2) COMMENT 'Market value of the short position in the funds base reporting currency.',
    `short_position_market_value_local` DECIMAL(18,2) COMMENT 'Market value of the short position in the local trading currency.',
    `short_position_quantity` DECIMAL(18,4) COMMENT 'Number of shares held in a short position by the fund.',
    `ticker_symbol` STRING COMMENT 'Exchange ticker symbol for the equity security.',
    `trade_date` DATE COMMENT 'Date on which the short sale or lending transaction was executed.',
    `unrealized_gain_loss_short` DECIMAL(18,2) COMMENT 'Unrealized profit or loss on the short position in base currency.',
    `valuation_source` STRING COMMENT 'Source system or vendor providing the market price used for valuation (e.g., Bloomberg, Reuters, custodian).',
    CONSTRAINT pk_short_interest PRIMARY KEY(`short_interest_id`)
) COMMENT 'Short interest and securities-lending data for equity positions, capturing both the funds short positions and its stock-lending activity. Short-side fields: short position quantity, short position market value, settlement status, and compliance flags for';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`restriction` (
    `restriction_id` BIGINT COMMENT 'Unique identifier for the investment restriction record.',
    `listed_security_id` BIGINT COMMENT 'Reference to the specific security subject to restriction, if applicable.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio subject to this restriction.',
    `active_flag` BOOLEAN COMMENT 'Indicates whether this restriction record is currently active and enforceable.',
    `approval_date` DATE COMMENT 'Date when this restriction was formally approved.',
    `approved_by` STRING COMMENT 'User or authority who approved this restriction for enforcement.',
    `asset_class` STRING COMMENT 'Asset class subject to this restriction, if applicable. [ENUM-REF-CANDIDATE: equity|fixed_income|private_equity|real_estate|infrastructure|natural_resources|credit|cash — 8 candidates stripped; promote to reference product]',
    `breach_notification_required_flag` BOOLEAN COMMENT 'Indicates whether a breach of this restriction requires formal notification to stakeholders or regulators.',
    `breach_tolerance_percent` DECIMAL(5,2) COMMENT 'Allowable tolerance percentage before a breach is triggered.',
    `restriction_code` STRING COMMENT 'Internal code uniquely identifying this restriction rule within the compliance framework.',
    `comments` STRING COMMENT 'Additional free-text comments or notes regarding this restriction.',
    `compliance_system_flag` BOOLEAN COMMENT 'Indicates whether this restriction is actively enforced by automated compliance monitoring systems.',
    `country_iso_code` STRING COMMENT 'Three-letter ISO country code for geographic restriction, if applicable.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this restriction record was first created.',
    `effective_date` DATE COMMENT 'Date when the restriction becomes enforceable.',
    `esg_criteria` STRING COMMENT 'ESG criteria or exclusion rationale for this restriction, if applicable.',
    `expiration_date` DATE COMMENT 'Date when the restriction ceases to be enforceable, if applicable.',
    `issuer_lei` STRING COMMENT 'Legal Entity Identifier of the issuer subject to restriction.. Valid values are `^[A-Z0-9]{20}$`',
    `last_review_date` DATE COMMENT 'Date when this restriction was last reviewed for continued relevance and accuracy.',
    `restriction_level` STRING COMMENT 'Hierarchical level at which the restriction applies: fund, portfolio, security, issuer, sector, country, or asset class. [ENUM-REF-CANDIDATE: fund|portfolio|security|issuer|sector|country|asset_class — 7 candidates stripped; promote to reference product]',
    `mandate_reference` STRING COMMENT 'Reference to the investment mandate or Limited Partnership Agreement (LPA) clause imposing this restriction.',
    `monitoring_frequency` STRING COMMENT 'Frequency at which compliance with this restriction is monitored.. Valid values are `real_time|daily|weekly|monthly|quarterly|ad_hoc`',
    `restriction_name` STRING COMMENT 'Human-readable name or title of the restriction rule.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next review of this restriction.',
    `notification_recipient_list` STRING COMMENT 'Comma-separated list of roles or individuals to be notified upon breach.',
    `override_allowed_flag` BOOLEAN COMMENT 'Indicates whether this restriction can be overridden with appropriate approval.',
    `override_approval_level` STRING COMMENT 'Required approval authority level for override: Chief Investment Officer (CIO), Chief Risk Officer (CRO), Investment Committee (IC), Board, or none.. Valid values are `cio|cro|ic|board|none`',
    `policy_document_reference` STRING COMMENT 'Reference to the policy document or regulation defining this restriction.',
    `rationale` STRING COMMENT 'Business or regulatory rationale for imposing this restriction.',
    `regulatory_authority` STRING COMMENT 'Name of the regulatory body mandating this restriction, if applicable.',
    `restriction_status` STRING COMMENT 'Current lifecycle status of the restriction rule.. Valid values are `active|inactive|pending|expired|suspended`',
    `restriction_type` STRING COMMENT 'Category of restriction: regulatory, mandate, ESG exclusion, sanctions, internal policy, or concentration limit.. Valid values are `regulatory|mandate|esg_exclusion|sanctions|internal_policy|concentration_limit`',
    `sanctions_list` STRING COMMENT 'Name of the sanctions list or watchlist triggering this restriction, if applicable.',
    `scope` STRING COMMENT 'Scope of the restriction: buy, sell, hold, trade, or all activities.. Valid values are `buy|sell|hold|trade|all`',
    `sector_classification` STRING COMMENT 'Industry sector subject to this restriction, if applicable.',
    `threshold_unit` STRING COMMENT 'Unit of measure for the threshold value: percent, absolute value, shares, weight, or exposure.. Valid values are `percent|absolute_value|shares|weight|exposure`',
    `threshold_value` DECIMAL(18,4) COMMENT 'Numeric threshold or limit value for the restriction, if applicable.',
    `updated_by` STRING COMMENT 'User or system that last updated this restriction record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this restriction record was last updated.',
    `created_by` STRING COMMENT 'User or system that created this restriction record.',
    CONSTRAINT pk_restriction PRIMARY KEY(`restriction_id`)
) COMMENT 'Investment restriction and compliance constraint records specific to equity securities and portfolios. Captures restriction type (regulatory, mandate, ESG exclusion, sanctions, internal policy), restricted security or issuer, restriction scope (buy, sell';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`index_rebalance_event` (
    `index_rebalance_event_id` BIGINT COMMENT 'Unique identifier for the index rebalancing event record.',
    `compliance_reviewer_employee_id` BIGINT COMMENT 'Identifier of the compliance officer who reviewed this rebalancing event.',
    `employee_id` BIGINT COMMENT 'Identifier of the compliance officer who reviewed this rebalancing event.',
    `equity_benchmark_id` BIGINT COMMENT 'Reference to the equity benchmark index being rebalanced.',
    `active_flag` BOOLEAN COMMENT 'Indicates whether this rebalancing event record is currently active and valid.',
    `announcement_date` DATE COMMENT 'Date when the index provider publicly announced the rebalancing changes.',
    `announcement_document_url` STRING COMMENT 'Web link to the official rebalancing announcement document published by the index provider.',
    `announcement_timestamp` TIMESTAMP COMMENT 'Precise date and time when the rebalancing announcement was published.',
    `benchmark_code` STRING COMMENT 'Standard code or ticker symbol identifying the benchmark index.',
    `benchmark_name` STRING COMMENT 'Full name of the benchmark index undergoing rebalancing.',
    `capping_applied_flag` BOOLEAN COMMENT 'Indicates whether constituent weight capping rules were applied during rebalancing.',
    `compliance_review_date` DATE COMMENT 'Date when internal compliance review of the rebalancing event was completed.',
    `compliance_review_required_flag` BOOLEAN COMMENT 'Indicates whether internal compliance review is required before trading on this rebalancing.',
    `constituent_list_url` STRING COMMENT 'Web link to the detailed list of additions, deletions, and weight changes.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for monetary values in this rebalancing event.. Valid values are `^[A-Z]{3}$`',
    `data_source` STRING COMMENT 'System or vendor from which the rebalancing event data was sourced.',
    `effective_date` DATE COMMENT 'Date when the rebalancing changes become effective in the index composition.',
    `effective_timestamp` TIMESTAMP COMMENT 'Precise date and time when the rebalancing changes take effect.',
    `esg_criteria_applied_flag` BOOLEAN COMMENT 'Indicates whether ESG screening or criteria were applied in this rebalancing.',
    `estimated_trading_volume` DECIMAL(20,2) COMMENT 'Projected total trading volume in base currency required to implement rebalancing.',
    `estimated_turnover_percent` DECIMAL(5,2) COMMENT 'Projected portfolio turnover percentage resulting from the rebalancing changes.',
    `free_float_minimum_percent` DECIMAL(5,2) COMMENT 'Minimum free float percentage required for a security to be eligible for inclusion.',
    `impact_assessment_summary` STRING COMMENT 'Internal summary of the expected portfolio impact from this rebalancing event.',
    `index_provider` STRING COMMENT 'Organization that administers and maintains the benchmark index. [ENUM-REF-CANDIDATE: MSCI|S&P Dow Jones|FTSE Russell|Bloomberg|Solactive|Stoxx|Nasdaq|Other — 8 candidates stripped; promote to reference product]',
    `liquidity_threshold` DECIMAL(20,2) COMMENT 'Minimum average daily trading volume or turnover required for index inclusion.',
    `market_cap_cutoff` DECIMAL(20,2) COMMENT 'Minimum market capitalization threshold applied for index inclusion eligibility.',
    `maximum_constituent_weight_percent` DECIMAL(5,2) COMMENT 'Maximum allowable weight for any single constituent after capping rules are applied.',
    `methodology_version` STRING COMMENT 'Version identifier of the index methodology applied for this rebalancing.',
    `number_of_additions` BIGINT COMMENT 'Count of securities added to the index during this rebalancing event.',
    `number_of_deletions` BIGINT COMMENT 'Count of securities removed from the index during this rebalancing event.',
    `number_of_weight_changes` BIGINT COMMENT 'Count of existing constituents with modified index weights.',
    `portfolio_exposure_flag` BOOLEAN COMMENT 'Indicates whether the pension fund holds positions that are affected by this rebalancing.',
    `rebalance_rationale` STRING COMMENT 'Business reason or trigger for the rebalancing event as stated by the index provider.',
    `rebalance_status` STRING COMMENT 'Current lifecycle state of the rebalancing event.. Valid values are `announced|pending|effective|completed|cancelled`',
    `rebalance_type` STRING COMMENT 'Classification of the rebalancing event based on schedule and trigger.. Valid values are `quarterly|semi-annual|annual|ad-hoc|reconstitution|special`',
    `record_created_timestamp` TIMESTAMP COMMENT 'Date and time when this rebalancing event record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Date and time when this rebalancing event record was last modified.',
    `record_version` BIGINT COMMENT 'Version number of this rebalancing event record for change tracking and audit purposes.',
    `review_period_end_date` DATE COMMENT 'End date of the data observation period used to determine rebalancing changes.',
    `review_period_start_date` DATE COMMENT 'Start date of the data observation period used to determine rebalancing changes.',
    `sector_rebalance_flag` BOOLEAN COMMENT 'Indicates whether sector classification changes are part of this rebalancing event.',
    `total_constituents_post_rebalance` BIGINT COMMENT 'Total number of securities in the index after rebalancing is complete.',
    `trading_strategy_recommendation` STRING COMMENT 'Internal recommendation for how to execute trades in response to the rebalancing event.',
    `updated_by` STRING COMMENT 'User or system identifier that last modified this rebalancing event record.',
    CONSTRAINT pk_index_rebalance_event PRIMARY KEY(`index_rebalance_event_id`)
) COMMENT 'Records of scheduled and ad-hoc index rebalancing events for equity benchmark indices tracked by the fund. Captures index provider, rebalancing type (quarterly, semi-annual, annual, ad-hoc), announcement date, effective date, additions list, deletions';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`earnings_announcement` (
    `earnings_announcement_id` BIGINT COMMENT 'Unique identifier for the earnings announcement record.',
    `issuer_financials_id` BIGINT COMMENT 'Reference to equity.issuer_financials.issuer_financials_id.',
    `listed_security_id` BIGINT COMMENT 'Reference to equity.listed_security.listed_security_id.',
    `market_consensus_id` BIGINT COMMENT 'Reference to research.market_consensus.market_consensus_id.',
    `actual_eps` DECIMAL(18,6) COMMENT 'Actual reported earnings per share for the earnings announcement.',
    `announcement_date` DATE COMMENT 'Date on which the earnings announcement was made.',
    `consensus_eps` DECIMAL(18,6) COMMENT 'Consensus analyst estimate for earnings per share for this earnings announcement.',
    `eps_basis` STRING COMMENT 'Basis used for the EPS figure reported in the earnings announcement (e.g., GAAP, non-GAAP, diluted, basic).',
    `fiscal_quarter` BIGINT COMMENT 'The fiscal quarter of the earnings announcement.',
    `fiscal_year` BIGINT COMMENT 'The fiscal year of the earnings announcement.',
    CONSTRAINT pk_earnings_announcement PRIMARY KEY(`earnings_announcement_id`)
) COMMENT 'Earnings announcement for a listed security including actual vs consensus EPS.';

CREATE OR REPLACE TABLE `asset_management`.`equity`.`price_target_evaluation` (
    `price_target_evaluation_id` BIGINT COMMENT 'Surrogate primary key.',
    `research_note_id` BIGINT COMMENT 'FK to equity.research_note, the note that issued the target.',
    `evaluation_date` DATE COMMENT 'Evaluation date.',
    `horizon_days` BIGINT COMMENT 'Evaluation horizon in days: 90, 180, 365.',
    `issue_price` DECIMAL(18,6) COMMENT 'Security price on the notes publication date.',
    `realized_price` DECIMAL(18,6) COMMENT 'Security price at the horizon, same currency as the target.',
    CONSTRAINT pk_price_target_evaluation PRIMARY KEY(`price_target_evaluation_id`)
) COMMENT 'Outcome of one research price target at its horizon.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`equity`.`price_target_evaluation` ADD CONSTRAINT `fk_equity_price_target_evaluation_research_note_id` FOREIGN KEY (`research_note_id`) REFERENCES `asset_management`.`equity`.`research_note`(`research_note_id`);
ALTER TABLE `asset_management`.`equity`.`equity_position` ADD CONSTRAINT `fk_equity_equity_position_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ADD CONSTRAINT `fk_equity_equity_benchmark_constituent_equity_benchmark_id` FOREIGN KEY (`equity_benchmark_id`) REFERENCES `asset_management`.`equity`.`equity_benchmark`(`equity_benchmark_id`);
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ADD CONSTRAINT `fk_equity_equity_benchmark_constituent_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ADD CONSTRAINT `fk_equity_equity_coverage_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`research_note` ADD CONSTRAINT `fk_equity_research_note_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`research_note` ADD CONSTRAINT `fk_equity_research_note_superseded_by_note_research_note_id` FOREIGN KEY (`superseded_by_note_research_note_id`) REFERENCES `asset_management`.`equity`.`research_note`(`research_note_id`);
ALTER TABLE `asset_management`.`equity`.`price_history` ADD CONSTRAINT `fk_equity_price_history_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`corporate_action` ADD CONSTRAINT `fk_equity_corporate_action_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ADD CONSTRAINT `fk_equity_corporate_action_election_corporate_action_id` FOREIGN KEY (`corporate_action_id`) REFERENCES `asset_management`.`equity`.`corporate_action`(`corporate_action_id`);
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ADD CONSTRAINT `fk_equity_corporate_action_election_equity_position_id` FOREIGN KEY (`equity_position_id`) REFERENCES `asset_management`.`equity`.`equity_position`(`equity_position_id`);
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ADD CONSTRAINT `fk_equity_corporate_action_election_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ADD CONSTRAINT `fk_equity_equity_factor_exposure_equity_benchmark_id` FOREIGN KEY (`equity_benchmark_id`) REFERENCES `asset_management`.`equity`.`equity_benchmark`(`equity_benchmark_id`);
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ADD CONSTRAINT `fk_equity_equity_factor_exposure_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ADD CONSTRAINT `fk_equity_equity_sector_classification_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ADD CONSTRAINT `fk_equity_security_sector_mapping_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`stock_selection` ADD CONSTRAINT `fk_equity_stock_selection_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`stock_selection` ADD CONSTRAINT `fk_equity_stock_selection_research_note_id` FOREIGN KEY (`research_note_id`) REFERENCES `asset_management`.`equity`.`research_note`(`research_note_id`);
ALTER TABLE `asset_management`.`equity`.`stock_selection` ADD CONSTRAINT `fk_equity_stock_selection_valuation_model_id` FOREIGN KEY (`valuation_model_id`) REFERENCES `asset_management`.`equity`.`valuation_model`(`valuation_model_id`);
ALTER TABLE `asset_management`.`equity`.`valuation_model` ADD CONSTRAINT `fk_equity_valuation_model_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ADD CONSTRAINT `fk_equity_equity_issuer_parent_issuer_equity_issuer_id` FOREIGN KEY (`parent_issuer_equity_issuer_id`) REFERENCES `asset_management`.`equity`.`equity_issuer`(`equity_issuer_id`);
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ADD CONSTRAINT `fk_equity_issuer_financials_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`dividend_record` ADD CONSTRAINT `fk_equity_dividend_record_corporate_action_id` FOREIGN KEY (`corporate_action_id`) REFERENCES `asset_management`.`equity`.`corporate_action`(`corporate_action_id`);
ALTER TABLE `asset_management`.`equity`.`dividend_record` ADD CONSTRAINT `fk_equity_dividend_record_equity_position_id` FOREIGN KEY (`equity_position_id`) REFERENCES `asset_management`.`equity`.`equity_position`(`equity_position_id`);
ALTER TABLE `asset_management`.`equity`.`dividend_record` ADD CONSTRAINT `fk_equity_dividend_record_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ADD CONSTRAINT `fk_equity_proxy_voting_record_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`engagement_log` ADD CONSTRAINT `fk_equity_engagement_log_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`engagement_log` ADD CONSTRAINT `fk_equity_engagement_log_related_proxy_vote_proxy_voting_record_id` FOREIGN KEY (`related_proxy_vote_proxy_voting_record_id`) REFERENCES `asset_management`.`equity`.`proxy_voting_record`(`proxy_voting_record_id`);
ALTER TABLE `asset_management`.`equity`.`engagement_log` ADD CONSTRAINT `fk_equity_engagement_log_related_proxy_voting_record_id` FOREIGN KEY (`related_proxy_voting_record_id`) REFERENCES `asset_management`.`equity`.`proxy_voting_record`(`proxy_voting_record_id`);
ALTER TABLE `asset_management`.`equity`.`short_interest` ADD CONSTRAINT `fk_equity_short_interest_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`restriction` ADD CONSTRAINT `fk_equity_restriction_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ADD CONSTRAINT `fk_equity_index_rebalance_event_equity_benchmark_id` FOREIGN KEY (`equity_benchmark_id`) REFERENCES `asset_management`.`equity`.`equity_benchmark`(`equity_benchmark_id`);
ALTER TABLE `asset_management`.`equity`.`earnings_announcement` ADD CONSTRAINT `fk_equity_earnings_announcement_issuer_financials_id` FOREIGN KEY (`issuer_financials_id`) REFERENCES `asset_management`.`equity`.`issuer_financials`(`issuer_financials_id`);
ALTER TABLE `asset_management`.`equity`.`earnings_announcement` ADD CONSTRAINT `fk_equity_earnings_announcement_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);

-- ========= TAGS =========
ALTER SCHEMA `asset_management`.`equity` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `asset_management`.`equity` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`price_target_evaluation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`equity`.`price_target_evaluation` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`price_target_evaluation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`price_target_evaluation` SET TAGS ('dbx_subdomain' = 'research_analysis');
ALTER TABLE `asset_management`.`equity`.`listed_security` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`equity`.`listed_security` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`listed_security` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`listed_security` SET TAGS ('dbx_subdomain' = 'instrument_reference');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Listed Security Identifier');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `bloomberg_ticker` SET TAGS ('dbx_business_glossary_term' = 'Bloomberg Ticker');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `coverage_analyst` SET TAGS ('dbx_business_glossary_term' = 'Coverage Analyst');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `delisting_date` SET TAGS ('dbx_business_glossary_term' = 'Delisting Date');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `dividend_frequency` SET TAGS ('dbx_business_glossary_term' = 'Dividend Frequency');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `dividend_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly|irregular|none');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `esg_rating_date` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating Date');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `exchange_mic` SET TAGS ('dbx_business_glossary_term' = 'Exchange Market Identifier Code (MIC)');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `exchange_mic` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}$');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `factset_entity_code` SET TAGS ('dbx_business_glossary_term' = 'FactSet Entity Identifier');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `gics_industry` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Industry');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `gics_industry_group` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Industry Group');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `gics_sector` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Sector');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `gics_sub_industry` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Sub-Industry');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `investment_restriction_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Restriction Flag');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Name');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `listing_country` SET TAGS ('dbx_business_glossary_term' = 'Listing Country');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `listing_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `listing_date` SET TAGS ('dbx_business_glossary_term' = 'Listing Date');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `listing_status` SET TAGS ('dbx_business_glossary_term' = 'Listing Status');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `listing_status` SET TAGS ('dbx_value_regex' = 'active|suspended|delisted|halted');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `lot_size` SET TAGS ('dbx_business_glossary_term' = 'Lot Size');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `market_cap_date` SET TAGS ('dbx_business_glossary_term' = 'Market Capitalization As-Of Date');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `market_capitalization` SET TAGS ('dbx_business_glossary_term' = 'Market Capitalization');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `msci_constituent_flag` SET TAGS ('dbx_business_glossary_term' = 'MSCI Constituent Flag');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `par_value` SET TAGS ('dbx_business_glossary_term' = 'Par Value');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `par_value_currency` SET TAGS ('dbx_business_glossary_term' = 'Par Value Currency');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `par_value_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `price_multiplier` SET TAGS ('dbx_business_glossary_term' = 'Price Multiplier');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `primary_exchange` SET TAGS ('dbx_business_glossary_term' = 'Primary Exchange');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `research_rating` SET TAGS ('dbx_business_glossary_term' = 'Research Rating');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `research_rating` SET TAGS ('dbx_value_regex' = 'buy|overweight|hold|underweight|sell');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `research_rating_date` SET TAGS ('dbx_business_glossary_term' = 'Research Rating Date');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `restriction_reason` SET TAGS ('dbx_business_glossary_term' = 'Restriction Reason');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `reuters_ric` SET TAGS ('dbx_business_glossary_term' = 'Reuters Instrument Code (RIC)');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `security_name` SET TAGS ('dbx_business_glossary_term' = 'Security Name');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `security_type` SET TAGS ('dbx_business_glossary_term' = 'Security Type');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `security_type` SET TAGS ('dbx_value_regex' = 'common_stock|preferred_stock|adr|gdr|reit|etf');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `share_class` SET TAGS ('dbx_business_glossary_term' = 'Share Class');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `shares_outstanding` SET TAGS ('dbx_business_glossary_term' = 'Shares Outstanding');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `shares_outstanding_date` SET TAGS ('dbx_business_glossary_term' = 'Shares Outstanding As-Of Date');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `ticker_symbol` SET TAGS ('dbx_business_glossary_term' = 'Ticker Symbol');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `trading_currency` SET TAGS ('dbx_business_glossary_term' = 'Trading Currency');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `trading_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `voting_rights` SET TAGS ('dbx_business_glossary_term' = 'Voting Rights');
ALTER TABLE `asset_management`.`equity`.`listed_security` ALTER COLUMN `voting_rights` SET TAGS ('dbx_value_regex' = 'full|limited|none|variable');
ALTER TABLE `asset_management`.`equity`.`equity_position` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`equity`.`equity_position` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`equity_position` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`equity_position` SET TAGS ('dbx_subdomain' = 'portfolio_stewardship');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `equity_position_id` SET TAGS ('dbx_business_glossary_term' = 'Equity Position Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `custody_account_id` SET TAGS ('dbx_business_glossary_term' = 'Custody Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Id (Foreign Key)');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate Id (Foreign Key)');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `risk_factor_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Factor Exposure Id (Foreign Key)');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `trader_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `trader_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `trader_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `accrued_dividend` SET TAGS ('dbx_business_glossary_term' = 'Accrued Dividend');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `acquisition_date` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Date');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `active_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Active Weight Percentage');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `average_cost_per_share` SET TAGS ('dbx_business_glossary_term' = 'Average Cost Per Share');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `benchmark_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Weight Percentage');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `beta` SET TAGS ('dbx_business_glossary_term' = 'Beta Coefficient');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `book_cost_base_currency` SET TAGS ('dbx_business_glossary_term' = 'Book Cost in Base Currency');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `country_of_domicile` SET TAGS ('dbx_business_glossary_term' = 'Country of Domicile');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `country_of_domicile` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_business_glossary_term' = 'Country of Risk');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP) Code');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `custodian_account_number` SET TAGS ('dbx_business_glossary_term' = 'Custodian Account Number');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `custodian_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `dividend_yield_percent` SET TAGS ('dbx_business_glossary_term' = 'Dividend Yield Percentage');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `esg_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Score');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `exchange_code` SET TAGS ('dbx_business_glossary_term' = 'Exchange Market Identifier Code (MIC)');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `exchange_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}$');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `income_classification` SET TAGS ('dbx_business_glossary_term' = 'Income Classification');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `income_classification` SET TAGS ('dbx_value_regex' = 'qualified|non_qualified|exempt|foreign');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `last_trade_date` SET TAGS ('dbx_business_glossary_term' = 'Last Trade Date');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `lending_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Securities Lending Eligible Flag');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `local_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Local Currency Code');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `local_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `market_capitalization_tier` SET TAGS ('dbx_business_glossary_term' = 'Market Capitalization Tier');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `market_capitalization_tier` SET TAGS ('dbx_value_regex' = 'large_cap|mid_cap|small_cap|micro_cap');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `market_price` SET TAGS ('dbx_business_glossary_term' = 'Market Price');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `market_value_base_currency` SET TAGS ('dbx_business_glossary_term' = 'Market Value in Base Currency');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `market_value_local_currency` SET TAGS ('dbx_business_glossary_term' = 'Market Value in Local Currency');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `portfolio_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Weight Percentage');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `position_date` SET TAGS ('dbx_business_glossary_term' = 'Position As-Of Date');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `position_status` SET TAGS ('dbx_business_glossary_term' = 'Position Status');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `position_status` SET TAGS ('dbx_value_regex' = 'active|closed|pending|suspended');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `position_type` SET TAGS ('dbx_business_glossary_term' = 'Position Type');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `position_type` SET TAGS ('dbx_value_regex' = 'long|short');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `price_to_earnings_ratio` SET TAGS ('dbx_business_glossary_term' = 'Price to Earnings (P/E) Ratio');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Position Quantity');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `restricted_flag` SET TAGS ('dbx_business_glossary_term' = 'Restricted Position Flag');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL) Code');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `tax_lot_method` SET TAGS ('dbx_business_glossary_term' = 'Tax Lot Accounting Method');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `tax_lot_method` SET TAGS ('dbx_value_regex' = 'FIFO|LIFO|HIFO|specific_identification');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `ticker_symbol` SET TAGS ('dbx_business_glossary_term' = 'Ticker Symbol');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `unrealized_gain_loss_base_currency` SET TAGS ('dbx_business_glossary_term' = 'Unrealized Gain or Loss in Base Currency');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `valuation_source` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `valuation_source` SET TAGS ('dbx_value_regex' = 'exchange|vendor|broker|model');
ALTER TABLE `asset_management`.`equity`.`equity_position` ALTER COLUMN `voting_rights_flag` SET TAGS ('dbx_business_glossary_term' = 'Voting Rights Flag');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` SET TAGS ('dbx_subdomain' = 'instrument_reference');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `equity_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Equity Benchmark Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `creator_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Creator Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `creator_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `creator_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `administrator_lei` SET TAGS ('dbx_business_glossary_term' = 'Administrator Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `administrator_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `base_currency` SET TAGS ('dbx_business_glossary_term' = 'Base Currency');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `base_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `base_date` SET TAGS ('dbx_business_glossary_term' = 'Base Date');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `base_value` SET TAGS ('dbx_business_glossary_term' = 'Base Value');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `benchmark_code` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Code');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `benchmark_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,12}$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `benchmark_name` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Name');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `benchmark_status` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Status');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `benchmark_status` SET TAGS ('dbx_value_regex' = 'Active|Discontinued|Suspended|Under Review');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `benchmark_type` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Type');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `bloomberg_ticker` SET TAGS ('dbx_business_glossary_term' = 'Bloomberg Ticker');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `bloomberg_ticker` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,10}( [A-Z]{1,6})?$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Calculation Frequency');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_value_regex' = 'Real-Time|End-of-Day|Weekly|Monthly');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `capping_methodology` SET TAGS ('dbx_business_glossary_term' = 'Capping Methodology');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `country_iso_code` SET TAGS ('dbx_business_glossary_term' = 'Country ISO Code');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `country_iso_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `dividend_treatment` SET TAGS ('dbx_business_glossary_term' = 'Dividend Treatment');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `dividend_treatment` SET TAGS ('dbx_value_regex' = 'Excluded|Net Reinvested|Gross Reinvested');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `dividend_treatment` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `dividend_treatment` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `esg_integration` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `esg_methodology` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Methodology');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `factsheet_url` SET TAGS ('dbx_business_glossary_term' = 'Factsheet Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `free_float_adjustment` SET TAGS ('dbx_business_glossary_term' = 'Free Float Adjustment');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_value_regex' = 'Global|Developed Markets|Emerging Markets|Frontier Markets|Regional|Single Country');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `hedged_currency` SET TAGS ('dbx_business_glossary_term' = 'Hedged Currency');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `hedged_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `index_provider` SET TAGS ('dbx_business_glossary_term' = 'Index Provider');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `internal_benchmark_flag` SET TAGS ('dbx_business_glossary_term' = 'Internal Benchmark Flag');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `is_hedged` SET TAGS ('dbx_business_glossary_term' = 'Is Hedged');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `market_cap_range` SET TAGS ('dbx_business_glossary_term' = 'Market Capitalization (Cap) Range');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `market_cap_range` SET TAGS ('dbx_value_regex' = 'Large Cap|Mid Cap|Small Cap|Micro Cap|All Cap|Multi Cap');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `methodology_url` SET TAGS ('dbx_business_glossary_term' = 'Methodology Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `number_of_constituents` SET TAGS ('dbx_business_glossary_term' = 'Number of Constituents');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Frequency');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `reconstitution_month` SET TAGS ('dbx_business_glossary_term' = 'Reconstitution Month');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `region` SET TAGS ('dbx_business_glossary_term' = 'Region');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `regulatory_classification` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Classification');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `return_type` SET TAGS ('dbx_business_glossary_term' = 'Return Type');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `return_type` SET TAGS ('dbx_value_regex' = 'Price Return|Net Total Return|Gross Total Return');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `ric_code` SET TAGS ('dbx_business_glossary_term' = 'Reuters Instrument Code (RIC)');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `ric_code` SET TAGS ('dbx_value_regex' = '^.[A-Z0-9]{1,10}$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `sector_focus` SET TAGS ('dbx_business_glossary_term' = 'Sector Focus');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `style_factor` SET TAGS ('dbx_business_glossary_term' = 'Style Factor');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `usage_purpose` SET TAGS ('dbx_business_glossary_term' = 'Usage Purpose');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ALTER COLUMN `weighting_methodology` SET TAGS ('dbx_business_glossary_term' = 'Weighting Methodology');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` SET TAGS ('dbx_subdomain' = 'instrument_reference');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `equity_benchmark_constituent_id` SET TAGS ('dbx_business_glossary_term' = 'Equity Benchmark Constituent ID');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `equity_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Equity Benchmark ID');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Equity Security ID');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `addition_date` SET TAGS ('dbx_business_glossary_term' = 'Addition Date');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `adjusted_market_capitalization` SET TAGS ('dbx_business_glossary_term' = 'Adjusted Market Capitalization');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `average_daily_value_traded` SET TAGS ('dbx_business_glossary_term' = 'Average Daily Value Traded (ADVT)');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `average_daily_volume` SET TAGS ('dbx_business_glossary_term' = 'Average Daily Volume (ADV)');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `capping_factor` SET TAGS ('dbx_business_glossary_term' = 'Capping Factor');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `constituent_status` SET TAGS ('dbx_business_glossary_term' = 'Constituent Status');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `constituent_status` SET TAGS ('dbx_value_regex' = 'active|pending_addition|pending_deletion|deleted|suspended');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `constituent_weight` SET TAGS ('dbx_business_glossary_term' = 'Constituent Weight');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `constituent_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Constituent Weight Percent');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `corporate_action_adjustment_flag` SET TAGS ('dbx_business_glossary_term' = 'Corporate Action Adjustment Flag');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `country_of_domicile` SET TAGS ('dbx_business_glossary_term' = 'Country of Domicile');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `country_of_domicile` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_business_glossary_term' = 'Country of Risk');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{9}$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `deletion_date` SET TAGS ('dbx_business_glossary_term' = 'Deletion Date');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `deletion_reason` SET TAGS ('dbx_business_glossary_term' = 'Deletion Reason');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `free_float_factor` SET TAGS ('dbx_business_glossary_term' = 'Free Float Factor');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `gics_industry_code` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Industry Code');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `gics_industry_code` SET TAGS ('dbx_value_regex' = '^[0-9]{6}$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `gics_industry_group_code` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Industry Group Code');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `gics_industry_group_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `gics_sector_code` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Sector Code');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `gics_sector_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2}$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `gics_sub_industry_code` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Sub-Industry Code');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `gics_sub_industry_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `index_divisor` SET TAGS ('dbx_business_glossary_term' = 'Index Divisor');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `index_provider_code` SET TAGS ('dbx_business_glossary_term' = 'Index Provider Code');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Name');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `liquidity_score` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Score');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `market_capitalization` SET TAGS ('dbx_business_glossary_term' = 'Market Capitalization');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `price_at_rebalance` SET TAGS ('dbx_business_glossary_term' = 'Price at Rebalance');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `rebalance_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rebalance Frequency');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `rebalance_frequency` SET TAGS ('dbx_value_regex' = 'quarterly|semi_annual|annual|monthly|ad_hoc');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `security_name` SET TAGS ('dbx_business_glossary_term' = 'Security Name');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `shares_outstanding` SET TAGS ('dbx_business_glossary_term' = 'Shares Outstanding');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `ticker_symbol` SET TAGS ('dbx_business_glossary_term' = 'Ticker Symbol');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `weighting_methodology` SET TAGS ('dbx_business_glossary_term' = 'Weighting Methodology');
ALTER TABLE `asset_management`.`equity`.`equity_benchmark_constituent` ALTER COLUMN `weighting_methodology` SET TAGS ('dbx_value_regex' = 'market_cap|free_float|equal|fundamental|factor');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` SET TAGS ('dbx_subdomain' = 'research_analysis');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `equity_coverage_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `active_flag` SET TAGS ('dbx_business_glossary_term' = 'Active Flag');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `analyst_name` SET TAGS ('dbx_business_glossary_term' = 'Analyst Name');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `benchmark_index` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `conviction_level` SET TAGS ('dbx_business_glossary_term' = 'Conviction Level');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `conviction_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `country_of_domicile` SET TAGS ('dbx_business_glossary_term' = 'Country of Domicile');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `country_of_domicile` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[0-9A-Z]{5}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `equity_coverage_status` SET TAGS ('dbx_business_glossary_term' = 'Coverage Status');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `equity_coverage_status` SET TAGS ('dbx_value_regex' = 'active|watch|suspended|dropped|pending');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `equity_coverage_type` SET TAGS ('dbx_business_glossary_term' = 'Coverage Type');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `equity_coverage_type` SET TAGS ('dbx_value_regex' = 'full|limited|sector|thematic|event');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `esg_coverage_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Coverage Flag');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `industry_group` SET TAGS ('dbx_business_glossary_term' = 'Industry Group');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `initiation_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Initiation Date');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `investment_rating` SET TAGS ('dbx_business_glossary_term' = 'Investment Rating');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `investment_rating` SET TAGS ('dbx_value_regex' = 'buy|overweight|hold|underweight|sell');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Name');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `market_cap_tier` SET TAGS ('dbx_business_glossary_term' = 'Market Capitalization (Cap) Tier');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `market_cap_tier` SET TAGS ('dbx_value_regex' = 'large|mid|small|micro');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `position_held_flag` SET TAGS ('dbx_business_glossary_term' = 'Position Held Flag');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `primary_exchange` SET TAGS ('dbx_business_glossary_term' = 'Primary Exchange');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `rating_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Rating Effective Date');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `rationale` SET TAGS ('dbx_business_glossary_term' = 'Coverage Rationale');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `record_version` SET TAGS ('dbx_business_glossary_term' = 'Record Version');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `research_priority` SET TAGS ('dbx_business_glossary_term' = 'Research Priority');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `research_priority` SET TAGS ('dbx_value_regex' = 'core|standard|opportunistic');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `security_name` SET TAGS ('dbx_business_glossary_term' = 'Security Name');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9BCDFGHJKLMNPQRSTVWXYZ]{7}$');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `target_price` SET TAGS ('dbx_business_glossary_term' = 'Target Price');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `target_price_currency` SET TAGS ('dbx_business_glossary_term' = 'Target Price Currency');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `target_price_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Termination Date');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `ticker_symbol` SET TAGS ('dbx_business_glossary_term' = 'Ticker Symbol');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By');
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`equity`.`research_note` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`equity`.`research_note` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`research_note` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`research_note` SET TAGS ('dbx_subdomain' = 'research_analysis');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `research_note_id` SET TAGS ('dbx_business_glossary_term' = 'Research Note ID');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `compliance_reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Reviewer ID');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst ID');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security ID');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `peer_review_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Peer Review Analyst ID');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `research_compliance_reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Reviewer ID');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `research_compliance_reviewer_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `research_compliance_reviewer_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `research_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst ID');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `research_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `research_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `research_peer_review_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Peer Review Analyst ID');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `research_peer_review_analyst_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `research_peer_review_analyst_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `superseded_by_note_research_note_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Research Note ID');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `archived_date` SET TAGS ('dbx_business_glossary_term' = 'Archived Date');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `archived_flag` SET TAGS ('dbx_business_glossary_term' = 'Archived Flag');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `compliance_review_date` SET TAGS ('dbx_business_glossary_term' = 'Compliance Review Date');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `conviction_level` SET TAGS ('dbx_business_glossary_term' = 'Conviction Level');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `conviction_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `dcf_terminal_growth_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Discounted Cash Flow (DCF) Terminal Growth Rate Percent');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `dcf_wacc_percent` SET TAGS ('dbx_business_glossary_term' = 'Discounted Cash Flow (DCF) Weighted Average Cost of Capital (WACC) Percent');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `distribution_scope` SET TAGS ('dbx_business_glossary_term' = 'Distribution Scope');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `distribution_scope` SET TAGS ('dbx_value_regex' = 'internal_all|portfolio_managers_only|investment_committee|restricted_list|archived');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `document_url` SET TAGS ('dbx_business_glossary_term' = 'Document Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `document_url` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `earnings_estimate_current_year` SET TAGS ('dbx_business_glossary_term' = 'Earnings Estimate Current Year');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `earnings_estimate_next_year` SET TAGS ('dbx_business_glossary_term' = 'Earnings Estimate Next Year');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `esg_assessment_summary` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Assessment Summary');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `esg_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Score');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `ev_ebitda_ratio` SET TAGS ('dbx_business_glossary_term' = 'Enterprise Value to Earnings Before Interest Taxes Depreciation and Amortization (EV/EBITDA) Ratio');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `executive_summary` SET TAGS ('dbx_business_glossary_term' = 'Executive Summary');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `investment_horizon_months` SET TAGS ('dbx_business_glossary_term' = 'Investment Horizon (Months)');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `investment_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Investment Recommendation');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `key_catalysts` SET TAGS ('dbx_business_glossary_term' = 'Key Catalysts');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `key_risks` SET TAGS ('dbx_business_glossary_term' = 'Key Risks');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `note_type` SET TAGS ('dbx_business_glossary_term' = 'Research Note Type');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `pe_ratio_forward` SET TAGS ('dbx_business_glossary_term' = 'Price-to-Earnings (P/E) Ratio Forward');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `prior_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Prior Recommendation');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `prior_target_price` SET TAGS ('dbx_business_glossary_term' = 'Prior Target Price');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `publication_date` SET TAGS ('dbx_business_glossary_term' = 'Publication Date');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `publication_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Publication Timestamp');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `recommendation_change_reason` SET TAGS ('dbx_business_glossary_term' = 'Recommendation Change Reason');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `research_status` SET TAGS ('dbx_business_glossary_term' = 'Research Status');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `revenue_estimate_current_year` SET TAGS ('dbx_business_glossary_term' = 'Revenue Estimate Current Year');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `revenue_estimate_next_year` SET TAGS ('dbx_business_glossary_term' = 'Revenue Estimate Next Year');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `sector_focus` SET TAGS ('dbx_business_glossary_term' = 'Sector Focus');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `target_price` SET TAGS ('dbx_business_glossary_term' = 'Target Price');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `target_price_currency` SET TAGS ('dbx_business_glossary_term' = 'Target Price Currency');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `target_price_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `thematic_tag` SET TAGS ('dbx_business_glossary_term' = 'Thematic Tag');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Research Note Title');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Valuation Methodology');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_value_regex' = 'dcf|comparable_multiples|sum_of_parts|dividend_discount|asset_based|hybrid');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_business_glossary_term' = 'Withdrawal Reason');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `withdrawn_flag` SET TAGS ('dbx_business_glossary_term' = 'Withdrawn Flag');
ALTER TABLE `asset_management`.`equity`.`research_note` ALTER COLUMN `word_count` SET TAGS ('dbx_business_glossary_term' = 'Word Count');
ALTER TABLE `asset_management`.`equity`.`price_history` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`equity`.`price_history` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`price_history` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`price_history` SET TAGS ('dbx_subdomain' = 'instrument_reference');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `price_history_id` SET TAGS ('dbx_business_glossary_term' = 'Price History Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `adjusted_close_price` SET TAGS ('dbx_business_glossary_term' = 'Adjusted Close Price');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `ask_price` SET TAGS ('dbx_business_glossary_term' = 'Ask Price');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `batch_reference` SET TAGS ('dbx_business_glossary_term' = 'Batch Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `bid_ask_spread` SET TAGS ('dbx_business_glossary_term' = 'Bid-Ask Spread');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `bid_price` SET TAGS ('dbx_business_glossary_term' = 'Bid Price');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `close_price` SET TAGS ('dbx_business_glossary_term' = 'Close Price');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `corporate_action_flag` SET TAGS ('dbx_business_glossary_term' = 'Corporate Action Flag');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `data_quality_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Flag');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `dividend_amount` SET TAGS ('dbx_business_glossary_term' = 'Dividend Amount');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `exchange_code` SET TAGS ('dbx_business_glossary_term' = 'Exchange Code');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `high_price` SET TAGS ('dbx_business_glossary_term' = 'High Price');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `is_trading_day` SET TAGS ('dbx_business_glossary_term' = 'Is Trading Day');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `low_price` SET TAGS ('dbx_business_glossary_term' = 'Low Price');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `market_cap` SET TAGS ('dbx_business_glossary_term' = 'Market Capitalization');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `open_price` SET TAGS ('dbx_business_glossary_term' = 'Open Price');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `previous_close_price` SET TAGS ('dbx_business_glossary_term' = 'Previous Close Price');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `price_change` SET TAGS ('dbx_business_glossary_term' = 'Price Change');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `price_change_percent` SET TAGS ('dbx_business_glossary_term' = 'Price Change Percentage');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `price_date` SET TAGS ('dbx_business_glossary_term' = 'Price Date');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `price_source` SET TAGS ('dbx_business_glossary_term' = 'Price Source');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `price_type` SET TAGS ('dbx_business_glossary_term' = 'Price Type');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `price_type` SET TAGS ('dbx_value_regex' = 'official|estimated|indicative|restated');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `shares_outstanding` SET TAGS ('dbx_business_glossary_term' = 'Shares Outstanding');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `split_factor` SET TAGS ('dbx_business_glossary_term' = 'Split Factor');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `ticker_symbol` SET TAGS ('dbx_business_glossary_term' = 'Ticker Symbol');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `total_return_index` SET TAGS ('dbx_business_glossary_term' = 'Total Return Index');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `trading_status` SET TAGS ('dbx_business_glossary_term' = 'Trading Status');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `trading_status` SET TAGS ('dbx_value_regex' = 'normal|halted|suspended|delisted|pre_open|post_close');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `turnover_value` SET TAGS ('dbx_business_glossary_term' = 'Turnover Value');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `volume` SET TAGS ('dbx_business_glossary_term' = 'Trading Volume');
ALTER TABLE `asset_management`.`equity`.`price_history` ALTER COLUMN `vwap` SET TAGS ('dbx_business_glossary_term' = 'Volume-Weighted Average Price (VWAP)');
ALTER TABLE `asset_management`.`equity`.`corporate_action` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`equity`.`corporate_action` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`corporate_action` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`corporate_action` SET TAGS ('dbx_subdomain' = 'instrument_reference');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `corporate_action_id` SET TAGS ('dbx_business_glossary_term' = 'Corporate Action Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `action_status` SET TAGS ('dbx_business_glossary_term' = 'Corporate Action Status');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `action_status` SET TAGS ('dbx_value_regex' = 'announced|confirmed|pending|executed|cancelled|expired');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `action_type` SET TAGS ('dbx_business_glossary_term' = 'Corporate Action Type');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `announcement_date` SET TAGS ('dbx_business_glossary_term' = 'Announcement Date');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `country_of_issue` SET TAGS ('dbx_business_glossary_term' = 'Country of Issue Code');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `country_of_issue` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `data_quality_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Flag');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `corporate_action_description` SET TAGS ('dbx_business_glossary_term' = 'Corporate Action Description');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `dividend_amount` SET TAGS ('dbx_business_glossary_term' = 'Dividend Amount Per Share');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `dividend_currency` SET TAGS ('dbx_business_glossary_term' = 'Dividend Currency Code');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `dividend_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `dividend_type` SET TAGS ('dbx_business_glossary_term' = 'Dividend Type');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `dividend_type` SET TAGS ('dbx_value_regex' = 'ordinary|special|interim|final');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `ex_date` SET TAGS ('dbx_business_glossary_term' = 'Ex-Dividend Date (Ex-Date)');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `exchange_code` SET TAGS ('dbx_business_glossary_term' = 'Exchange Market Identifier Code (MIC)');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `exchange_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}$');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `impact_on_nav_flag` SET TAGS ('dbx_business_glossary_term' = 'Impact on Net Asset Value (NAV) Flag');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Name');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `mandatory_voluntary_flag` SET TAGS ('dbx_business_glossary_term' = 'Mandatory or Voluntary Flag');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `new_cusip` SET TAGS ('dbx_business_glossary_term' = 'New Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `new_cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `new_isin` SET TAGS ('dbx_business_glossary_term' = 'New International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `new_isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `new_security_name` SET TAGS ('dbx_business_glossary_term' = 'New Security Name');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `new_sedol` SET TAGS ('dbx_business_glossary_term' = 'New Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `new_sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `new_ticker` SET TAGS ('dbx_business_glossary_term' = 'New Security Ticker Symbol');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `notification_sent_flag` SET TAGS ('dbx_business_glossary_term' = 'Notification Sent Flag');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `position_adjustment_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Position Adjustment Required Flag');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `processed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Processed Timestamp');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `record_date` SET TAGS ('dbx_business_glossary_term' = 'Record Date');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `rights_ratio_from` SET TAGS ('dbx_business_glossary_term' = 'Rights Issue Ratio From (Existing Shares)');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `rights_ratio_to` SET TAGS ('dbx_business_glossary_term' = 'Rights Issue Ratio To (New Shares)');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `source_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `split_ratio_from` SET TAGS ('dbx_business_glossary_term' = 'Stock Split Ratio From (Old Shares)');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `split_ratio_to` SET TAGS ('dbx_business_glossary_term' = 'Stock Split Ratio To (New Shares)');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `subscription_currency` SET TAGS ('dbx_business_glossary_term' = 'Subscription Currency Code');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `subscription_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `subscription_price` SET TAGS ('dbx_business_glossary_term' = 'Rights Subscription Price');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_business_glossary_term' = 'Tax Treatment Code');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `ticker` SET TAGS ('dbx_business_glossary_term' = 'Security Ticker Symbol');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`equity`.`corporate_action` ALTER COLUMN `withholding_tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Rate');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` SET TAGS ('dbx_subdomain' = 'instrument_reference');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `corporate_action_election_id` SET TAGS ('dbx_business_glossary_term' = 'Corporate Action Election Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `corporate_action_id` SET TAGS ('dbx_business_glossary_term' = 'Corporate Action Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `corporate_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Manager Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `corporate_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `corporate_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `corporate_trader_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `corporate_trader_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `corporate_trader_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `custodian_counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Modified By User Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `equity_position_id` SET TAGS ('dbx_business_glossary_term' = 'Position Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `holding_id` SET TAGS ('dbx_business_glossary_term' = 'Holding Id (Foreign Key)');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `portfolio_manager_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Manager Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `trader_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trader Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `accounting_entry_reference` SET TAGS ('dbx_business_glossary_term' = 'Accounting Entry Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `actual_quantity_processed` SET TAGS ('dbx_business_glossary_term' = 'Actual Quantity Processed');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `agent_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Agent Contact Email');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `agent_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `agent_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `agent_name` SET TAGS ('dbx_business_glossary_term' = 'Agent Name');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `cash_consideration_amount` SET TAGS ('dbx_business_glossary_term' = 'Cash Consideration Amount');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `cash_consideration_currency` SET TAGS ('dbx_business_glossary_term' = 'Cash Consideration Currency');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `cash_consideration_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `consideration_type` SET TAGS ('dbx_business_glossary_term' = 'Consideration Type');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `consideration_type` SET TAGS ('dbx_value_regex' = 'cash|stock|mixed|rights');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `custodian_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Custodian Reference Number');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `elected_quantity` SET TAGS ('dbx_business_glossary_term' = 'Elected Quantity');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `election_confirmation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Election Confirmation Timestamp');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `election_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Election Deadline Date');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `election_option_code` SET TAGS ('dbx_business_glossary_term' = 'Election Option Code');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `election_option_description` SET TAGS ('dbx_business_glossary_term' = 'Election Option Description');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `election_percentage` SET TAGS ('dbx_business_glossary_term' = 'Election Percentage');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `election_rationale` SET TAGS ('dbx_business_glossary_term' = 'Election Rationale');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `election_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Election Reference Number');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `election_status` SET TAGS ('dbx_business_glossary_term' = 'Election Status');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `election_submission_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Election Submission Timestamp');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `election_type` SET TAGS ('dbx_business_glossary_term' = 'Election Type');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `election_type` SET TAGS ('dbx_value_regex' = 'tender_offer|rights_subscription|merger_election|dividend_reinvestment|stock_split_election|spin_off_election');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `eligible_quantity` SET TAGS ('dbx_business_glossary_term' = 'Eligible Quantity');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `execution_date` SET TAGS ('dbx_business_glossary_term' = 'Execution Date');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `ic_approval_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Reference');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `investment_committee_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Required');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `net_cash_proceeds` SET TAGS ('dbx_business_glossary_term' = 'Net Cash Proceeds');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `proration_factor` SET TAGS ('dbx_business_glossary_term' = 'Proration Factor');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `stock_consideration_isin` SET TAGS ('dbx_business_glossary_term' = 'Stock Consideration International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `stock_consideration_isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `stock_consideration_quantity` SET TAGS ('dbx_business_glossary_term' = 'Stock Consideration Quantity');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_business_glossary_term' = 'Tax Treatment Code');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ALTER COLUMN `withholding_tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Rate');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` SET TAGS ('dbx_subdomain' = 'research_analysis');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `equity_factor_exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Factor Exposure Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `equity_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `factor_model_id` SET TAGS ('dbx_business_glossary_term' = 'Factor Model Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `active_exposure` SET TAGS ('dbx_business_glossary_term' = 'Active Exposure');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `adjustment_reason` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Reason');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `beta_to_market` SET TAGS ('dbx_business_glossary_term' = 'Beta to Market');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Calculation Method');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `calculation_method` SET TAGS ('dbx_value_regex' = 'regression|covariance|optimization|attribution');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Calculation Timestamp');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `contribution_to_risk` SET TAGS ('dbx_business_glossary_term' = 'Contribution to Risk');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `data_source` SET TAGS ('dbx_value_regex' = 'MSCI_Barra|Bloomberg|FactSet|Internal|Aladdin');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `exposure_date` SET TAGS ('dbx_business_glossary_term' = 'Exposure Date');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `exposure_percentile` SET TAGS ('dbx_business_glossary_term' = 'Exposure Percentile');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `exposure_value` SET TAGS ('dbx_business_glossary_term' = 'Exposure Value');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `exposure_weight` SET TAGS ('dbx_business_glossary_term' = 'Exposure Weight');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `factor_category` SET TAGS ('dbx_business_glossary_term' = 'Factor Category');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `factor_category` SET TAGS ('dbx_value_regex' = 'style|industry|country|currency|market|macro');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `factor_model_version` SET TAGS ('dbx_business_glossary_term' = 'Factor Model Version');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `factor_name` SET TAGS ('dbx_business_glossary_term' = 'Factor Name');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `factor_return` SET TAGS ('dbx_business_glossary_term' = 'Factor Return');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `factor_volatility` SET TAGS ('dbx_business_glossary_term' = 'Factor Volatility');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `frequency` SET TAGS ('dbx_business_glossary_term' = 'Frequency');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `lookback_period_days` SET TAGS ('dbx_business_glossary_term' = 'Lookback Period Days');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `marginal_contribution_to_risk` SET TAGS ('dbx_business_glossary_term' = 'Marginal Contribution to Risk (MCTR)');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `outlier_flag` SET TAGS ('dbx_business_glossary_term' = 'Outlier Flag');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `p_value` SET TAGS ('dbx_business_glossary_term' = 'P-Value');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `quality_score` SET TAGS ('dbx_business_glossary_term' = 'Quality Score');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `r_squared` SET TAGS ('dbx_business_glossary_term' = 'R-Squared');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ALTER COLUMN `t_statistic` SET TAGS ('dbx_business_glossary_term' = 'T-Statistic');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` SET TAGS ('dbx_subdomain' = 'instrument_reference');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `equity_sector_classification_id` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification ID');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security ID');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `analyst_override_flag` SET TAGS ('dbx_business_glossary_term' = 'Analyst Override Flag');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `benchmark_inclusion_flag` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Inclusion Flag');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `classification_confidence_score` SET TAGS ('dbx_business_glossary_term' = 'Classification Confidence Score');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `classification_methodology` SET TAGS ('dbx_business_glossary_term' = 'Classification Methodology');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `classification_notes` SET TAGS ('dbx_business_glossary_term' = 'Classification Notes');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `classification_scheme` SET TAGS ('dbx_business_glossary_term' = 'Classification Scheme');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `classification_scheme` SET TAGS ('dbx_value_regex' = 'GICS|ICB|NAICS|SIC|TRBC|BICS');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `classification_source` SET TAGS ('dbx_business_glossary_term' = 'Classification Source');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `classification_status` SET TAGS ('dbx_business_glossary_term' = 'Classification Status');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `classification_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|under_review|deprecated');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `classification_version` SET TAGS ('dbx_business_glossary_term' = 'Classification Version');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[0-9A-Z]{5}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `data_quality_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Flag');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `industry_code` SET TAGS ('dbx_business_glossary_term' = 'Industry Code');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `industry_group_code` SET TAGS ('dbx_business_glossary_term' = 'Industry Group Code');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `industry_group_name` SET TAGS ('dbx_business_glossary_term' = 'Industry Group Name');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `industry_name` SET TAGS ('dbx_business_glossary_term' = 'Industry Name');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `override_justification` SET TAGS ('dbx_business_glossary_term' = 'Override Justification');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `previous_sector_code` SET TAGS ('dbx_business_glossary_term' = 'Previous Sector Code');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `previous_sub_industry_code` SET TAGS ('dbx_business_glossary_term' = 'Previous Sub-Industry Code');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `primary_classification_flag` SET TAGS ('dbx_business_glossary_term' = 'Primary Classification Flag');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `reclassification_reason` SET TAGS ('dbx_business_glossary_term' = 'Reclassification Reason');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `revenue_percentage` SET TAGS ('dbx_business_glossary_term' = 'Revenue Percentage');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `sector_code` SET TAGS ('dbx_business_glossary_term' = 'Sector Code');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `sector_name` SET TAGS ('dbx_business_glossary_term' = 'Sector Name');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `sub_industry_code` SET TAGS ('dbx_business_glossary_term' = 'Sub-Industry Code');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `sub_industry_name` SET TAGS ('dbx_business_glossary_term' = 'Sub-Industry Name');
ALTER TABLE `asset_management`.`equity`.`equity_sector_classification` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` SET TAGS ('dbx_subdomain' = 'instrument_reference');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `security_sector_mapping_id` SET TAGS ('dbx_business_glossary_term' = 'Security Sector Mapping Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `benchmark_alignment_flag` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Alignment Flag');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `benchmark_sector_code` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Sector Code');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `carbon_intensity_sector` SET TAGS ('dbx_business_glossary_term' = 'Carbon Intensity Sector');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `classification_confidence_score` SET TAGS ('dbx_business_glossary_term' = 'Classification Confidence Score');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `classification_notes` SET TAGS ('dbx_business_glossary_term' = 'Classification Notes');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `classification_scheme` SET TAGS ('dbx_business_glossary_term' = 'Classification Scheme');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `classification_scheme` SET TAGS ('dbx_value_regex' = 'GICS|ICB|TRBC|BICS|NAICS|SIC');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `classification_source` SET TAGS ('dbx_business_glossary_term' = 'Classification Source');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `classification_source_identifier` SET TAGS ('dbx_business_glossary_term' = 'Classification Source Identifier');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `classification_status` SET TAGS ('dbx_business_glossary_term' = 'Classification Status');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `classification_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|superseded');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `classification_version` SET TAGS ('dbx_business_glossary_term' = 'Classification Version');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `data_quality_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Flag');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `esg_sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Sector Classification');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `industry_code` SET TAGS ('dbx_business_glossary_term' = 'Industry Code');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `industry_group_code` SET TAGS ('dbx_business_glossary_term' = 'Industry Group Code');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `industry_group_name` SET TAGS ('dbx_business_glossary_term' = 'Industry Group Name');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `industry_name` SET TAGS ('dbx_business_glossary_term' = 'Industry Name');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `internal_sector_code` SET TAGS ('dbx_business_glossary_term' = 'Internal Sector Code');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `internal_sector_name` SET TAGS ('dbx_business_glossary_term' = 'Internal Sector Name');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `last_verification_date` SET TAGS ('dbx_business_glossary_term' = 'Last Verification Date');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `manual_override_flag` SET TAGS ('dbx_business_glossary_term' = 'Manual Override Flag');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `override_by_user` SET TAGS ('dbx_business_glossary_term' = 'Override By User');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `override_reason` SET TAGS ('dbx_business_glossary_term' = 'Override Reason');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `override_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Override Timestamp');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `primary_classification_flag` SET TAGS ('dbx_business_glossary_term' = 'Primary Classification Flag');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `reclassification_reason` SET TAGS ('dbx_business_glossary_term' = 'Reclassification Reason');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `regulatory_sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Sector Classification');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `sector_code` SET TAGS ('dbx_business_glossary_term' = 'Sector Code');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `sector_name` SET TAGS ('dbx_business_glossary_term' = 'Sector Name');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9BCDFGHJKLMNPQRSTVWXYZ]{7}$');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `sub_industry_code` SET TAGS ('dbx_business_glossary_term' = 'Sub-Industry Code');
ALTER TABLE `asset_management`.`equity`.`security_sector_mapping` ALTER COLUMN `sub_industry_name` SET TAGS ('dbx_business_glossary_term' = 'Sub-Industry Name');
ALTER TABLE `asset_management`.`equity`.`stock_selection` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`equity`.`stock_selection` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`stock_selection` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`stock_selection` SET TAGS ('dbx_subdomain' = 'research_analysis');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `stock_selection_id` SET TAGS ('dbx_business_glossary_term' = 'Stock Selection Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `research_note_id` SET TAGS ('dbx_business_glossary_term' = 'Research Note Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `valuation_model_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Model Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `active_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Active Weight Percentage');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `benchmark_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Weight Percentage');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `beta` SET TAGS ('dbx_business_glossary_term' = 'Beta Coefficient');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `conviction_level` SET TAGS ('dbx_business_glossary_term' = 'Analyst Conviction Level');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `conviction_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_business_glossary_term' = 'Country of Risk');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `current_market_price` SET TAGS ('dbx_business_glossary_term' = 'Current Market Price');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `decision_date` SET TAGS ('dbx_business_glossary_term' = 'Selection Decision Date');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `dividend_yield_percent` SET TAGS ('dbx_business_glossary_term' = 'Dividend Yield Percentage');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Selection Effective Date');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'ESG Integration Flag');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `esg_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Score');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `expected_return_percent` SET TAGS ('dbx_business_glossary_term' = 'Expected Return Percentage');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Selection Expiry Date');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `ic_approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Required Flag');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `implementation_date` SET TAGS ('dbx_business_glossary_term' = 'Implementation Date');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `implementation_status` SET TAGS ('dbx_business_glossary_term' = 'Implementation Status');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `implementation_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|cancelled');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `intrinsic_value` SET TAGS ('dbx_business_glossary_term' = 'Intrinsic Value');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `investment_horizon_months` SET TAGS ('dbx_business_glossary_term' = 'Investment Horizon in Months');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `investment_thesis_summary` SET TAGS ('dbx_business_glossary_term' = 'Investment Thesis Summary');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `key_catalysts` SET TAGS ('dbx_business_glossary_term' = 'Key Investment Catalysts');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `key_risks` SET TAGS ('dbx_business_glossary_term' = 'Key Investment Risks');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `market_capitalization_tier` SET TAGS ('dbx_business_glossary_term' = 'Market Capitalization Tier');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `market_capitalization_tier` SET TAGS ('dbx_value_regex' = 'large_cap|mid_cap|small_cap|micro_cap');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `price_to_earnings_ratio` SET TAGS ('dbx_business_glossary_term' = 'Price to Earnings (P/E) Ratio');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `recommendation` SET TAGS ('dbx_business_glossary_term' = 'Investment Recommendation');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `recommendation` SET TAGS ('dbx_value_regex' = 'buy|overweight|hold|underweight|sell|avoid');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `security_name` SET TAGS ('dbx_business_glossary_term' = 'Security Name');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `selection_decision_code` SET TAGS ('dbx_business_glossary_term' = 'Stock Selection Decision Code');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `selection_decision_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{6,12}$');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `selection_status` SET TAGS ('dbx_business_glossary_term' = 'Selection Decision Status');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `selection_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|approved|rejected|implemented|withdrawn');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `style_factor` SET TAGS ('dbx_business_glossary_term' = 'Investment Style Factor');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `style_factor` SET TAGS ('dbx_value_regex' = 'growth|value|blend|quality|momentum');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `target_position_value_base_currency` SET TAGS ('dbx_business_glossary_term' = 'Target Position Value in Base Currency');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `target_price` SET TAGS ('dbx_business_glossary_term' = 'Target Price');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `target_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Target Portfolio Weight Percentage');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `ticker_symbol` SET TAGS ('dbx_business_glossary_term' = 'Ticker Symbol');
ALTER TABLE `asset_management`.`equity`.`stock_selection` ALTER COLUMN `upside_downside_percent` SET TAGS ('dbx_business_glossary_term' = 'Upside or Downside Percentage');
ALTER TABLE `asset_management`.`equity`.`valuation_model` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`equity`.`valuation_model` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`valuation_model` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`valuation_model` SET TAGS ('dbx_subdomain' = 'research_analysis');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `valuation_model_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Model Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `capex_percent_of_revenue` SET TAGS ('dbx_business_glossary_term' = 'Capital Expenditure (CapEx) Percentage of Revenue');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `comparable_multiple_type` SET TAGS ('dbx_business_glossary_term' = 'Comparable Multiple Type');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `comparable_multiple_value` SET TAGS ('dbx_business_glossary_term' = 'Comparable Multiple Value');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `discount_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate Percentage');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `ebitda_margin_percent` SET TAGS ('dbx_business_glossary_term' = 'Earnings Before Interest Taxes Depreciation and Amortization (EBITDA) Margin Percentage');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `forecast_period_years` SET TAGS ('dbx_business_glossary_term' = 'Forecast Period Years');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `intrinsic_value_estimate` SET TAGS ('dbx_business_glossary_term' = 'Intrinsic Value Estimate');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `key_assumptions` SET TAGS ('dbx_business_glossary_term' = 'Key Assumptions');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `key_risks` SET TAGS ('dbx_business_glossary_term' = 'Key Risks');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `model_confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Model Confidence Level');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `model_confidence_level` SET TAGS ('dbx_value_regex' = 'High|Medium|Low');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `model_documentation_url` SET TAGS ('dbx_business_glossary_term' = 'Model Documentation Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `model_notes` SET TAGS ('dbx_business_glossary_term' = 'Model Notes');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `model_status` SET TAGS ('dbx_business_glossary_term' = 'Model Status');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `model_status` SET TAGS ('dbx_value_regex' = 'Active|Under Review|Suspended|Archived|Discontinued');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `model_type` SET TAGS ('dbx_business_glossary_term' = 'Valuation Model Type');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `net_margin_percent` SET TAGS ('dbx_business_glossary_term' = 'Net Profit Margin Percentage');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `peer_group_median_multiple` SET TAGS ('dbx_business_glossary_term' = 'Peer Group Median Multiple');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `recommendation` SET TAGS ('dbx_business_glossary_term' = 'Investment Recommendation');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `research_team` SET TAGS ('dbx_business_glossary_term' = 'Research Team');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `revenue_cagr_percent` SET TAGS ('dbx_business_glossary_term' = 'Revenue Compound Annual Growth Rate (CAGR) Percentage');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `scenario_analysis_flag` SET TAGS ('dbx_business_glossary_term' = 'Scenario Analysis Flag');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `sensitivity_analysis_flag` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Analysis Flag');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `target_price` SET TAGS ('dbx_business_glossary_term' = 'Target Price');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `target_price_horizon_months` SET TAGS ('dbx_business_glossary_term' = 'Target Price Horizon Months');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `terminal_growth_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Terminal Growth Rate Percentage');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `ticker_symbol` SET TAGS ('dbx_business_glossary_term' = 'Ticker Symbol');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `upside_downside_percent` SET TAGS ('dbx_business_glossary_term' = 'Upside or Downside Percentage');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`equity`.`valuation_model` ALTER COLUMN `working_capital_percent_of_revenue` SET TAGS ('dbx_business_glossary_term' = 'Working Capital Percentage of Revenue');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` SET TAGS ('dbx_subdomain' = 'instrument_reference');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `equity_issuer_id` SET TAGS ('dbx_business_glossary_term' = 'Equity Issuer Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `parent_issuer_equity_issuer_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Issuer Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `accounting_standard` SET TAGS ('dbx_business_glossary_term' = 'Accounting Standard Framework');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `accounting_standard` SET TAGS ('dbx_value_regex' = 'IFRS|US_GAAP|local_GAAP|other');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `auditor_name` SET TAGS ('dbx_business_glossary_term' = 'External Auditor Name');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `carbon_intensity` SET TAGS ('dbx_business_glossary_term' = 'Carbon Intensity Metric');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `ceo_name` SET TAGS ('dbx_business_glossary_term' = 'Chief Executive Officer (CEO) Name');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `cfo_name` SET TAGS ('dbx_business_glossary_term' = 'Chief Financial Officer (CFO) Name');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `coverage_initiation_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Initiation Date');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `coverage_status` SET TAGS ('dbx_business_glossary_term' = 'Coverage Status');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `coverage_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|terminated');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `credit_rating_fitch` SET TAGS ('dbx_business_glossary_term' = 'Fitch Credit Rating');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `credit_rating_moody` SET TAGS ('dbx_business_glossary_term' = 'Moodys Credit Rating');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `credit_rating_sp` SET TAGS ('dbx_business_glossary_term' = 'Standard and Poors (S&P) Credit Rating');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `employee_count` SET TAGS ('dbx_business_glossary_term' = 'Total Employee Count');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `fiscal_year_end_day` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year End Day');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `fiscal_year_end_month` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year End Month');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `gics_industry_code` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Industry Code');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `gics_industry_code` SET TAGS ('dbx_value_regex' = '^[0-9]{6}$');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `gics_industry_group_code` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Industry Group Code');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `gics_industry_group_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `gics_sector_code` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Sector Code');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `gics_sector_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2}$');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `gics_sub_industry_code` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Sub-Industry Code');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `gics_sub_industry_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_business_glossary_term' = 'Headquarters Address');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `headquarters_city` SET TAGS ('dbx_business_glossary_term' = 'Headquarters City');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `headquarters_country_code` SET TAGS ('dbx_business_glossary_term' = 'Headquarters Country Code');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `headquarters_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `incorporation_country_code` SET TAGS ('dbx_business_glossary_term' = 'Country of Incorporation Code');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `incorporation_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `incorporation_date` SET TAGS ('dbx_business_glossary_term' = 'Date of Incorporation');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `investment_grade_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Grade (IG) Flag');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `investor_relations_email` SET TAGS ('dbx_business_glossary_term' = 'Investor Relations Email Address');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `investor_relations_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `investor_relations_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `investor_relations_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `investor_relations_phone` SET TAGS ('dbx_business_glossary_term' = 'Investor Relations Phone Number');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `investor_relations_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `investor_relations_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `issuer_status` SET TAGS ('dbx_business_glossary_term' = 'Issuer Lifecycle Status');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `issuer_type` SET TAGS ('dbx_business_glossary_term' = 'Issuer Type Classification');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Name');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `market_capitalization_tier` SET TAGS ('dbx_business_glossary_term' = 'Market Capitalization Tier');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `market_capitalization_tier` SET TAGS ('dbx_value_regex' = 'mega_cap|large_cap|mid_cap|small_cap|micro_cap|nano_cap');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `msci_esg_rating` SET TAGS ('dbx_business_glossary_term' = 'MSCI Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `net_zero_commitment_flag` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Commitment Flag');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `net_zero_target_year` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Target Year');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `primary_exchange_code` SET TAGS ('dbx_business_glossary_term' = 'Primary Stock Exchange Code');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `primary_listing_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Primary Listing Currency Code');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `primary_listing_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `primary_listing_ticker` SET TAGS ('dbx_business_glossary_term' = 'Primary Listing Ticker Symbol');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `record_version` SET TAGS ('dbx_business_glossary_term' = 'Record Version Number');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `short_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Short Name');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `sustainalytics_esg_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Sustainalytics Environmental Social and Governance (ESG) Risk Score');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `ultimate_parent_lei` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Parent Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `ultimate_parent_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Record Updated By User');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`equity`.`equity_issuer` ALTER COLUMN `website_url` SET TAGS ('dbx_business_glossary_term' = 'Corporate Website Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` SET TAGS ('dbx_subdomain' = 'instrument_reference');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `issuer_financials_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer Financials Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `capital_expenditures` SET TAGS ('dbx_business_glossary_term' = 'Capital Expenditures (CapEx)');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `cash_and_equivalents` SET TAGS ('dbx_business_glossary_term' = 'Cash and Cash Equivalents');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `cost_of_revenue` SET TAGS ('dbx_business_glossary_term' = 'Cost of Revenue');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `data_provider` SET TAGS ('dbx_business_glossary_term' = 'Data Provider');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `data_quality_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Flag');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `data_source_type` SET TAGS ('dbx_business_glossary_term' = 'Data Source Type');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `data_source_type` SET TAGS ('dbx_value_regex' = 'reported|consensus|restated|preliminary');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `depreciation_amortization` SET TAGS ('dbx_business_glossary_term' = 'Depreciation and Amortization');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `dividends_paid` SET TAGS ('dbx_business_glossary_term' = 'Dividends Paid');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `ebit` SET TAGS ('dbx_business_glossary_term' = 'Earnings Before Interest and Taxes (EBIT)');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `ebitda` SET TAGS ('dbx_business_glossary_term' = 'Earnings Before Interest Taxes Depreciation and Amortization (EBITDA)');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `eps_basic` SET TAGS ('dbx_business_glossary_term' = 'Earnings Per Share (EPS) Basic');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `eps_diluted` SET TAGS ('dbx_business_glossary_term' = 'Earnings Per Share (EPS) Diluted');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `filing_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Date');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `financing_cash_flow` SET TAGS ('dbx_business_glossary_term' = 'Financing Cash Flow');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `fiscal_period_type` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Period Type');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `fiscal_period_type` SET TAGS ('dbx_value_regex' = 'annual|semi-annual|quarterly|interim');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `fiscal_quarter` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Quarter');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `free_cash_flow` SET TAGS ('dbx_business_glossary_term' = 'Free Cash Flow');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `gross_profit` SET TAGS ('dbx_business_glossary_term' = 'Gross Profit');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `income_tax_expense` SET TAGS ('dbx_business_glossary_term' = 'Income Tax Expense');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `interest_expense` SET TAGS ('dbx_business_glossary_term' = 'Interest Expense');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `interest_income` SET TAGS ('dbx_business_glossary_term' = 'Interest Income');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `investing_cash_flow` SET TAGS ('dbx_business_glossary_term' = 'Investing Cash Flow');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Name');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `net_income` SET TAGS ('dbx_business_glossary_term' = 'Net Income');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `operating_cash_flow` SET TAGS ('dbx_business_glossary_term' = 'Operating Cash Flow');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `operating_expenses` SET TAGS ('dbx_business_glossary_term' = 'Operating Expenses');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `other_income_expense` SET TAGS ('dbx_business_glossary_term' = 'Other Income and Expense');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Period End Date');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `pretax_income` SET TAGS ('dbx_business_glossary_term' = 'Pretax Income');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `reporting_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Reporting Currency Code');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `reporting_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `reporting_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Date');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `revenue` SET TAGS ('dbx_business_glossary_term' = 'Total Revenue');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9BCDFGHJKLMNPQRSTVWXYZ]{7}$');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `shares_outstanding_basic` SET TAGS ('dbx_business_glossary_term' = 'Shares Outstanding Basic');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `shares_outstanding_diluted` SET TAGS ('dbx_business_glossary_term' = 'Shares Outstanding Diluted');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `ticker_symbol` SET TAGS ('dbx_business_glossary_term' = 'Ticker Symbol');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `total_assets` SET TAGS ('dbx_business_glossary_term' = 'Total Assets');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `total_debt` SET TAGS ('dbx_business_glossary_term' = 'Total Debt');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `total_equity` SET TAGS ('dbx_business_glossary_term' = 'Total Shareholders Equity');
ALTER TABLE `asset_management`.`equity`.`issuer_financials` ALTER COLUMN `total_liabilities` SET TAGS ('dbx_business_glossary_term' = 'Total Liabilities');
ALTER TABLE `asset_management`.`equity`.`dividend_record` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`equity`.`dividend_record` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`dividend_record` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`dividend_record` SET TAGS ('dbx_subdomain' = 'portfolio_stewardship');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `dividend_record_id` SET TAGS ('dbx_business_glossary_term' = 'Dividend Record Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `corporate_action_id` SET TAGS ('dbx_business_glossary_term' = 'Corporate Action Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `equity_position_id` SET TAGS ('dbx_business_glossary_term' = 'Equity Position Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `accrual_date` SET TAGS ('dbx_business_glossary_term' = 'Accrual Date');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `country_of_domicile` SET TAGS ('dbx_business_glossary_term' = 'Country of Domicile');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `country_of_domicile` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_business_glossary_term' = 'Country of Risk');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `country_of_risk` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[0-9A-Z]{5}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `custodian_account_number` SET TAGS ('dbx_business_glossary_term' = 'Custodian Account Number');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `custodian_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `custodian_lei` SET TAGS ('dbx_business_glossary_term' = 'Custodian Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `custodian_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `declaration_date` SET TAGS ('dbx_business_glossary_term' = 'Declaration Date');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `dividend_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Dividend Currency Code');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `dividend_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `dividend_frequency` SET TAGS ('dbx_business_glossary_term' = 'Dividend Frequency');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `dividend_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly|irregular');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `dividend_rate_per_share` SET TAGS ('dbx_business_glossary_term' = 'Dividend Rate Per Share');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `dividend_status` SET TAGS ('dbx_business_glossary_term' = 'Dividend Status');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `dividend_status` SET TAGS ('dbx_value_regex' = 'declared|accrued|paid|cancelled|pending');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `dividend_type` SET TAGS ('dbx_business_glossary_term' = 'Dividend Type');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `dividend_type` SET TAGS ('dbx_value_regex' = 'ordinary|special|interim|final|liquidating|return_of_capital');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `ex_dividend_date` SET TAGS ('dbx_business_glossary_term' = 'Ex-Dividend Date');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `fx_rate_date` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate Date');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `gross_dividend_amount_base` SET TAGS ('dbx_business_glossary_term' = 'Gross Dividend Amount Base Currency');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `gross_dividend_amount_local` SET TAGS ('dbx_business_glossary_term' = 'Gross Dividend Amount Local Currency');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `net_dividend_amount_base` SET TAGS ('dbx_business_glossary_term' = 'Net Dividend Amount Base Currency');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `net_dividend_amount_local` SET TAGS ('dbx_business_glossary_term' = 'Net Dividend Amount Local Currency');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `quantity_held` SET TAGS ('dbx_business_glossary_term' = 'Quantity Held');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `record_date` SET TAGS ('dbx_business_glossary_term' = 'Record Date');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `record_version` SET TAGS ('dbx_business_glossary_term' = 'Record Version');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `reinvestment_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinvestment Flag');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `security_name` SET TAGS ('dbx_business_glossary_term' = 'Security Name');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `tax_reclaim_amount_local` SET TAGS ('dbx_business_glossary_term' = 'Tax Reclaim Amount Local Currency');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `tax_reclaim_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Tax Reclaim Eligible Flag');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `tax_reclaim_status` SET TAGS ('dbx_business_glossary_term' = 'Tax Reclaim Status');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `tax_reclaim_status` SET TAGS ('dbx_value_regex' = 'not_applicable|pending|submitted|approved|received|rejected');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `ticker_symbol` SET TAGS ('dbx_business_glossary_term' = 'Ticker Symbol');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `withholding_tax_amount_base` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Amount Base Currency');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `withholding_tax_amount_local` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Amount Local Currency');
ALTER TABLE `asset_management`.`equity`.`dividend_record` ALTER COLUMN `withholding_tax_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Rate Percent');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` SET TAGS ('dbx_subdomain' = 'portfolio_stewardship');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `proxy_voting_record_id` SET TAGS ('dbx_business_glossary_term' = 'Proxy Voting Record Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Responsible Investment Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `responsible_investment_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Responsible Investment Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `ballot_reference` SET TAGS ('dbx_business_glossary_term' = 'Ballot Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[0-9A-Z]{5}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `custodian_account_number` SET TAGS ('dbx_business_glossary_term' = 'Custodian Account Number');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `custodian_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `custodian_name` SET TAGS ('dbx_business_glossary_term' = 'Custodian Name');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `disclosure_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Disclosure Required Flag');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `esg_relevance_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Relevance Flag');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `esg_theme` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Theme');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `fund_vote_decision` SET TAGS ('dbx_business_glossary_term' = 'Fund Vote Decision');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `fund_vote_decision` SET TAGS ('dbx_value_regex' = 'For|Against|Abstain|Withhold|Do Not Vote|Take No Action');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Name');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `management_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Management Recommendation');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `management_recommendation` SET TAGS ('dbx_value_regex' = 'For|Against|Abstain|No Recommendation');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `meeting_country_code` SET TAGS ('dbx_business_glossary_term' = 'Meeting Country Code');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `meeting_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Meeting Date');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `meeting_location` SET TAGS ('dbx_business_glossary_term' = 'Meeting Location');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `meeting_outcome` SET TAGS ('dbx_business_glossary_term' = 'Meeting Outcome');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `meeting_outcome` SET TAGS ('dbx_value_regex' = 'Passed|Failed|Withdrawn|Postponed|Pending');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `meeting_type` SET TAGS ('dbx_business_glossary_term' = 'Meeting Type');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `meeting_type` SET TAGS ('dbx_value_regex' = 'AGM|EGM|Special|Class|Adjourned|Written Consent');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `policy_alignment_flag` SET TAGS ('dbx_business_glossary_term' = 'Policy Alignment Flag');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `proxy_advisor_name` SET TAGS ('dbx_business_glossary_term' = 'Proxy Advisor Name');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `proxy_advisor_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Proxy Advisor Recommendation');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `proxy_advisor_recommendation` SET TAGS ('dbx_value_regex' = 'For|Against|Abstain|No Recommendation');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `proxy_service_provider` SET TAGS ('dbx_business_glossary_term' = 'Proxy Service Provider');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `record_date` SET TAGS ('dbx_business_glossary_term' = 'Record Date');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `resolution_category` SET TAGS ('dbx_business_glossary_term' = 'Resolution Category');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `resolution_description` SET TAGS ('dbx_business_glossary_term' = 'Resolution Description');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `resolution_number` SET TAGS ('dbx_business_glossary_term' = 'Resolution Number');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `resolution_sub_category` SET TAGS ('dbx_business_glossary_term' = 'Resolution Sub-Category');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `shares_entitled` SET TAGS ('dbx_business_glossary_term' = 'Shares Entitled');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `shares_voted` SET TAGS ('dbx_business_glossary_term' = 'Shares Voted');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `ticker_symbol` SET TAGS ('dbx_business_glossary_term' = 'Ticker Symbol');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `vote_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Vote Approved By');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `vote_approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Vote Approved Timestamp');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `vote_confirmation_number` SET TAGS ('dbx_business_glossary_term' = 'Vote Confirmation Number');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `vote_rationale` SET TAGS ('dbx_business_glossary_term' = 'Vote Rationale');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `vote_review_status` SET TAGS ('dbx_business_glossary_term' = 'Vote Review Status');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `vote_review_status` SET TAGS ('dbx_value_regex' = 'Pending|Reviewed|Approved|Escalated');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `vote_submission_method` SET TAGS ('dbx_business_glossary_term' = 'Vote Submission Method');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `vote_submission_method` SET TAGS ('dbx_value_regex' = 'Electronic|Paper|Proxy Card|Custodian|Third-Party Platform');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `vote_submission_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Vote Submission Timestamp');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `votes_abstain_percent` SET TAGS ('dbx_business_glossary_term' = 'Votes Abstain Percentage');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `votes_against_percent` SET TAGS ('dbx_business_glossary_term' = 'Votes Against Percentage');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `votes_for_percent` SET TAGS ('dbx_business_glossary_term' = 'Votes For Percentage');
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ALTER COLUMN `voting_power_percent` SET TAGS ('dbx_business_glossary_term' = 'Voting Power Percentage');
ALTER TABLE `asset_management`.`equity`.`engagement_log` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`equity`.`engagement_log` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`engagement_log` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`engagement_log` SET TAGS ('dbx_subdomain' = 'portfolio_stewardship');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `engagement_log_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Log Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `engagement_controversy_id` SET TAGS ('dbx_business_glossary_term' = 'Related Controversy Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `engagement_related_controversy_id` SET TAGS ('dbx_business_glossary_term' = 'Related Controversy Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `lead_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `related_proxy_vote_proxy_voting_record_id` SET TAGS ('dbx_business_glossary_term' = 'Related Proxy Vote Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `related_proxy_voting_record_id` SET TAGS ('dbx_business_glossary_term' = 'Related Proxy Vote Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `active_flag` SET TAGS ('dbx_business_glossary_term' = 'Active Record Flag');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `collaborative_partner_names` SET TAGS ('dbx_business_glossary_term' = 'Collaborative Partner Names');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Level');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `country_of_domicile` SET TAGS ('dbx_business_glossary_term' = 'Country of Domicile');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `country_of_domicile` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `document_reference_url` SET TAGS ('dbx_business_glossary_term' = 'Document Reference Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `engagement_date` SET TAGS ('dbx_business_glossary_term' = 'Engagement Date');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `engagement_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Engagement Duration in Minutes');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `engagement_mode` SET TAGS ('dbx_business_glossary_term' = 'Engagement Mode');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `engagement_mode` SET TAGS ('dbx_value_regex' = 'direct|collaborative|proxy_advisor|industry_coalition');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `engagement_notes` SET TAGS ('dbx_business_glossary_term' = 'Engagement Notes');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `engagement_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `engagement_objective` SET TAGS ('dbx_business_glossary_term' = 'Engagement Objective');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `engagement_status` SET TAGS ('dbx_business_glossary_term' = 'Engagement Status');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `engagement_status` SET TAGS ('dbx_value_regex' = 'initiated|ongoing|resolved|escalated|closed');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `engagement_type` SET TAGS ('dbx_business_glossary_term' = 'Engagement Type');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `engagement_type` SET TAGS ('dbx_value_regex' = 'letter|meeting|call|collaborative_engagement|shareholder_resolution|public_statement');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `escalation_date` SET TAGS ('dbx_business_glossary_term' = 'Escalation Date');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `escalation_level` SET TAGS ('dbx_business_glossary_term' = 'Escalation Level');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `escalation_level` SET TAGS ('dbx_value_regex' = 'none|board_letter|shareholder_proposal|vote_against|divestment_consideration');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `esg_pillar` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Pillar');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `esg_pillar` SET TAGS ('dbx_value_regex' = 'environmental|social|governance');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `follow_up_date` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Date');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `follow_up_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Required Flag');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `issuer_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Issuer Contact Email Address');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `issuer_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `issuer_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `issuer_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `issuer_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Contact Name');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `issuer_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `issuer_contact_title` SET TAGS ('dbx_business_glossary_term' = 'Issuer Contact Title');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Name');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `lead_analyst_name` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst Name');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `market_cap_tier` SET TAGS ('dbx_business_glossary_term' = 'Market Capitalization Tier');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `market_cap_tier` SET TAGS ('dbx_value_regex' = 'large_cap|mid_cap|small_cap|micro_cap');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `meeting_format` SET TAGS ('dbx_business_glossary_term' = 'Meeting Format');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `meeting_format` SET TAGS ('dbx_value_regex' = 'in_person|video_conference|phone|written_correspondence');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `meeting_location` SET TAGS ('dbx_business_glossary_term' = 'Meeting Location');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `milestone_achieved` SET TAGS ('dbx_business_glossary_term' = 'Milestone Achieved');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `milestone_date` SET TAGS ('dbx_business_glossary_term' = 'Milestone Date');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `outcome` SET TAGS ('dbx_business_glossary_term' = 'Engagement Outcome');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `outcome` SET TAGS ('dbx_value_regex' = 'positive_change|commitment_received|no_change|partial_progress|under_review');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `outcome_description` SET TAGS ('dbx_business_glossary_term' = 'Engagement Outcome Description');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `position_held_flag` SET TAGS ('dbx_business_glossary_term' = 'Position Held Flag');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `public_disclosure_flag` SET TAGS ('dbx_business_glossary_term' = 'Public Disclosure Flag');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `record_version` SET TAGS ('dbx_business_glossary_term' = 'Record Version Number');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `topic_category` SET TAGS ('dbx_business_glossary_term' = 'Engagement Topic Category');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `topic_detail` SET TAGS ('dbx_business_glossary_term' = 'Engagement Topic Detail');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Record Updated By User');
ALTER TABLE `asset_management`.`equity`.`engagement_log` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`equity`.`short_interest` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`equity`.`short_interest` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`short_interest` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`short_interest` SET TAGS ('dbx_subdomain' = 'portfolio_stewardship');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `short_interest_id` SET TAGS ('dbx_business_glossary_term' = 'Short Interest Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `activity_type` SET TAGS ('dbx_business_glossary_term' = 'Activity Type');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `activity_type` SET TAGS ('dbx_value_regex' = 'short_position|securities_lending|both');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `borrowing_cost_accrued` SET TAGS ('dbx_business_glossary_term' = 'Borrowing Cost Accrued');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `borrowing_cost_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Borrowing Cost Rate Basis Points (bps)');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'cash|government_bonds|corporate_bonds|equities|mixed');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `collateral_value_received` SET TAGS ('dbx_business_glossary_term' = 'Collateral Value Received');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `compliance_breach_reason` SET TAGS ('dbx_business_glossary_term' = 'Compliance Breach Reason');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Compliance Flag');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `counterparty_name` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Name');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `custodian_account_number` SET TAGS ('dbx_business_glossary_term' = 'Custodian Account Number');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `custodian_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `custodian_lei` SET TAGS ('dbx_business_glossary_term' = 'Custodian Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `custodian_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `exchange_code` SET TAGS ('dbx_business_glossary_term' = 'Exchange Code');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `lending_fee_accrued` SET TAGS ('dbx_business_glossary_term' = 'Lending Fee Accrued');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `lending_fee_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Lending Fee Rate Basis Points (bps)');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `lent_market_value_base` SET TAGS ('dbx_business_glossary_term' = 'Lent Market Value Base Currency');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `lent_market_value_local` SET TAGS ('dbx_business_glossary_term' = 'Lent Market Value Local Currency');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `lent_quantity` SET TAGS ('dbx_business_glossary_term' = 'Lent Quantity');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `loan_maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Loan Maturity Date');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `loan_start_date` SET TAGS ('dbx_business_glossary_term' = 'Loan Start Date');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `local_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Local Currency Code');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `local_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `position_date` SET TAGS ('dbx_business_glossary_term' = 'Position Date');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `recall_date` SET TAGS ('dbx_business_glossary_term' = 'Recall Date');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `return_date` SET TAGS ('dbx_business_glossary_term' = 'Return Date');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `settlement_status` SET TAGS ('dbx_business_glossary_term' = 'Settlement Status');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `settlement_status` SET TAGS ('dbx_value_regex' = 'settled|pending|failed|recalled|returned');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `short_cost_basis` SET TAGS ('dbx_business_glossary_term' = 'Short Cost Basis');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `short_position_market_value_base` SET TAGS ('dbx_business_glossary_term' = 'Short Position Market Value Base Currency');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `short_position_market_value_local` SET TAGS ('dbx_business_glossary_term' = 'Short Position Market Value Local Currency');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `short_position_quantity` SET TAGS ('dbx_business_glossary_term' = 'Short Position Quantity');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `ticker_symbol` SET TAGS ('dbx_business_glossary_term' = 'Ticker Symbol');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `trade_date` SET TAGS ('dbx_business_glossary_term' = 'Trade Date');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `unrealized_gain_loss_short` SET TAGS ('dbx_business_glossary_term' = 'Unrealized Gain Loss on Short Position');
ALTER TABLE `asset_management`.`equity`.`short_interest` ALTER COLUMN `valuation_source` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source');
ALTER TABLE `asset_management`.`equity`.`restriction` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`equity`.`restriction` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`restriction` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`restriction` SET TAGS ('dbx_subdomain' = 'portfolio_stewardship');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `restriction_id` SET TAGS ('dbx_business_glossary_term' = 'Restriction Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `active_flag` SET TAGS ('dbx_business_glossary_term' = 'Active Flag');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `breach_notification_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Breach Notification Required Flag');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `breach_tolerance_percent` SET TAGS ('dbx_business_glossary_term' = 'Breach Tolerance Percentage');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `restriction_code` SET TAGS ('dbx_business_glossary_term' = 'Restriction Code');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `compliance_system_flag` SET TAGS ('dbx_business_glossary_term' = 'Compliance System Flag');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `country_iso_code` SET TAGS ('dbx_business_glossary_term' = 'Country International Organization for Standardization (ISO) Code');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `country_iso_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `esg_criteria` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Criteria');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `restriction_level` SET TAGS ('dbx_business_glossary_term' = 'Restriction Level');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `mandate_reference` SET TAGS ('dbx_business_glossary_term' = 'Mandate Reference');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Frequency');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_value_regex' = 'real_time|daily|weekly|monthly|quarterly|ad_hoc');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `restriction_name` SET TAGS ('dbx_business_glossary_term' = 'Restriction Name');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `notification_recipient_list` SET TAGS ('dbx_business_glossary_term' = 'Notification Recipient List');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `notification_recipient_list` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `override_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Override Allowed Flag');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `override_approval_level` SET TAGS ('dbx_business_glossary_term' = 'Override Approval Level');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `override_approval_level` SET TAGS ('dbx_value_regex' = 'cio|cro|ic|board|none');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `policy_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Policy Document Reference');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `rationale` SET TAGS ('dbx_business_glossary_term' = 'Rationale');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `regulatory_authority` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `restriction_status` SET TAGS ('dbx_business_glossary_term' = 'Restriction Status');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `restriction_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|expired|suspended');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `restriction_type` SET TAGS ('dbx_business_glossary_term' = 'Restriction Type');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `restriction_type` SET TAGS ('dbx_value_regex' = 'regulatory|mandate|esg_exclusion|sanctions|internal_policy|concentration_limit');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `sanctions_list` SET TAGS ('dbx_business_glossary_term' = 'Sanctions List');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'Restriction Scope');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `scope` SET TAGS ('dbx_value_regex' = 'buy|sell|hold|trade|all');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `threshold_unit` SET TAGS ('dbx_business_glossary_term' = 'Threshold Unit');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `threshold_unit` SET TAGS ('dbx_value_regex' = 'percent|absolute_value|shares|weight|exposure');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `threshold_value` SET TAGS ('dbx_business_glossary_term' = 'Threshold Value');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`equity`.`restriction` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` SET TAGS ('dbx_subdomain' = 'instrument_reference');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `index_rebalance_event_id` SET TAGS ('dbx_business_glossary_term' = 'Index Rebalance Event Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `compliance_reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Reviewer Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Reviewer Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `equity_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Identifier (ID)');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `active_flag` SET TAGS ('dbx_business_glossary_term' = 'Active Flag');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `announcement_date` SET TAGS ('dbx_business_glossary_term' = 'Announcement Date');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `announcement_document_url` SET TAGS ('dbx_business_glossary_term' = 'Announcement Document Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `announcement_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Announcement Timestamp');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `benchmark_code` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Code');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `benchmark_name` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Name');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `capping_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Capping Applied Flag');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `compliance_review_date` SET TAGS ('dbx_business_glossary_term' = 'Compliance Review Date');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `compliance_review_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Compliance Review Required Flag');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `constituent_list_url` SET TAGS ('dbx_business_glossary_term' = 'Constituent List Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `effective_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Effective Timestamp');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `esg_criteria_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Criteria Applied Flag');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `estimated_trading_volume` SET TAGS ('dbx_business_glossary_term' = 'Estimated Trading Volume');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `estimated_turnover_percent` SET TAGS ('dbx_business_glossary_term' = 'Estimated Turnover Percent');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `free_float_minimum_percent` SET TAGS ('dbx_business_glossary_term' = 'Free Float Minimum Percent');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `impact_assessment_summary` SET TAGS ('dbx_business_glossary_term' = 'Impact Assessment Summary');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `index_provider` SET TAGS ('dbx_business_glossary_term' = 'Index Provider');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `liquidity_threshold` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Threshold');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `market_cap_cutoff` SET TAGS ('dbx_business_glossary_term' = 'Market Capitalization (Cap) Cutoff');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `maximum_constituent_weight_percent` SET TAGS ('dbx_business_glossary_term' = 'Maximum Constituent Weight Percent');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `methodology_version` SET TAGS ('dbx_business_glossary_term' = 'Methodology Version');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `number_of_additions` SET TAGS ('dbx_business_glossary_term' = 'Number of Additions');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `number_of_deletions` SET TAGS ('dbx_business_glossary_term' = 'Number of Deletions');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `number_of_weight_changes` SET TAGS ('dbx_business_glossary_term' = 'Number of Weight Changes');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `portfolio_exposure_flag` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Exposure Flag');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `rebalance_rationale` SET TAGS ('dbx_business_glossary_term' = 'Rebalance Rationale');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `rebalance_status` SET TAGS ('dbx_business_glossary_term' = 'Rebalance Status');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `rebalance_status` SET TAGS ('dbx_value_regex' = 'announced|pending|effective|completed|cancelled');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `rebalance_type` SET TAGS ('dbx_business_glossary_term' = 'Rebalance Type');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `rebalance_type` SET TAGS ('dbx_value_regex' = 'quarterly|semi-annual|annual|ad-hoc|reconstitution|special');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `record_version` SET TAGS ('dbx_business_glossary_term' = 'Record Version');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `review_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Review Period End Date');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `review_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Review Period Start Date');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `sector_rebalance_flag` SET TAGS ('dbx_business_glossary_term' = 'Sector Rebalance Flag');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `total_constituents_post_rebalance` SET TAGS ('dbx_business_glossary_term' = 'Total Constituents Post-Rebalance');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `trading_strategy_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Trading Strategy Recommendation');
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By');
ALTER TABLE `asset_management`.`equity`.`earnings_announcement` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`equity`.`earnings_announcement` SET TAGS ('dbx_domain' = 'equity');
ALTER TABLE `asset_management`.`equity`.`earnings_announcement` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`equity`.`earnings_announcement` SET TAGS ('dbx_subdomain' = 'research_analysis');
