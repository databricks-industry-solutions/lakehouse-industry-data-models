-- Schema for Domain: fee | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:26

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`fee` COMMENT 'Domain for fee administration and carried interest management across all investment structures and external manager mandates. Owns management fee calculations, carried interest waterfall computations, hurdle rate tracking, clawback provisions, GP fee';
ALTER SCHEMA `asset_management`.`fee` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `asset_management`.`fee` SET TAGS ('dbx_domain' = 'fee');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`fee`.`management_fee` (
    `management_fee_id` BIGINT COMMENT 'Unique identifier for the management fee arrangement record.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the General Partner (GP) or external manager entity receiving the management fee.',
    `gp_gp_entity_id` BIGINT COMMENT 'Reference to the General Partner (GP) or external manager entity receiving the management fee.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the external manager mandate or internal investment structure to which this management fee arrangement applies.',
    `approval_date` DATE COMMENT 'The date on which the management fee arrangement was formally approved by the Investment Committee (IC) or authorized governance body.',
    `approved_by` STRING COMMENT 'Name or identifier of the Investment Committee (IC) member or governance authority who approved the management fee arrangement.',
    `base_fee_rate` DECIMAL(10,6) COMMENT 'The primary management fee rate expressed as a decimal percentage (e.g., 0.015000 for 1.5% per annum) applicable to the fee basis.',
    `benchmark_index_code` STRING COMMENT 'The market benchmark index code (e.g., MSCI World, S&P 500) used for performance comparison and potential performance-based fee adjustments.',
    `calculation_frequency` STRING COMMENT 'The frequency at which the management fee is calculated and accrued, as specified in the Limited Partnership Agreement (LPA) or mandate documentation.. Valid values are `monthly|quarterly|semi_annually|annually|on_demand`',
    `catch_up_provision` STRING COMMENT 'Defines whether the General Partner (GP) is entitled to a catch-up allocation of profits after the hurdle rate is met, allowing the GP to reach its full carried interest percentage.. Valid values are `none|full_catch_up|partial_catch_up`',
    `clawback_provision_flag` BOOLEAN COMMENT 'Indicates whether the Limited Partnership Agreement (LPA) includes a clawback provision requiring the General Partner (GP) to return excess carried interest or fees if final fund performance falls below agreed thresholds.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this management fee arrangement record was first created in the system.',
    `effective_end_date` DATE COMMENT 'The date on which this management fee arrangement terminates or is superseded by a new arrangement. Null indicates an open-ended arrangement.',
    `effective_start_date` DATE COMMENT 'The date on which this management fee arrangement becomes effective and fee calculations commence.',
    `fee_arrangement_code` STRING COMMENT 'Unique business identifier for the management fee arrangement, typically referenced in Limited Partnership Agreement (LPA) or Investment Management Agreement (IMA).. Valid values are `^[A-Z0-9]{6,20}$`',
    `fee_arrangement_name` STRING COMMENT 'Descriptive name of the management fee arrangement for business user identification and reporting purposes.',
    `fee_arrangement_status` STRING COMMENT 'Current lifecycle status of the management fee arrangement, indicating whether it is actively in force, suspended, terminated, or under review.. Valid values are `active|suspended|terminated|pending_approval|under_review|amended`',
    `fee_basis` STRING COMMENT 'The calculation basis for the management fee, defining whether it is computed as a percentage of Assets Under Management (AUM), committed capital, Net Asset Value (NAV), or as a flat amount.. Valid values are `aum_percentage|committed_capital_percentage|nav_percentage|flat_fee|tiered_schedule|hybrid`',
    `fee_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the management fee is denominated and paid.. Valid values are `^[A-Z]{3}$`',
    `fee_offset_provision` STRING COMMENT 'Defines whether and how transaction fees, monitoring fees, or other ancillary fees paid by portfolio companies are offset against the management fee payable to the General Partner (GP).. Valid values are `none|full_offset|partial_offset|rebate_required`',
    `fee_rate_unit` STRING COMMENT 'The unit of measure and time period for the fee rate, clarifying whether the rate is annualized, quarterly, monthly, or a one-time flat amount.. Valid values are `percent_per_annum|percent_per_quarter|percent_per_month|basis_points_per_annum|flat_amount`',
    `fee_transparency_disclosure_flag` BOOLEAN COMMENT 'Indicates whether this management fee arrangement is subject to enhanced fee transparency disclosure requirements under regulatory frameworks such as Sustainable Finance Disclosure Regulation (SFDR) or MiFID II.',
    `fee_type` STRING COMMENT 'Classification of the fee arrangement by its purpose and structure within the investment mandate.. Valid values are `management_fee|advisory_fee|administration_fee|performance_fee|transaction_fee|monitoring_fee`',
    `fee_waiver_conditions` STRING COMMENT 'Textual description of specific conditions under which management fees may be waived, reduced, or deferred, such as fund underperformance or capital call delays.',
    `hurdle_rate` DECIMAL(10,6) COMMENT 'The preferred return threshold (expressed as a decimal percentage) that must be achieved before performance-based fee components or carried interest become payable.',
    `internal_cost_center_code` STRING COMMENT 'The internal General Ledger (GL) cost center or account code to which management fee expenses are allocated for financial accounting and budgeting purposes.. Valid values are `^[A-Z0-9]{4,12}$`',
    `investment_period_flag` BOOLEAN COMMENT 'Indicates whether the fund is currently in its investment period, during which management fees are typically calculated on committed capital rather than invested capital.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The date and time when this management fee arrangement record was most recently updated or amended.',
    `lpa_reference_section` STRING COMMENT 'The specific section, article, or clause reference within the Limited Partnership Agreement (LPA) or Investment Management Agreement (IMA) that governs this management fee arrangement.',
    `maximum_fee_amount` DECIMAL(18,2) COMMENT 'The contractual maximum management fee amount per period, capping the fee regardless of asset value growth.',
    `minimum_fee_amount` DECIMAL(18,2) COMMENT 'The contractual minimum management fee amount per period, ensuring the General Partner (GP) receives at least this amount regardless of asset value fluctuations.',
    `modified_by_user` STRING COMMENT 'Identifier of the user or system process that last modified this management fee arrangement record, supporting audit trail and data lineage requirements.',
    `most_favored_nation_clause` BOOLEAN COMMENT 'Indicates whether the fee arrangement includes a Most Favored Nation (MFN) clause ensuring this Limited Partner (LP) receives fee terms no less favorable than those granted to other LPs in the same fund.',
    `notes` STRING COMMENT 'Free-text field for additional contextual information, special conditions, or clarifications regarding the management fee arrangement not captured in structured fields.',
    `offset_percentage` DECIMAL(5,2) COMMENT 'The percentage of ancillary fees (transaction, monitoring, advisory) that must be rebated or offset against the management fee, typically ranging from 50% to 100%.',
    `payment_frequency` STRING COMMENT 'The frequency at which the calculated management fee is invoiced and paid to the General Partner (GP) or external manager.. Valid values are `monthly|quarterly|semi_annually|annually|on_demand`',
    `payment_timing` STRING COMMENT 'Specifies whether the management fee is paid in advance of the period, in arrears after the period, or triggered by specific capital events.. Valid values are `in_advance|in_arrears|on_capital_call|on_distribution`',
    `performance_fee_linkage_flag` BOOLEAN COMMENT 'Indicates whether the management fee arrangement is linked to or adjusted based on investment performance relative to benchmarks or absolute return targets.',
    `post_investment_period_basis` STRING COMMENT 'The fee calculation basis that applies after the investment period ends, often shifting from committed capital to invested capital or Net Asset Value (NAV).. Valid values are `invested_capital|nav|cost_basis|reduced_rate`',
    `post_investment_period_rate` DECIMAL(10,6) COMMENT 'The reduced management fee rate that applies after the investment period concludes, typically lower than the base rate during the investment period.',
    `regulatory_reporting_category` STRING COMMENT 'Classification of the management fee for regulatory cost disclosure and reporting purposes under frameworks such as MiFID II and SFDR.. Valid values are `ongoing_charges|transaction_costs|performance_fees|ancillary_costs|not_applicable`',
    `termination_notice_period_days` BIGINT COMMENT 'The number of days advance notice required to terminate or modify the management fee arrangement, as specified in the mandate or Limited Partnership Agreement (LPA).',
    `tiered_schedule_flag` BOOLEAN COMMENT 'Indicates whether the management fee arrangement uses a tiered rate schedule with different rates applying to different asset value thresholds.',
    `version_number` BIGINT COMMENT 'Sequential version number tracking amendments and revisions to the management fee arrangement over its lifecycle, supporting historical analysis and audit compliance.',
    CONSTRAINT pk_management_fee PRIMARY KEY(`management_fee_id`)
) COMMENT 'Master record defining the management fee arrangement for each external manager mandate or internal investment structure. Captures the fee basis (AUM percentage, flat fee, tiered), applicable rate schedule, fee calculation frequency (monthly, quarterly';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`carried_interest` (
    `carried_interest_id` BIGINT COMMENT 'Unique identifier for the carried interest arrangement. Primary key.',
    `fund_id` BIGINT COMMENT 'Reference to the fund or investment vehicle to which this carried interest arrangement applies.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the General Partner or external manager entity entitled to receive carried interest.',
    `valuation_cycle_id` BIGINT COMMENT 'Foreign key linking to valuation.cycle. Business justification: Carried interest calculations depend on fund valuations to determine IRR/MOIC thresholds. Pension funds must audit carry distributions against specific valuation cycles for fiduciary',
    `accrued_carry_amount` DECIMAL(18,2) COMMENT 'Total amount of carried interest accrued to date under this arrangement, in the arrangement currency.',
    `approval_date` DATE COMMENT 'Date on which this carried interest arrangement was approved by the Investment Committee or governing body.',
    `approved_by` STRING COMMENT 'Name or identifier of the Investment Committee member or authority who approved this carried interest arrangement.',
    `arrangement_name` STRING COMMENT 'Business name or label for this carried interest arrangement for identification and reporting purposes.',
    `arrangement_type` STRING COMMENT 'Classification of the carried interest structure: whole fund waterfall, deal-by-deal, hybrid, tiered, European style, or American style.. Valid values are `whole_fund|deal_by_deal|hybrid|tiered|european|american`',
    `asset_class` STRING COMMENT 'Asset class to which this carried interest arrangement applies: private equity, infrastructure, real estate, natural resources, or credit.. Valid values are `private_equity|infrastructure|real_estate|natural_resources|credit`',
    `benchmark_irr` DECIMAL(10,6) COMMENT 'Benchmark IRR used for performance comparison and carried interest eligibility assessment, expressed as a decimal.',
    `calculation_basis` STRING COMMENT 'Basis for calculating carried interest: realized gains only, unrealized gains included, total value, IRR-based, or MOIC-based.. Valid values are `realized_gains|unrealized_gains|total_value|irr_based|moic_based`',
    `calculation_frequency` STRING COMMENT 'Frequency at which carried interest is calculated: daily, monthly, quarterly, semi-annual, annual, or on specific events.. Valid values are `daily|monthly|quarterly|semi_annual|annual|on_event`',
    `carried_interest_status` STRING COMMENT 'Current lifecycle status of the carried interest arrangement: active, suspended, terminated, pending approval, or under review.. Valid values are `active|suspended|terminated|pending|under_review`',
    `carry_rate` DECIMAL(10,6) COMMENT 'Percentage of profits above the hurdle rate that the GP is entitled to receive as carried interest, expressed as a decimal (e.g., 0.20 for 20%).',
    `catchup_cap` DECIMAL(10,6) COMMENT 'Maximum percentage of total profits that can be allocated during the catch-up phase, expressed as a decimal.',
    `catchup_rate` DECIMAL(10,6) COMMENT 'Percentage of profits allocated to the GP after the hurdle is met and before the final carry split, allowing GP to catch up to their target carry percentage.',
    `clawback_cap_amount` DECIMAL(18,2) COMMENT 'Maximum amount in base currency that can be clawed back from the GP under the clawback provision.',
    `clawback_provision` BOOLEAN COMMENT 'Indicates whether a clawback provision exists requiring the GP to return excess carried interest if final fund performance falls below the hurdle.',
    `clawback_reserve_amount` DECIMAL(18,2) COMMENT 'Amount held in reserve to cover potential clawback obligations, in the arrangement currency.',
    `clawback_type` STRING COMMENT 'Type of clawback provision: full clawback of all excess carry, partial clawback with limitations, or none.. Valid values are `full|partial|none`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this carried interest arrangement record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which carried interest amounts are denominated and calculated.. Valid values are `^[A-Z]{3}$`',
    `distributed_carry_amount` DECIMAL(18,2) COMMENT 'Total amount of carried interest distributed to the GP to date under this arrangement, in the arrangement currency.',
    `distribution_timing` STRING COMMENT 'Timing of carried interest distributions to the GP: on asset realization, on LP distributions, at fund termination, quarterly, or annual.. Valid values are `on_realization|on_distribution|at_fund_termination|quarterly|annual`',
    `effective_date` DATE COMMENT 'Date on which this carried interest arrangement becomes effective and binding.',
    `fee_offset_percentage` DECIMAL(10,6) COMMENT 'Percentage of management fees that are offset against carried interest, expressed as a decimal (e.g., 1.00 for 100% offset).',
    `fee_offset_provision` BOOLEAN COMMENT 'Indicates whether management fees paid by the fund are offset against carried interest distributions to the GP.',
    `gp_commitment_amount` DECIMAL(18,2) COMMENT 'Amount of capital committed by the GP to the fund, which may affect carried interest entitlement, in the arrangement currency.',
    `gp_commitment_percentage` DECIMAL(10,6) COMMENT 'Percentage of total fund commitments contributed by the GP, expressed as a decimal.',
    `hurdle_rate` DECIMAL(10,6) COMMENT 'Minimum preferred return threshold that must be achieved before the GP is entitled to carried interest, expressed as a decimal (e.g., 0.08 for 8%).',
    `hurdle_type` STRING COMMENT 'Type of hurdle rate: hard hurdle (carry only on profits above hurdle), soft hurdle (carry on all profits once hurdle is met), or none.. Valid values are `hard|soft|none`',
    `last_calculation_date` DATE COMMENT 'Date on which the carried interest was most recently calculated and updated.',
    `modified_by` STRING COMMENT 'User identifier or system account that last modified this carried interest arrangement record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this carried interest arrangement record was last modified in the system.',
    `next_calculation_date` DATE COMMENT 'Scheduled date for the next carried interest calculation and update.',
    `notes` STRING COMMENT 'Free-text notes capturing additional details, special provisions, or amendments to the carried interest arrangement.',
    `outstanding_carry_amount` DECIMAL(18,2) COMMENT 'Amount of carried interest accrued but not yet distributed to the GP, in the arrangement currency.',
    `performance_threshold_moic` DECIMAL(10,4) COMMENT 'Minimum MOIC threshold that must be achieved for carried interest to be payable, expressed as a multiple (e.g., 1.5 for 1.5x).',
    `preferred_return_compounding` STRING COMMENT 'Method for compounding the preferred return (hurdle rate): simple interest, compound annual, compound quarterly, or compound monthly.. Valid values are `simple|compound_annual|compound_quarterly|compound_monthly`',
    `regulatory_classification` STRING COMMENT 'Regulatory classification of the carried interest arrangement under applicable securities and investment regulations.',
    `tax_treatment_code` STRING COMMENT 'Code indicating the tax treatment of carried interest distributions for the GP under applicable tax regulations.',
    `termination_date` DATE COMMENT 'Date on which this carried interest arrangement terminates or expires, typically aligned with fund liquidation.',
    `transaction_fee_treatment` STRING COMMENT 'Treatment of transaction fees earned by the GP: retained by GP, shared with LPs, offset against carry, or offset against management fees.. Valid values are `retained_by_gp|shared_with_lp|offset_against_carry|offset_against_mgmt_fee`',
    `vintage_year` BIGINT COMMENT 'Year in which the fund associated with this carried interest arrangement held its initial closing and began investing.',
    `waterfall_tier_count` BIGINT COMMENT 'Number of tiers in the carried interest waterfall structure for tiered arrangements.',
    CONSTRAINT pk_carried_interest PRIMARY KEY(`carried_interest_id`)
) COMMENT 'Master record for each carried interest arrangement negotiated with a GP/external manager across PE, infrastructure, real estate, and natural resources structures.';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`waterfall` (
    `waterfall_id` BIGINT COMMENT 'Unique identifier for the distribution waterfall structure.',
    `fund_id` BIGINT COMMENT 'Reference to the private markets fund or co-investment vehicle to which this waterfall applies.',
    `amendment_version` BIGINT COMMENT 'Version number tracking amendments to the waterfall structure, incremented with each modification to the Limited Partnership Agreement (LPA).',
    `approval_date` DATE COMMENT 'Date on which the Investment Committee (IC) or Limited Partner Advisory Committee approved this waterfall structure.',
    `approved_by` STRING COMMENT 'Name or identifier of the Investment Committee (IC) member or governance body that approved this waterfall structure.',
    `calculation_basis` STRING COMMENT 'The capital base used for waterfall calculations: Paid-In Capital (PIC), Net Asset Value (NAV), invested capital, or committed capital.. Valid values are `paid_in_capital|net_asset_value|invested_capital|committed_capital`',
    `carry_percentage` DECIMAL(10,6) COMMENT 'Percentage of profits allocated to the General Partner (GP) in this tier after hurdle conditions are met, expressed as a decimal (e.g., 0.20 for 20% carry).',
    `catch_up_percentage` DECIMAL(10,6) COMMENT 'Percentage of distributions allocated to the GP during the catch-up tier to bring GP participation to the target carry level, expressed as a decimal (e.g., 1.00 for 100% catch-up).',
    `clawback_cap_amount` DECIMAL(18,2) COMMENT 'Maximum monetary amount subject to clawback from the GP, limiting the GPs repayment obligation under the clawback provision.',
    `clawback_provision_flag` BOOLEAN COMMENT 'Indicates whether this waterfall tier includes a clawback provision requiring the GP to return excess carry if final fund performance falls below hurdle thresholds.',
    `compounding_frequency` STRING COMMENT 'Frequency at which the hurdle rate is compounded for preferred return calculations: annual, semi-annual, quarterly, or none for simple interest.. Valid values are `annual|semi_annual|quarterly|none`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this waterfall record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which waterfall calculations and distributions are denominated.. Valid values are `^[A-Z]{3}$`',
    `distribution_priority` STRING COMMENT 'Priority mechanism for allocating distributions among investors within a tier: pro-rata by commitment, pari passu (equal footing), sequential by seniority, or custom allocation.. Valid values are `pro_rata|pari_passu|sequential|custom`',
    `distribution_split_gp` DECIMAL(10,6) COMMENT 'Proportion of distributions allocated to the General Partner in this tier, expressed as a decimal (e.g., 0.20 for 20% to GP).',
    `distribution_split_lp` DECIMAL(10,6) COMMENT 'Proportion of distributions allocated to Limited Partners in this tier, expressed as a decimal (e.g., 0.80 for 80% to LPs).',
    `effective_date` DATE COMMENT 'Date on which this waterfall structure becomes effective and begins governing distribution calculations.',
    `gp_commitment_percentage` DECIMAL(10,6) COMMENT 'Percentage of total fund commitments contributed by the GP, affecting carry calculations and alignment of interest, expressed as a decimal.',
    `hurdle_rate` DECIMAL(10,6) COMMENT 'Preferred return threshold percentage that Limited Partners (LPs) must achieve before General Partner (GP) carry is earned in this tier, expressed as a decimal (e.g., 0.08 for 8%).',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this waterfall record was last updated, tracking the most recent change to any field.',
    `lookback_period_years` BIGINT COMMENT 'Number of years over which clawback calculations are performed, determining the historical window for assessing GP carry obligations.',
    `lpa_reference_section` STRING COMMENT 'Specific section or article number in the Limited Partnership Agreement that defines this waterfall structure.',
    `management_fee_offset_flag` BOOLEAN COMMENT 'Indicates whether management fees paid to the GP are offset against carried interest distributions in this waterfall tier.',
    `waterfall_name` STRING COMMENT 'Business-friendly name or label for this waterfall structure.',
    `notes` STRING COMMENT 'Free-text field capturing additional context, special provisions, or clarifications regarding the waterfall structure not captured in structured fields.',
    `preferred_return_accrual_method` STRING COMMENT 'Method by which preferred return accrues to LPs: simple interest, compound interest, or Internal Rate of Return (IRR) based calculation.. Valid values are `simple|compound|irr_based`',
    `termination_date` DATE COMMENT 'Date on which this waterfall structure ceases to be effective, typically at fund liquidation or amendment.',
    `tier_cap_amount` DECIMAL(18,2) COMMENT 'Maximum monetary amount that can be distributed within this tier before overflow proceeds to the next tier.',
    `tier_name` STRING COMMENT 'Descriptive label for this tier, such as Return of Capital, Preferred Return, Catch-Up, or Carried Interest.',
    `tier_sequence` BIGINT COMMENT 'Ordinal position of this tier within the waterfall structure, determining the order in which distributions are allocated.',
    `tier_threshold_amount` DECIMAL(18,2) COMMENT 'Monetary threshold that must be reached before distributions flow to the next tier in the waterfall sequence.',
    `transaction_fee_rebate_percentage` DECIMAL(10,6) COMMENT 'Percentage of transaction fees earned by the GP that must be rebated to the fund, reducing GP economics, expressed as a decimal (e.g., 0.80 for 80% rebate).',
    `waterfall_status` STRING COMMENT 'Current lifecycle status of the waterfall structure: active (in use), superseded (replaced by amendment), terminated (fund closed), or draft (pending approval).. Valid values are `active|superseded|terminated|draft`',
    `waterfall_type` STRING COMMENT 'Classification of the waterfall calculation methodology: European (whole-fund aggregation) vs American (deal-by-deal) vs hybrid or custom structures.. Valid values are `european_whole_fund|american_deal_by_deal|hybrid|custom`',
    CONSTRAINT pk_waterfall PRIMARY KEY(`waterfall_id`)
) COMMENT 'Master record defining the distribution waterfall structure for a private markets fund or co-investment vehicle. Captures waterfall type (European whole-fund vs American deal-by-deal), tier sequence, hurdle rate per tier, carry percentage per tier';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`waterfall_tier` (
    `waterfall_tier_id` BIGINT COMMENT 'Unique identifier for the waterfall tier within a distribution waterfall structure.',
    `waterfall_id` BIGINT COMMENT 'Reference to the parent distribution waterfall structure to which this tier belongs.',
    `waterfall_structure_waterfall_id` BIGINT COMMENT 'Reference to the parent distribution waterfall structure to which this tier belongs.',
    `calculation_basis` STRING COMMENT 'Methodology used to calculate distributions for this tier, such as cash-on-cash return, Internal Rate of Return (IRR), or Multiple on Invested Capital (MOIC).. Valid values are `cash_on_cash|irr|moic|nav_based|realized_proceeds`',
    `catch_up_percentage` DECIMAL(10,6) COMMENT 'Percentage of distributions allocated to GP during catch-up tier to equalize carried interest after preferred return is met.',
    `clawback_applicable_flag` BOOLEAN COMMENT 'Indicates whether clawback provisions apply to distributions made in this tier, requiring GP to return excess carried interest.',
    `clawback_percentage` DECIMAL(10,6) COMMENT 'Percentage of distributions subject to clawback if final returns fall below agreed thresholds.',
    `compounding_frequency` STRING COMMENT 'Frequency at which returns are compounded for hurdle rate calculations within this tier.. Valid values are `daily|monthly|quarterly|annual|none`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this waterfall tier record was first created in the system.',
    `cumulative_distribution_cap_amount` DECIMAL(20,2) COMMENT 'Maximum cumulative distribution amount for this tier before moving to the next tier in the waterfall.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which tier amounts and thresholds are denominated.. Valid values are `^[A-Z]{3}$`',
    `distribution_frequency` STRING COMMENT 'Frequency at which distributions are calculated and paid out for this tier.. Valid values are `quarterly|semi_annual|annual|event_driven|at_liquidation`',
    `distribution_reinvestment_flag` BOOLEAN COMMENT 'Indicates whether distributions from this tier are subject to mandatory or optional reinvestment into the fund.',
    `escrow_holdback_percentage` DECIMAL(10,6) COMMENT 'Percentage of GP distributions held in escrow to cover potential clawback obligations at fund termination.',
    `gp_allocation_percentage` DECIMAL(10,6) COMMENT 'Percentage of distributions allocated to General Partner within this tier, expressed as a decimal.',
    `hurdle_rate_percentage` DECIMAL(10,6) COMMENT 'Preferred return threshold that must be achieved before this tier becomes active, expressed as an annualized percentage.',
    `hurdle_rate_type` STRING COMMENT 'Method by which the hurdle rate is calculated, such as simple return, compounded return, or Internal Rate of Return (IRR) based.. Valid values are `simple|compounded|irr_based|none`',
    `lookback_provision_flag` BOOLEAN COMMENT 'Indicates whether a lookback provision applies, requiring recalculation of distributions at fund termination to ensure LPs receive their full preferred return.',
    `lp_allocation_percentage` DECIMAL(10,6) COMMENT 'Percentage of distributions allocated to Limited Partners within this tier, expressed as a decimal.',
    `management_fee_offset_flag` BOOLEAN COMMENT 'Indicates whether management fees paid by LPs are offset against distributions in this tier for carried interest calculations.',
    `notes` STRING COMMENT 'Additional comments, clarifications, or special conditions related to this waterfall tier.',
    `preferred_return_shortfall_carryforward_flag` BOOLEAN COMMENT 'Indicates whether any shortfall in preferred return from prior periods is carried forward and must be satisfied before moving to subsequent tiers.',
    `priority_rank` BIGINT COMMENT 'Numeric rank indicating the priority of this tier relative to other tiers in the waterfall, with lower numbers having higher priority.',
    `tier_amendment_date` DATE COMMENT 'Date of the most recent amendment to this tiers terms, reflecting changes to allocation percentages, hurdle rates, or other provisions.',
    `tier_amendment_reason` STRING COMMENT 'Business justification or regulatory reason for the most recent amendment to this tier.',
    `tier_description` STRING COMMENT 'Detailed explanation of the tiers purpose, calculation methodology, and conditions for distribution.',
    `tier_distribution_cap_amount` DECIMAL(20,2) COMMENT 'Maximum distribution amount that can be allocated within this specific tier.',
    `tier_effective_date` DATE COMMENT 'Date from which this tier becomes active and applicable for distribution calculations.',
    `tier_name` STRING COMMENT 'Business name or label for the tier, such as Return of Capital, Preferred Return, GP Catch-Up, or Carried Interest.',
    `tier_sequence_number` BIGINT COMMENT 'Sequential ordering of this tier within the waterfall structure, determining distribution priority.',
    `tier_status` STRING COMMENT 'Current lifecycle status of the waterfall tier within the distribution structure.. Valid values are `active|inactive|pending|superseded|terminated`',
    `tier_termination_date` DATE COMMENT 'Date on which this tier ceases to be active, either due to fund liquidation or structural amendment.',
    `tier_type` STRING COMMENT 'Classification of the tier within the waterfall structure, defining its economic purpose and distribution logic.. Valid values are `return_of_capital|preferred_return|gp_catch_up|carried_interest|profit_split|other`',
    `transaction_fee_treatment` STRING COMMENT 'Defines how transaction fees earned by GP are treated within this tier, such as offset to LP capital or retained by GP.. Valid values are `offset_to_lp|retained_by_gp|shared|not_applicable`',
    `updated_by` STRING COMMENT 'User or system identifier of the individual or process that last modified this waterfall tier record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this waterfall tier record was last modified.',
    `created_by` STRING COMMENT 'User or system identifier of the individual or process that created this waterfall tier record.',
    CONSTRAINT pk_waterfall_tier PRIMARY KEY(`waterfall_tier_id`)
) COMMENT 'Reference entity defining each sequential tier within a distribution waterfall structure. Captures tier sequence number, tier type (return of capital, preferred return/hurdle, GP catch-up, carried interest split), LP allocation percentage, GP allocation';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`hurdle_rate` (
    `hurdle_rate_id` BIGINT COMMENT 'Unique identifier for the hurdle rate record. Primary key for this entity.',
    `fund_id` BIGINT COMMENT 'Reference to the fund or investment vehicle to which this hurdle rate applies.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the General Partner entity associated with this hurdle rate arrangement.',
    `gp_gp_entity_id` BIGINT COMMENT 'Reference to the General Partner entity associated with this hurdle rate arrangement.',
    `approval_date` DATE COMMENT 'Date on which this hurdle rate arrangement was formally approved by the Investment Committee or governing body.',
    `approved_by` STRING COMMENT 'Name or identifier of the authority or committee that approved this hurdle rate arrangement.',
    `asset_class` STRING COMMENT 'The primary asset class to which this hurdle rate arrangement applies.. Valid values are `private_equity|real_estate|infrastructure|natural_resources|credit|multi_asset`',
    `benchmark_index_code` STRING COMMENT 'Reference code for any benchmark index used as a basis for the hurdle rate (e.g., SOFR, LIBOR, custom index).',
    `benchmark_spread_bps` BIGINT COMMENT 'Spread in basis points added to the benchmark index to determine the hurdle rate. Null if hurdle is absolute.',
    `calculation_method` STRING COMMENT 'The methodology used to calculate whether the hurdle rate has been achieved (e.g., Internal Rate of Return, money-weighted return, time-weighted return).. Valid values are `irr|money_weighted|time_weighted|absolute_return`',
    `carry_percentage` DECIMAL(5,4) COMMENT 'The percentage of profits allocated to the GP as carried interest after the hurdle rate is achieved. Expressed as a decimal (e.g., 0.20 for 20%).',
    `catch_up_percentage` DECIMAL(5,4) COMMENT 'The percentage of distributions allocated to the GP after the hurdle is met to catch up to their carried interest share. Typically 1.0 (100%) for full catch-up.',
    `clawback_cap_percentage` DECIMAL(5,4) COMMENT 'Maximum percentage of previously distributed carried interest subject to clawback. Null if no cap applies.',
    `clawback_provision_flag` BOOLEAN COMMENT 'Indicates whether a clawback provision exists requiring the GP to return excess carried interest if final returns fall below the hurdle.',
    `compounding_frequency` STRING COMMENT 'Indicates whether the hurdle rate is calculated on a simple or compound basis and the compounding period.. Valid values are `simple|compound_annual|compound_quarterly|compound_monthly|compound_daily`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this hurdle rate record was first created in the system.',
    `crystallization_event` STRING COMMENT 'Description of the event or condition that triggers the crystallization and payment of carried interest (e.g., exit, distribution, fund liquidation).',
    `cumulative_carry_distributed_amount` DECIMAL(20,2) COMMENT 'Total cumulative carried interest distributed to the General Partner under this hurdle rate arrangement, in the specified currency.',
    `cumulative_preferred_return_amount` DECIMAL(20,2) COMMENT 'Total cumulative preferred return amount owed to Limited Partners under this hurdle rate arrangement, in the specified currency.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the hurdle rate calculations and distributions are denominated.. Valid values are `^[A-Z]{3}$`',
    `data_classification` STRING COMMENT 'Classification level of this hurdle rate record indicating sensitivity and access control requirements.. Valid values are `restricted|confidential|internal|public`',
    `distribution_waterfall_tier` BIGINT COMMENT 'The tier or sequence number of this hurdle rate within the overall distribution waterfall structure.',
    `effective_date` DATE COMMENT 'The date from which this hurdle rate arrangement becomes active and applicable.',
    `escrow_percentage` DECIMAL(5,4) COMMENT 'Percentage of carried interest distributions held in escrow to cover potential clawback obligations. Null if no escrow applies.',
    `expiration_date` DATE COMMENT 'The date on which this hurdle rate arrangement ceases to be applicable. Null for open-ended arrangements.',
    `high_water_mark_flag` BOOLEAN COMMENT 'Indicates whether a high water mark provision applies, requiring losses to be recovered before new carry is earned.',
    `hurdle_achieved_flag` BOOLEAN COMMENT 'Indicates whether the hurdle rate has been achieved as of the last calculation date.',
    `hurdle_basis` STRING COMMENT 'The capital base against which the hurdle rate is calculated (e.g., committed capital, invested capital, paid-in capital, or net asset value).. Valid values are `committed_capital|invested_capital|paid_in_capital|nav`',
    `hurdle_rate_status` STRING COMMENT 'Current lifecycle status of the hurdle rate arrangement.. Valid values are `active|inactive|superseded|pending|terminated`',
    `hurdle_reset_frequency` STRING COMMENT 'Frequency at which the hurdle rate calculation resets or is re-evaluated.. Valid values are `none|annual|quarterly|fund_life|per_investment`',
    `hurdle_type` STRING COMMENT 'Classification of hurdle rate structure: hard (catch-up after hurdle), soft (no catch-up), or blended (partial catch-up).. Valid values are `hard|soft|blended`',
    `investment_strategy` STRING COMMENT 'The specific investment strategy or sub-strategy associated with this hurdle rate (e.g., buyout, growth equity, value-add real estate).',
    `last_calculation_date` DATE COMMENT 'The most recent date on which hurdle rate achievement was calculated and evaluated.',
    `lpa_reference` STRING COMMENT 'Reference to the specific section or clause in the Limited Partnership Agreement that defines this hurdle rate arrangement.',
    `measurement_period` STRING COMMENT 'The time period over which the hurdle rate performance is measured and evaluated.. Valid values are `inception_to_date|annual|quarterly|fund_life|investment_period`',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this hurdle rate record was last modified in the system.',
    `hurdle_rate_name` STRING COMMENT 'Business-friendly name or label for this hurdle rate arrangement.',
    `notes` STRING COMMENT 'Free-text field for additional comments, clarifications, or special conditions related to this hurdle rate arrangement.',
    `percentage` DECIMAL(10,6) COMMENT 'The preferred return threshold percentage that must be achieved before carried interest is earned. Expressed as a decimal (e.g., 0.08 for 8%).',
    `performance_fee_type` STRING COMMENT 'Classification of the performance-based fee structure associated with this hurdle rate.. Valid values are `carried_interest|incentive_fee|performance_allocation|profit_share`',
    `preferred_return_cumulative_flag` BOOLEAN COMMENT 'Indicates whether unpaid preferred returns accumulate and must be satisfied in future periods before carry is earned.',
    `record_version` BIGINT COMMENT 'Version number of this hurdle rate record, incremented with each modification for audit trail purposes.',
    `side_letter_flag` BOOLEAN COMMENT 'Indicates whether this hurdle rate arrangement is subject to side letter modifications for specific Limited Partners.',
    `tax_treatment_code` STRING COMMENT 'Code indicating the tax treatment of carried interest under this hurdle rate arrangement (jurisdiction-specific).',
    `vintage_year` BIGINT COMMENT 'The year in which the fund or investment vehicle was established, used for cohort analysis and performance benchmarking.',
    CONSTRAINT pk_hurdle_rate PRIMARY KEY(`hurdle_rate_id`)
) COMMENT 'Master record tracking the preferred return (hurdle rate) applicable to each carried interest arrangement or fund structure. Captures hurdle rate percentage, compounding frequency (simple vs compound), hurdle basis (committed capital vs invested capital';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`clawback_provision` (
    `clawback_provision_id` BIGINT COMMENT 'Unique identifier for the clawback provision record within the carried interest arrangement.',
    `carry_escrow_id` BIGINT COMMENT 'Reference to the segregated escrow account holding withheld carried interest distributions to satisfy potential clawback obligations.',
    `fund_id` BIGINT COMMENT 'Reference to the private equity or alternative investment fund to which this clawback provision applies.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the General Partner entity subject to the clawback obligation under this provision.',
    `calculation_frequency` STRING COMMENT 'Frequency at which clawback obligation is recalculated: per distribution (each carry payment), annual (yearly true-up), fund liquidation (final settlement only), deal exit (per investment realization), or continuous (real-time monitoring).. Valid values are `per_distribution|annual|fund_liquidation|deal_exit|continuous`',
    `carry_percent` DECIMAL(5,2) COMMENT 'General Partner (GP) carried interest percentage (typically 20 percent) of fund profits after hurdle and catch-up; basis for calculating maximum clawback obligation.',
    `clawback_calculation_method` STRING COMMENT 'Methodology used to compute clawback amount: Internal Rate of Return (IRR) based (comparing actual vs hurdle IRR), Multiple on Invested Capital (MOIC) based (comparing actual vs target multiple), Total Value to Paid-In (TVPI) based, hybrid (combination of. Valid values are `irr_based|moic_based|tvpi_based|hybrid|custom`',
    `clawback_cap_percent` DECIMAL(5,2) COMMENT 'Maximum clawback obligation expressed as percentage of cumulative carried interest distributions; protects General Partner (GP) from unlimited liability (e.g., 100 percent cap means GP never owes more than carry received).',
    `clawback_provision_status` STRING COMMENT 'Current lifecycle status of the clawback provision: active (in force), suspended (temporarily inactive), waived (Limited Partners (LPs) waived enforcement), triggered (clawback event occurred), settled (obligation fulfilled), or expired (provision term. Valid values are `active|suspended|waived|triggered|settled|expired`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this clawback provision record was first created in the system; used for audit trail and data lineage tracking.',
    `cumulative_gp_distributions_amount` DECIMAL(18,2) COMMENT 'Total carried interest distributions (in fund base currency) paid to General Partner (GP) to date; basis for calculating maximum clawback exposure.',
    `cumulative_lp_distributions_amount` DECIMAL(18,2) COMMENT 'Total distributions (in fund base currency) paid to Limited Partners (LPs) to date; used in waterfall calculations to determine if hurdle rate has been met.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this clawback provision record (e.g., USD, EUR, GBP); typically matches fund base currency.. Valid values are `^[A-Z]{3}$`',
    `current_clawback_liability_amount` DECIMAL(18,2) COMMENT 'Current estimated clawback liability (in fund base currency) owed by General Partner (GP) to Limited Partners (LPs) based on most recent calculation; may be negative (no liability) or positive (amount owed).',
    `dispute_resolution_method` STRING COMMENT 'Contractual method for resolving disputes related to clawback calculations or enforcement: arbitration (binding third-party decision), litigation (court proceedings), mediation (facilitated negotiation), or negotiation (direct party discussions).. Valid values are `arbitration|litigation|mediation|negotiation`',
    `effective_date` DATE COMMENT 'Date on which this clawback provision becomes binding and enforceable under the Limited Partnership Agreement (LPA).',
    `escrow_balance_amount` DECIMAL(18,2) COMMENT 'Current balance (in fund base currency) held in escrow account available to satisfy clawback obligations; updated with each carried interest distribution and clawback settlement.',
    `escrow_percentage` DECIMAL(5,2) COMMENT 'Percentage of each carried interest distribution withheld in escrow account to fund potential clawback obligations; released to General Partner (GP) after clawback period expires.',
    `expiration_date` DATE COMMENT 'Date on which the clawback provision expires and the General Partner (GP) is released from further clawback obligations; typically tied to fund liquidation plus statute of limitations period.',
    `fund_irr_percent` DECIMAL(7,4) COMMENT 'Current fund-level Internal Rate of Return (IRR) expressed as annualized percentage; compared against hurdle rate to determine clawback trigger status.',
    `fund_moic` DECIMAL(7,4) COMMENT 'Current fund-level Multiple on Invested Capital (MOIC) ratio (total value divided by total invested capital); used in Multiple on Invested Capital (MOIC) based clawback calculations.',
    `fund_tvpi` DECIMAL(7,4) COMMENT 'Current fund-level Total Value to Paid-In (TVPI) ratio (distributions plus residual Net Asset Value (NAV) divided by Paid-In Capital (PIC)); used in Total Value to Paid-In (TVPI) based clawback calculations.',
    `gp_catch_up_percent` DECIMAL(5,2) COMMENT 'Percentage of distributions allocated to General Partner (GP) after hurdle is met and before final carried interest split, used in waterfall calculations to determine clawback exposure.',
    `hurdle_rate_percent` DECIMAL(5,2) COMMENT 'Preferred return threshold (expressed as annual percentage) that Limited Partners (LPs) must achieve before General Partner (GP) participates in carried interest; clawback is triggered if final Internal Rate of Return (IRR) falls below this rate.',
    `is_active` BOOLEAN COMMENT 'Boolean flag indicating whether this clawback provision is currently active and enforceable (True) or has been terminated, expired, or superseded (False).',
    `last_calculation_date` DATE COMMENT 'Date of the most recent clawback obligation calculation and true-up analysis performed for this provision.',
    `legal_jurisdiction` STRING COMMENT 'Legal jurisdiction governing the enforcement and interpretation of this clawback provision, typically the fund domicile jurisdiction specified in Limited Partnership Agreement (LPA).',
    `lookback_period_years` BIGINT COMMENT 'Number of years after final fund liquidation during which Limited Partners (LPs) may enforce clawback claims; typically aligned with statute of limitations (e.g., 3 to 7 years).',
    `lpa_section_reference` STRING COMMENT 'Specific section, article, or clause reference in the Limited Partnership Agreement (LPA) document that defines this clawback provision (e.g., Article 7.3, Section 12.5).',
    `maximum_clawback_amount` DECIMAL(18,2) COMMENT 'Maximum monetary amount (in fund base currency) that General Partner (GP) may be required to return to Limited Partners (LPs) under this provision; typically capped at total carried interest distributed to date.',
    `next_calculation_date` DATE COMMENT 'Scheduled date for the next clawback obligation calculation and true-up analysis based on calculation frequency and fund lifecycle events.',
    `notes` STRING COMMENT 'Free-text field for additional context, special conditions, amendments, or operational notes related to this clawback provision not captured in structured fields.',
    `provision_name` STRING COMMENT 'Business name or label for this clawback provision as referenced in fund documentation and Investment Committee (IC) materials.',
    `provision_type` STRING COMMENT 'Classification of the clawback mechanism: full clawback (entire carry subject to true-up), partial clawback (limited to specific percentage), rolling clawback (calculated periodically), deal-by-deal clawback (per investment basis), aggregate clawback. Valid values are `full_clawback|partial_clawback|rolling_clawback|deal_by_deal_clawback|aggregate_clawback|escrow_based_clawback`',
    `settlement_amount` DECIMAL(18,2) COMMENT 'Actual monetary amount (in fund base currency) paid by General Partner (GP) to Limited Partners (LPs) to settle clawback obligation; null if not yet settled.',
    `settlement_date` DATE COMMENT 'Actual date on which General Partner (GP) remitted clawback payment to Limited Partners (LPs) and satisfied the clawback obligation; null if not yet settled.',
    `settlement_due_date` DATE COMMENT 'Date by which General Partner (GP) must remit clawback payment to Limited Partners (LPs) following trigger event; typically 30 to 90 days after trigger or fund liquidation.',
    `tax_treatment_code` STRING COMMENT 'Tax classification code for clawback payments (e.g., return of capital, ordinary income, capital gain reversal) per applicable tax jurisdiction and Internal Revenue Service (IRS) or local tax authority guidance.',
    `trigger_condition` STRING COMMENT 'Detailed description of the condition(s) that activate the clawback obligation, such as final fund Internal Rate of Return (IRR) falling below hurdle rate, Total Value to Paid-In (TVPI) below threshold, or cumulative General Partner (GP) distributions',
    `trigger_event_date` DATE COMMENT 'Date on which the clawback trigger condition was met and clawback obligation became enforceable; null if provision has not been triggered.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this clawback provision record was last modified; used for audit trail and change tracking.',
    `waiver_approval_date` DATE COMMENT 'Date on which Limited Partners (LPs) formally approved a waiver or modification of this clawback provision; null if no waiver has been granted.',
    `waiver_conditions` STRING COMMENT 'Conditions under which Limited Partners (LPs) may waive or modify clawback obligations, such as Limited Partner (LP) vote threshold, Investment Committee (IC) approval, or specific performance criteria.',
    CONSTRAINT pk_clawback_provision PRIMARY KEY(`clawback_provision_id`)
) COMMENT 'Master record for GP clawback provisions embedded within carried interest arrangements. Captures clawback trigger conditions (GP over-distribution relative to final fund IRR), maximum clawback amount, clawback escrow percentage, clawback calculation';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`clawback_event` (
    `clawback_event_id` BIGINT COMMENT 'Unique identifier for the clawback event record.',
    `carry_escrow_id` BIGINT COMMENT 'Identifier of the escrow account from which clawback funds will be drawn if the payment method involves escrow release.',
    `employee_id` BIGINT COMMENT 'Identifier of the user or system process that created this clawback event record.',
    `fund_id` BIGINT COMMENT 'Identifier of the private equity or alternative investment fund in which the clawback event occurred.',
    `gp_entity_id` BIGINT COMMENT 'Identifier of the General Partner entity subject to the clawback obligation.',
    `updated_by_user_employee_id` BIGINT COMMENT 'Identifier of the user or system process that last modified this clawback event record.',
    `valuation_cycle_id` BIGINT COMMENT 'Foreign key linking to valuation.cycle. Business justification: Clawback events are triggered when fund performance falls below thresholds based on valuations.',
    `auditor_verification_date` DATE COMMENT 'Date on which the external auditor completed verification of the clawback calculation.',
    `auditor_verified_flag` BOOLEAN COMMENT 'Indicates whether the clawback calculation has been independently verified by the funds external auditor.',
    `calculation_date` DATE COMMENT 'Date on which the clawback amount was calculated based on final fund performance and carried interest waterfall reconciliation.',
    `calculation_methodology` STRING COMMENT 'Description of the calculation methodology applied to determine the clawback amount, referencing specific Limited Partnership Agreement provisions and waterfall logic.',
    `carried_interest_distributed_amount` DECIMAL(18,2) COMMENT 'Total cumulative carried interest amount previously distributed to the General Partner prior to the clawback event.',
    `carried_interest_entitled_amount` DECIMAL(18,2) COMMENT 'Final carried interest amount to which the General Partner is entitled based on actual fund performance and waterfall calculations.',
    `carry_rate_percent` DECIMAL(5,4) COMMENT 'Percentage of profits above the hurdle rate to which the General Partner is entitled as carried interest, per the Limited Partnership Agreement.',
    `clawback_cap_amount` DECIMAL(18,2) COMMENT 'Maximum clawback amount that can be enforced against the General Partner per the Limited Partnership Agreement clawback cap provisions.',
    `clawback_cap_applied_flag` BOOLEAN COMMENT 'Indicates whether the contractual clawback cap was applied to limit the clawback obligation in this event.',
    `clawback_gross_amount` DECIMAL(18,2) COMMENT 'Gross clawback amount owed by the General Partner, calculated as the excess of distributed carried interest over entitled carried interest.',
    `clawback_net_amount` DECIMAL(18,2) COMMENT 'Net clawback amount owed after applying any contractual adjustments, tax gross-ups, or offsets per the Limited Partnership Agreement.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this clawback event record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the clawback amounts are denominated.. Valid values are `^[A-Z]{3}$`',
    `dispute_flag` BOOLEAN COMMENT 'Indicates whether the General Partner has formally disputed the clawback calculation or obligation.',
    `dispute_reason` STRING COMMENT 'Detailed explanation provided by the General Partner for disputing the clawback event, including calculation disagreements or contractual interpretation.',
    `dispute_resolution_date` DATE COMMENT 'Date on which the clawback dispute was resolved through negotiation, arbitration, or other dispute resolution mechanism.',
    `due_date` DATE COMMENT 'Date by which the General Partner must remit the clawback amount to the fund or Limited Partners.',
    `event_status` STRING COMMENT 'Current lifecycle status of the clawback event in the resolution workflow. [ENUM-REF-CANDIDATE: triggered|calculated|notified|acknowledged|disputed|settled|paid|waived|cancelled — 9 candidates stripped; promote to reference product]',
    `fund_irr_percent` DECIMAL(7,4) COMMENT 'Final Internal Rate of Return achieved by the fund at the time of clawback calculation, used to determine carried interest entitlement.',
    `fund_moic` DECIMAL(7,4) COMMENT 'Final Multiple on Invested Capital achieved by the fund, representing total value divided by paid-in capital, used in clawback determination.',
    `hurdle_rate_percent` DECIMAL(5,4) COMMENT 'Preferred return threshold percentage that Limited Partners must achieve before the General Partner is entitled to carried interest, used in clawback calculation.',
    `legal_counsel_opinion_flag` BOOLEAN COMMENT 'Indicates whether legal counsel has provided an opinion on the enforceability and calculation of the clawback obligation.',
    `lp_capital_returned_amount` DECIMAL(18,2) COMMENT 'Total capital returned to Limited Partners at the time of clawback calculation, used to verify hurdle achievement and waterfall distribution.',
    `lp_profit_distributed_amount` DECIMAL(18,2) COMMENT 'Total profit distributed to Limited Partners at the time of clawback calculation, used in carried interest waterfall reconciliation.',
    `notes` STRING COMMENT 'Free-text field for additional context, special circumstances, or administrative notes related to the clawback event.',
    `notification_date` DATE COMMENT 'Date on which the General Partner was formally notified of the clawback obligation.',
    `number` STRING COMMENT 'Business identifier or reference number assigned to this clawback event for tracking and reporting purposes.',
    `offset_amount` DECIMAL(18,2) COMMENT 'Amount offset against the clawback obligation due to management fee rebates, expense reimbursements, or other contractual adjustments.',
    `payment_method` STRING COMMENT 'Method by which the General Partner will satisfy the clawback obligation, such as cash payment or release from escrow account.. Valid values are `cash|escrow_release|offset_against_future_carry|promissory_note|in_kind_transfer|other`',
    `settlement_date` DATE COMMENT 'Actual date on which the clawback obligation was settled or paid by the General Partner.',
    `tax_gross_up_amount` DECIMAL(18,2) COMMENT 'Additional amount added to the clawback obligation to account for tax liabilities incurred by the General Partner on previously distributed carried interest.',
    `trigger_date` DATE COMMENT 'Date on which the clawback event was triggered, typically at fund liquidation or final distribution when carried interest calculations are finalized.',
    `trigger_reason` STRING COMMENT 'Business reason or event that triggered the clawback calculation, such as fund liquidation or final performance reconciliation.. Valid values are `fund_liquidation|final_distribution|performance_shortfall|hurdle_breach|waterfall_true_up|interim_reconciliation`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this clawback event record was last modified in the system.',
    `waiver_approval_date` DATE COMMENT 'Date on which the Limited Partner Advisory Committee or governing body approved the clawback waiver.',
    `waiver_flag` BOOLEAN COMMENT 'Indicates whether the Limited Partners or fund administrator waived the clawback obligation in whole or in part.',
    `waiver_reason` STRING COMMENT 'Business justification for waiving the clawback obligation, such as immateriality, GP relationship considerations, or administrative burden.',
    CONSTRAINT pk_clawback_event PRIMARY KEY(`clawback_event_id`)
) COMMENT 'Transactional record of a clawback event triggered against a GP when carried interest distributions exceed the GPs entitlement based on final fund performance.';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`accrual` (
    `accrual_id` BIGINT COMMENT 'Unique identifier for the fee accrual record. Primary key for the accrual entity.',
    `employee_id` BIGINT COMMENT 'Reference to the user or Investment Committee (IC) member who approved the accrual for posting. Supports audit trail and governance requirements.',
    `external_manager_gp_profile_id` BIGINT COMMENT 'Reference to the external General Partner (GP) or fund manager when the accrual relates to an externally managed mandate or fund investment.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external General Partner (GP) or fund manager when the accrual relates to an externally managed mandate or fund investment.',
    `investment_id` BIGINT COMMENT 'Reference to the investment (fund, mandate, direct investment, or co-investment) for which the fee is being accrued.',
    `accrual_status` STRING COMMENT 'Current state of the accrual in its approval and posting workflow: draft (initial calculation), pending approval (awaiting IC or finance review), approved (ready to post), posted (recorded in GL), reversed, or cancelled.. Valid values are `draft|pending_approval|approved|posted|reversed|cancelled`',
    `adjustment_amount` DECIMAL(18,2) COMMENT 'Manual or system-generated adjustment to the accrual, such as true-up adjustments for prior period corrections, catch-up accruals, or Investment Committee (IC) approved modifications.',
    `approval_date` DATE COMMENT 'The date on which the accrual was approved by the Investment Committee (IC), finance controller, or authorized approver, allowing it to be posted to the General Ledger (GL).',
    `basis` STRING COMMENT 'The base metric used to calculate the fee accrual: Assets Under Management (AUM), Net Asset Value (NAV), committed capital, Paid-In Capital (PIC), Gross Asset Value (GAV), or transaction value for deal-specific fees.. Valid values are `aum|nav|committed_capital|paid_in_capital|gross_asset_value|transaction_value`',
    `basis_amount` DECIMAL(20,2) COMMENT 'The dollar value of the basis metric (AUM, NAV, committed capital, etc.) used to compute the fee accrual for this period. Denominated in the fund or mandate base currency.',
    `benchmark_fee_rate_percent` DECIMAL(7,4) COMMENT 'The market benchmark or peer median fee rate for this fee type and asset class, used for fee transparency reporting and external manager fee benchmarking. Sourced from Preqin, PitchBook, or industry surveys.',
    `calculation_method` STRING COMMENT 'The methodology used to determine the accrual basis amount: average balance over the period, end-of-period snapshot, beginning-of-period snapshot, daily average, or transaction-based for deal fees.. Valid values are `average_balance|end_of_period|beginning_of_period|daily_average|transaction_based`',
    `calculation_timestamp` TIMESTAMP COMMENT 'The date and time when the accrual calculation was performed by the Investment Book of Record (IBOR) or accounting system. Supports audit trail and version control for recalculations.',
    `catch_up_rate_percent` DECIMAL(7,4) COMMENT 'The rate at which the General Partner (GP) catches up to their full carried interest share after the hurdle is met, typically 100% until the GP reaches their target carry allocation. Null for non-carry fee types.',
    `clawback_provision_flag` BOOLEAN COMMENT 'Indicates whether this accrual is subject to clawback provisions, where the General Partner (GP) may be required to return previously distributed carried interest if final fund performance falls below the hurdle rate.',
    `cost_center_code` STRING COMMENT 'The cost center or business unit code for internal allocation and reporting of the fee expense, enabling performance attribution and cost transparency by investment strategy or asset class.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this accrual record was first created in the data platform. Supports audit trail and data lineage tracking.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the accrual amounts (e.g., USD, EUR, GBP). Typically matches the base currency of the fund or mandate.. Valid values are `^[A-Z]{3}$`',
    `fee_rebate_amount` DECIMAL(18,2) COMMENT 'Any rebate or offset applied to the gross accrual, such as General Partner (GP) fee rebates on co-investments or transaction fee offsets negotiated in the Limited Partnership Agreement (LPA).',
    `fee_type` STRING COMMENT 'Classification of the fee being accrued: management fee (ongoing asset-based fee), carried interest (GP profit share above hurdle), performance fee (incentive-based), transaction fee (deal-specific), advisory fee, or administration fee.. Valid values are `management_fee|carried_interest|performance_fee|transaction_fee|advisory_fee|administration_fee`',
    `fee_variance_percent` DECIMAL(7,4) COMMENT 'The variance between the accrued fee rate and the benchmark fee rate, expressed as a percentage. Positive values indicate fees above market; negative values indicate favorable negotiated rates.',
    `frequency` STRING COMMENT 'The frequency at which this fee type is accrued: monthly, quarterly (most common for management fees), semi-annually, annually, or event-driven (for transaction fees).. Valid values are `monthly|quarterly|semi_annually|annually|event_driven`',
    `gl_account_code` STRING COMMENT 'The General Ledger account code to which this accrual is posted in the corporate accounting system (e.g., Oracle Financials). Typically an expense account for management fees or a liability account for carried interest.',
    `gross_accrual_amount` DECIMAL(18,2) COMMENT 'The gross fee amount accrued for the period before any adjustments, rebates, or offsets. Calculated as accrual_basis_amount multiplied by accrual_rate_percent, pro-rated for the period.',
    `hurdle_rate_percent` DECIMAL(7,4) COMMENT 'The preferred return threshold that must be achieved before carried interest accrues to the General Partner (GP). Expressed as an annualized percentage (e.g., 8.0000 for 8%). Null for non-carry fee types.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The date and time when this accrual record was last updated in the data platform. Supports change tracking and audit trail for corrections or adjustments.',
    `net_accrual_amount` DECIMAL(18,2) COMMENT 'The final net fee amount accrued for the period after applying all rebates and adjustments. This is the amount posted to the General Ledger (GL) and reflected in Net Asset Value (NAV) calculations.',
    `notes` STRING COMMENT 'Free-text field for additional context, explanations, or special instructions related to the accrual, such as non-standard calculation methods, Investment Committee (IC) guidance, or reconciliation notes.',
    `number` STRING COMMENT 'Human-readable business identifier for the accrual record, typically generated by the Investment Book of Record (IBOR) or accounting system.',
    `period_end_date` DATE COMMENT 'End date of the period for which the fee is being accrued, typically the last day of the calendar quarter or month. Defines the measurement window for Assets Under Management (AUM) or Net Asset Value (NAV) calculations.',
    `period_start_date` DATE COMMENT 'Start date of the period for which the fee is being accrued, typically the first day of the calendar quarter or month depending on fee calculation frequency.',
    `posting_date` DATE COMMENT 'The date on which the accrual was posted to the General Ledger (GL) and reflected in the Net Asset Value (NAV) calculation. Typically the last business day of the accrual period.',
    `rate_percent` DECIMAL(7,4) COMMENT 'The annualized fee rate applied to the accrual basis, expressed as a percentage. For example, a 1.50% management fee or 20% carried interest rate. Stored as decimal (e.g., 1.5000 for 1.5%).',
    `reversal_date` DATE COMMENT 'The date on which the accrual was reversed, typically due to an error correction, true-up adjustment, or cancellation of the underlying investment or mandate. Null if the accrual has not been reversed.',
    `reversal_reason` STRING COMMENT 'Free-text explanation for why the accrual was reversed, such as calculation error, mandate termination, or Investment Committee (IC) decision. Null if the accrual has not been reversed.',
    `source_system_reference` STRING COMMENT 'The unique identifier or transaction reference for this accrual in the source system (e.g., SimCorp transaction ID, Aladdin accrual batch ID), enabling reconciliation and audit trail back to the system of record.',
    `waterfall_tier` STRING COMMENT 'Identifier for the tier or tranche in a multi-tier carried interest waterfall structure (e.g., Tier 1, Tier 2, Tier 3), where different hurdle rates and carry percentages apply at different return levels. Null for non-carry fee types.',
    CONSTRAINT pk_accrual PRIMARY KEY(`accrual_id`)
) COMMENT 'Transactional record of periodic fee accruals computed for management fees, carried interest, and other investment-related fees. Captures accrual period (start/end date), fee type, accrual basis (AUM, NAV, committed capital), accrual rate applied, gross';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`payment` (
    `payment_id` BIGINT COMMENT 'Unique identifier for the fee payment transaction.',
    `external_manager_gp_profile_id` BIGINT COMMENT 'Reference to the external manager or General Partner (GP) receiving the payment.',
    `fund_id` BIGINT COMMENT 'Reference to the fund or investment vehicle from which the payment is made.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external manager or General Partner (GP) receiving the payment.',
    `investment_id` BIGINT COMMENT 'Reference to the specific investment or mandate associated with this payment.',
    `manager_mandate_id` BIGINT COMMENT 'Foreign key linking to manager.manager_mandate. Business justification: Fee payment reconciliation requires mandate-level attribution for SLA compliance monitoring, fee schedule validation, and contractual payment term verification per LPA.',
    `settlement_cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: Fee payment settlement process requires routing to specific treasury cash accounts. Cash management teams need this link for daily cash positioning, payment execution, and',
    `settlement_instruction_id` BIGINT COMMENT 'Reference to the payment instruction or settlement instruction (SSI) used for this disbursement.',
    `approval_date` DATE COMMENT 'Date on which the payment was approved by the authorized signatory or Investment Committee (IC).',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee that approved the payment.',
    `base_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code representing the funds base or reporting currency.. Valid values are `^[A-Z]{3}$`',
    `base_currency_gross_amount` DECIMAL(18,2) COMMENT 'Gross payment amount converted to the funds base currency using the FX rate.',
    `base_currency_net_amount` DECIMAL(18,2) COMMENT 'Net payment amount converted to the funds base currency using the FX rate.',
    `beneficiary_account_number` STRING COMMENT 'Bank account number of the external manager or GP receiving the payment.',
    `beneficiary_bank_bic` STRING COMMENT 'Bank Identifier Code (BIC) or SWIFT code of the beneficiary bank.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `beneficiary_bank_name` STRING COMMENT 'Name of the bank receiving the payment on behalf of the external manager or GP.',
    `clawback_amount` DECIMAL(18,2) COMMENT 'Amount clawed back or withheld from the payment due to clawback provisions in the LPA.',
    `clawback_provision_applied` BOOLEAN COMMENT 'Boolean flag indicating whether a clawback provision was applied to reduce this payment.',
    `cost_center_code` STRING COMMENT 'Cost center or business unit code to which this payment is allocated.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the payment record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the payment was made (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `payment_description` STRING COMMENT 'Detailed description or narrative of the payment, including purpose and any special terms or conditions.',
    `due_date` DATE COMMENT 'Contractual due date by which the payment must be made per the Limited Partnership Agreement (LPA) or mandate terms.',
    `fee_period_end_date` DATE COMMENT 'End date of the period for which this fee payment applies.',
    `fee_period_start_date` DATE COMMENT 'Start date of the period for which this fee payment applies.',
    `fee_type` STRING COMMENT 'Classification of the fee being paid: management fee, carried interest (carry), transaction fee, monitoring fee, advisory fee, or performance fee.. Valid values are `management_fee|carried_interest|transaction_fee|monitoring_fee|advisory_fee|performance_fee`',
    `fx_rate` DECIMAL(18,8) COMMENT 'Exchange rate applied to convert payment currency to base currency at the time of payment.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this payment is posted for accounting purposes.',
    `gross_payment_amount` DECIMAL(18,2) COMMENT 'Total fee amount before any deductions, withholdings, or adjustments.',
    `hurdle_rate_met` BOOLEAN COMMENT 'Boolean flag indicating whether the preferred return hurdle rate was met for carried interest payments.',
    `invoice_date` DATE COMMENT 'Date on which the invoice or fee statement was issued by the external manager or GP.',
    `invoice_number` STRING COMMENT 'Reference number of the invoice or fee statement associated with this payment.',
    `is_late_payment` BOOLEAN COMMENT 'Boolean flag indicating whether the payment was made after the contractual due date.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the payment record was last updated or modified.',
    `late_payment_penalty_amount` DECIMAL(18,2) COMMENT 'Amount of penalty or interest charged for late payment, if applicable per LPA terms.',
    `method` STRING COMMENT 'Method or instrument used to disburse the payment (e.g., wire transfer, ACH, check, SWIFT, SEPA).. Valid values are `wire_transfer|ach|check|electronic_funds_transfer|swift|sepa`',
    `net_payment_amount` DECIMAL(18,2) COMMENT 'Final net amount disbursed to the recipient after all deductions and withholdings.',
    `notes` STRING COMMENT 'Additional notes, comments, or special instructions related to the payment transaction.',
    `other_deductions_amount` DECIMAL(18,2) COMMENT 'Total amount of other deductions applied to the payment, such as clawback provisions, fee rebates, or adjustments.',
    `payment_date` DATE COMMENT 'The date on which the fee payment was disbursed to the recipient.',
    `payment_status` STRING COMMENT 'Current lifecycle status of the payment transaction. [ENUM-REF-CANDIDATE: pending|approved|disbursed|settled|cancelled|failed|reversed — 7 candidates stripped; promote to reference product]',
    `reconciliation_date` DATE COMMENT 'Date on which the payment was successfully reconciled with bank and custodian records.',
    `reconciliation_status` STRING COMMENT 'Status of the payment reconciliation process against bank statements and custodian records.. Valid values are `reconciled|pending_reconciliation|discrepancy|unreconciled`',
    `reference_number` STRING COMMENT 'External reference number or transaction identifier for the payment, used for reconciliation and audit trail.',
    `settlement_date` DATE COMMENT 'Date on which the payment was settled and funds were received by the beneficiary.',
    `vintage_year` BIGINT COMMENT 'The year in which the fund or investment commitment was made, used for performance tracking and benchmarking.',
    `withholding_tax_amount` DECIMAL(18,2) COMMENT 'Amount of withholding tax deducted from the gross payment per applicable tax treaties and regulations.',
    `withholding_tax_rate` DECIMAL(5,4) COMMENT 'Percentage rate of withholding tax applied to the gross payment, expressed as a decimal (e.g., 0.15 for 15%).',
    CONSTRAINT pk_payment PRIMARY KEY(`payment_id`)
) COMMENT 'Transactional record of actual fee payments disbursed to external managers, GPs, or service providers. Captures payment date, fee type (management fee, carried interest, transaction fee, monitoring fee), gross payment amount, withholding tax deducted, net';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`invoice` (
    `invoice_id` BIGINT COMMENT 'Unique identifier for the fee invoice record. Primary key.',
    `external_manager_gp_profile_id` BIGINT COMMENT 'Reference to the external manager or General Partner (GP) who issued this invoice.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external manager or General Partner (GP) who issued this invoice.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the investment mandate or Limited Partnership Agreement (LPA) under which this fee is charged.',
    `accrual_date` DATE COMMENT 'Date the fee expense was accrued in the accounting system, typically at period end.',
    `approval_date` DATE COMMENT 'Date the invoice was approved for payment by internal finance or investment operations.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual who approved the invoice for payment.',
    `base_amount` DECIMAL(20,4) COMMENT 'Base calculation amount (e.g., Assets Under Management, committed capital, or Net Asset Value) used to compute the fee.',
    `benchmark_fee_rate_bps` DECIMAL(10,4) COMMENT 'Industry benchmark fee rate in basis points (bps) for comparison and fee transparency reporting.',
    `carry_rate_pct` DECIMAL(8,4) COMMENT 'Carried interest (carry) rate percentage applied to profits above the hurdle rate for performance fee calculation.',
    `clawback_provision_flag` BOOLEAN COMMENT 'Indicates whether a clawback provision applies to this invoice, requiring the General Partner (GP) to return excess carried interest if final returns fall below the hurdle.',
    `cost_center_code` STRING COMMENT 'Cost center code for internal allocation and reporting of fee expenses.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this invoice record was first created in the fee administration system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the invoice amounts (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `invoice_description` STRING COMMENT 'Detailed description or narrative provided by the external manager or General Partner (GP) explaining the fee invoice.',
    `dispute_date` DATE COMMENT 'Date the invoice was flagged as disputed.',
    `dispute_reason` STRING COMMENT 'Reason for disputing the invoice, if payment status is disputed.',
    `due_date` DATE COMMENT 'Payment due date specified by the external manager or General Partner (GP).',
    `fee_basis` STRING COMMENT 'Basis on which the fee is calculated: Assets Under Management (AUM), committed capital, Net Asset Value (NAV), transaction value, or fixed amount.. Valid values are `aum|committed_capital|nav|transaction_value|fixed`',
    `fee_rate_bps` DECIMAL(10,4) COMMENT 'Fee rate expressed in basis points (bps) applied to the base amount. One basis point equals 0.01%.',
    `fee_type` STRING COMMENT 'Classification of the fee being invoiced: management fee, performance fee (carried interest), monitoring fee, transaction fee, advisory fee, or administration fee.. Valid values are `management_fee|performance_fee|monitoring_fee|transaction_fee|advisory_fee|administration_fee`',
    `fee_variance_bps` DECIMAL(10,4) COMMENT 'Variance between the invoiced fee rate and the benchmark fee rate, expressed in basis points (bps).',
    `gl_account_code` STRING COMMENT 'General Ledger (GL) account code to which this fee expense is posted in the corporate accounting system.',
    `gross_fee_amount` DECIMAL(18,2) COMMENT 'Gross fee amount before any adjustments, rebates, or taxes.',
    `hurdle_rate_pct` DECIMAL(8,4) COMMENT 'Preferred return threshold (hurdle rate) percentage that must be achieved before performance fees or carried interest are payable.',
    `invoice_date` DATE COMMENT 'Date the invoice was issued by the external manager or General Partner (GP).',
    `invoicing_entity_lei` STRING COMMENT 'Legal Entity Identifier (LEI) of the General Partner (GP) or external manager entity issuing the invoice.. Valid values are `^[A-Z0-9]{20}$`',
    `invoicing_entity_name` STRING COMMENT 'Legal name of the General Partner (GP) or external manager entity issuing the invoice.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this invoice record was last modified in the fee administration system.',
    `net_fee_amount` DECIMAL(18,2) COMMENT 'Net fee amount payable after rebates and taxes. This is the final amount due to the external manager or General Partner (GP).',
    `number` STRING COMMENT 'External invoice number assigned by the General Partner (GP) or external manager for tracking and reconciliation.',
    `payment_date` DATE COMMENT 'Actual date the invoice was paid to the external manager or General Partner (GP).',
    `payment_reference` STRING COMMENT 'Payment reference or transaction identifier used for reconciliation with treasury and cash management systems.',
    `payment_status` STRING COMMENT 'Current payment status of the invoice: pending review, approved for payment, paid, disputed, cancelled, or overdue.. Valid values are `pending|approved|paid|disputed|cancelled|overdue`',
    `period_end_date` DATE COMMENT 'End date of the period covered by this fee invoice.',
    `period_start_date` DATE COMMENT 'Start date of the period covered by this fee invoice.',
    `rebate_amount` DECIMAL(18,2) COMMENT 'Fee rebate or discount amount applied by the General Partner (GP) or external manager, reducing the gross fee.',
    `received_timestamp` TIMESTAMP COMMENT 'Timestamp when the invoice was received by the pension fund from the external manager or General Partner (GP).',
    `resolution_date` DATE COMMENT 'Date the dispute was resolved and the invoice was either approved or cancelled.',
    `source_document_uri` STRING COMMENT 'Uniform Resource Identifier (URI) or file path to the original invoice document (PDF, email) stored in the document management system.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Tax amount (e.g., Value Added Tax, Goods and Services Tax) applied to the fee invoice.',
    `waterfall_tier` STRING COMMENT 'Waterfall tier or tranche identifier for multi-tier carried interest structures (e.g., Tier 1, Tier 2).',
    CONSTRAINT pk_invoice PRIMARY KEY(`invoice_id`)
) COMMENT 'Transactional record of fee invoices received from external managers or GPs for management fees, monitoring fees, and other mandate-related charges. Captures invoice date, invoice number, invoicing entity (GP/manager LEI), invoice period, fee type';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`transaction_fee` (
    `transaction_fee_id` BIGINT COMMENT 'Unique identifier for the transaction fee record.',
    `counterparty_id` BIGINT COMMENT 'Reference to the external advisor or intermediary entity that charged this fee (investment bank, consultant, legal advisor).',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the private market investment deal or transaction that generated this fee.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the GP or external manager entity that charged or received this transaction fee.',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Transaction fees must be attributed to GP profiles for management fee offset calculations per LPA terms and ILPA fee transparency reporting requirements.',
    `investment_id` BIGINT COMMENT 'Reference to the underlying investment position associated with this transaction fee.',
    `opportunity_id` BIGINT COMMENT 'Reference to the private market investment deal or transaction that generated this fee.',
    `accrual_date` DATE COMMENT 'Date on which the fee was accrued in the accounting records.',
    `allocation_method` STRING COMMENT 'Method by which the transaction fee is allocated across multiple LPs or investment vehicles if applicable.. Valid values are `direct|pro_rata|waterfall|custom`',
    `benchmark_rate_percent` DECIMAL(8,5) COMMENT 'Industry benchmark or peer median fee rate for this type of transaction, used for fee reasonableness assessment.',
    `capitalized_flag` BOOLEAN COMMENT 'Indicates whether the transaction fee was capitalized as part of the investment cost basis rather than expensed.',
    `cost_center_code` STRING COMMENT 'Internal cost center or business unit code responsible for this transaction fee.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this transaction fee record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the transaction fee is denominated.. Valid values are `^[A-Z]{3}$`',
    `dispute_flag` BOOLEAN COMMENT 'Indicates whether this transaction fee is under dispute or subject to challenge by the LP or IC.',
    `dispute_reason` STRING COMMENT 'Explanation of the reason for disputing the transaction fee, if applicable.',
    `dispute_resolution_date` DATE COMMENT 'Date on which the fee dispute was resolved or settled.',
    `due_date` DATE COMMENT 'Date by which the transaction fee payment is contractually due.',
    `fee_basis` STRING COMMENT 'The valuation or capital base upon which the transaction fee calculation is determined.. Valid values are `transaction_value|enterprise_value|equity_value|committed_capital|flat_fee`',
    `fee_category` STRING COMMENT 'High-level categorization of the fee for reporting and benchmarking purposes.. Valid values are `transaction|management|performance|other`',
    `fee_gross_amount` DECIMAL(18,2) COMMENT 'Gross transaction fee amount before any offsets, rebates, or adjustments.',
    `fee_net_amount` DECIMAL(18,2) COMMENT 'Net transaction fee amount payable after rebates and offsets, representing the actual economic cost to the fund.',
    `fee_number` STRING COMMENT 'Business identifier or invoice number for this transaction fee as assigned by the charging party.',
    `fee_rate_percent` DECIMAL(8,5) COMMENT 'Percentage rate applied to the transaction value to calculate the fee, if fee is rate-based.',
    `fee_status` STRING COMMENT 'Current lifecycle status of the transaction fee in the payment and settlement process.. Valid values are `accrued|invoiced|paid|disputed|waived|cancelled`',
    `fee_type` STRING COMMENT 'Classification of the transaction fee by its purpose in the deal lifecycle. [ENUM-REF-CANDIDATE: acquisition|disposition|financing|monitoring|advisory|legal|due_diligence — 7 candidates stripped; promote to reference product]',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this transaction fee is posted in the accounting system.',
    `ic_approval_date` DATE COMMENT 'Date on which the Investment Committee approved the transaction fee.',
    `ic_approval_flag` BOOLEAN COMMENT 'Indicates whether this transaction fee was reviewed and approved by the Investment Committee.',
    `invoice_date` DATE COMMENT 'Date on which the fee invoice was issued by the charging party.',
    `lpa_reference_clause` STRING COMMENT 'Specific clause or section in the LPA that governs this transaction fee and its treatment.',
    `notes` STRING COMMENT 'Free-form notes or comments regarding the transaction fee, including special circumstances or approvals.',
    `payment_date` DATE COMMENT 'Actual date on which the transaction fee was paid or settled.',
    `payment_method` STRING COMMENT 'Method by which the transaction fee was or will be paid to the charging party.. Valid values are `wire_transfer|ach|check|offset|escrow_release`',
    `payment_reference_number` STRING COMMENT 'Bank or treasury reference number for the fee payment transaction.',
    `rebate_amount` DECIMAL(18,2) COMMENT 'Amount of fee rebate or offset credited back to the LP from the GP under the LPA terms.',
    `rebate_policy_flag` BOOLEAN COMMENT 'Indicates whether this fee is subject to GP rebate or offset provisions under the LPA.',
    `service_description` STRING COMMENT 'Detailed description of the services rendered by the GP or advisor in connection with this transaction fee.',
    `tax_treatment` STRING COMMENT 'Tax classification of the transaction fee for corporate tax and LP tax reporting purposes.. Valid values are `deductible|non_deductible|capitalized|other`',
    `transaction_date` DATE COMMENT 'Date on which the underlying investment transaction occurred that triggered this fee.',
    `transaction_value_amount` DECIMAL(18,2) COMMENT 'Total value of the underlying investment transaction used as the basis for calculating the fee.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this transaction fee record was last modified in the system.',
    `variance_to_benchmark_bps` DECIMAL(8,2) COMMENT 'Difference in basis points between the actual fee rate and the benchmark rate, used for cost monitoring.',
    `waiver_approval_date` DATE COMMENT 'Date on which the fee waiver was formally approved by the GP or IC.',
    `waiver_flag` BOOLEAN COMMENT 'Indicates whether the transaction fee was waived by the GP or advisor.',
    `waiver_reason` STRING COMMENT 'Explanation of the business rationale for waiving the transaction fee.',
    CONSTRAINT pk_transaction_fee PRIMARY KEY(`transaction_fee_id`)
) COMMENT 'Transactional record of deal-level transaction fees charged by GPs or advisors in connection with private market investment transactions (acquisition fees, disposition fees, financing fees, monitoring fees).';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`gp_fee_rebate` (
    `gp_fee_rebate_id` BIGINT COMMENT 'Unique identifier for the GP fee rebate record.',
    `counterparty_id` BIGINT COMMENT 'Reference to the third-party fund administrator responsible for processing this rebate.',
    `fund_id` BIGINT COMMENT 'Reference to the private equity or alternative investment fund to which this rebate applies.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the General Partner entity responsible for the rebate.',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Fee rebates require GP profile linkage for tracking rebate entitlements, MFN clause compliance, and management fee offset reconciliation per mandate terms.',
    `lpa_terms_id` BIGINT COMMENT 'Reference to the Limited Partnership Agreement governing the rebate terms.',
    `portfolio_company_id` BIGINT COMMENT 'Reference to the portfolio company that generated the underlying fee subject to rebate, if applicable.',
    `transaction_fee_id` BIGINT COMMENT 'Reference to the specific investment transaction that generated the fee subject to rebate, if applicable.',
    `transaction_transaction_fee_id` BIGINT COMMENT 'Reference to the specific investment transaction that generated the fee subject to rebate, if applicable.',
    `application_date` DATE COMMENT 'Date on which the rebate was applied to the management fee invoice or accrual.',
    `approval_date` DATE COMMENT 'Date on which the rebate was formally approved.',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether this rebate requires Investment Committee or senior management approval before application.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee that approved the rebate.',
    `auditor_verification_date` DATE COMMENT 'Date on which the auditor completed verification of the rebate calculation.',
    `auditor_verified_flag` BOOLEAN COMMENT 'Indicates whether the rebate calculation has been verified by an external auditor.',
    `calculation_date` DATE COMMENT 'Date on which the rebate amount was calculated.',
    `calculation_methodology` STRING COMMENT 'Description of the methodology used to calculate the rebate, including formulas and LPA references.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this rebate record was first created in the system.',
    `cumulative_rebate_amount` DECIMAL(18,2) COMMENT 'Cumulative total of all rebates applied to date for this fund and GP relationship.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this rebate record.. Valid values are `^[A-Z]{3}$`',
    `dispute_flag` BOOLEAN COMMENT 'Indicates whether the rebate calculation or application is under dispute by the GP or LP.',
    `dispute_reason` STRING COMMENT 'Description of the reason for the dispute, if applicable.',
    `dispute_resolution_date` DATE COMMENT 'Date on which the dispute was resolved, if applicable.',
    `effective_date` DATE COMMENT 'Date from which the rebate becomes effective and is applied to management fee calculations.',
    `gross_fee_amount` DECIMAL(18,2) COMMENT 'Total gross amount of the fee earned by the GP before rebate application.',
    `lpa_section_reference` STRING COMMENT 'Specific section or clause in the LPA that governs this rebate provision.',
    `management_fee_offset_amount` DECIMAL(18,2) COMMENT 'Amount by which the management fee is reduced as a result of this rebate.',
    `notes` STRING COMMENT 'Free-text field for additional comments, clarifications, or special instructions related to the rebate.',
    `rebate_adjustment_amount` DECIMAL(18,2) COMMENT 'Any adjustment applied to the gross rebate amount due to timing differences, prior period corrections, or other factors.',
    `rebate_cap_amount` DECIMAL(18,2) COMMENT 'Maximum rebate amount allowed per LPA terms, if applicable.',
    `rebate_cap_applied_flag` BOOLEAN COMMENT 'Indicates whether the rebate cap was reached and applied to limit the rebate amount.',
    `rebate_gross_amount` DECIMAL(18,2) COMMENT 'Gross rebate amount calculated before any adjustments or offsets.',
    `rebate_net_amount` DECIMAL(18,2) COMMENT 'Net rebate amount after all adjustments, representing the final offset to management fees.',
    `rebate_number` STRING COMMENT 'Business identifier for the rebate transaction, typically assigned by the fund administrator or internal system.',
    `rebate_percentage` DECIMAL(5,4) COMMENT 'Percentage of the gross fee to be rebated to the fund as specified in the LPA, expressed as a decimal (e.g., 0.8000 for 80%).',
    `rebate_status` STRING COMMENT 'Current lifecycle status of the rebate record.. Valid values are `pending|calculated|approved|applied|disputed|cancelled`',
    `rebate_type` STRING COMMENT 'Classification of the rebate based on the type of fee being offset as defined in the LPA.. Valid values are `transaction_fee_offset|monitoring_fee_offset|advisory_fee_offset|director_fee_offset|broken_deal_fee_offset|other`',
    `reporting_period_end_date` DATE COMMENT 'End date of the reporting period to which this rebate applies.',
    `reporting_period_start_date` DATE COMMENT 'Start date of the reporting period to which this rebate applies.',
    `source_system_record_code` STRING COMMENT 'Unique identifier of this rebate record in the source operational system.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this rebate record was last modified.',
    CONSTRAINT pk_gp_fee_rebate PRIMARY KEY(`gp_fee_rebate_id`)
) COMMENT 'Master record tracking GP fee rebates and offsets applied to management fees as required under LPA terms. Captures rebate type (transaction fee offset, monitoring fee offset, advisory fee offset), rebate percentage per LPA, gross rebate amount earned in';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`carry_distribution` (
    `carry_distribution_id` BIGINT COMMENT 'Unique identifier for the carried interest distribution transaction.',
    `carry_escrow_id` BIGINT COMMENT 'Reference to the escrow account holding clawback reserves, if applicable.',
    `escrow_account_carry_escrow_id` BIGINT COMMENT 'Reference to the escrow account holding clawback reserves, if applicable.',
    `fund_id` BIGINT COMMENT 'Reference to the private equity fund or investment vehicle from which the carry is distributed.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the general partner entity receiving the carried interest distribution.',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Carry distributions need GP profile attribution for performance fee transparency reporting to pension beneficiaries and manager performance evaluation.',
    `investment_id` BIGINT COMMENT 'Reference to the specific underlying investment that triggered this carry distribution event.',
    `settlement_cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: Carried interest distributions to GPs require treasury cash account for payment execution.',
    `approval_date` DATE COMMENT 'Date on which the carry distribution was approved by the investment committee or authorized body.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee that approved the carry distribution.',
    `auditor_verification_date` DATE COMMENT 'Date on which the auditor completed verification of the carry distribution calculation.',
    `auditor_verified_flag` BOOLEAN COMMENT 'Indicates whether the carry distribution calculation has been verified by an independent auditor.',
    `calculation_methodology` STRING COMMENT 'Methodology used to calculate carry eligibility: deal-by-deal, whole fund, or hybrid approach.. Valid values are `deal_by_deal|whole_fund|hybrid`',
    `carry_gross_amount` DECIMAL(20,2) COMMENT 'Gross carried interest amount calculated before any catch-up provisions or adjustments.',
    `carry_net_amount` DECIMAL(20,2) COMMENT 'Net carried interest distributed to the general partner after all adjustments and provisions.',
    `carry_rate_percent` DECIMAL(5,2) COMMENT 'Percentage of profits allocated to the general partner as carried interest, typically 20 percent.',
    `catch_up_amount` DECIMAL(20,2) COMMENT 'Additional amount allocated to the general partner under catch-up provisions to achieve target carry split.',
    `clawback_reserve_amount` DECIMAL(20,2) COMMENT 'Amount withheld from this distribution and held in reserve to cover potential future clawback obligations.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this carry distribution record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this distribution.. Valid values are `^[A-Z]{3}$`',
    `distribution_date` DATE COMMENT 'Date on which the carried interest distribution was paid to the general partner.',
    `distribution_number` STRING COMMENT 'Business identifier for the carry distribution transaction, typically sequential within a fund.',
    `distribution_status` STRING COMMENT 'Current lifecycle status of the carry distribution transaction.. Valid values are `pending|approved|paid|cancelled|reversed`',
    `fund_irr_percent` DECIMAL(7,4) COMMENT 'Fund-level internal rate of return at the time of this distribution, used for carry eligibility determination.',
    `fund_moic` DECIMAL(7,4) COMMENT 'Fund-level multiple on invested capital at the time of this distribution.',
    `gross_proceeds_amount` DECIMAL(20,2) COMMENT 'Total proceeds realized from the investment event before any deductions or allocations.',
    `hurdle_rate_percent` DECIMAL(5,2) COMMENT 'Minimum annualized return threshold that must be achieved before carry is distributed to the general partner.',
    `investment_irr_percent` DECIMAL(7,4) COMMENT 'Investment-level internal rate of return for the specific asset that generated this distribution.',
    `investment_moic` DECIMAL(7,4) COMMENT 'Investment-level multiple on invested capital for the specific asset that generated this distribution.',
    `lpa_reference_section` STRING COMMENT 'Specific section or clause in the limited partnership agreement governing this carry distribution.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this carry distribution record was last modified.',
    `net_distribution_amount` DECIMAL(20,2) COMMENT 'Final net amount distributed to the general partner after all reserves, withholdings, and adjustments.',
    `notes` STRING COMMENT 'Additional comments or contextual information regarding the carry distribution transaction.',
    `payment_method` STRING COMMENT 'Method used to transfer the carry distribution to the general partner.. Valid values are `wire_transfer|ach|check|book_transfer`',
    `payment_reference_number` STRING COMMENT 'Bank or treasury reference number for the payment transaction.',
    `preferred_return_amount` DECIMAL(20,2) COMMENT 'Cumulative preferred return (hurdle rate) paid to limited partners before carry is distributed.',
    `profit_split_amount` DECIMAL(20,2) COMMENT 'Total profit available for distribution after return of capital and preferred return have been satisfied.',
    `realization_date` DATE COMMENT 'Date on which the underlying investment realization event occurred.',
    `realization_event_type` STRING COMMENT 'Type of liquidity event that triggered the carry distribution.. Valid values are `exit|recapitalization|ipo|secondary_sale|dividend_recapitalization|partial_exit`',
    `return_of_capital_amount` DECIMAL(20,2) COMMENT 'Portion of proceeds representing return of original invested capital to limited partners.',
    `tax_withholding_amount` DECIMAL(20,2) COMMENT 'Amount withheld for tax purposes from the gross carry distribution.',
    `waterfall_tier` STRING COMMENT 'Tier within the carry waterfall structure from which this distribution was paid, reflecting performance thresholds.. Valid values are `tier_1|tier_2|tier_3|tier_4`',
    CONSTRAINT pk_carry_distribution PRIMARY KEY(`carry_distribution_id`)
) COMMENT 'Transactional record of carried interest distributions paid to a GP following a realized investment event (exit, recapitalization, IPO). Captures distribution date, fund/vehicle reference, realized proceeds, return of capital amount, preferred return';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`carry_escrow` (
    `carry_escrow_id` BIGINT COMMENT 'Unique identifier for the carried interest escrow account record. Primary key for the carry_escrow product.',
    `cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: Carry escrow reserves are held in treasury-managed cash accounts for potential clawback obligations.',
    `counterparty_id` BIGINT COMMENT 'Reference to the financial institution or escrow agent holding the carried interest escrow funds.',
    `fund_id` BIGINT COMMENT 'Reference to the private equity or alternative investment fund for which this escrow account was established.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the General Partner legal entity subject to potential clawback obligations secured by this escrow.',
    `auditor_verified_flag` BOOLEAN COMMENT 'Indicates whether the escrow account balance and calculations have been verified by external auditors as part of fund audit procedures.',
    `clawback_amount_applied` DECIMAL(18,2) COMMENT 'Total amount drawn from this escrow account to satisfy clawback obligations to LPs.',
    `clawback_triggered_flag` BOOLEAN COMMENT 'Indicates whether a clawback event has been triggered requiring funds from this escrow account to be returned to Limited Partners (LPs).',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp indicating when this escrow account record was first created in the data platform.',
    `cumulative_carry_distributed_amount` DECIMAL(18,2) COMMENT 'Total carried interest distributed to the GP since fund inception, used to calculate the escrow withholding base.',
    `cumulative_escrow_withheld_amount` DECIMAL(18,2) COMMENT 'Total amount withheld in escrow across all carried interest distributions to date for this fund and GP.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the escrow amount (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `dispute_description` STRING COMMENT 'Detailed description of the nature of the dispute affecting the escrow account, including parties involved and contested amounts.',
    `dispute_flag` BOOLEAN COMMENT 'Indicates whether the escrow account is subject to a dispute between GP and LPs regarding clawback calculations or release terms.',
    `dispute_resolution_date` DATE COMMENT 'Date on which the dispute was formally resolved, allowing escrow operations to resume per the resolution terms.',
    `escrow_account_name` STRING COMMENT 'Legal name or title of the escrow account as registered with the custodian or escrow agent.',
    `escrow_account_number` STRING COMMENT 'External bank or custodian account number for the escrow account holding the carried interest funds.',
    `escrow_amount` DECIMAL(18,2) COMMENT 'Total monetary value of carried interest distributions currently held in escrow to secure potential clawback obligations.',
    `escrow_percentage` DECIMAL(5,2) COMMENT 'Percentage of gross carried interest distributions withheld in escrow, typically ranging from 10% to 50% per LPA provisions.',
    `escrow_status` STRING COMMENT 'Current lifecycle status of the escrow account indicating whether funds are held, released, or subject to dispute.. Valid values are `active|released|partially_released|expired|disputed|closed`',
    `establishment_date` DATE COMMENT 'Date on which the escrow account was formally established and funded per the Limited Partnership Agreement (LPA) provisions.',
    `expiration_date` DATE COMMENT 'Final date after which the escrow obligation terminates and any remaining funds are released to the GP, typically tied to fund liquidation or statute of limitations.',
    `interest_accrual_flag` BOOLEAN COMMENT 'Indicates whether the escrow account accrues interest on held funds per LPA terms.',
    `interest_allocation_method` STRING COMMENT 'Method by which interest earned on escrow funds is allocated among General Partner (GP), Limited Partners (LPs), or the fund.. Valid values are `gp|lp|pro_rata|fund`',
    `interest_earned_amount` DECIMAL(18,2) COMMENT 'Total interest earned on escrow funds to date, which may be allocated to GP or LPs per LPA terms.',
    `interest_rate_percent` DECIMAL(5,4) COMMENT 'Annual interest rate applied to escrow funds if interest accrual is enabled, expressed as a percentage.',
    `investor_disclosure_flag` BOOLEAN COMMENT 'Indicates whether escrow details are disclosed to Limited Partners (LPs) in quarterly or annual investor reports.',
    `last_audit_date` DATE COMMENT 'Date of the most recent external audit verification of the escrow account balance and related calculations.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'System timestamp indicating when this escrow account record was most recently updated.',
    `legal_counsel_opinion_flag` BOOLEAN COMMENT 'Indicates whether external legal counsel has provided a formal opinion on the escrow structure and clawback enforceability.',
    `lpa_reference_section` STRING COMMENT 'Specific section or article reference in the LPA governing the escrow provisions and clawback mechanics.',
    `next_release_amount` DECIMAL(18,2) COMMENT 'Amount scheduled to be released on the next release date per the LPA release schedule.',
    `next_release_date` DATE COMMENT 'Next scheduled date on which a portion of the escrow funds is eligible for release to the GP per the release schedule.',
    `notes` STRING COMMENT 'Free-form text field for additional context, special conditions, or operational notes related to the escrow account.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this escrow account must be disclosed in regulatory filings or investor reports per applicable securities regulations.',
    `release_date` DATE COMMENT 'Date on which the escrow funds were released to the General Partner (GP) or became eligible for release per LPA terms.',
    `release_schedule_type` STRING COMMENT 'Type of release schedule governing when escrow funds are released: single release, periodic tranches, milestone-based, or performance-based.. Valid values are `single|periodic|milestone|performance`',
    `release_trigger_condition` STRING COMMENT 'Business condition or event that triggers release of escrow funds, such as fund liquidation, passage of time, or achievement of performance thresholds.',
    `released_amount` DECIMAL(18,2) COMMENT 'Total amount released from escrow to the GP to date, reflecting partial or full releases per LPA terms.',
    `remaining_balance` DECIMAL(18,2) COMMENT 'Current balance remaining in the escrow account after accounting for releases and any clawback settlements.',
    CONSTRAINT pk_carry_escrow PRIMARY KEY(`carry_escrow_id`)
) COMMENT 'Master record tracking carried interest escrow accounts established to protect LP interests against potential clawback obligations. Captures escrow account reference, GP counterparty, escrow amount held, escrow percentage (of gross carry distributions)';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`fee_benchmark` (
    `fee_benchmark_id` BIGINT COMMENT 'Unique identifier for the external manager fee benchmark record.',
    `data_vendor_id` BIGINT COMMENT 'Foreign key linking to research.data_vendor. Business justification: Fee benchmarks (management fee medians, carry percentiles by strategy/vintage) are sourced from specialized data vendors (Preqin, Cambridge Associates, Burgiss).',
    `approval_date` DATE COMMENT 'Date on which the benchmark data was reviewed and approved for use by the investment operations or procurement team.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee that approved the benchmark for operational use.',
    `asset_class` STRING COMMENT 'Primary asset class category to which this fee benchmark applies for manager selection and fee negotiation.. Valid values are `public_equities|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `benchmark_code` STRING COMMENT 'Short alphanumeric code uniquely identifying the fee benchmark within the organizations reference data system.',
    `benchmark_name` STRING COMMENT 'Descriptive name of the fee benchmark used for identification and reporting purposes.',
    `benchmark_status` STRING COMMENT 'Current lifecycle status of the benchmark record indicating whether it is actively used for fee assessments or has been retired.. Valid values are `active|superseded|archived|under_review`',
    `carried_interest_25th_percentile_percent` DECIMAL(5,4) COMMENT 'Twenty-fifth percentile carried interest rate representing the lower quartile of the benchmark distribution.',
    `carried_interest_75th_percentile_percent` DECIMAL(5,4) COMMENT 'Seventy-fifth percentile carried interest rate representing the upper quartile of the benchmark distribution.',
    `carried_interest_median_percent` DECIMAL(5,4) COMMENT 'Median carried interest rate as a percentage of profits above the hurdle rate observed in the benchmark peer group.',
    `catch_up_provision_prevalence_percent` DECIMAL(5,2) COMMENT 'Percentage of funds in the benchmark cohort that include a catch-up provision allowing GPs to receive a higher share of profits after the hurdle is met.',
    `clawback_provision_prevalence_percent` DECIMAL(5,2) COMMENT 'Percentage of funds in the benchmark cohort that include clawback provisions requiring GPs to return excess carried interest if final fund performance falls below agreed thresholds.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this benchmark record was first created in the system.',
    `data_source` STRING COMMENT 'Name of the external data provider or research firm that compiled the benchmark data (e.g., Preqin, PitchBook, Cambridge Associates).',
    `data_source_report_reference` STRING COMMENT 'Specific report title, publication identifier, or URL reference from the data source for audit trail and verification purposes.',
    `effective_end_date` DATE COMMENT 'Date on which this benchmark record ceases to be valid, typically when superseded by updated benchmark data.',
    `effective_start_date` DATE COMMENT 'Date from which this benchmark record is considered valid and applicable for fee negotiations and manager evaluations.',
    `fund_size_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for fund size bounds (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `fund_size_lower_bound_amount` DECIMAL(18,2) COMMENT 'Minimum fund size (Assets Under Management) in millions for which this benchmark is applicable, enabling size-cohort comparisons.',
    `fund_size_upper_bound_amount` DECIMAL(18,2) COMMENT 'Maximum fund size (Assets Under Management) in millions for which this benchmark is applicable, defining the upper limit of the size cohort.',
    `geographic_focus` STRING COMMENT 'Primary geographic region or market focus for the benchmark (e.g., North America, Europe, Asia-Pacific, Global).',
    `hurdle_rate_25th_percentile_percent` DECIMAL(5,4) COMMENT 'Twenty-fifth percentile hurdle rate representing the lower quartile of the benchmark distribution.',
    `hurdle_rate_75th_percentile_percent` DECIMAL(5,4) COMMENT 'Seventy-fifth percentile hurdle rate representing the upper quartile of the benchmark distribution.',
    `hurdle_rate_median_percent` DECIMAL(5,4) COMMENT 'Median preferred return threshold (hurdle rate) that must be achieved before General Partners (GPs) earn carried interest, observed in the benchmark peer group.',
    `management_fee_25th_percentile_percent` DECIMAL(5,4) COMMENT 'Twenty-fifth percentile management fee rate representing the lower quartile of the benchmark distribution, indicating competitive fee levels.',
    `management_fee_75th_percentile_percent` DECIMAL(5,4) COMMENT 'Seventy-fifth percentile management fee rate representing the upper quartile of the benchmark distribution.',
    `management_fee_median_percent` DECIMAL(5,4) COMMENT 'Median management fee rate as a percentage of committed capital or net asset value observed in the benchmark peer group.',
    `most_favored_nation_prevalence_percent` DECIMAL(5,2) COMMENT 'Percentage of funds in the benchmark cohort that include Most Favored Nation clauses ensuring Limited Partners (LPs) receive fee terms no less favorable than those granted to other LPs.',
    `publication_date` DATE COMMENT 'Date on which the benchmark data was published or made available by the data source.',
    `sample_size_count` BIGINT COMMENT 'Number of funds or manager mandates included in the benchmark calculation, indicating statistical robustness of the benchmark data.',
    `strategy_type` STRING COMMENT 'Specific investment strategy or sub-asset class for which the benchmark fee data is applicable (e.g., growth equity, value-add real estate, core infrastructure).',
    `usage_notes` STRING COMMENT 'Free-text field capturing guidance on how to apply the benchmark, any known limitations, or special considerations for fee negotiations.',
    `vintage_year` BIGINT COMMENT 'The year in which the benchmark data was collected or the fund cohort was established, critical for time-series fee trend analysis.',
    CONSTRAINT pk_fee_benchmark PRIMARY KEY(`fee_benchmark_id`)
) COMMENT 'Master record of external manager fee benchmarks used to assess the competitiveness of management fee and carried interest terms across the funds manager universe.';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`rate_schedule` (
    `rate_schedule_id` BIGINT COMMENT 'Unique identifier for the fee rate schedule. Primary key.',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Rate schedules are negotiated with specific GPs; linkage enables fee benchmarking across managers and tracking negotiation history for future mandate discussions.',
    `manager_mandate_id` BIGINT COMMENT 'Foreign key linking to manager.manager_mandate. Business justification: Rate schedules are mandate-specific fee terms; direct linkage required for fee calculation runs and contractual compliance verification.',
    `superseded_by_schedule_rate_schedule_id` BIGINT COMMENT 'Identifier of the rate schedule that supersedes this schedule when a new version is created or terms are updated.',
    `approval_date` DATE COMMENT 'Date on which this rate schedule was formally approved by the Investment Committee (IC) or authorized governance body.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee that approved this rate schedule for use in fee calculations.',
    `asset_class` STRING COMMENT 'Asset class to which this rate schedule applies, such as public equities, private equity, real estate, infrastructure, or credit. [ENUM-REF-CANDIDATE',
    `benchmark_index_code` STRING COMMENT 'Code identifying the benchmark index used for performance fee calculations or hurdle rate determination under this schedule.',
    `calculation_frequency` STRING COMMENT 'Frequency at which fees are calculated using this rate schedule, such as daily, monthly, quarterly, or annually.. Valid values are `daily|monthly|quarterly|semi_annually|annually`',
    `calculation_method` STRING COMMENT 'Methodology used to compute fees from this schedule, including flat rate, tiered blended, tiered marginal, or performance-based methods.. Valid values are `flat_rate|tiered_blended|tiered_marginal|performance_hurdle|high_water_mark`',
    `carry_rate_percent` DECIMAL(8,4) COMMENT 'Percentage of profits allocated to the General Partner (GP) as carried interest after hurdle and catch-up provisions are satisfied.',
    `catch_up_rate_percent` DECIMAL(8,4) COMMENT 'Rate applied to returns above the hurdle rate until the General Partner (GP) receives their full carried interest allocation.',
    `clawback_provision_flag` BOOLEAN COMMENT 'Indicates whether this rate schedule includes clawback provisions requiring return of carried interest if fund performance falls below thresholds.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this rate schedule record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which fee amounts and thresholds are denominated.. Valid values are `^[A-Z]{3}$`',
    `effective_end_date` DATE COMMENT 'Date on which this rate schedule ceases to be active. Null indicates an open-ended schedule with no expiration.',
    `effective_start_date` DATE COMMENT 'Date on which this rate schedule becomes active and applicable for fee calculations.',
    `fee_basis` STRING COMMENT 'The base metric upon which the fee rate is applied, such as Assets Under Management (AUM), Net Asset Value (NAV), or committed capital.. Valid values are `aum|nav|committed_capital|invested_capital|gav|transaction_value`',
    `fee_offset_provision_flag` BOOLEAN COMMENT 'Indicates whether this rate schedule includes provisions for offsetting management fees against transaction fees or other fee types.',
    `fee_type` STRING COMMENT 'Classification of the fee to which this rate schedule applies, such as management fee, performance fee, or transaction fee.. Valid values are `management_fee|performance_fee|transaction_fee|advisory_fee|administration_fee|custody_fee`',
    `geography_scope` STRING COMMENT 'Geographic scope or region to which this rate schedule applies, such as global, North America, Europe, Asia Pacific, or emerging markets.. Valid values are `global|north_america|europe|asia_pacific|emerging_markets|domestic`',
    `high_water_mark_flag` BOOLEAN COMMENT 'Indicates whether performance fees under this schedule are subject to a high water mark provision, ensuring fees are only charged on net new profits.',
    `hurdle_rate_percent` DECIMAL(8,4) COMMENT 'Minimum return threshold that must be achieved before performance fees are calculated. Also known as preferred return.',
    `investment_strategy` STRING COMMENT 'Investment strategy or mandate type to which this rate schedule applies, such as growth equity, value, core-plus real estate, or distressed credit.',
    `investor_type` STRING COMMENT 'Type of investor or client segment to which this rate schedule applies, such as institutional, retail, high net worth, or pension funds.. Valid values are `institutional|retail|high_net_worth|sovereign_wealth|endowment|pension`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this rate schedule record was last updated or modified in the system.',
    `lpa_reference_section` STRING COMMENT 'Section or clause reference in the Limited Partnership Agreement (LPA) or mandate document that defines this rate schedule.',
    `maximum_fee_amount` DECIMAL(18,2) COMMENT 'Ceiling amount for fees calculated under this schedule. If the computed fee exceeds this amount, the maximum fee is charged instead.',
    `minimum_fee_amount` DECIMAL(18,2) COMMENT 'Floor amount for fees calculated under this schedule. If the computed fee is below this amount, the minimum fee is charged instead.',
    `most_favored_nation_flag` BOOLEAN COMMENT 'Indicates whether this rate schedule includes a Most Favored Nation clause ensuring the investor receives the best fee terms offered to any investor.',
    `notes` STRING COMMENT 'Free-text field for additional notes, comments, or special conditions related to this rate schedule.',
    `offset_percentage` DECIMAL(5,2) COMMENT 'Percentage of transaction fees or other fees that are offset against management fees when fee offset provisions apply.',
    `payment_frequency` STRING COMMENT 'Frequency at which calculated fees are invoiced and paid, such as monthly, quarterly, or annually.. Valid values are `monthly|quarterly|semi_annually|annually|on_demand`',
    `regulatory_reporting_category` STRING COMMENT 'Classification of this rate schedule for regulatory reporting purposes under frameworks such as SFDR, MiFID II, or GIPS.',
    `schedule_code` STRING COMMENT 'Short alphanumeric code uniquely identifying this rate schedule in operational systems and fee calculations.',
    `schedule_name` STRING COMMENT 'Business name or label assigned to this fee rate schedule for identification and reference purposes.',
    `schedule_status` STRING COMMENT 'Current lifecycle status of the rate schedule indicating whether it is draft, active, suspended, expired, or superseded by a newer version.. Valid values are `draft|active|suspended|expired|superseded`',
    `tier_1_rate_bps` DECIMAL(8,4) COMMENT 'Fee rate applicable to tier 1 expressed in basis points. One basis point equals 0.01 percent.',
    `tier_1_threshold_amount` DECIMAL(20,2) COMMENT 'Lower bound amount for the first tier in a tiered fee schedule. Amounts at or above this threshold apply the tier 1 rate.',
    `tier_2_rate_bps` DECIMAL(8,4) COMMENT 'Fee rate applicable to tier 2 expressed in basis points. One basis point equals 0.01 percent.',
    `tier_2_threshold_amount` DECIMAL(20,2) COMMENT 'Lower bound amount for the second tier in a tiered fee schedule. Amounts at or above this threshold apply the tier 2 rate.',
    `tier_3_rate_bps` DECIMAL(8,4) COMMENT 'Fee rate applicable to tier 3 expressed in basis points. One basis point equals 0.01 percent.',
    `tier_3_threshold_amount` DECIMAL(20,2) COMMENT 'Lower bound amount for the third tier in a tiered fee schedule. Amounts at or above this threshold apply the tier 3 rate.',
    `tier_4_rate_bps` DECIMAL(8,4) COMMENT 'Fee rate applicable to tier 4 expressed in basis points. One basis point equals 0.01 percent.',
    `tier_4_threshold_amount` DECIMAL(20,2) COMMENT 'Lower bound amount for the fourth tier in a tiered fee schedule. Amounts at or above this threshold apply the tier 4 rate.',
    `tier_5_rate_bps` DECIMAL(8,4) COMMENT 'Fee rate applicable to tier 5 expressed in basis points. One basis point equals 0.01 percent.',
    `tier_5_threshold_amount` DECIMAL(20,2) COMMENT 'Lower bound amount for the fifth tier in a tiered fee schedule. Amounts at or above this threshold apply the tier 5 rate.',
    `version_number` BIGINT COMMENT 'Version number of this rate schedule, incremented when amendments or updates are made to the schedule terms.',
    CONSTRAINT pk_rate_schedule PRIMARY KEY(`rate_schedule_id`)
) COMMENT 'Reference entity defining tiered fee rate schedules applied during fee computation. Captures rate schedule name, fee type, AUM/NAV tier breakpoints, applicable fee rate per tier (bps), blended rate calculation method, currency, and effective/expiry dates.';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`fee_calculation_run` (
    `fee_calculation_run_id` BIGINT COMMENT 'Unique identifier for the fee calculation run. Primary key.',
    `employee_id` BIGINT COMMENT 'Reference to the external manager or General Partner (GP) entity receiving the fee.',
    `external_manager_gp_profile_id` BIGINT COMMENT 'Reference to the external manager or General Partner (GP) entity receiving the fee.',
    `fee_benchmark_id` BIGINT COMMENT 'Foreign key linking to fee.fee_benchmark. Business justification: Connect fee_calculation_run to fee_benchmark to link benchmark data used in fee calculations. Remove redundant benchmark_index_code.',
    `fund_id` BIGINT COMMENT 'Reference to the fund or investment vehicle for which fees are being calculated.',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Fee calculation audit trail requires GP attribution for reconciliation with manager invoices and fee dispute resolution processes.',
    `investment_id` BIGINT COMMENT 'Reference to the specific investment position for which fees are being calculated, if applicable.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the investment mandate or external manager mandate for which fees are being calculated.',
    `original_run_fee_calculation_run_id` BIGINT COMMENT 'Reference to the original fee calculation run if this is a recalculation or correction.',
    `performance_calculation_run_id` BIGINT COMMENT 'Foreign key linking to performance.performance_calculation_run. Business justification: Performance-based fee calculations (incentive fees, carry) require validated performance data.',
    `valuation_cycle_id` BIGINT COMMENT 'Foreign key linking to valuation.cycle. Business justification: Fee calculations (management fees, performance fees) require specific valuation cycle data as basis.',
    `accrual_flag` BOOLEAN COMMENT 'Indicates whether this calculation run is for accrual purposes or actual payment processing.',
    `adjustment_amount` DECIMAL(20,2) COMMENT 'Any manual or system-generated adjustments applied to the fee calculation.',
    `approval_date` DATE COMMENT 'The date on which the fee calculation run was approved by the Investment Committee (IC) or authorized personnel.',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether this fee calculation run requires Investment Committee (IC) or management approval before payment.',
    `approved_by` STRING COMMENT 'Name or identifier of the person or committee who approved the fee calculation run.',
    `aum_basis_amount` DECIMAL(20,2) COMMENT 'The Assets Under Management value used as the basis for calculating management fees.',
    `basis_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the basis amount used in the fee calculation.. Valid values are `^[A-Z]{3}$`',
    `calculation_date` DATE COMMENT 'The date on which the fee calculation was executed or processed.',
    `calculation_engine` STRING COMMENT 'The system or software module that executed the fee calculation, such as SimCorp Dimension or BlackRock Aladdin.',
    `calculation_frequency` STRING COMMENT 'The periodic frequency at which this fee calculation is executed. [ENUM-REF-CANDIDATE: daily|weekly|monthly|quarterly|semi_annually|annually|ad_hoc — 7 candidates stripped; promote to reference product]',
    `calculation_methodology` STRING COMMENT 'Description of the calculation methodology applied, including any specific formulas, waterfall structures, or computational approaches.',
    `calculation_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the fee calculation run was executed, including time zone information.',
    `calculation_version` STRING COMMENT 'Version number or identifier of the calculation logic or rule set applied in this run.',
    `carry_rate_percent` DECIMAL(8,5) COMMENT 'The percentage of profits allocated to the General Partner (GP) as carried interest.',
    `catch_up_provision_applied_flag` BOOLEAN COMMENT 'Indicates whether a catch-up provision was applied to allow the General Partner (GP) to receive additional carried interest after the hurdle is met.',
    `committed_capital_amount` DECIMAL(20,2) COMMENT 'The total committed capital amount used as the basis for fee calculation in private equity structures.',
    `cost_center_code` STRING COMMENT 'The internal cost center or business unit code to which the fee expense is allocated.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this fee calculation run record was first created in the system.',
    `fee_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the calculated fee amounts.. Valid values are `^[A-Z]{3}$`',
    `fee_rate_percent` DECIMAL(8,5) COMMENT 'The percentage rate applied to the basis amount to calculate the gross fee.',
    `fee_type` STRING COMMENT 'Category of fee being calculated in this run, such as management fee, carried interest, or transaction fee.. Valid values are `management_fee|performance_fee|carried_interest|transaction_fee|advisory_fee|administration_fee`',
    `fund_irr_percent` DECIMAL(8,5) COMMENT 'The Internal Rate of Return achieved by the fund during the calculation period, used for performance fee assessment.',
    `gl_account_code` STRING COMMENT 'The General Ledger account code to which the calculated fee will be posted for accounting purposes.',
    `gross_fee_amount` DECIMAL(20,2) COMMENT 'The total fee amount calculated before any offsets, rebates, or adjustments.',
    `hurdle_met_flag` BOOLEAN COMMENT 'Indicates whether the hurdle rate threshold was met or exceeded in this calculation period.',
    `hurdle_rate_percent` DECIMAL(8,5) COMMENT 'The preferred return threshold that must be achieved before carried interest or performance fees are calculated.',
    `invested_capital_amount` DECIMAL(20,2) COMMENT 'The total invested or paid-in capital amount used as the basis for fee calculation.',
    `lpa_reference_clause` STRING COMMENT 'The specific section or clause in the Limited Partnership Agreement (LPA) that governs this fee calculation.',
    `nav_basis_amount` DECIMAL(20,2) COMMENT 'The Net Asset Value used as the basis for fee calculation, particularly for private market investments.',
    `net_fee_amount` DECIMAL(20,2) COMMENT 'The final fee amount after applying all offsets, rebates, and adjustments.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding the fee calculation run, including any special circumstances or manual adjustments.',
    `offset_amount` DECIMAL(20,2) COMMENT 'The amount of fee offset or rebate applied, such as transaction fee rebates or General Partner (GP) fee offsets.',
    `payment_due_date` DATE COMMENT 'The date by which the calculated fee is due for payment to the external manager or General Partner (GP).',
    `performance_benchmark_code` STRING COMMENT 'The benchmark index or reference code used to evaluate performance for performance fee calculations.',
    `period_end_date` DATE COMMENT 'The ending date of the period for which fees are being calculated.',
    `period_start_date` DATE COMMENT 'The beginning date of the period for which fees are being calculated.',
    `recalculation_flag` BOOLEAN COMMENT 'Indicates whether this run is a recalculation of a previously executed fee calculation.',
    `run_number` STRING COMMENT 'Business-friendly identifier or sequence number for the calculation run, used for tracking and reporting purposes.',
    `run_status` STRING COMMENT 'Current lifecycle status of the fee calculation run indicating its workflow state. [ENUM-REF-CANDIDATE: draft|pending|in_progress|completed|approved|rejected|cancelled — 7 candidates stripped; promote to reference product]',
    `tiered_rate_applied_flag` BOOLEAN COMMENT 'Indicates whether a tiered fee schedule was applied in this calculation run.',
    CONSTRAINT pk_fee_calculation_run PRIMARY KEY(`fee_calculation_run_id`)
) COMMENT 'Transactional record of each periodic fee calculation run executed for management fees, carried interest, or other investment-related fees. Captures calculation run date, fee type, calculation period, AUM/NAV basis used, rate applied, gross fee computed';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`dispute` (
    `dispute_id` BIGINT COMMENT 'Unique identifier for the fee dispute record.',
    `assigned_to_user_employee_id` BIGINT COMMENT 'Reference to the internal user or team member currently responsible for managing and resolving the dispute.',
    `external_manager_gp_profile_id` BIGINT COMMENT 'Reference to the external manager or General Partner (GP) against whom the dispute is raised.',
    `fund_id` BIGINT COMMENT 'Reference to the fund or investment vehicle associated with the disputed fee.',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Fee disputes must be attributed to specific GPs for relationship management, escalation tracking, and manager evaluation/watchlist processes.',
    `identified_by_user_employee_id` BIGINT COMMENT 'Reference to the internal user or analyst who identified and raised the fee dispute.',
    `investment_id` BIGINT COMMENT 'Reference to the specific investment or co-investment associated with the disputed fee, if applicable.',
    `manager_mandate_id` BIGINT COMMENT 'Foreign key linking to manager.manager_mandate. Business justification: Disputes reference specific mandate terms (LPA clauses); mandate linkage required for contractual interpretation and resolution documentation.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_asset_valuation. Business justification: Fee disputes frequently stem from valuation disagreements. When LPs challenge fees, linking to specific asset valuations enables root cause analysis.',
    `auditor_notification_date` DATE COMMENT 'Date when the external auditor was formally notified of the fee dispute.',
    `auditor_notified_flag` BOOLEAN COMMENT 'Indicates whether the external auditor has been notified of the dispute for financial reporting and audit trail purposes.',
    `dispute_category` STRING COMMENT 'Categorization of the root cause or nature of the fee dispute.. Valid values are `calculation_error|unauthorized_charge|lpa_non_compliance|rate_discrepancy|timing_error|documentation_missing`',
    `claimed_amount` DECIMAL(18,2) COMMENT 'Amount that the external manager or General Partner (GP) originally claimed or charged.',
    `correct_amount` DECIMAL(18,2) COMMENT 'Amount that the pension fund believes is the correct fee based on Limited Partnership Agreement (LPA) terms and calculations.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the dispute record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter International Organization for Standardization (ISO) 4217 currency code for all monetary amounts in this dispute.. Valid values are `^[A-Z]{3}$`',
    `dispute_status` STRING COMMENT 'Current lifecycle status of the fee dispute in the resolution workflow.. Valid values are `open|under_review|escalated|resolved|closed|withdrawn`',
    `dispute_type` STRING COMMENT 'Classification of the fee type that is subject to dispute.. Valid values are `management_fee|carried_interest|transaction_fee|monitoring_fee|advisory_fee|other`',
    `disputed_amount` DECIMAL(18,2) COMMENT 'Total monetary amount of the fee that is under dispute.',
    `escalation_date` DATE COMMENT 'Date when the dispute was escalated to a higher authority or arbitration process.',
    `escalation_flag` BOOLEAN COMMENT 'Indicates whether the dispute has been escalated to senior management, legal counsel, or arbitration due to inability to resolve at operational level.',
    `escalation_level` STRING COMMENT 'Level to which the dispute has been escalated for resolution.. Valid values are `senior_management|legal_counsel|arbitration|litigation`',
    `fee_period_end_date` DATE COMMENT 'End date of the fee calculation period that is subject to dispute.',
    `fee_period_start_date` DATE COMMENT 'Start date of the fee calculation period that is subject to dispute.',
    `impact_on_nav_flag` BOOLEAN COMMENT 'Indicates whether the dispute and its resolution have a material impact on the fund Net Asset Value (NAV) calculation requiring restatement.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the dispute record was last updated or modified.',
    `lpa_reference_clause` STRING COMMENT 'Specific section, article, or clause number in the Limited Partnership Agreement (LPA) that governs the disputed fee calculation or terms.',
    `manager_response` STRING COMMENT 'Detailed response provided by the external manager or General Partner (GP) addressing the dispute, including their justification or acknowledgment.',
    `materiality_threshold_exceeded_flag` BOOLEAN COMMENT 'Indicates whether the disputed amount exceeds the materiality threshold requiring Investment Committee (IC) or senior management notification.',
    `notification_date` DATE COMMENT 'Date when the external manager or General Partner (GP) was formally notified of the dispute.',
    `number` STRING COMMENT 'Externally-known unique reference number assigned to the fee dispute for tracking and communication purposes.',
    `priority` STRING COMMENT 'Priority level assigned to the dispute based on materiality, urgency, and business impact.. Valid values are `low|medium|high|critical`',
    `raised_date` DATE COMMENT 'Date when the fee dispute was formally raised by the investment team or operations.',
    `reason` STRING COMMENT 'Detailed explanation of why the fee is being disputed, including specific calculation errors, unauthorized charges, or Limited Partnership Agreement (LPA) non-compliance issues.',
    `refund_amount` DECIMAL(18,2) COMMENT 'Amount to be refunded or credited to the pension fund following dispute resolution.',
    `refund_due_flag` BOOLEAN COMMENT 'Indicates whether a refund or credit is due to the pension fund as a result of the dispute resolution.',
    `refund_received_date` DATE COMMENT 'Date when the refund or credit was received from the external manager or General Partner (GP).',
    `resolution_date` DATE COMMENT 'Date when the fee dispute was formally resolved or closed.',
    `resolution_notes` STRING COMMENT 'Detailed notes documenting the resolution process, agreements reached, and any special conditions or future preventive measures.',
    `resolution_outcome` STRING COMMENT 'Final outcome of the dispute resolution process indicating how the dispute was concluded.. Valid values are `fee_adjusted|fee_upheld|partial_adjustment|withdrawn|escalated_to_arbitration`',
    `resolved_amount` DECIMAL(18,2) COMMENT 'Final agreed-upon fee amount after dispute resolution, which may differ from both claimed and correct amounts due to negotiation.',
    `response_due_date` DATE COMMENT 'Date by which the external manager or General Partner (GP) is required to respond to the dispute.',
    `response_received_date` DATE COMMENT 'Date when the external manager or General Partner (GP) provided their formal response to the dispute.',
    `supporting_documentation_flag` BOOLEAN COMMENT 'Indicates whether all required supporting documentation (invoices, calculations, Limited Partnership Agreement (LPA) excerpts) has been collected and attached to the dispute.',
    `variance_amount` DECIMAL(18,2) COMMENT 'Calculated difference between the claimed amount and the correct amount (claimed minus correct).',
    CONSTRAINT pk_dispute PRIMARY KEY(`dispute_id`)
) COMMENT 'Transactional record of fee disputes raised against external managers or GPs regarding incorrect fee calculations, unauthorized charges, or LPA non-compliance.';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`waiver` (
    `waiver_id` BIGINT COMMENT 'Unique identifier for the management fee waiver record.',
    `approved_by_user_employee_id` BIGINT COMMENT 'Reference to the user or Investment Committee (IC) member who authorized the fee waiver.',
    `employee_id` BIGINT COMMENT 'Reference to the user or Investment Committee (IC) member who authorized the fee waiver.',
    `fund_id` BIGINT COMMENT 'Reference to the fund receiving the management fee waiver.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the General Partner entity granting the fee waiver.',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Fee waivers granted to GPs require profile linkage for MFN clause compliance monitoring and tracking preferential terms across manager relationships.',
    `manager_mandate_id` BIGINT COMMENT 'Foreign key linking to manager.manager_mandate. Business justification: Waivers are mandate-specific per side letter terms; linkage enables fee schedule reconciliation and ensures waiver application to correct mandate.',
    `amount_cap` DECIMAL(18,2) COMMENT 'Maximum cumulative fee waiver amount that can be granted under this arrangement, if capped.',
    `application_frequency` STRING COMMENT 'Frequency at which the fee waiver is applied to management fee calculations.. Valid values are `quarterly|semi_annually|annually|per_transaction|continuous`',
    `approval_date` DATE COMMENT 'Date when the fee waiver was formally approved by the General Partner (GP) or Investment Committee (IC).',
    `auditor_verification_date` DATE COMMENT 'Date when external auditors last verified the fee waiver arrangement and calculations.',
    `auditor_verified_flag` BOOLEAN COMMENT 'Indicates whether the fee waiver calculation and application has been verified by external auditors.',
    `basis_points` BIGINT COMMENT 'Fee reduction expressed in basis points, commonly used for institutional fee negotiations.',
    `benchmark_fee_rate_percent` DECIMAL(5,4) COMMENT 'Standard management fee rate before application of the waiver, used for variance analysis.',
    `calculation_methodology` STRING COMMENT 'Detailed description of how the fee waiver is calculated and applied to management fee invoices.',
    `co_investment_linkage_flag` BOOLEAN COMMENT 'Indicates whether the fee waiver is contingent upon Limited Partner (LP) participation in co-investment opportunities.',
    `commitment_threshold_amount` DECIMAL(18,2) COMMENT 'Minimum capital commitment amount required to qualify for the fee waiver, if applicable.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this fee waiver record was first created in the system.',
    `cumulative_waiver_amount` DECIMAL(18,2) COMMENT 'Total cumulative fee reduction granted to date under this waiver arrangement.',
    `currency_code` STRING COMMENT 'Three-letter International Organization for Standardization (ISO) 4217 currency code for waiver amounts.. Valid values are `^[A-Z]{3}$`',
    `effective_end_date` DATE COMMENT 'Date when the fee waiver arrangement expires or terminates, nullable for open-ended waivers.',
    `effective_start_date` DATE COMMENT 'Date when the fee waiver arrangement becomes effective and begins reducing management fees.',
    `fee_transparency_disclosure_flag` BOOLEAN COMMENT 'Indicates whether this waiver must be disclosed in fee transparency reports to Limited Partners (LPs) or regulators.',
    `ic_approval_date` DATE COMMENT 'Date when the Investment Committee (IC) formally approved the fee waiver arrangement.',
    `ic_approval_flag` BOOLEAN COMMENT 'Indicates whether the fee waiver required formal Investment Committee (IC) approval.',
    `last_applied_date` DATE COMMENT 'Most recent date when the fee waiver was applied to a management fee calculation.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this fee waiver record was last updated or modified.',
    `legal_counsel_review_flag` BOOLEAN COMMENT 'Indicates whether the fee waiver arrangement was reviewed and approved by legal counsel.',
    `lpa_reference_section` STRING COMMENT 'Specific section or clause in the Limited Partnership Agreement (LPA) or side letter that governs this fee waiver.',
    `lpac_participation_flag` BOOLEAN COMMENT 'Indicates whether the fee waiver is granted in exchange for active Limited Partner Advisory Committee (LPAC) participation.',
    `most_favored_nation_clause_flag` BOOLEAN COMMENT 'Indicates whether this waiver is subject to Most Favored Nation (MFN) provisions ensuring equal treatment with other Limited Partners (LPs).',
    `net_fee_rate_percent` DECIMAL(5,4) COMMENT 'Effective management fee rate after application of the waiver.',
    `notes` STRING COMMENT 'Additional free-text notes or comments regarding the fee waiver arrangement, negotiation context, or special conditions.',
    `number` STRING COMMENT 'Externally-known business identifier for the fee waiver, typically referenced in Limited Partnership Agreement (LPA) or side letters.',
    `rate_percent` DECIMAL(5,4) COMMENT 'Percentage reduction applied to the standard management fee rate under this waiver arrangement.',
    `regulatory_reporting_category` STRING COMMENT 'Classification code for regulatory reporting purposes under the national pension regulator, Securities and Exchange Commission (SEC), or other jurisdictional requirements.',
    `revocation_date` DATE COMMENT 'Date when the fee waiver was revoked or cancelled by the General Partner (GP), if applicable.',
    `revocation_reason` STRING COMMENT 'Business justification for revoking or cancelling the fee waiver arrangement.',
    `side_letter_reference` STRING COMMENT 'Reference identifier for the side letter document that formalizes the fee waiver arrangement.',
    `trigger_condition` STRING COMMENT 'Business condition that qualifies the Limited Partner (LP) for the fee waiver, such as co-investment participation, Large Portfolio Advisory Committee (LPAC) membership, or commitment size threshold.',
    `waiver_status` STRING COMMENT 'Current lifecycle status of the fee waiver arrangement.. Valid values are `proposed|approved|active|expired|revoked|cancelled`',
    `waiver_type` STRING COMMENT 'Classification of the fee type being waived by the General Partner (GP).. Valid values are `management_fee|monitoring_fee|transaction_fee|advisory_fee|other`',
    CONSTRAINT pk_waiver PRIMARY KEY(`waiver_id`)
) COMMENT 'Transactional record of management fee waivers or reductions granted by a GP to the fund, typically in connection with co-investment rights, LPAC participation, or large commitment size.';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`monitoring_fee` (
    `monitoring_fee_id` BIGINT COMMENT 'Unique identifier for the portfolio company monitoring fee record. Primary key for the monitoring fee entity.',
    `fund_id` BIGINT COMMENT 'Reference to the private equity fund through which the investment was made and monitoring fee arrangement established.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the General Partner entity charging the monitoring fee to the portfolio company.',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Monitoring fees paid to GPs require attribution for management fee offset calculations and ILPA fee transparency disclosure requirements.',
    `investment_id` BIGINT COMMENT 'Reference to the private equity or co-investment that this monitoring fee is associated with.',
    `portfolio_company_id` BIGINT COMMENT 'Reference to the portfolio company being charged the monitoring fee by the General Partner (GP).',
    `annual_flat_fee_amount` DECIMAL(18,2) COMMENT 'Fixed annual monitoring fee amount charged to the portfolio company when fee structure is flat fee based.',
    `benchmark_fee_rate_percent` DECIMAL(8,4) COMMENT 'Industry benchmark or peer comparison rate for similar monitoring fee arrangements, used for fairness assessment and transparency.',
    `billing_frequency` STRING COMMENT 'Frequency at which monitoring fee invoices are issued to the portfolio company by the General Partner (GP).. Valid values are `annual|semi_annual|quarterly|monthly|one_time`',
    `calculation_base` STRING COMMENT 'The financial metric used as the basis for percentage-based monitoring fee calculations, such as Earnings Before Interest Taxes Depreciation and Amortization (EBITDA).. Valid values are `ebitda|revenue|enterprise_value|nav|none`',
    `capitalized_flag` BOOLEAN COMMENT 'Indicates whether monitoring fees are capitalized as part of the investment cost basis rather than expensed by the portfolio company.',
    `cost_center_code` STRING COMMENT 'Internal cost center or business unit code for allocation and tracking of monitoring fee revenue or expense.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp indicating when this monitoring fee record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this monitoring fee arrangement.. Valid values are `^[A-Z]{3}$`',
    `dispute_description` STRING COMMENT 'Detailed description of the nature and basis of any dispute related to the monitoring fee arrangement or payments.',
    `dispute_flag` BOOLEAN COMMENT 'Indicates whether there is an active dispute regarding the monitoring fee arrangement, calculation, or payment between parties.',
    `dispute_resolution_date` DATE COMMENT 'Date when any dispute regarding the monitoring fee arrangement was formally resolved between the parties.',
    `effective_end_date` DATE COMMENT 'Date when the monitoring fee arrangement terminates, typically upon exit or sale of the portfolio company investment.',
    `effective_start_date` DATE COMMENT 'Date when the monitoring fee arrangement becomes effective and fees begin accruing, typically aligned with investment closing date.',
    `escalation_clause_flag` BOOLEAN COMMENT 'Indicates whether the monitoring fee includes an automatic escalation provision tied to inflation or other indices.',
    `escalation_index` STRING COMMENT 'Reference index used for automatic fee escalation, such as Consumer Price Index (CPI) or other inflation measure.',
    `escalation_rate_percent` DECIMAL(5,2) COMMENT 'Annual percentage rate by which the monitoring fee automatically increases, if escalation clause is in effect.',
    `fee_arrangement_status` STRING COMMENT 'Current lifecycle status of the monitoring fee arrangement indicating whether fees are actively being charged.. Valid values are `active|suspended|terminated|pending|draft`',
    `fee_reference_number` STRING COMMENT 'External business identifier for the monitoring fee arrangement, typically referenced in investment agreements and invoices.',
    `fee_structure_type` STRING COMMENT 'Classification of the monitoring fee calculation methodology, such as flat annual fee or percentage of portfolio company EBITDA.. Valid values are `annual_flat_fee|percentage_of_ebitda|percentage_of_revenue|tiered|hybrid`',
    `gl_account_code` STRING COMMENT 'General Ledger account code to which monitoring fee revenue or expense is posted for financial accounting purposes.',
    `ic_approval_date` DATE COMMENT 'Date when the Investment Committee formally approved the monitoring fee arrangement as part of the investment approval.',
    `ic_approval_flag` BOOLEAN COMMENT 'Indicates whether the monitoring fee arrangement received formal Investment Committee approval as part of the investment decision process.',
    `investment_agreement_reference` STRING COMMENT 'Reference to the specific investment agreement, Share Purchase Agreement (SPA), or transaction document that establishes the monitoring fee terms.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'System timestamp indicating when this monitoring fee record was last updated or modified.',
    `lpa_offset_percentage` DECIMAL(5,2) COMMENT 'Percentage of monitoring fees that must be credited back to Limited Partners (LPs) as an offset against management fees, per LPA terms.',
    `lpa_offset_provision_flag` BOOLEAN COMMENT 'Indicates whether the Limited Partnership Agreement requires monitoring fees to be offset against management fees paid by Limited Partners (LPs).',
    `lpa_reference_section` STRING COMMENT 'Specific section, article, or clause reference in the Limited Partnership Agreement that governs this monitoring fee arrangement.',
    `maximum_fee_amount` DECIMAL(18,2) COMMENT 'Ceiling amount for the monitoring fee regardless of calculation base, capping GP compensation to protect portfolio company.',
    `minimum_fee_amount` DECIMAL(18,2) COMMENT 'Floor amount for the monitoring fee regardless of calculation base, ensuring GP receives minimum compensation for services.',
    `notes` STRING COMMENT 'Free-form text field for additional comments, special terms, or contextual information regarding the monitoring fee arrangement.',
    `payment_timing` STRING COMMENT 'Timing of monitoring fee payment relative to the service period, indicating whether fees are paid in advance or arrears.. Valid values are `advance|arrears|upon_invoice`',
    `percentage_rate` DECIMAL(8,4) COMMENT 'Percentage rate applied to the calculation base (EBITDA or revenue) when fee structure is percentage-based, expressed as decimal.',
    `regulatory_reporting_category` STRING COMMENT 'Classification code for regulatory reporting purposes, indicating how this monitoring fee should be categorized in regulatory filings.',
    `service_description` STRING COMMENT 'Detailed description of the monitoring, advisory, and value-creation services provided by the GP to justify the monitoring fee.',
    `tax_treatment_code` STRING COMMENT 'Classification code indicating the tax treatment of monitoring fees for both GP and portfolio company tax reporting purposes.',
    `termination_trigger` STRING COMMENT 'Event or condition that triggered or will trigger the termination of the monitoring fee arrangement.. Valid values are `exit|sale|ipo|maturity|breach|mutual_agreement`',
    `transparency_disclosure_flag` BOOLEAN COMMENT 'Indicates whether this monitoring fee arrangement is subject to transparency disclosure requirements to Limited Partners (LPs) or regulators.',
    `variance_to_benchmark_bps` DECIMAL(8,2) COMMENT 'Difference between the actual monitoring fee rate and the benchmark rate, expressed in basis points for variance analysis.',
    `waiver_approval_date` DATE COMMENT 'Date when the monitoring fee waiver or reduction was formally approved by authorized parties.',
    `waiver_flag` BOOLEAN COMMENT 'Indicates whether the General Partner (GP) has waived or reduced the monitoring fee for a specific period or permanently.',
    `waiver_reason` STRING COMMENT 'Business justification and rationale for any waiver or reduction of the monitoring fee by the General Partner (GP).',
    `withholding_tax_applicable_flag` BOOLEAN COMMENT 'Indicates whether withholding tax must be applied to monitoring fee payments based on jurisdiction and tax treaty provisions.',
    `withholding_tax_rate_percent` DECIMAL(5,2) COMMENT 'Percentage rate of withholding tax to be applied to monitoring fee payments when applicable.',
    CONSTRAINT pk_monitoring_fee PRIMARY KEY(`monitoring_fee_id`)
) COMMENT 'Master record for portfolio company monitoring fees charged by GPs to investee companies post-acquisition. Captures monitoring fee structure (annual flat fee vs percentage of EBITDA), fee amount, billing frequency, LPA offset provision (percentage';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`organizational_expense` (
    `organizational_expense_id` BIGINT COMMENT 'Unique identifier for the organizational expense record.',
    `approved_by_user_employee_id` BIGINT COMMENT 'Reference to the user or approver who authorized the organizational expense for payment.',
    `cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: Fund organizational expenses (legal, accounting setup costs) are paid from treasury cash accounts.',
    `counterparty_id` BIGINT COMMENT 'Reference to the external service provider or advisor entity that rendered the service and charged the expense.',
    `employee_id` BIGINT COMMENT 'Reference to the user or approver who authorized the organizational expense for payment.',
    `fund_id` BIGINT COMMENT 'Reference to the fund that incurred this organizational expense.',
    `allocation_method` STRING COMMENT 'Method used to allocate the organizational expense across Limited Partners (LPs) or fund entities per the Limited Partnership Agreement (LPA).. Valid values are `pro_rata|equal|custom|lpa_defined`',
    `amortization_period_months` BIGINT COMMENT 'Number of months over which the capitalized organizational expense will be amortized if applicable.',
    `approval_date` DATE COMMENT 'Date on which the organizational expense was approved for payment by the authorized approver or Investment Committee (IC).',
    `base_currency_code` STRING COMMENT 'Three-letter International Organization for Standardization (ISO) 4217 currency code representing the funds base reporting currency.. Valid values are `^[A-Z]{3}$`',
    `base_currency_net_amount` DECIMAL(18,2) COMMENT 'Net expense amount converted to the funds base reporting currency using the applicable Foreign Exchange (FX) rate.',
    `capitalized_flag` BOOLEAN COMMENT 'Indicates whether the organizational expense is capitalized as part of the fund formation costs or expensed immediately.',
    `cost_center_code` STRING COMMENT 'Cost center or business unit code to which this organizational expense is allocated for internal management reporting.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this organizational expense record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter International Organization for Standardization (ISO) 4217 currency code in which the organizational expense is denominated.. Valid values are `^[A-Z]{3}$`',
    `dispute_flag` BOOLEAN COMMENT 'Indicates whether the organizational expense is under dispute or has been contested by the fund or General Partner (GP).',
    `dispute_reason` STRING COMMENT 'Explanation or reason for disputing the organizational expense if the dispute flag is set to true.',
    `dispute_resolution_date` DATE COMMENT 'Date on which the dispute regarding the organizational expense was resolved or settled.',
    `due_date` DATE COMMENT 'Date by which the organizational expense payment is due to the service provider per contractual terms.',
    `expense_category` STRING COMMENT 'High-level categorization of the expense for financial reporting and cost allocation purposes.. Valid values are `formation|launch|ongoing_operational|regulatory|advisory`',
    `expense_number` STRING COMMENT 'Business reference number assigned to this organizational expense for tracking and reporting purposes.',
    `expense_status` STRING COMMENT 'Current lifecycle status of the organizational expense in the payment and approval workflow.. Valid values are `accrued|invoiced|approved|paid|disputed|waived`',
    `expense_type` STRING COMMENT 'Classification of the organizational expense by nature of cost incurred during fund formation or launch. [ENUM-REF-CANDIDATE',
    `fx_rate` DECIMAL(18,6) COMMENT 'Foreign exchange rate used to convert the expense amount from transaction currency to base currency.',
    `gl_account_code` STRING COMMENT 'General Ledger account code to which this organizational expense is posted for financial reporting and accounting purposes.',
    `gross_expense_amount` DECIMAL(18,2) COMMENT 'Total gross amount of the organizational expense before any adjustments, rebates, or allocations.',
    `incurred_date` DATE COMMENT 'Date on which the organizational expense was incurred or the service was rendered.',
    `invoice_date` DATE COMMENT 'Date on which the service provider issued the invoice for this organizational expense.',
    `invoice_number` STRING COMMENT 'Unique invoice reference number provided by the service provider for this expense.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this organizational expense record was last updated or modified in the system.',
    `lpa_reference_clause` STRING COMMENT 'Specific section or clause in the Limited Partnership Agreement (LPA) that governs the treatment and allocation of this organizational expense.',
    `net_expense_amount` DECIMAL(18,2) COMMENT 'Net amount of the organizational expense after all adjustments, taxes, and allocations have been applied.',
    `non_reimbursable_amount` DECIMAL(18,2) COMMENT 'Portion of the organizational expense that is not reimbursable and must be borne by the General Partner (GP) or other party.',
    `notes` STRING COMMENT 'Additional free-form notes or comments regarding the organizational expense for audit trail and internal reference purposes.',
    `payment_date` DATE COMMENT 'Actual date on which the organizational expense was paid to the service provider.',
    `payment_method` STRING COMMENT 'Method used to remit payment for the organizational expense to the service provider.. Valid values are `wire_transfer|ach|check|electronic_funds_transfer`',
    `payment_reference_number` STRING COMMENT 'Unique reference number or transaction identifier associated with the payment of this organizational expense.',
    `reimbursable_amount` DECIMAL(18,2) COMMENT 'Portion of the organizational expense that is reimbursable by the fund or Limited Partners (LPs) per the Limited Partnership Agreement (LPA).',
    `service_description` STRING COMMENT 'Detailed description of the service or work performed by the service provider that resulted in this organizational expense.',
    `service_provider_name` STRING COMMENT 'Name of the service provider or advisor firm that provided the service associated with this expense.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Total tax amount included in or applied to the organizational expense, including Value Added Tax (VAT) or Goods and Services Tax (GST).',
    `vintage_year` BIGINT COMMENT 'Year in which the fund was established or had its first capital commitment, used for cohort analysis and benchmarking of organizational expenses.',
    `waiver_flag` BOOLEAN COMMENT 'Indicates whether the organizational expense has been waived by the service provider or General Partner (GP) and will not be charged to the fund.',
    `waiver_reason` STRING COMMENT 'Explanation or justification for waiving the organizational expense if the waiver flag is set to true.',
    CONSTRAINT pk_organizational_expense PRIMARY KEY(`organizational_expense_id`)
) COMMENT 'Transactional record of fund organizational and formation expenses charged to the fund or LP during fund launch, including legal fees, placement agent fees, regulatory filing costs, and fund formation costs.';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`placement_fee` (
    `placement_fee_id` BIGINT COMMENT 'Unique identifier for the placement fee record.',
    `cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: Placement agent fee payments at fund closing require treasury cash account routing. Treasury operations track these one-time significant outflows for fundraising cost reporting and cash',
    `counterparty_id` BIGINT COMMENT 'Reference to the investor entity that committed capital through the placement agent.',
    `fund_id` BIGINT COMMENT 'Reference to the fund for which capital was raised through the placement agent.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the placement agent entity that facilitated the capital raising activity.',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Placement fees relate to GP fundraising activities; GP profile linkage required for fee transparency reporting and total cost of ownership analysis.',
    `allocation_method` STRING COMMENT 'Method used to allocate placement fee costs across investors or fund classes.. Valid values are `pro_rata|investor_specific|fund_level|class_level`',
    `capital_commitment_amount` DECIMAL(20,2) COMMENT 'Total capital commitment amount secured by the placement agent from the investor.',
    `capitalized_flag` BOOLEAN COMMENT 'Indicates whether the placement fee is capitalized as part of fund organizational costs or expensed immediately.',
    `commitment_date` DATE COMMENT 'Date on which the investor committed capital to the fund through the placement agent.',
    `cost_center_code` STRING COMMENT 'Cost center code for internal allocation and reporting of the placement fee expense.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this placement fee record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the placement fee transaction.. Valid values are `^[A-Z]{3}$`',
    `dispute_flag` BOOLEAN COMMENT 'Indicates whether the placement fee is under dispute between the fund and placement agent.',
    `dispute_reason` STRING COMMENT 'Description of the reason for disputing the placement fee amount or terms.',
    `dispute_resolution_date` DATE COMMENT 'Date on which the placement fee dispute was resolved.',
    `due_date` DATE COMMENT 'Date by which the placement fee payment is contractually due.',
    `fee_accrual_date` DATE COMMENT 'Date on which the placement fee was accrued in the accounting system.',
    `fee_basis_percentage` DECIMAL(8,4) COMMENT 'Percentage of committed capital that determines the placement fee amount.',
    `fee_reference_number` STRING COMMENT 'Externally-known unique reference number for this placement fee transaction.',
    `fee_status` STRING COMMENT 'Current lifecycle status of the placement fee.. Valid values are `pending|approved|paid|disputed|waived|cancelled`',
    `fee_transparency_disclosure_flag` BOOLEAN COMMENT 'Indicates whether this placement fee is subject to fee transparency disclosure requirements for investors.',
    `fee_type` STRING COMMENT 'Classification of the placement fee structure.. Valid values are `upfront|trailing|success|retainer|hybrid`',
    `gl_account_code` STRING COMMENT 'General ledger account code to which the placement fee is posted.',
    `gross_fee_amount` DECIMAL(18,2) COMMENT 'Total placement fee amount before any deductions or adjustments.',
    `ic_approval_date` DATE COMMENT 'Date on which the Investment Committee approved the placement fee arrangement.',
    `ic_approval_flag` BOOLEAN COMMENT 'Indicates whether the placement fee arrangement received Investment Committee approval.',
    `invoice_date` DATE COMMENT 'Date on which the placement agent issued the fee invoice.',
    `invoice_number` STRING COMMENT 'Unique invoice number issued by the placement agent for this fee.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this placement fee record was last updated in the system.',
    `lpa_reference_clause` STRING COMMENT 'Specific clause or section in the LPA that governs placement fee terms and conditions.',
    `net_fee_amount` DECIMAL(18,2) COMMENT 'Net placement fee amount payable after withholding tax and other deductions.',
    `notes` STRING COMMENT 'Additional free-text notes or comments regarding the placement fee transaction.',
    `payment_date` DATE COMMENT 'Actual date on which the placement fee was paid to the placement agent.',
    `payment_method` STRING COMMENT 'Method used to remit the placement fee payment to the placement agent.. Valid values are `wire_transfer|ach|check|offset`',
    `payment_reference_number` STRING COMMENT 'Unique reference number for the payment transaction from treasury system.',
    `placement_agreement_reference` STRING COMMENT 'Reference to the placement agent agreement document that governs this fee arrangement.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this placement fee must be disclosed in regulatory filings or investor reports.',
    `retrocession_amount` DECIMAL(18,2) COMMENT 'Amount of placement fee rebated to the fund or investors under retrocession arrangement.',
    `retrocession_arrangement_flag` BOOLEAN COMMENT 'Indicates whether the placement fee involves a retrocession arrangement where a portion is rebated to the fund or investors.',
    `retrocession_percentage` DECIMAL(6,4) COMMENT 'Percentage of gross placement fee that is rebated under retrocession arrangement.',
    `vintage_year` BIGINT COMMENT 'Year in which the fund held its initial capital closing, used for performance benchmarking.',
    `waiver_approval_date` DATE COMMENT 'Date on which the placement fee waiver was approved by authorized personnel.',
    `waiver_flag` BOOLEAN COMMENT 'Indicates whether the placement fee was waived in full or in part by the placement agent.',
    `waiver_reason` STRING COMMENT 'Business justification for waiving the placement fee.',
    `withholding_tax_amount` DECIMAL(18,2) COMMENT 'Tax amount withheld from the placement fee per applicable tax regulations.',
    `withholding_tax_rate_percent` DECIMAL(6,4) COMMENT 'Tax rate applied to calculate withholding tax on the placement fee.',
    CONSTRAINT pk_placement_fee PRIMARY KEY(`placement_fee_id`)
) COMMENT 'Transactional record of placement agent fees paid in connection with fund capital raising activities. Captures placement agent identity, fee basis (percentage of committed capital), fee amount, payment date, retrocession arrangement (whether placement fee';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`transparency_report` (
    `transparency_report_id` BIGINT COMMENT 'Unique identifier for the fee transparency report disclosure record.',
    `employee_id` BIGINT COMMENT 'Reference to the user or Investment Committee (IC) member who approved the transparency report for publication.',
    `fund_id` BIGINT COMMENT 'Reference to the pension fund or investment pool for which this transparency report is prepared.',
    `gp_profile_id` BIGINT COMMENT 'Foreign key linking to manager.gp_profile. Business justification: Transparency reports aggregate fees by manager for pension beneficiary disclosure; GP linkage enables manager-level fee analysis and benchmarking.',
    `prepared_by_user_employee_id` BIGINT COMMENT 'Reference to the user or team member who prepared the transparency report.',
    `regulatory_filing_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_filing. Business justification: Pension funds must file fee transparency reports with regulators (e.g., ILPA fee disclosure standards, fiduciary reporting).',
    `transparency_employee_id` BIGINT COMMENT 'Reference to the user or Investment Committee (IC) member who approved the transparency report for publication.',
    `transparency_prepared_by_user_employee_id` BIGINT COMMENT 'Reference to the user or team member who prepared the transparency report.',
    `valuation_cycle_id` BIGINT COMMENT 'Foreign key linking to valuation.cycle. Business justification: Fee transparency reports must reconcile fees to underlying valuations. Pension fund beneficiary reporting and regulatory filings require tracing total fees paid to specific valuation cycles',
    `approval_date` DATE COMMENT 'Date on which the transparency report was formally approved by the Investment Committee (IC) or designated authority.',
    `auditor_verification_date` DATE COMMENT 'Date on which external auditors completed their verification of the fee transparency report data.',
    `auditor_verified_flag` BOOLEAN COMMENT 'Indicates whether the fee amounts and calculations in this transparency report have been independently verified by external auditors.',
    `average_aum_amount` DECIMAL(20,2) COMMENT 'Average Assets Under Management (AUM) during the reporting period, used as the basis for fee rate calculations.',
    `benchmark_comparison_flag` BOOLEAN COMMENT 'Indicates whether this transparency report includes comparative benchmarking of fees against industry peers or standards.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this transparency report record was first created in the data platform.',
    `credit_fees_amount` DECIMAL(20,2) COMMENT 'Total fees paid for credit and fixed income investment management during the reporting period.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which all fee amounts in this report are denominated.. Valid values are `^[A-Z]{3}$`',
    `distribution_channel` STRING COMMENT 'Primary channel through which the transparency report was distributed to stakeholders.. Valid values are `beneficiary_portal|regulatory_filing|board_package|public_website|investor_letter`',
    `executive_summary` STRING COMMENT 'High-level narrative summary of the fee transparency report, highlighting key findings and trends for stakeholder communication.',
    `gips_compliant_flag` BOOLEAN COMMENT 'Indicates whether this transparency report was prepared in compliance with Global Investment Performance Standards (GIPS) for fee disclosure.',
    `infrastructure_fees_amount` DECIMAL(20,2) COMMENT 'Total fees paid for infrastructure investment management during the reporting period.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'System timestamp when this transparency report record was last updated or modified.',
    `natural_resources_fees_amount` DECIMAL(20,2) COMMENT 'Total fees paid for natural resources investment management during the reporting period.',
    `notes` STRING COMMENT 'Additional notes, explanations, or contextual information regarding the transparency report data, methodology, or special circumstances.',
    `peer_median_fee_rate_bps` DECIMAL(8,2) COMMENT 'Median fee rate in basis points (bps) for comparable institutional asset managers, used for benchmarking transparency.',
    `preparation_date` DATE COMMENT 'Date on which the transparency report was prepared and finalized by the investment accounting team.',
    `private_equity_fees_amount` DECIMAL(20,2) COMMENT 'Total fees paid for private equity and co-investment management during the reporting period.',
    `public_equities_fees_amount` DECIMAL(20,2) COMMENT 'Total fees paid for public equities asset class management during the reporting period.',
    `publication_date` DATE COMMENT 'Date on which the transparency report was published and made available to beneficiaries, regulators, and governance bodies.',
    `real_estate_fees_amount` DECIMAL(20,2) COMMENT 'Total fees paid for real estate investment management during the reporting period.',
    `recipient_category` STRING COMMENT 'Primary audience category for whom this transparency report was prepared and disclosed.. Valid values are `beneficiaries|regulators|board|investment_committee|public`',
    `regulatory_filing_flag` BOOLEAN COMMENT 'Indicates whether this transparency report was submitted as part of a mandatory regulatory filing requirement.',
    `report_reference_number` STRING COMMENT 'Externally-known unique reference number assigned to this transparency report for tracking and audit purposes.',
    `report_status` STRING COMMENT 'Current lifecycle status of the transparency report in the approval and publication workflow.. Valid values are `draft|under_review|approved|published|archived`',
    `report_type` STRING COMMENT 'Classification of the transparency report based on reporting frequency and purpose.. Valid values are `annual|quarterly|semi_annual|ad_hoc`',
    `reporting_period_end_date` DATE COMMENT 'End date of the period covered by this fee transparency disclosure.',
    `reporting_period_start_date` DATE COMMENT 'Start date of the period covered by this fee transparency disclosure.',
    `total_carried_interest_paid_amount` DECIMAL(20,2) COMMENT 'Aggregate carried interest (carry) paid to General Partners (GPs) during the reporting period across all private market investments.',
    `total_custody_fees_paid_amount` DECIMAL(20,2) COMMENT 'Aggregate custody and safekeeping fees paid to custodian banks during the reporting period.',
    `total_fee_rate_bps` DECIMAL(8,2) COMMENT 'Total fee rate expressed in basis points (bps) calculated as total fees paid divided by average AUM, multiplied by 10,000.',
    `total_fees_paid_amount` DECIMAL(20,2) COMMENT 'Grand total of all fees paid across all categories during the reporting period.',
    `total_management_fees_paid_amount` DECIMAL(20,2) COMMENT 'Aggregate management fees paid to all external managers and General Partners (GPs) during the reporting period.',
    `total_other_fees_paid_amount` DECIMAL(20,2) COMMENT 'Aggregate of all other investment-related fees not classified in primary categories, including legal, audit, and administrative fees.',
    `total_performance_fees_paid_amount` DECIMAL(20,2) COMMENT 'Aggregate performance-based fees paid to external managers who exceeded hurdle rates or benchmarks during the reporting period.',
    `total_placement_fees_paid_amount` DECIMAL(20,2) COMMENT 'Aggregate placement agent fees paid for capital raising and investor relations services during the reporting period.',
    `total_transaction_fees_paid_amount` DECIMAL(20,2) COMMENT 'Aggregate transaction fees paid for deal execution, advisory services, and other transaction-related costs during the reporting period.',
    `variance_to_peer_median_bps` DECIMAL(8,2) COMMENT 'Difference between the funds total fee rate and the peer median fee rate, expressed in basis points (bps).',
    CONSTRAINT pk_transparency_report PRIMARY KEY(`transparency_report_id`)
) COMMENT 'Transactional record of periodic fee transparency disclosures prepared for beneficiaries, regulators, and governance bodies. Captures reporting period, total management fees paid (by asset class and manager), total carried interest paid, total transaction';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`incentive_fee` (
    `incentive_fee_id` BIGINT COMMENT 'Unique identifier for the incentive fee arrangement. Primary key.',
    `approved_by_user_employee_id` BIGINT COMMENT 'Reference to the user or Investment Committee (IC) member who approved this incentive fee arrangement.',
    `employee_id` BIGINT COMMENT 'Reference to the user or Investment Committee (IC) member who approved this incentive fee arrangement.',
    `external_manager_gp_profile_id` BIGINT COMMENT 'Reference to the external manager subject to this incentive fee arrangement.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external manager subject to this incentive fee arrangement.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the Separately Managed Account (SMA) or liquid alternatives mandate under which this incentive fee applies.',
    `payment_cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: External manager incentive fee payments require treasury cash account for settlement.',
    `performance_benchmark_id` BIGINT COMMENT 'Foreign key linking to performance.performance_benchmark. Business justification: Incentive fee arrangements specify benchmark hurdles (e.g., beat MSCI World by 100bps).',
    `approval_date` DATE COMMENT 'Date on which the incentive fee arrangement was approved by the Investment Committee (IC) or authorized governance body.',
    `arrangement_name` STRING COMMENT 'Descriptive name of the incentive fee arrangement for business reference and reporting.',
    `arrangement_reference_number` STRING COMMENT 'Business identifier for the incentive fee arrangement, typically referenced in Investment Management Agreements (IMA).',
    `arrangement_status` STRING COMMENT 'Current lifecycle status of the incentive fee arrangement.. Valid values are `active|suspended|terminated|pending|draft`',
    `asset_class` STRING COMMENT 'Primary asset class to which this incentive fee arrangement applies, such as public equities, credit, or liquid alternatives.',
    `benchmark_reference` STRING COMMENT 'Identifier or name of the benchmark index or hurdle rate against which performance is measured for incentive fee calculation.',
    `calculation_frequency` STRING COMMENT 'Frequency at which incentive fee calculations are performed.. Valid values are `daily|monthly|quarterly|semi_annually|annually`',
    `clawback_provision_flag` BOOLEAN COMMENT 'Indicates whether a clawback provision exists requiring return of previously paid incentive fees if subsequent underperformance occurs.',
    `cost_center_code` STRING COMMENT 'Internal cost center code for allocation and tracking of incentive fee expenses.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this incentive fee arrangement record was first created in the system.',
    `crystallization_frequency` STRING COMMENT 'Frequency at which calculated incentive fees are crystallized and become payable.. Valid values are `monthly|quarterly|semi_annually|annually|at_redemption`',
    `cumulative_incentive_fee_paid_amount` DECIMAL(18,2) COMMENT 'Total cumulative incentive fees paid to the external manager under this arrangement since inception, in fee currency.',
    `effective_end_date` DATE COMMENT 'Date on which the incentive fee arrangement terminates or expires, if applicable.',
    `effective_start_date` DATE COMMENT 'Date from which the incentive fee arrangement becomes effective and performance measurement begins.',
    `equalization_method` STRING COMMENT 'Method used to ensure fair treatment of investors entering at different times relative to high water marks and performance periods.. Valid values are `series_accounting|full_equalization|no_equalization`',
    `fee_cap_percent` DECIMAL(8,5) COMMENT 'Maximum incentive fee as a percentage of Assets Under Management (AUM), providing an alternative cap mechanism.',
    `fee_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which incentive fees are denominated and paid.. Valid values are `^[A-Z]{3}$`',
    `fee_transparency_disclosure_flag` BOOLEAN COMMENT 'Indicates whether this incentive fee arrangement is subject to enhanced fee transparency disclosure requirements under regulatory frameworks.',
    `fee_type` STRING COMMENT 'Classification of the incentive fee structure type.. Valid values are `performance_fee|incentive_fee|fulcrum_fee|asymmetric_fee`',
    `fulcrum_fee_adjustment_flag` BOOLEAN COMMENT 'Indicates whether the arrangement includes symmetric fulcrum fee adjustments where fees increase for outperformance and decrease for underperformance.',
    `gl_account_code` STRING COMMENT 'General Ledger (GL) account code to which incentive fee expenses are posted for financial accounting.',
    `high_water_mark_amount` DECIMAL(18,2) COMMENT 'Current high water mark value in base currency, representing the highest Net Asset Value (NAV) level at which incentive fees were previously charged.',
    `high_water_mark_flag` BOOLEAN COMMENT 'Indicates whether a high water mark provision applies, ensuring incentive fees are only charged on net new performance above previous peaks.',
    `hurdle_rate_percent` DECIMAL(8,5) COMMENT 'Minimum return threshold that must be achieved before incentive fees are charged, expressed as annualized percentage.',
    `hurdle_type` STRING COMMENT 'Classification of hurdle rate structure: hard hurdle applies fee only to excess returns, soft hurdle applies to all returns once threshold is met.. Valid values are `hard|soft|blended`',
    `ima_reference_section` STRING COMMENT 'Specific section or clause reference in the Investment Management Agreement (IMA) governing this incentive fee arrangement.',
    `investment_strategy` STRING COMMENT 'Investment strategy classification for the mandate subject to this incentive fee, such as long-only equity, market neutral, or absolute return.',
    `last_calculation_date` DATE COMMENT 'Most recent date on which incentive fee calculation was performed for this arrangement.',
    `last_crystallization_date` DATE COMMENT 'Most recent date on which calculated incentive fees were crystallized and became payable.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this incentive fee arrangement record was most recently updated.',
    `loss_carryforward_flag` BOOLEAN COMMENT 'Indicates whether losses from prior periods must be recovered before new incentive fees can be charged.',
    `maximum_fee_amount` DECIMAL(18,2) COMMENT 'Maximum incentive fee amount per calculation period, if applicable, capping performance-based compensation.',
    `minimum_fee_amount` DECIMAL(18,2) COMMENT 'Minimum incentive fee amount per calculation period, if applicable, ensuring a floor on performance-based compensation.',
    `most_favored_nation_clause_flag` BOOLEAN COMMENT 'Indicates whether a Most Favored Nation (MFN) clause applies, entitling the investor to the most favorable fee terms offered to any other investor.',
    `notes` STRING COMMENT 'Free-form text field for additional comments, special provisions, or operational notes regarding the incentive fee arrangement.',
    `payment_timing` STRING COMMENT 'Timing convention for when crystallized incentive fees are paid relative to the calculation period.. Valid values are `in_arrears|in_advance|at_crystallization`',
    `performance_measurement_basis` STRING COMMENT 'Methodology used to calculate performance for incentive fee determination: Time-Weighted Return (TWR), Money-Weighted Return (MWR), or other basis.. Valid values are `time_weighted_return|money_weighted_return|absolute_return|relative_return`',
    `rate_percent` DECIMAL(8,5) COMMENT 'Percentage of outperformance above benchmark or hurdle that is charged as incentive fee, expressed as decimal percentage.',
    `regulatory_reporting_category` STRING COMMENT 'Classification code for regulatory reporting purposes under applicable frameworks such as SEC, or MiFID II.',
    `side_letter_flag` BOOLEAN COMMENT 'Indicates whether this incentive fee arrangement is subject to side letter provisions with modified terms.',
    `termination_notice_period_days` BIGINT COMMENT 'Number of days advance notice required to terminate the incentive fee arrangement.',
    CONSTRAINT pk_incentive_fee PRIMARY KEY(`incentive_fee_id`)
) COMMENT 'Master record for performance-based incentive fee arrangements applicable to external managers operating under SMA or liquid alternatives mandates. Captures incentive fee rate (percentage of outperformance), high-water mark provision, benchmark reference';

CREATE OR REPLACE TABLE `asset_management`.`fee`.`high_water_mark` (
    `high_water_mark_id` BIGINT COMMENT 'Unique identifier for the high water mark record. Primary key for the high_water_mark product.',
    `external_manager_gp_profile_id` BIGINT COMMENT 'Reference to the external investment manager responsible for the liquid strategy subject to performance fee calculation.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external investment manager responsible for the liquid strategy subject to performance fee calculation.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the investment mandate or separately managed account (SMA) to which this high water mark applies.',
    `performance_benchmark_id` BIGINT COMMENT 'Foreign key linking to performance.performance_benchmark. Business justification: High water mark crystallization often requires benchmark-relative performance comparison.',
    `valuation_nav_record_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_nav_record. Business justification: High water marks are established/reset based on NAV records. Performance fee calculations require tracing HWM to the specific NAV record that set it.',
    `approval_date` DATE COMMENT 'The date on which the high water mark arrangement and its terms were formally approved by the Investment Committee or authorized signatory.',
    `approved_by` STRING COMMENT 'The name or identifier of the Investment Committee member or authorized individual who approved the high water mark arrangement.',
    `auditor_verified_flag` BOOLEAN COMMENT 'Indicates whether the high water mark calculation and current level have been independently verified by external auditors.',
    `calculation_methodology` STRING COMMENT 'Detailed description of the methodology used to calculate the high water mark, including NAV basis, timing conventions, and adjustment rules.',
    `clawback_provision_flag` BOOLEAN COMMENT 'Indicates whether a clawback provision exists requiring the manager to return performance fees if the high water mark is subsequently breached.',
    `clawback_reserve_percentage` DECIMAL(5,2) COMMENT 'The percentage of performance fees withheld in reserve to cover potential future clawback obligations if performance deteriorates.',
    `created_timestamp` TIMESTAMP COMMENT 'The system timestamp when this high water mark record was first created in the data platform.',
    `crystallization_frequency` STRING COMMENT 'The frequency at which performance fees are crystallized and the high water mark is evaluated for potential update.. Valid values are `monthly|quarterly|semi-annually|annually|at_redemption`',
    `cumulative_performance_fee_accrued_amount` DECIMAL(20,4) COMMENT 'The total performance fees accrued to date since the last reset, representing fees earned above the high water mark.',
    `cumulative_performance_fee_paid_amount` DECIMAL(20,4) COMMENT 'The total performance fees actually paid out to the manager since the last reset, used for reconciliation and clawback calculations.',
    `cumulative_underperformance_amount` DECIMAL(20,4) COMMENT 'The cumulative loss carryforward or deficit amount that must be recovered before new performance fees can be earned. Represents NAV below the high water mark.',
    `current_hwm_nav` DECIMAL(20,4) COMMENT 'The current high water mark net asset value level that must be exceeded before performance fees are earned. Represents the highest NAV achieved to date.',
    `equalization_method` STRING COMMENT 'The method used to equalize performance fees across investors with different entry dates: series accounting, full equalization, or none.. Valid values are `series|full|none`',
    `hurdle_rate_percent` DECIMAL(5,2) COMMENT 'The minimum return threshold that must be exceeded before performance fees are earned, applied in conjunction with the high water mark.',
    `hurdle_type` STRING COMMENT 'Classification of the hurdle rate mechanism: hard (fees only on excess above hurdle), soft (fees on all returns once hurdle is met), or none (no hurdle applies).. Valid values are `hard|soft|none`',
    `hwm_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the high water mark NAV is denominated.. Valid values are `^[A-Z]{3}$`',
    `hwm_establishment_date` DATE COMMENT 'The date on which the high water mark arrangement was first established for this mandate or fund.',
    `hwm_exceeded_flag` BOOLEAN COMMENT 'Indicates whether the current NAV has exceeded the high water mark, triggering performance fee accrual eligibility.',
    `hwm_reference_number` STRING COMMENT 'Business-facing reference number or code for this high water mark arrangement, used in reporting and fee reconciliation.',
    `hwm_reset_date` DATE COMMENT 'The most recent date on which the high water mark was reset to a new level, typically following a full recovery or contractual reset event.',
    `hwm_status` STRING COMMENT 'Current lifecycle status of the high water mark arrangement indicating whether it is actively tracked or has been reset or terminated.. Valid values are `active|suspended|reset|terminated|pending`',
    `hwm_type` STRING COMMENT 'Classification of the high water mark mechanism: hard (never resets), soft (resets under conditions), rolling (time-based reset), or crystallized (locked at fee payment).. Valid values are `hard|soft|rolling|crystallized`',
    `initial_hwm_nav` DECIMAL(20,4) COMMENT 'The starting high water mark NAV level established at mandate inception or at the last full reset event.',
    `last_audit_date` DATE COMMENT 'The date of the most recent external audit verification of the high water mark calculation and supporting documentation.',
    `last_calculation_date` DATE COMMENT 'The date on which the high water mark was most recently calculated and updated based on current NAV.',
    `last_crystallization_date` DATE COMMENT 'The date of the most recent performance fee crystallization event when the high water mark was locked and performance fees were calculated and accrued.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The system timestamp when this high water mark record was most recently updated or modified.',
    `lookback_period_months` BIGINT COMMENT 'The number of months over which performance is evaluated for rolling high water mark calculations or reset eligibility.',
    `loss_carryforward_flag` BOOLEAN COMMENT 'Indicates whether losses must be fully recovered before performance fees resume. True if loss carryforward provision is active.',
    `lpa_reference_clause` STRING COMMENT 'The specific section or clause reference in the Limited Partnership Agreement or Investment Management Agreement governing this high water mark arrangement.',
    `most_favored_nation_clause_flag` BOOLEAN COMMENT 'Indicates whether a most favored nation clause applies, requiring that any more favorable high water mark terms offered to other investors be extended to this investor.',
    `nav_basis` STRING COMMENT 'The basis on which NAV is calculated for high water mark purposes: gross of fees, net of fees, or adjusted for specific items.. Valid values are `gross|net|adjusted`',
    `next_crystallization_date` DATE COMMENT 'The scheduled date for the next performance fee crystallization event when the high water mark will be evaluated and performance fees calculated.',
    `notes` STRING COMMENT 'Free-form text field for additional context, special conditions, or operational notes related to this high water mark arrangement.',
    `performance_fee_rate_percent` DECIMAL(5,2) COMMENT 'The percentage rate applied to returns above the high water mark to calculate performance-based incentive fees.',
    `previous_hwm_nav` DECIMAL(20,4) COMMENT 'The prior high water mark NAV level before the most recent update, used for performance attribution and fee variance analysis.',
    `reset_frequency` STRING COMMENT 'The frequency or condition under which the high water mark may be reset to a new baseline level.. Valid values are `never|annually|on_recovery|on_event`',
    `reset_trigger_condition` STRING COMMENT 'The contractual condition or event that triggers a reset of the high water mark, such as full recovery, time period expiry, or manager change.',
    `side_letter_flag` BOOLEAN COMMENT 'Indicates whether this high water mark arrangement is subject to side letter provisions that modify standard terms.',
    CONSTRAINT pk_high_water_mark PRIMARY KEY(`high_water_mark_id`)
) COMMENT 'Master record tracking the high-water mark (HWM) level for each incentive fee arrangement on liquid strategy mandates. Captures current HWM NAV level, HWM reset date, cumulative underperformance deficit (loss carryforward), last crystallization date, last';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ADD CONSTRAINT `fk_fee_waterfall_tier_waterfall_id` FOREIGN KEY (`waterfall_id`) REFERENCES `asset_management`.`fee`.`waterfall`(`waterfall_id`);
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ADD CONSTRAINT `fk_fee_waterfall_tier_waterfall_structure_waterfall_id` FOREIGN KEY (`waterfall_structure_waterfall_id`) REFERENCES `asset_management`.`fee`.`waterfall`(`waterfall_id`);
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ADD CONSTRAINT `fk_fee_clawback_provision_carry_escrow_id` FOREIGN KEY (`carry_escrow_id`) REFERENCES `asset_management`.`fee`.`carry_escrow`(`carry_escrow_id`);
ALTER TABLE `asset_management`.`fee`.`clawback_event` ADD CONSTRAINT `fk_fee_clawback_event_carry_escrow_id` FOREIGN KEY (`carry_escrow_id`) REFERENCES `asset_management`.`fee`.`carry_escrow`(`carry_escrow_id`);
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ADD CONSTRAINT `fk_fee_gp_fee_rebate_transaction_fee_id` FOREIGN KEY (`transaction_fee_id`) REFERENCES `asset_management`.`fee`.`transaction_fee`(`transaction_fee_id`);
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ADD CONSTRAINT `fk_fee_gp_fee_rebate_transaction_transaction_fee_id` FOREIGN KEY (`transaction_transaction_fee_id`) REFERENCES `asset_management`.`fee`.`transaction_fee`(`transaction_fee_id`);
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ADD CONSTRAINT `fk_fee_carry_distribution_carry_escrow_id` FOREIGN KEY (`carry_escrow_id`) REFERENCES `asset_management`.`fee`.`carry_escrow`(`carry_escrow_id`);
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ADD CONSTRAINT `fk_fee_carry_distribution_escrow_account_carry_escrow_id` FOREIGN KEY (`escrow_account_carry_escrow_id`) REFERENCES `asset_management`.`fee`.`carry_escrow`(`carry_escrow_id`);
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ADD CONSTRAINT `fk_fee_rate_schedule_superseded_by_schedule_rate_schedule_id` FOREIGN KEY (`superseded_by_schedule_rate_schedule_id`) REFERENCES `asset_management`.`fee`.`rate_schedule`(`rate_schedule_id`);
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ADD CONSTRAINT `fk_fee_fee_calculation_run_fee_benchmark_id` FOREIGN KEY (`fee_benchmark_id`) REFERENCES `asset_management`.`fee`.`fee_benchmark`(`fee_benchmark_id`);
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ADD CONSTRAINT `fk_fee_fee_calculation_run_original_run_fee_calculation_run_id` FOREIGN KEY (`original_run_fee_calculation_run_id`) REFERENCES `asset_management`.`fee`.`fee_calculation_run`(`fee_calculation_run_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`fee`.`management_fee` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`fee`.`management_fee` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`management_fee` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`management_fee` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `management_fee_id` SET TAGS ('dbx_business_glossary_term' = 'Management Fee ID');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) ID');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `gp_gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) ID');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate ID');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `base_fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Base Fee Rate');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `benchmark_index_code` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index Code');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Calculation Frequency');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annually|annually|on_demand');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `catch_up_provision` SET TAGS ('dbx_business_glossary_term' = 'Catch-Up Provision');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `catch_up_provision` SET TAGS ('dbx_value_regex' = 'none|full_catch_up|partial_catch_up');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `clawback_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Flag');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `fee_arrangement_code` SET TAGS ('dbx_business_glossary_term' = 'Fee Arrangement Code');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `fee_arrangement_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{6,20}$');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `fee_arrangement_name` SET TAGS ('dbx_business_glossary_term' = 'Fee Arrangement Name');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `fee_arrangement_status` SET TAGS ('dbx_business_glossary_term' = 'Fee Arrangement Status');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `fee_arrangement_status` SET TAGS ('dbx_value_regex' = 'active|suspended|terminated|pending_approval|under_review|amended');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `fee_basis` SET TAGS ('dbx_business_glossary_term' = 'Fee Basis');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `fee_basis` SET TAGS ('dbx_value_regex' = 'aum_percentage|committed_capital_percentage|nav_percentage|flat_fee|tiered_schedule|hybrid');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `fee_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Fee Currency Code');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `fee_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `fee_offset_provision` SET TAGS ('dbx_business_glossary_term' = 'Fee Offset Provision');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `fee_offset_provision` SET TAGS ('dbx_value_regex' = 'none|full_offset|partial_offset|rebate_required');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `fee_rate_unit` SET TAGS ('dbx_business_glossary_term' = 'Fee Rate Unit');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `fee_rate_unit` SET TAGS ('dbx_value_regex' = 'percent_per_annum|percent_per_quarter|percent_per_month|basis_points_per_annum|flat_amount');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `fee_transparency_disclosure_flag` SET TAGS ('dbx_business_glossary_term' = 'Fee Transparency Disclosure Flag');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `fee_type` SET TAGS ('dbx_business_glossary_term' = 'Fee Type');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `fee_type` SET TAGS ('dbx_value_regex' = 'management_fee|advisory_fee|administration_fee|performance_fee|transaction_fee|monitoring_fee');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `fee_waiver_conditions` SET TAGS ('dbx_business_glossary_term' = 'Fee Waiver Conditions');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `hurdle_rate` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `internal_cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Internal Cost Center Code');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `internal_cost_center_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4,12}$');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `investment_period_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Period Flag');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `lpa_reference_section` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reference Section');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `maximum_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Fee Amount');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `minimum_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Fee Amount');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `modified_by_user` SET TAGS ('dbx_business_glossary_term' = 'Modified By User');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `most_favored_nation_clause` SET TAGS ('dbx_business_glossary_term' = 'Most Favored Nation (MFN) Clause');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `offset_percentage` SET TAGS ('dbx_business_glossary_term' = 'Offset Percentage');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annually|annually|on_demand');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `payment_timing` SET TAGS ('dbx_business_glossary_term' = 'Payment Timing');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `payment_timing` SET TAGS ('dbx_value_regex' = 'in_advance|in_arrears|on_capital_call|on_distribution');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `performance_fee_linkage_flag` SET TAGS ('dbx_business_glossary_term' = 'Performance Fee Linkage Flag');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `post_investment_period_basis` SET TAGS ('dbx_business_glossary_term' = 'Post-Investment Period Basis');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `post_investment_period_basis` SET TAGS ('dbx_value_regex' = 'invested_capital|nav|cost_basis|reduced_rate');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `post_investment_period_rate` SET TAGS ('dbx_business_glossary_term' = 'Post-Investment Period Rate');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `regulatory_reporting_category` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Category');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `regulatory_reporting_category` SET TAGS ('dbx_value_regex' = 'ongoing_charges|transaction_costs|performance_fees|ancillary_costs|not_applicable');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `termination_notice_period_days` SET TAGS ('dbx_business_glossary_term' = 'Termination Notice Period Days');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `tiered_schedule_flag` SET TAGS ('dbx_business_glossary_term' = 'Tiered Schedule Flag');
ALTER TABLE `asset_management`.`fee`.`management_fee` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`fee`.`carried_interest` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`fee`.`carried_interest` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`carried_interest` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`carried_interest` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `carried_interest_id` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest ID');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund ID');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Entity ID');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `accrued_carry_amount` SET TAGS ('dbx_business_glossary_term' = 'Accrued Carried Interest Amount');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `arrangement_name` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Arrangement Name');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `arrangement_type` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Arrangement Type');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `arrangement_type` SET TAGS ('dbx_value_regex' = 'whole_fund|deal_by_deal|hybrid|tiered|european|american');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'private_equity|infrastructure|real_estate|natural_resources|credit');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `benchmark_irr` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Internal Rate of Return (IRR)');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `calculation_basis` SET TAGS ('dbx_business_glossary_term' = 'Calculation Basis');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `calculation_basis` SET TAGS ('dbx_value_regex' = 'realized_gains|unrealized_gains|total_value|irr_based|moic_based');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Calculation Frequency');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_value_regex' = 'daily|monthly|quarterly|semi_annual|annual|on_event');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `carried_interest_status` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Arrangement Status');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `carried_interest_status` SET TAGS ('dbx_value_regex' = 'active|suspended|terminated|pending|under_review');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `carry_rate` SET TAGS ('dbx_business_glossary_term' = 'Carry Rate');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `catchup_cap` SET TAGS ('dbx_business_glossary_term' = 'Catch-Up Cap');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `catchup_rate` SET TAGS ('dbx_business_glossary_term' = 'Catch-Up Rate');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `clawback_cap_amount` SET TAGS ('dbx_business_glossary_term' = 'Clawback Cap Amount');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `clawback_provision` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Indicator');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `clawback_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Clawback Reserve Amount');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `clawback_type` SET TAGS ('dbx_business_glossary_term' = 'Clawback Type');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `clawback_type` SET TAGS ('dbx_value_regex' = 'full|partial|none');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `distributed_carry_amount` SET TAGS ('dbx_business_glossary_term' = 'Distributed Carried Interest Amount');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `distribution_timing` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Distribution Timing');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `distribution_timing` SET TAGS ('dbx_value_regex' = 'on_realization|on_distribution|at_fund_termination|quarterly|annual');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `fee_offset_percentage` SET TAGS ('dbx_business_glossary_term' = 'Fee Offset Percentage');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `fee_offset_provision` SET TAGS ('dbx_business_glossary_term' = 'Fee Offset Provision Indicator');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `gp_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Commitment Amount');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `gp_commitment_percentage` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Commitment Percentage');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `hurdle_rate` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `hurdle_type` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Type');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `hurdle_type` SET TAGS ('dbx_value_regex' = 'hard|soft|none');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `last_calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Calculation Date');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Record Modified By');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `next_calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Next Calculation Date');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Arrangement Notes');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `outstanding_carry_amount` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Carried Interest Amount');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `performance_threshold_moic` SET TAGS ('dbx_business_glossary_term' = 'Performance Threshold Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `preferred_return_compounding` SET TAGS ('dbx_business_glossary_term' = 'Preferred Return Compounding Method');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `preferred_return_compounding` SET TAGS ('dbx_value_regex' = 'simple|compound_annual|compound_quarterly|compound_monthly');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `regulatory_classification` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Classification');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_business_glossary_term' = 'Tax Treatment Code');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `transaction_fee_treatment` SET TAGS ('dbx_business_glossary_term' = 'Transaction Fee Treatment');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `transaction_fee_treatment` SET TAGS ('dbx_value_regex' = 'retained_by_gp|shared_with_lp|offset_against_carry|offset_against_mgmt_fee');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `transaction_fee_treatment` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `transaction_fee_treatment` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`fee`.`carried_interest` ALTER COLUMN `waterfall_tier_count` SET TAGS ('dbx_business_glossary_term' = 'Waterfall Tier Count');
ALTER TABLE `asset_management`.`fee`.`waterfall` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`fee`.`waterfall` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`waterfall` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`waterfall` SET TAGS ('dbx_subdomain' = 'carry_distribution');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `waterfall_id` SET TAGS ('dbx_business_glossary_term' = 'Waterfall ID');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund ID');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `amendment_version` SET TAGS ('dbx_business_glossary_term' = 'Amendment Version');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `calculation_basis` SET TAGS ('dbx_business_glossary_term' = 'Calculation Basis');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `calculation_basis` SET TAGS ('dbx_value_regex' = 'paid_in_capital|net_asset_value|invested_capital|committed_capital');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `carry_percentage` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Percentage');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `catch_up_percentage` SET TAGS ('dbx_business_glossary_term' = 'Catch-Up Percentage');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `clawback_cap_amount` SET TAGS ('dbx_business_glossary_term' = 'Clawback Cap Amount');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `clawback_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Flag');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `compounding_frequency` SET TAGS ('dbx_business_glossary_term' = 'Compounding Frequency');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `compounding_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|none');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `distribution_priority` SET TAGS ('dbx_business_glossary_term' = 'Distribution Priority');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `distribution_priority` SET TAGS ('dbx_value_regex' = 'pro_rata|pari_passu|sequential|custom');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `distribution_split_gp` SET TAGS ('dbx_business_glossary_term' = 'Distribution Split General Partner (GP)');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `distribution_split_lp` SET TAGS ('dbx_business_glossary_term' = 'Distribution Split Limited Partner (LP)');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `gp_commitment_percentage` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Commitment Percentage');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `hurdle_rate` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `lookback_period_years` SET TAGS ('dbx_business_glossary_term' = 'Lookback Period Years');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `lpa_reference_section` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reference Section');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `management_fee_offset_flag` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Offset Flag');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `waterfall_name` SET TAGS ('dbx_business_glossary_term' = 'Waterfall Name');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Waterfall Notes');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `preferred_return_accrual_method` SET TAGS ('dbx_business_glossary_term' = 'Preferred Return Accrual Method');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `preferred_return_accrual_method` SET TAGS ('dbx_value_regex' = 'simple|compound|irr_based');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `tier_cap_amount` SET TAGS ('dbx_business_glossary_term' = 'Tier Cap Amount');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `tier_name` SET TAGS ('dbx_business_glossary_term' = 'Tier Name');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `tier_sequence` SET TAGS ('dbx_business_glossary_term' = 'Tier Sequence');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `tier_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Tier Threshold Amount');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `transaction_fee_rebate_percentage` SET TAGS ('dbx_business_glossary_term' = 'Transaction Fee Rebate Percentage');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `waterfall_status` SET TAGS ('dbx_business_glossary_term' = 'Waterfall Status');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `waterfall_status` SET TAGS ('dbx_value_regex' = 'active|superseded|terminated|draft');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `waterfall_type` SET TAGS ('dbx_business_glossary_term' = 'Waterfall Type');
ALTER TABLE `asset_management`.`fee`.`waterfall` ALTER COLUMN `waterfall_type` SET TAGS ('dbx_value_regex' = 'european_whole_fund|american_deal_by_deal|hybrid|custom');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` SET TAGS ('dbx_subdomain' = 'carry_distribution');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `waterfall_tier_id` SET TAGS ('dbx_business_glossary_term' = 'Waterfall Tier Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `waterfall_id` SET TAGS ('dbx_business_glossary_term' = 'Waterfall Structure Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `waterfall_structure_waterfall_id` SET TAGS ('dbx_business_glossary_term' = 'Waterfall Structure Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `calculation_basis` SET TAGS ('dbx_business_glossary_term' = 'Calculation Basis');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `calculation_basis` SET TAGS ('dbx_value_regex' = 'cash_on_cash|irr|moic|nav_based|realized_proceeds');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `catch_up_percentage` SET TAGS ('dbx_business_glossary_term' = 'Catch-Up Percentage');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `clawback_applicable_flag` SET TAGS ('dbx_business_glossary_term' = 'Clawback Applicable Flag');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `clawback_percentage` SET TAGS ('dbx_business_glossary_term' = 'Clawback Percentage');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `compounding_frequency` SET TAGS ('dbx_business_glossary_term' = 'Compounding Frequency');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `compounding_frequency` SET TAGS ('dbx_value_regex' = 'daily|monthly|quarterly|annual|none');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `cumulative_distribution_cap_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Distribution Cap Amount');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `distribution_frequency` SET TAGS ('dbx_business_glossary_term' = 'Distribution Frequency');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `distribution_frequency` SET TAGS ('dbx_value_regex' = 'quarterly|semi_annual|annual|event_driven|at_liquidation');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `distribution_reinvestment_flag` SET TAGS ('dbx_business_glossary_term' = 'Distribution Reinvestment Flag');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `escrow_holdback_percentage` SET TAGS ('dbx_business_glossary_term' = 'Escrow Holdback Percentage');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `gp_allocation_percentage` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Allocation Percentage');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `hurdle_rate_percentage` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `hurdle_rate_type` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Type');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `hurdle_rate_type` SET TAGS ('dbx_value_regex' = 'simple|compounded|irr_based|none');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `lookback_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Lookback Provision Flag');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `lp_allocation_percentage` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Allocation Percentage');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `management_fee_offset_flag` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Offset Flag');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `preferred_return_shortfall_carryforward_flag` SET TAGS ('dbx_business_glossary_term' = 'Preferred Return Shortfall Carryforward Flag');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `priority_rank` SET TAGS ('dbx_business_glossary_term' = 'Priority Rank');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `tier_amendment_date` SET TAGS ('dbx_business_glossary_term' = 'Tier Amendment Date');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `tier_amendment_reason` SET TAGS ('dbx_business_glossary_term' = 'Tier Amendment Reason');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `tier_description` SET TAGS ('dbx_business_glossary_term' = 'Tier Description');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `tier_distribution_cap_amount` SET TAGS ('dbx_business_glossary_term' = 'Tier Distribution Cap Amount');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `tier_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Tier Effective Date');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `tier_name` SET TAGS ('dbx_business_glossary_term' = 'Tier Name');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `tier_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Tier Sequence Number');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `tier_status` SET TAGS ('dbx_business_glossary_term' = 'Tier Status');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `tier_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|superseded|terminated');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `tier_termination_date` SET TAGS ('dbx_business_glossary_term' = 'Tier Termination Date');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `tier_type` SET TAGS ('dbx_business_glossary_term' = 'Tier Type');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `tier_type` SET TAGS ('dbx_value_regex' = 'return_of_capital|preferred_return|gp_catch_up|carried_interest|profit_split|other');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `transaction_fee_treatment` SET TAGS ('dbx_business_glossary_term' = 'Transaction Fee Treatment');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `transaction_fee_treatment` SET TAGS ('dbx_value_regex' = 'offset_to_lp|retained_by_gp|shared|not_applicable');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `transaction_fee_treatment` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `transaction_fee_treatment` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`fee`.`waterfall_tier` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `hurdle_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate ID');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund ID');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) ID');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `gp_gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) ID');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'private_equity|real_estate|infrastructure|natural_resources|credit|multi_asset');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `benchmark_index_code` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index Code');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `benchmark_spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Spread Basis Points (bps)');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Calculation Method');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `calculation_method` SET TAGS ('dbx_value_regex' = 'irr|money_weighted|time_weighted|absolute_return');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `carry_percentage` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Percentage');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `catch_up_percentage` SET TAGS ('dbx_business_glossary_term' = 'Catch-Up Percentage');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `clawback_cap_percentage` SET TAGS ('dbx_business_glossary_term' = 'Clawback Cap Percentage');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `clawback_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Flag');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `compounding_frequency` SET TAGS ('dbx_business_glossary_term' = 'Compounding Frequency');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `compounding_frequency` SET TAGS ('dbx_value_regex' = 'simple|compound_annual|compound_quarterly|compound_monthly|compound_daily');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `crystallization_event` SET TAGS ('dbx_business_glossary_term' = 'Crystallization Event');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `cumulative_carry_distributed_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Carried Interest Distributed Amount');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `cumulative_preferred_return_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Preferred Return Amount');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `data_classification` SET TAGS ('dbx_business_glossary_term' = 'Data Classification');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `data_classification` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `distribution_waterfall_tier` SET TAGS ('dbx_business_glossary_term' = 'Distribution Waterfall Tier');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `escrow_percentage` SET TAGS ('dbx_business_glossary_term' = 'Escrow Percentage');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `high_water_mark_flag` SET TAGS ('dbx_business_glossary_term' = 'High Water Mark Flag');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `hurdle_achieved_flag` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Achieved Flag');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `hurdle_basis` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Basis');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `hurdle_basis` SET TAGS ('dbx_value_regex' = 'committed_capital|invested_capital|paid_in_capital|nav');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `hurdle_rate_status` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Status');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `hurdle_rate_status` SET TAGS ('dbx_value_regex' = 'active|inactive|superseded|pending|terminated');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `hurdle_reset_frequency` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Reset Frequency');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `hurdle_reset_frequency` SET TAGS ('dbx_value_regex' = 'none|annual|quarterly|fund_life|per_investment');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `hurdle_type` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Type');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `hurdle_type` SET TAGS ('dbx_value_regex' = 'hard|soft|blended');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `last_calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Calculation Date');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `lpa_reference` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reference');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `measurement_period` SET TAGS ('dbx_business_glossary_term' = 'Measurement Period');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `measurement_period` SET TAGS ('dbx_value_regex' = 'inception_to_date|annual|quarterly|fund_life|investment_period');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `hurdle_rate_name` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Name');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `percentage` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `performance_fee_type` SET TAGS ('dbx_business_glossary_term' = 'Performance Fee Type');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `performance_fee_type` SET TAGS ('dbx_value_regex' = 'carried_interest|incentive_fee|performance_allocation|profit_share');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `preferred_return_cumulative_flag` SET TAGS ('dbx_business_glossary_term' = 'Preferred Return Cumulative Flag');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `record_version` SET TAGS ('dbx_business_glossary_term' = 'Record Version');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `side_letter_flag` SET TAGS ('dbx_business_glossary_term' = 'Side Letter Flag');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_business_glossary_term' = 'Tax Treatment Code');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `clawback_provision_id` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `carry_escrow_id` SET TAGS ('dbx_business_glossary_term' = 'Escrow Account Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Entity Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Clawback Calculation Frequency');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_value_regex' = 'per_distribution|annual|fund_liquidation|deal_exit|continuous');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `carry_percent` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Percentage');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `clawback_calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Clawback Calculation Method');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `clawback_calculation_method` SET TAGS ('dbx_value_regex' = 'irr_based|moic_based|tvpi_based|hybrid|custom');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `clawback_cap_percent` SET TAGS ('dbx_business_glossary_term' = 'Clawback Cap Percentage');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `clawback_provision_status` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Status');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `clawback_provision_status` SET TAGS ('dbx_value_regex' = 'active|suspended|waived|triggered|settled|expired');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `cumulative_gp_distributions_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative General Partner (GP) Distributions Amount');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `cumulative_gp_distributions_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `cumulative_lp_distributions_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Limited Partner (LP) Distributions Amount');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `cumulative_lp_distributions_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `current_clawback_liability_amount` SET TAGS ('dbx_business_glossary_term' = 'Current Clawback Liability Amount');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `current_clawback_liability_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `dispute_resolution_method` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Method');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `dispute_resolution_method` SET TAGS ('dbx_value_regex' = 'arbitration|litigation|mediation|negotiation');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Effective Date');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `escrow_balance_amount` SET TAGS ('dbx_business_glossary_term' = 'Escrow Balance Amount');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `escrow_balance_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `escrow_percentage` SET TAGS ('dbx_business_glossary_term' = 'Escrow Percentage');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Expiration Date');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `fund_irr_percent` SET TAGS ('dbx_business_glossary_term' = 'Fund Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `fund_irr_percent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `fund_moic` SET TAGS ('dbx_business_glossary_term' = 'Fund Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `fund_moic` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `fund_tvpi` SET TAGS ('dbx_business_glossary_term' = 'Fund Total Value to Paid-In (TVPI)');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `fund_tvpi` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `gp_catch_up_percent` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Catch-Up Percentage');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active Flag');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `last_calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Clawback Calculation Date');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `legal_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Legal Jurisdiction');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `lookback_period_years` SET TAGS ('dbx_business_glossary_term' = 'Lookback Period Years');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `lpa_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Section Reference');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `maximum_clawback_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Clawback Amount');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `maximum_clawback_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `next_calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Next Clawback Calculation Date');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Notes');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `provision_name` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Name');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `provision_type` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Type');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `provision_type` SET TAGS ('dbx_value_regex' = 'full_clawback|partial_clawback|rolling_clawback|deal_by_deal_clawback|aggregate_clawback|escrow_based_clawback');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Clawback Settlement Amount');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `settlement_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Clawback Settlement Date');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `settlement_due_date` SET TAGS ('dbx_business_glossary_term' = 'Clawback Settlement Due Date');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_business_glossary_term' = 'Tax Treatment Code');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `trigger_condition` SET TAGS ('dbx_business_glossary_term' = 'Clawback Trigger Condition');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `trigger_event_date` SET TAGS ('dbx_business_glossary_term' = 'Clawback Trigger Event Date');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `waiver_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Clawback Waiver Approval Date');
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ALTER COLUMN `waiver_conditions` SET TAGS ('dbx_business_glossary_term' = 'Clawback Waiver Conditions');
ALTER TABLE `asset_management`.`fee`.`clawback_event` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`fee`.`clawback_event` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`clawback_event` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`clawback_event` SET TAGS ('dbx_subdomain' = 'carry_distribution');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `clawback_event_id` SET TAGS ('dbx_business_glossary_term' = 'Clawback Event ID');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `carry_escrow_id` SET TAGS ('dbx_business_glossary_term' = 'Escrow Account ID');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Record Created By User ID');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund ID');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Entity ID');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `updated_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Record Updated By User ID');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `updated_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `updated_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `auditor_verification_date` SET TAGS ('dbx_business_glossary_term' = 'Auditor Verification Date');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `auditor_verified_flag` SET TAGS ('dbx_business_glossary_term' = 'Auditor Verified Flag');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Clawback Calculation Date');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Clawback Calculation Methodology');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `carried_interest_distributed_amount` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Distributed Amount');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `carried_interest_entitled_amount` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Entitled Amount');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `carry_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Rate Percent');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `clawback_cap_amount` SET TAGS ('dbx_business_glossary_term' = 'Clawback Cap Amount');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `clawback_cap_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Clawback Cap Applied Flag');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `clawback_gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Clawback Gross Amount');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `clawback_net_amount` SET TAGS ('dbx_business_glossary_term' = 'Clawback Net Amount');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Clawback Dispute Flag');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Clawback Dispute Reason');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `dispute_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Date');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Clawback Payment Due Date');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `event_status` SET TAGS ('dbx_business_glossary_term' = 'Clawback Event Status');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `fund_irr_percent` SET TAGS ('dbx_business_glossary_term' = 'Fund Internal Rate of Return (IRR) Percent');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `fund_moic` SET TAGS ('dbx_business_glossary_term' = 'Fund Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percent');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `legal_counsel_opinion_flag` SET TAGS ('dbx_business_glossary_term' = 'Legal Counsel Opinion Flag');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `lp_capital_returned_amount` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Capital Returned Amount');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `lp_profit_distributed_amount` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner (LP) Profit Distributed Amount');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Clawback Event Notes');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `notification_date` SET TAGS ('dbx_business_glossary_term' = 'Clawback Notification Date');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Clawback Event Number');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `offset_amount` SET TAGS ('dbx_business_glossary_term' = 'Clawback Offset Amount');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Clawback Payment Method');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'cash|escrow_release|offset_against_future_carry|promissory_note|in_kind_transfer|other');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Clawback Settlement Date');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `tax_gross_up_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Gross-Up Amount');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `trigger_date` SET TAGS ('dbx_business_glossary_term' = 'Clawback Trigger Date');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `trigger_reason` SET TAGS ('dbx_business_glossary_term' = 'Clawback Trigger Reason');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `trigger_reason` SET TAGS ('dbx_value_regex' = 'fund_liquidation|final_distribution|performance_shortfall|hurdle_breach|waterfall_true_up|interim_reconciliation');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `waiver_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Waiver Approval Date');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `waiver_flag` SET TAGS ('dbx_business_glossary_term' = 'Clawback Waiver Flag');
ALTER TABLE `asset_management`.`fee`.`clawback_event` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Clawback Waiver Reason');
ALTER TABLE `asset_management`.`fee`.`accrual` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`fee`.`accrual` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`accrual` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`accrual` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `accrual_id` SET TAGS ('dbx_business_glossary_term' = 'Accrual Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `external_manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `investment_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `accrual_status` SET TAGS ('dbx_business_glossary_term' = 'Accrual Lifecycle Status');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `accrual_status` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|approved|posted|reversed|cancelled');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Accrual Adjustment Amount');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Accrual Approval Date');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `basis` SET TAGS ('dbx_business_glossary_term' = 'Accrual Calculation Basis');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `basis` SET TAGS ('dbx_value_regex' = 'aum|nav|committed_capital|paid_in_capital|gross_asset_value|transaction_value');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `basis_amount` SET TAGS ('dbx_business_glossary_term' = 'Accrual Basis Amount');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `benchmark_fee_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Fee Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Method');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `calculation_method` SET TAGS ('dbx_value_regex' = 'average_balance|end_of_period|beginning_of_period|daily_average|transaction_based');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Accrual Calculation Timestamp');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `catch_up_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Catch-Up Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `clawback_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Flag');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `fee_rebate_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Rebate Amount');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `fee_type` SET TAGS ('dbx_business_glossary_term' = 'Fee Type Classification');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `fee_type` SET TAGS ('dbx_value_regex' = 'management_fee|carried_interest|performance_fee|transaction_fee|advisory_fee|administration_fee');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `fee_variance_percent` SET TAGS ('dbx_business_glossary_term' = 'Fee Variance Percentage');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `frequency` SET TAGS ('dbx_business_glossary_term' = 'Accrual Frequency');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annually|annually|event_driven');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `gross_accrual_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Accrual Amount');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percentage (Preferred Return)');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `net_accrual_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Accrual Amount');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Accrual Notes and Comments');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Accrual Reference Number');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Accrual Period End Date');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Accrual Period Start Date');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `posting_date` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Posting Date');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Accrual Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `reversal_date` SET TAGS ('dbx_business_glossary_term' = 'Accrual Reversal Date');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `reversal_reason` SET TAGS ('dbx_business_glossary_term' = 'Accrual Reversal Reason');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `source_system_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference Identifier');
ALTER TABLE `asset_management`.`fee`.`accrual` ALTER COLUMN `waterfall_tier` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Waterfall Tier');
ALTER TABLE `asset_management`.`fee`.`payment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`fee`.`payment` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`payment` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`payment` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `payment_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `external_manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `investment_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `settlement_cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Settlement Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `settlement_instruction_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Instruction Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `approved_by` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `base_currency_gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Gross Amount');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `base_currency_net_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Net Amount');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `beneficiary_account_number` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Account Number');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `beneficiary_account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `beneficiary_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `beneficiary_bank_bic` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Bank Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `beneficiary_bank_bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `beneficiary_bank_bic` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `beneficiary_bank_name` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Bank Name');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `beneficiary_bank_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `clawback_amount` SET TAGS ('dbx_business_glossary_term' = 'Clawback Amount');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `clawback_provision_applied` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Applied Flag');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Currency Code');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `payment_description` SET TAGS ('dbx_business_glossary_term' = 'Payment Description');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Due Date');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `fee_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Fee Period End Date');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `fee_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Fee Period Start Date');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `fee_type` SET TAGS ('dbx_business_glossary_term' = 'Fee Type');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `fee_type` SET TAGS ('dbx_value_regex' = 'management_fee|carried_interest|transaction_fee|monitoring_fee|advisory_fee|performance_fee');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `gross_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Payment Amount');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `hurdle_rate_met` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Met Flag');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `invoice_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Date');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Invoice Number');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `is_late_payment` SET TAGS ('dbx_business_glossary_term' = 'Is Late Payment Flag');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `late_payment_penalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Late Payment Penalty Amount');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `method` SET TAGS ('dbx_value_regex' = 'wire_transfer|ach|check|electronic_funds_transfer|swift|sepa');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `net_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Payment Amount');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Payment Notes');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `other_deductions_amount` SET TAGS ('dbx_business_glossary_term' = 'Other Deductions Amount');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Date');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'reconciled|pending_reconciliation|discrepancy|unreconciled');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Amount');
ALTER TABLE `asset_management`.`fee`.`payment` ALTER COLUMN `withholding_tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Rate');
ALTER TABLE `asset_management`.`fee`.`invoice` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`fee`.`invoice` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`invoice` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`invoice` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `external_manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `accrual_date` SET TAGS ('dbx_business_glossary_term' = 'Accrual Date');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `base_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Amount');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `benchmark_fee_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Fee Rate in Basis Points (bps)');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `carry_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `clawback_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Flag');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `invoice_description` SET TAGS ('dbx_business_glossary_term' = 'Invoice Description');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `dispute_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Date');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Due Date');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `fee_basis` SET TAGS ('dbx_business_glossary_term' = 'Fee Basis');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `fee_basis` SET TAGS ('dbx_value_regex' = 'aum|committed_capital|nav|transaction_value|fixed');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `fee_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Fee Rate in Basis Points (bps)');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `fee_type` SET TAGS ('dbx_business_glossary_term' = 'Fee Type');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `fee_type` SET TAGS ('dbx_value_regex' = 'management_fee|performance_fee|monitoring_fee|transaction_fee|advisory_fee|administration_fee');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `fee_variance_bps` SET TAGS ('dbx_business_glossary_term' = 'Fee Variance in Basis Points (bps)');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `gross_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Fee Amount');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `hurdle_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `invoice_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Date');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `invoicing_entity_lei` SET TAGS ('dbx_business_glossary_term' = 'Invoicing Entity Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `invoicing_entity_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `invoicing_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Invoicing Entity Name');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `net_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Fee Amount');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Invoice Number');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `payment_reference` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'pending|approved|paid|disputed|cancelled|overdue');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Period End Date');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Period Start Date');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `rebate_amount` SET TAGS ('dbx_business_glossary_term' = 'Rebate Amount');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `received_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Received Timestamp');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Resolution Date');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `source_document_uri` SET TAGS ('dbx_business_glossary_term' = 'Source Document Uniform Resource Identifier (URI)');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `asset_management`.`fee`.`invoice` ALTER COLUMN `waterfall_tier` SET TAGS ('dbx_business_glossary_term' = 'Waterfall Tier');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `transaction_fee_id` SET TAGS ('dbx_business_glossary_term' = 'Transaction Fee ID');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Advisor Entity ID');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Entity ID');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `investment_id` SET TAGS ('dbx_business_glossary_term' = 'Investment ID');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `accrual_date` SET TAGS ('dbx_business_glossary_term' = 'Accrual Date');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `allocation_method` SET TAGS ('dbx_business_glossary_term' = 'Allocation Method');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `allocation_method` SET TAGS ('dbx_value_regex' = 'direct|pro_rata|waterfall|custom');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `benchmark_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Rate Percent');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `capitalized_flag` SET TAGS ('dbx_business_glossary_term' = 'Capitalized Flag');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Flag');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `dispute_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Date');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Due Date');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `fee_basis` SET TAGS ('dbx_business_glossary_term' = 'Fee Basis');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `fee_basis` SET TAGS ('dbx_value_regex' = 'transaction_value|enterprise_value|equity_value|committed_capital|flat_fee');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `fee_category` SET TAGS ('dbx_business_glossary_term' = 'Fee Category');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `fee_category` SET TAGS ('dbx_value_regex' = 'transaction|management|performance|other');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `fee_gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Gross Amount');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `fee_net_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Net Amount');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `fee_number` SET TAGS ('dbx_business_glossary_term' = 'Fee Number');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `fee_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Fee Rate Percent');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `fee_status` SET TAGS ('dbx_business_glossary_term' = 'Fee Status');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `fee_status` SET TAGS ('dbx_value_regex' = 'accrued|invoiced|paid|disputed|waived|cancelled');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `fee_type` SET TAGS ('dbx_business_glossary_term' = 'Fee Type');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `ic_approval_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Flag');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `invoice_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Date');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `lpa_reference_clause` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reference Clause');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|ach|check|offset|escrow_release');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `rebate_amount` SET TAGS ('dbx_business_glossary_term' = 'Rebate Amount');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `rebate_policy_flag` SET TAGS ('dbx_business_glossary_term' = 'Rebate Policy Flag');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `service_description` SET TAGS ('dbx_business_glossary_term' = 'Service Description');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `tax_treatment` SET TAGS ('dbx_business_glossary_term' = 'Tax Treatment');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `tax_treatment` SET TAGS ('dbx_value_regex' = 'deductible|non_deductible|capitalized|other');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `tax_treatment` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `tax_treatment` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `transaction_date` SET TAGS ('dbx_business_glossary_term' = 'Transaction Date');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `transaction_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Transaction Value Amount');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `variance_to_benchmark_bps` SET TAGS ('dbx_business_glossary_term' = 'Variance to Benchmark Basis Points (bps)');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `waiver_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Waiver Approval Date');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `waiver_flag` SET TAGS ('dbx_business_glossary_term' = 'Waiver Flag');
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `gp_fee_rebate_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Fee Rebate ID');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Administrator ID');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund ID');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Entity ID');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `lpa_terms_id` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) ID');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `portfolio_company_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Company ID');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `transaction_fee_id` SET TAGS ('dbx_business_glossary_term' = 'Transaction ID');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `transaction_transaction_fee_id` SET TAGS ('dbx_business_glossary_term' = 'Transaction ID');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `application_date` SET TAGS ('dbx_business_glossary_term' = 'Application Date');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `auditor_verification_date` SET TAGS ('dbx_business_glossary_term' = 'Auditor Verification Date');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `auditor_verified_flag` SET TAGS ('dbx_business_glossary_term' = 'Auditor Verified Flag');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Calculation Date');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Calculation Methodology');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `cumulative_rebate_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Rebate Amount');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Flag');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `dispute_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Date');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `gross_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Fee Amount');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `lpa_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Section Reference');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `management_fee_offset_amount` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Offset Amount');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `rebate_adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Rebate Adjustment Amount');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `rebate_cap_amount` SET TAGS ('dbx_business_glossary_term' = 'Rebate Cap Amount');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `rebate_cap_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Rebate Cap Applied Flag');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `rebate_gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Rebate Gross Amount');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `rebate_net_amount` SET TAGS ('dbx_business_glossary_term' = 'Rebate Net Amount');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `rebate_number` SET TAGS ('dbx_business_glossary_term' = 'Rebate Number');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `rebate_percentage` SET TAGS ('dbx_business_glossary_term' = 'Rebate Percentage');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `rebate_status` SET TAGS ('dbx_business_glossary_term' = 'Rebate Status');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `rebate_status` SET TAGS ('dbx_value_regex' = 'pending|calculated|approved|applied|disputed|cancelled');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `rebate_type` SET TAGS ('dbx_business_glossary_term' = 'Rebate Type');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `rebate_type` SET TAGS ('dbx_value_regex' = 'transaction_fee_offset|monitoring_fee_offset|advisory_fee_offset|director_fee_offset|broken_deal_fee_offset|other');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` SET TAGS ('dbx_subdomain' = 'carry_distribution');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `carry_distribution_id` SET TAGS ('dbx_business_glossary_term' = 'Carry Distribution ID');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `carry_escrow_id` SET TAGS ('dbx_business_glossary_term' = 'Escrow Account ID');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `escrow_account_carry_escrow_id` SET TAGS ('dbx_business_glossary_term' = 'Escrow Account ID');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund ID');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Entity ID');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `investment_id` SET TAGS ('dbx_business_glossary_term' = 'Investment ID');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `settlement_cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Settlement Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `auditor_verification_date` SET TAGS ('dbx_business_glossary_term' = 'Auditor Verification Date');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `auditor_verified_flag` SET TAGS ('dbx_business_glossary_term' = 'Auditor Verified Flag');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Calculation Methodology');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_value_regex' = 'deal_by_deal|whole_fund|hybrid');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `carry_gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Carry Gross Amount');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `carry_net_amount` SET TAGS ('dbx_business_glossary_term' = 'Carry Net Amount');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `carry_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Carry Rate Percent');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `catch_up_amount` SET TAGS ('dbx_business_glossary_term' = 'Catch-Up Amount');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `clawback_reserve_amount` SET TAGS ('dbx_business_glossary_term' = 'Clawback Reserve Amount');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `distribution_date` SET TAGS ('dbx_business_glossary_term' = 'Distribution Date');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `distribution_number` SET TAGS ('dbx_business_glossary_term' = 'Distribution Number');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `distribution_status` SET TAGS ('dbx_business_glossary_term' = 'Distribution Status');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `distribution_status` SET TAGS ('dbx_value_regex' = 'pending|approved|paid|cancelled|reversed');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `fund_irr_percent` SET TAGS ('dbx_business_glossary_term' = 'Fund Internal Rate of Return (IRR) Percent');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `fund_moic` SET TAGS ('dbx_business_glossary_term' = 'Fund Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `gross_proceeds_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Proceeds Amount');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percent');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `investment_irr_percent` SET TAGS ('dbx_business_glossary_term' = 'Investment Internal Rate of Return (IRR) Percent');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `investment_moic` SET TAGS ('dbx_business_glossary_term' = 'Investment Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `lpa_reference_section` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reference Section');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `net_distribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Distribution Amount');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|ach|check|book_transfer');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `preferred_return_amount` SET TAGS ('dbx_business_glossary_term' = 'Preferred Return Amount');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `profit_split_amount` SET TAGS ('dbx_business_glossary_term' = 'Profit Split Amount');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `realization_date` SET TAGS ('dbx_business_glossary_term' = 'Realization Date');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `realization_event_type` SET TAGS ('dbx_business_glossary_term' = 'Realization Event Type');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `realization_event_type` SET TAGS ('dbx_value_regex' = 'exit|recapitalization|ipo|secondary_sale|dividend_recapitalization|partial_exit');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `return_of_capital_amount` SET TAGS ('dbx_business_glossary_term' = 'Return of Capital Amount');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `tax_withholding_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Withholding Amount');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `waterfall_tier` SET TAGS ('dbx_business_glossary_term' = 'Waterfall Tier');
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ALTER COLUMN `waterfall_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3|tier_4');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` SET TAGS ('dbx_subdomain' = 'carry_distribution');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `carry_escrow_id` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Escrow Account Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Entity Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Entity Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `auditor_verified_flag` SET TAGS ('dbx_business_glossary_term' = 'Auditor Verified Flag');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `clawback_amount_applied` SET TAGS ('dbx_business_glossary_term' = 'Clawback Amount Applied from Escrow');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `clawback_triggered_flag` SET TAGS ('dbx_business_glossary_term' = 'Clawback Triggered Flag');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `cumulative_carry_distributed_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Carried Interest Distributed Amount');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `cumulative_escrow_withheld_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Escrow Withheld Amount');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `dispute_description` SET TAGS ('dbx_business_glossary_term' = 'Dispute Description');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Flag');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `dispute_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Date');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `escrow_account_name` SET TAGS ('dbx_business_glossary_term' = 'Escrow Account Name');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `escrow_account_number` SET TAGS ('dbx_business_glossary_term' = 'Escrow Account Number');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `escrow_account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `escrow_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `escrow_amount` SET TAGS ('dbx_business_glossary_term' = 'Escrow Amount Held');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `escrow_percentage` SET TAGS ('dbx_business_glossary_term' = 'Escrow Percentage of Carry Distributions');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `escrow_status` SET TAGS ('dbx_business_glossary_term' = 'Escrow Account Status');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `escrow_status` SET TAGS ('dbx_value_regex' = 'active|released|partially_released|expired|disputed|closed');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `establishment_date` SET TAGS ('dbx_business_glossary_term' = 'Escrow Establishment Date');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Escrow Expiration Date');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `interest_accrual_flag` SET TAGS ('dbx_business_glossary_term' = 'Interest Accrual Flag');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `interest_allocation_method` SET TAGS ('dbx_business_glossary_term' = 'Interest Allocation Method');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `interest_allocation_method` SET TAGS ('dbx_value_regex' = 'gp|lp|pro_rata|fund');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `interest_earned_amount` SET TAGS ('dbx_business_glossary_term' = 'Interest Earned Amount');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `interest_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Interest Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `investor_disclosure_flag` SET TAGS ('dbx_business_glossary_term' = 'Investor Disclosure Flag');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `last_audit_date` SET TAGS ('dbx_business_glossary_term' = 'Last Audit Date');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `legal_counsel_opinion_flag` SET TAGS ('dbx_business_glossary_term' = 'Legal Counsel Opinion Flag');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `lpa_reference_section` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reference Section');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `next_release_amount` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Release Amount');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `next_release_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Release Date');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Escrow Account Notes');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `release_date` SET TAGS ('dbx_business_glossary_term' = 'Escrow Release Date');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `release_schedule_type` SET TAGS ('dbx_business_glossary_term' = 'Release Schedule Type');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `release_schedule_type` SET TAGS ('dbx_value_regex' = 'single|periodic|milestone|performance');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `release_trigger_condition` SET TAGS ('dbx_business_glossary_term' = 'Release Trigger Condition');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `released_amount` SET TAGS ('dbx_business_glossary_term' = 'Released Escrow Amount');
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ALTER COLUMN `remaining_balance` SET TAGS ('dbx_business_glossary_term' = 'Remaining Escrow Balance');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `fee_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Fee Benchmark Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `data_vendor_id` SET TAGS ('dbx_business_glossary_term' = 'Data Vendor Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equities|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `benchmark_code` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Code');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `benchmark_name` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Name');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `benchmark_status` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Status');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `benchmark_status` SET TAGS ('dbx_value_regex' = 'active|superseded|archived|under_review');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `carried_interest_25th_percentile_percent` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Twenty-Fifth (25th) Percentile Percentage');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `carried_interest_75th_percentile_percent` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Seventy-Fifth (75th) Percentile Percentage');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `carried_interest_median_percent` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Median Percentage');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `catch_up_provision_prevalence_percent` SET TAGS ('dbx_business_glossary_term' = 'Catch-Up Provision Prevalence Percentage');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `clawback_provision_prevalence_percent` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Prevalence Percentage');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `data_source_report_reference` SET TAGS ('dbx_business_glossary_term' = 'Data Source Report Reference');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `fund_size_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Fund Size Currency Code');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `fund_size_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `fund_size_lower_bound_amount` SET TAGS ('dbx_business_glossary_term' = 'Fund Size Lower Bound Amount');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `fund_size_upper_bound_amount` SET TAGS ('dbx_business_glossary_term' = 'Fund Size Upper Bound Amount');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Focus');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `hurdle_rate_25th_percentile_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Twenty-Fifth (25th) Percentile Percentage');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `hurdle_rate_75th_percentile_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Seventy-Fifth (75th) Percentile Percentage');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `hurdle_rate_median_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Median Percentage');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `management_fee_25th_percentile_percent` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Twenty-Fifth (25th) Percentile Percentage');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `management_fee_75th_percentile_percent` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Seventy-Fifth (75th) Percentile Percentage');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `management_fee_median_percent` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Median Percentage');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `most_favored_nation_prevalence_percent` SET TAGS ('dbx_business_glossary_term' = 'Most Favored Nation (MFN) Clause Prevalence Percentage');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `publication_date` SET TAGS ('dbx_business_glossary_term' = 'Publication Date');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `sample_size_count` SET TAGS ('dbx_business_glossary_term' = 'Sample Size Count');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `strategy_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy Type');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `usage_notes` SET TAGS ('dbx_business_glossary_term' = 'Usage Notes');
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `rate_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Schedule Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `superseded_by_schedule_rate_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Rate Schedule Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Rate Schedule Approval Date');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `benchmark_index_code` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index Code');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Frequency');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_value_regex' = 'daily|monthly|quarterly|semi_annually|annually');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Method');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `calculation_method` SET TAGS ('dbx_value_regex' = 'flat_rate|tiered_blended|tiered_marginal|performance_hurdle|high_water_mark');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `carry_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `catch_up_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Catch-Up Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `clawback_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Flag');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `fee_basis` SET TAGS ('dbx_business_glossary_term' = 'Fee Basis');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `fee_basis` SET TAGS ('dbx_value_regex' = 'aum|nav|committed_capital|invested_capital|gav|transaction_value');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `fee_offset_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Fee Offset Provision Flag');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `fee_type` SET TAGS ('dbx_business_glossary_term' = 'Fee Type');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `fee_type` SET TAGS ('dbx_value_regex' = 'management_fee|performance_fee|transaction_fee|advisory_fee|administration_fee|custody_fee');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `geography_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `geography_scope` SET TAGS ('dbx_value_regex' = 'global|north_america|europe|asia_pacific|emerging_markets|domestic');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `high_water_mark_flag` SET TAGS ('dbx_business_glossary_term' = 'High Water Mark Flag');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `investor_type` SET TAGS ('dbx_business_glossary_term' = 'Investor Type');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `investor_type` SET TAGS ('dbx_value_regex' = 'institutional|retail|high_net_worth|sovereign_wealth|endowment|pension');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `lpa_reference_section` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reference Section');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `maximum_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Fee Amount');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `minimum_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Fee Amount');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `most_favored_nation_flag` SET TAGS ('dbx_business_glossary_term' = 'Most Favored Nation (MFN) Clause Flag');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Rate Schedule Notes');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `offset_percentage` SET TAGS ('dbx_business_glossary_term' = 'Fee Offset Percentage');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Fee Payment Frequency');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annually|annually|on_demand');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `regulatory_reporting_category` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Category');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `schedule_code` SET TAGS ('dbx_business_glossary_term' = 'Rate Schedule Code');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `schedule_name` SET TAGS ('dbx_business_glossary_term' = 'Rate Schedule Name');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_business_glossary_term' = 'Rate Schedule Status');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_value_regex' = 'draft|active|suspended|expired|superseded');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `tier_1_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Tier 1 Rate in Basis Points (bps)');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `tier_1_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Tier 1 Threshold Amount');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `tier_2_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Tier 2 Rate in Basis Points (bps)');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `tier_2_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Tier 2 Threshold Amount');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `tier_3_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Tier 3 Rate in Basis Points (bps)');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `tier_3_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Tier 3 Threshold Amount');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `tier_4_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Tier 4 Rate in Basis Points (bps)');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `tier_4_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Tier 4 Threshold Amount');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `tier_5_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Tier 5 Rate in Basis Points (bps)');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `tier_5_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Tier 5 Threshold Amount');
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Rate Schedule Version Number');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `fee_calculation_run_id` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Run Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `external_manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `fee_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Fee Benchmark Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `investment_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `original_run_fee_calculation_run_id` SET TAGS ('dbx_business_glossary_term' = 'Original Fee Calculation Run Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `performance_calculation_run_id` SET TAGS ('dbx_business_glossary_term' = 'Performance Calculation Run Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `accrual_flag` SET TAGS ('dbx_business_glossary_term' = 'Fee Accrual Flag');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Adjustment Amount');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Approval Date');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Approved By');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `aum_basis_amount` SET TAGS ('dbx_business_glossary_term' = 'Assets Under Management (AUM) Basis Amount');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `basis_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Basis Currency Code');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `basis_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Date');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `calculation_engine` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Engine');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Frequency');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Methodology');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Timestamp');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `calculation_version` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Version');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `carry_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `catch_up_provision_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Catch-Up Provision Applied Flag');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `committed_capital_amount` SET TAGS ('dbx_business_glossary_term' = 'Committed Capital Amount');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `fee_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Fee Currency Code');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `fee_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `fee_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Fee Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `fee_type` SET TAGS ('dbx_business_glossary_term' = 'Fee Type');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `fee_type` SET TAGS ('dbx_value_regex' = 'management_fee|performance_fee|carried_interest|transaction_fee|advisory_fee|administration_fee');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `fund_irr_percent` SET TAGS ('dbx_business_glossary_term' = 'Fund Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `gross_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Fee Amount');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `hurdle_met_flag` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Met Flag');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `invested_capital_amount` SET TAGS ('dbx_business_glossary_term' = 'Invested Capital Amount');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `lpa_reference_clause` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reference Clause');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `nav_basis_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Basis Amount');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `net_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Fee Amount');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Run Notes');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `offset_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Offset Amount');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `payment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Fee Payment Due Date');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `performance_benchmark_code` SET TAGS ('dbx_business_glossary_term' = 'Performance Benchmark Code');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Period End Date');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Period Start Date');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `recalculation_flag` SET TAGS ('dbx_business_glossary_term' = 'Fee Recalculation Flag');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `run_number` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Run Number');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `run_status` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Run Status');
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ALTER COLUMN `tiered_rate_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Tiered Rate Applied Flag');
ALTER TABLE `asset_management`.`fee`.`dispute` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`fee`.`dispute` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`dispute` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`dispute` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `dispute_id` SET TAGS ('dbx_business_glossary_term' = 'Dispute Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `assigned_to_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned To User Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `assigned_to_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `assigned_to_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `external_manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `identified_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Identified By User Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `identified_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `identified_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `investment_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `auditor_notification_date` SET TAGS ('dbx_business_glossary_term' = 'Auditor Notification Date');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `auditor_notified_flag` SET TAGS ('dbx_business_glossary_term' = 'Auditor Notified Flag');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `dispute_category` SET TAGS ('dbx_business_glossary_term' = 'Dispute Category');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `dispute_category` SET TAGS ('dbx_value_regex' = 'calculation_error|unauthorized_charge|lpa_non_compliance|rate_discrepancy|timing_error|documentation_missing');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `claimed_amount` SET TAGS ('dbx_business_glossary_term' = 'Claimed Amount');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `correct_amount` SET TAGS ('dbx_business_glossary_term' = 'Correct Amount');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `dispute_status` SET TAGS ('dbx_business_glossary_term' = 'Dispute Status');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `dispute_status` SET TAGS ('dbx_value_regex' = 'open|under_review|escalated|resolved|closed|withdrawn');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `dispute_type` SET TAGS ('dbx_business_glossary_term' = 'Dispute Type');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `dispute_type` SET TAGS ('dbx_value_regex' = 'management_fee|carried_interest|transaction_fee|monitoring_fee|advisory_fee|other');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `disputed_amount` SET TAGS ('dbx_business_glossary_term' = 'Disputed Amount');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `escalation_date` SET TAGS ('dbx_business_glossary_term' = 'Escalation Date');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `escalation_flag` SET TAGS ('dbx_business_glossary_term' = 'Escalation Flag');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `escalation_level` SET TAGS ('dbx_business_glossary_term' = 'Escalation Level');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `escalation_level` SET TAGS ('dbx_value_regex' = 'senior_management|legal_counsel|arbitration|litigation');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `fee_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Fee Period End Date');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `fee_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Fee Period Start Date');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `impact_on_nav_flag` SET TAGS ('dbx_business_glossary_term' = 'Impact on Net Asset Value (NAV) Flag');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `lpa_reference_clause` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reference Clause');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `manager_response` SET TAGS ('dbx_business_glossary_term' = 'Manager Response');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `materiality_threshold_exceeded_flag` SET TAGS ('dbx_business_glossary_term' = 'Materiality Threshold Exceeded Flag');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `notification_date` SET TAGS ('dbx_business_glossary_term' = 'Notification Date');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reference Number');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Dispute Priority');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `raised_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Raised Date');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `refund_amount` SET TAGS ('dbx_business_glossary_term' = 'Refund Amount');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `refund_due_flag` SET TAGS ('dbx_business_glossary_term' = 'Refund Due Flag');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `refund_received_date` SET TAGS ('dbx_business_glossary_term' = 'Refund Received Date');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Resolution Date');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `resolution_notes` SET TAGS ('dbx_business_glossary_term' = 'Resolution Notes');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `resolution_outcome` SET TAGS ('dbx_business_glossary_term' = 'Resolution Outcome');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `resolution_outcome` SET TAGS ('dbx_value_regex' = 'fee_adjusted|fee_upheld|partial_adjustment|withdrawn|escalated_to_arbitration');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `resolved_amount` SET TAGS ('dbx_business_glossary_term' = 'Resolved Amount');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `response_due_date` SET TAGS ('dbx_business_glossary_term' = 'Response Due Date');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `response_received_date` SET TAGS ('dbx_business_glossary_term' = 'Response Received Date');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `supporting_documentation_flag` SET TAGS ('dbx_business_glossary_term' = 'Supporting Documentation Flag');
ALTER TABLE `asset_management`.`fee`.`dispute` ALTER COLUMN `variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Variance Amount');
ALTER TABLE `asset_management`.`fee`.`waiver` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`fee`.`waiver` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`waiver` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`waiver` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `waiver_id` SET TAGS ('dbx_business_glossary_term' = 'Waiver Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Entity Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `amount_cap` SET TAGS ('dbx_business_glossary_term' = 'Waiver Amount Cap');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `application_frequency` SET TAGS ('dbx_business_glossary_term' = 'Application Frequency');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `application_frequency` SET TAGS ('dbx_value_regex' = 'quarterly|semi_annually|annually|per_transaction|continuous');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `auditor_verification_date` SET TAGS ('dbx_business_glossary_term' = 'Auditor Verification Date');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `auditor_verified_flag` SET TAGS ('dbx_business_glossary_term' = 'Auditor Verified Flag');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `basis_points` SET TAGS ('dbx_business_glossary_term' = 'Waiver Basis Points (bps)');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `benchmark_fee_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Fee Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Calculation Methodology');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `co_investment_linkage_flag` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Linkage Flag');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `commitment_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Commitment Threshold Amount');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `cumulative_waiver_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Waiver Amount');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `fee_transparency_disclosure_flag` SET TAGS ('dbx_business_glossary_term' = 'Fee Transparency Disclosure Flag');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `ic_approval_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Flag');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `last_applied_date` SET TAGS ('dbx_business_glossary_term' = 'Last Applied Date');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `legal_counsel_review_flag` SET TAGS ('dbx_business_glossary_term' = 'Legal Counsel Review Flag');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `lpa_reference_section` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reference Section');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `lpac_participation_flag` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner Advisory Committee (LPAC) Participation Flag');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `most_favored_nation_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Most Favored Nation (MFN) Clause Flag');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `net_fee_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Net Fee Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reference Number');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Waiver Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `regulatory_reporting_category` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Category');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `revocation_date` SET TAGS ('dbx_business_glossary_term' = 'Revocation Date');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `revocation_reason` SET TAGS ('dbx_business_glossary_term' = 'Revocation Reason');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `side_letter_reference` SET TAGS ('dbx_business_glossary_term' = 'Side Letter Reference');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `trigger_condition` SET TAGS ('dbx_business_glossary_term' = 'Trigger Condition');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `waiver_status` SET TAGS ('dbx_business_glossary_term' = 'Waiver Status');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `waiver_status` SET TAGS ('dbx_value_regex' = 'proposed|approved|active|expired|revoked|cancelled');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `waiver_type` SET TAGS ('dbx_business_glossary_term' = 'Waiver Type');
ALTER TABLE `asset_management`.`fee`.`waiver` ALTER COLUMN `waiver_type` SET TAGS ('dbx_value_regex' = 'management_fee|monitoring_fee|transaction_fee|advisory_fee|other');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `monitoring_fee_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Fee Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Entity Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `investment_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `portfolio_company_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Company Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `annual_flat_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Annual Flat Fee Amount');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `benchmark_fee_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Fee Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `billing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Billing Frequency');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `billing_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly|one_time');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `calculation_base` SET TAGS ('dbx_business_glossary_term' = 'Calculation Base');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `calculation_base` SET TAGS ('dbx_value_regex' = 'ebitda|revenue|enterprise_value|nav|none');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `capitalized_flag` SET TAGS ('dbx_business_glossary_term' = 'Capitalized Flag');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `dispute_description` SET TAGS ('dbx_business_glossary_term' = 'Dispute Description');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Flag');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `dispute_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Date');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `escalation_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Escalation Clause Flag');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `escalation_index` SET TAGS ('dbx_business_glossary_term' = 'Escalation Index');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `escalation_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Escalation Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `fee_arrangement_status` SET TAGS ('dbx_business_glossary_term' = 'Fee Arrangement Status');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `fee_arrangement_status` SET TAGS ('dbx_value_regex' = 'active|suspended|terminated|pending|draft');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `fee_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Fee Reference Number');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `fee_structure_type` SET TAGS ('dbx_business_glossary_term' = 'Fee Structure Type');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `fee_structure_type` SET TAGS ('dbx_value_regex' = 'annual_flat_fee|percentage_of_ebitda|percentage_of_revenue|tiered|hybrid');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `ic_approval_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Flag');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `investment_agreement_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Agreement Reference');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `lpa_offset_percentage` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Offset Percentage');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `lpa_offset_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Offset Provision Flag');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `lpa_reference_section` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reference Section');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `maximum_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Fee Amount');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `minimum_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Fee Amount');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `payment_timing` SET TAGS ('dbx_business_glossary_term' = 'Payment Timing');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `payment_timing` SET TAGS ('dbx_value_regex' = 'advance|arrears|upon_invoice');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `percentage_rate` SET TAGS ('dbx_business_glossary_term' = 'Percentage Rate');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `regulatory_reporting_category` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Category');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `service_description` SET TAGS ('dbx_business_glossary_term' = 'Service Description');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_business_glossary_term' = 'Tax Treatment Code');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `termination_trigger` SET TAGS ('dbx_business_glossary_term' = 'Termination Trigger');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `termination_trigger` SET TAGS ('dbx_value_regex' = 'exit|sale|ipo|maturity|breach|mutual_agreement');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `transparency_disclosure_flag` SET TAGS ('dbx_business_glossary_term' = 'Transparency Disclosure Flag');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `variance_to_benchmark_bps` SET TAGS ('dbx_business_glossary_term' = 'Variance to Benchmark Basis Points (bps)');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `waiver_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Waiver Approval Date');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `waiver_flag` SET TAGS ('dbx_business_glossary_term' = 'Waiver Flag');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `withholding_tax_applicable_flag` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Applicable Flag');
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ALTER COLUMN `withholding_tax_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `organizational_expense_id` SET TAGS ('dbx_business_glossary_term' = 'Organizational Expense Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Service Provider Entity Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `allocation_method` SET TAGS ('dbx_business_glossary_term' = 'Allocation Method');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `allocation_method` SET TAGS ('dbx_value_regex' = 'pro_rata|equal|custom|lpa_defined');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `amortization_period_months` SET TAGS ('dbx_business_glossary_term' = 'Amortization Period in Months');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `base_currency_net_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Net Amount');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `capitalized_flag` SET TAGS ('dbx_business_glossary_term' = 'Capitalized Flag');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Flag');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `dispute_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Date');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Due Date');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `expense_category` SET TAGS ('dbx_business_glossary_term' = 'Expense Category');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `expense_category` SET TAGS ('dbx_value_regex' = 'formation|launch|ongoing_operational|regulatory|advisory');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `expense_number` SET TAGS ('dbx_business_glossary_term' = 'Expense Reference Number');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `expense_status` SET TAGS ('dbx_business_glossary_term' = 'Expense Status');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `expense_status` SET TAGS ('dbx_value_regex' = 'accrued|invoiced|approved|paid|disputed|waived');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `expense_type` SET TAGS ('dbx_business_glossary_term' = 'Expense Type');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `gross_expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Expense Amount');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `incurred_date` SET TAGS ('dbx_business_glossary_term' = 'Expense Incurred Date');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `invoice_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Date');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Invoice Number');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `lpa_reference_clause` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reference Clause');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `net_expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Expense Amount');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `non_reimbursable_amount` SET TAGS ('dbx_business_glossary_term' = 'Non-Reimbursable Amount');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|ach|check|electronic_funds_transfer');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `reimbursable_amount` SET TAGS ('dbx_business_glossary_term' = 'Reimbursable Amount');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `service_description` SET TAGS ('dbx_business_glossary_term' = 'Service Description');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `service_provider_name` SET TAGS ('dbx_business_glossary_term' = 'Service Provider Name');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `waiver_flag` SET TAGS ('dbx_business_glossary_term' = 'Waiver Flag');
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason');
ALTER TABLE `asset_management`.`fee`.`placement_fee` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`fee`.`placement_fee` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`placement_fee` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`placement_fee` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `placement_fee_id` SET TAGS ('dbx_business_glossary_term' = 'Placement Fee Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Investor Entity Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Placement Agent Entity Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `allocation_method` SET TAGS ('dbx_business_glossary_term' = 'Allocation Method');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `allocation_method` SET TAGS ('dbx_value_regex' = 'pro_rata|investor_specific|fund_level|class_level');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `capital_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Capital Commitment Amount');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `capitalized_flag` SET TAGS ('dbx_business_glossary_term' = 'Capitalized Flag');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `commitment_date` SET TAGS ('dbx_business_glossary_term' = 'Commitment Date');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Flag');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `dispute_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Date');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Due Date');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `fee_accrual_date` SET TAGS ('dbx_business_glossary_term' = 'Fee Accrual Date');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `fee_basis_percentage` SET TAGS ('dbx_business_glossary_term' = 'Fee Basis Percentage');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `fee_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Fee Reference Number');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `fee_status` SET TAGS ('dbx_business_glossary_term' = 'Fee Status');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `fee_status` SET TAGS ('dbx_value_regex' = 'pending|approved|paid|disputed|waived|cancelled');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `fee_transparency_disclosure_flag` SET TAGS ('dbx_business_glossary_term' = 'Fee Transparency Disclosure Flag');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `fee_type` SET TAGS ('dbx_business_glossary_term' = 'Fee Type');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `fee_type` SET TAGS ('dbx_value_regex' = 'upfront|trailing|success|retainer|hybrid');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `gross_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Fee Amount');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `ic_approval_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Flag');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `invoice_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Date');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Invoice Number');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `lpa_reference_clause` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reference Clause');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `net_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Fee Amount');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|ach|check|offset');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `placement_agreement_reference` SET TAGS ('dbx_business_glossary_term' = 'Placement Agreement Reference');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `retrocession_amount` SET TAGS ('dbx_business_glossary_term' = 'Retrocession Amount');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `retrocession_arrangement_flag` SET TAGS ('dbx_business_glossary_term' = 'Retrocession Arrangement Flag');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `retrocession_percentage` SET TAGS ('dbx_business_glossary_term' = 'Retrocession Percentage');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `waiver_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Waiver Approval Date');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `waiver_flag` SET TAGS ('dbx_business_glossary_term' = 'Waiver Flag');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Waiver Reason');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Amount');
ALTER TABLE `asset_management`.`fee`.`placement_fee` ALTER COLUMN `withholding_tax_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`transparency_report` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`fee`.`transparency_report` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`transparency_report` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`transparency_report` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `transparency_report_id` SET TAGS ('dbx_business_glossary_term' = 'Transparency Report Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Gp Profile Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `prepared_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Prepared By User Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `prepared_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `prepared_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `regulatory_filing_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `transparency_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `transparency_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `transparency_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `transparency_prepared_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Prepared By User Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `transparency_prepared_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `transparency_prepared_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `valuation_cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Cycle Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Report Approval Date');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `auditor_verification_date` SET TAGS ('dbx_business_glossary_term' = 'Auditor Verification Date');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `auditor_verified_flag` SET TAGS ('dbx_business_glossary_term' = 'Auditor Verified Flag');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `average_aum_amount` SET TAGS ('dbx_business_glossary_term' = 'Average Assets Under Management (AUM) Amount');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `benchmark_comparison_flag` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Comparison Flag');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `credit_fees_amount` SET TAGS ('dbx_business_glossary_term' = 'Credit and Fixed Income Fees Amount');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `distribution_channel` SET TAGS ('dbx_business_glossary_term' = 'Distribution Channel');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `distribution_channel` SET TAGS ('dbx_value_regex' = 'beneficiary_portal|regulatory_filing|board_package|public_website|investor_letter');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `executive_summary` SET TAGS ('dbx_business_glossary_term' = 'Executive Summary');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `gips_compliant_flag` SET TAGS ('dbx_business_glossary_term' = 'Global Investment Performance Standards (GIPS) Compliant Flag');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `infrastructure_fees_amount` SET TAGS ('dbx_business_glossary_term' = 'Infrastructure Fees Amount');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `natural_resources_fees_amount` SET TAGS ('dbx_business_glossary_term' = 'Natural Resources Fees Amount');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `peer_median_fee_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Peer Median Fee Rate in Basis Points (bps)');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `preparation_date` SET TAGS ('dbx_business_glossary_term' = 'Report Preparation Date');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `private_equity_fees_amount` SET TAGS ('dbx_business_glossary_term' = 'Private Equity Fees Amount');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `public_equities_fees_amount` SET TAGS ('dbx_business_glossary_term' = 'Public Equities Fees Amount');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `publication_date` SET TAGS ('dbx_business_glossary_term' = 'Report Publication Date');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `real_estate_fees_amount` SET TAGS ('dbx_business_glossary_term' = 'Real Estate Fees Amount');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `recipient_category` SET TAGS ('dbx_business_glossary_term' = 'Recipient Category');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `recipient_category` SET TAGS ('dbx_value_regex' = 'beneficiaries|regulators|board|investment_committee|public');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `regulatory_filing_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Flag');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `report_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Report Reference Number');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `report_status` SET TAGS ('dbx_business_glossary_term' = 'Report Status');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `report_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|published|archived');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `report_type` SET TAGS ('dbx_business_glossary_term' = 'Report Type');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `report_type` SET TAGS ('dbx_value_regex' = 'annual|quarterly|semi_annual|ad_hoc');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `total_carried_interest_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Carried Interest Paid Amount');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `total_custody_fees_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Custody Fees Paid Amount');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `total_fee_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Total Fee Rate in Basis Points (bps)');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `total_fees_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Fees Paid Amount');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `total_management_fees_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Management Fees Paid Amount');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `total_other_fees_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Other Fees Paid Amount');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `total_performance_fees_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Performance Fees Paid Amount');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `total_placement_fees_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Placement Fees Paid Amount');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `total_transaction_fees_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Transaction Fees Paid Amount');
ALTER TABLE `asset_management`.`fee`.`transparency_report` ALTER COLUMN `variance_to_peer_median_bps` SET TAGS ('dbx_business_glossary_term' = 'Variance to Peer Median in Basis Points (bps)');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `incentive_fee_id` SET TAGS ('dbx_business_glossary_term' = 'Incentive Fee Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `external_manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate Identifier (ID)');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `payment_cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `performance_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Performance Benchmark Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `arrangement_name` SET TAGS ('dbx_business_glossary_term' = 'Arrangement Name');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `arrangement_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Arrangement Reference Number');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `arrangement_status` SET TAGS ('dbx_business_glossary_term' = 'Arrangement Status');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `arrangement_status` SET TAGS ('dbx_value_regex' = 'active|suspended|terminated|pending|draft');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `benchmark_reference` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Reference');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Calculation Frequency');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_value_regex' = 'daily|monthly|quarterly|semi_annually|annually');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `clawback_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Flag');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `crystallization_frequency` SET TAGS ('dbx_business_glossary_term' = 'Crystallization Frequency');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `crystallization_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annually|annually|at_redemption');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `cumulative_incentive_fee_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Incentive Fee Paid Amount');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `equalization_method` SET TAGS ('dbx_business_glossary_term' = 'Equalization Method');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `equalization_method` SET TAGS ('dbx_value_regex' = 'series_accounting|full_equalization|no_equalization');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `fee_cap_percent` SET TAGS ('dbx_business_glossary_term' = 'Fee Cap Percentage');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `fee_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Fee Currency Code');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `fee_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `fee_transparency_disclosure_flag` SET TAGS ('dbx_business_glossary_term' = 'Fee Transparency Disclosure Flag');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `fee_type` SET TAGS ('dbx_business_glossary_term' = 'Fee Type');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `fee_type` SET TAGS ('dbx_value_regex' = 'performance_fee|incentive_fee|fulcrum_fee|asymmetric_fee');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `fulcrum_fee_adjustment_flag` SET TAGS ('dbx_business_glossary_term' = 'Fulcrum Fee Adjustment Flag');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `high_water_mark_amount` SET TAGS ('dbx_business_glossary_term' = 'High Water Mark Amount');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `high_water_mark_flag` SET TAGS ('dbx_business_glossary_term' = 'High Water Mark Flag');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `hurdle_type` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Type');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `hurdle_type` SET TAGS ('dbx_value_regex' = 'hard|soft|blended');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `ima_reference_section` SET TAGS ('dbx_business_glossary_term' = 'Investment Management Agreement (IMA) Reference Section');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `last_calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Calculation Date');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `last_crystallization_date` SET TAGS ('dbx_business_glossary_term' = 'Last Crystallization Date');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `loss_carryforward_flag` SET TAGS ('dbx_business_glossary_term' = 'Loss Carryforward Flag');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `maximum_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Fee Amount');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `minimum_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Fee Amount');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `most_favored_nation_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Most Favored Nation (MFN) Clause Flag');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `payment_timing` SET TAGS ('dbx_business_glossary_term' = 'Payment Timing');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `payment_timing` SET TAGS ('dbx_value_regex' = 'in_arrears|in_advance|at_crystallization');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `performance_measurement_basis` SET TAGS ('dbx_business_glossary_term' = 'Performance Measurement Basis');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `performance_measurement_basis` SET TAGS ('dbx_value_regex' = 'time_weighted_return|money_weighted_return|absolute_return|relative_return');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Incentive Fee Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `regulatory_reporting_category` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Category');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `side_letter_flag` SET TAGS ('dbx_business_glossary_term' = 'Side Letter Flag');
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ALTER COLUMN `termination_notice_period_days` SET TAGS ('dbx_business_glossary_term' = 'Termination Notice Period Days');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` SET TAGS ('dbx_domain' = 'fee');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` SET TAGS ('dbx_subdomain' = 'fee_processing');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `high_water_mark_id` SET TAGS ('dbx_business_glossary_term' = 'High Water Mark (HWM) Identifier');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `external_manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager Identifier');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager Identifier');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate Identifier');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `performance_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Performance Benchmark Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `valuation_nav_record_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Nav Record Id (Foreign Key)');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `auditor_verified_flag` SET TAGS ('dbx_business_glossary_term' = 'Auditor Verified Flag');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Calculation Methodology');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `clawback_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Flag');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `clawback_reserve_percentage` SET TAGS ('dbx_business_glossary_term' = 'Clawback Reserve Percentage');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `crystallization_frequency` SET TAGS ('dbx_business_glossary_term' = 'Crystallization Frequency');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `crystallization_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi-annually|annually|at_redemption');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `cumulative_performance_fee_accrued_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Performance Fee Accrued Amount');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `cumulative_performance_fee_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Performance Fee Paid Amount');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `cumulative_underperformance_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Underperformance Amount');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `current_hwm_nav` SET TAGS ('dbx_business_glossary_term' = 'Current High Water Mark (HWM) Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `equalization_method` SET TAGS ('dbx_business_glossary_term' = 'Equalization Method');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `equalization_method` SET TAGS ('dbx_value_regex' = 'series|full|none');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `hurdle_type` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Type');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `hurdle_type` SET TAGS ('dbx_value_regex' = 'hard|soft|none');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `hwm_currency_code` SET TAGS ('dbx_business_glossary_term' = 'High Water Mark (HWM) Currency Code');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `hwm_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `hwm_establishment_date` SET TAGS ('dbx_business_glossary_term' = 'High Water Mark (HWM) Establishment Date');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `hwm_exceeded_flag` SET TAGS ('dbx_business_glossary_term' = 'High Water Mark (HWM) Exceeded Flag');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `hwm_reference_number` SET TAGS ('dbx_business_glossary_term' = 'High Water Mark (HWM) Reference Number');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `hwm_reset_date` SET TAGS ('dbx_business_glossary_term' = 'High Water Mark (HWM) Reset Date');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `hwm_status` SET TAGS ('dbx_business_glossary_term' = 'High Water Mark (HWM) Status');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `hwm_status` SET TAGS ('dbx_value_regex' = 'active|suspended|reset|terminated|pending');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `hwm_type` SET TAGS ('dbx_business_glossary_term' = 'High Water Mark (HWM) Type');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `hwm_type` SET TAGS ('dbx_value_regex' = 'hard|soft|rolling|crystallized');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `initial_hwm_nav` SET TAGS ('dbx_business_glossary_term' = 'Initial High Water Mark (HWM) Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `last_audit_date` SET TAGS ('dbx_business_glossary_term' = 'Last Audit Date');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `last_calculation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Calculation Date');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `last_crystallization_date` SET TAGS ('dbx_business_glossary_term' = 'Last Crystallization Date');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `lookback_period_months` SET TAGS ('dbx_business_glossary_term' = 'Lookback Period Months');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `loss_carryforward_flag` SET TAGS ('dbx_business_glossary_term' = 'Loss Carryforward Flag');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `lpa_reference_clause` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reference Clause');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `most_favored_nation_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Most Favored Nation (MFN) Clause Flag');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `nav_basis` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Basis');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `nav_basis` SET TAGS ('dbx_value_regex' = 'gross|net|adjusted');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `next_crystallization_date` SET TAGS ('dbx_business_glossary_term' = 'Next Crystallization Date');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `performance_fee_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Performance Fee Rate Percentage');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `previous_hwm_nav` SET TAGS ('dbx_business_glossary_term' = 'Previous High Water Mark (HWM) Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `reset_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reset Frequency');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `reset_frequency` SET TAGS ('dbx_value_regex' = 'never|annually|on_recovery|on_event');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `reset_trigger_condition` SET TAGS ('dbx_business_glossary_term' = 'Reset Trigger Condition');
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ALTER COLUMN `side_letter_flag` SET TAGS ('dbx_business_glossary_term' = 'Side Letter Flag');
