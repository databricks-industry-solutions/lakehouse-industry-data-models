-- Schema for Domain: manager | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:27

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`manager` COMMENT 'Domain for external fund manager selection, mandate management, and ongoing manager oversight. Owns manager profiles, RFP processes, mandate terms (LPAs, SMAs, co-investment agreements), SLA tracking, manager performance evaluation, fee schedules, and';
ALTER SCHEMA `asset_management`.`manager` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `asset_management`.`manager` SET TAGS ('dbx_domain' = 'manager');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`manager`.`gp_profile` (
    `gp_profile_id` BIGINT COMMENT 'Unique surrogate identifier for each external General Partner (GP), sub-advisor, or Fund-of-Funds manager record in the Silver layer. Primary key for the gp_profile master entity.',
    `framework_id` BIGINT COMMENT 'Foreign key linking to the ESG framework against which compliance is tracked',
    `strategy_id` BIGINT COMMENT 'Foreign key linking to manager.strategy. Business justification: gp_profile.primary_strategy is a string that duplicates strategy information; replacing it with a FK to strategy.strategy_id normalizes the data and removes redundancy.',
    `adoption_date` DATE COMMENT 'Date on which the GP formally adopted or committed to this ESG framework. Used to assess maturity of ESG integration.',
    `approved_mandate_types` STRING COMMENT 'Comma-separated list of mandate types for which this GP is approved (e.g., LP fund commitment, co-investment, SMA, advisory). Constrains permissible transaction types in the deal pipeline.',
    `asset_class` STRING COMMENT 'Broad asset class bucket to which the GPs strategy belongs, aligned with the pension funds Strategic Asset Allocation (SAA) framework and portfolio construction taxonomy.',
    `aum_reporting_date` DATE COMMENT 'Date as of which the reported AUM figure was calculated or disclosed by the GP. Required to assess data currency and staleness for manager monitoring purposes.',
    `aum_usd` DECIMAL(20,2) COMMENT 'Total Assets Under Management (AUM) reported by the GP firm in USD as of the most recent reporting date. Key sizing metric for manager selection, capacity constraints, and peer benchmarking.',
    `carried_interest_rate` DECIMAL(6,4) COMMENT 'Standard carried interest (Carry) rate charged by the GP on profits above the hurdle rate (e.g., 0.2000 = 20%). Core economic term in LPA fee structure analysis and net return modeling.',
    `certification_status` STRING COMMENT 'Status of formal certification or verification under this framework: certified (valid certification), pending (certification in progress), expired (certification lapsed), not_applicable (framework does not offer certification).',
    `co_invest_rights_flag` BOOLEAN COMMENT 'Indicates whether the pension fund has secured co-investment rights with this GP, enabling direct participation in individual deals alongside the fund. Key for deal origination pipeline.',
    `compliance_level` STRING COMMENT 'Current level of GP compliance with the framework requirements: full (meets all requirements), partial (meets some requirements), non_compliant (does not meet requirements), in_progress (actively working toward compliance).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the GP profile record was first created in the Silver layer data product. Provides the audit trail creation anchor for data lineage and governance compliance.',
    `domicile_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction where the GP firm is legally domiciled. Used for regulatory classification, tax treaty analysis, and FATF AML risk assessment.. Valid values are `^[A-Z]{3}$`',
    `dry_powder_usd` DECIMAL(20,2) COMMENT 'Total uncalled committed capital (Dry Powder) available to the GP across all active funds in USD. Indicates deployment capacity and competitive positioning for new deal origination.',
    `efront_manager_code` STRING COMMENT 'Unique manager identifier within the eFront private markets portfolio monitoring system, which serves as the operational system of record for private fund investment data and GP reporting.',
    `esg_policy_flag` BOOLEAN COMMENT 'Indicates whether the GP firm has a formally documented ESG policy integrated into its investment process. Required for PRI signatory screening and SFDR alignment assessment.',
    `firm_founded_year` BIGINT COMMENT 'Calendar year in which the GP firm was established. Used to assess organizational maturity, track record length, and key-person risk in manager due diligence.',
    `geographic_focus` STRING COMMENT 'Primary geographic region(s) targeted by the GPs investment strategy (e.g., North America, Europe, Asia-Pacific, Global). Used for geographic concentration risk monitoring and SAA alignment.',
    `headquarters_city` STRING COMMENT 'City where the GP firms principal office and investment decision-making team are located. Used for operational due diligence site visit planning and time-zone coordination.',
    `headquarters_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the GP firms principal office location. Used for regulatory jurisdiction mapping and FATF AML country risk scoring.. Valid values are `^[A-Z]{3}$`',
    `hurdle_rate` DECIMAL(6,4) COMMENT 'Preferred return threshold (Hurdle Rate) that must be achieved before the GP is entitled to carried interest (e.g., 0.0800 = 8%). Key economic term for net IRR modeling and LP/GP alignment assessment.',
    `ic_approval_date` DATE COMMENT 'Date on which the Investment Committee (IC) formally approved this GP for inclusion in the pension funds approved manager universe. Establishes the governance audit trail.',
    `key_person_clause_flag` BOOLEAN COMMENT 'Indicates whether the GPs fund agreements include a key-person clause that triggers suspension of the investment period upon departure of named key individuals. Critical governance risk indicator.',
    `kyc_next_review_date` DATE COMMENT 'Scheduled date for the next mandatory KYC/AML periodic review of this GP entity, based on risk-tiered review frequency defined in the AML compliance policy.',
    `kyc_review_date` DATE COMMENT 'Date on which the most recent KYC/AML periodic review was completed for this GP entity. Drives refresh scheduling and compliance monitoring alerts.',
    `kyc_status` STRING COMMENT 'Current status of the KYC/AML onboarding and periodic review process for the GP entity. Mandatory for counterparty onboarding under FATF, and internal AML compliance policy.. Valid values are `pending|in_progress|completed|expired|failed`',
    `last_assessment_date` DATE COMMENT 'Date of the most recent compliance assessment or review conducted by the pension fund or external assessor for this GP-framework combination.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the GP profile record in the Silver layer. Used for change detection, data freshness monitoring, and incremental ETL processing.',
    `legal_name` STRING COMMENT 'Full registered legal name of the GP firm as recorded in its jurisdiction of incorporation. Used for contract execution, regulatory filings, and KYC/AML documentation.',
    `lei` STRING COMMENT '20-character ISO 17442 Legal Entity Identifier assigned to the GP firm. Mandatory for OTC derivative reporting under EMIR and MiFID II counterparty identification.. Valid values are `^[A-Z0-9]{18}[0-9]{2}$`',
    `management_fee_rate` DECIMAL(6,4) COMMENT 'Standard annual management fee rate charged by the GP as a percentage of committed or invested capital (e.g., 0.0150 = 1.50%). Used for fee budget modeling and total cost of ownership analysis.',
    `manager_risk_rating` STRING COMMENT 'Internal risk rating assigned to the GP based on operational, financial, regulatory, and reputational risk assessment. Used for monitoring frequency tiering and mandate eligibility gating.. Valid values are `low|medium|high|watch_list`',
    `manager_status` STRING COMMENT 'Current lifecycle status of the GP relationship within the pension funds approved manager universe. Drives eligibility for new mandates and capital commitments.. Valid values are `active|under_review|approved|suspended|terminated|prospect`',
    `manager_type` STRING COMMENT 'Classification of the external manager relationship: General Partner (GP), sub-advisor, Fund-of-Funds (FoF) manager, co-investment manager, or Separately Managed Account (SMA) manager.. Valid values are `GP|sub_advisor|FoF_manager|co_invest_manager|SMA_manager`',
    `number_of_funds` BIGINT COMMENT 'Total count of investment funds currently managed or advised by the GP firm, including closed-end, open-end, and co-investment vehicles. Used for organizational complexity assessment.',
    `number_of_investment_professionals` BIGINT COMMENT 'Headcount of dedicated investment professionals (partners, principals, associates) at the GP firm. Key input for key-person risk assessment and operational due diligence.',
    `operational_due_diligence_date` DATE COMMENT 'Date on which the most recent Operational Due Diligence (ODD) review was completed for this GP. Tracks compliance with the pension funds periodic ODD refresh policy.',
    `pitchbook_manager_code` STRING COMMENT 'Unique manager identifier assigned by PitchBook, used for cross-referencing GP data, fund performance benchmarks, and deal flow analytics from the PitchBook platform.',
    `preferred_lp_terms_flag` BOOLEAN COMMENT 'Indicates whether the pension fund has negotiated preferred LP terms (e.g., reduced management fees, enhanced co-investment rights, MFN clause) with this GP. Drives fee administration and mandate tracking.',
    `preqin_manager_code` STRING COMMENT 'Unique manager identifier assigned by Preqin, the primary external market intelligence source for private markets manager data. Enables automated data enrichment and benchmarking feeds.',
    `pri_signatory_flag` BOOLEAN COMMENT 'Indicates whether the GP firm is a current signatory to the UN Principles for Responsible Investment (PRI). Used for ESG manager screening and responsible investment stewardship reporting.',
    `primary_contact_email` STRING COMMENT 'Email address of the primary relationship contact at the GP firm. Used for capital call notices, distribution announcements, and investor reporting communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_contact_name` STRING COMMENT 'Full name of the primary relationship contact at the GP firm (typically the Investor Relations lead or Partner responsible for the LP relationship). Used for capital call notices and reporting distribution.',
    `primary_regulator` STRING COMMENT 'Name of the primary regulatory body that supervises the GP firm (e.g., SEC, FCA, ESMA, MAS). Used for regulatory risk assessment and compliance monitoring.',
    `registration_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction where the GP firm is incorporated or registered. May differ from domicile for tax-efficient structures (e.g., Cayman Islands).. Valid values are `^[A-Z]{3}$`',
    `regulatory_registration_number` STRING COMMENT 'Primary regulatory registration or licence number issued by the GPs home regulator (e.g., SEC CRD number, FCA FRN registration). Required for KYC and counterparty onboarding.',
    `relationship_inception_date` DATE COMMENT 'Date on which the pension fund first established a formal investment relationship with this GP (first capital commitment or mandate execution). Measures relationship tenure for loyalty and negotiation leverage.',
    `relationship_termination_date` DATE COMMENT 'Date on which the pension fund formally terminated its investment relationship with this GP. Null for active relationships. Used for historical manager universe reporting and post-mortem analysis.',
    `short_name` STRING COMMENT 'Commonly used abbreviated or trading name of the GP firm, used in internal reporting, dashboards, and investment committee materials for brevity.',
    `sub_strategy` STRING COMMENT 'More granular strategy classification within the primary asset class (e.g., large-cap buyout, core-plus real estate, greenfield infrastructure, direct lending). Used for portfolio diversification analysis.',
    `tcfd_aligned_flag` BOOLEAN COMMENT 'Indicates whether the GP firms reporting is aligned with TCFD recommendations for climate-related financial disclosures. Required for pension funds climate risk stewardship obligations.',
    `track_record_years` BIGINT COMMENT 'Number of years of audited investment performance track record available for the GP firm. Minimum track record thresholds are defined in the pension funds manager selection policy.',
    `vintage_year_first` BIGINT COMMENT 'Earliest vintage year of a fund managed by the GP for which performance track record data is available. Defines the start of the GPs measurable investment history for IRR and MOIC benchmarking.',
    `vintage_year_latest` BIGINT COMMENT 'Most recent vintage year of a fund managed by the GP. Used to assess recency of deployment activity and alignment with current market cycle positioning.',
    CONSTRAINT pk_gp_profile PRIMARY KEY(`gp_profile_id`)
) COMMENT 'Master SSOT record for each external General Partner (GP), sub-advisor, or Fund-of-Funds manager relationship. Captures manager identity, legal entity details, LEI, domicile, AUM, strategy focus, vintage coverage, and operational status, PLUS the';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`manager_mandate` (
    `manager_mandate_id` BIGINT COMMENT 'Unique surrogate identifier for each investment mandate awarded to an external manager. Primary key for the manager_mandate product in the Silver layer.',
    `custodian_id` BIGINT COMMENT 'Reference to the custodian or fund administrator responsible for safekeeping assets and NAV calculation under this mandate (e.g., State Street, Northern Trust). Links to the counterparty master.',
    `esg_policy_id` BIGINT COMMENT 'Foreign key linking to esg.policy. Business justification: Mandates must comply with specific ESG policies governing investment restrictions and engagement requirements.',
    `exclusion_list_id` BIGINT COMMENT 'Foreign key linking to esg.exclusion_list. Business justification: Mandates reference specific exclusion lists defining prohibited investments. Business process: Compliance monitoring ensures managers avoid excluded securities per mandate terms.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (GP, sub-advisor, or FoF manager) to whom this mandate has been awarded. Links to the manager master record.',
    `ic_approval_ic_decision_id` BIGINT COMMENT 'Reference to the Investment Committee approval record that authorized this mandate. Links to the IC governance record in Diligent/BoardEffect.',
    `ic_decision_id` BIGINT COMMENT 'Reference to the Investment Committee approval record that authorized this mandate. Links to the IC governance record in Diligent/BoardEffect.',
    `investment_strategy_id` BIGINT COMMENT 'Foreign key linking to manager.strategy. Business justification: manager_mandate.investment_strategy is a string that duplicates strategy information; replacing it with a FK to strategy.strategy_id normalizes the data and removes redundancy.',
    `manager_benchmark_id` BIGINT COMMENT 'Reference to the performance benchmark assigned to this mandate (e.g., MSCI World, CPI+4%, Cambridge Associates PE Benchmark). Used for TWR/MWR attribution and GIPS-compliant reporting.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (GP, sub-advisor, or FoF manager) to whom this mandate has been awarded. Links to the manager master record.',
    `portfolio_id` BIGINT COMMENT 'Reference to the internal investment portfolio or fund sleeve to which this mandate is allocated. Links to the portfolio master record in SimCorp Dimension.',
    `sfdr_disclosure_id` BIGINT COMMENT 'Foreign key linking to compliance.sfdr_disclosure. Business justification: EU SFDR requires disclosure filings per investment mandate. Links mandate to its regulatory disclosure record for Article 6/8/9 classification reporting.',
    `valuation_policy_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_policy. Business justification: LPAs and mandate agreements specify valuation methodology requirements (IPEV, GIPS compliance).',
    `asset_class` STRING COMMENT 'Primary asset class covered by this mandate (e.g., Private Equity, Real Estate, Infrastructure, Natural Resources, Public Equities, Credit). [ENUM-REF-CANDIDATE',
    `carried_interest_rate` DECIMAL(8,6) COMMENT 'GPs share of profits above the hurdle rate, expressed as a decimal (e.g., 0.20 = 20% carry). Key fee term sourced from LPA. Used in fee administration and carry accrual calculations.',
    `co_investment_rights` BOOLEAN COMMENT 'Indicates whether the mandate agreement grants the pension fund co-investment rights alongside the GPs fund investments. Co-invest rights are a key negotiated term for large LP commitments.',
    `commitment_amount` DECIMAL(22,4) COMMENT 'Total capital committed by the pension fund to this mandate in the mandate currency. Represents the maximum obligation (dry powder + deployed capital). Key input to SAA and liquidity planning.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this mandate record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Provides audit trail for mandate origination and data lineage.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the mandate is denominated (e.g., USD, EUR, GBP). Used for capital call processing, NAV reporting, and FX hedging decisions.. Valid values are `^[A-Z]{3}$`',
    `domicile_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code where the fund or mandate vehicle is legally domiciled (e.g., CYM for Cayman Islands, LUX for Luxembourg). Relevant for tax treaty and regulatory treatment.. Valid values are `^[A-Z]{3}$`',
    `effective_date` DATE COMMENT 'Date on which the mandate became legally binding and operationally effective. For LP funds, typically the fund closing date. For SMAs, the agreement execution date.',
    `esg_integration_level` STRING COMMENT 'Degree to which Environmental, Social, and Governance (ESG) factors are integrated into the mandates investment process: FULL (systematic ESG scoring), PARTIAL (considered but not scored), EXCLUSIONS_ONLY, or NONE.. Valid values are `FULL|PARTIAL|EXCLUSIONS_ONLY|NONE`',
    `expiry_date` DATE COMMENT 'Contractual end date of the mandate. For LP funds, the fund term end date (including extensions). For SMAs, the agreement termination date. Null for open-ended mandates.',
    `geographic_focus` STRING COMMENT 'Primary geographic region or country focus of the mandate (e.g., North America, Europe, Asia-Pacific, Global, GBR). Expressed as region name or ISO 3166-1 alpha-3 country code where single-country.',
    `governing_law_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction whose laws govern the mandate agreement (e.g., CAN, USA, GBR, LUX). Critical for legal enforceability and regulatory reporting.. Valid values are `^[A-Z]{3}$`',
    `hurdle_rate` DECIMAL(8,6) COMMENT 'Minimum preferred return threshold (as a decimal, e.g., 0.08 = 8%) that must be achieved before the GP is entitled to carried interest. Sourced from LPA or SMA agreement.',
    `investment_period_end_date` DATE COMMENT 'Date on which the GPs right to make new investments (deploy capital) expires. After this date, the fund enters harvest/realization phase. Specific to LP fund commitments.',
    `key_person_clause` BOOLEAN COMMENT 'Indicates whether the LPA or SMA includes a key person clause that suspends the investment period or triggers LP consent rights if named key investment professionals depart the GP.',
    `last_odd_review_date` DATE COMMENT 'Date of the most recent Operational Due Diligence (ODD) review conducted on the external manager for this mandate. Drives scheduling of next review per internal ODD policy.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this mandate record, in ISO 8601 format. Used for change data capture, audit trails, and Silver layer incremental processing in Databricks.',
    `lock_up_period_months` BIGINT COMMENT 'Number of months during which the pension fund cannot redeem or transfer its interest in the mandate. Relevant for hedge funds and open-ended private market vehicles. Zero for fully liquid mandates.',
    `lp_advisory_committee_seat` BOOLEAN COMMENT 'Indicates whether the pension fund holds a seat on the LP Advisory Committee (LPAC) for this fund mandate, granting governance rights over conflicts of interest and valuation matters.',
    `lpa_reference_number` STRING COMMENT 'Unique reference number of the executed Limited Partnership Agreement or SMA contract document. Used to cross-reference legal documents in the document management system.',
    `management_fee_basis` STRING COMMENT 'The base on which the management fee is calculated: Committed Capital (during investment period), Invested Capital (post-investment period), NAV, or AUM. Sourced from LPA.. Valid values are `COMMITTED_CAPITAL|INVESTED_CAPITAL|NAV|AUM`',
    `management_fee_rate` DECIMAL(8,6) COMMENT 'Annual management fee charged by the external manager as a decimal fraction of committed or invested capital (e.g., 0.015 = 1.5%). Sourced from LPA or SMA fee schedule.',
    `manager_risk_rating` STRING COMMENT 'Internal risk rating assigned to the external manager for this mandate, reflecting ODD findings, key person risk, operational controls, and financial stability. Drives oversight intensity.. Valid values are `LOW|MEDIUM|HIGH|WATCH_LIST|TERMINATED`',
    `mandate_name` STRING COMMENT 'Human-readable descriptive name of the mandate, typically combining manager name, strategy, and vintage year (e.g., Blackstone Real Estate Partners X - LP Commitment 2022).',
    `mandate_status` STRING COMMENT 'Current lifecycle state of the mandate. DRAFT=under negotiation, ACTIVE=deployed and operational, SUSPENDED=temporarily halted, TERMINATED=contractually ended, EXPIRED=term lapsed, PENDING_CLOSE=wind-down in progress.. Valid values are `DRAFT|ACTIVE|SUSPENDED|TERMINATED|EXPIRED|PENDING_CLOSE`',
    `mandate_type` STRING COMMENT 'Classification of the mandate structure: LP Fund Commitment (limited partnership), Separately Managed Account (SMA), Co-Investment agreement, Fund of Funds (FoF), or Advisory.. Valid values are `LP_FUND_COMMITMENT|SMA|CO_INVESTMENT|FOF|ADVISORY`',
    `max_allocation_pct` DECIMAL(8,6) COMMENT 'Maximum permissible portfolio weight for this mandate per investment guidelines. Breach triggers a compliance alert. Expressed as a decimal fraction of total AUM.',
    `max_extension_years` BIGINT COMMENT 'Maximum number of years by which the mandate term can be extended under the contractual extension option. Typically 1 or 2 years for PE/RE/Infrastructure LP funds.',
    `min_allocation_pct` DECIMAL(8,6) COMMENT 'Minimum permissible portfolio weight for this mandate per investment guidelines. Breach triggers a rebalancing review. Expressed as a decimal fraction of total AUM.',
    `most_favored_nation_flag` BOOLEAN COMMENT 'Indicates whether the pension fund has negotiated Most Favored Nation (MFN) status, entitling it to the most favorable fee terms offered to any LP in the fund.',
    `next_odd_review_date` DATE COMMENT 'Scheduled date for the next Operational Due Diligence (ODD) review of the external manager. Determined by manager risk rating and internal ODD review cycle policy.',
    `redemption_notice_days` BIGINT COMMENT 'Number of calendar days notice required to redeem or withdraw capital from this mandate. Applicable primarily to open-ended funds, hedge funds, and liquid SMAs. Null for closed-end LP funds.',
    `reference_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this mandate across internal systems (SimCorp, eFront, Dealpath). Used in counterparty correspondence and regulatory reporting.. Valid values are `^[A-Z]{2,6}-[A-Z0-9]{4,12}-[0-9]{4}$`',
    `reporting_frequency` STRING COMMENT 'Frequency at which the external manager is contractually required to provide performance, portfolio, and financial reports to the pension fund. Sourced from LPA or SMA reporting schedule.. Valid values are `MONTHLY|QUARTERLY|SEMI_ANNUAL|ANNUAL`',
    `sla_reporting_breach_flag` BOOLEAN COMMENT 'Indicates whether the external manager is currently in breach of contractual SLA reporting obligations (e.g., late quarterly reports, missing capital account statements). Triggers manager oversight review.',
    `sub_asset_class` STRING COMMENT 'Granular sub-classification within the asset class (e.g., Buyout, Venture Capital, Core Real Estate, Value-Add, Senior Infrastructure, Direct Lending, High Yield). Supports portfolio construction and attribution.',
    `target_allocation_amount` DECIMAL(22,4) COMMENT 'Target dollar allocation to this mandate as determined by the SAA/TAA process. May differ from commitment_amount for LP funds where deployment is phased over the investment period.',
    `target_allocation_pct` DECIMAL(8,6) COMMENT 'Target portfolio weight for this mandate expressed as a decimal fraction of total AUM (e.g., 0.025 = 2.5%). Used in SAA compliance monitoring and rebalancing triggers.',
    `term_extension_option` BOOLEAN COMMENT 'Indicates whether the LPA or SMA agreement includes an option to extend the mandate term beyond the initial expiry date (typically 1+1 year extensions for PE funds).',
    `valuation_methodology` STRING COMMENT 'Primary valuation methodology applied to assets held under this mandate. Determines how NAV/GAV is calculated for illiquid private assets. Sourced from LPA or fund governing documents.. Valid values are `FAIR_VALUE|COST|NAV|MARK_TO_MARKET|MARK_TO_MODEL`',
    `vintage_year` BIGINT COMMENT 'The calendar year in which the funds first capital call was made or the mandate was first funded. Critical for benchmarking PE/VC/RE fund performance against peers of the same vintage.',
    CONSTRAINT pk_manager_mandate PRIMARY KEY(`manager_mandate_id`)
) COMMENT 'Authoritative record of each investment mandate awarded to an external manager, covering mandate type (LP fund commitment, SMA, co-investment agreement, FoF), asset class, strategy, target allocation, benchmark, investment guidelines, and contractual term';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`rfp` (
    `rfp_id` BIGINT COMMENT 'Unique system-generated identifier for each Request for Proposal or Request for Information issued to external managers during the manager selection process.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager, General Partner (GP), or sub-advisor to whom this RFP/RFI was issued. Null if issued to multiple or unspecified managers.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager, General Partner (GP), or sub-advisor to whom this RFP/RFI was issued. Null if issued to multiple or unspecified managers.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the investment mandate or mandate opportunity that this RFP/RFI is intended to fill. Links the sourcing process to the resulting mandate if awarded.',
    `performance_benchmark_id` BIGINT COMMENT 'Foreign key linking to performance.performance_benchmark. Business justification: RFP manager selection process specifies benchmark requirements for evaluating manager proposals.',
    `asset_class` STRING COMMENT 'Primary asset class targeted by this RFP (e.g., Public Equities, Private Equity, Real Estate, Infrastructure, Natural Resources, Credit). [ENUM-REF-CANDIDATE: public_equities|private_equity|real_estate|infrastructure|natural_resources|credit|multi_asset —',
    `award_target_date` DATE COMMENT 'Target date by which the RFP evaluation is expected to conclude and a mandate award decision is expected to be communicated to the selected manager.',
    `closed_date` DATE COMMENT 'The actual date on which the RFP process was formally closed, either through award, cancellation, or withdrawal. Null if still active.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this RFP record was first created in the system, used for audit trail and data lineage purposes. Conforms to ISO 8601 format.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the mandate size and AUM thresholds stated in this RFP (e.g., USD, GBP, EUR).. Valid values are `^[A-Z]{3}$`',
    `distribution_channel` STRING COMMENT 'Channel through which the RFP was distributed to prospective managers: directly, via investment consultant, through an intermediary, public tender, or manager platform.. Valid values are `direct|intermediary|consultant|public_tender|platform`',
    `esg_framework` STRING COMMENT 'Specific ESG framework or standard the manager is required or expected to adhere to (e.g., PRI, TCFD, SFDR Article 8/9, GHG Protocol, UNPRI signatory status).',
    `esg_requirement` STRING COMMENT 'Specifies whether ESG (Environmental, Social, and Governance) integration by the responding manager is mandatory, preferred, or not required for this mandate.. Valid values are `mandatory|preferred|not_required`',
    `evaluation_start_date` DATE COMMENT 'The date on which the formal evaluation and scoring of received manager responses commences following the response deadline.',
    `geography` STRING COMMENT 'Geographic scope or target region for the mandate being sought (e.g., Global, North America, Europe, Asia-Pacific). Uses ISO 3166-1 alpha-3 country codes or regional descriptors.',
    `gips_compliance_required` BOOLEAN COMMENT 'Indicates whether responding managers are required to be compliant with CFA Institute Global Investment Performance Standards (GIPS) for performance reporting.',
    `hurdle_rate` DECIMAL(8,4) COMMENT 'Minimum required rate of return (preferred return threshold) specified in the RFP that the selected manager must achieve before carried interest or performance fees are earned.',
    `ic_approval_required` BOOLEAN COMMENT 'Indicates whether the final manager selection and mandate award resulting from this RFP requires formal Investment Committee (IC) approval before execution.',
    `issuance_date` DATE COMMENT 'The date on which the RFP or RFI was formally issued and distributed to prospective external managers or the broader market.',
    `kyc_aml_required` BOOLEAN COMMENT 'Indicates whether responding managers must demonstrate Know Your Customer (KYC) and Anti-Money Laundering (AML) compliance as part of the RFP eligibility criteria.',
    `lead_analyst` STRING COMMENT 'Name or identifier of the internal investment analyst or portfolio manager responsible for leading the RFP evaluation process.',
    `mandate_size` DECIMAL(20,2) COMMENT 'Indicative capital commitment or mandate size being sought through this RFP, expressed in the mandate currency. Confidential as it reveals investment sizing intentions.',
    `min_strategy_aum` DECIMAL(20,2) COMMENT 'Minimum AUM specifically in the target strategy (not total firm AUM) required for a manager to be eligible to respond to this RFP.',
    `min_track_record_years` BIGINT COMMENT 'Minimum number of years of audited performance track record required from responding managers for the relevant strategy to be considered eligible.',
    `nda_required` BOOLEAN COMMENT 'Indicates whether a signed Non-Disclosure Agreement (NDA) is required from prospective managers before they may access the full RFP documentation.',
    `notes` STRING COMMENT 'Free-text field for internal notes, commentary, or supplementary context related to the RFP process, evaluation observations, or special considerations.',
    `reference_number` STRING COMMENT 'Externally communicated unique reference number assigned to this RFP/RFI, used in all correspondence with prospective managers and in procurement records.. Valid values are `^RFP-[0-9]{4}-[0-9]{5}$`',
    `response_deadline` DATE COMMENT 'The deadline by which prospective managers must submit their responses to the RFP or RFI. Responses received after this date are typically disqualified.',
    `responses_received` BIGINT COMMENT 'Total count of manager responses received by the response deadline. Used to assess market interest and competitiveness of the RFP process.',
    `rfp_status` STRING COMMENT 'Current lifecycle status of the RFP. Tracks progression from drafting through issuance, evaluation, and final award or cancellation. [ENUM-REF-CANDIDATE: draft|issued|under_review|shortlisted|awarded|cancelled|closed — promote to reference product]',
    `rfp_type` STRING COMMENT 'Classifies the solicitation document type: RFP (Request for Proposal), RFI (Request for Information), RFQ (Request for Quotation), or DDQ (Due Diligence Questionnaire).. Valid values are `RFP|RFI|RFQ|DDQ`',
    `shortlisted_count` BIGINT COMMENT 'Number of managers advanced to the shortlist stage following initial screening and evaluation of RFP responses.',
    `sourcing_origin` STRING COMMENT 'Indicates how this RFP was initiated: proactively by the investment team, reactively in response to an inbound manager pitch, consultant-recommended, board-directed, or regulatory-driven.. Valid values are `proactive|reactive|consultant_recommended|board_directed|regulatory`',
    `strategy_description` STRING COMMENT 'Detailed narrative describing the investment strategy, mandate scope, and return objectives being sought through this RFP, as communicated to prospective managers.',
    `sub_asset_class` STRING COMMENT 'More granular classification within the primary asset class (e.g., Large Cap Growth within Public Equities, Core Plus within Real Estate, Senior Secured within Credit).',
    `target_aum_max` DECIMAL(20,2) COMMENT 'Maximum AUM threshold for responding managers, used to screen for boutique or capacity-constrained managers where strategy capacity is a consideration.',
    `target_aum_min` DECIMAL(20,2) COMMENT 'Minimum Assets Under Management (AUM) threshold required of responding managers to qualify for consideration, expressed in the mandate currency.',
    `target_irr` DECIMAL(8,4) COMMENT 'Target net Internal Rate of Return (IRR) specified in the RFP as the expected return objective for the mandate, used to evaluate manager proposals against return expectations.',
    `title` STRING COMMENT 'Short descriptive title of the RFP or RFI, summarising the strategy or mandate being sought (e.g., Global Infrastructure Equity Manager RFP 2024).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this RFP record, supporting audit trail, change tracking, and incremental data pipeline processing.',
    `vehicle_type` STRING COMMENT 'Legal or structural vehicle type sought through this RFP: LP Fund (Limited Partnership), SMA (Separately Managed Account), Co-Investment, FoF (Fund of Funds), REIT, or other fund structures.',
    `weight_esg` DECIMAL(5,2) COMMENT 'Percentage weight assigned to the ESG Integration criterion in the RFP evaluation scoring framework, reflecting the importance of responsible investment practices.',
    `weight_fees` DECIMAL(5,2) COMMENT 'Percentage weight assigned to the Fee Structure criterion in the RFP evaluation scoring framework, covering management fees, carried interest, and total expense ratios.',
    `weight_investment_process` DECIMAL(5,2) COMMENT 'Percentage weight assigned to the Investment Process criterion in the RFP evaluation scoring framework. All evaluation weights must sum to 100%.',
    `weight_operational_dd` DECIMAL(5,2) COMMENT 'Percentage weight assigned to the Operational Due Diligence (ODD) criterion, covering back-office infrastructure, compliance, cybersecurity, and business continuity.',
    `weight_risk_management` DECIMAL(5,2) COMMENT 'Percentage weight assigned to the Risk Management Framework criterion in the RFP evaluation scoring framework, covering VaR, drawdown controls, and risk governance.',
    `weight_team_experience` DECIMAL(5,2) COMMENT 'Percentage weight assigned to the Team and Key Personnel Experience criterion in the RFP evaluation scoring framework.',
    `weight_track_record` DECIMAL(5,2) COMMENT 'Percentage weight assigned to the Performance Track Record criterion in the RFP evaluation scoring framework, reflecting historical returns and consistency.',
    CONSTRAINT pk_rfp PRIMARY KEY(`rfp_id`)
) COMMENT 'Tracks each Request for Proposal (RFP) or Request for Information (RFI) issued to external managers during the manager selection process. Records RFP type, asset class, strategy sought, issuance date, response deadline, evaluation criteria weighting';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`rfp_response` (
    `rfp_response_id` BIGINT COMMENT 'Unique surrogate identifier for each managers formal response to an RFP. Primary key of the rfp_response product.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (GP, sub-advisor, or FoF manager) that submitted this RFP response. Sourced from Preqin/PitchBook manager registry.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (GP, sub-advisor, or FoF manager) that submitted this RFP response. Sourced from Preqin/PitchBook manager registry.',
    `performance_benchmark_id` BIGINT COMMENT 'Foreign key linking to performance.performance_benchmark. Business justification: RFP response evaluation compares proposed manager performance against specified benchmarks.',
    `rfp_id` BIGINT COMMENT 'Reference to the parent RFP solicitation to which this response belongs. Links the response to the originating RFP event.',
    `asset_class` STRING COMMENT 'Primary asset class of the proposed strategy as categorized by the pension funds Strategic Asset Allocation (SAA) framework.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `aum_at_submission_usd` DECIMAL(20,2) COMMENT 'Total AUM reported by the manager at the time of RFP response submission in USD, used to assess manager scale and operational capacity.',
    `carried_interest_rate_pct` DECIMAL(8,4) COMMENT 'Proposed carried interest (carry) percentage charged by the GP on profits above the hurdle rate, as stated in the RFP response fee schedule.',
    `esg_policy_disclosed` BOOLEAN COMMENT 'Indicates whether the manager disclosed a formal ESG (Environmental, Social, and Governance) policy or responsible investment framework in their RFP response.',
    `esg_score` DECIMAL(6,2) COMMENT 'Sub-score assigned by the internal ESG team assessing the quality and integration of the managers ESG framework as disclosed in the RFP response.',
    `evaluation_lead` STRING COMMENT 'Name or identifier of the internal investment professional designated as the lead evaluator for this RFP response.',
    `evaluation_notes` STRING COMMENT 'Free-text internal commentary and qualitative observations recorded by the evaluation team regarding the managers RFP response, strengths, weaknesses, and concerns.',
    `fee_basis` STRING COMMENT 'The capital base on which the proposed management fee is calculated (e.g., committed capital, invested capital, NAV, GAV), as specified in the managers fee schedule.. Valid values are `committed_capital|invested_capital|nav|gross_asset_value`',
    `fee_competitiveness_score` DECIMAL(6,2) COMMENT 'Sub-score assigned by the internal team assessing the competitiveness and alignment of the proposed fee schedule relative to market benchmarks and peer managers.',
    `fund_term_years` BIGINT COMMENT 'Total proposed fund life in years from first close to final liquidation, including any extension options, as stated in the managers RFP response.',
    `hurdle_rate_pct` DECIMAL(8,4) COMMENT 'Proposed preferred return threshold (hurdle rate) that must be achieved before the GP is entitled to carried interest, expressed as an annual percentage.',
    `ic_presentation_required` BOOLEAN COMMENT 'Indicates whether this RFP response has been escalated to require a formal presentation to the Investment Committee (IC) as part of the manager selection process.',
    `investment_merit_score` DECIMAL(6,2) COMMENT 'Sub-score assigned by the internal team assessing the investment thesis, strategy quality, and return potential of the proposed mandate.',
    `investment_period_years` BIGINT COMMENT 'Duration of the proposed investment period in years during which the manager may draw down committed capital, as stated in the LPA or mandate terms.',
    `key_person_risk_flag` BOOLEAN COMMENT 'Indicates whether the internal evaluation team identified key person risk concentration in the managers proposed team, based on RFP response team composition disclosure.',
    `key_personnel_count` BIGINT COMMENT 'Number of key investment professionals (partners, managing directors, portfolio managers) disclosed in the team composition section of the RFP response.',
    `management_fee_rate_bps` DECIMAL(10,2) COMMENT 'Annual management fee rate proposed by the manager expressed in basis points (bps) on committed or invested capital, as stated in the RFP response.',
    `nda_executed` BOOLEAN COMMENT 'Indicates whether a Non-Disclosure Agreement (NDA) was executed with the manager prior to or concurrent with the RFP response submission.',
    `operational_risk_score` DECIMAL(6,2) COMMENT 'Sub-score from the Operational Due Diligence (ODD) assessment of the managers operational infrastructure, controls, and risk management as disclosed in the RFP response.',
    `overall_evaluation_score` DECIMAL(6,2) COMMENT 'Composite evaluation score assigned by the internal manager selection team to this RFP response, aggregating scores across all evaluation criteria dimensions.',
    `pri_signatory` BOOLEAN COMMENT 'Indicates whether the manager is a current signatory to the UN Principles for Responsible Investment (PRI) as disclosed in the RFP response.',
    `prior_fund_count` BIGINT COMMENT 'Number of prior funds or strategies managed by the GP in the same asset class and strategy type, as disclosed in the RFP response track record section.',
    `proposed_commitment_usd` DECIMAL(20,2) COMMENT 'The specific capital commitment amount proposed or requested from the pension fund in USD, as stated in the managers RFP response.',
    `proposed_fund_size_usd` DECIMAL(20,2) COMMENT 'Total target fund size proposed by the manager in USD, representing the aggregate capital the manager intends to raise for the strategy.',
    `proposed_strategy_description` STRING COMMENT 'Detailed narrative description of the proposed investment strategy, including investment thesis, target sectors, geographies, and value creation approach as stated by the manager.',
    `proposed_strategy_name` STRING COMMENT 'Name of the investment strategy proposed by the manager in their RFP response (e.g., Global Infrastructure Equity Fund IV, Senior Secured Credit Strategy).',
    `received_timestamp` TIMESTAMP COMMENT 'System-recorded timestamp when the RFP response document was ingested into the deal management platform (Dealpath/DealCloud), distinct from submission timestamp.',
    `response_document_reference` STRING COMMENT 'Document management system reference or URL pointing to the managers full RFP response submission package stored in the deal management platform.',
    `response_reference_number` STRING COMMENT 'Externally assigned or manager-generated reference number for this RFP response submission, used for correspondence and audit trail purposes.',
    `shortlist_recommendation` BOOLEAN COMMENT 'Indicates whether the internal evaluation team has recommended this managers RFP response for advancement to the shortlist stage of the selection process.',
    `strategy_aum_usd` DECIMAL(20,2) COMMENT 'AUM specifically attributable to the proposed strategy or asset class at the time of submission, distinct from the managers total firm-wide AUM.',
    `strategy_type` STRING COMMENT 'Sub-classification of the proposed strategy (e.g., buyout, venture, core, value-add, opportunistic, direct lending, mezzanine, co-invest, FoF, SMA). [ENUM-REF-CANDIDATE',
    `submission_date` DATE COMMENT 'Calendar date on which the manager formally submitted their RFP response to the pension funds investment team.',
    `submission_status` STRING COMMENT 'Current lifecycle state of the managers RFP response within the internal selection process. Drives workflow routing in Dealpath/DealCloud.. Valid values are `submitted|under_review|shortlisted|rejected|withdrawn|awarded`',
    `submission_timestamp` TIMESTAMP COMMENT 'Precise date and time at which the managers RFP response was received and recorded in the system, used for deadline compliance verification.',
    `target_geography` STRING COMMENT 'Primary geographic focus of the proposed strategy as stated by the manager (e.g., North America, Global, Europe). Free-text to accommodate multi-region mandates.',
    `target_irr_pct` DECIMAL(8,4) COMMENT 'Managers stated target net IRR for the proposed strategy, used as a key performance benchmark during the evaluation and mandate negotiation process.',
    `target_moic` DECIMAL(8,4) COMMENT 'Managers stated target MOIC (gross or net) for the proposed strategy, representing the expected total value multiple on invested capital.',
    `tcfd_aligned` BOOLEAN COMMENT 'Indicates whether the managers proposed strategy and reporting framework is aligned with TCFD recommendations as disclosed in the RFP response.',
    `team_composition_description` STRING COMMENT 'Narrative description of the investment team structure, key personnel roles, experience, and stability as presented in the RFP response.',
    `team_quality_score` DECIMAL(6,2) COMMENT 'Sub-score assigned by the internal team assessing the depth, experience, stability, and succession planning of the managers investment team.',
    `track_record_summary` STRING COMMENT 'Narrative summary of the managers historical performance track record as presented in the RFP response, covering prior fund vintages and realized returns.',
    `track_record_years` BIGINT COMMENT 'Number of years of verifiable investment track record presented by the manager in the RFP response, used to assess manager experience and longevity.',
    `vintage_year` BIGINT COMMENT 'The year in which the proposed fund or strategy is expected to make its first capital commitment, used for J-Curve analysis and portfolio construction.',
    CONSTRAINT pk_rfp_response PRIMARY KEY(`rfp_response_id`)
) COMMENT 'Captures each managers formal response to an RFP, including submission date, proposed strategy details, proposed fee schedule, track record summary, team composition, AUM at time of submission, and evaluation scores assigned by the internal selection';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`mandate_term` (
    `mandate_term_id` BIGINT COMMENT 'Unique surrogate identifier for each mandate term record in the Silver layer. Primary key for the mandate_term data product.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (General Partner or sub-advisor) who is party to this mandate term.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (General Partner or sub-advisor) who is party to this mandate term.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the parent mandate or investment agreement to which these economic and governance terms apply.',
    `asset_class` STRING COMMENT 'Primary asset class covered by the mandate, used for SAA/TAA alignment and fee benchmarking. [ENUM-REF-CANDIDATE: promote to reference product if additional classes added]',
    `audit_firm` STRING COMMENT 'Name of the independent external auditor engaged to audit the funds financial statements under this mandate.',
    `carried_interest_rate_pct` DECIMAL(6,4) COMMENT 'Percentage of profits allocated to the GP as carried interest (carry) above the hurdle rate. Typically 20% for private equity mandates.',
    `carry_split_lp_pct` DECIMAL(6,4) COMMENT 'LP share of profits in the carried interest waterfall after the GP catch-up phase. Typically 80% in a standard 80/20 carry structure.',
    `clawback_flag` BOOLEAN COMMENT 'Indicates whether a GP clawback provision exists, requiring the GP to return previously distributed carry if the fund underperforms over its life.',
    `clawback_lookback_years` BIGINT COMMENT 'Number of years over which the clawback obligation is assessed. Defines the GPs liability window for returning excess carry distributions.',
    `co_invest_carry_rate_pct` DECIMAL(6,4) COMMENT 'Carried interest rate applicable to co-investment transactions, typically lower than the main fund carry rate.',
    `co_invest_fee_rate_bps` DECIMAL(8,4) COMMENT 'Management fee rate in basis points applicable to co-investment capital deployed alongside the fund, often reduced or zero.',
    `co_invest_rights_flag` BOOLEAN COMMENT 'Indicates whether the LP has negotiated co-investment rights alongside the fund, allowing direct participation in individual deals.',
    `commitment_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the LP commitment and fee calculations are denominated.. Valid values are `^[A-Z]{3}$`',
    `committed_capital_amount` DECIMAL(22,4) COMMENT 'Total capital committed by the LP under this mandate, as stated in the LPA or SMA. Basis for fee calculations where fee_base is committed_capital.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the mandate term record was first created in the system, used for audit trail and data lineage.',
    `effective_date` DATE COMMENT 'Date from which the mandate terms become legally binding and operationally effective, as stated in the LPA or SMA agreement.',
    `esg_side_letter_flag` BOOLEAN COMMENT 'Indicates whether an ESG-specific side letter or addendum is attached to the mandate, imposing additional responsible investment obligations on the GP.',
    `excuse_right_flag` BOOLEAN COMMENT 'Indicates whether the LP has the right to excuse itself from specific investments (e.g., for regulatory, ESG, or conflict-of-interest reasons).',
    `expiry_date` DATE COMMENT 'Date on which the mandate terms expire or the fund reaches its scheduled end of term. Nullable for open-ended mandates.',
    `extension_option_years` BIGINT COMMENT 'Number of additional years the GP may extend the fund term beyond the base term, subject to LP advisory committee or LP consent.',
    `fee_base` STRING COMMENT 'The capital base on which management fees are calculated: committed capital, invested capital, NAV, GAV, or AUM. Critical for fee accrual and reconciliation.. Valid values are `committed_capital|invested_capital|NAV|GAV|AUM`',
    `fee_frequency` STRING COMMENT 'Frequency at which management fees are calculated and payable to the GP, as stipulated in the LPA or SMA.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `fee_payment_timing` STRING COMMENT 'Specifies whether management fees are paid in advance (at the start of the period) or in arrears (at the end of the period).. Valid values are `in_advance|in_arrears`',
    `fund_administrator` STRING COMMENT 'Name of the third-party fund administrator responsible for NAV calculation, capital account maintenance, and investor reporting.',
    `fund_domicile` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code of the jurisdiction where the fund vehicle is legally domiciled.. Valid values are `^[A-Z]{3}$`',
    `fund_term_years` BIGINT COMMENT 'Contractual life of the fund in years from the initial closing date, as specified in the LPA. Excludes extension options.',
    `governing_law_jurisdiction` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code of the legal jurisdiction whose laws govern the mandate agreement (e.g., CYM for Cayman Islands, GBR, USA).. Valid values are `^[A-Z]{3}$`',
    `gp_catch_up_rate_pct` DECIMAL(6,4) COMMENT 'Rate at which the GP receives profits during the catch-up phase after the LP preferred return is met, before the standard carry split applies.',
    `high_water_mark_flag` BOOLEAN COMMENT 'Indicates whether a high-water mark provision applies, requiring the fund to recover prior losses before carry is charged again.',
    `hurdle_rate_pct` DECIMAL(6,4) COMMENT 'Minimum annualized return (preferred return) that must be achieved before the GP is entitled to carried interest. Also known as the hurdle rate.',
    `hurdle_type` STRING COMMENT 'Specifies whether the hurdle is a hard hurdle (carry only on returns above hurdle) or soft hurdle (catch-up provision applies once hurdle is met).. Valid values are `hard|soft|none`',
    `ic_approval_date` DATE COMMENT 'Date on which the Investment Committee formally approved the mandate terms and authorized the LP commitment.',
    `investment_period_end_date` DATE COMMENT 'Date on which the funds investment period closes, after which new capital deployments are restricted and management fees may step down.',
    `key_person_clause_flag` BOOLEAN COMMENT 'Indicates whether the mandate includes a key person provision that suspends the investment period if named key individuals depart the GP.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the mandate term record, supporting amendment tracking and audit compliance.',
    `lp_advisory_committee_flag` BOOLEAN COMMENT 'Indicates whether the LP has a seat or observer rights on the Limited Partner Advisory Committee (LPAC) for this fund mandate.',
    `mandate_type` STRING COMMENT 'Classification of the mandate structure governing these terms. [ENUM-REF-CANDIDATE: LPA|SMA|co_investment|FoF|sub_advisory|co_investment_side_letter — promote to reference product]. Valid values are `LPA|SMA|co_investment|FoF|sub_advisory|co_investment_side_letter`',
    `mgmt_fee_rate_bps` DECIMAL(8,4) COMMENT 'Annual management fee rate expressed in basis points (bps) applied to the fee base. Represents the primary tier or flat rate where tiered schedules are not applicable.',
    `mgmt_fee_tier_schedule` STRING COMMENT 'Textual or structured description of tiered management fee breakpoints by AUM band (e.g., 100bps on first $500M, 75bps above). Stored as structured text pending normalization.',
    `monitoring_fee_offset_pct` DECIMAL(6,4) COMMENT 'Percentage of portfolio company monitoring, transaction, or advisory fees received by the GP that must be credited back to offset LP management fees.',
    `most_favored_nation_flag` BOOLEAN COMMENT 'Indicates whether the LP has Most Favored Nation rights, entitling it to the most favorable economic terms offered to any other LP in the fund.',
    `no_fault_divorce_flag` BOOLEAN COMMENT 'Indicates whether LPs have the right to remove the GP without cause (no-fault divorce) by a supermajority vote.',
    `organizational_expense_cap_pct` DECIMAL(6,4) COMMENT 'Maximum percentage of committed capital that the GP may charge as organizational and formation expenses to the fund.',
    `post_investment_fee_rate_bps` DECIMAL(8,4) COMMENT 'Reduced management fee rate in basis points applicable after the investment period ends, typically applied to invested (not committed) capital.',
    `reporting_frequency` STRING COMMENT 'Frequency at which the GP is contractually required to deliver fund performance, valuation, and portfolio reports to the LP.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `term_reference_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this version of the mandate term, used in LPA schedules, SMA agreements, and co-investment side letters.. Valid values are `^[A-Z0-9-]{4,30}$`',
    `term_status` STRING COMMENT 'Current lifecycle state of the mandate term record, governing whether the economic terms are operationally binding.. Valid values are `draft|active|amended|suspended|terminated|expired`',
    `valuation_methodology` STRING COMMENT 'Accounting and valuation standard used to determine NAV/GAV for the fund under this mandate (e.g., IPEV guidelines, IFRS 13, FASB ASC 820).. Valid values are `IPEV|IFRS_13|FASB_ASC_820|NAV|other`',
    `vintage_year` BIGINT COMMENT 'Calendar year in which the funds first capital call was made or the mandate became effective. Used for peer benchmarking and J-curve analysis.',
    `waterfall_type` STRING COMMENT 'Distribution waterfall structure: deal-by-deal (American) allows carry on each deal; whole-fund (European) requires full capital return before carry.. Valid values are `deal_by_deal|whole_fund|modified_whole_fund`',
    CONSTRAINT pk_mandate_term PRIMARY KEY(`mandate_term_id`)
) COMMENT 'Authoritative SSOT for the economic and governance terms of each mandate: management fee basis points (tiered by AUM band), carried interest rate, hurdle/preferred return, high-water mark, clawback terms, fee base (committed vs invested capital), fee';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`mandate_amendment` (
    `mandate_amendment_id` BIGINT COMMENT 'Unique surrogate identifier for each formal amendment record to an external manager mandate. Primary key for the mandate_amendment product in the Silver layer.',
    `actor_id` BIGINT COMMENT 'Reference to the governance body or individual (e.g., Investment Committee, Board, CIO) that approved this amendment. Links to the governance authority entity.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (GP, sub-advisor, or FoF manager) whose mandate is being amended. Sourced from the manager master profile.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (GP, sub-advisor, or FoF manager) whose mandate is being amended. Sourced from the manager master profile.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the parent mandate (LPA, SMA, co-investment agreement, or FoF mandate) that this amendment modifies. Links to the mandate master record.',
    `mandate_dealcloud_amendment_id` BIGINT COMMENT 'Native amendment record identifier from DealCloud (Deal Pipeline and Origination CRM), used for amendments originating from the deal pipeline or manager relationship management workflow.',
    `mandate_efront_amendment_id` BIGINT COMMENT 'Native amendment record identifier from eFront (Private Markets Portfolio Monitoring system), the primary system of record for private market mandate amendments. Enables reconciliation.',
    `amendment_date` DATE COMMENT 'The principal real-world date on which the amendment was formally agreed and signed by both parties. This is the legally binding execution date per the amendment agreement.',
    `amendment_rationale` STRING COMMENT 'Business justification for the amendment as documented in the IC memo or negotiation record. Captures the strategic or operational reason driving the change.',
    `amendment_reference` STRING COMMENT 'Externally-known unique reference code assigned to this amendment (e.g., AMD-MAND0042-2024-001). Used in legal correspondence, IC memos, and audit trails.. Valid values are `^AMD-[A-Z0-9]{4,20}-[0-9]{4}-[0-9]{3,6}$`',
    `amendment_status` STRING COMMENT 'Current workflow state of the amendment from drafting through execution. Controls downstream processing and reporting inclusion.. Valid values are `draft|pending_approval|approved|executed|rejected|withdrawn`',
    `amendment_type` STRING COMMENT 'Classification of the amendment by its primary business purpose. Drives workflow routing and legal review requirements. [ENUM-REF-CANDIDATE. Valid values are `fee_renegotiation|guideline_change|term_extension|side_letter|co_invest_right|termination_notice`',
    `amendment_version` BIGINT COMMENT 'Sequential version number for amendments to the same clause or provision within the same mandate. Enables tracking of iterative renegotiations over the mandate lifecycle.',
    `approval_level` STRING COMMENT 'Governance tier at which the amendment was approved, reflecting the materiality and delegation of authority framework (e.g., CIO for minor fee adjustments, Board for material term changes).. Valid values are `cio|investment_committee|board|delegated_authority|portfolio_manager`',
    `clause_description` STRING COMMENT 'Plain-language description of the clause or provision being amended, providing business context for the change beyond the clause reference number.',
    `clause_reference` STRING COMMENT 'Specific section, article, or clause number within the original mandate agreement (LPA, SMA, or co-investment agreement) that is being modified by this amendment.',
    `counterparty_signed_date` DATE COMMENT 'Date on which the external manager (GP or sub-advisor) executed their signature on the amendment document. May differ from amendment_date if signing occurred in stages.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this amendment record was first created in the system. Supports audit trail, data lineage, and Silver layer ingestion tracking per ISO 27001.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code applicable when value_unit is currency (e.g., USD, GBP, EUR). Null for non-monetary clause amendments.. Valid values are `^[A-Z]{3}$`',
    `document_reference` STRING COMMENT 'Document management system reference or file path for the executed amendment agreement. Enables retrieval of the legal document from the document repository.',
    `effective_date` DATE COMMENT 'Date from which the amended terms take legal and operational effect. May differ from amendment_date if the amendment has a retroactive or future effective date.',
    `esg_impact_assessed` BOOLEAN COMMENT 'Indicates whether an ESG impact assessment was conducted for this amendment, particularly relevant for guideline changes affecting ESG constraints or responsible investment mandates.',
    `expiry_date` DATE COMMENT 'Date on which the amended terms cease to apply, if the amendment is time-limited (e.g., a temporary fee waiver or a side letter with a sunset clause). Null for permanent amendments.',
    `fee_type_amended` STRING COMMENT 'Specific fee component modified by this amendment when amendment_type is fee_renegotiation. Null for non-fee amendments. [ENUM-REF-CANDIDATE: management_fee|carried_interest|hurdle_rate|preferred_return|transaction_fee|monitoring_fee|setup_fee|clawback —. Valid values are `management_fee|carried_interest|hurdle_rate|preferred_return|transaction_fee|monitoring_fee`',
    `ic_approval_date` DATE COMMENT 'Date on which the Investment Committee formally approved this amendment. May precede the amendment_date (execution date) by days or weeks.',
    `ic_approval_reference` STRING COMMENT 'Reference number or resolution identifier from the Investment Committee (IC) meeting minutes approving this amendment. Links to the governance record in Diligent/BoardEffect.',
    `internal_signed_date` DATE COMMENT 'Date on which the pension funds authorized signatory executed the amendment on behalf of the fund. Completes the bilateral execution of the amendment.',
    `investment_guideline_category` STRING COMMENT 'Category of investment guideline modified when amendment_type is guideline_change. Drives compliance monitoring updates in BlackRock Aladdin and Charles River IMS.',
    `is_material_amendment` BOOLEAN COMMENT 'Indicates whether this amendment is classified as material under the funds internal governance policy, triggering enhanced IC approval, legal review, and regulatory disclosure requirements.',
    `is_side_letter` BOOLEAN COMMENT 'Indicates whether this amendment is structured as a side letter (a separate bilateral agreement supplementing the main LPA or SMA) rather than a formal amendment to the primary document.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this amendment record. Used for incremental data pipeline processing and change detection in the Databricks Silver layer.',
    `legal_counsel_firm` STRING COMMENT 'Name of the external legal counsel firm engaged to review and draft this amendment. Supports legal cost tracking and counsel relationship management.',
    `legal_review_completed` BOOLEAN COMMENT 'Indicates whether the internal or external legal review of this amendment has been formally completed and signed off prior to execution.',
    `mfn_applicable` BOOLEAN COMMENT 'Indicates whether a Most Favoured Nation (MFN) clause applies to this amendment, entitling the pension fund to the most favourable terms granted to any other LP in the fund.',
    `negotiation_summary` STRING COMMENT 'Summary of the negotiation process, key concessions, and counterparty positions leading to the agreed amendment terms. Supports post-deal review and future renegotiations.',
    `prior_carry_rate` DECIMAL(8,6) COMMENT 'The carried interest (carry) rate as a decimal (e.g., 0.20 for 20%) in effect before this amendment. Populated when fee_type_amended includes carried_interest.',
    `prior_hurdle_rate` DECIMAL(8,6) COMMENT 'The preferred return / hurdle rate as a decimal (e.g., 0.08 for 8%) before this amendment. The threshold IRR the GP must exceed before earning carry.',
    `prior_management_fee_rate` DECIMAL(8,6) COMMENT 'The management fee rate (as a decimal, e.g., 0.015 for 1.5%) in effect before this amendment. Populated only when fee_type_amended includes management_fee.',
    `prior_term_end_date` DATE COMMENT 'The original contractual end date of the mandate or fund term before this amendment. Populated for term extension amendments to document the change.',
    `prior_value` DECIMAL(18,2) COMMENT 'The original contractual value, rate, limit, or text of the clause before this amendment. Stored as STRING to accommodate numeric, percentage, date, and free-text clause values.',
    `regulatory_disclosure_required` BOOLEAN COMMENT 'Indicates whether this amendment triggers a regulatory disclosure obligation (e.g., SFDR, SEC reporting). Drives compliance workflow and regulatory reporting queue.',
    `revised_carry_rate` DECIMAL(8,6) COMMENT 'The carried interest (carry) rate as a decimal after this amendment. Tracks renegotiated economics for performance attribution and fee analysis.',
    `revised_hurdle_rate` DECIMAL(8,6) COMMENT 'The preferred return / hurdle rate as a decimal after this amendment. Impacts IRR and MOIC calculations for performance attribution.',
    `revised_management_fee_rate` DECIMAL(8,6) COMMENT 'The management fee rate (as a decimal) after this amendment. Enables fee savings tracking and benchmarking against Preqin/PitchBook market data.',
    `revised_term_end_date` DATE COMMENT 'The new contractual end date of the mandate or fund term after this amendment. Used in ALM, liquidity forecasting, and commitment scheduling.',
    `revised_value` DECIMAL(18,2) COMMENT 'The new contractual value, rate, limit, or text of the clause after this amendment. Stored as STRING to accommodate numeric, percentage, date, and free-text clause values.',
    `side_letter_type` STRING COMMENT 'Classification of the side letter if is_side_letter is true. MFN (Most Favoured Nation) clauses, co-investment rights, and fee discounts are common LP-negotiated side letter types.. Valid values are `mfn_clause|co_invest_right|fee_discount|reporting_right|excuse_right|other`',
    `term_extension_years` DECIMAL(5,2) COMMENT 'Number of years by which the mandate or fund term is extended under this amendment. Populated when amendment_type is term_extension. Supports ALM and liquidity planning.',
    `value_unit` STRING COMMENT 'Unit of measure for prior_value and revised_value (e.g., percentage for management fee rate, bps for spread, currency for hard cap). Enables correct interpretation of the change.',
    CONSTRAINT pk_mandate_amendment PRIMARY KEY(`mandate_amendment_id`)
) COMMENT 'Records each formal amendment to an existing mandate, capturing amendment date, amendment type (fee renegotiation, guideline change, term extension, side letter), the specific clause modified, prior value, revised value, and approval authority.';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`manager_contact` (
    `manager_contact_id` BIGINT COMMENT 'Unique surrogate identifier for a key personnel record at an external manager firm. Primary key for the manager_contact entity.',
    `employee_id` BIGINT COMMENT 'Internal employee ID of the pension fund staff member responsible for managing the relationship with this contact, used for accountability and coverage tracking.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external manager firm (GP, sub-advisor, or FoF manager) that this contact is associated with. Links to the manager master record.',
    `manager_firm_gp_profile_id` BIGINT COMMENT 'Reference to the external manager firm (GP, sub-advisor, or FoF manager) that this contact is associated with. Links to the manager master record.',
    `contact_status` STRING COMMENT 'Current lifecycle status of the contact record, reflecting whether the individual is actively employed at the manager firm and available for engagement.. Valid values are `active|inactive|departed|on_leave`',
    `coverage_asset_class` STRING COMMENT 'Primary asset class covered by this contact within the external manager firm, aligning to the pension funds asset allocation domains (e.g., private equity, infrastructure, credit).. Valid values are `private_equity|real_estate|infrastructure|natural_resources|credit|public_equities`',
    `coverage_strategy` STRING COMMENT 'Specific investment strategy or sub-strategy the contact oversees or represents (e.g., buyout, growth equity, core infrastructure, senior secured credit, value-add real estate).',
    `data_consent_date` DATE COMMENT 'Date on which data processing consent was obtained from this contact, used to track consent validity and trigger renewal workflows per GDPR and applicable privacy law requirements.',
    `data_consent_obtained` BOOLEAN COMMENT 'Indicates whether explicit consent for processing personal data has been obtained from this contact in jurisdictions where GDPR or equivalent privacy regulations apply.',
    `date_joined_firm` DATE COMMENT 'Date the contact joined the external manager firm, used to calculate tenure and assess team stability as part of ongoing manager oversight and ODD.',
    `departure_date` DATE COMMENT 'Date the contact departed the external manager firm, populated when contact_status transitions to departed. Triggers key-person event review if is_key_person is true.',
    `departure_reason` STRING COMMENT 'Reason for the contacts departure from the external manager firm, used in key-person event analysis and manager stability risk assessment.. Valid values are `resignation|retirement|termination|restructuring|unknown`',
    `direct_phone` STRING COMMENT 'Direct business telephone number for the contact, in E.164 international format, used for investment committee follow-ups and urgent mandate communications.. Valid values are `^+?[1-9]d{1,14}$`',
    `do_not_contact` BOOLEAN COMMENT 'Indicates whether this contact has requested to be excluded from outreach, or has been flagged by compliance as restricted from contact due to regulatory or legal constraints.',
    `educational_background` STRING COMMENT 'Summary of the contacts highest academic qualification and institution (e.g., MBA Harvard Business School), used in qualitative manager team assessment during ODD.',
    `email` STRING COMMENT 'Primary business email address for the contact at the external manager firm, used for capital call notices, LP communications, and mandate correspondence.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `first_name` STRING COMMENT 'Legal given name of the key personnel contact at the external manager firm, as recorded in Preqin, PitchBook, or direct firm communication.',
    `is_key_person` BOOLEAN COMMENT 'Indicates whether this contact is designated as a key person under the terms of an LPA or mandate agreement, triggering key-person event monitoring and notification obligations.',
    `is_primary_contact` BOOLEAN COMMENT 'Indicates whether this individual is the designated primary point of contact for the pension funds relationship with the external manager firm.',
    `job_title` STRING COMMENT 'Official job title of the contact at the external manager firm (e.g., Portfolio Manager, Chief Investment Officer, Investor Relations Director, Chief Compliance Officer).',
    `key_person_mandate_ref` STRING COMMENT 'Reference identifier of the LPA, SMA, or co-investment agreement in which this contact is named as a key person, enabling traceability to contractual key-person provisions.',
    `kyc_verified` BOOLEAN COMMENT 'Indicates whether KYC identity verification has been completed for this contact in accordance with AML/CTF obligations and FATF recommendations.',
    `kyc_verified_date` DATE COMMENT 'Date on which KYC verification was last completed for this contact, used to track compliance with AML/CTF refresh cycles and regulatory obligations.',
    `last_interaction_date` DATE COMMENT 'Date of the most recent recorded interaction between the pension funds team and this contact (e.g., LP advisory call, annual meeting, IC presentation), used for relationship health monitoring.',
    `last_interaction_type` STRING COMMENT 'Type of the most recent recorded interaction with this contact, used to assess engagement quality and frequency as part of ongoing manager relationship management.. Valid values are `lp_advisory_call|annual_meeting|ic_presentation|site_visit|email|conference`',
    `last_name` STRING COMMENT 'Legal family name of the key personnel contact at the external manager firm, as recorded in Preqin, PitchBook, or direct firm communication.',
    `linkedin_url` STRING COMMENT 'LinkedIn profile URL for the contact, used for background verification, professional history review during ODD, and ongoing key-person monitoring.',
    `mobile_phone` STRING COMMENT 'Mobile phone number for the contact in E.164 international format, used for time-sensitive communications such as capital call notices or NAV queries.. Valid values are `^+?[1-9]d{1,14}$`',
    `nda_expiry_date` DATE COMMENT 'Expiry date of the NDA in place with this contact. Null if the NDA is perpetual or if no NDA is in place. Used to trigger NDA renewal workflows.',
    `nda_in_place` BOOLEAN COMMENT 'Indicates whether a valid NDA is in place with this contact, required before sharing proprietary deal information, IM documents, or confidential portfolio data.',
    `notes` STRING COMMENT 'Free-text field for qualitative notes on the contact relationship, including meeting observations, personality insights, and engagement history relevant to manager oversight.',
    `office_location_city` STRING COMMENT 'City of the contacts primary office location at the external manager firm, used for time-zone management and in-person meeting logistics.',
    `office_location_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the contacts primary office location, used for regulatory jurisdiction mapping and travel planning.. Valid values are `^[A-Z]{3}$`',
    `pep_status` STRING COMMENT 'Politically Exposed Person classification for the contact per FATF Recommendation 12, required for enhanced due diligence and AML compliance screening.. Valid values are `not_pep|domestic_pep|foreign_pep|international_org_pep`',
    `preferred_contact_method` STRING COMMENT 'The contacts preferred communication channel for routine LP-GP interactions, capital call notices, and investor relations correspondence.. Valid values are `email|phone|video_call|in_person`',
    `preferred_language` STRING COMMENT 'Preferred language for communications with this contact, expressed as an IETF BCP 47 language tag (e.g., en-CA, fr-FR), used for LP reporting and correspondence.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `prior_employer` STRING COMMENT 'Most recent prior employer of the contact before joining the current manager firm, used in background verification and key-person track record assessment during ODD.',
    `professional_designation` STRING COMMENT 'Primary professional credential or designation held by the contact (e.g., CFA, CPA, CAIA, FRM), used in qualitative assessment of manager team quality during DD.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this manager contact record was first created in the data platform, used for audit trail and data lineage purposes per the national pension regulator data governance requirements.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this manager contact record was most recently modified in the data platform, used for change tracking, audit trail, and data freshness monitoring.',
    `role_type` STRING COMMENT 'Functional classification of the contacts role within the external manager firm, used to route communications and oversight activities. [ENUM-REF-CANDIDATE: investment|investor_relations|compliance|operations|legal|executive|risk|finance — promote to. Valid values are `investment|investor_relations|compliance|operations|legal|executive`',
    `sanctions_screened` BOOLEAN COMMENT 'Indicates whether this contact has been screened against applicable sanctions lists (OFAC, UN, EU) as part of AML/CTF compliance obligations.',
    `sanctions_screened_date` DATE COMMENT 'Date on which the most recent sanctions screening was performed for this contact, used to ensure compliance with periodic AML/CTF refresh requirements.',
    `source_system_contact_code` STRING COMMENT 'The unique identifier assigned to this contact in the originating source system (Preqin, PitchBook, or DealCloud), used for data lineage tracing and cross-system reconciliation.',
    `tenure_at_firm_years` DECIMAL(5,2) COMMENT 'Number of years the contact has been employed at the current external manager firm, a key metric in key-person risk assessment and manager stability evaluation.',
    `time_zone` STRING COMMENT 'IANA time zone identifier for the contacts primary office location (e.g., America/New_York, Europe/London), used for scheduling IC meetings and capital call deadlines.',
    `years_of_experience` BIGINT COMMENT 'Total years of professional investment experience for the contact, used in key-person risk assessment during ODD and ongoing manager oversight.',
    CONSTRAINT pk_manager_contact PRIMARY KEY(`manager_contact_id`)
) COMMENT 'Master record for key personnel at each external manager firm, including portfolio managers, investor relations contacts, compliance officers, and operations contacts.';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`fee_schedule` (
    `fee_schedule_id` BIGINT COMMENT 'Unique surrogate identifier for the fee schedule record within the pension funds manager domain.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (GP, sub-advisor, or FoF manager) subject to this fee schedule.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (GP, sub-advisor, or FoF manager) subject to this fee schedule.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the investment mandate (LPA, SMA, co-investment agreement) to which this fee schedule applies.',
    `performance_benchmark_id` BIGINT COMMENT 'Foreign key linking to performance.performance_benchmark. Business justification: Performance fee calculations require benchmark reference for hurdle rate comparisons.',
    `approval_date` DATE COMMENT 'Date on which the Investment Committee (IC) formally approved this fee schedule as part of the mandate approval process.',
    `approved_by` STRING COMMENT 'Name or identifier of the Investment Committee (IC) member or authorized officer who approved this fee schedule, as recorded in Diligent/BoardEffect.',
    `asset_class` STRING COMMENT 'Asset class to which this fee schedule applies, aligning with the pension funds Strategic Asset Allocation (SAA) taxonomy.. Valid values are `private_equity|real_estate|infrastructure|natural_resources|credit|public_equities`',
    `calculation_frequency` STRING COMMENT 'Frequency at which management fees are calculated and accrued: monthly, quarterly, semi-annual, or annual. Drives fee accrual in SimCorp Dimension and Oracle Financials.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `carried_interest_rate_pct` DECIMAL(8,4) COMMENT 'Percentage of profits allocated to the GP as carried interest (Carry), typically 20% for private equity mandates. Governed by the LPA waterfall provisions.',
    `carry_split_lp_pct` DECIMAL(8,4) COMMENT 'LPs share of profits above the hurdle rate after the GP catch-up, expressed as a percentage. Typically 80% in a standard 80/20 carry split.',
    `clawback_escrow_pct` DECIMAL(8,4) COMMENT 'Percentage of carried interest distributions held in escrow to fund potential clawback obligations. Null if no clawback escrow is required by the LPA.',
    `clawback_provision` BOOLEAN COMMENT 'Indicates whether the LPA includes a GP clawback provision requiring the GP to return excess carried interest distributions if the fund underperforms over its life.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this fee schedule record was first created in the system, used for audit trail and data lineage in the Databricks Silver layer.',
    `crystallization_frequency` STRING COMMENT 'Frequency at which performance fees (carried interest or incentive fees) are crystallized and become payable: annual, quarterly, at realization, or at fund end.. Valid values are `annual|quarterly|at_realization|at_fund_end`',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which fees are denominated and settled (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `effective_date` DATE COMMENT 'Date from which this fee schedule becomes contractually binding, as stipulated in the LPA or SMA agreement.',
    `expiry_date` DATE COMMENT 'Date on which this fee schedule ceases to be effective. Null for open-ended mandates. Triggers renegotiation workflow in eFront.',
    `fee_base` STRING COMMENT 'The denominator used to calculate management fees: Committed Capital, Invested Capital, Net Asset Value (NAV), Gross Asset Value (GAV), or Assets Under Management (AUM).. Valid values are `committed_capital|invested_capital|NAV|GAV|AUM`',
    `fee_rebate_eligible` BOOLEAN COMMENT 'Indicates whether the pension fund is eligible for fee rebates based on commitment size, co-investment rights, or negotiated LP-specific terms in the side letter.',
    `fee_rebate_rate_bps` DECIMAL(10,4) COMMENT 'Basis point reduction applied to the standard management fee rate as a rebate for large LP commitments or co-investment participation. Null if not eligible.',
    `fee_reporting_standard` STRING COMMENT 'Reporting standard under which fee disclosures are made: ILPA Fee Reporting Template, GIPS, SFDR Article 8/9, or custom bilateral agreement.. Valid values are `ILPA|GIPS|SFDR|custom`',
    `fee_schedule_status` STRING COMMENT 'Current lifecycle state of the fee schedule record: active (in force), superseded (replaced by a newer version), terminated, draft, or pending IC approval.. Valid values are `active|superseded|terminated|draft|pending_approval`',
    `gp_catchup_rate_pct` DECIMAL(8,4) COMMENT 'Rate at which the GP receives distributions during the catch-up phase after the LP preferred return hurdle is met, before the standard carry split applies.',
    `high_water_mark_flag` BOOLEAN COMMENT 'Indicates whether a high water mark provision applies, preventing the GP from collecting performance fees until prior losses are recovered.',
    `hurdle_rate_pct` DECIMAL(8,4) COMMENT 'Preferred return threshold (Hurdle Rate) that must be achieved before the GP is entitled to carried interest. Expressed as an annual percentage (e.g., 8%).',
    `hurdle_type` STRING COMMENT 'Specifies whether the hurdle rate is a hard hurdle (carry only on returns above hurdle) or soft hurdle (catch-up provision applies once hurdle is met).. Valid values are `hard|soft`',
    `investment_period_fee_rate_bps` DECIMAL(10,4) COMMENT 'Management fee rate in basis points applicable during the funds active investment period (typically years 1–5 for PE). May differ from the post-investment-period rate.',
    `is_tiered` BOOLEAN COMMENT 'Indicates whether the management fee schedule uses AUM-band tiers (True) or a flat rate (False). Tiered details are stored in the fee_schedule_tier product.',
    `management_fee_offset_pct` DECIMAL(8,4) COMMENT 'Percentage of transaction fees, monitoring fees, or other GP income credited back to reduce the LPs management fee obligation, per ILPA best practice.',
    `management_fee_rate_bps` DECIMAL(10,4) COMMENT 'Standard management fee rate expressed in basis points (bps) applied to the fee base. For tiered schedules, this is the first-tier rate.',
    `mandate_type` STRING COMMENT 'Type of investment mandate agreement governing this fee schedule: Limited Partnership Agreement (LPA), Separately Managed Account (SMA), co-investment, Fund of Funds (FoF), or sub-advisory.. Valid values are `LPA|SMA|co_investment|FoF|sub_advisory`',
    `monitoring_fee_annual_usd` DECIMAL(22,2) COMMENT 'Fixed annual monitoring fee in USD charged by the GP for portfolio company oversight services. Subject to management fee offset per LPA terms.',
    `most_favored_nation_flag` BOOLEAN COMMENT 'Indicates whether the pension fund has negotiated Most Favored Nation (MFN) rights, entitling it to the most favorable fee terms offered to any LP in the fund.',
    `notes` STRING COMMENT 'Free-text field for additional commentary on fee terms, negotiation context, or exceptions not captured in structured fields. Sourced from eFront or DealCloud.',
    `organizational_expense_cap_pct` DECIMAL(8,4) COMMENT 'Maximum percentage of committed capital that the GP may charge to the fund for organizational and formation expenses, as negotiated in the LPA.',
    `payment_frequency` STRING COMMENT 'Frequency at which management fee invoices are settled and cash is transferred to the GP. May differ from calculation frequency (e.g., calculated monthly, paid quarterly).. Valid values are `monthly|quarterly|semi_annual|annual|in_arrears`',
    `payment_timing` STRING COMMENT 'Specifies whether management fees are paid in advance (at the start of the period) or in arrears (at the end of the period), as defined in the LPA.. Valid values are `in_advance|in_arrears`',
    `post_investment_period_fee_rate_bps` DECIMAL(10,4) COMMENT 'Reduced management fee rate in basis points applicable after the funds investment period ends, typically based on invested (not committed) capital.',
    `schedule_code` STRING COMMENT 'Unique business identifier for the fee schedule, used in mandate documentation, fee invoices, and reconciliation with eFront and Oracle Financials.. Valid values are `^FS-[A-Z0-9]{4,20}$`',
    `schedule_name` STRING COMMENT 'Descriptive name for the fee schedule (e.g., PE Fund III Management Fee Schedule), used for display and reporting purposes.',
    `schedule_type` STRING COMMENT 'Classification of the fee schedule by fee category. [ENUM-REF-CANDIDATE: management_fee|carried_interest|advisory_fee|performance_fee|transaction_fee|monitoring_fee|placement_fee|custody_fee — promote to reference product]. Valid values are `management_fee|carried_interest|advisory_fee|performance_fee|transaction_fee|monitoring_fee`',
    `side_letter_reference` STRING COMMENT 'Reference number or identifier of the side letter agreement that modifies standard LPA fee terms for this LP. Null if no side letter exists.',
    `tier_1_upper_bound_usd` DECIMAL(22,2) COMMENT 'Upper AUM boundary in USD for the first management fee tier. Fees on committed/invested capital up to this amount are charged at the Tier 1 rate.',
    `tier_2_fee_rate_bps` DECIMAL(10,4) COMMENT 'Management fee rate in basis points applicable to the AUM band above the Tier 1 upper bound. Null if the schedule is not tiered.',
    `transaction_fee_rate_bps` DECIMAL(10,4) COMMENT 'Fee rate in basis points charged by the GP on deal transaction value (acquisition, disposition). Subject to management fee offset provisions per ILPA guidelines.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this fee schedule record, supporting change tracking and audit compliance per SOC 2 requirements.',
    `version_number` BIGINT COMMENT 'Sequential version number of the fee schedule, incremented each time terms are renegotiated or amended. Enables historical tracking of fee evolution over the mandate lifecycle.',
    `vintage_year` BIGINT COMMENT 'The year in which the funds first capital call occurred, used to benchmark fee terms against peer funds of the same vintage year in Preqin and PitchBook.',
    `waterfall_type` STRING COMMENT 'Specifies the carry distribution waterfall structure: deal-by-deal (carry calculated per investment) or whole-fund (carry calculated across the entire portfolio).. Valid values are `deal_by_deal|whole_fund`',
    CONSTRAINT pk_fee_schedule PRIMARY KEY(`fee_schedule_id`)
) COMMENT 'Defines the fee structure applicable to each mandate or manager relationship, including management fee tiers (basis points by AUM band), carried interest percentage, preferred return hurdle, fee calculation frequency, fee base (committed vs.';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`evaluation` (
    `evaluation_id` BIGINT COMMENT 'Unique surrogate identifier for each periodic external manager evaluation record within the manager domain.',
    `composite_id` BIGINT COMMENT 'Foreign key linking to performance.composite. Business justification: Manager evaluation process requires composite performance data to calculate conviction ratings and performance assessment scores.',
    `dd_engagement_id` BIGINT COMMENT 'Foreign key linking to diligence.dd_engagement. Business justification: Annual manager evaluation process requires tracing back to original DD engagement that established the relationship.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: Manager evaluations assess performance under specific economic scenarios (base/stress cases).',
    `employee_id` BIGINT COMMENT 'Senior investment professional or IC member who formally approved and signed off on this evaluation. Links to the internal employee record.',
    `evaluation_employee_id` BIGINT COMMENT 'Senior investment professional or IC member who formally approved and signed off on this evaluation. Links to the internal employee record.',
    `evaluation_lead_analyst_employee_id` BIGINT COMMENT 'Internal staff member responsible for authoring and coordinating this manager evaluation. Links to the internal employee/analyst record.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (GP, sub-advisor, or FoF manager) being evaluated. Links to the manager master record.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (GP, sub-advisor, or FoF manager) being evaluated. Links to the manager master record.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the specific mandate (LPA, SMA, or co-investment agreement) under which this manager evaluation is conducted.',
    `performance_benchmark_id` BIGINT COMMENT 'Foreign key linking to performance.performance_benchmark. Business justification: Manager evaluations compare reported performance against benchmarks. The evaluation has benchmark_irr_pct field indicating benchmark comparison is core to the evaluation',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the evaluation was formally approved by the designated approver, completing the governance workflow.',
    `benchmark_irr_pct` DECIMAL(8,4) COMMENT 'The target or benchmark Internal Rate of Return (IRR) percentage against which the managers performance is evaluated during this review period.',
    `compliance_breach_details` STRING COMMENT 'Narrative description of any compliance breaches, regulatory incidents, or mandate violations identified during the review period.',
    `compliance_breach_flag` BOOLEAN COMMENT 'Indicates whether the manager reported any regulatory, mandate, or investment guideline compliance breaches during the review period.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp recording when this evaluation record was first created in the data platform, used for audit trail and data lineage.',
    `data_source` STRING COMMENT 'Primary data source(s) used to populate this evaluation, such as eFront fund monitoring data, Preqin/PitchBook benchmarks, manager-submitted reports, or on-site visit findings.. Valid values are `efront|preqin|pitchbook|manager_report|on_site_visit|combined`',
    `esg_integration_notes` STRING COMMENT 'Qualitative narrative on the managers ESG policies, stewardship activities, TCFD alignment, and PRI signatory status.',
    `esg_integration_score` DECIMAL(5,2) COMMENT 'Numeric score assessing the depth and quality of Environmental, Social, and Governance (ESG) integration within the managers investment process.',
    `esg_maturity_level` STRING COMMENT 'Categorical maturity tier for the managers ESG integration, from nascent (minimal) to leading (best-in-class), used for portfolio-level ESG reporting.. Valid values are `leading|advanced|developing|nascent|not_assessed`',
    `evaluation_date` DATE COMMENT 'The principal business date on which the evaluation assessment was formally conducted or the review period ended.',
    `evaluation_status` STRING COMMENT 'Current lifecycle state of the evaluation record from initial drafting through IC approval and final publication.. Valid values are `draft|in_progress|pending_approval|approved|published|archived`',
    `evaluation_type` STRING COMMENT 'Classification of the evaluation cycle: annual review, interim review triggered by an event, onboarding assessment, termination review, or ad hoc. [ENUM-REF-CANDIDATE: annual_review|interim_review|onboarding|termination_review|ad_hoc — promote to. Valid values are `annual_review|interim_review|onboarding|termination_review|ad_hoc`',
    `executive_summary` STRING COMMENT 'High-level narrative summary of the evaluation findings, key strengths, concerns, and recommended actions, intended for IC and senior management review.',
    `fee_compliance_flag` BOOLEAN COMMENT 'Indicates whether the managers fee charges (management fee, carried interest, and expenses) were compliant with the agreed LPA or mandate terms during the review period.',
    `ic_decision_date` DATE COMMENT 'Date on which the Investment Committee (IC) formally reviewed and resolved the recommended action arising from this evaluation.',
    `ic_review_required_flag` BOOLEAN COMMENT 'Indicates whether this evaluation outcome requires formal escalation to the Investment Committee (IC) for review and decision.',
    `investment_process_notes` STRING COMMENT 'Qualitative narrative describing the analysts assessment of the managers investment process, strategy differentiation, and edge.',
    `investment_process_score` DECIMAL(5,2) COMMENT 'Numeric score assessing the quality, repeatability, and differentiation of the managers investment process and philosophy.',
    `key_person_departure_flag` BOOLEAN COMMENT 'Indicates whether a key-person departure event occurred at the manager during the review period, triggering enhanced monitoring.',
    `methodology` STRING COMMENT 'The scoring framework or methodology version applied in this evaluation (e.g., internal scorecard version, qualitative-only, or hybrid approach).. Valid values are `scorecard_v1|scorecard_v2|qualitative_only|quantitative_only|hybrid`',
    `next_evaluation_date` DATE COMMENT 'Scheduled date for the next periodic evaluation of this manager, set based on conviction rating and watch-list status.',
    `on_site_visit_conducted_flag` BOOLEAN COMMENT 'Indicates whether an on-site operational due diligence (ODD) visit to the managers offices was conducted as part of this evaluation cycle.',
    `on_site_visit_date` DATE COMMENT 'Date on which the on-site operational due diligence visit was conducted at the managers premises during this evaluation cycle.',
    `operational_infrastructure_notes` STRING COMMENT 'Qualitative narrative on the managers operational setup, technology stack, fund administration quality, and cybersecurity posture.',
    `operational_infrastructure_score` DECIMAL(5,2) COMMENT 'Numeric score from Operational Due Diligence (ODD) assessing the managers back-office, technology, compliance, and operational controls.',
    `overall_conviction_rating` STRING COMMENT 'Composite qualitative conviction rating summarising the investment teams overall confidence in the manager. Drives mandate continuation or termination decisions.. Valid values are `high_conviction|conviction|watch|reduce|terminate`',
    `overall_score` DECIMAL(5,2) COMMENT 'Composite weighted numeric score (e.g., 0.00–100.00) aggregating all qualitative and quantitative sub-scores into a single manager evaluation rating.',
    `performance_assessment_rating` STRING COMMENT 'Qualitative rating of the managers investment performance relative to benchmark and peers over the review period, based on TWR and IRR analysis.. Valid values are `outperforming|in_line|underperforming|insufficient_track_record`',
    `prior_conviction_rating` STRING COMMENT 'The overall conviction rating assigned in the immediately preceding evaluation cycle, enabling trend analysis and rating migration tracking.. Valid values are `high_conviction|conviction|watch|reduce|terminate`',
    `rating_change_flag` BOOLEAN COMMENT 'Indicates whether the overall conviction rating changed from the prior evaluation cycle, flagging upgrades or downgrades for IC attention.',
    `recommended_action` STRING COMMENT 'Formal recommendation arising from this evaluation for the Investment Committee (IC) regarding the mandate relationship. [ENUM-REF-CANDIDATE: continue|continue_with_conditions|increase_allocation|reduce_allocation|terminate|place_on_watch — promote to. Valid values are `continue|continue_with_conditions|increase_allocation|reduce_allocation|terminate|place_on_watch`',
    `reference` STRING COMMENT 'Externally-visible unique reference code for this evaluation record, used in IC reporting and governance documentation (e.g., EVAL-2024-000123).. Valid values are `^EVAL-[0-9]{4}-[0-9]{6}$`',
    `reported_irr_pct` DECIMAL(8,4) COMMENT 'The managers reported net IRR percentage for the mandate or fund as of the review period end date, sourced from eFront or manager reporting.',
    `reported_moic` DECIMAL(8,4) COMMENT 'The managers reported Multiple on Invested Capital (MOIC) as of the review period end date, reflecting gross investment return multiple.',
    `reported_tvpi` DECIMAL(8,4) COMMENT 'Total Value to Paid-In (TVPI) ratio reported by the manager as of the review period end date, combining DPI and RVPI.',
    `reporting_quality_score` DECIMAL(5,2) COMMENT 'Numeric score assessing the accuracy, completeness, timeliness, and transparency of the managers investor reporting and capital account statements.',
    `review_period_end_date` DATE COMMENT 'End date of the performance and qualitative assessment window covered by this evaluation.',
    `review_period_start_date` DATE COMMENT 'Start date of the performance and qualitative assessment window covered by this evaluation (e.g., beginning of the annual review period).',
    `risk_management_notes` STRING COMMENT 'Qualitative narrative on the managers risk governance, portfolio risk controls, and alignment with the pension funds risk appetite.',
    `risk_management_score` DECIMAL(5,2) COMMENT 'Numeric score evaluating the robustness of the managers risk management framework, including VaR, drawdown controls, and stress testing practices.',
    `sla_compliance_rating` STRING COMMENT 'Assessment of the managers adherence to Service Level Agreement (SLA) obligations including reporting timeliness, data quality, and operational deliverables.. Valid values are `fully_compliant|minor_breaches|material_breaches|non_compliant`',
    `team_stability_notes` STRING COMMENT 'Qualitative narrative on key-person risk, team tenure, succession planning, and any notable personnel changes since the last evaluation.',
    `team_stability_score` DECIMAL(5,2) COMMENT 'Numeric score reflecting the stability, depth, and continuity of the managers investment team, including key-person risk assessment.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp recording the most recent modification to this evaluation record, supporting audit trail and change tracking requirements.',
    `watch_list_flag` BOOLEAN COMMENT 'Indicates whether the manager has been placed on the internal watch list as a result of this evaluation, triggering enhanced monitoring and reporting.',
    CONSTRAINT pk_evaluation PRIMARY KEY(`evaluation_id`)
) COMMENT 'Records periodic qualitative and quantitative evaluations of each external manager, covering investment process assessment, team stability, operational infrastructure, risk management quality, ESG integration maturity, and overall conviction rating.';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`risk_assessment` (
    `risk_assessment_id` BIGINT COMMENT 'Unique surrogate identifier for each external manager risk assessment record in the silver layer lakehouse.',
    `approver_employee_id` BIGINT COMMENT 'Reference to the IC member or delegated authority who formally approved this risk assessment. Links to the staff/user master.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: Manager risk assessments must be conducted under defined economic scenarios for regulatory stress testing (e.g., IORP II, local pension regulations).',
    `employee_id` BIGINT COMMENT 'Reference to the internal investment professional responsible for conducting and authoring this risk assessment. Links to the staff/user master.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (GP, sub-advisor, or FoF manager) being assessed. Links to the manager master record.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (GP, sub-advisor, or FoF manager) being assessed. Links to the manager master record.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the specific mandate (LPA, SMA, or co-investment agreement) under which this risk assessment is conducted, if applicable.',
    `risk_model_id` BIGINT COMMENT 'Foreign key linking to risk.model. Business justification: Operational Due Diligence (ODD) assessments must document which risk model framework was applied. Pension fund compliance requires traceability of methodology used in manager risk scoring.',
    `adverse_media_flag` BOOLEAN COMMENT 'Indicates whether adverse media screening identified material negative news about the manager, its principals, or affiliated entities during the assessment period.',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time when the risk assessment was formally approved by the Investment Committee or delegated authority, marking the record as authoritative.',
    `assessment_date` DATE COMMENT 'The principal business date on which the risk assessment was formally conducted or the assessment period end date used for scoring and conclusions.',
    `assessment_methodology_version` STRING COMMENT 'Version identifier of the internal risk assessment scoring methodology applied (e.g., v2.1), enabling comparability across assessments and audit of methodology changes.. Valid values are `^v[0-9]+.[0-9]+$`',
    `assessment_notes` STRING COMMENT 'Free-text narrative field capturing qualitative analyst commentary, contextual observations, and IC discussion points not captured in structured scoring fields.',
    `assessment_reference` STRING COMMENT 'Externally-visible unique reference code for this risk assessment, used in IC submissions, ODD reports, and regulatory correspondence. Format: RA-YYYY-NNNNNN.. Valid values are `^RA-[0-9]{4}-[0-9]{6}$`',
    `assessment_status` STRING COMMENT 'Current lifecycle state of the risk assessment document: draft, in_review, pending_ic_approval, approved, rejected, or superseded by a newer assessment.. Valid values are `draft|in_review|pending_ic_approval|approved|rejected|superseded`',
    `assessment_type` STRING COMMENT 'Classification of the assessment trigger: initial (new manager onboarding), periodic (scheduled review), event_driven (triggered by material event), pre_commitment, post_investment, or termination.. Valid values are `initial|periodic|event_driven|pre_commitment|post_investment|termination`',
    `aum_at_assessment` DECIMAL(20,2) COMMENT 'Total AUM of the external manager at the time of this risk assessment, used to assess scale, stability, and viability risk. Expressed in the reporting currency.',
    `aum_currency` STRING COMMENT 'ISO 4217 three-letter currency code in which the managers AUM at assessment is denominated (e.g., USD, GBP).. Valid values are `^[A-Z]{3}$`',
    `business_continuity_rating` STRING COMMENT 'Assessment of the managers business continuity and disaster recovery capabilities, including documented BCP, testing frequency, and technology resilience.. Valid values are `satisfactory|needs_improvement|unsatisfactory|not_assessed`',
    `concentration_risk_rating` STRING COMMENT 'Categorical rating for concentration risk, reflecting the funds exposure to single issuers, sectors, geographies, or counterparties relative to mandate limits.. Valid values are `low|medium|high|critical`',
    `concentration_risk_score` DECIMAL(5,2) COMMENT 'Quantitative score measuring the degree of portfolio or counterparty concentration risk attributable to this manager, including single-name, sector, and geographic concentration.',
    `counterparty_risk_rating` STRING COMMENT 'Categorical rating for counterparty risk, covering prime broker credit quality, CSA terms, CCP usage, and collateral management practices of the external manager.. Valid values are `low|medium|high|critical`',
    `counterparty_risk_score` DECIMAL(5,2) COMMENT 'Quantitative score assessing the credit and settlement risk arising from the managers prime brokerage, custodian, OTC derivative, and other counterparty relationships.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk assessment record was first created in the system, used for audit trail and data lineage tracking.',
    `critical_findings_count` BIGINT COMMENT 'Number of critical-severity findings identified in this assessment requiring immediate remediation or escalation to the Investment Committee.',
    `cybersecurity_rating` STRING COMMENT 'Assessment of the managers cybersecurity posture, including data protection controls, incident response capability, and third-party security certifications (ISO 27001, SOC 2).. Valid values are `satisfactory|needs_improvement|unsatisfactory|not_assessed`',
    `enforcement_action_exists` BOOLEAN COMMENT 'Indicates whether the manager or its principals have been subject to any regulatory enforcement actions, sanctions, or material investigations within the lookback period.',
    `esg_risk_rating` STRING COMMENT 'Categorical ESG risk rating for the manager based on MSCI ESG scores, PRI assessment, TCFD alignment, and internal responsible investment due diligence findings.. Valid values are `low|medium|high|critical`',
    `esg_risk_score` DECIMAL(5,2) COMMENT 'Quantitative ESG risk score for the manager, reflecting the quality of ESG integration in their investment process, SFDR classification, and PRI signatory status.',
    `keyman_clause_exists` BOOLEAN COMMENT 'Indicates whether the governing LPA or mandate agreement contains a key-man clause that triggers suspension of capital calls or investor rights upon departure of named individuals.',
    `keyman_risk_rating` STRING COMMENT 'Categorical rating for key-man risk. Elevated when the managers investment process is highly dependent on a single portfolio manager or founding partner.. Valid values are `low|medium|high|critical`',
    `keyman_risk_score` DECIMAL(5,2) COMMENT 'Quantitative score assessing the degree of dependency on one or more key investment professionals at the manager firm, and the adequacy of succession planning.',
    `liquidity_risk_rating` STRING COMMENT 'Categorical rating for liquidity risk, reflecting the managers redemption terms, lock-up provisions, side pocket usage, and alignment with the pension funds liquidity needs.. Valid values are `low|medium|high|critical`',
    `liquidity_risk_score` DECIMAL(5,2) COMMENT 'Quantitative score assessing the liquidity risk of the managers strategy, including redemption terms, lock-up periods, gate provisions, and underlying asset liquidity profile.',
    `next_review_date` DATE COMMENT 'Date by which the next periodic risk assessment of this manager must be completed, driven by risk rating and mandate review cycle policy.',
    `odd_findings_summary` STRING COMMENT 'Narrative summary of key findings from the Operational Due Diligence (ODD) review, including material control weaknesses, remediation actions, and outstanding items.',
    `open_findings_count` BIGINT COMMENT 'Number of unresolved risk findings or remediation action items outstanding from this assessment, used to track manager remediation progress and escalation triggers.',
    `operational_risk_rating` STRING COMMENT 'Categorical rating for operational risk derived from ODD findings. Covers technology infrastructure, middle/back-office controls, disaster recovery, and process robustness.. Valid values are `low|medium|high|critical`',
    `operational_risk_score` DECIMAL(5,2) COMMENT 'Quantitative score reflecting the managers operational risk exposure based on ODD findings, including technology, process, controls, and business continuity assessments.',
    `overall_risk_rating` STRING COMMENT 'Composite risk rating assigned to the external manager based on aggregated scores across all risk dimensions. Drives review frequency and mandate oversight intensity.. Valid values are `low|medium|high|critical`',
    `overall_risk_score` DECIMAL(5,2) COMMENT 'Quantitative composite risk score (e.g., 0.00–100.00) aggregating all risk dimension scores using the internal risk scoring methodology for this manager.',
    `pension_fund_aum_pct` DECIMAL(7,4) COMMENT 'The pension funds total committed capital to this manager expressed as a percentage of the managers total AUM, used to assess investor concentration and influence risk.',
    `recommended_action` STRING COMMENT 'Formal recommendation arising from this risk assessment regarding the ongoing mandate relationship. Drives IC agenda items and mandate management actions.. Valid values are `continue|continue_with_conditions|place_on_watch|reduce_exposure|terminate|defer_decision`',
    `regulatory_risk_rating` STRING COMMENT 'Categorical rating for regulatory risk, including the managers regulatory status, history of enforcement actions, and compliance with KYC/AML and reporting obligations.. Valid values are `low|medium|high|critical`',
    `regulatory_risk_score` DECIMAL(5,2) COMMENT 'Quantitative score reflecting the managers exposure to regulatory sanctions, licensing issues, enforcement actions, or non-compliance with applicable regulations.',
    `regulatory_status` STRING COMMENT 'Current regulatory registration status of the external manager with applicable regulators (SEC, FCA, ESMA, etc.) at the time of assessment.. Valid values are `registered|exempt|pending_registration|suspended|deregistered`',
    `reputational_risk_rating` STRING COMMENT 'Categorical rating for reputational risk, covering adverse media coverage, ESG controversies, sanctions screening results, and alignment with PRI commitments.. Valid values are `low|medium|high|critical`',
    `reputational_risk_score` DECIMAL(5,2) COMMENT 'Quantitative score assessing reputational risk associated with the manager, including adverse media, ESG controversies, litigation, and alignment with the pension funds values.',
    `sanctions_screening_status` STRING COMMENT 'Result of sanctions and watchlist screening for the manager and its principals against OFAC, UN, EU, and other applicable sanctions lists as part of KYC/AML due diligence.. Valid values are `clear|flagged|pending|escalated`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this risk assessment record, supporting audit trail and change management requirements.',
    `watch_list_flag` BOOLEAN COMMENT 'Indicates whether the manager has been placed on the internal watch list as a result of this assessment, triggering enhanced monitoring and potential mandate review.',
    CONSTRAINT pk_risk_assessment PRIMARY KEY(`risk_assessment_id`)
) COMMENT 'Captures structured risk assessments of each external manager covering operational risk (ODD findings), key-man risk, concentration risk, counterparty risk, regulatory risk, and reputational risk.';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`sla_agreement` (
    `sla_agreement_id` BIGINT COMMENT 'Unique surrogate identifier for each SLA agreement record between the pension fund and an external manager or fund administrator.',
    `employee_id` BIGINT COMMENT 'Reference to the internal pension fund employee (typically a Portfolio Manager or Manager Relations Officer) who owns and is accountable for monitoring this SLA agreement.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager, General Partner (GP), sub-advisor, or fund administrator party that is counterparty to this SLA agreement.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager, General Partner (GP), sub-advisor, or fund administrator party that is counterparty to this SLA agreement.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the investment mandate (LPA, SMA, co-investment agreement) under which this SLA agreement operates, linking SLA obligations to the governing contractual mandate.',
    `agreement_name` STRING COMMENT 'Human-readable descriptive name of the SLA agreement, typically referencing the manager name and scope (e.g., Blackstone PE Fund IV — NAV Reporting SLA).',
    `agreement_type` STRING COMMENT 'Classification of the SLA agreement by functional scope. [ENUM-REF-CANDIDATE: reporting_sla|operational_sla|custody_sla|valuation_sla|compliance_sla|administrator_sla — promote to reference product]. Valid values are `reporting_sla|operational_sla|custody_sla|valuation_sla|compliance_sla|administrator_sla`',
    `agreement_version` STRING COMMENT 'Version identifier of the SLA agreement document, incremented upon each formal amendment or renegotiation (e.g., v1.0, v2.1).. Valid values are `^v[0-9]+.[0-9]+$`',
    `asset_class_scope` STRING COMMENT 'Asset class or classes covered by this SLA agreement, defining the investment domain to which the service-level obligations apply. [ENUM-REF-CANDIDATE: promote to reference product if multi-value needed]',
    `audited_financials_delivery_days` BIGINT COMMENT 'Maximum number of calendar days after fiscal year-end by which the manager must deliver audited financial statements to the pension fund under this SLA.',
    `auto_renewal_flag` BOOLEAN COMMENT 'Indicates whether the SLA agreement automatically renews upon expiry unless either party provides written notice of termination within the notice period.',
    `breach_notification_hours` BIGINT COMMENT 'Maximum number of hours within which the manager must notify the pension fund of an SLA breach or material reporting failure, as stipulated in the agreement.',
    `capital_account_delivery_days` BIGINT COMMENT 'Maximum number of business days after period end by which the manager must deliver capital account statements showing Paid-In Capital (PIC), distributions, and RVPI.',
    `capital_call_notice_days` BIGINT COMMENT 'Minimum number of business days advance notice the GP must provide to the pension fund before issuing a capital call (drawdown notice), as stipulated in the SLA and LPA.',
    `compliance_cert_delivery_days` BIGINT COMMENT 'Maximum number of business days after period end by which the manager must deliver compliance certificates confirming adherence to investment guidelines and regulatory requirements.',
    `counterparty_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier (LEI) of the external manager or fund administrator that is counterparty to this SLA, used for regulatory reporting and entity disambiguation.. Valid values are `^[A-Z0-9]{18}[0-9]{2}$`',
    `counterparty_name` STRING COMMENT 'Full legal name of the external manager, GP, sub-advisor, or fund administrator that is the counterparty to this SLA agreement, as registered with the relevant regulatory authority.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this SLA agreement record was first created in the data platform, providing the audit trail creation marker per data governance policy.',
    `custodian_involved` BOOLEAN COMMENT 'Indicates whether a third-party custodian (e.g., State Street, Northern Trust) is a party to or referenced in the SLA obligations, particularly for settlement and NAV reporting.',
    `data_delivery_channel` STRING COMMENT 'Transmission channel through which the manager delivers reports and data to the pension fund under this SLA (e.g., SFTP, API, custodian platform portal). [ENUM-REF-CANDIDATE: sftp|api|email|portal|swift|custodian_platform|other — 7 candidates stripped',
    `data_delivery_format` STRING COMMENT 'Contractually agreed file or transmission format in which the manager must deliver reports and data under this SLA (e.g., SWIFT, SFTP, API feed, Excel). [ENUM-REF-CANDIDATE: promote to reference product]',
    `distribution_notice_days` BIGINT COMMENT 'Minimum number of business days advance notice the GP must provide before making a distribution to the pension fund, enabling treasury and cash management planning.',
    `effective_date` DATE COMMENT 'Date on which the SLA agreement becomes binding and service-level obligations commence between the pension fund and the counterparty.',
    `esg_report_delivery_days` BIGINT COMMENT 'Maximum number of business days after period end by which the manager must deliver ESG and responsible investment reports, including GHG emissions data and TCFD disclosures.',
    `esg_reporting_required` BOOLEAN COMMENT 'Indicates whether the SLA mandates periodic ESG reporting from the manager, including PRI alignment, TCFD disclosures, and GHG emissions data.',
    `expiry_date` DATE COMMENT 'Date on which the SLA agreement is scheduled to expire or terminate. Null for open-ended agreements. Triggers renewal workflow when approaching.',
    `fund_admin_involved` BOOLEAN COMMENT 'Indicates whether a separate fund administrator (distinct from the GP) is a party to the SLA obligations for NAV calculation, capital account statements, and investor reporting.',
    `gips_compliant_reporting` BOOLEAN COMMENT 'Indicates whether the manager is contractually required to deliver performance reports in compliance with CFA Institute GIPS standards under this SLA.',
    `governing_law_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction whose laws govern the SLA agreement (e.g., CAN, GBR, USA).. Valid values are `^[A-Z]{3}$`',
    `independent_valuation_required` BOOLEAN COMMENT 'Indicates whether the SLA mandates an independent third-party valuation agent for illiquid or private asset valuations, as required for NAV/GAV determination.',
    `last_review_date` DATE COMMENT 'Date on which the most recent formal SLA performance review was completed between the pension fund and the manager.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this SLA agreement record in the data platform, supporting audit trail and change tracking requirements.',
    `nav_delivery_deadline_days` BIGINT COMMENT 'Maximum number of business days after the reference period end date by which the manager must deliver the NAV statement, as stipulated in the SLA.',
    `nav_delivery_frequency` STRING COMMENT 'Contractually agreed frequency at which the manager or administrator must deliver NAV statements to the pension fund under this SLA.. Valid values are `daily|weekly|monthly|quarterly|semi_annual|annual`',
    `next_review_date` DATE COMMENT 'Scheduled date of the next formal SLA performance review between the pension fund and the manager, used to trigger review workflow in the manager oversight process.',
    `notes` STRING COMMENT 'Free-text field for capturing material qualifications, special conditions, side-letter provisions, or operational notes relevant to this SLA agreement that are not captured in structured fields.',
    `penalty_basis_points` DECIMAL(10,4) COMMENT 'Fee rebate or penalty rate expressed in basis points (bps) applied to management fees upon confirmed SLA breach, as defined in the agreement.',
    `penalty_clause_applicable` BOOLEAN COMMENT 'Indicates whether financial penalty or fee rebate clauses are contractually applicable upon SLA breach by the manager or fund administrator.',
    `performance_report_delivery_days` BIGINT COMMENT 'Maximum number of business days after period end by which the manager must deliver performance attribution reports including TWR, MWR, IRR, MOIC, TVPI, DPI, and RVPI metrics.',
    `primary_contact_email` STRING COMMENT 'Email address of the primary relationship contact at the external manager responsible for SLA reporting delivery and breach notifications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_contact_name` STRING COMMENT 'Full name of the primary relationship contact at the external manager or fund administrator responsible for SLA compliance and reporting delivery.',
    `renewal_notice_days` BIGINT COMMENT 'Number of calendar days prior to expiry by which either party must provide written notice to prevent automatic renewal or to initiate renegotiation of the SLA.',
    `reporting_currency` STRING COMMENT 'ISO 4217 three-letter currency code in which all financial reports and NAV statements under this SLA must be delivered (e.g., USD, GBP).. Valid values are `^[A-Z]{3}$`',
    `review_frequency` STRING COMMENT 'Agreed frequency at which the pension fund and manager formally review SLA performance, compliance metrics, and potential amendments.. Valid values are `monthly|quarterly|semi_annual|annual|ad_hoc`',
    `sla_agreement_status` STRING COMMENT 'Current lifecycle state of the SLA agreement, governing whether obligations are enforceable and being monitored.. Valid values are `draft|active|suspended|terminated|expired|under_review`',
    `sla_reference_number` STRING COMMENT 'Externally-known alphanumeric reference code assigned to this SLA agreement, used in correspondence with the manager and in regulatory reporting.. Valid values are `^SLA-[A-Z0-9]{4,20}$`',
    `source_system_reference_code` STRING COMMENT 'Native identifier of this SLA agreement record in the originating operational system (e.g., eFront deal ID, DealCloud contract ID), enabling cross-system reconciliation.',
    `termination_date` DATE COMMENT 'Actual date on which the SLA agreement was terminated, if applicable. Null for active agreements. Distinct from expiry_date which is the scheduled end.',
    `termination_reason` STRING COMMENT 'Reason code for the termination of the SLA agreement, used for manager oversight analytics and regulatory audit trail. [ENUM-REF-CANDIDATE: promote to reference product if extended]',
    `valuation_methodology` STRING COMMENT 'Contractually agreed valuation methodology the manager must apply when determining NAV and asset values reported under this SLA. [ENUM-REF-CANDIDATE: promote to reference product if extended]',
    CONSTRAINT pk_sla_agreement PRIMARY KEY(`sla_agreement_id`)
) COMMENT 'SSOT for all service-level commitments and individual reporting obligations between the pension fund and each external manager or fund administrator. Covers reporting delivery timelines and line-item obligations (NAV, capital account statements, audited';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`sla_breach` (
    `sla_breach_id` BIGINT COMMENT 'Unique surrogate identifier for each SLA breach event record within the manager domain.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (GP, sub-advisor, or FoF manager) whose SLA obligation was breached.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (GP, sub-advisor, or FoF manager) whose SLA obligation was breached.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the specific mandate (LPA, SMA, or co-investment agreement) under which the SLA obligation was defined and breached.',
    `sla_agreement_id` BIGINT COMMENT 'Reference to the specific SLA obligation definition that was breached, as catalogued in the SLA obligation register.',
    `sla_obligation_id` BIGINT COMMENT 'Reference to the specific SLA obligation definition that was breached, as catalogued in the SLA obligation register.',
    `affected_asset_class` STRING COMMENT 'The asset class of the mandate affected by the breach, enabling portfolio-level SLA compliance analysis across the funds diversified allocation. [ENUM-REF-CANDIDATE',
    `breach_category` STRING COMMENT 'Functional category of the SLA obligation that was breached. [ENUM-REF-CANDIDATE: reporting|valuation|capital_call|distribution|compliance|operational|esg|risk_disclosure — promote to reference product]',
    `breach_date` DATE COMMENT 'The actual date on which the SLA obligation was breached (i.e., the obligation due date passed without fulfilment). Principal business event date for this record.',
    `breach_description` STRING COMMENT 'Detailed narrative describing the nature of the breach event, what was not delivered, and the circumstances surrounding the failure.',
    `breach_detected_date` DATE COMMENT 'The calendar date on which the SLA breach was first identified or detected by the internal oversight team or monitoring system.',
    `breach_detected_timestamp` TIMESTAMP COMMENT 'Precise timestamp at which the SLA breach was first detected, used for SLA measurement calculations and audit trail purposes.',
    `breach_reference_number` STRING COMMENT 'Externally-visible unique reference number assigned to this breach event, used in manager correspondence, escalation notices, and regulatory reporting.. Valid values are `^SLA-BR-[0-9]{4}-[0-9]{6}$`',
    `breach_status` STRING COMMENT 'Current lifecycle status of the breach event, tracking progression from initial detection through resolution or waiver. [ENUM-REF-CANDIDATE: open|under_review|remediation_in_progress|resolved|waived|escalated — promote to reference product]. Valid values are `open|under_review|remediation_in_progress|resolved|waived|escalated`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp at which this SLA breach record was first created in the data platform, providing the audit trail creation marker.',
    `days_overdue` BIGINT COMMENT 'Number of calendar days elapsed between the SLA obligation due date and the breach detection date, quantifying the extent of the delay at point of detection.',
    `days_to_resolution` BIGINT COMMENT 'Number of calendar days elapsed between the breach detection date and the resolution date. Null if unresolved. Used for manager performance benchmarking.',
    `detection_source` STRING COMMENT 'The mechanism or source through which the SLA breach was identified, distinguishing automated system alerts from manual reviews or manager self-reporting.. Valid values are `automated_monitoring|internal_review|manager_self_report|third_party_audit|regulatory_inquiry`',
    `escalation_date` DATE COMMENT 'Date on which the breach was formally escalated to the current escalation level. Null if no escalation has occurred.',
    `escalation_level` STRING COMMENT 'Current escalation tier to which this breach has been raised within the internal governance hierarchy, from relationship manager through to Investment Committee (IC).. Valid values are `none|relationship_manager|head_of_manager_oversight|cio|investment_committee`',
    `esg_related` BOOLEAN COMMENT 'Indicates whether the breached SLA obligation relates to Environmental, Social, and Governance (ESG) reporting or stewardship commitments under the mandate.',
    `financial_impact_amount` DECIMAL(18,2) COMMENT 'Estimated or actual financial impact of the breach on the fund, including any NAV misstatement, delayed distributions, or operational losses.',
    `financial_impact_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the financial impact amount.. Valid values are `^[A-Z]{3}$`',
    `impact_assessment` STRING COMMENT 'Narrative assessment of the actual or potential impact of the breach on fund operations, NAV accuracy, beneficiary interests, or regulatory compliance.',
    `internal_owner` STRING COMMENT 'Name or identifier of the internal relationship manager or oversight officer responsible for managing and resolving this breach event.',
    `is_contractual_penalty_triggered` BOOLEAN COMMENT 'Indicates whether the breach has triggered a contractual penalty, fee reduction, or other financial remedy as defined in the LPA or SMA.',
    `is_regulatory_reportable` BOOLEAN COMMENT 'Indicates whether this breach must be disclosed to a regulatory body (e.g., FCA, SEC) under applicable reporting obligations.',
    `is_repeat_breach` BOOLEAN COMMENT 'Indicates whether this breach is a recurrence of a previously recorded breach of the same SLA obligation by the same manager, flagging systemic non-compliance.',
    `manager_response` STRING COMMENT 'Verbatim or summarised formal response provided by the external manager acknowledging the breach and explaining their position or corrective intent.',
    `manager_response_date` DATE COMMENT 'Date on which the external manager formally responded to the breach notification. Used to measure manager responsiveness against SLA response time commitments.',
    `mandate_type` STRING COMMENT 'Type of mandate agreement under which the breached SLA obligation was defined, distinguishing LPA, SMA, co-investment, and Fund of Funds (FoF) structures.. Valid values are `LPA|SMA|co_investment|FoF`',
    `obligation_description` STRING COMMENT 'Narrative description of the specific SLA obligation that was breached, including the contractual clause reference and expected deliverable.',
    `penalty_amount` DECIMAL(18,2) COMMENT 'Monetary value of the contractual penalty or fee reduction applied as a result of this breach, denominated in the mandate currency. Null if no penalty triggered.',
    `penalty_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the penalty amount. Aligns with the mandate base currency.. Valid values are `^[A-Z]{3}$`',
    `prior_breach_count` BIGINT COMMENT 'Number of prior breach events recorded for the same SLA obligation and manager within the current mandate term, used for escalation threshold monitoring.',
    `regulatory_body` STRING COMMENT 'The regulatory authority to which this breach must be reported, if applicable. Populated only when is_regulatory_reportable is true.. Valid values are `SEC|FCA|ESMA|IOSCO|none`',
    `regulatory_report_date` DATE COMMENT 'Date on which the breach was formally reported to the relevant regulatory authority. Null if not yet reported or not required.',
    `remediation_plan` STRING COMMENT 'Description of the corrective action plan agreed with the manager to address the breach, prevent recurrence, and restore SLA compliance.',
    `remediation_target_date` DATE COMMENT 'Agreed target date by which the manager is expected to complete the remediation plan and restore full SLA compliance.',
    `resolution_date` DATE COMMENT 'The date on which the breach was formally resolved, remediated, or waived. Null if the breach remains open or in progress.',
    `root_cause_category` STRING COMMENT 'Categorical classification of the root cause of the breach. [ENUM-REF-CANDIDATE: system_failure|process_failure|data_error|staffing|third_party|regulatory_change|force_majeure|unknown — promote to reference product]',
    `root_cause_description` STRING COMMENT 'Detailed narrative of the root cause analysis conducted by the manager or internal oversight team explaining why the SLA obligation was not met.',
    `severity_classification` STRING COMMENT 'Categorical severity rating assigned to the breach based on its impact on fund operations, regulatory obligations, or beneficiary interests.. Valid values are `critical|high|medium|low`',
    `sla_obligation_date` DATE COMMENT 'The contractually agreed date by which the manager was required to fulfil the SLA obligation that was subsequently breached.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp at which this SLA breach record was most recently modified, supporting audit trail and change tracking requirements.',
    `waiver_approved_date` DATE COMMENT 'Date on which the waiver of the breach was formally approved by the authorised internal governance body. Null if no waiver granted.',
    `waiver_justification` STRING COMMENT 'Narrative justification for waiving the breach without penalty or escalation, including approver details. Populated only when breach_status is waived.',
    CONSTRAINT pk_sla_breach PRIMARY KEY(`sla_breach_id`)
) COMMENT 'Transactional record of each SLA breach event by an external manager, capturing breach date, SLA obligation breached, severity classification, root cause, manager response, remediation plan, and resolution date.';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`watchlist` (
    `watchlist_id` BIGINT COMMENT 'Unique surrogate identifier for a manager watchlist record. Primary key for this entity.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager or General Partner (GP) placed on the watchlist. Links to the manager master record.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager or General Partner (GP) placed on the watchlist. Links to the manager master record.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the specific mandate (LPA, SMA, co-investment agreement) associated with this watchlist entry, if applicable.',
    `approving_officer` STRING COMMENT 'Name or employee identifier of the senior officer (e.g., CIO, Head of External Managers) who formally approved the watchlist placement decision.',
    `asset_class` STRING COMMENT 'The primary asset class of the managers mandate under watchlist review. Enables asset-class-level watchlist analytics and risk aggregation.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `aum_at_placement` DECIMAL(20,2) COMMENT 'The pension funds total committed or invested capital with this manager (AUM) at the time of watchlist placement, in base currency. Used to assess financial exposure.',
    `aum_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the AUM at placement amount (e.g., USD, GBP).. Valid values are `^[A-Z]{3}$`',
    `watchlist_category` STRING COMMENT 'Primary classification of the reason for watchlist placement. [ENUM-REF-CANDIDATE: performance|key_man|regulatory|odd_finding|strategic_misalignment|esg_concern|fee_dispute|legal — promote to reference product]. Valid values are `performance|key_man|regulatory|odd_finding|strategic_misalignment|esg_concern`',
    `consecutive_underperformance_quarters` BIGINT COMMENT 'Number of consecutive calendar quarters in which the manager has underperformed their agreed benchmark or hurdle rate, as recorded at the time of watchlist placement.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this watchlist record was first created in the system, used for audit trail and data lineage purposes.',
    `engagement_log_summary` STRING COMMENT 'Summary of formal engagement activities with the manager since watchlist placement, including calls, meetings, and written correspondence. Full log maintained in DealCloud.',
    `esg_concern_category` STRING COMMENT 'Classifies the ESG dimension driving the concern: environmental (E), social (S), governance (G), or a combination. Populated when esg_concern_flag is true.. Valid values are `environmental|social|governance|combined`',
    `esg_concern_flag` BOOLEAN COMMENT 'Indicates whether ESG-related concerns (e.g., governance failures, environmental violations, social controversies) contributed to the watchlist placement.',
    `ic_approval_required` BOOLEAN COMMENT 'Indicates whether formal Investment Committee (IC) approval is required to resolve or close this watchlist entry, based on AUM exposure or severity level.',
    `ic_decision` STRING COMMENT 'The formal decision recorded by the Investment Committee (IC) following review of the watchlist entry. Drives downstream mandate management actions.. Valid values are `continue_monitoring|initiate_redemption|terminate_mandate|defer|no_action`',
    `ic_review_date` DATE COMMENT 'The date on which the Investment Committee (IC) formally reviewed this watchlist entry and issued a decision or deferred for further monitoring.',
    `key_man_clause_triggered` BOOLEAN COMMENT 'Indicates whether the formal key-man clause in the Limited Partnership Agreement (LPA) or mandate has been contractually triggered, potentially suspending capital calls or enabling early redemption.',
    `key_man_departure_flag` BOOLEAN COMMENT 'Indicates whether the watchlist placement was triggered by the departure or announced departure of a key investment professional covered under a key-man clause in the LPA or mandate agreement.',
    `last_review_date` DATE COMMENT 'The date of the most recent formal review of this watchlist entry, used to track review cadence compliance and identify overdue reviews.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'The timestamp of the most recent update to this watchlist record, supporting audit trail, change tracking, and incremental data pipeline processing.',
    `lead_analyst` STRING COMMENT 'Name or employee identifier of the internal investment analyst or portfolio manager responsible for monitoring and reporting on this watchlist entry.',
    `manager_response_date` DATE COMMENT 'The date on which the external manager formally responded to the watchlist notification. Populated when manager_response_received is true.',
    `manager_response_received` BOOLEAN COMMENT 'Indicates whether the external manager has formally responded to the watchlist notification and provided a remediation plan or explanation.',
    `manager_strategy` STRING COMMENT 'The specific investment strategy employed by the manager under the mandate (e.g., buyout, venture capital, core real estate, direct lending, long/short equity, infrastructure core-plus).',
    `new_capital_deployment_suspended` BOOLEAN COMMENT 'Indicates whether new capital commitments or capital calls to this manager have been suspended as a result of the watchlist placement, pending resolution.',
    `next_review_date` DATE COMMENT 'The date of the next scheduled formal review of this watchlist entry by the internal manager oversight or risk team.',
    `odd_finding_flag` BOOLEAN COMMENT 'Indicates whether a material finding from an Operational Due Diligence (ODD) review contributed to the watchlist placement, such as control failures, valuation concerns, or compliance gaps.',
    `odd_finding_summary` STRING COMMENT 'Concise summary of the material ODD findings that contributed to watchlist placement. Classified confidential due to sensitive operational assessment content.',
    `performance_concern_flag` BOOLEAN COMMENT 'Indicates whether underperformance relative to benchmark or hurdle rate is a contributing factor to the watchlist placement. Enables performance-driven watchlist analytics.',
    `placement_date` DATE COMMENT 'The formal date on which the manager was officially placed on the internal watchlist following Investment Committee or risk team approval.',
    `portfolio_exposure_pct` DECIMAL(7,4) COMMENT 'The pension funds exposure to this manager as a percentage of total fund AUM at the time of watchlist placement. Used for concentration risk assessment.',
    `redemption_notice_date` DATE COMMENT 'The date on which the formal redemption or withdrawal notice was issued to the manager. Populated when redemption_notice_issued is true.',
    `redemption_notice_issued` BOOLEAN COMMENT 'Indicates whether a formal redemption or withdrawal notice has been issued to the manager as a result of the watchlist review process.',
    `reference_code` STRING COMMENT 'Externally-known unique alphanumeric code assigned to this watchlist entry for cross-system referencing and audit trail purposes (e.g., WL-2024-000123).. Valid values are `^WL-[0-9]{4}-[0-9]{6}$`',
    `regulatory_body` STRING COMMENT 'Name of the regulatory authority conducting the investigation or enforcement action against the manager (e.g., SEC, FCA, ESMA). Populated when regulatory_investigation_flag is true.',
    `regulatory_investigation_flag` BOOLEAN COMMENT 'Indicates whether the manager is subject to an active regulatory investigation by a governing body (e.g., SEC, FCA) that contributed to watchlist placement.',
    `remediation_plan_agreed` BOOLEAN COMMENT 'Indicates whether a formal remediation plan has been agreed between the pension fund and the external manager to address the watchlist concerns.',
    `remediation_plan_deadline` DATE COMMENT 'The agreed deadline by which the manager must demonstrate completion of remediation actions. Populated when remediation_plan_agreed is true.',
    `resolution_date` DATE COMMENT 'The actual date on which the watchlist entry was formally resolved or closed, either through remediation, redemption, or termination of the mandate.',
    `resolution_outcome` STRING COMMENT 'The formal outcome decision upon closure of the watchlist entry. Indicates whether the manager relationship was retained, redeemed, or terminated following review.. Valid values are `retained|redeemed|terminated|monitoring_extended|escalated_to_ic`',
    `review_frequency` STRING COMMENT 'The required frequency of formal internal review for this watchlist entry, determined by severity level and asset class. Drives the monitoring calendar.. Valid values are `monthly|quarterly|semi_annual|annual|ad_hoc`',
    `severity_level` STRING COMMENT 'Internal risk severity rating assigned to the watchlist entry, reflecting the urgency and potential impact on the pension fund portfolio. Drives escalation and review frequency.. Valid values are `low|medium|high|critical`',
    `strategic_misalignment_flag` BOOLEAN COMMENT 'Indicates whether the watchlist placement is driven by a strategic misalignment between the managers investment approach and the pension funds evolving Strategic Asset Allocation (SAA) or mandate objectives.',
    `target_resolution_date` DATE COMMENT 'The target date by which the watchlist concerns are expected to be resolved or a formal decision (retain, redeem, terminate) is required from the Investment Committee.',
    `trigger_date` DATE COMMENT 'The date on which the triggering event or finding occurred that led to watchlist placement. Distinct from the formal placement date.',
    `trigger_reason` STRING COMMENT 'Detailed narrative description of the specific event or finding that triggered placement of the manager on the watchlist (e.g., lead PM departure, SEC investigation opened, consecutive quarters of underperformance).',
    `watchlist_status` STRING COMMENT 'Current lifecycle status of the watchlist entry. Active indicates ongoing monitoring; resolved indicates concerns addressed; closed indicates formal removal from watchlist.. Valid values are `active|under_review|escalated|resolved|closed`',
    CONSTRAINT pk_watchlist PRIMARY KEY(`watchlist_id`)
) COMMENT 'Tracks external managers placed on formal internal watch-list status due to performance concerns, key-man departures, regulatory investigations, ODD findings, or strategic misalignment.';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`meeting` (
    `meeting_id` BIGINT COMMENT 'Unique surrogate identifier for each formal manager interaction record within the external manager oversight domain.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the deal pipeline record if this meeting is linked to an active origination or due diligence process.',
    `employee_id` BIGINT COMMENT 'Reference to the internal investment professional (portfolio manager, analyst, or relationship manager) who led or organised this meeting on behalf of the pension fund.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (GP, sub-advisor, or FoF manager) who is the primary subject of this meeting.',
    `ic_governance_record_id` BIGINT COMMENT 'Foreign key linking to compliance.ic_governance_record. Business justification: IC meetings discussing managers (evaluations, mandate approvals) must link to formal IC governance records.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (GP, sub-advisor, or FoF manager) who is the primary subject of this meeting.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the specific investment mandate (LPA, SMA, or co-investment agreement) that this meeting is associated with, if applicable.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal pipeline record if this meeting is linked to an active origination or due diligence process.',
    `action_items_count` BIGINT COMMENT 'Total number of formal action items or follow-up tasks recorded as outcomes of this meeting. Supports SLA and accountability tracking.',
    `actual_date` DATE COMMENT 'The calendar date on which the meeting actually took place. May differ from scheduled_date if rescheduled.',
    `agenda_summary` STRING COMMENT 'Structured summary of the agenda items discussed, including key topics such as performance attribution, risk review, ESG updates, and operational matters.',
    `asset_class` STRING COMMENT 'Primary asset class context of the meeting (e.g., private equity, real estate, infrastructure, credit, public equities). [ENUM-REF-CANDIDATE: private_equity|real_estate|infrastructure|natural_resources|credit|public_equities|multi_asset|fund_of_funds —',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this meeting record was first created in the data platform. Supports audit trail and data lineage requirements.',
    `dd_type` STRING COMMENT 'Type of due diligence conducted during or associated with this meeting: ODD (Operational), FDD (Financial), CDD (Commercial), ESG DD, Legal DD, or not applicable.. Valid values are `odd|fdd|cdd|esg_dd|legal_dd|not_applicable`',
    `duration_minutes` BIGINT COMMENT 'Actual elapsed duration of the meeting in minutes as recorded by the meeting organiser. Supports SLA monitoring and engagement analytics.',
    `end_timestamp` TIMESTAMP COMMENT 'Precise date and time the meeting concluded, including timezone offset. Used alongside start_timestamp to derive meeting duration.',
    `escalation_flag` BOOLEAN COMMENT 'Indicates whether issues raised in this meeting require escalation to the Investment Committee (IC) or senior management for further review or decision.',
    `escalation_reason` STRING COMMENT 'Narrative description of the reason for escalation to the IC or senior management, if escalation_flag is true. Null if no escalation is required.',
    `esg_topics_discussed` BOOLEAN COMMENT 'Indicates whether Environmental, Social, and Governance (ESG) topics were formally discussed during the meeting, supporting PRI and TCFD stewardship reporting.',
    `esg_topics_summary` STRING COMMENT 'Free-text summary of ESG-related topics discussed, including climate risk, GHG targets, governance concerns, or social impact matters raised during the meeting.',
    `external_attendee_count` BIGINT COMMENT 'Number of external manager representatives (GP principals, IR staff, portfolio managers) who attended the meeting.',
    `format` STRING COMMENT 'Delivery format of the meeting: in-person, video conference, telephone, or hybrid. Relevant for travel cost attribution and engagement quality assessment.. Valid values are `in_person|video_conference|telephone|hybrid`',
    `ic_member_present` BOOLEAN COMMENT 'Indicates whether a member of the internal Investment Committee (IC) attended this meeting, relevant for governance and escalation tracking.',
    `internal_attendee_count` BIGINT COMMENT 'Number of internal pension fund staff members who attended the meeting. Used for engagement intensity and resource utilisation reporting.',
    `key_risks_identified` STRING COMMENT 'Narrative summary of material risks identified during the meeting, including operational, market, liquidity, counterparty, or ESG risks flagged by either party.',
    `location_city` STRING COMMENT 'City where the in-person or hybrid meeting took place (e.g., London, New York, Singapore). Null for fully remote meetings.',
    `location_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for the jurisdiction where the meeting physically occurred (e.g., GBR, USA, CAN). Null for fully remote meetings.. Valid values are `^[A-Z]{3}$`',
    `location_venue` STRING COMMENT 'Name of the specific venue, office, or facility where the meeting was held (e.g., manager HQ, fund administrator office, pension fund offices).',
    `manager_conviction_rating` STRING COMMENT 'Internal conviction rating assigned to the manager following this meeting: high, medium, low, or under review. Feeds into manager scoring and allocation decisions.. Valid values are `high|medium|low|under_review`',
    `manager_senior_rep_present` BOOLEAN COMMENT 'Indicates whether a senior representative (partner, CIO, or managing director) of the external manager was present. Relevant for escalation and governance quality assessment.',
    `meeting_status` STRING COMMENT 'Current lifecycle state of the meeting record: scheduled, completed, cancelled, rescheduled, or pending minutes approval.. Valid values are `scheduled|completed|cancelled|rescheduled|pending_minutes`',
    `meeting_type` STRING COMMENT 'Classification of the formal interaction: annual review, quarterly update call, on-site due diligence visit, LPAC meeting, ad-hoc escalation, or initial screening.. Valid values are `annual_review|quarterly_update|on_site_due_diligence|lpac|ad_hoc_escalation|initial_screening`',
    `minutes_approved` BOOLEAN COMMENT 'Indicates whether the formal meeting minutes have been reviewed and approved by the designated internal approver, completing the governance record.',
    `minutes_approved_date` DATE COMMENT 'Date on which the meeting minutes were formally approved. Null if minutes are pending or not yet approved.',
    `minutes_document_ref` STRING COMMENT 'Document management system reference or URL pointing to the formal meeting minutes stored in the governance platform (e.g., Diligent / BoardEffect).',
    `next_meeting_date` DATE COMMENT 'Tentative or confirmed date for the next formal interaction with this manager, supporting engagement cadence planning and SLA compliance.',
    `next_meeting_type` STRING COMMENT 'Anticipated type of the next scheduled meeting with this manager. Supports forward engagement planning and oversight cadence management.. Valid values are `annual_review|quarterly_update|on_site_due_diligence|lpac|ad_hoc_escalation|initial_screening`',
    `open_action_items_count` BIGINT COMMENT 'Number of action items from this meeting that remain open or unresolved at the time of record update. Used for follow-up governance monitoring.',
    `overall_sentiment` STRING COMMENT 'Internal qualitative assessment of the overall tone and outcome of the meeting: positive, neutral, negative, or cautionary. Supports manager scoring and watch-list decisions.. Valid values are `positive|neutral|negative|cautionary`',
    `performance_review_period` STRING COMMENT 'The reporting period covered in the performance discussion (e.g., Q3 2024, FY2023). Aligns with GIPS-compliant performance reporting cycles.. Valid values are `^(Q[1-4] [0-9]{4}|FY[0-9]{4}|[0-9]{4}-[0-9]{2})$`',
    `purpose` STRING COMMENT 'Free-text description of the primary business objective of the meeting (e.g., annual ODD review, portfolio performance discussion, ESG integration assessment).',
    `reference_number` STRING COMMENT 'Externally-visible alphanumeric reference code assigned to this meeting, used in correspondence and governance records (e.g., MTG-2024-000123).. Valid values are `^MTG-[0-9]{4}-[0-9]{6}$`',
    `scheduled_date` DATE COMMENT 'The calendar date on which the meeting was originally scheduled to occur, used for planning and SLA tracking purposes.',
    `sla_compliant` BOOLEAN COMMENT 'Indicates whether this meeting was conducted within the required SLA engagement frequency for this manager tier (e.g., annual review within 12 months of prior).',
    `source_system_ref_code` STRING COMMENT 'The native identifier of this meeting record in the originating source system (e.g., DealCloud activity ID, eFront interaction ID). Supports data lineage and reconciliation.',
    `start_timestamp` TIMESTAMP COMMENT 'Precise date and time the meeting commenced, including timezone offset. Used for duration calculation and audit trail.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this meeting record in the data platform. Supports change tracking and audit compliance.',
    `vintage_year` BIGINT COMMENT 'The vintage year of the fund or mandate under discussion, representing the year of initial capital commitment. Key context for private markets performance benchmarking.',
    `watch_list_flag` BOOLEAN COMMENT 'Indicates whether this meeting resulted in the manager being placed on or remaining on the internal watch list due to performance, operational, or ESG concerns.',
    CONSTRAINT pk_meeting PRIMARY KEY(`meeting_id`)
) COMMENT 'Records all formal interactions with external managers including annual reviews, quarterly update calls, on-site due diligence visits, LPAC meetings, and ad-hoc escalation meetings.';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`co_invest_right` (
    `co_invest_right_id` BIGINT COMMENT 'Unique surrogate identifier for a co-investment right record negotiated within an LP mandate. Primary key for this entity. Role: MASTER_AGREEMENT.',
    `fund_id` BIGINT COMMENT 'Reference to the specific GP fund vehicle (e.g., private equity fund, infrastructure fund) within which this co-investment right is embedded.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (General Partner) who granted this co-investment right. Sourced from the manager master record in Preqin/PitchBook.',
    `ic_decision_id` BIGINT COMMENT 'Foreign key linking to compliance.ic_decision. Business justification: Co-investment right exercise requires IC approval per fiduciary governance. Links co-invest rights to IC decisions that approved/modified them.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager (General Partner) who granted this co-investment right. Sourced from the manager master record in Preqin/PitchBook.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the LP mandate (LPA or SMA) under which this co-investment right was negotiated. Links to the parent mandate record in the manager domain.',
    `allocation_basis` STRING COMMENT 'Basis on which the co-investment allocation right is measured: as a percentage of deal size, percentage of LP commitment, a fixed dollar cap, or uncapped.. Valid values are `percentage_of_deal|percentage_of_commitment|fixed_dollar_cap|uncapped`',
    `allocation_cap_amount` DECIMAL(22,4) COMMENT 'Maximum dollar amount the pension fund may invest per co-investment opportunity under this right. Applicable when allocation_basis is fixed_dollar_cap. Expressed in the mandate currency.',
    `allocation_percentage` DECIMAL(8,4) COMMENT 'The percentage of each co-investment opportunity the pension fund is entitled to receive under this right. Applicable when allocation_basis is percentage-based. Expressed as a decimal (e.g., 0.1000 = 10%).',
    `annual_utilization_cap_amount` DECIMAL(22,4) COMMENT 'Maximum aggregate amount (in mandate currency) the pension fund may deploy under this co-investment right within a single calendar or fiscal year.',
    `approval_process_type` STRING COMMENT 'Internal approval process required to exercise this co-investment right: Investment Committee (IC) approval, delegated authority, CIO approval, or committee approval.. Valid values are `ic_approval|delegated_authority|cio_approval|committee_approval`',
    `asset_class` STRING COMMENT 'Primary asset class to which this co-investment right applies, aligned with the pension funds SAA framework (e.g., private equity, infrastructure, real estate).. Valid values are `private_equity|infrastructure|real_estate|natural_resources|credit|public_equity`',
    `carry_rate` DECIMAL(8,4) COMMENT 'Carried interest (carry) rate applicable to co-investments under this right, expressed as a decimal (e.g., 0.2000 = 20%). Zero for no-carry structures.',
    `confidentiality_obligation` BOOLEAN COMMENT 'Indicates whether the terms of this co-investment right are subject to confidentiality obligations under the LPA or NDA, restricting disclosure to third parties.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this co-investment right record was first created in the data platform. Supports audit trail and data lineage requirements per SOC 2 and ISO 27001.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code applicable to monetary fields on this co-investment right (e.g., USD, GBP, EUR).. Valid values are `^[A-Z]{3}$`',
    `decision_deadline_days` BIGINT COMMENT 'Maximum number of calendar days within which the pension fund must communicate its investment decision (accept or decline) after receiving a co-investment opportunity notice from the GP.',
    `effective_date` DATE COMMENT 'Date from which this co-investment right becomes binding and exercisable, as stipulated in the LPA or side-letter agreement.',
    `esg_screening_required` BOOLEAN COMMENT 'Indicates whether co-investment opportunities under this right must pass the pension funds ESG screening and responsible investment assessment prior to acceptance.',
    `exclusivity_applicable` BOOLEAN COMMENT 'Indicates whether an exclusivity window applies to this co-investment right, preventing the GP from offering the same opportunity to other LPs during the pension funds review period.',
    `exclusivity_window_days` BIGINT COMMENT 'Number of calendar days the pension fund has exclusive right to evaluate and accept or decline a co-investment opportunity before the GP may offer it to other LPs.',
    `expiry_date` DATE COMMENT 'Date on which this co-investment right expires or lapses. Null for rights that persist for the full fund term. Aligned with fund investment period end.',
    `fee_structure_type` STRING COMMENT 'Fee and carried interest structure applicable to co-investments under this right. Common structures include no-fee/no-carry (preferred), reduced fee/no carry, or full fee/full carry.. Valid values are `no_fee_no_carry|reduced_fee_no_carry|full_fee_full_carry|reduced_fee_reduced_carry|negotiated`',
    `geographic_focus` STRING COMMENT 'Geographic scope or region for which this co-investment right applies (e.g., North America, Global, Europe). Free-text to accommodate multi-region mandates.',
    `hurdle_rate` DECIMAL(8,4) COMMENT 'Preferred return threshold (hurdle rate) that must be achieved before carried interest accrues on co-investments under this right. Expressed as a decimal annual rate.',
    `last_review_date` DATE COMMENT 'Date of the most recent formal review of this co-investment right by the internal manager oversight team, confirming terms remain current and utilization is within limits.',
    `management_fee_rate` DECIMAL(8,4) COMMENT 'Annual management fee rate charged on co-investments under this right, expressed as a decimal (e.g., 0.0050 = 50 bps). Zero for no-fee structures.',
    `max_deal_size_amount` DECIMAL(22,4) COMMENT 'Maximum total deal or transaction size (in mandate currency) for which this co-investment right applies. Null if no upper deal size restriction is stipulated.',
    `min_deal_size_amount` DECIMAL(22,4) COMMENT 'Minimum total deal or transaction size (in mandate currency) for which this co-investment right is triggered. Deals below this threshold may not qualify for co-investment.',
    `negotiation_date` DATE COMMENT 'Date on which this co-investment right was formally negotiated and agreed between the pension fund and the GP, typically coinciding with LPA signing or side-letter execution.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal review of this co-investment right. Supports manager oversight calendar and governance compliance tracking.',
    `notes` STRING COMMENT 'Free-text field for additional context, negotiation history, special conditions, or qualifications associated with this co-investment right not captured in structured fields.',
    `notice_period_days` BIGINT COMMENT 'Number of calendar days the GP must provide advance notice to the pension fund before a co-investment opportunity closes, as stipulated in the LPA or side-letter.',
    `opportunities_accepted_count` BIGINT COMMENT 'Cumulative number of co-investment opportunities accepted and funded by the pension fund under this right since inception. Numerator for acceptance rate analytics.',
    `opportunities_declined_count` BIGINT COMMENT 'Cumulative number of co-investment opportunities formally declined by the pension fund under this right since inception. Supports GP relationship and pipeline analytics.',
    `opportunities_offered_count` BIGINT COMMENT 'Cumulative number of co-investment opportunities formally offered by the GP to the pension fund under this right since inception. Used for utilization tracking and GP relationship assessment.',
    `remaining_capacity_amount` DECIMAL(22,4) COMMENT 'Remaining investable capacity under the total right cap (total_right_cap_amount minus total_deployed_amount). Null if the right is uncapped. Supports portfolio construction decisions.',
    `right_name` STRING COMMENT 'Descriptive human-readable name for this co-investment right, typically referencing the fund name and right type (e.g., Buyout Fund V Co-Invest Pro-Rata Right).',
    `right_reference_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this co-investment right, as referenced in the LPA side-letter or mandate agreement documentation.. Valid values are `^CI-[A-Z0-9]{4,20}$`',
    `right_status` STRING COMMENT 'Current lifecycle status of the co-investment right: active (exercisable), suspended, expired (past effective period), terminated (cancelled), or pending_negotiation.. Valid values are `active|suspended|expired|terminated|pending_negotiation`',
    `right_type` STRING COMMENT 'Classification of the co-investment right structure: pro_rata (proportional to LP commitment), discretionary (GP discretion), first_look, last_look, or capped_allocation.. Valid values are `pro_rata|discretionary|first_look|last_look|capped_allocation`',
    `sector_focus` STRING COMMENT 'Industry sector or sectors to which this co-investment right is restricted or focused (e.g., Technology, Healthcare, Energy Infrastructure). Null if no sector restriction.',
    `side_letter_reference` STRING COMMENT 'Document reference number or identifier for the LPA side-letter or amendment that formally grants this co-investment right. Used for legal and compliance traceability.',
    `source_system_record_code` STRING COMMENT 'Native record identifier from the originating source system (e.g., eFront co-invest right ID, DealCloud record ID). Supports data lineage, reconciliation, and audit traceability.',
    `total_deployed_amount` DECIMAL(22,4) COMMENT 'Cumulative capital deployed (invested) by the pension fund under this co-investment right since inception, expressed in mandate currency. Tracks historical utilization against caps.',
    `total_right_cap_amount` DECIMAL(22,4) COMMENT 'Maximum aggregate amount (in mandate currency) the pension fund may deploy under this co-investment right over the full fund term. Null if uncapped.',
    `transferability_permitted` BOOLEAN COMMENT 'Indicates whether the pension fund may transfer or assign this co-investment right to an affiliated entity or co-investor. Governed by LPA transfer restriction clauses.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this co-investment right record was most recently modified in the data platform. Supports change tracking, audit trail, and Silver layer reconciliation.',
    CONSTRAINT pk_co_invest_right PRIMARY KEY(`co_invest_right_id`)
) COMMENT 'Master record of co-investment rights negotiated within each LP mandate, specifying the co-investment allocation right (percentage or dollar cap), notice period for co-invest opportunities, approval process, exclusivity window, and historical utilization.';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`lpac_membership` (
    `lpac_membership_id` BIGINT COMMENT 'Unique surrogate identifier for each LPAC membership position held by the pension fund across LP fund mandates. Primary key for this entity.',
    `employee_id` BIGINT COMMENT 'Reference to the internal pension fund employee or officer appointed to represent the fund on this LPAC seat.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external General Partner (GP) or fund manager entity for which this LPAC seat is held. Sourced from Preqin/PitchBook manager registry.',
    `manager_contact_id` BIGINT COMMENT 'Reference to the internal pension fund employee or officer appointed to represent the fund on this LPAC seat.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external General Partner (GP) or fund manager entity for which this LPAC seat is held. Sourced from Preqin/PitchBook manager registry.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the LP fund mandate under which this LPAC membership seat is held. Links to the specific Limited Partnership Agreement (LPA) governing the fund.',
    `alternate_representative_name` STRING COMMENT 'Full name of the designated alternate representative who may attend and vote on behalf of the pension fund when the primary representative is unavailable.',
    `appointment_date` DATE COMMENT 'Date on which the pension fund was formally appointed to the LPAC seat, as confirmed by the GP and documented in the LPA or side letter.',
    `commitment_amount` DECIMAL(28,6) COMMENT 'Total capital committed by the pension fund to this LP fund mandate under the LPA. Expressed in the funds base currency. Drives LPAC seat eligibility thresholds.',
    `commitment_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the denomination of the LP commitment amount (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `conflict_of_interest_notes` STRING COMMENT 'Free-text description of any identified or disclosed conflicts of interest associated with this LPAC membership, including related-party relationships or co-investment overlaps.',
    `consent_matters_voted_count` BIGINT COMMENT 'Total number of GP consent matters (e.g., conflict approvals, valuation overrides, key person waivers) on which the pension fund has cast a vote via this LPAC seat.',
    `data_source_system` STRING COMMENT 'Operational system of record from which this LPAC membership record was sourced (e.g., eFront for private markets monitoring, DealCloud for manager CRM, Preqin/PitchBook for external data).. Valid values are `efront|dealpath|dealcloud|preqin|pitchbook|manual`',
    `esg_oversight_scope` STRING COMMENT 'Scope of ESG oversight rights exercised through this LPAC seat, as defined in the LPA or side letter. Full scope includes ESG reporting review; limited scope covers specific ESG consent matters only.. Valid values are `full|limited|none`',
    `fund_asset_class` STRING COMMENT 'Primary asset class of the fund for which the LPAC seat is held. Drives portfolio domain classification and reporting alignment. [ENUM-REF-CANDIDATE: private_equity|real_estate|infrastructure|natural_resources|credit|fund_of_funds|other — promote to',
    `fund_domicile_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction in which the fund is legally domiciled (e.g., CYM for Cayman Islands, LUX for Luxembourg, GBR for United Kingdom).. Valid values are `^[A-Z]{3}$`',
    `fund_legal_entity_identifier` STRING COMMENT '20-character ISO 17442 Legal Entity Identifier (LEI) of the fund vehicle. Used for regulatory reporting and counterparty identification under EMIR and MiFID II.. Valid values are `^[A-Z0-9]{18}[0-9]{2}$`',
    `fund_name` STRING COMMENT 'Full legal name of the LP fund for which this LPAC membership is held, as stated in the Limited Partnership Agreement (LPA).',
    `fund_strategy` STRING COMMENT 'Specific investment strategy of the fund (e.g., buyout, venture capital, core infrastructure, opportunistic real estate, direct lending). Provides sub-classification within the asset class.',
    `fund_vintage_year` BIGINT COMMENT 'Year in which the fund made its first capital call or was formally closed, used to classify the fund generation and benchmark performance against peers of the same vintage.',
    `governance_review_date` DATE COMMENT 'Date of the most recent internal governance review of this LPAC membership, including assessment of representative suitability, conflict of interest status, and seat value to the pension fund.',
    `gp_consent_required` BOOLEAN COMMENT 'Indicates whether the General Partner (GP) must provide consent for the pension fund to transfer or assign its LPAC seat to another LP or representative.',
    `has_conflict_of_interest_waiver` BOOLEAN COMMENT 'Indicates whether the pension fund has executed a conflict of interest waiver in connection with this LPAC seat, as required by the LPA for certain GP-related transactions.',
    `internal_approval_date` DATE COMMENT 'Date on which the internal Investment Committee (IC) or governance body formally approved the pension funds participation in this LPAC seat.',
    `internal_approval_reference` STRING COMMENT 'Reference number of the internal Investment Committee (IC) or governance body approval authorizing the pension funds participation in this LPAC seat.',
    `is_lead_lp` BOOLEAN COMMENT 'Indicates whether the pension fund holds the lead LP designation on this LPAC, conferring additional governance rights such as chairing meetings or coordinating LP responses to GP consent requests.',
    `last_meeting_date` DATE COMMENT 'Date of the most recent LPAC meeting attended or scheduled for this fund. Used for monitoring engagement recency and governance activity.',
    `lp_commitment_pct_of_fund` DECIMAL(7,4) COMMENT 'The pension funds committed capital as a percentage of total fund commitments at final close. Determines voting weight and LPAC seat eligibility.',
    `lpa_side_letter_reference` STRING COMMENT 'Reference number or identifier of any side letter executed between the pension fund and the GP that modifies or supplements LPAC rights beyond the standard LPA terms.',
    `meetings_attended_count` BIGINT COMMENT 'Total number of LPAC meetings attended by the pension funds representative since appointment or within the current reporting period. Used for attendance compliance tracking.',
    `meetings_scheduled_count` BIGINT COMMENT 'Total number of LPAC meetings formally scheduled for this fund during the current reporting period or since appointment. Used to compute attendance rate.',
    `membership_status` STRING COMMENT 'Current lifecycle status of the LPAC membership position. Reflects whether the pension fund currently holds, is pending confirmation of, or has exited the LPAC seat.. Valid values are `active|inactive|pending|resigned|terminated|suspended`',
    `nda_executed` BOOLEAN COMMENT 'Indicates whether a Non-Disclosure Agreement (NDA) has been executed by the pension fund representative in connection with LPAC membership, as required for access to confidential GP materials.',
    `nda_execution_date` DATE COMMENT 'Date on which the NDA was formally executed by the pension fund representative for this LPAC membership. Null if no NDA has been executed.',
    `next_meeting_date` DATE COMMENT 'Date of the next scheduled LPAC meeting for this fund. Used for calendar management and representative preparation.',
    `notes` STRING COMMENT 'Free-text field for additional context, special conditions, or qualifications associated with this LPAC membership not captured in structured fields.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this LPAC membership record was first created in the data platform. Supports audit trail and data lineage requirements.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this LPAC membership record in the data platform. Used for change detection and incremental processing in the Silver layer.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this LPAC membership position must be disclosed in regulatory filings (e.g., SEC, FCA) due to governance rights, ownership thresholds, or related-party rules.',
    `representative_name` STRING COMMENT 'Full name of the internal pension fund officer or employee formally designated to represent the fund on this LPAC seat.',
    `representative_title` STRING COMMENT 'Job title or role of the internal representative assigned to this LPAC seat (e.g., Managing Director, Portfolio Manager, General Counsel).',
    `resignation_date` DATE COMMENT 'Date on which the pension fund formally resigned or was removed from the LPAC seat. Null if the membership is still active.',
    `seat_eligibility_threshold_pct` DECIMAL(7,4) COMMENT 'Minimum LP commitment percentage of total fund commitments required to qualify for an LPAC seat, as stipulated in the LPA. Expressed as a percentage (e.g., 5.0000 = 5%).',
    `seat_source` STRING COMMENT 'Indicates the contractual basis under which the LPAC seat was obtained: standard LPA provision, side letter negotiation, LPA amendment, or transfer from another LP.. Valid values are `lpa_standard|side_letter|negotiated_amendment|inherited_transfer`',
    `seat_type` STRING COMMENT 'Classification of the LPAC seat held by the pension fund. Voting seats carry formal decision-making rights; observer seats provide attendance without vote; alternate seats are backup positions.. Valid values are `voting|observer|alternate|advisory`',
    `source_system_record_code` STRING COMMENT 'Native record identifier from the operational source system (e.g., eFront fund ID, DealCloud entity ID) for lineage tracing and reconciliation with upstream systems.',
    `term_expiry_date` DATE COMMENT 'Date on which the current LPAC membership term expires or is subject to renewal. Null if the seat is held for the full life of the fund with no fixed term.',
    `voting_weight_pct` DECIMAL(7,4) COMMENT 'Percentage of total LPAC voting rights held by the pension fund on this committee, as defined in the LPA. Applicable only for voting seat types; null for observer seats.',
    CONSTRAINT pk_lpac_membership PRIMARY KEY(`lpac_membership_id`)
) COMMENT 'Tracks the pension funds Limited Partner Advisory Committee (LPAC) membership positions across all LP fund mandates, including seat type (voting, observer), appointment date, term expiry, representative assigned, and LPAC meeting attendance record.';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`strategy` (
    `strategy_id` BIGINT COMMENT 'Unique identifier for the strategy.',
    `asset_class` STRING COMMENT 'Primary asset class targeted by the strategy. [ENUM-REF-CANDIDATE: Equity|Fixed Income|Real Estate|Private Equity|Infrastructure|Natural Resources|Credit — promote to reference product]',
    `strategy_code` STRING COMMENT 'Alphanumeric code used to identify the strategy in external systems.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the strategy record was created.',
    `strategy_description` STRING COMMENT 'Detailed description of the strategys investment approach.',
    `geographic_focus` STRING COMMENT 'Primary geographic focus of the strategy. [ENUM-REF-CANDIDATE: North America|Europe|Asia|Latin America|Middle East|Africa|Global — promote to reference product]',
    `strategy_name` STRING COMMENT 'Human-readable name of the investment strategy.',
    `strategy_status` STRING COMMENT 'Current lifecycle status of the strategy.. Valid values are `active|inactive|draft|archived`',
    `sub_strategy_type` STRING COMMENT 'Specific sub-strategy focus. [ENUM-REF-CANDIDATE: Buyout|Venture|Growth|Distressed|Core Real Estate|Value-Add|Infrastructure Greenfield|... — promote to reference product]',
    `target_allocation_amount` DECIMAL(18,2) COMMENT 'Target allocation amount in USD for the strategy.',
    `target_allocation_pct` DECIMAL(5,2) COMMENT 'Target allocation percentage of the strategy within a portfolio.',
    `target_aum_max` DECIMAL(18,2) COMMENT 'Maximum target assets under management for the strategy.',
    `target_aum_min` DECIMAL(18,2) COMMENT 'Minimum target assets under management for the strategy.',
    `target_carry_rate` DECIMAL(5,2) COMMENT 'Target carried interest rate for the strategy.',
    `target_co_investment_flag` BOOLEAN COMMENT 'Flag indicating if co-investment is allowed for the strategy.',
    `target_commitment` DECIMAL(18,2) COMMENT 'Target committed capital for the strategy.',
    `target_dpi` DECIMAL(5,2) COMMENT 'Target distributions to paid-in for the strategy.',
    `target_esg_integration_level` STRING COMMENT 'Target ESG integration level for the strategy.. Valid values are `none|basic|advanced|full`',
    `target_fund_size` DECIMAL(18,2) COMMENT 'Target size of the fund for the strategy.',
    `target_gps` STRING COMMENT 'Target GIPS compliance status for the strategy.. Valid values are `gips|non-gips`',
    `target_hurdle_rate` DECIMAL(5,2) COMMENT 'Target hurdle rate for the strategy.',
    `target_irr` DECIMAL(5,2) COMMENT 'Target internal rate of return for the strategy.',
    `target_lpa_carry` DECIMAL(5,2) COMMENT 'Carry rate specified in the Limited Partnership Agreement.',
    `target_lpa_carry_rate` DECIMAL(5,2) COMMENT 'Carry rate percentage specified in the Limited Partnership Agreement.',
    `target_lpa_carry_split` DECIMAL(5,2) COMMENT 'Carry split percentage specified in the Limited Partnership Agreement.',
    `target_lpa_end_date` DATE COMMENT 'End date of the Limited Partnership Agreement.',
    `target_lpa_fee_structure` STRING COMMENT 'Fee structure of the Limited Partnership Agreement.. Valid values are `flat|tiered|performance`',
    `target_lpa_hurdle` DECIMAL(5,2) COMMENT 'Hurdle rate specified in the Limited Partnership Agreement.',
    `target_lpa_mgmt_fee` DECIMAL(5,2) COMMENT 'Management fee rate specified in the Limited Partnership Agreement.',
    `target_lpa_reference` STRING COMMENT 'Reference to the Limited Partnership Agreement for the strategy.',
    `target_lpa_start_date` DATE COMMENT 'Start date of the Limited Partnership Agreement.',
    `target_lpa_status` STRING COMMENT 'Current status of the Limited Partnership Agreement.. Valid values are `active|suspended|terminated|pending`',
    `target_lpa_type` STRING COMMENT 'Type of Limited Partnership Agreement for the strategy.. Valid values are `standard|side_letter|co_investment`',
    `target_management_fee_rate` DECIMAL(5,2) COMMENT 'Target management fee rate for the strategy.',
    `target_max_deal_size` DECIMAL(18,2) COMMENT 'Maximum deal size for the strategy.',
    `target_max_investment_period_years` BIGINT COMMENT 'Maximum investment period in years for the strategy.',
    `target_min_deal_size` DECIMAL(18,2) COMMENT 'Minimum deal size for the strategy.',
    `target_min_investment_period_years` BIGINT COMMENT 'Minimum investment period in years for the strategy.',
    `target_moic` DECIMAL(5,2) COMMENT 'Target multiple on invested capital for the strategy.',
    `target_rvpi` DECIMAL(5,2) COMMENT 'Target residual value to paid-in for the strategy.',
    `target_tvpi` DECIMAL(5,2) COMMENT 'Target total value to paid-in for the strategy.',
    `target_vintage_year` BIGINT COMMENT 'Target vintage year for the strategy.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the strategy record was last updated.',
    CONSTRAINT pk_strategy PRIMARY KEY(`strategy_id`)
) COMMENT 'Reference classification of investment strategies offered by external managers, including strategy name, asset class, sub-strategy type (buyout, venture, growth, distressed, core real estate, value-add, infrastructure greenfield, etc.), geographic focus';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`manager_document` (
    `manager_document_id` BIGINT COMMENT 'Unique identifier for the manager document record.',
    `gp_profile_id` BIGINT COMMENT 'Identifier linking the document to the associated manager.',
    `manager_gp_profile_id` BIGINT COMMENT 'Identifier linking the document to the associated manager.',
    `manager_mandate_id` BIGINT COMMENT 'Identifier linking the document to the related mandate.',
    `access_control` STRING COMMENT 'Access control level for the document (public, restricted, confidential).. Valid values are `public|restricted|confidential`',
    `approval_status` STRING COMMENT 'Status of the document approval workflow (approved, pending, rejected).. Valid values are `approved|pending|rejected`',
    `approved_by` STRING COMMENT 'Identifier of the individual who approved the document.',
    `approved_date` DATE COMMENT 'Date when the document was approved.',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the document record was created.',
    `document_category` STRING COMMENT 'High-level category of the document (e.g., Legal, Financial, Compliance).',
    `document_description` STRING COMMENT 'Detailed description of the document contents.',
    `document_status` STRING COMMENT 'Current lifecycle status of the document (draft, final, archived, replaced).. Valid values are `draft|final|archived|replaced`',
    `document_type` STRING COMMENT 'Classification of the document (e.g., LPA, NDA, PPM).',
    `effective_date` DATE COMMENT 'Date when the document becomes effective.',
    `expiry_date` DATE COMMENT 'Date when the document expires or is no longer valid.',
    `format` STRING COMMENT 'File format of the document (PDF, DOCX, XLSX, TXT, HTML).. Valid values are `PDF|DOCX|XLSX|TXT|HTML`',
    `hash_sha256` STRING COMMENT 'SHA-256 hash of the document file for integrity verification.',
    `language` STRING COMMENT 'Primary language of the document.',
    `language_code` STRING COMMENT 'ISO 639-1 code for the document language.',
    `last_accessed` TIMESTAMP COMMENT 'Timestamp of the last time the document was accessed.',
    `page_count` BIGINT COMMENT 'Number of pages in the document.',
    `pii_content_flag` BOOLEAN COMMENT 'Flag indicating whether the document content includes PII.',
    `pii_flag` BOOLEAN COMMENT 'Flag indicating whether the document contains personally identifiable information.',
    `reference_code` STRING COMMENT 'Alphanumeric code used to reference the document in external systems.',
    `reference_number` STRING COMMENT 'Sequential number assigned to the document for tracking.',
    `signed_by` STRING COMMENT 'Identifier of the individual who signed the document.',
    `signed_by_role` STRING COMMENT 'Role of the signer within the organization.',
    `signed_date` DATE COMMENT 'Date when the document was signed.',
    `signed_status` STRING COMMENT 'Status of the documents electronic signature (signed, unsigned, pending).. Valid values are `signed|unsigned|pending`',
    `size_bytes` BIGINT COMMENT 'Size of the document file in bytes.',
    `storage_location` STRING COMMENT 'Storage path or URI where the document is stored.',
    `summary` STRING COMMENT 'Brief summary of the document.',
    `title` STRING COMMENT 'Title of the document.',
    `updated_at` TIMESTAMP COMMENT 'Timestamp of the most recent update to the document record.',
    `version_label` STRING COMMENT 'Human-readable label for the document version.',
    `version_number` BIGINT COMMENT 'Numeric version identifier of the document.',
    `created_by` STRING COMMENT 'User who created the document record.',
    CONSTRAINT pk_manager_document PRIMARY KEY(`manager_document_id`)
) COMMENT 'Catalog of all legal and operational documents associated with each manager relationship, including executed LPAs, side letters, NDAs, PPMs, subscription agreements, audited financial statements, DDQs (Due Diligence Questionnaires), and regulatory';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`kyc` (
    `kyc_id` BIGINT COMMENT 'Unique identifier for the KYC record.',
    `gp_profile_id` BIGINT COMMENT 'Identifier of the external manager subject to KYC.',
    `kyc_record_id` BIGINT COMMENT 'FK to compliance.kyc_record.kyc_record_id — Manager-level KYC must reference the enterprise compliance KYC master so AML/sanctions status is authoritative and not duplicated across onboarding workflows.',
    `manager_gp_profile_id` BIGINT COMMENT 'Identifier of the external manager subject to KYC.',
    `sanctions_screening_id` BIGINT COMMENT 'Foreign key linking to compliance.sanctions_screening. Business justification: Manager onboarding due diligence requires documented sanctions screening. Links KYC record to actual screening performed, enabling audit trail for regulatory examinations and',
    `aml_screening_result` STRING COMMENT 'Result of AML screening.',
    `beneficial_ownership_verification` BOOLEAN COMMENT 'Verification of beneficial ownership.',
    `completion_date` DATE COMMENT 'Date when KYC was completed.',
    `compliance_flag` BOOLEAN COMMENT 'Flag indicating compliance status.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was created.',
    `document_category` STRING COMMENT 'Category of the document.. Valid values are `Legal|Financial|Regulatory`',
    `document_expiry_date` DATE COMMENT 'Expiry date of the document.',
    `document_hash` STRING COMMENT 'Hash of the document for integrity.',
    `document_language` STRING COMMENT 'Language of the document.',
    `document_reference` STRING COMMENT 'Reference code for the KYC document.',
    `document_size_bytes` BIGINT COMMENT 'Size of the document in bytes.',
    `document_status` STRING COMMENT 'Status of the KYC document.. Valid values are `uploaded|verified|rejected|expired`',
    `document_storage_location` STRING COMMENT 'Storage location of the document.',
    `document_type` STRING COMMENT 'Type of the KYC document.. Valid values are `KYC_Paper|AML_Paper|Compliance_Paper`',
    `document_upload_date` DATE COMMENT 'Date the document was uploaded.',
    `document_version` STRING COMMENT 'Version of the document.',
    `kyc_status` STRING COMMENT 'Current status of the KYC process.. Valid values are `pending|completed|failed|revoked`',
    `pep_status` STRING COMMENT 'Politically Exposed Person status.. Valid values are `none|yes|unknown`',
    `provider` STRING COMMENT 'Provider that performed the KYC.',
    `provider_document_category` STRING COMMENT 'Category of the providers document.. Valid values are `Legal|Financial|Regulatory`',
    `provider_document_expiry_date` DATE COMMENT 'Expiry date of the providers document.',
    `provider_document_hash` STRING COMMENT 'Hash of the providers document.',
    `provider_document_language` STRING COMMENT 'Language of the providers document.',
    `provider_document_reference` STRING COMMENT 'Reference for the providers document.',
    `provider_document_size_bytes` BIGINT COMMENT 'Size of the providers document in bytes.',
    `provider_document_status` STRING COMMENT 'Status of the providers document.. Valid values are `uploaded|verified|rejected|expired`',
    `provider_document_storage_location` STRING COMMENT 'Storage location of the providers document.',
    `provider_document_type` STRING COMMENT 'Type of the providers document.. Valid values are `KYC_Paper|AML_Paper|Compliance_Paper`',
    `provider_document_upload_date` DATE COMMENT 'Upload date of the providers document.',
    `provider_document_version` STRING COMMENT 'Version of the providers document.',
    `provider_version` STRING COMMENT 'Version of the KYC provider.',
    `reference` STRING COMMENT 'Reference code for the KYC record.',
    `reference_code` STRING COMMENT 'Code for the KYC reference.',
    `reference_name` STRING COMMENT 'Name of the KYC reference.',
    `regulatory_compliance_status` STRING COMMENT 'Regulatory compliance status.',
    `review_date` DATE COMMENT 'Date of the last KYC review.',
    `review_frequency` STRING COMMENT 'Frequency of KYC reviews.. Valid values are `monthly|quarterly|annually`',
    `risk_rating` STRING COMMENT 'Overall risk rating of the KYC.. Valid values are `low|medium|high|critical`',
    `source_of_funds_confirmation` BOOLEAN COMMENT 'Confirmation of source of funds.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `version` STRING COMMENT 'Version of the KYC record.',
    CONSTRAINT pk_kyc PRIMARY KEY(`kyc_id`)
) COMMENT 'Records KYC (Know Your Customer) and AML (Anti-Money Laundering) due diligence completed for each external manager entity, including beneficial ownership verification, sanctions screening results, PEP checks, source of funds confirmation, and regulatory';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`esg_profile` (
    `esg_profile_id` BIGINT COMMENT 'Globally unique identifier for the ESG profile record.',
    `esg_policy_document_id` BIGINT COMMENT 'Identifier of the ESG policy document associated with the profile.',
    `esg_policy_id` BIGINT COMMENT 'Foreign key linking to esg.policy. Business justification: Manager ESG profiles implement specific ESG policies. Business process: ESG policy compliance tracking, manager selection based on policy alignment.',
    `framework_id` BIGINT COMMENT 'Foreign key linking to esg.framework. Business justification: ESG profiles align to specific frameworks (PRI, TCFD, SFDR). Business process: Framework compliance reporting, manager ESG assessment during due diligence. Required for regulatory disclosures.',
    `esg_framework` STRING COMMENT 'The ESG framework or standard the profile adheres to, e.g., PRI, SFDR, TCFD, or ESG.. Valid values are `PRI|SFDR|TCFD|ESG`',
    `esg_policy_document_created_by` STRING COMMENT 'Identifier of the user or system that created the ESG policy document.',
    `esg_policy_document_created_date` DATE COMMENT 'Date when the ESG policy document was first created.',
    `esg_policy_document_language` STRING COMMENT 'Language of the ESG policy document, ISO 639‑1 code.. Valid values are `EN|FR|DE|ES`',
    `esg_policy_document_last_updated_by` STRING COMMENT 'Identifier of the user or system that last updated the ESG policy document.',
    `esg_policy_document_last_updated_date` DATE COMMENT 'Date when the ESG policy document was last updated.',
    `esg_policy_document_notes` STRING COMMENT 'Additional notes or remarks about the ESG policy document.',
    `esg_policy_document_source` STRING COMMENT 'Source of the ESG policy document, internal or external.. Valid values are `internal|external`',
    `esg_policy_document_status` STRING COMMENT 'Publication status of the ESG policy document.. Valid values are `draft|published|archived`',
    `esg_policy_document_type` STRING COMMENT 'Type of the ESG policy document, e.g., policy, report, guideline.. Valid values are `policy|report|guideline`',
    `esg_policy_document_url` STRING COMMENT 'Web URL where the ESG policy document can be accessed.',
    `esg_policy_document_version` STRING COMMENT 'Version identifier of the ESG policy document.',
    `esg_profile_status` STRING COMMENT 'Current lifecycle status of the ESG profile.. Valid values are `active|inactive|retired`',
    `esg_score` DECIMAL(5,2) COMMENT 'Composite ESG score as a percentage, ranging from 0.00 to 100.00.',
    `esg_score_calculation_frequency` STRING COMMENT 'Frequency at which the ESG score is recalculated, e.g., annual, quarterly.',
    `esg_score_calculation_method` STRING COMMENT 'Methodology used to compute the ESG score, e.g., weighted average, composite index.',
    `esg_score_calculation_notes` STRING COMMENT 'Additional notes or remarks about the ESG score calculation methodology.',
    `esg_score_date` DATE COMMENT 'Date when the ESG score was last calculated.',
    `esg_score_source` STRING COMMENT 'Source of the ESG score data, e.g., internal model, third‑party provider.',
    `profile_code` STRING COMMENT 'Unique alphanumeric code assigned to the ESG profile.',
    `profile_name` STRING COMMENT 'Human-readable name of the ESG profile.',
    CONSTRAINT pk_esg_profile PRIMARY KEY(`esg_profile_id`)
) COMMENT 'Captures the ESG credentials and responsible investment profile of each external manager, including PRI signatory status, SFDR article classification, TCFD alignment, proprietary ESG policy documentation, GHG reporting capability, exclusion list';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`manager_benchmark` (
    `manager_benchmark_id` BIGINT COMMENT 'Unique identifier for the manager benchmark record.',
    `gp_profile_id` BIGINT COMMENT 'Identifier of the external manager associated with the benchmark.',
    `macro_indicator_id` BIGINT COMMENT 'Foreign key linking to research.macro_indicator. Business justification: Benchmarks reference macro indicators (CPI, GDP) for real return calculations and inflation-linked performance measurement.',
    `manager_gp_profile_id` BIGINT COMMENT 'Identifier of the external manager associated with the benchmark.',
    `performance_benchmark_id` BIGINT COMMENT 'Foreign key linking to performance.performance_benchmark. Business justification: Manager benchmark assignments must reference master benchmark definitions in performance domain.',
    `approval_by` STRING COMMENT 'Identifier of the approver for the benchmark.',
    `approval_date` DATE COMMENT 'Date when the benchmark was approved.',
    `approval_notes` STRING COMMENT 'Notes or comments from the approval process.',
    `approval_status` STRING COMMENT 'Current approval state of the benchmark.. Valid values are `approved|pending|rejected|under_review`',
    `benchmark_description` STRING COMMENT 'Detailed description of the benchmark and its scope.',
    `benchmark_name` STRING COMMENT 'Human-readable name of the benchmark.',
    `benchmark_status` STRING COMMENT 'Current operational status of the benchmark.. Valid values are `active|inactive|pending|archived|deleted`',
    `benchmark_type` STRING COMMENT 'Asset class or category the benchmark represents.. Valid values are `equity|fixed_income|private_equity|real_estate|infrastructure|credit`',
    `calculation_methodology` STRING COMMENT 'Method used to calculate benchmark performance.. Valid values are `DCF|NAV|IRR|MOIC|TVPI|DPI`',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the benchmark record was created.',
    `currency` STRING COMMENT 'ISO 4217 currency code for benchmark values.. Valid values are `USD|EUR|GBP|JPY|CHF`',
    `end_date` DATE COMMENT 'Date when the benchmark expires or is no longer effective.',
    `frequency` STRING COMMENT 'How often the benchmark is updated.. Valid values are `daily|weekly|monthly|quarterly|annual`',
    `index_code` STRING COMMENT 'Standard code identifying the benchmark index.',
    `is_confidential` BOOLEAN COMMENT 'Indicates if the benchmark contains confidential information.',
    `is_custom` BOOLEAN COMMENT 'Indicates if this benchmark was created internally.',
    `is_default` BOOLEAN COMMENT 'Indicates if this benchmark is the default for its type.',
    `is_public` BOOLEAN COMMENT 'Indicates if the benchmark is publicly available.',
    `is_restricted` BOOLEAN COMMENT 'Indicates if the benchmark is restricted to certain users.',
    `is_sensitive` BOOLEAN COMMENT 'Indicates if the benchmark contains sensitive data.',
    `mandate_id` BIGINT COMMENT 'Identifier of the mandate to which the benchmark is assigned.',
    `provider` STRING COMMENT 'Name of the organization that publishes the benchmark.. Valid values are `MSCI|S&P|FTSE|Bloomberg|Reuters`',
    `source_document` STRING COMMENT 'Reference to the source document for the benchmark.',
    `source_document_checksum` STRING COMMENT 'Checksum of the source document for integrity.',
    `source_document_date` DATE COMMENT 'Date of the source document for the benchmark.',
    `source_document_format` STRING COMMENT 'File format of the source document.',
    `source_document_language` STRING COMMENT 'Language of the source document.',
    `source_document_language_code` STRING COMMENT 'ISO 639-1 code for the source document language.',
    `source_document_language_description` STRING COMMENT 'Description of the source document language.',
    `source_document_language_notes` STRING COMMENT 'Additional notes about the source document language.',
    `source_document_size` BIGINT COMMENT 'Size of the source document in bytes.',
    `source_document_type` STRING COMMENT 'Type of the source document (e.g., PDF, XLS).',
    `source_document_version` STRING COMMENT 'Version of the source document.',
    `source_url` STRING COMMENT 'URL to the source of the benchmark data.',
    `start_date` DATE COMMENT 'Date when the benchmark becomes effective.',
    `unit` STRING COMMENT 'Unit of measurement for benchmark values.. Valid values are `return|price|index_value|percentage`',
    `updated_at` TIMESTAMP COMMENT 'Timestamp of the last update to the benchmark record.',
    `version` STRING COMMENT 'Version identifier for the benchmark definition.',
    `version_date` DATE COMMENT 'Date when the benchmark version was released.',
    `created_by` STRING COMMENT 'Identifier of the user who created the benchmark.',
    CONSTRAINT pk_manager_benchmark PRIMARY KEY(`manager_benchmark_id`)
) COMMENT 'Defines the performance benchmarks assigned to each mandate or manager strategy, including benchmark name, benchmark provider, benchmark index code, benchmark currency, benchmark calculation methodology, and effective date range.';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`reporting_obligation` (
    `reporting_obligation_id` BIGINT COMMENT 'Unique identifier for the reporting obligation record.',
    `gp_profile_id` BIGINT COMMENT 'Identifier of the external manager associated with this obligation.',
    `manager_gp_profile_id` BIGINT COMMENT 'Identifier of the external manager associated with this obligation.',
    `manager_mandate_id` BIGINT COMMENT 'Identifier of the mandate under which the obligation is defined.',
    `compliance_flag` BOOLEAN COMMENT 'Indicates if the obligation is in compliance with regulatory requirements.',
    `compliance_notes` STRING COMMENT 'Additional notes regarding compliance status.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was first created.',
    `data_delivery_channel` STRING COMMENT 'Channel used for data delivery.. Valid values are `Email|Secure FTP|Portal`',
    `data_delivery_deadline_days` BIGINT COMMENT 'Number of days allowed to deliver data after the due date.',
    `data_delivery_format` STRING COMMENT 'Format in which data is delivered to the manager.. Valid values are `PDF|Excel|JSON|EDI`',
    `delivery_channel` STRING COMMENT 'Channel used to deliver the report.. Valid values are `Email|Secure FTP|Portal`',
    `delivery_format` STRING COMMENT 'Format in which the report is delivered.. Valid values are `PDF|Excel|JSON|EDI`',
    `due_date` DATE COMMENT 'Deadline for submitting the report.',
    `effective_from` DATE COMMENT 'Date when the obligation becomes effective.',
    `effective_until` DATE COMMENT 'Date when the obligation expires or is terminated.',
    `frequency` STRING COMMENT 'How often the obligation must be reported.. Valid values are `Monthly|Quarterly|Annual|Ad-hoc`',
    `last_sent_date` DATE COMMENT 'Date the report was last sent to the manager.',
    `next_due_date` DATE COMMENT 'Next scheduled due date for the obligation.',
    `obligation_type` STRING COMMENT 'Category of the reporting obligation.. Valid values are `Capital Account Statement|Audited Financials|Quarterly Investor Letter|ESG Report|ILPA Data Template`',
    `penalty_amount` DECIMAL(18,2) COMMENT 'Monetary penalty amount if the obligation is breached.',
    `penalty_clause_applicable` BOOLEAN COMMENT 'Indicates if a penalty clause is applicable to the obligation.',
    `penalty_currency` STRING COMMENT 'Currency code for the penalty amount.. Valid values are `^[A-Z]{3}$`',
    `reference_code` STRING COMMENT 'Code used to reference the obligation in external systems.. Valid values are `^[A-Z0-9]{1,20}$`',
    `reference_name` STRING COMMENT 'Human-readable name for the obligation reference.. Valid values are `^[A-Za-z0-9 ]{1,100}$`',
    `report_description` STRING COMMENT 'Detailed description of the report content.',
    `report_notes` STRING COMMENT 'Additional notes about the report.',
    `reporting_obligation_status` STRING COMMENT 'Current lifecycle status of the obligation.. Valid values are `Active|Completed|Cancelled|Pending`',
    `sla_effective_from` DATE COMMENT 'Date when the SLA becomes effective.',
    `sla_effective_until` DATE COMMENT 'Date when the SLA expires.',
    `sla_reference_number` STRING COMMENT 'Reference number for the SLA governing the obligation.',
    `sla_status` STRING COMMENT 'Current status of the SLA.. Valid values are `Active|Completed|Cancelled|Pending`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    CONSTRAINT pk_reporting_obligation PRIMARY KEY(`reporting_obligation_id`)
) COMMENT 'Defines the specific reporting obligations each external manager must fulfill under their mandate, including report type (capital account statement, audited financials, quarterly investor letter, ESG report, ILPA data template), delivery frequency';

CREATE OR REPLACE TABLE `asset_management`.`manager`.`report_receipt` (
    `report_receipt_id` BIGINT COMMENT 'Unique identifier for each manager report receipt record.',
    `gp_profile_id` BIGINT COMMENT 'Identifier of the external manager whose report was received.',
    `manager_gp_profile_id` BIGINT COMMENT 'Identifier of the external manager whose report was received.',
    `completeness_check_result` STRING COMMENT 'Outcome of the initial completeness validation of the report.. Valid values are `Pass|Fail|Partial`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was first created in the system.',
    `data_quality_flags` STRING COMMENT 'Comma-separated flags indicating data quality issues detected.',
    `delivery_channel` STRING COMMENT 'Medium through which the report was delivered to the system.. Valid values are `Email|FTP|API|Manual`',
    `processing_error_code` STRING COMMENT 'Error code returned by the processing engine, if any.',
    `processing_error_details` STRING COMMENT 'Additional details or stack trace for processing errors.',
    `processing_error_flag` BOOLEAN COMMENT 'Indicates whether an error occurred during processing.',
    `processing_error_message` STRING COMMENT 'Human-readable error message for processing failures.',
    `processing_status` STRING COMMENT 'Current status of the report processing workflow.. Valid values are `Received|Processing|Completed|Failed|Cancelled`',
    `processing_timestamp` TIMESTAMP COMMENT 'Timestamp when the report processing status last changed.',
    `receipt_date` TIMESTAMP COMMENT 'Timestamp when the report was received by the system.',
    `report_checksum` STRING COMMENT 'Checksum value for verifying file integrity.',
    `report_file_name` STRING COMMENT 'Original file name of the received report document.',
    `report_file_size_bytes` BIGINT COMMENT 'Size of the report file in bytes.',
    `report_language_code` STRING COMMENT 'ISO 639-1 code indicating the language of the report.. Valid values are `en|fr|de|es|zh`',
    `report_reference_code` STRING COMMENT 'Alphanumeric code assigned to the report for tracking.',
    `report_source_system_code` STRING COMMENT 'Unique identifier of the source system instance.',
    `report_source_system_name` STRING COMMENT 'Name of the system that generated the report.',
    `report_source_system_type` STRING COMMENT 'Type of system that produced the report.. Valid values are `SimCorp|BlackRock|Bloomberg|StateStreet|eFront|DealCloud`',
    `report_source_system_version` STRING COMMENT 'Version of the source system that generated the report.',
    `report_type` STRING COMMENT 'Category of the report received, e.g., NAV, Performance, ESG.. Valid values are `NAV|Performance|ESG|Compliance|Other`',
    `report_version` STRING COMMENT 'Version identifier of the report format.',
    `reporting_period_end_date` DATE COMMENT 'End date of the period covered by the report.',
    `reporting_period_start_date` DATE COMMENT 'Start date of the period covered by the report.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    CONSTRAINT pk_report_receipt PRIMARY KEY(`report_receipt_id`)
) COMMENT 'Transactional log of each manager report received, recording report type, reporting period covered, receipt date, delivery channel, completeness check result, data quality flags, and processing status.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`manager`.`gp_profile` ADD CONSTRAINT `fk_manager_gp_profile_strategy_id` FOREIGN KEY (`strategy_id`) REFERENCES `asset_management`.`manager`.`strategy`(`strategy_id`);
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ADD CONSTRAINT `fk_manager_manager_mandate_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ADD CONSTRAINT `fk_manager_manager_mandate_investment_strategy_id` FOREIGN KEY (`investment_strategy_id`) REFERENCES `asset_management`.`manager`.`strategy`(`strategy_id`);
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ADD CONSTRAINT `fk_manager_manager_mandate_manager_benchmark_id` FOREIGN KEY (`manager_benchmark_id`) REFERENCES `asset_management`.`manager`.`manager_benchmark`(`manager_benchmark_id`);
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ADD CONSTRAINT `fk_manager_manager_mandate_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`rfp` ADD CONSTRAINT `fk_manager_rfp_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`rfp` ADD CONSTRAINT `fk_manager_rfp_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`rfp` ADD CONSTRAINT `fk_manager_rfp_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`manager`.`rfp_response` ADD CONSTRAINT `fk_manager_rfp_response_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`rfp_response` ADD CONSTRAINT `fk_manager_rfp_response_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`rfp_response` ADD CONSTRAINT `fk_manager_rfp_response_rfp_id` FOREIGN KEY (`rfp_id`) REFERENCES `asset_management`.`manager`.`rfp`(`rfp_id`);
ALTER TABLE `asset_management`.`manager`.`mandate_term` ADD CONSTRAINT `fk_manager_mandate_term_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`mandate_term` ADD CONSTRAINT `fk_manager_mandate_term_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`mandate_term` ADD CONSTRAINT `fk_manager_mandate_term_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ADD CONSTRAINT `fk_manager_mandate_amendment_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ADD CONSTRAINT `fk_manager_mandate_amendment_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ADD CONSTRAINT `fk_manager_mandate_amendment_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`manager`.`manager_contact` ADD CONSTRAINT `fk_manager_manager_contact_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`manager_contact` ADD CONSTRAINT `fk_manager_manager_contact_manager_firm_gp_profile_id` FOREIGN KEY (`manager_firm_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ADD CONSTRAINT `fk_manager_fee_schedule_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ADD CONSTRAINT `fk_manager_fee_schedule_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ADD CONSTRAINT `fk_manager_fee_schedule_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`manager`.`evaluation` ADD CONSTRAINT `fk_manager_evaluation_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`evaluation` ADD CONSTRAINT `fk_manager_evaluation_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`evaluation` ADD CONSTRAINT `fk_manager_evaluation_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ADD CONSTRAINT `fk_manager_risk_assessment_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ADD CONSTRAINT `fk_manager_risk_assessment_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ADD CONSTRAINT `fk_manager_risk_assessment_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ADD CONSTRAINT `fk_manager_sla_agreement_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ADD CONSTRAINT `fk_manager_sla_agreement_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ADD CONSTRAINT `fk_manager_sla_agreement_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`manager`.`sla_breach` ADD CONSTRAINT `fk_manager_sla_breach_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`sla_breach` ADD CONSTRAINT `fk_manager_sla_breach_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`sla_breach` ADD CONSTRAINT `fk_manager_sla_breach_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`manager`.`sla_breach` ADD CONSTRAINT `fk_manager_sla_breach_sla_agreement_id` FOREIGN KEY (`sla_agreement_id`) REFERENCES `asset_management`.`manager`.`sla_agreement`(`sla_agreement_id`);
ALTER TABLE `asset_management`.`manager`.`watchlist` ADD CONSTRAINT `fk_manager_watchlist_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`watchlist` ADD CONSTRAINT `fk_manager_watchlist_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`watchlist` ADD CONSTRAINT `fk_manager_watchlist_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`manager`.`meeting` ADD CONSTRAINT `fk_manager_meeting_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`meeting` ADD CONSTRAINT `fk_manager_meeting_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`meeting` ADD CONSTRAINT `fk_manager_meeting_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ADD CONSTRAINT `fk_manager_co_invest_right_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ADD CONSTRAINT `fk_manager_co_invest_right_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ADD CONSTRAINT `fk_manager_co_invest_right_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ADD CONSTRAINT `fk_manager_lpac_membership_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ADD CONSTRAINT `fk_manager_lpac_membership_manager_contact_id` FOREIGN KEY (`manager_contact_id`) REFERENCES `asset_management`.`manager`.`manager_contact`(`manager_contact_id`);
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ADD CONSTRAINT `fk_manager_lpac_membership_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ADD CONSTRAINT `fk_manager_lpac_membership_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`manager`.`manager_document` ADD CONSTRAINT `fk_manager_manager_document_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`manager_document` ADD CONSTRAINT `fk_manager_manager_document_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`manager_document` ADD CONSTRAINT `fk_manager_manager_document_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`manager`.`kyc` ADD CONSTRAINT `fk_manager_kyc_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`kyc` ADD CONSTRAINT `fk_manager_kyc_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ADD CONSTRAINT `fk_manager_manager_benchmark_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ADD CONSTRAINT `fk_manager_manager_benchmark_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ADD CONSTRAINT `fk_manager_reporting_obligation_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ADD CONSTRAINT `fk_manager_reporting_obligation_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ADD CONSTRAINT `fk_manager_reporting_obligation_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`manager`.`report_receipt` ADD CONSTRAINT `fk_manager_report_receipt_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`manager`.`report_receipt` ADD CONSTRAINT `fk_manager_report_receipt_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`manager`.`gp_profile` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`manager`.`gp_profile` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`gp_profile` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`gp_profile` SET TAGS ('dbx_subdomain' = 'manager_selection');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Profile ID');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Strategy Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `adoption_date` SET TAGS ('dbx_business_glossary_term' = 'Framework Adoption Date');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `approved_mandate_types` SET TAGS ('dbx_business_glossary_term' = 'Approved Mandate Types');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `aum_reporting_date` SET TAGS ('dbx_business_glossary_term' = 'Assets Under Management (AUM) Reporting Date');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `aum_usd` SET TAGS ('dbx_business_glossary_term' = 'Assets Under Management (AUM) USD');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `aum_usd` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `carried_interest_rate` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Rate');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `carried_interest_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `certification_status` SET TAGS ('dbx_business_glossary_term' = 'Certification Status');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `co_invest_rights_flag` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Rights Flag');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `compliance_level` SET TAGS ('dbx_business_glossary_term' = 'Compliance Level');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `domicile_country` SET TAGS ('dbx_business_glossary_term' = 'Domicile Country Code');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `domicile_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `dry_powder_usd` SET TAGS ('dbx_business_glossary_term' = 'Dry Powder (Uncalled Committed Capital) USD');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `dry_powder_usd` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `efront_manager_code` SET TAGS ('dbx_business_glossary_term' = 'eFront Manager Identifier');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `esg_policy_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social Governance (ESG) Policy Flag');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `firm_founded_year` SET TAGS ('dbx_business_glossary_term' = 'Firm Founded Year');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Investment Focus');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `headquarters_city` SET TAGS ('dbx_business_glossary_term' = 'Headquarters City');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `headquarters_country` SET TAGS ('dbx_business_glossary_term' = 'Headquarters Country Code');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `headquarters_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `hurdle_rate` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate (Preferred Return Threshold)');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `hurdle_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `key_person_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Key Person Clause Flag');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `kyc_next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Next Review Date');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `kyc_review_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Last Review Date');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `kyc_status` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Status');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `kyc_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|expired|failed');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `last_assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Last Assessment Date');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Name');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{18}[0-9]{2}$');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `management_fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Rate');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `management_fee_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `manager_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Manager Risk Rating');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `manager_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|watch_list');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `manager_status` SET TAGS ('dbx_business_glossary_term' = 'Manager Operational Status');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `manager_status` SET TAGS ('dbx_value_regex' = 'active|under_review|approved|suspended|terminated|prospect');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `manager_type` SET TAGS ('dbx_business_glossary_term' = 'Manager Type');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `manager_type` SET TAGS ('dbx_value_regex' = 'GP|sub_advisor|FoF_manager|co_invest_manager|SMA_manager');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `number_of_funds` SET TAGS ('dbx_business_glossary_term' = 'Number of Funds Managed');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `number_of_investment_professionals` SET TAGS ('dbx_business_glossary_term' = 'Number of Investment Professionals');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `operational_due_diligence_date` SET TAGS ('dbx_business_glossary_term' = 'Operational Due Diligence (ODD) Last Completed Date');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `pitchbook_manager_code` SET TAGS ('dbx_business_glossary_term' = 'PitchBook Manager Identifier');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `preferred_lp_terms_flag` SET TAGS ('dbx_business_glossary_term' = 'Preferred Limited Partner (LP) Terms Flag');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `preqin_manager_code` SET TAGS ('dbx_business_glossary_term' = 'Preqin Manager Identifier');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `pri_signatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Principles for Responsible Investment (PRI) Signatory Flag');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Relationship Contact Email');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Primary Relationship Contact Name');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `primary_regulator` SET TAGS ('dbx_business_glossary_term' = 'Primary Regulatory Authority');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `registration_country` SET TAGS ('dbx_business_glossary_term' = 'Registration Country Code');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `registration_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `regulatory_registration_number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Registration Number');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `relationship_inception_date` SET TAGS ('dbx_business_glossary_term' = 'Relationship Inception Date');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `relationship_termination_date` SET TAGS ('dbx_business_glossary_term' = 'Relationship Termination Date');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `short_name` SET TAGS ('dbx_business_glossary_term' = 'GP Short Name');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `sub_strategy` SET TAGS ('dbx_business_glossary_term' = 'Sub-Strategy');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `tcfd_aligned_flag` SET TAGS ('dbx_business_glossary_term' = 'Task Force on Climate-related Financial Disclosures (TCFD) Aligned Flag');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `track_record_years` SET TAGS ('dbx_business_glossary_term' = 'Track Record Length (Years)');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `vintage_year_first` SET TAGS ('dbx_business_glossary_term' = 'First Vintage Year');
ALTER TABLE `asset_management`.`manager`.`gp_profile` ALTER COLUMN `vintage_year_latest` SET TAGS ('dbx_business_glossary_term' = 'Latest Vintage Year');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` SET TAGS ('dbx_subdomain' = 'mandate_governance');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Mandate ID');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian ID');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Esg Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `exclusion_list_id` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `ic_approval_ic_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval ID');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `ic_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval ID');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `investment_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `manager_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Benchmark ID');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `sfdr_disclosure_id` SET TAGS ('dbx_business_glossary_term' = 'Sfdr Disclosure Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `valuation_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `carried_interest_rate` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Rate');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `carried_interest_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `co_investment_rights` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Rights');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Capital Commitment Amount');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `commitment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Mandate Currency Code');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `domicile_country` SET TAGS ('dbx_business_glossary_term' = 'Fund Domicile Country');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `domicile_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Mandate Effective Date');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `esg_integration_level` SET TAGS ('dbx_business_glossary_term' = 'ESG Integration Level');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `esg_integration_level` SET TAGS ('dbx_value_regex' = 'FULL|PARTIAL|EXCLUSIONS_ONLY|NONE');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Mandate Expiry Date');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Focus');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `governing_law_country` SET TAGS ('dbx_business_glossary_term' = 'Governing Law Country');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `governing_law_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `hurdle_rate` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate (Preferred Return)');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `investment_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Period End Date');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `key_person_clause` SET TAGS ('dbx_business_glossary_term' = 'Key Person Clause');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `last_odd_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Operational Due Diligence (ODD) Review Date');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `lock_up_period_months` SET TAGS ('dbx_business_glossary_term' = 'Lock-Up Period (Months)');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `lp_advisory_committee_seat` SET TAGS ('dbx_business_glossary_term' = 'LP Advisory Committee (LPAC) Seat');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `lpa_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reference Number');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `lpa_reference_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `management_fee_basis` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Basis');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `management_fee_basis` SET TAGS ('dbx_value_regex' = 'COMMITTED_CAPITAL|INVESTED_CAPITAL|NAV|AUM');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `management_fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Rate');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `management_fee_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `manager_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Manager Risk Rating');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `manager_risk_rating` SET TAGS ('dbx_value_regex' = 'LOW|MEDIUM|HIGH|WATCH_LIST|TERMINATED');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `mandate_name` SET TAGS ('dbx_business_glossary_term' = 'Mandate Name');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `mandate_status` SET TAGS ('dbx_business_glossary_term' = 'Mandate Status');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `mandate_status` SET TAGS ('dbx_value_regex' = 'DRAFT|ACTIVE|SUSPENDED|TERMINATED|EXPIRED|PENDING_CLOSE');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `mandate_type` SET TAGS ('dbx_business_glossary_term' = 'Mandate Type');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `mandate_type` SET TAGS ('dbx_value_regex' = 'LP_FUND_COMMITMENT|SMA|CO_INVESTMENT|FOF|ADVISORY');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `max_allocation_pct` SET TAGS ('dbx_business_glossary_term' = 'Maximum Allocation Percentage');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `max_extension_years` SET TAGS ('dbx_business_glossary_term' = 'Maximum Extension Years');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `min_allocation_pct` SET TAGS ('dbx_business_glossary_term' = 'Minimum Allocation Percentage');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `most_favored_nation_flag` SET TAGS ('dbx_business_glossary_term' = 'Most Favored Nation (MFN) Flag');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `next_odd_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Operational Due Diligence (ODD) Review Date');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `redemption_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Redemption Notice Period (Days)');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `reference_code` SET TAGS ('dbx_business_glossary_term' = 'Mandate Reference Code');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `reference_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,6}-[A-Z0-9]{4,12}-[0-9]{4}$');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'MONTHLY|QUARTERLY|SEMI_ANNUAL|ANNUAL');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `sla_reporting_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Reporting Breach Flag');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `sub_asset_class` SET TAGS ('dbx_business_glossary_term' = 'Sub-Asset Class');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `target_allocation_amount` SET TAGS ('dbx_business_glossary_term' = 'Target Allocation Amount');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `target_allocation_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `target_allocation_pct` SET TAGS ('dbx_business_glossary_term' = 'Target Allocation Percentage');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `term_extension_option` SET TAGS ('dbx_business_glossary_term' = 'Term Extension Option');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Valuation Methodology');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_value_regex' = 'FAIR_VALUE|COST|NAV|MARK_TO_MARKET|MARK_TO_MODEL');
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`manager`.`rfp` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`manager`.`rfp` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`rfp` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`rfp` SET TAGS ('dbx_subdomain' = 'manager_selection');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `rfp_id` SET TAGS ('dbx_business_glossary_term' = 'Request for Proposal (RFP) ID');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate ID');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `performance_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Performance Benchmark Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `award_target_date` SET TAGS ('dbx_business_glossary_term' = 'Award Target Date');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `closed_date` SET TAGS ('dbx_business_glossary_term' = 'RFP Closed Date');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `distribution_channel` SET TAGS ('dbx_business_glossary_term' = 'RFP Distribution Channel');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `distribution_channel` SET TAGS ('dbx_value_regex' = 'direct|intermediary|consultant|public_tender|platform');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `esg_framework` SET TAGS ('dbx_business_glossary_term' = 'ESG Framework');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `esg_requirement` SET TAGS ('dbx_business_glossary_term' = 'ESG Requirement Level');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `esg_requirement` SET TAGS ('dbx_value_regex' = 'mandatory|preferred|not_required');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `evaluation_start_date` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Start Date');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `geography` SET TAGS ('dbx_business_glossary_term' = 'Target Geography');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `gips_compliance_required` SET TAGS ('dbx_business_glossary_term' = 'GIPS Compliance Required');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `hurdle_rate` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate (Preferred Return Threshold)');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `ic_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Required');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `issuance_date` SET TAGS ('dbx_business_glossary_term' = 'RFP Issuance Date');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `kyc_aml_required` SET TAGS ('dbx_business_glossary_term' = 'KYC/AML Compliance Required');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `lead_analyst` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `mandate_size` SET TAGS ('dbx_business_glossary_term' = 'Mandate Size');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `mandate_size` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `min_strategy_aum` SET TAGS ('dbx_business_glossary_term' = 'Minimum Strategy Assets Under Management (AUM)');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `min_track_record_years` SET TAGS ('dbx_business_glossary_term' = 'Minimum Track Record Years');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `nda_required` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Required');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'RFP Notes');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'RFP Reference Number');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `reference_number` SET TAGS ('dbx_value_regex' = '^RFP-[0-9]{4}-[0-9]{5}$');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `response_deadline` SET TAGS ('dbx_business_glossary_term' = 'Response Deadline Date');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `responses_received` SET TAGS ('dbx_business_glossary_term' = 'Number of Responses Received');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `rfp_status` SET TAGS ('dbx_business_glossary_term' = 'RFP Status');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `rfp_type` SET TAGS ('dbx_business_glossary_term' = 'RFP Type');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `rfp_type` SET TAGS ('dbx_value_regex' = 'RFP|RFI|RFQ|DDQ');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `shortlisted_count` SET TAGS ('dbx_business_glossary_term' = 'Shortlisted Manager Count');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `sourcing_origin` SET TAGS ('dbx_business_glossary_term' = 'Sourcing Origin');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `sourcing_origin` SET TAGS ('dbx_value_regex' = 'proactive|reactive|consultant_recommended|board_directed|regulatory');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `strategy_description` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy Description');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `sub_asset_class` SET TAGS ('dbx_business_glossary_term' = 'Sub-Asset Class');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `target_aum_max` SET TAGS ('dbx_business_glossary_term' = 'Target Assets Under Management (AUM) Maximum');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `target_aum_min` SET TAGS ('dbx_business_glossary_term' = 'Target Assets Under Management (AUM) Minimum');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `target_irr` SET TAGS ('dbx_business_glossary_term' = 'Target Internal Rate of Return (IRR)');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'RFP Title');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `vehicle_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Vehicle Type');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `weight_esg` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Weight - ESG (%)');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `weight_fees` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Weight - Fees (%)');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `weight_investment_process` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Weight - Investment Process (%)');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `weight_operational_dd` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Weight - Operational Due Diligence (ODD) (%)');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `weight_risk_management` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Weight - Risk Management (%)');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `weight_team_experience` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Weight - Team Experience (%)');
ALTER TABLE `asset_management`.`manager`.`rfp` ALTER COLUMN `weight_track_record` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Weight - Track Record (%)');
ALTER TABLE `asset_management`.`manager`.`rfp_response` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`manager`.`rfp_response` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`rfp_response` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`rfp_response` SET TAGS ('dbx_subdomain' = 'manager_selection');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `rfp_response_id` SET TAGS ('dbx_business_glossary_term' = 'Request for Proposal (RFP) Response ID');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Fund Manager ID');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Fund Manager ID');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `performance_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Performance Benchmark Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `rfp_id` SET TAGS ('dbx_business_glossary_term' = 'Request for Proposal (RFP) ID');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `aum_at_submission_usd` SET TAGS ('dbx_business_glossary_term' = 'Assets Under Management (AUM) at Submission (USD)');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `aum_at_submission_usd` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `carried_interest_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Proposed Carried Interest (Carry) Rate (%)');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `carried_interest_rate_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `esg_policy_disclosed` SET TAGS ('dbx_business_glossary_term' = 'ESG Policy Disclosed Flag');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `esg_score` SET TAGS ('dbx_business_glossary_term' = 'ESG Evaluation Score');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `esg_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `evaluation_lead` SET TAGS ('dbx_business_glossary_term' = 'RFP Evaluation Lead');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `evaluation_notes` SET TAGS ('dbx_business_glossary_term' = 'Internal Evaluation Notes');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `evaluation_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `fee_basis` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Basis');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `fee_basis` SET TAGS ('dbx_value_regex' = 'committed_capital|invested_capital|nav|gross_asset_value');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `fee_competitiveness_score` SET TAGS ('dbx_business_glossary_term' = 'Fee Competitiveness Score');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `fee_competitiveness_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `fund_term_years` SET TAGS ('dbx_business_glossary_term' = 'Proposed Fund Term (Years)');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `hurdle_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Proposed Hurdle Rate (Preferred Return) (%)');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `hurdle_rate_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `ic_presentation_required` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Presentation Required Flag');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `investment_merit_score` SET TAGS ('dbx_business_glossary_term' = 'Investment Merit Evaluation Score');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `investment_merit_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `investment_period_years` SET TAGS ('dbx_business_glossary_term' = 'Proposed Investment Period (Years)');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `key_person_risk_flag` SET TAGS ('dbx_business_glossary_term' = 'Key Person Risk Flag');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `key_personnel_count` SET TAGS ('dbx_business_glossary_term' = 'Key Investment Personnel Count');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `management_fee_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Proposed Management Fee Rate (Basis Points)');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `management_fee_rate_bps` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `nda_executed` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Executed Flag');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `operational_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Operational Risk (ODD) Score');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `operational_risk_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `overall_evaluation_score` SET TAGS ('dbx_business_glossary_term' = 'Overall RFP Evaluation Score');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `overall_evaluation_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `pri_signatory` SET TAGS ('dbx_business_glossary_term' = 'Principles for Responsible Investment (PRI) Signatory Flag');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `prior_fund_count` SET TAGS ('dbx_business_glossary_term' = 'Prior Fund Count');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `proposed_commitment_usd` SET TAGS ('dbx_business_glossary_term' = 'Proposed Capital Commitment (USD)');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `proposed_commitment_usd` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `proposed_fund_size_usd` SET TAGS ('dbx_business_glossary_term' = 'Proposed Fund Size (USD)');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `proposed_fund_size_usd` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `proposed_strategy_description` SET TAGS ('dbx_business_glossary_term' = 'Proposed Investment Strategy Description');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `proposed_strategy_name` SET TAGS ('dbx_business_glossary_term' = 'Proposed Investment Strategy Name');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `received_timestamp` SET TAGS ('dbx_business_glossary_term' = 'RFP Response Received Timestamp');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `response_document_reference` SET TAGS ('dbx_business_glossary_term' = 'RFP Response Document Reference');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `response_document_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `response_reference_number` SET TAGS ('dbx_business_glossary_term' = 'RFP Response Reference Number');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `shortlist_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Shortlist Recommendation Flag');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `strategy_aum_usd` SET TAGS ('dbx_business_glossary_term' = 'Strategy Assets Under Management (AUM) (USD)');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `strategy_aum_usd` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `strategy_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy Type');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'RFP Response Submission Date');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `submission_status` SET TAGS ('dbx_business_glossary_term' = 'RFP Response Submission Status');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `submission_status` SET TAGS ('dbx_value_regex' = 'submitted|under_review|shortlisted|rejected|withdrawn|awarded');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `submission_timestamp` SET TAGS ('dbx_business_glossary_term' = 'RFP Response Submission Timestamp');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `target_geography` SET TAGS ('dbx_business_glossary_term' = 'Target Investment Geography');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `target_irr_pct` SET TAGS ('dbx_business_glossary_term' = 'Target Internal Rate of Return (IRR) (%)');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `target_moic` SET TAGS ('dbx_business_glossary_term' = 'Target Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `tcfd_aligned` SET TAGS ('dbx_business_glossary_term' = 'Task Force on Climate-related Financial Disclosures (TCFD) Alignment Flag');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `team_composition_description` SET TAGS ('dbx_business_glossary_term' = 'Investment Team Composition Description');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `team_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Investment Team Quality Score');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `team_quality_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `track_record_summary` SET TAGS ('dbx_business_glossary_term' = 'Manager Track Record Summary');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `track_record_years` SET TAGS ('dbx_business_glossary_term' = 'Manager Track Record Length (Years)');
ALTER TABLE `asset_management`.`manager`.`rfp_response` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`manager`.`mandate_term` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`manager`.`mandate_term` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`mandate_term` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`mandate_term` SET TAGS ('dbx_subdomain' = 'mandate_governance');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `mandate_term_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate Term ID');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate ID');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `audit_firm` SET TAGS ('dbx_business_glossary_term' = 'Fund Audit Firm');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `carried_interest_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Rate (Percentage)');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `carried_interest_rate_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `carry_split_lp_pct` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest LP Split (Percentage)');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `carry_split_lp_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `clawback_flag` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision Flag');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `clawback_lookback_years` SET TAGS ('dbx_business_glossary_term' = 'Clawback Lookback Period (Years)');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `co_invest_carry_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Carried Interest Rate (Percentage)');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `co_invest_carry_rate_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `co_invest_fee_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Management Fee Rate (Basis Points)');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `co_invest_fee_rate_bps` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `co_invest_rights_flag` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Rights Flag');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Commitment Currency (ISO 4217)');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `committed_capital_amount` SET TAGS ('dbx_business_glossary_term' = 'Committed Capital Amount');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `committed_capital_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `esg_side_letter_flag` SET TAGS ('dbx_business_glossary_term' = 'ESG Side Letter Flag');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `excuse_right_flag` SET TAGS ('dbx_business_glossary_term' = 'LP Excuse Right Flag');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `extension_option_years` SET TAGS ('dbx_business_glossary_term' = 'Extension Option (Years)');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `fee_base` SET TAGS ('dbx_business_glossary_term' = 'Fee Base');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `fee_base` SET TAGS ('dbx_value_regex' = 'committed_capital|invested_capital|NAV|GAV|AUM');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `fee_base` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `fee_frequency` SET TAGS ('dbx_business_glossary_term' = 'Fee Payment Frequency');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `fee_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `fee_payment_timing` SET TAGS ('dbx_business_glossary_term' = 'Fee Payment Timing');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `fee_payment_timing` SET TAGS ('dbx_value_regex' = 'in_advance|in_arrears');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `fund_administrator` SET TAGS ('dbx_business_glossary_term' = 'Fund Administrator');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `fund_domicile` SET TAGS ('dbx_business_glossary_term' = 'Fund Domicile (ISO 3166-1 Alpha-3)');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `fund_domicile` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `fund_term_years` SET TAGS ('dbx_business_glossary_term' = 'Fund Term (Years)');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `governing_law_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Governing Law Jurisdiction (ISO 3166-1 Alpha-3)');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `governing_law_jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `gp_catch_up_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Catch-Up Rate (Percentage)');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `gp_catch_up_rate_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `high_water_mark_flag` SET TAGS ('dbx_business_glossary_term' = 'High-Water Mark Flag');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `hurdle_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate / Preferred Return (Percentage)');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `hurdle_rate_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `hurdle_type` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Type');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `hurdle_type` SET TAGS ('dbx_value_regex' = 'hard|soft|none');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `investment_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Period End Date');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `key_person_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Key Person Clause Flag');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `lp_advisory_committee_flag` SET TAGS ('dbx_business_glossary_term' = 'LP Advisory Committee (LPAC) Flag');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `mandate_type` SET TAGS ('dbx_business_glossary_term' = 'Mandate Type');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `mandate_type` SET TAGS ('dbx_value_regex' = 'LPA|SMA|co_investment|FoF|sub_advisory|co_investment_side_letter');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `mgmt_fee_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Rate (Basis Points)');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `mgmt_fee_rate_bps` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `mgmt_fee_tier_schedule` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Tier Schedule');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `mgmt_fee_tier_schedule` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `monitoring_fee_offset_pct` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Fee Offset (Percentage)');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `monitoring_fee_offset_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `most_favored_nation_flag` SET TAGS ('dbx_business_glossary_term' = 'Most Favored Nation (MFN) Flag');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `no_fault_divorce_flag` SET TAGS ('dbx_business_glossary_term' = 'No-Fault Divorce / GP Removal Flag');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `organizational_expense_cap_pct` SET TAGS ('dbx_business_glossary_term' = 'Organizational Expense Cap (Percentage)');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `organizational_expense_cap_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `post_investment_fee_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Post-Investment Period Management Fee Rate (Basis Points)');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `post_investment_fee_rate_bps` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `term_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Mandate Term Reference Code');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `term_reference_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{4,30}$');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `term_reference_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `term_status` SET TAGS ('dbx_business_glossary_term' = 'Mandate Term Status');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `term_status` SET TAGS ('dbx_value_regex' = 'draft|active|amended|suspended|terminated|expired');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Valuation Methodology');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_value_regex' = 'IPEV|IFRS_13|FASB_ASC_820|NAV|other');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `waterfall_type` SET TAGS ('dbx_business_glossary_term' = 'Waterfall Type');
ALTER TABLE `asset_management`.`manager`.`mandate_term` ALTER COLUMN `waterfall_type` SET TAGS ('dbx_value_regex' = 'deal_by_deal|whole_fund|modified_whole_fund');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` SET TAGS ('dbx_subdomain' = 'mandate_governance');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `mandate_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate Amendment ID');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Approval Authority ID');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate ID');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `mandate_dealcloud_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'DealCloud Amendment System ID');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `mandate_efront_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'eFront Amendment System ID');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `amendment_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Date');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `amendment_rationale` SET TAGS ('dbx_business_glossary_term' = 'Amendment Rationale');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `amendment_rationale` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `amendment_reference` SET TAGS ('dbx_business_glossary_term' = 'Amendment Reference Number');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `amendment_reference` SET TAGS ('dbx_value_regex' = '^AMD-[A-Z0-9]{4,20}-[0-9]{4}-[0-9]{3,6}$');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_business_glossary_term' = 'Amendment Lifecycle Status');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|approved|executed|rejected|withdrawn');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_business_glossary_term' = 'Amendment Type');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_value_regex' = 'fee_renegotiation|guideline_change|term_extension|side_letter|co_invest_right|termination_notice');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `amendment_version` SET TAGS ('dbx_business_glossary_term' = 'Amendment Version Number');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `approval_level` SET TAGS ('dbx_business_glossary_term' = 'Approval Level');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `approval_level` SET TAGS ('dbx_value_regex' = 'cio|investment_committee|board|delegated_authority|portfolio_manager');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `clause_description` SET TAGS ('dbx_business_glossary_term' = 'Clause Description');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `clause_reference` SET TAGS ('dbx_business_glossary_term' = 'Clause Reference');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `counterparty_signed_date` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Signed Date');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `document_reference` SET TAGS ('dbx_business_glossary_term' = 'Amendment Document Reference');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Effective Date');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `esg_impact_assessed` SET TAGS ('dbx_business_glossary_term' = 'ESG Impact Assessed Indicator');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Expiry Date');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `fee_type_amended` SET TAGS ('dbx_business_glossary_term' = 'Fee Type Amended');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `fee_type_amended` SET TAGS ('dbx_value_regex' = 'management_fee|carried_interest|hurdle_rate|preferred_return|transaction_fee|monitoring_fee');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `ic_approval_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Reference');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `internal_signed_date` SET TAGS ('dbx_business_glossary_term' = 'Internal Signatory Date');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `investment_guideline_category` SET TAGS ('dbx_business_glossary_term' = 'Investment Guideline Category');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `is_material_amendment` SET TAGS ('dbx_business_glossary_term' = 'Material Amendment Indicator');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `is_side_letter` SET TAGS ('dbx_business_glossary_term' = 'Side Letter Indicator');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `legal_counsel_firm` SET TAGS ('dbx_business_glossary_term' = 'Legal Counsel Firm');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `legal_review_completed` SET TAGS ('dbx_business_glossary_term' = 'Legal Review Completed Indicator');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `mfn_applicable` SET TAGS ('dbx_business_glossary_term' = 'Most Favoured Nation (MFN) Clause Applicable');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `negotiation_summary` SET TAGS ('dbx_business_glossary_term' = 'Negotiation Summary');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `negotiation_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `prior_carry_rate` SET TAGS ('dbx_business_glossary_term' = 'Prior Carried Interest (Carry) Rate');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `prior_carry_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `prior_hurdle_rate` SET TAGS ('dbx_business_glossary_term' = 'Prior Hurdle Rate (Preferred Return)');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `prior_hurdle_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `prior_management_fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Prior Management Fee Rate');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `prior_management_fee_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `prior_term_end_date` SET TAGS ('dbx_business_glossary_term' = 'Prior Mandate Term End Date');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `prior_value` SET TAGS ('dbx_business_glossary_term' = 'Prior Clause Value');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `prior_value` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `regulatory_disclosure_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Disclosure Required Indicator');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `revised_carry_rate` SET TAGS ('dbx_business_glossary_term' = 'Revised Carried Interest (Carry) Rate');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `revised_carry_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `revised_hurdle_rate` SET TAGS ('dbx_business_glossary_term' = 'Revised Hurdle Rate (Preferred Return)');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `revised_hurdle_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `revised_management_fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Revised Management Fee Rate');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `revised_management_fee_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `revised_term_end_date` SET TAGS ('dbx_business_glossary_term' = 'Revised Mandate Term End Date');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `revised_value` SET TAGS ('dbx_business_glossary_term' = 'Revised Clause Value');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `revised_value` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `side_letter_type` SET TAGS ('dbx_business_glossary_term' = 'Side Letter Type');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `side_letter_type` SET TAGS ('dbx_value_regex' = 'mfn_clause|co_invest_right|fee_discount|reporting_right|excuse_right|other');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `term_extension_years` SET TAGS ('dbx_business_glossary_term' = 'Term Extension (Years)');
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ALTER COLUMN `value_unit` SET TAGS ('dbx_business_glossary_term' = 'Clause Value Unit');
ALTER TABLE `asset_management`.`manager`.`manager_contact` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`manager`.`manager_contact` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`manager_contact` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`manager_contact` SET TAGS ('dbx_subdomain' = 'manager_selection');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `manager_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Contact ID');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Relationship Owner Employee ID');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Firm ID');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `manager_firm_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Firm ID');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `contact_status` SET TAGS ('dbx_business_glossary_term' = 'Contact Status');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `contact_status` SET TAGS ('dbx_value_regex' = 'active|inactive|departed|on_leave');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `coverage_asset_class` SET TAGS ('dbx_business_glossary_term' = 'Coverage Asset Class');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `coverage_asset_class` SET TAGS ('dbx_value_regex' = 'private_equity|real_estate|infrastructure|natural_resources|credit|public_equities');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `coverage_strategy` SET TAGS ('dbx_business_glossary_term' = 'Coverage Investment Strategy');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `data_consent_date` SET TAGS ('dbx_business_glossary_term' = 'Data Processing Consent Date');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `data_consent_obtained` SET TAGS ('dbx_business_glossary_term' = 'Data Processing Consent Obtained Flag');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `date_joined_firm` SET TAGS ('dbx_business_glossary_term' = 'Contact Date Joined Firm');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `departure_date` SET TAGS ('dbx_business_glossary_term' = 'Contact Departure Date');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `departure_reason` SET TAGS ('dbx_business_glossary_term' = 'Contact Departure Reason');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `departure_reason` SET TAGS ('dbx_value_regex' = 'resignation|retirement|termination|restructuring|unknown');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `direct_phone` SET TAGS ('dbx_business_glossary_term' = 'Contact Direct Phone Number');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `direct_phone` SET TAGS ('dbx_value_regex' = '^+?[1-9]d{1,14}$');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `direct_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `direct_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `do_not_contact` SET TAGS ('dbx_business_glossary_term' = 'Do Not Contact Flag');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `educational_background` SET TAGS ('dbx_business_glossary_term' = 'Contact Educational Background');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `email` SET TAGS ('dbx_business_glossary_term' = 'Contact Business Email Address');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `first_name` SET TAGS ('dbx_business_glossary_term' = 'Contact First Name');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `is_key_person` SET TAGS ('dbx_business_glossary_term' = 'Key Person Flag');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `is_primary_contact` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Flag');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `job_title` SET TAGS ('dbx_business_glossary_term' = 'Contact Job Title');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `key_person_mandate_ref` SET TAGS ('dbx_business_glossary_term' = 'Key Person Mandate Reference');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `kyc_verified` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Verified Flag');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `kyc_verified_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Verification Date');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `last_interaction_date` SET TAGS ('dbx_business_glossary_term' = 'Last Interaction Date');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `last_interaction_type` SET TAGS ('dbx_business_glossary_term' = 'Last Interaction Type');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `last_interaction_type` SET TAGS ('dbx_value_regex' = 'lp_advisory_call|annual_meeting|ic_presentation|site_visit|email|conference');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `last_name` SET TAGS ('dbx_business_glossary_term' = 'Contact Last Name');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `linkedin_url` SET TAGS ('dbx_business_glossary_term' = 'Contact LinkedIn Profile URL');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `linkedin_url` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `mobile_phone` SET TAGS ('dbx_business_glossary_term' = 'Contact Mobile Phone Number');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `mobile_phone` SET TAGS ('dbx_value_regex' = '^+?[1-9]d{1,14}$');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `mobile_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `mobile_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `nda_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Expiry Date');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `nda_in_place` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) In Place Flag');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Contact Relationship Notes');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `office_location_city` SET TAGS ('dbx_business_glossary_term' = 'Contact Office Location City');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `office_location_country` SET TAGS ('dbx_business_glossary_term' = 'Contact Office Location Country');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `office_location_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `pep_status` SET TAGS ('dbx_business_glossary_term' = 'Politically Exposed Person (PEP) Status');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `pep_status` SET TAGS ('dbx_value_regex' = 'not_pep|domestic_pep|foreign_pep|international_org_pep');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `pep_status` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `preferred_contact_method` SET TAGS ('dbx_business_glossary_term' = 'Preferred Contact Method');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `preferred_contact_method` SET TAGS ('dbx_value_regex' = 'email|phone|video_call|in_person');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `preferred_language` SET TAGS ('dbx_business_glossary_term' = 'Contact Preferred Language');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `preferred_language` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `prior_employer` SET TAGS ('dbx_business_glossary_term' = 'Contact Prior Employer');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `professional_designation` SET TAGS ('dbx_business_glossary_term' = 'Contact Professional Designation');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `role_type` SET TAGS ('dbx_business_glossary_term' = 'Contact Role Type');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `role_type` SET TAGS ('dbx_value_regex' = 'investment|investor_relations|compliance|operations|legal|executive');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `sanctions_screened` SET TAGS ('dbx_business_glossary_term' = 'Sanctions Screening Completed Flag');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `sanctions_screened_date` SET TAGS ('dbx_business_glossary_term' = 'Sanctions Screening Date');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `source_system_contact_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Contact Identifier');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `tenure_at_firm_years` SET TAGS ('dbx_business_glossary_term' = 'Contact Tenure at Firm (Years)');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `time_zone` SET TAGS ('dbx_business_glossary_term' = 'Contact Time Zone');
ALTER TABLE `asset_management`.`manager`.`manager_contact` ALTER COLUMN `years_of_experience` SET TAGS ('dbx_business_glossary_term' = 'Contact Years of Investment Experience');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` SET TAGS ('dbx_subdomain' = 'mandate_governance');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `fee_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Fee Schedule ID');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate ID');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `performance_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Performance Benchmark Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'private_equity|real_estate|infrastructure|natural_resources|credit|public_equities');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Fee Calculation Frequency');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `calculation_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `carried_interest_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Rate Percentage');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `carried_interest_rate_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `carry_split_lp_pct` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Split - Limited Partner (LP) Percentage');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `carry_split_lp_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `clawback_escrow_pct` SET TAGS ('dbx_business_glossary_term' = 'Clawback Escrow Percentage');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `clawback_escrow_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `clawback_provision` SET TAGS ('dbx_business_glossary_term' = 'Clawback Provision');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `crystallization_frequency` SET TAGS ('dbx_business_glossary_term' = 'Performance Fee Crystallization Frequency');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `crystallization_frequency` SET TAGS ('dbx_value_regex' = 'annual|quarterly|at_realization|at_fund_end');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `fee_base` SET TAGS ('dbx_business_glossary_term' = 'Fee Base');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `fee_base` SET TAGS ('dbx_value_regex' = 'committed_capital|invested_capital|NAV|GAV|AUM');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `fee_rebate_eligible` SET TAGS ('dbx_business_glossary_term' = 'Fee Rebate Eligible');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `fee_rebate_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Fee Rebate Rate (Basis Points)');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `fee_rebate_rate_bps` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `fee_reporting_standard` SET TAGS ('dbx_business_glossary_term' = 'Fee Reporting Standard');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `fee_reporting_standard` SET TAGS ('dbx_value_regex' = 'ILPA|GIPS|SFDR|custom');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `fee_schedule_status` SET TAGS ('dbx_business_glossary_term' = 'Fee Schedule Status');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `fee_schedule_status` SET TAGS ('dbx_value_regex' = 'active|superseded|terminated|draft|pending_approval');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `gp_catchup_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Catch-Up Rate Percentage');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `gp_catchup_rate_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `high_water_mark_flag` SET TAGS ('dbx_business_glossary_term' = 'High Water Mark Flag');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `hurdle_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate (Preferred Return) Percentage');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `hurdle_rate_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `hurdle_type` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Type');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `hurdle_type` SET TAGS ('dbx_value_regex' = 'hard|soft');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `investment_period_fee_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Investment Period Management Fee Rate (Basis Points)');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `investment_period_fee_rate_bps` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `is_tiered` SET TAGS ('dbx_business_glossary_term' = 'Is Tiered Fee Schedule');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `management_fee_offset_pct` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Offset Percentage');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `management_fee_offset_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `management_fee_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Rate (Basis Points)');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `management_fee_rate_bps` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `mandate_type` SET TAGS ('dbx_business_glossary_term' = 'Mandate Type');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `mandate_type` SET TAGS ('dbx_value_regex' = 'LPA|SMA|co_investment|FoF|sub_advisory');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `monitoring_fee_annual_usd` SET TAGS ('dbx_business_glossary_term' = 'Annual Monitoring Fee (USD)');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `monitoring_fee_annual_usd` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `most_favored_nation_flag` SET TAGS ('dbx_business_glossary_term' = 'Most Favored Nation (MFN) Flag');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Fee Schedule Notes');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `organizational_expense_cap_pct` SET TAGS ('dbx_business_glossary_term' = 'Organizational Expense Cap Percentage');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `organizational_expense_cap_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Fee Payment Frequency');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|in_arrears');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `payment_timing` SET TAGS ('dbx_business_glossary_term' = 'Fee Payment Timing');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `payment_timing` SET TAGS ('dbx_value_regex' = 'in_advance|in_arrears');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `post_investment_period_fee_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Post-Investment Period Management Fee Rate (Basis Points)');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `post_investment_period_fee_rate_bps` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `schedule_code` SET TAGS ('dbx_business_glossary_term' = 'Fee Schedule Code');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `schedule_code` SET TAGS ('dbx_value_regex' = '^FS-[A-Z0-9]{4,20}$');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `schedule_name` SET TAGS ('dbx_business_glossary_term' = 'Fee Schedule Name');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `schedule_type` SET TAGS ('dbx_business_glossary_term' = 'Fee Schedule Type');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `schedule_type` SET TAGS ('dbx_value_regex' = 'management_fee|carried_interest|advisory_fee|performance_fee|transaction_fee|monitoring_fee');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `side_letter_reference` SET TAGS ('dbx_business_glossary_term' = 'Side Letter Reference');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `side_letter_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `tier_1_upper_bound_usd` SET TAGS ('dbx_business_glossary_term' = 'Tier 1 Upper Bound (USD)');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `tier_1_upper_bound_usd` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `tier_2_fee_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Tier 2 Management Fee Rate (Basis Points)');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `tier_2_fee_rate_bps` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `transaction_fee_rate_bps` SET TAGS ('dbx_business_glossary_term' = 'Transaction Fee Rate (Basis Points)');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `transaction_fee_rate_bps` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `waterfall_type` SET TAGS ('dbx_business_glossary_term' = 'Distribution Waterfall Type');
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ALTER COLUMN `waterfall_type` SET TAGS ('dbx_value_regex' = 'deal_by_deal|whole_fund');
ALTER TABLE `asset_management`.`manager`.`evaluation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`manager`.`evaluation` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`evaluation` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`evaluation` SET TAGS ('dbx_subdomain' = 'risk_oversight');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `evaluation_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Evaluation ID');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `composite_id` SET TAGS ('dbx_business_glossary_term' = 'Composite Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Dd Engagement Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approver ID');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `evaluation_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approver ID');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `evaluation_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `evaluation_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `evaluation_lead_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `evaluation_lead_analyst_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `evaluation_lead_analyst_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate ID');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `performance_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Performance Benchmark Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Approval Timestamp');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `benchmark_irr_pct` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `compliance_breach_details` SET TAGS ('dbx_business_glossary_term' = 'Compliance Breach Details');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `compliance_breach_details` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `compliance_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Compliance Breach Flag');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Data Source');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `data_source` SET TAGS ('dbx_value_regex' = 'efront|preqin|pitchbook|manager_report|on_site_visit|combined');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `esg_integration_notes` SET TAGS ('dbx_business_glossary_term' = 'ESG Integration Assessment Notes');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `esg_integration_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `esg_integration_score` SET TAGS ('dbx_business_glossary_term' = 'ESG Integration Maturity Score');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `esg_maturity_level` SET TAGS ('dbx_business_glossary_term' = 'ESG Maturity Level');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `esg_maturity_level` SET TAGS ('dbx_value_regex' = 'leading|advanced|developing|nascent|not_assessed');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `evaluation_date` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Date');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `evaluation_status` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Status');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `evaluation_status` SET TAGS ('dbx_value_regex' = 'draft|in_progress|pending_approval|approved|published|archived');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `evaluation_type` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Type');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `evaluation_type` SET TAGS ('dbx_value_regex' = 'annual_review|interim_review|onboarding|termination_review|ad_hoc');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `executive_summary` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Executive Summary');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `executive_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `fee_compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Fee Compliance Flag');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `ic_decision_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision Date');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `ic_review_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Review Required Flag');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `investment_process_notes` SET TAGS ('dbx_business_glossary_term' = 'Investment Process Assessment Notes');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `investment_process_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `investment_process_score` SET TAGS ('dbx_business_glossary_term' = 'Investment Process Score');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `key_person_departure_flag` SET TAGS ('dbx_business_glossary_term' = 'Key Person Departure Flag');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `methodology` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Methodology');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `methodology` SET TAGS ('dbx_value_regex' = 'scorecard_v1|scorecard_v2|qualitative_only|quantitative_only|hybrid');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `next_evaluation_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Evaluation Date');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `on_site_visit_conducted_flag` SET TAGS ('dbx_business_glossary_term' = 'On-Site Visit Conducted Flag');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `on_site_visit_date` SET TAGS ('dbx_business_glossary_term' = 'On-Site Visit Date');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `operational_infrastructure_notes` SET TAGS ('dbx_business_glossary_term' = 'Operational Infrastructure Assessment Notes');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `operational_infrastructure_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `operational_infrastructure_score` SET TAGS ('dbx_business_glossary_term' = 'Operational Infrastructure Score');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `overall_conviction_rating` SET TAGS ('dbx_business_glossary_term' = 'Overall Conviction Rating');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `overall_conviction_rating` SET TAGS ('dbx_value_regex' = 'high_conviction|conviction|watch|reduce|terminate');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `overall_score` SET TAGS ('dbx_business_glossary_term' = 'Overall Evaluation Score');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `performance_assessment_rating` SET TAGS ('dbx_business_glossary_term' = 'Performance Assessment Rating');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `performance_assessment_rating` SET TAGS ('dbx_value_regex' = 'outperforming|in_line|underperforming|insufficient_track_record');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `prior_conviction_rating` SET TAGS ('dbx_business_glossary_term' = 'Prior Conviction Rating');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `prior_conviction_rating` SET TAGS ('dbx_value_regex' = 'high_conviction|conviction|watch|reduce|terminate');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `rating_change_flag` SET TAGS ('dbx_business_glossary_term' = 'Rating Change Flag');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `recommended_action` SET TAGS ('dbx_business_glossary_term' = 'Recommended Action');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `recommended_action` SET TAGS ('dbx_value_regex' = 'continue|continue_with_conditions|increase_allocation|reduce_allocation|terminate|place_on_watch');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `reference` SET TAGS ('dbx_business_glossary_term' = 'Evaluation Reference Number');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `reference` SET TAGS ('dbx_value_regex' = '^EVAL-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `reported_irr_pct` SET TAGS ('dbx_business_glossary_term' = 'Reported Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `reported_moic` SET TAGS ('dbx_business_glossary_term' = 'Reported Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `reported_tvpi` SET TAGS ('dbx_business_glossary_term' = 'Reported Total Value to Paid-In (TVPI)');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `reporting_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Reporting Quality Score');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `review_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Review Period End Date');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `review_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Review Period Start Date');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `risk_management_notes` SET TAGS ('dbx_business_glossary_term' = 'Risk Management Assessment Notes');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `risk_management_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `risk_management_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Management Quality Score');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `sla_compliance_rating` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Compliance Rating');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `sla_compliance_rating` SET TAGS ('dbx_value_regex' = 'fully_compliant|minor_breaches|material_breaches|non_compliant');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `team_stability_notes` SET TAGS ('dbx_business_glossary_term' = 'Team Stability Assessment Notes');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `team_stability_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `team_stability_score` SET TAGS ('dbx_business_glossary_term' = 'Team Stability Score');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`manager`.`evaluation` ALTER COLUMN `watch_list_flag` SET TAGS ('dbx_business_glossary_term' = 'Watch List Flag');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` SET TAGS ('dbx_subdomain' = 'risk_oversight');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `risk_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment ID');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approver ID');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate ID');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `risk_model_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Model Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `adverse_media_flag` SET TAGS ('dbx_business_glossary_term' = 'Adverse Media Flag');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Assessment Approval Timestamp');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Date');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `assessment_methodology_version` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Methodology Version');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `assessment_methodology_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+$');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `assessment_notes` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Notes');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `assessment_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `assessment_reference` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Reference Number');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `assessment_reference` SET TAGS ('dbx_value_regex' = '^RA-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Status');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'draft|in_review|pending_ic_approval|approved|rejected|superseded');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `assessment_type` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Type');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `assessment_type` SET TAGS ('dbx_value_regex' = 'initial|periodic|event_driven|pre_commitment|post_investment|termination');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `aum_at_assessment` SET TAGS ('dbx_business_glossary_term' = 'Assets Under Management (AUM) at Assessment Date');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `aum_currency` SET TAGS ('dbx_business_glossary_term' = 'Assets Under Management (AUM) Currency');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `aum_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `business_continuity_rating` SET TAGS ('dbx_business_glossary_term' = 'Business Continuity Planning (BCP) Rating');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `business_continuity_rating` SET TAGS ('dbx_value_regex' = 'satisfactory|needs_improvement|unsatisfactory|not_assessed');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `concentration_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Concentration Risk Rating');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `concentration_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `concentration_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Concentration Risk Score');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `counterparty_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Risk Rating');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `counterparty_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `counterparty_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Risk Score');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `critical_findings_count` SET TAGS ('dbx_business_glossary_term' = 'Critical Risk Findings Count');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `cybersecurity_rating` SET TAGS ('dbx_business_glossary_term' = 'Cybersecurity Risk Rating');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `cybersecurity_rating` SET TAGS ('dbx_value_regex' = 'satisfactory|needs_improvement|unsatisfactory|not_assessed');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `enforcement_action_exists` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Enforcement Action Exists Flag');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `esg_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Risk Rating');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `esg_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `esg_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Risk Score');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `keyman_clause_exists` SET TAGS ('dbx_business_glossary_term' = 'Key-Man Clause Exists Flag');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `keyman_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Key-Man Risk Rating');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `keyman_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `keyman_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Key-Man Risk Score');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `liquidity_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Risk Rating');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `liquidity_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `liquidity_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Liquidity Risk Score');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Review Date');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `odd_findings_summary` SET TAGS ('dbx_business_glossary_term' = 'Operational Due Diligence (ODD) Findings Summary');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `odd_findings_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `open_findings_count` SET TAGS ('dbx_business_glossary_term' = 'Open Risk Findings Count');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `operational_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Operational Risk Rating');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `operational_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `operational_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Operational Risk Score');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `overall_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Overall Risk Rating');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `overall_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `overall_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Overall Risk Score');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `pension_fund_aum_pct` SET TAGS ('dbx_business_glossary_term' = 'Pension Fund Allocation as Percentage of Manager AUM');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `recommended_action` SET TAGS ('dbx_business_glossary_term' = 'Recommended Action');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `recommended_action` SET TAGS ('dbx_value_regex' = 'continue|continue_with_conditions|place_on_watch|reduce_exposure|terminate|defer_decision');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `regulatory_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Risk Rating');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `regulatory_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `regulatory_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Risk Score');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `regulatory_status` SET TAGS ('dbx_business_glossary_term' = 'Manager Regulatory Status');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `regulatory_status` SET TAGS ('dbx_value_regex' = 'registered|exempt|pending_registration|suspended|deregistered');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `reputational_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Reputational Risk Rating');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `reputational_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `reputational_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Reputational Risk Score');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `sanctions_screening_status` SET TAGS ('dbx_business_glossary_term' = 'Sanctions Screening Status');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `sanctions_screening_status` SET TAGS ('dbx_value_regex' = 'clear|flagged|pending|escalated');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ALTER COLUMN `watch_list_flag` SET TAGS ('dbx_business_glossary_term' = 'Manager Watch List Flag');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` SET TAGS ('dbx_subdomain' = 'mandate_governance');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `sla_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Agreement ID');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Internal SLA Owner ID');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate ID');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `agreement_name` SET TAGS ('dbx_business_glossary_term' = 'SLA Agreement Name');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'SLA Agreement Type');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'reporting_sla|operational_sla|custody_sla|valuation_sla|compliance_sla|administrator_sla');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `agreement_version` SET TAGS ('dbx_business_glossary_term' = 'SLA Agreement Version');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `agreement_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+$');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `asset_class_scope` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Scope');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `audited_financials_delivery_days` SET TAGS ('dbx_business_glossary_term' = 'Audited Financial Statements Delivery Deadline (Calendar Days)');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `auto_renewal_flag` SET TAGS ('dbx_business_glossary_term' = 'Automatic Renewal Flag');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `breach_notification_hours` SET TAGS ('dbx_business_glossary_term' = 'SLA Breach Notification Period (Hours)');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `capital_account_delivery_days` SET TAGS ('dbx_business_glossary_term' = 'Capital Account Statement Delivery Deadline (Business Days)');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `capital_call_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Capital Call (Drawdown) Notice Period (Business Days)');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `compliance_cert_delivery_days` SET TAGS ('dbx_business_glossary_term' = 'Compliance Certificate Delivery Deadline (Business Days)');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{18}[0-9]{2}$');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `counterparty_name` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Name');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `counterparty_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `custodian_involved` SET TAGS ('dbx_business_glossary_term' = 'Custodian Involved Flag');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `data_delivery_channel` SET TAGS ('dbx_business_glossary_term' = 'Data Delivery Channel');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `data_delivery_format` SET TAGS ('dbx_business_glossary_term' = 'Data Delivery Format');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `distribution_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Distribution Notice Period (Business Days)');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'SLA Effective Date');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `esg_report_delivery_days` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social Governance (ESG) Report Delivery Deadline (Business Days)');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `esg_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social Governance (ESG) Reporting Required Flag');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'SLA Expiry Date');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `fund_admin_involved` SET TAGS ('dbx_business_glossary_term' = 'Fund Administrator Involved Flag');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `gips_compliant_reporting` SET TAGS ('dbx_business_glossary_term' = 'Global Investment Performance Standards (GIPS) Compliant Reporting Flag');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `governing_law_country` SET TAGS ('dbx_business_glossary_term' = 'Governing Law Country');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `governing_law_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `independent_valuation_required` SET TAGS ('dbx_business_glossary_term' = 'Independent Valuation Required Flag');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last SLA Review Date');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `nav_delivery_deadline_days` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Delivery Deadline (Business Days)');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `nav_delivery_frequency` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Delivery Frequency');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `nav_delivery_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next SLA Review Date');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'SLA Agreement Notes');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `penalty_basis_points` SET TAGS ('dbx_business_glossary_term' = 'SLA Breach Penalty Rate (Basis Points)');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `penalty_basis_points` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `penalty_clause_applicable` SET TAGS ('dbx_business_glossary_term' = 'Penalty Clause Applicable Flag');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `performance_report_delivery_days` SET TAGS ('dbx_business_glossary_term' = 'Performance Report Delivery Deadline (Business Days)');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Manager Primary Contact Email');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Manager Primary Contact Name');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `renewal_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Renewal Notice Period (Days)');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `reporting_currency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Currency');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `reporting_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'SLA Review Frequency');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|ad_hoc');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `sla_agreement_status` SET TAGS ('dbx_business_glossary_term' = 'SLA Agreement Status');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `sla_agreement_status` SET TAGS ('dbx_value_regex' = 'draft|active|suspended|terminated|expired|under_review');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `sla_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Reference Number');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `sla_reference_number` SET TAGS ('dbx_value_regex' = '^SLA-[A-Z0-9]{4,20}$');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference ID');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'SLA Termination Date');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'SLA Termination Reason');
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Valuation Methodology');
ALTER TABLE `asset_management`.`manager`.`sla_breach` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`manager`.`sla_breach` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`sla_breach` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`sla_breach` SET TAGS ('dbx_subdomain' = 'risk_oversight');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `sla_breach_id` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Breach ID');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate ID');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `sla_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Obligation ID');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `sla_obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Obligation ID');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `affected_asset_class` SET TAGS ('dbx_business_glossary_term' = 'Affected Asset Class');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `breach_category` SET TAGS ('dbx_business_glossary_term' = 'SLA Breach Category');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `breach_date` SET TAGS ('dbx_business_glossary_term' = 'SLA Breach Date');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `breach_description` SET TAGS ('dbx_business_glossary_term' = 'SLA Breach Description');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `breach_detected_date` SET TAGS ('dbx_business_glossary_term' = 'SLA Breach Detected Date');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `breach_detected_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SLA Breach Detected Timestamp');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `breach_reference_number` SET TAGS ('dbx_business_glossary_term' = 'SLA Breach Reference Number');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `breach_reference_number` SET TAGS ('dbx_value_regex' = '^SLA-BR-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `breach_status` SET TAGS ('dbx_business_glossary_term' = 'SLA Breach Status');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `breach_status` SET TAGS ('dbx_value_regex' = 'open|under_review|remediation_in_progress|resolved|waived|escalated');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `days_overdue` SET TAGS ('dbx_business_glossary_term' = 'Days Overdue');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `days_to_resolution` SET TAGS ('dbx_business_glossary_term' = 'Days to Resolution');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `detection_source` SET TAGS ('dbx_business_glossary_term' = 'Breach Detection Source');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `detection_source` SET TAGS ('dbx_value_regex' = 'automated_monitoring|internal_review|manager_self_report|third_party_audit|regulatory_inquiry');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `escalation_date` SET TAGS ('dbx_business_glossary_term' = 'Escalation Date');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `escalation_level` SET TAGS ('dbx_business_glossary_term' = 'Escalation Level');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `escalation_level` SET TAGS ('dbx_value_regex' = 'none|relationship_manager|head_of_manager_oversight|cio|investment_committee');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `esg_related` SET TAGS ('dbx_business_glossary_term' = 'ESG Related Flag');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `financial_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Financial Impact Amount');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `financial_impact_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `financial_impact_currency` SET TAGS ('dbx_business_glossary_term' = 'Financial Impact Currency Code');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `financial_impact_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `impact_assessment` SET TAGS ('dbx_business_glossary_term' = 'Impact Assessment');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `internal_owner` SET TAGS ('dbx_business_glossary_term' = 'Internal Breach Owner');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `is_contractual_penalty_triggered` SET TAGS ('dbx_business_glossary_term' = 'Is Contractual Penalty Triggered Flag');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `is_regulatory_reportable` SET TAGS ('dbx_business_glossary_term' = 'Is Regulatory Reportable Flag');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `is_repeat_breach` SET TAGS ('dbx_business_glossary_term' = 'Is Repeat Breach Flag');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `manager_response` SET TAGS ('dbx_business_glossary_term' = 'Manager Response');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `manager_response_date` SET TAGS ('dbx_business_glossary_term' = 'Manager Response Date');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `mandate_type` SET TAGS ('dbx_business_glossary_term' = 'Mandate Type');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `mandate_type` SET TAGS ('dbx_value_regex' = 'LPA|SMA|co_investment|FoF');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `obligation_description` SET TAGS ('dbx_business_glossary_term' = 'SLA Obligation Description');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `penalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Contractual Penalty Amount');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `penalty_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `penalty_currency` SET TAGS ('dbx_business_glossary_term' = 'Penalty Currency Code');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `penalty_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `prior_breach_count` SET TAGS ('dbx_business_glossary_term' = 'Prior Breach Count');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `regulatory_body` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Body');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `regulatory_body` SET TAGS ('dbx_value_regex' = 'SEC|FCA|ESMA|IOSCO|none');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `regulatory_report_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Report Date');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `remediation_plan` SET TAGS ('dbx_business_glossary_term' = 'Remediation Plan');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `remediation_target_date` SET TAGS ('dbx_business_glossary_term' = 'Remediation Target Date');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'SLA Breach Resolution Date');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `root_cause_category` SET TAGS ('dbx_business_glossary_term' = 'Root Cause Category');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `root_cause_description` SET TAGS ('dbx_business_glossary_term' = 'Root Cause Description');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `severity_classification` SET TAGS ('dbx_business_glossary_term' = 'SLA Breach Severity Classification');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `severity_classification` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `sla_obligation_date` SET TAGS ('dbx_business_glossary_term' = 'SLA Obligation Due Date');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `waiver_approved_date` SET TAGS ('dbx_business_glossary_term' = 'Waiver Approved Date');
ALTER TABLE `asset_management`.`manager`.`sla_breach` ALTER COLUMN `waiver_justification` SET TAGS ('dbx_business_glossary_term' = 'Waiver Justification');
ALTER TABLE `asset_management`.`manager`.`watchlist` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`manager`.`watchlist` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`watchlist` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`watchlist` SET TAGS ('dbx_subdomain' = 'risk_oversight');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `watchlist_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Watchlist ID');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate ID');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `approving_officer` SET TAGS ('dbx_business_glossary_term' = 'Approving Officer');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `aum_at_placement` SET TAGS ('dbx_business_glossary_term' = 'Assets Under Management (AUM) at Placement');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `aum_at_placement` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `aum_currency` SET TAGS ('dbx_business_glossary_term' = 'Assets Under Management (AUM) Currency');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `aum_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `watchlist_category` SET TAGS ('dbx_business_glossary_term' = 'Watchlist Category');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `watchlist_category` SET TAGS ('dbx_value_regex' = 'performance|key_man|regulatory|odd_finding|strategic_misalignment|esg_concern');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `consecutive_underperformance_quarters` SET TAGS ('dbx_business_glossary_term' = 'Consecutive Underperformance Quarters');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `engagement_log_summary` SET TAGS ('dbx_business_glossary_term' = 'Manager Engagement Log Summary');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `engagement_log_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `esg_concern_category` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Concern Category');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `esg_concern_category` SET TAGS ('dbx_value_regex' = 'environmental|social|governance|combined');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `esg_concern_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Concern Flag');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `ic_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Required');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `ic_decision` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `ic_decision` SET TAGS ('dbx_value_regex' = 'continue_monitoring|initiate_redemption|terminate_mandate|defer|no_action');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `ic_review_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Review Date');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `key_man_clause_triggered` SET TAGS ('dbx_business_glossary_term' = 'Key-Man Clause Triggered');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `key_man_departure_flag` SET TAGS ('dbx_business_glossary_term' = 'Key-Man Departure Flag');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `lead_analyst` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `manager_response_date` SET TAGS ('dbx_business_glossary_term' = 'Manager Response Date');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `manager_response_received` SET TAGS ('dbx_business_glossary_term' = 'Manager Response Received Flag');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `manager_strategy` SET TAGS ('dbx_business_glossary_term' = 'Manager Investment Strategy');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `new_capital_deployment_suspended` SET TAGS ('dbx_business_glossary_term' = 'New Capital Deployment Suspended Flag');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Review Date');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `odd_finding_flag` SET TAGS ('dbx_business_glossary_term' = 'Operational Due Diligence (ODD) Finding Flag');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `odd_finding_summary` SET TAGS ('dbx_business_glossary_term' = 'Operational Due Diligence (ODD) Finding Summary');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `odd_finding_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `performance_concern_flag` SET TAGS ('dbx_business_glossary_term' = 'Performance Concern Flag');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `placement_date` SET TAGS ('dbx_business_glossary_term' = 'Watchlist Placement Date');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `portfolio_exposure_pct` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Exposure Percentage');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `portfolio_exposure_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `redemption_notice_date` SET TAGS ('dbx_business_glossary_term' = 'Redemption Notice Date');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `redemption_notice_issued` SET TAGS ('dbx_business_glossary_term' = 'Redemption Notice Issued Flag');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `reference_code` SET TAGS ('dbx_business_glossary_term' = 'Watchlist Reference Code');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `reference_code` SET TAGS ('dbx_value_regex' = '^WL-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `regulatory_body` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Body');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `regulatory_investigation_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Investigation Flag');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `remediation_plan_agreed` SET TAGS ('dbx_business_glossary_term' = 'Remediation Plan Agreed Flag');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `remediation_plan_deadline` SET TAGS ('dbx_business_glossary_term' = 'Remediation Plan Deadline');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Watchlist Resolution Date');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `resolution_outcome` SET TAGS ('dbx_business_glossary_term' = 'Watchlist Resolution Outcome');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `resolution_outcome` SET TAGS ('dbx_value_regex' = 'retained|redeemed|terminated|monitoring_extended|escalated_to_ic');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Watchlist Review Frequency');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|ad_hoc');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `severity_level` SET TAGS ('dbx_business_glossary_term' = 'Watchlist Severity Level');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `severity_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `strategic_misalignment_flag` SET TAGS ('dbx_business_glossary_term' = 'Strategic Misalignment Flag');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `target_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Target Resolution Date');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `trigger_date` SET TAGS ('dbx_business_glossary_term' = 'Watchlist Trigger Date');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `trigger_reason` SET TAGS ('dbx_business_glossary_term' = 'Watchlist Trigger Reason');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `watchlist_status` SET TAGS ('dbx_business_glossary_term' = 'Watchlist Status');
ALTER TABLE `asset_management`.`manager`.`watchlist` ALTER COLUMN `watchlist_status` SET TAGS ('dbx_value_regex' = 'active|under_review|escalated|resolved|closed');
ALTER TABLE `asset_management`.`manager`.`meeting` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`manager`.`meeting` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`meeting` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`meeting` SET TAGS ('dbx_subdomain' = 'relationship_engagement');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `meeting_id` SET TAGS ('dbx_business_glossary_term' = 'Meeting ID');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Internal Lead Staff ID');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `ic_governance_record_id` SET TAGS ('dbx_business_glossary_term' = 'Ic Governance Record Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate ID');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `action_items_count` SET TAGS ('dbx_business_glossary_term' = 'Action Items Count');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `actual_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Meeting Date');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `agenda_summary` SET TAGS ('dbx_business_glossary_term' = 'Meeting Agenda Summary');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `dd_type` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Type');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `dd_type` SET TAGS ('dbx_value_regex' = 'odd|fdd|cdd|esg_dd|legal_dd|not_applicable');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Meeting Duration (Minutes)');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `end_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Meeting End Timestamp');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `escalation_flag` SET TAGS ('dbx_business_glossary_term' = 'Escalation Flag');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `escalation_reason` SET TAGS ('dbx_business_glossary_term' = 'Escalation Reason');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `esg_topics_discussed` SET TAGS ('dbx_business_glossary_term' = 'ESG Topics Discussed');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `esg_topics_summary` SET TAGS ('dbx_business_glossary_term' = 'ESG Topics Summary');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `external_attendee_count` SET TAGS ('dbx_business_glossary_term' = 'External Attendee Count');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `format` SET TAGS ('dbx_business_glossary_term' = 'Meeting Format');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `format` SET TAGS ('dbx_value_regex' = 'in_person|video_conference|telephone|hybrid');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `ic_member_present` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Member Present');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `internal_attendee_count` SET TAGS ('dbx_business_glossary_term' = 'Internal Attendee Count');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `key_risks_identified` SET TAGS ('dbx_business_glossary_term' = 'Key Risks Identified');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `location_city` SET TAGS ('dbx_business_glossary_term' = 'Meeting Location City');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `location_country_code` SET TAGS ('dbx_business_glossary_term' = 'Meeting Location Country Code');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `location_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `location_venue` SET TAGS ('dbx_business_glossary_term' = 'Meeting Venue');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `manager_conviction_rating` SET TAGS ('dbx_business_glossary_term' = 'Manager Conviction Rating');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `manager_conviction_rating` SET TAGS ('dbx_value_regex' = 'high|medium|low|under_review');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `manager_senior_rep_present` SET TAGS ('dbx_business_glossary_term' = 'Manager Senior Representative Present');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `meeting_status` SET TAGS ('dbx_business_glossary_term' = 'Meeting Status');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `meeting_status` SET TAGS ('dbx_value_regex' = 'scheduled|completed|cancelled|rescheduled|pending_minutes');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `meeting_type` SET TAGS ('dbx_business_glossary_term' = 'Meeting Type');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `meeting_type` SET TAGS ('dbx_value_regex' = 'annual_review|quarterly_update|on_site_due_diligence|lpac|ad_hoc_escalation|initial_screening');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `minutes_approved` SET TAGS ('dbx_business_glossary_term' = 'Meeting Minutes Approved');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `minutes_approved_date` SET TAGS ('dbx_business_glossary_term' = 'Meeting Minutes Approved Date');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `minutes_document_ref` SET TAGS ('dbx_business_glossary_term' = 'Meeting Minutes Document Reference');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `next_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Meeting Date');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `next_meeting_type` SET TAGS ('dbx_business_glossary_term' = 'Next Meeting Type');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `next_meeting_type` SET TAGS ('dbx_value_regex' = 'annual_review|quarterly_update|on_site_due_diligence|lpac|ad_hoc_escalation|initial_screening');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `open_action_items_count` SET TAGS ('dbx_business_glossary_term' = 'Open Action Items Count');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `overall_sentiment` SET TAGS ('dbx_business_glossary_term' = 'Overall Meeting Sentiment');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `overall_sentiment` SET TAGS ('dbx_value_regex' = 'positive|neutral|negative|cautionary');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `performance_review_period` SET TAGS ('dbx_business_glossary_term' = 'Performance Review Period');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `performance_review_period` SET TAGS ('dbx_value_regex' = '^(Q[1-4] [0-9]{4}|FY[0-9]{4}|[0-9]{4}-[0-9]{2})$');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `purpose` SET TAGS ('dbx_business_glossary_term' = 'Meeting Purpose');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Meeting Reference Number');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `reference_number` SET TAGS ('dbx_value_regex' = '^MTG-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `scheduled_date` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Meeting Date');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `sla_compliant` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Compliant');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `source_system_ref_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference ID');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `start_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Meeting Start Timestamp');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`manager`.`meeting` ALTER COLUMN `watch_list_flag` SET TAGS ('dbx_business_glossary_term' = 'Manager Watch List Flag');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` SET TAGS ('dbx_subdomain' = 'mandate_governance');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `co_invest_right_id` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment (Co-Invest) Right ID');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund ID');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager (GP) ID');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `ic_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Ic Decision Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager (GP) ID');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate ID');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `allocation_basis` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Allocation Basis');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `allocation_basis` SET TAGS ('dbx_value_regex' = 'percentage_of_deal|percentage_of_commitment|fixed_dollar_cap|uncapped');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `allocation_cap_amount` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Allocation Cap Amount');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `allocation_cap_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `allocation_percentage` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Allocation Percentage');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `allocation_percentage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `annual_utilization_cap_amount` SET TAGS ('dbx_business_glossary_term' = 'Annual Co-Investment Utilization Cap Amount');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `annual_utilization_cap_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `approval_process_type` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Approval Process Type');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `approval_process_type` SET TAGS ('dbx_value_regex' = 'ic_approval|delegated_authority|cio_approval|committee_approval');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'private_equity|infrastructure|real_estate|natural_resources|credit|public_equity');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `carry_rate` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Carried Interest (Carry) Rate');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `carry_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `confidentiality_obligation` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Confidentiality Obligation Flag');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `decision_deadline_days` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Decision Deadline (Days)');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `esg_screening_required` SET TAGS ('dbx_business_glossary_term' = 'ESG Screening Required Flag');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `exclusivity_applicable` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Exclusivity Applicable Flag');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `exclusivity_window_days` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Exclusivity Window (Days)');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `fee_structure_type` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Fee Structure Type');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `fee_structure_type` SET TAGS ('dbx_value_regex' = 'no_fee_no_carry|reduced_fee_no_carry|full_fee_full_carry|reduced_fee_reduced_carry|negotiated');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `fee_structure_type` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Geographic Focus');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `hurdle_rate` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Hurdle Rate (Preferred Return)');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `hurdle_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Right Last Review Date');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `management_fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Management Fee Rate');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `management_fee_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `max_deal_size_amount` SET TAGS ('dbx_business_glossary_term' = 'Maximum Deal Size Amount');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `min_deal_size_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Deal Size Amount');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `negotiation_date` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Right Negotiation Date');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Right Next Scheduled Review Date');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Right Notes');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `notice_period_days` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Notice Period (Days)');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `opportunities_accepted_count` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Opportunities Accepted Count');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `opportunities_declined_count` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Opportunities Declined Count');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `opportunities_offered_count` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Opportunities Offered Count');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `remaining_capacity_amount` SET TAGS ('dbx_business_glossary_term' = 'Remaining Co-Investment Capacity Amount');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `remaining_capacity_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `right_name` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Right Name');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `right_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Right Reference Code');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `right_reference_code` SET TAGS ('dbx_value_regex' = '^CI-[A-Z0-9]{4,20}$');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `right_status` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Right Status');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `right_status` SET TAGS ('dbx_value_regex' = 'active|suspended|expired|terminated|pending_negotiation');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `right_type` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Right Type');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `right_type` SET TAGS ('dbx_value_regex' = 'pro_rata|discretionary|first_look|last_look|capped_allocation');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `sector_focus` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Sector Focus');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `side_letter_reference` SET TAGS ('dbx_business_glossary_term' = 'LPA Side-Letter Reference');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `side_letter_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `total_deployed_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Co-Investment Deployed Amount');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `total_deployed_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `total_right_cap_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Co-Investment Right Cap Amount');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `total_right_cap_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `transferability_permitted` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Right Transferability Permitted Flag');
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` SET TAGS ('dbx_subdomain' = 'relationship_engagement');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `lpac_membership_id` SET TAGS ('dbx_business_glossary_term' = 'Limited Partner Advisory Committee (LPAC) Membership ID');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Pension Fund Representative ID');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `manager_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Pension Fund Representative ID');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Mandate ID');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `alternate_representative_name` SET TAGS ('dbx_business_glossary_term' = 'Alternate LPAC Representative Name');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `alternate_representative_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `appointment_date` SET TAGS ('dbx_business_glossary_term' = 'LPAC Appointment Date');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'LP Commitment Amount');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `commitment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Commitment Currency');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `conflict_of_interest_notes` SET TAGS ('dbx_business_glossary_term' = 'Conflict of Interest Notes');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `conflict_of_interest_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `consent_matters_voted_count` SET TAGS ('dbx_business_glossary_term' = 'LPAC Consent Matters Voted Count');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `data_source_system` SET TAGS ('dbx_value_regex' = 'efront|dealpath|dealcloud|preqin|pitchbook|manual');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `esg_oversight_scope` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Oversight Scope');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `esg_oversight_scope` SET TAGS ('dbx_value_regex' = 'full|limited|none');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `fund_asset_class` SET TAGS ('dbx_business_glossary_term' = 'Fund Asset Class');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `fund_domicile_country` SET TAGS ('dbx_business_glossary_term' = 'Fund Domicile Country');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `fund_domicile_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `fund_legal_entity_identifier` SET TAGS ('dbx_business_glossary_term' = 'Fund Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `fund_legal_entity_identifier` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{18}[0-9]{2}$');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `fund_name` SET TAGS ('dbx_business_glossary_term' = 'Fund Name');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `fund_strategy` SET TAGS ('dbx_business_glossary_term' = 'Fund Investment Strategy');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `fund_vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Fund Vintage Year');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `governance_review_date` SET TAGS ('dbx_business_glossary_term' = 'Governance Review Date');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `gp_consent_required` SET TAGS ('dbx_business_glossary_term' = 'GP Consent Required Flag');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `has_conflict_of_interest_waiver` SET TAGS ('dbx_business_glossary_term' = 'Conflict of Interest Waiver Flag');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `internal_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Internal Approval Date');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `internal_approval_reference` SET TAGS ('dbx_business_glossary_term' = 'Internal Approval Reference');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `is_lead_lp` SET TAGS ('dbx_business_glossary_term' = 'Lead Limited Partner (LP) Flag');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `last_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Last LPAC Meeting Date');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `lp_commitment_pct_of_fund` SET TAGS ('dbx_business_glossary_term' = 'LP Commitment Percentage of Fund');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `lp_commitment_pct_of_fund` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `lpa_side_letter_reference` SET TAGS ('dbx_business_glossary_term' = 'LPA Side Letter Reference');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `lpa_side_letter_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `meetings_attended_count` SET TAGS ('dbx_business_glossary_term' = 'LPAC Meetings Attended Count');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `meetings_scheduled_count` SET TAGS ('dbx_business_glossary_term' = 'LPAC Meetings Scheduled Count');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `membership_status` SET TAGS ('dbx_business_glossary_term' = 'LPAC Membership Status');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `membership_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|resigned|terminated|suspended');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `nda_executed` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Executed Flag');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `nda_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Execution Date');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `next_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Next LPAC Meeting Date');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'LPAC Membership Notes');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `representative_name` SET TAGS ('dbx_business_glossary_term' = 'LPAC Representative Name');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `representative_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `representative_title` SET TAGS ('dbx_business_glossary_term' = 'LPAC Representative Title');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `resignation_date` SET TAGS ('dbx_business_glossary_term' = 'LPAC Resignation Date');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `seat_eligibility_threshold_pct` SET TAGS ('dbx_business_glossary_term' = 'LPAC Seat Eligibility Threshold Percentage');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `seat_source` SET TAGS ('dbx_business_glossary_term' = 'LPAC Seat Source');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `seat_source` SET TAGS ('dbx_value_regex' = 'lpa_standard|side_letter|negotiated_amendment|inherited_transfer');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `seat_type` SET TAGS ('dbx_business_glossary_term' = 'LPAC Seat Type');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `seat_type` SET TAGS ('dbx_value_regex' = 'voting|observer|alternate|advisory');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `term_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'LPAC Term Expiry Date');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `voting_weight_pct` SET TAGS ('dbx_business_glossary_term' = 'LPAC Voting Weight Percentage');
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ALTER COLUMN `voting_weight_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`manager`.`strategy` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`manager`.`strategy` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`strategy` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`strategy` SET TAGS ('dbx_subdomain' = 'manager_selection');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Strategy ID (STR_ID)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class (AST_CLSS)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `strategy_code` SET TAGS ('dbx_business_glossary_term' = 'Strategy Code (STR_CODE)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp (CREATED_TS)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `strategy_description` SET TAGS ('dbx_business_glossary_term' = 'Strategy Description (STR_DESC)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Focus (GEO_FOCUS)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `strategy_name` SET TAGS ('dbx_business_glossary_term' = 'Strategy Name (STR_NAME)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `strategy_status` SET TAGS ('dbx_business_glossary_term' = 'Strategy Status (STR_STATUS)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `strategy_status` SET TAGS ('dbx_value_regex' = 'active|inactive|draft|archived');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `sub_strategy_type` SET TAGS ('dbx_business_glossary_term' = 'Sub-Strategy Type (SUB_STRAT_TYPE)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_allocation_amount` SET TAGS ('dbx_business_glossary_term' = 'Target Allocation Amount (TAR_ALLOC_AMT)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_allocation_pct` SET TAGS ('dbx_business_glossary_term' = 'Target Allocation Percentage (TAR_ALLOC_PCT)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_aum_max` SET TAGS ('dbx_business_glossary_term' = 'Target AUM Maximum (TAR_AUM_MAX)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_aum_min` SET TAGS ('dbx_business_glossary_term' = 'Target AUM Minimum (TAR_AUM_MIN)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_carry_rate` SET TAGS ('dbx_business_glossary_term' = 'Target Carry Rate (TAR_CARRY_RATE)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_co_investment_flag` SET TAGS ('dbx_business_glossary_term' = 'Target Co-Investment Flag (TAR_CO_INVEST_FLAG)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_commitment` SET TAGS ('dbx_business_glossary_term' = 'Target Commitment (TAR_COMMITMENT)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_dpi` SET TAGS ('dbx_business_glossary_term' = 'Target DPI (TAR_DPI)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_esg_integration_level` SET TAGS ('dbx_business_glossary_term' = 'Target ESG Integration Level (TAR_ESG_INTEGRATION_LEVEL)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_esg_integration_level` SET TAGS ('dbx_value_regex' = 'none|basic|advanced|full');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_fund_size` SET TAGS ('dbx_business_glossary_term' = 'Target Fund Size (TAR_FUND_SIZE)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_gps` SET TAGS ('dbx_business_glossary_term' = 'Target GIPS Compliance (TAR_GIPS)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_gps` SET TAGS ('dbx_value_regex' = 'gips|non-gips');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_hurdle_rate` SET TAGS ('dbx_business_glossary_term' = 'Target Hurdle Rate (TAR_HURDLE_RATE)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_irr` SET TAGS ('dbx_business_glossary_term' = 'Target IRR (TAR_IRR)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_lpa_carry` SET TAGS ('dbx_business_glossary_term' = 'Target LPA Carry (TAR_LPA_CARRY)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_lpa_carry_rate` SET TAGS ('dbx_business_glossary_term' = 'Target LPA Carry Rate (TAR_LPA_CARRY_RATE)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_lpa_carry_split` SET TAGS ('dbx_business_glossary_term' = 'Target LPA Carry Split (TAR_LPA_CARRY_SPLIT)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_lpa_end_date` SET TAGS ('dbx_business_glossary_term' = 'Target LPA End Date (TAR_LPA_END_DATE)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_lpa_fee_structure` SET TAGS ('dbx_business_glossary_term' = 'Target LPA Fee Structure (TAR_LPA_FEE_STRUCTURE)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_lpa_fee_structure` SET TAGS ('dbx_value_regex' = 'flat|tiered|performance');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_lpa_hurdle` SET TAGS ('dbx_business_glossary_term' = 'Target LPA Hurdle (TAR_LPA_HURDLE)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_lpa_mgmt_fee` SET TAGS ('dbx_business_glossary_term' = 'Target LPA Management Fee (TAR_LPA_MGMT_FEE)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_lpa_reference` SET TAGS ('dbx_business_glossary_term' = 'Target LPA Reference (TAR_LPA_REFERENCE)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_lpa_start_date` SET TAGS ('dbx_business_glossary_term' = 'Target LPA Start Date (TAR_LPA_START_DATE)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_lpa_status` SET TAGS ('dbx_business_glossary_term' = 'Target LPA Status (TAR_LPA_STATUS)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_lpa_status` SET TAGS ('dbx_value_regex' = 'active|suspended|terminated|pending');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_lpa_type` SET TAGS ('dbx_business_glossary_term' = 'Target LPA Type (TAR_LPA_TYPE)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_lpa_type` SET TAGS ('dbx_value_regex' = 'standard|side_letter|co_investment');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_management_fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Target Management Fee Rate (TAR_MGMT_FEE_RATE)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_max_deal_size` SET TAGS ('dbx_business_glossary_term' = 'Target Maximum Deal Size (TAR_MAX_DEAL_SIZE)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_max_investment_period_years` SET TAGS ('dbx_business_glossary_term' = 'Target Maximum Investment Period (TAR_MAX_INV_PERIOD_YEARS)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_min_deal_size` SET TAGS ('dbx_business_glossary_term' = 'Target Minimum Deal Size (TAR_MIN_DEAL_SIZE)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_min_investment_period_years` SET TAGS ('dbx_business_glossary_term' = 'Target Minimum Investment Period (TAR_MIN_INV_PERIOD_YEARS)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_moic` SET TAGS ('dbx_business_glossary_term' = 'Target MOIC (TAR_MOIC)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_rvpi` SET TAGS ('dbx_business_glossary_term' = 'Target RVPI (TAR_RVPI)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_tvpi` SET TAGS ('dbx_business_glossary_term' = 'Target TVPI (TAR_TVPI)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `target_vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Target Vintage Year (TAR_VINTAGE_YEAR)');
ALTER TABLE `asset_management`.`manager`.`strategy` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp (UPDATED_TS)');
ALTER TABLE `asset_management`.`manager`.`manager_document` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`manager`.`manager_document` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`manager_document` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`manager_document` SET TAGS ('dbx_subdomain' = 'relationship_engagement');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `manager_document_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Document ID (MDID)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID (MID)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID (MID)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate ID (MID)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `access_control` SET TAGS ('dbx_business_glossary_term' = 'Document Access Control Level (DACL)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `access_control` SET TAGS ('dbx_value_regex' = 'public|restricted|confidential');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Document Approval Status (DAS)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'approved|pending|rejected');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Document Approved By (DAB)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Document Approved Date (DAD)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Document Created Timestamp (DCT)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `document_category` SET TAGS ('dbx_business_glossary_term' = 'Document Category (DCAT)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `document_description` SET TAGS ('dbx_business_glossary_term' = 'Document Description (DD)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'Document Status (DS)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `document_status` SET TAGS ('dbx_value_regex' = 'draft|final|archived|replaced');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `document_type` SET TAGS ('dbx_business_glossary_term' = 'Document Type (DT)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Document Effective Date (DED)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Document Expiry Date (DED)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `format` SET TAGS ('dbx_business_glossary_term' = 'Document Format (DF)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `format` SET TAGS ('dbx_value_regex' = 'PDF|DOCX|XLSX|TXT|HTML');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `hash_sha256` SET TAGS ('dbx_business_glossary_term' = 'Document SHA-256 Hash (DHS)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `language` SET TAGS ('dbx_business_glossary_term' = 'Document Language (DLANG)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Document Language Code (DLANGC)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `last_accessed` SET TAGS ('dbx_business_glossary_term' = 'Document Last Accessed Timestamp (DLAT)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `page_count` SET TAGS ('dbx_business_glossary_term' = 'Document Page Count (DPC)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `pii_content_flag` SET TAGS ('dbx_business_glossary_term' = 'Document PII Content Flag (DPCF)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `pii_flag` SET TAGS ('dbx_business_glossary_term' = 'Document PII Presence Flag (DPIF)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `reference_code` SET TAGS ('dbx_business_glossary_term' = 'Document Reference Code (DRC)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Document Reference Number (DRN)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `signed_by` SET TAGS ('dbx_business_glossary_term' = 'Document Signed By (DSB)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `signed_by_role` SET TAGS ('dbx_business_glossary_term' = 'Document Signed By Role (DSBR)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `signed_date` SET TAGS ('dbx_business_glossary_term' = 'Document Signed Date (DSD)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `signed_status` SET TAGS ('dbx_business_glossary_term' = 'Document Signed Status (DSS)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `signed_status` SET TAGS ('dbx_value_regex' = 'signed|unsigned|pending');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `size_bytes` SET TAGS ('dbx_business_glossary_term' = 'Document Size in Bytes (DSB)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `storage_location` SET TAGS ('dbx_business_glossary_term' = 'Document Storage Location (DSL)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `summary` SET TAGS ('dbx_business_glossary_term' = 'Document Summary (DSUM)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Document Title (DTL)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Document Updated Timestamp (DUT)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `version_label` SET TAGS ('dbx_business_glossary_term' = 'Document Version Label (DVL)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Document Version Number (DVN)');
ALTER TABLE `asset_management`.`manager`.`manager_document` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Document Created By (DCB)');
ALTER TABLE `asset_management`.`manager`.`kyc` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`manager`.`kyc` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`kyc` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`kyc` SET TAGS ('dbx_subdomain' = 'risk_oversight');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `kyc_id` SET TAGS ('dbx_business_glossary_term' = 'KYC ID (KYC_ID)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID (MANAGER_ID)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID (MANAGER_ID)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `sanctions_screening_id` SET TAGS ('dbx_business_glossary_term' = 'Sanctions Screening Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `aml_screening_result` SET TAGS ('dbx_business_glossary_term' = 'KYC AML Screening Result (KYC_AML_SCREENING_RESULT)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `beneficial_ownership_verification` SET TAGS ('dbx_business_glossary_term' = 'KYC Beneficial Ownership Verification (KYC_BENEFICIAL_OWNERSHIP_VERIFICATION)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'KYC Completion Date (KYC_COMPLETION_DATE)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'KYC Compliance Flag (KYC_COMPLIANCE_FLAG)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'KYC Created Timestamp (KYC_CREATED_TIMESTAMP)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `document_category` SET TAGS ('dbx_business_glossary_term' = 'KYC Document Category (KYC_DOCUMENT_CATEGORY)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `document_category` SET TAGS ('dbx_value_regex' = 'Legal|Financial|Regulatory');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `document_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'KYC Document Expiry Date (KYC_DOCUMENT_EXPIRY_DATE)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `document_hash` SET TAGS ('dbx_business_glossary_term' = 'KYC Document Hash (KYC_DOCUMENT_HASH)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `document_language` SET TAGS ('dbx_business_glossary_term' = 'KYC Document Language (KYC_DOCUMENT_LANGUAGE)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `document_reference` SET TAGS ('dbx_business_glossary_term' = 'KYC Document Reference (KYC_DOCUMENT_REFERENCE)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `document_size_bytes` SET TAGS ('dbx_business_glossary_term' = 'KYC Document Size (KYC_DOCUMENT_SIZE_BYTES)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'KYC Document Status (KYC_DOCUMENT_STATUS)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `document_status` SET TAGS ('dbx_value_regex' = 'uploaded|verified|rejected|expired');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `document_storage_location` SET TAGS ('dbx_business_glossary_term' = 'KYC Document Storage Location (KYC_DOCUMENT_STORAGE_LOCATION)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `document_type` SET TAGS ('dbx_business_glossary_term' = 'KYC Document Type (KYC_DOCUMENT_TYPE)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `document_type` SET TAGS ('dbx_value_regex' = 'KYC_Paper|AML_Paper|Compliance_Paper');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `document_upload_date` SET TAGS ('dbx_business_glossary_term' = 'KYC Document Upload Date (KYC_DOCUMENT_UPLOAD_DATE)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `document_version` SET TAGS ('dbx_business_glossary_term' = 'KYC Document Version (KYC_DOCUMENT_VERSION)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `kyc_status` SET TAGS ('dbx_business_glossary_term' = 'KYC Status (KYC_STATUS)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `kyc_status` SET TAGS ('dbx_value_regex' = 'pending|completed|failed|revoked');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `pep_status` SET TAGS ('dbx_business_glossary_term' = 'KYC PEP Status (KYC_PEP_STATUS)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `pep_status` SET TAGS ('dbx_value_regex' = 'none|yes|unknown');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `provider` SET TAGS ('dbx_business_glossary_term' = 'KYC Provider (KYC_PROVIDER)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `provider_document_category` SET TAGS ('dbx_business_glossary_term' = 'KYC Provider Document Category (KYC_PROVIDER_DOCUMENT_CATEGORY)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `provider_document_category` SET TAGS ('dbx_value_regex' = 'Legal|Financial|Regulatory');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `provider_document_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'KYC Provider Document Expiry Date (KYC_PROVIDER_DOCUMENT_EXPIRY_DATE)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `provider_document_hash` SET TAGS ('dbx_business_glossary_term' = 'KYC Provider Document Hash (KYC_PROVIDER_DOCUMENT_HASH)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `provider_document_language` SET TAGS ('dbx_business_glossary_term' = 'KYC Provider Document Language (KYC_PROVIDER_DOCUMENT_LANGUAGE)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `provider_document_reference` SET TAGS ('dbx_business_glossary_term' = 'KYC Provider Document Reference (KYC_PROVIDER_DOCUMENT_REFERENCE)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `provider_document_size_bytes` SET TAGS ('dbx_business_glossary_term' = 'KYC Provider Document Size (KYC_PROVIDER_DOCUMENT_SIZE_BYTES)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `provider_document_status` SET TAGS ('dbx_business_glossary_term' = 'KYC Provider Document Status (KYC_PROVIDER_DOCUMENT_STATUS)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `provider_document_status` SET TAGS ('dbx_value_regex' = 'uploaded|verified|rejected|expired');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `provider_document_storage_location` SET TAGS ('dbx_business_glossary_term' = 'KYC Provider Document Storage Location (KYC_PROVIDER_DOCUMENT_STORAGE_LOCATION)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `provider_document_type` SET TAGS ('dbx_business_glossary_term' = 'KYC Provider Document Type (KYC_PROVIDER_DOCUMENT_TYPE)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `provider_document_type` SET TAGS ('dbx_value_regex' = 'KYC_Paper|AML_Paper|Compliance_Paper');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `provider_document_upload_date` SET TAGS ('dbx_business_glossary_term' = 'KYC Provider Document Upload Date (KYC_PROVIDER_DOCUMENT_UPLOAD_DATE)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `provider_document_version` SET TAGS ('dbx_business_glossary_term' = 'KYC Provider Document Version (KYC_PROVIDER_DOCUMENT_VERSION)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `provider_version` SET TAGS ('dbx_business_glossary_term' = 'KYC Provider Version (KYC_PROVIDER_VERSION)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `reference` SET TAGS ('dbx_business_glossary_term' = 'KYC Reference (KYC_REFERENCE)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `reference_code` SET TAGS ('dbx_business_glossary_term' = 'KYC Reference Code (KYC_REFERENCE_CODE)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `reference_name` SET TAGS ('dbx_business_glossary_term' = 'KYC Reference Name (KYC_REFERENCE_NAME)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `regulatory_compliance_status` SET TAGS ('dbx_business_glossary_term' = 'KYC Regulatory Compliance Status (KYC_REGULATORY_COMPLIANCE_STATUS)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'KYC Review Date (KYC_REVIEW_DATE)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'KYC Review Frequency (KYC_REVIEW_FREQUENCY)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|annually');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'KYC Risk Rating (KYC_RISK_RATING)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `source_of_funds_confirmation` SET TAGS ('dbx_business_glossary_term' = 'KYC Source of Funds Confirmation (KYC_SOURCE_OF_FUNDS_CONFIRMATION)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'KYC Updated Timestamp (KYC_UPDATED_TIMESTAMP)');
ALTER TABLE `asset_management`.`manager`.`kyc` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'KYC Version (KYC_VERSION)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`manager`.`esg_profile` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`esg_profile` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`esg_profile` SET TAGS ('dbx_subdomain' = 'manager_selection');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_profile_id` SET TAGS ('dbx_business_glossary_term' = 'ESG Profile ID (ESG_PROFILE_ID)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_policy_document_id` SET TAGS ('dbx_business_glossary_term' = 'ESG Policy Document ID (ESG_POLICY_DOCUMENT_ID)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `framework_id` SET TAGS ('dbx_business_glossary_term' = 'Framework Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_framework` SET TAGS ('dbx_business_glossary_term' = 'ESG Framework (ESG_FRAMEWORK)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_framework` SET TAGS ('dbx_value_regex' = 'PRI|SFDR|TCFD|ESG');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_policy_document_created_by` SET TAGS ('dbx_business_glossary_term' = 'ESG Policy Document Created By (ESG_POLICY_DOCUMENT_CREATED_BY)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_policy_document_created_date` SET TAGS ('dbx_business_glossary_term' = 'ESG Policy Document Created Date (ESG_POLICY_DOCUMENT_CREATED_DATE)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_policy_document_language` SET TAGS ('dbx_business_glossary_term' = 'ESG Policy Document Language (ESG_POLICY_DOCUMENT_LANGUAGE)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_policy_document_language` SET TAGS ('dbx_value_regex' = 'EN|FR|DE|ES');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_policy_document_last_updated_by` SET TAGS ('dbx_business_glossary_term' = 'ESG Policy Document Last Updated By (ESG_POLICY_DOCUMENT_LAST_UPDATED_BY)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_policy_document_last_updated_date` SET TAGS ('dbx_business_glossary_term' = 'ESG Policy Document Last Updated Date (ESG_POLICY_DOCUMENT_LAST_UPDATED_DATE)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_policy_document_notes` SET TAGS ('dbx_business_glossary_term' = 'ESG Policy Document Notes (ESG_POLICY_DOCUMENT_NOTES)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_policy_document_source` SET TAGS ('dbx_business_glossary_term' = 'ESG Policy Document Source (ESG_POLICY_DOCUMENT_SOURCE)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_policy_document_source` SET TAGS ('dbx_value_regex' = 'internal|external');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_policy_document_status` SET TAGS ('dbx_business_glossary_term' = 'ESG Policy Document Status (ESG_POLICY_DOCUMENT_STATUS)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_policy_document_status` SET TAGS ('dbx_value_regex' = 'draft|published|archived');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_policy_document_type` SET TAGS ('dbx_business_glossary_term' = 'ESG Policy Document Type (ESG_POLICY_DOCUMENT_TYPE)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_policy_document_type` SET TAGS ('dbx_value_regex' = 'policy|report|guideline');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_policy_document_url` SET TAGS ('dbx_business_glossary_term' = 'ESG Policy Document URL (ESG_POLICY_DOCUMENT_URL)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_policy_document_version` SET TAGS ('dbx_business_glossary_term' = 'ESG Policy Document Version (ESG_POLICY_DOCUMENT_VERSION)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_profile_status` SET TAGS ('dbx_business_glossary_term' = 'Profile Status (STATUS)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_profile_status` SET TAGS ('dbx_value_regex' = 'active|inactive|retired');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_score` SET TAGS ('dbx_business_glossary_term' = 'ESG Score (ESG_SCORE)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_score_calculation_frequency` SET TAGS ('dbx_business_glossary_term' = 'ESG Score Calculation Frequency (ESG_SCORE_CALCULATION_FREQUENCY)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_score_calculation_method` SET TAGS ('dbx_business_glossary_term' = 'ESG Score Calculation Method (ESG_SCORE_CALCULATION_METHOD)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_score_calculation_notes` SET TAGS ('dbx_business_glossary_term' = 'ESG Score Calculation Notes (ESG_SCORE_CALCULATION_NOTES)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_score_date` SET TAGS ('dbx_business_glossary_term' = 'ESG Score Date (ESG_SCORE_DATE)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `esg_score_source` SET TAGS ('dbx_business_glossary_term' = 'ESG Score Source (ESG_SCORE_SOURCE)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `profile_code` SET TAGS ('dbx_business_glossary_term' = 'Profile Code (PROFILE_CODE)');
ALTER TABLE `asset_management`.`manager`.`esg_profile` ALTER COLUMN `profile_name` SET TAGS ('dbx_business_glossary_term' = 'Profile Name (PROFILE_NAME)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` SET TAGS ('dbx_subdomain' = 'relationship_engagement');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `manager_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Benchmark ID (MB_ID)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID (MAN_ID)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `macro_indicator_id` SET TAGS ('dbx_business_glossary_term' = 'Macro Indicator Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID (MAN_ID)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `performance_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Performance Benchmark Id (Foreign Key)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `approval_by` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Approved By (BENCH_APP_BY)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Approval Date (BENCH_APP_DATE)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `approval_notes` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Approval Notes (BENCH_APP_NOTES)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Approval Status (BENCH_APP_STATUS)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'approved|pending|rejected|under_review');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `benchmark_description` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Description (BENCH_DESC)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `benchmark_name` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Name (BENCH_NAME)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `benchmark_status` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Status (BENCH_STATUS)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `benchmark_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|archived|deleted');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `benchmark_type` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Type (BENCH_TYPE)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `benchmark_type` SET TAGS ('dbx_value_regex' = 'equity|fixed_income|private_equity|real_estate|infrastructure|credit');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Calculation Methodology (BENCH_CALC_METHOD)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `calculation_methodology` SET TAGS ('dbx_value_regex' = 'DCF|NAV|IRR|MOIC|TVPI|DPI');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Created At (BENCH_CRE_AT)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Currency (BENCH_CURR)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = 'USD|EUR|GBP|JPY|CHF');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Effective Until Date (BENCH_END_DATE)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `frequency` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Frequency (BENCH_FREQ)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annual');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `index_code` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index Code (BENCH_IDX_CODE)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `is_confidential` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Is Confidential (BENCH_IS_CONF)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `is_custom` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Is Custom (BENCH_IS_CUSTOM)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `is_default` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Is Default (BENCH_IS_DEFAULT)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `is_public` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Is Public (BENCH_IS_PUBLIC)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `is_restricted` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Is Restricted (BENCH_IS_RESTRICTED)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `is_sensitive` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Is Sensitive (BENCH_IS_SENSITIVE)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate ID (MD_ID)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `provider` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Provider (BENCH_PROV)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `provider` SET TAGS ('dbx_value_regex' = 'MSCI|S&P|FTSE|Bloomberg|Reuters');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `source_document` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Source Document (BENCH_SRC_DOC)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `source_document_checksum` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Source Document Checksum (BENCH_SRC_DOC_CHKSUM)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `source_document_date` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Source Document Date (BENCH_SRC_DOC_DATE)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `source_document_format` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Source Document Format (BENCH_SRC_DOC_FMT)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `source_document_language` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Source Document Language (BENCH_SRC_DOC_LANG)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `source_document_language_code` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Source Document Language Code (BENCH_SRC_DOC_LANG_CODE)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `source_document_language_description` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Source Document Language Description (BENCH_SRC_DOC_LANG_DESC)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `source_document_language_notes` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Source Document Language Notes (BENCH_SRC_DOC_LANG_NOTES)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `source_document_size` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Source Document Size (BENCH_SRC_DOC_SIZE)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `source_document_type` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Source Document Type (BENCH_SRC_DOC_TYPE)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `source_document_version` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Source Document Version (BENCH_SRC_DOC_VER)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `source_url` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Source URL (BENCH_SRC_URL)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Effective From Date (BENCH_START_DATE)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `unit` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Unit (BENCH_UNIT)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `unit` SET TAGS ('dbx_value_regex' = 'return|price|index_value|percentage');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Updated At (BENCH_UPD_AT)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Version (BENCH_VER)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `version_date` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Version Date (BENCH_VER_DATE)');
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Created By (BENCH_CRE_BY)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` SET TAGS ('dbx_subdomain' = 'relationship_engagement');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `reporting_obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Reporting Obligation ID (RO_ID)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID (MGR_ID)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID (MGR_ID)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate ID (MDT_ID)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Reporting Obligation Compliance Flag (RO_COMP_FLAG)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `compliance_notes` SET TAGS ('dbx_business_glossary_term' = 'Reporting Obligation Compliance Notes (RO_COMP_NOTES)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp (REC_CREATED_TS)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `data_delivery_channel` SET TAGS ('dbx_business_glossary_term' = 'Data Delivery Channel (DATA_DEL_CHANNEL)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `data_delivery_channel` SET TAGS ('dbx_value_regex' = 'Email|Secure FTP|Portal');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `data_delivery_deadline_days` SET TAGS ('dbx_business_glossary_term' = 'Data Delivery Deadline Days (DATA_DEL_DAYS)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `data_delivery_format` SET TAGS ('dbx_business_glossary_term' = 'Data Delivery Format (DATA_DEL_FORMAT)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `data_delivery_format` SET TAGS ('dbx_value_regex' = 'PDF|Excel|JSON|EDI');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `delivery_channel` SET TAGS ('dbx_business_glossary_term' = 'Reporting Obligation Delivery Channel (RO_DEL_CHANNEL)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `delivery_channel` SET TAGS ('dbx_value_regex' = 'Email|Secure FTP|Portal');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `delivery_format` SET TAGS ('dbx_business_glossary_term' = 'Reporting Obligation Delivery Format (RO_DEL_FORMAT)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `delivery_format` SET TAGS ('dbx_value_regex' = 'PDF|Excel|JSON|EDI');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Obligation Due Date (RO_DUE_DATE)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Reporting Obligation Effective From Date (RO_EFF_FROM)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Reporting Obligation Effective Until Date (RO_EFF_UNTIL)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Obligation Frequency (RO_FREQ)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `frequency` SET TAGS ('dbx_value_regex' = 'Monthly|Quarterly|Annual|Ad-hoc');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `last_sent_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Obligation Last Sent Date (RO_LAST_SENT)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `next_due_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Obligation Next Due Date (RO_NEXT_DUE)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `obligation_type` SET TAGS ('dbx_business_glossary_term' = 'Reporting Obligation Type (RO_TYPE)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `obligation_type` SET TAGS ('dbx_value_regex' = 'Capital Account Statement|Audited Financials|Quarterly Investor Letter|ESG Report|ILPA Data Template');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `penalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Penalty Amount (PEN_AMT)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `penalty_clause_applicable` SET TAGS ('dbx_business_glossary_term' = 'Penalty Clause Applicable (PEN_CL_APP)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `penalty_currency` SET TAGS ('dbx_business_glossary_term' = 'Penalty Currency (PEN_CURR)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `penalty_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `reference_code` SET TAGS ('dbx_business_glossary_term' = 'Reference Code (REF_CODE)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `reference_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,20}$');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `reference_name` SET TAGS ('dbx_business_glossary_term' = 'Reference Name (REF_NAME)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `reference_name` SET TAGS ('dbx_value_regex' = '^[A-Za-z0-9 ]{1,100}$');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `report_description` SET TAGS ('dbx_business_glossary_term' = 'Report Description (REPORT_DESC)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `report_notes` SET TAGS ('dbx_business_glossary_term' = 'Report Notes (REPORT_NOTES)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `reporting_obligation_status` SET TAGS ('dbx_business_glossary_term' = 'Reporting Obligation Status (RO_STATUS)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `reporting_obligation_status` SET TAGS ('dbx_value_regex' = 'Active|Completed|Cancelled|Pending');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `sla_effective_from` SET TAGS ('dbx_business_glossary_term' = 'SLA Effective From Date (SLA_EFF_FROM)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `sla_effective_until` SET TAGS ('dbx_business_glossary_term' = 'SLA Effective Until Date (SLA_EFF_UNTIL)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `sla_reference_number` SET TAGS ('dbx_business_glossary_term' = 'SLA Reference Number (SLA_REF_NUM)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `sla_status` SET TAGS ('dbx_business_glossary_term' = 'SLA Status (SLA_STATUS)');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `sla_status` SET TAGS ('dbx_value_regex' = 'Active|Completed|Cancelled|Pending');
ALTER TABLE `asset_management`.`manager`.`reporting_obligation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp (REC_UPDATED_TS)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`manager`.`report_receipt` SET TAGS ('dbx_domain' = 'manager');
ALTER TABLE `asset_management`.`manager`.`report_receipt` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`manager`.`report_receipt` SET TAGS ('dbx_subdomain' = 'relationship_engagement');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `report_receipt_id` SET TAGS ('dbx_business_glossary_term' = 'Report Receipt ID (REPORT_RECEIPT_ID)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID (MANAGER_ID)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID (MANAGER_ID)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `completeness_check_result` SET TAGS ('dbx_business_glossary_term' = 'Completeness Check Result (COMPLETENESS_CHECK_RESULT)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `completeness_check_result` SET TAGS ('dbx_value_regex' = 'Pass|Fail|Partial');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp (CREATED_TIMESTAMP)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `data_quality_flags` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Flags (DATA_QUALITY_FLAGS)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `delivery_channel` SET TAGS ('dbx_business_glossary_term' = 'Delivery Channel (DELIVERY_CHANNEL)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `delivery_channel` SET TAGS ('dbx_value_regex' = 'Email|FTP|API|Manual');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `processing_error_code` SET TAGS ('dbx_business_glossary_term' = 'Processing Error Code (PROCESSING_ERROR_CODE)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `processing_error_details` SET TAGS ('dbx_business_glossary_term' = 'Processing Error Details (PROCESSING_ERROR_DETAILS)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `processing_error_flag` SET TAGS ('dbx_business_glossary_term' = 'Processing Error Flag (PROCESSING_ERROR_FLAG)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `processing_error_message` SET TAGS ('dbx_business_glossary_term' = 'Processing Error Message (PROCESSING_ERROR_MESSAGE)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `processing_status` SET TAGS ('dbx_business_glossary_term' = 'Processing Status (PROCESSING_STATUS)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `processing_status` SET TAGS ('dbx_value_regex' = 'Received|Processing|Completed|Failed|Cancelled');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `processing_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Processing Timestamp (PROCESSING_TIMESTAMP)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `receipt_date` SET TAGS ('dbx_business_glossary_term' = 'Receipt Date (RECEIPT_DATE)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `report_checksum` SET TAGS ('dbx_business_glossary_term' = 'Report Checksum (REPORT_CHECKSUM)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `report_file_name` SET TAGS ('dbx_business_glossary_term' = 'Report File Name (REPORT_FILE_NAME)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `report_file_size_bytes` SET TAGS ('dbx_business_glossary_term' = 'Report File Size (REPORT_FILE_SIZE_BYTES)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `report_language_code` SET TAGS ('dbx_business_glossary_term' = 'Report Language Code (REPORT_LANGUAGE_CODE)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `report_language_code` SET TAGS ('dbx_value_regex' = 'en|fr|de|es|zh');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `report_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Report Reference Code (REPORT_REFERENCE_CODE)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `report_source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Report Source System ID (REPORT_SOURCE_SYSTEM_ID)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `report_source_system_name` SET TAGS ('dbx_business_glossary_term' = 'Report Source System Name (REPORT_SOURCE_SYSTEM_NAME)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `report_source_system_type` SET TAGS ('dbx_business_glossary_term' = 'Report Source System Type (REPORT_SOURCE_SYSTEM_TYPE)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `report_source_system_type` SET TAGS ('dbx_value_regex' = 'SimCorp|BlackRock|Bloomberg|StateStreet|eFront|DealCloud');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `report_source_system_version` SET TAGS ('dbx_business_glossary_term' = 'Report Source System Version (REPORT_SOURCE_SYSTEM_VERSION)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `report_type` SET TAGS ('dbx_business_glossary_term' = 'Report Type (REPORT_TYPE)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `report_type` SET TAGS ('dbx_value_regex' = 'NAV|Performance|ESG|Compliance|Other');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `report_version` SET TAGS ('dbx_business_glossary_term' = 'Report Version (REPORT_VERSION)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date (REPORTING_PERIOD_END_DATE)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date (REPORTING_PERIOD_START_DATE)');
ALTER TABLE `asset_management`.`manager`.`report_receipt` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp (UPDATED_TIMESTAMP)');
