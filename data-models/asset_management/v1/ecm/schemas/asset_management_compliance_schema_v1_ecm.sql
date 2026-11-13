-- Schema for Domain: compliance | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:24

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`compliance` COMMENT 'Domain for regulatory compliance, beneficiary reporting, and governance operations. Owns regulatory filing records (SEC, FCA, ESMA), KYC/AML documentation, trade reporting (EMIR, MiFID II), SFDR disclosures, LEI management, investment committee';
ALTER SCHEMA `asset_management`.`compliance` SET TAGS ('dbx_division' = 'corporate');
ALTER SCHEMA `asset_management`.`compliance` SET TAGS ('dbx_domain' = 'compliance');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`compliance`.`regulatory_filing` (
    `regulatory_filing_id` BIGINT COMMENT 'System-generated unique identifier for the regulatory filing record.',
    `obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: Regulatory filings are made to fulfill specific compliance obligations. Each filing satisfies one obligation requirement.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Link regulatory_filing to regulatory_authority to capture the authority receiving the filing. Redundant authority attributes removed.',
    `stress_test_result_id` BIGINT COMMENT 'Foreign key linking to risk.stress_test_result. Business justification: Pension fund regulatory filings (IORP II, local pension regulations) require stress test results as supporting evidence.',
    `acceptance_date` TIMESTAMP COMMENT 'Timestamp when the regulator accepted the filing (null if not accepted).',
    `attached_document_url` STRING COMMENT 'Link to the electronic copy of the filing stored in the lakehouse.',
    `comments` STRING COMMENT 'Additional notes or remarks entered by the filing preparer.',
    `compliance_flag` BOOLEAN COMMENT 'Indicates whether the filing meets all regulatory compliance checks (true) or has outstanding issues (false).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the filing record was first created in the system.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code for the filing fee.',
    `filing_deadline` DATE COMMENT 'Date by which the filing must be submitted to the regulator.',
    `filing_fee_amount` DECIMAL(18,2) COMMENT 'Monetary fee charged by the regulator for processing the filing.',
    `filing_format` STRING COMMENT 'File format of the submitted filing.. Valid values are `xbrl|pdf|xml|json`',
    `filing_name` STRING COMMENT 'Descriptive name of the filing used for display and reporting.',
    `filing_number` STRING COMMENT 'External reference number assigned by the regulator or internal system for this filing.',
    `filing_status` STRING COMMENT 'Current lifecycle status of the filing.. Valid values are `draft|submitted|acknowledged|accepted|rejected`',
    `filing_type` STRING COMMENT 'Category of filing based on reporting frequency or purpose.. Valid values are `annual|quarterly|monthly|ad_hoc|event_driven|other`',
    `rejection_date` TIMESTAMP COMMENT 'Timestamp when the regulator rejected the filing (null if not rejected).',
    `rejection_reason` STRING COMMENT 'Free‑text explanation provided by the regulator for a rejected filing.',
    `reporting_period_end` DATE COMMENT 'Last day of the period covered by the filing.',
    `reporting_period_start` DATE COMMENT 'First day of the financial or regulatory period covered by the filing.',
    `submission_date` TIMESTAMP COMMENT 'Exact date and time the filing was submitted.',
    `submission_method` STRING COMMENT 'Channel used to submit the filing to the regulator.. Valid values are `electronic|paper|portal|api`',
    `updated_by` STRING COMMENT 'Identifier of the user or system that last updated the filing record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the filing record.',
    `version_number` BIGINT COMMENT 'Incremental version of the filing when resubmitted or amended.',
    `created_by` STRING COMMENT 'Identifier of the user or system that created the filing record.',
    CONSTRAINT pk_regulatory_filing PRIMARY KEY(`regulatory_filing_id`)
) COMMENT 'Master record for each formal regulatory filing submitted to governing bodies (SEC, FCA, ESMA, IOSCO). Captures filing type, regulatory authority, reporting period, submission date, filing status (draft, submitted, acknowledged, accepted, rejected)';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`filing_submission` (
    `filing_submission_id` BIGINT COMMENT 'System-generated unique identifier for the filing submission record.',
    `regulatory_filing_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_filing. Business justification: filing_submission is a transactional record of each submission event for a regulatory filing.',
    `acknowledgement_reference` STRING COMMENT 'Reference number or receipt provided by the regulator confirming receipt.',
    `comments` STRING COMMENT 'Free‑form notes or remarks added by the submitter or reviewer.',
    `error_code` STRING COMMENT 'Code returned by the regulator or internal system when submission fails.',
    `error_description` STRING COMMENT 'Human‑readable description of the error associated with the submission.',
    `file_checksum` STRING COMMENT 'SHA-256 checksum of the submitted file for integrity verification.. Valid values are `^[A-Fa-f0-9]{64}$`',
    `file_name` STRING COMMENT 'Name of the electronic file submitted to the regulator.',
    `file_size_bytes` BIGINT COMMENT 'Size of the submitted file in bytes.',
    `filing_period_end` DATE COMMENT 'End date of the reporting period covered by the filing.',
    `filing_period_start` DATE COMMENT 'Start date of the reporting period covered by the filing.',
    `filing_submission_status` STRING COMMENT 'Current processing state of the filing submission.. Valid values are `draft|pending|submitted|rejected|accepted`',
    `filing_type` STRING COMMENT 'Category of regulatory filing (e.g., annual report, quarterly report).. Valid values are `annual_report|quarterly_report|semiannual_report|ad_hoc|regulatory_notice|other`',
    `record_audit_created` TIMESTAMP COMMENT 'Timestamp when the filing submission record was first created in the system.',
    `record_audit_updated` TIMESTAMP COMMENT 'Timestamp of the most recent update to the filing submission record.',
    `regulator` STRING COMMENT 'Regulatory authority to which the filing is submitted.. Valid values are `SEC|FCA|ESMA|IOSCO|Other`',
    `submission_method` STRING COMMENT 'Channel used to submit the filing (e.g., portal, XBRL, API, manual upload).. Valid values are `portal|xbrl|api|manual`',
    `submission_number` STRING COMMENT 'External sequential number assigned to each filing submission for tracking.',
    `submission_timestamp` TIMESTAMP COMMENT 'Date and time when the filing was actually submitted to the regulator.',
    `submitted_by` STRING COMMENT 'Identifier of the employee or system that performed the submission.',
    CONSTRAINT pk_filing_submission PRIMARY KEY(`filing_submission_id`)
) COMMENT 'Transactional record of each individual submission event for a regulatory filing, capturing submission timestamp, submission method (portal, XBRL, API, manual), submitted by (officer/system), submission status, acknowledgement receipt reference, regulator';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`regulatory_calendar` (
    `regulatory_calendar_id` BIGINT COMMENT 'Unique identifier for the regulatory calendar record.',
    `obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: Link regulatory_calendar to obligation to represent each calendar entry belonging to a specific obligation. Redundant obligation attributes removed.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Link regulatory_calendar to regulatory_authority to capture the authority responsible for the obligation. Redundant authority attributes removed.',
    `rule_id` BIGINT COMMENT 'Foreign key linking to compliance.rule. Business justification: Link regulatory_calendar to rule to capture the compliance rule governing the obligation. No redundant columns to remove.',
    `compliance_status` STRING COMMENT 'Current compliance outcome for the obligation.. Valid values are `compliant|non-compliant|pending|exempt`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the calendar record was created.',
    `data_classification` STRING COMMENT 'Internal classification of the record (e.g., public, internal, confidential).',
    `effective_end_date` DATE COMMENT 'Date when the regulatory obligation ends or is superseded (nullable).',
    `effective_start_date` DATE COMMENT 'Date when the regulatory obligation becomes effective.',
    `escalation_contact` STRING COMMENT 'Email address for escalation if the filing is missed or delayed.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `filing_deadline` DATE COMMENT 'Official deadline by which the filing must be submitted.',
    `filing_frequency` STRING COMMENT 'How often the filing must be submitted.. Valid values are `annual|semi-annual|quarterly|monthly|ad-hoc`',
    `filing_method` STRING COMMENT 'Channel used to submit the filing.. Valid values are `electronic|paper|portal|api`',
    `filing_reference_number` STRING COMMENT 'External reference number assigned by the regulator upon filing.',
    `filing_status` STRING COMMENT 'Current status of the filing for the upcoming period.. Valid values are `filed|not_filed|waived|pending`',
    `is_external` BOOLEAN COMMENT 'True if the requirement originates from an external regulator; false if internal policy.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether the filing is mandatory (true) or optional (false).',
    `last_filed_date` DATE COMMENT 'Date when the obligation was most recently filed.',
    `last_reviewed_date` DATE COMMENT 'Date when the obligation details were last reviewed for accuracy.',
    `next_due_date` DATE COMMENT 'Upcoming deadline for the next filing of this obligation.',
    `next_review_date` DATE COMMENT 'Planned date for the next review of the obligation.',
    `notes` STRING COMMENT 'Free‑form comments or observations about the obligation.',
    `penalty_risk_level` STRING COMMENT 'Risk rating of potential penalties for non‑compliance.. Valid values are `low|medium|high|critical`',
    `regulatory_calendar_status` STRING COMMENT 'Current lifecycle status of the regulatory obligation.. Valid values are `active|inactive|pending|retired`',
    `required_documentation` STRING COMMENT 'List or description of documents required for the filing.',
    `responsible_party` STRING COMMENT 'Internal team or function accountable for meeting the obligation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the record.',
    CONSTRAINT pk_regulatory_calendar PRIMARY KEY(`regulatory_calendar_id`)
) COMMENT 'Authoritative register of every compliance obligation the pension fund must fulfil and its scheduled due dates across all jurisdictions and regulations. Captures obligation name, obligation type (regulatory reporting, disclosure, certification, record';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`rule` (
    `rule_id` BIGINT COMMENT 'Unique identifier for the compliance monitoring rule.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Compliance rules are mandated by specific regulatory authorities. Linking rule to regulatory_authority enables tracking which authority requires each rule.',
    `action` STRING COMMENT 'Action taken when the rule condition is met.. Valid values are `alert|block|flag|report|audit|notify`',
    `approval_by` BIGINT COMMENT 'User ID of the approver.',
    `approval_date` DATE COMMENT 'Date the rule was approved.',
    `approval_status` STRING COMMENT 'Approval state of the rule definition.. Valid values are `approved|pending|rejected`',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the rule was first created.',
    `criteria` STRING COMMENT 'JSON or expression defining the rule logic and thresholds.',
    `rule_description` STRING COMMENT 'Detailed description of the rule logic and purpose.',
    `document_reference` STRING COMMENT 'Link or identifier to the rule documentation.',
    `effective_from` DATE COMMENT 'Date the rule becomes active.',
    `effective_until` DATE COMMENT 'Date the rule ceases to be active; null for open‑ended rules.',
    `frequency` STRING COMMENT 'How often the rule is evaluated.. Valid values are `daily|weekly|monthly|quarterly|annually`',
    `is_active` BOOLEAN COMMENT 'Indicates if the rule is currently active.',
    `is_archived` BOOLEAN COMMENT 'True if the rule has been archived and is no longer active.',
    `is_automated` BOOLEAN COMMENT 'True if the rule is executed automatically by the system.',
    `is_compliance` BOOLEAN COMMENT 'True if the rule enforces compliance obligations.',
    `is_confidential` BOOLEAN COMMENT 'True if the rule contains confidential business logic.',
    `is_custom` BOOLEAN COMMENT 'True if the rule was created by a user or business unit.',
    `is_default` BOOLEAN COMMENT 'True if the rule is a system default rule.',
    `is_external` BOOLEAN COMMENT 'True if the rule originates from an external vendor or regulator.',
    `is_internal` BOOLEAN COMMENT 'True if the rule is defined internally by the firm.',
    `is_legal` BOOLEAN COMMENT 'True if the rule is derived from legal requirements.',
    `is_pii` BOOLEAN COMMENT 'True if the rule processes personally identifiable information.',
    `is_policy` BOOLEAN COMMENT 'True if the rule is based on internal policy.',
    `is_procedure` BOOLEAN COMMENT 'True if the rule defines a procedural step.',
    `is_process` BOOLEAN COMMENT 'True if the rule is part of a larger process.',
    `is_public` BOOLEAN COMMENT 'True if the rule is publicly disclosed.',
    `is_regulatory` BOOLEAN COMMENT 'True if the rule is mandated by a regulator.',
    `is_restricted` BOOLEAN COMMENT 'True if the rule is restricted to certain users.',
    `is_sensitive` BOOLEAN COMMENT 'True if the rule handles sensitive data or processes.',
    `is_template` BOOLEAN COMMENT 'True if the rule is a reusable template.',
    `is_test` BOOLEAN COMMENT 'True if the rule is a test or sandbox rule.',
    `is_workflow` BOOLEAN COMMENT 'True if the rule is part of a workflow.',
    `last_run_at` TIMESTAMP COMMENT 'Timestamp of the last execution of the rule.',
    `rule_name` STRING COMMENT 'Human‑readable name of the rule used in reporting and dashboards.',
    `next_run_at` TIMESTAMP COMMENT 'Scheduled timestamp for the next rule execution.',
    `owner` STRING COMMENT 'Business unit or department responsible for the rule.',
    `priority` STRING COMMENT 'Priority level for rule execution and escalation.. Valid values are `high|medium|low`',
    `rule_status` STRING COMMENT 'Current lifecycle state of the rule.. Valid values are `active|inactive|draft|pending|archived`',
    `rule_type` STRING COMMENT 'Category of the rule such as KYC, AML, ESG, Trade Reporting, Regulatory Filing, Risk Management, Governance, or Asset Allocation. [ENUM-REF-CANDIDATE: KYC|AML|ESG|Trade Reporting|Regulatory Filing|Risk Management|Governance|Asset Allocation] ',
    `scope` STRING COMMENT 'Business area the rule applies to such as portfolio, trade, counterparty, or beneficiary. [ENUM-REF-CANDIDATE: portfolio|trade|counterparty|beneficiary|investment|risk|liquidity|treasury|regulatory] ',
    `severity` STRING COMMENT 'Severity of the rule violation.. Valid values are `critical|major|minor`',
    `updated_at` TIMESTAMP COMMENT 'Timestamp of the most recent rule update.',
    `version` STRING COMMENT 'Version identifier for the rule definition.',
    `created_by` BIGINT COMMENT 'User ID of the person who created the rule.',
    CONSTRAINT pk_rule PRIMARY KEY(`rule_id`)
) COMMENT 'Master record defining each compliance monitoring rule configured in the rules engine (sourced from BlackRock Aladdin and Charles River IMS compliance modules).';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`rule_breach` (
    `rule_breach_id` BIGINT COMMENT 'Unique identifier for the compliance rule breach record.',
    `actor_id` BIGINT COMMENT 'Identifier of the senior stakeholder to whom the breach was escalated.',
    `blotter_id` BIGINT COMMENT 'Foreign key linking to trade.blotter. Business justification: Compliance breach investigation requires tracing to the specific trade that violated rules. Pension funds must document which trades triggered UCITS/regulatory breaches for regulatory exams and',
    `employee_id` BIGINT COMMENT 'Identifier of the internal party accountable for investigating the breach.',
    `infra_asset_id` BIGINT COMMENT 'Foreign key linking to infrastructure.infra_asset. Business justification: Each rule breach is tied to an asset for breach tracking.',
    `instrument_id` BIGINT COMMENT 'Identifier of the investment asset or portfolio component affected by the breach.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Link rule_breach to regulatory_authority to capture the authority overseeing the breach. Redundant authority attributes removed.',
    `resolved_by_employee_id` BIGINT COMMENT 'Identifier of the individual or team that closed the breach.',
    `rule_id` BIGINT COMMENT 'Identifier of the compliance rule that was violated.',
    `settlement_fail_id` BIGINT COMMENT 'Foreign key linking to trade.settlement_fail. Business justification: CSDR settlement discipline regime requires tracking settlement fails that trigger penalty breaches.',
    `amount_adjustment` DECIMAL(18,2) COMMENT 'Adjustments (e.g., recoveries, offsets) applied to the gross impact.',
    `amount_gross` DECIMAL(18,2) COMMENT 'Estimated gross monetary impact of the breach before adjustments.',
    `amount_net` DECIMAL(18,2) COMMENT 'Net monetary impact after adjustments, representing the final loss or penalty.',
    `breach_description` STRING COMMENT 'Detailed narrative of the compliance violation, including context and observed behavior.',
    `breach_number` STRING COMMENT 'Human‑readable reference number assigned to the breach for tracking and reporting.',
    `breach_timestamp` TIMESTAMP COMMENT 'Exact date‑time when the rule breach was detected by the monitoring engine.',
    `compliance_area` STRING COMMENT 'Functional compliance domain to which the breach belongs.. Valid values are `ESG|KYC|AML|Trade|Reporting|Risk`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the breach record was first created in the system.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code for the monetary impact fields.. Valid values are `^[A-Z]{3}$`',
    `data_classification` STRING COMMENT 'Classification level indicating sensitivity of the breach record.. Valid values are `restricted|confidential|internal|public`',
    `detection_method` STRING COMMENT 'Methodology used to identify the breach.. Valid values are `rule_engine|manual|audit`',
    `detection_source` STRING COMMENT 'System or platform that generated the breach detection.. Valid values are `Aladdin|Charles_River|Custom|Other`',
    `evidence_document_code` STRING COMMENT 'Reference to supporting documentation or file stored in the evidence repository.',
    `is_critical` BOOLEAN COMMENT 'Indicates whether the breach is deemed critical to the funds operations or reputation.',
    `is_repeat` BOOLEAN COMMENT 'True if the same rule has been breached previously for the same asset or party.',
    `is_reported` BOOLEAN COMMENT 'True if the breach has been reported to the relevant regulator.',
    `notes` STRING COMMENT 'Free‑form comments or observations added by investigators.',
    `penalty_amount` DECIMAL(18,2) COMMENT 'Monetary penalty imposed by the regulator, if any.',
    `penalty_currency` STRING COMMENT 'ISO currency code for the penalty amount.. Valid values are `^[A-Z]{3}$`',
    `remediation_action` STRING COMMENT 'Planned or executed corrective action to address the breach.',
    `remediation_due_date` DATE COMMENT 'Target date by which remediation must be completed.',
    `repeat_count` BIGINT COMMENT 'Number of times this specific rule has been breached within the reporting period.',
    `reporting_date` DATE COMMENT 'Date on which the breach was filed with the regulator.',
    `resolution_timestamp` TIMESTAMP COMMENT 'Date‑time when the breach was formally resolved.',
    `risk_score` DECIMAL(5,2) COMMENT 'Numeric risk score (0‑100) quantifying the breachs potential impact.',
    `rule_breach_status` STRING COMMENT 'Current lifecycle status of the breach.. Valid values are `detected|investigating|resolved|escalated|closed`',
    `severity_level` STRING COMMENT 'Risk severity assigned to the breach based on impact and likelihood.. Valid values are `low|medium|high|critical`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the breach record.',
    CONSTRAINT pk_rule_breach PRIMARY KEY(`rule_breach_id`)
) COMMENT 'Operational record of each compliance rule breach detected by the rules engine (Aladdin, Charles River IMS), tracked through its full breach-to-resolution lifecycle.';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`breach_remediation` (
    `breach_remediation_id` BIGINT COMMENT 'Unique identifier for the breach remediation record.',
    `employee_id` BIGINT COMMENT 'Identifier of the compliance officer responsible for executing the remediation.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: breach_remediation has regulatory_body as string but should link to regulatory_authority for proper normalization. regulatory_body string can be removed.',
    `regulatory_calendar_id` BIGINT COMMENT 'Link to the regulatory calendar entry governing filing deadlines for this breach.',
    `rule_breach_id` BIGINT COMMENT 'Identifier of the compliance rule breach that this remediation addresses.',
    `actual_completion_date` DATE COMMENT 'Date when remediation was actually finished.',
    `assigned_officer_name` STRING COMMENT 'Full name of the officer assigned to the remediation.',
    `breach_detection_timestamp` TIMESTAMP COMMENT 'Exact time the compliance breach was identified by the monitoring system.',
    `breach_severity` STRING COMMENT 'Severity classification of the compliance breach.. Valid values are `minor|major|critical`',
    `compliance_rule_code` STRING COMMENT 'Code identifying the specific compliance rule that was breached.',
    `compliance_rule_description` STRING COMMENT 'Human‑readable description of the breached compliance rule.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the remediation record was created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 currency code for the remediation cost.. Valid values are `USD|CAD|EUR|GBP|JPY|CHF`',
    `escalation_contact_email` STRING COMMENT 'Email address for escalation contact.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `escalation_contact_name` STRING COMMENT 'Name of the person to contact for escalation of the remediation.',
    `escalation_contact_phone` STRING COMMENT 'Phone number for escalation contact.',
    `is_waiver_requested` BOOLEAN COMMENT 'Indicates whether a regulatory waiver was requested for this breach.',
    `jurisdiction` STRING COMMENT 'ISO 3166‑1 alpha‑3 country code of the jurisdiction affected.',
    `last_updated_by` STRING COMMENT 'Name of the user or system that performed the latest update.',
    `notes` STRING COMMENT 'Additional free‑form notes captured by the officer during remediation.',
    `penalty_risk_estimate` DECIMAL(5,2) COMMENT 'Estimated financial penalty risk (as a percentage) if remediation is not completed.',
    `related_document_reference` STRING COMMENT 'Path or identifier for supporting documents attached to the remediation.',
    `remediation_action_details` STRING COMMENT 'Free‑text description of the specific steps performed during remediation.',
    `remediation_action_type` STRING COMMENT 'Category of action taken to resolve the breach.. Valid values are `trade_reversal|position_reduction|waiver_request|policy_update|other`',
    `remediation_cost_amount` DECIMAL(18,2) COMMENT 'Monetary cost incurred to execute the remediation actions.',
    `remediation_effectiveness_score` DECIMAL(5,2) COMMENT 'Post‑remediation score (0‑100) indicating how effectively the issue was resolved.',
    `remediation_plan_description` STRING COMMENT 'Narrative of the planned remediation approach and objectives.',
    `remediation_reference_code` STRING COMMENT 'Business identifier code for the remediation workflow, used for external tracking.',
    `remediation_start_timestamp` TIMESTAMP COMMENT 'Timestamp of the first remediation activity after breach detection.',
    `remediation_status` STRING COMMENT 'Current lifecycle status of the remediation effort.. Valid values are `pending|in_progress|completed|failed|waived`',
    `risk_level` STRING COMMENT 'Overall risk rating associated with the breach and its remediation.. Valid values are `low|medium|high|critical`',
    `target_remediation_date` DATE COMMENT 'Planned date by which remediation actions should be completed.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the remediation record.',
    `waiver_approval_status` STRING COMMENT 'Current approval status of the waiver request.. Valid values are `pending|approved|rejected`',
    `waiver_approval_timestamp` TIMESTAMP COMMENT 'Timestamp when the waiver request was approved or rejected.',
    `created_by` STRING COMMENT 'Name of the user or system that initially created the remediation record.',
    CONSTRAINT pk_breach_remediation PRIMARY KEY(`breach_remediation_id`)
) COMMENT 'Transactional record tracking the remediation workflow for each compliance rule breach. Captures remediation plan description, assigned officer, target remediation date, remediation actions taken (trade reversal, position reduction, waiver request, policy';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`kyc_record` (
    `kyc_record_id` BIGINT COMMENT 'System-generated unique identifier for the KYC record.',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: KYC verification is mandatory before engaging counterparties in collateral transactions.',
    `policy_document_id` BIGINT COMMENT 'Unique identifier or number on the KYC document.',
    `address_line1` STRING COMMENT 'Primary street address of the party.',
    `address_line2` STRING COMMENT 'Secondary address information (suite, unit, etc.).',
    `aml_check_status` STRING COMMENT 'Outcome of anti‑money‑laundering checks.. Valid values are `clear|match|pending|blocked`',
    `beneficial_owner_name` STRING COMMENT 'Name of the ultimate beneficial owner, if applicable.',
    `beneficial_owner_percentage` DECIMAL(5,2) COMMENT 'Ownership share held by the beneficial owner, expressed as a percentage.',
    `city` STRING COMMENT 'City component of the partys address.',
    `country_code` STRING COMMENT 'Three‑letter ISO country code for the partys location.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the KYC record was first created in the system.',
    `data_classification` STRING COMMENT 'Internal classification indicating sensitivity of the KYC data.. Valid values are `restricted|confidential|internal|public`',
    `document_expiry_date` DATE COMMENT 'Expiration date of the KYC document.',
    `document_issue_date` DATE COMMENT 'Date the KYC document was issued.',
    `document_status` STRING COMMENT 'Current validity status of the KYC document.. Valid values are `valid|expired|revoked`',
    `document_type` STRING COMMENT 'Type of identification or supporting document provided.. Valid values are `passport|driver_license|incorporation_certificate|utility_bill|other`',
    `email_address` STRING COMMENT 'Primary email address used for KYC communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `jurisdiction` STRING COMMENT 'Country or jurisdiction where the party is legally established.',
    `kyc_expiry_date` DATE COMMENT 'Date when the KYC record expires and must be refreshed.',
    `kyc_review_date` DATE COMMENT 'Date when the KYC record was last reviewed.',
    `kyc_status` STRING COMMENT 'Current lifecycle status of the KYC record.. Valid values are `pending|approved|rejected|expired|under_review`',
    `last_updated_by` STRING COMMENT 'User identifier of the analyst who performed the latest update.',
    `legal_entity_identifier` STRING COMMENT 'Global identifier for the legal entity as defined by the LEI system.',
    `notes` STRING COMMENT 'Free‑form notes captured by compliance analysts.',
    `party_name` STRING COMMENT 'Full legal name of the individual or organization subject to KYC.',
    `party_type` STRING COMMENT 'Category of the party for KYC purposes.. Valid values are `individual|organization|fund|manager|co_investor`',
    `pep_status` STRING COMMENT 'Indicates whether the party is a PEP or related.. Valid values are `none|identified|potential`',
    `phone_number` STRING COMMENT 'Primary telephone number for the party.',
    `postal_code` STRING COMMENT 'Postal or ZIP code for the partys address.',
    `registration_number` STRING COMMENT 'Official registration number assigned by the corporate registry.',
    `risk_rating` STRING COMMENT 'Qualitative risk rating derived from the risk score.. Valid values are `low|medium|high|critical`',
    `risk_score` BIGINT COMMENT 'Numerical risk score (0‑100) assigned after KYC assessment.',
    `sanctions_screening_status` STRING COMMENT 'Result of sanctions list screening for the party.. Valid values are `clear|match|pending|blocked`',
    `source_of_funds` STRING COMMENT 'Narrative description of the origin of the partys funds.',
    `state_province` STRING COMMENT 'State or province component of the partys address.',
    `tax_identifier` STRING COMMENT 'Government‑issued tax identification number for the party.',
    `trade_name` STRING COMMENT 'Operating name or DBA (Doing Business As) used for the party.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the KYC record.',
    `website_url` STRING COMMENT 'Public website associated with the party.',
    CONSTRAINT pk_kyc_record PRIMARY KEY(`kyc_record_id`)
) COMMENT 'Master KYC (Know Your Customer) and AML (Anti-Money Laundering) compliance record for each counterparty, external manager, co-investor, or institutional relationship managed by the pension fund.';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`sanctions_screening` (
    `sanctions_screening_id` BIGINT COMMENT 'Unique identifier for the sanctions screening event.',
    `counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: Sanctions screenings are performed on counterparties before collateral transactions.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the screening record was first created.',
    `is_false_positive` BOOLEAN COMMENT 'Indicates whether a match was later determined to be a false positive.',
    `match_detail` STRING COMMENT 'Free‑text description of any matches found.',
    `notes` STRING COMMENT 'Free‑form comments or observations about the screening.',
    `performed_by` STRING COMMENT 'User or system that executed the screening.',
    `record_status` STRING COMMENT 'Current lifecycle status of the screening record.. Valid values are `active|archived|deleted`',
    `remediation_action` STRING COMMENT 'Planned corrective action for a positive match.. Valid values are `review|escalate|reject|accept`',
    `remediation_due_date` DATE COMMENT 'Date by which remediation must be completed.',
    `risk_score` DECIMAL(5,2) COMMENT 'Numeric risk rating (0‑100) assigned to the screening result.',
    `screened_entity_lei` STRING COMMENT 'Global identifier for the screened legal entity.',
    `screened_entity_name` STRING COMMENT 'Legal name of the screened party (individual or organization).',
    `screened_entity_type` STRING COMMENT 'Category of the screened party.. Valid values are `counterparty|issuer|manager|individual|other`',
    `screening_list` STRING COMMENT 'Regulatory or watch‑list used for the screening.. Valid values are `OFAC|UN|EU|UK_HMT|FATF|CUSTOM`',
    `screening_result` STRING COMMENT 'Outcome of the screening process.. Valid values are `clear|potential_match|match|false_positive|blocked`',
    `screening_timestamp` TIMESTAMP COMMENT 'Date and time when the screening was performed.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the screening record.',
    CONSTRAINT pk_sanctions_screening PRIMARY KEY(`sanctions_screening_id`)
) COMMENT 'Transactional record of each sanctions and PEP screening event conducted against a counterparty, issuer, manager, or individual. Captures screening date, screened entity name and LEI, screening list(s) applied (OFAC, UN, EU, HMT), screening result (clear';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`trade_report` (
    `trade_report_id` BIGINT COMMENT 'System-generated unique identifier for each trade report record.',
    `broker_id` BIGINT COMMENT 'Identifier of the broker or intermediary facilitating the trade.',
    `execution_id` BIGINT COMMENT 'Unique identifier for the execution event provided by the venue.',
    `fx_forward_id` BIGINT COMMENT 'Foreign key linking to treasury.fx_forward. Business justification: EMIR/MiFID regulatory reporting requires pension funds to report OTC FX forward trades to trade repositories.',
    `fx_swap_id` BIGINT COMMENT 'Foreign key linking to treasury.fx_swap. Business justification: FX swaps are reportable OTC derivatives under EMIR/MiFID. Pension fund compliance teams must link trade reports to specific fx_swap transactions for regulatory submission and reconciliation',
    `fx_trade_id` BIGINT COMMENT 'Foreign key linking to trade.fx_trade. Business justification: EMIR/MiFID II mandate FX derivative reporting. Pension funds executing FX hedges must link trades directly to regulatory reports for transaction reporting compliance.',
    `order_id` BIGINT COMMENT 'Identifier of the order that generated the trade.',
    `otc_derivative_id` BIGINT COMMENT 'Foreign key linking to trade.otc_derivative. Business justification: EMIR requires OTC derivative trade reporting to trade repositories. Pension funds must link each OTC trade to its regulatory report for compliance audit trail.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: trade_report is submitted under specific regulatory regimes (EMIR, MiFID II). Should link to the governing regulatory authority.',
    `sfdr_disclosure_id` BIGINT COMMENT 'Foreign key linking to compliance.sfdr_disclosure. Business justification: Trade report belongs to a specific SFDR disclosure period; adding a child-to-parent FK aligns with standard 1:N modeling.',
    `asset_class` STRING COMMENT 'Broad classification of the instrument (e.g., Equity, Fixed Income, Real Estate).',
    `commission` DECIMAL(20,2) COMMENT 'Commission charged by the broker for executing the trade.',
    `compliance_status` STRING COMMENT 'Result of compliance validation for the trade report.. Valid values are `compliant|non_compliant|pending`',
    `counterparty_lei` STRING COMMENT 'Global identifier for the counterparty to the trade, as defined by the LEI system.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the trade report record was first created in the lakehouse.',
    `data_classification` STRING COMMENT 'Internal classification of the report data (e.g., public, internal, confidential, restricted).',
    `emir_reportable` BOOLEAN COMMENT 'Indicates whether the trade falls under EMIR reporting obligations.',
    `execution_venue` STRING COMMENT 'Market or platform where the trade was executed.',
    `fee_amount` DECIMAL(20,2) COMMENT 'Total fees and commissions charged on the trade.',
    `gross_amount` DECIMAL(20,2) COMMENT 'Total monetary value of the trade before fees and adjustments.',
    `instrument_isin` STRING COMMENT 'Standardized security identifier for the traded instrument.',
    `lifecycle_status` STRING COMMENT 'Current processing state of the trade report within the compliance workflow.. Valid values are `draft|pending|submitted|accepted|rejected|cancelled`',
    `mifid_reportable` BOOLEAN COMMENT 'Indicates whether the trade falls under MiFID II reporting obligations.',
    `net_amount` DECIMAL(20,2) COMMENT 'Net monetary value after subtracting fees from the gross amount.',
    `notes` STRING COMMENT 'Free‑form comments or observations related to the trade report.',
    `penalty_risk_level` STRING COMMENT 'Risk level for potential regulatory penalties if the report is non‑compliant.. Valid values are `low|medium|high`',
    `price` DECIMAL(20,6) COMMENT 'Price per unit at which the trade was executed.',
    `quantity` DECIMAL(20,6) COMMENT 'Number of units or shares traded.',
    `regulatory_status` STRING COMMENT 'Current status of the report with the regulator.. Valid values are `submitted|accepted|rejected`',
    `report_reference` STRING COMMENT 'External reference number assigned by the reporting regime or internal system.',
    `reporting_regime` STRING COMMENT 'Regulatory framework under which the trade is reported (EMIR or MiFID II).. Valid values are `EMIR|MiFIDII`',
    `reporting_timestamp` TIMESTAMP COMMENT 'Date and time when the trade report was submitted to the repository.',
    `settlement_amount` DECIMAL(20,2) COMMENT 'Monetary amount settled, typically matching net_amount in cash trades.',
    `settlement_date` DATE COMMENT 'Date on which cash and securities are exchanged.',
    `trade_currency` STRING COMMENT 'ISO 4217 currency code of the trade price.',
    `trade_repository` STRING COMMENT 'Name of the trade repository where the report is submitted (e.g., DTCC, REGIS-TR).',
    `trade_timestamp` TIMESTAMP COMMENT 'Exact date and time when the trade was executed in the market.',
    `trade_type` STRING COMMENT 'Classification of the transaction (e.g., Buy, Sell, Swap).. Valid values are `Buy|Sell|Swap|Option|Future|Forward`',
    `unique_trade_identifier` STRING COMMENT 'Globally unique identifier for the trade as required by EMIR/MiFID II.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the trade report record.',
    CONSTRAINT pk_trade_report PRIMARY KEY(`trade_report_id`)
) COMMENT 'Transactional record of each trade report submitted to a trade repository under EMIR or MiFID II transaction reporting obligations. Captures trade report reference, reporting regime (EMIR, MiFID II), trade repository (DTCC, REGIS-TR), UTI (Unique Trade';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`lei_record` (
    `lei_record_id` BIGINT COMMENT 'Unique identifier for the lei_record record.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the lei_record was first created in the system.',
    `entity_address` STRING COMMENT 'Physical address of the entity.',
    `entity_city` STRING COMMENT 'City where the entity is located.',
    `entity_classification` STRING COMMENT 'Classification of the entitys role in the organization.. Valid values are `Investor|Counterparty|Custodian|Regulator|Other`',
    `entity_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the entity. [ENUM-REF-CANDIDATE: USA|CAN|GBR|FRA|DEU|CHN|JPN|AUS|IND|BRA — 10 candidates stripped; promote to reference product]',
    `entity_description` STRING COMMENT 'Brief description of the entitys purpose or nature.',
    `entity_email` STRING COMMENT 'Primary email address for the entity.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `entity_fax` STRING COMMENT 'Primary fax number for the entity.. Valid values are `^+?[1-9]d{1,14}$`',
    `entity_name` STRING COMMENT 'Human-readable name of the legal entity.',
    `entity_phone` STRING COMMENT 'Primary phone number for the entity.. Valid values are `^+?[1-9]d{1,14}$`',
    `entity_postal_code` STRING COMMENT 'Postal code of the entitys address.',
    `entity_state` STRING COMMENT 'State or province of the entitys location.',
    `entity_status` STRING COMMENT 'Current lifecycle status of the entity.. Valid values are `Active|Inactive|Pending|Terminated|Suspended`',
    `entity_subtype` STRING COMMENT 'Specific subtype of the entity within its primary type.. Valid values are `Private Equity SPV|Real Estate Fund|Infrastructure Fund|Credit Fund|Equity Fund|Other`',
    `entity_type` STRING COMMENT 'Primary category of the entity (e.g., Fund, SPV, Counterparty).. Valid values are `Fund|SPV|Counterparty|Subsidiary`',
    `entity_website` STRING COMMENT 'Official website URL of the entity.',
    `lei` STRING COMMENT '20-character alphanumeric code that uniquely identifies a legal entity.. Valid values are `^[A-Z0-9]{20}$`',
    `lei_expiry_date` DATE COMMENT 'Date the LEI expires or is set to expire.',
    `lei_issue_date` DATE COMMENT 'Date the LEI was issued.',
    `lei_last_updated` TIMESTAMP COMMENT 'Timestamp of the last update to the LEI record.',
    `lei_source_system` STRING COMMENT 'Name of the system that provided the LEI data.',
    `lei_source_system_active_flag` BOOLEAN COMMENT 'Flag indicating if the source system record is active.',
    `lei_source_system_code` STRING COMMENT 'Identifier of the source system record for the LEI.',
    `lei_source_system_created` TIMESTAMP COMMENT 'Timestamp when the source system record was created.',
    `lei_source_system_deleted` TIMESTAMP COMMENT 'Timestamp when the source system record was deleted, if applicable.',
    `lei_source_system_description` STRING COMMENT 'Detailed description of the source system.',
    `lei_source_system_name` STRING COMMENT 'Human-readable name of the source system.',
    `lei_source_system_notes` STRING COMMENT 'Additional notes about the source system entry.',
    `lei_source_system_reference` STRING COMMENT 'Reference or identifier used within the source system for the LEI.',
    `lei_source_system_remarks` STRING COMMENT 'Free-text remarks about the source system record.',
    `lei_source_system_timestamp` TIMESTAMP COMMENT 'Timestamp when the source system recorded the LEI data.',
    `lei_source_system_type` STRING COMMENT 'Type of source system (e.g., ERP, CRM, Data Lake). [ENUM-REF-CANDIDATE: SimCorp|BlackRock|Bloomberg|StateStreet|eFront|DealCloud|MSCI|CharlesRiver|Oracle|SAP|Diligent|Preqin|PitchBook|FactSet — promote to reference product]',
    `lei_source_system_updated` TIMESTAMP COMMENT 'Timestamp when the source system record was last updated.',
    `lei_source_system_version` STRING COMMENT 'Version of the source system that provided the LEI.',
    `lei_status` STRING COMMENT 'Current status of the LEI registration.. Valid values are `Active|Inactive|Pending|Revoked`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the lei_record.',
    CONSTRAINT pk_lei_record PRIMARY KEY(`lei_record_id`)
) COMMENT 'Master record for each Legal Entity Identifier (LEI) managed or tracked by the pension fund, covering the fund itself, its subsidiaries, SPVs, and key counterparties.';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`ic_governance_record` (
    `ic_governance_record_id` BIGINT COMMENT 'System-generated unique identifier for the Investment Committee governance record.',
    `policy_document_id` BIGINT COMMENT 'Reference to the stored minutes document for the meeting.',
    `action_items` STRING COMMENT 'List of follow‑up actions resulting from meeting decisions.',
    `agenda_items` STRING COMMENT 'Structured list of agenda items discussed during the meeting.',
    `attendees_count` BIGINT COMMENT 'Number of participants present at the meeting.',
    `attendees_roles` STRING COMMENT 'Roles represented among attendees (enumerated).. Valid values are `chair|member|observer|guest|secretary|advisor`',
    `compliance_review_date` DATE COMMENT 'Date when the compliance review was completed.',
    `compliance_review_status` STRING COMMENT 'Status of the compliance review for the meeting record.. Valid values are `pending|approved|rejected`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the governance record was first created.',
    `decisions_made` STRING COMMENT 'Summary of formal decisions approved by the Investment Committee.',
    `end_time` TIMESTAMP COMMENT 'Exact timestamp when the meeting concluded.',
    `is_confidential` BOOLEAN COMMENT 'Indicates whether the meeting record contains confidential information.',
    `location` STRING COMMENT 'Physical location or venue of the meeting (if applicable).',
    `meeting_date` DATE COMMENT 'Calendar date on which the meeting took place.',
    `meeting_number` STRING COMMENT 'Business identifier assigned to the meeting (e.g., sequential number or code).',
    `meeting_status` STRING COMMENT 'Current lifecycle status of the meeting.. Valid values are `scheduled|completed|cancelled|postponed`',
    `meeting_title` STRING COMMENT 'Descriptive title of the Investment Committee meeting.',
    `meeting_type` STRING COMMENT 'Category of the meeting: regular IC, special IC, sub‑committee, or ad‑hoc session.. Valid values are `regular|special|subcommittee|ad_hoc`',
    `notes` STRING COMMENT 'Free‑form notes or comments captured by the recorder.',
    `quorum_status` STRING COMMENT 'Indicates whether the required quorum was achieved.. Valid values are `met|not_met|partial`',
    `regulatory_filing_reference` STRING COMMENT 'Reference number linking the meeting to a specific regulatory filing obligation.',
    `risk_assessment_score` DECIMAL(5,2) COMMENT 'Numeric risk score assigned to the meeting outcomes (e.g., based on ESG or governance risk models).',
    `start_time` TIMESTAMP COMMENT 'Exact timestamp when the meeting started.',
    `updated_by` STRING COMMENT 'User identifier of the person who last modified the record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the governance record.',
    `virtual_meeting_link` STRING COMMENT 'URL or access link for virtual attendance.',
    `created_by` STRING COMMENT 'User identifier of the person who created the record.',
    CONSTRAINT pk_ic_governance_record PRIMARY KEY(`ic_governance_record_id`)
) COMMENT 'Master record for each Investment Committee (IC) governance session managed via Diligent/BoardEffect. Captures IC meeting date, meeting type (regular IC, special IC, sub-committee), quorum status, agenda items, attendees and roles, decisions made';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`ic_decision` (
    `ic_decision_id` BIGINT COMMENT 'Unique system-generated identifier for each Investment Committee decision.',
    `fund_id` BIGINT COMMENT 'Identifier of the fund or investment vehicle associated with the decision.',
    `ic_governance_record_id` BIGINT COMMENT 'Foreign key linking to compliance.ic_governance_record. Business justification: ic_decision is a decision made during an IC governance session. Each decision belongs to one governance session.',
    `infra_asset_id` BIGINT COMMENT 'Identifier of the specific asset or security affected by the decision.',
    `attached_document_reference` STRING COMMENT 'Link or identifier to supporting documents (e.g., PDFs, presentations).',
    `committee_code` BIGINT COMMENT 'Identifier of the Investment Committee session during which the decision was made.',
    `compliance_status` STRING COMMENT 'Result of compliance checks related to the decision.. Valid values are `compliant|non_compliant|pending_review`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the decision record was first created in the system.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code for the approved investment amount.. Valid values are `USD|CAD|EUR|GBP|CHF|JPY`',
    `decision_maker` STRING COMMENT 'Name of the individual who recorded or signed off the decision (e.g., Chairperson).',
    `decision_maker_role` STRING COMMENT 'Role of the person who authored or signed the decision.. Valid values are `chair|member|observer`',
    `decision_number` STRING COMMENT 'Human‑readable identifier assigned to the decision (e.g., D‑2024‑0012).',
    `decision_status` STRING COMMENT 'Current workflow status of the decision record.. Valid values are `pending|approved|rejected|executed|closed`',
    `decision_timestamp` TIMESTAMP COMMENT 'Exact date‑time when the Investment Committee formally recorded the decision.',
    `decision_type` STRING COMMENT 'Category of the decision made by the Investment Committee.. Valid values are `approval|rejection|revision|policy_exception`',
    `effective_date` DATE COMMENT 'Date on which the decision becomes operationally effective.',
    `expiration_date` DATE COMMENT 'Date when the decision ceases to be effective, if applicable.',
    `filing_deadline` DATE COMMENT 'Latest date by which required regulatory filings must be submitted.',
    `investment_amount_approved` DECIMAL(20,2) COMMENT 'Monetary amount approved by the Committee for the investment or commitment.',
    `investment_vehicle_type` STRING COMMENT 'Asset class or vehicle to which the decision applies.. Valid values are `public_equity|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `mandate_change_flag` BOOLEAN COMMENT 'True if the decision results in a change to the investment mandate.',
    `notes` STRING COMMENT 'Additional comments, rationale, or observations recorded by the Committee.',
    `policy_exception_flag` BOOLEAN COMMENT 'True if the decision grants an exception to existing investment policy.',
    `regulatory_filing_required` BOOLEAN COMMENT 'Indicates whether the decision triggers a regulatory filing obligation.',
    `risk_rating_after` STRING COMMENT 'Risk rating after the decision is applied.. Valid values are `low|medium|high`',
    `risk_rating_before` STRING COMMENT 'Risk rating of the investment or portfolio before the decision.. Valid values are `low|medium|high`',
    `subject` STRING COMMENT 'Brief description of what the decision addresses (e.g., new fund approval, mandate amendment).',
    `updated_by` STRING COMMENT 'User identifier of the person who last modified the decision record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the decision record.',
    `votes_abstain` BIGINT COMMENT 'Number of Committee members who abstained from voting.',
    `votes_against` BIGINT COMMENT 'Number of Committee members who voted against.',
    `votes_for` BIGINT COMMENT 'Number of Committee members who voted in favor.',
    `voting_outcome` STRING COMMENT 'Result of the Committee vote on the decision.. Valid values are `unanimous|majority|split`',
    `created_by` STRING COMMENT 'User identifier of the person who initially entered the decision record.',
    CONSTRAINT pk_ic_decision PRIMARY KEY(`ic_decision_id`)
) COMMENT 'Transactional record of each formal Investment Committee decision made during an IC governance session. Captures decision date, IC session reference, decision subject (investment approval, mandate change, SAA revision, policy exception), decision type';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`conflict_of_interest` (
    `conflict_of_interest_id` BIGINT COMMENT 'System-generated unique identifier for each conflict of interest record.',
    `declarant_employee_id` BIGINT COMMENT 'Internal employee identifier assigned to the declarant.',
    `opportunity_id` BIGINT COMMENT 'Foreign key linking to deal.opportunity. Business justification: Conflicts of interest must be linked to specific deal opportunities for compliance screening. The conflict_related_deal attribute suggests this relationship exists denormalized.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: conflict_of_interest has regulatory_body as string but should link to regulatory_authority for proper normalization. regulatory_body string can be removed.',
    `conflict_audit_trail` STRING COMMENT 'JSON‑encoded log of changes made to the conflict record.',
    `conflict_category` STRING COMMENT 'High‑level domain to which the conflict belongs.. Valid values are `financial|operational|governance|legal|reputational|other`',
    `conflict_confidentiality_level` STRING COMMENT 'Level of confidentiality required for the conflict record.. Valid values are `high|medium|low`',
    `conflict_description` STRING COMMENT 'Narrative explanation of the conflict circumstances.',
    `conflict_end_date` DATE COMMENT 'Date when the conflict ceased or was resolved (nullable).',
    `conflict_esg_impact` STRING COMMENT 'Assessment of how the conflict affects ESG considerations.',
    `conflict_identifier` STRING COMMENT 'External reference code used for regulatory filings or audit trails.',
    `conflict_last_reviewed_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent review activity.',
    `conflict_of_interest_status` STRING COMMENT 'Current processing state of the conflict record.. Valid values are `pending|reviewed|approved|rejected|resolved|closed`',
    `conflict_publication_date` DATE COMMENT 'Date the conflict information was made public or disclosed to stakeholders.',
    `conflict_related_asset` STRING COMMENT 'Identifier of the asset (e.g., security, property) involved in the conflict.',
    `conflict_related_fund` STRING COMMENT 'Identifier of the fund potentially impacted by the conflict.',
    `conflict_resolution_action` STRING COMMENT 'Action taken to resolve or mitigate the conflict.',
    `conflict_resolution_by` STRING COMMENT 'Name of the individual who executed the resolution action.',
    `conflict_resolution_comments` STRING COMMENT 'Additional notes about how the conflict was resolved.',
    `conflict_review_comments` STRING COMMENT 'Comments recorded during the conflict review.',
    `conflict_review_date` DATE COMMENT 'Date of the most recent formal review of the conflict.',
    `conflict_reviewed_by` STRING COMMENT 'Name of the compliance officer or committee member who reviewed the conflict.',
    `conflict_risk_assessment_date` DATE COMMENT 'Date the risk score was calculated.',
    `conflict_risk_score` DECIMAL(5,2) COMMENT 'Quantitative risk score (0‑100) assigned after assessment.',
    `conflict_start_date` DATE COMMENT 'Date when the underlying conflict situation began.',
    `conflict_status_reason` STRING COMMENT 'Explanation for the current status value.',
    `conflict_title` STRING COMMENT 'Brief title summarizing the conflict (e.g., "Family Investment in Real Estate").',
    `conflict_type` STRING COMMENT 'Category describing the nature of the conflict.. Valid values are `personal_investment|related_party|board_membership|prior_employment|family_relationship|other`',
    `created_timestamp` TIMESTAMP COMMENT 'Date‑time when the conflict record was first created in the system.',
    `data_classification` STRING COMMENT 'Enterprise data classification level for the record.. Valid values are `restricted|confidential|internal|public`',
    `declarant_name` STRING COMMENT 'Legal full name of the individual declaring the conflict.',
    `declarant_role` STRING COMMENT 'Job function or position of the declarant within the pension fund.. Valid values are `investment_analyst|investment_committee_member|portfolio_manager|risk_officer|compliance_officer|other`',
    `disclosure_date` DATE COMMENT 'Date the conflict was formally disclosed to the compliance function.',
    `effective_from` DATE COMMENT 'Date from which the conflict declaration is considered effective.',
    `effective_until` DATE COMMENT 'Date after which the conflict declaration is no longer in effect (nullable).',
    `is_mandatory` BOOLEAN COMMENT 'Indicates if the conflict disclosure is mandatory under policy.',
    `mitigation_action` STRING COMMENT 'Planned or executed action to mitigate the conflict.',
    `notes` STRING COMMENT 'Free‑form comments or observations related to the conflict.',
    `related_party_identifier` STRING COMMENT 'Unique identifier (e.g., LEI, CUSIP) for the related party.',
    `related_party_name` STRING COMMENT 'Name of the individual or entity with which the conflict exists.',
    `related_party_relationship` STRING COMMENT 'Nature of the relationship between declarant and related party.. Valid values are `family|business|employment|board|other`',
    `reporting_status` STRING COMMENT 'Whether the conflict has been reported to the relevant regulator or internal board.. Valid values are `not_reported|reported|escalated`',
    `resolution_date` DATE COMMENT 'Date the conflict was formally resolved or mitigated.',
    `severity_level` STRING COMMENT 'Risk severity assigned to the conflict after assessment.. Valid values are `low|medium|high|critical`',
    `updated_timestamp` TIMESTAMP COMMENT 'Date‑time of the most recent modification to the conflict record.',
    CONSTRAINT pk_conflict_of_interest PRIMARY KEY(`conflict_of_interest_id`)
) COMMENT 'Master record of declared conflicts of interest by investment professionals, committee members, and officers of the pension fund. Captures declarant name and role, conflict type (personal investment, related party, board membership, prior employment)';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`policy_document` (
    `policy_document_id` BIGINT COMMENT 'Unique system-generated identifier for each policy document.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Link policy_document to regulatory_authority to capture the authority overseeing the policy. Redundant policy attributes removed.',
    `approval_date` DATE COMMENT 'Date the policy was formally approved.',
    `approved_by` STRING COMMENT 'Name of the person or committee that approved the policy.',
    `author_name` STRING COMMENT 'Name of the individual who authored the policy.',
    `policy_document_category` STRING COMMENT 'Higher‑level grouping of policies (e.g., operational, regulatory, strategic).',
    `checksum` STRING COMMENT 'SHA‑256 checksum for integrity verification of the document file.. Valid values are `^[A-Fa-f0-9]{64}$`',
    `compliance_area` STRING COMMENT 'Specific compliance domain addressed by the policy.. Valid values are `investment|operational|legal|risk|esg`',
    `confidentiality_level` STRING COMMENT 'Data classification level assigned to the policy document.. Valid values are `restricted|confidential|internal|public`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the policy record was first created in the system.',
    `policy_document_description` STRING COMMENT 'Full textual description outlining the purpose and scope of the policy.',
    `document_format` STRING COMMENT 'File format of the stored policy document.. Valid values are `pdf|docx|html`',
    `effective_date` DATE COMMENT 'Date on which the policy becomes effective.',
    `expiration_date` DATE COMMENT 'Date on which the policy expires or is superseded, if applicable.',
    `file_path` STRING COMMENT 'Location path of the policy document in the lakehouse storage.',
    `file_size_bytes` BIGINT COMMENT 'Size of the document file in bytes.',
    `is_mandatory` BOOLEAN COMMENT 'Flag indicating whether compliance with the policy is mandatory.',
    `last_reviewed_timestamp` TIMESTAMP COMMENT 'Timestamp when the policy was last reviewed.',
    `owner_department` STRING COMMENT 'Business department responsible for the policy.',
    `policy_document_status` STRING COMMENT 'Current lifecycle state of the policy.. Valid values are `draft|active|suspended|retired|archived`',
    `policy_owner_contact` STRING COMMENT 'Email address of the primary owner responsible for the policy.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `policy_type` STRING COMMENT 'Category of policy indicating its functional area.. Valid values are `investment|aml|esg|trading|risk|governance`',
    `retention_period_days` BIGINT COMMENT 'Number of days the policy document must be retained for compliance purposes.',
    `review_date` DATE COMMENT 'Date of the most recent policy review.',
    `reviewed_by` STRING COMMENT 'Name of the individual who performed the latest review.',
    `revision_number` BIGINT COMMENT 'Sequential integer indicating the revision count of the policy.',
    `title` STRING COMMENT 'Descriptive title of the policy document.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the policy record.',
    `version_number` STRING COMMENT 'Version identifier following the documents revision scheme.',
    CONSTRAINT pk_policy_document PRIMARY KEY(`policy_document_id`)
) COMMENT 'Master record for each internal compliance policy, investment policy statement, or regulatory procedure document maintained by the compliance function. Captures policy name, policy category (investment policy, AML policy, ESG policy, trading policy';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`policy_exception` (
    `policy_exception_id` BIGINT COMMENT 'Unique identifier for the policy exception record.',
    `approver_employee_id` BIGINT COMMENT 'System identifier of the compliance officer or committee member who approved or rejected the exception.',
    `employee_id` BIGINT COMMENT 'System identifier of the employee or party who submitted the exception request.',
    `policy_document_id` BIGINT COMMENT 'Foreign key linking to compliance.policy_document. Business justification: policy_exception is an exception granted to a compliance policy. Each exception relates to one policy document.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Link policy_exception to regulatory_authority to capture the authority overseeing the exception. No redundant columns to remove.',
    `related_calendar_regulatory_calendar_id` BIGINT COMMENT 'Identifier linking the exception to a regulatory calendar obligation, if applicable.',
    `rule_id` BIGINT COMMENT 'Foreign key linking to compliance.rule. Business justification: Policy exceptions are granted against specific compliance rules. related_policy_rule_code can be removed as it becomes redundant with the FK to rule.',
    `approval_status` STRING COMMENT 'Result of the approval workflow for the exception.. Valid values are `approved|rejected|escalated`',
    `approval_timestamp` TIMESTAMP COMMENT 'Date‑time when the exception was formally approved or rejected.',
    `approver_name` STRING COMMENT 'Legal full name of the individual who made the approval decision.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the exception record was first created in the system.',
    `currency_code` STRING COMMENT 'Three‑letter ISO 4217 code of the currency for the monetary limit.. Valid values are `^[A-Z]{3}$`',
    `effective_from` DATE COMMENT 'Date on which the granted exception becomes effective.',
    `effective_until` DATE COMMENT 'Date on which the exception expires or is no longer valid (null for permanent).',
    `exception_number` STRING COMMENT 'Human‑readable identifier assigned to the exception request.. Valid values are `^EXC-[0-9]{6}$`',
    `exception_type` STRING COMMENT 'Indicates whether the exception is temporary or permanent.. Valid values are `temporary|permanent`',
    `expiration_timestamp` TIMESTAMP COMMENT 'Date‑time when a temporary exception automatically expires.',
    `is_active` BOOLEAN COMMENT 'Indicates whether the exception is currently active (true) or not (false).',
    `justification` STRING COMMENT 'Narrative explanation describing why the exception is required and how it aligns with business objectives.',
    `monetary_limit_amount` DECIMAL(20,2) COMMENT 'Maximum monetary amount or exposure permitted under the granted exception.',
    `notes` STRING COMMENT 'Free‑form comments or additional information captured by reviewers.',
    `policy_exception_status` STRING COMMENT 'Current lifecycle status of the exception request.. Valid values are `pending|approved|rejected|revoked|expired`',
    `request_timestamp` TIMESTAMP COMMENT 'Date‑time when the exception was originally submitted.',
    `requestor_department` STRING COMMENT 'Organizational department or business unit of the requestor.',
    `requestor_name` STRING COMMENT 'Legal full name of the individual requesting the exception.',
    `updated_by` STRING COMMENT 'User identifier of the person or process that performed the latest update.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the exception record.',
    `created_by` STRING COMMENT 'User identifier of the person or process that created the record.',
    CONSTRAINT pk_policy_exception PRIMARY KEY(`policy_exception_id`)
) COMMENT 'Transactional record of each formal exception granted to a compliance policy or investment guideline. Captures exception request date, policy or rule being excepted, exception requestor, business justification, exception type (temporary, permanent';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`regulatory_change` (
    `regulatory_change_id` BIGINT COMMENT 'Unique identifier for the regulatory change record.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Link regulatory_change to regulatory_authority to capture the authority responsible for the change. Redundant authority attributes removed.',
    `amendment_number` BIGINT COMMENT 'Sequential number of the amendment if the change is an amendment.',
    `change_type` STRING COMMENT 'Nature of the regulatory change: new regulation, amendment, or guidance.. Valid values are `new|amendment|guidance`',
    `compliance_deadline` DATE COMMENT 'Date by which required compliance actions must be completed.',
    `compliance_status` STRING COMMENT 'Current compliance status of the organization with respect to this change.. Valid values are `compliant|non_compliant|in_progress|not_applicable`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the regulatory change record was created.',
    `regulatory_change_description` STRING COMMENT 'Full textual description of the regulatory change.',
    `document_reference` STRING COMMENT 'Identifier of the supporting regulatory document or filing.',
    `effective_date` DATE COMMENT 'Date when the regulation becomes effective.',
    `expiry_date` DATE COMMENT 'Date when the regulation expires or is superseded, if applicable.',
    `impact_assessment` STRING COMMENT 'Qualitative assessment of the impact on the pension fund operations.',
    `is_external` BOOLEAN COMMENT 'True if the regulation originates from an external authority, false if internal policy.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether compliance with this change is mandatory (true) or optional (false).',
    `last_reviewed_date` DATE COMMENT 'Date when the regulatory change was last reviewed for relevance.',
    `next_review_date` DATE COMMENT 'Planned date for the next review of the regulatory change.',
    `notes` STRING COMMENT 'Additional free‑form comments or observations.',
    `penalty_risk_estimate` DECIMAL(12,2) COMMENT 'Estimated financial penalty risk if non‑compliant, in local currency.',
    `regulation_code` STRING COMMENT 'Unique code or identifier assigned by the issuing authority.',
    `regulatory_body_contact` STRING COMMENT 'Contact information for the issuing authority (e.g., email or phone).',
    `regulatory_change_status` STRING COMMENT 'Current lifecycle status of the regulatory change record.. Valid values are `draft|active|retired|pending`',
    `related_regulation_code` BIGINT COMMENT 'Identifier of a related regulatory change, if any.',
    `required_action` STRING COMMENT 'Specific actions the organization must take to comply.',
    `responsible_party` STRING COMMENT 'Individual or team accountable for implementing compliance.',
    `risk_level` STRING COMMENT 'Overall risk rating associated with non‑compliance.. Valid values are `low|medium|high|critical`',
    `severity` STRING COMMENT 'Severity of the regulatory changes impact.. Valid values are `low|medium|high|critical`',
    `title` STRING COMMENT 'Official title of the regulation or amendment.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the record.',
    CONSTRAINT pk_regulatory_change PRIMARY KEY(`regulatory_change_id`)
) COMMENT 'Master record tracking regulatory changes, new regulations, and amendments to existing rules that impact the pension funds operations. Captures regulation name, issuing authority (SEC, FCA, ESMA), change type (new regulation, amendment, guidance';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`regulatory_exam` (
    `regulatory_exam_id` BIGINT COMMENT 'Unique system-generated identifier for the regulatory examination record.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Link regulatory_exam to regulatory_authority to capture the authority conducting the exam. Redundant authority attributes removed.',
    `compliance_status` STRING COMMENT 'Overall compliance determination after the examination.. Valid values are `compliant|non_compliant|exempt`',
    `corrective_action_deadline` DATE COMMENT 'Date by which all required corrective actions must be completed.',
    `corrective_action_required` BOOLEAN COMMENT 'Indicates whether the regulator mandated corrective actions.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the examination record was first created in the system.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code for any monetary amounts.. Valid values are `^[A-Z]{3}$`',
    `documentation_url` STRING COMMENT 'Link to the full examination report or supporting documents stored in the DMS.',
    `exam_number` STRING COMMENT 'External reference number assigned by the regulator or internal tracking system.',
    `exam_outcome` STRING COMMENT 'Result of the examination as determined by the regulator.. Valid values are `pass|fail|conditional|pending`',
    `exam_timestamp` TIMESTAMP COMMENT 'Date and time when the examination was conducted or officially recorded.',
    `exam_type` STRING COMMENT 'Category of the examination, indicating its purpose or scope.. Valid values are `initial|routine|special|follow_up`',
    `examiner_email` STRING COMMENT 'Email address for the examiner or examination team contact.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `examiner_name` STRING COMMENT 'Name of the primary individual or team conducting the examination.',
    `findings_summary` STRING COMMENT 'High‑level narrative of key findings and observations from the exam.',
    `notes` STRING COMMENT 'Additional free‑form comments or observations captured by compliance staff.',
    `penalty_amount` DECIMAL(18,2) COMMENT 'Monetary penalty assessed by the regulator, if any.',
    `regulatory_exam_status` STRING COMMENT 'Current lifecycle state of the examination.. Valid values are `scheduled|in_progress|completed|closed|cancelled`',
    `risk_rating` STRING COMMENT 'Internal risk rating assigned based on the exam findings.. Valid values are `low|medium|high|critical`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the examination record.',
    CONSTRAINT pk_regulatory_exam PRIMARY KEY(`regulatory_exam_id`)
) COMMENT 'Master record for each regulatory examination, inspection, or supervisory review conducted by a regulatory authority (SEC, FCA, ESMA) against the pension fund.';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`exam_finding` (
    `exam_finding_id` BIGINT COMMENT 'Unique identifier for the exam finding record.',
    `actor_id` BIGINT COMMENT 'Identifier of the regulator or examiner who raised the finding.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: exam_finding has regulatory_body as string but should link to regulatory_authority for proper normalization. regulatory_body string can be removed.',
    `regulatory_exam_id` BIGINT COMMENT 'Identifier of the supervisory examination to which this finding belongs.',
    `actual_resolution_date` DATE COMMENT 'Date on which remediation was actually completed.',
    `exam_finding_category` STRING COMMENT 'High‑level classification of the finding type.. Valid values are `deficiency|observation|recommendation|violation`',
    `compliance_rule_code` STRING COMMENT 'Code of the internal compliance rule that was breached.',
    `compliance_rule_description` STRING COMMENT 'Human‑readable description of the compliance rule.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the finding record was first created.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code for any monetary amounts.. Valid values are `^[A-Z]{3}$`',
    `data_classification` STRING COMMENT 'Classification of the record for security handling (e.g., confidential, internal).',
    `exam_finding_description` STRING COMMENT 'Detailed narrative describing the observation, deficiency, or violation.',
    `due_date` DATE COMMENT 'Target date by which remediation actions should be completed.',
    `escalation_contact_email` STRING COMMENT 'Email address of the escalation contact.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `escalation_contact_name` STRING COMMENT 'Name of the person to contact for escalation of the finding.',
    `escalation_contact_phone` STRING COMMENT 'Phone number of the escalation contact.',
    `exam_finding_status` STRING COMMENT 'Current processing state of the finding.. Valid values are `open|in_progress|resolved|closed|rejected`',
    `examiner_name` STRING COMMENT 'Full legal name of the examiner who raised the finding.',
    `finding_reference` STRING COMMENT 'Unique reference code assigned to the finding by the examiner.',
    `is_waiver_requested` BOOLEAN COMMENT 'Indicates whether a waiver for the finding has been requested.',
    `jurisdiction` STRING COMMENT 'Country or jurisdiction relevant to the finding.. Valid values are `^[A-Z]{3}$`',
    `notes` STRING COMMENT 'Free‑form notes captured by the examiner or remediation team.',
    `penalty_amount` DECIMAL(18,2) COMMENT 'Monetary penalty assessed for the finding, if any.',
    `recommendation` STRING COMMENT 'Suggested corrective action or improvement recommended by the examiner.',
    `regulation_code` STRING COMMENT 'Identifier of the specific regulation or rule implicated.',
    `remediation_plan` STRING COMMENT 'Planned steps and responsibilities to remediate the finding.',
    `reported_timestamp` TIMESTAMP COMMENT 'Date‑time when the examiner recorded the finding.',
    `resolved_timestamp` TIMESTAMP COMMENT 'Date‑time when the finding was marked as resolved or closed.',
    `risk_score` BIGINT COMMENT 'Numeric risk score (0‑100) derived from severity and other risk factors.',
    `severity` STRING COMMENT 'Severity rating indicating the potential impact of the finding.. Valid values are `critical|high|medium|low|informational`',
    `sub_category` STRING COMMENT 'More granular classification within the main category.',
    `supporting_document_url` STRING COMMENT 'Link to any external document that supports the finding.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp of the most recent modification to the finding record.',
    `waiver_approval_timestamp` TIMESTAMP COMMENT 'Date‑time when a waiver request was approved or denied.',
    `waiver_status` STRING COMMENT 'Current status of any waiver request.. Valid values are `requested|approved|denied|not_applicable`',
    CONSTRAINT pk_exam_finding PRIMARY KEY(`exam_finding_id`)
) COMMENT 'Transactional record of each finding or observation raised by a regulatory examiner during a supervisory examination. Captures finding reference, examination reference, finding category (deficiency, observation, recommendation, violation), finding';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`beneficiary_disclosure` (
    `beneficiary_disclosure_id` BIGINT COMMENT 'System-generated unique identifier for each beneficiary disclosure record.',
    `beneficiary_member_id` BIGINT COMMENT 'Identifier of the individual or entity receiving the disclosure.',
    `member_id` BIGINT COMMENT 'Identifier of the individual or entity receiving the disclosure.',
    `participating_employer_id` BIGINT COMMENT 'Identifier of the sponsoring employer or contributor pool associated with the disclosure.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: beneficiary_disclosure has regulatory_body as string but should link to regulatory_authority for proper normalization. regulatory_body string can be removed.',
    `acceptance_date` DATE COMMENT 'Date the regulator accepted the disclosure as compliant.',
    `adjustment_amount` DECIMAL(15,2) COMMENT 'Any fees, taxes, or discounts applied to the gross amount.',
    `attached_document_url` STRING COMMENT 'Link to the stored disclosure document in the content repository.',
    `beneficiary_disclosure_status` STRING COMMENT 'Current processing state of the disclosure record.. Valid values are `draft|issued|rejected|withdrawn|archived`',
    `comments` STRING COMMENT 'Free‑form notes entered by compliance staff.',
    `compliance_flag` BOOLEAN COMMENT 'Indicates whether the disclosure meets all applicable compliance requirements.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the disclosure record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three‑letter code of the currency used for monetary amounts.',
    `disclosure_number` STRING COMMENT 'External reference number assigned to the disclosure by the compliance team.',
    `disclosure_type` STRING COMMENT 'Category of the disclosure (e.g., annual pension statement, benefit entitlement notice, plan amendment, SFDR disclosure).. Valid values are `annual_statement|benefit_notice|plan_amendment|sfdr|other`',
    `filing_deadline` DATE COMMENT 'Date by which the disclosure must be filed with the regulator.',
    `filing_fee_amount` DECIMAL(15,2) COMMENT 'Monetary fee charged by the regulator for processing the filing.',
    `filing_format` STRING COMMENT 'File format of the submitted disclosure document.. Valid values are `pdf|xml|json|html`',
    `filing_status` STRING COMMENT 'Current status of the filing within the regulators workflow.. Valid values are `pending|submitted|accepted|rejected|withdrawn`',
    `gross_amount` DECIMAL(15,2) COMMENT 'Total monetary amount disclosed before adjustments.',
    `is_mandatory` BOOLEAN COMMENT 'True if the disclosure is required by law or regulation; otherwise false.',
    `issuance_timestamp` TIMESTAMP COMMENT 'Date and time when the disclosure was formally issued to the beneficiary or regulator.',
    `jurisdiction` STRING COMMENT 'Three‑letter ISO country code of the regulatory jurisdiction for the disclosure.. Valid values are `USA|CAN|GBR|AUS|FRA|DEU`',
    `net_amount` DECIMAL(15,2) COMMENT 'Final monetary amount after adjustments, representing the amount disclosed to the beneficiary.',
    `rejection_date` DATE COMMENT 'Date the regulator rejected the disclosure, if applicable.',
    `rejection_reason` STRING COMMENT 'Explanation provided by the regulator for a rejected filing.',
    `reporting_period_end` DATE COMMENT 'End date of the financial/reporting period covered by the disclosure.',
    `reporting_period_start` DATE COMMENT 'Start date of the financial/reporting period covered by the disclosure.',
    `submission_date` DATE COMMENT 'Date the disclosure was submitted to the regulator or beneficiary.',
    `submission_method` STRING COMMENT 'Channel used to submit the disclosure.. Valid values are `electronic|paper|portal|email`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the disclosure record.',
    `version_number` BIGINT COMMENT 'Sequential version of the disclosure document.',
    CONSTRAINT pk_beneficiary_disclosure PRIMARY KEY(`beneficiary_disclosure_id`)
) COMMENT 'Transactional record of each formal disclosure or regulatory report issued to pension beneficiaries, contributor pools, or sponsoring employers. Captures disclosure type (annual pension statement, benefit entitlement notice, plan amendment notice, SFDR';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`audit_finding` (
    `audit_finding_id` BIGINT COMMENT 'Unique identifier for the audit finding record.',
    `employee_id` BIGINT COMMENT 'Identifier of the auditor party.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: audit_finding has regulatory_body as string but should link to regulatory_authority for proper normalization. regulatory_body string can be removed.',
    `rule_id` BIGINT COMMENT 'Foreign key linking to compliance.rule. Business justification: Audit findings may relate to specific compliance rules. compliance_rule_code and compliance_rule_description can be removed as they become redundant with the FK to rule.',
    `audit_finding_status` STRING COMMENT 'Current lifecycle status of the audit finding.. Valid values are `open|in_progress|closed|rejected`',
    `audit_period_end` DATE COMMENT 'End date of the audit period covering the finding.',
    `audit_period_start` DATE COMMENT 'Start date of the audit period covering the finding.',
    `audit_reference_number` STRING COMMENT 'Reference number linking to the original audit documentation.',
    `audit_source_system` STRING COMMENT 'Source system where the audit finding originated (e.g., Diligent, BlackRock Aladdin).',
    `audit_type` STRING COMMENT 'Type of audit that generated the finding (e.g., internal, external, SOC 2, ISO 27001).. Valid values are `internal|external|soc2|iso27001|regulatory`',
    `auditor_name` STRING COMMENT 'Full name of the auditor who identified the finding.',
    `compliance_impact` STRING COMMENT 'Description of compliance impact resulting from the finding.',
    `control_code` STRING COMMENT 'Identifier of the internal control linked to the finding.',
    `control_name` STRING COMMENT 'Descriptive name of the control associated with the finding.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the audit finding record was created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 currency code for monetary amounts.. Valid values are `^[A-Z]{3}$`',
    `escalation_contact_email` STRING COMMENT 'Email address of the escalation contact.. Valid values are `^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,}$`',
    `escalation_contact_name` STRING COMMENT 'Name of the escalation contact for the finding.',
    `evidence_document_code` STRING COMMENT 'Identifier of the supporting evidence document.',
    `evidence_document_url` STRING COMMENT 'URL linking to the evidence document for the finding.',
    `financial_impact_amount` DECIMAL(18,2) COMMENT 'Estimated financial impact resulting from the finding.',
    `financial_impact_currency` STRING COMMENT 'Currency code for the financial impact amount.. Valid values are `^[A-Z]{3}$`',
    `finding_category` STRING COMMENT 'Broad category of the audit finding.. Valid values are `financial|operational|compliance|risk|it|governance`',
    `finding_description` STRING COMMENT 'Detailed narrative describing the audit finding.',
    `finding_number` STRING COMMENT 'Unique business identifier assigned to the audit finding.',
    `impact_assessment` STRING COMMENT 'Overall impact assessment (financial, operational, reputational).',
    `is_critical` BOOLEAN COMMENT 'Indicates whether the finding is classified as critical.',
    `is_repeat_finding` BOOLEAN COMMENT 'Indicates whether this finding repeats a prior issue.',
    `jurisdiction` STRING COMMENT 'Geographic jurisdiction relevant to the finding.',
    `operational_impact` STRING COMMENT 'Description of operational impact caused by the finding.',
    `recommendation` STRING COMMENT 'Suggested corrective action to address the finding.',
    `related_process` STRING COMMENT 'Name of the business process associated with the finding.',
    `remediation_action` STRING COMMENT 'Planned action to address and resolve the finding.',
    `remediation_cost_amount` DECIMAL(18,2) COMMENT 'Estimated monetary cost to remediate the finding.',
    `remediation_due_date` DATE COMMENT 'Target date by which remediation actions should be completed.',
    `remediation_effectiveness_score` BIGINT COMMENT 'Score (0-100) indicating effectiveness of remediation after closure.',
    `remediation_owner` STRING COMMENT 'Name of the individual responsible for executing remediation.',
    `remediation_status` STRING COMMENT 'Current status of the remediation effort.. Valid values are `not_started|in_progress|completed|deferred`',
    `reported_timestamp` TIMESTAMP COMMENT 'Date and time when the audit finding was reported.',
    `risk_rating` STRING COMMENT 'Overall risk rating assigned to the finding.. Valid values are `low|medium|high|critical`',
    `root_cause_analysis` STRING COMMENT 'Analysis of the underlying root cause of the finding.',
    `severity_level` STRING COMMENT 'Severity rating assigned to the finding based on impact.. Valid values are `low|medium|high|critical`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the audit finding record.',
    CONSTRAINT pk_audit_finding PRIMARY KEY(`audit_finding_id`)
) COMMENT 'Transactional record of each internal or external audit finding raised against the compliance, investment, or operational functions of the pension fund. Captures audit type (internal audit, external audit, SOC 2, ISO 27001), audit period, finding category';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`personal_account_dealing` (
    `personal_account_dealing_id` BIGINT COMMENT 'Unique identifier for the personal account dealing disclosure record.',
    `employee_id` BIGINT COMMENT 'Unique identifier of the employee submitting the dealing request.',
    `instrument_id` BIGINT COMMENT 'Foreign key linking to trade.instrument. Business justification: Employee pre-clearance requires checking requested securities against restricted lists and fund holdings.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: personal_account_dealing has regulatory_body as string but should link to regulatory_authority for proper normalization. regulatory_body string can be removed.',
    `rule_id` BIGINT COMMENT 'Foreign key linking to compliance.rule. Business justification: Link personal_account_dealing to rule to capture the rule that governs the transaction. Redundant regulation code removed.',
    `business_event_timestamp` TIMESTAMP COMMENT 'Timestamp representing when the dealing is intended to be executed.',
    `compliance_review_status` STRING COMMENT 'Status of the downstream compliance review.. Valid values are `not_started|in_review|completed|escalated`',
    `compliance_review_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent compliance review action.',
    `currency_code` STRING COMMENT 'Three‑letter ISO currency code for the transaction.',
    `data_classification` STRING COMMENT 'Classification of the record for data governance (e.g., restricted, confidential, internal, public).',
    `effective_date` DATE COMMENT 'Date on which the dealing becomes effective.',
    `employee_role` STRING COMMENT 'Role or position of the employee within the pension fund (e.g., Portfolio Manager).',
    `expiration_date` DATE COMMENT 'Date after which the dealing request is no longer valid, if applicable.',
    `fee_amount` DECIMAL(20,2) COMMENT 'Total fees associated with the dealing request.',
    `gross_amount` DECIMAL(20,2) COMMENT 'Total amount before fees and adjustments.',
    `is_waiver_requested` BOOLEAN COMMENT 'Indicates whether a regulatory or policy waiver was requested for the dealing.',
    `jurisdiction` STRING COMMENT 'Country jurisdiction applicable to the dealing request. [ENUM-REF-CANDIDATE: USA|CAN|GBR|AUS|FRA|DEU|JPN|CHN|IND|BRA] ',
    `justification_text` STRING COMMENT 'Narrative explanation provided by the employee for the dealing request.',
    `lifecycle_status` STRING COMMENT 'Overall lifecycle status of the dealing request.. Valid values are `draft|submitted|under_review|cleared|rejected|closed`',
    `net_amount` DECIMAL(20,2) COMMENT 'Net amount after fees (gross minus fees).',
    `notes` STRING COMMENT 'Free‑form notes captured by compliance or investment staff.',
    `preclearance_approval_timestamp` TIMESTAMP COMMENT 'Timestamp when the pre‑clearance request was approved or rejected.',
    `preclearance_approver` STRING COMMENT 'Name of the compliance officer who approved or rejected the request.',
    `preclearance_request_timestamp` TIMESTAMP COMMENT 'Timestamp when the employee submitted the pre‑clearance request.',
    `preclearance_status` STRING COMMENT 'Current status of the pre‑clearance request.. Valid values are `pending|approved|rejected|withdrawn`',
    `record_audit_created` TIMESTAMP COMMENT 'Timestamp when the dealing record was first created in the system.',
    `record_audit_updated` TIMESTAMP COMMENT 'Timestamp of the most recent update to the dealing record.',
    `related_document_reference` STRING COMMENT 'Reference (e.g., URL or document ID) to supporting documentation attached to the request.',
    `request_number` STRING COMMENT 'Business identifier assigned to each dealing request.',
    `risk_rating` STRING COMMENT 'Risk rating assigned to the dealing based on compliance assessment.. Valid values are `low|medium|high|critical`',
    `trade_execution_venue` STRING COMMENT 'Venue or platform where the trade would be executed.. Valid values are `NYSE|LSE|OTC|BATS|TSX|JPX`',
    `transaction_price` DECIMAL(20,4) COMMENT 'Price per share/unit at which the dealing is proposed.',
    `transaction_quantity` DECIMAL(20,4) COMMENT 'Number of shares or units involved in the dealing.',
    `transaction_reason` STRING COMMENT 'Business reason for the dealing (e.g., portfolio rebalancing, liquidity need).',
    `transaction_type` STRING COMMENT 'Type of dealing transaction requested.. Valid values are `buy|sell|short`',
    `waiver_approval_status` STRING COMMENT 'Current approval status of the waiver request.. Valid values are `pending|approved|denied`',
    `waiver_approval_timestamp` TIMESTAMP COMMENT 'Timestamp when the waiver request was approved or denied.',
    CONSTRAINT pk_personal_account_dealing PRIMARY KEY(`personal_account_dealing_id`)
) COMMENT 'Transactional record of personal account dealing (PAD) disclosures and pre-clearance requests submitted by investment staff and officers. Captures employee name and role, security identifier (ISIN/CUSIP), transaction type (buy, sell, short), proposed';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`regulatory_authority` (
    `regulatory_authority_id` BIGINT COMMENT 'Unique identifier for the regulatory authority record.',
    `abbreviation` STRING COMMENT 'Common abbreviation or acronym for the authority.',
    `authority_code` STRING COMMENT 'Alphanumeric code uniquely identifying the authority.. Valid values are `^[A-Z0-9]{1,10}$`',
    `authority_regulation_areas` STRING COMMENT 'Comma-separated list of regulatory areas or domains the authority covers.. Valid values are `^[ws,]+$`',
    `authority_regulation_areas_description` STRING COMMENT 'Detailed description of the regulatory areas covered.',
    `authority_regulation_areas_end_date` DATE COMMENT 'End date when the authority ceased overseeing the area, if applicable.',
    `authority_regulation_areas_notes` STRING COMMENT 'Additional notes about the regulatory areas.',
    `authority_regulation_areas_start_date` DATE COMMENT 'Start date when the authority began overseeing the area.',
    `authority_regulation_areas_status` STRING COMMENT 'Operational status of each regulatory area.. Valid values are `active|inactive|pending|terminated`',
    `authority_regulation_areas_type` STRING COMMENT 'Type classification of the regulatory area (e.g., market, conduct).',
    `authority_regulation_areas_type_code` STRING COMMENT 'Code identifying the regulatory area type.. Valid values are `^[A-Z0-9]+$`',
    `authority_regulation_areas_type_description` STRING COMMENT 'Detailed description of the regulatory area type.',
    `authority_regulation_areas_type_end_date` DATE COMMENT 'End date of the regulatory area type, if applicable.',
    `authority_regulation_areas_type_name` STRING COMMENT 'Human-readable name of the regulatory area type.',
    `authority_regulation_areas_type_notes` STRING COMMENT 'Additional notes about the regulatory area type.',
    `authority_regulation_areas_type_start_date` DATE COMMENT 'Start date of the regulatory area type.',
    `authority_regulation_areas_type_status` STRING COMMENT 'Operational status of the regulatory area type.. Valid values are `active|inactive|pending|terminated`',
    `authority_regulation_codes` STRING COMMENT 'Comma-separated list of regulation codes overseen by the authority.. Valid values are `^[A-Z0-9,]+$`',
    `authority_regulation_names` STRING COMMENT 'Comma-separated list of regulation names overseen by the authority.. Valid values are `^[ws,]+$`',
    `authority_type` STRING COMMENT 'Category of regulatory authority (prudential, conduct, market, other).. Valid values are `prudential|conduct|market|other`',
    `authority_website` STRING COMMENT 'Official website URL of the authority.. Valid values are `^(https?://)?[w.-]+(?:.[w.-]+)+[/w.-]*$`',
    `contact_address` STRING COMMENT 'Street address of the authoritys main office.',
    `contact_city` STRING COMMENT 'City component of the authoritys address.',
    `contact_country` STRING COMMENT 'Country of the authoritys address (ISO 3166-1 alpha-3).. Valid values are `^[A-Z]{3}$`',
    `contact_email` STRING COMMENT 'Primary email address for contacting the authority.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `contact_fax` STRING COMMENT 'Fax number for the authority.. Valid values are `^[+]?d{1,15}$`',
    `contact_person_email` STRING COMMENT 'Email address of the primary contact person.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `contact_person_name` STRING COMMENT 'Full name of the primary contact person at the authority.',
    `contact_person_phone` STRING COMMENT 'Telephone number of the primary contact person.. Valid values are `^[+]?d{1,15}$`',
    `contact_person_title` STRING COMMENT 'Job title of the primary contact person.',
    `contact_phone` STRING COMMENT 'Primary telephone number for contacting the authority.. Valid values are `^[+]?d{1,15}$`',
    `contact_postal_code` STRING COMMENT 'Postal code of the authoritys address.',
    `contact_state` STRING COMMENT 'State or province of the authoritys address.',
    `contact_website` STRING COMMENT 'Website URL for the authoritys contact page.. Valid values are `^(https?://)?[w.-]+(?:.[w.-]+)+[/w.-]*$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was first created.',
    `effective_date` DATE COMMENT 'Date the authority became effective.',
    `jurisdiction` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the authoritys jurisdiction.. Valid values are `^[A-Z]{3}$`',
    `legal_name` STRING COMMENT 'Full legal name of the regulatory authority as registered.',
    `regulatory_authority_name` STRING COMMENT 'Human-readable name of the regulatory authority.',
    `notes` STRING COMMENT 'Free-text notes or remarks about the authority.',
    `regulatory_authority_status` STRING COMMENT 'Current operational status of the authority.. Valid values are `active|inactive|pending|terminated`',
    `termination_date` DATE COMMENT 'Date the authority ceased operations, if applicable.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent record update.',
    CONSTRAINT pk_regulatory_authority PRIMARY KEY(`regulatory_authority_id`)
) COMMENT 'Reference master of all regulatory authorities and governing bodies with jurisdiction over the pension funds operations. Captures authority name (SEC, FCA, ESMA, IOSCO, local pension regulator), authority type (prudential, conduct, market';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`obligation` (
    `obligation_id` BIGINT COMMENT 'Unique identifier for the compliance obligation.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Link obligation to regulatory_authority to capture the authority overseeing the obligation. Redundant authority attributes removed.',
    `rule_id` BIGINT COMMENT 'Foreign key linking to compliance.rule. Business justification: Link obligation to rule to capture the rule that defines the obligation. Redundant rule attributes removed.',
    `obligation_code` STRING COMMENT 'Alphanumeric code assigned to the obligation by the fund.',
    `compliance_status` STRING COMMENT 'Current compliance status of the obligation.. Valid values are `compliant|non_compliant|in_review|pending_review`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was created.',
    `currency_code` STRING COMMENT 'ISO 4217 currency code for monetary amounts.',
    `data_classification` STRING COMMENT 'Classification level of the obligation data.',
    `obligation_description` STRING COMMENT 'Detailed description of the obligation.',
    `effective_end_date` DATE COMMENT 'Date the obligation expires or is terminated.',
    `effective_start_date` DATE COMMENT 'Date the obligation becomes effective.',
    `escalation_contact` STRING COMMENT 'Contact for escalation of compliance issues.',
    `filing_deadline` DATE COMMENT 'Deadline for filing the obligation.',
    `filing_frequency` STRING COMMENT 'Required reporting frequency for the obligation.',
    `filing_method` STRING COMMENT 'Method used to submit the filing (e.g., electronic, paper).',
    `filing_reference_number` STRING COMMENT 'Reference number assigned to the filing.',
    `filing_status` STRING COMMENT 'Current status of the filing submission.. Valid values are `submitted|pending|approved|rejected|withdrawn`',
    `is_external` BOOLEAN COMMENT 'Flag indicating if the obligation originates from an external regulator.',
    `is_mandatory` BOOLEAN COMMENT 'Flag indicating if the obligation is mandatory.',
    `is_reported` BOOLEAN COMMENT 'Flag indicating if the obligation has been reported.',
    `last_filed_date` DATE COMMENT 'Date the obligation was last filed.',
    `last_reviewed_date` DATE COMMENT 'Date the obligation was last reviewed.',
    `obligation_name` STRING COMMENT 'Descriptive name of the obligation.',
    `next_due_date` DATE COMMENT 'Next scheduled filing date.',
    `next_review_date` DATE COMMENT 'Scheduled next review date.',
    `notes` STRING COMMENT 'Free‑text notes about the obligation.',
    `obligation_status` STRING COMMENT 'Current lifecycle status of the obligation.. Valid values are `active|inactive|pending|terminated|draft`',
    `obligation_type` STRING COMMENT 'Category of the obligation (e.g., regulatory, policy, mandate).',
    `penalty_amount` DECIMAL(15,2) COMMENT 'Monetary penalty associated with the obligation.',
    `penalty_currency` STRING COMMENT 'Currency of the penalty amount.',
    `penalty_risk_level` STRING COMMENT 'Risk level of potential penalties.. Valid values are `low|medium|high|critical|unknown`',
    `remediation_action` STRING COMMENT 'Action required to remediate a breach.',
    `remediation_cost_amount` DECIMAL(15,2) COMMENT 'Monetary cost of remediation.',
    `remediation_due_date` DATE COMMENT 'Target date for completing remediation.',
    `remediation_status` STRING COMMENT 'Current status of the remediation effort.. Valid values are `pending|in_progress|completed|failed`',
    `reporting_date` DATE COMMENT 'Date the obligation was reported.',
    `required_documentation` STRING COMMENT 'Documents required for compliance filing.',
    `responsible_party` STRING COMMENT 'Party accountable for the obligation.',
    `risk_level` STRING COMMENT 'Overall risk level of the obligation.. Valid values are `low|medium|high|critical`',
    `risk_score` DECIMAL(10,2) COMMENT 'Quantitative risk score for the obligation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the last record update.',
    CONSTRAINT pk_obligation PRIMARY KEY(`obligation_id`)
) COMMENT 'Master record defining each specific compliance obligation the pension fund must fulfill under applicable regulations, internal policies, or mandate terms.';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`sfdr_disclosure` (
    `sfdr_disclosure_id` BIGINT COMMENT 'Primary key, unique identifier for the SFDR disclosure record.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: sfdr_disclosure has regulatory_body as string but should link to regulatory_authority for proper normalization. regulatory_body string can be removed.',
    `classification_or_type` STRING COMMENT 'Specifies whether the disclosure is entity-level PAI, product-level pre-contractual, or periodic report.. Valid values are `entity-level|product-level|periodic`',
    `compliance_flag` BOOLEAN COMMENT 'Indicates whether the disclosure meets all compliance criteria.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was first created.',
    `currency_code` STRING COMMENT 'ISO 4217 currency code for the filing fee.. Valid values are `USD|EUR|GBP|CAD|AUD|JPY`',
    `disclosure_reference` STRING COMMENT 'External reference or number assigned to the disclosure for tracking.',
    `effective_from` DATE COMMENT 'Date when the disclosure becomes effective.',
    `effective_until` DATE COMMENT 'Date when the disclosure ceases to be effective, if applicable.',
    `filing_acceptance_date` DATE COMMENT 'Date the regulator accepted the filing.',
    `filing_deadline` DATE COMMENT 'Deadline by which the disclosure must be filed.',
    `filing_document_url` STRING COMMENT 'URL to the filed document.',
    `filing_fee_amount` DECIMAL(15,2) COMMENT 'Fee paid for filing the disclosure.',
    `filing_format` STRING COMMENT 'File format of the submitted disclosure.. Valid values are `PDF|XML|XLSX`',
    `filing_method` STRING COMMENT 'Method used to submit the filing.. Valid values are `electronic|paper`',
    `filing_period_end` DATE COMMENT 'End date of the reporting period for the disclosure.',
    `filing_period_start` DATE COMMENT 'Start date of the reporting period for the disclosure.',
    `filing_reference_number` STRING COMMENT 'Unique reference number assigned by the regulator.',
    `filing_rejection_date` DATE COMMENT 'Date the regulator rejected the filing, if applicable.',
    `filing_rejection_reason` STRING COMMENT 'Reason for filing rejection, if any.',
    `filing_status` STRING COMMENT 'Current status of the filing process.. Valid values are `submitted|accepted|rejected|pending`',
    `filing_submission_date` DATE COMMENT 'Date the disclosure was submitted to the regulator.',
    `filing_version` STRING COMMENT 'Version number of the filing format.',
    `jurisdiction` STRING COMMENT 'Country code where the filing is submitted.. Valid values are `CAN|USA|GBR|FRA|DEU|JPN`',
    `lifecycle_status` STRING COMMENT 'Current state of the disclosure record in its lifecycle.. Valid values are `draft|pending|approved|filed|archived`',
    `notes` STRING COMMENT 'Free-text notes or comments about the disclosure.',
    `updated_by` STRING COMMENT 'User or system that last updated the record.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the record.',
    `created_by` STRING COMMENT 'User or system that created the record.',
    CONSTRAINT pk_sfdr_disclosure PRIMARY KEY(`sfdr_disclosure_id`)
) COMMENT 'Master record of SFDR (Sustainable Finance Disclosure Regulation) product-level and entity-level disclosures prepared and filed by the pension fund. Captures disclosure type (entity-level PAI statement, product-level pre-contractual, periodic report)';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`gips_compliance_record` (
    `gips_compliance_record_id` BIGINT COMMENT 'Unique identifier for the GIPS compliance record.',
    `composite_id` BIGINT COMMENT 'Identifier of the composite for which compliance is asserted.',
    `policy_document_id` BIGINT COMMENT 'Identifier of the compliance assertion document.',
    `assertion_date` DATE COMMENT 'Date when the GIPS compliance assertion was made.',
    `compliance_status` STRING COMMENT 'Current compliance status of the entity under GIPS.. Valid values are `compliant|non_compliant|pending|in_review|under_review|approved`',
    `composite_end_date` DATE COMMENT 'Date when the composite was closed or terminated.',
    `composite_start_date` DATE COMMENT 'Date when the composite became active.',
    `composite_status` STRING COMMENT 'Lifecycle status of the composite.. Valid values are `active|closed|pending`',
    `composite_type` STRING COMMENT 'Asset class of the composite: public equity, private equity, real estate, etc.',
    `document_checksum` STRING COMMENT 'MD5 checksum of the document for integrity verification.. Valid values are `^[0-9a-fA-F]{32}$`',
    `document_created_by` STRING COMMENT 'User who created the document.',
    `document_created_timestamp` TIMESTAMP COMMENT 'Timestamp when the document was first created.',
    `document_date` DATE COMMENT 'Date the document was issued or published.',
    `document_format` STRING COMMENT 'File format of the document.. Valid values are `pdf|docx|xlsx|txt`',
    `document_is_active` BOOLEAN COMMENT 'Flag indicating if the document is currently active.',
    `document_is_approved` BOOLEAN COMMENT 'Flag indicating if the document has been approved.',
    `document_is_archived` BOOLEAN COMMENT 'Flag indicating if the document has been archived.',
    `document_is_confidential` BOOLEAN COMMENT 'Flag indicating if the document contains confidential information.',
    `document_is_draft` BOOLEAN COMMENT 'Flag indicating if the document is in draft status.',
    `document_is_external` BOOLEAN COMMENT 'Flag indicating if the document originates from an external source.',
    `document_is_final` BOOLEAN COMMENT 'Flag indicating if the document is finalized.',
    `document_is_in_review` BOOLEAN COMMENT 'Flag indicating if the document is currently under review.',
    `document_is_pending` BOOLEAN COMMENT 'Flag indicating if the document is pending approval.',
    `document_is_pii` BOOLEAN COMMENT 'Flag indicating if the document contains personally identifiable information.',
    `document_is_restricted` BOOLEAN COMMENT 'Flag indicating if the document is restricted to certain users.',
    `document_is_reviewed` BOOLEAN COMMENT 'Flag indicating if the document has been reviewed.',
    `document_is_sensitive` BOOLEAN COMMENT 'Flag indicating if the document contains sensitive data.',
    `document_is_signed` BOOLEAN COMMENT 'Flag indicating if the document has been signed.',
    `document_is_verified` BOOLEAN COMMENT 'Flag indicating if the document has been verified.',
    `document_notes` STRING COMMENT 'Additional notes or comments about the document.',
    `document_path` STRING COMMENT 'File system or cloud path to the document.',
    `document_retention_period_days` BIGINT COMMENT 'Number of days the document must be retained.',
    `document_size_bytes` BIGINT COMMENT 'Size of the document in bytes.',
    `document_source_system` STRING COMMENT 'System that supplied the document. [ENUM-REF-CANDIDATE: SimCorp|BlackRock|Bloomberg|StateStreet|eFront|DealCloud|MSCI|CharlesRiver|Oracle|SAP|Diligent|Preqin|FactSet — promote to reference product]',
    `document_status` STRING COMMENT 'Lifecycle status of the document.. Valid values are `draft|final|archived|active|deleted`',
    `document_type` STRING COMMENT 'Type of the compliance document.. Valid values are `report|certification|audit|verification`',
    `document_updated_by` STRING COMMENT 'User who last updated the document.',
    `document_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the last update to the document.',
    `document_version` STRING COMMENT 'Version identifier of the document.',
    `firm_code` BIGINT COMMENT 'Identifier of the firm.',
    `firm_name` STRING COMMENT 'Name of the investment firm.',
    `firm_status` STRING COMMENT 'Current operational status of the firm.. Valid values are `active|closed|pending`',
    `method` STRING COMMENT 'Method used to assert compliance: manual, automated, or third-party.. Valid values are `manual|automated|third_party`',
    `scope` STRING COMMENT 'Scope of the compliance assertion: firm-wide or composite-specific.. Valid values are `firm-wide|composite-specific`',
    CONSTRAINT pk_gips_compliance_record PRIMARY KEY(`gips_compliance_record_id`)
) COMMENT 'Master record tracking the pension funds GIPS (Global Investment Performance Standards) compliance status at the composite and firm level. Captures GIPS compliance assertion date, compliance scope (firm-wide, composite-specific), composite reference';

CREATE OR REPLACE TABLE `asset_management`.`compliance`.`certification` (
    `certification_id` BIGINT COMMENT 'Unique system-generated identifier for the certification record.',
    `employee_id` BIGINT COMMENT 'Internal identifier of the staff member who completed the certification.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: certification has regulatory_body as string but should link to regulatory_authority for proper normalization. regulatory_body string can be removed.',
    `certification_date` DATE COMMENT 'Date when the certification was issued or recorded.',
    `certification_status` STRING COMMENT 'Current lifecycle state of the certification record.. Valid values are `draft|in_progress|completed|failed|revoked`',
    `certification_type` STRING COMMENT 'Category of the certification, e.g., annual compliance attestation or AML training.. Valid values are `annual_compliance|aml_training|code_of_ethics|gips_compliance`',
    `completion_date` DATE COMMENT 'Date when the certification was completed by the staff member.',
    `compliance_area` STRING COMMENT 'Business area covered by the certification.. Valid values are `risk_management|esg|financial_reporting|data_privacy`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the certification record was created.',
    `document_url` STRING COMMENT 'Link to the digital copy of the certification document.',
    `is_active` BOOLEAN COMMENT 'Flag indicating whether the certification record is currently active.',
    `notes` STRING COMMENT 'Free-text notes related to the certification record.',
    `number` STRING COMMENT 'External reference number assigned to the certification by the organization.',
    `regulatory_requirement_code` STRING COMMENT 'Code identifying the specific regulatory requirement.',
    `regulatory_requirement_name` STRING COMMENT 'Full name of the regulatory requirement.',
    `staff_department` STRING COMMENT 'Department where the staff member works.. Valid values are `compliance|training|investment|portfolio`',
    `staff_email` STRING COMMENT 'Primary email address of the staff member.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `staff_name` STRING COMMENT 'Full legal name of the staff member.',
    `staff_phone` STRING COMMENT 'Primary phone number of the staff member.. Valid values are `^+?[1-9]d{1,14}$`',
    `staff_role` STRING COMMENT 'Job role of the staff member within the organization.. Valid values are `compliance_officer|training_coordinator|investment_analyst|portfolio_manager`',
    `training_certificate_number` STRING COMMENT 'Certificate number issued for the completed training.',
    `training_certificate_url` STRING COMMENT 'Link to the digital copy of the training certificate.',
    `training_completion_date` DATE COMMENT 'Date when the training module was completed.',
    `training_module` STRING COMMENT 'Name of the training module completed as part of the certification.',
    `training_passed` BOOLEAN COMMENT 'Indicates whether the staff member passed the training assessment.',
    `training_score` DECIMAL(5,2) COMMENT 'Numeric score achieved in the training assessment.',
    `training_version` STRING COMMENT 'Version identifier of the training module.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the certification record was last updated.',
    CONSTRAINT pk_certification PRIMARY KEY(`certification_id`)
) COMMENT 'Transactional record of periodic compliance certifications completed by investment staff, officers, and committee members. Captures certification type (annual compliance attestation, AML training completion, code of ethics acknowledgement, GIPS compliance';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ADD CONSTRAINT `fk_compliance_regulatory_filing_obligation_id` FOREIGN KEY (`obligation_id`) REFERENCES `asset_management`.`compliance`.`obligation`(`obligation_id`);
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ADD CONSTRAINT `fk_compliance_regulatory_filing_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ADD CONSTRAINT `fk_compliance_filing_submission_regulatory_filing_id` FOREIGN KEY (`regulatory_filing_id`) REFERENCES `asset_management`.`compliance`.`regulatory_filing`(`regulatory_filing_id`);
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ADD CONSTRAINT `fk_compliance_regulatory_calendar_obligation_id` FOREIGN KEY (`obligation_id`) REFERENCES `asset_management`.`compliance`.`obligation`(`obligation_id`);
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ADD CONSTRAINT `fk_compliance_regulatory_calendar_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ADD CONSTRAINT `fk_compliance_regulatory_calendar_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `asset_management`.`compliance`.`rule`(`rule_id`);
ALTER TABLE `asset_management`.`compliance`.`rule` ADD CONSTRAINT `fk_compliance_rule_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ADD CONSTRAINT `fk_compliance_rule_breach_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ADD CONSTRAINT `fk_compliance_rule_breach_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `asset_management`.`compliance`.`rule`(`rule_id`);
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ADD CONSTRAINT `fk_compliance_breach_remediation_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ADD CONSTRAINT `fk_compliance_breach_remediation_regulatory_calendar_id` FOREIGN KEY (`regulatory_calendar_id`) REFERENCES `asset_management`.`compliance`.`regulatory_calendar`(`regulatory_calendar_id`);
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ADD CONSTRAINT `fk_compliance_breach_remediation_rule_breach_id` FOREIGN KEY (`rule_breach_id`) REFERENCES `asset_management`.`compliance`.`rule_breach`(`rule_breach_id`);
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ADD CONSTRAINT `fk_compliance_kyc_record_policy_document_id` FOREIGN KEY (`policy_document_id`) REFERENCES `asset_management`.`compliance`.`policy_document`(`policy_document_id`);
ALTER TABLE `asset_management`.`compliance`.`trade_report` ADD CONSTRAINT `fk_compliance_trade_report_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`compliance`.`trade_report` ADD CONSTRAINT `fk_compliance_trade_report_sfdr_disclosure_id` FOREIGN KEY (`sfdr_disclosure_id`) REFERENCES `asset_management`.`compliance`.`sfdr_disclosure`(`sfdr_disclosure_id`);
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ADD CONSTRAINT `fk_compliance_ic_governance_record_policy_document_id` FOREIGN KEY (`policy_document_id`) REFERENCES `asset_management`.`compliance`.`policy_document`(`policy_document_id`);
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ADD CONSTRAINT `fk_compliance_ic_decision_ic_governance_record_id` FOREIGN KEY (`ic_governance_record_id`) REFERENCES `asset_management`.`compliance`.`ic_governance_record`(`ic_governance_record_id`);
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ADD CONSTRAINT `fk_compliance_conflict_of_interest_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`compliance`.`policy_document` ADD CONSTRAINT `fk_compliance_policy_document_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ADD CONSTRAINT `fk_compliance_policy_exception_policy_document_id` FOREIGN KEY (`policy_document_id`) REFERENCES `asset_management`.`compliance`.`policy_document`(`policy_document_id`);
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ADD CONSTRAINT `fk_compliance_policy_exception_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ADD CONSTRAINT `fk_compliance_policy_exception_related_calendar_regulatory_calendar_id` FOREIGN KEY (`related_calendar_regulatory_calendar_id`) REFERENCES `asset_management`.`compliance`.`regulatory_calendar`(`regulatory_calendar_id`);
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ADD CONSTRAINT `fk_compliance_policy_exception_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `asset_management`.`compliance`.`rule`(`rule_id`);
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ADD CONSTRAINT `fk_compliance_regulatory_change_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ADD CONSTRAINT `fk_compliance_regulatory_exam_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ADD CONSTRAINT `fk_compliance_exam_finding_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ADD CONSTRAINT `fk_compliance_exam_finding_regulatory_exam_id` FOREIGN KEY (`regulatory_exam_id`) REFERENCES `asset_management`.`compliance`.`regulatory_exam`(`regulatory_exam_id`);
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ADD CONSTRAINT `fk_compliance_beneficiary_disclosure_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `asset_management`.`compliance`.`rule`(`rule_id`);
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ADD CONSTRAINT `fk_compliance_personal_account_dealing_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ADD CONSTRAINT `fk_compliance_personal_account_dealing_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `asset_management`.`compliance`.`rule`(`rule_id`);
ALTER TABLE `asset_management`.`compliance`.`obligation` ADD CONSTRAINT `fk_compliance_obligation_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`compliance`.`obligation` ADD CONSTRAINT `fk_compliance_obligation_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `asset_management`.`compliance`.`rule`(`rule_id`);
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ADD CONSTRAINT `fk_compliance_sfdr_disclosure_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ADD CONSTRAINT `fk_compliance_gips_compliance_record_policy_document_id` FOREIGN KEY (`policy_document_id`) REFERENCES `asset_management`.`compliance`.`policy_document`(`policy_document_id`);
ALTER TABLE `asset_management`.`compliance`.`certification` ADD CONSTRAINT `fk_compliance_certification_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `regulatory_filing_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing ID');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `stress_test_result_id` SET TAGS ('dbx_business_glossary_term' = 'Stress Test Result Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `acceptance_date` SET TAGS ('dbx_business_glossary_term' = 'Acceptance Timestamp');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `attached_document_url` SET TAGS ('dbx_business_glossary_term' = 'Attached Document URL');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Filing Comments');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Compliance Flag');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `filing_deadline` SET TAGS ('dbx_business_glossary_term' = 'Filing Deadline Date');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `filing_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Filing Fee Amount');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `filing_format` SET TAGS ('dbx_business_glossary_term' = 'Filing Format');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `filing_format` SET TAGS ('dbx_value_regex' = 'xbrl|pdf|xml|json');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `filing_name` SET TAGS ('dbx_business_glossary_term' = 'Filing Name');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `filing_number` SET TAGS ('dbx_business_glossary_term' = 'Filing Number');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Filing Status');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `filing_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|acknowledged|accepted|rejected');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `filing_type` SET TAGS ('dbx_business_glossary_term' = 'Filing Type');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `filing_type` SET TAGS ('dbx_value_regex' = 'annual|quarterly|monthly|ad_hoc|event_driven|other');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `rejection_date` SET TAGS ('dbx_business_glossary_term' = 'Rejection Timestamp');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `reporting_period_end` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `reporting_period_start` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Timestamp');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `submission_method` SET TAGS ('dbx_business_glossary_term' = 'Submission Method');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `submission_method` SET TAGS ('dbx_value_regex' = 'electronic|paper|portal|api');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By User Identifier');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Filing Version Number');
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By User Identifier');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `filing_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Filing Submission ID');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `regulatory_filing_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `acknowledgement_reference` SET TAGS ('dbx_business_glossary_term' = 'Acknowledgement Reference');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `error_code` SET TAGS ('dbx_business_glossary_term' = 'Error Code');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `error_description` SET TAGS ('dbx_business_glossary_term' = 'Error Description');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `file_checksum` SET TAGS ('dbx_business_glossary_term' = 'File Checksum (SHA-256)');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `file_checksum` SET TAGS ('dbx_value_regex' = '^[A-Fa-f0-9]{64}$');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `file_name` SET TAGS ('dbx_business_glossary_term' = 'File Name');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `file_size_bytes` SET TAGS ('dbx_business_glossary_term' = 'File Size (Bytes)');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `filing_period_end` SET TAGS ('dbx_business_glossary_term' = 'Filing Period End Date');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `filing_period_start` SET TAGS ('dbx_business_glossary_term' = 'Filing Period Start Date');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `filing_submission_status` SET TAGS ('dbx_business_glossary_term' = 'Filing Submission Status');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `filing_submission_status` SET TAGS ('dbx_value_regex' = 'draft|pending|submitted|rejected|accepted');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `filing_type` SET TAGS ('dbx_business_glossary_term' = 'Filing Type');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `filing_type` SET TAGS ('dbx_value_regex' = 'annual_report|quarterly_report|semiannual_report|ad_hoc|regulatory_notice|other');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Created Timestamp');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Record Audit Updated Timestamp');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `regulator` SET TAGS ('dbx_business_glossary_term' = 'Regulator');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `regulator` SET TAGS ('dbx_value_regex' = 'SEC|FCA|ESMA|IOSCO|Other');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `submission_method` SET TAGS ('dbx_business_glossary_term' = 'Submission Method');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `submission_method` SET TAGS ('dbx_value_regex' = 'portal|xbrl|api|manual');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `submission_number` SET TAGS ('dbx_business_glossary_term' = 'Submission Number');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `submission_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Submission Timestamp');
ALTER TABLE `asset_management`.`compliance`.`filing_submission` ALTER COLUMN `submitted_by` SET TAGS ('dbx_business_glossary_term' = 'Submitted By');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `regulatory_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Calendar ID');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `rule_id` SET TAGS ('dbx_business_glossary_term' = 'Rule Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non-compliant|pending|exempt');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `data_classification` SET TAGS ('dbx_business_glossary_term' = 'Data Classification');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `escalation_contact` SET TAGS ('dbx_business_glossary_term' = 'Escalation Contact Email');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `escalation_contact` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `escalation_contact` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `escalation_contact` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `filing_deadline` SET TAGS ('dbx_business_glossary_term' = 'Filing Deadline');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `filing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Filing Frequency');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `filing_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi-annual|quarterly|monthly|ad-hoc');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `filing_method` SET TAGS ('dbx_business_glossary_term' = 'Filing Method');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `filing_method` SET TAGS ('dbx_value_regex' = 'electronic|paper|portal|api');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `filing_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Filing Reference Number');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Filing Status');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `filing_status` SET TAGS ('dbx_value_regex' = 'filed|not_filed|waived|pending');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `is_external` SET TAGS ('dbx_business_glossary_term' = 'Is External Obligation');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Is Mandatory');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `last_filed_date` SET TAGS ('dbx_business_glossary_term' = 'Last Filed Date');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `last_reviewed_date` SET TAGS ('dbx_business_glossary_term' = 'Last Reviewed Date');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `next_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Due Date');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `penalty_risk_level` SET TAGS ('dbx_business_glossary_term' = 'Penalty Risk Level');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `penalty_risk_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `regulatory_calendar_status` SET TAGS ('dbx_business_glossary_term' = 'Obligation Status');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `regulatory_calendar_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|retired');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `required_documentation` SET TAGS ('dbx_business_glossary_term' = 'Required Documentation');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `responsible_party` SET TAGS ('dbx_business_glossary_term' = 'Responsible Party');
ALTER TABLE `asset_management`.`compliance`.`regulatory_calendar` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`compliance`.`rule` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`compliance`.`rule` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`rule` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`rule` SET TAGS ('dbx_subdomain' = 'monitoring_surveillance');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `rule_id` SET TAGS ('dbx_business_glossary_term' = 'Rule ID (RULE_ID)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `action` SET TAGS ('dbx_business_glossary_term' = 'Rule Action (RULE_ACTION)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `action` SET TAGS ('dbx_value_regex' = 'alert|block|flag|report|audit|notify');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `approval_by` SET TAGS ('dbx_business_glossary_term' = 'Rule Approval By (RULE_APPROVAL_BY)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Rule Approval Date (RULE_APPROVAL_DATE)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Rule Approval Status (RULE_APPROVAL_STATUS)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'approved|pending|rejected');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Rule Created At (RULE_CREATED_AT)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `criteria` SET TAGS ('dbx_business_glossary_term' = 'Rule Criteria (RULE_CRITERIA)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `rule_description` SET TAGS ('dbx_business_glossary_term' = 'Rule Description (RULE_DESCRIPTION)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `document_reference` SET TAGS ('dbx_business_glossary_term' = 'Rule Document Reference (RULE_DOCUMENT_REFERENCE)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date (EFFECTIVE_FROM)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date (EFFECTIVE_UNTIL)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `frequency` SET TAGS ('dbx_business_glossary_term' = 'Rule Frequency (RULE_FREQUENCY)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `frequency` SET TAGS ('dbx_value_regex' = 'daily|weekly|monthly|quarterly|annually');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Active (RULE_IS_ACTIVE)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_archived` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Archived (RULE_IS_ARCHIVED)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_automated` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Automated (RULE_IS_AUTOMATED)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_compliance` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Compliance (RULE_IS_COMPLIANCE)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_confidential` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Confidential (RULE_IS_CONFIDENTIAL)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_custom` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Custom (RULE_IS_CUSTOM)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_default` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Default (RULE_IS_DEFAULT)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_external` SET TAGS ('dbx_business_glossary_term' = 'Rule Is External (RULE_IS_EXTERNAL)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_internal` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Internal (RULE_IS_INTERNAL)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_legal` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Legal (RULE_IS_LEGAL)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_pii` SET TAGS ('dbx_business_glossary_term' = 'Rule Is PII (RULE_IS_PII)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_policy` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Policy (RULE_IS_POLICY)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_procedure` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Procedure (RULE_IS_PROCEDURE)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_process` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Process (RULE_IS_PROCESS)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_public` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Public (RULE_IS_PUBLIC)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_regulatory` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Regulatory (RULE_IS_REGULATORY)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_restricted` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Restricted (RULE_IS_RESTRICTED)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_sensitive` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Sensitive (RULE_IS_SENSITIVE)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_template` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Template (RULE_IS_TEMPLATE)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_test` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Test (RULE_IS_TEST)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `is_workflow` SET TAGS ('dbx_business_glossary_term' = 'Rule Is Workflow (RULE_IS_WORKFLOW)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `last_run_at` SET TAGS ('dbx_business_glossary_term' = 'Rule Last Run At (RULE_LAST_RUN_AT)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `rule_name` SET TAGS ('dbx_business_glossary_term' = 'Rule Name (RULE_NAME)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `next_run_at` SET TAGS ('dbx_business_glossary_term' = 'Rule Next Run At (RULE_NEXT_RUN_AT)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `owner` SET TAGS ('dbx_business_glossary_term' = 'Rule Owner (RULE_OWNER)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Rule Priority (RULE_PRIORITY)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `rule_status` SET TAGS ('dbx_business_glossary_term' = 'Rule Status (RULE_STATUS)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `rule_status` SET TAGS ('dbx_value_regex' = 'active|inactive|draft|pending|archived');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `rule_type` SET TAGS ('dbx_business_glossary_term' = 'Rule Type (RULE_TYPE)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'Rule Scope (RULE_SCOPE)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `severity` SET TAGS ('dbx_business_glossary_term' = 'Rule Severity (RULE_SEVERITY)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `severity` SET TAGS ('dbx_value_regex' = 'critical|major|minor');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Rule Updated At (RULE_UPDATED_AT)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Rule Version (RULE_VERSION)');
ALTER TABLE `asset_management`.`compliance`.`rule` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Rule Created By (RULE_CREATED_BY)');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` SET TAGS ('dbx_subdomain' = 'monitoring_surveillance');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `rule_breach_id` SET TAGS ('dbx_business_glossary_term' = 'Rule Breach ID');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Escalation Contact ID');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `blotter_id` SET TAGS ('dbx_business_glossary_term' = 'Blotter Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Responsible Party ID');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `infra_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Infra Asset Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Impacted Asset ID');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `resolved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Resolved By Party ID');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `rule_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Rule ID');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `settlement_fail_id` SET TAGS ('dbx_business_glossary_term' = 'Settlement Fail Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `amount_adjustment` SET TAGS ('dbx_business_glossary_term' = 'Financial Impact Adjustment Amount');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `amount_gross` SET TAGS ('dbx_business_glossary_term' = 'Gross Financial Impact Amount');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `amount_net` SET TAGS ('dbx_business_glossary_term' = 'Net Financial Impact Amount');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `breach_description` SET TAGS ('dbx_business_glossary_term' = 'Breach Description');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `breach_number` SET TAGS ('dbx_business_glossary_term' = 'Breach Number');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `breach_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Breach Occurrence Timestamp');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `compliance_area` SET TAGS ('dbx_business_glossary_term' = 'Compliance Area');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `compliance_area` SET TAGS ('dbx_value_regex' = 'ESG|KYC|AML|Trade|Reporting|Risk');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `data_classification` SET TAGS ('dbx_business_glossary_term' = 'Data Classification');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `data_classification` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `detection_method` SET TAGS ('dbx_business_glossary_term' = 'Detection Method');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `detection_method` SET TAGS ('dbx_value_regex' = 'rule_engine|manual|audit');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `detection_source` SET TAGS ('dbx_business_glossary_term' = 'Detection Source System');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `detection_source` SET TAGS ('dbx_value_regex' = 'Aladdin|Charles_River|Custom|Other');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `evidence_document_code` SET TAGS ('dbx_business_glossary_term' = 'Evidence Document ID');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `is_critical` SET TAGS ('dbx_business_glossary_term' = 'Critical Breach Flag');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `is_repeat` SET TAGS ('dbx_business_glossary_term' = 'Repeat Breach Flag');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `is_reported` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `penalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Penalty Amount');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `penalty_currency` SET TAGS ('dbx_business_glossary_term' = 'Penalty Currency Code');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `penalty_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `remediation_action` SET TAGS ('dbx_business_glossary_term' = 'Remediation Action');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `remediation_due_date` SET TAGS ('dbx_business_glossary_term' = 'Remediation Due Date');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `repeat_count` SET TAGS ('dbx_business_glossary_term' = 'Repeat Breach Count');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `reporting_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Date');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `resolution_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Resolution Timestamp');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Score');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `rule_breach_status` SET TAGS ('dbx_business_glossary_term' = 'Breach Status');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `rule_breach_status` SET TAGS ('dbx_value_regex' = 'detected|investigating|resolved|escalated|closed');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `severity_level` SET TAGS ('dbx_business_glossary_term' = 'Severity Level');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `severity_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` SET TAGS ('dbx_subdomain' = 'monitoring_surveillance');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `breach_remediation_id` SET TAGS ('dbx_business_glossary_term' = 'Breach Remediation ID');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned Officer ID');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `regulatory_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Calendar ID');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `rule_breach_id` SET TAGS ('dbx_business_glossary_term' = 'Breach ID');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `actual_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Completion Date');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `assigned_officer_name` SET TAGS ('dbx_business_glossary_term' = 'Assigned Officer Name');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `breach_detection_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Breach Detection Timestamp');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `breach_severity` SET TAGS ('dbx_business_glossary_term' = 'Breach Severity');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `breach_severity` SET TAGS ('dbx_value_regex' = 'minor|major|critical');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `compliance_rule_code` SET TAGS ('dbx_business_glossary_term' = 'Compliance Rule Code');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `compliance_rule_description` SET TAGS ('dbx_business_glossary_term' = 'Compliance Rule Description');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|JPY|CHF');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `escalation_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Escalation Contact Email');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `escalation_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `escalation_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `escalation_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `escalation_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Escalation Contact Name');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `escalation_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `escalation_contact_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `escalation_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Escalation Contact Phone');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `escalation_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `escalation_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `is_waiver_requested` SET TAGS ('dbx_business_glossary_term' = 'Waiver Requested Flag');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `last_updated_by` SET TAGS ('dbx_business_glossary_term' = 'Last Updated By');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Remediation Notes');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `penalty_risk_estimate` SET TAGS ('dbx_business_glossary_term' = 'Penalty Risk Estimate');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `related_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Related Document Reference');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `remediation_action_details` SET TAGS ('dbx_business_glossary_term' = 'Remediation Action Details');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `remediation_action_type` SET TAGS ('dbx_business_glossary_term' = 'Remediation Action Type');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `remediation_action_type` SET TAGS ('dbx_value_regex' = 'trade_reversal|position_reduction|waiver_request|policy_update|other');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `remediation_cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Remediation Cost Amount');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `remediation_effectiveness_score` SET TAGS ('dbx_business_glossary_term' = 'Remediation Effectiveness Score');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `remediation_plan_description` SET TAGS ('dbx_business_glossary_term' = 'Remediation Plan Description');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `remediation_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Remediation Reference Code');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `remediation_start_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Remediation Start Timestamp');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `remediation_status` SET TAGS ('dbx_business_glossary_term' = 'Remediation Status');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `remediation_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|failed|waived');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `risk_level` SET TAGS ('dbx_business_glossary_term' = 'Risk Level');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `risk_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `target_remediation_date` SET TAGS ('dbx_business_glossary_term' = 'Target Remediation Date');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `waiver_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Waiver Approval Status');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `waiver_approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `waiver_approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Waiver Approval Timestamp');
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` SET TAGS ('dbx_subdomain' = 'monitoring_surveillance');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `kyc_record_id` SET TAGS ('dbx_business_glossary_term' = 'KYC Record Identifier');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `policy_document_id` SET TAGS ('dbx_business_glossary_term' = 'Document Identifier');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `policy_document_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `policy_document_id` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `address_line1` SET TAGS ('dbx_business_glossary_term' = 'Address Line 1');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `address_line1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `address_line2` SET TAGS ('dbx_business_glossary_term' = 'Address Line 2');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `address_line2` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `aml_check_status` SET TAGS ('dbx_business_glossary_term' = 'AML Check Status');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `aml_check_status` SET TAGS ('dbx_value_regex' = 'clear|match|pending|blocked');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `beneficial_owner_name` SET TAGS ('dbx_business_glossary_term' = 'Beneficial Owner Name');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `beneficial_owner_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `beneficial_owner_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `beneficial_owner_percentage` SET TAGS ('dbx_business_glossary_term' = 'Beneficial Ownership Percentage');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'City');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code (ISO 3166‑1 alpha‑3)');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `data_classification` SET TAGS ('dbx_business_glossary_term' = 'Data Classification Level');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `data_classification` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `document_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Document Expiry Date');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `document_issue_date` SET TAGS ('dbx_business_glossary_term' = 'Document Issue Date');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'Document Status');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `document_status` SET TAGS ('dbx_value_regex' = 'valid|expired|revoked');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `document_type` SET TAGS ('dbx_business_glossary_term' = 'KYC Document Type');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `document_type` SET TAGS ('dbx_value_regex' = 'passport|driver_license|incorporation_certificate|utility_bill|other');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'Email Address');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction of Legal Entity');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `kyc_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'KYC Expiry Date');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `kyc_review_date` SET TAGS ('dbx_business_glossary_term' = 'KYC Review Date');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `kyc_status` SET TAGS ('dbx_business_glossary_term' = 'KYC Status');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `kyc_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|expired|under_review');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `last_updated_by` SET TAGS ('dbx_business_glossary_term' = 'Last Updated By');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `legal_entity_identifier` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `legal_entity_identifier` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `legal_entity_identifier` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'KYC Notes');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `party_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Party Name (Full Name)');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `party_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `party_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `party_type` SET TAGS ('dbx_business_glossary_term' = 'Party Type');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `party_type` SET TAGS ('dbx_value_regex' = 'individual|organization|fund|manager|co_investor');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `pep_status` SET TAGS ('dbx_business_glossary_term' = 'Politically Exposed Person (PEP) Status');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `pep_status` SET TAGS ('dbx_value_regex' = 'none|identified|potential');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `phone_number` SET TAGS ('dbx_business_glossary_term' = 'Phone Number');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `registration_number` SET TAGS ('dbx_business_glossary_term' = 'Business Registration Number');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `registration_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `registration_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Score');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `sanctions_screening_status` SET TAGS ('dbx_business_glossary_term' = 'Sanctions Screening Status');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `sanctions_screening_status` SET TAGS ('dbx_value_regex' = 'clear|match|pending|blocked');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `source_of_funds` SET TAGS ('dbx_business_glossary_term' = 'Source of Funds Description');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `state_province` SET TAGS ('dbx_business_glossary_term' = 'State or Province');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `state_province` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `state_province` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `tax_identifier` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number (TIN)');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `tax_identifier` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `tax_identifier` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `trade_name` SET TAGS ('dbx_business_glossary_term' = 'Trade or Business Name');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ALTER COLUMN `website_url` SET TAGS ('dbx_business_glossary_term' = 'Website URL');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` SET TAGS ('dbx_subdomain' = 'monitoring_surveillance');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `sanctions_screening_id` SET TAGS ('dbx_business_glossary_term' = 'Sanctions Screening ID');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `is_false_positive` SET TAGS ('dbx_business_glossary_term' = 'Is False Positive');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `match_detail` SET TAGS ('dbx_business_glossary_term' = 'Match Detail');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `performed_by` SET TAGS ('dbx_business_glossary_term' = 'Performed By');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `record_status` SET TAGS ('dbx_business_glossary_term' = 'Record Status');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `record_status` SET TAGS ('dbx_value_regex' = 'active|archived|deleted');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `remediation_action` SET TAGS ('dbx_business_glossary_term' = 'Remediation Action');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `remediation_action` SET TAGS ('dbx_value_regex' = 'review|escalate|reject|accept');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `remediation_due_date` SET TAGS ('dbx_business_glossary_term' = 'Remediation Due Date');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Score');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `screened_entity_lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `screened_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Screened Entity Full Name (PII)');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `screened_entity_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `screened_entity_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `screened_entity_type` SET TAGS ('dbx_business_glossary_term' = 'Screened Entity Type');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `screened_entity_type` SET TAGS ('dbx_value_regex' = 'counterparty|issuer|manager|individual|other');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `screening_list` SET TAGS ('dbx_business_glossary_term' = 'Screening List Applied');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `screening_list` SET TAGS ('dbx_value_regex' = 'OFAC|UN|EU|UK_HMT|FATF|CUSTOM');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `screening_result` SET TAGS ('dbx_business_glossary_term' = 'Screening Result');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `screening_result` SET TAGS ('dbx_value_regex' = 'clear|potential_match|match|false_positive|blocked');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `screening_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Screening Timestamp');
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`compliance`.`trade_report` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`compliance`.`trade_report` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`trade_report` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`trade_report` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `trade_report_id` SET TAGS ('dbx_business_glossary_term' = 'Trade Report Identifier (TRID)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `broker_id` SET TAGS ('dbx_business_glossary_term' = 'Broker Identifier (BID)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `execution_id` SET TAGS ('dbx_business_glossary_term' = 'Execution Identifier (EI)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `fx_forward_id` SET TAGS ('dbx_business_glossary_term' = 'Fx Forward Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `fx_swap_id` SET TAGS ('dbx_business_glossary_term' = 'Fx Swap Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `fx_trade_id` SET TAGS ('dbx_business_glossary_term' = 'Fx Trade Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `order_id` SET TAGS ('dbx_business_glossary_term' = 'Order Identifier (OID)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `otc_derivative_id` SET TAGS ('dbx_business_glossary_term' = 'Otc Derivative Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `sfdr_disclosure_id` SET TAGS ('dbx_business_glossary_term' = 'Sfdr Disclosure Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class (AC)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `commission` SET TAGS ('dbx_business_glossary_term' = 'Broker Commission (BC)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status (CS)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|pending');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `counterparty_lei` SET TAGS ('dbx_business_glossary_term' = 'Counterparty Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp (RCT)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `data_classification` SET TAGS ('dbx_business_glossary_term' = 'Data Classification (DC)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `emir_reportable` SET TAGS ('dbx_business_glossary_term' = 'EMIR Reportable Flag (ERF)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `execution_venue` SET TAGS ('dbx_business_glossary_term' = 'Execution Venue (EV)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Trade Fee Amount (TFA)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Trade Amount (GTA)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `instrument_isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Trade Report Lifecycle Status (TRLS)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_value_regex' = 'draft|pending|submitted|accepted|rejected|cancelled');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `mifid_reportable` SET TAGS ('dbx_business_glossary_term' = 'MiFID II Reportable Flag (MRF)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Trade Amount (NTA)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes (N)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `penalty_risk_level` SET TAGS ('dbx_business_glossary_term' = 'Penalty Risk Level (PRL)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `penalty_risk_level` SET TAGS ('dbx_value_regex' = 'low|medium|high');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `price` SET TAGS ('dbx_business_glossary_term' = 'Trade Price (TP)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Trade Quantity (TQ)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `regulatory_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Status (RS)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `regulatory_status` SET TAGS ('dbx_value_regex' = 'submitted|accepted|rejected');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `report_reference` SET TAGS ('dbx_business_glossary_term' = 'Trade Report Reference (TRR)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `reporting_regime` SET TAGS ('dbx_business_glossary_term' = 'Reporting Regime (RR)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `reporting_regime` SET TAGS ('dbx_value_regex' = 'EMIR|MiFIDII');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `reporting_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Reporting Timestamp (RT)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Settlement Amount (SA)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date (SD)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `trade_currency` SET TAGS ('dbx_business_glossary_term' = 'Trade Currency (TC)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `trade_repository` SET TAGS ('dbx_business_glossary_term' = 'Trade Repository (TR)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `trade_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Trade Event Timestamp (TET)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `trade_type` SET TAGS ('dbx_business_glossary_term' = 'Trade Type (TT)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `trade_type` SET TAGS ('dbx_value_regex' = 'Buy|Sell|Swap|Option|Future|Forward');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `unique_trade_identifier` SET TAGS ('dbx_business_glossary_term' = 'Unique Trade Identifier (UTI)');
ALTER TABLE `asset_management`.`compliance`.`trade_report` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp (RUT)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`compliance`.`lei_record` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`lei_record` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`lei_record` SET TAGS ('dbx_subdomain' = 'monitoring_surveillance');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_record_id` SET TAGS ('dbx_business_glossary_term' = 'LEI Record ID');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp (CREATED_TIMESTAMP)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_address` SET TAGS ('dbx_business_glossary_term' = 'Entity Address (ENTITY_ADDRESS)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_city` SET TAGS ('dbx_business_glossary_term' = 'Entity City (ENTITY_CITY)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_classification` SET TAGS ('dbx_business_glossary_term' = 'Entity Classification (ENTITY_CLASSIFICATION)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_classification` SET TAGS ('dbx_value_regex' = 'Investor|Counterparty|Custodian|Regulator|Other');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_country` SET TAGS ('dbx_business_glossary_term' = 'Entity Country (ENTITY_COUNTRY)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_description` SET TAGS ('dbx_business_glossary_term' = 'Entity Description (ENTITY_DESCRIPTION)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_email` SET TAGS ('dbx_business_glossary_term' = 'Entity Email Address (ENTITY_EMAIL)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_fax` SET TAGS ('dbx_business_glossary_term' = 'Entity Fax Number (ENTITY_FAX)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_fax` SET TAGS ('dbx_value_regex' = '^+?[1-9]d{1,14}$');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_fax` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_fax` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_name` SET TAGS ('dbx_business_glossary_term' = 'Entity Name (LEGAL_ENTITY_NAME)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_phone` SET TAGS ('dbx_business_glossary_term' = 'Entity Phone Number (ENTITY_PHONE)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_phone` SET TAGS ('dbx_value_regex' = '^+?[1-9]d{1,14}$');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Entity Postal Code (ENTITY_POSTAL_CODE)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_state` SET TAGS ('dbx_business_glossary_term' = 'Entity State/Province (ENTITY_STATE)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_status` SET TAGS ('dbx_business_glossary_term' = 'Entity Status (ENTITY_STATUS)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_status` SET TAGS ('dbx_value_regex' = 'Active|Inactive|Pending|Terminated|Suspended');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_subtype` SET TAGS ('dbx_business_glossary_term' = 'Entity Subtype (ENTITY_SUBTYPE)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_subtype` SET TAGS ('dbx_value_regex' = 'Private Equity SPV|Real Estate Fund|Infrastructure Fund|Credit Fund|Equity Fund|Other');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_type` SET TAGS ('dbx_business_glossary_term' = 'Entity Type (ENTITY_TYPE)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_type` SET TAGS ('dbx_value_regex' = 'Fund|SPV|Counterparty|Subsidiary');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `entity_website` SET TAGS ('dbx_business_glossary_term' = 'Entity Website (ENTITY_WEBSITE)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'LEI Expiry Date (LEI_EXPIRY_DATE)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_issue_date` SET TAGS ('dbx_business_glossary_term' = 'LEI Issue Date (LEI_ISSUE_DATE)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_last_updated` SET TAGS ('dbx_business_glossary_term' = 'LEI Last Updated (LEI_LAST_UPDATED)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_source_system` SET TAGS ('dbx_business_glossary_term' = 'LEI Source System (LEI_SOURCE_SYSTEM)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_source_system_active_flag` SET TAGS ('dbx_business_glossary_term' = 'LEI Source System Active Flag (LEI_SOURCE_SYSTEM_ACTIVE_FLAG)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_source_system_code` SET TAGS ('dbx_business_glossary_term' = 'LEI Source System ID (LEI_SOURCE_SYSTEM_ID)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_source_system_created` SET TAGS ('dbx_business_glossary_term' = 'LEI Source System Created (LEI_SOURCE_SYSTEM_CREATED)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_source_system_deleted` SET TAGS ('dbx_business_glossary_term' = 'LEI Source System Deleted (LEI_SOURCE_SYSTEM_DELETED)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_source_system_description` SET TAGS ('dbx_business_glossary_term' = 'LEI Source System Description (LEI_SOURCE_SYSTEM_DESCRIPTION)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_source_system_name` SET TAGS ('dbx_business_glossary_term' = 'LEI Source System Name (LEI_SOURCE_SYSTEM_NAME)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_source_system_notes` SET TAGS ('dbx_business_glossary_term' = 'LEI Source System Notes (LEI_SOURCE_SYSTEM_NOTES)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_source_system_reference` SET TAGS ('dbx_business_glossary_term' = 'LEI Source System Reference (LEI_SOURCE_SYSTEM_REFERENCE)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_source_system_remarks` SET TAGS ('dbx_business_glossary_term' = 'LEI Source System Remarks (LEI_SOURCE_SYSTEM_REMARKS)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_source_system_timestamp` SET TAGS ('dbx_business_glossary_term' = 'LEI Source System Timestamp (LEI_SOURCE_SYSTEM_TIMESTAMP)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_source_system_type` SET TAGS ('dbx_business_glossary_term' = 'LEI Source System Type (LEI_SOURCE_SYSTEM_TYPE)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_source_system_updated` SET TAGS ('dbx_business_glossary_term' = 'LEI Source System Updated (LEI_SOURCE_SYSTEM_UPDATED)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_source_system_version` SET TAGS ('dbx_business_glossary_term' = 'LEI Source System Version (LEI_SOURCE_SYSTEM_VERSION)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_status` SET TAGS ('dbx_business_glossary_term' = 'LEI Status (LEI_STATUS)');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `lei_status` SET TAGS ('dbx_value_regex' = 'Active|Inactive|Pending|Revoked');
ALTER TABLE `asset_management`.`compliance`.`lei_record` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp (UPDATED_TIMESTAMP)');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` SET TAGS ('dbx_subdomain' = 'governance_ethics');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `ic_governance_record_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee Governance Record ID');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `policy_document_id` SET TAGS ('dbx_business_glossary_term' = 'Minutes Document ID');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `action_items` SET TAGS ('dbx_business_glossary_term' = 'Action Items');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `agenda_items` SET TAGS ('dbx_business_glossary_term' = 'Agenda Items');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `attendees_count` SET TAGS ('dbx_business_glossary_term' = 'Attendees Count');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `attendees_roles` SET TAGS ('dbx_business_glossary_term' = 'Attendees Roles');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `attendees_roles` SET TAGS ('dbx_value_regex' = 'chair|member|observer|guest|secretary|advisor');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `compliance_review_date` SET TAGS ('dbx_business_glossary_term' = 'Compliance Review Date');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `compliance_review_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Review Status');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `compliance_review_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `decisions_made` SET TAGS ('dbx_business_glossary_term' = 'Decisions Made');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `end_time` SET TAGS ('dbx_business_glossary_term' = 'Meeting End Timestamp');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `is_confidential` SET TAGS ('dbx_business_glossary_term' = 'Confidential Flag');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `location` SET TAGS ('dbx_business_glossary_term' = 'Meeting Location');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Meeting Date');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `meeting_number` SET TAGS ('dbx_business_glossary_term' = 'Meeting Number');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `meeting_status` SET TAGS ('dbx_business_glossary_term' = 'Meeting Status');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `meeting_status` SET TAGS ('dbx_value_regex' = 'scheduled|completed|cancelled|postponed');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `meeting_title` SET TAGS ('dbx_business_glossary_term' = 'Meeting Title');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `meeting_type` SET TAGS ('dbx_business_glossary_term' = 'Meeting Type');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `meeting_type` SET TAGS ('dbx_value_regex' = 'regular|special|subcommittee|ad_hoc');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'General Notes');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `quorum_status` SET TAGS ('dbx_business_glossary_term' = 'Quorum Status');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `quorum_status` SET TAGS ('dbx_value_regex' = 'met|not_met|partial');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `regulatory_filing_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Reference');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `risk_assessment_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Score');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `start_time` SET TAGS ('dbx_business_glossary_term' = 'Meeting Start Timestamp');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Record Updated By');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `virtual_meeting_link` SET TAGS ('dbx_business_glossary_term' = 'Virtual Meeting Link');
ALTER TABLE `asset_management`.`compliance`.`ic_governance_record` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` SET TAGS ('dbx_subdomain' = 'governance_ethics');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `ic_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee Decision ID');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `fund_id` SET TAGS ('dbx_business_glossary_term' = 'Fund ID');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `ic_governance_record_id` SET TAGS ('dbx_business_glossary_term' = 'Ic Governance Record Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `infra_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Underlying Asset ID');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `attached_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Attached Document Reference');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `committee_code` SET TAGS ('dbx_business_glossary_term' = 'Committee Session ID');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|pending_review');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|CAD|EUR|GBP|CHF|JPY');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `decision_maker` SET TAGS ('dbx_business_glossary_term' = 'Decision Maker Name');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `decision_maker_role` SET TAGS ('dbx_business_glossary_term' = 'Decision Maker Role');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `decision_maker_role` SET TAGS ('dbx_value_regex' = 'chair|member|observer');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `decision_number` SET TAGS ('dbx_business_glossary_term' = 'Decision Reference Number');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `decision_status` SET TAGS ('dbx_business_glossary_term' = 'Decision Status');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `decision_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|executed|closed');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `decision_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Decision Timestamp');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `decision_type` SET TAGS ('dbx_business_glossary_term' = 'Decision Type');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `decision_type` SET TAGS ('dbx_value_regex' = 'approval|rejection|revision|policy_exception');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `filing_deadline` SET TAGS ('dbx_business_glossary_term' = 'Filing Deadline');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `investment_amount_approved` SET TAGS ('dbx_business_glossary_term' = 'Approved Investment Amount');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `investment_vehicle_type` SET TAGS ('dbx_business_glossary_term' = 'Investment Vehicle Type');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `investment_vehicle_type` SET TAGS ('dbx_value_regex' = 'public_equity|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `mandate_change_flag` SET TAGS ('dbx_business_glossary_term' = 'Mandate Change Flag');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Decision Notes');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `policy_exception_flag` SET TAGS ('dbx_business_glossary_term' = 'Policy Exception Flag');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `regulatory_filing_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Required');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `risk_rating_after` SET TAGS ('dbx_business_glossary_term' = 'Post‑Decision Risk Rating');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `risk_rating_after` SET TAGS ('dbx_value_regex' = 'low|medium|high');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `risk_rating_before` SET TAGS ('dbx_business_glossary_term' = 'Pre‑Decision Risk Rating');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `risk_rating_before` SET TAGS ('dbx_value_regex' = 'low|medium|high');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `subject` SET TAGS ('dbx_business_glossary_term' = 'Decision Subject');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Record Updated By');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `votes_abstain` SET TAGS ('dbx_business_glossary_term' = 'Votes Abstain');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `votes_against` SET TAGS ('dbx_business_glossary_term' = 'Votes Against');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `votes_for` SET TAGS ('dbx_business_glossary_term' = 'Votes For');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `voting_outcome` SET TAGS ('dbx_business_glossary_term' = 'Voting Outcome');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `voting_outcome` SET TAGS ('dbx_value_regex' = 'unanimous|majority|split');
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` SET TAGS ('dbx_subdomain' = 'governance_ethics');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_of_interest_id` SET TAGS ('dbx_business_glossary_term' = 'Conflict of Interest ID');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `declarant_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Declarant Employee Identifier (PII)');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `declarant_employee_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `declarant_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Opportunity Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_audit_trail` SET TAGS ('dbx_business_glossary_term' = 'Audit Trail');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_category` SET TAGS ('dbx_business_glossary_term' = 'Conflict Category');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_category` SET TAGS ('dbx_value_regex' = 'financial|operational|governance|legal|reputational|other');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Level');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_confidentiality_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_description` SET TAGS ('dbx_business_glossary_term' = 'Conflict Description');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_end_date` SET TAGS ('dbx_business_glossary_term' = 'Conflict End Date');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_esg_impact` SET TAGS ('dbx_business_glossary_term' = 'ESG Impact');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_identifier` SET TAGS ('dbx_business_glossary_term' = 'Conflict Identifier');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_last_reviewed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Reviewed Timestamp');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_of_interest_status` SET TAGS ('dbx_business_glossary_term' = 'Conflict Status');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_of_interest_status` SET TAGS ('dbx_value_regex' = 'pending|reviewed|approved|rejected|resolved|closed');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_publication_date` SET TAGS ('dbx_business_glossary_term' = 'Publication Date');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_related_asset` SET TAGS ('dbx_business_glossary_term' = 'Related Asset Identifier');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_related_fund` SET TAGS ('dbx_business_glossary_term' = 'Related Fund Identifier');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_resolution_action` SET TAGS ('dbx_business_glossary_term' = 'Resolution Action');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_resolution_by` SET TAGS ('dbx_business_glossary_term' = 'Resolution Performed By (PII)');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_resolution_by` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_resolution_by` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_resolution_comments` SET TAGS ('dbx_business_glossary_term' = 'Resolution Comments');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_review_comments` SET TAGS ('dbx_business_glossary_term' = 'Review Comments');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_review_date` SET TAGS ('dbx_business_glossary_term' = 'Conflict Review Date');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_reviewed_by` SET TAGS ('dbx_business_glossary_term' = 'Conflict Reviewed By (PII)');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_reviewed_by` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_reviewed_by` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_risk_assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Date');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_risk_score` SET TAGS ('dbx_business_glossary_term' = 'Conflict Risk Score');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_start_date` SET TAGS ('dbx_business_glossary_term' = 'Conflict Start Date');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_status_reason` SET TAGS ('dbx_business_glossary_term' = 'Status Reason');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_title` SET TAGS ('dbx_business_glossary_term' = 'Conflict Title');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_type` SET TAGS ('dbx_business_glossary_term' = 'Conflict Type');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `conflict_type` SET TAGS ('dbx_value_regex' = 'personal_investment|related_party|board_membership|prior_employment|family_relationship|other');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `data_classification` SET TAGS ('dbx_business_glossary_term' = 'Data Classification');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `data_classification` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `declarant_name` SET TAGS ('dbx_business_glossary_term' = 'Declarant Full Name (PII)');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `declarant_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `declarant_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `declarant_role` SET TAGS ('dbx_business_glossary_term' = 'Declarant Role');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `declarant_role` SET TAGS ('dbx_value_regex' = 'investment_analyst|investment_committee_member|portfolio_manager|risk_officer|compliance_officer|other');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `disclosure_date` SET TAGS ('dbx_business_glossary_term' = 'Disclosure Date');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Is Mandatory');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `mitigation_action` SET TAGS ('dbx_business_glossary_term' = 'Mitigation Action');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `related_party_identifier` SET TAGS ('dbx_business_glossary_term' = 'Related Party Identifier (PII)');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `related_party_identifier` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `related_party_identifier` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `related_party_name` SET TAGS ('dbx_business_glossary_term' = 'Related Party Name (PII)');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `related_party_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `related_party_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `related_party_relationship` SET TAGS ('dbx_business_glossary_term' = 'Related Party Relationship');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `related_party_relationship` SET TAGS ('dbx_value_regex' = 'family|business|employment|board|other');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `reporting_status` SET TAGS ('dbx_business_glossary_term' = 'Reporting Status');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `reporting_status` SET TAGS ('dbx_value_regex' = 'not_reported|reported|escalated');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Resolution Date');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `severity_level` SET TAGS ('dbx_business_glossary_term' = 'Severity Level');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `severity_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`compliance`.`policy_document` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`compliance`.`policy_document` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`policy_document` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`policy_document` SET TAGS ('dbx_subdomain' = 'governance_ethics');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `policy_document_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Document Identifier');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `author_name` SET TAGS ('dbx_business_glossary_term' = 'Author Name');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `policy_document_category` SET TAGS ('dbx_business_glossary_term' = 'Policy Category');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `checksum` SET TAGS ('dbx_business_glossary_term' = 'File Checksum (SHA‑256)');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `checksum` SET TAGS ('dbx_value_regex' = '^[A-Fa-f0-9]{64}$');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `compliance_area` SET TAGS ('dbx_business_glossary_term' = 'Compliance Area');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `compliance_area` SET TAGS ('dbx_value_regex' = 'investment|operational|legal|risk|esg');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Level');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `policy_document_description` SET TAGS ('dbx_business_glossary_term' = 'Policy Description');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `document_format` SET TAGS ('dbx_business_glossary_term' = 'Document Format');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `document_format` SET TAGS ('dbx_value_regex' = 'pdf|docx|html');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `file_path` SET TAGS ('dbx_business_glossary_term' = 'File Path');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `file_size_bytes` SET TAGS ('dbx_business_glossary_term' = 'File Size (Bytes)');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Is Mandatory');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `last_reviewed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Reviewed Timestamp');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `owner_department` SET TAGS ('dbx_business_glossary_term' = 'Owner Department');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `policy_document_status` SET TAGS ('dbx_business_glossary_term' = 'Policy Status');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `policy_document_status` SET TAGS ('dbx_value_regex' = 'draft|active|suspended|retired|archived');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `policy_owner_contact` SET TAGS ('dbx_business_glossary_term' = 'Policy Owner Contact Email');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `policy_owner_contact` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `policy_owner_contact` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `policy_owner_contact` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `policy_type` SET TAGS ('dbx_business_glossary_term' = 'Policy Type');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `policy_type` SET TAGS ('dbx_value_regex' = 'investment|aml|esg|trading|risk|governance');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `retention_period_days` SET TAGS ('dbx_business_glossary_term' = 'Retention Period (Days)');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'Review Date');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `reviewed_by` SET TAGS ('dbx_business_glossary_term' = 'Reviewed By');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `revision_number` SET TAGS ('dbx_business_glossary_term' = 'Revision Number');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Policy Title');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`compliance`.`policy_document` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Policy Version Number');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` SET TAGS ('dbx_subdomain' = 'governance_ethics');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `policy_exception_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Exception ID');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approver Identifier');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Requestor Identifier');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `policy_document_id` SET TAGS ('dbx_business_glossary_term' = 'Policy Document Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `related_calendar_regulatory_calendar_id` SET TAGS ('dbx_business_glossary_term' = 'Related Regulatory Calendar ID');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `rule_id` SET TAGS ('dbx_business_glossary_term' = 'Rule Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'approved|rejected|escalated');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `approver_name` SET TAGS ('dbx_business_glossary_term' = 'Approver Full Name');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `approver_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `approver_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `exception_number` SET TAGS ('dbx_business_glossary_term' = 'Exception Number');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `exception_number` SET TAGS ('dbx_value_regex' = '^EXC-[0-9]{6}$');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `exception_type` SET TAGS ('dbx_business_glossary_term' = 'Exception Type');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `exception_type` SET TAGS ('dbx_value_regex' = 'temporary|permanent');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `expiration_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Exception Expiration Timestamp');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active Flag');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `justification` SET TAGS ('dbx_business_glossary_term' = 'Exception Business Justification');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `monetary_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Monetary Limit Amount');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Exception Notes');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `policy_exception_status` SET TAGS ('dbx_business_glossary_term' = 'Exception Status');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `policy_exception_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|revoked|expired');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `request_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Exception Request Timestamp');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `requestor_department` SET TAGS ('dbx_business_glossary_term' = 'Requestor Department');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `requestor_name` SET TAGS ('dbx_business_glossary_term' = 'Requestor Full Name');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `requestor_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `requestor_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Record Updated By');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Record Created By');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `regulatory_change_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Change ID');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Amendment Number (Number)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `change_type` SET TAGS ('dbx_business_glossary_term' = 'Change Type (Type)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `change_type` SET TAGS ('dbx_value_regex' = 'new|amendment|guidance');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `compliance_deadline` SET TAGS ('dbx_business_glossary_term' = 'Compliance Deadline (Deadline)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status (Compliance)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|in_progress|not_applicable');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp (Created)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `regulatory_change_description` SET TAGS ('dbx_business_glossary_term' = 'Regulation Description (Description)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `document_reference` SET TAGS ('dbx_business_glossary_term' = 'Document Reference (Reference)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date (Date)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date (Date)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `impact_assessment` SET TAGS ('dbx_business_glossary_term' = 'Impact Assessment (Assessment)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `is_external` SET TAGS ('dbx_business_glossary_term' = 'Is External (External)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Is Mandatory (Mandatory)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `last_reviewed_date` SET TAGS ('dbx_business_glossary_term' = 'Last Reviewed Date (Reviewed)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date (Next Review)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes (Notes)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `penalty_risk_estimate` SET TAGS ('dbx_business_glossary_term' = 'Penalty Risk Estimate (Penalty)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `regulation_code` SET TAGS ('dbx_business_glossary_term' = 'Regulation Code (Code)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `regulatory_body_contact` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Body Contact (Contact)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `regulatory_change_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Change Status (Status)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `regulatory_change_status` SET TAGS ('dbx_value_regex' = 'draft|active|retired|pending');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `related_regulation_code` SET TAGS ('dbx_business_glossary_term' = 'Related Regulation ID (Related ID)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `required_action` SET TAGS ('dbx_business_glossary_term' = 'Required Action (Action)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `responsible_party` SET TAGS ('dbx_business_glossary_term' = 'Responsible Party (Party)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `risk_level` SET TAGS ('dbx_business_glossary_term' = 'Risk Level (Risk)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `risk_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `severity` SET TAGS ('dbx_business_glossary_term' = 'Severity (Severity)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `severity` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Regulation Title (Title)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_change` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp (Updated)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `regulatory_exam_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Exam ID');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status Post‑Exam');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|exempt');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `corrective_action_deadline` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action Deadline');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `corrective_action_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective Action Required Flag');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `documentation_url` SET TAGS ('dbx_business_glossary_term' = 'Examination Documentation URL');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `exam_number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Exam Number');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `exam_outcome` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Exam Outcome');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `exam_outcome` SET TAGS ('dbx_value_regex' = 'pass|fail|conditional|pending');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `exam_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Exam Timestamp');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `exam_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Exam Type');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `exam_type` SET TAGS ('dbx_value_regex' = 'initial|routine|special|follow_up');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `examiner_email` SET TAGS ('dbx_business_glossary_term' = 'Examiner Email Address');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `examiner_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `examiner_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `examiner_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `examiner_name` SET TAGS ('dbx_business_glossary_term' = 'Examiner Name');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `findings_summary` SET TAGS ('dbx_business_glossary_term' = 'Examination Findings Summary');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Examination Notes');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `penalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Penalty Amount');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `regulatory_exam_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Exam Status');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `regulatory_exam_status` SET TAGS ('dbx_value_regex' = 'scheduled|in_progress|completed|closed|cancelled');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Risk Rating');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`compliance`.`regulatory_exam` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `exam_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Exam Finding ID');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Examiner ID');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `regulatory_exam_id` SET TAGS ('dbx_business_glossary_term' = 'Examination ID');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `actual_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Resolution Date');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `exam_finding_category` SET TAGS ('dbx_business_glossary_term' = 'Finding Category (Deficiency, Observation, Recommendation, Violation)');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `exam_finding_category` SET TAGS ('dbx_value_regex' = 'deficiency|observation|recommendation|violation');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `compliance_rule_code` SET TAGS ('dbx_business_glossary_term' = 'Compliance Rule Code');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `compliance_rule_description` SET TAGS ('dbx_business_glossary_term' = 'Compliance Rule Description');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `data_classification` SET TAGS ('dbx_business_glossary_term' = 'Data Classification Level');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `exam_finding_description` SET TAGS ('dbx_business_glossary_term' = 'Finding Description');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Remediation Due Date');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `escalation_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Escalation Contact Email');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `escalation_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `escalation_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `escalation_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `escalation_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Escalation Contact Name');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `escalation_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `escalation_contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `escalation_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Escalation Contact Phone');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `escalation_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `escalation_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `exam_finding_status` SET TAGS ('dbx_business_glossary_term' = 'Finding Lifecycle Status (Open, In Progress, Resolved, Closed, Rejected)');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `exam_finding_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|resolved|closed|rejected');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `examiner_name` SET TAGS ('dbx_business_glossary_term' = 'Examiner Full Name');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `examiner_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `examiner_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `finding_reference` SET TAGS ('dbx_business_glossary_term' = 'Finding Reference Code');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `is_waiver_requested` SET TAGS ('dbx_business_glossary_term' = 'Waiver Requested Flag');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction (ISO Country Code)');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `penalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Penalty Amount');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `recommendation` SET TAGS ('dbx_business_glossary_term' = 'Recommended Action');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `regulation_code` SET TAGS ('dbx_business_glossary_term' = 'Regulation Code');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `remediation_plan` SET TAGS ('dbx_business_glossary_term' = 'Remediation Plan Description');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `reported_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Finding Reported Timestamp');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `resolved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Finding Resolved Timestamp');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Score (0‑100)');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `severity` SET TAGS ('dbx_business_glossary_term' = 'Finding Severity Level (Critical, High, Medium, Low, Informational)');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `severity` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low|informational');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `sub_category` SET TAGS ('dbx_business_glossary_term' = 'Finding Sub‑Category');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `supporting_document_url` SET TAGS ('dbx_business_glossary_term' = 'Supporting Document URL');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `waiver_approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Waiver Approval Timestamp');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `waiver_status` SET TAGS ('dbx_business_glossary_term' = 'Waiver Status');
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ALTER COLUMN `waiver_status` SET TAGS ('dbx_value_regex' = 'requested|approved|denied|not_applicable');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `beneficiary_disclosure_id` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Disclosure ID');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `beneficiary_member_id` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary ID');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary ID');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `member_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `member_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `participating_employer_id` SET TAGS ('dbx_business_glossary_term' = 'Employer ID');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `acceptance_date` SET TAGS ('dbx_business_glossary_term' = 'Acceptance Date');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Amount');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `attached_document_url` SET TAGS ('dbx_business_glossary_term' = 'Attached Document URL');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `beneficiary_disclosure_status` SET TAGS ('dbx_business_glossary_term' = 'Disclosure Status');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `beneficiary_disclosure_status` SET TAGS ('dbx_value_regex' = 'draft|issued|rejected|withdrawn|archived');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Comments');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Compliance Flag');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `disclosure_number` SET TAGS ('dbx_business_glossary_term' = 'Disclosure Number');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `disclosure_type` SET TAGS ('dbx_business_glossary_term' = 'Disclosure Type');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `disclosure_type` SET TAGS ('dbx_value_regex' = 'annual_statement|benefit_notice|plan_amendment|sfdr|other');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `filing_deadline` SET TAGS ('dbx_business_glossary_term' = 'Filing Deadline Date');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `filing_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Filing Fee Amount');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `filing_format` SET TAGS ('dbx_business_glossary_term' = 'Filing Format');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `filing_format` SET TAGS ('dbx_value_regex' = 'pdf|xml|json|html');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Filing Status');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `filing_status` SET TAGS ('dbx_value_regex' = 'pending|submitted|accepted|rejected|withdrawn');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Amount');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Is Mandatory');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `issuance_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Issuance Timestamp');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_value_regex' = 'USA|CAN|GBR|AUS|FRA|DEU');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Amount');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `rejection_date` SET TAGS ('dbx_business_glossary_term' = 'Rejection Date');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `reporting_period_end` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `reporting_period_start` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Date');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `submission_method` SET TAGS ('dbx_business_glossary_term' = 'Submission Method');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `submission_method` SET TAGS ('dbx_value_regex' = 'electronic|paper|portal|email');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Version Number');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `audit_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding ID');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Auditor ID');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `rule_id` SET TAGS ('dbx_business_glossary_term' = 'Rule Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `audit_finding_status` SET TAGS ('dbx_business_glossary_term' = 'Finding Status');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `audit_finding_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|closed|rejected');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `audit_period_end` SET TAGS ('dbx_business_glossary_term' = 'Audit Period End Date');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `audit_period_start` SET TAGS ('dbx_business_glossary_term' = 'Audit Period Start Date');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `audit_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Audit Reference Number');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `audit_source_system` SET TAGS ('dbx_business_glossary_term' = 'Audit Source System');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `audit_type` SET TAGS ('dbx_business_glossary_term' = 'Audit Type');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `audit_type` SET TAGS ('dbx_value_regex' = 'internal|external|soc2|iso27001|regulatory');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `auditor_name` SET TAGS ('dbx_business_glossary_term' = 'Auditor Full Name');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `auditor_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `auditor_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `compliance_impact` SET TAGS ('dbx_business_glossary_term' = 'Compliance Impact');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `control_code` SET TAGS ('dbx_business_glossary_term' = 'Control Identifier');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `control_name` SET TAGS ('dbx_business_glossary_term' = 'Control Name');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `escalation_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Escalation Contact Email');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `escalation_contact_email` SET TAGS ('dbx_value_regex' = '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,}$');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `escalation_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `escalation_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `escalation_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Escalation Contact Name');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `escalation_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `escalation_contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `evidence_document_code` SET TAGS ('dbx_business_glossary_term' = 'Evidence Document ID');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `evidence_document_url` SET TAGS ('dbx_business_glossary_term' = 'Evidence Document URL');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `financial_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Financial Impact Amount');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `financial_impact_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `financial_impact_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `financial_impact_currency` SET TAGS ('dbx_business_glossary_term' = 'Financial Impact Currency');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `financial_impact_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `finding_category` SET TAGS ('dbx_business_glossary_term' = 'Finding Category');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `finding_category` SET TAGS ('dbx_value_regex' = 'financial|operational|compliance|risk|it|governance');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `finding_description` SET TAGS ('dbx_business_glossary_term' = 'Finding Description');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `finding_number` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Number');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `impact_assessment` SET TAGS ('dbx_business_glossary_term' = 'Impact Assessment');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `is_critical` SET TAGS ('dbx_business_glossary_term' = 'Is Critical Flag');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `is_repeat_finding` SET TAGS ('dbx_business_glossary_term' = 'Is Repeat Finding Flag');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `operational_impact` SET TAGS ('dbx_business_glossary_term' = 'Operational Impact');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `recommendation` SET TAGS ('dbx_business_glossary_term' = 'Remediation Recommendation');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `related_process` SET TAGS ('dbx_business_glossary_term' = 'Related Business Process');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `remediation_action` SET TAGS ('dbx_business_glossary_term' = 'Remediation Action');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `remediation_cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Remediation Cost Amount');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `remediation_cost_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `remediation_cost_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `remediation_due_date` SET TAGS ('dbx_business_glossary_term' = 'Remediation Due Date');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `remediation_effectiveness_score` SET TAGS ('dbx_business_glossary_term' = 'Remediation Effectiveness Score');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `remediation_owner` SET TAGS ('dbx_business_glossary_term' = 'Remediation Owner');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `remediation_owner` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `remediation_owner` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `remediation_status` SET TAGS ('dbx_business_glossary_term' = 'Remediation Status');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `remediation_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed|deferred');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `reported_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Finding Reported Timestamp');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `root_cause_analysis` SET TAGS ('dbx_business_glossary_term' = 'Root Cause Analysis');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `severity_level` SET TAGS ('dbx_business_glossary_term' = 'Severity Level');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `severity_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Update Timestamp');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` SET TAGS ('dbx_subdomain' = 'governance_ethics');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `personal_account_dealing_id` SET TAGS ('dbx_business_glossary_term' = 'Personal Account Dealing ID');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Employee Identifier');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `instrument_id` SET TAGS ('dbx_business_glossary_term' = 'Instrument Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `rule_id` SET TAGS ('dbx_business_glossary_term' = 'Rule Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `business_event_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Dealing Effective Timestamp');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `compliance_review_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Review Status');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `compliance_review_status` SET TAGS ('dbx_value_regex' = 'not_started|in_review|completed|escalated');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `compliance_review_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Compliance Review Timestamp');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `data_classification` SET TAGS ('dbx_business_glossary_term' = 'Data Classification Level');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date of Dealing');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `employee_role` SET TAGS ('dbx_business_glossary_term' = 'Employee Role');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `expiration_date` SET TAGS ('dbx_business_glossary_term' = 'Expiration Date of Dealing');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Fee Amount');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Transaction Amount');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `is_waiver_requested` SET TAGS ('dbx_business_glossary_term' = 'Waiver Requested Flag');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction (ISO 3166-1 Alpha-3 Country Code)');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `justification_text` SET TAGS ('dbx_business_glossary_term' = 'Dealing Justification Text');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Dealing Lifecycle Status');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|under_review|cleared|rejected|closed');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Transaction Amount');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Additional Notes');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `preclearance_approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Preclearance Approval Timestamp');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `preclearance_approver` SET TAGS ('dbx_business_glossary_term' = 'Preclearance Approver Name');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `preclearance_request_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Preclearance Request Timestamp');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `preclearance_status` SET TAGS ('dbx_business_glossary_term' = 'Preclearance Request Status');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `preclearance_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|withdrawn');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `related_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Related Document Reference');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `request_number` SET TAGS ('dbx_business_glossary_term' = 'Personal Account Dealing Request Number');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating for Dealing');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `trade_execution_venue` SET TAGS ('dbx_business_glossary_term' = 'Trade Execution Venue');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `trade_execution_venue` SET TAGS ('dbx_value_regex' = 'NYSE|LSE|OTC|BATS|TSX|JPX');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `transaction_price` SET TAGS ('dbx_business_glossary_term' = 'Transaction Price per Unit');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `transaction_quantity` SET TAGS ('dbx_business_glossary_term' = 'Transaction Quantity (Number of Shares or Units)');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `transaction_reason` SET TAGS ('dbx_business_glossary_term' = 'Reason for Transaction');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'Transaction Type (Buy, Sell, Short)');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'buy|sell|short');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `waiver_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Waiver Approval Status');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `waiver_approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|denied');
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ALTER COLUMN `waiver_approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Waiver Approval Timestamp');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority ID (REG_AUTH_ID)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `abbreviation` SET TAGS ('dbx_business_glossary_term' = 'Abbreviation (ABBR)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_code` SET TAGS ('dbx_business_glossary_term' = 'Authority Code (AUTH_CODE)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,10}$');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas` SET TAGS ('dbx_business_glossary_term' = 'Authority Regulation Areas (AUTH_REG_AREAS)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas` SET TAGS ('dbx_value_regex' = '^[ws,]+$');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas_description` SET TAGS ('dbx_business_glossary_term' = 'Authority Regulation Areas Description (AUTH_REG_AREAS_DESC)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas_end_date` SET TAGS ('dbx_business_glossary_term' = 'Authority Regulation Areas End Date (AUTH_REG_AREAS_END_DATE)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas_notes` SET TAGS ('dbx_business_glossary_term' = 'Authority Regulation Areas Notes (AUTH_REG_AREAS_NOTES)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas_start_date` SET TAGS ('dbx_business_glossary_term' = 'Authority Regulation Areas Start Date (AUTH_REG_AREAS_START_DATE)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas_status` SET TAGS ('dbx_business_glossary_term' = 'Authority Regulation Areas Status (AUTH_REG_AREAS_STATUS)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|terminated');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas_type` SET TAGS ('dbx_business_glossary_term' = 'Authority Regulation Areas Type (AUTH_REG_AREAS_TYPE)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas_type_code` SET TAGS ('dbx_business_glossary_term' = 'Authority Regulation Areas Type Code (AUTH_REG_AREAS_TYPE_CODE)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas_type_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]+$');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas_type_description` SET TAGS ('dbx_business_glossary_term' = 'Authority Regulation Areas Type Description (AUTH_REG_AREAS_TYPE_DESC)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas_type_end_date` SET TAGS ('dbx_business_glossary_term' = 'Authority Regulation Areas Type End Date (AUTH_REG_AREAS_TYPE_END_DATE)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas_type_name` SET TAGS ('dbx_business_glossary_term' = 'Authority Regulation Areas Type Name (AUTH_REG_AREAS_TYPE_NAME)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas_type_notes` SET TAGS ('dbx_business_glossary_term' = 'Authority Regulation Areas Type Notes (AUTH_REG_AREAS_TYPE_NOTES)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas_type_start_date` SET TAGS ('dbx_business_glossary_term' = 'Authority Regulation Areas Type Start Date (AUTH_REG_AREAS_TYPE_START_DATE)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas_type_status` SET TAGS ('dbx_business_glossary_term' = 'Authority Regulation Areas Type Status (AUTH_REG_AREAS_TYPE_STATUS)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_areas_type_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|terminated');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_codes` SET TAGS ('dbx_business_glossary_term' = 'Authority Regulation Codes (AUTH_REG_CODES)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_codes` SET TAGS ('dbx_value_regex' = '^[A-Z0-9,]+$');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_names` SET TAGS ('dbx_business_glossary_term' = 'Authority Regulation Names (AUTH_REG_NAMES)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_regulation_names` SET TAGS ('dbx_value_regex' = '^[ws,]+$');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_type` SET TAGS ('dbx_business_glossary_term' = 'Authority Type (AUTH_TYPE)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_type` SET TAGS ('dbx_value_regex' = 'prudential|conduct|market|other');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_website` SET TAGS ('dbx_business_glossary_term' = 'Authority Website (AUTH_WEBSITE)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `authority_website` SET TAGS ('dbx_value_regex' = '^(https?://)?[w.-]+(?:.[w.-]+)+[/w.-]*$');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_address` SET TAGS ('dbx_business_glossary_term' = 'Contact Address (CONTACT_ADDRESS)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_city` SET TAGS ('dbx_business_glossary_term' = 'Contact City (CONTACT_CITY)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_country` SET TAGS ('dbx_business_glossary_term' = 'Contact Country (CONTACT_COUNTRY)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_country` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_country` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_email` SET TAGS ('dbx_business_glossary_term' = 'Contact Email (CONTACT_EMAIL)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_fax` SET TAGS ('dbx_business_glossary_term' = 'Contact Fax (CONTACT_FAX)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_fax` SET TAGS ('dbx_value_regex' = '^[+]?d{1,15}$');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_fax` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_fax` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_person_email` SET TAGS ('dbx_business_glossary_term' = 'Contact Person Email (CONTACT_PERSON_EMAIL)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_person_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_person_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_person_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_person_name` SET TAGS ('dbx_business_glossary_term' = 'Contact Person Name (CONTACT_PERSON_NAME)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_person_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_person_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_person_phone` SET TAGS ('dbx_business_glossary_term' = 'Contact Person Phone (CONTACT_PERSON_PHONE)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_person_phone` SET TAGS ('dbx_value_regex' = '^[+]?d{1,15}$');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_person_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_person_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_person_title` SET TAGS ('dbx_business_glossary_term' = 'Contact Person Title (CONTACT_PERSON_TITLE)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Contact Phone (CONTACT_PHONE)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_phone` SET TAGS ('dbx_value_regex' = '^[+]?d{1,15}$');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Contact Postal Code (CONTACT_POSTAL_CODE)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_state` SET TAGS ('dbx_business_glossary_term' = 'Contact State (CONTACT_STATE)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_state` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_state` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_website` SET TAGS ('dbx_business_glossary_term' = 'Contact Website (CONTACT_WEBSITE)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `contact_website` SET TAGS ('dbx_value_regex' = '^(https?://)?[w.-]+(?:.[w.-]+)+[/w.-]*$');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp (CREATED_TS)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date (EFF_DATE)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction (JURISDICTION)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Name (LEGAL_NAME)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `regulatory_authority_name` SET TAGS ('dbx_business_glossary_term' = 'Name (NAME)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes (NOTES)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `regulatory_authority_status` SET TAGS ('dbx_business_glossary_term' = 'Status (STATUS)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `regulatory_authority_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|terminated');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date (TERM_DATE)');
ALTER TABLE `asset_management`.`compliance`.`regulatory_authority` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp (UPDATED_TS)');
ALTER TABLE `asset_management`.`compliance`.`obligation` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`compliance`.`obligation` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`obligation` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`obligation` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation ID (OBL_ID)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `rule_id` SET TAGS ('dbx_business_glossary_term' = 'Rule Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `obligation_code` SET TAGS ('dbx_business_glossary_term' = 'Obligation Code (OBL_CODE)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status (COMP_STATUS)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|in_review|pending_review');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp (CREATED_TS)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (CURR_CODE)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `data_classification` SET TAGS ('dbx_business_glossary_term' = 'Data Classification (DATA_CLASS)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `obligation_description` SET TAGS ('dbx_business_glossary_term' = 'Obligation Description (OBL_DESC)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Effective End Date (EFF_END_DATE)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Start Date (EFF_START_DATE)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `escalation_contact` SET TAGS ('dbx_business_glossary_term' = 'Escalation Contact (ESC_CONTACT)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `filing_deadline` SET TAGS ('dbx_business_glossary_term' = 'Filing Deadline (FIL_DEADLINE)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `filing_frequency` SET TAGS ('dbx_business_glossary_term' = 'Filing Frequency (FIL_FREQ)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `filing_method` SET TAGS ('dbx_business_glossary_term' = 'Filing Method (FIL_METHOD)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `filing_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Filing Reference Number (FIL_REF_NUM)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Filing Status (FIL_STATUS)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `filing_status` SET TAGS ('dbx_value_regex' = 'submitted|pending|approved|rejected|withdrawn');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `is_external` SET TAGS ('dbx_business_glossary_term' = 'Is External (IS_EXTERNAL)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Is Mandatory (IS_MANDATORY)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `is_reported` SET TAGS ('dbx_business_glossary_term' = 'Is Reported (IS_REPORTED)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `last_filed_date` SET TAGS ('dbx_business_glossary_term' = 'Last Filed Date (LAST_FILLED_DATE)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `last_reviewed_date` SET TAGS ('dbx_business_glossary_term' = 'Last Reviewed Date (LAST_REVIEW_DATE)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `obligation_name` SET TAGS ('dbx_business_glossary_term' = 'Obligation Name (OBL_NAME)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `next_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Due Date (NEXT_DUE_DATE)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Review Date (NEXT_REVIEW_DATE)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes (NOTES)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `obligation_status` SET TAGS ('dbx_business_glossary_term' = 'Obligation Status (OBL_STATUS)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `obligation_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|terminated|draft');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `obligation_type` SET TAGS ('dbx_business_glossary_term' = 'Obligation Type (OBL_TYPE)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `penalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Penalty Amount (PEN_AMT)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `penalty_currency` SET TAGS ('dbx_business_glossary_term' = 'Penalty Currency (PEN_CURR)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `penalty_risk_level` SET TAGS ('dbx_business_glossary_term' = 'Penalty Risk Level (PEN_RISK_LEVEL)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `penalty_risk_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical|unknown');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `remediation_action` SET TAGS ('dbx_business_glossary_term' = 'Remediation Action (REMED_ACTION)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `remediation_cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Remediation Cost Amount (REMED_COST)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `remediation_due_date` SET TAGS ('dbx_business_glossary_term' = 'Remediation Due Date (REMED_DUE_DATE)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `remediation_status` SET TAGS ('dbx_business_glossary_term' = 'Remediation Status (REMED_STATUS)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `remediation_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|failed');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `reporting_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Date (REP_DATE)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `required_documentation` SET TAGS ('dbx_business_glossary_term' = 'Required Documentation (REQ_DOC)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `responsible_party` SET TAGS ('dbx_business_glossary_term' = 'Responsible Party (RESP_PARTY)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `risk_level` SET TAGS ('dbx_business_glossary_term' = 'Risk Level (RISK_LEVEL)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `risk_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `risk_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Score (RISK_SCORE)');
ALTER TABLE `asset_management`.`compliance`.`obligation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp (UPDATED_TS)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `sfdr_disclosure_id` SET TAGS ('dbx_business_glossary_term' = 'SFDR Disclosure ID (SFDR_DID)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `classification_or_type` SET TAGS ('dbx_business_glossary_term' = 'Disclosure Type (DIS_TYPE)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `classification_or_type` SET TAGS ('dbx_value_regex' = 'entity-level|product-level|periodic');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Compliance Flag (COMPLIANCE_FLAG)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp (CREATED_TS)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (CURR_CODE)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = 'USD|EUR|GBP|CAD|AUD|JPY');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `disclosure_reference` SET TAGS ('dbx_business_glossary_term' = 'Disclosure Reference (DIS_REF)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date (EFF_FROM)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date (EFF_UNTIL)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `filing_acceptance_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Acceptance Date (FILING_ACCEPTANCE)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `filing_deadline` SET TAGS ('dbx_business_glossary_term' = 'Filing Deadline Date (FILING_DEADLINE)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `filing_document_url` SET TAGS ('dbx_business_glossary_term' = 'Filing Document URL (FILING_DOC_URL)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `filing_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Filing Fee Amount (FILING_FEE)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `filing_format` SET TAGS ('dbx_business_glossary_term' = 'Filing Format (FILING_FORMAT)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `filing_format` SET TAGS ('dbx_value_regex' = 'PDF|XML|XLSX');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `filing_method` SET TAGS ('dbx_business_glossary_term' = 'Filing Method (FILING_METHOD)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `filing_method` SET TAGS ('dbx_value_regex' = 'electronic|paper');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `filing_period_end` SET TAGS ('dbx_business_glossary_term' = 'Filing Period End Date (FILING_PERIOD_END)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `filing_period_start` SET TAGS ('dbx_business_glossary_term' = 'Filing Period Start Date (FILING_PERIOD_START)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `filing_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Filing Reference Number (FILING_REF_NUM)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `filing_rejection_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Rejection Date (FILING_REJECTION)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `filing_rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Filing Rejection Reason (FILING_REJ_REASON)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Filing Status (FILING_STATUS)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `filing_status` SET TAGS ('dbx_value_regex' = 'submitted|accepted|rejected|pending');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `filing_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Filing Submission Date (FILING_SUBMISSION)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `filing_version` SET TAGS ('dbx_business_glossary_term' = 'Filing Version (FILING_VERSION)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction (JURISDICT)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_value_regex' = 'CAN|USA|GBR|FRA|DEU|JPN');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Lifecycle Status (LIFE_STATUS)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_value_regex' = 'draft|pending|approved|filed|archived');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes (NOTES)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `updated_by` SET TAGS ('dbx_business_glossary_term' = 'Updated By (UPDATED_BY)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp (UPDATED_TS)');
ALTER TABLE `asset_management`.`compliance`.`sfdr_disclosure` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By (CREATED_BY)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` SET TAGS ('dbx_subdomain' = 'regulatory_reporting');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `gips_compliance_record_id` SET TAGS ('dbx_business_glossary_term' = 'GIPS Compliance Record ID (GIPS_COMPLIANCE_RECORD_ID)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `composite_id` SET TAGS ('dbx_business_glossary_term' = 'Composite ID (COMPOSITE_ID)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `policy_document_id` SET TAGS ('dbx_business_glossary_term' = 'Document ID (DOCUMENT_ID)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `assertion_date` SET TAGS ('dbx_business_glossary_term' = 'Assertion Date (ASSERTION_DATE)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status (COMPLIANCE_STATUS)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|non_compliant|pending|in_review|under_review|approved');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `composite_end_date` SET TAGS ('dbx_business_glossary_term' = 'Composite End Date (COMPOSITE_END_DATE)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `composite_start_date` SET TAGS ('dbx_business_glossary_term' = 'Composite Start Date (COMPOSITE_START_DATE)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `composite_status` SET TAGS ('dbx_business_glossary_term' = 'Composite Status (COMPOSITE_STATUS)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `composite_status` SET TAGS ('dbx_value_regex' = 'active|closed|pending');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `composite_type` SET TAGS ('dbx_business_glossary_term' = 'Composite Type (COMPOSITE_TYPE)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_checksum` SET TAGS ('dbx_business_glossary_term' = 'Document Checksum (DOCUMENT_CHECKSUM)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_checksum` SET TAGS ('dbx_value_regex' = '^[0-9a-fA-F]{32}$');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_created_by` SET TAGS ('dbx_business_glossary_term' = 'Document Created By (DOCUMENT_CREATED_BY)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Document Created Timestamp (DOCUMENT_CREATED_TIMESTAMP)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_date` SET TAGS ('dbx_business_glossary_term' = 'Document Date (DOCUMENT_DATE)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_format` SET TAGS ('dbx_business_glossary_term' = 'Document Format (DOCUMENT_FORMAT)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_format` SET TAGS ('dbx_value_regex' = 'pdf|docx|xlsx|txt');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_is_active` SET TAGS ('dbx_business_glossary_term' = 'Document Is Active (DOCUMENT_IS_ACTIVE)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_is_approved` SET TAGS ('dbx_business_glossary_term' = 'Document Is Approved (DOCUMENT_IS_APPROVED)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_is_archived` SET TAGS ('dbx_business_glossary_term' = 'Document Is Archived (DOCUMENT_IS_ARCHIVED)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_is_confidential` SET TAGS ('dbx_business_glossary_term' = 'Document Is Confidential (DOCUMENT_IS_CONFIDENTIAL)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_is_draft` SET TAGS ('dbx_business_glossary_term' = 'Document Is Draft (DOCUMENT_IS_DRAFT)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_is_external` SET TAGS ('dbx_business_glossary_term' = 'Document Is External (DOCUMENT_IS_EXTERNAL)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_is_final` SET TAGS ('dbx_business_glossary_term' = 'Document Is Final (DOCUMENT_IS_FINAL)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_is_in_review` SET TAGS ('dbx_business_glossary_term' = 'Document Is In Review (DOCUMENT_IS_IN_REVIEW)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_is_pending` SET TAGS ('dbx_business_glossary_term' = 'Document Is Pending (DOCUMENT_IS_PENDING)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_is_pii` SET TAGS ('dbx_business_glossary_term' = 'Document Is PII (DOCUMENT_IS_PII)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_is_restricted` SET TAGS ('dbx_business_glossary_term' = 'Document Is Restricted (DOCUMENT_IS_RESTRICTED)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_is_reviewed` SET TAGS ('dbx_business_glossary_term' = 'Document Is Reviewed (DOCUMENT_IS_REVIEWED)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_is_sensitive` SET TAGS ('dbx_business_glossary_term' = 'Document Is Sensitive (DOCUMENT_IS_SENSITIVE)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_is_signed` SET TAGS ('dbx_business_glossary_term' = 'Document Is Signed (DOCUMENT_IS_SIGNED)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_is_verified` SET TAGS ('dbx_business_glossary_term' = 'Document Is Verified (DOCUMENT_IS_VERIFIED)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_notes` SET TAGS ('dbx_business_glossary_term' = 'Document Notes (DOCUMENT_NOTES)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_path` SET TAGS ('dbx_business_glossary_term' = 'Document Path (DOCUMENT_PATH)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_retention_period_days` SET TAGS ('dbx_business_glossary_term' = 'Document Retention Period (DOCUMENT_RETENTION_PERIOD_DAYS)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_size_bytes` SET TAGS ('dbx_business_glossary_term' = 'Document Size (DOCUMENT_SIZE_BYTES)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_source_system` SET TAGS ('dbx_business_glossary_term' = 'Document Source System (DOCUMENT_SOURCE_SYSTEM)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'Document Status (DOCUMENT_STATUS)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_status` SET TAGS ('dbx_value_regex' = 'draft|final|archived|active|deleted');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_type` SET TAGS ('dbx_business_glossary_term' = 'Document Type (DOCUMENT_TYPE)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_type` SET TAGS ('dbx_value_regex' = 'report|certification|audit|verification');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_updated_by` SET TAGS ('dbx_business_glossary_term' = 'Document Updated By (DOCUMENT_UPDATED_BY)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Document Updated Timestamp (DOCUMENT_UPDATED_TIMESTAMP)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `document_version` SET TAGS ('dbx_business_glossary_term' = 'Document Version (DOCUMENT_VERSION)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `firm_code` SET TAGS ('dbx_business_glossary_term' = 'Firm ID (FIRM_ID)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `firm_name` SET TAGS ('dbx_business_glossary_term' = 'Firm Name (FIRM_NAME)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `firm_status` SET TAGS ('dbx_business_glossary_term' = 'Firm Status (FIRM_STATUS)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `firm_status` SET TAGS ('dbx_value_regex' = 'active|closed|pending');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `method` SET TAGS ('dbx_business_glossary_term' = 'Compliance Assertion Method (METHOD)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `method` SET TAGS ('dbx_value_regex' = 'manual|automated|third_party');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'Compliance Scope (SCOPE)');
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ALTER COLUMN `scope` SET TAGS ('dbx_value_regex' = 'firm-wide|composite-specific');
ALTER TABLE `asset_management`.`compliance`.`certification` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`compliance`.`certification` SET TAGS ('dbx_domain' = 'compliance');
ALTER TABLE `asset_management`.`compliance`.`certification` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`compliance`.`certification` SET TAGS ('dbx_subdomain' = 'governance_ethics');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `certification_id` SET TAGS ('dbx_business_glossary_term' = 'Certification ID (CERT_ID)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Staff ID (STAFF_ID)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `certification_date` SET TAGS ('dbx_business_glossary_term' = 'Certification Date (CERT_DATE)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `certification_status` SET TAGS ('dbx_business_glossary_term' = 'Certification Status (CERT_STATUS)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `certification_status` SET TAGS ('dbx_value_regex' = 'draft|in_progress|completed|failed|revoked');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `certification_type` SET TAGS ('dbx_business_glossary_term' = 'Certification Type (CERT_TYPE)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `certification_type` SET TAGS ('dbx_value_regex' = 'annual_compliance|aml_training|code_of_ethics|gips_compliance');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'Completion Date (COMP_DATE)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `compliance_area` SET TAGS ('dbx_business_glossary_term' = 'Compliance Area (COMP_AREA)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `compliance_area` SET TAGS ('dbx_value_regex' = 'risk_management|esg|financial_reporting|data_privacy');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp (CREATED_TS)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `document_url` SET TAGS ('dbx_business_glossary_term' = 'Certification Document URL (CERT_DOC_URL)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Is Active (IS_ACTIVE)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes (NOTES)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Certification Number (CERT_NUM)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `regulatory_requirement_code` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Code (REG_REQ_CODE)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `regulatory_requirement_name` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Requirement Name (REG_REQ_NAME)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `staff_department` SET TAGS ('dbx_business_glossary_term' = 'Staff Department (STAFF_DEPT)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `staff_department` SET TAGS ('dbx_value_regex' = 'compliance|training|investment|portfolio');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `staff_email` SET TAGS ('dbx_business_glossary_term' = 'Staff Email Address (STAFF_EMAIL)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `staff_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `staff_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `staff_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `staff_name` SET TAGS ('dbx_business_glossary_term' = 'Staff Full Name (STAFF_NAME)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `staff_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `staff_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `staff_phone` SET TAGS ('dbx_business_glossary_term' = 'Staff Phone Number (STAFF_PHONE)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `staff_phone` SET TAGS ('dbx_value_regex' = '^+?[1-9]d{1,14}$');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `staff_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `staff_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `staff_role` SET TAGS ('dbx_business_glossary_term' = 'Staff Role (STAFF_ROLE)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `staff_role` SET TAGS ('dbx_value_regex' = 'compliance_officer|training_coordinator|investment_analyst|portfolio_manager');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `training_certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Training Certificate Number (TRAIN_CERT_NUM)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `training_certificate_url` SET TAGS ('dbx_business_glossary_term' = 'Training Certificate URL (TRAIN_CERT_URL)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `training_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Training Completion Date (TRAIN_COMP_DATE)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `training_module` SET TAGS ('dbx_business_glossary_term' = 'Training Module (TRAIN_MODULE)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `training_passed` SET TAGS ('dbx_business_glossary_term' = 'Training Passed (TRAIN_PASSED)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `training_score` SET TAGS ('dbx_business_glossary_term' = 'Training Score (TRAIN_SCORE)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `training_version` SET TAGS ('dbx_business_glossary_term' = 'Training Version (TRAIN_VERSION)');
ALTER TABLE `asset_management`.`compliance`.`certification` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp (UPDATED_TS)');
