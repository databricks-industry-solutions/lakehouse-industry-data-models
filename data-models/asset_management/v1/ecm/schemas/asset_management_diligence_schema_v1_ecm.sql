-- Schema for Domain: diligence | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:25

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`diligence` COMMENT 'Domain for comprehensive investment due diligence processes including operational due diligence (ODD), financial due diligence (FDD), commercial due diligence (CDD), legal DD, and ESG DD conducted on prospective investments and external fund managers.';
ALTER SCHEMA `asset_management`.`diligence` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `asset_management`.`diligence` SET TAGS ('dbx_domain' = 'diligence');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`diligence`.`dd_engagement` (
    `dd_engagement_id` BIGINT COMMENT 'Unique system-generated identifier for a formal due diligence engagement record. Primary key for the dd_engagement product.',
    `concession_agreement_id` BIGINT COMMENT 'Foreign key linking to infrastructure.concession_agreement. Business justification: Concession agreements are key infrastructure contracts; linking dd_engagement to concession_agreement supports regulatory and financial due diligence on the agreement',
    `dd_employee_id` BIGINT COMMENT 'Internal employee identifier for the primary analyst responsible for coordinating and executing the DD engagement. Sourced from SAP SuccessFactors HR system.',
    `dd_ic_sponsor_employee_id` BIGINT COMMENT 'Internal employee identifier for the senior investment professional sponsoring this DD engagement at the Investment Committee level. Sourced from Diligent/BoardEffect.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the originating deal or pipeline opportunity in the deal origination domain (Dealpath/DealCloud). Links DD engagement to the upstream sourcing record.',
    `employee_id` BIGINT COMMENT 'Internal employee identifier for the primary analyst responsible for coordinating and executing the DD engagement. Sourced from SAP SuccessFactors HR system.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager record in the manager domain when the DD engagement is a manager-level ODD or mandate review. Null for direct investment engagements.',
    `ic_sponsor_employee_id` BIGINT COMMENT 'Internal employee identifier for the senior investment professional sponsoring this DD engagement at the Investment Committee level. Sourced from Diligent/BoardEffect.',
    `infra_fund_commitment_id` BIGINT COMMENT 'Foreign key linking to infrastructure.infra_fund_commitment. Business justification: Due diligence is routinely performed before committing capital to a fund; FK connects engagement to the specific fund commitment for audit and compliance.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager record in the manager domain when the DD engagement is a manager-level ODD or mandate review. Null for direct investment engagements.',
    `manager_mandate_id` BIGINT COMMENT 'Foreign key linking to manager.manager_mandate. Business justification: DD engagements for mandate renewals, amendments, or re-ups must link to the specific mandate under review.',
    `opportunity_id` BIGINT COMMENT 'Reference to the originating deal or pipeline opportunity in the deal origination domain (Dealpath/DealCloud). Links DD engagement to the upstream sourcing record.',
    `prior_engagement_dd_engagement_id` BIGINT COMMENT 'Reference to the previous DD engagement record for the same target entity when this is a repeat or re-underwriting engagement. Enables longitudinal DD history tracking.',
    `project_investment_id` BIGINT COMMENT 'Foreign key linking to infrastructure.project_investment. Business justification: Engagements often target a project investment; FK allows tracking of due diligence outcomes per project and integration with investment decision workflows.',
    `resource_asset_id` BIGINT COMMENT 'Foreign key linking to naturalresource.resource_asset. Business justification: Due diligence engagement is performed on a specific natural resource asset; linking enables traceability of the engagement to the asset.',
    `actual_completion_date` DATE COMMENT 'Actual calendar date on which all DD workstreams were completed and the final DD report was signed off. Null if engagement is still in progress.',
    `asset_class` STRING COMMENT 'Primary asset class of the investment under review. Determines applicable valuation methodology, risk framework, and regulatory reporting requirements for the DD engagement.. Valid values are `Public Equity|Private Equity|Real Estate|Infrastructure|Natural Resources|Credit`',
    `cdd_rating` STRING COMMENT 'Outcome rating for the Commercial Due Diligence workstream evaluating market position, competitive dynamics, revenue quality, and business model sustainability.. Valid values are `Pass|Pass with Concerns|Fail|Not Applicable`',
    `commitment_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the proposed capital commitment amount (e.g., USD, EUR, GBP). Required for FX hedging analysis and treasury planning.. Valid values are `^[A-Z]{3}$`',
    `conditions_precedent` STRING COMMENT 'Narrative description of any conditions precedent or outstanding items that must be resolved before the investment can proceed following IC approval. Tracked post-IC decision.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp recording when the DD engagement record was first created in the data platform. Used for audit trail, data lineage, and SLA compliance tracking.',
    `data_room_location` STRING COMMENT 'URL or system reference to the virtual data room (VDR) where confidential DD documents, financial statements, and legal materials are stored for this engagement.',
    `dd_type` STRING COMMENT 'Classification of the due diligence engagement by discipline: ODD (Operational), FDD (Financial), CDD (Commercial), Legal, ESG, or Combined multi-workstream engagement.. Valid values are `ODD|FDD|CDD|Legal|ESG|Combined`',
    `engagement_name` STRING COMMENT 'Descriptive name for the DD engagement, typically referencing the target entity and DD type (e.g., Acme Infrastructure Fund IV - ODD 2024). Used for display and search.',
    `engagement_priority` STRING COMMENT 'Business priority level assigned to the DD engagement reflecting deal urgency, strategic importance, and resource allocation. Drives analyst bandwidth and timeline management.. Valid values are `High|Medium|Low`',
    `engagement_reference` STRING COMMENT 'Externally-known alphanumeric reference code assigned to the DD engagement at initiation (e.g., DD-2024-00123). Used for cross-system tracking in eFront and Dealpath/DealCloud.. Valid values are `^DD-[0-9]{4}-[0-9]{5}$`',
    `engagement_scope` STRING COMMENT 'Narrative description of the defined scope, boundaries, and objectives of the DD engagement including specific workstreams, geographic coverage, and exclusions agreed at initiation.',
    `engagement_status` STRING COMMENT 'Current lifecycle state of the DD engagement from initiation through IC review to completion or cancellation. Drives workflow routing in eFront and Diligent/BoardEffect.. Valid values are `Initiated|In Progress|Pending IC|Completed|Suspended|Cancelled`',
    `esg_dd_rating` STRING COMMENT 'Outcome rating for the ESG Due Diligence workstream assessing environmental risks, social practices, and governance quality per PRI and TCFD frameworks.. Valid values are `Pass|Pass with Concerns|Fail|Not Applicable`',
    `esg_material_issues` STRING COMMENT 'Description of material ESG issues identified during the ESG DD workstream, including GHG exposure, social risks, and governance deficiencies per TCFD and PRI frameworks.',
    `fdd_rating` STRING COMMENT 'Outcome rating for the Financial Due Diligence workstream covering financial statement analysis, EBITDA quality, cash flow, and capital structure assessment.. Valid values are `Pass|Pass with Concerns|Fail|Not Applicable`',
    `ic_decision` STRING COMMENT 'Formal outcome of the Investment Committee review following DD completion. Drives downstream capital commitment and mandate execution workflows.. Valid values are `Approved|Rejected|Deferred|Approved with Conditions|Withdrawn`',
    `ic_decision_date` DATE COMMENT 'Date on which the Investment Committee rendered its formal decision on the investment opportunity following DD completion. Null if IC review is pending.',
    `ic_submission_date` DATE COMMENT 'Date on which the completed DD package and Investment Memorandum (IM) were formally submitted to the Investment Committee for approval consideration.',
    `im_reference` STRING COMMENT 'Document reference or identifier for the Investment Memorandum (IM) prepared as the primary IC submission document summarizing DD findings and investment recommendation.',
    `initiation_date` DATE COMMENT 'Calendar date on which the formal DD engagement was officially initiated and the DD team was mandated. Represents the principal business event date for the engagement lifecycle.',
    `investment_strategy` STRING COMMENT 'Stated investment strategy of the target entity or fund (e.g., Buyout, Growth Equity, Core Infrastructure, Value-Add Real Estate, Senior Secured Credit). Informs DD checklist selection.',
    `key_risks_summary` STRING COMMENT 'Narrative summary of the most material risks identified across all DD workstreams. Included in the IC submission package and Investment Memorandum for decision-maker review.',
    `kyc_aml_cleared` BOOLEAN COMMENT 'Indicates whether the target entity has passed KYC/AML screening as required by FATF guidelines prior to investment. Mandatory compliance gate for all engagements.',
    `kyc_cleared_date` DATE COMMENT 'Date on which KYC/AML clearance was formally confirmed for the target entity. Required for regulatory audit trail and compliance reporting to FATF.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'System timestamp recording the most recent modification to the DD engagement record. Supports incremental data loading, change detection, and audit trail requirements.',
    `lead_analyst_name` STRING COMMENT 'Full name of the internal lead analyst responsible for the DD engagement. Denormalized for reporting and IC memorandum generation without requiring HR system join.',
    `legal_dd_rating` STRING COMMENT 'Outcome rating for the Legal Due Diligence workstream covering corporate structure, title, regulatory compliance, litigation exposure, and contractual obligations.. Valid values are `Pass|Pass with Concerns|Fail|Not Applicable`',
    `nda_executed` BOOLEAN COMMENT 'Indicates whether a Non-Disclosure Agreement (NDA) has been executed with the target entity prior to commencement of the DD engagement. Required before confidential data sharing.',
    `nda_execution_date` DATE COMMENT 'Date on which the NDA was formally executed between the pension fund and the target entity. Establishes the legal basis for confidential information exchange during DD.',
    `odd_rating` STRING COMMENT 'Outcome rating for the Operational Due Diligence workstream assessing governance, controls, technology, and operational infrastructure of the target entity.. Valid values are `Pass|Pass with Concerns|Fail|Not Applicable`',
    `overall_dd_rating` STRING COMMENT 'Consolidated DD outcome rating summarizing findings across all workstreams. Represents the lead analyst and DD teams aggregate assessment of the target entitys suitability.. Valid values are `Pass|Pass with Concerns|Fail|Inconclusive`',
    `proposed_commitment_amount` DECIMAL(20,2) COMMENT 'Proposed capital commitment or investment amount under consideration, expressed in the base currency. Used for IC sizing approval and portfolio construction impact assessment.',
    `regulatory_flags` STRING COMMENT 'Free-text notation of any regulatory concerns, sanctions screening results, or compliance flags raised during the DD process requiring escalation or legal review.',
    `repeat_engagement` BOOLEAN COMMENT 'Indicates whether this is a repeat or re-underwriting DD engagement on a previously reviewed entity (e.g., re-up fund commitment, periodic ODD refresh on existing manager).',
    `target_completion_date` DATE COMMENT 'Planned date by which all DD workstreams must be completed and findings consolidated for IC submission. Used for project tracking and SLA monitoring.',
    `target_entity_name` STRING COMMENT 'Legal name of the investment target, co-investment vehicle, or external fund manager subject to this DD engagement. Sourced from Dealpath/DealCloud or eFront.',
    `target_entity_type` STRING COMMENT 'Classification of the entity under DD review: Direct Investment, Co-Investment, External Fund Manager, Real Asset, or Credit Issuer. Determines applicable DD checklist and workstream scope.. Valid values are `Direct Investment|Co-Investment|External Fund Manager|Real Asset|Credit Issuer`',
    `target_geography` STRING COMMENT 'Primary geographic focus of the investment or fund under review (e.g., North America, Europe, Global). Drives applicable regulatory and legal DD requirements.',
    `third_party_advisor` STRING COMMENT 'Name of the external advisory firm engaged to support the DD process (e.g., legal counsel, accounting firm, technical advisor, ESG consultant). Multiple advisors noted as comma-separated.',
    `vintage_year` BIGINT COMMENT 'Year in which the fund or investment vehicle was established or first called capital. Critical for private equity performance benchmarking and J-Curve analysis per GIPS standards.',
    CONSTRAINT pk_dd_engagement PRIMARY KEY(`dd_engagement_id`)
) COMMENT 'Master record for a formal due diligence engagement initiated on a prospective investment, co-investment, or external fund manager. Captures the DD type (ODD, FDD, CDD, Legal, ESG, or combined), the target entity under review, engagement status, lead';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`dd_workstream` (
    `dd_workstream_id` BIGINT COMMENT 'Unique surrogate identifier for a distinct functional workstream within a due diligence engagement. Primary key for the dd_workstream entity.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the parent DD engagement to which this workstream belongs. Links the workstream to its overarching diligence process.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity under diligence. Links the workstream to the origination pipeline record in Dealpath/DealCloud.',
    `employee_id` BIGINT COMMENT 'Internal staff member designated as the lead analyst responsible for executing and coordinating this workstream. Links to the HR/workforce record.',
    `lead_analyst_employee_id` BIGINT COMMENT 'Internal staff member designated as the lead analyst responsible for executing and coordinating this workstream. Links to the HR/workforce record.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity under diligence. Links the workstream to the origination pipeline record in Dealpath/DealCloud.',
    `actual_completion_date` DATE COMMENT 'Date on which this workstream was formally signed off as complete. Null if workstream is still in progress. Used for DD cycle time analytics.',
    `actual_start_date` DATE COMMENT 'Date on which work on this DD workstream actually commenced. Compared against planned start date to measure DD process efficiency.',
    `advisor_engagement_ref` STRING COMMENT 'External engagement or mandate reference number assigned by the third-party advisor firm for this workstream. Used for invoice reconciliation and report tracking.',
    `advisor_fee_amount` DECIMAL(18,2) COMMENT 'Total fee amount committed or invoiced to the third-party advisor for this workstream. Denominated in the currency specified by advisor_fee_currency. Tracked for deal cost budgeting.',
    `advisor_fee_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the advisor fee amount (e.g., USD, GBP). Required for multi-currency deal cost consolidation.. Valid values are `^[A-Z]{3}$`',
    `aml_kyc_concern_flag` BOOLEAN COMMENT 'Indicates whether AML or KYC concerns were identified during this workstream. Triggers mandatory escalation to compliance per FATF AML requirements.',
    `asset_class` STRING COMMENT 'Asset class of the investment under diligence. Determines the applicable DD framework, checklist templates, and risk thresholds used in this workstream.. Valid values are `Private Equity|Real Estate|Infrastructure|Natural Resources|Credit|Public Equities`',
    `checklist_completion_pct` DECIMAL(5,2) COMMENT 'Percentage of checklist items within this workstream that have been completed. Provides a granular progress indicator beyond binary status fields.',
    `checklist_template_ref` STRING COMMENT 'Reference code or version identifier of the standardized DD checklist template applied to this workstream. Ensures consistency and regulatory alignment across engagements.',
    `conditions_precedent` STRING COMMENT 'Narrative description of conditions that must be satisfied before investment can proceed, as identified by this workstream. Tracked through to SPA execution.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp at which this DD workstream record was first created in the system. Provides the audit trail creation anchor for data lineage and compliance purposes.',
    `critical_finding_count` BIGINT COMMENT 'Number of findings rated as Critical or deal-breaker severity within this workstream. A non-zero value typically triggers IC escalation or deal suspension.',
    `data_room_access_flag` BOOLEAN COMMENT 'Indicates whether the DD team has been granted access to the virtual data room (VDR) for this workstream. Access is a prerequisite for FDD and Legal DD execution.',
    `data_room_platform` STRING COMMENT 'Name of the virtual data room platform used for document sharing in this workstream (e.g., Intralinks, Datasite, Ansarada). Used for access audit and document provenance.',
    `esg_materiality_flag` BOOLEAN COMMENT 'Indicates whether ESG factors identified in this workstream are material to the investment decision. Triggers mandatory ESG DD escalation per PRI and TCFD commitments.',
    `esg_risk_rating` STRING COMMENT 'ESG-specific risk rating assigned within this workstream. Populated for ESG DD workstreams and used as an input to MSCI ESG scoring and portfolio-level ESG reporting.. Valid values are `Low|Medium|High|Critical`',
    `finding_count` BIGINT COMMENT 'Total number of findings identified within this workstream. Provides a quantitative measure of diligence depth and issue density for IC reporting.',
    `ic_approval_required_flag` BOOLEAN COMMENT 'Indicates whether the findings of this workstream must be formally presented to and approved by the Investment Committee before the deal can proceed.',
    `ic_submission_deadline` DATE COMMENT 'Hard deadline by which this workstream findings must be incorporated into the Investment Memorandum (IM) for IC review and approval.',
    `investment_type` STRING COMMENT 'Nature of the investment structure under diligence: Direct, Co-Investment, Fund Subscription, Secondary market transaction, or Separately Managed Account (SMA).. Valid values are `Direct|Co-Investment|Fund Subscription|Secondary|SMA`',
    `key_findings_summary` STRING COMMENT 'Executive summary of the principal findings from this workstream. Incorporated into the Investment Memorandum (IM) for IC review. Confidential deal-sensitive content.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this DD workstream record. Used for change tracking, data freshness monitoring, and incremental ETL processing.',
    `nda_executed_flag` BOOLEAN COMMENT 'Indicates whether a Non-Disclosure Agreement (NDA) has been executed with the target entity prior to commencement of this workstream. Required before accessing confidential data room.',
    `open_finding_count` BIGINT COMMENT 'Number of findings that remain unresolved or unmitigated at the time of reporting. Tracks outstanding diligence items blocking workstream sign-off.',
    `overall_risk_rating` STRING COMMENT 'Aggregate risk rating assigned to this workstream based on findings. Informs IC decision-making and determines whether deal-breaker conditions exist.. Valid values are `Low|Medium|High|Critical`',
    `planned_completion_date` DATE COMMENT 'Target date by which this workstream must be completed to meet the IC submission deadline. Drives escalation and resource allocation decisions.',
    `planned_start_date` DATE COMMENT 'Scheduled date on which work on this DD workstream is planned to commence. Used for resource planning and IC timeline management.',
    `priority_level` STRING COMMENT 'Business priority assigned to this workstream relative to other concurrent workstreams in the engagement. Drives resource allocation and escalation sequencing.. Valid values are `Critical|High|Medium|Low`',
    `recommendation` STRING COMMENT 'Formal recommendation from the workstream lead submitted to the IC. Drives the overall deal disposition decision. Confidential pre-IC deliberation content.. Valid values are `Proceed|Proceed with Conditions|Further Investigation Required|Do Not Proceed`',
    `regulatory_concern_flag` BOOLEAN COMMENT 'Indicates whether this workstream has identified a regulatory, compliance, or legal concern requiring escalation to the Chief Compliance Officer or Legal counsel.',
    `report_issued_date` DATE COMMENT 'Date on which the final or most recent version of the DD report for this workstream was formally issued to the investment team and IC.',
    `report_version` STRING COMMENT 'Version identifier of the most recent DD report produced for this workstream (e.g., v1.0, v2.3). Tracks report iteration history for IC audit trail.. Valid values are `^v[0-9]+.[0-9]+$`',
    `scope_description` STRING COMMENT 'Narrative description of the specific scope, objectives, and boundaries of this workstream. Documents what is in and out of scope for IC transparency.',
    `sign_off_timestamp` TIMESTAMP COMMENT 'Timestamp at which the workstream owner formally signed off on the completeness and accuracy of this workstream. Constitutes the official DD completion event for audit purposes.',
    `target_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the target entitys primary jurisdiction. Used for geopolitical risk assessment, sanctions screening, and regulatory compliance.. Valid values are `^[A-Z]{3}$`',
    `target_entity_lei` STRING COMMENT '20-character ISO 17442 Legal Entity Identifier (LEI) of the target entity. Used for regulatory reporting, counterparty identification, and KYC/AML verification.. Valid values are `^[A-Z0-9]{20}$`',
    `target_entity_name` STRING COMMENT 'Legal name of the company, fund, or asset being evaluated in this workstream. Confidential pre-announcement deal information. May differ from deal code name.',
    `third_party_advisor` STRING COMMENT 'Name of the external advisory firm engaged to support this workstream (e.g., Big 4 accounting firm for FDD, law firm for Legal DD, ESG consultant for ESG DD).',
    `vintage_year` BIGINT COMMENT 'Year in which the fund or investment commitment is expected to be made. Relevant for private equity and fund subscription workstreams for J-Curve and performance benchmarking.',
    `workstream_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this workstream within the DD engagement. Used for cross-system referencing in eFront and Dealpath.. Valid values are `^DD-WS-[A-Z0-9]{4,20}$`',
    `workstream_name` STRING COMMENT 'Human-readable descriptive name for the workstream (e.g., Financial Due Diligence — Project Maple). Used in IC memoranda and reporting dashboards.',
    `workstream_owner` STRING COMMENT 'Name or title of the senior investment professional accountable for the quality and completeness of this workstream. Typically a Managing Director or VP.',
    `workstream_status` STRING COMMENT 'Current lifecycle state of the workstream. Drives IC governance reporting and tracks progress toward DD completion sign-off.. Valid values are `Not Started|In Progress|Under Review|Completed|On Hold|Cancelled`',
    `workstream_type` STRING COMMENT 'Functional category of the workstream: Operational DD (ODD), Financial DD (FDD), Commercial DD (CDD), Legal DD, ESG DD, or Tax DD. Determines the checklist and risk framework applied.. Valid values are `ODD|FDD|CDD|Legal DD|ESG DD|Tax DD`',
    CONSTRAINT pk_dd_workstream PRIMARY KEY(`dd_workstream_id`)
) COMMENT 'Represents a distinct functional workstream within a DD engagement — Operational DD (ODD), Financial DD (FDD), Commercial DD (CDD), Legal DD, ESG DD, or Tax DD.';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`dd_checklist` (
    `dd_checklist_id` BIGINT COMMENT 'Unique surrogate identifier for a DD checklist record within the diligence domain. Primary key for the dd_checklist product.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the parent DD engagement to which this checklist belongs. Links the checklist to a specific deal, fund manager, or asset under review.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity in the deal pipeline for which this checklist is being executed. Links to Dealpath/DealCloud origination records.',
    `employee_id` BIGINT COMMENT 'Reference to the internal analyst or associate responsible for leading the completion of this checklist workstream.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager or GP being evaluated, when this checklist is used for manager-level ODD or mandate due diligence.',
    `lead_analyst_employee_id` BIGINT COMMENT 'Reference to the internal analyst or associate responsible for leading the completion of this checklist workstream.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager or GP being evaluated, when this checklist is used for manager-level ODD or mandate due diligence.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity in the deal pipeline for which this checklist is being executed. Links to Dealpath/DealCloud origination records.',
    `parent_template_dd_checklist_id` BIGINT COMMENT 'Reference to the standard master template from which this checklist was derived or customized. Enables lineage tracking between standard and customized checklists.',
    `actual_completion_date` DATE COMMENT 'Date on which this checklist was fully completed and signed off by the workstream lead. Null if not yet completed.',
    `advisor_engagement_ref` STRING COMMENT 'External engagement or contract reference number for the third-party advisor assigned to this DD workstream. Confidential business reference.',
    `approved_by` STRING COMMENT 'Name or identifier of the investment officer or DD lead who approved the completed checklist for IC submission.',
    `approved_date` DATE COMMENT 'Date on which the completed checklist was reviewed and approved by the DD lead or investment officer, confirming readiness for IC submission.',
    `asset_class` STRING COMMENT 'Asset class to which this checklist applies. Determines the scope and relevance of checklist items. [ENUM-REF-CANDIDATE: Private Equity|Real Estate|Infrastructure|Natural Resources|Credit|Public Equities|External Fund Manager — promote to reference. Valid values are `Private Equity|Real Estate|Infrastructure|Natural Resources|Credit|Public Equities`',
    `assigned_date` DATE COMMENT 'Date on which this checklist was formally assigned to the DD team or workstream lead for the current engagement.',
    `checklist_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this checklist template instance, used for cross-system referencing in eFront and Dealpath/DealCloud.. Valid values are `^DDC-[A-Z]{2,10}-[0-9]{4,8}$`',
    `checklist_name` STRING COMMENT 'Human-readable name of the checklist template, e.g., Infrastructure ODD Checklist v3 or Private Equity FDD Standard Checklist.',
    `checklist_status` STRING COMMENT 'Current lifecycle status of the checklist template. Draft=in preparation, Active=approved for use, Deprecated=superseded by newer version, Archived=retired, Under Review=pending approval.. Valid values are `Draft|Active|Deprecated|Archived|Under Review`',
    `checklist_version` STRING COMMENT 'Version identifier of the checklist template (e.g., 1.0, 2.3), enabling tracking of template evolution and ensuring the correct version is applied to each engagement.. Valid values are `^[0-9]+.[0-9]+(.[0-9]+)?$`',
    `completed_item_count` BIGINT COMMENT 'Number of checklist items that have been marked as completed within this checklist instance. Enables real-time progress monitoring by the DD team.',
    `completion_status` STRING COMMENT 'Operational completion status of this checklist instance within its assigned engagement. Tracks progress from initiation through completion or waiver.. Valid values are `Not Started|In Progress|Completed|Waived|On Hold`',
    `conditions_precedent` STRING COMMENT 'Description of any conditions precedent or outstanding requirements that must be satisfied before this checklist can be marked complete and IC approval granted.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this checklist record was first created in the system. Audit trail field for data governance and lineage tracking.',
    `critical_item_count` BIGINT COMMENT 'Number of checklist items flagged as critical or mandatory. Critical items must be resolved before IC approval can be granted.',
    `data_room_access` BOOLEAN COMMENT 'Indicates whether the DD team has been granted access to the virtual data room (VDR) for this engagement, enabling document review and checklist completion.',
    `data_room_url` STRING COMMENT 'URL or access link to the virtual data room associated with this DD engagement. Confidential and restricted to authorized DD team members.',
    `esg_scope_included` BOOLEAN COMMENT 'Indicates whether ESG due diligence items are included within this checklist. Mandatory for all new investments per PRI and TCFD commitments.',
    `geography` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the primary jurisdiction where the target entity or asset is domiciled. Drives regulatory and legal DD scope.. Valid values are `^[A-Z]{3}$`',
    `ic_submission_required` BOOLEAN COMMENT 'Indicates whether completion of this checklist is a prerequisite for Investment Committee (IC) submission. Enforces governance gate controls.',
    `investment_strategy` STRING COMMENT 'Investment strategy or sub-strategy of the target (e.g., Buyout, Growth Equity, Core Infrastructure, Value-Add Real Estate, Direct Lending). Scopes the DD focus areas.',
    `is_customized` BOOLEAN COMMENT 'Indicates whether this checklist has been customized from the standard template for a specific engagement. Customized checklists require additional approval before use.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether this checklist is mandatory for the associated asset class and workstream type. Mandatory checklists must be fully completed prior to IC submission.',
    `key_findings_summary` STRING COMMENT 'Narrative summary of key findings, red flags, or notable observations identified during completion of this checklist workstream. Confidential investment analysis.',
    `kyc_aml_scope_included` BOOLEAN COMMENT 'Indicates whether KYC/AML screening items are included in this checklist. Required for all new counterparties per FATF AML guidelines.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this checklist record. Used for change tracking, audit trails, and incremental data pipeline processing.',
    `nda_in_place` BOOLEAN COMMENT 'Indicates whether a signed NDA is in place with the target entity prior to commencement of this DD workstream. Required before accessing confidential materials.',
    `outstanding_item_count` BIGINT COMMENT 'Number of checklist items that remain open or unresolved. Derived operationally from total minus completed, but stored for reporting and IC governance dashboards.',
    `overall_dd_recommendation` STRING COMMENT 'Workstream-level recommendation arising from this checklist. Aggregated with other workstream recommendations to form the overall DD conclusion for IC.. Valid values are `Proceed|Proceed with Conditions|Further Review|Do Not Proceed`',
    `regulatory_flags` STRING COMMENT 'Free-text or structured notation of applicable regulatory considerations flagged during this DD workstream (e.g., CFIUS review, FIRB approval notification required).',
    `risk_rating` STRING COMMENT 'Overall risk rating assigned to this checklist based on findings to date. Informs IC decision-making and post-investment monitoring intensity.. Valid values are `Low|Medium|High|Critical`',
    `source_system_ref` STRING COMMENT 'Native identifier of this checklist record in the originating source system (e.g., eFront checklist ID or Dealpath checklist GUID) for reconciliation purposes.',
    `target_completion_date` DATE COMMENT 'Target date by which this checklist must be completed to meet the deal timeline and IC submission schedule.',
    `target_entity_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier (LEI) of the target entity under due diligence. Used for regulatory reporting and counterparty identification per EMIR and MiFID II.. Valid values are `^[A-Z0-9]{18}[0-9]{2}$`',
    `target_entity_name` STRING COMMENT 'Legal name of the target company, fund, asset, or manager being evaluated under this checklist. Confidential pre-announcement deal information.',
    `third_party_advisor` STRING COMMENT 'Name of the external advisor or consulting firm engaged to assist with this DD workstream (e.g., legal counsel, accounting firm, technical consultant).',
    `total_item_count` BIGINT COMMENT 'Total number of checklist items defined within this checklist template version. Used for progress tracking and completion percentage calculations.',
    `vintage_year` BIGINT COMMENT 'Year of the funds first capital commitment or the deals origination year. Used for benchmarking and cohort analysis in private markets DD.',
    `workstream_type` STRING COMMENT 'Type of DD workstream this checklist supports. ODD=Operational, FDD=Financial, CDD=Commercial, Legal DD=Legal, ESG DD=Environmental/Social/Governance, Tax DD=Tax.. Valid values are `ODD|FDD|CDD|Legal DD|ESG DD|Tax DD`',
    CONSTRAINT pk_dd_checklist PRIMARY KEY(`dd_checklist_id`)
) COMMENT 'Standardized or customized DD checklist template assigned to a workstream within a DD engagement. Captures the checklist version, applicable asset class (private equity, real estate, infrastructure, credit, etc.), workstream type, total item count';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`dd_checklist_item` (
    `dd_checklist_item_id` BIGINT COMMENT 'Unique surrogate identifier for an individual due diligence checklist line item. Primary key for the dd_checklist_item product.',
    `dd_checklist_id` BIGINT COMMENT 'Reference to the parent DD checklist that this line item belongs to. Links the item to its governing checklist template or engagement.',
    `dd_employee_id` BIGINT COMMENT 'Reference to the internal analyst or investment professional responsible for completing or reviewing this checklist item.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity under diligence. Links the checklist item to the originating deal in the pipeline.',
    `employee_id` BIGINT COMMENT 'Reference to the internal analyst or investment professional responsible for completing or reviewing this checklist item.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager being evaluated, if this checklist item relates to an Operational Due Diligence (ODD) or manager selection engagement.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager being evaluated, if this checklist item relates to an Operational Due Diligence (ODD) or manager selection engagement.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity under diligence. Links the checklist item to the originating deal in the pipeline.',
    `reviewer_employee_id` BIGINT COMMENT 'Reference to the senior analyst, portfolio manager, or compliance officer who reviewed and approved the response to this checklist item.',
    `reviewer_id` BIGINT COMMENT 'Reference to the senior analyst, portfolio manager, or compliance officer who reviewed and approved the response to this checklist item.',
    `advisor_report_reference` STRING COMMENT 'Reference number or document identifier for the third-party advisor report that addresses this checklist item. Links to the document management system.',
    `asset_class` STRING COMMENT 'Asset class context for this checklist item. Determines which DD template and regulatory framework applies. [ENUM-REF-CANDIDATE: promote to reference product if values expand]',
    `dd_checklist_item_category` STRING COMMENT 'Business category grouping for this item within its DD type (e.g., Governance, Financial Statements, ESG Policy, AML/KYC, Valuation, Fund Terms, Cybersecurity). Enables thematic reporting.',
    `completed_date` DATE COMMENT 'Date on which this checklist item was marked as satisfactory or closed by the assigned analyst or reviewer. Supports DD completion tracking.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this checklist item record was first created in the system. Supports audit trail and DD engagement timeline reconstruction.',
    `data_room_reference` STRING COMMENT 'Reference path or identifier for the supporting document in the virtual data room (VDR) that satisfies this checklist item.',
    `dd_type` STRING COMMENT 'Classification of the diligence workstream this item belongs to: Financial DD (FDD), Operational DD (ODD), Commercial DD (CDD), Legal, ESG, Tax, or Technical. [ENUM-REF-CANDIDATE: FDD|ODD|CDD|Legal|ESG|Tax|Technical — promote to reference product]',
    `due_date` DATE COMMENT 'Target date by which this checklist item must be completed or a response received. Used for DD timeline management and escalation triggers.',
    `effront_item_code` STRING COMMENT 'Native identifier for this checklist item in the eFront Private Markets platform. Enables reconciliation and bi-directional synchronization with the system of record.',
    `escalation_date` DATE COMMENT 'Date on which this item was escalated due to non-response, unsatisfactory response, or identified risk. Triggers senior review workflow.',
    `escalation_reason` STRING COMMENT 'Narrative explanation for why this item was escalated, including the nature of the concern (e.g., missing document, adverse finding, counterparty non-response).',
    `esg_dimension` STRING COMMENT 'ESG pillar this item relates to, if applicable. Enables ESG-specific DD tracking aligned with PRI, TCFD, and SFDR reporting obligations.. Valid values are `environmental|social|governance|not_applicable`',
    `extended_due_date` DATE COMMENT 'Revised due date following a formal extension approval. Captures timeline changes for audit trail and DD project management reporting.',
    `finding_summary` STRING COMMENT 'Concise analyst summary of the key finding or observation for this checklist item. Included in the DD report and Investment Memorandum (IM) submitted to the IC.',
    `guidance_notes` STRING COMMENT 'Internal guidance text for the assigned analyst explaining the intent of the question, acceptable evidence, and evaluation criteria. Not shared with the counterparty.',
    `is_ic_blocking` BOOLEAN COMMENT 'Indicates whether an unresolved or escalated status on this item will block submission to the Investment Committee (IC). Supports IC governance gate controls.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether this checklist item is mandatory for DD completion. Mandatory items must reach satisfactory status before the investment can proceed to IC approval.',
    `is_recurring` BOOLEAN COMMENT 'Indicates whether this checklist item recurs on a periodic basis (e.g., annual re-diligence of an external manager), as opposed to a one-time deal DD item.',
    `item_reference_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this checklist item within the DD engagement (e.g., DD-FDD-00042). Used in advisor reports and IC submissions.. Valid values are `^DD-[A-Z]{2,6}-[0-9]{4,8}$`',
    `item_sequence` BIGINT COMMENT 'Ordinal position of this checklist item within its parent checklist section, used to maintain structured ordering for IC presentation and reporting.',
    `item_status` STRING COMMENT 'Current workflow status of the checklist item. [ENUM-REF-CANDIDATE: open|in_progress|received|satisfactory|escalated|waived|closed — promote to reference product]',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this checklist item record. Used for change tracking, data lineage, and incremental ETL processing.',
    `priority` STRING COMMENT 'Business priority assigned to this checklist item, indicating urgency and materiality to the investment decision. Critical items may block IC approval.. Valid values are `critical|high|medium|low`',
    `question_text` STRING COMMENT 'Full text of the diligence question, information request, or verification task as presented to the counterparty or assigned analyst. Core content of the checklist item.',
    `recurrence_frequency` STRING COMMENT 'Frequency at which this recurring checklist item must be re-executed. Applicable only when is_recurring is true. Drives automated scheduling in eFront.. Valid values are `annual|semi_annual|quarterly|monthly|ad_hoc`',
    `regulatory_reference` STRING COMMENT 'Applicable regulatory requirement, standard, or governing body that mandates or informs this checklist item (e.g., model risk management guidance, FATF AML, MiFID II, SFDR Article 8).',
    `remediation_notes` STRING COMMENT 'Description of the required remediation action, condition precedent, or post-close monitoring obligation associated with this checklist item finding.',
    `remediation_required` BOOLEAN COMMENT 'Indicates whether a remediation action or condition precedent is required to address the finding before or after investment close.',
    `response_received_date` DATE COMMENT 'Date on which a response or supporting document was received from the counterparty or data room for this checklist item.',
    `response_text` STRING COMMENT 'Free-text or structured response provided by the counterparty or analyst for this checklist item. Captured when response_type is text or yes_no.',
    `response_type` STRING COMMENT 'Format of the expected response for this item: document upload, free text, numeric value, date, yes/no confirmation, or multi-select. Drives UI rendering in eFront.. Valid values are `document|text|numeric|date|yes_no|multi_select`',
    `reviewed_date` DATE COMMENT 'Date on which the reviewer assessed and approved or rejected the response for this checklist item. Supports DD quality control audit trail.',
    `risk_rating` STRING COMMENT 'Risk rating assigned to this checklist item based on the analysts assessment of the finding. Aggregated to produce overall DD risk profile for IC submission.. Valid values are `high|medium|low|not_applicable`',
    `source_template_code` STRING COMMENT 'Code identifying the standardized DD checklist template from which this item was instantiated (e.g., PE-FDD-V3, INFRA-ODD-V2). Enables template version tracking.',
    `sub_category` STRING COMMENT 'Granular sub-grouping within the category (e.g., under Governance: Board Composition, Conflict of Interest Policy). Supports drill-down analytics and structured IC reporting.',
    `template_version` STRING COMMENT 'Version of the DD checklist template from which this item was derived. Supports methodology governance and year-over-year comparability of DD quality.. Valid values are `^v[0-9]+.[0-9]+$`',
    `third_party_advisor` STRING COMMENT 'Name of the external advisor (legal counsel, accounting firm, technical consultant) engaged to address or validate this checklist item.',
    `waiver_approved` BOOLEAN COMMENT 'Indicates whether a formal waiver has been approved for this checklist item, allowing the DD process to proceed despite an incomplete or unsatisfactory response.',
    `waiver_approved_by` STRING COMMENT 'Name or identifier of the senior officer or committee that approved the waiver for this checklist item. Supports governance accountability.',
    `waiver_rationale` STRING COMMENT 'Documented business justification for approving a waiver on this checklist item. Required for audit trail and regulatory compliance purposes.',
    CONSTRAINT pk_dd_checklist_item PRIMARY KEY(`dd_checklist_item_id`)
) COMMENT 'Individual line-item within a DD checklist representing a specific information request, verification task, or diligence question. Tracks item category, question text, response status (open, received, satisfactory, escalated), assigned analyst, due date';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`dd_finding` (
    `dd_finding_id` BIGINT COMMENT 'Unique surrogate identifier for a formal due diligence finding record within the diligence domain.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the parent DD engagement or workstream under which this finding was raised. Links to the overarching DD process record.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the investment deal or pipeline opportunity that this DD finding is associated with, sourced from the deal origination system.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager or General Partner (GP) being assessed, applicable when DD is conducted on a manager mandate rather than a direct deal.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager or General Partner (GP) being assessed, applicable when DD is conducted on a manager mandate rather than a direct deal.',
    `opportunity_id` BIGINT COMMENT 'Reference to the investment deal or pipeline opportunity that this DD finding is associated with, sourced from the deal origination system.',
    `resource_asset_id` BIGINT COMMENT 'Foreign key linking to naturalresource.resource_asset. Business justification: Findings are about the asset; linking directly to the asset supports reporting and audit trails.',
    `rule_id` BIGINT COMMENT 'Foreign key linking to compliance.rule. Business justification: DD findings identifying regulatory concerns must link to specific compliance rules for IC reporting and remediation tracking.',
    `advisor_report_reference` STRING COMMENT 'Document reference or identifier for the third-party advisor report in which this finding was originally documented, enabling traceability to source evidence.',
    `asset_class` STRING COMMENT 'Asset class of the investment under diligence to which this finding applies, enabling cross-asset-class DD analytics and benchmarking.. Valid values are `private_equity|real_estate|infrastructure|natural_resources|credit|public_equities`',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp recording when this DD finding record was first created in the data platform, used for audit trail and data lineage purposes.',
    `deal_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the deal in which this finding arises, used to denominate price adjustment and indemnity amounts.. Valid values are `^[A-Z]{3}$`',
    `deal_impact_type` STRING COMMENT 'Classification of how this finding impacts the deal structure: deal-breaker, price adjustment, condition precedent in SPA, warranty/indemnity clause, or ongoing monitoring.. Valid values are `deal_breaker|price_adjustment|condition_precedent|warranty|indemnity|monitoring`',
    `esg_sub_theme` STRING COMMENT 'Granular ESG sub-category for the finding (e.g., GHG emissions, water usage, labour practices, board independence, anti-corruption). Applicable when esg_theme is set.',
    `esg_theme` STRING COMMENT 'ESG pillar classification for findings raised within the ESG DD workstream: environmental, social, governance, or none for non-ESG findings.. Valid values are `environmental|social|governance|none`',
    `finding_category` STRING COMMENT 'Granular business category of the finding within its workstream (e.g., revenue recognition, AML controls, governance structure, GHG emissions). [ENUM-REF-CANDIDATE: promote to reference product]',
    `finding_description` STRING COMMENT 'Detailed narrative description of the finding, including the specific issue observed, context, and relevant facts gathered during the DD workstream.',
    `finding_reference` STRING COMMENT 'Externally-visible alphanumeric reference code uniquely identifying this finding across DD workstreams and investment committee (IC) documentation.. Valid values are `^DD-FND-[0-9]{4}-[0-9]{6}$`',
    `finding_status` STRING COMMENT 'Current lifecycle status of the finding from identification through resolution: open, under review, remediated, accepted (risk accepted), escalated to IC, or closed.. Valid values are `open|under_review|remediated|accepted|escalated|closed`',
    `finding_title` STRING COMMENT 'Concise human-readable title summarizing the nature of the finding, used in IC memos, investment memoranda (IM), and DD summary reports.',
    `follow_up_due_date` DATE COMMENT 'Target date by which the follow-up information or clarification for this finding must be received, applicable when follow_up_required is true.',
    `follow_up_required` BOOLEAN COMMENT 'Indicates whether this finding requires a follow-up action or additional information request from the target company, GP, or third-party advisor.',
    `geography` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the primary jurisdiction of the investment or fund manager under diligence, used for geographic risk analysis.. Valid values are `^[A-Z]{3}$`',
    `ic_disposition` STRING COMMENT 'Investment Committee (IC) decision on how to handle this finding: proceed, proceed with conditions, escalate for further review, reject the deal, or defer decision.. Valid values are `proceed|proceed_with_conditions|escalate|reject|defer`',
    `identified_by` STRING COMMENT 'Name or employee identifier of the internal analyst or team member who formally identified and raised this DD finding during the diligence process.',
    `identified_date` DATE COMMENT 'Calendar date on which the DD finding was formally identified and documented by the diligence team during the due diligence process.',
    `impact_confidence_level` STRING COMMENT 'Analyst confidence level in the estimated financial impact amount: high (well-supported), medium (estimated), low (speculative), or unquantifiable.. Valid values are `high|medium|low|unquantifiable`',
    `impact_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the potential financial impact amount (e.g., USD, GBP, EUR).. Valid values are `^[A-Z]{3}$`',
    `indemnity_amount` DECIMAL(20,4) COMMENT 'Monetary value of any indemnity or escrow arrangement negotiated with the vendor as a result of this finding, expressed in the deal currency.',
    `investment_stage` STRING COMMENT 'Stage of the investment lifecycle at which this finding was identified: screening, initial DD, full DD, final DD, post-IC approval, or post-acquisition monitoring.. Valid values are `screening|initial_dd|full_dd|final_dd|post_ic|post_acquisition`',
    `is_deal_condition` BOOLEAN COMMENT 'Indicates whether this finding has been elevated to a formal condition precedent in the Share Purchase Agreement (SPA) or Limited Partnership Agreement (LPA).',
    `is_ic_reportable` BOOLEAN COMMENT 'Indicates whether this finding must be formally reported to the Investment Committee (IC) as part of the IC submission package and investment memorandum (IM).',
    `likelihood_rating` STRING COMMENT 'Analyst assessment of the probability that the risk identified in this finding will materialize, used in conjunction with severity to derive the composite risk rating.. Valid values are `high|medium|low`',
    `potential_financial_impact_amount` DECIMAL(20,4) COMMENT 'Estimated monetary value of the potential financial impact of this finding on the investment, expressed in the base currency. Used in IC risk quantification.',
    `price_adjustment_amount` DECIMAL(20,4) COMMENT 'Monetary value of any purchase price adjustment negotiated as a result of this finding, expressed in the deal currency. Relevant for FDD and legal DD findings.',
    `recommendation` STRING COMMENT 'Formal recommendation from the DD team on how to address the finding, including suggested remediation actions, deal structuring adjustments, or risk mitigants.',
    `regulatory_breach_flag` BOOLEAN COMMENT 'Indicates whether this finding involves a potential or confirmed breach of applicable regulatory requirements (e.g., AML, KYC, EMIR, MiFID II guidelines).',
    `regulatory_reference` STRING COMMENT 'Specific regulation, guideline, or standard that is implicated by this finding (e.g., underwriting practices guidance, FATF Recommendation 10, SFDR Article 8).',
    `remediation_completed_date` DATE COMMENT 'Actual date on which the remediation action for this finding was completed and verified by the DD team or post-acquisition monitoring team.',
    `remediation_due_date` DATE COMMENT 'Target date by which the remediation action for this finding must be completed, as agreed between the DD team and the responsible party.',
    `remediation_notes` STRING COMMENT 'Free-text notes documenting the remediation steps taken, evidence reviewed, and outcome of the remediation process for this finding.',
    `remediation_owner` STRING COMMENT 'Name or identifier of the individual or team responsible for driving remediation of this finding, either internally or at the target company / GP.',
    `reviewed_by` STRING COMMENT 'Name or identifier of the senior analyst, portfolio manager, or DD lead who reviewed and validated this finding prior to IC submission.',
    `risk_rating` STRING COMMENT 'Composite risk rating assigned to this finding reflecting both likelihood and potential impact on the investment, used in portfolio risk aggregation and VaR analysis.. Valid values are `high|medium|low`',
    `root_cause` STRING COMMENT 'Analyst-documented root cause analysis explaining the underlying reason or systemic driver behind the identified finding.',
    `severity_rating` STRING COMMENT 'Standardized severity classification of the finding: critical (deal-breaker risk), major (significant issue requiring remediation), minor (manageable issue), or informational (noted for monitoring).. Valid values are `critical|major|minor|informational`',
    `source_system_finding_code` STRING COMMENT 'Native identifier of this finding in the originating operational system (e.g., eFront finding ID, Dealpath issue ID), enabling bi-directional traceability.',
    `third_party_advisor` STRING COMMENT 'Name of the external advisor (legal counsel, accounting firm, technical consultant, ESG specialist) who identified or validated this finding.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp recording the most recent modification to this DD finding record, supporting audit trail and change tracking requirements.',
    `vintage_year` BIGINT COMMENT 'Year in which the fund or investment commitment was made, used to contextualize DD findings within the fund vintage for benchmarking and J-curve analysis.',
    `workstream_type` STRING COMMENT 'Classifies the DD workstream that identified this finding: Financial DD (FDD), Operational DD (ODD), Legal DD, Commercial DD (CDD), or ESG DD.. Valid values are `financial|operational|legal|commercial|esg`',
    CONSTRAINT pk_dd_finding PRIMARY KEY(`dd_finding_id`)
) COMMENT 'Formal finding or issue identified during any DD workstream. Captures finding type (financial, operational, legal, ESG, commercial), severity rating (critical, major, minor, informational), description, root cause, potential financial impact, recommended';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`dd_risk_assessment` (
    `dd_risk_assessment_id` BIGINT COMMENT 'Unique surrogate identifier for the consolidated risk assessment record produced at the conclusion of a due diligence engagement or workstream. Entity role: TRANSACTION_HEADER.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the parent DD engagement or workstream that produced this risk assessment, linking to the overarching diligence project record in eFront or DealCloud.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the investment deal or opportunity in the deal origination pipeline for which this risk assessment was conducted.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: DD risk assessments stress-test findings against macroeconomic scenarios (base/adverse/severe).',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager or GP subject to this risk assessment, applicable when the DD is conducted on a manager mandate rather than a direct investment.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager or GP subject to this risk assessment, applicable when the DD is conducted on a manager mandate rather than a direct investment.',
    `opportunity_id` BIGINT COMMENT 'Reference to the investment deal or opportunity in the deal origination pipeline for which this risk assessment was conducted.',
    `prior_assessment_dd_risk_assessment_id` BIGINT COMMENT 'Reference to the previous version of this risk assessment, enabling version chain navigation for audit, re-underwriting, and IC re-submission scenarios.',
    `stress_scenario_id` BIGINT COMMENT 'Foreign key linking to risk.stress_scenario. Business justification: DD risk assessments evaluate target entity resilience under stress conditions. Pension funds stress-test acquisition targets against macro scenarios (recession, inflation) to validate',
    `advisor_report_reference` STRING COMMENT 'Document reference or identifier for the third-party advisors formal DD report, used to link to the document management system for retrieval and audit.',
    `assessment_date` DATE COMMENT 'The principal business event date on which the consolidated risk assessment was formally produced and signed off by the lead DD analyst or team.',
    `assessment_reference` STRING COMMENT 'Externally-known alphanumeric reference code assigned to this risk assessment, used for cross-referencing with eFront, DealCloud, and IC governance documentation.. Valid values are `^DD-RA-[0-9]{4}-[0-9]{6}$`',
    `assessment_status` STRING COMMENT 'Current workflow state of the risk assessment record, tracking progression from initial drafting through IC approval or withdrawal.. Valid values are `draft|in_progress|under_review|completed|approved|withdrawn`',
    `assessment_version` BIGINT COMMENT 'Version number of this risk assessment record, incremented when material updates are made post-initial completion, supporting audit trail and IC re-submission tracking.',
    `asset_class` STRING COMMENT 'Asset class of the investment subject to this risk assessment, used for portfolio construction analytics and SAA/TAA reporting. [ENUM-REF-CANDIDATE: public_equity|private_equity|real_estate|infrastructure|natural_resources|credit — promote to reference. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `commitment_amount` DECIMAL(20,2) COMMENT 'Proposed capital commitment amount in base currency being evaluated as part of this DD risk assessment, used for portfolio sizing and capital call planning.',
    `commitment_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the proposed capital commitment amount, used for FX hedging analysis and treasury planning.. Valid values are `^[A-Z]{3}$`',
    `conditions_precedent` STRING COMMENT 'Narrative description of conditions that must be satisfied prior to capital commitment, as stipulated by the IC when approving with conditions.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk assessment record was first captured in the system, used for audit trail and data lineage purposes.',
    `dd_type` STRING COMMENT 'Classification of the DD workstream that produced this assessment: Operational DD (ODD), Financial DD (FDD), Commercial DD (CDD), Legal DD, ESG DD, or Integrated (full-scope).. Valid values are `ODD|FDD|CDD|legal|ESG|integrated`',
    `esg_risk_rating` STRING COMMENT 'Categorical ESG risk rating summarizing climate transition risk, social impact, governance quality, and alignment with the funds responsible investment policy.. Valid values are `low|medium_low|medium|medium_high|high`',
    `esg_risk_score` DECIMAL(5,2) COMMENT 'Quantitative ESG risk score derived from MSCI ESG ratings, TCFD alignment assessment, GHG emissions data, and PRI responsible investment criteria.',
    `financial_risk_rating` STRING COMMENT 'Categorical risk rating for the financial dimension of the DD assessment, summarizing findings on earnings quality, balance sheet strength, and valuation risk.. Valid values are `low|medium_low|medium|medium_high|high`',
    `financial_risk_score` DECIMAL(5,2) COMMENT 'Quantitative risk score for the financial risk dimension, assessing quality of earnings, leverage, liquidity, EBITDA sustainability, and DCF/WACC sensitivity.',
    `ic_decision` STRING COMMENT 'Formal decision rendered by the Investment Committee (IC) following review of the risk assessment and DD findings.. Valid values are `approved|approved_with_conditions|deferred|rejected`',
    `ic_decision_date` DATE COMMENT 'Date on which the Investment Committee rendered its formal decision on the investment based on this risk assessment.',
    `ic_recommendation` STRING COMMENT 'DD teams formal recommendation to the Investment Committee (IC) based on the consolidated risk assessment findings.. Valid values are `proceed|proceed_with_conditions|further_diligence|decline`',
    `investment_strategy` STRING COMMENT 'Specific investment strategy or sub-strategy of the target (e.g., buyout, growth equity, core infrastructure, value-add real estate, direct lending), providing context for risk calibration.',
    `key_mitigants` STRING COMMENT 'Narrative description of the principal risk mitigants, structural protections, and value creation levers identified to offset the key risk factors in this assessment.',
    `key_risk_factors` STRING COMMENT 'Narrative summary of the principal risk factors identified across all DD workstreams, used in the Investment Memorandum (IM) and IC presentation. Confidential deal-sensitive content.',
    `kyc_aml_status` STRING COMMENT 'Status of KYC and AML screening conducted on the target entity and its beneficial owners as part of the DD process, per FATF requirements.. Valid values are `not_started|in_progress|cleared|flagged|escalated`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this risk assessment record, supporting version control and audit trail requirements.',
    `lead_analyst` STRING COMMENT 'Name or employee identifier of the lead internal analyst responsible for coordinating and producing this risk assessment.',
    `legal_risk_rating` STRING COMMENT 'Categorical risk rating for the legal dimension, summarizing findings on contractual terms, regulatory exposure, and litigation risk identified during legal DD.. Valid values are `low|medium_low|medium|medium_high|high`',
    `legal_risk_score` DECIMAL(5,2) COMMENT 'Quantitative risk score for the legal risk dimension, covering LPA terms, regulatory compliance, litigation exposure, IP ownership, and contractual obligations.',
    `management_quality_rating` STRING COMMENT 'Categorical rating for management team quality, covering investment track record, key-person risk, succession planning, and GP/LP alignment of interests.. Valid values are `low|medium_low|medium|medium_high|high`',
    `management_quality_score` DECIMAL(5,2) COMMENT 'Quantitative score assessing the quality, depth, track record, and alignment of the targets management team or GP investment professionals.',
    `market_risk_rating` STRING COMMENT 'Categorical rating for market risk, reflecting the investments sensitivity to macroeconomic cycles, sector dynamics, and capital market conditions.. Valid values are `low|medium_low|medium|medium_high|high`',
    `market_risk_score` DECIMAL(5,2) COMMENT 'Quantitative score for market risk exposure including macro sensitivity, sector concentration, FX risk, interest rate risk, and cyclicality of the targets business.',
    `nda_executed` BOOLEAN COMMENT 'Indicates whether a Non-Disclosure Agreement (NDA) has been executed with the target entity prior to commencement of the DD process.',
    `operational_risk_rating` STRING COMMENT 'Categorical risk rating for the operational dimension, summarizing findings on fund administration, compliance infrastructure, and operational controls.. Valid values are `low|medium_low|medium|medium_high|high`',
    `operational_risk_score` DECIMAL(5,2) COMMENT 'Quantitative risk score for the operational risk dimension, covering fund operations, middle/back-office controls, technology infrastructure, and service provider quality.',
    `overall_risk_rating` STRING COMMENT 'Consolidated risk rating assigned to the investment or manager at the conclusion of the DD engagement, synthesizing all risk dimension scores for IC decision-making.. Valid values are `low|medium_low|medium|medium_high|high`',
    `overall_risk_score` DECIMAL(5,2) COMMENT 'Quantitative composite risk score (typically on a 0–100 scale) derived from weighted individual risk dimension scores, used for portfolio-level risk aggregation and benchmarking.',
    `sanctions_screening_status` STRING COMMENT 'Result of sanctions list screening (OFAC, UN, EU) conducted on the target entity and key principals as part of the DD compliance process.. Valid values are `clear|match_pending_review|escalated`',
    `target_domicile` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction where the investment target or fund is domiciled, used for regulatory, tax, and FX risk analysis.. Valid values are `^[A-Z]{3}$`',
    `target_entity_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier (LEI) of the investment target or fund manager, used for regulatory reporting under EMIR, MiFID II counterparty identification.. Valid values are `^[A-Z0-9]{18}[0-9]{2}$`',
    `target_entity_name` STRING COMMENT 'Legal name of the investment target, fund, or manager subject to this risk assessment. Classified confidential as it may relate to non-public deal information.',
    `target_irr_pct` DECIMAL(6,4) COMMENT 'Expected gross IRR for the investment as modeled during DD, used to assess whether the risk-adjusted return meets the funds hurdle rate and SAA return targets.',
    `target_moic` DECIMAL(6,2) COMMENT 'Expected gross Multiple on Invested Capital (MOIC) for the investment as modeled during DD, complementing IRR for private markets return assessment.',
    `third_party_advisor` STRING COMMENT 'Name of the external advisor firm (legal counsel, accounting firm, technical advisor, ESG consultant) engaged to support this DD workstream.',
    `vintage_year` BIGINT COMMENT 'Year of the funds first capital call or the deals commitment year, used for performance benchmarking, J-curve analysis, and peer comparison in private markets.',
    CONSTRAINT pk_dd_risk_assessment PRIMARY KEY(`dd_risk_assessment_id`)
) COMMENT 'Consolidated risk assessment record produced at the conclusion of a DD engagement or workstream. Captures overall risk rating, individual risk dimension scores (financial, operational, legal, ESG, market, management quality), key risk factors, mitigants';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`advisor_engagement` (
    `advisor_engagement_id` BIGINT COMMENT 'Unique surrogate identifier for the advisor engagement record within the due diligence domain. Primary key for this master agreement entity.',
    `dd_workstream_id` BIGINT COMMENT 'Reference to the specific DD workstream (ODD, FDD, CDD, Legal DD, ESG DD) within the diligence domain that this advisor engagement supports.',
    `internal_deal_opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity in the deal origination pipeline (DealCloud/Dealpath) for which this advisor engagement was initiated.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity in the deal origination pipeline (DealCloud/Dealpath) for which this advisor engagement was initiated.',
    `advisor_firm_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier (LEI) of the advisor firm, used for regulatory counterparty identification and KYC/AML compliance verification.. Valid values are `^[A-Z0-9]{18}[0-9]{2}$`',
    `advisor_firm_name` STRING COMMENT 'Legal name of the third-party advisory or specialist firm engaged to support the DD workstream (e.g., law firm, Big-4 accounting firm, technical consultant, environmental consultant).',
    `agreed_fee_amount` DECIMAL(18,2) COMMENT 'Total contracted fee amount agreed with the advisor firm for the full scope of the engagement, expressed in the fee currency. For hourly/retainer structures, represents the estimated or capped total.',
    `approved_by` STRING COMMENT 'Name or identifier of the internal authority (IC member, CIO, or delegated approver) who authorized the advisor engagement per the internal governance and procurement policy.',
    `asset_class` STRING COMMENT 'Asset class of the investment or fund manager under DD for which this advisor engagement was initiated, used for cost allocation and portfolio analytics.. Valid values are `private_equity|real_estate|infrastructure|natural_resources|credit|public_equities`',
    `conflict_of_interest_checked` BOOLEAN COMMENT 'Indicates whether a formal conflict of interest check has been completed for the advisor firm relative to the target investment or fund manager prior to engagement.',
    `conflict_of_interest_notes` STRING COMMENT 'Free-text notes documenting the outcome of the conflict of interest review, including any identified conflicts, mitigants applied, or waivers granted by the IC or compliance team.',
    `cost_center_code` STRING COMMENT 'Oracle Financials General Ledger (GL) cost center code to which advisor engagement fees are allocated for internal management accounting and budget tracking purposes.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the advisor engagement record was first created in the system, providing the audit trail creation marker per data governance and regulatory record-keeping requirements.',
    `dd_report_due_date` DATE COMMENT 'Contractually agreed date by which the advisor must deliver the final DD report or key deliverable to the internal deal team, used for timeline management and IC scheduling.',
    `dd_report_received_date` DATE COMMENT 'Actual date on which the final DD report or principal deliverable was received from the advisor firm. Compared against dd_report_due_date to assess advisor performance.',
    `deal_geography` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the primary geographic jurisdiction of the investment or fund manager under due diligence, used for regulatory and reporting purposes.. Valid values are `^[A-Z]{3}$`',
    `effront_engagement_ref` STRING COMMENT 'System reference identifier for this advisor engagement record within the eFront Private Markets platform, enabling data lineage and reconciliation with the source system of record.',
    `engagement_channel` STRING COMMENT 'Method by which the advisor was selected and engaged: directly appointed, sourced via intermediary, selected through panel rotation, or awarded via competitive tender/RFP process.. Valid values are `direct|intermediated|panel_rotation|competitive_tender`',
    `engagement_end_date` DATE COMMENT 'Contractual end date of the advisor engagement. Nullable for open-ended engagements. Represents the effective-until date of the agreement.',
    `engagement_letter_date` DATE COMMENT 'Date on which the formal engagement letter or statement of work was signed by both parties, establishing the binding contractual relationship.',
    `engagement_reference` STRING COMMENT 'Externally-known alphanumeric reference code assigned to the advisor engagement, used in correspondence, invoices, and eFront/DealCloud records. Format: ENG-YYYY-NNNNNN.. Valid values are `^ENG-[0-9]{4}-[0-9]{6}$`',
    `engagement_start_date` DATE COMMENT 'Date on which the advisor engagement formally commences, as stipulated in the signed engagement letter or contract. Marks the effective-from date of the agreement.',
    `engagement_status` STRING COMMENT 'Current lifecycle state of the advisor engagement, tracking progression from initial scoping through completion or early termination.. Valid values are `draft|active|on_hold|completed|terminated|cancelled`',
    `engagement_type` STRING COMMENT 'Classification of the DD workstream the advisor is engaged to support. [ENUM-REF-CANDIDATE: legal|financial_dd|commercial_dd|technical|environmental_esg|actuarial|tax|cyber_security|other — promote to reference product]. Valid values are `legal|financial_dd|commercial_dd|technical|environmental_esg|other`',
    `fee_cap_amount` DECIMAL(18,2) COMMENT 'Maximum fee amount payable to the advisor under the engagement, regardless of hours incurred. Applicable for capped_fee and blended fee structures. Null if no cap applies.',
    `fee_currency` STRING COMMENT 'ISO 4217 three-letter currency code in which advisor fees are denominated and invoiced (e.g., USD, GBP, EUR).. Valid values are `^[A-Z]{3}$`',
    `fee_structure_type` STRING COMMENT 'Classification of the commercial fee arrangement agreed with the advisor firm (e.g., fixed fee, hourly rate, capped fee, success fee, retainer, or blended structure).. Valid values are `fixed_fee|hourly_rate|capped_fee|success_fee|retainer|blended`',
    `gl_account_code` STRING COMMENT 'Oracle Financials General Ledger (GL) account code used to record advisor fee expenses, enabling accurate financial reporting and cost attribution by deal or asset class.',
    `hourly_rate` DECIMAL(10,2) COMMENT 'Agreed hourly billing rate for the advisor engagement, applicable where the fee structure type is hourly_rate or blended. Expressed in the fee currency.',
    `ic_approval_date` DATE COMMENT 'Date on which the Investment Committee (IC) or delegated authority approved the advisor engagement. Null if IC approval is not required or not yet obtained.',
    `ic_approval_required` BOOLEAN COMMENT 'Indicates whether Investment Committee (IC) approval is required to authorize this advisor engagement, based on fee thresholds or deal materiality per internal governance policy.',
    `insurance_expiry_date` DATE COMMENT 'Expiry date of the advisor firms professional indemnity insurance policy. Used to trigger renewal verification before the policy lapses during an active engagement.',
    `insurance_verified` BOOLEAN COMMENT 'Indicates whether the advisor firms professional indemnity and liability insurance coverage has been verified and meets the minimum requirements stipulated in the engagement letter.',
    `internal_deal_lead` STRING COMMENT 'Name of the internal investment professional (deal lead or portfolio manager) responsible for managing the advisor engagement and overseeing DD deliverables.',
    `invoiced_amount` DECIMAL(18,2) COMMENT 'Cumulative amount invoiced by the advisor firm against this engagement to date, expressed in the fee currency. Used for budget tracking and accrual management.',
    `kyc_aml_status` STRING COMMENT 'Current status of the KYC/AML onboarding and verification process for the advisor firm, required before engagement commencement per regulatory and internal compliance policy.. Valid values are `pending|in_progress|approved|rejected|expired`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the advisor engagement record, supporting audit trail, data lineage, and change management requirements.',
    `lead_advisor_email` STRING COMMENT 'Primary email address of the lead advisor at the engaged firm, used for formal engagement correspondence and document exchange.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `lead_advisor_name` STRING COMMENT 'Full name of the primary individual (partner, director, or senior specialist) at the advisor firm who leads the engagement and is the principal point of contact.',
    `mandate_scope` STRING COMMENT 'Narrative description of the specific scope of work, deliverables, and boundaries of the advisors mandate as defined in the engagement letter or statement of work.',
    `nda_executed` BOOLEAN COMMENT 'Indicates whether a Non-Disclosure Agreement (NDA) has been fully executed with the advisor firm prior to sharing confidential deal or portfolio information.',
    `nda_execution_date` DATE COMMENT 'Date on which the NDA was fully executed between the pension fund and the advisor firm. Null if NDA has not yet been executed.',
    `paid_amount` DECIMAL(18,2) COMMENT 'Cumulative amount actually paid to the advisor firm against this engagement to date, expressed in the fee currency. Sourced from Oracle Financials AP payment records.',
    `preferred_panel_advisor` BOOLEAN COMMENT 'Indicates whether the advisor firm is on the pension funds pre-approved preferred advisor panel for this engagement type, streamlining procurement and governance approval.',
    `report_quality_rating` STRING COMMENT 'Internal qualitative rating assigned by the deal team to the advisors final deliverable, used for advisor performance tracking and future panel selection decisions.. Valid values are `excellent|good|satisfactory|below_expectations|unsatisfactory`',
    `rfp_conducted` BOOLEAN COMMENT 'Indicates whether a formal Request for Proposal (RFP) process was conducted to select this advisor, as required for engagements above the procurement threshold.',
    `termination_date` DATE COMMENT 'Date on which the advisor engagement was formally terminated or cancelled prior to the contractual end date. Null for engagements that run to their natural conclusion.',
    `termination_reason` STRING COMMENT 'Reason code for early termination or cancellation of the advisor engagement. Null for engagements that complete normally. Used for advisor performance analytics.. Valid values are `deal_aborted|scope_complete|advisor_performance|budget_constraint|conflict_identified|other`',
    CONSTRAINT pk_advisor_engagement PRIMARY KEY(`advisor_engagement_id`)
) COMMENT 'Master record for a third-party advisor or specialist firm engaged to support a DD workstream — e.g., legal counsel, accounting firm (FDD), technical consultant (infrastructure/real estate), environmental consultant (ESG/natural resources), or commercial';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`advisor_report` (
    `advisor_report_id` BIGINT COMMENT 'Unique surrogate identifier for the third-party advisor report record within the due diligence engagement.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the parent due diligence engagement for which this advisor report was commissioned and submitted.',
    `superseded_by_report_advisor_report_id` BIGINT COMMENT 'Reference to the newer advisor report record that supersedes this version, enabling version chain tracking across draft and final report iterations.',
    `advisor_firm_name` STRING COMMENT 'Legal name of the third-party advisory firm that authored and submitted the report, e.g., a Big Four accounting firm, law firm, or specialist ESG consultant.',
    `advisor_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier (LEI) of the third-party advisor firm, enabling unambiguous global identification for regulatory and counterparty management purposes.. Valid values are `^[A-Z0-9]{18}[0-9]{2}$`',
    `asset_class` STRING COMMENT 'Asset class of the investment subject to due diligence, aligning the report to the funds SAA domains: Private Equity, Real Estate, Infrastructure, Natural Resources, Credit, or Public Equities.. Valid values are `Private Equity|Real Estate|Infrastructure|Natural Resources|Credit|Public Equities`',
    `conditions_and_recommendations` STRING COMMENT 'Narrative description of conditions precedent, remediation actions, or recommendations made by the advisor that must be addressed prior to or post-investment close.',
    `confidentiality_classification` STRING COMMENT 'Confidentiality level assigned to the advisor report as stipulated by the advisor or engagement letter: Strictly Confidential, Confidential, Internal, or Restricted.. Valid values are `Strictly Confidential|Confidential|Internal|Restricted`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this advisor report record was first created in the system, providing the audit trail creation marker per data governance policy.',
    `data_room_location` STRING COMMENT 'URL or path reference to the virtual data room folder where the advisor report document is stored, enabling direct access for authorized DD team members.',
    `dd_scope` STRING COMMENT 'Scope of the due diligence engagement for which this report was produced: Direct Investment, Co-Investment, Fund Investment, Manager Selection, or Secondary transaction.. Valid values are `Direct Investment|Co-Investment|Fund Investment|Manager Selection|Secondary`',
    `document_format` STRING COMMENT 'File format of the advisor report document as stored in the data room: PDF, Word, Excel, or PowerPoint.. Valid values are `PDF|Word|Excel|PowerPoint`',
    `engagement_letter_reference` STRING COMMENT 'Reference number or identifier of the engagement letter or mandate agreement under which the advisor was retained to produce this report.',
    `esg_issues_identified` BOOLEAN COMMENT 'Indicates whether the advisor identified material Environmental, Social, or Governance (ESG) issues within the scope of this report, triggering ESG escalation review.',
    `esg_rating` STRING COMMENT 'ESG risk rating assigned within the advisor report, reflecting the materiality of environmental, social, and governance risks identified for the target entity.. Valid values are `Low Risk|Medium Risk|High Risk|Not Assessed`',
    `fee_amount` DECIMAL(18,2) COMMENT 'Total fee charged by the third-party advisor for producing this report, as invoiced under the engagement letter. Used for DD cost tracking and budget management.',
    `fee_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the advisor fee amount, e.g., USD, GBP, EUR.. Valid values are `^[A-Z]{3}$`',
    `follow_up_due_date` DATE COMMENT 'Target date by which outstanding follow-up items identified in the advisor report must be resolved, supporting DD timeline management and IC readiness.',
    `follow_up_required` BOOLEAN COMMENT 'Indicates whether the advisor report has identified open items or questions requiring follow-up clarification from the advisor or the target entity before DD can be concluded.',
    `ic_submission_date` DATE COMMENT 'Date on which this advisor report was included in and submitted to the Investment Committee (IC) as part of the formal IC approval package.',
    `ic_submission_included` BOOLEAN COMMENT 'Indicates whether this advisor report has been included as a supporting document in the Investment Committee (IC) submission pack for the related DD engagement.',
    `internal_review_date` DATE COMMENT 'Date on which the internal investment team member completed their review and sign-off of the advisor report findings.',
    `internal_review_notes` STRING COMMENT 'Free-text notes from the internal reviewer capturing their assessment, challenges, or additional context on the advisors findings for IC and investment team use.',
    `internal_reviewer_name` STRING COMMENT 'Name of the internal investment team member (analyst, associate, or VP) responsible for reviewing, challenging, and summarizing the advisor report findings.',
    `invoice_reference` STRING COMMENT 'Reference number of the advisors invoice for this report engagement, linking to the Oracle Financials AP module for payment processing and cost allocation.',
    `key_findings_summary` STRING COMMENT 'Concise narrative summary of the advisors principal findings, red flags, and material observations from the report, as extracted for IC and investment team review.',
    `lead_advisor_name` STRING COMMENT 'Full name of the lead partner or senior engagement manager at the advisor firm responsible for the report deliverable.',
    `material_issues_count` BIGINT COMMENT 'Total number of material issues or red flags identified by the advisor in the report, providing a quantitative signal of report severity for IC prioritization.',
    `nda_reference` STRING COMMENT 'Reference number of the Non-Disclosure Agreement (NDA) executed with the advisor firm governing the confidentiality of information exchanged during the DD engagement.',
    `overall_conclusion` STRING COMMENT 'High-level conclusion of the advisors report: Satisfactory, Satisfactory with Conditions, Unsatisfactory, or Inconclusive. Feeds into the ICs overall DD rating for the engagement.. Valid values are `Satisfactory|Satisfactory with Conditions|Unsatisfactory|Inconclusive`',
    `page_count` BIGINT COMMENT 'Total number of pages in the advisor report document, used for document management, completeness verification, and IC pack preparation.',
    `regulatory_issues_identified` BOOLEAN COMMENT 'Indicates whether the advisor identified material regulatory, legal, or compliance issues within the report scope, requiring escalation to legal counsel or compliance.',
    `reliance_letter_reference` STRING COMMENT 'Reference number of the formal reliance letter issued by the advisor permitting the pension fund to rely on the report findings for investment decision purposes.',
    `reliance_permitted` BOOLEAN COMMENT 'Indicates whether the advisor has granted the pension fund permission to rely on the report for investment decision-making purposes, as stipulated in the engagement letter.',
    `report_date` DATE COMMENT 'The official date printed on the face of the advisor report, representing the date as of which the advisors findings and conclusions are stated.',
    `report_period_end` DATE COMMENT 'End date of the historical period covered by the advisors analysis, typically the most recent audited financial year-end or ESG reporting period.',
    `report_period_start` DATE COMMENT 'Start date of the historical period covered by the advisors analysis, e.g., the earliest financial year reviewed in an FDD or the earliest ESG data period assessed.',
    `report_reference` STRING COMMENT 'Externally assigned unique reference number or code for the advisor report, as issued by the third-party advisor firm. Used for cross-referencing with the advisors own document management system.. Valid values are `^[A-Z]{2,6}-RPT-[0-9]{4}-[0-9]{4,6}$`',
    `report_status` STRING COMMENT 'Current lifecycle status of the advisor report: Draft (in preparation), Preliminary (initial submission), Final (approved deliverable), Superseded (replaced by newer version), or Withdrawn.. Valid values are `Draft|Preliminary|Final|Superseded|Withdrawn`',
    `report_subtype` STRING COMMENT 'Further classification within the report type, e.g., Quality of Earnings under FDD, IT Infrastructure under ODD, TCFD Climate Assessment under ESG. Free-text to accommodate evolving DD practice.',
    `report_title` STRING COMMENT 'Full descriptive title of the advisor report as submitted by the third-party advisor, e.g., Financial Due Diligence Report – Target Co Ltd – Q3 2024.',
    `report_type` STRING COMMENT 'Classification of the due diligence report by discipline: Financial Due Diligence (FDD), Operational Due Diligence (ODD), Commercial Due Diligence (CDD), Legal, ESG, Technical, or Environmental.',
    `report_version` STRING COMMENT 'Version identifier of the report (e.g., v1.0, v2.1, v3.0-final), tracking draft iterations through to the final deliverable submitted for IC review.. Valid values are `^v[0-9]+.[0-9]+(.[0-9]+)?$`',
    `risk_rating` STRING COMMENT 'Aggregate risk rating assigned by the advisor based on findings within the report scope: Low, Medium, High, or Critical. Used in IC risk aggregation and portfolio risk management.. Valid values are `Low|Medium|High|Critical`',
    `submission_date` DATE COMMENT 'Date on which the advisor formally submitted this version of the report to the pension funds due diligence team.',
    `target_entity_name` STRING COMMENT 'Legal name of the investment target, fund, or external manager that is the subject of the due diligence report, as referenced in the advisors deliverable.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this advisor report record, supporting audit trail and data lineage requirements in the Databricks Silver layer.',
    CONSTRAINT pk_advisor_report PRIMARY KEY(`advisor_report_id`)
) COMMENT 'Formal report or deliverable submitted by a third-party advisor as part of a DD engagement. Captures report type (legal opinion, FDD report, ODD report, environmental assessment, technical report, CDD report), submission date, report version, key';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`odd_assessment` (
    `odd_assessment_id` BIGINT COMMENT 'Unique surrogate identifier for the ODD assessment record. Primary key for the odd_assessment product in the diligence domain.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the parent due diligence engagement under which this ODD assessment was conducted. Links to the dd_engagement product in the diligence domain.',
    `employee_id` BIGINT COMMENT 'Internal analyst responsible for leading and coordinating the ODD assessment. Accountable for the completeness and accuracy of the ODD findings.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager or GP being assessed in this ODD review. Links to the gp_profile product in the manager domain.',
    `lead_odd_analyst_employee_id` BIGINT COMMENT 'Internal analyst responsible for leading and coordinating the ODD assessment. Accountable for the completeness and accuracy of the ODD findings.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager or GP being assessed in this ODD review. Links to the gp_profile product in the manager domain.',
    `manager_mandate_id` BIGINT COMMENT 'Foreign key linking to manager.manager_mandate. Business justification: ODD assessments evaluate operational risks at mandate level (fee structures, reporting SLAs, custody arrangements).',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: ODD assessments evaluate GP/manager compliance with specific regulatory frameworks.',
    `actual_completion_date` DATE COMMENT 'Date on which the ODD assessment was formally completed and the final report signed off. Compared against target_completion_date for SLA tracking.',
    `assessment_date` DATE COMMENT 'The principal date on which the ODD assessment was formally conducted or the on-site visit occurred. Represents the real-world business event date for this assessment.',
    `assessment_reference` STRING COMMENT 'Externally-known unique alphanumeric reference code assigned to this ODD assessment (e.g., ODD-2024-00123). Used for cross-system tracking and IC reporting.. Valid values are `^ODD-[0-9]{4}-[0-9]{5}$`',
    `assessment_status` STRING COMMENT 'Current lifecycle status of the ODD assessment workflow, from initial drafting through analyst review to final completion or cancellation.. Valid values are `draft|in_progress|under_review|completed|cancelled`',
    `assessment_type` STRING COMMENT 'Classification of the ODD assessment by trigger: initial (first-time manager), re-up (re-commitment), periodic (scheduled review), event-driven (triggered by material change), or ad-hoc.. Valid values are `initial|re_up|periodic|event_driven|ad_hoc`',
    `auditor_name` STRING COMMENT 'Name of the independent external auditor engaged to audit the managers funds and management company financial statements. Independence and quality assessed during ODD.',
    `aum_at_assessment` DECIMAL(20,2) COMMENT 'Total AUM managed by the external fund manager at the time of the ODD assessment, expressed in the reporting currency. Used to contextualise operational scale and resource adequacy.',
    `aum_currency` STRING COMMENT 'ISO 4217 three-letter currency code in which the managers AUM at assessment is denominated (e.g., USD, EUR).. Valid values are `^[A-Z]{3}$`',
    `bcp_tested_flag` BOOLEAN COMMENT 'Indicates whether the manager has conducted a documented and tested Business Continuity Plan (BCP) and Disaster Recovery (DR) exercise within the past 12 months.',
    `compliance_aml_rating` STRING COMMENT 'ODD sub-dimension rating for the managers compliance programme, AML/KYC controls, regulatory licensing status, and adherence to applicable regulations (MiFID II, EMIR, FATF).. Valid values are `satisfactory|acceptable|marginal|unsatisfactory`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this ODD assessment record was first created in the system. Audit trail field supporting data lineage and regulatory record-keeping requirements.',
    `custodian_name` STRING COMMENT 'Name of the primary custodian holding assets on behalf of the managers funds. Assessed for independence, creditworthiness, and segregation of assets.',
    `cybersecurity_rating` STRING COMMENT 'ODD sub-dimension rating for the managers cybersecurity posture, data protection controls, incident response procedures, and alignment with ISO 27001 and SOC 2 standards.. Valid values are `satisfactory|acceptable|marginal|unsatisfactory`',
    `ddq_received_date` DATE COMMENT 'Date on which the completed ILPA or proprietary Due Diligence Questionnaire (DDQ) was received from the manager. Marks the start of substantive ODD analysis.',
    `fund_admin_rating` STRING COMMENT 'ODD sub-dimension rating for the managers fund administration arrangements, use of independent third-party administrators, NAV calculation controls, and investor reporting quality.. Valid values are `satisfactory|acceptable|marginal|unsatisfactory`',
    `fund_administrator_name` STRING COMMENT 'Name of the third-party fund administrator responsible for NAV calculation, investor reporting, and fund accounting on behalf of the managers funds.',
    `governance_rating` STRING COMMENT 'ODD sub-dimension rating for the managers governance framework, ownership structure, key-person dependencies, succession planning, and organizational stability.. Valid values are `satisfactory|acceptable|marginal|unsatisfactory`',
    `independent_admin_flag` BOOLEAN COMMENT 'Indicates whether the manager uses a fully independent third-party fund administrator for NAV calculation and investor reporting, a key ODD best-practice indicator.',
    `initiation_date` DATE COMMENT 'Date on which the ODD assessment process was formally initiated and assigned to the lead analyst. Marks the start of the ODD workflow lifecycle.',
    `key_person_risk_flag` BOOLEAN COMMENT 'Indicates whether the ODD assessment identified material key-person dependency risk at the manager, where the departure of one or more individuals would significantly impair operations.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this ODD assessment record was most recently modified. Supports audit trail, data lineage tracking, and incremental data pipeline processing.',
    `legal_counsel_name` STRING COMMENT 'Name of the primary external legal counsel engaged by the manager for fund structuring, regulatory compliance, and ongoing legal matters. Assessed for quality and independence.',
    `litigation_flag` BOOLEAN COMMENT 'Indicates whether the ODD assessment identified material pending or historical litigation, arbitration, or legal proceedings involving the manager or its principals.',
    `material_findings_summary` STRING COMMENT 'Narrative summary of material operational findings, red flags, or concerns identified during the ODD assessment. Key input to IC memorandum and investment decision.',
    `next_review_date` DATE COMMENT 'Date on which the next periodic ODD review of this manager is scheduled. Supports ongoing monitoring obligations and periodic re-assessment cadence.',
    `number_of_investment_professionals` BIGINT COMMENT 'Total headcount of investment professionals (portfolio managers, analysts, associates) at the manager as reported during the ODD assessment. Indicator of operational capacity.',
    `number_of_operations_staff` BIGINT COMMENT 'Total headcount of operations, middle-office, and back-office staff at the manager as reported during ODD. Assesses operational infrastructure relative to AUM and strategy complexity.',
    `odd_recommendation` STRING COMMENT 'Formal ODD team recommendation on whether to proceed with the investment based on operational findings: proceed, proceed with conditions, defer pending remediation, or decline.. Valid values are `proceed|proceed_with_conditions|defer|decline`',
    `onsite_visit_conducted` BOOLEAN COMMENT 'Indicates whether an in-person on-site visit to the managers offices was conducted as part of this ODD assessment, as opposed to a purely desk-based or remote review.',
    `onsite_visit_date` DATE COMMENT 'Date on which the on-site visit to the managers offices was conducted. Populated only when onsite_visit_conducted is true.',
    `overall_odd_rating` STRING COMMENT 'Composite qualitative rating summarising the managers overall operational infrastructure quality across all ODD dimensions. Used as a key input to IC approval decisions.. Valid values are `satisfactory|acceptable|marginal|unsatisfactory`',
    `prime_broker_names` STRING COMMENT 'Names of the managers primary prime brokerage counterparties as identified during ODD. Relevant for counterparty concentration risk assessment and settlement infrastructure review.',
    `regulatory_action_flag` BOOLEAN COMMENT 'Indicates whether the manager or its principals are subject to any current or historical regulatory sanctions, enforcement actions, or material regulatory findings identified during ODD.',
    `remediation_deadline` DATE COMMENT 'Target date by which the manager must complete all required operational remediation actions identified in the ODD assessment. Populated only when remediation_required_flag is true.',
    `remediation_required_flag` BOOLEAN COMMENT 'Indicates whether the ODD assessment identified operational deficiencies requiring formal remediation actions by the manager prior to or as a condition of investment.',
    `risk_management_rating` STRING COMMENT 'ODD sub-dimension rating for the managers risk management framework, including VaR/CVaR monitoring, counterparty risk controls, liquidity risk management, and stress testing capabilities.. Valid values are `satisfactory|acceptable|marginal|unsatisfactory`',
    `soc2_report_available` BOOLEAN COMMENT 'Indicates whether the manager or its key service providers have a current SOC 2 Type II report available, evidencing controls over security, availability, and confidentiality.',
    `target_completion_date` DATE COMMENT 'Planned date by which the ODD assessment is expected to be completed and findings submitted for IC review. Used for workflow tracking and IC scheduling.',
    `technology_systems_rating` STRING COMMENT 'ODD sub-dimension rating for the managers technology infrastructure, portfolio management systems, cybersecurity controls, disaster recovery, and business continuity capabilities.. Valid values are `satisfactory|acceptable|marginal|unsatisfactory`',
    `third_party_odd_provider` STRING COMMENT 'Name of any external specialist ODD firm engaged to assist with or independently conduct the operational due diligence review (e.g., Albourne Partners, PAAMCO, Aksia).',
    `trade_execution_rating` STRING COMMENT 'ODD sub-dimension rating for the managers order management, best execution policies, prime brokerage arrangements, settlement processes, and DVP controls.. Valid values are `satisfactory|acceptable|marginal|unsatisfactory`',
    `valuation_rating` STRING COMMENT 'ODD sub-dimension rating for the managers valuation policies, independence of valuation function, NAV/GAV calculation methodology, and use of third-party valuation agents.. Valid values are `satisfactory|acceptable|marginal|unsatisfactory`',
    `years_in_operation` BIGINT COMMENT 'Number of years the manager has been in operation as of the assessment date. Provides context for organisational maturity and track record depth.',
    CONSTRAINT pk_odd_assessment PRIMARY KEY(`odd_assessment_id`)
) COMMENT 'Operational Due Diligence (ODD) assessment record specific to external fund manager evaluations. Captures operational infrastructure quality ratings across key ODD dimensions: governance and organizational structure, technology and systems, valuation';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`fdd_assessment` (
    `fdd_assessment_id` BIGINT COMMENT 'Unique surrogate identifier for the Financial Due Diligence (FDD) assessment record within the diligence domain.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the parent DD engagement record that initiated this FDD assessment, linking to the overarching diligence workflow.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: Financial DD normalizes EBITDA and projects cash flows under specific economic assumptions.',
    `employee_id` BIGINT COMMENT 'Reference to the internal analyst responsible for leading the FDD workstream, accountable for QoE findings and EBITDA normalization conclusions.',
    `fee_benchmark_id` BIGINT COMMENT 'Foreign key linking to fee.fee_benchmark. Business justification: Financial due diligence requires comparing proposed manager fee structures against market benchmarks.',
    `lead_fdd_analyst_employee_id` BIGINT COMMENT 'Reference to the internal analyst responsible for leading the FDD workstream, accountable for QoE findings and EBITDA normalization conclusions.',
    `accounting_standard` STRING COMMENT 'Accounting framework under which the targets financial statements were prepared, critical for normalization and comparability of FDD findings.. Valid values are `IFRS|US_GAAP|Local_GAAP|Other`',
    `adjusted_net_debt` DECIMAL(20,2) COMMENT 'Net debt after FDD reconciliation adjustments including debt-like items, contingent liabilities, pension deficits, and off-balance-sheet obligations.',
    `assessment_date` DATE COMMENT 'The principal date on which the FDD assessment was formally conducted or the financial analysis period was anchored, per the engagement timeline.',
    `assessment_reference` STRING COMMENT 'Externally-known alphanumeric reference code uniquely identifying this FDD assessment, used in IC submissions, IM documents, and eFront records.. Valid values are `^FDD-[0-9]{4}-[0-9]{6}$`',
    `assessment_status` STRING COMMENT 'Current lifecycle state of the FDD assessment, tracking progression from initial drafting through analyst review to IC-ready completion or withdrawal.. Valid values are `draft|in_progress|under_review|completed|withdrawn`',
    `audit_firm` STRING COMMENT 'Name of the external auditor that issued the audit opinion on the targets financial statements reviewed during FDD.',
    `audit_opinion_type` STRING COMMENT 'Type of audit opinion issued on the most recent audited financial statements, flagging any qualifications or adverse opinions as key FDD risk indicators.. Valid values are `unqualified|qualified|adverse|disclaimer`',
    `capex_growth` DECIMAL(20,2) COMMENT 'Annual growth capital expenditure identified during FDD for capacity expansion or new initiatives, distinct from maintenance CapEx, in the FDD reporting currency.',
    `capex_maintenance` DECIMAL(20,2) COMMENT 'Annual maintenance capital expenditure required to sustain current operating capacity, as identified during FDD, in the FDD reporting currency.',
    `conditions_and_recommendations` STRING COMMENT 'Conditions precedent or post-closing recommendations arising from FDD findings, including price adjustments, escrow arrangements, or warranty and indemnity requirements.',
    `contingent_liabilities_amount` DECIMAL(20,2) COMMENT 'Estimated aggregate value of contingent liabilities identified during FDD, used in net debt reconciliation and risk-adjusted valuation, in the FDD reporting currency.',
    `contingent_liabilities_identified` BOOLEAN COMMENT 'Indicates whether material contingent liabilities (litigation, tax exposures, warranties, guarantees) were identified during FDD requiring IC disclosure.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this FDD assessment record was first created in the system, used for audit trail and data lineage tracking.',
    `data_room_reference` STRING COMMENT 'Reference identifier or URL for the virtual data room folder containing FDD source documents, financial models, and supporting workpapers.',
    `ebitda_margin_pct` DECIMAL(8,4) COMMENT 'Normalized EBITDA as a percentage of revenue for the most recent full fiscal year, a key profitability metric used in valuation and peer benchmarking.',
    `ebitda_normalization_total` DECIMAL(20,2) COMMENT 'Net aggregate of all EBITDA normalization adjustments identified during FDD, being the difference between reported and normalized EBITDA.',
    `esg_financial_materiality_flag` BOOLEAN COMMENT 'Indicates whether ESG factors with financial materiality (e.g., carbon liabilities, stranded assets, regulatory fines) were identified and incorporated into FDD findings.',
    `financial_controls_rating` STRING COMMENT 'Assessment of the adequacy of the targets internal financial controls and reporting processes, informing post-acquisition integration planning.. Valid values are `strong|adequate|weak|deficient`',
    `financial_model_version` STRING COMMENT 'Version identifier of the financial model (DCF, LBO, or returns model) used in conjunction with FDD findings for investment valuation and IC submission.',
    `financial_statements_period_end` DATE COMMENT 'End date of the historical financial period reviewed during FDD, anchoring the most recent audited or management accounts period analyzed.',
    `financial_statements_period_start` DATE COMMENT 'Start date of the historical financial period reviewed during FDD, typically covering 3–5 fiscal years of audited financial statements.',
    `ic_submission_ready` BOOLEAN COMMENT 'Indicates whether the FDD assessment has been reviewed, signed off, and is ready for inclusion in the Investment Committee (IC) submission package.',
    `key_financial_risks_summary` STRING COMMENT 'Narrative summary of the most material financial risks identified during FDD, including earnings quality concerns, leverage risks, and structural financial issues.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this FDD assessment record, supporting version control and audit compliance.',
    `management_accounts_quality` STRING COMMENT 'Quality rating of the targets management reporting and internal accounts, assessing timeliness, accuracy, and granularity for post-acquisition monitoring.. Valid values are `high|acceptable|low|unacceptable`',
    `net_debt_adjustment_notes` STRING COMMENT 'Narrative description of material adjustments made to reported net debt during FDD, including debt-like items, earn-outs, and pension obligations identified.',
    `normalized_ebitda` DECIMAL(20,2) COMMENT 'EBITDA after all FDD normalization adjustments (one-time items, non-recurring charges, run-rate adjustments), representing sustainable earnings power.',
    `normalized_working_capital` DECIMAL(20,2) COMMENT 'Normalized working capital peg established during FDD, representing the level of working capital required to operate the business at a normalized level.',
    `overall_fdd_rating` STRING COMMENT 'Aggregate FDD rating summarizing the overall financial health and risk profile of the target, used as a key input to the IC investment decision.. Valid values are `satisfactory|conditional|unsatisfactory`',
    `pension_deficit` DECIMAL(20,2) COMMENT 'Defined benefit pension scheme deficit identified during FDD, treated as a debt-like item in net debt reconciliation, in the FDD reporting currency.',
    `qoe_findings_summary` STRING COMMENT 'Narrative summary of key QoE findings including revenue recognition practices, earnings sustainability, and material accounting policy concerns identified in FDD.',
    `qoe_rating` STRING COMMENT 'FDD analysts assessment of the quality and sustainability of the targets reported earnings, reflecting reliability of financial statements for investment decisions.. Valid values are `high|acceptable|low|unacceptable`',
    `reported_ebitda` DECIMAL(20,2) COMMENT 'EBITDA as reported by management or derived from audited financials before any normalization adjustments, in the FDD reporting currency.',
    `reported_net_debt` DECIMAL(20,2) COMMENT 'Net debt as reported by management (gross debt minus cash and cash equivalents) prior to FDD adjustments, in the FDD reporting currency.',
    `reported_revenue` DECIMAL(20,2) COMMENT 'Total revenue as reported in the targets audited financial statements for the most recent full fiscal year reviewed, in the FDD reporting currency.',
    `reporting_currency` STRING COMMENT 'ISO 4217 three-letter currency code in which all FDD financial figures are denominated (e.g., USD, GBP, EUR).. Valid values are `^[A-Z]{3}$`',
    `revenue_cagr_pct` DECIMAL(8,4) COMMENT 'Compound annual growth rate of the targets revenue over the FDD review period, expressed as a percentage, used to assess historical growth trajectory.',
    `revenue_concentration_risk` STRING COMMENT 'Risk rating reflecting the degree of revenue concentration by customer, product, or geography identified during FDD, impacting earnings sustainability assessment.. Valid values are `low|medium|high|critical`',
    `sign_off_date` DATE COMMENT 'Date on which the lead FDD analyst or senior investment professional formally signed off on the completed FDD assessment for IC submission.',
    `tax_structure_risk` STRING COMMENT 'FDD analysts risk rating of the targets tax structure, including transfer pricing, deferred tax positions, and unresolved tax authority disputes.. Valid values are `low|medium|high|critical`',
    `third_party_advisor_firm` STRING COMMENT 'Name of the external accounting or advisory firm engaged to conduct or support the FDD (e.g., Big 4 accounting firm), if applicable.',
    `third_party_report_date` DATE COMMENT 'Date on which the external advisor issued the final FDD report, used to assess report currency and relevance at IC submission.',
    `working_capital_findings_summary` STRING COMMENT 'Narrative summary of working capital analysis findings including seasonality, cash conversion cycle, and any unusual movements identified during FDD.',
    `working_capital_peg_basis` STRING COMMENT 'Methodology used to establish the normalized working capital peg in the SPA, determining the reference period for working capital adjustment at closing.. Valid values are `trailing_12_month_average|trailing_3_year_average|negotiated|other`',
    CONSTRAINT pk_fdd_assessment PRIMARY KEY(`fdd_assessment_id`)
) COMMENT 'Financial Due Diligence (FDD) assessment record capturing the financial analysis of a target investment or fund manager. Tracks quality of earnings (QoE) findings, EBITDA normalization adjustments, working capital analysis, net debt reconciliation';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`cdd_assessment` (
    `cdd_assessment_id` BIGINT COMMENT 'Unique system-generated identifier for the Commercial Due Diligence (CDD) assessment record. Primary key for this entity.',
    `country_outlook_id` BIGINT COMMENT 'Foreign key linking to research.country_outlook. Business justification: Commercial DD for cross-border investments must reference country risk assessment.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the parent due diligence engagement under which this CDD assessment was commissioned. Links to the overarching DD engagement record.',
    `employee_id` BIGINT COMMENT 'Identifier of the internal investment professional responsible for leading and owning the CDD assessment. Links to the internal analyst/employee party record.',
    `lead_analyst_employee_id` BIGINT COMMENT 'Identifier of the internal investment professional responsible for leading and owning the CDD assessment. Links to the internal analyst/employee party record.',
    `sector_outlook_id` BIGINT COMMENT 'Foreign key linking to research.sector_outlook. Business justification: Commercial DD assesses market size, growth rates, and competitive dynamics. Must reference the sector outlook that informed TAM/SAM assumptions.',
    `advisor_report_date` DATE COMMENT 'Date on which the third-party CDD advisor delivered their final report, used to track timeliness of DD completion relative to IC submission deadlines.',
    `assessment_date` DATE COMMENT 'The principal date on which the CDD assessment was formally conducted or the assessment report was issued by the lead analyst or third-party advisor.',
    `assessment_reference` STRING COMMENT 'Externally-known alphanumeric reference code uniquely identifying this CDD assessment, used in Investment Memoranda, IC submissions, and advisor correspondence.. Valid values are `^CDD-[0-9]{4}-[A-Z0-9]{6,12}$`',
    `assessment_status` STRING COMMENT 'Current lifecycle status of the CDD assessment, tracking progression from initial drafting through IC-ready completion or cancellation.. Valid values are `draft|in_progress|under_review|completed|superseded|cancelled`',
    `assessment_version` BIGINT COMMENT 'Version number of the CDD assessment, incremented when material updates are made post-initial completion (e.g., following management clarifications or updated market data).',
    `asset_class` STRING COMMENT 'Asset class of the target investment being assessed, determining the applicable CDD framework, benchmarks, and IC approval thresholds.. Valid values are `private_equity|real_estate|infrastructure|natural_resources|credit|public_equity`',
    `cdd_scope_notes` STRING COMMENT 'Narrative description of the scope, limitations, and key assumptions of the CDD assessment, including any areas excluded from scope or subject to information constraints.',
    `competitive_intensity` STRING COMMENT 'Analyst-assigned rating of the overall competitive intensity in the targets market, reflecting pricing pressure, new entrant threat, and substitute product risk.. Valid values are `low|moderate|high|very_high`',
    `competitive_moat_assessment` STRING COMMENT 'Analyst assessment of the durability and width of the targets competitive moat, including barriers to entry such as IP, switching costs, network effects, and regulatory licences.. Valid values are `wide|narrow|none`',
    `competitive_position_rating` STRING COMMENT 'Assessment of the target entitys competitive standing within its primary market, reflecting market share, brand strength, pricing power, and differentiation.. Valid values are `market_leader|strong_challenger|niche_player|weak_position`',
    `completion_date` DATE COMMENT 'Date on which the CDD assessment was formally completed and signed off by the lead analyst and/or IC sponsor, marking readiness for IC submission.',
    `contracted_revenue_pct` DECIMAL(8,4) COMMENT 'Percentage of total revenue covered by long-term contracts or take-or-pay agreements, a key indicator of revenue predictability and downside protection.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this CDD assessment record was first created in the system, used for audit trail and data lineage purposes.',
    `customer_churn_rate_pct` DECIMAL(8,4) COMMENT 'Annual customer attrition rate expressed as a percentage of total customers, used to assess revenue retention quality and commercial durability of the target.',
    `data_room_reference` STRING COMMENT 'Reference identifier or URL for the virtual data room folder containing CDD-related documents, management presentations, and market research reports.',
    `esg_commercial_risk_flag` BOOLEAN COMMENT 'Indicates whether material ESG-related commercial risks (e.g., carbon transition risk, social licence to operate) were identified during the CDD assessment.',
    `growth_strategy_assessment` STRING COMMENT 'Classification of the targets primary growth strategy as assessed during CDD, used to evaluate execution risk, capital requirements, and alignment with investment thesis.. Valid values are `organic|acquisitive|hybrid|turnaround`',
    `ic_submission_ready` BOOLEAN COMMENT 'Indicates whether the CDD assessment has been completed and approved to a standard sufficient for inclusion in the Investment Committee (IC) submission package.',
    `investment_thesis_alignment` STRING COMMENT 'Assessment of how well the targets commercial profile aligns with the funds stated investment thesis, SAA objectives, and long-term return requirements.. Valid values are `strong|moderate|weak|misaligned`',
    `key_commercial_opportunities` STRING COMMENT 'Narrative summary of the primary commercial value creation opportunities identified during CDD, including market expansion, pricing improvement, and customer growth levers.',
    `key_commercial_risks` STRING COMMENT 'Narrative summary of the most material commercial risks identified during the CDD assessment, including market, competitive, customer, and regulatory risk factors.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this CDD assessment record, supporting audit trail, version control, and change management requirements.',
    `macro_sensitivity_rating` STRING COMMENT 'Assessment of the targets revenue and earnings sensitivity to macroeconomic variables (GDP, interest rates, inflation, FX), used in stress testing and LDI alignment.. Valid values are `low|moderate|high|very_high`',
    `management_quality_rating` STRING COMMENT 'CDD-perspective rating of the target management teams commercial track record, strategic vision, and execution capability, distinct from ODD management assessment.. Valid values are `strong|satisfactory|cautionary|unsatisfactory`',
    `market_cycle_stage` STRING COMMENT 'Analyst assessment of the current stage of the targets market cycle at the time of CDD, informing entry timing, valuation, and macroeconomic sensitivity analysis.. Valid values are `early_growth|growth|mature|late_cycle|distressed`',
    `market_growth_assessment` STRING COMMENT 'Qualitative classification of the target markets growth trajectory based on analyst assessment of structural drivers, cyclicality, and secular trends.. Valid values are `high_growth|moderate_growth|stable|declining|cyclical`',
    `market_growth_rate_pct` DECIMAL(8,4) COMMENT 'Projected compound annual growth rate (CAGR) of the targets addressable market expressed as a percentage, used to assess long-term revenue trajectory and market tailwinds.',
    `market_share_pct` DECIMAL(8,4) COMMENT 'Estimated percentage of the targets primary addressable market captured by the target entity, used to benchmark competitive position and revenue sustainability.',
    `market_size_usd_mm` DECIMAL(18,2) COMMENT 'Estimated total addressable market (TAM) size in USD millions for the targets primary market, derived from third-party research and proprietary analysis.',
    `number_of_competitors` BIGINT COMMENT 'Count of direct competitors identified in the CDD competitive landscape analysis, used to assess market concentration and competitive intensity.',
    `overall_cdd_rating` STRING COMMENT 'Composite qualitative rating summarising the overall commercial viability of the target investment based on all CDD workstreams, used in IC submission and investment decision.. Valid values are `strong|satisfactory|cautionary|unsatisfactory`',
    `pricing_power_assessment` STRING COMMENT 'Analyst assessment of the targets ability to sustain or increase prices without material volume loss, reflecting brand strength, switching costs, and market position.. Valid values are `strong|moderate|limited|none`',
    `regulatory_risk_rating` STRING COMMENT 'Assessment of the regulatory risk exposure facing the target entity, including licensing requirements, sector-specific regulation, and potential for adverse regulatory change.. Valid values are `low|moderate|high|critical`',
    `revenue_base_year` BIGINT COMMENT 'The fiscal year used as the baseline for market size, revenue, and growth rate estimates in the CDD assessment, ensuring temporal consistency across analyses.',
    `revenue_visibility` STRING COMMENT 'Classification of the targets revenue model by predictability and contractual certainty, informing cash flow forecasting and risk-adjusted return analysis.. Valid values are `contracted|recurring|transactional|project_based`',
    `supply_chain_risk_rating` STRING COMMENT 'Assessment of the targets exposure to supply chain disruption risk, including supplier concentration, geographic risk, and input cost volatility identified during CDD.. Valid values are `low|moderate|high|critical`',
    `target_entity_name` STRING COMMENT 'Legal name of the investment target (company, fund, or asset) subject to this CDD assessment. Treated as confidential pre-announcement deal information.',
    `target_geography` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code representing the primary operating geography of the target entity, used for country risk and SAA alignment.. Valid values are `^[A-Z]{3}$`',
    `target_sector` STRING COMMENT 'Primary industry sector classification of the target entity (e.g., Technology, Healthcare, Industrials, Consumer), used for peer benchmarking and portfolio construction analysis.',
    `technology_disruption_risk` STRING COMMENT 'Assessment of the risk that technological innovation or digital disruption could materially erode the targets market position or business model over the investment horizon.. Valid values are `low|moderate|high|critical`',
    `third_party_advisor` STRING COMMENT 'Name of the external commercial due diligence advisor firm engaged to support or lead the CDD assessment (e.g., strategy consultancy, sector specialist).',
    `top_5_customer_concentration_pct` DECIMAL(8,4) COMMENT 'Combined revenue percentage attributable to the five largest customers, used to assess customer diversification risk and revenue resilience in the CDD analysis.',
    `top_customer_concentration_pct` DECIMAL(8,4) COMMENT 'Revenue percentage attributable to the single largest customer, a key risk indicator for customer concentration and revenue sustainability in the CDD assessment.',
    CONSTRAINT pk_cdd_assessment PRIMARY KEY(`cdd_assessment_id`)
) COMMENT 'Commercial Due Diligence (CDD) assessment record evaluating the market position, competitive dynamics, and commercial viability of a target investment. Captures market size and growth assessment, competitive positioning, customer concentration analysis';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`esg_dd_assessment` (
    `esg_dd_assessment_id` BIGINT COMMENT 'Unique surrogate identifier for the ESG due diligence assessment record within the diligence domain.',
    `climate_scenario_id` BIGINT COMMENT 'Foreign key linking to esg.climate_scenario. Business justification: TCFD-aligned DD requires documenting which climate scenario informed transition/physical risk ratings.',
    `climate_stress_scenario_id` BIGINT COMMENT 'Foreign key linking to risk.stress_scenario. Business justification: ESG DD requires TCFD-aligned climate scenario analysis. Product already has climate_transition_risk_rating and tcfd_disclosure_assessed - linking to stress_scenario enables formal',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the parent DD engagement under which this ESG assessment was conducted.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity that this ESG DD assessment is associated with.',
    `employee_id` BIGINT COMMENT 'Internal analyst responsible for conducting and owning this ESG due diligence assessment.',
    `esg_employee_id` BIGINT COMMENT 'Internal analyst responsible for conducting and owning this ESG due diligence assessment.',
    `exclusion_list_id` BIGINT COMMENT 'Foreign key linking to esg.exclusion_list. Business justification: Pension fund ESG DD must verify targets against exclusion lists per SFDR/fiduciary requirements.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager being assessed, if this ESG DD relates to a manager mandate evaluation rather than a direct investment.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager being assessed, if this ESG DD relates to a manager mandate evaluation rather than a direct investment.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity that this ESG DD assessment is associated with.',
    `reviewer_employee_id` BIGINT COMMENT 'Internal senior ESG professional or portfolio manager who reviewed and approved the ESG DD assessment prior to IC submission.',
    `reviewer_id` BIGINT COMMENT 'Internal senior ESG professional or portfolio manager who reviewed and approved the ESG DD assessment prior to IC submission.',
    `sfdr_disclosure_id` BIGINT COMMENT 'Foreign key linking to compliance.sfdr_disclosure. Business justification: ESG DD assessments directly inform SFDR Article 6/8/9 classification. EU pension funds must link ESG diligence to SFDR disclosures for regulatory filings.',
    `actual_completion_date` DATE COMMENT 'Date on which the ESG DD assessment was actually completed and signed off by the lead ESG analyst.',
    `advisor_report_reference` STRING COMMENT 'Document reference or data room location of the third-party ESG advisor report supporting this assessment, for audit trail and IC submission purposes.',
    `assessment_reference` STRING COMMENT 'Externally-known unique business reference code for this ESG DD assessment, used in IC submissions, IM documentation, and eFront records.. Valid values are `^ESG-DD-[0-9]{4}-[0-9]{6}$`',
    `assessment_status` STRING COMMENT 'Current lifecycle status of the ESG DD assessment from initiation through IC approval or withdrawal.. Valid values are `draft|in_progress|under_review|completed|approved|withdrawn`',
    `assessment_type` STRING COMMENT 'Classification of the assessment trigger: initial pre-investment DD, periodic refresh, post-acquisition monitoring, or incident-triggered reassessment.. Valid values are `initial|refresh|periodic_monitoring|incident_triggered|pre_ic|post_acquisition`',
    `asset_class` STRING COMMENT 'Asset class of the investment subject to ESG DD, determining applicable ESG materiality frameworks and sector-specific risk factors. [ENUM-REF-CANDIDATE: public_equity|private_equity|real_estate|infrastructure|natural_resources|credit|external_fund — 7',
    `board_independence_pct` DECIMAL(5,2) COMMENT 'Percentage of independent directors on the target entitys board of directors, a key governance quality indicator assessed during ESG DD.',
    `carbon_intensity` DECIMAL(18,6) COMMENT 'Carbon intensity of the target entity expressed as tCO2e per unit of revenue, used for portfolio-level carbon footprint reporting per TCFD and SFDR.',
    `climate_transition_risk_rating` STRING COMMENT 'Assessment of the target entitys exposure to policy, technology, and market risks arising from the transition to a low-carbon economy per TCFD framework.. Valid values are `low_risk|medium_risk|high_risk|critical_risk`',
    `controversy_description` STRING COMMENT 'Narrative description of identified ESG controversies, including nature, severity, and current resolution status, populated when controversy_flag is true.',
    `controversy_flag` BOOLEAN COMMENT 'Indicates whether the target entity has active or recent material ESG controversies (e.g., environmental violations, labor disputes, governance scandals) identified during DD.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the ESG DD assessment record was first created in the system, providing the audit trail creation marker.',
    `environmental_risk_rating` STRING COMMENT 'Risk rating for the environmental dimension of the ESG assessment, covering climate, GHG emissions, biodiversity, water, and waste factors.. Valid values are `low_risk|medium_risk|high_risk|critical_risk`',
    `esg_conditions_precedent` STRING COMMENT 'ESG-specific conditions that must be satisfied prior to investment close, such as adoption of an ESG policy, remediation of identified risks, or third-party certification.',
    `esg_engagement_plan` STRING COMMENT 'Description of planned post-investment ESG engagement actions and stewardship activities to address identified ESG risks and improvement opportunities.',
    `esg_policy_in_place` BOOLEAN COMMENT 'Indicates whether the target entity has a formal, documented ESG policy or responsible investment policy in place at the time of assessment.',
    `esg_reporting_standard` STRING COMMENT 'Primary ESG reporting framework adopted by the target entity (e.g., GRI, SASB, TCFD, ISSB/IFRS S1/S2), indicating disclosure quality and comparability. [ENUM-REF-CANDIDATE: GRI|SASB|TCFD|ISSB|CDP|UNPRI|none|multiple — 8 candidates stripped; promote to',
    `esg_score` DECIMAL(5,2) COMMENT 'Quantitative ESG score (0-100 scale) assigned to the target entity based on the assessment, sourced or benchmarked against MSCI ESG or proprietary scoring.',
    `esg_score_provider` STRING COMMENT 'Source or provider of the ESG score used in the assessment, distinguishing between internal proprietary scoring and third-party rating agencies. [ENUM-REF-CANDIDATE: internal|MSCI|Sustainalytics|ISS|Bloomberg|FTSE_Russell|proprietary — 7 candidates',
    `exclusion_list_check` BOOLEAN COMMENT 'Indicates whether the target entity has been screened against the funds responsible investment exclusion list (e.g., weapons, tobacco, coal) per investment policy.',
    `exclusion_list_result` STRING COMMENT 'Outcome of the exclusion list screening: pass (no exclusion triggers), fail (investment prohibited), or conditional pass (subject to conditions or waivers).. Valid values are `pass|fail|conditional_pass|not_applicable`',
    `ghg_emissions_year` BIGINT COMMENT 'The reporting year to which the GHG Scope 1, 2, and 3 emissions figures relate, enabling year-over-year trend analysis.',
    `ghg_scope1_emissions` DECIMAL(18,4) COMMENT 'Target entitys direct Scope 1 GHG emissions in tonnes of CO2 equivalent (tCO2e) as reported or estimated during the ESG DD process.',
    `ghg_scope2_emissions` DECIMAL(18,4) COMMENT 'Target entitys indirect Scope 2 GHG emissions from purchased energy in tCO2e as reported or estimated during the ESG DD process.',
    `ghg_scope3_emissions` DECIMAL(18,4) COMMENT 'Target entitys value chain Scope 3 GHG emissions in tCO2e where available, covering upstream and downstream indirect emissions.',
    `governance_risk_rating` STRING COMMENT 'Risk rating for the governance dimension covering board composition, ownership structure, executive compensation, anti-corruption, and shareholder rights.. Valid values are `low_risk|medium_risk|high_risk|critical_risk`',
    `human_rights_risk_flag` BOOLEAN COMMENT 'Indicates whether material human rights risks were identified during the social dimension of the ESG DD, including supply chain labor and community impacts.',
    `ic_esg_recommendation` STRING COMMENT 'ESG analysts recommendation to the Investment Committee based on the assessment outcome, indicating whether to proceed with the investment from an ESG perspective.. Valid values are `proceed|proceed_with_conditions|further_review_required|do_not_proceed`',
    `initiation_date` DATE COMMENT 'Date on which the ESG DD assessment was formally initiated, marking the start of the ESG review process.',
    `key_esg_risks_summary` STRING COMMENT 'Executive summary of the most material ESG risks identified during the assessment, used in the Investment Memorandum (IM) and IC submission package.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the ESG DD assessment record, supporting audit trail and data lineage requirements.',
    `net_zero_alignment` STRING COMMENT 'Assessment of whether the target entitys strategy and emissions trajectory are aligned with a net-zero by 2050 pathway per Paris Agreement commitments.. Valid values are `aligned|partially_aligned|not_aligned|not_assessed`',
    `overall_esg_rating` STRING COMMENT 'Composite ESG risk rating assigned at the conclusion of the assessment, summarizing environmental, social, and governance dimensions for IC reporting.. Valid values are `low_risk|medium_risk|high_risk|critical_risk`',
    `physical_climate_risk_rating` STRING COMMENT 'Assessment of the target entitys exposure to acute and chronic physical climate risks (e.g., flooding, extreme heat, sea-level rise) per TCFD framework.. Valid values are `low_risk|medium_risk|high_risk|critical_risk`',
    `pri_signatory` BOOLEAN COMMENT 'Indicates whether the target entity or fund manager is a signatory to the UN Principles for Responsible Investment (PRI).',
    `reviewed_date` DATE COMMENT 'Date on which the ESG DD assessment was reviewed and signed off by the designated reviewer prior to IC submission.',
    `sfdr_article_classification` STRING COMMENT 'SFDR product classification of the investment or fund: Article 6 (no sustainability objective), Article 8 (promotes ESG), or Article 9 (sustainable investment objective).. Valid values are `article_6|article_8|article_9|not_applicable`',
    `social_risk_rating` STRING COMMENT 'Risk rating for the social dimension covering labor practices, human rights, supply chain standards, health and safety, and community impact.. Valid values are `low_risk|medium_risk|high_risk|critical_risk`',
    `target_completion_date` DATE COMMENT 'Planned date by which the ESG DD assessment must be completed to meet IC submission timelines.',
    `target_entity_name` STRING COMMENT 'Legal name of the company, fund, asset, or manager subject to this ESG due diligence assessment.',
    `target_geography` STRING COMMENT 'Primary country of operation of the target entity using ISO 3166-1 alpha-3 code, informing jurisdiction-specific ESG regulatory requirements.. Valid values are `^[A-Z]{3}$`',
    `target_sector` STRING COMMENT 'Global Industry Classification Standard (GICS) sector of the target entity, used to apply sector-specific ESG materiality frameworks (e.g., SASB standards).',
    `tcfd_disclosure_assessed` BOOLEAN COMMENT 'Indicates whether the target entitys TCFD-aligned climate disclosure was reviewed and assessed as part of the ESG DD process.',
    `third_party_esg_advisor` STRING COMMENT 'Name of the external ESG advisory firm or specialist engaged to support the ESG DD assessment (e.g., ERM, Sustainalytics, specialist ESG consultants).',
    CONSTRAINT pk_esg_dd_assessment PRIMARY KEY(`esg_dd_assessment_id`)
) COMMENT 'ESG-specific due diligence assessment conducted as part of the investment DD process. Captures ESG materiality screening results, environmental risk factors (GHG emissions, climate transition risk, physical risk), social risk factors (labor practices';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`legal_dd_assessment` (
    `legal_dd_assessment_id` BIGINT COMMENT 'Unique surrogate identifier for the legal due diligence assessment record. Primary key for this entity. TRANSACTION_HEADER role.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the parent due diligence engagement under which this legal DD assessment was commissioned.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity in the deal pipeline that this legal DD assessment relates to.',
    `employee_id` BIGINT COMMENT 'Reference to the internal legal counsel or external legal advisor leading the legal due diligence review.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager or General Partner (GP) being assessed, where the legal DD is conducted on a manager mandate rather than a direct deal.',
    `lead_legal_counsel_employee_id` BIGINT COMMENT 'Reference to the internal legal counsel or external legal advisor leading the legal due diligence review.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager or General Partner (GP) being assessed, where the legal DD is conducted on a manager mandate rather than a direct deal.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity in the deal pipeline that this legal DD assessment relates to.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Legal DD assessments evaluate target compliance with specific regulatory authorities (FCA, SEC, etc.).',
    `actual_completion_date` DATE COMMENT 'Date on which the legal DD assessment was formally completed and the final legal opinion or report was received.',
    `assessment_reference` STRING COMMENT 'Externally-known unique reference code for this legal DD assessment, used in correspondence with legal advisors, Investment Committee (IC) submissions, and data room indexing.. Valid values are `^LDD-[0-9]{4}-[0-9]{6}$`',
    `assessment_status` STRING COMMENT 'Current lifecycle status of the legal DD assessment, tracking progression from initial scoping through completion or withdrawal.. Valid values are `draft|in_progress|under_review|completed|withdrawn`',
    `assessment_type` STRING COMMENT 'Classification of the legal DD assessment by investment type, distinguishing direct deals, co-investments, fund manager mandates, secondaries, real estate, and infrastructure.. Valid values are `direct_investment|co_investment|fund_manager|secondary|real_estate|infrastructure`',
    `conditions_precedent_identified` BOOLEAN COMMENT 'Indicates whether legal conditions precedent to closing have been identified, including regulatory approvals, third-party consents, or restructuring steps required before investment completion.',
    `conditions_precedent_summary` STRING COMMENT 'Summary of identified legal conditions precedent to closing, including required regulatory approvals, consent requirements, and outstanding restructuring steps.',
    `corporate_structure_findings` STRING COMMENT 'Summary of key findings from the corporate structure review, including any structural complexities, offshore entities, or holding company arrangements identified.',
    `corporate_structure_reviewed` BOOLEAN COMMENT 'Indicates whether the corporate structure, ownership hierarchy, and entity formation documents of the target have been reviewed and verified as part of the legal DD.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this legal DD assessment record was first created in the system, used for audit trail and data lineage purposes.',
    `data_privacy_findings` STRING COMMENT 'Summary of data privacy and cybersecurity legal findings, including identified GDPR non-compliance, data breach history, or inadequate data processing agreements.',
    `data_privacy_review_status` STRING COMMENT 'Status of the data privacy and cybersecurity legal review, assessing the targets compliance with applicable data protection regulations such as GDPR.. Valid values are `not_started|in_progress|completed|not_applicable`',
    `data_room_reference` STRING COMMENT 'Reference identifier or URL for the virtual data room folder containing legal DD source documents, including constitutional documents, contracts, and regulatory filings.',
    `employment_findings` STRING COMMENT 'Summary of employment and labour law findings, including identified unfunded pension liabilities, change-of-control clauses in executive contracts, or material employment disputes.',
    `employment_review_status` STRING COMMENT 'Status of the employment and labour law review covering key management contracts, collective bargaining agreements, pension obligations, and employment liability exposure.. Valid values are `not_started|in_progress|completed|not_applicable`',
    `external_legal_advisor` STRING COMMENT 'Name of the external law firm engaged to conduct or support the legal due diligence review on behalf of the pension fund.',
    `governing_law` STRING COMMENT 'The legal jurisdiction and governing law applicable to the primary transaction documents (e.g., Share Purchase Agreement (SPA), Limited Partnership Agreement (LPA)), such as New York Law or English Law.',
    `ic_submission_date` DATE COMMENT 'Date on which the legal DD assessment findings were submitted to the Investment Committee (IC) as part of the investment approval package.',
    `initiation_date` DATE COMMENT 'Date on which the legal due diligence assessment was formally initiated and scope was agreed with legal counsel.',
    `ip_findings` STRING COMMENT 'Summary of findings from the IP review, including unregistered IP risks, licensing gaps, third-party IP claims, or freedom-to-operate concerns identified.',
    `ip_review_status` STRING COMMENT 'Status of the intellectual property review covering ownership, registration, licensing, and freedom-to-operate of material IP assets held by the target.. Valid values are `not_started|in_progress|completed|not_applicable`',
    `legal_advisor_report_reference` STRING COMMENT 'Document reference or data room identifier for the external legal advisors formal legal DD report or legal opinion letter.',
    `legal_risk_flags` STRING COMMENT 'Free-text summary of the most material legal risk flags identified across all workstreams, intended for Investment Committee (IC) briefing and investment memorandum (IM) inclusion.',
    `legal_sign_off_date` DATE COMMENT 'Date on which the lead legal counsel formally signed off the legal DD assessment as complete and satisfactory for investment committee purposes.',
    `litigation_findings` STRING COMMENT 'Summary of identified litigation, arbitration proceedings, regulatory investigations, or material threatened claims, including estimated financial exposure where disclosed.',
    `litigation_review_status` STRING COMMENT 'Status of the litigation and dispute review, covering pending, threatened, and historical legal proceedings against the target entity.. Valid values are `not_started|in_progress|completed|not_applicable`',
    `lpa_key_terms_summary` STRING COMMENT 'Summary of material LPA terms reviewed, including hurdle rate, carried interest, clawback provisions, key-man clauses, no-fault divorce rights, and LP transfer restrictions.',
    `lpa_reviewed` BOOLEAN COMMENT 'Indicates whether the Limited Partnership Agreement (LPA) has been reviewed for key terms including GP removal rights, LPAC governance, fee and carry provisions, and transfer restrictions.',
    `material_contracts_findings` STRING COMMENT 'Summary of findings from the material contracts review, including identified change-of-control triggers, consent requirements, termination rights, and unusual commercial terms.',
    `material_contracts_reviewed` BOOLEAN COMMENT 'Indicates whether key commercial agreements (e.g., customer contracts, supplier agreements, joint ventures, licences) have been reviewed for change-of-control provisions and assignment restrictions.',
    `material_litigation_identified` BOOLEAN COMMENT 'Indicates whether material litigation, arbitration, regulatory investigations, or threatened claims have been identified that could adversely affect the investment.',
    `nda_executed` BOOLEAN COMMENT 'Indicates whether a Non-Disclosure Agreement (NDA) has been executed with the target entity or its advisors prior to commencement of the legal DD review.',
    `overall_legal_rating` STRING COMMENT 'Composite legal risk rating assigned by the lead legal counsel upon completion of the legal DD, summarising the aggregate legal risk profile of the target entity or transaction.. Valid values are `low_risk|medium_risk|high_risk|critical_risk`',
    `regulatory_compliance_findings` STRING COMMENT 'Summary of findings from the regulatory compliance review, including identified licence gaps, regulatory breaches, pending enforcement actions, or AML/KYC deficiencies.',
    `regulatory_compliance_reviewed` BOOLEAN COMMENT 'Indicates whether the target entitys regulatory licences, permits, and compliance with applicable laws (including AML, KYC, and sector-specific regulations) have been reviewed.',
    `remediation_notes` STRING COMMENT 'Detailed notes on required legal remediation actions, responsible parties, and target resolution dates for identified legal issues prior to investment closing.',
    `remediation_required` BOOLEAN COMMENT 'Indicates whether legal remediation actions are required prior to or as a condition of investment closing, such as restructuring, consent procurement, or warranty and indemnity insurance.',
    `spa_key_terms_summary` STRING COMMENT 'Summary of material SPA terms including representations and warranties, indemnification caps, baskets, escrow arrangements, and conditions precedent to closing.',
    `spa_reviewed` BOOLEAN COMMENT 'Indicates whether the Share Purchase Agreement (SPA) or equivalent acquisition agreement has been reviewed for representations, warranties, indemnities, and conditions precedent.',
    `target_completion_date` DATE COMMENT 'Planned date by which the legal DD assessment is expected to be completed and the legal DD report delivered to the Investment Committee (IC).',
    `target_entity_name` STRING COMMENT 'Legal name of the target company, fund, or manager entity subject to the legal due diligence review.',
    `target_jurisdiction` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the primary legal jurisdiction in which the target entity is incorporated or domiciled.. Valid values are `^[A-Z]{3}$`',
    `title_ownership_findings` STRING COMMENT 'Summary of findings from the title and ownership verification, including any identified encumbrances, liens, pledges, or unresolved ownership disputes.',
    `title_ownership_verified` BOOLEAN COMMENT 'Indicates whether title to the target assets and ownership interests have been verified as free and clear of undisclosed encumbrances, liens, or competing claims.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this legal DD assessment record was last modified, supporting audit trail, change tracking, and incremental data pipeline processing.',
    CONSTRAINT pk_legal_dd_assessment PRIMARY KEY(`legal_dd_assessment_id`)
) COMMENT 'Legal due diligence assessment record capturing the legal review of a target investment or fund manager. Tracks corporate structure review, title and ownership verification, material contract review (LPA terms, SPA, key commercial agreements), litigation';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`diligence_ic_submission` (
    `diligence_ic_submission_id` BIGINT COMMENT 'Unique surrogate identifier for the Investment Committee (IC) submission package record within the diligence domain.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the parent due diligence engagement that underpins this IC submission, linking all DD workstreams and findings to the submission package.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the originating deal or investment opportunity in the deal pipeline, sourced from Dealpath/DealCloud CRM.',
    `diligence_employee_id` BIGINT COMMENT 'Reference to the senior investment professional sponsoring and presenting this submission to the Investment Committee, accountable for the recommendation.',
    `diligence_lead_analyst_employee_id` BIGINT COMMENT 'Reference to the lead analyst who conducted the due diligence and authored the Investment Memorandum (IM) supporting this IC submission.',
    `economic_scenario_id` BIGINT COMMENT 'Foreign key linking to research.economic_scenario. Business justification: IC submissions must document the macroeconomic scenario under which target IRR/MOIC were modeled.',
    `employee_id` BIGINT COMMENT 'Reference to the senior investment professional sponsoring and presenting this submission to the Investment Committee, accountable for the recommendation.',
    `fee_benchmark_id` BIGINT COMMENT 'Foreign key linking to fee.fee_benchmark. Business justification: IC submissions must demonstrate fee competitiveness vs market benchmarks. Investment Committee requires fee benchmark comparison in approval memos to validate proposed terms align with',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager being evaluated, applicable when the IC submission relates to a new or re-up external manager mandate rather than a direct investment.',
    `lead_analyst_employee_id` BIGINT COMMENT 'Reference to the lead analyst who conducted the due diligence and authored the Investment Memorandum (IM) supporting this IC submission.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager being evaluated, applicable when the IC submission relates to a new or re-up external manager mandate rather than a direct investment.',
    `opportunity_id` BIGINT COMMENT 'Reference to the originating deal or investment opportunity in the deal pipeline, sourced from Dealpath/DealCloud CRM.',
    `prior_submission_diligence_ic_submission_id` BIGINT COMMENT 'Self-referencing identifier linking to the previous IC submission for the same deal or manager, enabling tracking of resubmissions and IC round history.',
    `approved_commitment_amount` DECIMAL(20,4) COMMENT 'The capital commitment amount formally approved by the Investment Committee, which may differ from the recommended amount if the IC imposed a cap or condition.',
    `asset_class` STRING COMMENT 'The primary asset class of the investment opportunity being submitted for IC approval, aligned with the funds Strategic Asset Allocation (SAA) framework. [ENUM-REF-CANDIDATE',
    `co_investment_flag` BOOLEAN COMMENT 'Indicates whether this IC submission relates to a co-investment opportunity alongside a GP, as distinct from a primary fund commitment or direct investment.',
    `commitment_amount_base_equivalent` DECIMAL(20,4) COMMENT 'Recommended commitment amount converted to national Dollars (Base Currency) at the submission date FX rate, used for consolidated portfolio exposure and SAA compliance reporting.',
    `commitment_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the recommended commitment amount (e.g., USD, EUR, GBP), used for FX hedging and multi-currency portfolio reporting.. Valid values are `^[A-Z]{3}$`',
    `conditions_precedent` STRING COMMENT 'Narrative description of conditions that must be satisfied prior to closing the investment, as stipulated by the IC in its approval decision or identified by the legal DD workstream.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this IC submission record was first created in the system, used for audit trail and data lineage purposes.',
    `data_room_location` STRING COMMENT 'URL or path reference to the virtual data room (VDR) containing the supporting due diligence materials, IM, and third-party advisor reports for this IC submission.',
    `dd_completion_status` STRING COMMENT 'Overall completion status of the due diligence process at the time of IC submission, indicating whether all DD workstreams (ODD, FDD, CDD, Legal, ESG) are fully or substantially complete.. Valid values are `complete|substantially_complete|partial|waived`',
    `esg_materiality_flag` BOOLEAN COMMENT 'Indicates whether material ESG risks or opportunities were identified during the ESG DD workstream that require specific IC attention, conditions, or post-investment monitoring.',
    `esg_rating` STRING COMMENT 'ESG risk rating assigned during the ESG due diligence workstream, reflecting material environmental, social, and governance risks identified for the investment target.. Valid values are `low_risk|medium_risk|high_risk|critical_risk`',
    `hurdle_rate_pct` DECIMAL(8,4) COMMENT 'The minimum preferred return threshold (hurdle rate) applicable to this investment, above which carried interest accrues to the GP. Expressed as an annual percentage per the LPA.',
    `ic_decision` STRING COMMENT 'The formal decision rendered by the Investment Committee on this submission: approved, rejected, deferred for further information, or approved subject to conditions precedent.. Valid values are `approved|rejected|deferred|approved_with_conditions`',
    `ic_decision_date` DATE COMMENT 'The date on which the Investment Committee formally rendered its decision (approval, rejection, or deferral) on this submission.',
    `ic_meeting_date` DATE COMMENT 'The scheduled or actual date of the Investment Committee meeting at which this submission is presented for deliberation and decision.',
    `ic_round` BIGINT COMMENT 'Sequential round number of this IC submission for the same deal or manager (e.g., 1 for initial submission, 2 for resubmission after deferral), tracking iterative IC review cycles.',
    `im_reference` STRING COMMENT 'Document reference or identifier for the Investment Memorandum (IM) submitted to the IC, linking to the formal research and analysis document in the data room or document management system.',
    `im_version` STRING COMMENT 'Version number of the Investment Memorandum submitted with this IC package (e.g., v1.0, v2.3), tracking document revisions through the IC review process.. Valid values are `^v[0-9]+.[0-9]+$`',
    `investment_horizon_years` BIGINT COMMENT 'Expected holding period or fund life in years for the investment, used for liability-driven investment (LDI) matching and long-duration portfolio planning.',
    `investment_strategy` STRING COMMENT 'Specific investment strategy or sub-strategy of the proposed investment (e.g., buyout, growth equity, core real estate, value-add infrastructure, direct lending, distressed credit).',
    `investment_type` STRING COMMENT 'Classification of the investment structure being proposed: direct investment, co-investment alongside a GP, fund commitment (LP interest), secondary market transaction, or separately managed account (SMA).. Valid values are `direct|co_investment|fund_commitment|secondary|sma`',
    `key_risks_summary` STRING COMMENT 'Narrative summary of the principal investment risks identified during due diligence, as presented to the IC. Includes financial, operational, legal, ESG, and macroeconomic risk factors.',
    `kyc_aml_cleared` BOOLEAN COMMENT 'Indicates whether the KYC and AML screening of the target entity and its beneficial owners has been completed and cleared prior to IC submission.',
    `loi_executed` BOOLEAN COMMENT 'Indicates whether a Letter of Intent (LOI) or term sheet has been executed with the target entity prior to IC submission, signaling advanced deal progression.',
    `nda_executed` BOOLEAN COMMENT 'Indicates whether a Non-Disclosure Agreement (NDA) has been executed with the target entity or GP prior to receiving confidential deal information and commencing due diligence.',
    `overall_dd_rating` STRING COMMENT 'Composite risk rating assigned by the DD team across all workstreams (ODD, FDD, CDD, Legal, ESG), summarizing the overall risk profile of the investment for IC deliberation.. Valid values are `low_risk|medium_risk|high_risk|critical_risk`',
    `portfolio_weight_pct` DECIMAL(8,4) COMMENT 'Proposed weight of this investment as a percentage of total fund AUM at the time of IC submission, used for concentration risk assessment and SAA compliance.',
    `recommendation` STRING COMMENT 'Formal recommendation of the investment team as presented in the IC submission: invest, do not invest, proceed with further diligence, or invest subject to conditions.. Valid values are `invest|do_not_invest|further_diligence|conditional_invest`',
    `recommended_commitment_amount` DECIMAL(20,4) COMMENT 'The gross capital commitment amount recommended by the investment team for IC approval, expressed in the commitment currency. Represents the proposed Paid-In Capital (PIC) obligation.',
    `regulatory_concern_flag` BOOLEAN COMMENT 'Indicates whether the legal or compliance DD workstream identified material regulatory concerns (e.g., EMIR, MiFID II, SFDR) requiring IC awareness or conditions precedent.',
    `saa_asset_class_bucket` STRING COMMENT 'The SAA portfolio bucket to which this investment is allocated (e.g., Global Equities, Private Equity, Real Assets, Credit), used for SAA compliance monitoring and rebalancing.',
    `submission_date` DATE COMMENT 'The date on which the completed IC submission package was formally submitted to the Investment Committee secretariat for scheduling and review.',
    `submission_reference` STRING COMMENT 'Externally-known alphanumeric reference code uniquely identifying this IC submission package, used in board governance systems and audit trails (e.g., IC-2024-00123).. Valid values are `^IC-[0-9]{4}-[0-9]{5}$`',
    `submission_status` STRING COMMENT 'Current lifecycle state of the IC submission package. [ENUM-REF-CANDIDATE: draft|submitted|under_review|approved|rejected|deferred|withdrawn — promote to reference product]',
    `target_entity_name` STRING COMMENT 'Legal name of the investment target entity, fund, or manager being evaluated in this IC submission. Classified confidential due to deal sensitivity and NDA obligations.',
    `target_geography` STRING COMMENT 'Primary country or region of the investment target, expressed as an ISO 3166-1 alpha-3 country code, used for geographic exposure and regulatory reporting.. Valid values are `^[A-Z]{3}$`',
    `target_irr_pct` DECIMAL(8,4) COMMENT 'Projected gross Internal Rate of Return (IRR) for the investment as modeled in the IC submission, expressed as a percentage. Key return metric for private markets investments.',
    `target_moic` DECIMAL(8,4) COMMENT 'Projected gross Multiple on Invested Capital (MOIC) for the investment as modeled in the IC submission. Complements IRR as a return metric for private markets and illiquid assets.',
    `third_party_advisor` STRING COMMENT 'Name of the primary external advisor (legal, financial, technical, or ESG) engaged to support the due diligence process for this IC submission.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this IC submission record, supporting audit trail and change tracking requirements.',
    `vintage_year` BIGINT COMMENT 'The year in which the capital commitment is made or the funds first capital call occurs, used for vintage year benchmarking and J-curve analysis of private markets investments.',
    CONSTRAINT pk_diligence_ic_submission PRIMARY KEY(`diligence_ic_submission_id`)
) COMMENT 'Investment Committee (IC) submission package record representing the formal presentation of a DD-completed investment opportunity to the IC for approval. Captures submission date, IC meeting date, investment type, recommended commitment amount, deal';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`diligence_ic_condition` (
    `diligence_ic_condition_id` BIGINT COMMENT 'Unique surrogate identifier for an individual condition or requirement attached to an Investment Committee (IC) approval decision within the due diligence process.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the parent due diligence engagement under which the IC approval decision and this condition were generated.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity in the deal pipeline (Dealpath/DealCloud) to which this IC condition applies.',
    `employee_id` BIGINT COMMENT 'Reference to the internal analyst or investment professional assigned as the primary owner accountable for tracking and driving resolution of this IC condition.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager subject to this IC condition, applicable when the condition relates to an external manager mandate rather than a direct investment.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager subject to this IC condition, applicable when the condition relates to an external manager mandate rather than a direct investment.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity in the deal pipeline (Dealpath/DealCloud) to which this IC condition applies.',
    `owner_analyst_employee_id` BIGINT COMMENT 'Reference to the internal analyst or investment professional assigned as the primary owner accountable for tracking and driving resolution of this IC condition.',
    `risk_assessment_id` BIGINT COMMENT 'Reference to the DD risk assessment record that informed the IC decision and gave rise to this condition.',
    `actual_resolution_date` DATE COMMENT 'Date on which the IC condition was actually satisfied, waived, or formally closed, enabling resolution cycle time analysis and governance reporting.',
    `advisor_report_reference` STRING COMMENT 'Reference identifier for the third-party advisor report or legal opinion that supports or evidences the resolution of this IC condition.',
    `asset_class` STRING COMMENT 'Asset class of the investment to which this IC condition applies, enabling portfolio-level condition tracking across public equities, private equity, real estate, infrastructure, natural resources, and credit.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `condition_category` STRING COMMENT 'Sub-category providing further granularity within the condition type (e.g., KYC/AML clearance, ISDA/CSA execution, TCFD disclosure, LPA negotiation, capital call mechanics).',
    `condition_description` STRING COMMENT 'Full narrative description of the condition or requirement as stated in the IC approval decision, including specific actions, deliverables, or thresholds that must be met.',
    `condition_rationale` STRING COMMENT 'Business rationale or risk basis for imposing this condition, as documented in the IC minutes or Investment Memorandum (IM), supporting audit and governance review.',
    `condition_reference` STRING COMMENT 'Externally-known alphanumeric reference code uniquely identifying this IC condition, used in IC minutes, governance records, and Diligent/BoardEffect board documentation.. Valid values are `^IC-COND-[0-9]{4}-[0-9]{5}$`',
    `condition_sequence` BIGINT COMMENT 'Ordinal sequence number of this condition within the set of conditions attached to the same IC decision, used for ordering in IC minutes and governance reports.',
    `condition_status` STRING COMMENT 'Current lifecycle status of the IC condition: open (not yet actioned), in_progress (being resolved), satisfied (fully met), waived (formally waived by IC), escalated, or overdue.. Valid values are `open|in_progress|satisfied|waived|escalated|overdue`',
    `condition_type` STRING COMMENT 'Classification of the IC condition by functional domain: legal (SPA, LPA, NDA), financial (FDD, valuation, EBITDA), ESG, operational (ODD), or regulatory (FCA, EMIR).. Valid values are `legal|financial|esg|operational|regulatory`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this IC condition record was first created in the system, providing the audit trail start point for governance and regulatory review.',
    `data_room_reference` STRING COMMENT 'Reference path or document identifier within the virtual data room (VDR) where supporting evidence or documentation for this IC condition is stored.',
    `dd_type` STRING COMMENT 'Type of due diligence workstream that identified or generated this IC condition: ODD (Operational), FDD (Financial), CDD (Commercial), Legal DD, or ESG DD.. Valid values are `ODD|FDD|CDD|legal_dd|esg_dd`',
    `escalation_date` DATE COMMENT 'Date on which this IC condition was escalated due to non-resolution by the target date, triggering senior management or IC review.',
    `escalation_reason` STRING COMMENT 'Narrative explanation of why this IC condition was escalated, including blocking factors, counterparty delays, or regulatory complications encountered.',
    `esg_dimension` STRING COMMENT 'ESG dimension relevant to this condition when condition_type is ESG: environmental (GHG, TCFD), social (labour, human rights), governance (board structure), or none if not ESG-related.. Valid values are `environmental|social|governance|none`',
    `extended_resolution_date` DATE COMMENT 'Revised target resolution date if the original deadline was formally extended, capturing the approved extension for audit and governance tracking purposes.',
    `ic_decision_date` DATE COMMENT 'Date on which the IC formally approved the investment subject to this condition, as recorded in the IC minutes and Diligent/BoardEffect governance platform.',
    `ic_decision_reference` STRING COMMENT 'Reference number or identifier of the IC approval decision to which this condition is attached, linking back to the formal IC minutes or resolution document.',
    `investment_type` STRING COMMENT 'Nature of the investment structure to which this condition applies: direct investment, co-investment (Co-Invest), fund commitment (LP), separately managed account (SMA), or secondary transaction.. Valid values are `direct|co_invest|fund_commitment|sma|secondary`',
    `is_conditions_precedent` BOOLEAN COMMENT 'Indicates whether this condition is a formal condition precedent (CP) that must be satisfied before capital can be committed or the transaction can close.',
    `is_ic_blocking` BOOLEAN COMMENT 'Indicates whether this condition blocks final IC approval or investment execution until resolved. Blocking conditions prevent capital deployment until satisfied.',
    `last_reviewed_by` STRING COMMENT 'Name or identifier of the analyst, compliance officer, or IC member who conducted the most recent formal review of this conditions status.',
    `last_reviewed_date` DATE COMMENT 'Date on which this IC condition was most recently formally reviewed and its status updated by the responsible analyst or governance team.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this IC condition record, supporting audit trail, data lineage, and change management requirements.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal status review of this IC condition, used to drive workflow reminders and governance reporting cadence.',
    `priority` STRING COMMENT 'Priority level assigned to this IC condition, indicating urgency of resolution relative to deal timeline and capital commitment schedule.. Valid values are `critical|high|medium|low`',
    `regulatory_reference` STRING COMMENT 'Specific regulatory rule, article, or requirement (e.g., underwriting practices guidance, EMIR Article 11, MiFID II, SFDR Article 8) that this IC condition is designed to address or satisfy.',
    `resolution_evidence` STRING COMMENT 'Description or reference to documentary evidence (e.g., signed SPA, legal opinion, KYC clearance certificate, ESG policy submission) confirming the condition has been satisfied.',
    `resolution_notes` STRING COMMENT 'Free-text notes documenting progress updates, outstanding actions, counterparty communications, or partial resolutions related to satisfying this IC condition.',
    `responsible_party_name` STRING COMMENT 'Name of the individual, team, or external counterparty (e.g., legal counsel, GP, third-party advisor) responsible for resolving or satisfying this IC condition.',
    `responsible_party_type` STRING COMMENT 'Classification of the party responsible for resolving the condition: internal analyst, legal counsel, external advisor, GP/manager, compliance, or finance team.',
    `review_frequency` STRING COMMENT 'Frequency at which the status of this IC condition is formally reviewed and reported to the IC or investment team until resolution.. Valid values are `weekly|bi_weekly|monthly|quarterly|ad_hoc`',
    `target_resolution_date` DATE COMMENT 'Target date by which the responsible party must satisfy or resolve this IC condition, as agreed at the time of IC approval.',
    `third_party_advisor` STRING COMMENT 'Name of the external advisor (legal firm, accounting firm, ESG consultant, technical advisor) engaged to support resolution of this IC condition.',
    `waiver_approved` BOOLEAN COMMENT 'Indicates whether a formal waiver has been approved by the IC or delegated authority, allowing the investment to proceed without full satisfaction of this condition.',
    `waiver_approved_by` STRING COMMENT 'Name or identifier of the IC member, committee, or delegated authority who formally approved the waiver of this condition.',
    `waiver_date` DATE COMMENT 'Date on which the formal waiver of this IC condition was approved and recorded in the governance system.',
    `waiver_rationale` STRING COMMENT 'Documented justification for granting a waiver on this IC condition, including risk acceptance rationale and mitigating factors considered by the IC.',
    CONSTRAINT pk_diligence_ic_condition PRIMARY KEY(`diligence_ic_condition_id`)
) COMMENT 'Individual condition or requirement attached to an IC approval decision. Captures condition type (legal, financial, ESG, operational, regulatory), condition description, responsible party for resolution, target resolution date, actual resolution date, and';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`nda_record` (
    `nda_record_id` BIGINT COMMENT 'Unique surrogate identifier for the NDA record within the diligence domain. Primary key for this entity.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the due diligence engagement for which this NDA was executed, linking the NDA to the broader DD process in eFront or DealCloud.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity in the deal origination pipeline (Dealpath/DealCloud) for which this NDA was executed.',
    `employee_id` BIGINT COMMENT 'Reference to the internal investment analyst or deal team member who initiated or is responsible for managing this NDA as part of the deal origination or DD process.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager or General Partner (GP) with whom this NDA was executed, if applicable to a manager evaluation context.',
    `lead_analyst_employee_id` BIGINT COMMENT 'Reference to the internal investment analyst or deal team member who initiated or is responsible for managing this NDA as part of the deal origination or DD process.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager or General Partner (GP) with whom this NDA was executed, if applicable to a manager evaluation context.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity in the deal origination pipeline (Dealpath/DealCloud) for which this NDA was executed.',
    `asset_class` STRING COMMENT 'Asset class of the investment opportunity or manager evaluation for which this NDA was executed, aligning with the funds strategic asset allocation (SAA) framework.',
    `confidentiality_scope` STRING COMMENT 'Narrative description of the scope of confidential information covered by the NDA, including categories of information (financial, operational, strategic) and any explicit exclusions.',
    `counterparty_domicile` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the jurisdiction of incorporation or domicile of the counterparty, used for governing law and regulatory screening.. Valid values are `^[A-Z]{3}$`',
    `counterparty_lei` STRING COMMENT '20-character ISO 17442 Legal Entity Identifier (LEI) of the counterparty, used for regulatory identification and KYC/AML compliance screening.. Valid values are `^[A-Z0-9]{18}[0-9]{2}$`',
    `counterparty_name` STRING COMMENT 'Full legal name of the counterparty (target company, fund manager, intermediary, or advisor) with whom the NDA is executed, as registered in the relevant jurisdiction.',
    `counterparty_signatory_name` STRING COMMENT 'Full name of the authorized signatory representing the counterparty who executed the NDA. Captured for legal enforceability and counterparty due diligence records.',
    `counterparty_signatory_title` STRING COMMENT 'Job title or role of the authorized signatory from the counterparty organization who executed the NDA (e.g., CEO, General Counsel, Managing Partner).',
    `counterparty_type` STRING COMMENT 'Classification of the counterparty entity type for the NDA, distinguishing between target companies, fund managers (GPs), intermediaries, advisors, co-investors, and lenders. [ENUM-REF-CANDIDATE: promote to reference product]',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this NDA record was first created in the system, providing an audit trail for record creation in compliance with data governance and regulatory requirements.',
    `data_room_access_granted` BOOLEAN COMMENT 'Indicates whether execution of this NDA has resulted in the fund being granted access to the counterpartys virtual data room (VDR) for due diligence purposes.',
    `data_room_platform` STRING COMMENT 'Name of the virtual data room (VDR) platform to which access was granted following NDA execution (e.g., Intralinks, Datasite, Ansarada). Used for DD workflow coordination.. Valid values are `intralinks|datasite|ansarada|box|sharepoint|other`',
    `document_reference` STRING COMMENT 'Reference identifier or URL for the executed NDA document stored in the funds document management system or virtual data room, enabling retrieval of the signed agreement.',
    `document_version` STRING COMMENT 'Version identifier of the executed NDA document, tracking amendments or restated versions of the agreement over the course of the deal lifecycle.',
    `exclusivity_expiry_date` DATE COMMENT 'Date on which any exclusivity provision within the NDA expires. Null if no exclusivity clause is included. Critical for deal timeline management in the origination pipeline.',
    `exclusivity_included` BOOLEAN COMMENT 'Indicates whether the NDA includes an exclusivity clause granting the fund exclusive negotiation rights for a defined period, preventing the counterparty from engaging other buyers.',
    `execution_date` DATE COMMENT 'The date on which the NDA was fully executed (signed by all parties), marking the commencement of confidentiality obligations under the agreement.',
    `expiry_date` DATE COMMENT 'The date on which the NDAs confidentiality obligations expire. Null if the NDA is perpetual or open-ended. Used for compliance monitoring and renewal tracking.',
    `external_counsel_firm` STRING COMMENT 'Name of the external law firm engaged to review or negotiate the NDA on behalf of the pension fund, if applicable. Supports advisor fee tracking and legal engagement management.',
    `fund_signatory_name` STRING COMMENT 'Full name of the authorized signatory representing the pension fund who executed the NDA on behalf of the fund. Used for legal record and governance audit trail.',
    `fund_signatory_title` STRING COMMENT 'Job title or role of the authorized signatory from the pension fund who executed the NDA (e.g., Managing Director, General Counsel, Chief Investment Officer).',
    `governing_law_detail` STRING COMMENT 'Specific governing law clause detail, including state or province where applicable (e.g., Delaware, England and Wales, New York, USA) for precise legal enforceability.',
    `governing_law_jurisdiction` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction whose laws govern the NDA. Critical for legal enforceability assessment and cross-border transaction management.. Valid values are `^[A-Z]{3}$`',
    `investment_type` STRING COMMENT 'Type of investment transaction associated with this NDA, distinguishing direct investments, co-investments (Co-Invest), fund investments (LP), secondaries, and separately managed accounts (SMAs).. Valid values are `direct|co_invest|fund_investment|secondary|sma|other`',
    `kyc_aml_cleared` BOOLEAN COMMENT 'Indicates whether the counterparty has passed KYC/AML screening at the time of NDA execution. Supports compliance gating for deal progression.',
    `kyc_aml_screening_required` BOOLEAN COMMENT 'Indicates whether KYC/AML screening of the counterparty is required as a condition of or concurrent with NDA execution, per the funds compliance policy.',
    `kyc_cleared_date` DATE COMMENT 'Date on which the counterpartys KYC/AML screening was completed and cleared, enabling deal progression. Null if screening is pending or not yet required.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this NDA record, supporting audit trail, data lineage, and change management requirements in the Silver layer lakehouse.',
    `legal_counsel_internal` STRING COMMENT 'Name of the internal legal counsel or legal team responsible for reviewing and approving the NDA on behalf of the pension fund.',
    `nda_reference` STRING COMMENT 'Externally-known unique reference number or code assigned to this NDA, used for tracking in legal document management systems and correspondence.',
    `nda_status` STRING COMMENT 'Current lifecycle status of the NDA record, tracking progression from draft through execution to expiry or termination. [ENUM-REF-CANDIDATE: draft|pending_signature|executed|expired|terminated|superseded — promote to reference product]. Valid values are `draft|pending_signature|executed|expired|terminated|superseded`',
    `nda_type` STRING COMMENT 'Classification of the NDA by directionality of confidentiality obligations: mutual (bilateral), one-way inbound (counterparty discloses to fund), one-way outbound, or multilateral.. Valid values are `mutual|one_way_inbound|one_way_outbound|multilateral`',
    `non_solicit_included` BOOLEAN COMMENT 'Indicates whether the NDA includes a non-solicitation clause restricting either party from soliciting the others employees or clients during and after the evaluation period.',
    `notes` STRING COMMENT 'Free-text field for additional notes, negotiation commentary, or special conditions associated with this NDA that are not captured in structured fields.',
    `origination_channel` STRING COMMENT 'Channel through which the deal or manager relationship was originated, indicating whether the NDA arose from proprietary sourcing, an intermediary, a secondary market process, or an RFP.. Valid values are `proprietary|intermediated|secondary_market|rfp|referral|other`',
    `permitted_use_description` STRING COMMENT 'Description of the permitted purposes for which confidential information may be used under the NDA, typically limited to evaluation of the specific investment opportunity.',
    `renewal_date` DATE COMMENT 'Date on which the NDA was renewed or extended. Null if the NDA has not been renewed. Supports compliance monitoring and legal document lifecycle management.',
    `renewal_required` BOOLEAN COMMENT 'Indicates whether this NDA requires renewal prior to expiry to maintain confidentiality coverage for an ongoing due diligence or investment monitoring process.',
    `sanctions_screened` BOOLEAN COMMENT 'Indicates whether the counterparty has been screened against applicable sanctions lists (OFAC, UN, EU) prior to or concurrent with NDA execution.',
    `standstill_expiry_date` DATE COMMENT 'Date on which the standstill provision within the NDA expires, after which the fund may freely acquire securities of the counterparty. Null if no standstill provision exists.',
    `standstill_included` BOOLEAN COMMENT 'Indicates whether the NDA includes a standstill provision restricting the fund from acquiring securities of the counterparty for a defined period. Relevant for public equity transactions.',
    `superseded_by_agreement` STRING COMMENT 'Reference to the definitive agreement (e.g., Share Purchase Agreement (SPA), Limited Partnership Agreement (LPA), or ISDA Master Agreement) that supersedes this NDA upon deal execution.',
    `term_months` BIGINT COMMENT 'Duration of the NDAs confidentiality obligations expressed in months from execution date. Null for perpetual NDAs. Supports automated expiry monitoring and renewal workflows.',
    `termination_date` DATE COMMENT 'Date on which the NDA was terminated prior to its natural expiry, if applicable. Null for active or naturally expired NDAs. Captures early termination events.',
    `termination_reason` STRING COMMENT 'Reason for early termination of the NDA, such as deal abandonment, deal closure, mutual agreement, breach, or supersession by a definitive agreement (e.g., SPA or LPA).. Valid values are `deal_abandoned|deal_closed|mutual_agreement|breach|superseded|other`',
    CONSTRAINT pk_nda_record PRIMARY KEY(`nda_record_id`)
) COMMENT 'Non-Disclosure Agreement (NDA) record executed with a target company, fund manager, or intermediary as part of the deal origination and DD process. Captures counterparty name, LEI, NDA type (mutual, one-way), execution date, expiry date, governing law';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`data_room_access` (
    `data_room_access_id` BIGINT COMMENT 'Unique surrogate identifier for a virtual data room (VDR) access record within a due diligence engagement.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the parent due diligence engagement for which this VDR access was provisioned.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity in the deal pipeline associated with this data room access.',
    `employee_id` BIGINT COMMENT 'Reference to the lead investment analyst responsible for the DD engagement, who is the primary user of the VDR access.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager under evaluation, applicable when the DD engagement relates to manager selection or ODD.',
    `lead_analyst_employee_id` BIGINT COMMENT 'Reference to the lead investment analyst responsible for the DD engagement, who is the primary user of the VDR access.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager under evaluation, applicable when the DD engagement relates to manager selection or ODD.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity in the deal pipeline associated with this data room access.',
    `access_expiry_date` DATE COMMENT 'Date on which the VDR access is scheduled to expire. After this date, the investment team can no longer access documents unless access is extended.',
    `access_extension_count` BIGINT COMMENT 'Number of times the VDR access expiry date has been extended. Repeated extensions may indicate deal complexity or delays in the DD process.',
    `access_grant_date` DATE COMMENT 'Date on which access to the virtual data room was formally granted to the investment team. Marks the start of the document review period.',
    `access_notes` STRING COMMENT 'Free-text notes recorded by the DD team regarding the VDR access, such as access limitations, counterparty restrictions, or document quality observations.',
    `access_reference` STRING COMMENT 'Unique business reference code assigned to this VDR access grant, used for tracking and audit purposes across the DD lifecycle.',
    `access_revocation_date` DATE COMMENT 'Date on which VDR access was revoked prior to the scheduled expiry, typically upon deal termination, NDA breach, or completion of the DD process.',
    `access_status` STRING COMMENT 'Current lifecycle status of the VDR access grant. Active indicates current access; expired indicates the access period has lapsed; revoked indicates early termination.. Valid values are `active|expired|revoked|pending|suspended`',
    `access_type` STRING COMMENT 'Level of access permissions granted within the VDR, controlling whether users can view only, download documents, or have full access including printing.. Valid values are `read_only|download|full_access|restricted_view`',
    `access_user_count` BIGINT COMMENT 'Number of internal investment team members provisioned with access to this VDR. Used for access governance and information security monitoring.',
    `advisor_access_granted` BOOLEAN COMMENT 'Indicates whether the third-party advisor has been granted access to the VDR in addition to the internal investment team.',
    `asset_class` STRING COMMENT 'Asset class of the investment under due diligence (e.g., Private Equity, Real Estate, Infrastructure, Natural Resources, Credit). [ENUM-REF-CANDIDATE: private_equity|real_estate|infrastructure|natural_resources|credit|public_equities|co_investment —',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this VDR access record was first created in the data platform. Supports audit trail and data lineage requirements.',
    `dd_type` STRING COMMENT 'Type of due diligence workstream this VDR access supports: Operational DD (ODD), Financial DD (FDD), Commercial DD (CDD), Legal DD, ESG DD, or Full DD.. Valid values are `ODD|FDD|CDD|Legal DD|ESG DD|Full DD`',
    `document_categories` STRING COMMENT 'Comma-separated list of document category folders available in the VDR (e.g., Financial Statements, Legal Agreements, ESG Reports, Management Presentations).',
    `document_count` BIGINT COMMENT 'Total number of documents available in the VDR at the time of access grant. Provides a baseline for tracking document completeness during the DD process.',
    `documents_downloaded_count` BIGINT COMMENT 'Cumulative number of documents downloaded from the VDR by the investment team. Tracked for information security audit and NDA compliance purposes.',
    `documents_viewed_count` BIGINT COMMENT 'Cumulative number of distinct documents viewed by the investment team within this VDR access grant. Indicates DD thoroughness and document review progress.',
    `download_enabled` BOOLEAN COMMENT 'Indicates whether downloading of documents is permitted for users with this access grant. Restricted access may allow viewing only without download capability.',
    `esg_documents_available` BOOLEAN COMMENT 'Indicates whether ESG-related documents (e.g., sustainability reports, GHG disclosures, governance policies) are available in the VDR for ESG DD review.',
    `financial_statements_available` BOOLEAN COMMENT 'Indicates whether audited financial statements are available in the VDR, a prerequisite for Financial Due Diligence (FDD) workstream completion.',
    `granted_by` STRING COMMENT 'Name or identifier of the individual (typically the deal lead or DD coordinator) who authorized and provisioned the VDR access for the investment team.',
    `ic_submission_ready` BOOLEAN COMMENT 'Indicates whether the document review from this VDR access is sufficiently complete to support Investment Committee submission for the associated deal.',
    `kyc_aml_documents_available` BOOLEAN COMMENT 'Indicates whether KYC/AML documentation (e.g., ownership structure, beneficial ownership, source of funds) is available in the VDR for compliance review.',
    `last_accessed_date` DATE COMMENT 'Most recent date on which a member of the investment team accessed the VDR. Used to monitor engagement activity and identify stale or inactive access grants.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this VDR access record was most recently modified in the data platform. Supports change tracking and audit trail requirements.',
    `legal_documents_available` BOOLEAN COMMENT 'Indicates whether key legal documents (e.g., LPA, SPA, constitutional documents, material contracts) are available in the VDR for legal DD review.',
    `nda_executed` BOOLEAN COMMENT 'Indicates whether a valid NDA has been executed with the target entity prior to granting VDR access. Access should not be provisioned without NDA execution.',
    `nda_execution_date` DATE COMMENT 'Date on which the NDA was formally executed between the pension fund and the target entity or its advisors, establishing confidentiality obligations.',
    `nda_reference` STRING COMMENT 'Reference number or identifier of the executed NDA governing the use of information accessed through the VDR. Required before access is provisioned.',
    `outstanding_document_requests` BIGINT COMMENT 'Number of document requests submitted to the target entity via the VDR that remain unfulfilled. Tracks information gaps in the DD process.',
    `print_enabled` BOOLEAN COMMENT 'Indicates whether printing of documents is permitted for users with this access grant. Controlled to limit physical distribution of confidential deal materials.',
    `revocation_reason` STRING COMMENT 'Reason for early revocation of VDR access. Supports audit trail and compliance reporting on information security and deal lifecycle management.. Valid values are `deal_terminated|dd_completed|nda_breach|access_expired|counterparty_request|other`',
    `source_system_ref` STRING COMMENT 'Native identifier of this VDR access record in the originating source system (e.g., eFront access record ID), enabling lineage tracing and reconciliation.',
    `target_entity_name` STRING COMMENT 'Legal name of the target company, fund, or asset being evaluated in the DD engagement. Confidential as it identifies a prospective investment under NDA.',
    `third_party_advisor` STRING COMMENT 'Name of the external advisor firm (e.g., legal counsel, accounting firm, technical advisor) also granted access to the VDR as part of the DD engagement.',
    `vdr_platform` STRING COMMENT 'Name of the virtual data room platform hosting the DD documents (e.g., Intralinks, Datasite, Ansarada). Determines integration and access protocols.. Valid values are `Intralinks|Datasite|Ansarada|Merrill DatasiteOne|Box|SharePoint`',
    `vdr_room_code` STRING COMMENT 'Platform-assigned unique identifier for the data room instance, used for API integration and cross-referencing with the VDR platforms own records.',
    `vdr_room_name` STRING COMMENT 'Name of the specific data room instance on the VDR platform, typically reflecting the target entity or deal name. Treated as confidential deal information.',
    `vdr_url` STRING COMMENT 'Web URL for accessing the virtual data room. Classified as confidential as it provides direct access to sensitive deal documents under NDA.',
    `watermarking_enabled` BOOLEAN COMMENT 'Indicates whether document watermarking is enabled in the VDR to deter unauthorized distribution and support document traceability.',
    CONSTRAINT pk_data_room_access PRIMARY KEY(`data_room_access_id`)
) COMMENT 'Record of virtual data room (VDR) access granted to the investment team for a specific DD engagement. Captures VDR platform (e.g., Intralinks, Datasite, Ansarada), access grant date, access expiry date, document categories available, number of documents';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`management_interview` (
    `management_interview_id` BIGINT COMMENT 'Unique surrogate identifier for a management interview or reference check record within the due diligence process.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the parent DD engagement under which this interview or reference check is conducted.',
    `dd_workstream_id` BIGINT COMMENT 'Reference to the specific DD workstream (e.g., ODD, FDD, CDD) this interview supports.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity associated with this interview, sourced from the deal pipeline system.',
    `employee_id` BIGINT COMMENT 'Internal analyst responsible for conducting and documenting this interview or reference check.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager or GP being evaluated, where the interview relates to an external manager mandate.',
    `lead_analyst_employee_id` BIGINT COMMENT 'Internal analyst responsible for conducting and documenting this interview or reference check.',
    `manager_contact_id` BIGINT COMMENT 'Foreign key linking to manager.manager_contact. Business justification: Management interviews must link to specific GP contacts interviewed. This supports key person clause monitoring, tracks interview history per individual, and enables cross-referencing',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager or GP being evaluated, where the interview relates to an external manager mandate.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity associated with this interview, sourced from the deal pipeline system.',
    `actual_date` DATE COMMENT 'The actual calendar date on which the interview or reference check took place, which may differ from the scheduled date.',
    `additional_attendees` STRING COMMENT 'Names and roles of other internal team members or advisors who attended the interview, recorded for completeness of the DD audit trail.',
    `aml_kyc_concern_flag` BOOLEAN COMMENT 'Flags whether the interview surfaced any AML or KYC concerns requiring escalation to the compliance team for further investigation.',
    `asset_class` STRING COMMENT 'Asset class of the investment being evaluated, providing context for the interviews scope and relevance to the portfolio strategy. [ENUM-REF-CANDIDATE: private_equity|real_estate|infrastructure|natural_resources|credit|public_equities|external_manager —',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this management interview record was first created in the system, providing the audit trail creation point.',
    `data_room_reference` STRING COMMENT 'Reference path or document identifier in the virtual data room where the interview notes, transcript, or supporting materials are stored.',
    `dd_type` STRING COMMENT 'The DD workstream category this interview supports: Operational DD (ODD), Financial DD (FDD), Commercial DD (CDD), Legal DD, ESG DD, or general cross-workstream.. Valid values are `ODD|FDD|CDD|legal_dd|ESG_dd|general`',
    `duration_minutes` BIGINT COMMENT 'Actual duration of the interview or reference check in minutes, used to assess depth of engagement and completeness of coverage.',
    `esg_findings_summary` STRING COMMENT 'Summary of ESG-related findings from the interview, including managements approach to climate risk, governance practices, and responsible investment integration.',
    `esg_topics_discussed` BOOLEAN COMMENT 'Indicates whether Environmental, Social, and Governance (ESG) topics were explicitly discussed during the interview, supporting ESG DD completeness tracking.',
    `follow_up_description` STRING COMMENT 'Description of the specific follow-up actions required, including outstanding questions, additional document requests, or further interviews needed.',
    `follow_up_due_date` DATE COMMENT 'Target date by which follow-up actions from this interview must be completed, aligned with the overall DD engagement timeline.',
    `follow_up_required` BOOLEAN COMMENT 'Indicates whether additional follow-up actions, clarifications, or supplementary interviews are required as a result of this interview.',
    `ic_submission_included` BOOLEAN COMMENT 'Indicates whether findings from this interview are included in the Investment Committee (IC) submission package for the associated deal or mandate.',
    `interview_format` STRING COMMENT 'The medium through which the interview was conducted: in-person meeting, video call, phone call, or written questionnaire response.. Valid values are `in_person|video_call|phone_call|written_questionnaire`',
    `interview_location` STRING COMMENT 'Physical location or virtual platform where the interview took place (e.g., target HQ city, office address, or video platform name for remote sessions).',
    `interview_reference` STRING COMMENT 'Unique human-readable reference code for this interview or reference check record, used for tracking and cross-referencing in IC submissions and DD reports.. Valid values are `^MI-[0-9]{4}-[0-9]{6}$`',
    `interview_sequence` BIGINT COMMENT 'Sequential number of this interview within the DD engagement, indicating whether it is the first, second, or subsequent session with the target or referee.',
    `interview_status` STRING COMMENT 'Current lifecycle status of the interview: scheduled, completed, cancelled, rescheduled, or pending notes/write-up after completion.. Valid values are `scheduled|completed|cancelled|rescheduled|pending_notes`',
    `interview_type` STRING COMMENT 'Classification of the engagement: formal management interview with target, on-site visit, third-party reference check, expert network call, or advisor debrief.. Valid values are `management_interview|site_visit|reference_check|expert_call|advisor_debrief`',
    `interviewee_name` STRING COMMENT 'Full name of the primary individual interviewed (management representative) or the referee providing a reference check response.',
    `interviewee_organization` STRING COMMENT 'Name of the organization the interviewee represents. For reference checks, this is the referees employer, not the target entity.',
    `interviewee_relationship` STRING COMMENT 'Nature of the interviewees relationship to the target entity, critical for assessing objectivity and relevance of information provided. [ENUM-REF-CANDIDATE: promote to reference product]',
    `interviewee_title` STRING COMMENT 'Professional title or role of the interviewee at their organization (e.g., CEO, CFO, Head of Risk, Portfolio Manager).',
    `key_findings` STRING COMMENT 'Analysts summary of the most significant insights, observations, and conclusions drawn from the interview relevant to the investment decision.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this interview record, supporting audit trail and data lineage requirements.',
    `lead_analyst_name` STRING COMMENT 'Name of the internal analyst who led the interview, retained for audit trail and IC submission documentation.',
    `management_quality_assessment` STRING COMMENT 'Narrative assessment of management team quality, depth, experience, and alignment of interests based on the interview, feeding into the DD risk assessment management quality score.',
    `notes_completed_date` DATE COMMENT 'Date on which the interview notes or write-up were finalized and submitted, used for DD timeline tracking.',
    `notes_completed_flag` BOOLEAN COMMENT 'Indicates whether the formal interview notes or write-up have been completed and submitted by the lead analyst.',
    `overall_impression_rating` STRING COMMENT 'Analysts qualitative rating of the overall impression from the interview, used to inform the management quality score in the DD risk assessment.. Valid values are `strong_positive|positive|neutral|negative|strong_negative`',
    `recording_consent_obtained` BOOLEAN COMMENT 'Indicates whether explicit consent was obtained from the interviewee to record the session, required for compliance with privacy regulations.',
    `red_flags_identified` STRING COMMENT 'Specific concerns, inconsistencies, or adverse findings surfaced during the interview that require escalation or further investigation.',
    `referee_sourced_by` STRING COMMENT 'How the referee or interviewee was identified: analyst-sourced independently, provided by the GP/target, via third-party advisor, expert network, or internal network. Indicates potential bias.. Valid values are `analyst_sourced|gp_provided|third_party_advisor|expert_network|internal_network`',
    `scheduled_date` DATE COMMENT 'The calendar date on which the interview or site visit is planned to occur.',
    `scheduled_start_time` TIMESTAMP COMMENT 'Precise date and time the interview is scheduled to begin, including timezone offset, for calendar coordination across geographies.',
    `target_entity_name` STRING COMMENT 'Legal name of the company, fund, or asset being evaluated in the DD process to which this interview relates.',
    `third_party_advisor` STRING COMMENT 'Name of the external advisor firm (e.g., legal counsel, ODD specialist) who participated in or facilitated this interview.',
    `topics_covered` STRING COMMENT 'Summary of the key subject areas and agenda items discussed during the interview (e.g., investment process, risk management, team stability, ESG integration).',
    CONSTRAINT pk_management_interview PRIMARY KEY(`management_interview_id`)
) COMMENT 'Record of a formal qualitative information-gathering engagement conducted during DD — covering both management interviews/site visits with the target and reference checks with third-party referees.';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`reference_check` (
    `reference_check_id` BIGINT COMMENT 'Unique surrogate identifier for the reference check record within the diligence domain.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the parent DD engagement under which this reference check was conducted.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity associated with this reference check, sourced from the deal pipeline.',
    `employee_id` BIGINT COMMENT 'Internal identifier of the investment team analyst or associate who conducted the reference check interview.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager being evaluated, where the reference check relates to a manager mandate assessment.',
    `interviewer_employee_id` BIGINT COMMENT 'Internal identifier of the investment team analyst or associate who conducted the reference check interview.',
    `manager_contact_id` BIGINT COMMENT 'Foreign key linking to manager.manager_contact. Business justification: Reference checks on key persons must link to the manager_contact record. This supports key person due diligence, tracks reference history per individual, and enables pattern analysis',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager being evaluated, where the reference check relates to a manager mandate assessment.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity associated with this reference check, sourced from the deal pipeline.',
    `advisor_report_reference` STRING COMMENT 'Document reference or identifier for the third-party advisors written report or findings related to this reference check, linking to the data room.',
    `asset_class` STRING COMMENT 'Asset class of the investment opportunity or fund manager mandate to which this reference check relates, enabling domain-specific DD analysis.. Valid values are `private_equity|real_estate|infrastructure|natural_resources|credit|public_equities`',
    `check_date` DATE COMMENT 'Date on which the reference check conversation or interview was conducted with the referee.',
    `check_reference` STRING COMMENT 'Unique human-readable business identifier for the reference check, used for tracking and cross-referencing in IC submissions and DD reports.. Valid values are `^RC-[0-9]{4}-[0-9]{6}$`',
    `check_status` STRING COMMENT 'Current lifecycle status of the reference check, tracking progress from planning through completion or cancellation.. Valid values are `planned|in_progress|completed|cancelled|on_hold`',
    `check_type` STRING COMMENT 'Category of reference check indicating whether it covers a target company management team member, GP investment professional, co-investor, or other party. [ENUM-REF-CANDIDATE',
    `confidentiality_requested` BOOLEAN COMMENT 'Indicates whether the referee requested that their identity be kept confidential and not disclosed to the subject or third parties.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this reference check record was first created in the system, providing the audit trail creation event.',
    `data_room_reference` STRING COMMENT 'Reference path or identifier for the reference check notes, transcript, or supporting documentation stored in the virtual data room.',
    `dd_type` STRING COMMENT 'The DD workstream category under which this reference check falls: Operational DD (ODD), Financial DD (FDD), Commercial DD (CDD), Legal DD, or ESG DD.. Valid values are `ODD|FDD|CDD|legal_dd|esg_dd`',
    `esg_concerns_noted` BOOLEAN COMMENT 'Indicates whether the reference check surfaced any Environmental, Social, or Governance concerns about the subject, feeding into ESG DD and responsible investment assessment.',
    `follow_up_notes` STRING COMMENT 'Description of required follow-up actions, open questions, or additional investigation steps identified as a result of this reference check.',
    `follow_up_required` BOOLEAN COMMENT 'Indicates whether additional follow-up with the referee or further investigation is required based on the findings of this reference check.',
    `ic_submission_included` BOOLEAN COMMENT 'Indicates whether the findings from this reference check are included in the Investment Committee (IC) submission package for the associated deal or mandate.',
    `integrity_rating` STRING COMMENT 'Referees assessment of the subjects integrity and ethical conduct, a critical dimension in ODD for institutional investors.. Valid values are `strong|satisfactory|concerns_noted|unsatisfactory`',
    `interview_duration_minutes` BIGINT COMMENT 'Duration of the reference check interview in minutes, providing context for the depth and thoroughness of the reference conversation.',
    `interview_method` STRING COMMENT 'Mode by which the reference check interview was conducted: phone call, video conference, in-person meeting, or written questionnaire.. Valid values are `phone|video_call|in_person|written`',
    `interviewer_name` STRING COMMENT 'Full name of the internal analyst or investment professional who conducted the reference check, for audit and IC submission purposes.',
    `investment_acumen_rating` STRING COMMENT 'Referees assessment of the subjects investment judgment, deal sourcing capability, and track record quality, relevant for GP and management team evaluations.. Valid values are `strong|satisfactory|concerns_noted|unsatisfactory`',
    `key_feedback_summary` STRING COMMENT 'Narrative summary of the most significant feedback provided by the referee, capturing key strengths, concerns, and notable observations for IC and DD report inclusion.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this reference check record, supporting audit trail and data lineage requirements.',
    `leadership_rating` STRING COMMENT 'Referees qualitative assessment of the subjects leadership capabilities, team management, and strategic decision-making effectiveness.. Valid values are `strong|satisfactory|concerns_noted|unsatisfactory`',
    `overall_rating` STRING COMMENT 'Consolidated qualitative rating summarizing the overall outcome of the reference check, used in DD risk assessment and IC submission materials.. Valid values are `strong_positive|positive|neutral|negative|strong_negative`',
    `red_flags_description` STRING COMMENT 'Detailed narrative description of any red flags or material concerns identified during the reference check, required when red_flags_noted is True.',
    `red_flags_noted` BOOLEAN COMMENT 'Boolean flag indicating whether the reference check surfaced any material red flags, concerns, or adverse findings requiring escalation or further investigation.',
    `referee_consent_obtained` BOOLEAN COMMENT 'Confirms that the referee provided informed consent for their feedback to be recorded and used in the DD process, required under GDPR and applicable privacy regulations.',
    `referee_contact_email` STRING COMMENT 'Professional email address of the referee, used for follow-up correspondence and audit trail. Classified as restricted PII per GDPR.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `referee_contact_phone` STRING COMMENT 'Direct phone number of the referee for scheduling and follow-up. Classified as restricted PII per GDPR and applicable privacy regulations.',
    `referee_name` STRING COMMENT 'Full name of the individual who provided the reference. Treated as confidential to protect the referees identity in IC and reporting contexts.',
    `referee_organization` STRING COMMENT 'Name of the organization where the referee is currently employed or was employed during their relationship with the subject.',
    `referee_relationship` STRING COMMENT 'Nature of the professional relationship between the referee and the subject being referenced, critical for assessing objectivity and relevance of feedback.',
    `referee_sourced_by` STRING COMMENT 'Indicates how the referee was identified — whether provided by the GP/target, independently sourced by the investment team, or identified via network or third-party advisor.. Valid values are `fund_provided|independently_sourced|network_referral|third_party_advisor`',
    `referee_title` STRING COMMENT 'Professional title or designation of the referee at the time of the reference check (e.g., CFO, Managing Partner, Head of Infrastructure).',
    `relationship_duration_years` DECIMAL(5,2) COMMENT 'Approximate number of years the referee has known or worked with the subject, providing context for the depth and relevance of the reference.',
    `subject_name` STRING COMMENT 'Full name of the individual being referenced — typically a management team member of the target company or an investment professional at the GP being evaluated.',
    `subject_organization` STRING COMMENT 'Name of the organization where the subject individual is employed or was previously employed at the time of the reference check.',
    `subject_title` STRING COMMENT 'Professional title or role of the individual being referenced (e.g., CEO, Managing Director, Portfolio Manager) at the target entity.',
    `target_entity_name` STRING COMMENT 'Name of the target company, fund, or GP organization that is the subject of the broader DD engagement to which this reference check belongs.',
    `third_party_advisor` STRING COMMENT 'Name of the external advisory firm engaged to conduct or assist with the reference check (e.g., specialist ODD firm, background check provider).',
    `topics_covered` STRING COMMENT 'Structured summary of the key topic areas discussed during the reference check, such as leadership, investment track record, integrity, team dynamics, and ESG practices.',
    `would_work_again` STRING COMMENT 'Referees response to whether they would work with or invest alongside the subject again, a standard qualitative indicator in institutional ODD reference checks.. Valid values are `yes|no|with_reservations|declined_to_answer`',
    CONSTRAINT pk_reference_check PRIMARY KEY(`reference_check_id`)
) COMMENT 'Record of a reference check conducted on a target companys management team or an external fund managers investment professionals. Captures referee name, referee organization, referee relationship to subject, check date, topics covered, key feedback';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`dd_document` (
    `dd_document_id` BIGINT COMMENT 'Unique surrogate identifier for a due diligence document record in the metadata registry.',
    `dd_checklist_item_id` BIGINT COMMENT 'Reference to the DD checklist item this document satisfies or supports as evidence.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the DD engagement under which this document was received, generated, or reviewed.',
    `dd_workstream_id` BIGINT COMMENT 'Reference to the specific DD workstream (ODD, FDD, CDD, Legal, ESG) this document belongs to.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity in the pipeline that this document supports.',
    `employee_id` BIGINT COMMENT 'Reference to the internal analyst or team member responsible for reviewing and assessing this document.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager being evaluated, if this document relates to a manager DD engagement.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager being evaluated, if this document relates to a manager DD engagement.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity in the pipeline that this document supports.',
    `resource_asset_id` BIGINT COMMENT 'Foreign key linking to naturalresource.resource_asset. Business justification: Documents related to the asset are stored in dd_document; linking allows asset‑centric document search.',
    `reviewer_employee_id` BIGINT COMMENT 'Reference to the internal analyst or team member responsible for reviewing and assessing this document.',
    `superseded_by_document_dd_document_id` BIGINT COMMENT 'Reference to the newer document record that supersedes this version, enabling document version chain tracking.',
    `target_entity_id` BIGINT COMMENT 'FK to deal.target_entity',
    `asset_class` STRING COMMENT 'The investment asset class to which the DD engagement and this document relate.. Valid values are `private_equity|real_estate|infrastructure|natural_resources|credit|public_equities`',
    `confidentiality_level` STRING COMMENT 'Data classification level assigned to this document per the funds information security policy.. Valid values are `restricted|confidential|internal|public`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this document metadata record was first created in the registry.',
    `data_room_platform` STRING COMMENT 'Name of the virtual data room (VDR) platform where this document is stored and accessed during the DD process. [ENUM-REF-CANDIDATE: Intralinks|Datasite|Ansarada|SharePoint|Box|Firmex|other — 7 candidates stripped; promote to reference product]',
    `data_room_reference` STRING COMMENT 'Unique path, folder reference, or file identifier locating this document within the virtual data room (VDR) platform.',
    `dd_type` STRING COMMENT 'The DD workstream category this document primarily supports: Operational (ODD), Financial (FDD), Commercial (CDD), Legal, ESG, Tax, Technical, or General. [ENUM-REF-CANDIDATE: ODD|FDD|CDD|Legal|ESG|Tax|Technical|General — 8 candidates stripped; promote to',
    `document_currency` STRING COMMENT 'ISO 4217 three-letter currency code of the primary currency used in the document (e.g., USD, GBP, EUR).. Valid values are `^[A-Z]{3}$`',
    `document_date` DATE COMMENT 'The date the document was formally issued, signed, or published by the originating party.',
    `document_language` STRING COMMENT 'ISO 639-2 three-letter language code of the document (e.g., ENG, FRE, DEU).. Valid values are `^[A-Z]{3}$`',
    `document_reference` STRING COMMENT 'Unique human-readable reference code assigned to this document within the DD engagement (e.g., DDR-2024-FDD-0042).',
    `document_status` STRING COMMENT 'Current lifecycle status of the document within the DD review process.. Valid values are `received|under_review|reviewed|accepted|rejected|superseded`',
    `document_summary` STRING COMMENT 'Brief analyst-authored summary of the documents key content, findings, or relevance to the DD engagement.',
    `document_title` STRING COMMENT 'Full descriptive title of the document as provided by the originating party or assigned by the DD team.',
    `document_type` STRING COMMENT 'Classification of the document by its business purpose. [ENUM-REF-CANDIDATE',
    `document_version` STRING COMMENT 'Version identifier of the document (e.g., v1.0, v2.1, Final) as designated by the originating party.',
    `esg_dimension` STRING COMMENT 'ESG dimension addressed by this document, if applicable (e.g., climate risk report = environmental, board governance review = governance).. Valid values are `environmental|social|governance|climate|general`',
    `file_format` STRING COMMENT 'File format or MIME type of the document (e.g., PDF, XLSX, DOCX), used for document management and access control. [ENUM-REF-CANDIDATE: PDF|XLSX|DOCX|PPTX|CSV|ZIP|other — 7 candidates stripped; promote to reference product]',
    `file_name` STRING COMMENT 'Original file name of the document as stored in the data room or document management system.',
    `file_size_kb` BIGINT COMMENT 'Size of the document file in kilobytes, used for storage management and data room auditing.',
    `is_final_version` BOOLEAN COMMENT 'Indicates whether this document represents the final, authoritative version superseding all prior drafts.',
    `is_ic_relevant` BOOLEAN COMMENT 'Indicates whether this document is designated as material evidence for the Investment Committee (IC) submission package.',
    `is_nda_required` BOOLEAN COMMENT 'Indicates whether a signed NDA is required before this document may be accessed or distributed.',
    `key_findings` STRING COMMENT 'Material findings or observations extracted from this document that are relevant to the DD risk assessment or IC recommendation.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this document metadata record was most recently modified.',
    `originating_party_name` STRING COMMENT 'Name of the entity that produced or provided the document (e.g., target company, GP, external advisor, legal counsel, auditor).',
    `originating_party_type` STRING COMMENT 'Classification of the party that produced the document, distinguishing internal from external sources. [ENUM-REF-CANDIDATE: target_company|GP|external_advisor|legal_counsel|auditor|regulator|internal — 7 candidates stripped; promote to reference product]',
    `received_date` DATE COMMENT 'The date the document was received by the DD team from the counterparty, advisor, or data room.',
    `regulatory_reference` STRING COMMENT 'Applicable regulatory framework or standard this document relates to (e.g., SFDR Article 8, TCFD disclosure, third-party risk management guidance).',
    `reporting_period_end` DATE COMMENT 'End date of the financial or operational reporting period covered by the document.',
    `reporting_period_start` DATE COMMENT 'Start date of the financial or operational reporting period covered by the document (e.g., for audited financials or management accounts).',
    `reviewed_date` DATE COMMENT 'The date the document was formally reviewed and assessed by the responsible analyst or advisor.',
    `risk_relevance_rating` STRING COMMENT 'Analyst assessment of the degree to which this documents content is material to the overall DD risk assessment.. Valid values are `high|medium|low|not_applicable`',
    `source_system_ref` STRING COMMENT 'Native identifier or document ID assigned to this record in the originating source system (e.g., eFront document ID).',
    `target_entity_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier (LEI) of the target entity, used for regulatory reporting and counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `third_party_advisor` STRING COMMENT 'Name of the external advisor firm (e.g., Big 4 accounting firm, law firm, technical consultant) that authored or provided this document.',
    CONSTRAINT pk_dd_document PRIMARY KEY(`dd_document_id`)
) COMMENT 'Metadata registry record for a document received, generated, or reviewed during a DD engagement (CIM, PPM, audited financials, legal opinion, technical report, ESG disclosure, management presentation, data room file).';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`dd_status_event` (
    `dd_status_event_id` BIGINT COMMENT 'Unique surrogate identifier for each DD status transition event record in the audit trail.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the parent DD engagement to which this status event belongs.',
    `dd_workstream_id` BIGINT COMMENT 'Reference to the specific DD workstream (ODD, FDD, CDD, Legal, ESG) whose status changed. Null if the event applies at engagement level.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity associated with this DD status event, sourced from the deal pipeline system.',
    `employee_id` BIGINT COMMENT 'Identifier of the internal analyst or user who manually triggered this status transition. Null when the transition was system-initiated.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal or investment opportunity associated with this DD status event, sourced from the deal pipeline system.',
    `triggered_by_analyst_employee_id` BIGINT COMMENT 'Identifier of the internal analyst or user who manually triggered this status transition. Null when the transition was system-initiated.',
    `asset_class` STRING COMMENT 'Asset class of the investment under DD at the time of this status event, used for domain-specific reporting and analytics across the portfolio.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `comments` STRING COMMENT 'Additional free-text commentary provided by the analyst or system at the time of the status transition, capturing context not covered by structured fields.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this status event record was first written to the lakehouse Silver layer. Distinct from event_timestamp which records the business event time.',
    `dd_type` STRING COMMENT 'The type of due diligence workstream affected by this status event: Operational DD (ODD), Financial DD (FDD), Commercial DD (CDD), Legal DD, ESG DD, or full engagement-level DD.. Valid values are `ODD|FDD|CDD|legal_dd|esg_dd|full_dd`',
    `escalated_to` STRING COMMENT 'Name or role of the senior stakeholder, committee, or governance body to whom this status event was escalated (e.g., IC Sponsor, Chief Investment Officer, Investment Committee).',
    `escalation_flag` BOOLEAN COMMENT 'Indicates whether this status event was accompanied by a formal escalation to senior management, the IC sponsor, or the Investment Committee due to a critical finding or risk.',
    `escalation_reason` STRING COMMENT 'Narrative description of the reason for escalation associated with this status event, where escalation_flag is true. Documents the specific risk or finding that necessitated escalation.',
    `event_reference` STRING COMMENT 'Human-readable unique reference code for this status event, used in audit reports and IC governance documentation (e.g., DDSE-2024-000123).. Valid values are `^DDSE-[0-9]{4}-[0-9]{6}$`',
    `event_scope` STRING COMMENT 'Indicates whether this status event applies to the overall DD engagement or to a specific workstream within the engagement.. Valid values are `engagement|workstream`',
    `event_timestamp` TIMESTAMP COMMENT 'Precise date and time at which the status transition occurred, recorded in ISO 8601 format with timezone offset. This is the authoritative business event time.',
    `event_type` STRING COMMENT 'Categorises the nature of the status transition event (e.g., analyst-driven status change, IC decision, escalation, waiver approval, or automated system update).. Valid values are `status_change|escalation|waiver|ic_decision|system_update|analyst_override`',
    `ic_decision_outcome` STRING COMMENT 'The IC decision outcome that drove this status event, where the transition was triggered by an IC meeting (e.g., approved, rejected, deferred, approved with conditions).. Valid values are `approved|rejected|deferred|approved_with_conditions`',
    `ic_decision_reference` STRING COMMENT 'Reference number of the IC decision that triggered this status transition, where applicable (e.g., IC approval advancing DD to completed, or IC rejection terminating engagement).',
    `investment_type` STRING COMMENT 'Type of investment structure under DD at the time of this event: direct investment, co-investment, fund commitment, secondary transaction, or separately managed account (SMA).. Valid values are `direct|co_invest|fund|secondary|sma`',
    `is_ic_blocking` BOOLEAN COMMENT 'Indicates whether the status resulting from this event blocks IC submission or IC approval until resolved (e.g., a critical finding or unresolved condition precedent).',
    `is_milestone_event` BOOLEAN COMMENT 'Indicates whether this status transition represents a key DD lifecycle milestone (e.g., initiation, IC submission readiness, completion) for reporting and governance dashboards.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this status event record in the lakehouse, supporting data lineage and incremental load tracking.',
    `new_status` STRING COMMENT 'The status of the DD engagement or workstream after this transition event. Represents the current state post-transition. [ENUM-REF-CANDIDATE: not_started|in_progress|on_hold|pending_ic|pending_information|completed|terminated|waived|escalated — promote to',
    `on_hold_reason` STRING COMMENT 'Reason the DD engagement or workstream was placed on hold, captured when new_status is on_hold (e.g., pending NDA execution, awaiting data room access, counterparty unresponsive).',
    `prior_status` STRING COMMENT 'The status of the DD engagement or workstream immediately before this transition event. Null for the initial status assignment. [ENUM-REF-CANDIDATE: not_started|in_progress|on_hold|pending_ic|pending_information|completed|terminated|waived|escalated —',
    `prior_status_duration_days` BIGINT COMMENT 'Number of calendar days the DD engagement or workstream remained in the prior status before this transition. Used for SLA monitoring and DD cycle time analytics.',
    `source_system_event_ref` STRING COMMENT 'The native event or transaction identifier from the originating source system (e.g., eFront workflow event ID), enabling traceability back to the system of record.',
    `target_completion_date` DATE COMMENT 'The planned completion date for the DD engagement or workstream at the time of this status event, capturing any revisions to the timeline as the engagement progresses.',
    `target_entity_name` STRING COMMENT 'Name of the investment target entity or external fund manager subject to DD at the time of this status event, captured for audit immutability.',
    `termination_reason` STRING COMMENT 'Reason the DD engagement or workstream was terminated, captured when new_status is terminated (e.g., deal withdrawn, IC rejection, valuation mismatch, ESG disqualification).',
    `triggered_by_analyst_name` STRING COMMENT 'Display name of the internal analyst or user who triggered this status transition, captured at the time of the event for audit immutability.',
    `triggered_by_system` STRING COMMENT 'Name of the operational system that automatically triggered this status transition (e.g., eFront workflow engine, Dealpath pipeline update). Null for manually triggered events.. Valid values are `eFront|Dealpath|DealCloud|Diligent|manual|SimCorp`',
    `triggered_by_type` STRING COMMENT 'Indicates the category of actor or mechanism that triggered the status transition: an analyst, an IC decision, an automated system process, the external manager, a third-party advisor, or a compliance control.. Valid values are `analyst|ic_decision|system|manager|third_party_advisor|compliance`',
    `triggering_event_description` STRING COMMENT 'Free-text narrative describing the specific business event, decision, or condition that caused this status transition (e.g., IC approval received, data room access granted, critical finding identified).',
    `waiver_approved_by` STRING COMMENT 'Name or role of the authority who approved the waiver associated with this status event (e.g., IC Sponsor, Chief Risk Officer). Populated only when waiver_flag is true.',
    `waiver_flag` BOOLEAN COMMENT 'Indicates whether this status event involved the approval of a waiver for an outstanding DD item or condition, allowing the engagement to progress despite an unresolved finding.',
    CONSTRAINT pk_dd_status_event PRIMARY KEY(`dd_status_event_id`)
) COMMENT 'Audit trail of status transitions for a DD engagement or workstream throughout its lifecycle. Captures the prior status, new status, transition timestamp, triggering event description, and the analyst or system that triggered the change.';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`kyc_aml_record` (
    `kyc_aml_record_id` BIGINT COMMENT 'Unique system-generated identifier for the KYC/AML screening record. Primary key for this entity. Role: TRANSACTION_HEADER.',
    `compliance_officer_employee_id` BIGINT COMMENT 'Reference to the compliance officer responsible for reviewing and approving this KYC/AML screening record and its final determination.',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: Regulatory requirement (EMIR/Dodd-Frank): OTC derivative counterparties must pass KYC/AML screening before ISDA/CSA execution.',
    `dd_engagement_id` BIGINT COMMENT 'Reference to the parent DD engagement under which this KYC/AML screening was initiated, linking the record to the broader diligence process.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the investment deal or transaction for which this KYC/AML screening was conducted, linking to the deal origination pipeline.',
    `employee_id` BIGINT COMMENT 'Reference to the internal analyst or compliance officer who initiated this KYC/AML screening request.',
    `exclusion_list_id` BIGINT COMMENT 'Foreign key linking to esg.exclusion_list. Business justification: KYC/AML screening must cross-reference ESG exclusion lists for sanctions, controversial weapons, UNGC violations.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager being screened, applicable when the KYC/AML record pertains to a GP or external manager onboarding.',
    `kyc_compliance_officer_employee_id` BIGINT COMMENT 'Reference to the compliance officer responsible for reviewing and approving this KYC/AML screening record and its final determination.',
    `kyc_employee_id` BIGINT COMMENT 'Reference to the internal analyst or compliance officer who initiated this KYC/AML screening request.',
    `manager_gp_profile_id` BIGINT COMMENT 'Reference to the external fund manager being screened, applicable when the KYC/AML record pertains to a GP or external manager onboarding.',
    `opportunity_id` BIGINT COMMENT 'Reference to the investment deal or transaction for which this KYC/AML screening was conducted, linking to the deal origination pipeline.',
    `adverse_media_flag` BOOLEAN COMMENT 'Indicates whether adverse media screening identified negative news coverage related to financial crime, fraud, corruption, or regulatory violations for the subject.',
    `adverse_media_summary` STRING COMMENT 'Brief narrative summary of adverse media findings identified during screening, including nature of allegations and source references. Null if no adverse media found.',
    `aml_risk_rating` STRING COMMENT 'Risk-based AML classification assigned to the subject following screening, used to determine monitoring frequency and enhanced due diligence requirements.. Valid values are `low|medium|high|very_high`',
    `aml_risk_score` DECIMAL(5,2) COMMENT 'Quantitative AML risk score assigned to the subject by the screening model or third-party provider, on a standardized scale used for risk-tiering decisions.',
    `asset_class` STRING COMMENT 'Asset class context in which this KYC/AML screening was conducted, enabling domain-specific risk calibration and reporting segmentation. [ENUM-REF-CANDIDATE: public_equity|private_equity|real_estate|infrastructure|natural_resources|credit|multi_asset — 7',
    `beneficial_owner_verified` BOOLEAN COMMENT 'Indicates whether the ultimate beneficial owner(s) (UBO) of the subject entity have been identified and verified per the applicable ownership threshold (typically 25%).',
    `compliance_approval_date` DATE COMMENT 'Date on which the compliance officer formally approved the KYC/AML screening outcome, marking the completion of the compliance sign-off process.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this KYC/AML record was first created in the data platform, providing the audit trail creation marker.',
    `document_reference` STRING COMMENT 'Reference to the document repository location or data room path where KYC/AML supporting documents (ID copies, registry extracts, etc.) are stored.',
    `edd_completed_date` DATE COMMENT 'Date on which Enhanced Due Diligence (EDD) was completed for this subject, applicable when EDD was required. Null if EDD was not required.',
    `enhanced_due_diligence_required` BOOLEAN COMMENT 'Indicates whether Enhanced Due Diligence (EDD) is required for this subject based on risk rating, PEP status, sanctions proximity, or high-risk jurisdiction.',
    `escalation_reason` STRING COMMENT 'Narrative description of the reason for escalating this KYC/AML record to senior compliance or the AML committee, applicable when screening_status is escalated.',
    `expiry_date` DATE COMMENT 'Date on which this KYC/AML clearance expires and the subject must be re-screened before further business activity is permitted.',
    `high_risk_jurisdiction_flag` BOOLEAN COMMENT 'Indicates whether the subject is domiciled in or primarily operates from a FATF-identified high-risk or non-cooperative jurisdiction, triggering enhanced scrutiny.',
    `identity_verification_method` STRING COMMENT 'Method used to verify the identity of the subject, such as document review, third-party database check, official registry search, or electronic verification.. Valid values are `document_review|third_party_database|registry_search|in_person|electronic_verification`',
    `investment_type` STRING COMMENT 'Type of investment transaction associated with this KYC/AML screening, distinguishing direct investments, co-investments, fund commitments, secondaries, or SMAs.. Valid values are `direct|co_investment|fund_commitment|secondary|sma`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'System timestamp of the most recent modification to this KYC/AML record, supporting audit trail and data lineage requirements.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic KYC/AML refresh review, determined by the subjects risk tier and the firms periodic review policy.',
    `overall_kyc_aml_outcome` STRING COMMENT 'Final determination of the KYC/AML screening process, indicating whether the subject is cleared for onboarding, cleared with conditions, escalated, or rejected.. Valid values are `cleared|cleared_with_conditions|escalated|rejected|pending_review`',
    `pep_category` STRING COMMENT 'Classification of the PEP designation: domestic, foreign, international organisation PEP, or close associate, per FATF R.12 taxonomy.. Valid values are `domestic_pep|foreign_pep|international_organisation_pep|pep_associate|not_applicable`',
    `pep_flag` BOOLEAN COMMENT 'Indicates whether the subject or a beneficial owner has been identified as a Politically Exposed Person (PEP), triggering enhanced due diligence requirements.',
    `periodic_review_frequency` STRING COMMENT 'Frequency at which this subjects KYC/AML record must be periodically refreshed, determined by the assigned risk rating and regulatory requirements.. Valid values are `annual|biennial|triennial|event_triggered`',
    `record_reference` STRING COMMENT 'Externally-visible business reference code for this KYC/AML screening record, used in correspondence, audit trails, and regulatory submissions.. Valid values are `^KYC-[0-9]{4}-[0-9]{6}$`',
    `rejection_reason` STRING COMMENT 'Documented reason for rejecting the subjects onboarding or continued relationship based on KYC/AML findings, required for regulatory record-keeping.',
    `sanctions_hit_flag` BOOLEAN COMMENT 'Indicates whether the subject returned a positive match against any sanctions list (OFAC, UN, EU, or other applicable lists) during screening.',
    `sanctions_list_matched` STRING COMMENT 'Name(s) of the specific sanctions list(s) on which the subject returned a match (e.g., OFAC SDN, UN Consolidated, EU Consolidated). Null if no match.',
    `screening_completed_date` DATE COMMENT 'Calendar date on which the KYC/AML screening was concluded and a final determination was reached, used for SLA and regulatory timeliness tracking.',
    `screening_initiated_date` DATE COMMENT 'Calendar date on which the KYC/AML screening process was formally initiated, marking the start of the compliance clock for regulatory timeliness requirements.',
    `screening_provider` STRING COMMENT 'Name of the third-party screening provider or internal system used to conduct the KYC/AML checks (e.g., Refinitiv World-Check, Dow Jones Risk, LexisNexis).',
    `screening_provider_reference` STRING COMMENT 'Unique reference or case number assigned by the third-party screening provider for this screening event, used for audit trail and provider reconciliation.',
    `screening_status` STRING COMMENT 'Current lifecycle status of the KYC/AML screening process for this record, driving workflow routing and onboarding gate decisions.. Valid values are `pending|in_progress|cleared|escalated|rejected|expired`',
    `screening_type` STRING COMMENT 'Classification of the screening event: initial onboarding, periodic refresh, event-triggered review, or enhanced/simplified due diligence based on risk tier.. Valid values are `initial|periodic_refresh|trigger_review|enhanced_due_diligence|simplified_due_diligence`',
    `source_of_funds_description` STRING COMMENT 'Narrative description of the verified source of funds or wealth for the subject, documenting the basis for the fund origin determination.',
    `source_of_funds_verified` BOOLEAN COMMENT 'Indicates whether the source of funds or wealth for the subject has been verified as part of the KYC/AML process, required for high-risk and PEP subjects.',
    `subject_domicile_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the subjects country of domicile or incorporation, used for jurisdiction risk assessment and sanctions screening.. Valid values are `^[A-Z]{3}$`',
    `subject_legal_name` STRING COMMENT 'Full registered legal name of the entity or individual being screened, as per official incorporation documents or government-issued identification.',
    `subject_lei` STRING COMMENT '20-character ISO 17442 Legal Entity Identifier (LEI) of the subject being screened, used for global entity identification and regulatory reporting.. Valid values are `^[A-Z0-9]{18}[0-9]{2}$`',
    `subject_operating_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the primary country where the subject conducts its principal business operations, which may differ from domicile.. Valid values are `^[A-Z]{3}$`',
    `subject_registration_number` STRING COMMENT 'Official corporate registration or incorporation number issued by the relevant national registry for the subject entity, used for identity verification.',
    `subject_type` STRING COMMENT 'Category of the entity being screened: counterparty, target company, external fund manager, beneficial owner, co-investor, custodian, or service provider. [ENUM-REF-CANDIDATE',
    `ubo_ownership_threshold_pct` DECIMAL(5,2) COMMENT 'Ownership percentage threshold applied to identify ultimate beneficial owners (UBOs) for this screening, typically 25% per FATF standards.',
    `watchlist_match_flag` BOOLEAN COMMENT 'Indicates whether the subject matched any internal or external watchlist beyond formal sanctions lists, such as internal restricted counterparty lists.',
    CONSTRAINT pk_kyc_aml_record PRIMARY KEY(`kyc_aml_record_id`)
) COMMENT 'Know Your Customer (KYC) and Anti-Money Laundering (AML) screening record conducted on a counterparty, target company, fund manager, or beneficial owner as part of the DD and onboarding process.';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`dd_advisor_cost` (
    `dd_advisor_cost_id` BIGINT COMMENT 'Unique identifier for the advisor cost record.',
    `advisor_engagement_id` BIGINT COMMENT 'Identifier of the third‑party advisor.',
    `dd_advisor_engagement_id` BIGINT COMMENT 'Identifier of the advisor engagement associated with this cost.',
    `dd_engagement_id` BIGINT COMMENT 'Identifier of the due diligence engagement.',
    `deal_opportunity_id` BIGINT COMMENT 'Identifier of the deal associated with the engagement.',
    `employee_id` BIGINT COMMENT 'Identifier of the third‑party advisor.',
    `gp_profile_id` BIGINT COMMENT 'Identifier of the manager overseeing the engagement.',
    `manager_gp_profile_id` BIGINT COMMENT 'Identifier of the manager overseeing the engagement.',
    `opportunity_id` BIGINT COMMENT 'Identifier of the deal associated with the engagement.',
    `resource_asset_id` BIGINT COMMENT 'Foreign key linking to naturalresource.resource_asset. Business justification: Cost records for due diligence are tied to the asset; linking enables cost allocation per asset.',
    `accrued_amount` DECIMAL(18,2) COMMENT 'Amount accrued to date for the cost.',
    `budgeted_amount` DECIMAL(18,2) COMMENT 'Planned amount for the cost.',
    `cost_accrual_date` DATE COMMENT 'Date when the cost was accrued.',
    `cost_approval_date` DATE COMMENT 'Date when the cost was approved.',
    `cost_approval_status` STRING COMMENT 'Approval status of the cost record.. Valid values are `approved|pending|rejected`',
    `cost_approved_by` STRING COMMENT 'Name of the approver for the cost record.',
    `cost_category` STRING COMMENT 'Classification of the cost item.. Valid values are `fee|expense|reimbursement`',
    `cost_center_code` STRING COMMENT 'Internal cost center code for accounting purposes.',
    `cost_currency_rate` DECIMAL(18,6) COMMENT 'Exchange rate used for currency conversion.',
    `cost_currency_rate_date` DATE COMMENT 'Date of the exchange rate applied.',
    `cost_date` DATE COMMENT 'Date of the cost event.',
    `cost_description` STRING COMMENT 'Detailed description of the cost item.',
    `cost_end_date` DATE COMMENT 'End date of the cost period.',
    `cost_invoice_date` DATE COMMENT 'Date of the invoice for the cost.',
    `cost_invoice_number` STRING COMMENT 'Invoice number issued for the cost.',
    `cost_invoiced_date` DATE COMMENT 'Date when the cost was invoiced.',
    `cost_notes` STRING COMMENT 'Free‑text notes related to the cost.',
    `cost_paid_date` DATE COMMENT 'Date when the cost was paid.',
    `cost_payment_date` DATE COMMENT 'Date when the payment was processed.',
    `cost_payment_method` STRING COMMENT 'Method used to pay the cost.. Valid values are `bank_transfer|check|credit_card|wire_transfer`',
    `cost_payment_status` STRING COMMENT 'Status of the payment for the cost.. Valid values are `pending|completed|failed`',
    `cost_start_date` DATE COMMENT 'Start date of the cost period.',
    `cost_status` STRING COMMENT 'Current status of the cost line item.. Valid values are `budgeted|accrued|invoiced|paid|reconciled|cancelled`',
    `cost_tax_amount` DECIMAL(18,2) COMMENT 'Tax amount applied to the cost.',
    `cost_tax_code` STRING COMMENT 'Tax code used for the cost.. Valid values are `GST|VAT|HST|PST|QST|NONE`',
    `cost_tax_rate` DECIMAL(5,2) COMMENT 'Tax rate applied to the cost.',
    `cost_type` STRING COMMENT 'Fee structure type for the advisor engagement.. Valid values are `fixed|capped|hourly|success_based`',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the cost record was first created.',
    `currency` STRING COMMENT 'ISO 4217 currency code for the cost amounts.. Valid values are `^[A-Z]{3}$`',
    `dd_advisor_cost_status` STRING COMMENT 'Current lifecycle status of the cost record.. Valid values are `budgeted|accrued|invoiced|paid|reconciled|cancelled`',
    `gl_account_code` STRING COMMENT 'General ledger account code for cost allocation.',
    `invoiced_amount` DECIMAL(18,2) COMMENT 'Amount invoiced to the advisor.',
    `paid_amount` DECIMAL(18,2) COMMENT 'Amount paid to the advisor.',
    `reference` STRING COMMENT 'Human‑readable reference for the advisor cost record.',
    `updated_at` TIMESTAMP COMMENT 'Timestamp of the most recent update to the cost record.',
    CONSTRAINT pk_dd_advisor_cost PRIMARY KEY(`dd_advisor_cost_id`)
) COMMENT 'Cost and fee-accrual record for a third-party advisor engagement within a DD engagement. Captures the advisor_engagement reference, fee type (fixed, capped, hourly, success-based), budgeted amount, accrued-to-date, invoiced amount, paid amount, currency';

CREATE OR REPLACE TABLE `asset_management`.`diligence`.`assessment` (
    `assessment_id` BIGINT COMMENT 'Primary key for the assessment association',
    `dd_engagement_id` BIGINT COMMENT 'Foreign key linking to the due diligence engagement being assessed for compliance',
    `rule_id` BIGINT COMMENT 'Foreign key linking to the compliance rule being evaluated',
    `applicability_status` STRING COMMENT 'Indicates whether the compliance rule applies to this specific DD engagement based on asset class, geography, and entity type. Some rules only apply to certain engagement types.',
    `assessment_date` DATE COMMENT 'Calendar date on which the compliance assessment was performed for this engagement-rule combination.',
    `compliance_rating` STRING COMMENT 'Outcome rating of the compliance assessment indicating whether the DD engagement satisfies the requirements of the specific rule.',
    `remediation_required` BOOLEAN COMMENT 'Boolean flag indicating whether remediation actions are required before the engagement can proceed to IC submission based on this rule assessment.',
    CONSTRAINT pk_assessment PRIMARY KEY(`assessment_id`)
) COMMENT 'This association product represents the compliance assessment event between a due diligence engagement and a compliance rule. It captures the outcome of evaluating a specific DD engagement against a specific compliance monitoring rule.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ADD CONSTRAINT `fk_diligence_dd_engagement_prior_engagement_dd_engagement_id` FOREIGN KEY (`prior_engagement_dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ADD CONSTRAINT `fk_diligence_dd_workstream_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ADD CONSTRAINT `fk_diligence_dd_checklist_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ADD CONSTRAINT `fk_diligence_dd_checklist_parent_template_dd_checklist_id` FOREIGN KEY (`parent_template_dd_checklist_id`) REFERENCES `asset_management`.`diligence`.`dd_checklist`(`dd_checklist_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ADD CONSTRAINT `fk_diligence_dd_checklist_item_dd_checklist_id` FOREIGN KEY (`dd_checklist_id`) REFERENCES `asset_management`.`diligence`.`dd_checklist`(`dd_checklist_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ADD CONSTRAINT `fk_diligence_dd_finding_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ADD CONSTRAINT `fk_diligence_dd_risk_assessment_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ADD CONSTRAINT `fk_diligence_dd_risk_assessment_prior_assessment_dd_risk_assessment_id` FOREIGN KEY (`prior_assessment_dd_risk_assessment_id`) REFERENCES `asset_management`.`diligence`.`dd_risk_assessment`(`dd_risk_assessment_id`);
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ADD CONSTRAINT `fk_diligence_advisor_engagement_dd_workstream_id` FOREIGN KEY (`dd_workstream_id`) REFERENCES `asset_management`.`diligence`.`dd_workstream`(`dd_workstream_id`);
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ADD CONSTRAINT `fk_diligence_advisor_report_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ADD CONSTRAINT `fk_diligence_advisor_report_superseded_by_report_advisor_report_id` FOREIGN KEY (`superseded_by_report_advisor_report_id`) REFERENCES `asset_management`.`diligence`.`advisor_report`(`advisor_report_id`);
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ADD CONSTRAINT `fk_diligence_odd_assessment_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ADD CONSTRAINT `fk_diligence_fdd_assessment_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ADD CONSTRAINT `fk_diligence_cdd_assessment_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ADD CONSTRAINT `fk_diligence_esg_dd_assessment_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ADD CONSTRAINT `fk_diligence_legal_dd_assessment_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ADD CONSTRAINT `fk_diligence_diligence_ic_submission_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ADD CONSTRAINT `fk_diligence_diligence_ic_submission_prior_submission_diligence_ic_submission_id` FOREIGN KEY (`prior_submission_diligence_ic_submission_id`) REFERENCES `asset_management`.`diligence`.`diligence_ic_submission`(`diligence_ic_submission_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ADD CONSTRAINT `fk_diligence_diligence_ic_condition_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`nda_record` ADD CONSTRAINT `fk_diligence_nda_record_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ADD CONSTRAINT `fk_diligence_data_room_access_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`management_interview` ADD CONSTRAINT `fk_diligence_management_interview_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`management_interview` ADD CONSTRAINT `fk_diligence_management_interview_dd_workstream_id` FOREIGN KEY (`dd_workstream_id`) REFERENCES `asset_management`.`diligence`.`dd_workstream`(`dd_workstream_id`);
ALTER TABLE `asset_management`.`diligence`.`reference_check` ADD CONSTRAINT `fk_diligence_reference_check_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_document` ADD CONSTRAINT `fk_diligence_dd_document_dd_checklist_item_id` FOREIGN KEY (`dd_checklist_item_id`) REFERENCES `asset_management`.`diligence`.`dd_checklist_item`(`dd_checklist_item_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_document` ADD CONSTRAINT `fk_diligence_dd_document_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_document` ADD CONSTRAINT `fk_diligence_dd_document_dd_workstream_id` FOREIGN KEY (`dd_workstream_id`) REFERENCES `asset_management`.`diligence`.`dd_workstream`(`dd_workstream_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_document` ADD CONSTRAINT `fk_diligence_dd_document_superseded_by_document_dd_document_id` FOREIGN KEY (`superseded_by_document_dd_document_id`) REFERENCES `asset_management`.`diligence`.`dd_document`(`dd_document_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ADD CONSTRAINT `fk_diligence_dd_status_event_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ADD CONSTRAINT `fk_diligence_dd_status_event_dd_workstream_id` FOREIGN KEY (`dd_workstream_id`) REFERENCES `asset_management`.`diligence`.`dd_workstream`(`dd_workstream_id`);
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ADD CONSTRAINT `fk_diligence_kyc_aml_record_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ADD CONSTRAINT `fk_diligence_dd_advisor_cost_advisor_engagement_id` FOREIGN KEY (`advisor_engagement_id`) REFERENCES `asset_management`.`diligence`.`advisor_engagement`(`advisor_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ADD CONSTRAINT `fk_diligence_dd_advisor_cost_dd_advisor_engagement_id` FOREIGN KEY (`dd_advisor_engagement_id`) REFERENCES `asset_management`.`diligence`.`advisor_engagement`(`advisor_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ADD CONSTRAINT `fk_diligence_dd_advisor_cost_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`diligence`.`assessment` ADD CONSTRAINT `fk_diligence_assessment_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` SET TAGS ('dbx_subdomain' = 'diligence_execution');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `concession_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Concession Agreement Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `dd_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `dd_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `dd_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `dd_ic_sponsor_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Sponsor ID');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `dd_ic_sponsor_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `dd_ic_sponsor_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Pipeline ID');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Fund Manager ID');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `ic_sponsor_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Sponsor ID');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `infra_fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Infra Fund Commitment Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Fund Manager ID');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Mandate Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Pipeline ID');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `prior_engagement_dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `project_investment_id` SET TAGS ('dbx_business_glossary_term' = 'Project Investment Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Asset Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `actual_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Due Diligence (DD) Completion Date');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'Public Equity|Private Equity|Real Estate|Infrastructure|Natural Resources|Credit');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `cdd_rating` SET TAGS ('dbx_business_glossary_term' = 'Commercial Due Diligence (CDD) Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `cdd_rating` SET TAGS ('dbx_value_regex' = 'Pass|Pass with Concerns|Fail|Not Applicable');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Commitment Currency (ISO 4217)');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `conditions_precedent` SET TAGS ('dbx_business_glossary_term' = 'Conditions Precedent');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `conditions_precedent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `data_room_location` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Location');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `data_room_location` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `dd_type` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Type');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `dd_type` SET TAGS ('dbx_value_regex' = 'ODD|FDD|CDD|Legal|ESG|Combined');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `engagement_name` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement Name');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `engagement_priority` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement Priority');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `engagement_priority` SET TAGS ('dbx_value_regex' = 'High|Medium|Low');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `engagement_reference` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement Reference Number');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `engagement_reference` SET TAGS ('dbx_value_regex' = '^DD-[0-9]{4}-[0-9]{5}$');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `engagement_scope` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement Scope');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `engagement_status` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement Status');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `engagement_status` SET TAGS ('dbx_value_regex' = 'Initiated|In Progress|Pending IC|Completed|Suspended|Cancelled');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `esg_dd_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Due Diligence (DD) Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `esg_dd_rating` SET TAGS ('dbx_value_regex' = 'Pass|Pass with Concerns|Fail|Not Applicable');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `esg_material_issues` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Material Issues');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `fdd_rating` SET TAGS ('dbx_business_glossary_term' = 'Financial Due Diligence (FDD) Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `fdd_rating` SET TAGS ('dbx_value_regex' = 'Pass|Pass with Concerns|Fail|Not Applicable');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `ic_decision` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `ic_decision` SET TAGS ('dbx_value_regex' = 'Approved|Rejected|Deferred|Approved with Conditions|Withdrawn');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `ic_decision_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision Date');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `ic_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Date');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `im_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Memorandum (IM) Reference');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `im_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `initiation_date` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Initiation Date');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `key_risks_summary` SET TAGS ('dbx_business_glossary_term' = 'Key Due Diligence (DD) Risks Summary');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `key_risks_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `kyc_aml_cleared` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) / Anti-Money Laundering (AML) Cleared Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `kyc_cleared_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Clearance Date');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `lead_analyst_name` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst Name');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `legal_dd_rating` SET TAGS ('dbx_business_glossary_term' = 'Legal Due Diligence (DD) Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `legal_dd_rating` SET TAGS ('dbx_value_regex' = 'Pass|Pass with Concerns|Fail|Not Applicable');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `nda_executed` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Executed Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `nda_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Execution Date');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `odd_rating` SET TAGS ('dbx_business_glossary_term' = 'Operational Due Diligence (ODD) Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `odd_rating` SET TAGS ('dbx_value_regex' = 'Pass|Pass with Concerns|Fail|Not Applicable');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `overall_dd_rating` SET TAGS ('dbx_business_glossary_term' = 'Overall Due Diligence (DD) Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `overall_dd_rating` SET TAGS ('dbx_value_regex' = 'Pass|Pass with Concerns|Fail|Inconclusive');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `proposed_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Proposed Capital Commitment Amount');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `proposed_commitment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `regulatory_flags` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Flags');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `repeat_engagement` SET TAGS ('dbx_business_glossary_term' = 'Repeat Due Diligence (DD) Engagement Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `target_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Target Due Diligence (DD) Completion Date');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `target_entity_type` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Type');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `target_entity_type` SET TAGS ('dbx_value_regex' = 'Direct Investment|Co-Investment|External Fund Manager|Real Asset|Credit Issuer');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `target_geography` SET TAGS ('dbx_business_glossary_term' = 'Target Investment Geography');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `third_party_advisor` SET TAGS ('dbx_business_glossary_term' = 'Third-Party DD Advisor');
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` SET TAGS ('dbx_subdomain' = 'diligence_execution');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `dd_workstream_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Workstream ID');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `lead_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `actual_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Completion Date');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `actual_start_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Start Date');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `advisor_engagement_ref` SET TAGS ('dbx_business_glossary_term' = 'Advisor Engagement Reference Number');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `advisor_engagement_ref` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `advisor_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor Fee Amount');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `advisor_fee_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `advisor_fee_currency` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor Fee Currency');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `advisor_fee_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `aml_kyc_concern_flag` SET TAGS ('dbx_business_glossary_term' = 'Anti-Money Laundering (AML) / Know Your Customer (KYC) Concern Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'Private Equity|Real Estate|Infrastructure|Natural Resources|Credit|Public Equities');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `checklist_completion_pct` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Checklist Completion Percentage');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `checklist_template_ref` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Checklist Template Reference');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `conditions_precedent` SET TAGS ('dbx_business_glossary_term' = 'Conditions Precedent');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `conditions_precedent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `critical_finding_count` SET TAGS ('dbx_business_glossary_term' = 'Critical Due Diligence (DD) Finding Count');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `data_room_access_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Room Access Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `data_room_platform` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Platform Name');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `esg_materiality_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Materiality Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `esg_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `esg_risk_rating` SET TAGS ('dbx_value_regex' = 'Low|Medium|High|Critical');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `finding_count` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Finding Count');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `ic_approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Required Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `ic_submission_deadline` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Deadline');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `investment_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Type');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `investment_type` SET TAGS ('dbx_value_regex' = 'Direct|Co-Investment|Fund Subscription|Secondary|SMA');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `key_findings_summary` SET TAGS ('dbx_business_glossary_term' = 'Key Findings Summary');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `key_findings_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `nda_executed_flag` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Executed Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `open_finding_count` SET TAGS ('dbx_business_glossary_term' = 'Open Due Diligence (DD) Finding Count');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `overall_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Overall Due Diligence (DD) Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `overall_risk_rating` SET TAGS ('dbx_value_regex' = 'Low|Medium|High|Critical');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `planned_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Completion Date');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Start Date');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Workstream Priority Level');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'Critical|High|Medium|Low');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `recommendation` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Workstream Recommendation');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `recommendation` SET TAGS ('dbx_value_regex' = 'Proceed|Proceed with Conditions|Further Investigation Required|Do Not Proceed');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `recommendation` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `regulatory_concern_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Concern Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `report_issued_date` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Report Issued Date');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `report_version` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Report Version');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `report_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+$');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `scope_description` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Workstream Scope Description');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `sign_off_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Workstream Sign-Off Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `target_country` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Country');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `target_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `target_entity_lei` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `target_entity_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `third_party_advisor` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor Name');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `workstream_code` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Workstream Code');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `workstream_code` SET TAGS ('dbx_value_regex' = '^DD-WS-[A-Z0-9]{4,20}$');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `workstream_name` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Workstream Name');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `workstream_owner` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Workstream Owner');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `workstream_status` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Workstream Status');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `workstream_status` SET TAGS ('dbx_value_regex' = 'Not Started|In Progress|Under Review|Completed|On Hold|Cancelled');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `workstream_type` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Workstream Type');
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ALTER COLUMN `workstream_type` SET TAGS ('dbx_value_regex' = 'ODD|FDD|CDD|Legal DD|ESG DD|Tax DD');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` SET TAGS ('dbx_subdomain' = 'diligence_execution');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `dd_checklist_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Checklist ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Due Diligence (DD) Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Fund Manager ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `lead_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Due Diligence (DD) Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Fund Manager ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `parent_template_dd_checklist_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Due Diligence (DD) Checklist Template ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `actual_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Completion Date');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `advisor_engagement_ref` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor Engagement Reference');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `advisor_engagement_ref` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Checklist Approved By');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Checklist Approved Date');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'Private Equity|Real Estate|Infrastructure|Natural Resources|Credit|Public Equities');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `assigned_date` SET TAGS ('dbx_business_glossary_term' = 'Checklist Assigned Date');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `checklist_code` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Checklist Code');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `checklist_code` SET TAGS ('dbx_value_regex' = '^DDC-[A-Z]{2,10}-[0-9]{4,8}$');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `checklist_name` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Checklist Name');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `checklist_status` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Checklist Status');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `checklist_status` SET TAGS ('dbx_value_regex' = 'Draft|Active|Deprecated|Archived|Under Review');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `checklist_version` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Checklist Version');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `checklist_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+(.[0-9]+)?$');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `completed_item_count` SET TAGS ('dbx_business_glossary_term' = 'Completed Due Diligence (DD) Checklist Item Count');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `completion_status` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Checklist Completion Status');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `completion_status` SET TAGS ('dbx_value_regex' = 'Not Started|In Progress|Completed|Waived|On Hold');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `conditions_precedent` SET TAGS ('dbx_business_glossary_term' = 'Conditions Precedent');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `conditions_precedent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `critical_item_count` SET TAGS ('dbx_business_glossary_term' = 'Critical Due Diligence (DD) Checklist Item Count');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `data_room_access` SET TAGS ('dbx_business_glossary_term' = 'Data Room Access Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `data_room_url` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) URL');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `data_room_url` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `esg_scope_included` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Scope Included Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `geography` SET TAGS ('dbx_business_glossary_term' = 'Target Geography (ISO 3166-1 Alpha-3)');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `geography` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `ic_submission_required` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Required Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `is_customized` SET TAGS ('dbx_business_glossary_term' = 'Is Customized Checklist Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Is Mandatory Checklist Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `key_findings_summary` SET TAGS ('dbx_business_glossary_term' = 'Key Due Diligence (DD) Findings Summary');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `key_findings_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `kyc_aml_scope_included` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) / Anti-Money Laundering (AML) Scope Included Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `nda_in_place` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) In Place Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `outstanding_item_count` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Due Diligence (DD) Checklist Item Count');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `overall_dd_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Overall Due Diligence (DD) Recommendation');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `overall_dd_recommendation` SET TAGS ('dbx_value_regex' = 'Proceed|Proceed with Conditions|Further Review|Do Not Proceed');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `regulatory_flags` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Flags');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'Low|Medium|High|Critical');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `source_system_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `target_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Target Completion Date');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `target_entity_lei` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `target_entity_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{18}[0-9]{2}$');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `target_entity_lei` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `third_party_advisor` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor Name');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `total_item_count` SET TAGS ('dbx_business_glossary_term' = 'Total Due Diligence (DD) Checklist Item Count');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `workstream_type` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Workstream Type');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ALTER COLUMN `workstream_type` SET TAGS ('dbx_value_regex' = 'ODD|FDD|CDD|Legal DD|ESG DD|Tax DD');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` SET TAGS ('dbx_subdomain' = 'diligence_execution');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `dd_checklist_item_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Checklist Item ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `dd_checklist_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Checklist ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `dd_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `dd_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `dd_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewer ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `reviewer_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewer ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `advisor_report_reference` SET TAGS ('dbx_business_glossary_term' = 'Advisor Report Reference');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `advisor_report_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `dd_checklist_item_category` SET TAGS ('dbx_business_glossary_term' = 'Checklist Item Category');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `completed_date` SET TAGS ('dbx_business_glossary_term' = 'Item Completed Date');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `data_room_reference` SET TAGS ('dbx_business_glossary_term' = 'Data Room Document Reference');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `data_room_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `dd_type` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Type');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Item Due Date');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `effront_item_code` SET TAGS ('dbx_business_glossary_term' = 'eFront Item ID');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `escalation_date` SET TAGS ('dbx_business_glossary_term' = 'Escalation Date');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `escalation_reason` SET TAGS ('dbx_business_glossary_term' = 'Escalation Reason');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `escalation_reason` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `esg_dimension` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Dimension');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `esg_dimension` SET TAGS ('dbx_value_regex' = 'environmental|social|governance|not_applicable');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `extended_due_date` SET TAGS ('dbx_business_glossary_term' = 'Extended Due Date');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `finding_summary` SET TAGS ('dbx_business_glossary_term' = 'Finding Summary');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `finding_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `guidance_notes` SET TAGS ('dbx_business_glossary_term' = 'Analyst Guidance Notes');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `is_ic_blocking` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Blocking Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Item Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `is_recurring` SET TAGS ('dbx_business_glossary_term' = 'Recurring Item Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `item_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Item Reference Code');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `item_reference_code` SET TAGS ('dbx_value_regex' = '^DD-[A-Z]{2,6}-[0-9]{4,8}$');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `item_sequence` SET TAGS ('dbx_business_glossary_term' = 'Item Sequence Number');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `item_status` SET TAGS ('dbx_business_glossary_term' = 'Checklist Item Status');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Item Priority');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `question_text` SET TAGS ('dbx_business_glossary_term' = 'Diligence Question Text');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `question_text` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `recurrence_frequency` SET TAGS ('dbx_business_glossary_term' = 'Recurrence Frequency');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `recurrence_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly|ad_hoc');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `remediation_notes` SET TAGS ('dbx_business_glossary_term' = 'Remediation Notes');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `remediation_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `remediation_required` SET TAGS ('dbx_business_glossary_term' = 'Remediation Required Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `response_received_date` SET TAGS ('dbx_business_glossary_term' = 'Response Received Date');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `response_text` SET TAGS ('dbx_business_glossary_term' = 'Response Text');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `response_text` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `response_type` SET TAGS ('dbx_business_glossary_term' = 'Expected Response Type');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `response_type` SET TAGS ('dbx_value_regex' = 'document|text|numeric|date|yes_no|multi_select');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `reviewed_date` SET TAGS ('dbx_business_glossary_term' = 'Reviewed Date');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Item Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'high|medium|low|not_applicable');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `source_template_code` SET TAGS ('dbx_business_glossary_term' = 'Source Template Code');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `sub_category` SET TAGS ('dbx_business_glossary_term' = 'Checklist Item Sub-Category');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `template_version` SET TAGS ('dbx_business_glossary_term' = 'Template Version');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `template_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+$');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `third_party_advisor` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor Name');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `waiver_approved` SET TAGS ('dbx_business_glossary_term' = 'Waiver Approved Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `waiver_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Waiver Approved By');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `waiver_rationale` SET TAGS ('dbx_business_glossary_term' = 'Waiver Rationale');
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ALTER COLUMN `waiver_rationale` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` SET TAGS ('dbx_subdomain' = 'risk_assessment');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `dd_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Finding ID');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Asset Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `rule_id` SET TAGS ('dbx_business_glossary_term' = 'Rule Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `advisor_report_reference` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor Report Reference');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'private_equity|real_estate|infrastructure|natural_resources|credit|public_equities');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `deal_currency` SET TAGS ('dbx_business_glossary_term' = 'Deal Currency Code');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `deal_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `deal_impact_type` SET TAGS ('dbx_business_glossary_term' = 'Deal Impact Type');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `deal_impact_type` SET TAGS ('dbx_value_regex' = 'deal_breaker|price_adjustment|condition_precedent|warranty|indemnity|monitoring');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `esg_sub_theme` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Sub-Theme');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `esg_theme` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Theme');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `esg_theme` SET TAGS ('dbx_value_regex' = 'environmental|social|governance|none');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `finding_category` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Finding Category');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `finding_description` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Finding Description');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `finding_reference` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Finding Reference Number');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `finding_reference` SET TAGS ('dbx_value_regex' = '^DD-FND-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `finding_status` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Finding Status');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `finding_status` SET TAGS ('dbx_value_regex' = 'open|under_review|remediated|accepted|escalated|closed');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `finding_title` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Finding Title');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `follow_up_due_date` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Due Date');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `follow_up_required` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Required Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `geography` SET TAGS ('dbx_business_glossary_term' = 'Investment Geography');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `geography` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `ic_disposition` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Disposition');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `ic_disposition` SET TAGS ('dbx_value_regex' = 'proceed|proceed_with_conditions|escalate|reject|defer');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `identified_by` SET TAGS ('dbx_business_glossary_term' = 'Finding Identified By');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `identified_date` SET TAGS ('dbx_business_glossary_term' = 'Finding Identified Date');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `impact_confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Financial Impact Confidence Level');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `impact_confidence_level` SET TAGS ('dbx_value_regex' = 'high|medium|low|unquantifiable');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `impact_currency` SET TAGS ('dbx_business_glossary_term' = 'Financial Impact Currency Code');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `impact_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `indemnity_amount` SET TAGS ('dbx_business_glossary_term' = 'Indemnity Amount');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `indemnity_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `investment_stage` SET TAGS ('dbx_business_glossary_term' = 'Investment Stage at Finding');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `investment_stage` SET TAGS ('dbx_value_regex' = 'screening|initial_dd|full_dd|final_dd|post_ic|post_acquisition');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `is_deal_condition` SET TAGS ('dbx_business_glossary_term' = 'Deal Condition Precedent Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `is_ic_reportable` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Reportable Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `likelihood_rating` SET TAGS ('dbx_business_glossary_term' = 'Finding Likelihood Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `likelihood_rating` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `potential_financial_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Potential Financial Impact Amount');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `potential_financial_impact_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `price_adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Price Adjustment Amount');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `price_adjustment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `recommendation` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Finding Recommendation');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `regulatory_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Breach Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `remediation_completed_date` SET TAGS ('dbx_business_glossary_term' = 'Remediation Completed Date');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `remediation_due_date` SET TAGS ('dbx_business_glossary_term' = 'Remediation Due Date');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `remediation_notes` SET TAGS ('dbx_business_glossary_term' = 'Remediation Notes');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `remediation_owner` SET TAGS ('dbx_business_glossary_term' = 'Remediation Owner');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `reviewed_by` SET TAGS ('dbx_business_glossary_term' = 'Finding Reviewed By');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Finding Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `root_cause` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Finding Root Cause');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `severity_rating` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Finding Severity Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `severity_rating` SET TAGS ('dbx_value_regex' = 'critical|major|minor|informational');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `source_system_finding_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Finding ID');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `third_party_advisor` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor Name');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `workstream_type` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Workstream Type');
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ALTER COLUMN `workstream_type` SET TAGS ('dbx_value_regex' = 'financial|operational|legal|commercial|esg');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` SET TAGS ('dbx_subdomain' = 'risk_assessment');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `dd_risk_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Risk Assessment ID');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Pipeline ID');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager / General Partner (GP) ID');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager / General Partner (GP) ID');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Pipeline ID');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `prior_assessment_dd_risk_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Risk Assessment ID');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Stress Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `advisor_report_reference` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor Report Reference');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `advisor_report_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Date');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `assessment_reference` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Risk Assessment Reference Number');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `assessment_reference` SET TAGS ('dbx_value_regex' = '^DD-RA-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Lifecycle Status');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'draft|in_progress|under_review|completed|approved|withdrawn');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `assessment_version` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Version Number');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Proposed Capital Commitment Amount');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `commitment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Commitment Currency (ISO 4217)');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `conditions_precedent` SET TAGS ('dbx_business_glossary_term' = 'Conditions Precedent to Investment');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `conditions_precedent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `dd_type` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Type');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `dd_type` SET TAGS ('dbx_value_regex' = 'ODD|FDD|CDD|legal|ESG|integrated');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `esg_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `esg_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium_low|medium|medium_high|high');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `esg_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Risk Score');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `financial_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Financial Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `financial_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium_low|medium|medium_high|high');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `financial_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Financial Due Diligence (FDD) Risk Score');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `ic_decision` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `ic_decision` SET TAGS ('dbx_value_regex' = 'approved|approved_with_conditions|deferred|rejected');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `ic_decision_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision Date');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `ic_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Recommendation');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `ic_recommendation` SET TAGS ('dbx_value_regex' = 'proceed|proceed_with_conditions|further_diligence|decline');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `key_mitigants` SET TAGS ('dbx_business_glossary_term' = 'Key Risk Mitigants Summary');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `key_mitigants` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `key_risk_factors` SET TAGS ('dbx_business_glossary_term' = 'Key Risk Factors Summary');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `key_risk_factors` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `kyc_aml_status` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer / Anti-Money Laundering (KYC/AML) Status');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `kyc_aml_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|cleared|flagged|escalated');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `lead_analyst` SET TAGS ('dbx_business_glossary_term' = 'Lead Due Diligence (DD) Analyst');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `legal_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Legal Due Diligence Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `legal_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium_low|medium|medium_high|high');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `legal_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Legal Due Diligence Risk Score');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `management_quality_rating` SET TAGS ('dbx_business_glossary_term' = 'Management Quality Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `management_quality_rating` SET TAGS ('dbx_value_regex' = 'low|medium_low|medium|medium_high|high');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `management_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Management Quality Score');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `market_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Market Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `market_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium_low|medium|medium_high|high');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `market_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Market Risk Score');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `nda_executed` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Executed Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `operational_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Operational Due Diligence (ODD) Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `operational_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium_low|medium|medium_high|high');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `operational_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Operational Due Diligence (ODD) Risk Score');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `overall_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Overall Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `overall_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium_low|medium|medium_high|high');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `overall_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Overall Risk Score');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `sanctions_screening_status` SET TAGS ('dbx_business_glossary_term' = 'Sanctions Screening Status');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `sanctions_screening_status` SET TAGS ('dbx_value_regex' = 'clear|match_pending_review|escalated');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `target_domicile` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Domicile Country');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `target_domicile` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `target_entity_lei` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `target_entity_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{18}[0-9]{2}$');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Legal Name');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `target_irr_pct` SET TAGS ('dbx_business_glossary_term' = 'Target Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `target_irr_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `target_moic` SET TAGS ('dbx_business_glossary_term' = 'Target Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `target_moic` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `third_party_advisor` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor Name');
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` SET TAGS ('dbx_subdomain' = 'advisor_management');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `advisor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Advisor Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `dd_workstream_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Workstream ID');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `internal_deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Internal Deal ID');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Internal Deal ID');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `advisor_firm_lei` SET TAGS ('dbx_business_glossary_term' = 'Advisor Firm Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `advisor_firm_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{18}[0-9]{2}$');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `advisor_firm_name` SET TAGS ('dbx_business_glossary_term' = 'Advisor Firm Name');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `advisor_firm_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `agreed_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Agreed Fee Amount');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `agreed_fee_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'private_equity|real_estate|infrastructure|natural_resources|credit|public_equities');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `conflict_of_interest_checked` SET TAGS ('dbx_business_glossary_term' = 'Conflict of Interest Checked Flag');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `conflict_of_interest_notes` SET TAGS ('dbx_business_glossary_term' = 'Conflict of Interest Notes');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `conflict_of_interest_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `dd_report_due_date` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Report Due Date');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `dd_report_received_date` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Report Received Date');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `deal_geography` SET TAGS ('dbx_business_glossary_term' = 'Deal Geography (ISO Country Code)');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `deal_geography` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `effront_engagement_ref` SET TAGS ('dbx_business_glossary_term' = 'eFront Engagement Reference');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `engagement_channel` SET TAGS ('dbx_business_glossary_term' = 'Engagement Channel');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `engagement_channel` SET TAGS ('dbx_value_regex' = 'direct|intermediated|panel_rotation|competitive_tender');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `engagement_end_date` SET TAGS ('dbx_business_glossary_term' = 'Engagement End Date');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `engagement_letter_date` SET TAGS ('dbx_business_glossary_term' = 'Engagement Letter Date');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `engagement_reference` SET TAGS ('dbx_business_glossary_term' = 'Engagement Reference Number');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `engagement_reference` SET TAGS ('dbx_value_regex' = '^ENG-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `engagement_start_date` SET TAGS ('dbx_business_glossary_term' = 'Engagement Start Date');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `engagement_status` SET TAGS ('dbx_business_glossary_term' = 'Engagement Status');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `engagement_status` SET TAGS ('dbx_value_regex' = 'draft|active|on_hold|completed|terminated|cancelled');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `engagement_type` SET TAGS ('dbx_business_glossary_term' = 'Engagement Type');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `engagement_type` SET TAGS ('dbx_value_regex' = 'legal|financial_dd|commercial_dd|technical|environmental_esg|other');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `fee_cap_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Cap Amount');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `fee_cap_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `fee_currency` SET TAGS ('dbx_business_glossary_term' = 'Fee Currency Code');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `fee_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `fee_structure_type` SET TAGS ('dbx_business_glossary_term' = 'Fee Structure Type');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `fee_structure_type` SET TAGS ('dbx_value_regex' = 'fixed_fee|hourly_rate|capped_fee|success_fee|retainer|blended');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `fee_structure_type` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `hourly_rate` SET TAGS ('dbx_business_glossary_term' = 'Hourly Rate');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `hourly_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `ic_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Required Flag');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `insurance_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Insurance Expiry Date');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `insurance_verified` SET TAGS ('dbx_business_glossary_term' = 'Professional Indemnity Insurance Verified Flag');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `internal_deal_lead` SET TAGS ('dbx_business_glossary_term' = 'Internal Deal Lead');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `invoiced_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Invoiced Amount');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `invoiced_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `kyc_aml_status` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer / Anti-Money Laundering (KYC/AML) Status');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `kyc_aml_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|approved|rejected|expired');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `lead_advisor_email` SET TAGS ('dbx_business_glossary_term' = 'Lead Advisor Email Address');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `lead_advisor_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `lead_advisor_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `lead_advisor_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `lead_advisor_name` SET TAGS ('dbx_business_glossary_term' = 'Lead Advisor Name');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `lead_advisor_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `mandate_scope` SET TAGS ('dbx_business_glossary_term' = 'Engagement Mandate Scope');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `mandate_scope` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `nda_executed` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Executed Flag');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `nda_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Execution Date');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Paid Amount');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `paid_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `preferred_panel_advisor` SET TAGS ('dbx_business_glossary_term' = 'Preferred Panel Advisor Flag');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `report_quality_rating` SET TAGS ('dbx_business_glossary_term' = 'Report Quality Rating');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `report_quality_rating` SET TAGS ('dbx_value_regex' = 'excellent|good|satisfactory|below_expectations|unsatisfactory');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `rfp_conducted` SET TAGS ('dbx_business_glossary_term' = 'Request for Proposal (RFP) Conducted Flag');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Engagement Termination Date');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason');
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'deal_aborted|scope_complete|advisor_performance|budget_constraint|conflict_identified|other');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` SET TAGS ('dbx_subdomain' = 'advisor_management');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `advisor_report_id` SET TAGS ('dbx_business_glossary_term' = 'Advisor Report ID');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `superseded_by_report_advisor_report_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Advisor Report ID');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `advisor_firm_name` SET TAGS ('dbx_business_glossary_term' = 'Advisor Firm Name');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `advisor_firm_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `advisor_lei` SET TAGS ('dbx_business_glossary_term' = 'Advisor Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `advisor_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{18}[0-9]{2}$');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'Private Equity|Real Estate|Infrastructure|Natural Resources|Credit|Public Equities');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `conditions_and_recommendations` SET TAGS ('dbx_business_glossary_term' = 'Conditions and Recommendations');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `conditions_and_recommendations` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `confidentiality_classification` SET TAGS ('dbx_business_glossary_term' = 'Report Confidentiality Classification');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `confidentiality_classification` SET TAGS ('dbx_value_regex' = 'Strictly Confidential|Confidential|Internal|Restricted');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `data_room_location` SET TAGS ('dbx_business_glossary_term' = 'Data Room Location');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `data_room_location` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `dd_scope` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Scope');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `dd_scope` SET TAGS ('dbx_value_regex' = 'Direct Investment|Co-Investment|Fund Investment|Manager Selection|Secondary');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `document_format` SET TAGS ('dbx_business_glossary_term' = 'Report Document Format');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `document_format` SET TAGS ('dbx_value_regex' = 'PDF|Word|Excel|PowerPoint');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `engagement_letter_reference` SET TAGS ('dbx_business_glossary_term' = 'Engagement Letter Reference');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `engagement_letter_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `esg_issues_identified` SET TAGS ('dbx_business_glossary_term' = 'ESG Issues Identified Flag');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'ESG Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `esg_rating` SET TAGS ('dbx_value_regex' = 'Low Risk|Medium Risk|High Risk|Not Assessed');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Advisor Fee Amount');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `fee_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `fee_currency` SET TAGS ('dbx_business_glossary_term' = 'Advisor Fee Currency');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `fee_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `follow_up_due_date` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Due Date');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `follow_up_required` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Required Flag');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `ic_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Date');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `ic_submission_included` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Included Flag');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `internal_review_date` SET TAGS ('dbx_business_glossary_term' = 'Internal Review Completion Date');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `internal_review_notes` SET TAGS ('dbx_business_glossary_term' = 'Internal Review Notes');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `internal_review_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `internal_reviewer_name` SET TAGS ('dbx_business_glossary_term' = 'Internal Reviewer Name');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `invoice_reference` SET TAGS ('dbx_business_glossary_term' = 'Advisor Invoice Reference');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `invoice_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `key_findings_summary` SET TAGS ('dbx_business_glossary_term' = 'Key Findings Summary');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `key_findings_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `lead_advisor_name` SET TAGS ('dbx_business_glossary_term' = 'Lead Advisor Name');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `lead_advisor_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `material_issues_count` SET TAGS ('dbx_business_glossary_term' = 'Material Issues Count');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `nda_reference` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Reference');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `nda_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `overall_conclusion` SET TAGS ('dbx_business_glossary_term' = 'Overall Report Conclusion');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `overall_conclusion` SET TAGS ('dbx_value_regex' = 'Satisfactory|Satisfactory with Conditions|Unsatisfactory|Inconclusive');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `overall_conclusion` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `page_count` SET TAGS ('dbx_business_glossary_term' = 'Report Page Count');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `regulatory_issues_identified` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Issues Identified Flag');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `reliance_letter_reference` SET TAGS ('dbx_business_glossary_term' = 'Reliance Letter Reference');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `reliance_letter_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `reliance_permitted` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Reliance Permitted Flag');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `report_date` SET TAGS ('dbx_business_glossary_term' = 'Report Date');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `report_period_end` SET TAGS ('dbx_business_glossary_term' = 'Report Analysis Period End Date');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `report_period_start` SET TAGS ('dbx_business_glossary_term' = 'Report Analysis Period Start Date');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `report_reference` SET TAGS ('dbx_business_glossary_term' = 'Advisor Report Reference Number');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `report_reference` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,6}-RPT-[0-9]{4}-[0-9]{4,6}$');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `report_status` SET TAGS ('dbx_business_glossary_term' = 'Advisor Report Status');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `report_status` SET TAGS ('dbx_value_regex' = 'Draft|Preliminary|Final|Superseded|Withdrawn');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `report_subtype` SET TAGS ('dbx_business_glossary_term' = 'Advisor Report Subtype');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `report_title` SET TAGS ('dbx_business_glossary_term' = 'Advisor Report Title');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `report_title` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `report_type` SET TAGS ('dbx_business_glossary_term' = 'Advisor Report Type');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `report_version` SET TAGS ('dbx_business_glossary_term' = 'Advisor Report Version');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `report_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+(.[0-9]+)?$');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Advisor Report Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'Low|Medium|High|Critical');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Report Submission Date');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`advisor_report` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` SET TAGS ('dbx_subdomain' = 'risk_assessment');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `odd_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Operational Due Diligence (ODD) Assessment ID');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Operational Due Diligence (ODD) Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) / External Fund Manager ID');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `lead_odd_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Operational Due Diligence (ODD) Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) / External Fund Manager ID');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `manager_mandate_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Mandate Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `actual_completion_date` SET TAGS ('dbx_business_glossary_term' = 'ODD Actual Completion Date');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `assessment_date` SET TAGS ('dbx_business_glossary_term' = 'ODD Assessment Date');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `assessment_reference` SET TAGS ('dbx_business_glossary_term' = 'Operational Due Diligence (ODD) Assessment Reference Number');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `assessment_reference` SET TAGS ('dbx_value_regex' = '^ODD-[0-9]{4}-[0-9]{5}$');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'ODD Assessment Status');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'draft|in_progress|under_review|completed|cancelled');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `assessment_type` SET TAGS ('dbx_business_glossary_term' = 'ODD Assessment Type');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `assessment_type` SET TAGS ('dbx_value_regex' = 'initial|re_up|periodic|event_driven|ad_hoc');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `auditor_name` SET TAGS ('dbx_business_glossary_term' = 'External Auditor Name');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `aum_at_assessment` SET TAGS ('dbx_business_glossary_term' = 'Assets Under Management (AUM) at Assessment Date');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `aum_at_assessment` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `aum_currency` SET TAGS ('dbx_business_glossary_term' = 'Assets Under Management (AUM) Currency');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `aum_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `bcp_tested_flag` SET TAGS ('dbx_business_glossary_term' = 'Business Continuity Plan (BCP) Tested Flag');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `compliance_aml_rating` SET TAGS ('dbx_business_glossary_term' = 'Compliance, Anti-Money Laundering (AML), and Know Your Customer (KYC) ODD Rating');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `compliance_aml_rating` SET TAGS ('dbx_value_regex' = 'satisfactory|acceptable|marginal|unsatisfactory');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `custodian_name` SET TAGS ('dbx_business_glossary_term' = 'Custodian Name');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `cybersecurity_rating` SET TAGS ('dbx_business_glossary_term' = 'Cybersecurity and Information Security ODD Rating');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `cybersecurity_rating` SET TAGS ('dbx_value_regex' = 'satisfactory|acceptable|marginal|unsatisfactory');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `ddq_received_date` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence Questionnaire (DDQ) Received Date');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `fund_admin_rating` SET TAGS ('dbx_business_glossary_term' = 'Fund Administration and Back-Office ODD Rating');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `fund_admin_rating` SET TAGS ('dbx_value_regex' = 'satisfactory|acceptable|marginal|unsatisfactory');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `fund_administrator_name` SET TAGS ('dbx_business_glossary_term' = 'Fund Administrator Name');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `governance_rating` SET TAGS ('dbx_business_glossary_term' = 'Governance and Organizational Structure ODD Rating');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `governance_rating` SET TAGS ('dbx_value_regex' = 'satisfactory|acceptable|marginal|unsatisfactory');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `independent_admin_flag` SET TAGS ('dbx_business_glossary_term' = 'Independent Fund Administrator Flag');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `initiation_date` SET TAGS ('dbx_business_glossary_term' = 'ODD Assessment Initiation Date');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `key_person_risk_flag` SET TAGS ('dbx_business_glossary_term' = 'Key Person Risk Flag');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `legal_counsel_name` SET TAGS ('dbx_business_glossary_term' = 'External Legal Counsel Name');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `litigation_flag` SET TAGS ('dbx_business_glossary_term' = 'Material Litigation Flag');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `material_findings_summary` SET TAGS ('dbx_business_glossary_term' = 'Material ODD Findings Summary');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `material_findings_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled ODD Review Date');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `number_of_investment_professionals` SET TAGS ('dbx_business_glossary_term' = 'Number of Investment Professionals');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `number_of_operations_staff` SET TAGS ('dbx_business_glossary_term' = 'Number of Operations and Back-Office Staff');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `odd_recommendation` SET TAGS ('dbx_business_glossary_term' = 'ODD Investment Recommendation');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `odd_recommendation` SET TAGS ('dbx_value_regex' = 'proceed|proceed_with_conditions|defer|decline');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `onsite_visit_conducted` SET TAGS ('dbx_business_glossary_term' = 'On-Site Visit Conducted Flag');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `onsite_visit_date` SET TAGS ('dbx_business_glossary_term' = 'On-Site Visit Date');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `overall_odd_rating` SET TAGS ('dbx_business_glossary_term' = 'Overall Operational Due Diligence (ODD) Rating');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `overall_odd_rating` SET TAGS ('dbx_value_regex' = 'satisfactory|acceptable|marginal|unsatisfactory');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `prime_broker_names` SET TAGS ('dbx_business_glossary_term' = 'Prime Broker Names');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `regulatory_action_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Action Flag');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `remediation_deadline` SET TAGS ('dbx_business_glossary_term' = 'Remediation Deadline Date');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `remediation_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Remediation Required Flag');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `risk_management_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Management Framework ODD Rating');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `risk_management_rating` SET TAGS ('dbx_value_regex' = 'satisfactory|acceptable|marginal|unsatisfactory');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `soc2_report_available` SET TAGS ('dbx_business_glossary_term' = 'SOC 2 Report Availability Flag');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `target_completion_date` SET TAGS ('dbx_business_glossary_term' = 'ODD Target Completion Date');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `technology_systems_rating` SET TAGS ('dbx_business_glossary_term' = 'Technology and Systems ODD Rating');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `technology_systems_rating` SET TAGS ('dbx_value_regex' = 'satisfactory|acceptable|marginal|unsatisfactory');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `third_party_odd_provider` SET TAGS ('dbx_business_glossary_term' = 'Third-Party ODD Service Provider');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `trade_execution_rating` SET TAGS ('dbx_business_glossary_term' = 'Trade Execution and Settlement ODD Rating');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `trade_execution_rating` SET TAGS ('dbx_value_regex' = 'satisfactory|acceptable|marginal|unsatisfactory');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `valuation_rating` SET TAGS ('dbx_business_glossary_term' = 'Valuation Policy and Controls ODD Rating');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `valuation_rating` SET TAGS ('dbx_value_regex' = 'satisfactory|acceptable|marginal|unsatisfactory');
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ALTER COLUMN `years_in_operation` SET TAGS ('dbx_business_glossary_term' = 'Manager Years in Operation');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` SET TAGS ('dbx_subdomain' = 'risk_assessment');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `fdd_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Financial Due Diligence (FDD) Assessment ID');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Financial Due Diligence (FDD) Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `fee_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Fee Benchmark Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `lead_fdd_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Financial Due Diligence (FDD) Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `accounting_standard` SET TAGS ('dbx_business_glossary_term' = 'Accounting Standard Applied');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `accounting_standard` SET TAGS ('dbx_value_regex' = 'IFRS|US_GAAP|Local_GAAP|Other');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `adjusted_net_debt` SET TAGS ('dbx_business_glossary_term' = 'Adjusted Net Debt');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `adjusted_net_debt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Financial Due Diligence (FDD) Assessment Date');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `assessment_reference` SET TAGS ('dbx_business_glossary_term' = 'Financial Due Diligence (FDD) Assessment Reference');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `assessment_reference` SET TAGS ('dbx_value_regex' = '^FDD-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'Financial Due Diligence (FDD) Assessment Status');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'draft|in_progress|under_review|completed|withdrawn');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `audit_firm` SET TAGS ('dbx_business_glossary_term' = 'Target Audit Firm Name');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `audit_opinion_type` SET TAGS ('dbx_business_glossary_term' = 'Audit Opinion Type');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `audit_opinion_type` SET TAGS ('dbx_value_regex' = 'unqualified|qualified|adverse|disclaimer');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `capex_growth` SET TAGS ('dbx_business_glossary_term' = 'Growth Capital Expenditure (CapEx)');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `capex_growth` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `capex_maintenance` SET TAGS ('dbx_business_glossary_term' = 'Maintenance Capital Expenditure (CapEx)');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `capex_maintenance` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `conditions_and_recommendations` SET TAGS ('dbx_business_glossary_term' = 'Financial Due Diligence (FDD) Conditions and Recommendations');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `conditions_and_recommendations` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `contingent_liabilities_amount` SET TAGS ('dbx_business_glossary_term' = 'Contingent Liabilities Estimated Amount');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `contingent_liabilities_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `contingent_liabilities_identified` SET TAGS ('dbx_business_glossary_term' = 'Contingent Liabilities Identified Flag');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `data_room_reference` SET TAGS ('dbx_business_glossary_term' = 'Financial Due Diligence (FDD) Data Room Reference');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `ebitda_margin_pct` SET TAGS ('dbx_business_glossary_term' = 'Normalized Earnings Before Interest Taxes Depreciation and Amortization (EBITDA) Margin Percentage');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `ebitda_margin_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `ebitda_normalization_total` SET TAGS ('dbx_business_glossary_term' = 'Total Earnings Before Interest Taxes Depreciation and Amortization (EBITDA) Normalization Adjustments');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `ebitda_normalization_total` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `esg_financial_materiality_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Financial Materiality Flag');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `financial_controls_rating` SET TAGS ('dbx_business_glossary_term' = 'Financial Controls Rating');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `financial_controls_rating` SET TAGS ('dbx_value_regex' = 'strong|adequate|weak|deficient');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `financial_model_version` SET TAGS ('dbx_business_glossary_term' = 'Financial Model Version Reference');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `financial_statements_period_end` SET TAGS ('dbx_business_glossary_term' = 'Financial Statements Analysis Period End Date');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `financial_statements_period_start` SET TAGS ('dbx_business_glossary_term' = 'Financial Statements Analysis Period Start Date');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `ic_submission_ready` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Ready Flag');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `key_financial_risks_summary` SET TAGS ('dbx_business_glossary_term' = 'Key Financial Risks Summary');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `key_financial_risks_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `management_accounts_quality` SET TAGS ('dbx_business_glossary_term' = 'Management Accounts Quality Rating');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `management_accounts_quality` SET TAGS ('dbx_value_regex' = 'high|acceptable|low|unacceptable');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `net_debt_adjustment_notes` SET TAGS ('dbx_business_glossary_term' = 'Net Debt Reconciliation Adjustment Notes');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `net_debt_adjustment_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `normalized_ebitda` SET TAGS ('dbx_business_glossary_term' = 'Normalized Earnings Before Interest Taxes Depreciation and Amortization (EBITDA)');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `normalized_ebitda` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `normalized_working_capital` SET TAGS ('dbx_business_glossary_term' = 'Normalized Working Capital');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `normalized_working_capital` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `overall_fdd_rating` SET TAGS ('dbx_business_glossary_term' = 'Overall Financial Due Diligence (FDD) Rating');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `overall_fdd_rating` SET TAGS ('dbx_value_regex' = 'satisfactory|conditional|unsatisfactory');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `pension_deficit` SET TAGS ('dbx_business_glossary_term' = 'Pension Deficit');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `pension_deficit` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `qoe_findings_summary` SET TAGS ('dbx_business_glossary_term' = 'Quality of Earnings (QoE) Findings Summary');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `qoe_findings_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `qoe_rating` SET TAGS ('dbx_business_glossary_term' = 'Quality of Earnings (QoE) Rating');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `qoe_rating` SET TAGS ('dbx_value_regex' = 'high|acceptable|low|unacceptable');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `reported_ebitda` SET TAGS ('dbx_business_glossary_term' = 'Reported Earnings Before Interest Taxes Depreciation and Amortization (EBITDA)');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `reported_ebitda` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `reported_net_debt` SET TAGS ('dbx_business_glossary_term' = 'Reported Net Debt');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `reported_net_debt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `reported_revenue` SET TAGS ('dbx_business_glossary_term' = 'Reported Revenue');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `reported_revenue` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `reporting_currency` SET TAGS ('dbx_business_glossary_term' = 'Financial Due Diligence (FDD) Reporting Currency');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `reporting_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `revenue_cagr_pct` SET TAGS ('dbx_business_glossary_term' = 'Revenue Compound Annual Growth Rate (CAGR) Percentage');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `revenue_cagr_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `revenue_concentration_risk` SET TAGS ('dbx_business_glossary_term' = 'Revenue Concentration Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `revenue_concentration_risk` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `sign_off_date` SET TAGS ('dbx_business_glossary_term' = 'Financial Due Diligence (FDD) Sign-Off Date');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `tax_structure_risk` SET TAGS ('dbx_business_glossary_term' = 'Tax Structure Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `tax_structure_risk` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `third_party_advisor_firm` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Financial Due Diligence (FDD) Advisor Firm');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `third_party_report_date` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Financial Due Diligence (FDD) Report Date');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `working_capital_findings_summary` SET TAGS ('dbx_business_glossary_term' = 'Working Capital Analysis Findings Summary');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `working_capital_findings_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `working_capital_peg_basis` SET TAGS ('dbx_business_glossary_term' = 'Working Capital Peg Basis');
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ALTER COLUMN `working_capital_peg_basis` SET TAGS ('dbx_value_regex' = 'trailing_12_month_average|trailing_3_year_average|negotiated|other');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` SET TAGS ('dbx_subdomain' = 'risk_assessment');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `cdd_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Commercial Due Diligence (CDD) Assessment ID');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `country_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Country Outlook Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `lead_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `sector_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Sector Outlook Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `advisor_report_date` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor Report Date');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `assessment_date` SET TAGS ('dbx_business_glossary_term' = 'CDD Assessment Date');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `assessment_reference` SET TAGS ('dbx_business_glossary_term' = 'Commercial Due Diligence (CDD) Assessment Reference');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `assessment_reference` SET TAGS ('dbx_value_regex' = '^CDD-[0-9]{4}-[A-Z0-9]{6,12}$');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'Commercial Due Diligence (CDD) Assessment Status');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'draft|in_progress|under_review|completed|superseded|cancelled');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `assessment_version` SET TAGS ('dbx_business_glossary_term' = 'CDD Assessment Version Number');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'private_equity|real_estate|infrastructure|natural_resources|credit|public_equity');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `cdd_scope_notes` SET TAGS ('dbx_business_glossary_term' = 'Commercial Due Diligence (CDD) Scope Notes');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `cdd_scope_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `competitive_intensity` SET TAGS ('dbx_business_glossary_term' = 'Competitive Intensity');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `competitive_intensity` SET TAGS ('dbx_value_regex' = 'low|moderate|high|very_high');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `competitive_moat_assessment` SET TAGS ('dbx_business_glossary_term' = 'Competitive Moat Assessment');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `competitive_moat_assessment` SET TAGS ('dbx_value_regex' = 'wide|narrow|none');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `competitive_position_rating` SET TAGS ('dbx_business_glossary_term' = 'Competitive Position Rating');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `competitive_position_rating` SET TAGS ('dbx_value_regex' = 'market_leader|strong_challenger|niche_player|weak_position');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'CDD Assessment Completion Date');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `contracted_revenue_pct` SET TAGS ('dbx_business_glossary_term' = 'Contracted Revenue (Percent of Total Revenue)');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `contracted_revenue_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `customer_churn_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Customer Churn Rate (Percent)');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `customer_churn_rate_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `data_room_reference` SET TAGS ('dbx_business_glossary_term' = 'Data Room Reference');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `data_room_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `esg_commercial_risk_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Commercial Risk Flag');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `growth_strategy_assessment` SET TAGS ('dbx_business_glossary_term' = 'Growth Strategy Assessment');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `growth_strategy_assessment` SET TAGS ('dbx_value_regex' = 'organic|acquisitive|hybrid|turnaround');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `ic_submission_ready` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Ready Flag');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `investment_thesis_alignment` SET TAGS ('dbx_business_glossary_term' = 'Investment Thesis Alignment');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `investment_thesis_alignment` SET TAGS ('dbx_value_regex' = 'strong|moderate|weak|misaligned');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `key_commercial_opportunities` SET TAGS ('dbx_business_glossary_term' = 'Key Commercial Opportunities Summary');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `key_commercial_opportunities` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `key_commercial_risks` SET TAGS ('dbx_business_glossary_term' = 'Key Commercial Risks Summary');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `key_commercial_risks` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `macro_sensitivity_rating` SET TAGS ('dbx_business_glossary_term' = 'Macroeconomic Sensitivity Rating');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `macro_sensitivity_rating` SET TAGS ('dbx_value_regex' = 'low|moderate|high|very_high');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `management_quality_rating` SET TAGS ('dbx_business_glossary_term' = 'Management Quality Rating');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `management_quality_rating` SET TAGS ('dbx_value_regex' = 'strong|satisfactory|cautionary|unsatisfactory');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `market_cycle_stage` SET TAGS ('dbx_business_glossary_term' = 'Market Cycle Stage');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `market_cycle_stage` SET TAGS ('dbx_value_regex' = 'early_growth|growth|mature|late_cycle|distressed');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `market_growth_assessment` SET TAGS ('dbx_business_glossary_term' = 'Market Growth Assessment');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `market_growth_assessment` SET TAGS ('dbx_value_regex' = 'high_growth|moderate_growth|stable|declining|cyclical');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `market_growth_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Market Growth Rate (Percent)');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `market_growth_rate_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `market_share_pct` SET TAGS ('dbx_business_glossary_term' = 'Market Share (Percent)');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `market_share_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `market_size_usd_mm` SET TAGS ('dbx_business_glossary_term' = 'Total Addressable Market (TAM) Size (USD Millions)');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `market_size_usd_mm` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `number_of_competitors` SET TAGS ('dbx_business_glossary_term' = 'Number of Identified Competitors');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `overall_cdd_rating` SET TAGS ('dbx_business_glossary_term' = 'Overall Commercial Due Diligence (CDD) Rating');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `overall_cdd_rating` SET TAGS ('dbx_value_regex' = 'strong|satisfactory|cautionary|unsatisfactory');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `pricing_power_assessment` SET TAGS ('dbx_business_glossary_term' = 'Pricing Power Assessment');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `pricing_power_assessment` SET TAGS ('dbx_value_regex' = 'strong|moderate|limited|none');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `regulatory_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `regulatory_risk_rating` SET TAGS ('dbx_value_regex' = 'low|moderate|high|critical');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `revenue_base_year` SET TAGS ('dbx_business_glossary_term' = 'Revenue Base Year');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `revenue_visibility` SET TAGS ('dbx_business_glossary_term' = 'Revenue Visibility');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `revenue_visibility` SET TAGS ('dbx_value_regex' = 'contracted|recurring|transactional|project_based');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `supply_chain_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Supply Chain Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `supply_chain_risk_rating` SET TAGS ('dbx_value_regex' = 'low|moderate|high|critical');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `target_geography` SET TAGS ('dbx_business_glossary_term' = 'Target Geography (ISO 3166-1 Alpha-3)');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `target_geography` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `target_sector` SET TAGS ('dbx_business_glossary_term' = 'Target Sector');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `technology_disruption_risk` SET TAGS ('dbx_business_glossary_term' = 'Technology Disruption Risk');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `technology_disruption_risk` SET TAGS ('dbx_value_regex' = 'low|moderate|high|critical');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `third_party_advisor` SET TAGS ('dbx_business_glossary_term' = 'Third-Party CDD Advisor');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `top_5_customer_concentration_pct` SET TAGS ('dbx_business_glossary_term' = 'Top 5 Customer Concentration (Percent of Revenue)');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `top_5_customer_concentration_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `top_customer_concentration_pct` SET TAGS ('dbx_business_glossary_term' = 'Top Customer Concentration (Percent of Revenue)');
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ALTER COLUMN `top_customer_concentration_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` SET TAGS ('dbx_subdomain' = 'risk_assessment');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `esg_dd_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Due Diligence (DD) Assessment ID');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `climate_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `climate_stress_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Climate Stress Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Environmental, Social, and Governance (ESG) Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `esg_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Environmental, Social, and Governance (ESG) Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `esg_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `esg_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `exclusion_list_id` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'ESG Assessment Reviewer ID');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `reviewer_id` SET TAGS ('dbx_business_glossary_term' = 'ESG Assessment Reviewer ID');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `sfdr_disclosure_id` SET TAGS ('dbx_business_glossary_term' = 'Sfdr Disclosure Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `actual_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Completion Date');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `advisor_report_reference` SET TAGS ('dbx_business_glossary_term' = 'ESG Advisor Report Reference');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `assessment_reference` SET TAGS ('dbx_business_glossary_term' = 'ESG Due Diligence (DD) Assessment Reference');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `assessment_reference` SET TAGS ('dbx_value_regex' = '^ESG-DD-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'ESG Assessment Status');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'draft|in_progress|under_review|completed|approved|withdrawn');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `assessment_type` SET TAGS ('dbx_business_glossary_term' = 'ESG Assessment Type');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `assessment_type` SET TAGS ('dbx_value_regex' = 'initial|refresh|periodic_monitoring|incident_triggered|pre_ic|post_acquisition');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `board_independence_pct` SET TAGS ('dbx_business_glossary_term' = 'Board Independence Percentage');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `carbon_intensity` SET TAGS ('dbx_business_glossary_term' = 'Carbon Intensity (tCO2e per USD Revenue)');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `climate_transition_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Climate Transition Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `climate_transition_risk_rating` SET TAGS ('dbx_value_regex' = 'low_risk|medium_risk|high_risk|critical_risk');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `controversy_description` SET TAGS ('dbx_business_glossary_term' = 'ESG Controversy Description');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `controversy_flag` SET TAGS ('dbx_business_glossary_term' = 'ESG Controversy Flag');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `environmental_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `environmental_risk_rating` SET TAGS ('dbx_value_regex' = 'low_risk|medium_risk|high_risk|critical_risk');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `esg_conditions_precedent` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Conditions Precedent');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `esg_engagement_plan` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Engagement Plan');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `esg_policy_in_place` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Policy in Place');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `esg_reporting_standard` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Reporting Standard');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `esg_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Score');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `esg_score_provider` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Score Provider');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `exclusion_list_check` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List Check Completed');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `exclusion_list_result` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List Screening Result');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `exclusion_list_result` SET TAGS ('dbx_value_regex' = 'pass|fail|conditional_pass|not_applicable');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `ghg_emissions_year` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Emissions Reference Year');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `ghg_scope1_emissions` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Scope 1 Emissions (tCO2e)');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `ghg_scope2_emissions` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Scope 2 Emissions (tCO2e)');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `ghg_scope3_emissions` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Scope 3 Emissions (tCO2e)');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `governance_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Governance Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `governance_risk_rating` SET TAGS ('dbx_value_regex' = 'low_risk|medium_risk|high_risk|critical_risk');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `human_rights_risk_flag` SET TAGS ('dbx_business_glossary_term' = 'Human Rights Risk Flag');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `ic_esg_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) ESG Recommendation');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `ic_esg_recommendation` SET TAGS ('dbx_value_regex' = 'proceed|proceed_with_conditions|further_review_required|do_not_proceed');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `initiation_date` SET TAGS ('dbx_business_glossary_term' = 'Assessment Initiation Date');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `key_esg_risks_summary` SET TAGS ('dbx_business_glossary_term' = 'Key Environmental, Social, and Governance (ESG) Risks Summary');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `net_zero_alignment` SET TAGS ('dbx_business_glossary_term' = 'Net Zero Alignment Status');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `net_zero_alignment` SET TAGS ('dbx_value_regex' = 'aligned|partially_aligned|not_aligned|not_assessed');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `overall_esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Overall Environmental, Social, and Governance (ESG) Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `overall_esg_rating` SET TAGS ('dbx_value_regex' = 'low_risk|medium_risk|high_risk|critical_risk');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `physical_climate_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Physical Climate Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `physical_climate_risk_rating` SET TAGS ('dbx_value_regex' = 'low_risk|medium_risk|high_risk|critical_risk');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `pri_signatory` SET TAGS ('dbx_business_glossary_term' = 'Principles for Responsible Investment (PRI) Signatory Status');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `reviewed_date` SET TAGS ('dbx_business_glossary_term' = 'ESG Assessment Reviewed Date');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `sfdr_article_classification` SET TAGS ('dbx_business_glossary_term' = 'Sustainable Finance Disclosure Regulation (SFDR) Article Classification');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `sfdr_article_classification` SET TAGS ('dbx_value_regex' = 'article_6|article_8|article_9|not_applicable');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `social_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Social Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `social_risk_rating` SET TAGS ('dbx_value_regex' = 'low_risk|medium_risk|high_risk|critical_risk');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `target_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Target Completion Date');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `target_geography` SET TAGS ('dbx_business_glossary_term' = 'Target Geography (ISO 3166-1 Alpha-3)');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `target_geography` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `target_sector` SET TAGS ('dbx_business_glossary_term' = 'Target Sector (GICS)');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `tcfd_disclosure_assessed` SET TAGS ('dbx_business_glossary_term' = 'Task Force on Climate-related Financial Disclosures (TCFD) Disclosure Assessed');
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ALTER COLUMN `third_party_esg_advisor` SET TAGS ('dbx_business_glossary_term' = 'Third-Party ESG Advisor');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` SET TAGS ('dbx_subdomain' = 'risk_assessment');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `legal_dd_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Legal Due Diligence (DD) Assessment ID');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Legal Counsel ID');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `lead_legal_counsel_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Legal Counsel ID');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `actual_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Completion Date');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `assessment_reference` SET TAGS ('dbx_business_glossary_term' = 'Legal Due Diligence (DD) Assessment Reference');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `assessment_reference` SET TAGS ('dbx_value_regex' = '^LDD-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'Legal Due Diligence (DD) Assessment Status');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'draft|in_progress|under_review|completed|withdrawn');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `assessment_type` SET TAGS ('dbx_business_glossary_term' = 'Legal Due Diligence (DD) Assessment Type');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `assessment_type` SET TAGS ('dbx_value_regex' = 'direct_investment|co_investment|fund_manager|secondary|real_estate|infrastructure');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `conditions_precedent_identified` SET TAGS ('dbx_business_glossary_term' = 'Conditions Precedent Identified Flag');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `conditions_precedent_summary` SET TAGS ('dbx_business_glossary_term' = 'Conditions Precedent Summary');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `conditions_precedent_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `corporate_structure_findings` SET TAGS ('dbx_business_glossary_term' = 'Corporate Structure Review Findings');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `corporate_structure_findings` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `corporate_structure_reviewed` SET TAGS ('dbx_business_glossary_term' = 'Corporate Structure Reviewed Flag');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `data_privacy_findings` SET TAGS ('dbx_business_glossary_term' = 'Data Privacy Review Findings');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `data_privacy_findings` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `data_privacy_review_status` SET TAGS ('dbx_business_glossary_term' = 'Data Privacy Review Status');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `data_privacy_review_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed|not_applicable');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `data_room_reference` SET TAGS ('dbx_business_glossary_term' = 'Data Room Reference');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `employment_findings` SET TAGS ('dbx_business_glossary_term' = 'Employment and Labour Law Review Findings');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `employment_findings` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `employment_review_status` SET TAGS ('dbx_business_glossary_term' = 'Employment and Labour Law Review Status');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `employment_review_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed|not_applicable');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `external_legal_advisor` SET TAGS ('dbx_business_glossary_term' = 'External Legal Advisor Firm Name');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `governing_law` SET TAGS ('dbx_business_glossary_term' = 'Governing Law');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `ic_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Date');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `initiation_date` SET TAGS ('dbx_business_glossary_term' = 'Legal Due Diligence (DD) Initiation Date');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `ip_findings` SET TAGS ('dbx_business_glossary_term' = 'Intellectual Property (IP) Review Findings');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `ip_findings` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `ip_review_status` SET TAGS ('dbx_business_glossary_term' = 'Intellectual Property (IP) Review Status');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `ip_review_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed|not_applicable');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `legal_advisor_report_reference` SET TAGS ('dbx_business_glossary_term' = 'Legal Advisor Report Reference');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `legal_risk_flags` SET TAGS ('dbx_business_glossary_term' = 'Legal Risk Flags Summary');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `legal_risk_flags` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `legal_sign_off_date` SET TAGS ('dbx_business_glossary_term' = 'Legal Sign-Off Date');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `litigation_findings` SET TAGS ('dbx_business_glossary_term' = 'Litigation and Disputes Findings');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `litigation_findings` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `litigation_review_status` SET TAGS ('dbx_business_glossary_term' = 'Litigation Review Status');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `litigation_review_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed|not_applicable');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `lpa_key_terms_summary` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Key Terms Summary');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `lpa_key_terms_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `lpa_reviewed` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reviewed Flag');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `material_contracts_findings` SET TAGS ('dbx_business_glossary_term' = 'Material Contracts Review Findings');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `material_contracts_findings` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `material_contracts_reviewed` SET TAGS ('dbx_business_glossary_term' = 'Material Contracts Reviewed Flag');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `material_litigation_identified` SET TAGS ('dbx_business_glossary_term' = 'Material Litigation Identified Flag');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `nda_executed` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Executed Flag');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `overall_legal_rating` SET TAGS ('dbx_business_glossary_term' = 'Overall Legal Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `overall_legal_rating` SET TAGS ('dbx_value_regex' = 'low_risk|medium_risk|high_risk|critical_risk');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `regulatory_compliance_findings` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Review Findings');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `regulatory_compliance_findings` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `regulatory_compliance_reviewed` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Compliance Reviewed Flag');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `remediation_notes` SET TAGS ('dbx_business_glossary_term' = 'Legal Remediation Notes');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `remediation_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `remediation_required` SET TAGS ('dbx_business_glossary_term' = 'Legal Remediation Required Flag');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `spa_key_terms_summary` SET TAGS ('dbx_business_glossary_term' = 'Share Purchase Agreement (SPA) Key Terms Summary');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `spa_key_terms_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `spa_reviewed` SET TAGS ('dbx_business_glossary_term' = 'Share Purchase Agreement (SPA) Reviewed Flag');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `target_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Target Completion Date');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `target_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Jurisdiction');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `target_jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `title_ownership_findings` SET TAGS ('dbx_business_glossary_term' = 'Title and Ownership Verification Findings');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `title_ownership_findings` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `title_ownership_verified` SET TAGS ('dbx_business_glossary_term' = 'Title and Ownership Verification Flag');
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` SET TAGS ('dbx_subdomain' = 'compliance_approval');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `diligence_ic_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `diligence_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Sponsor ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `diligence_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `diligence_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `diligence_lead_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `diligence_lead_analyst_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `diligence_lead_analyst_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `economic_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Economic Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Sponsor ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `fee_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Fee Benchmark Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `lead_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `prior_submission_diligence_ic_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Prior IC Submission ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `approved_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'IC-Approved Commitment Amount');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `approved_commitment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `co_investment_flag` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Flag');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `commitment_amount_base_equivalent` SET TAGS ('dbx_business_glossary_term' = 'Commitment Amount (Base Currency Equivalent)');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `commitment_amount_base_equivalent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Commitment Currency (ISO 4217)');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `conditions_precedent` SET TAGS ('dbx_business_glossary_term' = 'Conditions Precedent');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `conditions_precedent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `data_room_location` SET TAGS ('dbx_business_glossary_term' = 'Data Room Location / URL');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `dd_completion_status` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Completion Status');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `dd_completion_status` SET TAGS ('dbx_value_regex' = 'complete|substantially_complete|partial|waived');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `esg_materiality_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Materiality Flag');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `esg_rating` SET TAGS ('dbx_value_regex' = 'low_risk|medium_risk|high_risk|critical_risk');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `hurdle_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate (Preferred Return) Percentage');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `ic_decision` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `ic_decision` SET TAGS ('dbx_value_regex' = 'approved|rejected|deferred|approved_with_conditions');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `ic_decision_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision Date');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `ic_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Meeting Date');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `ic_round` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Round Number');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `im_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Memorandum (IM) Reference');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `im_version` SET TAGS ('dbx_business_glossary_term' = 'Investment Memorandum (IM) Version');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `im_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+$');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `investment_horizon_years` SET TAGS ('dbx_business_glossary_term' = 'Investment Horizon (Years)');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `investment_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Type');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `investment_type` SET TAGS ('dbx_value_regex' = 'direct|co_investment|fund_commitment|secondary|sma');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `key_risks_summary` SET TAGS ('dbx_business_glossary_term' = 'Key Risks Summary');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `key_risks_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `kyc_aml_cleared` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer / Anti-Money Laundering (KYC/AML) Cleared');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `loi_executed` SET TAGS ('dbx_business_glossary_term' = 'Letter of Intent (LOI) Executed');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `nda_executed` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Executed');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `overall_dd_rating` SET TAGS ('dbx_business_glossary_term' = 'Overall Due Diligence (DD) Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `overall_dd_rating` SET TAGS ('dbx_value_regex' = 'low_risk|medium_risk|high_risk|critical_risk');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `portfolio_weight_pct` SET TAGS ('dbx_business_glossary_term' = 'Proposed Portfolio Weight Percentage');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `recommendation` SET TAGS ('dbx_business_glossary_term' = 'Investment Team Recommendation');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `recommendation` SET TAGS ('dbx_value_regex' = 'invest|do_not_invest|further_diligence|conditional_invest');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `recommended_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Recommended Commitment Amount');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `recommended_commitment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `regulatory_concern_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Concern Flag');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `saa_asset_class_bucket` SET TAGS ('dbx_business_glossary_term' = 'Strategic Asset Allocation (SAA) Asset Class Bucket');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'IC Submission Date');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `submission_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Reference');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `submission_reference` SET TAGS ('dbx_value_regex' = '^IC-[0-9]{4}-[0-9]{5}$');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `submission_status` SET TAGS ('dbx_business_glossary_term' = 'IC Submission Status');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `target_geography` SET TAGS ('dbx_business_glossary_term' = 'Target Geography (ISO 3166-1 Alpha-3)');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `target_geography` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `target_irr_pct` SET TAGS ('dbx_business_glossary_term' = 'Target Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `target_irr_pct` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `target_moic` SET TAGS ('dbx_business_glossary_term' = 'Target Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `target_moic` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `third_party_advisor` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor Name');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` SET TAGS ('dbx_subdomain' = 'compliance_approval');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `diligence_ic_condition_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence Investment Committee (IC) Condition ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Condition Owner Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `owner_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Condition Owner Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `risk_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Risk Assessment ID');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `actual_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Resolution Date');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `advisor_report_reference` SET TAGS ('dbx_business_glossary_term' = 'Advisor Report Reference');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `condition_category` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Condition Category');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `condition_description` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Condition Description');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `condition_rationale` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Condition Rationale');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `condition_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Condition Reference');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `condition_reference` SET TAGS ('dbx_value_regex' = '^IC-COND-[0-9]{4}-[0-9]{5}$');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `condition_sequence` SET TAGS ('dbx_business_glossary_term' = 'Condition Sequence Number');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `condition_status` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Condition Status');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `condition_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|satisfied|waived|escalated|overdue');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `condition_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Condition Type');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `condition_type` SET TAGS ('dbx_value_regex' = 'legal|financial|esg|operational|regulatory');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `data_room_reference` SET TAGS ('dbx_business_glossary_term' = 'Data Room Reference');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `dd_type` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Type');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `dd_type` SET TAGS ('dbx_value_regex' = 'ODD|FDD|CDD|legal_dd|esg_dd');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `escalation_date` SET TAGS ('dbx_business_glossary_term' = 'Condition Escalation Date');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `escalation_reason` SET TAGS ('dbx_business_glossary_term' = 'Condition Escalation Reason');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `esg_dimension` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Dimension');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `esg_dimension` SET TAGS ('dbx_value_regex' = 'environmental|social|governance|none');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `extended_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Extended Resolution Date');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `ic_decision_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision Date');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `ic_decision_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision Reference');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `investment_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Type');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `investment_type` SET TAGS ('dbx_value_regex' = 'direct|co_invest|fund_commitment|sma|secondary');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `is_conditions_precedent` SET TAGS ('dbx_business_glossary_term' = 'Conditions Precedent (CP) Flag');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `is_ic_blocking` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Blocking Condition Flag');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `last_reviewed_by` SET TAGS ('dbx_business_glossary_term' = 'Last Reviewed By');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `last_reviewed_date` SET TAGS ('dbx_business_glossary_term' = 'Last Condition Review Date');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Condition Review Date');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Condition Priority');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `resolution_evidence` SET TAGS ('dbx_business_glossary_term' = 'Condition Resolution Evidence');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `resolution_notes` SET TAGS ('dbx_business_glossary_term' = 'Condition Resolution Notes');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `responsible_party_name` SET TAGS ('dbx_business_glossary_term' = 'Responsible Party Name');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `responsible_party_type` SET TAGS ('dbx_business_glossary_term' = 'Responsible Party Type');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Condition Review Frequency');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'weekly|bi_weekly|monthly|quarterly|ad_hoc');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `target_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Target Resolution Date');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `third_party_advisor` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `waiver_approved` SET TAGS ('dbx_business_glossary_term' = 'Condition Waiver Approved Flag');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `waiver_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Condition Waiver Approved By');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `waiver_date` SET TAGS ('dbx_business_glossary_term' = 'Condition Waiver Date');
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ALTER COLUMN `waiver_rationale` SET TAGS ('dbx_business_glossary_term' = 'Condition Waiver Rationale');
ALTER TABLE `asset_management`.`diligence`.`nda_record` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`diligence`.`nda_record` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`nda_record` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`nda_record` SET TAGS ('dbx_subdomain' = 'compliance_approval');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `nda_record_id` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Record ID');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `lead_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `confidentiality_scope` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Scope Description');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `confidentiality_scope` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `counterparty_domicile` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Domicile Country');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `counterparty_domicile` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{18}[0-9]{2}$');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `counterparty_name` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Name');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `counterparty_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `counterparty_signatory_name` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Signatory Name');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `counterparty_signatory_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `counterparty_signatory_title` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Signatory Title');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `counterparty_type` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Type');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `data_room_access_granted` SET TAGS ('dbx_business_glossary_term' = 'Data Room Access Granted Flag');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `data_room_platform` SET TAGS ('dbx_business_glossary_term' = 'Data Room Platform');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `data_room_platform` SET TAGS ('dbx_value_regex' = 'intralinks|datasite|ansarada|box|sharepoint|other');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `document_reference` SET TAGS ('dbx_business_glossary_term' = 'NDA Document Reference');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `document_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `document_version` SET TAGS ('dbx_business_glossary_term' = 'NDA Document Version');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `exclusivity_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Exclusivity Expiry Date');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `exclusivity_included` SET TAGS ('dbx_business_glossary_term' = 'Exclusivity Provision Included Flag');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `execution_date` SET TAGS ('dbx_business_glossary_term' = 'NDA Execution Date');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'NDA Expiry Date');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `external_counsel_firm` SET TAGS ('dbx_business_glossary_term' = 'External Legal Counsel Firm Name');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `fund_signatory_name` SET TAGS ('dbx_business_glossary_term' = 'Fund Signatory Name');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `fund_signatory_title` SET TAGS ('dbx_business_glossary_term' = 'Fund Signatory Title');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `governing_law_detail` SET TAGS ('dbx_business_glossary_term' = 'Governing Law Detail');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `governing_law_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Governing Law Jurisdiction');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `governing_law_jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `investment_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Type');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `investment_type` SET TAGS ('dbx_value_regex' = 'direct|co_invest|fund_investment|secondary|sma|other');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `kyc_aml_cleared` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer / Anti-Money Laundering (KYC/AML) Cleared Flag');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `kyc_aml_screening_required` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer / Anti-Money Laundering (KYC/AML) Screening Required Flag');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `kyc_cleared_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer / Anti-Money Laundering (KYC/AML) Cleared Date');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `legal_counsel_internal` SET TAGS ('dbx_business_glossary_term' = 'Internal Legal Counsel Name');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `nda_reference` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Reference Number');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `nda_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `nda_status` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Status');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `nda_status` SET TAGS ('dbx_value_regex' = 'draft|pending_signature|executed|expired|terminated|superseded');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `nda_type` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Type');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `nda_type` SET TAGS ('dbx_value_regex' = 'mutual|one_way_inbound|one_way_outbound|multilateral');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `non_solicit_included` SET TAGS ('dbx_business_glossary_term' = 'Non-Solicitation Provision Included Flag');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'NDA Notes');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `origination_channel` SET TAGS ('dbx_business_glossary_term' = 'Deal Origination Channel');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `origination_channel` SET TAGS ('dbx_value_regex' = 'proprietary|intermediated|secondary_market|rfp|referral|other');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `permitted_use_description` SET TAGS ('dbx_business_glossary_term' = 'Permitted Use Description');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `renewal_date` SET TAGS ('dbx_business_glossary_term' = 'NDA Renewal Date');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `renewal_required` SET TAGS ('dbx_business_glossary_term' = 'NDA Renewal Required Flag');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `sanctions_screened` SET TAGS ('dbx_business_glossary_term' = 'Sanctions Screening Completed Flag');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `standstill_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Standstill Provision Expiry Date');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `standstill_included` SET TAGS ('dbx_business_glossary_term' = 'Standstill Provision Included Flag');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `superseded_by_agreement` SET TAGS ('dbx_business_glossary_term' = 'Superseding Agreement Reference');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `superseded_by_agreement` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `term_months` SET TAGS ('dbx_business_glossary_term' = 'NDA Term Duration (Months)');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'NDA Termination Date');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'NDA Termination Reason');
ALTER TABLE `asset_management`.`diligence`.`nda_record` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'deal_abandoned|deal_closed|mutual_agreement|breach|superseded|other');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` SET TAGS ('dbx_subdomain' = 'diligence_execution');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `data_room_access_id` SET TAGS ('dbx_business_glossary_term' = 'Data Room Access ID');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `lead_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `access_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Access Expiry Date');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `access_extension_count` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Access Extension Count');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `access_grant_date` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Access Grant Date');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `access_notes` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Access Notes');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `access_reference` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Access Reference');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `access_revocation_date` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Access Revocation Date');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `access_status` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Access Status');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `access_status` SET TAGS ('dbx_value_regex' = 'active|expired|revoked|pending|suspended');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `access_type` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Access Type');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `access_type` SET TAGS ('dbx_value_regex' = 'read_only|download|full_access|restricted_view');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `access_user_count` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Access User Count');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `advisor_access_granted` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor Virtual Data Room (VDR) Access Granted Flag');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `dd_type` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Type');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `dd_type` SET TAGS ('dbx_value_regex' = 'ODD|FDD|CDD|Legal DD|ESG DD|Full DD');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `document_categories` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Document Categories');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `document_count` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Document Count');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `documents_downloaded_count` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Documents Downloaded Count');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `documents_viewed_count` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Documents Viewed Count');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `download_enabled` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Download Enabled Flag');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `esg_documents_available` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Documents Available Flag');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `financial_statements_available` SET TAGS ('dbx_business_glossary_term' = 'Financial Statements Available Flag');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `granted_by` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Access Granted By');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `ic_submission_ready` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Ready Flag');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `kyc_aml_documents_available` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer / Anti-Money Laundering (KYC/AML) Documents Available Flag');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `last_accessed_date` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Last Accessed Date');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `legal_documents_available` SET TAGS ('dbx_business_glossary_term' = 'Legal Documents Available Flag');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `nda_executed` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Executed Flag');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `nda_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Execution Date');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `nda_reference` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Reference');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `nda_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `outstanding_document_requests` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Outstanding Document Requests');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `print_enabled` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Print Enabled Flag');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `revocation_reason` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Access Revocation Reason');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `revocation_reason` SET TAGS ('dbx_value_regex' = 'deal_terminated|dd_completed|nda_breach|access_expired|counterparty_request|other');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `source_system_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `third_party_advisor` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `vdr_platform` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Platform');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `vdr_platform` SET TAGS ('dbx_value_regex' = 'Intralinks|Datasite|Ansarada|Merrill DatasiteOne|Box|SharePoint');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `vdr_room_code` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Room Identifier');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `vdr_room_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `vdr_room_name` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Room Name');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `vdr_room_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `vdr_url` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Access URL');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `vdr_url` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ALTER COLUMN `watermarking_enabled` SET TAGS ('dbx_business_glossary_term' = 'Virtual Data Room (VDR) Document Watermarking Enabled Flag');
ALTER TABLE `asset_management`.`diligence`.`management_interview` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`diligence`.`management_interview` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`management_interview` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`management_interview` SET TAGS ('dbx_subdomain' = 'advisor_management');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `management_interview_id` SET TAGS ('dbx_business_glossary_term' = 'Management Interview ID');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `dd_workstream_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Workstream ID');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `lead_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `manager_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Contact Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `actual_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Interview Date');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `additional_attendees` SET TAGS ('dbx_business_glossary_term' = 'Additional Attendees');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `aml_kyc_concern_flag` SET TAGS ('dbx_business_glossary_term' = 'Anti-Money Laundering / Know Your Customer (AML/KYC) Concern Flag');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `data_room_reference` SET TAGS ('dbx_business_glossary_term' = 'Data Room Reference');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `dd_type` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Type');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `dd_type` SET TAGS ('dbx_value_regex' = 'ODD|FDD|CDD|legal_dd|ESG_dd|general');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Interview Duration (Minutes)');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `esg_findings_summary` SET TAGS ('dbx_business_glossary_term' = 'ESG Findings Summary');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `esg_topics_discussed` SET TAGS ('dbx_business_glossary_term' = 'ESG Topics Discussed Flag');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `follow_up_description` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Description');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `follow_up_due_date` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Due Date');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `follow_up_required` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Required Flag');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `ic_submission_included` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Included Flag');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `interview_format` SET TAGS ('dbx_business_glossary_term' = 'Interview Format');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `interview_format` SET TAGS ('dbx_value_regex' = 'in_person|video_call|phone_call|written_questionnaire');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `interview_location` SET TAGS ('dbx_business_glossary_term' = 'Interview Location');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `interview_reference` SET TAGS ('dbx_business_glossary_term' = 'Management Interview Reference Code');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `interview_reference` SET TAGS ('dbx_value_regex' = '^MI-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `interview_sequence` SET TAGS ('dbx_business_glossary_term' = 'Interview Sequence Number');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `interview_status` SET TAGS ('dbx_business_glossary_term' = 'Interview Status');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `interview_status` SET TAGS ('dbx_value_regex' = 'scheduled|completed|cancelled|rescheduled|pending_notes');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `interview_type` SET TAGS ('dbx_business_glossary_term' = 'Interview Type');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `interview_type` SET TAGS ('dbx_value_regex' = 'management_interview|site_visit|reference_check|expert_call|advisor_debrief');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `interviewee_name` SET TAGS ('dbx_business_glossary_term' = 'Interviewee Full Name');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `interviewee_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `interviewee_organization` SET TAGS ('dbx_business_glossary_term' = 'Interviewee Organization');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `interviewee_relationship` SET TAGS ('dbx_business_glossary_term' = 'Interviewee Relationship to Target');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `interviewee_title` SET TAGS ('dbx_business_glossary_term' = 'Interviewee Job Title');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `key_findings` SET TAGS ('dbx_business_glossary_term' = 'Key Findings');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `lead_analyst_name` SET TAGS ('dbx_business_glossary_term' = 'Lead Analyst Name');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `management_quality_assessment` SET TAGS ('dbx_business_glossary_term' = 'Management Quality Assessment');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `notes_completed_date` SET TAGS ('dbx_business_glossary_term' = 'Interview Notes Completed Date');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `notes_completed_flag` SET TAGS ('dbx_business_glossary_term' = 'Interview Notes Completed Flag');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `overall_impression_rating` SET TAGS ('dbx_business_glossary_term' = 'Overall Impression Rating');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `overall_impression_rating` SET TAGS ('dbx_value_regex' = 'strong_positive|positive|neutral|negative|strong_negative');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `recording_consent_obtained` SET TAGS ('dbx_business_glossary_term' = 'Recording Consent Obtained Flag');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `red_flags_identified` SET TAGS ('dbx_business_glossary_term' = 'Red Flags Identified');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `referee_sourced_by` SET TAGS ('dbx_business_glossary_term' = 'Referee Sourced By');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `referee_sourced_by` SET TAGS ('dbx_value_regex' = 'analyst_sourced|gp_provided|third_party_advisor|expert_network|internal_network');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `scheduled_date` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Interview Date');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `scheduled_start_time` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Start Timestamp');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `third_party_advisor` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor');
ALTER TABLE `asset_management`.`diligence`.`management_interview` ALTER COLUMN `topics_covered` SET TAGS ('dbx_business_glossary_term' = 'Topics Covered');
ALTER TABLE `asset_management`.`diligence`.`reference_check` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`diligence`.`reference_check` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`reference_check` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`reference_check` SET TAGS ('dbx_subdomain' = 'advisor_management');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `reference_check_id` SET TAGS ('dbx_business_glossary_term' = 'Reference Check ID');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Interviewer Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `interviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Interviewer Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `manager_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Manager Contact Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `advisor_report_reference` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor Report Reference');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'private_equity|real_estate|infrastructure|natural_resources|credit|public_equities');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `check_date` SET TAGS ('dbx_business_glossary_term' = 'Reference Check Date');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `check_reference` SET TAGS ('dbx_business_glossary_term' = 'Reference Check Reference Number');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `check_reference` SET TAGS ('dbx_value_regex' = '^RC-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `check_status` SET TAGS ('dbx_business_glossary_term' = 'Reference Check Status');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `check_status` SET TAGS ('dbx_value_regex' = 'planned|in_progress|completed|cancelled|on_hold');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `check_type` SET TAGS ('dbx_business_glossary_term' = 'Reference Check Type');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `confidentiality_requested` SET TAGS ('dbx_business_glossary_term' = 'Referee Confidentiality Requested Indicator');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `data_room_reference` SET TAGS ('dbx_business_glossary_term' = 'Data Room Document Reference');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `dd_type` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Type');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `dd_type` SET TAGS ('dbx_value_regex' = 'ODD|FDD|CDD|legal_dd|esg_dd');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `esg_concerns_noted` SET TAGS ('dbx_business_glossary_term' = 'ESG Concerns Noted Indicator');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `follow_up_notes` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Action Notes');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `follow_up_required` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Required Indicator');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `ic_submission_included` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Included Indicator');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `integrity_rating` SET TAGS ('dbx_business_glossary_term' = 'Integrity and Ethics Rating');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `integrity_rating` SET TAGS ('dbx_value_regex' = 'strong|satisfactory|concerns_noted|unsatisfactory');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `interview_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Interview Duration (Minutes)');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `interview_method` SET TAGS ('dbx_business_glossary_term' = 'Reference Interview Method');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `interview_method` SET TAGS ('dbx_value_regex' = 'phone|video_call|in_person|written');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `interviewer_name` SET TAGS ('dbx_business_glossary_term' = 'Interviewer Name');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `investment_acumen_rating` SET TAGS ('dbx_business_glossary_term' = 'Investment Acumen Rating');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `investment_acumen_rating` SET TAGS ('dbx_value_regex' = 'strong|satisfactory|concerns_noted|unsatisfactory');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `key_feedback_summary` SET TAGS ('dbx_business_glossary_term' = 'Key Reference Feedback Summary');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `leadership_rating` SET TAGS ('dbx_business_glossary_term' = 'Leadership Quality Rating');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `leadership_rating` SET TAGS ('dbx_value_regex' = 'strong|satisfactory|concerns_noted|unsatisfactory');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `overall_rating` SET TAGS ('dbx_business_glossary_term' = 'Overall Reference Check Rating');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `overall_rating` SET TAGS ('dbx_value_regex' = 'strong_positive|positive|neutral|negative|strong_negative');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `red_flags_description` SET TAGS ('dbx_business_glossary_term' = 'Red Flags Description');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `red_flags_noted` SET TAGS ('dbx_business_glossary_term' = 'Red Flags Noted Indicator');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `referee_consent_obtained` SET TAGS ('dbx_business_glossary_term' = 'Referee Consent Obtained Indicator');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `referee_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Referee Contact Email Address');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `referee_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `referee_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `referee_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `referee_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Referee Contact Phone Number');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `referee_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `referee_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `referee_name` SET TAGS ('dbx_business_glossary_term' = 'Referee Full Name');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `referee_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `referee_organization` SET TAGS ('dbx_business_glossary_term' = 'Referee Organization Name');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `referee_relationship` SET TAGS ('dbx_business_glossary_term' = 'Referee Relationship to Subject');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `referee_sourced_by` SET TAGS ('dbx_business_glossary_term' = 'Referee Sourcing Method');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `referee_sourced_by` SET TAGS ('dbx_value_regex' = 'fund_provided|independently_sourced|network_referral|third_party_advisor');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `referee_title` SET TAGS ('dbx_business_glossary_term' = 'Referee Professional Title');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `relationship_duration_years` SET TAGS ('dbx_business_glossary_term' = 'Referee Relationship Duration (Years)');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `subject_name` SET TAGS ('dbx_business_glossary_term' = 'Reference Check Subject Name');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `subject_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `subject_organization` SET TAGS ('dbx_business_glossary_term' = 'Reference Check Subject Organization');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `subject_title` SET TAGS ('dbx_business_glossary_term' = 'Reference Check Subject Title');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `third_party_advisor` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor Name');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `topics_covered` SET TAGS ('dbx_business_glossary_term' = 'Reference Check Topics Covered');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `would_work_again` SET TAGS ('dbx_business_glossary_term' = 'Referee Would Work Again Indicator');
ALTER TABLE `asset_management`.`diligence`.`reference_check` ALTER COLUMN `would_work_again` SET TAGS ('dbx_value_regex' = 'yes|no|with_reservations|declined_to_answer');
ALTER TABLE `asset_management`.`diligence`.`dd_document` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`diligence`.`dd_document` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`dd_document` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`dd_document` SET TAGS ('dbx_subdomain' = 'diligence_execution');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `dd_document_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Document ID');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `dd_checklist_item_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Checklist Item ID');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `dd_workstream_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Workstream ID');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewer Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Manager ID');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Asset Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewer Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `superseded_by_document_dd_document_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Document ID');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `target_entity_id` SET TAGS ('dbx_internal' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'private_equity|real_estate|infrastructure|natural_resources|credit|public_equities');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Document Confidentiality Level');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `data_room_platform` SET TAGS ('dbx_business_glossary_term' = 'Data Room Platform');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `data_room_reference` SET TAGS ('dbx_business_glossary_term' = 'Data Room Reference');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `dd_type` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Type');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `document_currency` SET TAGS ('dbx_business_glossary_term' = 'Document Currency Code');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `document_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `document_date` SET TAGS ('dbx_business_glossary_term' = 'Document Date');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `document_language` SET TAGS ('dbx_business_glossary_term' = 'Document Language Code');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `document_language` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `document_reference` SET TAGS ('dbx_business_glossary_term' = 'Document Reference Code');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'Document Status');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `document_status` SET TAGS ('dbx_value_regex' = 'received|under_review|reviewed|accepted|rejected|superseded');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `document_summary` SET TAGS ('dbx_business_glossary_term' = 'Document Summary');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `document_title` SET TAGS ('dbx_business_glossary_term' = 'Document Title');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `document_type` SET TAGS ('dbx_business_glossary_term' = 'Document Type');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `document_version` SET TAGS ('dbx_business_glossary_term' = 'Document Version');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `esg_dimension` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Dimension');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `esg_dimension` SET TAGS ('dbx_value_regex' = 'environmental|social|governance|climate|general');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `file_format` SET TAGS ('dbx_business_glossary_term' = 'Document File Format');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `file_name` SET TAGS ('dbx_business_glossary_term' = 'Document File Name');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `file_size_kb` SET TAGS ('dbx_business_glossary_term' = 'Document File Size (Kilobytes)');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `is_final_version` SET TAGS ('dbx_business_glossary_term' = 'Final Version Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `is_ic_relevant` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Relevant Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `is_nda_required` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Required Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `key_findings` SET TAGS ('dbx_business_glossary_term' = 'Key Findings');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `originating_party_name` SET TAGS ('dbx_business_glossary_term' = 'Originating Party Name');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `originating_party_type` SET TAGS ('dbx_business_glossary_term' = 'Originating Party Type');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `received_date` SET TAGS ('dbx_business_glossary_term' = 'Document Received Date');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `regulatory_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reference');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `reporting_period_end` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `reporting_period_start` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `reviewed_date` SET TAGS ('dbx_business_glossary_term' = 'Document Reviewed Date');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `risk_relevance_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Relevance Rating');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `risk_relevance_rating` SET TAGS ('dbx_value_regex' = 'high|medium|low|not_applicable');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `source_system_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `target_entity_lei` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `target_entity_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`diligence`.`dd_document` ALTER COLUMN `third_party_advisor` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Advisor Name');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` SET TAGS ('dbx_subdomain' = 'diligence_execution');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `dd_status_event_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Status Event ID');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `dd_workstream_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Workstream ID');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Triggered By Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `triggered_by_analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Triggered By Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Status Event Comments');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `dd_type` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Type');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `dd_type` SET TAGS ('dbx_value_regex' = 'ODD|FDD|CDD|legal_dd|esg_dd|full_dd');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `escalated_to` SET TAGS ('dbx_business_glossary_term' = 'Escalated To');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `escalation_flag` SET TAGS ('dbx_business_glossary_term' = 'Escalation Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `escalation_reason` SET TAGS ('dbx_business_glossary_term' = 'Escalation Reason');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `event_reference` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Status Event Reference');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `event_reference` SET TAGS ('dbx_value_regex' = '^DDSE-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `event_scope` SET TAGS ('dbx_business_glossary_term' = 'Status Event Scope');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `event_scope` SET TAGS ('dbx_value_regex' = 'engagement|workstream');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `event_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Status Event Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `event_type` SET TAGS ('dbx_business_glossary_term' = 'Status Event Type');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `event_type` SET TAGS ('dbx_value_regex' = 'status_change|escalation|waiver|ic_decision|system_update|analyst_override');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `ic_decision_outcome` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision Outcome');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `ic_decision_outcome` SET TAGS ('dbx_value_regex' = 'approved|rejected|deferred|approved_with_conditions');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `ic_decision_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision Reference');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `investment_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Type');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `investment_type` SET TAGS ('dbx_value_regex' = 'direct|co_invest|fund|secondary|sma');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `is_ic_blocking` SET TAGS ('dbx_business_glossary_term' = 'Is Investment Committee (IC) Blocking Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `is_milestone_event` SET TAGS ('dbx_business_glossary_term' = 'Is Milestone Event Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `new_status` SET TAGS ('dbx_business_glossary_term' = 'New Due Diligence (DD) Status');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `on_hold_reason` SET TAGS ('dbx_business_glossary_term' = 'On Hold Reason');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `prior_status` SET TAGS ('dbx_business_glossary_term' = 'Prior Due Diligence (DD) Status');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `prior_status_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Prior Status Duration (Days)');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `source_system_event_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Event Reference');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `target_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Target Completion Date');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Termination Reason');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `triggered_by_analyst_name` SET TAGS ('dbx_business_glossary_term' = 'Triggered By Analyst Name');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `triggered_by_analyst_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `triggered_by_system` SET TAGS ('dbx_business_glossary_term' = 'Triggered By System');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `triggered_by_system` SET TAGS ('dbx_value_regex' = 'eFront|Dealpath|DealCloud|Diligent|manual|SimCorp');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `triggered_by_type` SET TAGS ('dbx_business_glossary_term' = 'Triggered By Type');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `triggered_by_type` SET TAGS ('dbx_value_regex' = 'analyst|ic_decision|system|manager|third_party_advisor|compliance');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `triggering_event_description` SET TAGS ('dbx_business_glossary_term' = 'Triggering Event Description');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `waiver_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Waiver Approved By');
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ALTER COLUMN `waiver_flag` SET TAGS ('dbx_business_glossary_term' = 'Waiver Flag');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` SET TAGS ('dbx_subdomain' = 'compliance_approval');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `kyc_aml_record_id` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer / Anti-Money Laundering (KYC/AML) Record ID');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `compliance_officer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Officer ID');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Engagement ID');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'KYC/AML Initiating Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `exclusion_list_id` SET TAGS ('dbx_business_glossary_term' = 'Exclusion List Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Fund Manager ID');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `kyc_compliance_officer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Officer ID');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `kyc_compliance_officer_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `kyc_compliance_officer_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `kyc_employee_id` SET TAGS ('dbx_business_glossary_term' = 'KYC/AML Initiating Analyst ID');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `kyc_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `kyc_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'External Fund Manager ID');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `adverse_media_flag` SET TAGS ('dbx_business_glossary_term' = 'Adverse Media Flag');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `adverse_media_summary` SET TAGS ('dbx_business_glossary_term' = 'Adverse Media Summary');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `aml_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Anti-Money Laundering (AML) Risk Rating');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `aml_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|very_high');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `aml_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Anti-Money Laundering (AML) Risk Score');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `beneficial_owner_verified` SET TAGS ('dbx_business_glossary_term' = 'Beneficial Owner Verified Flag');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `compliance_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Compliance Approval Date');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `document_reference` SET TAGS ('dbx_business_glossary_term' = 'KYC/AML Supporting Document Reference');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `edd_completed_date` SET TAGS ('dbx_business_glossary_term' = 'Enhanced Due Diligence (EDD) Completed Date');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `enhanced_due_diligence_required` SET TAGS ('dbx_business_glossary_term' = 'Enhanced Due Diligence (EDD) Required Flag');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `escalation_reason` SET TAGS ('dbx_business_glossary_term' = 'KYC/AML Escalation Reason');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'KYC/AML Record Expiry Date');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `high_risk_jurisdiction_flag` SET TAGS ('dbx_business_glossary_term' = 'High-Risk Jurisdiction Flag');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `identity_verification_method` SET TAGS ('dbx_business_glossary_term' = 'Identity Verification Method');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `identity_verification_method` SET TAGS ('dbx_value_regex' = 'document_review|third_party_database|registry_search|in_person|electronic_verification');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `investment_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Type');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `investment_type` SET TAGS ('dbx_value_regex' = 'direct|co_investment|fund_commitment|secondary|sma');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'KYC/AML Next Periodic Review Date');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `overall_kyc_aml_outcome` SET TAGS ('dbx_business_glossary_term' = 'Overall KYC/AML Screening Outcome');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `overall_kyc_aml_outcome` SET TAGS ('dbx_value_regex' = 'cleared|cleared_with_conditions|escalated|rejected|pending_review');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `pep_category` SET TAGS ('dbx_business_glossary_term' = 'Politically Exposed Person (PEP) Category');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `pep_category` SET TAGS ('dbx_value_regex' = 'domestic_pep|foreign_pep|international_organisation_pep|pep_associate|not_applicable');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `pep_flag` SET TAGS ('dbx_business_glossary_term' = 'Politically Exposed Person (PEP) Flag');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `periodic_review_frequency` SET TAGS ('dbx_business_glossary_term' = 'KYC/AML Periodic Review Frequency');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `periodic_review_frequency` SET TAGS ('dbx_value_regex' = 'annual|biennial|triennial|event_triggered');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `record_reference` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer / Anti-Money Laundering (KYC/AML) Record Reference');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `record_reference` SET TAGS ('dbx_value_regex' = '^KYC-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'KYC/AML Rejection Reason');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `sanctions_hit_flag` SET TAGS ('dbx_business_glossary_term' = 'Sanctions Hit Flag');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `sanctions_list_matched` SET TAGS ('dbx_business_glossary_term' = 'Sanctions List Matched');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `screening_completed_date` SET TAGS ('dbx_business_glossary_term' = 'KYC/AML Screening Completed Date');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `screening_initiated_date` SET TAGS ('dbx_business_glossary_term' = 'KYC/AML Screening Initiated Date');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `screening_provider` SET TAGS ('dbx_business_glossary_term' = 'KYC/AML Screening Provider');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `screening_provider_reference` SET TAGS ('dbx_business_glossary_term' = 'Screening Provider Reference Number');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `screening_status` SET TAGS ('dbx_business_glossary_term' = 'KYC/AML Screening Status');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `screening_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|cleared|escalated|rejected|expired');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `screening_type` SET TAGS ('dbx_business_glossary_term' = 'KYC/AML Screening Type');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `screening_type` SET TAGS ('dbx_value_regex' = 'initial|periodic_refresh|trigger_review|enhanced_due_diligence|simplified_due_diligence');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `source_of_funds_description` SET TAGS ('dbx_business_glossary_term' = 'Source of Funds Description');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `source_of_funds_description` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `source_of_funds_verified` SET TAGS ('dbx_business_glossary_term' = 'Source of Funds Verified Flag');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `subject_domicile_country` SET TAGS ('dbx_business_glossary_term' = 'Subject Domicile Country');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `subject_domicile_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `subject_legal_name` SET TAGS ('dbx_business_glossary_term' = 'KYC/AML Subject Legal Name');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `subject_legal_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `subject_lei` SET TAGS ('dbx_business_glossary_term' = 'Subject Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `subject_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{18}[0-9]{2}$');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `subject_operating_country` SET TAGS ('dbx_business_glossary_term' = 'Subject Primary Operating Country');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `subject_operating_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `subject_registration_number` SET TAGS ('dbx_business_glossary_term' = 'Subject Corporate Registration Number');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `subject_registration_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `subject_type` SET TAGS ('dbx_business_glossary_term' = 'KYC/AML Subject Type');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `ubo_ownership_threshold_pct` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Beneficial Owner (UBO) Ownership Threshold Percentage');
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ALTER COLUMN `watchlist_match_flag` SET TAGS ('dbx_business_glossary_term' = 'Watchlist Match Flag');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` SET TAGS ('dbx_subdomain' = 'advisor_management');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `dd_advisor_cost_id` SET TAGS ('dbx_business_glossary_term' = 'DD Advisor Cost ID (DDAC_ID)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `advisor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Advisor ID (ADV_ID)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `dd_advisor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'DD Advisor Engagement ID (DDAE_ID)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'DD Engagement ID (DDE_ID)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID (DEAL_ID)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Advisor ID (ADV_ID)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID (MGR_ID)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Manager ID (MGR_ID)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID (DEAL_ID)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `resource_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Resource Asset Id (Foreign Key)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `accrued_amount` SET TAGS ('dbx_business_glossary_term' = 'Accrued Amount (ACCR_AMT)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `budgeted_amount` SET TAGS ('dbx_business_glossary_term' = 'Budgeted Amount (BUDG_AMT)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_accrual_date` SET TAGS ('dbx_business_glossary_term' = 'Cost Accrual Date (COST_ACCR_DATE)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Cost Approval Date (COST_APP_DATE)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Cost Approval Status (COST_APP_STATUS)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_approval_status` SET TAGS ('dbx_value_regex' = 'approved|pending|rejected');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Cost Approved By (COST_APP_BY)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_category` SET TAGS ('dbx_business_glossary_term' = 'Cost Category (COST_CAT)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_category` SET TAGS ('dbx_value_regex' = 'fee|expense|reimbursement');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code (CC_CODE)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_currency_rate` SET TAGS ('dbx_business_glossary_term' = 'Cost Currency Rate (COST_CURR_RATE)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_currency_rate_date` SET TAGS ('dbx_business_glossary_term' = 'Cost Currency Rate Date (COST_CURR_RATE_DATE)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_date` SET TAGS ('dbx_business_glossary_term' = 'Cost Date (COST_DATE)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_description` SET TAGS ('dbx_business_glossary_term' = 'Cost Description (COST_DESC)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_end_date` SET TAGS ('dbx_business_glossary_term' = 'Cost End Date (COST_END_DATE)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_invoice_date` SET TAGS ('dbx_business_glossary_term' = 'Cost Invoice Date (COST_INV_DATE)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Cost Invoice Number (COST_INV_NUM)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_invoiced_date` SET TAGS ('dbx_business_glossary_term' = 'Cost Invoiced Date (COST_INV_DATE)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_notes` SET TAGS ('dbx_business_glossary_term' = 'Cost Notes (COST_NOTES)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_paid_date` SET TAGS ('dbx_business_glossary_term' = 'Cost Paid Date (COST_PAID_DATE)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_payment_date` SET TAGS ('dbx_business_glossary_term' = 'Cost Payment Date (COST_PAY_DATE)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_payment_method` SET TAGS ('dbx_business_glossary_term' = 'Cost Payment Method (COST_PAY_METHOD)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_payment_method` SET TAGS ('dbx_value_regex' = 'bank_transfer|check|credit_card|wire_transfer');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_payment_status` SET TAGS ('dbx_business_glossary_term' = 'Cost Payment Status (COST_PAY_STATUS)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_payment_status` SET TAGS ('dbx_value_regex' = 'pending|completed|failed');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_start_date` SET TAGS ('dbx_business_glossary_term' = 'Cost Start Date (COST_START_DATE)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_status` SET TAGS ('dbx_business_glossary_term' = 'Cost Status (COST_STATUS)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_status` SET TAGS ('dbx_value_regex' = 'budgeted|accrued|invoiced|paid|reconciled|cancelled');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Cost Tax Amount (COST_TAX_AMT)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_tax_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Tax Code (COST_TAX_CODE)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_tax_code` SET TAGS ('dbx_value_regex' = 'GST|VAT|HST|PST|QST|NONE');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Cost Tax Rate (COST_TAX_RATE)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_type` SET TAGS ('dbx_business_glossary_term' = 'Cost Type (COST_TYPE)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `cost_type` SET TAGS ('dbx_value_regex' = 'fixed|capped|hourly|success_based');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'DD Advisor Cost Created At (DDAC_CREATED_AT)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Currency (CURR)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `dd_advisor_cost_status` SET TAGS ('dbx_business_glossary_term' = 'DD Advisor Cost Status (DDAC_STATUS)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `dd_advisor_cost_status` SET TAGS ('dbx_value_regex' = 'budgeted|accrued|invoiced|paid|reconciled|cancelled');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger Account Code (GL_ACCT_CODE)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `invoiced_amount` SET TAGS ('dbx_business_glossary_term' = 'Invoiced Amount (INV_AMT)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Amount (PAID_AMT)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `reference` SET TAGS ('dbx_business_glossary_term' = 'DD Advisor Cost Reference (DDAC_REF)');
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'DD Advisor Cost Updated At (DDAC_UPDATED_AT)');
ALTER TABLE `asset_management`.`diligence`.`assessment` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`diligence`.`assessment` SET TAGS ('dbx_domain' = 'diligence');
ALTER TABLE `asset_management`.`diligence`.`assessment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`diligence`.`assessment` SET TAGS ('dbx_subdomain' = 'compliance_approval');
ALTER TABLE `asset_management`.`diligence`.`assessment` SET TAGS ('dbx_association_edges' = 'diligence.dd_engagement,compliance.rule');
ALTER TABLE `asset_management`.`diligence`.`assessment` ALTER COLUMN `applicability_status` SET TAGS ('dbx_business_glossary_term' = 'Rule Applicability Status');
ALTER TABLE `asset_management`.`diligence`.`assessment` ALTER COLUMN `assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Compliance Assessment Date');
ALTER TABLE `asset_management`.`diligence`.`assessment` ALTER COLUMN `compliance_rating` SET TAGS ('dbx_business_glossary_term' = 'Compliance Rating');
ALTER TABLE `asset_management`.`diligence`.`assessment` ALTER COLUMN `remediation_required` SET TAGS ('dbx_business_glossary_term' = 'Remediation Required Flag');
