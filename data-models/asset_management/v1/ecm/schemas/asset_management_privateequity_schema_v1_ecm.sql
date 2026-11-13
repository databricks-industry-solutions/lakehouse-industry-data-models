-- Schema for Domain: privateequity | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:28

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`privateequity` COMMENT 'Domain for private equity and co-investment operations including LP/GP fund structures, vintage year tracking, capital calls (drawdowns), distributions, J-Curve modeling, dry powder tracking, and carried interest waterfall calculations.';
ALTER SCHEMA `asset_management`.`privateequity` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `asset_management`.`privateequity` SET TAGS ('dbx_domain' = 'privateequity');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`fund` (
    `fund_id` BIGINT COMMENT 'Unique identifier for the fund data product (auto-inserted during validation).',
    `actor_id` BIGINT COMMENT 'Reference to the custodian bank or institution holding the funds assets and cash.',
    `fund_administrator_id` BIGINT COMMENT 'Reference to the third-party fund administrator responsible for NAV calculation, capital call processing, and LP reporting.',
    `auditor_id` BIGINT COMMENT 'Reference to the external audit firm responsible for annual financial statement audits of the fund.',
    `climate_scenario_id` BIGINT COMMENT 'Foreign key linking to esg.climate_scenario. Business justification: Funds use climate scenarios for stress testing and risk assessment.',
    `controversy_id` BIGINT COMMENT 'Foreign key linking to esg.controversy. Business justification: Funds track controversies affecting portfolio companies for risk management.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: Fund uses a specific economic scenario for risk modeling and projections, a core part of investment strategy.',
    `employee_id` BIGINT COMMENT 'Reference to the third-party fund administrator responsible for NAV calculation, capital call processing, and LP reporting.',
    `engagement_activity_id` BIGINT COMMENT 'Foreign key linking to esg.engagement_activity. Business justification: Funds record engagement activities with investees to drive ESG outcomes.',
    `engagement_objective_id` BIGINT COMMENT 'Foreign key linking to esg.engagement_objective. Business justification: Funds set specific engagement objectives for ESG improvement.',
    `esg_benchmark_id` BIGINT COMMENT 'Foreign key linking to esg.esg_benchmark. Business justification: Funds benchmark ESG performance against industry standards.',
    `esg_policy_id` BIGINT COMMENT 'Foreign key linking to esg.policy. Business justification: Each fund follows an ESG policy that sets integration level and compliance requirements.',
    `exclusion_list_id` BIGINT COMMENT 'Foreign key linking to esg.exclusion_list. Business justification: Funds maintain exclusion lists of securities or sectors to avoid for ESG compliance.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the General Partner entity responsible for managing the fund and making investment decisions.',
    `macro_model_run_id` BIGINT COMMENT 'Foreign key linking to research.macro_model_run. Business justification: Macro model runs provide scenario projections used in fund valuation and stress testing.',
    `master_fund_id` BIGINT COMMENT 'Reference to the master fund if this is a feeder fund in a master-feeder structure.',
    `risk_model_id` BIGINT COMMENT 'Foreign key linking to risk.model. Business justification: Fund risk model FK required for VaR calculation and regulatory reporting.',
    `stress_scenario_id` BIGINT COMMENT 'Foreign key linking to risk.stress_scenario. Business justification: Fund stress scenario FK needed for scenario‑based VaR and capital adequacy testing.',
    `tcfd_disclosure_id` BIGINT COMMENT 'Foreign key linking to esg.tcfd_disclosure. Business justification: Funds file TCF disclosures for their portfolio, requiring a link to the disclosure record.',
    `benchmark_index` STRING COMMENT 'The primary performance benchmark or peer group index used to evaluate fund performance (e.g., Cambridge Associates PE Index, Preqin Buyout Index).',
    `carried_interest_rate` DECIMAL(5,4) COMMENT 'The performance fee rate (carry) paid to the GP from fund profits after the hurdle rate is achieved, expressed as a decimal percentage.',
    `catch_up_rate` DECIMAL(5,4) COMMENT 'The percentage of profits allocated to the GP after the hurdle is met and before the carried interest split, allowing GP to catch up to its target carry percentage.',
    `clawback_provision` BOOLEAN COMMENT 'Indicates whether the LPA includes a clawback provision requiring the GP to return excess carried interest if final fund performance falls below the hurdle.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this fund record was first created in the system.',
    `currency` STRING COMMENT 'The base currency in which the fund is denominated and reports Net Asset Value (NAV), using ISO 4217 three-letter currency code.. Valid values are `^[A-Z]{3}$`',
    `domicile_country` STRING COMMENT 'The country of legal domicile or incorporation for the fund vehicle, using ISO 3166-1 alpha-3 country code.. Valid values are `^[A-Z]{3}$`',
    `domicile_jurisdiction` STRING COMMENT 'The specific legal jurisdiction or state within the domicile country where the fund is registered (e.g., Delaware, Cayman Islands).',
    `esg_strategy` STRING COMMENT 'Description of the funds Environmental, Social, and Governance (ESG) integration approach, responsible investment policies, and sustainability commitments.',
    `extension_options_years` BIGINT COMMENT 'The number of additional years the fund term may be extended beyond the base term, subject to GP discretion or LP approval per LPA.',
    `final_close_date` DATE COMMENT 'The date of the funds final capital close when fundraising concluded and no further LP commitments are accepted.',
    `first_close_date` DATE COMMENT 'The date of the funds initial capital close when the first Limited Partner (LP) commitments were accepted and the fund began operations.',
    `fund_status` STRING COMMENT 'Current lifecycle stage of the fund: fundraising (capital raising), investing (deployment period), harvesting (realization period), liquidated (fully exited), or dissolved.. Valid values are `fundraising|investing|harvesting|liquidated|dissolved`',
    `fund_type` STRING COMMENT 'Classification of the private equity fund strategy: buyout, venture capital, growth equity, secondaries, fund-of-funds (FoF), or co-investment vehicle.. Valid values are `buyout|venture|growth|secondaries|fund_of_funds|co_investment`',
    `hard_cap` DECIMAL(18,2) COMMENT 'The maximum total capital commitment amount the fund is permitted to accept from LPs, as specified in the PPM or LPA.',
    `hurdle_rate` DECIMAL(5,4) COMMENT 'The minimum annualized Internal Rate of Return (IRR) that LPs must achieve before the GP is entitled to carried interest, expressed as a decimal percentage.',
    `identifier` STRING COMMENT 'External unique identifier or code assigned by the General Partner (GP) or administrator for the fund vehicle.',
    `inception_date` DATE COMMENT 'The date on which the fund was legally established or the Limited Partnership Agreement (LPA) was executed.',
    `investment_period_end_date` DATE COMMENT 'The date on which the funds investment period concludes, after which new investments are generally prohibited per LPA terms.',
    `investment_period_start_date` DATE COMMENT 'The date on which the funds investment period commenced, typically aligned with first close or final close per LPA terms.',
    `investment_strategy` STRING COMMENT 'Narrative description of the funds investment strategy, including target sectors, geographies, deal sizes, and value creation approach.',
    `is_evergreen` BOOLEAN COMMENT 'Indicates whether the fund is an evergreen (open-ended) structure with no fixed termination date, allowing continuous capital raising and redemptions.',
    `is_feeder_fund` BOOLEAN COMMENT 'Indicates whether this fund is a feeder vehicle that channels LP capital into a master fund structure.',
    `lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the fund vehicle, used for regulatory reporting and counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `management_fee_basis` STRING COMMENT 'The basis on which the management fee is calculated: committed capital (during investment period), invested capital (post-investment period), or Net Asset Value (NAV).. Valid values are `committed_capital|invested_capital|nav`',
    `management_fee_rate` DECIMAL(5,4) COMMENT 'The annual management fee rate charged by the GP, expressed as a decimal percentage of committed or invested capital per LPA terms.',
    `maximum_investment_size` DECIMAL(18,2) COMMENT 'The maximum equity check size for individual portfolio company investments, typically expressed as a percentage of total commitments or absolute amount.',
    `minimum_investment_size` DECIMAL(18,2) COMMENT 'The minimum equity check size for individual portfolio company investments, as specified in the funds investment guidelines.',
    `fund_name` STRING COMMENT 'The full legal name of the private equity fund as registered in the Limited Partnership Agreement (LPA).',
    `reporting_frequency` STRING COMMENT 'The frequency at which the fund provides formal performance and portfolio reports to Limited Partners (LPs).. Valid values are `monthly|quarterly|semi_annual|annual`',
    `sfdr_classification` STRING COMMENT 'EU SFDR classification: Article 6 (no sustainability focus), Article 8 (promotes ESG characteristics), or Article 9 (sustainable investment objective).. Valid values are `article_6|article_8|article_9`',
    `short_name` STRING COMMENT 'Abbreviated or common name used internally for reporting and operational reference.',
    `target_fund_size` DECIMAL(18,2) COMMENT 'The target total capital commitment amount the General Partner (GP) aims to raise from Limited Partners (LPs) during fundraising.',
    `target_geographies` STRING COMMENT 'Comma-separated list of target geographic regions or countries for fund investments (e.g., North America, Europe, Asia-Pacific).',
    `target_sectors` STRING COMMENT 'Comma-separated list of target industry sectors or verticals the fund focuses on for investment (e.g., technology, healthcare, industrials).',
    `term_years` BIGINT COMMENT 'The total contractual life of the fund in years as specified in the LPA, typically 10-12 years with extension options.',
    `termination_date` DATE COMMENT 'The actual or expected date on which the fund will be dissolved and all assets liquidated, including any extensions exercised.',
    `total_commitments` DECIMAL(18,2) COMMENT 'The aggregate capital commitment amount pledged by all Limited Partners (LPs) to the fund, representing total dry powder available for capital calls.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this fund record was last modified in the system.',
    `valuation_policy` STRING COMMENT 'Summary of the funds valuation methodology for portfolio company holdings, including frequency and approach (e.g., IPEV Guidelines, ASC 820 Fair Value).',
    `vintage_year` BIGINT COMMENT 'The year in which the fund held its first capital close and began investment operations. Critical for performance benchmarking and cohort analysis.',
    `waterfall_structure` STRING COMMENT 'The carried interest distribution methodology: European (whole-fund basis), American (deal-by-deal basis), or hybrid.. Valid values are `european|american|hybrid`',
    CONSTRAINT pk_fund PRIMARY KEY(`fund_id`)
) COMMENT 'Master record for each private equity fund vehicle in which the pension fund holds an LP interest or manages as a GP. Captures fund name, vintage year, fund type (buyout, venture, growth, secondaries, FoF, co-invest), target size, hard cap, fund currency';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`fund_commitment` (
    `fund_commitment_id` BIGINT COMMENT 'Unique identifier for the Limited Partner (LP) capital commitment record to a private equity fund.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the General Partner managing the fund.',
    `gp_gp_entity_id` BIGINT COMMENT 'Reference to the General Partner managing the fund.',
    `pe_fund_id` BIGINT COMMENT 'Reference to the private equity fund receiving the commitment.',
    `carried_interest_rate_percent` DECIMAL(5,4) COMMENT 'Performance fee percentage paid to the GP after the hurdle rate is achieved, typically 20% of profits above the hurdle.',
    `catch_up_rate_percent` DECIMAL(5,4) COMMENT 'Percentage of distributions allocated to the GP after the hurdle is met to bring their total carry to the target rate, typically 80%.',
    `commitment_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the commitment is denominated.. Valid values are `^[A-Z]{3}$`',
    `commitment_date` DATE COMMENT 'Date on which the pension fund executed the commitment to the private equity fund, typically the LPA signature date.',
    `commitment_number` STRING COMMENT 'External business identifier for the commitment, often referenced in Limited Partnership Agreement (LPA) and capital call notices.',
    `commitment_status` STRING COMMENT 'Current state of the commitment in its lifecycle from active through fully drawn or terminated.. Valid values are `active|fully_drawn|partially_drawn|terminated|suspended|defaulted`',
    `commitment_type` STRING COMMENT 'Classification of the commitment structure: primary fund commitment, secondary purchase, co-investment, or fund-of-funds.. Valid values are `primary|secondary|co_investment|fund_of_funds`',
    `committed_capital_amount` DECIMAL(18,2) COMMENT 'Total capital amount the pension fund committed to invest in the fund over its investment period, subject to capital calls.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this commitment record was first created in the data platform.',
    `dpi_multiple` DECIMAL(8,4) COMMENT 'Cash-on-cash return metric calculated as Total Distributions / Paid-In Capital, representing realized value.',
    `esg_classification` STRING COMMENT 'SFDR classification of the funds ESG integration: Article 6 (no ESG focus), Article 8 (promotes ESG), Article 9 (sustainable objective).. Valid values are `article_6|article_8|article_9`',
    `extension_options_count` BIGINT COMMENT 'Number of one-year extension periods available to the GP beyond the base fund term, typically requiring LP approval.',
    `final_close_date` DATE COMMENT 'Date of the funds final capital close, after which no additional LP commitments are accepted.',
    `first_close_date` DATE COMMENT 'Date of the funds initial capital close when the fund began operations and investment activity.',
    `fund_strategy` STRING COMMENT 'Primary investment strategy of the fund: buyout, growth equity, venture capital, distressed, real assets, or infrastructure.. Valid values are `buyout|growth_equity|venture_capital|distressed|real_assets|infrastructure`',
    `fund_term_years` BIGINT COMMENT 'Total duration of the fund from first close to final liquidation, typically 10-12 years with extension options per the LPA.',
    `geographic_focus` STRING COMMENT 'Primary geographic region or country focus of the funds investment mandate.',
    `hurdle_rate_percent` DECIMAL(5,4) COMMENT 'Minimum annualized return threshold that LPs must achieve before the GP earns carried interest, typically 8%.',
    `investment_period_end_date` DATE COMMENT 'Date when the funds investment period concludes, after which capital calls are typically limited to follow-on investments and fees.',
    `investment_period_start_date` DATE COMMENT 'Date when the fund begins its investment period during which capital calls for new investments are permitted per the LPA.',
    `irr_percent` DECIMAL(8,4) COMMENT 'Annualized time-weighted return on the commitment, calculated using cash flow timing and current NAV.',
    `key_person_clause_flag` BOOLEAN COMMENT 'Indicates whether the LPA includes key person provisions that suspend investment period if key investment professionals depart.',
    `last_capital_call_date` DATE COMMENT 'Date of the most recent capital call notice issued by the GP for this commitment.',
    `last_distribution_date` DATE COMMENT 'Date of the most recent distribution received from the fund.',
    `management_fee_rate_percent` DECIMAL(5,4) COMMENT 'Annual management fee rate charged by the GP, typically 1.5-2.0% of committed capital during investment period and NAV thereafter.',
    `modified_timestamp` TIMESTAMP COMMENT 'System timestamp when this commitment record was last updated in the data platform.',
    `moic_multiple` DECIMAL(8,4) COMMENT 'Gross return multiple calculated as (Distributions + NAV) / Paid-In Capital, synonymous with TVPI.',
    `most_favored_nation_flag` BOOLEAN COMMENT 'Indicates whether the commitment includes Most Favored Nation rights to receive terms granted to other LPs.',
    `nav_amount` DECIMAL(18,2) COMMENT 'Current fair value of the pension funds remaining investment in the fund, representing unrealized value.',
    `no_fault_divorce_flag` BOOLEAN COMMENT 'Indicates whether LPs have the right to remove the GP without cause under specified voting thresholds.',
    `ownership_percentage` DECIMAL(7,4) COMMENT 'Pension funds percentage ownership stake in the fund, calculated as commitment amount divided by total fund size.',
    `paid_in_capital_amount` DECIMAL(18,2) COMMENT 'Cumulative capital amount drawn down by the General Partner (GP) through capital calls to date.',
    `remaining_commitment_amount` DECIMAL(18,2) COMMENT 'Uncalled committed capital available for future capital calls, also known as dry powder.',
    `rvpi_multiple` DECIMAL(8,4) COMMENT 'Unrealized value metric calculated as NAV / Paid-In Capital, representing remaining investment value.',
    `sector_focus` STRING COMMENT 'Primary industry sector or sectors targeted by the funds investment strategy.',
    `side_letter_flag` BOOLEAN COMMENT 'Indicates whether a side letter agreement with special terms or rights exists for this commitment.',
    `target_fund_size_amount` DECIMAL(18,2) COMMENT 'Total capital the fund aims to raise from all Limited Partners (LPs), representing the funds target size.',
    `termination_date` DATE COMMENT 'Date on which the commitment was terminated or the fund was fully liquidated.',
    `total_distributions_amount` DECIMAL(18,2) COMMENT 'Cumulative distributions received from the fund to date, including return of capital and realized gains.',
    `tvpi_multiple` DECIMAL(8,4) COMMENT 'Performance metric calculated as (Distributions + NAV) / Paid-In Capital, representing total value creation.',
    `valuation_date` DATE COMMENT 'Date as of which the NAV, TVPI, DPI, RVPI, and IRR metrics were calculated, typically quarter-end.',
    `vintage_year` BIGINT COMMENT 'Calendar year in which the fund held its first close and began making investments, used for cohort performance benchmarking.',
    `waterfall_structure_type` STRING COMMENT 'Distribution waterfall methodology: American (deal-by-deal carry), European (whole-fund carry), or Hybrid.. Valid values are `american|european|hybrid`',
    CONSTRAINT pk_fund_commitment PRIMARY KEY(`fund_commitment_id`)
) COMMENT 'Records the pension funds LP capital commitment to a specific PE fund, including committed capital amount, commitment currency, commitment date, vintage year, commitment status (active, fully drawn, terminated), total paid-in capital (PIC), remaining';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`privateequity_capital_call` (
    `privateequity_capital_call_id` BIGINT COMMENT 'Unique identifier for the capital call record. Primary key for the capital call transaction.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the specific private equity deal or investment transaction for which capital is being called.',
    `fund_commitment_id` BIGINT COMMENT 'Reference to the Limited Partner (LP) commitment record against which this capital call is drawn.',
    `fund_id` BIGINT COMMENT 'Reference to the private equity fund issuing the capital call.',
    `gp_entity_id` BIGINT COMMENT 'Foreign key linking to privateequity.gp_entity. Business justification: Capital call records have denormalized GP contact fields (gp_contact_name, gp_contact_email, gp_contact_phone).',
    `opportunity_id` BIGINT COMMENT 'Reference to the specific private equity deal or investment transaction for which capital is being called.',
    `settlement_instruction_id` BIGINT COMMENT 'Reference to the treasury payment instruction record used to execute the capital call funding.',
    `portfolio_company_id` BIGINT COMMENT 'Reference to the portfolio company receiving the investment funded by this capital call.',
    `call_amount` DECIMAL(18,2) COMMENT 'Total amount requested from the Limited Partner (LP) in this capital call, denominated in call currency.',
    `call_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the capital call amount.. Valid values are `^[A-Z]{3}$`',
    `call_document_url` STRING COMMENT 'Link to the official capital call notice document stored in the document management system.',
    `call_due_date` DATE COMMENT 'Date by which the Limited Partner (LP) must fund the capital call amount to the fund.',
    `call_notice_date` DATE COMMENT 'Date on which the General Partner (GP) issued the capital call notice to Limited Partners (LPs).',
    `call_notice_number` STRING COMMENT 'Unique business identifier assigned by the General Partner (GP) to this capital call notice.',
    `call_purpose` STRING COMMENT 'Primary purpose for which the capital is being called by the General Partner (GP). [ENUM-REF-CANDIDATE: investment|management_fee|fund_expense|organizational_expense|bridge_financing|follow_on_investment|co_investment — 7 candidates stripped; promote to',
    `call_sequence_number` BIGINT COMMENT 'Sequential number of this capital call within the fund lifecycle, starting from 1 for the first drawdown.',
    `call_status` STRING COMMENT 'Current lifecycle status of the capital call from issuance through funding completion.. Valid values are `issued|acknowledged|funded|partially_funded|overdue|cancelled`',
    `call_type` STRING COMMENT 'Classification of the capital call based on urgency and timing characteristics.. Valid values are `regular|emergency|bridge|final`',
    `cancellation_reason` STRING COMMENT 'Narrative explanation for why the capital call was cancelled by the General Partner (GP).',
    `cancelled_date` DATE COMMENT 'Date on which the capital call was cancelled by the General Partner (GP).',
    `cancelled_flag` BOOLEAN COMMENT 'Indicates whether this capital call has been cancelled by the General Partner (GP) prior to funding.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this capital call record was first created in the system.',
    `default_interest_accrued` DECIMAL(18,2) COMMENT 'Total default interest accrued on unfunded or late capital call amounts.',
    `default_interest_rate` DECIMAL(5,4) COMMENT 'Annual interest rate applied to late or unfunded capital call amounts as specified in the Limited Partnership Agreement (LPA).',
    `excuse_approval_status` STRING COMMENT 'Status of the General Partner (GP) decision on the Limited Partner (LP) excuse request.. Valid values are `pending|approved|denied|not_applicable`',
    `excuse_request_flag` BOOLEAN COMMENT 'Indicates whether the Limited Partner (LP) has requested an excuse or deferral from funding this capital call.',
    `excuse_request_reason` STRING COMMENT 'Narrative explanation provided by the Limited Partner (LP) for requesting excuse or deferral from the capital call.',
    `fund_expense_amount` DECIMAL(18,2) COMMENT 'Portion of the capital call allocated to fund-level operating expenses such as legal, audit, and administrative costs.',
    `funded_amount` DECIMAL(18,2) COMMENT 'Actual amount funded by the Limited Partner (LP) in response to this capital call, may differ from call amount if partially funded.',
    `funded_date` DATE COMMENT 'Date on which the Limited Partner (LP) transferred funds to the fund in response to the capital call.',
    `investment_amount` DECIMAL(18,2) COMMENT 'Portion of the capital call allocated to direct investment activities, excluding fees and expenses.',
    `investment_description` STRING COMMENT 'Narrative description of the underlying investment or purpose for which capital is being called.',
    `lp_acknowledgement_date` DATE COMMENT 'Date on which the Limited Partner (LP) formally acknowledged the capital call notice.',
    `lp_acknowledgement_flag` BOOLEAN COMMENT 'Indicates whether the Limited Partner (LP) has formally acknowledged receipt of the capital call notice.',
    `management_fee_amount` DECIMAL(18,2) COMMENT 'Portion of the capital call allocated to General Partner (GP) management fees as per Limited Partnership Agreement (LPA).',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this capital call record was last modified in the system.',
    `notes` STRING COMMENT 'Additional free-text notes or comments related to this capital call for internal reference.',
    `notice_method` STRING COMMENT 'Method by which the General Partner (GP) delivered the capital call notice to the Limited Partner (LP).. Valid values are `email|postal_mail|electronic_portal|courier|fax`',
    `notice_received_date` DATE COMMENT 'Date on which the Limited Partner (LP) acknowledged receipt of the capital call notice.',
    `organizational_expense_amount` DECIMAL(18,2) COMMENT 'Portion of the capital call allocated to one-time fund formation and organizational expenses.',
    `payment_reference_number` STRING COMMENT 'Bank wire or payment system reference number for the capital call funding transaction.',
    `settlement_account_number` STRING COMMENT 'Bank account number to which the Limited Partner (LP) must transfer the capital call funds.',
    `settlement_bank_bic` STRING COMMENT 'Bank Identifier Code (BIC) or SWIFT code for the settlement bank receiving capital call funds.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `settlement_bank_name` STRING COMMENT 'Name of the bank holding the settlement account for capital call funding.',
    `unfunded_amount` DECIMAL(18,2) COMMENT 'Outstanding amount not yet funded by the Limited Partner (LP), calculated as call amount minus funded amount.',
    CONSTRAINT pk_privateequity_capital_call PRIMARY KEY(`privateequity_capital_call_id`)
) COMMENT 'Transactional record of each capital call (drawdown notice) issued by a GP to the pension fund as LP. Captures call notice date, due date, call amount, call currency, call sequence number, call purpose (investment, management fees, fund expenses';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`distribution` (
    `distribution_id` BIGINT COMMENT 'Unique identifier for the private equity fund distribution transaction.',
    `approved_by_user_employee_id` BIGINT COMMENT 'User identifier of the investment operations or treasury staff member who approved the distribution transaction.',
    `employee_id` BIGINT COMMENT 'User identifier of the investment operations or treasury staff member who approved the distribution transaction.',
    `fund_commitment_id` BIGINT COMMENT 'Foreign key linking to privateequity.fund_commitment. Business justification: Distributions are currently linked only at fund level. Adding fund_commitment_id enables LP-specific distribution tracking, which is essential for pension fund operations where',
    `fund_id` BIGINT COMMENT 'Reference to the private equity fund or co-investment vehicle making the distribution.',
    `gp_entity_id` BIGINT COMMENT 'Foreign key linking to privateequity.gp_entity. Business justification: Distribution records have denormalized GP entity data (gp_entity_name, gp_lei). Adding FK to gp_entity normalizes this relationship. GP entity details can be retrieved via JOIN.',
    `underlying_investment_id` BIGINT COMMENT 'Reference to the specific portfolio company or direct investment that generated the distribution.',
    `accounting_period` STRING COMMENT 'Fiscal period (quarter or month) in which the distribution is recognized for accounting and performance reporting purposes (format: YYYY-QN or YYYY-MM).. Valid values are `^d{4}-Q[1-4]$|^d{4}-d{2}$`',
    `amount` DECIMAL(18,2) COMMENT 'Gross distribution amount in the distribution currency before any withholding taxes or fees.',
    `amount_base_currency` DECIMAL(18,2) COMMENT 'Distribution amount converted to the pension funds base reporting currency using the effective date foreign exchange (FX) rate.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the distribution transaction was approved by the internal investment operations or treasury team.',
    `cumulative_distributions_to_date` DECIMAL(18,2) COMMENT 'Total cumulative distributions received by the Limited Partner (LP) from the fund inception through this distribution, used for Distributions to Paid-In (DPI) calculation.',
    `currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the distribution was denominated and paid.. Valid values are `^[A-Z]{3}$`',
    `custodian_reference_number` STRING COMMENT 'Unique transaction reference number assigned by the custodian bank for the distribution settlement.',
    `distribution_status` STRING COMMENT 'Current lifecycle status of the distribution transaction in the settlement and accounting workflow.. Valid values are `pending|confirmed|settled|cancelled|recalled`',
    `distribution_type` STRING COMMENT 'Classification of the distribution by its economic nature: return of capital, realized gain, dividend income, interest income, in-kind asset transfer, or recallable distribution subject to clawback.. Valid values are `return_of_capital|realized_gain|dividend|interest|in_kind|recallable`',
    `document_uri` STRING COMMENT 'Uniform Resource Identifier (URI) or file path to the distribution notice document stored in the document management system.',
    `dpi_ratio` DECIMAL(8,4) COMMENT 'Ratio of cumulative distributions to cumulative capital called, calculated as of this distribution date, measuring cash-on-cash return realized to date.',
    `effective_date` DATE COMMENT 'Date on which the distribution is effective for accounting and Net Asset Value (NAV) calculation purposes.',
    `fx_rate` DECIMAL(12,6) COMMENT 'Foreign exchange rate used to convert the distribution amount from distribution currency to base currency.',
    `in_kind_asset_description` STRING COMMENT 'Description of the asset transferred in-kind if the distribution type is in-kind (e.g., publicly traded shares, real estate, infrastructure asset).',
    `in_kind_asset_fair_value` DECIMAL(18,2) COMMENT 'Fair market value of the in-kind asset at the distribution effective date, used for accounting and Net Asset Value (NAV) purposes.',
    `in_kind_asset_quantity` DECIMAL(18,4) COMMENT 'Quantity or number of units of the in-kind asset transferred (e.g., number of shares, square meters of real estate).',
    `irr_contribution` DECIMAL(8,4) COMMENT 'Contribution of this distribution to the funds cumulative Internal Rate of Return (IRR) calculation, expressed as a percentage.',
    `lp_commitment_amount` DECIMAL(18,2) COMMENT 'Total capital commitment made by the Limited Partner (LP) to the fund, used to calculate distribution ratios and Distributions to Paid-In (DPI) metrics.',
    `memo` STRING COMMENT 'Free-text memo or commentary provided by the General Partner (GP) explaining the distribution context, source, and any special conditions.',
    `moic_contribution` DECIMAL(8,4) COMMENT 'Contribution of this distribution to the funds cumulative Multiple on Invested Capital (MOIC) calculation.',
    `nav_impact_amount` DECIMAL(18,2) COMMENT 'Impact of the distribution on the funds Net Asset Value (NAV) as of the effective date, typically a reduction equal to the distribution amount.',
    `net_distribution_amount` DECIMAL(18,2) COMMENT 'Net distribution amount received by the Limited Partner (LP) after withholding taxes and any applicable fees.',
    `notice_date` DATE COMMENT 'Date on which the General Partner (GP) issued the distribution notice to Limited Partners (LPs).',
    `notice_number` STRING COMMENT 'External reference number assigned by the General Partner (GP) to the distribution notice document.',
    `payment_date` DATE COMMENT 'Actual date on which the distribution cash or in-kind assets were received by the Limited Partner (LP).',
    `recallable_expiry_date` DATE COMMENT 'Date after which the distribution is no longer subject to clawback or recall provisions.',
    `recallable_flag` BOOLEAN COMMENT 'Indicates whether the distribution is subject to potential clawback or recall under the Limited Partnership Agreement (LPA) terms.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Date and time when the distribution record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Date and time when the distribution record was last modified in the system.',
    `settlement_account_number` STRING COMMENT 'Bank account number or custody account identifier to which the distribution was credited.',
    `settlement_bank_bic` STRING COMMENT 'Bank Identifier Code (BIC) or SWIFT code of the receiving bank for the distribution payment.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `source_event` STRING COMMENT 'Type of underlying transaction or event that triggered the distribution (e.g., exit, initial public offering, dividend, refinancing). [ENUM-REF-CANDIDATE: exit|ipo|dividend|interest|refinancing|partial_sale|recapitalization|liquidation — 8 candidates',
    `source_system_code` STRING COMMENT 'Unique identifier of the distribution transaction in the source operational system for data lineage and reconciliation.',
    `tax_jurisdiction` STRING COMMENT 'Three-letter ISO country code of the jurisdiction in which withholding tax was applied.. Valid values are `^[A-Z]{3}$`',
    `tax_treaty_applicable_flag` BOOLEAN COMMENT 'Indicates whether a bilateral tax treaty was applied to reduce the withholding tax rate on the distribution.',
    `vintage_year` BIGINT COMMENT 'Year in which the fund held its initial closing and began making capital calls, used for J-Curve analysis and performance benchmarking.',
    `withholding_tax_amount` DECIMAL(18,2) COMMENT 'Amount of withholding tax deducted at source by the fund jurisdiction or underlying investment jurisdiction.',
    `withholding_tax_rate` DECIMAL(5,4) COMMENT 'Percentage rate of withholding tax applied to the distribution, expressed as a decimal (e.g., 0.15 for 15%).',
    CONSTRAINT pk_distribution PRIMARY KEY(`distribution_id`)
) COMMENT 'Transactional record of each cash or in-kind distribution received from a PE fund. Captures distribution notice date, payment date, distribution amount, distribution currency, distribution type (return of capital, realized gain, dividend, in-kind)';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`investment` (
    `investment_id` BIGINT COMMENT 'Unique identifier for the investment data product (auto-inserted during validation).',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the origination deal record that led to this investment, linking to the deal pipeline and due diligence process.',
    `fund_id` BIGINT COMMENT 'Reference to the parent private equity fund or co-investment vehicle that holds this investment.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the General Partner (GP) or external manager entity managing this investment.',
    `investment_gp_entity_id` BIGINT COMMENT 'Reference to the General Partner (GP) or external manager entity managing this investment.',
    `investment_gp_gp_entity_id` BIGINT COMMENT 'FK to privateequity.gp_entity',
    `opportunity_id` BIGINT COMMENT 'Reference to the origination deal record that led to this investment, linking to the deal pipeline and due diligence process.',
    `portfolio_company_id` BIGINT COMMENT 'Reference to the underlying portfolio company or asset entity in which capital is invested.',
    `research_report_id` BIGINT COMMENT 'Foreign key linking to research.report. Business justification: Investment decisions are supported by specific research reports that justify the investment thesis.',
    `risk_model_id` BIGINT COMMENT 'Foreign key linking to risk.model. Business justification: Investment risk model FK needed for portfolio risk aggregation and performance attribution.',
    `asset_class` STRING COMMENT 'High-level asset class designation, typically private equity, but may include hybrid classifications for cross-asset investments.',
    `carried_interest_rate` DECIMAL(5,4) COMMENT 'Percentage of profits allocated to the General Partner (GP) as performance-based compensation, typically after the hurdle rate is achieved.',
    `commitment_amount` DECIMAL(18,2) COMMENT 'Total capital amount committed by the Limited Partner (LP) to the investment or fund, representing the maximum callable capital.',
    `commitment_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the commitment amount.. Valid values are `^[A-Z]{3}$`',
    `commitment_date` DATE COMMENT 'Date on which the Limited Partner (LP) formally committed capital to the investment or fund, establishing the legal obligation.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this investment record was first created in the system.',
    `distributions_received` DECIMAL(18,2) COMMENT 'Cumulative cash distributions returned to the Limited Partner (LP) from the investment, including realized gains and income.',
    `dpi` DECIMAL(10,4) COMMENT 'Multiple of cumulative distributions divided by paid-in capital, measuring realized cash-on-cash return.',
    `esg_integration_flag` BOOLEAN COMMENT 'Indicates whether ESG factors were formally integrated into the investment due diligence and decision-making process.',
    `esg_rating` STRING COMMENT 'ESG rating or score assigned to the investment, reflecting environmental, social, and governance performance and risk assessment.',
    `exit_date` DATE COMMENT 'Date on which the investment was fully exited or realized, marking the end of the holding period.',
    `final_close_date` DATE COMMENT 'Date of the final closing of the fund, after which no additional Limited Partners (LPs) may join and total commitments are finalized.',
    `first_close_date` DATE COMMENT 'Date of the first closing of the fund or investment vehicle, marking the initial capital commitment milestone.',
    `fund_size` DECIMAL(18,2) COMMENT 'Total capital raised by the fund at final close, representing the aggregate commitments from all Limited Partners (LPs).',
    `fund_term_years` BIGINT COMMENT 'Total term of the fund in years, including investment period and harvest period, as defined in the Limited Partnership Agreement (LPA).',
    `geography` STRING COMMENT 'Primary geographic region or country of the investment, using three-letter ISO country codes or regional groupings.',
    `hurdle_rate` DECIMAL(5,4) COMMENT 'Minimum annualized return threshold that must be achieved before the General Partner (GP) earns carried interest, expressed as a decimal percentage.',
    `investment_date` DATE COMMENT 'Date on which the investment was executed and capital was deployed into the portfolio company or fund.',
    `investment_status` STRING COMMENT 'Current lifecycle status of the investment: committed but not yet funded, actively held, partially or fully exited, or written off.. Valid values are `committed|funded|active|partially_exited|fully_exited|written_off`',
    `investment_type` STRING COMMENT 'Classification of the investment structure: direct investment, co-investment alongside a General Partner (GP), secondary market purchase, or fund-of-funds (FoF) commitment.. Valid values are `direct|co-investment|secondary|fund-of-funds|primary_fund|club_deal`',
    `irr` DECIMAL(10,4) COMMENT 'Annualized time-weighted rate of return on the investment, calculated using cash flows and Net Asset Value (NAV), expressed as a decimal.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this investment record was most recently modified.',
    `management_fee_rate` DECIMAL(5,4) COMMENT 'Annual management fee rate charged by the General Partner (GP), expressed as a decimal percentage of committed or invested capital.',
    `moic` DECIMAL(10,4) COMMENT 'Total value divided by paid-in capital, representing the gross multiple of capital returned and remaining, synonymous with Total Value to Paid-In (TVPI).',
    `investment_name` STRING COMMENT 'Business name or title of the private equity investment, typically the portfolio company name or fund name.',
    `nav` DECIMAL(18,2) COMMENT 'Current fair market value of the investment as of the most recent valuation date, representing unrealized value.',
    `nav_date` DATE COMMENT 'As-of date for the reported Net Asset Value (NAV), typically the end of the most recent reporting quarter.',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage equity ownership stake held in the portfolio company or fund, expressed as a decimal percentage.',
    `paid_in_capital` DECIMAL(18,2) COMMENT 'Cumulative capital called and paid by the Limited Partner (LP) to date, representing actual cash deployed into the investment.',
    `period_end_date` DATE COMMENT 'Date marking the end of the investment period during which the General Partner (GP) may make new investments, as defined in the Limited Partnership Agreement (LPA).',
    `rvpi` DECIMAL(10,4) COMMENT 'Multiple of current Net Asset Value (NAV) divided by paid-in capital, representing unrealized value remaining in the investment.',
    `sector` STRING COMMENT 'Primary industry sector of the portfolio company or investment focus area, aligned with GICS or internal sector taxonomy.',
    `strategy` STRING COMMENT 'Private equity strategy classification: buyout, growth equity, venture capital, distressed debt, mezzanine financing, or turnaround.. Valid values are `buyout|growth_equity|venture_capital|distressed|mezzanine|turnaround`',
    `sub_sector` STRING COMMENT 'Detailed sub-sector or industry vertical within the primary sector, providing granular classification for portfolio analysis.',
    `total_value` DECIMAL(18,2) COMMENT 'Sum of distributions received plus current Net Asset Value (NAV), representing the total realized and unrealized value of the investment.',
    `tvpi` DECIMAL(10,4) COMMENT 'Multiple of total value divided by paid-in capital, a key performance metric indicating total return on invested capital.',
    `unfunded_commitment` DECIMAL(18,2) COMMENT 'Remaining uncalled capital commitment available for future capital calls, also known as dry powder.',
    `valuation_method` STRING COMMENT 'Methodology used to determine the fair value of the investment, such as Discounted Cash Flow (DCF), comparable company analysis, or recent transaction price.',
    `vintage_year` BIGINT COMMENT 'The calendar year in which the fund was raised or the investment was first committed, used for cohort performance analysis and J-Curve modeling.',
    CONSTRAINT pk_investment PRIMARY KEY(`investment_id`)
) COMMENT 'Master record for each direct private equity investment or fund-level portfolio company investment. Captures investment name, investment type (direct, co-invest, secondary, FoF), asset class sub-type (buyout, growth equity, venture, distressed), entry';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`coinvestment` (
    `coinvestment_id` BIGINT COMMENT 'Unique identifier for the co-investment opportunity record. Primary key.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the origination deal pipeline record from which this co-investment opportunity emerged.',
    `gp_fund_id` BIGINT COMMENT 'Reference to the main GP fund vehicle alongside which this co-investment is being made.',
    `opportunity_id` BIGINT COMMENT 'Reference to the origination deal pipeline record from which this co-investment opportunity emerged.',
    `portfolio_company_id` BIGINT COMMENT 'Reference to the underlying portfolio company or asset being co-invested into.',
    `actual_exit_date` DATE COMMENT 'Actual date on which the co-investment position was fully exited and realized.',
    `asset_class` STRING COMMENT 'Primary asset class category of the co-investment for strategic asset allocation and portfolio construction purposes.. Valid values are `private_equity|venture_capital|growth_equity|buyout|infrastructure|real_estate`',
    `coinvestment_code` STRING COMMENT 'External business identifier or deal code used for reporting and communication with the GP and internal stakeholders.',
    `coinvestment_status` STRING COMMENT 'Current lifecycle status of the co-investment opportunity from initial pipeline through exit. [ENUM-REF-CANDIDATE: pipeline|due_diligence|ic_review|approved|committed|funded|active|exited|declined — 9 candidates stripped; promote to reference product]',
    `commitment_amount` DECIMAL(18,2) COMMENT 'Total capital commitment amount pledged by the pension fund for this co-investment opportunity in base currency.',
    `commitment_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the commitment amount.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this co-investment record was first created in the system.',
    `distributions_received` DECIMAL(18,2) COMMENT 'Cumulative cash distributions received from the co-investment to date in base currency.',
    `dpi` DECIMAL(10,4) COMMENT 'Cash-on-cash return multiple calculated as cumulative distributions divided by paid-in capital.',
    `entry_ebitda_multiple` DECIMAL(10,2) COMMENT 'Valuation multiple at entry calculated as enterprise value divided by trailing or forward EBITDA.',
    `entry_valuation` DECIMAL(18,2) COMMENT 'Enterprise value or equity valuation of the portfolio company at the time of initial investment in base currency.',
    `esg_integration_level` STRING COMMENT 'Degree to which ESG factors were integrated into the investment decision and ongoing monitoring.. Valid values are `full|partial|minimal|none`',
    `esg_rating` STRING COMMENT 'ESG risk rating or score assigned to the portfolio company based on due diligence assessment. [ENUM-REF-CANDIDATE: AAA|AA|A|BBB|BB|B|CCC|CC|C|not_rated — 10 candidates stripped; promote to reference product]',
    `exit_proceeds` DECIMAL(18,2) COMMENT 'Total cash proceeds realized from the exit of the co-investment in base currency.',
    `exit_type` STRING COMMENT 'Method or transaction type through which the co-investment was exited or is expected to be exited.. Valid values are `ipo|trade_sale|secondary_sale|recapitalization|write_off|partial_exit`',
    `expected_exit_date` DATE COMMENT 'Projected or target date for full exit from the co-investment position.',
    `expected_hold_period_years` BIGINT COMMENT 'Anticipated investment holding period in years from initial funding to expected exit.',
    `final_close_date` DATE COMMENT 'Date on which the co-investment commitment was finalized and legally binding.',
    `first_capital_call_date` DATE COMMENT 'Date of the initial capital call or drawdown notice for this co-investment.',
    `geography` STRING COMMENT 'Primary geographic region or country where the portfolio company operates or where the investment is domiciled.',
    `ic_approval_date` DATE COMMENT 'Date on which the Investment Committee formally approved the co-investment opportunity.',
    `ic_approval_reference` STRING COMMENT 'Reference number or identifier for the IC meeting minutes or resolution approving this co-investment.',
    `investment_structure` STRING COMMENT 'Capital structure layer or instrument type through which the co-investment is made.. Valid values are `common_equity|preferred_equity|convertible_debt|mezzanine|hybrid`',
    `investment_thesis` STRING COMMENT 'Summary of the strategic rationale and value creation hypothesis supporting the co-investment decision.',
    `investment_type` STRING COMMENT 'Classification of the co-investment structure indicating whether it is a direct co-invest, syndicated deal, club arrangement, or secondary transaction.. Valid values are `direct_coinvest|syndicated_coinvest|club_deal|secondary_coinvest`',
    `irr` DECIMAL(10,4) COMMENT 'Annualized time-weighted return percentage calculated from cash flows and current NAV, expressed as a decimal.',
    `lead_investment_professional` STRING COMMENT 'Name or identifier of the internal investment team member responsible for originating and managing this co-investment.',
    `modified_timestamp` TIMESTAMP COMMENT 'System timestamp when this co-investment record was last updated or modified.',
    `moic` DECIMAL(10,4) COMMENT 'Total return multiple calculated as total value divided by total invested capital, synonymous with TVPI in co-investment context.',
    `coinvestment_name` STRING COMMENT 'Business name or title of the co-investment opportunity, typically including the portfolio company name and vintage year.',
    `nav` DECIMAL(18,2) COMMENT 'Current fair market value of the co-investment position as of the latest valuation date in base currency.',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage ownership stake in the portfolio company acquired through this co-investment.',
    `paid_in_capital` DECIMAL(18,2) COMMENT 'Cumulative capital called and funded to date through capital calls or drawdown notices in base currency.',
    `realized_gain_loss` DECIMAL(18,2) COMMENT 'Net realized profit or loss from the co-investment calculated as exit proceeds minus paid-in capital in base currency.',
    `rvpi` DECIMAL(10,4) COMMENT 'Unrealized value multiple calculated as current NAV divided by paid-in capital.',
    `sector` STRING COMMENT 'Industry sector or vertical of the underlying portfolio company being co-invested into, aligned with GICS or internal taxonomy.',
    `target_irr` DECIMAL(10,4) COMMENT 'Underwritten or target IRR percentage established at investment approval, expressed as a decimal.',
    `target_moic` DECIMAL(10,4) COMMENT 'Underwritten or target MOIC multiple established at investment approval.',
    `tvpi` DECIMAL(10,4) COMMENT 'Performance multiple calculated as the sum of distributions and NAV divided by paid-in capital.',
    `unfunded_commitment` DECIMAL(18,2) COMMENT 'Remaining uncalled capital commitment available for future capital calls, also known as dry powder.',
    `valuation_date` DATE COMMENT 'As-of date for the most recent NAV valuation of the co-investment position.',
    `vintage_year` BIGINT COMMENT 'Calendar year in which the co-investment commitment was made, used for cohort analysis and J-Curve modeling.',
    CONSTRAINT pk_coinvestment PRIMARY KEY(`coinvestment_id`)
) COMMENT 'Master record for co-investment opportunities where the pension fund invests directly alongside a GP in a specific portfolio company, outside the main fund vehicle.';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`secondary_transaction` (
    `secondary_transaction_id` BIGINT COMMENT 'Unique identifier for the secondary market transaction of Limited Partner (LP) interests in private equity funds.',
    `counterparty_id` BIGINT COMMENT 'Identifier of the counterparty entity (buyer or seller) on the opposite side of this secondary transaction.',
    `fund_commitment_id` BIGINT COMMENT 'Foreign key linking to privateequity.fund_commitment. Business justification: Secondary transactions involve buying/selling LP interests which are tracked at the fund_commitment level.',
    `fund_id` BIGINT COMMENT 'Identifier of the private equity fund whose LP interest is being transacted in the secondary market.',
    `gp_entity_id` BIGINT COMMENT 'Foreign key linking to privateequity.gp_entity. Business justification: Secondary transactions have denormalized gp_name attribute. Adding FK to gp_entity normalizes this and allows proper tracking of which GP manages the fund being transacted.',
    `broker_fee_amount` DECIMAL(18,2) COMMENT 'Fee paid to the broker or intermediary for facilitating the secondary transaction.',
    `broker_intermediary_name` STRING COMMENT 'Name of the broker, advisor, or intermediary who facilitated the secondary transaction, if applicable.',
    `created_by_user` STRING COMMENT 'User identifier of the person who created this secondary transaction record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this secondary transaction record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this secondary transaction.. Valid values are `^[A-Z]{3}$`',
    `discount_premium_to_nav_percent` DECIMAL(8,4) COMMENT 'Percentage discount (negative) or premium (positive) of the transaction price relative to the NAV at transaction date, calculated as ((transaction_price - nav_at_transaction) / nav_at_transaction) * 100.',
    `dpi_at_transaction` DECIMAL(8,4) COMMENT 'Distributions to Paid-In Capital multiple of the LP interest at the time of the secondary transaction, representing realized returns.',
    `effective_date` DATE COMMENT 'Date from which the buyer assumes economic ownership of the LP interest, including rights to future distributions and obligations for future capital calls.',
    `face_value_commitment` DECIMAL(18,2) COMMENT 'Original committed capital amount of the LP interest being transacted, representing the full commitment value before any capital calls or distributions.',
    `fund_strategy` STRING COMMENT 'Investment strategy classification of the underlying private equity fund whose LP interest is being transacted.. Valid values are `buyout|venture_capital|growth_equity|distressed|mezzanine|secondary`',
    `gp_consent_date` DATE COMMENT 'Date on which General Partner consent was formally received for the secondary transaction.',
    `gp_consent_received_flag` BOOLEAN COMMENT 'Indicates whether General Partner consent was obtained for this secondary transaction if required.',
    `gp_consent_required_flag` BOOLEAN COMMENT 'Indicates whether General Partner consent was required for this secondary transaction per the Limited Partnership Agreement terms.',
    `investment_committee_approval_date` DATE COMMENT 'Date on which the Investment Committee formally approved the secondary transaction.',
    `investment_committee_memo_reference` STRING COMMENT 'Reference identifier for the Investment Committee memorandum documenting the rationale and approval for the secondary transaction.',
    `irr_at_transaction_percent` DECIMAL(8,4) COMMENT 'Internal Rate of Return of the LP interest calculated at the time of the secondary transaction, reflecting historical performance up to transaction date.',
    `last_modified_by_user` STRING COMMENT 'User identifier of the person who last modified this secondary transaction record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this secondary transaction record was last updated in the system.',
    `legal_advisor_name` STRING COMMENT 'Name of the legal advisor or law firm engaged to support the secondary transaction due diligence and documentation.',
    `legal_fee_amount` DECIMAL(18,2) COMMENT 'Legal fees incurred for the secondary transaction including due diligence, documentation review, and closing support.',
    `nav_at_transaction` DECIMAL(18,2) COMMENT 'Net Asset Value of the LP interest at the time of the secondary transaction, used as the baseline for discount or premium calculation.',
    `portfolio_allocation_strategy` STRING COMMENT 'Strategic rationale for the secondary transaction within the broader portfolio allocation framework (e.g., rebalancing, liquidity management, vintage diversification).',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this secondary transaction requires regulatory reporting to SEC, or other governing bodies.',
    `rvpi_at_transaction` DECIMAL(8,4) COMMENT 'Residual Value to Paid-In Capital multiple of the LP interest at the time of the secondary transaction, representing unrealized value.',
    `settlement_date` DATE COMMENT 'Date on which the secondary transaction settled, including transfer of LP interest and payment of consideration.',
    `total_transaction_costs` DECIMAL(18,2) COMMENT 'Aggregate of all costs incurred in executing the secondary transaction including broker fees, legal fees, and other transaction expenses.',
    `transaction_date` DATE COMMENT 'Date on which the secondary transaction was executed and agreed upon by both parties.',
    `transaction_notes` STRING COMMENT 'Free-text field capturing additional context, special terms, or conditions associated with the secondary transaction.',
    `transaction_price` DECIMAL(18,2) COMMENT 'Actual purchase or sale price paid for the LP interest in the secondary transaction.',
    `transaction_reference_number` STRING COMMENT 'External reference number or deal code assigned to this secondary transaction for tracking and reporting purposes.',
    `transaction_status` STRING COMMENT 'Current lifecycle status of the secondary transaction from initiation through settlement or cancellation.. Valid values are `pending|executed|settled|cancelled|failed`',
    `transaction_type` STRING COMMENT 'Indicates whether this is a purchase (buy) or sale (sell) of LP interests in the secondary market.. Valid values are `buy|sell`',
    `tvpi_at_transaction` DECIMAL(8,4) COMMENT 'Total Value to Paid-In Capital multiple of the LP interest at the time of the secondary transaction, calculated as (distributions + NAV) / paid-in capital.',
    `unfunded_commitment` DECIMAL(18,2) COMMENT 'Remaining uncalled capital commitment (dry powder) associated with the LP interest at the time of the secondary transaction.',
    `vintage_year` BIGINT COMMENT 'Year in which the underlying private equity fund held its initial closing and began making investments, critical for J-Curve analysis and performance benchmarking.',
    CONSTRAINT pk_secondary_transaction PRIMARY KEY(`secondary_transaction_id`)
) COMMENT 'Transactional record for secondary market purchases or sales of LP interests in PE funds. Captures transaction type (buy/sell), counterparty, fund interest being transacted, face value of commitment, purchase/sale price, discount or premium to NAV (%)';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`lpa_terms` (
    `lpa_terms_id` BIGINT COMMENT 'Unique identifier for the LPA terms record. Primary key for the LPA terms entity.',
    `fund_id` BIGINT COMMENT 'Reference to the private equity fund to which these LPA terms apply.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the General Partner legal entity managing the fund.',
    `advisory_committee_flag` BOOLEAN COMMENT 'Indicates whether the LPA establishes a Limited Partner Advisory Committee for governance and conflict resolution.',
    `amendment_number` BIGINT COMMENT 'Sequential number of amendments to the original LPA, starting at 0 for original and incrementing with each amendment.',
    `audit_requirement_flag` BOOLEAN COMMENT 'Indicates whether the LPA requires annual audited financial statements prepared by independent auditor.',
    `carried_interest_rate_pct` DECIMAL(5,4) COMMENT 'Percentage of profits allocated to the GP as performance incentive, typically 20% (carry).',
    `catch_up_rate_pct` DECIMAL(5,4) COMMENT 'Percentage of distributions allocated to GP after hurdle is met to catch up to target carry split, typically 80-100%.',
    `clawback_provision_flag` BOOLEAN COMMENT 'Indicates whether the LPA includes a clawback provision requiring GP to return excess carried interest at fund termination.',
    `co_investment_right_flag` BOOLEAN COMMENT 'Indicates whether LPs have the right to participate in co-investment opportunities alongside the fund.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this LPA terms record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the funds base currency (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `esg_policy_description` STRING COMMENT 'Textual description of ESG policies, exclusions, or responsible investment commitments specified in the LPA.',
    `esg_policy_flag` BOOLEAN COMMENT 'Indicates whether the LPA includes specific ESG investment policies or exclusions that the GP must follow.',
    `extension_option_years` BIGINT COMMENT 'Number of years by which the fund term may be extended at GP discretion, typically 1-2 one-year extensions.',
    `fund_domicile` STRING COMMENT 'Legal domicile or jurisdiction where the fund is established and registered.',
    `fund_term_years` BIGINT COMMENT 'Total duration of the fund in years as specified in the LPA, typically 10-12 years for private equity funds.',
    `geographic_restriction` STRING COMMENT 'Geographic investment mandate or restrictions specified in the LPA (e.g., North America, Europe, Global).',
    `governing_law_jurisdiction` STRING COMMENT 'Legal jurisdiction whose laws govern the interpretation and enforcement of the LPA (e.g., Delaware, Cayman Islands).',
    `gp_commitment_amount` DECIMAL(18,2) COMMENT 'Total capital amount committed by the GP to the fund, demonstrating alignment of interest with LPs.',
    `gp_commitment_pct` DECIMAL(5,4) COMMENT 'GP commitment expressed as percentage of total fund commitments, typically 1-5%.',
    `hurdle_rate_pct` DECIMAL(5,4) COMMENT 'Minimum annualized return threshold (preferred return) that LPs must achieve before GP receives carried interest, typically 8%.',
    `hurdle_type` STRING COMMENT 'Type of hurdle rate structure: hard (GP only receives carry on returns above hurdle), soft (GP receives catch-up), or none.. Valid values are `hard|soft|none`',
    `investment_concentration_limit_pct` DECIMAL(5,4) COMMENT 'Maximum percentage of fund capital that may be invested in a single portfolio company, typically 15-25%.',
    `investment_period_years` BIGINT COMMENT 'Duration in years during which the GP may make new investments, typically 3-5 years from fund inception.',
    `key_person_clause_flag` BOOLEAN COMMENT 'Indicates whether the LPA includes key person provisions that trigger restrictions if key investment professionals depart.',
    `key_person_names` STRING COMMENT 'Comma-separated list of key persons named in the LPA whose departure may trigger key person provisions.',
    `leverage_limit_multiple` DECIMAL(5,2) COMMENT 'Maximum debt-to-equity or debt-to-EBITDA multiple permitted for portfolio company investments.',
    `lpa_document_reference` STRING COMMENT 'External reference number or identifier for the signed LPA document in the document management system.',
    `lpa_effective_date` DATE COMMENT 'Date from which the LPA terms become effective and operational.',
    `lpa_execution_date` DATE COMMENT 'Date on which the LPA was executed and became legally binding.',
    `lpa_terms_status` STRING COMMENT 'Current lifecycle status of the LPA terms record: active, amended, superseded by new version, or terminated.. Valid values are `active|amended|superseded|terminated`',
    `management_fee_basis` STRING COMMENT 'Basis on which management fees are calculated: committed capital, invested capital, NAV, or hybrid structure.. Valid values are `committed_capital|invested_capital|nav|hybrid`',
    `management_fee_rate_pct` DECIMAL(5,4) COMMENT 'Annual management fee rate charged by the GP, expressed as a percentage. Typically 1.5-2.0% during investment period.',
    `management_fee_step_down_date` DATE COMMENT 'Date at which management fee rate or basis changes, typically at end of investment period.',
    `most_favored_nation_clause_flag` BOOLEAN COMMENT 'Indicates whether the LPA includes MFN provisions ensuring LPs receive terms no less favorable than other LPs.',
    `no_fault_divorce_clause_flag` BOOLEAN COMMENT 'Indicates whether LPs have the right to remove the GP without cause, typically requiring supermajority vote.',
    `post_investment_fee_rate_pct` DECIMAL(5,4) COMMENT 'Reduced management fee rate applicable after the investment period ends, typically 1.0-1.5%.',
    `recycling_limit_pct` DECIMAL(5,4) COMMENT 'Maximum percentage of distributions that may be recycled into new investments, typically 10-20% of commitments.',
    `recycling_provision_flag` BOOLEAN COMMENT 'Indicates whether the LPA permits recycling of early distributions back into new investments during investment period.',
    `removal_threshold_pct` DECIMAL(5,4) COMMENT 'Percentage of LP votes required to remove the GP, typically 66.67% or 75% supermajority.',
    `reporting_frequency` STRING COMMENT 'Frequency at which the GP must provide financial and portfolio reports to LPs as specified in the LPA.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `sector_restriction` STRING COMMENT 'Industry sector focus or restrictions specified in the LPA (e.g., technology, healthcare, industrials).',
    `transfer_restriction_type` STRING COMMENT 'Type of restriction on LP ability to transfer fund interests: prohibited, requires GP consent, ROFR, or free transfer.. Valid values are `prohibited|gp_consent|right_of_first_refusal|free_transfer`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this LPA terms record was last modified in the system.',
    `waterfall_structure` STRING COMMENT 'Distribution waterfall methodology: American (deal-by-deal), European (whole-fund), or hybrid structure.. Valid values are `american|european|hybrid`',
    CONSTRAINT pk_lpa_terms PRIMARY KEY(`lpa_terms_id`)
) COMMENT 'Structured record of the key economic and governance terms extracted from each Limited Partnership Agreement (LPA). Captures management fee rate, management fee basis (committed vs.';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` (
    `carried_interest_waterfall_id` BIGINT COMMENT 'Unique identifier for the carried interest waterfall calculation record. Primary key.',
    `pe_fund_id` BIGINT COMMENT 'Reference to the private equity fund for which this waterfall calculation applies.',
    `approval_date` DATE COMMENT 'Date on which this waterfall calculation was formally approved and finalized.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee who approved this waterfall calculation for finalization.',
    `calculation_date` DATE COMMENT 'The reporting period date or valuation date as of which this carried interest waterfall was calculated.',
    `calculation_method` STRING COMMENT 'Description of the specific calculation methodology or formula applied for this waterfall, including any LPA-specific nuances.',
    `calculation_notes` STRING COMMENT 'Free-text notes documenting assumptions, adjustments, or special circumstances affecting this waterfall calculation.',
    `calculation_status` STRING COMMENT 'Current lifecycle status of this waterfall calculation indicating whether it is draft, preliminary, final, revised, or superseded.. Valid values are `draft|preliminary|final|revised|superseded`',
    `carry_accrued_unpaid` DECIMAL(20,2) COMMENT 'Carried interest earned but not yet distributed to the GP, representing the accrued liability.',
    `carry_distributed` DECIMAL(20,2) COMMENT 'Cumulative carried interest amount actually distributed to the GP to date.',
    `carry_earned` DECIMAL(20,2) COMMENT 'Total carried interest earned by the GP based on the waterfall calculation as of the calculation date.',
    `carry_rate` DECIMAL(5,4) COMMENT 'The GP profit share percentage (e.g., 0.2000 for 20%) applied to profits after preferred return and catch-up are satisfied.',
    `clawback_provision_flag` BOOLEAN COMMENT 'Indicates whether the LPA includes a clawback provision requiring GP to return excess carry if final fund performance falls below hurdle.',
    `clawback_reserve` DECIMAL(20,2) COMMENT 'Amount reserved or withheld from GP distributions to cover potential clawback obligations at fund termination.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this waterfall calculation record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which all monetary amounts in this waterfall calculation are denominated.. Valid values are `^[A-Z]{3}$`',
    `dpi` DECIMAL(10,4) COMMENT 'Multiple representing cumulative distributions divided by paid-in capital, measuring realized returns.',
    `gp_catchup_amount` DECIMAL(20,2) COMMENT 'Cumulative amount distributed to GP during the catch-up phase after LPs receive return of capital and preferred return.',
    `gp_catchup_rate` DECIMAL(5,4) COMMENT 'The percentage of distributions allocated to GP during the catch-up phase to bring GP to its target carried interest share.',
    `gp_profit_share` DECIMAL(20,2) COMMENT 'Cumulative profit distributions allocated to GP including catch-up and carried interest.',
    `irr` DECIMAL(10,6) COMMENT 'The annualized effective compounded return rate of the fund, calculated using cash flows and NAV as of the calculation date.',
    `lp_profit_share` DECIMAL(20,2) COMMENT 'Cumulative profit distributions allocated to LPs after return of capital and preferred return, net of GP carry.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this waterfall calculation record was last modified or recalculated.',
    `nav` DECIMAL(20,2) COMMENT 'Current net asset value of the fund representing the fair value of remaining investments less liabilities.',
    `preferred_return_accrued` DECIMAL(20,2) COMMENT 'Cumulative preferred return amount accrued to LPs based on the hurdle rate applied to outstanding capital over time.',
    `preferred_return_paid` DECIMAL(20,2) COMMENT 'Cumulative preferred return amount distributed to LPs to date, satisfying the hurdle before GP catch-up.',
    `preferred_return_rate` DECIMAL(5,4) COMMENT 'The hurdle rate (expressed as decimal, e.g., 0.0800 for 8%) that LPs must achieve before GP participates in carried interest.',
    `return_of_capital` DECIMAL(20,2) COMMENT 'The portion of total distributions allocated to returning LP contributed capital before profit sharing begins.',
    `rvpi` DECIMAL(10,4) COMMENT 'Multiple representing remaining NAV divided by paid-in capital, measuring unrealized value.',
    `total_contributions` DECIMAL(20,2) COMMENT 'Cumulative capital contributions (Paid-In Capital / PIC) called from LPs to date for this fund.',
    `total_distributions` DECIMAL(20,2) COMMENT 'Cumulative distributions paid to LPs and GP from the fund to date, including return of capital and profits.',
    `tvpi` DECIMAL(10,4) COMMENT 'Multiple representing total value (distributions plus NAV) divided by paid-in capital, used to assess overall fund performance.',
    `waterfall_type` STRING COMMENT 'The carried interest distribution methodology: American (deal-by-deal), European (whole-fund), or hybrid structure as defined in the LPA.. Valid values are `american|european|hybrid`',
    CONSTRAINT pk_carried_interest_waterfall PRIMARY KEY(`carried_interest_waterfall_id`)
) COMMENT 'Transactional record tracking the carried interest waterfall calculation for each PE fund at each reporting period. Captures total fund distributions to date, return of capital tranche, preferred return accrual, GP catch-up amount, carried interest earned';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`nav` (
    `nav_id` BIGINT COMMENT 'Unique identifier for the nav data product (auto-inserted during validation).',
    `fund_commitment_id` BIGINT COMMENT 'Reference to the LP fund commitment or direct PE investment for which this NAV is reported.',
    `gp_report_id` BIGINT COMMENT 'Reference identifier for the source GP report document from which this NAV data was extracted.',
    `amount` DECIMAL(20,2) COMMENT 'The net asset value of the LP interest or direct investment as of the valuation date, representing fair value of the investment net of liabilities.',
    `audit_opinion` STRING COMMENT 'The auditors opinion on the funds financial statements, if this NAV is from an audited period.. Valid values are `unqualified|qualified|adverse|disclaimer`',
    `audited_flag` BOOLEAN COMMENT 'Indicates whether this NAV has been audited by an independent auditor as part of the funds annual audit process.',
    `auditor_name` STRING COMMENT 'The name of the independent auditor who audited the funds financial statements and NAV, if applicable.',
    `base_currency_amount` DECIMAL(20,2) COMMENT 'The NAV amount converted to the LPs base currency using the FX rate to base, for consolidated portfolio reporting.',
    `carried_interest_accrued` DECIMAL(20,2) COMMENT 'The cumulative carried interest accrued by the GP as of the valuation date, subject to hurdle rate and waterfall provisions.',
    `comments` STRING COMMENT 'Free-text field for additional notes, qualifications, or context regarding this NAV record, such as GP commentary or internal observations.',
    `data_source_system` STRING COMMENT 'The operational system from which this NAV record was sourced, such as eFront, Aladdin, or manual entry.',
    `distributions_received` DECIMAL(20,2) COMMENT 'The cumulative cash distributions received by the LP from the fund or investment to date.',
    `dpi` DECIMAL(10,4) COMMENT 'The ratio of distributions received to paid-in capital, representing the cash-on-cash return. Calculated as distributions divided by paid-in capital.',
    `fair_value_hierarchy_level` STRING COMMENT 'The IFRS 13 fair value hierarchy level classification for this NAV valuation, indicating the observability of inputs used.. Valid values are `level_1|level_2|level_3`',
    `fund_age_years` DECIMAL(6,2) COMMENT 'The number of years since the funds first closing or investment date, calculated as of the valuation date.',
    `fx_rate_to_base` DECIMAL(18,8) COMMENT 'The exchange rate used to convert the NAV reporting currency to the LPs base currency as of the valuation date.',
    `gav_amount` DECIMAL(20,2) COMMENT 'The gross asset value of the fund or investment before deducting liabilities, representing the total fair value of underlying assets.',
    `gp_report_received_date` DATE COMMENT 'The date on which the GP capital account statement or NAV report was received by the LP.',
    `irr_since_inception` DECIMAL(10,6) COMMENT 'The annualized internal rate of return from the first capital call to the valuation date, representing time-weighted performance.',
    `is_current_record` BOOLEAN COMMENT 'Flag indicating whether this is the current active version of the NAV record for the given fund commitment and valuation date.',
    `j_curve_phase` STRING COMMENT 'The current phase of the funds J-curve lifecycle, indicating whether it is in investment, harvesting, mature, or liquidation phase.. Valid values are `investment|harvesting|mature|liquidation`',
    `management_fee_accrued` DECIMAL(20,2) COMMENT 'The cumulative management fees accrued and charged to the LP capital account as of the valuation date.',
    `moic` DECIMAL(10,4) COMMENT 'The multiple of invested capital returned, equivalent to TVPI. Represents total value as a multiple of paid-in capital.',
    `nav_status` STRING COMMENT 'The status of this NAV record, indicating whether it is preliminary, final, audited, or has been adjusted or restated.. Valid values are `preliminary|final|audited|adjusted|restated`',
    `number_of_portfolio_companies` BIGINT COMMENT 'The count of active portfolio companies or investments held by the fund as of the valuation date.',
    `other_expenses_accrued` DECIMAL(20,2) COMMENT 'Other fund-level expenses accrued and allocated to the LP capital account, excluding management fees and carried interest.',
    `paid_in_capital` DECIMAL(20,2) COMMENT 'The cumulative capital called and funded by the LP to date, representing the total invested capital.',
    `realized_value` DECIMAL(20,2) COMMENT 'The cumulative proceeds from exits, sales, and distributions received to date from the investment.',
    `record_created_timestamp` TIMESTAMP COMMENT 'The timestamp when this NAV record was first created in the data platform.',
    `record_effective_from_date` DATE COMMENT 'The date from which this version of the NAV record is effective, supporting slowly changing dimension type 2 historization.',
    `record_effective_to_date` DATE COMMENT 'The date until which this version of the NAV record is effective, supporting slowly changing dimension type 2 historization. Null indicates current record.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this NAV record was last updated in the data platform.',
    `reporting_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the NAV is reported by the GP.. Valid values are `^[A-Z]{3}$`',
    `reporting_period_end_date` DATE COMMENT 'The end date of the reporting period covered by this NAV statement, aligning with GP reporting cycles.',
    `rvpi` DECIMAL(10,4) COMMENT 'The ratio of unrealized value to paid-in capital, representing the remaining value still held. Calculated as unrealized value divided by paid-in capital.',
    `total_commitment` DECIMAL(20,2) COMMENT 'The total capital commitment made by the LP to the fund or investment, representing the maximum callable amount.',
    `total_value` DECIMAL(20,2) COMMENT 'The sum of unrealized value and realized value, representing the total value generated by the investment to date.',
    `tvpi` DECIMAL(10,4) COMMENT 'The ratio of total value to paid-in capital, representing the multiple of invested capital generated. Calculated as total value divided by paid-in capital.',
    `unfunded_commitment` DECIMAL(20,2) COMMENT 'The remaining uncalled capital commitment, also known as dry powder, available for future capital calls.',
    `unrealized_value` DECIMAL(20,2) COMMENT 'The fair value of investments still held in the portfolio, not yet realized through exit or distribution.',
    `valuation_adjustment_amount` DECIMAL(20,2) COMMENT 'Any adjustment made to the GP-reported NAV by the LP for internal valuation policy, risk overlay, or fair value hierarchy alignment.',
    `valuation_adjustment_reason` STRING COMMENT 'Explanation for any valuation adjustment applied by the LP, documenting the rationale for deviation from GP-reported NAV.',
    `valuation_date` DATE COMMENT 'The as-of date for this NAV valuation, typically quarter-end or month-end as reported by the GP.',
    `valuation_method` STRING COMMENT 'The primary valuation methodology used by the GP to determine fair value for this reporting period.. Valid values are `market_comparable|dcf|transaction_price|cost|other`',
    `valuation_source` STRING COMMENT 'The source of the valuation, indicating whether it is GP-reported, independently valued, or internally estimated.. Valid values are `gp_reported|independent_valuation|internal_estimate|audited`',
    `vintage_year` BIGINT COMMENT 'The year in which the fund held its first closing or the direct investment was made, used for cohort analysis and J-curve modeling.',
    CONSTRAINT pk_nav PRIMARY KEY(`nav_id`)
) COMMENT 'Periodic NAV (Net Asset Value) record for each PE fund commitment and direct PE investment, capturing the GP-reported fair value, gross asset value (GAV), net asset value (NAV), unrealized value, realized value, total value (NAV + distributions), TVPI';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`jcurve_projection` (
    `jcurve_projection_id` BIGINT COMMENT 'Unique identifier for the J-Curve projection record. Primary key for this entity.',
    `approved_by_employee_id` BIGINT COMMENT 'Reference to the senior investment professional or Investment Committee (IC) member who approved this projection.',
    `employee_id` BIGINT COMMENT 'Reference to the analyst or investment professional who created or approved this projection.',
    `fund_commitment_id` BIGINT COMMENT 'Reference to the private equity fund commitment for which this J-Curve projection is modeled.',
    `jcurve_approved_by_employee_id` BIGINT COMMENT 'Reference to the senior investment professional or Investment Committee (IC) member who approved this projection.',
    `jcurve_employee_id` BIGINT COMMENT 'Reference to the analyst or investment professional who created or approved this projection.',
    `approval_date` DATE COMMENT 'The date on which this projection was formally approved for use in investment decision-making or reporting.',
    `assumed_carried_interest_rate` DECIMAL(6,4) COMMENT 'The carried interest (carry) rate assumed in this projection, expressed as a decimal (e.g., 0.20 for 20%).',
    `assumed_management_fee_rate` DECIMAL(6,4) COMMENT 'The annual management fee rate assumed in this projection, expressed as a decimal (e.g., 0.0150 for 1.50%).',
    `benchmark_cohort` STRING COMMENT 'The benchmark cohort or peer group used as a reference for this projection (e.g., Global Buyout 2020 Vintage, North America VC 2019-2021).',
    `breakeven_period_months` BIGINT COMMENT 'The number of months from fund inception until the cumulative distributions equal cumulative capital called, marking the J-Curve inflection point.',
    `capital_call_frequency` STRING COMMENT 'The expected frequency pattern of capital calls (drawdowns) in this projection: monthly, quarterly, semi-annual, annual, or irregular.. Valid values are `monthly|quarterly|semi_annual|annual|irregular`',
    `catch_up_provision` STRING COMMENT 'Description of the catch-up provision in the waterfall structure, if applicable (e.g., 100% catch-up until GP receives 20% of total profits).',
    `committed_capital_amount` DECIMAL(20,2) COMMENT 'The total capital amount committed by the Limited Partner (LP) to this fund, representing the maximum callable capital.',
    `committed_capital_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the committed capital amount (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this J-Curve projection record was first created in the system.',
    `distribution_frequency` STRING COMMENT 'The expected frequency pattern of distributions in this projection: monthly, quarterly, semi-annual, annual, or irregular.. Valid values are `monthly|quarterly|semi_annual|annual|irregular`',
    `fund_term_years` BIGINT COMMENT 'The total expected term of the fund in years, including investment period and harvest period.',
    `hurdle_rate` DECIMAL(6,4) COMMENT 'The preferred return threshold that must be achieved before carried interest is paid to the General Partner (GP), expressed as a decimal (e.g., 0.08 for 8%).',
    `investment_period_years` BIGINT COMMENT 'The number of years during which the General Partner (GP) can make new investments, typically 3-5 years.',
    `key_assumptions` STRING COMMENT 'Summary of key assumptions underlying this projection (e.g., exit multiples, holding periods, macroeconomic conditions, sector performance).',
    `model_run_date` DATE COMMENT 'The date on which this J-Curve projection model was executed and results were generated.',
    `model_version` STRING COMMENT 'Version identifier of the J-Curve projection model or tool used to generate this projection.',
    `notes` STRING COMMENT 'Free-text field for additional notes, commentary, or context regarding this J-Curve projection.',
    `peak_negative_nav_amount` DECIMAL(20,2) COMMENT 'The maximum negative NAV position expected during the J-Curve trough, representing the deepest point of unrealized loss.',
    `peak_negative_nav_period` BIGINT COMMENT 'The period number (in months or quarters) at which the peak negative NAV is expected to occur.',
    `projected_dpi` DECIMAL(10,4) COMMENT 'The projected Distributions to Paid-In multiple, calculated as Distributions / Capital Called, representing realized cash returns.',
    `projected_final_nav` DECIMAL(20,2) COMMENT 'The expected Net Asset Value (NAV) at the end of the projection period, representing unrealized value remaining.',
    `projected_gross_irr` DECIMAL(10,4) COMMENT 'The projected gross Internal Rate of Return before management fees and carried interest, expressed as a decimal (e.g., 0.15 for 15%).',
    `projected_moic` DECIMAL(10,4) COMMENT 'The projected Multiple on Invested Capital, representing the total value multiple expected from the investment.',
    `projected_net_irr` DECIMAL(10,4) COMMENT 'The projected net Internal Rate of Return after management fees and carried interest, expressed as a decimal (e.g., 0.12 for 12%).',
    `projected_rvpi` DECIMAL(10,4) COMMENT 'The projected Residual Value to Paid-In multiple, calculated as NAV / Capital Called, representing unrealized value remaining.',
    `projected_total_capital_called` DECIMAL(20,2) COMMENT 'The total amount of capital expected to be called (drawn down) over the life of the fund based on this projection scenario.',
    `projected_total_distributions` DECIMAL(20,2) COMMENT 'The total amount of distributions expected to be returned to the Limited Partner (LP) over the life of the fund.',
    `projected_tvpi` DECIMAL(10,4) COMMENT 'The projected Total Value to Paid-In multiple, calculated as (Distributions + NAV) / Capital Called, representing total value creation.',
    `projection_confidence_level` STRING COMMENT 'Qualitative assessment of confidence in this projection: high (based on strong data), medium (moderate uncertainty), or low (highly uncertain).. Valid values are `high|medium|low`',
    `projection_end_date` DATE COMMENT 'The date at which the J-Curve projection concludes, typically aligned with the expected fund liquidation date.',
    `projection_methodology` STRING COMMENT 'Description of the methodology used to generate this J-Curve projection (e.g., historical cohort analysis, GP-provided forecast, Monte Carlo simulation).',
    `projection_name` STRING COMMENT 'Business-friendly name or label for this J-Curve projection scenario (e.g., Base Case, Optimistic, Pessimistic).',
    `projection_start_date` DATE COMMENT 'The date from which the J-Curve projection begins, typically the fund commitment date or first capital call date.',
    `projection_status` STRING COMMENT 'Current lifecycle status of the J-Curve projection: draft, approved for use, active, superseded by newer version, or archived.. Valid values are `draft|approved|active|superseded|archived`',
    `projection_version` STRING COMMENT 'Version identifier for this projection, enabling tracking of revisions over time (e.g., v1.0, v2.1, Q1-2024).',
    `scenario_type` STRING COMMENT 'Classification of the projection scenario: base case, optimistic, pessimistic, stress test, or custom.. Valid values are `base_case|optimistic|pessimistic|stress|custom`',
    `sensitivity_analysis_performed` BOOLEAN COMMENT 'Indicates whether sensitivity analysis has been performed on this projection to test robustness under varying assumptions.',
    `stress_test_scenario` STRING COMMENT 'Description of the stress test scenario applied, if this is a stress projection (e.g., 2008 Financial Crisis, COVID-19 Pandemic, Recession).',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this J-Curve projection record was last modified in the system.',
    `vintage_year` BIGINT COMMENT 'The year in which the fund commitment was made, used for cohort analysis and benchmarking.',
    CONSTRAINT pk_jcurve_projection PRIMARY KEY(`jcurve_projection_id`)
) COMMENT 'Forward-looking J-Curve cash flow projection model for each PE fund commitment, capturing projected capital call schedule by period, projected distribution schedule by period, projected NAV trajectory, expected IRR at various exit scenarios, break-even';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`portfolio_company` (
    `portfolio_company_id` BIGINT COMMENT 'Unique identifier for the portfolio company record.',
    `country_outlook_id` BIGINT COMMENT 'Foreign key linking to research.country_outlook. Business justification: Country outlooks inform risk assessment and strategic decisions for portfolio companies.',
    `issuer_esg_rating_id` BIGINT COMMENT 'Foreign key linking to esg.issuer_esg_rating. Business justification: ESG rating of each portfolio company is required for investment decisions and reporting.',
    `board_representation` BOOLEAN COMMENT 'Indicates whether the pension fund holds a board seat or observer rights at the portfolio company.',
    `business_description` STRING COMMENT 'Detailed narrative describing the portfolio companys business model, operations, products, services, and competitive positioning.',
    `carbon_footprint_tonnes` DECIMAL(18,2) COMMENT 'Total greenhouse gas emissions attributable to the portfolio company, measured in tonnes of CO2 equivalent.',
    `co_investors` STRING COMMENT 'Comma-separated list of other institutional investors participating in the investment alongside the pension fund.',
    `company_name` STRING COMMENT 'Full legal name of the portfolio company as registered in its jurisdiction of incorporation.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the portfolio company record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code representing the base currency for all monetary amounts in this record.. Valid values are `^[A-Z]{3}$`',
    `current_fair_value` DECIMAL(18,2) COMMENT 'Most recent mark-to-market valuation of the pension funds stake in the portfolio company, in base currency.',
    `ebitda_latest` DECIMAL(18,2) COMMENT 'Most recent annual or trailing twelve-month EBITDA reported by the portfolio company, in base currency.',
    `employee_count` BIGINT COMMENT 'Total number of employees working for the portfolio company as of the most recent reporting date.',
    `enterprise_value` DECIMAL(18,2) COMMENT 'Total enterprise value of the portfolio company including equity and net debt, in base currency.',
    `esg_rating` STRING COMMENT 'ESG rating assigned to the portfolio company by an external rating agency or internal assessment framework. [ENUM-REF-CANDIDATE: AAA|AA|A|BBB|BB|B|CCC|CC|C — 9 candidates stripped; promote to reference product]',
    `esg_score` DECIMAL(5,2) COMMENT 'Numeric ESG score assigned to the portfolio company, typically on a 0-100 scale.',
    `exit_date` DATE COMMENT 'Date when the pension fund fully exited its position in the portfolio company, if applicable.',
    `exit_type` STRING COMMENT 'Method by which the pension fund exited the investment, if realized.. Valid values are `ipo|trade_sale|secondary_sale|recapitalization|write_off`',
    `financials_as_of_date` DATE COMMENT 'Date to which the latest revenue and EBITDA figures correspond.',
    `fund_name` STRING COMMENT 'Name of the private equity fund through which the portfolio company is held, if applicable.',
    `gics_industry_code` STRING COMMENT 'Six-digit GICS industry code providing detailed industry classification.. Valid values are `^[0-9]{6}$`',
    `gics_industry_group_code` STRING COMMENT 'Four-digit GICS industry group code providing sub-sector classification.. Valid values are `^[0-9]{4}$`',
    `gics_sector_code` STRING COMMENT 'Two-digit GICS sector code classifying the companys primary industry sector.. Valid values are `^[0-9]{2}$`',
    `gics_sub_industry_code` STRING COMMENT 'Eight-digit GICS sub-industry code providing the most granular industry classification.. Valid values are `^[0-9]{8}$`',
    `headquarters_city` STRING COMMENT 'City where the portfolio companys headquarters is located.',
    `headquarters_country` STRING COMMENT 'Three-letter ISO country code representing the location of the portfolio companys headquarters.. Valid values are `^[A-Z]{3}$`',
    `initial_investment_date` DATE COMMENT 'Date when the pension fund first invested in the portfolio company.',
    `investment_committee_approval_date` DATE COMMENT 'Date when the pension funds Investment Committee approved the initial investment in the portfolio company.',
    `investment_stage` STRING COMMENT 'Stage of the company at the time of investment indicating maturity and risk profile.. Valid values are `venture|growth|buyout|distressed|turnaround|expansion`',
    `investment_status` STRING COMMENT 'Current lifecycle status of the investment in the portfolio company.. Valid values are `active|realized|written_off|under_review|pending_exit`',
    `investment_thesis` STRING COMMENT 'Summary of the strategic rationale and value creation plan that justified the investment in the portfolio company.',
    `investment_type` STRING COMMENT 'Classification of how the portfolio company is held: direct investment, co-investment alongside a GP, through a fund, or via secondary transaction.. Valid values are `direct|co_investment|fund_investment|secondary`',
    `irr` DECIMAL(5,2) COMMENT 'Annualized internal rate of return on the investment in the portfolio company, expressed as a percentage.',
    `jurisdiction_of_incorporation` STRING COMMENT 'Three-letter ISO country code representing the legal jurisdiction where the company is incorporated.. Valid values are `^[A-Z]{3}$`',
    `key_risks` STRING COMMENT 'Summary of the principal risks identified during due diligence and ongoing monitoring of the portfolio company.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the portfolio company record was most recently modified.',
    `lead_investor` STRING COMMENT 'Name of the lead investor or General Partner (GP) in the deal, if applicable.',
    `lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier uniquely identifying the portfolio company globally.. Valid values are `^[A-Z0-9]{20}$`',
    `moic` DECIMAL(5,2) COMMENT 'Ratio of total value (distributions plus current fair value) to total invested capital, measuring investment return multiple.',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage of equity ownership held by the pension fund in the portfolio company, expressed as a decimal (e.g., 25.50 for 25.5%).',
    `revenue_latest` DECIMAL(18,2) COMMENT 'Most recent annual or trailing twelve-month revenue reported by the portfolio company, in base currency.',
    `total_distributions_received` DECIMAL(18,2) COMMENT 'Cumulative cash distributions received by the pension fund from the portfolio company, including dividends and exit proceeds, in base currency.',
    `total_invested_capital` DECIMAL(18,2) COMMENT 'Cumulative amount of capital invested by the pension fund in the portfolio company across all rounds and capital calls, in base currency.',
    `valuation_date` DATE COMMENT 'Date of the most recent fair value assessment for the portfolio company holding.',
    `vintage_year` BIGINT COMMENT 'Year in which the initial investment or fund commitment was made, used for cohort analysis and J-Curve modeling.',
    `website_url` STRING COMMENT 'Official website URL of the portfolio company.',
    CONSTRAINT pk_portfolio_company PRIMARY KEY(`portfolio_company_id`)
) COMMENT 'Master record for each portfolio company held directly or indirectly through PE fund investments. Captures company name, LEI, jurisdiction of incorporation, sector (GICS), sub-sector, business description, revenue (latest), EBITDA (latest), enterprise';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`gp_entity` (
    `gp_entity_id` BIGINT COMMENT 'Unique identifier for the General Partner entity record.',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Required for compliance reporting: each GP entity must be linked to a manager profile to track regulatory and performance attribution.',
    `active_fund_count` BIGINT COMMENT 'Number of funds in active investment period or still holding portfolio assets.',
    `aum_as_of_date` DATE COMMENT 'Date as of which the total AUM figure was reported or calculated.',
    `aum_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the reported AUM figure.. Valid values are `^[A-Z]{3}$`',
    `average_fund_irr` DECIMAL(8,4) COMMENT 'Average net IRR across all realized and partially realized funds managed by this GP, expressed as a decimal.',
    `average_fund_moic` DECIMAL(8,4) COMMENT 'Average MOIC across all realized and partially realized funds managed by this GP.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this GP entity record was first created in the system.',
    `domicile_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code where the GP entity is legally domiciled.. Valid values are `^[A-Z]{3}$`',
    `domicile_jurisdiction` STRING COMMENT 'Specific legal jurisdiction or state within the domicile country where the GP is registered.',
    `entity_type` STRING COMMENT 'Legal structure type of the General Partner entity.. Valid values are `limited_partnership|limited_liability_company|corporation|trust|other`',
    `esg_rating` STRING COMMENT 'ESG rating or score assigned to the General Partner by third-party rating agencies.',
    `fund_count` BIGINT COMMENT 'Total number of private equity funds currently managed by this General Partner.',
    `gp_entity_status` STRING COMMENT 'Current operational status of the General Partner entity in the pension funds records.. Valid values are `active|inactive|suspended|dissolved|under_review`',
    `headquarters_address` STRING COMMENT 'Full street address of the General Partners headquarters office.',
    `headquarters_city` STRING COMMENT 'City where the General Partners headquarters is located.',
    `headquarters_postal_code` STRING COMMENT 'Postal or ZIP code of the General Partners headquarters location.',
    `inception_date` DATE COMMENT 'Date when the General Partner entity was originally established or incorporated.',
    `investment_team_size` BIGINT COMMENT 'Total number of investment professionals employed by the General Partner.',
    `key_investment_professionals` STRING COMMENT 'Comma-separated list of key investment professionals and senior partners at the GP firm.',
    `kyc_completion_date` DATE COMMENT 'Date when the most recent KYC review was completed and approved.',
    `kyc_expiry_date` DATE COMMENT 'Date when the current KYC approval expires and requires renewal.',
    `kyc_status` STRING COMMENT 'Current status of the Know Your Customer due diligence process for this GP entity.. Valid values are `approved|pending|expired|rejected`',
    `legal_name` STRING COMMENT 'Full legal name of the General Partner entity as registered with regulatory authorities.',
    `lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier uniquely identifying the GP entity globally.. Valid values are `^[A-Z0-9]{20}$`',
    `ownership_structure` STRING COMMENT 'Classification of the General Partners ownership and organizational structure.. Valid values are `independent|captive|institutional_backed|publicly_traded|family_office`',
    `parent_organization` STRING COMMENT 'Name of the parent or holding company if the GP is part of a larger organization.',
    `pri_signatory` BOOLEAN COMMENT 'Indicates whether the GP is a signatory to the UN Principles for Responsible Investment.',
    `primary_contact_email` STRING COMMENT 'Email address of the primary contact person for Limited Partner communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_contact_name` STRING COMMENT 'Full name of the primary contact person at the General Partner for LP relations.',
    `primary_contact_phone` STRING COMMENT 'Telephone number of the primary contact person at the General Partner.',
    `primary_regulator` STRING COMMENT 'Name of the primary financial regulatory authority overseeing the General Partner.',
    `primary_strategy` STRING COMMENT 'Primary private equity investment strategy focus of the General Partner.. Valid values are `buyout|growth_equity|venture_capital|distressed|secondaries|fund_of_funds`',
    `registration_number` STRING COMMENT 'Official company registration or incorporation number issued by the domicile jurisdiction.',
    `regulatory_status` STRING COMMENT 'Current regulatory registration status of the GP with relevant financial authorities.. Valid values are `registered|exempt|pending|non_compliant`',
    `relationship_end_date` DATE COMMENT 'Date when the pension funds Limited Partner relationship with this GP ended, if applicable.',
    `relationship_start_date` DATE COMMENT 'Date when the pension fund first established a Limited Partner relationship with this GP.',
    `risk_rating` STRING COMMENT 'Internal risk rating assigned to the General Partner based on operational and counterparty risk assessment.. Valid values are `low|medium|high|very_high`',
    `secondary_strategy` STRING COMMENT 'Secondary or complementary investment strategy pursued by the General Partner, if applicable.',
    `short_name` STRING COMMENT 'Abbreviated or commonly used name for the General Partner entity.',
    `target_geographies` STRING COMMENT 'Comma-separated list of geographic regions or countries the GP focuses on for investments.',
    `target_sectors` STRING COMMENT 'Comma-separated list of industry sectors the GP typically targets for investment.',
    `total_aum` DECIMAL(20,2) COMMENT 'Total assets under management across all funds managed by this General Partner, in USD.',
    `total_employee_count` BIGINT COMMENT 'Total number of employees across all functions at the General Partner firm.',
    `track_record_summary` STRING COMMENT 'Narrative summary of the GPs historical performance track record and key achievements.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this GP entity record was last modified.',
    `website_url` STRING COMMENT 'Official website URL of the General Partner firm.',
    CONSTRAINT pk_gp_entity PRIMARY KEY(`gp_entity_id`)
) COMMENT 'Master record for each General Partner (GP) entity managing PE funds in which the pension fund is an LP. Captures GP legal name, LEI, domicile, AUM, fund count, strategy focus, key investment professionals, GP track record summary, GP ownership structure';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`lp_advisory_committee` (
    `lp_advisory_committee_id` BIGINT COMMENT 'Unique identifier for the LP Advisory Committee membership record.',
    `lp_entity_id` BIGINT COMMENT 'Foreign key linking to privateequity.lp_entity. Business justification: LPAC members are LP investors in the fund. The member_organization and member_organization_lei fields are denormalized LP entity data.',
    `pe_fund_id` BIGINT COMMENT 'Reference to the private equity fund for which this LPAC membership applies.',
    `alternate_member_name` STRING COMMENT 'Name of the designated alternate who may represent the member in their absence.',
    `appointment_authority` STRING COMMENT 'Name or title of the entity or individual who appointed the member to the advisory committee.',
    `appointment_date` DATE COMMENT 'Date on which the member was formally appointed to the LP Advisory Committee.',
    `committee_role` STRING COMMENT 'Specific leadership or functional role held by the member within the advisory committee structure.. Valid values are `chair|vice_chair|member|secretary`',
    `compensation_amount` DECIMAL(18,2) COMMENT 'Annual or per-meeting compensation paid to the member for advisory committee service, if applicable.',
    `compensation_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the compensation amount.. Valid values are `^[A-Z]{3}$`',
    `confidentiality_agreement_date` DATE COMMENT 'Date on which the member signed the confidentiality or non-disclosure agreement.',
    `confidentiality_agreement_signed` BOOLEAN COMMENT 'Indicates whether the member has executed the required confidentiality or non-disclosure agreement.',
    `conflict_disclosure_date` DATE COMMENT 'Date on which the member submitted their conflict of interest disclosure.',
    `conflict_of_interest_description` STRING COMMENT 'Detailed description of any disclosed conflicts of interest affecting the members advisory role.',
    `conflict_of_interest_disclosed` BOOLEAN COMMENT 'Indicates whether the member has disclosed any conflicts of interest as required by governance policies.',
    `contact_email` STRING COMMENT 'Primary email address for official LPAC communications with the member.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `contact_phone` STRING COMMENT 'Primary telephone number for official LPAC communications with the member.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this LPAC membership record was first created in the system.',
    `expense_reimbursement_eligible` BOOLEAN COMMENT 'Indicates whether the member is eligible for reimbursement of travel and meeting-related expenses.',
    `meeting_attendance_required` BOOLEAN COMMENT 'Indicates whether the member is required to attend LPAC meetings per governance terms.',
    `member_name` STRING COMMENT 'Full name of the individual representing the LP on the advisory committee.',
    `membership_status` STRING COMMENT 'Current status of the members participation on the advisory committee.. Valid values are `active|inactive|resigned|removed|term_expired`',
    `minimum_attendance_percentage` DECIMAL(5,2) COMMENT 'Minimum percentage of meetings the member must attend to maintain good standing, as defined in LPA.',
    `notes` STRING COMMENT 'Additional free-text notes or comments regarding the members advisory committee participation.',
    `removal_date` DATE COMMENT 'Date on which the member was removed from the advisory committee, if applicable.',
    `removal_reason` STRING COMMENT 'Explanation or justification for the members removal from the advisory committee.',
    `renewal_eligible` BOOLEAN COMMENT 'Indicates whether the member is eligible for term renewal upon expiration.',
    `representation_basis` STRING COMMENT 'Criterion or basis on which the member was selected to represent LPs on the advisory committee.. Valid values are `commitment_size|geographic|sector|founding_lp|rotating`',
    `resignation_date` DATE COMMENT 'Date on which the member formally resigned from the advisory committee, if applicable.',
    `seat_type` STRING COMMENT 'Classification of the committee seat indicating voting rights and participation level.. Valid values are `voting|observer|alternate|ex_officio`',
    `term_duration_years` DECIMAL(4,2) COMMENT 'Length of the committee term in years, typically defined in the LPA governance provisions.',
    `term_end_date` DATE COMMENT 'Scheduled expiration date of the members current term on the advisory committee.',
    `term_start_date` DATE COMMENT 'Effective start date of the members current term on the advisory committee.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this LPAC membership record was last modified in the system.',
    `voting_rights` BOOLEAN COMMENT 'Indicates whether the member holds voting rights on advisory committee matters.',
    `voting_weight` DECIMAL(5,4) COMMENT 'Proportional voting weight assigned to the member, typically expressed as a decimal fraction of total votes.',
    CONSTRAINT pk_lp_advisory_committee PRIMARY KEY(`lp_advisory_committee_id`)
) COMMENT 'Master record for LP Advisory Committee (LPAC) membership and governance for each PE fund. Captures fund reference, LPAC member name, member organization, seat type (voting, observer), appointment date, term expiry, conflict of interest disclosure status';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`capital_account` (
    `capital_account_id` BIGINT COMMENT 'Unique identifier for the LP capital account ledger record within a PE fund.',
    `fund_administrator_id` BIGINT COMMENT 'Reference to the fund administrator responsible for maintaining and reporting this capital account.',
    `employee_id` BIGINT COMMENT 'Reference to the fund administrator responsible for maintaining and reporting this capital account.',
    `lp_entity_id` BIGINT COMMENT 'Reference to the limited partner entity holding this capital account.',
    `pe_fund_id` BIGINT COMMENT 'Reference to the private equity fund in which this capital account exists.',
    `account_number` STRING COMMENT 'External account number assigned by the GP or fund administrator to this LP capital account.',
    `account_status` STRING COMMENT 'Current lifecycle status of the capital account.. Valid values are `active|suspended|closed|liquidated`',
    `carried_interest_allocation` DECIMAL(20,2) COMMENT 'Carried interest allocated to the GP from this LP capital account during the reporting period, subject to hurdle and waterfall provisions.',
    `catch_up_amount` DECIMAL(20,2) COMMENT 'Cumulative catch-up allocation to the GP after the preferred return threshold is met, per the LPA waterfall structure.',
    `clawback_obligation` DECIMAL(20,2) COMMENT 'Estimated clawback obligation owed by the LP to the fund if the fund were liquidated at current valuations, per waterfall calculations.',
    `closing_balance` DECIMAL(20,2) COMMENT 'Capital account balance at the end of the reporting period, calculated as opening balance plus contributions and income allocations minus distributions and expense allocations.',
    `commitment_amount` DECIMAL(20,2) COMMENT 'Total capital commitment made by the LP to the fund, representing the maximum callable capital.',
    `commitment_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the commitment amount.. Valid values are `^[A-Z]{3}$`',
    `contributions_in_period` DECIMAL(20,2) COMMENT 'Total capital called and contributed by the LP during the reporting period, including capital calls and recallable distributions.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this capital account record was first created in the system.',
    `cumulative_distributions` DECIMAL(20,2) COMMENT 'Total distributions paid to the LP since fund inception, including return of capital and profit distributions.',
    `distributions_in_period` DECIMAL(20,2) COMMENT 'Total distributions paid to the LP during the reporting period, including return of capital and profit distributions.',
    `dpi` DECIMAL(10,4) COMMENT 'Realization multiple calculated as cumulative distributions divided by paid-in capital, measuring cash returned to the LP.',
    `fx_rate_to_commitment_currency` DECIMAL(15,8) COMMENT 'Exchange rate applied to convert reporting currency amounts to commitment currency, if different.',
    `irr` DECIMAL(10,6) COMMENT 'Annualized internal rate of return for the LP capital account, calculated using cash flow timing and NAV.',
    `is_final_statement` BOOLEAN COMMENT 'Indicates whether this is the final capital account statement upon fund liquidation and closure.',
    `k1_issued_date` DATE COMMENT 'Date the Schedule K-1 tax form was issued to the LP for this capital account, applicable for US tax-reporting funds.',
    `management_fee_allocation` DECIMAL(20,2) COMMENT 'Management fees charged to the LP capital account during the reporting period per the LPA terms.',
    `nav` DECIMAL(20,2) COMMENT 'Current net asset value of the LP capital account, representing the fair value of the LPs residual interest in the fund.',
    `net_income_allocation` DECIMAL(20,2) COMMENT 'Net income or loss allocated to the LP capital account during the reporting period, reflecting the LPs share of fund performance.',
    `notes` STRING COMMENT 'Free-text notes or commentary from the GP or administrator regarding this capital account statement.',
    `opening_balance` DECIMAL(20,2) COMMENT 'Capital account balance at the beginning of the reporting period.',
    `other_expenses_allocation` DECIMAL(20,2) COMMENT 'Other fund-level expenses allocated to the LP capital account during the period, excluding management fees.',
    `ownership_percentage` DECIMAL(7,6) COMMENT 'LP ownership percentage in the fund, calculated as LP commitment divided by total fund commitments.',
    `paid_in_capital` DECIMAL(20,2) COMMENT 'Cumulative capital called and contributed by the LP since fund inception.',
    `period_end_date` DATE COMMENT 'End date of the reporting period for this capital account statement.',
    `period_start_date` DATE COMMENT 'Start date of the reporting period for this capital account statement.',
    `preferred_return_earned` DECIMAL(20,2) COMMENT 'Cumulative preferred return earned by the LP to date, calculated based on the hurdle rate and capital account balance over time.',
    `preferred_return_threshold` DECIMAL(20,2) COMMENT 'Cumulative preferred return amount that must be achieved before carried interest is allocated to the GP, per the LPA hurdle rate.',
    `recallable_distributions` DECIMAL(20,2) COMMENT 'Cumulative distributions subject to clawback provisions per the LPA, which may be recalled by the GP under certain conditions.',
    `reporting_currency` STRING COMMENT 'ISO 4217 three-letter currency code in which this capital account statement is reported.. Valid values are `^[A-Z]{3}$`',
    `rvpi` DECIMAL(10,4) COMMENT 'Unrealized multiple calculated as NAV divided by paid-in capital, measuring remaining value held in the fund.',
    `side_letter_terms` STRING COMMENT 'Summary of any side letter provisions or special terms applicable to this LP capital account that differ from the standard LPA.',
    `statement_date` DATE COMMENT 'Date the capital account statement was generated and issued to the LP.',
    `tax_basis` DECIMAL(20,2) COMMENT 'Tax basis of the LP capital account for tax reporting purposes, may differ from GAAP capital account balance.',
    `tvpi` DECIMAL(10,4) COMMENT 'Total value multiple calculated as the sum of cumulative distributions and NAV divided by paid-in capital, measuring total return.',
    `unfunded_commitment` DECIMAL(20,2) COMMENT 'Remaining uncalled capital commitment available for future capital calls, calculated as commitment amount minus paid-in capital.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this capital account record was last modified in the system.',
    `valuation_date` DATE COMMENT 'As-of date for the NAV and fair value measurements reported in this capital account statement.',
    CONSTRAINT pk_capital_account PRIMARY KEY(`capital_account_id`)
) COMMENT 'LP capital account ledger record tracking the pension funds running capital account balance within each PE fund. Captures opening balance, contributions in period, distributions in period, management fee allocations, carried interest allocations';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`management_fee_invoice` (
    `management_fee_invoice_id` BIGINT COMMENT 'Unique identifier for the management fee invoice record.',
    `fund_id` BIGINT COMMENT 'Reference to the PE fund commitment against which this management fee invoice was issued.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the GP entity that issued this management fee invoice.',
    `invoice_recipient_entity_id` BIGINT COMMENT 'Reference to the LP entity (pension fund) that received and is responsible for paying this invoice.',
    `approval_date` DATE COMMENT 'Date on which the invoice was approved for payment.',
    `approval_status` STRING COMMENT 'Internal approval status of the invoice before payment authorization.. Valid values are `pending_review|approved|rejected|escalated`',
    `approved_by` STRING COMMENT 'Name or identifier of the individual who approved the invoice for payment.',
    `calculation_methodology` STRING COMMENT 'Description of the methodology used to calculate the management fee for this period, including any special provisions or adjustments per the LPA.',
    `cost_center` STRING COMMENT 'Cost center or business unit to which this management fee is allocated.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this invoice record was first created in the data platform.',
    `currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the management fee is denominated.. Valid values are `^[A-Z]{3}$`',
    `dispute_date` DATE COMMENT 'Date on which the dispute was raised by the LP.',
    `dispute_flag` BOOLEAN COMMENT 'Indicates whether this invoice is under dispute by the LP.',
    `dispute_reason` STRING COMMENT 'Explanation of the reason for disputing this management fee invoice, if applicable.',
    `due_date` DATE COMMENT 'Date by which the net management fee amount is due for payment to the GP.',
    `fee_basis` STRING COMMENT 'The capital base on which the management fee rate is applied: committed capital, invested capital, Net Asset Value (NAV), cost basis, or hybrid structure.. Valid values are `committed_capital|invested_capital|nav|cost_basis|hybrid`',
    `fee_basis_amount` DECIMAL(20,2) COMMENT 'The capital amount (in fund currency) on which the management fee rate is applied for this period.',
    `fee_period_end_date` DATE COMMENT 'End date of the period for which the management fee is being charged.',
    `fee_period_start_date` DATE COMMENT 'Start date of the period for which the management fee is being charged.',
    `fee_rate` DECIMAL(6,4) COMMENT 'The annualized management fee rate applied to the fee basis, expressed as a decimal (e.g., 0.0200 for 2.00%).',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this management fee expense is posted.',
    `gross_fee_amount` DECIMAL(18,2) COMMENT 'The gross management fee amount calculated before any offsets or credits are applied.',
    `invoice_date` DATE COMMENT 'Date on which the GP issued the management fee invoice.',
    `invoice_document_uri` STRING COMMENT 'URI or file path to the original invoice document received from the GP.',
    `invoice_number` STRING COMMENT 'Unique invoice number assigned by the General Partner (GP) for this management fee billing.',
    `monitoring_fee_offset` DECIMAL(18,2) COMMENT 'Offset credit applied from monitoring fees received by the GP from portfolio companies, reducing the net management fee payable by the Limited Partner (LP).',
    `net_fee_amount` DECIMAL(18,2) COMMENT 'The net management fee amount payable by the LP after all offsets and credits have been applied.',
    `notes` STRING COMMENT 'Additional notes or comments related to this management fee invoice.',
    `other_fee_offset` DECIMAL(18,2) COMMENT 'Any other fee offsets or credits applied to reduce the net management fee payable by the LP.',
    `payment_date` DATE COMMENT 'Actual date on which the management fee payment was made to the GP.',
    `payment_reference` STRING COMMENT 'Reference number or transaction identifier for the payment made against this invoice.',
    `payment_status` STRING COMMENT 'Current payment status of the management fee invoice.. Valid values are `pending|paid|overdue|disputed|waived|cancelled`',
    `proration_factor` DECIMAL(6,4) COMMENT 'Factor applied to prorate the management fee for partial periods (e.g., 0.5000 for half-year), expressed as a decimal.',
    `resolution_date` DATE COMMENT 'Date on which the dispute was resolved.',
    `resolution_notes` STRING COMMENT 'Notes describing the outcome and resolution of the dispute.',
    `source_system_code` STRING COMMENT 'Unique identifier of this invoice record in the source operational system.',
    `total_fee_offset` DECIMAL(18,2) COMMENT 'Total of all fee offsets (monitoring, transaction, and other) applied to the gross management fee.',
    `transaction_fee_offset` DECIMAL(18,2) COMMENT 'Offset credit applied from transaction fees received by the GP from portfolio companies, reducing the net management fee payable by the LP.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this invoice record was last updated in the data platform.',
    CONSTRAINT pk_management_fee_invoice PRIMARY KEY(`management_fee_invoice_id`)
) COMMENT 'Transactional record for GP management fee invoices received against each PE fund commitment: invoice date, fee period, fee basis (committed/invested capital/NAV), fee rate applied, gross fee, fee offset credits (monitoring/transaction fees), net fee';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`privateequity_benchmark` (
    `privateequity_benchmark_id` BIGINT COMMENT 'Unique identifier for the privateequity_benchmark data product (auto-inserted during validation).',
    `equity_benchmark_id` BIGINT COMMENT 'Primary key for benchmark',
    `approved_for_reporting_flag` BOOLEAN COMMENT 'Indicates whether this benchmark has been approved by internal governance for use in official performance reporting to beneficiaries and regulators.',
    `asset_class` STRING COMMENT 'Primary asset class category that the benchmark covers.. Valid values are `Private Equity|Venture Capital|Buyout|Growth Equity|Mezzanine|Distressed`',
    `benchmark_code` STRING COMMENT 'Short code or ticker symbol identifying the benchmark.',
    `benchmark_description` STRING COMMENT 'Detailed textual description of the benchmark scope, methodology, inclusion criteria, and intended use cases.',
    `benchmark_name` STRING COMMENT 'Full name of the private equity benchmark used for performance comparison.',
    `benchmark_status` STRING COMMENT 'Current operational status of the benchmark indicating whether it is actively maintained and published.. Valid values are `Active|Discontinued|Under Review|Archived`',
    `benchmark_type` STRING COMMENT 'Methodology used to calculate benchmark returns. Pooled Internal Rate of Return (IRR), Horizon IRR, Public Market Equivalent (PME), modified PME, Kaplan-Schoar PME, or Direct Alpha.. Valid values are `Pooled IRR|Horizon IRR|PME|mPME|KS-PME|Direct Alpha`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this benchmark record was first created in the system.',
    `currency` STRING COMMENT 'ISO 4217 three-letter currency code in which benchmark returns are denominated.. Valid values are `^[A-Z]{3}$`',
    `data_lag_quarters` BIGINT COMMENT 'Number of quarters of reporting lag inherent in the benchmark data due to fund reporting cycles.',
    `data_quality_rating` STRING COMMENT 'Internal assessment of the benchmark data quality based on completeness, accuracy, and timeliness.. Valid values are `High|Medium|Low`',
    `data_source_url` STRING COMMENT 'Web address or reference link to the providers official benchmark documentation and data access portal.',
    `effective_date` DATE COMMENT 'Date from which this benchmark record is effective and valid for use in performance comparisons.',
    `exclusion_criteria` STRING COMMENT 'Specific criteria that disqualify funds from inclusion in the benchmark, such as non-standard fee structures or incomplete reporting.',
    `expiration_date` DATE COMMENT 'Date after which this benchmark record is no longer valid or has been superseded by a newer version.',
    `family` STRING COMMENT 'Name of the broader benchmark family or suite to which this benchmark belongs, enabling grouping of related benchmarks.',
    `fund_size_category` STRING COMMENT 'Size classification of funds included in the benchmark, such as Small (<$500M), Mid ($500M-$2B), Large (>$2B), or All Sizes.',
    `geographic_scope` STRING COMMENT 'Geographic coverage of the benchmark using ISO 3166-1 alpha-3 country codes or regional identifiers (e.g., USA, GBR, Global, North America, Europe, Asia-Pacific).',
    `inception_date` DATE COMMENT 'Date when the benchmark was first established or when data collection began.',
    `inclusion_criteria` STRING COMMENT 'Specific criteria that funds must meet to be included in the benchmark universe, such as minimum fund size, reporting standards, or geographic domicile.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this benchmark record was most recently modified or updated.',
    `last_update_date` DATE COMMENT 'Date when the benchmark data was most recently updated by the provider.',
    `license_type` STRING COMMENT 'Type of data license governing the use and distribution of benchmark data within the organization.. Valid values are `Subscription|One-Time Purchase|Internal Use|Redistribution Allowed`',
    `net_or_gross` STRING COMMENT 'Indicates whether benchmark returns are net of fees (Net) or gross of fees (Gross).. Valid values are `Net|Gross`',
    `notes` STRING COMMENT 'Additional free-text notes, comments, or special considerations related to the benchmark usage or interpretation.',
    `number_of_funds` BIGINT COMMENT 'Count of individual funds included in the benchmark calculation, indicating sample size and statistical robustness.',
    `primary_use_case` STRING COMMENT 'Primary business purpose for which this benchmark is used, such as performance attribution, manager selection, or portfolio construction.',
    `provider_name` STRING COMMENT 'Organization that publishes and maintains the benchmark data. [ENUM-REF-CANDIDATE: Cambridge Associates|Preqin|Burgiss|MSCI|PitchBook|State Street|Custom — 7 candidates stripped; promote to reference product]',
    `public_market_index` STRING COMMENT 'Name of the public market index used for Public Market Equivalent (PME) calculations, such as S&P 500, MSCI World, or Russell 2000.',
    `quartile_available_flag` BOOLEAN COMMENT 'Indicates whether quartile breakdowns (top quartile, median, bottom quartile) are available for this benchmark.',
    `restatement_flag` BOOLEAN COMMENT 'Indicates whether historical benchmark data has been restated or revised by the provider.',
    `return_calculation_method` STRING COMMENT 'Detailed methodology for calculating returns, including cash flow timing assumptions, valuation frequency, and aggregation approach.',
    `sector_focus` STRING COMMENT 'Industry sector or sectors covered by the benchmark, such as Technology, Healthcare, Industrials, or All Sectors.',
    `strategy_focus` STRING COMMENT 'Investment strategy or sub-strategy focus of the benchmark, such as early-stage venture, mega-buyout, or sector-specific strategies.',
    `survivorship_bias_adjusted_flag` BOOLEAN COMMENT 'Indicates whether the benchmark has been adjusted to account for survivorship bias by including defunct or liquidated funds.',
    `update_frequency` STRING COMMENT 'Frequency at which the benchmark provider publishes updated performance data.. Valid values are `Quarterly|Semi-Annual|Annual|Monthly`',
    `usage_restrictions` STRING COMMENT 'Any contractual or regulatory restrictions on how the benchmark data may be used, shared, or published.',
    `version_number` STRING COMMENT 'Version identifier for the benchmark methodology or data series, enabling tracking of changes over time.',
    `vintage_year` BIGINT COMMENT 'The fund commitment year that this benchmark represents. Used to compare funds of the same vintage cohort.',
    `weighting_methodology` STRING COMMENT 'Method used to weight individual fund contributions to the benchmark, such as equal-weighted, capital-weighted, or commitment-weighted.',
    CONSTRAINT pk_privateequity_benchmark PRIMARY KEY(`privateequity_benchmark_id`)
) COMMENT 'Reference data for PE performance benchmarks used to evaluate fund and portfolio performance. Captures benchmark name, benchmark provider (Cambridge Associates, Preqin, Burgiss, MSCI), benchmark type (pooled IRR, horizon IRR, PME), asset class scope';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` (
    `fund_of_funds_allocation_id` BIGINT COMMENT 'Unique identifier for the fund-of-funds allocation record.',
    `fof_vehicle_id` BIGINT COMMENT 'Reference to the fund-of-funds vehicle entity that this allocation represents.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the external manager entity responsible for managing the FoF vehicle.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external manager entity responsible for managing the FoF vehicle.',
    `underlying_pe_fund_id` BIGINT COMMENT 'Reference to the underlying PE fund that the FoF vehicle allocates capital to.',
    `allocation_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the allocation commitment and cash flows.. Valid values are `^[A-Z]{3}$`',
    `allocation_date` DATE COMMENT 'Date when the FoF vehicle committed or allocated capital to the underlying PE fund.',
    `allocation_number` STRING COMMENT 'Business identifier for the FoF allocation, used for operational tracking and reporting.',
    `allocation_status` STRING COMMENT 'Current lifecycle status of the FoF allocation to the underlying fund.. Valid values are `committed|funded|active|realized|terminated|suspended`',
    `allocation_type` STRING COMMENT 'Classification of the FoF allocation strategy: primary fund commitment, secondary market purchase, or co-investment alongside the FoF.. Valid values are `primary|secondary|co_investment`',
    `carried_interest_rate_percent` DECIMAL(5,4) COMMENT 'Performance fee rate (carry) earned by the FoF manager on profits above the hurdle rate, expressed as a percentage.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this allocation record was first created in the system.',
    `dpi_multiple` DECIMAL(8,4) COMMENT 'Realization multiple calculated as cumulative distributions divided by paid-in capital, measuring cash-on-cash return.',
    `esg_classification` STRING COMMENT 'ESG classification or rating of the underlying PE fund, reflecting its responsible investment approach and sustainability integration.',
    `final_close_date` DATE COMMENT 'Date of the underlying PE funds final capital close, after which no new commitments are accepted.',
    `first_close_date` DATE COMMENT 'Date of the underlying PE funds first capital close, marking the beginning of the investment period.',
    `fof_total_commitment_amount` DECIMAL(18,2) COMMENT 'Total capital commitment made by the FoF vehicle to the underlying PE fund.',
    `fund_term_years` BIGINT COMMENT 'Total term of the underlying PE fund in years, including any extension options, as defined in the Limited Partnership Agreement (LPA).',
    `geographic_focus` STRING COMMENT 'Primary geographic regions or countries targeted by the underlying PE fund for investment.',
    `hurdle_rate_percent` DECIMAL(5,4) COMMENT 'Minimum annualized return threshold that must be achieved before the FoF manager earns carried interest.',
    `investment_period_end_date` DATE COMMENT 'Date when the underlying PE funds investment period concludes, after which new investments are typically restricted.',
    `investment_strategy` STRING COMMENT 'Description of the underlying PE funds investment strategy that the FoF vehicle is allocating to (e.g., buyout, growth equity, venture capital).',
    `irr_percent` DECIMAL(8,4) COMMENT 'Annualized internal rate of return for the FoF allocation, calculated using cash flow timing and current NAV.',
    `key_person_clause_flag` BOOLEAN COMMENT 'Indicates whether a key person provision exists that suspends investment activity if specified key investment professionals leave the FoF manager.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this allocation record was most recently modified.',
    `management_fee_rate_percent` DECIMAL(5,4) COMMENT 'Annual management fee rate charged by the FoF manager, expressed as a percentage of committed or invested capital.',
    `moic_multiple` DECIMAL(8,4) COMMENT 'Gross return multiple calculated as total value divided by invested capital, measuring overall investment performance.',
    `most_favored_nation_flag` BOOLEAN COMMENT 'Indicates whether the pension fund has most favored nation rights, ensuring it receives terms at least as favorable as any other LP.',
    `nav_amount` DECIMAL(18,2) COMMENT 'Current fair market value of the FoF vehicles interest in the underlying PE fund, representing unrealized value.',
    `notes` STRING COMMENT 'Free-text field for additional commentary, special terms, or operational notes related to the FoF allocation.',
    `paid_in_capital_amount` DECIMAL(18,2) COMMENT 'Cumulative capital called and funded by the FoF vehicle to the underlying PE fund as of the reporting date.',
    `pension_lp_interest_amount` DECIMAL(18,2) COMMENT 'The pension funds proportional capital commitment within the FoF vehicle, representing its LP interest in the FoF.',
    `pension_lp_ownership_percentage` DECIMAL(5,2) COMMENT 'The pension funds ownership percentage in the FoF vehicle, calculated as pension LP interest divided by total FoF commitments.',
    `remaining_commitment_amount` DECIMAL(18,2) COMMENT 'Uncalled committed capital available for future drawdowns by the underlying PE fund, also known as dry powder.',
    `reporting_currency` STRING COMMENT 'Three-letter ISO 4217 currency code used for consolidated reporting and performance measurement of this allocation.. Valid values are `^[A-Z]{3}$`',
    `rvpi_multiple` DECIMAL(8,4) COMMENT 'Unrealized value multiple calculated as NAV divided by paid-in capital, measuring remaining investment value.',
    `sector_focus` STRING COMMENT 'Primary industry sectors or verticals targeted by the underlying PE fund for investment.',
    `side_letter_flag` BOOLEAN COMMENT 'Indicates whether the pension fund has negotiated a side letter with the FoF manager granting special rights or terms.',
    `termination_date` DATE COMMENT 'Expected or actual date when the underlying PE fund will be dissolved and all assets liquidated.',
    `total_distributions_amount` DECIMAL(18,2) COMMENT 'Cumulative distributions received by the FoF vehicle from the underlying PE fund, including realized proceeds and income.',
    `tvpi_multiple` DECIMAL(8,4) COMMENT 'Total value multiple calculated as (distributions plus NAV) divided by paid-in capital, measuring total return on invested capital.',
    `valuation_date` DATE COMMENT 'As-of date for the most recent NAV valuation and performance metrics reported for this allocation.',
    `vintage_year` BIGINT COMMENT 'Year in which the underlying PE fund held its first close and began investing, used for cohort analysis and benchmarking.',
    `waterfall_structure` STRING COMMENT 'Distribution waterfall methodology defining how profits are allocated between LPs and the GP (European, American, or deal-by-deal).. Valid values are `european|american|deal_by_deal`',
    CONSTRAINT pk_fund_of_funds_allocation PRIMARY KEY(`fund_of_funds_allocation_id`)
) COMMENT 'Master record for Fund-of-Funds (FoF) allocations where the pension fund invests in a FoF vehicle that in turn allocates to underlying PE funds. Captures FoF vehicle name, FoF manager, total FoF commitment, the pension funds LP interest in the FoF';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` (
    `privateequity_cash_flow_id` BIGINT COMMENT 'Primary key for cash_flow',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the specific investment deal or transaction that triggered this cash flow, if applicable.',
    `fund_commitment_id` BIGINT COMMENT 'Reference to the fund commitment record associated with this cash flow.',
    `fund_id` BIGINT COMMENT 'Reference to the private equity fund associated with this cash flow.',
    `gp_entity_id` BIGINT COMMENT 'Foreign key linking to privateequity.gp_entity. Business justification: Cash flow records have denormalized GP contact fields (gp_contact_name, gp_contact_email, gp_contact_phone).',
    `opportunity_id` BIGINT COMMENT 'Reference to the specific investment deal or transaction that triggered this cash flow, if applicable.',
    `portfolio_company_id` BIGINT COMMENT 'Reference to the portfolio company associated with this cash flow, if applicable.',
    `base_currency_amount` DECIMAL(18,2) COMMENT 'The cash flow amount converted to the funds base reporting currency.',
    `carried_interest_amount` DECIMAL(18,2) COMMENT 'The portion of the distribution representing carried interest or performance allocation to the general partner.',
    `cash_flow_status` STRING COMMENT 'Current lifecycle status of the cash flow transaction.. Valid values are `pending|settled|cancelled|defaulted|partially_settled`',
    `cash_flow_type` STRING COMMENT 'Classification of the cash flow transaction indicating the nature of the movement. [ENUM-REF-CANDIDATE: capital_call|distribution|management_fee|fund_expense|organizational_expense|recallable_distribution|carried_interest|preferred_return — 8 candidates',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this cash flow record was first created in the system.',
    `currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the cash flow transaction.. Valid values are `^[A-Z]{3}$`',
    `default_interest_accrued` DECIMAL(18,2) COMMENT 'The cumulative amount of default interest accrued on late or unpaid capital call amounts.',
    `default_interest_rate` DECIMAL(5,4) COMMENT 'The annual interest rate applied to late or defaulted capital call payments, expressed as a decimal.',
    `document_url` STRING COMMENT 'The URL or file path to the official cash flow notice document or supporting documentation.',
    `due_date` DATE COMMENT 'The date by which the cash flow payment is due, applicable primarily to capital calls.',
    `effective_date` DATE COMMENT 'The date from which the cash flow is effective for performance and valuation calculations.',
    `excuse_approval_status` STRING COMMENT 'The status of the limited partners excuse request as determined by the general partner.. Valid values are `pending|approved|denied|not_applicable`',
    `excuse_request_flag` BOOLEAN COMMENT 'Indicates whether the limited partner has requested to be excused from participating in this cash flow transaction.',
    `excuse_request_reason` STRING COMMENT 'The business or legal reason provided by the limited partner for requesting to be excused from the cash flow.',
    `fund_expense_amount` DECIMAL(18,2) COMMENT 'The portion of the cash flow representing fund-level operating expenses.',
    `fx_rate` DECIMAL(12,6) COMMENT 'The foreign exchange rate used to convert the transaction currency to the base currency.',
    `gross_amount` DECIMAL(18,2) COMMENT 'The total gross amount of the cash flow before any adjustments, withholdings, or offsets.',
    `investment_amount` DECIMAL(18,2) COMMENT 'The portion of the cash flow allocated to direct investment in portfolio companies or assets.',
    `lp_acknowledgement_date` DATE COMMENT 'The date on which the limited partner acknowledged receipt of the cash flow notice.',
    `lp_acknowledgement_flag` BOOLEAN COMMENT 'Indicates whether the limited partner has acknowledged receipt of the cash flow notice.',
    `management_fee_amount` DECIMAL(18,2) COMMENT 'The portion of the cash flow representing management fees paid to the general partner.',
    `modified_timestamp` TIMESTAMP COMMENT 'The timestamp when this cash flow record was last modified in the system.',
    `net_amount` DECIMAL(18,2) COMMENT 'The net amount of the cash flow after all adjustments, withholdings, and offsets have been applied.',
    `notice_date` DATE COMMENT 'The date on which notice of the cash flow was issued to the limited partner.',
    `notice_method` STRING COMMENT 'The method by which notice of the cash flow was communicated to the limited partner.. Valid values are `email|postal_mail|electronic_portal|fax|courier`',
    `organizational_expense_amount` DECIMAL(18,2) COMMENT 'The portion of the cash flow representing one-time organizational and offering expenses incurred at fund formation.',
    `payment_method` STRING COMMENT 'The method used to execute the cash flow payment.. Valid values are `wire_transfer|ach|check|internal_transfer`',
    `payment_reference_number` STRING COMMENT 'The unique reference number assigned to the payment transaction by the treasury or banking system.',
    `preferred_return_amount` DECIMAL(18,2) COMMENT 'The portion of the distribution representing the preferred return or hurdle rate payment to limited partners.',
    `purpose` STRING COMMENT 'Detailed description of the business purpose or reason for the cash flow transaction.',
    `recallable_amount` DECIMAL(18,2) COMMENT 'The amount of the distribution that remains subject to recall by the general partner.',
    `recallable_expiry_date` DATE COMMENT 'The date after which the recallable distribution can no longer be recalled by the general partner.',
    `recallable_flag` BOOLEAN COMMENT 'Indicates whether the distribution is subject to recallability provisions under the limited partnership agreement.',
    `settlement_account_number` STRING COMMENT 'The bank account number used for settling the cash flow transaction.',
    `settlement_bank_bic` STRING COMMENT 'The Bank Identifier Code or SWIFT code of the settlement bank.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `settlement_bank_name` STRING COMMENT 'The name of the financial institution through which the cash flow was settled.',
    `settlement_date` DATE COMMENT 'The date on which the cash flow was actually settled and funds transferred.',
    `transaction_date` DATE COMMENT 'The date on which the cash flow transaction was executed or recorded by the general partner.',
    `transaction_number` STRING COMMENT 'Unique business identifier for the cash flow transaction assigned by the fund administrator or general partner.',
    `withholding_tax_amount` DECIMAL(18,2) COMMENT 'The amount of tax withheld at source from the cash flow, typically applicable to distributions.',
    CONSTRAINT pk_privateequity_cash_flow PRIMARY KEY(`privateequity_cash_flow_id`)
) COMMENT 'Granular transactional record of all cash flows associated with PE investments — capital calls, distributions, management fees, fund expenses, and recallable distributions.';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`value_creation_plan` (
    `value_creation_plan_id` BIGINT COMMENT 'Unique identifier for the value creation plan record.',
    `coinvestment_id` BIGINT COMMENT 'Foreign key linking to privateequity.coinvestment. Business justification: Value creation plans currently link to investment but not coinvestment. Co-investments are direct investments alongside GPs that also require value creation tracking.',
    `fund_id` BIGINT COMMENT 'Reference to the private equity fund that owns or co-invests in this portfolio company.',
    `investment_id` BIGINT COMMENT 'Reference to the underlying private equity direct investment or co-investment for which this value creation plan was developed.',
    `portfolio_company_id` BIGINT COMMENT 'Reference to the portfolio company entity subject to this value creation plan.',
    `actual_cost_reduction_amount` DECIMAL(18,2) COMMENT 'Actual cost savings achieved to date from execution of this value creation plan.',
    `actual_ebitda_improvement_amount` DECIMAL(18,2) COMMENT 'Actual EBITDA improvement achieved to date from execution of this value creation plan, measured against the baseline.',
    `actual_revenue_growth_amount` DECIMAL(18,2) COMMENT 'Actual revenue growth achieved to date from execution of this value creation plan, measured against the baseline.',
    `baseline_date` DATE COMMENT 'Date as of which the baseline financial metrics were measured for this value creation plan.',
    `baseline_ebitda_amount` DECIMAL(18,2) COMMENT 'Baseline EBITDA of the portfolio company at the time the value creation plan was established, used as the reference point for measuring improvement.',
    `baseline_revenue_amount` DECIMAL(18,2) COMMENT 'Baseline revenue of the portfolio company at the time the value creation plan was established, used as the reference point for measuring growth.',
    `board_reporting_frequency` STRING COMMENT 'Frequency at which progress on this value creation plan is reported to the portfolio company board and GP investment committee.. Valid values are `monthly|quarterly|semi_annually|annually|ad_hoc`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this value creation plan record was first created in the system.',
    `esg_impact_flag` BOOLEAN COMMENT 'Boolean indicator of whether this value creation plan includes specific ESG improvement initiatives or targets.',
    `esg_improvement_description` STRING COMMENT 'Narrative description of the ESG improvements targeted by this value creation plan, if applicable.',
    `investment_committee_memo_reference` STRING COMMENT 'Reference number or identifier of the Investment Committee memorandum that approved or documented this value creation plan.',
    `investment_thesis_alignment` STRING COMMENT 'Narrative describing how this value creation plan aligns with the original investment thesis and underwriting assumptions presented to the Investment Committee.',
    `key_initiatives` STRING COMMENT 'Summary of the key strategic initiatives, projects, or workstreams that comprise this value creation plan.',
    `key_risks` STRING COMMENT 'Summary of the key risks and challenges that could impede successful execution of the value creation plan.',
    `last_review_date` DATE COMMENT 'Date of the most recent formal review or update of the value creation plan progress and metrics.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this value creation plan record was last modified or updated.',
    `mitigation_actions` STRING COMMENT 'Summary of the mitigation actions and contingency plans in place to address identified risks.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal review or update of the value creation plan.',
    `plan_actual_completion_date` DATE COMMENT 'Actual date on which the value creation plan was completed or closed, if applicable.',
    `plan_approval_date` DATE COMMENT 'Date on which the value creation plan was formally approved by the Investment Committee or relevant governance body.',
    `plan_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which all financial targets and metrics for this value creation plan are denominated.. Valid values are `^[A-Z]{3}$`',
    `plan_description` STRING COMMENT 'Detailed narrative description of the value creation plan objectives, scope, and strategic rationale.',
    `plan_document_uri` STRING COMMENT 'URI or file path to the formal value creation plan document, presentation, or supporting materials stored in the document management system.',
    `plan_name` STRING COMMENT 'Descriptive name or title of the value creation plan, typically reflecting the strategic theme or initiative focus.',
    `plan_reference_number` STRING COMMENT 'Externally-known unique reference or tracking number assigned to this value creation plan for governance and reporting purposes.',
    `plan_start_date` DATE COMMENT 'Date on which execution of the value creation plan commenced.',
    `plan_status` STRING COMMENT 'Current lifecycle status of the value creation plan indicating its stage in the approval and execution workflow.. Valid values are `draft|approved|active|on_hold|completed|cancelled`',
    `plan_target_completion_date` DATE COMMENT 'Target date by which all initiatives in the value creation plan are expected to be completed.',
    `portfolio_company_ceo_name` STRING COMMENT 'Name of the portfolio company CEO or senior executive accountable for delivering the value creation plan.',
    `progress_percent` DECIMAL(5,2) COMMENT 'Overall percentage completion of the value creation plan based on milestone achievement and initiative progress.',
    `responsible_partner_email` STRING COMMENT 'Email address of the General Partner or investment professional responsible for this value creation plan.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `responsible_partner_name` STRING COMMENT 'Name of the General Partner or investment professional responsible for overseeing execution of this value creation plan.',
    `risk_assessment` STRING COMMENT 'Current risk rating for successful execution of the value creation plan, reflecting execution challenges, market conditions, and management capability.. Valid values are `low|medium|high|critical`',
    `target_cost_reduction_amount` DECIMAL(18,2) COMMENT 'Targeted absolute cost savings expected from execution of this value creation plan, expressed in the plan currency.',
    `target_ebitda_improvement_amount` DECIMAL(18,2) COMMENT 'Targeted absolute improvement in EBITDA expected from execution of this value creation plan, expressed in the plan currency.',
    `target_ebitda_improvement_percent` DECIMAL(5,2) COMMENT 'Targeted percentage improvement in EBITDA margin expected from execution of this value creation plan.',
    `target_irr_percent` DECIMAL(5,2) COMMENT 'Targeted IRR expected at exit if this value creation plan is successfully executed.',
    `target_moic_multiple` DECIMAL(5,2) COMMENT 'Targeted MOIC multiple expected at exit if this value creation plan is successfully executed.',
    `target_revenue_growth_amount` DECIMAL(18,2) COMMENT 'Targeted absolute revenue increase expected from execution of this value creation plan, expressed in the plan currency.',
    `target_revenue_growth_percent` DECIMAL(5,2) COMMENT 'Targeted percentage revenue growth expected from execution of this value creation plan.',
    `value_creation_theme` STRING COMMENT 'Primary strategic theme or category of value creation initiative, such as operational efficiency, revenue growth, margin expansion, cost reduction, ESG improvement, or management change.. Valid values are `operational_efficiency|revenue_growth|margin_expansion|cost_reduction|esg_improvement|management_change`',
    CONSTRAINT pk_value_creation_plan PRIMARY KEY(`value_creation_plan_id`)
) COMMENT 'Master record for post-acquisition value creation plans for direct PE investments and co-investments. Captures investment reference, value creation theme (operational efficiency, revenue growth, M&A bolt-on, ESG improvement, management change';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`gp_report` (
    `gp_report_id` BIGINT COMMENT 'Unique identifier for each GP report received by the pension fund as Limited Partner (LP).',
    `fund_id` BIGINT COMMENT 'Reference to the private equity fund for which this report was issued.',
    `audit_opinion` STRING COMMENT 'Type of audit opinion issued by the independent auditor for audited reports.. Valid values are `unqualified|qualified|adverse|disclaimer`',
    `auditor_name` STRING COMMENT 'Name of the independent auditor who audited the fund financials, applicable for audited annual reports.',
    `carried_interest_accrued` DECIMAL(20,2) COMMENT 'Cumulative carried interest accrued to the GP as of the reporting period end date, subject to clawback provisions.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this GP report record was first created in the system.',
    `dpi_multiple` DECIMAL(10,4) COMMENT 'Distributions to Paid-In (DPI) multiple calculated as cumulative distributions divided by paid-in capital.',
    `dry_powder` DECIMAL(20,2) COMMENT 'Uncalled committed capital available for future investments as of the reporting period end date.',
    `due_date` DATE COMMENT 'Contractual deadline by which the GP was required to deliver the report per the Limited Partnership Agreement (LPA).',
    `esg_metrics_included_flag` BOOLEAN COMMENT 'Indicates whether the report includes Environmental, Social, and Governance (ESG) metrics and disclosures.',
    `esg_summary` STRING COMMENT 'Summary of ESG initiatives, metrics, and performance reported by the GP for the fund and portfolio companies.',
    `fund_expenses` DECIMAL(20,2) COMMENT 'Total fund-level expenses incurred during the reporting period, excluding management fees.',
    `fund_nav` DECIMAL(20,2) COMMENT 'Total Net Asset Value (NAV) of the fund as reported by the GP for the reporting period end date.',
    `fund_nav_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the fund NAV amount.. Valid values are `^[A-Z]{3}$`',
    `gp_contact_email` STRING COMMENT 'Email address of the GP representative for report-related communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `gp_contact_name` STRING COMMENT 'Name of the GP representative responsible for investor relations and report inquiries.',
    `gp_contact_phone` STRING COMMENT 'Phone number of the GP representative for report-related communications.',
    `irr_percent` DECIMAL(10,4) COMMENT 'Internal Rate of Return (IRR) of the fund as reported by the GP for the reporting period, expressed as a percentage.',
    `key_person_event_description` STRING COMMENT 'Details of any key person event that occurred during the reporting period.',
    `key_person_event_flag` BOOLEAN COMMENT 'Indicates whether a key person event occurred during the reporting period that may trigger LPA provisions.',
    `lp_distributions` DECIMAL(20,2) COMMENT 'Cumulative distributions paid to the pension fund as LP as of the reporting period end date.',
    `lp_dry_powder` DECIMAL(20,2) COMMENT 'Uncalled committed capital attributable to the pension fund as LP as of the reporting period end date.',
    `lp_nav` DECIMAL(20,2) COMMENT 'Net Asset Value (NAV) attributable to the pension fund as LP, reflecting its proportional share of the fund.',
    `lp_nav_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the LP NAV amount.. Valid values are `^[A-Z]{3}$`',
    `lp_paid_in_capital` DECIMAL(20,2) COMMENT 'Cumulative capital called and funded by the pension fund as LP as of the reporting period end date.',
    `management_fees_paid` DECIMAL(20,2) COMMENT 'Total management fees paid to the GP during the reporting period.',
    `new_investments_amount` DECIMAL(20,2) COMMENT 'Total capital deployed into new investments during the reporting period.',
    `new_investments_count` BIGINT COMMENT 'Number of new investments made by the fund during the reporting period.',
    `notes` STRING COMMENT 'Additional notes or commentary from the pension fund regarding the GP report review and analysis.',
    `portfolio_company_count` BIGINT COMMENT 'Total number of portfolio companies held by the fund as of the reporting period end date.',
    `realized_exits_count` BIGINT COMMENT 'Number of portfolio company exits or realizations completed during the reporting period.',
    `realized_proceeds_amount` DECIMAL(20,2) COMMENT 'Total proceeds received from portfolio company exits during the reporting period.',
    `receipt_date` DATE COMMENT 'Date on which the pension fund received the GP report from the General Partner.',
    `report_date` DATE COMMENT 'Date on which the GP report was officially issued or finalized by the General Partner.',
    `report_document_url` STRING COMMENT 'Uniform Resource Locator (URL) or file path to the full GP report document stored in the document management system.',
    `report_number` STRING COMMENT 'Unique report identifier assigned by the General Partner (GP) for tracking and reference purposes.',
    `report_status` STRING COMMENT 'Current lifecycle status of the GP report indicating whether it is preliminary or finalized.. Valid values are `draft|final|amended|superseded`',
    `report_type` STRING COMMENT 'Classification of the report indicating its frequency and purpose.. Valid values are `quarterly|annual|audited|special|interim`',
    `reporting_period_end_date` DATE COMMENT 'Ending date of the period covered by this GP report.',
    `reporting_period_start_date` DATE COMMENT 'Beginning date of the period covered by this GP report.',
    `rvpi_multiple` DECIMAL(10,4) COMMENT 'Residual Value to Paid-In (RVPI) multiple calculated as NAV divided by paid-in capital.',
    `total_distributions` DECIMAL(20,2) COMMENT 'Cumulative distributions paid to all Limited Partners (LPs) as of the reporting period end date.',
    `total_paid_in_capital` DECIMAL(20,2) COMMENT 'Cumulative capital called and funded by all Limited Partners (LPs) as of the reporting period end date.',
    `tvpi_multiple` DECIMAL(10,4) COMMENT 'Total Value to Paid-In (TVPI) multiple calculated as the sum of distributions and NAV divided by paid-in capital.',
    `unrealized_value` DECIMAL(20,2) COMMENT 'Fair value of remaining portfolio investments that have not yet been exited as of the reporting period end date.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this GP report record was last modified in the system.',
    `valuation_methodology` STRING COMMENT 'Description of the valuation methodology applied by the GP to determine portfolio company fair values.',
    CONSTRAINT pk_gp_report PRIMARY KEY(`gp_report_id`)
) COMMENT 'Transactional record for each GP quarterly or annual fund report received by the pension fund as LP. Captures report type (quarterly, annual, audited), reporting period, receipt date, GP fund NAV reported, portfolio company count, new investments in';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`privateequity_coverage` (
    `privateequity_coverage_id` BIGINT COMMENT 'Primary key for the coverage association',
    `pe_fund_id` BIGINT COMMENT 'Foreign key linking to the private equity fund vehicle being covered by the research report',
    `research_report_id` BIGINT COMMENT 'Foreign key linking to the research report that covers the fund',
    `privateequity_coverage_date` DATE COMMENT 'Date when the research report was linked to or became relevant to the fund, as identified in detection phase relationship data',
    `relevance_score` DECIMAL(5,2) COMMENT 'Numeric score indicating how material or relevant the research report is to the specific fund, as identified in detection phase relationship data. A report may be highly relevant to one fund but only tangentially relevant to another.',
    CONSTRAINT pk_privateequity_coverage PRIMARY KEY(`privateequity_coverage_id`)
) COMMENT 'This association product represents the research coverage relationship between private equity funds and research reports. It captures which research publications are relevant to which fund vehicles, enabling investment professionals to retrieve all';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`fof_vehicle` (
    `fof_vehicle_id` BIGINT COMMENT 'Primary key for fof_vehicle',
    `gp_entity_id` BIGINT COMMENT 'Foreign key linking to privateequity.gp_entity. Business justification: Fund-of-Funds vehicles are managed by a General Partner entity. This FK links the FoF vehicle to its managing GP, enabling proper relationship tracking for governance and reporting',
    `administrator_name` STRING COMMENT 'Name of the third-party fund administrator providing accounting and investor services.',
    `audit_firm_name` STRING COMMENT 'Name of the independent external auditor responsible for auditing the fund of funds vehicle financials.',
    `base_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code representing the functional currency of the fund of funds vehicle.',
    `called_capital_amount` DECIMAL(18,2) COMMENT 'Cumulative capital that has been drawn down from limited partners through capital calls.',
    `carried_interest_rate` DECIMAL(5,4) COMMENT 'Performance fee rate (carry) payable to the general partner on profits exceeding the preferred return.',
    `custodian_name` STRING COMMENT 'Name of the custodian bank responsible for safekeeping the fund of funds vehicle assets.',
    `distributed_capital_amount` DECIMAL(18,2) COMMENT 'Cumulative distributions returned to limited partners from the fund of funds vehicle.',
    `domicile_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code indicating the legal domicile jurisdiction of the fund of funds vehicle.',
    `effective_date` DATE COMMENT 'Date from which this fund of funds vehicle record becomes effective for reporting purposes.',
    `extension_period_years` BIGINT COMMENT 'Number of years by which the fund term may be extended beyond the original termination date.',
    `final_close_date` DATE COMMENT 'Date of the final closing after which no additional limited partner commitments are accepted.',
    `first_close_date` DATE COMMENT 'Date of the initial closing when the fund of funds vehicle accepted its first limited partner commitments.',
    `fund_term_years` BIGINT COMMENT 'Contractual duration in years for the fund of funds vehicle from inception to planned termination.',
    `geographic_focus` STRING COMMENT 'Primary geographic region targeted for underlying fund investments by the fund of funds vehicle.',
    `gp_commitment_percentage` DECIMAL(5,4) COMMENT 'Percentage of total fund commitments contributed by the general partner to align interests with LPs.',
    `hard_cap_amount` DECIMAL(18,2) COMMENT 'Maximum capital commitment amount the fund of funds vehicle is permitted to accept from all limited partners.',
    `inception_date` DATE COMMENT 'Date on which the fund of funds vehicle was legally established and commenced operations.',
    `investment_period_end_date` DATE COMMENT 'Date marking the end of the commitment period during which new investments can be made by the vehicle.',
    `investment_strategy` STRING COMMENT 'Primary private equity investment strategy pursued by the fund of funds vehicle.',
    `is_erisa_eligible` BOOLEAN COMMENT 'Indicates whether the fund of funds vehicle is structured to accept ERISA plan assets from US pension funds.',
    `is_esg_compliant` BOOLEAN COMMENT 'Indicates whether the fund of funds vehicle follows Environmental, Social, and Governance investment criteria.',
    `legal_counsel_name` STRING COMMENT 'Name of the primary legal counsel firm advising the fund of funds vehicle.',
    `legal_entity_identifier` STRING COMMENT '20-character ISO 17442 Legal Entity Identifier assigned to the fund of funds vehicle for regulatory reporting.',
    `management_fee_rate` DECIMAL(5,4) COMMENT 'Annual management fee rate charged by the general partner as a percentage of committed or invested capital.',
    `nav_as_of_date` DATE COMMENT 'Valuation date as of which the net asset value was calculated for the fund of funds vehicle.',
    `net_asset_value` DECIMAL(18,2) COMMENT 'Current net asset value of the fund of funds vehicle representing fair value of all underlying holdings.',
    `preferred_return_rate` DECIMAL(5,4) COMMENT 'Minimum annual return rate that must be achieved before carried interest is payable to the general partner.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this fund of funds vehicle record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this fund of funds vehicle record was last modified in the system.',
    `regulatory_status` STRING COMMENT 'Current regulatory registration status of the fund of funds vehicle with applicable authorities.',
    `reporting_frequency` STRING COMMENT 'Frequency at which the fund of funds vehicle provides performance reports to limited partners.',
    `sector_focus` STRING COMMENT 'Primary industry sectors targeted for investment by the fund of funds vehicle.',
    `sfdr_classification` STRING COMMENT 'EU Sustainable Finance Disclosure Regulation classification for the fund of funds vehicle.',
    `target_commitment_amount` DECIMAL(18,2) COMMENT 'Target total capital commitment amount the fund of funds vehicle aims to raise from limited partners.',
    `tax_status` STRING COMMENT 'Tax treatment classification of the fund of funds vehicle for investor reporting purposes.',
    `termination_date` DATE COMMENT 'Actual or projected date on which the fund of funds vehicle will be wound down and dissolved.',
    `total_committed_capital` DECIMAL(18,2) COMMENT 'Aggregate capital commitments received from all limited partners in the fund of funds vehicle.',
    `uncalled_capital_amount` DECIMAL(18,2) COMMENT 'Remaining committed capital not yet called from limited partners, representing available dry powder.',
    `vehicle_code` STRING COMMENT 'Internal alphanumeric code used to identify the fund of funds vehicle across investment systems.',
    `vehicle_name` STRING COMMENT 'Official legal name of the fund of funds vehicle as registered with regulatory authorities.',
    `vehicle_status` STRING COMMENT 'Current lifecycle status of the fund of funds vehicle indicating its operational phase.',
    `vehicle_structure` STRING COMMENT 'Legal structure under which the fund of funds vehicle is organized and operates.',
    `vehicle_type` STRING COMMENT 'Classification of the fund of funds vehicle by investment strategy approach.',
    `vintage_year` BIGINT COMMENT 'Calendar year in which the fund of funds vehicle held its first close or made its first capital call.',
    `waterfall_type` STRING COMMENT 'Type of distribution waterfall structure governing how profits are allocated between LP and GP.',
    CONSTRAINT pk_fof_vehicle PRIMARY KEY(`fof_vehicle_id`)
) COMMENT 'Master reference table for fof_vehicle. Referenced by fof_vehicle_id.';

CREATE OR REPLACE TABLE `asset_management`.`privateequity`.`lp_entity` (
    `lp_entity_id` BIGINT COMMENT 'Primary key for lp_entity',
    `aml_kyc_expiry_date` DATE COMMENT 'Date when the current AML/KYC verification expires and requires renewal for the limited partner.',
    `aml_kyc_status` STRING COMMENT 'Current status of anti-money laundering and know-your-customer verification for the limited partner.',
    `aml_kyc_verification_date` DATE COMMENT 'Date when the most recent AML/KYC verification was completed for the limited partner entity.',
    `aum_as_of_date` DATE COMMENT 'The effective date for the reported total assets under management figure.',
    `aum_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the total assets under management amount.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the limited partner entity record was first created in the system.',
    `crs_status` STRING COMMENT 'OECD Common Reporting Standard classification for automatic exchange of financial account information.',
    `domicile_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code indicating the legal domicile jurisdiction of the limited partner entity.',
    `entity_status` STRING COMMENT 'Current operational status of the limited partner entity in the fund relationship lifecycle.',
    `entity_type` STRING COMMENT 'Classification of the limited partner by institutional investor category. [ENUM-REF-CANDIDATE: pension_fund|sovereign_wealth_fund|endowment|foundation|insurance_company|family_office|fund_of_funds|corporate|bank|other — promote to reference product]',
    `erisa_status` STRING COMMENT 'Classification indicating whether the limited partner is subject to ERISA regulations for benefit plan investments.',
    `esg_policy_indicator` BOOLEAN COMMENT 'Indicates whether the limited partner has formal ESG investment policy requirements.',
    `fatca_status` STRING COMMENT 'FATCA classification of the limited partner for US tax withholding and reporting compliance purposes.',
    `incorporation_date` DATE COMMENT 'The date on which the limited partner entity was legally incorporated or established.',
    `investor_classification` STRING COMMENT 'Regulatory classification of the limited partner based on applicable securities law investor qualification standards.',
    `is_government_entity` BOOLEAN COMMENT 'Indicates whether the limited partner is a government or sovereign entity for regulatory classification.',
    `is_most_favored_nation_eligible` BOOLEAN COMMENT 'Indicates whether the limited partner is eligible for most favored nation provisions in fund terms.',
    `is_side_letter_holder` BOOLEAN COMMENT 'Indicates whether the limited partner has negotiated side letter agreements with special terms.',
    `is_tax_exempt` BOOLEAN COMMENT 'Indicates whether the limited partner entity has tax-exempt status affecting distribution calculations.',
    `legal_entity_identifier` STRING COMMENT 'The 20-character ISO 17442 Legal Entity Identifier assigned to the limited partner for regulatory reporting.',
    `legal_name` STRING COMMENT 'The official registered legal name of the limited partner entity as it appears in fund documentation.',
    `notes` STRING COMMENT 'Free-form notes and comments regarding the limited partner entity for internal reference.',
    `preferred_communication_method` STRING COMMENT 'The limited partners preferred method for receiving fund communications and reports.',
    `primary_contact_email` STRING COMMENT 'Email address of the primary contact person for investor relations and fund communications.',
    `primary_contact_name` STRING COMMENT 'Full name of the primary contact person at the limited partner entity for fund communications.',
    `primary_contact_phone` STRING COMMENT 'Phone number of the primary contact person at the limited partner entity.',
    `registered_address_line_1` STRING COMMENT 'First line of the official registered address of the limited partner entity.',
    `registered_address_line_2` STRING COMMENT 'Second line of the official registered address of the limited partner entity.',
    `registered_city` STRING COMMENT 'City of the official registered address of the limited partner entity.',
    `registered_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for the registered address of the limited partner entity.',
    `registered_postal_code` STRING COMMENT 'Postal or ZIP code of the official registered address of the limited partner entity.',
    `registration_number` STRING COMMENT 'Official registration or incorporation number assigned by the domicile jurisdiction regulatory authority.',
    `relationship_manager_name` STRING COMMENT 'Name of the internal relationship manager responsible for the limited partner account.',
    `relationship_start_date` DATE COMMENT 'Date when the business relationship with the limited partner entity was first established.',
    `reporting_frequency` STRING COMMENT 'The frequency at which the limited partner requires fund performance and financial reports.',
    `risk_rating` STRING COMMENT 'Internal risk assessment rating assigned to the limited partner based on due diligence and compliance review.',
    `short_name` STRING COMMENT 'Abbreviated or commonly used name for the limited partner entity for internal reference and reporting.',
    `target_private_equity_allocation_pct` DECIMAL(5,2) COMMENT 'The limited partners target allocation percentage to private equity as part of their investment policy.',
    `tax_identification_number` STRING COMMENT 'The tax identification number of the limited partner entity used for tax reporting and withholding purposes.',
    `total_assets_under_management` DECIMAL(18,2) COMMENT 'Total assets under management by the limited partner entity, used for investor capacity assessment.',
    `unpri_signatory_indicator` BOOLEAN COMMENT 'Indicates whether the limited partner is a signatory to the UN Principles for Responsible Investment.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the limited partner entity record was last modified in the system.',
    CONSTRAINT pk_lp_entity PRIMARY KEY(`lp_entity_id`)
) COMMENT 'Master reference table for lp_entity. Referenced by lp_entity_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_master_fund_id` FOREIGN KEY (`master_fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ADD CONSTRAINT `fk_privateequity_fund_commitment_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ADD CONSTRAINT `fk_privateequity_fund_commitment_gp_gp_entity_id` FOREIGN KEY (`gp_gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ADD CONSTRAINT `fk_privateequity_fund_commitment_pe_fund_id` FOREIGN KEY (`pe_fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ADD CONSTRAINT `fk_privateequity_privateequity_capital_call_fund_commitment_id` FOREIGN KEY (`fund_commitment_id`) REFERENCES `asset_management`.`privateequity`.`fund_commitment`(`fund_commitment_id`);
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ADD CONSTRAINT `fk_privateequity_privateequity_capital_call_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ADD CONSTRAINT `fk_privateequity_privateequity_capital_call_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ADD CONSTRAINT `fk_privateequity_privateequity_capital_call_portfolio_company_id` FOREIGN KEY (`portfolio_company_id`) REFERENCES `asset_management`.`privateequity`.`portfolio_company`(`portfolio_company_id`);
ALTER TABLE `asset_management`.`privateequity`.`distribution` ADD CONSTRAINT `fk_privateequity_distribution_fund_commitment_id` FOREIGN KEY (`fund_commitment_id`) REFERENCES `asset_management`.`privateequity`.`fund_commitment`(`fund_commitment_id`);
ALTER TABLE `asset_management`.`privateequity`.`distribution` ADD CONSTRAINT `fk_privateequity_distribution_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`privateequity`.`distribution` ADD CONSTRAINT `fk_privateequity_distribution_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`privateequity`.`distribution` ADD CONSTRAINT `fk_privateequity_distribution_underlying_investment_id` FOREIGN KEY (`underlying_investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`privateequity`.`investment` ADD CONSTRAINT `fk_privateequity_investment_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`privateequity`.`investment` ADD CONSTRAINT `fk_privateequity_investment_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`privateequity`.`investment` ADD CONSTRAINT `fk_privateequity_investment_investment_gp_entity_id` FOREIGN KEY (`investment_gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`privateequity`.`investment` ADD CONSTRAINT `fk_privateequity_investment_investment_gp_gp_entity_id` FOREIGN KEY (`investment_gp_gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`privateequity`.`investment` ADD CONSTRAINT `fk_privateequity_investment_portfolio_company_id` FOREIGN KEY (`portfolio_company_id`) REFERENCES `asset_management`.`privateequity`.`portfolio_company`(`portfolio_company_id`);
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ADD CONSTRAINT `fk_privateequity_coinvestment_gp_fund_id` FOREIGN KEY (`gp_fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ADD CONSTRAINT `fk_privateequity_coinvestment_portfolio_company_id` FOREIGN KEY (`portfolio_company_id`) REFERENCES `asset_management`.`privateequity`.`portfolio_company`(`portfolio_company_id`);
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ADD CONSTRAINT `fk_privateequity_secondary_transaction_fund_commitment_id` FOREIGN KEY (`fund_commitment_id`) REFERENCES `asset_management`.`privateequity`.`fund_commitment`(`fund_commitment_id`);
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ADD CONSTRAINT `fk_privateequity_secondary_transaction_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ADD CONSTRAINT `fk_privateequity_secondary_transaction_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ADD CONSTRAINT `fk_privateequity_lpa_terms_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ADD CONSTRAINT `fk_privateequity_lpa_terms_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ADD CONSTRAINT `fk_privateequity_carried_interest_waterfall_pe_fund_id` FOREIGN KEY (`pe_fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`privateequity`.`nav` ADD CONSTRAINT `fk_privateequity_nav_fund_commitment_id` FOREIGN KEY (`fund_commitment_id`) REFERENCES `asset_management`.`privateequity`.`fund_commitment`(`fund_commitment_id`);
ALTER TABLE `asset_management`.`privateequity`.`nav` ADD CONSTRAINT `fk_privateequity_nav_gp_report_id` FOREIGN KEY (`gp_report_id`) REFERENCES `asset_management`.`privateequity`.`gp_report`(`gp_report_id`);
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ADD CONSTRAINT `fk_privateequity_jcurve_projection_fund_commitment_id` FOREIGN KEY (`fund_commitment_id`) REFERENCES `asset_management`.`privateequity`.`fund_commitment`(`fund_commitment_id`);
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ADD CONSTRAINT `fk_privateequity_lp_advisory_committee_lp_entity_id` FOREIGN KEY (`lp_entity_id`) REFERENCES `asset_management`.`privateequity`.`lp_entity`(`lp_entity_id`);
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ADD CONSTRAINT `fk_privateequity_lp_advisory_committee_pe_fund_id` FOREIGN KEY (`pe_fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ADD CONSTRAINT `fk_privateequity_capital_account_lp_entity_id` FOREIGN KEY (`lp_entity_id`) REFERENCES `asset_management`.`privateequity`.`lp_entity`(`lp_entity_id`);
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ADD CONSTRAINT `fk_privateequity_capital_account_pe_fund_id` FOREIGN KEY (`pe_fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ADD CONSTRAINT `fk_privateequity_management_fee_invoice_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ADD CONSTRAINT `fk_privateequity_management_fee_invoice_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ADD CONSTRAINT `fk_privateequity_management_fee_invoice_invoice_recipient_entity_id` FOREIGN KEY (`invoice_recipient_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ADD CONSTRAINT `fk_privateequity_fund_of_funds_allocation_fof_vehicle_id` FOREIGN KEY (`fof_vehicle_id`) REFERENCES `asset_management`.`privateequity`.`fof_vehicle`(`fof_vehicle_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ADD CONSTRAINT `fk_privateequity_fund_of_funds_allocation_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ADD CONSTRAINT `fk_privateequity_fund_of_funds_allocation_underlying_pe_fund_id` FOREIGN KEY (`underlying_pe_fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ADD CONSTRAINT `fk_privateequity_privateequity_cash_flow_fund_commitment_id` FOREIGN KEY (`fund_commitment_id`) REFERENCES `asset_management`.`privateequity`.`fund_commitment`(`fund_commitment_id`);
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ADD CONSTRAINT `fk_privateequity_privateequity_cash_flow_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ADD CONSTRAINT `fk_privateequity_privateequity_cash_flow_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ADD CONSTRAINT `fk_privateequity_privateequity_cash_flow_portfolio_company_id` FOREIGN KEY (`portfolio_company_id`) REFERENCES `asset_management`.`privateequity`.`portfolio_company`(`portfolio_company_id`);
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ADD CONSTRAINT `fk_privateequity_value_creation_plan_coinvestment_id` FOREIGN KEY (`coinvestment_id`) REFERENCES `asset_management`.`privateequity`.`coinvestment`(`coinvestment_id`);
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ADD CONSTRAINT `fk_privateequity_value_creation_plan_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ADD CONSTRAINT `fk_privateequity_value_creation_plan_investment_id` FOREIGN KEY (`investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ADD CONSTRAINT `fk_privateequity_value_creation_plan_portfolio_company_id` FOREIGN KEY (`portfolio_company_id`) REFERENCES `asset_management`.`privateequity`.`portfolio_company`(`portfolio_company_id`);
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ADD CONSTRAINT `fk_privateequity_gp_report_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`privateequity`.`privateequity_coverage` ADD CONSTRAINT `fk_privateequity_privateequity_coverage_pe_fund_id` FOREIGN KEY (`pe_fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`privateequity`.`fof_vehicle` ADD CONSTRAINT `fk_privateequity_fof_vehicle_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`privateequity`.`fund` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`privateequity`.`fund` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`fund` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`fund` SET TAGS ('dbx_subdomain' = 'fund_structure');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Entity Identifier');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `fund_administrator_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Administrator Entity Identifier');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `auditor_id` SET TAGS ('dbx_business_glossary_term' = 'Auditor Entity Identifier');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `climate_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `controversy_id` SET TAGS ('dbx_business_glossary_term' = 'Controversy Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Administrator Entity Identifier');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `engagement_activity_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Activity Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `engagement_objective_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Objective Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `esg_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Esg Benchmark Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `exclusion_list_id` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Entity Identifier');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `macro_model_run_id` SET TAGS ('dbx_business_glossary_term' = 'Macro Model Run Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `master_fund_id` SET TAGS ('dbx_business_glossary_term' = 'Master Fund Identifier');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `risk_model_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Model Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Stress Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `tcfd_disclosure_id` SET TAGS ('dbx_business_glossary_term' = 'Tcf Disclosure Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `benchmark_index` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `carried_interest_rate` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Rate');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `catch_up_rate` SET TAGS ('dbx_business_glossary_term' = 'Catch-Up Rate');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `clawback_provision` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Indicator');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Fund Base Currency');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `domicile_country` SET TAGS ('dbx_business_glossary_term' = 'Fund Domicile Country');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `domicile_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `domicile_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Fund Domicile Jurisdiction');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `esg_strategy` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Strategy');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `extension_options_years` SET TAGS ('dbx_business_glossary_term' = 'Extension Options in Years');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `final_close_date` SET TAGS ('dbx_business_glossary_term' = 'Final Close Date');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `first_close_date` SET TAGS ('dbx_business_glossary_term' = 'First Close Date');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `fund_status` SET TAGS ('dbx_business_glossary_term' = 'Fund Lifecycle Status');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `fund_status` SET TAGS ('dbx_value_regex' = 'fundraising|investing|harvesting|liquidated|dissolved');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `fund_type` SET TAGS ('dbx_business_glossary_term' = 'Fund Type');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `fund_type` SET TAGS ('dbx_value_regex' = 'buyout|venture|growth|secondaries|fund_of_funds|co_investment');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `hard_cap` SET TAGS ('dbx_business_glossary_term' = 'Hard Cap');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `hurdle_rate` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate (Preferred Return)');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `identifier` SET TAGS ('dbx_business_glossary_term' = 'Fund External Identifier');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Fund Inception Date');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `investment_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Period End Date');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `investment_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Period Start Date');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy Description');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `is_evergreen` SET TAGS ('dbx_business_glossary_term' = 'Evergreen Fund Indicator');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `is_feeder_fund` SET TAGS ('dbx_business_glossary_term' = 'Feeder Fund Indicator');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `management_fee_basis` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Basis');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `management_fee_basis` SET TAGS ('dbx_value_regex' = 'committed_capital|invested_capital|nav');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `management_fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Rate');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `maximum_investment_size` SET TAGS ('dbx_business_glossary_term' = 'Maximum Investment Size');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `minimum_investment_size` SET TAGS ('dbx_business_glossary_term' = 'Minimum Investment Size');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `fund_name` SET TAGS ('dbx_business_glossary_term' = 'Fund Legal Name');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Classification');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_value_regex' = 'article_6|article_8|article_9');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `short_name` SET TAGS ('dbx_business_glossary_term' = 'Fund Short Name');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `target_fund_size` SET TAGS ('dbx_business_glossary_term' = 'Target Fund Size');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `target_geographies` SET TAGS ('dbx_business_glossary_term' = 'Target Geographies');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `target_sectors` SET TAGS ('dbx_business_glossary_term' = 'Target Sectors');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `term_years` SET TAGS ('dbx_business_glossary_term' = 'Fund Term in Years');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Fund Termination Date');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `total_commitments` SET TAGS ('dbx_business_glossary_term' = 'Total Commitments');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `valuation_policy` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `waterfall_structure` SET TAGS ('dbx_business_glossary_term' = 'Waterfall Structure');
ALTER TABLE `asset_management`.`privateequity`.`fund` ALTER COLUMN `waterfall_structure` SET TAGS ('dbx_value_regex' = 'european|american|hybrid');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` SET TAGS ('dbx_subdomain' = 'fund_structure');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Commitment Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `gp_gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `pe_fund_id` SET TAGS ('dbx_business_glossary_term' = 'Private Equity (PE) Fund Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `carried_interest_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Rate Percentage');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `catch_up_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Catch-Up Rate Percentage');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Commitment Currency Code');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `commitment_date` SET TAGS ('dbx_business_glossary_term' = 'Commitment Execution Date');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `commitment_number` SET TAGS ('dbx_business_glossary_term' = 'Commitment Reference Number');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `commitment_status` SET TAGS ('dbx_business_glossary_term' = 'Commitment Lifecycle Status');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `commitment_status` SET TAGS ('dbx_value_regex' = 'active|fully_drawn|partially_drawn|terminated|suspended|defaulted');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `commitment_type` SET TAGS ('dbx_business_glossary_term' = 'Commitment Type Classification');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `commitment_type` SET TAGS ('dbx_value_regex' = 'primary|secondary|co_investment|fund_of_funds');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `committed_capital_amount` SET TAGS ('dbx_business_glossary_term' = 'Committed Capital Amount');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `dpi_multiple` SET TAGS ('dbx_business_glossary_term' = 'Distributions to Paid-In (DPI) Multiple');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `esg_classification` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Classification');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `esg_classification` SET TAGS ('dbx_value_regex' = 'article_6|article_8|article_9');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `extension_options_count` SET TAGS ('dbx_business_glossary_term' = 'Extension Options Count');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `final_close_date` SET TAGS ('dbx_business_glossary_term' = 'Final Close Date');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `first_close_date` SET TAGS ('dbx_business_glossary_term' = 'First Close Date');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `fund_strategy` SET TAGS ('dbx_business_glossary_term' = 'Fund Investment Strategy');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `fund_strategy` SET TAGS ('dbx_value_regex' = 'buyout|growth_equity|venture_capital|distressed|real_assets|infrastructure');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `fund_term_years` SET TAGS ('dbx_business_glossary_term' = 'Fund Term Duration in Years');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Investment Focus');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate (Preferred Return) Percentage');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `investment_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Period End Date');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `investment_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Period Start Date');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `irr_percent` SET TAGS ('dbx_business_glossary_term' = 'Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `key_person_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Key Person Clause Flag');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `last_capital_call_date` SET TAGS ('dbx_business_glossary_term' = 'Last Capital Call Date');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `last_distribution_date` SET TAGS ('dbx_business_glossary_term' = 'Last Distribution Date');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `management_fee_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Rate Percentage');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `moic_multiple` SET TAGS ('dbx_business_glossary_term' = 'Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `most_favored_nation_flag` SET TAGS ('dbx_business_glossary_term' = 'Most Favored Nation (MFN) Clause Flag');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `nav_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Amount');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `no_fault_divorce_flag` SET TAGS ('dbx_business_glossary_term' = 'No-Fault Divorce Clause Flag');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage in Fund');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `paid_in_capital_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid-In Capital (PIC) Amount');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `remaining_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Remaining Commitment Amount (Dry Powder)');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `rvpi_multiple` SET TAGS ('dbx_business_glossary_term' = 'Residual Value to Paid-In (RVPI) Multiple');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `sector_focus` SET TAGS ('dbx_business_glossary_term' = 'Sector Investment Focus');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `side_letter_flag` SET TAGS ('dbx_business_glossary_term' = 'Side Letter Agreement Flag');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `target_fund_size_amount` SET TAGS ('dbx_business_glossary_term' = 'Target Fund Size Amount');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Commitment Termination Date');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `total_distributions_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Distributions Amount');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `tvpi_multiple` SET TAGS ('dbx_business_glossary_term' = 'Total Value to Paid-In (TVPI) Multiple');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation As-Of Date');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Fund Vintage Year');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `waterfall_structure_type` SET TAGS ('dbx_business_glossary_term' = 'Waterfall Structure Type');
ALTER TABLE `asset_management`.`privateequity`.`fund_commitment` ALTER COLUMN `waterfall_structure_type` SET TAGS ('dbx_value_regex' = 'american|european|hybrid');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` SET TAGS ('dbx_subdomain' = 'capital_flows');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `privateequity_capital_call_id` SET TAGS ('dbx_business_glossary_term' = 'Private Equity Capital Call Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Commitment Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Entity Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `settlement_instruction_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Instruction Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `portfolio_company_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Company Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `call_amount` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Amount');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `call_currency` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Currency Code');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `call_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `call_document_url` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Document Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `call_due_date` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Due Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `call_notice_date` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Notice Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `call_notice_number` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Notice Number');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `call_purpose` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Purpose');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `call_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Sequence Number');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `call_status` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Status');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `call_status` SET TAGS ('dbx_value_regex' = 'issued|acknowledged|funded|partially_funded|overdue|cancelled');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `call_type` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Type');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `call_type` SET TAGS ('dbx_value_regex' = 'regular|emergency|bridge|final');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Reason');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `cancelled_date` SET TAGS ('dbx_business_glossary_term' = 'Cancelled Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `cancelled_flag` SET TAGS ('dbx_business_glossary_term' = 'Cancelled Flag');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `default_interest_accrued` SET TAGS ('dbx_business_glossary_term' = 'Default Interest Accrued');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `default_interest_rate` SET TAGS ('dbx_business_glossary_term' = 'Default Interest Rate');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `excuse_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Excuse Approval Status');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `excuse_approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|denied|not_applicable');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `excuse_request_flag` SET TAGS ('dbx_business_glossary_term' = 'Excuse Request Flag');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `excuse_request_reason` SET TAGS ('dbx_business_glossary_term' = 'Excuse Request Reason');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `fund_expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Fund Expense Amount');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `funded_amount` SET TAGS ('dbx_business_glossary_term' = 'Funded Amount');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `funded_date` SET TAGS ('dbx_business_glossary_term' = 'Funded Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `investment_amount` SET TAGS ('dbx_business_glossary_term' = 'Investment Amount');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `investment_description` SET TAGS ('dbx_business_glossary_term' = 'Investment Description');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `lp_acknowledgement_date` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Acknowledgement Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `lp_acknowledgement_flag` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Acknowledgement Flag');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `management_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Amount');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Notes');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `notice_method` SET TAGS ('dbx_business_glossary_term' = 'Notice Delivery Method');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `notice_method` SET TAGS ('dbx_value_regex' = 'email|postal_mail|electronic_portal|courier|fax');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `notice_received_date` SET TAGS ('dbx_business_glossary_term' = 'Notice Received Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `organizational_expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Organizational Expense Amount');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `settlement_account_number` SET TAGS ('dbx_business_glossary_term' = 'Settlement Account Number');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `settlement_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `settlement_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `settlement_bank_bic` SET TAGS ('dbx_business_glossary_term' = 'Settlement Bank Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `settlement_bank_bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `settlement_bank_name` SET TAGS ('dbx_business_glossary_term' = 'Settlement Bank Name');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ALTER COLUMN `unfunded_amount` SET TAGS ('dbx_business_glossary_term' = 'Unfunded Amount');
ALTER TABLE `asset_management`.`privateequity`.`distribution` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`privateequity`.`distribution` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`distribution` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`distribution` SET TAGS ('dbx_subdomain' = 'capital_flows');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `distribution_id` SET TAGS ('dbx_business_glossary_term' = 'Distribution Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Commitment Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Entity Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `underlying_investment_id` SET TAGS ('dbx_business_glossary_term' = 'Underlying Investment Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `accounting_period` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `accounting_period` SET TAGS ('dbx_value_regex' = '^d{4}-Q[1-4]$|^d{4}-d{2}$');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Distribution Amount');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `amount_base_currency` SET TAGS ('dbx_business_glossary_term' = 'Distribution Amount in Base Currency');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `cumulative_distributions_to_date` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Distributions to Date');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Distribution Currency');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `custodian_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Custodian Reference Number');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `distribution_status` SET TAGS ('dbx_business_glossary_term' = 'Distribution Status');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `distribution_status` SET TAGS ('dbx_value_regex' = 'pending|confirmed|settled|cancelled|recalled');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `distribution_type` SET TAGS ('dbx_business_glossary_term' = 'Distribution Type');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `distribution_type` SET TAGS ('dbx_value_regex' = 'return_of_capital|realized_gain|dividend|interest|in_kind|recallable');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `document_uri` SET TAGS ('dbx_business_glossary_term' = 'Distribution Document Uniform Resource Identifier (URI)');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `dpi_ratio` SET TAGS ('dbx_business_glossary_term' = 'Distributions to Paid-In (DPI) Ratio');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Distribution Effective Date');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `in_kind_asset_description` SET TAGS ('dbx_business_glossary_term' = 'In-Kind Asset Description');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `in_kind_asset_fair_value` SET TAGS ('dbx_business_glossary_term' = 'In-Kind Asset Fair Value');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `in_kind_asset_quantity` SET TAGS ('dbx_business_glossary_term' = 'In-Kind Asset Quantity');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `irr_contribution` SET TAGS ('dbx_business_glossary_term' = 'Internal Rate of Return (IRR) Contribution');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `lp_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Commitment Amount');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `memo` SET TAGS ('dbx_business_glossary_term' = 'Distribution Memo');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `moic_contribution` SET TAGS ('dbx_business_glossary_term' = 'Multiple on Invested Capital (MOIC) Contribution');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `nav_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Impact Amount');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `net_distribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Distribution Amount');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `notice_date` SET TAGS ('dbx_business_glossary_term' = 'Distribution Notice Date');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `notice_number` SET TAGS ('dbx_business_glossary_term' = 'Distribution Notice Number');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Distribution Payment Date');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `recallable_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Recallable Distribution Expiry Date');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `recallable_flag` SET TAGS ('dbx_business_glossary_term' = 'Recallable Distribution Flag');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `settlement_account_number` SET TAGS ('dbx_business_glossary_term' = 'Settlement Account Number');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `settlement_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `settlement_bank_bic` SET TAGS ('dbx_business_glossary_term' = 'Settlement Bank Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `settlement_bank_bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `source_event` SET TAGS ('dbx_business_glossary_term' = 'Distribution Source Event');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `tax_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Tax Jurisdiction');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `tax_jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `tax_treaty_applicable_flag` SET TAGS ('dbx_business_glossary_term' = 'Tax Treaty Applicable Flag');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Amount');
ALTER TABLE `asset_management`.`privateequity`.`distribution` ALTER COLUMN `withholding_tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Rate');
ALTER TABLE `asset_management`.`privateequity`.`investment` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`privateequity`.`investment` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`investment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`investment` SET TAGS ('dbx_subdomain' = 'fund_structure');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `investment_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Identifier');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Identifier');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `investment_gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Identifier');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `investment_gp_gp_entity_id` SET TAGS ('dbx_internal' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `portfolio_company_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Company Identifier');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `research_report_id` SET TAGS ('dbx_business_glossary_term' = 'Report Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `risk_model_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Model Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `carried_interest_rate` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Rate');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Commitment Amount');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Commitment Currency');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `commitment_date` SET TAGS ('dbx_business_glossary_term' = 'Commitment Date');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `distributions_received` SET TAGS ('dbx_business_glossary_term' = 'Distributions Received');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `dpi` SET TAGS ('dbx_business_glossary_term' = 'Distributions to Paid-In (DPI)');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `esg_integration_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Integration Flag');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `exit_date` SET TAGS ('dbx_business_glossary_term' = 'Exit Date');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `final_close_date` SET TAGS ('dbx_business_glossary_term' = 'Final Close Date');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `first_close_date` SET TAGS ('dbx_business_glossary_term' = 'First Close Date');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `fund_size` SET TAGS ('dbx_business_glossary_term' = 'Fund Size');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `fund_term_years` SET TAGS ('dbx_business_glossary_term' = 'Fund Term (Years)');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `geography` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `hurdle_rate` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate (Preferred Return)');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `investment_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Date');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `investment_status` SET TAGS ('dbx_business_glossary_term' = 'Investment Status');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `investment_status` SET TAGS ('dbx_value_regex' = 'committed|funded|active|partially_exited|fully_exited|written_off');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `investment_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Type');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `investment_type` SET TAGS ('dbx_value_regex' = 'direct|co-investment|secondary|fund-of-funds|primary_fund|club_deal');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `irr` SET TAGS ('dbx_business_glossary_term' = 'Internal Rate of Return (IRR)');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `management_fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Rate');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `moic` SET TAGS ('dbx_business_glossary_term' = 'Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `investment_name` SET TAGS ('dbx_business_glossary_term' = 'Investment Name');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `nav` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `nav_date` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Date');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `paid_in_capital` SET TAGS ('dbx_business_glossary_term' = 'Paid-In Capital (PIC)');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Period End Date');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `rvpi` SET TAGS ('dbx_business_glossary_term' = 'Residual Value to Paid-In (RVPI)');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Industry Sector');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `strategy` SET TAGS ('dbx_value_regex' = 'buyout|growth_equity|venture_capital|distressed|mezzanine|turnaround');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `sub_sector` SET TAGS ('dbx_business_glossary_term' = 'Industry Sub-Sector');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `total_value` SET TAGS ('dbx_business_glossary_term' = 'Total Value');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `tvpi` SET TAGS ('dbx_business_glossary_term' = 'Total Value to Paid-In (TVPI)');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `unfunded_commitment` SET TAGS ('dbx_business_glossary_term' = 'Unfunded Commitment (Dry Powder)');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `asset_management`.`privateequity`.`investment` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` SET TAGS ('dbx_subdomain' = 'fund_structure');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `coinvestment_id` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment (Co-Invest) Identifier');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `gp_fund_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Fund Identifier');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `portfolio_company_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Company Identifier');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `actual_exit_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Exit Date');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'private_equity|venture_capital|growth_equity|buyout|infrastructure|real_estate');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `coinvestment_code` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment (Co-Invest) Code');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `coinvestment_status` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment (Co-Invest) Status');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Commitment Amount');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Commitment Currency');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `distributions_received` SET TAGS ('dbx_business_glossary_term' = 'Distributions Received');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `dpi` SET TAGS ('dbx_business_glossary_term' = 'Distributions to Paid-In (DPI)');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `entry_ebitda_multiple` SET TAGS ('dbx_business_glossary_term' = 'Entry Earnings Before Interest Taxes Depreciation and Amortization (EBITDA) Multiple');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `entry_valuation` SET TAGS ('dbx_business_glossary_term' = 'Entry Valuation');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `esg_integration_level` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Integration Level');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `esg_integration_level` SET TAGS ('dbx_value_regex' = 'full|partial|minimal|none');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `exit_proceeds` SET TAGS ('dbx_business_glossary_term' = 'Exit Proceeds');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `exit_type` SET TAGS ('dbx_business_glossary_term' = 'Exit Type');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `exit_type` SET TAGS ('dbx_value_regex' = 'ipo|trade_sale|secondary_sale|recapitalization|write_off|partial_exit');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `expected_exit_date` SET TAGS ('dbx_business_glossary_term' = 'Expected Exit Date');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `expected_hold_period_years` SET TAGS ('dbx_business_glossary_term' = 'Expected Hold Period (Years)');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `final_close_date` SET TAGS ('dbx_business_glossary_term' = 'Final Close Date');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `first_capital_call_date` SET TAGS ('dbx_business_glossary_term' = 'First Capital Call Date');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `geography` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `ic_approval_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Reference');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `investment_structure` SET TAGS ('dbx_business_glossary_term' = 'Investment Structure');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `investment_structure` SET TAGS ('dbx_value_regex' = 'common_equity|preferred_equity|convertible_debt|mezzanine|hybrid');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `investment_thesis` SET TAGS ('dbx_business_glossary_term' = 'Investment Thesis');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `investment_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Type');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `investment_type` SET TAGS ('dbx_value_regex' = 'direct_coinvest|syndicated_coinvest|club_deal|secondary_coinvest');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `irr` SET TAGS ('dbx_business_glossary_term' = 'Internal Rate of Return (IRR)');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `lead_investment_professional` SET TAGS ('dbx_business_glossary_term' = 'Lead Investment Professional');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `moic` SET TAGS ('dbx_business_glossary_term' = 'Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `coinvestment_name` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment (Co-Invest) Name');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `nav` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `paid_in_capital` SET TAGS ('dbx_business_glossary_term' = 'Paid-In Capital (PIC)');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `realized_gain_loss` SET TAGS ('dbx_business_glossary_term' = 'Realized Gain or Loss');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `rvpi` SET TAGS ('dbx_business_glossary_term' = 'Residual Value to Paid-In (RVPI)');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `target_irr` SET TAGS ('dbx_business_glossary_term' = 'Target Internal Rate of Return (IRR)');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `target_moic` SET TAGS ('dbx_business_glossary_term' = 'Target Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `tvpi` SET TAGS ('dbx_business_glossary_term' = 'Total Value to Paid-In (TVPI)');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `unfunded_commitment` SET TAGS ('dbx_business_glossary_term' = 'Unfunded Commitment (Dry Powder)');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` SET TAGS ('dbx_subdomain' = 'capital_flows');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `secondary_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Secondary Transaction ID');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Commitment Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund ID');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Entity Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `broker_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Broker Fee Amount');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `broker_intermediary_name` SET TAGS ('dbx_business_glossary_term' = 'Broker or Intermediary Name');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `broker_intermediary_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `discount_premium_to_nav_percent` SET TAGS ('dbx_business_glossary_term' = 'Discount or Premium to NAV (%)');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `dpi_at_transaction` SET TAGS ('dbx_business_glossary_term' = 'Distributions to Paid-In (DPI) at Transaction');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `face_value_commitment` SET TAGS ('dbx_business_glossary_term' = 'Face Value Commitment');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `fund_strategy` SET TAGS ('dbx_business_glossary_term' = 'Fund Strategy');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `fund_strategy` SET TAGS ('dbx_value_regex' = 'buyout|venture_capital|growth_equity|distressed|mezzanine|secondary');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `gp_consent_date` SET TAGS ('dbx_business_glossary_term' = 'GP Consent Date');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `gp_consent_received_flag` SET TAGS ('dbx_business_glossary_term' = 'GP Consent Received Flag');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `gp_consent_required_flag` SET TAGS ('dbx_business_glossary_term' = 'GP Consent Required Flag');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `investment_committee_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `investment_committee_memo_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Memo Reference');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `irr_at_transaction_percent` SET TAGS ('dbx_business_glossary_term' = 'Internal Rate of Return (IRR) at Transaction (%)');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `last_modified_by_user` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `legal_advisor_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Advisor Name');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `legal_advisor_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `legal_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Legal Fee Amount');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `nav_at_transaction` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) at Transaction');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `portfolio_allocation_strategy` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Allocation Strategy');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `rvpi_at_transaction` SET TAGS ('dbx_business_glossary_term' = 'Residual Value to Paid-In (RVPI) at Transaction');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `total_transaction_costs` SET TAGS ('dbx_business_glossary_term' = 'Total Transaction Costs');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Date');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `transaction_notes` SET TAGS ('dbx_business_glossary_term' = 'Transaction Notes');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `transaction_price` SET TAGS ('dbx_business_glossary_term' = 'Transaction Price');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `transaction_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Transaction Reference Number');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_business_glossary_term' = 'Transaction Status');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_value_regex' = 'pending|executed|settled|cancelled|failed');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Transaction Type');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'buy|sell');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `tvpi_at_transaction` SET TAGS ('dbx_business_glossary_term' = 'Total Value to Paid-In (TVPI) at Transaction');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `unfunded_commitment` SET TAGS ('dbx_business_glossary_term' = 'Unfunded Commitment');
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` SET TAGS ('dbx_subdomain' = 'fund_structure');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `lpa_terms_id` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Terms Identifier');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Legal Entity Identifier');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `advisory_committee_flag` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner Advisory Committee (LPAC) Flag');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Amendment Number');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `audit_requirement_flag` SET TAGS ('dbx_business_glossary_term' = 'Annual Audit Requirement Flag');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `carried_interest_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Rate Percentage');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `catch_up_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Catch-Up Rate Percentage');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `clawback_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Flag');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `co_investment_right_flag` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Right Flag');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `esg_policy_description` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Policy Description');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `esg_policy_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Policy Flag');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `extension_option_years` SET TAGS ('dbx_business_glossary_term' = 'Extension Option in Years');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `fund_domicile` SET TAGS ('dbx_business_glossary_term' = 'Fund Domicile');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `fund_term_years` SET TAGS ('dbx_business_glossary_term' = 'Fund Term in Years');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `geographic_restriction` SET TAGS ('dbx_business_glossary_term' = 'Geographic Restriction');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `governing_law_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Governing Law Jurisdiction');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `gp_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Commitment Amount');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `gp_commitment_pct` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Commitment Percentage');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `hurdle_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percentage');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `hurdle_type` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Type');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `hurdle_type` SET TAGS ('dbx_value_regex' = 'hard|soft|none');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `investment_concentration_limit_pct` SET TAGS ('dbx_business_glossary_term' = 'Investment Concentration Limit Percentage');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `investment_period_years` SET TAGS ('dbx_business_glossary_term' = 'Investment Period in Years');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `key_person_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Key Person Clause Flag');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `key_person_names` SET TAGS ('dbx_business_glossary_term' = 'Key Person Names');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `leverage_limit_multiple` SET TAGS ('dbx_business_glossary_term' = 'Leverage Limit Multiple');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `lpa_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Document Reference');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `lpa_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Effective Date');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `lpa_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Execution Date');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `lpa_terms_status` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Terms Status');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `lpa_terms_status` SET TAGS ('dbx_value_regex' = 'active|amended|superseded|terminated');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `management_fee_basis` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Basis');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `management_fee_basis` SET TAGS ('dbx_value_regex' = 'committed_capital|invested_capital|nav|hybrid');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `management_fee_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Rate Percentage');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `management_fee_step_down_date` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Step-Down Date');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `most_favored_nation_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Most Favored Nation (MFN) Clause Flag');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `no_fault_divorce_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'No-Fault Divorce Clause Flag');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `post_investment_fee_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Post-Investment Period Fee Rate Percentage');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `recycling_limit_pct` SET TAGS ('dbx_business_glossary_term' = 'Capital Recycling Limit Percentage');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `recycling_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Capital Recycling Provision Flag');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `removal_threshold_pct` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Removal Threshold Percentage');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `sector_restriction` SET TAGS ('dbx_business_glossary_term' = 'Sector Restriction');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `transfer_restriction_type` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Interest Transfer Restriction Type');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `transfer_restriction_type` SET TAGS ('dbx_value_regex' = 'prohibited|gp_consent|right_of_first_refusal|free_transfer');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `waterfall_structure` SET TAGS ('dbx_business_glossary_term' = 'Waterfall Structure');
ALTER TABLE `asset_management`.`privateequity`.`lpa_terms` ALTER COLUMN `waterfall_structure` SET TAGS ('dbx_value_regex' = 'american|european|hybrid');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` SET TAGS ('dbx_subdomain' = 'capital_flows');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `carried_interest_waterfall_id` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Waterfall ID');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `pe_fund_id` SET TAGS ('dbx_business_glossary_term' = 'Private Equity (PE) Fund ID');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Calculation Date');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Calculation Method');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `calculation_notes` SET TAGS ('dbx_business_glossary_term' = 'Calculation Notes');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `calculation_status` SET TAGS ('dbx_business_glossary_term' = 'Calculation Status');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `calculation_status` SET TAGS ('dbx_value_regex' = 'draft|preliminary|final|revised|superseded');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `carry_accrued_unpaid` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Accrued Unpaid');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `carry_distributed` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Distributed');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `carry_earned` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Earned');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `carry_rate` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Rate');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `clawback_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Flag');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `clawback_reserve` SET TAGS ('dbx_business_glossary_term' = 'Clawback Reserve');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `dpi` SET TAGS ('dbx_business_glossary_term' = 'Distributions to Paid-In (DPI)');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `gp_catchup_amount` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Catch-Up Amount');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `gp_catchup_rate` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Catch-Up Rate');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `gp_profit_share` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Profit Share');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `irr` SET TAGS ('dbx_business_glossary_term' = 'Internal Rate of Return (IRR)');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `lp_profit_share` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Profit Share');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `nav` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `preferred_return_accrued` SET TAGS ('dbx_business_glossary_term' = 'Preferred Return Accrued');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `preferred_return_paid` SET TAGS ('dbx_business_glossary_term' = 'Preferred Return Paid');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `preferred_return_rate` SET TAGS ('dbx_business_glossary_term' = 'Preferred Return Rate');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `return_of_capital` SET TAGS ('dbx_business_glossary_term' = 'Return of Capital');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `rvpi` SET TAGS ('dbx_business_glossary_term' = 'Residual Value to Paid-In (RVPI)');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `total_contributions` SET TAGS ('dbx_business_glossary_term' = 'Total Contributions');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `total_distributions` SET TAGS ('dbx_business_glossary_term' = 'Total Distributions');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `tvpi` SET TAGS ('dbx_business_glossary_term' = 'Total Value to Paid-In (TVPI)');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `waterfall_type` SET TAGS ('dbx_business_glossary_term' = 'Waterfall Type');
ALTER TABLE `asset_management`.`privateequity`.`carried_interest_waterfall` ALTER COLUMN `waterfall_type` SET TAGS ('dbx_value_regex' = 'american|european|hybrid');
ALTER TABLE `asset_management`.`privateequity`.`nav` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`privateequity`.`nav` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`nav` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`nav` SET TAGS ('dbx_subdomain' = 'performance_analytics');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `nav_id` SET TAGS ('dbx_business_glossary_term' = 'Nav Identifier');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Commitment ID');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `gp_report_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Report Document ID');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Amount');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `audit_opinion` SET TAGS ('dbx_business_glossary_term' = 'Audit Opinion');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `audit_opinion` SET TAGS ('dbx_value_regex' = 'unqualified|qualified|adverse|disclaimer');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `audited_flag` SET TAGS ('dbx_business_glossary_term' = 'Audited Flag');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `auditor_name` SET TAGS ('dbx_business_glossary_term' = 'Auditor Name');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `base_currency_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Base Currency Amount');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `carried_interest_accrued` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Accrued');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `distributions_received` SET TAGS ('dbx_business_glossary_term' = 'Distributions Received');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `dpi` SET TAGS ('dbx_business_glossary_term' = 'Distributions to Paid-In (DPI)');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `fair_value_hierarchy_level` SET TAGS ('dbx_business_glossary_term' = 'Fair Value Hierarchy Level');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `fair_value_hierarchy_level` SET TAGS ('dbx_value_regex' = 'level_1|level_2|level_3');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `fund_age_years` SET TAGS ('dbx_business_glossary_term' = 'Fund Age in Years');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `fx_rate_to_base` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate to Base Currency');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `gav_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Asset Value (GAV) Amount');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `gp_report_received_date` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Report Received Date');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `irr_since_inception` SET TAGS ('dbx_business_glossary_term' = 'Internal Rate of Return (IRR) Since Inception');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `is_current_record` SET TAGS ('dbx_business_glossary_term' = 'Is Current Record');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `j_curve_phase` SET TAGS ('dbx_business_glossary_term' = 'J-Curve Phase');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `j_curve_phase` SET TAGS ('dbx_value_regex' = 'investment|harvesting|mature|liquidation');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `management_fee_accrued` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Accrued');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `moic` SET TAGS ('dbx_business_glossary_term' = 'Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `nav_status` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Status');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `nav_status` SET TAGS ('dbx_value_regex' = 'preliminary|final|audited|adjusted|restated');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `number_of_portfolio_companies` SET TAGS ('dbx_business_glossary_term' = 'Number of Portfolio Companies');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `other_expenses_accrued` SET TAGS ('dbx_business_glossary_term' = 'Other Expenses Accrued');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `paid_in_capital` SET TAGS ('dbx_business_glossary_term' = 'Paid-In Capital (PIC)');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `realized_value` SET TAGS ('dbx_business_glossary_term' = 'Realized Value');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `record_effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Record Effective From Date');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `record_effective_to_date` SET TAGS ('dbx_business_glossary_term' = 'Record Effective To Date');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `reporting_currency` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Reporting Currency');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `reporting_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `rvpi` SET TAGS ('dbx_business_glossary_term' = 'Residual Value to Paid-In (RVPI)');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `total_commitment` SET TAGS ('dbx_business_glossary_term' = 'Total Commitment');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `total_value` SET TAGS ('dbx_business_glossary_term' = 'Total Value');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `tvpi` SET TAGS ('dbx_business_glossary_term' = 'Total Value to Paid-In (TVPI)');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `unfunded_commitment` SET TAGS ('dbx_business_glossary_term' = 'Unfunded Commitment');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `unrealized_value` SET TAGS ('dbx_business_glossary_term' = 'Unrealized Value');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `valuation_adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Valuation Adjustment Amount');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `valuation_adjustment_reason` SET TAGS ('dbx_business_glossary_term' = 'Valuation Adjustment Reason');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'market_comparable|dcf|transaction_price|cost|other');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `valuation_source` SET TAGS ('dbx_business_glossary_term' = 'Valuation Source');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `valuation_source` SET TAGS ('dbx_value_regex' = 'gp_reported|independent_valuation|internal_estimate|audited');
ALTER TABLE `asset_management`.`privateequity`.`nav` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` SET TAGS ('dbx_subdomain' = 'performance_analytics');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `jcurve_projection_id` SET TAGS ('dbx_business_glossary_term' = 'J-Curve Projection Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Commitment Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `jcurve_approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `jcurve_approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `jcurve_approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `jcurve_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `jcurve_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `jcurve_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `assumed_carried_interest_rate` SET TAGS ('dbx_business_glossary_term' = 'Assumed Carried Interest Rate');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `assumed_management_fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Assumed Management Fee Rate');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `benchmark_cohort` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Cohort');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `breakeven_period_months` SET TAGS ('dbx_business_glossary_term' = 'Breakeven Period Months');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `capital_call_frequency` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Frequency');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `capital_call_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|irregular');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `catch_up_provision` SET TAGS ('dbx_business_glossary_term' = 'Catch-Up Provision');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `committed_capital_amount` SET TAGS ('dbx_business_glossary_term' = 'Committed Capital Amount');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `committed_capital_currency` SET TAGS ('dbx_business_glossary_term' = 'Committed Capital Currency');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `committed_capital_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `distribution_frequency` SET TAGS ('dbx_business_glossary_term' = 'Distribution Frequency');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `distribution_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|irregular');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `fund_term_years` SET TAGS ('dbx_business_glossary_term' = 'Fund Term Years');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `hurdle_rate` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `investment_period_years` SET TAGS ('dbx_business_glossary_term' = 'Investment Period Years');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `key_assumptions` SET TAGS ('dbx_business_glossary_term' = 'Key Assumptions');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `model_run_date` SET TAGS ('dbx_business_glossary_term' = 'Model Run Date');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'Model Version');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Projection Notes');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `peak_negative_nav_amount` SET TAGS ('dbx_business_glossary_term' = 'Peak Negative Net Asset Value (NAV) Amount');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `peak_negative_nav_period` SET TAGS ('dbx_business_glossary_term' = 'Peak Negative Net Asset Value (NAV) Period');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projected_dpi` SET TAGS ('dbx_business_glossary_term' = 'Projected Distributions to Paid-In (DPI)');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projected_final_nav` SET TAGS ('dbx_business_glossary_term' = 'Projected Final Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projected_gross_irr` SET TAGS ('dbx_business_glossary_term' = 'Projected Gross Internal Rate of Return (IRR)');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projected_moic` SET TAGS ('dbx_business_glossary_term' = 'Projected Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projected_net_irr` SET TAGS ('dbx_business_glossary_term' = 'Projected Net Internal Rate of Return (IRR)');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projected_rvpi` SET TAGS ('dbx_business_glossary_term' = 'Projected Residual Value to Paid-In (RVPI)');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projected_total_capital_called` SET TAGS ('dbx_business_glossary_term' = 'Projected Total Capital Called');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projected_total_distributions` SET TAGS ('dbx_business_glossary_term' = 'Projected Total Distributions');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projected_tvpi` SET TAGS ('dbx_business_glossary_term' = 'Projected Total Value to Paid-In (TVPI)');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projection_confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Projection Confidence Level');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projection_confidence_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projection_end_date` SET TAGS ('dbx_business_glossary_term' = 'Projection End Date');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projection_methodology` SET TAGS ('dbx_business_glossary_term' = 'Projection Methodology');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projection_name` SET TAGS ('dbx_business_glossary_term' = 'Projection Name');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projection_start_date` SET TAGS ('dbx_business_glossary_term' = 'Projection Start Date');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projection_status` SET TAGS ('dbx_business_glossary_term' = 'Projection Status');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projection_status` SET TAGS ('dbx_value_regex' = 'draft|approved|active|superseded|archived');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `projection_version` SET TAGS ('dbx_business_glossary_term' = 'Projection Version');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `scenario_type` SET TAGS ('dbx_business_glossary_term' = 'Scenario Type');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `scenario_type` SET TAGS ('dbx_value_regex' = 'base_case|optimistic|pessimistic|stress|custom');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `sensitivity_analysis_performed` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Analysis Performed');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `stress_test_scenario` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Scenario');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` SET TAGS ('dbx_subdomain' = 'fund_structure');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `portfolio_company_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Company Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `country_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Country Outlook Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `issuer_esg_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer Esg Rating Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `board_representation` SET TAGS ('dbx_business_glossary_term' = 'Board Representation');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `business_description` SET TAGS ('dbx_business_glossary_term' = 'Business Description');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `carbon_footprint_tonnes` SET TAGS ('dbx_business_glossary_term' = 'Carbon Footprint Tonnes');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `co_investors` SET TAGS ('dbx_business_glossary_term' = 'Co-Investors');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `company_name` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Company Legal Name');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `current_fair_value` SET TAGS ('dbx_business_glossary_term' = 'Current Fair Value');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `ebitda_latest` SET TAGS ('dbx_business_glossary_term' = 'Earnings Before Interest Taxes Depreciation and Amortization (EBITDA) Latest');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `employee_count` SET TAGS ('dbx_business_glossary_term' = 'Employee Count');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `enterprise_value` SET TAGS ('dbx_business_glossary_term' = 'Enterprise Value (EV)');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `esg_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Score');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `exit_date` SET TAGS ('dbx_business_glossary_term' = 'Exit Date');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `exit_type` SET TAGS ('dbx_business_glossary_term' = 'Exit Type');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `exit_type` SET TAGS ('dbx_value_regex' = 'ipo|trade_sale|secondary_sale|recapitalization|write_off');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `financials_as_of_date` SET TAGS ('dbx_business_glossary_term' = 'Financials As Of Date');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `fund_name` SET TAGS ('dbx_business_glossary_term' = 'Fund Name');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `gics_industry_code` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Industry Code');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `gics_industry_code` SET TAGS ('dbx_value_regex' = '^[0-9]{6}$');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `gics_industry_group_code` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Industry Group Code');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `gics_industry_group_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `gics_sector_code` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Sector Code');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `gics_sector_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2}$');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `gics_sub_industry_code` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Sub-Industry Code');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `gics_sub_industry_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `headquarters_city` SET TAGS ('dbx_business_glossary_term' = 'Headquarters City');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `headquarters_country` SET TAGS ('dbx_business_glossary_term' = 'Headquarters Country');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `headquarters_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `initial_investment_date` SET TAGS ('dbx_business_glossary_term' = 'Initial Investment Date');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `investment_committee_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `investment_stage` SET TAGS ('dbx_business_glossary_term' = 'Investment Stage');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `investment_stage` SET TAGS ('dbx_value_regex' = 'venture|growth|buyout|distressed|turnaround|expansion');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `investment_status` SET TAGS ('dbx_business_glossary_term' = 'Investment Status');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `investment_status` SET TAGS ('dbx_value_regex' = 'active|realized|written_off|under_review|pending_exit');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `investment_thesis` SET TAGS ('dbx_business_glossary_term' = 'Investment Thesis');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `investment_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Type');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `investment_type` SET TAGS ('dbx_value_regex' = 'direct|co_investment|fund_investment|secondary');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `irr` SET TAGS ('dbx_business_glossary_term' = 'Internal Rate of Return (IRR)');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `jurisdiction_of_incorporation` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction of Incorporation');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `jurisdiction_of_incorporation` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `key_risks` SET TAGS ('dbx_business_glossary_term' = 'Key Risks');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `lead_investor` SET TAGS ('dbx_business_glossary_term' = 'Lead Investor');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `moic` SET TAGS ('dbx_business_glossary_term' = 'Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `revenue_latest` SET TAGS ('dbx_business_glossary_term' = 'Revenue Latest');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `total_distributions_received` SET TAGS ('dbx_business_glossary_term' = 'Total Distributions Received');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `total_invested_capital` SET TAGS ('dbx_business_glossary_term' = 'Total Invested Capital');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ALTER COLUMN `website_url` SET TAGS ('dbx_business_glossary_term' = 'Website Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` SET TAGS ('dbx_subdomain' = 'fund_structure');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Entity Identifier');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `active_fund_count` SET TAGS ('dbx_business_glossary_term' = 'Active Fund Count');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `aum_as_of_date` SET TAGS ('dbx_business_glossary_term' = 'Assets Under Management (AUM) As-Of Date');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `aum_currency` SET TAGS ('dbx_business_glossary_term' = 'Assets Under Management (AUM) Currency');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `aum_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `average_fund_irr` SET TAGS ('dbx_business_glossary_term' = 'Average Fund Internal Rate of Return (IRR)');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `average_fund_moic` SET TAGS ('dbx_business_glossary_term' = 'Average Fund Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `domicile_country` SET TAGS ('dbx_business_glossary_term' = 'Domicile Country Code');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `domicile_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `domicile_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Domicile Jurisdiction');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `entity_type` SET TAGS ('dbx_business_glossary_term' = 'Entity Type');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `entity_type` SET TAGS ('dbx_value_regex' = 'limited_partnership|limited_liability_company|corporation|trust|other');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `fund_count` SET TAGS ('dbx_business_glossary_term' = 'Fund Count');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `gp_entity_status` SET TAGS ('dbx_business_glossary_term' = 'Entity Status');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `gp_entity_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|dissolved|under_review');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_business_glossary_term' = 'Headquarters Address');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `headquarters_city` SET TAGS ('dbx_business_glossary_term' = 'Headquarters City');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `headquarters_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Headquarters Postal Code');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `headquarters_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `headquarters_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Inception Date');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `investment_team_size` SET TAGS ('dbx_business_glossary_term' = 'Investment Team Size');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `key_investment_professionals` SET TAGS ('dbx_business_glossary_term' = 'Key Investment Professionals');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `kyc_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Completion Date');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `kyc_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Expiry Date');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `kyc_status` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Status');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `kyc_status` SET TAGS ('dbx_value_regex' = 'approved|pending|expired|rejected');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Name');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `ownership_structure` SET TAGS ('dbx_business_glossary_term' = 'Ownership Structure');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `ownership_structure` SET TAGS ('dbx_value_regex' = 'independent|captive|institutional_backed|publicly_traded|family_office');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `parent_organization` SET TAGS ('dbx_business_glossary_term' = 'Parent Organization');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `pri_signatory` SET TAGS ('dbx_business_glossary_term' = 'Principles for Responsible Investment (PRI) Signatory');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Email Address');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Name');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Phone Number');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `primary_regulator` SET TAGS ('dbx_business_glossary_term' = 'Primary Regulator');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `primary_strategy` SET TAGS ('dbx_business_glossary_term' = 'Primary Investment Strategy');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `primary_strategy` SET TAGS ('dbx_value_regex' = 'buyout|growth_equity|venture_capital|distressed|secondaries|fund_of_funds');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `registration_number` SET TAGS ('dbx_business_glossary_term' = 'Registration Number');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `regulatory_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Status');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `regulatory_status` SET TAGS ('dbx_value_regex' = 'registered|exempt|pending|non_compliant');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `relationship_end_date` SET TAGS ('dbx_business_glossary_term' = 'Relationship End Date');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `relationship_start_date` SET TAGS ('dbx_business_glossary_term' = 'Relationship Start Date');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|very_high');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `secondary_strategy` SET TAGS ('dbx_business_glossary_term' = 'Secondary Investment Strategy');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `short_name` SET TAGS ('dbx_business_glossary_term' = 'Short Name');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `target_geographies` SET TAGS ('dbx_business_glossary_term' = 'Target Geographies');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `target_sectors` SET TAGS ('dbx_business_glossary_term' = 'Target Sectors');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `total_aum` SET TAGS ('dbx_business_glossary_term' = 'Total Assets Under Management (AUM)');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `total_employee_count` SET TAGS ('dbx_business_glossary_term' = 'Total Employee Count');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `track_record_summary` SET TAGS ('dbx_business_glossary_term' = 'Track Record Summary');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ALTER COLUMN `website_url` SET TAGS ('dbx_business_glossary_term' = 'Website Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` SET TAGS ('dbx_subdomain' = 'performance_analytics');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `lp_advisory_committee_id` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Advisory Committee ID');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `lp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Lp Entity Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `pe_fund_id` SET TAGS ('dbx_business_glossary_term' = 'Private Equity (PE) Fund ID');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `alternate_member_name` SET TAGS ('dbx_business_glossary_term' = 'LPAC Alternate Member Name');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `alternate_member_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `alternate_member_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `appointment_authority` SET TAGS ('dbx_business_glossary_term' = 'LPAC Appointment Authority');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `appointment_date` SET TAGS ('dbx_business_glossary_term' = 'LPAC Appointment Date');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `committee_role` SET TAGS ('dbx_business_glossary_term' = 'LPAC Committee Role');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `committee_role` SET TAGS ('dbx_value_regex' = 'chair|vice_chair|member|secretary');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `compensation_amount` SET TAGS ('dbx_business_glossary_term' = 'LPAC Member Compensation Amount');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `compensation_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `compensation_currency` SET TAGS ('dbx_business_glossary_term' = 'LPAC Member Compensation Currency');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `compensation_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `compensation_currency` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `compensation_currency` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `confidentiality_agreement_date` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Agreement Signature Date');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `confidentiality_agreement_signed` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Agreement Signed Flag');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `conflict_disclosure_date` SET TAGS ('dbx_business_glossary_term' = 'Conflict of Interest Disclosure Date');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `conflict_of_interest_description` SET TAGS ('dbx_business_glossary_term' = 'Conflict of Interest Description');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `conflict_of_interest_description` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `conflict_of_interest_disclosed` SET TAGS ('dbx_business_glossary_term' = 'Conflict of Interest Disclosed Flag');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `contact_email` SET TAGS ('dbx_business_glossary_term' = 'LPAC Member Contact Email');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `contact_phone` SET TAGS ('dbx_business_glossary_term' = 'LPAC Member Contact Phone');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `expense_reimbursement_eligible` SET TAGS ('dbx_business_glossary_term' = 'LPAC Expense Reimbursement Eligible Flag');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `meeting_attendance_required` SET TAGS ('dbx_business_glossary_term' = 'LPAC Meeting Attendance Required Flag');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `member_name` SET TAGS ('dbx_business_glossary_term' = 'LPAC Member Name');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `member_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `member_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `membership_status` SET TAGS ('dbx_business_glossary_term' = 'LPAC Membership Status');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `membership_status` SET TAGS ('dbx_value_regex' = 'active|inactive|resigned|removed|term_expired');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `minimum_attendance_percentage` SET TAGS ('dbx_business_glossary_term' = 'LPAC Minimum Attendance Percentage');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'LPAC Membership Notes');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `removal_date` SET TAGS ('dbx_business_glossary_term' = 'LPAC Removal Date');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `removal_reason` SET TAGS ('dbx_business_glossary_term' = 'LPAC Removal Reason');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `renewal_eligible` SET TAGS ('dbx_business_glossary_term' = 'LPAC Term Renewal Eligible Flag');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `representation_basis` SET TAGS ('dbx_business_glossary_term' = 'LPAC Representation Basis');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `representation_basis` SET TAGS ('dbx_value_regex' = 'commitment_size|geographic|sector|founding_lp|rotating');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `resignation_date` SET TAGS ('dbx_business_glossary_term' = 'LPAC Resignation Date');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `seat_type` SET TAGS ('dbx_business_glossary_term' = 'LPAC Seat Type');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `seat_type` SET TAGS ('dbx_value_regex' = 'voting|observer|alternate|ex_officio');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `term_duration_years` SET TAGS ('dbx_business_glossary_term' = 'LPAC Term Duration in Years');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `term_end_date` SET TAGS ('dbx_business_glossary_term' = 'LPAC Term End Date');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `term_start_date` SET TAGS ('dbx_business_glossary_term' = 'LPAC Term Start Date');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `voting_rights` SET TAGS ('dbx_business_glossary_term' = 'LPAC Voting Rights Flag');
ALTER TABLE `asset_management`.`privateequity`.`lp_advisory_committee` ALTER COLUMN `voting_weight` SET TAGS ('dbx_business_glossary_term' = 'LPAC Voting Weight');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` SET TAGS ('dbx_subdomain' = 'capital_flows');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `capital_account_id` SET TAGS ('dbx_business_glossary_term' = 'Capital Account Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `fund_administrator_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Administrator Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Administrator Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `lp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Entity Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `pe_fund_id` SET TAGS ('dbx_business_glossary_term' = 'Private Equity (PE) Fund Identifier (ID)');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `account_number` SET TAGS ('dbx_business_glossary_term' = 'Capital Account Number');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `account_status` SET TAGS ('dbx_business_glossary_term' = 'Capital Account Status');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `account_status` SET TAGS ('dbx_value_regex' = 'active|suspended|closed|liquidated');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `carried_interest_allocation` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Allocation');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `catch_up_amount` SET TAGS ('dbx_business_glossary_term' = 'Catch-Up Amount');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `clawback_obligation` SET TAGS ('dbx_business_glossary_term' = 'Clawback Obligation');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `closing_balance` SET TAGS ('dbx_business_glossary_term' = 'Closing Balance');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Commitment Amount');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Commitment Currency Code');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `contributions_in_period` SET TAGS ('dbx_business_glossary_term' = 'Contributions in Period');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `cumulative_distributions` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Distributions');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `distributions_in_period` SET TAGS ('dbx_business_glossary_term' = 'Distributions in Period');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `dpi` SET TAGS ('dbx_business_glossary_term' = 'Distributions to Paid-In (DPI)');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `fx_rate_to_commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate to Commitment Currency');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `irr` SET TAGS ('dbx_business_glossary_term' = 'Internal Rate of Return (IRR)');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `is_final_statement` SET TAGS ('dbx_business_glossary_term' = 'Is Final Statement Flag');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `k1_issued_date` SET TAGS ('dbx_business_glossary_term' = 'Schedule K-1 Issued Date');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `management_fee_allocation` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Allocation');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `nav` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `net_income_allocation` SET TAGS ('dbx_business_glossary_term' = 'Net Income Allocation');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Capital Account Notes');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `opening_balance` SET TAGS ('dbx_business_glossary_term' = 'Opening Balance');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `other_expenses_allocation` SET TAGS ('dbx_business_glossary_term' = 'Other Expenses Allocation');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `paid_in_capital` SET TAGS ('dbx_business_glossary_term' = 'Paid-In Capital (PIC)');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Period End Date');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Period Start Date');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `preferred_return_earned` SET TAGS ('dbx_business_glossary_term' = 'Preferred Return Earned');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `preferred_return_threshold` SET TAGS ('dbx_business_glossary_term' = 'Preferred Return Threshold');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `recallable_distributions` SET TAGS ('dbx_business_glossary_term' = 'Recallable Distributions');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `reporting_currency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Currency Code');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `reporting_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `rvpi` SET TAGS ('dbx_business_glossary_term' = 'Residual Value to Paid-In (RVPI)');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `side_letter_terms` SET TAGS ('dbx_business_glossary_term' = 'Side Letter Terms');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `side_letter_terms` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `statement_date` SET TAGS ('dbx_business_glossary_term' = 'Statement Date');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `tax_basis` SET TAGS ('dbx_business_glossary_term' = 'Tax Basis');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `tax_basis` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `tvpi` SET TAGS ('dbx_business_glossary_term' = 'Total Value to Paid-In (TVPI)');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `unfunded_commitment` SET TAGS ('dbx_business_glossary_term' = 'Unfunded Commitment');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` SET TAGS ('dbx_subdomain' = 'capital_flows');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `management_fee_invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Invoice ID');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Private Equity (PE) Fund ID');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Entity ID');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `invoice_recipient_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice Recipient Entity ID');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending_review|approved|rejected|escalated');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Methodology');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `cost_center` SET TAGS ('dbx_business_glossary_term' = 'Cost Center');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `dispute_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Date');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Flag');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Due Date');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `fee_basis` SET TAGS ('dbx_business_glossary_term' = 'Fee Basis');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `fee_basis` SET TAGS ('dbx_value_regex' = 'committed_capital|invested_capital|nav|cost_basis|hybrid');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `fee_basis_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Basis Amount');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `fee_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Fee Period End Date');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `fee_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Fee Period Start Date');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Rate');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `gross_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Management Fee Amount');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `invoice_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Date');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `invoice_document_uri` SET TAGS ('dbx_business_glossary_term' = 'Invoice Document Uniform Resource Identifier (URI)');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Invoice Number');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `monitoring_fee_offset` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Fee Offset');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `net_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Management Fee Amount');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Invoice Notes');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `other_fee_offset` SET TAGS ('dbx_business_glossary_term' = 'Other Fee Offset');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `payment_reference` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'pending|paid|overdue|disputed|waived|cancelled');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `proration_factor` SET TAGS ('dbx_business_glossary_term' = 'Proration Factor');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Date');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `resolution_notes` SET TAGS ('dbx_business_glossary_term' = 'Resolution Notes');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System ID');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `total_fee_offset` SET TAGS ('dbx_business_glossary_term' = 'Total Fee Offset');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `transaction_fee_offset` SET TAGS ('dbx_business_glossary_term' = 'Transaction Fee Offset');
ALTER TABLE `asset_management`.`privateequity`.`management_fee_invoice` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` SET TAGS ('dbx_subdomain' = 'performance_analytics');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `privateequity_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Privateequity Benchmark Identifier');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `equity_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Identifier');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `approved_for_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Approved for Reporting Flag');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'Private Equity|Venture Capital|Buyout|Growth Equity|Mezzanine|Distressed');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `benchmark_code` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Code');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `benchmark_description` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Description');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `benchmark_name` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Name');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `benchmark_status` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Status');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `benchmark_status` SET TAGS ('dbx_value_regex' = 'Active|Discontinued|Under Review|Archived');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `benchmark_type` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Type');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `benchmark_type` SET TAGS ('dbx_value_regex' = 'Pooled IRR|Horizon IRR|PME|mPME|KS-PME|Direct Alpha');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Currency');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `data_lag_quarters` SET TAGS ('dbx_business_glossary_term' = 'Data Lag in Quarters');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `data_quality_rating` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Rating');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `data_quality_rating` SET TAGS ('dbx_value_regex' = 'High|Medium|Low');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `data_source_url` SET TAGS ('dbx_business_glossary_term' = 'Data Source Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `exclusion_criteria` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Criteria');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `family` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Family');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `fund_size_category` SET TAGS ('dbx_business_glossary_term' = 'Fund Size Category');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Inception Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `inclusion_criteria` SET TAGS ('dbx_business_glossary_term' = 'Inclusion Criteria');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `last_update_date` SET TAGS ('dbx_business_glossary_term' = 'Last Update Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `license_type` SET TAGS ('dbx_business_glossary_term' = 'License Type');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `license_type` SET TAGS ('dbx_value_regex' = 'Subscription|One-Time Purchase|Internal Use|Redistribution Allowed');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `net_or_gross` SET TAGS ('dbx_business_glossary_term' = 'Net or Gross Returns');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `net_or_gross` SET TAGS ('dbx_value_regex' = 'Net|Gross');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `number_of_funds` SET TAGS ('dbx_business_glossary_term' = 'Number of Funds in Benchmark');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `primary_use_case` SET TAGS ('dbx_business_glossary_term' = 'Primary Use Case');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `provider_name` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Provider Name');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `public_market_index` SET TAGS ('dbx_business_glossary_term' = 'Public Market Index');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `quartile_available_flag` SET TAGS ('dbx_business_glossary_term' = 'Quartile Data Available Flag');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `restatement_flag` SET TAGS ('dbx_business_glossary_term' = 'Restatement Flag');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `return_calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Return Calculation Method');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `sector_focus` SET TAGS ('dbx_business_glossary_term' = 'Sector Focus');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `strategy_focus` SET TAGS ('dbx_business_glossary_term' = 'Strategy Focus');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `survivorship_bias_adjusted_flag` SET TAGS ('dbx_business_glossary_term' = 'Survivorship Bias Adjusted Flag');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `update_frequency` SET TAGS ('dbx_business_glossary_term' = 'Update Frequency');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `update_frequency` SET TAGS ('dbx_value_regex' = 'Quarterly|Semi-Annual|Annual|Monthly');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `usage_restrictions` SET TAGS ('dbx_business_glossary_term' = 'Usage Restrictions');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ALTER COLUMN `weighting_methodology` SET TAGS ('dbx_business_glossary_term' = 'Weighting Methodology');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` SET TAGS ('dbx_subdomain' = 'fund_structure');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `fund_of_funds_allocation_id` SET TAGS ('dbx_business_glossary_term' = 'Fund of Funds (FoF) Allocation Identifier');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `fof_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Fund of Funds (FoF) Vehicle Identifier');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Fund of Funds (FoF) Manager Identifier');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Fund of Funds (FoF) Manager Identifier');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `underlying_pe_fund_id` SET TAGS ('dbx_business_glossary_term' = 'Underlying Private Equity (PE) Fund Identifier');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `allocation_currency` SET TAGS ('dbx_business_glossary_term' = 'Allocation Currency Code');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `allocation_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `allocation_date` SET TAGS ('dbx_business_glossary_term' = 'Allocation Date');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `allocation_number` SET TAGS ('dbx_business_glossary_term' = 'Allocation Reference Number');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `allocation_status` SET TAGS ('dbx_business_glossary_term' = 'Allocation Status');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `allocation_status` SET TAGS ('dbx_value_regex' = 'committed|funded|active|realized|terminated|suspended');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `allocation_type` SET TAGS ('dbx_business_glossary_term' = 'Allocation Type');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `allocation_type` SET TAGS ('dbx_value_regex' = 'primary|secondary|co_investment');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `carried_interest_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Rate Percentage (Carry)');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `dpi_multiple` SET TAGS ('dbx_business_glossary_term' = 'Distributions to Paid-In (DPI) Multiple');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `esg_classification` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Classification');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `final_close_date` SET TAGS ('dbx_business_glossary_term' = 'Final Close Date');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `first_close_date` SET TAGS ('dbx_business_glossary_term' = 'First Close Date');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `fof_total_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Fund of Funds (FoF) Total Commitment Amount');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `fund_term_years` SET TAGS ('dbx_business_glossary_term' = 'Fund Term Years');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Focus');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percentage (Preferred Return)');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `investment_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Period End Date');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `irr_percent` SET TAGS ('dbx_business_glossary_term' = 'Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `key_person_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Key Person Clause Flag');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `management_fee_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Rate Percentage');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `moic_multiple` SET TAGS ('dbx_business_glossary_term' = 'Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `most_favored_nation_flag` SET TAGS ('dbx_business_glossary_term' = 'Most Favored Nation (MFN) Flag');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `nav_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Amount');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Allocation Notes');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `paid_in_capital_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid-In Capital (PIC) Amount');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `pension_lp_interest_amount` SET TAGS ('dbx_business_glossary_term' = 'Pension Limited Partner (LP) Interest Amount');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `pension_lp_ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Pension Limited Partner (LP) Ownership Percentage');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `remaining_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Remaining Commitment Amount (Dry Powder)');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `reporting_currency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Currency Code');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `reporting_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `rvpi_multiple` SET TAGS ('dbx_business_glossary_term' = 'Residual Value to Paid-In (RVPI) Multiple');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `sector_focus` SET TAGS ('dbx_business_glossary_term' = 'Sector Focus');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `side_letter_flag` SET TAGS ('dbx_business_glossary_term' = 'Side Letter Flag');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `total_distributions_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Distributions Amount');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `tvpi_multiple` SET TAGS ('dbx_business_glossary_term' = 'Total Value to Paid-In (TVPI) Multiple');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `waterfall_structure` SET TAGS ('dbx_business_glossary_term' = 'Waterfall Structure Type');
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ALTER COLUMN `waterfall_structure` SET TAGS ('dbx_value_regex' = 'european|american|deal_by_deal');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` SET TAGS ('dbx_subdomain' = 'capital_flows');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `privateequity_cash_flow_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Identifier');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Commitment ID');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund ID');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Entity Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `portfolio_company_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Company ID');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `base_currency_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Amount');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `carried_interest_amount` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Amount');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `cash_flow_status` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Status');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `cash_flow_status` SET TAGS ('dbx_value_regex' = 'pending|settled|cancelled|defaulted|partially_settled');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `cash_flow_type` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Type');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `default_interest_accrued` SET TAGS ('dbx_business_glossary_term' = 'Default Interest Accrued');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `default_interest_rate` SET TAGS ('dbx_business_glossary_term' = 'Default Interest Rate');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `document_url` SET TAGS ('dbx_business_glossary_term' = 'Document Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Due Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `excuse_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Excuse Approval Status');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `excuse_approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|denied|not_applicable');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `excuse_request_flag` SET TAGS ('dbx_business_glossary_term' = 'Excuse Request Flag');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `excuse_request_reason` SET TAGS ('dbx_business_glossary_term' = 'Excuse Request Reason');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `fund_expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Fund Expense Amount');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Amount');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `investment_amount` SET TAGS ('dbx_business_glossary_term' = 'Investment Amount');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `lp_acknowledgement_date` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Acknowledgement Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `lp_acknowledgement_flag` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Acknowledgement Flag');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `management_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Amount');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Amount');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `notice_date` SET TAGS ('dbx_business_glossary_term' = 'Notice Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `notice_method` SET TAGS ('dbx_business_glossary_term' = 'Notice Method');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `notice_method` SET TAGS ('dbx_value_regex' = 'email|postal_mail|electronic_portal|fax|courier');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `organizational_expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Organizational Expense Amount');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|ach|check|internal_transfer');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `preferred_return_amount` SET TAGS ('dbx_business_glossary_term' = 'Preferred Return Amount');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `purpose` SET TAGS ('dbx_business_glossary_term' = 'Cash Flow Purpose');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `recallable_amount` SET TAGS ('dbx_business_glossary_term' = 'Recallable Amount');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `recallable_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Recallable Expiry Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `recallable_flag` SET TAGS ('dbx_business_glossary_term' = 'Recallable Flag');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `settlement_account_number` SET TAGS ('dbx_business_glossary_term' = 'Settlement Account Number');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `settlement_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `settlement_bank_bic` SET TAGS ('dbx_business_glossary_term' = 'Settlement Bank Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `settlement_bank_bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `settlement_bank_name` SET TAGS ('dbx_business_glossary_term' = 'Settlement Bank Name');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `transaction_number` SET TAGS ('dbx_business_glossary_term' = 'Transaction Number');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Amount');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` SET TAGS ('dbx_subdomain' = 'performance_analytics');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `value_creation_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Value Creation Plan ID');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `coinvestment_id` SET TAGS ('dbx_business_glossary_term' = 'Coinvestment Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund ID');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `investment_id` SET TAGS ('dbx_business_glossary_term' = 'Investment ID');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `portfolio_company_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Company ID');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `actual_cost_reduction_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Cost Reduction Amount');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `actual_ebitda_improvement_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual EBITDA Improvement Amount');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `actual_revenue_growth_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Revenue Growth Amount');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `baseline_date` SET TAGS ('dbx_business_glossary_term' = 'Baseline Date');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `baseline_ebitda_amount` SET TAGS ('dbx_business_glossary_term' = 'Baseline EBITDA Amount');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `baseline_revenue_amount` SET TAGS ('dbx_business_glossary_term' = 'Baseline Revenue Amount');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `board_reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Board Reporting Frequency');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `board_reporting_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annually|annually|ad_hoc');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `esg_impact_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Impact Flag');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `esg_improvement_description` SET TAGS ('dbx_business_glossary_term' = 'ESG Improvement Description');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `investment_committee_memo_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Memo Reference');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `investment_thesis_alignment` SET TAGS ('dbx_business_glossary_term' = 'Investment Thesis Alignment');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `key_initiatives` SET TAGS ('dbx_business_glossary_term' = 'Key Initiatives');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `key_risks` SET TAGS ('dbx_business_glossary_term' = 'Key Risks');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `mitigation_actions` SET TAGS ('dbx_business_glossary_term' = 'Mitigation Actions');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `plan_actual_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Plan Actual Completion Date');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `plan_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Plan Approval Date');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `plan_currency` SET TAGS ('dbx_business_glossary_term' = 'Plan Currency');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `plan_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `plan_description` SET TAGS ('dbx_business_glossary_term' = 'Plan Description');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `plan_document_uri` SET TAGS ('dbx_business_glossary_term' = 'Plan Document Uniform Resource Identifier (URI)');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `plan_name` SET TAGS ('dbx_business_glossary_term' = 'Value Creation Plan Name');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `plan_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Plan Reference Number');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `plan_start_date` SET TAGS ('dbx_business_glossary_term' = 'Plan Start Date');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `plan_status` SET TAGS ('dbx_business_glossary_term' = 'Plan Status');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `plan_status` SET TAGS ('dbx_value_regex' = 'draft|approved|active|on_hold|completed|cancelled');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `plan_target_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Plan Target Completion Date');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `portfolio_company_ceo_name` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Company Chief Executive Officer (CEO) Name');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `progress_percent` SET TAGS ('dbx_business_glossary_term' = 'Progress Percentage');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `responsible_partner_email` SET TAGS ('dbx_business_glossary_term' = 'Responsible Partner Email');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `responsible_partner_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `responsible_partner_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `responsible_partner_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `responsible_partner_name` SET TAGS ('dbx_business_glossary_term' = 'Responsible Partner Name');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `risk_assessment` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `risk_assessment` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `target_cost_reduction_amount` SET TAGS ('dbx_business_glossary_term' = 'Target Cost Reduction Amount');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `target_ebitda_improvement_amount` SET TAGS ('dbx_business_glossary_term' = 'Target Earnings Before Interest Taxes Depreciation and Amortization (EBITDA) Improvement Amount');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `target_ebitda_improvement_percent` SET TAGS ('dbx_business_glossary_term' = 'Target EBITDA Improvement Percentage');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `target_irr_percent` SET TAGS ('dbx_business_glossary_term' = 'Target Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `target_moic_multiple` SET TAGS ('dbx_business_glossary_term' = 'Target Multiple on Invested Capital (MOIC) Multiple');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `target_revenue_growth_amount` SET TAGS ('dbx_business_glossary_term' = 'Target Revenue Growth Amount');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `target_revenue_growth_percent` SET TAGS ('dbx_business_glossary_term' = 'Target Revenue Growth Percentage');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `value_creation_theme` SET TAGS ('dbx_business_glossary_term' = 'Value Creation Theme');
ALTER TABLE `asset_management`.`privateequity`.`value_creation_plan` ALTER COLUMN `value_creation_theme` SET TAGS ('dbx_value_regex' = 'operational_efficiency|revenue_growth|margin_expansion|cost_reduction|esg_improvement|management_change');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` SET TAGS ('dbx_subdomain' = 'performance_analytics');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `gp_report_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Report Identifier');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `audit_opinion` SET TAGS ('dbx_business_glossary_term' = 'Audit Opinion');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `audit_opinion` SET TAGS ('dbx_value_regex' = 'unqualified|qualified|adverse|disclaimer');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `auditor_name` SET TAGS ('dbx_business_glossary_term' = 'Auditor Name');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `carried_interest_accrued` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Accrued');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `dpi_multiple` SET TAGS ('dbx_business_glossary_term' = 'Distributions to Paid-In (DPI) Multiple');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `dry_powder` SET TAGS ('dbx_business_glossary_term' = 'Dry Powder');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Report Due Date');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `esg_metrics_included_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Metrics Included Flag');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `esg_summary` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Summary');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `fund_expenses` SET TAGS ('dbx_business_glossary_term' = 'Fund Expenses');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `fund_nav` SET TAGS ('dbx_business_glossary_term' = 'Fund Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `fund_nav_currency` SET TAGS ('dbx_business_glossary_term' = 'Fund Net Asset Value (NAV) Currency');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `fund_nav_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `gp_contact_email` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Contact Email');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `gp_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `gp_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `gp_contact_name` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Contact Name');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `gp_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `gp_contact_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `gp_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Contact Phone');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `gp_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `irr_percent` SET TAGS ('dbx_business_glossary_term' = 'Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `key_person_event_description` SET TAGS ('dbx_business_glossary_term' = 'Key Person Event Description');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `key_person_event_flag` SET TAGS ('dbx_business_glossary_term' = 'Key Person Event Flag');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `lp_distributions` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Distributions');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `lp_dry_powder` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Dry Powder');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `lp_nav` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `lp_nav_currency` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Net Asset Value (NAV) Currency');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `lp_nav_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `lp_paid_in_capital` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Paid-In Capital (PIC)');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `management_fees_paid` SET TAGS ('dbx_business_glossary_term' = 'Management Fees Paid');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `new_investments_amount` SET TAGS ('dbx_business_glossary_term' = 'New Investments Amount');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `new_investments_count` SET TAGS ('dbx_business_glossary_term' = 'New Investments Count');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `portfolio_company_count` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Company Count');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `realized_exits_count` SET TAGS ('dbx_business_glossary_term' = 'Realized Exits Count');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `realized_proceeds_amount` SET TAGS ('dbx_business_glossary_term' = 'Realized Proceeds Amount');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `receipt_date` SET TAGS ('dbx_business_glossary_term' = 'Receipt Date');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `report_date` SET TAGS ('dbx_business_glossary_term' = 'Report Date');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `report_document_url` SET TAGS ('dbx_business_glossary_term' = 'Report Document Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `report_number` SET TAGS ('dbx_business_glossary_term' = 'Report Number');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `report_status` SET TAGS ('dbx_business_glossary_term' = 'Report Status');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `report_status` SET TAGS ('dbx_value_regex' = 'draft|final|amended|superseded');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `report_type` SET TAGS ('dbx_business_glossary_term' = 'Report Type');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `report_type` SET TAGS ('dbx_value_regex' = 'quarterly|annual|audited|special|interim');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `rvpi_multiple` SET TAGS ('dbx_business_glossary_term' = 'Residual Value to Paid-In (RVPI) Multiple');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `total_distributions` SET TAGS ('dbx_business_glossary_term' = 'Total Distributions');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `total_paid_in_capital` SET TAGS ('dbx_business_glossary_term' = 'Total Paid-In Capital (PIC)');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `tvpi_multiple` SET TAGS ('dbx_business_glossary_term' = 'Total Value to Paid-In (TVPI) Multiple');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `unrealized_value` SET TAGS ('dbx_business_glossary_term' = 'Unrealized Value');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`privateequity`.`gp_report` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Valuation Methodology');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_coverage` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_coverage` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_coverage` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_coverage` SET TAGS ('dbx_subdomain' = 'performance_analytics');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_coverage` SET TAGS ('dbx_association_edges' = 'privateequity.fund,research.report');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_coverage` ALTER COLUMN `privateequity_coverage_date` SET TAGS ('dbx_business_glossary_term' = 'Coverage Date');
ALTER TABLE `asset_management`.`privateequity`.`privateequity_coverage` ALTER COLUMN `relevance_score` SET TAGS ('dbx_business_glossary_term' = 'Research Relevance Score');
ALTER TABLE `asset_management`.`privateequity`.`fof_vehicle` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`privateequity`.`fof_vehicle` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`fof_vehicle` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`fof_vehicle` SET TAGS ('dbx_subdomain' = 'fund_structure');
ALTER TABLE `asset_management`.`privateequity`.`fof_vehicle` ALTER COLUMN `fof_vehicle_id` SET TAGS ('dbx_business_glossary_term' = 'Fof Vehicle Identifier');
ALTER TABLE `asset_management`.`privateequity`.`fof_vehicle` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Entity Id (Foreign Key)');
ALTER TABLE `asset_management`.`privateequity`.`fof_vehicle` ALTER COLUMN `carried_interest_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`fof_vehicle` ALTER COLUMN `management_fee_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` SET TAGS ('dbx_domain' = 'privateequity');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` SET TAGS ('dbx_subdomain' = 'fund_structure');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `lp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Lp Entity Identifier');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `registered_address_line_1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `registered_address_line_1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `registered_address_line_2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `registered_address_line_2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `registered_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `registered_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `registered_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `registered_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`privateequity`.`lp_entity` ALTER COLUMN `total_assets_under_management` SET TAGS ('dbx_confidential' = 'true');
