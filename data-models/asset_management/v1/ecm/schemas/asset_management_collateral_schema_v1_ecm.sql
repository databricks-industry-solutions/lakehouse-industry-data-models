-- Schema for Domain: collateral | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:24

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`collateral` COMMENT 'Domain for collateral management and counterparty credit risk operations. Owns ISDA/CSA agreement records, margin call processing, collateral eligibility schedules, counterparty exposure tracking, LEI/BIC registry, credit limits, CCP clearing records, and';
ALTER SCHEMA `asset_management`.`collateral` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `asset_management`.`collateral` SET TAGS ('dbx_domain' = 'collateral');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`collateral`.`counterparty` (
    `counterparty_id` BIGINT COMMENT 'Unique system-generated identifier for the counterparty.',
    `actor_id` BIGINT COMMENT 'Foreign key linking to shared.actor. Business justification: Counterparties (banks, asset managers, CCPs) must link to unified actor registry for KYC/AML compliance, regulatory reporting (EMIR), and consolidated entity management.',
    `bic` STRING COMMENT 'ISO 9362 BIC for the counterpartys primary banking relationship.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `blacklist_reason` STRING COMMENT 'Reason for blacklisting the counterparty, if applicable.',
    `classification` STRING COMMENT 'Business classification indicating internal, external, or affiliated relationship.. Valid values are `internal|external|affiliated`',
    `collateral_eligible_flag` BOOLEAN COMMENT 'Indicates whether the counterparty is eligible to post collateral under firm policy.',
    `comments` STRING COMMENT 'Free-text field for additional notes or remarks about the counterparty.',
    `counterparty_status` STRING COMMENT 'Current operational status of the counterparty.. Valid values are `active|inactive|suspended|terminated|pending`',
    `country_of_incorporation` STRING COMMENT 'Country where the counterparty is legally incorporated. [ENUM-REF-CANDIDATE: USA|CAN|GBR|FRA|DEU|JPN|AUS|CHN|... — promote to reference product]',
    `credit_limit` DECIMAL(20,2) COMMENT 'Maximum credit exposure approved for the counterparty.',
    `default_probability` DECIMAL(5,4) COMMENT 'One-year probability of default as assessed by internal risk models.',
    `entity_type` STRING COMMENT 'Category of the counterparty based on its role in the financial ecosystem.. Valid values are `bank|broker|custodian|ccp|fund_manager|other`',
    `esg_score` DECIMAL(5,2) COMMENT 'Aggregated Environmental, Social, and Governance score assigned to the counterparty.',
    `exposure_limit` DECIMAL(20,2) COMMENT 'Maximum aggregate exposure allowed for the counterparty across all trades.',
    `is_blacklisted` BOOLEAN COMMENT 'Indicates whether the counterparty is on the internal blacklist.',
    `is_central_counterparty` BOOLEAN COMMENT 'True if the counterparty functions as a Central Counterparty.',
    `is_clearing_member` BOOLEAN COMMENT 'True if the counterparty is a clearing member of a CCP.',
    `jurisdiction` STRING COMMENT 'Legal jurisdiction under which the counterparty is organized.',
    `last_rating_date` DATE COMMENT 'Date of the most recent risk rating assignment.',
    `lei` STRING COMMENT 'Global legal entity identifier assigned to the counterparty.. Valid values are `^[A-Z0-9]{20}$`',
    `lifecycle_status` STRING COMMENT 'Lifecycle stage of the counterparty record within the data system.. Valid values are `onboarding|active|closed|terminated`',
    `margin_call_threshold` DECIMAL(5,2) COMMENT 'Exposure percentage at which a margin call is triggered.',
    `counterparty_name` STRING COMMENT 'Full legal name of the counterparty entity.',
    `onboarding_date` DATE COMMENT 'Date when the counterparty was first onboarded into the system.',
    `primary_contact_address` STRING COMMENT 'Mailing address for the primary contact of the counterparty.',
    `primary_contact_email` STRING COMMENT 'Email address of the primary contact person.. Valid values are `^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,}$`',
    `primary_contact_name` STRING COMMENT 'Full name of the primary contact person for the counterparty.',
    `primary_contact_phone` STRING COMMENT 'Phone number of the primary contact person.. Valid values are `^+?[0-9]{7,15}$`',
    `rating_agency` STRING COMMENT 'Name of the external agency providing the risk rating.',
    `record_audit_created` TIMESTAMP COMMENT 'Timestamp when the counterparty record was initially created in the data lake.',
    `record_audit_updated` TIMESTAMP COMMENT 'Timestamp of the most recent update to the counterparty record.',
    `recovery_rate` DECIMAL(5,2) COMMENT 'Estimated recovery rate in the event of counterparty default.',
    `registration_number` STRING COMMENT 'Official registration number of the counterparty in its jurisdiction of incorporation.. Valid values are `^[A-Z0-9-]+$`',
    `regulatory_status` STRING COMMENT 'Regulatory classification of the counterparty under applicable frameworks.. Valid values are `regulated|unregulated|exempt`',
    `risk_rating` STRING COMMENT 'External credit risk rating of the counterparty. [ENUM-REF-CANDIDATE: AAA|AA|A|BBB|BB|B|CCC|CC|C|D — promote to reference product]',
    `settlement_currency` STRING COMMENT 'Default currency used for settlement with the counterparty.. Valid values are `USD|CAD|EUR|GBP|JPY|CHF`',
    `settlement_cycle` STRING COMMENT 'Standard settlement period for trades with the counterparty.. Valid values are `T+0|T+1|T+2|T+3`',
    `short_name` STRING COMMENT 'Commonly used short name or ticker for the counterparty.',
    `tax_identifier` STRING COMMENT 'Tax identification number of the counterparty for jurisdictional tax reporting.. Valid values are `^[A-Z0-9]{8,15}$`',
    `termination_date` DATE COMMENT 'Date when the relationship with the counterparty was terminated, if applicable.',
    CONSTRAINT pk_counterparty PRIMARY KEY(`counterparty_id`)
) COMMENT 'Master record for each counterparty entity in the pension funds collateral and OTC derivatives ecosystem, including banks, broker-dealers, CCPs, and custodians.';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`isda_master` (
    `isda_master_id` BIGINT COMMENT 'Unique system-generated identifier for the ISDA Master Agreement record.',
    `counterparty_id` BIGINT COMMENT 'FK to collateral.counterparty',
    `agreement_number` STRING COMMENT 'External reference number or code assigned to the ISDA Master Agreement.. Valid values are `^[A-Z0-9-]+$`',
    `agreement_type` STRING COMMENT 'Indicates whether the agreement follows the 1992 or 2002 ISDA Master Agreement version.. Valid values are `1992|2002`',
    `amendment_count` BIGINT COMMENT 'Total number of amendments applied to the agreement.',
    `amendment_indicator` BOOLEAN COMMENT 'True if the agreement has been amended since original execution.',
    `close_out_netting_provision` STRING COMMENT 'Text describing the close‑out netting rules applicable to the agreement.',
    `collateral_eligibility` STRING COMMENT 'Indicates whether the agreement permits collateral posting and its scope.. Valid values are `eligible|ineligible|partial`',
    `comments` STRING COMMENT 'Free‑form notes or remarks about the agreement.',
    `confidentiality_classification` STRING COMMENT 'Data classification level applied to the agreement record.. Valid values are `restricted|confidential|internal|public`',
    `counterparty_bic` STRING COMMENT 'BIC of the counterpartys primary banking relationship.. Valid values are `^[A-Z0-9]{8,11}$`',
    `counterparty_lei` STRING COMMENT 'Global identifier for the counterparty as defined by ISO 17442.. Valid values are `^[A-Z0-9]{20}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the ISDA Master Agreement record was first created in the system.',
    `credit_support_annex_reference` STRING COMMENT 'Identifier of the associated Credit Support Annex governing collateral terms.',
    `default_provision` STRING COMMENT 'Text of the provision outlining events of default and remedies.',
    `dispute_resolution_mechanism` STRING COMMENT 'Mechanism (e.g., arbitration, court) for resolving disputes under the agreement.',
    `document_reference` STRING COMMENT 'Path or identifier for the stored electronic copy of the agreement.',
    `early_termination_rights` STRING COMMENT 'Description of any rights allowing early termination of the agreement.',
    `effective_from` DATE COMMENT 'Date on which the agreement becomes legally binding.',
    `effective_until` DATE COMMENT 'Date on which the agreement terminates or expires; null for open‑ended agreements.',
    `execution_date` DATE COMMENT 'Date the parties signed the ISDA Master Agreement.',
    `governing_law_jurisdiction` STRING COMMENT 'Legal jurisdiction whose law governs the agreement.',
    `isda_master_status` STRING COMMENT 'Current lifecycle state of the ISDA Master Agreement.. Valid values are `active|terminated|suspended|draft|pending`',
    `jurisdiction_code` STRING COMMENT 'Three‑letter ISO country code representing the governing jurisdiction.. Valid values are `^[A-Z]{3}$`',
    `last_amendment_date` DATE COMMENT 'Date of the most recent amendment to the agreement.',
    `margin_call_frequency` STRING COMMENT 'How often margin calls are required under the agreement.. Valid values are `daily|weekly|monthly|ad_hoc`',
    `margin_currency` STRING COMMENT 'ISO 4217 currency code for the margin threshold amount.. Valid values are `^[A-Z]{3}$`',
    `margin_threshold_amount` DECIMAL(18,2) COMMENT 'Monetary threshold that triggers a margin call under the agreement.',
    `netting_agreement_type` STRING COMMENT 'Specifies whether the agreement provides full, partial, or no netting of exposures.. Valid values are `full|partial|none`',
    `regulatory_body` STRING COMMENT 'Regulatory authority overseeing compliance of the agreement. [ENUM-REF-CANDIDATE: SEC|FCA|ESMA|IOSCO|CFA|PRI|TCFD|SFDR|IFRS|FASB|FATF|ISDA|FSB|Basel|Local|ISO27001|SOC2|GDPR|MiFIDII — promote to reference product]',
    `regulatory_reporting_requirement` STRING COMMENT 'Regulatory regime(s) that the agreement must satisfy for reporting.. Valid values are `EMIR|Dodd-Frank|MiFIDII|Other`',
    `termination_event_clauses` STRING COMMENT 'Key clauses that define events triggering termination of the agreement.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the ISDA Master Agreement record.',
    `version_number` BIGINT COMMENT 'Sequential version of the agreement reflecting amendments or restatements.',
    CONSTRAINT pk_isda_master PRIMARY KEY(`isda_master_id`)
) COMMENT 'Master record for each ISDA Master Agreement executed between the pension fund and a counterparty. Captures agreement version (1992 or 2002 ISDA), execution date, governing law jurisdiction, default provisions, termination event clauses, close-out netting';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`csa` (
    `csa_id` BIGINT COMMENT 'System-generated unique identifier for the CSA record.',
    `counterparty_id` BIGINT COMMENT 'Unique identifier of the counterparty party to the CSA.',
    `isda_master_id` BIGINT COMMENT 'Foreign key linking to collateral.isda_master. Business justification: CSA (Credit Support Annex) is ALWAYS attached to an ISDA Master Agreement - this is fundamental to OTC derivatives documentation. Every CSA must reference its parent ISDA Master.',
    `netting_agreement_id` BIGINT COMMENT 'Identifier of the netting agreement linked to this CSA, if any.',
    `valuation_policy_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_policy. Business justification: CSAs specify collateral valuation methods that must align with internal valuation policies.',
    `amendment_date` DATE COMMENT 'Date on which the latest amendment was executed.',
    `amendment_number` BIGINT COMMENT 'Sequential number of the most recent amendment to the CSA.',
    `collateral_valuation_frequency` STRING COMMENT 'How often collateral valuations are refreshed.. Valid values are `daily|weekly|monthly`',
    `collateral_valuation_method` STRING COMMENT 'Method used to value posted collateral.. Valid values are `mark_to_market|mark_to_model|price_source`',
    `collateral_valuation_source` STRING COMMENT 'Origin of the data used for collateral valuation.. Valid values are `internal|external|third_party`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the CSA record was first created in the system.',
    `credit_limit` DECIMAL(20,2) COMMENT 'Maximum credit exposure allowed under the CSA.',
    `credit_limit_currency` STRING COMMENT 'ISO 4217 currency code for the credit limit.. Valid values are `^[A-Z]{3}$`',
    `csa_status` STRING COMMENT 'Current lifecycle state of the CSA agreement.. Valid values are `draft|active|suspended|terminated|expired`',
    `csa_type` STRING COMMENT 'Classification of the CSA based on governing law or ISDA version.. Valid values are `english_law|new_york_law|isda_2016_vm`',
    `csa_description` STRING COMMENT 'Free‑text description of the CSA, including any special provisions.',
    `effective_from` DATE COMMENT 'Date on which the CSA becomes legally binding.',
    `effective_until` DATE COMMENT 'Date on which the CSA expires or is terminated; null for open‑ended agreements.',
    `eligible_collateral_type` STRING COMMENT 'Asset class(s) permitted as collateral under the CSA.. Valid values are `cash|government_bonds|equity|real_estate|commodities|other`',
    `governing_law` STRING COMMENT 'Legal jurisdiction governing the CSA.. Valid values are `english|new_york|isda`',
    `independent_amount` DECIMAL(20,2) COMMENT 'Collateral amount that must be posted irrespective of exposure.',
    `independent_amount_currency` STRING COMMENT 'ISO 4217 currency code for the independent amount.. Valid values are `^[A-Z]{3}$`',
    `is_eligible_for_clearing` BOOLEAN COMMENT 'True if the CSA permits clearing through a CCP; false otherwise.',
    `is_margin_call_required` BOOLEAN COMMENT 'Indicates whether the CSA mandates margin calls (true) or not (false).',
    `margin_call_frequency` STRING COMMENT 'How often margin calls are calculated and issued.. Valid values are `daily|weekly|monthly|quarterly`',
    `minimum_transfer_amount` DECIMAL(20,2) COMMENT 'Minimum amount of collateral that must be transferred in a margin call.',
    `minimum_transfer_currency` STRING COMMENT 'ISO 4217 currency code for the minimum transfer amount.. Valid values are `^[A-Z]{3}$`',
    `number` STRING COMMENT 'External reference number or code assigned to the CSA by the firm or regulator.',
    `threshold_amount` DECIMAL(20,2) COMMENT 'Monetary amount that triggers a margin call under the CSA.',
    `threshold_currency` STRING COMMENT 'ISO 4217 currency code for the threshold amount.. Valid values are `^[A-Z]{3}$`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the CSA record.',
    `valuation_currency` STRING COMMENT 'Currency in which collateral valuations are expressed.. Valid values are `^[A-Z]{3}$`',
    CONSTRAINT pk_csa PRIMARY KEY(`csa_id`)
) COMMENT 'Master record for each Credit Support Annex (CSA) attached to an ISDA Master Agreement. Stores CSA type (English Law, New York Law, ISDA 2016 VM CSA), threshold amounts, minimum transfer amounts (MTA), independent amounts (IA), eligible collateral';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`netting_agreement` (
    `netting_agreement_id` BIGINT COMMENT 'Unique system-generated identifier for the netting agreement record.',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: Netting agreements are bilateral contracts between the pension fund and a specific counterparty.',
    `agreement_classification` STRING COMMENT 'Indicates whether the netting arrangement is bilateral (between two parties) or multilateral (involving multiple parties).. Valid values are `bilateral|multilateral`',
    `agreement_number` STRING COMMENT 'External business identifier or reference number assigned to the netting agreement.',
    `amendment_date` DATE COMMENT 'Date on which the latest amendment to the agreement was executed.',
    `amendment_number` BIGINT COMMENT 'Sequential number of the most recent amendment to the agreement.',
    `collateral_eligibility_criteria` STRING COMMENT 'Business rules defining which assets qualify as eligible collateral under the agreement.',
    `collateral_type` STRING COMMENT 'Primary form of collateral accepted (cash, securities, or both).. Valid values are `cash|securities|both`',
    `comments` STRING COMMENT 'Free‑form field for any supplemental notes or remarks about the agreement.',
    `created_timestamp` TIMESTAMP COMMENT 'Date‑time when the netting agreement record was first created in the system.',
    `credit_limit` DECIMAL(20,2) COMMENT 'Maximum credit exposure permitted for the counterparty under the netting arrangement.',
    `currency_code` STRING COMMENT 'ISO 4217 three‑letter code of the currency used for the threshold amount.. Valid values are `^[A-Z]{3}$`',
    `netting_agreement_description` STRING COMMENT 'Free‑form textual description of the netting agreement purpose and key terms.',
    `effective_from` DATE COMMENT 'Date on which the netting agreement becomes legally binding.',
    `effective_until` DATE COMMENT 'Date on which the netting agreement terminates or expires; null for open‑ended agreements.',
    `governing_law` STRING COMMENT 'Jurisdiction whose law governs the interpretation and enforcement of the agreement.',
    `last_review_date` DATE COMMENT 'Date when the agreement was last reviewed for compliance or operational relevance.',
    `margin_call_frequency` STRING COMMENT 'How often margin calls are calculated and communicated under the agreement.. Valid values are `daily|weekly|monthly|ad_hoc`',
    `netting_agreement_status` STRING COMMENT 'Current lifecycle status of the netting agreement.. Valid values are `active|inactive|suspended|terminated|draft`',
    `netting_type` STRING COMMENT 'Specifies the type of netting covered by the agreement: close‑out, payment, or novation.. Valid values are `close_out|payment|novation`',
    `product_scope` STRING COMMENT 'Asset classes covered by the netting agreement.. Valid values are `rates|fx|credit|equity|all`',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether the agreement is subject to EMIR reporting obligations.',
    `risk_weight` DECIMAL(5,2) COMMENT 'Regulatory risk‑weight percentage applied to the netted exposure.',
    `settlement_cycle` STRING COMMENT 'Standard settlement convention applied to transactions covered by the agreement.. Valid values are `T+2|DVP|T+1|same_day`',
    `threshold_amount` DECIMAL(20,2) COMMENT 'Monetary amount of collateral that must be posted before netting is applied.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date‑time of the most recent modification to the netting agreement record.',
    `valuation_method` STRING COMMENT 'Method used to value eligible collateral (e.g., market price, model‑based).',
    CONSTRAINT pk_netting_agreement PRIMARY KEY(`netting_agreement_id`)
) COMMENT 'Master record for each bilateral netting agreement (close-out netting or payment netting) executed with a counterparty. Captures netting type (close-out, payment, novation), governing law, effective date, product scope (rates, FX, credit, equity';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`eligibility_schedule` (
    `eligibility_schedule_id` BIGINT COMMENT 'Unique system-generated identifier for the collateral eligibility schedule.',
    `agreement_csa_id` BIGINT COMMENT 'Identifier of the CSA or CCP agreement to which this eligibility schedule applies.',
    `csa_id` BIGINT COMMENT 'Identifier of the CSA or CCP agreement to which this eligibility schedule applies.',
    `asset_class` STRING COMMENT 'Asset class that is eligible as collateral under this schedule.. Valid values are `government_bond|agency_bond|cash|equity|money_market_fund`',
    `collateral_category` STRING COMMENT 'High‑level category of the collateral (e.g., primary, secondary, liquidity, haircut).. Valid values are `primary|secondary|liquidity|haircut`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the eligibility schedule record was first created in the system.',
    `currency` STRING COMMENT 'Three‑letter ISO 4217 currency code for the eligible collateral.. Valid values are `^[A-Z]{3}$`',
    `eligibility_schedule_description` STRING COMMENT 'Free‑form description of the schedule, its purpose, and any special conditions.',
    `effective_from` DATE COMMENT 'Date on which the eligibility schedule becomes binding.',
    `effective_until` DATE COMMENT 'Date on which the eligibility schedule expires or is superseded; null if open‑ended.',
    `eligibility_criteria` STRING COMMENT 'Detailed textual rules defining eligibility beyond asset class and currency.',
    `eligibility_status` STRING COMMENT 'Current operational status of the eligibility schedule.. Valid values are `active|inactive|pending|retired`',
    `haircut_percentage` DECIMAL(5,2) COMMENT 'Percentage reduction applied to the market value of the collateral for risk weighting.',
    `is_marginable` BOOLEAN COMMENT 'Indicates whether the eligible asset can be used for margin purposes.',
    `last_review_date` DATE COMMENT 'Date when the eligibility schedule was last reviewed for compliance or market changes.',
    `max_balance` DECIMAL(18,2) COMMENT 'Maximum monetary amount of the eligible asset that can be posted under this schedule.',
    `min_balance` DECIMAL(18,2) COMMENT 'Minimum monetary amount of the eligible asset that must be posted as collateral.',
    `regulatory_reference` STRING COMMENT 'Reference to the specific EMIR or other regulatory clause governing the schedule.',
    `review_frequency` STRING COMMENT 'How often the schedule must be reviewed or re‑validated.. Valid values are `monthly|quarterly|annually`',
    `risk_weight` DECIMAL(5,4) COMMENT 'Risk weight assigned to the collateral class for capital adequacy calculations.',
    `schedule_name` STRING COMMENT 'Human‑readable name for the eligibility schedule used in reporting and governance.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the eligibility schedule record.',
    `version_number` BIGINT COMMENT 'Sequential version of the eligibility schedule for change management.',
    CONSTRAINT pk_eligibility_schedule PRIMARY KEY(`eligibility_schedule_id`)
) COMMENT 'Defines the collateral eligibility criteria and haircut schedules applicable under each CSA or CCP clearing membership. Stores eligible asset classes (government bonds, agency bonds, cash, equities, money market funds), currency eligibility, minimum';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`credit_limit` (
    `credit_limit_id` BIGINT COMMENT 'Unique surrogate key for the credit limit record.',
    `counterparty_id` BIGINT COMMENT 'Surrogate key referencing the counterparty to which the limit applies.',
    `approval_date` DATE COMMENT 'Date on which the credit limit was formally approved by the committee.',
    `approved_by` STRING COMMENT 'Name of the individual who signed off the credit limit approval.',
    `breach_action` STRING COMMENT 'Pre‑defined action to be taken when a breach occurs.. Valid values are `notify|reduce|close|escalate`',
    `breach_date` DATE COMMENT 'Date on which the credit limit breach was first identified.',
    `breach_threshold` DECIMAL(5,2) COMMENT 'Utilization percentage that constitutes a breach of the credit limit.',
    `collateral_eligible` BOOLEAN COMMENT 'True if the counterpartys exposures are eligible for collateral posting under EMIR.',
    `committee_name` STRING COMMENT 'Name of the Investment or Risk Committee that granted the limit.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the credit limit record was first created in the system.',
    `credit_limit_status` STRING COMMENT 'Current lifecycle status of the credit limit.. Valid values are `active|inactive|suspended|pending|closed`',
    `credit_rating` STRING COMMENT 'Credit rating from external agencies (e.g., S&P, Moodys) for the counterparty. [ENUM-REF-CANDIDATE: AAA|AA|A|BBB|BB|B|CCC|CC|C|D — promote to reference product]',
    `effective_from` DATE COMMENT 'Date when the credit limit becomes effective.',
    `effective_until` DATE COMMENT 'Date when the credit limit expires or is scheduled to be reviewed; null for open‑ended.',
    `emir_reporting_indicator` BOOLEAN COMMENT 'True when the limit is subject to EMIR reporting requirements.',
    `is_override` BOOLEAN COMMENT 'Indicates whether the limit has been manually overridden beyond standard rules.',
    `last_review_date` DATE COMMENT 'Date when the credit limit was last reviewed by risk governance.',
    `limit_amount` DECIMAL(20,2) COMMENT 'Maximum credit exposure approved for the counterparty, in the limit currency.',
    `limit_amount_usd` DECIMAL(20,2) COMMENT 'Approved limit converted to US dollars for reporting purposes.',
    `limit_category` STRING COMMENT 'High‑level grouping of the limit (e.g., counterparty, portfolio, group).. Valid values are `counterparty|portfolio|group`',
    `limit_change_reason` STRING COMMENT 'Narrative explanation for any amendment to the credit limit.',
    `limit_currency` STRING COMMENT 'Three‑letter ISO 4217 code of the currency in which the limit is expressed.. Valid values are `^[A-Z]{3}$`',
    `limit_identifier` STRING COMMENT 'Business identifier or code assigned to the credit limit.. Valid values are `^[A-Z0-9_-]{3,20}$`',
    `limit_revision_number` BIGINT COMMENT 'Sequential revision number tracking changes to the limit over time.',
    `limit_subtype` STRING COMMENT 'Optional finer classification of the limit within its category.',
    `limit_type` STRING COMMENT 'Classification of the limit based on its application scope.. Valid values are `pre_settlement|settlement|issuer|aggregate`',
    `margin_call_threshold` DECIMAL(5,2) COMMENT 'Utilization percentage that triggers a margin call under the agreement.',
    `next_review_date` DATE COMMENT 'Planned date for the next periodic review of the credit limit.',
    `override_reason` STRING COMMENT 'Justification provided for a manual override of the limit.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates if the limit must be reported under regulatory regimes (e.g., EMIR).',
    `risk_rating` STRING COMMENT 'Internal risk rating assigned to the limit exposure.. Valid values are `low|medium|high|critical`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the credit limit record.',
    `usage_amount` DECIMAL(20,2) COMMENT 'Current amount of credit already utilized against the approved limit.',
    `usage_percentage` DECIMAL(5,2) COMMENT 'Percentage of the approved limit that is currently utilized.',
    CONSTRAINT pk_credit_limit PRIMARY KEY(`credit_limit_id`)
) COMMENT 'Master record defining the approved counterparty credit exposure limits set by the Investment Committee or Risk Committee for each counterparty. Stores limit type (pre-settlement, settlement, issuer, aggregate), limit currency, approved limit amount';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`exposure` (
    `exposure_id` BIGINT COMMENT 'Unique identifier for the daily exposure record.',
    `counterparty_id` BIGINT COMMENT 'Identifier of the counterparty for which exposure is measured.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: Counterparty exposure stress testing under economic scenarios (base/adverse/severely adverse) is required for Basel III CVA capital, EMIR reporting, and internal risk limits.',
    `netting_agreement_id` BIGINT COMMENT 'Identifier of the netting set grouping related OTC derivatives.',
    `stress_scenario_id` BIGINT COMMENT 'Foreign key linking to risk.stress_scenario. Business justification: Regulatory stress testing (EMIR, Basel) requires stressed counterparty exposure calculations. Pension funds must report stressed exposures under defined scenarios.',
    `exposure_category` STRING COMMENT 'High‑level asset class category of the exposure.. Valid values are `derivative|securities|fx|commodity`',
    `collateral_held` DECIMAL(20,4) COMMENT 'Value of collateral posted against the exposure.',
    `collateral_usd` DECIMAL(20,4) COMMENT 'Collateral amount converted to US dollars.',
    `comments` STRING COMMENT 'Additional free‑form notes from analysts or operations.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the exposure record was first created.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code of the exposure amounts.',
    `cvar` DECIMAL(20,4) COMMENT 'Expected loss exceeding VaR, used for tail‑risk analysis.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Score (0‑100) indicating confidence in the exposure data quality.',
    `exposure_description` STRING COMMENT 'Free‑form description or notes about the exposure record.',
    `dv01` DECIMAL(20,4) COMMENT 'Sensitivity of the exposure to a one‑basis‑point shift in interest rates.',
    `effective_from` DATE COMMENT 'Start date of the exposures validity period.',
    `effective_until` DATE COMMENT 'End date of the exposures validity period (nullable).',
    `exposure_status` STRING COMMENT 'Current lifecycle status of the exposure record.. Valid values are `active|estimated|final|closed`',
    `exposure_type` STRING COMMENT 'Classification of the exposure measurement.. Valid values are `gross|net|collateralized|adjusted`',
    `gross_exposure_usd` DECIMAL(20,4) COMMENT 'Gross positive exposure converted to US dollars.',
    `gross_positive_exposure` DECIMAL(20,4) COMMENT 'Total positive mark‑to‑market exposure before netting.',
    `is_approximate` BOOLEAN COMMENT 'True if the exposure values are estimated rather than fully calculated.',
    `is_historical` BOOLEAN COMMENT 'True if the record represents a historical (non‑current) exposure.',
    `last_margin_call_amount` DECIMAL(20,4) COMMENT 'Amount of the most recent margin call.',
    `last_margin_call_date` DATE COMMENT 'Date of the most recent margin call associated with this exposure.',
    `margin_call_amount` DECIMAL(20,4) COMMENT 'Amount of additional collateral required by the margin call.',
    `margin_call_flag` BOOLEAN COMMENT 'Indicates whether a margin call was generated for the exposure.',
    `net_exposure` DECIMAL(20,4) COMMENT 'Exposure after applying netting agreements, before collateral.',
    `net_exposure_after_collateral` DECIMAL(20,4) COMMENT 'Net exposure after deducting posted collateral.',
    `net_exposure_usd` DECIMAL(20,4) COMMENT 'Net exposure converted to US dollars.',
    `netting_set_name` STRING COMMENT 'Human‑readable name of the netting set.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'True if the exposure is included in regulatory reporting (e.g., EMIR).',
    `reporting_period` STRING COMMENT 'Frequency at which the exposure is reported.. Valid values are `daily|weekly|monthly`',
    `risk_factor` STRING COMMENT 'Key risk factor identifier (e.g., interest rate, credit spread) driving the exposure.',
    `risk_weight` DECIMAL(5,2) COMMENT 'Regulatory risk weight applied to the exposure for capital calculations.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the exposure record.',
    `valuation_date` DATE COMMENT 'Date of the exposure valuation (yyyy-MM-dd).',
    `valuation_timestamp` TIMESTAMP COMMENT 'Exact timestamp when the exposure was calculated.',
    `var` DECIMAL(20,4) COMMENT 'Statistical risk measure representing potential loss at a confidence level.',
    `version` BIGINT COMMENT 'Version number for revisions of the same exposure snapshot.',
    CONSTRAINT pk_exposure PRIMARY KEY(`exposure_id`)
) COMMENT 'Daily counterparty exposure record capturing gross and net MTM exposure per counterparty across all OTC derivative netting sets. Stores valuation date, gross positive exposure (GPE), net exposure after netting, collateral held, net exposure after';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`margin_call` (
    `margin_call_id` BIGINT COMMENT 'System-generated unique identifier for each margin call record.',
    `collateral_account_id` BIGINT COMMENT 'Identifier of the account holding collateral pledged for the margin call.',
    `counterparty_id` BIGINT COMMENT 'Unique identifier of the counterparty to which the margin call relates.',
    `csa_id` BIGINT COMMENT 'Foreign key linking to collateral.csa. Business justification: Margin calls are governed by CSA terms including threshold amounts, minimum transfer amounts, and call frequency. Linking margin_call to csa enables retrieval of the governing agreement terms.',
    `party_counterparty_id` BIGINT COMMENT 'Unique identifier of the counterparty to which the margin call relates.',
    `processed_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Margin call processing requires audit trail of which employee processed/approved the call. Critical for operational risk controls, regulatory compliance, and segregation of duties in',
    `related_trade_blotter_id` BIGINT COMMENT 'Identifier of the trade that triggered the margin requirement.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_asset_valuation. Business justification: Margin calls are triggered by valuation changes. Pension funds must link margin call amounts to the specific asset valuation that triggered the call for regulatory',
    `adjustment_amount` DECIMAL(20,4) COMMENT 'Any positive or negative adjustment applied to the gross call amount.',
    `adjustment_reason` STRING COMMENT 'Free‑text description of why an adjustment was made to the margin call amount.',
    `call_amount` DECIMAL(20,4) COMMENT 'Total amount requested in the margin call before any adjustments, expressed in the call currency.',
    `call_batch_reference` BIGINT COMMENT 'Identifier of the batch grouping multiple margin calls generated together.',
    `call_currency` STRING COMMENT 'Three‑letter ISO 4217 code of the currency in which the margin call amount is denominated.',
    `call_date` TIMESTAMP COMMENT 'Date and time when the margin call was generated or received in the operational system.',
    `call_direction` STRING COMMENT 'Indicates whether the margin call was issued to a counterparty or received from a counterparty.. Valid values are `issued|received`',
    `call_number` STRING COMMENT 'External reference number assigned to the margin call by the front‑office system.',
    `call_processed_flag` BOOLEAN COMMENT 'True when the margin call has been fully processed and posted.',
    `call_sequence_number` BIGINT COMMENT 'Ordinal position of the margin call within its batch.',
    `collateral_amount` DECIMAL(20,4) COMMENT 'Monetary value of the collateral posted, expressed in the collateral currency.',
    `collateral_currency` STRING COMMENT 'ISO 4217 code of the currency in which collateral amount is denominated.',
    `collateral_type` STRING COMMENT 'Category of collateral posted against the margin call.. Valid values are `cash|securities|other`',
    `comments` STRING COMMENT 'Free‑form notes entered by operations or risk teams.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the margin call record was first created in the data lake.',
    `due_date` DATE COMMENT 'Deadline by which the counterparty must satisfy the margin call.',
    `exchange_rate` DECIMAL(12,6) COMMENT 'FX rate applied when converting between call currency and reporting currency.',
    `exchange_rate_date` DATE COMMENT 'Date on which the exchange rate was sourced.',
    `external_reference` STRING COMMENT 'Identifier of the margin call in an external system (e.g., Aladdin, SimCorp).',
    `interest_rate` DECIMAL(6,4) COMMENT 'Interest rate applied to the margin amount when the call is overdue, expressed as a decimal.',
    `interest_rate_type` STRING COMMENT 'Indicates whether the margin interest rate is fixed or floating.. Valid values are `fixed|floating`',
    `margin_call_status` STRING COMMENT 'Current processing state of the margin call within the workflow.. Valid values are `pending|processed|settled|failed|cancelled`',
    `margin_type` STRING COMMENT 'Specifies whether the call relates to variation margin (VM) or initial margin (IM).. Valid values are `VM|IM`',
    `net_amount` DECIMAL(20,4) COMMENT 'Final amount after adjustments (fees, interest) that the counterparty must pay.',
    `net_currency` STRING COMMENT 'Currency of the net amount payable.',
    `processed_by` STRING COMMENT 'Identifier of the user or system that processed the margin call.',
    `processed_timestamp` TIMESTAMP COMMENT 'Date and time when the margin call was processed (e.g., posted to accounting).',
    `regulatory_report_flag` BOOLEAN COMMENT 'True if the margin call must be reported under EMIR or similar regulations.',
    `regulatory_report_status` STRING COMMENT 'Current status of the regulatory report for this margin call.. Valid values are `not_reported|reported|error`',
    `settlement_date` DATE COMMENT 'Date on which the margin call amount is expected to be settled.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the margin call record.',
    `valuation_amount` DECIMAL(20,4) COMMENT 'Monetary value of the portfolio used in the margin calculation.',
    `valuation_currency` STRING COMMENT 'Currency in which the valuation amount is expressed.',
    `valuation_date` DATE COMMENT 'Date of the market valuation used to calculate the margin requirement.',
    `valuation_method` STRING COMMENT 'Methodology used to value the underlying positions for margin calculation.. Valid values are `mark_to_market|model_based|other`',
    `valuation_source` STRING COMMENT 'System or vendor providing the market data for valuation (e.g., Bloomberg, internal model).',
    CONSTRAINT pk_margin_call PRIMARY KEY(`margin_call_id`)
) COMMENT 'Transactional record of each margin call issued or received in the collateral management workflow. Captures call date, call direction (call issued / call received), margin type (VM — Variation Margin or IM — Initial Margin), call amount, call currency';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`margin_dispute` (
    `margin_dispute_id` BIGINT COMMENT 'Unique system-generated identifier for the margin dispute record.',
    `counterparty_id` BIGINT COMMENT 'Identifier of the counterparty (e.g., broker, clearing house) that raised or is subject to the dispute.',
    `margin_call_id` BIGINT COMMENT 'Identifier of the margin call that triggered the dispute.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_asset_valuation. Business justification: Margin disputes frequently arise from valuation disagreements. Linking disputes to the contested valuation record enables pension funds to track dispute resolution and',
    `comments` STRING COMMENT 'Optional free‑form comments captured by the disputing party.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the dispute record was first created in the system.',
    `dispute_date` TIMESTAMP COMMENT 'Timestamp when the margin dispute was initially raised by a party.',
    `dispute_initiator` STRING COMMENT 'Party that originated the dispute (either the counterparty or the fund).. Valid values are `counterparty|fund`',
    `dispute_number` STRING COMMENT 'Business-facing identifier assigned to the dispute, used in communications and reporting.',
    `dispute_reason` STRING COMMENT 'Root cause of the dispute, such as valuation mismatch, eligibility disagreement, or haircut issue.. Valid values are `valuation_difference|eligibility_disagreement|haircut_dispute|other`',
    `disputed_amount` DECIMAL(20,2) COMMENT 'Monetary amount that is being contested in the dispute.',
    `disputed_currency` STRING COMMENT 'Three‑letter ISO currency code of the disputed amount.',
    `eligibility_flag` BOOLEAN COMMENT 'Indicates whether the dispute relates to collateral eligibility (true) or not (false).',
    `haircut_dispute_flag` BOOLEAN COMMENT 'True if the dispute concerns the applied haircut on collateral.',
    `margin_dispute_status` STRING COMMENT 'Current lifecycle state of the dispute (e.g., open, resolved, closed, rejected).. Valid values are `open|resolved|closed|rejected`',
    `resolution_amount` DECIMAL(20,2) COMMENT 'Final monetary amount agreed upon after dispute resolution.',
    `resolution_currency` STRING COMMENT 'Currency code of the resolved amount.',
    `resolution_date` DATE COMMENT 'Date on which the dispute was formally resolved.',
    `resolution_notes` STRING COMMENT 'Free‑text notes describing the outcome and any agreed actions.',
    `resolution_status` STRING COMMENT 'Current status of the dispute resolution workflow.. Valid values are `pending|accepted|rejected|settled`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the dispute record.',
    `valuation_date` DATE COMMENT 'Date of the market valuation that is the basis of the dispute.',
    CONSTRAINT pk_margin_dispute PRIMARY KEY(`margin_dispute_id`)
) COMMENT 'Transactional record of each margin call dispute raised by either party. Captures dispute date, disputing party, disputed amount, dispute reason (valuation difference, eligibility disagreement, haircut dispute), resolution status (open, resolved';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`posting` (
    `posting_id` BIGINT COMMENT 'Unique system-generated identifier for the collateral posting record.',
    `collateral_position_id` BIGINT COMMENT 'Foreign key linking to collateral.collateral_position. Business justification: A collateral posting instruction affects a specific collateral position. When collateral is posted or returned, it updates the position inventory.',
    `counterparty_id` BIGINT COMMENT 'Identifier of the counterparty (e.g., clearing member, broker) involved in the posting.',
    `margin_call_id` BIGINT COMMENT 'Identifier of the margin call that triggered this posting.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_asset_valuation. Business justification: When collateral is posted, the asset_value must be supported by a formal valuation.',
    `asset_identifier` STRING COMMENT 'Unique market identifier of the posted asset (ISIN, CUSIP, or SEDOL).',
    `asset_quantity` DECIMAL(20,4) COMMENT 'Number of units of the posted asset (e.g., shares, bond face value).',
    `asset_type` STRING COMMENT 'Classification of the collateral asset being posted.. Valid values are `cash|government_bond|agency_bond|equity|other`',
    `asset_value` DECIMAL(20,4) COMMENT 'Market value of the posted asset at the time of posting, expressed in the posting currency.',
    `collateral_quality` STRING COMMENT 'Regulatory eligibility status of the posted collateral.. Valid values are `eligible|non_eligible|restricted`',
    `collateral_source` STRING COMMENT 'Origin of the collateral (e.g., cash pool, bond portfolio).. Valid values are `cash|bond|equity|derivative`',
    `comments` STRING COMMENT 'Free‑form notes entered by operations staff regarding the posting.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the posting record was first created in the data lake.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code of the posting amount.. Valid values are `USD|EUR|GBP|CAD|JPY|CHF`',
    `direction` STRING COMMENT 'Indicates whether collateral was posted to, received from, or returned to the counterparty.. Valid values are `posted|received|returned`',
    `exchange_rate` DECIMAL(12,6) COMMENT 'FX rate used when the posting currency differs from the funds base currency.',
    `gross_amount` DECIMAL(20,4) COMMENT 'Total amount of collateral posted before haircuts and adjustments.',
    `haircut_percentage` DECIMAL(5,2) COMMENT 'Risk haircut applied to the collateral value, expressed as a percent.',
    `internal_reference` STRING COMMENT 'Internal reference or memo number used for reconciliation across systems.',
    `net_amount` DECIMAL(20,4) COMMENT 'Collateral amount after applying haircuts and any adjustments.',
    `number` STRING COMMENT 'External reference number assigned to the posting by the front‑office or margin‑call system.',
    `posting_status` STRING COMMENT 'Current lifecycle state of the posting record.. Valid values are `pending|posted|settled|cancelled|returned`',
    `regulatory_reported` BOOLEAN COMMENT 'Indicates whether the posting has been reported to EMIR or other regulatory regimes.',
    `settlement_date` DATE COMMENT 'Date on which the posting is expected to settle or was settled.',
    `settlement_method` STRING COMMENT 'Mechanism used to settle the collateral posting.. Valid values are `DVP|FOP|RTGS|wire|clearing_house`',
    `timestamp` TIMESTAMP COMMENT 'Date‑time when the posting instruction was executed in the market.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the posting record.',
    `valuation_date` DATE COMMENT 'Date on which the asset value was determined for the posting.',
    `valuation_method` STRING COMMENT 'Methodology used to determine the assets market value for the posting.. Valid values are `market_price|model_price|independent_valuation`',
    CONSTRAINT pk_posting PRIMARY KEY(`posting_id`)
) COMMENT 'Transactional record of each collateral posting or return instruction executed to satisfy a margin call. Captures posting date, posting direction (posted / received / returned), asset type (cash, government bond, agency bond, equity), ISIN/CUSIP of posted';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`collateral_position` (
    `collateral_position_id` BIGINT COMMENT 'Unique system-generated identifier for the collateral position record.',
    `ccp_ccp_membership_id` BIGINT COMMENT 'Identifier of the clearing house (CCP) when collateral is posted to a CCP.',
    `ccp_membership_id` BIGINT COMMENT 'Identifier of the clearing house (CCP) when collateral is posted to a CCP.',
    `counterparty_id` BIGINT COMMENT 'Identifier of the counterparty or client to which the collateral is held or pledged.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_asset_valuation. Business justification: Collateral positions require independent valuations for margin adequacy.',
    `asset_cusip` STRING COMMENT 'North American security identifier for the collateral asset, when applicable.. Valid values are `^[0-9A-Z]{9}$`',
    `asset_isin` STRING COMMENT 'Standardized 12‑character identifier for the underlying security used as collateral.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `asset_type` STRING COMMENT 'Classification of the collateral asset (cash, security, repo, derivative).. Valid values are `cash|security|repo|derivative`',
    `collateral_position_status` STRING COMMENT 'Current lifecycle state of the position (e.g., active, inactive, closed).. Valid values are `active|inactive|closed|pending`',
    `collateral_type` STRING COMMENT 'Business classification used for regulatory and risk reporting.. Valid values are `cash|securities|margin|other`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the position record was first created in the system.',
    `currency` STRING COMMENT 'Three‑letter ISO 4217 currency code of the market value.. Valid values are `^[A-Z]{3}$`',
    `collateral_position_description` STRING COMMENT 'Free‑form text providing additional context about the position.',
    `eligible_flag` BOOLEAN COMMENT 'True if the asset meets eligibility criteria for posting under the agreement.',
    `haircut_percent` DECIMAL(5,2) COMMENT 'Regulatory haircut applied to the market value, expressed as a percent.',
    `label` STRING COMMENT 'Human‑readable label describing the collateral position (e.g., "Cash Collateral for Counterparty X on 2023‑10‑01").',
    `margin_call_flag` BOOLEAN COMMENT 'True if the position triggered a margin call on the reporting date.',
    `market_value` DECIMAL(20,2) COMMENT 'Current market value of the collateral in the reporting currency.',
    `net_market_value` DECIMAL(20,2) COMMENT 'Market value after applying the haircut (market_value * (1‑haircut_percent/100)).',
    `position_date` DATE COMMENT 'The business date for which the collateral snapshot is taken.',
    `position_source` STRING COMMENT 'Origin of the data feed (internal system vs external market data).. Valid values are `internal|external`',
    `quantity` DECIMAL(20,6) COMMENT 'Nominal amount of the collateral asset (units or face value).',
    `reference` STRING COMMENT 'Business reference code for the position, often used in reporting and reconciliation.',
    `regulatory_reportable_flag` BOOLEAN COMMENT 'True if the position must be reported under EMIR or similar regulations.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the position record.',
    `valuation_method` STRING COMMENT 'Method used to determine the market value of the collateral.. Valid values are `mark_to_market|mark_to_model|price_source`',
    CONSTRAINT pk_collateral_position PRIMARY KEY(`collateral_position_id`)
) COMMENT 'Daily snapshot of the collateral inventory held or pledged with each counterparty or CCP, representing the current collateral book of record. Stores position date, counterparty or CCP, asset ISIN/CUSIP, asset type, nominal quantity, market value, haircut';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`ccp_membership` (
    `ccp_membership_id` BIGINT COMMENT 'Unique surrogate key for each CCP membership record.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: CCP memberships are overseen by specific regulators (ESMA for EU CCPs, CFTC for US).',
    `ccp_name` STRING COMMENT 'Name of the central counterparty clearing house.. Valid values are `LCH|Eurex|CME|ICE|Clearstream`',
    `cleared_product` STRING COMMENT 'Asset class or product category cleared under the membership.. Valid values are `equities|fixed_income|derivatives|fx|commodities`',
    `clearing_broker_lei` STRING COMMENT 'LEI of the broker that holds the clearing membership on behalf of the fund.. Valid values are `^[A-Z0-9]{20}$`',
    `collateral_eligible` BOOLEAN COMMENT 'Indicates whether the membership permits posting collateral.',
    `collateral_type_allowed` STRING COMMENT 'Types of assets that can be used as collateral for this membership.. Valid values are `cash|government_securities|corporate_bonds|equity|commodities`',
    `compliance_document_reference` STRING COMMENT 'Identifier of the regulatory compliance document linked to this membership.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the membership record was created in the system.',
    `credit_limit` DECIMAL(18,2) COMMENT 'Maximum credit exposure permitted by the CCP for the member.',
    `effective_from` DATE COMMENT 'Date when the membership becomes effective.',
    `effective_until` DATE COMMENT 'Date when the membership ends or expires; null if open‑ended.',
    `fee_amount` DECIMAL(18,2) COMMENT 'Monetary amount of the membership fee for the current period.',
    `fee_structure` STRING COMMENT 'Method used to calculate CCP membership fees.. Valid values are `flat|percentage|tiered`',
    `initial_margin_requirement` DECIMAL(18,2) COMMENT 'Initial margin amount required by the CCP for this membership.',
    `jurisdiction` STRING COMMENT 'Country jurisdiction governing the CCP membership.. Valid values are `^[A-Z]{3}$`',
    `last_fee_assessed_date` DATE COMMENT 'Date when the most recent membership fee was assessed.',
    `last_margin_call_amount` DECIMAL(18,2) COMMENT 'Amount of the most recent margin call.',
    `last_margin_call_date` DATE COMMENT 'Date of the most recent margin call issued by the CCP.',
    `margin_call_frequency` STRING COMMENT 'How often margin calls are issued under the membership.. Valid values are `daily|weekly|monthly|ad_hoc`',
    `membership_status` STRING COMMENT 'Current lifecycle status of the CCP membership.. Valid values are `active|inactive|suspended|pending|terminated`',
    `membership_type` STRING COMMENT 'Classification of the membership relationship with the CCP.. Valid values are `direct|client|indirect`',
    `netting_agreement_flag` BOOLEAN COMMENT 'True if a netting agreement exists with the CCP.',
    `notes` STRING COMMENT 'Free‑form comments or remarks about the membership.',
    `registration_date` DATE COMMENT 'Date the membership was formally registered with the CCP.',
    `regulatory_reporting_status` STRING COMMENT 'Status of EMIR/other regulatory reporting for this membership.. Valid values are `compliant|non_compliant|pending_review`',
    `reporting_currency` STRING COMMENT 'Currency used for reporting balances and margins to the CCP.. Valid values are `^[A-Z]{3}$`',
    `risk_weight` DECIMAL(5,2) COMMENT 'Risk‑weight factor applied to exposures under this membership.',
    `settlement_cycle` STRING COMMENT 'Standard settlement period for trades cleared through this CCP.. Valid values are `T+1|T+2|T+3`',
    `termination_date` DATE COMMENT 'Date the membership was terminated, if applicable.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the membership record.',
    `variation_margin_requirement` DECIMAL(18,2) COMMENT 'Daily variation margin amount that must be posted to the CCP.',
    CONSTRAINT pk_ccp_membership PRIMARY KEY(`ccp_membership_id`)
) COMMENT 'Master record for each Central Counterparty (CCP) clearing membership held by the pension fund or its clearing broker. Stores CCP name (LCH, Eurex, CME, ICE), membership type (direct clearing member, client clearing), clearing broker LEI, cleared product';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`simm_calculation` (
    `simm_calculation_id` BIGINT COMMENT 'Unique system-generated identifier for the SIMM calculation record.',
    `counterparty_id` BIGINT COMMENT 'Identifier of the counterparty for which the SIMM margin is calculated.',
    `netting_agreement_id` BIGINT COMMENT 'Reference to the netting agreement governing offsetting of exposures.',
    `portfolio_id` BIGINT COMMENT 'Identifier of the investment portfolio containing the trades subject to the calculation.',
    `calculation_method` STRING COMMENT 'Indicates whether the calculation follows the standard SIMM methodology or a custom approach.. Valid values are `standard|custom`',
    `calculation_number` STRING COMMENT 'External business identifier or reference number assigned to the SIMM calculation.',
    `calculation_source_system` STRING COMMENT 'System that performed the SIMM calculation (e.g., Aladdin, In‑house engine).. Valid values are `Aladdin|InHouse|Other`',
    `calculation_timestamp` TIMESTAMP COMMENT 'Timestamp when the SIMM calculation was performed.',
    `collateral_eligible` BOOLEAN COMMENT 'Indicates if the calculated margin is eligible to be posted as collateral.',
    `comments` STRING COMMENT 'Free‑form notes or remarks about the calculation.',
    `confidence_interval` DECIMAL(5,2) COMMENT 'Statistical confidence interval associated with the margin estimate.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the calculation record was first created in the system.',
    `initial_margin_amount` DECIMAL(20,2) COMMENT 'Gross initial margin calculated before netting or offsets.',
    `input_data_hash` STRING COMMENT 'Cryptographic hash of the raw input data set used for reproducibility.',
    `is_override` BOOLEAN COMMENT 'True if the margin amount was manually overridden after automatic calculation.',
    `margin_adjustment` DECIMAL(20,2) COMMENT 'Any manual or regulatory adjustments applied to the margin.',
    `margin_call_date` DATE COMMENT 'Date by which the margin call should be satisfied.',
    `margin_call_required` BOOLEAN COMMENT 'True if a margin call must be issued based on the calculation result.',
    `margin_currency` STRING COMMENT 'Three‑letter ISO currency code of the margin amounts.. Valid values are `^[A-Z]{3}$`',
    `margin_factor` DECIMAL(10,4) COMMENT 'Multiplicative factor used in the margin calculation (e.g., scaling for stress scenarios).',
    `margin_type` STRING COMMENT 'Specifies whether the margin is initial, variation, or both.. Valid values are `initial|variation|both`',
    `model_version` STRING COMMENT 'Version of the ISDA SIMM model applied (e.g., v2.5).',
    `net_margin_amount` DECIMAL(20,2) COMMENT 'Margin amount after applying netting and eligible offsets.',
    `override_reason` STRING COMMENT 'Explanation provided for a manual margin override.',
    `regulatory_framework` STRING COMMENT 'Regulatory regime governing the margin calculation, e.g., EMIR.. Valid values are `EMIR`',
    `regulatory_reportable` BOOLEAN COMMENT 'Indicates whether the calculation result must be reported to regulators.',
    `risk_class` STRING COMMENT 'Primary risk class of the underlying exposure (e.g., interest rate, credit).. Valid values are `interest_rate|credit|equity|commodity|fx|inflation`',
    `sensitivity_count` BIGINT COMMENT 'Number of individual risk factor sensitivities processed in the calculation.',
    `simm_calculation_status` STRING COMMENT 'Current processing status of the SIMM calculation.. Valid values are `pending|running|completed|failed`',
    `total_risk_weight` DECIMAL(10,6) COMMENT 'Aggregate risk weight applied across all risk factors.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the calculation record.',
    `valuation_date` DATE COMMENT 'Date of the market data snapshot used for valuation in the calculation.',
    `version_number` BIGINT COMMENT 'Version number of the calculation record for audit and change tracking.',
    CONSTRAINT pk_simm_calculation PRIMARY KEY(`simm_calculation_id`)
) COMMENT 'Transactional record of each ISDA SIMM (Standard Initial Margin Model) calculation performed for bilateral uncleared OTC derivatives under EMIR UMR (Uncleared Margin Rules).';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`repo_transaction` (
    `repo_transaction_id` BIGINT COMMENT 'System-generated unique identifier for the repo transaction record.',
    `broker_id` BIGINT COMMENT 'Unique identifier of the broker facilitating the repo transaction.',
    `ccp_membership_id` BIGINT COMMENT 'Identifier of the clearing house that processes the repo settlement.',
    `counterparty_id` BIGINT COMMENT 'Unique identifier of the counterparty (bank, broker, or dealer) to the pension fund.',
    `legal_entity_id` BIGINT COMMENT 'Identifier of the legal entity (LEI) owning the transaction.',
    `repo_collateral_security_listed_security_id` BIGINT COMMENT 'Identifier of the security or asset posted as collateral for the repo.',
    `repo_listed_security_id` BIGINT COMMENT 'Identifier of the security that is being financed through the repo.',
    `accrued_interest` DECIMAL(20,2) COMMENT 'Interest accrued on the principal up to the reporting date.',
    `collateral_type` STRING COMMENT 'Classification of the collateral (cash, securities, or other assets).. Valid values are `cash|securities|other`',
    `collateral_value` DECIMAL(20,2) COMMENT 'Current market valuation of the posted collateral.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the repo transaction record was first created in the system.',
    `currency` STRING COMMENT 'ISO 4217 currency code of the cash leg of the repo transaction.',
    `emir_reporting_status` STRING COMMENT 'Current status of EMIR reporting for the transaction.. Valid values are `pending|submitted|rejected`',
    `external_trade_reference` STRING COMMENT 'Identifier assigned by the external execution system or broker.',
    `haircut_percent` DECIMAL(5,2) COMMENT 'Percentage discount applied to the collateral value for risk mitigation.',
    `initial_margin_amount` DECIMAL(20,2) COMMENT 'Initial collateral margin posted at the start of the repo.',
    `is_cleared` BOOLEAN COMMENT 'True if the transaction has been cleared through a CCP or clearing house.',
    `is_closed` BOOLEAN COMMENT 'True when the repo has been fully settled and closed.',
    `is_marginable` BOOLEAN COMMENT 'Indicates whether the repo transaction is eligible for margining under regulatory rules.',
    `is_open` BOOLEAN COMMENT 'Indicates whether the repo transaction is currently open (true) or closed (false).',
    `is_rehypothecated` BOOLEAN COMMENT 'True if the posted collateral may be rehypothecated by the counterparty.',
    `is_secured` BOOLEAN COMMENT 'Indicates whether the transaction is fully secured by collateral.',
    `maturity_date` DATE COMMENT 'Date when the repo transaction matures and the original security is repurchased.',
    `net_amount` DECIMAL(20,2) COMMENT 'Net cash amount after adding accrued interest and subtracting fees.',
    `notes` STRING COMMENT 'Free‑form text for any additional information or comments about the repo transaction.',
    `principal_amount` DECIMAL(20,2) COMMENT 'Cash amount lent or borrowed in the repo transaction.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates the regulatory reporting status of the repo under EMIR/SEC.',
    `repo_rate` DECIMAL(10,6) COMMENT 'Annualized interest rate applied to the principal for the repo term.',
    `repo_rate_type` STRING COMMENT 'Specifies whether the repo rate is fixed for the term or floating based on a reference index.. Valid values are `fixed|floating`',
    `repo_term_days` BIGINT COMMENT 'Length of the repo agreement expressed in calendar days.',
    `repo_trade_reference` STRING COMMENT 'External trade identifier assigned by the execution venue or broker.',
    `repo_transaction_status` STRING COMMENT 'Current processing state of the repo transaction.. Valid values are `draft|open|settled|closed|cancelled`',
    `repo_type` STRING COMMENT 'Indicates whether the transaction is a repo (sell‑and‑repurchase) or reverse repo (buy‑and‑sell).. Valid values are `repo|reverse_repo`',
    `settlement_amount` DECIMAL(20,2) COMMENT 'Total amount settled at maturity, including principal and interest.',
    `settlement_currency` STRING COMMENT 'Currency code used for the final settlement payment.',
    `settlement_date` DATE COMMENT 'Date on which cash and securities are exchanged to settle the repo.',
    `settlement_method` STRING COMMENT 'Method used to settle the repo (cash, securities, or netting).. Valid values are `cash|securities|netting`',
    `tax_withholding_amount` DECIMAL(20,2) COMMENT 'Monetary amount of tax withheld from the interest component.',
    `tax_withholding_percent` DECIMAL(5,2) COMMENT 'Percentage of tax withheld on interest payments, if applicable.',
    `termination_date` DATE COMMENT 'Date on which the repo transaction was terminated.',
    `termination_reason` STRING COMMENT 'Reason why the repo transaction was terminated before or at maturity.. Valid values are `maturity|early_termination|default|call`',
    `trade_date` DATE COMMENT 'Calendar date on which the repo trade was agreed.',
    `trade_execution_venue` STRING COMMENT 'Platform or market where the repo trade was executed.. Valid values are `exchange|OTC|ECN|dark_pool`',
    `transaction_timestamp` TIMESTAMP COMMENT 'Date and time when the repo trade was executed in the market.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the repo transaction record.',
    `variation_margin_amount` DECIMAL(20,2) COMMENT 'Additional margin required due to changes in market value of the collateral.',
    CONSTRAINT pk_repo_transaction PRIMARY KEY(`repo_transaction_id`)
) COMMENT 'Transactional record of each repurchase agreement (repo) or reverse repo executed for collateral transformation, liquidity management, or securities financing.';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`securities_lending` (
    `securities_lending_id` BIGINT COMMENT 'Unique surrogate key for each securities lending transaction record.',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: Securities lending transactions are executed with counterparties; adding counterparty_id FK links the transaction to the counterparty and removes redundant LEI/BIC columns.',
    `listed_security_id` BIGINT COMMENT 'ISIN of the security that is being lent.',
    `amendment_date` DATE COMMENT 'Date when the most recent amendment to the loan was executed.',
    `amendment_number` BIGINT COMMENT 'Sequential number of any amendment to the original loan agreement.',
    `collateral_currency` STRING COMMENT 'ISO 4217 currency code of the collateral value.',
    `collateral_eligibility_criteria` STRING COMMENT 'Business rules defining which assets qualify as collateral for this loan.',
    `collateral_type` STRING COMMENT 'Classification of the collateral received for the loan.. Valid values are `cash|government_bond|equity|other`',
    `collateral_value` DECIMAL(20,4) COMMENT 'Market value of the collateral at the time of loan initiation.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the loan record was first created in the system.',
    `credit_limit` DECIMAL(20,4) COMMENT 'Maximum credit exposure allowed for the counterparty under this loan.',
    `currency_code` STRING COMMENT 'ISO 4217 three‑letter code of the transaction currency.. Valid values are `^[A-Z]{3}$`',
    `securities_lending_description` STRING COMMENT 'Free‑text description of the loan purpose or special terms.',
    `effective_from` DATE COMMENT 'Date on which the loan agreement becomes effective.',
    `effective_until` DATE COMMENT 'Date on which the loan agreement terminates or expires.',
    `fee_amount` DECIMAL(20,4) COMMENT 'Monetary amount of fees charged for the loan.',
    `fee_rate` DECIMAL(5,4) COMMENT 'Annualized fee rate charged for the securities loan, expressed as a decimal.',
    `gross_amount` DECIMAL(20,4) COMMENT 'Total monetary amount before fees and rebates, in the loan currency.',
    `last_review_date` DATE COMMENT 'Date of the most recent compliance or risk review of the loan.',
    `loan_number` STRING COMMENT 'External business identifier assigned to the securities loan.',
    `loan_open_timestamp` TIMESTAMP COMMENT 'Date and time when the securities loan was initially opened.',
    `loan_recall_timestamp` TIMESTAMP COMMENT 'Date and time when the lender recalled the loaned securities.',
    `loan_return_timestamp` TIMESTAMP COMMENT 'Date and time when the loaned securities were returned to the lender.',
    `loan_status` STRING COMMENT 'Current lifecycle state of the securities loan.. Valid values are `open|closed|recall|defaulted|terminated`',
    `loan_term_days` BIGINT COMMENT 'Length of the loan in calendar days.',
    `loan_type` STRING COMMENT 'Classification of the loan product type.. Valid values are `securities_lending|repo|reverse_repo`',
    `margin_call_frequency` STRING COMMENT 'How often margin calls are evaluated for the loan.. Valid values are `daily|weekly|monthly|none`',
    `net_amount` DECIMAL(20,4) COMMENT 'Net monetary amount after applying fees and rebates.',
    `rebate_rate` DECIMAL(5,4) COMMENT 'Annualized rebate rate paid by the borrower to the lender, expressed as a decimal.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether the loan must be reported under EMIR or other regulations.',
    `risk_weight` DECIMAL(5,4) COMMENT 'Regulatory risk weight assigned to the collateral.',
    `security_cusip` STRING COMMENT 'CUSIP of the security that is being lent.. Valid values are `^[A-Z0-9]{9}$`',
    `security_quantity` DECIMAL(20,4) COMMENT 'Number of units of the security lent, expressed in the securitys native units.',
    `settlement_cycle` STRING COMMENT 'Standard settlement period for the loan transaction.. Valid values are `T+2|T+1|same_day`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the loan record.',
    `valuation_method` STRING COMMENT 'Method used to value the collateral at loan inception.. Valid values are `market|model|price_source`',
    CONSTRAINT pk_securities_lending PRIMARY KEY(`securities_lending_id`)
) COMMENT 'Transactional record of each securities lending transaction where the pension fund lends securities from its portfolio in exchange for collateral. Captures loan open date, recall date, return date, lent security ISIN/CUSIP, quantity lent, collateral type';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`substitution` (
    `substitution_id` BIGINT COMMENT 'Unique system-generated identifier for the collateral substitution transaction.',
    `blotter_id` BIGINT COMMENT 'Identifier of the underlying trade linked to the collateral substitution.',
    `collateral_position_id` BIGINT COMMENT 'Identifier of the collateral that is being replaced.',
    `counterparty_id` BIGINT COMMENT 'Identifier of the counterparty involved in the substitution.',
    `employee_id` BIGINT COMMENT 'System identifier of the user who created or last modified the record.',
    `margin_call_id` BIGINT COMMENT 'Identifier of the margin call that triggered the substitution, if applicable.',
    `new_collateral_collateral_position_id` BIGINT COMMENT 'Identifier of the collateral that is posted as replacement.',
    `substitution_collateral_position_id` BIGINT COMMENT 'Identifier of the collateral that is being replaced.',
    `substitution_new_collateral_collateral_position_id` BIGINT COMMENT 'Identifier of the collateral that is posted as replacement.',
    `audit_user_role` STRING COMMENT 'Business role of the user performing the audit action.. Valid values are `trader|risk|operations|compliance`',
    `comments` STRING COMMENT 'Additional free‑form notes captured by the operations team.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the substitution record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three‑letter currency code for the collateral values.. Valid values are `^[A-Z]{3}$`',
    `effective_date` DATE COMMENT 'Date on which the substitution becomes legally effective.',
    `eligibility_flag` BOOLEAN COMMENT 'Indicates whether the new collateral meets eligibility criteria under ISDA/CSA.',
    `execution_timestamp` TIMESTAMP COMMENT 'Date and time when the substitution was executed and posted.',
    `fee_currency_code` STRING COMMENT 'ISO 4217 currency code for the transaction fee.. Valid values are `^[A-Z]{3}$`',
    `haircut_percent` DECIMAL(5,2) COMMENT 'Percentage haircut applied to the new collateral value for margin purposes.',
    `is_automated` BOOLEAN COMMENT 'Indicates whether the substitution was processed automatically by workflow rules.',
    `net_amount_change` DECIMAL(20,2) COMMENT 'Difference between new and old collateral values (new – old).',
    `net_settlement_amount` DECIMAL(20,2) COMMENT 'Net cash amount to be settled after accounting for fees and haircuts.',
    `net_settlement_currency` STRING COMMENT 'Currency of the net settlement amount.. Valid values are `^[A-Z]{3}$`',
    `new_collateral_quantity` DECIMAL(20,6) COMMENT 'Quantity of the replacement collateral posted.',
    `new_collateral_value` DECIMAL(20,2) COMMENT 'Monetary value of the replacement collateral at the time of substitution.',
    `number` STRING COMMENT 'External reference number assigned to the substitution request for tracking and reporting.',
    `old_collateral_quantity` DECIMAL(20,6) COMMENT 'Quantity of the original collateral being substituted, expressed in its unit of measure.',
    `old_collateral_value` DECIMAL(20,2) COMMENT 'Monetary value of the original collateral at the time of substitution.',
    `reason_code` STRING COMMENT 'Standard code indicating the primary driver for the substitution.. Valid values are `risk|liquidity|regulatory|operational|client_request`',
    `reason_description` STRING COMMENT 'Free‑text explanation of why the substitution was performed.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'True if the substitution must be reported under EMIR or other regulatory regimes.',
    `request_timestamp` TIMESTAMP COMMENT 'Date and time when the substitution request was submitted.',
    `settlement_date` DATE COMMENT 'Date on which cash or securities settlement for the substitution occurs.',
    `substitution_status` STRING COMMENT 'Current lifecycle state of the substitution request.. Valid values are `requested|approved|executed|rejected|cancelled`',
    `substitution_type` STRING COMMENT 'Category describing why the substitution is being performed.. Valid values are `margin_call|portfolio_rebalance|regulatory_swap|voluntary`',
    `transaction_fee` DECIMAL(20,2) COMMENT 'Fee charged for processing the collateral substitution.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the substitution record.',
    `valuation_method` STRING COMMENT 'Method used to value the collateral at the time of substitution.. Valid values are `market|model|independent|internal`',
    CONSTRAINT pk_substitution PRIMARY KEY(`substitution_id`)
) COMMENT 'Transactional record of each collateral substitution request and execution, where previously posted collateral is replaced with an alternative eligible asset.';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`credit_limit_breach` (
    `credit_limit_breach_id` BIGINT COMMENT 'Unique system-generated identifier for the credit limit breach event.',
    `counterparty_id` BIGINT COMMENT 'Identifier of the counterparty whose exposure triggered the breach.',
    `credit_limit_id` BIGINT COMMENT 'Foreign key linking to collateral.credit_limit. Business justification: A credit limit breach event occurs when exposure exceeds a specific credit limit. The breach should reference the exact credit_limit record that was breached.',
    `limit_id` BIGINT COMMENT 'Reference to the master credit limit record that was breached.',
    `actual_exposure_amount` DECIMAL(20,2) COMMENT 'Measured exposure amount of the counterparty at the breach moment.',
    `breach_amount` DECIMAL(20,2) COMMENT 'Monetary amount by which exposure exceeded the approved limit.',
    `breach_number` STRING COMMENT 'Business identifier assigned to the breach event for tracking and reference.',
    `breach_percentage` DECIMAL(5,2) COMMENT 'Percentage of the approved limit that was exceeded (breach amount / approved limit).',
    `breach_reason` STRING COMMENT 'Narrative explanation of why the breach occurred (e.g., market move, valuation error).',
    `breach_resolution_deadline` DATE COMMENT 'Target date by which the breach must be resolved or mitigated.',
    `breach_resolved_flag` BOOLEAN COMMENT 'True if the breach has been fully addressed and exposure is back within limit.',
    `breach_resolved_timestamp` TIMESTAMP COMMENT 'Date and time when the breach was marked as resolved.',
    `breach_severity` STRING COMMENT 'Risk severity assigned to the breach based on magnitude and counterparty profile.. Valid values are `low|medium|high|critical`',
    `breach_timestamp` TIMESTAMP COMMENT 'Date and time when the credit limit breach was detected.',
    `comments` STRING COMMENT 'Additional remarks from risk or compliance teams regarding the breach.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the breach record was first created in the system.',
    `credit_limit_breach_status` STRING COMMENT 'Current lifecycle status of the breach record.. Valid values are `open|resolved|closed|pending`',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code for monetary amounts in this record.',
    `credit_limit_breach_description` STRING COMMENT 'Free‑form notes providing extra context about the breach.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this breach must be reported to regulators (e.g., SEC).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the breach record.',
    CONSTRAINT pk_credit_limit_breach PRIMARY KEY(`credit_limit_breach_id`)
) COMMENT 'Transactional record of each credit limit breach event where counterparty exposure exceeds an approved credit limit. Captures breach date, counterparty, limit type breached, approved limit amount, actual exposure at breach, breach magnitude (amount and';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`emir_trade_report` (
    `emir_trade_report_id` BIGINT COMMENT 'Surrogate primary key for the EMIR trade report record.',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: EMIR trade reports reference a counterparty via LEI/BIC; adding counterparty_id FK provides a direct link and removes redundancy.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: EMIR trade reports must be submitted to specific regulatory authorities (ESMA, NCAs).',
    `amendment_indicator` BOOLEAN COMMENT 'True if the report represents an amendment to a previously submitted report.',
    `clearing_house_lei` STRING COMMENT 'LEI of the clearing house, if the trade is centrally cleared.',
    `collateral_eligible_flag` BOOLEAN COMMENT 'True if the trade is eligible to receive or post collateral under EMIR.',
    `comments` STRING COMMENT 'Additional remarks or notes related to the trade report.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the EMIR trade report record was first created in the data lake.',
    `emir_trade_report_description` STRING COMMENT 'Free‑form description of the trade for internal reference.',
    `jurisdiction` STRING COMMENT 'Three‑letter country code of the regulatory jurisdiction.. Valid values are `^[A-Z]{3}$`',
    `margin_call_flag` BOOLEAN COMMENT 'Indicates whether a margin call was generated for the trade.',
    `maturity_date` DATE COMMENT 'Date on which the derivative contract expires or settles.',
    `notional_amount` DECIMAL(20,2) COMMENT 'Principal amount on which the derivative payoff is based.',
    `notional_currency` STRING COMMENT 'Three‑letter ISO currency code for the notional amount.. Valid values are `^[A-Z]{3}$`',
    `price` DECIMAL(20,6) COMMENT 'Price or rate agreed for the derivative contract.',
    `price_currency` STRING COMMENT 'Currency in which the trade price is expressed.. Valid values are `^[A-Z]{3}$`',
    `product_class` STRING COMMENT 'High‑level classification of the derivative product.. Valid values are `interest_rate|credit|equity|fx|commodity|inflation`',
    `quantity` DECIMAL(20,6) COMMENT 'Number of units or contracts involved in the trade.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether the trade is subject to EMIR reporting.',
    `report_date` DATE COMMENT 'Calendar date on which the trade report was submitted to the trade repository.',
    `report_status` STRING COMMENT 'Processing status of the EMIR report within the trade repository.. Valid values are `submitted|accepted|rejected|pending|error`',
    `reporting_entity_lei` STRING COMMENT 'LEI of the pension fund entity that is responsible for the EMIR report.',
    `risk_weight` DECIMAL(5,2) COMMENT 'Regulatory risk weight assigned to the trade for capital calculations.',
    `settlement_date` DATE COMMENT 'Date on which cash or securities settlement is due.',
    `trade_status` STRING COMMENT 'Current lifecycle state of the trade.. Valid values are `executed|cleared|settled|failed|rejected|pending`',
    `trade_timestamp` TIMESTAMP COMMENT 'Exact date and time when the OTC derivative trade was executed.',
    `trade_type` STRING COMMENT 'Category of the derivative contract (e.g., swap, option).. Valid values are `swap|option|forward|future|credit_derivative|interest_rate_derivative`',
    `trade_venue` STRING COMMENT 'Identifier of the venue or platform where the trade was executed.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the EMIR trade report record.',
    `upi` STRING COMMENT 'Identifier for the underlying product class of the trade as defined by EMIR.',
    `uti` STRING COMMENT 'Globally unique identifier assigned to the trade under EMIR reporting.',
    `valuation_date` DATE COMMENT 'Date on which the trade was valued for reporting purposes.',
    `valuation_method` STRING COMMENT 'Methodology used to determine the trades value.. Valid values are `mark_to_market|model_based|price_source|fallback`',
    `valuation_timestamp` TIMESTAMP COMMENT 'Exact time of the valuation used for the EMIR report.',
    `version_number` BIGINT COMMENT 'Sequential version number for amended reports.',
    CONSTRAINT pk_emir_trade_report PRIMARY KEY(`emir_trade_report_id`)
) COMMENT 'Transactional record of each EMIR trade reporting submission for OTC derivative transactions to a registered Trade Repository (TR). Captures report date, UTI (Unique Trade Identifier), UPI (Unique Product Identifier), counterparty LEI, reporting';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`ssi_registry` (
    `ssi_registry_id` BIGINT COMMENT 'Unique surrogate key for each SSI registry record.',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: SSIs are issued to counterparties; adding counterparty_id FK links SSIs to the counterparty and removes redundant LEI/BIC columns.',
    `account_number` STRING COMMENT 'Account identifier at the custodian for the settlement of the asset.',
    `asset_type` STRING COMMENT 'Category of asset for which the settlement instruction is used.. Valid values are `equity|fixed_income|real_estate|private_equity|infrastructure|cash`',
    `collateral_type` STRING COMMENT 'Nature of collateral accepted under the SSI.. Valid values are `cash|securities|guarantee|letter_of_credit|insurance|other`',
    `comments` STRING COMMENT 'Free‑form notes or remarks about the SSI.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the SSI record was first created in the system.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code of the settlement currency.. Valid values are `USD|EUR|GBP|CAD|JPY|CHF`',
    `custodian_bic` STRING COMMENT 'BIC of the custodian bank holding the settlement account.',
    `ssi_registry_description` STRING COMMENT 'Human‑readable description of the SSI purpose and scope.',
    `effective_from` DATE COMMENT 'Date on which the SSI becomes effective for settlement.',
    `effective_until` DATE COMMENT 'Date on which the SSI expires or is superseded; null for open‑ended.',
    `eligibility_criteria` STRING COMMENT 'Business rules that determine whether an asset qualifies for the SSI.',
    `haircut_percentage` DECIMAL(5,2) COMMENT 'Percentage reduction applied to the collateral value for risk mitigation.',
    `instruction_type` STRING COMMENT 'Classification of the instruction record (e.g., standard SSI, settlement instruction, payment instruction).. Valid values are `ssi|settlement_instruction|payment_instruction`',
    `last_review_date` DATE COMMENT 'Date when the SSI was last reviewed for accuracy and compliance.',
    `margin_call_frequency` STRING COMMENT 'How often margin calls are generated against this SSI.. Valid values are `daily|weekly|monthly|quarterly|ad_hoc|none`',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether the SSI must be reported under EMIR/BCBS regulations.',
    `risk_weight` DECIMAL(5,2) COMMENT 'Regulatory risk weight applied to the collateral for capital calculations.',
    `settlement_cycle` STRING COMMENT 'Regularity of settlement processing for the instruction.. Valid values are `daily|weekly|monthly|quarterly|ad_hoc|none`',
    `settlement_method` STRING COMMENT 'Mechanism by which the settlement is executed.. Valid values are `DVP|FOP|RTGS|ACH|SWIFT|CLS`',
    `settlement_platform` STRING COMMENT 'Clearing/settlement platform used for the instruction.. Valid values are `Euroclear|Clearstream|DTCC|LCH|CME|ICE`',
    `ssi_code` STRING COMMENT 'Business identifier assigned to the SSI record by the fund.',
    `ssi_registry_status` STRING COMMENT 'Current lifecycle status of the SSI record.. Valid values are `active|inactive|pending|suspended|terminated`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the SSI record.',
    `valuation_method` STRING COMMENT 'Methodology used to value the collateral (e.g., market price, model).',
    `version` BIGINT COMMENT 'Incremental version number for change tracking.',
    CONSTRAINT pk_ssi_registry PRIMARY KEY(`ssi_registry_id`)
) COMMENT 'Master registry of Standard Settlement Instructions (SSIs) for each counterparty and asset type combination used in collateral settlement. Stores counterparty LEI, asset type, currency, custodian BIC, account number, settlement platform (Euroclear';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`counterparty_rating` (
    `counterparty_rating_id` BIGINT COMMENT 'Unique identifier for the rating record.',
    `counterparty_id` BIGINT COMMENT 'Identifier of the counterparty to which this rating applies.',
    `comments` STRING COMMENT 'Free‑form notes or comments about the rating.',
    `counterparty_rating_status` STRING COMMENT 'Current lifecycle status of the rating record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the rating record was first created in the system.',
    `data_quality_score` DECIMAL(3,2) COMMENT 'Score (0‑1) reflecting the quality and completeness of the rating data.',
    `is_historical` BOOLEAN COMMENT 'Indicates whether the rating is retained for historical reporting only.',
    `outlook` STRING COMMENT 'Outlook associated with the rating (positive, negative, stable, unchanged).',
    `prior_rating_value` DECIMAL(18,2) COMMENT 'Rating value that preceded the current rating.',
    `rating_agency` STRING COMMENT 'Name of the external rating agency (e.g., Moodys, S&P, Fitch).',
    `rating_change_reason` STRING COMMENT 'Reason or event that triggered the rating change (e.g., financial performance, market conditions).',
    `rating_confidence_score` DECIMAL(5,2) COMMENT 'Numeric confidence score (0-100) indicating the certainty of the rating.',
    `rating_date` DATE COMMENT 'Date on which the rating was issued.',
    `rating_effective_date` DATE COMMENT 'Date when the rating becomes effective for the counterparty.',
    `rating_expiration_date` DATE COMMENT 'Date when the rating expires or is scheduled for review.',
    `rating_methodology` STRING COMMENT 'Brief description of the methodology used to derive the rating.',
    `rating_scale` STRING COMMENT 'Scale used by the rating agency (e.g., S&P, Moodys, Fitch).',
    `rating_source` STRING COMMENT 'Indicates whether the rating originates from an external agency or internal assessment.',
    `rating_type` STRING COMMENT 'Classification of rating as long-term, short-term, or outlook.',
    `rating_value` DECIMAL(18,2) COMMENT 'Numeric or alphanumeric rating assigned by the agency. [ENUM-REF-CANDIDATE: AAA|AA|A|BBB|BB|B|CCC|CC|C|D|NR|WD|SD — promote to reference product]',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates if the rating is required for regulatory reporting (yes/no).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the rating record.',
    `version` BIGINT COMMENT 'Incremental version number for the rating record to track revisions.',
    CONSTRAINT pk_counterparty_rating PRIMARY KEY(`counterparty_rating_id`)
) COMMENT 'Tracks the credit ratings assigned to each counterparty by external rating agencies (Moodys, S&P, Fitch) and internal credit assessment. Stores rating agency, rating type (long-term, short-term, outlook), rating value, rating date, prior rating, rating';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`recall` (
    `recall_id` BIGINT COMMENT 'System-generated unique identifier for the collateral recall instruction.',
    `collateral_position_id` BIGINT COMMENT 'Foreign key linking to collateral.collateral_position. Business justification: A recall instruction retrieves previously posted collateral from a specific position. The recall should reference the collateral_position from which assets are being recalled.',
    `counterparty_id` BIGINT COMMENT 'Unique identifier of the counterparty from which collateral is being recalled.',
    `asset_identifier` STRING COMMENT 'Standard security identifier of the collateral asset being recalled.',
    `asset_type` STRING COMMENT 'Classification of the recalled asset.. Valid values are `cash|security|derivative|real_estate|commodity`',
    `comments` STRING COMMENT 'Additional free‑form notes related to the recall.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the recall record was first created in the system.',
    `recall_description` STRING COMMENT 'Free‑text description providing additional context for the recall.',
    `haircut_percentage` DECIMAL(5,2) COMMENT 'Percentage reduction applied to the gross value of the recalled collateral.',
    `is_historical` BOOLEAN COMMENT 'True if the record represents a historical (non‑current) recall.',
    `net_amount` DECIMAL(20,6) COMMENT 'Value of the recalled collateral after applying the haircut.',
    `net_currency` STRING COMMENT 'Currency of the net recall amount.. Valid values are `^[A-Z]{3}$`',
    `number` STRING COMMENT 'External business identifier assigned to the recall request.',
    `quantity` DECIMAL(20,6) COMMENT 'Amount of the asset being recalled, expressed in the unit specified.',
    `quantity_unit` STRING COMMENT 'Unit of measure for the recalled quantity.. Valid values are `shares|units|million_usd|kg`',
    `reason` STRING COMMENT 'Business reason prompting the collateral recall.. Valid values are `trade_maturity|rebalancing|substitution|margin_call|regulatory|other`',
    `recall_status` STRING COMMENT 'Current lifecycle state of the recall instruction.. Valid values are `issued|pending|completed|rejected|cancelled`',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether the recall must be reported to regulatory authorities.',
    `timestamp` TIMESTAMP COMMENT 'Date and time when the recall instruction was issued.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the recall record.',
    `valuation_amount` DECIMAL(20,6) COMMENT 'Monetary value of the recalled collateral on the valuation date.',
    `valuation_currency` STRING COMMENT 'Three‑letter ISO currency code of the valuation amount.. Valid values are `^[A-Z]{3}$`',
    `valuation_date` DATE COMMENT 'Date of the market valuation used for the recalled collateral.',
    `version` BIGINT COMMENT 'Version number for optimistic concurrency control.',
    CONSTRAINT pk_recall PRIMARY KEY(`recall_id`)
) COMMENT 'Transactional record of each collateral recall instruction issued to retrieve previously posted collateral from a counterparty. Captures recall date, asset ISIN/CUSIP, quantity recalled, recall reason (trade maturity, rebalancing, substitution';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`counterparty_stress_result` (
    `counterparty_stress_result_id` BIGINT COMMENT 'Unique identifier for this counterparty stress test result record',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to the counterparty being stress tested',
    `stress_scenario_id` BIGINT COMMENT 'Foreign key linking to the stress scenario being applied',
    `effective_date` DATE COMMENT 'The date on which this stress test result was calculated or became effective',
    `exposure_amount` DECIMAL(20,2) COMMENT 'The counterparty exposure amount under this specific stress scenario, reflecting stressed mark-to-market values',
    `margin_call_estimate` DECIMAL(20,2) COMMENT 'Estimated margin call amount that would be triggered for this counterparty under this stress scenario',
    `pnl_impact` DECIMAL(20,2) COMMENT 'The profit and loss impact for this counterparty under this stress scenario',
    CONSTRAINT pk_counterparty_stress_result PRIMARY KEY(`counterparty_stress_result_id`)
) COMMENT 'This association product represents the stress test result for a specific counterparty under a specific stress scenario. It captures the quantified impact of applying a macroeconomic or market stress scenario to a counterpartys exposure, including';

CREATE OR REPLACE TABLE `asset_management`.`collateral`.`collateral_account` (
    `collateral_account_id` BIGINT COMMENT 'Primary key for collateral_account',
    `ccp_membership_id` BIGINT COMMENT 'Reference to the central counterparty clearing house if this is a CCP-cleared collateral account.',
    `counterparty_id` BIGINT COMMENT 'Reference to the counterparty entity associated with this collateral account for exposure tracking.',
    `csa_id` BIGINT COMMENT 'Reference to the governing ISDA Credit Support Annex agreement defining collateral terms and eligibility.',
    `custodian_id` BIGINT COMMENT 'Reference to the custodian institution holding the collateral assets in this account.',
    `eligibility_schedule_id` BIGINT COMMENT 'Reference to the schedule defining eligible collateral types and haircuts for this account.',
    `account_holder_name` STRING COMMENT 'Legal name of the entity that holds this collateral account as registered with the custodian.',
    `account_number` STRING COMMENT 'External business identifier for the collateral account used in margin call processing and counterparty communications.',
    `account_type` STRING COMMENT 'Classification of the collateral account indicating its purpose and segregation requirements under regulatory frameworks.',
    `base_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code representing the base currency for collateral valuations and margin calculations.',
    `bic_code` STRING COMMENT 'SWIFT BIC code of the custodian bank holding the collateral account for settlement instructions.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this collateral account record was first created in the system.',
    `credit_limit_amount` DECIMAL(18,2) COMMENT 'Maximum unsecured credit exposure permitted for this account before additional collateral is required.',
    `collateral_account_description` STRING COMMENT 'Free-text description providing additional context about the collateral account purpose and usage.',
    `dispute_resolution_method` STRING COMMENT 'Method specified for resolving disputes related to margin calls and collateral valuations.',
    `effective_date` DATE COMMENT 'Date from which the collateral account becomes active and available for margin call processing.',
    `governing_law_jurisdiction` STRING COMMENT 'Legal jurisdiction governing the collateral account and associated CSA agreement terms.',
    `independent_amount` DECIMAL(18,2) COMMENT 'Additional collateral amount required independent of mark-to-market exposure, often based on credit rating.',
    `interest_rate_basis` STRING COMMENT 'Reference rate used for calculating interest on cash collateral held in this account.',
    `interest_rate_spread_bps` DECIMAL(8,4) COMMENT 'Spread in basis points applied to the reference rate for cash collateral interest calculations.',
    `is_bilateral` BOOLEAN COMMENT 'Indicates whether this is a bilateral OTC collateral arrangement versus a cleared arrangement.',
    `is_ccp_cleared` BOOLEAN COMMENT 'Indicates whether this account is used for centrally cleared derivatives requiring CCP margin posting.',
    `is_initial_margin_required` BOOLEAN COMMENT 'Indicates whether initial margin posting is required under BCBS-IOSCO uncleared margin rules.',
    `is_rehypothecation_allowed` BOOLEAN COMMENT 'Indicates whether the collateral holder may reuse posted collateral for their own purposes.',
    `is_segregated` BOOLEAN COMMENT 'Indicates whether collateral assets are held in a segregated account separate from house assets.',
    `is_unilateral_posting` BOOLEAN COMMENT 'Indicates whether only one party is required to post collateral under the agreement terms.',
    `is_variation_margin_required` BOOLEAN COMMENT 'Indicates whether variation margin posting is required for this collateral arrangement.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this collateral account record was last updated in the system.',
    `legal_entity_identifier` STRING COMMENT '20-character ISO 17442 Legal Entity Identifier of the account holder for regulatory reporting.',
    `margin_call_frequency` STRING COMMENT 'Frequency at which margin calls are calculated and issued for this collateral account.',
    `margin_type` STRING COMMENT 'Type of margin this account is designated to hold, distinguishing initial margin from variation margin.',
    `minimum_transfer_amount` DECIMAL(18,2) COMMENT 'Minimum threshold amount below which collateral transfers are not required under the CSA agreement.',
    `collateral_account_name` STRING COMMENT 'Human-readable name or label assigned to the collateral account for identification purposes.',
    `notification_deadline_time` STRING COMMENT 'Daily cutoff time by which margin call notifications must be issued to be effective for same-day settlement.',
    `notification_time_zone` STRING COMMENT 'Time zone used for determining margin call notification deadlines and settlement cutoff times.',
    `posting_party_role` STRING COMMENT 'Role of the account holder in the collateral arrangement indicating posting obligations.',
    `regulatory_classification` STRING COMMENT 'EMIR counterparty classification affecting margin requirements and clearing obligations.',
    `rounding_amount` DECIMAL(18,2) COMMENT 'Amount to which collateral transfers are rounded for operational efficiency in margin call processing.',
    `settlement_days` BIGINT COMMENT 'Number of business days allowed for collateral settlement following a margin call notification.',
    `settlement_method` STRING COMMENT 'Method by which collateral is transferred between parties, affecting legal ownership and rehypothecation rights.',
    `collateral_account_status` STRING COMMENT 'Current lifecycle status of the collateral account indicating operational availability for margin movements.',
    `termination_date` DATE COMMENT 'Date on which the collateral account is scheduled to terminate or was closed. Null for open-ended accounts.',
    `threshold_amount` DECIMAL(18,2) COMMENT 'Unsecured credit exposure threshold above which collateral must be posted under the CSA agreement.',
    `valuation_frequency` STRING COMMENT 'Frequency at which collateral assets in this account are marked to market for exposure calculations.',
    CONSTRAINT pk_collateral_account PRIMARY KEY(`collateral_account_id`)
) COMMENT 'Master reference table for collateral_account. Referenced by collateral_account_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`collateral`.`isda_master` ADD CONSTRAINT `fk_collateral_isda_master_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`csa` ADD CONSTRAINT `fk_collateral_csa_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`csa` ADD CONSTRAINT `fk_collateral_csa_isda_master_id` FOREIGN KEY (`isda_master_id`) REFERENCES `asset_management`.`collateral`.`isda_master`(`isda_master_id`);
ALTER TABLE `asset_management`.`collateral`.`csa` ADD CONSTRAINT `fk_collateral_csa_netting_agreement_id` FOREIGN KEY (`netting_agreement_id`) REFERENCES `asset_management`.`collateral`.`netting_agreement`(`netting_agreement_id`);
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ADD CONSTRAINT `fk_collateral_netting_agreement_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ADD CONSTRAINT `fk_collateral_eligibility_schedule_agreement_csa_id` FOREIGN KEY (`agreement_csa_id`) REFERENCES `asset_management`.`collateral`.`csa`(`csa_id`);
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ADD CONSTRAINT `fk_collateral_eligibility_schedule_csa_id` FOREIGN KEY (`csa_id`) REFERENCES `asset_management`.`collateral`.`csa`(`csa_id`);
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ADD CONSTRAINT `fk_collateral_credit_limit_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`exposure` ADD CONSTRAINT `fk_collateral_exposure_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`exposure` ADD CONSTRAINT `fk_collateral_exposure_netting_agreement_id` FOREIGN KEY (`netting_agreement_id`) REFERENCES `asset_management`.`collateral`.`netting_agreement`(`netting_agreement_id`);
ALTER TABLE `asset_management`.`collateral`.`margin_call` ADD CONSTRAINT `fk_collateral_margin_call_collateral_account_id` FOREIGN KEY (`collateral_account_id`) REFERENCES `asset_management`.`collateral`.`collateral_account`(`collateral_account_id`);
ALTER TABLE `asset_management`.`collateral`.`margin_call` ADD CONSTRAINT `fk_collateral_margin_call_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`margin_call` ADD CONSTRAINT `fk_collateral_margin_call_csa_id` FOREIGN KEY (`csa_id`) REFERENCES `asset_management`.`collateral`.`csa`(`csa_id`);
ALTER TABLE `asset_management`.`collateral`.`margin_call` ADD CONSTRAINT `fk_collateral_margin_call_party_counterparty_id` FOREIGN KEY (`party_counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ADD CONSTRAINT `fk_collateral_margin_dispute_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ADD CONSTRAINT `fk_collateral_margin_dispute_margin_call_id` FOREIGN KEY (`margin_call_id`) REFERENCES `asset_management`.`collateral`.`margin_call`(`margin_call_id`);
ALTER TABLE `asset_management`.`collateral`.`posting` ADD CONSTRAINT `fk_collateral_posting_collateral_position_id` FOREIGN KEY (`collateral_position_id`) REFERENCES `asset_management`.`collateral`.`collateral_position`(`collateral_position_id`);
ALTER TABLE `asset_management`.`collateral`.`posting` ADD CONSTRAINT `fk_collateral_posting_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`posting` ADD CONSTRAINT `fk_collateral_posting_margin_call_id` FOREIGN KEY (`margin_call_id`) REFERENCES `asset_management`.`collateral`.`margin_call`(`margin_call_id`);
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ADD CONSTRAINT `fk_collateral_collateral_position_ccp_ccp_membership_id` FOREIGN KEY (`ccp_ccp_membership_id`) REFERENCES `asset_management`.`collateral`.`ccp_membership`(`ccp_membership_id`);
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ADD CONSTRAINT `fk_collateral_collateral_position_ccp_membership_id` FOREIGN KEY (`ccp_membership_id`) REFERENCES `asset_management`.`collateral`.`ccp_membership`(`ccp_membership_id`);
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ADD CONSTRAINT `fk_collateral_collateral_position_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ADD CONSTRAINT `fk_collateral_simm_calculation_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ADD CONSTRAINT `fk_collateral_simm_calculation_netting_agreement_id` FOREIGN KEY (`netting_agreement_id`) REFERENCES `asset_management`.`collateral`.`netting_agreement`(`netting_agreement_id`);
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ADD CONSTRAINT `fk_collateral_repo_transaction_ccp_membership_id` FOREIGN KEY (`ccp_membership_id`) REFERENCES `asset_management`.`collateral`.`ccp_membership`(`ccp_membership_id`);
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ADD CONSTRAINT `fk_collateral_repo_transaction_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ADD CONSTRAINT `fk_collateral_securities_lending_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`substitution` ADD CONSTRAINT `fk_collateral_substitution_collateral_position_id` FOREIGN KEY (`collateral_position_id`) REFERENCES `asset_management`.`collateral`.`collateral_position`(`collateral_position_id`);
ALTER TABLE `asset_management`.`collateral`.`substitution` ADD CONSTRAINT `fk_collateral_substitution_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`substitution` ADD CONSTRAINT `fk_collateral_substitution_margin_call_id` FOREIGN KEY (`margin_call_id`) REFERENCES `asset_management`.`collateral`.`margin_call`(`margin_call_id`);
ALTER TABLE `asset_management`.`collateral`.`substitution` ADD CONSTRAINT `fk_collateral_substitution_new_collateral_collateral_position_id` FOREIGN KEY (`new_collateral_collateral_position_id`) REFERENCES `asset_management`.`collateral`.`collateral_position`(`collateral_position_id`);
ALTER TABLE `asset_management`.`collateral`.`substitution` ADD CONSTRAINT `fk_collateral_substitution_substitution_collateral_position_id` FOREIGN KEY (`substitution_collateral_position_id`) REFERENCES `asset_management`.`collateral`.`collateral_position`(`collateral_position_id`);
ALTER TABLE `asset_management`.`collateral`.`substitution` ADD CONSTRAINT `fk_collateral_substitution_substitution_new_collateral_collateral_position_id` FOREIGN KEY (`substitution_new_collateral_collateral_position_id`) REFERENCES `asset_management`.`collateral`.`collateral_position`(`collateral_position_id`);
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ADD CONSTRAINT `fk_collateral_credit_limit_breach_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ADD CONSTRAINT `fk_collateral_credit_limit_breach_credit_limit_id` FOREIGN KEY (`credit_limit_id`) REFERENCES `asset_management`.`collateral`.`credit_limit`(`credit_limit_id`);
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ADD CONSTRAINT `fk_collateral_emir_trade_report_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ADD CONSTRAINT `fk_collateral_ssi_registry_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ADD CONSTRAINT `fk_collateral_counterparty_rating_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`recall` ADD CONSTRAINT `fk_collateral_recall_collateral_position_id` FOREIGN KEY (`collateral_position_id`) REFERENCES `asset_management`.`collateral`.`collateral_position`(`collateral_position_id`);
ALTER TABLE `asset_management`.`collateral`.`recall` ADD CONSTRAINT `fk_collateral_recall_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`counterparty_stress_result` ADD CONSTRAINT `fk_collateral_counterparty_stress_result_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`collateral_account` ADD CONSTRAINT `fk_collateral_collateral_account_ccp_membership_id` FOREIGN KEY (`ccp_membership_id`) REFERENCES `asset_management`.`collateral`.`ccp_membership`(`ccp_membership_id`);
ALTER TABLE `asset_management`.`collateral`.`collateral_account` ADD CONSTRAINT `fk_collateral_collateral_account_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`collateral`.`collateral_account` ADD CONSTRAINT `fk_collateral_collateral_account_csa_id` FOREIGN KEY (`csa_id`) REFERENCES `asset_management`.`collateral`.`csa`(`csa_id`);
ALTER TABLE `asset_management`.`collateral`.`collateral_account` ADD CONSTRAINT `fk_collateral_collateral_account_eligibility_schedule_id` FOREIGN KEY (`eligibility_schedule_id`) REFERENCES `asset_management`.`collateral`.`eligibility_schedule`(`eligibility_schedule_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`collateral`.`counterparty` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`collateral`.`counterparty` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`counterparty` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`counterparty` SET TAGS ('dbx_subdomain' = 'counterparty_risk');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Actor Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `bic` SET TAGS ('dbx_business_glossary_term' = 'Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `bic` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `bic` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `blacklist_reason` SET TAGS ('dbx_business_glossary_term' = 'Blacklist Reason (BLR)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `classification` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Classification (CL)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `classification` SET TAGS ('dbx_value_regex' = 'internal|external|affiliated');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `collateral_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Collateral Eligibility Flag (CEF)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments (CMTS)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `counterparty_status` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Status (STAT)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `counterparty_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|terminated|pending');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `country_of_incorporation` SET TAGS ('dbx_business_glossary_term' = 'Country of Incorporation (COI)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `credit_limit` SET TAGS ('dbx_business_glossary_term' = 'Credit Limit (CL)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `credit_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `credit_limit` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `default_probability` SET TAGS ('dbx_business_glossary_term' = 'Default Probability (DP)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `entity_type` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Entity Type (ET)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `entity_type` SET TAGS ('dbx_value_regex' = 'bank|broker|custodian|ccp|fund_manager|other');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `esg_score` SET TAGS ('dbx_business_glossary_term' = 'ESG Score (ESG)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `exposure_limit` SET TAGS ('dbx_business_glossary_term' = 'Exposure Limit (EL)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `exposure_limit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `exposure_limit` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `is_blacklisted` SET TAGS ('dbx_business_glossary_term' = 'Is Blacklisted (BL)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `is_central_counterparty` SET TAGS ('dbx_business_glossary_term' = 'Is Central Counterparty (CCP)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `is_clearing_member` SET TAGS ('dbx_business_glossary_term' = 'Is Clearing Member (CM)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Legal Jurisdiction (JUR)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `last_rating_date` SET TAGS ('dbx_business_glossary_term' = 'Last Rating Date (LRD)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `lei` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `lei` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Lifecycle Status (LIFESTAT)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_value_regex' = 'onboarding|active|closed|terminated');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `margin_call_threshold` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Threshold (MCT)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `counterparty_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Name (LE)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `onboarding_date` SET TAGS ('dbx_business_glossary_term' = 'Onboarding Date (OBD)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `primary_contact_address` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Address (PCA)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `primary_contact_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `primary_contact_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Email (PCE)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_value_regex' = '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,}$');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Name (PCN)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Phone (PCP)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9]{7,15}$');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `rating_agency` SET TAGS ('dbx_business_glossary_term' = 'Rating Agency (RA)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Created Timestamp (RACT)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Updated Timestamp (RAUT)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `recovery_rate` SET TAGS ('dbx_business_glossary_term' = 'Recovery Rate (RR)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `registration_number` SET TAGS ('dbx_business_glossary_term' = 'Company Registration Number (CRN)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `registration_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]+$');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `registration_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `registration_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `regulatory_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Status (REGSTAT)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `regulatory_status` SET TAGS ('dbx_value_regex' = 'regulated|unregulated|exempt');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating (RR)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `settlement_currency` SET TAGS ('dbx_business_glossary_term' = 'Settlement Currency (SCUR)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `settlement_currency` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|JPY|CHF');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_business_glossary_term' = 'Settlement Cycle (SC)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_value_regex' = 'T+0|T+1|T+2|T+3');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `short_name` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Short Name (CSN)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `tax_identifier` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number (TIN)');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `tax_identifier` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{8,15}$');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `tax_identifier` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `tax_identifier` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date (TD)');
ALTER TABLE `asset_management`.`collateral`.`isda_master` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`collateral`.`isda_master` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`isda_master` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`isda_master` SET TAGS ('dbx_subdomain' = 'agreement_documentation');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `isda_master_id` SET TAGS ('dbx_business_glossary_term' = 'ISDA Master Agreement ID');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_internal' = 'true');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `agreement_number` SET TAGS ('dbx_business_glossary_term' = 'Agreement Number');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `agreement_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]+$');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Agreement Type');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = '1992|2002');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `amendment_count` SET TAGS ('dbx_business_glossary_term' = 'Amendment Count');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `amendment_indicator` SET TAGS ('dbx_business_glossary_term' = 'Amendment Indicator');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `close_out_netting_provision` SET TAGS ('dbx_business_glossary_term' = 'Close‑out Netting Provision');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `collateral_eligibility` SET TAGS ('dbx_business_glossary_term' = 'Collateral Eligibility');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `collateral_eligibility` SET TAGS ('dbx_value_regex' = 'eligible|ineligible|partial');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `confidentiality_classification` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Classification');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `confidentiality_classification` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `counterparty_bic` SET TAGS ('dbx_business_glossary_term' = 'Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `counterparty_bic` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{8,11}$');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `credit_support_annex_reference` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) Reference');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `default_provision` SET TAGS ('dbx_business_glossary_term' = 'Default Provision');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Mechanism');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `document_reference` SET TAGS ('dbx_business_glossary_term' = 'Document Reference');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `early_termination_rights` SET TAGS ('dbx_business_glossary_term' = 'Early Termination Rights');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `execution_date` SET TAGS ('dbx_business_glossary_term' = 'Execution Date');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `governing_law_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Governing Law Jurisdiction');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `isda_master_status` SET TAGS ('dbx_business_glossary_term' = 'Agreement Status');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `isda_master_status` SET TAGS ('dbx_value_regex' = 'active|terminated|suspended|draft|pending');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `jurisdiction_code` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction ISO Code');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `jurisdiction_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `last_amendment_date` SET TAGS ('dbx_business_glossary_term' = 'Last Amendment Date');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `margin_call_frequency` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Frequency');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `margin_call_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|ad_hoc');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `margin_currency` SET TAGS ('dbx_business_glossary_term' = 'Margin Currency');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `margin_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `margin_threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Margin Threshold Amount');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `netting_agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Netting Agreement Type');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `netting_agreement_type` SET TAGS ('dbx_value_regex' = 'full|partial|none');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `regulatory_body` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Body');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `regulatory_reporting_requirement` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Requirement');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `regulatory_reporting_requirement` SET TAGS ('dbx_value_regex' = 'EMIR|Dodd-Frank|MiFIDII|Other');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `termination_event_clauses` SET TAGS ('dbx_business_glossary_term' = 'Termination Event Clauses');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`collateral`.`isda_master` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Agreement Version Number');
ALTER TABLE `asset_management`.`collateral`.`csa` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`collateral`.`csa` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`csa` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`csa` SET TAGS ('dbx_subdomain' = 'agreement_documentation');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `csa_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) Identifier');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `isda_master_id` SET TAGS ('dbx_business_glossary_term' = 'Isda Master Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `netting_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Netting Agreement Identifier');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `valuation_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `amendment_date` SET TAGS ('dbx_business_glossary_term' = 'CSA Amendment Date');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'CSA Amendment Number');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `collateral_valuation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Collateral Valuation Frequency');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `collateral_valuation_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `collateral_valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Collateral Valuation Method');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `collateral_valuation_method` SET TAGS ('dbx_value_regex' = 'mark_to_market|mark_to_model|price_source');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `collateral_valuation_source` SET TAGS ('dbx_business_glossary_term' = 'Collateral Valuation Source');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `collateral_valuation_source` SET TAGS ('dbx_value_regex' = 'internal|external|third_party');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `credit_limit` SET TAGS ('dbx_business_glossary_term' = 'Credit Limit');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `credit_limit_currency` SET TAGS ('dbx_business_glossary_term' = 'Credit Limit Currency');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `credit_limit_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `csa_status` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) Status');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `csa_status` SET TAGS ('dbx_value_regex' = 'draft|active|suspended|terminated|expired');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `csa_type` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) Type');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `csa_type` SET TAGS ('dbx_value_regex' = 'english_law|new_york_law|isda_2016_vm');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `csa_description` SET TAGS ('dbx_business_glossary_term' = 'CSA Description');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'CSA Effective Start Date');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'CSA Effective End Date');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `eligible_collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Eligible Collateral Type');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `eligible_collateral_type` SET TAGS ('dbx_value_regex' = 'cash|government_bonds|equity|real_estate|commodities|other');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `governing_law` SET TAGS ('dbx_business_glossary_term' = 'Governing Law');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `governing_law` SET TAGS ('dbx_value_regex' = 'english|new_york|isda');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `independent_amount` SET TAGS ('dbx_business_glossary_term' = 'Independent Amount (IA)');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `independent_amount_currency` SET TAGS ('dbx_business_glossary_term' = 'Independent Amount Currency');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `independent_amount_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `is_eligible_for_clearing` SET TAGS ('dbx_business_glossary_term' = 'Clearing Eligibility Flag');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `is_margin_call_required` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Required Flag');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `margin_call_frequency` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Frequency');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `margin_call_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `minimum_transfer_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Transfer Amount (MTA)');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `minimum_transfer_currency` SET TAGS ('dbx_business_glossary_term' = 'Minimum Transfer Currency');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `minimum_transfer_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Credit Support Annex (CSA) Number');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'CSA Threshold Amount');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `threshold_currency` SET TAGS ('dbx_business_glossary_term' = 'CSA Threshold Currency');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `threshold_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `valuation_currency` SET TAGS ('dbx_business_glossary_term' = 'Collateral Valuation Currency');
ALTER TABLE `asset_management`.`collateral`.`csa` ALTER COLUMN `valuation_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` SET TAGS ('dbx_subdomain' = 'agreement_documentation');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `netting_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Netting Agreement Identifier');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `agreement_classification` SET TAGS ('dbx_business_glossary_term' = 'Agreement Classification');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `agreement_classification` SET TAGS ('dbx_value_regex' = 'bilateral|multilateral');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `agreement_number` SET TAGS ('dbx_business_glossary_term' = 'Netting Agreement Number');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `amendment_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Date');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Amendment Number');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `collateral_eligibility_criteria` SET TAGS ('dbx_business_glossary_term' = 'Collateral Eligibility Criteria');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'cash|securities|both');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Additional Comments');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `credit_limit` SET TAGS ('dbx_business_glossary_term' = 'Credit Limit');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `netting_agreement_description` SET TAGS ('dbx_business_glossary_term' = 'Agreement Description');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `governing_law` SET TAGS ('dbx_business_glossary_term' = 'Governing Law');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `margin_call_frequency` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Frequency');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `margin_call_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|ad_hoc');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `netting_agreement_status` SET TAGS ('dbx_business_glossary_term' = 'Netting Agreement Status');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `netting_agreement_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|terminated|draft');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `netting_type` SET TAGS ('dbx_business_glossary_term' = 'Netting Type');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `netting_type` SET TAGS ('dbx_value_regex' = 'close_out|payment|novation');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `product_scope` SET TAGS ('dbx_business_glossary_term' = 'Product Scope');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `product_scope` SET TAGS ('dbx_value_regex' = 'rates|fx|credit|equity|all');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `risk_weight` SET TAGS ('dbx_business_glossary_term' = 'Risk Weight');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_business_glossary_term' = 'Settlement Cycle');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_value_regex' = 'T+2|DVP|T+1|same_day');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `threshold_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Threshold Amount');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`collateral`.`netting_agreement` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` SET TAGS ('dbx_subdomain' = 'agreement_documentation');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `eligibility_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Schedule ID');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `agreement_csa_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement ID');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `csa_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement ID');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'government_bond|agency_bond|cash|equity|money_market_fund');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `collateral_category` SET TAGS ('dbx_business_glossary_term' = 'Collateral Category');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `collateral_category` SET TAGS ('dbx_value_regex' = 'primary|secondary|liquidity|haircut');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Currency (ISO 4217)');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `eligibility_schedule_description` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Schedule Description');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `eligibility_criteria` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Criteria');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `eligibility_status` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Status');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `eligibility_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|retired');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `haircut_percentage` SET TAGS ('dbx_business_glossary_term' = 'Haircut Percentage');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `is_marginable` SET TAGS ('dbx_business_glossary_term' = 'Marginable Flag');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `max_balance` SET TAGS ('dbx_business_glossary_term' = 'Maximum Balance Limit');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `min_balance` SET TAGS ('dbx_business_glossary_term' = 'Minimum Balance Requirement');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|annually');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `risk_weight` SET TAGS ('dbx_business_glossary_term' = 'Risk Weight');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `schedule_name` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Schedule Name');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`collateral`.`eligibility_schedule` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` SET TAGS ('dbx_subdomain' = 'counterparty_risk');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `credit_limit_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Limit ID');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By (Person)');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `breach_action` SET TAGS ('dbx_business_glossary_term' = 'Breach Action');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `breach_action` SET TAGS ('dbx_value_regex' = 'notify|reduce|close|escalate');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `breach_date` SET TAGS ('dbx_business_glossary_term' = 'Breach Date');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `breach_threshold` SET TAGS ('dbx_business_glossary_term' = 'Breach Threshold (%)');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `collateral_eligible` SET TAGS ('dbx_business_glossary_term' = 'Collateral Eligibility Flag');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `committee_name` SET TAGS ('dbx_business_glossary_term' = 'Approval Committee Name');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `credit_limit_status` SET TAGS ('dbx_business_glossary_term' = 'Credit Limit Status');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `credit_limit_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending|closed');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `credit_rating` SET TAGS ('dbx_business_glossary_term' = 'External Credit Rating (Agency)');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `emir_reporting_indicator` SET TAGS ('dbx_business_glossary_term' = 'EMIR Reporting Indicator');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `is_override` SET TAGS ('dbx_business_glossary_term' = 'Override Flag');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Approved Credit Limit Amount');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `limit_amount_usd` SET TAGS ('dbx_business_glossary_term' = 'Approved Credit Limit Amount (USD)');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `limit_category` SET TAGS ('dbx_business_glossary_term' = 'Credit Limit Category');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `limit_category` SET TAGS ('dbx_value_regex' = 'counterparty|portfolio|group');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `limit_change_reason` SET TAGS ('dbx_business_glossary_term' = 'Limit Change Reason');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `limit_currency` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `limit_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `limit_identifier` SET TAGS ('dbx_business_glossary_term' = 'Credit Limit Identifier (Code)');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `limit_identifier` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,20}$');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `limit_revision_number` SET TAGS ('dbx_business_glossary_term' = 'Limit Revision Number');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `limit_subtype` SET TAGS ('dbx_business_glossary_term' = 'Credit Limit Subtype');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `limit_type` SET TAGS ('dbx_business_glossary_term' = 'Credit Limit Type (Pre-Settlement, Settlement, Issuer, Aggregate)');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `limit_type` SET TAGS ('dbx_value_regex' = 'pre_settlement|settlement|issuer|aggregate');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `margin_call_threshold` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Threshold (%)');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `override_reason` SET TAGS ('dbx_business_glossary_term' = 'Override Reason');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `usage_amount` SET TAGS ('dbx_business_glossary_term' = 'Current Credit Usage Amount');
ALTER TABLE `asset_management`.`collateral`.`credit_limit` ALTER COLUMN `usage_percentage` SET TAGS ('dbx_business_glossary_term' = 'Credit Usage Percentage');
ALTER TABLE `asset_management`.`collateral`.`exposure` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`collateral`.`exposure` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`exposure` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`exposure` SET TAGS ('dbx_subdomain' = 'counterparty_risk');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `exposure_id` SET TAGS ('dbx_business_glossary_term' = 'Exposure ID');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `netting_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Netting Set ID');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Stress Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `exposure_category` SET TAGS ('dbx_business_glossary_term' = 'Exposure Category');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `exposure_category` SET TAGS ('dbx_value_regex' = 'derivative|securities|fx|commodity');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `collateral_held` SET TAGS ('dbx_business_glossary_term' = 'Collateral Held');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `collateral_usd` SET TAGS ('dbx_business_glossary_term' = 'Collateral Held (USD)');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `cvar` SET TAGS ('dbx_business_glossary_term' = 'Conditional Value at Risk (CVaR)');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `exposure_description` SET TAGS ('dbx_business_glossary_term' = 'Exposure Description');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `dv01` SET TAGS ('dbx_business_glossary_term' = 'Dollar Value of 01 (DV01)');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `exposure_status` SET TAGS ('dbx_business_glossary_term' = 'Exposure Status');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `exposure_status` SET TAGS ('dbx_value_regex' = 'active|estimated|final|closed');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `exposure_type` SET TAGS ('dbx_business_glossary_term' = 'Exposure Type');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `exposure_type` SET TAGS ('dbx_value_regex' = 'gross|net|collateralized|adjusted');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `gross_exposure_usd` SET TAGS ('dbx_business_glossary_term' = 'Gross Positive Exposure (USD)');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `gross_positive_exposure` SET TAGS ('dbx_business_glossary_term' = 'Gross Positive Exposure');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `is_approximate` SET TAGS ('dbx_business_glossary_term' = 'Is Approximate Flag');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `is_historical` SET TAGS ('dbx_business_glossary_term' = 'Is Historical Flag');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `last_margin_call_amount` SET TAGS ('dbx_business_glossary_term' = 'Last Margin Call Amount');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `last_margin_call_date` SET TAGS ('dbx_business_glossary_term' = 'Last Margin Call Date');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `margin_call_amount` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Amount');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `margin_call_flag` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Flag');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `net_exposure` SET TAGS ('dbx_business_glossary_term' = 'Net Exposure');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `net_exposure_after_collateral` SET TAGS ('dbx_business_glossary_term' = 'Net Exposure After Collateral');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `net_exposure_usd` SET TAGS ('dbx_business_glossary_term' = 'Net Exposure (USD)');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `netting_set_name` SET TAGS ('dbx_business_glossary_term' = 'Netting Set Name');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `reporting_period` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `reporting_period` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `risk_factor` SET TAGS ('dbx_business_glossary_term' = 'Risk Factor');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `risk_weight` SET TAGS ('dbx_business_glossary_term' = 'Risk Weight');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `valuation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Valuation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `var` SET TAGS ('dbx_business_glossary_term' = 'Value at Risk (VaR)');
ALTER TABLE `asset_management`.`collateral`.`exposure` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Exposure Version');
ALTER TABLE `asset_management`.`collateral`.`margin_call` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`collateral`.`margin_call` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`margin_call` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`margin_call` SET TAGS ('dbx_subdomain' = 'margin_operations');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `margin_call_id` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Identifier');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `collateral_account_id` SET TAGS ('dbx_business_glossary_term' = 'Collateral Account Identifier');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `csa_id` SET TAGS ('dbx_business_glossary_term' = 'Csa Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `party_counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `processed_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Processed By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `processed_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `processed_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `related_trade_blotter_id` SET TAGS ('dbx_business_glossary_term' = 'Related Trade Identifier');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Adjustment Amount');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `adjustment_reason` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Reason');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `call_amount` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Gross Amount');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `call_batch_reference` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Batch Identifier');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `call_currency` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Currency (ISO 4217)');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `call_date` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Date and Time');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `call_direction` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Direction');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `call_direction` SET TAGS ('dbx_value_regex' = 'issued|received');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `call_number` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Number');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `call_processed_flag` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Processed Indicator');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `call_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Sequence Number');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `collateral_amount` SET TAGS ('dbx_business_glossary_term' = 'Collateral Amount');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `collateral_currency` SET TAGS ('dbx_business_glossary_term' = 'Collateral Currency (ISO 4217)');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'cash|securities|other');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Comments');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Due Date');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Currency Exchange Rate');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `exchange_rate_date` SET TAGS ('dbx_business_glossary_term' = 'Exchange Rate Date');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `external_reference` SET TAGS ('dbx_business_glossary_term' = 'External System Reference');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `interest_rate` SET TAGS ('dbx_business_glossary_term' = 'Margin Interest Rate');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `interest_rate_type` SET TAGS ('dbx_business_glossary_term' = 'Interest Rate Type');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `interest_rate_type` SET TAGS ('dbx_value_regex' = 'fixed|floating');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `margin_call_status` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Status');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `margin_call_status` SET TAGS ('dbx_value_regex' = 'pending|processed|settled|failed|cancelled');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `margin_type` SET TAGS ('dbx_business_glossary_term' = 'Margin Type (Variation Margin or Initial Margin)');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `margin_type` SET TAGS ('dbx_value_regex' = 'VM|IM');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Net Amount');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `net_currency` SET TAGS ('dbx_business_glossary_term' = 'Net Amount Currency (ISO 4217)');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `processed_by` SET TAGS ('dbx_business_glossary_term' = 'Processed By User Identifier');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `processed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Processed Timestamp');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `regulatory_report_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Indicator');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `regulatory_report_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Status');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `regulatory_report_status` SET TAGS ('dbx_value_regex' = 'not_reported|reported|error');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Settlement Date');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `valuation_amount` SET TAGS ('dbx_business_glossary_term' = 'Margin Valuation Amount');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `valuation_currency` SET TAGS ('dbx_business_glossary_term' = 'Valuation Currency (ISO 4217)');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Margin Valuation Date');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Margin Valuation Method');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'mark_to_market|model_based|other');
ALTER TABLE `asset_management`.`collateral`.`margin_call` ALTER COLUMN `valuation_source` SET TAGS ('dbx_business_glossary_term' = 'Valuation Data Source');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` SET TAGS ('dbx_subdomain' = 'margin_operations');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `margin_dispute_id` SET TAGS ('dbx_business_glossary_term' = 'Margin Dispute Identifier');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `margin_call_id` SET TAGS ('dbx_business_glossary_term' = 'Related Margin Call Identifier');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Additional Comments');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `dispute_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Date and Time');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `dispute_initiator` SET TAGS ('dbx_business_glossary_term' = 'Dispute Initiator');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `dispute_initiator` SET TAGS ('dbx_value_regex' = 'counterparty|fund');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `dispute_number` SET TAGS ('dbx_business_glossary_term' = 'Dispute Number');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_value_regex' = 'valuation_difference|eligibility_disagreement|haircut_dispute|other');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `disputed_amount` SET TAGS ('dbx_business_glossary_term' = 'Disputed Amount (Monetary Value)');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `disputed_currency` SET TAGS ('dbx_business_glossary_term' = 'Disputed Amount Currency (ISO 4217 Code)');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `eligibility_flag` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Issue Flag');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `haircut_dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Haircut Dispute Flag');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `margin_dispute_status` SET TAGS ('dbx_business_glossary_term' = 'Dispute Lifecycle Status');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `margin_dispute_status` SET TAGS ('dbx_value_regex' = 'open|resolved|closed|rejected');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `resolution_amount` SET TAGS ('dbx_business_glossary_term' = 'Resolution Amount');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `resolution_currency` SET TAGS ('dbx_business_glossary_term' = 'Resolution Currency (ISO 4217 Code)');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Resolution Date');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `resolution_notes` SET TAGS ('dbx_business_glossary_term' = 'Resolution Notes');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `resolution_status` SET TAGS ('dbx_business_glossary_term' = 'Resolution Status');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `resolution_status` SET TAGS ('dbx_value_regex' = 'pending|accepted|rejected|settled');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date Used for Dispute');
ALTER TABLE `asset_management`.`collateral`.`posting` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`collateral`.`posting` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`posting` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`posting` SET TAGS ('dbx_subdomain' = 'margin_operations');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `posting_id` SET TAGS ('dbx_business_glossary_term' = 'Posting ID');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `collateral_position_id` SET TAGS ('dbx_business_glossary_term' = 'Collateral Position Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `margin_call_id` SET TAGS ('dbx_business_glossary_term' = 'Margin Call ID');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `asset_identifier` SET TAGS ('dbx_business_glossary_term' = 'Asset Identifier (ISIN/CUSIP)');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `asset_quantity` SET TAGS ('dbx_business_glossary_term' = 'Asset Quantity');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `asset_type` SET TAGS ('dbx_business_glossary_term' = 'Asset Type');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `asset_type` SET TAGS ('dbx_value_regex' = 'cash|government_bond|agency_bond|equity|other');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `asset_value` SET TAGS ('dbx_business_glossary_term' = 'Asset Market Value');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `collateral_quality` SET TAGS ('dbx_business_glossary_term' = 'Collateral Quality');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `collateral_quality` SET TAGS ('dbx_value_regex' = 'eligible|non_eligible|restricted');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `collateral_source` SET TAGS ('dbx_business_glossary_term' = 'Collateral Source');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `collateral_source` SET TAGS ('dbx_value_regex' = 'cash|bond|equity|derivative');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Posting Comments');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|EUR|GBP|CAD|JPY|CHF');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `direction` SET TAGS ('dbx_business_glossary_term' = 'Posting Direction');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `direction` SET TAGS ('dbx_value_regex' = 'posted|received|returned');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Exchange Rate to Base Currency');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Posting Amount');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `haircut_percentage` SET TAGS ('dbx_business_glossary_term' = 'Haircut Percentage');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `internal_reference` SET TAGS ('dbx_business_glossary_term' = 'Internal Reference');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Posting Amount');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Posting Number (External)');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `posting_status` SET TAGS ('dbx_business_glossary_term' = 'Posting Status');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `posting_status` SET TAGS ('dbx_value_regex' = 'pending|posted|settled|cancelled|returned');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `regulatory_reported` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reported Flag');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'DVP|FOP|RTGS|wire|clearing_house');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `timestamp` SET TAGS ('dbx_business_glossary_term' = 'Posting Timestamp');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `asset_management`.`collateral`.`posting` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'market_price|model_price|independent_valuation');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` SET TAGS ('dbx_subdomain' = 'collateral_inventory');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `collateral_position_id` SET TAGS ('dbx_business_glossary_term' = 'Collateral Position ID');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `ccp_ccp_membership_id` SET TAGS ('dbx_business_glossary_term' = 'Central Counterparty ID');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `ccp_membership_id` SET TAGS ('dbx_business_glossary_term' = 'Central Counterparty ID');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `asset_cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `asset_cusip` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{9}$');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `asset_isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `asset_isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `asset_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Asset Type');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `asset_type` SET TAGS ('dbx_value_regex' = 'cash|security|repo|derivative');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `collateral_position_status` SET TAGS ('dbx_business_glossary_term' = 'Collateral Position Status');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `collateral_position_status` SET TAGS ('dbx_value_regex' = 'active|inactive|closed|pending');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'cash|securities|margin|other');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Currency (ISO 4217)');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `collateral_position_description` SET TAGS ('dbx_business_glossary_term' = 'Collateral Position Description');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Collateral Eligibility Indicator');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `haircut_percent` SET TAGS ('dbx_business_glossary_term' = 'Haircut Percentage');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `label` SET TAGS ('dbx_business_glossary_term' = 'Collateral Position Label');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `margin_call_flag` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Indicator');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `market_value` SET TAGS ('dbx_business_glossary_term' = 'Collateral Market Value');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `net_market_value` SET TAGS ('dbx_business_glossary_term' = 'Net Collateral Market Value');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `position_date` SET TAGS ('dbx_business_glossary_term' = 'Position Date');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `position_source` SET TAGS ('dbx_business_glossary_term' = 'Collateral Position Source');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `position_source` SET TAGS ('dbx_value_regex' = 'internal|external');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Collateral Quantity');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `reference` SET TAGS ('dbx_business_glossary_term' = 'Collateral Position Reference');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `regulatory_reportable_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reportable Indicator');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'mark_to_market|mark_to_model|price_source');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` SET TAGS ('dbx_subdomain' = 'agreement_documentation');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `ccp_membership_id` SET TAGS ('dbx_business_glossary_term' = 'CCP Membership Identifier');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `ccp_name` SET TAGS ('dbx_business_glossary_term' = 'Central Counterparty (CCP) Name');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `ccp_name` SET TAGS ('dbx_value_regex' = 'LCH|Eurex|CME|ICE|Clearstream');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `cleared_product` SET TAGS ('dbx_business_glossary_term' = 'Cleared Product Category');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `cleared_product` SET TAGS ('dbx_value_regex' = 'equities|fixed_income|derivatives|fx|commodities');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `clearing_broker_lei` SET TAGS ('dbx_business_glossary_term' = 'Clearing Broker Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `clearing_broker_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `clearing_broker_lei` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `clearing_broker_lei` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `collateral_eligible` SET TAGS ('dbx_business_glossary_term' = 'Collateral Eligibility Flag');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `collateral_type_allowed` SET TAGS ('dbx_business_glossary_term' = 'Allowed Collateral Types');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `collateral_type_allowed` SET TAGS ('dbx_value_regex' = 'cash|government_securities|corporate_bonds|equity|commodities');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `compliance_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Compliance Document Reference Identifier');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `credit_limit` SET TAGS ('dbx_business_glossary_term' = 'Credit Limit (Currency Amount)');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Amount (Currency)');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `fee_structure` SET TAGS ('dbx_business_glossary_term' = 'Fee Structure Type');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `fee_structure` SET TAGS ('dbx_value_regex' = 'flat|percentage|tiered');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `initial_margin_requirement` SET TAGS ('dbx_business_glossary_term' = 'Initial Margin Requirement (Currency Amount)');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction Country Code (ISO 3166-1 Alpha-3)');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `last_fee_assessed_date` SET TAGS ('dbx_business_glossary_term' = 'Last Fee Assessed Date');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `last_margin_call_amount` SET TAGS ('dbx_business_glossary_term' = 'Last Margin Call Amount (Currency)');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `last_margin_call_date` SET TAGS ('dbx_business_glossary_term' = 'Last Margin Call Date');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `margin_call_frequency` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Frequency');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `margin_call_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|ad_hoc');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `membership_status` SET TAGS ('dbx_business_glossary_term' = 'Membership Status');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `membership_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending|terminated');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `membership_type` SET TAGS ('dbx_business_glossary_term' = 'Membership Type (Direct or Client Clearing)');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `membership_type` SET TAGS ('dbx_value_regex' = 'direct|client|indirect');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `netting_agreement_flag` SET TAGS ('dbx_business_glossary_term' = 'Netting Agreement Presence Flag');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes or Comments');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `registration_date` SET TAGS ('dbx_business_glossary_term' = 'Membership Registration Date');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `regulatory_reporting_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Status');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `regulatory_reporting_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|pending_review');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `reporting_currency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Currency (ISO 4217 Code)');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `reporting_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `risk_weight` SET TAGS ('dbx_business_glossary_term' = 'Risk Weight Percentage');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_business_glossary_term' = 'Settlement Cycle (Trade Date Plus N)');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_value_regex' = 'T+1|T+2|T+3');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Membership Termination Date');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ALTER COLUMN `variation_margin_requirement` SET TAGS ('dbx_business_glossary_term' = 'Variation Margin Requirement (Currency Amount)');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` SET TAGS ('dbx_subdomain' = 'margin_operations');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `simm_calculation_id` SET TAGS ('dbx_business_glossary_term' = 'SIMM Calculation ID');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `netting_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Netting Agreement Identifier');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Calculation Method');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `calculation_method` SET TAGS ('dbx_value_regex' = 'standard|custom');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `calculation_number` SET TAGS ('dbx_business_glossary_term' = 'SIMM Calculation Number');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `calculation_source_system` SET TAGS ('dbx_business_glossary_term' = 'Calculation Source System');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `calculation_source_system` SET TAGS ('dbx_value_regex' = 'Aladdin|InHouse|Other');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `calculation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SIMM Calculation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `collateral_eligible` SET TAGS ('dbx_business_glossary_term' = 'Collateral Eligibility Flag');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `confidence_interval` SET TAGS ('dbx_business_glossary_term' = 'Confidence Interval Percentage');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `initial_margin_amount` SET TAGS ('dbx_business_glossary_term' = 'Initial Margin Amount');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `input_data_hash` SET TAGS ('dbx_business_glossary_term' = 'Input Data Hash');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `is_override` SET TAGS ('dbx_business_glossary_term' = 'Manual Override Flag');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `margin_adjustment` SET TAGS ('dbx_business_glossary_term' = 'Margin Adjustment Amount');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `margin_call_date` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Due Date');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `margin_call_required` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Required Flag');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `margin_currency` SET TAGS ('dbx_business_glossary_term' = 'Margin Currency (ISO 4217 Code)');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `margin_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `margin_factor` SET TAGS ('dbx_business_glossary_term' = 'Margin Factor');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `margin_type` SET TAGS ('dbx_business_glossary_term' = 'Margin Type');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `margin_type` SET TAGS ('dbx_value_regex' = 'initial|variation|both');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `model_version` SET TAGS ('dbx_business_glossary_term' = 'SIMM Model Version');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `net_margin_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Margin Amount');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `override_reason` SET TAGS ('dbx_business_glossary_term' = 'Manual Override Reason');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `regulatory_framework` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Framework');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `regulatory_framework` SET TAGS ('dbx_value_regex' = 'EMIR');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `regulatory_reportable` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reportable Flag');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `risk_class` SET TAGS ('dbx_business_glossary_term' = 'Risk Class');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `risk_class` SET TAGS ('dbx_value_regex' = 'interest_rate|credit|equity|commodity|fx|inflation');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `sensitivity_count` SET TAGS ('dbx_business_glossary_term' = 'Risk Factor Sensitivity Count');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `simm_calculation_status` SET TAGS ('dbx_business_glossary_term' = 'SIMM Calculation Status');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `simm_calculation_status` SET TAGS ('dbx_value_regex' = 'pending|running|completed|failed');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `total_risk_weight` SET TAGS ('dbx_business_glossary_term' = 'Total Risk Weight');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Calculation Record Version Number');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` SET TAGS ('dbx_subdomain' = 'collateral_inventory');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `repo_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Repo Transaction ID');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `broker_id` SET TAGS ('dbx_business_glossary_term' = 'Broker ID');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `ccp_membership_id` SET TAGS ('dbx_business_glossary_term' = 'Clearing House ID');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Identifier');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `legal_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity ID');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `repo_collateral_security_listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Collateral Security ID');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `repo_listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'Underlying Security ID');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `accrued_interest` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'cash|securities|other');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `collateral_value` SET TAGS ('dbx_business_glossary_term' = 'Collateral Market Value');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Transaction Currency');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `emir_reporting_status` SET TAGS ('dbx_business_glossary_term' = 'EMIR Reporting Status');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `emir_reporting_status` SET TAGS ('dbx_value_regex' = 'pending|submitted|rejected');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `external_trade_reference` SET TAGS ('dbx_business_glossary_term' = 'External Trade Identifier');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `haircut_percent` SET TAGS ('dbx_business_glossary_term' = 'Haircut Percentage');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `initial_margin_amount` SET TAGS ('dbx_business_glossary_term' = 'Initial Margin Amount');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `is_cleared` SET TAGS ('dbx_business_glossary_term' = 'Cleared Flag');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `is_closed` SET TAGS ('dbx_business_glossary_term' = 'Closed Flag');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `is_marginable` SET TAGS ('dbx_business_glossary_term' = 'Marginable Flag');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `is_open` SET TAGS ('dbx_business_glossary_term' = 'Open Flag');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `is_rehypothecated` SET TAGS ('dbx_business_glossary_term' = 'Rehypothecation Flag');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `is_secured` SET TAGS ('dbx_business_glossary_term' = 'Secured Flag');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Transaction Amount');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Transaction Notes');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `principal_amount` SET TAGS ('dbx_business_glossary_term' = 'Principal Amount');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `repo_rate` SET TAGS ('dbx_business_glossary_term' = 'Repo Interest Rate');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `repo_rate_type` SET TAGS ('dbx_business_glossary_term' = 'Repo Rate Type');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `repo_rate_type` SET TAGS ('dbx_value_regex' = 'fixed|floating');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `repo_term_days` SET TAGS ('dbx_business_glossary_term' = 'Repo Term (Days)');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `repo_trade_reference` SET TAGS ('dbx_business_glossary_term' = 'Repo Trade Identifier');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `repo_transaction_status` SET TAGS ('dbx_business_glossary_term' = 'Repo Transaction Status');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `repo_transaction_status` SET TAGS ('dbx_value_regex' = 'draft|open|settled|closed|cancelled');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `repo_type` SET TAGS ('dbx_business_glossary_term' = 'Repo Type');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `repo_type` SET TAGS ('dbx_value_regex' = 'repo|reverse_repo');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Settlement Amount');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `settlement_currency` SET TAGS ('dbx_business_glossary_term' = 'Settlement Currency');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'cash|securities|netting');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `tax_withholding_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Withholding Amount');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `tax_withholding_percent` SET TAGS ('dbx_business_glossary_term' = 'Tax Withholding Percentage');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'maturity|early_termination|default|call');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `trade_date` SET TAGS ('dbx_business_glossary_term' = 'Trade Date');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `trade_execution_venue` SET TAGS ('dbx_business_glossary_term' = 'Execution Venue');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `trade_execution_venue` SET TAGS ('dbx_value_regex' = 'exchange|OTC|ECN|dark_pool');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `transaction_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Transaction Timestamp');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ALTER COLUMN `variation_margin_amount` SET TAGS ('dbx_business_glossary_term' = 'Variation Margin Amount');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` SET TAGS ('dbx_subdomain' = 'collateral_inventory');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `securities_lending_id` SET TAGS ('dbx_business_glossary_term' = 'Securities Lending Transaction ID');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `listed_security_id` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `amendment_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Date');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Amendment Number');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `collateral_currency` SET TAGS ('dbx_business_glossary_term' = 'Collateral Currency (COLL_CURR)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `collateral_eligibility_criteria` SET TAGS ('dbx_business_glossary_term' = 'Collateral Eligibility Criteria');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type (COLL_TYPE)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'cash|government_bond|equity|other');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `collateral_value` SET TAGS ('dbx_business_glossary_term' = 'Collateral Value (COLL_VAL)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `credit_limit` SET TAGS ('dbx_business_glossary_term' = 'Credit Limit (CREDIT_LIMIT)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (CURR_CODE)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `securities_lending_description` SET TAGS ('dbx_business_glossary_term' = 'Loan Description');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Amount (FEE_AMT)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Fee Rate (FEE_RATE)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Amount (GROSS_AMT)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `loan_number` SET TAGS ('dbx_business_glossary_term' = 'Loan Number (LOAN_NUM)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `loan_open_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Loan Open Timestamp');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `loan_recall_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Loan Recall Timestamp');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `loan_return_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Loan Return Timestamp');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `loan_status` SET TAGS ('dbx_business_glossary_term' = 'Loan Status (LOAN_STATUS)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `loan_status` SET TAGS ('dbx_value_regex' = 'open|closed|recall|defaulted|terminated');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `loan_term_days` SET TAGS ('dbx_business_glossary_term' = 'Loan Term (TERM_DAYS)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `loan_type` SET TAGS ('dbx_business_glossary_term' = 'Loan Type (LOAN_TYPE)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `loan_type` SET TAGS ('dbx_value_regex' = 'securities_lending|repo|reverse_repo');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `margin_call_frequency` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Frequency (MARGIN_FREQ)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `margin_call_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|none');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Amount (NET_AMT)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `rebate_rate` SET TAGS ('dbx_business_glossary_term' = 'Rebate Rate (REBATE_RATE)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `risk_weight` SET TAGS ('dbx_business_glossary_term' = 'Risk Weight (RISK_WEIGHT)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `security_cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `security_cusip` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{9}$');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `security_quantity` SET TAGS ('dbx_business_glossary_term' = 'Security Quantity (SEC_QTY)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_business_glossary_term' = 'Settlement Cycle (SETTLE_CYCLE)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_value_regex' = 'T+2|T+1|same_day');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method (VAL_METHOD)');
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'market|model|price_source');
ALTER TABLE `asset_management`.`collateral`.`substitution` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`collateral`.`substitution` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`substitution` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`substitution` SET TAGS ('dbx_subdomain' = 'collateral_inventory');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `substitution_id` SET TAGS ('dbx_business_glossary_term' = 'Substitution ID');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `blotter_id` SET TAGS ('dbx_business_glossary_term' = 'Trade ID');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `collateral_position_id` SET TAGS ('dbx_business_glossary_term' = 'Old Collateral ID');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Audit User ID');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `margin_call_id` SET TAGS ('dbx_business_glossary_term' = 'Margin Call ID');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `new_collateral_collateral_position_id` SET TAGS ('dbx_business_glossary_term' = 'New Collateral ID');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `substitution_collateral_position_id` SET TAGS ('dbx_business_glossary_term' = 'Old Collateral ID');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `substitution_new_collateral_collateral_position_id` SET TAGS ('dbx_business_glossary_term' = 'New Collateral ID');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `audit_user_role` SET TAGS ('dbx_business_glossary_term' = 'Audit User Role');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `audit_user_role` SET TAGS ('dbx_value_regex' = 'trader|risk|operations|compliance');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `eligibility_flag` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Flag');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `execution_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Substitution Execution Timestamp');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `fee_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Fee Currency Code');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `fee_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `haircut_percent` SET TAGS ('dbx_business_glossary_term' = 'Haircut Percentage');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `is_automated` SET TAGS ('dbx_business_glossary_term' = 'Automation Flag');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `net_amount_change` SET TAGS ('dbx_business_glossary_term' = 'Net Amount Change');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `net_settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Settlement Amount');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `net_settlement_currency` SET TAGS ('dbx_business_glossary_term' = 'Net Settlement Currency');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `net_settlement_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `new_collateral_quantity` SET TAGS ('dbx_business_glossary_term' = 'New Collateral Quantity');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `new_collateral_value` SET TAGS ('dbx_business_glossary_term' = 'New Collateral Value');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Substitution Number');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `old_collateral_quantity` SET TAGS ('dbx_business_glossary_term' = 'Old Collateral Quantity');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `old_collateral_value` SET TAGS ('dbx_business_glossary_term' = 'Old Collateral Value');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `reason_code` SET TAGS ('dbx_business_glossary_term' = 'Substitution Reason Code');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `reason_code` SET TAGS ('dbx_value_regex' = 'risk|liquidity|regulatory|operational|client_request');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `reason_description` SET TAGS ('dbx_business_glossary_term' = 'Substitution Reason Description');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `request_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Substitution Request Timestamp');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `substitution_status` SET TAGS ('dbx_business_glossary_term' = 'Substitution Status');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `substitution_status` SET TAGS ('dbx_value_regex' = 'requested|approved|executed|rejected|cancelled');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `substitution_type` SET TAGS ('dbx_business_glossary_term' = 'Substitution Type');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `substitution_type` SET TAGS ('dbx_value_regex' = 'margin_call|portfolio_rebalance|regulatory_swap|voluntary');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `transaction_fee` SET TAGS ('dbx_business_glossary_term' = 'Transaction Fee');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `asset_management`.`collateral`.`substitution` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'market|model|independent|internal');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` SET TAGS ('dbx_subdomain' = 'counterparty_risk');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `credit_limit_breach_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Limit Breach ID');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `credit_limit_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Limit Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `limit_id` SET TAGS ('dbx_business_glossary_term' = 'Credit Limit Record ID');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `actual_exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Exposure Amount at Breach');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `breach_amount` SET TAGS ('dbx_business_glossary_term' = 'Breach Amount (Excess over Limit)');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `breach_number` SET TAGS ('dbx_business_glossary_term' = 'Breach Number');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `breach_percentage` SET TAGS ('dbx_business_glossary_term' = 'Breach Percentage of Approved Limit');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `breach_reason` SET TAGS ('dbx_business_glossary_term' = 'Reason for Credit Limit Breach');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `breach_resolution_deadline` SET TAGS ('dbx_business_glossary_term' = 'Breach Resolution Deadline Date');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `breach_resolved_flag` SET TAGS ('dbx_business_glossary_term' = 'Breach Resolved Flag');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `breach_resolved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Breach Resolved Timestamp');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `breach_severity` SET TAGS ('dbx_business_glossary_term' = 'Breach Severity Level');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `breach_severity` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `breach_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Breach Event Timestamp');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments and Notes');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `credit_limit_breach_status` SET TAGS ('dbx_business_glossary_term' = 'Breach Status');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `credit_limit_breach_status` SET TAGS ('dbx_value_regex' = 'open|resolved|closed|pending');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `credit_limit_breach_description` SET TAGS ('dbx_business_glossary_term' = 'Additional Description of Breach Event');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` SET TAGS ('dbx_subdomain' = 'margin_operations');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `emir_trade_report_id` SET TAGS ('dbx_business_glossary_term' = 'EMIR Trade Report Surrogate Identifier');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `amendment_indicator` SET TAGS ('dbx_business_glossary_term' = 'Amendment Indicator');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `clearing_house_lei` SET TAGS ('dbx_business_glossary_term' = 'Clearing House Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `collateral_eligible_flag` SET TAGS ('dbx_business_glossary_term' = 'Collateral Eligibility Flag');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `emir_trade_report_description` SET TAGS ('dbx_business_glossary_term' = 'Trade Description');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction (ISO 3166‑1 Alpha‑3)');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `margin_call_flag` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Flag');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `notional_amount` SET TAGS ('dbx_business_glossary_term' = 'Notional Amount');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `notional_currency` SET TAGS ('dbx_business_glossary_term' = 'Notional Currency (ISO 4217)');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `notional_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `price` SET TAGS ('dbx_business_glossary_term' = 'Trade Price');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `price_currency` SET TAGS ('dbx_business_glossary_term' = 'Price Currency (ISO 4217)');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `price_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `product_class` SET TAGS ('dbx_business_glossary_term' = 'Product Class');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `product_class` SET TAGS ('dbx_value_regex' = 'interest_rate|credit|equity|fx|commodity|inflation');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Quantity');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `report_date` SET TAGS ('dbx_business_glossary_term' = 'Report Submission Date');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `report_status` SET TAGS ('dbx_business_glossary_term' = 'Report Status');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `report_status` SET TAGS ('dbx_value_regex' = 'submitted|accepted|rejected|pending|error');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `reporting_entity_lei` SET TAGS ('dbx_business_glossary_term' = 'Reporting Entity Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `risk_weight` SET TAGS ('dbx_business_glossary_term' = 'Risk Weight');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `trade_status` SET TAGS ('dbx_business_glossary_term' = 'Trade Status');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `trade_status` SET TAGS ('dbx_value_regex' = 'executed|cleared|settled|failed|rejected|pending');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `trade_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Trade Execution Timestamp');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `trade_type` SET TAGS ('dbx_business_glossary_term' = 'Trade Type');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `trade_type` SET TAGS ('dbx_value_regex' = 'swap|option|forward|future|credit_derivative|interest_rate_derivative');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `trade_venue` SET TAGS ('dbx_business_glossary_term' = 'Trade Venue');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `upi` SET TAGS ('dbx_business_glossary_term' = 'Unique Product Identifier (UPI)');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `uti` SET TAGS ('dbx_business_glossary_term' = 'Unique Trade Identifier (UTI)');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'mark_to_market|model_based|price_source|fallback');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `valuation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Valuation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Report Version Number');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` SET TAGS ('dbx_subdomain' = 'collateral_inventory');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `ssi_registry_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Settlement Instructions Registry ID');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `account_number` SET TAGS ('dbx_business_glossary_term' = 'Settlement Account Number');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `asset_type` SET TAGS ('dbx_business_glossary_term' = 'Asset Type');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `asset_type` SET TAGS ('dbx_value_regex' = 'equity|fixed_income|real_estate|private_equity|infrastructure|cash');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `collateral_type` SET TAGS ('dbx_business_glossary_term' = 'Collateral Type');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `collateral_type` SET TAGS ('dbx_value_regex' = 'cash|securities|guarantee|letter_of_credit|insurance|other');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|EUR|GBP|CAD|JPY|CHF');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `custodian_bic` SET TAGS ('dbx_business_glossary_term' = 'Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `ssi_registry_description` SET TAGS ('dbx_business_glossary_term' = 'Description');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `eligibility_criteria` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Criteria');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `haircut_percentage` SET TAGS ('dbx_business_glossary_term' = 'Haircut Percentage');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `instruction_type` SET TAGS ('dbx_business_glossary_term' = 'Instruction Type (SSI Type)');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `instruction_type` SET TAGS ('dbx_value_regex' = 'ssi|settlement_instruction|payment_instruction');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `margin_call_frequency` SET TAGS ('dbx_business_glossary_term' = 'Margin Call Frequency');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `margin_call_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|ad_hoc|none');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `risk_weight` SET TAGS ('dbx_business_glossary_term' = 'Risk Weight');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_business_glossary_term' = 'Settlement Cycle');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `settlement_cycle` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|ad_hoc|none');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'DVP|FOP|RTGS|ACH|SWIFT|CLS');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `settlement_platform` SET TAGS ('dbx_business_glossary_term' = 'Settlement Platform');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `settlement_platform` SET TAGS ('dbx_value_regex' = 'Euroclear|Clearstream|DTCC|LCH|CME|ICE');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `ssi_code` SET TAGS ('dbx_business_glossary_term' = 'Standard Settlement Instruction Code');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `ssi_registry_status` SET TAGS ('dbx_business_glossary_term' = 'Instruction Status');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `ssi_registry_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|suspended|terminated');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `asset_management`.`collateral`.`ssi_registry` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Record Version');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` SET TAGS ('dbx_subdomain' = 'counterparty_risk');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `counterparty_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Rating ID');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `counterparty_rating_status` SET TAGS ('dbx_business_glossary_term' = 'Rating Status');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `is_historical` SET TAGS ('dbx_business_glossary_term' = 'Is Historical Flag');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `outlook` SET TAGS ('dbx_business_glossary_term' = 'Rating Outlook');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `prior_rating_value` SET TAGS ('dbx_business_glossary_term' = 'Prior Rating Value');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `rating_agency` SET TAGS ('dbx_business_glossary_term' = 'Rating Agency');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `rating_change_reason` SET TAGS ('dbx_business_glossary_term' = 'Rating Change Reason');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `rating_confidence_score` SET TAGS ('dbx_business_glossary_term' = 'Rating Confidence Score');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `rating_date` SET TAGS ('dbx_business_glossary_term' = 'Rating Date');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `rating_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Rating Effective Date');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `rating_expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Rating Expiration Date');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `rating_methodology` SET TAGS ('dbx_business_glossary_term' = 'Rating Methodology');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `rating_scale` SET TAGS ('dbx_business_glossary_term' = 'Rating Scale');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `rating_source` SET TAGS ('dbx_business_glossary_term' = 'Rating Source');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `rating_type` SET TAGS ('dbx_business_glossary_term' = 'Rating Type');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `rating_value` SET TAGS ('dbx_business_glossary_term' = 'Rating Value');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`collateral`.`counterparty_rating` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`collateral`.`recall` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`collateral`.`recall` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`recall` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`recall` SET TAGS ('dbx_subdomain' = 'collateral_inventory');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `recall_id` SET TAGS ('dbx_business_glossary_term' = 'Recall ID');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `collateral_position_id` SET TAGS ('dbx_business_glossary_term' = 'Collateral Position Id (Foreign Key)');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty ID');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `asset_identifier` SET TAGS ('dbx_business_glossary_term' = 'Asset Identifier (ISIN or CUSIP)');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `asset_type` SET TAGS ('dbx_business_glossary_term' = 'Asset Type');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `asset_type` SET TAGS ('dbx_value_regex' = 'cash|security|derivative|real_estate|commodity');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `recall_description` SET TAGS ('dbx_business_glossary_term' = 'Recall Description');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `haircut_percentage` SET TAGS ('dbx_business_glossary_term' = 'Haircut Percentage');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `is_historical` SET TAGS ('dbx_business_glossary_term' = 'Historical Record Flag');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Recall Amount');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `net_currency` SET TAGS ('dbx_business_glossary_term' = 'Net Currency (ISO 4217)');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `net_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Recall Number');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Recall Quantity');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `quantity_unit` SET TAGS ('dbx_business_glossary_term' = 'Quantity Unit');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `quantity_unit` SET TAGS ('dbx_value_regex' = 'shares|units|million_usd|kg');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `reason` SET TAGS ('dbx_business_glossary_term' = 'Recall Reason');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `reason` SET TAGS ('dbx_value_regex' = 'trade_maturity|rebalancing|substitution|margin_call|regulatory|other');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `recall_status` SET TAGS ('dbx_business_glossary_term' = 'Recall Status');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `recall_status` SET TAGS ('dbx_value_regex' = 'issued|pending|completed|rejected|cancelled');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `timestamp` SET TAGS ('dbx_business_glossary_term' = 'Recall Timestamp');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `valuation_amount` SET TAGS ('dbx_business_glossary_term' = 'Valuation Amount');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `valuation_currency` SET TAGS ('dbx_business_glossary_term' = 'Valuation Currency (ISO 4217)');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `valuation_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`collateral`.`recall` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Record Version');
ALTER TABLE `asset_management`.`collateral`.`counterparty_stress_result` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`collateral`.`counterparty_stress_result` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`counterparty_stress_result` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`counterparty_stress_result` SET TAGS ('dbx_subdomain' = 'counterparty_risk');
ALTER TABLE `asset_management`.`collateral`.`counterparty_stress_result` SET TAGS ('dbx_association_edges' = 'risk.stress_scenario,collateral.counterparty');
ALTER TABLE `asset_management`.`collateral`.`counterparty_stress_result` ALTER COLUMN `counterparty_stress_result_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Stress Result ID');
ALTER TABLE `asset_management`.`collateral`.`counterparty_stress_result` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Effective Date');
ALTER TABLE `asset_management`.`collateral`.`counterparty_stress_result` ALTER COLUMN `exposure_amount` SET TAGS ('dbx_business_glossary_term' = 'Scenario Exposure Amount');
ALTER TABLE `asset_management`.`collateral`.`counterparty_stress_result` ALTER COLUMN `exposure_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty_stress_result` ALTER COLUMN `margin_call_estimate` SET TAGS ('dbx_business_glossary_term' = 'Scenario Margin Call Estimate');
ALTER TABLE `asset_management`.`collateral`.`counterparty_stress_result` ALTER COLUMN `margin_call_estimate` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`collateral`.`counterparty_stress_result` ALTER COLUMN `pnl_impact` SET TAGS ('dbx_business_glossary_term' = 'Scenario P&L Impact');
ALTER TABLE `asset_management`.`collateral`.`counterparty_stress_result` ALTER COLUMN `pnl_impact` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`collateral`.`collateral_account` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`collateral`.`collateral_account` SET TAGS ('dbx_domain' = 'collateral');
ALTER TABLE `asset_management`.`collateral`.`collateral_account` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`collateral`.`collateral_account` SET TAGS ('dbx_subdomain' = 'collateral_inventory');
ALTER TABLE `asset_management`.`collateral`.`collateral_account` ALTER COLUMN `collateral_account_id` SET TAGS ('dbx_business_glossary_term' = 'Collateral Account Identifier');
ALTER TABLE `asset_management`.`collateral`.`collateral_account` ALTER COLUMN `credit_limit_amount` SET TAGS ('dbx_confidential' = 'true');
