-- Schema for Domain: deal | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:25

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`deal` COMMENT 'Domain for deal origination, sourcing, and investment pipeline management covering both off-market and intermediated opportunities across all asset classes.';
ALTER SCHEMA `asset_management`.`deal` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `asset_management`.`deal` SET TAGS ('dbx_domain' = 'deal');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`deal`.`opportunity` (
    `opportunity_id` BIGINT COMMENT 'Unique identifier for the investment opportunity record. Primary key for the opportunity entity.',
    `asset_class_outlook_id` BIGINT COMMENT 'Foreign key linking to research.asset_class_outlook. Business justification: Every deal opportunity is evaluated against asset class return expectations and allocation targets. IC presentations compare deal IRR to asset class outlook expected returns.',
    `climate_scenario_id` BIGINT COMMENT 'Foreign key linking to esg.climate_scenario. Business justification: Opportunities undergo ESG stress testing under a selected climate scenario to evaluate resilience to climate risks.',
    `country_outlook_id` BIGINT COMMENT 'Foreign key linking to research.country_outlook. Business justification: Global pension funds assess country risk for every cross-border deal. IC submissions require country outlook assessment for sovereign/political risk.',
    `data_provider_id` BIGINT COMMENT 'Foreign key linking to esg.data_provider. Business justification: ESG data for an opportunity is sourced from a specific data provider; tracking the provider ensures data provenance.',
    `esg_benchmark_id` BIGINT COMMENT 'Foreign key linking to esg.esg_benchmark. Business justification: Opportunities are benchmarked against a chosen ESG benchmark to assess relative performance and risk.',
    `esg_policy_id` BIGINT COMMENT 'Foreign key linking to esg.policy. Business justification: Every opportunity must align with a defined ESG policy that sets inclusion/exclusion criteria for the pension fund.',
    `framework_id` BIGINT COMMENT 'Foreign key linking to esg.framework. Business justification: Each opportunity is evaluated against a specific ESG framework; the investment team selects the framework during opportunity creation.',
    `origination_source_id` BIGINT COMMENT 'Foreign key linking to deal.origination_source. Business justification: Opportunity records originate from a specific source; adding a FK to origination_source links the siloed origination_source table and captures the source of each opportunity.',
    `sector_outlook_id` BIGINT COMMENT 'Foreign key linking to research.sector_outlook. Business justification: Deal screening and IC presentations require current sector views. Investment committees evaluate opportunities against sector outlook ratings and conviction levels.',
    `target_entity_id` BIGINT COMMENT 'Foreign key linking to deal.target_entity. Business justification: Opportunity should reference the target entity; adding a FK to target_entity removes redundant columns and ensures consistency across the model.',
    `actual_close_date` DATE COMMENT 'Actual date on which the transaction closed and capital was deployed, if applicable.',
    `asset_class` STRING COMMENT 'Primary asset class category of the opportunity aligned with Strategic Asset Allocation (SAA) framework.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `opportunity_code` STRING COMMENT 'Internal tracking code or reference number assigned to the opportunity for pipeline management and reporting purposes.',
    `confidentiality_level` STRING COMMENT 'Data classification level governing access and distribution of opportunity information within the organization.. Valid values are `public|internal|confidential|highly_confidential`',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp indicating when the opportunity record was first created in the pipeline management system.',
    `data_room_url` STRING COMMENT 'Web address or link to the virtual data room containing confidential due diligence materials for the opportunity.',
    `decline_reason` STRING COMMENT 'Primary rationale for declining or passing on the opportunity, captured for pipeline analytics and lessons learned.',
    `esg_exclusion_flag` BOOLEAN COMMENT 'Boolean indicator of whether the opportunity triggers any ESG exclusion criteria per the funds responsible investment policy.',
    `esg_rating` STRING COMMENT 'Preliminary Environmental, Social, and Governance rating or score assigned during initial screening, aligned with MSCI ESG or equivalent rating methodology.',
    `expected_close_date` DATE COMMENT 'Anticipated date for final transaction closing and capital deployment.',
    `expected_hold_period_years` DECIMAL(4,1) COMMENT 'Anticipated investment holding period in years from initial capital deployment to full exit or realization.',
    `expected_investment_amount` DECIMAL(18,2) COMMENT 'Anticipated capital commitment or investment size in base currency for this opportunity.',
    `gp_sponsor_name` STRING COMMENT 'Name of the General Partner, fund manager, or sponsor presenting or managing the opportunity.',
    `ic_decision` STRING COMMENT 'Final decision outcome from the Investment Committee regarding the opportunity.. Valid values are `approved|declined|conditional|deferred`',
    `ic_decision_date` DATE COMMENT 'Date on which the Investment Committee rendered a formal decision on the opportunity.',
    `ic_submission_date` DATE COMMENT 'Date on which the opportunity was formally submitted to the Investment Committee for approval consideration.',
    `intermediary_name` STRING COMMENT 'Name of the investment bank, advisor, or intermediary facilitating the opportunity, if applicable.',
    `investment_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the expected investment amount.. Valid values are `^[A-Z]{3}$`',
    `investment_thesis` STRING COMMENT 'High-level strategic rationale and value creation hypothesis for pursuing the opportunity, including expected return drivers and risk-adjusted return profile.',
    `is_active` BOOLEAN COMMENT 'Boolean flag indicating whether the opportunity is currently active in the pipeline or has been archived or closed.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'System timestamp indicating when the opportunity record was most recently updated or modified.',
    `lead_investment_professional` STRING COMMENT 'Name of the internal investment team member responsible for originating and managing the opportunity through the pipeline.',
    `loi_status` STRING COMMENT 'Current status of the Letter of Intent submission indicating preliminary commitment interest.. Valid values are `not_submitted|draft|submitted|accepted|rejected`',
    `loi_submission_date` DATE COMMENT 'Date on which the Letter of Intent was formally submitted to the General Partner (GP) or seller.',
    `opportunity_name` STRING COMMENT 'Business name or title of the investment opportunity as presented by the General Partner (GP) or intermediary.',
    `nda_execution_date` DATE COMMENT 'Date on which the Non-Disclosure Agreement was fully executed by all parties.',
    `nda_status` STRING COMMENT 'Current status of the Non-Disclosure Agreement required to access confidential information for the opportunity.. Valid values are `not_required|pending|executed|expired`',
    `notes` STRING COMMENT 'Free-text field for capturing additional context, observations, or commentary relevant to the opportunity evaluation and pipeline management.',
    `opportunity_status` STRING COMMENT 'Current lifecycle stage of the opportunity in the investment pipeline workflow. [ENUM-REF-CANDIDATE: prospecting|screening|due_diligence|ic_review|approved|declined|on_hold|closed — 8 candidates stripped; promote to reference product]',
    `opportunity_type` STRING COMMENT 'Classification of the investment structure: direct investment, co-investment alongside a General Partner (GP), fund commitment, secondary market transaction, joint venture, or club deal.. Valid values are `direct|co_investment|fund_commitment|secondary|joint_venture|club_deal`',
    `origination_date` DATE COMMENT 'Date when the opportunity was first identified and entered into the deal pipeline system.',
    `priority_tier` STRING COMMENT 'Internal prioritization ranking for resource allocation and pipeline management, with Tier 1 representing highest priority opportunities.. Valid values are `tier_1|tier_2|tier_3|tier_4`',
    `risk_rating` STRING COMMENT 'Preliminary risk assessment classification based on initial screening and due diligence findings.. Valid values are `low|medium|high|very_high`',
    `sourcing_channel` STRING COMMENT 'Method by which the opportunity was originated: proprietary off-market deal, GP-introduced, intermediated through advisor, inbound inquiry, or network referral.. Valid values are `proprietary|gp_introduced|intermediated|inbound|network_referral`',
    `strategic_fit_score` BIGINT COMMENT 'Quantitative score (typically 1-10 scale) assessing alignment with Strategic Asset Allocation (SAA) and portfolio construction objectives.',
    `sub_asset_class` STRING COMMENT 'Granular sub-category within the primary asset class for detailed portfolio segmentation and reporting.',
    `target_irr_percent` DECIMAL(5,2) COMMENT 'Expected annualized Internal Rate of Return (IRR) for the opportunity expressed as a percentage, used for investment committee evaluation.',
    `target_moic` DECIMAL(5,2) COMMENT 'Expected gross multiple of invested capital (MOIC) representing total value divided by paid-in capital.',
    `vintage_year` BIGINT COMMENT 'Year in which the investment commitment or capital deployment is expected to occur, used for cohort analysis and performance benchmarking.',
    CONSTRAINT pk_opportunity PRIMARY KEY(`opportunity_id`)
) COMMENT 'Core master record (SSOT) for every investment opportunity entering the pipeline—off-market/proprietary, GP-introduced, or intermediated—across all asset classes.';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`pipeline_stage` (
    `pipeline_stage_id` BIGINT COMMENT 'Unique identifier for the pipeline stage record.',
    `alternate_exit_stages` STRING COMMENT 'Comma-separated list of stage codes representing valid non-sequential exit paths (e.g., rejection, withdrawal, fast-track approval).',
    `applicable_asset_classes` STRING COMMENT 'Comma-separated list of asset classes for which this stage is applicable (e.g., Private Equity, Real Estate, Infrastructure, Credit). Empty if applicable to all.',
    `applicable_deal_types` STRING COMMENT 'Comma-separated list of deal types for which this stage is applicable (e.g., Direct Investment, Co-Investment, Fund Commitment, Secondary). Empty if applicable to all.',
    `compliance_checkpoints` STRING COMMENT 'Comma-separated list of regulatory, legal, or internal compliance checks required at this stage (e.g., KYC, AML, EMIR, SFDR pre-contractual disclosure).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this pipeline stage record was first created in the system.',
    `effective_from_date` DATE COMMENT 'Date from which this pipeline stage definition became effective and available for use in deal workflows.',
    `effective_to_date` DATE COMMENT 'Date until which this pipeline stage definition remains effective. Null indicates the stage is currently active with no planned end date.',
    `entry_criteria` STRING COMMENT 'Textual description of conditions or prerequisites that must be met for a deal to enter this stage.',
    `escalation_contact` STRING COMMENT 'Role, title, or individual to whom deals are escalated when escalation threshold is breached.',
    `escalation_threshold_days` BIGINT COMMENT 'Number of days in stage after which automatic escalation or alert is triggered to senior management or deal governance committee.',
    `esg_review_required` BOOLEAN COMMENT 'Indicates whether an Environmental, Social, and Governance (ESG) assessment is required at this stage per PRI and SFDR obligations.',
    `exit_criteria` STRING COMMENT 'Textual description of conditions, deliverables, or approvals required for a deal to exit this stage and progress to the next.',
    `governance_framework` STRING COMMENT 'Reference to the governance policy, Investment Committee (IC) charter, or procedural document governing this stage.',
    `ic_submission_required` BOOLEAN COMMENT 'Indicates whether a formal Investment Committee (IC) submission and Investment Memorandum (IM) are required at this stage.',
    `is_active` BOOLEAN COMMENT 'Indicates whether this pipeline stage is currently active and available for use in deal workflows.',
    `is_approval_gate` BOOLEAN COMMENT 'Indicates whether this stage requires formal Investment Committee (IC) or other governance approval before progression.',
    `is_terminal` BOOLEAN COMMENT 'Indicates whether this stage represents a terminal state (deal closed, deal rejected, deal withdrawn) with no further progression.',
    `legal_review_required` BOOLEAN COMMENT 'Indicates whether legal counsel review and sign-off is required before exiting this stage.',
    `maximum_dwell_days` BIGINT COMMENT 'Maximum allowable calendar days in this stage before escalation or review is triggered, preventing pipeline stagnation.',
    `minimum_dwell_days` BIGINT COMMENT 'Minimum number of calendar days a deal must remain in this stage before progression, enforcing process discipline and thoroughness.',
    `predecessor_stage_code` STRING COMMENT 'Stage code of the immediately preceding stage in the standard pipeline sequence. Null for the first stage.',
    `reporting_label` STRING COMMENT 'Abbreviated or alternative label used for this stage in executive reports, dashboards, and external communications.',
    `required_approvers` STRING COMMENT 'Comma-separated list or structured text identifying roles or individuals whose approval is required to exit this stage (e.g., CIO, IC Chair, Legal Counsel).',
    `required_deliverables` STRING COMMENT 'Comma-separated list or structured text defining mandatory deliverables, documents, or milestones required for stage completion (e.g., NDA, LOI, IM, FDD report).',
    `risk_assessment_required` BOOLEAN COMMENT 'Indicates whether a formal risk assessment or risk rating is required before exiting this stage.',
    `stage_category` STRING COMMENT 'High-level grouping of the stage within the investment lifecycle (origination, screening, diligence, approval, execution, post-close).. Valid values are `origination|screening|diligence|approval|execution|post_close`',
    `stage_code` STRING COMMENT 'Short alphanumeric code uniquely identifying the pipeline stage (e.g., SCREEN, DD, IC_PREP, IC_APPR, CLOSING).. Valid values are `^[A-Z0-9_]{2,20}$`',
    `stage_color_code` STRING COMMENT 'Hexadecimal color code used for visual representation of this stage in dashboards and reporting tools (e.g., #4CAF50 for green).. Valid values are `^#[0-9A-Fa-f]{6}$`',
    `stage_description` STRING COMMENT 'Detailed narrative description of the purpose, activities, and objectives of this pipeline stage.',
    `stage_icon` STRING COMMENT 'Icon identifier or Unicode character used for visual representation of this stage in user interfaces.',
    `stage_name` STRING COMMENT 'Full descriptive name of the pipeline stage (e.g., Initial Screening, Due Diligence, Investment Committee Approval).',
    `stage_notes` STRING COMMENT 'Free-form text field for additional notes, guidance, or context relevant to this pipeline stage.',
    `stage_owner_role` STRING COMMENT 'Role or function responsible for managing and driving deals through this stage (e.g., Deal Lead, Due Diligence Manager, Legal Counsel).',
    `stage_sequence` BIGINT COMMENT 'Numeric ordering of the stage within the deal pipeline lifecycle, enabling chronological sorting and progression tracking.',
    `stage_type` STRING COMMENT 'Classification indicating whether the stage is mandatory for all deals, optional, or conditional based on deal characteristics.. Valid values are `mandatory|optional|conditional`',
    `successor_stage_code` STRING COMMENT 'Stage code of the immediately following stage in the standard pipeline sequence. Null for terminal stages.',
    `target_dwell_days` BIGINT COMMENT 'Target number of calendar days for deal completion within this stage, used for pipeline velocity tracking and performance management.',
    `updated_by` STRING COMMENT 'User identifier or name of the individual who last modified this pipeline stage record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this pipeline stage record was last modified.',
    `valuation_required` BOOLEAN COMMENT 'Indicates whether a formal valuation (DCF, comparable company analysis, or third-party appraisal) is required at this stage.',
    `version_number` BIGINT COMMENT 'Version number of this stage definition, incremented when stage attributes, criteria, or deliverables are modified.',
    `created_by` STRING COMMENT 'User identifier or name of the individual who created this pipeline stage record.',
    CONSTRAINT pk_pipeline_stage PRIMARY KEY(`pipeline_stage_id`)
) COMMENT 'Reference taxonomy defining the ordered stages of the deal pipeline lifecycle—from initial screening through IC approval and closing. Captures stage code, stage name, stage sequence order, minimum dwell days, required deliverables checklist, stage';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`stage_transition` (
    `stage_transition_id` BIGINT COMMENT 'Unique identifier for the stage transition event record.',
    `deal_ic_submission_id` BIGINT COMMENT 'Reference to the Investment Committee submission record associated with this transition.',
    `employee_id` BIGINT COMMENT 'Reference to the user who approved or executed this stage transition.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal opportunity that underwent this stage transition.',
    `pipeline_stage_id` BIGINT COMMENT 'Foreign key linking to deal.pipeline_stage. Business justification: Stage_transition records transitions between pipeline stages; adding a FK to pipeline_stage enforces referential integrity and connects the siloed pipeline_stage table.',
    `approving_committee` STRING COMMENT 'Name of the Investment Committee or governance body that approved this transition, if applicable.',
    `approving_user_name` STRING COMMENT 'Full name of the user who approved or executed this stage transition, captured for audit trail.',
    `conditions_imposed` STRING COMMENT 'List of conditions or requirements imposed as part of a conditional approval decision.',
    `cumulative_days_in_pipeline` BIGINT COMMENT 'Total number of calendar days the opportunity has been in the pipeline as of this transition.',
    `days_in_prior_stage` BIGINT COMMENT 'Number of calendar days the opportunity spent in the prior stage before this transition.',
    `decision_outcome` STRING COMMENT 'Result of the gate or screening decision: pass (approved to advance), fail (rejected), conditional (approved with conditions), deferred (postponed), withdrawn (sponsor pulled).. Valid values are `pass|fail|conditional|deferred|withdrawn`',
    `decision_type` STRING COMMENT 'Nature of the decision that triggered the transition: automatic (system-driven), manual (user-initiated), ic_decision (Investment Committee), screening (preliminary filter), gate_review (formal checkpoint).. Valid values are `automatic|manual|ic_decision|screening|gate_review`',
    `gate_criteria_checklist` STRING COMMENT 'Summary of gate criteria evaluated and their pass/fail status for this transition.',
    `gate_criteria_met` BOOLEAN COMMENT 'Indicates whether all formal gate criteria were satisfied for this transition.',
    `ic_approval_received` BOOLEAN COMMENT 'Indicates whether Investment Committee approval was obtained for this transition.',
    `ic_meeting_date` DATE COMMENT 'Date of the Investment Committee meeting where this transition decision was made, if applicable.',
    `is_active` BOOLEAN COMMENT 'Indicates whether this stage transition record is currently active and valid for reporting.',
    `is_milestone_transition` BOOLEAN COMMENT 'Indicates whether this transition represents a major milestone in the deal lifecycle.',
    `milestone_name` STRING COMMENT 'Name of the milestone achieved if this is a milestone transition.',
    `new_stage_code` STRING COMMENT 'Code representing the pipeline stage the opportunity moved to in this transition.',
    `new_stage_name` STRING COMMENT 'Human-readable name of the pipeline stage the opportunity moved to in this transition.',
    `notification_sent` BOOLEAN COMMENT 'Indicates whether stakeholder notifications were sent for this stage transition.',
    `notification_timestamp` TIMESTAMP COMMENT 'Date and time when stakeholder notifications were sent for this transition.',
    `prior_stage_code` STRING COMMENT 'Code representing the pipeline stage the opportunity was in before this transition.',
    `prior_stage_name` STRING COMMENT 'Human-readable name of the pipeline stage the opportunity was in before this transition.',
    `record_created_by` STRING COMMENT 'User or system identifier that created this stage transition record.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Date and time when this stage transition record was first created in the system.',
    `record_updated_by` STRING COMMENT 'User or system identifier that last modified this stage transition record.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Date and time when this stage transition record was last modified.',
    `rejection_reason` STRING COMMENT 'Specific reason for rejection if the transition represents a negative decision or deal termination.',
    `requires_ic_approval` BOOLEAN COMMENT 'Indicates whether this stage transition required formal Investment Committee approval.',
    `source_system_code` STRING COMMENT 'Unique identifier of this transition record in the source operational system.',
    `supporting_document_count` BIGINT COMMENT 'Number of supporting documents attached to this stage transition for audit and review purposes.',
    `system_generated` BOOLEAN COMMENT 'Indicates whether this transition was automatically generated by the system versus manually recorded by a user.',
    `transition_date` DATE COMMENT 'Calendar date of the stage transition, used for day-level reporting and analytics.',
    `transition_notes` STRING COMMENT 'Free-text notes and commentary captured during the stage transition, providing additional context.',
    `transition_number` STRING COMMENT 'Business-facing identifier for this stage transition event, used for audit trail and reporting purposes.',
    `transition_reason_code` STRING COMMENT 'Standardized code indicating the primary reason for the stage transition.',
    `transition_reason_description` STRING COMMENT 'Detailed explanation of why the stage transition occurred, capturing business rationale and context.',
    `transition_sequence_number` BIGINT COMMENT 'Sequential order of this transition within the opportunity lifecycle, starting from 1.',
    `transition_timestamp` TIMESTAMP COMMENT 'Precise date and time when the stage transition occurred, capturing the business event moment.',
    `transition_type` STRING COMMENT 'Classification of the transition movement: advance (forward progress), retreat (moved back), reopen (reactivated), reject (declined), approve (gate passed), hold (paused).. Valid values are `advance|retreat|reopen|reject|approve|hold`',
    CONSTRAINT pk_stage_transition PRIMARY KEY(`stage_transition_id`)
) COMMENT 'Transactional audit record capturing every pipeline-gate event for an opportunity—both mechanical stage advances and formal go/no-go screening decisions. Records the opportunity, prior stage, new stage, transition date/timestamp, approving';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`nda` (
    `nda_id` BIGINT COMMENT 'Unique identifier for the non-disclosure agreement record.',
    `counterparty_id` BIGINT COMMENT 'Reference to the legal entity with whom the NDA is executed.',
    `counterparty_legal_entity_counterparty_id` BIGINT COMMENT 'Reference to the legal entity with whom the NDA is executed.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the deal opportunity this NDA supports.',
    `employee_id` BIGINT COMMENT 'Reference to the user who created this NDA record.',
    `last_modified_by_user_employee_id` BIGINT COMMENT 'Reference to the user who last modified this NDA record.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal opportunity this NDA supports.',
    `superseded_by_nda_id` BIGINT COMMENT 'Reference to a subsequent NDA that replaces or supersedes this agreement.',
    `asset_class` STRING COMMENT 'Primary asset class associated with the deal opportunity covered by this NDA.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `breach_description` STRING COMMENT 'Detailed description of the nature and circumstances of any reported NDA breach.',
    `breach_reported_flag` BOOLEAN COMMENT 'Indicates whether a breach or suspected breach of the NDA has been reported.',
    `confidentiality_period_years` DECIMAL(5,2) COMMENT 'Duration in years for which confidential information must be protected under the NDA.',
    `counterparty_signatory_name` STRING COMMENT 'Full name of the individual who signed the NDA on behalf of the counterparty.',
    `counterparty_signatory_title` STRING COMMENT 'Job title or role of the counterparty signatory (e.g., Chief Executive Officer, General Counsel).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this NDA record was first created in the system.',
    `data_room_access_granted_flag` BOOLEAN COMMENT 'Indicates whether the NDA has been executed and data room access has been granted to the investment team.',
    `data_room_url` STRING COMMENT 'Web address or link to the virtual data room where confidential materials are hosted.',
    `deal_origination_source` STRING COMMENT 'Channel through which the deal opportunity was sourced, determining NDA negotiation context.. Valid values are `off_market|intermediated|co_investment|secondary|proprietary`',
    `disclosure_to_advisors_permitted_flag` BOOLEAN COMMENT 'Indicates whether the NDA permits disclosure of confidential information to external advisors (legal, financial, operational) under confidentiality.',
    `dispute_resolution_mechanism` STRING COMMENT 'Agreed method for resolving disputes arising under the NDA.. Valid values are `litigation|arbitration|mediation`',
    `document_storage_location` STRING COMMENT 'File path or document management system reference where the executed NDA is stored.',
    `effective_date` DATE COMMENT 'Date from which the confidentiality obligations under the NDA commence.',
    `estimated_deal_size_usd_millions` DECIMAL(15,2) COMMENT 'Estimated transaction size in millions of US dollars at the time of NDA execution.',
    `execution_date` DATE COMMENT 'Date on which the NDA was fully executed by all parties and became legally binding.',
    `expiry_date` DATE COMMENT 'Date on which the NDA confidentiality obligations expire, if applicable. Null for perpetual NDAs.',
    `external_counsel_firm` STRING COMMENT 'Name of the external law firm that advised on or reviewed the NDA, if applicable.',
    `governing_law_jurisdiction` STRING COMMENT 'Legal jurisdiction whose laws govern the interpretation and enforcement of the NDA (e.g., New York, England and Wales).',
    `intermediary_firm_name` STRING COMMENT 'Name of the investment bank, broker, or advisor facilitating the deal, if applicable.',
    `internal_counsel_approval_flag` BOOLEAN COMMENT 'Indicates whether the NDA has been reviewed and approved by internal legal counsel.',
    `internal_signatory_name` STRING COMMENT 'Full name of the individual who signed the NDA on behalf of the pension fund.',
    `internal_signatory_title` STRING COMMENT 'Job title or role of the internal signatory (e.g., Senior Managing Director, Chief Investment Officer).',
    `is_perpetual` BOOLEAN COMMENT 'Indicates whether the NDA has no expiry date and confidentiality obligations continue indefinitely.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this NDA record was last updated.',
    `nda_status` STRING COMMENT 'Current lifecycle status of the NDA indicating its enforceability and workflow state.. Valid values are `draft|pending_signature|executed|expired|terminated|superseded`',
    `nda_type` STRING COMMENT 'Classification of the NDA structure: mutual (both parties bound), one-way (unilateral), or multilateral (multiple parties).. Valid values are `mutual|one-way|multilateral`',
    `non_solicitation_flag` BOOLEAN COMMENT 'Indicates whether the NDA includes a non-solicitation clause prohibiting hiring or soliciting employees of the disclosing party.',
    `notes` STRING COMMENT 'Free-text field for additional context, special terms, or internal observations regarding the NDA.',
    `permitted_use_scope` STRING COMMENT 'Description of the permitted purposes for which confidential information may be used (e.g., evaluation of investment opportunity, due diligence).',
    `reference_number` STRING COMMENT 'Externally-known unique reference number or code assigned to this NDA for tracking and retrieval.',
    `regulatory_disclosure_carveout_flag` BOOLEAN COMMENT 'Indicates whether the NDA includes a carveout permitting disclosure to regulatory authorities or as required by law.',
    `remediation_action_taken` STRING COMMENT 'Description of corrective or remedial actions taken in response to an NDA breach.',
    `return_or_destroy_obligation_flag` BOOLEAN COMMENT 'Indicates whether the NDA requires the receiving party to return or destroy confidential materials upon request or termination.',
    `standstill_period_months` BIGINT COMMENT 'Duration in months for which the standstill provision applies, if present.',
    `standstill_provision_flag` BOOLEAN COMMENT 'Indicates whether the NDA includes a standstill clause restricting the counterparty from making unsolicited offers or acquiring securities.',
    `target_company_name` STRING COMMENT 'Name of the target company or asset that is the subject of the confidential evaluation.',
    `target_geography` STRING COMMENT 'Primary geographic location or jurisdiction of the target asset or company.',
    `template_version` STRING COMMENT 'Version identifier of the NDA template used as the basis for this agreement.',
    `termination_date` DATE COMMENT 'Date on which the NDA was formally terminated prior to its natural expiry, if applicable.',
    CONSTRAINT pk_nda PRIMARY KEY(`nda_id`)
) COMMENT 'Master record for Non-Disclosure Agreements executed in connection with deal origination and due diligence. Captures NDA type (mutual/one-way), counterparty legal entity, execution date, expiry date, governing law jurisdiction, NDA status (draft';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`loi` (
    `loi_id` BIGINT COMMENT 'Unique identifier for the Letter of Intent record.',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: LOIs are negotiated with counterparties. Linking enables credit/collateral status assessment during deal negotiation, supports counterparty due diligence, and enforces 3NF by removing',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the deal opportunity in the pipeline that this LOI supports.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal opportunity in the pipeline that this LOI supports.',
    `superseded_by_loi_id` BIGINT COMMENT 'Reference to a subsequent LOI that supersedes this one.',
    `acceptance_date` DATE COMMENT 'Date on which the counterparty formally accepted the LOI terms.',
    `advisor_firm_name` STRING COMMENT 'Name of the external advisory firm (investment bank, broker, consultant) facilitating the transaction.',
    `asset_class` STRING COMMENT 'Primary asset class category of the investment opportunity covered by this LOI.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `break_fee_amount` DECIMAL(18,2) COMMENT 'Monetary penalty payable if either party terminates the LOI under specified conditions.',
    `conditions_precedent` STRING COMMENT 'Summary of key conditions that must be satisfied before the LOI becomes effective or binding.',
    `confidentiality_clause_flag` BOOLEAN COMMENT 'Indicates whether the LOI includes a confidentiality clause binding the parties.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this LOI record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in the LOI.. Valid values are `^[A-Z]{3}$`',
    `deposit_amount` DECIMAL(18,2) COMMENT 'Good faith deposit or earnest money amount required under the LOI terms.',
    `deposit_due_date` DATE COMMENT 'Date by which the deposit amount must be paid.',
    `due_diligence_period_days` BIGINT COMMENT 'Number of days allocated for conducting due diligence as specified in the LOI.',
    `exclusivity_end_date` DATE COMMENT 'Date on which the exclusivity period ends.',
    `exclusivity_flag` BOOLEAN COMMENT 'Indicates whether the LOI includes an exclusivity provision preventing the seller from negotiating with other parties.',
    `exclusivity_start_date` DATE COMMENT 'Date from which the exclusivity period begins, preventing the seller from negotiating with other parties.',
    `expiry_date` DATE COMMENT 'Date on which the LOI terms expire and are no longer valid unless extended or accepted.',
    `financing_contingency_flag` BOOLEAN COMMENT 'Indicates whether the LOI is contingent upon securing financing.',
    `geographic_region` STRING COMMENT 'Primary geographic region or country where the target asset or entity operates.',
    `governing_law` STRING COMMENT 'Jurisdiction and legal framework governing the LOI (e.g., New York law, English law).',
    `ic_approval_date` DATE COMMENT 'Date on which the Investment Committee approved the LOI issuance.',
    `ic_approval_required_flag` BOOLEAN COMMENT 'Indicates whether Investment Committee approval is required before the LOI can be finalized.',
    `ic_submission_date` DATE COMMENT 'Date on which the LOI and supporting Investment Memorandum (IM) were submitted to the Investment Committee.',
    `indicative_enterprise_value` DECIMAL(18,2) COMMENT 'Proposed total enterprise value of the target asset or company as stated in the LOI.',
    `indicative_equity_value` DECIMAL(18,2) COMMENT 'Proposed equity value of the target asset or company as stated in the LOI.',
    `investment_strategy` STRING COMMENT 'Specific investment strategy or sub-strategy applicable to this LOI (e.g., growth equity, value-add real estate, core infrastructure).',
    `issuance_date` DATE COMMENT 'Date on which the LOI was formally issued to the counterparty.',
    `lead_investment_professional` STRING COMMENT 'Name of the lead investment professional or deal team member responsible for this LOI.',
    `loi_status` STRING COMMENT 'Current lifecycle state of the LOI in the negotiation process. [ENUM-REF-CANDIDATE: draft|issued|accepted|rejected|expired|withdrawn|superseded — 7 candidates stripped; promote to reference product]',
    `loi_type` STRING COMMENT 'Classification of the LOI indicating whether it creates legally binding obligations or is indicative only.. Valid values are `binding|non-binding|conditional`',
    `nda_reference_number` STRING COMMENT 'Reference number of the NDA executed prior to LOI issuance.',
    `notes` STRING COMMENT 'Free-text field for additional comments, clarifications, or internal notes regarding the LOI.',
    `number` STRING COMMENT 'Externally-known unique business identifier for the LOI document.. Valid values are `^LOI-[0-9]{6,10}$`',
    `proposed_deal_structure` STRING COMMENT 'Type of transaction structure proposed in the LOI.. Valid values are `asset_purchase|share_purchase|merger|joint_venture|co_investment|secondary_transaction`',
    `proposed_ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage of ownership stake proposed to be acquired, expressed as a decimal (e.g., 51.00 for 51%).',
    `regulatory_approval_required_flag` BOOLEAN COMMENT 'Indicates whether the transaction requires regulatory or governmental approval.',
    `rejection_date` DATE COMMENT 'Date on which the counterparty formally rejected the LOI.',
    `sector` STRING COMMENT 'Industry sector of the target entity or asset (e.g., technology, healthcare, energy).',
    `target_entity_name` STRING COMMENT 'Legal name of the target company or asset being acquired.',
    `target_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier of the target entity if available.. Valid values are `^[A-Z0-9]{20}$`',
    `term_sheet_reference_number` STRING COMMENT 'Reference number of the term sheet that preceded or accompanies this LOI.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this LOI record was last modified.',
    `withdrawal_date` DATE COMMENT 'Date on which the issuing party withdrew the LOI.',
    CONSTRAINT pk_loi PRIMARY KEY(`loi_id`)
) COMMENT 'Master record for Letters of Intent issued during deal origination and early negotiation. Captures LOI type (binding/non-binding), issuance date, expiry date, indicative enterprise value, indicative equity value, proposed deal structure, exclusivity';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`term_sheet` (
    `term_sheet_id` BIGINT COMMENT 'Unique identifier for the term sheet record. Primary key.',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: Term sheets specify deal terms with counterparties. Linking enables credit assessment during deal structuring, exposure monitoring, and enforces 3NF by removing denormalized',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the parent deal opportunity in the investment pipeline.',
    `opportunity_id` BIGINT COMMENT 'Reference to the parent deal opportunity in the investment pipeline.',
    `advisor_firm_name` STRING COMMENT 'Name of the external advisor or intermediary firm facilitating the transaction.',
    `asset_class` STRING COMMENT 'Primary asset class category for the proposed investment.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `binding_status` BOOLEAN COMMENT 'Indicates whether the term sheet is legally binding or non-binding.',
    `carried_interest_percent` DECIMAL(5,2) COMMENT 'Percentage of profits allocated to the General Partner (GP) as performance fee.',
    `closing_conditions` STRING COMMENT 'Key conditions precedent that must be satisfied before transaction closing.',
    `created_by_user` STRING COMMENT 'User identifier of the person who created the term sheet record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the term sheet record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the investment amount.. Valid values are `^[A-Z]{3}$`',
    `deal_structure_type` STRING COMMENT 'Proposed structure of the investment transaction.. Valid values are `equity|debt|hybrid|co_investment|direct_investment|fund_commitment`',
    `document_storage_path` STRING COMMENT 'File path or URI to the physical term sheet document in the document management system.',
    `due_diligence_period_days` BIGINT COMMENT 'Number of days allocated for completion of due diligence activities.',
    `ebitda_multiple` DECIMAL(8,2) COMMENT 'Valuation multiple expressed as enterprise value divided by EBITDA.',
    `enterprise_value` DECIMAL(18,2) COMMENT 'Proposed enterprise value of the target asset or company.',
    `equity_value` DECIMAL(18,2) COMMENT 'Proposed equity value of the target asset or company.',
    `esg_considerations` STRING COMMENT 'Summary of ESG factors and responsible investment considerations relevant to the term sheet.',
    `exclusivity_period_days` BIGINT COMMENT 'Number of days during which the counterparty grants exclusive negotiation rights.',
    `expiry_date` DATE COMMENT 'Date by which the term sheet offer expires if not accepted.',
    `governance_rights` STRING COMMENT 'Summary of proposed governance rights including board seats, veto rights, and consent provisions.',
    `hurdle_rate_percent` DECIMAL(5,2) COMMENT 'Minimum preferred return threshold before carried interest is earned, expressed as percentage.',
    `ic_submission_planned_date` DATE COMMENT 'Planned date for submission of the investment opportunity to the Investment Committee.',
    `investment_horizon_years` BIGINT COMMENT 'Expected holding period for the investment expressed in years.',
    `investment_type` STRING COMMENT 'Classification of the investment opportunity by transaction type.. Valid values are `primary|secondary|co_invest|direct|fund_of_funds`',
    `issuance_date` DATE COMMENT 'Date the term sheet was formally issued to the counterparty.',
    `key_terms_summary` STRING COMMENT 'High-level summary of the principal economic and structural terms of the proposed deal.',
    `lead_investment_professional` STRING COMMENT 'Name of the internal investment professional leading the term sheet negotiation.',
    `loi_reference_number` STRING COMMENT 'Reference number of the associated Letter of Intent if one was issued prior to term sheet.',
    `management_fee_percent` DECIMAL(5,2) COMMENT 'Annual management fee percentage charged on committed or invested capital.',
    `modified_by_user` STRING COMMENT 'User identifier of the person who last modified the term sheet record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the term sheet record was last modified.',
    `nda_reference_number` STRING COMMENT 'Reference number of the executed NDA governing confidentiality of term sheet discussions.',
    `notes` STRING COMMENT 'Free-form notes and comments regarding the term sheet negotiation and key discussion points.',
    `number` STRING COMMENT 'Business identifier for the term sheet, typically assigned by deal origination system.',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Proposed ownership stake percentage in the target entity.',
    `proposed_investment_amount` DECIMAL(18,2) COMMENT 'Total capital amount proposed for investment in base currency.',
    `regulatory_approvals_required` STRING COMMENT 'List of regulatory approvals or filings required to complete the transaction.',
    `source_channel` STRING COMMENT 'Channel through which the deal opportunity was sourced.. Valid values are `off_market|intermediated|proprietary|co_invest_partner|fund_manager`',
    `target_irr_percent` DECIMAL(5,2) COMMENT 'Target internal rate of return expressed as a percentage for the investment.',
    `target_moic` DECIMAL(5,2) COMMENT 'Target multiple on invested capital for the investment opportunity.',
    `term_sheet_status` STRING COMMENT 'Current lifecycle status of the term sheet in the negotiation process.. Valid values are `draft|issued|under_negotiation|accepted|rejected|superseded`',
    `valuation_basis` STRING COMMENT 'Methodology or basis used for the indicative valuation in the term sheet.',
    `version_number` BIGINT COMMENT 'Sequential version number of the term sheet as negotiations progress.',
    CONSTRAINT pk_term_sheet PRIMARY KEY(`term_sheet_id`)
) COMMENT 'Master record for term sheets negotiated during deal structuring. Captures term sheet version, issuance date, counterparty, proposed deal structure (equity/debt/hybrid), indicative valuation basis, key economic terms (purchase price, EBITDA multiple, IRR';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`investment_memo` (
    `investment_memo_id` BIGINT COMMENT 'Unique identifier for the investment memorandum record. Primary key.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the deal opportunity in the pipeline that this investment memorandum supports.',
    `employee_id` BIGINT COMMENT 'Employee identifier of the primary investment professional responsible for preparing the memorandum.',
    `lead_author_employee_id` BIGINT COMMENT 'Employee identifier of the primary investment professional responsible for preparing the memorandum.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal opportunity in the pipeline that this investment memorandum supports.',
    `asset_class` STRING COMMENT 'Primary asset class category of the investment opportunity covered in this memorandum.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `commitment_currency` STRING COMMENT 'Three-letter ISO currency code for the proposed commitment amount.. Valid values are `^[A-Z]{3}$`',
    `competitive_landscape` STRING COMMENT 'Assessment of the competitive environment, market positioning, and key competitors relevant to the target investment.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this investment memorandum record was first created in the system.',
    `deal_structure` STRING COMMENT 'Proposed transaction structure including equity stake, debt instruments, preferred shares, or other investment vehicles.',
    `deal_type` STRING COMMENT 'Type of investment structure being proposed in the memorandum.. Valid values are `direct_investment|co_investment|fund_commitment|secondary|joint_venture`',
    `decision_date` DATE COMMENT 'Date when the Investment Committee made a formal decision on the investment proposal.',
    `document_location` STRING COMMENT 'File path or URI reference to the full investment memorandum document stored in the document management system.',
    `esg_rating` STRING COMMENT 'Internal ESG assessment rating assigned to the target investment based on responsible investment criteria.. Valid values are `A|B|C|D|not_rated`',
    `esg_summary` STRING COMMENT 'Summary of key ESG considerations, risks, and opportunities identified during due diligence.',
    `exit_strategy` STRING COMMENT 'Planned exit approach for the investment, including potential exit routes such as IPO, strategic sale, secondary sale, or recapitalization.',
    `expected_close_date` DATE COMMENT 'Anticipated date when the investment transaction is expected to close and capital will be deployed.',
    `ic_conditions` STRING COMMENT 'Specific conditions or requirements stipulated by the Investment Committee that must be satisfied before proceeding with the investment.',
    `ic_decision` STRING COMMENT 'Final decision rendered by the Investment Committee on the investment proposal.. Valid values are `approved|approved_with_conditions|rejected|deferred`',
    `ic_decision_notes` STRING COMMENT 'Additional commentary, rationale, or guidance provided by the Investment Committee regarding their decision.',
    `ic_meeting_date` DATE COMMENT 'Scheduled date of the Investment Committee meeting where this memorandum will be or was presented.',
    `ic_recommendation` STRING COMMENT 'Formal recommendation presented to the Investment Committee regarding the proposed investment.. Valid values are `approve|approve_with_conditions|reject|defer`',
    `investment_horizon_years` BIGINT COMMENT 'Expected holding period for the investment measured in years from initial commitment to anticipated exit.',
    `investment_thesis` STRING COMMENT 'Core strategic rationale and value creation hypothesis supporting the investment recommendation.',
    `is_active` BOOLEAN COMMENT 'Boolean flag indicating whether this investment memorandum record is currently active and valid.',
    `key_risks` STRING COMMENT 'Summary of principal risks identified in the investment analysis, including market, operational, regulatory, and execution risks.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'System timestamp when this investment memorandum record was last updated.',
    `management_assessment` STRING COMMENT 'Evaluation of the target company management team quality, experience, track record, and alignment with investment objectives.',
    `memo_number` STRING COMMENT 'Business identifier for the investment memorandum, typically formatted as IM-YYYY-NNNN.. Valid values are `^IM-[0-9]{4}-[0-9]{4}$`',
    `memo_status` STRING COMMENT 'Current lifecycle status of the investment memorandum in the approval workflow.. Valid values are `draft|under_review|ic_submitted|ic_approved|ic_rejected|withdrawn`',
    `mitigation_strategies` STRING COMMENT 'Proposed strategies and actions to mitigate identified investment risks.',
    `preparation_date` DATE COMMENT 'Date when the investment memorandum was initially prepared by the investment team.',
    `proposed_commitment_amount` DECIMAL(18,2) COMMENT 'Total capital commitment amount being recommended for Investment Committee approval, in base currency.',
    `sub_asset_class` STRING COMMENT 'Detailed sub-category within the primary asset class, providing granular investment classification.',
    `submission_date` DATE COMMENT 'Date when the investment memorandum was formally submitted to the Investment Committee for review and decision.',
    `target_country` STRING COMMENT 'Three-letter ISO country code representing the primary geographic location of the target asset or company headquarters.. Valid values are `^[A-Z]{3}$`',
    `target_description` STRING COMMENT 'Detailed business description of the target company or asset, including operations, market position, and strategic rationale.',
    `target_irr_percent` DECIMAL(5,2) COMMENT 'Projected internal rate of return expressed as a percentage, representing the expected annualized return on the investment.',
    `target_moic` DECIMAL(5,2) COMMENT 'Projected multiple on invested capital, representing the total value expected to be returned relative to the initial investment.',
    `target_name` STRING COMMENT 'Name of the target company, asset, or fund that is the subject of the investment proposal.',
    `target_region` STRING COMMENT 'Broader geographic region classification of the target investment.',
    `target_sector` STRING COMMENT 'Primary industry sector or vertical of the target company or asset.',
    `valuation_amount` DECIMAL(18,2) COMMENT 'Enterprise or asset valuation of the target at the proposed transaction price, in base currency.',
    `valuation_currency` STRING COMMENT 'Three-letter ISO currency code for the target valuation amount.. Valid values are `^[A-Z]{3}$`',
    `valuation_methodology` STRING COMMENT 'Primary valuation approach used to determine target pricing, such as Discounted Cash Flow (DCF), comparable transactions, or Net Asset Value (NAV).',
    `version_number` BIGINT COMMENT 'Version number of the investment memorandum, incremented for each revision submitted to the Investment Committee (IC).',
    CONSTRAINT pk_investment_memo PRIMARY KEY(`investment_memo_id`)
) COMMENT 'Master record for Investment Memoranda (IM) prepared for IC submission. Captures IM version, preparation date, lead author, asset class, deal type, target company/asset name, recommended deal structure, proposed commitment amount, target IRR, target MOIC';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`deal_ic_submission` (
    `deal_ic_submission_id` BIGINT COMMENT 'Unique identifier for the Investment Committee submission record. Primary key for the deal IC submission entity.',
    `actor_id` BIGINT COMMENT 'Reference to the external advisor, investment bank, or intermediary that originated or facilitated the deal opportunity, if applicable.',
    `deal_employee_id` BIGINT COMMENT 'Reference to the investment professional or deal team lead responsible for originating and presenting this opportunity to the IC.',
    `deal_external_advisor_employee_id` BIGINT COMMENT 'Reference to the external advisor, investment bank, or intermediary that originated or facilitated the deal opportunity, if applicable.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the underlying deal opportunity or pipeline record being submitted for IC approval.',
    `employee_id` BIGINT COMMENT 'Reference to the user or investment professional who created the IC submission record.',
    `fee_benchmark_id` BIGINT COMMENT 'Foreign key linking to fee.fee_benchmark. Business justification: Investment Committee approval process requires fee reasonableness assessment. IC members review proposed deal fees against market benchmarks to ensure fiduciary duty compliance and',
    `gp_manager_gp_profile_id` BIGINT COMMENT 'Reference to the General Partner or external fund manager for fund commitments or co-investments.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the General Partner or external fund manager for fund commitments or co-investments.',
    `ic_governance_record_id` BIGINT COMMENT 'Foreign key linking to compliance.ic_governance_record. Business justification: IC submissions must link to formal governance meeting records for audit trail and regulatory compliance.',
    `last_modified_by_user_employee_id` BIGINT COMMENT 'Reference to the user who last modified the IC submission record.',
    `ldi_strategy_id` BIGINT COMMENT 'Foreign key linking to actuarial.ldi_strategy. Business justification: IC submissions reference applicable LDI strategy to demonstrate investment fits liability-driven framework.',
    `lead_investment_professional_employee_id` BIGINT COMMENT 'Reference to the investment professional or deal team lead responsible for originating and presenting this opportunity to the IC.',
    `liability_projection_id` BIGINT COMMENT 'Foreign key linking to actuarial.liability_projection. Business justification: IC submissions must demonstrate liability alignment. Pension fund governance requires IC to review how proposed investments support liability matching.',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: IC submissions must specify target portfolio for pre-trade compliance validation against portfolio mandates, concentration limits, and SAA targets.',
    `approval_conditions` STRING COMMENT 'Text description of any conditions, covenants, or requirements attached to a conditional IC approval that must be satisfied before investment execution.',
    `approved_commitment_amount` DECIMAL(18,2) COMMENT 'Actual investment commitment amount approved by the IC, which may differ from the requested amount in cases of conditional or partial approval.',
    `asset_class` STRING COMMENT 'Primary asset class category of the investment opportunity being submitted for IC approval. [ENUM-REF-CANDIDATE: public_equity|private_equity|real_estate|infrastructure|natural_resources|credit|fixed_income|multi_asset — 8 candidates stripped; promote to',
    `confidentiality_level` STRING COMMENT 'Data classification level for the IC submission and associated materials, governing access and distribution controls.. Valid values are `public|internal|confidential|restricted`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the IC submission record was first created in the system.',
    `dd_completion_status` STRING COMMENT 'Status of due diligence workstreams at the time of IC submission, indicating readiness for investment decision.. Valid values are `not_started|in_progress|substantially_complete|complete`',
    `decision_date` DATE COMMENT 'Date on which the Investment Committee rendered its final decision on this submission.',
    `deferral_reason` STRING COMMENT 'Text description of the reasons for deferring the IC decision to a future meeting, including any additional information or analysis requested.',
    `esg_rating` STRING COMMENT 'ESG assessment rating assigned to the investment opportunity based on responsible investment criteria.. Valid values are `A|B|C|D|not_rated`',
    `expected_irr_percent` DECIMAL(5,2) COMMENT 'Projected Internal Rate of Return for the investment as presented in the Investment Memorandum, expressed as a percentage.',
    `expected_moic` DECIMAL(5,2) COMMENT 'Projected Multiple on Invested Capital for the investment as presented in the Investment Memorandum.',
    `ic_decision` STRING COMMENT 'Final decision rendered by the Investment Committee on this submission.. Valid values are `approved|rejected|conditional_approval|deferred|withdrawn`',
    `ic_feedback` STRING COMMENT 'Free-text feedback, questions, or guidance provided by IC members during or after the review of this submission.',
    `ic_type` STRING COMMENT 'Type or level of IC review being requested: preliminary review, full committee approval, special session, emergency approval, or written consent.. Valid values are `preliminary|full|special|emergency|written_consent`',
    `investment_horizon_years` BIGINT COMMENT 'Expected holding period or investment horizon for the opportunity, expressed in years.',
    `investment_memo_version` STRING COMMENT 'Version identifier of the Investment Memorandum document submitted to the IC for this opportunity.',
    `investment_strategy` STRING COMMENT 'Specific investment strategy or sub-strategy within the asset class, such as growth equity, value-add real estate, or core infrastructure.',
    `investment_structure` STRING COMMENT 'Structure of the proposed investment: direct investment, co-investment alongside a GP, fund commitment, secondary purchase, or separately managed account.. Valid values are `direct|co_investment|fund_commitment|secondary|separate_account`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the IC submission record was last updated or modified.',
    `presentation_document_uri` STRING COMMENT 'URI or file path reference to the IC presentation deck or Investment Memorandum document submitted for this opportunity.',
    `rejection_rationale` STRING COMMENT 'Text description of the reasons and rationale provided by the IC for rejecting the investment submission.',
    `requested_commitment_amount` DECIMAL(18,2) COMMENT 'Total investment commitment amount being requested for IC approval, expressed in the base currency.',
    `requested_commitment_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the requested commitment amount.. Valid values are `^[A-Z]{3}$`',
    `risk_rating` STRING COMMENT 'Overall risk assessment rating for the investment opportunity as evaluated by the investment and risk teams.. Valid values are `low|medium|high|very_high`',
    `scheduled_ic_meeting_date` DATE COMMENT 'Date on which the IC meeting is scheduled to review and vote on this submission.',
    `sponsoring_department` STRING COMMENT 'Internal department or investment team sponsoring the IC submission, such as Private Equity, Real Estate, or Infrastructure.',
    `strategic_alignment_score` BIGINT COMMENT 'Quantitative score indicating how well the investment aligns with the funds Strategic Asset Allocation and investment objectives, typically on a scale of 1-10.',
    `submission_date` DATE COMMENT 'Date on which the IC submission package was formally submitted to the Investment Committee for review.',
    `submission_notes` STRING COMMENT 'Free-text notes or commentary from the deal team providing additional context, updates, or clarifications for the IC submission.',
    `submission_reference_number` STRING COMMENT 'Business-facing unique reference number or code assigned to this IC submission for tracking and communication purposes.',
    `submission_status` STRING COMMENT 'Current lifecycle status of the IC submission indicating its position in the approval workflow. [ENUM-REF-CANDIDATE: draft|submitted|under_review|approved|rejected|conditional_approval|withdrawn|deferred — 8 candidates stripped; promote to reference',
    `supporting_materials_uri` STRING COMMENT 'URI or file path reference to supporting materials, appendices, or due diligence reports accompanying the IC submission.',
    `target_entity_name` STRING COMMENT 'Name of the target company, asset, fund, or entity that is the subject of the investment opportunity.',
    `target_geography` STRING COMMENT 'Primary geographic region or country where the target investment is domiciled or operates.',
    `target_sector` STRING COMMENT 'Industry sector or sub-sector of the target investment, such as technology, healthcare, energy, or consumer goods.',
    `votes_abstained` BIGINT COMMENT 'Number of IC members who abstained from voting on the investment submission due to conflicts of interest or other reasons.',
    `votes_against` BIGINT COMMENT 'Number of IC members who voted against approving the investment submission.',
    `votes_in_favor` BIGINT COMMENT 'Number of IC members who voted in favor of approving the investment submission.',
    `voting_quorum_met` BOOLEAN COMMENT 'Boolean flag indicating whether the required quorum of IC members was present for a valid vote on this submission.',
    CONSTRAINT pk_deal_ic_submission PRIMARY KEY(`deal_ic_submission_id`)
) COMMENT 'Transactional record capturing each formal Investment Committee (IC) submission for deal approval. Records the opportunity, investment memo version, submission date, IC meeting date, IC type (preliminary/full/special), requested commitment amount';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`deal_ic_condition` (
    `deal_ic_condition_id` BIGINT COMMENT 'Unique identifier for the Investment Committee condition record. Primary key for the deal IC condition entity.',
    `deal_ic_submission_id` BIGINT COMMENT 'Reference to the parent IC submission that this condition is attached to. Links condition to the specific investment approval request.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the underlying deal or investment opportunity that this condition relates to. Enables direct linkage to deal pipeline.',
    `opportunity_id` BIGINT COMMENT 'Reference to the underlying deal or investment opportunity that this condition relates to. Enables direct linkage to deal pipeline.',
    `breach_date` DATE COMMENT 'Date on which the condition was determined to be breached, either through non-satisfaction by the due date or violation of an ongoing covenant.',
    `breach_description` STRING COMMENT 'Detailed description of the nature and circumstances of the condition breach, including materiality assessment and remediation actions.',
    `condition_category` STRING COMMENT 'Functional category of the condition indicating which workstream or domain it pertains to for assignment and tracking purposes. [ENUM-REF-CANDIDATE: legal|financial|operational|esg|regulatory|commercial|technical — 7 candidates stripped; promote to',
    `condition_description` STRING COMMENT 'Detailed narrative description of the condition requirement as documented in the IC approval resolution or investment memorandum.',
    `condition_notes` STRING COMMENT 'Additional notes, comments, or context regarding the condition, its interpretation, satisfaction progress, or any special circumstances.',
    `condition_number` STRING COMMENT 'Business-facing reference number or code assigned to this condition for tracking and communication purposes.',
    `condition_owner` STRING COMMENT 'Name or identifier of the individual or team responsible for ensuring the condition is satisfied and providing evidence of completion.',
    `condition_rationale` STRING COMMENT 'Business justification or risk mitigation rationale explaining why the IC imposed this condition on the investment approval.',
    `condition_status` STRING COMMENT 'Current lifecycle status of the condition indicating whether it remains outstanding, has been fulfilled, or has been waived by authorized parties.. Valid values are `open|in_progress|satisfied|waived|breached|expired`',
    `condition_type` STRING COMMENT 'Classification of the condition based on timing and enforceability. Pre-close must be satisfied before transaction closes, post-close after closing, ongoing covenant throughout holding period.. Valid values are `pre_close|post_close|ongoing_covenant|precedent|subsequent|waiver_eligible`',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp indicating when this condition record was first created in the deal management system, typically following IC approval.',
    `due_date` DATE COMMENT 'Target date by which the condition must be satisfied or reported on, as specified in the IC resolution or subsequent tracking updates.',
    `escalation_date` DATE COMMENT 'Date on which the condition issue was escalated to senior management or Investment Committee for review and decision.',
    `escalation_required` BOOLEAN COMMENT 'Indicator of whether the condition status or breach requires escalation to senior management or the Investment Committee for resolution.',
    `evidence_document_reference` STRING COMMENT 'Reference identifier or location of the documentation evidencing satisfaction of the condition, stored in data room or document management system.',
    `ic_meeting_date` DATE COMMENT 'Date of the Investment Committee meeting at which this condition was imposed as part of the investment approval resolution.',
    `ic_resolution_reference` STRING COMMENT 'Reference number or identifier of the formal IC resolution document that contains the condition language and approval terms.',
    `is_active` BOOLEAN COMMENT 'Flag indicating whether this condition record is currently active and relevant, or has been archived or superseded by subsequent IC actions.',
    `last_modified_by` STRING COMMENT 'Identifier of the user or system process that last modified this condition record, supporting audit trail and accountability requirements.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'System timestamp of the most recent update to this condition record, tracking changes to status, evidence, or other attributes over time.',
    `monitoring_frequency` STRING COMMENT 'Frequency at which ongoing covenant conditions must be monitored and reported on to ensure continued compliance throughout the investment holding period.. Valid values are `one_time|monthly|quarterly|semi_annual|annual|event_driven`',
    `next_review_date` DATE COMMENT 'Scheduled date for the next review or monitoring check of this condition, particularly relevant for ongoing covenants and post-close conditions.',
    `priority_level` STRING COMMENT 'Priority ranking assigned to the condition reflecting its materiality and urgency for investment execution or ongoing compliance.. Valid values are `critical|high|medium|low`',
    `remediation_plan` STRING COMMENT 'Description of the action plan to address a breached or at-risk condition, including timeline and responsible parties for remediation activities.',
    `responsible_party` STRING COMMENT 'Classification of the party responsible for fulfilling the condition, distinguishing between internal teams, external managers, counterparties, or advisors.. Valid values are `internal|external_manager|counterparty|advisor|legal_counsel`',
    `satisfaction_date` DATE COMMENT 'Actual date on which the condition was confirmed as satisfied and evidence was accepted by the responsible oversight function.',
    `verification_date` DATE COMMENT 'Date on which the verification of condition satisfaction was completed and documented by the responsible oversight function.',
    `verification_method` STRING COMMENT 'Method or process used to verify and confirm satisfaction of the condition, ensuring appropriate level of assurance based on condition materiality.. Valid values are `document_review|third_party_confirmation|site_visit|legal_opinion|financial_audit|management_certification`',
    `verified_by` STRING COMMENT 'Name or identifier of the individual or team that performed the verification and confirmed satisfaction of the condition.',
    `waiver_authority` STRING COMMENT 'Name or role of the individual or committee that authorized the waiver of this condition, ensuring proper governance and accountability.',
    `waiver_date` DATE COMMENT 'Date on which the condition was formally waived by authorized parties, typically documented in IC minutes or delegated authority records.',
    `waiver_rationale` STRING COMMENT 'Business justification and risk assessment supporting the decision to waive the condition rather than require full satisfaction.',
    `created_by` STRING COMMENT 'Identifier of the user or system process that created this condition record, supporting audit trail and data lineage requirements.',
    CONSTRAINT pk_deal_ic_condition PRIMARY KEY(`deal_ic_condition_id`)
) COMMENT 'Master record for conditions attached to IC approvals. Captures the IC submission, condition description, condition type (pre-close, post-close, ongoing covenant), condition owner, due date, condition status (open, satisfied, waived, breached)';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`team` (
    `team_id` BIGINT COMMENT 'Unique identifier for the deal_team data product (auto-inserted during validation).',
    `employee_id` BIGINT COMMENT 'User identifier of the person who created this deal team assignment record.',
    `last_modified_by_user_employee_id` BIGINT COMMENT 'User identifier of the person who last modified this deal team assignment record.',
    `opportunity_id` BIGINT COMMENT 'Reference to the investment opportunity or deal pipeline record this team is assigned to.',
    `team_approved_by_employee_id` BIGINT COMMENT 'Reference to the employee who approved this team assignment.',
    `team_employee_id` BIGINT COMMENT 'Reference to the employee or team member assigned to this deal.',
    `actual_hours` DECIMAL(10,2) COMMENT 'Actual total hours the team member has spent on this deal to date.',
    `advisor_engagement_type` STRING COMMENT 'Type of advisory engagement for external advisors: financial (financial due diligence), legal (legal counsel), technical (technical assessment), esg (ESG assessment), operational (operational due diligence), tax (tax advisory).. Valid values are `financial|legal|technical|esg|operational|tax`',
    `advisor_firm_name` STRING COMMENT 'Name of the external advisory firm if the team member is an external advisor or consultant. Null for internal employees.',
    `allocation_percentage` DECIMAL(5,2) COMMENT 'Percentage of the team members time allocated to this deal, expressed as a decimal (e.g., 25.00 for 25% allocation).',
    `approval_date` DATE COMMENT 'Date when the team assignment was approved.',
    `approval_status` STRING COMMENT 'Approval status of the team members assignment: pending (awaiting approval), approved (assignment confirmed), rejected (assignment not approved).. Valid values are `pending|approved|rejected`',
    `assignment_end_date` DATE COMMENT 'Date when the team members assignment to the deal ended or is expected to end. Null for ongoing assignments.',
    `assignment_notes` STRING COMMENT 'Free-text notes regarding the team members assignment, responsibilities, or special considerations for this deal.',
    `assignment_start_date` DATE COMMENT 'Date when the team member was assigned to the deal.',
    `assignment_status` STRING COMMENT 'Current status of the team members assignment: active (currently working), completed (assignment finished), suspended (temporarily paused), withdrawn (removed from deal).. Valid values are `active|completed|suspended|withdrawn`',
    `conflict_check_date` DATE COMMENT 'Date when the conflict of interest check was completed.',
    `conflict_check_status` STRING COMMENT 'Status of conflict of interest check for this team member on this deal: not_required (no check needed), pending (check in progress), cleared (no conflicts found), flagged (potential conflict identified).. Valid values are `not_required|pending|cleared|flagged`',
    `cost_center_code` STRING COMMENT 'Cost center code to which the team members time and expenses on this deal are charged.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this deal team assignment record was first created in the system.',
    `data_room_access_date` DATE COMMENT 'Date when the team member was granted access to the deal data room.',
    `data_room_access_granted` BOOLEAN COMMENT 'Indicates whether the team member has been granted access to the deal data room. True if access granted, False otherwise.',
    `estimated_hours` DECIMAL(10,2) COMMENT 'Estimated total hours the team member is expected to spend on this deal.',
    `is_ic_presenter` BOOLEAN COMMENT 'Indicates whether this team member will present the Investment Memorandum (IM) to the Investment Committee (IC). True if presenter, False otherwise.',
    `is_primary_contact` BOOLEAN COMMENT 'Indicates whether this team member is the primary point of contact for the deal. True if primary contact, False otherwise.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this deal team assignment record was last modified.',
    `nda_signed_date` DATE COMMENT 'Date when the team member signed the Non-Disclosure Agreement (NDA) for this deal.',
    `nda_signed_flag` BOOLEAN COMMENT 'Indicates whether the team member has signed a Non-Disclosure Agreement (NDA) for this deal. True if signed, False otherwise.',
    `role_code` STRING COMMENT 'Role of the team member on this deal: LEAD (deal lead or principal), ASSOCIATE (senior associate), ANALYST (junior analyst), LEGAL (legal counsel), ESG (ESG advisor), EXTERNAL (external advisor or consultant).. Valid values are `LEAD|ASSOCIATE|ANALYST|LEGAL|ESG|EXTERNAL`',
    `role_description` STRING COMMENT 'Detailed description of the team members responsibilities and scope of work on this deal.',
    CONSTRAINT pk_team PRIMARY KEY(`team_id`)
) COMMENT 'Association record capturing the deal team composition for each opportunity. Records the opportunity, team member employee reference, role on deal (lead, associate, analyst, legal counsel, ESG advisor, external advisor), assignment start date, assignment';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`origination_source` (
    `origination_source_id` BIGINT COMMENT 'Unique identifier for the origination source party or intermediary.',
    `kyc_record_id` BIGINT COMMENT 'Foreign key linking to compliance.kyc_record. Business justification: Origination sources (intermediaries, placement agents, GPs) must undergo KYC verification. The kyc_status/kyc_completion_date attributes indicate KYC is tracked.',
    `asset_class_focus` STRING COMMENT 'Primary asset classes or sectors in which the origination source specializes, such as private equity, real estate, infrastructure, or credit. [ENUM-REF-CANDIDATE',
    `exclusivity_scope` STRING COMMENT 'Description of the scope of any exclusive arrangement, including asset classes, geographies, or deal size ranges covered.',
    `fee_arrangement_type` STRING COMMENT 'Type of fee or compensation arrangement with the origination source for deal introductions.. Valid values are `no_fee|success_fee|retainer|advisory_fee`',
    `first_deal_date` DATE COMMENT 'Date on which the first deal opportunity was received from this origination source.',
    `geographic_focus` STRING COMMENT 'Primary geographic regions or markets in which the origination source operates and sources deals.',
    `is_exclusive` BOOLEAN COMMENT 'Indicates whether the origination source has an exclusive deal flow arrangement with the organization for specific sectors or geographies.',
    `kyc_completion_date` DATE COMMENT 'Date on which the most recent KYC and AML review was completed for the origination source.',
    `kyc_expiry_date` DATE COMMENT 'Date on which the current KYC approval expires and requires renewal for the origination source.',
    `kyc_status` STRING COMMENT 'Current status of the KYC and AML compliance review for the origination source.. Valid values are `not_started|in_progress|completed|expired|failed`',
    `last_deal_date` DATE COMMENT 'Date on which the most recent deal opportunity was received from this origination source.',
    `lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the origination source organization, enabling global counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `nda_execution_date` DATE COMMENT 'Date on which the NDA with the origination source was signed and became effective.',
    `nda_expiry_date` DATE COMMENT 'Date on which the NDA with the origination source expires and requires renewal.',
    `nda_status` STRING COMMENT 'Current status of the NDA with the origination source, governing confidentiality of deal information.. Valid values are `not_required|pending|executed|expired`',
    `notes` STRING COMMENT 'Free-text notes capturing additional context, relationship history, or special considerations for the origination source.',
    `organization_address_line1` STRING COMMENT 'First line of the origination source organizations registered or primary business address.',
    `organization_address_line2` STRING COMMENT 'Second line of the origination source organizations address, including suite or floor details.',
    `organization_city` STRING COMMENT 'City or municipality of the origination source organizations primary address.',
    `organization_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for the origination source organizations primary address.. Valid values are `^[A-Z]{3}$`',
    `organization_postal_code` STRING COMMENT 'Postal or ZIP code of the origination source organizations primary address.',
    `organization_state_province` STRING COMMENT 'State, province, or region of the origination source organizations primary address.',
    `party_type` STRING COMMENT 'Indicates whether the source is an individual contact, an organization, or an intermediary entity.. Valid values are `individual|organization|intermediary|advisor|referral_partner`',
    `preferred_communication_method` STRING COMMENT 'Preferred channel for communicating with the origination source contact regarding deal opportunities.. Valid values are `email|phone|video_conference|in_person`',
    `primary_contact_email` STRING COMMENT 'Primary email address for the origination source contact, used for deal pipeline communication and NDA distribution.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_contact_name` STRING COMMENT 'Full name of the primary individual contact at the origination source for deal flow communication.',
    `primary_contact_phone` STRING COMMENT 'Primary telephone number for the origination source contact, including country and area codes.',
    `record_created_by` STRING COMMENT 'User or system identifier that created this origination source record in the lakehouse.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this origination source record was first created in the lakehouse silver layer.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this origination source record was last updated in the lakehouse silver layer.',
    `relationship_manager_name` STRING COMMENT 'Name of the internal relationship manager or deal origination team member responsible for managing this origination source.',
    `relationship_status` STRING COMMENT 'Current status of the relationship with the origination source, indicating whether they are actively providing deal flow.. Valid values are `active|inactive|suspended|under_review|blacklisted`',
    `relationship_tier` STRING COMMENT 'Strategic importance tier of the origination source based on deal quality, volume, and historical performance.. Valid values are `tier_1|tier_2|tier_3|opportunistic`',
    `secondary_contact_email` STRING COMMENT 'Secondary email address for backup communication with the origination source.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `secondary_contact_name` STRING COMMENT 'Full name of the secondary or backup contact at the origination source for continuity of deal flow.',
    `secondary_contact_phone` STRING COMMENT 'Secondary telephone number for backup contact at the origination source.',
    `source_name` STRING COMMENT 'Full legal or trading name of the origination source party, intermediary, or contact organization.',
    `source_system_code` STRING COMMENT 'Unique identifier of this origination source record in the source operational system for traceability and reconciliation.',
    `source_type` STRING COMMENT 'Classification of the origination source indicating how the deal opportunity was introduced to the organization.. Valid values are `proprietary|gp_introduced|investment_bank|broker|co_investor_referral|management_team`',
    `success_rate_percent` DECIMAL(5,2) COMMENT 'Percentage of deals sourced by this origination source that resulted in closed investments, calculated as total deals closed divided by total deals sourced.',
    `total_deals_closed` BIGINT COMMENT 'Cumulative count of deal opportunities from this origination source that resulted in executed investments.',
    `total_deals_sourced` BIGINT COMMENT 'Cumulative count of deal opportunities introduced by this origination source since relationship inception.',
    CONSTRAINT pk_origination_source PRIMARY KEY(`origination_source_id`)
) COMMENT 'Reference master for external deal parties—origination sources, intermediaries, and their individual contacts—across the pipeline. Captures source/party type (proprietary/off-market, GP-introduced, investment bank, broker, co-investor referral, management';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`target_entity` (
    `target_entity_id` BIGINT COMMENT 'Unique identifier for the target entity record in the deal pipeline system.',
    `coverage_universe_id` BIGINT COMMENT 'Foreign key linking to research.coverage_universe. Business justification: Target entities under deal evaluation should link to research coverage when actively covered.',
    `kyc_record_id` BIGINT COMMENT 'Foreign key linking to compliance.kyc_record. Business justification: Target entities MUST have KYC verification before investment per AML regulations. Pension funds must verify counterparty identity and beneficial ownership.',
    `lei_record_id` BIGINT COMMENT 'Foreign key linking to compliance.lei_record. Business justification: Target entities need LEI linkage for regulatory transaction reporting (EMIR, MiFID II). The lei attribute on target_entity is denormalized.',
    `sanctions_screening_id` BIGINT COMMENT 'Foreign key linking to compliance.sanctions_screening. Business justification: All investment targets must be screened against sanctions lists (OFAC, EU, UN) before capital deployment.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_asset_valuation. Business justification: The pension fund requires the valuation of the target entity for investment decision-making; the target entitys valuation is stored in valuation_asset_valuation.',
    `annual_revenue_amount` DECIMAL(18,2) COMMENT 'Total annual revenue generated by the target entity in its most recent fiscal year, expressed in the reporting currency.',
    `annual_revenue_currency` STRING COMMENT 'Three-letter ISO currency code for the currency in which the annual revenue amount is denominated.. Valid values are `^[A-Z]{3}$`',
    `asset_class` STRING COMMENT 'Investment asset class category to which the target entity belongs for portfolio allocation and strategic asset allocation purposes. [ENUM-REF-CANDIDATE: public_equity|private_equity|real_estate|infrastructure|natural_resources|credit|fixed_income — 7',
    `credit_rating` STRING COMMENT 'External credit rating assigned to the target entity by a recognized rating agency indicating creditworthiness and default risk.',
    `credit_rating_agency` STRING COMMENT 'Name of the credit rating agency that assigned the credit rating to the target entity.',
    `cusip` STRING COMMENT 'Nine-character alphanumeric CUSIP identifier for the target entitys securities, primarily used in North American markets.. Valid values are `^[A-Z0-9]{9}$`',
    `ebitda_amount` DECIMAL(18,2) COMMENT 'EBITDA for the target entity in its most recent fiscal year, representing operating profitability before financing and non-cash charges.',
    `ebitda_currency` STRING COMMENT 'Three-letter ISO currency code for the currency in which the EBITDA amount is denominated.. Valid values are `^[A-Z]{3}$`',
    `employee_count` BIGINT COMMENT 'Total number of full-time equivalent employees working for the target entity as of the most recent reporting period.',
    `enterprise_value_amount` DECIMAL(18,2) COMMENT 'Estimated or reported enterprise value of the target entity representing the total value of the business including debt and excluding cash.',
    `enterprise_value_currency` STRING COMMENT 'Three-letter ISO currency code for the currency in which the enterprise value amount is denominated.. Valid values are `^[A-Z]{3}$`',
    `esg_assessment_date` DATE COMMENT 'Date on which the ESG score or rating was assigned or last updated by the rating provider.',
    `esg_rating_provider` STRING COMMENT 'Name of the third-party provider or rating agency that assigned the ESG score to the target entity.',
    `esg_score` DECIMAL(5,2) COMMENT 'Composite ESG score for the target entity reflecting its performance on environmental, social, and governance factors.',
    `headquarters_address` STRING COMMENT 'Full street address of the target entitys primary headquarters or principal place of business.',
    `headquarters_city` STRING COMMENT 'City where the target entitys headquarters is located.',
    `headquarters_country` STRING COMMENT 'Three-letter ISO country code for the country where the target entitys headquarters is located.. Valid values are `^[A-Z]{3}$`',
    `incorporation_date` DATE COMMENT 'Date on which the target entity was legally incorporated or established in its jurisdiction.',
    `industry_sector` STRING COMMENT 'Primary industry sector classification for the target entity based on its core business activities.',
    `industry_subsector` STRING COMMENT 'More granular industry subsector classification providing additional detail on the target entitys business focus.',
    `is_publicly_listed` BOOLEAN COMMENT 'Boolean flag indicating whether the target entity is publicly listed on a stock exchange.',
    `isin` STRING COMMENT 'ISO 6166 compliant 12-character alphanumeric International Securities Identification Number uniquely identifying the target entitys securities.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `jurisdiction_of_incorporation` STRING COMMENT 'Three-letter ISO country code representing the legal jurisdiction where the target entity is incorporated or domiciled.. Valid values are `^[A-Z]{3}$`',
    `origination_date` DATE COMMENT 'Date on which the target entity was first identified and entered into the deal origination pipeline.',
    `ownership_structure` STRING COMMENT 'Classification of the target entitys ownership structure indicating whether it is publicly traded, privately held, family-owned, government-owned, partnership, or joint venture.. Valid values are `publicly_traded|privately_held|family_owned|government_owned|partnership|joint_venture`',
    `parent_company_lei` STRING COMMENT 'Legal Entity Identifier of the parent company or ultimate beneficial owner of the target entity.. Valid values are `^[A-Z0-9]{20}$`',
    `parent_company_name` STRING COMMENT 'Legal name of the parent company or ultimate beneficial owner if the target entity is a subsidiary or controlled entity.',
    `primary_business_description` STRING COMMENT 'Detailed narrative description of the target entitys core business operations, products, services, and value proposition.',
    `primary_contact_email` STRING COMMENT 'Email address of the primary contact person at the target entity for deal correspondence.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_contact_name` STRING COMMENT 'Full name of the primary contact person at the target entity for deal-related communications.',
    `primary_contact_phone` STRING COMMENT 'Telephone number of the primary contact person at the target entity.',
    `primary_contact_title` STRING COMMENT 'Job title or role of the primary contact person at the target entity.',
    `record_created_timestamp` TIMESTAMP COMMENT 'System timestamp indicating when this target entity record was first created in the deal pipeline system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'System timestamp indicating when this target entity record was last modified or updated.',
    `registration_number` STRING COMMENT 'Official company registration or identification number assigned by the jurisdiction of incorporation for the target entity.',
    `sedol` STRING COMMENT 'Seven-character alphanumeric SEDOL identifier for the target entitys securities, primarily used in UK and Irish markets.. Valid values are `^[A-Z0-9]{7}$`',
    `source_channel` STRING COMMENT 'Channel through which the target entity was sourced or originated for the deal pipeline.. Valid values are `off_market|intermediated|proprietary|referral|co_investment`',
    `stock_exchange_code` STRING COMMENT 'Market Identifier Code for the primary stock exchange where the target entitys securities are listed, if publicly traded.',
    `sub_asset_class` STRING COMMENT 'More specific sub-category within the primary asset class providing granular classification for investment strategy alignment.',
    `target_legal_name` STRING COMMENT 'Full legal name of the target company, asset, fund, or investment vehicle as registered in its jurisdiction of incorporation.',
    `target_short_name` STRING COMMENT 'Abbreviated or commonly used name for the target entity used in internal communications and reporting.',
    `target_status` STRING COMMENT 'Current lifecycle status of the target entity within the deal pipeline indicating whether it is actively being pursued, inactive, under review, archived, or has been merged or acquired.. Valid values are `active|inactive|under_review|archived|merged|acquired`',
    `target_type` STRING COMMENT 'Classification of the target entity indicating whether it is an operating company, real asset, infrastructure asset, natural resource asset, fund, or co-investment vehicle.. Valid values are `operating_company|real_estate_asset|infrastructure_asset|natural_resource_asset|fund|co_investment_vehicle`',
    `tax_identification_number` STRING COMMENT 'Tax identification number or equivalent identifier used by tax authorities in the target entitys primary jurisdiction.',
    `ticker_symbol` STRING COMMENT 'Stock ticker symbol or trading symbol for the target entity on its primary stock exchange, if publicly listed.',
    `valuation_date` DATE COMMENT 'Date as of which the enterprise value or other valuation metrics were determined or estimated.',
    `website_url` STRING COMMENT 'Primary website URL for the target entity providing public information about the company or asset.',
    CONSTRAINT pk_target_entity PRIMARY KEY(`target_entity_id`)
) COMMENT 'Master record for the target company, asset, or fund that is the subject of a deal opportunity. Captures target legal name, target type (operating company, real asset, infrastructure asset, fund, co-investment vehicle), jurisdiction of incorporation, LEI';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`deal_valuation` (
    `deal_valuation_id` BIGINT COMMENT 'Unique identifier for the deal valuation record.',
    `capital_market_assumption_id` BIGINT COMMENT 'Foreign key linking to research.capital_market_assumption. Business justification: Institutional valuations require documented capital market assumptions for WACC, risk premiums.',
    `deal_employee_id` BIGINT COMMENT 'Reference to the investment professional who prepared the valuation.',
    `discount_rate_curve_id` BIGINT COMMENT 'Foreign key linking to actuarial.discount_rate_curve. Business justification: Deal valuations for pension investments should use liability-consistent discount rates. Actuarial discount curves ensure valuation consistency with ALM framework.',
    `employee_id` BIGINT COMMENT 'Reference to the investment professional who prepared the valuation.',
    `macro_model_run_id` BIGINT COMMENT 'Foreign key linking to research.macro_model_run. Business justification: Deal valuations use macro assumptions (discount rates, growth rates). Linking to specific model run provides audit trail for valuation inputs.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal opportunity being valued.',
    `reviewer_employee_id` BIGINT COMMENT 'Reference to the senior professional who reviewed and approved the valuation.',
    `reviewer_id` BIGINT COMMENT 'Reference to the senior professional who reviewed and approved the valuation.',
    `superseded_by_valuation_deal_valuation_id` BIGINT COMMENT 'Reference to the subsequent valuation that supersedes this record, if applicable.',
    `analyst_name` STRING COMMENT 'Name of the investment professional who prepared the valuation.',
    `approval_date` DATE COMMENT 'Date when the valuation was formally approved by the reviewer.',
    `comparable_count` BIGINT COMMENT 'Number of comparable companies or precedent transactions used in the analysis.',
    `confidence_level` STRING COMMENT 'Qualitative assessment of confidence in the valuation estimate given data availability and assumptions.. Valid values are `high|medium|low`',
    `currency` STRING COMMENT 'Three-letter ISO 4217 currency code for valuation amounts.. Valid values are `^[A-Z]{3}$`',
    `data_quality_score` BIGINT COMMENT 'Numeric score representing the quality and completeness of data used in valuation, scale 1-10.',
    `discount_rate_percent` DECIMAL(5,2) COMMENT 'Discount rate applied in discounted cash flow analysis, expressed as percentage.',
    `ebitda_multiple` DECIMAL(6,2) COMMENT 'EBITDA multiple applied in comparable company or precedent transaction analysis.',
    `enterprise_value` DECIMAL(20,2) COMMENT 'Estimated enterprise value of the target entity.',
    `equity_value` DECIMAL(20,2) COMMENT 'Estimated equity value derived from enterprise value less net debt.',
    `key_assumptions` STRING COMMENT 'Summary of critical assumptions underpinning the valuation estimate.',
    `methodology` STRING COMMENT 'Primary valuation methodology applied for this estimate.. Valid values are `dcf|comparable_company|precedent_transaction|nav|liquidation|option_pricing`',
    `midpoint` DECIMAL(20,2) COMMENT 'Midpoint of the valuation range, representing the central estimate.',
    `model_file_path` STRING COMMENT 'File path or document management system reference to the detailed valuation model.',
    `nav_per_share` DECIMAL(18,4) COMMENT 'Calculated net asset value per share for equity investments.',
    `net_debt` DECIMAL(20,2) COMMENT 'Net debt position of the target entity used to bridge enterprise value to equity value.',
    `notes` STRING COMMENT 'Additional commentary, caveats, or context relevant to the valuation estimate.',
    `range_high` DECIMAL(20,2) COMMENT 'Upper bound of the valuation range estimate.',
    `range_low` DECIMAL(20,2) COMMENT 'Lower bound of the valuation range estimate.',
    `record_created_by` STRING COMMENT 'User or system identifier that created this record in the data platform.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this record was first created in the data platform.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this record was last updated in the data platform.',
    `revenue_multiple` DECIMAL(6,2) COMMENT 'Revenue multiple applied in comparable company or precedent transaction analysis.',
    `reviewer_name` STRING COMMENT 'Name of the senior professional who reviewed and approved the valuation.',
    `risk_factors` STRING COMMENT 'Key risks and uncertainties that could materially impact the valuation.',
    `sensitivity_analysis_performed` BOOLEAN COMMENT 'Indicates whether sensitivity analysis was conducted on key valuation drivers.',
    `source_system_code` STRING COMMENT 'Unique identifier of this valuation record in the source system.',
    `target_ebitda` DECIMAL(20,2) COMMENT 'Target company EBITDA used as basis for multiple-based valuation.',
    `target_revenue` DECIMAL(20,2) COMMENT 'Target company revenue used as basis for multiple-based valuation.',
    `terminal_growth_rate_percent` DECIMAL(5,2) COMMENT 'Perpetual growth rate assumption used in terminal value calculation.',
    `valuation_date` DATE COMMENT 'The as-of date for which the valuation estimate was prepared.',
    `valuation_number` STRING COMMENT 'Business identifier for this valuation record, used for tracking and reference.',
    `valuation_status` STRING COMMENT 'Current lifecycle status of the valuation record.. Valid values are `draft|in_review|approved|rejected|superseded`',
    `valuation_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the valuation was completed or submitted.',
    `valuation_type` STRING COMMENT 'Classification of the valuation approach used during deal origination.. Valid values are `indicative|preliminary|formal|fairness_opinion|desktop|full_model`',
    `version_number` BIGINT COMMENT 'Sequential version number for tracking iterations of the valuation for the same opportunity.',
    `wacc_percent` DECIMAL(5,2) COMMENT 'Weighted average cost of capital used in valuation model, expressed as percentage.',
    CONSTRAINT pk_deal_valuation PRIMARY KEY(`deal_valuation_id`)
) COMMENT 'Transactional record capturing indicative valuation estimates produced during deal origination and screening—prior to formal valuation domain ownership post-IC approval.';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`deal_capital_commitment` (
    `deal_capital_commitment_id` BIGINT COMMENT 'Unique identifier for the capital commitment record. Primary key for this entity.',
    `deal_employee_id` BIGINT COMMENT 'Identifier for the internal investment professional responsible for originating and managing this commitment.',
    `deal_ic_submission_id` BIGINT COMMENT 'Reference to the Investment Committee submission that resulted in this commitment approval.',
    `deal_portfolio_manager_employee_id` BIGINT COMMENT 'Identifier for the portfolio manager responsible for overseeing this commitment within the broader portfolio.',
    `employee_id` BIGINT COMMENT 'Identifier for the internal investment professional responsible for originating and managing this commitment.',
    `liability_projection_id` BIGINT COMMENT 'Foreign key linking to actuarial.liability_projection. Business justification: Capital commitment decisions must align with liability cash flow timing. Investment teams reference liability projections during commitment sizing to ensure assets match',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal opportunity for which this capital commitment was approved.',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: IC approval process requires specifying target portfolio for mandate compliance checks and allocation limit validation.',
    `portfolio_manager_employee_id` BIGINT COMMENT 'Identifier for the portfolio manager responsible for overseeing this commitment within the broader portfolio.',
    `asset_class` STRING COMMENT 'Primary asset class for this commitment: public equity, private equity, real estate, infrastructure, natural resources, or credit.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `base_currency_code` STRING COMMENT 'Three-letter ISO 4217 code for the funds base reporting currency used for conversion.. Valid values are `^[A-Z]{3}$`',
    `carried_interest_percent` DECIMAL(5,2) COMMENT 'Percentage of profits above the hurdle rate that will be paid to the General Partner as carried interest.',
    `commitment_amount` DECIMAL(20,2) COMMENT 'Total capital amount committed and approved by the Investment Committee for this deal.',
    `commitment_amount_base_currency` DECIMAL(20,2) COMMENT 'Commitment amount converted to the funds base reporting currency at the approval date exchange rate.',
    `commitment_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the commitment amount (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `commitment_expiry_date` DATE COMMENT 'Date after which the capital commitment expires if not drawn or legally executed.',
    `commitment_name` STRING COMMENT 'Descriptive name for the capital commitment, typically referencing the target entity and commitment type.',
    `commitment_notes` STRING COMMENT 'Additional notes, comments, or context related to this capital commitment.',
    `commitment_reference_number` STRING COMMENT 'External business identifier for this capital commitment, used in legal documents and reporting.',
    `commitment_status` STRING COMMENT 'Current lifecycle status of the capital commitment: approved, reserved, active, partially funded, fully funded, cancelled, or expired. [ENUM-REF-CANDIDATE: approved|reserved|active|partially_funded|fully_funded|cancelled|expired — 7 candidates stripped',
    `commitment_type` STRING COMMENT 'Type of capital commitment being made: equity, debt, mezzanine, preferred equity, fund commitment, or co-investment.. Valid values are `equity|debt|mezzanine|preferred_equity|fund_commitment|co_investment`',
    `dry_powder_allocation` DECIMAL(20,2) COMMENT 'Amount of uncalled committed capital (dry powder) reserved for this commitment at approval.',
    `esg_exclusion_flag` BOOLEAN COMMENT 'Indicates whether the investment was subject to ESG exclusion screening (True if exclusions apply, False otherwise).',
    `esg_rating` STRING COMMENT 'ESG rating assigned to the target entity or investment at the time of commitment approval.',
    `expected_final_close_date` DATE COMMENT 'Expected date by which the investment will reach final close and the commitment becomes legally binding.',
    `expected_first_drawdown_date` DATE COMMENT 'Anticipated date for the first capital call or drawdown against this commitment.',
    `expected_hold_period_years` BIGINT COMMENT 'Expected total holding period in years from initial investment to full exit.',
    `expected_investment_period_years` BIGINT COMMENT 'Expected duration in years over which the committed capital will be deployed.',
    `fx_rate_at_approval` DECIMAL(18,8) COMMENT 'Exchange rate used to convert commitment amount to base currency at the time of IC approval.',
    `gp_sponsor_name` STRING COMMENT 'Name of the General Partner or sponsor managing the investment, applicable for fund commitments and co-investments.',
    `hurdle_rate_percent` DECIMAL(5,2) COMMENT 'Preferred return threshold percentage that must be achieved before carried interest is paid to the GP.',
    `ic_approval_date` DATE COMMENT 'Date on which the Investment Committee formally approved this capital commitment.',
    `ic_conditions` STRING COMMENT 'Any conditions or requirements imposed by the Investment Committee as part of the approval.',
    `ic_decision_outcome` STRING COMMENT 'Final decision outcome from the Investment Committee: approved, approved with conditions, deferred, or rejected.. Valid values are `approved|approved_with_conditions|deferred|rejected`',
    `ic_meeting_reference` STRING COMMENT 'Reference identifier for the IC meeting at which this commitment was approved.',
    `investment_strategy` STRING COMMENT 'Specific investment strategy or mandate under which this commitment is being made.',
    `investment_thesis` STRING COMMENT 'Summary of the strategic rationale and value creation hypothesis supporting this capital commitment.',
    `lpa_execution_date` DATE COMMENT 'Date on which the Limited Partnership Agreement was formally executed.',
    `lpa_signed_flag` BOOLEAN COMMENT 'Indicates whether the Limited Partnership Agreement has been executed (True if signed, False otherwise).',
    `management_fee_percent` DECIMAL(5,2) COMMENT 'Annual management fee percentage charged on committed or invested capital.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this commitment record was first created in the data platform.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this commitment record was last updated in the data platform.',
    `risk_rating` STRING COMMENT 'Overall risk rating assigned to this commitment: low, medium, high, or very high.. Valid values are `low|medium|high|very_high`',
    `source_system_code` STRING COMMENT 'Unique identifier for this commitment record in the source operational system.',
    `strategic_fit_score` BIGINT COMMENT 'Quantitative score (typically 1-10) representing how well this commitment aligns with the funds strategic asset allocation.',
    `sub_asset_class` STRING COMMENT 'Detailed sub-classification within the primary asset class (e.g., growth equity, core real estate, renewable infrastructure).',
    `target_entity_name` STRING COMMENT 'Legal name of the target entity or fund receiving the capital commitment.',
    `target_irr_percent` DECIMAL(5,2) COMMENT 'Target net Internal Rate of Return percentage expected from this investment at the time of commitment.',
    `target_jurisdiction` STRING COMMENT 'Three-letter ISO country code for the primary jurisdiction of the target entity.. Valid values are `^[A-Z]{3}$`',
    `target_lei` STRING COMMENT '20-character ISO 17442 Legal Entity Identifier for the target entity, if available.. Valid values are `^[A-Z0-9]{20}$`',
    `target_moic` DECIMAL(5,2) COMMENT 'Target Multiple on Invested Capital expected from this investment at the time of commitment.',
    `vintage_year` BIGINT COMMENT 'Year in which the capital commitment was approved, used for cohort analysis and performance benchmarking.',
    CONSTRAINT pk_deal_capital_commitment PRIMARY KEY(`deal_capital_commitment_id`)
) COMMENT 'Master record for the capital commitment approved and reserved for a deal at IC approval. Captures the opportunity, IC submission reference, approved commitment amount, commitment currency, commitment type (equity, debt, co-invest, fund commitment)';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`ppm_review` (
    `ppm_review_id` BIGINT COMMENT 'Unique identifier for the PPM review record. Primary key.',
    `employee_id` BIGINT COMMENT 'Identifier of the investment professional who conducted the primary PPM review.',
    `fee_benchmark_id` BIGINT COMMENT 'Foreign key linking to fee.fee_benchmark. Business justification: PPM due diligence requires systematic comparison of proposed fund fee terms against market benchmarks.',
    `opportunity_id` BIGINT COMMENT 'Reference to the investment opportunity being evaluated through this PPM review.',
    `reviewer_employee_id` BIGINT COMMENT 'Identifier of the investment professional who conducted the primary PPM review.',
    `carried_interest_percent` DECIMAL(5,4) COMMENT 'Carried interest percentage that the GP will receive on profits above the hurdle rate.',
    `esg_policy_summary` STRING COMMENT 'Summary of the funds ESG policy, responsible investment approach, and sustainability commitments as disclosed in the PPM.',
    `esg_rating` STRING COMMENT 'Internal ESG rating assigned to the fund based on PPM review and ESG due diligence.',
    `follow_up_actions` STRING COMMENT 'List of follow-up actions, additional diligence items, or clarifications required before proceeding.',
    `fund_asset_class` STRING COMMENT 'Primary asset class focus of the fund being reviewed.. Valid values are `private_equity|real_estate|infrastructure|natural_resources|credit|multi_strategy`',
    `fund_name` STRING COMMENT 'Name of the fund or investment vehicle described in the PPM.',
    `fund_strategy` STRING COMMENT 'Investment strategy of the fund as described in the PPM, including asset class focus and approach.',
    `fund_term_years` BIGINT COMMENT 'Total term of the fund in years, including investment period and harvest period.',
    `fund_vintage_year` BIGINT COMMENT 'Vintage year of the fund, representing the year of first capital commitment.',
    `gp_aum_amount` DECIMAL(18,2) COMMENT 'Total assets under management by the GP as disclosed in the PPM.',
    `gp_aum_currency` STRING COMMENT 'Currency code for the GP assets under management amount.',
    `gp_lei` STRING COMMENT 'Legal Entity Identifier of the General Partner for regulatory identification.',
    `gp_prior_fund_count` BIGINT COMMENT 'Number of prior funds managed by the GP as disclosed in the PPM.',
    `gp_sponsor_name` STRING COMMENT 'Name of the General Partner or sponsor managing the fund.',
    `gp_track_record_assessment` STRING COMMENT 'Qualitative assessment of the GPs historical performance and track record based on PPM disclosures and external research.',
    `hurdle_rate_percent` DECIMAL(5,4) COMMENT 'Preferred return threshold that must be achieved before GP receives carried interest.',
    `ic_submission_required` BOOLEAN COMMENT 'Flag indicating whether this opportunity requires formal Investment Committee submission and approval.',
    `investment_period_years` BIGINT COMMENT 'Duration in years during which the fund will actively deploy capital into new investments.',
    `investment_restrictions` STRING COMMENT 'Summary of investment restrictions, concentration limits, and prohibited activities specified in the PPM.',
    `key_person_provisions` STRING COMMENT 'Summary of key person provisions and conditions outlined in the PPM.',
    `management_fee_percent` DECIMAL(5,4) COMMENT 'Annual management fee percentage charged by the GP as stated in the PPM.',
    `minimum_commitment_amount` DECIMAL(18,2) COMMENT 'Minimum investment commitment required from Limited Partners as specified in the PPM.',
    `minimum_commitment_currency` STRING COMMENT 'Currency code for the minimum commitment amount.',
    `ppm_document_date` DATE COMMENT 'Issuance or effective date of the PPM document under review.',
    `ppm_document_version` STRING COMMENT 'Version identifier of the Private Placement Memorandum document being reviewed.',
    `recommendation` STRING COMMENT 'Reviewers recommendation on whether to proceed with the investment opportunity.. Valid values are `proceed|proceed_with_conditions|decline|further_diligence_required`',
    `recommendation_rationale` STRING COMMENT 'Detailed rationale supporting the reviewers recommendation, including key strengths and concerns.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this PPM review record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this PPM review record was last updated in the system.',
    `red_flags_identified` STRING COMMENT 'Summary of any red flags, concerns, or material issues identified during the PPM review.',
    `review_code` STRING COMMENT 'Business identifier for the PPM review, typically combining opportunity code and review sequence.',
    `review_completed_timestamp` TIMESTAMP COMMENT 'Timestamp when the PPM review was completed and findings finalized.',
    `review_date` DATE COMMENT 'Date when the PPM review was conducted or completed.',
    `review_initiated_timestamp` TIMESTAMP COMMENT 'Timestamp when the PPM review process was formally initiated.',
    `review_notes` STRING COMMENT 'Additional notes, observations, or commentary from the PPM review process.',
    `review_status` STRING COMMENT 'Current lifecycle status of the PPM review process.. Valid values are `initiated|in_progress|completed|approved|rejected|on_hold`',
    `review_team` STRING COMMENT 'Name or identifier of the investment team responsible for the PPM review.',
    `reviewer_name` STRING COMMENT 'Full name of the investment professional who conducted the PPM review.',
    `risk_assessment` STRING COMMENT 'Overall risk assessment of the fund opportunity based on PPM review, including strategy risk, GP risk, and structural risk.',
    `risk_rating` STRING COMMENT 'Categorical risk rating assigned to the fund opportunity.. Valid values are `low|medium|high|very_high`',
    `strategic_fit_score` BIGINT COMMENT 'Numerical score representing alignment of the fund with the organizations strategic asset allocation and investment objectives.',
    `target_fund_size_amount` DECIMAL(18,2) COMMENT 'Target total capital to be raised for the fund as stated in the PPM.',
    `target_fund_size_currency` STRING COMMENT 'Currency code for the target fund size amount.',
    CONSTRAINT pk_ppm_review PRIMARY KEY(`ppm_review_id`)
) COMMENT 'Master record for Private Placement Memorandum (PPM) reviews conducted during fund manager and co-investment screening. Captures the opportunity, PPM document version, review date, reviewer, fund strategy summary, GP track record assessment, fee structure';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`screening_decision` (
    `screening_decision_id` BIGINT COMMENT 'Unique identifier for the screening decision record. Primary key for the screening decision entity.',
    `employee_id` BIGINT COMMENT 'Reference to the individual who chaired the screening committee meeting. Senior investment professional responsible for decision governance.',
    `lead_reviewer_employee_id` BIGINT COMMENT 'Reference to the investment professional who led the screening analysis and presented to the committee. Primary deal sponsor.',
    `opportunity_id` BIGINT COMMENT 'Reference to the investment opportunity being screened. Links to the deal opportunity under review.',
    `screening_employee_id` BIGINT COMMENT 'Reference to the individual who chaired the screening committee meeting. Senior investment professional responsible for decision governance.',
    `screening_lead_reviewer_employee_id` BIGINT COMMENT 'Reference to the investment professional who led the screening analysis and presented to the committee. Primary deal sponsor.',
    `committee_chair_name` STRING COMMENT 'Full name of the committee chair who presided over the screening decision. Denormalized for reporting convenience.',
    `committee_member_count` BIGINT COMMENT 'Number of committee members present at the screening review. Used to validate quorum requirements.',
    `conditions_imposed` STRING COMMENT 'List of conditions or requirements that must be met before advancing to the next stage. May include additional due diligence (DD), valuation work, or legal reviews.',
    `confidentiality_level` STRING COMMENT 'Data classification level for the screening decision record. Determines access controls and distribution restrictions.. Valid values are `public|internal|confidential|restricted`',
    `decision_outcome` STRING COMMENT 'Final outcome of the screening review. Proceed advances to next stage; hold pauses for additional information; decline terminates the opportunity; conditional proceed requires specific conditions to be met.. Valid values are `proceed|hold|decline|conditional_proceed|refer_to_ic`',
    `decision_status` STRING COMMENT 'Current lifecycle status of the screening decision record. Tracks workflow state from draft through final approval.. Valid values are `draft|submitted|approved|rejected|withdrawn`',
    `decline_reason_code` STRING COMMENT 'Standardized code categorizing the primary reason for declining the opportunity. Used for pipeline analytics and sourcing strategy refinement.',
    `decline_reason_description` STRING COMMENT 'Detailed explanation of why the opportunity was declined. Captures investment thesis misalignment, valuation concerns, risk factors, or strategic fit issues.',
    `esg_exclusion_flag` BOOLEAN COMMENT 'Indicates whether the opportunity was flagged for Environmental Social and Governance (ESG) exclusion criteria. True if the investment violates responsible investment policies.',
    `esg_rating` STRING COMMENT 'Environmental Social and Governance (ESG) assessment grade assigned during screening. Reflects alignment with Principles for Responsible Investment (PRI) and Sustainable Finance Disclosure Regulation (SFDR) requirements.. Valid values are `A|B|C|D|F`',
    `hold_reason` STRING COMMENT 'Explanation for placing the opportunity on hold. Identifies missing information, pending external events, or conditions that must be satisfied before proceeding.',
    `ic_submission_date` DATE COMMENT 'Date when the Investment Memorandum (IM) was submitted to Investment Committee (IC) for formal approval. Applicable for opportunities requiring IC review.',
    `ic_submission_required` BOOLEAN COMMENT 'Indicates whether the opportunity must be escalated to full Investment Committee (IC) for approval. True if deal size or risk profile exceeds delegated authority thresholds.',
    `lead_reviewer_name` STRING COMMENT 'Full name of the lead investment professional who conducted the screening review. Denormalized for reporting convenience.',
    `legal_concern_flag` BOOLEAN COMMENT 'Indicates whether legal or regulatory concerns were identified during screening. True if material legal risks require further assessment.',
    `meeting_reference_number` STRING COMMENT 'Reference identifier for the committee meeting where the screening decision was made. Links to Investment Committee (IC) meeting minutes.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next screening review or follow-up. Applicable when decision outcome is hold or conditional proceed.',
    `operational_concern_flag` BOOLEAN COMMENT 'Indicates whether operational due diligence (ODD) concerns were identified. True if material operational risks require further investigation.',
    `quorum_met` BOOLEAN COMMENT 'Indicates whether the required quorum of committee members was present for the screening decision. True if quorum requirements were satisfied.',
    `record_created_by` STRING COMMENT 'User or system identifier that created the screening decision record. Audit trail for data governance.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when the screening decision record was first created in the lakehouse. Audit trail for data lineage.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the screening decision record was last modified in the lakehouse. Audit trail for data lineage.',
    `risk_rating` STRING COMMENT 'Overall risk assessment assigned during screening. Considers operational, financial, market, and Environmental Social and Governance (ESG) risks.. Valid values are `low|medium|high|very_high`',
    `screening_committee_name` STRING COMMENT 'Name of the committee or review body that made the screening decision. May be asset class-specific committee or central Investment Committee (IC).',
    `screening_date` DATE COMMENT 'Date when the screening decision was formally made. Principal business event timestamp for the screening review.',
    `screening_notes` STRING COMMENT 'Free-text notes and commentary from the screening committee. Captures key discussion points, concerns raised, and rationale for the decision.',
    `screening_number` STRING COMMENT 'Business identifier for the screening decision. Human-readable reference number used in Investment Committee (IC) documentation and pipeline tracking.',
    `screening_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the screening decision was recorded in the system. Captures exact moment of decision finalization.',
    `screening_type` STRING COMMENT 'Classification of the screening review. Initial screening is preliminary assessment; full screening is comprehensive due diligence (DD) gate review.. Valid values are `initial|full|supplemental|expedited|special`',
    `source_system_code` STRING COMMENT 'Unique identifier of the screening decision record in the source system. Used for data lineage and reconciliation.',
    `strategic_fit_score` DECIMAL(5,2) COMMENT 'Quantitative assessment of how well the opportunity aligns with Strategic Asset Allocation (SAA) and investment mandate. Scale typically 0-100.',
    `supporting_document_count` BIGINT COMMENT 'Number of supporting documents attached to the screening decision. Includes Investment Memorandum (IM), due diligence (DD) reports, and valuation models.',
    `unanimous_decision` BOOLEAN COMMENT 'Indicates whether the screening decision was unanimous. True if all voting members agreed on the outcome.',
    `valuation_concern_flag` BOOLEAN COMMENT 'Indicates whether the screening committee identified material valuation concerns. True if pricing appears misaligned with intrinsic value or market comparables.',
    `vote_abstain_count` BIGINT COMMENT 'Number of committee members who abstained from voting. Typically due to conflict of interest or insufficient information.',
    `vote_against_count` BIGINT COMMENT 'Number of committee members who voted against proceeding with the opportunity. Used for governance audit trail.',
    `vote_for_count` BIGINT COMMENT 'Number of committee members who voted in favor of proceeding with the opportunity. Used for governance audit trail.',
    CONSTRAINT pk_screening_decision PRIMARY KEY(`screening_decision_id`)
) COMMENT 'Transactional record capturing the formal screening decision made at each pipeline gate review. Records the opportunity, screening date, screening type (initial/full), screening committee members, decision outcome (proceed, hold, decline), decline reason';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`deal_document` (
    `deal_document_id` BIGINT COMMENT 'Unique identifier for the deal document record. Primary key.',
    `approved_by_user_employee_id` BIGINT COMMENT 'Identifier of the user who approved the document, if applicable.',
    `counterparty_legal_entity_counterparty_id` BIGINT COMMENT 'Identifier of the external legal entity that is a party to this document (e.g., target company, General Partner (GP), intermediary).',
    `deal_ic_submission_id` BIGINT COMMENT 'Reference to the Investment Committee (IC) submission package that includes this document, if applicable.',
    `employee_id` BIGINT COMMENT 'Identifier of the internal user who uploaded the document into the system.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal opportunity this document belongs to.',
    `owner_user_employee_id` BIGINT COMMENT 'Identifier of the internal user responsible for managing and maintaining this document.',
    `superseded_by_document_deal_document_id` BIGINT COMMENT 'Reference to the newer document that supersedes this document, if applicable.',
    `access_restriction_flag` BOOLEAN COMMENT 'Indicates whether access to this document is restricted to specific users or roles.',
    `approval_date` DATE COMMENT 'Date when the document was formally approved.',
    `approval_required_flag` BOOLEAN COMMENT 'Indicates whether this document requires formal approval before it can be executed or finalized.',
    `approval_status` STRING COMMENT 'Current approval status of the document: Pending, Approved, Rejected, or Not Required.. Valid values are `PENDING|APPROVED|REJECTED|NOT_REQUIRED`',
    `approved_by_user_name` STRING COMMENT 'Full name of the user who approved the document.',
    `asset_class` STRING COMMENT 'Asset class associated with the deal this document supports (e.g., Public Equities, Private Equity, Real Estate, Infrastructure, Natural Resources, Credit).',
    `author_name` STRING COMMENT 'Name of the individual or organization that authored or prepared the document.',
    `confidentiality_level` STRING COMMENT 'Data classification level indicating the sensitivity of the document: Public, Internal, Confidential, or Restricted.. Valid values are `PUBLIC|INTERNAL|CONFIDENTIAL|RESTRICTED`',
    `deal_stage_code` STRING COMMENT 'Code representing the deal pipeline stage at which this document was created or uploaded.',
    `document_date` DATE COMMENT 'Official date of the document as stated on the document itself (e.g., execution date, issuance date, effective date).',
    `document_description` STRING COMMENT 'Detailed description or summary of the document content and purpose.',
    `document_status` STRING COMMENT 'Current lifecycle status of the document: Draft, Under Review, Approved, Executed, Superseded, Archived, or Rejected. [ENUM-REF-CANDIDATE: DRAFT|UNDER_REVIEW|APPROVED|EXECUTED|SUPERSEDED|ARCHIVED|REJECTED — 7 candidates stripped; promote to reference',
    `effective_date` DATE COMMENT 'Date from which the document becomes legally or operationally effective.',
    `execution_date` DATE COMMENT 'Date when the document was executed or signed by all parties, if applicable.',
    `expiry_date` DATE COMMENT 'Date when the document expires or ceases to be valid, if applicable.',
    `external_signatory_name` STRING COMMENT 'Name of the external counterparty representative who signed the document.',
    `external_signatory_title` STRING COMMENT 'Job title or role of the external signatory.',
    `file_format` STRING COMMENT 'File format or extension of the document (e.g., PDF, DOCX, XLSX, PPTX, MSG, ZIP). [ENUM-REF-CANDIDATE: PDF|DOCX|XLSX|PPTX|MSG|ZIP|OTHER — 7 candidates stripped; promote to reference product]',
    `file_name` STRING COMMENT 'Original file name of the uploaded document including file extension.',
    `file_size_bytes` BIGINT COMMENT 'Size of the document file in bytes for storage and retrieval tracking.',
    `hash` STRING COMMENT 'Cryptographic hash (e.g., SHA-256) of the document file to ensure integrity and detect tampering.',
    `internal_signatory_name` STRING COMMENT 'Name of the internal representative who signed the document on behalf of the organization.',
    `internal_signatory_title` STRING COMMENT 'Job title or role of the internal signatory.',
    `legal_counsel_firm` STRING COMMENT 'Name of the external legal counsel firm that reviewed or advised on this document, if applicable.',
    `legal_review_required_flag` BOOLEAN COMMENT 'Indicates whether this document requires review by internal or external legal counsel.',
    `legal_review_status` STRING COMMENT 'Current status of legal review for this document: Pending, In Progress, Completed, or Not Required.. Valid values are `PENDING|IN_PROGRESS|COMPLETED|NOT_REQUIRED`',
    `notes` STRING COMMENT 'Additional notes, comments, or annotations related to the document for internal reference.',
    `owner_user_name` STRING COMMENT 'Full name of the internal user who owns this document.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this record was first created in the system for audit and lineage tracking.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this record was last updated in the system for audit and lineage tracking.',
    `reference_number` STRING COMMENT 'Externally-known unique reference number or code assigned to this document for tracking and retrieval purposes.',
    `storage_location` STRING COMMENT 'Physical or logical storage path where the document is stored (e.g., cloud storage URI, file share path, data room location).',
    `title` STRING COMMENT 'Full title or name of the deal document as it appears on the document itself.',
    `type_code` STRING COMMENT 'Categorical code classifying the document type: Non-Disclosure Agreement (NDA), Letter of Intent (LOI), Term Sheet, Investment Memorandum (IM), Private Placement Memorandum (PPM), Financial Model, Legal Opinion, Management Presentation, Data Room Index',
    `type_name` STRING COMMENT 'Human-readable name of the document type for display and reporting purposes.',
    `upload_date` DATE COMMENT 'Date when the document was uploaded into the deal pipeline system.',
    `upload_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the document was uploaded into the system, including time zone information.',
    `uploaded_by_user_name` STRING COMMENT 'Full name of the internal user who uploaded the document.',
    `version` STRING COMMENT 'Version identifier of the document (e.g., v1.0, v2.1, Final) to track revisions and iterations.',
    `version_sequence_number` BIGINT COMMENT 'Numeric sequence number indicating the version order for sorting and comparison purposes.',
    CONSTRAINT pk_deal_document PRIMARY KEY(`deal_document_id`)
) COMMENT 'Master record for all deal-related documents managed within the deal pipeline. Captures document type (NDA, LOI, term sheet, IM, PPM, financial model, legal opinion, management presentation, data room index), document title, document version, upload date';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`exclusivity_agreement` (
    `exclusivity_agreement_id` BIGINT COMMENT 'Unique identifier for the exclusivity agreement record. Primary key.',
    `counterparty_id` BIGINT COMMENT 'Reference to the seller, General Partner (GP), or other counterparty legal entity with whom exclusivity is negotiated.',
    `counterparty_legal_entity_counterparty_id` BIGINT COMMENT 'Reference to the seller, General Partner (GP), or other counterparty legal entity with whom exclusivity is negotiated.',
    `employee_id` BIGINT COMMENT 'Reference to the internal investment professional responsible for negotiating and managing this exclusivity agreement.',
    `lead_investment_professional_employee_id` BIGINT COMMENT 'Reference to the internal investment professional responsible for negotiating and managing this exclusivity agreement.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal opportunity for which this exclusivity agreement was negotiated.',
    `agreement_number` STRING COMMENT 'Externally-known unique reference number or code assigned to this exclusivity agreement for tracking and communication purposes.',
    `agreement_type` STRING COMMENT 'Classification of the exclusivity arrangement: full exclusivity (no other buyers), limited exclusivity (restricted buyer pool), no-shop (no active solicitation), no-talk (no discussions), or standstill (no hostile action).. Valid values are `full_exclusivity|limited_exclusivity|no_shop|no_talk|standstill`',
    `arbitration_venue` STRING COMMENT 'City or institution designated for arbitration proceedings if arbitration is the chosen dispute resolution mechanism (e.g., London, New York, ICC Paris).',
    `asset_class` STRING COMMENT 'Primary asset class of the investment opportunity covered by this exclusivity agreement.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `breach_description` STRING COMMENT 'Narrative description of the alleged or confirmed breach of exclusivity terms, including nature of violation and parties involved.',
    `breach_reported_flag` BOOLEAN COMMENT 'Indicates whether a breach of the exclusivity terms has been reported or alleged by either party.',
    `break_fee_amount` DECIMAL(18,2) COMMENT 'Monetary penalty payable by the counterparty if they breach the exclusivity terms or accept a competing offer during the exclusivity period.',
    `break_fee_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the break fee amount (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `counterparty_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the counterparty, enabling global entity identification and regulatory reporting.. Valid values are `^[A-Z0-9]{20}$`',
    `counterparty_signatory_name` STRING COMMENT 'Name of the authorized representative from the counterparty organization who signed the exclusivity agreement.',
    `counterparty_signatory_title` STRING COMMENT 'Job title or role of the counterparty signatory who executed the exclusivity agreement.',
    `deal_structure` STRING COMMENT 'High-level description of the proposed transaction structure (e.g., equity purchase, asset acquisition, joint venture, co-investment) contemplated during the exclusivity period.',
    `deposit_amount` DECIMAL(18,2) COMMENT 'Refundable or non-refundable deposit paid by the buyer to secure exclusivity, demonstrating commitment and compensating seller for opportunity cost.',
    `deposit_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the exclusivity deposit amount.. Valid values are `^[A-Z]{3}$`',
    `deposit_refundable_flag` BOOLEAN COMMENT 'Indicates whether the exclusivity deposit is refundable to the buyer if the deal does not close (true) or is forfeited to the seller (false).',
    `dispute_resolution_mechanism` STRING COMMENT 'Method specified for resolving disputes arising from the exclusivity agreement: litigation (court proceedings), arbitration (binding private tribunal), or mediation (facilitated negotiation).. Valid values are `litigation|arbitration|mediation`',
    `document_storage_location` STRING COMMENT 'File path, URL, or document management system reference where the executed exclusivity agreement is stored for retrieval and audit purposes.',
    `effective_date` DATE COMMENT 'Date from which the exclusivity period begins and the counterparty is bound by the exclusivity terms.',
    `exclusivity_agreement_status` STRING COMMENT 'Current lifecycle status of the exclusivity agreement: draft (under negotiation), executed (signed), active (in force), expired (period ended), terminated (ended early), or breached (violated).. Valid values are `draft|executed|active|expired|terminated|breached`',
    `exclusivity_period_days` BIGINT COMMENT 'Total number of calendar days for which exclusivity is granted, calculated from effective date to expiry date.',
    `execution_date` DATE COMMENT 'Date on which the exclusivity agreement was signed by all parties.',
    `expiry_date` DATE COMMENT 'Date on which the exclusivity period ends, after which the counterparty may engage with other buyers unless extended or deal closes.',
    `extension_count` BIGINT COMMENT 'Number of times the exclusivity period has been extended beyond the original expiry date.',
    `extension_permitted_flag` BOOLEAN COMMENT 'Indicates whether the exclusivity period may be extended by mutual agreement or under predefined conditions (true) or is fixed with no extension provision (false).',
    `external_counsel_firm` STRING COMMENT 'Name of the external law firm engaged to advise on or draft the exclusivity agreement, if applicable.',
    `fiduciary_out_clause_flag` BOOLEAN COMMENT 'Indicates whether the agreement includes a fiduciary out clause allowing the counterparty to consider superior proposals if required by fiduciary duty to shareholders or beneficiaries.',
    `governing_law_jurisdiction` STRING COMMENT 'Legal jurisdiction whose laws govern the interpretation and enforcement of the exclusivity agreement (e.g., New York, England and Wales, Delaware).',
    `indicative_enterprise_value` DECIMAL(18,2) COMMENT 'Non-binding indicative enterprise value of the target entity or asset at the time the exclusivity agreement was executed, used for scoping the transaction.',
    `internal_counsel_approval_flag` BOOLEAN COMMENT 'Indicates whether the exclusivity agreement has been reviewed and approved by internal legal counsel prior to execution.',
    `internal_signatory_name` STRING COMMENT 'Name of the authorized representative from the pension fund who signed the exclusivity agreement on behalf of the organization.',
    `internal_signatory_title` STRING COMMENT 'Job title or role of the internal signatory who executed the exclusivity agreement (e.g., Chief Investment Officer, Managing Director).',
    `loi_reference_number` STRING COMMENT 'Reference number of the associated Letter of Intent that may have been issued concurrently with or following this exclusivity agreement.',
    `nda_reference_number` STRING COMMENT 'Reference number of the associated NDA that preceded or accompanies this exclusivity agreement, establishing confidentiality obligations.',
    `no_shop_provision_flag` BOOLEAN COMMENT 'Indicates whether the agreement includes a no-shop provision prohibiting the counterparty from actively soliciting or entertaining competing offers during the exclusivity period.',
    `notes` STRING COMMENT 'Free-form notes capturing additional context, special conditions, negotiation history, or internal commentary related to this exclusivity agreement.',
    `record_created_by` STRING COMMENT 'Username or identifier of the user or system process that created this exclusivity agreement record.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this exclusivity agreement record was first created in the data platform.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this exclusivity agreement record was last modified in the data platform.',
    `remediation_action_taken` STRING COMMENT 'Description of remedial actions taken in response to a breach, including legal action, fee collection, or agreement termination.',
    `scope_description` STRING COMMENT 'Detailed narrative describing the scope and boundaries of the exclusivity arrangement, including any carve-outs, permitted actions, or restrictions on counterparty behavior.',
    `source_system_code` STRING COMMENT 'Unique identifier of this exclusivity agreement record in the source operational system, enabling traceability and reconciliation.',
    `standstill_period_months` BIGINT COMMENT 'Duration in months for which the standstill provision remains in effect, restricting hostile actions by the buyer.',
    `standstill_provision_flag` BOOLEAN COMMENT 'Indicates whether the agreement includes a standstill provision preventing the buyer from taking hostile action (e.g., unsolicited tender offer) during or after the exclusivity period.',
    `target_entity_name` STRING COMMENT 'Name of the target company, asset, or investment opportunity that is the subject of the exclusivity agreement.',
    `target_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the target entity, if applicable and available.. Valid values are `^[A-Z0-9]{20}$`',
    `termination_date` DATE COMMENT 'Actual date on which the exclusivity agreement was terminated early, if applicable (null if agreement ran to expiry or is still active).',
    `valuation_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the indicative enterprise value.. Valid values are `^[A-Z]{3}$`',
    CONSTRAINT pk_exclusivity_agreement PRIMARY KEY(`exclusivity_agreement_id`)
) COMMENT 'Master record for exclusivity agreements negotiated with sellers or GPs during deal execution. Captures the opportunity, counterparty, exclusivity start date, exclusivity end date, exclusivity scope description, break fee amount, break fee currency';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`milestone` (
    `milestone_id` BIGINT COMMENT 'Unique identifier for the deal_milestone data product (auto-inserted during validation).',
    `completed_by_user_employee_id` BIGINT COMMENT 'System identifier of the user who marked this milestone as completed.',
    `employee_id` BIGINT COMMENT 'System identifier of the user assigned as responsible for this milestone completion.',
    `opportunity_id` BIGINT COMMENT 'Reference to the investment opportunity this milestone belongs to.',
    `actual_date` DATE COMMENT 'Date when the milestone was actually achieved or completed.',
    `approving_committee` STRING COMMENT 'Name of the Investment Committee (IC) or governance body that approved this milestone.',
    `asset_class` STRING COMMENT 'Investment asset class category for this deal milestone such as public equities, private equity, real estate, infrastructure, natural resources, or credit.',
    `milestone_code` STRING COMMENT 'Standardized code representing the milestone type for system processing and reporting.',
    `conditions_imposed` STRING COMMENT 'Description of any conditions, contingencies, or requirements imposed at this milestone by Investment Committee (IC) or counterparty.',
    `conditions_met` BOOLEAN COMMENT 'Flag indicating whether all conditions precedent for this milestone have been satisfied.',
    `counterparty_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the counterparty entity.. Valid values are `^[A-Z0-9]{20}$`',
    `counterparty_name` STRING COMMENT 'Name of the counterparty organization involved in this milestone such as seller, General Partner (GP), or intermediary.',
    `deal_type` STRING COMMENT 'Classification of the deal structure associated with this milestone.. Valid values are `direct_investment|co_investment|fund_commitment|secondary|joint_venture`',
    `decision_date` DATE COMMENT 'Date when the gate decision was formally made by the Investment Committee (IC) or approving authority.',
    `document_execution_date` DATE COMMENT 'Date when the associated legal or business document was formally executed by all parties.',
    `document_reference_number` STRING COMMENT 'Reference number of the key legal or business document associated with this milestone such as Non-Disclosure Agreement (NDA), Letter of Intent (LOI), or Share Purchase Agreement (SPA) number.',
    `esg_review_required` BOOLEAN COMMENT 'Flag indicating whether Environmental, Social, and Governance review is required at this milestone per Principles for Responsible Investment (PRI) standards.',
    `esg_review_status` STRING COMMENT 'Current status of the Environmental, Social, and Governance due diligence review for this milestone.. Valid values are `not_started|in_progress|completed|waived`',
    `gate_decision` STRING COMMENT 'Decision outcome for gate milestones requiring formal approval or go/no-go determination.. Valid values are `approved|rejected|conditional|deferred|withdrawn`',
    `gp_sponsor_name` STRING COMMENT 'Name of the General Partner or sponsor firm managing the investment vehicle or co-investment opportunity.',
    `ic_meeting_date` DATE COMMENT 'Date of the Investment Committee meeting where this milestone was reviewed or approved.',
    `intermediary_name` STRING COMMENT 'Name of the investment bank, broker, or advisor intermediating the deal opportunity.',
    `investment_strategy` STRING COMMENT 'Strategic investment approach or mandate under which this deal milestone is being executed.',
    `is_critical_path` BOOLEAN COMMENT 'Flag indicating whether this milestone is on the critical path for deal closure.',
    `is_gate_milestone` BOOLEAN COMMENT 'Flag indicating whether this milestone represents a formal approval gate requiring Investment Committee (IC) or governance decision.',
    `milestone_status` STRING COMMENT 'Current lifecycle status of the milestone indicating its completion state.. Valid values are `pending|in_progress|completed|cancelled|deferred|failed`',
    `milestone_timestamp` TIMESTAMP COMMENT 'Precise timestamp when the milestone event occurred for audit trail and sequencing.',
    `milestone_type` STRING COMMENT 'Classification of the milestone event in the deal execution timeline. [ENUM-REF-CANDIDATE: nda_signed|loi_issued|exclusivity_granted|dd_commenced|ic_submission|ic_approval|spa_signed|regulatory_filing|financial_close — 9 candidates stripped; promote to',
    `milestone_name` STRING COMMENT 'Human-readable name of the milestone event for business user display and reporting.',
    `notes` STRING COMMENT 'Free-text commentary providing additional context, observations, or instructions related to this milestone.',
    `notification_sent` BOOLEAN COMMENT 'Flag indicating whether automated notification was sent to stakeholders upon milestone completion or status change.',
    `notification_timestamp` TIMESTAMP COMMENT 'Timestamp when the milestone notification was sent to stakeholders.',
    `record_created_by` STRING COMMENT 'Username or identifier of the user who created this milestone record.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this milestone record was first created in the system for audit trail purposes.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this milestone record was last modified for change tracking and audit compliance.',
    `regulatory_approval_required` BOOLEAN COMMENT 'Flag indicating whether regulatory or governmental approval is required to complete this milestone.',
    `regulatory_jurisdiction` STRING COMMENT 'Jurisdiction or regulatory body whose approval is required for this milestone such as the national pension regulator, Securities and Exchange Commission (SEC), or Financial Conduct Authority (FCA).',
    `responsible_party` STRING COMMENT 'Name of the individual or team responsible for completing this milestone.',
    `risk_rating` STRING COMMENT 'Risk assessment level assigned to this milestone based on execution complexity, market conditions, or counterparty factors.. Valid values are `low|medium|high|critical`',
    `scheduled_date` DATE COMMENT 'Planned or target date for achieving this milestone as per deal execution plan.',
    `sequence` BIGINT COMMENT 'Ordinal position of this milestone within the deal execution timeline for chronological ordering.',
    `source_system_code` STRING COMMENT 'Unique identifier of this milestone record in the source system for data lineage and reconciliation.',
    `target_entity_name` STRING COMMENT 'Legal name of the target company or asset being acquired or invested in.',
    `target_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the target entity enabling global counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `variance_days` BIGINT COMMENT 'Number of days difference between scheduled and actual milestone completion, positive for delays and negative for early completion.',
    CONSTRAINT pk_milestone PRIMARY KEY(`milestone_id`)
) COMMENT 'Transactional record tracking key milestones in the deal execution timeline. Captures the opportunity, milestone type (NDA signed, LOI issued, exclusivity granted, DD commenced, IC submission, IC approval, SPA signed, regulatory filing, financial close)';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`co_invest_allocation` (
    `co_invest_allocation_id` BIGINT COMMENT 'Unique identifier for the co-investment allocation record.',
    `kyc_record_id` BIGINT COMMENT 'Foreign key linking to compliance.kyc_record. Business justification: Co-investors must have KYC verification before accepting their capital commitments. The kyc_aml_status attribute indicates this is tracked.',
    `opportunity_id` BIGINT COMMENT 'Reference to the parent deal opportunity for which this co-investment allocation is offered or accepted.',
    `relationship_manager_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Co-investment relationship management requires tracking assigned employee for LP/co-investor communications and reporting. New FK replaces denormalized relationship_manager_name.',
    `actual_close_date` DATE COMMENT 'Actual date on which the co-investment transaction reached financial close and all funding was completed.',
    `allocated_amount` DECIMAL(18,2) COMMENT 'The monetary amount of co-investment capital allocated to or accepted by the co-investor for this opportunity.',
    `allocation_acceptance_date` DATE COMMENT 'Date on which the co-investor formally accepted the co-investment allocation offer.',
    `allocation_commitment_date` DATE COMMENT 'Date on which the co-investor legally committed capital to the co-investment, typically via signed commitment letter or Limited Partnership Agreement (LPA).',
    `allocation_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the allocated co-investment amount.. Valid values are `^[A-Z]{3}$`',
    `allocation_expiry_date` DATE COMMENT 'Date by which the co-investor must accept the allocation offer, after which the offer becomes void.',
    `allocation_funding_date` DATE COMMENT 'Date on which the co-investor transferred funds to fulfill their co-investment allocation.',
    `allocation_notes` STRING COMMENT 'Free-text field for additional context, special terms, conditions, or internal commentary related to this co-investment allocation.',
    `allocation_offer_date` DATE COMMENT 'Date on which the co-investment opportunity was formally offered to the co-investor.',
    `allocation_reference_number` STRING COMMENT 'Externally-known unique reference number for this co-investment allocation, used in communications with co-investors and internal tracking.',
    `allocation_status` STRING COMMENT 'Current operational status of the co-investment allocation in its workflow.. Valid values are `pending|active|completed|cancelled|expired`',
    `allocation_type` STRING COMMENT 'Classification of the allocation lifecycle stage: offered to co-investor, accepted by co-investor, declined, committed, funded, or withdrawn.. Valid values are `offered|accepted|declined|committed|funded|withdrawn`',
    `carried_interest_percent` DECIMAL(5,4) COMMENT 'Performance-based fee percentage (carry) charged on profits above the hurdle rate, expressed as a decimal fraction.',
    `co_investor_entity_name` STRING COMMENT 'Full legal name of the co-investing entity or institution participating in this allocation.',
    `co_investor_jurisdiction` STRING COMMENT 'Three-letter ISO country code representing the legal jurisdiction of the co-investor entity.. Valid values are `^[A-Z]{3}$`',
    `co_investor_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the co-investing party, enabling global counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `co_investor_type` STRING COMMENT 'Classification of the co-investor by institutional type, reflecting their investment mandate and regulatory framework.. Valid values are `pension_fund|sovereign_wealth_fund|insurance_company|endowment|family_office|asset_manager`',
    `confidentiality_level` STRING COMMENT 'Data classification level for this co-investment allocation record, governing access and disclosure controls.. Valid values are `public|internal|confidential|restricted`',
    `decline_reason` STRING COMMENT 'Explanation provided by the co-investor for declining the co-investment allocation offer, if applicable.',
    `expected_close_date` DATE COMMENT 'Anticipated date for the co-investment transaction to reach financial close and funding completion.',
    `fee_arrangement` STRING COMMENT 'Classification of the fee structure applied to this co-investment allocation, indicating whether management fees, carried interest, or both are charged.. Valid values are `no_fee|management_fee_only|carried_interest_only|full_fee_structure|custom`',
    `governance_rights` STRING COMMENT 'Summary of governance, voting, and information rights granted to the co-investor, such as board observer status, consent rights, or veto provisions.',
    `hurdle_rate_percent` DECIMAL(5,4) COMMENT 'Minimum annualized return threshold that must be achieved before carried interest is charged, expressed as a decimal percentage.',
    `ic_approval_date` DATE COMMENT 'Date on which the Investment Committee approved this co-investment allocation, if applicable.',
    `ic_approval_required_flag` BOOLEAN COMMENT 'Indicates whether Investment Committee approval was required for this co-investment allocation.',
    `kyc_aml_status` STRING COMMENT 'Current status of KYC and AML due diligence and compliance checks for the co-investor entity.. Valid values are `pending|in_progress|approved|rejected|expired`',
    `kyc_completion_date` DATE COMMENT 'Date on which KYC and AML due diligence was completed and approved for the co-investor.',
    `lead_investment_professional` STRING COMMENT 'Name of the lead investment professional from the pension fund responsible for originating and managing this co-investment opportunity.',
    `lpa_reference_number` STRING COMMENT 'Reference number for the Limited Partnership Agreement or co-investment agreement governing this allocation.',
    `management_fee_percent` DECIMAL(5,4) COMMENT 'Annual management fee rate charged on the co-investment allocation, expressed as a decimal percentage of committed or invested capital.',
    `ownership_percentage` DECIMAL(5,4) COMMENT 'Percentage of total deal equity or ownership that this co-investment allocation represents, expressed as a decimal fraction.',
    `record_created_by` STRING COMMENT 'Username or identifier of the user or system process that created this co-investment allocation record.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this co-investment allocation record was first created in the data platform.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this co-investment allocation record was last modified in the data platform.',
    `regulatory_approval_required_flag` BOOLEAN COMMENT 'Indicates whether regulatory or governmental approval is required for this co-investment allocation due to jurisdiction, sector, or size thresholds.',
    `regulatory_approval_status` STRING COMMENT 'Current status of any required regulatory approvals for the co-investment allocation.. Valid values are `not_required|pending|submitted|approved|rejected`',
    `side_letter_flag` BOOLEAN COMMENT 'Indicates whether a side letter agreement with special terms or rights was executed for this co-investor allocation.',
    `side_letter_reference` STRING COMMENT 'Reference number or document identifier for the side letter agreement, if applicable.',
    `source_system_code` STRING COMMENT 'Unique identifier for this co-investment allocation record in the source operational system, enabling traceability and reconciliation.',
    `subscription_agreement_reference` STRING COMMENT 'Reference number for the subscription agreement executed by the co-investor to formalize their capital commitment.',
    `withdrawal_reason` STRING COMMENT 'Explanation for withdrawal of the co-investment allocation by either party after initial acceptance or commitment.',
    CONSTRAINT pk_co_invest_allocation PRIMARY KEY(`co_invest_allocation_id`)
) COMMENT 'Master record for co-investment allocations offered to or accepted from co-investors alongside the pension funds direct investment. Captures the opportunity, co-investor entity name, co-investor LEI, allocated co-invest amount, co-invest currency';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`deal_fee` (
    `deal_fee_id` BIGINT COMMENT 'Unique identifier for the deal fee transaction record.',
    `approver_employee_id` BIGINT COMMENT 'Foreign key linking to shared.employee. Business justification: Fee approval workflow requires tracking approving employee for financial controls and audit. Pension funds require documented approval chains for all expenditures.',
    `co_invest_allocation_id` BIGINT COMMENT 'Reference to the parent deal or transaction if the opportunity has progressed to execution stage.',
    `deal_ic_submission_id` BIGINT COMMENT 'Reference to the Investment Committee submission or approval record associated with this deal and its fees.',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the parent deal or transaction if the opportunity has progressed to execution stage.',
    `opportunity_id` BIGINT COMMENT 'Reference to the investment opportunity or deal pipeline record to which this fee relates.',
    `rate_schedule_id` BIGINT COMMENT 'Foreign key linking to fee.rate_schedule. Business justification: Deal fee calculations require standardized rate structures per LPA terms. Investment professionals reference rate_schedule when negotiating/validating advisor fees, ensuring consistency',
    `amount` DECIMAL(18,2) COMMENT 'Monetary value of the fee in the specified currency representing the cost incurred or committed.',
    `amount_usd` DECIMAL(18,2) COMMENT 'Fee amount converted to USD using the applicable exchange rate for consolidated reporting and analysis.',
    `approval_date` DATE COMMENT 'Date on which the fee transaction received formal approval from the authorized approver.',
    `approval_status` STRING COMMENT 'Current approval status of the fee transaction within internal governance and authorization workflows.. Valid values are `pending|approved|rejected`',
    `asset_class` STRING COMMENT 'Investment asset class associated with the deal for which this fee was incurred such as private equity or real estate.',
    `basis` STRING COMMENT 'Methodology or structure used to calculate the fee amount such as fixed amount or percentage of transaction value.. Valid values are `fixed|percentage|hourly|retainer|success_based`',
    `calculation_base_amount` DECIMAL(18,2) COMMENT 'The underlying transaction value or asset amount upon which percentage-based fees are calculated.',
    `cost_center_code` STRING COMMENT 'Internal cost center or business unit code to which this fee is allocated for management accounting purposes.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the fee amount is denominated.. Valid values are `^[A-Z]{3}$`',
    `deal_stage` STRING COMMENT 'Pipeline stage or phase of the deal at which this fee was incurred such as due diligence or closing.',
    `engagement_letter_reference` STRING COMMENT 'Reference number or identifier of the engagement letter or service agreement governing this fee arrangement.',
    `fee_category` STRING COMMENT 'High-level grouping of the fee for financial reporting and cost allocation purposes.. Valid values are `transaction|professional_services|regulatory|administrative`',
    `fee_status` STRING COMMENT 'Current lifecycle status of the fee transaction indicating its progression from estimation through payment.. Valid values are `estimated|committed|invoiced|paid|cancelled|disputed`',
    `fee_type` STRING COMMENT 'Classification of the fee based on the service or purpose it represents during deal origination and execution.. Valid values are `advisory|arrangement|legal|due_diligence|break|success`',
    `fx_rate` DECIMAL(12,6) COMMENT 'Exchange rate applied to convert the fee amount from the original currency to USD for reporting purposes.',
    `fx_rate_date` DATE COMMENT 'Date on which the foreign exchange rate was determined or applied for currency conversion.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this fee expense is posted for financial accounting and reporting.',
    `invoice_date` DATE COMMENT 'Date on which the service provider issued the invoice for this fee.',
    `invoice_due_date` DATE COMMENT 'Date by which payment of the invoiced fee amount is contractually due to the service provider.',
    `invoice_number` STRING COMMENT 'Unique invoice reference number issued by the service provider for this fee transaction.',
    `is_capitalizable` BOOLEAN COMMENT 'Indicates whether this fee is eligible to be capitalized as part of the investment cost basis per accounting standards.',
    `is_reimbursable` BOOLEAN COMMENT 'Indicates whether this fee is eligible for reimbursement from a co-investor or counterparty per transaction agreements.',
    `notes` STRING COMMENT 'Free-text field for additional comments or contextual information regarding this fee transaction.',
    `payment_date` DATE COMMENT 'Actual date on which the fee payment was disbursed to the service provider.',
    `payment_method` STRING COMMENT 'Financial instrument or mechanism used to disburse the fee payment to the service provider.. Valid values are `wire_transfer|ach|check|eft`',
    `payment_reference_number` STRING COMMENT 'Unique reference number assigned to the payment transaction in the treasury or accounts payable system.',
    `percentage` DECIMAL(5,4) COMMENT 'Percentage rate applied to the transaction value or asset base when fee is calculated on a percentage basis.',
    `record_created_by` STRING COMMENT 'User identifier or system account that created this fee record in the data platform.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this fee record was first created in the data platform.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this fee record was last modified or updated in the data platform.',
    `reference_number` STRING COMMENT 'External or internal reference number assigned to this fee transaction for tracking and reconciliation purposes.',
    `reimbursement_amount` DECIMAL(18,2) COMMENT 'Portion of the fee amount that has been or will be reimbursed by a co-investor or counterparty.',
    `reimbursement_date` DATE COMMENT 'Date on which the reimbursement amount was received from the co-investor or counterparty.',
    `service_description` STRING COMMENT 'Detailed description of the professional service or advisory work performed for which this fee is charged.',
    `service_end_date` DATE COMMENT 'Date on which the service provider completed or concluded work related to this fee.',
    `service_provider_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the service provider enabling global counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `service_provider_name` STRING COMMENT 'Legal name of the external firm or advisor providing the service for which this fee is charged.',
    `service_provider_type` STRING COMMENT 'Classification of the service provider based on their professional specialty and role in the transaction.. Valid values are `investment_bank|law_firm|accounting_firm|consultant|broker`',
    `service_start_date` DATE COMMENT 'Date on which the service provider commenced work or services related to this fee.',
    `source_system_code` STRING COMMENT 'Unique identifier of this fee record in the originating source system for traceability and reconciliation.',
    CONSTRAINT pk_deal_fee PRIMARY KEY(`deal_fee_id`)
) COMMENT 'Transactional record for fees incurred during deal origination and execution—including advisory fees, break fees, arrangement fees, legal fees, and due diligence costs.';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`deal_contact` (
    `deal_contact_id` BIGINT COMMENT 'Unique identifier for the deal contact record. Primary key.',
    `opportunity_id` BIGINT COMMENT 'Reference to the deal opportunity this contact is associated with.',
    `confidentiality_level` STRING COMMENT 'Data classification level for information shared with this contact (public, internal, confidential, or restricted).. Valid values are `public|internal|confidential|restricted`',
    `conflict_of_interest_description` STRING COMMENT 'Description of any identified conflict of interest with this contact.',
    `conflict_of_interest_flag` BOOLEAN COMMENT 'Indicates whether a potential conflict of interest has been identified with this contact.',
    `contact_role` STRING COMMENT 'Specific role or title of the contact within their organization (e.g., Managing Director, Chief Executive Officer, Partner, General Counsel).',
    `contact_type` STRING COMMENT 'Classification of the contacts role in the deal (sell-side advisor, management team member, GP representative, legal counsel, intermediary, or broker).. Valid values are `sell_side_advisor|management_team|gp_representative|legal_counsel|intermediary|broker`',
    `data_room_access_date` DATE COMMENT 'Date when data room access was granted to this contact.',
    `data_room_access_granted_flag` BOOLEAN COMMENT 'Indicates whether this contact has been granted access to the deal data room.',
    `decision_maker_flag` BOOLEAN COMMENT 'Indicates whether this contact has decision-making authority for the deal.',
    `email_address` STRING COMMENT 'Primary email address for the contact.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `first_contact_date` DATE COMMENT 'Date when initial contact was established with this person for the deal opportunity.',
    `first_name` STRING COMMENT 'First name of the contact person.',
    `full_name` STRING COMMENT 'Full legal name of the contact person.',
    `kyc_completion_date` DATE COMMENT 'Date when KYC verification was completed for this contact.',
    `kyc_expiry_date` DATE COMMENT 'Date when the current KYC verification expires and requires renewal.',
    `kyc_status` STRING COMMENT 'Status of Know Your Customer verification for this contact (not started, in progress, completed, failed, or expired).. Valid values are `not_started|in_progress|completed|failed|expired`',
    `last_contact_date` DATE COMMENT 'Date of the most recent interaction with this contact.',
    `last_name` STRING COMMENT 'Last name of the contact person.',
    `linkedin_profile_url` STRING COMMENT 'URL to the contacts LinkedIn profile for professional background verification.',
    `mobile_number` STRING COMMENT 'Mobile phone number for the contact.',
    `nda_signatory_flag` BOOLEAN COMMENT 'Indicates whether this contact is an authorized signatory for NDA execution.',
    `notes` STRING COMMENT 'Free-text notes or comments about the contact, interactions, or relationship history.',
    `office_address_line1` STRING COMMENT 'First line of the contacts office address.',
    `office_address_line2` STRING COMMENT 'Second line of the contacts office address.',
    `office_city` STRING COMMENT 'City of the contacts office location.',
    `office_country_code` STRING COMMENT 'Three-letter ISO country code for the contacts office location.. Valid values are `^[A-Z]{3}$`',
    `office_postal_code` STRING COMMENT 'Postal code of the contacts office location.',
    `office_state_province` STRING COMMENT 'State or province of the contacts office location.',
    `organization_lei` STRING COMMENT 'Legal Entity Identifier for the contacts organization.. Valid values are `^[A-Z0-9]{20}$`',
    `organization_name` STRING COMMENT 'Name of the organization or firm the contact represents.',
    `organization_type` STRING COMMENT 'Type of organization the contact represents (investment bank, advisory firm, law firm, GP sponsor, intermediary, or broker-dealer).. Valid values are `investment_bank|advisory_firm|law_firm|gp_sponsor|intermediary|broker_dealer`',
    `phone_number` STRING COMMENT 'Primary phone number for the contact.',
    `preferred_communication_method` STRING COMMENT 'Preferred method of communication for this contact (email, phone, mobile, video conference, or in-person).. Valid values are `email|phone|mobile|video_conference|in_person`',
    `primary_contact_flag` BOOLEAN COMMENT 'Indicates whether this is the primary contact for the deal opportunity.',
    `professional_biography` STRING COMMENT 'Brief professional biography or background summary of the contact.',
    `record_created_by` STRING COMMENT 'User or system identifier that created this contact record.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this contact record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this contact record was last updated in the system.',
    `relationship_status` STRING COMMENT 'Current status of the relationship with this contact (active, inactive, suspended, or terminated).. Valid values are `active|inactive|suspended|terminated`',
    `source_system_code` STRING COMMENT 'Unique identifier for this contact in the source system.',
    `specialization_area` STRING COMMENT 'Area of specialization or expertise (e.g., private equity, real estate, infrastructure, mergers and acquisitions).',
    `years_of_experience` BIGINT COMMENT 'Number of years of professional experience in the relevant industry or role.',
    CONSTRAINT pk_deal_contact PRIMARY KEY(`deal_contact_id`)
) COMMENT 'Master record for external contacts associated with a deal opportunity—including sell-side advisors, management teams, GP representatives, legal counsel, and intermediaries.';

CREATE OR REPLACE TABLE `asset_management`.`deal`.`deal_check` (
    `deal_check_id` BIGINT COMMENT 'Primary key for the check association',
    `employee_id` BIGINT COMMENT 'Foreign key to the user or compliance officer who performed or approved the compliance check.',
    `opportunity_id` BIGINT COMMENT 'Foreign key linking to the investment opportunity being checked for compliance',
    `rule_id` BIGINT COMMENT 'Foreign key linking to the compliance rule being evaluated against the opportunity',
    `deal_check_date` DATE COMMENT 'Date when the compliance check was performed against the opportunity.',
    `deal_check_status` STRING COMMENT 'Outcome of the compliance check indicating whether the opportunity passed, failed, is pending review, received an exception, or the rule was not applicable.',
    `exception_flag` BOOLEAN COMMENT 'Indicates whether an exception to the compliance rule was granted for this opportunity.',
    CONSTRAINT pk_deal_check PRIMARY KEY(`deal_check_id`)
) COMMENT 'This association product represents the Compliance Check event between an investment opportunity and a compliance rule. It captures the operational record of each compliance verification performed during the deal pipeline process.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`deal`.`opportunity` ADD CONSTRAINT `fk_deal_opportunity_origination_source_id` FOREIGN KEY (`origination_source_id`) REFERENCES `asset_management`.`deal`.`origination_source`(`origination_source_id`);
ALTER TABLE `asset_management`.`deal`.`opportunity` ADD CONSTRAINT `fk_deal_opportunity_target_entity_id` FOREIGN KEY (`target_entity_id`) REFERENCES `asset_management`.`deal`.`target_entity`(`target_entity_id`);
ALTER TABLE `asset_management`.`deal`.`stage_transition` ADD CONSTRAINT `fk_deal_stage_transition_deal_ic_submission_id` FOREIGN KEY (`deal_ic_submission_id`) REFERENCES `asset_management`.`deal`.`deal_ic_submission`(`deal_ic_submission_id`);
ALTER TABLE `asset_management`.`deal`.`stage_transition` ADD CONSTRAINT `fk_deal_stage_transition_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`stage_transition` ADD CONSTRAINT `fk_deal_stage_transition_pipeline_stage_id` FOREIGN KEY (`pipeline_stage_id`) REFERENCES `asset_management`.`deal`.`pipeline_stage`(`pipeline_stage_id`);
ALTER TABLE `asset_management`.`deal`.`nda` ADD CONSTRAINT `fk_deal_nda_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`nda` ADD CONSTRAINT `fk_deal_nda_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`nda` ADD CONSTRAINT `fk_deal_nda_superseded_by_nda_id` FOREIGN KEY (`superseded_by_nda_id`) REFERENCES `asset_management`.`deal`.`nda`(`nda_id`);
ALTER TABLE `asset_management`.`deal`.`loi` ADD CONSTRAINT `fk_deal_loi_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`loi` ADD CONSTRAINT `fk_deal_loi_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`loi` ADD CONSTRAINT `fk_deal_loi_superseded_by_loi_id` FOREIGN KEY (`superseded_by_loi_id`) REFERENCES `asset_management`.`deal`.`loi`(`loi_id`);
ALTER TABLE `asset_management`.`deal`.`term_sheet` ADD CONSTRAINT `fk_deal_term_sheet_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`term_sheet` ADD CONSTRAINT `fk_deal_term_sheet_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`investment_memo` ADD CONSTRAINT `fk_deal_investment_memo_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`investment_memo` ADD CONSTRAINT `fk_deal_investment_memo_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ADD CONSTRAINT `fk_deal_deal_ic_submission_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ADD CONSTRAINT `fk_deal_deal_ic_condition_deal_ic_submission_id` FOREIGN KEY (`deal_ic_submission_id`) REFERENCES `asset_management`.`deal`.`deal_ic_submission`(`deal_ic_submission_id`);
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ADD CONSTRAINT `fk_deal_deal_ic_condition_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ADD CONSTRAINT `fk_deal_deal_ic_condition_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`team` ADD CONSTRAINT `fk_deal_team_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ADD CONSTRAINT `fk_deal_deal_valuation_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ADD CONSTRAINT `fk_deal_deal_valuation_superseded_by_valuation_deal_valuation_id` FOREIGN KEY (`superseded_by_valuation_deal_valuation_id`) REFERENCES `asset_management`.`deal`.`deal_valuation`(`deal_valuation_id`);
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ADD CONSTRAINT `fk_deal_deal_capital_commitment_deal_ic_submission_id` FOREIGN KEY (`deal_ic_submission_id`) REFERENCES `asset_management`.`deal`.`deal_ic_submission`(`deal_ic_submission_id`);
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ADD CONSTRAINT `fk_deal_deal_capital_commitment_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`ppm_review` ADD CONSTRAINT `fk_deal_ppm_review_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`screening_decision` ADD CONSTRAINT `fk_deal_screening_decision_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`deal_document` ADD CONSTRAINT `fk_deal_deal_document_deal_ic_submission_id` FOREIGN KEY (`deal_ic_submission_id`) REFERENCES `asset_management`.`deal`.`deal_ic_submission`(`deal_ic_submission_id`);
ALTER TABLE `asset_management`.`deal`.`deal_document` ADD CONSTRAINT `fk_deal_deal_document_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`deal_document` ADD CONSTRAINT `fk_deal_deal_document_superseded_by_document_deal_document_id` FOREIGN KEY (`superseded_by_document_deal_document_id`) REFERENCES `asset_management`.`deal`.`deal_document`(`deal_document_id`);
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ADD CONSTRAINT `fk_deal_exclusivity_agreement_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`milestone` ADD CONSTRAINT `fk_deal_milestone_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ADD CONSTRAINT `fk_deal_co_invest_allocation_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`deal_fee` ADD CONSTRAINT `fk_deal_deal_fee_co_invest_allocation_id` FOREIGN KEY (`co_invest_allocation_id`) REFERENCES `asset_management`.`deal`.`co_invest_allocation`(`co_invest_allocation_id`);
ALTER TABLE `asset_management`.`deal`.`deal_fee` ADD CONSTRAINT `fk_deal_deal_fee_deal_ic_submission_id` FOREIGN KEY (`deal_ic_submission_id`) REFERENCES `asset_management`.`deal`.`deal_ic_submission`(`deal_ic_submission_id`);
ALTER TABLE `asset_management`.`deal`.`deal_fee` ADD CONSTRAINT `fk_deal_deal_fee_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`deal_fee` ADD CONSTRAINT `fk_deal_deal_fee_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`deal_contact` ADD CONSTRAINT `fk_deal_deal_contact_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`deal`.`deal_check` ADD CONSTRAINT `fk_deal_deal_check_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`deal`.`opportunity` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`deal`.`opportunity` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`opportunity` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`opportunity` SET TAGS ('dbx_subdomain' = 'pipeline_origination');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `asset_class_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Outlook Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `climate_scenario_id` SET TAGS ('dbx_business_glossary_term' = 'Climate Scenario Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `country_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Country Outlook Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `data_provider_id` SET TAGS ('dbx_business_glossary_term' = 'Data Provider Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `esg_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Esg Benchmark Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `esg_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `framework_id` SET TAGS ('dbx_business_glossary_term' = 'Framework Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `origination_source_id` SET TAGS ('dbx_business_glossary_term' = 'Origination Source Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `sector_outlook_id` SET TAGS ('dbx_business_glossary_term' = 'Sector Outlook Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `target_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `actual_close_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Close Date');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `opportunity_code` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Code');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Level');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|highly_confidential');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `data_room_url` SET TAGS ('dbx_business_glossary_term' = 'Data Room Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `data_room_url` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `decline_reason` SET TAGS ('dbx_business_glossary_term' = 'Decline Reason');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `decline_reason` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `esg_exclusion_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Exclusion Flag');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `expected_close_date` SET TAGS ('dbx_business_glossary_term' = 'Expected Close Date');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `expected_hold_period_years` SET TAGS ('dbx_business_glossary_term' = 'Expected Hold Period (Years)');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `expected_investment_amount` SET TAGS ('dbx_business_glossary_term' = 'Expected Investment Amount');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `expected_investment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `gp_sponsor_name` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) or Sponsor Name');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `ic_decision` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `ic_decision` SET TAGS ('dbx_value_regex' = 'approved|declined|conditional|deferred');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `ic_decision_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision Date');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `ic_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Date');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `intermediary_name` SET TAGS ('dbx_business_glossary_term' = 'Intermediary Name');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `investment_currency` SET TAGS ('dbx_business_glossary_term' = 'Investment Currency');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `investment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `investment_thesis` SET TAGS ('dbx_business_glossary_term' = 'Investment Thesis');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `investment_thesis` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Active Record Indicator');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `lead_investment_professional` SET TAGS ('dbx_business_glossary_term' = 'Lead Investment Professional');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `loi_status` SET TAGS ('dbx_business_glossary_term' = 'Letter of Intent (LOI) Status');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `loi_status` SET TAGS ('dbx_value_regex' = 'not_submitted|draft|submitted|accepted|rejected');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `loi_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Letter of Intent (LOI) Submission Date');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `opportunity_name` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Name');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `nda_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Execution Date');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `nda_status` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Status');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `nda_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|executed|expired');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Notes');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `opportunity_status` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Status');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `opportunity_type` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Type');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `opportunity_type` SET TAGS ('dbx_value_regex' = 'direct|co_investment|fund_commitment|secondary|joint_venture|club_deal');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `origination_date` SET TAGS ('dbx_business_glossary_term' = 'Origination Date');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `priority_tier` SET TAGS ('dbx_business_glossary_term' = 'Priority Tier');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `priority_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3|tier_4');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|very_high');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `sourcing_channel` SET TAGS ('dbx_business_glossary_term' = 'Sourcing Channel');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `sourcing_channel` SET TAGS ('dbx_value_regex' = 'proprietary|gp_introduced|intermediated|inbound|network_referral');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `strategic_fit_score` SET TAGS ('dbx_business_glossary_term' = 'Strategic Fit Score');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `sub_asset_class` SET TAGS ('dbx_business_glossary_term' = 'Sub-Asset Class');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `target_irr_percent` SET TAGS ('dbx_business_glossary_term' = 'Target Internal Rate of Return (IRR) Percent');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `target_irr_percent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `target_moic` SET TAGS ('dbx_business_glossary_term' = 'Target Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `target_moic` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`opportunity` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` SET TAGS ('dbx_subdomain' = 'pipeline_origination');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `pipeline_stage_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Stage Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `alternate_exit_stages` SET TAGS ('dbx_business_glossary_term' = 'Alternate Exit Stages');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `applicable_asset_classes` SET TAGS ('dbx_business_glossary_term' = 'Applicable Asset Classes');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `applicable_deal_types` SET TAGS ('dbx_business_glossary_term' = 'Applicable Deal Types');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `compliance_checkpoints` SET TAGS ('dbx_business_glossary_term' = 'Compliance Checkpoints');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `effective_to_date` SET TAGS ('dbx_business_glossary_term' = 'Effective To Date');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `entry_criteria` SET TAGS ('dbx_business_glossary_term' = 'Entry Criteria');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `escalation_contact` SET TAGS ('dbx_business_glossary_term' = 'Escalation Contact');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `escalation_threshold_days` SET TAGS ('dbx_business_glossary_term' = 'Escalation Threshold Days');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `esg_review_required` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Review Required Indicator');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `exit_criteria` SET TAGS ('dbx_business_glossary_term' = 'Exit Criteria');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `governance_framework` SET TAGS ('dbx_business_glossary_term' = 'Governance Framework');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `ic_submission_required` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Required Indicator');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Active Status Indicator');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `is_approval_gate` SET TAGS ('dbx_business_glossary_term' = 'Approval Gate Indicator');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `is_terminal` SET TAGS ('dbx_business_glossary_term' = 'Terminal Stage Indicator');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `legal_review_required` SET TAGS ('dbx_business_glossary_term' = 'Legal Review Required Indicator');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `maximum_dwell_days` SET TAGS ('dbx_business_glossary_term' = 'Maximum Dwell Days');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `minimum_dwell_days` SET TAGS ('dbx_business_glossary_term' = 'Minimum Dwell Days');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `predecessor_stage_code` SET TAGS ('dbx_business_glossary_term' = 'Predecessor Stage Code');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `reporting_label` SET TAGS ('dbx_business_glossary_term' = 'Reporting Label');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `required_approvers` SET TAGS ('dbx_business_glossary_term' = 'Required Approvers');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `required_deliverables` SET TAGS ('dbx_business_glossary_term' = 'Required Deliverables Checklist');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `risk_assessment_required` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Required Indicator');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `stage_category` SET TAGS ('dbx_business_glossary_term' = 'Stage Category');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `stage_category` SET TAGS ('dbx_value_regex' = 'origination|screening|diligence|approval|execution|post_close');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `stage_code` SET TAGS ('dbx_business_glossary_term' = 'Stage Code');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `stage_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `stage_color_code` SET TAGS ('dbx_business_glossary_term' = 'Stage Color Code');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `stage_color_code` SET TAGS ('dbx_value_regex' = '^#[0-9A-Fa-f]{6}$');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `stage_description` SET TAGS ('dbx_business_glossary_term' = 'Stage Description');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `stage_icon` SET TAGS ('dbx_business_glossary_term' = 'Stage Icon');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `stage_name` SET TAGS ('dbx_business_glossary_term' = 'Stage Name');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `stage_notes` SET TAGS ('dbx_business_glossary_term' = 'Stage Notes');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `stage_owner_role` SET TAGS ('dbx_business_glossary_term' = 'Stage Owner Role');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `stage_sequence` SET TAGS ('dbx_business_glossary_term' = 'Stage Sequence Order');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `stage_type` SET TAGS ('dbx_business_glossary_term' = 'Stage Type');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `stage_type` SET TAGS ('dbx_value_regex' = 'mandatory|optional|conditional');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `successor_stage_code` SET TAGS ('dbx_business_glossary_term' = 'Successor Stage Code');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `target_dwell_days` SET TAGS ('dbx_business_glossary_term' = 'Target Dwell Days');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Record Updated By User');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `valuation_required` SET TAGS ('dbx_business_glossary_term' = 'Valuation Required Indicator');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`deal`.`pipeline_stage` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By User');
ALTER TABLE `asset_management`.`deal`.`stage_transition` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`deal`.`stage_transition` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`stage_transition` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`stage_transition` SET TAGS ('dbx_subdomain' = 'pipeline_origination');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `stage_transition_id` SET TAGS ('dbx_business_glossary_term' = 'Stage Transition Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `deal_ic_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approving User Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `pipeline_stage_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Stage Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `approving_committee` SET TAGS ('dbx_business_glossary_term' = 'Approving Committee');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `approving_user_name` SET TAGS ('dbx_business_glossary_term' = 'Approving User Name');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `approving_user_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `approving_user_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `conditions_imposed` SET TAGS ('dbx_business_glossary_term' = 'Conditions Imposed');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `cumulative_days_in_pipeline` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Days in Pipeline');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `days_in_prior_stage` SET TAGS ('dbx_business_glossary_term' = 'Days in Prior Stage');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `decision_outcome` SET TAGS ('dbx_business_glossary_term' = 'Decision Outcome');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `decision_outcome` SET TAGS ('dbx_value_regex' = 'pass|fail|conditional|deferred|withdrawn');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `decision_type` SET TAGS ('dbx_business_glossary_term' = 'Decision Type');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `decision_type` SET TAGS ('dbx_value_regex' = 'automatic|manual|ic_decision|screening|gate_review');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `gate_criteria_checklist` SET TAGS ('dbx_business_glossary_term' = 'Gate Criteria Checklist');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `gate_criteria_met` SET TAGS ('dbx_business_glossary_term' = 'Gate Criteria Met Flag');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `ic_approval_received` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Received Flag');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `ic_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Meeting Date');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Active Record Flag');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `is_milestone_transition` SET TAGS ('dbx_business_glossary_term' = 'Milestone Transition Flag');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `milestone_name` SET TAGS ('dbx_business_glossary_term' = 'Milestone Name');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `new_stage_code` SET TAGS ('dbx_business_glossary_term' = 'New Stage Code');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `new_stage_name` SET TAGS ('dbx_business_glossary_term' = 'New Stage Name');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `notification_sent` SET TAGS ('dbx_business_glossary_term' = 'Notification Sent Flag');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `notification_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Notification Timestamp');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `prior_stage_code` SET TAGS ('dbx_business_glossary_term' = 'Prior Stage Code');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `prior_stage_name` SET TAGS ('dbx_business_glossary_term' = 'Prior Stage Name');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `record_created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `record_updated_by` SET TAGS ('dbx_business_glossary_term' = 'Record Updated By');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `requires_ic_approval` SET TAGS ('dbx_business_glossary_term' = 'Requires Investment Committee (IC) Approval Flag');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `supporting_document_count` SET TAGS ('dbx_business_glossary_term' = 'Supporting Document Count');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `system_generated` SET TAGS ('dbx_business_glossary_term' = 'System Generated Flag');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `transition_date` SET TAGS ('dbx_business_glossary_term' = 'Transition Date');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `transition_notes` SET TAGS ('dbx_business_glossary_term' = 'Transition Notes');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `transition_number` SET TAGS ('dbx_business_glossary_term' = 'Transition Number');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `transition_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Transition Reason Code');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `transition_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Transition Reason Description');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `transition_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Transition Sequence Number');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `transition_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Transition Timestamp');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `transition_type` SET TAGS ('dbx_business_glossary_term' = 'Transition Type');
ALTER TABLE `asset_management`.`deal`.`stage_transition` ALTER COLUMN `transition_type` SET TAGS ('dbx_value_regex' = 'advance|retreat|reopen|reject|approve|hold');
ALTER TABLE `asset_management`.`deal`.`nda` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`deal`.`nda` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`nda` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`nda` SET TAGS ('dbx_subdomain' = 'documentation_negotiation');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `nda_id` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) ID');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity ID');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `counterparty_legal_entity_counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity ID');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Created By User ID');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `last_modified_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User ID');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `last_modified_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `last_modified_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal ID');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `superseded_by_nda_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Non-Disclosure Agreement (NDA) ID');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `breach_description` SET TAGS ('dbx_business_glossary_term' = 'Breach Description');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `breach_description` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `breach_reported_flag` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Breach Reported Flag');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `confidentiality_period_years` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Period (Years)');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `counterparty_signatory_name` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Signatory Name');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `counterparty_signatory_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `counterparty_signatory_title` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Signatory Title');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `data_room_access_granted_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Room Access Granted Flag');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `data_room_url` SET TAGS ('dbx_business_glossary_term' = 'Data Room Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `data_room_url` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `deal_origination_source` SET TAGS ('dbx_business_glossary_term' = 'Deal Origination Source');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `deal_origination_source` SET TAGS ('dbx_value_regex' = 'off_market|intermediated|co_investment|secondary|proprietary');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `disclosure_to_advisors_permitted_flag` SET TAGS ('dbx_business_glossary_term' = 'Disclosure to Advisors Permitted Flag');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Mechanism');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_value_regex' = 'litigation|arbitration|mediation');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `document_storage_location` SET TAGS ('dbx_business_glossary_term' = 'Document Storage Location');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `document_storage_location` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `estimated_deal_size_usd_millions` SET TAGS ('dbx_business_glossary_term' = 'Estimated Deal Size (USD Millions)');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `estimated_deal_size_usd_millions` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `execution_date` SET TAGS ('dbx_business_glossary_term' = 'Execution Date');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `external_counsel_firm` SET TAGS ('dbx_business_glossary_term' = 'External Counsel Firm');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `governing_law_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Governing Law Jurisdiction');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `intermediary_firm_name` SET TAGS ('dbx_business_glossary_term' = 'Intermediary Firm Name');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `internal_counsel_approval_flag` SET TAGS ('dbx_business_glossary_term' = 'Internal Counsel Approval Flag');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `internal_signatory_name` SET TAGS ('dbx_business_glossary_term' = 'Internal Signatory Name');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `internal_signatory_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `internal_signatory_title` SET TAGS ('dbx_business_glossary_term' = 'Internal Signatory Title');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `is_perpetual` SET TAGS ('dbx_business_glossary_term' = 'Is Perpetual');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `nda_status` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Status');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `nda_status` SET TAGS ('dbx_value_regex' = 'draft|pending_signature|executed|expired|terminated|superseded');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `nda_type` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Type');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `nda_type` SET TAGS ('dbx_value_regex' = 'mutual|one-way|multilateral');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `non_solicitation_flag` SET TAGS ('dbx_business_glossary_term' = 'Non-Solicitation Flag');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `permitted_use_scope` SET TAGS ('dbx_business_glossary_term' = 'Permitted Use Scope');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Reference Number');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `regulatory_disclosure_carveout_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Disclosure Carveout Flag');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `remediation_action_taken` SET TAGS ('dbx_business_glossary_term' = 'Remediation Action Taken');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `remediation_action_taken` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `return_or_destroy_obligation_flag` SET TAGS ('dbx_business_glossary_term' = 'Return or Destroy Obligation Flag');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `standstill_period_months` SET TAGS ('dbx_business_glossary_term' = 'Standstill Period (Months)');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `standstill_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Standstill Provision Flag');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `target_company_name` SET TAGS ('dbx_business_glossary_term' = 'Target Company Name');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `target_company_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `target_geography` SET TAGS ('dbx_business_glossary_term' = 'Target Geography');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `template_version` SET TAGS ('dbx_business_glossary_term' = 'Template Version');
ALTER TABLE `asset_management`.`deal`.`nda` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `asset_management`.`deal`.`loi` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`deal`.`loi` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`loi` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`loi` SET TAGS ('dbx_subdomain' = 'documentation_negotiation');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `loi_id` SET TAGS ('dbx_business_glossary_term' = 'Letter of Intent (LOI) Identifier');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `superseded_by_loi_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Letter of Intent (LOI) Identifier');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `acceptance_date` SET TAGS ('dbx_business_glossary_term' = 'Acceptance Date');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `advisor_firm_name` SET TAGS ('dbx_business_glossary_term' = 'Advisor Firm Name');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `break_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Break Fee Amount');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `conditions_precedent` SET TAGS ('dbx_business_glossary_term' = 'Conditions Precedent');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `confidentiality_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Clause Flag');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `deposit_amount` SET TAGS ('dbx_business_glossary_term' = 'Deposit Amount');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `deposit_due_date` SET TAGS ('dbx_business_glossary_term' = 'Deposit Due Date');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `due_diligence_period_days` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Period Days');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `exclusivity_end_date` SET TAGS ('dbx_business_glossary_term' = 'Exclusivity End Date');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `exclusivity_flag` SET TAGS ('dbx_business_glossary_term' = 'Exclusivity Flag');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `exclusivity_start_date` SET TAGS ('dbx_business_glossary_term' = 'Exclusivity Start Date');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `financing_contingency_flag` SET TAGS ('dbx_business_glossary_term' = 'Financing Contingency Flag');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `geographic_region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `governing_law` SET TAGS ('dbx_business_glossary_term' = 'Governing Law');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `ic_approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Required Flag');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `ic_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Date');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `indicative_enterprise_value` SET TAGS ('dbx_business_glossary_term' = 'Indicative Enterprise Value');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `indicative_equity_value` SET TAGS ('dbx_business_glossary_term' = 'Indicative Equity Value');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `issuance_date` SET TAGS ('dbx_business_glossary_term' = 'Issuance Date');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `lead_investment_professional` SET TAGS ('dbx_business_glossary_term' = 'Lead Investment Professional');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `loi_status` SET TAGS ('dbx_business_glossary_term' = 'Letter of Intent (LOI) Status');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `loi_type` SET TAGS ('dbx_business_glossary_term' = 'Letter of Intent (LOI) Type');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `loi_type` SET TAGS ('dbx_value_regex' = 'binding|non-binding|conditional');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `nda_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Reference Number');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Letter of Intent (LOI) Number');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^LOI-[0-9]{6,10}$');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `proposed_deal_structure` SET TAGS ('dbx_business_glossary_term' = 'Proposed Deal Structure');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `proposed_deal_structure` SET TAGS ('dbx_value_regex' = 'asset_purchase|share_purchase|merger|joint_venture|co_investment|secondary_transaction');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `proposed_ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Proposed Ownership Percentage');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `regulatory_approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Required Flag');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `rejection_date` SET TAGS ('dbx_business_glossary_term' = 'Rejection Date');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Sector');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `target_lei` SET TAGS ('dbx_business_glossary_term' = 'Target Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `target_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `term_sheet_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Term Sheet Reference Number');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`deal`.`loi` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'Withdrawal Date');
ALTER TABLE `asset_management`.`deal`.`term_sheet` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`deal`.`term_sheet` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`term_sheet` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`term_sheet` SET TAGS ('dbx_subdomain' = 'documentation_negotiation');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `term_sheet_id` SET TAGS ('dbx_business_glossary_term' = 'Term Sheet Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `advisor_firm_name` SET TAGS ('dbx_business_glossary_term' = 'Advisor Firm Name');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `advisor_firm_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `binding_status` SET TAGS ('dbx_business_glossary_term' = 'Binding Status');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `carried_interest_percent` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Percent');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `carried_interest_percent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `closing_conditions` SET TAGS ('dbx_business_glossary_term' = 'Closing Conditions');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `closing_conditions` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Created By User');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `deal_structure_type` SET TAGS ('dbx_business_glossary_term' = 'Deal Structure Type');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `deal_structure_type` SET TAGS ('dbx_value_regex' = 'equity|debt|hybrid|co_investment|direct_investment|fund_commitment');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `document_storage_path` SET TAGS ('dbx_business_glossary_term' = 'Document Storage Path');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `document_storage_path` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `due_diligence_period_days` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Period Days');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `ebitda_multiple` SET TAGS ('dbx_business_glossary_term' = 'Earnings Before Interest Taxes Depreciation and Amortization (EBITDA) Multiple');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `ebitda_multiple` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `enterprise_value` SET TAGS ('dbx_business_glossary_term' = 'Enterprise Value');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `enterprise_value` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `equity_value` SET TAGS ('dbx_business_glossary_term' = 'Equity Value');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `equity_value` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `esg_considerations` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Considerations');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `exclusivity_period_days` SET TAGS ('dbx_business_glossary_term' = 'Exclusivity Period Days');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `exclusivity_period_days` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `governance_rights` SET TAGS ('dbx_business_glossary_term' = 'Governance Rights');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `governance_rights` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percent');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `ic_submission_planned_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Planned Date');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `investment_horizon_years` SET TAGS ('dbx_business_glossary_term' = 'Investment Horizon Years');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `investment_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Type');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `investment_type` SET TAGS ('dbx_value_regex' = 'primary|secondary|co_invest|direct|fund_of_funds');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `issuance_date` SET TAGS ('dbx_business_glossary_term' = 'Issuance Date');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `key_terms_summary` SET TAGS ('dbx_business_glossary_term' = 'Key Terms Summary');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `key_terms_summary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `lead_investment_professional` SET TAGS ('dbx_business_glossary_term' = 'Lead Investment Professional');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `loi_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Letter of Intent (LOI) Reference Number');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `loi_reference_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `management_fee_percent` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Percent');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `management_fee_percent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `modified_by_user` SET TAGS ('dbx_business_glossary_term' = 'Modified By User');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `nda_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Reference Number');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `nda_reference_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Term Sheet Number');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `proposed_investment_amount` SET TAGS ('dbx_business_glossary_term' = 'Proposed Investment Amount');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `proposed_investment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `regulatory_approvals_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approvals Required');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `source_channel` SET TAGS ('dbx_business_glossary_term' = 'Source Channel');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `source_channel` SET TAGS ('dbx_value_regex' = 'off_market|intermediated|proprietary|co_invest_partner|fund_manager');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `target_irr_percent` SET TAGS ('dbx_business_glossary_term' = 'Target Internal Rate of Return (IRR) Percent');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `target_irr_percent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `target_moic` SET TAGS ('dbx_business_glossary_term' = 'Target Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `target_moic` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `term_sheet_status` SET TAGS ('dbx_business_glossary_term' = 'Term Sheet Status');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `term_sheet_status` SET TAGS ('dbx_value_regex' = 'draft|issued|under_negotiation|accepted|rejected|superseded');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `valuation_basis` SET TAGS ('dbx_business_glossary_term' = 'Valuation Basis');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `valuation_basis` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`term_sheet` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`deal`.`investment_memo` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`deal`.`investment_memo` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`investment_memo` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`investment_memo` SET TAGS ('dbx_subdomain' = 'approval_commitment');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `investment_memo_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Memorandum (IM) Identifier');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Author Identifier');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `lead_author_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Author Identifier');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Commitment Currency Code');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `competitive_landscape` SET TAGS ('dbx_business_glossary_term' = 'Competitive Landscape Analysis');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `competitive_landscape` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `deal_structure` SET TAGS ('dbx_business_glossary_term' = 'Recommended Deal Structure');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `deal_structure` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `deal_type` SET TAGS ('dbx_business_glossary_term' = 'Deal Type');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `deal_type` SET TAGS ('dbx_value_regex' = 'direct_investment|co_investment|fund_commitment|secondary|joint_venture');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `decision_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision Date');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `document_location` SET TAGS ('dbx_business_glossary_term' = 'Document Storage Location');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `esg_rating` SET TAGS ('dbx_value_regex' = 'A|B|C|D|not_rated');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `esg_summary` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Summary');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `exit_strategy` SET TAGS ('dbx_business_glossary_term' = 'Exit Strategy');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `exit_strategy` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `expected_close_date` SET TAGS ('dbx_business_glossary_term' = 'Expected Transaction Close Date');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `ic_conditions` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Conditions');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `ic_decision` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `ic_decision` SET TAGS ('dbx_value_regex' = 'approved|approved_with_conditions|rejected|deferred');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `ic_decision_notes` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision Notes');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `ic_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Meeting Date');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `ic_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Recommendation');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `ic_recommendation` SET TAGS ('dbx_value_regex' = 'approve|approve_with_conditions|reject|defer');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `investment_horizon_years` SET TAGS ('dbx_business_glossary_term' = 'Investment Horizon in Years');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `investment_thesis` SET TAGS ('dbx_business_glossary_term' = 'Investment Thesis');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `investment_thesis` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Active Record Indicator');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `key_risks` SET TAGS ('dbx_business_glossary_term' = 'Key Investment Risks');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `key_risks` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `management_assessment` SET TAGS ('dbx_business_glossary_term' = 'Management Team Assessment');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `management_assessment` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `memo_number` SET TAGS ('dbx_business_glossary_term' = 'Investment Memorandum (IM) Number');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `memo_number` SET TAGS ('dbx_value_regex' = '^IM-[0-9]{4}-[0-9]{4}$');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `memo_status` SET TAGS ('dbx_business_glossary_term' = 'Memorandum Status');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `memo_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|ic_submitted|ic_approved|ic_rejected|withdrawn');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `mitigation_strategies` SET TAGS ('dbx_business_glossary_term' = 'Risk Mitigation Strategies');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `mitigation_strategies` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `preparation_date` SET TAGS ('dbx_business_glossary_term' = 'Memorandum Preparation Date');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `proposed_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Proposed Commitment Amount');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `proposed_commitment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `sub_asset_class` SET TAGS ('dbx_business_glossary_term' = 'Sub-Asset Class');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Date');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `target_country` SET TAGS ('dbx_business_glossary_term' = 'Target Country Code');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `target_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `target_description` SET TAGS ('dbx_business_glossary_term' = 'Target Description');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `target_description` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `target_irr_percent` SET TAGS ('dbx_business_glossary_term' = 'Target Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `target_irr_percent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `target_moic` SET TAGS ('dbx_business_glossary_term' = 'Target Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `target_moic` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `target_name` SET TAGS ('dbx_business_glossary_term' = 'Target Company or Asset Name');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `target_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `target_region` SET TAGS ('dbx_business_glossary_term' = 'Target Geographic Region');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `target_sector` SET TAGS ('dbx_business_glossary_term' = 'Target Industry Sector');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `valuation_amount` SET TAGS ('dbx_business_glossary_term' = 'Target Valuation Amount');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `valuation_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `valuation_currency` SET TAGS ('dbx_business_glossary_term' = 'Valuation Currency Code');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `valuation_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Valuation Methodology');
ALTER TABLE `asset_management`.`deal`.`investment_memo` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Memorandum Version Number');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` SET TAGS ('dbx_subdomain' = 'approval_commitment');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `deal_ic_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Investment Committee (IC) Submission Identifier');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'External Advisor Identifier');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `deal_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Investment Professional Identifier');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `deal_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `deal_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `deal_external_advisor_employee_id` SET TAGS ('dbx_business_glossary_term' = 'External Advisor Identifier');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `deal_external_advisor_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `deal_external_advisor_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Opportunity Identifier');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Created By User Identifier');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `fee_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Fee Benchmark Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `gp_manager_gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Manager Identifier');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Manager Identifier');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `ic_governance_record_id` SET TAGS ('dbx_business_glossary_term' = 'Ic Governance Record Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `last_modified_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User Identifier');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `last_modified_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `last_modified_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `ldi_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Ldi Strategy Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `lead_investment_professional_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Investment Professional Identifier');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `liability_projection_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Projection Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `approval_conditions` SET TAGS ('dbx_business_glossary_term' = 'Approval Conditions');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `approved_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Approved Commitment Amount');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Level');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `dd_completion_status` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Completion Status');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `dd_completion_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|substantially_complete|complete');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `decision_date` SET TAGS ('dbx_business_glossary_term' = 'Decision Date');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `deferral_reason` SET TAGS ('dbx_business_glossary_term' = 'Deferral Reason');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `esg_rating` SET TAGS ('dbx_value_regex' = 'A|B|C|D|not_rated');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `expected_irr_percent` SET TAGS ('dbx_business_glossary_term' = 'Expected Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `expected_moic` SET TAGS ('dbx_business_glossary_term' = 'Expected Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `ic_decision` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `ic_decision` SET TAGS ('dbx_value_regex' = 'approved|rejected|conditional_approval|deferred|withdrawn');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `ic_feedback` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Feedback');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `ic_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Type');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `ic_type` SET TAGS ('dbx_value_regex' = 'preliminary|full|special|emergency|written_consent');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `investment_horizon_years` SET TAGS ('dbx_business_glossary_term' = 'Investment Horizon Years');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `investment_memo_version` SET TAGS ('dbx_business_glossary_term' = 'Investment Memorandum (IM) Version');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `investment_structure` SET TAGS ('dbx_business_glossary_term' = 'Investment Structure');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `investment_structure` SET TAGS ('dbx_value_regex' = 'direct|co_investment|fund_commitment|secondary|separate_account');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `presentation_document_uri` SET TAGS ('dbx_business_glossary_term' = 'Presentation Document Uniform Resource Identifier (URI)');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `rejection_rationale` SET TAGS ('dbx_business_glossary_term' = 'Rejection Rationale');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `requested_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Requested Commitment Amount');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `requested_commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Requested Commitment Currency');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `requested_commitment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|very_high');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `scheduled_ic_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Investment Committee (IC) Meeting Date');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `sponsoring_department` SET TAGS ('dbx_business_glossary_term' = 'Sponsoring Department');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `strategic_alignment_score` SET TAGS ('dbx_business_glossary_term' = 'Strategic Alignment Score');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Date');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `submission_notes` SET TAGS ('dbx_business_glossary_term' = 'Submission Notes');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `submission_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Submission Reference Number');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `submission_status` SET TAGS ('dbx_business_glossary_term' = 'Submission Status');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `supporting_materials_uri` SET TAGS ('dbx_business_glossary_term' = 'Supporting Materials Uniform Resource Identifier (URI)');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `target_geography` SET TAGS ('dbx_business_glossary_term' = 'Target Geography');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `target_sector` SET TAGS ('dbx_business_glossary_term' = 'Target Sector');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `votes_abstained` SET TAGS ('dbx_business_glossary_term' = 'Votes Abstained');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `votes_against` SET TAGS ('dbx_business_glossary_term' = 'Votes Against');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `votes_in_favor` SET TAGS ('dbx_business_glossary_term' = 'Votes in Favor');
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ALTER COLUMN `voting_quorum_met` SET TAGS ('dbx_business_glossary_term' = 'Voting Quorum Met');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` SET TAGS ('dbx_subdomain' = 'approval_commitment');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `deal_ic_condition_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Investment Committee (IC) Condition Identifier');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `deal_ic_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Identifier');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `breach_date` SET TAGS ('dbx_business_glossary_term' = 'Condition Breach Date');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `breach_description` SET TAGS ('dbx_business_glossary_term' = 'Breach Description');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `condition_category` SET TAGS ('dbx_business_glossary_term' = 'Condition Category');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `condition_description` SET TAGS ('dbx_business_glossary_term' = 'Condition Description');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `condition_notes` SET TAGS ('dbx_business_glossary_term' = 'Condition Notes');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `condition_number` SET TAGS ('dbx_business_glossary_term' = 'Condition Reference Number');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `condition_owner` SET TAGS ('dbx_business_glossary_term' = 'Condition Owner');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `condition_rationale` SET TAGS ('dbx_business_glossary_term' = 'Condition Rationale');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `condition_status` SET TAGS ('dbx_business_glossary_term' = 'Condition Status');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `condition_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|satisfied|waived|breached|expired');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `condition_type` SET TAGS ('dbx_business_glossary_term' = 'Condition Type Classification');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `condition_type` SET TAGS ('dbx_value_regex' = 'pre_close|post_close|ongoing_covenant|precedent|subsequent|waiver_eligible');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Condition Due Date');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `escalation_date` SET TAGS ('dbx_business_glossary_term' = 'Escalation Date');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `escalation_required` SET TAGS ('dbx_business_glossary_term' = 'Escalation Required Flag');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `evidence_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Evidence Document Reference');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `ic_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Meeting Date');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `ic_resolution_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Resolution Reference');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Active Record Indicator');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified By');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Frequency');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `monitoring_frequency` SET TAGS ('dbx_value_regex' = 'one_time|monthly|quarterly|semi_annual|annual|event_driven');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Condition Priority Level');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `remediation_plan` SET TAGS ('dbx_business_glossary_term' = 'Remediation Plan');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `responsible_party` SET TAGS ('dbx_business_glossary_term' = 'Responsible Party Type');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `responsible_party` SET TAGS ('dbx_value_regex' = 'internal|external_manager|counterparty|advisor|legal_counsel');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `satisfaction_date` SET TAGS ('dbx_business_glossary_term' = 'Condition Satisfaction Date');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Verification Date');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `verification_method` SET TAGS ('dbx_business_glossary_term' = 'Verification Method');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `verification_method` SET TAGS ('dbx_value_regex' = 'document_review|third_party_confirmation|site_visit|legal_opinion|financial_audit|management_certification');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `verified_by` SET TAGS ('dbx_business_glossary_term' = 'Verified By');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `waiver_authority` SET TAGS ('dbx_business_glossary_term' = 'Waiver Authority');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `waiver_date` SET TAGS ('dbx_business_glossary_term' = 'Condition Waiver Date');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `waiver_rationale` SET TAGS ('dbx_business_glossary_term' = 'Waiver Rationale');
ALTER TABLE `asset_management`.`deal`.`deal_ic_condition` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By');
ALTER TABLE `asset_management`.`deal`.`team` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`deal`.`team` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`team` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`team` SET TAGS ('dbx_subdomain' = 'pipeline_origination');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `team_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Team Identifier');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Created By User Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `last_modified_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `last_modified_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `last_modified_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Opportunity Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `team_approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `team_approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `team_approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `team_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Employee Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `team_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `team_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `actual_hours` SET TAGS ('dbx_business_glossary_term' = 'Actual Hours');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `advisor_engagement_type` SET TAGS ('dbx_business_glossary_term' = 'Advisor Engagement Type');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `advisor_engagement_type` SET TAGS ('dbx_value_regex' = 'financial|legal|technical|esg|operational|tax');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `advisor_firm_name` SET TAGS ('dbx_business_glossary_term' = 'External Advisor Firm Name');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `allocation_percentage` SET TAGS ('dbx_business_glossary_term' = 'Time Allocation Percentage');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Assignment Approval Status');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `assignment_end_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment End Date');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `assignment_notes` SET TAGS ('dbx_business_glossary_term' = 'Assignment Notes');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `assignment_start_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Start Date');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Assignment Status');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'active|completed|suspended|withdrawn');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `conflict_check_date` SET TAGS ('dbx_business_glossary_term' = 'Conflict Check Date');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `conflict_check_status` SET TAGS ('dbx_business_glossary_term' = 'Conflict Check Status');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `conflict_check_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|cleared|flagged');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `data_room_access_date` SET TAGS ('dbx_business_glossary_term' = 'Data Room Access Date');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `data_room_access_granted` SET TAGS ('dbx_business_glossary_term' = 'Data Room Access Granted Flag');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `estimated_hours` SET TAGS ('dbx_business_glossary_term' = 'Estimated Hours');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `is_ic_presenter` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Presenter Flag');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `is_primary_contact` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Flag');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Modified Timestamp');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `nda_signed_date` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Signed Date');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `nda_signed_flag` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Signed Flag');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `role_code` SET TAGS ('dbx_business_glossary_term' = 'Deal Team Role Code');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `role_code` SET TAGS ('dbx_value_regex' = 'LEAD|ASSOCIATE|ANALYST|LEGAL|ESG|EXTERNAL');
ALTER TABLE `asset_management`.`deal`.`team` ALTER COLUMN `role_description` SET TAGS ('dbx_business_glossary_term' = 'Deal Team Role Description');
ALTER TABLE `asset_management`.`deal`.`origination_source` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`deal`.`origination_source` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`origination_source` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`origination_source` SET TAGS ('dbx_subdomain' = 'pipeline_origination');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `origination_source_id` SET TAGS ('dbx_business_glossary_term' = 'Origination Source Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `kyc_record_id` SET TAGS ('dbx_business_glossary_term' = 'Kyc Record Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `asset_class_focus` SET TAGS ('dbx_business_glossary_term' = 'Asset Class Focus');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `exclusivity_scope` SET TAGS ('dbx_business_glossary_term' = 'Exclusivity Scope');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `fee_arrangement_type` SET TAGS ('dbx_business_glossary_term' = 'Fee Arrangement Type');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `fee_arrangement_type` SET TAGS ('dbx_value_regex' = 'no_fee|success_fee|retainer|advisory_fee');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `first_deal_date` SET TAGS ('dbx_business_glossary_term' = 'First Deal Date');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Focus');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `is_exclusive` SET TAGS ('dbx_business_glossary_term' = 'Is Exclusive Relationship');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `kyc_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Completion Date');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `kyc_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Expiry Date');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `kyc_status` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Status');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `kyc_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed|expired|failed');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `last_deal_date` SET TAGS ('dbx_business_glossary_term' = 'Last Deal Date');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `nda_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Execution Date');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `nda_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Expiry Date');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `nda_status` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Status');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `nda_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|executed|expired');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `organization_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Organization Address Line 1');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `organization_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `organization_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `organization_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Organization Address Line 2');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `organization_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `organization_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `organization_city` SET TAGS ('dbx_business_glossary_term' = 'Organization City');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `organization_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `organization_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `organization_country_code` SET TAGS ('dbx_business_glossary_term' = 'Organization Country Code');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `organization_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `organization_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Organization Postal Code');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `organization_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `organization_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `organization_state_province` SET TAGS ('dbx_business_glossary_term' = 'Organization State or Province');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `organization_state_province` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `organization_state_province` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `party_type` SET TAGS ('dbx_business_glossary_term' = 'Party Type');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `party_type` SET TAGS ('dbx_value_regex' = 'individual|organization|intermediary|advisor|referral_partner');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `preferred_communication_method` SET TAGS ('dbx_business_glossary_term' = 'Preferred Communication Method');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `preferred_communication_method` SET TAGS ('dbx_value_regex' = 'email|phone|video_conference|in_person');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Email Address');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Name');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Phone Number');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `record_created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `relationship_manager_name` SET TAGS ('dbx_business_glossary_term' = 'Relationship Manager Name');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `relationship_status` SET TAGS ('dbx_business_glossary_term' = 'Relationship Status');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `relationship_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|under_review|blacklisted');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `relationship_tier` SET TAGS ('dbx_business_glossary_term' = 'Relationship Tier');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `relationship_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3|opportunistic');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `secondary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Secondary Contact Email Address');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `secondary_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `secondary_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `secondary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `secondary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Secondary Contact Name');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `secondary_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `secondary_contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `secondary_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Secondary Contact Phone Number');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `secondary_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `secondary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `source_name` SET TAGS ('dbx_business_glossary_term' = 'Source Name');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `source_type` SET TAGS ('dbx_business_glossary_term' = 'Source Type');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `source_type` SET TAGS ('dbx_value_regex' = 'proprietary|gp_introduced|investment_bank|broker|co_investor_referral|management_team');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `success_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Success Rate Percentage');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `total_deals_closed` SET TAGS ('dbx_business_glossary_term' = 'Total Deals Closed');
ALTER TABLE `asset_management`.`deal`.`origination_source` ALTER COLUMN `total_deals_sourced` SET TAGS ('dbx_business_glossary_term' = 'Total Deals Sourced');
ALTER TABLE `asset_management`.`deal`.`target_entity` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`deal`.`target_entity` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`target_entity` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`target_entity` SET TAGS ('dbx_subdomain' = 'pipeline_origination');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `target_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `coverage_universe_id` SET TAGS ('dbx_business_glossary_term' = 'Coverage Universe Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `kyc_record_id` SET TAGS ('dbx_business_glossary_term' = 'Kyc Record Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `lei_record_id` SET TAGS ('dbx_business_glossary_term' = 'Lei Record Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `sanctions_screening_id` SET TAGS ('dbx_business_glossary_term' = 'Sanctions Screening Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `annual_revenue_amount` SET TAGS ('dbx_business_glossary_term' = 'Annual Revenue Amount');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `annual_revenue_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `annual_revenue_currency` SET TAGS ('dbx_business_glossary_term' = 'Annual Revenue Currency');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `annual_revenue_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `credit_rating_agency` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating Agency');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP) Number');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{9}$');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `ebitda_amount` SET TAGS ('dbx_business_glossary_term' = 'Earnings Before Interest Taxes Depreciation and Amortization (EBITDA) Amount');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `ebitda_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `ebitda_currency` SET TAGS ('dbx_business_glossary_term' = 'Earnings Before Interest Taxes Depreciation and Amortization (EBITDA) Currency');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `ebitda_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `employee_count` SET TAGS ('dbx_business_glossary_term' = 'Employee Count');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `enterprise_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Enterprise Value Amount');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `enterprise_value_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `enterprise_value_currency` SET TAGS ('dbx_business_glossary_term' = 'Enterprise Value Currency');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `enterprise_value_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `esg_assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Assessment Date');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `esg_rating_provider` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating Provider');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `esg_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Score');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_business_glossary_term' = 'Headquarters Address');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `headquarters_city` SET TAGS ('dbx_business_glossary_term' = 'Headquarters City');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `headquarters_country` SET TAGS ('dbx_business_glossary_term' = 'Headquarters Country');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `headquarters_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `incorporation_date` SET TAGS ('dbx_business_glossary_term' = 'Incorporation Date');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `industry_sector` SET TAGS ('dbx_business_glossary_term' = 'Industry Sector');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `industry_subsector` SET TAGS ('dbx_business_glossary_term' = 'Industry Subsector');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `is_publicly_listed` SET TAGS ('dbx_business_glossary_term' = 'Is Publicly Listed Flag');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `jurisdiction_of_incorporation` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction of Incorporation');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `jurisdiction_of_incorporation` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `origination_date` SET TAGS ('dbx_business_glossary_term' = 'Origination Date');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `ownership_structure` SET TAGS ('dbx_business_glossary_term' = 'Ownership Structure');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `ownership_structure` SET TAGS ('dbx_value_regex' = 'publicly_traded|privately_held|family_owned|government_owned|partnership|joint_venture');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `parent_company_lei` SET TAGS ('dbx_business_glossary_term' = 'Parent Company Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `parent_company_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `parent_company_name` SET TAGS ('dbx_business_glossary_term' = 'Parent Company Name');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `primary_business_description` SET TAGS ('dbx_business_glossary_term' = 'Primary Business Description');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Email Address');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Name');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Phone Number');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `primary_contact_title` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Title');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `registration_number` SET TAGS ('dbx_business_glossary_term' = 'Registration Number');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL) Code');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{7}$');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `source_channel` SET TAGS ('dbx_business_glossary_term' = 'Source Channel');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `source_channel` SET TAGS ('dbx_value_regex' = 'off_market|intermediated|proprietary|referral|co_investment');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `stock_exchange_code` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Code');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `sub_asset_class` SET TAGS ('dbx_business_glossary_term' = 'Sub-Asset Class');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `target_legal_name` SET TAGS ('dbx_business_glossary_term' = 'Target Legal Name');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `target_short_name` SET TAGS ('dbx_business_glossary_term' = 'Target Short Name');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `target_status` SET TAGS ('dbx_business_glossary_term' = 'Target Status');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `target_status` SET TAGS ('dbx_value_regex' = 'active|inactive|under_review|archived|merged|acquired');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `target_type` SET TAGS ('dbx_business_glossary_term' = 'Target Type');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `target_type` SET TAGS ('dbx_value_regex' = 'operating_company|real_estate_asset|infrastructure_asset|natural_resource_asset|fund|co_investment_vehicle');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number (TIN)');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `ticker_symbol` SET TAGS ('dbx_business_glossary_term' = 'Ticker Symbol');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`deal`.`target_entity` ALTER COLUMN `website_url` SET TAGS ('dbx_business_glossary_term' = 'Website Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` SET TAGS ('dbx_subdomain' = 'approval_commitment');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `deal_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Valuation Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `capital_market_assumption_id` SET TAGS ('dbx_business_glossary_term' = 'Capital Market Assumption Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `deal_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `deal_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `deal_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `discount_rate_curve_id` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate Curve Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Analyst Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `macro_model_run_id` SET TAGS ('dbx_business_glossary_term' = 'Macro Model Run Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewer Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `reviewer_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewer Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `superseded_by_valuation_deal_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Valuation Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `analyst_name` SET TAGS ('dbx_business_glossary_term' = 'Valuation Analyst Name');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `comparable_count` SET TAGS ('dbx_business_glossary_term' = 'Comparable Count');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `confidence_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `currency` SET TAGS ('dbx_business_glossary_term' = 'Valuation Currency');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `data_quality_score` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Score');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `discount_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate Percentage');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `ebitda_multiple` SET TAGS ('dbx_business_glossary_term' = 'Earnings Before Interest Taxes Depreciation and Amortization (EBITDA) Multiple');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `enterprise_value` SET TAGS ('dbx_business_glossary_term' = 'Enterprise Value (EV)');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `equity_value` SET TAGS ('dbx_business_glossary_term' = 'Equity Value');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `key_assumptions` SET TAGS ('dbx_business_glossary_term' = 'Key Assumptions');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `methodology` SET TAGS ('dbx_business_glossary_term' = 'Valuation Methodology');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `methodology` SET TAGS ('dbx_value_regex' = 'dcf|comparable_company|precedent_transaction|nav|liquidation|option_pricing');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `midpoint` SET TAGS ('dbx_business_glossary_term' = 'Valuation Midpoint');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `model_file_path` SET TAGS ('dbx_business_glossary_term' = 'Model File Path');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `nav_per_share` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Per Share');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `net_debt` SET TAGS ('dbx_business_glossary_term' = 'Net Debt');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Valuation Notes');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `range_high` SET TAGS ('dbx_business_glossary_term' = 'Valuation Range High');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `range_low` SET TAGS ('dbx_business_glossary_term' = 'Valuation Range Low');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `record_created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `revenue_multiple` SET TAGS ('dbx_business_glossary_term' = 'Revenue Multiple');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `reviewer_name` SET TAGS ('dbx_business_glossary_term' = 'Reviewer Name');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `risk_factors` SET TAGS ('dbx_business_glossary_term' = 'Risk Factors');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `sensitivity_analysis_performed` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Analysis Performed');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `target_ebitda` SET TAGS ('dbx_business_glossary_term' = 'Target Earnings Before Interest Taxes Depreciation and Amortization (EBITDA)');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `target_revenue` SET TAGS ('dbx_business_glossary_term' = 'Target Revenue');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `terminal_growth_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Terminal Growth Rate Percentage');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `valuation_number` SET TAGS ('dbx_business_glossary_term' = 'Valuation Number');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `valuation_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Status');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `valuation_status` SET TAGS ('dbx_value_regex' = 'draft|in_review|approved|rejected|superseded');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `valuation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Valuation Timestamp');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `valuation_type` SET TAGS ('dbx_business_glossary_term' = 'Valuation Type');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `valuation_type` SET TAGS ('dbx_value_regex' = 'indicative|preliminary|formal|fairness_opinion|desktop|full_model');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ALTER COLUMN `wacc_percent` SET TAGS ('dbx_business_glossary_term' = 'Weighted Average Cost of Capital (WACC) Percentage');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` SET TAGS ('dbx_subdomain' = 'approval_commitment');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `deal_capital_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Capital Commitment Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `deal_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Investment Professional Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `deal_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `deal_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `deal_ic_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `deal_portfolio_manager_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Manager Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `deal_portfolio_manager_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `deal_portfolio_manager_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Investment Professional Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `liability_projection_id` SET TAGS ('dbx_business_glossary_term' = 'Liability Projection Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `portfolio_manager_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Manager Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `carried_interest_percent` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Percentage');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Commitment Amount');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `commitment_amount_base_currency` SET TAGS ('dbx_business_glossary_term' = 'Commitment Amount in Base Currency');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Commitment Currency');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `commitment_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Commitment Expiry Date');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `commitment_name` SET TAGS ('dbx_business_glossary_term' = 'Commitment Name');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `commitment_notes` SET TAGS ('dbx_business_glossary_term' = 'Commitment Notes');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `commitment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Commitment Reference Number');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `commitment_status` SET TAGS ('dbx_business_glossary_term' = 'Commitment Status');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `commitment_type` SET TAGS ('dbx_business_glossary_term' = 'Commitment Type');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `commitment_type` SET TAGS ('dbx_value_regex' = 'equity|debt|mezzanine|preferred_equity|fund_commitment|co_investment');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `dry_powder_allocation` SET TAGS ('dbx_business_glossary_term' = 'Dry Powder Allocation');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `esg_exclusion_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Exclusion Flag');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `expected_final_close_date` SET TAGS ('dbx_business_glossary_term' = 'Expected Final Close Date');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `expected_first_drawdown_date` SET TAGS ('dbx_business_glossary_term' = 'Expected First Drawdown Date');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `expected_hold_period_years` SET TAGS ('dbx_business_glossary_term' = 'Expected Hold Period in Years');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `expected_investment_period_years` SET TAGS ('dbx_business_glossary_term' = 'Expected Investment Period in Years');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `fx_rate_at_approval` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate at Approval');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `gp_sponsor_name` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) or Sponsor Name');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `gp_sponsor_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percentage');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `ic_conditions` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Conditions');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `ic_decision_outcome` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Decision Outcome');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `ic_decision_outcome` SET TAGS ('dbx_value_regex' = 'approved|approved_with_conditions|deferred|rejected');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `ic_meeting_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Meeting Reference');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `investment_thesis` SET TAGS ('dbx_business_glossary_term' = 'Investment Thesis');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `investment_thesis` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `lpa_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Execution Date');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `lpa_signed_flag` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Signed Flag');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `management_fee_percent` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Percentage');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|very_high');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `strategic_fit_score` SET TAGS ('dbx_business_glossary_term' = 'Strategic Fit Score');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `sub_asset_class` SET TAGS ('dbx_business_glossary_term' = 'Sub-Asset Class');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `target_irr_percent` SET TAGS ('dbx_business_glossary_term' = 'Target Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `target_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Target Jurisdiction');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `target_jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `target_lei` SET TAGS ('dbx_business_glossary_term' = 'Target Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `target_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `target_moic` SET TAGS ('dbx_business_glossary_term' = 'Target Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`deal`.`ppm_review` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`deal`.`ppm_review` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`ppm_review` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`ppm_review` SET TAGS ('dbx_subdomain' = 'approval_commitment');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `ppm_review_id` SET TAGS ('dbx_business_glossary_term' = 'Private Placement Memorandum (PPM) Review ID');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewer ID');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `fee_benchmark_id` SET TAGS ('dbx_business_glossary_term' = 'Fee Benchmark Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity ID');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewer ID');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `carried_interest_percent` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Percent');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `esg_policy_summary` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Policy Summary');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'ESG Rating');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `follow_up_actions` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Actions');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `fund_asset_class` SET TAGS ('dbx_business_glossary_term' = 'Fund Asset Class');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `fund_asset_class` SET TAGS ('dbx_value_regex' = 'private_equity|real_estate|infrastructure|natural_resources|credit|multi_strategy');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `fund_name` SET TAGS ('dbx_business_glossary_term' = 'Fund Name');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `fund_strategy` SET TAGS ('dbx_business_glossary_term' = 'Fund Strategy');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `fund_term_years` SET TAGS ('dbx_business_glossary_term' = 'Fund Term Years');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `fund_vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Fund Vintage Year');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `gp_aum_amount` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Assets Under Management (AUM) Amount');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `gp_aum_currency` SET TAGS ('dbx_business_glossary_term' = 'GP AUM Currency');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `gp_lei` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `gp_prior_fund_count` SET TAGS ('dbx_business_glossary_term' = 'GP Prior Fund Count');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `gp_sponsor_name` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Sponsor Name');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `gp_track_record_assessment` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Track Record Assessment');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percent');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `ic_submission_required` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Required');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `investment_period_years` SET TAGS ('dbx_business_glossary_term' = 'Investment Period Years');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `investment_restrictions` SET TAGS ('dbx_business_glossary_term' = 'Investment Restrictions');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `key_person_provisions` SET TAGS ('dbx_business_glossary_term' = 'Key Person Provisions');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `management_fee_percent` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Percent');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `minimum_commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Minimum Commitment Amount');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `minimum_commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Minimum Commitment Currency');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `ppm_document_date` SET TAGS ('dbx_business_glossary_term' = 'PPM Document Date');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `ppm_document_version` SET TAGS ('dbx_business_glossary_term' = 'PPM Document Version');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `recommendation` SET TAGS ('dbx_business_glossary_term' = 'Recommendation');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `recommendation` SET TAGS ('dbx_value_regex' = 'proceed|proceed_with_conditions|decline|further_diligence_required');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `recommendation_rationale` SET TAGS ('dbx_business_glossary_term' = 'Recommendation Rationale');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `red_flags_identified` SET TAGS ('dbx_business_glossary_term' = 'Red Flags Identified');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `review_code` SET TAGS ('dbx_business_glossary_term' = 'PPM Review Code');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `review_completed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Review Completed Timestamp');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'Review Date');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `review_initiated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Review Initiated Timestamp');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `review_notes` SET TAGS ('dbx_business_glossary_term' = 'Review Notes');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `review_status` SET TAGS ('dbx_business_glossary_term' = 'Review Status');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `review_status` SET TAGS ('dbx_value_regex' = 'initiated|in_progress|completed|approved|rejected|on_hold');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `review_team` SET TAGS ('dbx_business_glossary_term' = 'Review Team');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `reviewer_name` SET TAGS ('dbx_business_glossary_term' = 'Reviewer Name');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `risk_assessment` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|very_high');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `strategic_fit_score` SET TAGS ('dbx_business_glossary_term' = 'Strategic Fit Score');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `target_fund_size_amount` SET TAGS ('dbx_business_glossary_term' = 'Target Fund Size Amount');
ALTER TABLE `asset_management`.`deal`.`ppm_review` ALTER COLUMN `target_fund_size_currency` SET TAGS ('dbx_business_glossary_term' = 'Target Fund Size Currency');
ALTER TABLE `asset_management`.`deal`.`screening_decision` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`deal`.`screening_decision` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`screening_decision` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`screening_decision` SET TAGS ('dbx_subdomain' = 'pipeline_origination');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `screening_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Screening Decision Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Committee Chair Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `lead_reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Reviewer Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `screening_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Committee Chair Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `screening_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `screening_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `screening_lead_reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Reviewer Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `screening_lead_reviewer_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `screening_lead_reviewer_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `committee_chair_name` SET TAGS ('dbx_business_glossary_term' = 'Committee Chair Name');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `committee_member_count` SET TAGS ('dbx_business_glossary_term' = 'Committee Member Count');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `conditions_imposed` SET TAGS ('dbx_business_glossary_term' = 'Conditions Imposed');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Level');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `decision_outcome` SET TAGS ('dbx_business_glossary_term' = 'Screening Decision Outcome');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `decision_outcome` SET TAGS ('dbx_value_regex' = 'proceed|hold|decline|conditional_proceed|refer_to_ic');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `decision_status` SET TAGS ('dbx_business_glossary_term' = 'Screening Decision Status');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `decision_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|approved|rejected|withdrawn');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `decline_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Decline Reason Code');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `decline_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Decline Reason Description');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `esg_exclusion_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Exclusion Flag');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `esg_rating` SET TAGS ('dbx_value_regex' = 'A|B|C|D|F');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `hold_reason` SET TAGS ('dbx_business_glossary_term' = 'Hold Reason');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `ic_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Date');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `ic_submission_required` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Required Flag');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `lead_reviewer_name` SET TAGS ('dbx_business_glossary_term' = 'Lead Reviewer Name');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `legal_concern_flag` SET TAGS ('dbx_business_glossary_term' = 'Legal Concern Flag');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `meeting_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Meeting Reference Number');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `operational_concern_flag` SET TAGS ('dbx_business_glossary_term' = 'Operational Concern Flag');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `quorum_met` SET TAGS ('dbx_business_glossary_term' = 'Quorum Met Flag');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `record_created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|very_high');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `screening_committee_name` SET TAGS ('dbx_business_glossary_term' = 'Screening Committee Name');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `screening_date` SET TAGS ('dbx_business_glossary_term' = 'Screening Decision Date');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `screening_notes` SET TAGS ('dbx_business_glossary_term' = 'Screening Notes');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `screening_number` SET TAGS ('dbx_business_glossary_term' = 'Screening Decision Number');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `screening_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Screening Decision Timestamp');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `screening_type` SET TAGS ('dbx_business_glossary_term' = 'Screening Type');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `screening_type` SET TAGS ('dbx_value_regex' = 'initial|full|supplemental|expedited|special');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `strategic_fit_score` SET TAGS ('dbx_business_glossary_term' = 'Strategic Fit Score');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `supporting_document_count` SET TAGS ('dbx_business_glossary_term' = 'Supporting Document Count');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `unanimous_decision` SET TAGS ('dbx_business_glossary_term' = 'Unanimous Decision Flag');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `valuation_concern_flag` SET TAGS ('dbx_business_glossary_term' = 'Valuation Concern Flag');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `vote_abstain_count` SET TAGS ('dbx_business_glossary_term' = 'Vote Abstain Count');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `vote_against_count` SET TAGS ('dbx_business_glossary_term' = 'Vote Against Count');
ALTER TABLE `asset_management`.`deal`.`screening_decision` ALTER COLUMN `vote_for_count` SET TAGS ('dbx_business_glossary_term' = 'Vote For Count');
ALTER TABLE `asset_management`.`deal`.`deal_document` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`deal`.`deal_document` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`deal_document` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`deal_document` SET TAGS ('dbx_subdomain' = 'documentation_negotiation');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `deal_document_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Document Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `approved_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `counterparty_legal_entity_counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `deal_ic_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Uploaded By User Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `owner_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Document Owner User Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `owner_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `owner_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `superseded_by_document_deal_document_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Document Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `access_restriction_flag` SET TAGS ('dbx_business_glossary_term' = 'Access Restriction Flag');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Approval Required Flag');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'PENDING|APPROVED|REJECTED|NOT_REQUIRED');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `approved_by_user_name` SET TAGS ('dbx_business_glossary_term' = 'Approved By User Name');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `approved_by_user_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `approved_by_user_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `author_name` SET TAGS ('dbx_business_glossary_term' = 'Author Name');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Level');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'PUBLIC|INTERNAL|CONFIDENTIAL|RESTRICTED');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `deal_stage_code` SET TAGS ('dbx_business_glossary_term' = 'Deal Stage Code');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `document_date` SET TAGS ('dbx_business_glossary_term' = 'Document Date');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `document_description` SET TAGS ('dbx_business_glossary_term' = 'Document Description');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'Document Status');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `execution_date` SET TAGS ('dbx_business_glossary_term' = 'Execution Date');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `external_signatory_name` SET TAGS ('dbx_business_glossary_term' = 'External Signatory Name');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `external_signatory_title` SET TAGS ('dbx_business_glossary_term' = 'External Signatory Title');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `file_format` SET TAGS ('dbx_business_glossary_term' = 'File Format');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `file_name` SET TAGS ('dbx_business_glossary_term' = 'File Name');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `file_size_bytes` SET TAGS ('dbx_business_glossary_term' = 'File Size in Bytes');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `hash` SET TAGS ('dbx_business_glossary_term' = 'Document Hash');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `internal_signatory_name` SET TAGS ('dbx_business_glossary_term' = 'Internal Signatory Name');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `internal_signatory_title` SET TAGS ('dbx_business_glossary_term' = 'Internal Signatory Title');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `legal_counsel_firm` SET TAGS ('dbx_business_glossary_term' = 'Legal Counsel Firm');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `legal_review_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Legal Review Required Flag');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `legal_review_status` SET TAGS ('dbx_business_glossary_term' = 'Legal Review Status');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `legal_review_status` SET TAGS ('dbx_value_regex' = 'PENDING|IN_PROGRESS|COMPLETED|NOT_REQUIRED');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Document Notes');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `owner_user_name` SET TAGS ('dbx_business_glossary_term' = 'Document Owner User Name');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `owner_user_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `owner_user_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Document Reference Number');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `storage_location` SET TAGS ('dbx_business_glossary_term' = 'Document Storage Location');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `storage_location` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Document Title');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `type_code` SET TAGS ('dbx_business_glossary_term' = 'Document Type Code');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `type_name` SET TAGS ('dbx_business_glossary_term' = 'Document Type Name');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `upload_date` SET TAGS ('dbx_business_glossary_term' = 'Upload Date');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `upload_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Upload Timestamp');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `uploaded_by_user_name` SET TAGS ('dbx_business_glossary_term' = 'Uploaded By User Name');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `uploaded_by_user_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `uploaded_by_user_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Document Version');
ALTER TABLE `asset_management`.`deal`.`deal_document` ALTER COLUMN `version_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Version Sequence Number');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` SET TAGS ('dbx_subdomain' = 'documentation_negotiation');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `exclusivity_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Exclusivity Agreement ID');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity ID');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `counterparty_legal_entity_counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity ID');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Investment Professional ID');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `lead_investment_professional_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Investment Professional ID');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity ID');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `agreement_number` SET TAGS ('dbx_business_glossary_term' = 'Agreement Reference Number');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Exclusivity Agreement Type');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'full_exclusivity|limited_exclusivity|no_shop|no_talk|standstill');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `arbitration_venue` SET TAGS ('dbx_business_glossary_term' = 'Arbitration Venue');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `breach_description` SET TAGS ('dbx_business_glossary_term' = 'Breach Description');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `breach_reported_flag` SET TAGS ('dbx_business_glossary_term' = 'Breach Reported Flag');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `break_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Break Fee Amount');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `break_fee_currency` SET TAGS ('dbx_business_glossary_term' = 'Break Fee Currency Code');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `break_fee_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `counterparty_signatory_name` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Signatory Name');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `counterparty_signatory_title` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Signatory Title');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `deal_structure` SET TAGS ('dbx_business_glossary_term' = 'Proposed Deal Structure');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `deposit_amount` SET TAGS ('dbx_business_glossary_term' = 'Exclusivity Deposit Amount');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `deposit_currency` SET TAGS ('dbx_business_glossary_term' = 'Deposit Currency Code');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `deposit_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `deposit_refundable_flag` SET TAGS ('dbx_business_glossary_term' = 'Deposit Refundable Flag');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Mechanism');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_value_regex' = 'litigation|arbitration|mediation');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `document_storage_location` SET TAGS ('dbx_business_glossary_term' = 'Document Storage Location');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Exclusivity Effective Start Date');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `exclusivity_agreement_status` SET TAGS ('dbx_business_glossary_term' = 'Agreement Status');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `exclusivity_agreement_status` SET TAGS ('dbx_value_regex' = 'draft|executed|active|expired|terminated|breached');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `exclusivity_period_days` SET TAGS ('dbx_business_glossary_term' = 'Exclusivity Period Duration (Days)');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `execution_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Execution Date');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Exclusivity Expiry Date');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `extension_count` SET TAGS ('dbx_business_glossary_term' = 'Extension Count');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `extension_permitted_flag` SET TAGS ('dbx_business_glossary_term' = 'Extension Permitted Flag');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `external_counsel_firm` SET TAGS ('dbx_business_glossary_term' = 'External Counsel Firm Name');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `fiduciary_out_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Fiduciary Out Clause Flag');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `governing_law_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Governing Law Jurisdiction');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `indicative_enterprise_value` SET TAGS ('dbx_business_glossary_term' = 'Indicative Enterprise Value');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `internal_counsel_approval_flag` SET TAGS ('dbx_business_glossary_term' = 'Internal Counsel Approval Flag');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `internal_signatory_name` SET TAGS ('dbx_business_glossary_term' = 'Internal Signatory Name');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `internal_signatory_title` SET TAGS ('dbx_business_glossary_term' = 'Internal Signatory Title');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `loi_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Letter of Intent (LOI) Reference Number');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `nda_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Reference Number');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `no_shop_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'No-Shop Provision Flag');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Agreement Notes');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `record_created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By User');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `remediation_action_taken` SET TAGS ('dbx_business_glossary_term' = 'Remediation Action Taken');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `scope_description` SET TAGS ('dbx_business_glossary_term' = 'Exclusivity Scope Description');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `standstill_period_months` SET TAGS ('dbx_business_glossary_term' = 'Standstill Period Duration (Months)');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `standstill_provision_flag` SET TAGS ('dbx_business_glossary_term' = 'Standstill Provision Flag');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `target_lei` SET TAGS ('dbx_business_glossary_term' = 'Target Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `target_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Agreement Termination Date');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `valuation_currency` SET TAGS ('dbx_business_glossary_term' = 'Valuation Currency Code');
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ALTER COLUMN `valuation_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`milestone` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`deal`.`milestone` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`milestone` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`milestone` SET TAGS ('dbx_subdomain' = 'documentation_negotiation');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Milestone Identifier');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `completed_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Completed By User Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `completed_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `completed_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Responsible User Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `actual_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Milestone Date');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `approving_committee` SET TAGS ('dbx_business_glossary_term' = 'Approving Committee Name');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `milestone_code` SET TAGS ('dbx_business_glossary_term' = 'Milestone Code');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `conditions_imposed` SET TAGS ('dbx_business_glossary_term' = 'Conditions Imposed');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `conditions_met` SET TAGS ('dbx_business_glossary_term' = 'Conditions Met Indicator');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `counterparty_name` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Name');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `counterparty_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `deal_type` SET TAGS ('dbx_business_glossary_term' = 'Deal Type');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `deal_type` SET TAGS ('dbx_value_regex' = 'direct_investment|co_investment|fund_commitment|secondary|joint_venture');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `decision_date` SET TAGS ('dbx_business_glossary_term' = 'Decision Date');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `document_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Document Execution Date');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `document_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Document Reference Number');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `esg_review_required` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Review Required Indicator');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `esg_review_status` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Review Status');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `esg_review_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed|waived');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `gate_decision` SET TAGS ('dbx_business_glossary_term' = 'Gate Decision Outcome');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `gate_decision` SET TAGS ('dbx_value_regex' = 'approved|rejected|conditional|deferred|withdrawn');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `gp_sponsor_name` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Sponsor Name');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `ic_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Meeting Date');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `intermediary_name` SET TAGS ('dbx_business_glossary_term' = 'Intermediary Firm Name');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `is_critical_path` SET TAGS ('dbx_business_glossary_term' = 'Critical Path Indicator');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `is_gate_milestone` SET TAGS ('dbx_business_glossary_term' = 'Gate Milestone Indicator');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `milestone_status` SET TAGS ('dbx_business_glossary_term' = 'Milestone Status');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `milestone_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|cancelled|deferred|failed');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `milestone_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Milestone Timestamp');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `milestone_type` SET TAGS ('dbx_business_glossary_term' = 'Milestone Type');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `milestone_name` SET TAGS ('dbx_business_glossary_term' = 'Milestone Name');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Milestone Notes');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `notification_sent` SET TAGS ('dbx_business_glossary_term' = 'Notification Sent Indicator');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `notification_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Notification Timestamp');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `record_created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By User');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `regulatory_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Required Indicator');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `regulatory_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Jurisdiction');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `responsible_party` SET TAGS ('dbx_business_glossary_term' = 'Responsible Party Name');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `scheduled_date` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Milestone Date');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `sequence` SET TAGS ('dbx_business_glossary_term' = 'Milestone Sequence Number');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Target Entity Name');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `target_entity_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `target_lei` SET TAGS ('dbx_business_glossary_term' = 'Target Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `target_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`deal`.`milestone` ALTER COLUMN `variance_days` SET TAGS ('dbx_business_glossary_term' = 'Variance Days');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` SET TAGS ('dbx_subdomain' = 'approval_commitment');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `co_invest_allocation_id` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Allocation Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `kyc_record_id` SET TAGS ('dbx_business_glossary_term' = 'Kyc Record Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `relationship_manager_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Relationship Manager Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `relationship_manager_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `relationship_manager_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `actual_close_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Co-Investment Close Date');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `allocated_amount` SET TAGS ('dbx_business_glossary_term' = 'Allocated Co-Investment Amount');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `allocated_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `allocation_acceptance_date` SET TAGS ('dbx_business_glossary_term' = 'Allocation Acceptance Date');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `allocation_commitment_date` SET TAGS ('dbx_business_glossary_term' = 'Allocation Commitment Date');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `allocation_currency` SET TAGS ('dbx_business_glossary_term' = 'Allocation Currency Code');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `allocation_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `allocation_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Allocation Offer Expiry Date');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `allocation_funding_date` SET TAGS ('dbx_business_glossary_term' = 'Allocation Funding Date');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `allocation_notes` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Allocation Notes');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `allocation_offer_date` SET TAGS ('dbx_business_glossary_term' = 'Allocation Offer Date');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `allocation_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Allocation Reference Number');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `allocation_status` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Allocation Status');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `allocation_status` SET TAGS ('dbx_value_regex' = 'pending|active|completed|cancelled|expired');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `allocation_type` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Allocation Type');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `allocation_type` SET TAGS ('dbx_value_regex' = 'offered|accepted|declined|committed|funded|withdrawn');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `carried_interest_percent` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Percentage (Carry)');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `carried_interest_percent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `co_investor_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Co-Investor Entity Legal Name');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `co_investor_entity_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `co_investor_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Co-Investor Jurisdiction Code');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `co_investor_jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `co_investor_lei` SET TAGS ('dbx_business_glossary_term' = 'Co-Investor Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `co_investor_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `co_investor_lei` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `co_investor_type` SET TAGS ('dbx_business_glossary_term' = 'Co-Investor Entity Type');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `co_investor_type` SET TAGS ('dbx_value_regex' = 'pension_fund|sovereign_wealth_fund|insurance_company|endowment|family_office|asset_manager');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Level');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `decline_reason` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Decline Reason');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `expected_close_date` SET TAGS ('dbx_business_glossary_term' = 'Expected Co-Investment Close Date');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `fee_arrangement` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Fee Arrangement');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `fee_arrangement` SET TAGS ('dbx_value_regex' = 'no_fee|management_fee_only|carried_interest_only|full_fee_structure|custom');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `fee_arrangement` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `governance_rights` SET TAGS ('dbx_business_glossary_term' = 'Co-Investor Governance Rights');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `governance_rights` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percentage (Preferred Return)');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `hurdle_rate_percent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `ic_approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Required Flag');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `kyc_aml_status` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) and Anti-Money Laundering (AML) Status');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `kyc_aml_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|approved|rejected|expired');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `kyc_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Completion Date');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `lead_investment_professional` SET TAGS ('dbx_business_glossary_term' = 'Lead Investment Professional Name');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `lpa_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reference Number');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `lpa_reference_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `management_fee_percent` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Percentage');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `management_fee_percent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Co-Investor Ownership Percentage');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `record_created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By User');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `regulatory_approval_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Required Flag');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Status');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `regulatory_approval_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|submitted|approved|rejected');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `side_letter_flag` SET TAGS ('dbx_business_glossary_term' = 'Side Letter Agreement Flag');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `side_letter_reference` SET TAGS ('dbx_business_glossary_term' = 'Side Letter Reference Number');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `side_letter_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `subscription_agreement_reference` SET TAGS ('dbx_business_glossary_term' = 'Subscription Agreement Reference Number');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `subscription_agreement_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_business_glossary_term' = 'Co-Investment Withdrawal Reason');
ALTER TABLE `asset_management`.`deal`.`deal_fee` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`deal`.`deal_fee` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`deal_fee` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`deal_fee` SET TAGS ('dbx_subdomain' = 'documentation_negotiation');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `deal_fee_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Fee Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approver Employee Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `co_invest_allocation_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `deal_ic_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Submission Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `rate_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Schedule Id (Foreign Key)');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Amount');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `amount_usd` SET TAGS ('dbx_business_glossary_term' = 'Fee Amount United States Dollar (USD)');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `amount_usd` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `basis` SET TAGS ('dbx_business_glossary_term' = 'Fee Basis');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `basis` SET TAGS ('dbx_value_regex' = 'fixed|percentage|hourly|retainer|success_based');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `calculation_base_amount` SET TAGS ('dbx_business_glossary_term' = 'Calculation Base Amount');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `calculation_base_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Fee Currency Code');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `deal_stage` SET TAGS ('dbx_business_glossary_term' = 'Deal Stage');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `engagement_letter_reference` SET TAGS ('dbx_business_glossary_term' = 'Engagement Letter Reference');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `fee_category` SET TAGS ('dbx_business_glossary_term' = 'Fee Category');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `fee_category` SET TAGS ('dbx_value_regex' = 'transaction|professional_services|regulatory|administrative');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `fee_status` SET TAGS ('dbx_business_glossary_term' = 'Fee Status');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `fee_status` SET TAGS ('dbx_value_regex' = 'estimated|committed|invoiced|paid|cancelled|disputed');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `fee_type` SET TAGS ('dbx_business_glossary_term' = 'Fee Type');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `fee_type` SET TAGS ('dbx_value_regex' = 'advisory|arrangement|legal|due_diligence|break|success');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `fx_rate_date` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate Date');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `invoice_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Date');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `invoice_due_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Due Date');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Invoice Number');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `is_capitalizable` SET TAGS ('dbx_business_glossary_term' = 'Is Capitalizable Flag');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `is_reimbursable` SET TAGS ('dbx_business_glossary_term' = 'Is Reimbursable Flag');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Fee Notes');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|ach|check|eft');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `percentage` SET TAGS ('dbx_business_glossary_term' = 'Fee Percentage');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `percentage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `record_created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Fee Reference Number');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `reimbursement_amount` SET TAGS ('dbx_business_glossary_term' = 'Reimbursement Amount');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `reimbursement_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `reimbursement_date` SET TAGS ('dbx_business_glossary_term' = 'Reimbursement Date');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `service_description` SET TAGS ('dbx_business_glossary_term' = 'Service Description');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `service_end_date` SET TAGS ('dbx_business_glossary_term' = 'Service End Date');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `service_provider_lei` SET TAGS ('dbx_business_glossary_term' = 'Service Provider Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `service_provider_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `service_provider_name` SET TAGS ('dbx_business_glossary_term' = 'Service Provider Name');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `service_provider_type` SET TAGS ('dbx_business_glossary_term' = 'Service Provider Type');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `service_provider_type` SET TAGS ('dbx_value_regex' = 'investment_bank|law_firm|accounting_firm|consultant|broker');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `service_start_date` SET TAGS ('dbx_business_glossary_term' = 'Service Start Date');
ALTER TABLE `asset_management`.`deal`.`deal_fee` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_contact` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`deal`.`deal_contact` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`deal_contact` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`deal_contact` SET TAGS ('dbx_subdomain' = 'pipeline_origination');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `deal_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Contact Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Level');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `conflict_of_interest_description` SET TAGS ('dbx_business_glossary_term' = 'Conflict of Interest Description');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `conflict_of_interest_flag` SET TAGS ('dbx_business_glossary_term' = 'Conflict of Interest Flag');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `contact_role` SET TAGS ('dbx_business_glossary_term' = 'Contact Role');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `contact_type` SET TAGS ('dbx_business_glossary_term' = 'Contact Type');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `contact_type` SET TAGS ('dbx_value_regex' = 'sell_side_advisor|management_team|gp_representative|legal_counsel|intermediary|broker');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `data_room_access_date` SET TAGS ('dbx_business_glossary_term' = 'Data Room Access Date');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `data_room_access_granted_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Room Access Granted Flag');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `decision_maker_flag` SET TAGS ('dbx_business_glossary_term' = 'Decision Maker Flag');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'Contact Email Address');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `first_contact_date` SET TAGS ('dbx_business_glossary_term' = 'First Contact Date');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `first_name` SET TAGS ('dbx_business_glossary_term' = 'Contact First Name');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `full_name` SET TAGS ('dbx_business_glossary_term' = 'Contact Full Name');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `full_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `full_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `kyc_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Completion Date');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `kyc_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Expiry Date');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `kyc_status` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Status');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `kyc_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed|failed|expired');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `last_contact_date` SET TAGS ('dbx_business_glossary_term' = 'Last Contact Date');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `last_name` SET TAGS ('dbx_business_glossary_term' = 'Contact Last Name');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `linkedin_profile_url` SET TAGS ('dbx_business_glossary_term' = 'LinkedIn Profile Uniform Resource Locator (URL)');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `mobile_number` SET TAGS ('dbx_business_glossary_term' = 'Contact Mobile Number');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `mobile_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `mobile_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `nda_signatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Non-Disclosure Agreement (NDA) Signatory Flag');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Contact Notes');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `office_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Office Address Line 1');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `office_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `office_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `office_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Office Address Line 2');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `office_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `office_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `office_city` SET TAGS ('dbx_business_glossary_term' = 'Office City');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `office_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `office_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `office_country_code` SET TAGS ('dbx_business_glossary_term' = 'Office Country Code');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `office_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `office_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Office Postal Code');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `office_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `office_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `office_state_province` SET TAGS ('dbx_business_glossary_term' = 'Office State or Province');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `office_state_province` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `office_state_province` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `organization_lei` SET TAGS ('dbx_business_glossary_term' = 'Organization Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `organization_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `organization_name` SET TAGS ('dbx_business_glossary_term' = 'Organization Name');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `organization_type` SET TAGS ('dbx_business_glossary_term' = 'Organization Type');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `organization_type` SET TAGS ('dbx_value_regex' = 'investment_bank|advisory_firm|law_firm|gp_sponsor|intermediary|broker_dealer');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `phone_number` SET TAGS ('dbx_business_glossary_term' = 'Contact Phone Number');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `preferred_communication_method` SET TAGS ('dbx_business_glossary_term' = 'Preferred Communication Method');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `preferred_communication_method` SET TAGS ('dbx_value_regex' = 'email|phone|mobile|video_conference|in_person');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `primary_contact_flag` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Flag');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `professional_biography` SET TAGS ('dbx_business_glossary_term' = 'Professional Biography');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `record_created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `relationship_status` SET TAGS ('dbx_business_glossary_term' = 'Relationship Status');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `relationship_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|terminated');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier (ID)');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `specialization_area` SET TAGS ('dbx_business_glossary_term' = 'Specialization Area');
ALTER TABLE `asset_management`.`deal`.`deal_contact` ALTER COLUMN `years_of_experience` SET TAGS ('dbx_business_glossary_term' = 'Years of Experience');
ALTER TABLE `asset_management`.`deal`.`deal_check` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`deal`.`deal_check` SET TAGS ('dbx_domain' = 'deal');
ALTER TABLE `asset_management`.`deal`.`deal_check` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`deal`.`deal_check` SET TAGS ('dbx_subdomain' = 'approval_commitment');
ALTER TABLE `asset_management`.`deal`.`deal_check` SET TAGS ('dbx_association_edges' = 'deal.opportunity,compliance.rule');
ALTER TABLE `asset_management`.`deal`.`deal_check` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewer Identifier');
ALTER TABLE `asset_management`.`deal`.`deal_check` ALTER COLUMN `deal_check_date` SET TAGS ('dbx_business_glossary_term' = 'Check Date');
ALTER TABLE `asset_management`.`deal`.`deal_check` ALTER COLUMN `deal_check_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status');
ALTER TABLE `asset_management`.`deal`.`deal_check` ALTER COLUMN `exception_flag` SET TAGS ('dbx_business_glossary_term' = 'Exception Flag');
