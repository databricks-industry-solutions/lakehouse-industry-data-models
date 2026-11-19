-- Schema for Domain: agreement | Business: Clinical_Trials | Version: v2_ecm
-- Generated on: 2026-11-19 16:37:31

CREATE DATABASE IF NOT EXISTS `clinical_trials_ecm`.`agreement` COMMENT 'Stores study contracts, master service agreements, amendments, scope of work documents, change orders, and service-level agreements. Governs the legal and commercial relationship between sponsor and CRO including billing milestones and deliverable';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` (
    `master_service_agreement_id` BIGINT COMMENT 'Unique surrogate identifier for the Master Service Agreement record in the Clinical Trials data lakehouse. Primary key for this entity. Role: MASTER_AGREEMENT.',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: MSAs are frequently negotiated at the clinical program level (e.g., a sponsor engages a CRO for an entire oncology program).',
    `parent_msa_master_service_agreement_id` BIGINT COMMENT 'Reference to the original MSA record when this record represents an amendment or change order. Enables hierarchical agreement versioning. Null for original MSAs.',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: MSA scope is defined by therapeutic area; contract portfolio analytics, rate benchmarking, and CRO capability assessments are all segmented by TA.',
    `agreement_status` STRING COMMENT 'Current lifecycle state of the MSA. DRAFT = initial authoring; UNDER_NEGOTIATION = active negotiation rounds in progress; PENDING_EXECUTION = awaiting final signatures; ACTIVE = fully executed and in force; SUSPENDED = temporarily paused by mutual',
    `agreement_type` STRING COMMENT 'Classification of the agreement document. MSA = Master Service Agreement; NDA = Non-Disclosure Agreement (standalone); CDA = Confidential Disclosure Agreement; SOW = Statement of Work; AMENDMENT = amendment to an existing MSA; CHANGE_ORDER = change order. Valid values are `MSA|NDA|CDA|SOW|AMENDMENT|CHANGE_ORDER`',
    `amendment_number` BIGINT COMMENT 'Sequential amendment number for MSA amendments. Null for original MSA; populated for agreement_type = AMENDMENT to track the version history of contractual modifications.',
    `audit_right_flag` BOOLEAN COMMENT 'Indicates whether the sponsor has contractual rights to audit the CROs facilities, systems, and study records. True = audit rights granted; False = no audit rights. Required for GCP compliance and regulatory inspection readiness.',
    `confidentiality_term_years` BIGINT COMMENT 'Duration in years for which confidentiality obligations survive termination or expiry of the MSA. Critical for data protection compliance and IP protection in clinical research.',
    `contract_currency` STRING COMMENT 'ISO 4217 three-letter currency code in which all financial terms of the MSA are denominated (e.g., USD, EUR, GBP). Governs billing milestones, liability caps, and payment terms.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the MSA record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `cro_legal_entity` STRING COMMENT 'Full registered legal entity name of the CRO (Contract Research Organization) as it appears on the executed agreement. Identifies the CRO contracting party for multi-entity CRO structures.',
    `data_privacy_framework` STRING COMMENT 'Primary data privacy regulatory framework applicable to patient and study data processed under this MSA. GDPR = EU General Data Protection Regulation; HIPAA = U.S.. Valid values are `GDPR|HIPAA|PIPEDA|APPI|COMBINED|NOT_APPLICABLE`',
    `dispute_resolution_mechanism` STRING COMMENT 'Contractually agreed method for resolving disputes between the CRO and sponsor. ARBITRATION = binding arbitration; LITIGATION = court proceedings; MEDIATION = non-binding mediation; EXPERT_DETERMINATION = independent expert ruling.. Valid values are `ARBITRATION|LITIGATION|MEDIATION|EXPERT_DETERMINATION`',
    `effective_date` DATE COMMENT 'Date on which the MSA becomes legally binding and operative. Serves as the EFFECTIVE_FROM category for this MASTER_AGREEMENT entity. Sourced from Veeva Vault executed agreement record.',
    `executed_date` DATE COMMENT 'Actual date on which the MSA was fully executed (signed by all authorized parties). Marks the transition from PENDING_EXECUTION to ACTIVE status. Sourced from Veeva Vault e-signature record.',
    `expiry_date` DATE COMMENT 'Date on which the MSA naturally expires or terminates unless renewed. Nullable for open-ended agreements. Serves as the EFFECTIVE_UNTIL category for this MASTER_AGREEMENT entity. Sourced from Veeva Vault.',
    `force_majeure_clause` BOOLEAN COMMENT 'Indicates whether the MSA contains a force majeure clause that excuses performance obligations under extraordinary circumstances (e.g., pandemic, natural disaster). True = clause present; False = no force majeure provision.',
    `governing_law_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction whose laws govern interpretation and enforcement of the MSA (e.g., USA, GBR, DEU). Critical for dispute resolution and regulatory compliance.. Valid values are `^[A-Z]{3}$`',
    `governing_law_state` STRING COMMENT 'State or province within the governing law country that provides the specific legal jurisdiction (e.g., Delaware, New York, England and Wales). Supplements governing_law_country for sub-national jurisdiction specification.',
    `indemnification_scope` STRING COMMENT 'Contractual indemnification structure defining which party bears liability for third-party claims. MUTUAL = both parties indemnify each other; SPONSOR_INDEMNIFIES_CRO = sponsor bears primary liability; CRO_INDEMNIFIES_SPONSOR = CRO bears primary. Valid values are `MUTUAL|SPONSOR_INDEMNIFIES_CRO|CRO_INDEMNIFIES_SPONSOR|LIMITED`',
    `insurance_required_flag` BOOLEAN COMMENT 'Indicates whether the MSA mandates that the CRO maintain specified levels of professional indemnity, clinical trial, or general liability insurance. True = insurance requirements specified; False = no insurance mandate.',
    `ip_ownership` STRING COMMENT 'Contractual allocation of intellectual property rights arising from the clinical research activities. SPONSOR = all IP vests in sponsor; CRO = CRO retains IP; JOINT = jointly owned; BACKGROUND_RETAINED = each party retains pre-existing background IP.. Valid values are `SPONSOR|CRO|JOINT|BACKGROUND_RETAINED`',
    `liability_cap_amount` DECIMAL(18,2) COMMENT 'Maximum aggregate financial liability of either party under the MSA, expressed in the contract currency. A core commercial term governing financial risk exposure. Sourced from the source system accounting.',
    `msa_number` STRING COMMENT 'Externally-known, human-readable agreement reference number assigned by the CRO or sponsor (e.g., MSA-2024-00123). Used for cross-system reconciliation between Veeva Vault and the source system',
    `negotiation_round` BIGINT COMMENT 'Sequential count of negotiation rounds completed for pre-execution MSAs. Tracks the negotiation lifecycle from initial draft through final execution. Relevant when agreement_status is DRAFT or UNDER_NEGOTIATION.',
    `payment_schedule_type` STRING COMMENT 'Contractual basis on which invoices are issued and payments are expected. MILESTONE = tied to deliverable completion; MONTHLY/QUARTERLY/ANNUAL = time-based; UPON_DELIVERY = triggered by specific deliverable acceptance.. Valid values are `MILESTONE|MONTHLY|QUARTERLY|ANNUAL|UPON_DELIVERY`',
    `payment_terms_days` BIGINT COMMENT 'Number of days from invoice date within which the sponsor must remit payment (e.g., 30, 45, 60). Governs accounts receivable management and cash flow planning in the source system',
    `regulatory_scope` STRING COMMENT 'Primary regulatory authority or geographic scope under which studies governed by this MSA will be conducted and submitted. Determines applicable GCP guidelines, data privacy requirements, and submission standards.',
    `renewal_notice_days` BIGINT COMMENT 'Number of days prior to expiry by which either party must provide written notice to prevent auto-renewal or to initiate renewal negotiations. Applicable when auto_renewal_flag is True.',
    `sap_contract_number` STRING COMMENT 'Contract identifier assigned in the source system accounting and procurement module. Enables financial reconciliation of billing milestones, purchase orders, and revenue recognition entries against the MSA.',
    `sla_included_flag` BOOLEAN COMMENT 'Indicates whether the MSA incorporates Service Level Agreement (SLA) provisions defining performance standards, KPIs, and remedies for non-performance. True = SLA terms embedded or referenced; False = no SLA provisions.',
    `sponsor_legal_entity` STRING COMMENT 'Full registered legal entity name of the sponsor as it appears on the executed agreement, which may differ from the trading name. Required for regulatory submissions and legal enforceability.',
    `sponsor_name` STRING COMMENT 'Legal entity name of the pharmaceutical or biotech sponsor that is the counterparty to this MSA. Sourced from Veeva Vault and the source system master. Used for reporting and regulatory correspondence.',
    `subcontracting_permitted` BOOLEAN COMMENT 'Indicates whether the CRO is permitted to subcontract any portion of the services to third-party vendors without prior sponsor approval. True = permitted (subject to conditions); False = not permitted without explicit sponsor consent.',
    `target_execution_date` DATE COMMENT 'Planned date by which the MSA is expected to be fully executed and signed by all parties. Used for negotiation tracking and study start-up timeline planning. Applicable for pre-execution agreements.',
    `termination_date` DATE COMMENT 'Actual date on which the MSA was terminated, if terminated before natural expiry. Null if the agreement is active or expired naturally. Sourced from Veeva Vault executed termination notice.',
    `termination_for_convenience_days` BIGINT COMMENT 'Number of days advance written notice required for either party to terminate the MSA for convenience (without cause). A key commercial risk management term.',
    `termination_reason` STRING COMMENT 'Reason for early termination of the MSA. FOR_CAUSE = material breach; FOR_CONVENIENCE = unilateral termination without cause; MUTUAL_AGREEMENT = both parties agreed; REGULATORY_REQUIREMENT = mandated by regulatory authority; SPONSOR_INSOLVENCY = sponsor. Valid values are `FOR_CAUSE|FOR_CONVENIENCE|MUTUAL_AGREEMENT|REGULATORY_REQUIREMENT|SPONSOR_INSOLVENCY`',
    `total_contract_value` DECIMAL(18,2) COMMENT 'Estimated or committed total financial value of the MSA over its full term, in the contract currency. Used for revenue recognition planning, financial forecasting, and the source system accounting.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the MSA record, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail and data lineage requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `veeva_vault_doc_number` STRING COMMENT 'Unique document identifier assigned by Veeva Vault eTMF/regulatory submissions module to the executed MSA document. Enables direct cross-system traceability to the source document repository.',
    CONSTRAINT pk_master_service_agreement PRIMARY KEY(`master_service_agreement_id`)
) COMMENT 'SSOT for Master Service Agreements (MSAs) between the CRO and pharmaceutical/biotech sponsors, including standalone NDAs/CDAs modeled as agreement_type=NDA.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`agreement`.`study_contract` (
    `study_contract_id` BIGINT COMMENT 'Unique surrogate identifier for the study-level Clinical Trial Agreement (CTA) record in the lakehouse silver layer. Primary key.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Study contracts are scoped to a specific regulatory application (IND/NDA/BLA). Contract managers must know which regulatory application governs the contracted work to align scope',
    `contract_manager_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Contract managers are internal employees responsible for negotiating and managing study contracts.',
    `master_service_agreement_id` BIGINT COMMENT 'Reference to the governing Master Service Agreement (MSA) under which this study-level contract is executed. Establishes the overarching legal and commercial framework.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor entity that is the counterparty to this Clinical Trial Agreement.',
    `preferred_provider_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.preferred_provider_agreement. Business justification: A study contract (CTA) can be executed under a Preferred Provider Agreement framework, inheriting pre-negotiated rates and terms.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this contract is executed. Links the commercial instrument to the study master record in the source system',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: Study contracts are scoped by therapeutic area for rate benchmarking, CRO performance reporting, and regulatory portfolio management.',
    `billing_frequency` STRING COMMENT 'Frequency at which the CRO invoices the sponsor under this contract (e.g., monthly, quarterly, milestone-triggered). Governs the billing milestone schedule and revenue recognition cadence.. Valid values are `monthly|quarterly|milestone|annual|upon_completion`',
    `change_order_count` BIGINT COMMENT 'Cumulative number of executed change orders (contract amendments modifying scope or budget) against this study contract. Supports contract health monitoring and scope creep analysis.',
    `confidentiality_term_years` BIGINT COMMENT 'Duration in years for which confidentiality obligations survive contract termination or expiry. Relevant for GDPR, HIPAA, and sponsor data protection compliance tracking.',
    `contract_number` STRING COMMENT 'Externally-known, human-readable contract reference number assigned by the CRO or sponsor at execution (e.g., CTA-2024-00123). Used for cross-system reconciliation with the source system and the source system',
    `contract_status` STRING COMMENT 'Current lifecycle state of the Clinical Trial Agreement. Tracks progression from initial drafting through negotiation, execution, active performance, and eventual termination or expiry.',
    `contract_title` STRING COMMENT 'Descriptive title of the Clinical Trial Agreement, typically including the study name or protocol number and sponsor name (e.g., CTA – SPONSOR-XYZ – Protocol ABC-001 Phase III).',
    `contract_type` STRING COMMENT 'Classification of the engagement model governing the CRO-sponsor relationship: full_service (CRO manages all study operations), functional_service (FSP – specific functional areas only), co_development (joint development partnership), pass_through_only. Valid values are `full_service|functional_service|co_development|pass_through_only|letter_of_intent`',
    `contract_version` STRING COMMENT 'Version identifier of the current executed contract document (e.g., v1.0, v2.1). Incremented with each executed amendment. Supports document traceability in Veeva Vault eTMF.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this study contract record was first created in the system of record. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which all monetary values in this contract are denominated (e.g., USD, EUR, GBP, JPY). Required for multi-currency financial reporting and the source system translation.. Valid values are `^[A-Z]{3}$`',
    `current_contracted_value` DECIMAL(18,2) COMMENT 'Total contracted value as adjusted by all executed change orders to date. Represents the live commercial commitment and is the basis for revenue recognition and financial forecasting.',
    `effective_end_date` DATE COMMENT 'Date on which the contract obligations are scheduled to expire or have been terminated. Nullable for open-ended agreements. Used for renewal tracking and financial accrual cut-off.',
    `effective_start_date` DATE COMMENT 'Date from which the contract terms and obligations become binding and CRO services may commence. May differ from execution_date if a retroactive or future start is agreed.',
    `execution_date` DATE COMMENT 'Date on which the Clinical Trial Agreement was fully executed (signed by all parties). Represents the binding effective date of the commercial instrument.',
    `governing_law_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction whose laws govern interpretation and enforcement of this contract (e.g., USA, GBR, DEU). Critical for dispute resolution and regulatory compliance.. Valid values are `^[A-Z]{3}$`',
    `indemnification_cap` DECIMAL(18,2) COMMENT 'Maximum monetary liability cap agreed between the CRO and sponsor for indemnification claims under this contract. Expressed in the contract currency. Key risk management and insurance alignment parameter.',
    `ip_ownership` STRING COMMENT 'Designation of intellectual property ownership for study data, results, and inventions arising from the contracted work: sponsor (all IP to sponsor), cro (CRO retains background IP), joint (shared ownership), third_party (licensed from or to a third. Valid values are `sponsor|cro|joint|third_party`',
    `key_open_issues` STRING COMMENT 'Free-text summary of the principal unresolved contractual issues blocking execution (e.g., indemnification language, IP ownership, payment terms). Populated by the contract manager during negotiation.',
    `negotiation_round` BIGINT COMMENT 'Sequential count of negotiation rounds completed between the CRO and sponsor. Tracks negotiation complexity and cycle time for KPI reporting and process improvement.',
    `negotiation_status` STRING COMMENT 'Current status of the contract negotiation lifecycle, distinct from the overall contract status. Tracks whether active negotiation rounds are ongoing, paused, escalated to senior management, or concluded.. Valid values are `not_started|in_progress|on_hold|escalated|closed`',
    `notice_period_days` BIGINT COMMENT 'Number of calendar days of advance written notice required by either party to terminate or elect non-renewal of the contract. Drives automated alerts in contract management workflows.',
    `pass_through_budget` DECIMAL(18,2) COMMENT 'Portion of the total contracted value allocated to reimbursable pass-through costs (e.g., central lab fees, IRB/IEC fees, travel). Tracked separately for revenue recognition and sponsor invoicing purposes.',
    `payment_terms` STRING COMMENT 'Agreed payment terms governing sponsor invoice settlement (e.g., net_30, net_60, milestone_based). Drives accounts receivable aging and cash flow forecasting in the source system. Valid values are `net_30|net_45|net_60|net_90|milestone_based|advance_payment`',
    `phase` STRING COMMENT 'Regulatory development phase of the clinical study covered by this contract (Phase I through Phase IV). Influences contract complexity, budget scale, and regulatory compliance requirements.. Valid values are `Phase I|Phase II|Phase III|Phase IV|Phase I/II|Phase II/III`',
    `protocol_number` STRING COMMENT 'Sponsor-assigned clinical study protocol number referenced in this contract (e.g., ABC-001). Provides direct traceability between the commercial instrument and the scientific protocol document.',
    `renewal_date` DATE COMMENT 'Date on which the contract was renewed or extended. Captures the renewal lifecycle event for long-running studies requiring contract extensions beyond the original effective_end_date.',
    `scope_of_work_version` STRING COMMENT 'Version identifier of the current governing Scope of Work (SOW) document attached to this contract. Ensures traceability to the specific deliverable schedule and service definitions in effect.',
    `service_fee_budget` DECIMAL(18,2) COMMENT 'Portion of the total contracted value representing CRO professional service fees (excluding pass-throughs). Used for revenue recognition, margin analysis, and billing milestone scheduling.',
    `sla_penalty_clause_flag` BOOLEAN COMMENT 'Indicates whether the contract includes Service Level Agreement (SLA) penalty or credit provisions triggered by CRO performance failures against agreed KPI thresholds.',
    `sponsor_contact_name` STRING COMMENT 'Name of the primary sponsor-side contact (e.g., Alliance Manager or Legal Counsel) responsible for this contract. Used for correspondence and escalation tracking.',
    `sponsor_contract_number` STRING COMMENT 'Sponsor-assigned contract reference number for the same Clinical Trial Agreement, used for cross-party reconciliation and sponsor billing correspondence.',
    `target_execution_date` DATE COMMENT 'Planned date by which the contract is expected to be fully executed. Used to monitor negotiation cycle time against internal KPI targets and to flag at-risk contracts.',
    `termination_date` DATE COMMENT 'Date on which the contract was formally terminated prior to its scheduled effective_end_date. Null if the contract has not been terminated. Triggers financial close-out and accrual reversal processes.',
    `termination_reason` STRING COMMENT 'Categorized reason for early contract termination. Used for portfolio risk analysis, sponsor relationship management, and financial close-out reporting. [ENUM-REF-CANDIDATE',
    `total_contracted_value` DECIMAL(18,2) COMMENT 'Gross total monetary value of the Clinical Trial Agreement as executed, inclusive of all service fees and pass-through budgets but before any change orders. Expressed in the contract currency.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this study contract record. Supports change tracking, audit trail compliance, and incremental ETL processing in the Databricks lakehouse.',
    CONSTRAINT pk_study_contract PRIMARY KEY(`study_contract_id`)
) COMMENT 'Study-level contract (Clinical Trial Agreement / CTA) executed between the sponsor and CRO for a specific clinical study. Captures contract number, study reference, contract type (full-service, functional service, co-development), total contracted value';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` (
    `scope_of_work_id` BIGINT COMMENT 'Unique surrogate identifier for the Scope of Work record in the lakehouse silver layer. Primary key for this entity.',
    `cro_lead_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: The CRO lead named on a SOW is a key personnel designation required by ICH E6 GCP guidelines.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that commissioned the Scope of Work from the CRO.',
    `study_contract_id` BIGINT COMMENT 'Reference to the parent master service agreement or study contract to which this Scope of Work is attached. A single contract may have multiple SOW versions.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this Scope of Work defines CRO services and deliverables. Links the SOW to the study protocol context.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: SOWs are TMF-filed contractual documents required for GCP inspection readiness. This FK replaces the denormalized etmf_document_reference string, enabling direct navigation from SOW to',
    `amendment_number` BIGINT COMMENT 'Sequential amendment counter for this SOW. Zero (0) indicates the original SOW; positive integers indicate successive amendments. Used to track the amendment lineage within a contract.',
    `approval_status` STRING COMMENT 'Current lifecycle state of the SOW document: draft (being authored), under_review (circulated for approval), approved (internally approved but not yet countersigned), executed (fully signed by both parties), superseded (replaced by a newer version), or. Valid values are `draft|under_review|approved|executed|superseded|terminated`',
    `billing_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which sponsor invoices will be issued under this SOW. May differ from contract currency_code when multi-currency billing arrangements apply.. Valid values are `^[A-Z]{3}$`',
    `biostatistics_included` BOOLEAN COMMENT 'Indicates whether biostatistical analysis and reporting services (Statistical Analysis Plan authoring, analysis datasets, tables/listings/figures) are included in this SOW. True = biostatistics is in scope.',
    `confidentiality_level` STRING COMMENT 'Data classification level assigned to this SOW document per the organizations data governance policy. Determines access controls, sharing restrictions, and handling requirements.. Valid values are `restricted|confidential|internal|public`',
    `country_count` BIGINT COMMENT 'Number of countries included in the geographic scope of this SOW. Used for complexity assessment, resource planning, and regulatory submission tracking.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this SOW record was first created in the system, in ISO 8601 format with timezone offset. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `ctms_sow_reference` STRING COMMENT 'Identifier of the corresponding SOW record in the the source system system. Supports cross-system reconciliation between the lakehouse and the operational CTMS.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the monetary values in this SOW (e.g., USD, EUR, GBP, JPY). All financial fields in this record are denominated in this currency.. Valid values are `^[A-Z]{3}$`',
    `data_management_included` BOOLEAN COMMENT 'Indicates whether clinical data management services (EDC build, eCRF design, data cleaning, database lock) are included in this SOW. True = data management is in scope.',
    `effective_date` DATE COMMENT 'Date on which this SOW version becomes legally binding and operationally active. Marks the start of the CROs obligation to deliver the defined services.',
    `execution_date` DATE COMMENT 'Date on which the SOW was fully countersigned by both the sponsor and the CRO, making it a legally executed agreement. Distinct from effective_date, which may be backdated or future-dated.',
    `expiry_date` DATE COMMENT 'Date on which this SOW version expires or is scheduled to conclude. Nullable for open-ended SOWs. Used for contract renewal tracking and financial accrual cut-offs.',
    `geographic_scope` STRING COMMENT 'Description of the geographic regions or countries covered by this SOW (e.g., North America, EU, Asia-Pacific). Defines the territorial boundaries of the CROs service obligations. Free-text to accommodate multi-region combinations.',
    `governing_law` STRING COMMENT 'Jurisdiction whose laws govern the interpretation and enforcement of this SOW (e.g., State of New Jersey, USA, England and Wales). Critical for dispute resolution and regulatory compliance.',
    `is_current_version` BOOLEAN COMMENT 'Indicates whether this SOW record represents the currently active and operative version. True = this is the current version; False = this version has been superseded by a later amendment. Enables efficient filtering to the active SOW.',
    `key_assumptions` STRING COMMENT 'Material assumptions underlying the SOW budget and timeline (e.g., assumed screen failure rate, assumed site activation timeline, assumed protocol amendment frequency). Deviations from these assumptions may trigger change orders.',
    `monitoring_included` BOOLEAN COMMENT 'Indicates whether clinical site monitoring services (on-site and/or remote monitoring by CRAs, Source Data Verification) are included in this SOW. True = monitoring is in scope.',
    `out_of_scope_items` STRING COMMENT 'Explicit list of services or activities that are excluded from this SOW. Prevents scope creep disputes and clarifies sponsor versus CRO responsibilities.',
    `pass_through_budget` DECIMAL(18,2) COMMENT 'Portion of the total contract value allocated to pass-through costs (e.g., investigator grants, central lab fees, travel, IRB/IEC fees) that are reimbursed at cost without CRO markup. Tracked separately from service fees for financial reporting.',
    `payment_model` STRING COMMENT 'Commercial payment structure governing how the CRO is compensated under this SOW: milestone (payments tied to deliverable completion), time_and_materials (FTE hours and expenses), fixed_fee (lump sum), unit_based (per patient/visit/site), or hybrid. Valid values are `milestone|time_and_materials|fixed_fee|unit_based|hybrid`',
    `pharmacovigilance_included` BOOLEAN COMMENT 'Indicates whether pharmacovigilance and safety reporting services (SAE/SUSAR processing, expedited regulatory reporting, signal detection) are included in this SOW. True = pharmacovigilance is in scope.',
    `planned_site_count` BIGINT COMMENT 'Number of investigational sites planned under this SOW. Drives resource allocation for Clinical Research Associates (CRAs), monitoring visit budgets, and site management activities.',
    `planned_subject_count` BIGINT COMMENT 'Target number of subjects to be enrolled under this SOW. Used for patient recruitment planning, EDC build scoping, and biostatistical resource estimation.',
    `regulatory_included` BOOLEAN COMMENT 'Indicates whether regulatory affairs services (IND/NDA/BLA/MAA submissions, eCTD compilation, agency interactions) are included in this SOW. True = regulatory is in scope.',
    `sap_contract_reference` STRING COMMENT 'the source system or purchase order number associated with this SOW. Links the SOW to the financial procurement and accounts payable records for budget tracking and invoice matching.',
    `scope_description` STRING COMMENT 'Detailed narrative description of the services, deliverables, responsibilities, and exclusions defined in this SOW. Captures the full scope of the CROs obligations as agreed with the sponsor.',
    `service_category_summary` STRING COMMENT 'Free-text summary of all service categories included in this SOW (e.g., Monitoring, Data Management, Biostatistics, Medical Writing, Regulatory). Provides a human-readable overview of the CROs service obligations for reporting and contract management.',
    `service_fee_budget` DECIMAL(18,2) COMMENT 'Portion of the total contract value representing CRO professional service fees (excluding pass-through costs). Used for revenue recognition, margin analysis, and sponsor invoicing.',
    `sow_number` STRING COMMENT 'Externally-known alphanumeric identifier for the Scope of Work document, used in sponsor communications, contract management systems, and regulatory correspondence. Follows the CROs SOW numbering convention.. Valid values are `^SOW-[A-Z0-9]{3,20}-[0-9]{4}$`',
    `sow_title` STRING COMMENT 'Human-readable title or short description of the Scope of Work document, typically referencing the study name, therapeutic area, or service bundle (e.g., Phase III Oncology Study – Full-Service CRO SOW).',
    `sow_type` STRING COMMENT 'Classification of the SOW by engagement model: full_service (CRO manages all study functions), functional_service (CRO provides specific functional units), task_order (discrete task under a master SOW), change_order (modification to an existing SOW), or. Valid values are `full_service|functional_service|task_order|change_order|amendment`',
    `sponsor_contact_name` STRING COMMENT 'Name of the sponsors designated representative or project manager who is the primary point of contact for this SOW. Used for contract governance and escalation.',
    `superseded_date` DATE COMMENT 'Date on which this SOW version was superseded by a newer amendment or version. Null if the SOW is still the current active version. Supports version lineage tracking.',
    `total_contract_value` DECIMAL(18,2) COMMENT 'Total monetary value of the CRO services defined in this SOW, expressed in the contract currency. Represents the gross budget ceiling for all service categories combined. Used for financial planning, revenue recognition, and sponsor billing.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this SOW record, in ISO 8601 format with timezone offset. Used for change tracking, data lineage, and audit compliance.',
    `version_number` STRING COMMENT 'Version identifier for this SOW document (e.g., 1.0, 2.0, 2.1). Multiple versions exist per contract due to amendments or change orders. The combination of sow_number and version_number uniquely identifies a specific SOW revision.. Valid values are `^[0-9]+.[0-9]+$`',
    CONSTRAINT pk_scope_of_work PRIMARY KEY(`scope_of_work_id`)
) COMMENT 'Formal Scope of Work (SOW) document attached to a study contract or MSA, defining the specific services, deliverables, timelines, and responsibilities the CRO will perform.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`agreement`.`change_order` (
    `change_order_id` BIGINT COMMENT 'Unique system-generated identifier for the Change Order (CO) or Contract Change Notice (CCN) record. Primary key for the change_order data product.',
    `audit_finding_id` BIGINT COMMENT 'Foreign key linking to compliance.audit_finding. Business justification: Audit findings (e.g., inadequate monitoring coverage) can mandate scope changes executed via change orders.',
    `initiated_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Change orders are initiated by specific employees; tracking this supports change management audit trails, workload analysis by employee, and financial controls.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that is party to the contract being modified by this Change Order.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: Protocol amendments are the primary driver of change orders in CRO contracts.',
    `scope_of_work_id` BIGINT COMMENT 'Reference to the parent Statement of Work or study contract that this Change Order modifies. Links the CO to its governing agreement.',
    `study_contract_id` BIGINT COMMENT 'Foreign key linking to agreement.study_contract. Business justification: A change order modifies the scope, budget, or timeline of a study contract. While change_order already links to scope_of_work (which links to study_contract), a direct FK to',
    `study_id` BIGINT COMMENT 'Reference to the clinical study or trial whose contract scope, budget, or timeline is being modified by this Change Order.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Protocol amendments are the primary driver of CRO change orders. Regulatory and contracts teams must trace each change order back to the specific protocol amendment that caused',
    `superseded_co_change_order_id` BIGINT COMMENT 'Reference to a prior Change Order that this record supersedes or replaces. Enables version chain traceability for contract modification history.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Change orders are TMF-required documents (scope/budget amendments). This FK replaces the denormalized etmf_document_ref string, enabling TMF completeness tracking to verify each change',
    `approval_workflow_step` STRING COMMENT 'Current step in the multi-stage internal and external approval workflow for this Change Order, tracking progression from initiation through sponsor sign-off.',
    `billing_milestone_impact` STRING COMMENT 'Description of how this Change Order affects existing billing milestones, including additions, removals, or modifications to milestone amounts and trigger events.',
    `change_reason` STRING COMMENT 'Structured business reason or justification for the contract modification, such as protocol amendment, site expansion, enrollment rate change, regulatory requirement, or sponsor-directed scope change.',
    `change_reason_detail` STRING COMMENT 'Free-text narrative providing additional context and detail for the change reason, including background, triggering events, and business impact rationale.',
    `change_type` STRING COMMENT 'Classification of the nature of the contract modification: scope increase (additional services/sites/subjects), scope decrease (reduction), timeline extension, budget reallocation between lines, service-level change, or regulatory-driven amendment.. Valid values are `scope_increase|scope_decrease|timeline_extension|budget_reallocation|service_level_change|regulatory_driven`',
    `co_number` STRING COMMENT 'Externally-known, human-readable identifier for the Change Order or Contract Change Notice, used in sponsor communications, contract management systems, and audit trails. Follows the format CO-{YEAR}-{SEQUENCE}.. Valid values are `^CO-[0-9]{4}-[0-9]{5}$`',
    `co_status` STRING COMMENT 'Current lifecycle status of the Change Order within the approval workflow, from initial drafting through sponsor approval or rejection. [ENUM-REF-CANDIDATE: draft|pending_review|pending_sponsor_approval|approved|rejected|cancelled|superseded — promote to',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp recording when the Change Order record was first created in the contract management system. Supports audit trail and ALCOA+ compliance.',
    `ctms_co_reference` STRING COMMENT 'Cross-reference identifier for this Change Order as recorded in the source system enabling reconciliation between the financial contract management system and the operational trial management system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code applicable to all monetary amounts on this Change Order (e.g., USD, EUR, GBP, JPY).. Valid values are `^[A-Z]{3}$`',
    `delta_value` DECIMAL(18,2) COMMENT 'The net financial impact of the Change Order expressed as a signed monetary amount. Positive values indicate a budget increase (scope increase); negative values indicate a budget decrease (scope decrease). Represents the gross change to the contract value.',
    `effective_date` DATE COMMENT 'The date on which the approved Change Order becomes contractually effective and the modified scope, budget, or timeline takes legal effect.',
    `expiry_date` DATE COMMENT 'The date by which the Change Order must receive sponsor approval before it lapses. Null if no expiry constraint applies.',
    `finance_review_required` BOOLEAN COMMENT 'Indicates whether this Change Order requires formal finance department review and sign-off, typically triggered when the delta value exceeds a defined materiality threshold.',
    `impacted_budget_lines` STRING COMMENT 'Comma-separated list or structured reference to the budget line identifiers affected by this Change Order. Provides traceability between the CO and specific financial budget lines.',
    `initiation_date` DATE COMMENT 'The date on which the Change Order was formally initiated and submitted for internal review. Represents the principal real-world business event timestamp for this transaction.',
    `internal_approver_name` STRING COMMENT 'Name of the CRO-side authorized signatory (e.g., Finance Director, VP Contracts) who approved the Change Order internally before sponsor submission.',
    `legal_review_required` BOOLEAN COMMENT 'Indicates whether this Change Order requires formal legal review before sponsor submission, typically triggered by changes to liability, IP, or regulatory terms.',
    `notes` STRING COMMENT 'General free-text notes or comments associated with the Change Order, capturing supplementary context not covered by structured fields.',
    `pass_through_delta` DECIMAL(18,2) COMMENT 'The portion of the delta value attributable to pass-through costs (e.g., investigator grants, lab fees, travel) that are reimbursed at cost without CRO margin.',
    `priority` STRING COMMENT 'Business priority classification of the Change Order, used to triage the approval workflow and resource allocation for processing.. Valid values are `critical|high|medium|low`',
    `regulatory_driven_flag` BOOLEAN COMMENT 'Indicates whether this Change Order was mandated by a regulatory authority (FDA, EMA, PMDA, etc.) or regulatory requirement, as opposed to being sponsor- or operationally-initiated.',
    `rejection_reason` STRING COMMENT 'Documented reason provided by the sponsor or internal reviewer when the Change Order is rejected. Null if the CO has not been rejected.',
    `revised_contract_value` DECIMAL(18,2) COMMENT 'The total contract value after application of this Change Order, representing the updated financial commitment between sponsor and CRO.',
    `revised_study_end_date` DATE COMMENT 'The updated projected study or SOW completion date after application of any timeline extension specified in this Change Order.',
    `scope_description` STRING COMMENT 'Detailed narrative description of the scope changes introduced by this Change Order, including additions, removals, or modifications to services, deliverables, sites, or subject counts.',
    `service_fee_delta` DECIMAL(18,2) COMMENT 'The portion of the delta value attributable to CRO service fees (professional services, management fees) as distinct from pass-through costs.',
    `site_count_delta` BIGINT COMMENT 'Net change in the number of investigative sites resulting from this Change Order. Positive for site additions, negative for site closures. Zero if site count is unaffected.',
    `sponsor_approval_date` DATE COMMENT 'The date on which the sponsor formally approved the Change Order, completing the approval workflow. Null if not yet approved.',
    `sponsor_approver_name` STRING COMMENT 'Name of the authorized sponsor representative who approved or rejected the Change Order. Captured for audit and regulatory compliance purposes.',
    `subject_count_delta` BIGINT COMMENT 'Net change in the number of enrolled subjects (patients) resulting from this Change Order. Positive for enrollment increases, negative for decreases. Zero if subject count is unaffected.',
    `timeline_extension_days` BIGINT COMMENT 'Number of calendar days by which the study or SOW timeline is extended as a result of this Change Order. Zero or null if the CO does not affect the timeline.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp recording the most recent modification to the Change Order record. Supports audit trail and ALCOA+ compliance.',
    `version_number` BIGINT COMMENT 'Sequential version number of the Change Order document, incremented each time the CO is revised during the negotiation and approval process.',
    CONSTRAINT pk_change_order PRIMARY KEY(`change_order_id`)
) COMMENT 'Formal Change Order (CO) or Contract Change Notice (CCN) issued to modify the scope, budget, or timeline of an existing SOW or study contract. Captures change order number, change type (scope increase, scope decrease, timeline extension, budget';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` (
    `contract_amendment_id` BIGINT COMMENT 'Unique system-generated identifier for the contract amendment record. Primary key for the contract_amendment data product.',
    `master_service_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.master_service_agreement. Business justification: Contract amendments can be issued against a Master Service Agreement directly (e.g., to modify framework terms, liability caps, or payment terms), not only against study',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor party who is a signatory to the amended contract.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: Contract amendments are frequently executed in direct response to regulatory protocol amendments that change study scope.',
    `study_contract_id` BIGINT COMMENT 'Reference to the master service agreement or study contract that this amendment modifies. Links the amendment to its governing contract.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Contract amendments are frequently necessitated by protocol amendments (scope changes, timeline extensions, safety-driven redesigns).',
    `superseded_by_amendment_contract_amendment_id` BIGINT COMMENT 'Reference to the subsequent amendment that supersedes this one, enabling a versioned chain of contract modifications. Null if this amendment is the current active version.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Contract amendments are essential TMF documents (Zone 1). This FK replaces the denormalized etmf_document_reference string, enabling direct eTMF filing verification and TMF completeness',
    `version_id` BIGINT COMMENT 'Foreign key linking to document.document_version. Business justification: Each contract amendment produces a specific document version in the eTMF. This FK links the amendment record to its executed document version, enabling regulatory audit trails',
    `amendment_description` STRING COMMENT 'Detailed narrative description of the changes introduced by this amendment, including the specific clauses modified, deleted, or added. Provides the business rationale and legal context for the modification.',
    `amendment_number` STRING COMMENT 'Externally-known sequential identifier for the amendment within the context of the parent contract (e.g., AMD-2024-001). Used in legal correspondence and regulatory submissions.. Valid values are `^AMD-[0-9]{4}-[0-9]{3,6}$`',
    `amendment_status` STRING COMMENT 'Current lifecycle state of the amendment. Tracks progression from initial drafting through negotiation, signature collection, execution, and potential supersession or voiding.. Valid values are `draft|under_negotiation|pending_signature|executed|superseded|voided`',
    `amendment_title` STRING COMMENT 'Short descriptive title summarizing the primary purpose of the amendment (e.g., Payment Schedule Revision Q3 2024). Used for identification in contract management systems and legal registers.',
    `amendment_type` STRING COMMENT 'Classification of the legal or commercial area being modified by this amendment. Distinguishes amendments that change legal terms, payment terms, liability clauses, confidentiality provisions, termination conditions, or intellectual property rights.. Valid values are `legal_terms|payment_terms|liability|confidentiality|termination|intellectual_property`',
    `amendment_version` BIGINT COMMENT 'Monotonically increasing version number for this amendment, supporting versioned history of the legal contract. Increments when an amendment is revised prior to execution.',
    `change_rationale` STRING COMMENT 'Business or legal justification for why this amendment was initiated. Documents the triggering event or business need (e.g., regulatory requirement change, scope renegotiation, dispute resolution).',
    `clauses_modified` STRING COMMENT 'Comma-separated list or narrative identifying the specific contract clause numbers or section references that are modified, added, or deleted by this amendment (e.g., Section 4.2, Section 7.1, Exhibit B).',
    `confidentiality_period_years` BIGINT COMMENT 'Duration in years for which confidentiality obligations apply under the amended contract terms. Relevant when the amendment modifies the confidentiality clause of the master agreement.',
    `contract_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the contract and amendment financial values (e.g., USD, EUR, GBP). Ensures consistent financial reporting across multi-currency sponsor agreements.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp recording when this amendment record was first created in the data platform. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `cro_signatory_name` STRING COMMENT 'Full name of the authorized representative from the CRO (Contract Research Organization) who signed the amendment. Required for legal validity and regulatory audit trail.',
    `cro_signatory_title` STRING COMMENT 'Job title or role of the CROs authorized signatory (e.g., President, VP Business Development). Validates signatory authority level for the CRO party.',
    `dispute_resolution_mechanism` STRING COMMENT 'The agreed mechanism for resolving disputes arising from the amended contract terms. Captures whether parties have agreed to arbitration, litigation, mediation, or expert determination.. Valid values are `arbitration|litigation|mediation|expert_determination`',
    `effective_date` DATE COMMENT 'The date from which the amended terms become legally binding and operationally effective. May differ from the execution date if retroactive or future-dated application is agreed.',
    `execution_date` DATE COMMENT 'The date on which all required parties formally signed and executed the amendment, making it legally binding. Distinct from effective_date which governs when terms apply.',
    `expiry_date` DATE COMMENT 'Date on which the amended terms cease to apply, if the amendment is time-limited. Null for amendments that remain in force until superseded or the parent contract terminates.',
    `finance_review_completed` BOOLEAN COMMENT 'Indicates whether the finance team has reviewed and approved the financial implications of the amendment, including impact on accruals, revenue recognition, and billing milestones.',
    `financial_impact_amount` DECIMAL(18,2) COMMENT 'Net monetary value change to the parent contract resulting from this amendment (positive for increases, negative for decreases). Expressed in the contract currency. Populated only when financial_impact_flag is True.',
    `financial_impact_flag` BOOLEAN COMMENT 'Indicates whether this amendment has a direct financial impact on the contract value, payment schedule, or billing milestones. True triggers downstream finance accrual and revenue recognition review.',
    `governing_law_jurisdiction` STRING COMMENT 'The legal jurisdiction whose laws govern interpretation and enforcement of the amended contract terms (e.g., Delaware, USA, England and Wales). Critical for dispute resolution.',
    `indemnification_modified` BOOLEAN COMMENT 'Indicates whether this amendment modifies the indemnification provisions of the parent contract. Triggers legal and risk management review when True.',
    `initiated_date` DATE COMMENT 'The date on which the amendment process was formally initiated, typically when the first draft was created or the request was submitted. Supports negotiation cycle time analytics.',
    `initiating_party` STRING COMMENT 'Identifies which party initiated the amendment request: the pharmaceutical/biotech sponsor, the CRO (Contract Research Organization), or mutually agreed. Supports contract governance analytics.. Valid values are `sponsor|cro|mutual`',
    `legal_review_completed` BOOLEAN COMMENT 'Indicates whether the internal legal team has completed their review and approved the amendment language prior to execution. Part of the amendment governance workflow.',
    `legal_review_date` DATE COMMENT 'Date on which the internal legal review was completed and sign-off was granted. Populated when legal_review_completed is True.',
    `liability_cap_amount` DECIMAL(18,2) COMMENT 'Maximum monetary liability exposure agreed between parties as modified by this amendment. Expressed in contract_currency. Populated when amendment_type includes liability modifications.',
    `negotiation_end_date` DATE COMMENT 'Date on which negotiation was concluded and terms were agreed upon by all parties, prior to formal execution. Enables measurement of negotiation duration as a KPI.',
    `negotiation_round_count` BIGINT COMMENT 'Number of negotiation rounds completed before the amendment was agreed. Supports KPI reporting on contract negotiation efficiency and legal resource consumption.',
    `negotiation_start_date` DATE COMMENT 'Date on which active negotiation between the CRO and sponsor commenced for this amendment. Used to measure negotiation cycle time and track legal resource utilization.',
    `new_payment_terms_description` STRING COMMENT 'Narrative description of the revised payment terms introduced by this amendment, including net payment days, milestone triggers, or revised billing schedule. Populated only when payment_terms_modified is True.',
    `notes` STRING COMMENT 'Free-text field for additional context, internal commentary, or negotiation history notes that do not fit structured fields. Intended for legal and contract management team use.',
    `payment_terms_modified` BOOLEAN COMMENT 'Indicates whether this amendment modifies the payment terms of the parent contract, including payment schedule, milestone definitions, or net payment days. Triggers finance team review.',
    `regulatory_notification_date` DATE COMMENT 'Date on which the required regulatory notification was submitted to the relevant authority (FDA, EMA, MHRA, etc.). Populated only when regulatory_notification_required is True.',
    `regulatory_notification_required` BOOLEAN COMMENT 'Indicates whether the amendment triggers a regulatory notification obligation to FDA, EMA, or other governing bodies (e.g., changes to sponsor responsibilities under ICH E6). Drives compliance workflow.',
    `sponsor_signatory_name` STRING COMMENT 'Full name of the authorized representative from the sponsor organization who signed the amendment. Required for legal validity and regulatory audit trail.',
    `sponsor_signatory_title` STRING COMMENT 'Job title or role of the sponsors authorized signatory (e.g., VP Clinical Operations, Chief Medical Officer). Validates signatory authority level.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp recording when this amendment record was last modified in the data platform. Supports change tracking and audit trail requirements under 21 CFR Part 11.',
    `veeva_vault_document_number` STRING COMMENT 'System document identifier in Veeva Vault for the executed amendment document. Supports direct deep-linking from the data lakehouse to the source document management system.',
    CONSTRAINT pk_contract_amendment PRIMARY KEY(`contract_amendment_id`)
) COMMENT 'Formal amendment to a master service agreement or study contract that modifies legal terms, commercial conditions, or governing clauses (as distinct from a Change Order which modifies scope/budget).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` (
    `service_level_agreement_id` BIGINT COMMENT 'Unique surrogate identifier for the Service Level Agreement record in the lakehouse silver layer.',
    `approver_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: SLA approvals by named employees are required for governance and compliance audit trails.',
    `audit_id` BIGINT COMMENT 'Foreign key linking to compliance.audit. Business justification: SLA performance audits verify CRO adherence to contracted thresholds (e.g., query resolution rate, monitoring visit frequency).',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: SLA measurement methodology is governed by SOPs (e.g., SOP for monitoring visit conduct defines the SLA metric).',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: SLAs with regulatory_commitment_flag are driven by specific health authority requirements (e.g., FDA 15-day expedited safety reporting timelines).',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: SLAs for turnaround time, critical value notification, and result reporting are negotiated with specific lab facilities. Lab operations teams monitor SLA performance per facility.',
    `master_service_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.master_service_agreement. Business justification: Service Level Agreements can be established at the MSA level as framework performance commitments that apply across all studies under the MSA.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that is the counterparty to this SLA. Enables sponsor-level SLA performance reporting.',
    `preferred_provider_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.preferred_provider_agreement. Business justification: Service Level Agreements can be established at the PPA framework level, defining performance commitments that apply across all studies under the preferred provider',
    `scope_of_work_id` BIGINT COMMENT 'Reference to the Statement of Work or scope-of-work document that this SLA is specifically attached to, where the SLA is scoped below the master contract level.',
    `study_contract_id` BIGINT COMMENT 'Reference to the master service agreement or contract to which this SLA is attached. Links the SLA to its governing legal instrument.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study or trial to which this SLA applies, when the SLA is scoped at the study level rather than the enterprise contract level.',
    `superseded_by_service_level_agreement_id` BIGINT COMMENT 'Reference to the newer SLA record that replaces this one when sla_status is superseded. Enables forward navigation of the SLA version chain for audit and historical analysis.',
    `amendment_number` STRING COMMENT 'Amendment or change order number that introduced or last modified this SLA, if applicable. Provides traceability to the contract amendment history and version control.. Valid values are `^AMD-[0-9]{3}$`',
    `approved_date` DATE COMMENT 'Date on which this SLA was formally approved and signed off by both the CRO and the sponsor. Marks the transition from draft to active status and is required for regulatory audit trails.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this SLA record was first created in the system. Required for audit trail and data lineage tracking per ALCOA+ principles and 21 CFR Part 11.',
    `credit_applicable` BOOLEAN COMMENT 'Indicates whether a service credit (bonus or rebate) is awarded to the sponsor when the CRO exceeds the SLA threshold. Supports incentive-based contract structures.',
    `credit_value` DECIMAL(18,4) COMMENT 'Numeric value of the service credit awarded when the CRO exceeds the SLA target. Expressed in contract currency or as a percentage of invoice, consistent with penalty_type conventions.',
    `effective_end_date` DATE COMMENT 'Calendar date on which this SLA ceases to be binding. Nullable for open-ended SLAs that remain in force until the contract terminates.',
    `effective_start_date` DATE COMMENT 'Calendar date on which this SLA becomes binding and performance measurement begins. Aligns with the contract or SOW commencement date.',
    `escalation_contact` STRING COMMENT 'Name or role of the designated escalation contact (e.g., Project Manager, Sponsor Alliance Manager) who must be notified when the escalation threshold is breached. Supports SLA governance and sponsor relationship management.',
    `escalation_threshold_value` DECIMAL(18,4) COMMENT 'Numeric value at which a near-breach warning or escalation is triggered before the formal SLA threshold is reached (e.g., escalate at 20 hours for a 24-hour SAE reporting SLA). Enables proactive remediation.',
    `exclusion_criteria` STRING COMMENT 'Free-text description of conditions or events that are excluded from SLA measurement (e.g., sponsor-caused delays, system downtime, force majeure, regulatory authority hold). Critical for fair breach adjudication.',
    `governing_regulation` STRING COMMENT 'Specific regulatory citation that mandates or informs this SLA threshold when regulatory_commitment_flag is True (e.g., FDA 21 CFR 312.32 – 15-day SAE reporting, ICH E2A – expedited safety reporting, EU CTR 536/2014 Article 42).',
    `grace_period_unit` STRING COMMENT 'Unit of measure for the grace period value (hours, business_days, or calendar_days). Paired with grace_period_value to define the full grace period window.. Valid values are `hours|business_days|calendar_days`',
    `grace_period_value` DECIMAL(10,2) COMMENT 'Numeric value of the allowable grace period beyond the threshold before a breach is formally recorded (e.g., 2 for a 2-hour grace period). Accommodates system downtime or force majeure scenarios.',
    `measurement_frequency` STRING COMMENT 'How frequently SLA performance is measured and reported: per_event (each occurrence), daily, weekly, monthly, quarterly, or annually. Drives the cadence of SLA performance review meetings with the sponsor.. Valid values are `per_event|daily|weekly|monthly|quarterly|annually`',
    `measurement_method` STRING COMMENT 'Description of how the SLA metric is measured and from which source system (e.g., Calculated from SAE receipt timestamp to submission timestamp in the source system Query open-to-close duration in Medidata Rave EDC).',
    `notes` STRING COMMENT 'Free-text field for additional context, negotiation history, sponsor-specific interpretations, or operational guidance related to this SLA that does not fit structured fields.',
    `penalty_applicable` BOOLEAN COMMENT 'Indicates whether a financial penalty or service credit applies when this SLA is breached. True = penalty/credit terms are defined; False = informational SLA with no financial consequence.',
    `penalty_cap_value` DECIMAL(18,4) COMMENT 'Maximum cumulative penalty or credit that can be applied under this SLA within a measurement period, expressed in the penalty currency or as a percentage cap. Protects the CRO from unlimited liability exposure.',
    `penalty_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code applicable to the penalty_value when penalty_type is fixed_fee (e.g., USD, EUR, GBP). Null for non-monetary penalty types.. Valid values are `^[A-Z]{3}$`',
    `penalty_type` STRING COMMENT 'Type of financial consequence applied upon SLA breach: fixed_fee (flat monetary penalty), percentage_of_invoice (percentage deducted from the relevant invoice), service_credit (credit applied to future invoices), milestone_hold (billing milestone. Valid values are `fixed_fee|percentage_of_invoice|service_credit|milestone_hold|none`',
    `penalty_value` DECIMAL(18,4) COMMENT 'Numeric value of the penalty or credit applied upon breach. Interpretation depends on penalty_type: a fixed monetary amount (in contract currency) for fixed_fee, or a percentage for percentage_of_invoice. Commercially sensitive.',
    `regulatory_commitment_flag` BOOLEAN COMMENT 'Indicates whether this SLA is directly tied to a regulatory reporting obligation (e.g., FDA 15-day SAE reporting, EMA SUSAR submission timelines). True = regulatory deadline drives the SLA threshold; False = contractual performance target only.',
    `reporting_format` STRING COMMENT 'Agreed format for communicating SLA performance results to the sponsor: dashboard (real-time portal), monthly_report (formal written report), quarterly_review (governance meeting), ad_hoc (on-request), automated_alert (system-generated notification).. Valid values are `dashboard|monthly_report|quarterly_review|ad_hoc|automated_alert`',
    `service_category` STRING COMMENT 'High-level classification of the service domain governed by this SLA (e.g., Safety Reporting, Data Management, Site Monitoring, Patient Recruitment, Regulatory Submissions, Biostatistics, Supply Chain).',
    `service_subcategory` STRING COMMENT 'Granular classification within the service category (e.g., within Safety Reporting: SAE Initial Report, SUSAR Submission; within Data Management: Query Resolution, Data Entry Lag). Enables fine-grained SLA performance analytics.',
    `sla_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this SLA within the contract management system (e.g., SLA-QRY-001). Used as the business key for cross-system reference and regulatory traceability.. Valid values are `^SLA-[A-Z0-9]{3,20}$`',
    `sla_status` STRING COMMENT 'Current lifecycle state of the SLA: draft (under negotiation), active (in force), suspended (temporarily paused by mutual agreement), expired (past effective end date), terminated (ended early), superseded (replaced by an amendment).. Valid values are `draft|active|suspended|expired|terminated|superseded`',
    `sla_title` STRING COMMENT 'Human-readable short title describing the SLA commitment (e.g., SAE Reporting Turnaround – 24h, Query Resolution – 5 Business Days). Used in dashboards, reports, and sponsor communications.',
    `sla_type` STRING COMMENT 'Classification of the SLA metric type: response_time (time to first action), turnaround_time (time to completion), frequency (how often an activity must occur), rate (throughput rate), percentage (proportion-based target), count (absolute volume target).. Valid values are `response_time|turnaround_time|frequency|rate|percentage|count`',
    `target_metric_name` STRING COMMENT 'Descriptive name of the specific performance metric being measured (e.g., Time to SAE Initial Report, Query Resolution Turnaround, Monitoring Visit Frequency, Data Entry Lag Days, Site Activation Cycle Time).',
    `threshold_direction` STRING COMMENT 'Specifies whether compliance requires the measured value to be less than or equal to (e.g., turnaround time ≤ 24h), greater than or equal to (e.g., visit frequency ≥ 1/month), or exactly equal to the threshold. Critical for automated compliance evaluation.. Valid values are `less_than_or_equal|greater_than_or_equal|equal`',
    `threshold_unit` STRING COMMENT 'Unit of measure for the threshold value (e.g., hours, business_days, calendar_days, percentage, visits_per_month). Defines how the threshold_value is interpreted for compliance assessment.',
    `threshold_value` DECIMAL(18,4) COMMENT 'The numeric performance threshold that the CRO must meet or exceed for this SLA (e.g., 24 for a 24-hour SAE reporting window, 95 for 95% query resolution rate, 5 for 5 business days). The principal quantitative commitment of the SLA.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this SLA record. Supports change detection, incremental ETL processing, and audit trail requirements under 21 CFR Part 11.',
    `version_number` BIGINT COMMENT 'Sequential version number of this SLA record, incremented each time the SLA terms are renegotiated or amended. Supports version history tracking and audit trail requirements under 21 CFR Part 11.',
    CONSTRAINT pk_service_level_agreement PRIMARY KEY(`service_level_agreement_id`)
) COMMENT 'Service Level Agreement (SLA) defining measurable performance commitments the CRO must meet for specific service categories (e.g., query resolution turnaround, SAE reporting timelines, monitoring visit frequency, data entry lag).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` (
    `agreement_billing_milestone_id` BIGINT COMMENT 'Unique surrogate identifier for the billing milestone record in the agreement domain. Primary key for this entity.',
    `approver_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Billing milestone approvals require an auditable employee reference for financial controls, revenue recognition sign-off, and delegation-of-authority compliance.',
    `change_order_id` BIGINT COMMENT 'Foreign key linking to agreement.change_order. Business justification: billing_milestone currently stores change_order_number as a STRING denormalized reference.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor entity that is the billing counterparty for this milestone.',
    `scope_of_work_id` BIGINT COMMENT 'Reference to the specific Statement of Work (SOW) or scope of work document that governs this billing milestone, if applicable.',
    `study_contract_id` BIGINT COMMENT 'Reference to the parent study contract or master service agreement under which this billing milestone is defined.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study or trial associated with this billing milestone, enabling study-level financial tracking.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Specific billing milestones are triggered by regulatory submission events (e.g., payment upon IND submission, NDA filing).',
    `actual_trigger_date` DATE COMMENT 'Actual calendar date on which the qualifying trigger event occurred, confirming the milestone has been achieved. Null if the milestone has not yet been triggered.',
    `adjusted_amount` DECIMAL(18,2) COMMENT 'Final invoiceable amount after applying any contractual adjustments, change orders, or amendments to the original milestone amount. May differ from milestone_amount when scope changes have been approved.',
    `approval_date` DATE COMMENT 'Date on which the billing milestone was formally approved for invoicing by the authorized approver.',
    `approval_status` STRING COMMENT 'Internal approval workflow status for the billing milestone before invoicing. Some milestones require sponsor sign-off or internal finance approval prior to invoice generation.. Valid values are `not_required|pending_approval|approved|rejected`',
    `billing_status` STRING COMMENT 'Current lifecycle status of the billing milestone. Pending: milestone not yet triggered; Triggered: qualifying event has occurred; Invoiced: invoice has been issued to sponsor; Paid: payment received; Disputed: sponsor has raised a dispute; Cancelled. Valid values are `pending|triggered|invoiced|paid|disputed|cancelled`',
    `cost_center_code` STRING COMMENT 'the source system center code to which the revenue and costs associated with this billing milestone are allocated for internal financial reporting.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this billing milestone record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail and data lineage requirements.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the milestone amount (e.g., USD, EUR, GBP, JPY). Determines the currency in which the invoice will be issued.. Valid values are `^[A-Z]{3}$`',
    `deliverable_description` STRING COMMENT 'Detailed description of the specific deliverable, event, or condition that activates this billing milestone (e.g., Submission of final Clinical Study Report (CSR) to sponsor, Achievement of 50% patient enrollment target).',
    `dispute_reason` STRING COMMENT 'Description of the reason provided by the sponsor or CRO for disputing this billing milestone. Populated only when billing_status is disputed.',
    `dispute_resolution_date` DATE COMMENT 'Date on which a billing dispute for this milestone was formally resolved between the CRO and sponsor. Null if no dispute exists or dispute is still open.',
    `enrollment_target_count` BIGINT COMMENT 'For enrollment-based milestones, the number of patients enrolled that must be achieved to trigger this milestone. Null for non-enrollment-based milestone types.',
    `functional_area` STRING COMMENT 'Clinical trial functional area or service line to which this milestone belongs (e.g., Clinical Operations, Data Management, Biostatistics, Regulatory Affairs, Safety). Used for service-line revenue reporting.',
    `invoice_date` DATE COMMENT 'Date on which the invoice was issued to the sponsor for this billing milestone. Null if the milestone has not yet been invoiced.',
    `invoice_number` STRING COMMENT 'Reference number of the invoice issued to the sponsor for this billing milestone, as generated in the source system receivable. Links to the sponsor invoice record.',
    `is_pass_through` BOOLEAN COMMENT 'Indicates whether this milestone represents a pass-through cost (True) that is billed to the sponsor at cost without CRO margin, or a fee-for-service milestone (False) subject to standard markup.',
    `milestone_amount` DECIMAL(18,2) COMMENT 'Contractually agreed gross amount to be invoiced upon achievement of this milestone, expressed in the contract currency. This is the base billing amount before any adjustments.',
    `milestone_name` STRING COMMENT 'Human-readable name of the billing milestone as defined in the contract or SOW (e.g., First Patient First Visit, Database Lock, Final CSR Delivery).',
    `milestone_number` STRING COMMENT 'Externally-known unique alphanumeric identifier for the billing milestone as referenced in the contract, SOW, or the source system accounting system (e.g., MS-2024-0042).',
    `milestone_sequence` BIGINT COMMENT 'Ordinal sequence number of this milestone within the contract or SOW, defining the chronological order in which milestones are expected to be achieved and billed.',
    `milestone_type` STRING COMMENT 'Classification of the billing milestone by the nature of its trigger mechanism. Enrollment-based milestones are triggered by patient enrollment counts; visit-based by clinical visit completion; deliverable-based by document or data deliverable submission. Valid values are `enrollment_based|visit_based|deliverable_based|time_based|safety_based`',
    `notes` STRING COMMENT 'Free-text field for capturing additional context, conditions, or commentary related to this billing milestone, such as special contractual conditions or sponsor-specific requirements.',
    `payment_due_date` DATE COMMENT 'Contractually defined date by which the sponsor must remit payment for the invoiced milestone amount, based on agreed payment terms.',
    `payment_received_date` DATE COMMENT 'Date on which payment was received from the sponsor for this milestone. Null if payment has not yet been received.',
    `payment_terms` STRING COMMENT 'Contractual payment terms specifying the number of days within which the sponsor must pay after invoice issuance (e.g., NET30, NET45, NET60). Sourced from the contract or the source system master.',
    `percent_complete` DECIMAL(5,2) COMMENT 'Percentage of the milestone completion criteria that have been satisfied as of the last assessment, ranging from 0.00 to 100.00. Used for revenue recognition and project progress tracking.',
    `planned_trigger_date` DATE COMMENT 'Contractually planned calendar date on which the milestone trigger event is expected to occur, as defined in the original SOW or project plan.',
    `project_code` STRING COMMENT 'the source system accounting code (WBS element or project number) under which this billing milestone is tracked for project cost and revenue management.',
    `revenue_recognition_method` STRING COMMENT 'Accounting method applied to recognize revenue for this milestone under IFRS 15 / ASC 606. Point-in-time recognition applies when control transfers at a single moment; over-time when performance obligations are satisfied continuously.. Valid values are `point_in_time|over_time|percentage_completion`',
    `source_record_reference` STRING COMMENT 'Native identifier of this billing milestone record in the originating source system (e.g., the source system plan item ID or project milestone ID), enabling traceability back to the system of record.',
    `trigger_event_code` STRING COMMENT 'Standardized code identifying the specific business event that triggers this milestone (e.g., FPFV for First Patient First Visit, DBL for Database Lock, CSR_FINAL for Final CSR Delivery). Aligns with CTMS event taxonomy.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this billing milestone record, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail and change tracking.',
    `visit_count_target` BIGINT COMMENT 'For visit-based milestones, the cumulative number of subject visits that must be completed to trigger this milestone. Null for non-visit-based milestone types.',
    `wbs_element` STRING COMMENT 'Work Breakdown Structure (WBS) element code from the source system maps this billing milestone to a specific deliverable or phase within the project hierarchy.',
    CONSTRAINT pk_agreement_billing_milestone PRIMARY KEY(`agreement_billing_milestone_id`)
) COMMENT 'Contractually defined billing milestone tied to a study contract or SOW, representing a specific deliverable or event that triggers an invoice. Captures milestone name, milestone type (enrollment-based, visit-based, deliverable-based, time-based), planned';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`agreement`.`deliverable` (
    `deliverable_id` BIGINT COMMENT 'Unique system-generated identifier for each contractually committed deliverable record within the agreement domain.',
    `agreement_billing_milestone_id` BIGINT COMMENT 'Reference to the finance billing milestone that is triggered upon acceptance of this deliverable. Links contractual delivery to revenue recognition and sponsor invoicing.',
    `change_order_id` BIGINT COMMENT 'Foreign key linking to agreement.change_order. Business justification: deliverable currently stores change_order_reference as a STRING denormalized reference.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: Deliverables (data management plans, monitoring reports, statistical analysis plans) must be produced per specific SOPs.',
    `employee_id` BIGINT COMMENT 'Reference to the CRO staff member (typically a Project Manager or functional lead) who is the named accountable owner for this deliverables timely and quality completion.',
    `organization_contact_id` BIGINT COMMENT 'FK to sponsor.sponsor_contact',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that commissioned this deliverable under the CRO agreement.',
    `scope_of_work_id` BIGINT COMMENT 'Reference to the Statement of Work (SOW) or study contract under which this deliverable is defined. Links the deliverable to its governing commercial agreement.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this deliverable is scoped. Enables study-level tracking of all contractual outputs.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Many contractual deliverables are regulatory submission components (CTD modules, IND packages, safety reports). The deliverable already has regulatory_submission_flag.',
    `acceptance_criteria` STRING COMMENT 'Contractually defined quality and completeness criteria that the deliverable must satisfy for sponsor acceptance, as specified in the SOW. Used by QA reviewers and project managers during review.',
    `acceptance_date` DATE COMMENT 'Date on which the sponsor formally accepted the deliverable as meeting the contractual acceptance criteria. Triggers billing milestone recognition and TMF archival.',
    `actual_delivery_date` DATE COMMENT 'Date on which the CRO formally submitted or transmitted the deliverable to the sponsor. Compared against planned_delivery_date to calculate schedule variance and SLA compliance.',
    `actual_effort_hours` DECIMAL(10,2) COMMENT 'Actual labor hours expended to produce and deliver this deliverable. Compared against estimated_effort_hours to calculate effort variance and inform future SOW scoping.',
    `deliverable_category` STRING COMMENT 'Functional domain category of the deliverable, indicating which CRO functional team is primarily responsible (e.g., clinical, statistical, data management, regulatory, safety, monitoring).',
    `cdisc_compliant_flag` BOOLEAN COMMENT 'Indicates whether this deliverable (typically a dataset or tabulation) must conform to CDISC SDTM or ADaM standards as required by the sponsor or regulatory authority.',
    `deliverable_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this deliverable within the SOW or contract. Used in sponsor communications, billing milestones, and regulatory submissions.. Valid values are `^DLV-[A-Z0-9]{4,20}$`',
    `contracted_value_usd` DECIMAL(18,2) COMMENT 'Monetary value assigned to this deliverable in the SOW or contract, denominated in US Dollars. Represents the billable amount triggered upon acceptance. Business-confidential commercial data.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this deliverable record was first created in the system, including timezone offset. Supports ALCOA+ audit trail and 21 CFR Part 11 electronic record requirements.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the contracted value (e.g., USD, EUR, GBP, JPY). Supports multi-currency sponsor agreements.. Valid values are `^[A-Z]{3}$`',
    `days_overdue` BIGINT COMMENT 'Number of calendar days by which the actual delivery date exceeded the planned delivery date. Negative values indicate early delivery. Used for SLA performance reporting and sponsor relationship management.',
    `delivery_method` STRING COMMENT 'Channel or mechanism by which the deliverable is transmitted to the sponsor (e.g., eTMF upload, secure email, sponsor portal, eCTD gateway). Supports audit trail and compliance verification.. Valid values are `etmf_upload|secure_email|sponsor_portal|ectd_gateway|physical|other`',
    `delivery_status` STRING COMMENT 'Current lifecycle state of the deliverable from initiation through sponsor acceptance. Drives milestone billing triggers and project management dashboards.. Valid values are `not_started|in_progress|submitted|accepted|rejected|on_hold`',
    `document_reference_number` STRING COMMENT 'Identifier of the associated document record in the eTMF or document management system (e.g., Veeva Vault document ID) for the accepted deliverable artifact. Enables cross-system traceability.',
    `estimated_effort_hours` DECIMAL(10,2) COMMENT 'Planned labor hours estimated to produce this deliverable, as defined during SOW scoping. Used for resource planning, budget tracking, and variance analysis against actuals.',
    `gcp_audit_required_flag` BOOLEAN COMMENT 'Indicates whether this deliverable requires a formal GCP quality audit prior to submission, as mandated by the sponsors quality agreement or applicable regulatory requirements.',
    `deliverable_name` STRING COMMENT 'Human-readable name of the contractual deliverable as defined in the SOW (e.g., Clinical Study Report, Statistical Analysis Plan, Data Management Plan, Monitoring Plan, Regulatory Submission Package).',
    `notes` STRING COMMENT 'Free-text field for project managers and functional leads to capture contextual information, sponsor feedback, escalation notes, or special instructions related to this deliverable.',
    `phase_milestone` STRING COMMENT 'Study phase or operational milestone during which this deliverable is due (e.g., startup, enrollment, interim, closeout, post-study). Supports timeline planning and phase-gate reporting.. Valid values are `startup|enrollment|interim|closeout|post_study`',
    `planned_delivery_date` DATE COMMENT 'Contractually committed date by which the CRO must deliver this output to the sponsor, as defined in the SOW or study contract. Used for SLA tracking and milestone billing.',
    `priority_level` STRING COMMENT 'Business priority assigned to this deliverable, reflecting its criticality to the study timeline, regulatory submission, or sponsor relationship. Used for resource prioritization and escalation decisions.. Valid values are `critical|high|medium|low`',
    `qc_review_status` STRING COMMENT 'Current status of the internal QC review process for this deliverable prior to sponsor submission. Ensures GCP compliance and reduces rejection risk.. Valid values are `not_required|pending|in_review|passed|failed`',
    `regulatory_submission_flag` BOOLEAN COMMENT 'Indicates whether this deliverable is intended for inclusion in a regulatory submission package (e.g., NDA, BLA, MAA, eCTD). When true, triggers enhanced QC review and audit trail requirements.',
    `rejection_reason` STRING COMMENT 'Sponsor-provided rationale for rejecting the deliverable submission. Populated when delivery_status is rejected. Used for root cause analysis and CAPA tracking.',
    `responsible_functional_team` STRING COMMENT 'CRO functional team accountable for producing and delivering this output (e.g., Biostatistics, Data Management, Clinical Operations, Regulatory Affairs, Medical Writing). Drives resource allocation and escalation routing.',
    `review_deadline_date` DATE COMMENT 'Contractually defined date by which the sponsor must complete review and provide acceptance or rejection feedback. Supports SLA enforcement and escalation workflows.',
    `revision_count` BIGINT COMMENT 'Total number of revision cycles this deliverable has undergone following initial submission. High revision counts may indicate quality issues or unclear acceptance criteria.',
    `revision_due_date` DATE COMMENT 'Date by which the CRO must resubmit a revised deliverable following sponsor rejection or request for changes. Populated only when delivery_status is rejected.',
    `sla_met_flag` BOOLEAN COMMENT 'Indicates whether the deliverable was submitted within the contractually defined SLA target days. Populated upon actual delivery. Used for sponsor performance reporting and contract compliance.',
    `sla_target_days` BIGINT COMMENT 'Contractually defined number of calendar days within which the CRO must deliver this output from the triggering event (e.g., database lock, last patient last visit). Basis for SLA compliance measurement.',
    `submission_timestamp` TIMESTAMP COMMENT 'Precise date and time when the deliverable was formally submitted to the sponsor, including timezone offset. Supports ALCOA+ audit trail requirements for electronic records.',
    `tmf_filing_required_flag` BOOLEAN COMMENT 'Indicates whether the accepted deliverable must be archived in the electronic Trial Master File (eTMF) per ICH E6(R2) and sponsor TMF reference model requirements.',
    `deliverable_type` STRING COMMENT 'Classification of the deliverable by output category. Drives workflow routing, acceptance criteria templates, and regulatory tracking. [ENUM-REF-CANDIDATE: report|plan|submission|dataset|package|database|training_material|other — promote to reference. Valid values are `report|plan|submission|dataset|package|other`',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this deliverable record was last modified, including timezone offset. Supports change tracking, audit trail, and data lineage requirements.',
    `version_number` STRING COMMENT 'Version identifier of the deliverable at the time of submission (e.g., v1.0, v2.1). Tracks revision history and ensures sponsor and CRO are aligned on the correct document version.. Valid values are `^v?[0-9]+.[0-9]+(.[0-9]+)?$`',
    CONSTRAINT pk_deliverable PRIMARY KEY(`deliverable_id`)
) COMMENT 'Contractually committed deliverable defined within a SOW or study contract, representing a specific output the CRO must produce (e.g., Clinical Study Report, Statistical Analysis Plan, Data Management Plan, Monitoring Plan, Regulatory Submission Package).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` (
    `investigator_grant_id` BIGINT COMMENT 'Primary key for investigator_grant',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Investigator grant approvals require employee-level traceability for fair market value compliance, Sunshine Act reporting, and financial controls.',
    `audit_id` BIGINT COMMENT 'Foreign key linking to compliance.audit. Business justification: Investigator grants are subject to fair market value audits (fair_market_value_verified, sunshine_act_reportable fields) and GCP site audits.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: Investigator grants cannot be executed and sites cannot be activated without a valid CTA for that country.',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: Investigator grants cannot be executed without IRB/IEC ethics approval (irb_iec_approval_required flag).',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site (clinical research site) that is party to this grant agreement.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor on whose behalf the CRO has negotiated this investigator grant.',
    `principal_investigator_id` BIGINT COMMENT 'FK to site.principal_investigator',
    `study_contract_id` BIGINT COMMENT 'Foreign key linking to agreement.study_contract. Business justification: An investigator grant agreement is executed by the CRO on behalf of the sponsor under a governing study contract (CTA).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this investigator grant is established. Links the grant to the specific trial protocol.',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to site.study_site. Business justification: An investigator grant is created for a specific study-site combination. Linking investigator_grant to study_site enables direct lookup of the operational site record during payment',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Investigator grants are TMF Zone 1/2 essential documents (financial disclosure, site agreements).',
    `amendment_number` BIGINT COMMENT 'Sequential amendment counter for this grant. Zero (0) indicates the original grant; each subsequent amendment increments this value. Used to track renegotiation history.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time at which the grant was formally approved internally by the CRO. Provides a precise audit trail event for the approval lifecycle stage.',
    `confidentiality_level` STRING COMMENT 'Data classification level assigned to this grant record per the enterprise data governance policy. Governs access controls and data handling requirements.. Valid values are `restricted|confidential|internal|public`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the investigational site. Determines applicable regulatory requirements, tax treatment, currency, and local payment regulations for the grant.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this investigator grant record was first created in the system. Supports ALCOA+ data integrity requirements and audit trail completeness.',
    `ctms_grant_reference` STRING COMMENT 'Identifier of the corresponding investigator grant record in the source system Enables cross-system traceability between the lakehouse Silver layer and the operational CTMS.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which all grant rates and payments are denominated (e.g., USD, EUR, GBP, JPY). Governs all financial calculations for this grant.. Valid values are `^[A-Z]{3}$`',
    `effective_date` DATE COMMENT 'Date from which the grant rates and terms become binding and applicable for site payment calculations. Aligns with the study start date or amendment execution date.',
    `execution_date` DATE COMMENT 'Date on which the investigator grant was formally signed and executed by all parties (CRO and Principal Investigator / site). Required for regulatory audit trail.',
    `expiry_date` DATE COMMENT 'Date on which the grant terms cease to be applicable. Null for open-ended grants that remain active until superseded or the study closes.',
    `fair_market_value_verified` BOOLEAN COMMENT 'Indicates whether the grant payment rates have been verified against Fair Market Value (FMV) benchmarks to ensure compliance with anti-kickback statutes and industry transparency requirements (e.g., Sunshine Act).',
    `fmv_benchmark_source` STRING COMMENT 'Source of the Fair Market Value benchmark data used to validate grant payment rates (e.g., Medidata Grants Manager, McLaughlin & Associates, BBK Worldwide, internal database). Required for compliance documentation.. Valid values are `medidata_grants_manager|mclaughlin_associates|bbk_worldwide|internal_database|other`',
    `governing_law` STRING COMMENT 'Jurisdiction whose laws govern the interpretation and enforcement of this investigator grant (e.g., State of New York, England and Wales, Germany). Critical for dispute resolution.',
    `grant_number` STRING COMMENT 'Externally-known alphanumeric identifier for the investigator grant, used in CTMS, the source system orders, and site correspondence. Serves as the business-facing reference number across systems.',
    `grant_title` STRING COMMENT 'Descriptive title of the investigator grant agreement, typically referencing the study protocol number and site name for human-readable identification.',
    `grant_type` STRING COMMENT 'Classification of the investigator grant structure. Per-capita grants pay a fixed amount per enrolled subject; fee-for-service grants pay per completed procedure/visit; hybrid combines both; fixed-fee covers all site activities for a lump sum.. Valid values are `per_capita|fee_for_service|hybrid|fixed_fee`',
    `grant_version` STRING COMMENT 'Version identifier of the investigator grant document (e.g., v1.0, v2.0). Incremented with each amendment or renegotiation cycle to maintain a complete audit trail of rate changes.',
    `irb_iec_approval_required` BOOLEAN COMMENT 'Indicates whether the grant terms (particularly payment rates) require review and approval by the sites Institutional Review Board (IRB) or Independent Ethics Committee (IEC) to ensure payments do not constitute undue inducement.',
    `negotiation_status` STRING COMMENT 'Current lifecycle state of the investigator grant negotiation process. Tracks progression from initial draft through site negotiation, internal approval, execution, and potential supersession by an amendment.',
    `notes` STRING COMMENT 'Free-text field for capturing negotiation context, special terms, site-specific conditions, or other qualitative information relevant to this investigator grant that is not captured in structured fields.',
    `overhead_percentage` DECIMAL(5,2) COMMENT 'Institutional overhead or indirect cost rate (expressed as a percentage) applied on top of direct procedure and visit costs. Negotiated with the site institution and added to the base grant rates.',
    `pass_through_budget` DECIMAL(15,2) COMMENT 'Portion of the grant budget designated as pass-through costs (e.g., lab fees, imaging, central lab kits) that are reimbursed at cost without markup. Tracked separately from service fees for financial reporting.',
    `payment_method` STRING COMMENT 'Agreed mechanism for disbursing grant payments to the investigational site or PI (e.g., wire transfer, ACH, check). Drives the source system payable processing.. Valid values are `wire_transfer|check|ach|direct_deposit|virtual_card`',
    `payment_schedule_type` STRING COMMENT 'Classification of the payment trigger mechanism for this grant. Determines how and when site payments are generated: per completed visit, per completed procedure, upon milestone achievement, or on a periodic basis.. Valid values are `per_visit|per_procedure|milestone|monthly|quarterly|completion`',
    `payment_terms_days` BIGINT COMMENT 'Number of days from invoice receipt or milestone trigger within which payment must be made to the site. Standard net payment terms (e.g., Net 30, Net 45) as agreed in the grant.',
    `planned_subject_count` BIGINT COMMENT 'Number of subjects the site is contracted to enroll under this grant. Drives the total grant value calculation and site capacity planning.',
    `sap_purchase_order_number` STRING COMMENT 'the source system order number created to encumber funds for this investigator grant. Links financial commitments in the ERP to the contractual grant terms.',
    `screen_failure_payment_amount` DECIMAL(15,2) COMMENT 'Fixed monetary amount payable to the site per screen-failed subject, in the grant currency. Used when screen failure compensation is a flat fee rather than a percentage.',
    `screen_failure_rate` DECIMAL(5,2) COMMENT 'Agreed reimbursement rate per screen-failed subject (as a percentage of the full screening visit cost or a fixed amount). Compensates sites for screening work on subjects who do not meet eligibility criteria.',
    `service_fee_budget` DECIMAL(15,2) COMMENT 'Portion of the grant budget representing direct service fees for investigator and site staff time (visits, procedures, coordination). Excludes pass-through costs.',
    `sunshine_act_reportable` BOOLEAN COMMENT 'Indicates whether payments under this grant are reportable under the US Physician Payments Sunshine Act (Open Payments) or equivalent transparency regulations. Drives compliance reporting workflows.',
    `tax_identification_number` STRING COMMENT 'Tax identification number (TIN) or VAT registration number of the investigational site or PI entity for payment processing and tax reporting compliance.',
    `total_grant_value` DECIMAL(18,2) COMMENT 'Total estimated monetary value of the investigator grant based on planned subject enrollment, visit schedule, and procedure rates. Used for budget planning, accrual calculations, and the source system creation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this investigator grant record. Supports change tracking, audit trail, and data lineage requirements.',
    `vat_applicable` BOOLEAN COMMENT 'Indicates whether Value Added Tax (VAT) or equivalent indirect tax applies to payments under this grant. Drives tax calculation logic in the source system payable.',
    `withholding_percentage` DECIMAL(5,2) COMMENT 'Percentage of each payment withheld and held in reserve until study completion or database lock (DBL). Released upon satisfactory completion of site obligations. Common risk-management mechanism in investigator grants.',
    CONSTRAINT pk_investigator_grant PRIMARY KEY(`investigator_grant_id`)
) COMMENT 'Contractual grant agreement between the CRO (on behalf of the sponsor) and an investigational site or Principal Investigator (PI) defining per-procedure and per-visit payment rates for conducting the clinical trial.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` (
    `contract_negotiation_id` BIGINT COMMENT 'Unique surrogate identifier for each contract negotiation record in the Clinical Trials lakehouse silver layer.',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: MSA-level contract negotiations (already linked via master_service_agreement_id) cover entire clinical programs.',
    `compliance_obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: Contract negotiations must incorporate regulatory compliance obligations as non-negotiable terms.',
    `contract_amendment_id` BIGINT COMMENT 'Reference to the contract amendment being negotiated, if this negotiation relates to an amendment rather than the original agreement. Null for initial contract negotiations.',
    `cro_lead_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: The CRO lead on a contract negotiation is a specific internal employee. This FK supports negotiation team tracking, workload reporting across active negotiations, and key personnel',
    `master_service_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.master_service_agreement. Business justification: Contract negotiations occur not only at the study contract level but also at the MSA level.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that is a primary negotiating party in this contract negotiation.',
    `regulatory_strategy_id` BIGINT COMMENT 'Foreign key linking to regulatory.strategy. Business justification: CRO contract negotiations are scoped and timed according to the regulatory strategy — planned IND/NDA submission dates drive contract execution deadlines.',
    `scope_of_work_id` BIGINT COMMENT 'Foreign key linking to agreement.scope_of_work. Business justification: Negotiations frequently occur at the SOW level — sponsors and CROs negotiate specific service scopes, budgets, and timelines defined in a Scope of Work.',
    `study_contract_id` BIGINT COMMENT 'Reference to the parent contract or master service agreement that this negotiation pertains to.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `version_id` BIGINT COMMENT 'Foreign key linking to document.document_version. Business justification: Contract negotiation rounds track specific document versions under redline review.',
    `actual_execution_date` DATE COMMENT 'Calendar date on which the contract was fully executed and signed by all required parties. Null until execution is complete. Compared against target_execution_date to measure negotiation cycle time variance.',
    `approval_date` DATE COMMENT 'Date on which all required internal approvers (e.g., finance, legal, executive) granted approval for the negotiated contract terms, enabling progression to execution. Null until approval is granted.',
    `approved_by` STRING COMMENT 'Name or user identifier of the individual who granted final internal approval for the negotiated contract terms. Supports audit trail and SOX compliance for contract authorization.',
    `confidentiality_level` STRING COMMENT 'Data classification level assigned to this negotiation record per enterprise data governance policy. Drives access control and data handling requirements in the lakehouse.. Valid values are `restricted|confidential|internal|public`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this contract negotiation record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `ctms_negotiation_reference` STRING COMMENT 'Cross-reference identifier for this negotiation record in the source system enabling reconciliation between the lakehouse silver layer and the operational CTMS system of record.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the negotiated contract value (e.g., USD, EUR, GBP). Ensures consistent financial reporting across multi-currency sponsor engagements.. Valid values are `^[A-Z]{3}$`',
    `document_version` STRING COMMENT 'Version label of the contract document under negotiation in this round (e.g., v1.0, v2.3). Tracks document lineage across negotiation rounds and aligns with Veeva Vault version control.. Valid values are `^v[0-9]+.[0-9]+(.[0-9]+)?$`',
    `escalation_date` DATE COMMENT 'Date on which the negotiation was formally escalated to senior management or executive leadership. Null if escalation_flag is False.',
    `escalation_flag` BOOLEAN COMMENT 'Indicates whether this negotiation has been escalated to senior management or executive leadership due to stalled progress, unresolved issues, or timeline risk. True = escalated; False = normal track.',
    `escalation_reason` STRING COMMENT 'Categorized reason for escalation of the negotiation to senior leadership. Enables root cause analysis of contracting bottlenecks. [ENUM-REF-CANDIDATE: timeline_risk|unresolved_legal_terms|budget_disagreement|scope_dispute|executive_alignment|other —',
    `governing_law_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction whose laws govern the contract being negotiated (e.g., USA, GBR, DEU). Determines applicable regulatory and legal framework for dispute resolution.. Valid values are `^[A-Z]{3}$`',
    `legal_counsel_cro` STRING COMMENT 'Name of the internal or external legal counsel representing the CRO during contract negotiation. Populated when legal review is engaged (negotiation_status = legal_review or later).',
    `legal_counsel_sponsor` STRING COMMENT 'Name of the internal or external legal counsel representing the sponsor during contract negotiation. Populated when sponsor legal review is engaged.',
    `legal_review_end_date` DATE COMMENT 'Date on which legal counsel completed their review and returned comments or approval for the current negotiation round. Null if legal review is still in progress.',
    `legal_review_start_date` DATE COMMENT 'Date on which the contract was formally submitted to legal counsel for review in this negotiation round. Enables measurement of legal review cycle time as a component of overall negotiation duration.',
    `negotiated_contract_value` DECIMAL(18,2) COMMENT 'Total contract value as agreed or proposed in the current negotiation round, expressed in the billing currency. May differ from the final executed value if further rounds occur. Supports financial forecasting and budget alignment.',
    `negotiation_channel` STRING COMMENT 'Primary communication and document exchange channel used during this negotiation round (e.g., Veeva Vault for document redlining, DocuSign for execution, email for correspondence).. Valid values are `email|veeva_vault|docusign|in_person|video_conference|legal_portal`',
    `negotiation_number` STRING COMMENT 'Externally visible, human-readable business identifier for this negotiation instance, used in correspondence and CTMS tracking (e.g., NEG-ONCOL-002341). Unique across the enterprise.. Valid values are `^NEG-[A-Z0-9]{4,10}-[0-9]{4,6}$`',
    `negotiation_round` BIGINT COMMENT 'Sequential integer indicating which round of negotiation this record represents (e.g., 1 = initial draft exchange, 2 = first redline response). Enables cycle time analysis per round.',
    `negotiation_start_date` DATE COMMENT 'Calendar date on which the negotiation process was formally initiated, typically when the first draft was circulated to the counterparty. Used as the baseline for cycle time measurement.',
    `negotiation_status` STRING COMMENT 'Current workflow state of the contract negotiation lifecycle. Tracks progression from initial draft through final execution: draft (initial version created), under_review (circulated for internal review), redline (counterparty markup received). Valid values are `draft|under_review|redline|legal_review|approved|executed`',
    `negotiation_type` STRING COMMENT 'Classification of the contract instrument being negotiated. Distinguishes between Master Service Agreements (MSA), Scope of Work (SOW) documents, Change Orders (CO), Amendments, Confidentiality Agreements (CDA/NDA), and Service Level Agreements (SLA).. Valid values are `master_service_agreement|scope_of_work|change_order|amendment|confidentiality_agreement|service_level_agreement`',
    `notes` STRING COMMENT 'Free-text field for capturing additional context, negotiation strategy notes, or internal commentary relevant to this negotiation record. Restricted to authorized contracts and legal personnel.',
    `open_issue_count` BIGINT COMMENT 'Number of distinct unresolved contractual issues or redline items outstanding at the time of the current negotiation round. Used as a KPI for negotiation complexity and progress tracking.',
    `open_issues_summary` STRING COMMENT 'Free-text summary of the key unresolved issues or points of contention remaining in the current negotiation round (e.g., indemnification clauses, IP ownership, payment terms, liability caps). Supports bottleneck identification and escalation decisions.',
    `pass_through_value` DECIMAL(18,2) COMMENT 'Portion of the negotiated contract value designated as pass-through costs (e.g., investigator grants, lab fees, travel) as proposed in the current negotiation round. Distinct from service fee budget.',
    `payment_model` STRING COMMENT 'Commercial payment structure being negotiated for this contract (e.g., milestone_based = payments tied to deliverable completion, time_and_materials = resource-rate billing, fixed_fee = lump sum, unit_based = per-patient or per-site pricing, hybrid =. Valid values are `milestone_based|time_and_materials|fixed_fee|unit_based|hybrid`',
    `priority_level` STRING COMMENT 'Business priority assigned to this negotiation, reflecting urgency relative to study start timelines, sponsor commitments, or regulatory milestones. Drives resource allocation in the contracts team.. Valid values are `critical|high|medium|low`',
    `redline_received_date` DATE COMMENT 'Date on which the counterpartys marked-up (redlined) version of the contract was received in the current negotiation round. Null if no redline has been received. Used to measure counterparty response time.',
    `round_end_date` DATE COMMENT 'Date on which the current negotiation round concluded, i.e., when a response was received or the round was closed. Null if the round is still open. Used to compute per-round turnaround time.',
    `round_start_date` DATE COMMENT 'Date on which the current negotiation round commenced, i.e., when the draft or redline was sent to the counterparty for this specific round. Enables per-round cycle time analysis.',
    `sap_contract_reference` STRING COMMENT 'Cross-reference to the corresponding contract object in the source system accounting module), enabling financial reconciliation of negotiated contract values against purchase orders and accruals.',
    `service_fee_value` DECIMAL(18,2) COMMENT 'Portion of the negotiated contract value representing CRO service fees (professional services, management fees) as proposed in the current negotiation round. Distinct from pass-through costs.',
    `sponsor_lead_contact` STRING COMMENT 'Name or identifier of the primary sponsor representative leading the negotiation on behalf of the pharmaceutical or biotech sponsor. Typically a procurement officer or legal counsel.',
    `target_execution_date` DATE COMMENT 'Planned date by which the contract is expected to be fully executed (signed by all parties). Used for SLA tracking and bottleneck identification in the contracting process.',
    `termination_flag` BOOLEAN COMMENT 'Indicates whether this negotiation was terminated without reaching execution (e.g., sponsor withdrew, parties could not agree). True = terminated without execution; False = active or successfully executed.',
    `termination_reason` STRING COMMENT 'Categorized reason for termination of the negotiation without execution. Populated only when termination_flag is True. Supports win/loss analysis and process improvement.. Valid values are `sponsor_withdrawal|budget_disagreement|scope_disagreement|legal_impasse|competitive_loss|other`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this contract negotiation record, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports change tracking and audit trail requirements under 21 CFR Part 11.',
    `veeva_vault_document_number` STRING COMMENT 'External reference identifier for the contract document stored in Veeva Vault (eTMF/regulatory submissions system). Enables direct traceability from the negotiation record to the source document in the system of record.',
    CONSTRAINT pk_contract_negotiation PRIMARY KEY(`contract_negotiation_id`)
) COMMENT 'Tracks the negotiation lifecycle of a contract or amendment from initial draft through final execution. Captures negotiation round number, negotiation status (draft, under review, redline, legal review, approved, executed), negotiation start date, target';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` (
    `contract_obligation_id` BIGINT COMMENT 'Unique system-generated identifier for each contractual obligation record tracked within the agreement domain.',
    `compliance_obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: Contract obligations are frequently derived from or mapped to regulatory compliance obligations (ICH E6, FDA 21 CFR).',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: Contract obligations mandate adherence to specific SOPs (e.g., obligation to conduct monitoring per SOP-MON-001).',
    `contract_amendment_id` BIGINT COMMENT 'Foreign key linking to agreement.contract_amendment. Business justification: contract_obligation currently stores amendment_number as a STRING denormalized reference.',
    `linked_milestone_agreement_billing_milestone_id` BIGINT COMMENT 'Reference to the associated billing milestone in the finance domain when this obligation is tied to a payment trigger (e.g., obligation fulfillment unlocks a billing milestone in the source system',
    `regulatory_action_item_id` BIGINT COMMENT 'Foreign key linking to regulatory.regulatory_action_item. Business justification: Regulatory inspection findings and agency action items frequently generate contractual obligations on the CRO (e.g., CAPA implementation, data resubmission).',
    `regulatory_commitment_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_commitment. Business justification: Regulatory commitments made to health authorities (post-inspection) are operationalized as contract obligations.',
    `responsible_owner_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Contract obligations are assigned to specific employees for fulfillment. This FK enables obligation ownership tracking, overdue obligation reporting by employee, escalation workflows, and',
    `scope_of_work_id` BIGINT COMMENT 'Reference to the specific scope of work document from which this obligation originates, enabling traceability to the governing SOW version.',
    `study_contract_id` BIGINT COMMENT 'Reference to the parent contract, master service agreement (MSA), statement of work (SOW), or subcontract from which this obligation is extracted.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `study_protocol_milestone_id` BIGINT COMMENT 'Foreign key linking to study.study_milestone. Business justification: Contract obligations (regulatory submission deadlines, safety reporting requirements, enrollment commitments) are fulfilled upon specific study milestone achievements.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Contract obligations require evidence documents filed in the eTMF (e.g., audit reports, regulatory notifications, training records).',
    `comments` STRING COMMENT 'Free-text field for additional context, notes, or clarifications related to this obligation, such as waiver rationale, extension justification, or sponsor communication summaries.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this obligation record was first created in the system, in ISO 8601 format with timezone offset. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+.',
    `ctms_obligation_reference` STRING COMMENT 'Cross-reference identifier for this obligation record in the source system enabling bidirectional traceability between the lakehouse silver layer and the operational CTMS system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code applicable to any monetary values associated with this obligation (e.g., USD, EUR, GBP, JPY).. Valid values are `^[A-Z]{3}$`',
    `dispute_description` STRING COMMENT 'Narrative description of the nature of the contractual dispute associated with this obligation, including the contested position of each party. Populated only when is_dispute_item is true. Confidential legal information.',
    `dispute_resolution_date` DATE COMMENT 'The date on which the contractual dispute related to this obligation was formally resolved. Null if the dispute is ongoing.',
    `due_date` DATE COMMENT 'The contractually agreed date by which this obligation must be fulfilled. Used as the primary trigger for overdue escalation and SLA breach calculations.',
    `effective_date` DATE COMMENT 'The date from which this obligation becomes binding and active, typically aligned with the contract execution date or a specific milestone trigger date.',
    `escalation_date` DATE COMMENT 'The date on which the escalation was triggered for this obligation. Null if no escalation has occurred.',
    `escalation_status` STRING COMMENT 'Current state of the escalation workflow for this obligation: not_triggered (no escalation active), triggered (escalation notification sent), acknowledged (escalation received and acknowledged), or resolved (escalation closed).. Valid values are `not_triggered|triggered|acknowledged|resolved`',
    `escalation_trigger` STRING COMMENT 'Defined condition or threshold that triggers an escalation notification (e.g., 5 business days before due date, overdue by 48 hours, penalty threshold reached). Used by automated monitoring workflows.',
    `evidence_description` STRING COMMENT 'Narrative description of the evidence provided to demonstrate fulfillment of this obligation (e.g., SAE report submitted via Argus Safety on 2024-03-15, CSR delivered and accepted by sponsor, Invoice paid per the source system',
    `fulfillment_date` DATE COMMENT 'The actual date on which the obligation was fulfilled and accepted by the receiving party. Null if not yet fulfilled.',
    `fulfillment_status` STRING COMMENT 'Current lifecycle state of the obligation: pending (not yet started), in_progress (actively being worked), fulfilled (completed and evidenced), overdue (past due date without fulfillment), waived (formally waived by mutual agreement), disputed (contested',
    `is_dispute_item` BOOLEAN COMMENT 'Indicates whether this obligation is currently subject to a formal contractual dispute between the sponsor and CRO. When true, the obligation is tracked as a dispute item requiring legal or governance review.',
    `is_regulatory_required` BOOLEAN COMMENT 'Indicates whether this obligation is mandated by a regulatory authority (FDA, EMA, ICH, MHRA, PMDA, etc.) as opposed to being a purely commercial or operational commitment. Regulatory obligations carry heightened compliance risk.',
    `obligation_description` STRING COMMENT 'Full narrative description of the contractual obligation as extracted or paraphrased from the source contract, MSA, SOW, or amendment, including specific deliverable criteria and acceptance conditions.',
    `obligation_number` STRING COMMENT 'Externally-known, human-readable unique reference number assigned to this obligation for cross-system tracking, audit, and dispute resolution purposes (e.g., OBL-MSA001-00042).. Valid values are `^OBL-[A-Z0-9]{3,10}-[0-9]{4,8}$`',
    `obligation_subtype` STRING COMMENT 'Granular sub-classification within the obligation type (e.g., SAE reporting, enrollment milestone, regulatory submission, invoice payment, SLA penalty, CAPA delivery).',
    `obligation_title` STRING COMMENT 'Short, human-readable title summarizing the obligation (e.g., Deliver Final Clinical Study Report, Submit SAE within 24 hours, Achieve 80% enrollment by Q3).',
    `obligation_type` STRING COMMENT 'High-level classification of the obligation: regulatory (e.g., IRB/IEC submissions, GCP compliance), financial (e.g., payment milestones, pass-through caps), operational (e.g., site activation timelines, enrollment targets), reporting (e.g., CSR delivery. Valid values are `regulatory|financial|operational|reporting|dispute`',
    `penalty_amount` DECIMAL(18,2) COMMENT 'Monetary value of the contractual penalty or liquidated damages applicable upon breach of this obligation. Expressed in the contract currency. Confidential commercial data.',
    `penalty_clause` STRING COMMENT 'Description of the contractual penalty, liquidated damages, or service credit that applies if this obligation is not fulfilled by the due date. Confidential commercial information.',
    `priority_level` STRING COMMENT 'Business-assigned priority of the obligation reflecting its regulatory, financial, or operational criticality. Critical obligations (e.g., SAE reporting, regulatory submissions) require immediate escalation if at risk.. Valid values are `critical|high|medium|low`',
    `recurrence_end_date` DATE COMMENT 'For recurring obligations, the date after which no further recurrence instances are generated. Null for one-time obligations or open-ended recurring obligations.',
    `recurrence_pattern` STRING COMMENT 'Indicates whether the obligation is a one-time commitment or a recurring obligation with a defined frequency (e.g., monthly safety reports, quarterly enrollment updates, annual GCP training confirmations).. Valid values are `one_time|daily|weekly|monthly|quarterly|annual`',
    `regulatory_authority` STRING COMMENT 'The specific regulatory body to which this obligation relates (e.g., FDA, EMA, MHRA, PMDA, TGA, Health Canada). Populated only when is_regulatory_required is true.',
    `responsible_party` STRING COMMENT 'The contractual party accountable for fulfilling this obligation: sponsor (pharmaceutical/biotech client), CRO (contract research organization), site (investigative site), subcontractor (third-party vendor), or joint (shared responsibility).. Valid values are `sponsor|cro|site|subcontractor|joint`',
    `review_date` DATE COMMENT 'The date on which the formal review of this obligations fulfillment was completed and accepted.',
    `review_required` BOOLEAN COMMENT 'Indicates whether this obligation requires a formal review or approval step before it can be marked as fulfilled (e.g., sponsor sign-off on CSR, IRB/IEC acknowledgment of protocol deviation).',
    `reviewer_name` STRING COMMENT 'Name of the individual or role responsible for reviewing and approving fulfillment of this obligation. Populated when review_required is true.',
    `sap_contract_reference` STRING COMMENT 'Cross-reference identifier linking this obligation to the corresponding contract line or obligation record in the source system financial reconciliation and procurement compliance.',
    `source_clause_reference` STRING COMMENT 'Specific section, article, clause, or exhibit number within the source contract document from which this obligation is extracted (e.g., Section 4.2.1, Exhibit B, Clause 7, Schedule 3). Enables rapid legal traceability.',
    `source_document_type` STRING COMMENT 'Type of the source contractual document from which this obligation was extracted: MSA (Master Service Agreement), SOW (Statement of Work), amendment, change order, subcontract, or SLA (Service Level Agreement).. Valid values are `msa|sow|amendment|change_order|subcontract|sla`',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this obligation record was last modified, in ISO 8601 format with timezone offset. Required for change audit trail under 21 CFR Part 11 and ALCOA+ principles.',
    `version_number` BIGINT COMMENT 'Sequential version number of this obligation record, incremented each time the obligation is formally modified (e.g., due date extension, scope change, penalty revision). Supports audit trail and change history.',
    CONSTRAINT pk_contract_obligation PRIMARY KEY(`contract_obligation_id`)
) COMMENT 'Specific contractual obligation or commitment extracted from a study contract, MSA, SOW, or subcontract that must be tracked for compliance. Captures obligation type (regulatory, financial, operational, reporting, dispute-related), obligation description';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` (
    `preferred_provider_agreement_id` BIGINT COMMENT 'Primary key for preferred_provider_agreement',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: PPAs are often negotiated for a specific clinical program portfolio (e.g., a dedicated oncology program PPA).',
    `compliance_obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: PPAs establish long-term CRO partnerships with embedded compliance obligations (audit_right_flag, sla_included_flag).',
    `cro_alliance_manager_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: The CRO alliance manager on a PPA is a named internal employee responsible for the strategic sponsor relationship.',
    `master_service_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.master_service_agreement. Business justification: A Preferred Provider Agreement is a framework agreement that is typically established in conjunction with or under a Master Service Agreement.',
    `parent_ppa_preferred_provider_agreement_id` BIGINT COMMENT 'Self-referencing identifier pointing to the original or parent PPA when this record represents an amendment or successor agreement. Null for original agreements. Enables amendment lineage tracking.',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: PPAs are scoped by therapeutic area (therapeutic_area_scope exists as a text field).',
    `agreement_status` STRING COMMENT 'Current lifecycle state of the Preferred Provider Agreement. Drives operational eligibility — only active agreements permit new study task orders to be issued under the PPA.',
    `agreement_type` STRING COMMENT 'Classification of the strategic agreement instrument. Distinguishes a Preferred Provider Agreement (PPA) from a Framework Agreement, Master Vendor Agreement, or Strategic Alliance Agreement governing the sponsor-CRO partnership.. Valid values are `preferred_provider_agreement|framework_agreement|master_vendor_agreement|strategic_alliance_agreement`',
    `amendment_number` BIGINT COMMENT 'Sequential amendment counter for this Preferred Provider Agreement. Zero (0) indicates the original executed agreement; each subsequent amendment increments this value. Supports version tracking and audit compliance.',
    `audit_right_flag` BOOLEAN COMMENT 'Indicates whether the sponsor retains the contractual right to audit the CROs facilities, systems, and records under this Preferred Provider Agreement. True = audit rights are explicitly granted per GCP requirements.',
    `confidentiality_term_years` BIGINT COMMENT 'Duration in years for which confidentiality obligations under this Preferred Provider Agreement remain in force after expiry or termination. Relevant for GDPR, HIPAA, and clinical data protection compliance.',
    `contract_currency` STRING COMMENT 'ISO 4217 three-letter currency code in which financial terms, rate cards, and volume commitments under this Preferred Provider Agreement are denominated (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `cro_legal_entity` STRING COMMENT 'Full legal name of the Contract Research Organization (CRO) or vendor that is the preferred provider under this agreement. Used for regulatory filings, audit trails, and financial reconciliation.',
    `ctms_ppa_reference` STRING COMMENT 'Reference identifier for this Preferred Provider Agreement in the source system Links the strategic agreement to study-level task orders and site monitoring activities managed within the CTMS.',
    `data_privacy_framework` STRING COMMENT 'Primary data privacy regulatory framework governing personal and clinical data handling obligations under this Preferred Provider Agreement (e.g., GDPR for EU studies, HIPAA for US studies).. Valid values are `GDPR|HIPAA|PIPEDA|PDPA|LGPD|combined`',
    `dispute_resolution_mechanism` STRING COMMENT 'Contractually agreed method for resolving disputes arising under the Preferred Provider Agreement. Determines the legal pathway if commercial or performance disagreements cannot be resolved bilaterally.. Valid values are `arbitration|mediation|litigation|expert_determination`',
    `effective_date` DATE COMMENT 'Calendar date on which the Preferred Provider Agreement becomes legally binding and commercially operative. Marks the start of the preferred partnership period.',
    `execution_date` DATE COMMENT 'Date on which all required parties formally signed the Preferred Provider Agreement, making it legally executed. May differ from the effective date when agreements are backdated or post-dated.',
    `expiry_date` DATE COMMENT 'Calendar date on which the Preferred Provider Agreement ceases to be operative unless renewed or extended. Null indicates an open-ended agreement with no fixed end date.',
    `force_majeure_clause` BOOLEAN COMMENT 'Indicates whether a force majeure clause is included in this Preferred Provider Agreement, excusing performance obligations in the event of extraordinary circumstances beyond either partys control.',
    `geographic_scope` STRING COMMENT 'Description of the geographic regions or countries covered by this Preferred Provider Agreement (e.g., North America, Europe, Global). Defines where the CRO is authorized to conduct services under the PPA terms.',
    `governance_committee_name` STRING COMMENT 'Name of the joint governance body (e.g., Joint Steering Committee, Alliance Management Committee) established under this PPA to oversee performance, resolve escalations, and manage the strategic partnership.',
    `governance_review_frequency` STRING COMMENT 'Contractually agreed frequency at which the joint governance committee convenes to review PPA performance, KPIs, and strategic alignment between sponsor and CRO.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `governing_law_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction whose laws govern interpretation and enforcement of this Preferred Provider Agreement (e.g., USA, GBR, DEU).. Valid values are `^[A-Z]{3}$`',
    `insurance_required_flag` BOOLEAN COMMENT 'Indicates whether the CRO is contractually required to maintain specified insurance coverage (e.g., professional indemnity, clinical trial insurance) as a condition of this Preferred Provider Agreement.',
    `ip_ownership` STRING COMMENT 'Defines which party owns intellectual property (including study data, methodologies, and innovations) generated under this Preferred Provider Agreement. Critical for regulatory submissions and commercialization rights.. Valid values are `sponsor|cro|joint|licensed_to_sponsor`',
    `liability_cap_amount` DECIMAL(18,2) COMMENT 'Maximum financial liability either party may incur under this Preferred Provider Agreement, expressed in the contract currency. Governs indemnification exposure and insurance requirements.',
    `payment_terms_days` BIGINT COMMENT 'Standard number of days from invoice receipt within which the sponsor must remit payment to the CRO under this Preferred Provider Agreement (e.g., Net 30, Net 45, Net 60).',
    `ppa_number` STRING COMMENT 'Externally-known, human-readable business identifier for the Preferred Provider Agreement, used in correspondence, the source system Veeva Vault document references. Follows the format PPA-{SPONSOR_CODE}-{YEAR}.. Valid values are `^PPA-[A-Z0-9]{4,10}-[0-9]{4}$`',
    `rate_card_reference` STRING COMMENT 'Reference identifier for the pre-negotiated rate card document associated with this Preferred Provider Agreement. Links to the Veeva Vault document or the source system containing unit rates for services delivered under the PPA.',
    `renewal_notice_days` BIGINT COMMENT 'Number of calendar days prior to expiry by which either party must provide written notice of intent not to renew the Preferred Provider Agreement. Relevant only when auto_renewal_flag is True.',
    `sap_contract_number` STRING COMMENT 'Contract identifier in the source system this Preferred Provider Agreement. Used for financial reconciliation, purchase order issuance, and accounts payable processing against the PPA.',
    `service_category_scope` STRING COMMENT 'Comma-separated list of CRO service categories covered under this PPA (e.g., Clinical Operations, Data Management, Biostatistics, Regulatory Affairs, Pharmacovigilance). Defines the functional scope of the preferred partnership.',
    `sla_document_reference` STRING COMMENT 'Reference identifier for the SLA schedule document in Veeva Vault or eTMF. Populated only when sla_included_flag is True. Links to the specific SLA exhibit defining KPI targets and remediation terms.',
    `sla_included_flag` BOOLEAN COMMENT 'Indicates whether a Service Level Agreement (SLA) schedule with defined KPIs and performance metrics is incorporated into this Preferred Provider Agreement. True = SLA schedule is attached and enforceable.',
    `sponsor_alliance_manager` STRING COMMENT 'Full name of the sponsor-side Alliance Manager or Relationship Manager responsible for overseeing the strategic partnership and governance of this Preferred Provider Agreement.',
    `sponsor_legal_entity` STRING COMMENT 'Full legal name of the pharmaceutical or biotech sponsor organization that is party to this Preferred Provider Agreement. Used for regulatory submissions, invoicing, and legal correspondence.',
    `subcontracting_permitted` BOOLEAN COMMENT 'Indicates whether the CRO is permitted to subcontract services to third-party vendors under this Preferred Provider Agreement. True = subcontracting is allowed, subject to sponsor notification or approval requirements.',
    `termination_date` DATE COMMENT 'Actual date on which this Preferred Provider Agreement was terminated, if applicable. Null for active or expired agreements. Populated when agreement_status transitions to terminated.',
    `termination_for_convenience_days` BIGINT COMMENT 'Number of calendar days of written notice required by either party to terminate this Preferred Provider Agreement for convenience (without cause). Governs wind-down planning for in-flight studies.',
    `termination_reason` STRING COMMENT 'Reason code for the termination of this Preferred Provider Agreement. Used for portfolio analytics, vendor performance tracking, and regulatory audit trails.. Valid values are `convenience|breach|mutual_agreement|regulatory_action|sponsor_insolvency|cro_performance`',
    `therapeutic_area_scope` STRING COMMENT 'Comma-separated list of therapeutic areas (e.g., Oncology, Neurology, Cardiovascular) covered under this Preferred Provider Agreement. Defines the portfolio of studies eligible to be placed under the PPA.',
    `veeva_vault_doc_number` STRING COMMENT 'Unique document identifier in Veeva Vault eTMF for the executed Preferred Provider Agreement and its amendments. Enables direct navigation to the source document for audit and regulatory inspection readiness.',
    `volume_commitment_amount` DECIMAL(18,2) COMMENT 'Minimum financial volume (in contract currency) the sponsor commits to place with the CRO over the PPA term. Triggers preferred pricing tiers and governs rebate or penalty clauses if thresholds are not met.',
    `volume_commitment_unit` STRING COMMENT 'Unit of measure for the volume commitment threshold (e.g., currency for financial commitment, study_count for number of studies, fte_hours for full-time equivalent hours). Determines how compliance with the volume commitment is tracked.. Valid values are `currency|study_count|fte_hours|subject_count`',
    CONSTRAINT pk_preferred_provider_agreement PRIMARY KEY(`preferred_provider_agreement_id`)
) COMMENT 'Preferred Provider Agreement (PPA) or Framework Agreement establishing pre-negotiated terms, rates, and service standards with a CRO or vendor for a portfolio of studies.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` (
    `confidentiality_agreement_id` BIGINT COMMENT 'Unique surrogate identifier for the Non-Disclosure Agreement (NDA) or Confidentiality Disclosure Agreement (CDA) record in the lakehouse silver layer.',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: CDAs are executed with lab facilities before study initiation to protect confidential compound and protocol information.',
    `master_service_agreement_id` BIGINT COMMENT 'Reference to the Master Service Agreement under which this NDA/CDA operates, if applicable. Links the confidentiality agreement to the broader commercial relationship framework between the CRO and sponsor.',
    `parent_agreement_confidentiality_agreement_id` BIGINT COMMENT 'Reference to the original NDA/CDA record that this amendment or superseding agreement is derived from. Enables version lineage tracking. Null for original agreements. Self-referencing within the confidentiality_agreement product.',
    `study_contract_id` BIGINT COMMENT 'Foreign key linking to agreement.study_contract. Business justification: A Confidentiality Agreement (NDA/CDA) is often executed in the context of a specific study or study contract, not just at the MSA level.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: CDAs/NDAs are TMF Zone 1 essential documents required before study initiation. This FK enables TMF completeness checks to verify confidentiality agreements are filed.',
    `agreement_number` STRING COMMENT 'Externally-known business identifier for the NDA/CDA, typically assigned by the CRO legal department or sourced from Veeva Vault document numbering (e.g., NDA-2024-00123).',
    `agreement_status` STRING COMMENT 'Current lifecycle state of the NDA/CDA. Tracks progression from draft through execution to expiry or termination. Only agreements in executed status permit sharing of proprietary compound or protocol information with the counterparty.. Valid values are `draft|pending_execution|executed|expired|terminated|superseded`',
    `agreement_type` STRING COMMENT 'Classifies the directionality of confidentiality obligations: unilateral (one party discloses to another), bilateral (mutual NDA between two parties), or multilateral (three or more parties). Determines which parties bear disclosure restrictions.. Valid values are `unilateral|bilateral|multilateral`',
    `amendment_number` BIGINT COMMENT 'Sequential amendment number indicating how many times this NDA/CDA has been formally amended. Zero for the original agreement. Incremented with each executed amendment that modifies scope, term, or parties.',
    `breach_notification_days` BIGINT COMMENT 'Number of calendar days within which a party must notify the other of a suspected or confirmed confidentiality breach. Aligns with GDPR 72-hour breach notification requirements and contractual obligations. Drives compliance monitoring workflows.',
    `confidentiality_term_years` BIGINT COMMENT 'Duration in years for which confidentiality obligations survive after the agreement expires or terminates. Commonly 2–10 years in clinical research. Drives data retention and destruction scheduling per GDPR and HIPAA requirements.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this NDA/CDA record was first created in the lakehouse silver layer. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles (Attributable, Legible, Contemporaneous, Original, Accurate).',
    `cro_legal_entity` STRING COMMENT 'Full legal name of the CRO entity executing this NDA/CDA. Relevant when the CRO operates through multiple legal subsidiaries across jurisdictions. Must match the entity name on the executed document in Veeva Vault.',
    `cro_signatory_name` STRING COMMENT 'Full name of the authorized CRO representative who executed this NDA/CDA on behalf of the CRO legal entity. Captured from Veeva Vault eSignature records for legal audit trail and 21 CFR Part 11 compliance.',
    `ctms_agreement_reference` STRING COMMENT 'Cross-reference identifier for this NDA/CDA in the source system Enables traceability between the legal agreement record and the operational study management context in the CTMS.',
    `data_privacy_framework` STRING COMMENT 'Primary data privacy regulatory framework applicable to personal data covered by this NDA/CDA. Determines data handling, retention, and breach notification obligations. Sourced from the agreements jurisdiction and sponsor requirements.. Valid values are `GDPR|HIPAA|PIPEDA|PDPA|LGPD|other`',
    `data_return_destruction_clause` BOOLEAN COMMENT 'Indicates whether this NDA/CDA includes a clause requiring the receiving party to return or destroy confidential information upon termination or expiry. When True, triggers data destruction workflows aligned with GDPR Article 17 and HIPAA requirements.',
    `disclosing_party` STRING COMMENT 'Identifies which party is the primary discloser of confidential information under this agreement. For unilateral NDAs, this is typically the sponsor sharing compound or protocol data. For bilateral agreements, both parties disclose.. Valid values are `sponsor|cro|both|third_party`',
    `dispute_resolution_mechanism` STRING COMMENT 'Method agreed upon for resolving disputes arising from this NDA/CDA. Determines the legal pathway if a breach or disagreement occurs between the CRO and sponsor.. Valid values are `litigation|arbitration|mediation|expert_determination`',
    `effective_date` DATE COMMENT 'Calendar date on which the NDA/CDA becomes legally binding and confidentiality obligations commence. No proprietary compound or protocol information may be shared prior to this date.',
    `esignature_flag` BOOLEAN COMMENT 'Indicates whether this NDA/CDA was executed using electronic signatures compliant with 21 CFR Part 11 and/or eIDAS regulations. When True, the executed document is stored in Veeva Vault with a validated eSignature audit trail.',
    `execution_date` DATE COMMENT 'Calendar date on which all required parties signed and the NDA/CDA was fully executed. May differ from effective_date when agreements are backdated or have a future effective date. Captured from Veeva Vault eSignature records.',
    `expiry_date` DATE COMMENT 'Calendar date on which the NDA/CDA confidentiality obligations formally expire. Nullable for perpetual agreements. Triggers automated renewal or renegotiation workflows in the CTMS and Veeva Vault.',
    `governing_law_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction whose laws govern interpretation and enforcement of this NDA/CDA (e.g., USA, GBR, DEU). Determines applicable data privacy regulations and dispute resolution frameworks.. Valid values are `^[A-Z]{3}$`',
    `governing_law_state` STRING COMMENT 'State or province within the governing law country for sub-national jurisdiction specification (e.g., Delaware, New York, California). Relevant for U.S.-based agreements where state contract law applies.',
    `inspection_ready_flag` BOOLEAN COMMENT 'Indicates whether this NDA/CDA record and its associated executed document in Veeva Vault are confirmed as inspection-ready for regulatory authority review (FDA, EMA, MHRA). Set to True after QA review confirms completeness and accessibility.',
    `ip_ownership_clause` BOOLEAN COMMENT 'Indicates whether this NDA/CDA includes provisions addressing intellectual property ownership of any inventions or discoveries arising from the exchange of confidential information. When True, IP ownership terms are defined within the agreement.',
    `notes` STRING COMMENT 'Free-text field for capturing additional context, legal team annotations, negotiation history notes, or special conditions not captured in structured fields. Intended for internal legal and contract management use only.',
    `permitted_disclosures` STRING COMMENT 'Narrative description of circumstances under which confidential information may be disclosed without breach, such as disclosure to regulatory authorities (FDA, EMA), IRB/IEC, or as required by law. Critical for regulatory submission planning.',
    `receiving_party` STRING COMMENT 'Identifies which party receives and is bound to protect confidential information under this agreement. For unilateral NDAs, this is typically the CRO receiving proprietary compound or protocol data from the sponsor.. Valid values are `sponsor|cro|both|third_party`',
    `renewal_notice_days` BIGINT COMMENT 'Number of calendar days prior to expiry_date by which a party must provide written notice to prevent auto-renewal. Applicable only when auto_renewal_flag is True. Drives automated reminder workflows.',
    `residual_knowledge_clause` BOOLEAN COMMENT 'Indicates whether this NDA/CDA includes a residual knowledge clause permitting the receiving party to use information retained in unaided memory after return or destruction of confidential materials.',
    `sap_contract_reference` STRING COMMENT 'Contract number or document reference in the source system this NDA/CDA to the financial and procurement records associated with the sponsor engagement. Supports SOX financial reporting controls.',
    `scope_of_confidential_info` STRING COMMENT 'Narrative description of the categories of confidential information covered by this NDA/CDA, such as investigational compound data, clinical protocol, patient data, financial terms, or regulatory strategy. Defines the boundaries of protection.',
    `sponsor_legal_entity` STRING COMMENT 'Full legal name of the pharmaceutical or biotech sponsor organization that is a party to this NDA/CDA. Used for legal correspondence, regulatory submissions, and contract management. Sourced from Veeva Vault counterparty records.',
    `sponsor_signatory_name` STRING COMMENT 'Full name of the authorized representative of the sponsor organization who executed this NDA/CDA. Captured from Veeva Vault eSignature records for legal audit trail and 21 CFR Part 11 compliance.',
    `study_phase` STRING COMMENT 'Clinical development phase of the study or program for which this NDA/CDA is executed. Provides context for the sensitivity and regulatory significance of the confidential information being protected.. Valid values are `pre_clinical|phase_1|phase_2|phase_3|phase_4|not_applicable`',
    `termination_date` DATE COMMENT 'Calendar date on which the NDA/CDA was terminated prior to its scheduled expiry_date. Populated only when agreement_status is terminated. Triggers data destruction or return obligations per the agreement terms.',
    `termination_reason` STRING COMMENT 'Reason for early termination of the NDA/CDA prior to its scheduled expiry. Captured for legal audit trail and regulatory compliance. Populated only when agreement_status is terminated.. Valid values are `mutual_agreement|breach|convenience|superseded|study_cancelled`',
    `third_party_name` STRING COMMENT 'Name of any additional party (e.g., academic institution, sub-CRO, laboratory partner) included in a multilateral NDA/CDA. Populated only when agreement_type is multilateral. Nullable for unilateral and bilateral agreements.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this NDA/CDA record in the lakehouse silver layer. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `veeva_vault_doc_number` STRING COMMENT 'Unique document identifier assigned by Veeva Vault eTMF to the executed NDA/CDA document. Enables direct retrieval of the source document for audit, inspection readiness, and regulatory submission purposes.',
    CONSTRAINT pk_confidentiality_agreement PRIMARY KEY(`confidentiality_agreement_id`)
) COMMENT 'Non-Disclosure Agreement (NDA) or Confidentiality Disclosure Agreement (CDA) executed between the CRO and a sponsor or partner prior to or alongside a study contract.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`agreement`.`subcontract` (
    `subcontract_id` BIGINT COMMENT 'Unique system-generated identifier for the subcontract or sub-CRO agreement record.',
    `audit_id` BIGINT COMMENT 'Foreign key linking to compliance.audit. Business justification: Subcontractor qualification and performance audits (audit_right_flag on subcontract) must reference the specific subcontract being audited.',
    `compliance_obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: Subcontracts must flow down specific regulatory compliance obligations to subcontractors (ICH E6 R2 requirement).',
    `contract_manager_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Subcontract managers are internal employees responsible for vendor oversight and GCP flow-down compliance.',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: When a CRO subcontracts central lab work, the subcontract governs the specific lab facilitys engagement.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor whose study is covered by this subcontract, required for sponsor approval tracking and oversight.',
    `scope_of_work_id` BIGINT COMMENT 'Foreign key linking to agreement.scope_of_work. Business justification: A subcontract delegates specific services defined in a Scope of Work to a third-party vendor or sub-CRO.',
    `study_contract_id` BIGINT COMMENT 'Reference to the primary study contract between the sponsor and CRO from which this subcontract flows down obligations and scope.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which the subcontracted services are being performed.',
    `amendment_date` DATE COMMENT 'Date on which the most recent amendment to the subcontract was executed.',
    `amendment_number` BIGINT COMMENT 'Sequential number of the most recent amendment to this subcontract. Zero indicates the original executed version with no amendments.',
    `audit_right_flag` BOOLEAN COMMENT 'Indicates whether the CRO and/or sponsor retain the right to audit the subcontractors facilities, records, and processes as stipulated in the subcontract.',
    `confidentiality_term_years` BIGINT COMMENT 'Duration in years for which confidentiality obligations under the subcontract remain in force after termination or expiry.',
    `contract_status` STRING COMMENT 'Current lifecycle state of the subcontract, tracking progression from draft through execution to termination or expiry. [ENUM-REF-CANDIDATE: draft|pending_approval|active|suspended|terminated|expired|superseded — 7 candidates stripped; promote to',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this subcontract record was first created in the system, supporting audit trail requirements under ALCOA+ and 21 CFR Part 11.',
    `ctms_subcontract_reference` STRING COMMENT 'Reference identifier for this subcontract in the source system enabling cross-system traceability for vendor oversight and site management activities.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the subcontract value and payments are denominated (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `data_privacy_framework` STRING COMMENT 'Applicable data privacy regulatory framework governing the handling of personal and patient data by the subcontractor under this agreement.. Valid values are `GDPR|HIPAA|PIPEDA|PDPA|none|multiple`',
    `effective_end_date` DATE COMMENT 'Date on which the subcontract expires or services are contractually scheduled to conclude. Nullable for open-ended agreements.',
    `effective_start_date` DATE COMMENT 'Date on which the subcontract becomes legally binding and the subcontractor is authorized to commence delegated services.',
    `execution_date` DATE COMMENT 'Date on which the subcontract was fully executed (signed by all parties), representing the principal business event timestamp for this agreement.',
    `flow_down_obligations` STRING COMMENT 'Description of the contractual obligations from the primary sponsor-CRO contract that are flowed down to the subcontractor, including GCP compliance, audit rights, confidentiality, and regulatory requirements.',
    `gcp_compliance_required` BOOLEAN COMMENT 'Indicates whether the subcontractor is required to operate in compliance with ICH E6(R2) Good Clinical Practice guidelines as a flow-down obligation from the primary contract.',
    `geographic_scope` STRING COMMENT 'Description of the countries or regions in which the subcontractor is authorized to perform services under this subcontract.',
    `governing_law_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction whose laws govern the interpretation and enforcement of this subcontract.. Valid values are `^[A-Z]{3}$`',
    `insurance_required_flag` BOOLEAN COMMENT 'Indicates whether the subcontractor is contractually required to maintain specified insurance coverage (e.g., professional indemnity, clinical trial liability) as a condition of this subcontract.',
    `liability_cap_amount` DECIMAL(18,2) COMMENT 'Maximum monetary liability of the subcontractor under this subcontract as agreed in the indemnification and limitation of liability clauses.',
    `number` STRING COMMENT 'Externally-known alphanumeric identifier assigned to the subcontract, used for cross-referencing with the CROs contract management system and the source system records.',
    `pass_through_amount` DECIMAL(18,2) COMMENT 'Portion of the subcontract value representing pass-through costs (e.g., investigator fees, travel, lab kits) that are reimbursed at cost without CRO markup.',
    `payment_model` STRING COMMENT 'Billing and payment structure agreed with the subcontractor, determining how invoices are generated and approved.. Valid values are `milestone|time_and_materials|fixed_fee|per_unit|cost_plus`',
    `payment_terms_days` BIGINT COMMENT 'Number of days from invoice receipt within which payment to the subcontractor is due, as stipulated in the subcontract.',
    `performance_bond_required` BOOLEAN COMMENT 'Indicates whether the subcontractor is required to provide a performance bond or financial guarantee as a condition of the subcontract.',
    `qualification_expiry_date` DATE COMMENT 'Date on which the subcontractors vendor qualification certification expires, triggering re-qualification activities to maintain GCP compliance.',
    `sap_po_number` STRING COMMENT 'Purchase Order number in the source system to this subcontract, used for financial commitment tracking, invoice matching, and procurement compliance.',
    `service_fee_amount` DECIMAL(18,2) COMMENT 'Portion of the subcontract value representing the subcontractors professional service fees, distinct from pass-through reimbursements.',
    `sla_included_flag` BOOLEAN COMMENT 'Indicates whether the subcontract includes defined Service Level Agreements (SLAs) with measurable performance targets and associated penalties or remedies.',
    `sponsor_approval_date` DATE COMMENT 'Date on which the sponsor formally approved this subcontract, required for GCP compliance documentation.',
    `sponsor_approval_status` STRING COMMENT 'Status of the sponsors review and approval of this subcontract, required under GCP where the primary contract mandates sponsor consent for subcontracting arrangements.. Valid values are `not_required|pending|approved|rejected|conditionally_approved`',
    `subcontracted_services_description` STRING COMMENT 'Narrative description of the specific services delegated to the subcontractor, including scope boundaries, deliverables, and any service-level commitments.',
    `subcontractor_contact_name` STRING COMMENT 'Name of the primary contact person at the subcontractor organization responsible for contract execution and service delivery.',
    `subcontractor_qualification_status` STRING COMMENT 'Current qualification status of the subcontractor in the CROs vendor qualification program, confirming GCP compliance and capability assessment prior to engagement.. Valid values are `qualified|pending_qualification|disqualified|under_review`',
    `termination_date` DATE COMMENT 'Date on which the subcontract was terminated early, if applicable. Null if the contract ran to its natural expiry.',
    `termination_reason` STRING COMMENT 'Narrative explanation for early termination of the subcontract, such as performance failure, study cancellation, or mutual agreement.',
    `subcontract_type` STRING COMMENT 'Classification of the subcontract by the category of services being delegated. Common types include laboratory services (central lab), imaging (radiology), eCOA (electronic Clinical Outcome Assessment), translation, and monitoring.. Valid values are `laboratory_services|imaging|eCOA|translation|monitoring|other`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this subcontract record was last modified, supporting audit trail and data lineage requirements under ALCOA+ and 21 CFR Part 11.',
    `value` DECIMAL(18,2) COMMENT 'Total contracted monetary value of the subcontract representing the gross base amount committed to the subcontractor for all delegated services.',
    `veeva_vault_doc_number` STRING COMMENT 'Reference identifier for the executed subcontract document stored in Veeva Vault eTMF, enabling direct retrieval of the source document for audit and inspection readiness.',
    CONSTRAINT pk_subcontract PRIMARY KEY(`subcontract_id`)
) COMMENT 'Subcontract or sub-CRO agreement executed by the CRO with a third-party vendor or sub-CRO to delegate specific services defined in the primary study contract.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`agreement`.`rate_card` (
    `rate_card_id` BIGINT COMMENT 'Unique system-generated identifier for the rate card record. Primary key for the rate_card data product within the agreement domain.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Rate card approvals by named employees are required for financial governance and delegation-of-authority compliance.',
    `job_profile_id` BIGINT COMMENT 'Foreign key linking to workforce.job_profile. Business justification: Rate cards in clinical trials are structured around job profiles (CRA Level II, Data Manager, etc.).',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: Rate cards specify pricing for lab services at specific facilities (unit rates vary by facility capability and location).',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_panel. Business justification: Rate cards price lab services at the panel level (per panel per specimen). Finance teams validate central lab invoices by matching billed panel codes to contracted rate card line items.',
    `master_service_agreement_id` BIGINT COMMENT 'Reference to the Master Service Agreement (MSA) or Preferred Provider Agreement (PPA) to which this rate card is attached. Establishes the governing commercial relationship under which these rates apply.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor entity for whom this rate card is applicable. Enables sponsor-specific pricing differentiation across preferred provider agreements.',
    `preferred_provider_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.preferred_provider_agreement. Business justification: A Preferred Provider Agreement (PPA) establishes pre-negotiated terms and rates. Rate cards are the operational expression of those pre-negotiated rates.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: Rate cards are explicitly scoped by therapeutic area (different TA expertise commands different rates).',
    `amendment_number` STRING COMMENT 'Reference number of the MSA or PPA amendment that introduced or modified this rate card version. Links the rate card to the formal contract amendment document stored in Veeva Vault eTMF. Null if the rate card was established in the original agreement.',
    `approval_status` STRING COMMENT 'Internal approval workflow status of the rate card. pending indicates awaiting sponsor or internal approval; approved indicates formally accepted by both parties; rejected indicates declined; under_review indicates in active negotiation or legal. Valid values are `pending|approved|rejected|under_review`',
    `approved_date` DATE COMMENT 'Date on which the rate card received final approval from both the CRO and sponsor. Marks the transition from negotiation to binding commercial reference. Required for SOX audit trail and contract management compliance.',
    `billing_milestone_flag` BOOLEAN COMMENT 'Indicates whether this rate card line is associated with a milestone-based billing event (True) rather than a time-and-materials or unit-based billing model (False). Supports milestone payment schedule construction in SOW and study contract workflows.',
    `change_order_applicable_flag` BOOLEAN COMMENT 'Indicates whether this rate card line can be used for change order valuation (True). Some rate card lines may be restricted to initial SOW pricing only and not applicable for out-of-scope change order pricing.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for country-specific rate applicability. Used when a rate card line is scoped to a single country rather than a broader region. Null if the rate applies regionally or globally.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this rate card record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 electronic records, ALCOA+ data integrity principles, and SOX financial controls.',
    `ctms_rate_reference` STRING COMMENT 'Reference identifier for this rate card entry in the source system used for SOW budget construction and site payment planning. Enables cross-system reconciliation between contract rates and operational trial management.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the unit rate is denominated (e.g., USD, EUR, GBP, JPY). Supports multi-currency rate cards for global clinical trials across FDA, EMA, PMDA, and other regulatory jurisdictions.. Valid values are `^[A-Z]{3}$`',
    `effective_date` DATE COMMENT 'The date from which this rate card becomes binding and applicable for SOW pricing and change order valuation. Marks the start of the rate cards validity period under the governing MSA or PPA.',
    `escalation_basis` STRING COMMENT 'The basis on which annual rate escalation is calculated: fixed (predetermined fixed percentage), cpi_linked (tied to Consumer Price Index), negotiated (subject to annual renegotiation), none (no escalation applies for the rate card term).. Valid values are `fixed|cpi_linked|negotiated|none`',
    `escalation_rate_pct` DECIMAL(5,2) COMMENT 'Annual rate escalation percentage applied to the unit rate at each contract year anniversary (e.g., CPI-linked or fixed escalation). Expressed as a percentage (e.g., 3.00 = 3%). Governs automatic rate adjustments over multi-year MSA terms.',
    `expiry_date` DATE COMMENT 'The date on which this rate card ceases to be applicable. Nullable for open-ended rate cards. After this date, a new or superseding rate card version must be referenced for new SOW pricing. Triggers rate card renewal workflows.',
    `geographic_region` STRING COMMENT 'Geographic region or country scope for which this rate applies (e.g., North America, Western Europe, Asia-Pacific, or specific ISO 3166-1 alpha-3 country codes). Reflects regional labor cost differentials and regulatory environment complexity.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this rate card record. Required for ALCOA+ data integrity compliance, 21 CFR Part 11 audit trail, and SOX change management controls. Enables detection of unauthorized rate modifications.',
    `markup_pct` DECIMAL(5,2) COMMENT 'CRO margin markup percentage applied to pass-through costs before billing to the sponsor. Expressed as a percentage (e.g., 10.00 = 10%). Applicable only when pass_through_flag is True. Governs pass-through billing in sponsor invoices.',
    `maximum_units` DECIMAL(18,4) COMMENT 'Maximum number of units covered at this rate before a volume tier escalation or renegotiation is triggered. Supports tiered pricing structures in MSAs and PPAs. Null if no maximum cap applies.',
    `minimum_units` DECIMAL(18,4) COMMENT 'Minimum number of units that must be purchased or committed to for this rate to apply. Supports volume commitment structures in preferred provider agreements. Null if no minimum commitment is required.',
    `rate_card_name` STRING COMMENT 'Human-readable descriptive name for the rate card (e.g., Oncology Phase III Global Rate Card FY2024). Used for identification in CTMS, the source system, and contract management workflows.',
    `notes` STRING COMMENT 'Free-text field for capturing negotiation context, special conditions, exceptions, or assumptions associated with this rate card line (e.g., Rate applies only to Phase III oncology studies with >50 sites, Subject to annual CPI review in Q1).',
    `number` STRING COMMENT 'Externally-known unique business identifier for the rate card, used in SOW budget construction, change order valuation, and sponsor communications. Follows the CRO internal numbering convention (e.g., RC-SPONS2024-001).. Valid values are `^RC-[A-Z0-9]{4,20}$`',
    `pass_through_flag` BOOLEAN COMMENT 'Indicates whether this rate card line represents a pass-through cost (True) that is billed to the sponsor at cost without CRO margin, or a service fee (False) that includes CRO margin.',
    `sap_price_list_number` STRING COMMENT 'Reference identifier for the corresponding price list or condition record in the source system for automated invoice generation and revenue recognition. Ensures alignment between the contract rate card and the financial billing system.',
    `service_category` STRING COMMENT 'High-level CRO service category to which this rate applies (e.g., Clinical Monitoring, Data Management, Biostatistics, Regulatory Affairs, Medical Writing, Project Management, Pharmacovigilance, Laboratory Services).',
    `service_subcategory` STRING COMMENT 'Granular sub-classification of the CRO service within the service category (e.g., within Clinical Monitoring: Site Initiation Visit, Routine Monitoring Visit, Close-Out Visit; within Data Management: eCRF Design, Data Entry, Query Management).',
    `sow_applicable_flag` BOOLEAN COMMENT 'Indicates whether this rate card line is currently available for use in new Scope of Work (SOW) budget construction (True) or has been restricted from new SOW use (False).',
    `sponsor_approved_by` STRING COMMENT 'Name or identifier of the sponsors authorized representative who approved the rate card. Confirms bilateral acceptance of the pre-negotiated rates. Required for contract enforceability and SOX audit trail.',
    `rate_card_status` STRING COMMENT 'Current lifecycle status of the rate card. draft indicates under negotiation; active indicates currently in use for SOW pricing; superseded indicates replaced by a newer version; expired indicates past effective date range; withdrawn indicates. Valid values are `draft|active|superseded|expired|withdrawn`',
    `study_phase` STRING COMMENT 'Clinical development phase for which this rate applies. Rates often differ by phase due to complexity, site count, and monitoring intensity. Supports phase-specific SOW budget construction and change order valuation.. Valid values are `Phase I|Phase II|Phase III|Phase IV|Phase I/II|Phase II/III`',
    `rate_card_type` STRING COMMENT 'Classification of the rate card by its commercial scope. standard applies to general CRO service pricing; preferred_provider applies under a PPA; study_specific is negotiated for a single study; therapeutic_area is scoped to a disease area. Valid values are `standard|preferred_provider|study_specific|therapeutic_area|regional`',
    `unit_of_measure` STRING COMMENT 'The billing unit against which the unit rate is applied. Defines how the CRO service is quantified for invoicing: per_hour (time-and-materials), per_day (daily rate), per_visit (site monitoring visit), per_subject (enrolled patient), per_procedure',
    `unit_rate` DECIMAL(18,4) COMMENT 'Pre-negotiated price per unit of measure for this service/staff category combination. The principal quantitative fact of the rate card. Used as the pricing reference for SOW budget construction and change order valuation.',
    `veeva_vault_doc_number` STRING COMMENT 'Reference identifier for the rate card document stored in Veeva Vault eTMF or contract management module. Enables traceability between the structured rate card data and the executed contract document for regulatory inspection readiness.',
    `version_number` BIGINT COMMENT 'Sequential version number of the rate card, incremented with each renegotiation or amendment. Enables tracking of rate evolution over the life of the MSA and supports audit trail requirements under 21 CFR Part 11 and SOX.',
    `volume_discount_pct` DECIMAL(5,2) COMMENT 'Percentage discount applied to the unit rate when volume thresholds defined in the MSA or PPA are met. Expressed as a percentage (e.g., 5.00 = 5%). Supports tiered pricing and preferred provider incentive structures.',
    CONSTRAINT pk_rate_card PRIMARY KEY(`rate_card_id`)
) COMMENT 'Pre-negotiated rate card defining unit prices for specific CRO services, staff categories, and activities applicable to a sponsor relationship or preferred provider agreement.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`agreement`.`obligation_fulfillment` (
    `obligation_fulfillment_id` BIGINT COMMENT 'Primary key for the obligation_fulfillment association',
    `contract_obligation_id` BIGINT COMMENT 'Foreign key linking to the contractual obligation being fulfilled by the associated deliverable',
    `deliverable_id` BIGINT COMMENT 'Foreign key linking to the contractually committed deliverable that fulfills or partially fulfills the obligation',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — obligation fulfillment links obligation to deliverable but lacks study context',
    `evidence_document_reference` STRING COMMENT 'Reference identifier or URL to the document or artifact that serves as evidence of fulfillment for this specific deliverable-obligation pairing. Used in GCP audits and contract compliance reviews to demonstrate that the obligation was met.',
    `fulfillment_date` DATE COMMENT 'The date on which this deliverable was formally accepted as fulfilling this specific contractual obligation. Belongs to the association because the same deliverable may fulfill different obligations on different dates depending on sponsor review timelines.',
    `fulfillment_percentage` DECIMAL(18,2) COMMENT 'Numeric percentage (0–100) indicating the degree to which this deliverable satisfies the associated obligation. Supports partial fulfillment scenarios where an obligation requires multiple deliverables collectively, each contributing a portion of the',
    `fulfillment_status` STRING COMMENT 'Current lifecycle state of this specific deliverable-to-obligation fulfillment link. Tracks whether the deliverable has been accepted as satisfying this obligation, is pending review, or has been rejected as insufficient evidence of fulfillment.',
    CONSTRAINT pk_obligation_fulfillment PRIMARY KEY(`obligation_fulfillment_id`)
) COMMENT 'This association product represents the fulfillment event between a contractual deliverable and a contract obligation. It captures the operational record of how and to what degree a specific deliverable satisfies a specific contractual obligation, serving';

ALTER SCHEMA `clinical_trials_ecm`.`agreement` SET TAGS ('dbx_division' = 'business');

ALTER SCHEMA `clinical_trials_ecm`.`agreement` SET TAGS ('dbx_domain' = 'agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ADD CONSTRAINT `fk_agreement_master_service_agreement_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ADD CONSTRAINT `fk_agreement_master_service_agreement_parent_msa_master_service_agreement_id` FOREIGN KEY (`parent_msa_master_service_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`master_service_agreement`(`master_service_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ADD CONSTRAINT `fk_agreement_master_service_agreement_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` SET TAGS ('dbx_domain' = 'agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` SET TAGS ('dbx_subdomain' = 'contract_management');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `master_service_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Service Agreement (MSA) ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `parent_msa_master_service_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Master Service Agreement (MSA) ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'MSA|NDA|CDA|SOW|AMENDMENT|CHANGE_ORDER');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `confidentiality_term_years` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Term (Years)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `contract_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `cro_legal_entity` SET TAGS ('dbx_business_glossary_term' = 'Contract Research Organization (CRO) Legal Entity Name');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `cro_legal_entity` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `data_privacy_framework` SET TAGS ('dbx_value_regex' = 'GDPR|HIPAA|PIPEDA|APPI|COMBINED|NOT_APPLICABLE');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_value_regex' = 'ARBITRATION|LITIGATION|MEDIATION|EXPERT_DETERMINATION');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `effective_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `effective_date` SET TAGS ('dbx_pii_date' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `executed_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `executed_date` SET TAGS ('dbx_pii_date' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `expiry_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `expiry_date` SET TAGS ('dbx_pii_date' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `force_majeure_clause` SET TAGS ('dbx_business_glossary_term' = 'Force Majeure Clause Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `governing_law_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `governing_law_state` SET TAGS ('dbx_business_glossary_term' = 'Governing Law State or Province');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `indemnification_scope` SET TAGS ('dbx_value_regex' = 'MUTUAL|SPONSOR_INDEMNIFIES_CRO|CRO_INDEMNIFIES_SPONSOR|LIMITED');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `indemnification_scope` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `insurance_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Insurance Requirement Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `ip_ownership` SET TAGS ('dbx_business_glossary_term' = 'Intellectual Property (IP) Ownership');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `ip_ownership` SET TAGS ('dbx_value_regex' = 'SPONSOR|CRO|JOINT|BACKGROUND_RETAINED');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `ip_ownership` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `liability_cap_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `msa_number` SET TAGS ('dbx_business_glossary_term' = 'Master Service Agreement (MSA) Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `msa_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `payment_schedule_type` SET TAGS ('dbx_value_regex' = 'MILESTONE|MONTHLY|QUARTERLY|ANNUAL|UPON_DELIVERY');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `payment_terms_days` SET TAGS ('dbx_business_glossary_term' = 'Payment Terms (Days)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `payment_terms_days` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `renewal_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Renewal Notice Period (Days)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `sap_contract_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Contract ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `sla_included_flag` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Included Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `sponsor_legal_entity` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Legal Entity Name');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `sponsor_legal_entity` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `subcontracting_permitted` SET TAGS ('dbx_business_glossary_term' = 'Subcontracting Permitted Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `termination_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `termination_date` SET TAGS ('dbx_pii_date' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `termination_for_convenience_days` SET TAGS ('dbx_business_glossary_term' = 'Termination for Convenience Notice Period (Days)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'FOR_CAUSE|FOR_CONVENIENCE|MUTUAL_AGREEMENT|REGULATORY_REQUIREMENT|SPONSOR_INSOLVENCY');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `termination_reason` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `total_contract_value` SET TAGS ('dbx_business_glossary_term' = 'Total Contract Value (TCV)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `total_contract_value` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`master_service_agreement` ALTER COLUMN `veeva_vault_doc_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ADD CONSTRAINT `fk_agreement_study_contract_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ADD CONSTRAINT `fk_agreement_study_contract_contract_manager_employee_id` FOREIGN KEY (`contract_manager_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ADD CONSTRAINT `fk_agreement_study_contract_master_service_agreement_id` FOREIGN KEY (`master_service_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`master_service_agreement`(`master_service_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ADD CONSTRAINT `fk_agreement_study_contract_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ADD CONSTRAINT `fk_agreement_study_contract_preferred_provider_agreement_id` FOREIGN KEY (`preferred_provider_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement`(`preferred_provider_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ADD CONSTRAINT `fk_agreement_study_contract_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ADD CONSTRAINT `fk_agreement_study_contract_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` SET TAGS ('dbx_domain' = 'agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` SET TAGS ('dbx_subdomain' = 'contract_management');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `contract_manager_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Contract Manager Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `contract_manager_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `contract_manager_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `master_service_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Service Agreement (MSA) ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `preferred_provider_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Preferred Provider Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `billing_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|milestone|annual|upon_completion');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `billing_frequency` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `change_order_count` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `confidentiality_term_years` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Term (Years)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `confidentiality_term_years` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `contract_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `contract_status` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `contract_title` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `contract_type` SET TAGS ('dbx_value_regex' = 'full_service|functional_service|co_development|pass_through_only|letter_of_intent');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `contract_type` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `contract_version` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Contract Currency Code');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `currency_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `current_contracted_value` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Effective End Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_pii_date' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Effective Start Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_pii_date' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `execution_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Execution Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `execution_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `execution_date` SET TAGS ('dbx_pii_date' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `governing_law_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `governing_law_country` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `indemnification_cap` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `ip_ownership` SET TAGS ('dbx_business_glossary_term' = 'Intellectual Property (IP) Ownership');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `ip_ownership` SET TAGS ('dbx_value_regex' = 'sponsor|cro|joint|third_party');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `ip_ownership` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `key_open_issues` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `negotiation_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|on_hold|escalated|closed');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `negotiation_status` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `notice_period_days` SET TAGS ('dbx_business_glossary_term' = 'Notice Period (Days)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `notice_period_days` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `pass_through_budget` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Budget');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `pass_through_budget` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `payment_terms` SET TAGS ('dbx_value_regex' = 'net_30|net_45|net_60|net_90|milestone_based|advance_payment');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `payment_terms` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Phase');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase II|Phase III|Phase IV|Phase I/II|Phase II/III');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `renewal_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Renewal Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `renewal_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `renewal_date` SET TAGS ('dbx_pii_date' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `scope_of_work_version` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Version');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `scope_of_work_version` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `service_fee_budget` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `sla_penalty_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Penalty Clause Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `sla_penalty_clause_flag` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `sponsor_contract_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `target_execution_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `target_execution_date` SET TAGS ('dbx_pii_date' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Termination Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `termination_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `termination_date` SET TAGS ('dbx_pii_date' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Contract Termination Reason');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `termination_reason` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `total_contracted_value` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`study_contract` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ADD CONSTRAINT `fk_agreement_scope_of_work_cro_lead_employee_id` FOREIGN KEY (`cro_lead_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ADD CONSTRAINT `fk_agreement_scope_of_work_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ADD CONSTRAINT `fk_agreement_scope_of_work_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ADD CONSTRAINT `fk_agreement_scope_of_work_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ADD CONSTRAINT `fk_agreement_scope_of_work_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` SET TAGS ('dbx_domain' = 'agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` SET TAGS ('dbx_subdomain' = 'contract_management');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `scope_of_work_id` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `cro_lead_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Cro Lead Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `cro_lead_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `cro_lead_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Contract ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Amendment Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Approval Status');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|executed|superseded|terminated');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `billing_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `biostatistics_included` SET TAGS ('dbx_business_glossary_term' = 'Biostatistics Services Included Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Confidentiality Level');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `country_count` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Country Count');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `ctms_sow_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Scope of Work (SOW) Reference');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Contract Currency Code');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `data_management_included` SET TAGS ('dbx_business_glossary_term' = 'Data Management Services Included Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `data_management_included` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Effective Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `execution_date` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Execution Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Geographic Scope');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `governing_law` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Governing Law');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `is_current_version` SET TAGS ('dbx_business_glossary_term' = 'Is Current Version Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `key_assumptions` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Key Assumptions');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `monitoring_included` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Services Included Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `out_of_scope_items` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Out-of-Scope Items');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `pass_through_budget` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Budget');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `pass_through_budget` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `payment_model` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Payment Model');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `payment_model` SET TAGS ('dbx_value_regex' = 'milestone|time_and_materials|fixed_fee|unit_based|hybrid');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `pharmacovigilance_included` SET TAGS ('dbx_business_glossary_term' = 'Pharmacovigilance Services Included Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `regulatory_included` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Affairs Services Included Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `scope_description` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Scope Description');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `service_category_summary` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Service Category Summary');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `service_fee_budget` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `sow_number` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `sow_number` SET TAGS ('dbx_value_regex' = '^SOW-[A-Z0-9]{3,20}-[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `sow_title` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Title');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `sow_type` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Type');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `sow_type` SET TAGS ('dbx_value_regex' = 'full_service|functional_service|task_order|change_order|amendment');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `superseded_date` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Superseded Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `total_contract_value` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Total Contract Value');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `total_contract_value` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Version Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`scope_of_work` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ADD CONSTRAINT `fk_agreement_change_order_audit_finding_id` FOREIGN KEY (`audit_finding_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit_finding`(`audit_finding_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ADD CONSTRAINT `fk_agreement_change_order_initiated_by_employee_id` FOREIGN KEY (`initiated_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ADD CONSTRAINT `fk_agreement_change_order_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ADD CONSTRAINT `fk_agreement_change_order_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ADD CONSTRAINT `fk_agreement_change_order_scope_of_work_id` FOREIGN KEY (`scope_of_work_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`scope_of_work`(`scope_of_work_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ADD CONSTRAINT `fk_agreement_change_order_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ADD CONSTRAINT `fk_agreement_change_order_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ADD CONSTRAINT `fk_agreement_change_order_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ADD CONSTRAINT `fk_agreement_change_order_superseded_co_change_order_id` FOREIGN KEY (`superseded_co_change_order_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`change_order`(`change_order_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ADD CONSTRAINT `fk_agreement_change_order_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` SET TAGS ('dbx_domain' = 'agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` SET TAGS ('dbx_subdomain' = 'contract_management');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `audit_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `initiated_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Initiated By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `initiated_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `initiated_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `scope_of_work_id` SET TAGS ('dbx_business_glossary_term' = 'Statement of Work (SOW) ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Study Contract Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `superseded_co_change_order_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded Change Order ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `billing_milestone_impact` SET TAGS ('dbx_business_glossary_term' = 'Billing Milestone Impact Description');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `change_reason` SET TAGS ('dbx_business_glossary_term' = 'Change Order Reason');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `change_reason_detail` SET TAGS ('dbx_business_glossary_term' = 'Change Order Reason Detail');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `change_type` SET TAGS ('dbx_business_glossary_term' = 'Change Order Change Type');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `change_type` SET TAGS ('dbx_value_regex' = 'scope_increase|scope_decrease|timeline_extension|budget_reallocation|service_level_change|regulatory_driven');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `co_number` SET TAGS ('dbx_business_glossary_term' = 'Change Order (CO) Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `co_number` SET TAGS ('dbx_value_regex' = '^CO-[0-9]{4}-[0-9]{5}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `co_status` SET TAGS ('dbx_business_glossary_term' = 'Change Order (CO) Status');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `ctms_co_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Change Order Reference');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `delta_value` SET TAGS ('dbx_business_glossary_term' = 'Change Order Delta Value');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `delta_value` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Change Order Effective Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Change Order Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `finance_review_required` SET TAGS ('dbx_business_glossary_term' = 'Finance Review Required Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `impacted_budget_lines` SET TAGS ('dbx_business_glossary_term' = 'Impacted Budget Line References');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `initiation_date` SET TAGS ('dbx_business_glossary_term' = 'Change Order Initiation Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `internal_approver_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `internal_approver_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `legal_review_required` SET TAGS ('dbx_business_glossary_term' = 'Legal Review Required Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Change Order Notes');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `pass_through_delta` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Cost Delta Value');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `pass_through_delta` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Change Order Priority');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `regulatory_driven_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory-Driven Change Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `revised_contract_value` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `scope_description` SET TAGS ('dbx_business_glossary_term' = 'Scope Change Description');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `service_fee_delta` SET TAGS ('dbx_business_glossary_term' = 'Service Fee Delta Value');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `service_fee_delta` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `sponsor_approver_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `sponsor_approver_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`change_order` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Change Order Version Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ADD CONSTRAINT `fk_agreement_contract_amendment_master_service_agreement_id` FOREIGN KEY (`master_service_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`master_service_agreement`(`master_service_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ADD CONSTRAINT `fk_agreement_contract_amendment_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ADD CONSTRAINT `fk_agreement_contract_amendment_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ADD CONSTRAINT `fk_agreement_contract_amendment_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ADD CONSTRAINT `fk_agreement_contract_amendment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ADD CONSTRAINT `fk_agreement_contract_amendment_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ADD CONSTRAINT `fk_agreement_contract_amendment_superseded_by_amendment_contract_amendment_id` FOREIGN KEY (`superseded_by_amendment_contract_amendment_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`contract_amendment`(`contract_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ADD CONSTRAINT `fk_agreement_contract_amendment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ADD CONSTRAINT `fk_agreement_contract_amendment_version_id` FOREIGN KEY (`version_id`) REFERENCES `clinical_trials_ecm`.`document`.`version`(`version_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` SET TAGS ('dbx_domain' = 'agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` SET TAGS ('dbx_subdomain' = 'contract_management');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `master_service_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Service Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Contract ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `superseded_by_amendment_contract_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Amendment ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Document Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `amendment_description` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `amendment_number` SET TAGS ('dbx_value_regex' = '^AMD-[0-9]{4}-[0-9]{3,6}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_value_regex' = 'draft|under_negotiation|pending_signature|executed|superseded|voided');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `amendment_title` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_value_regex' = 'legal_terms|payment_terms|liability|confidentiality|termination|intellectual_property');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `amendment_version` SET TAGS ('dbx_business_glossary_term' = 'Amendment Version Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `change_rationale` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `clauses_modified` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `confidentiality_period_years` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Period (Years)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `contract_currency` SET TAGS ('dbx_business_glossary_term' = 'Contract Currency Code');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `contract_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `cro_signatory_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `cro_signatory_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `cro_signatory_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_value_regex' = 'arbitration|litigation|mediation|expert_determination');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Effective Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `execution_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Execution Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `finance_review_completed` SET TAGS ('dbx_business_glossary_term' = 'Finance Review Completed Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `financial_impact_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `indemnification_modified` SET TAGS ('dbx_business_glossary_term' = 'Indemnification Modified Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `initiated_date` SET TAGS ('dbx_business_glossary_term' = 'Amendment Initiated Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `initiating_party` SET TAGS ('dbx_value_regex' = 'sponsor|cro|mutual');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `legal_review_completed` SET TAGS ('dbx_business_glossary_term' = 'Legal Review Completed Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `legal_review_date` SET TAGS ('dbx_business_glossary_term' = 'Legal Review Completion Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `liability_cap_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `new_payment_terms_description` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Amendment Notes');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `notes` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `payment_terms_modified` SET TAGS ('dbx_business_glossary_term' = 'Payment Terms Modified Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `regulatory_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `sponsor_signatory_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `sponsor_signatory_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `sponsor_signatory_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_amendment` ALTER COLUMN `veeva_vault_document_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ADD CONSTRAINT `fk_agreement_service_level_agreement_approver_employee_id` FOREIGN KEY (`approver_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ADD CONSTRAINT `fk_agreement_service_level_agreement_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ADD CONSTRAINT `fk_agreement_service_level_agreement_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ADD CONSTRAINT `fk_agreement_service_level_agreement_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ADD CONSTRAINT `fk_agreement_service_level_agreement_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ADD CONSTRAINT `fk_agreement_service_level_agreement_master_service_agreement_id` FOREIGN KEY (`master_service_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`master_service_agreement`(`master_service_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ADD CONSTRAINT `fk_agreement_service_level_agreement_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ADD CONSTRAINT `fk_agreement_service_level_agreement_preferred_provider_agreement_id` FOREIGN KEY (`preferred_provider_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement`(`preferred_provider_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ADD CONSTRAINT `fk_agreement_service_level_agreement_scope_of_work_id` FOREIGN KEY (`scope_of_work_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`scope_of_work`(`scope_of_work_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ADD CONSTRAINT `fk_agreement_service_level_agreement_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ADD CONSTRAINT `fk_agreement_service_level_agreement_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ADD CONSTRAINT `fk_agreement_service_level_agreement_superseded_by_service_level_agreement_id` FOREIGN KEY (`superseded_by_service_level_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`service_level_agreement`(`service_level_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` SET TAGS ('dbx_domain' = 'agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` SET TAGS ('dbx_subdomain' = 'contract_management');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `service_level_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approver Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `master_service_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Service Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `preferred_provider_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Preferred Provider Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `scope_of_work_id` SET TAGS ('dbx_business_glossary_term' = 'Statement of Work (SOW) ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Contract ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `superseded_by_service_level_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By SLA ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'SLA Amendment Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `amendment_number` SET TAGS ('dbx_value_regex' = '^AMD-[0-9]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'SLA Approved Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SLA Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `credit_applicable` SET TAGS ('dbx_business_glossary_term' = 'SLA Service Credit Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `credit_value` SET TAGS ('dbx_business_glossary_term' = 'SLA Service Credit Value');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `credit_value` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'SLA Effective End Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'SLA Effective Start Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `escalation_contact` SET TAGS ('dbx_business_glossary_term' = 'SLA Escalation Contact');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `escalation_contact` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `escalation_contact` SET TAGS ('dbx_pii_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `escalation_threshold_value` SET TAGS ('dbx_business_glossary_term' = 'SLA Escalation Threshold Value');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `exclusion_criteria` SET TAGS ('dbx_business_glossary_term' = 'SLA Exclusion Criteria');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `governing_regulation` SET TAGS ('dbx_business_glossary_term' = 'SLA Governing Regulation');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `grace_period_unit` SET TAGS ('dbx_business_glossary_term' = 'SLA Grace Period Unit');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `grace_period_unit` SET TAGS ('dbx_value_regex' = 'hours|business_days|calendar_days');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `grace_period_unit` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `grace_period_value` SET TAGS ('dbx_business_glossary_term' = 'SLA Grace Period Value');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `grace_period_value` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `measurement_frequency` SET TAGS ('dbx_business_glossary_term' = 'SLA Measurement Frequency');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `measurement_frequency` SET TAGS ('dbx_value_regex' = 'per_event|daily|weekly|monthly|quarterly|annually');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `measurement_method` SET TAGS ('dbx_business_glossary_term' = 'SLA Measurement Method');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'SLA Notes');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `penalty_applicable` SET TAGS ('dbx_business_glossary_term' = 'SLA Penalty Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `penalty_cap_value` SET TAGS ('dbx_business_glossary_term' = 'SLA Penalty Cap Value');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `penalty_cap_value` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `penalty_currency_code` SET TAGS ('dbx_business_glossary_term' = 'SLA Penalty Currency Code');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `penalty_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `penalty_type` SET TAGS ('dbx_business_glossary_term' = 'SLA Penalty Type');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `penalty_type` SET TAGS ('dbx_value_regex' = 'fixed_fee|percentage_of_invoice|service_credit|milestone_hold|none');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `penalty_value` SET TAGS ('dbx_business_glossary_term' = 'SLA Penalty Value');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `penalty_value` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `regulatory_commitment_flag` SET TAGS ('dbx_business_glossary_term' = 'SLA Regulatory Commitment Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `reporting_format` SET TAGS ('dbx_business_glossary_term' = 'SLA Reporting Format');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `reporting_format` SET TAGS ('dbx_value_regex' = 'dashboard|monthly_report|quarterly_review|ad_hoc|automated_alert');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `service_category` SET TAGS ('dbx_business_glossary_term' = 'SLA Service Category');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `service_subcategory` SET TAGS ('dbx_business_glossary_term' = 'SLA Service Subcategory');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `sla_code` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Code');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `sla_code` SET TAGS ('dbx_value_regex' = '^SLA-[A-Z0-9]{3,20}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `sla_status` SET TAGS ('dbx_value_regex' = 'draft|active|suspended|expired|terminated|superseded');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `sla_title` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Title');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `sla_type` SET TAGS ('dbx_value_regex' = 'response_time|turnaround_time|frequency|rate|percentage|count');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `target_metric_name` SET TAGS ('dbx_business_glossary_term' = 'SLA Target Metric Name');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `target_metric_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `threshold_direction` SET TAGS ('dbx_business_glossary_term' = 'SLA Threshold Direction');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `threshold_direction` SET TAGS ('dbx_value_regex' = 'less_than_or_equal|greater_than_or_equal|equal');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `threshold_unit` SET TAGS ('dbx_business_glossary_term' = 'SLA Threshold Unit of Measure');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `threshold_value` SET TAGS ('dbx_business_glossary_term' = 'SLA Threshold Value');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SLA Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`service_level_agreement` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'SLA Version Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ADD CONSTRAINT `fk_agreement_agreement_billing_milestone_approver_employee_id` FOREIGN KEY (`approver_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ADD CONSTRAINT `fk_agreement_agreement_billing_milestone_change_order_id` FOREIGN KEY (`change_order_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`change_order`(`change_order_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ADD CONSTRAINT `fk_agreement_agreement_billing_milestone_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ADD CONSTRAINT `fk_agreement_agreement_billing_milestone_scope_of_work_id` FOREIGN KEY (`scope_of_work_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`scope_of_work`(`scope_of_work_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ADD CONSTRAINT `fk_agreement_agreement_billing_milestone_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ADD CONSTRAINT `fk_agreement_agreement_billing_milestone_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ADD CONSTRAINT `fk_agreement_agreement_billing_milestone_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` SET TAGS ('dbx_domain' = 'agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` SET TAGS ('dbx_subdomain' = 'financial_terms');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approver Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `change_order_id` SET TAGS ('dbx_business_glossary_term' = 'Change Order Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `scope_of_work_id` SET TAGS ('dbx_business_glossary_term' = 'Statement of Work (SOW) ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Contract ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `actual_trigger_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Milestone Trigger Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `adjusted_amount` SET TAGS ('dbx_business_glossary_term' = 'Adjusted Milestone Amount');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `adjusted_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Milestone Approval Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Milestone Approval Status');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'not_required|pending_approval|approved|rejected');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `billing_status` SET TAGS ('dbx_business_glossary_term' = 'Billing Milestone Status');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `billing_status` SET TAGS ('dbx_value_regex' = 'pending|triggered|invoiced|paid|disputed|cancelled');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `deliverable_description` SET TAGS ('dbx_business_glossary_term' = 'Milestone Deliverable Description');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `is_pass_through` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Cost Indicator');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `milestone_amount` SET TAGS ('dbx_business_glossary_term' = 'Billing Milestone Amount');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `milestone_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `milestone_name` SET TAGS ('dbx_business_glossary_term' = 'Billing Milestone Name');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `milestone_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `milestone_number` SET TAGS ('dbx_business_glossary_term' = 'Billing Milestone Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `milestone_sequence` SET TAGS ('dbx_business_glossary_term' = 'Milestone Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `milestone_type` SET TAGS ('dbx_business_glossary_term' = 'Billing Milestone Type');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `milestone_type` SET TAGS ('dbx_value_regex' = 'enrollment_based|visit_based|deliverable_based|time_based|safety_based');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Milestone Notes');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `percent_complete` SET TAGS ('dbx_business_glossary_term' = 'Milestone Percent Complete');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `planned_trigger_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Milestone Trigger Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `project_code` SET TAGS ('dbx_business_glossary_term' = 'SAP Project Code');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `revenue_recognition_method` SET TAGS ('dbx_value_regex' = 'point_in_time|over_time|percentage_completion');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `source_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source Record ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone` ALTER COLUMN `wbs_element` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Element');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ADD CONSTRAINT `fk_agreement_deliverable_agreement_billing_milestone_id` FOREIGN KEY (`agreement_billing_milestone_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone`(`agreement_billing_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ADD CONSTRAINT `fk_agreement_deliverable_change_order_id` FOREIGN KEY (`change_order_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`change_order`(`change_order_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ADD CONSTRAINT `fk_agreement_deliverable_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ADD CONSTRAINT `fk_agreement_deliverable_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ADD CONSTRAINT `fk_agreement_deliverable_organization_contact_id` FOREIGN KEY (`organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ADD CONSTRAINT `fk_agreement_deliverable_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ADD CONSTRAINT `fk_agreement_deliverable_scope_of_work_id` FOREIGN KEY (`scope_of_work_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`scope_of_work`(`scope_of_work_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ADD CONSTRAINT `fk_agreement_deliverable_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ADD CONSTRAINT `fk_agreement_deliverable_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` SET TAGS ('dbx_domain' = 'agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` SET TAGS ('dbx_subdomain' = 'financial_terms');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `agreement_billing_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Milestone ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `change_order_id` SET TAGS ('dbx_business_glossary_term' = 'Change Order Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Responsible Owner ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `scope_of_work_id` SET TAGS ('dbx_business_glossary_term' = 'Statement of Work (SOW) ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `cdisc_compliant_flag` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Compliant Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `deliverable_code` SET TAGS ('dbx_value_regex' = '^DLV-[A-Z0-9]{4,20}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `contracted_value_usd` SET TAGS ('dbx_business_glossary_term' = 'Contracted Value (USD)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `contracted_value_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `delivery_method` SET TAGS ('dbx_value_regex' = 'etmf_upload|secure_email|sponsor_portal|ectd_gateway|physical|other');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `delivery_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|submitted|accepted|rejected|on_hold');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `document_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Document Reference ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `gcp_audit_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Audit Required Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `deliverable_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Deliverable Notes');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `phase_milestone` SET TAGS ('dbx_value_regex' = 'startup|enrollment|interim|closeout|post_study');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `qc_review_status` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Review Status');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `qc_review_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|in_review|passed|failed');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `sla_met_flag` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Met Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `sla_target_days` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Target Days');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `tmf_filing_required_flag` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Filing Required Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `deliverable_type` SET TAGS ('dbx_value_regex' = 'report|plan|submission|dataset|package|other');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`deliverable` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^v?[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ADD CONSTRAINT `fk_agreement_investigator_grant_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ADD CONSTRAINT `fk_agreement_investigator_grant_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ADD CONSTRAINT `fk_agreement_investigator_grant_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ADD CONSTRAINT `fk_agreement_investigator_grant_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ADD CONSTRAINT `fk_agreement_investigator_grant_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ADD CONSTRAINT `fk_agreement_investigator_grant_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ADD CONSTRAINT `fk_agreement_investigator_grant_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_ecm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ADD CONSTRAINT `fk_agreement_investigator_grant_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ADD CONSTRAINT `fk_agreement_investigator_grant_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ADD CONSTRAINT `fk_agreement_investigator_grant_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ADD CONSTRAINT `fk_agreement_investigator_grant_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` SET TAGS ('dbx_domain' = 'agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` SET TAGS ('dbx_subdomain' = 'financial_terms');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `investigator_grant_id` SET TAGS ('dbx_business_glossary_term' = 'Investigator Grant Identifier');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Study Contract Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Study Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `ctms_grant_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Grant Reference');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `fair_market_value_verified` SET TAGS ('dbx_business_glossary_term' = 'Fair Market Value (FMV) Verified Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `fmv_benchmark_source` SET TAGS ('dbx_business_glossary_term' = 'Fair Market Value (FMV) Benchmark Source');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `fmv_benchmark_source` SET TAGS ('dbx_value_regex' = 'medidata_grants_manager|mclaughlin_associates|bbk_worldwide|internal_database|other');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `grant_number` SET TAGS ('dbx_business_glossary_term' = 'Investigator Grant Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `grant_type` SET TAGS ('dbx_value_regex' = 'per_capita|fee_for_service|hybrid|fixed_fee');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `irb_iec_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Required Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Grant Notes');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `overhead_percentage` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `overhead_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `pass_through_budget` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Budget');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `pass_through_budget` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|check|ach|direct_deposit|virtual_card');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `payment_schedule_type` SET TAGS ('dbx_value_regex' = 'per_visit|per_procedure|milestone|monthly|quarterly|completion');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `sap_purchase_order_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Purchase Order (PO) Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `screen_failure_payment_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `service_fee_budget` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `sunshine_act_reportable` SET TAGS ('dbx_business_glossary_term' = 'Sunshine Act Reportable Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `total_grant_value` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `vat_applicable` SET TAGS ('dbx_business_glossary_term' = 'VAT Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `withholding_percentage` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`investigator_grant` ALTER COLUMN `withholding_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ADD CONSTRAINT `fk_agreement_contract_negotiation_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ADD CONSTRAINT `fk_agreement_contract_negotiation_compliance_obligation_id` FOREIGN KEY (`compliance_obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ADD CONSTRAINT `fk_agreement_contract_negotiation_contract_amendment_id` FOREIGN KEY (`contract_amendment_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`contract_amendment`(`contract_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ADD CONSTRAINT `fk_agreement_contract_negotiation_cro_lead_employee_id` FOREIGN KEY (`cro_lead_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ADD CONSTRAINT `fk_agreement_contract_negotiation_master_service_agreement_id` FOREIGN KEY (`master_service_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`master_service_agreement`(`master_service_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ADD CONSTRAINT `fk_agreement_contract_negotiation_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ADD CONSTRAINT `fk_agreement_contract_negotiation_regulatory_strategy_id` FOREIGN KEY (`regulatory_strategy_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`strategy`(`strategy_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ADD CONSTRAINT `fk_agreement_contract_negotiation_scope_of_work_id` FOREIGN KEY (`scope_of_work_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`scope_of_work`(`scope_of_work_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ADD CONSTRAINT `fk_agreement_contract_negotiation_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ADD CONSTRAINT `fk_agreement_contract_negotiation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ADD CONSTRAINT `fk_agreement_contract_negotiation_version_id` FOREIGN KEY (`version_id`) REFERENCES `clinical_trials_ecm`.`document`.`version`(`version_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` SET TAGS ('dbx_domain' = 'agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` SET TAGS ('dbx_subdomain' = 'contract_management');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `compliance_obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `contract_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `cro_lead_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Cro Lead Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `cro_lead_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `cro_lead_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `master_service_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Service Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `regulatory_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Regulatory Strategy Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `scope_of_work_id` SET TAGS ('dbx_business_glossary_term' = 'Scope Of Work Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Contract ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Document Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `approved_by` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `approved_by` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `ctms_negotiation_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Negotiation Reference');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `document_version` SET TAGS ('dbx_business_glossary_term' = 'Contract Document Version');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `document_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `escalation_reason` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `governing_law_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `legal_counsel_cro` SET TAGS ('dbx_business_glossary_term' = 'CRO Legal Counsel Name');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `legal_counsel_cro` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `legal_counsel_cro` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `legal_counsel_cro` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `legal_counsel_sponsor` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Legal Counsel Name');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `legal_counsel_sponsor` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `legal_counsel_sponsor` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `legal_counsel_sponsor` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `negotiated_contract_value` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `negotiation_channel` SET TAGS ('dbx_value_regex' = 'email|veeva_vault|docusign|in_person|video_conference|legal_portal');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `negotiation_number` SET TAGS ('dbx_value_regex' = '^NEG-[A-Z0-9]{4,10}-[0-9]{4,6}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `negotiation_round` SET TAGS ('dbx_business_glossary_term' = 'Negotiation Round Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `negotiation_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|redline|legal_review|approved|executed');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `negotiation_type` SET TAGS ('dbx_value_regex' = 'master_service_agreement|scope_of_work|change_order|amendment|confidentiality_agreement|service_level_agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Negotiation Notes');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `notes` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `open_issues_summary` SET TAGS ('dbx_business_glossary_term' = 'Key Open Issues Summary');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `open_issues_summary` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `pass_through_value` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Budget Value');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `pass_through_value` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `payment_model` SET TAGS ('dbx_value_regex' = 'milestone_based|time_and_materials|fixed_fee|unit_based|hybrid');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Negotiation Priority Level');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `service_fee_value` SET TAGS ('dbx_business_glossary_term' = 'Service Fee Budget Value');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `service_fee_value` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `sponsor_lead_contact` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Lead Negotiator Contact');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `sponsor_lead_contact` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `sponsor_lead_contact` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `sponsor_lead_contact` SET TAGS ('dbx_pii_contact' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `termination_flag` SET TAGS ('dbx_business_glossary_term' = 'Negotiation Termination Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Negotiation Termination Reason');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'sponsor_withdrawal|budget_disagreement|scope_disagreement|legal_impasse|competitive_loss|other');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `termination_reason` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_negotiation` ALTER COLUMN `veeva_vault_document_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ADD CONSTRAINT `fk_agreement_contract_obligation_compliance_obligation_id` FOREIGN KEY (`compliance_obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ADD CONSTRAINT `fk_agreement_contract_obligation_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ADD CONSTRAINT `fk_agreement_contract_obligation_contract_amendment_id` FOREIGN KEY (`contract_amendment_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`contract_amendment`(`contract_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ADD CONSTRAINT `fk_agreement_contract_obligation_linked_milestone_agreement_billing_milestone_id` FOREIGN KEY (`linked_milestone_agreement_billing_milestone_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone`(`agreement_billing_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ADD CONSTRAINT `fk_agreement_contract_obligation_regulatory_action_item_id` FOREIGN KEY (`regulatory_action_item_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_action_item`(`regulatory_action_item_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ADD CONSTRAINT `fk_agreement_contract_obligation_regulatory_commitment_id` FOREIGN KEY (`regulatory_commitment_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`regulatory_commitment`(`regulatory_commitment_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ADD CONSTRAINT `fk_agreement_contract_obligation_responsible_owner_employee_id` FOREIGN KEY (`responsible_owner_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ADD CONSTRAINT `fk_agreement_contract_obligation_scope_of_work_id` FOREIGN KEY (`scope_of_work_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`scope_of_work`(`scope_of_work_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ADD CONSTRAINT `fk_agreement_contract_obligation_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ADD CONSTRAINT `fk_agreement_contract_obligation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ADD CONSTRAINT `fk_agreement_contract_obligation_study_protocol_milestone_id` FOREIGN KEY (`study_protocol_milestone_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_milestone`(`study_protocol_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ADD CONSTRAINT `fk_agreement_contract_obligation_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` SET TAGS ('dbx_domain' = 'agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` SET TAGS ('dbx_subdomain' = 'contract_management');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `compliance_obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `contract_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Contract Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `linked_milestone_agreement_billing_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Linked Billing Milestone ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `regulatory_action_item_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Action Item Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `regulatory_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Commitment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `responsible_owner_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Responsible Owner Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `responsible_owner_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `responsible_owner_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `scope_of_work_id` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Contract ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `study_protocol_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Study Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Obligation Comments');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `ctms_obligation_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Obligation Reference');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `dispute_description` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Obligation Due Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Obligation Effective Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `escalation_status` SET TAGS ('dbx_value_regex' = 'not_triggered|triggered|acknowledged|resolved');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `evidence_description` SET TAGS ('dbx_business_glossary_term' = 'Fulfillment Evidence Description');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `fulfillment_date` SET TAGS ('dbx_business_glossary_term' = 'Obligation Fulfillment Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `is_dispute_item` SET TAGS ('dbx_business_glossary_term' = 'Dispute Item Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `is_regulatory_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Required Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `obligation_number` SET TAGS ('dbx_value_regex' = '^OBL-[A-Z0-9]{3,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `obligation_type` SET TAGS ('dbx_value_regex' = 'regulatory|financial|operational|reporting|dispute');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `penalty_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `penalty_clause` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Obligation Priority Level');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `recurrence_pattern` SET TAGS ('dbx_value_regex' = 'one_time|daily|weekly|monthly|quarterly|annual');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `responsible_party` SET TAGS ('dbx_value_regex' = 'sponsor|cro|site|subcontractor|joint');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `review_required` SET TAGS ('dbx_business_glossary_term' = 'Review Required Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `reviewer_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `reviewer_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `source_document_type` SET TAGS ('dbx_value_regex' = 'msa|sow|amendment|change_order|subcontract|sla');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`contract_obligation` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Obligation Version Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ADD CONSTRAINT `fk_agreement_preferred_provider_agreement_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ADD CONSTRAINT `fk_agreement_preferred_provider_agreement_compliance_obligation_id` FOREIGN KEY (`compliance_obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ADD CONSTRAINT `fk_agreement_preferred_provider_agreement_cro_alliance_manager_employee_id` FOREIGN KEY (`cro_alliance_manager_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ADD CONSTRAINT `fk_agreement_preferred_provider_agreement_master_service_agreement_id` FOREIGN KEY (`master_service_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`master_service_agreement`(`master_service_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ADD CONSTRAINT `fk_agreement_preferred_provider_agreement_parent_ppa_preferred_provider_agreement_id` FOREIGN KEY (`parent_ppa_preferred_provider_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement`(`preferred_provider_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ADD CONSTRAINT `fk_agreement_preferred_provider_agreement_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` SET TAGS ('dbx_domain' = 'agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` SET TAGS ('dbx_subdomain' = 'contract_management');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `preferred_provider_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Preferred Provider Agreement Identifier');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `compliance_obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `cro_alliance_manager_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Cro Alliance Manager Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `cro_alliance_manager_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `cro_alliance_manager_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `master_service_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Service Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `parent_ppa_preferred_provider_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Preferred Provider Agreement (PPA) ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'preferred_provider_agreement|framework_agreement|master_vendor_agreement|strategic_alliance_agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `confidentiality_term_years` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Term (Years)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `contract_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `cro_legal_entity` SET TAGS ('dbx_business_glossary_term' = 'Contract Research Organization (CRO) Legal Entity Name');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `cro_legal_entity` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `ctms_ppa_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) PPA Reference');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `data_privacy_framework` SET TAGS ('dbx_value_regex' = 'GDPR|HIPAA|PIPEDA|PDPA|LGPD|combined');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_value_regex' = 'arbitration|mediation|litigation|expert_determination');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `force_majeure_clause` SET TAGS ('dbx_business_glossary_term' = 'Force Majeure Clause Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `governance_committee_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `governance_review_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `governing_law_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `ip_ownership` SET TAGS ('dbx_business_glossary_term' = 'Intellectual Property (IP) Ownership');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `ip_ownership` SET TAGS ('dbx_value_regex' = 'sponsor|cro|joint|licensed_to_sponsor');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `ip_ownership` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `liability_cap_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `payment_terms_days` SET TAGS ('dbx_business_glossary_term' = 'Payment Terms (Days)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `ppa_number` SET TAGS ('dbx_business_glossary_term' = 'Preferred Provider Agreement (PPA) Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `ppa_number` SET TAGS ('dbx_value_regex' = '^PPA-[A-Z0-9]{4,10}-[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `rate_card_reference` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `renewal_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Renewal Notice Period (Days)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `sap_contract_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Contract ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `sla_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Document Reference');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `sla_included_flag` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Included Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `sponsor_alliance_manager` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Alliance Manager Name');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `sponsor_alliance_manager` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `sponsor_alliance_manager` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `sponsor_legal_entity` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Legal Entity Name');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `sponsor_legal_entity` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `subcontracting_permitted` SET TAGS ('dbx_business_glossary_term' = 'Subcontracting Permitted Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `termination_for_convenience_days` SET TAGS ('dbx_business_glossary_term' = 'Termination for Convenience Notice Period (Days)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'convenience|breach|mutual_agreement|regulatory_action|sponsor_insolvency|cro_performance');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `veeva_vault_doc_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `volume_commitment_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement` ALTER COLUMN `volume_commitment_unit` SET TAGS ('dbx_value_regex' = 'currency|study_count|fte_hours|subject_count');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ADD CONSTRAINT `fk_agreement_confidentiality_agreement_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ADD CONSTRAINT `fk_agreement_confidentiality_agreement_master_service_agreement_id` FOREIGN KEY (`master_service_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`master_service_agreement`(`master_service_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ADD CONSTRAINT `fk_agreement_confidentiality_agreement_parent_agreement_confidentiality_agreement_id` FOREIGN KEY (`parent_agreement_confidentiality_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`confidentiality_agreement`(`confidentiality_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ADD CONSTRAINT `fk_agreement_confidentiality_agreement_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ADD CONSTRAINT `fk_agreement_confidentiality_agreement_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ADD CONSTRAINT `fk_agreement_confidentiality_agreement_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` SET TAGS ('dbx_domain' = 'agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` SET TAGS ('dbx_subdomain' = 'contract_management');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `master_service_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Service Agreement (MSA) ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `master_service_agreement_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `parent_agreement_confidentiality_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Confidentiality Agreement ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `parent_agreement_confidentiality_agreement_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Study Contract Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `agreement_number` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Agreement Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `agreement_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `agreement_status` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Agreement Execution Status');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `agreement_status` SET TAGS ('dbx_value_regex' = 'draft|pending_execution|executed|expired|terminated|superseded');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Agreement Type');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'unilateral|bilateral|multilateral');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `amendment_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `breach_notification_days` SET TAGS ('dbx_business_glossary_term' = 'Breach Notification Period (Days)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `breach_notification_days` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `confidentiality_term_years` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Obligation Term (Years)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `confidentiality_term_years` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `cro_legal_entity` SET TAGS ('dbx_business_glossary_term' = 'Contract Research Organization (CRO) Legal Entity Name');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `cro_legal_entity` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `cro_signatory_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `cro_signatory_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `cro_signatory_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `ctms_agreement_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Agreement Reference');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `ctms_agreement_reference` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `data_privacy_framework` SET TAGS ('dbx_value_regex' = 'GDPR|HIPAA|PIPEDA|PDPA|LGPD|other');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `data_privacy_framework` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `data_return_destruction_clause` SET TAGS ('dbx_business_glossary_term' = 'Data Return or Destruction Clause Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `data_return_destruction_clause` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `disclosing_party` SET TAGS ('dbx_value_regex' = 'sponsor|cro|both|third_party');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `disclosing_party` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_value_regex' = 'litigation|arbitration|mediation|expert_determination');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Agreement Effective Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `effective_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `esignature_flag` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `esignature_flag` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `execution_date` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Agreement Execution Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `execution_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Agreement Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `expiry_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `governing_law_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `governing_law_country` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `governing_law_state` SET TAGS ('dbx_business_glossary_term' = 'Governing Law State or Province');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `governing_law_state` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `inspection_ready_flag` SET TAGS ('dbx_business_glossary_term' = 'Inspection Readiness Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `ip_ownership_clause` SET TAGS ('dbx_business_glossary_term' = 'Intellectual Property Ownership Clause Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `ip_ownership_clause` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Agreement Notes');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `notes` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `permitted_disclosures` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `receiving_party` SET TAGS ('dbx_value_regex' = 'sponsor|cro|both|third_party');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `receiving_party` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `renewal_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Renewal Notice Period (Days)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `renewal_notice_days` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `residual_knowledge_clause` SET TAGS ('dbx_business_glossary_term' = 'Residual Knowledge Clause Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `residual_knowledge_clause` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `sap_contract_reference` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `scope_of_confidential_info` SET TAGS ('dbx_business_glossary_term' = 'Scope of Confidential Information');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `scope_of_confidential_info` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `sponsor_legal_entity` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Legal Entity Name');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `sponsor_legal_entity` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `sponsor_signatory_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `sponsor_signatory_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `sponsor_signatory_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `study_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Phase');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `study_phase` SET TAGS ('dbx_value_regex' = 'pre_clinical|phase_1|phase_2|phase_3|phase_4|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `study_phase` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Agreement Termination Date');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `termination_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'mutual_agreement|breach|convenience|superseded|study_cancelled');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `termination_reason` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `third_party_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `third_party_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `veeva_vault_doc_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`confidentiality_agreement` ALTER COLUMN `veeva_vault_doc_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ADD CONSTRAINT `fk_agreement_subcontract_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ADD CONSTRAINT `fk_agreement_subcontract_compliance_obligation_id` FOREIGN KEY (`compliance_obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ADD CONSTRAINT `fk_agreement_subcontract_contract_manager_employee_id` FOREIGN KEY (`contract_manager_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ADD CONSTRAINT `fk_agreement_subcontract_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ADD CONSTRAINT `fk_agreement_subcontract_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ADD CONSTRAINT `fk_agreement_subcontract_scope_of_work_id` FOREIGN KEY (`scope_of_work_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`scope_of_work`(`scope_of_work_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ADD CONSTRAINT `fk_agreement_subcontract_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ADD CONSTRAINT `fk_agreement_subcontract_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` SET TAGS ('dbx_domain' = 'agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` SET TAGS ('dbx_subdomain' = 'contract_management');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `compliance_obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `contract_manager_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Contract Manager Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `contract_manager_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `contract_manager_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `scope_of_work_id` SET TAGS ('dbx_business_glossary_term' = 'Scope Of Work Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `confidentiality_term_years` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Term (Years)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `contract_status` SET TAGS ('dbx_business_glossary_term' = 'Subcontract Status');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `ctms_subcontract_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Subcontract Reference');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `data_privacy_framework` SET TAGS ('dbx_value_regex' = 'GDPR|HIPAA|PIPEDA|PDPA|none|multiple');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `flow_down_obligations` SET TAGS ('dbx_business_glossary_term' = 'Flow-Down Obligations');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `gcp_compliance_required` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Compliance Required');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `governing_law_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `liability_cap_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `pass_through_amount` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Amount');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `pass_through_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `payment_model` SET TAGS ('dbx_value_regex' = 'milestone|time_and_materials|fixed_fee|per_unit|cost_plus');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `payment_terms_days` SET TAGS ('dbx_business_glossary_term' = 'Payment Terms (Days)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `sap_po_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Purchase Order (PO) Number');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `service_fee_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `sla_included_flag` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Included Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `sponsor_approval_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|approved|rejected|conditionally_approved');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `subcontractor_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `subcontractor_contact_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `subcontractor_contact_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `subcontractor_qualification_status` SET TAGS ('dbx_value_regex' = 'qualified|pending_qualification|disqualified|under_review');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `subcontract_type` SET TAGS ('dbx_value_regex' = 'laboratory_services|imaging|eCOA|translation|monitoring|other');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `value` SET TAGS ('dbx_business_glossary_term' = 'Subcontract Total Value');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `value` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`subcontract` ALTER COLUMN `veeva_vault_doc_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ADD CONSTRAINT `fk_agreement_rate_card_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ADD CONSTRAINT `fk_agreement_rate_card_job_profile_id` FOREIGN KEY (`job_profile_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`job_profile`(`job_profile_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ADD CONSTRAINT `fk_agreement_rate_card_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ADD CONSTRAINT `fk_agreement_rate_card_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ADD CONSTRAINT `fk_agreement_rate_card_master_service_agreement_id` FOREIGN KEY (`master_service_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`master_service_agreement`(`master_service_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ADD CONSTRAINT `fk_agreement_rate_card_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ADD CONSTRAINT `fk_agreement_rate_card_preferred_provider_agreement_id` FOREIGN KEY (`preferred_provider_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement`(`preferred_provider_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ADD CONSTRAINT `fk_agreement_rate_card_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ADD CONSTRAINT `fk_agreement_rate_card_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` SET TAGS ('dbx_domain' = 'agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` SET TAGS ('dbx_subdomain' = 'financial_terms');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `job_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Job Profile Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Panel Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `master_service_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Service Agreement (MSA) ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `preferred_provider_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Preferred Provider Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|under_review');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `ctms_rate_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Rate Reference');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `escalation_basis` SET TAGS ('dbx_value_regex' = 'fixed|cpi_linked|negotiated|none');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `escalation_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Annual Escalation Rate Percentage');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `escalation_rate_pct` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `markup_pct` SET TAGS ('dbx_business_glossary_term' = 'Markup Percentage');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `markup_pct` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `rate_card_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Rate Card Notes');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^RC-[A-Z0-9]{4,20}$');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `number` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `pass_through_flag` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `sap_price_list_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Price List ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `sow_applicable_flag` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work (SOW) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `sponsor_approved_by` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `sponsor_approved_by` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `rate_card_status` SET TAGS ('dbx_value_regex' = 'draft|active|superseded|expired|withdrawn');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `study_phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase II|Phase III|Phase IV|Phase I/II|Phase II/III');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `rate_card_type` SET TAGS ('dbx_value_regex' = 'standard|preferred_provider|study_specific|therapeutic_area|regional');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `unit_rate` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `veeva_vault_doc_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `volume_discount_pct` SET TAGS ('dbx_business_glossary_term' = 'Volume Discount Percentage');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`rate_card` ALTER COLUMN `volume_discount_pct` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`obligation_fulfillment` ADD CONSTRAINT `fk_agreement_obligation_fulfillment_contract_obligation_id` FOREIGN KEY (`contract_obligation_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`contract_obligation`(`contract_obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`obligation_fulfillment` ADD CONSTRAINT `fk_agreement_obligation_fulfillment_deliverable_id` FOREIGN KEY (`deliverable_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`deliverable`(`deliverable_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`obligation_fulfillment` ADD CONSTRAINT `fk_agreement_obligation_fulfillment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`agreement`.`obligation_fulfillment` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`obligation_fulfillment` SET TAGS ('dbx_domain' = 'agreement');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`obligation_fulfillment` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`obligation_fulfillment` SET TAGS ('dbx_subdomain' = 'financial_terms');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`obligation_fulfillment` SET TAGS ('dbx_association_edges' = 'agreement.deliverable,agreement.contract_obligation');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`obligation_fulfillment` ALTER COLUMN `obligation_fulfillment_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Fulfillment - Obligation Fulfillment Id');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`obligation_fulfillment` ALTER COLUMN `contract_obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Fulfillment - Contract Obligation Id');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`obligation_fulfillment` ALTER COLUMN `deliverable_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Fulfillment - Deliverable Id');

ALTER TABLE `clinical_trials_ecm`.`agreement`.`obligation_fulfillment` ALTER COLUMN `fulfillment_percentage` SET TAGS ('dbx_pii' = 'true');
