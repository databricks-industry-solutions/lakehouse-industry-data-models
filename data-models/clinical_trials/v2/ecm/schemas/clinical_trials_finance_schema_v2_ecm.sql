-- Schema for Domain: finance | Business: Clinical_Trials | Version: v2_ecm
-- Generated on: 2026-11-20 10:02:59

CREATE DATABASE IF NOT EXISTS `clinical_trials_ecm`.`finance` COMMENT 'Manages clinical trial financial operations including study budgets, investigator grants, site payment milestones, patient stipends, pass-through cost tracking, sponsor invoicing, accounts payable/receivable, accruals, financial forecasting, and project';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`finance`.`study_budget` (
    `study_budget_id` BIGINT COMMENT 'Unique surrogate identifier for the study budget master record in the Databricks Silver Layer. Primary key for this entity.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Study budget approval is a named SOX financial control process in clinical trials. The approver must be a credentialed employee traceable in the workforce system.',
    `change_order_id` BIGINT COMMENT 'Foreign key linking to agreement.change_order. Business justification: Approved change orders directly trigger study budget revisions in clinical trials. Finance teams create new budget versions when change orders are executed.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Study budgets are managed under a primary cost center in the source system. study_budget.cost_center_code is a denormalized string; adding cost_center_id FK normalizes this to the',
    `dmp_id` BIGINT COMMENT 'Foreign key linking to datamanagement.dmp. Business justification: The Data Management Plan version drives budget scope for data management activities (EDC build, coding, SDTM). Budget amendments are triggered by DMP amendments.',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Study budgets reference a primary GL account for financial reporting. study_budget.gl_account_code is a denormalized string; adding gl_account_id FK normalizes this to the authoritative',
    `master_agreement_id` BIGINT COMMENT 'Foreign key linking to sponsor.master_agreement. Business justification: Master agreements define preferred pricing discounts and volume commitments applied during study budget construction.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor funding this clinical study budget.',
    `pipeline_asset_id` BIGINT COMMENT 'Foreign key linking to sponsor.pipeline_asset. Business justification: Study budgets are built for a specific pipeline assets development program. Portfolio finance reporting aggregates spend by asset.',
    `program_strategic_plan_id` BIGINT COMMENT 'Foreign key linking to program.program_plan. Business justification: Study budgets are developed against a specific program development plan version. Linking enables variance analysis between planned program spend (program_plan.planned_budget_usd) and',
    `proposal_id` BIGINT COMMENT 'Foreign key linking to sponsor.proposal. Business justification: Awarded proposals are the commercial baseline for study budgets. Finance teams build study_budget directly from the winning proposals scope and pricing.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Study budgets are built against a specific protocol version. Protocol amendments trigger budget revisions (change orders).',
    `sample_size_calc_id` BIGINT COMMENT 'Foreign key linking to biostatistics.sample_size_calc. Business justification: Budget build process: finance teams use the approved sample size calculation (total_enrollment_target, sample_size_per_arm) as the primary statistical input for',
    `scope_of_work_id` BIGINT COMMENT 'Foreign key linking to agreement.scope_of_work. Business justification: Study budgets are constructed to fund a specific SOW version. CRO finance tracks budget at SOW level — when SOW is amended, a new budget version is created.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this budget is defined. Links the financial envelope to the study master record.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Protocol amendments drive budget amendments (change orders). study_budget.amendment_number is a denormalized reference to the amendment record.',
    `amendment_reason` STRING COMMENT 'Narrative description of the business justification for the budget amendment, such as protocol change, scope expansion, site addition, or regulatory requirement. Required for SOX-compliant change audit trail.',
    `approval_status` STRING COMMENT 'Current approval workflow status of this budget version. Tracks the formal sign-off process required before the budget becomes financially active. Supports SOX internal control documentation.. Valid values are `pending|approved|rejected|withdrawn`',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time when this budget version received formal financial approval. Captured per 21 CFR Part 11 electronic signature requirements and SOX audit trail standards.',
    `budget_effective_date` DATE COMMENT 'The date from which this budget version becomes financially binding and active for cost tracking and sponsor invoicing purposes.',
    `budget_expiry_date` DATE COMMENT 'The date on which this budget version expires or is superseded by a new amendment. Null for the currently active version. Supports version history management.',
    `budget_number` STRING COMMENT 'Externally-known, human-readable budget reference number assigned by the source system accounting. Used in sponsor invoicing, financial reporting, and SOX audit trails.. Valid values are `^BDG-[0-9]{4}-[A-Z0-9]{6,12}$`',
    `budget_status` STRING COMMENT 'Current lifecycle state of the study budget record. Drives workflow approvals, financial controls, and SOX-compliant change management. [ENUM-REF-CANDIDATE: draft|pending_approval|approved|active|amended|closed|cancelled — promote to reference product]',
    `budget_type` STRING COMMENT 'Classification of the budget record indicating whether it represents the original approved budget, a formal amendment, a supplemental allocation, or a contingency reserve.. Valid values are `original|amendment|supplemental|contingency`',
    `budget_version` BIGINT COMMENT 'Sequential integer version number of the budget, incremented with each approved amendment. Version 1 represents the original approved budget; subsequent versions reflect contract amendments or scope changes.',
    `company_code` STRING COMMENT 'the source system code representing the legal entity responsible for this study budget. Used for financial consolidation, intercompany accounting, and SOX entity-level reporting.. Valid values are `^[A-Z0-9]{4}$`',
    `contingency_amount` DECIMAL(18,2) COMMENT 'Budgeted contingency reserve amount set aside for unforeseen study costs, protocol deviations, or scope changes. Typically expressed as a percentage of total direct costs.',
    `cost_category` STRING COMMENT 'High-level classification of the budget cost type. Distinguishes direct study costs, indirect/overhead allocations, pass-through expenses billed to sponsor, investigator grants, and patient stipends for granular financial analysis.. Valid values are `direct|indirect|overhead|pass_through|investigator_grant|patient_stipend`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this study budget record was first created in the source system. Supports ALCOA+ data integrity principles and SOX audit trail requirements.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts in this budget record (e.g., USD, EUR, GBP, JPY). Enables multi-currency study financial management.. Valid values are `^[A-Z]{3}$`',
    `direct_cost_amount` DECIMAL(18,2) COMMENT 'Portion of the total approved budget allocated to direct study costs, including clinical operations, site management, data management, and biostatistics activities.',
    `exchange_rate` DECIMAL(18,6) COMMENT 'Foreign exchange rate applied to convert the transaction currency to the company code currency at the time of budget approval. Sourced from the source system rate tables.',
    `fiscal_period` BIGINT COMMENT 'The fiscal period (month 1–12) within the fiscal year to which this budget allocation applies. Supports monthly accrual calculations and period-level variance analysis.',
    `fiscal_year` BIGINT COMMENT 'The fiscal year to which this budget record or line item applies. Used for annual financial planning, accrual management, and SOX period-end reporting.',
    `indirect_cost_amount` DECIMAL(18,2) COMMENT 'Portion of the total approved budget allocated to indirect costs such as administrative overhead, facility costs, and shared service allocations not directly attributable to a single study activity.',
    `investigator_grant_amount` DECIMAL(18,2) COMMENT 'Total budgeted amount for investigator grants payable to Principal Investigators (PIs) and clinical sites for conducting study procedures per the site payment schedule.',
    `is_pass_through_billable` BOOLEAN COMMENT 'Indicates whether pass-through costs in this budget are contractually billable to the sponsor at cost without markup. Drives accounts receivable and sponsor invoicing logic.',
    `is_sox_controlled` BOOLEAN COMMENT 'Indicates whether this study budget is subject to Sarbanes-Oxley (SOX) financial reporting controls. True for budgets associated with publicly-reported financial obligations.',
    `overhead_amount` DECIMAL(18,2) COMMENT 'Overhead allocation applied to the study budget, typically calculated as a percentage of direct costs per the CROs overhead rate agreement with the sponsor.',
    `pass_through_estimate_amount` DECIMAL(18,2) COMMENT 'Estimated amount for pass-through costs to be billed directly to the sponsor at cost, including central lab fees, imaging, specialty vendors, and IRB/IEC fees. Tracked separately from CRO service fees.',
    `patient_stipend_amount` DECIMAL(18,2) COMMENT 'Total budgeted amount for patient stipends and reimbursements, including travel, parking, and participation compensation paid to study subjects per IRB/IEC-approved amounts.',
    `planned_site_count` BIGINT COMMENT 'Number of investigational sites planned for the study as reflected in the budget assumptions. Drives site activation costs, monitoring visit budgets, and investigator grant totals.',
    `planned_subject_count` BIGINT COMMENT 'Total number of study subjects (patients) planned for enrollment as reflected in the budget assumptions. Key driver for per-patient cost calculations and investigator grant milestones.',
    `profit_center_code` STRING COMMENT 'the source system center code for the business unit or therapeutic area responsible for this study budget. Enables profitability analysis by business segment.. Valid values are `^[A-Z0-9]{4,10}$`',
    `sponsor_contract_number` STRING COMMENT 'The sponsor-assigned contract or work order number associated with this study budget. Used for sponsor invoicing reconciliation and contract management.',
    `study_end_date` DATE COMMENT 'Planned or actual end date of the clinical study as reflected in the budget planning horizon. Used for financial close-out planning and final accrual calculations.',
    `study_start_date` DATE COMMENT 'Planned or actual start date of the clinical study as reflected in the budget planning horizon. Used for fiscal period allocation and accrual scheduling.',
    `total_budget_amount` DECIMAL(18,2) COMMENT 'The total approved financial budget envelope for the clinical study in the transaction currency. Represents the gross budget including direct costs, indirect costs, overhead, and pass-through estimates.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this study budget record was last modified in the source system. Supports change detection, incremental data loading, and SOX audit trail requirements.',
    `wbs_element_code` STRING COMMENT 'the source system Breakdown Structure element code that uniquely identifies the project node to which this budget is assigned. Enables hierarchical cost tracking and project accounting roll-up.. Valid values are `^[A-Z0-9]{2,20}(-[A-Z0-9]{1,10}){0,5}$`',
    CONSTRAINT pk_study_budget PRIMARY KEY(`study_budget_id`)
) COMMENT 'Master record for the total approved financial budget allocated to a clinical study, including versioned amendments and granular line-item breakdown by cost category, WBS element, and fiscal period.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`finance`.`cost_center` (
    `cost_center_id` BIGINT COMMENT 'Unique surrogate identifier for the cost center record in the Databricks Silver Layer. Primary key generated by the lakehouse ingestion pipeline from the source system',
    `activity_type_group` STRING COMMENT 'the source system group (LGRUPPE) associated with this cost center, defining the types of internal activities (e.g., CRA monitoring hours, biostatistician hours, regulatory writing hours) that can be planned and allocated.. Valid values are `^[A-Z0-9_-]{1,20}$`',
    `annual_budget_amount` DECIMAL(18,2) COMMENT 'Total approved annual budget allocated to this cost center in the cost centers primary currency. Represents the planned expenditure ceiling for the fiscal year as approved through the the source system cycle. Used for budget vs.',
    `business_area_code` STRING COMMENT 'the source system (GSBER) associated with this cost center. Represents a distinct area of operations for which an internal balance sheet and P&L can be produced. Used for -code financial reporting in multi-entity CRO structures.. Valid values are `^[A-Z0-9]{1,4}$`',
    `cost_center_category` STRING COMMENT 'the source system category (KOSAR) that determines which activity types and statistical key figures can be posted. Common categories in clinical research include: E (Production/Operations), F (Research & Development), G (General & Administrative), H (Human',
    `cost_center_code` STRING COMMENT 'The externally-known alphanumeric code assigned to the cost center in the source system CC-FIN-001, CC-CRA-ONCOLOGY). Used as the primary business identifier on all financial postings, purchase orders, and project accounting entries.. Valid values are `^[A-Z0-9_-]{2,20}$`',
    `company_code` STRING COMMENT 'the source system (BUKRS) representing the legal entity to which this cost center is assigned. Determines the chart of accounts, fiscal year, and local currency for financial reporting and SOX compliance.. Valid values are `^[A-Z0-9]{1,4}$`',
    `controlling_area_code` STRING COMMENT 'the source system (KOKRS) to which this cost center belongs. Defines the organizational unit within which cost accounting is performed. All cost centers within a controlling area share the same fiscal year variant and currency settings.. Valid values are `^[A-Z0-9]{1,4}$`',
    `cost_allocation_method` STRING COMMENT 'Method used to allocate or distribute costs from this cost center to other cost objects (studies, projects, sponsors). direct = direct assignment; assessment = the source system distribution = the source system activity_based = activity. Valid values are `direct|assessment|distribution|activity_based|statistical`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the country where this cost centers organizational unit is domiciled (e.g., USA, GBR, DEU, JPN). Determines applicable tax jurisdiction, regulatory reporting requirements (FDA, EMA, PMDA), and GDPR/HIPAA data residency. Valid values are `^[A-Z]{3}$`',
    `created_by_user` STRING COMMENT 'the source system (ERNAM) of the person who created this cost center record in the source system for SOX audit trail, segregation of duties validation, and ALCOA+ (Attributable) compliance for financial records.. Valid values are `^[A-Z0-9_]{1,12}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this cost center record was first created in the source system + ERZET fields). Provides the audit trail start point for SOX compliance and financial record retention requirements under 21 CFR Part 11.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code representing the primary transaction currency for this cost center (e.g., USD, EUR, GBP, JPY). Determines the currency in which budgets are set and actuals are reported.. Valid values are `^[A-Z]{3}$`',
    `department_code` STRING COMMENT 'Internal department code from the source system structure mapped to this cost center. Enables reconciliation between HR workforce cost data (the source system) and financial cost center data (the source system headcount-based cost allocation and labor cost. Valid values are `^[A-Z0-9_-]{1,20}$`',
    `fiscal_year` BIGINT COMMENT 'The fiscal year (GJAHR) for which the annual budget and planning data on this cost center record applies. Enables year-over-year budget comparison and multi-year financial trend analysis.',
    `fiscal_year_variant` STRING COMMENT 'the source system variant (PERIV) defining the fiscal year calendar structure for this cost center (e.g., K4 = calendar year Jan-Dec, V3 = April-March). Determines period mapping for financial postings and regulatory reporting timelines.. Valid values are `^[A-Z0-9]{2}$`',
    `functional_area` STRING COMMENT 'Organizational functional department associated with this cost center (e.g., Clinical Operations, Regulatory Affairs, Biostatistics, Data Management, Safety, Finance, IT). Used for cross-functional cost allocation and departmental P&L reporting.',
    `gl_account_code` STRING COMMENT 'Primary General Ledger (GL) account code in the source system with this cost center for default cost postings. Ensures financial transactions are recorded to the correct GL account in the chart of accounts for GAAP/IFRS financial statement preparation and. Valid values are `^[0-9]{6,10}$`',
    `hierarchy_area` STRING COMMENT 'The node within the standard cost center hierarchy (the source system SEGH) to which this cost center is assigned. Enables roll-up reporting by organizational unit, therapeutic area, or functional department.. Valid values are `^[A-Z0-9_-]{1,30}$`',
    `hierarchy_level` BIGINT COMMENT 'Numeric depth of this cost center within the organizational cost center hierarchy (1 = top-level division, higher numbers = more granular sub-units). Used for hierarchical roll-up in financial reporting and budget consolidation.',
    `is_intercompany` BOOLEAN COMMENT 'Indicates whether this cost center is used for intercompany transactions between legal entities within the CRO group (True) or is a standard intra-company cost center (False).',
    `is_statistical` BOOLEAN COMMENT 'Indicates whether this is a statistical cost center (True) used only for informational/reporting purposes without actual cost postings, or a real cost center (False) that receives actual financial transactions.',
    `last_modified_by_user` STRING COMMENT 'the source system of the person who last modified this cost center record. Required for SOX audit trail and ALCOA+ (Attributable) compliance. Enables identification of unauthorized changes during internal and external audits.. Valid values are `^[A-Z0-9_]{1,12}$`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this cost center record in the source system for change detection in ETL pipelines, audit trail maintenance, and SOX change management controls.',
    `lock_indicator` BOOLEAN COMMENT 'Indicates whether this cost center is locked for actual postings (True = locked, no new financial transactions permitted). Corresponds to the SPERRZ field in the source system during period-end close, audit periods, or when a cost center is under SOX',
    `cost_center_name` STRING COMMENT 'Human-readable descriptive name of the cost center (e.g., Oncology Clinical Operations, Regulatory Affairs – EU, Biostatistics & Data Management). Displayed in financial reports, dashboards, and sponsor invoicing summaries.',
    `overhead_rate_pct` DECIMAL(5,2) COMMENT 'Overhead surcharge rate (as a percentage) applied to direct costs posted to this cost center for indirect cost recovery. Used in the source system calculation schemes to compute fully-loaded project costs for sponsor invoicing and contract budget',
    `plan_lock_indicator` BOOLEAN COMMENT 'Indicates whether this cost center is locked for planning/budget postings (True = planning locked). Corresponds to the SPERP field in the source system budget modifications after the annual planning cycle is finalized.',
    `profit_center_code` STRING COMMENT 'the source system (PRCTR) to which this cost center is assigned for internal profitability analysis. Enables management reporting of revenues and costs by business segment, therapeutic area, or sponsor relationship.. Valid values are `^[A-Z0-9_-]{1,20}$`',
    `region_code` STRING COMMENT 'Geographic region code for this cost center (e.g., AMER, EMEA, APAC). Used for regional financial consolidation, multi-regional clinical trial cost allocation, and regulatory reporting segmentation across FDA, EMA, PMDA, TGA, and Health Canada. Valid values are `^[A-Z]{2,10}$`',
    `sap_object_class` STRING COMMENT 'the source system (OBART) assigned to this cost center, determining which cost accounting objects can receive allocations from it. OCCA = Cost Centers; OACC = Orders; OPRO = Projects/WBS; OSTA = Statistical Objects.. Valid values are `OCCA|OACC|OPRO|OSTA`',
    `short_name` STRING COMMENT 'Abbreviated name of the cost center used in the source system layouts and condensed financial statements where space is limited. Corresponds to the KTEXT field in the source system. Valid values are `^.{1,20}$`',
    `source_system_code` STRING COMMENT 'Identifier of the operational source system from which this cost center record was ingested (e.g., the source system, the source system). Supports data lineage tracking, multi-system reconciliation, and Silver Layer data provenance in the Databricks. Valid values are `^[A-Z0-9_-]{1,20}$`',
    `cost_center_status` STRING COMMENT 'Current lifecycle status of the cost center. active — open for postings; inactive — temporarily suspended; locked — blocked for new postings pending review; pending_activation — created but not yet approved; closed — permanently deactivated. Valid values are `active|inactive|locked|pending_activation|closed`',
    `therapeutic_area` STRING COMMENT 'Clinical therapeutic area associated with this cost center (e.g., Oncology, Neurology, Cardiovascular, Immunology, Rare Disease). Enables financial reporting and budget tracking by therapeutic area, which is a primary dimension for CRO sponsor billing and',
    `cost_center_type` STRING COMMENT 'Classification of the cost center by its cost allocation behavior. direct centers accumulate costs directly attributable to clinical trial studies or sponsors; indirect centers hold shared service costs; overhead centers capture organizational. Valid values are `direct|indirect|overhead|project|administrative`',
    `valid_from_date` DATE COMMENT 'The date from which this cost center is active and available for financial postings in the source system to the DATAB (valid-from date) field in the source system Financial transactions cannot be posted to this cost center before this date.',
    `wbs_element_code` STRING COMMENT 'the source system Structure (WBS) element code (POSID) associated with this cost center for project accounting. Links cost center expenditures to specific clinical trial project structures in the source system System), enabling study-level cost tracking. Valid values are `^[A-Z0-9._-]{1,24}$`',
    CONSTRAINT pk_cost_center PRIMARY KEY(`cost_center_id`)
) COMMENT 'Master reference for the source system centers used to allocate and track clinical trial expenditures by organizational unit, therapeutic area, or functional department.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`finance`.`gl_account` (
    `gl_account_id` BIGINT COMMENT 'Unique surrogate identifier for the General Ledger account record in the Databricks Silver Layer. Primary key for this master reference entity.',
    `cost_center_id` BIGINT COMMENT 'add column cost_center_id (BIGINT) with FK to finance.cost_center.cost_center_id — gl_account has only a self-ref FK; it should reference the cost center hierarchy for financial reporting',
    `parent_gl_account_id` BIGINT COMMENT 'Parent GL account for chart-of-accounts hierarchy',
    `account_currency` STRING COMMENT 'ISO 4217 three-letter currency code assigned to the GL account (e.g., USD, EUR, GBP). When set, all postings to this account must be in this currency. Relevant for multi-currency clinical trial sponsor invoicing and site payments.. Valid values are `^[A-Z]{3}$`',
    `account_group` STRING COMMENT 'the source system code (KTOKS) that controls the number range and field selection for GL master data maintenance. Groups accounts by functional category such as balance sheet accounts, P&L accounts, cost accounts, or clinical trial-specific categories',
    `account_hierarchy_node` STRING COMMENT 'Node identifier within the GL account hierarchy (e.g., the source system Version node or account group hierarchy) that positions this account in the reporting structure.',
    `account_long_description` STRING COMMENT 'Extended narrative description of the GL account purpose, providing additional context for financial analysts, auditors, and SOX compliance reviewers beyond the short account name.',
    `account_name` STRING COMMENT 'Short descriptive name of the GL account as maintained in the source system table). Used as the human-readable label in financial reports, trial balance, and study cost allocations.',
    `account_number` STRING COMMENT 'The externally-known GL account number as defined in the the source system of Accounts (SKA1/SKB1). This is the primary business identifier used in all journal entries, accruals, and financial postings across clinical trial studies.. Valid values are `^[0-9]{6,10}$`',
    `account_status` STRING COMMENT 'Current lifecycle status of the GL account indicating whether it is available for financial postings (active), temporarily blocked from postings (blocked), or flagged for removal from the chart of accounts (marked_for_deletion).. Valid values are `active|blocked|marked_for_deletion`',
    `account_type` STRING COMMENT 'Fundamental financial classification of the GL account indicating whether it is a balance sheet account (asset, liability, equity) or an income statement account (revenue, expense).. Valid values are `asset|liability|equity|revenue|expense`',
    `accrual_engine_relevant` BOOLEAN COMMENT 'Indicates whether this GL account participates in the source system processing for automated period-end accruals. Highly relevant for clinical trial study cost accruals such as investigator fees earned but not yet invoiced, CRO milestone accruals, and',
    `alternative_account_number` STRING COMMENT 'Country-specific or group-level alternative account number (the source system for local statutory reporting or consolidation mapping. Enables clinical trial entities operating in multiple jurisdictions to map to local chart of accounts requirements.',
    `balance_in_local_currency` BOOLEAN COMMENT 'Indicates whether this GL account only manages balances in local (company code) currency (the source system True, foreign currency transaction details are not separately tracked, which may apply to certain internal clearing accounts used in clinical',
    `chart_of_accounts` STRING COMMENT 'Four-character the source system Accounts key (e.g., INT, YCOA) that groups GL accounts under a common numbering scheme. Determines the account structure applicable across all company codes in the clinical trials enterprise.. Valid values are `^[A-Z0-9]{4}$`',
    `clinical_cost_category` STRING COMMENT 'Clinical research industry-specific cost classification applied to this GL account for study financial reporting and sponsor invoicing. Categorizes accounts into clinical trial cost buckets such as investigator grants, site management, pass-through costs',
    `commitment_item` STRING COMMENT 'Funds management commitment item linked to this GL account for budget availability control. Used in clinical trial project accounting to track committed expenditures against approved study budgets before actual invoices are posted.',
    `company_code` STRING COMMENT 'the source system code representing the legal entity for which this GL account is active. Determines the applicable accounting principles, currency, and fiscal year variant for clinical trial financial postings.. Valid values are `^[A-Z0-9]{4}$`',
    `controlling_area` STRING COMMENT 'the source system identifier to which this GL account is assigned. The controlling area defines the organizational unit for management accounting, enabling cost center allocations, internal orders, and project accounting for clinical trial studies.. Valid values are `^[A-Z0-9]{4}$`',
    `cost_element_category` STRING COMMENT 'Controlling module classification indicating whether this GL account is a primary cost element (originating from FI postings such as investigator fees, pass-through costs) or secondary cost element (internal allocations between cost centers).. Valid values are `primary|secondary|not_applicable`',
    `created_on` DATE COMMENT 'Date on which this GL account master record was first created in the source system Provides the audit trail start point for the account lifecycle, supporting SOX change management controls.',
    `field_status_group` STRING COMMENT 'the source system group (SKB1.FSTAG) that controls which fields are required, optional, or suppressed during document entry for this GL account. Ensures mandatory fields such as cost center, internal order, or WBS element are captured for clinical trial. Valid values are `^G[0-9]{3}$`',
    `financial_statement_version` STRING COMMENT 'the source system Version key that determines how this GL account is grouped and presented in statutory financial statements (balance sheet, income statement). Critical for SOX-compliant financial reporting and regulatory submissions.',
    `functional_area` STRING COMMENT 'the source system (SKA1.FUNC_AREA) that classifies the GL account by business function such as research and development, general and administrative, or sales.',
    `house_bank` STRING COMMENT 'the source system identifier (SKB1.HBKID) linked to this GL account for bank accounts. Relevant for clinical trial treasury accounts used to manage sponsor fund receipts and investigator site payment disbursements.',
    `ifrs_account_mapping` STRING COMMENT 'Mapping code linking this GL account to the corresponding IFRS disclosure line item or standard. Supports dual GAAP/IFRS reporting requirements for clinical trial organizations operating across US and international jurisdictions.',
    `interest_indicator` STRING COMMENT 'the source system (SKB1.ZINRT) that determines whether and how interest is calculated on balances in this GL account. Applicable to clinical trial escrow accounts or deferred revenue accounts holding sponsor advance payments.',
    `is_planning_blocked` BOOLEAN COMMENT 'Indicates whether cost planning is blocked for this GL account (the source system True, the account cannot be used in financial forecasting or study budget planning activities.',
    `is_posting_blocked` BOOLEAN COMMENT 'Indicates whether financial postings to this GL account are currently blocked at the company code level (the source system True, no journal entries, accruals, or study cost allocations can be posted to this account.',
    `is_reconciliation_account` BOOLEAN COMMENT 'Indicates whether this GL account is a reconciliation account for a subledger (e.g., accounts payable for investigator site payments, accounts receivable for sponsor invoicing). Reconciliation accounts cannot receive direct manual postings.',
    `is_tax_relevant` BOOLEAN COMMENT 'Indicates whether postings to this GL account are subject to tax determination. When True, a valid tax code must be entered for all financial transactions posted to this account, supporting VAT/GST compliance for international clinical trial operations.',
    `last_changed_by` STRING COMMENT 'the source system of the person who last modified this GL account master record. Supports segregation of duties and SOX audit trail requirements for chart of accounts change management.',
    `last_changed_on` DATE COMMENT 'Date on which this GL account master record was most recently modified in the source system Tracks the currency of the account definition for audit and change management purposes.',
    `line_item_display` BOOLEAN COMMENT 'Indicates whether individual line items are stored and displayable for this GL account (the source system True, detailed transaction-level audit trails are maintained, supporting SOX compliance and clinical trial cost transparency requirements.',
    `open_item_management` BOOLEAN COMMENT 'Indicates whether open item management is activated for this GL account (the source system True, individual line items remain open until cleared, enabling tracking of outstanding investigator grant payments, sponsor invoice receivables, and',
    `profit_loss_statement_account` BOOLEAN COMMENT 'Indicates whether this GL account is a profit and loss (income statement) account as opposed to a balance sheet account. P&L accounts are reset to zero at fiscal year-end during the closing process.',
    `reconciliation_account_type` STRING COMMENT 'Specifies the subledger type for which this account serves as a reconciliation account. vendor applies to accounts payable for site and investigator payments; customer applies to accounts receivable for sponsor invoicing; asset applies to fixed. Valid values are `vendor|customer|asset|not_applicable`',
    `revaluation_relevant` BOOLEAN COMMENT 'Indicates whether open items or balances in this GL account are subject to foreign currency revaluation at period-end. Applicable to clinical trial accounts holding balances in non-functional currencies such as EUR-denominated site payments or',
    `sort_key` STRING COMMENT 'the source system (SKB1.ZUAWA) that determines the allocation field populated in line items when posting to this account. Controls how line items are sorted and displayed in the GL account line item display for audit and reconciliation purposes.. Valid values are `^[0-9]{3}$`',
    `source_system_code` STRING COMMENT 'Identifier of the operational source system from which this GL account record was extracted (e.g., the source system ID or client number). Supports data lineage tracking in the Databricks Silver Layer for multi-system clinical trial financial',
    `sox_relevant` BOOLEAN COMMENT 'Indicates whether this GL account is within scope for Sarbanes-Oxley (SOX) internal controls over financial reporting. SOX-relevant accounts require documented controls, periodic reconciliation, and management sign-off as part of the clinical trials',
    `tax_category` STRING COMMENT 'the source system indicator (SKA1.MWSKZ) that controls whether and how tax codes can be entered during posting to this account. Relevant for VAT/GST compliance on cross-border clinical trial site payments and sponsor invoices.',
    `tolerance_group` STRING COMMENT 'the source system assigned to this GL account that defines acceptable variance thresholds for payment differences and clearing. Relevant for managing small discrepancies in investigator site payment reconciliations and sponsor invoice settlements.',
    `valid_from_date` DATE COMMENT 'Date from which this GL account is effective and available for financial postings. Supports time-dependent account validity for clinical trial programs that introduce new cost categories at specific study phases or fiscal periods.',
    `created_by` STRING COMMENT 'the source system of the person who created this GL account master record (SKA1.ERNAM). Supports segregation of duties controls and SOX audit trail requirements for chart of accounts maintenance.',
    CONSTRAINT pk_gl_account PRIMARY KEY(`gl_account_id`)
) COMMENT 'Master reference for General Ledger accounts used in clinical trial financial postings. Captures account number, account type (P&L vs balance sheet), account group, description, currency, and controlling area assignment per the source system of Accounts.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`finance`.`journal_entry` (
    `journal_entry_id` BIGINT COMMENT 'Unique surrogate identifier for each journal entry record in the clinical trial finance data product. Primary key for the journal_entry table in the Databricks Silver Layer.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Journal entries are posted to the source system for clinical trial cost allocation. journal_entry.cost_center_code is a denormalized string; adding cost_center_id FK normalizes this to the',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Every journal entry line posts to a General Ledger account — this is a fundamental the source system',
    `payroll_record_id` BIGINT COMMENT 'Foreign key linking to workforce.payroll_record. Business justification: Payroll journal entries must be traceable to their source payroll records for payroll posting reconciliation and SOX controls.',
    `primary_journal_employee_id` BIGINT COMMENT 'the source system ID of the individual who posted the journal entry. Mandatory for SOX segregation of duties controls, ALCOA+ attributability requirements, and 21 CFR Part 11 electronic records audit trail.',
    `sponsor_invoice_id` BIGINT COMMENT 'Foreign key linking to finance.sponsor_invoice. Business justification: Journal entry line items for AR postings (sponsor invoice issuance, payment receipts) reference the originating sponsor invoice.',
    `vendor_invoice_id` BIGINT COMMENT 'Foreign key linking to finance.vendor_invoice. Business justification: Journal entry line items for AP postings (vendor invoice receipts, goods receipts) reference the originating vendor invoice.',
    `accrual_basis` STRING COMMENT 'Indicates the basis on which an accrual journal entry was generated in the source system manually entered accruals from system-generated recurring accruals and milestone-based accruals tied to clinical trial site payment schedules.. Valid values are `manual|system_generated|recurring|milestone_based`',
    `approval_status` STRING COMMENT 'Current approval workflow status of the journal entry in the source system whether the entry has been reviewed and approved by an authorized approver as required by SOX internal controls and clinical trial financial governance policies.. Valid values are `pending|approved|rejected|not_required`',
    `approval_timestamp` TIMESTAMP COMMENT 'Timestamp when the journal entry was approved by the authorized approver in the source system SOX audit trail, segregation of duties reporting, and period-end close timeliness monitoring.',
    `company_code` STRING COMMENT 'the source system code representing the legal entity or organizational unit within the clinical trials enterprise that owns this journal entry. Enables multi-entity financial consolidation and legal entity reporting.',
    `cost_category` STRING COMMENT 'Business classification of the clinical trial cost type captured in this journal entry. Enables sponsor invoicing, budget vs. actuals analysis, and pass-through cost tracking across study sites. Aligns with clinical trial financial management taxonomy.. Valid values are `investigator_grant|site_payment|patient_stipend|pass_through|cro_fee|lab_cost`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the journal entry record was first created in the source system ALCOA+ (Attributable, Legible, Contemporaneous, Original, Accurate) audit trail requirements and SOX internal controls.',
    `credit_amount` DECIMAL(18,2) COMMENT 'The gross credit amount posted on this journal entry line in the transaction currency. Represents decreases to asset/expense accounts or increases to liability/revenue accounts.',
    `debit_amount` DECIMAL(18,2) COMMENT 'The gross debit amount posted on this journal entry line in the transaction currency. Represents increases to asset/expense accounts or decreases to liability/revenue accounts.',
    `debit_credit_indicator` STRING COMMENT 'the source system indicator for the journal entry line item. D denotes a debit posting; C denotes a credit posting. Fundamental to double-entry bookkeeping and financial statement preparation for clinical trial operations.. Valid values are `D|C`',
    `document_date` DATE COMMENT 'The date of the originating source document (e.g., invoice date, contract date, accrual date) that triggered the journal entry. May differ from posting_date when documents are processed after the originating event. Used for aging analysis and audit trail.',
    `document_number` STRING COMMENT 'The externally-known the source system document number assigned at posting time. Serves as the primary business identifier for the journal entry and is used for cross-referencing in audit trails, regulatory submissions, and SOX controls.',
    `document_type_code` STRING COMMENT 'the source system type code classifying the nature of the journal entry (e.g., SA=General Ledger, KR=Vendor Invoice, DR=Customer Invoice, AB=Accounting Document, ZP=Payment Posting). Determines number range assignment and posting rules.',
    `entry_type` STRING COMMENT 'Business classification of the journal entry indicating its purpose in the financial close process. Distinguishes original postings from period-end accruals, reversals, adjustments, reclassifications, and intercompany eliminations for clinical trial cost. Valid values are `original|reversal|accrual|adjustment|reclassification|intercompany`',
    `exchange_rate` DECIMAL(18,6) COMMENT 'The foreign currency exchange rate applied at posting time to translate transaction currency amounts to local currency. Sourced from the source system rate tables. Critical for multi-currency clinical trial financial reporting and audit trail.',
    `fiscal_period` BIGINT COMMENT 'The fiscal period (month 1–12, or 13–16 for special periods) within the fiscal year to which the journal entry is assigned. Drives period-end close, accrual reversal scheduling, and monthly financial reporting for clinical trial operations.',
    `fiscal_year` BIGINT COMMENT 'The fiscal year to which the journal entry is assigned in the source system for annual financial reporting, budget vs. actuals analysis, and SOX period-end close controls.',
    `header_text` STRING COMMENT 'Free-text description at the journal entry header level in the source system business context for the posting (e.g., Q3 site payment accrual - Study XYZ, Investigator grant milestone 2 - Site 001).',
    `internal_order_number` STRING COMMENT 'the source system order number used to collect costs for a specific clinical trial activity, investigator grant, or pass-through cost category. Complements WBS elements for granular cost tracking at the study or site level.',
    `is_reversed` BOOLEAN COMMENT 'Indicates whether this journal entry has been reversed in the source system if a reversal document exists; False otherwise. Used to exclude reversed entries from financial reporting and to identify correcting entry pairs for SOX controls.',
    `line_item_number` BIGINT COMMENT 'Sequential line item number within the journal entry document in the source system identifies each debit or credit posting line within a multi-line journal entry. Required for line-level audit trail and reconciliation.',
    `line_item_text` STRING COMMENT 'Free-text description at the individual line item level in the source system specific context for the debit or credit posting (e.g., Pass-through lab cost - Site 005, Patient stipend accrual - Period 6).',
    `local_currency_amount` DECIMAL(18,2) COMMENT 'The net journal entry amount translated into the company code local currency (functional currency) using the exchange rate applied at posting time. Used for statutory financial reporting and local regulatory compliance.',
    `local_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code of the company code local (functional) currency into which the transaction currency amounts are translated. Required for multi-currency consolidation and statutory reporting.. Valid values are `^[A-Z]{3}$`',
    `posting_date` DATE COMMENT 'The principal real-world financial event date on which the journal entry is posted to the general ledger in the source system the fiscal period and year to which the entry belongs. Critical for period-end close and SOX financial reporting controls.',
    `posting_status` STRING COMMENT 'Current lifecycle state of the journal entry within the the source system workflow. Controls whether the entry is visible in financial reporting and period-end close.. Valid values are `draft|posted|reversed|parked|held|cleared`',
    `profit_center_code` STRING COMMENT 'the source system center code representing the business segment or study portfolio unit accountable for profitability. Enables sponsor-level and study-level P&L reporting for clinical trial financial management.',
    `reference_document_number` STRING COMMENT 'External or internal reference document number associated with the journal entry (e.g., vendor invoice number, sponsor purchase order number, site payment milestone reference, or pass-through cost receipt number).',
    `reversal_date` DATE COMMENT 'The scheduled or actual date on which an accrual or adjustment journal entry is reversed in the source system to accrual entries that require automatic reversal in the subsequent fiscal period. Supports period-end close management.',
    `reversal_document_number` STRING COMMENT 'the source system number of the reversing journal entry if this entry has been reversed. Populated only for reversed entries. Supports period-end accrual reversal tracking and SOX audit trail for correcting entries.',
    `sponsor_billable` BOOLEAN COMMENT 'Indicates whether the cost or revenue captured in this journal entry is billable to the pharmaceutical or biotech sponsor under the clinical trial contract.',
    `tax_amount` DECIMAL(18,2) COMMENT 'The tax amount (VAT, GST, or withholding tax) calculated and posted on this journal entry line in the transaction currency. Supports tax reporting, cross-border payment compliance, and financial statement accuracy for global clinical trial operations.',
    `tax_code` STRING COMMENT 'the source system code associated with the journal entry line item, determining the applicable VAT/GST/withholding tax treatment. Relevant for cross-border clinical trial payments to investigators, sites, and vendors in multi-jurisdiction operations.',
    `transaction_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code of the transaction currency in which the journal entry amounts (debit/credit) are originally recorded. Supports multi-currency clinical trial operations across global sponsor and site jurisdictions.. Valid values are `^[A-Z]{3}$`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the journal entry record in the source system for change tracking, incremental data loads to the Silver Layer, and SOX audit trail completeness.',
    `wbs_element_code` STRING COMMENT 'the source system Breakdown Structure (WBS) element code linking the journal entry to a specific clinical trial project, study phase, or milestone. Enables project accounting, study budget tracking, and sponsor invoicing reconciliation.',
    CONSTRAINT pk_journal_entry PRIMARY KEY(`journal_entry_id`)
) COMMENT 'Transactional record for every financial journal entry posted in the source system clinical trial operations. Captures document number, posting date, fiscal period, document type (original, reversal, accrual), debit/credit line items, cost center, GL';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` (
    `sponsor_invoice_id` BIGINT COMMENT 'Unique surrogate identifier for the sponsor invoice or credit/debit memo record in the clinical trial financial management system. Primary key for this entity.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Sponsor invoice approval is a named billing control process in clinical trial finance. Regulatory and sponsor audits require tracing each invoice approval to a credentialed employee.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Sponsor invoices are attributed to a cost center for the source system and clinical trial financial tracking.',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Sponsor invoices post to a GL account for accounts receivable recognition. sponsor_invoice.gl_account_code is a denormalized string; adding gl_account_id FK normalizes this to the',
    `icsr_id` BIGINT COMMENT 'Foreign key linking to safety.icsr. Business justification: CRO contracts often include per-ICSR billing — sponsors are invoiced for each expedited safety report submitted.',
    `organization_contact_id` BIGINT COMMENT 'Foreign key linking to sponsor.sponsor_contact. Business justification: Invoices must be routed to the sponsors designated billing contact. sponsor_invoice.billing_contact_name and billing_contact_email are denormalized from sponsor_contact.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization to whom this invoice or credit memo is issued. Links to the sponsor master record.',
    `sdtm_dataset_id` BIGINT COMMENT 'Foreign key linking to datamanagement.sdtm_dataset. Business justification: SDTM dataset delivery is a contractual deliverable that triggers sponsor invoicing in CRO contracts.',
    `study_contract_id` BIGINT COMMENT 'Reference to the master service agreement or work order contract under which this invoice is issued. Governs payment terms, scope, and billing milestones.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study or protocol for which services were rendered and are being billed. Enables study-level revenue recognition and financial reporting.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Sponsor invoices are generated for regulatory submission services (IND preparation, NDA publishing, eCTD compilation).',
    `amount_paid` DECIMAL(18,4) COMMENT 'Total amount received from the sponsor against this invoice to date. May be less than net_amount for partially paid invoices. Expressed in invoice currency.',
    `approved_date` DATE COMMENT 'The date on which the invoice was internally approved by CRO finance management prior to submission to the sponsor. Part of the SOX financial controls audit trail.',
    `billing_period_end_date` DATE COMMENT 'The last date of the service period covered by this invoice. Defines the end of the billing window for accrual and revenue recognition purposes.',
    `billing_period_start_date` DATE COMMENT 'The first date of the service period covered by this invoice. Together with billing_period_end_date, defines the time window for which clinical trial services are being billed.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this invoice record was first created in the system. Supports audit trail, data lineage, and SOX financial reporting controls.',
    `credit_memo_ref_invoice_number` STRING COMMENT 'For credit memos and debit memos, the invoice_number of the original invoice being adjusted. Establishes the audit trail linking adjustments to originating billing documents.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the invoice (e.g., USD, EUR, GBP, JPY). Determines the denomination of all monetary amounts on this invoice.. Valid values are `^[A-Z]{3}$`',
    `discount_amount` DECIMAL(18,4) COMMENT 'Total contractual or negotiated discount applied to the gross invoice amount. Reduces the net billable amount. Expressed in the invoice currency.',
    `dispute_reason` STRING COMMENT 'Categorizes the reason for a billing dispute raised by the sponsor. Populated when payment_status is disputed. Drives dispute resolution workflow and root cause analysis.. Valid values are `scope_dispute|pricing_error|missing_backup|duplicate_invoice|unauthorized_charges|other`',
    `dispute_resolution_date` DATE COMMENT 'The date on which a billing dispute was formally resolved between the CRO and the sponsor. Populated when dispute_reason is set and the dispute is closed.',
    `document_type` STRING COMMENT 'Classifies the billing document as a standard invoice for services rendered, a credit memo reducing amounts owed, or a debit memo for additional charges. Drives the source system logic.. Valid values are `invoice|credit_memo|debit_memo`',
    `due_date` DATE COMMENT 'The date by which full payment is contractually required from the sponsor. Calculated from invoice_date plus payment terms. Drives AR aging buckets and collections escalation.',
    `exchange_rate` DECIMAL(18,6) COMMENT 'Exchange rate applied to convert the invoice currency to the CRO functional currency (typically USD) at the time of invoice creation. Required for multi-currency consolidation and GAAP/IFRS foreign currency translation.',
    `functional_currency_amount` DECIMAL(18,4) COMMENT 'Net invoice amount converted to the CROs functional currency using the exchange_rate. Used for consolidated financial reporting, SOX controls, and management accounting.',
    `gross_amount` DECIMAL(18,4) COMMENT 'Total pre-tax, pre-discount amount of all billable services and pass-through costs included in this invoice before any adjustments. Expressed in the invoice currency.',
    `invoice_date` DATE COMMENT 'The official date the invoice was issued to the sponsor. Used as the principal business event date for revenue recognition, aging calculations, and regulatory reporting.',
    `invoice_description` STRING COMMENT 'Free-text description of the services, milestones, or deliverables covered by this invoice. Provides context for sponsor review, dispute resolution, and audit documentation.',
    `invoice_number` STRING COMMENT 'Externally-visible, human-readable invoice number assigned by the CRO billing system and communicated to the sponsor. Used for sponsor remittance matching and dispute resolution. Format: INV-YYYY-NNNNNN.. Valid values are `^INV-[0-9]{4}-[0-9]{6}$`',
    `is_pass_through` BOOLEAN COMMENT 'Indicates whether this invoice (or a portion thereof) represents pass-through costs incurred on behalf of the sponsor (e.g., lab fees, site payments, travel) that are billed at cost without markup. Affects revenue recognition and margin reporting.',
    `net_amount` DECIMAL(18,4) COMMENT 'Total amount due from the sponsor after applying discounts and adding taxes (gross_amount - discount_amount + tax_amount). This is the amount the sponsor is obligated to pay. Expressed in the invoice currency.',
    `outstanding_balance` DECIMAL(18,4) COMMENT 'Remaining unpaid balance on this invoice (net_amount - amount_paid). Drives AR aging reports, collections prioritization, and bad debt provisioning. Expressed in invoice currency.',
    `pass_through_amount` DECIMAL(18,4) COMMENT 'The portion of the gross invoice amount attributable to pass-through costs billed at cost to the sponsor. Segregated for revenue recognition, margin analysis, and sponsor reporting. Expressed in invoice currency.',
    `payment_received_date` DATE COMMENT 'The date on which cash payment was received from the sponsor and applied to this invoice. Used for cash flow reporting, DSO (Days Sales Outstanding) calculation, and AR clearance.',
    `payment_status` STRING COMMENT 'Current lifecycle state of the invoice in the accounts receivable workflow. Drives AR aging, collections follow-up, and revenue recognition reporting. [ENUM-REF-CANDIDATE: draft|submitted|disputed|paid|partially_paid|cancelled — promote to reference',
    `payment_terms_code` STRING COMMENT 'the source system code defining the contractual payment schedule (e.g., NET30, NET45, NET60, 2/10NET30). Determines due date calculation and early payment discount eligibility.',
    `ref` STRING COMMENT 'The sponsors own reference or tracking number assigned to this invoice in their accounts payable system. Facilitates cross-system reconciliation and dispute resolution.',
    `revenue_recognition_method` STRING COMMENT 'The accounting method applied to recognize revenue for this invoice per GAAP ASC 606 / IFRS 15. Determines how and when revenue is recorded in the financial statements.. Valid values are `milestone|percentage_of_completion|time_and_materials|fixed_fee|pass_through`',
    `sap_ar_document_number` STRING COMMENT 'The the source system receivable document number generated upon posting of this invoice. Serves as the system-of-record identifier for GL reconciliation, audit trails, and SOX compliance.',
    `sap_company_code` STRING COMMENT 'the source system code identifying the legal entity of the CRO issuing this invoice. Required for entity-level financial reporting, intercompany reconciliation, and SOX controls.',
    `sponsor_po_number` STRING COMMENT 'The sponsors internal purchase order number referencing this invoice. Required by most pharmaceutical sponsors for invoice processing and payment authorization. Critical for remittance matching.',
    `submitted_date` DATE COMMENT 'The date the invoice was formally submitted to the sponsor for payment. Marks the start of the payment terms clock and is used for AR aging and collections tracking.',
    `tax_amount` DECIMAL(18,4) COMMENT 'Total tax (VAT, GST, withholding tax, or other applicable taxes) applied to the invoice. Computed based on sponsor jurisdiction and applicable tax codes. Expressed in the invoice currency.',
    `tax_code` STRING COMMENT 'the source system identifying the applicable tax jurisdiction and rate for this invoice (e.g., V1 for standard VAT, A0 for zero-rated). Drives automated tax calculation and regulatory tax reporting.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this invoice record. Supports change tracking, audit trail, and SOX financial reporting controls.',
    `wbs_element` STRING COMMENT 'the source system Breakdown Structure element code linking this invoice to a specific project task or deliverable. Enables granular project accounting and milestone-based billing tracking.',
    CONSTRAINT pk_sponsor_invoice PRIMARY KEY(`sponsor_invoice_id`)
) COMMENT 'Master record for invoices and credit memos issued to pharmaceutical and biotech sponsors for clinical trial services rendered. Captures document type (invoice, credit memo, debit memo), invoice number, sponsor reference, study association, billing';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`finance`.`invoice_line` (
    `invoice_line_id` BIGINT COMMENT 'Unique surrogate identifier for each invoice line item record in the clinical trial billing system. Primary key for the invoice_line data product.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Invoice line approval is part of the billing review and dispute resolution process. Linking to the approving employee supports audit trails for sponsor billing governance.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Invoice line items are attributed to a cost center for granular cost allocation and the source system posting.',
    `deliverable_id` BIGINT COMMENT 'Foreign key linking to agreement.deliverable. Business justification: Invoice lines bill for specific contractual deliverables. Direct traceability from invoice line to deliverable is required for sponsor dispute resolution, revenue recognition under ASC',
    `finance_billing_milestone_id` BIGINT COMMENT 'Reference to the study or site payment milestone that triggered this billing line item, such as patient enrollment, database lock, or regulatory submission milestones.',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Invoice line items post to a GL account for revenue recognition and AR line-item accounting.',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_panel. Business justification: Central lab invoices bill at panel level. Linking invoice_line to lab_panel enables reconciliation of billed panels against the protocol lab schedule, detection of overbilling, and',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor being billed for this line item. Enables sponsor-level financial reporting and accounts receivable tracking.',
    `proposal_line_id` BIGINT COMMENT 'Foreign key linking to sponsor.proposal_line. Business justification: Invoice lines must reference the originating proposal line for scope validation, billing authorization, and out-of-scope billing identification.',
    `rate_card_id` BIGINT COMMENT 'Foreign key linking to agreement.rate_card. Business justification: Invoice lines must be priced at contracted rate card rates. A direct FK enables billing audit — verifying that unit_price on each invoice line matches the applicable rate card rate.',
    `sponsor_invoice_id` BIGINT COMMENT 'Reference to the parent sponsor invoice header to which this line item belongs. Establishes the header-detail relationship for billing reconciliation.',
    `study_contract_id` BIGINT COMMENT 'Reference to the master service agreement or work order contract under which this billing line item is authorized. Ensures billing is contractually grounded for SOX compliance.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) associated with this invoice line item. Links billing activity to the specific trial being conducted for the sponsor.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site associated with this invoice line item, applicable for site-level charges such as investigator grants, site management fees, and pass-through costs.',
    `accrual_amount` DECIMAL(18,2) COMMENT 'Revenue or cost accrual amount recognized for this line item in the current accounting period, supporting period-end financial close and SOX-compliant accrual accounting for unbilled clinical trial services.',
    `accrual_period` STRING COMMENT 'Accounting period (YYYY-MM format) in which the accrual for this line item is recognized. Used for period-end financial close, revenue recognition scheduling, and SOX reporting.. Valid values are `^d{4}-(0[1-9]|1[0-2])$`',
    `approval_status` STRING COMMENT 'Internal approval status of this invoice line item prior to sponsor submission. Reflects the internal finance review and authorization workflow required for SOX compliance.. Valid values are `pending|approved|rejected|on_hold`',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time when this invoice line item was approved for sponsor billing. Provides an audit trail for SOX financial controls and internal authorization workflows.',
    `billing_category` STRING COMMENT 'High-level classification of the type of charge being billed on this line item. Drives financial reporting segmentation and sponsor audit support. [ENUM-REF-CANDIDATE. Valid values are `professional_fee|pass_through|investigator_grant|lab_fee|patient_stipend|regulatory_fee`',
    `billing_period_end` DATE COMMENT 'End date of the service period covered by this invoice line item. Defines the close of the billing window for time-based or recurring charges.',
    `billing_period_start` DATE COMMENT 'Start date of the service period covered by this invoice line item. Defines the beginning of the billing window for time-based or recurring charges.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this invoice line item record was first created in the system. Provides the audit trail entry point for SOX compliance and data lineage tracking.',
    `credit_note_ref` STRING COMMENT 'Reference number of the credit note issued to reverse or adjust this invoice line item. Populated when a billing correction or sponsor credit is applied.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which this invoice line item is denominated (e.g., USD, EUR, GBP, JPY). Supports multi-currency sponsor billing across global clinical trials.. Valid values are `^[A-Z]{3}$`',
    `discount_amount` DECIMAL(18,2) COMMENT 'Contractual discount or credit applied to this line item, reducing the gross billed amount. May reflect volume discounts, sponsor negotiated rates, or contractual adjustments.',
    `dispute_reason` STRING COMMENT 'Description of the reason provided by the sponsor or internal finance team for disputing this invoice line item. Populated when line_status is disputed. Supports billing reconciliation and sponsor audit support.',
    `is_billable` BOOLEAN COMMENT 'Indicates whether this line item is billable to the sponsor. Non-billable lines may represent internal cost tracking, write-offs, or contractually excluded activities.',
    `is_pass_through` BOOLEAN COMMENT 'Indicates whether this line item represents a pass-through cost being recharged to the sponsor at cost without markup. Drives separate financial reporting for pass-through versus professional fee revenue.',
    `line_amount` DECIMAL(18,2) COMMENT 'Gross billed amount for this line item before any adjustments, discounts, or taxes. Calculated as quantity multiplied by unit_price. Represents the primary monetary value of the line.',
    `line_item_number` STRING COMMENT 'Externally visible alphanumeric identifier for this invoice line item as it appears on the sponsor-facing invoice document. Used for sponsor reference and dispute resolution.',
    `line_number` BIGINT COMMENT 'Sequential position number of this line item within the parent invoice. Used to order and reference individual billing items during sponsor audit and reconciliation.',
    `line_status` STRING COMMENT 'Current workflow status of this invoice line item. Tracks the lifecycle from initial creation through sponsor approval, dispute resolution, or cancellation.. Valid values are `draft|pending_approval|approved|disputed|credited|cancelled`',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this invoice line item record was last modified. Supports audit trail requirements, change tracking, and SOX financial controls.',
    `net_amount` DECIMAL(18,2) COMMENT 'Net billed amount for this line item after applying discounts and adjustments but before tax. Equals line_amount minus discount_amount. Used for revenue recognition and accounts receivable.',
    `pass_through_invoice_ref` STRING COMMENT 'Reference number of the original vendor invoice being passed through to the sponsor. Enables three-way matching between vendor invoice, CRO accounts payable, and sponsor billing for audit purposes.',
    `pass_through_vendor` STRING COMMENT 'Name of the third-party vendor whose costs are being passed through to the sponsor on this line item (e.g., central laboratory, imaging vendor, courier). Applicable only for pass-through billing category lines.',
    `quantity` DECIMAL(18,4) COMMENT 'Number of units, events, patients, visits, or other countable items being billed on this line item. Combined with unit_price to derive the line amount.',
    `revenue_recognition_method` STRING COMMENT 'Method used to recognize revenue for this billing line item per GAAP ASC 606 / IFRS 15 requirements. Determines when and how revenue is recorded in the financial statements.. Valid values are `milestone|percentage_of_completion|time_and_materials|fixed_fee|pass_through`',
    `service_code` STRING COMMENT 'Standardized code identifying the specific service, activity, or cost type being billed, aligned with the contract work breakdown structure (WBS) and the source system catalog.',
    `service_delivery_date` DATE COMMENT 'Date on which the service, milestone, or deliverable associated with this billing line was completed or delivered. Used as the principal business event date for revenue recognition and audit.',
    `service_description` STRING COMMENT 'Human-readable description of the service, activity, or cost item being billed on this line. Appears on the sponsor-facing invoice and supports billing reconciliation and audit.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Tax amount applied to this invoice line item based on the applicable tax code and jurisdiction. Includes VAT, GST, or withholding tax as applicable per sponsor country.',
    `tax_code` STRING COMMENT 'the source system code identifying the applicable tax rate and jurisdiction rules for this line item. Determines VAT, GST, or withholding tax treatment based on sponsor country and service type.',
    `total_amount` DECIMAL(18,2) COMMENT 'Total billed amount for this line item inclusive of taxes. Equals net_amount plus tax_amount. Represents the final amount due from the sponsor for this specific billing item.',
    `unit_of_measure` STRING COMMENT 'Unit in which the billed quantity is expressed (e.g., each, patient, visit, hour, day, month, kit). Defines the billing granularity for this line item. [ENUM-REF-CANDIDATE: each|patient|visit|hour|day|month|kit — 7 candidates stripped; promote to',
    `unit_price` DECIMAL(18,4) COMMENT 'Contracted price per unit for the service or cost item on this line, as agreed in the master service agreement or work order. Multiplied by quantity to derive the line amount.',
    `visit_name` STRING COMMENT 'Name or identifier of the clinical study visit (e.g., Screening, Week 4, End of Treatment) associated with this billing line item, applicable for per-visit billing milestones.',
    `wbs_element` STRING COMMENT 'the source system Breakdown Structure element code that maps this billing line to the project accounting hierarchy for the clinical trial, enabling granular cost tracking by study phase and activity.',
    CONSTRAINT pk_invoice_line PRIMARY KEY(`invoice_line_id`)
) COMMENT 'Line-item detail for each sponsor invoice, capturing the specific service, milestone, or pass-through cost being billed. Includes line number, service description, billing category (professional fees, pass-through, investigator grant reimbursement, lab';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`finance`.`site_payment` (
    `site_payment_id` BIGINT COMMENT 'Unique surrogate identifier for each site payment disbursement record in the clinical trial finance system. Primary key for this transactional entity.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Site payment approval is a named investigator grant disbursement control process. Clinical trial finance requires an auditable link from each site payment to the authorizing employee for',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Site payments to investigational sites are charged to a cost center for the source system',
    `finance_billing_milestone_id` BIGINT COMMENT 'Reference to the specific payment milestone, per-procedure fee, or per-visit fee schedule item defined in the clinical trial agreement that triggered this disbursement.',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Site payments post to a GL account for accounts payable and investigator grant expense recognition.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor funding the clinical trial. Used to associate the site payment with the correct sponsor for pass-through cost invoicing and financial reporting.',
    `original_payment_site_payment_id` BIGINT COMMENT 'Self-referencing identifier pointing to the original site_payment record that this record reverses or amends. Null for original payments; populated only when reversal_indicator is True.',
    `site_agreement_id` BIGINT COMMENT 'Reference to the Clinical Trial Agreement (CTA) or investigator grant agreement under which this payment is being made. Establishes the contractual basis for the disbursement.',
    `site_monitoring_visit_id` BIGINT COMMENT 'Foreign key linking to monitoring.monitoring_visit. Business justification: Site initiation, per-patient, and close-out visit completions are direct triggers for investigator grant payments.',
    `study_budget_id` BIGINT COMMENT 'Foreign key linking to finance.study_budget. Business justification: Site payments (investigator grants, milestone payments) draw from the study budget allocation (study_budget.investigator_grant_amount).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) for which this site payment is being disbursed. Links the financial disbursement to the governing study protocol.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site (clinical trial site) receiving this payment. The site is the primary counterparty for this financial disbursement.',
    `vendor_invoice_id` BIGINT COMMENT 'Reference to the sponsor invoice against which this site payment is being charged or reconciled. Links the disbursement to the outbound billing cycle for pass-through cost recovery.',
    `accrual_period` STRING COMMENT 'Accounting period (YYYY-MM) in which this site payment expense is accrued for financial reporting purposes, which may differ from the actual payment date. Supports month-end close and SOX-compliant accrual accounting.. Valid values are `^d{4}-(0[1-9]|1[0-2])$`',
    `bank_account_reference` STRING COMMENT 'Masked or tokenized reference to the investigational site bank account used for this disbursement, as registered in the source system banking details. Full account details are stored in the secure banking master;',
    `bank_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the bank where the sites receiving account is held. Used for cross-border payment routing, SWIFT/SEPA determination, and withholding tax jurisdiction assessment.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this site payment record was first created in the data platform, sourced from the source system audit trail, SOX compliance, and data lineage tracking.',
    `ctms_payment_ref` STRING COMMENT 'Cross-reference identifier from the source system linking this financial disbursement record to the corresponding milestone completion event tracked in the clinical trial management system. Enables finance-to-operations reconciliation.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the payment currency (e.g., USD, EUR, GBP, JPY). Determines the currency in which the site bank account is credited.. Valid values are `^[A-Z]{3}$`',
    `exchange_rate` DECIMAL(18,8) COMMENT 'Exchange rate applied to convert the payment currency to the functional currency at the time of disbursement. Sourced from the source system rate tables.',
    `functional_currency_amount` DECIMAL(18,4) COMMENT 'Net payment amount converted to the sponsor or CRO functional currency (typically USD) using the exchange rate applied at the time of payment. Used for consolidated financial reporting and SOX controls.',
    `is_advance_payment` BOOLEAN COMMENT 'Indicates whether this disbursement is an advance payment (True) made to the site prior to milestone completion, requiring future reconciliation against earned milestones, or a standard post-completion payment (False).',
    `is_pass_through` BOOLEAN COMMENT 'Indicates whether this payment represents a pass-through cost (True) that will be recharged to the sponsor, as opposed to a CRO-absorbed investigator grant payment (False). Drives sponsor invoicing and cost recovery workflows.',
    `net_payment_amount` DECIMAL(18,4) COMMENT 'Net amount actually disbursed to the investigational site after deduction of withholding tax (payment_amount minus withholding_tax_amount). This is the amount credited to the site bank account.',
    `payment_amount` DECIMAL(18,4) COMMENT 'Gross payment amount disbursed to the investigational site before any withholding tax or deductions, expressed in the payment currency. Represents the base financial obligation per the clinical trial agreement.',
    `payment_approval_date` DATE COMMENT 'Date on which the site payment was formally approved by the authorized finance approver in the the source system prior to disbursement. Required for SOX dual-control compliance.',
    `payment_date` DATE COMMENT 'The actual calendar date on which the payment was disbursed to the investigational site. This is the principal real-world event date for the financial transaction, as recorded in the source system',
    `payment_method` STRING COMMENT 'Instrument or mechanism used to disburse the payment to the investigational site (e.g., wire transfer, ACH, check, SEPA credit transfer, SWIFT). Determines the clearing channel and settlement timeline.. Valid values are `wire|ACH|check|SEPA|SWIFT|EFT`',
    `payment_number` STRING COMMENT 'Externally-known, human-readable payment reference number assigned by the source system Payable at the time of disbursement. Used for reconciliation with site bank statements and sponsor invoicing. Corresponds to the the source system number.',
    `payment_reference_note` STRING COMMENT 'Free-text reference note or remittance advice text included with the payment to the site, identifying the study, milestone, or invoice being paid. Appears on the bank transfer or check stub.',
    `payment_status` STRING COMMENT 'Current lifecycle state of the site payment disbursement within the the source system Drives reconciliation and financial reporting. [ENUM-REF-CANDIDATE: pending|approved|processed|paid|cancelled|on_hold|reversed — promote to reference product]',
    `payment_type` STRING COMMENT 'Classification of the payment by the type of clinical trial activity it compensates: milestone-based, per-procedure fee, per-visit fee, site startup, study closeout, pass-through cost reimbursement, patient stipend, or overhead.',
    `payment_value_date` DATE COMMENT 'The bank value date on which funds are credited to the sites bank account, which may differ from the payment_date (posting date) due to banking clearing cycles. Used for cash flow forecasting and bank reconciliation.',
    `reconciliation_date` DATE COMMENT 'Date on which the site payment was confirmed as reconciled against the site bank statement or clinical trial agreement milestone. Populated when reconciliation_status transitions to reconciled.',
    `reconciliation_status` STRING COMMENT 'Current reconciliation state of the site payment against the sites bank statement confirmation and the clinical trial agreement milestone schedule. Drives the finance teams month-end close and audit readiness.. Valid values are `unreconciled|reconciled|disputed|partial|written_off`',
    `reversal_indicator` BOOLEAN COMMENT 'Indicates whether this payment record represents a reversal (True) of a previously posted payment, used to correct erroneous disbursements. Reversed payments must be linked to the original via original_payment_id.',
    `sap_ap_document_number` STRING COMMENT 'the source system Payable document number generated when the payment was posted. Serves as the primary cross-reference between the clinical trial finance data product and the ERP system of record for audit and SOX compliance.',
    `sap_payment_run_reference` STRING COMMENT 'Identifier of the the source system payment program run (F110) that generated this disbursement. Enables batch-level reconciliation and audit tracing of grouped payment runs.',
    `sap_vendor_code` STRING COMMENT 'the source system master record identifier for the investigational site or principal investigator entity receiving the payment. Used to match the payment to the correct payee in the ERP.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this site payment record in the data platform. Tracks status changes, reconciliation updates, and corrections for audit and SOX compliance.',
    `wbs_element` STRING COMMENT 'the source system System Work Breakdown Structure (WBS) element code identifying the specific project task or deliverable this payment is charged against. Enables granular project accounting and sponsor cost reporting.',
    `withholding_tax_amount` DECIMAL(18,4) COMMENT 'Amount of withholding tax deducted from the gross payment prior to disbursement, as required by applicable tax jurisdiction rules. Zero if no withholding tax applies.',
    `withholding_tax_code` STRING COMMENT 'the source system tax code identifying the applicable tax type and rate configuration for this payment. Used for tax reporting (e.g., IRS Form 1042-S, local equivalents).',
    `withholding_tax_rate` DECIMAL(7,4) COMMENT 'Percentage rate of withholding tax applied to the gross payment amount, as determined by the applicable tax treaty or local tax regulation for the sites jurisdiction. Expressed as a decimal (e.g., 0.3000 = 30%).',
    CONSTRAINT pk_site_payment PRIMARY KEY(`site_payment_id`)
) COMMENT 'Transactional record for payments disbursed to investigational sites against completed milestones, per-procedure fees, and per-visit fees as defined in the clinical trial agreement.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` (
    `patient_stipend_id` BIGINT COMMENT 'Unique system-generated identifier for each patient stipend or reimbursement payment record. Primary key for the patient_stipend data product.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Patient stipend approval is a named IRB/FMV compliance process. Linking to the approving employee supports fair market value compliance audits and IRB reporting requirements.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: Stipend payment eligibility requires verified active consent — finance must confirm the subject held valid consent at time of payment.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Patient stipend payments are charged to a cost center for clinical trial subject cost tracking.',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: Stipend budget management requires tying each payment to the specific enrollment record — critical for re-screened subjects who enroll multiple times and for per-enrollment stipend cap',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Patient stipends post to a GL account for subject reimbursement expense recognition. patient_stipend.gl_account_code is a denormalized string; adding gl_account_id FK normalizes this to',
    `reissue_of_stipend_id` BIGINT COMMENT 'Reference to the original patient_stipend_id that this record replaces or reissues (e.g., due to lost check, failed bank transfer, or payment correction). Enables payment lineage tracking and prevents duplicate disbursement.',
    `study_budget_id` BIGINT COMMENT 'Foreign key linking to finance.study_budget. Business justification: Patient stipend payments draw from the study budget allocation (study_budget.patient_stipend_amount tracks the total allocated for stipends).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this stipend payment is issued. Links the payment to the governing study protocol and sponsor agreement.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigative site at which the subject is enrolled and where the stipend obligation originates. Used for site-level financial reporting and budget reconciliation.',
    `study_visit_schedule_id` BIGINT COMMENT 'Foreign key linking to study.study_visit_schedule. Business justification: Patient stipends are paid per protocol-defined visit. study_visit_schedule defines the visit type and FMV-compliant stipend rate.',
    `subject_visit_id` BIGINT COMMENT 'Reference to the specific scheduled or unscheduled study visit that triggered this stipend payment. Enables visit-level payment tracking and protocol compliance verification.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (patient) receiving the stipend or reimbursement. Core party reference linking the payment to the enrolled participant.',
    `accrual_period` STRING COMMENT 'Accounting period (YYYY-MM) in which the stipend expense is accrued for financial reporting purposes, which may differ from the payment date. Supports month-end close and sponsor invoicing accruals.. Valid values are `^[0-9]{4}-(0[1-9]|1[0-2])$`',
    `approval_date` DATE COMMENT 'Date on which the stipend payment was formally approved by the authorized approver (e.g., site coordinator, finance manager) prior to disbursement. Supports SOX dual-control and audit trail requirements.',
    `cancellation_reason` STRING COMMENT 'Free-text explanation for why a stipend payment was cancelled or placed on hold. Populated only when payment_status is cancelled or on_hold. Required for audit trail and compliance documentation.',
    `country_code` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code of the site where the subject is enrolled. Determines applicable tax regulations, currency, and local payment compliance requirements.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this stipend payment record was first created in the system. Supports audit trail requirements under 21 CFR Part 11, ALCOA+ principles, and SOX financial record-keeping controls.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the payment amount (e.g., USD, EUR, GBP). Required for multi-currency study operations and financial consolidation in the source system. Valid values are `^[A-Z]{3}$`',
    `fmv_compliant` BOOLEAN COMMENT 'Indicates whether the stipend payment amount is within the approved fair market value range as reviewed by the IRB/IEC. A value of True confirms compliance; False triggers a compliance review workflow.',
    `fmv_rate` DECIMAL(18,4) COMMENT 'Approved fair market value rate for this stipend type as established by the IRB/IEC and sponsor. Used to validate that payment amounts comply with regulatory guidelines preventing undue inducement of study participation.',
    `irb_approval_reference` STRING COMMENT 'Reference number of the IRB/IEC approval that authorized the subject payment plan for this study. Confirms that the stipend structure has been reviewed and approved by the ethics committee as required by GCP.',
    `net_payment_amount` DECIMAL(18,4) COMMENT 'Actual amount disbursed to the subject after tax withholding deductions. Equals payment_amount minus tax_withheld_amount. Used for subject-facing payment confirmation and financial reconciliation.',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, special handling instructions, or contextual information related to this stipend payment record. Not used for audit trail purposes.',
    `payment_amount` DECIMAL(18,4) COMMENT 'Gross stipend or reimbursement amount to be paid to the subject before any applicable tax withholding. Expressed in the payment currency. Used for budget tracking and FMV compliance assessment.',
    `payment_date` DATE COMMENT 'Calendar date on which the stipend payment was or is scheduled to be disbursed to the subject. Used for financial period accruals, cash flow reporting, and subject retention tracking.',
    `payment_method` STRING COMMENT 'Mechanism used to disburse the stipend to the subject. Determines the downstream payment processing workflow and compliance requirements for subject payment programs.. Valid values are `prepaid_card|check|bank_transfer|digital_wallet|money_order`',
    `payment_processor` STRING COMMENT 'Name of the third-party payment processing vendor or financial institution used to disburse the stipend (e.g., Greenphire ClinCard, BioClinica, bank name). Supports vendor management and reconciliation.',
    `payment_reference_number` STRING COMMENT 'External payment processor or bank reference number assigned upon successful disbursement (e.g., ACH trace number, check number, prepaid card transaction ID). Used for payment reconciliation and dispute resolution.',
    `payment_status` STRING COMMENT 'Current lifecycle state of the stipend payment record within the payment workflow. Drives operational processing, financial accruals, and reconciliation activities in the source system. Valid values are `pending|approved|processed|paid|cancelled|on_hold`',
    `protocol_number` STRING COMMENT 'Sponsor-assigned protocol identifier for the clinical study under which this stipend is issued. Enables direct cross-referencing with regulatory submissions and sponsor financial reporting without requiring a join.',
    `receipt_received` BOOLEAN COMMENT 'Indicates whether the required supporting receipt or documentation has been received from the subject prior to payment processing. Blocks payment disbursement when receipt_required is True and this flag is False.',
    `receipt_required` BOOLEAN COMMENT 'Indicates whether supporting documentation (e.g., travel receipt, parking receipt) is required to process this reimbursement payment. Applicable primarily to expense reimbursement stipend types.',
    `stipend_number` STRING COMMENT 'Externally-visible, human-readable reference number assigned to this stipend payment record, used for cross-system reconciliation and subject communication. Sourced from the source system payable module.. Valid values are `^STI-[0-9]{4}-[0-9]{6}$`',
    `stipend_type` STRING COMMENT 'Classification of the stipend or reimbursement category. Determines the nature of the payment for fair market value (FMV) compliance, tax reporting, and budget allocation.. Valid values are `participation_fee|travel_reimbursement|meal_allowance|lodging_reimbursement|caregiver_allowance|incidental_expense`',
    `subject_consent_verified` BOOLEAN COMMENT 'Indicates whether the subjects valid informed consent (ICF) has been verified as current and on file prior to processing this stipend payment. Ensures payment is only made to consented participants.',
    `subject_number` STRING COMMENT 'Protocol-assigned subject identification number (e.g., site-subject number in format SSSXXX) used to identify the subject in study records without exposing personal identity. Enables cross-system traceability while maintaining subject pseudonymization.',
    `tax_form_type` STRING COMMENT 'Type of tax reporting form applicable to this stipend payment based on jurisdiction and payment classification. Populated only when tax_reportable is True. Supports year-end tax compliance reporting.. Valid values are `1099-MISC|1099-NEC|W-2|none|other`',
    `tax_reportable` BOOLEAN COMMENT 'Indicates whether this stipend payment is subject to tax reporting obligations (e.g., IRS Form 1099-MISC in the U.S.). Drives year-end tax reporting processes and subject tax notification workflows.',
    `tax_withheld_amount` DECIMAL(18,4) COMMENT 'Amount of tax withheld from the gross stipend payment prior to disbursement to the subject. Applicable where local tax regulations require withholding on research participation payments.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this stipend payment record. Required for change tracking, data lineage, and SOX audit trail compliance in the Silver Layer lakehouse.',
    `visit_completion_date` DATE COMMENT 'Date on which the associated study visit was completed by the subject, triggering the stipend payment obligation. Establishes the business event date distinct from the payment disbursement date.',
    `wbs_element` STRING COMMENT 'the source system Work Breakdown Structure element code used to allocate the stipend cost to a specific study activity or deliverable. Enables granular project accounting and sponsor pass-through billing.',
    CONSTRAINT pk_patient_stipend PRIMARY KEY(`patient_stipend_id`)
) COMMENT 'Transactional record for stipend and reimbursement payments made to trial subjects (patients) for study participation, travel, and incidental expenses. Captures subject reference, study visit association, stipend type (participation fee, travel';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`finance`.`purchase_order` (
    `purchase_order_id` BIGINT COMMENT 'Unique surrogate identifier for the purchase order record in the clinical trials finance data lakehouse (Silver Layer). Primary key.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: PO approval is a named procurement control process. Clinical trial finance requires an auditable link from each PO to the authorizing employee for spend governance and SOX compliance.',
    `bioanalytical_assay_id` BIGINT COMMENT 'Foreign key linking to laboratory.bioanalytical_assay. Business justification: POs for DMPK/PK studies are issued for specific validated bioanalytical assays.',
    `cost_center_id` BIGINT COMMENT 'Reference to the internal cost center responsible for this purchase order, used for project accounting and financial reporting in the source system',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Purchase orders reference a GL account for the source system assignment and commitment tracking.',
    `investigational_product_id` BIGINT COMMENT 'Foreign key linking to study.investigational_product. Business justification: Purchase orders for IP manufacturing, packaging, labeling, and distribution reference the specific investigational product.',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: Sponsors and CROs issue purchase orders to central labs for analytical services. Linking purchase_order to lab_facility enables procurement tracking, budget commitment by facility',
    `study_budget_id` BIGINT COMMENT 'Foreign key linking to finance.study_budget. Business justification: Purchase orders are issued against study budgets and consume committed budget amounts. The PO has wbs_element which maps to study_budget.wbs_element_code.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study or trial protocol this purchase order supports. Enables study-level cost tracking and sponsor invoicing reconciliation.',
    `subcontract_id` BIGINT COMMENT 'Foreign key linking to agreement.subcontract. Business justification: POs are raised to fund subcontracted vendor services in clinical trials. Each PO must reference the subcontract authorizing the spend — required for three-way match (PO/GR/invoice)',
    `vendor_id` BIGINT COMMENT 'Reference to the vendor or service provider (e.g., central lab, imaging CRO, specialty vendor, courier) to whom this purchase order is issued.',
    `accrual_amount` DECIMAL(18,2) COMMENT 'The financial accrual amount recognized for this purchase order in the current accounting period, representing goods/services received but not yet invoiced. Supports GAAP/IFRS period-end close and SOX financial reporting.',
    `approval_date` DATE COMMENT 'The date on which the purchase order received final approval through the the source system strategy workflow. Used for SOX controls and procurement cycle time analytics.',
    `approval_status` STRING COMMENT 'Current status of the purchase order within the the source system workflow (release strategy). Tracks whether the PO has been approved by all required authorization levels per SOX segregation of duties controls.. Valid values are `pending|approved|rejected|escalated`',
    `cancellation_reason` STRING COMMENT 'Free-text reason provided when a purchase order is cancelled. Required for audit trail, procurement analytics, and SOX controls documentation. Populated only when po_status is cancelled.',
    `company_code` STRING COMMENT 'the source system code representing the legal entity issuing this purchase order. Required for entity-level financial reporting, SOX controls, and multi-entity consolidation.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this purchase order record was first created in the system (the source system the lakehouse Silver Layer). Required for audit trail, SOX controls, and ALCOA+ data integrity compliance.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the purchase order (e.g., USD, EUR, GBP). Required for multi-currency clinical trial financial management and sponsor invoicing.. Valid values are `^[A-Z]{3}$`',
    `delivery_date` DATE COMMENT 'The date by which goods or services are requested to be delivered or completed by the vendor. Used for supply chain scheduling and clinical trial operational planning.',
    `delivery_terms` STRING COMMENT 'International commercial terms (Incoterms) governing delivery obligations, risk transfer, and cost allocation between the CRO and vendor (e.g., EXW, FOB, CIF, DDP). Relevant for clinical supply chain and central lab shipments.',
    `exchange_rate` DECIMAL(18,6) COMMENT 'The foreign currency exchange rate applied at the time of PO creation to convert the PO currency to the company code functional currency (e.g., USD). Required for multi-currency financial consolidation and reporting.',
    `functional_currency_amount` DECIMAL(18,2) COMMENT 'The net PO amount converted to the companys functional currency (typically USD) using the exchange rate at PO creation. Used for consolidated financial reporting and SOX controls.',
    `goods_receipt_date` DATE COMMENT 'The date on which goods or services were confirmed as received from the vendor. Used for accrual period determination, invoice matching, and accounts payable processing.',
    `goods_receipt_status` STRING COMMENT 'Indicates whether goods or services ordered under this PO have been received: not received, partially received, or fully received. Drives accounts payable invoice matching (3-way match) and accrual calculations in the source system. Valid values are `not_received|partially_received|fully_received`',
    `invoice_status` STRING COMMENT 'Current accounts payable invoice processing status for this purchase order. Tracks whether vendor invoices have been received, matched, and processed against the PO in the source system. Valid values are `not_invoiced|partially_invoiced|fully_invoiced|disputed`',
    `invoiced_amount` DECIMAL(18,2) COMMENT 'Cumulative amount invoiced by the vendor against this purchase order to date, in PO currency. Used to calculate open commitment (PO value minus invoiced amount) for accrual and financial forecasting.',
    `net_amount` DECIMAL(18,2) COMMENT 'The net total value of the purchase order after discounts and adjustments but before tax. Represents the accounts payable obligation and is used for accrual calculations and sponsor invoicing.',
    `pass_through_flag` BOOLEAN COMMENT 'Indicates whether the costs under this purchase order are pass-through expenses to be recharged directly to the sponsor (True) or absorbed as CRO operational costs (False). Critical for sponsor invoicing and budget reconciliation.',
    `payment_terms` STRING COMMENT 'Contractual payment terms agreed with the vendor (e.g., Net 30, Net 60, 2/10 Net 30). Drives accounts payable scheduling and cash flow forecasting in the source system',
    `po_date` DATE COMMENT 'The business date on which the purchase order was formally issued to the vendor. This is the principal real-world event date for the procurement transaction, distinct from the system creation timestamp.',
    `po_gross_amount` DECIMAL(18,2) COMMENT 'The total gross value of the purchase order before any discounts, taxes, or adjustments, expressed in the PO currency. Represents the full procurement commitment.',
    `po_number` STRING COMMENT 'Externally-known, human-readable purchase order number assigned by the source system module (e.g., PO-2024-000123). Used in vendor communications, accounts payable matching, and audit trails.. Valid values are `^PO-[0-9]{4}-[0-9]{6}$`',
    `po_status` STRING COMMENT 'Current lifecycle status of the purchase order, tracking progression from draft through approval, issuance, goods/service receipt, and closure or cancellation.',
    `po_type` STRING COMMENT 'Classification of the purchase order by procurement instrument type: standard (single delivery), blanket (multiple releases against a ceiling), framework (master agreement call-off), service (service entry sheet-based), or emergency (expedited. Valid values are `standard|blanket|framework|service|emergency`',
    `purchasing_group` STRING COMMENT 'the source system group (buyer group) code identifying the team or individual buyer responsible for managing this purchase order.',
    `purchasing_org` STRING COMMENT 'the source system organization code responsible for negotiating and issuing this purchase order. Represents the organizational unit with procurement authority.',
    `sap_mm_document_number` STRING COMMENT 'The the source system Management (MM) module document reference number for this purchase order (EKKO table key). Enables traceability back to the system of record for audit and reconciliation.',
    `service_description` STRING COMMENT 'Free-text description of the goods or services being procured under this purchase order (e.g., Central laboratory specimen processing services for Phase III oncology study). Provides business context for audit and reporting.',
    `sponsor_billable_flag` BOOLEAN COMMENT 'Indicates whether this purchase orders costs are billable to the pharmaceutical or biotech sponsor under the clinical trial agreement. Drives sponsor invoicing and accounts receivable processes.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Total tax amount applicable to this purchase order (e.g., VAT, GST, sales tax) as calculated in the source system for accounts payable tax compliance and financial reporting.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this purchase order record was last modified in the Silver Layer. Supports change data capture, audit trail, and SOX financial reporting controls.',
    `vendor_category` STRING COMMENT 'Classification of the vendor type for this purchase order, enabling spend analytics by vendor category across clinical trial operations. [ENUM-REF-CANDIDATE',
    `vendor_quote_number` STRING COMMENT 'The vendors quotation or proposal reference number that this purchase order is based upon. Enables traceability from PO back to the sourcing event and vendor bid documentation.',
    `wbs_element` STRING COMMENT 'the source system System (PS) Work Breakdown Structure (WBS) element code linking this purchase order to a specific clinical trial project task or deliverable for project accounting and sponsor cost reporting.',
    `created_by` STRING COMMENT 'the source system ID of the individual who created this purchase order record. Required for SOX audit trail, segregation of duties compliance, and 21 CFR Part 11 electronic records.',
    CONSTRAINT pk_purchase_order PRIMARY KEY(`purchase_order_id`)
) COMMENT 'Master record for purchase orders issued to vendors and service providers supporting clinical trial operations (e.g., central labs, imaging CROs, specialty vendors, courier services).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` (
    `vendor_invoice_id` BIGINT COMMENT 'Unique surrogate identifier for the vendor invoice record in the clinical trials finance system (the source system key for the vendor_invoice data product.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Vendor invoice approval (3-way match sign-off) is a named AP control process. Regulatory audits and SOX require tracing each invoice approval to a specific credentialed employee.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Vendor invoices are attributed to a cost center for the source system and clinical trial expenditure tracking.',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Vendor invoices post to a GL account for accounts payable recognition. vendor_invoice.gl_account_code is a denormalized string; adding gl_account_id FK normalizes this to the authoritative',
    `investigational_site_id` BIGINT COMMENT 'Reference to the clinical trial site associated with this invoice, where applicable (e.g., site-specific pass-through costs, investigator grants). Nullable for non-site-specific vendor invoices.',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: Central lab facilities submit invoices for analytical services. Linking vendor_invoice to lab_facility enables AP reconciliation, three-way match against lab POs, and pass-through',
    `purchase_order_id` BIGINT COMMENT 'Reference to the associated purchase order against which this vendor invoice is matched. Supports three-way match (PO/GR/invoice) validation required for SOX-compliant accounts payable processing.',
    `rems_program_id` BIGINT COMMENT 'Foreign key linking to regulatory.rems_program. Business justification: REMS programs involve third-party administrators, call centers, and patient support vendors who submit invoices against the REMS program.',
    `site_monitoring_visit_id` BIGINT COMMENT 'Foreign key linking to monitoring.monitoring_visit. Business justification: CRO vendor invoices for monitoring services (per-visit fees, CRA travel) reference the specific monitoring visit being billed.',
    `specimen_shipment_id` BIGINT COMMENT 'Foreign key linking to laboratory.specimen_shipment. Business justification: Courier vendors invoice per specimen shipment. Linking vendor_invoice to specimen_shipment enables reconciliation of courier invoices against actual shipments, detection of',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) to which this vendor invoice is allocated. Enables study-level cost tracking, budget vs. actuals reporting, and sponsor pass-through cost recovery.',
    `subcontract_id` BIGINT COMMENT 'Foreign key linking to agreement.subcontract. Business justification: Vendor invoices from subcontractors (labs, imaging vendors, eCOA providers) must reference the subcontract they bill against for three-way match validation and sponsor pass-through',
    `vendor_id` BIGINT COMMENT 'Reference to the vendor (supplier/service provider) who issued this invoice. Links to the vendor master record for CROs, labs, site management organizations, and other clinical trial service providers.',
    `accrual_flag` BOOLEAN COMMENT 'Indicates whether this vendor invoice has been accrued in the financial statements prior to receipt of the actual invoice. Supports period-end accrual management, reversal processing, and accurate financial reporting under GAAP/IFRS.',
    `accrual_period` STRING COMMENT 'The accounting period (YYYY-MM) in which the expense was accrued, if accrual_flag is True. Used for accrual reversal matching, period-end close reconciliation, and financial reporting accuracy.. Valid values are `^d{4}-(0[1-9]|1[0-2])$`',
    `approval_date` DATE COMMENT 'The date on which the vendor invoice was formally approved for payment by the authorized approver. Part of the SOX-compliant AP approval workflow audit trail.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when the vendor invoice record was first created in the clinical trials finance system. Supports audit trail, data lineage, and SOX-compliant record management per ALCOA+ principles.',
    `currency_code` STRING COMMENT 'The ISO 4217 three-letter currency code in which the vendor invoice is denominated (e.g., USD, EUR, GBP, JPY). Required for multi-currency AP processing and foreign exchange revaluation in global clinical trials.. Valid values are `^[A-Z]{3}$`',
    `dispute_reason` STRING COMMENT 'Description of the reason for disputing the vendor invoice when invoice_status is disputed. Captures the nature of the discrepancy (e.g., price variance, quantity mismatch, service not rendered, duplicate invoice) for resolution tracking.',
    `due_date` DATE COMMENT 'The date by which payment must be made to the vendor per the agreed payment terms. Calculated from invoice date or receipt date plus payment terms. Drives cash flow forecasting and early payment discount capture.',
    `early_payment_discount_amount` DECIMAL(18,2) COMMENT 'The cash discount amount available if payment is made within the early payment discount period as defined in the payment terms. Supports working capital optimization and discount capture reporting.',
    `exchange_rate` DECIMAL(18,6) COMMENT 'The exchange rate applied to convert the invoice currency to the company code local currency at the time of posting. Required for multi-currency financial reporting and foreign exchange gain/loss calculation.',
    `goods_receipt_number` STRING COMMENT 'The the source system number for the goods receipt or service entry sheet that confirms delivery of goods or services against the purchase order. Required for three-way match validation in the source system',
    `gross_amount` DECIMAL(18,2) COMMENT 'The total gross amount of the vendor invoice before tax deductions or discounts, as stated on the invoice document. Represents the base amount for three-way match validation and accounts payable liability.',
    `invoice_date` DATE COMMENT 'The date printed on the vendors invoice document, representing the principal business event date. Used for payment terms calculation, accrual period determination, and aging analysis.',
    `invoice_description` STRING COMMENT 'Free-text description of the goods or services covered by the vendor invoice, as provided by the vendor or entered by the AP team. Supports invoice review, audit, and spend categorization.',
    `invoice_number` STRING COMMENT 'The externally-assigned invoice number as printed on the vendors invoice document. Used for vendor reconciliation, dispute resolution, and audit trail. This is the business identifier issued by the vendor.',
    `invoice_status` STRING COMMENT 'Current lifecycle status of the vendor invoice through the accounts payable workflow. Drives AP processing, payment scheduling, and cash flow management. [ENUM-REF-CANDIDATE: received|under_review|approved|posted|disputed|paid|cancelled — promote to',
    `invoice_type` STRING COMMENT 'Classification of the vendor invoice by document type. Distinguishes standard invoices, credit/debit memos, pro-forma invoices, recurring service invoices, and pass-through cost invoices billable to sponsors.. Valid values are `standard|credit_memo|debit_memo|pro_forma|recurring|pass_through`',
    `is_pass_through` BOOLEAN COMMENT 'Indicates whether this vendor invoice represents a pass-through cost that is billable to the sponsor for reimbursement. Pass-through costs (e.g., lab fees, imaging, IRB fees) are tracked separately for sponsor invoicing and cost recovery.',
    `local_currency_amount` DECIMAL(18,2) COMMENT 'The net invoice amount converted to the company code local currency using the exchange rate at posting date. Used for consolidated financial reporting, budget vs. actuals analysis, and SOX financial controls.',
    `net_amount` DECIMAL(18,2) COMMENT 'The net payable amount of the vendor invoice after tax adjustments and applicable discounts. Represents the actual cash outflow obligation. Equals gross_amount minus tax_amount (where tax is excluded) or as defined by invoice terms.',
    `payment_block_indicator` STRING COMMENT 'Indicates whether the invoice is blocked from payment processing and the reason for the block. Blocked invoices require resolution before inclusion in payment runs. Supports AP workflow management and SOX controls.. Valid values are `unblocked|manual_block|dispute_block|compliance_block`',
    `payment_date` DATE COMMENT 'The actual date on which payment was made to the vendor. Populated upon payment execution. Used for cash flow reporting, days payable outstanding (DPO) calculation, and vendor payment performance analysis.',
    `payment_document_number` STRING COMMENT 'The the source system document number generated when the vendor invoice is cleared through a payment run. Populated after payment execution; null for unpaid invoices. Used for payment reconciliation and audit trail.',
    `payment_method` STRING COMMENT 'The method by which payment will be or was made to the vendor (e.g., wire transfer, ACH, check). Sourced from vendor master or overridden at invoice level. Drives payment run configuration in the source system. Valid values are `wire_transfer|ach|check|credit_card|direct_debit`',
    `payment_terms_code` STRING COMMENT 'The the source system key defining the payment schedule, discount periods, and due date calculation rules (e.g., NET30, NET45, 2/10NET30). Sourced from the vendor master or purchase order.',
    `posting_date` DATE COMMENT 'The date the vendor invoice was posted to the general ledger in the source system the accounting period for financial reporting, accruals, and SOX-compliant period-end close.',
    `receipt_date` DATE COMMENT 'The date the vendor invoice was physically or electronically received by the clinical trials organization. Used to calculate payment due dates based on payment terms and for aging analysis.',
    `sap_fi_document_number` STRING COMMENT 'The the source system document number assigned upon posting of the vendor invoice in the source system as the system-of-record reference for financial audit and reconciliation purposes.',
    `service_category` STRING COMMENT 'Business classification of the clinical trial service or goods category covered by this invoice (e.g., CRO services, central laboratory, imaging, IRB fees, drug supply, site management). Supports spend analytics and budget category reporting.',
    `sponsor_reimbursement_status` STRING COMMENT 'Tracks the reimbursement status of pass-through costs with the sponsor. Applicable only when is_pass_through is True. Drives sponsor invoicing, accounts receivable follow-up, and pass-through cost recovery reporting.. Valid values are `not_applicable|pending|invoiced|reimbursed|disputed`',
    `tax_amount` DECIMAL(18,2) COMMENT 'The total tax amount (VAT, GST, withholding tax, or other applicable taxes) included in or associated with the vendor invoice. Required for tax compliance reporting and recoverable tax tracking.',
    `three_way_match_status` STRING COMMENT 'Status of the three-way match validation between the purchase order (PO), goods receipt (GR), and vendor invoice. Fully matched invoices are eligible for payment posting. Exceptions require AP team resolution before payment.. Valid values are `not_started|po_matched|gr_matched|fully_matched|exception`',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when the vendor invoice record was last modified in the clinical trials finance system. Supports change tracking, audit trail, and SOX-compliant record management per ALCOA+ principles.',
    `vendor_reference_number` STRING COMMENT 'The vendors own internal reference or contract number associated with this invoice, as provided by the vendor. Used for vendor reconciliation, dispute resolution, and cross-referencing with vendor accounts receivable records.',
    `wbs_element` STRING COMMENT 'The the source system WBS element to which the vendor invoice cost is assigned. Enables project-level cost tracking, budget vs. actuals reporting, and sponsor billing reconciliation at the study activity level.',
    CONSTRAINT pk_vendor_invoice PRIMARY KEY(`vendor_invoice_id`)
) COMMENT 'Transactional record for invoices received from external vendors and service providers for clinical trial-related goods and services, including pass-through costs billable to sponsors.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`finance`.`accrual` (
    `accrual_id` BIGINT COMMENT 'Unique system-generated identifier for each financial accrual record posted in the clinical trial accounting system (the source system module). Serves as the primary key for this entity.',
    `investigational_site_id` BIGINT COMMENT 'FK from accrual_fk_extension: investigational_site_id',
    `trial_subject_id` BIGINT COMMENT 'FK from accrual_fk_extension: trial_subject_id',
    `vendor_invoice_id` BIGINT COMMENT 'finance.vendor_invoice.vendor_invoice_id',
    `agreement_billing_milestone_id` BIGINT COMMENT 'Foreign key linking to agreement.billing_milestone. Business justification: Accruals for partially-completed billing milestones are a standard CRO month-end close process.',
    `agreement_investigator_grant_id` BIGINT COMMENT 'Foreign key linking to agreement.investigator_grant. Business justification: Investigator grant accruals are booked monthly based on site activity against the grant schedule. Linking accruals to the specific investigator grant enables grant spend vs.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Accrual approval is a SOX-controlled month-end close process in clinical trial finance. The approving employee must be traceable for audit.',
    `arm_id` BIGINT COMMENT 'FK from accrual_fk_extension: arm_id',
    `audit_id` BIGINT COMMENT 'Foreign key linking to compliance.audit. Business justification: Audit service costs (external GCP auditors, CRO audit fees) are accrued monthly before invoices arrive.',
    `bioanalytical_assay_id` BIGINT COMMENT 'FK from accrual_fk_extension: bioanalytical_assay_id',
    `budget_line_id` BIGINT COMMENT 'description',
    `change_order_id` BIGINT COMMENT 'FK from accrual_fk_extension: change_order_id',
    `clinical_program_id` BIGINT COMMENT 'FK from accrual_fk_extension: clinical_program_id',
    `compliance_capa_id` BIGINT COMMENT 'FK from accrual_fk_extension: compliance_capa_id',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Period-end accruals are posted to a specific cost center in the source system is a denormalized string; adding cost_center_id FK normalizes this to the authoritative',
    `country_id` BIGINT COMMENT 'Foreign key linking to study.study_country. Business justification: Country-level accruals are a standard clinical trials finance process — regulatory fees, country-specific site costs, and local lab costs are accrued by country.',
    `database_lock_event_id` BIGINT COMMENT 'Foreign key linking to biostatistics.database_lock_event. Business justification: Database lock triggers accrual true-ups and reversals: open biostatistics/data management accruals are reversed upon DBL confirmation.',
    `deliverable_id` BIGINT COMMENT 'FK from accrual_fk_extension: deliverable_id',
    `dosing_regimen_id` BIGINT COMMENT 'FK from accrual_fk_extension: dosing_regimen_id',
    `dsmb_review_id` BIGINT COMMENT 'Foreign key linking to safety.dsmb_review. Business justification: DSMB meetings generate direct costs: independent member honoraria, unblinded statistician fees, data package preparation. Finance accrues these per meeting.',
    `edc_study_build_id` BIGINT COMMENT 'FK from accrual_fk_extension: edc_study_build_id',
    `enrollment_id` BIGINT COMMENT 'FK from accrual_fk_extension: enrollment_id',
    `epoch_id` BIGINT COMMENT 'Foreign key linking to study.study_epoch. Business justification: Accruals are calculated by study epoch — treatment epoch costs accrue differently from screening or follow-up.',
    `finance_billing_milestone_id` BIGINT COMMENT 'FK from accrual_fk_extension: finance_billing_milestone_id',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Accruals are posted to a GL account for period-end cost recognition. accrual.gl_account_code is a denormalized string; adding gl_account_id FK normalizes this to the authoritative',
    `icf_amendment_id` BIGINT COMMENT 'FK from accrual_fk_extension: icf_amendment_id',
    `investigational_product_id` BIGINT COMMENT 'Foreign key linking to study.investigational_product. Business justification: IP-related accruals (drug supply costs, comparator drug costs, placebo manufacturing) reference the specific investigational product.',
    `primary_investigational_site_id` BIGINT COMMENT 'description',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: Month-end accruals for central lab services are posted per facility (samples received but not yet invoiced).',
    `lab_panel_id` BIGINT COMMENT 'FK from accrual_fk_extension: lab_panel_id',
    `monitoring_cra_assignment_id` BIGINT COMMENT 'FK from accrual_fk_extension: monitoring_cra_assignment_id',
    `monitoring_plan_id` BIGINT COMMENT 'FK from accrual_fk_extension: monitoring_plan_id',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor funding the clinical trial. Used to allocate accruals to the correct sponsor contract and support sponsor invoicing reconciliation.',
    `pipeline_asset_id` BIGINT COMMENT 'FK from accrual_fk_extension: pipeline_asset_id',
    `pk_sampling_schedule_id` BIGINT COMMENT 'FK from accrual_fk_extension: pk_sampling_schedule_id',
    `program_development_milestone_id` BIGINT COMMENT 'Foreign key linking to program.program_milestone. Business justification: Clinical trial accruals are frequently triggered by program milestones (first patient in, database lock, regulatory submission).',
    `proposal_line_id` BIGINT COMMENT 'FK from accrual_fk_extension: proposal_line_id',
    `protocol_id` BIGINT COMMENT 'FK from accrual_fk_extension: protocol_id',
    `protocol_lab_schedule_id` BIGINT COMMENT 'FK from accrual_fk_extension: protocol_lab_schedule_id',
    `purchase_order_id` BIGINT COMMENT 'Foreign key linking to finance.purchase_order. Business justification: Accruals in clinical trials are frequently tied to open purchase orders (goods/services received but not yet invoiced).',
    `rate_card_id` BIGINT COMMENT 'FK from accrual_fk_extension: rate_card_id',
    `regulatory_commitment_id` BIGINT COMMENT 'Foreign key linking to regulatory.commitment. Business justification: Post-approval regulatory commitments (PMC studies, REMS assessments, annual safety reports) generate ongoing accruals for labor and vendor costs.',
    `scope_of_work_id` BIGINT COMMENT 'FK from accrual_fk_extension: scope_of_work_id',
    `site_agreement_id` BIGINT COMMENT 'FK from accrual_fk_extension: site_agreement_id',
    `site_monitoring_visit_id` BIGINT COMMENT 'Foreign key linking to monitoring.monitoring_visit. Business justification: Monitoring cost accruals (CRA fees, travel, per-visit charges) are substantiated by completed monitoring visits.',
    `specimen_collection_id` BIGINT COMMENT 'FK from accrual_fk_extension: specimen_collection_id',
    `specimen_shipment_id` BIGINT COMMENT 'FK from accrual_fk_extension: specimen_shipment_id',
    `sponsor_invoice_id` BIGINT COMMENT 'Reference to the actual vendor or site invoice that settles this accrual once received and processed. Populated during the accrual-to-actual reconciliation process; null if no invoice has been matched yet.',
    `study_budget_id` BIGINT COMMENT 'Reference to the study or site budget record against which this accrual is tracked. Enables budget-to-actual variance analysis and financial forecasting for the clinical trial.',
    `study_contract_id` BIGINT COMMENT 'Reference to the executed contract (e.g., Clinical Trial Agreement, Site Budget Agreement, vendor service agreement) that governs the cost being accrued. Supports contractual obligation tracking and accrual substantiation.',
    `study_id` BIGINT COMMENT 'BIGINT',
    `study_protocol_amendment_id` BIGINT COMMENT 'FK from accrual_fk_extension: study_protocol_amendment_id',
    `study_site_id` BIGINT COMMENT 'site.study_site.study_site_id',
    `study_visit_schedule_id` BIGINT COMMENT 'FK from accrual_fk_extension: study_visit_schedule_id',
    `subject_visit_id` BIGINT COMMENT 'FK from accrual_fk_extension: subject_visit_id',
    `treatment_arm_id` BIGINT COMMENT 'FK from accrual_fk_extension: treatment_arm_id',
    `billing_trial_subject_id` BIGINT COMMENT 'description',
    `vendor_id` BIGINT COMMENT 'finance.vendor.vendor_id',
    `original_vendor_invoice_id` BIGINT COMMENT 'description',
    `visit_procedure_id` BIGINT COMMENT 'FK from accrual_fk_extension: visit_procedure_id',
    `amount` DECIMAL(18,2) COMMENT 'The gross accrual amount in the transaction currency representing the estimated clinical trial cost incurred but not yet invoiced for the accrual period. This is the primary financial figure for the accrual entry.',
    `amount_usd` DECIMAL(18,2) COMMENT 'The accrual amount converted to US Dollars (USD) using the period-end exchange rate. Used for consolidated financial reporting and sponsor invoicing in USD-denominated contracts.',
    `approval_date` DATE COMMENT 'The date on which the accrual entry received formal financial approval from the authorized reviewer. Supports SOX period-end close timeline compliance and audit trail requirements.',
    `basis` STRING COMMENT 'The methodology used to calculate and recognize the accrual amount. Enrollment-based accruals are driven by subject counts; visit-based by completed protocol visits; milestone-based by contractual deliverable completion; time-based by elapsed period. Valid values are `enrollment_based|visit_based|milestone_based|time_based|unit_based`',
    `calculation_method` STRING COMMENT 'The method used to derive the accrual amount. Manual entries are prepared by finance staff; system_calculated entries are generated by the source system engine; spreadsheet_upload entries are imported from Excel models; ctms_derived entries are sourced. Valid values are `manual|system_calculated|spreadsheet_upload|ctms_derived|edl_feed`',
    `company_code` STRING COMMENT 'The the source system code representing the legal entity within the CRO organization that is recognizing the accrual. Enables multi-entity financial consolidation and intercompany accrual management.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when the accrual record was first created in the source system. Supports audit trail requirements under SOX, 21 CFR Part 11, and ALCOA+ data integrity principles.',
    `cumulative_accrual_amount` DECIMAL(18,2) COMMENT 'The total accrual amount accumulated from study start through the current accrual period for the same cost category and study/site combination. Supports budget-to-actual tracking and study-level financial forecasting.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the transaction currency in which the accrual amount is denominated (e.g., USD, EUR, GBP, JPY). Required for multi-currency clinical trial financial operations.. Valid values are `^[A-Z]{3}$`',
    `accrual_description` STRING COMMENT 'Free-text narrative describing the nature and business justification of the accrual entry. Provides context for auditors, finance reviewers, and SOX controls testing. Should reference the specific service, period, and study activity being accrued.',
    `exchange_rate` DECIMAL(18,6) COMMENT 'The foreign currency exchange rate applied to convert the transaction currency accrual amount to USD for consolidated reporting. Sourced from the source system rate tables at period-end.',
    `fiscal_year` STRING COMMENT 'The fiscal year (YYYY) in which the accrual is recognized. Used for annual financial reporting, budget-to-actual analysis, and year-end close procedures in the source system. Valid values are `^[0-9]{4}$`',
    `is_pass_through` BOOLEAN COMMENT 'Indicates whether the accrual represents a pass-through cost that will be recharged to the sponsor at actual cost without markup. True = pass-through cost; False = direct CRO service cost. Affects sponsor invoicing and revenue recognition.',
    `is_sox_controlled` BOOLEAN COMMENT 'Indicates whether this accrual entry is subject to Sarbanes-Oxley (SOX) internal controls testing and documentation requirements. True = SOX-controlled accrual requiring documented review and approval; False = non-SOX accrual.',
    `number` STRING COMMENT 'Externally-visible, human-readable business identifier for the accrual entry, used in financial reporting, audit trails, and cross-system reconciliation. Follows the format ACR-YYYY-NNNNNN.. Valid values are `^ACR-[0-9]{4}-[0-9]{6}$`',
    `period` STRING COMMENT 'The accounting period (YYYY-MM) for which the accrual is recognized. Determines the financial reporting period in which the clinical trial cost is recorded, critical for period-end close accuracy and SOX compliance.. Valid values are `^[0-9]{4}-(0[1-9]|1[0-2])$`',
    `posting_date` DATE COMMENT 'The date on which the accrual journal entry was posted to the the source system Ledger. This is the principal business event date for the accrual transaction and determines the accounting period assignment.',
    `prepared_by` STRING COMMENT 'Name or employee identifier of the finance analyst or accountant who prepared and submitted the accrual entry. Required for SOX segregation of duties and audit trail documentation.',
    `prior_period_accrual_amount` DECIMAL(18,2) COMMENT 'The accrual amount recognized in the immediately preceding accounting period for the same cost category and study/site combination. Used to calculate period-over-period variance and support accrual roll-forward analysis.',
    `reversal_date` DATE COMMENT 'The date on which the accrual entry is scheduled to be automatically reversed in the source system set to the first day of the following accounting period to offset the accrual when the actual invoice is received.',
    `reversal_document_number` STRING COMMENT 'The the source system document number of the reversal journal entry that offsets this accrual. Populated after the reversal is executed; null if the accrual has not yet been reversed.',
    `sap_fi_document_number` STRING COMMENT 'The the source system Accounting (FI) document number assigned when the accrual journal entry is posted in the general ledger. Used for cross-referencing between the data lakehouse and the ERP system of record.',
    `accrual_status` STRING COMMENT 'Current workflow state of the accrual entry within the period-end close process. Draft entries are under preparation; posted entries have been recorded in the GL; reversed entries have been offset; adjusted entries have been corrected; approved entries. Valid values are `draft|posted|reversed|adjusted|approved|cancelled`',
    `supporting_units` DECIMAL(18,4) COMMENT 'The quantity of activity units (e.g., enrolled subjects, completed visits, monitoring days, lab samples) used as the basis for calculating the accrual amount. Provides the quantitative driver behind enrollment-based, visit-based, or unit-based accruals.',
    `accrual_type` STRING COMMENT 'Classification of the nature of the clinical trial cost being accrued. Drives GL account mapping and financial reporting categorization. [ENUM-REF-CANDIDATE',
    `unit_rate` DECIMAL(18,4) COMMENT 'The per-unit cost rate applied to supporting units to calculate the accrual amount (accrual_amount = supporting_units × unit_rate). Sourced from the executed site budget or investigator grant agreement.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp of the most recent modification to the accrual record. Tracks changes to accrual amounts, status, or supporting data as part of the period-end close process and SOX audit trail.',
    `variance_amount` DECIMAL(18,2) COMMENT 'The difference between the accrual amount and the actual invoice amount when the invoice is received and matched. A positive variance indicates over-accrual; negative indicates under-accrual. Used for accrual accuracy monitoring and process improvement.',
    `variance_explanation` STRING COMMENT 'Free-text explanation of the variance between the accrual amount and the actual invoice amount. Required for material variances exceeding the defined threshold as part of SOX controls and period-end close procedures.',
    `wbs_element` STRING COMMENT 'the source system Work Breakdown Structure (WBS) element code that maps the accrual to a specific project task or deliverable within the clinical trial project accounting hierarchy.',
    CONSTRAINT pk_accrual PRIMARY KEY(`accrual_id`)
) COMMENT 'Transactional record for financial accruals posted at period-end to recognize clinical trial costs incurred but not yet invoiced. Captures accrual type (site services, CRA monitoring, lab fees, investigator grants), accrual basis (enrollment-based';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` (
    `revenue_recognition_id` BIGINT COMMENT 'Unique surrogate identifier for each revenue recognition event record in the clinical trial financial system. Primary key for the revenue_recognition data product.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Revenue recognition approval under ASC 606/IFRS 15 is a named SOX-controlled process in clinical trial finance. The approving employee must be traceable for external audit.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Revenue recognition events are attributed to a cost center for the source system Accounting and Reporting) integration.',
    `database_lock_event_id` BIGINT COMMENT 'Foreign key linking to biostatistics.database_lock_event. Business justification: Under ASC 606/IFRS 15, database lock is a performance obligation completion event for CROs, triggering revenue recognition for biostatistics/data management services.',
    `deliverable_id` BIGINT COMMENT 'Foreign key linking to agreement.deliverable. Business justification: Revenue recognition events are triggered by deliverable acceptance under ASC 606. Linking revenue_recognition to the specific accepted deliverable provides the audit trail required for',
    `evidence_tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: ASC 606 and SOX controls require documented evidence that a performance obligation was completed before revenue is recognized.',
    `finance_billing_milestone_id` BIGINT COMMENT 'Foreign key linking to finance.finance_billing_milestone. Business justification: Revenue recognition events are often triggered by billing milestone completions.',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Revenue recognition events post to a GL account for deferred/recognized revenue accounting.',
    `interim_analysis_id` BIGINT COMMENT 'Foreign key linking to biostatistics.interim_analysis. Business justification: Interim analysis delivery is a distinct performance obligation in CRO contracts under ASC 606.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor entity funding the clinical trial. Supports sponsor-level revenue aggregation, invoicing, and financial reporting.',
    `original_recognition_revenue_recognition_id` BIGINT COMMENT 'For reversal entries (reversal_flag = True), references the revenue_recognition_id of the original recognition event being reversed. Enables complete audit trail linking reversals to their source entries for SOX compliance.',
    `program_development_milestone_id` BIGINT COMMENT 'Foreign key linking to program.program_milestone. Business justification: ASC 606/IFRS 15 revenue recognition in clinical trials is milestone-based. Program milestones (phase completion, regulatory submission) trigger recognition events.',
    `regulatory_approval_id` BIGINT COMMENT 'Foreign key linking to regulatory.approval. Business justification: Under ASC 606/IFRS 15, regulatory approval is a performance obligation completion event that triggers revenue recognition in CRO contracts.',
    `scope_of_work_id` BIGINT COMMENT 'Foreign key linking to agreement.scope_of_work. Business justification: ASC 606 revenue recognition in CRO operations is performed at the performance obligation level, which maps to SOW service categories.',
    `study_contract_id` BIGINT COMMENT 'Reference to the sponsor contract (master service agreement or work order) under which clinical trial services are being delivered and revenue is being recognized. Ties the recognition event to the governing commercial agreement.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) for which services are being delivered and revenue is being recognized. Enables study-level revenue reporting and sponsor billing reconciliation.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Protocol amendments modify contract performance obligations under ASC 606/IFRS 15, requiring revenue recognition adjustments.',
    `accrual_flag` BOOLEAN COMMENT 'Indicates whether this recognition event represents an accrual entry (True) or an actual posted recognition (False). Accrual entries are created at period-end for services delivered but not yet formally invoiced or milestone-triggered.',
    `approval_timestamp` TIMESTAMP COMMENT 'The date and time when the revenue recognition event was approved by the finance controller. Provides the precise approval event timestamp for SOX audit trail and segregation of duties documentation.',
    `completion_percentage` DECIMAL(7,4) COMMENT 'The estimated percentage of the performance obligation completed as of the recognition date, expressed as a decimal (e.g., 0.6500 = 65.00%). Drives the percentage-of-completion revenue recognition calculation.',
    `contract_modification_flag` BOOLEAN COMMENT 'Indicates whether this recognition event was triggered by or resulted from a contract modification (change order, scope amendment) to the sponsor agreement (True) or is a standard recognition event (False).',
    `contract_value` DECIMAL(18,2) COMMENT 'The total transaction price allocated to this performance obligation under the sponsor contract, as defined in ASC 606 Step 4. Represents the full expected revenue for the obligation over the contract term.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this revenue recognition record was first created in the system. Provides the audit trail creation timestamp for SOX compliance and data lineage tracking in the Databricks Silver layer.',
    `cumulative_recognized_amount` DECIMAL(18,2) COMMENT 'The total revenue recognized to date for this performance obligation from contract inception through the current recognition date. Used to calculate remaining revenue to be recognized and to validate percentage-of-completion calculations against contract',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this recognition record (e.g., USD, EUR, GBP, JPY). Supports multi-currency sponsor contracts and foreign currency translation for consolidated financial reporting.. Valid values are `^[A-Z]{3}$`',
    `deferred_revenue_balance` DECIMAL(18,2) COMMENT 'The remaining unrecognized contract liability (deferred revenue) for this performance obligation as of the recognition date. Calculated as contract_value minus cumulative_recognized_amount. Reported on the balance sheet as a liability until earned.',
    `deliverable_description` STRING COMMENT 'Free-text description of the clinical trial service deliverable or milestone associated with this recognition event (e.g., Site Initiation Visit completion, Interim Clinical Study Report delivery, Database Lock).',
    `fiscal_period` STRING COMMENT 'The fiscal year and month (YYYY-MM) to which this revenue recognition event belongs. Used for period-close reporting, accrual reconciliation, and SOX financial controls. Derived from recognition_date but stored explicitly for reporting efficiency.. Valid values are `^[0-9]{4}-(0[1-9]|1[0-2])$`',
    `fiscal_year` BIGINT COMMENT 'The four-digit fiscal year (e.g., 2024) to which this revenue recognition event belongs. Supports annual financial reporting, year-end close, and multi-year revenue trend analysis.',
    `functional_currency_code` STRING COMMENT 'Three-letter ISO 4217 code for the entitys functional currency used for financial statement reporting (e.g., USD for a US-based CRO). Amounts may differ from contract currency due to foreign exchange translation. Required for multi-currency consolidation.. Valid values are `^[A-Z]{3}$`',
    `fx_rate` DECIMAL(18,6) COMMENT 'The exchange rate applied to convert contract currency amounts to functional currency as of the recognition date. Stored for audit traceability and to support foreign currency gain/loss analysis. Sourced from the source system rate tables.',
    `notes` STRING COMMENT 'Free-text field for finance team annotations, explanations of unusual recognition events, contract modification rationale, or audit reviewer comments associated with this revenue recognition record.',
    `phase` STRING COMMENT 'The regulatory phase of the clinical trial (Phase I through Phase IV) for which services are being delivered. Supports revenue segmentation by trial phase for strategic pricing analysis and portfolio reporting.. Valid values are `Phase I|Phase II|Phase III|Phase IV|Phase I/II|Phase II/III`',
    `prior_period_completion_percentage` DECIMAL(7,4) COMMENT 'The percentage of completion recorded in the immediately preceding recognition period. Used to calculate the incremental completion percentage and the resulting incremental recognized revenue for the current period.',
    `profit_center_code` STRING COMMENT 'the source system center code for the business unit responsible for the clinical trial engagement. Enables segment-level profitability reporting and management P&L analysis by therapeutic area or service line.',
    `rar_document_number` STRING COMMENT 'Human-readable the source system number (e.g., RAR-2024-000123) assigned by the source system the revenue accounting document. Used for cross-referencing with the source system audit packages, and SOX control evidence.',
    `rar_document_reference` BIGINT COMMENT 'Reference to the the source system Accounting and Reporting) performance obligation document that governs this recognition event. Links the lakehouse record to the authoritative the source system document for SOX audit traceability.',
    `recognition_date` DATE COMMENT 'The accounting date on which revenue is formally recognized in the general ledger. Determines the fiscal period to which the recognized amount is attributed. Aligned with the percentage-of-completion calculation as of this date.',
    `recognition_method` STRING COMMENT 'The accounting methodology applied to recognize revenue for this event. percentage_of_completion is the primary method for CRO services under ASC 606 / IFRS 15 over-time recognition.. Valid values are `percentage_of_completion|milestone|straight_line|output_method|input_method`',
    `recognition_status` STRING COMMENT 'Current workflow state of the revenue recognition event. draft indicates a preliminary calculation pending review; pending_review indicates awaiting finance controller approval; recognized indicates posted to the general ledger; reversed indicates. Valid values are `draft|pending_review|recognized|reversed|cancelled`',
    `recognized_amount` DECIMAL(18,2) COMMENT 'The revenue amount recognized in the current recognition period for this event. Represents the incremental revenue posted to the general ledger in this fiscal period. Core financial metric for period-close reporting and sponsor revenue reporting.',
    `recognized_amount_functional` DECIMAL(18,2) COMMENT 'The recognized revenue amount translated into the entitys functional currency using the fx_rate as of the recognition date. Used for consolidated financial reporting and SOX-controlled general ledger postings in the functional currency.',
    `reversal_flag` BOOLEAN COMMENT 'Indicates whether this recognition event is a reversal of a prior period recognition (True) or an original recognition entry (False). Reversals occur for corrections, contract modifications, or accrual true-ups. Supports audit trail completeness.',
    `service_line` STRING COMMENT 'The CRO service line category under which the recognized revenue is classified (e.g., clinical_operations for site management and monitoring, data_management for EDC/eCRF services, biostatistics for the source system/analysis, regulatory_affairs for',
    `sox_control_reference` STRING COMMENT 'The SOX internal control reference number (e.g., FIN-REV-001) associated with this revenue recognition event. Documents the specific SOX control applied during the recognition process for audit evidence and ICFR (Internal Controls over Financial',
    `therapeutic_area` STRING COMMENT 'The medical or scientific therapeutic area of the clinical trial (e.g., Oncology, Cardiology, Neurology, Infectious Disease). Supports revenue reporting and profitability analysis segmented by therapeutic area for strategic business intelligence.',
    `unbilled_receivable_amount` DECIMAL(18,2) COMMENT 'The contract asset amount representing revenue recognized but not yet invoiced to the sponsor as of the recognition date. Arises when revenue recognition outpaces billing milestones. Reported on the balance sheet as a contract asset per ASC 606 / IFRS 15.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this revenue recognition record was most recently modified. Tracks the last update event for change management, audit trail completeness, and incremental data pipeline processing in the Databricks Silver layer.',
    `wbs_element` STRING COMMENT 'the source system Breakdown Structure element code identifying the specific project task or deliverable within the clinical trial project plan to which this revenue recognition event is attributed.',
    CONSTRAINT pk_revenue_recognition PRIMARY KEY(`revenue_recognition_id`)
) COMMENT 'Transactional record capturing the revenue recognition events for clinical trial services delivered to sponsors, aligned with ASC 606 / IFRS 15 percentage-of-completion methodology.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` (
    `financial_forecast_id` BIGINT COMMENT 'Unique system-generated identifier for the financial forecast record. Primary key for the financial_forecast data product in the finance domain.',
    `account_plan_id` BIGINT COMMENT 'Foreign key linking to sponsor.account_plan. Business justification: Account plans set annual revenue targets that financial forecasts must align with. Finance teams validate financial_forecast against account_plan revenue targets during annual planning',
    `approver_employee_id` BIGINT COMMENT 'Reference to the the source system record of the individual who approved the forecast. Enforces SOX segregation of duties — approver must differ from preparer.',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: Financial forecasts are prepared at program level for portfolio governance and sponsor reporting.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Financial forecasts are scoped to a cost center for rolling financial planning. financial_forecast.cost_center_code is a denormalized string; adding cost_center_id FK normalizes this to',
    `country_id` BIGINT COMMENT 'Foreign key linking to study.study_country. Business justification: Financial forecasts are broken down by country for enrollment rate assumptions, site activation timelines, and country-specific cost projections.',
    `monitoring_plan_id` BIGINT COMMENT 'Foreign key linking to monitoring.monitoring_plan. Business justification: Financial forecasts for monitoring costs are built directly from monitoring plan parameters (visit frequency, SDV %, RBM strategy, site risk tiers).',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor funding the clinical trial. Used for sponsor-level financial reporting and invoicing reconciliation.',
    `pipeline_asset_id` BIGINT COMMENT 'Foreign key linking to sponsor.pipeline_asset. Business justification: Financial forecasts are produced per pipeline asset for portfolio-level R&D spend reporting. Pharma sponsors require asset-level financial forecasts for pipeline investment decisions.',
    `primary_financial_preparer_employee_id` BIGINT COMMENT 'Reference to the the source system record of the individual who prepared the forecast. Supports SOX segregation of duties controls and accountability tracking.',
    `sample_size_calc_id` BIGINT COMMENT 'Foreign key linking to biostatistics.sample_size_calc. Business justification: Financial forecasts use enrolled_subjects_assumption directly derived from the approved sample size calculation.',
    `scope_of_work_id` BIGINT COMMENT 'Foreign key linking to agreement.scope_of_work. Business justification: Financial forecasts in CRO operations are prepared at SOW level — each SOW version drives a forecast revision.',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking to sponsor.engagement. Business justification: Financial forecasts are produced at the engagement level for account planning and revenue target tracking.',
    `study_budget_id` BIGINT COMMENT 'Foreign key linking to finance.study_budget. Business justification: Financial forecasts project future revenue/costs against an approved study budget. The financial_forecast already has budget_revenue_amount and budget_cost_amount fields that compare',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this financial forecast is prepared. Links the forecast to a specific protocol and sponsor engagement.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Protocol amendments trigger forecast revisions (scope changes affect enrollment assumptions, visit counts, costs).',
    `study_protocol_milestone_id` BIGINT COMMENT 'Foreign key linking to study.study_milestone. Business justification: Financial forecasts use milestone completion percentages as EAC inputs. financial_forecast.milestone_completion_pct is a denormalized value without traceability.',
    `timeline_id` BIGINT COMMENT 'Foreign key linking to program.program_timeline. Business justification: Enrollment rate, active sites, and milestone completion assumptions in financial_forecast are derived directly from program_timeline data.',
    `workforce_resource_plan_id` BIGINT COMMENT 'Foreign key linking to workforce.workforce_resource_plan. Business justification: Financial forecasts incorporate workforce resource plan assumptions (enrolled_subjects_assumption, active_sites_assumption, FTE demand).',
    `accrual_amount` DECIMAL(18,2) COMMENT 'Projected accrual amount to be recorded in the general ledger for the forecast period, representing earned but not yet invoiced revenue or incurred but not yet paid costs. Supports period-end close processes.',
    `active_sites_assumption` BIGINT COMMENT 'The assumed number of active investigator sites used as a driver in the financial forecast model. Site activation status directly affects cost burn rates and milestone payment projections.',
    `approval_date` DATE COMMENT 'The date on which the forecast was formally approved by the authorized financial reviewer. Required for SOX financial reporting controls and sponsor financial reporting.',
    `budget_cost_amount` DECIMAL(18,2) COMMENT 'The approved budget total cost amount for the same forecast period, sourced from the study budget baseline. Used to compute cost variance between forecast and budget.',
    `budget_revenue_amount` DECIMAL(18,2) COMMENT 'The approved budget revenue amount for the same forecast period, sourced from the study budget baseline. Used to compute revenue variance between forecast and budget.',
    `cash_inflow_forecast_amount` DECIMAL(18,2) COMMENT 'Projected cash receipts from the sponsor during the forecast period, including milestone payments and invoice collections. Supports cash flow management and treasury planning.',
    `cash_outflow_forecast_amount` DECIMAL(18,2) COMMENT 'Projected cash disbursements to investigators, sites, vendors, and other payees during the forecast period. Supports cash flow management and treasury planning.',
    `confidence_level` STRING COMMENT 'Qualitative assessment of the reliability and accuracy of the forecast, reflecting the preparers confidence based on data quality, enrollment stability, and milestone predictability.. Valid values are `high|medium|low`',
    `cost_variance_amount` DECIMAL(18,2) COMMENT 'Monetary difference between the forecasted total cost and the budgeted total cost for the period (budget minus forecast). Positive value indicates favorable (under-budget) variance. Expressed in the forecast currency.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp recording when the financial forecast record was first created in the data platform. Supports audit trail requirements under SOX and 21 CFR Part 11.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which all monetary amounts in this forecast are expressed (e.g., USD, EUR, GBP). Enables multi-currency sponsor financial reporting.. Valid values are `^[A-Z]{3}$`',
    `direct_cost_forecast_amount` DECIMAL(18,2) COMMENT 'Projected total direct costs for the forecast period, including investigator grants, site payments, patient stipends, and clinical operations labor. Expressed in the forecast currency.',
    `enrolled_subjects_assumption` BIGINT COMMENT 'The assumed cumulative number of subjects enrolled as of the forecast period end date. Used to project visit-based costs, patient stipends, and milestone completion timelines.',
    `enrollment_rate_assumption` DECIMAL(10,4) COMMENT 'The assumed patient enrollment rate (subjects per site per month) used as a key driver in the financial forecast model. Changes in enrollment rate directly impact revenue recognition timing and cost projections.',
    `fiscal_period` BIGINT COMMENT 'The fiscal period number (1–12 for monthly, 1–4 for quarterly) within the fiscal year to which the forecast belongs. Aligns with the source system close and accrual posting cycles.',
    `fiscal_year` BIGINT COMMENT 'The fiscal year to which the forecast period belongs, as defined in the the source system calendar. Used for annual financial planning, SOX reporting, and year-over-year variance analysis.',
    `forecast_basis` STRING COMMENT 'Methodology used to construct the financial forecast. Indicates whether the forecast was built from granular site/subject data (bottom-up), extrapolated from portfolio trends (top-down), or derived from a statistical model.. Valid values are `bottom_up|top_down|run_rate|statistical_model|hybrid`',
    `forecast_number` STRING COMMENT 'Externally-known unique business identifier for the forecast document, following the format FC-YYYY-NNNNNN. Used in sponsor financial reporting, internal management reviews, and audit trails.. Valid values are `^FC-[0-9]{4}-[0-9]{6}$`',
    `forecast_period_end_date` DATE COMMENT 'The last calendar date of the forecast period being projected. Defines the closing boundary of the financial projection window.',
    `forecast_period_start_date` DATE COMMENT 'The first calendar date of the forecast period being projected. Defines the beginning boundary of the financial projection window.',
    `forecast_status` STRING COMMENT 'Current lifecycle state of the financial forecast record. Controls whether the forecast is active for reporting and decision-making or has been replaced by a newer version.. Valid values are `draft|under_review|approved|superseded|archived`',
    `forecast_type` STRING COMMENT 'Classification of the forecast by periodicity or purpose. Determines the time horizon and granularity of the projection. [ENUM-REF-CANDIDATE: monthly|quarterly|annual|ad_hoc|rolling_12_month|study_to_date — promote to reference product]',
    `forecast_version` BIGINT COMMENT 'Sequential version number of the forecast for a given study and forecast period. Incremented each time a forecast is revised, enabling comparison of forecast iterations over time.',
    `gross_margin_forecast_amount` DECIMAL(18,2) COMMENT 'Projected gross margin for the forecast period, calculated as revenue forecast minus direct cost forecast. Expressed in the forecast currency. Used for sponsor financial reporting and internal profitability management.',
    `gross_margin_forecast_pct` DECIMAL(7,4) COMMENT 'Projected gross margin as a percentage of forecasted revenue for the period. Expressed as a decimal (e.g., 0.3250 = 32.50%). Used for portfolio-level profitability benchmarking.',
    `indirect_cost_forecast_amount` DECIMAL(18,2) COMMENT 'Projected total indirect and overhead costs allocated to the study for the forecast period, including G&A allocations and shared service charges. Expressed in the forecast currency.',
    `is_baseline_forecast` BOOLEAN COMMENT 'Indicates whether this forecast version has been designated as the baseline against which future forecast variances will be measured. Only one forecast per study and period may be flagged as baseline.',
    `milestone_completion_pct` DECIMAL(7,4) COMMENT 'Projected percentage of study milestones expected to be completed by the end of the forecast period. Expressed as a decimal (e.g., 0.6500 = 65%). Drives revenue recognition and sponsor invoicing projections.',
    `pass_through_cost_forecast_amount` DECIMAL(18,2) COMMENT 'Projected total pass-through costs to be reimbursed by the sponsor for the forecast period, such as central lab fees, imaging costs, and regulatory filing fees. Expressed in the forecast currency.',
    `preparation_date` DATE COMMENT 'The business date on which the forecast was formally prepared and submitted for review. Distinct from the system audit timestamp; represents the real-world event date for the forecast cycle.',
    `reporting_period_label` STRING COMMENT 'Human-readable label for the forecast period used in sponsor financial reports and internal management dashboards (e.g., Q3 2024, FY2024, October 2024). Supports consistent period identification across reporting cycles.',
    `revenue_forecast_amount` DECIMAL(18,2) COMMENT 'Projected total revenue to be recognized from the sponsor for the forecast period, including service fees, pass-through reimbursements, and milestone payments. Expressed in the forecast currency.',
    `revenue_variance_amount` DECIMAL(18,2) COMMENT 'Monetary difference between the forecasted revenue and the budgeted revenue for the period (forecast minus budget). Positive value indicates favorable variance; negative indicates unfavorable. Expressed in the forecast currency.',
    `scope_level` STRING COMMENT 'Indicates the organizational or operational scope at which the forecast is prepared. Study-level forecasts project a single protocol; portfolio-level forecasts aggregate across multiple studies for sponsor or management reporting.. Valid values are `study|portfolio|program|country`',
    `sponsor_submitted_flag` BOOLEAN COMMENT 'Indicates whether this forecast has been formally submitted to the sponsor as part of contractual financial reporting obligations. Supports sponsor relationship management and contract compliance tracking.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp recording the most recent modification to the financial forecast record. Supports change tracking and audit trail requirements under SOX and 21 CFR Part 11.',
    `variance_explanation` STRING COMMENT 'Free-text narrative provided by the preparer explaining material variances between the current forecast and the approved budget or prior forecast version. Required for management review and SOX documentation.',
    `wbs_element_code` STRING COMMENT 'the source system Breakdown Structure element code identifying the project node to which this forecast is linked. Enables project-level cost and revenue tracking aligned to the studys project accounting structure.',
    CONSTRAINT pk_financial_forecast PRIMARY KEY(`financial_forecast_id`)
) COMMENT 'Master record for rolling financial forecasts at the study or portfolio level, projecting future revenues, costs, and cash flows based on current enrollment rates, site activation status, and milestone completion projections.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` (
    `finance_billing_milestone_id` BIGINT COMMENT 'Unique surrogate identifier for the sponsor-facing billing milestone record in the clinical trial financial management system.',
    `approved_by_employee_id` BIGINT COMMENT 'Reference to the employee who approved this billing milestone for invoicing in the internal approval workflow. Required for SOX dual-control and segregation-of-duties compliance.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Billing milestones are attributed to a cost center for revenue recognition and the source system processing.',
    `evidence_tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Billing milestones (e.g., database lock, final CSR delivery) require a specific TMF document as evidence of completion before invoicing.',
    `nda_bla_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.nda_bla_application. Business justification: NDA/BLA submission acceptance, PDUFA date, and approval are major billing milestones in CRO regulatory affairs contracts.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor entity that will be invoiced upon milestone achievement.',
    `program_development_milestone_id` BIGINT COMMENT 'Foreign key linking to program.program_milestone. Business justification: Contractual billing milestones are directly tied to program execution milestones (IND filing, Phase 2 completion).',
    `proposal_id` BIGINT COMMENT 'Foreign key linking to sponsor.proposal. Business justification: Billing milestones are derived from the payment schedule defined in the winning proposal. Finance teams set up billing plans by mapping proposal payment milestones to',
    `regulatory_approval_id` BIGINT COMMENT 'Foreign key linking to regulatory.approval. Business justification: Regulatory approval (NDA, MAA, CTA approval) is the most significant billing milestone trigger in CRO contracts, often representing 20-30% of contract value.',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: Regulatory submission milestones (IND filing, NDA submission) are explicit billing triggers in CRO/sponsor contracts.',
    `regulatory_commitment_id` BIGINT COMMENT 'Foreign key linking to regulatory.commitment. Business justification: Post-approval regulatory commitments (PMC/PMR deliverables, annual safety reports) are billable milestones in CRO post-approval service contracts.',
    `sponsor_invoice_id` BIGINT COMMENT 'Reference to the accounts receivable invoice generated when this milestone is triggered. Null until the milestone reaches invoiced status.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this billing milestone applies. Enables financial reporting and accrual tracking at the study level.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Protocol amendments create new billing milestones or modify existing ones via contract change orders. finance_billing_milestone.amendment_number is denormalized.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Regulatory submissions (IND filing, NDA acceptance) are standard billing milestone triggers in CRO-sponsor contracts.',
    `triggering_subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: Billing milestones such as First Patient Randomized and Last Patient Randomized are directly triggered by specific randomization events.',
    `workflow_id` BIGINT COMMENT 'Foreign key linking to document.document_workflow. Business justification: Document workflow completion events (e.g., final study report approval workflow) are contractual billing triggers in clinical trial service agreements.',
    `accrual_amount` DECIMAL(18,2) COMMENT 'Revenue accrual amount recognized for this milestone in the current accounting period based on percentage-of-completion or other accrual methodology, prior to formal invoicing. Used for monthly financial close and SOX-compliant revenue accruals.',
    `accrual_pct` DECIMAL(5,2) COMMENT 'Percentage of the billing milestone amount that has been accrued as revenue in the current period (0.00 to 100.00). Reflects the estimated completion of the milestone trigger criteria for accrual purposes.',
    `actual_trigger_date` DATE COMMENT 'The actual calendar date on which the milestone trigger criteria were confirmed as satisfied and the milestone was formally triggered for invoicing. Null until the milestone is triggered. Used for variance analysis against planned billing date.',
    `approval_date` DATE COMMENT 'Date on which the billing milestone was formally approved for invoicing by the authorized approver. Part of the SOX-compliant audit trail for revenue recognition.',
    `approval_status` STRING COMMENT 'Internal approval workflow status for triggering the milestone invoice: pending_approval (awaiting finance/management sign-off), approved (cleared for invoicing), rejected (trigger evidence insufficient), not_required (auto-approved per contract terms).. Valid values are `pending_approval|approved|rejected|not_required`',
    `billing_amount` DECIMAL(18,2) COMMENT 'Gross contractual amount to be invoiced to the sponsor upon achievement of this milestone, expressed in the billing currency. Represents the base revenue amount before any adjustments or withholdings.',
    `billing_plan_line_number` STRING COMMENT 'the source system plan line item number corresponding to this milestone within the project or contract billing schedule. Enables direct traceability to the source system billing plan configuration.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this billing milestone record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Provides the audit trail creation anchor required for SOX and ALCOA+ data integrity compliance.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the billing milestone amount (e.g., USD, EUR, GBP, JPY). Determines the currency in which the sponsor invoice will be raised.. Valid values are `^[A-Z]{3}$`',
    `exchange_rate` DECIMAL(18,6) COMMENT 'Exchange rate applied to convert the billing currency amount to the functional currency at the time of milestone recognition or invoicing. Sourced from the source system rate tables.',
    `functional_currency_amount` DECIMAL(18,2) COMMENT 'Billing milestone amount converted to the CROs functional (reporting) currency using the applicable exchange rate at the time of recognition. Required for consolidated financial reporting and SOX compliance.',
    `invoice_date` DATE COMMENT 'Date on which the sponsor invoice was raised in the source system Receivable for this billing milestone. Null until the milestone reaches invoiced status. Determines the revenue recognition date.',
    `is_at_risk` BOOLEAN COMMENT 'Indicates whether this billing milestone is classified as at-risk (True), meaning the sponsor has disputed, placed on hold, or the CRO has assessed a significant probability of non-collection.',
    `is_pass_through` BOOLEAN COMMENT 'Indicates whether this billing milestone represents a pass-through cost reimbursement (True) rather than a CRO service fee (False). Pass-through milestones are billed at cost without margin and require separate financial treatment.',
    `milestone_description` STRING COMMENT 'Detailed narrative description of the billing milestone, including specific trigger conditions, deliverable specifications, and any contractual nuances as agreed with the sponsor.',
    `milestone_name` STRING COMMENT 'Descriptive name of the billing milestone as defined in the sponsor agreement (e.g., First Patient First Visit, Database Lock, 50% Enrollment Achieved). Used in sponsor-facing invoices and financial dashboards.',
    `milestone_number` STRING COMMENT 'Externally-known, human-readable unique identifier for the billing milestone as referenced in sponsor contracts, invoices, and financial reports (e.g., BM-STUDY001-0010). Used for sponsor communication and audit trail.. Valid values are `^BM-[A-Z0-9]{3,20}-[0-9]{4}$`',
    `milestone_sequence` BIGINT COMMENT 'Ordinal position of this milestone within the sponsor agreement billing schedule. Determines the order in which milestones are evaluated and invoiced across the study lifecycle.',
    `milestone_status` STRING COMMENT 'Current lifecycle state of the billing milestone: pending (not yet met), triggered (trigger criteria satisfied, ready for invoicing), invoiced (invoice raised to sponsor), paid (payment received), cancelled (milestone voided), on_hold (temporarily. Valid values are `pending|triggered|invoiced|paid|cancelled|on_hold`',
    `milestone_type` STRING COMMENT 'Classification of the billing milestone by the nature of its trigger mechanism: enrollment_based (subject enrollment thresholds), visit_based (patient visit completion), deliverable_based (document or data deliverable), time_based (calendar-driven), or. Valid values are `enrollment_based|visit_based|deliverable_based|time_based|regulatory_based`',
    `notes` STRING COMMENT 'Free-text field for capturing operational notes, sponsor communications, dispute details, or special billing instructions related to this milestone. Supports audit trail and exception management.',
    `original_billing_amount` DECIMAL(18,2) COMMENT 'The original contractual billing amount for this milestone prior to any amendments or scope changes. Enables variance analysis between original contract value and current billing amount to support change order tracking.',
    `payment_amount_received` DECIMAL(18,2) COMMENT 'Actual amount received from the sponsor against this billing milestone invoice. May differ from billing_amount due to partial payments, withholdings, or currency adjustments.',
    `payment_due_date` DATE COMMENT 'Contractual date by which the sponsor is required to remit payment for the invoiced milestone amount, as defined in the sponsor agreement payment terms.',
    `payment_received_date` DATE COMMENT 'Actual date on which sponsor payment was received and applied against the invoice for this milestone in the source system until payment is confirmed. Used for days-sales-outstanding (DSO) analysis.',
    `planned_billing_date` DATE COMMENT 'Contractually agreed or operationally planned calendar date on which this milestone is expected to be triggered and invoiced to the sponsor. Used for cash flow forecasting and revenue planning.',
    `profit_center_code` STRING COMMENT 'the source system center code for this billing milestone, enabling revenue attribution to the appropriate business unit or therapeutic area for management reporting.',
    `revenue_recognition_method` STRING COMMENT 'Accounting method applied to recognize revenue for this billing milestone: milestone_completion (recognize at 100% trigger), percentage_of_completion (pro-rata accrual), straight_line (time-based), or event_based (specific regulatory or clinical event).. Valid values are `milestone_completion|percentage_of_completion|straight_line|event_based`',
    `sap_wbs_element` STRING COMMENT 'the source system Breakdown Structure element code to which this billing milestone is assigned for project accounting and cost allocation purposes. Enables revenue and cost tracking at the project sub-element level.',
    `trigger_criteria` STRING COMMENT 'Formal description of the measurable condition(s) that must be satisfied to trigger this billing milestone (e.g., 50 subjects enrolled across all sites, Final CSR delivered to sponsor, DBL achieved).',
    `trigger_threshold_unit` STRING COMMENT 'Unit of measure for the trigger threshold value (e.g., subjects, visits, sites, percentage, days, deliverables). Provides context for interpreting the numeric threshold.. Valid values are `subjects|visits|sites|percentage|days|deliverables`',
    `trigger_threshold_value` DECIMAL(18,4) COMMENT 'Quantitative threshold value associated with the trigger criteria (e.g., number of subjects enrolled, number of visits completed, percentage of data cleaned). Applicable for enrollment_based and visit_based milestone types.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this billing milestone record, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports change detection, data lineage, and SOX audit trail requirements.',
    `withholding_amount` DECIMAL(18,2) COMMENT 'Amount withheld by the sponsor from the milestone payment, typically as a contractual retention or performance guarantee holdback. Reduces the net payment received relative to the invoiced amount.',
    CONSTRAINT pk_finance_billing_milestone PRIMARY KEY(`finance_billing_milestone_id`)
) COMMENT 'Master record defining the contractual billing milestones agreed with sponsors for triggering invoice generation. Captures milestone name, milestone type (enrollment-based, visit-based, deliverable-based, time-based), trigger criteria, planned billing';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`finance`.`budget_line` (
    `budget_line_id` BIGINT COMMENT 'Unique surrogate identifier for each granular budget line item within a study budget. Primary key for the budget_line data product.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Budget line approval is part of the study budget management and change control process. Linking to the approving employee supports financial governance reporting and SOX audit trails.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.study_arm. Business justification: Multi-arm studies have arm-specific budget lines (different drug costs, dosing frequencies, procedure requirements per arm).',
    `bioanalytical_assay_id` BIGINT COMMENT 'Foreign key linking to laboratory.bioanalytical_assay. Business justification: PK/DMPK study budgets include dedicated lines per bioanalytical assay (sample count × assay cost). Linking budget_line to bioanalytical_assay enables assay-level budget vs.',
    `budget_vendor_invoice_id` BIGINT COMMENT 'FK from budget_line_fk_extension: vendor_invoice_id',
    `change_order_id` BIGINT COMMENT 'Foreign key linking to agreement.change_order. Business justification: Budget lines are created or modified by specific change orders. The change_order.impacted_budget_lines field confirms this relationship.',
    `clinical_program_id` BIGINT COMMENT 'FK from budget_line_fk_extension: clinical_program_id',
    `compliance_capa_id` BIGINT COMMENT 'Foreign key linking to compliance.capa. Business justification: Significant CAPAs (e.g., site remediation, system overhaul) have dedicated budget lines in study or operational budgets.',
    `cost_center_id` BIGINT COMMENT 'BIGINT',
    `country_id` BIGINT COMMENT 'FK from budget_line_fk_extension: country_id',
    `database_lock_event_id` BIGINT COMMENT 'FK from budget_line_fk_extension: database_lock_event_id',
    `deliverable_id` BIGINT COMMENT 'FK from budget_line_fk_extension: deliverable_id',
    `dosing_regimen_id` BIGINT COMMENT 'Foreign key linking to study.dosing_regimen. Business justification: Drug administration costs (infusion nursing, pharmacy preparation, drug wastage) are tied to specific dosing regimens. Dose escalation schemes have distinct cost profiles.',
    `dsmb_review_id` BIGINT COMMENT 'FK from budget_line_fk_extension: dsmb_review_id',
    `edc_study_build_id` BIGINT COMMENT 'Foreign key linking to datamanagement.edc_study_build. Business justification: EDC build activities (UAT, go-live, amendments) are discrete billable line items in CRO budgets.',
    `epoch_id` BIGINT COMMENT 'Foreign key linking to study.study_epoch. Business justification: Budget lines are structured by study epoch (screening, treatment, follow-up) for cost phasing and sponsor billing.',
    `finance_billing_milestone_id` BIGINT COMMENT 'Foreign key linking to finance.finance_billing_milestone. Business justification: Budget lines that are milestone-based (budget_line.is_milestone_based = true, has milestone_description) should reference the specific billing milestone they correspond to.',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Budget lines are mapped to GL accounts for financial planning and the source system budget_line.gl_account_code is a denormalized string; adding gl_account_id FK normalizes this to the',
    `icf_amendment_id` BIGINT COMMENT 'Foreign key linking to consent.icf_amendment. Business justification: ICF amendments generate discrete budget lines for translation, back-translation, IRB fees, and reconsent visit costs.',
    `interim_analysis_id` BIGINT COMMENT 'FK from budget_line_fk_extension: interim_analysis_id',
    `investigational_product_id` BIGINT COMMENT 'FK from budget_line_fk_extension: investigational_product_id',
    `investigational_site_id` BIGINT COMMENT 'FK from budget_line_fk_extension: investigational_site_id',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_panel. Business justification: Clinical trial budgets are built panel-by-panel (hematology, chemistry, urinalysis × visits × subjects × unit cost). Linking budget_line to lab_panel enables panel-level budget vs.',
    `monitoring_cra_assignment_id` BIGINT COMMENT 'FK from budget_line_fk_extension: monitoring_cra_assignment_id',
    `monitoring_plan_id` BIGINT COMMENT 'Foreign key linking to monitoring.monitoring_plan. Business justification: Budget lines for monitoring activities (on-site visits, remote monitoring, SDV) are scoped and sized from the monitoring plan.',
    `monitoring_visit_id` BIGINT COMMENT 'FK from budget_line_fk_extension: monitoring_visit_id',
    `nda_bla_application_id` BIGINT COMMENT 'FK from budget_line_fk_extension: nda_bla_application_id',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor funding this budget line. Used for sponsor-level budget reporting and invoicing reconciliation.',
    `pipeline_asset_id` BIGINT COMMENT 'FK from budget_line_fk_extension: pipeline_asset_id',
    `pk_sampling_schedule_id` BIGINT COMMENT 'Foreign key linking to study.pk_sampling_schedule. Business justification: PK sampling has dedicated budget lines for central lab processing, sample storage, and bioanalytical assays.',
    `program_development_milestone_id` BIGINT COMMENT 'FK from budget_line_fk_extension: program_development_milestone_id',
    `proposal_line_id` BIGINT COMMENT 'Foreign key linking to sponsor.proposal_line. Business justification: Each budget_line traces to a proposal_line for cost-vs-bid variance reporting and scope change management.',
    `protocol_lab_schedule_id` BIGINT COMMENT 'Foreign key linking to laboratory.protocol_lab_schedule. Business justification: Budget lines for lab costs are derived directly from the protocol lab schedule (panels × visits × subject count × unit rate).',
    `purchase_order_id` BIGINT COMMENT 'FK from budget_line_fk_extension: purchase_order_id',
    `rate_card_id` BIGINT COMMENT 'Foreign key linking to agreement.rate_card. Business justification: Budget lines are priced using contracted rate card unit rates. CRO finance teams build study budgets by applying rate card rates to planned activity units.',
    `regulatory_approval_id` BIGINT COMMENT 'FK from budget_line_fk_extension: regulatory_approval_id',
    `regulatory_commitment_id` BIGINT COMMENT 'FK from budget_line_fk_extension: regulatory_commitment_id',
    `regulatory_inspection_id` BIGINT COMMENT 'FK from budget_line_fk_extension: regulatory_inspection_id',
    `rems_program_id` BIGINT COMMENT 'FK from budget_line_fk_extension: rems_program_id',
    `sample_size_calc_id` BIGINT COMMENT 'FK from budget_line_fk_extension: sample_size_calc_id',
    `scope_of_work_id` BIGINT COMMENT 'FK from budget_line_fk_extension: scope_of_work_id',
    `serious_adverse_event_id` BIGINT COMMENT 'FK from budget_line_fk_extension: serious_adverse_event_id',
    `site_agreement_id` BIGINT COMMENT 'FK from budget_line_fk_extension: site_agreement_id',
    `specimen_collection_id` BIGINT COMMENT 'FK from budget_line_fk_extension: specimen_collection_id',
    `specimen_shipment_id` BIGINT COMMENT 'FK from budget_line_fk_extension: specimen_shipment_id',
    `sponsor_invoice_id` BIGINT COMMENT 'FK from budget_line_fk_extension: sponsor_invoice_id',
    `study_budget_id` BIGINT COMMENT 'Reference to the parent study budget header that this line item belongs to. Establishes the header-detail relationship for budget line aggregation and version control.',
    `study_id` BIGINT COMMENT 'BIGINT',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Budget lines are revised when protocol amendments change scope (additional visits, procedures, subjects).',
    `study_site_id` BIGINT COMMENT 'FK from budget_line_fk_extension: study_site_id',
    `study_visit_schedule_id` BIGINT COMMENT 'Foreign key linking to study.study_visit_schedule. Business justification: Per-visit budget lines (lab fees, procedure costs, site fees) are tied to specific protocol visit schedule entries.',
    `subcontract_id` BIGINT COMMENT 'FK from budget_line_fk_extension: subcontract_id',
    `submission_id` BIGINT COMMENT 'regulatory.submission.submission_id',
    `timeline_id` BIGINT COMMENT 'FK from budget_line_fk_extension: timeline_id',
    `treatment_arm_id` BIGINT COMMENT 'randomization.treatment_arm.treatment_arm_id',
    `trial_subject_id` BIGINT COMMENT 'FK from budget_line_fk_extension: trial_subject_id',
    `vendor_id` BIGINT COMMENT 'BIGINT',
    `vendor_invoice_id` BIGINT COMMENT 'description',
    `visit_procedure_id` BIGINT COMMENT 'study.visit_procedure.visit_procedure_id',
    `workforce_resource_plan_id` BIGINT COMMENT 'FK from budget_line_fk_extension: workforce_resource_plan_id',
    `accrual_amount` DECIMAL(18,2) COMMENT 'Accrued cost amount for this budget line representing services rendered but not yet invoiced, posted as a period-end accrual in the source system Critical for accurate period financial reporting and SOX compliance.',
    `activity_type` STRING COMMENT 'Specific clinical trial activity associated with this budget line (e.g., Site Initiation Visit, Monitoring Visit, Database Lock, Regulatory Submission, Patient Screening, SAE Reporting).',
    `actual_amount` DECIMAL(18,2) COMMENT 'Total actual costs incurred against this budget line item to date in the transaction currency, as posted in the source system for budget vs. actual variance analysis and financial reporting.',
    `approved_date` DATE COMMENT 'Date on which this budget line was formally approved by the authorized financial approver. Required for SOX financial controls documentation and audit trail.',
    `budget_version` STRING COMMENT 'Version identifier of the budget to which this line belongs (e.g., v1.0, v2.0-Amendment-1). Supports budget versioning for contract amendments, scope changes, and sponsor re-negotiations. Aligns with the source system version management.',
    `committed_amount` DECIMAL(18,2) COMMENT 'Amount committed via purchase orders or contracts against this budget line but not yet invoiced or paid. Represents financial obligations that reduce available budget. Sourced from the source system management.',
    `cost_category` STRING COMMENT 'High-level classification of the cost type for this budget line. Drives financial reporting segmentation and sponsor invoicing. Values: direct_labor (CRO staff effort), pass_through (third-party vendor costs billed at cost), investigator_grant (site/PI. Valid values are `direct_labor|pass_through|investigator_grant|overhead|patient_stipend`',
    `cost_subcategory` STRING COMMENT 'Granular sub-classification within the cost category (e.g., Clinical Monitoring, Data Management, Biostatistics, Central Lab, Imaging, RTSM, eCRF License). Enables detailed cost tracking and variance analysis at the activity level.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this budget line record was first created in the system. Provides audit trail for record origination. Conforms to 21 CFR Part 11 electronic records requirements and SOX audit trail standards.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this budget line (e.g., USD, EUR, GBP, JPY). Supports multi-currency clinical trial budgets for global studies.. Valid values are `^[A-Z]{3}$`',
    `exchange_rate` DECIMAL(18,6) COMMENT 'Foreign exchange rate applied to convert the transaction currency amount to the functional currency. Sourced from the source system rate tables. Required for multi-currency budget reporting and variance analysis.',
    `fiscal_period` BIGINT COMMENT 'Fiscal accounting period (1–12 or 1–13 depending on fiscal year variant) within the fiscal year to which this budget line is allocated. Enables monthly budget tracking and period-end accrual management in the source system',
    `fiscal_year` BIGINT COMMENT 'Fiscal year to which this budget line is allocated (e.g., 2024, 2025). Used for annual budget planning, financial period reporting, and SOX financial controls alignment in the source system',
    `functional_currency_amount` DECIMAL(18,2) COMMENT 'Planned amount converted to the companys functional currency (typically USD) using the applicable exchange rate. Required for consolidated financial reporting and SOX compliance across multi-currency global studies.',
    `is_milestone_based` BOOLEAN COMMENT 'Indicates whether payment for this budget line is triggered by achievement of a defined clinical milestone (True) rather than time-and-materials or unit-based billing (False). Drives milestone payment scheduling and sponsor invoicing logic.',
    `is_pass_through` BOOLEAN COMMENT 'Indicates whether this budget line represents a pass-through cost that is billed to the sponsor at cost without CRO markup (True) or a CRO-managed cost subject to margin (False). Critical for sponsor invoicing and revenue recognition.',
    `line_description` STRING COMMENT 'Human-readable description of the budget line item activity or cost element (e.g., Site Initiation Visit - Site 001, Investigator Grant - Per Patient Enrolled, Central Lab Processing Fee). Used in sponsor budget reports and financial reconciliation.',
    `line_number` BIGINT COMMENT 'Sequential line number ordering this item within the parent budget. Enables ordered display and navigation of budget line items in sponsor budget reports and the source system accounting views.',
    `line_status` STRING COMMENT 'Current lifecycle status of the budget line item. Controls whether the line is available for cost posting and sponsor invoicing. Draft: under preparation; Approved: authorized for spend; Active: costs being incurred; On Hold: temporarily suspended. Valid values are `draft|approved|active|on_hold|cancelled|closed`',
    `milestone_description` STRING COMMENT 'Description of the clinical or contractual milestone that triggers payment for this budget line when is_milestone_based is True (e.g., First Patient First Visit, Database Lock, Last Patient Last Visit, Regulatory Submission).',
    `notes` STRING COMMENT 'Free-text notes or comments providing additional context for this budget line item (e.g., assumptions, scope clarifications, amendment rationale, vendor quotes). Supports financial review and audit documentation.',
    `period_end_date` DATE COMMENT 'End date of the time period covered by this budget line item. Defines the temporal boundary for cost incurrence and accrual cutoff. Used in time-phased budget reporting and study close-out.',
    `period_start_date` DATE COMMENT 'Start date of the time period covered by this budget line item. Defines the temporal scope for cost incurrence and accrual recognition. Used in time-phased budget reporting.',
    `planned_amount` DECIMAL(18,2) COMMENT 'Total budgeted amount for this line item in the transaction currency (planned_quantity × unit_cost). Represents the authorized spend ceiling for this activity. Used for variance analysis and sponsor budget reporting.',
    `planned_quantity` DECIMAL(18,4) COMMENT 'Budgeted quantity of units for this line item (e.g., number of monitoring visits, number of patients enrolled, number of lab kits, number of FTE hours). Combined with unit_cost to derive the total planned amount.',
    `profit_center_code` STRING COMMENT 'the source system code associated with this budget line for internal profitability reporting. Enables study-level and sponsor-level margin analysis within the source system',
    `sap_company_code` STRING COMMENT 'the source system representing the legal entity responsible for this budget line. Required for multi-entity financial consolidation, intercompany accounting, and SOX entity-level financial reporting.',
    `sap_document_number` STRING COMMENT 'the source system document number associated with the budget posting for this line item. Provides direct traceability from the lakehouse Silver layer back to the source system transaction for audit and reconciliation purposes.',
    `sap_internal_order` STRING COMMENT 'the source system number used for detailed cost collection and monitoring for this budget line, particularly for pass-through costs and investigator grants. Supplements WBS element for granular cost tracking.',
    `sponsor_line_ref` STRING COMMENT 'Sponsors own reference code or line identifier for this budget item as defined in the contract or sponsor budget template. Enables cross-referencing between CRO internal budget and sponsor-facing budget documentation for reconciliation.',
    `unit_cost` DECIMAL(18,4) COMMENT 'Negotiated or standard cost per unit for this budget line item in the transaction currency. Multiplied by planned_quantity to derive planned_amount. Commercially sensitive as it reflects CRO pricing and investigator grant rates.',
    `unit_of_measure` STRING COMMENT 'Unit of measurement for the planned quantity (e.g., visit, patient, hour, FTE, kit, sample, page, month). Required for accurate cost calculation and sponsor budget reporting.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this budget line record. Supports change detection, incremental data loading in the Databricks Silver layer, and SOX audit trail requirements.',
    `wbs_element` STRING COMMENT 'the source system Structure element code that classifies this budget line within the project hierarchy (e.g., study phase, activity, task). Drives cost allocation, project accounting, and financial reporting in the source system',
    CONSTRAINT pk_budget_line PRIMARY KEY(`budget_line_id`)
) COMMENT 'Granular line-item breakdown of a study budget by WBS element, cost category, and time period. Captures budget line description, cost category (direct labor, pass-through, investigator grants, overhead), planned quantity, unit cost, total planned amount';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`finance`.`vendor` (
    `vendor_id` BIGINT COMMENT 'Primary key for vendor',
    `organization_id` BIGINT COMMENT 'add column organization_id (BIGINT) with FK to sponsor.organization.organization_id — vendors are organizations and should link to the organization master',
    `parent_vendor_id` BIGINT COMMENT 'Self-referencing FK on vendor (parent_vendor_id)',
    `address_line_1` STRING COMMENT 'Primary street address line of the vendors registered business location used for correspondence and payment remittance.',
    `address_line_2` STRING COMMENT 'Secondary address line for suite, floor, building, or additional location details of the vendor.',
    `bank_account_number` STRING COMMENT 'Vendors bank account number used for electronic fund transfers and payment remittance. Encrypted at rest per PCI-DSS requirements.',
    `bank_routing_number` STRING COMMENT 'Bank routing or SWIFT/BIC code used to identify the vendors financial institution for payment processing.',
    `vendor_category` STRING COMMENT 'Tiered classification of the vendor based on strategic importance, qualification status, and procurement preference level.',
    `city` STRING COMMENT 'City or municipality of the vendors registered business address.',
    `vendor_code` STRING COMMENT 'Unique alphanumeric business code assigned to the vendor for identification in financial systems and purchase orders.',
    `contract_effective_date` DATE COMMENT 'Date on which the current master service agreement or framework contract with the vendor became effective.',
    `contract_expiration_date` DATE COMMENT 'Date on which the current master service agreement or framework contract with the vendor expires and requires renewal.',
    `cost_center_code` STRING COMMENT 'Default cost center assignment for expenses incurred with this vendor, supporting project accounting and financial allocation.',
    `country_code` STRING COMMENT 'Three-letter ISO country code of the vendors registered business location, used for tax jurisdiction and regulatory compliance determination.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the vendor master record was first created in the system, supporting audit trail and SOX compliance requirements.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code representing the vendors preferred transaction and invoicing currency.',
    `dba_name` STRING COMMENT 'The trade name or doing-business-as name under which the vendor operates, if different from the legal name.',
    `diversity_classification` STRING COMMENT 'Diversity certification classification of the vendor for supplier diversity reporting and compliance with corporate social responsibility programs.',
    `duns_number` STRING COMMENT 'The Dun & Bradstreet unique nine-digit identifier for the vendor entity, used for credit assessment and supplier qualification.',
    `gl_account_code` STRING COMMENT 'Default general ledger account code for posting vendor-related transactions in the financial accounting system.',
    `insurance_expiration_date` DATE COMMENT 'Expiration date of the vendors certificate of insurance, ensuring adequate liability coverage for clinical trial services.',
    `is_1099_reportable` BOOLEAN COMMENT 'Indicates whether payments to this vendor are subject to IRS 1099 reporting requirements for US tax compliance.',
    `is_gcp_compliant` BOOLEAN COMMENT 'Indicates whether the vendor has demonstrated compliance with ICH Good Clinical Practice guidelines through audit or self-assessment.',
    `is_minority_owned` BOOLEAN COMMENT 'Indicates whether the vendor is certified as a minority-owned business enterprise for diversity tracking and reporting purposes.',
    `vendor_name` STRING COMMENT 'The official registered legal name of the vendor organization used in contracts, invoices, and regulatory filings.',
    `next_audit_date` DATE COMMENT 'Date of the next scheduled quality audit or vendor oversight review as required by GCP vendor management procedures.',
    `onboarding_date` DATE COMMENT 'Date on which the vendor was initially onboarded and approved in the vendor master system for clinical trial engagements.',
    `payment_method` STRING COMMENT 'Preferred method of payment disbursement to the vendor for settled invoices and milestone payments.',
    `payment_terms` STRING COMMENT 'Standard payment terms agreed with the vendor specifying the number of days within which invoices must be settled or milestone-based payment structure.',
    `postal_code` STRING COMMENT 'Postal or ZIP code of the vendors registered business address used for mail delivery and geographic classification.',
    `primary_contact_email` STRING COMMENT 'Email address of the primary contact at the vendor organization used for official correspondence and invoice communications.',
    `primary_contact_name` STRING COMMENT 'Full name of the primary business contact person at the vendor organization for day-to-day communications.',
    `primary_contact_phone` STRING COMMENT 'Phone number of the primary contact at the vendor organization for urgent communications and escalations.',
    `purchasing_organization` STRING COMMENT 'The organizational unit responsible for procurement activities and contract negotiations with this vendor.',
    `qualification_date` DATE COMMENT 'Date on which the vendor was most recently qualified or re-qualified per clinical trial vendor oversight requirements.',
    `qualification_status` STRING COMMENT 'Current qualification status of the vendor per GCP vendor qualification requirements, indicating whether the vendor meets quality and regulatory standards for clinical trial work.',
    `risk_rating` STRING COMMENT 'Risk classification assigned to the vendor based on the criticality of services provided, regulatory impact, and historical performance in clinical trial operations.',
    `service_scope` STRING COMMENT 'Description of the primary services or goods the vendor provides to clinical trial operations, such as data management, biostatistics, monitoring, lab services, or drug supply.',
    `state_province` STRING COMMENT 'State, province, or administrative region of the vendors registered business address.',
    `vendor_status` STRING COMMENT 'Current operational status of the vendor in the master data system indicating whether the vendor is eligible for new engagements and payments.',
    `tax_identifier` STRING COMMENT 'The vendors government-issued tax identification number used for tax reporting, 1099 filings, and regulatory compliance.',
    `termination_date` DATE COMMENT 'Date on which the vendor relationship was terminated or deactivated, if applicable. Null for active vendors.',
    `vendor_type` STRING COMMENT 'Classification of the vendor by the nature of services or goods provided to clinical trial operations. Includes Contract Research Organizations (CROs), central laboratories, investigator sites, material suppliers, consultants, and technology providers.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the vendor master record was last modified, supporting change tracking and SOX audit trail requirements.',
    `withholding_tax_code` STRING COMMENT 'Tax withholding code applicable to payments made to this vendor, determining the withholding rate per tax jurisdiction rules.',
    CONSTRAINT pk_vendor PRIMARY KEY(`vendor_id`)
) COMMENT 'Master reference table for vendor. Referenced by vendor_id.';

ALTER SCHEMA `clinical_trials_ecm`.`finance` SET TAGS ('dbx_division' = 'corporate');

ALTER SCHEMA `clinical_trials_ecm`.`finance` SET TAGS ('dbx_domain' = 'finance');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ADD CONSTRAINT `fk_finance_study_budget_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ADD CONSTRAINT `fk_finance_study_budget_change_order_id` FOREIGN KEY (`change_order_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`change_order`(`change_order_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ADD CONSTRAINT `fk_finance_study_budget_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ADD CONSTRAINT `fk_finance_study_budget_dmp_id` FOREIGN KEY (`dmp_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`dmp`(`dmp_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ADD CONSTRAINT `fk_finance_study_budget_gl_account_id` FOREIGN KEY (`gl_account_id`) REFERENCES `clinical_trials_ecm`.`finance`.`gl_account`(`gl_account_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ADD CONSTRAINT `fk_finance_study_budget_master_agreement_id` FOREIGN KEY (`master_agreement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`master_agreement`(`master_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ADD CONSTRAINT `fk_finance_study_budget_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ADD CONSTRAINT `fk_finance_study_budget_pipeline_asset_id` FOREIGN KEY (`pipeline_asset_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`pipeline_asset`(`pipeline_asset_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ADD CONSTRAINT `fk_finance_study_budget_program_strategic_plan_id` FOREIGN KEY (`program_strategic_plan_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_strategic_plan`(`program_strategic_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ADD CONSTRAINT `fk_finance_study_budget_proposal_id` FOREIGN KEY (`proposal_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`proposal`(`proposal_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ADD CONSTRAINT `fk_finance_study_budget_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ADD CONSTRAINT `fk_finance_study_budget_sample_size_calc_id` FOREIGN KEY (`sample_size_calc_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sample_size_calc`(`sample_size_calc_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ADD CONSTRAINT `fk_finance_study_budget_scope_of_work_id` FOREIGN KEY (`scope_of_work_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`scope_of_work`(`scope_of_work_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ADD CONSTRAINT `fk_finance_study_budget_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ADD CONSTRAINT `fk_finance_study_budget_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` SET TAGS ('dbx_domain' = 'finance');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` SET TAGS ('dbx_subdomain' = 'budget_planning');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `change_order_id` SET TAGS ('dbx_business_glossary_term' = 'Change Order Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `dmp_id` SET TAGS ('dbx_business_glossary_term' = 'Dmp Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `master_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `pipeline_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `program_strategic_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Program Plan Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `proposal_id` SET TAGS ('dbx_business_glossary_term' = 'Proposal Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `sample_size_calc_id` SET TAGS ('dbx_business_glossary_term' = 'Sample Size Calc Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `scope_of_work_id` SET TAGS ('dbx_business_glossary_term' = 'Scope Of Work Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|withdrawn');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `budget_number` SET TAGS ('dbx_value_regex' = '^BDG-[0-9]{4}-[A-Z0-9]{6,12}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `budget_type` SET TAGS ('dbx_value_regex' = 'original|amendment|supplemental|contingency');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `budget_version` SET TAGS ('dbx_business_glossary_term' = 'Budget Version Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `company_code` SET TAGS ('dbx_business_glossary_term' = 'SAP Company Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `company_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `contingency_amount` SET TAGS ('dbx_business_glossary_term' = 'Contingency Reserve Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `contingency_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `cost_category` SET TAGS ('dbx_value_regex' = 'direct|indirect|overhead|pass_through|investigator_grant|patient_stipend');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Transaction Currency Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `direct_cost_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `indirect_cost_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `investigator_grant_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `is_pass_through_billable` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Billable Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `is_sox_controlled` SET TAGS ('dbx_business_glossary_term' = 'SOX Controlled Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `overhead_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `pass_through_estimate_amount` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Cost Estimate Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `pass_through_estimate_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `patient_stipend_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `profit_center_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4,10}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `sponsor_contract_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `total_budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `wbs_element_code` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Element Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`study_budget` ALTER COLUMN `wbs_element_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,20}(-[A-Z0-9]{1,10}){0,5}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` SET TAGS ('dbx_domain' = 'finance');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` SET TAGS ('dbx_subdomain' = 'budget_planning');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `activity_type_group` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{1,20}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `annual_budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `business_area_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,4}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{2,20}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `company_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,4}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `controlling_area_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,4}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `cost_allocation_method` SET TAGS ('dbx_value_regex' = 'direct|assessment|distribution|activity_based|statistical');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Created By User ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `created_by_user` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{1,12}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Currency Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `department_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{1,20}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `fiscal_year_variant` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_value_regex' = '^[0-9]{6,10}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `hierarchy_area` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Hierarchy Area');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `hierarchy_area` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{1,30}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `hierarchy_level` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Hierarchy Level');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `is_intercompany` SET TAGS ('dbx_business_glossary_term' = 'Intercompany Cost Center Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `is_statistical` SET TAGS ('dbx_business_glossary_term' = 'Statistical Cost Center Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `last_modified_by_user` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `last_modified_by_user` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{1,12}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `lock_indicator` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Lock Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `cost_center_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `overhead_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Overhead Rate Percentage');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `overhead_rate_pct` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `plan_lock_indicator` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Plan Lock Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `profit_center_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{1,20}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `region_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,10}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `sap_object_class` SET TAGS ('dbx_value_regex' = 'OCCA|OACC|OPRO|OSTA');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `short_name` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Short Name');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `short_name` SET TAGS ('dbx_value_regex' = '^.{1,20}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `short_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{1,20}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `cost_center_status` SET TAGS ('dbx_value_regex' = 'active|inactive|locked|pending_activation|closed');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `cost_center_type` SET TAGS ('dbx_value_regex' = 'direct|indirect|overhead|project|administrative');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `wbs_element_code` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Element Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`cost_center` ALTER COLUMN `wbs_element_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9._-]{1,24}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ADD CONSTRAINT `fk_finance_gl_account_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ADD CONSTRAINT `fk_finance_gl_account_parent_gl_account_id` FOREIGN KEY (`parent_gl_account_id`) REFERENCES `clinical_trials_ecm`.`finance`.`gl_account`(`gl_account_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` SET TAGS ('dbx_domain' = 'finance');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` SET TAGS ('dbx_subdomain' = 'budget_planning');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `account_currency` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Currency (ISO 4217)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `account_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `account_group` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Group');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `account_hierarchy_node` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Hierarchy Node');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `account_long_description` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Long Description');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `account_name` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Name');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `account_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `account_number` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `account_number` SET TAGS ('dbx_value_regex' = '^[0-9]{6,10}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `account_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `account_number` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `account_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `account_status` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Status');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `account_status` SET TAGS ('dbx_value_regex' = 'active|blocked|marked_for_deletion');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `account_type` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Type');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `account_type` SET TAGS ('dbx_value_regex' = 'asset|liability|equity|revenue|expense');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `accrual_engine_relevant` SET TAGS ('dbx_business_glossary_term' = 'Accrual Engine Relevant Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `alternative_account_number` SET TAGS ('dbx_business_glossary_term' = 'Alternative General Ledger (GL) Account Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `alternative_account_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `alternative_account_number` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `alternative_account_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `balance_in_local_currency` SET TAGS ('dbx_business_glossary_term' = 'Balance in Local Currency Only Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `chart_of_accounts` SET TAGS ('dbx_business_glossary_term' = 'Chart of Accounts (COA) Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `chart_of_accounts` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `clinical_cost_category` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Cost Category');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `commitment_item` SET TAGS ('dbx_business_glossary_term' = 'Commitment Item Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `company_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `controlling_area` SET TAGS ('dbx_business_glossary_term' = 'Controlling Area (CO Area) Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `controlling_area` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `cost_element_category` SET TAGS ('dbx_value_regex' = 'primary|secondary|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `created_on` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Creation Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `field_status_group` SET TAGS ('dbx_business_glossary_term' = 'Field Status Group Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `field_status_group` SET TAGS ('dbx_value_regex' = '^G[0-9]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `financial_statement_version` SET TAGS ('dbx_business_glossary_term' = 'Financial Statement Version (FSV)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `functional_area` SET TAGS ('dbx_business_glossary_term' = 'Functional Area Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `house_bank` SET TAGS ('dbx_business_glossary_term' = 'House Bank ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `ifrs_account_mapping` SET TAGS ('dbx_business_glossary_term' = 'International Financial Reporting Standards (IFRS) Account Mapping Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `interest_indicator` SET TAGS ('dbx_business_glossary_term' = 'Interest Calculation Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `is_planning_blocked` SET TAGS ('dbx_business_glossary_term' = 'Planning Blocked Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `is_posting_blocked` SET TAGS ('dbx_business_glossary_term' = 'Posting Blocked Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `is_reconciliation_account` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Account Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `is_tax_relevant` SET TAGS ('dbx_business_glossary_term' = 'Tax Relevant Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `last_changed_by` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Last Changed By User');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `last_changed_on` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Last Changed Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `line_item_display` SET TAGS ('dbx_business_glossary_term' = 'Line Item Display Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `open_item_management` SET TAGS ('dbx_business_glossary_term' = 'Open Item Management Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `open_item_management` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `profit_loss_statement_account` SET TAGS ('dbx_business_glossary_term' = 'Profit and Loss (P&L) Statement Account Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `reconciliation_account_type` SET TAGS ('dbx_value_regex' = 'vendor|customer|asset|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `revaluation_relevant` SET TAGS ('dbx_business_glossary_term' = 'Foreign Currency Revaluation Relevant Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `sort_key` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Sort Key');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `sort_key` SET TAGS ('dbx_value_regex' = '^[0-9]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Identifier');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `sox_relevant` SET TAGS ('dbx_business_glossary_term' = 'Sarbanes-Oxley (SOX) Relevant Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `tax_category` SET TAGS ('dbx_business_glossary_term' = 'Tax Category Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `tolerance_group` SET TAGS ('dbx_business_glossary_term' = 'Tolerance Group Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `valid_from_date` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Valid From Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`gl_account` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Created By User');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ADD CONSTRAINT `fk_finance_journal_entry_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ADD CONSTRAINT `fk_finance_journal_entry_gl_account_id` FOREIGN KEY (`gl_account_id`) REFERENCES `clinical_trials_ecm`.`finance`.`gl_account`(`gl_account_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ADD CONSTRAINT `fk_finance_journal_entry_payroll_record_id` FOREIGN KEY (`payroll_record_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`payroll_record`(`payroll_record_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ADD CONSTRAINT `fk_finance_journal_entry_primary_journal_employee_id` FOREIGN KEY (`primary_journal_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ADD CONSTRAINT `fk_finance_journal_entry_sponsor_invoice_id` FOREIGN KEY (`sponsor_invoice_id`) REFERENCES `clinical_trials_ecm`.`finance`.`sponsor_invoice`(`sponsor_invoice_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ADD CONSTRAINT `fk_finance_journal_entry_vendor_invoice_id` FOREIGN KEY (`vendor_invoice_id`) REFERENCES `clinical_trials_ecm`.`finance`.`vendor_invoice`(`vendor_invoice_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` SET TAGS ('dbx_domain' = 'finance');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` SET TAGS ('dbx_subdomain' = 'transaction_processing');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `payroll_record_id` SET TAGS ('dbx_business_glossary_term' = 'Payroll Record Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `primary_journal_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Posting User ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `primary_journal_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `primary_journal_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `primary_journal_employee_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `sponsor_invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Invoice Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `vendor_invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Vendor Invoice Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `accrual_basis` SET TAGS ('dbx_value_regex' = 'manual|system_generated|recurring|milestone_based');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Journal Entry Approval Status');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|not_required');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `company_code` SET TAGS ('dbx_business_glossary_term' = 'SAP Company Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `cost_category` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Cost Category');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `cost_category` SET TAGS ('dbx_value_regex' = 'investigator_grant|site_payment|patient_stipend|pass_through|cro_fee|lab_cost');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `debit_credit_indicator` SET TAGS ('dbx_business_glossary_term' = 'Debit/Credit Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `debit_credit_indicator` SET TAGS ('dbx_value_regex' = 'D|C');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `document_date` SET TAGS ('dbx_business_glossary_term' = 'Financial Document Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `document_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Financial Document Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `document_type_code` SET TAGS ('dbx_business_glossary_term' = 'SAP Financial Document Type Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `entry_type` SET TAGS ('dbx_business_glossary_term' = 'Journal Entry Type');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `entry_type` SET TAGS ('dbx_value_regex' = 'original|reversal|accrual|adjustment|reclassification|intercompany');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Currency Exchange Rate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `header_text` SET TAGS ('dbx_business_glossary_term' = 'Journal Entry Header Text');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `internal_order_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Internal Order Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `is_reversed` SET TAGS ('dbx_business_glossary_term' = 'Is Reversed Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `line_item_number` SET TAGS ('dbx_business_glossary_term' = 'Journal Entry Line Item Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `line_item_text` SET TAGS ('dbx_business_glossary_term' = 'Journal Entry Line Item Text');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `local_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `posting_date` SET TAGS ('dbx_business_glossary_term' = 'Journal Entry Posting Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `posting_status` SET TAGS ('dbx_business_glossary_term' = 'Journal Entry Posting Status');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `posting_status` SET TAGS ('dbx_value_regex' = 'draft|posted|reversed|parked|held|cleared');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `sponsor_billable` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Billable Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `tax_code` SET TAGS ('dbx_business_glossary_term' = 'SAP Tax Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `transaction_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`journal_entry` ALTER COLUMN `wbs_element_code` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Element Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ADD CONSTRAINT `fk_finance_sponsor_invoice_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ADD CONSTRAINT `fk_finance_sponsor_invoice_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ADD CONSTRAINT `fk_finance_sponsor_invoice_gl_account_id` FOREIGN KEY (`gl_account_id`) REFERENCES `clinical_trials_ecm`.`finance`.`gl_account`(`gl_account_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ADD CONSTRAINT `fk_finance_sponsor_invoice_icsr_id` FOREIGN KEY (`icsr_id`) REFERENCES `clinical_trials_ecm`.`safety`.`icsr`(`icsr_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ADD CONSTRAINT `fk_finance_sponsor_invoice_organization_contact_id` FOREIGN KEY (`organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ADD CONSTRAINT `fk_finance_sponsor_invoice_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ADD CONSTRAINT `fk_finance_sponsor_invoice_sdtm_dataset_id` FOREIGN KEY (`sdtm_dataset_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`sdtm_dataset`(`sdtm_dataset_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ADD CONSTRAINT `fk_finance_sponsor_invoice_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ADD CONSTRAINT `fk_finance_sponsor_invoice_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ADD CONSTRAINT `fk_finance_sponsor_invoice_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` SET TAGS ('dbx_domain' = 'finance');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` SET TAGS ('dbx_subdomain' = 'transaction_processing');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `icsr_id` SET TAGS ('dbx_business_glossary_term' = 'Icsr Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Billing Sponsor Contact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `sdtm_dataset_id` SET TAGS ('dbx_business_glossary_term' = 'Sdtm Dataset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Contract ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `amount_paid` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `amount_paid` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Approved Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `credit_memo_ref_invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Credit Memo Reference Invoice Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Invoice Currency Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `discount_amount` SET TAGS ('dbx_business_glossary_term' = 'Invoice Discount Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `discount_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `discount_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Invoice Dispute Reason');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_value_regex' = 'scope_dispute|pricing_error|missing_backup|duplicate_invoice|unauthorized_charges|other');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `document_type` SET TAGS ('dbx_business_glossary_term' = 'AR Document Type');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `document_type` SET TAGS ('dbx_value_regex' = 'invoice|credit_memo|debit_memo');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Due Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange Rate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `functional_currency_amount` SET TAGS ('dbx_business_glossary_term' = 'Functional Currency Net Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `functional_currency_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `functional_currency_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Invoice Gross Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `gross_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `gross_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `invoice_number` SET TAGS ('dbx_value_regex' = '^INV-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `is_pass_through` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Cost Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Invoice Net Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `net_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `net_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `outstanding_balance` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `outstanding_balance` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `pass_through_amount` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Cost Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `pass_through_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `pass_through_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Invoice Payment Status');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `ref` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Invoice Reference Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `revenue_recognition_method` SET TAGS ('dbx_value_regex' = 'milestone|percentage_of_completion|time_and_materials|fixed_fee|pass_through');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `sap_ar_document_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Accounts Receivable (AR) Document Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `sponsor_po_number` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Purchase Order (PO) Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `submitted_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Submitted Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Invoice Tax Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `tax_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `tax_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`sponsor_invoice` ALTER COLUMN `wbs_element` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Element');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ADD CONSTRAINT `fk_finance_invoice_line_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ADD CONSTRAINT `fk_finance_invoice_line_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ADD CONSTRAINT `fk_finance_invoice_line_deliverable_id` FOREIGN KEY (`deliverable_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`deliverable`(`deliverable_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ADD CONSTRAINT `fk_finance_invoice_line_finance_billing_milestone_id` FOREIGN KEY (`finance_billing_milestone_id`) REFERENCES `clinical_trials_ecm`.`finance`.`finance_billing_milestone`(`finance_billing_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ADD CONSTRAINT `fk_finance_invoice_line_gl_account_id` FOREIGN KEY (`gl_account_id`) REFERENCES `clinical_trials_ecm`.`finance`.`gl_account`(`gl_account_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ADD CONSTRAINT `fk_finance_invoice_line_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ADD CONSTRAINT `fk_finance_invoice_line_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ADD CONSTRAINT `fk_finance_invoice_line_proposal_line_id` FOREIGN KEY (`proposal_line_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`proposal_line`(`proposal_line_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ADD CONSTRAINT `fk_finance_invoice_line_rate_card_id` FOREIGN KEY (`rate_card_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`rate_card`(`rate_card_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ADD CONSTRAINT `fk_finance_invoice_line_sponsor_invoice_id` FOREIGN KEY (`sponsor_invoice_id`) REFERENCES `clinical_trials_ecm`.`finance`.`sponsor_invoice`(`sponsor_invoice_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ADD CONSTRAINT `fk_finance_invoice_line_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ADD CONSTRAINT `fk_finance_invoice_line_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ADD CONSTRAINT `fk_finance_invoice_line_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` SET TAGS ('dbx_domain' = 'finance');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` SET TAGS ('dbx_subdomain' = 'transaction_processing');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `deliverable_id` SET TAGS ('dbx_business_glossary_term' = 'Deliverable Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `finance_billing_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Milestone ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Panel Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `proposal_line_id` SET TAGS ('dbx_business_glossary_term' = 'Proposal Line Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `rate_card_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Card Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `sponsor_invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Contract ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `accrual_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `accrual_period` SET TAGS ('dbx_value_regex' = '^d{4}-(0[1-9]|1[0-2])$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|on_hold');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `billing_category` SET TAGS ('dbx_value_regex' = 'professional_fee|pass_through|investigator_grant|lab_fee|patient_stipend|regulatory_fee');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `billing_period_end` SET TAGS ('dbx_business_glossary_term' = 'Billing Period End Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `billing_period_start` SET TAGS ('dbx_business_glossary_term' = 'Billing Period Start Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `credit_note_ref` SET TAGS ('dbx_business_glossary_term' = 'Credit Note Reference');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `discount_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `is_billable` SET TAGS ('dbx_business_glossary_term' = 'Is Billable Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `is_pass_through` SET TAGS ('dbx_business_glossary_term' = 'Is Pass-Through Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `line_amount` SET TAGS ('dbx_business_glossary_term' = 'Invoice Line Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `line_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `line_item_number` SET TAGS ('dbx_business_glossary_term' = 'Invoice Line Item Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `line_number` SET TAGS ('dbx_business_glossary_term' = 'Invoice Line Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `line_status` SET TAGS ('dbx_business_glossary_term' = 'Invoice Line Status');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `line_status` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|approved|disputed|credited|cancelled');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Invoice Line Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `net_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `pass_through_invoice_ref` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Vendor Invoice Reference');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `pass_through_vendor` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Vendor Name');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `quantity` SET TAGS ('dbx_business_glossary_term' = 'Billed Quantity');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `revenue_recognition_method` SET TAGS ('dbx_value_regex' = 'milestone|percentage_of_completion|time_and_materials|fixed_fee|pass_through');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `tax_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `total_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Invoice Line Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `total_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `unit_price` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `visit_name` SET TAGS ('dbx_business_glossary_term' = 'Study Visit Name');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `visit_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`invoice_line` ALTER COLUMN `wbs_element` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Element');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ADD CONSTRAINT `fk_finance_site_payment_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ADD CONSTRAINT `fk_finance_site_payment_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ADD CONSTRAINT `fk_finance_site_payment_finance_billing_milestone_id` FOREIGN KEY (`finance_billing_milestone_id`) REFERENCES `clinical_trials_ecm`.`finance`.`finance_billing_milestone`(`finance_billing_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ADD CONSTRAINT `fk_finance_site_payment_gl_account_id` FOREIGN KEY (`gl_account_id`) REFERENCES `clinical_trials_ecm`.`finance`.`gl_account`(`gl_account_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ADD CONSTRAINT `fk_finance_site_payment_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ADD CONSTRAINT `fk_finance_site_payment_original_payment_site_payment_id` FOREIGN KEY (`original_payment_site_payment_id`) REFERENCES `clinical_trials_ecm`.`finance`.`site_payment`(`site_payment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ADD CONSTRAINT `fk_finance_site_payment_site_agreement_id` FOREIGN KEY (`site_agreement_id`) REFERENCES `clinical_trials_ecm`.`site`.`site_agreement`(`site_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ADD CONSTRAINT `fk_finance_site_payment_site_monitoring_visit_id` FOREIGN KEY (`site_monitoring_visit_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_visit`(`monitoring_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ADD CONSTRAINT `fk_finance_site_payment_study_budget_id` FOREIGN KEY (`study_budget_id`) REFERENCES `clinical_trials_ecm`.`finance`.`study_budget`(`study_budget_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ADD CONSTRAINT `fk_finance_site_payment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ADD CONSTRAINT `fk_finance_site_payment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ADD CONSTRAINT `fk_finance_site_payment_vendor_invoice_id` FOREIGN KEY (`vendor_invoice_id`) REFERENCES `clinical_trials_ecm`.`finance`.`vendor_invoice`(`vendor_invoice_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` SET TAGS ('dbx_domain' = 'finance');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` SET TAGS ('dbx_subdomain' = 'transaction_processing');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `finance_billing_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Payment Milestone ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `original_payment_site_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Original Payment ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `site_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Agreement (CTA) ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `site_monitoring_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `study_budget_id` SET TAGS ('dbx_business_glossary_term' = 'Study Budget Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `vendor_invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Invoice ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `accrual_period` SET TAGS ('dbx_value_regex' = '^d{4}-(0[1-9]|1[0-2])$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_business_glossary_term' = 'Site Bank Account Reference');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `bank_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `ctms_payment_ref` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Payment Reference');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Currency Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange Rate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `functional_currency_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `functional_currency_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `is_advance_payment` SET TAGS ('dbx_business_glossary_term' = 'Advance Payment Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `is_pass_through` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Cost Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `net_payment_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `net_payment_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Payment Amount (Gross)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `payment_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `payment_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire|ACH|check|SEPA|SWIFT|EFT');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'unreconciled|reconciled|disputed|partial|written_off');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `reversal_indicator` SET TAGS ('dbx_business_glossary_term' = 'Payment Reversal Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `sap_ap_document_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Accounts Payable (AP) Document Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `sap_payment_run_reference` SET TAGS ('dbx_business_glossary_term' = 'SAP Payment Run ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `sap_vendor_code` SET TAGS ('dbx_business_glossary_term' = 'SAP Vendor ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `wbs_element` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Element');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`site_payment` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ADD CONSTRAINT `fk_finance_patient_stipend_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ADD CONSTRAINT `fk_finance_patient_stipend_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ADD CONSTRAINT `fk_finance_patient_stipend_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ADD CONSTRAINT `fk_finance_patient_stipend_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_ecm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ADD CONSTRAINT `fk_finance_patient_stipend_gl_account_id` FOREIGN KEY (`gl_account_id`) REFERENCES `clinical_trials_ecm`.`finance`.`gl_account`(`gl_account_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ADD CONSTRAINT `fk_finance_patient_stipend_reissue_of_stipend_id` FOREIGN KEY (`reissue_of_stipend_id`) REFERENCES `clinical_trials_ecm`.`finance`.`patient_stipend`(`patient_stipend_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ADD CONSTRAINT `fk_finance_patient_stipend_study_budget_id` FOREIGN KEY (`study_budget_id`) REFERENCES `clinical_trials_ecm`.`finance`.`study_budget`(`study_budget_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ADD CONSTRAINT `fk_finance_patient_stipend_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ADD CONSTRAINT `fk_finance_patient_stipend_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ADD CONSTRAINT `fk_finance_patient_stipend_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ADD CONSTRAINT `fk_finance_patient_stipend_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ADD CONSTRAINT `fk_finance_patient_stipend_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` SET TAGS ('dbx_domain' = 'finance');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` SET TAGS ('dbx_subdomain' = 'transaction_processing');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `study_budget_id` SET TAGS ('dbx_business_glossary_term' = 'Study Budget Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Study Visit Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `subject_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Study Visit ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `accrual_period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(0[1-9]|1[0-2])$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Stipend Approval Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code (ISO 3166-1 Alpha-3)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `fmv_compliant` SET TAGS ('dbx_business_glossary_term' = 'Fair Market Value (FMV) Compliant Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `fmv_rate` SET TAGS ('dbx_business_glossary_term' = 'Fair Market Value (FMV) Rate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `irb_approval_reference` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board (IRB) Approval Reference');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `net_payment_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `net_payment_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Stipend Notes');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `payment_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `payment_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'prepaid_card|check|bank_transfer|digital_wallet|money_order');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'pending|approved|processed|paid|cancelled|on_hold');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `receipt_received` SET TAGS ('dbx_business_glossary_term' = 'Receipt Received Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `receipt_required` SET TAGS ('dbx_business_glossary_term' = 'Receipt Required Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `stipend_number` SET TAGS ('dbx_business_glossary_term' = 'Stipend Reference Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `stipend_number` SET TAGS ('dbx_value_regex' = '^STI-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `stipend_type` SET TAGS ('dbx_value_regex' = 'participation_fee|travel_reimbursement|meal_allowance|lodging_reimbursement|caregiver_allowance|incidental_expense');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `subject_consent_verified` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Verified Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `tax_form_type` SET TAGS ('dbx_value_regex' = '1099-MISC|1099-NEC|W-2|none|other');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `tax_reportable` SET TAGS ('dbx_business_glossary_term' = 'Tax Reportable Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `tax_withheld_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `tax_withheld_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`patient_stipend` ALTER COLUMN `wbs_element` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Element');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ADD CONSTRAINT `fk_finance_purchase_order_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ADD CONSTRAINT `fk_finance_purchase_order_bioanalytical_assay_id` FOREIGN KEY (`bioanalytical_assay_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay`(`bioanalytical_assay_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ADD CONSTRAINT `fk_finance_purchase_order_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ADD CONSTRAINT `fk_finance_purchase_order_gl_account_id` FOREIGN KEY (`gl_account_id`) REFERENCES `clinical_trials_ecm`.`finance`.`gl_account`(`gl_account_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ADD CONSTRAINT `fk_finance_purchase_order_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_ecm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ADD CONSTRAINT `fk_finance_purchase_order_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ADD CONSTRAINT `fk_finance_purchase_order_study_budget_id` FOREIGN KEY (`study_budget_id`) REFERENCES `clinical_trials_ecm`.`finance`.`study_budget`(`study_budget_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ADD CONSTRAINT `fk_finance_purchase_order_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ADD CONSTRAINT `fk_finance_purchase_order_subcontract_id` FOREIGN KEY (`subcontract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`subcontract`(`subcontract_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ADD CONSTRAINT `fk_finance_purchase_order_vendor_id` FOREIGN KEY (`vendor_id`) REFERENCES `clinical_trials_ecm`.`finance`.`vendor`(`vendor_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` SET TAGS ('dbx_domain' = 'finance');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` SET TAGS ('dbx_subdomain' = 'transaction_processing');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `purchase_order_id` SET TAGS ('dbx_business_glossary_term' = 'Purchase Order (PO) ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `bioanalytical_assay_id` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Assay Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `study_budget_id` SET TAGS ('dbx_business_glossary_term' = 'Study Budget Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `subcontract_id` SET TAGS ('dbx_business_glossary_term' = 'Subcontract Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `accrual_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Workflow Status');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|escalated');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Requested Delivery Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `delivery_terms` SET TAGS ('dbx_business_glossary_term' = 'Delivery Terms (Incoterms)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `functional_currency_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `goods_receipt_date` SET TAGS ('dbx_business_glossary_term' = 'Goods/Service Receipt Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `goods_receipt_status` SET TAGS ('dbx_business_glossary_term' = 'Goods/Service Receipt Status');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `goods_receipt_status` SET TAGS ('dbx_value_regex' = 'not_received|partially_received|fully_received');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `invoice_status` SET TAGS ('dbx_value_regex' = 'not_invoiced|partially_invoiced|fully_invoiced|disputed');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `invoiced_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Purchase Order (PO) Net Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `net_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `pass_through_flag` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Cost Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `po_date` SET TAGS ('dbx_business_glossary_term' = 'Purchase Order (PO) Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `po_gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Purchase Order (PO) Gross Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `po_gross_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `po_number` SET TAGS ('dbx_business_glossary_term' = 'Purchase Order (PO) Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `po_number` SET TAGS ('dbx_value_regex' = '^PO-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `po_status` SET TAGS ('dbx_business_glossary_term' = 'Purchase Order (PO) Status');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `po_type` SET TAGS ('dbx_business_glossary_term' = 'Purchase Order (PO) Type');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `po_type` SET TAGS ('dbx_value_regex' = 'standard|blanket|framework|service|emergency');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `purchasing_org` SET TAGS ('dbx_business_glossary_term' = 'Purchasing Organization');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `sap_mm_document_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Materials Management (MM) Document Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `service_description` SET TAGS ('dbx_business_glossary_term' = 'Service/Goods Description');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `tax_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `wbs_element` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Element');

ALTER TABLE `clinical_trials_ecm`.`finance`.`purchase_order` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By (User ID)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ADD CONSTRAINT `fk_finance_vendor_invoice_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ADD CONSTRAINT `fk_finance_vendor_invoice_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ADD CONSTRAINT `fk_finance_vendor_invoice_gl_account_id` FOREIGN KEY (`gl_account_id`) REFERENCES `clinical_trials_ecm`.`finance`.`gl_account`(`gl_account_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ADD CONSTRAINT `fk_finance_vendor_invoice_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ADD CONSTRAINT `fk_finance_vendor_invoice_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ADD CONSTRAINT `fk_finance_vendor_invoice_purchase_order_id` FOREIGN KEY (`purchase_order_id`) REFERENCES `clinical_trials_ecm`.`finance`.`purchase_order`(`purchase_order_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ADD CONSTRAINT `fk_finance_vendor_invoice_rems_program_id` FOREIGN KEY (`rems_program_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`rems_program`(`rems_program_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ADD CONSTRAINT `fk_finance_vendor_invoice_site_monitoring_visit_id` FOREIGN KEY (`site_monitoring_visit_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_visit`(`monitoring_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ADD CONSTRAINT `fk_finance_vendor_invoice_specimen_shipment_id` FOREIGN KEY (`specimen_shipment_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`specimen_shipment`(`specimen_shipment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ADD CONSTRAINT `fk_finance_vendor_invoice_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ADD CONSTRAINT `fk_finance_vendor_invoice_subcontract_id` FOREIGN KEY (`subcontract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`subcontract`(`subcontract_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ADD CONSTRAINT `fk_finance_vendor_invoice_vendor_id` FOREIGN KEY (`vendor_id`) REFERENCES `clinical_trials_ecm`.`finance`.`vendor`(`vendor_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` SET TAGS ('dbx_domain' = 'finance');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` SET TAGS ('dbx_subdomain' = 'transaction_processing');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `purchase_order_id` SET TAGS ('dbx_business_glossary_term' = 'Purchase Order (PO) ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `rems_program_id` SET TAGS ('dbx_business_glossary_term' = 'Rems Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `site_monitoring_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `specimen_shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Specimen Shipment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `subcontract_id` SET TAGS ('dbx_business_glossary_term' = 'Subcontract Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `accrual_period` SET TAGS ('dbx_value_regex' = '^d{4}-(0[1-9]|1[0-2])$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Approval Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Invoice Currency Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Invoice Dispute Reason');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Due Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange Rate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `goods_receipt_number` SET TAGS ('dbx_business_glossary_term' = 'Goods Receipt (GR) Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Invoice Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `gross_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Vendor Invoice Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `invoice_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `invoice_type` SET TAGS ('dbx_value_regex' = 'standard|credit_memo|debit_memo|pro_forma|recurring|pass_through');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `is_pass_through` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Cost Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `local_currency_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Invoice Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `net_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `payment_block_indicator` SET TAGS ('dbx_value_regex' = 'unblocked|manual_block|dispute_block|compliance_block');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|ach|check|credit_card|direct_debit');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `posting_date` SET TAGS ('dbx_business_glossary_term' = 'Accounting Posting Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `receipt_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Receipt Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `sap_fi_document_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Financial (FI) Accounts Payable (AP) Document Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `service_category` SET TAGS ('dbx_business_glossary_term' = 'Clinical Service Category');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `sponsor_reimbursement_status` SET TAGS ('dbx_value_regex' = 'not_applicable|pending|invoiced|reimbursed|disputed');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `tax_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `three_way_match_status` SET TAGS ('dbx_business_glossary_term' = 'Three-Way Match Status');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `three_way_match_status` SET TAGS ('dbx_value_regex' = 'not_started|po_matched|gr_matched|fully_matched|exception');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor_invoice` ALTER COLUMN `wbs_element` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Element');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_vendor_invoice_id` FOREIGN KEY (`vendor_invoice_id`) REFERENCES `clinical_trials_ecm`.`finance`.`vendor_invoice`(`vendor_invoice_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_agreement_billing_milestone_id` FOREIGN KEY (`agreement_billing_milestone_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`agreement_billing_milestone`(`agreement_billing_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_agreement_investigator_grant_id` FOREIGN KEY (`agreement_investigator_grant_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`investigator_grant`(`investigator_grant_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_ecm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_bioanalytical_assay_id` FOREIGN KEY (`bioanalytical_assay_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay`(`bioanalytical_assay_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_budget_line_id` FOREIGN KEY (`budget_line_id`) REFERENCES `clinical_trials_ecm`.`finance`.`budget_line`(`budget_line_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_change_order_id` FOREIGN KEY (`change_order_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`change_order`(`change_order_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_ecm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_deliverable_id` FOREIGN KEY (`deliverable_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`deliverable`(`deliverable_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_dosing_regimen_id` FOREIGN KEY (`dosing_regimen_id`) REFERENCES `clinical_trials_ecm`.`study`.`dosing_regimen`(`dosing_regimen_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_dsmb_review_id` FOREIGN KEY (`dsmb_review_id`) REFERENCES `clinical_trials_ecm`.`safety`.`dsmb_review`(`dsmb_review_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_edc_study_build_id` FOREIGN KEY (`edc_study_build_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`edc_study_build`(`edc_study_build_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_ecm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_ecm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_finance_billing_milestone_id` FOREIGN KEY (`finance_billing_milestone_id`) REFERENCES `clinical_trials_ecm`.`finance`.`finance_billing_milestone`(`finance_billing_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_gl_account_id` FOREIGN KEY (`gl_account_id`) REFERENCES `clinical_trials_ecm`.`finance`.`gl_account`(`gl_account_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_icf_amendment_id` FOREIGN KEY (`icf_amendment_id`) REFERENCES `clinical_trials_ecm`.`consent`.`icf_amendment`(`icf_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_ecm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_primary_investigational_site_id` FOREIGN KEY (`primary_investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_monitoring_cra_assignment_id` FOREIGN KEY (`monitoring_cra_assignment_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment`(`monitoring_cra_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_pipeline_asset_id` FOREIGN KEY (`pipeline_asset_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`pipeline_asset`(`pipeline_asset_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_pk_sampling_schedule_id` FOREIGN KEY (`pk_sampling_schedule_id`) REFERENCES `clinical_trials_ecm`.`study`.`pk_sampling_schedule`(`pk_sampling_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_program_development_milestone_id` FOREIGN KEY (`program_development_milestone_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_development_milestone`(`program_development_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_proposal_line_id` FOREIGN KEY (`proposal_line_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`proposal_line`(`proposal_line_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_protocol_lab_schedule_id` FOREIGN KEY (`protocol_lab_schedule_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule`(`protocol_lab_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_purchase_order_id` FOREIGN KEY (`purchase_order_id`) REFERENCES `clinical_trials_ecm`.`finance`.`purchase_order`(`purchase_order_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_rate_card_id` FOREIGN KEY (`rate_card_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`rate_card`(`rate_card_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_regulatory_commitment_id` FOREIGN KEY (`regulatory_commitment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`commitment`(`commitment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_scope_of_work_id` FOREIGN KEY (`scope_of_work_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`scope_of_work`(`scope_of_work_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_site_agreement_id` FOREIGN KEY (`site_agreement_id`) REFERENCES `clinical_trials_ecm`.`site`.`site_agreement`(`site_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_site_monitoring_visit_id` FOREIGN KEY (`site_monitoring_visit_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_visit`(`monitoring_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_specimen_shipment_id` FOREIGN KEY (`specimen_shipment_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`specimen_shipment`(`specimen_shipment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_sponsor_invoice_id` FOREIGN KEY (`sponsor_invoice_id`) REFERENCES `clinical_trials_ecm`.`finance`.`sponsor_invoice`(`sponsor_invoice_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_study_budget_id` FOREIGN KEY (`study_budget_id`) REFERENCES `clinical_trials_ecm`.`finance`.`study_budget`(`study_budget_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_billing_trial_subject_id` FOREIGN KEY (`billing_trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_vendor_id` FOREIGN KEY (`vendor_id`) REFERENCES `clinical_trials_ecm`.`finance`.`vendor`(`vendor_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_original_vendor_invoice_id` FOREIGN KEY (`original_vendor_invoice_id`) REFERENCES `clinical_trials_ecm`.`finance`.`vendor_invoice`(`vendor_invoice_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ADD CONSTRAINT `fk_finance_accrual_visit_procedure_id` FOREIGN KEY (`visit_procedure_id`) REFERENCES `clinical_trials_ecm`.`study`.`visit_procedure`(`visit_procedure_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` SET TAGS ('dbx_domain' = 'finance');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` SET TAGS ('dbx_subdomain' = 'transaction_processing');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `vendor_invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Vendor Invoice Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `agreement_billing_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Billing Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `agreement_investigator_grant_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Investigator Grant Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Study Country Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `database_lock_event_id` SET TAGS ('dbx_business_glossary_term' = 'Biostatistics Dbl Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `dsmb_review_id` SET TAGS ('dbx_business_glossary_term' = 'Dsmb Review Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Epoch Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `primary_investigational_site_id` SET TAGS ('dbx_renamed_from' = 'investigational_site_id');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `program_development_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Program Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `purchase_order_id` SET TAGS ('dbx_business_glossary_term' = 'Purchase Order Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `regulatory_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Regulatory Commitment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `site_monitoring_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `sponsor_invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `study_budget_id` SET TAGS ('dbx_business_glossary_term' = 'Budget ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Contract ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `amount` SET TAGS ('dbx_business_glossary_term' = 'Accrual Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `amount_usd` SET TAGS ('dbx_business_glossary_term' = 'Accrual Amount USD');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `amount_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `basis` SET TAGS ('dbx_business_glossary_term' = 'Accrual Basis');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `basis` SET TAGS ('dbx_value_regex' = 'enrollment_based|visit_based|milestone_based|time_based|unit_based');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Accrual Calculation Method');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `calculation_method` SET TAGS ('dbx_value_regex' = 'manual|system_calculated|spreadsheet_upload|ctms_derived|edl_feed');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `company_code` SET TAGS ('dbx_business_glossary_term' = 'SAP Company Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `cumulative_accrual_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `is_pass_through` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Cost Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `is_sox_controlled` SET TAGS ('dbx_business_glossary_term' = 'Sarbanes-Oxley (SOX) Controlled Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^ACR-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `period` SET TAGS ('dbx_business_glossary_term' = 'Accrual Period');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(0[1-9]|1[0-2])$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `prior_period_accrual_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `reversal_document_number` SET TAGS ('dbx_business_glossary_term' = 'Reversal SAP Financial (FI) Document Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `sap_fi_document_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Financial (FI) Document Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `accrual_status` SET TAGS ('dbx_value_regex' = 'draft|posted|reversed|adjusted|approved|cancelled');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `unit_rate` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `variance_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`accrual` ALTER COLUMN `wbs_element` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Element');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ADD CONSTRAINT `fk_finance_revenue_recognition_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ADD CONSTRAINT `fk_finance_revenue_recognition_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ADD CONSTRAINT `fk_finance_revenue_recognition_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ADD CONSTRAINT `fk_finance_revenue_recognition_deliverable_id` FOREIGN KEY (`deliverable_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`deliverable`(`deliverable_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ADD CONSTRAINT `fk_finance_revenue_recognition_evidence_tmf_document_id` FOREIGN KEY (`evidence_tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ADD CONSTRAINT `fk_finance_revenue_recognition_finance_billing_milestone_id` FOREIGN KEY (`finance_billing_milestone_id`) REFERENCES `clinical_trials_ecm`.`finance`.`finance_billing_milestone`(`finance_billing_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ADD CONSTRAINT `fk_finance_revenue_recognition_gl_account_id` FOREIGN KEY (`gl_account_id`) REFERENCES `clinical_trials_ecm`.`finance`.`gl_account`(`gl_account_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ADD CONSTRAINT `fk_finance_revenue_recognition_interim_analysis_id` FOREIGN KEY (`interim_analysis_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`interim_analysis`(`interim_analysis_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ADD CONSTRAINT `fk_finance_revenue_recognition_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ADD CONSTRAINT `fk_finance_revenue_recognition_original_recognition_revenue_recognition_id` FOREIGN KEY (`original_recognition_revenue_recognition_id`) REFERENCES `clinical_trials_ecm`.`finance`.`revenue_recognition`(`revenue_recognition_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ADD CONSTRAINT `fk_finance_revenue_recognition_program_development_milestone_id` FOREIGN KEY (`program_development_milestone_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_development_milestone`(`program_development_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ADD CONSTRAINT `fk_finance_revenue_recognition_regulatory_approval_id` FOREIGN KEY (`regulatory_approval_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`approval`(`approval_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ADD CONSTRAINT `fk_finance_revenue_recognition_scope_of_work_id` FOREIGN KEY (`scope_of_work_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`scope_of_work`(`scope_of_work_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ADD CONSTRAINT `fk_finance_revenue_recognition_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ADD CONSTRAINT `fk_finance_revenue_recognition_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ADD CONSTRAINT `fk_finance_revenue_recognition_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` SET TAGS ('dbx_domain' = 'finance');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` SET TAGS ('dbx_subdomain' = 'transaction_processing');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `database_lock_event_id` SET TAGS ('dbx_business_glossary_term' = 'Biostatistics Dbl Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `deliverable_id` SET TAGS ('dbx_business_glossary_term' = 'Deliverable Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `evidence_tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Evidence Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `finance_billing_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Finance Billing Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `interim_analysis_id` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `original_recognition_revenue_recognition_id` SET TAGS ('dbx_business_glossary_term' = 'Original Revenue Recognition ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `program_development_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Program Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `regulatory_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `scope_of_work_id` SET TAGS ('dbx_business_glossary_term' = 'Scope Of Work Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Contract ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `accrual_flag` SET TAGS ('dbx_business_glossary_term' = 'Revenue Accrual Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `completion_percentage` SET TAGS ('dbx_business_glossary_term' = 'Percentage of Completion');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `completion_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `contract_value` SET TAGS ('dbx_business_glossary_term' = 'Total Contract Value');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `contract_value` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `cumulative_recognized_amount` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Recognized Revenue Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `cumulative_recognized_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `deferred_revenue_balance` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `fiscal_period` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-(0[1-9]|1[0-2])$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `functional_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Functional Currency Code (ISO 4217)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `functional_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Recognition Notes');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Phase');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase II|Phase III|Phase IV|Phase I/II|Phase II/III');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `prior_period_completion_percentage` SET TAGS ('dbx_business_glossary_term' = 'Prior Period Percentage of Completion');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `prior_period_completion_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `rar_document_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Revenue Accounting and Reporting (RAR) Document Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `rar_document_reference` SET TAGS ('dbx_business_glossary_term' = 'SAP Revenue Accounting and Reporting (RAR) Document ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `recognition_date` SET TAGS ('dbx_business_glossary_term' = 'Revenue Recognition Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `recognition_method` SET TAGS ('dbx_business_glossary_term' = 'Revenue Recognition Method');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `recognition_method` SET TAGS ('dbx_value_regex' = 'percentage_of_completion|milestone|straight_line|output_method|input_method');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `recognition_status` SET TAGS ('dbx_business_glossary_term' = 'Revenue Recognition Status');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `recognition_status` SET TAGS ('dbx_value_regex' = 'draft|pending_review|recognized|reversed|cancelled');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `recognized_amount` SET TAGS ('dbx_business_glossary_term' = 'Recognized Revenue Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `recognized_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `recognized_amount_functional` SET TAGS ('dbx_business_glossary_term' = 'Recognized Revenue Amount in Functional Currency');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `recognized_amount_functional` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `reversal_flag` SET TAGS ('dbx_business_glossary_term' = 'Revenue Reversal Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `service_line` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Service Line');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `sox_control_reference` SET TAGS ('dbx_business_glossary_term' = 'Sarbanes-Oxley (SOX) Control Reference');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `unbilled_receivable_amount` SET TAGS ('dbx_business_glossary_term' = 'Unbilled Receivable Amount (Contract Asset)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `unbilled_receivable_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`revenue_recognition` ALTER COLUMN `wbs_element` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Element');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_account_plan_id` FOREIGN KEY (`account_plan_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`account_plan`(`account_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_approver_employee_id` FOREIGN KEY (`approver_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_ecm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_pipeline_asset_id` FOREIGN KEY (`pipeline_asset_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`pipeline_asset`(`pipeline_asset_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_primary_financial_preparer_employee_id` FOREIGN KEY (`primary_financial_preparer_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_sample_size_calc_id` FOREIGN KEY (`sample_size_calc_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sample_size_calc`(`sample_size_calc_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_scope_of_work_id` FOREIGN KEY (`scope_of_work_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`scope_of_work`(`scope_of_work_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_study_budget_id` FOREIGN KEY (`study_budget_id`) REFERENCES `clinical_trials_ecm`.`finance`.`study_budget`(`study_budget_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_study_protocol_milestone_id` FOREIGN KEY (`study_protocol_milestone_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_milestone`(`study_protocol_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_timeline_id` FOREIGN KEY (`timeline_id`) REFERENCES `clinical_trials_ecm`.`program`.`timeline`(`timeline_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ADD CONSTRAINT `fk_finance_financial_forecast_workforce_resource_plan_id` FOREIGN KEY (`workforce_resource_plan_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`workforce_resource_plan`(`workforce_resource_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` SET TAGS ('dbx_domain' = 'finance');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` SET TAGS ('dbx_subdomain' = 'budget_planning');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `account_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Account Plan Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Study Country Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `monitoring_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Plan Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `pipeline_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `primary_financial_preparer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Preparer Employee ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `primary_financial_preparer_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `primary_financial_preparer_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `primary_financial_preparer_employee_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `sample_size_calc_id` SET TAGS ('dbx_business_glossary_term' = 'Sample Size Calc Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `scope_of_work_id` SET TAGS ('dbx_business_glossary_term' = 'Scope Of Work Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `study_budget_id` SET TAGS ('dbx_business_glossary_term' = 'Study Budget Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `study_protocol_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Study Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `timeline_id` SET TAGS ('dbx_business_glossary_term' = 'Program Timeline Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `workforce_resource_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Workforce Resource Plan Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `accrual_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Forecast Approval Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `budget_cost_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `budget_revenue_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `cash_inflow_forecast_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `cash_outflow_forecast_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Forecast Confidence Level');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `confidence_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `cost_variance_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `direct_cost_forecast_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `forecast_basis` SET TAGS ('dbx_value_regex' = 'bottom_up|top_down|run_rate|statistical_model|hybrid');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `forecast_number` SET TAGS ('dbx_value_regex' = '^FC-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `forecast_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|superseded|archived');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `gross_margin_forecast_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `gross_margin_forecast_pct` SET TAGS ('dbx_business_glossary_term' = 'Gross Margin Forecast Percentage');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `gross_margin_forecast_pct` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `indirect_cost_forecast_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `is_baseline_forecast` SET TAGS ('dbx_business_glossary_term' = 'Is Baseline Forecast Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `milestone_completion_pct` SET TAGS ('dbx_business_glossary_term' = 'Milestone Completion Percentage');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `pass_through_cost_forecast_amount` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Cost Forecast Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `pass_through_cost_forecast_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `preparation_date` SET TAGS ('dbx_business_glossary_term' = 'Forecast Preparation Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `revenue_forecast_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `revenue_variance_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `scope_level` SET TAGS ('dbx_business_glossary_term' = 'Forecast Scope Level');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `scope_level` SET TAGS ('dbx_value_regex' = 'study|portfolio|program|country');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`financial_forecast` ALTER COLUMN `wbs_element_code` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Element Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ADD CONSTRAINT `fk_finance_finance_billing_milestone_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ADD CONSTRAINT `fk_finance_finance_billing_milestone_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ADD CONSTRAINT `fk_finance_finance_billing_milestone_evidence_tmf_document_id` FOREIGN KEY (`evidence_tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ADD CONSTRAINT `fk_finance_finance_billing_milestone_nda_bla_application_id` FOREIGN KEY (`nda_bla_application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`nda_bla_application`(`nda_bla_application_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ADD CONSTRAINT `fk_finance_finance_billing_milestone_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ADD CONSTRAINT `fk_finance_finance_billing_milestone_program_development_milestone_id` FOREIGN KEY (`program_development_milestone_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_development_milestone`(`program_development_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ADD CONSTRAINT `fk_finance_finance_billing_milestone_proposal_id` FOREIGN KEY (`proposal_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`proposal`(`proposal_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ADD CONSTRAINT `fk_finance_finance_billing_milestone_regulatory_approval_id` FOREIGN KEY (`regulatory_approval_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`approval`(`approval_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ADD CONSTRAINT `fk_finance_finance_billing_milestone_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_ecm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ADD CONSTRAINT `fk_finance_finance_billing_milestone_regulatory_commitment_id` FOREIGN KEY (`regulatory_commitment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`commitment`(`commitment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ADD CONSTRAINT `fk_finance_finance_billing_milestone_sponsor_invoice_id` FOREIGN KEY (`sponsor_invoice_id`) REFERENCES `clinical_trials_ecm`.`finance`.`sponsor_invoice`(`sponsor_invoice_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ADD CONSTRAINT `fk_finance_finance_billing_milestone_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ADD CONSTRAINT `fk_finance_finance_billing_milestone_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ADD CONSTRAINT `fk_finance_finance_billing_milestone_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ADD CONSTRAINT `fk_finance_finance_billing_milestone_triggering_subject_randomization_id` FOREIGN KEY (`triggering_subject_randomization_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ADD CONSTRAINT `fk_finance_finance_billing_milestone_workflow_id` FOREIGN KEY (`workflow_id`) REFERENCES `clinical_trials_ecm`.`document`.`workflow`(`workflow_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` SET TAGS ('dbx_domain' = 'finance');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` SET TAGS ('dbx_subdomain' = 'budget_planning');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `evidence_tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Evidence Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `nda_bla_application_id` SET TAGS ('dbx_business_glossary_term' = 'Nda Bla Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `program_development_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Program Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `proposal_id` SET TAGS ('dbx_business_glossary_term' = 'Proposal Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `regulatory_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `regulatory_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Regulatory Commitment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `sponsor_invoice_id` SET TAGS ('dbx_business_glossary_term' = 'Invoice ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `triggering_subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Triggering Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `workflow_id` SET TAGS ('dbx_business_glossary_term' = 'Document Workflow Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `accrual_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `accrual_pct` SET TAGS ('dbx_business_glossary_term' = 'Accrual Percentage');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `actual_trigger_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Milestone Trigger Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Milestone Approval Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Milestone Approval Status');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending_approval|approved|rejected|not_required');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `billing_amount` SET TAGS ('dbx_business_glossary_term' = 'Billing Milestone Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `billing_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `billing_plan_line_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Billing Plan Line Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Billing Currency Code');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange Rate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `functional_currency_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `is_at_risk` SET TAGS ('dbx_business_glossary_term' = 'At-Risk Milestone Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `is_pass_through` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Cost Indicator');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `milestone_description` SET TAGS ('dbx_business_glossary_term' = 'Billing Milestone Description');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `milestone_name` SET TAGS ('dbx_business_glossary_term' = 'Billing Milestone Name');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `milestone_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `milestone_number` SET TAGS ('dbx_business_glossary_term' = 'Billing Milestone Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `milestone_number` SET TAGS ('dbx_value_regex' = '^BM-[A-Z0-9]{3,20}-[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `milestone_sequence` SET TAGS ('dbx_business_glossary_term' = 'Billing Milestone Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `milestone_status` SET TAGS ('dbx_business_glossary_term' = 'Billing Milestone Status');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `milestone_status` SET TAGS ('dbx_value_regex' = 'pending|triggered|invoiced|paid|cancelled|on_hold');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `milestone_type` SET TAGS ('dbx_business_glossary_term' = 'Billing Milestone Type');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `milestone_type` SET TAGS ('dbx_value_regex' = 'enrollment_based|visit_based|deliverable_based|time_based|regulatory_based');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Billing Milestone Notes');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `original_billing_amount` SET TAGS ('dbx_business_glossary_term' = 'Original Billing Milestone Amount');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `original_billing_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `payment_amount_received` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `revenue_recognition_method` SET TAGS ('dbx_value_regex' = 'milestone_completion|percentage_of_completion|straight_line|event_based');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `sap_wbs_element` SET TAGS ('dbx_business_glossary_term' = 'SAP Work Breakdown Structure (WBS) Element');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `trigger_criteria` SET TAGS ('dbx_business_glossary_term' = 'Milestone Trigger Criteria');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `trigger_threshold_unit` SET TAGS ('dbx_business_glossary_term' = 'Milestone Trigger Threshold Unit');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `trigger_threshold_unit` SET TAGS ('dbx_value_regex' = 'subjects|visits|sites|percentage|days|deliverables');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `trigger_threshold_value` SET TAGS ('dbx_business_glossary_term' = 'Milestone Trigger Threshold Value');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`finance_billing_milestone` ALTER COLUMN `withholding_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_ecm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_bioanalytical_assay_id` FOREIGN KEY (`bioanalytical_assay_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay`(`bioanalytical_assay_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_budget_vendor_invoice_id` FOREIGN KEY (`budget_vendor_invoice_id`) REFERENCES `clinical_trials_ecm`.`finance`.`vendor_invoice`(`vendor_invoice_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_change_order_id` FOREIGN KEY (`change_order_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`change_order`(`change_order_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_ecm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_deliverable_id` FOREIGN KEY (`deliverable_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`deliverable`(`deliverable_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_dosing_regimen_id` FOREIGN KEY (`dosing_regimen_id`) REFERENCES `clinical_trials_ecm`.`study`.`dosing_regimen`(`dosing_regimen_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_dsmb_review_id` FOREIGN KEY (`dsmb_review_id`) REFERENCES `clinical_trials_ecm`.`safety`.`dsmb_review`(`dsmb_review_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_edc_study_build_id` FOREIGN KEY (`edc_study_build_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`edc_study_build`(`edc_study_build_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_ecm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_finance_billing_milestone_id` FOREIGN KEY (`finance_billing_milestone_id`) REFERENCES `clinical_trials_ecm`.`finance`.`finance_billing_milestone`(`finance_billing_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_gl_account_id` FOREIGN KEY (`gl_account_id`) REFERENCES `clinical_trials_ecm`.`finance`.`gl_account`(`gl_account_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_icf_amendment_id` FOREIGN KEY (`icf_amendment_id`) REFERENCES `clinical_trials_ecm`.`consent`.`icf_amendment`(`icf_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_interim_analysis_id` FOREIGN KEY (`interim_analysis_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`interim_analysis`(`interim_analysis_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_ecm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_monitoring_cra_assignment_id` FOREIGN KEY (`monitoring_cra_assignment_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_cra_assignment`(`monitoring_cra_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_monitoring_visit_id` FOREIGN KEY (`monitoring_visit_id`) REFERENCES `clinical_trials_ecm`.`monitoring`.`monitoring_visit`(`monitoring_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_nda_bla_application_id` FOREIGN KEY (`nda_bla_application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`nda_bla_application`(`nda_bla_application_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_pipeline_asset_id` FOREIGN KEY (`pipeline_asset_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`pipeline_asset`(`pipeline_asset_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_pk_sampling_schedule_id` FOREIGN KEY (`pk_sampling_schedule_id`) REFERENCES `clinical_trials_ecm`.`study`.`pk_sampling_schedule`(`pk_sampling_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_program_development_milestone_id` FOREIGN KEY (`program_development_milestone_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_development_milestone`(`program_development_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_proposal_line_id` FOREIGN KEY (`proposal_line_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`proposal_line`(`proposal_line_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_protocol_lab_schedule_id` FOREIGN KEY (`protocol_lab_schedule_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule`(`protocol_lab_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_purchase_order_id` FOREIGN KEY (`purchase_order_id`) REFERENCES `clinical_trials_ecm`.`finance`.`purchase_order`(`purchase_order_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_rate_card_id` FOREIGN KEY (`rate_card_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`rate_card`(`rate_card_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_regulatory_approval_id` FOREIGN KEY (`regulatory_approval_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`approval`(`approval_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_regulatory_commitment_id` FOREIGN KEY (`regulatory_commitment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`commitment`(`commitment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_regulatory_inspection_id` FOREIGN KEY (`regulatory_inspection_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_inspection`(`regulatory_inspection_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_rems_program_id` FOREIGN KEY (`rems_program_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`rems_program`(`rems_program_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_sample_size_calc_id` FOREIGN KEY (`sample_size_calc_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sample_size_calc`(`sample_size_calc_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_scope_of_work_id` FOREIGN KEY (`scope_of_work_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`scope_of_work`(`scope_of_work_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_serious_adverse_event_id` FOREIGN KEY (`serious_adverse_event_id`) REFERENCES `clinical_trials_ecm`.`safety`.`serious_adverse_event`(`serious_adverse_event_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_site_agreement_id` FOREIGN KEY (`site_agreement_id`) REFERENCES `clinical_trials_ecm`.`site`.`site_agreement`(`site_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_specimen_shipment_id` FOREIGN KEY (`specimen_shipment_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`specimen_shipment`(`specimen_shipment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_sponsor_invoice_id` FOREIGN KEY (`sponsor_invoice_id`) REFERENCES `clinical_trials_ecm`.`finance`.`sponsor_invoice`(`sponsor_invoice_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_study_budget_id` FOREIGN KEY (`study_budget_id`) REFERENCES `clinical_trials_ecm`.`finance`.`study_budget`(`study_budget_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_subcontract_id` FOREIGN KEY (`subcontract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`subcontract`(`subcontract_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_timeline_id` FOREIGN KEY (`timeline_id`) REFERENCES `clinical_trials_ecm`.`program`.`timeline`(`timeline_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_vendor_id` FOREIGN KEY (`vendor_id`) REFERENCES `clinical_trials_ecm`.`finance`.`vendor`(`vendor_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_vendor_invoice_id` FOREIGN KEY (`vendor_invoice_id`) REFERENCES `clinical_trials_ecm`.`finance`.`vendor_invoice`(`vendor_invoice_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_visit_procedure_id` FOREIGN KEY (`visit_procedure_id`) REFERENCES `clinical_trials_ecm`.`study`.`visit_procedure`(`visit_procedure_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ADD CONSTRAINT `fk_finance_budget_line_workforce_resource_plan_id` FOREIGN KEY (`workforce_resource_plan_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`workforce_resource_plan`(`workforce_resource_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` SET TAGS ('dbx_domain' = 'finance');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` SET TAGS ('dbx_subdomain' = 'budget_planning');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `bioanalytical_assay_id` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Assay Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `change_order_id` SET TAGS ('dbx_business_glossary_term' = 'Change Order Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Capa Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `dosing_regimen_id` SET TAGS ('dbx_business_glossary_term' = 'Dosing Regimen Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `edc_study_build_id` SET TAGS ('dbx_business_glossary_term' = 'Edc Study Build Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Epoch Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `finance_billing_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Finance Billing Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `icf_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Icf Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Panel Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `monitoring_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Plan Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `pk_sampling_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Pk Sampling Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `proposal_line_id` SET TAGS ('dbx_business_glossary_term' = 'Proposal Line Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `protocol_lab_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Lab Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `rate_card_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Card Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `study_budget_id` SET TAGS ('dbx_business_glossary_term' = 'Budget ID');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Study Visit Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `visit_procedure_id` SET TAGS ('dbx_business_glossary_term' = 'Visit Procedure Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `accrual_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `actual_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Budget Line Approved Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `committed_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `cost_category` SET TAGS ('dbx_value_regex' = 'direct_labor|pass_through|investigator_grant|overhead|patient_stipend');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `functional_currency_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `is_milestone_based` SET TAGS ('dbx_business_glossary_term' = 'Is Milestone-Based Payment Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `is_pass_through` SET TAGS ('dbx_business_glossary_term' = 'Is Pass-Through Cost Flag');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `line_description` SET TAGS ('dbx_business_glossary_term' = 'Budget Line Description');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `line_number` SET TAGS ('dbx_business_glossary_term' = 'Budget Line Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `line_status` SET TAGS ('dbx_business_glossary_term' = 'Budget Line Status');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `line_status` SET TAGS ('dbx_value_regex' = 'draft|approved|active|on_hold|cancelled|closed');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Budget Line Notes');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Budget Period End Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Budget Period Start Date');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `planned_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `sap_internal_order` SET TAGS ('dbx_business_glossary_term' = 'SAP Internal Order Number');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `sponsor_line_ref` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Budget Line Reference');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `unit_cost` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`finance`.`budget_line` ALTER COLUMN `wbs_element` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Element');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ADD CONSTRAINT `fk_finance_vendor_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ADD CONSTRAINT `fk_finance_vendor_parent_vendor_id` FOREIGN KEY (`parent_vendor_id`) REFERENCES `clinical_trials_ecm`.`finance`.`vendor`(`vendor_id`);

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` SET TAGS ('dbx_domain' = 'finance');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` SET TAGS ('dbx_subdomain' = 'transaction_processing');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `vendor_id` SET TAGS ('dbx_business_glossary_term' = 'Vendor Identifier');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `parent_vendor_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `address_line_1` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `address_line_1` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `address_line_1` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `address_line_2` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `address_line_2` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `address_line_2` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_pii_bank_account' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `bank_routing_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `vendor_category` SET TAGS ('dbx_business_glossary_term' = 'Category');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `city` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `dba_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `vendor_name` SET TAGS ('dbx_business_glossary_term' = 'Name');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `vendor_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `state_province` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `state_province` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `state_province` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `vendor_status` SET TAGS ('dbx_business_glossary_term' = 'Status');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `tax_identifier` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `tax_identifier` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `tax_identifier` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`finance`.`vendor` ALTER COLUMN `vendor_type` SET TAGS ('dbx_business_glossary_term' = 'Type');
