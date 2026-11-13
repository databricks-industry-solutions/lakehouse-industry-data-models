-- Schema for Domain: esg | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:26

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`esg` COMMENT 'Domain for ESG integration, responsible investment stewardship, and sustainability reporting across the investment lifecycle. Owns ESG ratings (MSCI ESG), PRI reporting data, SFDR classifications, TCFD climate risk disclosures, GHG emissions tracking';
ALTER SCHEMA `asset_management`.`esg` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `asset_management`.`esg` SET TAGS ('dbx_domain' = 'esg');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`esg`.`issuer_esg_rating` (
    `issuer_esg_rating_id` BIGINT COMMENT 'Unique surrogate identifier for each ESG rating record assigned to an investable issuer. Primary key for the issuer_esg_rating product in the ESG domain.',
    `equity_issuer_id` BIGINT COMMENT 'Reference to the investable issuer (corporate, sovereign, or real asset entity) to which this ESG rating applies. Links to the master issuer record.',
    `asset_class` STRING COMMENT 'Primary asset class of the issuers securities held or evaluated by the pension fund. Determines ESG integration approach and applicable SFDR product-level disclosures. [ENUM-REF-CANDIDATE: promote to reference product]',
    `carbon_intensity` DECIMAL(12,4) COMMENT 'Issuers GHG emissions intensity measured in tonnes of CO2 equivalent per USD million of revenue. Key TCFD and SFDR climate metric used in portfolio carbon footprint reporting and net-zero alignment analysis.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this ESG rating record was first ingested into the Databricks Silver Layer from the source system (MSCI ESG Ratings feed or internal assessment). Supports data lineage and audit trail.',
    `domicile_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the issuers country of domicile/incorporation. Used for sovereign ESG overlay, country-level exclusion screening, and SFDR geographic disclosures.. Valid values are `^[A-Z]{3}$`',
    `emissions_data_source` STRING COMMENT 'Indicates whether the issuers GHG emissions data is directly reported by the issuer, estimated by the rating provider, or modeled. Affects data quality weighting in TCFD and SFDR disclosures.. Valid values are `Reported|Estimated|Modeled|Partial`',
    `engagement_priority_flag` BOOLEAN COMMENT 'Indicates whether the issuer has been designated as a priority for active ESG engagement by the responsible investment stewardship team, based on ESG rating, controversy level, or portfolio weight.',
    `environmental_score` DECIMAL(5,2) COMMENT 'Numeric score for the Environmental pillar of the ESG rating, covering climate change, natural resources, pollution, and environmental opportunities. Sourced from MSCI ESG Ratings.',
    `esg_controversy_level` STRING COMMENT 'Categorical severity level of ESG controversies for the issuer per MSCI methodology (0–10 scale mapped to levels). Used in exclusion screening and engagement prioritization workflows.. Valid values are `None|Low|Moderate|Significant|High|Very High`',
    `esg_controversy_score` DECIMAL(5,2) COMMENT 'Numeric score reflecting the severity of ESG-related controversies involving the issuer, sourced from MSCI ESG Controversy Scores. High controversy scores may trigger exclusion list review.',
    `esg_data_coverage_pct` DECIMAL(5,2) COMMENT 'Percentage of ESG key issues for which underlying data is available for this issuer, as reported by the rating provider. Indicates data completeness and reliability of the ESG rating.',
    `esg_rating_category` STRING COMMENT 'Broad categorical classification of the issuers ESG performance: Leader (AAA–AA), Average (A–BBB–BB), or Laggard (B–CCC). Used for portfolio-level ESG reporting and SAA constraints.. Valid values are `Leader|Average|Laggard`',
    `esg_rating_grade` STRING COMMENT 'Letter-grade ESG rating assigned by the provider (e.g., MSCI scale: AAA to CCC). Represents the issuers ESG risk category used in investment screening, exclusion lists, and SFDR classification.',
    `esg_rating_methodology_version` STRING COMMENT 'Version identifier of the ESG rating methodology applied by the provider (e.g., MSCI ESG Ratings v3.1). Required for audit trail and to identify ratings produced under different methodology vintages.',
    `esg_rating_score` DECIMAL(5,2) COMMENT 'Numeric ESG score assigned by the rating provider, typically on a 0–10 scale for MSCI. Represents the issuers overall ESG risk management performance used in portfolio construction and IC reporting.',
    `exclusion_reason` STRING COMMENT 'Narrative description of the reason for the issuers inclusion on the exclusion list (e.g., controversial weapons, severe ESG controversy, UNGC non-compliance). Populated only when on_exclusion_list is True.',
    `gics_industry_code` STRING COMMENT 'Eight-digit GICS industry code providing granular industry classification for the issuer. Enables industry-adjusted ESG key issue weighting in MSCI ESG Ratings methodology.. Valid values are `^[0-9]{8}$`',
    `gics_sector_code` STRING COMMENT 'Two-digit GICS sector code classifying the issuers primary industry. Used for sector-level ESG benchmarking, peer comparison, and industry-adjusted ESG scoring in MSCI RiskMetrics.. Valid values are `^[0-9]{2}$`',
    `governance_score` DECIMAL(5,2) COMMENT 'Numeric score for the Governance pillar of the ESG rating, covering corporate governance, corporate behavior, and board structure. Sourced from MSCI ESG Ratings.',
    `industry_adjusted_score` DECIMAL(5,2) COMMENT 'ESG score normalized relative to the issuers GICS industry peer group, enabling cross-sector comparison. Used in BlackRock Aladdin ESG analytics for relative ESG positioning within sector allocations.',
    `internal_esg_override_flag` BOOLEAN COMMENT 'Indicates whether the pension funds internal ESG team has applied an override to the external providers rating based on proprietary due diligence or investment committee decision.',
    `internal_esg_override_grade` STRING COMMENT 'The internally assigned ESG rating grade when the internal team overrides the external providers rating. Null if no override is applied. Used in IC reporting and investment decision documentation.',
    `internal_override_rationale` STRING COMMENT 'Narrative justification provided by the internal ESG team for overriding the external providers rating. Required for audit trail and IC governance documentation when override flag is True.',
    `isin` STRING COMMENT '12-character ISIN code identifying the primary security of the issuer, used to link ESG ratings to portfolio holdings in SimCorp Dimension and BlackRock Aladdin.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `issuer_name` STRING COMMENT 'Full legal name of the issuer entity (corporate, sovereign, or real asset) as recognized by the ESG rating provider. Used for display and reconciliation purposes.',
    `issuer_type` STRING COMMENT 'Classification of the issuer entity type for ESG rating methodology selection. Determines which MSCI ESG rating framework applies (corporate, sovereign, or real asset methodology).. Valid values are `Corporate|Sovereign|Real Asset|Financial Institution|Supranational`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this ESG rating record in the Silver Layer. Used for incremental data pipeline processing, change detection, and audit trail compliance.',
    `lei_code` STRING COMMENT '20-character ISO 17442 Legal Entity Identifier uniquely identifying the issuer globally. Used for cross-system reconciliation and regulatory reporting under EMIR and MiFID II.. Valid values are `^[A-Z0-9]{18}[0-9]{2}$`',
    `net_zero_target_flag` BOOLEAN COMMENT 'Indicates whether the issuer has publicly committed to a net-zero GHG emissions target. Used in portfolio net-zero alignment analysis and TCFD transition risk assessment.',
    `net_zero_target_year` BIGINT COMMENT 'The year by which the issuer has committed to achieving net-zero GHG emissions. Null if no net-zero target has been set. Used in transition risk modeling and portfolio decarbonization pathway analysis.',
    `on_exclusion_list` BOOLEAN COMMENT 'Indicates whether the issuer is currently on the pension funds internal exclusion list, prohibiting new investment. Driven by ESG screening, UNGC non-compliance, or IC-approved exclusion decisions.',
    `prior_esg_rating_grade` STRING COMMENT 'The issuers ESG rating grade from the immediately preceding rating cycle. Used to identify rating upgrades or downgrades and assess ESG momentum for engagement prioritization.',
    `proxy_voting_policy_alignment` STRING COMMENT 'Assessment of the issuers governance practices alignment with the pension funds proxy voting policy. Used in stewardship reporting and annual proxy voting disclosure to beneficiaries.. Valid values are `Aligned|Partially Aligned|Not Aligned|Not Applicable`',
    `rating_change_direction` STRING COMMENT 'Direction of change from the prior ESG rating grade to the current grade. Upgrade or Downgrade triggers internal review and potential engagement action per the responsible investment stewardship policy.. Valid values are `Upgrade|Downgrade|No Change|Initiated`',
    `rating_date` DATE COMMENT 'The date on which the ESG rating was officially assigned or last updated by the rating provider. Used to determine rating currency and trigger review workflows in BlackRock Aladdin.',
    `rating_effective_date` DATE COMMENT 'Date from which this ESG rating version is considered effective for portfolio management and compliance purposes. Supports point-in-time ESG analysis and SFDR periodic reporting.',
    `rating_expiry_date` DATE COMMENT 'Date on which this ESG rating version expires or is superseded by a new rating. Null if the rating remains current. Used to manage rating staleness and trigger re-assessment workflows.',
    `rating_provider` STRING COMMENT 'Organization that produced the ESG rating. Primary source is MSCI ESG Ratings via MSCI RiskMetrics and Barra; supplemented by internal assessments. [ENUM-REF-CANDIDATE: MSCI|Sustainalytics|ISS ESG|Bloomberg ESG|Internal|Refinitiv|S&P Global ESG — promote. Valid values are `MSCI|Sustainalytics|ISS ESG|Bloomberg ESG|Internal|Refinitiv`',
    `rating_status` STRING COMMENT 'Current lifecycle status of this ESG rating record. Active ratings are used in portfolio analytics; Superseded records are retained for historical point-in-time analysis and GIPS compliance.. Valid values are `Active|Superseded|Under Review|Withdrawn|Pending`',
    `scope1_emissions` DECIMAL(15,2) COMMENT 'Issuers direct Scope 1 GHG emissions in tonnes of CO2 equivalent, as reported or estimated. Required for TCFD climate risk disclosure and SFDR Principal Adverse Impact (PAI) indicator reporting.',
    `scope2_emissions` DECIMAL(15,2) COMMENT 'Issuers indirect Scope 2 GHG emissions from purchased energy in tonnes of CO2 equivalent. Required for TCFD climate risk disclosure and SFDR PAI indicator reporting.',
    `scope3_emissions` DECIMAL(15,2) COMMENT 'Issuers value chain Scope 3 GHG emissions in tonnes of CO2 equivalent. Used in portfolio-level financed emissions calculations and net-zero pathway alignment assessments per TCFD.',
    `sfdr_pai_flag` BOOLEAN COMMENT 'Indicates whether this issuer contributes to one or more SFDR Principal Adverse Impact indicators at the portfolio level. True triggers inclusion in mandatory PAI statement disclosures.',
    `social_score` DECIMAL(5,2) COMMENT 'Numeric score for the Social pillar of the ESG rating, covering human capital, product liability, stakeholder opposition, and social opportunities. Sourced from MSCI ESG Ratings.',
    `source_system_rating_code` STRING COMMENT 'Native identifier of this ESG rating record in the originating source system (e.g., MSCI ESG Ratings platform or BlackRock Aladdin ESG module). Used for upstream reconciliation and data lineage tracing.',
    `tcfd_alignment_status` STRING COMMENT 'Assessment of the issuers climate-related financial disclosures against TCFD recommendations. Used in portfolio-level TCFD reporting and climate risk integration into investment decisions.. Valid values are `Aligned|Partial|Not Aligned|Not Assessed`',
    `ungc_compliance_status` STRING COMMENT 'Issuers compliance status with the UN Global Compact principles covering human rights, labor, environment, and anti-corruption. Non-compliant issuers are candidates for exclusion list review per PRI commitments.. Valid values are `Compliant|Non-Compliant|Watch List|Not Assessed`',
    `weapons_involvement_flag` BOOLEAN COMMENT 'Indicates whether the issuer is involved in the manufacture or sale of controversial weapons (cluster munitions, anti-personnel mines, biological/chemical weapons). Triggers mandatory exclusion screening.',
    CONSTRAINT pk_issuer_esg_rating PRIMARY KEY(`issuer_esg_rating_id`)
) COMMENT 'Master record of ESG ratings assigned to investable issuers (corporates, sovereigns, real assets) sourced primarily from MSCI ESG Ratings and supplemented by internal assessments.';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`framework` (
    `framework_id` BIGINT COMMENT 'Unique surrogate identifier for each ESG framework, standard, or regulatory regime record in the reference catalogue. Primary key. Role: REFERENCE_LOOKUP — exempt from per-role minimums; serves as a controlled vocabulary for ESG framework adoption.',
    `abbreviation` STRING COMMENT 'Widely recognised acronym or abbreviation for the framework (e.g., PRI, SFDR, TCFD, GRI). Distinct from code where the code may include versioning or internal suffixes.. Valid values are `^[A-Z0-9/-]{2,20}$`',
    `adoption_date` DATE COMMENT 'Date on which the funds Investment Committee or Board formally approved adoption of this ESG framework into the funds responsible investment programme and policies.',
    `adoption_status` STRING COMMENT 'Current lifecycle status of the framework within the funds ESG programme: adopted (in active use), under_review (being assessed), pending_adoption, superseded (replaced by newer version), withdrawn, or not_applicable.. Valid values are `adopted|under_review|pending_adoption|superseded|withdrawn|not_applicable`',
    `applicable_jurisdiction` STRING COMMENT 'Geographic or regulatory jurisdiction(s) where the framework applies or is mandated (e.g., EU, GBR, CAN, Global). Pipe-delimited ISO 3166-1 alpha-3 codes or Global for universal frameworks.',
    `assessment_score` DECIMAL(18,2) COMMENT 'Quantitative compliance assessment score for this framework-obligation combination, typically 0-100',
    `asset_class_scope` STRING COMMENT 'Asset classes to which this framework applies within the funds portfolio (e.g., public_equities, private_equity, real_estate, infrastructure, all). Pipe-delimited list.',
    `assurance_provider` STRING COMMENT 'Name of the external assurance or audit firm engaged to verify the funds compliance disclosures under this framework (e.g., PwC, Deloitte, EY). Null if external assurance is not required or not yet engaged.',
    `benchmark_alignment` STRING COMMENT 'Name of any ESG benchmark, index, or reference portfolio aligned to this framework (e.g., Paris-Aligned Benchmark, EU Climate Transition Benchmark, MSCI ESG Leaders Index). Null if no benchmark alignment.',
    `climate_related` BOOLEAN COMMENT 'Indicates whether this framework specifically addresses climate-related financial risks and disclosures (True), such as TCFD, TNFD, SFDR PAI climate indicators, or GHG reporting standards.',
    `framework_code` STRING COMMENT 'Short, unique alphanumeric code identifying the ESG framework (e.g., PRI, SFDR, TCFD, UNGC, SASB, GRI, TNFD). Used as the business key across systems and reporting outputs.. Valid values are `^[A-Z0-9_]{2,30}$`',
    `compliance_category` STRING COMMENT 'Categorises the basis of the funds obligation to the framework: regulatory (legally mandated), voluntary (self-elected commitment), best_practice (industry norm), or contractual (required by LPA or mandate terms).. Valid values are `regulatory|voluntary|best_practice|contractual`',
    `compliance_score` DECIMAL(5,2) COMMENT 'Numeric score (0.00–100.00) representing the funds assessed level of compliance or alignment with this framework at the last assessment date. Sourced from internal ESG assessments or PRI assessment results.',
    `compliance_status` STRING COMMENT 'Current compliance status for this specific framework-obligation pairing',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this ESG framework record was first created in the data catalogue. Supports data lineage, audit trail, and Silver layer provenance tracking per lakehouse governance standards.',
    `data_source_system` STRING COMMENT 'Operational system of record that is the primary source of ESG data for this frameworks reporting (e.g., BlackRock Aladdin, MSCI RiskMetrics, eFront, SimCorp Dimension). Supports data lineage.',
    `effective_date` DATE COMMENT 'Date from which this version of the framework became effective and applicable to the funds investment and reporting activities. Used for compliance timeline tracking.',
    `engagement_applicable` BOOLEAN COMMENT 'Indicates whether this framework requires or recommends active engagement with investee companies or external fund managers on ESG matters (True). Supports engagement activity logging and stewardship reporting.',
    `esg_pillar` STRING COMMENT 'Primary Environmental, Social, and Governance (ESG) pillar addressed by the framework. cross_pillar indicates the framework spans all three dimensions (e.g., PRI, GRI).. Valid values are `environmental|social|governance|cross_pillar`',
    `exclusion_list_applicable` BOOLEAN COMMENT 'Indicates whether this framework mandates or recommends maintaining an investment exclusion list (e.g., controversial weapons under UNGC, fossil fuel exclusions under certain SFDR Article 9 mandates).',
    `expiry_date` DATE COMMENT 'Date on which this version of the framework ceases to be applicable, superseded by a newer version or withdrawn. Null if the framework version remains open-ended and currently in force.',
    `external_assurance_required` BOOLEAN COMMENT 'Indicates whether the framework requires or recommends third-party external assurance or audit of the funds disclosures (True). Relevant for GRI, SFDR RTS, and TCFD-aligned reporting.',
    `external_reference_url` STRING COMMENT 'Official URL to the governing bodys published framework documentation, standard text, or regulatory guidance. Enables direct access to source material for compliance and due diligence teams.. Valid values are `^https?://[^s]{5,255}$`',
    `framework_type` STRING COMMENT 'Categorical classification of the ESG framework by its nature: regulatory regime (SFDR, EMIR), voluntary principle (PRI, UNGC), disclosure framework (TCFD, TNFD), reporting standard (GRI, SASB), or rating methodology (MSCI ESG).. Valid values are `reporting_standard|regulatory_regime|voluntary_principle|disclosure_framework|rating_methodology|stewardship_code`',
    `full_name` STRING COMMENT 'Complete official name of the ESG framework or standard (e.g., Principles for Responsible Investment, Sustainable Finance Disclosure Regulation). Used in regulatory and beneficiary reporting.',
    `ghg_reporting_required` BOOLEAN COMMENT 'Indicates whether the framework mandates or recommends Greenhouse Gas (GHG) emissions reporting (Scope 1, 2, or 3) as part of the funds disclosure obligations.',
    `governing_body` STRING COMMENT 'Name of the organisation or regulatory authority that owns, maintains, and publishes the framework (e.g., UN PRI Association, European Commission, TCFD Secretariat / IFRS Foundation, GRI Standards Board).',
    `integration_level` STRING COMMENT 'Degree to which this framework is integrated into the funds investment decision-making process: full (embedded in IC process), partial (considered but not binding), monitoring_only, or not_integrated.. Valid values are `full|partial|monitoring_only|not_integrated`',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether compliance with this framework is legally or regulatorily mandatory for the fund (True) or voluntary (False). Mandatory frameworks include SFDR, MiFID II ESG; voluntary include PRI, TCFD (pre-ISSB).',
    `last_assessment_date` DATE COMMENT 'Date of the most recent internal or external assessment of the funds compliance posture and performance against this framework. Supports ongoing ESG governance and audit readiness.',
    `materiality_approach` STRING COMMENT 'Materiality concept applied by the framework: single_materiality (financial impact on the fund), double_materiality (financial + societal/environmental impact), dynamic_materiality, or not_specified. Relevant for GRI vs SASB vs SFDR.. Valid values are `single_materiality|double_materiality|dynamic_materiality|not_specified`',
    `next_review_date` DATE COMMENT 'Scheduled date for the next compliance review of this specific framework-obligation mapping',
    `notes` STRING COMMENT 'Free-text field for additional context, implementation notes, known gaps, or commentary on the funds adoption and compliance posture for this ESG framework. Used by the ESG & Responsible Investment team.',
    `pai_indicator_required` BOOLEAN COMMENT 'Indicates whether the framework requires disclosure of Principal Adverse Impact (PAI) indicators on sustainability factors, as defined under SFDR Article 7 and Regulatory Technical Standards.',
    `pri_module` STRING COMMENT 'Specific PRI Transparency Report module(s) associated with this framework (e.g., Strategy & Governance, Listed Equity, Private Equity, Infrastructure). Null if framework is not PRI-related.',
    `proxy_voting_applicable` BOOLEAN COMMENT 'Indicates whether this framework includes requirements or guidance on proxy voting and shareholder engagement stewardship activities (True). Relevant for PRI, UK Stewardship Code, and similar frameworks.',
    `publication_date` DATE COMMENT 'Date on which the governing body officially published or released this version of the framework. Distinct from the effective_date on which the funds obligations commence.',
    `reporting_deadline_month` BIGINT COMMENT 'Calendar month (1–12) by which the funds annual or periodic disclosure under this framework must be submitted to the governing body or published publicly. Supports ESG reporting calendar management.',
    `reporting_frequency` STRING COMMENT 'Required or expected frequency of disclosure or reporting under this framework (e.g., annual PRI Transparency Report, annual TCFD disclosure). Drives the funds ESG reporting calendar.. Valid values are `annual|semi_annual|quarterly|monthly|on_demand|not_required`',
    `responsible_team` STRING COMMENT 'Name of the internal team or business unit responsible for managing compliance with and reporting under this framework (e.g., ESG & Responsible Investment, Risk Management, Legal & Compliance).',
    `review_date` DATE COMMENT 'Scheduled date for the funds next internal review of this frameworks applicability, version currency, and compliance posture. Supports proactive ESG governance and regulatory change management.',
    `sfdr_article_classification` STRING COMMENT 'SFDR product classification applicable to this framework context: Article 6 (no sustainability integration), Article 8 (promotes environmental/social characteristics), Article 9 (sustainable investment objective), or not_applicable.. Valid values are `article_6|article_8|article_9|not_applicable`',
    `signatory_date` DATE COMMENT 'Date on which the fund formally became a signatory to the framework or voluntary principle. Null if the fund is not a signatory. Relevant for PRI, UNGC, TCFD supporter declarations.',
    `signatory_status` STRING COMMENT 'The funds formal signatory status with the frameworks governing body: signatory (committed member), non_signatory, pending (application submitted), or former_signatory (previously committed, now withdrawn).. Valid values are `signatory|non_signatory|pending|former_signatory`',
    `taxonomy_alignment` STRING COMMENT 'Sustainable finance taxonomy to which this framework aligns for classifying environmentally sustainable economic activities (e.g., EU Taxonomy Regulation, UK Green Taxonomy, ASEAN Taxonomy). Supports SFDR and TCFD reporting.. Valid values are `eu_taxonomy|uk_taxonomy|asean_taxonomy|none`',
    `tcfd_pillar` STRING COMMENT 'TCFD disclosure pillar addressed by this framework: Governance, Strategy, Risk Management, or Metrics and Targets. Null or not_applicable for non-TCFD frameworks. Supports TCFD alignment mapping.. Valid values are `governance|strategy|risk_management|metrics_and_targets|not_applicable`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this ESG framework record. Used for change tracking, incremental data loads, and audit compliance in the Databricks Silver layer.',
    `version` STRING COMMENT 'Version or edition of the framework currently adopted by the fund (e.g., 2.0, 2021, Article 8, GRI 2021). Tracks which iteration of the standard is in force for compliance purposes.. Valid values are `^[0-9]{1,3}(.[0-9]{1,3}){0,2}([a-zA-Z0-9-.]{0,20})?$`',
    CONSTRAINT pk_framework PRIMARY KEY(`framework_id`)
) COMMENT 'Reference catalogue of ESG frameworks, standards, and regulatory regimes adopted by the fund (PRI, SFDR, TCFD, UNGC, SASB, GRI, TNFD). Stores framework code, full name, governing body, applicable jurisdiction, version, effective date, and mandatory vs.';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`esg_policy` (
    `esg_policy_id` BIGINT COMMENT 'Unique identifier for the responsible investment policy record.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: ESG policy governance requires documented approval chains for regulatory compliance and audit. Investment policies must track which employee formally approved them.',
    `superseded_policy_esg_policy_id` BIGINT COMMENT 'Identifier of the previous policy version that this policy replaces.',
    `approval_date` DATE COMMENT 'Date on which the policy was formally approved by the Investment Committee (IC) or Board.',
    `baseline_year` BIGINT COMMENT 'Reference year for measuring progress against climate or ESG targets (e.g., 2020, 2019).',
    `breach_escalation_procedure` STRING COMMENT 'Description of the procedure to follow when a policy breach is detected (e.g., notify IC, divest within 90 days, escalate to Board).',
    `climate_alignment_target` STRING COMMENT 'Specific climate-related target or commitment defined by the policy (e.g., net-zero by 2050, Paris Agreement alignment, 1.5°C pathway).',
    `esg_policy_code` STRING COMMENT 'Externally-known unique code for the policy (e.g., RIP-2024, EXCL-POL-01, PROXY-V3).. Valid values are `^[A-Z0-9_-]{3,20}$`',
    `compliance_monitoring_method` STRING COMMENT 'Method used to monitor compliance with the policy (automated system checks, manual review, or hybrid approach).. Valid values are `automated|manual|hybrid`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the policy record was first created in the system.',
    `document_url` STRING COMMENT 'URL to the official published version of the policy document.. Valid values are `^https?://.*$`',
    `effective_date` DATE COMMENT 'Date from which the policy becomes binding and enforceable across the investment portfolio.',
    `engagement_mandate` BOOLEAN COMMENT 'Indicates whether the policy mandates active engagement with portfolio companies on ESG issues.',
    `esg_integration_level` STRING COMMENT 'Degree to which ESG factors must be integrated into investment decision-making under this policy.. Valid values are `mandatory|recommended|optional|not_applicable`',
    `esg_policy_status` STRING COMMENT 'Current lifecycle status of the policy within the governance framework.. Valid values are `draft|active|under_review|suspended|superseded|archived`',
    `esg_policy_type` STRING COMMENT 'Classification of the policy by its primary ESG (Environmental, Social, and Governance) focus area.. Valid values are `responsible_investment|exclusion|proxy_voting|engagement|climate|human_rights`',
    `exclusion_criteria` STRING COMMENT 'Detailed description of sectors, activities, or entities excluded from investment under this policy (e.g., tobacco, controversial weapons, thermal coal).',
    `expiry_date` DATE COMMENT 'Date on which the policy ceases to be in force; null for open-ended policies.',
    `external_audit_required` BOOLEAN COMMENT 'Indicates whether compliance with the policy requires external third-party audit or verification.',
    `geographic_scope` STRING COMMENT 'Geographic coverage of the policy (global, regional, or market-specific).. Valid values are `global|developed_markets|emerging_markets|specific_region`',
    `ghg_reduction_target_pct` DECIMAL(5,2) COMMENT 'Target percentage reduction in portfolio GHG emissions intensity or absolute emissions as defined by the policy.',
    `is_active` BOOLEAN COMMENT 'Indicates whether the policy is currently active and enforceable (true) or inactive (false).',
    `language` STRING COMMENT 'ISO 639-2 three-letter language code for the primary language of the policy document (e.g., ENG, FRA, DEU).. Valid values are `^[A-Z]{3}$`',
    `last_audit_date` DATE COMMENT 'Date of the most recent external or internal audit of policy compliance.',
    `last_modified_by` STRING COMMENT 'User or system identifier of the individual who last modified the policy record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the policy record.',
    `legal_jurisdiction` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the primary legal jurisdiction governing the policy (e.g., CAN, USA, GBR).. Valid values are `^[A-Z]{3}$`',
    `esg_policy_name` STRING COMMENT 'Full official name of the responsible investment policy (e.g., Responsible Investment Policy, Climate Change Policy, Exclusion Policy).',
    `next_audit_date` DATE COMMENT 'Scheduled date for the next audit of policy compliance.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next mandatory review and update of the policy.',
    `notes` STRING COMMENT 'Free-text field for additional context, implementation guidance, or historical notes related to the policy.',
    `owner` STRING COMMENT 'Name or title of the individual or department responsible for maintaining and enforcing the policy (e.g., Chief Investment Officer, ESG Team).',
    `proxy_voting_mandate` BOOLEAN COMMENT 'Indicates whether the policy mandates proxy voting on ESG-related shareholder resolutions.',
    `public_disclosure_required` BOOLEAN COMMENT 'Indicates whether the policy or its compliance metrics must be publicly disclosed.',
    `regulatory_alignment` STRING COMMENT 'Comma-separated list of regulatory frameworks the policy aligns with (e.g., SFDR, TCFD, PRI).',
    `related_policy_ids` STRING COMMENT 'Comma-separated list of policy_id values for related or dependent policies (e.g., parent policy, superseded policy).',
    `reporting_frequency` STRING COMMENT 'Frequency at which compliance with the policy must be reported to stakeholders.. Valid values are `annual|semi_annual|quarterly|monthly|ad_hoc`',
    `review_frequency_months` BIGINT COMMENT 'Number of months between mandatory policy reviews (e.g., 12, 24, 36).',
    `scope` STRING COMMENT 'Asset class or investment domain to which the policy applies. [ENUM-REF-CANDIDATE: all_assets|public_equities|private_equity|real_estate|infrastructure|fixed_income|natural_resources — 7 candidates stripped; promote to reference product]',
    `summary` STRING COMMENT 'Executive summary or high-level description of the policys objectives and key provisions.',
    `tags` STRING COMMENT 'Comma-separated list of keywords or tags for categorization and search (e.g., climate, human_rights, diversity, fossil_fuels).',
    `target_year` BIGINT COMMENT 'Year by which the policy targets or commitments are to be achieved (e.g., 2030, 2050).',
    `version_number` STRING COMMENT 'Semantic version identifier for the policy document (e.g., 1.0, 2.1, 3.0.1).. Valid values are `^[0-9]+.[0-9]+(.[0-9]+)?$`',
    `created_by` STRING COMMENT 'User or system identifier of the individual who created the policy record.',
    CONSTRAINT pk_esg_policy PRIMARY KEY(`esg_policy_id`)
) COMMENT 'Master record of the funds responsible investment policies and ESG integration mandates—including the Responsible Investment Policy, Exclusion Policy, Proxy Voting Policy, and Engagement Policy.';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`exclusion_list` (
    `exclusion_list_id` BIGINT COMMENT 'Unique identifier for the exclusion list entry. Primary key.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Exclusion decisions require Investment Committee approval with documented accountability. Pension funds must demonstrate governance over exclusion decisions for beneficiary protection and',
    `esg_policy_id` BIGINT COMMENT 'Foreign key linking to esg.policy. Business justification: Exclusion lists are mandated by responsible investment policies. The policy_reference STRING can be removed as the FK provides the authoritative link.',
    `framework_id` BIGINT COMMENT 'Foreign key linking to esg.framework. Business justification: Exclusions may be driven by framework requirements (e.g., UNGC violations). Links exclusion criteria to governing frameworks.',
    `approval_date` DATE COMMENT 'Date on which the Investment Committee or Responsible Investment Committee formally approved this exclusion.',
    `breach_resolution_date` DATE COMMENT 'Date on which a detected compliance breach was resolved through divestment, override, or policy amendment.',
    `compliance_breach_flag` BOOLEAN COMMENT 'Boolean flag indicating whether a compliance breach has been detected (i.e., excluded security found in active portfolio holdings).',
    `controversy_level` STRING COMMENT 'Severity level of ESG controversies associated with the issuer: low, medium, high, or severe, as assessed by ESG data providers or internal due diligence.. Valid values are `low|medium|high|severe`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this exclusion list record was first created in the system.',
    `data_source` STRING COMMENT 'Source system or vendor providing the exclusion data or ESG rating that triggered the exclusion, such as MSCI ESG, Sustainalytics, or internal research.',
    `divestment_deadline` DATE COMMENT 'Target date by which existing holdings of the excluded security must be divested to achieve full compliance with the exclusion policy.',
    `divestment_status` STRING COMMENT 'Current status of divestment for legacy holdings: not applicable (no holdings), pending (divestment planned), in progress (actively divesting), completed (fully divested), or exempted (override granted).. Valid values are `not_applicable|pending|in_progress|completed|exempted`',
    `effective_date` DATE COMMENT 'Date from which this exclusion becomes active and enforceable across the investment portfolio.',
    `engagement_status` STRING COMMENT 'Status of active ownership engagement with the excluded issuer: no engagement, active engagement (ongoing dialogue), escalated (formal escalation), resolved (issue addressed), or discontinued (engagement ceased).. Valid values are `no_engagement|active_engagement|escalated|resolved|discontinued`',
    `esg_rating` STRING COMMENT 'ESG rating or score from external provider (e.g., MSCI ESG, Sustainalytics) that contributed to the exclusion decision.',
    `exclusion_category` STRING COMMENT 'Specific category or theme of the exclusion, such as controversial weapons, tobacco, thermal coal, oil sands, human rights violations, or labor rights violations.. Valid values are `controversial_weapons|tobacco|thermal_coal|oil_sands|human_rights|labor_rights`',
    `exclusion_identifier` STRING COMMENT 'Business-facing unique identifier or code for this exclusion entry, used for external reference and reporting.',
    `exclusion_override_flag` BOOLEAN COMMENT 'Boolean flag indicating whether an exception or override has been granted for this exclusion, allowing investment despite the exclusion criteria being met.',
    `exclusion_reason` STRING COMMENT 'Detailed narrative explanation of why this security, issuer, or sector is excluded from the investable universe, including policy references and rationale.',
    `exclusion_scope` STRING COMMENT 'Asset class or portfolio scope to which this exclusion applies: all portfolios, public equity only, private equity, fixed income, real estate, or infrastructure.. Valid values are `all_portfolios|public_equity|private_equity|fixed_income|real_estate|infrastructure`',
    `exclusion_status` STRING COMMENT 'Current lifecycle status of the exclusion entry: active (enforced), suspended (temporarily inactive), expired (no longer valid), under review (being reassessed), pending approval (awaiting IC decision), or revoked (formally withdrawn).. Valid values are `active|suspended|expired|under_review|pending_approval|revoked`',
    `exclusion_type` STRING COMMENT 'Classification of the exclusion basis: norm-based (international norms violations), sector-based (industry exclusion), product-based (specific products), issuer-based (entity-level), geography-based (country/region), or conduct-based (corporate behavior).. Valid values are `norm-based|sector-based|product-based|issuer-based|geography-based|conduct-based`',
    `expiry_date` DATE COMMENT 'Date on which this exclusion expires or is scheduled for review. Null if the exclusion is indefinite.',
    `ghg_emissions_intensity` DECIMAL(15,2) COMMENT 'GHG emissions intensity metric (e.g., tonnes CO2e per million USD revenue) for the issuer, used as a quantitative exclusion criterion for high-carbon emitters.',
    `issuer_country` STRING COMMENT 'Three-letter ISO country code representing the issuers country of domicile or primary listing.. Valid values are `^[A-Z]{3}$`',
    `issuer_lei` STRING COMMENT '20-character Legal Entity Identifier for the issuer, providing globally unique entity identification.. Valid values are `^[A-Z0-9]{20}$`',
    `issuer_name` STRING COMMENT 'Legal name of the issuer, company, or entity subject to the exclusion.',
    `last_holdings_check_date` DATE COMMENT 'Date of the most recent portfolio holdings check to verify compliance with this exclusion across all portfolios and asset classes.',
    `notes` STRING COMMENT 'Free-text field for additional context, operational notes, or special instructions related to this exclusion entry.',
    `override_reason` STRING COMMENT 'Detailed explanation of why an exclusion override was granted, including Investment Committee rationale and compensating controls.',
    `proxy_voting_restriction` BOOLEAN COMMENT 'Boolean flag indicating whether proxy voting rights are restricted or prohibited for this excluded security, if still held in legacy positions.',
    `revenue_threshold_pct` DECIMAL(5,2) COMMENT 'Revenue exposure threshold percentage that triggers exclusion. For example, companies deriving more than 5% of revenue from thermal coal may be excluded.',
    `review_date` DATE COMMENT 'Next scheduled date for periodic review of this exclusion to assess continued relevance and compliance with evolving ESG standards.',
    `sector_classification` STRING COMMENT 'Industry sector classification of the excluded entity or security, typically using GICS, ICB, or internal taxonomy.',
    `security_identifier` STRING COMMENT 'Primary security identifier for the excluded instrument. May be ISIN, CUSIP, SEDOL, or internal security ID depending on asset class and market.',
    `security_identifier_type` STRING COMMENT 'Type of security identifier used: ISIN (International Securities Identification Number), CUSIP, SEDOL, TICKER, or INTERNAL (proprietary identifier).. Valid values are `ISIN|CUSIP|SEDOL|TICKER|INTERNAL`',
    `sfdr_classification` STRING COMMENT 'SFDR article classification for the excluded security or issuer: Article 6 (no sustainability objective), Article 8 (promotes ESG), Article 9 (sustainable investment objective), or excluded (not eligible under SFDR).. Valid values are `article_6|article_8|article_9|excluded`',
    `tcfd_climate_risk_flag` BOOLEAN COMMENT 'Boolean flag indicating whether the exclusion is driven by TCFD-identified climate-related financial risks, such as transition risk or physical risk exposure.',
    `un_global_compact_violation` BOOLEAN COMMENT 'Boolean flag indicating whether the issuer has been identified as violating UN Global Compact principles (human rights, labor, environment, anti-corruption).',
    `updated_by` STRING COMMENT 'User identifier or system account that last updated this exclusion list record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this exclusion list record.',
    `created_by` STRING COMMENT 'User identifier or system account that created this exclusion list record.',
    CONSTRAINT pk_exclusion_list PRIMARY KEY(`exclusion_list_id`)
) COMMENT 'Master record of securities, issuers, sectors, and geographies formally excluded from the investable universe under the funds Exclusion Policy. Captures exclusion type (norm-based, sector-based, product-based), exclusion reason (controversial weapons';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`sfdr_classification` (
    `sfdr_classification_id` BIGINT COMMENT 'Unique identifier for the SFDR classification record.',
    `composite_id` BIGINT COMMENT 'Foreign key linking to performance.composite. Business justification: EU SFDR regulation requires pension funds to report Article 6/8/9 classification at composite level for investor disclosures.',
    `framework_id` BIGINT COMMENT 'Foreign key linking to esg.framework. Business justification: SFDR classifications are made under the SFDR regulatory framework. Links classification to the governing framework.',
    `fund_id` BIGINT COMMENT 'Reference to the fund vehicle or mandate to which this SFDR classification applies.',
    `manager_mandate_id` BIGINT COMMENT 'Reference to the investment mandate if this classification applies to a separately managed account or mandate rather than a pooled fund.',
    `sfdr_disclosure_id` BIGINT COMMENT 'Foreign key linking to compliance.sfdr_disclosure. Business justification: SFDR fund classifications (Article 6/8/9) directly determine regulatory disclosure requirements. Pension funds must file SFDR disclosures based on each funds classification.',
    `benchmark_index_name` STRING COMMENT 'Name of the designated ESG or sustainability benchmark index used for performance comparison and alignment assessment, if applicable (e.g., MSCI World ESG Leaders, FTSE4Good).',
    `benchmark_is_esg_aligned` BOOLEAN COMMENT 'Indicates whether the designated benchmark is itself an ESG or Paris-aligned benchmark as defined under the EU Benchmark Regulation.',
    `classification_approval_date` DATE COMMENT 'The date on which this SFDR classification was formally approved by the Investment Committee or designated governance body.',
    `classification_approved_by` STRING COMMENT 'Name or identifier of the Investment Committee member or governance body that approved this SFDR classification.',
    `classification_effective_date` DATE COMMENT 'The date from which this SFDR classification becomes effective and must be disclosed to investors.',
    `classification_end_date` DATE COMMENT 'The date on which this SFDR classification ceases to be effective, typically due to reclassification or fund closure. Null for currently active classifications.',
    `classification_rationale` STRING COMMENT 'Detailed business and regulatory rationale explaining why this fund or mandate was assigned this specific SFDR article classification, including reference to investment objectives, ESG integration approach, and sustainability commitments.',
    `classification_status` STRING COMMENT 'Current lifecycle status of this SFDR classification record: active (in force), pending (approved but not yet effective), superseded (replaced by newer classification), or withdrawn (no longer applicable).. Valid values are `active|pending|superseded|withdrawn`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this SFDR classification record was first created in the system.',
    `data_coverage_percentage` DECIMAL(5,2) COMMENT 'Percentage of the funds portfolio (by market value or number of holdings) for which ESG data is available to support SFDR classification and PAI disclosures.',
    `data_quality_score` DECIMAL(3,2) COMMENT 'Internal data quality score (0.00 to 1.00) reflecting the completeness, accuracy, and timeliness of the ESG data used to support this SFDR classification.',
    `do_no_significant_harm_assessment` STRING COMMENT 'Summary of the assessment process and conclusion regarding whether the funds sustainable investments do no significant harm to any environmental or social objective, as required under SFDR.',
    `engagement_strategy_applied` BOOLEAN COMMENT 'Indicates whether an active engagement strategy with investee companies on ESG matters is part of the responsible investment approach for this fund or mandate.',
    `environmental_objective_alignment` BOOLEAN COMMENT 'Indicates whether the fund or mandate promotes or has as its objective alignment with one or more environmental objectives as defined under the EU Taxonomy Regulation.',
    `esg_methodology_version` STRING COMMENT 'Version identifier of the ESG assessment methodology or framework applied to determine this SFDR classification and ongoing monitoring.',
    `esg_rating_provider` STRING COMMENT 'Name of the primary external ESG rating or data provider used to assess sustainability characteristics and PAI indicators for this fund or mandate (e.g., MSCI ESG, Sustainalytics, ISS ESG).',
    `exclusion_policy_applied` BOOLEAN COMMENT 'Indicates whether a formal exclusion policy (e.g., fossil fuels, controversial weapons, tobacco) is applied as part of the ESG integration strategy for this fund or mandate.',
    `exclusion_policy_description` STRING COMMENT 'Detailed description of the exclusion criteria and sectors or activities that are excluded from the investment universe for this fund or mandate.',
    `good_governance_assessment` STRING COMMENT 'Summary of the assessment process and conclusion regarding whether investee companies follow good governance practices, particularly with respect to sound management structures, employee relations, remuneration of staff, and tax compliance.',
    `last_review_date` DATE COMMENT 'The date on which this SFDR classification was last reviewed for continued accuracy and compliance with evolving regulatory guidance.',
    `minimum_sustainable_investment_percentage` DECIMAL(5,2) COMMENT 'For Article 9 funds, the minimum proportion of the portfolio (as a percentage) that must be invested in sustainable investments as defined by SFDR. Null for Article 6 and Article 8 funds unless they commit to a minimum sustainable investment threshold.',
    `next_review_date` DATE COMMENT 'The scheduled date for the next periodic review of this SFDR classification to ensure ongoing compliance and accuracy.',
    `notes` STRING COMMENT 'Free-text field for additional notes, comments, or context regarding this SFDR classification, including any special considerations or pending regulatory clarifications.',
    `pai_disclosure_required` BOOLEAN COMMENT 'Indicates whether this fund or mandate is required to disclose Principal Adverse Impacts on sustainability factors under SFDR Article 4 or 7.',
    `pai_indicators_considered` STRING COMMENT 'Comma-separated list of PAI indicator codes or names that are considered and disclosed for this fund or mandate, drawn from the mandatory and optional PAI indicators defined in SFDR RTS.',
    `periodic_disclosure_url` STRING COMMENT 'URL or document reference to the periodic (annual) disclosure report that contains the SFDR-mandated sustainability performance and PAI disclosures for this fund or mandate.',
    `pre_contractual_disclosure_url` STRING COMMENT 'URL or document reference to the pre-contractual disclosure document (e.g., prospectus annex) that contains the SFDR-mandated sustainability disclosures for this fund or mandate.',
    `proxy_voting_policy_applied` BOOLEAN COMMENT 'Indicates whether a formal proxy voting policy aligned with ESG principles is applied to portfolio holdings in this fund or mandate.',
    `regulatory_filing_reference` STRING COMMENT 'Reference number or identifier of the regulatory filing or submission to the competent authority (e.g., national regulator, ESMA) that includes this SFDR classification.',
    `sfdr_article_classification` STRING COMMENT 'The SFDR article classification: Article 6 (no sustainability objective), Article 8 (promotes environmental or social characteristics), or Article 9 (has sustainable investment as objective).. Valid values are `Article 6|Article 8|Article 9`',
    `social_objective_alignment` BOOLEAN COMMENT 'Indicates whether the fund or mandate promotes or has as its objective alignment with one or more social objectives as defined under SFDR and related frameworks.',
    `taxonomy_alignment_percentage` DECIMAL(5,2) COMMENT 'The percentage of the funds investments that are aligned with the EU Taxonomy for sustainable activities. Required disclosure for Article 8 and Article 9 funds.',
    `updated_by` STRING COMMENT 'User identifier or system account that last modified this SFDR classification record.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this SFDR classification record was last modified.',
    `website_disclosure_url` STRING COMMENT 'URL to the dedicated website section where SFDR sustainability information for this fund or mandate is published and maintained.',
    `created_by` STRING COMMENT 'User identifier or system account that created this SFDR classification record.',
    CONSTRAINT pk_sfdr_classification PRIMARY KEY(`sfdr_classification_id`)
) COMMENT 'Master record of SFDR (Sustainable Finance Disclosure Regulation) product-level classifications for each fund vehicle and mandate managed or invested in. Stores Article classification (6, 8, or 9), classification rationale, which Principal Adverse Impact';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`tcfd_disclosure` (
    `tcfd_disclosure_id` BIGINT COMMENT 'Unique identifier for the TCFD disclosure submission record.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: TCFD disclosures are regulatory filings requiring formal sign-off. Pension funds must document who approved climate risk disclosures for regulatory accountability and audit trails.',
    `climate_scenario_id` BIGINT COMMENT 'Foreign key linking to esg.climate_scenario. Business justification: TCFD disclosures reference climate scenarios for scenario analysis. The scenario_temperature_pathways is a summary field, the FK links to the detailed scenario.',
    `net_zero_commitment_id` BIGINT COMMENT 'Foreign key linking to esg.net_zero_commitment. Business justification: TCFD disclosures report on net zero commitment progress. The net_zero_commitment_flag and net_zero_target_year are disclosure-specific values, the FK links to the commitment record.',
    `approval_date` DATE COMMENT 'Date on which the TCFD disclosure was formally approved by the designated authority.',
    `assurance_level` STRING COMMENT 'Level of assurance provided by the external auditor, either limited or reasonable assurance.. Valid values are `limited|reasonable`',
    `assurance_provider` STRING COMMENT 'Name of the external assurance provider or auditor who verified the TCFD disclosure and climate data.',
    `baseline_year` BIGINT COMMENT 'Reference year against which emissions reductions and progress toward targets are measured.',
    `board_oversight_description` STRING COMMENT 'Description of the boards oversight of climate-related risks and opportunities, including committee structure and frequency of review.',
    `carbon_footprint_portfolio_tco2e_per_million` DECIMAL(18,4) COMMENT 'Portfolio-level carbon footprint metric representing financed emissions per million dollars invested, calculated according to PCAF methodology.',
    `climate_opportunity_summary` STRING COMMENT 'Summary of climate-related opportunities identified by the organization, including resource efficiency, energy sources, products and services, markets, and resilience.',
    `climate_related_financial_impact_estimate` STRING COMMENT 'Qualitative or quantitative estimate of the financial impact of climate-related risks and opportunities on the organizations financial position and performance.',
    `climate_risk_integration_approach` STRING COMMENT 'Description of how climate-related risks are integrated into the organizations overall risk management framework and investment decision-making processes.',
    `climate_var_estimate` DECIMAL(18,2) COMMENT 'Estimated potential loss in portfolio value due to climate-related risks under specified scenarios, expressed in monetary terms.',
    `climate_var_methodology` STRING COMMENT 'Description of the methodology and assumptions used to calculate the climate VaR estimate.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp recording when this TCFD disclosure record was first created in the system.',
    `disclosure_status` STRING COMMENT 'Current lifecycle status of the TCFD disclosure submission.. Valid values are `draft|under_review|approved|published|archived`',
    `disclosure_version` STRING COMMENT 'Version identifier for the disclosure document, used to track revisions and amendments.',
    `disclosure_year` BIGINT COMMENT 'Calendar year in which the TCFD disclosure was published or submitted.',
    `emissions_intensity_metric` STRING COMMENT 'Description of the emissions intensity metric used, such as tCO2e per million dollars of Assets Under Management (AUM) or tCO2e per million dollars of revenue.',
    `emissions_intensity_value` DECIMAL(18,4) COMMENT 'Calculated emissions intensity value based on the specified metric, enabling comparison across periods and peers.',
    `external_assurance_obtained` BOOLEAN COMMENT 'Indicates whether the TCFD disclosure and underlying climate data have been subject to external third-party assurance or verification.',
    `fossil_fuel_exposure_pct` DECIMAL(5,2) COMMENT 'Percentage of portfolio value exposed to fossil fuel-related assets, used to assess transition risk exposure.',
    `governance_narrative` STRING COMMENT 'Textual description of the organizations governance around climate-related risks and opportunities, including board oversight and managements role.',
    `green_revenue_alignment_pct` DECIMAL(5,2) COMMENT 'Percentage of portfolio companies revenues aligned with green or low-carbon activities, as defined by relevant taxonomies such as EU Taxonomy.',
    `interim_emissions_reduction_target_pct` DECIMAL(5,2) COMMENT 'Interim percentage reduction target for GHG emissions relative to a baseline year, used to track progress toward long-term net-zero goals.',
    `interim_target_year` BIGINT COMMENT 'Year by which the interim emissions reduction target is to be achieved.',
    `last_modified_by` STRING COMMENT 'User identifier of the individual who last modified this TCFD disclosure record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'System timestamp recording when this TCFD disclosure record was last updated.',
    `management_role_description` STRING COMMENT 'Description of managements role in assessing and managing climate-related risks and opportunities, including specific roles and responsibilities.',
    `metrics_targets_narrative` STRING COMMENT 'Textual description of the metrics and targets used to assess and manage relevant climate-related risks and opportunities.',
    `net_zero_commitment_flag` BOOLEAN COMMENT 'Indicates whether the organization has made a formal commitment to achieve net-zero emissions by a specified target year.',
    `net_zero_target_year` BIGINT COMMENT 'Target year by which the organization aims to achieve net-zero greenhouse gas emissions.',
    `physical_risk_exposure_summary` STRING COMMENT 'Summary of the organizations exposure to physical climate risks such as extreme weather events, sea-level rise, and temperature changes.',
    `prepared_by` STRING COMMENT 'Name or identifier of the individual or team responsible for preparing the TCFD disclosure.',
    `publication_url` STRING COMMENT 'Web address where the published TCFD disclosure document can be accessed by stakeholders.',
    `reporting_period_end_date` DATE COMMENT 'End date of the fiscal or calendar period covered by this TCFD disclosure.',
    `reporting_period_start_date` DATE COMMENT 'Start date of the fiscal or calendar period covered by this TCFD disclosure.',
    `risk_management_narrative` STRING COMMENT 'Textual description of the processes used by the organization to identify, assess, and manage climate-related risks.',
    `scenario_analysis_approach` STRING COMMENT 'Description of the scenario analysis methodology used to assess the resilience of the organizations strategy under different climate-related scenarios.',
    `scenario_temperature_pathways` STRING COMMENT 'Temperature pathways or scenarios analyzed, such as 1.5C, 2C, or higher warming scenarios, used in the scenario analysis.',
    `scope_1_emissions_tco2e` DECIMAL(18,2) COMMENT 'Total direct GHG emissions from sources owned or controlled by the organization, measured in metric tons of carbon dioxide equivalent.',
    `scope_2_emissions_tco2e` DECIMAL(18,2) COMMENT 'Total indirect GHG emissions from the generation of purchased electricity, steam, heating, and cooling consumed by the organization, measured in metric tons of carbon dioxide equivalent.',
    `scope_3_emissions_tco2e` DECIMAL(18,2) COMMENT 'Total indirect GHG emissions from the organizations value chain, including financed emissions from investment portfolio, measured in metric tons of carbon dioxide equivalent.',
    `stranded_asset_risk_assessment` STRING COMMENT 'Qualitative assessment of the risk that portfolio assets may become stranded due to climate policy, technology shifts, or market changes.',
    `strategy_narrative` STRING COMMENT 'Textual description of the actual and potential impacts of climate-related risks and opportunities on the organizations businesses, strategy, and financial planning.',
    `submission_date` DATE COMMENT 'Date on which the TCFD disclosure was formally submitted or published.',
    `time_horizons_assessed` STRING COMMENT 'Time horizons considered in the climate risk assessment, such as short-term (0-5 years), medium-term (5-15 years), and long-term (15+ years).',
    `total_emissions_tco2e` DECIMAL(18,2) COMMENT 'Sum of Scope 1, Scope 2, and Scope 3 emissions, representing the organizations total carbon footprint in metric tons of carbon dioxide equivalent.',
    `transition_risk_exposure_summary` STRING COMMENT 'Summary of the organizations exposure to transition risks arising from policy, legal, technology, and market changes as the economy shifts toward a lower-carbon future.',
    `weighted_average_carbon_intensity_waci` DECIMAL(18,4) COMMENT 'Portfolio-weighted average of investee companies carbon intensities, measured in tCO2e per million dollars of revenue, used to assess portfolio climate risk.',
    `created_by` STRING COMMENT 'User identifier of the individual who created this TCFD disclosure record in the system.',
    CONSTRAINT pk_tcfd_disclosure PRIMARY KEY(`tcfd_disclosure_id`)
) COMMENT 'Transactional record of annual TCFD (Task Force on Climate-related Financial Disclosures) climate risk disclosure submissions. Captures reporting period, governance narrative, strategy narrative, risk management narrative, physical risk exposure summary';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`ghg_emission_record` (
    `ghg_emission_record_id` BIGINT COMMENT 'Unique identifier for the greenhouse gas emission record.',
    `infra_asset_id` BIGINT COMMENT 'Reference to the underlying asset (direct investment, real estate property, infrastructure asset) for which emissions are measured.',
    `climate_scenario_id` BIGINT COMMENT 'Foreign key linking to esg.climate_scenario. Business justification: GHG emissions are tracked against climate scenario pathways for alignment assessment.',
    `data_provider_id` BIGINT COMMENT 'Foreign key linking to esg.data_provider. Business justification: GHG emissions data is sourced from external data providers. The data_provider STRING can be removed as the FK provides the authoritative link.',
    `issuer_esg_rating_id` BIGINT COMMENT 'Foreign key linking to esg.issuer_esg_rating. Business justification: Linking ghg_emission_record to issuer_esg_rating associates emissions data with the issuer’s ESG profile, enabling integrated reporting.',
    `portfolio_holding_id` BIGINT COMMENT 'Reference to the specific portfolio holding or investment position to which this emission data applies.',
    `resource_asset_id` BIGINT COMMENT 'Foreign key linking to naturalresource.resource_asset. Business justification: Each GHG emission record must be tied to a specific natural resource asset for compliance and reporting.',
    `asset_class` STRING COMMENT 'Investment asset class to which this emission record applies. [ENUM-REF-CANDIDATE: public_equity|private_equity|real_estate|infrastructure|natural_resources|credit|other — 7 candidates stripped; promote to reference product]',
    `attributed_emissions_tco2e` DECIMAL(18,4) COMMENT 'Emissions attributed to the funds investment based on ownership percentage or other allocation method, measured in tCO2e.',
    `baseline_year` BIGINT COMMENT 'Reference year used as the baseline for measuring emissions reduction progress.',
    `carbon_footprint_per_million_invested` DECIMAL(18,4) COMMENT 'Carbon footprint metric expressed as tCO2e per million dollars invested, used for portfolio-level aggregation.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this emission record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO currency code for any monetary values used in intensity calculations.. Valid values are `^[A-Z]{3}$`',
    `data_collection_method` STRING COMMENT 'Description of the method used to collect or obtain the emissions data (e.g., direct reporting, survey, estimation model, third-party data feed).',
    `data_quality_flag` BOOLEAN COMMENT 'Categorical flag indicating the quality level of the emissions data.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Numerical score representing the quality, completeness, and reliability of the emissions data (scale 0-100).',
    `data_source_type` STRING COMMENT 'Classification of the data source used to obtain emissions data (reported by company, estimated, modeled, third-party provider, proxy).. Valid values are `reported|estimated|modeled|third_party|proxy`',
    `emission_factor_source` STRING COMMENT 'Source of the emission factors used in calculations (e.g., IPCC, EPA, DEFRA, IEA).',
    `emissions_intensity_metric` STRING COMMENT 'Denominator used to calculate emissions intensity (e.g., revenue, AUM, employees, production unit, square meter).. Valid values are `revenue|aum|employees|production_unit|square_meter|other`',
    `emissions_intensity_value` DECIMAL(18,6) COMMENT 'Calculated emissions intensity ratio (tCO2e per unit of the chosen metric).',
    `geographic_scope` STRING COMMENT 'Three-letter ISO country code representing the primary geographic location of the emissions source.. Valid values are `^[A-Z]{3}$`',
    `is_active` BOOLEAN COMMENT 'Indicates whether this emission record is currently active and should be used in reporting and analytics.',
    `issuer_lei` STRING COMMENT 'Legal Entity Identifier of the issuer or operating company responsible for the emissions.. Valid values are `^[A-Z0-9]{20}$`',
    `issuer_name` STRING COMMENT 'Legal name of the issuer or operating company responsible for the emissions.',
    `last_modified_by` STRING COMMENT 'User or system identifier that last modified this emission record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this emission record was last updated.',
    `measurement_date` DATE COMMENT 'Date on which the emission measurement or calculation was performed.',
    `methodology` STRING COMMENT 'Description of the calculation methodology or standard used to measure emissions (e.g., GHG Protocol, ISO 14064, PCAF).',
    `notes` STRING COMMENT 'Additional notes, comments, or context regarding the emissions data, methodology, or data quality.',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage of ownership or attribution used to calculate the funds proportional share of emissions.',
    `paris_alignment_flag` BOOLEAN COMMENT 'Indicates whether the emissions trajectory is aligned with Paris Agreement climate goals (1.5 or 2 degree scenarios).',
    `reduction_target_pct` DECIMAL(5,2) COMMENT 'Target percentage reduction in emissions relative to the baseline year.',
    `reporting_period_end_date` DATE COMMENT 'End date of the reporting period for which emissions are measured.',
    `reporting_period_start_date` DATE COMMENT 'Start date of the reporting period for which emissions are measured.',
    `scope_1_emissions_tco2e` DECIMAL(18,4) COMMENT 'Direct greenhouse gas emissions from sources owned or controlled by the company, measured in tonnes of carbon dioxide equivalent.',
    `scope_2_location_based_emissions_tco2e` DECIMAL(18,4) COMMENT 'Indirect emissions from purchased electricity, steam, heating, and cooling using average emission factors for the grid, measured in tCO2e.',
    `scope_2_market_based_emissions_tco2e` DECIMAL(18,4) COMMENT 'Indirect emissions from purchased energy using contractual instruments and supplier-specific emission factors, measured in tCO2e.',
    `scope_3_category` STRING COMMENT 'Specific Scope 3 category classification per GHG Protocol (e.g., Category 1 Purchased Goods, Category 11 Use of Sold Products). [ENUM-REF-CANDIDATE',
    `scope_3_emissions_tco2e` DECIMAL(18,4) COMMENT 'All other indirect emissions occurring in the value chain (upstream and downstream), measured in tonnes of carbon dioxide equivalent.',
    `sector_classification` STRING COMMENT 'Industry sector classification of the emitting entity (e.g., GICS, NAICS, NACE).',
    `sfdr_classification` STRING COMMENT 'SFDR article classification of the investment product to which this emission data applies.. Valid values are `article_6|article_8|article_9`',
    `target_year` BIGINT COMMENT 'Year by which the emissions reduction target is to be achieved.',
    `tcfd_alignment_flag` BOOLEAN COMMENT 'Indicates whether the emissions data meets TCFD disclosure requirements.',
    `total_emissions_tco2e` DECIMAL(18,4) COMMENT 'Sum of Scope 1, Scope 2 (location-based or market-based), and Scope 3 emissions, measured in tCO2e.',
    `verification_body` STRING COMMENT 'Name of the independent third-party organization that verified the emissions data.',
    `verification_date` DATE COMMENT 'Date on which the emissions data verification was completed.',
    `verification_status` STRING COMMENT 'Indicates whether the emissions data has been independently verified and the level of assurance obtained.. Valid values are `verified|unverified|limited_assurance|reasonable_assurance`',
    `created_by` STRING COMMENT 'User or system identifier that created this emission record.',
    CONSTRAINT pk_ghg_emission_record PRIMARY KEY(`ghg_emission_record_id`)
) COMMENT 'Transactional record of greenhouse gas (GHG) emissions data collected at the portfolio holding or asset level. Captures Scope 1, Scope 2 (location-based and market-based), and Scope 3 emissions in tCO2e, data source (reported vs.';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`climate_scenario` (
    `climate_scenario_id` BIGINT COMMENT 'Unique identifier for the climate scenario record.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Climate scenarios used for stress testing require formal approval before use in portfolio analysis. Documents who authorized each scenario for risk management governance.',
    `approval_date` DATE COMMENT 'Date when the scenario was formally approved for use by the Investment Committee or Risk Committee.',
    `approved_for_use_flag` BOOLEAN COMMENT 'Indicates whether the scenario has been formally approved by the Investment Committee or Risk Committee for use in investment decision-making and risk management.',
    `asset_class_applicability` STRING COMMENT 'Investment asset classes for which this scenario is relevant and applicable (e.g., public equities, private equity, real estate, infrastructure, credit).',
    `base_year` BIGINT COMMENT 'Starting year for the climate scenario projections and baseline measurements.',
    `carbon_budget_gt` DECIMAL(12,2) COMMENT 'Total cumulative carbon dioxide emissions budget in gigatonnes allowed under this scenario pathway from base year to target year.',
    `carbon_price_trajectory` STRING COMMENT 'Qualitative classification of the carbon pricing pathway assumed in the scenario (low, medium, high, very high).. Valid values are `low|medium|high|very_high`',
    `climate_scenario_status` STRING COMMENT 'Current lifecycle status of the climate scenario within the organizations stress testing framework.. Valid values are `active|deprecated|under_review|archived`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the climate scenario record was first created in the system.',
    `data_source_url` STRING COMMENT 'Web address or repository location where the full scenario data, documentation, and methodology can be accessed.',
    `geographic_scope` STRING COMMENT 'Spatial coverage of the climate scenario (global, regional, or national level projections).. Valid values are `global|regional|national`',
    `key_assumptions` STRING COMMENT 'Critical assumptions underlying the scenario regarding policy action, technology deployment, economic growth, population dynamics, and behavioral change.',
    `last_modified_by` STRING COMMENT 'User identifier or system account that last modified the climate scenario record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when the climate scenario record was most recently updated or modified.',
    `limitations` STRING COMMENT 'Known limitations, uncertainties, and caveats associated with the scenarios projections and applicability to investment decision-making.',
    `methodology_summary` STRING COMMENT 'Brief summary of the modeling approach, assumptions, and methodologies used to construct the climate scenario (maximum 500 characters).',
    `net_zero_year` BIGINT COMMENT 'Year in which net greenhouse gas emissions reach zero under this scenario pathway (null if net zero is not achieved).',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review and validation of the scenarios continued relevance and accuracy.',
    `owner` STRING COMMENT 'Name or identifier of the internal team or individual responsible for maintaining and updating the scenario (e.g., Climate Risk Team, ESG Research).',
    `peak_emissions_year` BIGINT COMMENT 'Year in which global greenhouse gas emissions reach their maximum level before declining under this scenario.',
    `physical_risk_severity` STRING COMMENT 'Overall severity level of physical climate risks (acute and chronic) under this scenario.. Valid values are `low|moderate|high|severe`',
    `policy_stringency` STRING COMMENT 'Assessment of the strength and comprehensiveness of climate policy measures assumed in the scenario.. Valid values are `weak|moderate|strong|very_strong`',
    `publication_date` DATE COMMENT 'Date when the climate scenario was officially published or released by the source organization.',
    `rcp_classification` STRING COMMENT 'IPCC Representative Concentration Pathway classification indicating radiative forcing level (W/m2) by 2100.. Valid values are `RCP2.6|RCP4.5|RCP6.0|RCP8.5`',
    `regulatory_alignment` STRING COMMENT 'Comma-separated list of regulatory frameworks and stress testing requirements this scenario satisfies (e.g., a prudential climate risk guideline, ECB Climate Stress Test, PRA Climate Biennial Exploratory Scenario).',
    `review_frequency_months` BIGINT COMMENT 'Number of months between scheduled reviews of the scenario (e.g., 12 for annual review, 24 for biennial review).',
    `scenario_category` STRING COMMENT 'High-level categorization of the climate scenario pathway (orderly transition, disorderly transition, hot house world, too little too late).. Valid values are `orderly|disorderly|hot_house|too_little_too_late`',
    `scenario_code` STRING COMMENT 'Unique business identifier code for the climate scenario (e.g., NGFS_NZ2050, IEA_SDS, RCP26).. Valid values are `^[A-Z0-9_-]{3,20}$`',
    `scenario_name` STRING COMMENT 'Full descriptive name of the climate scenario (e.g., Network for Greening the Financial System Net Zero 2050, International Energy Agency Sustainable Development Scenario).',
    `scenario_type` STRING COMMENT 'Classification of the climate scenario as transition risk, physical risk, or combined risk scenario.. Valid values are `transition|physical|combined`',
    `sector_coverage` STRING COMMENT 'Economic sectors and industries covered by the scenarios projections and impact assessments (e.g., energy, transport, agriculture, buildings, industry).',
    `sfdr_disclosure_flag` BOOLEAN COMMENT 'Indicates whether the scenario is used for SFDR principal adverse impact and sustainability risk disclosures.',
    `source_organization` STRING COMMENT 'Name of the organization or consortium that published the climate scenario (e.g., NGFS, IEA, IPCC, UNEP).',
    `ssp_classification` STRING COMMENT 'IPCC Shared Socioeconomic Pathway classification describing socioeconomic development trajectory (e.g., SSP1, SSP2, SSP3, SSP4, SSP5).',
    `stress_test_usage_flag` BOOLEAN COMMENT 'Indicates whether this scenario is actively used in the organizations climate risk stress testing and scenario analysis exercises.',
    `target_year` BIGINT COMMENT 'End year for the climate scenario projections and impact assessments.',
    `tcfd_alignment_flag` BOOLEAN COMMENT 'Indicates whether the scenario is aligned with TCFD recommended climate scenario analysis frameworks.',
    `technology_change_assumption` STRING COMMENT 'Assumed pace of technological innovation and deployment for decarbonization and adaptation technologies.. Valid values are `slow|moderate|rapid|breakthrough`',
    `temperature_pathway` STRING COMMENT 'Global mean temperature increase pathway associated with the scenario (e.g., 1.5C, 2C, 3C, 4C+) by end of century relative to pre-industrial levels.',
    `time_horizon` BIGINT COMMENT 'Number of years from base year to the scenarios target projection year (e.g., 30 for 2050 target from 2020 base).',
    `transition_risk_severity` STRING COMMENT 'Overall severity level of transition risks (policy, technology, market, reputation) under this scenario.. Valid values are `low|moderate|high|severe`',
    `usage_guidance` STRING COMMENT 'Internal guidance on appropriate use cases, interpretation, and integration of the scenario into investment analysis and risk management processes.',
    `version` STRING COMMENT 'Version number of the climate scenario release (e.g., 1.0, 2.1, 3.0).. Valid values are `^[0-9]+.[0-9]+(.[0-9]+)?$`',
    `created_by` STRING COMMENT 'User identifier or system account that created the climate scenario record.',
    CONSTRAINT pk_climate_scenario PRIMARY KEY(`climate_scenario_id`)
) COMMENT 'Reference catalogue of climate transition and physical risk scenarios used in stress testing and TCFD disclosures. Stores scenario name (e.g., NGFS Net Zero 2050, IEA SDS, RCP 2.6/4.5/8.5), scenario type (transition vs.';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`engagement_activity` (
    `engagement_activity_id` BIGINT COMMENT 'Unique identifier for the stewardship engagement activity record.',
    `esg_policy_id` BIGINT COMMENT 'Foreign key linking to esg.policy. Business justification: Engagement activities are conducted under specific responsible investment policies. The policy_reference STRING can be removed as the FK provides the authoritative link.',
    `issuer_esg_rating_id` BIGINT COMMENT 'Foreign key linking to esg.issuer_esg_rating. Business justification: Engagement activities target investee companies that have ESG ratings. The investee_lei and investee_name are operational identifiers needed for matching, not redundant with the rating',
    `asset_class` STRING COMMENT 'Investment asset class category of the holding that is the subject of the engagement, aligning with the funds strategic asset allocation framework. [ENUM-REF-CANDIDATE',
    `collaborative_initiative_name` STRING COMMENT 'Name of the formal collaborative engagement initiative or investor coalition through which the engagement was conducted, if applicable.',
    `controversy_level` STRING COMMENT 'Severity classification of any ESG-related controversy or incident associated with the investee entity that triggered or informed the engagement.. Valid values are `none|low|moderate|high|severe`',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this engagement activity record was first created in the data platform, supporting audit trail and data lineage.',
    `data_source` STRING COMMENT 'System or platform from which the engagement activity record was captured or logged, supporting data lineage and audit requirements.',
    `document_reference_url` STRING COMMENT 'URL or file path to supporting documentation for the engagement activity, such as meeting notes, correspondence, or presentation materials.',
    `engagement_channel` STRING COMMENT 'Communication medium or forum through which the engagement activity was conducted, distinct from engagement type which describes the approach. [ENUM-REF-CANDIDATE',
    `engagement_date` DATE COMMENT 'The date when the engagement activity occurred or was initiated, representing the primary business event timestamp for this interaction.',
    `engagement_identifier` STRING COMMENT 'Human-readable unique business identifier for the engagement activity, used for external reference and reporting.. Valid values are `^ENG-[0-9]{8}-[A-Z0-9]{6}$`',
    `engagement_milestone` STRING COMMENT 'Key progress indicator or achievement reached during the engagement, used to track effectiveness and outcomes over time.',
    `engagement_objective` STRING COMMENT 'Specific goal or desired outcome that the fund seeks to achieve through this engagement activity, articulating the stewardship intent.',
    `engagement_outcome` STRING COMMENT 'Assessment of the result or impact achieved from the engagement activity, measuring the effectiveness of stewardship efforts. [ENUM-REF-CANDIDATE',
    `engagement_participants_external` STRING COMMENT 'Names or roles of external stakeholders from the investee entity or collaborative partners who participated in the engagement.',
    `engagement_participants_internal` STRING COMMENT 'Names or roles of internal fund personnel who participated in the engagement activity, supporting accountability and knowledge management.',
    `engagement_priority` STRING COMMENT 'Priority classification assigned to the engagement activity based on materiality, risk, and strategic importance to the funds stewardship objectives.. Valid values are `critical|high|medium|low`',
    `engagement_status` STRING COMMENT 'Current lifecycle status of the engagement activity indicating its progression through the stewardship workflow.. Valid values are `planned|initiated|in_progress|completed|suspended|closed`',
    `engagement_sub_topic` STRING COMMENT 'Detailed sub-category or specific aspect within the primary engagement topic, providing granular classification of the engagement focus area.',
    `engagement_summary` STRING COMMENT 'Narrative summary of the engagement discussion, key points raised, investee responses, and any commitments or action items agreed upon.',
    `engagement_topic` STRING COMMENT 'Primary Environmental, Social, and Governance (ESG) theme or issue that is the focus of the engagement activity. [ENUM-REF-CANDIDATE',
    `engagement_type` STRING COMMENT 'Classification of the engagement approach used: direct dialogue, collaborative initiative, escalation action, proxy voting, shareholder resolution filing, or public statement.. Valid values are `direct|collaborative|escalation|proxy_voting|shareholder_resolution|public_statement`',
    `escalation_level` STRING COMMENT 'Degree of escalation applied in the engagement, ranging from standard dialogue to formal actions such as voting against management or divestment consideration.',
    `esg_rating_at_engagement` STRING COMMENT 'MSCI ESG rating or equivalent third-party ESG assessment of the investee entity at the time of engagement, providing risk context.. Valid values are `^(AAA|AA|A|BBB|BB|B|CCC)$`',
    `holding_value_at_engagement` DECIMAL(18,2) COMMENT 'Market value of the funds holding in the investee entity at the time of engagement, providing materiality context for stewardship prioritization.',
    `holding_value_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the holding value amount, supporting multi-currency portfolio reporting.. Valid values are `^[A-Z]{3}$`',
    `investee_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the primary jurisdiction or headquarters location of the investee entity.. Valid values are `^[A-Z]{3}$`',
    `investee_entity_name` STRING COMMENT 'Legal name of the portfolio company, external manager, or other investee entity that is the subject of the engagement activity.',
    `investee_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the investee entity, providing globally unique identification for regulatory and reporting purposes.. Valid values are `^[A-Z0-9]{20}$`',
    `investee_sector` STRING COMMENT 'Industry sector classification of the investee entity using Global Industry Classification Standard (GICS) or equivalent taxonomy.',
    `is_active` BOOLEAN COMMENT 'Indicates whether this engagement activity record is currently active and valid, supporting logical deletion and historical record management.',
    `last_modified_by` STRING COMMENT 'User identifier or name of the individual who most recently modified this engagement activity record, supporting audit and accountability.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'System timestamp when this engagement activity record was most recently updated, enabling change tracking and version control.',
    `next_action` STRING COMMENT 'Planned follow-up activity or next step in the engagement process, supporting continuity and accountability in stewardship efforts.',
    `next_action_due_date` DATE COMMENT 'Target date by which the next engagement action or follow-up is scheduled to occur, enabling tracking of engagement cadence.',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage of the investee entitys equity or voting rights held by the fund at the time of engagement, indicating influence capacity.',
    `public_disclosure_flag` BOOLEAN COMMENT 'Indicates whether details of this engagement activity are subject to public disclosure under PRI reporting or other transparency commitments.',
    `sfdr_classification` STRING COMMENT 'EU SFDR article classification of the investment strategy or fund under which this engagement is conducted, supporting regulatory disclosure.. Valid values are `article_6|article_8|article_9`',
    `tcfd_alignment_flag` BOOLEAN COMMENT 'Indicates whether the engagement topic relates to TCFD climate risk disclosure or climate transition planning.',
    `un_global_compact_violation_flag` BOOLEAN COMMENT 'Indicates whether the engagement was triggered by or relates to a potential violation of UN Global Compact principles by the investee entity.',
    `voting_action_taken` BOOLEAN COMMENT 'Indicates whether proxy voting action was taken as part of or in connection with this engagement activity.',
    `voting_decision` STRING COMMENT 'The funds voting decision on the resolution associated with this engagement activity.. Valid values are `for|against|abstain|not_voted`',
    `voting_meeting_date` DATE COMMENT 'Date of the Annual General Meeting (AGM) or Extraordinary General Meeting (EGM) where voting action related to this engagement occurred.',
    `voting_resolution_description` STRING COMMENT 'Description of the shareholder resolution or management proposal that was the subject of voting action related to this engagement.',
    `created_by` STRING COMMENT 'User identifier or name of the individual who created this engagement activity record, supporting accountability and audit requirements.',
    CONSTRAINT pk_engagement_activity PRIMARY KEY(`engagement_activity_id`)
) COMMENT 'Transactional record of stewardship engagement interactions between the fund and investee companies or external managers. Captures engagement type (direct, collaborative, escalation), engagement topic (climate, board diversity, executive pay, supply';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`engagement_objective` (
    `engagement_objective_id` BIGINT COMMENT 'Unique identifier for the engagement objective record.',
    `engagement_activity_id` BIGINT COMMENT 'Reference to the parent engagement program or activity under which this objective is defined.',
    `engagement_engagement_activity_id` BIGINT COMMENT 'Reference to the parent engagement program or activity under which this objective is defined.',
    `engagement_esg_policy_id` BIGINT COMMENT 'Reference to the ESG policy or responsible investment policy that mandates or guides this engagement objective.',
    `engagement_related_policy_esg_policy_id` BIGINT COMMENT 'Reference to the ESG policy or responsible investment policy that mandates or guides this engagement objective.',
    `owner_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Engagement objectives require accountable owners to drive progress. PRI reporting requires tracking who owns each engagement objective for stewardship accountability.',
    `achievement_date` DATE COMMENT 'Actual date on which the objective was achieved, if applicable.',
    `approval_date` DATE COMMENT 'Date on which the engagement objective was formally approved for execution.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee that approved the engagement objective.',
    `baseline_date` DATE COMMENT 'Date on which the baseline value was measured or established.',
    `baseline_value` DECIMAL(18,2) COMMENT 'Baseline or starting value of the target metric at the time the objective was established.',
    `closure_date` DATE COMMENT 'Date on which the objective was formally closed, whether achieved, not achieved, or cancelled.',
    `closure_reason` STRING COMMENT 'Explanation for why the objective was closed, including achievement rationale or reasons for non-achievement or cancellation.',
    `collaboration_initiative_name` STRING COMMENT 'Name of the external collaborative engagement initiative or coalition, if applicable, such as Climate Action 100+ or Investor Alliance for Human Rights.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the engagement objective record was first created in the system.',
    `data_source` STRING COMMENT 'Source system or provider from which objective data and progress metrics are obtained, such as MSCI ESG, Bloomberg, or internal stewardship platform.',
    `engagement_approach` STRING COMMENT 'Method or strategy employed to achieve the objective, such as direct dialogue, collaborative engagement, proxy voting, or public advocacy.. Valid values are `direct|collaborative|proxy_voting|public_statement|divestment_threat`',
    `engagement_objective_status` STRING COMMENT 'Current lifecycle status of the engagement objective, tracking progress from definition through completion. [ENUM-REF-CANDIDATE: draft|active|on_track|at_risk|achieved|not_achieved|deferred|cancelled — 8 candidates stripped; promote to reference product]',
    `escalation_level` STRING COMMENT 'Current escalation level of the engagement, indicating intensity of stewardship actions taken.. Valid values are `initial|moderate|elevated|maximum`',
    `esg_issue` STRING COMMENT 'Specific ESG issue or topic that the objective targets, such as climate risk, board diversity, labor practices, or supply chain transparency.',
    `esg_pillar` STRING COMMENT 'Primary ESG pillar that this objective addresses: environmental, social, governance, or integrated across multiple pillars.. Valid values are `environmental|social|governance|integrated`',
    `external_collaboration_flag` BOOLEAN COMMENT 'Indicates whether this objective is pursued in collaboration with other institutional investors or engagement coalitions.',
    `investee_country` STRING COMMENT 'Primary country of domicile or operations for the investee entity, using ISO 3166-1 alpha-3 country codes.. Valid values are `^[A-Z]{3}$`',
    `investee_entity_name` STRING COMMENT 'Name of the investee company, fund manager, or counterparty that is the subject of this engagement objective.',
    `investee_lei` STRING COMMENT 'Legal Entity Identifier of the investee entity subject to this engagement objective.. Valid values are `^[A-Z0-9]{20}$`',
    `investee_sector` STRING COMMENT 'Industry sector classification of the investee entity, using standard classification systems such as GICS or NAICS.',
    `last_modified_by` STRING COMMENT 'Identifier of the user or system that last modified the engagement objective record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the engagement objective record was last updated.',
    `last_review_date` DATE COMMENT 'Date of the most recent formal review of progress toward the objective.',
    `milestone_description` STRING COMMENT 'Specific, measurable, achievable, relevant, and time-bound (SMART) milestone definition for tracking progress toward the objective.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal review of progress toward the objective.',
    `notes` STRING COMMENT 'Additional free-text notes, observations, or context regarding the engagement objective and its execution.',
    `objective_code` STRING COMMENT 'Business-assigned unique code or identifier for the engagement objective.',
    `objective_description` STRING COMMENT 'Detailed description of the engagement objective, including the desired outcome and rationale.',
    `objective_name` STRING COMMENT 'Short descriptive name or title of the engagement objective.',
    `objective_type` STRING COMMENT 'Classification of the engagement objective by its strategic or operational nature.. Valid values are `strategic|tactical|operational|compliance|thematic|ad_hoc`',
    `owner_department` STRING COMMENT 'Department or business unit to which the objective owner belongs, such as ESG team, investment team, or stewardship team.',
    `priority_level` STRING COMMENT 'Priority classification of the objective within the engagement program, indicating urgency and resource allocation.. Valid values are `critical|high|medium|low`',
    `progress_percentage` DECIMAL(5,2) COMMENT 'Estimated percentage completion of the objective, ranging from 0.00 to 100.00 percent.',
    `public_disclosure_flag` BOOLEAN COMMENT 'Indicates whether the objective and its progress are disclosed publicly in stewardship reports or PRI reporting.',
    `review_frequency_months` BIGINT COMMENT 'Frequency in months at which progress toward the objective is formally reviewed and reported.',
    `sfdr_principal_adverse_impact` STRING COMMENT 'SFDR Principal Adverse Impact indicator that this objective addresses, if applicable.',
    `target_completion_date` DATE COMMENT 'Target date by which the engagement objective is expected to be achieved.',
    `target_metric` STRING COMMENT 'Quantitative or qualitative metric used to measure achievement of the objective, such as GHG emissions reduction percentage, board independence ratio, or policy adoption.',
    `target_value` DECIMAL(18,2) COMMENT 'Specific target value or threshold for the metric that defines successful achievement of the objective.',
    `tcfd_alignment` STRING COMMENT 'Alignment of the objective with TCFD disclosure pillars: governance, strategy, risk management, or metrics and targets.. Valid values are `governance|strategy|risk_management|metrics_targets|not_applicable`',
    `un_sdg_alignment` STRING COMMENT 'UN Sustainable Development Goals that this objective supports, specified as goal numbers or names.',
    `created_by` STRING COMMENT 'Identifier of the user or system that created the engagement objective record.',
    CONSTRAINT pk_engagement_objective PRIMARY KEY(`engagement_objective_id`)
) COMMENT 'Master record of structured engagement objectives and milestones set for each investee company or manager engagement program. Captures objective description, target ESG issue (E/S/G pillar), SMART milestone definition, target completion date, priority';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`proxy_vote_record` (
    `proxy_vote_record_id` BIGINT COMMENT 'Unique identifier for the proxy vote record. Primary key for this transactional voting record.',
    `esg_policy_id` BIGINT COMMENT 'Foreign key linking to esg.policy. Business justification: Proxy votes are cast according to voting policies. The policy_reference STRING can be removed as the FK provides the authoritative link to the policy.',
    `holding_id` BIGINT COMMENT 'Reference to the investment holding position for which this proxy vote was cast.',
    `instrument_id` BIGINT COMMENT 'Foreign key linking to trade.instrument. Business justification: Proxy votes are cast on specific securities. Linking to instrument master enables corporate governance analysis, voting pattern reporting by security type, and integration with trading data',
    `issuer_esg_rating_id` BIGINT COMMENT 'Foreign key linking to esg.issuer_esg_rating. Business justification: Proxy votes are cast at companies with ESG ratings. The issuer_name and issuer_lei are operational identifiers for matching, not redundant.',
    `approval_date` DATE COMMENT 'Date on which the vote decision was formally approved.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee that approved the vote decision.',
    `ballot_reference` STRING COMMENT 'Unique identifier for the ballot or voting card submitted for this meeting.',
    `climate_alignment_flag` BOOLEAN COMMENT 'Indicates whether the resolution relates to climate change alignment and net-zero transition goals (True) or not (False).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this proxy vote record was first created in the system.',
    `custodian_name` STRING COMMENT 'Name of the custodian bank or institution holding the shares and facilitating the proxy vote.',
    `disclosure_date` DATE COMMENT 'Date on which the proxy vote record was publicly disclosed or reported.',
    `engagement_activity_flag` BOOLEAN COMMENT 'Indicates whether this vote was preceded by direct engagement with the investee company (True) or not (False).',
    `esg_relevance_flag` BOOLEAN COMMENT 'Indicates whether this resolution had material ESG implications (True) or not (False).',
    `esg_theme` STRING COMMENT 'Primary ESG theme associated with the resolution: Climate Change, Board Diversity, Executive Pay, Human Rights, Labor Standards, or Anti-Corruption.. Valid values are `Climate Change|Board Diversity|Executive Pay|Human Rights|Labor Standards|Anti-Corruption`',
    `glass_lewis_recommendation` STRING COMMENT 'Voting recommendation provided by Glass Lewis proxy advisory service.. Valid values are `For|Against|Abstain|Withhold`',
    `iss_recommendation` STRING COMMENT 'Voting recommendation provided by ISS proxy advisory service.. Valid values are `For|Against|Abstain|Withhold`',
    `issuer_lei` STRING COMMENT '20-character Legal Entity Identifier for the investee company issuer.. Valid values are `^[A-Z0-9]{20}$`',
    `issuer_name` STRING COMMENT 'Legal name of the investee company holding the shareholder meeting.',
    `last_modified_by` STRING COMMENT 'User or system identifier that last modified this proxy vote record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this proxy vote record was last updated.',
    `management_recommendation` STRING COMMENT 'Voting recommendation provided by the investee company management.. Valid values are `For|Against|Abstain`',
    `meeting_date` DATE COMMENT 'Date on which the shareholder meeting took place.',
    `meeting_location` STRING COMMENT 'Physical or virtual location where the shareholder meeting was held.',
    `meeting_outcome` STRING COMMENT 'Final outcome of the resolution at the shareholder meeting: Passed, Failed, or Withdrawn.. Valid values are `Passed|Failed|Withdrawn`',
    `meeting_type` STRING COMMENT 'Type of shareholder meeting: Annual General Meeting (AGM), Extraordinary General Meeting (EGM), Special, or Class meeting.. Valid values are `AGM|EGM|Special|Class`',
    `notes` STRING COMMENT 'Additional free-text notes or comments related to the proxy vote decision or execution.',
    `proxy_agent_name` STRING COMMENT 'Name of the third-party proxy voting service or agent used to execute the vote (e.g., Broadridge, ISS ProxyExchange).',
    `public_disclosure_required` BOOLEAN COMMENT 'Indicates whether this proxy vote must be publicly disclosed per regulatory or policy requirements (True) or not (False).',
    `record_date` DATE COMMENT 'Date on which shareholders of record were eligible to vote at the meeting.',
    `regulatory_filing_reference` STRING COMMENT 'Reference number or identifier for any regulatory filing associated with this proxy vote disclosure.',
    `resolution_category` STRING COMMENT 'High-level category of the resolution: Board Election, Executive Compensation, Audit, Capital Structure, Mergers and Acquisitions (M&A), Environmental Social and Governance (ESG), or Shareholder Proposal.',
    `resolution_description` STRING COMMENT 'Full text or summary description of the resolution being voted on.',
    `resolution_number` STRING COMMENT 'Sequential number or identifier of the resolution item on the meeting agenda.',
    `resolution_type` STRING COMMENT 'Indicates whether the resolution was proposed by Management or by a Shareholder.. Valid values are `Management|Shareholder`',
    `security_identifier` STRING COMMENT 'Unique identifier for the security (ISIN, CUSIP, SEDOL) of the investee company whose meeting is being voted on.',
    `security_identifier_type` STRING COMMENT 'Type of security identifier used (ISIN, CUSIP, SEDOL, TICKER, LEI).. Valid values are `ISIN|CUSIP|SEDOL|TICKER|LEI`',
    `shares_voted` DECIMAL(18,4) COMMENT 'Number of shares voted on this resolution by the fund.',
    `vote_alignment_with_iss` BOOLEAN COMMENT 'Indicates whether the vote cast was aligned with ISS recommendation (True) or not (False).',
    `vote_alignment_with_management` BOOLEAN COMMENT 'Indicates whether the vote cast was aligned with management recommendation (True) or not (False).',
    `vote_confirmation_number` STRING COMMENT 'Confirmation or reference number received upon successful vote submission.',
    `vote_direction` STRING COMMENT 'Direction of the vote cast: For, Against, Abstain, Withhold, or Do Not Vote.. Valid values are `For|Against|Abstain|Withhold|Do Not Vote`',
    `vote_execution_method` STRING COMMENT 'Method by which the vote was submitted: Electronic platform, Paper ballot, Proxy Agent, or Direct submission.. Valid values are `Electronic|Paper|Proxy Agent|Direct`',
    `vote_rationale` STRING COMMENT 'Detailed explanation and justification for the vote direction taken, aligned with proxy voting policy and ESG considerations.',
    `vote_recommendation_source` STRING COMMENT 'Source of the voting recommendation consulted: Institutional Shareholder Services (ISS), Glass Lewis, Internal research, Management recommendation, or Other.. Valid values are `ISS|Glass Lewis|Internal|Management|Other`',
    `vote_rejection_reason` STRING COMMENT 'Reason provided if the vote was rejected by the custodian or proxy agent (e.g., late submission, insufficient shares).',
    `vote_status` STRING COMMENT 'Current status of the proxy vote: Submitted, Confirmed, Rejected, Pending, or Cancelled.. Valid values are `Submitted|Confirmed|Rejected|Pending|Cancelled`',
    `vote_submission_date` DATE COMMENT 'Date on which the proxy vote was submitted to the custodian or proxy agent.',
    `votes_against_percentage` DECIMAL(5,2) COMMENT 'Percentage of total votes cast against the resolution at the meeting.',
    `votes_for_percentage` DECIMAL(5,2) COMMENT 'Percentage of total votes cast in favor of the resolution at the meeting.',
    `voting_power_percentage` DECIMAL(5,2) COMMENT 'Percentage of total outstanding shares represented by the shares voted, indicating voting power.',
    `created_by` STRING COMMENT 'User or system identifier that created this proxy vote record.',
    CONSTRAINT pk_proxy_vote_record PRIMARY KEY(`proxy_vote_record_id`)
) COMMENT 'SSOT transactional record of proxy voting decisions cast at investee company shareholder meetings, including meeting date, resolution category, vote direction, and rationale. Governed by proxy_vote_policy guidelines.';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`pri_reporting_submission` (
    `pri_reporting_submission_id` BIGINT COMMENT 'Unique identifier for the PRI reporting submission record.',
    `framework_id` BIGINT COMMENT 'Foreign key linking to esg.framework. Business justification: PRI reporting submissions are made under the PRI framework. This also connects the previously siloed pri_reporting_submission product.',
    `approval_date` DATE COMMENT 'The date on which this submission response was formally approved for submission to PRI.',
    `assessment_band` STRING COMMENT 'The overall assessment band awarded by PRI for the module (e.g., Five Stars, Four Stars, Three Stars, Two Stars, One Star).. Valid values are `Five Stars|Four Stars|Three Stars|Two Stars|One Star`',
    `assessment_score` STRING COMMENT 'The assessment score awarded by PRI for this indicator (e.g., A+, A, B, C, D, E) based on the quality and comprehensiveness of the response.. Valid values are `^[A-E]+?$`',
    `asset_class` STRING COMMENT 'The asset class to which this indicator response applies (e.g., Public Equities, Private Equity, Real Estate, Infrastructure, Fixed Income, Natural Resources).',
    `aum_coverage_amount` DECIMAL(20,2) COMMENT 'The total AUM (in base currency) covered by this indicator response, representing the asset base to which the ESG practice applies.',
    `aum_coverage_percentage` DECIMAL(5,2) COMMENT 'The percentage of total AUM covered by this indicator response (0.00 to 100.00).',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this submission record was first created in the system.',
    `data_quality_score` DECIMAL(3,2) COMMENT 'Internal data quality score for this submission (0.00 to 1.00) reflecting completeness, accuracy, and timeliness of the underlying data.',
    `data_source` STRING COMMENT 'The internal or external system from which the response data was sourced (e.g., BlackRock Aladdin ESG Analytics, MSCI ESG Ratings, Internal ESG Database).',
    `indicator_code` STRING COMMENT 'The specific indicator code within the module (e.g., SG01, LE02.1, PE03) as defined by PRI reporting taxonomy.. Valid values are `^[A-Z]{2,3}[0-9]{1,2}(.[0-9]{1,2})?$`',
    `indicator_description` STRING COMMENT 'Full text description of the indicator question or requirement being addressed in this submission.',
    `last_modified_by` STRING COMMENT 'Identifier of the user or system that last modified this submission record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The timestamp when this submission record was last modified.',
    `module_name` STRING COMMENT 'The specific PRI reporting module being submitted (e.g., Strategy & Governance, Listed Equity, Private Equity, Real Estate, Infrastructure, Fixed Income).. Valid values are `Strategy & Governance|Listed Equity|Private Equity|Real Estate|Infrastructure|Fixed Income`',
    `notes` STRING COMMENT 'Additional notes, comments, or context related to this submission response for internal reference.',
    `peer_comparison_percentile` DECIMAL(5,2) COMMENT 'The percentile ranking of this submission relative to peer signatories in the same asset class and region (0.00 to 100.00).',
    `prepared_by` STRING COMMENT 'Name or identifier of the individual or team responsible for preparing this submission response.',
    `public_disclosure_flag` BOOLEAN COMMENT 'Indicates whether this submission response is approved for public disclosure in the PRI Transparency Report (True/False).',
    `reporting_year` BIGINT COMMENT 'The calendar year for which the PRI assessment is being reported (e.g., 2023).',
    `response_type` STRING COMMENT 'The type of response required for this indicator (e.g., Quantitative, Qualitative, Binary, Multiple Choice, Descriptive).. Valid values are `Quantitative|Qualitative|Binary|Multiple Choice|Descriptive`',
    `response_unit` STRING COMMENT 'Unit of measure for quantitative responses (e.g., USD millions, percentage, tonnes CO2e, number of holdings).',
    `response_value` DECIMAL(18,2) COMMENT 'The actual response value submitted for this indicator. May contain numeric values, text descriptions, or categorical selections depending on response_type.',
    `reviewed_by` STRING COMMENT 'Name or identifier of the individual or team who reviewed and approved this submission response before submission.',
    `submission_date` DATE COMMENT 'The date on which this submission was formally submitted to PRI.',
    `submission_deadline` DATE COMMENT 'The deadline date by which this submission must be completed and submitted to PRI.',
    `submission_reference_number` STRING COMMENT 'External reference number assigned by PRI for this submission (e.g., PRI-2023-A1B2C3D4).. Valid values are `^PRI-[0-9]{4}-[A-Z0-9]{8}$`',
    `submission_status` STRING COMMENT 'Current lifecycle status of this submission record (e.g., Draft, In Review, Submitted, Validated, Published, Rejected).. Valid values are `Draft|In Review|Submitted|Validated|Published|Rejected`',
    `supporting_evidence_url` STRING COMMENT 'URL or document reference to supporting evidence, policies, or documentation that substantiates this submission response.',
    `transparency_report_url` STRING COMMENT 'URL to the published PRI Transparency Report containing this submission data.',
    `validation_errors` STRING COMMENT 'Description of any validation errors or warnings identified by PRI during submission review.',
    `validation_status` STRING COMMENT 'Status of PRI validation checks for this submission (e.g., Pending, Passed, Failed, Waived).. Valid values are `Pending|Passed|Failed|Waived`',
    `created_by` STRING COMMENT 'Identifier of the user or system that created this submission record.',
    CONSTRAINT pk_pri_reporting_submission PRIMARY KEY(`pri_reporting_submission_id`)
) COMMENT 'Transactional record of annual PRI (Principles for Responsible Investment) Assessment submissions. Captures reporting year, module name (Strategy & Governance, Listed Equity, Private Equity, Real Estate, Infrastructure, Fixed Income), indicator code';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`controversy` (
    `controversy_id` BIGINT COMMENT 'Unique identifier for the ESG controversy record.',
    `assigned_analyst_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: ESG controversy monitoring requires analyst assignment for investigation and escalation. Pension funds track which employee is responsible for monitoring each controversy for workload',
    `esg_policy_id` BIGINT COMMENT 'Foreign key linking to esg.policy. Business justification: Controversies are assessed against responsible investment policies to determine escalation and response actions.',
    `exclusion_list_id` BIGINT COMMENT 'Foreign key linking to esg.exclusion_list. Business justification: Severe controversies can trigger exclusion list placement. The exclusion_list_flag indicates this relationship exists, the FK provides the direct link.',
    `issuer_esg_rating_id` BIGINT COMMENT 'Foreign key linking to esg.issuer_esg_rating. Business justification: Linking controversy to issuer_esg_rating associates controversies with the issuer’s ESG rating, supporting risk analysis.',
    `analyst_notes` STRING COMMENT 'Internal notes and commentary from the ESG analyst or investment team regarding the controversy.',
    `controversy_category` STRING COMMENT 'Detailed sub-category or theme of the controversy within the primary type.',
    `controversy_code` STRING COMMENT 'Business-assigned unique code for the controversy event.. Valid values are `^[A-Z0-9]{6,20}$`',
    `controversy_status` STRING COMMENT 'Current lifecycle status of the controversy within the investment risk management process.. Valid values are `identified|under_review|escalated|monitoring|resolved|closed`',
    `controversy_type` STRING COMMENT 'Primary classification of the controversy event.. Valid values are `environmental_incident|labor_violation|governance_failure|human_rights|product_safety|corruption`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the controversy record was first created in the system.',
    `data_source` STRING COMMENT 'Primary source of the controversy information (e.g., MSCI ESG, RepRisk, media, regulatory filing).',
    `divestment_deadline` DATE COMMENT 'Target date by which divestment or exposure reduction should be completed if recommended.',
    `divestment_recommendation` STRING COMMENT 'Investment action recommendation resulting from the controversy assessment.. Valid values are `none|monitor|reduce_exposure|full_divestment`',
    `engagement_initiated_flag` BOOLEAN COMMENT 'Indicates whether active engagement with the investee has been initiated in response to the controversy.',
    `engagement_status` STRING COMMENT 'Current status of the engagement activity with the investee regarding the controversy.. Valid values are `not_started|in_progress|awaiting_response|completed|unsuccessful`',
    `escalation_date` DATE COMMENT 'Date when the controversy was escalated to Investment Committee or senior management.',
    `escalation_flag` BOOLEAN COMMENT 'Indicates whether the controversy has been escalated to Investment Committee or senior management.',
    `exclusion_list_flag` BOOLEAN COMMENT 'Indicates whether the investee has been added to the exclusion list as a result of this controversy.',
    `financial_penalty_amount` DECIMAL(18,2) COMMENT 'Monetary value of fines or penalties imposed on the investee related to the controversy.',
    `geographic_location` STRING COMMENT 'ISO 3166-1 alpha-3 country code where the controversy incident occurred.. Valid values are `^[A-Z]{3}$`',
    `ghg_emissions_related` BOOLEAN COMMENT 'Indicates whether the controversy involves greenhouse gas emissions or climate impact.',
    `ic_decision` STRING COMMENT 'Investment Committee decision or recommendation regarding the controversy and investee.',
    `ic_decision_date` DATE COMMENT 'Date when the Investment Committee made its decision regarding the controversy.',
    `ic_submission_flag` BOOLEAN COMMENT 'Indicates whether the controversy has been formally submitted to the Investment Committee for review.',
    `identification_date` DATE COMMENT 'Date when the controversy was first identified and recorded by the ESG team.',
    `impact_assessment_summary` STRING COMMENT 'Summary of the assessed impact of the controversy on stakeholders, environment, and investment value.',
    `incident_date` DATE COMMENT 'Date when the controversy event or incident occurred or was first reported publicly.',
    `investee_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier of the investee company or fund manager subject to the controversy.. Valid values are `^[A-Z0-9]{20}$`',
    `investee_name` STRING COMMENT 'Legal or common name of the investee company or fund manager involved in the controversy.',
    `investee_response_summary` STRING COMMENT 'Summary of the investees response, remediation actions, or public statement regarding the controversy.',
    `is_active` BOOLEAN COMMENT 'Indicates whether the controversy record is currently active and under monitoring.',
    `last_modified_by` STRING COMMENT 'User identifier of the person who last modified the controversy record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the controversy record was last updated.',
    `media_url` STRING COMMENT 'URL link to the primary media article or public disclosure reporting the controversy.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next review of the controversy status and investee response.',
    `penalty_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the financial penalty amount.. Valid values are `^[A-Z]{3}$`',
    `proxy_voting_action` STRING COMMENT 'Proxy voting action taken or recommended in response to the controversy.. Valid values are `no_action|vote_against|abstain|withhold|escalate`',
    `regulatory_action_flag` BOOLEAN COMMENT 'Indicates whether regulatory or legal action has been taken against the investee.',
    `regulatory_authority` STRING COMMENT 'Name of the regulatory body or authority involved in the controversy investigation or enforcement.',
    `resolution_date` DATE COMMENT 'Date when the controversy was resolved or closed by the investee or regulatory authority.',
    `sector_classification` STRING COMMENT 'Industry sector classification of the investee (e.g., GICS, NAICS).',
    `severity_level` STRING COMMENT 'Assessed severity of the controversy impact on stakeholders and reputation.. Valid values are `low|moderate|high|severe|critical`',
    `sfdr_pai_indicator` STRING COMMENT 'SFDR Principal Adverse Impact indicator code associated with the controversy.',
    `source_reference_code` STRING COMMENT 'External reference identifier from the data source provider for traceability.',
    `tcfd_climate_risk_flag` BOOLEAN COMMENT 'Indicates whether the controversy relates to climate-related physical or transition risk.',
    `un_global_compact_violation` BOOLEAN COMMENT 'Indicates whether the controversy constitutes a violation of UN Global Compact principles.',
    `watch_list_flag` BOOLEAN COMMENT 'Indicates whether the investee has been placed on the ESG watch list due to this controversy.',
    `created_by` STRING COMMENT 'User identifier of the person who created the controversy record.',
    CONSTRAINT pk_controversy PRIMARY KEY(`controversy_id`)
) COMMENT 'Master record of ESG controversies, adverse-media events, and the resulting watch/escalation status flagged against investee companies or fund managers. Captures controversy type (environmental incident, labor violation, governance failure';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`due_diligence` (
    `due_diligence_id` BIGINT COMMENT 'Unique identifier for the ESG due diligence assessment record. Primary key for the due diligence product.',
    `climate_scenario_id` BIGINT COMMENT 'Foreign key linking to esg.climate_scenario. Business justification: Linking due_diligence to climate_scenario provides a reference to the scenario used in the assessment, enabling traceability of stress‑testing data.',
    `data_provider_id` BIGINT COMMENT 'Foreign key linking to esg.data_provider. Business justification: Linking due_diligence to data_provider allows attribution of ESG ratings to the external vendor, supporting provenance and audit.',
    `dd_engagement_id` BIGINT COMMENT 'Foreign key linking to diligence.dd_engagement. Business justification: ESG due_diligence records must link to master dd_engagement for integrated DD workflow. Enables consolidated DD status tracking and ensures ESG findings flow to IC submission package.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the investment deal or opportunity being evaluated through ESG due diligence.',
    `employee_id` BIGINT COMMENT 'Reference to the internal ESG specialist or analyst responsible for leading the due diligence assessment.',
    `esg_policy_id` BIGINT COMMENT 'Foreign key linking to esg.policy. Business justification: ESG due diligence assessments are conducted under responsible investment policies. Links DD to governing policy.',
    `exclusion_list_id` BIGINT COMMENT 'Foreign key linking to esg.exclusion_list. Business justification: Linking due_diligence to exclusion_list records the specific exclusion criteria applied during the assessment, enabling detailed reporting.',
    `issuer_esg_rating_id` BIGINT COMMENT 'Foreign key linking to esg.issuer_esg_rating. Business justification: Linking due_diligence to issuer_esg_rating associates the target issuer’s ESG rating with the assessment, providing context for risk scoring.',
    `lead_assessor_employee_id` BIGINT COMMENT 'Reference to the internal ESG specialist or analyst responsible for leading the due diligence assessment.',
    `opportunity_id` BIGINT COMMENT 'Reference to the investment deal or opportunity being evaluated through ESG due diligence.',
    `assessment_code` STRING COMMENT 'Unique business identifier for the ESG due diligence assessment, following format DD-ESG-NNNNNN.. Valid values are `^DD-ESG-[0-9]{6}$`',
    `assessment_status` STRING COMMENT 'Current lifecycle status of the ESG due diligence assessment process. [ENUM-REF-CANDIDATE: initiated|in_progress|pending_review|completed|approved|rejected|on_hold — 7 candidates stripped; promote to reference product]',
    `assessment_team_members` STRING COMMENT 'Comma-separated list of employee identifiers representing the full ESG due diligence assessment team.',
    `assessment_type` STRING COMMENT 'Category of ESG due diligence assessment based on the nature of the investment opportunity being evaluated.. Valid values are `new_investment|co_investment|fund_manager_selection|portfolio_company_review|follow_on_investment|secondary_transaction`',
    `asset_class` STRING COMMENT 'Investment asset class category to which the target entity or opportunity belongs. [ENUM-REF-CANDIDATE: public_equity|private_equity|real_estate|infrastructure|natural_resources|credit|fixed_income — 7 candidates stripped; promote to reference product]',
    `carbon_intensity_metric` STRING COMMENT 'Unit of measure for carbon intensity calculation, such as tCO2e per million revenue or tCO2e per unit produced.',
    `carbon_intensity_value` DECIMAL(18,4) COMMENT 'Calculated carbon intensity value for the target entity using the specified metric denominator.',
    `climate_risk_assessment` STRING COMMENT 'Assessment of physical and transition climate risks facing the target entity under TCFD framework.. Valid values are `low|moderate|high|critical`',
    `completion_date` DATE COMMENT 'Date when the ESG due diligence assessment was completed and finalized for Investment Committee review.',
    `controversy_description` STRING COMMENT 'Summary of material ESG controversies, legal disputes, or reputational issues identified during due diligence.',
    `controversy_level` STRING COMMENT 'Severity classification of ESG-related controversies or incidents involving the target entity.. Valid values are `none|low|moderate|high|severe`',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the ESG due diligence assessment record was first created in the system.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Assessment of the completeness and reliability of ESG data obtained during due diligence, on a 0-100 scale.',
    `engagement_priority_flag` BOOLEAN COMMENT 'Indicates whether the target entity has been flagged for active ESG engagement and stewardship activities post-investment.',
    `engagement_topics` STRING COMMENT 'Comma-separated list of ESG topics identified for active engagement with the target entity management or board.',
    `environmental_score` DECIMAL(5,2) COMMENT 'Environmental pillar score assessing climate risk, resource efficiency, pollution, and biodiversity impact.',
    `esg_overall_score` DECIMAL(5,2) COMMENT 'Composite ESG score assigned to the target entity, typically on a 0-100 scale, reflecting overall ESG performance.',
    `esg_rating_provider` STRING COMMENT 'Third-party ESG rating agency or internal methodology used to assess the target entity ESG performance. [ENUM-REF-CANDIDATE: msci|sustainalytics|refinitiv|sp_global|ftse_russell|internal|other — 7 candidates stripped; promote to reference product]',
    `esg_risk_rating` STRING COMMENT 'Categorical ESG risk classification indicating the severity of unmanaged ESG risks for the target entity.. Valid values are `negligible|low|medium|high|severe`',
    `exclusion_criteria_breached` STRING COMMENT 'Comma-separated list of specific exclusion criteria breached by the target entity, if applicable.',
    `exclusion_policy_breach_flag` BOOLEAN COMMENT 'Indicates whether the target entity breaches any of the pension funds ESG exclusion policies or criteria.',
    `external_advisor_name` STRING COMMENT 'Name of external ESG consultant or advisory firm engaged to support the due diligence assessment, if applicable.',
    `governance_score` DECIMAL(5,2) COMMENT 'Governance pillar score assessing board structure, executive compensation, shareholder rights, and business ethics.',
    `ic_decision` STRING COMMENT 'Final Investment Committee decision on the investment opportunity following ESG due diligence review.. Valid values are `approved|approved_with_conditions|rejected|deferred|withdrawn`',
    `ic_decision_date` DATE COMMENT 'Date when the Investment Committee rendered its final decision on the investment opportunity.',
    `ic_submission_date` DATE COMMENT 'Date when the ESG due diligence assessment was submitted to the Investment Committee for review and decision.',
    `initiation_date` DATE COMMENT 'Date when the ESG due diligence assessment was formally initiated and assigned to the assessment team.',
    `last_modified_by` STRING COMMENT 'User identifier of the individual who most recently modified the ESG due diligence assessment record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'System timestamp when the ESG due diligence assessment record was most recently updated.',
    `net_zero_commitment_flag` BOOLEAN COMMENT 'Indicates whether the target entity has made a public commitment to achieve net zero greenhouse gas emissions.',
    `net_zero_target_year` BIGINT COMMENT 'Calendar year by which the target entity has committed to achieve net zero emissions, if applicable.',
    `pri_signatory_flag` BOOLEAN COMMENT 'Indicates whether the target entity or fund manager is a signatory to the UN Principles for Responsible Investment.',
    `recommendation` STRING COMMENT 'Final ESG due diligence recommendation to the Investment Committee regarding the investment opportunity.. Valid values are `proceed|proceed_with_conditions|decline|further_review_required`',
    `recommendation_rationale` STRING COMMENT 'Detailed justification for the ESG due diligence recommendation, including key findings and risk mitigation strategies.',
    `scope_1_emissions_tco2e` DECIMAL(18,2) COMMENT 'Direct greenhouse gas emissions from sources owned or controlled by the target entity, measured in tonnes CO2 equivalent.',
    `scope_2_emissions_tco2e` DECIMAL(18,2) COMMENT 'Indirect greenhouse gas emissions from purchased electricity, steam, heating, and cooling consumed by the target entity.',
    `scope_3_emissions_tco2e` DECIMAL(18,2) COMMENT 'Indirect greenhouse gas emissions from value chain activities upstream and downstream of the target entity.',
    `sfdr_article_classification` STRING COMMENT 'SFDR classification indicating whether the investment promotes environmental or social characteristics or has sustainable investment as its objective.. Valid values are `article_6|article_8|article_9|not_applicable`',
    `social_score` DECIMAL(5,2) COMMENT 'Social pillar score assessing labor practices, human rights, community relations, and product responsibility.',
    `target_entity_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the primary jurisdiction of the investment target entity.. Valid values are `^[A-Z]{3}$`',
    `target_entity_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the investment target, enabling global entity identification.. Valid values are `^[A-Z0-9]{20}$`',
    `target_entity_name` STRING COMMENT 'Legal name of the investment target entity being assessed for ESG risks and opportunities.',
    `target_sector` STRING COMMENT 'Industry sector classification of the investment target entity using GICS or equivalent taxonomy.',
    `taxonomy_alignment_pct` DECIMAL(5,2) COMMENT 'Percentage of target entity revenue or activities aligned with EU Taxonomy for sustainable activities.',
    `un_global_compact_violation_flag` BOOLEAN COMMENT 'Indicates whether the target entity has been identified as violating UN Global Compact principles on human rights, labor, environment, or anti-corruption.',
    `created_by` STRING COMMENT 'User identifier of the individual who created the ESG due diligence assessment record in the system.',
    CONSTRAINT pk_due_diligence PRIMARY KEY(`due_diligence_id`)
) COMMENT 'Transactional record of ESG due diligence assessments conducted during investment evaluation for new deals, co-investments, and external manager selections.';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`kpi_target` (
    `kpi_target_id` BIGINT COMMENT 'Unique identifier for the ESG KPI target record.',
    `framework_id` BIGINT COMMENT 'Foreign key linking to esg.framework. Business justification: KPI targets align to ESG frameworks (PRI, TCFD, etc.). The alignment_framework STRING can be removed as the FK provides the authoritative link.',
    `holding_id` BIGINT COMMENT 'Reference to a specific portfolio holding if the KPI target is set at the individual investment level.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio to which this KPI target applies.',
    `achievement_status` STRING COMMENT 'Current assessment of progress toward the KPI target, indicating whether achievement is on track, at risk, off track, already achieved, or not yet started.. Valid values are `on_track|at_risk|off_track|achieved|not_started`',
    `approval_date` DATE COMMENT 'Date on which the KPI target was formally approved by the Investment Committee or ESG governance body.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee that approved the KPI target.',
    `asset_class` STRING COMMENT 'Asset class to which this KPI target applies, enabling asset-class-level ESG performance tracking.. Valid values are `public_equities|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `baseline_value` DECIMAL(18,4) COMMENT 'Starting or baseline value of the KPI against which progress toward the target is measured.',
    `baseline_year` BIGINT COMMENT 'Calendar year in which the baseline value was established, serving as the reference point for target achievement.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the KPI target record was first created in the system.',
    `data_source` STRING COMMENT 'Primary data source or provider used to measure progress against the KPI target, such as MSCI ESG, Bloomberg, or issuer disclosures.',
    `effective_date` DATE COMMENT 'Date from which the KPI target becomes active and performance tracking begins.',
    `escalation_threshold_pct` DECIMAL(5,2) COMMENT 'Percentage deviation from the target trajectory that triggers escalation to senior management or the Investment Committee.',
    `expiry_date` DATE COMMENT 'Date on which the KPI target expires or is superseded, marking the end of its active tracking period.',
    `interim_target_value` DECIMAL(18,4) COMMENT 'Intermediate target value set for a milestone year between the baseline and final target year.',
    `interim_target_year` BIGINT COMMENT 'Calendar year for the interim target milestone, enabling phased progress tracking.',
    `is_active` BOOLEAN COMMENT 'Indicates whether the KPI target is currently active and being tracked, or has been archived or superseded.',
    `kpi_category` STRING COMMENT 'High-level category classifying the KPI into environmental, social, governance, climate, diversity, or health and safety domains.. Valid values are `environmental|social|governance|climate|diversity|health_safety`',
    `kpi_code` STRING COMMENT 'Standardized code identifying the specific ESG KPI being targeted.',
    `kpi_name` STRING COMMENT 'Human-readable name of the ESG KPI, such as carbon intensity, board diversity percentage, renewable energy percentage, water intensity, or employee safety rate.',
    `kpi_subcategory` STRING COMMENT 'Detailed subcategory providing granular classification of the KPI within its primary category.',
    `last_measured_value` DECIMAL(18,4) COMMENT 'Most recent measured value of the KPI, used to assess current progress toward the target.',
    `last_measurement_date` DATE COMMENT 'Date on which the most recent KPI measurement was taken.',
    `last_modified_by` STRING COMMENT 'Identifier of the user or system that last modified the KPI target record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the KPI target record was most recently modified.',
    `methodology` STRING COMMENT 'Description of the methodology used to set the KPI target, including calculation approach, data sources, and assumptions.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal review of the KPI target and its progress.',
    `notes` STRING COMMENT 'Free-text field for additional context, commentary, or qualitative information about the KPI target and its progress.',
    `owner` STRING COMMENT 'Name or identifier of the individual, team, or department responsible for achieving the KPI target.',
    `paris_alignment_flag` BOOLEAN COMMENT 'Indicates whether the KPI target is aligned with the Paris Agreement climate goals, typically 1.5 or 2 degrees Celsius warming scenarios.',
    `progress_pct` DECIMAL(5,2) COMMENT 'Percentage of progress achieved toward the KPI target, calculated as the ratio of improvement to total required improvement.',
    `public_disclosure_required` BOOLEAN COMMENT 'Indicates whether the KPI target and its progress must be publicly disclosed in regulatory filings or sustainability reports.',
    `reporting_frequency` STRING COMMENT 'Frequency at which progress against the KPI target is reported to stakeholders and governance bodies.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `review_frequency_months` BIGINT COMMENT 'Frequency in months at which the KPI target is reviewed for progress and potential adjustment.',
    `sbti_validated_flag` BOOLEAN COMMENT 'Indicates whether the KPI target has been validated by the Science Based Targets initiative as science-based.',
    `target_scope` STRING COMMENT 'Scope level at which the KPI target is set, such as entire portfolio, specific asset class, individual holding, or fund.. Valid values are `portfolio|asset_class|holding|fund`',
    `target_status` STRING COMMENT 'Current lifecycle status of the KPI target, indicating whether it is in draft, active tracking, achieved, missed, suspended, or cancelled.. Valid values are `draft|active|achieved|missed|suspended|cancelled`',
    `target_type` STRING COMMENT 'Classification of the target as absolute reduction, intensity-based, percentage improvement, or binary achievement.. Valid values are `absolute|intensity|percentage|binary`',
    `target_unit` STRING COMMENT 'Unit of measure for the target value, such as percentage, tonnes CO2e per million revenue, or incidents per employee.',
    `target_value` DECIMAL(18,4) COMMENT 'Numeric target value for the KPI that the portfolio, asset class, or holding is expected to achieve.',
    `target_year` BIGINT COMMENT 'Calendar year by which the KPI target is expected to be achieved.',
    `created_by` STRING COMMENT 'Identifier of the user or system that created the KPI target record.',
    CONSTRAINT pk_kpi_target PRIMARY KEY(`kpi_target_id`)
) COMMENT 'Master record of ESG key performance indicator (KPI) targets set at the portfolio, asset class, or individual holding level. Captures KPI name, KPI category (carbon intensity, board diversity %, renewable energy %, water intensity, employee safety rate)';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`kpi_measurement` (
    `kpi_measurement_id` BIGINT COMMENT 'Unique identifier for the ESG KPI measurement record.',
    `data_provider_id` BIGINT COMMENT 'Foreign key linking to esg.data_provider. Business justification: KPI measurement data is sourced from external data providers. The data_provider STRING can be removed as the FK provides the authoritative link.',
    `kpi_kpi_target_id` BIGINT COMMENT 'Reference to the ESG KPI definition being measured.',
    `kpi_target_id` BIGINT COMMENT 'Foreign key linking to esg.kpi_target. Business justification: KPI measurements track progress against KPI targets. The target_value on measurement is the point-in-time target, the FK links to the full target record.',
    `portfolio_holding_id` BIGINT COMMENT 'Reference to the specific portfolio holding for which this KPI is measured.',
    `portfolio_id` BIGINT COMMENT 'Reference to the portfolio for which this KPI is measured at aggregate level.',
    `actual_value` DECIMAL(20,6) COMMENT 'The actual measured value of the KPI for the specified period.',
    `approval_date` DATE COMMENT 'The date on which the measurement was approved for official reporting.',
    `approval_status` STRING COMMENT 'The approval status of the measurement for official reporting purposes.. Valid values are `pending|approved|rejected|under_review`',
    `approved_by` STRING COMMENT 'The name or identifier of the person who approved the measurement for reporting.',
    `asset_class` STRING COMMENT 'The asset class category to which the measured holding belongs. [ENUM-REF-CANDIDATE: public_equity|private_equity|real_estate|infrastructure|natural_resources|credit|fixed_income — 7 candidates stripped; promote to reference product]',
    `baseline_value` DECIMAL(20,6) COMMENT 'The baseline or reference value against which progress is measured over time.',
    `baseline_year` BIGINT COMMENT 'The year from which the baseline value was established for comparison purposes.',
    `calculation_method` STRING COMMENT 'The specific calculation method applied to derive the KPI value from raw data.. Valid values are `direct|attribution|normalization|aggregation|weighted_average`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this measurement record was first created in the system.',
    `currency_code` STRING COMMENT 'The ISO 4217 three-letter currency code if the KPI measurement is expressed in monetary terms.. Valid values are `^[A-Z]{3}$`',
    `data_coverage_percentage` DECIMAL(5,2) COMMENT 'The percentage of the portfolio or holding for which actual data was available (vs. estimated or proxied).',
    `data_quality_flag` BOOLEAN COMMENT 'A categorical flag indicating the overall quality level of the measurement data.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'A numerical score representing the quality and reliability of the measurement data, typically on a scale of 0-100.',
    `data_source_type` STRING COMMENT 'The type of data source used to obtain the KPI measurement.. Valid values are `reported|estimated|modeled|third_party|proxy`',
    `exception_flag` BOOLEAN COMMENT 'Indicates whether this measurement represents an exception or anomaly requiring attention.',
    `exception_reason` STRING COMMENT 'Explanation of why this measurement was flagged as an exception.',
    `geographic_scope` STRING COMMENT 'The geographic region or country to which this measurement applies.',
    `gri_indicator_code` STRING COMMENT 'The GRI indicator code that this measurement corresponds to, if applicable.',
    `last_modified_by` STRING COMMENT 'The identifier of the user or system that last modified this measurement record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The timestamp when this measurement record was last updated.',
    `materiality_assessment` STRING COMMENT 'Assessment of whether this KPI measurement is material to investment decision-making or reporting.. Valid values are `material|non_material|under_review`',
    `measurement_date` DATE COMMENT 'The date on which the KPI measurement was taken or observed.',
    `measurement_frequency` STRING COMMENT 'The frequency at which this KPI is measured and reported.. Valid values are `daily|weekly|monthly|quarterly|annually|ad_hoc`',
    `measurement_methodology` STRING COMMENT 'Description of the methodology or approach used to measure or calculate the KPI value.',
    `measurement_notes` STRING COMMENT 'Additional notes, comments, or context regarding the KPI measurement.',
    `measurement_status` STRING COMMENT 'The current status of the KPI measurement in its lifecycle.. Valid values are `measured|estimated|projected|pending|verified|rejected`',
    `on_track_flag` BOOLEAN COMMENT 'Boolean indicator of whether the KPI measurement is on track to meet its target.',
    `progress_to_target_percentage` DECIMAL(10,4) COMMENT 'The percentage of progress achieved toward the target value from the baseline.',
    `reporting_period_end_date` DATE COMMENT 'The end date of the reporting period for which this KPI measurement applies.',
    `reporting_period_start_date` DATE COMMENT 'The start date of the reporting period for which this KPI measurement applies.',
    `sasb_metric_code` STRING COMMENT 'The SASB metric code that this measurement corresponds to, if applicable.',
    `sector_classification` STRING COMMENT 'The industry sector classification of the asset or holding being measured.',
    `sfdr_pai_indicator` STRING COMMENT 'The SFDR PAI indicator code that this measurement corresponds to, if applicable.',
    `target_value` DECIMAL(20,6) COMMENT 'The target or benchmark value that the KPI is measured against.',
    `tcfd_alignment_flag` BOOLEAN COMMENT 'Indicates whether this measurement aligns with TCFD disclosure requirements.',
    `unit_of_measure` STRING COMMENT 'The unit in which the KPI value is expressed (e.g., tCO2e for emissions, percentage for ratios). [ENUM-REF-CANDIDATE: tCO2e|MWh|m3|percentage|score|count|currency|ratio — 8 candidates stripped; promote to reference product]',
    `variance_percentage` DECIMAL(10,4) COMMENT 'The variance expressed as a percentage of the target value.',
    `variance_value` DECIMAL(20,6) COMMENT 'The calculated variance between actual and target values (actual minus target).',
    `verification_body` STRING COMMENT 'The name of the independent third-party organization that verified the measurement.',
    `verification_date` DATE COMMENT 'The date on which the measurement was verified by an independent party.',
    `verification_status` STRING COMMENT 'Indicates whether the measurement has been independently verified or assured.. Valid values are `verified|unverified|pending_verification|rejected`',
    `created_by` STRING COMMENT 'The identifier of the user or system that created this measurement record.',
    CONSTRAINT pk_kpi_measurement PRIMARY KEY(`kpi_measurement_id`)
) COMMENT 'Transactional record of periodic ESG KPI actuals measured against targets at the holding or portfolio level. Captures measurement date, KPI reference, actual value, unit of measure, variance from target, data source, measurement methodology, data quality';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`integration_checklist` (
    `integration_checklist_id` BIGINT COMMENT 'Unique identifier for the ESG integration checklist record. Primary key for the integration checklist entity.',
    `assigned_to_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: ESG integration checklists in deal process require assignment to specific analysts. Tracks who is responsible for completing ESG due diligence items before Investment Committee.',
    `dd_engagement_id` BIGINT COMMENT 'Foreign key linking to diligence.dd_engagement. Business justification: ESG integration checklists track ESG factor integration during investment process. Linking to dd_engagement enables tracking checklist completion as part of DD workflow and IC',
    `deal_opportunity_id` BIGINT COMMENT 'Identifier of the deal or transaction in the origination pipeline associated with this ESG integration checklist.',
    `esg_benchmark_id` BIGINT COMMENT 'Foreign key linking to esg.esg_benchmark. Business justification: Linking integration_checklist to esg_benchmark records the benchmark used during the ESG integration process, enabling traceability.',
    `esg_policy_id` BIGINT COMMENT 'Foreign key linking to esg.policy. Business justification: Integration checklists implement policy requirements during investment evaluation. Links checklist to governing policy.',
    `exclusion_list_id` BIGINT COMMENT 'Foreign key linking to esg.exclusion_list. Business justification: Integration checklists check investments against exclusion lists. The exclusion_criteria_breached and exclusion_details are assessment results, the FK links to the exclusion list checked.',
    `ic_decision_id` BIGINT COMMENT 'Foreign key linking to compliance.ic_decision. Business justification: ESG integration checklists are reviewed during investment committee meetings. The IC decision records which ESG checklist was considered when approving/rejecting investments.',
    `investment_id` BIGINT COMMENT 'Identifier of the investment opportunity or holding to which this ESG integration checklist applies.',
    `opportunity_id` BIGINT COMMENT 'Identifier of the deal or transaction in the origination pipeline associated with this ESG integration checklist.',
    `approval_date` DATE COMMENT 'Date when the completed ESG integration checklist was formally approved by the designated reviewer or governance body.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual who formally approved the ESG integration checklist.',
    `asset_class` STRING COMMENT 'Primary asset class category of the investment being assessed through this ESG integration checklist. [ENUM-REF-CANDIDATE: public_equity|private_equity|real_estate|infrastructure|natural_resources|credit|fixed_income|multi_asset — 8 candidates stripped',
    `checklist_identifier` STRING COMMENT 'Business-readable unique identifier or reference code for the checklist instance, used for tracking and reporting purposes.',
    `checklist_status` STRING COMMENT 'Current lifecycle status of the ESG integration checklist indicating progress through the assessment workflow. [ENUM-REF-CANDIDATE: not_started|in_progress|completed|approved|rejected|pending_review|overdue — 7 candidates stripped; promote to reference',
    `checklist_type` STRING COMMENT 'Category of ESG integration checklist defining the stage in the investment lifecycle where ESG factors are assessed. [ENUM-REF-CANDIDATE',
    `completed_items` BIGINT COMMENT 'Number of checklist items that have been completed and assessed as of the current status.',
    `completion_date` DATE COMMENT 'Date when the ESG integration checklist was fully completed and all required items were assessed.',
    `completion_percentage` DECIMAL(5,2) COMMENT 'Percentage of checklist items completed, calculated as completed items divided by total items, expressed as a percentage.',
    `controversy_level` STRING COMMENT 'Severity level of ESG controversies associated with the investment, based on third-party data and internal assessment.. Valid values are `none|low|medium|high|severe`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the ESG integration checklist record was first created in the system.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Assessment of the quality and completeness of ESG data available for the checklist, expressed as a percentage score.',
    `data_source` STRING COMMENT 'Primary source of ESG data used to complete the integration checklist, such as third-party providers or direct issuer disclosure.',
    `document_reference_url` STRING COMMENT 'URL or file path to the detailed ESG integration checklist document, supporting evidence, or assessment report.',
    `due_date` DATE COMMENT 'Target date by which the ESG integration checklist must be completed to meet investment governance requirements.',
    `engagement_priority` STRING COMMENT 'Priority level assigned to engagement activities required based on the severity of ESG issues identified.. Valid values are `low|medium|high|critical`',
    `engagement_required` BOOLEAN COMMENT 'Flag indicating whether active engagement with the investee entity is required to address ESG concerns identified in the checklist.',
    `environmental_score` DECIMAL(5,2) COMMENT 'Numerical score representing the environmental pillar assessment from the ESG integration checklist, typically on a 0-100 scale.',
    `exclusion_criteria_breached` BOOLEAN COMMENT 'Flag indicating whether the investment breaches any ESG exclusion criteria defined in the responsible investment policy.',
    `exclusion_details` STRING COMMENT 'Description of specific exclusion criteria breached, including policy references and severity of the breach.',
    `governance_score` DECIMAL(5,2) COMMENT 'Numerical score representing the governance pillar assessment from the ESG integration checklist, typically on a 0-100 scale.',
    `ic_conditions` STRING COMMENT 'Specific conditions or requirements imposed by the Investment Committee related to ESG factors that must be met before investment execution.',
    `ic_decision` STRING COMMENT 'Investment Committee decision regarding the investment based on the ESG integration checklist findings.. Valid values are `approved|rejected|conditional_approval|deferred|not_submitted`',
    `ic_submission_date` DATE COMMENT 'Date when the ESG integration checklist was submitted to the Investment Committee as part of the investment approval process.',
    `investment_stage` STRING COMMENT 'Stage in the investment lifecycle at which this ESG integration checklist is being conducted. [ENUM-REF-CANDIDATE: origination|screening|due_diligence|ic_approval|execution|holding|monitoring|exit — 8 candidates stripped; promote to reference product]',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the ESG integration checklist record was last updated or modified.',
    `material_esg_risks_identified` BOOLEAN COMMENT 'Flag indicating whether material ESG risks were identified during the checklist assessment that require mitigation or escalation.',
    `methodology_version` STRING COMMENT 'Version identifier of the ESG integration methodology or checklist template used for this assessment.',
    `mitigation_actions_required` BOOLEAN COMMENT 'Flag indicating whether specific mitigation actions or remediation steps are required based on the checklist findings.',
    `mitigation_plan` STRING COMMENT 'Description of planned actions to address identified ESG risks or deficiencies, including timelines and responsible parties.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next ESG integration checklist review or reassessment, typically for ongoing monitoring of held investments.',
    `notes` STRING COMMENT 'Additional comments, observations, or context related to the ESG integration checklist assessment and findings.',
    `overall_esg_rating` STRING COMMENT 'Aggregated ESG rating or score assigned to the investment based on the checklist assessment results. [ENUM-REF-CANDIDATE: AAA|AA|A|BBB|BB|B|CCC|not_rated — 8 candidates stripped; promote to reference product]',
    `paris_alignment_flag` BOOLEAN COMMENT 'Flag indicating whether the investment is aligned with Paris Agreement climate goals and net-zero transition pathways.',
    `review_frequency_months` BIGINT COMMENT 'Frequency in months at which the ESG integration checklist should be reviewed and updated for ongoing investments.',
    `reviewer` STRING COMMENT 'Name or identifier of the individual responsible for reviewing and approving the completed ESG integration checklist.',
    `risk_summary` STRING COMMENT 'Narrative summary of key ESG risks identified through the checklist assessment, including severity and potential impact.',
    `sfdr_classification` STRING COMMENT 'Sustainable Finance Disclosure Regulation article classification applicable to this investment based on ESG integration assessment.. Valid values are `article_6|article_8|article_9|not_applicable`',
    `social_score` DECIMAL(5,2) COMMENT 'Numerical score representing the social pillar assessment from the ESG integration checklist, typically on a 0-100 scale.',
    `tcfd_alignment_flag` BOOLEAN COMMENT 'Flag indicating whether the investment aligns with Task Force on Climate-related Financial Disclosures recommendations.',
    `total_items` BIGINT COMMENT 'Total number of assessment items or questions included in this ESG integration checklist.',
    `un_global_compact_violation_flag` BOOLEAN COMMENT 'Flag indicating whether the investment involves entities with confirmed violations of UN Global Compact principles.',
    CONSTRAINT pk_integration_checklist PRIMARY KEY(`integration_checklist_id`)
) COMMENT 'Transactional record of ESG integration checklist completions embedded within the investment lifecycle (deal screening, IC memo, annual review). Captures checklist type (pre-investment screening, annual monitoring, exit review), completion date';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`net_zero_commitment` (
    `net_zero_commitment_id` BIGINT COMMENT 'Unique identifier for the net-zero commitment record.',
    `framework_id` BIGINT COMMENT 'Foreign key linking to esg.framework. Business justification: Net zero commitments align to frameworks like SBTi, NZAOA. The commitment_standard STRING can be removed as the FK provides the authoritative link.',
    `net_esg_policy_id` BIGINT COMMENT 'Reference to the ESG or climate policy that governs or supports this net-zero commitment.',
    `net_related_policy_esg_policy_id` BIGINT COMMENT 'Reference to the ESG or climate policy that governs or supports this net-zero commitment.',
    `approval_date` DATE COMMENT 'The date on which the net-zero commitment was formally approved by the Investment Committee or Board.',
    `approved_by` STRING COMMENT 'Name or identifier of the governance body or individual who approved the commitment, such as Investment Committee or Board of Directors.',
    `asset_class` STRING COMMENT 'The asset class to which this net-zero commitment applies, if scope is asset-class specific. [ENUM-REF-CANDIDATE: Public_Equities|Private_Equity|Real_Estate|Infrastructure|Natural_Resources|Credit|Multi_Asset|All — 8 candidates stripped; promote to',
    `base_year` BIGINT COMMENT 'The baseline year against which emissions reductions are measured, typically the year of initial emissions measurement.',
    `base_year_emissions_tco2e` DECIMAL(18,2) COMMENT 'Total greenhouse gas emissions in tonnes of carbon dioxide equivalent for the baseline year, covering applicable scopes.',
    `carbon_offset_allowed` BOOLEAN COMMENT 'Indicates whether carbon offsets or credits are permitted to meet the net-zero target, and under what conditions.',
    `carbon_removal_allowed` BOOLEAN COMMENT 'Indicates whether carbon removal technologies or nature-based solutions are permitted to neutralize residual emissions.',
    `commitment_code` STRING COMMENT 'Business identifier code for the net-zero commitment, used for external reference and reporting.. Valid values are `^[A-Z0-9_-]{3,20}$`',
    `commitment_name` STRING COMMENT 'Descriptive name of the net-zero commitment initiative or program.',
    `commitment_owner` STRING COMMENT 'Name or department of the internal owner responsible for managing and delivering the net-zero commitment.',
    `commitment_scope` STRING COMMENT 'The scope of the commitment, indicating whether it applies to the total portfolio, specific asset class, sector, geography, or fund.. Valid values are `Total_Portfolio|Asset_Class|Sector|Geography|Fund`',
    `commitment_status` STRING COMMENT 'Current lifecycle status of the net-zero commitment. [ENUM-REF-CANDIDATE: Draft|Approved|Active|Under_Review|Suspended|Achieved|Superseded — 7 candidates stripped; promote to reference product]',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this net-zero commitment record was first created in the system.',
    `decarbonization_strategy` STRING COMMENT 'High-level description of the strategy to achieve the net-zero commitment, including engagement, divestment, green investment, and transition finance approaches.',
    `divestment_threshold_defined` BOOLEAN COMMENT 'Indicates whether specific divestment thresholds or criteria have been defined as part of the commitment strategy.',
    `document_url` STRING COMMENT 'URL or document reference to the formal commitment document, public disclosure, or detailed strategy documentation.',
    `effective_date` DATE COMMENT 'The date from which the net-zero commitment becomes effective and operational.',
    `engagement_priority` BOOLEAN COMMENT 'Indicates whether active engagement with investee companies is a priority strategy for achieving this commitment.',
    `external_verification_required` BOOLEAN COMMENT 'Indicates whether external third-party verification or assurance of emissions data and progress is required.',
    `financed_emissions_methodology` STRING COMMENT 'The methodology used to calculate financed emissions for portfolio holdings, such as Partnership for Carbon Accounting Financials (PCAF) or SBTi Financial Institutions standard.. Valid values are `PCAF|TCFD|SBTi_FI|Custom|Other`',
    `geographic_scope` STRING COMMENT 'Geographic region or country scope of the commitment, using ISO 3166 country codes or regional groupings.',
    `green_investment_target_pct` DECIMAL(5,2) COMMENT 'Target percentage of portfolio allocated to green or climate-aligned investments as part of the net-zero strategy.',
    `interim_reduction_target_pct` DECIMAL(5,2) COMMENT 'The percentage reduction in greenhouse gas emissions targeted for the interim target year, relative to the baseline year.',
    `interim_target_year` BIGINT COMMENT 'The year by which the interim decarbonization target is to be achieved, typically 2025, 2030, or 2035.',
    `is_active` BOOLEAN COMMENT 'Indicates whether this net-zero commitment record is currently active and in use.',
    `last_modified_by` STRING COMMENT 'User or system identifier of the person or process that last modified this record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The timestamp when this net-zero commitment record was last modified or updated.',
    `last_review_date` DATE COMMENT 'The date of the most recent review of the commitment progress and strategy.',
    `net_zero_definition` STRING COMMENT 'The specific definition of net-zero used for this commitment, including treatment of residual emissions, carbon offsets, and removals.',
    `net_zero_target_year` BIGINT COMMENT 'The year by which net-zero greenhouse gas emissions are targeted to be achieved, typically 2050.',
    `next_review_date` DATE COMMENT 'The scheduled date for the next review of the commitment progress and strategy.',
    `notes` STRING COMMENT 'Additional notes, context, or commentary regarding the net-zero commitment, including assumptions, limitations, or special considerations.',
    `paris_alignment_flag` BOOLEAN COMMENT 'Indicates whether the commitment is explicitly aligned with the goals of the Paris Agreement on climate change.',
    `public_disclosure_required` BOOLEAN COMMENT 'Indicates whether public disclosure of the commitment and progress is required under regulatory or voluntary frameworks.',
    `reporting_frequency` STRING COMMENT 'The frequency at which progress against the net-zero commitment is reported to stakeholders and regulators.. Valid values are `Annual|Semi_Annual|Quarterly|Ad_Hoc`',
    `review_frequency_months` BIGINT COMMENT 'The frequency in months at which the commitment progress is reviewed and reported, typically annually or semi-annually.',
    `scope_1_included` BOOLEAN COMMENT 'Indicates whether Scope 1 direct emissions from owned or controlled sources are included in the commitment.',
    `scope_2_included` BOOLEAN COMMENT 'Indicates whether Scope 2 indirect emissions from purchased electricity, heat, or steam are included in the commitment.',
    `scope_3_included` BOOLEAN COMMENT 'Indicates whether Scope 3 indirect emissions from the value chain, including financed emissions, are included in the commitment.',
    `sector_classification` STRING COMMENT 'Industry sector classification if the commitment is sector-specific, using standard classification systems such as GICS or BICS.',
    `temperature_alignment_target` STRING COMMENT 'The global warming temperature pathway that the commitment is aligned with, typically 1.5 degrees Celsius consistent with the Paris Agreement.. Valid values are `1.5C|Well_Below_2C|2C|Other`',
    `verification_body` STRING COMMENT 'Name of the external third-party organization providing verification or assurance services for the commitment.',
    `created_by` STRING COMMENT 'User or system identifier of the person or process that created this record.',
    CONSTRAINT pk_net_zero_commitment PRIMARY KEY(`net_zero_commitment_id`)
) COMMENT 'Master record of the funds net-zero commitments and interim decarbonization targets at the total portfolio and asset class level. Captures commitment name, commitment standard (NZAOA, SBTi, IIGCC NZIF), base year emissions, interim target year, interim';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`esg_benchmark` (
    `esg_benchmark_id` BIGINT COMMENT 'Unique identifier for the ESG benchmark record. Primary key.',
    `framework_id` BIGINT COMMENT 'Foreign key linking to esg.framework. Business justification: Linking esg_benchmark to framework associates the benchmark with the governing ESG framework, supporting compliance reporting.',
    `administrator` STRING COMMENT 'Legal entity responsible for the administration and governance of the benchmark under applicable regulatory frameworks (e.g., EU Benchmark Regulation).',
    `approval_date` DATE COMMENT 'Date on which the benchmark was approved for use by the internal investment committee or governance authority.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee that approved the benchmark for use in portfolio management and reporting.',
    `approved_for_use_flag` BOOLEAN COMMENT 'Indicates whether the benchmark has been approved by internal investment committee or governance body for use in portfolio performance measurement and reporting.',
    `base_index_name` STRING COMMENT 'Name of the parent or underlying broad market index from which the ESG benchmark is derived (e.g., MSCI ACWI, S&P 500).',
    `benchmark_category` STRING COMMENT 'Asset class or market segment that the benchmark covers (e.g., Equity, Fixed Income, Multi-Asset, Real Estate, Infrastructure). [ENUM-REF-CANDIDATE: Equity|Fixed Income|Multi-Asset|Real Estate|Infrastructure|Private Markets|Broad Market|Sector-Specific —',
    `benchmark_code` STRING COMMENT 'Unique alphanumeric code assigned by the provider to identify the benchmark (e.g., MSCI ACWI ESG Leaders, FTSE4Good).',
    `benchmark_name` STRING COMMENT 'Full descriptive name of the ESG benchmark or index used for portfolio performance comparison.',
    `benchmark_type` STRING COMMENT 'Classification of the ESG benchmark methodology (e.g., ESG Leaders, Paris-Aligned, Climate Transition, Best-in-Class, Low Carbon). [ENUM-REF-CANDIDATE: ESG Leaders|Paris-Aligned|Climate Transition|Best-in-Class|Low Carbon|SRI|Thematic|Exclusionary — 8',
    `carbon_intensity_reduction_target_pct` DECIMAL(5,2) COMMENT 'Target percentage reduction in weighted average carbon intensity (WACI) relative to the base index (e.g., 30% lower carbon intensity than parent index).',
    `climate_alignment_target` STRING COMMENT 'Climate goal or temperature pathway the benchmark is designed to align with (e.g., Paris Agreement 1.5°C, Net Zero by 2050, 2°C scenario).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this benchmark record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the benchmark returns are denominated (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `data_source_url` STRING COMMENT 'Web address or hyperlink to the official benchmark methodology document, factsheet, or provider page.',
    `esg_benchmark_status` STRING COMMENT 'Current lifecycle status of the benchmark indicating whether it is actively maintained and available for use.. Valid values are `Active|Discontinued|Under Review|Suspended|Retired|Pending Launch`',
    `esg_methodology` STRING COMMENT 'Description of the ESG screening, scoring, or weighting methodology applied by the benchmark provider to construct the index.',
    `esg_rating_provider` STRING COMMENT 'Third-party ESG data or rating provider whose scores are used in the benchmark construction (e.g., MSCI ESG Research, Sustainalytics, ISS ESG).',
    `eu_climate_benchmark_flag` BOOLEAN COMMENT 'Indicates whether the benchmark is designated as an EU Climate Transition Benchmark (CTB) or EU Paris-Aligned Benchmark (PAB) under EU regulations.',
    `exclusion_criteria` STRING COMMENT 'List of sectors, activities, or controversies that result in exclusion from the benchmark (e.g., tobacco, weapons, thermal coal, UN Global Compact violators).',
    `fossil_fuel_exposure_limit_pct` DECIMAL(5,2) COMMENT 'Maximum allowable percentage of benchmark weight allocated to fossil fuel-related companies (e.g., 5% cap on coal, oil, gas producers).',
    `geographic_scope` STRING COMMENT 'Geographic coverage of the benchmark (e.g., Global, North America, Europe, Asia-Pacific, Emerging Markets). Use 3-letter country codes for single-country benchmarks.',
    `green_revenue_alignment_pct` DECIMAL(5,2) COMMENT 'Minimum percentage of constituent revenues that must be derived from green or sustainable activities as defined by EU Taxonomy or similar frameworks.',
    `inception_date` DATE COMMENT 'Date when the benchmark was first launched or calculated by the provider.',
    `last_modified_by` STRING COMMENT 'User identifier or system account that last modified this benchmark record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this benchmark record was last updated or modified.',
    `last_rebalance_date` DATE COMMENT 'Most recent date on which the benchmark was rebalanced or reconstituted by the provider.',
    `last_review_date` DATE COMMENT 'Most recent date on which the benchmark was reviewed for continued suitability and alignment with investment objectives.',
    `methodology_document_url` STRING COMMENT 'Direct link to the detailed methodology document published by the benchmark provider describing construction rules and ESG criteria.',
    `minimum_esg_rating` STRING COMMENT 'Minimum ESG rating threshold required for constituent inclusion in the benchmark (e.g., BBB or above on MSCI ESG scale).',
    `next_rebalance_date` DATE COMMENT 'Scheduled date for the next benchmark rebalancing or reconstitution event.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next internal review of the benchmark suitability and methodology alignment.',
    `notes` STRING COMMENT 'Additional free-text notes, comments, or observations regarding the benchmark selection, limitations, or special considerations for use.',
    `number_of_constituents` BIGINT COMMENT 'Total count of securities or holdings included in the benchmark as of the last rebalance date.',
    `pri_signatory_flag` BOOLEAN COMMENT 'Indicates whether the benchmark provider is a signatory to the UN Principles for Responsible Investment.',
    `provider` STRING COMMENT 'Organization that publishes and maintains the ESG benchmark (e.g., MSCI, FTSE Russell, S&P Dow Jones Indices). [ENUM-REF-CANDIDATE: MSCI|FTSE Russell|S&P Dow Jones|Bloomberg|Sustainalytics|ISS ESG|Refinitiv|STOXX|Other — 9 candidates stripped; promote to',
    `rebalancing_frequency` STRING COMMENT 'Frequency at which the benchmark constituents and weights are reviewed and rebalanced by the provider.. Valid values are `Daily|Weekly|Monthly|Quarterly|Semi-Annually|Annually`',
    `regulatory_authorization` STRING COMMENT 'Regulatory approval or registration status of the benchmark under applicable jurisdictions (e.g., EU BMR authorized, IOSCO compliant).',
    `review_frequency_months` BIGINT COMMENT 'Frequency in months at which the benchmark suitability and methodology are reviewed by internal governance (e.g., 12 for annual review, 36 for triennial).',
    `sfdr_classification` STRING COMMENT 'SFDR article classification of the benchmark indicating its sustainability characteristics (Article 6, 8, or 9 alignment).. Valid values are `Article 6|Article 8|Article 9|Not Classified`',
    `tcfd_alignment_flag` BOOLEAN COMMENT 'Indicates whether the benchmark methodology and disclosure practices align with TCFD recommendations for climate risk reporting.',
    `un_sdg_alignment` STRING COMMENT 'List of UN Sustainable Development Goals that the benchmark is designed to support or align with (e.g., SDG 7 Affordable Clean Energy, SDG 13 Climate Action).',
    `usage_scope` STRING COMMENT 'Description of the portfolios, mandates, or asset classes for which this benchmark is designated as the primary performance comparison standard.',
    `weighting_methodology` STRING COMMENT 'Method used to determine constituent weights in the benchmark (e.g., Market Capitalization, Equal Weight, ESG Score-Weighted, Carbon Efficiency). [ENUM-REF-CANDIDATE: Market Cap|Equal Weight|ESG Score|Carbon Efficiency|Fundamental|Factor-Based|Optimized —',
    `created_by` STRING COMMENT 'User identifier or system account that created this benchmark record.',
    CONSTRAINT pk_esg_benchmark PRIMARY KEY(`esg_benchmark_id`)
) COMMENT 'Reference catalogue of ESG benchmarks and indices used for portfolio ESG performance comparison. Captures benchmark name, benchmark provider (MSCI, FTSE Russell, S&P), benchmark type (ESG Leaders, Paris-Aligned, Climate Transition, Best-in-Class)';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`data_provider` (
    `data_provider_id` BIGINT COMMENT 'Unique identifier for the external ESG data provider or rating agency. Primary key.',
    `annual_subscription_cost` DECIMAL(15,2) COMMENT 'Total annual cost of the subscription or service agreement with the provider in the contract currency.',
    `api_endpoint_url` STRING COMMENT 'Base URL for the providers API endpoint if API delivery is used. Confidential operational information.',
    `approval_date` DATE COMMENT 'Date when the provider was approved for use by the investment committee or procurement authority.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee that approved the provider relationship.',
    `contract_end_date` DATE COMMENT 'Scheduled expiration or renewal date of the current contractual agreement. Null for evergreen contracts.',
    `contract_reference_number` STRING COMMENT 'Internal or external reference number for the master service agreement or subscription contract.',
    `contract_start_date` DATE COMMENT 'Effective start date of the current contractual agreement with the provider.',
    `cost_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the annual subscription cost (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `coverage_asset_classes` STRING COMMENT 'Asset classes covered by the providers data (e.g., public equities, corporate bonds, sovereign debt, private equity, real estate, infrastructure).',
    `coverage_geography` STRING COMMENT 'Geographic scope of the providers data coverage (e.g., global, North America, Europe, Asia-Pacific, emerging markets).',
    `coverage_issuer_count` BIGINT COMMENT 'Approximate number of unique issuers or entities covered by the providers data universe.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this provider record was first created in the system.',
    `data_delivery_frequency` STRING COMMENT 'Frequency at which data updates are delivered by the provider (real-time, daily, weekly, monthly, quarterly, annual, or on-demand). [ENUM-REF-CANDIDATE: real_time|daily|weekly|monthly|quarterly|annual|on_demand — 7 candidates stripped; promote to',
    `data_delivery_method` STRING COMMENT 'Primary method by which data is delivered from the provider (API, SFTP, web portal, email, vendor platform, or data feed).. Valid values are `api|sftp|portal|email|vendor_platform|data_feed`',
    `data_format` STRING COMMENT 'Technical format of delivered data (e.g., JSON, XML, CSV, Excel, Parquet, proprietary format).',
    `data_products_subscribed` STRING COMMENT 'Comma-separated list or description of specific data products, feeds, or services subscribed from this provider (e.g., ESG ratings, carbon data, controversy alerts, proxy research).',
    `data_quality_last_review_date` DATE COMMENT 'Date of the most recent internal data quality assessment or audit of the providers data.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Internal assessment score (0-100) reflecting the quality, completeness, and reliability of the providers data based on periodic reviews.',
    `data_usage_restrictions` STRING COMMENT 'Description of any contractual restrictions on data usage, redistribution, or publication imposed by the provider.',
    `headquarters_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the providers headquarters location.. Valid values are `^[A-Z]{3}$`',
    `last_modified_by` STRING COMMENT 'User identifier or system account that last modified this provider record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this provider record was last updated.',
    `lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the provider organization, enabling global entity identification.. Valid values are `^[A-Z0-9]{20}$`',
    `methodology_framework` STRING COMMENT 'Description or reference to the providers ESG assessment methodology, rating framework, or data collection approach.',
    `methodology_last_updated_date` DATE COMMENT 'Date when the provider last updated or revised their methodology framework.',
    `methodology_version` STRING COMMENT 'Version identifier of the current methodology or rating framework in use by the provider.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review of the provider relationship, data quality, or contract terms.',
    `notes` STRING COMMENT 'Free-text field for additional comments, special considerations, or operational notes about the provider.',
    `payment_terms` STRING COMMENT 'Description of payment terms and schedule (e.g., annual in advance, quarterly in arrears, monthly billing).',
    `portal_url` STRING COMMENT 'Web portal URL for accessing provider data, reports, or analytics tools.',
    `primary_contact_email` STRING COMMENT 'Email address of the primary contact for operational and commercial matters.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_contact_name` STRING COMMENT 'Full name of the primary relationship manager or account representative at the provider.',
    `primary_contact_phone` STRING COMMENT 'Telephone number of the primary contact for urgent escalations and support.',
    `provider_code` STRING COMMENT 'Short alphanumeric code uniquely identifying the provider (e.g., MSCI_ESG, SUSTAINALYTICS, ISS_ESG, REPRISK, CDP, BBGESG).. Valid values are `^[A-Z0-9_]{2,20}$`',
    `provider_name` STRING COMMENT 'Full legal or trading name of the ESG data provider or rating agency.',
    `provider_status` STRING COMMENT 'Current lifecycle status of the provider relationship (active, inactive, suspended, under review, or terminated).. Valid values are `active|inactive|suspended|under_review|terminated`',
    `provider_type` STRING COMMENT 'Classification of the providers primary service offering (rating agency, data vendor, research provider, index provider, disclosure platform, or multi-service).. Valid values are `rating_agency|data_vendor|research_provider|index_provider|disclosure_platform|multi_service`',
    `regulatory_alignment` STRING COMMENT 'Comma-separated list of regulatory frameworks or standards the providers data supports (e.g., SFDR, TCFD, PRI, EU Taxonomy, SASB, GRI).',
    `review_frequency_months` BIGINT COMMENT 'Frequency in months at which the provider relationship is reviewed (e.g., 12 for annual, 6 for semi-annual).',
    `sfdr_pai_coverage_flag` BOOLEAN COMMENT 'Indicates whether the provider supplies data for SFDR Principal Adverse Impact indicators (True/False).',
    `sftp_host` STRING COMMENT 'SFTP server hostname or IP address if SFTP delivery is used. Confidential operational information.',
    `sla_support_response_time_hours` BIGINT COMMENT 'Contractual maximum response time in hours for support requests or incidents.',
    `sla_uptime_percentage` DECIMAL(5,2) COMMENT 'Contractual service level agreement uptime commitment as a percentage (e.g., 99.5 for 99.5% uptime).',
    `tcfd_alignment_flag` BOOLEAN COMMENT 'Indicates whether the providers data is aligned with TCFD disclosure requirements (True/False).',
    `vendor_risk_last_assessment_date` DATE COMMENT 'Date of the most recent vendor risk assessment or due diligence review.',
    `vendor_risk_rating` STRING COMMENT 'Internal risk assessment rating for the provider based on operational, financial, and reputational risk (low, medium, high, or critical).. Valid values are `low|medium|high|critical`',
    `created_by` STRING COMMENT 'User identifier or system account that created this provider record.',
    CONSTRAINT pk_data_provider PRIMARY KEY(`data_provider_id`)
) COMMENT 'Reference master of external ESG data vendors and rating agencies contracted by the fund. Captures provider name (MSCI ESG, RepRisk, Sustainalytics, ISS ESG, CDP, Bloomberg ESG), data products subscribed, coverage universe (asset class, geography, issuer';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`watch_list` (
    `watch_list_id` BIGINT COMMENT 'Unique identifier for the ESG watch list record. Primary key for the watch list entity.',
    `controversy_id` BIGINT COMMENT 'Foreign key linking to esg.controversy. Business justification: Watch list placements are often triggered by controversies. The controversy_level and controversy_description on watch_list are summary fields, the FK links to the full controversy record.',
    `exclusion_list_id` BIGINT COMMENT 'Foreign key linking to esg.exclusion_list. Business justification: Watch list entries may be linked to exclusion list entries when an issuer is being monitored for potential exclusion. Natural escalation path.',
    `instrument_id` BIGINT COMMENT 'Foreign key linking to trade.instrument. Business justification: ESG watch list tracks securities under scrutiny for controversies or policy breaches. Linking to instrument enables pre-trade screening systems to flag/block orders on watched securities',
    `issuer_esg_rating_id` BIGINT COMMENT 'Foreign key linking to esg.issuer_esg_rating. Business justification: Watch list entries monitor issuers with ESG ratings. The esg_rating_current/previous are point-in-time values that should be retained for historical tracking.',
    `owner_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Watch list items require designated owners for ongoing monitoring and escalation decisions. Critical for risk management workflow and ensuring no items are orphaned.',
    `rule_id` BIGINT COMMENT 'Foreign key linking to compliance.rule. Business justification: ESG watch list placements trigger compliance rules (trading restrictions, pre-clearance requirements, disclosure obligations).',
    `approval_date` DATE COMMENT 'Date when the watch list placement was formally approved by the responsible committee or authority.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or committee that approved the watch list placement.',
    `watch_list_category` STRING COMMENT 'Primary category or reason for watch list placement: ESG rating deterioration, controversy, policy breach, regulatory violation, engagement escalation, or exclusion candidate.. Valid values are `esg_rating_deterioration|controversy|policy_breach|regulatory_violation|engagement_escalation|exclusion_candidate`',
    `closure_reason` STRING COMMENT 'Reason for closing or removing the entity from the watch list, such as issue resolved, position divested, or entity no longer held.',
    `controversy_description` STRING COMMENT 'Detailed description of the ESG controversy or incident that led to watch list placement, including nature, scope, and stakeholders affected.',
    `controversy_level` STRING COMMENT 'Severity level of ESG-related controversy associated with the entity: low, moderate, high, or severe.. Valid values are `low|moderate|high|severe`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the watch list record was first created in the system.',
    `data_source` STRING COMMENT 'Primary data source or system that provided the information triggering watch list placement, such as MSCI ESG, Bloomberg, or internal research.',
    `divestment_deadline` DATE COMMENT 'Target date by which divestment or position reduction must be completed if divestment has been recommended.',
    `divestment_recommendation_flag` BOOLEAN COMMENT 'Boolean flag indicating whether divestment or exclusion from portfolio has been recommended as a result of watch list review.',
    `divestment_status` STRING COMMENT 'Current status of divestment action: not applicable, planned, in progress, completed, or deferred.. Valid values are `not_applicable|planned|in_progress|completed|deferred`',
    `engagement_objective` STRING COMMENT 'Primary objective or goal of engagement with the entity on watch list, such as improving ESG disclosure, addressing controversy, or achieving policy compliance.',
    `engagement_status` STRING COMMENT 'Current status of active engagement with the entity on the watch list: not initiated, active, escalated, suspended, or completed.. Valid values are `not_initiated|active|escalated|suspended|completed`',
    `entity_lei` STRING COMMENT '20-character Legal Entity Identifier for the entity on watch list, enabling global entity identification.. Valid values are `^[A-Z0-9]{20}$`',
    `entity_name` STRING COMMENT 'Full legal or registered name of the entity placed on the ESG watch list.',
    `entity_type` STRING COMMENT 'Type of entity placed on the watch list: issuer, fund, manager, counterparty, security, or portfolio holding.. Valid values are `issuer|fund|manager|counterparty|security|portfolio_holding`',
    `escalation_level` STRING COMMENT 'Severity or priority level of the watch list entry: low, medium, high, or critical, determining urgency of response.. Valid values are `low|medium|high|critical`',
    `esg_rating_change_date` DATE COMMENT 'Date when the ESG rating change occurred that contributed to watch list placement.',
    `esg_rating_current` STRING COMMENT 'Current ESG rating of the entity at the time of watch list placement or most recent update, from provider such as MSCI, Sustainalytics, or internal rating.',
    `esg_rating_previous` STRING COMMENT 'Previous ESG rating before the deterioration or change that triggered watch list placement, enabling trend analysis.',
    `esg_rating_provider` STRING COMMENT 'Name of the ESG rating provider whose rating triggered or informed the watch list placement, such as MSCI ESG, Sustainalytics, or ISS ESG.',
    `ghg_emissions_intensity` DECIMAL(18,4) COMMENT 'Greenhouse gas emissions intensity metric for the entity, typically measured as tonnes of CO2 equivalent per million revenue or per unit of production.',
    `holding_value_at_placement` DECIMAL(18,2) COMMENT 'Market value of the holding or exposure to the entity at the time of watch list placement, used to assess materiality and portfolio impact.',
    `holding_value_currency` STRING COMMENT 'Three-letter ISO currency code for the holding value at placement, such as USD, EUR, GBP, or JPY.. Valid values are `^[A-Z]{3}$`',
    `identifier` STRING COMMENT 'Business-readable unique identifier or reference code for the watch list entry, used for external communication and reporting.',
    `issuer_country` STRING COMMENT 'Three-letter ISO country code representing the country of domicile or incorporation of the issuer.. Valid values are `^[A-Z]{3}$`',
    `last_modified_by` STRING COMMENT 'User identifier or system account that last modified the watch list record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the watch list record was last updated or modified.',
    `notes` STRING COMMENT 'Free-text field for additional context, observations, or commentary related to the watch list entry.',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage of ownership or voting rights held in the entity at the time of watch list placement, relevant for engagement and stewardship decisions.',
    `paris_alignment_flag` BOOLEAN COMMENT 'Boolean flag indicating whether the entity is aligned with Paris Agreement climate goals and net-zero pathways.',
    `placement_date` DATE COMMENT 'Date when the entity was formally placed on the ESG watch list.',
    `policy_breach_type` STRING COMMENT 'Type or category of policy breach that triggered watch list placement, such as exclusion criteria violation, engagement mandate breach, or climate target misalignment.',
    `policy_reference` STRING COMMENT 'Reference to the specific ESG policy, exclusion policy, or responsible investment policy that was breached or triggered the watch list placement.',
    `proxy_voting_restriction` STRING COMMENT 'Voting restriction or guideline applied to the entity on watch list: none, vote against management, abstain, or case-by-case review.. Valid values are `none|against_management|abstain|case_by_case`',
    `resolution_action` STRING COMMENT 'Specific action or milestone required to resolve the watch list issue and enable removal from watch list, such as rating upgrade, controversy resolution, or policy compliance.',
    `resolution_date` DATE COMMENT 'Date when the watch list issue was resolved and the entity was removed from active watch list status.',
    `review_date` DATE COMMENT 'Scheduled date for the next formal review of the watch list entry to assess status and determine next actions.',
    `review_frequency_months` BIGINT COMMENT 'Frequency in months for periodic review of the watch list entry, typically ranging from 1 to 12 months.',
    `sector_classification` STRING COMMENT 'Industry sector classification of the entity, typically using GICS, ICB, or internal taxonomy.',
    `security_identifier` STRING COMMENT 'Primary security identifier for the instrument on watch list, such as ISIN, CUSIP, or SEDOL.',
    `security_identifier_type` STRING COMMENT 'Type of security identifier used: ISIN, CUSIP, SEDOL, TICKER, or INTERNAL code.. Valid values are `ISIN|CUSIP|SEDOL|TICKER|INTERNAL`',
    `sfdr_classification` STRING COMMENT 'SFDR article classification of the fund or mandate associated with the watch list entity: Article 6, Article 8, or Article 9.. Valid values are `Article_6|Article_8|Article_9`',
    `tcfd_climate_risk_flag` BOOLEAN COMMENT 'Boolean flag indicating whether the entity has been identified as having material climate-related financial risk under TCFD framework.',
    `trigger_date` DATE COMMENT 'Date when the triggering event occurred that led to watch list placement.',
    `trigger_event` STRING COMMENT 'Specific event or incident that triggered the placement on the watch list, such as rating downgrade, controversy emergence, or policy violation.',
    `un_global_compact_violation_flag` BOOLEAN COMMENT 'Boolean flag indicating whether the entity has violated one or more of the UN Global Compact principles on human rights, labor, environment, or anti-corruption.',
    `watch_list_status` STRING COMMENT 'Current lifecycle status of the watch list entry: active, under review, escalated, resolved, or closed.. Valid values are `active|under_review|escalated|resolved|closed`',
    `created_by` STRING COMMENT 'User identifier or system account that created the watch list record.',
    CONSTRAINT pk_watch_list PRIMARY KEY(`watch_list_id`)
) COMMENT 'Master record of issuers, funds, or managers placed on formal ESG watch or review status due to deteriorating ESG ratings, controversy escalation, or policy breaches.';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`responsible_investment_report` (
    `responsible_investment_report_id` BIGINT COMMENT 'Unique identifier for the responsible investment report record.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: RI reports are public disclosures requiring formal approval. Pension funds must document who approved annual responsible investment reports for governance and regulatory compliance.',
    `composite_id` BIGINT COMMENT 'Foreign key linking to performance.composite. Business justification: Responsible investment reports must reference specific composites for AUM coverage and ESG performance disclosure.',
    `framework_id` BIGINT COMMENT 'Foreign key linking to esg.framework. Business justification: RI reports align to ESG frameworks (PRI, TCFD, SFDR). The regulatory_framework STRING can be removed as the FK provides the authoritative link.',
    `net_zero_commitment_id` BIGINT COMMENT 'Foreign key linking to esg.net_zero_commitment. Business justification: RI reports disclose net zero commitment progress. The net_zero_commitment_flag and net_zero_target_year are report-specific values, the FK links to the commitment record.',
    `superseded_report_responsible_investment_report_id` BIGINT COMMENT 'Identifier of the previous report that this report supersedes or replaces, if applicable.',
    `approval_date` DATE COMMENT 'Date on which the responsible investment report was formally approved by the Investment Committee or Board.',
    `asset_class_coverage` STRING COMMENT 'Asset classes covered by the responsible investment report, such as public equities, private equity, real estate, infrastructure, fixed income.',
    `assurance_level` STRING COMMENT 'Level of external assurance obtained for the report, if applicable.. Valid values are `limited|reasonable|not_applicable`',
    `assurance_provider_name` STRING COMMENT 'Name of the external assurance or audit provider, if applicable.',
    `aum_covered` DECIMAL(20,2) COMMENT 'Total assets under management covered by the responsible investment report, in the reporting currency.',
    `aum_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the AUM covered amount.. Valid values are `^[A-Z]{3}$`',
    `carbon_footprint_per_million_invested` DECIMAL(18,2) COMMENT 'Portfolio carbon footprint normalized per million units of currency invested, as disclosed in the report.',
    `climate_action_summary` STRING COMMENT 'Summary of climate-related actions, commitments, and progress during the reporting period.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the responsible investment report record was first created in the system.',
    `disclosure_level` STRING COMMENT 'Classification of the reports disclosure level, determining who may access the document.. Valid values are `public|confidential|restricted|internal`',
    `document_url` STRING COMMENT 'Web address or file path where the published responsible investment report document is stored or accessible.',
    `engagement_activity_summary` STRING COMMENT 'Summary of stewardship and engagement activities undertaken with investee companies during the reporting period.',
    `esg_integration_summary` STRING COMMENT 'High-level narrative summary of how ESG factors are integrated into investment decision-making during the reporting period.',
    `exclusion_criteria_summary` STRING COMMENT 'Summary of exclusion criteria applied to investments during the reporting period.',
    `exclusion_policy_applied_flag` BOOLEAN COMMENT 'Indicates whether exclusion policies were applied during the reporting period.',
    `external_assurance_obtained_flag` BOOLEAN COMMENT 'Indicates whether the report has been externally assured or audited by a third party.',
    `geographic_scope` STRING COMMENT 'Geographic scope of the investments covered by the report, such as global, regional, or country-specific.',
    `language` STRING COMMENT 'Two-letter ISO 639-1 language code indicating the primary language of the report.. Valid values are `^[a-z]{2}$`',
    `last_modified_by` STRING COMMENT 'Identifier of the user or system that last modified the responsible investment report record.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the responsible investment report record was last modified.',
    `net_zero_commitment_flag` BOOLEAN COMMENT 'Indicates whether the fund has made a formal net zero emissions commitment as disclosed in the report.',
    `net_zero_target_year` BIGINT COMMENT 'Target year for achieving net zero emissions, if a commitment has been made.',
    `next_publication_date` DATE COMMENT 'Expected or scheduled date for the next responsible investment report publication.',
    `notes` STRING COMMENT 'Additional notes, comments, or context related to the responsible investment report.',
    `prepared_by` STRING COMMENT 'Name or identifier of the individual or team responsible for preparing the report.',
    `pri_signatory_status` STRING COMMENT 'Indicates whether the fund is a signatory to the UN Principles for Responsible Investment at the time of report publication.. Valid values are `signatory|non_signatory|pending`',
    `proxy_voting_summary` STRING COMMENT 'Summary of proxy voting activities and outcomes during the reporting period.',
    `publication_date` DATE COMMENT 'Date on which the responsible investment report was officially published to external stakeholders.',
    `report_code` STRING COMMENT 'Business identifier or reference code for the responsible investment report, used for external citation and tracking.',
    `report_status` STRING COMMENT 'Current lifecycle status of the responsible investment report.. Valid values are `draft|under_review|approved|published|archived|superseded`',
    `report_title` STRING COMMENT 'Full title of the responsible investment report as published.',
    `report_type` STRING COMMENT 'Classification of the responsible investment report by regulatory or stakeholder framework.. Valid values are `annual_ri_report|pri_transparency_report|tcfd_disclosure|sfdr_periodic_disclosure|esg_stewardship_report|climate_action_report`',
    `report_year` BIGINT COMMENT 'Calendar or fiscal year to which the responsible investment report primarily relates.',
    `reporting_period_end_date` DATE COMMENT 'End date of the period covered by the responsible investment report.',
    `reporting_period_start_date` DATE COMMENT 'Start date of the period covered by the responsible investment report.',
    `reviewed_by` STRING COMMENT 'Name or identifier of the individual or committee that reviewed the report prior to approval.',
    `sfdr_classification` STRING COMMENT 'SFDR article classification applicable to the fund or mandate covered by the report.. Valid values are `article_6|article_8|article_9|not_applicable`',
    `submission_date` DATE COMMENT 'Date on which the report was submitted to the relevant regulatory or industry body.',
    `target_audience` STRING COMMENT 'Primary intended audience for the responsible investment report.. Valid values are `beneficiaries|regulators|public|investment_committee|board|external_stakeholders`',
    `tcfd_alignment_flag` BOOLEAN COMMENT 'Indicates whether the report is aligned with TCFD recommendations.',
    `total_ghg_emissions_tco2e` DECIMAL(18,2) COMMENT 'Total portfolio greenhouse gas emissions reported in the responsible investment report, measured in tonnes of CO2 equivalent.',
    `version_number` STRING COMMENT 'Version identifier for the report, used to track revisions and updates.',
    `created_by` STRING COMMENT 'Identifier of the user or system that created the responsible investment report record.',
    CONSTRAINT pk_responsible_investment_report PRIMARY KEY(`responsible_investment_report_id`)
) COMMENT 'Transactional record of formal responsible investment (RI) reports published by the fund for external stakeholders—beneficiaries, regulators, and the public.';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`pai_indicator` (
    `pai_indicator_id` BIGINT COMMENT 'Unique identifier for the PAI indicator record.',
    `credit_issuer_id` BIGINT COMMENT 'Unique identifier for the issuer associated with the PAI indicator.',
    `framework_id` BIGINT COMMENT 'Foreign key linking to esg.framework. Business justification: PAI (Principal Adverse Impact) indicators are mandated by the SFDR framework. Links PAI tracking to the governing framework.',
    `sfdr_disclosure_id` BIGINT COMMENT 'Foreign key linking to compliance.sfdr_disclosure. Business justification: PAI (Principal Adverse Impact) indicators are SFDR-mandated metrics that must be disclosed. Each PAI measurement directly supports a specific SFDR disclosure filing.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the PAI indicator record was created.',
    `indicator_code` STRING COMMENT 'Alphanumeric code identifying the specific PAI indicator.. Valid values are `^[A-Z0-9]{3,10}$`',
    `indicator_description` STRING COMMENT 'Detailed description of the PAI indicators purpose and scope.',
    `indicator_name` STRING COMMENT 'Human-readable name of the PAI indicator.',
    `indicator_pai_disclosure_date` DATE COMMENT 'Date when the PAI indicator was disclosed to regulators or investors.',
    `indicator_pai_disclosure_document_url` STRING COMMENT 'URL to the official disclosure document for the PAI indicator.',
    `indicator_pai_disclosure_notes` STRING COMMENT 'Additional notes or comments regarding the PAI disclosure.',
    `indicator_pai_disclosure_required` BOOLEAN COMMENT 'Flag indicating if the PAI indicator requires disclosure under SFDR Article 7.',
    `indicator_pai_disclosure_status` STRING COMMENT 'Current status of the PAI disclosure process.. Valid values are `required|not_required|pending`',
    `indicator_source` STRING COMMENT 'Source of the indicator data (e.g., MSCI, Bloomberg).',
    `indicator_source_date` DATE COMMENT 'Date when the source data was published or updated.',
    `indicator_source_version` STRING COMMENT 'Version or release of the source data used for the indicator.',
    `indicator_type` STRING COMMENT 'Classification of the PAI indicator as environmental, social, or governance.. Valid values are `environmental|social|governance`',
    `indicator_unit` STRING COMMENT 'Unit of measurement for the indicator value (e.g., percentage, absolute).',
    `indicator_value` DECIMAL(18,4) COMMENT 'Quantitative value of the PAI indicator for the reporting period.',
    `pai_indicator_status` STRING COMMENT 'Current lifecycle status of the PAI indicator record.. Valid values are `active|inactive|archived`',
    `reporting_period_end_date` DATE COMMENT 'End date of the reporting period for the PAI indicator.',
    `reporting_period_start_date` DATE COMMENT 'Start date of the reporting period for the PAI indicator.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the PAI indicator record was last updated.',
    CONSTRAINT pk_pai_indicator PRIMARY KEY(`pai_indicator_id`)
) COMMENT 'Transactional/reference record of Principal Adverse Impact (PAI) indicator values tracked per issuer and per reporting period under SFDR Article 7 and the PAI Statement.';

CREATE OR REPLACE TABLE `asset_management`.`esg`.`taxonomy_alignment` (
    `taxonomy_alignment_id` BIGINT COMMENT 'Unique identifier for the taxonomy alignment record.',
    `infra_asset_id` BIGINT COMMENT 'Identifier of the asset associated with the alignment.',
    `framework_id` BIGINT COMMENT 'Foreign key linking to esg.framework. Business justification: EU Taxonomy alignment is tracked against the EU Taxonomy framework. The regulatory_alignment field is a status, not the framework reference.',
    `holding_id` BIGINT COMMENT 'Identifier of the holding associated with the alignment.',
    `portfolio_id` BIGINT COMMENT 'Identifier of the portfolio associated with the alignment.',
    `activity_code` STRING COMMENT 'Identifier for the specific economic activity.',
    `activity_description` STRING COMMENT 'Description of the economic activity.',
    `alignment_end_date` DATE COMMENT 'Date when the alignment ended or is scheduled to end.',
    `alignment_percentage` DECIMAL(5,2) COMMENT 'Percentage of alignment to the taxonomy objective.',
    `alignment_start_date` DATE COMMENT 'Date when the alignment became effective.',
    `alignment_status` STRING COMMENT 'Current status of the alignment record.. Valid values are `active|inactive|pending|terminated`',
    `alignment_type` STRING COMMENT 'Type of investment alignment (direct, co-investment, fund).. Valid values are `direct|co-investment|fund`',
    `audit_trail_flag` BOOLEAN COMMENT 'Indicates if an audit trail exists for the record.',
    `biodiversity_objective` STRING COMMENT 'Biodiversity objective of the activity.',
    `carbon_intensity_metric` STRING COMMENT 'Metric used for carbon intensity measurement.',
    `carbon_intensity_value` DECIMAL(10,2) COMMENT 'Value of carbon intensity for the activity.',
    `circular_economy_objective` STRING COMMENT 'Circular economy objective of the activity.',
    `climate_objective` STRING COMMENT 'Climate-related objective of the activity (e.g., mitigation, adaptation).',
    `compliance_status` STRING COMMENT 'Compliance status of the alignment record.. Valid values are `compliant|non_compliant|pending`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the activity location.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was first created.',
    `data_quality_flag` BOOLEAN COMMENT 'Flag indicating overall data quality status.',
    `data_quality_score` DECIMAL(5,2) COMMENT 'Score indicating the quality of the data.',
    `data_source` STRING COMMENT 'Origin of the data (e.g., internal, external provider).',
    `effective_date` DATE COMMENT 'Date when the alignment record became effective.',
    `eligible_capex_pct` DECIMAL(5,2) COMMENT 'Percentage of capital expenditure eligible under the taxonomy.',
    `eligible_opex_pct` DECIMAL(5,2) COMMENT 'Percentage of operating expenditure eligible under the taxonomy.',
    `eligible_revenue_pct` DECIMAL(5,2) COMMENT 'Percentage of revenue eligible under the taxonomy.',
    `expiry_date` DATE COMMENT 'Date when the alignment record expires.',
    `gics_industry_code` STRING COMMENT 'GICS industry code for the activity.',
    `gics_sector_code` STRING COMMENT 'GICS sector code for the activity.',
    `last_modified_by` STRING COMMENT 'User who last modified the record.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the record.',
    `net_zero_commitment_flag` BOOLEAN COMMENT 'Indicates if the alignment includes a net zero commitment.',
    `notes` STRING COMMENT 'Free-text notes about the alignment record.',
    `pollution_objective` STRING COMMENT 'Pollution-related objective of the activity.',
    `regulatory_alignment` STRING COMMENT 'Regulatory framework aligned with the taxonomy record.. Valid values are `EU Taxonomy|SFDR|PRI`',
    `risk_assessment_flag` BOOLEAN COMMENT 'Indicates if a risk assessment has been performed.',
    `sector_classification` STRING COMMENT 'Sector classification of the activity (e.g., GICS sector).',
    `taxonomy_code` STRING COMMENT 'Code identifying the EU Taxonomy activity.',
    `taxonomy_eligibility_reason` STRING COMMENT 'Reason for the eligibility status.',
    `taxonomy_eligibility_status` STRING COMMENT 'Eligibility status of the activity under the taxonomy.. Valid values are `eligible|not_eligible|partial`',
    `taxonomy_name` STRING COMMENT 'Human-readable name of the EU Taxonomy activity.',
    `taxonomy_version` STRING COMMENT 'Version of the EU Taxonomy used.',
    `water_objective` STRING COMMENT 'Water-related objective of the activity.',
    `created_by` STRING COMMENT 'User who created the record.',
    CONSTRAINT pk_taxonomy_alignment PRIMARY KEY(`taxonomy_alignment_id`)
) COMMENT 'Record of EU Taxonomy eligibility and alignment at the economic-activity / holding level. Captures environmental objective (climate mitigation, adaptation, water, circular economy, pollution, biodiversity), eligible revenue/capex/opex %, aligned %';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`esg`.`esg_policy` ADD CONSTRAINT `fk_esg_esg_policy_superseded_policy_esg_policy_id` FOREIGN KEY (`superseded_policy_esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ADD CONSTRAINT `fk_esg_exclusion_list_esg_policy_id` FOREIGN KEY (`esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ADD CONSTRAINT `fk_esg_exclusion_list_framework_id` FOREIGN KEY (`framework_id`) REFERENCES `asset_management`.`esg`.`framework`(`framework_id`);
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ADD CONSTRAINT `fk_esg_sfdr_classification_framework_id` FOREIGN KEY (`framework_id`) REFERENCES `asset_management`.`esg`.`framework`(`framework_id`);
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ADD CONSTRAINT `fk_esg_tcfd_disclosure_climate_scenario_id` FOREIGN KEY (`climate_scenario_id`) REFERENCES `asset_management`.`esg`.`climate_scenario`(`climate_scenario_id`);
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ADD CONSTRAINT `fk_esg_tcfd_disclosure_net_zero_commitment_id` FOREIGN KEY (`net_zero_commitment_id`) REFERENCES `asset_management`.`esg`.`net_zero_commitment`(`net_zero_commitment_id`);
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ADD CONSTRAINT `fk_esg_ghg_emission_record_climate_scenario_id` FOREIGN KEY (`climate_scenario_id`) REFERENCES `asset_management`.`esg`.`climate_scenario`(`climate_scenario_id`);
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ADD CONSTRAINT `fk_esg_ghg_emission_record_data_provider_id` FOREIGN KEY (`data_provider_id`) REFERENCES `asset_management`.`esg`.`data_provider`(`data_provider_id`);
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ADD CONSTRAINT `fk_esg_ghg_emission_record_issuer_esg_rating_id` FOREIGN KEY (`issuer_esg_rating_id`) REFERENCES `asset_management`.`esg`.`issuer_esg_rating`(`issuer_esg_rating_id`);
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ADD CONSTRAINT `fk_esg_engagement_activity_esg_policy_id` FOREIGN KEY (`esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ADD CONSTRAINT `fk_esg_engagement_activity_issuer_esg_rating_id` FOREIGN KEY (`issuer_esg_rating_id`) REFERENCES `asset_management`.`esg`.`issuer_esg_rating`(`issuer_esg_rating_id`);
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ADD CONSTRAINT `fk_esg_engagement_objective_engagement_activity_id` FOREIGN KEY (`engagement_activity_id`) REFERENCES `asset_management`.`esg`.`engagement_activity`(`engagement_activity_id`);
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ADD CONSTRAINT `fk_esg_engagement_objective_engagement_engagement_activity_id` FOREIGN KEY (`engagement_engagement_activity_id`) REFERENCES `asset_management`.`esg`.`engagement_activity`(`engagement_activity_id`);
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ADD CONSTRAINT `fk_esg_engagement_objective_engagement_esg_policy_id` FOREIGN KEY (`engagement_esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ADD CONSTRAINT `fk_esg_engagement_objective_engagement_related_policy_esg_policy_id` FOREIGN KEY (`engagement_related_policy_esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ADD CONSTRAINT `fk_esg_proxy_vote_record_esg_policy_id` FOREIGN KEY (`esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ADD CONSTRAINT `fk_esg_proxy_vote_record_issuer_esg_rating_id` FOREIGN KEY (`issuer_esg_rating_id`) REFERENCES `asset_management`.`esg`.`issuer_esg_rating`(`issuer_esg_rating_id`);
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ADD CONSTRAINT `fk_esg_pri_reporting_submission_framework_id` FOREIGN KEY (`framework_id`) REFERENCES `asset_management`.`esg`.`framework`(`framework_id`);
ALTER TABLE `asset_management`.`esg`.`controversy` ADD CONSTRAINT `fk_esg_controversy_esg_policy_id` FOREIGN KEY (`esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`esg`.`controversy` ADD CONSTRAINT `fk_esg_controversy_exclusion_list_id` FOREIGN KEY (`exclusion_list_id`) REFERENCES `asset_management`.`esg`.`exclusion_list`(`exclusion_list_id`);
ALTER TABLE `asset_management`.`esg`.`controversy` ADD CONSTRAINT `fk_esg_controversy_issuer_esg_rating_id` FOREIGN KEY (`issuer_esg_rating_id`) REFERENCES `asset_management`.`esg`.`issuer_esg_rating`(`issuer_esg_rating_id`);
ALTER TABLE `asset_management`.`esg`.`due_diligence` ADD CONSTRAINT `fk_esg_due_diligence_climate_scenario_id` FOREIGN KEY (`climate_scenario_id`) REFERENCES `asset_management`.`esg`.`climate_scenario`(`climate_scenario_id`);
ALTER TABLE `asset_management`.`esg`.`due_diligence` ADD CONSTRAINT `fk_esg_due_diligence_data_provider_id` FOREIGN KEY (`data_provider_id`) REFERENCES `asset_management`.`esg`.`data_provider`(`data_provider_id`);
ALTER TABLE `asset_management`.`esg`.`due_diligence` ADD CONSTRAINT `fk_esg_due_diligence_esg_policy_id` FOREIGN KEY (`esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`esg`.`due_diligence` ADD CONSTRAINT `fk_esg_due_diligence_exclusion_list_id` FOREIGN KEY (`exclusion_list_id`) REFERENCES `asset_management`.`esg`.`exclusion_list`(`exclusion_list_id`);
ALTER TABLE `asset_management`.`esg`.`due_diligence` ADD CONSTRAINT `fk_esg_due_diligence_issuer_esg_rating_id` FOREIGN KEY (`issuer_esg_rating_id`) REFERENCES `asset_management`.`esg`.`issuer_esg_rating`(`issuer_esg_rating_id`);
ALTER TABLE `asset_management`.`esg`.`kpi_target` ADD CONSTRAINT `fk_esg_kpi_target_framework_id` FOREIGN KEY (`framework_id`) REFERENCES `asset_management`.`esg`.`framework`(`framework_id`);
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ADD CONSTRAINT `fk_esg_kpi_measurement_data_provider_id` FOREIGN KEY (`data_provider_id`) REFERENCES `asset_management`.`esg`.`data_provider`(`data_provider_id`);
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ADD CONSTRAINT `fk_esg_kpi_measurement_kpi_kpi_target_id` FOREIGN KEY (`kpi_kpi_target_id`) REFERENCES `asset_management`.`esg`.`kpi_target`(`kpi_target_id`);
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ADD CONSTRAINT `fk_esg_kpi_measurement_kpi_target_id` FOREIGN KEY (`kpi_target_id`) REFERENCES `asset_management`.`esg`.`kpi_target`(`kpi_target_id`);
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ADD CONSTRAINT `fk_esg_integration_checklist_esg_benchmark_id` FOREIGN KEY (`esg_benchmark_id`) REFERENCES `asset_management`.`esg`.`esg_benchmark`(`esg_benchmark_id`);
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ADD CONSTRAINT `fk_esg_integration_checklist_esg_policy_id` FOREIGN KEY (`esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ADD CONSTRAINT `fk_esg_integration_checklist_exclusion_list_id` FOREIGN KEY (`exclusion_list_id`) REFERENCES `asset_management`.`esg`.`exclusion_list`(`exclusion_list_id`);
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ADD CONSTRAINT `fk_esg_net_zero_commitment_framework_id` FOREIGN KEY (`framework_id`) REFERENCES `asset_management`.`esg`.`framework`(`framework_id`);
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ADD CONSTRAINT `fk_esg_net_zero_commitment_net_esg_policy_id` FOREIGN KEY (`net_esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ADD CONSTRAINT `fk_esg_net_zero_commitment_net_related_policy_esg_policy_id` FOREIGN KEY (`net_related_policy_esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ADD CONSTRAINT `fk_esg_esg_benchmark_framework_id` FOREIGN KEY (`framework_id`) REFERENCES `asset_management`.`esg`.`framework`(`framework_id`);
ALTER TABLE `asset_management`.`esg`.`watch_list` ADD CONSTRAINT `fk_esg_watch_list_controversy_id` FOREIGN KEY (`controversy_id`) REFERENCES `asset_management`.`esg`.`controversy`(`controversy_id`);
ALTER TABLE `asset_management`.`esg`.`watch_list` ADD CONSTRAINT `fk_esg_watch_list_exclusion_list_id` FOREIGN KEY (`exclusion_list_id`) REFERENCES `asset_management`.`esg`.`exclusion_list`(`exclusion_list_id`);
ALTER TABLE `asset_management`.`esg`.`watch_list` ADD CONSTRAINT `fk_esg_watch_list_issuer_esg_rating_id` FOREIGN KEY (`issuer_esg_rating_id`) REFERENCES `asset_management`.`esg`.`issuer_esg_rating`(`issuer_esg_rating_id`);
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ADD CONSTRAINT `fk_esg_responsible_investment_report_framework_id` FOREIGN KEY (`framework_id`) REFERENCES `asset_management`.`esg`.`framework`(`framework_id`);
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ADD CONSTRAINT `fk_esg_responsible_investment_report_net_zero_commitment_id` FOREIGN KEY (`net_zero_commitment_id`) REFERENCES `asset_management`.`esg`.`net_zero_commitment`(`net_zero_commitment_id`);
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ADD CONSTRAINT `fk_esg_responsible_investment_report_superseded_report_responsible_investment_report_id` FOREIGN KEY (`superseded_report_responsible_investment_report_id`) REFERENCES `asset_management`.`esg`.`responsible_investment_report`(`responsible_investment_report_id`);
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ADD CONSTRAINT `fk_esg_pai_indicator_framework_id` FOREIGN KEY (`framework_id`) REFERENCES `asset_management`.`esg`.`framework`(`framework_id`);
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ADD CONSTRAINT `fk_esg_taxonomy_alignment_framework_id` FOREIGN KEY (`framework_id`) REFERENCES `asset_management`.`esg`.`framework`(`framework_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` SET TAGS ('dbx_subdomain' = 'ratings_research');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `issuer_esg_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer Environmental, Social, and Governance (ESG) Rating ID');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `equity_issuer_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer ID');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `carbon_intensity` SET TAGS ('dbx_business_glossary_term' = 'Carbon Intensity (tCO2e per USD million revenue)');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `carbon_intensity` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `domicile_country_code` SET TAGS ('dbx_business_glossary_term' = 'Issuer Domicile Country Code');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `domicile_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `emissions_data_source` SET TAGS ('dbx_business_glossary_term' = 'GHG Emissions Data Source Type');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `emissions_data_source` SET TAGS ('dbx_value_regex' = 'Reported|Estimated|Modeled|Partial');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `engagement_priority_flag` SET TAGS ('dbx_business_glossary_term' = 'Engagement Priority Flag');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `environmental_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental (E) Pillar Score');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `environmental_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `esg_controversy_level` SET TAGS ('dbx_business_glossary_term' = 'ESG Controversy Level');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `esg_controversy_level` SET TAGS ('dbx_value_regex' = 'None|Low|Moderate|Significant|High|Very High');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `esg_controversy_score` SET TAGS ('dbx_business_glossary_term' = 'ESG Controversy Score');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `esg_controversy_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `esg_data_coverage_pct` SET TAGS ('dbx_business_glossary_term' = 'ESG Data Coverage Percentage');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `esg_rating_category` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Rating Category');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `esg_rating_category` SET TAGS ('dbx_value_regex' = 'Leader|Average|Laggard');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `esg_rating_grade` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Rating Grade');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `esg_rating_methodology_version` SET TAGS ('dbx_business_glossary_term' = 'ESG Rating Methodology Version');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `esg_rating_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Rating Score');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `esg_rating_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `exclusion_reason` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Reason');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `gics_industry_code` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Industry Code');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `gics_industry_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `gics_sector_code` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Sector Code');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `gics_sector_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2}$');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `governance_score` SET TAGS ('dbx_business_glossary_term' = 'Governance (G) Pillar Score');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `governance_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `industry_adjusted_score` SET TAGS ('dbx_business_glossary_term' = 'Industry-Adjusted ESG Score');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `industry_adjusted_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `internal_esg_override_flag` SET TAGS ('dbx_business_glossary_term' = 'Internal ESG Override Flag');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `internal_esg_override_grade` SET TAGS ('dbx_business_glossary_term' = 'Internal ESG Override Grade');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `internal_esg_override_grade` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `internal_override_rationale` SET TAGS ('dbx_business_glossary_term' = 'Internal ESG Override Rationale');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `internal_override_rationale` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Name');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `issuer_type` SET TAGS ('dbx_business_glossary_term' = 'Issuer Type');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `issuer_type` SET TAGS ('dbx_value_regex' = 'Corporate|Sovereign|Real Asset|Financial Institution|Supranational');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `lei_code` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI) Code');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `lei_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{18}[0-9]{2}$');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `net_zero_target_flag` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Target Flag');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `net_zero_target_year` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Target Year');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `on_exclusion_list` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List Flag');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `prior_esg_rating_grade` SET TAGS ('dbx_business_glossary_term' = 'Prior Environmental, Social, and Governance (ESG) Rating Grade');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `proxy_voting_policy_alignment` SET TAGS ('dbx_business_glossary_term' = 'Proxy Voting Policy Alignment');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `proxy_voting_policy_alignment` SET TAGS ('dbx_value_regex' = 'Aligned|Partially Aligned|Not Aligned|Not Applicable');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `rating_change_direction` SET TAGS ('dbx_business_glossary_term' = 'ESG Rating Change Direction');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `rating_change_direction` SET TAGS ('dbx_value_regex' = 'Upgrade|Downgrade|No Change|Initiated');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `rating_date` SET TAGS ('dbx_business_glossary_term' = 'ESG Rating Date');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `rating_effective_date` SET TAGS ('dbx_business_glossary_term' = 'ESG Rating Effective Date');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `rating_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'ESG Rating Expiry Date');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `rating_provider` SET TAGS ('dbx_business_glossary_term' = 'ESG Rating Provider');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `rating_provider` SET TAGS ('dbx_value_regex' = 'MSCI|Sustainalytics|ISS ESG|Bloomberg ESG|Internal|Refinitiv');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `rating_status` SET TAGS ('dbx_business_glossary_term' = 'ESG Rating Status');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `rating_status` SET TAGS ('dbx_value_regex' = 'Active|Superseded|Under Review|Withdrawn|Pending');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `scope1_emissions` SET TAGS ('dbx_business_glossary_term' = 'Scope 1 Greenhouse Gas (GHG) Emissions (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `scope1_emissions` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `scope2_emissions` SET TAGS ('dbx_business_glossary_term' = 'Scope 2 Greenhouse Gas (GHG) Emissions (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `scope2_emissions` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `scope3_emissions` SET TAGS ('dbx_business_glossary_term' = 'Scope 3 Greenhouse Gas (GHG) Emissions (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `scope3_emissions` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `sfdr_pai_flag` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Principal Adverse Impact (PAI) Flag');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `social_score` SET TAGS ('dbx_business_glossary_term' = 'Social (S) Pillar Score');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `social_score` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `source_system_rating_code` SET TAGS ('dbx_business_glossary_term' = 'Source System ESG Rating Identifier');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `tcfd_alignment_status` SET TAGS ('dbx_business_glossary_term' = 'Task Force on Climate-related Financial Disclosures (TCFD) Alignment Status');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `tcfd_alignment_status` SET TAGS ('dbx_value_regex' = 'Aligned|Partial|Not Aligned|Not Assessed');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `ungc_compliance_status` SET TAGS ('dbx_business_glossary_term' = 'United Nations Global Compact (UNGC) Compliance Status');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `ungc_compliance_status` SET TAGS ('dbx_value_regex' = 'Compliant|Non-Compliant|Watch List|Not Assessed');
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ALTER COLUMN `weapons_involvement_flag` SET TAGS ('dbx_business_glossary_term' = 'Controversial Weapons Involvement Flag');
ALTER TABLE `asset_management`.`esg`.`framework` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`esg`.`framework` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`framework` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`framework` SET TAGS ('dbx_subdomain' = 'climate_metrics');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `framework_id` SET TAGS ('dbx_business_glossary_term' = 'ESG Framework ID');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `abbreviation` SET TAGS ('dbx_business_glossary_term' = 'Framework Abbreviation');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `abbreviation` SET TAGS ('dbx_value_regex' = '^[A-Z0-9/-]{2,20}$');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `adoption_date` SET TAGS ('dbx_business_glossary_term' = 'Fund Adoption Date');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `adoption_status` SET TAGS ('dbx_business_glossary_term' = 'Adoption Status');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `adoption_status` SET TAGS ('dbx_value_regex' = 'adopted|under_review|pending_adoption|superseded|withdrawn|not_applicable');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `applicable_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Applicable Jurisdiction');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `assessment_score` SET TAGS ('dbx_business_glossary_term' = 'Compliance Assessment Score');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `asset_class_scope` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Scope');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `assurance_provider` SET TAGS ('dbx_business_glossary_term' = 'External Assurance Provider');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `benchmark_alignment` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Alignment');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `climate_related` SET TAGS ('dbx_business_glossary_term' = 'Climate-Related Framework Flag');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `framework_code` SET TAGS ('dbx_business_glossary_term' = 'Framework Code');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `framework_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,30}$');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `compliance_category` SET TAGS ('dbx_business_glossary_term' = 'Compliance Category');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `compliance_category` SET TAGS ('dbx_value_regex' = 'regulatory|voluntary|best_practice|contractual');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `compliance_score` SET TAGS ('dbx_business_glossary_term' = 'Compliance Score');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Framework Compliance Status');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Primary Data Source System');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `engagement_applicable` SET TAGS ('dbx_business_glossary_term' = 'Engagement Activity Applicable Flag');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `esg_pillar` SET TAGS ('dbx_business_glossary_term' = 'ESG Pillar');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `esg_pillar` SET TAGS ('dbx_value_regex' = 'environmental|social|governance|cross_pillar');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `exclusion_list_applicable` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List Applicable Flag');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `external_assurance_required` SET TAGS ('dbx_business_glossary_term' = 'External Assurance Required Flag');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `external_reference_url` SET TAGS ('dbx_business_glossary_term' = 'External Reference URL');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `external_reference_url` SET TAGS ('dbx_value_regex' = '^https?://[^s]{5,255}$');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `framework_type` SET TAGS ('dbx_business_glossary_term' = 'Framework Type');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `framework_type` SET TAGS ('dbx_value_regex' = 'reporting_standard|regulatory_regime|voluntary_principle|disclosure_framework|rating_methodology|stewardship_code');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `full_name` SET TAGS ('dbx_business_glossary_term' = 'Framework Full Name');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `full_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `full_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `ghg_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Reporting Required Flag');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `governing_body` SET TAGS ('dbx_business_glossary_term' = 'Governing Body');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `integration_level` SET TAGS ('dbx_business_glossary_term' = 'ESG Integration Level');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `integration_level` SET TAGS ('dbx_value_regex' = 'full|partial|monitoring_only|not_integrated');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Compliance Flag');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `last_assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Last Assessment Date');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `materiality_approach` SET TAGS ('dbx_business_glossary_term' = 'Materiality Approach');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `materiality_approach` SET TAGS ('dbx_value_regex' = 'single_materiality|double_materiality|dynamic_materiality|not_specified');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Framework Notes');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `pai_indicator_required` SET TAGS ('dbx_business_glossary_term' = 'Principal Adverse Impact (PAI) Indicator Required Flag');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `pri_module` SET TAGS ('dbx_business_glossary_term' = 'Principles for Responsible Investment (PRI) Reporting Module');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `proxy_voting_applicable` SET TAGS ('dbx_business_glossary_term' = 'Proxy Voting Applicable Flag');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `publication_date` SET TAGS ('dbx_business_glossary_term' = 'Publication Date');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `reporting_deadline_month` SET TAGS ('dbx_business_glossary_term' = 'Reporting Deadline Month');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly|on_demand|not_required');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `responsible_team` SET TAGS ('dbx_business_glossary_term' = 'Responsible Internal Team');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `sfdr_article_classification` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Article Classification');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `sfdr_article_classification` SET TAGS ('dbx_value_regex' = 'article_6|article_8|article_9|not_applicable');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `signatory_date` SET TAGS ('dbx_business_glossary_term' = 'Signatory Date');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `signatory_status` SET TAGS ('dbx_business_glossary_term' = 'Signatory Status');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `signatory_status` SET TAGS ('dbx_value_regex' = 'signatory|non_signatory|pending|former_signatory');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `taxonomy_alignment` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Taxonomy Alignment');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `taxonomy_alignment` SET TAGS ('dbx_value_regex' = 'eu_taxonomy|uk_taxonomy|asean_taxonomy|none');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `tcfd_pillar` SET TAGS ('dbx_business_glossary_term' = 'Task Force on Climate-related Financial Disclosures (TCFD) Pillar');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `tcfd_pillar` SET TAGS ('dbx_value_regex' = 'governance|strategy|risk_management|metrics_and_targets|not_applicable');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Framework Version');
ALTER TABLE `asset_management`.`esg`.`framework` ALTER COLUMN `version` SET TAGS ('dbx_value_regex' = '^[0-9]{1,3}(.[0-9]{1,3}){0,2}([a-zA-Z0-9-.]{0,20})?$');
ALTER TABLE `asset_management`.`esg`.`esg_policy` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`esg`.`esg_policy` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`esg_policy` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`esg_policy` SET TAGS ('dbx_subdomain' = 'climate_metrics');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `superseded_policy_esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded Policy Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `baseline_year` SET TAGS ('dbx_business_glossary_term' = 'Baseline Year');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `breach_escalation_procedure` SET TAGS ('dbx_business_glossary_term' = 'Breach Escalation Procedure');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `climate_alignment_target` SET TAGS ('dbx_business_glossary_term' = 'Climate Alignment Target');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `esg_policy_code` SET TAGS ('dbx_business_glossary_term' = 'Policy Code');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `esg_policy_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,20}$');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `compliance_monitoring_method` SET TAGS ('dbx_business_glossary_term' = 'Compliance Monitoring Method');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `compliance_monitoring_method` SET TAGS ('dbx_value_regex' = 'automated|manual|hybrid');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `document_url` SET TAGS ('dbx_business_glossary_term' = 'Policy Document URL (Uniform Resource Locator)');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `document_url` SET TAGS ('dbx_value_regex' = '^https?://.*$');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `engagement_mandate` SET TAGS ('dbx_business_glossary_term' = 'Engagement Mandate');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `esg_integration_level` SET TAGS ('dbx_business_glossary_term' = 'ESG (Environmental, Social, and Governance) Integration Level');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `esg_integration_level` SET TAGS ('dbx_value_regex' = 'mandatory|recommended|optional|not_applicable');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `esg_policy_status` SET TAGS ('dbx_business_glossary_term' = 'Policy Status');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `esg_policy_status` SET TAGS ('dbx_value_regex' = 'draft|active|under_review|suspended|superseded|archived');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `esg_policy_type` SET TAGS ('dbx_business_glossary_term' = 'Policy Type');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `esg_policy_type` SET TAGS ('dbx_value_regex' = 'responsible_investment|exclusion|proxy_voting|engagement|climate|human_rights');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `exclusion_criteria` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Criteria');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `external_audit_required` SET TAGS ('dbx_business_glossary_term' = 'External Audit Required');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_value_regex' = 'global|developed_markets|emerging_markets|specific_region');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `ghg_reduction_target_pct` SET TAGS ('dbx_business_glossary_term' = 'GHG (Greenhouse Gas) Reduction Target Percentage');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `language` SET TAGS ('dbx_business_glossary_term' = 'Policy Language');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `language` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `last_audit_date` SET TAGS ('dbx_business_glossary_term' = 'Last Audit Date');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `legal_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Legal Jurisdiction');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `legal_jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `esg_policy_name` SET TAGS ('dbx_business_glossary_term' = 'Policy Name');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `next_audit_date` SET TAGS ('dbx_business_glossary_term' = 'Next Audit Date');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `owner` SET TAGS ('dbx_business_glossary_term' = 'Policy Owner');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `proxy_voting_mandate` SET TAGS ('dbx_business_glossary_term' = 'Proxy Voting Mandate');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `public_disclosure_required` SET TAGS ('dbx_business_glossary_term' = 'Public Disclosure Required');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `regulatory_alignment` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Alignment');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `related_policy_ids` SET TAGS ('dbx_business_glossary_term' = 'Related Policy Identifiers (IDs)');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly|ad_hoc');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `review_frequency_months` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency (Months)');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'Policy Scope');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `summary` SET TAGS ('dbx_business_glossary_term' = 'Policy Summary');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `tags` SET TAGS ('dbx_business_glossary_term' = 'Policy Tags');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `target_year` SET TAGS ('dbx_business_glossary_term' = 'Target Year');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+(.[0-9]+)?$');
ALTER TABLE `asset_management`.`esg`.`esg_policy` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` SET TAGS ('dbx_subdomain' = 'climate_metrics');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `exclusion_list_id` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List ID');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `framework_id` SET TAGS ('dbx_business_glossary_term' = 'Framework Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `breach_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Breach Resolution Date');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `compliance_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Compliance Breach Flag');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `controversy_level` SET TAGS ('dbx_business_glossary_term' = 'Controversy Level');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `controversy_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|severe');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `divestment_deadline` SET TAGS ('dbx_business_glossary_term' = 'Divestment Deadline');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `divestment_status` SET TAGS ('dbx_business_glossary_term' = 'Divestment Status');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `divestment_status` SET TAGS ('dbx_value_regex' = 'not_applicable|pending|in_progress|completed|exempted');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `engagement_status` SET TAGS ('dbx_business_glossary_term' = 'Engagement Status');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `engagement_status` SET TAGS ('dbx_value_regex' = 'no_engagement|active_engagement|escalated|resolved|discontinued');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `exclusion_category` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Category');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `exclusion_category` SET TAGS ('dbx_value_regex' = 'controversial_weapons|tobacco|thermal_coal|oil_sands|human_rights|labor_rights');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `exclusion_identifier` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Business Identifier');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `exclusion_override_flag` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Override Flag');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `exclusion_reason` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Reason');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `exclusion_scope` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Scope');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `exclusion_scope` SET TAGS ('dbx_value_regex' = 'all_portfolios|public_equity|private_equity|fixed_income|real_estate|infrastructure');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `exclusion_status` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Status');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `exclusion_status` SET TAGS ('dbx_value_regex' = 'active|suspended|expired|under_review|pending_approval|revoked');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `exclusion_type` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Type');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `exclusion_type` SET TAGS ('dbx_value_regex' = 'norm-based|sector-based|product-based|issuer-based|geography-based|conduct-based');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `ghg_emissions_intensity` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Emissions Intensity');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `issuer_country` SET TAGS ('dbx_business_glossary_term' = 'Issuer Country Code');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `issuer_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Name');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `last_holdings_check_date` SET TAGS ('dbx_business_glossary_term' = 'Last Holdings Check Date');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Notes');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `override_reason` SET TAGS ('dbx_business_glossary_term' = 'Override Reason');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `proxy_voting_restriction` SET TAGS ('dbx_business_glossary_term' = 'Proxy Voting Restriction Flag');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `revenue_threshold_pct` SET TAGS ('dbx_business_glossary_term' = 'Revenue Threshold Percentage');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'Review Date');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `security_identifier` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `security_identifier_type` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier Type');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `security_identifier_type` SET TAGS ('dbx_value_regex' = 'ISIN|CUSIP|SEDOL|TICKER|INTERNAL');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Classification');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_value_regex' = 'article_6|article_8|article_9|excluded');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `tcfd_climate_risk_flag` SET TAGS ('dbx_business_glossary_term' = 'Task Force on Climate-related Financial Disclosures (TCFD) Climate Risk Flag');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `un_global_compact_violation` SET TAGS ('dbx_business_glossary_term' = 'United Nations (UN) Global Compact Violation Flag');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By User');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `sfdr_classification_id` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Classification ID');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `composite_id` SET TAGS ('dbx_business_glossary_term' = 'Composite Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `framework_id` SET TAGS ('dbx_business_glossary_term' = 'Framework Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund ID');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Mandate ID');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `sfdr_disclosure_id` SET TAGS ('dbx_business_glossary_term' = 'Sfdr Disclosure Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `benchmark_index_name` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index Name');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `benchmark_is_esg_aligned` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Is Environmental Social and Governance (ESG) Aligned');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `classification_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Classification Approval Date');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `classification_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Classification Approved By');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `classification_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Classification Effective Date');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `classification_end_date` SET TAGS ('dbx_business_glossary_term' = 'Classification End Date');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `classification_rationale` SET TAGS ('dbx_business_glossary_term' = 'Classification Rationale');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `classification_status` SET TAGS ('dbx_business_glossary_term' = 'Classification Status');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `classification_status` SET TAGS ('dbx_value_regex' = 'active|pending|superseded|withdrawn');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `data_coverage_percentage` SET TAGS ('dbx_business_glossary_term' = 'Data Coverage Percentage');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `do_no_significant_harm_assessment` SET TAGS ('dbx_business_glossary_term' = 'Do No Significant Harm (DNSH) Assessment');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `engagement_strategy_applied` SET TAGS ('dbx_business_glossary_term' = 'Engagement Strategy Applied');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `environmental_objective_alignment` SET TAGS ('dbx_business_glossary_term' = 'Environmental Objective Alignment');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `esg_methodology_version` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Methodology Version');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `esg_rating_provider` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating Provider');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `exclusion_policy_applied` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Policy Applied');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `exclusion_policy_description` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Policy Description');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `good_governance_assessment` SET TAGS ('dbx_business_glossary_term' = 'Good Governance Assessment');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `minimum_sustainable_investment_percentage` SET TAGS ('dbx_business_glossary_term' = 'Minimum Sustainable Investment Percentage');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `pai_disclosure_required` SET TAGS ('dbx_business_glossary_term' = 'Principal Adverse Impact (PAI) Disclosure Required');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `pai_indicators_considered` SET TAGS ('dbx_business_glossary_term' = 'Principal Adverse Impact (PAI) Indicators Considered');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `periodic_disclosure_url` SET TAGS ('dbx_business_glossary_term' = 'Periodic Disclosure Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `pre_contractual_disclosure_url` SET TAGS ('dbx_business_glossary_term' = 'Pre-Contractual Disclosure Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `proxy_voting_policy_applied` SET TAGS ('dbx_business_glossary_term' = 'Proxy Voting Policy Applied');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `regulatory_filing_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Reference');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `sfdr_article_classification` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Article Classification');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `sfdr_article_classification` SET TAGS ('dbx_value_regex' = 'Article 6|Article 8|Article 9');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `social_objective_alignment` SET TAGS ('dbx_business_glossary_term' = 'Social Objective Alignment');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `taxonomy_alignment_percentage` SET TAGS ('dbx_business_glossary_term' = 'EU Taxonomy Alignment Percentage');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `website_disclosure_url` SET TAGS ('dbx_business_glossary_term' = 'Website Disclosure Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `tcfd_disclosure_id` SET TAGS ('dbx_business_glossary_term' = 'Task Force on Climate-related Financial Disclosures (TCFD) Disclosure ID');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `climate_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `net_zero_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Commitment Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `assurance_level` SET TAGS ('dbx_business_glossary_term' = 'Assurance Level');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `assurance_level` SET TAGS ('dbx_value_regex' = 'limited|reasonable');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `assurance_provider` SET TAGS ('dbx_business_glossary_term' = 'Assurance Provider');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `baseline_year` SET TAGS ('dbx_business_glossary_term' = 'Baseline Year');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `board_oversight_description` SET TAGS ('dbx_business_glossary_term' = 'Board Oversight Description');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `carbon_footprint_portfolio_tco2e_per_million` SET TAGS ('dbx_business_glossary_term' = 'Carbon Footprint of Portfolio (tCO2e per Million Invested)');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `climate_opportunity_summary` SET TAGS ('dbx_business_glossary_term' = 'Climate Opportunity Summary');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `climate_related_financial_impact_estimate` SET TAGS ('dbx_business_glossary_term' = 'Climate-Related Financial Impact Estimate');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `climate_risk_integration_approach` SET TAGS ('dbx_business_glossary_term' = 'Climate Risk Integration Approach');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `climate_var_estimate` SET TAGS ('dbx_business_glossary_term' = 'Climate Value at Risk (VaR) Estimate');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `climate_var_methodology` SET TAGS ('dbx_business_glossary_term' = 'Climate Value at Risk (VaR) Methodology');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `disclosure_status` SET TAGS ('dbx_business_glossary_term' = 'Disclosure Status');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `disclosure_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|published|archived');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `disclosure_version` SET TAGS ('dbx_business_glossary_term' = 'Disclosure Version');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `disclosure_year` SET TAGS ('dbx_business_glossary_term' = 'Disclosure Year');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `emissions_intensity_metric` SET TAGS ('dbx_business_glossary_term' = 'Emissions Intensity Metric');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `emissions_intensity_value` SET TAGS ('dbx_business_glossary_term' = 'Emissions Intensity Value');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `external_assurance_obtained` SET TAGS ('dbx_business_glossary_term' = 'External Assurance Obtained');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `fossil_fuel_exposure_pct` SET TAGS ('dbx_business_glossary_term' = 'Fossil Fuel Exposure Percentage');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `governance_narrative` SET TAGS ('dbx_business_glossary_term' = 'Governance Narrative');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `green_revenue_alignment_pct` SET TAGS ('dbx_business_glossary_term' = 'Green Revenue Alignment Percentage');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `interim_emissions_reduction_target_pct` SET TAGS ('dbx_business_glossary_term' = 'Interim Emissions Reduction Target Percentage');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `interim_target_year` SET TAGS ('dbx_business_glossary_term' = 'Interim Target Year');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `management_role_description` SET TAGS ('dbx_business_glossary_term' = 'Management Role Description');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `metrics_targets_narrative` SET TAGS ('dbx_business_glossary_term' = 'Metrics and Targets Narrative');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `net_zero_commitment_flag` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Commitment Flag');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `net_zero_target_year` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Target Year');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `physical_risk_exposure_summary` SET TAGS ('dbx_business_glossary_term' = 'Physical Risk Exposure Summary');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `prepared_by` SET TAGS ('dbx_business_glossary_term' = 'Prepared By');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `publication_url` SET TAGS ('dbx_business_glossary_term' = 'Publication Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `risk_management_narrative` SET TAGS ('dbx_business_glossary_term' = 'Risk Management Narrative');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `scenario_analysis_approach` SET TAGS ('dbx_business_glossary_term' = 'Scenario Analysis Approach');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `scenario_temperature_pathways` SET TAGS ('dbx_business_glossary_term' = 'Scenario Temperature Pathways');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `scope_1_emissions_tco2e` SET TAGS ('dbx_business_glossary_term' = 'Scope 1 Greenhouse Gas (GHG) Emissions (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `scope_2_emissions_tco2e` SET TAGS ('dbx_business_glossary_term' = 'Scope 2 Greenhouse Gas (GHG) Emissions (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `scope_3_emissions_tco2e` SET TAGS ('dbx_business_glossary_term' = 'Scope 3 Greenhouse Gas (GHG) Emissions (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `stranded_asset_risk_assessment` SET TAGS ('dbx_business_glossary_term' = 'Stranded Asset Risk Assessment');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `strategy_narrative` SET TAGS ('dbx_business_glossary_term' = 'Strategy Narrative');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Date');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `time_horizons_assessed` SET TAGS ('dbx_business_glossary_term' = 'Time Horizons Assessed');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `total_emissions_tco2e` SET TAGS ('dbx_business_glossary_term' = 'Total Greenhouse Gas (GHG) Emissions (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `transition_risk_exposure_summary` SET TAGS ('dbx_business_glossary_term' = 'Transition Risk Exposure Summary');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `weighted_average_carbon_intensity_waci` SET TAGS ('dbx_business_glossary_term' = 'Weighted Average Carbon Intensity (WACI)');
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` SET TAGS ('dbx_subdomain' = 'climate_metrics');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `ghg_emission_record_id` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Emission Record Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `infra_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `climate_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `data_provider_id` SET TAGS ('dbx_business_glossary_term' = 'Data Provider Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `issuer_esg_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `portfolio_holding_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Holding Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Asset Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `attributed_emissions_tco2e` SET TAGS ('dbx_business_glossary_term' = 'Attributed Emissions in Tonnes Carbon Dioxide Equivalent (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `baseline_year` SET TAGS ('dbx_business_glossary_term' = 'Baseline Year');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `carbon_footprint_per_million_invested` SET TAGS ('dbx_business_glossary_term' = 'Carbon Footprint Per Million Invested');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `data_collection_method` SET TAGS ('dbx_business_glossary_term' = 'Data Collection Method');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `data_quality_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Flag');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `data_source_type` SET TAGS ('dbx_business_glossary_term' = 'Data Source Type');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `data_source_type` SET TAGS ('dbx_value_regex' = 'reported|estimated|modeled|third_party|proxy');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `emission_factor_source` SET TAGS ('dbx_business_glossary_term' = 'Emission Factor Source');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `emissions_intensity_metric` SET TAGS ('dbx_business_glossary_term' = 'Emissions Intensity Metric');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `emissions_intensity_metric` SET TAGS ('dbx_value_regex' = 'revenue|aum|employees|production_unit|square_meter|other');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `emissions_intensity_value` SET TAGS ('dbx_business_glossary_term' = 'Emissions Intensity Value');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Name');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `measurement_date` SET TAGS ('dbx_business_glossary_term' = 'Measurement Date');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `methodology` SET TAGS ('dbx_business_glossary_term' = 'Methodology');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `paris_alignment_flag` SET TAGS ('dbx_business_glossary_term' = 'Paris Agreement Alignment Flag');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `reduction_target_pct` SET TAGS ('dbx_business_glossary_term' = 'Reduction Target Percentage');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `scope_1_emissions_tco2e` SET TAGS ('dbx_business_glossary_term' = 'Scope 1 Emissions in Tonnes Carbon Dioxide Equivalent (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `scope_2_location_based_emissions_tco2e` SET TAGS ('dbx_business_glossary_term' = 'Scope 2 Location-Based Emissions in Tonnes Carbon Dioxide Equivalent (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `scope_2_market_based_emissions_tco2e` SET TAGS ('dbx_business_glossary_term' = 'Scope 2 Market-Based Emissions in Tonnes Carbon Dioxide Equivalent (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `scope_3_category` SET TAGS ('dbx_business_glossary_term' = 'Scope 3 Category');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `scope_3_emissions_tco2e` SET TAGS ('dbx_business_glossary_term' = 'Scope 3 Emissions in Tonnes Carbon Dioxide Equivalent (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Classification');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_value_regex' = 'article_6|article_8|article_9');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `target_year` SET TAGS ('dbx_business_glossary_term' = 'Target Year');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `tcfd_alignment_flag` SET TAGS ('dbx_business_glossary_term' = 'Task Force on Climate-related Financial Disclosures (TCFD) Alignment Flag');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `total_emissions_tco2e` SET TAGS ('dbx_business_glossary_term' = 'Total Emissions in Tonnes Carbon Dioxide Equivalent (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `verification_body` SET TAGS ('dbx_business_glossary_term' = 'Verification Body');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Verification Date');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `verification_status` SET TAGS ('dbx_business_glossary_term' = 'Verification Status');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `verification_status` SET TAGS ('dbx_value_regex' = 'verified|unverified|limited_assurance|reasonable_assurance');
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` SET TAGS ('dbx_subdomain' = 'climate_metrics');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `climate_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `approved_for_use_flag` SET TAGS ('dbx_business_glossary_term' = 'Approved for Use Flag');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `asset_class_applicability` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Applicability');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `base_year` SET TAGS ('dbx_business_glossary_term' = 'Base Year');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `carbon_budget_gt` SET TAGS ('dbx_business_glossary_term' = 'Carbon Budget (Gigatonnes CO2)');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `carbon_price_trajectory` SET TAGS ('dbx_business_glossary_term' = 'Carbon Price Trajectory');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `carbon_price_trajectory` SET TAGS ('dbx_value_regex' = 'low|medium|high|very_high');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `climate_scenario_status` SET TAGS ('dbx_business_glossary_term' = 'Scenario Status');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `climate_scenario_status` SET TAGS ('dbx_value_regex' = 'active|deprecated|under_review|archived');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `data_source_url` SET TAGS ('dbx_business_glossary_term' = 'Data Source Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_value_regex' = 'global|regional|national');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `key_assumptions` SET TAGS ('dbx_business_glossary_term' = 'Key Assumptions');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `limitations` SET TAGS ('dbx_business_glossary_term' = 'Scenario Limitations');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `methodology_summary` SET TAGS ('dbx_business_glossary_term' = 'Methodology Summary');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `net_zero_year` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Year');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `owner` SET TAGS ('dbx_business_glossary_term' = 'Scenario Owner');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `peak_emissions_year` SET TAGS ('dbx_business_glossary_term' = 'Peak Emissions Year');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `physical_risk_severity` SET TAGS ('dbx_business_glossary_term' = 'Physical Risk Severity');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `physical_risk_severity` SET TAGS ('dbx_value_regex' = 'low|moderate|high|severe');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `policy_stringency` SET TAGS ('dbx_business_glossary_term' = 'Policy Stringency');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `policy_stringency` SET TAGS ('dbx_value_regex' = 'weak|moderate|strong|very_strong');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `publication_date` SET TAGS ('dbx_business_glossary_term' = 'Publication Date');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `rcp_classification` SET TAGS ('dbx_business_glossary_term' = 'Representative Concentration Pathway (RCP) Classification');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `rcp_classification` SET TAGS ('dbx_value_regex' = 'RCP2.6|RCP4.5|RCP6.0|RCP8.5');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `regulatory_alignment` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Alignment');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `review_frequency_months` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency (Months)');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `scenario_category` SET TAGS ('dbx_business_glossary_term' = 'Scenario Category');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `scenario_category` SET TAGS ('dbx_value_regex' = 'orderly|disorderly|hot_house|too_little_too_late');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `scenario_code` SET TAGS ('dbx_business_glossary_term' = 'Scenario Code');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `scenario_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,20}$');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `scenario_name` SET TAGS ('dbx_business_glossary_term' = 'Scenario Name');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `scenario_type` SET TAGS ('dbx_business_glossary_term' = 'Scenario Type');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `scenario_type` SET TAGS ('dbx_value_regex' = 'transition|physical|combined');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `sector_coverage` SET TAGS ('dbx_business_glossary_term' = 'Sector Coverage');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `sfdr_disclosure_flag` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Disclosure Flag');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `source_organization` SET TAGS ('dbx_business_glossary_term' = 'Source Organization');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `ssp_classification` SET TAGS ('dbx_business_glossary_term' = 'Shared Socioeconomic Pathway (SSP) Classification');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `stress_test_usage_flag` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Usage Flag');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `target_year` SET TAGS ('dbx_business_glossary_term' = 'Target Year');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `tcfd_alignment_flag` SET TAGS ('dbx_business_glossary_term' = 'Task Force on Climate-related Financial Disclosures (TCFD) Alignment Flag');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `technology_change_assumption` SET TAGS ('dbx_business_glossary_term' = 'Technology Change Assumption');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `technology_change_assumption` SET TAGS ('dbx_value_regex' = 'slow|moderate|rapid|breakthrough');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `temperature_pathway` SET TAGS ('dbx_business_glossary_term' = 'Temperature Pathway');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `time_horizon` SET TAGS ('dbx_business_glossary_term' = 'Time Horizon (Years)');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `transition_risk_severity` SET TAGS ('dbx_business_glossary_term' = 'Transition Risk Severity');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `transition_risk_severity` SET TAGS ('dbx_value_regex' = 'low|moderate|high|severe');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `usage_guidance` SET TAGS ('dbx_business_glossary_term' = 'Usage Guidance');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Scenario Version');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+(.[0-9]+)?$');
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` SET TAGS ('dbx_subdomain' = 'climate_metrics');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_activity_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Activity Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `issuer_esg_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer Esg Rating Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `collaborative_initiative_name` SET TAGS ('dbx_business_glossary_term' = 'Collaborative Initiative Name');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `controversy_level` SET TAGS ('dbx_business_glossary_term' = 'Controversy Level');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `controversy_level` SET TAGS ('dbx_value_regex' = 'none|low|moderate|high|severe');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `document_reference_url` SET TAGS ('dbx_business_glossary_term' = 'Document Reference Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `document_reference_url` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_channel` SET TAGS ('dbx_business_glossary_term' = 'Engagement Channel');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_date` SET TAGS ('dbx_business_glossary_term' = 'Engagement Date');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_identifier` SET TAGS ('dbx_business_glossary_term' = 'Engagement Business Identifier');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_identifier` SET TAGS ('dbx_value_regex' = '^ENG-[0-9]{8}-[A-Z0-9]{6}$');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_milestone` SET TAGS ('dbx_business_glossary_term' = 'Engagement Milestone');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_objective` SET TAGS ('dbx_business_glossary_term' = 'Engagement Objective');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_outcome` SET TAGS ('dbx_business_glossary_term' = 'Engagement Outcome');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_participants_external` SET TAGS ('dbx_business_glossary_term' = 'External Engagement Participants');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_participants_external` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_participants_internal` SET TAGS ('dbx_business_glossary_term' = 'Internal Engagement Participants');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_participants_internal` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_priority` SET TAGS ('dbx_business_glossary_term' = 'Engagement Priority');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_status` SET TAGS ('dbx_business_glossary_term' = 'Engagement Status');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_status` SET TAGS ('dbx_value_regex' = 'planned|initiated|in_progress|completed|suspended|closed');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_sub_topic` SET TAGS ('dbx_business_glossary_term' = 'Engagement Sub-Topic');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_summary` SET TAGS ('dbx_business_glossary_term' = 'Engagement Summary');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_topic` SET TAGS ('dbx_business_glossary_term' = 'Engagement Topic');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_type` SET TAGS ('dbx_business_glossary_term' = 'Engagement Type');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `engagement_type` SET TAGS ('dbx_value_regex' = 'direct|collaborative|escalation|proxy_voting|shareholder_resolution|public_statement');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `escalation_level` SET TAGS ('dbx_business_glossary_term' = 'Escalation Level');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `esg_rating_at_engagement` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Rating at Engagement');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `esg_rating_at_engagement` SET TAGS ('dbx_value_regex' = '^(AAA|AA|A|BBB|BB|B|CCC)$');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `holding_value_at_engagement` SET TAGS ('dbx_business_glossary_term' = 'Holding Value at Engagement');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `holding_value_at_engagement` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `holding_value_currency` SET TAGS ('dbx_business_glossary_term' = 'Holding Value Currency Code');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `holding_value_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `investee_country` SET TAGS ('dbx_business_glossary_term' = 'Investee Country Code');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `investee_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `investee_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Investee Entity Name');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `investee_lei` SET TAGS ('dbx_business_glossary_term' = 'Investee Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `investee_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `investee_sector` SET TAGS ('dbx_business_glossary_term' = 'Investee Sector Classification');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Active Record Flag');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified By User');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `next_action` SET TAGS ('dbx_business_glossary_term' = 'Next Action');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `next_action_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Action Due Date');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `public_disclosure_flag` SET TAGS ('dbx_business_glossary_term' = 'Public Disclosure Flag');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Classification');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_value_regex' = 'article_6|article_8|article_9');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `tcfd_alignment_flag` SET TAGS ('dbx_business_glossary_term' = 'Task Force on Climate-related Financial Disclosures (TCFD) Alignment Flag');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `un_global_compact_violation_flag` SET TAGS ('dbx_business_glossary_term' = 'United Nations (UN) Global Compact Violation Flag');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `voting_action_taken` SET TAGS ('dbx_business_glossary_term' = 'Voting Action Taken Flag');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `voting_decision` SET TAGS ('dbx_business_glossary_term' = 'Voting Decision');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `voting_decision` SET TAGS ('dbx_value_regex' = 'for|against|abstain|not_voted');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `voting_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Voting Meeting Date');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `voting_resolution_description` SET TAGS ('dbx_business_glossary_term' = 'Voting Resolution Description');
ALTER TABLE `asset_management`.`esg`.`engagement_activity` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By User');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` SET TAGS ('dbx_subdomain' = 'climate_metrics');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `engagement_objective_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Objective Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `engagement_activity_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `engagement_engagement_activity_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `engagement_esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Related Policy Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `engagement_related_policy_esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Related Policy Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Owner Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `achievement_date` SET TAGS ('dbx_business_glossary_term' = 'Achievement Date');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `baseline_date` SET TAGS ('dbx_business_glossary_term' = 'Baseline Date');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `baseline_value` SET TAGS ('dbx_business_glossary_term' = 'Baseline Value');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `closure_date` SET TAGS ('dbx_business_glossary_term' = 'Closure Date');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `closure_reason` SET TAGS ('dbx_business_glossary_term' = 'Closure Reason');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `collaboration_initiative_name` SET TAGS ('dbx_business_glossary_term' = 'Collaboration Initiative Name');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `engagement_approach` SET TAGS ('dbx_business_glossary_term' = 'Engagement Approach');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `engagement_approach` SET TAGS ('dbx_value_regex' = 'direct|collaborative|proxy_voting|public_statement|divestment_threat');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `engagement_objective_status` SET TAGS ('dbx_business_glossary_term' = 'Objective Status');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `escalation_level` SET TAGS ('dbx_business_glossary_term' = 'Escalation Level');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `escalation_level` SET TAGS ('dbx_value_regex' = 'initial|moderate|elevated|maximum');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `esg_issue` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Issue');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `esg_pillar` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Pillar');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `esg_pillar` SET TAGS ('dbx_value_regex' = 'environmental|social|governance|integrated');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `external_collaboration_flag` SET TAGS ('dbx_business_glossary_term' = 'External Collaboration Flag');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `investee_country` SET TAGS ('dbx_business_glossary_term' = 'Investee Country');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `investee_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `investee_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Investee Entity Name');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `investee_lei` SET TAGS ('dbx_business_glossary_term' = 'Investee Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `investee_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `investee_sector` SET TAGS ('dbx_business_glossary_term' = 'Investee Sector');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `milestone_description` SET TAGS ('dbx_business_glossary_term' = 'Milestone Description');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `objective_code` SET TAGS ('dbx_business_glossary_term' = 'Objective Code');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `objective_description` SET TAGS ('dbx_business_glossary_term' = 'Objective Description');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `objective_name` SET TAGS ('dbx_business_glossary_term' = 'Objective Name');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `objective_type` SET TAGS ('dbx_business_glossary_term' = 'Objective Type');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `objective_type` SET TAGS ('dbx_value_regex' = 'strategic|tactical|operational|compliance|thematic|ad_hoc');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `owner_department` SET TAGS ('dbx_business_glossary_term' = 'Owner Department');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Priority Level');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `progress_percentage` SET TAGS ('dbx_business_glossary_term' = 'Progress Percentage');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `public_disclosure_flag` SET TAGS ('dbx_business_glossary_term' = 'Public Disclosure Flag');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `review_frequency_months` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency in Months');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `sfdr_principal_adverse_impact` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Principal Adverse Impact (PAI)');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `target_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Target Completion Date');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `target_metric` SET TAGS ('dbx_business_glossary_term' = 'Target Metric');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `target_value` SET TAGS ('dbx_business_glossary_term' = 'Target Value');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `tcfd_alignment` SET TAGS ('dbx_business_glossary_term' = 'Task Force on Climate-related Financial Disclosures (TCFD) Alignment');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `tcfd_alignment` SET TAGS ('dbx_value_regex' = 'governance|strategy|risk_management|metrics_targets|not_applicable');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `un_sdg_alignment` SET TAGS ('dbx_business_glossary_term' = 'United Nations (UN) Sustainable Development Goal (SDG) Alignment');
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` SET TAGS ('dbx_subdomain' = 'climate_metrics');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `proxy_vote_record_id` SET TAGS ('dbx_business_glossary_term' = 'Proxy Vote Record Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `holding_id` SET TAGS ('dbx_business_glossary_term' = 'Holding Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `issuer_esg_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer Esg Rating Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `ballot_reference` SET TAGS ('dbx_business_glossary_term' = 'Ballot Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `climate_alignment_flag` SET TAGS ('dbx_business_glossary_term' = 'Climate Alignment Flag');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `custodian_name` SET TAGS ('dbx_business_glossary_term' = 'Custodian Name');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `disclosure_date` SET TAGS ('dbx_business_glossary_term' = 'Disclosure Date');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `engagement_activity_flag` SET TAGS ('dbx_business_glossary_term' = 'Engagement Activity Flag');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `esg_relevance_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Relevance Flag');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `esg_theme` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Theme');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `esg_theme` SET TAGS ('dbx_value_regex' = 'Climate Change|Board Diversity|Executive Pay|Human Rights|Labor Standards|Anti-Corruption');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `glass_lewis_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Glass Lewis Recommendation');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `glass_lewis_recommendation` SET TAGS ('dbx_value_regex' = 'For|Against|Abstain|Withhold');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `iss_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Institutional Shareholder Services (ISS) Recommendation');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `iss_recommendation` SET TAGS ('dbx_value_regex' = 'For|Against|Abstain|Withhold');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_business_glossary_term' = 'Issuer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `issuer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `issuer_name` SET TAGS ('dbx_business_glossary_term' = 'Issuer Company Name');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `management_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Management Recommendation');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `management_recommendation` SET TAGS ('dbx_value_regex' = 'For|Against|Abstain');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Shareholder Meeting Date');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `meeting_location` SET TAGS ('dbx_business_glossary_term' = 'Meeting Location');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `meeting_outcome` SET TAGS ('dbx_business_glossary_term' = 'Meeting Outcome');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `meeting_outcome` SET TAGS ('dbx_value_regex' = 'Passed|Failed|Withdrawn');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `meeting_type` SET TAGS ('dbx_business_glossary_term' = 'Meeting Type');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `meeting_type` SET TAGS ('dbx_value_regex' = 'AGM|EGM|Special|Class');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `proxy_agent_name` SET TAGS ('dbx_business_glossary_term' = 'Proxy Agent Name');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `public_disclosure_required` SET TAGS ('dbx_business_glossary_term' = 'Public Disclosure Required Flag');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `record_date` SET TAGS ('dbx_business_glossary_term' = 'Record Date');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `regulatory_filing_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Reference');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `resolution_category` SET TAGS ('dbx_business_glossary_term' = 'Resolution Category');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `resolution_description` SET TAGS ('dbx_business_glossary_term' = 'Resolution Description');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `resolution_number` SET TAGS ('dbx_business_glossary_term' = 'Resolution Number');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `resolution_type` SET TAGS ('dbx_business_glossary_term' = 'Resolution Type');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `resolution_type` SET TAGS ('dbx_value_regex' = 'Management|Shareholder');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `security_identifier` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `security_identifier_type` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier Type');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `security_identifier_type` SET TAGS ('dbx_value_regex' = 'ISIN|CUSIP|SEDOL|TICKER|LEI');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `shares_voted` SET TAGS ('dbx_business_glossary_term' = 'Shares Voted Quantity');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `vote_alignment_with_iss` SET TAGS ('dbx_business_glossary_term' = 'Vote Alignment with Institutional Shareholder Services (ISS) Flag');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `vote_alignment_with_management` SET TAGS ('dbx_business_glossary_term' = 'Vote Alignment with Management Flag');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `vote_confirmation_number` SET TAGS ('dbx_business_glossary_term' = 'Vote Confirmation Number');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `vote_direction` SET TAGS ('dbx_business_glossary_term' = 'Vote Direction');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `vote_direction` SET TAGS ('dbx_value_regex' = 'For|Against|Abstain|Withhold|Do Not Vote');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `vote_execution_method` SET TAGS ('dbx_business_glossary_term' = 'Vote Execution Method');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `vote_execution_method` SET TAGS ('dbx_value_regex' = 'Electronic|Paper|Proxy Agent|Direct');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `vote_rationale` SET TAGS ('dbx_business_glossary_term' = 'Vote Rationale');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `vote_recommendation_source` SET TAGS ('dbx_business_glossary_term' = 'Vote Recommendation Source');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `vote_recommendation_source` SET TAGS ('dbx_value_regex' = 'ISS|Glass Lewis|Internal|Management|Other');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `vote_rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Vote Rejection Reason');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `vote_status` SET TAGS ('dbx_business_glossary_term' = 'Vote Status');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `vote_status` SET TAGS ('dbx_value_regex' = 'Submitted|Confirmed|Rejected|Pending|Cancelled');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `vote_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Vote Submission Date');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `votes_against_percentage` SET TAGS ('dbx_business_glossary_term' = 'Votes Against Percentage');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `votes_for_percentage` SET TAGS ('dbx_business_glossary_term' = 'Votes For Percentage');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `voting_power_percentage` SET TAGS ('dbx_business_glossary_term' = 'Voting Power Percentage');
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `pri_reporting_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Principles for Responsible Investment (PRI) Reporting Submission ID');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `framework_id` SET TAGS ('dbx_business_glossary_term' = 'Framework Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `assessment_band` SET TAGS ('dbx_business_glossary_term' = 'PRI Assessment Band');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `assessment_band` SET TAGS ('dbx_value_regex' = 'Five Stars|Four Stars|Three Stars|Two Stars|One Star');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `assessment_score` SET TAGS ('dbx_business_glossary_term' = 'PRI Assessment Score');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `assessment_score` SET TAGS ('dbx_value_regex' = '^[A-E]+?$');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `aum_coverage_amount` SET TAGS ('dbx_business_glossary_term' = 'Assets Under Management (AUM) Coverage Amount');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `aum_coverage_percentage` SET TAGS ('dbx_business_glossary_term' = 'AUM Coverage Percentage');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `indicator_code` SET TAGS ('dbx_business_glossary_term' = 'PRI Indicator Code');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `indicator_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,3}[0-9]{1,2}(.[0-9]{1,2})?$');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `indicator_description` SET TAGS ('dbx_business_glossary_term' = 'Indicator Description');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `module_name` SET TAGS ('dbx_business_glossary_term' = 'PRI Module Name');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `module_name` SET TAGS ('dbx_value_regex' = 'Strategy & Governance|Listed Equity|Private Equity|Real Estate|Infrastructure|Fixed Income');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `peer_comparison_percentile` SET TAGS ('dbx_business_glossary_term' = 'Peer Comparison Percentile');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `prepared_by` SET TAGS ('dbx_business_glossary_term' = 'Prepared By');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `public_disclosure_flag` SET TAGS ('dbx_business_glossary_term' = 'Public Disclosure Flag');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `reporting_year` SET TAGS ('dbx_business_glossary_term' = 'Reporting Year');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `response_type` SET TAGS ('dbx_business_glossary_term' = 'Response Type');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `response_type` SET TAGS ('dbx_value_regex' = 'Quantitative|Qualitative|Binary|Multiple Choice|Descriptive');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `response_unit` SET TAGS ('dbx_business_glossary_term' = 'Response Unit of Measure');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `response_value` SET TAGS ('dbx_business_glossary_term' = 'Response Value');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `reviewed_by` SET TAGS ('dbx_business_glossary_term' = 'Reviewed By');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Date');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `submission_deadline` SET TAGS ('dbx_business_glossary_term' = 'Submission Deadline');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `submission_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Submission Reference Number');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `submission_reference_number` SET TAGS ('dbx_value_regex' = '^PRI-[0-9]{4}-[A-Z0-9]{8}$');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `submission_status` SET TAGS ('dbx_business_glossary_term' = 'Submission Status');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `submission_status` SET TAGS ('dbx_value_regex' = 'Draft|In Review|Submitted|Validated|Published|Rejected');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `supporting_evidence_url` SET TAGS ('dbx_business_glossary_term' = 'Supporting Evidence URL');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `transparency_report_url` SET TAGS ('dbx_business_glossary_term' = 'Transparency Report URL');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `validation_errors` SET TAGS ('dbx_business_glossary_term' = 'Validation Errors');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `validation_status` SET TAGS ('dbx_business_glossary_term' = 'Validation Status');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'Pending|Passed|Failed|Waived');
ALTER TABLE `asset_management`.`esg`.`pri_reporting_submission` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`esg`.`controversy` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`esg`.`controversy` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`controversy` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`controversy` SET TAGS ('dbx_subdomain' = 'ratings_research');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `controversy_id` SET TAGS ('dbx_business_glossary_term' = 'Controversy Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `assigned_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Analyst Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `assigned_analyst_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `assigned_analyst_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `exclusion_list_id` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `issuer_esg_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `analyst_notes` SET TAGS ('dbx_business_glossary_term' = 'Analyst Notes');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `controversy_category` SET TAGS ('dbx_business_glossary_term' = 'Controversy Category');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `controversy_code` SET TAGS ('dbx_business_glossary_term' = 'Controversy Code');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `controversy_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{6,20}$');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `controversy_status` SET TAGS ('dbx_business_glossary_term' = 'Controversy Status');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `controversy_status` SET TAGS ('dbx_value_regex' = 'identified|under_review|escalated|monitoring|resolved|closed');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `controversy_type` SET TAGS ('dbx_business_glossary_term' = 'Controversy Type');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `controversy_type` SET TAGS ('dbx_value_regex' = 'environmental_incident|labor_violation|governance_failure|human_rights|product_safety|corruption');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `divestment_deadline` SET TAGS ('dbx_business_glossary_term' = 'Divestment Deadline');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `divestment_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Divestment Recommendation');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `divestment_recommendation` SET TAGS ('dbx_value_regex' = 'none|monitor|reduce_exposure|full_divestment');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `engagement_initiated_flag` SET TAGS ('dbx_business_glossary_term' = 'Engagement Initiated Flag');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `engagement_status` SET TAGS ('dbx_business_glossary_term' = 'Engagement Status');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `engagement_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|awaiting_response|completed|unsuccessful');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `escalation_date` SET TAGS ('dbx_business_glossary_term' = 'Escalation Date');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `escalation_flag` SET TAGS ('dbx_business_glossary_term' = 'Escalation Flag');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `exclusion_list_flag` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List Flag');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `financial_penalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Financial Penalty Amount');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `geographic_location` SET TAGS ('dbx_business_glossary_term' = 'Geographic Location');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `geographic_location` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `ghg_emissions_related` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Emissions Related');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `ic_decision` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `ic_decision_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision Date');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `ic_submission_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Flag');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `identification_date` SET TAGS ('dbx_business_glossary_term' = 'Identification Date');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `impact_assessment_summary` SET TAGS ('dbx_business_glossary_term' = 'Impact Assessment Summary');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `incident_date` SET TAGS ('dbx_business_glossary_term' = 'Incident Date');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `investee_lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `investee_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `investee_name` SET TAGS ('dbx_business_glossary_term' = 'Investee Name');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `investee_response_summary` SET TAGS ('dbx_business_glossary_term' = 'Investee Response Summary');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `media_url` SET TAGS ('dbx_business_glossary_term' = 'Media Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `penalty_currency` SET TAGS ('dbx_business_glossary_term' = 'Penalty Currency');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `penalty_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `proxy_voting_action` SET TAGS ('dbx_business_glossary_term' = 'Proxy Voting Action');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `proxy_voting_action` SET TAGS ('dbx_value_regex' = 'no_action|vote_against|abstain|withhold|escalate');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `regulatory_action_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Action Flag');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `regulatory_authority` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Resolution Date');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `severity_level` SET TAGS ('dbx_business_glossary_term' = 'Severity Level');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `severity_level` SET TAGS ('dbx_value_regex' = 'low|moderate|high|severe|critical');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `sfdr_pai_indicator` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Principal Adverse Impact (PAI) Indicator');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `source_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Source Reference Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `tcfd_climate_risk_flag` SET TAGS ('dbx_business_glossary_term' = 'Task Force on Climate-related Financial Disclosures (TCFD) Climate Risk Flag');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `un_global_compact_violation` SET TAGS ('dbx_business_glossary_term' = 'United Nations (UN) Global Compact Violation');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `watch_list_flag` SET TAGS ('dbx_business_glossary_term' = 'Watch List Flag');
ALTER TABLE `asset_management`.`esg`.`controversy` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`esg`.`due_diligence` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`esg`.`due_diligence` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`due_diligence` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`due_diligence` SET TAGS ('dbx_subdomain' = 'ratings_research');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `due_diligence_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence ID');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `climate_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `data_provider_id` SET TAGS ('dbx_business_glossary_term' = 'Data Provider Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Dd Engagement Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Assessor ID');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `exclusion_list_id` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `issuer_esg_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `lead_assessor_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Assessor ID');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `assessment_code` SET TAGS ('dbx_business_glossary_term' = 'Assessment Code');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `assessment_code` SET TAGS ('dbx_value_regex' = '^DD-ESG-[0-9]{6}$');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'Assessment Status');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `assessment_team_members` SET TAGS ('dbx_business_glossary_term' = 'Assessment Team Members');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `assessment_type` SET TAGS ('dbx_business_glossary_term' = 'Assessment Type');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `assessment_type` SET TAGS ('dbx_value_regex' = 'new_investment|co_investment|fund_manager_selection|portfolio_company_review|follow_on_investment|secondary_transaction');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `carbon_intensity_metric` SET TAGS ('dbx_business_glossary_term' = 'Carbon Intensity Metric');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `carbon_intensity_value` SET TAGS ('dbx_business_glossary_term' = 'Carbon Intensity Value');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `climate_risk_assessment` SET TAGS ('dbx_business_glossary_term' = 'Climate Risk Assessment');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `climate_risk_assessment` SET TAGS ('dbx_value_regex' = 'low|moderate|high|critical');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'Completion Date');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `controversy_description` SET TAGS ('dbx_business_glossary_term' = 'Controversy Description');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `controversy_description` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `controversy_level` SET TAGS ('dbx_business_glossary_term' = 'Controversy Level');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `controversy_level` SET TAGS ('dbx_value_regex' = 'none|low|moderate|high|severe');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `engagement_priority_flag` SET TAGS ('dbx_business_glossary_term' = 'Engagement Priority Flag');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `engagement_topics` SET TAGS ('dbx_business_glossary_term' = 'Engagement Topics');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `environmental_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental Score');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `esg_overall_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Overall Score');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `esg_rating_provider` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating Provider');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `esg_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Risk Rating');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `esg_risk_rating` SET TAGS ('dbx_value_regex' = 'negligible|low|medium|high|severe');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `exclusion_criteria_breached` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Criteria Breached');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `exclusion_policy_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Policy Breach Flag');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `external_advisor_name` SET TAGS ('dbx_business_glossary_term' = 'External Advisor Name');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `external_advisor_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `governance_score` SET TAGS ('dbx_business_glossary_term' = 'Governance Score');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `ic_decision` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `ic_decision` SET TAGS ('dbx_value_regex' = 'approved|approved_with_conditions|rejected|deferred|withdrawn');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `ic_decision_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision Date');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `ic_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Date');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `initiation_date` SET TAGS ('dbx_business_glossary_term' = 'Initiation Date');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `net_zero_commitment_flag` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Commitment Flag');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `net_zero_target_year` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Target Year');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `pri_signatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Principles for Responsible Investment (PRI) Signatory Flag');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `recommendation` SET TAGS ('dbx_business_glossary_term' = 'Recommendation');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `recommendation` SET TAGS ('dbx_value_regex' = 'proceed|proceed_with_conditions|decline|further_review_required');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `recommendation_rationale` SET TAGS ('dbx_business_glossary_term' = 'Recommendation Rationale');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `recommendation_rationale` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `scope_1_emissions_tco2e` SET TAGS ('dbx_business_glossary_term' = 'Scope 1 Emissions Tonnes Carbon Dioxide Equivalent (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `scope_2_emissions_tco2e` SET TAGS ('dbx_business_glossary_term' = 'Scope 2 Emissions Tonnes Carbon Dioxide Equivalent (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `scope_3_emissions_tco2e` SET TAGS ('dbx_business_glossary_term' = 'Scope 3 Emissions Tonnes Carbon Dioxide Equivalent (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `sfdr_article_classification` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Article Classification');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `sfdr_article_classification` SET TAGS ('dbx_value_regex' = 'article_6|article_8|article_9|not_applicable');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `social_score` SET TAGS ('dbx_business_glossary_term' = 'Social Score');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `target_entity_country` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Country');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `target_entity_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `target_entity_lei` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `target_entity_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `target_entity_lei` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `target_sector` SET TAGS ('dbx_business_glossary_term' = 'Target Sector');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `taxonomy_alignment_pct` SET TAGS ('dbx_business_glossary_term' = 'Taxonomy Alignment Percentage');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `un_global_compact_violation_flag` SET TAGS ('dbx_business_glossary_term' = 'United Nations (UN) Global Compact Violation Flag');
ALTER TABLE `asset_management`.`esg`.`due_diligence` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`esg`.`kpi_target` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`esg`.`kpi_target` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`kpi_target` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`kpi_target` SET TAGS ('dbx_subdomain' = 'climate_metrics');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `kpi_target_id` SET TAGS ('dbx_business_glossary_term' = 'Key Performance Indicator (KPI) Target Identifier');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `framework_id` SET TAGS ('dbx_business_glossary_term' = 'Framework Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `holding_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Holding Identifier');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `achievement_status` SET TAGS ('dbx_business_glossary_term' = 'Achievement Status');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `achievement_status` SET TAGS ('dbx_value_regex' = 'on_track|at_risk|off_track|achieved|not_started');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equities|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `baseline_value` SET TAGS ('dbx_business_glossary_term' = 'Baseline Value');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `baseline_year` SET TAGS ('dbx_business_glossary_term' = 'Baseline Year');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `escalation_threshold_pct` SET TAGS ('dbx_business_glossary_term' = 'Escalation Threshold Percentage');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `interim_target_value` SET TAGS ('dbx_business_glossary_term' = 'Interim Target Value');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `interim_target_year` SET TAGS ('dbx_business_glossary_term' = 'Interim Target Year');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `kpi_category` SET TAGS ('dbx_business_glossary_term' = 'Key Performance Indicator (KPI) Category');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `kpi_category` SET TAGS ('dbx_value_regex' = 'environmental|social|governance|climate|diversity|health_safety');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `kpi_code` SET TAGS ('dbx_business_glossary_term' = 'Key Performance Indicator (KPI) Code');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `kpi_name` SET TAGS ('dbx_business_glossary_term' = 'Key Performance Indicator (KPI) Name');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `kpi_subcategory` SET TAGS ('dbx_business_glossary_term' = 'Key Performance Indicator (KPI) Subcategory');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `last_measured_value` SET TAGS ('dbx_business_glossary_term' = 'Last Measured Value');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `last_measurement_date` SET TAGS ('dbx_business_glossary_term' = 'Last Measurement Date');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `methodology` SET TAGS ('dbx_business_glossary_term' = 'Methodology');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `owner` SET TAGS ('dbx_business_glossary_term' = 'Owner');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `paris_alignment_flag` SET TAGS ('dbx_business_glossary_term' = 'Paris Alignment Flag');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `progress_pct` SET TAGS ('dbx_business_glossary_term' = 'Progress Percentage');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `public_disclosure_required` SET TAGS ('dbx_business_glossary_term' = 'Public Disclosure Required');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `review_frequency_months` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency in Months');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `sbti_validated_flag` SET TAGS ('dbx_business_glossary_term' = 'Science Based Targets Initiative (SBTi) Validated Flag');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `target_scope` SET TAGS ('dbx_business_glossary_term' = 'Target Scope');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `target_scope` SET TAGS ('dbx_value_regex' = 'portfolio|asset_class|holding|fund');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `target_status` SET TAGS ('dbx_business_glossary_term' = 'Target Status');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `target_status` SET TAGS ('dbx_value_regex' = 'draft|active|achieved|missed|suspended|cancelled');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `target_type` SET TAGS ('dbx_business_glossary_term' = 'Target Type');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `target_type` SET TAGS ('dbx_value_regex' = 'absolute|intensity|percentage|binary');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `target_unit` SET TAGS ('dbx_business_glossary_term' = 'Target Unit of Measure');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `target_value` SET TAGS ('dbx_business_glossary_term' = 'Target Value');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `target_year` SET TAGS ('dbx_business_glossary_term' = 'Target Year');
ALTER TABLE `asset_management`.`esg`.`kpi_target` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` SET TAGS ('dbx_subdomain' = 'climate_metrics');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `kpi_measurement_id` SET TAGS ('dbx_business_glossary_term' = 'Key Performance Indicator (KPI) Measurement Identifier');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `data_provider_id` SET TAGS ('dbx_business_glossary_term' = 'Data Provider Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `kpi_kpi_target_id` SET TAGS ('dbx_business_glossary_term' = 'Key Performance Indicator (KPI) Identifier');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `kpi_target_id` SET TAGS ('dbx_business_glossary_term' = 'Kpi Target Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `portfolio_holding_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Holding Identifier');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `actual_value` SET TAGS ('dbx_business_glossary_term' = 'Actual Value');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|under_review');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `baseline_value` SET TAGS ('dbx_business_glossary_term' = 'Baseline Value');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `baseline_year` SET TAGS ('dbx_business_glossary_term' = 'Baseline Year');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Calculation Method');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `calculation_method` SET TAGS ('dbx_value_regex' = 'direct|attribution|normalization|aggregation|weighted_average');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `data_coverage_percentage` SET TAGS ('dbx_business_glossary_term' = 'Data Coverage Percentage');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `data_quality_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Flag');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `data_source_type` SET TAGS ('dbx_business_glossary_term' = 'Data Source Type');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `data_source_type` SET TAGS ('dbx_value_regex' = 'reported|estimated|modeled|third_party|proxy');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `exception_flag` SET TAGS ('dbx_business_glossary_term' = 'Exception Flag');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `exception_reason` SET TAGS ('dbx_business_glossary_term' = 'Exception Reason');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `gri_indicator_code` SET TAGS ('dbx_business_glossary_term' = 'Global Reporting Initiative (GRI) Indicator Code');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `materiality_assessment` SET TAGS ('dbx_business_glossary_term' = 'Materiality Assessment');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `materiality_assessment` SET TAGS ('dbx_value_regex' = 'material|non_material|under_review');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `measurement_date` SET TAGS ('dbx_business_glossary_term' = 'Measurement Date');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `measurement_frequency` SET TAGS ('dbx_business_glossary_term' = 'Measurement Frequency');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `measurement_frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annually|ad_hoc');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `measurement_methodology` SET TAGS ('dbx_business_glossary_term' = 'Measurement Methodology');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `measurement_notes` SET TAGS ('dbx_business_glossary_term' = 'Measurement Notes');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `measurement_status` SET TAGS ('dbx_business_glossary_term' = 'Measurement Status');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `measurement_status` SET TAGS ('dbx_value_regex' = 'measured|estimated|projected|pending|verified|rejected');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `on_track_flag` SET TAGS ('dbx_business_glossary_term' = 'On Track Flag');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `progress_to_target_percentage` SET TAGS ('dbx_business_glossary_term' = 'Progress to Target Percentage');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `sasb_metric_code` SET TAGS ('dbx_business_glossary_term' = 'Sustainability Accounting Standards Board (SASB) Metric Code');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `sfdr_pai_indicator` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Principal Adverse Impact (PAI) Indicator');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `target_value` SET TAGS ('dbx_business_glossary_term' = 'Target Value');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `tcfd_alignment_flag` SET TAGS ('dbx_business_glossary_term' = 'Task Force on Climate-related Financial Disclosures (TCFD) Alignment Flag');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `variance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Variance Percentage');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `variance_value` SET TAGS ('dbx_business_glossary_term' = 'Variance Value');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `verification_body` SET TAGS ('dbx_business_glossary_term' = 'Verification Body');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Verification Date');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `verification_status` SET TAGS ('dbx_business_glossary_term' = 'Verification Status');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `verification_status` SET TAGS ('dbx_value_regex' = 'verified|unverified|pending_verification|rejected');
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` SET TAGS ('dbx_subdomain' = 'ratings_research');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `integration_checklist_id` SET TAGS ('dbx_business_glossary_term' = 'Integration Checklist ID');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `assigned_to_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned To Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `assigned_to_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `assigned_to_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Dd Engagement Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `esg_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Esg Benchmark Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `exclusion_list_id` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `ic_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Ic Decision Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `investment_id` SET TAGS ('dbx_business_glossary_term' = 'Investment ID');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `approved_by` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `checklist_identifier` SET TAGS ('dbx_business_glossary_term' = 'Checklist Identifier');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `checklist_status` SET TAGS ('dbx_business_glossary_term' = 'Checklist Status');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `checklist_type` SET TAGS ('dbx_business_glossary_term' = 'Checklist Type');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `completed_items` SET TAGS ('dbx_business_glossary_term' = 'Completed Items');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'Completion Date');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `completion_percentage` SET TAGS ('dbx_business_glossary_term' = 'Completion Percentage');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `controversy_level` SET TAGS ('dbx_business_glossary_term' = 'Controversy Level');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `controversy_level` SET TAGS ('dbx_value_regex' = 'none|low|medium|high|severe');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `document_reference_url` SET TAGS ('dbx_business_glossary_term' = 'Document Reference URL');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Due Date');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `engagement_priority` SET TAGS ('dbx_business_glossary_term' = 'Engagement Priority');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `engagement_priority` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `engagement_required` SET TAGS ('dbx_business_glossary_term' = 'Engagement Required');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `environmental_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental Score');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `exclusion_criteria_breached` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Criteria Breached');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `exclusion_details` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Details');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `governance_score` SET TAGS ('dbx_business_glossary_term' = 'Governance Score');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `ic_conditions` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Conditions');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `ic_decision` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `ic_decision` SET TAGS ('dbx_value_regex' = 'approved|rejected|conditional_approval|deferred|not_submitted');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `ic_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Date');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `investment_stage` SET TAGS ('dbx_business_glossary_term' = 'Investment Stage');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `material_esg_risks_identified` SET TAGS ('dbx_business_glossary_term' = 'Material ESG Risks Identified');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `methodology_version` SET TAGS ('dbx_business_glossary_term' = 'Methodology Version');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `mitigation_actions_required` SET TAGS ('dbx_business_glossary_term' = 'Mitigation Actions Required');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `mitigation_plan` SET TAGS ('dbx_business_glossary_term' = 'Mitigation Plan');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `overall_esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Overall ESG Rating');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `paris_alignment_flag` SET TAGS ('dbx_business_glossary_term' = 'Paris Alignment Flag');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `review_frequency_months` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency Months');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `reviewer` SET TAGS ('dbx_business_glossary_term' = 'Reviewer');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `reviewer` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `risk_summary` SET TAGS ('dbx_business_glossary_term' = 'Risk Summary');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_business_glossary_term' = 'SFDR Classification');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_value_regex' = 'article_6|article_8|article_9|not_applicable');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `social_score` SET TAGS ('dbx_business_glossary_term' = 'Social Score');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `tcfd_alignment_flag` SET TAGS ('dbx_business_glossary_term' = 'TCFD Alignment Flag');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `total_items` SET TAGS ('dbx_business_glossary_term' = 'Total Items');
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ALTER COLUMN `un_global_compact_violation_flag` SET TAGS ('dbx_business_glossary_term' = 'UN Global Compact Violation Flag');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` SET TAGS ('dbx_subdomain' = 'climate_metrics');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `net_zero_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Commitment Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `framework_id` SET TAGS ('dbx_business_glossary_term' = 'Framework Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `net_esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Related Policy Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `net_related_policy_esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Related Policy Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `base_year` SET TAGS ('dbx_business_glossary_term' = 'Baseline Year');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `base_year_emissions_tco2e` SET TAGS ('dbx_business_glossary_term' = 'Baseline Year Emissions in Tonnes Carbon Dioxide Equivalent (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `carbon_offset_allowed` SET TAGS ('dbx_business_glossary_term' = 'Carbon Offset Allowed Flag');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `carbon_removal_allowed` SET TAGS ('dbx_business_glossary_term' = 'Carbon Removal Allowed Flag');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `commitment_code` SET TAGS ('dbx_business_glossary_term' = 'Commitment Code');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `commitment_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,20}$');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `commitment_name` SET TAGS ('dbx_business_glossary_term' = 'Commitment Name');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `commitment_owner` SET TAGS ('dbx_business_glossary_term' = 'Commitment Owner');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `commitment_scope` SET TAGS ('dbx_business_glossary_term' = 'Commitment Scope');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `commitment_scope` SET TAGS ('dbx_value_regex' = 'Total_Portfolio|Asset_Class|Sector|Geography|Fund');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `commitment_status` SET TAGS ('dbx_business_glossary_term' = 'Commitment Status');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `decarbonization_strategy` SET TAGS ('dbx_business_glossary_term' = 'Decarbonization Strategy');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `divestment_threshold_defined` SET TAGS ('dbx_business_glossary_term' = 'Divestment Threshold Defined Flag');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `document_url` SET TAGS ('dbx_business_glossary_term' = 'Document Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `engagement_priority` SET TAGS ('dbx_business_glossary_term' = 'Engagement Priority Flag');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `external_verification_required` SET TAGS ('dbx_business_glossary_term' = 'External Verification Required Flag');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `financed_emissions_methodology` SET TAGS ('dbx_business_glossary_term' = 'Financed Emissions Methodology');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `financed_emissions_methodology` SET TAGS ('dbx_value_regex' = 'PCAF|TCFD|SBTi_FI|Custom|Other');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `green_investment_target_pct` SET TAGS ('dbx_business_glossary_term' = 'Green Investment Target Percentage');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `interim_reduction_target_pct` SET TAGS ('dbx_business_glossary_term' = 'Interim Reduction Target Percentage');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `interim_target_year` SET TAGS ('dbx_business_glossary_term' = 'Interim Target Year');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active Flag');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `net_zero_definition` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Definition');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `net_zero_target_year` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Target Year');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `paris_alignment_flag` SET TAGS ('dbx_business_glossary_term' = 'Paris Agreement Alignment Flag');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `public_disclosure_required` SET TAGS ('dbx_business_glossary_term' = 'Public Disclosure Required Flag');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'Annual|Semi_Annual|Quarterly|Ad_Hoc');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `review_frequency_months` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency in Months');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `scope_1_included` SET TAGS ('dbx_business_glossary_term' = 'Scope 1 Emissions Included Flag');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `scope_2_included` SET TAGS ('dbx_business_glossary_term' = 'Scope 2 Emissions Included Flag');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `scope_3_included` SET TAGS ('dbx_business_glossary_term' = 'Scope 3 Emissions Included Flag');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `temperature_alignment_target` SET TAGS ('dbx_business_glossary_term' = 'Temperature Alignment Target');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `temperature_alignment_target` SET TAGS ('dbx_value_regex' = '1.5C|Well_Below_2C|2C|Other');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `verification_body` SET TAGS ('dbx_business_glossary_term' = 'Verification Body');
ALTER TABLE `asset_management`.`esg`.`net_zero_commitment` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` SET TAGS ('dbx_subdomain' = 'ratings_research');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `esg_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Benchmark Identifier');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `framework_id` SET TAGS ('dbx_business_glossary_term' = 'Framework Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `administrator` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Administrator');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `approved_for_use_flag` SET TAGS ('dbx_business_glossary_term' = 'Approved for Use Flag');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `base_index_name` SET TAGS ('dbx_business_glossary_term' = 'Base Index Name');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `benchmark_category` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Category');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `benchmark_code` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Code');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `benchmark_name` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Name');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `benchmark_type` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Type');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `carbon_intensity_reduction_target_pct` SET TAGS ('dbx_business_glossary_term' = 'Carbon Intensity Reduction Target Percentage');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `climate_alignment_target` SET TAGS ('dbx_business_glossary_term' = 'Climate Alignment Target');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `data_source_url` SET TAGS ('dbx_business_glossary_term' = 'Data Source Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `esg_benchmark_status` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Status');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `esg_benchmark_status` SET TAGS ('dbx_value_regex' = 'Active|Discontinued|Under Review|Suspended|Retired|Pending Launch');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `esg_methodology` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Methodology');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `esg_rating_provider` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Rating Provider');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `eu_climate_benchmark_flag` SET TAGS ('dbx_business_glossary_term' = 'European Union (EU) Climate Benchmark Flag');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `exclusion_criteria` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Criteria');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `fossil_fuel_exposure_limit_pct` SET TAGS ('dbx_business_glossary_term' = 'Fossil Fuel Exposure Limit Percentage');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `green_revenue_alignment_pct` SET TAGS ('dbx_business_glossary_term' = 'Green Revenue Alignment Percentage');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Inception Date');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `last_rebalance_date` SET TAGS ('dbx_business_glossary_term' = 'Last Rebalance Date');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Review Date');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `methodology_document_url` SET TAGS ('dbx_business_glossary_term' = 'Methodology Document Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `minimum_esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Minimum Environmental, Social, and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `next_rebalance_date` SET TAGS ('dbx_business_glossary_term' = 'Next Rebalance Date');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `number_of_constituents` SET TAGS ('dbx_business_glossary_term' = 'Number of Constituents');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `pri_signatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Principles for Responsible Investment (PRI) Signatory Flag');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `provider` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Provider');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rebalancing Frequency');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `rebalancing_frequency` SET TAGS ('dbx_value_regex' = 'Daily|Weekly|Monthly|Quarterly|Semi-Annually|Annually');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `regulatory_authorization` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authorization');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `review_frequency_months` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency in Months');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Classification');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_value_regex' = 'Article 6|Article 8|Article 9|Not Classified');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `tcfd_alignment_flag` SET TAGS ('dbx_business_glossary_term' = 'Task Force on Climate-related Financial Disclosures (TCFD) Alignment Flag');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `un_sdg_alignment` SET TAGS ('dbx_business_glossary_term' = 'United Nations Sustainable Development Goals (UN SDG) Alignment');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `usage_scope` SET TAGS ('dbx_business_glossary_term' = 'Usage Scope');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `weighting_methodology` SET TAGS ('dbx_business_glossary_term' = 'Weighting Methodology');
ALTER TABLE `asset_management`.`esg`.`esg_benchmark` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`esg`.`data_provider` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`esg`.`data_provider` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`data_provider` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`data_provider` SET TAGS ('dbx_subdomain' = 'ratings_research');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `data_provider_id` SET TAGS ('dbx_business_glossary_term' = 'Data Provider Identifier (ID)');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `annual_subscription_cost` SET TAGS ('dbx_business_glossary_term' = 'Annual Subscription Cost');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `annual_subscription_cost` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `api_endpoint_url` SET TAGS ('dbx_business_glossary_term' = 'API (Application Programming Interface) Endpoint URL (Uniform Resource Locator)');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `api_endpoint_url` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `contract_end_date` SET TAGS ('dbx_business_glossary_term' = 'Contract End Date');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `contract_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Contract Reference Number');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `contract_reference_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `contract_start_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Start Date');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `cost_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Currency Code');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `cost_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `coverage_asset_classes` SET TAGS ('dbx_business_glossary_term' = 'Coverage Asset Classes');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `coverage_geography` SET TAGS ('dbx_business_glossary_term' = 'Coverage Geography');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `coverage_issuer_count` SET TAGS ('dbx_business_glossary_term' = 'Coverage Issuer Count');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `data_delivery_frequency` SET TAGS ('dbx_business_glossary_term' = 'Data Delivery Frequency');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `data_delivery_method` SET TAGS ('dbx_business_glossary_term' = 'Data Delivery Method');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `data_delivery_method` SET TAGS ('dbx_value_regex' = 'api|sftp|portal|email|vendor_platform|data_feed');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `data_format` SET TAGS ('dbx_business_glossary_term' = 'Data Format');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `data_products_subscribed` SET TAGS ('dbx_business_glossary_term' = 'Data Products Subscribed');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `data_quality_last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Last Review Date');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `data_usage_restrictions` SET TAGS ('dbx_business_glossary_term' = 'Data Usage Restrictions');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `data_usage_restrictions` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `headquarters_country` SET TAGS ('dbx_business_glossary_term' = 'Headquarters Country');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `headquarters_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `methodology_framework` SET TAGS ('dbx_business_glossary_term' = 'Methodology Framework');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `methodology_last_updated_date` SET TAGS ('dbx_business_glossary_term' = 'Methodology Last Updated Date');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `methodology_version` SET TAGS ('dbx_business_glossary_term' = 'Methodology Version');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `payment_terms` SET TAGS ('dbx_business_glossary_term' = 'Payment Terms');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `payment_terms` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `portal_url` SET TAGS ('dbx_business_glossary_term' = 'Portal URL (Uniform Resource Locator)');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Email Address');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Name');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Phone Number');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `provider_code` SET TAGS ('dbx_business_glossary_term' = 'Provider Code');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `provider_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `provider_name` SET TAGS ('dbx_business_glossary_term' = 'Provider Name');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `provider_status` SET TAGS ('dbx_business_glossary_term' = 'Provider Status');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `provider_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|under_review|terminated');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `provider_type` SET TAGS ('dbx_business_glossary_term' = 'Provider Type');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `provider_type` SET TAGS ('dbx_value_regex' = 'rating_agency|data_vendor|research_provider|index_provider|disclosure_platform|multi_service');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `regulatory_alignment` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Alignment');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `review_frequency_months` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency Months');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `sfdr_pai_coverage_flag` SET TAGS ('dbx_business_glossary_term' = 'SFDR (Sustainable Finance Disclosure Regulation) PAI (Principal Adverse Impact) Coverage Flag');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `sftp_host` SET TAGS ('dbx_business_glossary_term' = 'SFTP (Secure File Transfer Protocol) Host');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `sftp_host` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `sla_support_response_time_hours` SET TAGS ('dbx_business_glossary_term' = 'SLA (Service Level Agreement) Support Response Time Hours');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `sla_uptime_percentage` SET TAGS ('dbx_business_glossary_term' = 'SLA (Service Level Agreement) Uptime Percentage');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `tcfd_alignment_flag` SET TAGS ('dbx_business_glossary_term' = 'TCFD (Task Force on Climate-related Financial Disclosures) Alignment Flag');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `vendor_risk_last_assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Vendor Risk Last Assessment Date');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `vendor_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Vendor Risk Rating');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `vendor_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`esg`.`data_provider` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`esg`.`watch_list` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`esg`.`watch_list` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`watch_list` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`watch_list` SET TAGS ('dbx_subdomain' = 'climate_metrics');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `watch_list_id` SET TAGS ('dbx_business_glossary_term' = 'Watch List ID');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `controversy_id` SET TAGS ('dbx_business_glossary_term' = 'Controversy Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `exclusion_list_id` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `issuer_esg_rating_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer Esg Rating Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Owner Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `rule_id` SET TAGS ('dbx_business_glossary_term' = 'Rule Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `watch_list_category` SET TAGS ('dbx_business_glossary_term' = 'Watch List Category');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `watch_list_category` SET TAGS ('dbx_value_regex' = 'esg_rating_deterioration|controversy|policy_breach|regulatory_violation|engagement_escalation|exclusion_candidate');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `closure_reason` SET TAGS ('dbx_business_glossary_term' = 'Closure Reason');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `controversy_description` SET TAGS ('dbx_business_glossary_term' = 'Controversy Description');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `controversy_level` SET TAGS ('dbx_business_glossary_term' = 'Controversy Level');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `controversy_level` SET TAGS ('dbx_value_regex' = 'low|moderate|high|severe');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `divestment_deadline` SET TAGS ('dbx_business_glossary_term' = 'Divestment Deadline');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `divestment_recommendation_flag` SET TAGS ('dbx_business_glossary_term' = 'Divestment Recommendation Flag');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `divestment_status` SET TAGS ('dbx_business_glossary_term' = 'Divestment Status');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `divestment_status` SET TAGS ('dbx_value_regex' = 'not_applicable|planned|in_progress|completed|deferred');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `engagement_objective` SET TAGS ('dbx_business_glossary_term' = 'Engagement Objective');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `engagement_status` SET TAGS ('dbx_business_glossary_term' = 'Engagement Status');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `engagement_status` SET TAGS ('dbx_value_regex' = 'not_initiated|active|escalated|suspended|completed');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `entity_lei` SET TAGS ('dbx_business_glossary_term' = 'Entity Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `entity_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `entity_name` SET TAGS ('dbx_business_glossary_term' = 'Entity Name');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `entity_type` SET TAGS ('dbx_business_glossary_term' = 'Entity Type');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `entity_type` SET TAGS ('dbx_value_regex' = 'issuer|fund|manager|counterparty|security|portfolio_holding');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `escalation_level` SET TAGS ('dbx_business_glossary_term' = 'Escalation Level');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `escalation_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `esg_rating_change_date` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating Change Date');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `esg_rating_current` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating Current');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `esg_rating_previous` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating Previous');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `esg_rating_provider` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating Provider');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `ghg_emissions_intensity` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Emissions Intensity');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `holding_value_at_placement` SET TAGS ('dbx_business_glossary_term' = 'Holding Value at Placement');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `holding_value_currency` SET TAGS ('dbx_business_glossary_term' = 'Holding Value Currency');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `holding_value_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `identifier` SET TAGS ('dbx_business_glossary_term' = 'Watch List Identifier');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `issuer_country` SET TAGS ('dbx_business_glossary_term' = 'Issuer Country');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `issuer_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `paris_alignment_flag` SET TAGS ('dbx_business_glossary_term' = 'Paris Alignment Flag');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `placement_date` SET TAGS ('dbx_business_glossary_term' = 'Placement Date');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `policy_breach_type` SET TAGS ('dbx_business_glossary_term' = 'Policy Breach Type');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `policy_reference` SET TAGS ('dbx_business_glossary_term' = 'Policy Reference');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `proxy_voting_restriction` SET TAGS ('dbx_business_glossary_term' = 'Proxy Voting Restriction');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `proxy_voting_restriction` SET TAGS ('dbx_value_regex' = 'none|against_management|abstain|case_by_case');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `resolution_action` SET TAGS ('dbx_business_glossary_term' = 'Resolution Action');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Resolution Date');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'Review Date');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `review_frequency_months` SET TAGS ('dbx_business_glossary_term' = 'Review Frequency Months');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `security_identifier` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `security_identifier_type` SET TAGS ('dbx_business_glossary_term' = 'Security Identifier Type');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `security_identifier_type` SET TAGS ('dbx_value_regex' = 'ISIN|CUSIP|SEDOL|TICKER|INTERNAL');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Classification');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_value_regex' = 'Article_6|Article_8|Article_9');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `tcfd_climate_risk_flag` SET TAGS ('dbx_business_glossary_term' = 'Task Force on Climate-related Financial Disclosures (TCFD) Climate Risk Flag');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `trigger_date` SET TAGS ('dbx_business_glossary_term' = 'Trigger Date');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `trigger_event` SET TAGS ('dbx_business_glossary_term' = 'Trigger Event');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `un_global_compact_violation_flag` SET TAGS ('dbx_business_glossary_term' = 'United Nations (UN) Global Compact Violation Flag');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `watch_list_status` SET TAGS ('dbx_business_glossary_term' = 'Watch List Status');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `watch_list_status` SET TAGS ('dbx_value_regex' = 'active|under_review|escalated|resolved|closed');
ALTER TABLE `asset_management`.`esg`.`watch_list` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `responsible_investment_report_id` SET TAGS ('dbx_business_glossary_term' = 'Responsible Investment (RI) Report Identifier');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `composite_id` SET TAGS ('dbx_business_glossary_term' = 'Composite Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `framework_id` SET TAGS ('dbx_business_glossary_term' = 'Framework Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `net_zero_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Commitment Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `superseded_report_responsible_investment_report_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded Report Identifier');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `asset_class_coverage` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Coverage');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `assurance_level` SET TAGS ('dbx_business_glossary_term' = 'Assurance Level');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `assurance_level` SET TAGS ('dbx_value_regex' = 'limited|reasonable|not_applicable');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `assurance_provider_name` SET TAGS ('dbx_business_glossary_term' = 'Assurance Provider Name');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `aum_covered` SET TAGS ('dbx_business_glossary_term' = 'Assets Under Management (AUM) Covered');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `aum_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Assets Under Management (AUM) Currency Code');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `aum_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `carbon_footprint_per_million_invested` SET TAGS ('dbx_business_glossary_term' = 'Carbon Footprint per Million Invested');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `climate_action_summary` SET TAGS ('dbx_business_glossary_term' = 'Climate Action Summary');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `disclosure_level` SET TAGS ('dbx_business_glossary_term' = 'Disclosure Level');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `disclosure_level` SET TAGS ('dbx_value_regex' = 'public|confidential|restricted|internal');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `document_url` SET TAGS ('dbx_business_glossary_term' = 'Document Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `engagement_activity_summary` SET TAGS ('dbx_business_glossary_term' = 'Engagement Activity Summary');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `esg_integration_summary` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Integration Summary');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `exclusion_criteria_summary` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Criteria Summary');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `exclusion_policy_applied_flag` SET TAGS ('dbx_business_glossary_term' = 'Exclusion Policy Applied Flag');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `external_assurance_obtained_flag` SET TAGS ('dbx_business_glossary_term' = 'External Assurance Obtained Flag');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Geographic Scope');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `language` SET TAGS ('dbx_business_glossary_term' = 'Language');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `language` SET TAGS ('dbx_value_regex' = '^[a-z]{2}$');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `net_zero_commitment_flag` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Commitment Flag');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `net_zero_target_year` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Target Year');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `next_publication_date` SET TAGS ('dbx_business_glossary_term' = 'Next Publication Date');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `prepared_by` SET TAGS ('dbx_business_glossary_term' = 'Prepared By');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `pri_signatory_status` SET TAGS ('dbx_business_glossary_term' = 'Principles for Responsible Investment (PRI) Signatory Status');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `pri_signatory_status` SET TAGS ('dbx_value_regex' = 'signatory|non_signatory|pending');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `proxy_voting_summary` SET TAGS ('dbx_business_glossary_term' = 'Proxy Voting Summary');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `publication_date` SET TAGS ('dbx_business_glossary_term' = 'Publication Date');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `report_code` SET TAGS ('dbx_business_glossary_term' = 'Report Code');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `report_status` SET TAGS ('dbx_business_glossary_term' = 'Report Status');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `report_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|published|archived|superseded');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `report_title` SET TAGS ('dbx_business_glossary_term' = 'Report Title');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `report_type` SET TAGS ('dbx_business_glossary_term' = 'Report Type');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `report_type` SET TAGS ('dbx_value_regex' = 'annual_ri_report|pri_transparency_report|tcfd_disclosure|sfdr_periodic_disclosure|esg_stewardship_report|climate_action_report');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `report_year` SET TAGS ('dbx_business_glossary_term' = 'Report Year');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `reviewed_by` SET TAGS ('dbx_business_glossary_term' = 'Reviewed By');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Classification');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `sfdr_classification` SET TAGS ('dbx_value_regex' = 'article_6|article_8|article_9|not_applicable');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Date');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `target_audience` SET TAGS ('dbx_business_glossary_term' = 'Target Audience');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `target_audience` SET TAGS ('dbx_value_regex' = 'beneficiaries|regulators|public|investment_committee|board|external_stakeholders');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `tcfd_alignment_flag` SET TAGS ('dbx_business_glossary_term' = 'Task Force on Climate-related Financial Disclosures (TCFD) Alignment Flag');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `total_ghg_emissions_tco2e` SET TAGS ('dbx_business_glossary_term' = 'Total Greenhouse Gas (GHG) Emissions in Tonnes of Carbon Dioxide Equivalent (tCO2e)');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `pai_indicator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Adverse Impact Indicator ID (PAI ID)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `credit_issuer_id` SET TAGS ('dbx_business_glossary_term' = 'Issuer ID (Issuer Identifier)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `framework_id` SET TAGS ('dbx_business_glossary_term' = 'Framework Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `sfdr_disclosure_id` SET TAGS ('dbx_business_glossary_term' = 'Sfdr Disclosure Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp (Created Timestamp)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `indicator_code` SET TAGS ('dbx_business_glossary_term' = 'Indicator Code (Indicator Code)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `indicator_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,10}$');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `indicator_description` SET TAGS ('dbx_business_glossary_term' = 'Indicator Description (Indicator Description)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `indicator_name` SET TAGS ('dbx_business_glossary_term' = 'Indicator Name (Indicator Name)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `indicator_pai_disclosure_date` SET TAGS ('dbx_business_glossary_term' = 'PAI Disclosure Date (PAI Disclosure Date)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `indicator_pai_disclosure_document_url` SET TAGS ('dbx_business_glossary_term' = 'PAI Disclosure Document URL (PAI Disclosure Document URL)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `indicator_pai_disclosure_notes` SET TAGS ('dbx_business_glossary_term' = 'PAI Disclosure Notes (PAI Disclosure Notes)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `indicator_pai_disclosure_required` SET TAGS ('dbx_business_glossary_term' = 'PAI Disclosure Required (PAI Disclosure Required)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `indicator_pai_disclosure_status` SET TAGS ('dbx_business_glossary_term' = 'PAI Disclosure Status (PAI Disclosure Status)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `indicator_pai_disclosure_status` SET TAGS ('dbx_value_regex' = 'required|not_required|pending');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `indicator_source` SET TAGS ('dbx_business_glossary_term' = 'Indicator Source (Indicator Source)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `indicator_source_date` SET TAGS ('dbx_business_glossary_term' = 'Indicator Source Date (Indicator Source Date)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `indicator_source_version` SET TAGS ('dbx_business_glossary_term' = 'Indicator Source Version (Indicator Source Version)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `indicator_type` SET TAGS ('dbx_business_glossary_term' = 'Indicator Type (Indicator Type)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `indicator_type` SET TAGS ('dbx_value_regex' = 'environmental|social|governance');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `indicator_unit` SET TAGS ('dbx_business_glossary_term' = 'Indicator Unit (Indicator Unit)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `indicator_value` SET TAGS ('dbx_business_glossary_term' = 'Indicator Value (Indicator Value)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `pai_indicator_status` SET TAGS ('dbx_business_glossary_term' = 'Status (Status)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `pai_indicator_status` SET TAGS ('dbx_value_regex' = 'active|inactive|archived');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date (Reporting Period End)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date (Reporting Period Start)');
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp (Updated Timestamp)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` SET TAGS ('dbx_domain' = 'esg');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `taxonomy_alignment_id` SET TAGS ('dbx_business_glossary_term' = 'Taxonomy Alignment ID');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `infra_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Asset ID (ASSET_ID)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `framework_id` SET TAGS ('dbx_business_glossary_term' = 'Framework Id (Foreign Key)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `holding_id` SET TAGS ('dbx_business_glossary_term' = 'Holding ID (HOLDING_ID)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio ID (PORTFOLIO_ID)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `activity_code` SET TAGS ('dbx_business_glossary_term' = 'Activity Code (ACT_CODE)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `activity_description` SET TAGS ('dbx_business_glossary_term' = 'Activity Description (ACT_DESC)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `alignment_end_date` SET TAGS ('dbx_business_glossary_term' = 'Alignment End Date (ALIGN_END)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `alignment_percentage` SET TAGS ('dbx_business_glossary_term' = 'Alignment Percentage (ALIGN_PCT)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `alignment_start_date` SET TAGS ('dbx_business_glossary_term' = 'Alignment Start Date (ALIGN_START)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `alignment_status` SET TAGS ('dbx_business_glossary_term' = 'Alignment Status (ALIGN_STATUS)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `alignment_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|terminated');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `alignment_type` SET TAGS ('dbx_business_glossary_term' = 'Alignment Type (ALIGN_TYPE)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `alignment_type` SET TAGS ('dbx_value_regex' = 'direct|co-investment|fund');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `audit_trail_flag` SET TAGS ('dbx_business_glossary_term' = 'Audit Trail Flag (AUDIT_FLAG)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `biodiversity_objective` SET TAGS ('dbx_business_glossary_term' = 'Biodiversity Objective (BIODIVERSITY_OBJ)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `carbon_intensity_metric` SET TAGS ('dbx_business_glossary_term' = 'Carbon Intensity Metric (CARB_INT_METRIC)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `carbon_intensity_value` SET TAGS ('dbx_business_glossary_term' = 'Carbon Intensity Value (CARB_INT_VALUE)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `circular_economy_objective` SET TAGS ('dbx_business_glossary_term' = 'Circular Economy Objective (CIRC_ECO_OBJ)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `climate_objective` SET TAGS ('dbx_business_glossary_term' = 'Climate Objective (CLIMATE_OBJ)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status (COMP_STATUS)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|pending');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code (COUNTRY)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp (CREATED)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `data_quality_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Flag (DQ_FLAG)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score (DQ_SCORE)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source (DATA_SRC)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date (EFFECTIVE)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `eligible_capex_pct` SET TAGS ('dbx_business_glossary_term' = 'Eligible Capex % (ELIG_CAPEX_PCT)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `eligible_opex_pct` SET TAGS ('dbx_business_glossary_term' = 'Eligible Opex % (ELIG_OPEX_PCT)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `eligible_revenue_pct` SET TAGS ('dbx_business_glossary_term' = 'Eligible Revenue % (ELIG_REVENUE_PCT)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date (EXPIRY)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `gics_industry_code` SET TAGS ('dbx_business_glossary_term' = 'GICS Industry Code (GICS_INDUSTRY)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `gics_sector_code` SET TAGS ('dbx_business_glossary_term' = 'GICS Sector Code (GICS_SECTOR)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By (MODIFIED_BY)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp (LAST_UPD)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `net_zero_commitment_flag` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Commitment Flag (NET_ZERO_FLAG)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes (NOTES)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `pollution_objective` SET TAGS ('dbx_business_glossary_term' = 'Pollution Objective (POLLUTION_OBJ)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `regulatory_alignment` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Alignment (REG_ALIGN)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `regulatory_alignment` SET TAGS ('dbx_value_regex' = 'EU Taxonomy|SFDR|PRI');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `risk_assessment_flag` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Flag (RISK_FLAG)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `sector_classification` SET TAGS ('dbx_business_glossary_term' = 'Sector Classification (SECTOR_CLASS)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `taxonomy_code` SET TAGS ('dbx_business_glossary_term' = 'Taxonomy Code (TAX_CODE)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `taxonomy_eligibility_reason` SET TAGS ('dbx_business_glossary_term' = 'Taxonomy Eligibility Reason (TAX_ELIG_REASON)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `taxonomy_eligibility_status` SET TAGS ('dbx_business_glossary_term' = 'Taxonomy Eligibility Status (TAX_ELIG_STATUS)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `taxonomy_eligibility_status` SET TAGS ('dbx_value_regex' = 'eligible|not_eligible|partial');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `taxonomy_name` SET TAGS ('dbx_business_glossary_term' = 'Taxonomy Name (TAX_NAME)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `taxonomy_version` SET TAGS ('dbx_business_glossary_term' = 'Taxonomy Version (TAX_VER)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `water_objective` SET TAGS ('dbx_business_glossary_term' = 'Water Objective (WATER_OBJ)');
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By (CREATED_BY)');
